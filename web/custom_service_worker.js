const CACHE_NAME = 'flutter-app-cache-v1';

self.addEventListener('install', (event) => {
  console.log('Installing service worker...');

  event.waitUntil(
    fetch('assets/AssetManifest.json')
      .then((response) => {
        if (!response.ok) {
          throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
      })
      .then((manifest) => {
        // Dynamically construct asset paths based on the base scope
        const baseHref = self.registration.scope; // Gets the base path
        console.log('Base href detected:', baseHref);

        // Map over assets in AssetManifest.json and prepend baseHref
        const assets = Object.keys(manifest).map((key) => `${baseHref}assets/${key}`);

        // Add static resources to the list of assets to cache
        const allAssetsToCache = [
          `${baseHref}`, // Root entry point
          `${baseHref}index.html`,
          `${baseHref}main.dart.js`,
          `${baseHref}flutter.js`,
          `${baseHref}manifest.json`,
          ...assets, // Include all dynamic assets
        ];

        console.log('Assets to cache:', allAssetsToCache);

        return caches.open(CACHE_NAME).then((cache) => {
          return cache.addAll(allAssetsToCache);
        });
      })
      .catch((error) => {
        console.error('Failed to cache assets during install:', error);
      })
  );
});

self.addEventListener('activate', (event) => {
  console.log('Activating service worker...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      if (response) {
        console.log('Serving cached:', event.request.url);
        return response;
      }
      console.log('Fetching from network:', event.request.url);
      return fetch(event.request);
    })
  );
});