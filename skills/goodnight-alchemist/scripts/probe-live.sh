#!/usr/bin/env bash
# Is a string present in what a deployed site is serving for a route?
#
# Prefer the host's deployment record for the commit SHA, or a /version
# endpoint that returns it. This is the fallback for client bundles.
#
#   BASE=https://example.com bash probe-live.sh <route> <marker>
#   BASE=https://example.com bash probe-live.sh /pricing "annual billing"
#
# Prints how many chunks were scanned and every URL containing the marker, or
# NONE. Checks the route's HTML itself (SSR and static sites), then its
# HTML-referenced chunks plus one level of their imports (that is where lazy
# route chunks live). Follows redirects.
#
# Exit 0: probed (found, or NONE). Exit 2: the route itself could not be
# fetched (FETCH-FAILED) — that is a broken probe or a down site, not a
# missing marker. Chunks that fail to fetch are counted in chunks-failed.
#
# PROVE THE PROBE FIRST: run it once with a string the old and new builds both
# contain. If that prints NONE, the probe is broken — not the deploy.
# `Accept: */*` can bypass a pre-launch or consent gate, which
# is fine here: we are checking what the server ships, not what a visitor sees.
#
# ASSETS is the bundle's path prefix, default /assets (Vite). Others:
# /_next/static (Next.js), /_astro (Astro), /static/js (Create React App),
# /_app/immutable (SvelteKit), /build (Remix). Needs bash and curl.
set -u -o pipefail
base="${BASE:?set BASE to the site origin, e.g. BASE=https://example.com}"
assets="${ASSETS:-/assets}"
route="${1:?usage: probe-live.sh <route> <marker>}"
marker="${2:?usage: probe-live.sh <route> <marker>}"
case "$route" in *\?*) sep='&' ;; *) sep='?' ;; esac
get() { curl -sfL -H 'Accept: */*' "$1" | tr -d '\0'; }
html=$(get "$base$route${sep}cb=$(date +%s)") || { echo "FETCH-FAILED $base$route"; exit 2; }
found=""
if printf '%s' "$html" | grep -qF -- "$marker"; then found=" $route(html)"; fi
urls=$(printf '%s' "$html" | grep -oE "$assets/[^\"' ]+\.js" | sort -u)
more=""
for u in $urls; do
  more="$more $(get "$base$u" | grep -oE "(\./|$assets/)[A-Za-z0-9_.\$-]+\.js" | sed "s#^\./#$assets/#" | sort -u)"
done
all=$(printf '%s\n' $urls $more | sort -u)
failed=0
for u in $all; do
  body=$(get "$base$u") || { failed=$((failed + 1)); continue; }
  if printf '%s' "$body" | grep -qF -- "$marker"; then found="$found $u"; fi
done
echo "chunks-scanned: $(printf '%s\n' $all | grep -c .)"
echo "chunks-failed: $failed"
echo "${found:-NONE}"
