# Storefront restyle — install

Three files, in order of risk. Duplicate your theme first: **Online Store → Themes → ⋯ → Duplicate**, then work on the copy and publish only when it looks right.

| File in this folder | Where it goes | What you do |
| --- | --- | --- |
| `theme.liquid` | `layout/theme.liquid` | Replace the whole file. Fixes the Meta Pixel. |
| `sections/header.liquid` | `sections/header.liquid` | Replace the whole file. |
| `snippets/cyd-footer-style.liquid` | `snippets/cyd-footer-style.liquid` | New file, plus one line added to `sections/footer.liquid`. |

See the previews first: `preview-header.html` and `preview-footer.html` open in any browser with no internet.

## 1. Pixel fix

Follow `PIXEL-FIX.md`. Pixel `1763779941048884` is already set in the file.

## 2. Header

**⋯ → Edit code → `sections/header.liquid`** → select all → paste in this folder's version → save.

Nothing structural changed. Dawn's cart icon and count, search modal, predictive search, menu drawer, mega menu, dropdowns, customer account, country and language selectors, sticky-header script and JSON-LD are all still the originals. What changed is the CSS and two added settings.

**New in the theme editor** under *Header → Choose Your Destiny styling*:

- **Header bar** — black bar with the white wordmark (default), or paper bar with the black wordmark. This overrides the colour scheme for the header only.
- **Rule under header** — gold (default), matching the text colour, or none.

While you are in there: set the logo to `assets/wordmark-white.png` if you use the black bar, and raise **logo width** to 140–160px. The current 90px is small for a wordmark carrying the sword and lily.

## 3. Footer

Two steps.

**a.** **⋯ → Edit code → Snippets → Add a new snippet**, name it `cyd-footer-style`, and paste in `snippets/cyd-footer-style.liquid`.

**b.** Open `sections/footer.liquid`. At the very top are five lines ending in `| stylesheet_tag }}`. Directly after the last of them, add one line:

```liquid
{% render 'cyd-footer-style' %}
```

Save. That is the whole install.

It is a snippet rather than a rewritten section on purpose: a future Dawn update will not clobber it, and deleting that one line reverts the footer completely.

## Reverting

Every piece is independent and reversible.

- Footer: delete the `{% render %}` line.
- Header: paste back Dawn's original `sections/header.liquid`.
- Everything: delete the duplicated theme. Your published theme was never touched.

## Still not covered

Section layouts — the homepage hero, collection pages, product pages — are their own section files. The colour schemes and type settings in `THEME-RESTYLE.md` carry the brand into those without any code. Do those in the theme editor after the three files above are in.
