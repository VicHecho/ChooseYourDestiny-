# htm_render_mp4.py — render a Hack The Matrix day-video HTML to MP4 (1080x1920, 30 fps, silent, exact length).
# Seeks the video tool frame by frame through its built-in seek hook and screenshots the stage, so every frame
# is exact (no screen recording). Needs: python3, playwright (chromium), ffmpeg, and internet (the page loads
# React, Babel and three.js from unpkg).
# Usage: python3 htm_render_mp4.py <in.html> <out.mp4> [fps=30]
import sys, os, re, json, time, subprocess, threading, functools, http.server, socketserver
from playwright.sync_api import sync_playwright

src, out = os.path.abspath(sys.argv[1]), os.path.abspath(sys.argv[2])
fps = int(sys.argv[3]) if len(sys.argv) > 3 else 30
html = open(src, encoding='utf-8').read()
scenes = re.findall(r"window\.OM_SCENES = '(.*?)';</script>", html)
dur = round(sum(x['dur'] for x in json.loads(scenes[-1])), 3)   # the last OM_SCENES is the real one
n = int(round(dur * fps))

# serve the file's folder over http (module scripts don't load from file://)
handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=os.path.dirname(src))
handler.log_message = lambda *a: None
srv = socketserver.TCPServer(('127.0.0.1', 0), handler); port = srv.server_address[1]
threading.Thread(target=srv.serve_forever, daemon=True).start()
url = 'http://127.0.0.1:%d/%s' % (port, __import__('urllib.parse').parse.quote(os.path.basename(src)))

ff = subprocess.Popen(['ffmpeg', '-v', 'error', '-y', '-f', 'image2pipe', '-framerate', str(fps), '-c:v', 'mjpeg', '-i', '-',
                       '-vf', 'scale=1080:1920:flags=lanczos,format=yuv420p', '-c:v', 'libx264', '-preset', 'medium',
                       '-crf', '18', '-movflags', '+faststart', '-r', str(fps), out], stdin=subprocess.PIPE)
errs, t0 = [], time.time()
with sync_playwright() as p:
    b = p.chromium.launch(args=['--use-gl=swiftshader', '--enable-webgl', '--ignore-gpu-blocklist'])
    pg = b.new_page(viewport={'width': 1300, 'height': 2300}, device_scale_factor=1)
    pg.on('pageerror', lambda e: errs.append(str(e)[:200]))
    pg.goto(url); pg.wait_for_timeout(10000)          # let React, Babel, fonts and the 3D book load
    root = pg.locator('[data-om-exportable-video-with-duration-secs]').first
    for i in range(n):
        pg.evaluate("""t => new Promise(r => { document.querySelectorAll('[data-om-sync-seek]').forEach(el =>
            el.dispatchEvent(new CustomEvent('data-om-seek-to-time-frame', { detail: { time: t, sync: true } })));
            requestAnimationFrame(() => requestAnimationFrame(r)); })""", i / fps)
        ff.stdin.write(root.screenshot(type='jpeg', quality=93))
    b.close()
ff.stdin.close(); ff.wait(); srv.shutdown()
print(json.dumps({'out': out, 'frames': n, 'seconds': dur, 'render_s': round(time.time() - t0), 'page_errors': errs[:3]}))
