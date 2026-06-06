#!/usr/bin/env bash
# install.sh — Nautilus My Computer Extension Installer
#
# Wrap everything in main() so a truncated curl | sh never executes a half-downloaded script.
#
# Latest release:
#   curl -fsSL https://raw.githubusercontent.com/yannmasoch/nautilus-my-computer/main/install.sh | sh
#
# Specific version:
#   VERSION=v0.1.1 curl -fsSL https://…/install.sh | sh
#
# Dev branch:
#   BRANCH=dev curl -fsSL https://…/install.sh | sh
#
# Uninstall:
#   curl -fsSL https://…/install.sh | sh -s -- --uninstall

main() {

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED=$'\033[0;31m'
CYAN=$'\033[0;36m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

line()  { printf "%-20s" "$1"; echo -e "${CYAN}$2${RESET}"; }
error() { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
die()   { error "$*"; exit 1; }

# ─── Temp dir + cleanup ───────────────────────────────────────────────────────
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# ─── Constants ────────────────────────────────────────────────────────────────
REPO="yannmasoch/nautilus-my-computer"
EXT_DIR="$HOME/.local/share/nautilus-python/extensions"
EXT_FILE="nautilus-my-computer.py"
SCHEMA_FILE="io.github.yannmasoch.nautilus-my-computer.gschema.xml"
USER_SCHEMA_DIR="$HOME/.local/share/glib-2.0/schemas"

# ─── Argument parsing ─────────────────────────────────────────────────────────
MODE="install"
for arg in "$@"; do
    case "$arg" in
        --uninstall) MODE="uninstall" ;;
        *) die "Unknown argument: $arg" ;;
    esac
done

VERSION="${VERSION:-}"
BRANCH="${BRANCH:-}"

# ─── Source detection: local clone or remote ──────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
if [ -z "${INSTALL_SOURCE:-}" ]; then
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$EXT_FILE" ] && [ -f "$SCRIPT_DIR/$SCHEMA_FILE" ]; then
        INSTALL_SOURCE="$SCRIPT_DIR"
    else
        INSTALL_SOURCE="remote"
    fi
fi

# ─── Package manager detection ────────────────────────────────────────────────
PM=""
NP_PKG=""

detect_pm() {
    if   command -v pacman  >/dev/null 2>&1; then PM=pacman;  NP_PKG="python-nautilus"
    elif command -v apt-get >/dev/null 2>&1; then PM=apt;     NP_PKG="python3-nautilus"
    elif command -v dnf     >/dev/null 2>&1; then PM=dnf;     NP_PKG="nautilus-python"
    elif command -v zypper  >/dev/null 2>&1; then PM=zypper;  NP_PKG="python3-nautilus"
    else die "Cannot detect package manager. Install nautilus-python manually and re-run."
    fi
    line "Package manager" "$PM"
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
        line "$NP_PKG" "detected"; return
    fi
    line "$NP_PKG" "not found — installing..."
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
        line "gettext" "detected"; return
    fi
    line "gettext" "not found — installing..."
    case "$PM" in
        pacman) sudo pacman -S --noconfirm gettext ;;
        apt)    sudo apt-get install -y gettext ;;
        dnf)    sudo dnf install -y gettext ;;
        zypper) sudo zypper install -y gettext-tools ;;
    esac
    if command -v msgfmt >/dev/null 2>&1; then
        line "gettext" "installed"
    else
        line "gettext" "install failed — translations will be skipped"
    fi
}

# ─── Dependency check ─────────────────────────────────────────────────────────
check_dependencies() {
    local missing="" tools="python3 glib-compile-schemas gsettings"
    [ "$INSTALL_SOURCE" = "remote" ] && tools="curl $tools"
    for tool in $tools; do
        command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
    done
    [ -z "$missing" ] || die "Required tools missing:$missing"
}

# ─── Resolve ref ──────────────────────────────────────────────────────────────
LATEST=""

resolve_ref() {
    if [ -n "$BRANCH" ]; then
        LATEST="$BRANCH"
        line "Source" "branch $BRANCH"
        return
    fi

    local response latest_release
    response=$(curl -s "https://api.github.com/repos/$REPO/releases/latest") \
        || die "Failed to reach GitHub API."
    latest_release=$(echo "$response" | grep '"tag_name"' \
        | sed 's/.*"tag_name": *"\(.*\)".*/\1/' || true)
    [ -z "$latest_release" ] && latest_release="main"

    if [ -n "$VERSION" ]; then
        local status
        status=$(curl -s -o /dev/null -w "%{http_code}" \
            "https://raw.githubusercontent.com/$REPO/$VERSION/$EXT_FILE")
        if [ "$status" = "200" ]; then
            LATEST="$VERSION"
            line "Version" "$VERSION"
        else
            LATEST="$latest_release"
            line "Version" "$VERSION not found — using $latest_release"
        fi
    else
        LATEST="$latest_release"
        line "Version" "$latest_release (latest)"
    fi
}

# ─── Fetch or copy source files ───────────────────────────────────────────────
download_files() {
    if [ "$INSTALL_SOURCE" = "remote" ]; then
        local base="https://raw.githubusercontent.com/$REPO/$LATEST"
        curl -fsSL "$base/$EXT_FILE"    -o "$TEMP_DIR/$EXT_FILE"    || die "Failed to download $EXT_FILE"
        curl -fsSL "$base/$SCHEMA_FILE" -o "$TEMP_DIR/$SCHEMA_FILE" || die "Failed to download $SCHEMA_FILE"

        mkdir -p "$TEMP_DIR/po"
        local langs
        langs=$(curl -fsSL "https://api.github.com/repos/$REPO/contents/po?ref=$LATEST" \
            | grep '"name"' | sed 's/.*"name": "\(.*\)\.po".*/\1/' | grep -v '"name"') || true
        for lang in $langs; do
            curl -fsSL "$base/po/$lang.po" -o "$TEMP_DIR/po/$lang.po" || true
        done
    else
        cp "$INSTALL_SOURCE/$EXT_FILE"    "$TEMP_DIR/$EXT_FILE"    || die "Local $EXT_FILE not found"
        cp "$INSTALL_SOURCE/$SCHEMA_FILE" "$TEMP_DIR/$SCHEMA_FILE" || die "Local $SCHEMA_FILE not found"
        [ -d "$INSTALL_SOURCE/po" ] && cp -r "$INSTALL_SOURCE/po" "$TEMP_DIR/"
    fi

    python3 -m py_compile "$TEMP_DIR/$EXT_FILE" \
        || die "Extension file failed syntax check — aborting."
}

# ─── Install extension + schema ───────────────────────────────────────────────
install_files() {
    mkdir -p "$EXT_DIR"
    cp "$TEMP_DIR/$EXT_FILE" "$EXT_DIR/$EXT_FILE"
    rm -f "$EXT_DIR/__pycache__/nautilus-my-computer.cpython-"*.pyc 2>/dev/null || true
    line "Extension" "$EXT_DIR/$EXT_FILE"

    mkdir -p "$USER_SCHEMA_DIR"
    cp "$TEMP_DIR/$SCHEMA_FILE" "$USER_SCHEMA_DIR/$SCHEMA_FILE"
    glib-compile-schemas "$USER_SCHEMA_DIR"
    line "Preferences" "$USER_SCHEMA_DIR/$SCHEMA_FILE"

    [ -d "$TEMP_DIR/po" ] || return
    command -v msgfmt >/dev/null 2>&1 || return
    local lang_list=""
    for po_file in "$TEMP_DIR"/po/*.po; do
        [ -f "$po_file" ] || continue
        local lang loc_dir
        lang=$(basename "$po_file" .po)
        loc_dir="$HOME/.local/share/locale/$lang/LC_MESSAGES"
        mkdir -p "$loc_dir"
        msgfmt "$po_file" -o "$loc_dir/nautilus-my-computer.mo"
        lang_list="$lang_list $lang"
    done
    [ -n "$lang_list" ] && line "Languages" "$(format_lang_list "$lang_list")"
}

# ─── Format language list: EN (default) first, then alpha-sorted uppercase ────
format_lang_list() {
    local langs="$1" result="EN (default)" rest=""
    rest=$(echo "$langs" | tr ' ' '\n' | grep -v "^en$" | sort | tr '[:lower:]' '[:upper:]' | tr '\n' ' ')
    for lang in $rest; do
        result="$result, $lang"
    done
    echo "$result"
}

# ─── Restart Nautilus ─────────────────────────────────────────────────────────
restart_nautilus() {
    nautilus -q >/dev/null 2>&1 || true
    sleep 1
    if command -v gtk-launch >/dev/null 2>&1; then
        gtk-launch org.gnome.Nautilus >/dev/null 2>&1 &
    else
        (exec >/dev/null 2>&1 </dev/null; exec nautilus) &
    fi
    disown $!
}

# ─── INSTALL ──────────────────────────────────────────────────────────────────
do_install() {
    echo ""
    check_dependencies

    echo -e "${BOLD}Install type${RESET}"
    if [ "$INSTALL_SOURCE" = "remote" ]; then
        resolve_ref
    else
        line "Source" "local"
    fi

    if [ -f "$EXT_DIR/$EXT_FILE" ]; then
        line "Previous install" "found (updating)"
    fi

    echo ""
    echo -e "${BOLD}System${RESET}"
    detect_pm
    ensure_nautilus_python
    ensure_gettext

    echo ""
    echo -e "${BOLD}Install${RESET}"
    download_files
    install_files

    echo ""
    echo -e "${BOLD}${CYAN}🚀 Installation complete!${RESET}"
    echo ""
    restart_nautilus
}

# ─── UNINSTALL ────────────────────────────────────────────────────────────────
do_uninstall() {
    echo ""
    echo -e "${BOLD}Uninstall${RESET}"
    local found=false

    if [ -f "$EXT_DIR/$EXT_FILE" ]; then
        rm -f "$EXT_DIR/$EXT_FILE"
        rm -f "$EXT_DIR/__pycache__/nautilus-my-computer.cpython-"*.pyc 2>/dev/null || true
        line "Extension" "$EXT_DIR/$EXT_FILE"
        found=true
    fi

    if [ -f "$USER_SCHEMA_DIR/$SCHEMA_FILE" ]; then
        gsettings reset-recursively io.github.yannmasoch.nautilus-my-computer 2>/dev/null || true
        rm -f "$USER_SCHEMA_DIR/$SCHEMA_FILE"
        glib-compile-schemas "$USER_SCHEMA_DIR"
        line "Preferences" "$USER_SCHEMA_DIR/$SCHEMA_FILE"
        found=true
    fi

    local loc_prefix="$HOME/.local/share/locale"
    local lang_list=""
    for mo_file in "$loc_prefix"/*/LC_MESSAGES/nautilus-my-computer.mo; do
        [ -f "$mo_file" ] || continue
        local lang
        lang=$(echo "$mo_file" | sed "s|$loc_prefix/\(.*\)/LC_MESSAGES.*|\1|")
        rm -f "$mo_file"
        lang_list="$lang_list $lang"
        found=true
    done
    [ -n "$lang_list" ] && line "Languages" "$(format_lang_list "$lang_list")"

    if [ "$found" = false ]; then
        echo -e "${BOLD}${CYAN}Nothing to uninstall!${RESET}"
        echo ""
        return
    fi

    echo ""
    echo -e "${BOLD}${CYAN}🗑️  Uninstall complete!${RESET}"
    echo ""
    restart_nautilus
}

# ─── Entry point ──────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Nautilus My Computer Installer${RESET}"
printf '%0.s─' {1..30}; echo

case "$MODE" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
esac

} # end main

main "$@"
