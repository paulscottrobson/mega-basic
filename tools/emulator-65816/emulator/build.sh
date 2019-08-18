#
#			Build 65816-Based emulator
#
cp ../core/65816.* ../core/65816core.c ../core/traps.h .
make -f makefile.linux
cp m65816 ../../../bin

64tass -x -Wall --ascii -b -f  test.asm -o test.rom
if [ -e test.rom ]
then
./m65816 test.rom
fi
