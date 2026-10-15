// Lifecycle bridge for the self-hosted model-viewer web component.
// No remote scripts, network analytics, or tracking.
const connected = new WeakSet();
function attachModels() {
  document.querySelectorAll('model-viewer').forEach(model => {
    if (connected.has(model)) return;
    connected.add(model);
    const send = status => window.dispatchEvent(new CustomEvent('anatomorph-model', {
      detail: {id: model.id, status},
    }));
    model.addEventListener('load', () => send('ready'));
    model.addEventListener('error', () => send('error'));
    model.addEventListener('pointerdown', () => { model.autoRotate = false; }, {once: true});
    if (model.loaded) send('ready');
  });
}
new MutationObserver(attachModels).observe(document.documentElement, {childList: true, subtree: true});
customElements.whenDefined('model-viewer').then(attachModels);
