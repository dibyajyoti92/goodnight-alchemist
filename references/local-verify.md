# Local verification

The point is not "the page rendered". It is: **the numbers on screen match
figures you computed by hand before you looked.** Anything less is a
screenshot of your own bug.

## Starting the dev server

Use `preview_start` with a `.claude/launch.json` entry — never a Bash-launched
server. If you are working in a worktree, the launch config still has to live
in the **root checkout**; point it at the worktree:

```json
{
  "version": "0.0.1",
  "configurations": [
    {
      "name": "<slug>-dev",
      "runtimeExecutable": "bun",
      "runtimeArgs": ["run", "--cwd", ".claude/worktrees/<slug>", "dev", "--port", "8137", "--strictPort"],
      "port": 8137
    }
  ]
}
```

`env` in a config is how you force a mode — e.g. an empty `VITE_SUPABASE_URL`
to run the demo/local adapter on a second port while the live one keeps
running. Verify the mode actually took (fetch the module and grep for the
switch) rather than trusting the flag.

Delete temporary configs and `preview_stop` the server when finished.

## Seeding and expected figures

1. Find the store the local adapter reads (`grep -n 'const KEY' <repo>`) and
   seed it in one `javascript_tool` call, then `location.reload()`.
2. Seed for the questions the change answers, and make it awkward on purpose:
   several statuses, one row from a previous period, one restricted row, one
   archived, one incomplete, and enough rows to page.
3. **Write the expected totals, counts and orderings down first.** Then
   compare — including against the module's own export for the same period.

## Checking

- Prefer `javascript_tool` DOM reads and `getBoundingClientRect()` over
  screenshots; screenshots time out when the app window is not in front.
  `read_page` is the cheap structural check.
- Desktop (1440×900) and phone (375×812) with `resize_window`. At 375:
  `document.documentElement.scrollWidth === 375` — no horizontal page scroll.
- `read_console_messages` / `read_network_requests` after every interaction;
  a clean render with a red console is not a pass.
- Exercise one real write through the local adapter and confirm the screen
  updates. Note which flows genuinely cannot be tested locally (email sends,
  OAuth, paid APIs) — they become *Pending on you* click-throughs.
- Permission and tenancy rules deserve an explicit pass: restricted rows must
  disappear from rows, totals, counts, filters **and** exports, and write
  controls must refuse both pointer and keyboard paths.
- Reset the viewport (`resize_window` preset desktop) when done.

## Against a live backend

Read-only by default. Never write test data into production tables — the
permission classifier will block it and it is the right call. If a test needs
writes, do them in a throwaway namespace (a `zz-<run>-test` workspace/tenant)
and say so in the ledger, or queue the test for the user's approval in the
morning.
