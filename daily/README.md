# HTM daily drop

One folder per day: `daily/YYYY-MM-DD/`
- `*.html` — the four day videos (Briefing, Vault, Expansion, Glitch), 59 s each
- `htm-day-NN-posts-YYYYMMDD.md` — captions + voice scripts
- `READY` — written last; only pick up a folder once this file exists

`tools/htm_render_mp4.py` renders each .html to a 1080×1920 MP4.
MP4s are not stored here (too large for git); Choose_bot renders them on the server.
