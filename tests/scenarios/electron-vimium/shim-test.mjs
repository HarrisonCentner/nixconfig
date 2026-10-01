import assert from "node:assert/strict";
import fs from "node:fs";
import vm from "node:vm";

const shimSource = fs.readFileSync(process.argv[2], "utf8");

// Objects created inside the vm realm have foreign prototypes; compare as JSON.
const plain = (value) => JSON.parse(JSON.stringify(value));

const fakeChrome = (initial = {}) => {
  const data = { ...initial };
  const listeners = new Set();
  const messageListeners = new Set();
  const emit = (changes) => {
    for (const listener of listeners) listener(changes, "local");
  };
  const local = {
    get: async (keys) => {
      if (keys == null) return { ...data };
      if (typeof keys === "string") keys = [keys];
      if (Array.isArray(keys)) {
        return Object.fromEntries(keys.filter((key) => key in data).map((key) => [key, data[key]]));
      }
      return Object.fromEntries(
        Object.entries(keys).map(([key, fallback]) => [key, key in data ? data[key] : fallback]),
      );
    },
    set: async (items) => {
      const changes = {};
      for (const [key, value] of Object.entries(items)) {
        changes[key] = { oldValue: data[key], newValue: value };
        data[key] = value;
      }
      emit(changes);
    },
    remove: async (keys) => {
      const changes = {};
      for (const key of [].concat(keys)) {
        if (key in data) {
          changes[key] = { oldValue: data[key] };
          delete data[key];
        }
      }
      emit(changes);
    },
  };
  const chrome = {
    storage: {
      local,
      sync: {
        get: async () => {
          throw new Error('"sync" is not available in this instance of Chrome');
        },
      },
      session: {
        get: async () => {
          throw new Error("Access to storage is not allowed from this context.");
        },
      },
      onChanged: {
        addListener: (listener) => listeners.add(listener),
        removeListener: (listener) => listeners.delete(listener),
        hasListener: (listener) => listeners.has(listener),
      },
    },
    tabs: { query: async () => ["real"] },
    runtime: {
      onMessage: {
        addListener: (listener) => messageListeners.add(listener),
      },
    },
  };
  const message = (sender) => {
    for (const listener of messageListeners) listener({}, sender);
  };
  return { data, chrome, message };
};

const load = (chrome, { background }) => {
  const context = vm.createContext({ chrome, console });
  if (!background) context.document = {};
  vm.runInContext(shimSource, context);
  return context;
};

// Content-script context.
{
  const { data, chrome } = fakeChrome({ plain: 1 });
  const context = load(chrome, { background: false });

  await chrome.storage.sync.set({ a: 1 });
  assert.equal(data["sync:a"], 1);
  assert.deepEqual(plain(await chrome.storage.sync.get("a")), { a: 1 });
  assert.deepEqual(plain(await chrome.storage.sync.get({ a: 0, b: 2 })), { a: 1, b: 2 });
  assert.deepEqual(plain(await chrome.storage.sync.get(null)), { a: 1 });
  assert.deepEqual(plain(await chrome.storage.local.get("plain")), { plain: 1 });

  const viaCallback = await new Promise((resolve) => chrome.storage.session.get("missing", resolve));
  assert.deepEqual(plain(viaCallback), {});

  const seen = [];
  chrome.storage.onChanged.addListener((changes, area) => seen.push([area, Object.keys(changes)]));
  await chrome.storage.session.set({ k: 1 });
  await chrome.storage.local.set({ l: 1 });
  assert.deepEqual(plain(seen), [["session", ["k"]], ["local", ["l"]]]);

  await chrome.storage.sync.clear();
  assert.deepEqual(Object.keys(data).sort(), ["l", "plain", "session:k"]);

  assert.deepEqual(plain(await chrome.tabs.query({})), ["real"]);
  chrome.tabs.onRemoved.addListener(() => {});
  chrome.history.onVisited.addListener(() => {});
  chrome.webNavigation.onCommitted.addListener(() => {});
  assert.deepEqual(plain(await chrome.bookmarks.getTree()), []);
  assert.equal(chrome.windows.WINDOW_ID_CURRENT, undefined);
  assert.deepEqual(plain(await chrome.webNavigation.getAllFrames({ tabId: 1 })), [{ frameId: 0 }]);

  const tabs = chrome.tabs;
  vm.runInContext(shimSource, context);
  assert.equal(chrome.tabs, tabs, "shim must be idempotent");
}

// Background (service worker) context clears stale session keys.
{
  const { data, chrome } = fakeChrome({ "session:stale": 1, "sync:keep": 1 });
  load(chrome, { background: true });
  await chrome.storage.session.set({ fresh: 1 });
  assert.deepEqual(plain(await chrome.storage.session.get(null)), { fresh: 1 });
  assert.equal(data["sync:keep"], 1);
}

// Background context answers getAllFrames from frames that have messaged it.
{
  const { chrome, message } = fakeChrome();
  load(chrome, { background: true });
  message({ tab: { id: 1 }, frameId: 0 });
  message({ tab: { id: 1 }, frameId: 7 });
  message({ tab: { id: 2 }, frameId: 3 });
  message({});
  const frameIds = async (tabId) =>
    plain(await chrome.webNavigation.getAllFrames({ tabId })).map((frame) => frame.frameId);
  assert.deepEqual(await frameIds(1), [0, 7]);
  assert.deepEqual(await frameIds(2), [0, 3]);
  assert.deepEqual(await frameIds(9), [0]);
}

console.log("electron shim: ok");
