rm rom.bin rom.lst memory.dump 2>/dev/null
pushd scripts >/dev/null
python ftestgen.py >../modules/testing/script.inc
#python fscript.py >../modules/testing/script.inc
popd >/dev/null

pushd tokens >/dev/null
python tokentables.py >../modules/basic/header/header.src
python basicprogram.py ../modules/basic/testcode/testcode.src
python testcreate.py ../modules/basic/testcode/testing.src
popd

64tass -X -b -q basic.asm  -L rom.lst -o rom.bin
truncate rom.bin -s 131072
if [ $? -eq 0 ]
then
	../../xemu/build/bin/xmega65.native -loadrom rom.bin -forcerom 1>/dev/null
fi
