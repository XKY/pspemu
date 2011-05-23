module pspemu.utils.Logger;

import std.string;
import std.format;
import std.stdio;
import std.conv;

class Logger {
	enum Level : ubyte { TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL, NONE }

	struct Message {
		uint   time;
		Level  level;
		string component;
		string text;
		void print() {
			synchronized (synchronizationObject) {
				stdout.writefln("%-8s: %-10d: '%s'::'%s'", to!string(level), time, component, text);
				stdout.flush();
			}
		}
	}
	
	__gshared Object synchronizationObject;
	static this() {
		synchronizationObject = new Object();
	}

	//__gshared Message[] messages;
	__gshared Level currentLogLevel = Level.NONE;
	__gshared string[] disabledLogComponents;
	__gshared string[] enabledLogComponents;
	
	static public void setLevel(Level level) {
		currentLogLevel = level;
	}
	
	static public void disableLogComponent(string componentToDisable) {
		disabledLogComponents ~= componentToDisable;
	}

	static public void enableLogComponent(string componentToEnable) {
		enabledLogComponents ~= componentToEnable;
		writefln("Enabled: %s", componentToEnable);
	}
	
	static void log(T...)(Level level, string component, T args) {
		if (level == Level.NONE) return;
		foreach (enabledLogComponent; enabledLogComponents) {
			if (component == enabledLogComponent) goto display;
			//writefln("%s, %s", component, enabledLogComponent);
		}
		if (level < currentLogLevel) return;

		if (level <= Level.INFO) {
			foreach (disabledLogComponent; disabledLogComponents) {
				if (component == disabledLogComponent) return;
			}
		}
		
		display:;

		auto message = Message(std.c.time.time(null), level, component, std.string.format(args));
		message.print();
	}
	
	template DebugLogPerComponent(string componentName) {
		void logLevel(T...)(Logger.Level level, T args) {
			Logger.log(level, componentName, args);
		}
		mixin Logger.LogPerComponent;	
	}
	
	template LogPerComponent() {
		void logTrace   (T...)(T args) { logLevel(Logger.Level.TRACE   , args); }
		void logDebug   (T...)(T args) { logLevel(Logger.Level.DEBUG   , args); }
		void logInfo    (T...)(T args) { logLevel(Logger.Level.INFO    , args); }
		void logWarning (T...)(T args) { logLevel(Logger.Level.WARNING , args); }
		void logError   (T...)(T args) { logLevel(Logger.Level.ERROR   , args); }
		void logCritical(T...)(T args) { logLevel(Logger.Level.CRITICAL, args); }
	}
}