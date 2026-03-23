#!/usr/bin/env bash
set -euo pipefail

# oh-my-stalab-harness installer
# File-level merge — never overwrites user's custom files

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  oh-my-stalab-harness installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Check dependencies
echo "[1/4] Checking dependencies..."
command -v node >/dev/null 2>&1 || { echo "ERROR: Node.js required."; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: Git required."; exit 1; }
echo "  node: $(node --version)"
echo "  git: $(git --version | cut -d' ' -f3)"

IS_WINDOWS=false
if [[ "$(uname -s)" == MINGW* ]] || [[ "$(uname -s)" == MSYS* ]]; then
  IS_WINDOWS=true
  echo "  OS: Windows (file-level copy)"
else
  echo "  OS: $(uname -s)"
fi

# 2. Create directories
echo ""
echo "[2/4] Preparing directories..."
DIRS_TO_INSTALL=(agents commands hooks skills rules cc-chips-custom)
for dir in "${DIRS_TO_INSTALL[@]}"; do
  mkdir -p "$CLAUDE_DIR/$dir"
done

# 3. File-level merge
echo ""
echo "[3/4] Installing files (file-level merge)..."

INSTALLED=0
SKIPPED=0
CONFLICTS=()

install_file() {
  local src="$1" dst="$2"

  if [ ! -e "$dst" ]; then
    # New file — safe to install
    mkdir -p "$(dirname "$dst")"
    if [ "$IS_WINDOWS" = true ]; then
      cp "$src" "$dst"
    else
      ln -sf "$src" "$dst"
    fi
    INSTALLED=$((INSTALLED + 1))
    return
  fi

  # File exists — check if identical (compare by hash)
  local src_hash dst_hash
  src_hash=$(sha256sum "$src" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$src" | cut -d' ' -f1)
  dst_hash=$(sha256sum "$dst" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$dst" | cut -d' ' -f1)

  if [ "$src_hash" = "$dst_hash" ]; then
    # Identical — skip
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  # Conflict: different content — backup existing, then install
  local rel_path="${dst#$CLAUDE_DIR/}"
  CONFLICTS+=("$rel_path")

  cp "$dst" "$dst.backup-$(date +%Y%m%d-%H%M%S)"
  if [ "$IS_WINDOWS" = true ]; then
    cp "$src" "$dst"
  else
    ln -sf "$src" "$dst"
  fi
  INSTALLED=$((INSTALLED + 1))
}

for dir in "${DIRS_TO_INSTALL[@]}"; do
  src_dir="$REPO_DIR/$dir"
  [ ! -d "$src_dir" ] && continue

  while IFS= read -r -d '' src_file; do
    rel="${src_file#$src_dir/}"
    dst_file="$CLAUDE_DIR/$dir/$rel"
    install_file "$src_file" "$dst_file"
  done < <(find "$src_dir" -type f -print0)
done

echo "  Installed: $INSTALLED files"
echo "  Skipped (identical): $SKIPPED files"

if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo ""
  echo "  CONFLICTS (originals backed up with .backup-* suffix):"
  for c in "${CONFLICTS[@]}"; do
    echo "    ~/.claude/$c"
  done
fi

# 4. Config files — never overwrite
echo ""
echo "[4/4] Setting up configs..."
for cfg in settings.json .mcp.json; do
  if [ -f "$REPO_DIR/$cfg" ] && [ ! -f "$CLAUDE_DIR/$cfg" ]; then
    cp "$REPO_DIR/$cfg" "$CLAUDE_DIR/$cfg"
    echo "  Created $cfg"
  elif [ -f "$CLAUDE_DIR/$cfg" ]; then
    echo "  $cfg exists — merge manually if needed"
  fi
done

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo ""
echo "  Installed: $INSTALLED | Skipped: $SKIPPED | Conflicts: ${#CONFLICTS[@]}"
if [ ${#CONFLICTS[@]} -gt 0 ]; then
  echo "  Review .backup-* files for conflicts"
fi
if [ "$IS_WINDOWS" = false ]; then
  echo "  Update: git pull (symlinks auto-reflect)"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
