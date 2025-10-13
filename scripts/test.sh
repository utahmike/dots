#!/bin/bash
set -e

echo "=== Dotfiles Configuration Tests ==="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}✓${NC} $1"
}

fail() {
    echo -e "${RED}✗${NC} $1"
    exit 1
}

skip() {
    echo -e "${YELLOW}⊗${NC} $1"
}

# Test 1: Shell script syntax
echo "Testing shell scripts..."
if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck config/env.sh 2>/dev/null; then
        pass "env.sh syntax valid"
    else
        fail "env.sh has errors"
    fi
else
    skip "shellcheck not installed, skipping shell tests"
fi

# Test 2: Lua syntax
echo ""
echo "Testing Lua configs..."
if command -v luacheck >/dev/null 2>&1; then
    if luacheck config/nvim/init.lua --globals vim 2>/dev/null; then
        pass "init.lua syntax valid"
    else
        fail "init.lua has errors"
    fi
    if luacheck config/wezterm/wezterm.lua --globals os io 2>/dev/null; then
        pass "wezterm.lua syntax valid"
    else
        fail "wezterm.lua has errors"
    fi
else
    skip "luacheck not installed, skipping Lua tests"
fi

# Test 3: TOML syntax
echo ""
echo "Testing TOML configs..."
if command -v taplo >/dev/null 2>&1; then
    if taplo check config/alacritty/alacritty.toml 2>/dev/null; then
        pass "alacritty.toml valid"
    else
        fail "alacritty.toml has errors"
    fi
else
    skip "taplo not installed, skipping TOML tests"
fi

# Test 4: Git config validity
echo ""
echo "Testing Git config..."
if git config -f home/dot-gitconfig --list >/dev/null 2>&1; then
    pass "gitconfig valid"
else
    fail "gitconfig has errors"
fi

# Test 5: Check for hardcoded paths
echo ""
echo "Checking for hardcoded absolute paths..."
HARDCODED=$(grep -r "/Users/mjc" config/ 2>/dev/null | grep -v ".swp" | grep -v "Binary file" || true)
if [ -z "$HARDCODED" ]; then
    pass "No hardcoded user paths found"
else
    fail "Found hardcoded paths:\n$HARDCODED"
fi

# Test 6: Check for exposed secrets
echo ""
echo "Checking for potential secrets..."
SECRETS=$(grep -rE "(password|secret|key|token).*=.*['\"]?[A-Za-z0-9]{20,}" config/ 2>/dev/null | grep -v ".swp" | grep -v "Binary file" || true)
if [ -z "$SECRETS" ]; then
    pass "No obvious secrets found"
else
    fail "Potential secrets found:\n$SECRETS"
fi

# Test 7: Verify template files exist
echo ""
echo "Checking templates..."
if [ -f "templates/.credentials.sh.template" ]; then
    pass ".credentials.sh.template exists"
else
    skip "Missing .credentials.sh.template"
fi

if [ -f "templates/env.local.sh.template" ]; then
    pass "env.local.sh.template exists"
else
    skip "Missing env.local.sh.template"
fi

# Test 8: Check .gitignore patterns
echo ""
echo "Checking .gitignore..."
if grep -q "backups/" .gitignore; then
    pass ".gitignore includes backups/"
else
    fail ".gitignore missing backups/ entry"
fi

if grep -q ".credentials.sh" .gitignore; then
    pass ".gitignore includes .credentials.sh"
else
    fail ".gitignore missing .credentials.sh entry"
fi

# Test 9: Directory structure
echo ""
echo "Checking directory structure..."
for dir in config home templates scripts plan; do
    if [ -d "$dir" ]; then
        pass "Directory $dir/ exists"
    else
        skip "Directory $dir/ not found"
    fi
done

# Test 10: Required files
echo ""
echo "Checking required files..."
for file in makefile CLAUDE.md .gitignore; do
    if [ -f "$file" ]; then
        pass "File $file exists"
    else
        fail "Required file $file not found"
    fi
done

echo ""
echo "=== All tests passed ==="
