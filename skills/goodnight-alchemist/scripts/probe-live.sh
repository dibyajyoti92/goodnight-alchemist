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
# route chunks live).
#
# PROVE THE PROBE FIRST: run it once with a string the old and new builds both
# contain. If that prints NONE, the probe is broken — not the deploy.
# `Accept: */*` can bypass a pre-launch or consent gate, which
# is fine here: we are checking what the server ships, not what a visitor sees.
#
# ASSETS is the bundle's path prefix, default /assets (Vite). Others:
# /_next/static (Next.js), /_astro (Astro), /static/js (Create React App),
# /_app/immutable (SvelteKit), /build (Remix). Plain sh + curl, no bashisms.
set -u
base="${BASE:?set BASE to the site origin, e.g. BASE=https://example.com}"
assets="${ASSETS:-/assets}"
route="${1:?usage: probe-live.sh <route> <marker>}"
marker="${2:?usage: probe-live.sh <route> <marker>}"
html=$(curl -s -H 'Accept: */*' "$base$route?cb=$(date +%s)" | tr -d '\0')
found=""
if printf '%s' "$html" | grep -qF -- "$marker"; then found=" $route(html)"; fi
urls=$(printf '%s' "$html" | grep -oE "$assets/[^\"' ]+\.js" | sort -u)
more=""
for u in $urls; do
  more="$more $(curl -s "$base$u" | tr -d '\0' | grep -oE "(\./|$assets/)[A-Za-z0-9_.\$-]+\.js" | sed "s#^\./#$assets/#" | sort -u)"
done
all=$(printf '%s\n' $urls $more | sort -u)
for u in $all; do
  if curl -s "$base$u" | tr -d '\0' | grep -qF -- "$marker"; then found="$found $u"; fi
done
echo "chunks-scanned: $(printf '%s\n' $all | grep -c .)"
echo "${found:-NONE}"
