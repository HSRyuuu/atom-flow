---
name: implementing
description: plan.md를 받아 실제 코드 변경을 실행한다. 각 task의 step을 순차 실행하고 plan ↔ 구현 매핑 셀프 리뷰 후 writing-report 호출.
---

# implementing

plan.md 한 파일을 받아 그 안의 task·step을 순차로 실행해 코드 변경을 만든다.

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `plan_path` | `path` | ✅ | `.atom-flow/plan/<file>` — design-review를 통과한 plan |

## 출력

- 실제 코드 변경 (프로젝트 코드베이스에 직접 적용)
- task의 step 체크박스 상태 갱신 (`- [ ]` → `- [x]`)
- 각 task 완료 시 task 단위 커밋 (plan에 명시된 commit 메시지 사용)

## 절차

1. **plan.md를 읽어 task·step 구조 파악**
2. **각 task를 순차 실행**:
   - task의 Files 섹션에서 Create/Modify/Test 경로 확인
   - 각 step을 순차 수행 (코드 작성, 테스트 실행, 커밋)
   - step 완료 시 plan.md의 체크박스를 `- [x]`로 갱신
3. **모든 task 완료 후 self-review**:
   - plan ↔ 구현 매핑 점검: 모든 task의 모든 step이 체크됐는가
   - 빌드·테스트 통과 확인
   - plan에서 벗어난 결정이 있다면 기록
4. **self-review 통과 시 `writing-report` 직접 호출** (자동 흐름)

## 셀프 리뷰 실패 재시도

self-review에서 빌드 실패·테스트 실패 등이 발견되면 자동 재시도 (상한 3회). 3회 초과 시 사용자에게 실패 내역·시도 기록을 보고하고 진행 여부 결정을 받는다 (자동 진행 안 함).

## 자유 호출

- 코딩 표준이 필요하면 그 표준 스킬을 단발 호출 (예: 향후 등록될 standards-equivalent).
- 디버깅이 필요하면 `oh-my-claudecode:debug` 등 외부 스킬을 단발 호출 가능.

## Terminal state

모든 task 체크 완료 + self-review 통과 + `writing-report` 호출. 별도 완료 통보 없음.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success | warning, summary: "<n> tasks completed, build/tests OK", next: writing-report, artifacts: [<changed file paths>] }`

3회 초과 실패 시 **using-atom-flow §6.5.3 error schema**로 보고하고 `next: user`로 인계한다 — `error.last_state`에는 마지막으로 통과한 task·step 번호와 빌드·테스트 실패 위치를 기록한다.
