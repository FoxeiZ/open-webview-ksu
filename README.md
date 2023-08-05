# Open WebView KSU

![Open WebView](https://raw.githubusercontent.com/FoxeiZ/open-webview-ksu/main/img/logo.png)

This script helps you create the module to replace your system webview though KernelSU.

>**ATTENTION!** There is a bug that still needs to be fixed where sometimes you may find that the installed webview doesn't work. To fix this bug you need to manually install the webview, to do this just:<br/><br/>- go to fdroid and re-download the latest version<br/>- manually download the apk and install it

## Compatibility

- Android 8+
- KernelSU v0.6.1+ (11041)

## Tested Device

- [LOS 20](https://lineageos.org/)
- [Corvus](https://github.com/Corvus-AOSP)
- And more...

## DISCLAIMER

Before flash module, please read below:
>I AM NOT RESPONSIBLE SOME YOUR FEATURE FROM YOUR DEVICE IF DOESN'T WORK PROPERLY. BEFORE FLASH THE MODULE, PLEASE READ LINE CODES AND SELECT GOOGLE SERVICES YOU NEEDS. YOU ARE FLASHING THIS MAGISK MODULE AND ITS YOUR CHOICE TO DO IT OR NOT TO DO IT AND YOU'RE THE ONE DOING IT. I JUST WANT TO HELP OTHERS OUT.

## Build step

```
# Run this on any terminal with root access

/data/adb/ksu/bin/busybox wget -qO /data/local/tmp/build.sh https://github.com/FoxeiZ/open-webview-ksu/raw/main/build.sh
ASH_STANDALONE=1 /data/adb/ksu/bin/busybox sh /data/local/tmp/build.sh

```

## Support

If you found this helpful, please consider supporting development with a [coffe](https://www.paypal.me/f3ff0). Alternatively, you can contribute to the project by reporting bugs and doing PR. All support is appreciated!

## Features

- Works on any device running Android 8.0+ and Magisk 20.4+
- Replace the webview with one of:
    1. [Bromite WebView](https://github.com/bromite/bromite)
    2. [Mulch](https://gitlab.com/divested-mobile/mulch)

## Credits

- Original [repo](https://github.com/Magisk-Modules-Alt-Repo/open_webview) by [F3FFO](https://github.com/F3FFO/)
- [aapt-binary](https://github.com/JonForShort/android-tools)
- [MMT-Extended-Next](https://github.com/symbuzzer/MMT-Extended-Next) by [symbuzzer](https://github.com/symbuzzer)
- [Bromite](https://github.com/bromite/bromite)
- [DivestOS](https://gitlab.com/divested-mobile)
- [cUrl](https://github.com/curl/curl)
- [cUrl binary](https://github.com/F3FFO/compile_zlib_openssl_curl_android)
- [Zipsigner and zip](https://github.com/Magisk-Modules-Repo/zipsigner) by [osm0sis](https://github.com/osm0sis)

## License

Copyright 2023 F3FFO

The source code is available under [GPL-3.0](https://github.com/Magisk-Modules-Alt-Repo/open_fonts/blob/master/LICENSE)

## Change logs

# v2.1.0_1

- Porting to ksu
- Change aapt binary
- Reduce zip size
- Unpack all overlays zip file

# v2.1.0

- Add Mulch webview
- Add status in the module description
- Update bromite to v108.0.5359.156
- Bug fix

# v2.0.0

- Reworked the installation logic
- Add cleaning logic for dalvik cache
- Update bromite to v106.0.5249.163
- Bug fix

# v1.1.0

- Add curl binary
- Bug fix

# v1.0.1

- Bug fix

# v1.0.0

- Initial release
