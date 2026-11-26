# Landing page (the guide as a website)

## Goal
Let people open one link (for example from LinkedIn, often on a phone) and read the whole guide
as a web page: a hero, then sections 00–21 with smooth navigation and animations. It is built from
the **same source** as the PDF, so the two can never say different things. Project facts
(version, date, links) live in **one file** and reach the PDF, the site and the README from there.

## Behavior
**One source for facts: `project.json`** (repo root):
```json
{ "version": "1.0", "released": "November 2026",
  "repo": "https://github.com/shajiyev/think-prove-checkpoint",
  "linkedin": "https://www.linkedin.com/in/sabir-hajiyev-9948a9364/",
  "site": "https://think-prove-checkpoint.vercel.app" }
```
- `guide/assemble.sh` fills `{{version}}`, `{{released}}`, `{{repo}}`, `{{linkedin}}`, `{{site}}`
  the way it already fills page 21's counts. `guide.html` holds placeholders, not typed values.
- `{{repo_display}}` is derived: `repo` without `https://` (the visible link text).
- `{{latest}}` / `{{latest_display}}`: the site, or the repo while `site` is empty. The PDF's end page
  says "Latest version: <site> · Files: <repo>"; A1 (for agents) keeps the repo, where the files are.
- `assemble.sh` fails, naming them, on any `{{placeholder}}` it couldn't fill, and on a key missing
  from `project.json`.
- The README is shown as written by GitHub, so it is not generated; it gets a version line
  (`Version 1.0 · November 2026`) and a test checks that its version and links match `project.json`.
- `site` stays empty until Vercel gives the link (see Deploy).

**One source for the look: `guide/src/tokens.css`** — the `@font-face` rules and the `:root`
tokens move here from `styles.css`. `styles.css` (print) and `site/src/web.css` (screen) both
`@import` it; no file but `tokens.css` holds a colour value.

**One source for content: `guide/src/guide.html`.**
```
guide.html + project.json ──assemble.sh──▶ guide.gen.html ──▶ PDF   (guide/build.sh, as today)
guide.html + project.json ──assemble.sh──▶ site/build.sh ──▶ site/dist/  (+ a copy of the PDF)
```

**The page (`site/dist/index.html`):**
- **Hero** from the cover: label, title with the highlight, lead, byline, "Claude forgets. Git
  doesn't." callout. Buttons: **Read the guide** (scrolls) and **GitHub**, on one line on phones
  (360px and up); **Get the PDF** is left to the navigation, which is always on screen. The
  cover's contents table is dropped (the navigation replaces it).
- **24 sections**: 00–21, "Before you go" and "The end" — one `<section>` per guide page. Its name
  comes from the page's header strip (`.top`, second span: `21 · Proof`), its anchor from the name
  (`#01-the-problem`, `#10-brainstorm-plan`, `#the-end`). Each page's `.top` / `.foot` strips and
  page numbers are removed; the content markup is unchanged. The appendix (A1–A8) is not included.
- **Navigation:** desktop — fixed side rail: title, **Get the PDF**, then the section list (which
  scrolls on its own, so the button never leaves the screen); current section highlighted; thin
  reading-progress bar at the top. Phone — slim top bar: the current section's name, **Get the PDF**,
  and ☰; the name or ☰ opens the full list. Every entry scrolls smoothly to its section.
- **New tabs:** links to other sites and the PDF open in a new tab (`site.js`), so the guide stays
  where the reader left it; the PDF opens in the browser's viewer, which has its own download button.
- **Animations:** sections fade and rise in once when scrolled to; step diagrams (three layers,
  the spine, red/green) reveal step by step; the hero fades in on load. `prefers-reduced-motion`
  turns them all off. Without JavaScript everything is visible (hiding is applied only after the
  script adds a `js` class).
- **Layout:** one column, about 760px wide; card grids two columns on desktop, one on phones; wide
  tables and code blocks scroll sideways inside their own box, never the page. No horizontal page
  scroll at 375px.
- **Copy buttons** on every copy-paste block (`.copy`), so the agent prompt in 00 and 17 is one
  click; the prompt is never repeated in web-only text.
- **"Set it up"** after "The end" (also in the navigation): one line pointing to the prompt in
  00 · Start here, **Get the PDF**, **View on GitHub**, and links to `framework/` and `scripts/`.
- **Footer:** version line from `project.json`, MIT licence, repo link. Credits to Karpathy and
  superpowers by Jesse Vincent stay where they are, in "The end".
- **Link preview:** title, description and Open Graph / Twitter tags; `og.png` (1200×630) is a
  headless-Chrome screenshot of the hero. `og:image` / `og:url` use `site` from `project.json`.
- **Wording:** the ~8 places in 00–21 that say "this PDF" stay as they are; a Download button is
  always near, and the PDF is what readers hand their agent.

**Build (`site/build.sh [out_dir]`):** runs `guide/assemble.sh` itself on `guide.html` and on the
page template `site/src/index.html` (never reads a stale file), turns the result into `site/dist/`
(`index.html`, `tokens.css`, `web.css`, `site.js`, `fonts/`, `think-prove-checkpoint.pdf`,
`og.png`). It **copies** the committed PDF rather than rebuilding it; run `guide/build.sh` first.
Built on the author's Mac and **committed**; Vercel never builds. Exits non-zero with a clear
message on: a missing `project.json` key, a `{{placeholder}}` with no value, a page with no
section name, a duplicate section anchor, or a missing PDF.

**Deploy (done 2026-11-26):** Vercel project `think-prove-checkpoint`, linked to the GitHub repo;
root directory `site/dist`, framework none, no build or install command, output `.`. Every push to
`main` redeploys it. Public address: https://think-prove-checkpoint.vercel.app (in `project.json`).

## Out of scope
- Building on Vercel (its shallow clone would also miscount page 21's commits).
- Generating the README, or shared text blocks between README and guide.
- The appendix on the site (the PDF and the GitHub files cover it).
- Dark mode, search, analytics (tokens make dark mode cheap to add later).
- Rewording the guide for the web.
- Any site framework or package manager; plain HTML, CSS, JS, bash.

## Design
Approach 1 of 3 (chosen 2026-11-25): the site is the assembled guide HTML with web CSS + JS
instead of print CSS. Rejected: rendering `guide.html` in the browser (empty page until JS runs,
bad for LinkedIn's preview), and a framework like Astro/Next (adds Node and dependencies for one
page, breaks "Chrome is the only dependency"). `site/dist` is committed like the PDF.

## Key files
<!-- Kept current at every checkpoint: describes the feature AS BUILT. -->
- `project.json` — the facts (version, release date, repo, LinkedIn, site URL)
- `guide/src/tokens.css` — fonts + colour/font tokens shared by print and web
- `guide/assemble.sh` — fills facts and page 21 counts; expands the appendix
- `site/src/index.html` — page template: head, navigation shell, hero buttons, "Set it up",
  footer; markers `<!-- hero -->`, `<!-- nav -->`, `<!-- sections -->` take the guide's content
- `site/src/web.css`, `site/src/site.js` — screen layout and look; behaviour
- `site/build.sh` — builds and checks `site/dist/`
- `site/dist/` — the deployed site (committed)
- `tests/test_site.sh` — site tests

## Gotchas
- Vercel's default protection (Vercel Authentication) asks for a login on the team and per-deployment
  URLs (`…-sabir-projects.vercel.app`); only the production domain is public. Share that one.
- **Page 21's commit count changes with every commit**, so `site/dist` can never match HEAD
  exactly. The build marks that value in the HTML and the up-to-date test ignores it; everything
  else must match. (The PDF already labels it "as of this build".)
- Guide markup has inline mm sizes (e.g. `style="margin-top: 3mm"`); `web.css` must look right with them.
- LinkedIn needs absolute `og:image` / `og:url`, hence `site` in `project.json`; the preview is
  incomplete until it is filled.
- The site needs its own copies of the fonts and PDF in `dist/` (Vercel serves only `site/dist`).
- Chrome stamps a creation date into every PDF, so two builds of the same guide differ in bytes.
  The site copies the committed PDF; tests compare that copy, never a rebuild.
- Facts are read with `sed` (no `jq`): `project.json` stays flat, one `"key": "value"` per line;
  values can't contain `"` or `&` (awk's `gsub` treats `&` specially).
- Headless Chrome won't make a window narrower than 500px: the width tests load the site in an
  iframe of the exact width (`--allow-file-access-from-files` lets the harness read its result).
- `og.png` is byte-identical across builds, so the freshness test compares it.
- Chrome needs absolute `file://` paths: `site/build.sh` makes its output path absolute;
  `guide/build.sh` needs an absolute source path when one is given (its default is absolute).
- Docs updated at a checkpoint change page 21's decision count: rebuild the PDF and the site
  after the docs, before the commit.

## Tests
- `tests/test_site.sh`:
  - Facts: no `{{` left in `guide.gen.html` or `site/dist/index.html`; version line matches
    `project.json` in both; README version + repo link match `project.json`.
  - Structure: exactly 24 guide sections plus "Set it up"; no appendix, `.top` or `.foot`; every
    in-page link targets an existing id; hero buttons point to the guide and the repo; one Copy button
    per copy-paste block.
  - Getting the PDF: the hero has two buttons (Read the guide, GitHub) and no PDF link, on one
    row at 375px and 360px; the phone bar has a PDF button; the
    rail's PDF button comes before the section list; no outside or PDF link opens in the same tab.
  - One look: no colour values outside `tokens.css`.
  - Phone width: 375px (and 1280px), nothing scrolls sideways; measured inside an exact-width
    iframe; the report names the too-wide elements.
  - Preview: `og.png` exists at 1200×630; Open Graph tags present.
  - Up to date: a fresh build equals committed `site/dist` (except the marked commit count);
    `site/dist`'s PDF is byte-identical to `guide/`'s.
  - Failure: fixtures with an unknown placeholder, a missing fact, a nameless page, a duplicate
    section, a missing PDF, and a too-wide element (phone check) each make it fail.
- `tests/test_guide.sh`: the committed PDF must read the same as a fresh build (text layer, commit
  count masked; bytes differ by build date), so a stale PDF can't ship with the site.
- `tests/test_guide.sh` and `tests/test_scripts.sh` still pass; the guide's real build writes its
  PDF to a temp folder (tests never change committed files); page 21 also counts site checks
  (`{{site_checks}}`).
- Hand check (user): open `site/dist/index.html` on desktop; after deploy, on a phone. Read it
  through, use the navigation, copy the prompt, check the LinkedIn preview.

## Last updated
2026-11-25 — Designed (brainstorm): approach 1, one facts file, shared tokens, local build,
committed `site/dist`, Vercel deploy only.
2026-11-25 — Built (L1–L6): as specified, plus — width tests load the site in an exact-width
iframe (headless Chrome's minimum window is 500px); copy blocks aligned in columns scroll instead
of wrapping (`.cols`); code in tables keeps its natural line breaks; `og.png` is reproducible, so
the freshness test compares it. Deploy (L7) pending.
2026-11-25 — After the author's hand check: one constant **Get the PDF** (top of the rail; phone
bar), outside links and the PDF in new tabs, hero buttons on one line on phones; a stale PDF fails
`tests/test_guide.sh`.
2026-11-25 — Hero's **Get the PDF** removed (the navigation always shows it); the phone-only button
shrinking went with it, as two buttons fit at 360px.
2026-11-26 — Deployed (L7): Vercel project `think-prove-checkpoint` (team "Sabir"), production
domain https://think-prove-checkpoint.vercel.app; every live file matched `site/dist` byte for byte.
`site` filled in; the PDF's end page points to it (v1.1.1).
