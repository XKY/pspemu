module pspemu.core.cpu.interpreter.Utils;

enum Advance { NO, YES }
enum : bool { Unsigned, Signed }	
enum Sign : bool { Unsigned, Signed }	

T1 reinterpret(T1, T2)(T2 v) { return *cast(T1 *)&v; }

// $rd = cast(uint)registers.R[instruction.RD]
// #rt = cast( int)registers.R[instruction.RT]
string CpuExpression(string s, Advance advancePC = Advance.YES) {
	string r = "";
	for (int n = 0; n < s.length; n++) {
		if (s[n] == '$' || s[n] == '#') {
			string add = "";
			bool replace = true;
			bool signed = false;
			signed = (s[n] == '#');
			if (signed) add ~= "cast(int)";
			switch (s[n + 1..n + 3]) {
				case "fs": add ~= "registers.F[instruction.FS]"; break;
				case "fd": add ~= "registers.F[instruction.FD]"; break;
				case "ft": add ~= "registers.F[instruction.FT]"; break;
				case "Fs": add ~= "registers.RF[instruction.FS]"; break;
				case "Fd": add ~= "registers.RF[instruction.FD]"; break;
				case "Ft": add ~= "registers.RF[instruction.FT]"; break;
				case "rs": add ~= "registers.R[instruction.RS]"; break;
				case "rd": add ~= "registers.R[instruction.RD]"; break;
				case "rt": add ~= "registers.R[instruction.RT]"; break;
				case "im": add ~= signed ? "instruction.IMM" : "instruction.IMMU"; break;
				case "ps": add ~= "instruction.POS"; break;
				case "ne": add ~= "instruction.SIZE_E"; break;
				case "ni": add ~= "instruction.SIZE_I"; break;
				case "hi": add ~= "registers.HI"; break;
				case "lo": add ~= "registers.LO"; break;
				case "hl": add ~= "registers.HILO"; break;
				case "00": add ~= "registers.FCR0.VALUE"; break;
				case "cc": add ~= "registers.FCR31.C"; break;
				case "31": add ~= "registers.FCR31.VALUE"; break;
				default:
					replace = false;
					r ~= s[n];
				break;
			}
			if (replace) {
				r ~= "(" ~ add ~ ")";
				n += 2;
			}
		} else {
			r ~= s[n];
		}
	}
	if (advancePC) r ~= "registers.pcAdvance(4);";
	return r;
}

alias CpuExpression CE;
