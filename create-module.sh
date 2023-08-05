dir="$(cd "$(dirname "$0")" || exit; pwd)";

OVERLAY_API=28
OVERLAY_APK_FILE="WebviewOverlay.apk"

api="$(getprop ro.build.version.sdk)"
[ -z "$TMPDIR" ] && TMPDIR="/data/local/tmp"
if [ -n "$TERMUX_APP__UID" ]; then
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
fi

if [ "$(getprop ro.product.cpu.abi)" == "arm64-v8a" ]; then
    abi="arm64"
else
    abi="arm"
fi

alias curl='$dir/tools/tools/$abi/curl --dns-servers 1.1.1.1,1.0.0.1'
alias aapt='$dir/tools/tools/$abi/aapt'
alias sign='$dir/tools/zipsigner'


clean_up() {
    if [[ $1 -eq 1 ]]; then
        echo "  $2"
        echo "  Aborting..."
        rm -rf "$dir"/module
        exit 1
    fi

    echo "Cleaning..."
    rm -rf "$dir"/module
    echo "Exit."
}
to_module() {
    if [ ! -d "$dir"/module/"$2" ]; then
        mkdir -p "$dir"/module/"$2"
    fi

    cp -af "$dir"/"$1" "$dir"/module/"$2"
}
get_version_github() {
    curl -kLs "https://api.github.com/repos/$1/releases/latest" |
        grep '"tag_name":' |
        sed -E 's/.*"(.*)".*/\1/'
}
get_sha_gitlab_lfs() {
    curl -kLs "https://gitlab.com/api/v4/projects/$1/repository/files/$2" |
        grep 'oid sha256:' |
        cut -d":" -f2
}
get_sha_gitlab() {
    curl -kLs "https://gitlab.com/api/v4/projects/$1/repository/files/$2" |
        grep 'content_sha256:' |
        cut -d":" -f2
}
get_bromite_sha() {
    curl -kLs "https://github.com/bromite/bromite/releases/download/$1/brm_$1.sha256.txt" |
        awk -v val="${abi}_SystemWebView.apk" '$2 == val {print $1}'
}
bromite() {
    tag_name_bormite=$(get_version_github "bromite/bromite")
    VW_APK_URL=https://github.com/bromite/bromite/releases/download/${tag_name_bormite}/${abi}_SystemWebView.apk
#    VW_APK_URL=http://127.0.0.1:8000/arm64_SystemWebView.apk
    VW_TRICHROME_LIB_URL=""
    VW_OVERLAY_PATH=overlays/bromite-overlay${OVERLAY_API}
    VW_SHA=$(get_bromite_sha "$tag_name_bormite")
    VW_SYSTEM_PATH=system/app/BromiteWebview
    VW_PACKAGE="org.bromite.webview"
    VW_OVERLAY_PACKAGE="org.Bromite.WebviewOverlay"
}
mulch() {
    VW_APK_URL=https://gitlab.com/divested-mobile/mulch/-/raw/master/prebuilt/${abi}/webview.apk
    VW_TRICHROME_LIB_URL=""
    VW_OVERLAY_PATH=overlays/mulch-overlay${OVERLAY_API}
    VW_SHA=$(get_sha_gitlab_lfs "30111188" "prebuilt%2F${abi}%2Fwebview.apk/raw?ref=master")
    VW_SYSTEM_PATH=system/app/MulchWebview
    VW_PACKAGE="us.spotco.mulch_wv"
    VW_OVERLAY_PACKAGE="us.spotco.WebviewOverlay"
}
vanadium() {
    VW_APK_URL="https://gitlab.com/api/v4/projects/40905333/repository/files/prebuilt%2F${1}%2FTrichromeWebView.apk/raw?ref=13"
    VW_TRICHROME_LIB_URL="https://gitlab.com/api/v4/projects/40905333/repository/files/prebuilt%2F${1}%2FTrichromeLibrary.apk/raw?ref=13"
    VW_OVERLAY_PATH=overlays/vanadium-overlay${OVERLAY_API}
    # VW_SHA=$(get_sha_gitlab "40905333" "prebuilt%2F${1}%2FTrichromeWebView.apk?ref=13")
    VW_SHA=""
    VW_SYSTEM_PATH=system/app/VanadiumWebview
    VW_PACKAGE="app.vanadium.webview"
    VW_OVERLAY_PACKAGE="app.vanadium.WebviewOverlay"
}
download_file() {
    echo "  Downloading... {$2}"

    curl -skL "$2" -o "$dir/module/common/$1"

    if [[ ! -f "$dir/module/common/$1" ]]; then
        check_status 1
    fi
}
check_status() {
    if [[ $1 -eq 0 ]]; then
        echo ""
        echo "  !!! Dowload failed !!!"
        echo ""
        clean_up "$1"
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
create_overlay() {
    aapt p -fvM "$dir"/"$VW_OVERLAY_PATH"/AndroidManifest.xml -I /system/framework/framework-res.apk -S "$dir"/"$VW_OVERLAY_PATH"/res -F "$dir"/module/unsigned.apk
#     cp -f "$MODPATH"/unsigned.apk /sdcard/unsigned.apk
}
sign_framework_res() {
    sign "$dir"/module/unsigned.apk "$dir"/module/signed.apk
#     cp -f "$MODPATH"/signed.apk /sdcard/signed.apk
    mv -f "$dir"/module/signed.apk "$dir"/module/common/"$OVERLAY_APK_FILE"
}
find_overlay_path() {
    if [[ -d /system_ext/overlay ]]; then
        OVERLAY_PATH=system/system_ext/overlay/
    elif [[ -d /product/overlay ]]; then
        OVERLAY_PATH=system/product/overlay/
    elif [[ -d /vendor/overlay ]]; then
        OVERLAY_PATH=system/vendor/overlay/
    elif [[ -d /system/overlay ]]; then
        OVERLAY_PATH=system/overlay/
    else
        clean_up 1
    fi
}

to_module CHANGELOG.md
to_module LICENSE
to_module README.md
# to_module data/overlays
to_module data/customize.sh
to_module data/module.prop
to_module data/post-fs-data.sh
to_module data/service.sh
to_module data/uninstall.sh
to_module data/common/functions.sh common/
to_module data/META-INF
to_module tools/tools/$abi/curl common/tools/
# to_module data/common/addon common/addon

mkdir -p "$dir"/module/common


if [[ $api -ge 29 ]]; then
    OVERLAY_API=29
fi

echo "Choose your webview: "
echo "  1. Bromite"
echo "  2. Mulch"
echo "  3. Vanadium"
read -r choice
case "$choice" in
    1) bromite;;
    2) mulch;;
    3) vanadium "arm64";;
    *) clean_up 1 "Not recognize that options."
esac


echo "Make module for Android API $api $abi"

echo "Initialize..."
echo "  Run in terminal"
#
# download_file webview.apk "$VW_APK_URL"
# if [[ -n $VW_SHA ]]; then
#     echo "  Checking integrity..."
#     check_integrity "$dir"/module/common/webview.apk "$VW_SHA"
# fi
#





echo "  Creating overlay..."
create_overlay
echo "  Done."

echo "  Signing overlay APK..."
sign_framework_res
echo "  Done."

find_overlay_path
echo "  Found overlay path at: $OVERLAY_PATH"
# force_overlay

install_file="$dir/module/common/install.sh"
{
    echo "VW_APK_URL=\"$VW_APK_URL\""
    echo "VW_TRICHROME_LIB_URL=\"$VW_TRICHROME_LIB_URL\""
    echo "VW_OVERLAY_PATH=\"\$MODPATH/$VW_OVERLAY_PATH\""
    echo "VW_SHA=\"$VW_SHA\""
    echo "VW_SYSTEM_PATH=\"$VW_SYSTEM_PATH\""
    echo "VW_PACKAGE=\"$VW_PACKAGE\""
    echo "VW_OVERLAY_PACKAGE=\"$VW_OVERLAY_PACKAGE\""
    printf "\n\n"
    echo "OVERLAY_PATH=\"$OVERLAY_PATH\""
    echo "OVERLAY_API=\"$OVERLAY_API\""
    echo "OVERLAY_APK_FILE=\"$OVERLAY_APK_FILE\""
    printf "\n\n"
    cat "$dir/data/common/new_install.sh"
}  >> "$install_file"

which zip 2>&1
if [ $? -eq 1 ]; then
    alias zip='$dir/tools/zip'
fi

chown -R everybody:everybody "$dir"/module
ls -la "$dir"/module
echo "$(cd "$dir"/module; zip -0 -r ../module.zip .)"
chown -R everybody:everybody "$dir"/module.zip
clean_up 0
