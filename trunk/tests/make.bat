@ECHO OFF
REM http://minpspw.sourceforge.net/
SET PSPSDK=%CD%/../dmd/pspsdk
SET LIBS=-lpspgum -lpspgu -lm -lpsprtc -lpspdebug -lpspdisplay -lpspge -lpspctrl -lpspsdk -lc -lpspnet -lpspnet_inet -lpspnet_apctl -lpspnet_resolver -lpsputility -lpspuser -lpspkernel
REM SET FLAGS=-G0 -Wall -O2 -g -gstabs
SET FLAGS=-Wall -g

CALL :BUILD test_sprintf
CALL :BUILD test1
CALL :BUILD test2
CALL :BUILD ortho "common/callbacks.o common/vram.o"

EXIT /B

:BUILD
	SET BASE=%1
	SET PARAMS=%~2
	c:\pspsdk\bin\psp-gcc -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 %FLAGS% %BASE%.c %PARAMS% %LIBS% -o %BASE%.elf
	c:\pspsdk\bin\psp-fixup-imports %BASE%.elf
	IF EXIST STRIP_ELF (
		c:\pspsdk\bin\psp-strip %BASE%.elf
	)
EXIT /B