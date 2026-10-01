(() => {
  if (globalThis.__vimiumElectronShim) return;
  globalThis.__vimiumElectronShim = true;

  const define = (target, name, value) => {
    try {
      Object.defineProperty(target, name, { value, configurable: true, writable: true });
    } catch (error) {
      console.error(`vimium-electron: cannot shim ${name}`, error);
    }
  };

  const callbackable = (impl) => (...args) => {
    const callback = typeof args.at(-1) === "function" ? args.pop() : null;
    const result = impl(...args);
    if (!callback) return result;
    result.then(callback);
  };

  const isBackground = typeof document === "undefined";
  const storage = chrome.storage;
  const local = storage?.local;
  // Electron's native sync rejects every call; its session is closed to content scripts.
  const shimmedAreas = local ? ["sync", "session"] : [];

  if (shimmedAreas.length) {
    const areaOf = (key) => shimmedAreas.find((name) => key.startsWith(`${name}:`)) ?? "local";

    const makeArea = (name) => {
      const prefix = `${name}:`;
      const prefixKeys = (keys) =>
        typeof keys === "string"
          ? [prefix + keys]
          : Array.isArray(keys)
            ? keys.map((key) => prefix + key)
            : Object.fromEntries(Object.entries(keys).map(([key, value]) => [prefix + key, value]));
      const unprefix = (items) =>
        Object.fromEntries(
          Object.entries(items)
            .filter(([key]) => key.startsWith(prefix))
            .map(([key, value]) => [key.slice(prefix.length), value]),
        );
      const ops = {
        get: (keys) => local.get(keys == null ? null : prefixKeys(keys)).then(unprefix),
        set: (items) => local.set(prefixKeys(items)),
        remove: (keys) => local.remove(prefixKeys(keys)),
        clear: () =>
          local
            .get(null)
            .then((all) => local.remove(Object.keys(all).filter((key) => key.startsWith(prefix)))),
      };
      // storage.session must start empty per browser run, like Chrome's.
      const ready = name === "session" && isBackground ? ops.clear() : Promise.resolve();
      const area = { setAccessLevel: callbackable(() => Promise.resolve()) };
      for (const [op, fn] of Object.entries(ops)) {
        area[op] = callbackable((...args) => ready.then(() => fn(...args)));
      }
      return area;
    };

    const nativeOnChanged = storage.onChanged;
    const forwarders = new Map();
    const splitByArea = (changes) => {
      const byArea = {};
      for (const [key, change] of Object.entries(changes)) {
        const name = areaOf(key);
        const bare = name === "local" ? key : key.slice(name.length + 1);
        (byArea[name] ??= {})[bare] = change;
      }
      return Object.entries(byArea);
    };
    define(storage, "onChanged", {
      addListener(listener) {
        const forward = (changes, areaName) => {
          if (areaName !== "local") return listener(changes, areaName);
          for (const [name, part] of splitByArea(changes)) listener(part, name);
        };
        forwarders.set(listener, forward);
        nativeOnChanged.addListener(forward);
      },
      removeListener(listener) {
        nativeOnChanged.removeListener(forwarders.get(listener));
        forwarders.delete(listener);
      },
      hasListener: (listener) => forwarders.has(listener),
    });
    for (const name of shimmedAreas) define(storage, name, makeArea(name));
  }

  const noopEvent = () => ({ addListener() {}, removeListener() {}, hasListener: () => false });
  const stubMember = (name) =>
    /^on[A-Z]/.test(name)
      ? noopEvent()
      : /^[A-Z_]+$/.test(name)
        ? undefined
        : callbackable(() => Promise.resolve([]));
  const withStubs = (real, overrides = {}) => {
    const stubs = new Map(Object.entries(overrides));
    return new Proxy(real ?? {}, {
      get(target, name) {
        if (typeof name !== "string" || name in target) {
          const value = Reflect.get(target, name);
          return typeof value === "function" ? value.bind(target) : value;
        }
        if (!stubs.has(name)) stubs.set(name, stubMember(name));
        return stubs.get(name);
      },
    });
  };

  // Link hints enumerate frames via webNavigation.getAllFrames, which Electron lacks.
  // Every frame messages the background page on init, so track senders instead.
  const framesByTab = new Map();
  if (isBackground) {
    chrome.runtime?.onMessage?.addListener((_, sender) => {
      const tabId = sender.tab?.id;
      if (tabId == null) return;
      if (!framesByTab.has(tabId)) framesByTab.set(tabId, new Set([0]));
      framesByTab.get(tabId).add(sender.frameId ?? 0);
    });
  }
  const overrides = {
    webNavigation: {
      getAllFrames: callbackable(({ tabId }) =>
        Promise.resolve([...(framesByTab.get(tabId) ?? [0])].map((frameId) => ({ frameId }))),
      ),
    },
  };

  for (const name of [
    "tabs",
    "windows",
    "history",
    "bookmarks",
    "sessions",
    "notifications",
    "search",
    "webNavigation",
    "action",
  ]) {
    define(chrome, name, withStubs(chrome[name], overrides[name]));
  }
})();
