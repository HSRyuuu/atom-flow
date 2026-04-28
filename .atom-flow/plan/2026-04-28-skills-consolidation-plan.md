# Skills Consolidation Implementation Plan

> **다음 단계:** 이 plan을 task 단위로 실행할 때는 `implementing` 스킬을 사용한다. Step은 checkbox(`- [x]`) 문법을 사용한다.

**Goal:** atom-flow 스킬 디렉토리를 2-tier(`skills/` + `shared-skills/`)에서 1-tier(`skills/` 단일)로 단일화하고, `writing-clearly-and-concisely` 외딴 스킬 제거 + `copy-feature` 카탈로그 잔재 정리.

**Architecture:** 변경은 6개 task로 분해. Task 1은 원자적(디렉토리 이동 + hook 경로 갱신을 같이 해야 SessionStart hook이 깨지지 않음). Task 2~5는 독립. Task 6은 통합 검증으로 commit 직전 게이트 보강.

**Tech Stack:** bash file ops, jq (JSON 편집), grep (잔재 검증). 새 라이브러리·코드 없음.

**Source spec:** `.atom-flow/spec/2026-04-28-skills-consolidation-spec.md`

---

## File Inventory

**삭제될 파일·디렉토리:**
- `shared-skills/writing-clearly-and-concisely/SKILL.md`
- `shared-skills/writing-clearly-and-concisely/elements-of-style.md`
- `shared-skills/writing-clearly-and-concisely/LICENSE`
- `shared-skills/writing-clearly-and-concisely/` (디렉토리)
- `shared-skills/` (디렉토리, 비어있게 됨)

**이동될 파일·디렉토리:**
- `shared-skills/using-atom-flow/SKILL.md` → `skills/using-atom-flow/SKILL.md`
- `shared-skills/using-atom-flow/` → `skills/using-atom-flow/` (디렉토리 통째)

**수정될 파일:**
- `.claude-plugin/plugin.json` (skills 필드 제거)
- `hooks/session-start.sh` (line 9 GUIDE 경로 갱신)
- `.claude/CLAUDE.md` (디렉토리 구조도, 스킬 카탈로그, copy-feature 잔재 제거)

**생성될 파일:**
- 없음

---

### Task 1: using-atom-flow 이동 + hook 경로 갱신 (원자적)

**Files:**
- Move: `shared-skills/using-atom-flow/` → `skills/using-atom-flow/`
- Modify: `hooks/session-start.sh:9`

**원자성 이유:** hook의 GUIDE 경로가 옛 위치를 가리키는 상태로 commit하면 SessionStart hook이 즉시 깨진다. 두 변경은 같은 task 안에서 함께 수행한다.

- [x] **Step 1: shared-skills/using-atom-flow 디렉토리 통째 이동**

```bash
git mv shared-skills/using-atom-flow skills/using-atom-flow
```

(`git mv`를 사용해 history 추적 유지)

- [x] **Step 2: 이동 결과 확인**

Run: `ls skills/using-atom-flow/SKILL.md && ls shared-skills/using-atom-flow 2>&1`
Expected: 첫 번째 명령은 파일 출력. 두 번째는 `No such file or directory`로 실패.

- [x] **Step 3: session-start.sh의 GUIDE 경로 갱신**

`hooks/session-start.sh` line 9 변경:

Before:
```bash
GUIDE="${PLUGIN_ROOT}/shared-skills/using-atom-flow/SKILL.md"
```

After:
```bash
GUIDE="${PLUGIN_ROOT}/skills/using-atom-flow/SKILL.md"
```

- [x] **Step 4: hook 스크립트 실제 실행해서 GUIDE 로드 검증**

Run:
```bash
cd /Users/happyhsryu/dev/personal/atom-flow && \
mkdir -p /tmp/atom-flow-hook-test/.atom-flow && \
CLAUDE_PROJECT_DIR=/tmp/atom-flow-hook-test \
CLAUDE_PLUGIN_ROOT=/Users/happyhsryu/dev/personal/atom-flow \
bash hooks/session-start.sh | head -5
```

Expected: stdout으로 `using-atom-flow/SKILL.md` 본문 시작부 출력. stderr에 "guide not found" 없음.

`/tmp/atom-flow-hook-test`는 검증용 임시 dir이고, 검증 끝나면 cleanup:
```bash
rm -rf /tmp/atom-flow-hook-test
```

---

### Task 2: writing-clearly-and-concisely 디렉토리 제거

**Files:**
- Delete: `shared-skills/writing-clearly-and-concisely/` (전체)

- [x] **Step 1: 다른 곳에서 호출하는지 확인 (잔재 호출 검사)**

Run:
```bash
grep -rn "writing-clearly-and-concisely" \
  --include="*.md" --include="*.json" --include="*.sh" \
  /Users/happyhsryu/dev/personal/atom-flow
```

Expected: 두 종류의 hit만 나와야 함:
1. `shared-skills/writing-clearly-and-concisely/SKILL.md` 자기 자신
2. `skills/writing-spec/SKILL.md`의 "자유 호출" 섹션 — 본문에 `shared-skills/writing-clearly-and-concisely`를 단발 호출 가능하다고 안내. 이 라인은 Task 5에서 함께 제거됨.

**실행 결과**: 추가 잔재 2개 발견 — `README.md:62` 카탈로그 행, `skills/using-atom-flow/SKILL.md:127` 카탈로그 표 행. Task 5 갱신 대상에 추가.

- [x] **Step 2: 디렉토리 통째 삭제**

```bash
git rm -r shared-skills/writing-clearly-and-concisely
```

- [x] **Step 3: 삭제 확인**

Run: `ls shared-skills/writing-clearly-and-concisely 2>&1`
Expected: `No such file or directory`로 실패.

---

### Task 3: shared-skills/ 디렉토리 자체 삭제

**Files:**
- Delete: `shared-skills/` (디렉토리)

**실행 노트**: Task 2 Step 2의 `git rm -r`이 부모 디렉토리(`shared-skills/`)까지 자동 정리. Task 3의 모든 step이 결과적으로 자동 완료됨.

- [x] **Step 1: shared-skills/가 비어있는지 확인**

Run: `ls shared-skills/ 2>&1`
Expected: 빈 출력 (Task 1에서 using-atom-flow 이동, Task 2에서 writing-clearly-and-concisely 삭제 후라 빈 디렉토리).
**실행 결과**: 디렉토리 자체가 사라짐 (`No such file or directory`). plan 의도와 일치.

- [x] **Step 2: 디렉토리 삭제**

```bash
rmdir shared-skills
```

(`git rm -r`은 추적 파일이 없으면 적용 불가. `rmdir`로 빈 디렉토리만 삭제. git은 빈 디렉토리를 추적하지 않으므로 별도 git 처리 불필요.)
**실행 결과**: 불필요 — Task 2 Step 2가 부모도 함께 정리.

- [x] **Step 3: 삭제 확인**

Run: `ls shared-skills 2>&1`
Expected: `No such file or directory`로 실패.

---

### Task 4: plugin.json의 skills 필드 제거

**Files:**
- Modify: `.claude-plugin/plugin.json`

- [x] **Step 1: 현재 plugin.json 백업 및 확인**

Run: `cat .claude-plugin/plugin.json`
Expected: 현재 `"skills": ["./skills/", "./shared-skills/"]` 라인 존재 확인.

- [x] **Step 2: jq로 skills 필드 제거**

```bash
cd /Users/happyhsryu/dev/personal/atom-flow && \
jq 'del(.skills)' .claude-plugin/plugin.json > .claude-plugin/plugin.json.tmp && \
mv .claude-plugin/plugin.json.tmp .claude-plugin/plugin.json
```

- [x] **Step 3: skills 필드 제거 확인**

Run: `jq '.skills' .claude-plugin/plugin.json`
Expected: `null` 출력. **실행 결과**: `null` ✅

추가 검증 — name·hooks 등 다른 필드는 보존됐는지:
Run: `jq 'keys' .claude-plugin/plugin.json`
Expected: `["description", "hooks", "name", "version"]`. **실행 결과**: 정확히 일치 ✅

- [x] **Step 4: JSON 유효성 검사**

Run: `jq empty .claude-plugin/plugin.json && echo "valid"`
Expected: `valid` 출력. **실행 결과**: `valid` ✅

---

### Task 5: CLAUDE.md 카탈로그·구조도 갱신

**Files:**
- Modify: `.claude/CLAUDE.md`
- Modify: `skills/writing-spec/SKILL.md` (Task 2 Step 1에서 발견된 잔재 라인 제거 — 자유 호출 섹션의 `shared-skills/writing-clearly-and-concisely` 언급)

**갱신 대상 6개:**

1. **디렉토리 구조 도식 (~line 90-110)** — 2-tier에서 1-tier로
2. **"3-tier와의 차이" 섹션 (~line 113-118)** — 1-tier 단순화로 갱신, "shared-skills 의미" 단락 삭제
3. **스킬 카탈로그 — skills/ 표** — `using-atom-flow` 행 추가, `copy-feature` 행 삭제
4. **스킬 카탈로그 — shared-skills/ 표** — 표 자체 삭제
5. **carousel 텍스트의 shared-skills 언급** — grep으로 모든 잔재 찾아 제거
6. **skills/writing-spec/SKILL.md** — `shared-skills/writing-clearly-and-concisely` 자유 호출 안내 라인 제거

- [x] **Step 1: 갱신 전 잔재 grep**

Run:
```bash
grep -n "shared-skills\|copy-feature" /Users/happyhsryu/dev/personal/atom-flow/.claude/CLAUDE.md
```

Expected: shared-skills 언급 5+ 라인, copy-feature 1 라인. 모두 후속 step에서 제거 대상.

- [x] **Step 2: 디렉토리 구조 도식 1-tier로 변경**

`.claude/CLAUDE.md`의 "디렉토리 구조 (2-tier)" 섹션 본문을 다음으로 교체:

Before:
```
## 디렉토리 구조 (2-tier)

\`\`\`
atom-flow/
├── .claude-plugin/
│   └── plugin.json              # Claude Code 플러그인 정의
├── CLAUDE.md                    # 이 파일
├── README.md
├── hooks/                       # SessionStart·PreToolUse hook 스크립트
│   ├── session-start.sh
│   └── pre-commit-report-sync.sh
├── skills/                      # 워크플로우 핵심 스킬 (자유 호출 가능)
│   ├── brainstorming/
│   ├── writing-spec/
│   ├── writing-plan/
│   ├── design-review/
│   ├── implementing/
│   ├── writing-report/
│   ├── updating-report/
│   ├── handoff/
│   └── copy-feature/
└── shared-skills/               # 보조성·범용 스킬
    ├── writing-clearly-and-concisely/
    └── using-atom-flow/
\`\`\`
```

After:
```
## 디렉토리 구조

\`\`\`
atom-flow/
├── .claude-plugin/
│   └── plugin.json              # Claude Code 플러그인 정의
├── CLAUDE.md                    # 이 파일
├── README.md
├── hooks/                       # SessionStart·PreToolUse hook 스크립트
│   ├── session-start.sh
│   └── pre-commit-report-sync.sh
└── skills/                      # 모든 스킬 (자유 호출 가능)
    ├── brainstorming/
    ├── design-review/
    ├── handoff/
    ├── implementing/
    ├── updating-report/
    ├── using-atom-flow/         # SessionStart hook이 본문 주입
    ├── writing-plan/
    ├── writing-report/
    └── writing-spec/
\`\`\`
```

- [x] **Step 3: "3-tier와의 차이" 섹션 갱신**

Before:
```
### atom-flow 3-tier와의 차이

- **3-tier → 2-tier**: \`standards/\` 폐기. \`skills/\` + \`shared-skills/\`만 유지.
- **shared-skills 의미**: atom-flow의 "원자성 예외 영역"이 아니라 단순히 보조성·범용 스킬 보관소. 모든 스킬이 자유롭게 서로 호출 가능하므로 "예외" 개념 자체가 없다.
- **plugin.json + 디렉토리 자체가 단일 정보원**: 별도 atom-catalog.md 없음.
- **hooks/ 디렉토리 신규**: 자동 흐름 보장 hook을 별도 디렉토리로 관리.
```

After:
```
### 디렉토리 정책

- **단일 \`skills/\` tier**: 모든 스킬은 \`skills/\` 아래 평면 구조. 보조성·범용 스킬도 동등하게 다룬다 — "예외 영역" 개념 없음.
- **plugin.json + 디렉토리 자체가 단일 정보원**: 별도 atom-catalog.md 없음. plugin.json은 Claude Code 기본 위치(\`skills/\`)를 자동 스캔하므로 \`skills\` 필드 명시 불필요.
- **hooks/ 디렉토리 분리**: 자동 흐름 보장 hook을 별도 디렉토리로 관리.
```

- [x] **Step 4: 스킬 카탈로그 표 갱신**

Before (두 표):
```
### skills/ (워크플로우 핵심)

| 스킬 | 역할 | 자동/수동 |
|---|---|---|
| ...
| \`copy-feature\` | 외부 오픈소스·아이디어를 atom-flow로 이식할 때 개념 추출·이식 가능성 판정 | 수동/자동 모두 가능 |

### shared-skills/ (보조성·범용)

| 스킬 | 역할 |
|---|---|
| \`writing-clearly-and-concisely\` | Strunk 글쓰기 원칙 적용. spec/plan/report 작성 단계에서 임의로 호출 가능 |
| \`using-atom-flow\` | SessionStart hook이 주입할 가이드 본문. 새 세션의 워크플로우 진입점 |
```

After (단일 표):
```
### skills/ (전체 카탈로그)

| 스킬 | 역할 | 자동/수동 |
|---|---|---|
| \`brainstorming\` | 사용자 대화로 의도·요구·design 결정. 마지막에 writing-spec 호출 | 인간 대화 |
| \`writing-spec\` | brainstorming 합의를 \`.atom-flow/spec/\`에 저장 | 자동 |
| \`writing-plan\` | spec.md → plan.md 작성. 직후 design-review 호출해 셀프 리뷰. 통과 시 implementing 호출 | 자동 |
| \`design-review\` | plan.md를 7-dimension으로 평가하고 plan.md 직접 편집·보강. 재시도 상한 3회 | 자동 |
| \`implementing\` | plan.md → 실제 코드 변경 + plan ↔ 구현 매핑 셀프 리뷰. 통과 시 writing-report 호출 | 자동 |
| \`writing-report\` | exec 완료 후 report 강제 작성 (살아있는 문서 초기 형태) | 자동, 건너뛸 수 없음 |
| \`updating-report\` | 검토 루프 내 코드 수정 시 report 동기 갱신 | LLM 자율 + PreToolUse hook 강제 |
| \`handoff\` | \`.atom-flow/handoff/\` 생성 — 대화 맥락 + 산출물 경로 인덱싱 | 수동 트리거 |
| \`using-atom-flow\` | SessionStart hook이 주입할 가이드 본문. 새 세션의 워크플로우 진입점 | hook 강제 주입 |
```

(`copy-feature` 행 삭제, `writing-clearly-and-concisely` 행 삭제, `using-atom-flow` 행을 skills 표에 통합. shared-skills 표 통째 삭제.)

- [x] **Step 5: 안티패턴 목록의 잔재 검사**

Run:
```bash
grep -n "standards/\|3-tier" /Users/happyhsryu/dev/personal/atom-flow/.claude/CLAUDE.md
```

Expected: 안티패턴 목록의 `❌ standards/ 자동 활성화` 라인은 보존(과거 회피 사유 기록). "3-tier" 언급은 Step 3에서 정리됐으므로 안티패턴 외 잔재 없어야 함.

남은 잔재가 있으면 추가 정리.

- [x] **Step 6: skills/writing-spec/SKILL.md의 잔재 라인 제거**

`skills/writing-spec/SKILL.md`의 "자유 호출" 섹션에서 `shared-skills/writing-clearly-and-concisely` 호출 안내 라인을 통째 제거.

Before (예시 — 실제 라인은 grep 결과로 확정):
```
## 자유 호출

- \`shared-skills/writing-clearly-and-concisely\`를 단발로 호출해 prose 품질을 높여도 된다.
- 추가 정보 수집을 위해 다른 스킬을 호출해도 된다.
```

After:
```
## 자유 호출

- 추가 정보 수집을 위해 다른 스킬을 호출해도 된다.
- 글쓰기 품질이 중요하면 외부 plugin(예: superpowers:elements-of-style) 활용 가능.
```

- [x] **Step 7: 최종 검증 grep**

Run:
```bash
grep -rn "shared-skills\|copy-feature" \
  --include="*.md" --include="*.json" --include="*.sh" \
  /Users/happyhsryu/dev/personal/atom-flow
```

Expected: 0 hit (또는 안티패턴 목록·history 컨텍스트 의도적 잔재만).

남은 hit가 있으면 inline으로 정리.

---

### Task 6: 통합 검증

**Files:** 변경 없음. 검증만.

- [x] **Step 1: 디렉토리 구조 일관성**

Run:
```bash
ls -la /Users/happyhsryu/dev/personal/atom-flow/skills/ && \
ls /Users/happyhsryu/dev/personal/atom-flow/shared-skills 2>&1
```

Expected:
- `skills/` 안에 9개 스킬 디렉토리 (brainstorming, design-review, handoff, implementing, updating-report, using-atom-flow, writing-plan, writing-report, writing-spec).
- `shared-skills/`는 `No such file or directory`로 실패.

- [x] **Step 2: plugin.json 유효성 + skills 필드 부재**

Run:
```bash
jq empty /Users/happyhsryu/dev/personal/atom-flow/.claude-plugin/plugin.json && \
jq '.skills' /Users/happyhsryu/dev/personal/atom-flow/.claude-plugin/plugin.json
```

Expected: 첫 번째 명령은 silent success. 두 번째는 `null`.

- [x] **Step 3: SessionStart hook 통합 실행**

Run:
```bash
mkdir -p /tmp/atom-flow-final-test/.atom-flow && \
CLAUDE_PROJECT_DIR=/tmp/atom-flow-final-test \
CLAUDE_PLUGIN_ROOT=/Users/happyhsryu/dev/personal/atom-flow \
bash /Users/happyhsryu/dev/personal/atom-flow/hooks/session-start.sh 2>&1 | head -10 && \
rm -rf /tmp/atom-flow-final-test
```

Expected: stdout에 using-atom-flow 본문 시작부 정상 출력. stderr에 에러 없음.

- [x] **Step 4: PreToolUse hook 무리 없이 실행 가능 검증**

Run:
```bash
CLAUDE_PLUGIN_ROOT=/Users/happyhsryu/dev/personal/atom-flow \
bash -n /Users/happyhsryu/dev/personal/atom-flow/hooks/pre-commit-report-sync.sh && \
echo "syntax ok"
```

Expected: `syntax ok` 출력. (이 hook은 본 사이클에서 변경되지 않았으므로 syntax check만.)

- [x] **Step 5: 카탈로그 잔재 0건 확인**

Run:
```bash
grep -rn "shared-skills\|copy-feature" \
  --include="*.md" --include="*.json" --include="*.sh" \
  /Users/happyhsryu/dev/personal/atom-flow | \
  grep -v "안티패턴\|polished" || echo "no leftover"
```

Expected: `no leftover` 출력 (혹은 안티패턴 목록 hit만 — 의도적 보존).

남은 hit가 있으면 Task 5로 돌아가 마무리.

- [x] **Step 6: writing-report 호출로 전환**

implementing 종료 시 self-review 통과 → `writing-report` 호출 (자동 흐름. 본 plan에서는 명시만, 실제 호출은 implementing 스킬이 수행).

---

## Self-Review

**1. Spec coverage:**
| Spec 변경 항목 | 담당 task |
|---|---|
| using-atom-flow 이동 | Task 1 |
| writing-clearly-and-concisely 삭제 | Task 2 |
| shared-skills/ 자체 삭제 | Task 3 |
| plugin.json skills 필드 제거 | Task 4 |
| session-start.sh GUIDE 경로 갱신 | Task 1 (원자적 동행) |
| CLAUDE.md 디렉토리 구조도 | Task 5 Step 2 |
| CLAUDE.md "3-tier와의 차이" | Task 5 Step 3 |
| CLAUDE.md 카탈로그 (using-atom-flow 추가, copy-feature 삭제) | Task 5 Step 4 |
| copy-feature 카탈로그 잔재 | Task 5 Step 4·7 |
| 게이트 보존 (변경 없음) | 모든 task에서 미수정 |
| writing-spec SKILL.md 잔재 라인 제거 | Task 5 Step 6 (Task 2 Step 1에서 발견 시 추가) |

→ 모든 spec 항목이 task에 매핑됨.

**2. Placeholder scan:**
- "TBD"/"TODO"/"적절한"/"적당한" 검색 → 없음
- "유사" 패턴 (Task N과 유사) → 없음
- 코드를 보여주지 않는 step → 없음 (각 step에 정확한 명령 또는 before/after 텍스트 포함)

**3. Type consistency:**
- 경로 명명: `shared-skills/using-atom-flow/SKILL.md` → `skills/using-atom-flow/SKILL.md` 일관 사용
- 환경변수: `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT` 일관 사용
- jq 쿼리: `del(.skills)`, `.skills` 일관 사용
- 검증 명령 패턴: 변경 후 즉시 ls/grep/jq로 확인 — 일관

→ 통과.

## Terminal output schema

`{ status: success, summary: "plan written for skills-consolidation", next: implementing, artifacts: [".atom-flow/plan/2026-04-28-skills-consolidation-plan.md"] }`
