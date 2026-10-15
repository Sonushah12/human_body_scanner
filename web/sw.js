// The build step tools/finalize_web.py replaces this with a content-addressed
// offline cache. Development builds deliberately avoid stale caching.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', event => event.waitUntil(self.clients.claim()));
