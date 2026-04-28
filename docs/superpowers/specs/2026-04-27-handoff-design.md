# `/handoff` & `/handoff-resume` — Design

**Date:** 2026-04-27
**Project:** handoff (new standalone project at `~/Workspace/handoff/`)
**Status:** Approved by user, ready for implementation planning

## 1. Goal

Build a paired Claude Code slash-command set that lets a user gracefully transition between sessions without re-explaining context:

- **`/handoff [extra info]`** — at the end of a session, generates a markdown file capturing what was done, choices made, references, anti-patterns to carry forward, and what to do next. If next-step direction is ambiguous, the AI **must** brainstorm with the user until clear before writing.
- **`/handoff-resume`** — at the start of a new session, picks the latest handoff file from `.handoff/`, summarizes it, and asks the user to confirm before continuing the work.

The pair forms a closed loop that keeps cross-session context tight and zero-effort for the user.

## 2. Non-Goals (YAGNI)

Explicitly out of scope for this iteration:

- `/handoff-resume <fragment>` fuzzy match — defer until a real "many handoffs, need lookup" pain emerges
- `/handoff-resume --list` — `ls .handoff/` is enough for now
- `/handoff --dry-run` preview mode
- Auto-rotation / cleanup of old handoff files
- Publishing to a marketplace as a plugin
- Multi-handoff merging or branching narratives
- Auto-detecting that the session is too thin to warrant a handoff (instead: AI just asks)

## 3. User-Facing Behaviour

### 3.1 `/handoff [extra info]`

| Invocation | Behaviour |
|---|---|
| `/handoff` | AI auto-infers title and content from the current session, runs the **clarity check** (§3.3), and writes the file once direction is clear. |
| `/handoff catatan tambahan` | Same, but the free-form text is captured in the handoff file's *Notes from User* section. |

The argument is opaque free-form text. There is **no** `--` delimiter, no flags, no quoting rules. The whole argument string after the command is the user's note.

### 3.2 `/handoff-resume`

Takes **no arguments**. Behaviour:

1. Look in `<repo-root>/.handoff/`. If missing or empty, return:
   > "Tidak ada handoff sebelumnya di repo ini."
2. Pick the lexicographically last filename (works because filenames start with `yyyymmddhhmm` — alphabetic sort = chronological sort).
3. Read the file fully into context.
4. Show the user a **brief, decision-oriented summary** plus an explicit confirmation prompt:
   > "Saya menemukan handoff terakhir: **{title}** (dari {date}). Sesi sebelumnya selesai: {one-line summary}. Rencana berikutnya: {one-line summary}. Apakah Anda yakin ingin melanjutkan task handover ini?"
5. Wait for user reply. If user confirms, the AI proceeds with the *Next Session* plan (§5.6). If user redirects, the loaded context is still available — the AI follows the new direction with handoff awareness.

### 3.3 The Clarity Check (`/handoff`)

Before writing any file, the AI MUST decide whether the next-session direction is clear enough that someone reading the handoff cold could act on it. Heuristic:

**Clear (proceed to write) when at least one of:**

- An active spec or plan document exists for the next iteration (e.g., a committed `docs/superpowers/specs/` or `docs/superpowers/plans/` file describing what comes next).
- The user has made an explicit choice in the current session about what comes next ("yes, lanjut ke Opsi B", "saya pilih A", "let's defer X to next session").
- Git state plus an unfinished task list unambiguously points to the next step (e.g., a TodoWrite with one remaining `pending` task that names the work).

**Not clear (must brainstorm before writing) when:**

- The session is exploratory Q&A with no decision recorded.
- Multiple plausible "next steps" exist and the user has not chosen between them.
- The AI is itself uncertain how to interpret the work just done.

When unclear, the AI asks brainstorming-style questions (one at a time, multiple-choice when possible, recommend an option), exactly as the `superpowers:brainstorming` skill does. Once the user's answers resolve the ambiguity, the AI proceeds to write.

The clarity check is enforced inside the `handoff` skill, not via heuristics outside it.

## 4. File Output Contract

### 4.1 Location

`<repo-root>/.handoff/`. Created if missing. The repo root is the nearest ancestor directory containing a `.git/` folder, falling back to `cwd` if not in a git repo (with a warning to the user).

### 4.2 Filename

```
<yyyymmddhhmm>-prompt-<title>.md
```

- Timestamp uses local time of the machine running Claude Code.
- `<title>` is AI-inferred from the session: kebab-case, lowercased, ≤6 words, alphanumerics and hyphens only. Non-conforming characters are dropped.
- If a clash occurs (same minute, same title), append `-2`, `-3`, ... to disambiguate.

### 4.3 Discoverability and Git Integration

- The skill does **not** auto-add `.handoff/` to `.gitignore`. It is the user's call whether handoff history is committed (audit trail) or kept local (private notes).
- The `README.md` of the `handoff` project explains the trade-off.

## 5. Handoff File Template

The file has 8 sections. Sections that have no relevant content are still present, with `—` as their value (so the structure is predictable for `/handoff-resume`).

```markdown
# {Title}

**Date:** YYYY-MM-DD HH:MM ({TZ})
**Repo:** {repo name}
**Branch:** {branch} (HEAD: {short-SHA})
**Generated by:** /handoff [{extra info if any, else blank}]

---

## 1. Konteks Proyek
2-4 sentences about the project so a fresh session understands the
domain without re-reading CLAUDE.md.

## 2. Yang Sudah Selesai di Sesi Ini
- Concrete bullets, action verb + object.
- Reference commit SHAs / file paths / spec/plan docs inline.

## 3. Pilihan & Keputusan User Lewat Brainstorming
| Pertanyaan | Pilihan User | Konsekuensi |
|---|---|---|
| {question} | {answer} | {what it implies for code or next steps} |

## 4. Artefak yang Dihasilkan
- **Spec:** `path/to/spec.md`
- **Plan:** `path/to/plan.md`
- **Commits:** {N} commits ({base-SHA}..{head-SHA})
- **Files baru:** ...
- **Files diubah:** ...
- **Files dihapus:** ...

## 5. Anti-Patterns / Lessons Learned (CARRY FORWARD)
> Aturan-aturan ini berlaku untuk pengembangan selanjutnya juga.

- ❌ JANGAN ... (alasan)
- ✅ LAKUKAN ... (alasan)

## 6. Apa yang Akan Dikerjakan di Sesi Berikutnya
**Goal:** {one-sentence}

- Step / area / decision needing follow-up
- ...

**Starting point untuk sesi baru:**
- Branch: ...
- Existing spec/plan to read first: ...

## 7. Catatan Tambahan dari User
{verbatim from `/handoff <extra info>`, or `—` if none}

## 8. Hal-Hal Penting Lain untuk Sesi Berikutnya
- Environment, tooling, host IP, credentials notes
- Open questions the AI noticed but the user hasn't decided yet
- Anything else surprising or hard to rediscover from code alone
```

The full template lives in `skills/handoff/template.md` for reference.

## 6. Project Layout

```
~/Workspace/handoff/
├── README.md
├── install.sh
├── uninstall.sh
├── commands/
│   ├── handoff.md
│   └── handoff-resume.md
├── skills/
│   ├── handoff/
│   │   ├── SKILL.md
│   │   └── template.md
│   └── handoff-resume/
│       └── SKILL.md
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-04-27-handoff-design.md   (this file)
└── .gitignore
```

`commands/*.md` are the slash-command entry points (frontmatter + short instructions). `skills/*/SKILL.md` are the actual logic the AI follows.

## 7. Install Mechanism

A POSIX `install.sh` script that creates **symlinks** (not copies) from `~/.claude/` into the repo:

```
~/.claude/commands/handoff.md         -> ~/Workspace/handoff/commands/handoff.md
~/.claude/commands/handoff-resume.md  -> ~/Workspace/handoff/commands/handoff-resume.md
~/.claude/skills/handoff              -> ~/Workspace/handoff/skills/handoff
~/.claude/skills/handoff-resume       -> ~/Workspace/handoff/skills/handoff-resume
```

Symlinks mean any edit to the source repo is picked up immediately by the next Claude Code session — no re-install.

`install.sh` is idempotent. If a target already exists and is not a symlink, the script aborts with a message asking the user to remove it first (do not overwrite real files silently).

`uninstall.sh` removes only the symlinks it created.

## 8. Error Handling

| Scenario | Behaviour |
|---|---|
| `/handoff` outside a git repo | Use `cwd/.handoff/`, warn the user once in the message confirming the file was written. |
| `/handoff` and `.handoff/` does not exist | Auto-create the dir. |
| `/handoff-resume` and `.handoff/` does not exist or is empty | Refuse with a clear message; do not silently no-op. |
| Filename collision (same minute + same title) | Append `-2`, `-3`, ... |
| `/handoff` argument provided but session has no substantive content | The clarity check kicks in: AI asks "Sesi ini belum ada konten substantif, yakin mau buat handoff?" |
| User declines confirmation in `/handoff-resume` | The handoff content stays loaded in conversation context; user is free to redirect to anything else. |

## 9. Testing Strategy

Manual smoke tests are sufficient for the first iteration:

1. **Round-trip test.** In any repo: run `/handoff "test"` → verify a file with correct format lands in `.handoff/`. Then run `/handoff-resume` in a fresh session → verify it picks the file, prompts for confirmation, loads context.
2. **Clarity-check test.** In a session with no clear next step, run `/handoff` → verify AI brainstorms before writing.
3. **Argument test.** Run `/handoff catatan ekstra` → verify Section 7 contains the verbatim text.
4. **Edge tests.** Empty `.handoff/`, no `.handoff/` at all, two handoffs in the same minute, run outside a git repo.

No automated test infrastructure for the iteration. If the skill grows, add bats / pytest later.

## 10. Estimated Effort

~½ day:

- Project scaffolding (README, install.sh, uninstall.sh, .gitignore): 30 min
- `/handoff` skill incl. clarity check logic: 1.5 hr
- `/handoff-resume` skill: 30 min
- Template + handoff README: 30 min
- Manual testing across repos: 30 min

## 11. Open Items for the Implementation Plan

The plan (next step) needs to lock in:

- Exact frontmatter for `commands/*.md` (Claude Code's `description`, `argument-hint`, etc.) — model after `~/.claude/commands/daily-report.md` which already works.
- Exact `SKILL.md` shape and where the clarity-check rules live in prose.
- Whether `template.md` is loaded by the skill at runtime or simply documents the expected output for the AI to reproduce. Recommended: documents only — the AI generates from the template description in `SKILL.md`, not from disk.
- A short integration sanity check: how does `/handoff-resume` interact with the `superpowers:using-superpowers` boot sequence? It should not block on or duplicate context-establishing skills.
