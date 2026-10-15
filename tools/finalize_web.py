#!/usr/bin/env python3
"""Generate a versioned offline cache for the actual release output.

Run after flutter build web --release --no-web-resources-cdn.
The cache stays on this app's origin and never proxies external source links.
"""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1] / 'build/web'
if not (root/'main.dart.js').exists():
    raise SystemExit('Build the Flutter web release before finalizing its offline cache.')
files = sorted(p for p in root.rglob('*') if p.is_file() and p.name not in ['sw.js','flutter_service_worker.js'] and not p.name.endswith('.map'))
paths = [str(p.relative_to(root)) for p in files]
digest = hashlib.sha256()
for path in files:
    digest.update(str(path.relative_to(root)).encode())
    digest.update(path.read_bytes())
version = 'anatomorph-' + digest.hexdigest()[:16]
worker = """const CACHE = __VERSION__;
const FILES = __FILES__;
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(FILES)).then(()=>self.skipWaiting()));
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k.startsWith('anatomorph-') && k !== CACHE).map(k => caches.delete(k)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;
  event.respondWith(caches.match(request).then(cached => cached || fetch(request).catch(error => {
    if (request.mode === 'navigate') return caches.match('index.html');
    throw error;
  })));
});
"""
(root/'sw.js').write_text(worker.replace('__VERSION__',json.dumps(version)).replace('__FILES__',json.dumps(paths)))
print('Offline cache:',version,'files:',len(files))
