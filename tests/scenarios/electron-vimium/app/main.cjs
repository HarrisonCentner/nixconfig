require("@inject@");
const fs = require("node:fs");
const path = require("node:path");
const { app, BrowserWindow } = require("electron");

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const press = (contents, keyCode) => {
  for (const type of ["keyDown", "char", "keyUp"]) contents.sendInputEvent({ type, keyCode });
};
const poll = async (attempt) => {
  for (let i = 0; i < 40; i++) {
    const value = await attempt();
    if (value) return value;
    await sleep(500);
  }
  return 0;
};

app.whenReady().then(async () => {
  const win = new BrowserWindow({ width: 800, height: 600 });
  await win.loadFile(path.join(__dirname, "page.html"));
  const contents = win.webContents;
  contents.focus();

  const hints = await poll(async () => {
    press(contents, "f");
    await sleep(300);
    return contents.executeJavaScript(
      'document.querySelectorAll("#vimium-hint-marker-container .vimiumHintMarker").length',
    );
  });
  const treeitemHint = await contents.executeJavaScript(`(() => {
    const target = document.querySelector('[role="treeitem"]').getBoundingClientRect();
    const distance = (marker) => {
      const rect = marker.getBoundingClientRect();
      return Math.abs(rect.x - target.x) + Math.abs(rect.y - target.y);
    };
    const markers = [...document.querySelectorAll("#vimium-hint-marker-container .vimiumHintMarker")];
    return markers.sort((a, b) => distance(a) - distance(b))[0].textContent;
  })()`);
  for (const key of treeitemHint.toLowerCase()) press(contents, key);
  await sleep(500);
  const treeitemClicked = await contents.executeJavaScript('document.title === "clicked"');

  const scrollY = await poll(async () => {
    press(contents, "j");
    await sleep(300);
    return contents.executeJavaScript("window.scrollY");
  });

  fs.writeFileSync(process.env.RESULT, JSON.stringify({ hints, treeitemClicked, scrollY }));
  app.quit();
});
