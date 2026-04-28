---
name: using-atom-flow
description: atom-flow 플러그인 런타임 진입 가이드. 새 세션 시작 시 SessionStart hook이 자동 주입한다.
---

# using-atom-flow

이 프로젝트는 **atom-flow** 에이전트 하네스를 사용한다. `.atom-flow/` 디렉토리가 감지되었으므로 이 가이드가 자동 주입되었다. 아래 규약을 세션 시작부터 일관되게 따른다.

---

## 1. 정체성

`atom-flow`는 **워크플로우 자동화에 본질을 둔 에이전트 하네스**다. brainstorming만 인간 게이트로 두고, 그 이후 spec → plan → exec → report는 자동으로 흐른다. 커밋 직전에만 사용자 승인을 받는다.

- 스킬은 자유롭게 서로 호출하고 시퀀스를 본문에 박을 수 있다.
- 별도 메타 라우팅(suggest-next-step, announce-completion) 없음.
- hook이 자동 흐름의 견고성을 시스템 레벨에서 보장한다.

---

## 2. 핵심 철학

1. **자동 흐름 기본** — brainstorming 이후 spec → plan → exec → report는 자동으로 흐른다. LLM이 매 단계 사용자에게 결정권을 넘기지 않는다.
2. **인간 게이트는 두 곳뿐** — (1) brainstorming 도중 질문·결정, (2) 커밋 직전 검토·승인 (report 검토 루프 + 최종 승인을 합친 단일 게이트 윈도우).
3. **스킬 자유 호출** — 어느 스킬이든 다른 스킬을 직접 호출 가능. 시퀀스를 본문에 박아도 된다.
4. **셀프 리뷰는 흐름의 일부** — 별도 인간 결재 없이 작성 직후 인라인 점검·수정. 실패 시 자동 재시도 상한 3회. 3회 초과 시 사용자 보고 후 진행 여부 결정.
5. **report = 살아있는 구현 문서** — 단계 메타 로그가 아니라 "현재 무엇이 어떻게 구현됐는지"의 단일 진실원. 코드와 같은 커밋에 묶인다.
6. **hook으로 강제** — 자동 흐름의 견고성은 LLM 자율에 의존하지 않고 Claude Code hook이 보장한다.

---

## 3. 워크플로우 다이어그램

```
[ 사용자 요청 ]
     ↓
1. brainstorming                ← 인간 게이트 (질문·결정 대화)
     ↓
   spec.md 작성 (writing-spec)
     ↓
=== 자동 흐름 시작 ===
     ↓
2. plan 작성 + 셀프 리뷰         ← writing-plan이 design-review 호출
     ↓
   plan.md 작성
     ↓
3. exec (코드 구현) + 셀프 리뷰  ← plan ↔ 구현 매핑 점검
     ↓
4. report 강제 작성 (writing-report)
     ↓
   사용자 검토 루프              ← 수정 요청 시:
   ├─ 코드 수정 (필요 시 updating-report로 report 갱신, LLM 자율)
   └─ (반복)
     ↓
5. 사용자 승인 게이트             ← 유일한 후속 인간 게이트
     ↓
   git commit 실행
     ├─ PreToolUse hook 자동 발동 → updating-report로 report 최종 동기화
     └─ code + report 함께 커밋됨
     ↓
=== 사이클 종료 ===

(다음 변경은 새 brainstorming/spec/plan/exec/report 사이클로 시작)
```

---

## 4. 인간 게이트 & 셀프 리뷰 정책

### 인간 게이트 (정확히 두 곳)

| 위치 | 내용 |
|---|---|
| brainstorming 단계 | 사용자와 의도·요구·design 결정 대화. spec 합의까지. |
| 커밋 직전 | report 검토 루프 + 최종 승인. 같은 게이트 윈도우 안에서 수정 요청·재구현·재검토 반복 가능. |

- **그 외 모든 단계는 자동**. 셀프 리뷰는 흐름의 일부, 별도 인간 결재 없음.
- 검토 루프 안에서 코드 수정 + report 갱신은 항상 같은 사이클·같은 게이트에 묶인다.
- 커밋 이후 추가 변경도 새 brainstorming부터 새 사이클로 진입한다.

### 셀프 리뷰 재시도 정책

- design-review·implementing 셀프 리뷰가 통과하지 못하면 같은 스킬 본문 안에서 자동 재시도
- **상한: 3회**
- 3회 초과 시 → 사용자에게 실패 사유·시도 내역 보고 후 진행 여부 결정 (자동 진행 안 함)

---

## 5. 산출물 디렉토리 규약

이 플러그인이 생성하는 모든 문서는 작업 디렉토리 기준 `.atom-flow/` 아래에 둔다.

| 경로 | 역할 |
|---|---|
| `.atom-flow/spec/{date}-{feature}-spec.md` | brainstorming 합의 결과 |
| `.atom-flow/plan/{date}-{feature}-plan.md` | plan 작성 + 셀프 리뷰 통과 |
| `.atom-flow/report/{date}-{feature}-report.md` | exec 완료 시 강제 작성, 살아있는 구현 문서 |
| `.atom-flow/handoff/{date}-{feature}-handoff.md` | 명시 export 시에만, feature별 누적 |

- 폴더가 없으면 먼저 생성한다.
- 외부 경로(루트 `docs/`, 임의 경로)에 산출물을 떨어뜨리지 않는다.
- `exec/` 폴더는 없다 — 실제 코드는 프로젝트 코드베이스에 직접 들어가고, 매핑은 report에 모인다.

---

## 6. 스킬 카탈로그 (`skills/` — 9개)

| 스킬 | 역할 | 자동/수동 |
|---|---|---|
| `brainstorming` | 사용자 대화로 의도·요구·design 결정. 마지막에 writing-spec 호출 | 인간 대화 |
| `writing-spec` | brainstorming 합의를 `.atom-flow/spec/`에 저장. 직후 writing-plan 호출 | 자동 |
| `writing-plan` | spec.md → plan.md 작성. 직후 design-review 호출해 셀프 리뷰. 통과 시 implementing 호출 | 자동 |
| `design-review` | plan.md를 7-dimension으로 평가하고 plan.md 직접 편집·보강. 재시도 상한 3회 | 자동 |
| `implementing` | plan.md → 실제 코드 변경 + plan ↔ 구현 매핑 셀프 리뷰. 통과 시 writing-report 호출 | 자동 |
| `writing-report` | exec 완료 후 report 강제 작성 (살아있는 문서 초기 형태). 건너뛸 수 없음 | 자동 |
| `updating-report` | 검토 루프 내 코드 수정 시 report 동기 갱신. LLM 자율 호출 + PreToolUse hook 강제 | LLM 자율 + hook |
| `handoff` | `.atom-flow/handoff/` 생성 — 대화 맥락 + 산출물 경로 인덱싱 | 수동 트리거 |
| `using-atom-flow` | 이 파일. SessionStart hook이 주입할 가이드 본문 | hook 강제 주입 |

---

## 6.5. 표준 입출력 schema

모든 워크플로우 스킬은 동일한 입출력 schema를 따른다. 자연어 대화로 요약하면 충분 — 별도 JSON 직렬화는 강제하지 않는다. 단일 정의는 이 절이고, 각 SKILL.md는 자기 고유 값만 채워 한 줄로 인용한다.

### 6.5.1. 입력 schema

각 스킬의 SKILL.md `## 입력` 섹션은 다음 표 형식을 따른다.

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|

타입 enum:
- `path` — `.atom-flow/` 산출물 경로 (예: `.atom-flow/plan/<file>`)
- `string` — 자유 자연어 (예: `feature_name`, 변경 요약)
- `enum<a | b | c>` — 정의된 값 집합
- `none` — 입력 필드 없음. 진입 스킬(사용자 발화·세션 컨텍스트가 사실상의 입력)이거나 트리거-온리 스킬에 사용

### 6.5.2. 정상 종료 output schema

```
{ status, summary, next, artifacts }
```

- `status`: `success` | `warning` (warning은 산출물은 만들었으나 권장 임계 미달일 때)
- `summary`: 한 줄. **자기 작업 결과만** 적는다 — 다음 스킬의 결과를 미리 흡수하지 않는다.
- `next`: 호출 그래프상의 다음 대상. 다음 enum만 허용:
  - `<skill-name>` — 다음 스킬을 직접 호출 (자동 흐름)
  - `caller` — 호출자에게 제어 반환
  - `user` — 사용자에게 제어 반환 (대화 게이트)
- `artifacts`: **path 배열**만. 인라인 텍스트는 쓰지 않고 summary로 흡수한다. 산출물이 없으면 `[]`.

### 6.5.3. 비정상 종료(error) 보고 포맷

셀프 리뷰 3회 초과 실패 등 비정상 종료에는 다음 schema를 사용한다.

```
{ status: error, summary, next: user, artifacts, error: { reason, attempts, last_state, recommended_next_actions } }
```

- `status`: `error`
- `next`: 항상 `user` (자동 흐름을 끊고 사용자 결정으로 인계)
- `error.reason` — 무엇이 실패했는가 (한 줄)
- `error.attempts` — 각 재시도(최대 3회)의 결과 요약 배열. 시도별로 "무엇을 바꿨고 왜 통과 못했는지"
- `error.last_state` — 부분 편집된 산출물의 경로와 상태 (예: "plan.md Pass 4까지 보강, Pass 5에서 차단")
- `error.recommended_next_actions` — 사용자에게 제시할 옵션 2-3개. 표준 후보:
  - **재시도** — `last_state`의 마지막 실패 step부터 재진입
  - **현재 상태로 강행** — 산출물 그대로 다음 스킬 호출
  - **`handoff` 호출** — 인계 export 후 사이클 중단

재진입 진입점은 `error.last_state`가 기록한 마지막 성공 step 다음부터다 — 항상 step 1부터 다시 돌리지 않는다.

---

## 7. Hook 정책

### SessionStart (`hooks/session-start.sh`)

- **트리거**: 새 세션 시작 시 자동
- **동작**: `.atom-flow/` 디렉토리 존재 감지 → 이 가이드(`using-atom-flow/SKILL.md`) 전체를 `<EXTREMELY_IMPORTANT>` 블록으로 감싸 stdout 출력
- **효과**: LLM이 세션 시작 직후부터 atom-flow 규약을 따름

### PreToolUse: Bash `git commit` (`hooks/pre-commit-report-sync.sh`)

- **트리거**: Bash 도구로 `git commit` 실행 직전
- **동작**:
  1. `.atom-flow/report/` 안에서 가장 최근 report.md 식별
  2. report.md mtime vs staged 파일 mtime 비교
  3. staged 파일이 더 최신이면 `updating-report` 스킬 호출 안내 메시지를 stdout으로 출력
  4. report가 최신이거나 진행 중 사이클이 없으면 통과
- **특징**: 기본은 차단하지 않음 — 경고 안내만. 의도적으로 건너뛰는 경우 그대로 진행 가능.
- **차단 모드**: `AF_BLOCK_ON_STALE_REPORT=1` 환경변수가 설정되면 stale 시 `exit 2`로 커밋을 차단한다. CI 또는 엄격한 강제가 필요한 환경에서 사용.

---

## 8. 행동 지침

### 새 작업 시작 시

1. 사용자가 새 feature를 요청하면 → **반드시 `brainstorming` 스킬부터 시작**한다
2. brainstorming이 끝나면 `writing-spec`을 자동 호출해 spec을 저장한다
3. 사용자 승인 후 `writing-plan` → `design-review` → `implementing` → `writing-report` 순으로 자동 흐름

### 진행 중 작업

- 각 스킬은 종료부에서 다음 스킬을 직접 호출한다 — 사용자에게 "다음은 무엇을 할까요?" 묻지 않는다
- 셀프 리뷰 실패 시 자동 재시도 (상한 3회). 3회 초과 시에만 사용자 보고
- 코드 수정이 발생하면 LLM 자율로 `updating-report` 호출. 커밋 직전 hook이 최종 동기화를 보장

### 커밋 전

- 사용자 승인 요청 (유일한 후속 인간 게이트)
- git commit 직전 PreToolUse hook이 자동 발동 — report stale 시 안내 메시지 수신
- 안내 수신 시 `updating-report` 호출 후 커밋 진행
- code + report가 같은 커밋에 묶이도록 staging을 확인

### 금지 사항

- ❌ 매 단계 "다음 단계를 선택해 주세요" 라우팅 — 자동 흐름을 끊는 행위
- ❌ report 건너뛰기 — `writing-report`는 exec 후 강제, 건너뛸 수 없음
- ❌ 외부 경로에 산출물 작성 — `.atom-flow/` 외부 금지
- ❌ 동일 커밋에 report 없이 코드만 커밋 — hook이 경고하면 반드시 대응
- ❌ atom-flow 패턴 재도입 — update-report 메타 호출, announce-completion, suggest-next-step, atom-catalog.md

---

## 빠른 참조

| 상황 | 행동 |
|---|---|
| 새 작업 요청 | `brainstorming` 호출 |
| 중간에 인계·export 필요 | `handoff` 호출 |
| 커밋 준비 완료 | 사용자 승인 요청 → hook 안내 확인 → 커밋 |
| 셀프 리뷰 3회 초과 | 사용자 보고, 진행 여부 결정 위임 |
