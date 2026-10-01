const { app, session } = require("electron");

const loaded = new WeakSet();
const load = async (target) => {
  if (loaded.has(target)) return;
  loaded.add(target);
  try {
    await target.extensions.loadExtension("@extension@", { allowFileAccess: true });
  } catch (error) {
    console.error("vimium-electron:", error.message);
  }
};

app.on("session-created", load);
app.whenReady().then(() => load(session.defaultSession));
