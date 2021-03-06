;=====================================================================================
;
; AutoCmdLine-readme.txt
;
; v1.0.0.4 - Last updated: 09/08/2016 
;
;-------------------------------------------------------------------------------------

About
-----

AutoCmdLine Plugin (x64) For x64dbg (64bit plugin)
by fearless - www.LetTheLight.in

Created with the x64dbg Plugin SDK For x64 Assembler
https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x64-Assembler


Overview
--------

A plugin to remember the command line and load it up automatically


Features
--------

- Add and/or change command line
- Remember command line
- Automatically set command line  


Notes
-----

AutoCmdLine takes the modulename, the full filepath of the program that is loaded and
being debugged and creates an MD5 hash from this value.
It searches in the plugins\AutoCmdLine.ini file for a matching profile section name
and loads up the saved command line if it was set to 'remember' it.

'remember' perhaps should be named auto-load as it will auto load this command line
the next time the same module is being debugged.

Arguments on the command line should be wrapped with double quotes ""
and you should specify the fullpath for any arguments that require it.

This is to ensure compatability with windows and how it handles arguments and also 
with the way x64dbg sets the cmdline. 

- 09/08/2016 Added fix for full command line to be set, previously only saved portion was
- 26/06/2016 Updated x64dbg SDK for masm to version 1.0.0.3 and recompiled plugin.
- 01/03/2016 Updated x64dbg SDK for masm to version 1.0.0.2 and recompiled plugin.
- Added function AutoCmdLineLoadMenuIcon to load png resource image as raw bytes 
- Added menu icon for plugin (uses _plugin_menuseticon)