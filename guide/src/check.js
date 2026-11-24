// Build self-check: build.sh loads the page with #check and reads what this writes.
//   data-pages     number of .page sections
//   data-overflow  pages whose content spills down or sideways ("none" if clean)
//   #fidelity      one line per appendix file: "<path> <base64 of its rendered UTF-8 text>"
if (location.hash === "#check") {
  document.fonts.ready.then(() => {
    const pages = [...document.querySelectorAll(".page")];
    const tooTall = (p) => p.scrollHeight > p.clientHeight + 1;
    const tooWide = (p) => [...p.querySelectorAll("pre")].some((e) => e.scrollWidth > e.clientWidth + 1);
    const bad = pages.map((p, i) => (tooTall(p) || tooWide(p) ? i + 1 : 0)).filter(Boolean);
    document.body.setAttribute("data-pages", pages.length);
    document.body.setAttribute("data-overflow", bad.join(",") || "none");

    const text = {};
    for (const e of document.querySelectorAll("pre.file")) {
      text[e.dataset.file] = (text[e.dataset.file] || "") + e.textContent;
    }
    const b64 = (s) => btoa(Array.from(new TextEncoder().encode(s), (b) => String.fromCharCode(b)).join(""));
    const out = document.createElement("pre");
    out.id = "fidelity";
    out.textContent = Object.entries(text).map(([f, t]) => `${f} ${b64(t)}`).join("\n");
    document.body.appendChild(out);
  });
}
