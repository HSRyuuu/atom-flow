# atom-flow

워크플로우 자동화에 본질을 둔 Claude Code 에이전트 하네스. brainstorming만 인간 게이트, 그 후 spec → plan → exec → report가 자동으로 흐르고 커밋 직전에만 사용자 승인.

## 설치

이 디렉토리를 Claude Code plugin으로 등록한다.

```bash
# 1. 이 레포 clone (이미 했다면 생략)
cd ~/dev/personal && git clone <repo-url> atom-flow

# 2. Claude Code에 plugin 경로 등록
# ~/.claude/settings.json 또는 프로젝트 .claude/settings.json의 plugins 배열에 추가:
# {
#   "plugins": ["/Users/<you>/dev/personal/atom-flow"]
# }
```

## 사용

소비 프로젝트에서:

1. `.atom-flow/` 디렉토리를 만든다 (또는 첫 brainstorming이 자동 생성)
2. Claude Code 세션 시작 — `SessionStart` hook이 자동 발동하여 워크플로우 가이드를 LLM에 주입
3. 자연어로 "X를 만들어줘" 또는 `/brainstorming`을 호출
4. 흐름은 자동: **brainstorming(인간 게이트)** → spec → plan → exec → report → **커밋 직전 사용자 승인**

## 디렉토리 구조

소비 프로젝트 산출물:

```
{프로젝트}/
└── .atom-flow/
    ├── spec/{date}-{feature}-spec.md    # brainstorming 합의 결과
    ├── plan/{date}-{feature}-plan.md    # 구현 가능 단위 분해
    ├── report/{date}-{feature}-report.md  # 살아있는 구현 문서 (코드와 함께 커밋)
    └── handoff/{date}-{feature}-handoff.md  # 명시 export 시에만, feature별 누적
```

## 스킬

### 워크플로우 핵심 (`skills/`)

| 스킬 | 역할 |
|---|---|
| `brainstorming` | 사용자 대화로 의도·요구·design 결정 → writing-spec 호출 |
| `writing-spec` | brainstorming 합의를 spec.md로 저장 → writing-plan 자동 호출 |
| `writing-plan` | spec → plan 작성 + design-review 셀프 리뷰 → implementing 자동 호출 |
| `design-review` | plan.md를 7-dimension으로 평가·보강 (재시도 상한 3회) |
| `implementing` | plan → 코드 변경 + 매핑 셀프 리뷰 → writing-report 자동 호출 |
| `writing-report` | exec 완료 후 살아있는 구현 문서 초기 작성 |
| `updating-report` | 검토 루프·커밋 직전 report in-place 갱신 |
| `handoff` | 명시 export 시 대화 맥락 + 산출물 인덱스 저장 |
| `copy-feature` | 외부 기능·아이디어 이식 가능성 판정 및 추출 |

### 보조 (`shared-skills/`)

| 스킬 | 역할 |
|---|---|
| `writing-clearly-and-concisely` | Strunk 글쓰기 원칙. spec/plan/report 작성 시 단발 호출 가능 |
| `using-atom-flow` | SessionStart hook이 주입하는 워크플로우 진입 가이드 |

## Hook

| Hook | 스크립트 | 동작 |
|---|---|---|
| `SessionStart` | `hooks/session-start.sh` | `.atom-flow/` 감지 시 워크플로우 가이드 LLM 주입 |
| `PreToolUse(Bash: git commit)` | `hooks/pre-commit-report-sync.sh` | 커밋 직전 report 동기화 알림 |

## 철학

자세한 내용은 [CLAUDE.md](CLAUDE.md) 참조.

핵심만 요약:
- **인간 게이트 2곳**: brainstorming 대화 + 커밋 직전 검토·승인 (report 검토 루프 + 최종 승인을 합친 단일 게이트 윈도우). 차단 모드는 `AF_BLOCK_ON_STALE_REPORT=1`로 활성화
- **스킬 자유 호출**: 어느 스킬이든 다른 스킬을 직접 호출 가능, 시퀀스 본문에 박아도 됨
- **report = 살아있는 문서**: 코드와 같은 커밋에 묶이는 단일 진실원
- **hook 강제**: 자동 흐름의 견고성은 LLM 자율이 아닌 Claude Code hook이 보장
