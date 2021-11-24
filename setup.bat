@echo off
title FNKNGT Setup - Start
echo Make sure Haxe 4.1.5 and HaxeFlixel is installed (4.1.5 is important)!
echo Press any key to install required libraries.
pause >nul
title FNKNGT Setup - Installing libraries
echo Installing haxelib libraries...
haxelib install lime 7.8.0
haxelib install openfl
haxelib install flixel 4.8.1
haxelib install flixel-ui
haxelib install hscript
haxelib run lime setup
haxelib install flixel-tools
haxelib run flixel-tools setup
cls
echo Make sure you have git installed. You can download it here: https://git-scm.com/downloads
pause >nul
title FNKNGT Setup - Installing libraries
echo Installing haxelib git libraries...
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons
haxelib git polymod https://github.com/larsiusprime/polymod.git
cls
title FNKNGT Setup - Success
echo Setup successful. Press any key to exit.
pause >nul
exit
