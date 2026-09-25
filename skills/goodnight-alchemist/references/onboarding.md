# Onboarding: detect, then ask in plain English

Read this file on the first run in a repo, when the profile or the project
notes are missing, when drift is found, when a question is marked
"unanswered", or when the user says "set up goodnight alchemist". On a normal
night the notes' Ship section already holds everything here, and only §1 step 2
and the §2 signals column are needed, for the drift check.

Paths, always absolute with the home directory expanded (Windows tools do not
expand `~`); create the folders if they are missing:

- **profile** — `<home>/.claude/goodnight/profile.md` (template §4)
- **project notes** — `<home>/.claude/goodnight/notes/<repo-slug>.md` (template §5).
  `<repo-slug>` is the remote's repository name, lowercase; the folder name when
  there is no remote.

## 1. Detect

Read-only, about a minute, before the handshake message. Never ask what the
repo already answers.

1. **Read the profile and the project notes.** If the notes are missing, look
   for the legacy `references/project-notes/<repo-slug>.md` inside the skill
   folder, and, if it is not there, in any older plugin copy:
   `<home>/.claude/plugins/cache/*/goodnight-alchemist/*/skills/goodnight-alchemist/references/project-notes/<repo-slug>.md`
   (if several match, take the newest). If it exists, migrate it: copy it to
   the notes path, rename `## Git / deploy` to `## Ship`, add the missing §5
   sections, and leave the old file where it is. Write the parts that map to a
   question — Costs, Never touch, and the Ship section's Default ceiling line —
   as "unanswered"; the rest empty, or "none yet". Log the migration.
2. **Notes whose Ship section has a `Signals seen:` line → drift check only.**
   Compare against the repo now: the same default branch, and the same signals
   from §2 (the "Signals seen" line). Also recount authors (step 3). Any
   question the notes or profile mark "unanswered" goes in tonight's handshake
   (§3 principle 6). Then:
   - Default branch renamed → update the notes silently; it is a fact, not a
     question.
   - A new §2 row matches, a recorded one no longer does, or team signals
     appeared → re-ask only the question that covers it (§3, *Drift*). Until
     it is answered, the stricter reading applies tonight.
   - Nothing changed → go to step 4 (harness).
3. **Otherwise (including freshly migrated 1.0 notes) → scan the repo:**
   - `git remote -v` — no remote is the *No remote* row.
   - the default branch from `git symbolic-ref refs/remotes/origin/HEAD` —
     never assume `main` or `origin`.
   - the root file listing and `package.json` (or the stack's manifest).
   - `.github/workflows` — any `on: push` step that deploys, publishes or runs
     `eas update` with no branch filter.
   - migration directories, and anything that applies them automatically.
   - release configuration.
   - `git shortlog -sn --since=90.days` (humans only: ignore `[bot]` authors
     and the builder bots in §2, such as gpt-engineer and lovable) and
     CODEOWNERS, to spot a team repo.
   - `gh api repos/{owner}/{repo}/rules/branches/<default>` — only if
     `gh auth status` is green without prompting.
   - Match everything against §2. Several rows can match: the strictest cap
     wins, and each deployable gets its own Ship line.
4. **Harness.** Resolve the Harness line as `references/keepalive.md` §0
   describes: tool names by suffix, one get_usage call (`not_applicable` means
   per-token billing).
5. **Pre-flight** — each one read-only or a dry run:
   - `GIT_TERMINAL_PROMPT=0 git -c core.sshCommand="ssh -o BatchMode=yes" push --dry-run origin HEAD:refs/heads/<run branch>`
     — a prompt or an auth failure means L0 tonight.
   - if `git config --get commit.gpgsign` is `true`, prove a signature without
     a prompt: `git commit-tree -S HEAD^{tree} -m preflight < /dev/null`, run
     with a 20-second limit where the shell has one (`timeout` / `gtimeout`).
     It creates an unreferenced object and moves no ref. If it fails or times
     out, say at the handshake that nothing can be committed until the key is
     unlocked with a cache that lasts the night. Never turn signing off
     yourself.
   - the host CLI's read-only auth check, only if the ceiling needs it.
   - prove the live probe once against the current live SHA, only if the
     ceiling can reach L3.

Write what you found into the notes' Ship section as you go (setup rows with
evidence, default branch, "Signals seen", who else writes here), so the next
night only drift-checks. Then ask whatever §3 still needs.

## 2. Setup signals

Read in full on a repo's first night and on drift; every other night only its
signals column, for the drift check.

| Setup — signals | Pushing the default branch | L4 | Proof for a SHA | Cap |
|---|---|---|---|---|
| **Lovable** — `lovable-tagger`, `componentTagger`, a lovable.dev link, gpt-engineer or lovable bot commits, a Lovable MCP | Syncs the editor, not the live site | `deploy_project`; with no MCP, the Publish button goes to *Pending on you* | `probe-live.sh` on `*.lovable.app` or the custom domain | L4 |
| **Base44 / Bolt / Replit** — `@base44/sdk`, `.bolt/`, `.replit` | Syncs to the builder | A Publish button with no API: *Pending on you*, with a ready probe command | The probe, once the user has published | L3 |
| **Vercel / Netlify / Cloudflare / GitHub Pages / v0** — `vercel.json` or `.vercel`, `netlify.toml`, `wrangler.*`, a pages workflow, `v0/*` branches | Production deploy, so L3 = L4 | = L3 | The host's deployment for the SHA reports ready, then `/version` or the probe | L4 |
| **PaaS** — `fly.toml`, `render.yaml`, `railway.*`, `Procfile`, `Dockerfile` | Deploys if the host is wired to git; `release_command` or `preDeployCommand` may migrate | `fly deploy` or the host's deploy command | The release for the SHA, then `/healthz` or `/version` | L4; L2 without a health URL and a rollback in the notes |
| **Self-hosted** — `deploy.sh`, a Makefile `deploy` target, Kamal, Capfile, Ansible, ssh or rsync workflows | Whatever the workflows do; read them | Only the script the grant names | The notes' health URL | L4 only when the grant names the script and the notes hold a rollback and a health URL; otherwise L2 |
| **Team repo** — branch rules, CODEOWNERS, 3 or more human authors in 90 days | Usually refused by protection; never tried | None: merging is the team's | PR head = HEAD, required checks green, preview probed | L2, one draft PR a night |
| **Library / CLI / desktop / extension** — `publishConfig`, `exports` or `bin`, a pyproject `build-system`, Cargo `[package]`, `go.mod` plus tags, `.changeset`, release-please, `.releaserc`, goreleaser, an electron-builder publish provider | CI; a release, if release automation runs on it | None overnight: registry publish and tags go to *Pending on you* | CI matrix, a pack dry-run, a temp install, a CLI golden run in a temp HOME | L3; L2 when the default branch releases |
| **Mobile** — `ios/`, `android/`, `pubspec.yaml`, capacitor, `eas.json`, expo-updates, fastlane | CI; possibly `eas update` to production | None overnight: store submit and production OTA go to *Pending on you* | CI and the build | L3; L2 when the default branch runs `eas update` on production |
| **IaC** — `*.tf`, `Pulumi.yaml`, `cdk.json`, `sst.config.*`, `serverless.yml`, `atlantis.yaml` | The pipeline may apply | None overnight: apply and destroy go to *Pending on you* | The pipeline's plan, summarised in the PR | L2 |
| **Modifier: auto-migrating backend** — `migrate deploy` in the build, `release_command`, `preDeployCommand`, a Procfile `release:` line, the Supabase GitHub integration | Runs migrations on every build or deploy that uses it, previews included | — | Query the result afterwards | A migration caps the rest of the night at L2 (every later SHA contains it); L0 if preview builds can reach the production database |
| **`on: push` deploy with no branch filter** | Even L1 fires something | — | — | L0 until the user says otherwise |
| **No remote** | Nothing to push | — | — | L0; never create a remote |

Several rows can match, and the strictest cap wins; each deployable gets its
own Ship line. With no known undo, L3 and L4 cap at L2 whatever the row says
(SKILL.md Phase 4). GitLab and Bitbucket users record their equivalent
read-back (`glab`, or the host API) in the notes.

Row rules the table cannot hold:

- **Lovable.** Backend changes go only through a message to the Lovable agent,
  as a production-state change; a migration file in git is only a proposal.
  Never rewrite the default branch, fetch before every push, and follow the
  `lovable-git-workflow` skill when it is installed.
- **Vercel and friends.** Protected previews are read only through the host MCP
  or a bypass token the user gave. Never name a branch `v0/*`.
- **Self-hosted.** ssh with `BatchMode=yes`, never `sudo`.
- **Team repo.** Roadmap items become proposals under *Pending on you*. Never
  approve, merge, enable auto-merge, bypass protection or sign off.
- **Library.** A changeset file is fine; releasing is not.
- **Mobile.** Always `--non-interactive`.

## 3. The questions

**Principles, in order:**

1. **Look first, ask second.** §1 runs before any question. A question
   confirms a guess; it never asks something technical and open. When
   detection is conclusive (branch rules that require review), state it rather
   than asking.
2. **Plain English only.** Everything the user reads during onboarding — the
   text in quotes below — never says branch, CI, SHA, deploy target, or a
   level name such as L1. The levels and caps after each arrow are for you.
3. **Every question is multiple choice, and "I'm not sure" is always an
   answer.** It selects the safe option, and you say what that option is.
4. **Two scopes.** Project answers go in the project notes, once per repo.
   Person answers go in the profile, once per person.
5. **Stop time is asked every night** and never stored as an answer.
6. **Re-ask an answered question only on drift**, and only the one that
   drifted. A question still marked "unanswered" goes in every handshake until
   it is answered. "I'm not sure" is a stored answer and is not re-asked.

**Awake or at bedtime.**

- **Awake** ("set up goodnight alchemist", about two minutes): run §1, then ask
  the questions below, a few at a time. Write the notes and profile as answers
  arrive, finish with a short summary of what was stored, and start no night.
- **At bedtime** (first use at goodnight): put the unanswered questions,
  numbered, below the handshake message, each with the safe answer you are
  already taking. Never end the turn on them. The night starts on the safe
  settings — L1, no spending beyond the Claude subscription, no
  production-state change. A later answer updates the files and the ledger as
  an override; anything still unanswered is marked "unanswered" in the files
  and goes at the top of the morning report.

### Project questions → project notes

**1. Where it goes live** → `## Ship` (setup rows, evidence)

"It looks like your app goes live through Vercel — every time the main version
changes, your live site updates. Is that right?" (State your own detected guess
the same way: what it is, and what happens when the main version changes.)

- "Yes" → the row is confirmed; its cap from §2 applies.
- "No, it's something else" → "What do you use?", offering the other rows that
  could fit plus "something else (type it)". Record what they say; a setup
  that matches no row caps at L2 until the notes hold its publish command,
  proof and undo.
- "I'm not sure" → setup unconfirmed, cap L1. Say: "Then I'll keep everything
  off your live site until you tell me how it goes live."

With nothing detected, ask instead: "I couldn't tell where this project goes
live. Does it?" — "No, it only runs on my computer" (→ no deployable; cap L1,
or L0 with no remote) / "Yes, through something else (type it)" / "I'm not
sure" (→ cap L1).

**2. How far to take finished work** → `## Ship` (the project's default ceiling)

"While you sleep, how far should I take finished work?"

- "Save it on your computer only" → L0.
- "Put it somewhere safe for you to check in the morning (recommended)" → L1;
  L2 on a team repo.
- "Put it live" → L4, then capped by the setup (min with §2). Add: "A few
  things always wait for you, even then: publishing a release, app store
  submissions, and anything that can't be undone. I'll leave those ready for
  you in the morning."
- "I'm not sure" → L1 (L2 on a team repo). Say: "Then I'll keep it safe and off
  your live site. Say 'take it live' on any night to go further."

This is the project's default ceiling, quoted back every night. A non-live
answer (L0–L2) is used on nights the user says nothing. **"Put it live" is
never applied on its own**: it is stored as a preference, and on nights the
user says nothing the handshake asks "At setup you said you like it live — shall
I put tonight's work live too?" while work starts on L1. Each night's own words
still change it, for that night only.

**3. Money beyond the Claude subscription** → `## Costs`

"Does building or publishing here cost money beyond your Claude plan — credits,
a paid service, build minutes?" (If §1 matched a builder row, say so: "It looks
like Lovable uses credits each time I ask its agent for changes — anything else
that costs money?")

- "No" → per-night cap: nothing.
- "Yes" → "How much may I spend in one night?" — "Nothing without asking me
  first" (→ cap nothing; paid work goes to *Pending on you*) / "Up to ___ a
  night" (type an amount or a number of credits → that cap) / "I'm not sure"
  (→ cap nothing).
- "I'm not sure" → cap nothing. Say: "Then I won't spend anything; paid steps
  wait for you in the morning."

Record what spends money here as well as the cap. It is the default quoted at
the handshake; a night's own words can change it for that night.

**4. Who else works here** → `## Ship` (who else writes here, team flag)

"Does anyone else work on this project?" (If detection saw other people, say so:
"It looks like four people changed this project in the last three months.")

- "Just me" → team flag off. Branch rules or CODEOWNERS found in §1 still apply,
  and you say so.
- "Others check changes before they go live" → team flag on, cap L2.
- "I'm not sure" → team flag on, cap L2. Say: "Then I'll treat it as shared:
  everything waits for someone to approve it, and I won't approve anything
  myself."

**5. Never touch** → `## Never touch`

"Is there anything I should never touch? For example customer data, payment
settings, or a particular folder." — "Yes (type it)" / "Nothing I can think of"
/ "I'm not sure".

Record their words, plus the paths you take them to mean. "Nothing" and "not
sure" record "none named"; the ground rules in SKILL.md still apply either way.

### Person questions → profile

**6. How to say it's done** → `## Standing defaults`

"How should I tell you it's done?" — "A notification on my phone" / "Just leave
a report" / "I'm not sure" (→ a notification where the harness has one, and the
report either way).

**7. Usual wake time** → `## Standing defaults`

"What time do you usually wake up?" — "Around 6" / "Around 7" / "Around 8" /
"Another time (type it)" / "It varies" (→ not recorded).

Used only to suggest a stop time. Record it with the time zone.

### Every night, never stored

"What time should I stop?" — suggest the profile's wake time when there is one.
If the user leaves without answering, SKILL.md Phase 0 step 2 sets the default
and says so.

### Drift

Ask only about what changed, in the same plain words, and keep the other
answers:

| Drift | Re-ask |
|---|---|
| A new setup row matches, or a recorded one no longer does (Lovable files appear in a repo noted as Vercel) | 1, then 2 if the new cap is lower than the default ceiling: "This project now looks like it goes live through Lovable, but last time it was Vercel. Which is right now?" |
| Team signals appear (branch rules, CODEOWNERS, 3 or more human authors in 90 days) | 4; the L2 cap applies tonight regardless |
| A builder row with credits now matches (Lovable, Base44, Bolt, Replit) | 3 |
| Default branch renamed | Nothing — update the notes |

## 4. Profile template

`<home>/.claude/goodnight/profile.md`. One per person. Person-level answers
only; nothing about a repo.

```md
# Goodnight profile

Updated: <date>

## Standing defaults
- Default ceiling when I say nothing: <not set → L1 | L0–L2 | live preference> —
  set only when the user asks for one; quoted back every night. A live
  preference is never applied silently: it only makes the go-live question
  suggest yes
- Tell me it's done by: <notification | report only>
- Usual wake time: <HH:MM, time zone | not recorded> — suggests a stop time;
  never stored as one

## Unanswered
- <question> — asked <date>; safe answer in use: <what>
```

Example, for a fictional user:

```md
# Goodnight profile

Updated: 2026-09-02

## Standing defaults
- Default ceiling when I say nothing: not set → L1
- Tell me it's done by: notification
- Usual wake time: 07:15, Europe/Lisbon

## Unanswered
- none
```

## 5. Project notes template

`<home>/.claude/goodnight/notes/<repo-slug>.md`. One per repo. The master reads
it before planning and appends whenever the night teaches it something, so the
second night in a repo is smarter than the first. It never goes in the skill
folder or in git.

```md
# <repo> notes (read before planning)

## Ship
- Setup: <§2 row(s)> — evidence: <files, bots, tools seen> · confirmed: <yes | not sure or unanswered → cap L1 until confirmed>
- Signals seen: <list> (checked <date>)
- Default branch: <name> · who else writes here: <names or count> · team: <yes | no>
- Levels here: L0 <…> · L1 <what a pushed run branch triggers> · L2 <…> · L3 <…> · L4 <command>
- Proof for a SHA: <command or API, then the probe or /version>
- A push to the default branch triggers: <what fires>
- Undo: <how to roll back> (none known → cap L2)
- Never here: <ship actions off limits in this repo>
- Default ceiling: <L0–L2 | live preference> (answered <date>) — L0–L2 is used when the user says nothing; a live preference only shapes the go-live question
- Last night: <level, date> — information only, never applied

## Costs
- What spends money or credits here: <services> · per-night cap: <amount | nothing>

## Verify commands
- <typecheck / tests / build / lint, and any checklist doc — or "none yet">

## Local run
- <dev server command and port, auth bypass, seeding keys, fixture data>

## Review focus
- <this stack's defect classes, for the code-quality reviewer>

## Traps
- <one line each, learned the hard way>

## Never touch
- <the user's words, and the paths they mean — or "none named">
```

Example, for a fictional repo:

```md
# acme-dashboard notes (read before planning)

## Ship
- Setup: Vercel — evidence: `vercel.json`, Vercel bot comments on commits · confirmed: yes
- Signals seen: vercel.json, supabase/migrations (applied by CLI only) (checked 2026-09-24)
- Default branch: main · who else writes here: owner only (1 author in 90 days) · team: no
- Levels here: L0 local commit · L1 run branch pushed, Vercel builds a preview
  for it · L2 draft PR · L3 = L4: a push to main is the production deploy
- Proof for a SHA: `gh api repos/acme/dashboard/deployments?sha=<sha>` reports
  success, then `BASE=https://dashboard.acme.test bash probe-live.sh /reports "<marker>"`
- A push to the default branch triggers: the production deploy; no migrations
- Undo: `vercel rollback`, or promote the previous deployment in the dashboard
- Never here: applying migrations unattended — a committed `.sql` file is a
  proposal; verify afterwards that the object exists and `anon` cannot touch it
- Default ceiling: live preference (answered 2026-09-02, "put it live") — asked each night, never applied silently
- Last night: L4, 2026-09-24 — information only

## Costs
- What spends money or credits here: preview deployments are free; the upstream
  API bills per 1,000 lookups · per-night cap: 5,000 lookups

## Verify commands
- `pnpm typecheck` · `pnpm test` · `pnpm build` — all three before any push

## Local run
- `pnpm dev` on :3000. `?e2e=1` short-circuits the auth guard in dev builds only.
- Seed data lives in `localStorage` under `acme.dev.store`; shape in `src/lib/dev-seed.ts`.

## Review focus
- Every query filters by team id; a missing filter leaks another team's rows.
- A failed load must not render as zero in totals.

## Traps
- The admin route sits outside the `(app)` layout group, or the layout guard
  bounces admins into onboarding.
- `routes.gen.ts` regenerates with line-ending-only changes. Restore it, never commit it.

## Never touch
- "The billing settings and anything in the customers export" → `src/billing/`, `exports/`
```
