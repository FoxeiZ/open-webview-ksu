cd $TMPDIR || cd "/data/local/tmp" && TMPDIR="/data/local/tmp"

mkdir open_webview
cd open_webview

wget --no-check-certificate -qO- https://github.com/FoxeiZ/open-webview-ksu/archive/refs/heads/main.zip | unzip -

cd open-webview-ksu-main
chmod -R +x .

su -c create-module.sh
cp -f module.zip /storage/emulated/0/Download/open_webview_ksu.zip
echo "Copy module.zip into /storage/emulated/0/Download/Download/open_webview_ksu.zip"
echo "Now go in KernelSU and flash module"

echo "Cleaning up..."
rm -rf "$TMPDIR"/open_webview
echo "Bye."
