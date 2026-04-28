# Spec: skills-consolidation

**Date**: 2026-04-28
**Feature**: skills-consolidation
**Cycle**: atom-flow 자체에 적용하는 메타 사이클

## 개요

atom-flow의 스킬 디렉토리 구조를 2-tier(`skills/` + `shared-skills/`)에서 1-tier(`skills/` 단일)로 단일화한다. 동시에 `shared-skills/writing-clearly-and-concisely`를 제거한다(자동 흐름과 직교하는 외딴 스킬). 같은 사이클에 카탈로그 잔재(`copy-feature`)를 정리하고 디렉토리 구조도를 갱신한다.

## 정체성·위치

- **위치**: atom-flow plugin 자체 (`/Users/happyhsryu/dev/personal/atom-flow`)
- **사이클 종류**: 메타 — atom-flow plugin 코드를 atom-flow 워크플로우로 작업
- **영향 범위**: plugin 매니페스트, hook 스크립트, CLAUDE.md, 스킬 디렉토리

## 핵심 철학과의 정합

이 변경은 atom-flow의 다음 철학을 강화한다:

- **자유 호출 + 게이트 최소화**: shared-skills의 "예외 영역" 의미가 모호했음. 1-tier로 단일화해 "모든 스킬은 동등하게 자유 호출"이라는 본 철학과 일관성 회복.
- **외부 plugin과 공존**: 글쓰기 가이드 같은 직교 스킬은 외부 plugin(superpowers:elements-of-style 등)에 위임. atom-flow 카탈로그를 워크플로우 본질에 집중.
- **검증된 표준 추종**: omc(38개 스킬), superpowers(14개 스킬) 모두 1-tier `skills/`만 사용. 작은 하네스가 2-tier 유지할 이유 없음.

## 변경 작업 명세

### 1. 디렉토리 변경

| 작업 | 출처 | 대상 |
|---|---|---|
| 이동 | `shared-skills/using-atom-flow/` (전체 디렉토리) | `skills/using-atom-flow/` |
| 삭제 | `shared-skills/writing-clearly-and-concisely/` (전체 디렉토리, SKILL.md + elements-of-style.md + LICENSE 포함) | — |
| 삭제 | `shared-skills/` (비어있게 되므로) | — |

### 2. plugin.json 변경

**Before**:
```json
{
  "name": "atom-flow",
  ...
  "skills": ["./skills/", "./shared-skills/"],
  "hooks": { ... }
}
```

**After**: `skills` 필드 자체 제거. Claude Code 기본 위치(`skills/`)가 자동 스캔되므로 명시 불필요.

```json
{
  "name": "atom-flow",
  ...
  "hooks": { ... }
}
```

### 3. hooks/session-start.sh 경로 갱신

**Before** (line 9):
```bash
GUIDE="${PLUGIN_ROOT}/shared-skills/using-atom-flow/SKILL.md"
```

**After**:
```bash
GUIDE="${PLUGIN_ROOT}/skills/using-atom-flow/SKILL.md"
```

다른 로직(.atom-flow/ 존재 검사, GUIDE 존재 검사, stdout 출력)은 변경 없음.

### 4. .claude/CLAUDE.md 갱신

다음 섹션을 갱신·삭제한다:

| 섹션 | 작업 |
|---|---|
| "디렉토리 구조 (2-tier)" 도식 | 1-tier로 갱신 (shared-skills 블록 삭제) |
| "atom-flow 3-tier와의 차이" 섹션 | 제목과 본문 갱신 — 이제 단순 1-tier. "shared-skills 의미" 단락 삭제 |
| "스킬 카탈로그 / shared-skills" 표 | 표 자체 삭제 (또는 합쳐 단일 카탈로그로) |
| "스킬 카탈로그 / skills" 표 | `using-atom-flow` 행 추가, `copy-feature` 행 삭제 |

`copy-feature`는 이미 이전 커밋(`1d452ed remove copy-feature`)에서 코드 제거되었으나 카탈로그에 잔재. 본 사이클에서 카탈로그 잔재만 정리.

### 5. 변경하지 않는 것 (회귀 방지)

다음은 의식적으로 본 사이클에서 건드리지 않는다:

- 핵심 인간 게이트 2개 (brainstorming, 커밋 직전 검토·승인) — 동일하게 유지
- 자동 흐름 파이프라인 (brainstorming → spec → plan → exec → report) — 동일
- 안티패턴 목록 — 동일
- hook 정책(SessionStart, PreToolUse(Bash:git commit)) — 동작 동일, 경로만 갱신
- 다른 스킬 본문 — 본 사이클에서 미수정

## 산출물 구조 (변경 후)

```
atom-flow/
├── .claude-plugin/
│   └── plugin.json              # skills 필드 제거됨
├── .claude/
│   └── CLAUDE.md                # 카탈로그·구조도 갱신됨
├── README.md
├── hooks/
│   ├── session-start.sh         # GUIDE 경로 갱신됨
│   └── pre-commit-report-sync.sh
└── skills/                      # 단일 tier
    ├── brainstorming/
    ├── design-review/
    ├── handoff/
    ├── implementing/
    ├── updating-report/
    ├── using-atom-flow/         # ← 이동됨
    ├── writing-plan/
    ├── writing-report/
    └── writing-spec/
```

(`shared-skills/` 디렉토리 사라짐, `writing-clearly-and-concisely` 사라짐)

## 영향 분석 (회귀 위험 검사)

| 영향 지점 | 위험 | 완화 |
|---|---|---|
| SessionStart hook이 GUIDE를 못 찾으면 stderr 경고 후 exit 0 | 자동 흐름 진입 가이드 누락 | hooks/session-start.sh 경로 갱신을 동일 커밋에 포함. plan 단계에서 두 변경의 동시성 강제 |
| plugin.json `skills` 필드 삭제 후 Claude Code가 `skills/` 인식 못 함 | 모든 스킬 미발견 | docs상 default 스캔 명시(line 506-514). 신뢰 가능 |
| shared-skills/writing-clearly-and-concisely를 다른 곳에서 호출 중일 위험 | 호출 깨짐 | 본 사이클 plan 단계에서 grep 검증 (`grep -r "writing-clearly-and-concisely" .`로 잔재 호출 확인) |
| CLAUDE.md 갱신 누락 시 카탈로그 drift | 사용자 혼동 | plan 단계 task에 명시, design-review에서 검증 |

## 비범위

다음은 의식적으로 본 사이클에서 다루지 않는다:

- **PostCompact hook 추가**: 이전 대화에서 검토. 별도 사이클로 분리.
- **writing-spec/plan/report 본문에 외부 글쓰기 plugin 안내 한 줄**: 선택사항이며 본 사이클 핵심 결정과 분리.
- **copy-feature 스킬 코드 자체**: 이미 이전 커밋(`1d452ed`)에서 제거됨. 본 사이클은 카탈로그 잔재만 정리.
- **session-start.sh의 wrapping 강화** (`<ATOM_FLOW_CRITICAL>` 태그 등): 별도 사이클.

## 미해결 결정 (Plan/Exec로 미루지 않음 — 모두 brainstorming에서 확정)

해당 없음. brainstorming Q1~Q3에서 모두 확정.

## Terminal output schema

```
{ status: success, summary: "spec written & approved for skills-consolidation", next: writing-plan, artifacts: [".atom-flow/spec/2026-04-28-skills-consolidation-spec.md"] }
```
