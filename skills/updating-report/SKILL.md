---
name: updating-report
description: 검토 루프 내 코드 수정 또는 PreToolUse(git commit) hook에서 호출되어 report.md를 in-place 갱신한다.
---

# updating-report

이미 작성된 report.md를 갱신한다. 전체 재작성이 아니라 매핑 표·변경 요약·미구현 항목의 diff 갱신.

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `report_path` | `path` | ⬜ | `.atom-flow/report/<file>` — 생략 시 디렉토리 내 최신 파일을 자동 선택 |
| `change_summary` | `string` | ⬜ | 직전 코드 변경 요약. 생략 시 staged/working tree diff에서 재구성 |

## 출력

- 갱신된 `.atom-flow/report/<file>` (in-place)

## 절차

1. **현재 report.md를 읽어** 기존 매핑 표·변경 요약·미구현 항목 파싱
2. **직전 코드 변경(staged 또는 working tree)을 감지**
3. **변경된 항목을 매핑 표와 변경 요약에 반영** (없는 항목은 추가, 있는 항목은 갱신)
4. **plan ↔ 구현 매핑이 어긋난 부분**이 있으면 "Plan에서 조정된 사항"에 추가
5. **미구현·후속 항목을 검토**하여 완료된 것은 매핑 표로 옮기고 새로 발견된 것은 추가
6. **변경 요약 섹션에** 추가/수정 파일 목록 갱신

## 호출 시점

| 시점 | 트리거 | 비고 |
|---|---|---|
| 검토 루프 내 코드 수정 직후 | LLM 자율 호출 | 필수 아님 — 변경이 report와 어긋났다고 판단될 때 |
| 커밋 직전 | PreToolUse hook (`git commit`) 안내 | 강제 동기화. 코드와 report가 같은 커밋에 묶이도록 보장 |

LLM이 검토 루프에서 `updating-report` 호출을 잊더라도, 커밋 직전 PreToolUse hook이 무조건 동기화를 안내하므로 코드와 report가 어긋난 채 커밋되는 상태는 구조적으로 방지된다.

## Terminal state

report.md 갱신 완료. 호출자에게 제어 반환.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success, summary: "report synced with <n> changes", next: caller, artifacts: [".atom-flow/report/<file>"] }`
