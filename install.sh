#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  oh-my-stalab-harness installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check dependencies
echo "[1/5] Checking dependencies..."
command -v node >/dev/null 2>&1 || { echo "ERROR: Node.js required. Install from https://nodejs.org"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: Git required."; exit 1; }
echo "  node: $(node --version)"
echo "  git: $(git --version | cut -d' ' -f3)"

# 2. Detect OS
IS_WINDOWS=false
if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]] || [[ -n "${WSLENV:-}" ]]; then
  IS_WINDOWS=true
  echo "  OS: Windows (will copy instead of symlink)"
else
  echo "  OS: $(uname -s)"
fi

# 3. Backup existing ~/.claude
echo ""
echo "[2/5] Checking existing ~/.claude/..."
DIRS_TO_LINK=(agents commands hooks skills rules cc-chips-custom)
EXISTING=()
for dir in "${DIRS_TO_LINK[@]}"; do
  if [ -e "$CLAUDE_DIR/$dir" ]; then
    EXISTING+=("$dir")
  fi
done

if [ ${#EXISTING[@]} -gt 0 ]; then
  echo "  Found existing directories: ${EXISTING[*]}"
  BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
  read -p "  Back up to $BACKUP_DIR? (Y/n) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    mkdir -p "$BACKUP_DIR"
    for dir in "${EXISTING[@]}"; do
      mv "$CLAUDE_DIR/$dir" "$BACKUP_DIR/$dir"
    done
    echo "  Backed up to $BACKUP_DIR"
  fi
fi

# 4. Link or copy
echo ""
echo "[3/5] Installing harness..."
mkdir -p "$CLAUDE_DIR"

for dir in "${DIRS_TO_LINK[@]}"; do
  if [ -d "$REPO_DIR/$dir" ]; then
    if [ "$IS_WINDOWS" = true ]; then
      cp -r "$REPO_DIR/$dir" "$CLAUDE_DIR/$dir"
      echo "  Copied $dir/"
    else
      ln -sfn "$REPO_DIR/$dir" "$CLAUDE_DIR/$dir"
      echo "  Linked $dir/ -> $REPO_DIR/$dir"
    fi
  fi
done

# 5. Merge settings and MCP
echo ""
echo "[4/5] Setting up configs..."

if [ -f "$REPO_DIR/settings.json" ]; then
  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$REPO_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  Created settings.json"
  else
    echo "  settings.json exists — merge manually if needed"
  fi
fi

if [ -f "$REPO_DIR/.mcp.json" ]; then
  if [ ! -f "$CLAUDE_DIR/.mcp.json" ]; then
    cp "$REPO_DIR/.mcp.json" "$CLAUDE_DIR/.mcp.json"
    echo "  Created .mcp.json"
  else
    echo "  .mcp.json exists — merge manually if needed"
  fi
fi

# 6. Done
echo ""
echo "[5/5] Verifying installation..."
COUNT=0
for dir in "${DIRS_TO_LINK[@]}"; do
  if [ -e "$CLAUDE_DIR/$dir" ]; then
    COUNT=$((COUNT + 1))
  fi
done
echo "  $COUNT/${#DIRS_TO_LINK[@]} directories installed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo ""
echo "  Installed to: $CLAUDE_DIR"
echo "  Components:"
echo "    10 agents, 14 commands, 12 hooks"
echo "    13 skills, 6 rules, cc-chips-custom"
echo ""
if [ "$IS_WINDOWS" = false ]; then
  echo "  Update: git pull (symlinks auto-reflect changes)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
