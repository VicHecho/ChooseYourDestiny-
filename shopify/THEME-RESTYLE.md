# Restyling your Dawn theme to the CYD design

Two ways to do this. **Do it in the theme editor** — it is safer and takes about ten minutes. The JSON route is here only if you prefer editing code directly.

Everything below is reversible. Nothing here touches your product data, orders, or apps.

---

## First: duplicate your theme

**Online Store → Themes → ⋯ → Duplicate.** Work on the copy. Preview it privately, publish only when it looks right. Do not do this on the live theme while customers are shopping.

---

## The colors

**Theme editor → Settings (gear icon) → Colors.** You have five schemes. Change them to these.

| Scheme | Where Dawn uses it | Background | Text | Button | Button label |
| --- | --- | --- | --- | --- | --- |
| `scheme-1` | Default, most sections | `#ffffff` | `#0a0a0a` | `#0a0a0a` | `#ffffff` |
| `scheme-2` | Product & collection cards | `#faf9f7` | `#0a0a0a` | `#0a0a0a` | `#faf9f7` |
| `scheme-3` | Sold-out badge, accents | `#5c3a8f` | `#ffffff` | `#f0c93e` | `#0a0a0a` |
| `scheme-4` | Sale badge, dark sections | `#0a0a0a` | `#ffffff` | `#f0c93e` | `#0a0a0a` |
| `scheme-5` | Accent sections | `#2f6fd1` | `#ffffff` | `#ffffff` | `#2f6fd1` |

Set **secondary button label** to the same value as **text** in every scheme, and **shadow** to `#0a0a0a` throughout.

What changes: your near-black `#121212` becomes the CYD ink `#0a0a0a`, the flat grey `#f3f3f3` becomes the warm paper `#faf9f7`, the navy and royal blue become CYD violet and blue, and dark sections get **gold buttons** — the signature move from the design system.

### Where to use them

- **Homepage hero:** `scheme-4`. Black with gold buttons. This is the brand at full strength.
- **Regular content:** `scheme-1`.
- **One mid-page band:** `scheme-3` violet, to break up a long page.
- Keep `scheme-5` blue for one thing only. Used everywhere it stops reading as an accent.

---

## The type

**Settings → Typography.**

- **Headings:** change from Assistant to **Cormorant Garamond**. Search for it in Shopify's font picker.
- **Body:** leave it on **Assistant**. It is close to the design system's Inter and already loaded, so leaving it costs nothing and saves a request.
- **Heading scale:** raise from 100% to **120%**. Cormorant runs small, and the design system leans on large serif headings.

If Cormorant Garamond is not in your font picker, pick it in the editor rather than hand-editing the font handle in JSON — a wrong handle breaks type across the whole store.

---

## The shapes

You are already almost there. Dawn is set to `0` radius on buttons, inputs, cards, and media, which matches the design system's hard-edged look. Two changes:

**Settings → Buttons:** border thickness `1` → **`2`**. The design system uses heavier borders and it is what makes the buttons feel stamped rather than drawn.

**Settings → Variant pills** and **Badges:** corner radius `40` → **`0`**. These are the only rounded things left in your theme and they fight everything else.

Leave shadows off. The design system uses hard offset shadows, which Dawn's blur-based shadow settings cannot reproduce — a soft grey blur would look wrong next to the rest.

---

## The logo

Your current logo is `choose_fall_25_for_brights.png` at 90px. Two notes:

The filename suggests it is the version made for bright backgrounds. If your header sits on black, you want the white wordmark. `assets/wordmark-white.png` in this project is the cropped transparent version.

90px is small for a wordmark with the sword and lily in it. Try **140–160px** and see how it holds up in the header.

---

## The JSON route

If you would rather edit code: **Themes → ⋯ → Edit code → `config/settings_data.json`**, find the `"color_schemes"` block inside `"current"`, and replace the five scheme objects with the values in the table. Leave `"presets"` alone — that is Dawn's factory default and is what you restore from if something goes wrong.

Change `"type_header_font"` only through the editor, not here.

---

## What this does not cover

Section layouts, the header structure, and the footer are defined in Liquid, not settings. Restyling those means editing `sections/header.liquid` and friends, which needs the actual theme files. The color and type changes above get you most of the way with none of that risk — do them first and see how far it gets you.
