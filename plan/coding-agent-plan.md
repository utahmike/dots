# Coding Agent Simulator Plan - Dotfiles Repository Improvements

## Executive Summary

This plan outlines the implementation strategy for improving security, portability, maintainability, and usability of the dotfiles repository. Based on the critique and recommendations, this represents the exact steps a coding agent would follow to execute the improvements.

---

## Step-by-Step Execution Plan

### Phase 1: Critical Security & Git Cleanup (IMMEDIATE)
**Estimated time: 30 minutes**
**Risk level: LOW - mostly file operations**

#### Step 1.1: Resolve Git File Naming Conflict
```bash
# Remove the deleted reference
git rm claude/CLAUDE.md

# Normalize the root file
git mv CLAUDE.MD CLAUDE.md

# Commit
git commit -m "Standardize Claude instructions location to root"
```

#### Step 1.2: Create Credential Management System
1. Create `templates/.credentials.sh.template` with placeholders
2. Remove exposed SDK key from `config/env.sh:46`
3. Add note to rotate the Optimizely key (UYioHayz4pqa2EXuLyRgP9)
4. Update `.gitignore` to ensure credentials never committed

#### Step 1.3: Update .gitignore
Add entries for:
- `backups/`
- `config/env.local.sh`
- `.credentials.sh`
- OS files (`.DS_Store`)
- Editor files (`*.swp`, `*.swo`, `*~`)
- `config/nvim/lazy-lock.json`

#### Step 1.4: Commit Security Fixes
```bash
git add .gitignore templates/
git add config/env.sh  # with removed SDK key
git commit -m "Security: Remove exposed secrets and add credential management"
```

---

### Phase 2: Portability Improvements (HIGH PRIORITY)
**Estimated time: 1-2 hours**
**Risk level: MEDIUM - modifying active configs**

#### Step 2.1: Fix Hardcoded Paths in WezTerm
**File:** `config/wezterm/wezterm.lua`

Replace lines 16-27:
```lua
local home = os.getenv("HOME")
local config_dir = home .. "/.config/wezterm"
local bg_image = config_dir .. "/background.tif"

local file = io.open(bg_image, "r")
if file ~= nil then
    io.close(file)
    config.window_background_image = bg_image
    config.window_background_image_hsb = {
        brightness = 0.05,
        hue = 1.0,
        saturation = 1.0,
    }
end
```

Test: Verify WezTerm still launches without errors

#### Step 2.2: Create Local Environment Override System
**File:** `templates/env.local.sh.template`

Move company-specific configuration from `config/env.sh:44-77` to template:
- GOPATH settings
- ZEROPW paths
- Company-specific functions
- Custom cdpath entries

#### Step 2.3: Update env.sh for Local Overrides
**File:** `config/env.sh`

Add after line 26:
```bash
# Source local environment overrides
if [ -f ~/.config/env.local.sh ]; then
    source ~/.config/env.local.sh
fi
```

Remove company-specific sections (lines 44-77)

#### Step 2.4: Enhance OS Detection
**File:** `config/env.sh`

Replace existing Darwin/Linux case statement with enhanced version:
- Add Homebrew path detection (both /opt/homebrew and /usr/local)
- Add file existence checks
- Complete Linux configuration section
- Add unknown OS warning

Test: Source env.sh on macOS and verify no errors

---

### Phase 3: Repository Organization & Backup System (HIGH PRIORITY)
**Estimated time: 2 hours**
**Risk level: LOW - new functionality**

#### Step 3.1: Create Directory Structure
```bash
mkdir -p scripts
mkdir -p templates
mkdir -p backups
```

#### Step 3.2: Create Enhanced Makefile
**File:** `makefile`

Replace existing makefile with enhanced version containing:
- `help` - Display available commands
- `check-dependencies` - Verify stow, git installed
- `backup` - Backup existing configs with timestamp
- `install` - Install with automatic backup
- `uninstall` - Remove symlinks
- `restore` - Restore from latest backup
- `test` - Run configuration validation
- `clean` - Remove old backups (keep last 5)

All targets include verbose output and error handling

#### Step 3.3: Create Testing Script
**File:** `scripts/test.sh`

Implement validation checks:
1. Shell script syntax (shellcheck)
2. Lua syntax (luacheck)
3. TOML syntax (taplo)
4. Git config validity
5. Hardcoded path detection
6. Secret scanning
7. Template file verification

Make executable: `chmod +x scripts/test.sh`

#### Step 3.4: Update Git Credential Helper
**File:** `home/dot-gitconfig`

Change line 14:
```gitconfig
[credential]
	helper = osxkeychain
```

---

### Phase 4: Documentation (HIGH PRIORITY)
**Estimated time: 1 hour**
**Risk level: NONE - documentation only**

#### Step 4.1: Create Comprehensive README
**File:** `README.md`

Sections:
1. **Overview** - What this repository manages
2. **Prerequisites** - Required and optional tools
3. **Quick Start** - 5-step installation
4. **Usage** - Available make commands table
5. **Structure** - Directory tree explanation
6. **Customization** - Personal overrides and credentials
7. **Neovim Configuration** - Plugin list and key bindings
8. **Troubleshooting** - Common issues and solutions
9. **Contributing** - Fork/PR guidelines
10. **License** - MIT
11. **Acknowledgments** - kickstart.nvim, GNU Stow

#### Step 4.2: Create License File
**File:** `LICENSE`

Add MIT license with appropriate copyright year

---

### Phase 5: Testing & Validation (MEDIUM PRIORITY)
**Estimated time: 1 hour**
**Risk level: LOW - verification only**

#### Step 5.1: Run Local Tests
```bash
make test
```

Fix any issues discovered:
- Shell syntax errors
- Lua warnings
- Hardcoded paths
- Exposed secrets

#### Step 5.2: Test Installation Flow
On a test machine or clean user account:
```bash
# Fresh clone
git clone <repo> ~/.dotfiles
cd ~/.dotfiles

# Check dependencies
make check-dependencies

# Install
make install

# Verify symlinks
ls -la ~/.config/nvim
ls -la ~/.config/alacritty
ls -la ~/.gitconfig

# Test uninstall
make uninstall

# Test restore
make restore
```

#### Step 5.3: Test Backup/Restore Cycle
```bash
# Create initial backup
make backup

# Install dotfiles
make install

# Restore backup
make restore

# Verify original files restored
```

---

### Phase 6: Optional Enhancements (LOW PRIORITY)
**Estimated time: Variable**
**Risk level: LOW**

#### 6.1: GitHub Actions CI
**File:** `.github/workflows/test.yml`

Workflow to:
- Run shellcheck on all shell files
- Run luacheck on Lua configs
- Verify no hardcoded paths
- Scan for secrets
- Test stow dry-run

#### 6.2: Pre-commit Hooks
**File:** `.pre-commit-config.yaml`

Hooks for:
- Shellcheck
- Luacheck
- Secret scanning
- File naming validation

#### 6.3: Expanded LSP Configuration
**File:** `config/nvim/init.lua`

Add language servers as needed:
- pyright (Python)
- ts_ls (TypeScript)
- gopls (Go)
- rust_analyzer (Rust)

Create per-language config files in `config/nvim/after/ftplugin/`

---

## Proposed File Tree

```
dots/
├── .claude/
│   └── settings.local.json        [EXISTING] Claude Code settings
├── .github/                        [NEW]
│   └── workflows/
│       └── test.yml                [NEW] CI testing workflow
├── config/                         [EXISTING]
│   ├── alacritty/
│   │   └── alacritty.toml          [EXISTING]
│   ├── nvim/
│   │   ├── init.lua                [EXISTING - minor updates]
│   │   └── after/                  [NEW]
│   │       └── ftplugin/           [NEW] Language-specific configs
│   ├── wezterm/
│   │   ├── wezterm.lua             [MODIFIED] Remove hardcoded paths
│   │   └── background.tif          [OPTIONAL] Custom background
│   └── env.sh                      [MODIFIED] Remove secrets, add overrides
├── home/                           [EXISTING]
│   └── dot-gitconfig               [MODIFIED] Update credential helper
├── plan/                           [EXISTING]
│   ├── critique.md                 [EXISTING]
│   ├── recommendations.md          [EXISTING]
│   └── coding-agent-plan.md        [THIS FILE]
├── scripts/                        [NEW]
│   ├── backup.sh                   [NEW] Backup script
│   ├── restore.sh                  [NEW] Restore script
│   └── test.sh                     [NEW] Validation script
├── templates/                      [NEW]
│   ├── .credentials.sh.template    [NEW] Secret management
│   └── env.local.sh.template       [NEW] Local overrides
├── backups/                        [NEW] Auto-generated backups (gitignored)
├── .gitignore                      [MODIFIED] Add new entries
├── .pre-commit-config.yaml         [NEW - OPTIONAL]
├── CLAUDE.md                       [EXISTING - renamed/moved]
├── LICENSE                         [NEW]
├── makefile                        [MODIFIED] Enhanced with backup/test
└── README.md                       [NEW]
```

**Legend:**
- `[EXISTING]` - Already in repository
- `[MODIFIED]` - Requires changes
- `[NEW]` - To be created
- `[OPTIONAL]` - Nice to have but not required

---

## Test Plan

### Unit Tests (Automated)

#### Test 1: Shell Script Syntax
**Tool:** shellcheck
**Target:** `config/env.sh`
**Verifies:** No syntax errors, proper quoting, valid shell constructs
**Pass criteria:** Exit code 0

#### Test 2: Lua Configuration Syntax
**Tool:** luacheck
**Target:** `config/nvim/init.lua`
**Verifies:** Valid Lua syntax, no undefined variables (except vim globals)
**Pass criteria:** Exit code 0

#### Test 3: TOML Configuration Syntax
**Tool:** taplo
**Target:** `config/alacritty/alacritty.toml`
**Verifies:** Valid TOML structure
**Pass criteria:** Exit code 0

#### Test 4: Git Config Validity
**Tool:** git config
**Target:** `home/dot-gitconfig`
**Verifies:** Valid git configuration format
**Command:** `git config -f home/dot-gitconfig --list`
**Pass criteria:** Exit code 0

#### Test 5: Hardcoded Path Detection
**Tool:** grep
**Pattern:** `/Users/mjc`
**Verifies:** No hardcoded user paths in configs
**Pass criteria:** No matches found

#### Test 6: Secret Detection
**Tool:** grep with regex
**Pattern:** `(password|secret|key|token).*=.*['\"]?[A-Za-z0-9]{20,}`
**Verifies:** No obvious secrets in tracked files
**Pass criteria:** No matches found

#### Test 7: Template Existence
**Tool:** file existence check
**Verifies:** All required template files exist
**Targets:**
- `templates/.credentials.sh.template`
- `templates/env.local.sh.template`
**Pass criteria:** All files exist

### Integration Tests (Manual)

#### Test 8: Fresh Installation
**Scenario:** New user on clean machine
**Steps:**
1. Clone repository
2. Run `make check-dependencies`
3. Copy templates to active files
4. Run `make install`
5. Verify symlinks created
6. Source env.sh
7. Launch Neovim, check no errors
8. Launch WezTerm, check no errors
9. Test git commands

**Verifies:** Complete installation flow works
**Pass criteria:** All applications launch without errors

#### Test 9: Backup and Restore
**Scenario:** Protecting existing configurations
**Steps:**
1. Create dummy configs in ~/.config
2. Run `make backup`
3. Verify backup directory created with timestamp
4. Run `make install` (overwrites with stow)
5. Run `make restore`
6. Verify original dummy configs restored

**Verifies:** Backup/restore mechanism works
**Pass criteria:** Original files successfully restored

#### Test 10: Uninstall
**Scenario:** Removing dotfiles
**Steps:**
1. Run `make install`
2. Verify symlinks exist
3. Run `make uninstall`
4. Verify symlinks removed
5. Verify original files (if any) still present

**Verifies:** Clean uninstallation
**Pass criteria:** All symlinks removed, no data loss

#### Test 11: Cross-Platform (if applicable)
**Scenario:** Linux compatibility
**Steps:**
1. Clone on Linux machine
2. Run `make install`
3. Source env.sh
4. Verify Linux-specific paths loaded
5. Verify no macOS-specific errors

**Verifies:** OS detection and branching works
**Pass criteria:** Appropriate configs loaded per platform

#### Test 12: Local Overrides
**Scenario:** Machine-specific customization
**Steps:**
1. Create `~/.config/env.local.sh` with custom exports
2. Source env.sh
3. Verify custom exports available
4. Verify base config still works

**Verifies:** Override system works
**Pass criteria:** Both base and override configs active

### Security Tests (Manual)

#### Test 13: Secret Exposure
**Scenario:** Ensure no secrets in git
**Steps:**
1. Run `git log -p | grep -i "key\|token\|password\|secret"`
2. Check git history for exposed secrets
3. Verify `.gitignore` prevents credential files

**Verifies:** No secrets in version control
**Pass criteria:** No secrets found in current or historical commits

#### Test 14: Credential Management
**Scenario:** Proper secret handling
**Steps:**
1. Copy `.credentials.sh.template` to `~/.credentials.sh`
2. Add test secret
3. Source env.sh
4. Verify secret available in environment
5. Verify file not tracked by git

**Verifies:** Credential system works
**Pass criteria:** Secrets loaded but not committed

---

## Risks & Open Questions

### High-Risk Areas

#### Risk 1: Data Loss During Stow
**Severity:** HIGH
**Scenario:** User has existing configs that get overwritten without backup
**Mitigation:**
- Automatic backup before install in makefile
- Verbose output showing what will be overwritten
- Dry-run option for preview
**Open Question:** Should we require explicit confirmation before first install?

#### Risk 2: Exposed Secrets Already in Git History
**Severity:** HIGH
**Scenario:** SDK key already committed (config/env.sh:46)
**Mitigation:**
- Remove from current version
- Document key rotation in recommendations
- Add warning in README about git history
**Open Question:** Should we attempt git history rewrite? (Not recommended for shared repos)

#### Risk 3: Hardcoded Paths Breaking Installation
**Severity:** MEDIUM
**Scenario:** WezTerm background image path doesn't exist
**Mitigation:**
- File existence check before setting background
- Graceful fallback if missing
- Clear documentation
**Open Question:** Should we include a default background in the repo?

### Medium-Risk Areas

#### Risk 4: Stow Conflicts on Existing Systems
**Severity:** MEDIUM
**Scenario:** User already has ~/.config/nvim that's not a symlink
**Mitigation:**
- Backup existing configs first
- Use `stow --adopt` with caution
- Document conflict resolution
**Open Question:** Should makefile auto-adopt or require manual intervention?

#### Risk 5: OS-Specific Config Failures
**Severity:** MEDIUM
**Scenario:** Linux paths don't exist, causing errors
**Mitigation:**
- Add existence checks before sourcing
- Graceful error handling
- Platform-specific documentation
**Open Question:** Should we support Windows via WSL?

#### Risk 6: Shell Compatibility
**Severity:** MEDIUM
**Scenario:** env.sh assumes bash/zsh, might break on fish/csh
**Mitigation:**
- Document supported shells
- Add shell detection
- Provide fish-specific config if needed
**Open Question:** Do we need fish shell support?

### Low-Risk Areas

#### Risk 7: Makefile Targets Fail Silently
**Severity:** LOW
**Scenario:** Backup fails but install continues
**Mitigation:**
- Use `set -e` equivalent in make
- Check return codes
- Verbose error messages
**Resolution:** Add proper error handling to all make targets

#### Risk 8: Plugin Installation Delays
**Severity:** LOW
**Scenario:** First Neovim launch takes 5+ minutes to install plugins
**Mitigation:**
- Document in README
- Consider pre-installing plugins in make target
**Open Question:** Should we add `make nvim-setup` target?

#### Risk 9: Nerd Font Not Installed
**Severity:** LOW
**Scenario:** Icons don't display in Neovim
**Mitigation:**
- Document in prerequisites
- Add to dependency check
- Provide fallback config
**Resolution:** Add font installation to README

---

## Estimated Unknowns That Could Cause Rework

### Category A: Technical Unknowns

1. **Stow Behavior with Existing Files**
   - Unknown: How stow handles existing non-symlink files
   - Impact: May require manual conflict resolution
   - Discovery: Test Phase 5.1
   - Potential rework: Alternative to stow (homeshick, yadm)

2. **Shell Sourcing Order**
   - Unknown: Whether .credentials.sh is sourced before/after other configs
   - Impact: Environment variables might not be available
   - Discovery: Test Phase 5.2
   - Potential rework: Reorder sourcing in env.sh

3. **Neovim Plugin Compatibility**
   - Unknown: Whether all plugins work with Neovim 0.10+
   - Impact: Broken features or error messages
   - Discovery: Test Phase 5.2
   - Potential rework: Pin plugin versions, update configs

4. **WezTerm Lua API Changes**
   - Unknown: Whether background image API is stable
   - Impact: Configuration might not apply
   - Discovery: Test Phase 5.2
   - Potential rework: Use alternative background method

### Category B: User Environment Unknowns

5. **Existing Config Complexity**
   - Unknown: User might have complex existing configs with dependencies
   - Impact: Backup/restore might not capture everything
   - Discovery: User testing
   - Potential rework: More sophisticated backup script

6. **Corporate Environments**
   - Unknown: Corporate proxies, firewalls, or restrictions
   - Impact: Git clone, Homebrew, plugin installation might fail
   - Discovery: User reports
   - Potential rework: Offline installation mode

7. **Non-Standard Shell Configurations**
   - Unknown: User might have custom .zshrc that conflicts
   - Impact: env.sh might not load or cause errors
   - Discovery: User testing
   - Potential rework: More defensive sourcing logic

### Category C: Workflow Unknowns

8. **Git Workflow Preferences**
   - Unknown: User might want different branching strategy
   - Impact: Recommendations assume main/master workflow
   - Discovery: User feedback
   - Potential rework: Document alternative workflows

9. **Update Strategy**
   - Unknown: How users will pull updates without losing local changes
   - Impact: Git conflicts on updates
   - Discovery: First update cycle
   - Potential rework: Stow might handle this naturally via symlinks

10. **Multi-Machine Sync**
    - Unknown: Whether users will use same repo on multiple machines
    - Impact: Machine-specific configs might conflict
    - Discovery: User feedback
    - Potential rework: More sophisticated local override system

### Category D: Security Unknowns

11. **Historical Secret Exposure**
    - Unknown: Whether SDK key was used in production
    - Impact: Potential security breach
    - Discovery: Check with Optimizely account
    - Potential rework: Complete key rotation, audit access logs

12. **Credential File Permissions**
    - Unknown: Whether ~/.credentials.sh has secure permissions
    - Impact: Other users might read secrets
    - Discovery: Security audit
    - Potential rework: Auto-set chmod 600 in makefile

---

## Success Criteria

### Must Have (Phase 1-3)
- ✅ No secrets in version control
- ✅ No hardcoded user-specific paths
- ✅ Automatic backup before installation
- ✅ Working uninstall/restore mechanism
- ✅ Comprehensive README with quick start
- ✅ All configs portable across machines
- ✅ Tests pass on clean installation

### Should Have (Phase 4)
- ✅ Credential management system documented
- ✅ Local override system working
- ✅ OS detection with graceful fallbacks
- ✅ Troubleshooting documentation
- ✅ License file

### Nice to Have (Phase 5-6)
- ✅ CI/CD pipeline testing
- ✅ Pre-commit hooks
- ✅ Expanded LSP configs
- ✅ Cross-platform testing
- ✅ Update notification system

---

## Dependencies & Prerequisites

### Required for Development
- **git** - Version control
- **GNU stow** - Symlink management
- **bash/zsh** - Shell environment
- **make** - Build automation

### Required for Usage
- **Neovim >= 0.10** - Text editor
- **git** - Version control
- **Nerd Font** - Icon display (recommended: Hack Nerd Font)

### Optional for Development
- **shellcheck** - Shell script linting
- **luacheck** - Lua linting
- **taplo** - TOML linting
- **ripgrep** - Fast searching
- **tree** - Directory visualization

### Optional for Usage
- **Alacritty** - Terminal emulator
- **WezTerm** - Alternative terminal
- **Homebrew** (macOS) - Package management
- **apt** (Linux) - Package management

---

## Timeline Estimate

| Phase | Description | Time | Dependencies |
|-------|-------------|------|--------------|
| 1 | Security & Git cleanup | 30 min | None |
| 2 | Portability fixes | 1-2 hours | Phase 1 complete |
| 3 | Backup system & makefile | 2 hours | Phase 1 complete |
| 4 | Documentation | 1 hour | Phases 1-3 complete |
| 5 | Testing & validation | 1 hour | Phases 1-4 complete |
| 6 | Optional enhancements | Variable | Phase 5 complete |

**Total estimated time (required phases): 5-6 hours**
**Total with optional enhancements: 8-12 hours**

---

## Post-Implementation Checklist

### Verification Steps
- [ ] All secrets removed from tracked files
- [ ] Git history checked for exposed secrets
- [ ] All hardcoded paths replaced with variables
- [ ] Template files created and documented
- [ ] .gitignore updated
- [ ] Makefile tested (all targets)
- [ ] Fresh installation successful on test machine
- [ ] Backup/restore cycle successful
- [ ] README complete and accurate
- [ ] All tests passing
- [ ] No errors in Neovim on first launch
- [ ] WezTerm launches without errors
- [ ] Shell environment loads without errors

### Documentation Verification
- [ ] README has installation instructions
- [ ] Prerequisites clearly listed
- [ ] Troubleshooting section complete
- [ ] License file added
- [ ] Templates documented
- [ ] Credential setup documented

### Security Verification
- [ ] No secrets in current commit
- [ ] No secrets in git history (or documented)
- [ ] .gitignore prevents future secret commits
- [ ] Credential files have secure permissions
- [ ] SDK key rotation documented/completed

---

## Handoff Notes

### For Coding Agent
When implementing this plan:

1. **Start with Phase 1** - Security is critical
2. **Test after each phase** - Don't accumulate issues
3. **Preserve existing functionality** - User's configs work now
4. **Use verbose git commits** - Document why each change was made
5. **Create backups before testing** - Safety first

### For User
After implementation:

1. **Rotate exposed Optimizely key** - Contact Optimizely support
2. **Review git history** - Consider if history rewrite needed
3. **Test on secondary machine** - Verify portability
4. **Set up local overrides** - Customize for your workflow
5. **Star dependent projects** - Credit kickstart.nvim, stow

### Known Limitations
- Only tested on macOS (Darwin 25.0.0)
- Assumes bash/zsh shell
- Neovim-centric (other editors not configured)
- No Windows support (WSL untested)
- English-only documentation

---

## Conclusion

This plan provides a comprehensive roadmap for improving the dotfiles repository with:
- **Clear execution steps** broken into logical phases
- **Complete file tree** showing what changes
- **Comprehensive test plan** with 14 specific tests
- **Risk assessment** with mitigation strategies
- **Unknown factors** that could require rework
- **Success criteria** for each phase

The plan prioritizes security and portability while maintaining backward compatibility with existing functionality. Total implementation time is estimated at 5-6 hours for critical phases, with optional enhancements requiring additional time.

**Recommendation:** Execute phases 1-4 immediately, phase 5 before considering complete, and phase 6 as time allows.
