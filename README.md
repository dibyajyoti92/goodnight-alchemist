![goodnight alchemist. A Claude Code skill: hand it over at bedtime, find it shipped by morning.](.github/banner.png)

# Goodnight Alchemist

**A Claude Code skill for handing your project over at bedtime and finding it shipped in the morning.**

You say goodnight, and how long it may run. One master agent takes the brief, builds a backlog, and works it in batches — subagents implementing in parallel, then a review gate, then one fix round, then tests, commit, push, deploy, and a check that the change is genuinely live. Then the next batch. By morning there is a report: what shipped, what it decided for you while you slept, and a checklist of what still needs your hands.

```
you: "goodnight alchemist — take the brief to production, stop at 7am"
     ↓
 backlog → [batch: 4 agents in parallel] → review → fix → gates → ship → prove live
     ↓                                                                        ↺
 usage window empties → park → resume itself after reset → keep going
     ↓
 07:00 → morning report + "pending on you" checklist
```

---

## Why this exists

Agents already write code unattended. What they do badly is *run out of budget in the middle of it*.

A long autonomous session dies the same way every time: the usage window empties mid-edit, the turn is killed, half-written files sit in the working tree, dispatched subagents are orphaned — and the whole thing waits for a human to come back and press something. You wake up to a mess plus four wasted hours.

This skill treats the usage limit as a scheduling problem instead of an accident. It measures what its own work costs, sizes each batch to fit the budget actually remaining, and refuses to start anything it cannot finish. When the room runs out it parks deliberately — ledger written, work committed, hooks armed — and picks itself back up after the window resets. The night flows across resets instead of breaking on them.

The second thing it does is **stop**. An agent that can work unattended for eight hours can also burn a week's budget by lunchtime if nobody comes back. The deadline is asked for up front and enforced by every component.

## What it actually does

**Works in shippable batches.** A batch is a handful of tasks split by file ownership so they can run in parallel, then one review gate, one fix round, the project's own gates (typecheck, tests, build), then commit, push, deploy and a live check. Each batch ends published. A run cut off at any point has left working software behind, never a half-applied change.

**Paces itself against the plan you actually have.** It reads whatever usage windows the account reports — it doesn't assume a plan or a number — works against the tightest one, holds a reserve back so there is always enough left to write the report, and calibrates the cost of a task from the run's own first batch. Six tasks where there is budget for six, one where there is budget for one. The structure and the guarantees are identical either way.

**Reviews before it ships.** Two read-only reviewers per batch: one against the spec and against behaviour that silently disappeared, one for real defects with a concrete failure scenario attached. The master triages their findings itself, drops the wrong ones, and pulls out anything whose blast radius exceeds the task — a database-wide grant change, a dependency bump, a schema migration — for you to decide in the morning. It also re-runs the tests an agent *claims* passed, because a confident report over a red repo is the classic way broken code reaches production.

**Never forks itself.** Resume hooks check a `busy-until` lease in the ledger before they resume anything. Two sessions editing one repo is the worst outcome in the whole protocol; idling is not.

**Leaves a ledger, not a mystery.** Every decision, every park, every measured cost goes in a file a fresh session can resume from alone.

## Install

**As a plugin** — two commands inside Claude Code, and `/plugin` keeps it updated:

```
/plugin marketplace add dibyajyoti92/goodnight-alchemist
/plugin install goodnight-alchemist@goodnight-alchemist
```

**Or by hand** — copy the skill folder into your skills directory:

```bash
git clone https://github.com/dibyajyoti92/goodnight-alchemist /tmp/goodnight-alchemist

# available in every project
cp -r /tmp/goodnight-alchemist/skills/goodnight-alchemist ~/.claude/skills/

# or scoped to one project (commit it if your team wants it too)
cp -r /tmp/goodnight-alchemist/skills/goodnight-alchemist .claude/skills/
```

Then start a session and say **"goodnight alchemist"** — or just *"I'm going to bed, keep building"*. It triggers on the intent, not only on the name.

Nothing to configure. `scripts/probe-live.sh` wants `bash` and `curl`, and only if you use it.

## What a night looks like

1. **The handshake.** It asks how far it may go — commit? push to `main`? deploy? spend money, up to what? — and until what time. It never ends that turn waiting on you: it states the defaults it is taking and starts.
2. **Ground truth.** Sync check, isolate in a worktree if another session shares the checkout, read the brief and the code, rank a backlog by *value ÷ risk of needing you*. Anything that needs your judgement goes on the morning list rather than being guessed at.
3. **Batches, until the backlog or the clock runs out.** Implement → review → fix → gates → ship → prove live → next.
4. **The report**, with everything it decided in your absence spelled out.

## Good fits

- **A brief or a design handoff you want turned into a working, deployed feature** while you sleep.
- **Backlog burn-down** — the twenty small things nobody schedules: edge cases, empty states, a11y, error handling, test coverage, docs.
- **A long mechanical migration** that is too big for one context window but splits cleanly by file.
- **A hardening pass before a launch** — review, verification and fixes over code that already works.
- **Small-plan users especially.** The pacing means an account with a modest window still gets a full night of continuous progress, one careful task at a time, instead of one big batch that dies halfway.

Poor fits: anything whose acceptance criteria are a product question, work that needs credentials or sign-ins, or a repo with no gates — with no typecheck, tests or build, nothing stands between "an agent said it was done" and your production branch.

## What it will not do

The protocol takes the strict reading by default, and says so out loud at the handshake:

- No account creation, no sign-ins, no entering credentials or keys.
- No confidential data leaving the machine, and none of it committed.
- No test writes to production data — a throwaway namespace, or it waits for you.
- Anything destructive, legal, financial or irreversible goes on the morning list instead of being done.
- A denied permission is never worked around. It is recorded and the run continues with what it can.
- The authorisation grant covers **that run only**. The next night asks again.

## Inside the repo

| Path | What it is |
|---|---|
| `.claude-plugin/` | Plugin and marketplace manifests, so `/plugin` can install and update it |
| `skills/goodnight-alchemist/SKILL.md` | The protocol — seven phases, from the goodnight handshake to the morning report |
| `skills/goodnight-alchemist/references/keepalive.md` | The pacing algorithm, the deadline, and the three resume hooks |
| `skills/goodnight-alchemist/references/batch-loop.md` | Multi-agent mechanics: fan-out, reviewer prompts, recovering a dead run |
| `skills/goodnight-alchemist/references/ledger-template.md` | The ledger — the file a fresh session resumes from |
| `skills/goodnight-alchemist/references/local-verify.md` | Verifying in a real browser before shipping |
| `skills/goodnight-alchemist/references/project-notes/` | One file per repo, holding that repo's traps. Template and example inside |
| `skills/goodnight-alchemist/scripts/probe-live.sh` | Proves a deploy is live by grepping the bundle the server is actually serving |

The per-repo notes files are what make the second night in a codebase smarter than the first: the traps stop being rediscovered at 3am.

## Honest notes

Written out of real overnight runs and then reviewed adversarially — six independent lenses over the protocol, every finding handed to a separate agent whose job was to refute it. Eight defects survived that and were fixed, including a handshake question that could stall the entire night and a reviewer scope bug that would have returned a cheerful "no findings" until morning.

It is prose read by a capable agent, not a program. It does not remove your judgement from the loop; it makes the agent's judgement legible, bounded and reversible. Read the morning report before you merge anything, and give it a repo whose gates you trust.

## Credits

Built by [**Alchemist Inc**](https://alchemistinc.in) — a creative and technology studio.

Made with [Claude Code](https://claude.com/claude-code). Shared as-is: fork it, gut it, rename it.

## License

MIT — see [LICENSE](LICENSE).
