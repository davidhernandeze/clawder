# TOOLS.md - Local Notes

## Instagram Data Collection

### Key Capabilities

- **Browser automation**: OpenClaw's sandbox browser (Chromium) via Kasm desktop
- **Image reading**: Vision model support (DeepSeek V4 Flash supports text input; check model image support)
- **Humanized patterns**: Vary scroll speed, mouse position, timing between actions

### Instagram Web App Notes

- Login page: `https://www.instagram.com/`
- Explore/feed: scroll patterns matter — natural pauses, varied scroll distances
- Profile pages: `/username/` — follower/following counts, bio, posts grid
- Post detail: opens in modal or `/p/shortcode/` — caption, likes, comments, timestamp
- Image extraction: screenshots of posts, stories, profiles for OCR/vision extraction

### Anti-Detection Practices

- Randomize delays between actions (not fixed intervals)
- Natural scroll patterns (slow, pause, scan, scroll more)
- Vary click positions slightly (don't always hit the exact pixel)
- Add mouse movements that look human (don't teleport cursor)
- Session rotation for heavy data collection
- Mimic human browsing (scrolling feed, pausing on posts, checking profiles)

## Replication

All workspace config and prompts are captured in `~/clawder/config/workspace/` for recreating this environment.

---

_Last updated: 2026-06-06_
