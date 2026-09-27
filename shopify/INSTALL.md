# Shopify install — Choose Your Destiny

Four files. Two you paste into Shopify, two you open in a browser to check them first.

| File | What it is |
| --- | --- |
| `cyd-intake.liquid` | **Paste into Shopify.** Client intake + consultation agreement. |
| `cyd-bookings-2027.liquid` | **Paste into Shopify.** 2027 booking calendar. |
| `preview-client-intake.html` | Double-click to open in a browser. Same thing, just viewable. |
| `preview-book-2027.html` | Double-click to open in a browser. Same thing, just viewable. |

Open the two preview files first. They are ordinary web pages — double-click and they open in Chrome or Safari with no internet needed. If they look right, the Liquid files will look the same on your site.

## Installing

Do this twice, once per page.

1. Shopify admin → **Online Store → Pages → Add page**.
2. Title the first one **Client Intake**, the second **Book 2027**. Note the handle Shopify gives each (shown under the title, e.g. `client-intake`).
3. In the page editor, open the theme customizer for that page → **Add section → Custom Liquid**.
4. Open the matching `.liquid` file in TextEdit or Notepad, select all, copy, and paste the whole thing into the Custom Liquid box.
5. Save, then view the page.

**The handles must match.** The two pages link to each other using `/pages/client-intake` and `/pages/book-2027`. If Shopify gives you different handles, either rename the pages to match, or edit the `INTAKE_URL` and `BOOKING_URL` lines near the top of the `<script>` in each file.

## Before you go live

**Availability is currently wide open.** Every day of the week, all three bands: regular hours 8am–3pm, limited hours 4pm–9pm, and after hours 10pm–7am, Eastern. Limited and after-hours slots are labelled in the picker as availability and fees may vary. When you want to narrow it, open `preview-book-2027.html` → **Advisor access → Availability**, set your hours, and tell me — I'll bake the new defaults into the Liquid file. Settings entered in the preview stay on that device and do not travel to Shopify on their own.

**Decide how submissions reach you.** Right now, when someone finishes either form, their mail app opens automatically with a prefilled message to `contact@chooseyourdestiny.us`, and a manual **Email my request** button stays on the confirmation screen as a backup. That is your notification. It works with no backend, but it still depends on the client pressing send in their own mail app — some will not, and some devices have no mail app configured.

The reliable version needs somewhere to receive the data. Find the `SUBMIT_ENDPOINT` line near the top of the `<script>` in each file and put a URL there that accepts a JSON POST — a Shopify app, a Zapier or Make webhook, a Google Apps Script, or a small serverless function all work. Most of those can text or email you the moment a booking lands. Submission then happens automatically, and if it ever fails the email path comes back on its own as a fallback.

Until you set that up, treat the Shopify pages as a way for clients to read, sign, and choose a time — not as a reliable inbox. Check them yourself rather than assuming silence means no bookings.

**Tracking who needs a reply.** In the offline build's Advisor panel every booking starts marked **Needs reply**, and the header shows a running count of how many are still awaiting you. Each row has an **Email** button that opens a prefilled confirmation to that client with their date and time filled in. Click **Needs reply** once you have responded and it flips to **Confirmed**. The state is saved and included in the CSV export as a `replied` column.

**Get the agreement reviewed.** See the legal notes in `../ui_kits/client-intake/README.md`. The entity structure section matters: the agreement still describes a sole proprietorship and names North Carolina courts, and your business is a tribal government entity that is also a nonprofit.

## What these pages do and do not store

Nothing is saved to your site or sent anywhere except to you. There is deliberately no client database in the Shopify version — a visitor's browser must never hold other clients' names, health notes, or signatures. The versions with a records database are the offline ones in `../ui_kits/client-intake/`, meant for your own tablet.

## Notes

- Everything is scoped to `#cyd-intake` and `#cyd-book`. There are no unscoped rules at all, so nothing leaks into or gets overwritten by your theme — your page background and layout stay exactly as they are.
- No external fonts, scripts, or stylesheets. The logo is embedded directly in the file.
- Each file is around 270 KB, most of which is the embedded logo. If page speed matters, upload `wordmark.png` to Shopify Files and swap the long `src="data:image/png;base64,…"` for the CDN URL — that cuts roughly 220 KB.
- The whole thing is wrapped in `{% raw %}` so Shopify's template engine leaves the JavaScript alone.
