import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../../body_explorer/domain/anatomy_part.dart';
import '../../../settings/presentation/settings_controller.dart';
import '../../../../core/widgets/app_shell.dart';
import 'gallery.dart';
import 'viewer_bridge_stub.dart'
    if (dart.library.js_interop) 'viewer_bridge_web.dart'
    as bridge;

class Viewer3d extends StatefulWidget {
  const Viewer3d({required this.part, super.key});
  final AnatomyPart part;
  @override
  State<Viewer3d> createState() => _Viewer3dState();
}

class _Viewer3dState extends State<Viewer3d> {
  Timer? _timeout;
  late void Function() _unsubscribe;
  bool _fallback = false;
  bool _loaded = false;
  bool _failed = false;
  int _revision = 0;
  void Function()? _nativeReset;
  String get _id => 'atlas_${widget.part.id}_$_revision';
  bool get _supported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _unsubscribe = bridge.subscribeViewer(_id, _status);
    if (_supported && widget.part.model3d != null) {
      _timeout = Timer(const Duration(seconds: 20), () {
        if (mounted && !_loaded) setState(() => _failed = true);
      });
    }
  }

  void _status(bool ready) {
    if (!mounted) return;
    _timeout?.cancel();
    setState(() {
      _loaded = ready;
      _failed = !ready;
    });
  }

  void _reload() {
    _timeout?.cancel();
    _unsubscribe();
    setState(() {
      _revision++;
      _loaded = false;
      _failed = false;
      _fallback = false;
    });
    _subscribe();
  }

  void _resetCamera() {
    if (kIsWeb) {
      bridge.resetCamera(_id);
    } else {
      _nativeReset?.call();
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;
    if (!_supported || part.model3d == null || _fallback) {
      return Column(
        children: [
          if (!_fallback)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: EmptyState(
                icon: Icons.view_in_ar_outlined,
                title: 'model_unavailable'.tr,
                description: 'model_fallback'.tr,
              ),
            ),
          AnatomyGallery(part: part),
        ],
      );
    }
    final reduced =
        MediaQuery.disableAnimationsOf(context) ||
        Get.find<SettingsController>().reduceMotion.value;
    final generation = _revision;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 410,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ModelViewer(
                    key: ValueKey(_id),
                    id: _id,
                    // Flutter web assets live under assets/<asset key>.
                    src: kIsWeb ? 'assets/${part.model3d!}' : part.model3d!,
                    alt: part.name(Get.locale?.languageCode ?? 'en'),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    loading: Loading.eager,
                    reveal: Reveal.auto,
                    ar: false,
                    cameraControls: true,
                    disablePan: true,
                    autoRotate: !reduced,
                    autoRotateDelay: 2500,
                    rotationPerSecond: '12deg',
                    cameraOrbit: '0deg 90deg 105%',
                    minCameraOrbit: 'auto auto 45%',
                    maxCameraOrbit: 'auto auto 180%',
                    shadowIntensity: .4,
                    interpolationDecay: 120,
                    debugLogging: false,
                    onWebViewCreated: (webController) {
                      if (!mounted || generation != _revision) return;
                      _nativeReset = () => unawaited(
                        webController
                            .runJavaScript('''
                        (() => {
                        const model = document.querySelector('model-viewer');
                        if (model) {
                          model.autoRotate = false;
                          model.cameraOrbit = '0deg 90deg 105%';
                          model.cameraTarget = '0m 0m 0m';
                        }
                        })();
                      ''')
                            .catchError((Object _) {}),
                      );
                    },
                    relatedJs: '''
            customElements.whenDefined('model-viewer').then(() => {
              const model = document.querySelector('model-viewer');
              if (!model) return;
              model.addEventListener('load', () => { if(window.AtlasStatus) AtlasStatus.postMessage('ready'); });
              model.addEventListener('error', () => { if(window.AtlasStatus) AtlasStatus.postMessage('error'); });
              model.addEventListener('pointerdown', () => model.autoRotate = false, {once:true});
            });
          ''',
                    javascriptChannels: kIsWeb
                        ? null
                        : {
                            JavascriptChannel(
                              'AtlasStatus',
                              onMessageReceived: (message) {
                                if (generation == _revision) {
                                  _status(message.message == 'ready');
                                }
                              },
                            ),
                          },
                  ),
                ),
                if (!_loaded && !_failed)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: IgnorePointer(
                      child: StatusPill(
                        label: 'loading_model'.tr,
                        icon: Icons.hourglass_empty,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _failed ? _reload : _resetCamera,
              icon: const Icon(Icons.restart_alt),
              label: Text(_failed ? 'retry'.tr : 'reset_view'.tr),
            ),
            TextButton.icon(
              onPressed: () {
                _timeout?.cancel();
                setState(() => _fallback = true);
              },
              icon: const Icon(Icons.image_outlined),
              label: Text('use_images'.tr),
            ),
          ],
        ),
        if (_failed) ...[
          const SizedBox(height: 12),
          Text(
            'model_timeout'.tr,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        Text('model_controls'.tr, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 14),
        Text(part.modelNote, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 14),
        Text(part.attribution, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
