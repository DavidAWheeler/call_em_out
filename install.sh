#!/usr/bin/env bash
# install.sh — Nautilus My Computer Extension Installer
#
# Default (latest release):
#   curl -fsSL https://raw.githubusercontent.com/yannmasoch/nautilus-my-computer/main/install.sh | bash
#
# Pin to a specific version:
#   VERSION=v0.2.1 curl -fsSL https://raw.githubusercontent.com/yannmasoch/nautilus-my-computer/main/install.sh | bash

main() {

set -euo pipefail

REF_OVERRIDE="${VERSION:-}"

# ─── Colors ───────────────────────────────────────────────────────────────────
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

line()      { printf "%-26s" "$1"; echo -e "${CYAN}$2${RESET}"; }
print_bye() { echo ""; echo -e "${BOLD}${CYAN}👋 Bye${RESET}"; echo ""; }
error()     { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()       { error "$*"; exit 1; }

# ─── Temp dir + cleanup ───────────────────────────────────────────────────────
TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

# ─── Constants ────────────────────────────────────────────────────────────────
REPO="yannmasoch/nautilus-my-computer"
EXT_DIR="$HOME/.local/share/nautilus-python/extensions"
EXT_FILE="nautilus-my-computer.py"
SCHEMA_FILE="io.github.yannmasoch.nautilus-my-computer.gschema.xml"
USER_SCHEMA_DIR="$HOME/.local/share/glib-2.0/schemas"

# ─── Source detection: local clone or remote ──────────────────────────────────
# INSTALL_SOURCE can be set externally to override auto-detection.
# If unset: use local files when run from inside a git clone, else download.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -z "${INSTALL_SOURCE:-}" ]; then
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$EXT_FILE" ] && [ -f "$SCRIPT_DIR/$SCHEMA_FILE" ]; then
        INSTALL_SOURCE="$SCRIPT_DIR"
    else
        INSTALL_SOURCE="remote"
    fi
fi

# ─── Read from terminal even when piped via curl | bash ───────────────────────
ask() {
    local prompt="$1" var="$2" default="${3:-}"
    printf "%s" "$prompt" >/dev/tty
    read -r "$var" </dev/tty
    printf -v "$var" '%s' "${!var%$'\r'}"
    if [ -z "${!var}" ] && [ -n "$default" ]; then
        printf -v "$var" '%s' "$default"
        printf "\033[1A\033[%dC%s\n" "${#prompt}" "$default" >/dev/tty
    fi
}

# ─── Package manager detection ────────────────────────────────────────────────
detect_pm() {
    if   command -v pacman  >/dev/null 2>&1; then PM=pacman;  NP_PKG="python-nautilus"
    elif command -v apt-get >/dev/null 2>&1; then PM=apt;     NP_PKG="python3-nautilus"
    elif command -v dnf     >/dev/null 2>&1; then PM=dnf;     NP_PKG="nautilus-python"
    elif command -v zypper  >/dev/null 2>&1; then PM=zypper;  NP_PKG="python3-nautilus"
    else die "Cannot detect package manager. Install the nautilus-python package manually and re-run."
    fi
    line "Package Manager" "$PM detected"
}

nautilus_python_installed() {
    case "$PM" in
        pacman) pacman -Q "$NP_PKG" >/dev/null 2>&1 ;;
        apt)    dpkg -l "$NP_PKG"   >/dev/null 2>&1 ;;
        dnf)    rpm -q  "$NP_PKG"   >/dev/null 2>&1 ;;
        zypper) rpm -q  "$NP_PKG"   >/dev/null 2>&1 ;;
    esac
}

ensure_nautilus_python() {
    if nautilus_python_installed; then
        line "$NP_PKG" "detected"
        return
    fi
    line "$NP_PKG" "not detected — installing..."
    case "$PM" in
        pacman) sudo pacman -S --noconfirm "$NP_PKG" ;;
        apt)    sudo apt-get install -y "$NP_PKG" python3-gi ;;
        dnf)    sudo dnf install -y "$NP_PKG" ;;
        zypper) sudo zypper install -y "$NP_PKG" ;;
    esac
    nautilus_python_installed || die "$NP_PKG installation failed."
    line "$NP_PKG" "installed"
}

ensure_gettext() {
    if command -v msgfmt >/dev/null 2>&1; then
        line "gettext (msgfmt)" "detected"
        return
    fi
    line "gettext (msgfmt)" "not detected — installing..."
    case "$PM" in
        pacman) sudo pacman -S --noconfirm gettext ;;
        apt)    sudo apt-get install -y gettext ;;
        dnf)    sudo dnf install -y gettext ;;
        zypper) sudo zypper install -y gettext-tools ;;
    esac
    command -v msgfmt >/dev/null 2>&1 || die "gettext (msgfmt) installation failed. Install gettext manually and re-run."
    line "gettext (msgfmt)" "installed"
}

# ─── Dependency check ─────────────────────────────────────────────────────────
check_dependencies() {
    local missing=""
    local tools="python3 glib-compile-schemas gsettings"
    if [ "$INSTALL_SOURCE" = "remote" ]; then tools="curl $tools"; fi
    for tool in $tools; do
        command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
    done
    [ -z "$missing" ] || die "Required tools missing:$missing"
}

# ─── Resolve version to install ──────────────────────────────────────────────
# Always fetches the latest published release into LATEST_RELEASE.
# If VERSION is set, LATEST is set to that; validate_ref will fall back to
# LATEST_RELEASE if the specified version does not exist.
LATEST=""
LATEST_RELEASE=""
REF_FALLBACK=false

fetch_latest_version() {
    local response
    response=$(curl -s "https://api.github.com/repos/$REPO/releases/latest") \
        || die "Failed to reach GitHub API."

    LATEST_RELEASE=$(echo "$response" | grep '"tag_name"' | sed 's/.*"tag_name": *"\(.*\)".*/\1/' || true)
    [ -z "$LATEST_RELEASE" ] && LATEST_RELEASE="main"

    LATEST="${REF_OVERRIDE:-$LATEST_RELEASE}"
}

# ─── Validate user-specified VERSION exists on GitHub ────────────────────────
validate_ref() {
    [ -z "$REF_OVERRIDE" ] && return
    local status
    status=$(curl -s -o /dev/null -w "%{http_code}" \
        "https://raw.githubusercontent.com/$REPO/$LATEST/$EXT_FILE")
    if [ "$status" != "200" ]; then
        REF_FALLBACK=true
        LATEST="$LATEST_RELEASE"
    fi
}

# ─── Fetch or copy source files ───────────────────────────────────────────────
download_files() {
    if [ "$INSTALL_SOURCE" = "remote" ]; then
        local base="https://raw.githubusercontent.com/$REPO/$LATEST"
        curl -fsSL "$base/$EXT_FILE" -o "$TEMP_DIR/$EXT_FILE" \
            || die "Failed to download $EXT_FILE"
        curl -fsSL "$base/$SCHEMA_FILE" -o "$TEMP_DIR/$SCHEMA_FILE" \
            || die "Failed to download $SCHEMA_FILE"

        # Download translation files
        mkdir -p "$TEMP_DIR/po"
        langs=$(curl -fsSL "https://api.github.com/repos/$REPO/contents/po?ref=$LATEST" \
            | grep '"name"' | sed 's/.*"name": "\(.*\)\.po".*/\1/' | grep -v '"name"') || true
        for lang in $langs; do
            curl -fsSL "$base/po/$lang.po" -o "$TEMP_DIR/po/$lang.po" || true
        done
    else
        cp "$INSTALL_SOURCE/$EXT_FILE"    "$TEMP_DIR/$EXT_FILE"    || die "Local $EXT_FILE not found"
        cp "$INSTALL_SOURCE/$SCHEMA_FILE" "$TEMP_DIR/$SCHEMA_FILE" || die "Local $SCHEMA_FILE not found"
        if [ -d "$INSTALL_SOURCE/po" ]; then
            cp -r "$INSTALL_SOURCE/po" "$TEMP_DIR/"
        fi
    fi

    python3 -m py_compile "$TEMP_DIR/$EXT_FILE" \
        || die "Extension file failed syntax check — aborting."
}

# ─── Install extension + schema ───────────────────────────────────────────────
install_files() {
    # Extension
    mkdir -p "$EXT_DIR"
    cp "$TEMP_DIR/$EXT_FILE" "$EXT_DIR/$EXT_FILE"
    rm -f "$EXT_DIR/__pycache__/nautilus-my-computer.cpython-"*.pyc 2>/dev/null || true
    line "Extension installed" "$EXT_DIR/$EXT_FILE"

    # Schema
    mkdir -p "$USER_SCHEMA_DIR"
    cp "$TEMP_DIR/$SCHEMA_FILE" "$USER_SCHEMA_DIR/$SCHEMA_FILE"
    line "Preferences installed" "$USER_SCHEMA_DIR/$SCHEMA_FILE"
    glib-compile-schemas "$USER_SCHEMA_DIR"

    # Translations (if any)
    [ -d "$TEMP_DIR/po" ] || return
    command -v msgfmt >/dev/null 2>&1 || return
    local langs_installed=""
    for po_file in "$TEMP_DIR"/po/*.po; do
        [ -f "$po_file" ] || continue
        lang=$(basename "$po_file" .po)
        loc_dir="$HOME/.local/share/locale/$lang/LC_MESSAGES"
        mkdir -p "$loc_dir"
        msgfmt "$po_file" -o "$loc_dir/nautilus-my-computer.mo"
        langs_installed="${langs_installed:+$langs_installed, }$lang"
    done
    [ -n "$langs_installed" ] && line "Translations installed" "$langs_installed"
}


# ─── Restart Nautilus ─────────────────────────────────────────────────────────
offer_restart() {
    echo "" >/dev/tty
    local answer
    ask "Restart Nautilus now? [Y/n]: " answer "Y"
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        nautilus -q >/dev/null 2>&1 || true
        sleep 1
        if command -v gtk-launch >/dev/null 2>&1; then
            gtk-launch org.gnome.Nautilus >/dev/null 2>&1 &
        else
            (exec >/dev/null 2>&1 </dev/null; exec nautilus) &
        fi
        disown $!
    fi
}

# ─── INSTALL ──────────────────────────────────────────────────────────────────
do_install() {
    echo ""
    check_dependencies

    if [ "$INSTALL_SOURCE" = "remote" ]; then
        fetch_latest_version
        validate_ref
        line "Installation type" "GitHub ($LATEST)"
        if [ -n "$REF_OVERRIDE" ]; then
            if [ "$REF_FALLBACK" = "true" ]; then
                line "Selected version" "${CYAN}$REF_OVERRIDE${RESET} not found - using ${CYAN}$LATEST_RELEASE${RESET}"
            else
                line "Selected version" "${CYAN}$REF_OVERRIDE${RESET}"
            fi
        fi
    else
        line "Installation type" "local"
        [ -n "$REF_OVERRIDE" ] && line "Selected version" "${CYAN}not available for local installs${RESET}"
    fi

    if [ -f "$EXT_DIR/$EXT_FILE" ]; then
        line "Previous installation" "detected"
    else
        line "Previous installation" "not detected"
    fi

    echo ""
    detect_pm
    ensure_nautilus_python
    ensure_gettext
    download_files
    install_files

    echo ""
    echo -e "${BOLD}${CYAN}🚀 Installation completed!${RESET}"
    offer_restart
}

# ─── UNINSTALL ────────────────────────────────────────────────────────────────
do_uninstall() {
    echo ""

    local found=false

    # Extension
    if [ -f "$EXT_DIR/$EXT_FILE" ]; then
        rm -f "$EXT_DIR/$EXT_FILE"
        rm -f "$EXT_DIR/__pycache__/nautilus-my-computer.cpython-"*.pyc 2>/dev/null || true
        line "Extension removed" "$EXT_DIR/$EXT_FILE"
        found=true
    fi

    # Schema
    if [ -f "$USER_SCHEMA_DIR/$SCHEMA_FILE" ]; then
        gsettings reset-recursively io.github.yannmasoch.nautilus-my-computer 2>/dev/null || true
        rm -f "$USER_SCHEMA_DIR/$SCHEMA_FILE"
        glib-compile-schemas "$USER_SCHEMA_DIR"
        line "Preferences removed" "$USER_SCHEMA_DIR/$SCHEMA_FILE"
        found=true
    fi

    # Translations
    local loc_dir_prefix="$HOME/.local/share/locale"
    local langs_removed=""
    if [ -d "$loc_dir_prefix" ]; then
        for mo_file in "$loc_dir_prefix"/*/LC_MESSAGES/nautilus-my-computer.mo; do
            if [ -f "$mo_file" ]; then
                lang=$(echo "$mo_file" | sed "s|$loc_dir_prefix/\(.*\)/LC_MESSAGES.*|\1|")
                rm -f "$mo_file"
                langs_removed="${langs_removed:+$langs_removed, }$lang"
                found=true
            fi
        done
    fi
    [ -n "$langs_removed" ] && line "Translation(s) removed" "$langs_removed"

    if [ "$found" = false ]; then
        line "Nothing to uninstall" "extension was not found"
        print_bye
        return
    fi

    echo ""
    echo -e "${BOLD}${CYAN}🗑️  Uninstall completed!${RESET}"
    offer_restart
}

# ─── MAIN MENU ────────────────────────────────────────────────────────────────
if [ -n "$REF_OVERRIDE" ]; then
    VERSION_LABEL="  ${CYAN}[$REF_OVERRIDE]${RESET}"
else
    VERSION_LABEL=""
fi

echo ""
echo -e "${BOLD}Nautilus My Computer Extension Installer${RESET}"
printf '%0.s─' {1..40}; echo
echo ""
echo -e "1) Install / Update${VERSION_LABEL}"
echo    "2) Uninstall"
echo    "3) Exit"
echo ""

choice=""
ask "Choose an option [1-3]: " choice ""

case "$choice" in
    1) do_install ;;
    2) do_uninstall ;;
    3) print_bye; exit 0 ;;
    *) die "Invalid choice: '$choice'" ;;
esac

} # end main

main
