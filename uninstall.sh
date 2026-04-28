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
