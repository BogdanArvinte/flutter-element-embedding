globalThis.onAppInit = async () => {
  console.info("Flutter says %cHow you doin'?", "color: #1b9df0");

  const { appState } = globalThis;

  const backgroundButtons = document.querySelectorAll("fieldset button");
  const defaultImage = "assets/bg1.jpeg";

  backgroundButtons.forEach(
    (button) => (button.onclick = () => generateColorScheme(button.dataset.src))
  );

  appState.streamController.stream.listen((scheme) => {
    setCssProperty("--primary", scheme.primary);
    setCssProperty("--on-primary", scheme.onPrimary);
    setCssProperty("--primary-container", scheme.primaryContainer);
    setCssProperty("--on-primary-container", scheme.onPrimaryContainer);
    setCssProperty("--secondary", scheme.secondary);
    setCssProperty("--on-secondary", scheme.onSecondary);
    setCssProperty("--secondary-container", scheme.secondaryContainer);
    setCssProperty("--on-secondary-container", scheme.onSecondaryContainer);
    setCssProperty("--tertiary", scheme.tertiary);
    setCssProperty("--on-tertiary", scheme.onTertiary);
    setCssProperty("--tertiary-container", scheme.tertiaryContainer);
    setCssProperty("--on-tertiary-container", scheme.onTertiaryContainer);
  });

  generateColorScheme(defaultImage);

  async function generateColorScheme(imagePath) {
    const image = document.querySelector("img");
    const imageResponse = await fetch(imagePath);
    const imageData = new Uint8Array(await imageResponse.arrayBuffer());
    image.src = `data:image/jpeg;base64,${btoa(
      imageData.reduce((result, bytes) => result + String.fromCharCode(bytes), "")
    )}`;
    appState.generateColorScheme(imageData);
  }

  function argbToRgba(argb) {
    return `#${argb.slice(2)}${argb.slice(0, 2)}`;
  }

  function intToHexString(int) {
    return argbToRgba(int.toString(16));
  }

  function setCssProperty(name, value) {
    document.documentElement.style.setProperty(name, intToHexString(value));
  }
};
