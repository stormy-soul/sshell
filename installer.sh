#!/usr/bin/env bash
set -euo pipefail

# ─── Directories ───
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$PROJECT_ROOT/configs"
SHELL_SRC="$PROJECT_ROOT"

SHELL_DST="$HOME/.config/quickshell/sshell"
CONFIG_DST="$HOME/.config"
BACKUP_ROOT="$HOME/.local/state/sshell/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"

# ─── Packages ───
# Pacman packages
PACMAN_PKGS=(
  hyprland
  qt6-base
  qt6-declarative
  qt6-wayland
  qt6-5compat
  qt6-multimedia
  qt6-shadertools
  qt6-svg
  qt6-quicktimeline
  networkmanager
  bluez
  bluez-utils
  cliphist
  imagemagick
  matugen
  playerctl
  brightnessctl
  jq
  starship
  fish
  ttf-material-symbols-variable-git
  ttf-twemoji
)

# AUR packages
AUR_PKGS=(
  quickshell
)

# Fonts
FONT_PKGS=(
  ttf-cascadia-code-nerd
  inter-font
  ttf-jetbrains-mono
)

# Config directories to back up and copy
CONFIG_DIRS=(
  fish
  gtk-3.0
  gtk-4.0
  hypr
  matugen
)

CONFIG_FILES=(
  starship.toml
)

# Files/dirs to exclude from shell copy
SHELL_EXCLUDES=(
  --exclude='.git'
  --exclude='.gitmodules'
  --exclude='configs'
  --exclude='installer.sh'
  --exclude='README.md'
  --exclude='LICENSE'
)

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ─── Utilities ───
die()  { echo -e "${RED}${BOLD}✗${NC} $1"; exit 1; }
info() { echo -e "${BLUE}${BOLD}→${NC} $1"; }
ok()   { echo -e "${GREEN}${BOLD}✓${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}!${NC} $1"; }
dim()  { echo -e "${DIM}  $1${NC}"; }

confirm() {
  read -rp "$(echo -e "${MAGENTA}${BOLD}?${NC} $1 ${DIM}[y/N]${NC} ")" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

banner() {
  echo -e "${CYAN}"
  cat <<'EOF'
               █             ▀▀█    ▀▀█   
  ▄▄▄    ▄▄▄   █ ▄▄    ▄▄▄     █      █   
 █   ▀  █   ▀  █▀  █  █▀  █    █      █   
  ▀▀▀▄   ▀▀▀▄  █   █  █▀▀▀▀    █      █   
 ▀▄▄▄▀  ▀▄▄▄▀  █   █  ▀█▄▄▀    ▀▄▄    ▀▄▄ 
EOF
  echo -e "${NC}${DIM} stormy's shell installer             v1.0${NC}"
  echo ""
}

# ─── Dependencies ───
detect_aur_helper() {
  for helper in paru yay pikaur; do
    if command -v "$helper" &>/dev/null; then
      echo "$helper"
      return
    fi
  done
  echo ""
}

check_prereqs() {
  info "Checking prerequisites..."

  if ! command -v pacman &>/dev/null; then
    die "This installer was made for Arch Linux (pacman not found)"
  fi

  if ! command -v rsync &>/dev/null; then
    warn "rsync not found, installing..."
    sudo pacman -S --noconfirm rsync
  fi

  AUR_HELPER=$(detect_aur_helper)
  if [[ -z "$AUR_HELPER" ]]; then
    warn "No AUR helper found (paru/yay). AUR packages will need manual installation."
  else
    ok "Found AUR helper: $AUR_HELPER"
  fi
}

# ─── Packages ───
install_packages() {
  info "Installing packages..."

  # Filter to only missing packages
  local missing_pacman=()
  for pkg in "${PACMAN_PKGS[@]}" "${FONT_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
      missing_pacman+=("$pkg")
    fi
  done

  if [[ ${#missing_pacman[@]} -gt 0 ]]; then
    info "Installing ${#missing_pacman[@]} pacman packages..."
    for pkg in "${missing_pacman[@]}"; do
      dim "$pkg"
    done
    sudo pacman -S --needed --noconfirm "${missing_pacman[@]}" || warn "Some pacman packages may have failed"
  else
    ok "All pacman packages already installed"
  fi

  # AUR packages
  if [[ -n "$AUR_HELPER" ]]; then
    local missing_aur=()
    for pkg in "${AUR_PKGS[@]}"; do
      if ! pacman -Qi "$pkg" &>/dev/null; then
        missing_aur+=("$pkg")
      fi
    done

    if [[ ${#missing_aur[@]} -gt 0 ]]; then
      info "Installing ${#missing_aur[@]} AUR packages via $AUR_HELPER..."
      for pkg in "${missing_aur[@]}"; do
        dim "$pkg"
      done
      "$AUR_HELPER" -S --needed --noconfirm "${missing_aur[@]}" || warn "Some AUR packages may have failed"
    else
      ok "All AUR packages already installed"
    fi
  else
    warn "Skipping AUR packages (no helper). Install manually:"
    for pkg in "${AUR_PKGS[@]}"; do
      dim "  $pkg"
    done
  fi

  ok "Package installation complete"
}

# ─── Backup ───
backup_path() {
  local src="$1"
  local name="$2"

  if [[ -e "$src" ]]; then
    local backup_dst="$BACKUP_DIR/$name"
    mkdir -p "$(dirname "$backup_dst")"
    cp -a "$src" "$backup_dst"
    dim "Backed up $name"
  fi
}

backup_configs() {
  info "Backing up existing configs..."
  mkdir -p "$BACKUP_DIR"

  # Back up existing shell
  if [[ -d "$SHELL_DST" ]]; then
    backup_path "$SHELL_DST" "quickshell-sshell"
  fi

  # Back up config directories
  for dir in "${CONFIG_DIRS[@]}"; do
    if [[ -d "$CONFIG_DST/$dir" ]]; then
      backup_path "$CONFIG_DST/$dir" "configs/$dir"
    fi
  done

  # Back up config files
  for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$CONFIG_DST/$file" ]]; then
      backup_path "$CONFIG_DST/$file" "configs/$file"
    fi
  done

  # Symlink latest
  rm -f "$BACKUP_ROOT/latest"
  ln -s "$BACKUP_DIR" "$BACKUP_ROOT/latest"

  ok "Backup saved to $BACKUP_DIR"
}

# ─── Install ───
install_configs() {
  info "Installing config files..."

  # Copy config directories
  for dir in "${CONFIG_DIRS[@]}"; do
    if [[ -d "$CONFIG_SRC/$dir" ]]; then
      mkdir -p "$CONFIG_DST/$dir"
      rsync -a "$CONFIG_SRC/$dir/" "$CONFIG_DST/$dir/"
      dim "Installed $dir"
    fi
  done

  # Copy config files
  for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$CONFIG_SRC/$file" ]]; then
      cp -a "$CONFIG_SRC/$file" "$CONFIG_DST/$file"
      dim "Installed $file"
    fi
  done

  ok "Config files installed"
}

install_shell() {
  info "Installing sshell..."

  mkdir -p "$SHELL_DST"
  rsync -a "${SHELL_EXCLUDES[@]}" "$SHELL_SRC/" "$SHELL_DST/"

  ok "sshell installed to $SHELL_DST"
}

setup_state_dirs() {
  info "Setting up state directories..."
  mkdir -p "$HOME/.local/state/quickshell/wallpaper"
  mkdir -p "$HOME/.cache/sshell/thumbnails"
  ok "State directories created"
}

# ─── Uninstall ───
restore_backup() {
  local backup_src="$BACKUP_ROOT/latest"

  if [[ ! -d "$backup_src" ]]; then
    die "No backup found at $backup_src"
  fi

  info "Restoring from backup: $(readlink -f "$backup_src")"

  # Restore shell
  if [[ -d "$backup_src/quickshell-sshell" ]]; then
    rm -rf "$SHELL_DST"
    cp -a "$backup_src/quickshell-sshell" "$SHELL_DST"
    ok "Restored sshell"
  else
    info "No shell backup found, removing sshell directory..."
    rm -rf "$SHELL_DST"
    ok "Removed sshell"
  fi

  # Restore config directories
  for dir in "${CONFIG_DIRS[@]}"; do
    if [[ -d "$backup_src/configs/$dir" ]]; then
      rm -rf "$CONFIG_DST/$dir"
      cp -a "$backup_src/configs/$dir" "$CONFIG_DST/$dir"
      dim "Restored $dir"
    fi
  done

  # Restore config files
  for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$backup_src/configs/$file" ]]; then
      cp -a "$backup_src/configs/$file" "$CONFIG_DST/$file"
      dim "Restored $file"
    fi
  done

  ok "Restore complete!"
}

# ─── Commands ───
cmd_install() {
  banner
  check_prereqs

  echo ""
  info "This will install:"
  dim "sshell → $SHELL_DST"
  for dir in "${CONFIG_DIRS[@]}"; do
    [[ -d "$CONFIG_SRC/$dir" ]] && dim "$dir → $CONFIG_DST/$dir"
  done
  for file in "${CONFIG_FILES[@]}"; do
    [[ -f "$CONFIG_SRC/$file" ]] && dim "$file → $CONFIG_DST/$file"
  done

  echo ""
  info "Packages to install:"
  dim "pacman: ${PACMAN_PKGS[*]}"
  dim "fonts:  ${FONT_PKGS[*]}"
  dim "AUR:    ${AUR_PKGS[*]}"

  echo ""
  confirm "Continue with installation?" || exit 0

  echo ""
  install_packages
  echo ""
  backup_configs
  echo ""
  install_configs
  install_shell
  setup_state_dirs

  echo ""
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  ok "Installation complete!"
  echo ""
  dim "Start the shell:   qs -c sshell or restart your device"
  dim "Restore backup:    ./installer.sh uninstall"
  dim "Backups stored in: $BACKUP_ROOT"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

cmd_uninstall() {
  banner

  echo ""
  warn "This will remove sshell and restore your backed-up configs."
  echo ""
  confirm "Continue with uninstall?" || exit 0

  echo ""
  restore_backup
  echo ""

  echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  ok "Uninstall complete! Your previous configs have been restored."
  dim "Installed packages were NOT removed."
  dim "Remove them manually if needed."
  echo -e "${YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

cmd_help() {
  banner
  cat <<EOF
$(echo -e "${BOLD}Usage:${NC}") ./installer.sh <command>

$(echo -e "${BOLD}Commands:${NC}")
  install     Install sshell, configs, and dependencies
  uninstall   Restore backed-up configs and remove sshell
  help        Show this help message

$(echo -e "${BOLD}Backups:${NC}")
  All backups are stored in ~/.local/state/sshell/backups/
  The most recent backup is symlinked as 'latest'.
  Running 'uninstall' restores from the latest backup.
EOF
}

# ─── Entry ───
case "${1:-help}" in
  install)            cmd_install ;;
  uninstall|restore)  cmd_uninstall ;;
  help|--help|-h)     cmd_help ;;
  *)                  die "'$1' is not a valid command. Run './installer.sh help' for usage." ;;
esac
