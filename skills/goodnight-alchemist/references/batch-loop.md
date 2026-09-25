# The batch loop: fan out, review, fix, ship

A batch is the unit of the night: **N parallel tasks → one review gate → one
fix round → gates → ship**. It ends with working software at its ceiling and
proven — shipped as far as tonight's ship ceiling allows, proven by its commit
SHA — so whenever the run is cut off (usage limit, crash, morning) nothing is
half-finished.

**N is derived, never assumed.** `references/keepalive.md` §2 measures what a
task costs on this plan from the run's own first batch, and sizes every later
batch from the room left in the tightest window: `min(6, floor(room × 0.6 /
cost_per_task))`. On a large plan that lands at 5–6 tasks and eight
batches a night; on a small one it lands at 1–2 tasks and three or four
batches, with the same structure and the same guarantee. A one-task batch is a
legitimate batch — it still gets a review, still ships; zero is not — park or
wrap up (keepalive.md §2–§3).

Sizing levers, in the order to pull them when a batch does not fit: drop to one
reviewer, route mechanical tasks to a cheaper model, cut tasks. Never drop the
review entirely — unreviewed code shipping while the user sleeps is the one
failure that cannot be fixed in the morning.

## Choosing what goes in one batch

- **Split by file ownership, not by feature.** Two tasks in the same batch may
  never edit the same file. If they must, either serialise them across two
  batches or split the file by named section with one owner each.
- **Mix risk.** One substantial task plus two or three small, certain ones
  keeps the batch shippable even if the big one has to be dropped.
- **Nothing that needs the user.** If a task's acceptance criteria contain a
  product question, it belongs in *Pending on you*, not in a batch.
- **A production-state change is a modifier on the batch, not a task.**
  Migrations, grants/RLS, storage, functions, secrets and messages to a
  builder's agent (e.g. Lovable): only when the grant names backend or
  credits, at most one per batch, reviewed with the batch and sent as one
  message at its end — never one per task. Log it in the ledger
  (`<time> prod-state sent: <summary>, unverified`) before sending, and verify
  by querying afterwards; any session that finds an unverified send queries
  whether it landed and never resends.

## Fanning out with the `Workflow` tool

The workflow script is deterministic control flow; the agents inside it do the
work. Read the `workflow-authoring` skill before writing one. The shape that
fits a batch:

```js
export const meta = {
  name: 'overnight-batch-3',
  description: 'Batch 3: import hardening, CSV safety, adapter tests',
  phases: [{ title: 'Implement' }, { title: 'Review' }, { title: 'Fix' }],
}

const TASKS = [
  { key: 'import',  owns: ['src/lib/import.ts'],            prompt: `...` },
  { key: 'csv',     owns: ['src/lib/export.ts'],            prompt: `...` },
  { key: 'tests',   owns: ['src/lib/api/local.test.ts'],    prompt: `...` },
]

// Implement in parallel — disjoint files, so no worktree isolation needed.
const built = await parallel(TASKS.map(t => () =>
  agent(t.prompt, { label: `build:${t.key}`, phase: 'Implement', schema: REPORT })))

// One review gate over the whole batch (barrier is correct here: reviewers
// need the finished batch, and the fix round is split by file across it).
const reviews = await parallel([
  () => agent(SPEC_REVIEW_PROMPT,    { label: 'review:spec',    phase: 'Review', schema: FINDINGS }),
  () => agent(QUALITY_REVIEW_PROMPT, { label: 'review:quality', phase: 'Review', schema: FINDINGS }),
])

return { built: built.filter(Boolean), findings: reviews.filter(Boolean).flatMap(r => r.findings) }
```

The master then triages the findings itself — drops the wrong ones, removes
anything with a blast radius beyond the batch — and dispatches the fix round.
Keep the fix round in a second, smaller workflow (or plain `Agent` calls) so
the triage decision stays yours.

**When a workflow dies** (API 529, a killed agent), relaunch with
`Workflow({ scriptPath, resumeFromRunId })`. Completed stages replay from
cache; only the dead stage and everything after it re-runs. Never re-run a
whole batch to recover one agent.

For two or three tasks, plain parallel `Agent` calls in one message are
cheaper than a workflow. Use a workflow when the batch has stages. Use `Agent`
calls too when `Workflow` is missing or its launch is denied (the Harness
line's fan-out says which); there is no `resumeFromRunId` then, so when one
agent dies, re-run only the dead task.

## Implementer prompt skeleton

```
Working directory: <absolute path>. Never cd elsewhere.

Task: <one paragraph, plus acceptance criteria as a checklist>

You own these files — do not edit any other file:
  <paths>
Being edited concurrently by other agents (do not touch, do not read as truth):
  <paths>

Verify before reporting: <exact commands>
Do not commit, push, stash or `git add`. The master commits.

Report: what you changed, the command output proving it, anything you could
not do and why. Your final text is the return value — no preamble.
```

## Reviewer prompts (read-only, in parallel)

Both prompts open with the implementer skeleton's first lines — `Working
directory: <absolute path>. Never cd elsewhere.` and `Review exactly these
files: <the batch's owned and created paths>` — and only then the criteria
below. A reviewer inherits the session's cwd, which in a worktree run is the
wrong tree: it reads a clean `git diff`, finds nothing, and reports a green
batch. **Zero findings over a non-empty diff means the reviewer was looking at
the wrong tree** — re-run it with the diff pasted in rather than believing it.

**Spec compliance.** "Read <brief/plan>. Read the working tree diff
(`git diff` and `git status`). List: (1) acceptance criteria not met, (2)
anything built that nobody asked for, (3) behaviour that silently disappeared —
compare against `git show HEAD:<file>` for every changed file. Findings only,
each with file:line and the criterion it violates. Do not edit anything."

**Code quality.** "Real defects only, each with a concrete failure scenario:
inputs or state → wrong output, crash or leak. Look for unhandled errors and
rejections, data shown as zero or empty when a load failed, permission or
tenancy leaks, unbounded loops over user data, injection — plus <the project
notes' Review focus>. (On a web UI, for example: stale closures, hook order,
layout at 375px.) No style opinions, no speculative refactors. Do not edit
anything."

Both reviewers return structured findings. The master ranks them, discards the
ones it can disprove by reading the code, and turns the rest into numbered fix
instructions grouped by file owner.

## Rules that keep the loop honest

1. **Verify the reports.** Re-run the typecheck and tests the agents claim
   passed. A green claim with a red repo is the single most common failure.
2. **One fix round per batch.** A second only when the fix round was large or
   security-relevant. Endless polish burns the night.
3. **Log silent caps.** If you dropped a task, sampled instead of covering, or
   skipped a review, it goes in the ledger and the morning report. An
   unreported cap reads as "covered everything".
4. **Ship before the next batch.** The ledger row is not done until its commit
   is at its ceiling and proven, or its proof is recorded as proof-pending, or it is set aside (SKILL.md Phase 4 rule 9).
