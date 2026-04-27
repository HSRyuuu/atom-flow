---
name: handoff
description: 사용자 명시 호출 시 .atom-flow/handoff/{date}-{feature}-handoff.md 생성. 대화 맥락 + 산출물 경로 인덱싱. 진행 중 흐름은 멈추지 않는다.
---

# handoff

사용자가 "/handoff" 또는 자연어 "여기까지 export 해줘"라고 했을 때 호출. 비상 출구 + 인계 도구.

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| (없음) | `none` | — | 트리거 전용. 현재 `.atom-flow/` 상태와 대화 컨텍스트를 자체 수집한다. |

## 출력

- `.atom-flow/handoff/{YYYY-MM-DD}-{feature_name}-handoff.md`
- 같은 날·같은 feature가 이미 있으면 `{YYYY-MM-DD}-{feature_name}-handoff-{HHMMSS}.md` 형식으로 타임스탬프 suffix 추가.

## 표준 구조

```markdown
# Hand-off — {feature_name} ({timestamp})

## 현재 작업 컨텍스트
{사용자와 합의한 의도·제약·미해결 결정 요약. 1-3문단}

## 진행 단계
- 현재 단계: {brainstorming | spec 작성 후 | plan 작성 후 | exec 진행 중 | report 작성 후, 커밋 직전}
- 마지막 사용자 승인: {언제·무엇}

## 산출물 인덱스
- Spec: .atom-flow/spec/{...}-spec.md (작성 완료 / 진행 중 / 없음)
- Plan: .atom-flow/plan/{...}-plan.md (작성 완료 / 진행 중 / 없음)
- Report: .atom-flow/report/{...}-report.md (작성 완료 / 진행 중 / 없음)

## 미해결·다음 액션
- {이어받는 사람·에이전트가 가장 먼저 해야 할 일}
- {결정 보류 중인 항목}

## 대화 요점 (압축)
{LLM이 요약한 brainstorming 핵심 결정 흐름. 5-15줄}
```

## 절차

1. 디렉토리 보장: `mkdir -p .atom-flow/handoff`
2. 현재 진행 중 feature_name 추정 (가장 최근 spec/plan/report 파일명에서 추출). 추정 실패(산출물 없음·이름 불일치) 시 `unknown-{HHMMSS}` 형식으로 fallback.
3. 파일명 조립 — 같은 날·feature 충돌(동일 경로 파일이 이미 존재) 시 `HHMMSS` suffix 부여
4. 현재 단계 추정 (어느 산출물 파일까지 존재하는가로 판정). 산출물이 하나도 없으면 단계는 `pre-brainstorming`으로 표기.
5. 대화 맥락을 5-15줄로 압축 (사용자 결정·미해결 항목·왜 멈추는지)
6. handoff 파일 작성
7. 사용자에게 파일 경로 안내

## 흐름 영향 없음

- 진행 중인 자동 흐름을 멈추지 않는다. 멈추는 건 사용자가 결정.
- 정상 완료(커밋) 시점에는 호출되지 않는다 — 명시 export 전용.

## Terminal state

handoff 파일 생성 + 경로 안내. 다른 스킬을 자동으로 이어 호출하지 않는다.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success, summary: "handoff exported at <stage>", next: user, artifacts: [".atom-flow/handoff/<file>"] }`
