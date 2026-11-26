# Website

## Purpose
`site/dist/`: the guide as a web page (hero, 24 sections, "Set it up"), built from
`guide/src/guide.html` and served by Vercel as static files. Spec: `docs/specs/landing-page.md`.

## Key dirs & files
- `site/src/index.html` — template: head and preview tags, navigation shell, hero buttons,
  "Set it up", footer; markers `<!-- hero -->`, `<!-- nav -->`, `<!-- sections -->`
- `site/src/web.css` — screen layout and look; `@import`s `tokens.css`
- `site/src/site.js` — reveal, current section, progress, phone menu, copy buttons; `#check` test hook
- `site/build.sh` — assembles the guide, splits it with awk, splices it into the template, copies
  assets + the committed PDF, screenshots `og.png`
- `site/dist/` — the built site (committed; Vercel's root directory)

## Conventions
- Section names come from each page's header strip; anchors from the names (`#10-brainstorm-plan`).
- Breakpoints: 640px (one-column cards and flows), 1000px (side rail vs. top bar + menu).
- Hiding for animation only under `.js` and `prefers-reduced-motion: no-preference`.
- Copy blocks aligned in columns (`.cols`, set by `site.js`) scroll sideways instead of wrapping.
- One constant action, **Get the PDF**: top of the rail (desktop), in the bar (phone). Outside
  links and the PDF get `target="_blank"` from `site.js`; without JS they open in the same tab.
- The phone bar's section name and ☰ are both `[data-menu]` buttons that open the list.

## Gotchas
- Headless Chrome won't make a window narrower than 500px: the width tests load the site in an
  iframe of the exact width.
- `--blink-settings=scriptEnabled=false` breaks `--screenshot`; tall windows fail too.
- CSS can't select ids that start with a digit (`#09-the-spine`); use `[id="…"]`.
- `og.png` is byte-identical across builds, so the freshness test compares it.

## Run & test
- Run: `guide/build.sh && site/build.sh`, then `open site/dist/index.html`
- Test: `tests/test_site.sh`
