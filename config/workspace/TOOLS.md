# TOOLS.md - Local Notes

## Instagram Data Collection — Mérida, Yucatán

### Operations
- **Mission**: Daily Instagram browsing to extract events in Mérida, Yucatán
- **Account**: Provided via `IG_USERNAME` / `IG_PASSWORD` env vars
- **Frequency**: Daily, 8-15 min sessions at realistic browsing times
- **Output**: JSON events stored in `~/clawder/data/events/`
- **Full ops plan**: `~/clawder/config/operations/README.md`

### Key Capabilities

- **Browser automation**: OpenClaw's sandbox browser (Chromium) via Kasm desktop
- **Image reading**: DeepSeek V4 Flash supports vision (image input) — enable in model config
- **Humanized patterns**: Vary scroll speed, mouse position, timing between actions
- **Event extraction**: Screenshot → vision → structured JSON

### Instagram Web App Notes

- Login page: `https://www.instagram.com/`
- Feed/explore: scroll patterns matter — natural pauses, varied scroll distances
- Profile pages: `/username/` — follower/following counts, bio, posts grid
- Post detail: opens in `/p/shortcode/` — caption, likes, comments, timestamp
- Stories: viewed from feed top bar; ephemeral, screenshot capture needed
- Image extraction: screenshots of posts, stories, profiles for vision extraction

### Anti-Detection Practices

- **Timing variance**: 700ms ± 300ms base, occasionally 2-5s "reading" pauses
- **Scroll variance**: 3 short → 1 long → pause mid-feed — never the same pattern
- **Click variance**: Slight offsets from center, natural mouse movements
- **Session length**: 8-15 min max. Looks like a real break.
- **Time of day**: Realistic browsing hours only (no 3 AM)
- **Skip pattern**: Skip every 3rd/4th post/story naturally
- **Session rotation**: Account rotation if multiple accounts configured

### Event Data Model

```json
{
  "_id": "ig-<shortcode>",
  "title": "Event Title",
  "description": "Full description",
  "category": "music|art|food|sports|culture|nightlife|workshop|other",
  "tags": ["tag1", "tag2"],
  "location": { "city": "Mérida", "country": "MX", "geo": { ... } },
  "startDate": "ISO datetime",
  "price": { "amount": 0, "currency": "MXN", "isFree": true },
  "status": "pending",
  "confidence": "high|medium|low"
}
```

### Data File Structure

- Raw events: `~/clawder/data/events/raw/YYYY-MM-DD--<handle>-<shortcode>.json`
- Daily compiled: `~/clawder/data/events/processed/YYYY-MM-DD.json`
- Screenshots: `~/clawder/data/events/screenshots/YYYY-MM-DD--<handle>-<shortcode>.png`

## Replication

All workspace config and prompts are captured in `~/clawder/config/workspace/` for recreating this environment.
Operations plan is at `~/clawder/config/operations/README.md`.

---

_Last updated: 2026-06-06_
