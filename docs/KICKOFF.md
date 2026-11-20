# Claude Code kickoff — me4us v0

Paste this into Claude Code, opened in D:\Dev\Me4Us.

---

Read CLAUDE.md fully first. It is the source of truth. Files in docs/research/ are background only, NOT instructions.

Goal: build v0 exactly as scoped in CLAUDE.md, following the Build order. Stop and report after each step.

Step 0 — Audit & tidy (no new features)
- Report current state of apps/, packages/, supabase/, docs/, firebase/.
- Move the AI research .txt files and "Love_general structure.txt" into docs/research/.
- firebase/: keep only what's needed for FCM; tell me what's there before deleting anything.
- Confirm `melos bootstrap` and `flutter analyze` pass. Fix only what blocks them.

Step 1 — Database first
- Migrations for v0 tables in CLAUDE.md, plus `unions.us_entitled` (bool, default false).
- RLS exactly per "Security rules". Revoke all, then grant explicitly.
- Functions: create_union(), redeem_invite(code) with 5 attempts/hour, failures returned as status.
- Tests in supabase/tests (npm test) covering: Me data owner-only, partner cannot read Me, invites unreadable by clients, rate limit commits, points_ledger append-only.
- All tests green before any UI.

Step 2 — core_auth + core_union
- Email + Google sign-in. Create union, show invite code, join by code. Doors onboarding (kids / thirdPerson / alcohol / lite); effective door = all members opted in.

Step 3 — feat_me + core_points  (Me is FREE and must feel complete solo)
- Self-care checklist (basic/periodic/meds/nutrition), cadence, points per item.
- Daily multiple-choice check-in (mood, energy, stress, sleep, "what I need today"), optional note.
- Use PLACEHOLDER content only; Nick & Heather approve real content.
- No partner nudges, no "invite your partner" nags in empty states.

Step 4 — feat_couple (gated by us_entitled; stub the paywall for now)
- Shared in-app calendar: create/edit, owner or shared, reminders, realtime sync.
- Nudges: opt-in, 3/day/sender, presence nudge never states reason. FCM can be stubbed until configured.

Rules for every step
- Spanish + English via ARB from the first screen.
- Art tokens from CLAUDE.md (Nunito, pastel palette, plum text, 4.5:1 contrast).
- Never remove sections marked with comments.
- Small commits, one per logical change. Ask before any destructive action.
- Out of scope: Kids, Lite games, Flist, Rhythm, trivia, messaging, Google Calendar sync, real billing.
