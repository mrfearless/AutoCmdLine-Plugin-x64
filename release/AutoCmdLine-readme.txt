;=====================================================================================
;
; AutoCmdLine-readme.txt
;
; v1.0.0.3 - Last updated: 26/06/2016 
;
;-------------------------------------------------------------------------------------

About
-----

AutoCmdLine plugin for x64dbg (64bit plugin), created with the x64dbg plugin for masm
by fearless 2016 - www.LetTheLight.in

The x64dbg plugin SDK for JWasm64 can be downloaded from here:
https://bitbucket.org/mrfearless/x64dbg-plugin-sdk-for-JWasm64/overview

The x64dbg plugin SDK for Masm can be downloaded from here:
https://bitbucket.org/mrfearless/x64dbg-plugin-sdk-for-masm/overview


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


- 26/06/2016 Updated x64dbg SDK for masm to version 1.0.0.3 and recompiled plugin.
- 01/03/2016 Updated x64dbg SDK for masm to version 1.0.0.2 and recompiled plugin.
- Added function AutoCmdLineLoadMenuIcon to load png resource image as raw bytes 
- Added menu icon for plugin (uses _plugin_menuseticon)