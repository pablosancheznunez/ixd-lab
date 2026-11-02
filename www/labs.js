// IxD Lab · browser-side helpers: notes saved in this browser, and the timed experiments of the
// Laws of UX lab (Fitts's and Hick's laws), which need millisecond timing in the page.
(function () {
  const lang = () => document.documentElement.lang || "en";
  const noteKey = (id) => "ixd-notes-" + lang() + "-" + id;

  // ---- Notes: every "…-reflection" textarea is kept in localStorage, on this device only.
  function restoreNotes() {
    document.querySelectorAll("textarea[id$='-reflection']").forEach((el) => {
      let saved = "";
      try { saved = localStorage.getItem(noteKey(el.id)) || ""; } catch (e) {}
      if (saved && !el.value) $(el).val(saved).trigger("change");
    });
  }
  $(document).on("input change", "textarea[id$='-reflection']", function () {
    try {
      if (this.value) localStorage.setItem(noteKey(this.id), this.value);
      else localStorage.removeItem(noteKey(this.id));
    } catch (e) {}
  });
  window.ixdClearNotes = function () {
    try {
      Object.keys(localStorage).filter((k) => k.startsWith("ixd-notes-")).forEach((k) => localStorage.removeItem(k));
    } catch (e) {}
    document.querySelectorAll("textarea[id$='-reflection']").forEach((el) => $(el).val("").trigger("change"));
  };
  $(document).on("shiny:sessioninitialized", () => setTimeout(restoreNotes, 300));

  // ---- Fitts's law: click targets of different sizes and distances as fast as you can.
  const FITTS_TRIALS = 18;
  function fittsStart(area) {
    const input = area.dataset.fitts;
    const box = area.querySelector(".exp-stage");
    const status = area.querySelector(".exp-status");
    const sizes = [20, 40, 80];
    const data = { d: [], w: [], t: [], misses: 0 };
    let last = { x: box.clientWidth / 2, y: box.clientHeight / 2 };
    let shownAt = 0;
    let n = 0;
    box.innerHTML = "";
    box.onclick = (e) => { if (e.target === box) data.misses++; };
    function next() {
      if (n >= FITTS_TRIALS) {
        box.innerHTML = "<p class='exp-done'>" + area.dataset.done + "</p>";
        box.onclick = null;
        Shiny.setInputValue(input, Object.assign({ nonce: Date.now() }, data), { priority: "event" });
        return;
      }
      const w = sizes[Math.floor(Math.random() * sizes.length)];
      let x, y, d;
      do {
        x = w / 2 + Math.random() * (box.clientWidth - w);
        y = w / 2 + Math.random() * (box.clientHeight - w);
        d = Math.hypot(x - last.x, y - last.y);
      } while (d < 60);
      const t = document.createElement("button");
      t.type = "button";
      t.className = "fitts-target";
      t.setAttribute("aria-label", area.dataset.target);
      Object.assign(t.style, { width: w + "px", height: w + "px", left: (x - w / 2) + "px", top: (y - w / 2) + "px" });
      t.onclick = (e) => {
        e.stopPropagation();
        data.d.push(Math.round(d)); data.w.push(w); data.t.push(Math.round(performance.now() - shownAt));
        last = { x: x, y: y };
        t.remove();
        n++;
        status.textContent = n + " / " + FITTS_TRIALS;
        next();
      };
      box.appendChild(t);
      shownAt = performance.now();
    }
    status.textContent = "0 / " + FITTS_TRIALS;
    next();
  }

  // ---- Hick's law: find a word among 2, 4, 8 or 16 choices.
  const HICK_WORDS = {
    en: ["Madrid", "Lisbon", "Paris", "Berlin", "Rome", "Vienna", "Prague", "Dublin", "Oslo", "Athens", "Warsaw", "Brussels", "Helsinki", "Sofia", "Riga", "Bern"],
    es: ["Madrid", "Lisboa", "París", "Berlín", "Roma", "Viena", "Praga", "Dublín", "Oslo", "Atenas", "Varsovia", "Bruselas", "Helsinki", "Sofía", "Riga", "Berna"]
  };
  function shuffle(a) { for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; }
  function hickStart(area) {
    const input = area.dataset.hick;
    const box = area.querySelector(".exp-stage");
    const status = area.querySelector(".exp-status");
    const words = HICK_WORDS[lang()] || HICK_WORDS.en;
    const plan = shuffle([2, 4, 8, 16, 2, 4, 8, 16, 2, 4, 8, 16, 2, 4, 8, 16]);
    const data = { n: [], t: [], errors: 0 };
    let i = 0;
    function next() {
      if (i >= plan.length) {
        box.innerHTML = "<p class='exp-done'>" + area.dataset.done + "</p>";
        Shiny.setInputValue(input, Object.assign({ nonce: Date.now() }, data), { priority: "event" });
        return;
      }
      const options = shuffle(words.slice()).slice(0, plan[i]);
      const goal = options[Math.floor(Math.random() * options.length)];
      box.innerHTML = "<p class='hick-goal'>" + area.dataset.find + " <strong>" + goal + "</strong></p><div class='hick-grid'></div>";
      const grid = box.querySelector(".hick-grid");
      const shownAt = performance.now();
      options.forEach((w) => {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "btn btn-outline-secondary btn-sm";
        b.textContent = w;
        b.onclick = () => {
          if (w !== goal) { data.errors++; b.classList.add("hick-wrong"); return; }
          data.n.push(plan[i]); data.t.push(Math.round(performance.now() - shownAt));
          i++;
          status.textContent = i + " / " + plan.length;
          next();
        };
        grid.appendChild(b);
      });
    }
    status.textContent = "0 / " + plan.length;
    next();
  }

  $(document).on("click", "[data-exp-start]", function () {
    const area = this.closest("[data-fitts], [data-hick]");
    if (area.dataset.fitts) fittsStart(area); else hickStart(area);
  });
})();
