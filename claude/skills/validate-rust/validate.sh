#!/usr/bin/env bash
# validate [fast|full] — run from anywhere inside a Rust repo
set -uo pipefail
TIER="${1:-fast}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

failures=()
step() {
    local n="$1"
    shift
    printf '>>> %s\n' "$n"
    if out=$("$@" 2>&1); then
        echo "    ok"
    else
        printf '    FAIL\n%s\n' "$(tail -n 40 <<<"$out")"
        failures+=("$n")
    fi
}

# per-repo override: if the repo ships its own, defer to it entirely
if [[ -x ./validate.sh ]]; then exec ./validate.sh "$TIER"; fi

if [[ ! -f Cargo.toml ]]; then
    echo "validate: no Cargo.toml at $ROOT"
    exit 2
fi

export CARGO_TERM_COLOR=never RUSTFLAGS="-D warnings"

# cargo errors on --lib / --bins when no selected package has that target kind,
# so only pass the selectors that exist (binary-only crates are common).
unit=()
has_integration=1
if meta=$(cargo metadata --no-deps --format-version 1 --locked 2>/dev/null); then
    grep -qE '"kind":\[[^]]*"(lib|rlib|dylib|cdylib|staticlib|proc-macro)"' <<<"$meta" && unit+=(--lib)
    grep -qE '"kind":\[[^]]*"bin"' <<<"$meta" && unit+=(--bins)
    grep -qE '"kind":\["test"\]' <<<"$meta" || has_integration=0
else
    unit=(--lib --bins) # let the test step surface the real error
fi

step fmt cargo fmt --all -- --check --color never
step build cargo build --workspace --all-targets --locked
step clippy cargo clippy --workspace --all-targets --locked -- -D warnings
if ((${#unit[@]})); then
    step test cargo test --workspace "${unit[@]}" --locked
else
    echo ">>> test"
    echo "    skipped (no lib or bin targets)"
fi
if [[ $TIER == full ]]; then
    if ((has_integration)); then
        # --test '*' = tests/ targets only; --tests would rerun the unit tests
        step integration cargo test --workspace --test '*' --locked
    else
        echo ">>> integration"
        echo "    skipped (no tests/ targets)"
    fi
fi

# per-repo extra steps (hardware, swtpm, etc.) without replacing the whole thing
[[ $TIER == full && -x ./.validate-extra.sh ]] && step extra ./.validate-extra.sh

echo "=================================================="
((${#failures[@]})) && {
    echo "VALIDATION FAILED: ${failures[*]}"
    exit 1
}
echo "VALIDATION PASSED ($TIER)"
