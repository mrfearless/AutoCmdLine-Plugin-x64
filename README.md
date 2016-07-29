# AutoCmdLine Plugin (x64) - A Plugin For x64dbg

![](https://github.com/mrfearless/AutoCmdLine-Plugin-x64/blob/master/images/AutoCmdLine.png) [Current version: 1.0.0.3 - Last updated: 26/06/2016](https://github.com/mrfearless/AutoCmdLine-Plugin-x64/releases/latest) For the x86 version of this plugin, visit [here](https://github.com/mrfearless/AutoCmdLine-Plugin-x86)

## Overview

A plugin to remember the command line and load it up automatically

## Features

* Add and/or change command line
* Remember command line
* Automatically set command line  

## How to install

* If x64dbg (x64dbg 64bit) is currently running, stop and exit.
* Copy the `AutoCmdLine.dp64` to your `x64dbg\x64\plugins` folder.
* Start x64dbg

## Notes

AutoCmdLine takes the modulename, the full filepath of the program that is loaded and being debugged and creates an MD5 hash from this value.
It searches in the plugins\AutoCmdLine.ini file for a matching profile section name and loads up the saved command line if it was set to 'remember' it.

'remember' perhaps should be named auto-load as it will auto load this command line the next time the same module is being debugged.

Arguments on the command line should be wrapped with double quotes "" and you should specify the fullpath for any arguments that require it.

This is to ensure compatability with windows and how it handles arguments and also with the way x64dbg sets the cmdline. 

## Information

* Written by [fearless](https://github.com/mrfearless)  - [www.LetTheLight.in](http://www.LetTheLight.in)
* Created with the [x64dbg Plugin SDK For x64 Assembler](https://github.com/mrfearless/x64dbg-Plugin-SDK-For-x64-Assembler)
* A RadASM project (.rap) is used to manage and compile the plugin. The RadASM IDE can be downloaded [here](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)
* The x64 version of this plugin uses [JWasm64](http://masm32.com/board/index.php?topic=3795.0)
* The [JWasm for RadASM package](http://masm32.com/board/index.php?topic=4162.0) is also required to build this x64 version.

## x64dbg
* [x64dbg website](http://x64dbg.com)
* [x64dbg github](https://github.com/x64dbg/x64dbg)
* [x64dbg gitter](https://gitter.im/x64dbg/x64dbg)
