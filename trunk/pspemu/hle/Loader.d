module pspemu.hle.Loader;

//version = DEBUG_LOADER;

import std.stream, std.stdio, std.string;

import pspemu.utils.Utils;

import pspemu.formats.Elf;
import pspemu.formats.ElfDwarf;
import pspemu.formats.Pbp;

import pspemu.hle.Module;
import pspemu.hle.kd.iofilemgr;
import pspemu.hle.kd.sysmem;

import pspemu.core.Memory;
import pspemu.core.cpu.Cpu;
import pspemu.core.cpu.Assembler;
import pspemu.core.cpu.Instruction;
import pspemu.core.cpu.InstructionCounter;

import pspemu.models.IDebugSource;

import std.xml;

version (unittest) {
	import pspemu.utils.SparseMemory;
}

class Loader : IDebugSource {
	enum ModuleFlags : ushort {
		User   = 0x0000,
		Kernel = 0x1000,
	}

	enum LibFlags : ushort {
		DirectJump = 0x0001,
		Syscall    = 0x4000,
		SysLib     = 0x8000,
	}

	static struct ModuleExport {
		uint   name;         /// Address to a stringz with the module.
		ushort _version;     ///
		ushort flags;        ///
		byte   entry_size;   ///
		byte   var_count;    ///
		ushort func_count;   ///
		uint   exports;      ///

		// Check the size of the struct.
		static assert(this.sizeof == 16);
	}

	static struct ModuleImport {
		uint   name;           /// Address to a stringz with the module.
		ushort _version;       /// Version of the module?
		ushort flags;          /// Flags for the module.
		byte   entry_size;     /// ???
		byte   var_count;      /// 
		ushort func_count;     /// 
		uint   nidAddress;     /// Address to the nid pointer. (Read)
		uint   callAddress;    /// Address to the function table. (Write 16 bits. jump/syscall)

		// Check the size of the struct.
		static assert(this.sizeof == 20);
	}
	
	static struct ModuleInfo {
		uint flags;     ///
		char[28] name;      /// Name of the module.
		uint gp;            /// Global Pointer initial value.
		uint exportsStart;  ///
		uint exportsEnd;    ///
		uint importsStart;  ///
		uint importsEnd;    ///

		// Check the size of the struct.
		static assert(this.sizeof == 52);
	}

	Elf elf;
	ElfDwarf dwarf;
	Cpu cpu;
	Memory memory() { return cpu.memory; }
	ModuleInfo moduleInfo;
	ModuleImport[] moduleImports;
	ModuleExport[] moduleExports;
	
	this(string file, Cpu cpu) {
		file = file.replace("\\", "/");
		string path = ".";
		int index = file.lastIndexOf("/");
		if (index != -1) path = file[0..index];
		Module.loadModuleEx!(IoFileMgrForUser).setVirtualDir(path);
		this(new BufferedFile(file, FileMode.In), cpu);
	}

	this(Stream stream, Cpu cpu) {
		while (true) {
			auto magics = new SliceStream(stream, 0, 4);
			switch (magics.readString(4)) {
				case "\x7FELF":
				break;
				case "~PSP":
					throw(new Exception("Not support compressed elf files"));
				break;
				case "\0PBP":
					stream = (new Pbp(stream))["psp.data"];
					continue;
				break;
				default:
					throw(new Exception("Unknown file type"));
				break;
			}
			break;
		}

		this.elf = new Elf(stream);
		this.cpu = cpu;
		version (DEBUG_LOADER) {
			elf.dumpSections();
		}
		try {
			load();
		} catch (Object o) {
			writefln("Loader.load Exception: %s", o);
			throw(o);
		}
		version (DEBUG_LOADER) {
			count();
			Module.dumpKnownModules();
		}
		checkDebug();
		//(new std.stream.File("debug_str", FileMode.OutNew)).copyFrom(elf.SectionStream(".debug_str"));
	}
	
	void checkDebug() {
		try {
			dwarf = new ElfDwarf;
			dwarf.parseDebugLine(elf.SectionStream(".debug_line"));
			dwarf.find(0x089004C8);
			cpu.debugSource = this;
		} catch (Object o) {
			writefln("Can't find debug information: '%s'", o.toString);
		}
	}

	bool lookupDebugSourceLine(ref DebugSourceLine debugSourceLine, uint address) {
		if (dwarf is null) return false;
		auto state = dwarf.find(address);
		if (state is null) return false;
		debugSourceLine.file    = state.file_full_path;
		debugSourceLine.address = state.address;
		debugSourceLine.line    = state.line;
		return true;
	}

	bool lookupDebugSymbol(ref DebugSymbol debugSymbol, uint address) {
		return false;
	}

	void count() {
		try {
			auto counter = new InstructionCounter;
			counter.count(elf.SectionStream(".text"));
			counter.dump();
		} catch (Object o) {
			writefln("Can't count instructions: '%s'", o.toString);
		}
	}

	void allocatePartitionBlock() {
		Memory memory = cast(Memory)this.memory;

		// Not a Memory supplied.
		if (memory is null) {
			return;
		}

		auto sysMemUserForUser = Module.loadModuleEx!(SysMemUserForUser);
		//writefln("%08X", memory.getPointer(this.elf.suggestedBlockAddress));
		auto blockid = sysMemUserForUser.sceKernelAllocPartitionMemory(2, "Main Program", PspSysMemBlockTypes.PSP_SMEM_Addr, this.elf.requiredBlockSize, this.elf.suggestedBlockAddress);
		uint blockaddress = sysMemUserForUser.sceKernelGetBlockHeadAddr(blockid);

		writefln("suggestedBlockAddress:%08X", this.elf.suggestedBlockAddress);
		writefln("requiredBlockSize:%08X", this.elf.requiredBlockSize);
		writefln("allocatedIn:%08X", blockaddress);
	}

	void load() {
		allocatePartitionBlock();

		this.elf.writeToMemory(memory);
		readInplace(moduleInfo, elf.SectionStream(".rodata.sceModuleInfo"));
		
		auto importsStream = new SliceStream(memory, moduleInfo.importsStart, moduleInfo.importsEnd);
		auto exportsStream = new SliceStream(memory, moduleInfo.exportsStart, moduleInfo.exportsEnd);
		
		// Load Imports.
		version (DEBUG_LOADER) writefln("Imports (0x%08X-0x%08X):", moduleInfo.importsStart, moduleInfo.importsEnd);
		auto assembler = new AllegrexAssembler(memory);

		uint unimplementedNids = 0;

		while (!importsStream.eof) {
			auto moduleImport = read!(ModuleImport)(importsStream);
			auto moduleImportName = moduleImport.name ? readStringz(memory, moduleImport.name) : "<null>";
			//assert(moduleImport.entry_size == moduleImport.sizeof);
			version (DEBUG_LOADER) writefln("  '%s'", moduleImportName);
			moduleImports ~= moduleImport;
			auto nidStream  = new SliceStream(memory, moduleImport.nidAddress , moduleImport.nidAddress  + moduleImport.func_count * 4);
			auto callStream = new SliceStream(memory, moduleImport.callAddress, moduleImport.callAddress + moduleImport.func_count * 8);
			//writefln("%08X", moduleImport.callAddress);
			auto pspModule = Module.loadModule(moduleImportName);
			while (!nidStream.eof) {
				uint nid = read!(uint)(nidStream);
				
				if (nid in pspModule.nids) {
					version (DEBUG_LOADER) writefln("    %s", pspModule.nids[nid]);
					callStream.write(cast(uint)(0x0000000C | (0x2307 << 6)));
					callStream.write(cast(uint)cast(void *)&pspModule.nids[nid]);
				} else {
					version (DEBUG_LOADER) writefln("    0x%08X", nid);
					callStream.write(cast(uint)(0x70000000));
					callStream.write(cast(uint)0);
					unimplementedNids++;
				}
				//writefln("++");
				//writefln("--");
			}
		}
		
		if (unimplementedNids > 0) {
			throw(new Exception(std.string.format("Several unimplemented NIds. (%d)", unimplementedNids)));
		}
		// Load Exports.
		version (DEBUG_LOADER) writefln("Exports (0x%08X-0x%08X):", moduleInfo.exportsStart, moduleInfo.exportsEnd);
		while (!exportsStream.eof) {
			auto moduleExport = read!(ModuleExport)(exportsStream);
			auto moduleExportName = moduleExport.name ? readStringz(memory, moduleExport.name) : "<null>";
			version (DEBUG_LOADER) writefln("  '%s'", moduleExportName);
			moduleExports ~= moduleExport;
		}
	}

	void setRegisters() {
		uint PC() { return elf.header.entryPoint; }
		uint GP() { return moduleInfo.gp; }

		auto sysMemUserForUser = Module.loadModuleEx!(SysMemUserForUser);
		//writefln("%08X", memory.getPointer(this.elf.suggestedBlockAddress));
		//uint stacksize = 0x8000; // 32 KB
		uint stacksize = 0x40000; // 256 KB
		uint stackaddress = sysMemUserForUser.sceKernelGetBlockHeadAddr(sysMemUserForUser.sceKernelAllocPartitionMemory(2, "Main Stack", PspSysMemBlockTypes.PSP_SMEM_High, stacksize, 0));
		//uint stackaddress = sysMemUserForUser.sceKernelGetBlockHeadAddr(sysMemUserForUser.sceKernelAllocPartitionMemory(2, "Main Stack", PspSysMemBlockTypes.PSP_SMEM_Addr, stacksize, 0x09F00000));

		cpu.registers.pcSet = PC;
		cpu.registers["gp"] = GP;
		cpu.registers["sp"] = stackaddress + stacksize - 0x10;
		cpu.registers["k0"] = cpu.registers["sp"];
		cpu.registers["ra"] = 0;
		cpu.registers["a0"] = 0; // argumentsLength.
		cpu.registers["a1"] = 0; // argumentsPointer

		writefln("PC: %08X", cpu.registers.PC);
		writefln("GP: %08X", cpu.registers["gp"]);
		writefln("SP: %08X", cpu.registers["sp"]);
	}
}

/*
unittest {
	const testPath = "demos";
	auto memory = new SparseMemoryStream;
	try {
		auto loader = new Loader(
			new BufferedFile(testPath ~ "/controller.elf", FileMode.In),
			memory
		);
	} finally {
		//memory.smartDump();
	}

	//assert(0);
}
*/
