---
name: goodnight-alchemist
description: The overnight, multi-agent build protocol for any project, on any plan. One master agent owns a ledger, fans work out to implementer and reviewer subagents in small shippable batches, measures what its own work costs and sizes each batch to fit the usage window left, so the run glides across limit resets without a human ever restarting it, stops at a deadline the user sets, and leaves a morning report with a "pending on you" list. Use this whenever the user says "goodnight alchemist", "I'm going to bed, keep building", "keep the development going until morning", "finish this overnight", "run it through the night", "have it live by morning", "work while I sleep", or hands over a brief and says to take it to production unattended — even if they don't name the skill.
---

# Goodnight Alchemist

The user goes to sleep. You are the **master agent**: you own the backlog, the
ledger, the pacing and the ship decision. Subagents do the typing; you keep
your context for judgement — reading their reports, checking their claims,
deciding what happens next.

The protocol guarantees three things by morning:

1. **The work shipped**, or a precise note says why not and what is left.
2. **Nothing shipped unreviewed or unverified.**
3. **The run never stalled waiting for a human** — not for a question, not for
   a usage-limit reset.

Multi-agent orchestration through the `Workflow` tool is authorised by this
skill; the user opted in by starting an overnight run. Spend it on batches,
not on one giant fan-out.

**First, project notes.** If `references/project-notes/<repo-slug>.md` exists,
read it before planning — it holds that repo's traps, gates and deploy steps.
If it does not, write one as you learn them (template at the bottom of this
file) so the next run starts smarter. `references/project-notes/README.md` has
the template and a worked example.

---

## Phase 0 — The goodnight handshake (before they leave)

The user is about to be unreachable for hours. Anything you would normally ask
mid-task gets asked **now**, in one message, or decided by a stated default.

1. **Authorisation scope — in writing, in chat.** Commit? Push to `main`?
   Deploy or publish? Paid actions (Lovable credits, API spend) and a rough
   cap? If they already said it ("you have full rights, use credits
   judiciously"), quote it back in one line and go. The grant covers **this
   run only**.
2. **Stop time — settle it every single run, and say out loud what you settled
   on.**
   "Until what time should I keep going?" An overnight run has no natural end:
   if the user does not come back at eight, nothing stops it from spending the
   whole week's budget by lunchtime. The answer becomes `stop-at` in the ledger,
   an absolute timestamp with its offset, and it is a **hard deadline** — every
   hook checks it before doing anything, no batch is started that cannot finish
   before it, and at `stop-at` the run writes its report and stops even with
   backlog left. If the user has already gone without answering, default to
   **8 hours from now**, say so in the report, and stop then regardless.
   Ask for a spend ceiling in the same breath if the project can spend money.
3. **Ground rules, stated back to them.** Default to the strictest reading:
   - No account creation, no sign-ins, no entering credentials or keys.
   - No confidential or customer data leaves the machine, and none of it gets
     committed.
   - No writes to production data beyond what the work requires; test data
     only inside a throwaway namespace, never in live tables.
   - Anything destructive, legal, financial or irreversible goes to
     *Pending on you*.
4. **Blocking decisions — but never end this turn on an unanswered question.**
   Skim the brief for genuine ambiguity. Asking is fine *only if you will still
   be running afterwards*; a question that ends the turn before Phase 2 has
   armed a single hook means the night is one idle session on an unanswered
   prompt. So state every open decision and the default you are taking —
   stop-at included, 8 hours from now if they said nothing — in one chat line,
   start immediately on those defaults, log them under *Decisions made for
   you*, and treat any later reply as an override that updates the ledger.
5. **Prerequisites** (Phase 2): the Claude app stays open, the machine stays
   awake. One line, then say goodnight and start.

## Phase 1 — Ground truth, backlog, ledger

1. **Sync gate.** `git fetch`; compare the current branch **and** `main`
   against `origin/main`. Build on `origin/main`, never on whatever branch
   happens to be checked out. In a Lovable or otherwise two-way-synced repo,
   follow the `lovable-git-workflow` skill's Gate 1.
2. **Isolate when other sessions share the checkout.** A worktree
   (`git worktree add -b <slug> .claude/worktrees/<slug> origin/main`),
   install, and a green baseline before changing anything. Working directly in
   the repo is fine only when you are the sole writer tonight.
3. **Read before planning.** The brief, the mockups (subagents read images),
   the code it touches end to end, the roadmap, the memory index.
4. **Build a ranked backlog, not one monolithic plan.** An overnight user
   usually says "keep going, even if it's not in the plan" — so the backlog is:
   everything explicitly asked, then the roadmap's next items, then quality
   work that needs no product decision (tests, a11y, performance, hardening,
   docs, edge cases). Rank by *value ÷ risk of needing the user*. Anything
   needing their judgement goes to *Pending on you* instead of being guessed.
   Group into **batches split by file ownership**, so the tasks inside a batch
   can run in parallel. How many tasks fit in one batch is decided in Phase 2
   from measured cost, not guessed here.
5. **Open the ledger** — copy `references/ledger-template.md` to
   `~/.claude/goodnight/<slug>-run.md`, or `docs/overnight/<date>-run.md` when
   the user wants it in git. **Never the session scratchpad**: the resume hooks
   start a *different* session, which cannot read the old one's private temp
   directory, and the run would have no resume point at all. The ledger is that
   resume point — a fresh session with no memory of tonight must be able to
   continue from it alone.

## Phase 2 — Keep-alive: pacing and the resume hooks

Full mechanics in `references/keepalive.md`. The short version:

- **Pace against the plan you actually have, measured — never against a
  remembered number.** `mcp__ccd_session_mgmt__get_usage` reports whatever
  windows this account has; read them all, take the tightest, and calibrate
  the cost of your own work from the first batch of this run. A batch that fits
  a Max window is three nights' budget on a smaller plan, so **batch size is
  derived, not fixed**: fewer tasks, cheaper models, one reviewer instead of
  two, until the batch fits the room that is left.
- **The rule that keeps the night continuous: never be mid-batch when a window
  empties.** A turn killed in the middle of an edit is what actually breaks a
  run — not the limit itself. If the next batch does not fit in what remains,
  either shrink it to fit or **park**: write the ledger, arm the hooks, end the
  turn, and resume just after the window resets. Idling for twenty minutes is
  cheaper than losing a half-finished batch. **Park only when the reset comes
  before `stop-at`** — when the binding window is the weekly one, it usually
  does not, and waiting all night for budget that returns on Tuesday helps
  nobody. Wrap up and say so instead.
- **Always keep enough in reserve to write the report** and to leave the user
  some of their own budget for the morning.
- **Hook A — same-session heartbeat (`CronCreate`)**, every ~25 minutes:
  re-reads the ledger and continues if nothing is running. Resumes *this*
  conversation with its full context once the window resets. Dies with the app.
- **Hook B — fresh-session safety net
  (`mcp__scheduled-tasks__create_scheduled_task`)**, **hourly**, with a fully
  self-contained prompt that resumes **only if** the run has genuinely stalled.
  It is the one hook that survives the app being closed, so it is also the one
  that writes the report when everything else died with the session. If the
  permission classifier blocks it, do not work around it — note it under
  *Pending on you*.
- **Hook C — wrap-up**, a one-shot ~20 minutes before `stop-at` that writes the
  report and sends the notification.
- **Every hook checks `stop-at` first.** Past it: finish the report, delete the
  other hooks, stop. A run that outlives its deadline is a bug, not diligence.
- **Before any hook resumes anything, it checks `busy-until`** (§9). Two
  sessions on one repo is the worst failure in this protocol; idling is not.
- Update `last-heartbeat` at every phase change. Delete every hook when DONE.

## Phase 3 — The batch loop (the core of the run)

Repeat until the backlog is empty, `stop-at` arrives, or usage says park. Each
batch ends **shipped**, so a run cut off at any point still leaves working
software. Batch size comes from the calibration in Phase 2, not from a fixed
number. Prompts and a `Workflow` script template are in
`references/batch-loop.md`.

1. **Implement in parallel.** Write `busy-until` in the ledger *before* the
   fan-out — your time estimate plus 30 minutes — or a resume hook will mistake
   a long batch for a dead session and start a second run on the same files.
   Then: one task = one fresh subagent. Tasks with disjoint files launch in the
   same message; anything touching the same file serialises. A shared file is split by *named section*, one owner each.
   Every implementer prompt states: the working directory and "never cd
   elsewhere", the task and its acceptance criteria, the files it owns, the
   files others are editing concurrently, the exact verify commands, and
   **"do not commit, push, stash or `git add`"** — only the master commits.
2. **One review gate per batch**, read-only, two reviewers in parallel:
   *spec compliance* (against the brief, and against behaviour that silently
   disappeared — diff `git show HEAD:<file>`) and *code quality* (real defects
   only, each with a concrete failure scenario).
3. **One fix round**, split by file ownership across parallel fixers, with
   exact numbered instructions. A second review round only if the fix round
   was large or touched security-relevant code.
4. **Check the claims.** Re-run the tests and typecheck a report says it
   passed; spot-read the diff. Agents are wrong often enough that trusting a
   report is how broken code ships.
5. **Gates, then ship** (Phase 4), then update the ledger and start the next
   batch.

**Judgement the master never delegates:** anything a fixer proposes whose blast
radius exceeds the task — a database-wide grant change, a dependency bump, a
schema migration, deleting code nobody asked about — comes out of the batch
and becomes an owner decision in the report, however confident the agent was.

## Phase 4 — Ship each batch and prove it

1. Run every gate: typecheck, tests, build, lint on touched files. Restore
   generated-file noise rather than committing it.
2. Stage **explicit paths**; commit in the repo's voice with the attribution
   trailer. `git fetch` → ahead/behind must read `N 0`; rebase unpushed work
   if the remote moved, and re-run the gates. Never force-push, never rewrite
   what is already pushed.
3. Push, then publish the way the project publishes (`deploy_project`, CI, a
   host command). **Push is not publish.**
4. **Prove it is live once, then move on** — no polling. Fetch the deployed
   asset and grep for a marker only the new code contains;
   `scripts/probe-live.sh` does that for a static bundle
   (`BASE=https://example.com bash probe-live.sh /route "marker"`). Prove the
   probe first with a string both the old and new builds share.
5. **Backend and paid work** (schema, RLS, storage, edge functions, secrets,
   agent credits) is batched into **one** message per batch, sent only when
   genuinely needed, and verified by querying the result afterwards. If such a
   message times out, **do not resend it** — check whether it landed. Duplicate
   backend work is expensive and sometimes destructive.

## Phase 5 — Local verification

`references/local-verify.md` has the general recipe: start the dev server with
`preview_start`, seed realistic data, and **write the expected figures down
before looking at the screen**. Prefer DOM reads and `getBoundingClientRect()`
over screenshots (screenshots time out when the app window is behind others).
Check desktop and 375px phone width. Stop the server and reset the viewport
when finished. Auth bypasses, seeding keys and permission-preview rules are
per-project — they belong in the project notes.

## Phase 6 — The morning report

Set the ledger to `phase: DONE`, delete every hook, update memory with project
facts that are not already in the code, then write the report — in the repo
when the work is tracked there (`docs/overnight/<date>-morning-report.md`) and
in chat:

```
<one line: what is live, commit shas, what the user will see>

**What shipped** — per batch, in the user's terms, not file names.
**Decisions made for you** — every default taken while they slept, and why.
**Review + verification** — what was checked, what was found and fixed.
**Pending on you** (checklist) — approvals, sign-ins, blocked permissions,
  product questions, anything deliberately not done.
**The run** — batches, agents, usage consumed per window, measured cost per
  task, money or credits spent, every park and how long it waited, whether the
  run finished the backlog or hit `stop-at`.
```

Send one `PushNotification` (under 200 chars) and stop.

## When things go wrong

- **Gate fails, fix is clear** → one more fix round, then re-gate.
- **Gate fails, fix needs a product decision** → do not ship. Leave the branch
  pushed (not `main`), record exactly what failed with its output, and put the
  decision under *Pending on you*.
- **A subagent or workflow dies mid-run** (API overload, timeout) → resume it
  (`Workflow` with `scriptPath` + `resumeFromRunId` replays the cached stages)
  instead of re-running the whole batch.
- **A call is denied by the permission classifier** → never work around the
  denial. Re-scope the task to stay inside the rules (read-only checks, a
  throwaway namespace) and queue the blocked part for the morning.
- **Another session touched the same area** (`ListAgents`,
  `git log --all --since=<start>`) → don't touch its work; message it and
  record the overlap.
- **A command that could be interactive** will hang the run for hours.
  Redirect stdin (`< /dev/null`), never launch a REPL, never pass `-i`.

## Project notes template

Create `references/project-notes/<repo-slug>.md` on the first run in a repo:

```md
# <repo> traps (read before planning)

## Git / deploy
- branch to build from, who else writes here, what "published" means, how to prove it
## Verify commands
- typecheck / tests / build / lint, and any checklist doc
## Local run
- dev server command and port, auth bypass, seeding keys, fixture data
## Traps
- one line each, learned the hard way
## Costs
- what spends money or credits here, and the cap
```
