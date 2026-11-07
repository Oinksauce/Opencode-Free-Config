#!/usr/bin/env bash
# Check the installed free-team config: every model in the lists answers, then the team works together.
# Uses whatever config OpenCode would use here (respects XDG_CONFIG_HOME, e.g. ~/.config-freeteam).
#   ./test.sh          models + team
#   ./test.sh models   models only (fast)
#   ./test.sh team     team only
set -uo pipefail
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode/oh-my-opencode-slim.jsonc"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
cd "$WORK"
run() { timeout "$1" opencode run --standalone --auto "${@:2}" 2>&1; }
fail=0

if [ "${1:-}" != team ]; then
  echo "== Models (from $CFG)"
  models=$(python3 - "$CFG" <<'EOF'
import json, os, re, sys
cfg = json.loads(re.sub(r'^\s*//.*$', '', open(sys.argv[1]).read(), flags=re.M))
seen = []
for agent in cfg['presets'][os.environ.get('OH_MY_OPENCODE_SLIM_PRESET') or cfg['preset']].values():
    for m in agent['model'] if isinstance(agent['model'], list) else [agent['model']]:
        if m not in seen: seen.append(m)
print('\n'.join(seen))
EOF
)
  for m in $models; do
    # Whole output, not the last line: OpenCode can print a shutdown notice after the answer.
    out=$(run 90 -m "$m" "Reply with just: ok")
    if grep -qiE '^ok\b' <<<"$out"; then echo "PASS $m"; else echo "FAIL $m  $(tail -1 <<<"$out" | cut -c1-100)"; fail=1; fi
  done
fi
[ "${1:-}" = models ] && exit $fail

echo "== Team: two helpers at once on a small job"
printf 'def add(a, b):\n    return a - b\n\ndef average(xs):\n    return sum(xs) / len(xs) + 1\n' > calc.py
# Not background jobs: `opencode run` exits when the main turn ends, which would cut them off.
run 600 "Use your helpers in parallel: send @explorer to describe calc.py and @fixer to fix every bug in it, in the same step so they run at the same time, not as background jobs, and wait for both. Then tell me which helper and which model did each part." | tail -15
echo "-- calc.py after:"; cat calc.py
python3 -c "from calc import add, average; assert add(2,3)==5 and average([2,4])==3; print('PASS team fixed both bugs')" || { echo "FAIL team result"; fail=1; }
exit $fail
