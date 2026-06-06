# Rook Operations — Instagram Event Collection for Mérida, Yucatán

## Mission

Daily browsing of Instagram using a humanized account to discover **events in Mérida, Yucatán** — concerts, festivals, gallery openings, food markets, workshops, sports, cultural events, and nightlife. Extract structured data and store as JSON files while maintaining a natural-looking account footprint.

## How It Works

### 1. Session Preparation
- Read IG credentials from environment (`IG_USERNAME`, `IG_PASSWORD`)
- Open Chromium via OpenClaw's browser tools
- Navigate to instagram.com
- Humanlike login (type naturally, slight pauses between fields)
- Session cookie persistence through `data/openclaw`

### 2. Browsing Workflow (Daily, 8-15 min)

The account already follows local venues, bars, promoters — so the feed is seeded. Each session rotates through a subset of these activities:

**a. Feed Scrolling**
- Scroll the home feed with varied timing
- 500-1200ms between paginations, sometimes pause longer (2-4s) on interesting posts
- Apply relevance filter to each post (see section 6)
- When an event post is found: extract data (section 4)
- Randomly like 1-3 non-event posts per session (see section 8)
- Randomly like event posts from venues we don't follow (feeds the algorithm)

**b. Profile Checks** (2-3 profiles per session, rotating across days)
- Targeted visits to profiles of known venues/promoters
- Scroll their grid, click into recent posts
- Check their bio/links for event schedules
- If a profile posts consistent events, like a recent post casually

**c. Location/Explore**
- Search relevant hashtags: #MeridaEventos #MeridaTonight #YucatanEvents (spread over days)
- Browse location-based content tagged at venues
- Check "Explore" tab for local trends
- When a post from an unknown account is relevant, decide whether to follow (section 7)

**d. Story Sessions** (2-3 min)
- View stories from followed accounts
- Stories often have "today only" event promos or countdown stickers
- Apply relevance filter (section 6)
- Watch stories fully (don't skip instantly — human behavior)
- Randomly react to 1 story per session with a quick tap (heart emoji) — this looks organic

### 3. Humanization Patterns

| Pattern | Detail |
|---------|--------|
| **Timing variance** | 700ms ± 300ms base, occasionally 2-5s "reading" pauses. Never the same interval twice. |
| **Scroll variance** | 3 quick scrolls → pause → 1 long scroll → pause mid-feed. Rotate patterns each session. |
| **Click variance** | Slight offsets from center of elements. Natural mouse movement trajectories. |
| **Lost pointer** | Every 45-90 seconds, simulate losing the mouse — small hesitant movements, tiny zigzag, or quick circle as if searching for the cursor. Particularly before clicking a target or after a period of inactivity. |
| **Micro-adjustments** | Approach targets in stages — overshoot slightly, correct, then click. Never land exactly on the first pass. |
| **Session length** | 8-15 minutes max. Looks like a real break. Hard stop at 15 min. |
| **Session time** | Realistic browsing hours only. No 3 AM runs. Vary start time ±1 hour across days. |
| **Skip pattern** | Skip every 3rd/4th post/story naturally. |
| **Like timing** | Don't like posts in batches. Spread interactions across the session. Wait at least 10-15s after viewing before liking. |
| **Follow timing** | Only follow max 1-2 new accounts per session. Wait until near the end of the session to follow (looks like you discovered them browsing). |

### 4. Data Extraction

When an event post is identified:

1. **Screenshot** the post (image + caption context)
2. **Extract via vision** if text isn't fully accessible through page content
3. **Structure** into the event schema:

```json
{
  "_id": "ig-<shortcode>",
  "source": "instagram",
  "sourceUrl": "https://instagram.com/p/<shortcode>/",
  "sourceAccount": "@venuename",
  "title": "Concierto de Muse Tribute",
  "description": "Banda tributo a Muse en vivo en La Cuarta",
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
  "confidence": "high"
}
```

**Confidence levels:**
- `high` — explicit date + time + venue in caption or poster
- `medium` — date mentioned but no time, or venue inferred from location tag
- `low` — looks like an event but missing key details; needs human review

### 5. File Output

- **Raw**: `data/events/raw/YYYY-MM-DD--<handle>-<shortcode>.json`
- **Processed**: `data/events/processed/YYYY-MM-DD.json` — daily compilation
- **Screenshots**: `data/events/screenshots/YYYY-MM-DD--<handle>-<shortcode>.png`

### 6. Relevance Criteria — Is This an Event?

Not every post from a followed venue is an event. Most posts on Instagram are just content. Apply this decision tree:

**SIGNALS THAT A POST IS AN EVENT:**

| Signal | Examples |
|--------|----------|
| **Date/time in caption or image** | "Este viernes", "Sábado 8", "June 15", "9 PM", "8:00 pm" |
| **Event design graphics** | Poster-style image with date, lineup, venue logo |
| **Action words in caption** | "Concierto", "Festival", "Exposición", "Taller", "Mercado", "Noche de", "Tocada", "Evento" |
| **Tagged location = venue** | Tagged at a known bar, restaurant, gallery, theater |
| **Mentions other accounts** | Tagging bands, artists, DJs, or collaborators in the post |
| **Countdown/date stickers** | On stories: "Countdown", "Event", date stickers |
| **Link in bio for tickets** | "Link in bio for tickets / boletos / entradas" |
| **Venue specific imagery** | Stage setup, DJ booth, empty room before an event, lineup flyer |

**LIKELY NOT AN EVENT (skip these):**

| Signal | Examples |
|--------|----------|
| **Personal photos** | Staff selfies, dinner photos, BTS of the kitchen |
| **Daily specials** | "Today's special: cochinita tacos" — this is a menu, not an event |
| **Generic food/drink photos** | Nice cocktail shot, beautifully plated dish — not an event |
| **Reposted memes** | Marketing memes, relatable industry content |
| **General announcements** | "We're hiring", "New hours starting Monday", "Closed for renovation" |
| **Throwback posts** | "Throwback to last weekend's show" — already happened, not upcoming |
| **Single image of artist/musician** | Just a portrait or promo shot without date/venue context |

**STORY-SPECIFIC SIGNALS:**
- Countdown stickers → check the date
- Location sticker + "Tonight" / "Today" text → likely event
- "Link in bio" + event graphic → extract
- Repost of a customer's story → usually skip
- Food/kitchen BTS → skip
- Poll or question sticker ("Where should we play next?") → skip

**If uncertain: extract with `confidence: "low"` and let human review decide.**

### 7. Follow Strategy — When to Follow

The account's follow list is a living thing. It grows naturally over time.

**FOLLOW IF:**
- Unknown account posts a relevant Mérida event and their profile bio confirms they're a venue, promoter, musician, artist, or organizer
- Profile description mentions: "eventos en Mérida", "promotor", "música en vivo", venue name, or a related category
- They post events regularly (check their latest 3-6 posts — if >50% are event-related, follow)
- A known venue/account reposts or tags them in an event context

**DON'T FOLLOW IF:**
- Account is in a different city (Cancún, CDMX, etc.)
- Account is a national brand (Corona, Heineken, etc.)
- Account is clearly a personal page of someone who just happens to be at events
- Account posts mostly memes/entertainment content
- Account has less than 3 posts or feels like a bot/spam account

**RULES:**
- Max 1-2 new follows per session — looks organic
- Wait until the last 3-4 minutes of the session before following (feels like organic discovery)
- Don't follow accounts you've already followed (track via Instagram's "Following" state)
- Never unfollow anyone — growing is natural, shrinking is suspicious

### 8. Interaction Strategy — Random Engagements

A real account likes posts. A scraping account doesn't. We like things.

**WHAT TO LIKE:**
- 1-3 non-event posts per session from followed accounts (nice food photo, cool architecture shot, behind-the-scenes)
- 1-2 event posts from accounts we DON'T follow (trains the algorithm to show us more event content)
- 1 story reaction per session (heart tap) — on a story that's genuine content, not promotional spam

**WHAT NOT TO LIKE:**
- Multiple posts in a row from the same account (looks like a bot)
- Old posts (>30 days) — real users rarely go back and like old content
- Posts from national brands or obvious ads
- Controversial content, politics, news

**LIKE PATTERN RULES:**
- Spread likes across the session, not in a batch
- Wait 10-15 seconds after opening a post before liking
- Don't like more than 5 total items per session
- Never like posts from the same account twice in one session
- Vary the accounts you interact with day to day

### 9. Browsing Session Template

A typical 12-minute session might look like:

```
0:00     Open browser → navigate to instagram.com
0:30     Login (type credentials, slight pauses)
1:00     Feed appears, start scrolling — slow, reading pauses
3:00     See event post → pause, screenshot, extract data
4:30     Continue scrolling, see a nice photo → like it
6:00     Click into a venue profile → scroll grid, click recent post
7:30     See another event post → screenshot, extract
9:00     Check stories → watch 3 stories, react to 1
10:30    Scroll explore tab for local hashtag
11:30    Find new venue account → follow it
12:00    Last scroll, wrap up, close
```

The exact pattern varies every session. Never the same sequence twice.

### 10. What I Won't Do
- ❌ Post, comment, or DM
- ❌ Save posts or add to collections
- ❌ Scrape at unnatural hours
- ❌ Use the same browsing pattern twice
- ❌ Exfiltrate credentials or private data
- ❌ Follow more than 2 accounts per session
- ❌ Like more than 5 posts per session
- ❌ Interact with old content (>30 days)

### Event Data Model — Reference

| Field | Type | Description |
|---|---|---|
| `_id` | string | Unique identifier (ig-<shortcode>) |
| `title` | string | Event title from caption/poster |
| `description` | string | Full description |
| `category` | string | music, art, food, sports, culture, nightlife, workshop, other |
| `tags` | string[] | Keywords for categorization |
| `location.city` | string | "Mérida" |
| `location.country` | string | "MX" |
| `startDate` | ISO string | When the event starts |
| `price.amount` | number | Entry fee (0 if free) |
| `price.isFree` | bool | True if no entry fee |
| `status` | string | Initial: "pending" |
| `confidence` | string | high / medium / low |
