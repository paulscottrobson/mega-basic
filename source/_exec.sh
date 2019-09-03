#
#		Common Linux start script
#
rm rom.bin rom.lst memory.dump 2>/dev/null
#
#		Build tokens
#
pushd tokens >/dev/null
python tokentables.py >../modules/basic/header/header.src
#
#		Generate various test scripts
#
python basicprogram.py ../modules/basic/testcode/testcode.src
python testmath.py ../modules/basic/testcode/testing.src
python testassign.py ../modules/basic/testcode/testassign.src

popd

64tass -X -Wall -b -q basic.asm  -L rom.lst -o rom.bin
truncate rom.bin -s 131072
if [ $? -eq 0 ]
then
	../../xemu/build/bin/xmega65.native -loadrom rom.bin -forcerom 1>/dev/null
fi
