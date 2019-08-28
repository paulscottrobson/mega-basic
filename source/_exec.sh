#
#		Common Linux start script
#
rm rom.bin rom.lst memory.dump 2>/dev/null
pushd scripts >/dev/null
#python ftestgen.py >../modules/testing/script.inc
#python fscript.py >../modules/testing/script.inc
popd >/dev/null

pushd tokens >/dev/null
python tokentables.py >../modules/basic/header/header.src

python basicprogram.py ../modules/basic/testcode/testcode.src
python testmath.py ../modules/basic/testcode/testing.src
python testassign.py ../modules/basic/testcode/testassign.src

popd

64tass -X -b -q basic.asm  -L rom.lst -o rom.bin
if [ $? -eq 0 ]
then
	../bin/m65816 rom.bin go
	python scripts/showxs.py
	python scripts/showv.py
fi
