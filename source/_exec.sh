rm rom.bin rom.lst memory.dump 2>/dev/null
pushd scripts >/dev/null
python ftestgen.py >../modules/testing/script.inc
#python fscript.py >../modules/testing/script.inc
popd >/dev/null
python scripts/builder.py
64tass -b -q basic.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../bin/m65816 rom.bin go
	python scripts/showxs.py
fi
