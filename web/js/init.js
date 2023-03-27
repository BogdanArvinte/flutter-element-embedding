const { _flutter } = globalThis;
const hostElement = document.querySelector("#flutter-host");

// Download main.dart.js
_flutter.loader.loadEntrypoint({
  serviceWorker: {
    serviceWorkerVersion,
  },
  onEntrypointLoaded: async (engineInitializer) => {
    const appRunner = await engineInitializer.initializeEngine({
      hostElement,
    });
    await appRunner.runApp();
  },
});
