# Me4Us — CLAUDE.md

Couples app. Android first. Flutter \+ Supabase. Build App 1 only for now. Tagline: "a little more me, a little more us".

## Product (App 1: `me4us`)

Parts (each optional, gated by "doors" chosen at onboarding):

1. **Me** — self-care basics (daily: teeth, shower, meds, vitamins, meals; periodic: haircut etc.), points, quick multiple-choice check-ins.  
2. **Me \+ You** — shared calendar, chores, trivia, light messaging/nudges, flags.  
3. **Me \+ You \+ Kids** — kids calendars \+ tasks. **Paid add-on** (one-time IAP).  
4. **Dirty Fun Lite** — mild, PG-13 content only. Included. (Intense \= separate app, LATER. Do not build, do not bundle any intense content.)

Rules:

- Android first. One-time purchases. No cross-unlock between App 1 and App 2\.  
- Union \= 2–3 members, linked by invite code between separate phones.  
- Doors per person: kids / third person / alcohol / lite. Effective door \= ALL members opted in.  
- Never show content a member hasn't opted into. Vanilla users must never be surprised.  
- Points \= friendly rivalry; redeem for rewards (pick the date, 5-min massage). Redemption \= negative ledger entry.

## v0 scope (build only this first)

- Auth, create/join union via invite code  
- Doors onboarding  
- Me: self-care checklist \+ points \+ daily check-in  
- Us: shared calendar (in-app; Google Calendar sync later), nudges (opt-in, rate-limited)  
- Out of v0: Kids, Lite games, Flist, Rhythm (cycle), trivia, messaging

## Stack

- Flutter (Android first), Supabase: Auth, Postgres with row-level security, SQL functions (Edge Functions where needed), Realtime  
- FCM (a small Firebase project, free) for push notifications only, added with nudges  
- Monorepo with Melos (config in the root `pubspec.yaml`; Melos 8 no longer reads `melos.yaml`)
- Switched from Firebase to Supabase on 2026-11-02 (Firebase Cloud Functions need the paid Blaze plan)

## Repo layout

```
me4us/
├─ CLAUDE.md
├─ pubspec.yaml              # Dart workspace + Melos config
├─ apps/
│  └─ me4us/                 # com.<owner>.me4us
│  # apps/intense/ added LATER (com.<owner>.me4us.intense)
├─ packages/
│  ├─ core_auth/  core_union/  core_flist/  core_points/  core_content/  core_ui/
│  ├─ feat_me/  feat_couple/  feat_kids/  feat_lite/
│  └─ content_lite/          # JSON assets, imported ONLY by apps/me4us
├─ supabase/  (migrations/, tests/)
└─ docs/
```

- `apps/me4us` must NEVER depend on any `*_intense` package. Add a CI check.  
- Content item IDs are permanent. Never rename (Flist ratings key on them).  
- Content ships inside the app binary. Never fetch content from the server.

## Data model (Postgres, `supabase/migrations/`)

```
profiles(id = auth user)         display_name, active_union_id, fcm_tokens[]
selfcare_items                   user_id, title, category(basic|periodic|meds|nutrition), cadence, point_value, active
selfcare_log                     (user_id, date, item_id), done, at
checkins                         (user_id, date), answers[{qId, choiceId, note?}]
flist (per user)                 rating(curious|reserved|hard_limit), updated_at, source, cooldown_until, resurfaceCount, retired   # later

unions                           member_count(<=3), kids_entitled
members                          (union_id, user_id), role, joined_at, accepts_flags, hygiene_alerts, my_doors{kids,thirdPerson,alcohol,lite}, points
nudges                           union_id, from_uid, to_uid, kind(flag|presence), text?, at, read_at
points_ledger                    union_id, user_id, delta, reason, ref_type, ref_id, at
rewards                          union_id, title, cost, created_by, active
events                           union_id, title, start_at, end_at, all_day, owner_uid|null, audience, kid_id?, google_event_id?, reminders[]
kids                             union_id, name, birth_year                    # kids add-on
kid_tasks                        union_id, kid_id, title, recurrence, assigned_to, done_log   # kids add-on
flist_matches                    (union_id, item_id), matched_at, tier          # function-written, later
invites                          code, union_id, created_by, expires_at, uses_left   # function-only
invite_attempts                  user_id, count, window_start                   # function-only (rate limit)
```

## Security rules (row-level security)

- Me data (`profiles`, `selfcare_*`, `checkins`): owner only. Partners never read Me data.  
- Union tables: read by members only. Writes to unions, members (join/role/points), nudges, matches, sessions, entitlements = SQL functions only.  
- Members edit only their own `accepts_flags`, `hygiene_alerts`, `my_doors`. Nudge recipients may set `read_at` only. Only sender and recipient see a nudge.  
- `points_ledger` is append-only, own entries. Kids tables writable only when `kids_entitled`.  
- `invites`, `invite_attempts`: no client access (RLS on, no policies, no grants).  
- Privileges are granted explicitly (revoke all, then grant); never rely on Supabase default grants.  
- Write database tests BEFORE building UI: `cd supabase/tests && npm test` (embedded Postgres + a small shim for `auth`).

## SQL functions (v0)

- `create_union()`, `redeem_invite(code)` (5 attempts/hour). Expected failures are returned as a `status`, not raised, so the attempt counter commits.  
- `sendNudge` (checks `accepts_flags`, rate limit 3/day/sender, FCM). Not built yet.  
- Later: `onFlistWrite`, `createSession`, `respondSuggestion`, `verifyKidsPurchase`

## Flist rules (build later, keep in mind now)

- Rating private to owner. Partner never sees raw ratings.  
- Match only when ALL members rate `curious`. Reveals nothing about who rated what.  
- Any `hard_limit` excludes the item for everyone. Never deleted; owner can always view/change.  
- Suggestion in a game: everyone must tap "try it". Weekly suggestion: asked privately until all accept.  
- Skip → `cooldownUntil = now + 10d × (resurfaceCount + 1)`, cap 90 days, then `retired` until owner re-rates.  
- Nobody is told who skipped.

## Hygiene / flags

- Opt-in per person. Flags: sender limited to 3/day; receiver must have `acceptsFlags`.  
- Worrying pattern → silent `presence` nudge ("go be present for a moment"). Never state the reason.

## Build order

1. Repo, Flutter skeleton, Supabase project, row-level-security policies \+ database tests  
2. `core_auth` \+ `core_union` (pairing, doors)  
3. `feat_me` \+ `core_points`  
4. `feat_couple` (calendar, nudges)  
5. Billing (Kids IAP) \+ `verifyKidsPurchase`  
6. `feat_kids`  
7. `feat_lite` \+ `core_flist`

## Art tokens

- Concept: small heart nested inside big heart ("me inside us").  
- Font: Nunito (600, 800). Wordmark lowercase `me4us`, the `4` in \#D9648A.  
- Colors: cream \#FFF8F4, blush \#F9BFCF, peach \#FFD3BE, butter \#FFF1C2, mint \#CDEBDD, lavender \#D9CCF5, dusk \#C79BC4, plum \#5B4B6B (text).  
- Section hearts: me \= blush (1 inner heart), me+you \= lavender (2), kids \= mint (3), dirty fun \= dusk (1).  
- Light and pastel. Text on pastel must pass 4.5:1 (use plum).

## Open decisions

- Kids add-on scope: per-union (one buys, both get it; needs `verifyKidsPurchase`) vs per-person. Default: per-union.  
- Unrated Flist items: Lite included by default, Intense excluded.  
- Google Calendar sync: after v0.

## Working agreements

- Do not remove sections marked with comments.  
- Both partners (Nick and Heather) approve all content. Don't invent content; use placeholders.  
- Google Play: follow sexual-content, age-rating, health-app, and Data safety policies. Verify current rules before each release.