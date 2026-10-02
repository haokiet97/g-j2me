#!/bin/sh
# install_j2me.sh - Install/upgrade J2ME emulator from bundled resources
# Usage: install_j2me.sh [--force] --lang=VI|EN
# Exit codes: 0=success, 1=error
# Output: last line = user-facing message (VI or EN)

set -e

SDCARD="${SDCARD:-/mnt/SDCARD}"
EMU_DIR="$SDCARD/Emus/JAVA"
RUNTIME_DIR="$EMU_DIR/zulu17"
RES_DIR="$(cd "$(dirname "$0")/../j2me_resources" && pwd)"

REQUIRED_FILES="
$RUNTIME_DIR/bin/java
$RUNTIME_DIR/bin/freej2me-sdl.jar
$RUNTIME_DIR/bin/sdl_interface
$EMU_DIR/config.json
$EMU_DIR/launch.sh
"

msg_vi() {
    case "$1" in
        missing_payload) echo "Thiếu gói cài trong app (j2me_resources/)" ;;
        installing) echo "Đang cài đặt..." ;;
        upgrading) echo "Đang nâng cấp..." ;;
        installed) echo "Đã cài giả lập Java J2ME" ;;
        reinstalled) echo "Đã cài lại giả lập Java J2ME" ;;
        upgraded) echo "Đã nâng cấp giả lập Java J2ME lên bản mới" ;;
        incomplete) echo "Cài chưa đủ, còn thiếu: $2" ;;
        error) echo "Lỗi cài đặt: $2" ;;
        stale_detected) echo "Phát hiện bản cũ, đang nâng cấp tự động..." ;;
    esac
}

msg_en() {
    case "$1" in
        missing_payload) echo "Installer resources missing from app (j2me_resources/)" ;;
        installing) echo "Installing..." ;;
        upgrading) echo "Upgrading..." ;;
        installed) echo "Java J2ME emulator installed" ;;
        reinstalled) echo "Java J2ME emulator reinstalled" ;;
        upgraded) echo "Java J2ME emulator upgraded to the new build" ;;
        incomplete) echo "Incomplete, missing: $2" ;;
        error) echo "Install failed: $2" ;;
        stale_detected) echo "Old build detected, auto-upgrading..." ;;
    esac
}

log() {
    echo "[install_j2me] $*" >&2
}

get_binary_sizes() {
    local dir="$1"
    stat -c%s "$dir/bin/freej2me-sdl.jar" 2>/dev/null || echo 0
    stat -c%s "$dir/bin/sdl_interface" 2>/dev/null || echo 0
}

is_stale() {
    local res_sizes
    local inst_sizes
    res_sizes=$(get_binary_sizes "$RES_DIR/zulu17")
    inst_sizes=$(get_binary_sizes "$RUNTIME_DIR")
    [ "$res_sizes" != "$inst_sizes" ]
}

backup_user_data() {
    local stash_dir
    stash_dir=$(mktemp -d -p "$EMU_DIR" .rh_j2me_XXXXXX)
    for d in bin/rms bin/config; do
        [ -d "$RUNTIME_DIR/$d" ] && mv "$RUNTIME_DIR/$d" "$stash_dir/"
    done
    echo "$stash_dir"
}

restore_user_data() {
    local stash="$1"
    for d in bin/rms bin/config; do
        [ -d "$stash/$d" ] && mv "$stash/$d" "$RUNTIME_DIR/"
    done
    rmdir "$stash" 2>/dev/null || true
}

save_render_mode() {
    local mode="$1"
    cat > "$RUNTIME_DIR/bin/renderer.conf" <<EOF
render_mode=$mode
integer_scaling=true
keep_aspect=true
text_aa=true
shape_aa=true
m3g_filter=linear
EOF
}

load_render_mode() {
    grep '^render_mode=' "$RUNTIME_DIR/bin/renderer.conf" 2>/dev/null | cut -d= -f2
}

setup_nextui_pak() {
    for plat in tg5040 tg5050; do
        local pak_dir="$SDCARD/Emus/$plat/JAVA.pak"
        mkdir -p "$pak_dir"
        cat > "$pak_dir/launch.sh" <<'EOF'
#!/bin/sh
ROM="$1"
EMU_ROOT="/mnt/SDCARD/Emus/JAVA"
if [ -f "$EMU_ROOT/launch.sh" ]; then
    exec "$EMU_ROOT/launch.sh" "$ROM"
else
    cd "$EMU_ROOT/zulu17/bin"
    exec ./java -Djava.awt.headless=true -jar ./freej2me-sdl.jar "$ROM"
fi
EOF
        chmod +x "$pak_dir/launch.sh"
    done
}

verify_install() {
    local missing=""
    for f in $REQUIRED_FILES; do
        [ -e "$f" ] || missing="$missing $f"
    done
    if [ -n "$missing" ]; then
        echo "$missing"
        return 1
    fi
    return 0
}

print_msg() {
    local lang="$1"
    local key="$2"
    local arg="$3"
    if [ "$lang" = "VI" ]; then
        msg_vi "$key" "$arg"
    else
        msg_en "$key" "$arg"
    fi
}

main() {
    local force=0
    local lang="VI"
    for arg in "$@"; do
        case $arg in
            --force) force=1 ;;
            --lang=*) lang="${arg#*=}" ;;
        esac
    done

    if [ ! -d "$RES_DIR/zulu17" ]; then
        print_msg "$lang" error "Resources not found at $RES_DIR"
        exit 1
    fi

    local stale=0
    if [ $force -eq 0 ] && is_stale; then
        stale=1
        force=1
        print_msg "$lang" stale_detected >&2
    fi

    local stash=""
    if [ $force -eq 1 ] && [ -d "$RUNTIME_DIR" ]; then
        stash=$(backup_user_data)
        log "Backed up user data to $stash"
    fi

    local saved_mode=""
    if [ $force -eq 1 ]; then
        saved_mode=$(load_render_mode)
    fi

    log "Copying resources from $RES_DIR to $EMU_DIR"
    mkdir -p "$EMU_DIR" "$RUNTIME_DIR"
    cp -r "$RES_DIR"/* "$EMU_DIR/"

    chmod +x "$RUNTIME_DIR/bin/java" "$RUNTIME_DIR/bin/sdl_interface" 2>/dev/null || true
    chmod +x "$EMU_DIR/launch.sh" "$EMU_DIR/cpuswitch.sh" "$EMU_DIR/cpufreq.sh" 2>/dev/null || true

    if [ -n "$saved_mode" ]; then
        save_render_mode "$saved_mode"
    fi

    if [ -n "$stash" ]; then
        restore_user_data "$stash"
    fi

    setup_nextui_pak

    local missing
    if missing=$(verify_install); then
        if [ $stale -eq 1 ]; then
            print_msg "$lang" upgraded
        elif [ $force -eq 1 ]; then
            print_msg "$lang" reinstalled
        else
            print_msg "$lang" installed
        fi
        exit 0
    else
        print_msg "$lang" incomplete "$missing"
        exit 1
    fi
}

main "$@"