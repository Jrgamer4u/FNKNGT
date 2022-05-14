# FNKNGT

## Credits:

### FNKNGT
- [Jrgamer4u](https://twitter.com/okobern) - Mistake
- [Pietro](https://twitter.com/AnimatedHooman) - Nice Guy

### Friday Night Funkin
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician

### hxCodec
- [PolybiusProxy](https://twitter.com/polybiusproxy) - Creator of hxCodec.
- [datee](https://twitter.com/d0oo0p) - Creator of HaxeVLC.
- [Jigsaw](https://twitter.com/jigsaw1_ma) - Android Support.
- [Erizur](https://twitter.com/am_erizur) - Linux Support.
- and Others

### Installing the Required Programs
Use the setup.bat included in the project.

If you can't open the bat file, this is the list of the required programs:

[haxe 4.1.5](https://haxe.org/download/version/4.1.5/)

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

haxelib git hxCodec https://github.com/polybiusproxy/hxCodec.git

## Notes

### Support
No versions for Mac and for x86 yet, wait for the hxcodec to add support for them.

### Deprecated Packages
If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling.

### Linux
In order to make your game work, every Linux user (this includes the player) has to download "libvlc-dev" and "libvlccore-dev" from your distro's package manager. You can also install them through the terminal:

```bash
sudo apt-get install libvlc-dev
sudo apt-get install libvlccore-dev
```

## Build instructions:

### Compiling game
Once you have all those installed, it's pretty easy to compile the game.
You just need to run `lime build html5` in the root of the project to build and run the HTML5 version.

To run it for your {{Operating System}}, it can be a bit more involved.

#### Windows
You need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads.
Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Open a terminal in the project directory and run `lime build {{OS}}`
Once that command finishes, you can run FNF under export\release\\{{OS}}\bin.
