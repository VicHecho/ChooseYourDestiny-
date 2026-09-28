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

## New videos
When Vic wants a new video, Claude builds it as `shopify/video/<Name>.html` and pushes it through Vic. Hermes renders it with the same command, changing the file name. Every video must be vertical 1080×1920 unless Vic says otherwise.
