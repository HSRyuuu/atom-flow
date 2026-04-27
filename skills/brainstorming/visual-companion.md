# Visual Companion Guide

Mockup, diagram, option을 보여주기 위한 browser 기반 visual brainstorming companion.

## 언제 쓰는가

Session 단위가 아니라 **질문 단위**로 판단한다. 기준: **사용자가 읽는 것보다 보는 쪽이 더 잘 이해되는 content인가?**

**Browser 사용** — content 자체가 시각적일 때:

- **UI mockup** — wireframe, layout, navigation 구조, component design
- **Architecture diagram** — system 구성요소, data flow, 관계도
- **Side-by-side 시각 비교** — 두 layout, 두 color scheme, 두 design 방향 비교
- **Design polish** — look and feel, spacing, visual hierarchy에 관한 질문
- **공간적 관계** — state machine, flowchart, entity relationship을 diagram으로

**Terminal 사용** — content가 text 또는 표 형태일 때:

- **Requirement와 scope 질문** — "X가 무슨 뜻인가?", "어떤 feature가 scope인가?"
- **개념적 A/B/C 선택** — 말로 설명된 approach 중 고르기
- **Trade-off list** — pros/cons, 비교 표
- **기술적 결정** — API design, data modeling, architecture approach 선택
- **명확화 질문** — 답이 단어인 질문 (시각적 preference가 아닌)

UI 주제에 *대한* 질문이라고 해서 자동으로 visual question이 되지 않는다. "어떤 종류의 wizard를 원하냐"는 개념적 질문 — terminal. "이 중 어떤 wizard layout이 맞는 느낌이냐"는 visual — browser.

## 동작 방식

Server가 디렉토리를 감시하고 가장 최근 HTML 파일을 browser에 serve한다. `screen_dir`에 HTML을 쓰면 사용자가 browser에서 보고 option을 클릭할 수 있다. 선택은 `state_dir/events`에 기록되며, 다음 turn에서 읽는다.

**Content fragment vs 전체 document:** HTML 파일이 `<!DOCTYPE` 또는 `<html`로 시작하면 server가 그대로 serve한다 (helper script만 주입). 그 외에는 server가 frame template으로 자동 wrapping한다 — header, CSS theme, selection indicator, 상호작용 infrastructure를 추가한다. **기본적으로 content fragment를 쓴다.** 전체 document는 페이지 전체를 제어해야 할 때만 쓴다.

## Session 시작

```bash
# persistence 옵션으로 server 시작 (mockup이 project에 저장됨)
scripts/start-server.sh --project-dir /path/to/project

# 반환값: {"type":"server-started","port":52341,"url":"http://localhost:52341",
#           "screen_dir":"/path/to/project/.atom-flow/brainstorm/12345-1706000000/content",
#           "state_dir":"/path/to/project/.atom-flow/brainstorm/12345-1706000000/state"}
```

응답에서 `screen_dir`와 `state_dir`를 저장한다. 사용자에게 URL을 열도록 안내한다.

**연결 정보 찾기:** Server가 시작 시 JSON을 `$STATE_DIR/server-info`에 쓴다. Background로 server를 띄우고 stdout을 캡처하지 못했다면 그 파일을 읽어 URL과 port를 얻는다. `--project-dir`을 쓴 경우 `<project>/.atom-flow/brainstorm/`에서 session 디렉토리를 확인한다.

**Note:** `--project-dir`에 project root를 넘겨 mockup이 `.atom-flow/brainstorm/`에 남고 server 재시작을 넘어 살아남도록 한다. 없으면 `/tmp`에 떨어져 청소된다. 아직 없으면 사용자에게 `.atom-flow/`를 `.gitignore`에 추가하도록 알려준다.

**Platform별 server 실행:**

**Claude Code (macOS / Linux):**
```bash
# 기본 모드로 충분 — script가 직접 background 처리
scripts/start-server.sh --project-dir /path/to/project
```

**Claude Code (Windows):**
```bash
# Windows는 auto-detect 후 foreground 모드를 쓰며, 이는 tool call을 block한다.
# Bash tool 호출 시 run_in_background: true를 설정하여 server가 turn을 넘어 살아남게 한다.
scripts/start-server.sh --project-dir /path/to/project
```
Bash tool로 호출할 때 `run_in_background: true`로 설정. 이후 turn에서 `$STATE_DIR/server-info`를 읽어 URL과 port를 얻는다.

**Codex:**
```bash
# Codex는 background process를 reap한다. Script가 CODEX_CI를 auto-detect해
# foreground 모드로 전환한다. 그냥 실행하면 된다 — 추가 flag 불필요.
scripts/start-server.sh --project-dir /path/to/project
```

**Gemini CLI:**
```bash
# --foreground를 쓰고 shell tool 호출에 is_background: true 설정
# → process가 turn을 넘어 살아남는다
scripts/start-server.sh --project-dir /path/to/project --foreground
```

**기타 환경:** Server는 turn 사이에 background로 계속 살아 있어야 한다. 환경이 detached process를 reap한다면 `--foreground`를 쓰고 해당 platform의 background 실행 방법으로 launch한다.

Browser에서 URL에 접근이 안 된다면 (remote/containerized 환경에서 흔함) non-loopback host에 bind:

```bash
scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

`--url-host`로 반환 URL JSON에 찍힐 hostname을 제어한다.

## The Loop

1. **Server가 살아 있는지 확인**, 그 후 `screen_dir`의 새 파일에 **HTML을 쓴다**:
   - 매 write 전에 `$STATE_DIR/server-info`가 있는지 확인. 없거나 `$STATE_DIR/server-stopped`가 있다면 server가 종료된 것 — `start-server.sh`로 다시 띄우고 진행. Server는 비활동 30분 후 auto-exit.
   - 의미 있는 파일명 사용: `platform.html`, `visual-style.html`, `layout.html`
   - **파일명을 재사용하지 않는다** — 화면마다 새 파일
   - Write tool 사용 — **cat/heredoc 금지** (terminal을 noise로 도배함)
   - Server가 자동으로 최신 파일을 serve

2. **사용자에게 다음을 안내하고 turn을 종료한다:**
   - URL을 다시 알려준다 (매 단계마다, 처음만이 아님)
   - 화면에 무엇이 있는지 짧은 text 요약 (예: "홈페이지 layout 3개 option을 보여드립니다")
   - Terminal에서 답해 달라고 요청: "보시고 말씀해 주세요. option을 선택하려면 클릭하세요."

3. **다음 turn에** — 사용자가 terminal에서 응답한 뒤:
   - `$STATE_DIR/events`가 있으면 읽는다 — browser 상호작용(클릭, 선택)이 JSON line으로 담겨 있음
   - 사용자의 terminal text와 합쳐 전체 그림을 본다
   - Terminal 메시지가 primary feedback이고, `state_dir/events`는 구조화된 상호작용 데이터

4. **Iterate or advance** — feedback이 현재 화면을 바꾼다면 새 파일을 쓴다 (예: `layout-v2.html`). 현재 단계가 validated될 때만 다음 질문으로 이동.

5. **Terminal로 돌아갈 때 unload** — 다음 단계가 browser를 필요로 하지 않을 때(예: 명확화 질문, trade-off 논의), 대기 화면을 push하여 오래된 content를 치운다:

   ```html
   <!-- filename: waiting.html (또는 waiting-2.html 등) -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">Terminal에서 계속 진행합니다...</p>
   </div>
   ```

   이미 해결된 선택 화면을 사용자가 계속 바라보는 상황을 막는다. 다음 visual question이 오면 평소대로 새 content 파일을 push.

6. 완료될 때까지 반복.

## Content Fragment 쓰기

Page 안에 들어갈 content만 쓴다. Server가 frame template으로 자동 wrap한다 (header, theme CSS, selection indicator, 상호작용 infrastructure).

**최소 예시:**

```html
<h2>어떤 layout이 더 나은가?</h2>
<p class="subtitle">가독성과 visual hierarchy를 고려해 주세요</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Single Column</h3>
      <p>깔끔하고 집중된 읽기 경험</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>Two Column</h3>
      <p>Sidebar navigation + main content</p>
    </div>
  </div>
</div>
```

끝. `<html>`, CSS, `<script>` 태그 모두 불필요. Server가 다 제공한다.

## 사용 가능한 CSS Class

Frame template이 content를 위해 제공하는 CSS class:

### Options (A/B/C 선택)

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>Title</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

**Multi-select:** 컨테이너에 `data-multiselect`를 추가하면 여러 option을 선택할 수 있다. 클릭할 때마다 toggle. indicator bar가 개수를 표시.

```html
<div class="options" data-multiselect>
  <!-- 동일 option markup — 사용자는 여러 개를 select/deselect 가능 -->
</div>
```

### Cards (visual design)

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup content --></div>
    <div class="card-body">
      <h3>Name</h3>
      <p>Description</p>
    </div>
  </div>
</div>
```

### Mockup container

```html
<div class="mockup">
  <div class="mockup-header">Preview: Dashboard Layout</div>
  <div class="mockup-body"><!-- mockup HTML --></div>
</div>
```

### Split view (side-by-side)

```html
<div class="split">
  <div class="mockup"><!-- left --></div>
  <div class="mockup"><!-- right --></div>
</div>
```

### Pros/Cons

```html
<div class="pros-cons">
  <div class="pros"><h4>Pros</h4><ul><li>장점</li></ul></div>
  <div class="cons"><h4>Cons</h4><ul><li>단점</li></ul></div>
</div>
```

### Mock element (wireframe building block)

```html
<div class="mock-nav">Logo | Home | About | Contact</div>
<div style="display: flex;">
  <div class="mock-sidebar">Navigation</div>
  <div class="mock-content">Main content area</div>
</div>
<button class="mock-button">Action Button</button>
<input class="mock-input" placeholder="Input field">
<div class="placeholder">Placeholder area</div>
```

### Typography and section

- `h2` — page title
- `h3` — section heading
- `.subtitle` — title 아래의 보조 text
- `.section` — 하단 margin이 있는 content block
- `.label` — 작은 uppercase label text

## Browser Event Format

사용자가 browser에서 option을 클릭하면 상호작용이 `$STATE_DIR/events`에 기록된다 (line당 JSON 객체 하나). 새 화면을 push하면 파일이 자동 비워진다.

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

Event 전체 흐름은 사용자의 탐색 경로를 보여준다 — 최종 결정 전에 여러 option을 눌러볼 수 있다. 마지막 `choice` event가 대개 최종 선택이지만, 클릭 pattern 자체가 망설임이나 선호를 드러낼 수 있어 물어볼 가치가 있다.

`$STATE_DIR/events`가 없다면 사용자가 browser와 상호작용하지 않은 것 — terminal text만 사용한다.

## Design Tip

- **질문에 맞춰 fidelity를 조절** — layout 질문엔 wireframe, polish 질문엔 polish
- **각 page에 질문을 설명** — "이 중 고르세요" 말고 "어떤 layout이 더 professional하게 느껴지나요?"
- **Advance 전에 iterate** — feedback이 현재 화면을 바꾸면 새 버전 작성
- **화면당 option은 2-4개**
- **중요할 땐 실제 content 사용** — photography portfolio라면 실제 이미지(Unsplash). Placeholder content는 design 문제를 가린다.
- **Mockup은 단순하게** — pixel-perfect보다 layout·구조에 집중

## File 명명

- 의미 있는 이름: `platform.html`, `visual-style.html`, `layout.html`
- 파일명 재사용 금지 — 화면마다 새 파일
- Iteration은 version suffix: `layout-v2.html`, `layout-v3.html`
- Server는 수정 시각 기준 최신 파일을 serve

## 청소

```bash
scripts/stop-server.sh $SESSION_DIR
```

Session이 `--project-dir`을 썼다면 mockup 파일은 `.atom-flow/brainstorm/`에 남아 나중에 참고 가능. `/tmp` session만 stop 시 삭제.

## Reference

- Frame template (CSS reference): `scripts/frame-template.html`
- Helper script (client-side): `scripts/helper.js`
