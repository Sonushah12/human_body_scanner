import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes/app_routes.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.selected, required this.child, super.key});
  final int selected;
  final Widget child;
  static const _paths = [
    AppRoutes.explore,
    AppRoutes.bookmarks,
    AppRoutes.quiz,
    AppRoutes.settings,
  ];

  void _navigate(int index) {
    if (index != selected) unawaited(Get.offNamed<void>(_paths[index]));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final labels = ['explore'.tr, 'saved'.tr, 'quiz'.tr, 'settings'.tr];
    const icons = [
      Icons.explore_outlined,
      Icons.bookmark_border,
      Icons.school_outlined,
      Icons.tune,
    ];
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide) ...[
              SizedBox(
                width: 112,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: BrandMark(size: 42),
                    ),
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: selected,
                        onDestinationSelected: _navigate,
                        labelType: NavigationRailLabelType.all,
                        destinations: List.generate(
                          4,
                          (i) => NavigationRailDestination(
                            icon: Icon(icons[i]),
                            label: Text(labels[i]),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'v1.0',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: selected,
              onDestinationSelected: _navigate,
              destinations: List.generate(
                4,
                (i) => NavigationDestination(
                  icon: Icon(icons[i]),
                  label: labels[i],
                ),
              ),
            ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 32, super.key});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(size * .3),
    ),
    child: Icon(
      Icons.accessibility_new_rounded,
      color: Theme.of(context).colorScheme.onPrimary,
      size: size * .65,
    ),
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
    super.key,
  });
  final String title;
  final String subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BrandMark(),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'AnatoMorph',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -.5,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: trailing!,
              ),
            ],
          ],
        ),
        const SizedBox(height: 26),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    super.key,
  });
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: .45),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ],
      ),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    this.icon = Icons.offline_bolt_outlined,
    super.key,
  });
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .4),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> openReference(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.scheme != 'https') return;
  try {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('link_error'.tr, url, snackPosition: SnackPosition.BOTTOM);
    }
  } catch (_) {
    Get.snackbar('link_error'.tr, url, snackPosition: SnackPosition.BOTTOM);
  }
}
