# <Job name> — overnight run ledger

Working directory: <absolute path (worktree or repo)>
Branch: <branch> (from origin/main <sha>)
Brief / plan: <paths>
Project notes: references/project-notes/<repo-slug>.md
Deploy: <how this project publishes, and the live URL>

Grant (quoted from the user, <date time>): "<their words>"
→ commit: yes/no · push to main: yes/no · deploy: yes/no · paid actions: <cap or none>

**stop-at: <absolute timestamp with offset>** — hard deadline. Asked at the
handshake, or defaulted to 8h from <start> and reported as a default. No batch
starts that cannot finish before it; at stop-at the run reports and ends.

Ground rules: <the strict defaults agreed at the handshake — data, sign-ins,
production writes>

Hooks: A heartbeat cron <id or "not armed: reason"> · B scheduled task
<taskId or "blocked: reason"> · C wrap-up cron <id> at <wake time>

## Status (update at EVERY phase change and every processed report)

last-heartbeat: <ISO time with offset>
busy-until: <ISO time with offset — written BEFORE every fan-out and every
  park; no hook resumes this run while it is in the future. Cleared when the
  batch is processed.>
usage: <every window the plan reports: label pct% (resets time)> ·
  binding: <label>, room <100 - pct - reserve> · spend: <money/credits so far>
calibration: cost_per_task ≈ <pct points>, measured over <n> tasks → next batch
  sized at <n> tasks
phase: <what is happening now · or `parked until <resetsAt>` · or DONE — <sha>
  live, verified by <marker>>

## Backlog (ranked; move rows into batches as they are picked up)

| # | item | why it is safe to do unattended |
|---|---|---|
| 1 | | |

## Batches

| batch | tasks | review | fixes | gates | shipped (sha / bundle) |
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
