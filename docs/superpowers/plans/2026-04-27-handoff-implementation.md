# `/handoff` & `/handoff-resume` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `/handoff` and `/handoff-resume` Claude Code slash-command pair, packaged as a standalone project at `~/Workspace/handoff/` that installs into `~/.claude/` via symlinks.

**Architecture:** Two slash commands that wrap two skills. The slash-command markdown (`commands/*.md`) is a thin entry point; the actual AI logic lives in `skills/*/SKILL.md`. An `install.sh` script symlinks the source files into `~/.claude/` so edits to the project repo take effect immediately. No build step, no executable code beyond the install/uninstall shell scripts.

**Tech Stack:** POSIX shell (install/uninstall scripts), Markdown with YAML frontmatter (Claude Code's native skill/command format).

**Spec:** `docs/superpowers/specs/2026-04-27-handoff-design.md`

**Project root:** `/Users/mirza/Workspace/handoff/` (already initialised as a git repo, with the spec committed).

---

## File Map

**New files (10):**

| Path | Purpose |
|---|---|
| `README.md` | User-facing docs: what these commands do, how to install, FAQ |
| `.gitignore` | Ignore macOS junk + editor artefacts |
| `install.sh` | Idempotent symlink installer |
| `uninstall.sh` | Symmetric remover |
| `commands/handoff.md` | `/handoff` slash-command entry point |
| `commands/handoff-resume.md` | `/handoff-resume` slash-command entry point |
| `skills/handoff/SKILL.md` | Logic for `/handoff`: clarity check, content generation, file write |
| `skills/handoff/template.md` | Reference template for the 8-section handoff file |
| `skills/handoff-resume/SKILL.md` | Logic for `/handoff-resume`: find latest, summarise, confirm |

(Existing spec at `docs/superpowers/specs/2026-04-27-handoff-design.md` stays untouched.)

**Total tasks: 5.**

---

## Testing Approach

This project produces markdown content that the Claude Code runtime interprets at AI inference time, plus two POSIX shell scripts. There is no unit-testable application logic.

- **`install.sh`/`uninstall.sh`** are tested by running them in a controlled environment and observing filesystem state.
- **`commands/*.md` and `skills/*/SKILL.md`** are tested by invoking the slash commands in real Claude Code sessions and observing AI behaviour.

This matches the "manual smoke tests sufficient" decision in spec §9. Task 5 is an explicit smoke-test task with concrete checks.

---

### Task 1: Project scaffolding (README, .gitignore, empty install/uninstall stubs)

**Files:**
- Create: `README.md`
- Create: `.gitignore`
- Create: `install.sh` (stub — full implementation in Task 4)
- Create: `uninstall.sh` (stub — full implementation in Task 4)

- [ ] **Step 1: Create `README.md`**

Write `/Users/mirza/Workspace/handoff/README.md`:

```markdown
# handoff

A pair of Claude Code slash commands that make session-to-session handoff smooth.

- **`/handoff [optional notes]`** — at the end of a session, generates a markdown file in `<repo>/.handoff/` capturing what was done, choices made, references, anti-patterns to remember, and what to do next. If next-step direction is ambiguous, the AI brainstorms with you before writing.
- **`/handoff-resume`** — at the start of a new session, picks up the latest handoff file from `<repo>/.handoff/`, summarises it, and asks you to confirm before continuing.

## Install

```bash
cd ~/Workspace/handoff
./install.sh
```

The installer creates symlinks from `~/.claude/commands/` and `~/.claude/skills/` into this project. Editing files in this repo takes effect on the next Claude Code session — no re-install needed.

## Uninstall

```bash
./uninstall.sh
```

## Filename format

```
<repo-root>/.handoff/<yyyymmddhhmm>-prompt-<title>.md
```

`<title>` is kebab-case, ≤6 words, AI-inferred from the session.

## Should `.handoff/` be git-tracked?

It depends.

- **Track it** if you want a project-level audit trail of cross-session decisions.
- **Ignore it** (`echo .handoff/ >> .gitignore`) if these are personal notes between you and Claude.

The `/handoff` command does NOT touch your `.gitignore`. That choice is yours.

## See also

- Design spec: [docs/superpowers/specs/2026-04-27-handoff-design.md](docs/superpowers/specs/2026-04-27-handoff-design.md)
- Implementation plan: [docs/superpowers/plans/2026-04-27-handoff-implementation.md](docs/superpowers/plans/2026-04-27-handoff-implementation.md)
```

- [ ] **Step 2: Create `.gitignore`**

Write `/Users/mirza/Workspace/handoff/.gitignore`:

```gitignore
.DS_Store
*.swp
.idea/
.vscode/
```

- [ ] **Step 3: Create stub `install.sh`**

Write `/Users/mirza/Workspace/handoff/install.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
echo "install.sh stub — implementation in Task 4"
exit 1
```

Then mark executable: `chmod +x install.sh`.

- [ ] **Step 4: Create stub `uninstall.sh`**

Write `/Users/mirza/Workspace/handoff/uninstall.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
echo "uninstall.sh stub — implementation in Task 4"
exit 1
```

Then mark executable: `chmod +x uninstall.sh`.

- [ ] **Step 5: Verify scaffolding**

Run from `/Users/mirza/Workspace/handoff`:

```bash
ls -la
```

Expected: `README.md`, `.gitignore`, `install.sh` (executable), `uninstall.sh` (executable), and the existing `docs/` and `.git/` dirs.

- [ ] **Step 6: Commit**

```bash
cd /Users/mirza/Workspace/handoff
git add README.md .gitignore install.sh uninstall.sh
git commit -m "chore: project scaffolding for handoff slash-command pair

README, gitignore, and stub install/uninstall scripts (full
implementation comes later in the plan)."
```

---

### Task 2: `/handoff` write side (slash command + skill + template)

This is the core feature. The three files in this task work as a unit:

- `commands/handoff.md` — slash-command entry point. Tells Claude to invoke the `handoff` skill and pass any user argument forward.
- `skills/handoff/SKILL.md` — the actual logic: clarity check, title generation, content generation, file write, edge cases.
- `skills/handoff/template.md` — reference template documenting the 8 expected sections. Used for human reference only; the AI generates output from the SKILL.md instructions, not by loading this file.

**Files:**
- Create: `commands/handoff.md`
- Create: `skills/handoff/SKILL.md`
- Create: `skills/handoff/template.md`

- [ ] **Step 1: Create `commands/handoff.md`**

Make the directory first: `mkdir -p commands`. Then write `/Users/mirza/Workspace/handoff/commands/handoff.md`:

```markdown
---
description: Generate a handoff markdown file capturing the current session so the next session can resume cleanly. Brainstorms first if next-step direction is unclear.
argument-hint: "[optional free-form notes]"
---

You are producing a session handoff for the user. Invoke the `handoff` skill — it contains the full procedure: clarity-check rules, content structure, filename format, and write logic. Follow its instructions exactly.

The user's argument string (everything after `/handoff`, or empty) is captured below as `$ARGUMENTS`. Pass it through to the skill as the "extra notes from user" input — it goes verbatim into Section 7 of the handoff file.

If `$ARGUMENTS` is empty, that is fine. The skill still runs the clarity check and produces the file. The argument is purely supplementary context.

$ARGUMENTS
```

- [ ] **Step 2: Create `skills/handoff/SKILL.md`**

Make the directory first: `mkdir -p skills/handoff`. Then write `/Users/mirza/Workspace/handoff/skills/handoff/SKILL.md`:

```markdown
---
name: handoff
description: Use when the user invokes /handoff to capture the current session so it can be resumed cleanly later. Runs a clarity check first; if next-step direction is unclear, the AI brainstorms with the user before writing the file. Final output is a markdown file in <repo>/.handoff/ following an 8-section template.
---

# Handoff: Capturing a Session for the Next One

## When this skill runs

You were invoked by the `/handoff` slash command. The user's argument string (free-form notes, possibly empty) was passed to you. Your job is to:

1. Run the **clarity check** below.
2. If unclear, brainstorm with the user until clear.
3. Generate the handoff file content following the 8-section template.
4. Write the file into the repo's `.handoff/` directory.
5. Confirm to the user with the file path.

## Step 1 — Clarity check (REQUIRED, before any writing)

Before writing any file, decide whether the **next-session direction** is clear enough that someone reading the handoff cold could act on it.

**The direction IS clear when at least one of these holds:**

- The current session resulted in a committed `docs/superpowers/specs/` or `docs/superpowers/plans/` document that describes what comes next (or what is in progress).
- The user explicitly chose between options in this session: "yes, lanjut ke Opsi B", "saya pilih A", "let's defer X to next session", or similar.
- The git state plus an in-progress task list unambiguously points to one next step (e.g., one `pending` TodoWrite task whose description names the work).

**The direction is NOT clear when:**

- The session was exploratory Q&A with no decision recorded.
- Multiple plausible next steps exist and the user has not chosen between them.
- You yourself feel uncertain about how to interpret what comes next.

**If unclear: brainstorm before writing.** Use the same discipline as the `superpowers:brainstorming` skill: one question at a time, multiple-choice when possible, lead with a recommendation. Do NOT write the file until the user's answers leave you with a clear next-step. Examples of brainstorm questions:

- "Anda ingin lanjut ke Opsi B di sesi berikutnya, atau ada arah lain yang sedang dipertimbangkan?"
- "Sesi ini banyak eksplorasi tapi belum ada keputusan eksplisit. Sebelum saya tulis handoff, mana yang paling tepat sebagai 'next step'? (a) merge dan deploy fitur X, (b) lanjut bug Y, (c) pause dan sesi berikutnya tentukan arah baru"

Once the user answers, proceed to Step 2.

## Step 2 — Generate the title

The title goes in the filename: `<yyyymmddhhmm>-prompt-<title>.md`.

Rules:

- Lowercase, kebab-case, ≤6 words, alphanumerics and hyphens only.
- Inferred from what the session was about, biased toward what is most useful for the next session ("swe-bench-add-deploy" beats "session-2026-04-27").
- If the user's `/handoff` argument contains a clear topic phrase, you may use it as the title hint (slugify it). Otherwise infer from the session.

Examples:

- A session that finished SWE-bench browse-only and is teeing up Opsi B → `swe-bench-add-deploy-prep`
- A session debugging a flaky test → `flaky-checkout-test-fix`
- A session reviewing PRs without changes → `pr-review-2026-04-28` (date in title is acceptable when the session has no clear topic)

Validate the title before writing. If it has more than 6 words or contains illegal characters, trim and clean it.

## Step 3 — Compute the filename

- Timestamp: local time, format `YYYYMMDDHHMM` (no seconds).
- Path: `<repo-root>/.handoff/<yyyymmddhhmm>-prompt-<title>.md`.
- **Repo root** is the nearest ancestor of the current working directory that contains a `.git/` directory. Use `git rev-parse --show-toplevel`. If that fails (not in a git repo), fall back to `pwd` and warn the user once in your final message.
- Create `.handoff/` if it does not exist.
- If the exact filename already exists (rare: same minute, same title), append `-2`, `-3`, ... before `.md` until you find a free name.

## Step 4 — Generate the content

Use the 8-section template below. Every section is present even if its content is `—` (so `/handoff-resume` can parse predictably).

Use `git log`, `git status`, `git diff --stat`, the conversation, and any TodoWrite/superpowers state visible in the session to fill the sections. Be specific — cite commit SHAs, file paths, and document paths.

**Template (the AI generates this; do not load `template.md` from disk — it exists for human reference only):**

```markdown
# {Title in Title Case}

**Date:** YYYY-MM-DD HH:MM ({TZ})
**Repo:** {repo name from path}
**Branch:** {git branch} (HEAD: {short SHA})
**Generated by:** /handoff [{verbatim user argument, or blank}]

---

## 1. Konteks Proyek
2-4 kalimat tentang proyek secara umum supaya sesi baru paham domain
tanpa perlu baca CLAUDE.md panjang lebar. Sebut: domain, stack utama,
ada apa di repo ini.

## 2. Yang Sudah Selesai di Sesi Ini
- Bullet pendek dengan action verb + objek konkret.
- Sertakan referensi commit SHA, file path, atau spec/plan inline.
- Lebih spesifik > lebih panjang. Hindari narasi.

## 3. Pilihan & Keputusan User Lewat Brainstorming
| Pertanyaan | Pilihan User | Konsekuensi |
|---|---|---|
| {pertanyaan singkat} | {jawaban user} | {dampak ke kode atau next step} |

(If no brainstorming choices were made in this session, write `—` instead of an empty table.)

## 4. Artefak yang Dihasilkan
- **Spec:** `path/to/spec.md` (atau `—`)
- **Plan:** `path/to/plan.md` (atau `—`)
- **Commits:** {N} commits ({base-SHA}..{head-SHA})
- **Files baru:** ...
- **Files diubah:** ...
- **Files dihapus:** ...

To compute the commit range, use `git log --oneline <merge-base>..HEAD`
where `<merge-base>` is the closest ancestor of HEAD and the default
branch (usually `main` or `master`). If you cannot determine a sensible
base, list the commits made during this session by checking `git reflog`
or by counting commits with timestamps inside the session window.

## 5. Anti-Patterns / Lessons Learned (CARRY FORWARD)
> Aturan-aturan ini berlaku untuk pengembangan selanjutnya juga.

- ❌ JANGAN ... (alasan / konteks insiden di sesi ini kalau ada)
- ✅ LAKUKAN ... (alasan)

(If no carry-forward lessons emerged, write `—`.)

## 6. Apa yang Akan Dikerjakan di Sesi Berikutnya
**Goal:** {one-sentence}

- Step / area / decision needing follow-up
- ...

**Starting point untuk sesi baru:**
- Branch: {current branch, or instruction like "rebase add-foo onto main first"}
- Existing spec/plan to read first: {path}

## 7. Catatan Tambahan dari User
{verbatim from /handoff <extra info>, or `—` if argument was empty}

## 8. Hal-Hal Penting Lain untuk Sesi Berikutnya
- Environment, tooling, host IP, credentials notes
- Open questions you noticed but the user hasn't decided yet
- Anything else surprising or hard to rediscover from code alone
- Time-sensitive items (deadlines, freeze windows)
```

## Step 5 — Write the file

Use the Write tool with the absolute path computed in Step 3. Do not modify any other file (do not auto-edit `.gitignore`).

## Step 6 — Confirm to the user

Reply briefly:

> "Handoff tersimpan di `<absolute path>`. Untuk melanjutkan di sesi baru, jalankan `/handoff-resume` dari direktori repo yang sama."

If you fell back to `pwd` because not in a git repo, add a one-line warning before the confirmation.

## Edge cases

- **Argument provided but session has no substantive content.** The clarity check covers this: the AI brainstorms first, e.g. "Sesi ini belum ada konten substantif untuk di-handoff. Yakin tetap mau buat file? Atau ada konteks yang belum saya catat?"
- **Filename collision.** Append `-2`, `-3`, ... before `.md`.
- **`.handoff/` already exists with files.** Fine — just add a new file.
- **User runs `/handoff` again immediately.** Clarity check will likely pass (the previous handoff is the latest "next step"); produce a new file with a slightly newer timestamp.
- **Repo with no commits yet.** Use `pwd` as the root, warn once.

## Anti-patterns to avoid

- ❌ Do NOT silently overwrite an existing handoff file. Always create a new file with the timestamp/title naming. If a collision occurs, suffix with `-2`, `-3`.
- ❌ Do NOT auto-edit `.gitignore`. The README explains the trade-off; the user owns that choice.
- ❌ Do NOT pad the handoff with filler. Every bullet should be actionable or referential.
- ❌ Do NOT write a handoff file when the clarity check fails. Brainstorm first.
```

- [ ] **Step 3: Create `skills/handoff/template.md`**

Write `/Users/mirza/Workspace/handoff/skills/handoff/template.md` — same template as in SKILL.md Step 4, but as a standalone reference doc. Content:

```markdown
# Handoff Template

This file documents the 8-section structure of a handoff markdown.
The `/handoff` skill generates output following this shape — it does
NOT load this file at runtime. It exists only as a human-readable
reference.

```markdown
# {Title in Title Case}

**Date:** YYYY-MM-DD HH:MM ({TZ})
**Repo:** {repo name}
**Branch:** {git branch} (HEAD: {short SHA})
**Generated by:** /handoff [{verbatim user argument, or blank}]

---

## 1. Konteks Proyek
2-4 sentences explaining the project domain & stack so a fresh session
gets oriented without reading CLAUDE.md.

## 2. Yang Sudah Selesai di Sesi Ini
- Action verb + concrete object bullets.
- Cite commit SHAs and file paths inline.

## 3. Pilihan & Keputusan User Lewat Brainstorming
| Pertanyaan | Pilihan User | Konsekuensi |
|---|---|---|
| ... | ... | ... |

(Or `—` if no choices were made this session.)

## 4. Artefak yang Dihasilkan
- **Spec:** path or `—`
- **Plan:** path or `—`
- **Commits:** N commits (base-SHA..head-SHA)
- **Files baru:** ...
- **Files diubah:** ...
- **Files dihapus:** ...

## 5. Anti-Patterns / Lessons Learned (CARRY FORWARD)
- ❌ JANGAN ... (reason)
- ✅ LAKUKAN ... (reason)

(Or `—` if none.)

## 6. Apa yang Akan Dikerjakan di Sesi Berikutnya
**Goal:** one sentence

- Step / area / decision

**Starting point:**
- Branch: ...
- Spec/plan to read first: ...

## 7. Catatan Tambahan dari User
Verbatim from /handoff <args>, or `—`.

## 8. Hal-Hal Penting Lain untuk Sesi Berikutnya
- Environment, tooling, IP, credentials
- Open questions
- Surprising / hidden context
- Deadlines / freeze windows
```
```

- [ ] **Step 4: Verify SKILL.md frontmatter parses cleanly**

Quick sanity check that the YAML frontmatter is well-formed:

```bash
cd /Users/mirza/Workspace/handoff
python3 -c "
import re, yaml, sys
for path in ['skills/handoff/SKILL.md', 'commands/handoff.md']:
    with open(path) as f:
        text = f.read()
    m = re.match(r'^---\n(.*?)\n---\n', text, re.DOTALL)
    assert m, f'{path}: no frontmatter'
    data = yaml.safe_load(m.group(1))
    print(f'{path}: {list(data.keys())}')
"
```

Expected: prints two lines listing each file's frontmatter keys. `commands/handoff.md` should show `['description', 'argument-hint']`. `skills/handoff/SKILL.md` should show `['name', 'description']`.

If the script errors out on `yaml`, install with `pip install pyyaml` first or skip this check (the frontmatter syntax is short enough to verify by eye).

- [ ] **Step 5: Commit**

```bash
cd /Users/mirza/Workspace/handoff
git add commands/handoff.md skills/handoff/
git commit -m "feat: /handoff slash command with clarity-check skill

Adds the write side: a slash command, the skill that drives content
generation and writes the file, and a human-readable template doc.
Skill enforces a clarity check that brainstorms with the user before
writing if the next-session direction is ambiguous."
```

---

### Task 3: `/handoff-resume` read side (slash command + skill)

**Files:**
- Create: `commands/handoff-resume.md`
- Create: `skills/handoff-resume/SKILL.md`

- [ ] **Step 1: Create `commands/handoff-resume.md`**

Write `/Users/mirza/Workspace/handoff/commands/handoff-resume.md`:

```markdown
---
description: Load the latest handoff file from <repo>/.handoff/, summarise it, and ask the user to confirm before continuing the work it describes.
argument-hint: ""
---

You are resuming work from a previous Claude Code session. Invoke the `handoff-resume` skill — it locates the latest handoff file, summarises it, and asks the user to confirm before proceeding. Follow its instructions exactly.

This command takes no arguments. If the user typed extra text after `/handoff-resume`, ignore it and continue with the default behaviour.
```

- [ ] **Step 2: Create `skills/handoff-resume/SKILL.md`**

Make the directory first: `mkdir -p skills/handoff-resume`. Then write `/Users/mirza/Workspace/handoff/skills/handoff-resume/SKILL.md`:

```markdown
---
name: handoff-resume
description: Use when the user invokes /handoff-resume at the start of a new Claude Code session to pick up where the previous session left off. Reads the latest file from <repo>/.handoff/, presents a brief summary, and waits for explicit confirmation before continuing the prescribed next steps.
---

# Resuming from a Handoff File

## When this skill runs

You were invoked by the `/handoff-resume` slash command. The user has no argument to give you. Your job:

1. Locate the repo's `.handoff/` directory and find the latest file.
2. Read the full file into your context.
3. Show the user a short summary and ask for confirmation.
4. After confirmation (or redirection), proceed with full handoff context loaded.

## Step 1 — Locate the handoff directory

Determine the repo root: `git rev-parse --show-toplevel`. If that fails, use the current working directory.

Then look at `<repo-root>/.handoff/`.

Two failure paths:

- **Directory does not exist:** Reply: `"Tidak ada direktori .handoff/ di repo ini. Sesi sebelumnya belum pernah membuat handoff. Anda bisa mulai segar atau jalankan /handoff di akhir sesi ini untuk mulai journaling."` Then stop.
- **Directory exists but is empty:** Reply: `"Direktori .handoff/ ada tapi kosong — belum ada handoff tersimpan. Sesi ini bisa mulai dari awal."` Then stop.

## Step 2 — Pick the latest file

List files in `.handoff/` matching the pattern `*.md`. Sort lexicographically and take the **last** entry. Because filenames start with `yyyymmddhhmm`, lex sort = chronological sort.

If multiple files share the same timestamp prefix (collision suffixes `-2`, `-3`), the lex sort still picks the highest suffix correctly because `-2` < `-3` etc.

## Step 3 — Read the file

Use the Read tool. Load the entire file. You will need the title, dates, Sections 1, 2, 5, 6, 7, 8 to summarise (Section 3 and 4 are reference detail).

## Step 4 — Show summary and confirm

Reply with this exact shape:

```
Saya menemukan handoff terakhir: **{title}** (dari {date}, repo {repo}).

Sesi sebelumnya selesai:
{Section 2 condensed to 1-2 lines — the most actionable bullets}

Rencana berikutnya:
{Section 6 Goal + 1-2 of the sub-bullets}

{If Section 5 has anti-patterns, add: "Catatan penting: {one line}"}

Apakah Anda yakin ingin melanjutkan task handover ini?
```

Then stop and wait for the user's reply. Do NOT begin executing the plan from Section 6 until the user confirms.

## Step 5 — Proceed based on user reply

- **User confirms** ("ya", "lanjut", "iya", "yes", or similar): Acknowledge briefly, then begin executing Section 6's plan. The full file content is already in your context — you do NOT need to re-read it. Apply the anti-patterns from Section 5 throughout your work.
- **User redirects** ("ganti haluan", "saya mau X dulu", or proposes a different task): Treat the handoff as background context only. Follow the new direction. Do NOT silently dismiss the handoff — you can still draw on Sections 1, 5, and 8 (project context, anti-patterns, environment) for the new work.
- **User declines without redirect**: Reply: `"OK, handoff tetap ada di {file path}. Silakan beri tahu saya apa yang Anda kerjakan hari ini."` Then wait.

## Edge cases

- **More than one file in `.handoff/`.** Pick the lex-last. Do NOT mention the others — the user can `ls .handoff/` themselves if curious.
- **File present but malformed (missing sections).** Read whatever you can. In your summary, say `"(some sections missing — handoff may be partial)"` so the user can decide.
- **File is empty.** Treat as the directory being empty: tell the user, do not crash.
- **Repo has changed branches since the handoff.** The handoff records its own branch in the header. If the current branch differs, mention it in the summary: `"Catatan: handoff ini dibuat di branch X; Anda sekarang di branch Y."`

## Anti-patterns to avoid

- ❌ Do NOT execute the Section 6 plan before the user confirms. The whole point of this skill is the human gate.
- ❌ Do NOT delete or modify the handoff file. It is a journal entry; future runs of `/handoff-resume` may need it.
- ❌ Do NOT load handoffs from other repos or directories. The lookup is scoped to the current repo's `.handoff/` only.
- ❌ Do NOT prompt the user a second time after they confirm. Once they say "ya", proceed without further questions (unless ambiguity arises during execution).
```

- [ ] **Step 3: Verify frontmatter again**

```bash
cd /Users/mirza/Workspace/handoff
python3 -c "
import re, yaml
for path in ['skills/handoff-resume/SKILL.md', 'commands/handoff-resume.md']:
    with open(path) as f:
        text = f.read()
    m = re.match(r'^---\n(.*?)\n---\n', text, re.DOTALL)
    assert m, f'{path}: no frontmatter'
    data = yaml.safe_load(m.group(1))
    print(f'{path}: {list(data.keys())}')
"
```

Expected: 2 OK lines.

- [ ] **Step 4: Commit**

```bash
cd /Users/mirza/Workspace/handoff
git add commands/handoff-resume.md skills/handoff-resume/
git commit -m "feat: /handoff-resume slash command with confirmation skill

Adds the read side: locate the latest handoff file in <repo>/.handoff/,
summarise it, and require explicit user confirmation before resuming
the prescribed next steps. Skill is scoped to the current repo only
and never modifies handoff files."
```

---

### Task 4: `install.sh` and `uninstall.sh` (idempotent symlink installer)

**Files:**
- Modify: `install.sh` (replace stub with full implementation)
- Modify: `uninstall.sh` (replace stub with full implementation)

- [ ] **Step 1: Write the full `install.sh`**

Replace the contents of `/Users/mirza/Workspace/handoff/install.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

# install.sh — symlink the handoff slash commands and skills into ~/.claude/.
# Idempotent: re-running is safe. Aborts (without overwriting) if a target
# exists and is not a symlink that already points to this repo.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CLAUDE_DIR="${HOME}/.claude"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
SKILLS_DIR="${CLAUDE_DIR}/skills"

mkdir -p "${COMMANDS_DIR}" "${SKILLS_DIR}"

link_one() {
  local src="$1"
  local dest="$2"

  if [[ -L "${dest}" ]]; then
    local current
    current="$(readlink "${dest}")"
    if [[ "${current}" == "${src}" ]]; then
      echo "= ${dest} (already linked)"
      return 0
    else
      echo "! ${dest} exists as a symlink to ${current} (expected ${src})" >&2
      echo "  Refusing to overwrite. Remove it manually if you want to relink." >&2
      return 1
    fi
  fi

  if [[ -e "${dest}" ]]; then
    echo "! ${dest} exists and is NOT a symlink. Refusing to overwrite." >&2
    echo "  Move or remove it, then re-run install.sh." >&2
    return 1
  fi

  ln -s "${src}" "${dest}"
  echo "+ ${dest} -> ${src}"
}

set +e
fail=0
link_one "${SCRIPT_DIR}/commands/handoff.md"          "${COMMANDS_DIR}/handoff.md"          || fail=1
link_one "${SCRIPT_DIR}/commands/handoff-resume.md"   "${COMMANDS_DIR}/handoff-resume.md"   || fail=1
link_one "${SCRIPT_DIR}/skills/handoff"               "${SKILLS_DIR}/handoff"               || fail=1
link_one "${SCRIPT_DIR}/skills/handoff-resume"        "${SKILLS_DIR}/handoff-resume"        || fail=1
set -e

if [[ "${fail}" -ne 0 ]]; then
  echo
  echo "install.sh finished with errors. Resolve the conflicts above and re-run." >&2
  exit 1
fi

echo
echo "Done. /handoff and /handoff-resume are now available in any Claude Code session."
```

`chmod +x install.sh` (no-op if already executable from Task 1).

- [ ] **Step 2: Write the full `uninstall.sh`**

Replace the contents of `/Users/mirza/Workspace/handoff/uninstall.sh` with:

```bash
#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — remove ONLY the symlinks that install.sh created.
# Will not touch real files (refuses if the target is not a symlink to this repo).

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

CLAUDE_DIR="${HOME}/.claude"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
SKILLS_DIR="${CLAUDE_DIR}/skills"

unlink_one() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "${dest}" && ! -L "${dest}" ]]; then
    echo "= ${dest} (not present)"
    return 0
  fi

  if [[ ! -L "${dest}" ]]; then
    echo "! ${dest} is not a symlink. Refusing to remove." >&2
    return 1
  fi

  local current
  current="$(readlink "${dest}")"
  if [[ "${current}" != "${src}" ]]; then
    echo "! ${dest} -> ${current} (expected ${src}). Refusing to remove." >&2
    return 1
  fi

  rm "${dest}"
  echo "- ${dest}"
}

set +e
fail=0
unlink_one "${SCRIPT_DIR}/commands/handoff.md"        "${COMMANDS_DIR}/handoff.md"          || fail=1
unlink_one "${SCRIPT_DIR}/commands/handoff-resume.md" "${COMMANDS_DIR}/handoff-resume.md"   || fail=1
unlink_one "${SCRIPT_DIR}/skills/handoff"             "${SKILLS_DIR}/handoff"               || fail=1
unlink_one "${SCRIPT_DIR}/skills/handoff-resume"      "${SKILLS_DIR}/handoff-resume"        || fail=1
set -e

if [[ "${fail}" -ne 0 ]]; then
  echo
  echo "uninstall.sh finished with errors. Inspect the warnings above." >&2
  exit 1
fi

echo
echo "Done. /handoff and /handoff-resume have been unlinked."
```

`chmod +x uninstall.sh`.

- [ ] **Step 3: Run `install.sh` for real**

```bash
cd /Users/mirza/Workspace/handoff
./install.sh
```

Expected output (4 `+` lines, 1 `Done.` line):

```
+ /Users/mirza/.claude/commands/handoff.md -> /Users/mirza/Workspace/handoff/commands/handoff.md
+ /Users/mirza/.claude/commands/handoff-resume.md -> /Users/mirza/Workspace/handoff/commands/handoff-resume.md
+ /Users/mirza/.claude/skills/handoff -> /Users/mirza/Workspace/handoff/skills/handoff
+ /Users/mirza/.claude/skills/handoff-resume -> /Users/mirza/Workspace/handoff/skills/handoff-resume

Done. /handoff and /handoff-resume are now available in any Claude Code session.
```

- [ ] **Step 4: Verify symlinks**

```bash
ls -l ~/.claude/commands/handoff.md ~/.claude/commands/handoff-resume.md
ls -l ~/.claude/skills/handoff ~/.claude/skills/handoff-resume
```

Expected: each line ends with ` -> /Users/mirza/Workspace/handoff/...`.

- [ ] **Step 5: Verify idempotency**

Run `./install.sh` a second time. Expected output: 4 `=` lines (already linked) and the `Done.` line. No errors.

- [ ] **Step 6: Commit**

```bash
cd /Users/mirza/Workspace/handoff
git add install.sh uninstall.sh
git commit -m "feat: idempotent install.sh and uninstall.sh

Symlinks the handoff commands/skills into ~/.claude/. Refuses to
overwrite real files; idempotent on repeat invocations. Uninstall
mirrors the install but only removes symlinks pointing at this repo."
```

---

### Task 5: End-to-end smoke test

This task uses the real Claude Code runtime to verify the slash commands behave as designed. The user runs the smoke checklist; the implementer fixes anything that fails.

**Files:** None modified in this task unless smoke tests reveal a defect.

- [ ] **Step 1: Round-trip in this same project**

In a fresh Claude Code session inside `/Users/mirza/Workspace/handoff/`:

1. Open the repo. Verify the project state by running `git log --oneline | head -5` (manually or via Claude).
2. Type `/handoff this is a test`.
3. Expected: AI runs the clarity check. Since this session is a smoke test, it may brainstorm ("Sesi ini hanya verifikasi, ada sesuatu yang ingin di-handoff?"). Answer affirmatively, e.g. "iya, handoff dummy untuk test."
4. Verify a file appears at `/Users/mirza/Workspace/handoff/.handoff/<yyyymmddhhmm>-prompt-<title>.md`.
5. Open the file. Verify all 8 sections are present, the timestamp matches the current minute, the title is kebab-case, Section 7 contains "this is a test".

If the file is malformed or missing a section, fix `skills/handoff/SKILL.md` and redo.

- [ ] **Step 2: `/handoff-resume` in a fresh session**

In a brand-new Claude Code session inside `/Users/mirza/Workspace/handoff/`:

1. Type `/handoff-resume`.
2. Expected: AI summarises the file from Step 1 and asks: "Apakah Anda yakin ingin melanjutkan task handover ini?"
3. Reply "iya."
4. Expected: AI acknowledges and is ready to proceed (it has nothing concrete to do for a dummy handoff, but should confirm it has loaded context).

If the AI executes work without confirmation, or fails to find the file, fix `skills/handoff-resume/SKILL.md` and redo.

- [ ] **Step 3: Empty-directory edge case**

In a different repo (e.g., `/Users/mirza/Workspace/benchmach-manager/`), run `/handoff-resume` without first creating `.handoff/`.

Expected: AI replies that no handoff exists and stops.

If AI tries to read a non-existent path or crashes, fix the skill.

- [ ] **Step 4: Real-use round-trip in `benchmach-manager`**

This is the canonical reason the project exists.

1. In `/Users/mirza/Workspace/benchmach-manager/` (clean checkout of `add-swe-bench` branch), type `/handoff lanjut ke Opsi B`.
2. The session has clear context (just finished SWE-bench Opsi A) and a clear next step (Opsi B). Clarity check should pass without brainstorming.
3. Verify a file appears at `benchmach-manager/.handoff/<yyyymmddhhmm>-prompt-*.md`.
4. Open the file. Section 6 should mention "Opsi B" or "Deploy workspace". Section 5 should reference at least one of the anti-patterns from the SWE-bench session (e.g., "JANGAN tambahkan `|| echo` ke `git clone`").
5. In a fresh session in the same repo, run `/handoff-resume`.
6. Confirm the summary is accurate. Confirm with "iya."
7. AI should be ready to begin Opsi B planning.

If the file misses key context, return to Task 2 and tighten the SKILL.md instructions on what to extract.

- [ ] **Step 5: Clarity-check edge case**

In a Claude Code session with no substantive work (just a `Hello, can you tell me about Python?` exchange and a brief answer), type `/handoff`.

Expected: AI brainstorms before writing — e.g., "Sesi ini hanya tanya-jawab umum, tidak ada keputusan atau task yang sedang dikerjakan. Yakin ingin buat handoff? Atau lewati saja?"

If the AI writes a vacuous handoff without asking, the clarity check rule is not being enforced — tighten `skills/handoff/SKILL.md` Step 1.

- [ ] **Step 6: Commit smoke-test fixes if any**

If any of Steps 1-5 required fixes:

```bash
cd /Users/mirza/Workspace/handoff
git add -A
git commit -m "fix: smoke-test polish for /handoff and /handoff-resume

Issues found during end-to-end smoke testing:
- {summary of fix 1}
- {summary of fix 2}"
```

If no fixes were needed, skip this commit.

- [ ] **Step 7: Final verification**

```bash
cd /Users/mirza/Workspace/handoff
git log --oneline
ls -la commands/ skills/
ls -l ~/.claude/commands/handoff*.md ~/.claude/skills/handoff*
```

Expected:
- 5-6 commits (1 spec, 1 plan, 1 scaffolding, 1 /handoff, 1 /handoff-resume, 1 install scripts; possibly +1 smoke-test fix)
- `commands/` has 2 files; `skills/` has 2 directories with the right contents.
- All 4 symlinks in `~/.claude/` are present and point into the project.

---

## Self-Review Notes

**Spec coverage check**

| Spec section | Implemented in |
|---|---|
| §1 Goal | Tasks 2 + 3 (the two slash commands) |
| §2 Non-Goals | Honoured throughout — no fuzzy match, no `--list`, no `--dry-run` |
| §3.1 `/handoff` argument behaviour | Task 2 (`commands/handoff.md` + `skills/handoff/SKILL.md` Step 4 captures argument verbatim into Section 7) |
| §3.2 `/handoff-resume` behaviour | Task 3 (`skills/handoff-resume/SKILL.md` Steps 1-5) |
| §3.3 Clarity check | Task 2 (`skills/handoff/SKILL.md` Step 1, including the brainstorm-style examples) |
| §4 File output contract (location, filename, gitignore policy) | Task 2 Step 3 (filename + collision handling), README in Task 1 (gitignore policy) |
| §5 Handoff template (8 sections) | Task 2 Step 4 (in SKILL.md) and Task 2 Step 3 (template.md as reference) |
| §6 Project layout | Tasks 1-4 cumulatively produce the layout |
| §7 Install via symlinks | Task 4 (install.sh idempotent, uninstall.sh symmetric) |
| §8 Edge cases | Tasks 2 (filename collision, no git repo), 3 (empty dir, missing dir, malformed file), 4 (idempotency), 5 (smoke tests cover real edge cases) |
| §9 Manual smoke testing | Task 5 |
| §11 Open items resolved | Task 2 fixes the SKILL.md vs template.md split (template is reference-only); commands/*.md frontmatter modeled on `daily-report.md` |

**Type/name consistency check**

- File paths and slash-command names are consistent across all tasks: `/handoff`, `/handoff-resume`, `commands/handoff.md`, `commands/handoff-resume.md`, `skills/handoff/SKILL.md`, `skills/handoff-resume/SKILL.md`.
- Frontmatter field names match Claude Code conventions seen in `~/.claude/commands/daily-report.md` and `~/.claude/skills/daily-report/SKILL.md`.
- The 8-section template is described once in SKILL.md and once in template.md; both should be kept in sync (template.md says so explicitly).

**Implementer pitfalls**

1. **Do not load `template.md` from disk inside the skill.** The skill generates output from the description in SKILL.md. `template.md` is a human-readable reference only. The Task 2 step 3 instructions make this explicit, but reviewers should double-check during implementation.
2. **Symlink target paths are absolute.** `install.sh` uses `SCRIPT_DIR` resolved via `pwd` so the symlinks survive `cd` in other shells. Do not change to relative paths.
3. **The clarity check is a behaviour rule, not a hard validator.** It must be enforced via clear language in `SKILL.md`. There is no programmatic check the implementer can write — the AI's adherence is the only mechanism. Step 5 of Task 5 (smoke test) is the verification gate.
4. **Section 4 commit-range computation in the handoff file.** The `<merge-base>..HEAD` strategy works for feature branches but may produce noise on `main` itself. The skill's instructions say to "fall back to reflog or session-window timestamps" — the implementer should ensure that fallback prose is clear in SKILL.md. (Task 2 Step 4 already includes this guidance; just flag it for review.)
