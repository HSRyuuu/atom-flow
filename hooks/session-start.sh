#!/usr/bin/env bash
# SessionStart hook for atom-flow.
# Detects .atom-flow/ in CWD and injects using-atom-flow guide as system reminder.

set -eu

CWD="${CLAUDE_PROJECT_DIR:-$PWD}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
GUIDE="${PLUGIN_ROOT}/skills/using-atom-flow/SKILL.md"

# Skip injection if .atom-flow/ does not exist
if [ ! -d "${CWD}/.atom-flow" ]; then
  exit 0
fi

# Guide must exist; if not, fail visibly
if [ ! -f "${GUIDE}" ]; then
  echo "[atom-flow] guide not found at ${GUIDE}" >&2
  exit 0
fi

cat <<'EOF_HEADER'
<EXTREMELY_IMPORTANT>
이 프로젝트는 atom-flow 플러그인 워크플로우를 사용합니다 (.atom-flow/ 디렉토리 감지됨).

**아래는 using-atom-flow 스킬의 전체 내용입니다 — 이 플러그인의 진입 가이드.**

EOF_HEADER

cat "${GUIDE}"

cat <<'EOF_FOOTER'

</EXTREMELY_IMPORTANT>
EOF_FOOTER

exit 0
