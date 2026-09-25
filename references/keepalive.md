# Keep-alive: pacing, the deadline, and the resume hooks

Usage limits arrive as rolling windows — how many, how long and how large
depends on the account's plan. When a window is exhausted the current turn ends
and nothing more happens until it resets, unless something re-prompts the
session afterwards. That "something" is what this file sets up, and the pacing
below is what stops the run being cut off mid-edit in the first place.

**Nothing here assumes a plan.** Read the windows, measure your own cost, size
the work to fit. A batch that is comfortable on a large plan is a whole night's
budget on a small one.

## 1. Read the windows — all of them

```
mcp__ccd_session_mgmt__get_usage   →  plan.windows[]: { label, percentUsed, resetsAt, resetsIn }
```

Do not look for a window by name. Read every window the plan reports, and work
against the **tightest** one:

```
room(w)        = 100 - w.percentUsed - reserve
binding window = the w with the least room
```

`reserve` is what you refuse to spend: **10 points** by default — enough to
write the morning report, plus something left for the user's own morning. If
the user named a spend ceiling, it is a second binding limit; treat it the same
way.

Write all of it into the ledger heartbeat, e.g.
`5h 46% (resets 04:30) · weekly 29% · binding: 5h, room 44`.

Keep the machine awake: `mcp__ccd_host__request_keep_awake` at the start.

## 2. Calibrate on your own first batch

You cannot know what a batch costs on this plan, with this model, on this
codebase, until you have run one. So **make the first batch of every run a
deliberately small probe** — two tasks, one reviewer — and measure:

```
cost_per_task ≈ (percentUsed after - percentUsed before) / tasks in the probe
```

`percentUsed` is reported as a whole number, so a small probe on a large plan
can show a delta of **0**. That is "too small to measure", not "free": floor it
at **1 point per task** and re-measure across the next two batches rather than
dividing by zero.

Record it in the ledger. Every later batch is sized from it:

```
tasks = min( 6, floor( room(binding) × 0.6 / cost_per_task ) )
```

The 0.6 is headroom for the review and fix rounds, which are part of the batch
but not counted in `tasks`. Re-measure after every batch — the number drifts as
files get bigger and context gets longer, and on a small plan it drifts fast.

If `tasks` comes out at 1, that is a real answer, not a failure: a small plan
runs one careful task per batch and still ships by morning. If it comes out at
0 — or `room(binding)` is already negative — you are out of room, so do not
round up to one "small" task: go to §3 and park or wrap up.

Worked example, one real run on a Max plan: a 5-task batch with two reviewers
and a fix round cost ~14 points of the 5-hour window, so `cost_per_task ≈ 2.3`
and a window with 44 points of room supported `floor(44 × 0.6 / 2.3) = 11` →
capped at 6. On a plan with a quarter of that room, the same arithmetic gives
2 tasks. Same algorithm, different night.

## 3. Never be mid-batch when a window empties

This is the rule that makes the night continuous. A limit hit **between**
batches costs nothing — the ledger is current, the hooks fire after the reset,
work resumes. A limit hit **inside** a batch loses half-finished edits, orphans
subagents, and is what actually forces the user to intervene.

Before starting anything, check it fits twice over:

1. **Budget fit** — does the estimated cost fit in `room(binding)`? If not,
   shrink the batch (fewer tasks, cheaper models for mechanical work, one
   reviewer) until it does.
2. **Time fit** — will it finish before `resetsIn`, and before `stop-at`? A
   batch that will still be running when the window empties must be shrunk or
   deferred.

If it does not fit either way, **park** — but only if waiting can actually
help. Compare the binding window's `resetsAt` to `stop-at`:

- **Resets before `stop-at`** → park: write the ledger (phase: `parked until
  <resetsAt>`, and `busy-until` = `resetsAt` + 5 min), confirm the hooks are
  armed, end the turn.
- **Resets after `stop-at`** (the usual shape when the *weekly* window is the
  binding one) → waiting is pointless: the budget will not come back tonight.
  **Wrap up now** — write the morning report, send the PushNotification, delete
  every hook, stop. Say plainly in the report that the run ended on budget, not
  on backlog, and at what time. A user told at 23:30 that the week's budget is
  gone can still decide something; the same news at 07:00 is useless.

Park deliberately rather than squeezing in one more task. Twenty idle minutes
costs nothing; a batch cut in half costs the run. While parked, cheap work is
still fine: updating the report, re-reading code, planning the next batch.

## 4. The deadline

`stop-at` from the handshake is absolute and overrides everything above. It
is the only thing that ends the run on a night where the user does not come
back:

- Never start a batch that cannot finish before it.
- In the last stretch, do only small, certain work — then the report.
- Past it: finish the report, delete every hook, stop. Backlog left over is
  reported, not worked.
- A run that outlives its deadline is a bug. There is no "almost done"
  exception; the user set a time because unattended spend is the risk.

## 5. Hook A — same-session heartbeat (`CronCreate`)

Resumes THIS conversation, with its full context, once the window resets. It
fires only while the session is idle (never mid-turn), is session-only (gone if
the app closes), and recurring jobs auto-expire after 7 days.

```
CronCreate({
  cron: "13,33,53 * * * *",       // off-minute pattern, ~every 20-25 min
  recurring: true,
  prompt: "Goodnight Alchemist heartbeat. Read the ledger at <ABSOLUTE LEDGER PATH>. 1) If now is past its stop-at, or phase is DONE: write the morning report if it is not written, CronDelete this job and delete the other hooks, and stop. 2) If a background subagent or workflow from this run is still working: do nothing. 3) Otherwise check get_usage: take the tightest window; if the next batch fits its remaining room (minus the 10-point reserve) and finishes before both resetsIn and stop-at, update last-heartbeat and continue from the first ledger row not marked done, following the goodnight-alchemist skill. If it does not fit: update last-heartbeat and busy-until, then shrink the batch or stay parked for the next beat — unless the binding window resets after stop-at, in which case waiting cannot help, so wrap up now (report, notification, delete the hooks, stop)."
})
```

Record the job id in the ledger. `CronDelete(<id>)` when DONE.

## 6. Hook B — fresh-session safety net (scheduled task)

Survives the app being closed and reopened (a missed task runs on next launch),
but starts a NEW session with no memory — so its prompt must be fully
self-contained and must refuse to duplicate a live run.

**Make it hourly, not a one-shot.** A single `fireAt` at the first window reset
covers one moment of the night: if the run is healthy then, the task is
consumed, and a crash at 03:10 is never caught by anything — Hook A and Hook C
die with the app. Hourly, it catches an app death within the hour, all night,
and costs a handful of tiny sessions that read the ledger and exit.

```
mcp__scheduled-tasks__create_scheduled_task({
  taskId: "goodnight-<slug>-resume",
  title: "Goodnight Alchemist — resume <slug> if stalled",
  description: "Resume the overnight <slug> build from its ledger if the original session stalled.",
  cronExpression: "7 * * * *",          // hourly, LOCAL time; off-minute on purpose
  notifyOnCompletion: true,
  prompt: "You are the safety net for an overnight build the user authorised (<quote the grant: commit / push to main / deploy / credits>), which must stop at <STOP-AT, absolute with offset>. 1) Read the ledger <ABSOLUTE LEDGER PATH>. Stand down — reply 'still alive' and stop — if phase is DONE, or if its busy-until is in the future, or if last-heartbeat is under 90 minutes old. 2) If now is past stop-at and phase is not DONE: do NOT resume. Write the morning report from the ledger, delete this task and the other hooks, send one PushNotification, and stop. 3) Otherwise the run has stalled, so resume it: work ONLY in <ABSOLUTE WORKING DIRECTORY> on branch <branch>; load the goodnight-alchemist skill and follow it from the first ledger row not marked done; read <AGENTS.md / CLAUDE.md> and the memory index at <ABSOLUTE MEMORY INDEX PATH> first. Set busy-until before any long call, update last-heartbeat at every phase, and finish with the morning report and one PushNotification."
})
```

Step 2 matters more than it looks: when the app was closed all night, this task
running on next launch is the **only** thing left that can tell the user what
happened — Hook C died with the session it was created in.

If the call is **denied by the permission classifier**, do not retry it through
another tool. Add to *Pending on you*: "The fresh-session safety net was blocked
— allow `mcp__scheduled-tasks__create_scheduled_task` if you want it next
time." Hook A plus pacing still covers the common case.

## 7. Hook C — the wrap-up

A one-shot `CronCreate` (`recurring: false`, minute and hour pinned) ~20 minutes
before `stop-at`: "Finish the Goodnight Alchemist run: whatever state the ledger
is in, complete the morning report, delete the heartbeat cron and the safety-net
task, and send one PushNotification."

It is what makes `stop-at` a stop rather than a wish — in the common case, where
the session is alive, because it resumes that session with its full context and
so writes the best report available. It is **not** a guarantee: cron fires only
while the session is idle, so a run wedged mid-turn at stop-at gets no report
from Hook C. That case belongs to Hook B, which is why its step 2 writes one.

## 8. What the user needs in place (tell them once, at the handshake)

- The Claude desktop app stays **open** overnight (both resume hooks need it;
  Hook B catches up on next launch if it wasn't).
- The computer stays **awake**: the app's keep-awake preference on, and system
  sleep disabled while plugged in.
- For Hook B: an allow rule for `mcp__scheduled-tasks__create_scheduled_task`
  (and `CronCreate`, if it ever prompts) in their settings.

## 9. Anti-duplication — `busy-until`

Two sessions editing the same files is the worst outcome in this whole
protocol: lost edits, a commit mixing two runs, doubled spend. It is worse than
any amount of idle time, so the liveness test has to be conservative.

`last-heartbeat` alone cannot carry it. The master writes the heartbeat
*between* steps, but the dangerous gap is *during* one: a fan-out is a single
long tool call, the master cannot write to the ledger from inside it, and cron
cannot fire mid-turn. A 50-minute batch therefore looks exactly like a dead
session to anything watching the heartbeat.

So the master writes **`busy-until`** in the ledger immediately *before* every
long call — a fan-out (its own time-fit estimate plus 30 minutes of slack), or
a park (`resetsAt` + 5 min) — and clears it when the batch is processed.

The rule every hook obeys, in this order:

1. `now < busy-until` → someone is alive and working. Stand down.
2. `last-heartbeat` under **90 minutes** old → stand down.
3. Otherwise the run has genuinely stalled, and only then may a hook resume it.

90, not 30: a legitimate batch routinely runs longer than half an hour, and a
stale `busy-until` from a crashed session expires on its own.
