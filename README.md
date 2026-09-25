![goodnight alchemist. A Claude Code skill: hand it over at bedtime, find it shipped by morning.](.github/banner.png)

# Goodnight Alchemist

**A Claude Code skill for handing your project over at bedtime and finding it shipped in the morning — as far as you allowed, and proven.**

You say goodnight, and how long it may run. One master agent takes the brief, builds a backlog, and works it in batches — subagents implementing in parallel, then a review gate, then one fix round, then tests and a commit. Then it ships the batch as far as you allowed — a pushed branch by default, a pull request, or live — and checks, against that exact commit, that it really got there. Then the next batch. By morning there is a report: what shipped and how far, what it decided for you while you slept, and a checklist of what still needs your hands.

```
you: "goodnight alchemist — take it live, stop at 7am"
     ↓
 backlog → [batch: 4 agents in parallel] → review → fix → gates → ship → prove it
     ↓                                                                      ↺
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

**Works in shippable batches.** A batch is a handful of tasks split by file ownership so they can run in parallel, then one review gate, one fix round, the project's own gates (typecheck, tests, build), then a commit and the ship step. Each batch ends shipped and proven. A run cut off at any point has left working software behind, never a half-applied change.

**Ships as far as you allow, and proves it.** There are five levels: kept on your machine, pushed to its own `goodnight/` branch (the default), a draft pull request, your main branch, or live. It learns what each of those means in your setup — Lovable, Vercel, a server of your own, a team repo — takes each batch to the level you granted tonight, one step at a time, and proves it by the commit: the host's deployment record, a version endpoint, or a check of what the live site is actually serving. "Take it live" or "full rights" raises the level; saying nothing about going live never goes live: it asks you plainly at goodnight, keeps everything on a safe copy until you say yes, and the morning report tells you if nothing went live and the one step to do it. Anything uncertain — a rejected push, a password prompt, a red check — only ever lowers it.

**Paces itself against the account you actually have.** On any Claude subscription it reads whatever usage windows the account reports — it doesn't assume a plan or a number — works against the tightest one, holds a reserve back so there is always enough left to write the report, and calibrates the cost of a task from the run's own first batch. Six tasks where there is budget for six, one where there is budget for one. The structure and the guarantees are identical either way.

**Reviews before it ships.** Two read-only reviewers per batch: one against the spec and against behaviour that silently disappeared, one for real defects with a concrete failure scenario attached. The master triages their findings itself, drops the wrong ones, and pulls out anything whose blast radius exceeds the task — a database-wide grant change, a dependency bump, a schema migration — for you to decide in the morning. It also re-runs the tests an agent *claims* passed, because a confident report over a red repo is the classic way broken code reaches production.

**Never forks itself.** Resume hooks check a `busy-until` lease in the ledger before they resume anything. Two sessions editing one repo is the worst outcome in the whole protocol; idling is not.

**Leaves a ledger, not a mystery.** Every decision, every park, every measured cost, every commit and how far it shipped goes in a file a fresh session can resume from alone.

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

No config files to edit — the first run asks what it needs. `scripts/probe-live.sh` wants `bash` and `curl`, and only if you use it.

## First run

The first time it meets you, and the first time it meets a repo, it looks before it asks. It reads the repo — where it goes live, whether others work in it, how it is tested — and then confirms its guesses in plain English, with multiple-choice answers:

- *Where does your app go live?* ("It looks like Vercel — every time the main version changes, your live site updates. Is that right?")
- *While you sleep, how far should I take finished work?* Keep it on your computer, put it somewhere safe for you to check in the morning (recommended), or put it live.
- *Does building or publishing here cost money beyond your Claude plan?* And if so, how much may it spend in one night.
- *Does anyone else work on this project?*
- *Is there anything I should never touch?* Customer data, payment settings, a folder.
- *How should I tell you it's done?* And what time you usually wake up, so it can suggest a stop time.

"I'm not sure" is always an answer, and it picks the safe option, which it tells you. The stop time is asked every night and never remembered as a standing answer. After that it only asks again about something that changed, or a question you have not answered yet.

Best done while you are awake: say **"set up goodnight alchemist"** and it takes about two minutes. If your first use is at bedtime and you walk away mid-questions, the night still starts — on the safe settings (a pushed branch, no spending beyond your Claude plan, no changes to your live database or backend settings) — and the unanswered questions wait at the top of the morning report and come back each night until answered.

Your answers live in `~/.claude/goodnight/` — a `profile.md` for you, and one file per repo under `notes/` — outside the skill folder. Updating the plugin never overwrites them, and they are never part of anything published.

## What a night looks like

1. **The handshake.** One message: the setup it detected and the evidence, how far it will ship tonight and the phrase that raises it, the stop time and any spend cap, what must stay running on your side, and the defaults it took. It never ends that turn waiting on you — it states the defaults and starts.
2. **Ground truth.** Sync check against your real default branch, isolate in a worktree if another session shares the checkout, read the brief and the code, rank a backlog by *value ÷ risk of needing you*. Anything that needs your judgement goes on the morning list rather than being guessed at.
3. **Batches, until the backlog or the clock runs out.** Implement → review → fix → gates → ship → prove → next.
4. **The report.** The first line gives each batch's commit, how far it shipped and the one step left ("merge PR #12", "press Publish", "nothing, it's live"). Then everything it decided in your absence, spelled out.

## Where it runs

| Surface | Support |
|---|---|
| **Claude desktop app** | Fully supported: usage meter, resume hooks including the hourly fresh-session safety net, keep-awake, browser checks, a phone notification when it is done (unless you asked for a report only). |
| **Terminal CLI** | Supported, with fallbacks. No usage meter, so it cannot tell a subscription from a per-token account: it stops after 4 batches unless you name a dollar ceiling, or tell it this is a subscription (then small batches, with the stop time as the limit). No fresh-session safety net (it hands you the one-line OS scheduler entry to add yourself if you want one). No built-in keep-awake: keep the machine and the terminal up (on macOS and Linux it uses the system's own sleep blocker). |
| **Claude Code on the web** | Supported, with fallbacks. No usage meter (same 4-batch default as the CLI unless you name a dollar ceiling or say it's a subscription), no fresh-session safety net, and no parking across a limit reset — it wraps up instead. The ledger lives on the run's branch. Nothing to keep awake. |

**Accounts.** Any Claude subscription. Per-token accounts — an API key, Bedrock, Vertex, a gateway — report no usage window, so the night is paced by a dollar ceiling you name, or failing that a small batch cap stated at the handshake.

**Permissions.** On every surface one permission prompt stalls the night, so it needs auto mode or allow rules for its git pushes, gates and ship commands. It cannot set that for you, and it says so at the handshake.

## Good fits

- **A brief or a design handoff you want turned into a working, deployed feature** while you sleep.
- **Backlog burn-down** — the twenty small things nobody schedules: edge cases, empty states, a11y, error handling, test coverage, docs.
- **A long mechanical migration** that is too big for one context window but splits cleanly by file.
- **A hardening pass before a launch** — review, verification and fixes over code that already works.
- **Most ways of going live.** Lovable and other app builders, Vercel, Netlify and Cloudflare, Fly, Render and Railway, a deploy script of your own, team repos where changes go through pull requests (one draft PR a night, never merged by it), libraries and CLIs (tested and packed, never auto-released), mobile apps and infrastructure code (a pull request, never an apply).
- **Small-plan users especially.** The pacing means an account with a modest window still gets a full night of continuous progress, one careful task at a time, instead of one big batch that dies halfway.

Poor fits: anything whose acceptance criteria are a product question, work that needs credentials or sign-ins, or a repo with no gates — with no typecheck, tests or build, it writes a smoke test first and the report can only say "builds and runs", not "verified".

## What it will not do

The protocol takes the strict reading by default, and says so out loud at the handshake:

- No account creation, no sign-ins, no entering credentials or keys.
- No confidential data leaving the machine, and none of it committed.
- No test writes to production data — a throwaway namespace, or it waits for you.
- Anything destructive, legal, financial or irreversible goes on the morning list instead of being done.
- **Never overnight, even if you ask for it:** publishing a package or a release, creating release tags, submitting to an app store, pushing an over-the-air update to users, applying or destroying infrastructure, deleting or reshaping database data, rewriting git history or force-pushing, merging or approving its own pull request, turning on auto-merge, getting round branch protection, or signing anything off in your name. Each one waits on the morning list with the exact command ready.
- No changes to your setup: it never installs a scheduled job, an allow rule or a status line. It hands you the snippet instead.
- A denied permission is never worked around. It is recorded and the run continues with what it can.
- The authorisation grant covers **that run only**. The next night starts from your setup default, stated back to you; last night's level is shown, never reused silently.

## Inside the repo

| Path | What it is |
|---|---|
| `.claude-plugin/` | Plugin and marketplace manifests, so `/plugin` can install and update it |
| `CHANGELOG.md` | What changed in each version |
| `skills/goodnight-alchemist/SKILL.md` | The protocol — seven phases, from the goodnight handshake to the morning report, with the ship ladder |
| `skills/goodnight-alchemist/references/onboarding.md` | First run only: what it detects, the plain-English questions, and the templates for your profile and project notes |
| `skills/goodnight-alchemist/references/keepalive.md` | What each surface supports, the pacing algorithm, the deadline, and the resume hooks |
| `skills/goodnight-alchemist/references/batch-loop.md` | Multi-agent mechanics: fan-out, reviewer prompts, recovering a dead run |
| `skills/goodnight-alchemist/references/ledger-template.md` | The ledger — the file a fresh session resumes from |
| `skills/goodnight-alchemist/references/local-verify.md` | Verifying locally before shipping — in a browser, or against written-down expected output when there is no screen |
| `skills/goodnight-alchemist/scripts/probe-live.sh` | The fallback live check: greps what the server is actually serving for a marker from the new build |

The per-repo notes in `~/.claude/goodnight/notes/` are what make the second night in a codebase smarter than the first: how it goes live, how to undo it, and the traps that stop being rediscovered at 3am.

## Honest notes

Written out of real overnight runs and then reviewed adversarially — six independent lenses over the protocol, every finding handed to a separate agent whose job was to refute it. Eight defects survived that and were fixed, including a handshake question that could stall the entire night and a reviewer scope bug that would have returned a cheerful "no findings" until morning.

It is prose read by a capable agent, not a program. It does not remove your judgement from the loop; it makes the agent's judgement legible, bounded and reversible. Read the morning report before you merge anything, and give it a repo whose gates you trust.

## Credits

Built by [**Alchemist Inc**](https://alchemistinc.in) — a creative and technology studio.

Made with [Claude Code](https://claude.com/claude-code). Shared as-is: fork it, gut it, rename it.

## License

MIT — see [LICENSE](LICENSE).
