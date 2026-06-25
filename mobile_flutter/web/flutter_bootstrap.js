{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine({
        // Self-host CanvasKit (bundled into ./canvaskit/ by `flutter build web`)
        // instead of fetching ~7 MB of WASM from gstatic.com, which can be
        // blocked/unreachable on restricted networks.
        canvasKitBaseUrl: "canvaskit/",
      });
      await appRunner.runApp();
      // App painted — remove the plain-HTML boot overlay from index.html.
      var boot = document.getElementById('boot-status');
      if (boot) boot.remove();
    } catch (err) {
      var detail = document.getElementById('boot-detail');
      var label = document.querySelector('#boot-status .label');
      if (label) label.textContent = 'UNIFY engine failed to initialize';
      if (detail) detail.textContent += 'Engine init error: ' + (err && err.message ? err.message : err) + '\n';
    }
  }
});
