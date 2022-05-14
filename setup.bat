@echo off
title FNKNGT Setup - Start
echo Make sure Haxe 4.1.5 is installed (4.1.5 is important)!
echo Press any key to install required libraries.
pause >nul
title FNKNGT Setup - Installing libraries
echo Installing haxelib libraries...
haxelib install lime 7.9.0
haxelib install openfl
haxelib install flixel
haxelib run lime setup
haxelib run lime setup flixel
haxelib install flixel-tools
haxelib run flixel-tools setup
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
cls
echo Make sure you have git installed. You can download it here: https://git-scm.com/downloads
echo Press any key to install HxCodec.
pause >nul
title FNF Setup - Installing libraries
echo Installing haxelib libraries...
haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git
cls
title FNKNGT Setup - Success
echo Setup successful. Press any key to exit.
pause >nul
exit
