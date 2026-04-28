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
