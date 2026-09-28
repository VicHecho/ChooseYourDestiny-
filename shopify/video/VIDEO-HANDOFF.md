# Video handoff: Claude → Hermes (@Choose_BOT)

From 2026-09-28 Hermes owns rendering, uploading and posting videos. Claude still designs and edits the video files themselves.

## Split
- **Claude:** writes and edits video HTML files in `shopify/video/` (scenes, copy, timing, look).
- **Hermes:** renders them to MP4, uploads to Shopify Files, attaches to blog posts, pushes to social after Vic approves.
- **Vic:** approves before anything goes public.

## Files
- `shopify/video/HTM Trailer.html`: Hack The Matrix 2026 trailer. 90 s, vertical 1080×1920. Self-contained (engine code and the 7 wallpapers are built in). Only needs internet for React and Google Fonts.
- `shopify/video/render.mjs.txt`: turns any video HTML here into an MP4. Copy it to `render.mjs` on the server before running (it's stored as .txt so the design system doesn't try to bundle it).
- Do NOT edit `htm-trailer.jsx` / `animations-v3.jsx` expecting the trailer to change. The trailer HTML has its own copy of that code.

## Render an MP4 (one-time setup, then one command)
```
cd ~/ChooseYourDestiny && git pull -q
command -v ffmpeg || sudo apt-get install -y ffmpeg
[ -d node_modules/playwright ] || (npm i -D playwright && npx playwright install --with-deps chromium)
cp shopify/video/render.mjs.txt /tmp/render.mjs && node /tmp/render.mjs "shopify/video/HTM Trailer.html" /tmp/hack-the-matrix-2026-trailer.mp4 30
```
Takes several minutes (2,700 frames). Check the result: `ffprobe /tmp/hack-the-matrix-2026-trailer.mp4` should show 1080x1920, ~90 s. Send Vic a 5-second clip or a frame grab in Discord before posting (`ffmpeg -ss 16 -i … -frames:v 1 /tmp/check.jpg`: the title wallpaper should be visible at 16 s).

Never commit MP4s to GitHub (too large). Keep them in /tmp or ~/videos.

## Upload to Shopify Files
Credentials are in `~/.hermes/.env` (SHOPIFY_STORE + token). Admin GraphQL:
1. `stagedUploadsCreate(input:[{resource: VIDEO, filename:"hack-the-matrix-2026-trailer.mp4", mimeType:"video/mp4", fileSize:"<bytes>", httpMethod: POST}])`
2. POST the file to the returned `url` with the returned `parameters` as form fields (file field last).
3. `fileCreate(files:[{originalSource:"<resourceUrl>", contentType: VIDEO, alt:"Hack The Matrix 2026 trailer"}])`
4. Poll `node(id:){... on Video { fileStatus sources { url mimeType } }}` until READY. Use the mp4 source URL below.

## Finish the blog post (waiting on the MP4)
- Blog: Hack The Matrix, `gid://shopify/Blog/105157820591`
- Article: `gid://shopify/Article/599144300719`, handle `hack-the-matrix-2026-trailer`, currently **unpublished**.
- In its body, replace the two placeholder comments:
  - `<!-- VIDEO: replace this line with the MP4 once uploaded -->` → `<video controls playsinline preload="metadata" poster="https://cdn.shopify.com/s/files/1/0664/8178/2959/files/cyd-htm-title.png" style="width:100%;max-width:420px;display:block;margin:0 auto"><source src="<MP4_URL>" type="video/mp4"></video>`
  - `<!-- DOWNLOAD: replace with MP4 download link -->` → `<a href="<MP4_URL>" download>Download the trailer (MP4)</a>`
- Use `articleUpdate`, keep everything else in the body. Publish (`isPublished: true`) only after Vic says yes.

## Social
Follow the Platform posts rules in SOUL.md. YouTube: title "Hack The Matrix 2026 · Trailer", description = the Facebook text. Short-form (Reels/TikTok/Shorts) uses the same MP4. Facebook is still blocked on phone verification. Skip it until Vic says it's connected.

## Brand look (read before touching any video file)
Claude designs videos. Hermes may only make **small edits** (a date, a price, a word of copy, swapping a wallpaper) and must follow these rules. Anything bigger (new scenes, new layout, new motion, new colors, new fonts) goes to Claude.

**Two looks. Don't mix them in one video.**
- **Hack The Matrix** (class, codes, Dayplanner, trailer): black `#0a0a0a`, code green `#39d353`, mint `#c8f7d2` for secondary text, white `#ffffff`. Fonts: Inter 800–900 in capitals with wide letter-spacing for headlines, Inter 500–600 for body, Cormorant Garamond italic for quotes only.
- **Choose Your Destiny main brand** (sessions, readings, subliminals, general posts): black `#0a0a0a` and white, gold `#f0c93e` as the accent (light gold `#ffe774`, deep gold `#c9a11f`), indigo `#2c1fa8` as a second accent, used sparingly. Fonts: Inter for text, Cormorant Garamond for mystical/quote lines. Creepster only for rare spooky display headings, never for body.

**Always**
- Stark contrast: light text on black, or black on white. No low-contrast grey text on photos. Put a dark gradient behind any text that sits on a wallpaper.
- Square corners, solid 2–4 px borders. No rounded pill buttons, drop-shadow glows or rainbow gradients.
- Use the real logo files from `assets/` (`wordmark-white.png`, `wordmark-black.png`, `logo-mark.png`). Never retype the "Choose Your Destiny" wordmark in a font.
- Use only artwork already in the repo (book wallpapers in `shopify/wallpapers/`, `assets/`). No stock photos, no AI images, no emoji.
- Keep Vic's copy word for word. Service names are exact: "Hack The Matrix Class (I will teach you how to effectively use -The Metaphysical Dayplanner-)".
- Prices and dates must match the site: sessions $60/hr (was $100) through January 1, 2027; Hack The Matrix course $33; Deluxe Edition book $49.99. Check the live product before posting a price.
- Vertical 1080×1920, 30 fps. Text stays inside the safe area: 120 px from top and 260 px from bottom (Reels/TikTok UI covers those).
- Headlines at least 64 px, body at least 40 px at 1080 wide.

**Never**
- Change the palette, fonts or motion style of an existing video.
- Edit the engine code in a video HTML (the `animations-v3.jsx` / `tweaks-panel.jsx` blocks).
- Post anything without sending Vic a frame and getting a yes.

After any edit, render a frame from each scene you changed and send it to Vic with a one-line note of what changed.

## New videos
When Vic wants a new video, Claude builds it as `shopify/video/<Name>.html` and pushes it through Vic. Hermes renders it with the same command, changing the file name. Every video must be vertical 1080×1920 unless Vic says otherwise.
