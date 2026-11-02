// IxD Lab · optional AI feedback and tutor with the visitor's own API key: Claude (Anthropic),
// ChatGPT (OpenAI) or Gemini (Google). The key and the request stay in the browser: they go
// straight to the provider, never to the Shiny server, and the key input has no id so Shiny
// never binds it.
(function () {
  const PROVIDER_STORE = "ixd-lab-ai-provider";
  const keyStore = (p) => "ixd-lab-key-" + p;

  const PROVIDERS = {
    claude: {
      label: "Claude",
      model: "claude-opus-5-5",
      valid: (k) => k.startsWith("sk-ant-"),
      async ask(key, model, system, messages) {
        const res = await fetch("https://api.anthropic.com/v1/messages", {
          method: "POST",
          headers: {
            "content-type": "application/json",
            "x-api-key": key,
            "anthropic-version": "2026-10-21",
            "anthropic-beta": "server-side-fallback-2026-07-01",
            "anthropic-dangerous-direct-browser-access": "true"
          },
          body: JSON.stringify({
            model: model,
            max_tokens: 16000,
            fallbacks: "default",
            output_config: { effort: "medium" },
            system: system,
            messages: messages
          })
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) return { status: res.status, detail: data.error && data.error.message };
        if (data.stop_reason === "refusal") return { refusal: true };
        return { text: (data.content || []).filter((b) => b.type === "text").map((b) => b.text).join("\n") };
      }
    },
    openai: {
      label: "ChatGPT",
      model: "gpt-5",
      valid: (k) => k.startsWith("sk-"),
      async ask(key, model, system, messages) {
        const res = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: { "content-type": "application/json", "authorization": "Bearer " + key },
          body: JSON.stringify({ model: model, messages: [{ role: "system", content: system }].concat(messages) })
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) return { status: res.status, detail: data.error && data.error.message };
        const choice = (data.choices || [])[0] || {};
        if (choice.message && choice.message.refusal) return { refusal: true };
        return { text: (choice.message && choice.message.content) || "" };
      }
    },
    gemini: {
      label: "Gemini",
      model: "gemini-flash-latest",
      valid: (k) => k.startsWith("AIza"),
      async ask(key, model, system, messages) {
        const url = "https://generativelanguage.googleapis.com/v1beta/models/" + encodeURIComponent(model) + ":generateContent";
        const res = await fetch(url, {
          method: "POST",
          headers: { "content-type": "application/json", "x-goog-api-key": key },
          body: JSON.stringify({
            systemInstruction: { parts: [{ text: system }] },
            contents: messages.map((m) => ({ role: m.role === "assistant" ? "model" : "user", parts: [{ text: m.content }] }))
          })
        });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) {
          // Gemini reports a bad key as 400 INVALID_ARGUMENT with reason API_KEY_INVALID.
          const msg = data.error && data.error.message;
          return { status: /api key/i.test(msg || "") ? 401 : res.status, detail: msg };
        }
        const cand = (data.candidates || [])[0];
        if (!cand) return data.promptFeedback && data.promptFeedback.blockReason ? { refusal: true } : { text: "" };
        if (cand.finishReason === "SAFETY") return { refusal: true };
        return { text: ((cand.content && cand.content.parts) || []).map((p) => p.text || "").join("") };
      }
    }
  };

  function read(store) {
    try { return sessionStorage.getItem(store) || localStorage.getItem(store) || ""; } catch (e) { return ""; }
  }
  function write(store, value, remember) {
    try {
      sessionStorage.removeItem(store);
      localStorage.removeItem(store);
      if (value) (remember ? localStorage : sessionStorage).setItem(store, value);
    } catch (e) { /* storage blocked: the value is simply not kept */ }
  }

  // Keys saved by IxD Lab 0.1 (Claude only) keep working.
  (function migrate() {
    try {
      const old = localStorage.getItem("ixd-lab-anthropic-key") || sessionStorage.getItem("ixd-lab-anthropic-key");
      if (old && !read(keyStore("claude"))) write(keyStore("claude"), old, Boolean(localStorage.getItem("ixd-lab-anthropic-key")));
      localStorage.removeItem("ixd-lab-anthropic-key");
      sessionStorage.removeItem("ixd-lab-anthropic-key");
    } catch (e) {}
  })();

  function provider() {
    const p = read(PROVIDER_STORE);
    return PROVIDERS[p] ? p : "claude";
  }
  function getKey(p) { return read(keyStore(p || provider())); }
  function getModel(p) { return read("ixd-lab-model-" + (p || provider())) || PROVIDERS[p || provider()].model; }

  function el(sel) { return document.querySelector(sel); }

  function refreshStatus() {
    const p = provider();
    const on = Boolean(getKey(p));
    document.body.classList.toggle("ai-on", on);
    document.querySelectorAll("[data-ixd-ai-provider-name]").forEach((n) => { n.textContent = PROVIDERS[p].label; });
    try { Shiny.setInputValue("ai_provider", on ? PROVIDERS[p].label : ""); } catch (e) { /* Shiny not connected yet */ }
  }

  // Shows the chosen provider's key hint, link and saved state in the settings dialog.
  function showProvider(p) {
    document.querySelectorAll("[data-ixd-ai-pick]").forEach((r) => { r.checked = r.value === p; });
    document.querySelectorAll("[data-ixd-ai-for]").forEach((n) => { n.hidden = n.dataset.ixdAiFor !== p; });
    const input = el("[data-ixd-ai-key]");
    input.value = "";
    input.placeholder = getKey(p) ? "••••••••  (" + input.dataset.saved + ")" : input.dataset["ph" + p];
    el("[data-ixd-ai-model]").value = read("ixd-lab-model-" + p);
    el("[data-ixd-ai-model]").placeholder = PROVIDERS[p].model;
    el("[data-ixd-ai-message]").textContent = "";
  }

  function modal() {
    return bootstrap.Modal.getOrCreateInstance(document.getElementById("ai-settings"));
  }

  function chosen() {
    const r = el("[data-ixd-ai-pick]:checked");
    return r ? r.value : provider();
  }

  function save() {
    const p = chosen();
    const input = el("[data-ixd-ai-key]");
    const message = el("[data-ixd-ai-message]");
    const remember = el("[data-ixd-ai-remember]").checked;
    const key = input.value.trim();
    if (!key && !getKey(p)) {
      message.textContent = message.dataset.missing;
      input.focus();
      return;
    }
    if (key && !PROVIDERS[p].valid(key)) {
      message.textContent = message.dataset["invalid" + p];
      input.focus();
      return;
    }
    if (key) write(keyStore(p), key, remember);
    write("ixd-lab-model-" + p, el("[data-ixd-ai-model]").value.trim(), remember);
    write(PROVIDER_STORE, p, true);
    input.value = "";
    refreshStatus();
    modal().hide();
  }

  function clear() {
    const p = chosen();
    write(keyStore(p), "", false);
    write("ixd-lab-model-" + p, "", false);
    showProvider(p);
    refreshStatus();
  }

  function reply(target, value) {
    Shiny.setInputValue(target, Object.assign({ nonce: Date.now() }, value), { priority: "event" });
  }

  async function ask(msg) {
    const p = provider();
    const key = getKey(p);
    if (!key) {
      reply(msg.target, { error: "nokey" });
      modal().show();
      return;
    }
    try {
      const r = await PROVIDERS[p].ask(key, getModel(p), msg.system, msg.messages);
      const label = PROVIDERS[p].label;
      if (r.refusal) return reply(msg.target, { error: "refusal", provider: label });
      if (r.status) {
        const code = r.status === 401 || r.status === 403 ? "auth" : r.status === 429 || r.status === 529 ? "rate" : "api";
        return reply(msg.target, { error: code, provider: label, detail: r.detail || String(r.status) });
      }
      const text = (r.text || "").trim();
      reply(msg.target, text ? { text: text, provider: label } : { error: "api", provider: label, detail: "empty response" });
    } catch (e) {
      reply(msg.target, { error: "network", detail: String(e) });
    }
  }

  window.ixdAI = { save: save, clear: clear, pick: showProvider };
  document.addEventListener("DOMContentLoaded", function () {
    refreshStatus();
    const dialog = document.getElementById("ai-settings");
    if (dialog) dialog.addEventListener("show.bs.modal", () => showProvider(provider()));
  });
  $(document).on("shiny:connected", function () {
    Shiny.addCustomMessageHandler("ixd-ai-request", ask);
    refreshStatus();
  });
})();
