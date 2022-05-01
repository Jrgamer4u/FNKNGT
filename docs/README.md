# FNKNGT

## Credits:
<br>

### FNKNGT
- [Jrgamer4u](https://twitter.com/okobern) - Mistake
- [Pietro](https://twitter.com/AnimatedHooman) - Nice Guy
<br><br>

### Friday Night Funkin
- [ninjamuffin99](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician
<br><br>

### hxCodec
- [PolyProxy](https://twitter.com/polybiusproxy) - Creator of hxCodec.
- [Datee](https://twitter.com/d0oo0p) - Creator of HaxeVLC.
- [BrightFyre](https://twitter.com/fyre_bright) - Creator of repository.
- [GWebDev](https://twitter.com/GWebDevFNF) - Inspiring PolybiusProxy
- [CryBit](https://twitter.com/cry_bit) - Fixing PolybiusProxy's Code
- [Jigsaw](https://twitter.com/jigsaw1_ma) - for the Android port
- and Others
<br><br>

### Installing the Required Programs
Use the setup.bat included in the project.
<br>

<h2>Linux</h2>
<b>
To run the .bat file, run the following command:</b>

```bash
sudo apt install dosbox
```
<b>In order to make your game work, every Linux user (this includes the player) has to download "libvlc-dev" and "libvlccore-dev" from your distro's package manager. You can also install them through the terminal:</b>

```bash
sudo apt-get install libvlc-dev
sudo apt-get install libvlccore-dev
```


## Notes

### Note 1
<b>no version for Mac and no version for x86 yet.</b>
use the [Other Branch](https://github.com/Jrgamer4u/FNKNGT/tree/non-Windows) for now.
<br><br>

### Note 2
<b>If you see any messages relating to deprecated packages, ignore them. They're just warnings that don't affect compiling</b>
<br><br>

## Build instructions:
<br>

### Compiling game

Once you have all those installed, it's pretty easy to compile the game.
You just need to run `lime test html5 -debug` in the root of the project to build and run the HTML5 version.

To run it from your desktop (Linux, Mac, Windows) it can be a bit more involved.

For Linux, you only need to open a terminal in the project directory and run `lime test linux -debug` and then run the executable file in export/release/linux/bin.

As for Mac, `lime test mac -debug` should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads.
Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Once that is done you can open up a command line in the project's directory and run `lime test windows -debug`.
Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
