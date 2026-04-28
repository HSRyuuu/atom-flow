# Report — skills-consolidation

**Spec**: .atom-flow/spec/2026-04-28-skills-consolidation-spec.md
**Plan**: .atom-flow/plan/2026-04-28-skills-consolidation-plan.md

## 구현 요약

atom-flow 스킬 디렉토리 구조를 2-tier(`skills/` + `shared-skills/`)에서 1-tier(`skills/` 단일)로 단일화했다. `using-atom-flow`는 `skills/`로 이동, `writing-clearly-and-concisely`는 외딴 스킬로 판정되어 디렉토리째 제거되었다. plugin manifest는 Claude Code 기본 위치 자동 스캔에 의존하도록 `skills` 필드를 삭제해 단순화했다. SessionStart hook의 가이드 경로 참조와 카탈로그 4곳(CLAUDE.md, README.md, using-atom-flow SKILL.md, writing-spec SKILL.md)의 잔재 정리도 같은 사이클에 묶어 처리해 drift를 막았다.

검토 루프 중 추가 결정 — omc 패턴을 빌려 `templates/rules/` 디렉토리를 도입하고 `karpathy-guidelines.md`를 첫 룰 템플릿으로 두었다. 이전에 `using-atom-flow/SKILL.md`의 `## 9. 코딩 행동 규칙` 섹션에 본문으로 박혀 있던 karpathy 가이드라인은 templates 위임으로 진입 가이드에서 제거되었다. 사용자는 자기 프로젝트의 `.claude/rules/`로 cp하면 Claude Code가 자동 lazy-load 한다.

자동 흐름(spec → plan → exec → report)과 인간 게이트(brainstorming, 커밋 직전 승인)는 그대로 보존된다.

## Plan ↔ 구현 매핑

| Plan 항목 | 상태 | 위치 (파일·심볼) | 비고 |
|---|---|---|---|
| Task 1: using-atom-flow 이동 | ✅ 구현 | `skills/using-atom-flow/SKILL.md` (from `shared-skills/`) | `git mv`로 이동, history 추적 유지 |
| Task 1: hook GUIDE 경로 갱신 | ✅ 구현 | `hooks/session-start.sh:9` | 새 경로로 hook 통합 실행 검증됨 |
| Task 2: writing-clearly-and-concisely 삭제 | ✅ 구현 | `shared-skills/writing-clearly-and-concisely/` (삭제됨) | `git rm -r`로 SKILL.md + elements-of-style.md + LICENSE 삭제 |
| Task 3: shared-skills/ 자체 삭제 | ✅ 구현 (자동) | `shared-skills/` (삭제됨) | Task 2의 `git rm -r`이 부모 디렉토리도 함께 정리하여 `rmdir` 불필요 |
| Task 4: plugin.json skills 필드 제거 | ✅ 구현 | `.claude-plugin/plugin.json` | `jq del(.skills)`. JSON 유효, 다른 4개 필드(name·description·hooks·version) 보존 |
| Task 5: CLAUDE.md 디렉토리 도식 갱신 | ✅ 구현 | `.claude/CLAUDE.md` | 2-tier 도식 → 1-tier, "3-tier와의 차이" → "디렉토리 정책" |
| Task 5: CLAUDE.md 카탈로그 단일화 | ✅ 구현 | `.claude/CLAUDE.md` | `using-atom-flow` 흡수, `copy-feature` 행 삭제, `writing-clearly-and-concisely` 행 삭제 |
| Task 5: README.md 카탈로그 정리 | ✅ 구현 (계획 외 추가) | `README.md` | Task 2 잔재 grep에서 발견. 두 표 → 단일 표로 합치고 두 외딴 스킬 행 삭제 |
| Task 5: using-atom-flow SKILL.md 카탈로그 정리 | ✅ 구현 (계획 외 추가) | `skills/using-atom-flow/SKILL.md` | 자기 SKILL.md의 `shared-skills/` 카탈로그 표 + 빠른 참조의 copy-feature 행 정리 |
| Task 5: writing-spec SKILL.md 자유 호출 정리 | ✅ 구현 | `skills/writing-spec/SKILL.md` | `shared-skills/writing-clearly-and-concisely` 단발 호출 안내 → 외부 plugin(`superpowers:elements-of-style`) 안내 |
| Task 6: 통합 검증 | ✅ 통과 | (검증만) | 디렉토리 9개 정상, plugin.json valid·skills absent, SessionStart hook 통합 실행 정상, pre-commit hook syntax OK |
| 검토 루프: `templates/rules/` 디렉토리 신설 | ✅ 구현 (검토 루프 추가) | `templates/rules/karpathy-guidelines.md` (사용자 직접 작성) | omc 패턴 차용. 사용자가 자기 프로젝트의 `.claude/rules/`로 cp 하는 옵트인 자료 |
| 검토 루프: `## 9. 코딩 행동 규칙` 섹션 import 제거 | ✅ 구현 (검토 루프 추가) | `skills/using-atom-flow/SKILL.md` (§9 전체 삭제) | 본문이 templates에 있으므로 진입 가이드에서 중복 제거 |

## 실제 변경 요약

- **이동**: `shared-skills/using-atom-flow/SKILL.md` → `skills/using-atom-flow/SKILL.md`
- **삭제 (3개 파일 + 2개 디렉토리)**:
  - `shared-skills/writing-clearly-and-concisely/SKILL.md`
  - `shared-skills/writing-clearly-and-concisely/elements-of-style.md`
  - `shared-skills/writing-clearly-and-concisely/LICENSE`
  - `shared-skills/writing-clearly-and-concisely/` (디렉토리)
  - `shared-skills/` (디렉토리, 부모도 함께 정리됨)
- **신규 (검토 루프 추가)**:
  - `templates/rules/karpathy-guidelines.md` (omc 패턴 차용, 사용자 직접 작성)
- **수정**:
  - `.claude-plugin/plugin.json` (skills 필드 제거 — 4개 필드만 보존)
  - `hooks/session-start.sh` (line 9 GUIDE 경로)
  - `.claude/CLAUDE.md` (.gitignore 적용 — git에는 안 잡힘. 디렉토리 도식·카탈로그 갱신)
  - `README.md` (스킬 표 통합)
  - `skills/using-atom-flow/SKILL.md` (자체 카탈로그 정리 + 빠른 참조 정리 + 검토 루프 추가: §9 코딩 행동 규칙 섹션 import 제거)
  - `skills/writing-spec/SKILL.md` (자유 호출 라인 제거)
- **테스트**: 본 사이클은 코드 변경이 없어 단위 테스트 없음. 통합 검증은 Task 6 참조 + 검토 루프 후 SessionStart hook 재실행으로 §9 잔재 0건 확인.

## Plan에서 조정된 사항

1. **Task 3 자동 완료** — plan은 `rmdir shared-skills`를 명시했으나, Task 2 Step 2의 `git rm -r shared-skills/writing-clearly-and-concisely`가 부모 디렉토리(`shared-skills/`)까지 함께 정리했다. 결과는 plan 의도와 동일하므로 무해. plan에 실행 노트로 기록.

2. **Task 5 범위 확장** — Task 2 Step 1의 잔재 grep에서 plan이 예상한 두 종류(`shared-skills/writing-clearly-and-concisely/SKILL.md` 자기 자신, `skills/writing-spec/SKILL.md` 자유 호출 라인) 외에 두 곳이 추가 발견:
   - `README.md:62` — 보조 스킬 표의 카탈로그 행
   - `skills/using-atom-flow/SKILL.md:127` — 자체 카탈로그의 `shared-skills/` 표 행 + line 305 빠른 참조의 `copy-feature` 행
   
   plan Step 1에 명시된 fallback("다른 hit가 있으면 그 위치도 Task 5에 추가해서 정리") 그대로 따라 Task 5 갱신 대상에 포함. plan 의도(카탈로그 잔재 0건)와 정합.

3. **검토 루프 — `templates/rules/` 도입 + §9 import 제거** — report 작성 후 검토 루프에서 사용자가 omc 패턴을 빌려 `templates/rules/karpathy-guidelines.md`를 직접 추가했고, `using-atom-flow/SKILL.md`의 `## 9. 코딩 행동 규칙` 섹션(karpathy 가이드라인 본문) import 제거를 요청했다. 본 사이클의 spec/plan에는 명시되지 않은 추가 결정이지만, "검토 루프 안의 코드 수정은 같은 사이클에 묶인다"는 atom-flow 규약에 따라 같은 사이클로 처리. CLAUDE.md 디렉토리 구조도에 `templates/` 추가는 별도 사이클로 분리(범위 확대 회피).

## 미구현·후속·기술 부채

- [ ] **PostCompact hook 추가** — 긴 사이클에서 컨텍스트 압축 후 워크플로우 가이드가 희미해지는 문제 대비. 본 사이클 비범위로 명시.
- [ ] **외부 글쓰기 plugin 안내 본문 통합** — 현재 `writing-spec` SKILL.md에만 외부 plugin 안내. `writing-plan`, `writing-report`도 prose 작성하므로 같은 안내가 들어가면 일관성 ↑. 본 사이클 비범위로 명시.
- [ ] **session-start.sh wrapping 강화 검토** — 이미 `<EXTREMELY_IMPORTANT>` 태그 적용됨(superpowers 패턴 차용). 추가 강도 어휘("MUST", "DO NOT skip") 도입은 별도 사이클.
- [ ] **`.claude/CLAUDE.md`의 git tracking 정책 재검토** — 현재 `.gitignore` 적용으로 atom-flow 핵심 정의 문서가 commit되지 않는다. plugin 본인의 정의 문서는 추적되어야 합리적이지만 변경 범위가 커 별도 사이클.
- [ ] **`templates/` 디렉토리 정책 문서화** — 본 사이클 검토 루프에서 신설된 `templates/rules/`. CLAUDE.md 디렉토리 구조도 + README의 setup 안내(omc-setup처럼 사용자 프로젝트의 `.claude/rules/`로 cp 가이드)를 별도 사이클에서 추가.

## 검증

- **빌드**: n/a (코드 변경 없음)
- **테스트**: n/a (코드 변경 없음)
- **수동 통합 검증** (Task 6, 모두 통과):
  - `skills/` 9개 디렉토리 정상 (brainstorming, design-review, handoff, implementing, updating-report, using-atom-flow, writing-plan, writing-report, writing-spec)
  - `shared-skills/` 부재 확인
  - `plugin.json` JSON 유효성 + `.skills` 필드 absent
  - SessionStart hook (`session-start.sh`) 통합 실행 시 새 경로의 SKILL.md 본문을 `<EXTREMELY_IMPORTANT>` wrapping과 함께 정상 stdout 출력. stderr 에러 없음
  - PreToolUse hook (`pre-commit-report-sync.sh`) syntax OK
- **카탈로그 잔재 0건**: 의도된 self-ref(spec/plan/report 본문)·안티패턴 목록 외 `shared-skills`·`copy-feature` hit 0건.
