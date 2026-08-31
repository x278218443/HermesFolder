# MiMo API Reference (Token Plan)

## Endpoint

```
Base URL: https://token-plan-cn.xiaomimimo.com/v1
Auth header: api-key: <key>  (NOT Authorization: Bearer)
```

## Key Format

MiMo Token Plan keys start with `tp-` (e.g., `tp-c94w7cdo9c683osvigcffg1cwhdlmbtjb2srlqwh7w5n4rej`).

Environment variable: `MIMO_API_KEY`

## Models

| Model | Use | max_tokens |
|-------|-----|------------|
| mimo-v2.5-pro | Script generation (chat completions) | 4096 |
| mimo-v2.5-tts | Voice synthesis (audio output) | N/A |

## Script Generation (LLM)

```python
resp = requests.post(
    f"{LLM_API_BASE}/chat/completions",
    headers={"api-key": LLM_API_KEY, "Content-Type": "application/json"},
    json={
        "model": "mimo-v2.5-pro",
        "messages": [
            {"role": "system", "content": "..."},
            {"role": "user", "content": prompt},
        ],
        "temperature": 0.7,
        "max_tokens": 4096,  # CRITICAL: 3000 truncates JSON
    },
    timeout=60,
)
```

**Pitfall:** `max_tokens=3000` causes "Unterminated string" JSON parse errors when generating multi-segment scripts (>500 chars narration). Always use 4096+.

## TTS (Voice Synthesis)

```python
payload = {
    "model": "mimo-v2.5-tts",
    "messages": [
        {"role": "user", "content": "明亮清晰的播报语气"},  # style instruction
        {"role": "assistant", "content": text_to_speak},     # text to synthesize
    ],
    "audio": {"format": "mp3", "voice": "冰糖"},
    "stream": False,
}
resp = requests.post(
    f"{MIMO_BASE_URL}/chat/completions",
    headers={
        "Authorization": f"Bearer {MIMO_API_KEY}",  # Note: Bearer for TTS
        "Content-Type": "application/json",
    },
    json=payload,
    timeout=120,
)
```

**Available voices (Chinese):** 冰糖 (bright female), 茉莉 (gentle female), 苏打 (male), 白桦 (deep male)

**Auth difference:** LLM uses `api-key` header; TTS uses `Authorization: Bearer` header.

## Fallback: edge-tts

Free, no API key required:
```bash
pip install edge-tts
edge-tts --voice zh-CN-XiaoyiNeural --text "测试" --write-media output.mp3
```

Voices: `zh-CN-XiaoyiNeural` (female), `zh-CN-XiaoxiaoNeural` (female), `zh-CN-YunxiNeural` (male)
