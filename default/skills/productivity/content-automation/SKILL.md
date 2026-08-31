---
name: content-automation
description: "Use when building or running automated content pipelines: news collection → LLM script → TTS → video composition → platform publishing."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [content, automation, video, pipeline, tts, publishing, ai]
    related_skills: [powerpoint, humanizer]
---

# Content Automation Pipelines

## Overview

Automated content pipelines chain multiple AI services to produce publishable media. The canonical pattern: **collect → script → voice → video → publish**. This skill covers the architecture, common pitfalls, and integration patterns for building and running these pipelines.

## When to Use

- Building a news/video generation pipeline (AI早报, daily briefings, topic explainers)
- Running an existing pipeline that uses LLM + TTS + FFmpeg + platform APIs
- Debugging pipeline failures (truncated JSON, missing images, publishing errors)
- Setting up environment for a cloned content automation project

Don't use for: single-shot video editing, manual content creation, or pure text generation tasks.

## Pipeline Architecture

```
┌──────────────┐
│  1. Collect   │  RSS feeds, APIs, web scraping
└──────┬───────┘
       ↓
┌──────────────┐
│  2. Script    │  LLM generates structured JSON (segments, narration, image_query)
└──────┬───────┘
       ↓
┌──────────────┐
│  3. Voice     │  TTS engine (MiMo, edge-tts, MiniMax)
└──────┬───────┘
       ↓
┌──────────────┐
│  4. Visuals   │  AI image gen (Seedream, DALL-E) + board composition
└──────┬───────┘
       ↓
┌──────────────┐
│  5. Compose   │  FFmpeg: concat segments + subtitles + audio → MP4
└──────┬───────┘
       ↓
┌──────────────┐
│  6. Publish   │  Bilibili API, Douyin Playwright, YouTube OAuth
└──────────────┘
```

Each step should be independently testable with `--dry-run` or by running the module directly.

## Environment Setup

When cloning a content automation repo:

```bash
# 1. Create venv and install base deps
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# 2. Install platform-specific deps
pip install bilibili-api-python    # B站 publishing
pip install edge-tts               # Free TTS fallback
pip install playwright             # Browser automation (Douyin)
playwright install chromium        # Download browser binary

# 3. Verify core tools
ffmpeg -version                    # Video composition
ffprobe -version                   # Audio duration detection
```

### Chromium Version Mismatch Workaround

Playwright may demand a newer chromium than installed. Use `executable_path` to point to existing:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(
        headless=True,
        executable_path='/home/user/.cache/ms-playwright/chromium-1228/chrome-linux64/chrome'
    )
```

Find existing installations: `ls ~/.cache/ms-playwright/`

## Common Pitfalls

### 1. LLM JSON Truncation (max_tokens)

**Symptom:** `JSON 解析失败: Unterminated string starting at: line N column M`

**Cause:** LLM response exceeds `max_tokens`, cutting off mid-JSON. Common with multi-segment scripts (>500 chars narration).

**Fix:** Increase `max_tokens` in the LLM call:
- MiMo v2.5-pro: use `max_tokens=4096` (3000 truncates JSON-heavy responses)
- GPT-4 class: `max_tokens=4096` is usually safe
- Always validate the full JSON structure after parsing

**Verification:** After fixing, run the script generation step alone and confirm `json.loads()` succeeds on the full response.

### 2. Image Fallback Chain

Most pipelines implement graceful degradation for image sources:

```
AI generation (Seedream/DALL-E) → Stock API (Unsplash) → Random (Lorem Picsum) → Plain background
```

When AI image gen fails (no API key, quota exceeded, timeout), the pipeline should continue with fallback images. If ALL sources fail, compose video with plain dark background — don't abort the pipeline.

**Check:** After pipeline run, verify `image_paths` in metadata.json. Empty strings indicate fallback was used.

**Network-blocked servers:** Some cloud servers block image CDNs (Lorem Picsum, Unsplash API). Fallback that works: use Unsplash direct image URLs without API key:

```python
# Unsplash direct URLs work without API key
UNSPLASH_PHOTOS = [
    "1485827404703-89b55fcc595e",  # robot
    "1677442136019-21780ecad995",  # AI brain
    "1555255707-c07966088b7b",     # tech abstract
]
url = f"https://images.unsplash.com/photo-{photo_id}?w=1920&h=1080&fit=crop&q=80"
```

**Check connectivity first:** `curl -sI https://picsum.photos` — if it times out, skip that source.

### 3. TTS Engine Fallback

TTS modules should auto-downgrade when primary engine fails:

```python
if engine == "mimo" and not MIMO_API_KEY:
    print("[TTS] MiMo API Key 未配置，降级到 edge-tts")
    engine = "edge-tts"
```

edge-tts is free and requires no API key — good for testing and as a reliable fallback.

### 4. Board Composition (板书 Style)

Board-style images combine dark grid backgrounds with text overlays. Common failure modes:

**Filter chain breakage:** When no photo is available, the filter chain can break if `;` is used where `,` is needed. See `references/ffmpeg-video-composition.md` for details.

**Rule:** All draw operations (drawtext, drawbox, drawgrid) must be in the same comma-separated chain as the background generation, unless a labeled intermediate exists.

```python
# WRONG — draw operations disconnected from background
full_filter = "color=c=0x0a1628:s=1920x1080[bg]; drawtext=text=Hello:fontsize=96:fontcolor=white[x]"

# CORRECT — single chain
full_filter = "color=c=0x0a1628:s=1920x1080, drawtext=text=Hello:fontsize=96:fontcolor=white[x]"
```

**Font issues:** Chinese text requires CJK fonts. Use `/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc` as fallback. Verify with `fc-list :lang=zh`.

**Title card generation:** For opening title cards, generate a static image with FFmpeg then use it as the first video segment. See `references/ffmpeg-video-composition.md` for the correct command pattern.

### 5. FFmpeg Filter Pitfalls

See `references/ffmpeg-video-composition.md` for detailed patterns. Key rules:

- `-f lavfi -i` requires `-filter_complex`, not `-vf`
- `-map 0:v` with `-filter_complex` can suppress drawtext
- Add `-update 1` when writing single frames to image files
- `;` splits independent chains; `,` chains sequentially

### 6. Platform Publishing Credentials

**B站:** Requires `BILI_SESSDATA` and `BILI_JCT` from browser cookies. Set in `.env`:
```
BILI_SESSDATA=xxx
BILI_JCT=xxx
BILI_BUVID3=xxx  # optional
```

**抖音:** Requires Playwright with logged-in browser session. More complex — needs browser automation to upload, fill forms, handle crop dialogs.

**Both:** Test with `--dry-run` first to verify the pipeline produces valid output before attempting publish.

**VNC/headless login verification:** When automating browser login via VNC or headless mode, NEVER claim "login successful" without taking a screenshot and verifying the page content. A script reporting "登录成功" based on URL patterns alone can be a false positive — the page might still show a login form or QR code. Always use `vision_analyze` on the screenshot before confirming login state.

**抖音 SMS verification:** Publishing to Douyin may trigger SMS verification on first use or after cookie expiry. The verification dialog has a "获取验证码" button that must be clicked before the user receives the code. Script should detect this dialog and prompt the user, not skip past it.

## Verification Checklist

After running a content pipeline:

- [ ] `news_raw.json` exists and contains valid news items
- [ ] `script.json` has `title`, `segments[]` with `narration` and `image_query`
- [ ] `narration.mp3` exists and `ffprobe` reports reasonable duration
- [ ] `subtitles.srt` has entries matching segment count
- [ ] `final_video.mp4` exists and `ffprobe` shows video + audio streams
- [ ] Board images (`boards/board_*.jpg`) have text content, not just background
- [ ] Title card (`boards/title_card.jpg`) renders with visible text
- [ ] `metadata.json` has all expected fields
- [ ] No `""` in `image_paths` unless AI image gen was intentionally skipped

## One-Shot Recipes

### Dry Run (test without publishing)
```bash
python3 pipeline.py --topics "AI" --count 3 --dry-run
```

### Full Pipeline
```bash
python3 pipeline.py --topics "AI" "科技" --count 5
```

### Publish to Bilibili
```bash
python3 bilibili_publish.py --video output/latest/final_video.mp4
```

### Test TTS Only
```bash
python3 -c "from tts_engine import synthesize_speech; synthesize_speech('测试', '/tmp/test.mp3')"
```
