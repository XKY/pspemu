# http://pspemu.soywiz.com/2012/02/new-version-soywizs-psp-emulator-2012.html #
## Official Site: http://pspemu.soywiz.com/ ##

http://www.digitalmars.com/d/archives/digitalmars/D/PSP_emulator_written_in_D_142107.html

https://github.com/soywiz/pspemu

![http://2.bp.blogspot.com/-8Y0vetLguCk/TgXA46tVfJI/AAAAAAAADUc/3LB0P0s8Y54/s1600/astonishia_story.jpg](http://2.bp.blogspot.com/-8Y0vetLguCk/TgXA46tVfJI/AAAAAAAADUc/3LB0P0s8Y54/s1600/astonishia_story.jpg)

## Current version is [r302](https://code.google.com/p/pspemu/source/detail?r=302) ##

## Motivation ##

This project aims making an emulator using D language. I started it in order to practice D, use D features and learn about the PSP hardware and software.
It pretends to be a simple but somehow pretty-fast interpreted implementation.
It also aims to spread over the world that D is a very good compiled language. It's fast like C but it feels like Java or C#.

## New version: ##

<wiki:gadget url="http://hosting.gmodules.com/ig/gadgets/file/101638777846294812126/2.xml" width="380" height="400" up\_url="http://blog.cballesterosvelasco.es/category/pspemu/feed/" up\_style="1" up\_articles="04" up\_date=1 up\_size=100 up\_sort=1 up\_acolor="#00c" up\_color="#333333" up\_ads=0 up\_title="Spanish D PSP Emulator Blog" width="100%" height="200" />


## Old version ##

This is a proof of concept I made of a PSP Emulator with a debugger using [D programming language](http://digitalmars.com/d/) (Walter Bright) and [DFL library](http://www.dprogramming.com/dfl.php) (Chris Miller).

This emulator is based in another great opensource emulator [psplayer](http://code.google.com/p/pspplayer/) (Noxa) and the laudable work of [ps2dev](http://ps2dev.org/) community. Demos included are part of the pspsdk.

## Information ##

&lt;wiki:gadget url="http://www.ohloh.net/p/441191/widgets/project\_languages.xml" border="0" width="330" height="180" /&gt;
&lt;wiki:gadget url="http://www.ohloh.net/p/441191/widgets/project\_basic\_stats.xml" height="220" border="1" /&gt;
&lt;wiki:gadget url="http://www.ohloh.net/p/441191/widgets/project\_cocomo.xml" height="240" border="0"/&gt;

## Other psp emulators ##

  * http://code.google.com/p/jpcsp/
  * http://code.google.com/p/emu-sam/
  * http://code.google.com/p/pcsp/
  * http://code.google.com/p/pspplayer/
  * http://code.google.com/p/mfzpsp/

## Useful/Interesting/Random Links ##

  * http://minpspw.sourceforge.net/archives/cat_llvm.html
  * http://hitmen.c02.at/files/yapspd/psp_doc/
  * http://www.dsource.org/projects/ldc
  * http://www.dprogramming.com/dfl.php
  * http://www.digitalmars.com/d/2.0/
  * http://dsource.org/projects/
  * http://ddbg.mainia.de/releases.html
  * http://d-ide.sourceforge.net/
  * http://forums.qj.net/psp-development-forum/142864-how-program-d-psptoolchain-gdc.html
  * http://dblog.aldacron.net/2010/04/19/visual-d/

## Stack Trace using DDBG ##
```
dmd\windows\bin\ddbg -cmd "r;us;q" pspemu.exe %*

...
Loader.load Exception: object.Exception: Not implemented relocation yet.
Unhandled D Exception (object.Exception
 "Not implemented relocation yet.") at KERNELBASE.dll (0x7660b727) thread(984)
->us
#0 ?? () at pspemu\hle\Loader.d:162 from KERNELBASE.dll
#1 0x0049447c in __d_throw@4 () at pspemu\hle\Loader.d:162 from deh
#2 0x0041c578 in _D6pspemu3hle6Loader6Loader4loadMFAyaZv () at pspemu\hle\Loader.d:162
#3 0x004a2974 in extern (C) int rt.dmain2.main(int, char**) . void runMain(void*) () from dmain2
#4 0x004a29b1 in extern (C) int rt.dmain2.main(int, char**) . void runAll(void*) () from dmain2
#5 0x004a2724 in _main () from dmain2
#6 0x00519f85 in _mainCRTStartup () from constart
#7 0x74df3677 in ?? () from KERNEL32.dll
#8 0x77199d72 in ?? () from ntdll.dll
#9 0x77199d45 in ?? () from ntdll.dll
```