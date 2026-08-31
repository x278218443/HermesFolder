# Pipeline Output Structure

Standard output layout for AI video news pipelines.

## Directory Structure

```
output/
└── YYYY-MM-DD_HHMM/
    ├── news_raw.json       # Raw collected news items
    ├── script.json         # LLM-generated script (title, segments, tags)
    ├── narration.mp3       # TTS audio output
    ├── subtitles.srt       # SRT subtitle file
    ├── subtitles.ass       # ASS subtitle file (auto-generated from SRT)
    ├── final_video.mp4     # Composed video
    ├── metadata.json       # Pipeline run metadata
    ├── images/             # AI-generated or fallback images per segment
    │   ├── segment_00.jpg
    │   ├── segment_01.jpg
    │   └── ...
    ├── boards/             # Composed "board" style images (if applicable)
    │   ├── board_00.jpg
    │   └── ...
    └── videos/             # AI-generated video clips (if applicable)
        ├── clip_00.mp4
        └── ...
```

## Key File Formats

### script.json
```json
{
  "title": "Video title (headline news)",
  "date": "YYYY-MM-DD",
  "segments": [
    {
      "index": 1,
      "headline": "News headline (≤20 chars)",
      "narration": "Detailed narration (15-25s for lead, 8-12s for others)",
      "image_query": "English description for AI image generation"
    }
  ],
  "tags": ["tag1", "tag2"]
}
```

### metadata.json
```json
{
  "date": "YYYY-MM-DD_HHMM",
  "title": "...",
  "segments": [...],
  "audio": "/path/to/narration.mp3",
  "video": "/path/to/final_video.mp4",
  "srt": "/path/to/subtitles.srt",
  "tags": [...],
  "news_count": 10,
  "segment_count": 8,
  "duration_sec": 120.5,
  "image_paths": ["path1", "path2", ""],
  "video_paths": ["", ""]
}
```

## Validation Commands

```bash
# Check video streams
ffprobe -v quiet -show_streams -of json final_video.mp4 | jq '.streams[].codec_type'

# Check audio duration
ffprobe -v quiet -show_entries format=duration -of csv=p=0 narration.mp3

# Check subtitle count
grep -c "^[0-9]*$" subtitles.srt

# Verify JSON validity
python3 -c "import json; json.load(open('script.json')); print('OK')"
```

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `image_paths` all empty | AI image gen failed + fallback returned nothing | Check API key, network, or use `--source lorem` |
| `video_paths` all empty | ARK_API_KEY not set | Set env var or accept static images only |
| Video has no audio | `narration.mp3` missing or empty | Check TTS step output |
| Subtitles out of sync | Segment timing calculated from char count, not actual speech | Use audio duration for timing |
| Board composition fails | No images to composite | Pipeline should fall back to plain background |
