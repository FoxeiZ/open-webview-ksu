# VW_APK_URL=
# OVERLAY_APK_FILE="WebviewOverlay.apk"
# OVERLAY_ZIP_FILE="overlay.zip"
CONFIG_FILE="$MODPATH/.webview"

alias curl='$MODPATH/common/tools/curl --dns-servers 1.1.1.1,1.0.0.1'
ksu_overlay() {
    ui_print "Create overlay folder at $MODPATH""$1"
    if [ ! -d "$MODPATH""$1" ]; then
        mkdir -p "$MODPATH""$1"
    else
        ui_print "Folder already exists. Skipping folder create."
    fi
    setfattr -n trusted.overlay.opaque -v y "$MODPATH""$1"
}
download_file() {
    ui_print "  Downloading..."

    curl -skL "$2" -o "$TMPDIR"/"$1"

    if [[ ! -f "$TMPDIR"/$1 ]]; then
        check_status 1
    fi
}
check_integrity() {
    SHA_FILE_CALCULATED=$(sha256sum "$1" | awk '{print $1}')
    if [[ $SHA_FILE_CALCULATED = "$2" ]]; then
        echo "  Integrity checked!"
    else
        echo "  Integrity not checked!"
        clean_up 1
    fi
}

check_status() {
    if [[ $1 -eq 0 ]]; then
        ui_print ""
        ui_print "  !!! Dowload failed !!!"
        ui_print ""
        clean_up "$1"
    fi
}
replace_old_webview() {
    for i in "com.android.chrome" "com.android.webview" "com.google.android.webview"; do
        unsanitized_path=$(cmd package dump "$i" | grep codePath)
        path=${unsanitized_path##*=}
        [ -z $path ] && continue
        if [[ -d $path ]]; then
            ksu_overlay "$path/"
        fi
    done
}
copy_webview_file() {
    cp -af "$TMPDIR"/webview.apk "$MODPATH"/"$VW_SYSTEM_PATH"/webview.apk
    cp -af "$TMPDIR"/webview.apk "$TMPDIR"/webview.zip
}
extract_lib() {
    mkdir -p "$MODPATH"/"$VW_SYSTEM_PATH"/lib/arm64 "$MODPATH"/"$VW_SYSTEM_PATH"/lib/arm
    cp -rf "$TMPDIR"/webview/lib/arm64-v8a/* "$MODPATH"/"$VW_SYSTEM_PATH"/lib/arm64
    cp -rf "$TMPDIR"/webview/lib/armeabi-v7a/* "$MODPATH"/"$VW_SYSTEM_PATH"/lib/arm
}
install_webview() {
    ksu_overlay "/$VW_SYSTEM_PATH"

    copy_webview_file
    if [[ -n $VW_TRICHROME_LIB_URL ]]; then
        download_file trichrome.apk "$VW_TRICHROME_LIB_URL"
        ui_print "  Installing trichrome library..."
        su -c "pm install -r -t --user 0 ${TMPDIR}/trichrome.apk" >&2
    fi
    su -c "pm install -r -t --user 0 ${TMPDIR}/webview.apk" >&2
    mkdir -p "$TMPDIR"/webview
    unzip -qo "$TMPDIR"/webview.zip -d "$TMPDIR"/webview >&2
    extract_lib
}
force_overlay() {
    if [[ -d "$MODPATH"/product ]]; then
        if [[ -d "$MODPATH"/system/product ]]; then
            for i in "$MODPATH"/product/*;
            do
                ui_print "$i"
                mv $i "$MODPATH"/system/product/
            done
            rm -rf "$MODPATH"/product/
        else
            mv "$MODPATH"/product/ "$MODPATH"/system/
        fi
    fi
    mkdir -p "$MODPATH"/$OVERLAY_PATH
    mktouch "$MODPATH"/$OVERLAY_PATH$OVERLAY_APK_FILE
#    cat "$MODPATH"/common/$OVERLAY_APK_FILE > "$MODPATH"/$OVERLAY_PATH$OVERLAY_APK_FILE
    mv "$MODPATH"/common/$OVERLAY_APK_FILE "$MODPATH"/$OVERLAY_PATH$OVERLAY_APK_FILE
}
clean_up() {
    if [[ $1 -eq 1 ]]; then
        ui_print ""
        sleep 20
        abort "  Aborting..."
    fi

    ui_print "  Cleaning up..."
    rm -rf "$MODPATH"/common/
    ui_print "  !!! Dalvik cache will be cleared next boot."
    ui_print "  !!! Boot time may be longer."
}

if [[ ! $BOOTMODE ]]; then
    ui_print "  Installing through recovery NOT supported!"
    ui_print "  Install this module via Magisk Manager"
    clean_up 1
fi

ui_print "  Installing webview..."
download_file webview.apk "$VW_APK_URL"
#cp /sdcard/webview.apk "$TMPDIR"/webview.apk
if [[ -n $VW_SHA ]]; then
    ui_print "  Checking integrity..."
    check_integrity webview.apk "$VW_SHA"
fi
replace_old_webview
install_webview
force_overlay

if [[ -f $CONFIG_FILE ]]; then
    rm -rf "$CONFIG_FILE"
fi

{
    echo "RESET=1"
    echo "OVERLAY_PATH=${OVERLAY_PATH}"
    echo "OVERLAY_APK_FILE=${OVERLAY_APK_FILE}"
    echo "VW_PACKAGE=${VW_PACKAGE}"
    echo "VW_OVERLAY_PACKAGE=${VW_OVERLAY_PACKAGE}"
} >> "$CONFIG_FILE"
clean_up 0
