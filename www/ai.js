// IxD Lab · optional AI feedback with the visitor's own Anthropic API key.
// The key and the request stay in the browser: they are sent straight to the Claude API,
// never to the Shiny server, and the key input has no id so Shiny never binds it.
(function () {
  const STORE = "ixd-lab-anthropic-key";
  const API_URL = "https://api.anthropic.com/v1/messages";

  function getKey() {
    try { return sessionStorage.getItem(STORE) || localStorage.getItem(STORE) || ""; } catch (e) { return ""; }
  }

  function storeKey(key, remember) {
    try {
      sessionStorage.removeItem(STORE);
      localStorage.removeItem(STORE);
      if (key) (remember ? localStorage : sessionStorage).setItem(STORE, key);
    } catch (e) { /* storage blocked: the key is simply not kept */ }
  }

  function refreshStatus() {
    document.body.classList.toggle("ai-on", Boolean(getKey()));
  }

  function modal() {
    return bootstrap.Modal.getOrCreateInstance(document.getElementById("ai-settings"));
  }

  function save() {
    const input = document.querySelector("[data-ixd-ai-key]");
    const remember = document.querySelector("[data-ixd-ai-remember]");
    const message = document.querySelector("[data-ixd-ai-message]");
    const key = input.value.trim();
    if (!key.startsWith("sk-ant-")) {
      message.textContent = message.dataset.invalid;
      input.focus();
      return;
    }
    storeKey(key, remember.checked);
    input.value = "";
    message.textContent = "";
    refreshStatus();
    modal().hide();
  }

  function clear() {
    storeKey("", false);
    document.querySelector("[data-ixd-ai-key]").value = "";
    refreshStatus();
  }

  function reply(target, value) {
    Shiny.setInputValue(target, Object.assign({ nonce: Date.now() }, value), { priority: "event" });
  }

  async function ask(msg) {
    const key = getKey();
    if (!key) {
      reply(msg.target, { error: "nokey" });
      modal().show();
      return;
    }
    try {
      const res = await fetch(API_URL, {
        method: "POST",
        headers: {
          "content-type": "application/json",
          "x-api-key": key,
          "anthropic-version": "2026-10-21",
          "anthropic-beta": "server-side-fallback-2026-07-01",
          "anthropic-dangerous-direct-browser-access": "true"
        },
        body: JSON.stringify({
          model: "claude-opus-5-5",
          max_tokens: 16000,
          fallbacks: "default",
          output_config: { effort: "medium" },
          system: msg.system,
          messages: [{ role: "user", content: msg.prompt }]
        })
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        const code = res.status === 401 || res.status === 403 ? "auth" : res.status === 429 || res.status === 529 ? "rate" : "api";
        reply(msg.target, { error: code, detail: (data.error && data.error.message) || String(res.status) });
        return;
      }
      if (data.stop_reason === "refusal") {
        reply(msg.target, { error: "refusal" });
        return;
      }
      const text = (data.content || []).filter((b) => b.type === "text").map((b) => b.text).join("\n").trim();
      reply(msg.target, text ? { text: text } : { error: "api", detail: "empty response" });
    } catch (e) {
      reply(msg.target, { error: "network", detail: String(e) });
    }
  }

  window.ixdAI = { save: save, clear: clear };
  document.addEventListener("DOMContentLoaded", refreshStatus);
  $(document).on("shiny:connected", function () {
    Shiny.addCustomMessageHandler("ixd-ai-request", ask);
    refreshStatus();
  });
})();
