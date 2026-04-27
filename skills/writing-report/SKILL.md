---
name: writing-report
description: implementing 완료 후 .atom-flow/report/{date}-{feature}-report.md를 강제 작성한다. 살아있는 구현 문서의 초기 형태.
---

# writing-report

exec 완료 후 report 강제 작성. 건너뛸 수 없다.

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `spec_path` | `path` | ✅ | `.atom-flow/spec/<file>` — 같은 feature의 spec |
| `plan_path` | `path` | ✅ | `.atom-flow/plan/<file>` — implementing이 실행한 plan |
| `change_summary` | `string` | ⬜ | implementing이 만든 변경 요약. 생략 시 plan 체크박스·git diff에서 재구성 |

## 출력

- `.atom-flow/report/{YYYY-MM-DD}-{feature_name}-report.md`

## 표준 구조

`Status`·`Last commit` 같은 커밋 추적 메타 필드는 두지 않는다 — git 자체가 커밋 추적의 권위 있는 기록이고, report에 추가 추적을 두면 동기화 부담만 늘어난다.

```markdown
# Report — {feature_name}

**Spec**: .atom-flow/spec/{date}-{feature}-spec.md
**Plan**: .atom-flow/plan/{date}-{feature}-plan.md

## 구현 요약
{한두 문단으로 "지금 이 feature가 무엇이고, 어떻게 동작하는지" 기술. 코드와 함께 진화한다.}

## Plan ↔ 구현 매핑
| Plan 항목 | 상태 | 위치 (파일·심볼) | 비고 |
|---|---|---|---|
| ... | ✅ 구현 / ⏸ 보류 / ❌ 폐기 | src/foo.ts:doBar() | ... |

## 실제 변경 요약
- 추가: {파일들}
- 수정: {파일들}
- 테스트: {파일·통과 수}

## Plan에서 조정된 사항
{구현 중 발견해 spec/plan에서 벗어난 결정·이유}

## 미구현·후속·기술 부채
- [ ] ...

## 검증
- 빌드: ✅
- 테스트: ✅ (n/n)
- 수동 확인: ...
```

## 절차

1. **디렉토리 보장**: `mkdir -p .atom-flow/report`
2. **plan.md를 읽어** 모든 task를 매핑 표 항목으로 변환
3. **implementing이 만든 변경**을 "실제 변경 요약"에 채움
4. **plan에서 벗어난 결정**을 "Plan에서 조정된 사항"에 기록
5. **빌드·테스트 결과**를 "검증" 섹션에 기록

## Terminal state

report.md 작성 완료. 호출자(implementing의 후속)가 사용자 검토 루프로 진입한다.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success, summary: "report initialized for <feature>", next: user, artifacts: [".atom-flow/report/<file>"] }`

`next: user`는 검토 루프 + 커밋 직전 승인이라는 단일 게이트 윈도우로의 진입을 의미한다.
