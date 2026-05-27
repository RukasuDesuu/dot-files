#!/usr/bin/env bash
set -euo pipefail

PLAYER="spotify"

# If Spotify is already exposing MPRIS, just toggle.
if playerctl -p "$PLAYER" status >/dev/null 2>&1; then
  playerctl -p "$PLAYER" play-pause
  exit 0
fi

# Otherwise, start Spotify (if not running) and wait for MPRIS to appear.
pgrep -x spotify >/dev/null 2>&1 || (spotify >/dev/null 2>&1 & disown)

# Wait up to ~10s for Spotify to register on MPRIS
for _ in {1..50}; do
  if playerctl -p "$PLAYER" status >/dev/null 2>&1; then
    playerctl -p "$PLAYER" play
    exit 0
  fi
  sleep 0.2
done

# If we got here, Spotify never showed up to playerctl.
exit 1
`
