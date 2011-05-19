module pspemu.hle.kd.rtc.sceRtc; // kd/rtc.prx (sceRTC_Service)

import std.stdio;

import pspemu.hle.ModuleNative;

import std.datetime;

import pspemu.hle.kd.rtc.Types;

// http://pspemu.googlecode.com/svn-history/r166/trunk/extra/psp-gdc/pspsdk/psprtc.d

class sceRtc : ModuleNative {
	void initNids() {
		mixin(registerd!(0xC41C2853, sceRtcGetTickResolution));
		mixin(registerd!(0x3F7AD767, sceRtcGetCurrentTick));
		mixin(registerd!(0x05EF322C, sceRtcGetDaysInMonth));
		mixin(registerd!(0x57726BC1, sceRtcGetDayOfWeek));
		mixin(registerd!(0x26D25A5D, sceRtcTickAddMicroseconds));

		mixin(registerd!(0x44F45E05, sceRtcTickAddTicks));
		mixin(registerd!(0x6FF40ACC, sceRtcGetTick));
		mixin(registerd!(0x7ED29E40, sceRtcSetTick));
		mixin(registerd!(0xE7C27D1B, sceRtcGetCurrentClockLocalTime));
		
		mixin(registerd!(0x34885E0D, sceRtcConvertUtcToLocalTime));

		mixin(registerd!(0x27C4594C, sceRtcGetTime_t));
	}

	/**
	 * Convert a UTC-based tickcount into a local time tick count
	 *
	 * @param tickUTC   - pointer to u64 tick in UTC time
	 * @param tickLocal - pointer to u64 to receive tick in local time
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcConvertUtcToLocalTime(u64* tickUTC, u64* tickLocal) {
		throw(new NotImplementedException("sceRtcConvertUtcToLocalTime"));
		//*tickLocal = dtime_to_tick(std.date.UTCtoLocalTime(tick_to_dtime(*tickUTC)));
		//return 0;
	}

	/**
	 * Add two ticks
	 *
	 * @param destTick - pointer to tick to hold result
	 * @param srcTick  - pointer to source tick
	 * @param numTicks - number of ticks to add
	 *
	 * @return 0 on success, <0 on error
	 */
	int sceRtcTickAddTicks(ulong* destTick, ulong* srcTick, ulong numTicks) {
		*destTick = *srcTick + numTicks;
		return 0;
	}

	/**
	 * Set ticks based on a pspTime struct
	 *
	 * @param date - pointer to pspTime to convert
	 * @param tick - pointer to tick to set
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetTick(pspTime* date, ulong* tick) {
		try {
			*tick = date.tick;
			return 0;
		} catch {
			*tick = 0;
			return -1;
		}
	}

	/**
	 * Set a pspTime struct based on ticks
	 *
	 * @param date - pointer to pspTime struct to set
	 * @param tick - pointer to ticks to convert
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcSetTick(pspTime* date, ulong* tick) {
		date.parse(*tick);
		return 0;
	}

	/**
	 * Get current local time into a pspTime struct
	 *
	 * @param time - pointer to pspTime struct to receive time
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentClockLocalTime(pspTime *time) {
		ulong currentTick;
		sceRtcGetCurrentTick(&currentTick);
		sceRtcSetTick(time, &currentTick);
		return 0;
	}

	/**
	 * Get the resolution of the tick counter
	 *
	 * @return # of ticks per second
	 */
	u32 sceRtcGetTickResolution() {
		return cast(uint)std.datetime.convert!("seconds", "usecs")(1);
	}

	/**
	 * Add an amount of ms to a tick
	 *
	 * @param destTick - pointer to tick to hold result
	 * @param srcTick  - pointer to source tick
	 * @param numMS    - number of ms to add
	 *
	 * @return 0 on success, <0 on error
	 */
	int sceRtcTickAddMicroseconds(ulong* destTick, ulong* srcTick, ulong numMS) {
		return sceRtcTickAddTicks(destTick, srcTick, std.datetime.convert!("msecs", "usecs")(numMS));
	}

	/**
	 * Get current tick count
	 *
	 * @param tick - pointer to u64 to receive tick count
	 *
	 * @return 0 on success, < 0 on error
	 */
	int sceRtcGetCurrentTick(ulong* tick) {
		*tick = systime_to_tick(Clock.currTime(UTC()));
		return 0;
	}

	/**
	 * Get number of days in a specific month
	 *
	 * @param year  - year in which to check (accounts for leap year)
	 * @param month - month to get number of days for
	 *
	 * @return # of days in month, <0 on error (?)
	 */
	int sceRtcGetDaysInMonth(int year, int month) {
		return Date(year, month, 1).endOfMonthDay;
	}

	/**
	 * Get day of the week for a date
	 *
	 * @param year  - year in which to check (accounts for leap year)
	 * @param month - month that day is in
	 * @param day   - day to get day of week for
	 *
	 * @return day of week with 0 representing Monday
	 */
	int sceRtcGetDayOfWeek(int year, int month, int day) {
		return (DateTime(year, month, day).dayOfWeek + 6) % 7;
	}
	
	int sceRtcGetTime_t(pspTime* date, time_t* time) {
		// @TODO: check!
		throw(new NotImplementedException("sceRtcGetTime_t(pspTime* date, time_t* time)"));
		//tick_to_systime(date.tick);
		
		//*time = cast(time_t)(cast(ulong)tick_to_dtime(date.tick) / 1000);
		//return 0;
	}
}

static this() {
	mixin(ModuleNative.registerModule("sceRtc"));
}
