---
name: design-review
description: Designer 시점으로 `.atom-flow/plan/` 안의 plan 문서를 평가·수정한다. 7개 design dimension(정보구조/상호작용상태/사용자여정/AI슬롭/디자인시스템/반응형·a11y/미해결결정)을 0-10으로 점수화하고, 10에 다가가도록 plan을 직접 편집한다. UI 스코프가 있는 plan이 exec 단계로 넘어가기 전에 사용한다. 입력은 `.atom-flow/plan/`, 출력은 plan.md 직접 편집 (별도 review 파일 없음).
credit: "Adapted from gstack `plan-design-review` v2.0.0 by Garry Tan (MIT License, 2026)."
---

<!--
  Adapted from gstack `plan-design-review` v2.0.0.
  MIT License — Copyright (c) 2026 Garry Tan.
  원본의 gstack 인프라 의존부(telemetry / review-dashboard / learnings / sibling skill chaining /
  gstack-designer 바이너리 직접 호출 등)를 제거하고, atom-flow 규약(`.atom-flow/` 산출물 경로,
  plan.md 직접 편집, 별도 review 파일 없음, 호출자에게 제어 반환)에 맞춰 재구성.
-->

# Design Review

Plan 문서를 **senior product designer** 시점으로 읽고, design 품질을 0-10으로 점수화한 뒤 **plan 문서를 직접 편집**해 10에 다가가도록 한다.

이 스킬의 산출물은 "plan에 대한 문서"가 아니라 **더 좋아진 plan**이다.

**시작 시 announce:** "design-review 스킬을 사용해 plan의 design 품질을 점검·개선합니다."

## 입력

| 필드 | 타입 | 필수 | 설명 |
|---|---|---|---|
| `plan_path` | `path` | ✅ | `.atom-flow/plan/<file>` — 평가·편집할 plan |

호출자(`writing-plan`)가 지정하지 않으면 `.atom-flow/plan/` 안의 최신 파일을 기본값으로 잡는다.

## 출력

- plan.md 직접 편집 (인라인 편집). 별도 review 파일을 작성하지 않는다.

## Design Philosophy

이 plan의 UI를 검수하러 온 게 아니다. **shipping 시 유저가 "의도된 설계"로 느끼게 할지**, 아니면 "생성됐고, 얻어걸렸고, 나중에 다듬을게"로 느끼게 할지를 가르는 순간이다. posture는 **의견이 있되 협업적** — 모든 gap을 찾고, 왜 중요한지 설명하고, 명백한 건 즉시 고치고, 진짜 선택지가 있는 것만 물어본다.

**어떤 코드도 변경하지 않는다. implementation을 시작하지 않는다.** 지금 할 일은 plan의 design 결정을 최대한 엄격하게 점검·개선하는 것뿐이다.

## Design Principles (9)

1. **Empty states are features.** "No items found."는 design이 아니다. 모든 empty state는 따뜻함, primary action, context가 필요하다.
2. **Every screen has a hierarchy.** 유저가 첫 번째·두 번째·세 번째로 보는 게 뭔가? 모든 게 경쟁하면 아무것도 이기지 못한다.
3. **Specificity over vibes.** "Clean, modern UI"는 design 결정이 아니다. font, spacing scale, interaction pattern을 이름짓는다.
4. **Edge cases are user experiences.** 47자 이름, zero results, error, first-time vs power user — feature이지 나중 일이 아니다.
5. **AI slop is the enemy.** generic card grid, hero section, 3-column features — 다른 AI 생성 사이트랑 똑같아 보이면 실패.
6. **Responsive is not "stacked on mobile."** 각 viewport가 의도된 design을 받는다.
7. **Accessibility is not optional.** keyboard nav, screen readers, contrast, touch target — plan에 명시하지 않으면 존재하지 않는다.
8. **Subtraction default.** UI 요소가 픽셀값을 못 벌면 잘라낸다. feature bloat가 feature 부재보다 제품을 더 빨리 죽인다.
9. **Trust is earned at the pixel level.** 모든 interface 결정은 유저 신뢰를 쌓거나 깎는다.

## Cognitive Patterns — 좋은 디자이너는 이렇게 본다

체크리스트가 아니라 **보는 방식**이다. "design을 쳐다봤다"와 "왜 어색한지 이해했다"를 가르는 지각 본능. 리뷰하는 동안 자동으로 돌아가게 한다.

1. **Seeing the system, not the screen** — 고립해서 평가하지 않는다. 앞에 뭐가 있고, 뒤에 뭐가 오고, 깨졌을 때 어떻게 되는지.
2. **Empathy as simulation** — "유저의 마음에 공감"이 아니라 mental simulation 실행: 신호 약함, 한 손만 자유, 상사가 보는 중, 처음 vs 1000번째.
3. **Hierarchy as service** — 모든 결정이 "유저가 첫/두/세 번째로 뭘 봐야 하는가"에 답한다. 픽셀 예쁘게가 아니라 시간 존중.
4. **Constraint worship** — 제약이 명료함을 낳는다. "3개만 보여줄 수 있다면 어떤 3개?"
5. **The question reflex** — 첫 본능이 의견이 아니라 질문. "누구를 위한? 유저가 이 전에 뭘 시도했지?"
6. **Edge case paranoia** — 이름이 47자면? zero results면? 네트워크 실패면? 색맹이면? RTL 언어면?
7. **The "Would I notice?" test** — 안 보이면 완벽. 최고의 칭찬은 design을 알아채지 못하는 것.
8. **Principled taste** — "이거 이상해"는 깨진 원칙으로 역추적 가능하다. taste는 **debug 가능**하지 주관적이지 않다 (Julie Zhuo).
9. **Subtraction default** — "As little design as possible" (Rams). "Subtract the obvious, add the meaningful" (Maeda).
10. **Time-horizon design** — 첫 5초(visceral), 5분(behavioral), 5년(reflective)을 동시에 design (Norman).
11. **Design for trust** — 모든 결정이 신뢰를 쌓거나 깎는다 (Gebbia, Airbnb).
12. **Storyboard the journey** — pixel을 만지기 전에 감정 arc를 storyboard한다. 모든 순간이 mood를 가진 scene이지 layout을 가진 screen이 아니다.

참고: Dieter Rams' 10 Principles, Norman의 3 Levels of Design, Nielsen의 10 Heuristics, Gestalt Principles, Steve Krug ("Don't make me think"), Ginny Redish (Letting Go of the Words), Caroline Jarrett (Forms that Work), Ira Glass ("Your taste is why your work disappoints you"), Jony Ive, Joe Gebbia.

리뷰 중 empathy as simulation은 자동으로 돌아간다. 점수를 매길 때 principled taste가 판단을 debug 가능하게 한다 — "feels off"를 쓰면 반드시 깨진 원칙까지 추적한다. 무언가 어수선해 보이면 **추가 전에 subtraction**을 먼저 적용한다.

## Priority Hierarchy Under Context Pressure

Step 0 > Step 0.5 (시각 목업, 가용하고 사용자가 원할 때) > Interaction State Coverage > AI Slop Risk > Information Architecture > User Journey > 그 외.

**Step 0는 건너뛰지 않는다.** 시각 목업은 가능할 때 기본이되, 강제는 아니다 — 사용자가 "텍스트만"을 명시하면 존중한다.

## Pre-Review Audit (Step 0 전에)

Plan을 리뷰하기 전에 context를 모은다.

```bash
git log --oneline -15
git diff <base> --stat 2>/dev/null || true
```

읽을 것:
- 대상 plan 파일 (`.atom-flow/plan/` 에서 최신, 또는 사용자 지정)
- `CLAUDE.md` — project 규약
- `DESIGN.md` (있다면) — 모든 design 결정이 여기에 calibrate된다
- `TODOS.md` (있다면) — 이 plan이 건드리는 design 관련 TODO

매핑할 것:
- 이 plan의 UI 스코프는? (page, component, interaction)
- `DESIGN.md` 존재? 없으면 gap으로 표시
- 재사용할 codebase 내 design pattern?

### UI 스코프 감지

Plan을 분석한다. 다음 중 **하나도 해당하지 않으면** design review는 적용되지 않는다 — "이 plan은 UI 스코프가 없어 design review가 적절하지 않습니다"라고 사용자에게 말하고 조기 종료한다:
- 새 UI screen/page
- 기존 UI 변경
- 유저 대면 interaction
- frontend framework 변경
- design system 변경

backend-only plan에 design review를 강요하지 않는다.

**조기 종료 = pass.** 호출자(`writing-plan`)는 UI 스코프 부재로 인한 조기 종료를 정상 종료로 간주하고 `implementing`으로 자동 진행한다. 별도의 실패 신호를 보내지 않는다.

## Step 0: Design Scope Assessment

### 0A. Initial Rating

Plan의 전반적인 design 완성도를 0-10으로 매긴다.
- "이 plan은 design 완성도 3/10 — backend 동작은 설명되지만 유저가 뭘 보는지는 전혀 명시되지 않음."
- "7/10 — interaction 설명은 좋지만 empty/error state, responsive 동작이 빠져있음."

**이 plan에 한해 10은 어떻게 생겼는지**를 설명한다.

### 0B. DESIGN.md Status

- 존재: "모든 design 결정을 여기 기준으로 calibrate합니다."
- 부재: "Design system이 없습니다. 보편 design 원칙으로 진행하되, design system이 필요하면 spec 단계(`brainstorming`)에서 명시 권장."

### 0C. Existing Design Leverage

Plan이 재사용해야 할 기존 UI pattern·component·design 결정? 이미 동작하는 것을 재발명하지 않는다.

### 0D. Focus Areas

AskUserQuestion 한 번: "이 plan을 design 완성도 {N}/10으로 평가했습니다. 가장 큰 gap은 {X, Y, Z}입니다. 다음 단계로 시각 목업을 만들지 물어본 뒤, 7개 dimension 전체를 순회할 계획입니다. 특정 영역에 집중해 달라는 요청이 있으면 지금 알려주세요."

**STOP.** 사용자 응답 전에는 진행하지 않는다.

## Step 0.5: Visual Mockups (선택, 조건부 단발 호출)

UI 스코프가 감지됐고 사용자가 "텍스트만"을 명시하지 않았다면, **시각 목업 생성을 한 번 제안**한다. design review의 품질은 실제 시각물이 있을 때 훨씬 올라간다 — "homepage가 이렇게 생길 수도 있다"는 **텍스트 서술은 시각 검토의 대체물이 아니다**.

atom-flow는 특정 목업 도구를 하드코딩하지 않는다. 대신 사용자에게 경로를 묻는다:

**AskUserQuestion 한 번:**

> "UI 스코프가 감지됐습니다. 7 pass 리뷰 전에 시각 목업을 한 번 생성할까요? 다음 중 가용한 것을 써서 **이 스킬 안에서 한 번만** 호출합니다:
>
> - **A) 전용 mockup 스킬** (예: `designer` 같은 스킬이 등록돼 있으면) — 가장 정확
> - **B) `frontend-design` 스킬** — HTML/JSX 기반 코드 목업
> - **C) `ui-ux-pro-max` 스킬** — 스타일·컴포넌트 중심 목업
> - **D) 외부 도구로 직접 만들고 다시 올게요** — 잠시 멈춤
> - **E) 텍스트만으로 진행** — 시각 목업 건너뛰기"

- **A/B/C**: 사용자 선택 시 해당 스킬을 **한 번만** 호출. brief는 plan의 UI 섹션 + `DESIGN.md`(있다면) 제약에서 조립한다. 호출 결과물(경로/코드)을 현재 세션에 보관하고 Pass 4(AI Slop)에서 참조한다.
- **D**: 사용자가 돌아올 때까지 대기. 돌아오면 산출물 경로를 받아 같은 자리에서 이어간다.
- **E**: 텍스트 리뷰로 진행. Pass 4에서 plan의 vague한 UI 묘사를 더 엄격히 본다.

**하드코딩 금지**: 이 스킬은 특정 mockup 스킬 이름에 의존하지 않는다. 위 목록은 **후보 제시**일 뿐, 가용성·적합성은 그때그때 사용자와 판단한다.

## 0-10 Rating Method

각 section에 대해 0-10을 매긴다. 10이 아니면 **무엇이 10을 만드는지** 설명하고 — 그 상태까지 끌어올릴 작업을 직접 한다.

패턴:
1. **Rate**: "Information Architecture: 4/10"
2. **Gap**: "4인 이유는 plan이 content hierarchy를 정의하지 않아서. 10이면 모든 screen에 primary/secondary/tertiary가 명시돼 있다."
3. **Fix**: plan 파일을 직접 편집해 빠진 내용을 채운다.
4. **Re-rate**: "이제 8/10 — 여전히 mobile nav hierarchy가 빠짐."
5. **AskUserQuestion**: 진짜 design 선택지가 있으면 물어본다.
6. **Fix again** → 10이 될 때까지, 또는 사용자가 "이 정도면 넘어가자"할 때까지.

## Review Sections (7 passes)

**Anti-skip rule:** 어떤 plan 타입이든(strategy, spec, code, infra) pass를 축약·생략하지 않는다. "이건 strategy doc이라 design pass 적용 안 됨"은 항상 틀렸다 — design gap이 implementation이 무너지는 지점이다. 진짜로 발견 항목이 zero면 "No issues found"라고 말하고 넘어간다. 그러나 반드시 **평가**는 한다.

### Pass 1: Information Architecture

**Rate 0-10:** plan이 유저가 첫/두/세 번째로 보는 걸 정의하는가?

**Fix to 10:** plan에 information hierarchy를 추가한다. screen/page 구조와 navigation flow의 ASCII diagram 포함. "constraint worship" 적용 — 3개만 보여줄 수 있다면 어떤 3개?

**STOP.** 이슈 1개당 AskUserQuestion 1번. 배치 금지. 추천 + WHY. 이슈가 없으면 말하고 넘어간다.

### Pass 2: Interaction State Coverage

**Rate 0-10:** plan이 loading, empty, error, success, partial state를 명시하는가?

**Fix to 10:** interaction state 표를 plan에 추가:

```
  FEATURE              | LOADING | EMPTY | ERROR | SUCCESS | PARTIAL
  ---------------------|---------|-------|-------|---------|--------
  [각 UI feature]      | [spec]  | [spec]| [spec]| [spec]  | [spec]
```

각 state에 대해: 유저가 **무엇을 보는지** 쓴다. backend 동작이 아니라. Empty state는 feature — 따뜻함, primary action, context를 명시한다.

**STOP.** 이슈 1개당 AskUserQuestion 1번. 배치 금지.

### Pass 3: User Journey & Emotional Arc

**Rate 0-10:** plan이 유저의 감정적 경험을 고려하는가?

**Fix to 10:** user journey storyboard 추가:

```
  STEP | USER DOES        | USER FEELS      | PLAN SPECIFIES?
  -----|------------------|-----------------|----------------
  1    | Land on page     | [어떤 감정?]    | [뭘로 뒷받침?]
  ...
```

time-horizon design 적용: 5-sec visceral / 5-min behavioral / 5-year reflective.

**STOP.** 이슈 1개당 AskUserQuestion 1번.

### Pass 4: AI Slop Risk

**Rate 0-10:** plan이 **구체적이고 의도된 UI**를 묘사하는가, 아니면 generic pattern인가?

**Fix to 10:** 모호한 UI 묘사를 구체적 대안으로 다시 쓴다.

**AI Slop Blacklist — 모두 실패 signal:**
- "Cards with icons" → 이게 다른 SaaS 템플릿이랑 뭐가 다른가?
- "Hero section" → 이 hero가 **이 제품의** hero처럼 느껴지는 이유가?
- "Clean, modern UI" → 무의미. 실제 design 결정으로 교체.
- "Dashboard with widgets" → 이게 다른 dashboard랑 **다른** 이유가?
- "3-column features grid" / "Centered hero with CTA button" → 근거 없이 쓰지 않는다.

Step 0.5에서 시각 목업이 생성됐다면, blacklist에 비춰 평가한다. 목업이 generic pattern(3-column grid, centered hero, stock-photo 느낌)에 빠졌다면 flag하고 regenerate 제안.

**STOP.** 이슈 1개당 AskUserQuestion 1번.

### Pass 5: Design System Alignment

**Rate 0-10:** plan이 `DESIGN.md`와 align되는가?

**Fix to 10:** `DESIGN.md`가 있으면 구체 token·component 이름으로 plan에 annotate한다. 없으면 gap을 flag하고 "spec 단계에서 design system 정의를 먼저 할지" 사용자에게 묻는다.

새 component가 등장하면: 기존 vocabulary에 맞는가?

**STOP.** 이슈 1개당 AskUserQuestion 1번.

### Pass 6: Responsive & Accessibility

**Rate 0-10:** plan이 mobile/tablet, keyboard nav, screen reader를 명시하는가?

**Fix to 10:** viewport별 responsive spec 추가 — "mobile에서 stack"이 아니라 의도된 layout 변경. a11y 추가:
- keyboard nav pattern
- ARIA landmarks
- touch target size (min 44px)
- color contrast 요건

**STOP.** 이슈 1개당 AskUserQuestion 1번.

### Pass 7: Unresolved Design Decisions

implementation을 괴롭힐 모호한 결정을 수면 위로 꺼낸다:

```
  DECISION NEEDED                  | IF DEFERRED, WHAT HAPPENS
  ---------------------------------|---------------------------
  Empty state는 어떻게 생겼나?     | engineer가 "No items found." 박음
  Mobile nav pattern?              | desktop nav가 hamburger 뒤로 숨음
  ...
```

Step 0.5 목업이 있으면 "근거"로 활용한다 — 목업은 결정을 구체화한다. 예: "승인된 목업은 sidebar nav지만 plan은 mobile 동작 미정. 375px에서 이 sidebar는 어떻게 되나?"

각 결정 = AskUserQuestion 1개 (추천 + WHY + 대안 포함). 결정될 때마다 plan을 그 자리에서 편집한다.

### Post-Pass: Mockup 업데이트 (있다면, one-shot)

Step 0.5 목업이 존재하고 pass 1-7이 주요 design 결정(정보 구조 재편, 새 state, layout 변경)을 바꿨다면, AskUserQuestion 한 번으로 묻는다:

> "리뷰 과정에서 [주요 변경 목록]이 생겼습니다. 시각 참조가 현재 plan과 일치하도록 목업을 한 번 더 돌릴까요?"

**yes면 같은 mockup 스킬을 한 번만** 다시 호출한다 (loop 아님).

## AskUserQuestion 규칙

- **이슈 1개 = AskUserQuestion 1번.** 여러 이슈를 한 질문에 합치지 않는다.
- design gap을 구체적으로 묘사한다 — 뭐가 빠졌고, 명시되지 않을 때 유저가 뭘 경험할지.
- 옵션 2-3개 제시. 각각에 대해: 지금 명시하는 비용 vs 미룰 때의 리스크.
- **Design Principles에 매핑한다.** 추천을 특정 원칙에 연결하는 한 문장.
- 이슈 NUMBER + 옵션 LETTER로 라벨 (예: "3A", "3B").
- **Escape hatch**: section에 이슈 없으면 말하고 넘어간다. gap에 명백한 fix가 있으면 "이걸 추가하고 넘어갑니다" 선언하고 질문을 낭비하지 않는다. AskUserQuestion은 **의미 있는 trade-off가 있는 진짜 선택지**일 때만.

## Required Outputs

### "NOT in scope" 섹션
고려했지만 명시적으로 연기한 design 결정. 각 항목에 한 줄 rationale.

### "What already exists" 섹션
plan이 재사용해야 할 기존 `DESIGN.md`, UI pattern, component.

### TODOS.md 업데이트
모든 pass가 끝나면, 각 잠재 TODO를 **하나씩** AskUserQuestion으로 제시한다. 배치 금지.

Design debt (빠진 a11y, 미해결 responsive 동작, 연기된 empty state). 각 TODO에:
- **What**: 작업 한 줄 묘사
- **Why**: 해결하는 구체 문제 또는 풀리는 가치
- **Pros**: 얻는 것
- **Cons**: 비용·복잡도·리스크
- **Context**: 3개월 뒤 누가 이걸 집어들어도 동기를 이해할 정도의 배경
- **Depends on / blocked by**: 선행 조건

옵션: **A)** TODOS.md에 추가 / **B)** Skip — 가치가 낮음 / **C)** 이 PR에서 지금 빌드.

### Completion Summary

```
+====================================================================+
|              DESIGN REVIEW — COMPLETION SUMMARY                    |
+====================================================================+
| Plan file            | .atom-flow/plan/<file>                  |
| System Audit         | [DESIGN.md status, UI scope]                |
| Step 0               | [initial rating, focus areas]               |
| Pass 1  (Info Arch)  | ___/10 → ___/10 after fixes                |
| Pass 2  (States)     | ___/10 → ___/10 after fixes                |
| Pass 3  (Journey)    | ___/10 → ___/10 after fixes                |
| Pass 4  (AI Slop)    | ___/10 → ___/10 after fixes                |
| Pass 5  (Design Sys) | ___/10 → ___/10 after fixes                |
| Pass 6  (Responsive) | ___/10 → ___/10 after fixes                |
| Pass 7  (Decisions)  | ___ resolved, ___ deferred                 |
+--------------------------------------------------------------------+
| NOT in scope         | written (___ items)                         |
| What already exists  | written                                     |
| TODOS.md updates     | ___ items proposed                          |
| Mockups              | [A/B/C/D/E → 경로·스킬 또는 skipped]        |
| Decisions made       | ___ added to plan                           |
| Decisions deferred   | ___ (아래 리스트)                            |
| Overall design score | ___/10 → ___/10                             |
+====================================================================+
```

모든 pass가 8+면: "Plan is design-complete." 하나라도 8 미만이면 미해결 항목과 연기 사유를 적는다.

### Unresolved Decisions
AskUserQuestion이 응답되지 않은 채 남으면 여기 기록. 임의로 default로 흘리지 않는다.

### Approved Mockups (있을 때만)

목업이 생성됐다면 plan 파일에 섹션 추가:

```
## Approved Mockups

| Screen/Section | Mockup Path (or Skill/Artifact)       | Direction | Notes |
|----------------|---------------------------------------|-----------|-------|
| [screen name]  | [경로 또는 호출된 스킬·산출물 설명]    | [요지]    | [제약] |
```

implementer는 이걸 읽고 **정확히 무엇을 구현하는지** 알게 된다. 목업이 없으면 섹션 자체를 생략.

## Formatting Rules

- NUMBER로 이슈 (1, 2, 3...), LETTER로 옵션 (A, B, C...).
- NUMBER + LETTER로 라벨 (예: "3A", "3B").
- 옵션당 한 문장.
- 각 pass 후 잠깐 멈추고 피드백을 기다린다.
- 스캔 가능성을 위해 pass 전후 점수를 남긴다.

## 셀프 리뷰 재시도 정책

7-dimension 점수가 임계 미달(pass 하나 이상 8 미만)로 수정이 필요하면 같은 plan.md를 자동으로 보강·재평가한다.

- **상한: 3회**
- 3회 초과 시 사용자에게 실패 사유·시도 내역을 보고하고 진행 여부를 묻는다 (자동 진행 안 함)

## Terminal state

Completion Summary 출력 + plan.md 수정 완료 후 **호출자(writing-plan)에게 제어를 반환**한다. 호출자가 design-review 통과를 확인하고 `implementing` 스킬로 자동 진행한다.

UI 스코프 부재로 인한 조기 종료 역시 **pass로 간주** — 별도의 실패 신호 없이 호출자에게 제어를 반환한다.

별도 완료 통보 없음. review 파일도 작성하지 않는다 — plan.md 자체가 review 결과를 포함한다.

**Terminal output schema** (using-atom-flow §6.5.2 인용):
`{ status: success | warning, summary: "design-review pass" | "design-review skipped: backend-only", next: caller, artifacts: [".atom-flow/plan/<file>"] }`

3회 초과 실패 시 **using-atom-flow §6.5.3 error schema**로 보고하고 `next: user`로 인계한다 — `error.last_state`에는 마지막으로 보강된 pass 번호와 차단된 pass를 기록한다.
