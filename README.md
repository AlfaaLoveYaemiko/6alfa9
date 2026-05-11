# 6alfa9

Pterodactyl-compatible Docker yolk that ships **Python 3.13 + Chromium + ChromeDriver + Xvfb + Selenium runtime libs** out-of-the-box. Drop-in image for HidenCloud / Pterodactyl panels that need to run hCaptcha / Selenium / Playwright bots.

Pulled image: `ghcr.io/<your-github-username>/6alfa9:latest`

## What's inside

- Python 3.13 (slim Debian Bookworm)
- Chromium + chromium-driver (matched, no version mismatch)
- Xvfb + xauth (real headed mode works via `xvfb-run`)
- All Chrome runtime libs (`libnss3`, `libgbm1`, `libxkbcommon0`, ...) verbatim from the user's spec
- Convenience: `git`, `gcc`, `g++`, `tini`, `procps`, `iproute2`, `sqlite3`

Pterodactyl conventions applied:

- User `container` (uid 1000)
- `HOME=/home/container`
- `entrypoint.sh` expands `{{VAR}}` -> `${VAR}` then `exec`s `$STARTUP`
- `STOPSIGNAL SIGINT`

Pre-set env vars so apps don't have to guess:

```
CHROME_BIN=/usr/bin/chromium
CHROME_BINARY=/usr/bin/chromium
CHROMEDRIVER_PATH=/usr/bin/chromedriver
SE_CHROMEDRIVER=/usr/bin/chromedriver
```

## How to publish (1 minute)

1. Create a **public** GitHub repo named `6alfa9` (under your account, e.g. `AlfaaLoveYaemiko/6alfa9`).
2. Upload these 3 files to it:
   - `Dockerfile`
   - `entrypoint.sh`
   - `.github/workflows/build.yml`
3. Make a git push (or click "Commit changes" in the GitHub web UI). The Action triggers automatically and:
   - Builds for `linux/amd64` + `linux/arm64`
   - Publishes to `ghcr.io/<your-github-username>/6alfa9:latest` (lowercased)
4. Go to your GitHub profile -> **Packages** tab -> click `6alfa9` -> **Package settings** -> **Change visibility** -> **Public**.
   (Otherwise HidenCloud can't pull it.)

Wait ~2-3 minutes for the first build. Subsequent builds are cached.

## How to use on HidenCloud

In the panel, edit your server:

- **Docker Image** -> set to `ghcr.io/<your-github-username>/6alfa9:latest`
- **Startup Command** -> `python3 start.py --install`
  (no need for `--install-deps` or `--download-chrome` — Chrome is already pre-installed in the image)
- Click **Save** and **Restart**.

On boot you should see in console:

```
Container@6alfa9: python=Python 3.13.x  chromium=Chromium 120.x ...  chromedriver=ChromeDriver 120.x ...
:/home/container$ python3 start.py --install
[start] Resolved bind host=0.0.0.0 port=24594
[start] Using system Chrome at /usr/bin/chromium (working)
[start] Booting uvicorn ...
```

Then `/api/solve` works without any apt-get / dpkg-deb tricks.

## Local test

```bash
docker buildx build --platform linux/amd64 -t 6alfa9:dev .
docker run --rm -it -e STARTUP='python3 -c "from selenium import webdriver; o=webdriver.ChromeOptions(); o.add_argument(\"--headless=new\"); o.add_argument(\"--no-sandbox\"); d=webdriver.Chrome(options=o); d.get(\"https://example.com\"); print(d.title); d.quit()"' 6alfa9:dev
```

Expected output:

```
Container@6alfa9: python=Python 3.13.x  chromium=Chromium 120.x  chromedriver=ChromeDriver 120.x
:/home/container$ python3 -c "..."
Example Domain
```
