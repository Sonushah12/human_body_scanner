import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/bindings/app_bindings.dart';
import 'core/localization/app_translations.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/body_explorer/presentation/explorer_view.dart';
import 'features/bookmarks/presentation/bookmarks_view.dart';
import 'features/part_detail/presentation/detail_view.dart';
import 'features/quiz/presentation/quiz_view.dart';
import 'features/settings/presentation/credits_view.dart';
import 'features/settings/presentation/settings_controller.dart';
import 'features/settings/presentation/settings_view.dart';

class AnatoMorphApp extends StatelessWidget {
  const AnatoMorphApp({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Obx(
      () => GetMaterialApp(
        title: 'AnatoMorph',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.create(Brightness.light),
        darkTheme: AppTheme.create(Brightness.dark),
        themeMode: settings.themeMode,
        translations: AppTranslations(),
        locale: Locale(settings.language.value),
        fallbackLocale: const Locale('en'),
        supportedLocales: const [Locale('en'), Locale('hi'), Locale('gu')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        defaultTransition: settings.reduceMotion.value
            ? Transition.noTransition
            : Transition.cupertino,
        transitionDuration: settings.reduceMotion.value
            ? Duration.zero
            : const Duration(milliseconds: 280),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                settings.reduceMotion.value ||
                MediaQuery.disableAnimationsOf(context),
          ),
          child: child!,
        ),
        initialRoute: AppRoutes.explore,
        getPages: [
          GetPage(
            name: AppRoutes.explore,
            page: () => const ExplorerView(),
            binding: ExplorerBinding(),
          ),
          GetPage(
            name: AppRoutes.bookmarks,
            page: () => const BookmarksView(),
            binding: BookmarksBinding(),
          ),
          GetPage(
            name: AppRoutes.detail,
            page: () => const DetailView(),
            binding: DetailBinding(),
          ),
          GetPage(
            name: AppRoutes.quiz,
            page: () => const QuizView(),
            binding: QuizBinding(),
          ),
          GetPage(name: AppRoutes.settings, page: () => const SettingsView()),
          GetPage(
            name: AppRoutes.credits,
            page: () => const CreditsView(),
            binding: CreditsBinding(),
          ),
        ],
        unknownRoute: GetPage(
          name: '/not-found',
          page: () => const ExplorerView(),
          binding: ExplorerBinding(),
        ),
      ),
    );
  }
}
