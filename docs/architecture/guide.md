# Guide (the PDF)

## Purpose
`guide/think-prove-checkpoint.pdf`: the A4 guide that doubles as the installer (readers hand it
to their agent, which installs from the appendix).

## Key dirs & files
- `guide/src/guide.html` — every page as `<section class="page">`; facts as `{{placeholders}}`;
  appendix markers `<!-- appendix A3: <paths> -->`
- `guide/src/tokens.css` — fonts + colour/font tokens (shared with the website)
- `guide/src/styles.css` — print layout and components; `@import`s tokens
- `guide/src/check.js` — `#check` mode: overflow, page count, appendix text report
- `guide/assemble.sh` — fills facts and page 21 counts, expands the appendix → `guide.gen.html` (gitignored)
- `guide/build.sh` — assembles, prints, self-checks

## Conventions
- Each page: header strip (`.top`, its second span names the page), label, headline with one
  `.hl` mono word, body, footer (`.foot`, page number from a CSS counter).
- Text refers to sections ("see 18 · Tailor or undo"), never page numbers.
- `framework/` is the only source of appendix text.

## Gotchas
- Chrome stamps a creation date into the PDF: two builds of the same source differ in bytes.
- `guide/build.sh` needs an absolute source path when one is given (it becomes a `file://` URL).
- Page 21's commit count can't include the commit about to be made ("as of this build").
- Ligatures are off so the PDF text layer keeps Markdown symbols.

## Run & test
- Run: `guide/build.sh` (exit 0 = no overflow, page count matches, appendix byte-identical)
- Test: `tests/test_guide.sh`
