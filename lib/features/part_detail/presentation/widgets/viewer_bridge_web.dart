import 'dart:js_interop';
import 'package:web/web.dart' as web;

typedef VoidCallback = void Function();

VoidCallback subscribeViewer(String id, void Function(bool ready) onStatus) {
  final listener = ((web.Event event) {
    final data = (event as web.CustomEvent).detail.dartify();
    if (data is Map && data['id'] == id) onStatus(data['status'] == 'ready');
  }).toJS;
  web.window.addEventListener('anatomorph-model', listener);
  return () => web.window.removeEventListener('anatomorph-model', listener);
}

void resetCamera(String id) {
  final model = web.document.getElementById(id);
  model?.removeAttribute('auto-rotate');
  model?.setAttribute('camera-orbit', '0deg 90deg 105%');
  model?.setAttribute('camera-target', '0m 0m 0m');
}
