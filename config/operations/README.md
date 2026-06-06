# Rook Operations — Instagram Event Collection for Mérida, Yucatán

## Mission

Daily browsing of Instagram using a humanized account to discover **events in Mérida, Yucatán** — concerts, festivals, gallery openings, food markets, workshops, sports, cultural events, and nightlife. Extract structured data and store as JSON files.

## How It Works

### 1. Session Preparation
- Read IG credentials from environment (`IG_USERNAME`, `IG_PASSWORD`)
- Open Chromium via OpenClaw's browser tools
- Navigate to instagram.com
- Humanlike login (type naturally, slight pauses between fields)
- Session cookie persistence through `data/openclaw`

### 2. Browsing Workflow (Daily)

The account already follows local venues, bars, promoters — so the feed is seeded. I visit:

**a. Feed Scrolling**
- Scroll the home feed with varied timing
- 500-1200ms between paginations, sometimes pause longer (2-4s) on interesting posts
- When an event post appears:
  - Take a screenshot for visual context
  - Extract caption text, date, location if tagged
  - Note the poster's handle (many venues post their own events)

**b. Profile Checks** (rotating across days)
- Targeted visits to profiles of known venues/promoters
- Scroll their grid, click into recent posts
- Check their bio/links for event schedules

**c. Location/Explore**
- Search relevant hashtags: #MeridaEventos #MeridaTonight #YucatanEvents (human schedule, spread over days)
- Browse location-based content tagged at venues
- Check "Explore" tab for local trends

**d. Story Sessions** (when applicable)
- View stories from followed accounts (stories often have "today only" event promos)
- Take screenshots of story content when relevant

### 3. Humanization Patterns
- **Timing variance**: Actions never happen on exact intervals. 700ms ± 300ms as base, occasionally 2-5s "reading" pauses.
- **Scroll variance**: Sometimes 3 short scrolls, sometimes 1 long scroll, sometimes a pause mid-feed.
- **Click variance**: Natural mouse movements, slight offsets from center.
- **Session length**: 8-15 minutes per session, not longer — looks like a real break.
- **Time of day**: Sessions happen at realistic browsing times. No 3 AM scraping runs.
- **Skip pattern**: Skip every 3rd or 4th story/post naturally, like a real user.

### 4. Data Extraction

When an event post is found:

1. **Screenshot** the post (image + caption context)
2. **Extract via vision** if text isn't accessible:
   - Post image may have event poster with dates/text
   - Screenshot the full post modal
3. **Structure** into the event schema:

```json
{
  "_id": "ig-<post-shortcode>",
  "source": "instagram",
  "sourceUrl": "https://instagram.com/p/<shortcode>/",
  "sourceAccount": "@venuename",
  "title": "Concierto de Muse Tribute",
  "description": "Banda tributo a Muse en vivo en La Cuarta",
  "imageUrl": "https://cdn/.../events/<id>/<uuid>.jpg",
  "category": "music",
  "tags": ["muse", "tribute", "rock", "mérida"],
  "location": {
    "placeId": null,
    "address": null,
    "city": "Mérida",
    "country": "MX",
    "geo": { "type": "Point", "coordinates": [-89.6237, 20.9674] }
  },
  "startDate": "2026-06-10T20:00:00Z",
  "endDate": null,
  "price": { "amount": 0, "currency": "MXN", "isFree": true },
  "status": "pending",
  "moderation": {
    "reviewedBy": null,
    "reviewedAt": null,
    "rejectionReason": null,
    "history": [{"from": "raw", "to": "pending", "by": "rook", "at": "2026-06-06T18:40:00Z", "reason": null}]
  },
  "stats": { "viewCount": 0, "interestedCount": 0 },
  "createdAt": "2026-06-06T18:40:00Z",
  "updatedAt": "2026-06-06T18:40:00Z",
  "deletedAt": null,
  "confidence": "high"  // high = explicit date+time, medium = partial info, low = inferred
}
```

### 5. File Output

- **Raw**: `data/events/raw/YYYY-MM-DD--<handle>-<shortcode>.json` — full extraction as-is
- **Processed**: `data/events/processed/YYYY-MM-DD.json` — daily compilation of all events found
- **Screenshots**: `data/events/screenshots/YYYY-MM-DD--<handle>-<shortcode>.png` — visual reference

### 6. What I Won't Do
- ❌ Post, comment, DM, or like anything
- ❌ Follow/unfollow accounts
- ❌ Save posts or interact in any way
- ❌ Scrape at unnatural hours
- ❌ Use the same pattern twice
- ❌ Exfiltrate credentials anywhere

### Data Model Reference

| Field | Type | Description |
|---|---|---|
| `_id` | string | Unique identifier (ig-<shortcode>) |
| `title` | string | Event title from caption/poster |
| `description` | string | Full description |
| `category` | string | music, art, food, sports, culture, nightlife, workshop, other |
| `tags` | string[] | Keywords for categorization |
| `location.city` | string | Always "Mérida" initially |
| `location.country` | string | "MX" |
| `startDate` | ISO string | When the event starts |
| `price.amount` | number | Entry fee (0 if free) |
| `price.isFree` | bool | True if no entry fee |
| `status` | string | Initial: "pending" |
| `confidence` | string | high / medium / low |
