{{flutter_js}}
{{flutter_build_config}}

// index.html owns sw.js registration. Avoid registering Flutter's deprecated
// cleanup worker over the application's versioned offline cache.
_flutter.loader.load();
