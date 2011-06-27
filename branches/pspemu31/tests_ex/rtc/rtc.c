//#pragma compile, "%PSPSDK%/bin/psp-gcc" -I. -I"%PSPSDK%/psp/sdk/include" -L. -L"%PSPSDK%/psp/sdk/lib" -D_PSP_FW_VERSION=150 -Wall -g rtc.c ../common/emits.c -lpspsdk -lc -lpspuser -lpspkernel -lpsprtc -o rtc.elf
//#pragma compile, "%PSPSDK%/bin/psp-fixup-imports" rtc.elf

#include <pspkernel.h>
#include <psprtc.h>

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

//#include "../common/emits.h"

PSP_MODULE_INFO("rtctest", 0, 1, 1);
PSP_MAIN_THREAD_ATTR(THREAD_ATTR_USER);

/**
 * Check that getCurrentTick works fine.
 *
 * @TODO: Currently sceKernelDelayThread only work with ms.
 *        It should check that work with microseconds precission.
 */
void checkGetCurrentTick() {
	u64 tick0, tick1;
	int microseconds = 2 * 1000; // 2ms

	Kprintf("Checking sceRtcGetCurrentTick\n");

	sceRtcGetCurrentTick(&tick0);
	{
		sceKernelDelayThread(microseconds);
	}
	sceRtcGetCurrentTick(&tick1);
	
	Kprintf("%d\n", (tick1 - tick0) >= microseconds);
}

void checkDaysInMonth() {
	Kprintf("Checking sceRtcGetDaysInMonth\n");
	Kprintf("sceRtcGetDaysInMonth:2010, 4\n");
	Kprintf("%d\n", sceRtcGetDaysInMonth(2010, 4));
}

void checkDayOfWeek() {
	Kprintf("Checking sceRtcGetDayOfWeek\n");
	Kprintf("sceRtcGetDayOfWeek:2010, 4, 27\n");
	Kprintf("%d\n", sceRtcGetDayOfWeek(2010, 4, 27));
}

int main() {
	checkGetCurrentTick();
	checkDaysInMonth();
	checkDayOfWeek();
	
	return 0;
}
