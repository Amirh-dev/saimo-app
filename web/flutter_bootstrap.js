{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Load the rendering engine (skwasm / CanvasKit) from this site, which the
    // build already ships under canvaskit/, rather than from www.gstatic.com:
    // that first-visit download was slow or blocked for many students.
    useLocalCanvasKit: true,
  },
  // No serviceWorkerSettings: Flutter's service worker is deprecated, and
  // a cached copy of an old release is what kept students on it (see
  // lib/data/app_update/).
});
