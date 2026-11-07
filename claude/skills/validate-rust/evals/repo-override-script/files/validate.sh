#!/usr/bin/env bash
# Project gate: cargo checks + every pub fn must be documented in docs/API.md.
set -uo pipefail
cd "$(dirname "$0")"
fail=0
cargo fmt --check || fail=1
cargo clippy --all-targets --locked -- -D warnings || fail=1
cargo test --locked || fail=1
for f in $(grep -oP 'pub fn \K\w+' src/lib.rs); do
    grep -q "\`$f(" docs/API.md || { echo "docs/API.md: missing entry for $f"; fail=1; }
done
((fail)) && { echo "PROJECT GATE FAILED"; exit 1; }
echo "PROJECT GATE PASSED"
