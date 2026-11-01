#!/usr/bin/env bash
# Open the OpenCode desktop app with the free-team config, leaving ~/.config/opencode untouched.
# The app's server reads config from $XDG_CONFIG_HOME/opencode.
# Quit the app and reopen it normally to go back to your usual config.
set -euo pipefail
TEAM_HOME="$HOME/.config-freeteam"
XDG_CONFIG_HOME="$TEAM_HOME" "$(dirname "$0")/install.sh"
# Each background service needs its own port; your normal one already holds the default.
XDG_CONFIG_HOME="$TEAM_HOME" XDG_STATE_HOME="$HOME/.local/state-freeteam" opencode service set port 49375 >/dev/null
osascript -e 'quit app "OpenCode"' 2>/dev/null || true
while pgrep -xq OpenCode; do sleep 0.5; done
# App 2.x attaches to the background service listed in $XDG_STATE_HOME/opencode/service.json.
# A separate state folder makes it start its own service with the free-team config; keys in ~/.local/share stay shared.
open -a OpenCode --env "XDG_CONFIG_HOME=$TEAM_HOME" --env "XDG_STATE_HOME=$HOME/.local/state-freeteam"
echo "OpenCode app opened with the free-team config ($TEAM_HOME/opencode)."
