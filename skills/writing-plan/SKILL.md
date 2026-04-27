---
name: writing-plan
description: spec이나 requirement가 있고 multi-step task를 시작하기 전에 사용. 구현 가능한 단위로 plan을 분해한다. 입력은 `.atom-flow/spec/`의 spec 파일, 출력은 `.atom-flow/plan/`의 plan 파일.
---

# Writing Plan

## Overview

Engineer가 우리 codebase에 zero context를 가지고 있고 취향도 의심스럽다고 가정하고 포괄적인 implementation plan을 작성한다. 그가 알아야 할 모든 것을 문서화한다 — 각 task에 어떤 파일을 건드릴지, 코드, testing, 참고할 docs, 어떻게 test할지. 전체 plan을 bite-sized task로 쪼개 준다. DRY. YAGNI. TDD. 잦은 commit.

Engineer는 숙련된 개발자지만 우리 toolset과 problem domain은 거의 모른다고 가정한다. 좋은 test 설계도 잘 모른다고 가정한다.

**시작 시 announce:** "writing-plan skill을 사용해 implementation plan을 작성합니다."

**Context:** 권장 — dedicated worktree에서 실행.

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `spec_path` | `path` | ✅ | `.atom-flow/spec/<file>` — 이 plan의 근거가 되는 spec |
| `feature_name` | `string` | ✅ | kebab-case 짧은 식별자 (spec과 동일 값 권장) |

## 출력

**Plan 저장 위치:** `.atom-flow/plan/{yyyy-MM-dd}-{feature_name}-plan.md`
- 디렉토리가 없으면 먼저 생성: `mkdir -p .atom-flow/plan`
- date는 `date +"%Y-%m-%d"` 형식 (예: `2026-04-23`)
- `{feature_name}`은 kebab-case 짧은 식별자 (spec 파일과 동일 이름 권장)
- 최종 파일명 예시: `.atom-flow/plan/2026-04-23-user-onboarding-flow-plan.md`
- (사용자가 명시한 경로 선호가 있으면 그쪽이 우선한다)

## Scope Check

Spec이 여러 독립 subsystem을 다룬다면 brainstorming 단계에서 sub-project spec으로 쪼개졌어야 한다. 그렇지 않았다면 별도 plan으로 쪼갤 것을 제안한다 — subsystem당 하나씩. 각 plan은 독자적으로 동작·테스트 가능한 software를 만들어야 한다.

## File Structure

Task를 정의하기 전에 어떤 파일을 만들고 수정할지, 각각이 무엇을 책임지는지 먼저 매핑한다. 여기서 decomposition 결정이 고정된다.

- 명확한 boundary와 잘 정의된 interface로 unit을 설계한다. 각 파일은 명확한 책임 하나를 가진다.
- Context에 한 번에 담을 수 있는 코드에 대해 더 잘 추론하고, 파일이 집중되어 있을수록 편집이 안정적이다. 큰 파일보다 작고 집중된 파일이 낫다.
- 함께 변경되는 파일은 함께 둔다. 기술 layer가 아니라 책임으로 분리한다.
- 기존 codebase에서는 확립된 pattern을 따른다. Codebase가 큰 파일을 쓴다면 일방적으로 재구성하지 않는다 — 다만 수정 중인 파일이 너무 커졌다면 split을 plan에 포함하는 건 합리적이다.

이 구조가 task decomposition을 결정한다. 각 task는 독립적으로 의미 있는 자기완결적 변경을 만들어야 한다.

## Bite-Sized Task Granularity

**각 step은 하나의 action (2-5분):**
- "failing test 작성" — step
- "test 실행해서 실패 확인" — step
- "test를 통과시킬 최소 코드 구현" — step
- "test 실행해서 통과 확인" — step
- "Commit" — step

## Plan Document Header

**모든 plan은 이 header로 시작한다:**

```markdown
# [Feature Name] Implementation Plan

> **다음 단계:** 이 plan을 task 단위로 실행할 때는 `implementing` 스킬을 사용한다. Step은 checkbox(`- [ ]`) 문법을 사용한다.

**Goal:** [한 문장으로 무엇을 만드는지]

**Architecture:** [접근 방식 2-3 문장]

**Tech Stack:** [핵심 기술/라이브러리]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: failing test 작성**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: test 실행해서 실패 확인**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: 최소 implementation 작성**

```python
def function(input):
    return expected
```

- [ ] **Step 4: test 실행해서 통과 확인**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

모든 step은 engineer가 필요로 하는 실제 content를 담아야 한다. 이것들은 **plan 실패**다 — 절대 쓰지 않는다:
- "TBD", "TODO", "implement later", "fill in details"
- "적절한 error handling 추가" / "validation 추가" / "edge case 처리"
- "위 항목에 대한 test 작성" (실제 test 코드 없이)
- "Task N과 유사" (코드를 반복해서 적는다 — engineer가 task를 순서 무시하고 읽을 수 있음)
- 어떻게(how)를 보여주지 않고 무엇(what)만 설명하는 step (코드 step에는 코드 블록이 필수)
- 어떤 task에서도 정의되지 않은 type, function, method 참조

## 기억할 것
- 정확한 file path 항상
- 모든 step에 완전한 코드 — step이 코드를 바꾸면 코드를 보여줘라
- 정확한 명령어와 expected output
- DRY, YAGNI, TDD, 잦은 commit

## Self-Review

전체 plan을 작성한 뒤, spec을 새 눈으로 다시 보고 plan을 spec에 비춰 점검한다. 이건 직접 돌리는 checklist다 — subagent dispatch가 아니다.

**1. Spec coverage:** Spec의 각 section/requirement를 훑는다. 그것을 구현하는 task를 가리킬 수 있는가? 빠진 부분을 나열한다.

**2. Placeholder scan:** 위 "No Placeholders" section의 패턴을 plan 안에서 찾는다. 발견하면 고친다.

**3. Type consistency:** 후반 task에서 사용한 type, method signature, property 이름이 초반 task에서 정의한 것과 일치하는가? Task 3에서 `clearLayers()`라 부르고 Task 7에서 `clearFullLayers()`라 부르면 그건 bug다.

발견된 문제는 inline으로 고친다. 재리뷰는 필요 없다 — 고치고 넘어간다. Spec requirement인데 task가 없으면 task를 추가한다.

**선택적 — 더 엄격한 검증이 필요할 때:**
큰 plan, 여러 사람이 실행할 plan, 고위험 project에서는 본 스킬 디렉터리의 `plan-document-reviewer-prompt.md` 템플릿으로 reviewer subagent를 dispatch해 독립적인 검토를 받는다. 일반 project에서는 위 inline self-review로 충분하다.

## 셀프 리뷰 실패 재시도

self-review가 통과하지 못하면 자동 재시도 (상한 3회). 3회 초과 시 사용자에게 실패 사유·시도 내역을 보고하고 진행 여부를 묻는다 (자동 진행 안 함).

## 완료 안내 (Terminal state)

plan 작성·self-review가 끝나면 즉시 `design-review` 스킬을 직접 호출한다 (자동 흐름). design-review가 (a) 모든 pass 통과, 또는 (b) UI 스코프 부재로 조기 종료 — 둘 다 **pass로 간주**하고 `implementing` 스킬을 호출한다. 셀프 리뷰가 3회 초과 실패할 때만 사용자 보고로 분기한다.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success, summary: "plan written for <feature>", next: implementing, artifacts: [".atom-flow/plan/<file>"] }`

`summary`에는 자기 작업 결과(plan 작성)만 적는다. design-review의 결과는 design-review 자신의 schema로 보고되므로 여기서 흡수하지 않는다.

3회 초과 실패 시 **using-atom-flow §6.5.3 error schema**로 보고하고 `next: user`로 인계한다.
