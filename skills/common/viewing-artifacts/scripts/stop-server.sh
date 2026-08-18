#!/usr/bin/env bash
# Stop a serve.py preview by PID. Refuses to signal a process that is not a
# serve.py preview: a recorded PID can be reused by an innocent process
# between the preview's death and a late stop.
set -uo pipefail

case "${1-}" in
  -h|--help)
    cat <<'EOF'
stop-server.sh — stop a governed localhost preview.

  stop-server.sh PID    stop the serve.py process with this PID
  --help                this text

Exit codes: 0 stopped, or already gone · 1 PID is not a serve.py preview
(refused) · 2 bad arguments
EOF
    exit 0;;
esac

pid="${1-}"
case "$pid" in ''|*[!0-9]*) echo '{"error": "needs a numeric PID"}' >&2; exit 2;; esac

if ! kill -0 "$pid" 2>/dev/null; then
  echo "{\"type\": \"server-stopped\", \"pid\": $pid, \"note\": \"already gone\"}"
  exit 0
fi

cmd="$(ps -p "$pid" -o command= 2>/dev/null)"
case "$cmd" in
  *serve\.py*) ;;
  *) echo "{\"error\": \"PID $pid is not a serve.py preview — refusing to kill it\"}" >&2; exit 1;;
esac

kill "$pid" 2>/dev/null
for _ in $(seq 1 50); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
if kill -0 "$pid" 2>/dev/null; then
  echo "{\"error\": \"PID $pid did not exit after SIGTERM\"}" >&2
  exit 1
fi
echo "{\"type\": \"server-stopped\", \"pid\": $pid}"
exit 0
