# <Job name> — overnight run ledger

Working directory: <absolute path (worktree or repo)>
Run branch: goodnight/<date>-<slug> (from origin/<default> <sha>)
Brief / plan: <paths>
Profile / notes: <home>/.claude/goodnight/profile.md · <home>/.claude/goodnight/notes/<repo-slug>.md
  (absolute, home expanded)
Ship: L<n> — <what it does here> · proof: <cmd> · setup: <rows>
  (one Ship line per deployable)

Grant (quoted from the user, <date time>): "<their words>"
→ commit · ceiling L<n> (of L0–L4: the lower of the grant and the setup's cap; every drop or user override rewrites it as `ceiling L<n> (dropped from L<m> at <time>: <reason>)`) · prod-state: <none|named> · paid cap: <cap or none>

**stop-at: <absolute timestamp with offset>** — hard deadline. Asked at the
handshake, or defaulted to <the next occurrence of the profile's wake time, if
within 12 hours | 8h from <start>> and reported as a default. No batch
starts that cannot finish before it; at stop-at the run reports and ends.

Ground rules: <the strict defaults agreed at the handshake — data, sign-ins,
production writes>

Harness: meter … · A … · B … · C … · awake … · browser … · notify … · fan-out …

Hooks: A heartbeat cron <id or "not armed: reason"> · B scheduled task
<taskId or "not armed: reason"> · C wrap-up cron <id or "not armed: reason"> at <time>

## Status (update at EVERY phase change and every processed report)

last-heartbeat: <ISO time with offset>
busy-until: <ISO time with offset — written BEFORE every fan-out and every
  park; no hook resumes this run while it is in the future. Cleared when the
  batch is processed.>
usage: <every window the meter reports: label pct% (resets time), or "blind"> ·
  binding: <label>, room <100 - pct - reserve> · spend: <money/credits so far>
calibration: cost_per_task ≈ <pct points or $>, measured over <n> tasks → next
  batch sized at <n> tasks
proof-pending: <sha · level · check still settling — or none>
phase: <what is happening now · or `parked until <resetsAt>` · or DONE — <sha>
  at L<n>, proven by <check>>

## Backlog (ranked; move rows into batches as they are picked up)

| # | item | why it is safe to do unattended |
|---|---|---|
| 1 | | |

## Batches

| batch | tasks | review | fixes | gates | shipped (sha · level · proof) |
|---|---|---|---|---|---|
| 1 | | | | | |

## Decisions made for you

- <default taken while the user slept, and why>

## Owner decisions (found, deliberately NOT applied)

- <change whose blast radius exceeded the task — what it was, why it waits>

## Pending on you (morning list)

- [ ] <approval / sign-in / product question / blocked permission>
- [ ] <anything deliberately not built, and what it needs>

## Log

- <time> <what happened, one line>
