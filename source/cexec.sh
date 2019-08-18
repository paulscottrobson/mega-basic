#
#		Build BASIC (EM4510)
#
rm memory.dump
pushd scripts
#python ftestgen.py >../modules/testing/script.inc
python fscript.py >../modules/testing/script.inc
popd
python scripts/builder.py
64tass -q -c -b basic.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../bin/m65816 rom.bin
	python scripts/showxs.py
fi
