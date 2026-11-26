// Site behaviour: sections reveal once, the current section is highlighted, a bar shows reading
// progress, the phone menu opens and closes, and every copy-paste block gets a Copy button.
// Without this script every section is simply visible (web.css hides only under .js).
(() => {
  const root = document.documentElement;
  const sections = [...document.querySelectorAll("main .sec")];
  const links = new Map([...document.querySelectorAll(".rail li a")].map((a) => [a.hash.slice(1), a]));
  const menuButtons = [...document.querySelectorAll("[data-menu]")];
  const barName = document.querySelector(".bar-name");

  // Other sites and the PDF open in a new tab, so the guide stays where the reader left it.
  for (const a of document.querySelectorAll('a[href^="http"], a[href$=".pdf"]')) {
    a.target = "_blank";
    a.rel = "noopener";
  }

  // Copy buttons on every copy-paste block.
  for (const box of document.querySelectorAll(".copy")) {
    const pre = box.querySelector("pre");
    if (!pre) continue;
    // Text aligned in columns (a run of spaces mid-line) keeps its lines and scrolls instead of wrapping.
    if (/\S {2,}\S/.test(pre.textContent)) pre.classList.add("cols");
    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "copy-btn";
    btn.textContent = "Copy";
    btn.addEventListener("click", async () => {
      try { await navigator.clipboard.writeText(pre.textContent); btn.textContent = "Copied"; }
      catch { btn.textContent = "Select to copy"; }
      setTimeout(() => { btn.textContent = "Copy"; }, 1600);
    });
    box.appendChild(btn);
  }

  // Step diagrams: each step's place in the order drives its delay (web.css, --i).
  for (const flow of document.querySelectorAll(".sec .flow")) {
    [...flow.children].forEach((el, i) => el.style.setProperty("--i", i));
  }

  // Sections rise in once, the first time they come into view.
  const reveal = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (e.isIntersecting) { e.target.classList.add("in"); reveal.unobserve(e.target); }
    }
  }, { rootMargin: "0px 0px -10% 0px" });
  sections.forEach((s) => reveal.observe(s));

  // The section crossing the middle of the screen is the current one.
  const hero = document.querySelector(".hero");
  const current = new IntersectionObserver((entries) => {
    for (const e of entries) {
      if (!e.isIntersecting) continue;
      for (const a of links.values()) a.removeAttribute("aria-current");
      const a = links.get(e.target.id);
      if (a) a.setAttribute("aria-current", "true");
      barName.textContent = a ? a.dataset.name : "Contents";
    }
  }, { rootMargin: "-45% 0px -50% 0px" });
  [hero, ...sections].forEach((s) => current.observe(s));

  // Reading progress.
  const fill = document.querySelector(".progress span");
  let queued = false;
  const progress = () => {
    const max = root.scrollHeight - innerHeight;
    fill.style.transform = `scaleX(${max > 0 ? Math.min(1, scrollY / max) : 0})`;
    queued = false;
  };
  addEventListener("scroll", () => { if (!queued) { queued = true; requestAnimationFrame(progress); } }, { passive: true });
  progress();

  // Phone menu: the section name or ☰ opens the section list; choosing a section or Escape closes it.
  const setMenu = (open) => {
    document.body.classList.toggle("menu-open", open);
    for (const b of menuButtons) b.setAttribute("aria-expanded", String(open));
  };
  for (const b of menuButtons) b.addEventListener("click", () => setMenu(!document.body.classList.contains("menu-open")));
  document.querySelector(".rail").addEventListener("click", (e) => { if (e.target.closest("a")) setMenu(false); });
  addEventListener("keydown", (e) => { if (e.key === "Escape") setMenu(false); });
})();

// #check mode, for tests/test_site.sh: reports on <body> whether anything scrolls sideways
// (data-overflow-x: "none", or the first too-wide elements), how many Copy buttons exist,
// how many rows the hero's buttons take, and how many outside/PDF links would replace this page.
if (location.hash === "#check") {
  document.fonts.ready.then(() => {
    const vw = document.documentElement.clientWidth;
    const wide = [...document.body.querySelectorAll("*")]
      .filter((e) => e.getBoundingClientRect().right > vw + 1 ||
        (e.scrollWidth > e.clientWidth + 1 && getComputedStyle(e).overflowX === "visible"))
      .slice(0, 5)
      .map((e) => e.tagName.toLowerCase() + (typeof e.className === "string" && e.className ? "." + e.className : ""));
    const scrolls = document.documentElement.scrollWidth > vw + 1;
    document.body.setAttribute("data-overflow-x", scrolls ? wide.join(" ") || "yes" : "none");
    document.body.setAttribute("data-copy-buttons", document.querySelectorAll(".copy-btn").length);
    const tops = new Set([...document.querySelectorAll(".hero .actions > *")].map((e) => e.offsetTop));
    document.body.setAttribute("data-hero-rows", tops.size);
    const sameTab = [...document.querySelectorAll('a[href^="http"], a[href$=".pdf"]')].filter((a) => a.target !== "_blank");
    document.body.setAttribute("data-same-tab-links", sameTab.length);
  });
}
