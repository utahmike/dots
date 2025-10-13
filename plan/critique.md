# Project Critique: Dotfiles Repository

## Executive Summary

This dotfiles repository manages personal configuration files for a development environment (Neovim, Alacritty, WezTerm, Git) using GNU Stow. The repository demonstrates good organization but has several areas requiring attention to ensure maintainability, security, and portability.

## Ranked Risks

### 1. CRITICAL: Hardcoded Sensitive Information (Security Risk)
**Severity: HIGH**

**Location:** `config/env.sh:46`
```bash
export OPTIMIZELY_SDK_KEY_DEVEL=UYioHayz4pqa2EXuLyRgP9
```

**Impact:**
- SDK key exposed in version control
- Potential unauthorized access to Optimizely account
- Violates security best practices

**Recommendation:**
- Move to `~/.credentials.sh` (which is already sourced at line 24-26)
- Add `.credentials.sh` documentation for setup
- Consider rotating the exposed key

### 2. CRITICAL: Hardcoded Absolute Paths (Portability Risk)
**Severity: HIGH**

**Locations:**
- `config/wezterm/wezterm.lua:16` - `/Users/mjc/Desktop/untitled-1.tif`
- `config/env.sh:46-69` - Multiple company-specific paths (Beyond Identity/zeropw)

**Impact:**
- Configuration won't work on other machines
- Won't work for other users
- Breaks the portability goal of dotfiles

**Recommendation:**
- Use `$HOME` environment variable
- Use relative paths where possible
- Parameterize company-specific configurations

### 3. HIGH: Incomplete Documentation
**Severity: MEDIUM-HIGH**

**Current State:**
- No README explaining project structure
- No installation instructions
- No dependency requirements listed
- CLAUDE.MD exists but plan directory is empty

**Impact:**
- Difficult for others (or future self) to set up
- No context for configuration choices
- Cannot easily recover from system failure

**Recommendation:**
- Create comprehensive README.md
- Document all dependencies
- Add troubleshooting section

### 4. HIGH: Missing Backup/Restore Strategy
**Severity: MEDIUM-HIGH**

**Current State:**
- No backup mechanism for existing configs before stow
- Destructive `make install` with no rollback

**Impact:**
- Risk of losing existing configurations
- No easy way to revert changes
- Could break working setup

**Recommendation:**
- Add backup step to makefile
- Create restore target
- Document manual rollback procedure

### 5. MEDIUM: Git Workflow Issues
**Severity: MEDIUM**

**Observations:**
- Deleted file in working tree: `claude/CLAUDE.md`
- Untracked file: `CLAUDE.MD` (case difference)
- Inconsistent file naming (case sensitivity)

**Impact:**
- Confusion about which file is canonical
- Potential sync issues across case-insensitive filesystems

**Recommendation:**
- Clean up file naming immediately
- Decide on canonical location for Claude instructions
- Add pre-commit hooks for file naming conventions

### 6. MEDIUM: Secret Management Pattern Incomplete
**Severity: MEDIUM**

**Current State:**
- `env.sh:24-26` sources `~/.credentials.sh`
- Pattern exists but not fully utilized
- Some secrets still in tracked files

**Impact:**
- Mixed security posture
- Easy to accidentally commit secrets

**Recommendation:**
- Document credential file template
- Provide example `.credentials.sh.template`
- Move ALL sensitive data to credentials file

### 7. MEDIUM: macOS-Specific Configuration Without Guards
**Severity: MEDIUM**

**Location:** `config/env.sh:8-20`

**Current State:**
- Has case statement for Darwin
- Linux section commented out
- Assumes Homebrew installation path

**Impact:**
- Partial portability
- Fails silently on Linux if paths don't exist

**Recommendation:**
- Add existence checks before sourcing
- Complete Linux configuration
- Add fallback behaviors

### 8. LOW: LSP Configuration Minimal
**Severity: LOW**

**Location:** `config/nvim/init.lua:811-839`

**Current State:**
- Only lua_ls configured
- Many language servers commented out
- No project-specific LSP configs

**Impact:**
- Limited development language support
- Requires manual addition for each language

**Recommendation:**
- Document which languages are intended
- Add project detection logic
- Create language-specific config files

### 9. LOW: Stow Conflicts Not Handled
**Severity: LOW**

**Current State:**
- Makefile has no conflict detection
- No pre-flight checks
- Silent failures possible

**Impact:**
- Confusing failures during installation
- May silently skip files

**Recommendation:**
- Add `--verbose` flag option
- Check for conflicts before installing
- Provide clear error messages

### 10. LOW: No Automated Testing
**Severity: LOW**

**Current State:**
- No CI/CD
- No validation of configs
- Manual testing only

**Impact:**
- Broken configs can be committed
- No guarantee configs work on fresh install

**Recommendation:**
- Add syntax checking (shellcheck, luacheck)
- Consider GitHub Actions for validation
- Create test target in makefile

## Summary Priority Matrix

| Risk | Severity | Effort | Priority |
|------|----------|--------|----------|
| Exposed SDK Key | Critical | Low | **IMMEDIATE** |
| Hardcoded Paths | Critical | Medium | **IMMEDIATE** |
| File Naming Conflict | High | Low | **HIGH** |
| Missing Documentation | High | Medium | **HIGH** |
| No Backup Strategy | High | Medium | **MEDIUM** |
| Incomplete Secret Management | Medium | Low | **MEDIUM** |
| macOS Guards | Medium | Low | **MEDIUM** |
| Minimal LSP Config | Low | High | **LOW** |
| Stow Conflict Handling | Low | Medium | **LOW** |
| No Testing | Low | High | **LOW** |

## Next Steps

1. **IMMEDIATE ACTION REQUIRED:**
   - Remove SDK key from env.sh
   - Rotate the exposed key if possible
   - Fix file naming issue (CLAUDE.MD vs claude/CLAUDE.md)

2. **High Priority (This Week):**
   - Replace hardcoded paths with variables
   - Create comprehensive README.md
   - Implement backup mechanism

3. **Medium Priority (This Month):**
   - Complete credential management pattern
   - Add OS detection guards
   - Document all dependencies

4. **Low Priority (Future):**
   - Expand LSP configurations
   - Add automated testing
   - Improve error handling
