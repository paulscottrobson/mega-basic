#
#		Build BASIC (EM4510)
#
rm dump.mem memory.dump uart.sock
#pushd scripts
#python ftestgen.py >../testing/script.inc
#python fscript.py >../testing/script.inc
#popd
#pushd ../emulator
#sh build.sh
#popd
python scripts/builder.py
64tass -q -c -b basic.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../bin/m65816 rom.bin
	python scripts/showxs.py
fi
