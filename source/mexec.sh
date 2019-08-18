#
#		Run BASIC (XEMU)
#
rm dump.mem memory.dump uart.sock
pushd scripts
python ftestgen.py >../testing/script.inc
#python fscript.py >../testing/script.inc
popd
64tass --m4510  -D CPU=4510 -D INTERFACE=2 -b basic.asm  -L rom.lst -o rom.bin
truncate rom.bin -s 131072
if [ $? -eq 0 ]
then
	../../xemu/build/bin/xmega65.native -loadrom rom.bin -forcerom 1>/dev/null
	rm rom.lst rom.bin
fi
