#!/usr/bin/env bash
# PreToolUse hook for atom-flow.
# Triggered before any Bash tool. Filters for `git commit` patterns; for those,
# checks if report.md is stale relative to staged changes. If stale, asks LLM
# to call updating-report before proceeding.
#
# Hook input arrives as JSON on stdin (per Claude Code hook spec):
#   { "tool_name": "Bash", "tool_input": { "command": "..." } }
# Hook output: stdout content becomes additional context for LLM.

set -eu

CWD="${CLAUDE_PROJECT_DIR:-$PWD}"

# Read stdin JSON. If parsing fails, fall through silently.
INPUT="$(cat || true)"
if [ -z "${INPUT}" ]; then exit 0; fi

# Fast pre-filter: skip JSON parse cost when input clearly is not a git commit.
case "${INPUT}" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# Extract command. Use python3 for safe JSON parsing (no jq dependency).
COMMAND="$(printf '%s' "${INPUT}" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    cmd = data.get("tool_input", {}).get("command", "")
    print(cmd)
except Exception:
    pass
' 2>/dev/null || true)"

# Only act on git commit invocations (re-check against parsed command).
case "${COMMAND}" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# Skip if no .atom-flow/report/ directory
REPORT_DIR="${CWD}/.atom-flow/report"
if [ ! -d "${REPORT_DIR}" ]; then exit 0; fi

# Find latest report file
LATEST_REPORT="$(ls -t "${REPORT_DIR}"/*-report.md 2>/dev/null | head -1 || true)"
if [ -z "${LATEST_REPORT}" ]; then exit 0; fi

# Compare report mtime vs staged file mtime
REPORT_MTIME="$(stat -f %m "${LATEST_REPORT}" 2>/dev/null || stat -c %Y "${LATEST_REPORT}" 2>/dev/null || echo 0)"

# Check staged files (anything in `git diff --cached --name-only`)
STAGED="$(cd "${CWD}" && git diff --cached --name-only 2>/dev/null || true)"
STALE=0
if [ -n "${STAGED}" ]; then
  while IFS= read -r f; do
    [ -z "${f}" ] && continue
    [ ! -f "${CWD}/${f}" ] && continue
    F_MTIME="$(stat -f %m "${CWD}/${f}" 2>/dev/null || stat -c %Y "${CWD}/${f}" 2>/dev/null || echo 0)"
    if [ "${F_MTIME}" -gt "${REPORT_MTIME}" ]; then
      STALE=1
      break
    fi
  done <<EOF_STAGED
${STAGED}
EOF_STAGED
fi

if [ "${STALE}" -eq 1 ]; then
  cat <<EOF_NOTICE
[atom-flow] PreToolUse hook 알림:
  staged 파일이 report보다 새롭습니다 — ${LATEST_REPORT}
  커밋 진행 전 \`updating-report\` 스킬을 호출해 report를 동기화하는 것을 권장합니다.
  (기본은 경고만, 차단 안 함. AF_BLOCK_ON_STALE_REPORT=1 환경변수로 차단 모드 활성화 가능.)
EOF_NOTICE
  if [ "${AF_BLOCK_ON_STALE_REPORT:-0}" = "1" ]; then
    echo "[atom-flow] AF_BLOCK_ON_STALE_REPORT=1 — stale report 감지, 커밋 차단." >&2
    exit 2
  fi
fi

exit 0
