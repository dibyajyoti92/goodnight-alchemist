#!/usr/bin/env bash
# Is a string present in the JavaScript a deployed site is serving for a route?
#
#   BASE=https://example.com bash probe-live.sh <route> <marker>
#   BASE=https://example.com bash probe-live.sh /pricing "annual billing"
#
# Prints how many chunks were scanned and every chunk URL containing the
# marker, or NONE. Scans the route's HTML-referenced chunks plus one level of
# their imports (that is where lazy route chunks live).
#
# PROVE THE PROBE FIRST: run it once with a string the old and new builds both
# contain. If that prints NONE, the probe is broken — not the deploy.
# `Accept: */*` can bypass a pre-launch or consent gate, which
# is fine here: we are checking what the server ships, not what a visitor sees.
#
# Assumes a static /assets bundle (Vite-style). For another host, replace the
# chunk discovery below with whatever that host serves.
set -u
base="${BASE:?set BASE to the site origin, e.g. BASE=https://example.com}"
route="$1"
marker="$2"
html=$(curl -s -H 'Accept: */*' "$base$route?cb=$RANDOM" | tr -d '\0')
urls=$(printf '%s' "$html" | grep -oE '/assets/[^"'"'"' ]+\.js' | sort -u)
more=""
for u in $urls; do
  more="$more $(curl -s "$base$u" | tr -d '\0' | grep -oE '(\./|/assets/)[A-Za-z0-9_.$-]+\.js' | sed 's#^\./#/assets/#' | sort -u)"
done
all=$(printf '%s\n' $urls $more | sort -u)
found=""
for u in $all; do
  if curl -s "$base$u" | tr -d '\0' | grep -qF "$marker"; then found="$found $u"; fi
done
echo "chunks-scanned: $(printf '%s\n' $all | grep -c .)"
echo "${found:-NONE}"
