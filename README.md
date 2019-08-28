# 6502-Basic
Portable-ish 65C02/65C816/4510 BASIC

Want to run me ?

Well it's still under development. On Linux. So it's not that easy. I will make
it easier :)

So you may need to build the emulator in tools/emulator-65816/emulator first, 
this goes in bin as m65816. Or it might just work. SDL2, not much else. There's 
a makefile in there which will probably build it if you install Mingw32 and SDL2
(the SDL2 is in the root). I recommend chocolatey which makes Windows "almost 
useable" as I said to one of its developers. I think they knew what I meant :)

Then go into src and type python scripts/builder.py xxxx which will give you a list
of possible builds and targets. xemu and the mega65 fpga builds assume that this 
git (6502-Basic), xemu and mega65-core are all in the same directory and built.
Xemu also requires an SDcard image.

Then you type python scripts/builder.py [params] && sh _exec.sh 

The [params] are what you want to build, platform and build ; so say assn fm65 will
run the assignment test script on a mega65 FPGA board.

The standard build you can just have no parameters to builder.py

It's harder in Windows because of the source/scripts/runners/windows scripts, likewise
for MacOS though this will be much the same as the Linux ones.

