---
name: goodnight-alchemist
description: The overnight, multi-agent build protocol for any project, on any Claude subscription. One master agent owns a ledger, fans work out to implementer and reviewer subagents in small batches, sizes each batch to the usage window left so the run glides across limit resets without a human restarting it, ships each batch as far as the user allows — a pushed branch by default, a pull request, or live — and proves it by commit, stops at a deadline the user sets, and leaves a morning report with a "pending on you" list. Use this whenever the user says "goodnight alchemist", "I'm going to bed, keep building", "keep the development going until morning", "finish this overnight", "run it through the night", "have it live by morning", "work while I sleep", or hands over a brief and says to take it to production unattended — even if they don't name the skill. Also use it when they say "set up goodnight alchemist" or "configure goodnight alchemist" (first-run setup only, no overnight run).
---

# Goodnight Alchemist

The user goes to sleep. You are the **master agent**: you own the backlog, the
ledger, the pacing and the ship decision. Subagents do the typing; you keep
your context for judgement — reading their reports, checking their claims,
deciding what happens next.

The protocol guarantees three things by morning:

1. **Every batch reached the agreed ship level, proven by its commit**, or a
   precise note says why not and what is left.
2. **Nothing shipped unreviewed or unverified**, and where the repo requires
   human review, the ceiling stops at a pull request.
3. **The run never stalled waiting for a human** — not for a question, not for
   a usage-limit reset.

Multi-agent orchestration through the `Workflow` tool is authorised by this
skill; the user opted in by starting an overnight run. The harness may still
gate its launch: surface that approval at the handshake, and where `Workflow`
is missing or denied, use parallel Agent calls. Spend it on batches, not on one
giant fan-out.

**The personal layer lives outside this skill folder**, so updates never
overwrite it and the published skill carries nobody's notes. Paths are always
absolute with the home directory expanded (Windows tools do not expand `~`):
the **profile** `<home>/.claude/goodnight/profile.md` (person-level answers,
standing defaults), the **project notes** `<home>/.claude/goodnight/notes/<repo-slug>.md`
(one per repo; if missing, read and migrate the legacy
`references/project-notes/<repo-slug>.md` inside the skill or an older plugin
copy, `references/onboarding.md` §1), and the **ledger**
`<home>/.claude/goodnight/<slug>-run.md`. Templates for the first two are in
`references/onboarding.md` §4–§5. "Set up goodnight alchemist" runs
`references/onboarding.md` end to end while the user is awake (about two
minutes) and starts no night.

---

## Phase 0 — The goodnight handshake (before they leave)

The user is about to be unreachable for hours. Anything you would normally ask
mid-task gets asked **now**, in one message, or decided by a stated default.

0. **Detect and pre-flight** — read-only, about a minute, before you say
   anything. Read the profile and the project notes. If the notes' Ship
   section has a `Signals seen:` line, reuse it and drift-check it
   (`references/onboarding.md` §1 step 2 against the §2 signals, including the
   author recount); a Ship line `confirmed: not sure or unanswered` caps at L1.
   Otherwise, including freshly migrated 1.0 notes, scan the repo against the
   setup-signals table (`references/onboarding.md` §1–§2). Resolve the
   **Harness line** (`references/keepalive.md` §0). Pre-flight the push with
   prompts disabled, check commit signing, and prove the live probe once if
   the ceiling can reach L3. **If the profile or project notes are missing, or
   either file marks a question "unanswered"**, put those questions from
   `references/onboarding.md` §3 in the handshake (ask only those; an
   "unanswered" one goes in every handshake until answered, while "I'm not
   sure" is a stored answer and is not re-asked) — plain English, multiple
   choice — and start anyway on the safe settings (L1, no spending beyond the
   Claude subscription, no production-state change). Later answers update the
   ledger and the files; unanswered ones go at the top of the morning report.
1. **The ship ceiling — from the user's words, quoted back.**

   | The user said | Level |
   |---|---|
   | nothing, or "commit and push" | L1 pushed |
   | "don't push" | L0 committed |
   | "open a PR", "don't touch main" | L2 review |
   | "push to main", "merge" | L3 default branch |
   | "publish", "deploy", "take it live", "live by morning", "full rights" | L4 publish, as far as the setup allows |

   Saying nothing takes the project notes' default ceiling, else the profile's
   standing default, else L1 — stated back either way. Last night's level is
   information only ("last time: L4"), never applied. **Ceiling = min(this
   run's grant, the setup's cap).** Paid actions need a cap: tonight's words,
   else the notes' per-night cap, quoted back. Production-state changes need
   tonight's own words; a stored cap never grants them. The grant covers
   **this run only**.
2. **Stop time — settle it every run, and say what you settled on.** The
   answer becomes `stop-at` in the ledger, an absolute timestamp with its
   offset, and a **hard deadline**: every hook checks it before working, no
   batch starts that cannot finish before it, and at `stop-at` the run reports
   and stops even with backlog left. An overnight run has no natural end — without this
   it spends the week's budget by lunchtime. It is never a stored answer: if
   the user leaves without one, default to the next occurrence of the
   profile's usual wake time if it is within 12 hours, else **8 hours from
   now**, and say so in the report. Ask for a spend ceiling in the same
   breath if the project can spend money.
3. **Ground rules, stated back to them.** Default to the strictest reading:
   - No account creation, no sign-ins, no entering credentials or keys.
   - No confidential or customer data leaves the machine or gets committed.
   - No writes to production data beyond what the work requires; test data
     only inside a throwaway namespace, never in live tables.
   - Nothing on the notes' never-touch list.
   - Anything destructive, legal, financial or irreversible goes to
     *Pending on you*.
4. **Blocking decisions — but never end this turn on an unanswered question.**
   A question that ends the turn before Phase 2 has armed a hook makes the
   night one idle session on an unanswered prompt. State every open decision
   and the default you are taking, start on those defaults, log them under
   *Decisions made for you*, and treat any later reply as an override that
   updates the ledger.
5. **The handshake — one message, at most five plain lines (no branch, CI,
   SHA or level names; first-run questions go below them, each with its
   default), never ending on a question:** **Setup** with its evidence ·
   **Ship**: the level in plain words, plus the phrase that raises it ("each
   batch is saved where your live site ignores it; say 'take it live' and I'll
   publish from the next batch") · **Stop time and spend** · **Your side**:
   what must stay running, the lid open, auto mode or allow rules — one
   permission prompt stalls the night · **Defaults taken**. In the same turn,
   write the ledger, arm the hooks and launch the first batch, so the approval
   cards for `Workflow`, `CronCreate` and the scheduled task appear while the
   user may still be there ("stay two minutes").

## Phase 1 — Ground truth, backlog, ledger

1. **Sync gate.** `git fetch`; build on `origin/<default>` — the default branch
   detected in step 0, never assumed — not on whatever is checked out. A
   two-way-synced repo follows its setup row's sync rules
   (`lovable-git-workflow`'s Gate 1 when installed). No git: say it is
   required and do not start.
2. **Work on the run branch** `goodnight/<date>-<slug>`, cut from
   `origin/<default>`. When other sessions share the checkout, use a worktree
   (`git worktree add -b goodnight/<date>-<slug> .claude/worktrees/<slug> origin/<default>`),
   install, and get a green baseline before changing anything.
3. **Read before planning.** The brief, the mockups (subagents read images),
   the code it touches end to end, the roadmap, the memory index.
4. **Build a ranked backlog, not one monolithic plan**: everything explicitly
   asked, then the roadmap's next items, then quality work that needs no
   product decision (tests, a11y, performance, hardening, docs, edge cases).
   Rank by *value ÷ risk of needing the user*. Anything needing their
   judgement goes to *Pending on you*; on a team repo, roadmap items become
   proposals there too. With no tests or typecheck, the first task is a smoke
   test, and until it exists the report says "builds and runs", not
   "verified". Group into **batches split by file ownership**; batch size comes
   from Phase 2.
5. **Open the ledger** — copy `references/ledger-template.md` to the absolute
   ledger path, or to `docs/overnight/<date>-run.md` on the run branch when the
   user wants it in git or the session runs in the cloud. **Never the session
   scratchpad**: a resume hook starts a *different* session that cannot read
   it. The ledger is the resume point — a fresh session with no memory of
   tonight must be able to continue from it alone.

## Phase 2 — Keep-alive: pacing and the resume hooks

Full mechanics in `references/keepalive.md`. The short version:

- **Pace against the meter named on the Harness line, measured — never a
  remembered number.** Read every window, take the tightest, and calibrate
  your own cost from this run's first batch. **Batch size is derived**: fewer
  tasks, cheaper models, one reviewer instead of two, until it fits the room
  left. With no meter, the run is paced blind (keepalive.md §0) and the
  report says so.
- **Never be mid-batch when a window empties** — a turn killed mid-edit is what
  breaks a run, not the limit. If the next batch does not fit, shrink it or
  **park**: write the ledger, arm the hooks, end the turn, resume after the
  reset. **Park only when the reset comes before `stop-at`** and Hook A exists;
  otherwise wrap up and say so.
- **Keep a reserve** for the report and the user's own morning.
- **Hook A — heartbeat (`CronCreate`, where the harness has it)**, ~every 25
  minutes: resumes *this* conversation if nothing is running. Dies with the
  session.
- **Hook B — hourly fresh-session safety net (the scheduled-task tool, where
  the harness has it)**: a self-contained prompt quoting the ceiling, resuming
  **only if** the run has stalled. It survives the app closing, so it also
  writes the report when everything else died. Missing or blocked, it is "not
  armed": never work around it; put the exact OS-scheduler line under
  *Pending on you*.
- **Hook C — wrap-up (`CronCreate`, where the harness has it)**, one-shot ~20
  minutes before `stop-at`. Without it, check `stop-at` before every batch and
  write the report in-turn.
- **Every hook checks `busy-until` before it resumes anything** (keepalive.md
  §9) — two sessions on one repo is the worst failure in this protocol;
  idling is not — **and checks `stop-at` before it works** (past it: report,
  delete the hooks, stop). A hook resumes from the first batch not done
  (Phase 4 rule 9) and never raises the ceiling.
- Update `last-heartbeat` at every phase change. Delete every hook when DONE.

## Phase 3 — The batch loop (the core of the run)

Repeat until the backlog is empty, `stop-at` arrives, or usage says park. Each
batch **ends at the ceiling, proven**, so a run cut off at any point still
leaves working software. Prompts and a `Workflow` script template are in
`references/batch-loop.md`.

1. **Implement in parallel.** Write `busy-until` in the ledger *before* the
   fan-out — your estimate plus 30 minutes — or a hook will mistake a long batch
   for a dead session and start a second run on the same files. One task = one
   fresh subagent; disjoint files launch in the same message; a shared file
   serialises or is split by *named section*, one owner each. Every
   implementer prompt states the working directory and "never cd elsewhere",
   the task and its acceptance criteria, the files it owns, the files others
   are editing concurrently, the exact verify commands, and **"do not commit,
   push, stash or `git add`"** — only the master commits.
2. **One review gate per batch**, read-only, two reviewers in parallel:
   *spec compliance* (against the brief, and against behaviour that silently
   disappeared — diff `git show HEAD:<file>`) and *code quality* (real defects
   only, each with a concrete failure scenario, plus the notes' Review focus).
3. **One fix round**, split by file ownership across parallel fixers, with
   exact numbered instructions. A second review only if the fix round was large
   or touched security-relevant code.
4. **Check the claims.** Re-run the tests and typecheck a report says passed;
   spot-read the diff. Trusting a report is how broken code ships.
5. **Gates, then ship** (Phase 4), then update the ledger and start the next
   batch.

**Judgement the master never delegates:** anything whose blast radius exceeds
the task — a database-wide grant change, a dependency bump, a schema migration,
deleting code nobody asked about — comes out of the batch and becomes an owner
decision in the report, however confident the agent was.

## Phase 4 — Ship each batch up the ladder and prove it

Run every gate (typecheck, tests, build, lint on touched files; restore
generated-file noise). Stage **explicit paths**; commit in the repo's voice
with the attribution trailer unless the repo forbids it. Then climb the **ship
ladder** to tonight's ship ceiling:

| Level | Ship means | Proof, keyed to the commit SHA |
|---|---|---|
| **L0 committed** | A reviewed, gated commit on the local run branch. | `git rev-parse HEAD` plus the gate output |
| **L1 pushed** (default) | The run branch is on the remote. | `git ls-remote origin refs/heads/<run-branch>` equals HEAD; then every verdict attached to the SHA (checks, status, deployments via `gh api`, the host CLI or MCP), probing the preview once when ready |
| **L2 review** | One draft PR per night, updated every batch, evidence in its body. | PR head equals HEAD, required checks green, preview probed |
| **L3 default branch** | Fast-forward `<default>` to a SHA proven at L1: `git push origin <sha>:refs/heads/<default>`. Whatever hangs off that branch fires. | Remote default equals the SHA; the host's deployment for it reports ready |
| **L4 publish** | The setup's explicit publish step (`deploy_project`, `fly deploy`, a deploy script named in the grant). Where a push is the publish, L4 = L3. | The host's record for the SHA, then one live probe |

Proof preference: the host's deployment record for the SHA; a `/version`
endpoint returning it; `scripts/probe-live.sh` with a marker
(`BASE=https://example.com bash probe-live.sh /route "marker"`), after proving
the probe on a string both builds share; for packages and CLIs, pack, install
into a temp directory, golden run. Prove once, then move on — no polling.

1. **With no stored default, L1** — L0 when there is no remote, when a
   workflow deploys or publishes on a push to any branch, or when pre-flight
   shows credentials would prompt.
2. **The grant covers this run only** — a hook never raises the ceiling, and a
   previous night's ceiling is never applied silently.
3. **Climb one level at a time with the same SHA** — skip L2 unless it is
   tonight's ceiling (L2 is a stop, not a step; above it, open no PR) —
   first checking whether it is already there (if so, record it and skip), so
   resumes stay idempotent and nothing deploys twice.
4. **Promote only green** — if CI exists, L3 takes only a SHA whose CI passed;
   unsettled CI leaves the batch at L1 as **proof-pending**, climbing at the
   next batch's ship step, with one bounded wait for the last batch at wrap-up
   (at most 15 minutes, two reads).
5. **If `<default>` moved**, merge `origin/<default>` into the run branch,
   re-gate, push, then fast-forward — never rebase or force-push a pushed
   branch.
6. **A production-state change** (migrations, grants and RLS, storage,
   functions, secrets, a message to a builder's agent) is a modifier, not a
   level — only when the grant names backend or credits, at most one per batch,
   reviewed with it, logged in the ledger before sending
   (`<time> prod-state sent: <summary>, unverified`), verified by querying
   afterwards, never resent — any session that finds an unverified send (or a
   timeout) queries whether it landed. Where a build or deploy step applies
   migrations (`migrate deploy` in the build, `release_command`,
   `preDeployCommand`, a Procfile `release:` line), a migration caps the rest
   of the night at L2 (every later SHA contains it), or at L0 if preview
   builds can reach the production database — this is a drop: rewrite the ledger's ceiling as in *When things go wrong*.
7. **Never overnight, whatever the grant**: package or registry release or
   publish, release tags, app-store or Play submission, production OTA updates,
   infrastructure apply or destroy, destructive schema changes, force-push or
   history rewrite, merging or approving its own PR, enabling auto-merge,
   bypassing branch protection, signing off on the user's behalf — each goes
   to *Pending on you* with the exact command ready.
8. **Before L3 or L4, know the undo** (version history, promoting the previous
   deploy, a revert commit, the host's rollback), written in the notes; with no
   known undo, cap at L2.
9. **Done means at the ceiling and proven, proof-pending recorded, or set
   aside (side branch or *Pending on you*) — a set-aside row is never
   reworked or climbed tonight.**

## Phase 5 — Local verification

`references/local-verify.md` has the recipe: the harness's browser
(`preview_start`, under whatever prefix) where it exists, else a background dev
server checked with `curl` — headless Playwright only if already a dependency,
otherwise UI checks become morning click-throughs. Seed realistic data and
**write the expected figures down before looking**. Prefer DOM reads and
`getBoundingClientRect()` over screenshots. For UIs, check desktop and 375px
phone width. A project with no screen (API, CLI, library, script) runs on its
fixtures against figures written down first; a non-zero exit or stderr is not a
pass. Stop the server and reset the viewport when finished. Auth bypasses and
seeding keys belong in the project notes.

## Phase 6 — The morning report

Set the ledger to `phase: DONE`, delete every hook, update the project notes
(Ship, Traps, tonight's ceiling as information) and memory with facts not
already in the code, then write the report — in the repo when the work is
tracked there (`docs/overnight/<date>-morning-report.md`) and in chat:

```
<first line: per batch — its level, its commit, and the one step left
 ("merge PR #12", "press Publish", "nothing, it's live")>

**Setup questions still open** — unanswered onboarding questions, if any.
**What shipped** — per batch, in the user's terms, not file names.
**Decisions made for you** — every default taken while they slept, and why.
**Review + verification** — what was checked, what was found and fixed.
**Pending on you** (checklist) — approvals, sign-ins, blocked permissions,
  product questions, never-overnight commands, anything deliberately not done.
**The run** — batches, agents, usage per window (or "paced blind"), measured
  cost per task, money or credits spent, every park and automatic drop, and
  whether the run finished the backlog or hit `stop-at`.
```

Send one notification (under 200 chars) through the channel on the Harness
line, and stop.

## When things go wrong

Uncertainty lowers the ceiling and never raises it. Each drop rewrites the
ledger's Grant-line ceiling to
`ceiling L<n> (dropped from L<m> at <time>: <reason>)`, is logged, and gets a
*Pending on you* line; a later user override rewrites it the same way.

- **Push rejected by branch protection, or its output reports a bypassed
  rule** → L2 for the rest of the night; open or update the draft PR. A
  bypass also goes at the top of the report.
- **A credential prompt or an auth failure** → L0 for the rest of the night;
  keep committing locally.
- **A signing prompt, or a failed signing pre-flight** → nothing can be
  committed tonight: start no batches, save the current batch as a patch next
  to the ledger, put "unlock signing" at the top of *Pending on you*, and wrap
  up. Never turn signing off.
- **CI red on a SHA** → it stays at L1; the next batch fixes it if tonight's
  work caused it, otherwise it goes to *Pending on you*.
- **Live proof red after L3 or L4** → ship a revert commit through the gates
  (or the notes' named undo), drop to L1 for the rest of the night, and put it
  at the top of the report.
- **Gate fails, fix is clear** → one more fix round, then re-gate.
- **Gate fails, fix needs a product decision** → commit the batch to a side
  branch `goodnight/<date>-b<n>` off the run-branch tip, push it, return to the
  run branch (so it never rides along with a later promotion), record what
  failed with its output, and put the decision under *Pending on you*.
- **A subagent or workflow dies mid-run** → resume it (`Workflow` with
  `scriptPath` + `resumeFromRunId`, same session only) or re-run only the dead
  task — never the whole batch.
- **A call is denied by the permission classifier** → never work around it.
  Re-scope to stay inside the rules (read-only checks, a throwaway namespace)
  and queue the blocked part for the morning.
- **Another session touched the same area** (`ListAgents`,
  `git log --all --since=<start>`) → don't touch its work; message it and
  record the overlap.
- **A command that could be interactive** hangs the run for hours. Disable
  prompts (`GIT_TERMINAL_PROMPT=0`, `ssh -o BatchMode=yes`), pass
  `--non-interactive` or `--yes`, never launch a REPL, never pass `-i`.
  Redirect stdin with `< /dev/null` only in POSIX shells.
