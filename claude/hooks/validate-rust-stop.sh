#!/usr/bin/env bash
# Stop hook: run the Rust gate before Claude is allowed to finish a turn.
input=$(cat)
# Already blocked once this turn: let Claude stop rather than loop forever.
[[ $(jq -r '.stop_hook_active // false' <<<"$input") == true ]] && exit 0

cd "$(jq -r '.cwd // empty' <<<"$input")" 2>/dev/null || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
[[ -f Cargo.toml ]] || exit 0
# Only gate when Rust-relevant files are dirty.
git status --porcelain -- '*.rs' Cargo.toml Cargo.lock | grep -q . || exit 0

out=$("$HOME/.claude/skills/validate-rust/validate.sh" fast 2>&1) && exit 0
tail -n 60 <<<"$out" >&2
echo "Rust validation failed. Fix the causes (don't silence lints or skip tests), then finish." >&2
exit 2
