module pspemu.core.gpu.Commands;

import pspemu.utils.MathUtils;
import std.string;
import std.conv;

enum Opcode : ubyte { // VideoCommand
	NOP			, // 0x00 - NOP
	VADDR			, // 0x01 - Vertex List (BASE)
	IADDR			, // 0x02 - Index List (BASE)
	Unknown0x03	, // 0x03 - 
	PRIM			, // 0x04 - Primitive Kick
	BEZIER		, // 0x05 - Bezier Patch Kick
	SPLINE		, // 0x06 - Spline Surface Kick
	BBOX			, // 0x07 - Bounding Box
	JUMP			, // 0x08 - Jump To New Address (BASE)
	BJUMP			, // 0x09 - Conditional Jump (BASE)
	CALL			, // 0x0A - Call Address (BASE)
	RET			, // 0x0B - Return From Call
	END			, // 0x0C - Stop Execution
	Unknown0x0D	, // 0x0D - 
	SIGNAL		, // 0x0E - Raise Signal Interrupt
	FINISH		, // 0x0F - Complete Rendering
	BASE			, // 0x10 - Base Address Register
	Unknown0x11	, // 0x11 - 
	VTYPE			, // 0x12 - Vertex Type
	OFFSETADDR	, // 0x13 - Offset Address (BASE)
	ORIGINADDR	, // 0x14 - Origin Address (BASE)
	REGION1		, // 0x15 - Draw Region Start
	REGION2		, // 0x16 - Draw Region End
	LTE			, // 0x17 - Lighting Enable
	LTE0			, // 0x18 - Light 0 Enable
	LTE1			, // 0x19 - Light 1 Enable
	LTE2			, // 0x1A - Light 2 Enable
	LTE3			, // 0x1B - Light 3 Enable
	CPE			, // 0x1C - Clip Plane Enable
	BCE			, // 0x1D - Backface Culling Enable
	TME			, // 0x1E - Texture Mapping Enable
	FGE			, // 0x1F - Fog Enable
	DTE			, // 0x20 - Dither Enable
	ABE			, // 0x21 - Alpha Blend Enable
	ATE			, // 0x22 - Alpha Test Enable
	ZTE			, // 0x23 - Depth Test Enable
	STE			, // 0x24 - Stencil Test Enable
	AAE			, // 0x25 - Anitaliasing Enable
	PCE			, // 0x26 - Patch Cull Enable
	CTE			, // 0x27 - Color Test Enable
	LOE			, // 0x28 - Logical Operation Enable
	Unknown0x29	, // 0x29 - 
	BOFS			, // 0x2A - Bone Matrix Offset
	BONE			, // 0x2B - Bone Matrix Upload
	MW0			, // 0x2C - Morph Weight 0
	MW1			, // 0x2D - Morph Weight 1
	MW2			, // 0x2E - Morph Weight 2
	MW3			, // 0x2F - Morph Weight 3
	MW4			, // 0x30 - Morph Weight 4
	MW5			, // 0x31 - Morph Weight 5
	MW6			, // 0x32 - Morph Weight 6
	MW7			, // 0x33 - Morph Weight 7
	Unknown0x34	, // 0x34 - 
	Unknown0x35	, // 0x35 - 
	PSUB			, // 0x36 - Patch Subdivision
	PPRIM			, // 0x37 - Patch Primitive
	PFACE			, // 0x38 - Patch Front Face
	Unknown0x39	, // 0x39 - 
	WMS			, // 0x3A - World Matrix Select
	WORLD			, // 0x3B - World Matrix Upload
	VMS			, // 0x3C - View Matrix Select
	VIEW			, // 0x3D - View Matrix upload
	PMS			, // 0x3E - Projection matrix Select
	PROJ			, // 0x3F - Projection Matrix upload
	TMS			, // 0x40 - Texture Matrix Select
	TMATRIX		, // 0x41 - Texture Matrix Upload
	XSCALE		, // 0x42 - Viewport Width Scale
	YSCALE		, // 0x43 - Viewport Height Scale
	ZSCALE		, // 0x44 - Depth Scale
	XPOS			, // 0x45 - Viewport X Position
	YPOS			, // 0x46 - Viewport Y Position
	ZPOS			, // 0x47 - Depth Position
	USCALE		, // 0x48 - Texture Scale U
	VSCALE		, // 0x49 - Texture Scale V
	UOFFSET		, // 0x4A - Texture Offset U
	VOFFSET		, // 0x4B - Texture Offset V
	OFFSETX		, // 0x4C - Viewport offset (X)
	OFFSETY		, // 0x4D - Viewport offset (Y)
	Unknown0x4E	, // 0x4E - 
	Unknown0x4F	, // 0x4F - 
	SHADE			, // 0x50 - Shade Model
	RNORM			, // 0x51 - Reverse Face Normals Enable
	Unknown0x52	, // 0x52 - 
	CMAT			, // 0x53 - Color Material
	EMC			, // 0x54 - Emissive Model Color
	AMC			, // 0x55 - Ambient Model Color
	DMC			, // 0x56 - Diffuse Model Color
	SMC			, // 0x57 - Specular Model Color
	AMA			, // 0x58 - Ambient Model Alpha
	Unknown0x59	, // 0x59 - 
	Unknown0x5A	, // 0x5A - 
	SPOW			, // 0x5B - Specular Power
	ALC			, // 0x5C - Ambient Light Color
	ALA			, // 0x5D - Ambient Light Alpha
	LMODE			, // 0x5E - Light Model
	LT0			, // 0x5F - Light Type 0
	LT1			, // 0x60 - Light Type 1
	LT2			, // 0x61 - Light Type 2
	LT3			, // 0x62 - Light Type 3
	LXP0			, // 0x63 - Light X Position 0
	LYP0			, // 0x64 - Light Y Position 0
	LZP0			, // 0x65 - Light Z Position 0
	LXP1			, // 0x66 - Light X Position 1
	LYP1			, // 0x67 - Light Y Position 1
	LZP1			, // 0x68 - Light Z Position 1
	LXP2			, // 0x69 - Light X Position 2
	LYP2			, // 0x6A - Light Y Position 2
	LZP2			, // 0x6B - Light Z Position 2
	LXP3			, // 0x6C - Light X Position 3
	LYP3			, // 0x6D - Light Y Position 3
	LZP3			, // 0x6E - Light Z Position 3
	LXD0			, // 0x6F - Light X Direction 0
	LYD0			, // 0x70 - Light Y Direction 0
	LZD0			, // 0x71 - Light Z Direction 0
	LXD1			, // 0x72 - Light X Direction 1
	LYD1			, // 0x73 - Light Y Direction 1
	LZD1			, // 0x74 - Light Z Direction 1
	LXD2			, // 0x75 - Light X Direction 2
	LYD2			, // 0x76 - Light Y Direction 2
	LZD2			, // 0x77 - Light Z Direction 2
	LXD3			, // 0x78 - Light X Direction 3
	LYD3			, // 0x79 - Light Y Direction 3
	LZD3			, // 0x7A - Light Z Direction 3
	LCA0			, // 0x7B - Light Constant Attenuation 0
	LLA0			, // 0x7C - Light Linear Attenuation 0
	LQA0			, // 0x7D - Light Quadratic Attenuation 0
	LCA1			, // 0x7E - Light Constant Attenuation 1
	LLA1			, // 0x7F - Light Linear Attenuation 1
	LQA1			, // 0x80 - Light Quadratic Attenuation 1
	LCA2			, // 0x81 - Light Constant Attenuation 2
	LLA2			, // 0x82 - Light Linear Attenuation 2
	LQA2			, // 0x83 - Light Quadratic Attenuation 2
	LCA3			, // 0x84 - Light Constant Attenuation 3
	LLA3			, // 0x85 - Light Linear Attenuation 3
	LQA3			, // 0x86 - Light Quadratic Attenuation 3
	SPOTEXP0		, // 0x87 - Spot light 0 exponent
	SPOTEXP1		, // 0x88 - Spot light 1 exponent
	SPOTEXP2		, // 0x89 - Spot light 2 exponent
	SPOTEXP3		, // 0x8A - Spot light 3 exponent
	SPOTCUT0		, // 0x8B - Spot light 0 cutoff
	SPOTCUT1		, // 0x8C - Spot light 1 cutoff
	SPOTCUT2		, // 0x8D - Spot light 2 cutoff
	SPOTCUT3		, // 0x8E - Spot light 3 cutoff
	ALC0			, // 0x8F - Ambient Light Color 0
	DLC0			, // 0x90 - Diffuse Light Color 0
	SLC0			, // 0x91 - Specular Light Color 0
	ALC1			, // 0x92 - Ambient Light Color 1
	DLC1			, // 0x93 - Diffuse Light Color 1
	SLC1			, // 0x94 - Specular Light Color 1
	ALC2			, // 0x95 - Ambient Light Color 2
	DLC2			, // 0x96 - Diffuse Light Color 2
	SLC2			, // 0x97 - Specular Light Color 2
	ALC3			, // 0x98 - Ambient Light Color 3
	DLC3			, // 0x99 - Diffuse Light Color 3
	SLC3			, // 0x9A - Specular Light Color 3
	FFACE			, // 0x9B - Front Face Culling Order
	FBP			, // 0x9C - Frame Buffer Pointer
	FBW			, // 0x9D - Frame Buffer Width
	ZBP			, // 0x9E - Depth Buffer Pointer
	ZBW			, // 0x9F - Depth Buffer Width
	TBP0			, // 0xA0 - Texture Buffer Pointer 0
	TBP1			, // 0xA1 - Texture Buffer Pointer 1
	TBP2			, // 0xA2 - Texture Buffer Pointer 2
	TBP3			, // 0xA3 - Texture Buffer Pointer 3
	TBP4			, // 0xA4 - Texture Buffer Pointer 4
	TBP5			, // 0xA5 - Texture Buffer Pointer 5
	TBP6			, // 0xA6 - Texture Buffer Pointer 6
	TBP7			, // 0xA7 - Texture Buffer Pointer 7
	TBW0			, // 0xA8 - Texture Buffer Width 0
	TBW1			, // 0xA9 - Texture Buffer Width 1
	TBW2			, // 0xAA - Texture Buffer Width 2
	TBW3			, // 0xAB - Texture Buffer Width 3
	TBW4			, // 0xAC - Texture Buffer Width 4
	TBW5			, // 0xAD - Texture Buffer Width 5
	TBW6			, // 0xAE - Texture Buffer Width 6
	TBW7			, // 0xAF - Texture Buffer Width 7
	CBP			, // 0xB0 - CLUT Buffer Pointer
	CBPH			, // 0xB1 - CLUT Buffer Pointer H
	TRXSBP		, // 0xB2 - Transmission Source Buffer Pointer
	TRXSBW		, // 0xB3 - Transmission Source Buffer Width
	TRXDBP		, // 0xB4 - Transmission Destination Buffer Pointer
	TRXDBW		, // 0xB5 - Transmission Destination Buffer Width
	Unknown0xB6	, // 0xB6 - 
	Unknown0xB7	, // 0xB7 - 
	TSIZE0		, // 0xB8 - Texture Size Level 0
	TSIZE1		, // 0xB9 - Texture Size Level 1
	TSIZE2		, // 0xBA - Texture Size Level 2
	TSIZE3		, // 0xBB - Texture Size Level 3
	TSIZE4		, // 0xBC - Texture Size Level 4
	TSIZE5		, // 0xBD - Texture Size Level 5
	TSIZE6		, // 0xBE - Texture Size Level 6
	TSIZE7		, // 0xBF - Texture Size Level 7
	TMAP			, // 0xC0 - Texture Projection Map Mode + Texture Map Mode
	TEXTURE_ENV_MAP_MATRIX, // 0xC1 - Environment Map Matrix
	TMODE			, // 0xC2 - Texture Mode
	TPSM			, // 0xC3 - Texture Pixel Storage Mode
	CLOAD			, // 0xC4 - CLUT Load
	CMODE			, // 0xC5 - CLUT Mode
	TFLT			, // 0xC6 - Texture Filter
	TWRAP			, // 0xC7 - Texture Wrapping
	TBIAS			, // 0xC8 - Texture Level Bias (???)
	TFUNC			, // 0xC9 - Texture Function
	TEC			, // 0xCA - Texture Environment Color
	TFLUSH		, // 0xCB - Texture Flush
	TSYNC			, // 0xCC - Texture Sync
	FFAR			, // 0xCD - Fog Far (???)
	FDIST			, // 0xCE - Fog Range
	FCOL			, // 0xCF - Fog Color
	TSLOPE		, // 0xD0 - Texture Slope
	Unknown0xD1	, // 0xD1 - 
	PSM			, // 0xD2 - Frame Buffer Pixel Storage Mode
	CLEAR			, // 0xD3 - Clear Flags
	SCISSOR1		, // 0xD4 - Scissor Region Start
	SCISSOR2		, // 0xD5 - Scissor Region End
	NEARZ			, // 0xD6 - Near Depth Range
	FARZ			, // 0xD7 - Far Depth Range
	CTST			, // 0xD8 - Color Test Function
	CREF			, // 0xD9 - Color Reference
	CMSK			, // 0xDA - Color Mask
	ATST			, // 0xDB - Alpha Test
	STST			, // 0xDC - Stencil Test
	SOP			, // 0xDD - Stencil Operations
	ZTST			, // 0xDE - Depth Test Function
	ALPHA			, // 0xDF - Alpha Blend
	SFIX			, // 0xE0 - Source Fix Color
	DFIX			, // 0xE1 - Destination Fix Color
	DTH0			, // 0xE2 - Dither Matrix Row 0
	DTH1			, // 0xE3 - Dither Matrix Row 1
	DTH2			, // 0xE4 - Dither Matrix Row 2
	DTH3			, // 0xE5 - Dither Matrix Row 3
	LOP			, // 0xE6 - Logical Operation
	ZMSK			, // 0xE7 - Depth Mask
	PMSKC			, // 0xE8 - Pixel Mask Color
	PMSKA			, // 0xE9 - Pixel Mask Alpha
	TRXKICK		, // 0xEA - Transmission Kick
	TRXSPOS		, // 0xEB - Transfer Source Position
	TRXDPOS		, // 0xEC - Transfer Destination Position
	Unknown0xED	, // 0xED - 
	TRXSIZE		, // 0xEE - Transfer Size
	Unknown0xEF	, // 0xEF - 
	Unknown0xF0	, // 0xF0 - 
	Unknown0xF1	, // 0xF1 - 
	Unknown0xF2	, // 0xF2 - 
	Unknown0xF3	, // 0xF3 - 
	Unknown0xF4	, // 0xF4 - 
	Unknown0xF5	, // 0xF5 - 
	Unknown0xF6	, // 0xF6 - 
	Unknown0xF7	, // 0xF7 - 
	Unknown0xF8	, // 0xF8 - 
	Unknown0xF9	, // 0xF9 - 
	Unknown0xFA	, // 0xFA - 
	Unknown0xFB	, // 0xFB - 
	Unknown0xFC	, // 0xFC - 
	Unknown0xFD	, // 0xFD - 
	Unknown0xFE	, // 0xFE - 
	Unknown0xFF	  // 0xFF - 
};

struct Command {
	union {
		uint v;
		struct {
			ubyte[3] V;
			Opcode opcode;
		}
	}
	
	uint     param16() { return v & 0xFFFF; }
	uint     param24() { return v & 0xFFFFFF; }
	float[3] float3 () { return [cast(float)V[0] / 255.0, cast(float)V[1] / 255.0, cast(float)V[2] / 255.0]; }
	float[4] float4 () { return [cast(float)V[0] / 255.0, cast(float)V[1] / 255.0, cast(float)V[2] / 255.0, 1.0]; }
	float    float1 () { return reinterpret!(float)(v << 8); }
	bool     bool1  () { return (v << 8) != 0; }

	T extract(T = uint, uint displacement = 0, ubyte numberOfBits = 0)() {
		// Detect mask from type.
		if (numberOfBits == 0) {
			return cast(T)((param24 >> displacement) & ((1 << (T.sizeof * 8)) - 1));
		}
		// Specified mask.
		else {
			return cast(T)((param24 >> displacement) & ((1 << numberOfBits) - 1));
		}
	}

	static uint minMask(uint max) {
		uint mask = 0;
		while (mask < max) {
			mask <<= 1;
			mask |= 1;
		}
		return mask;
	}

	T extractEnum(T, uint displacement = 0)() {
		return cast(T)(((param24 >> displacement) & minMask(T.max)) % (T.max + 1));
	}

	T extractSet(T, uint displacement = 0)() {
		return cast(T)((param24 >> displacement) & minMask(T.max));
	}

	float extractFixedFloat(uint displacement = 0, ubyte numberOfBits = 32)() {
		uint mask = (1 << numberOfBits) - 1;
		return cast(float)((param24 >> displacement) & mask) / cast(float)mask;
	}

	alias V byte3;

	string toString() {
		return std.string.format("Command[%08X](%02X:%s)", v, opcode, to!string(opcode));
	}
	
	static assert(this.sizeof == 4);
}
