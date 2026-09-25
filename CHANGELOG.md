# Changelog

## 1.2.0

- **Saying nothing never goes live.** If you don't mention going live at goodnight, every batch stays on a safe copy your live site ignores — even if you chose "put it live" at setup. That choice is now a preference: it makes the question suggest yes, but never acts on its own.
- **It asks, plainly, every time.** When you haven't said, the goodnight message asks "Should anything go live tonight?" and starts work on the safe copy meanwhile. Say yes at any point and it goes live from the next batch.
- **The morning report says so.** If nothing went live because you didn't ask, the report's second line says exactly that, with the one step to put it live.

## 1.1.0

- **Behaviour change: the default is now a pushed branch, not live.** When you say nothing (and chose nothing else at setup), each batch is pushed to its own `goodnight/<date>-<slug>` branch for you to check in the morning. Say "push it live", "take it live" or "full rights" and you get the 1.0 flow back: main, publish, and a live check.
- **Ships as far as you allow, and proves it.** Five levels — kept on your machine, a pushed branch, a draft pull request, your main branch, live — each proven against the exact commit: the host's deployment record, a version endpoint, or a check of what the live site is serving. Anything uncertain only ever lowers the level.
- **Works beyond Lovable.** It detects how your project goes live — Vercel, Netlify, Cloudflare, Fly, Render, a deploy script, a team repo with pull requests, a library, a mobile app, infrastructure code — and ships the way that setup ships.
- **Plain-English first run.** It looks at the repo first, then confirms its guesses with a few multiple-choice questions ("I'm not sure" always picks the safe option). Say "set up goodnight alchemist" while you are awake; it takes about two minutes. At bedtime it starts on safe settings and saves the questions for the morning report.
- **Your answers live outside the skill.** Your profile and per-repo notes are kept in `~/.claude/goodnight/`, so plugin updates never overwrite them and they are never published. Notes from 1.0's `references/project-notes/` are picked up and moved there, including from an older plugin copy still on disk; if you updated via `/plugin` and the old version folder is already gone, copy your old notes file to `~/.claude/goodnight/notes/` by hand.
- **A fixed list of things it never does overnight**, even when asked: package or app-store releases, release tags, over-the-air updates to users, infrastructure apply or destroy, destructive database changes, force-pushes, merging or approving its own pull request, auto-merge, getting round branch protection, signing off in your name. Each goes on the morning list with the exact command ready.
- **Runs in more places.** The Claude desktop app is fully supported; the terminal CLI and Claude Code on the web are supported with stated fallbacks (paced blind without a usage meter: 4 batches unless you name a dollar ceiling or say it's a subscription; no hourly safety net; keep-awake left to you on Windows). Works on any Claude subscription; per-token accounts are paced by a dollar ceiling or a batch cap.
- **A clearer morning report.** The first line gives each batch's commit, how far it shipped, and the one step left for you.
- **Safer when a repo has no tests.** The first task becomes a smoke test, and the report says "builds and runs" rather than "verified".

## 1.0.0

- Initial release: the overnight multi-agent build protocol — batches with a review gate, usage-aware pacing that parks and resumes itself across limit resets, a hard stop time, a resumable ledger and a morning report with a *Pending on you* list — packaged as a Claude Code plugin.
