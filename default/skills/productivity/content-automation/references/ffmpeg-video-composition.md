# FFmpeg Video Composition Pitfalls

Collected from real pipeline debugging. These are non-obvious FFmpeg behaviors that cause silent failures.

## filter_complex vs -vf

**Rule:** When using `-f lavfi -i` (synthetic input), you MUST use `-filter_complex`, NOT `-vf`.

```bash
# WRONG — produces empty output or "Error initializing a simple filtergraph"
ffmpeg -y -f lavfi -i "color=c=white:s=1920x1080:d=1:r=1" \
  -vf "drawtext=text=Hello:fontsize=96:fontcolor=black:x=100:y=100" \
  -frames:v 1 output.jpg

# CORRECT
ffmpeg -y -f lavfi -i "color=c=white:s=1920x1080:d=1:r=1" \
  -filter_complex "drawtext=text=Hello:fontsize=96:fontcolor=black:x=100:y=100" \
  -frames:v 1 -update 1 output.jpg
```

**Why:** `-vf` is a simple filtergraph that expects a real input stream. `-f lavfi` generates a synthetic stream that requires `-filter_complex` to connect properly.

## -map 0:v Suppresses drawtext

**Symptom:** Command succeeds, output file exists, but text is invisible (pure background).

**Cause:** `-map 0:v` with `-filter_complex` can cause drawtext to not render. The mapped stream bypasses the filter chain.

```bash
# WRONG — no text visible
ffmpeg -y -f lavfi -i "color=c=white:s=1920x1080:d=1:r=1" \
  -filter_complex "drawtext=text=Hello:fontsize=96:fontcolor=black:x=100:y=100" \
  -map 0:v -frames:v 1 -update 1 output.jpg

# CORRECT — omit -map 0:v
ffmpeg -y -f lavfi -i "color=c=white:s=1920x1080:d=1:r=1" \
  -filter_complex "drawtext=text=Hello:fontsize=96:fontcolor=black:x=100:y=100" \
  -frames:v 1 -update 1 output.jpg
```

## -update 1 for Single Image Output

**Symptom:** `Cannot write more than one file with the same name. Are you missing the -update option?`

**Fix:** Add `-update 1` when writing single frames to image files:

```bash
ffmpeg -y -f lavfi -i "color=c=white:s=1920x1080:d=1:r=1" \
  -filter_complex "..." \
  -frames:v 1 -update 1 output.jpg
```

## Filter Chain Continuity

**Symptom:** `Error initializing a simple filtergraph` or output has only background, no text/graphics.

**Cause:** Broken filter chain — draw operations have no input source.

```python
# WRONG — semicolon splits chain, second part has no input
full_filter = "color=c=white:s=1920x1080[d1]; drawtext=text=Hello:fontsize=96[x]"

# CORRECT — all operations in one comma-separated chain
full_filter = "color=c=white:s=1920x1080, drawtext=text=Hello:fontsize=96[x]"

# CORRECT — when you DO need two chains, use labels
full_filter = "color=c=white:s=1920x1080[bg]; [bg]drawtext=text=Hello:fontsize=96[x]"
```

**Rule:** In FFmpeg filter_complex, `;` separates independent filter chains (each needs its own labeled output). `,` chains filters sequentially within one chain.

## Font Path for Chinese Text

Noto Sans CJK may not be installed. Fallback that works on most Linux:

```python
FONT = "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc"  # WenQuanYi Zen Hei
```

Check available Chinese fonts: `fc-list :lang=zh`

## drawgrid for Grid Backgrounds

```python
# Subtle tech grid
f"drawgrid=w=60:h=60:t=1:c=0x1a3050@0.3"
# w=width, h=height, t=thickness, c=color@opacity
```

## Source Filters Cannot Accept Input Labels

**Symptom:** `Filter drawtext:default has an unconnected output` or `More input link labels specified for filter 'color' than it has inputs`

**Cause:** Source filters (`color`, `gradients`, etc.) generate their own frames — they have no input. Prefixing the filter chain with `[0:v]` tells FFmpeg to feed input #0 into the first filter, but source filters don't accept inputs.

```python
# WRONG — [0:v] prefix on a chain starting with color source
full_filter = "[0:v]color=c=0x121227:s=1920x1080,drawtext=text=Hello[v]"
cmd = ["ffmpeg", "-f", "lavfi", "-i", "color=c=0x121227:s=1920x1080",
       "-filter_complex", full_filter, "-map", "[v]", ...]

# CORRECT — no [0:v] prefix, source filter is the chain start
full_filter = "color=c=0x121227:s=1920x1080,drawtext=text=Hello[v]"
cmd = ["ffmpeg", "-f", "lavfi", "-i", "color=c=0x121227:s=1920x1080",
       "-filter_complex", full_filter, "-map", "[v]", ...]
```

**Rule:** When `-filter_complex` starts with a source filter (no preceding labeled output), do NOT add `[0:v]`. The source filter is self-generating. Use `-map [v]` to select the chain's output.

**When `[0:v]` IS correct:** When the chain starts with an existing labeled stream, e.g. `[0:v]scale=1920:1080,drawtext=...[v]` — here `[0:v]` refers to the input video stream, not a source filter.

## Quick Diagnosis Checklist

When FFmpeg produces empty/wrong output:

1. **Check returncode** — 0 means "ran" not "correct"
2. **Check file size** — tiny file (<5KB for 1920x1080) = nothing rendered
3. **Check stderr** — warnings about "0 frames" or "simple filtergraph" = filter issue
4. **Test minimal command** — strip to one filter, one input, verify it works
5. **Verify font exists** — `ls /path/to/font.ttf` and `fc-match "Font Name"`
