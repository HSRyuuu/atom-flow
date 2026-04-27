---
name: writing-spec
description: brainstorming에서 합의된 design을 .atom-flow/spec/{date}-{feature}-spec.md로 저장한다. brainstorming 종료부에서 호출되며, 작성 직후 writing-plan으로 자동 흐름이 이어진다.
---

# writing-spec

brainstorming이 사용자와 합의한 의도·요구·design을 spec 문서로 저장한다.

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `brainstorm_summary` | `string` | ✅ | brainstorming 결과의 요점 — 의도, 제약, design 결정, scope, 미해결 결정 |
| `feature_name` | `string` | ✅ | kebab-case 짧은 식별자 (파일명·이후 사이클에서 동일 값 사용) |

## 출력

- `.atom-flow/spec/{YYYY-MM-DD}-{feature_name}-spec.md`

## 절차

1. **디렉토리 보장**: `mkdir -p .atom-flow/spec`
2. **날짜 획득**: `date +"%Y-%m-%d"`
3. **파일명 조립**: `{date}-{feature_name}-spec.md`
4. **spec 문서 작성**. 표준 섹션:
   - 개요 (한 문단으로 무엇·왜)
   - 정체성·위치 (위치·이름·관계)
   - 핵심 철학 (채택·폐기 항목)
   - 워크플로우 / 동작 명세
   - 디렉토리·산출물 구조
   - 스킬·구성요소 카탈로그
   - 자산 이식·재사용 (있을 때)
   - 미해결 결정 (Plan/Exec로 미룬 것)
5. **inline self-review**:
   - placeholder scan (TBD/TODO/모호한 requirement → 고침)
   - internal consistency (섹션 간 모순 → 고침)
   - scope check (single plan에 담을 만한가)
   - ambiguity check (두 가지로 해석 가능한 부분 → 한쪽으로 명시)
6. **사용자에게 spec 경로 안내** + 검토 요청
7. **사용자 승인 후 `writing-plan` 스킬을 직접 호출** (자동 흐름)

## 자유 호출

- `shared-skills/writing-clearly-and-concisely`를 단발로 호출해 prose 품질을 높여도 된다.
- 추가 정보 수집을 위해 다른 스킬을 호출해도 된다.

## Terminal state

spec 파일 작성 + 사용자 승인 + `writing-plan` 호출. 별도 완료 통보 스킬 없음 — `writing-plan`이 그대로 이어 실행된다.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success, summary: "spec written & approved for <feature>", next: writing-plan, artifacts: [".atom-flow/spec/<file>"] }`
