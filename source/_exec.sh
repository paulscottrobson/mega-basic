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
python testtokenise.py >../modules/basic/tokenise/testing/tokentest.src

popd

64tass -X -Wall -b -q basic.asm  -L rom.lst -o rom.bin
truncate rom.bin -s 131072
if [ $? -eq 0 ]
then
	../../mega65-core/src/tools/monitor_load -b ../documents/nexys4ddr.bit -p -R rom.bin -k ../documents/hickup.m65 
	rm rom.lst rom.bin
fi
