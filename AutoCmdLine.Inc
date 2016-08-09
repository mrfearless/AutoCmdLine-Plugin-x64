;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2015
;
; AutoCmdLine.inc
;
;-------------------------------------------------------------------------------------
include windows.inc
include CommCtrl.inc
include shellapi.inc
include wincrypt.INC

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib shell32.lib
includelib Crypt32.Lib

AddCmdLineDlgProc               PROTO :HWND, :UINT, :WPARAM, :LPARAM
AutoCmdLineCreateHash           PROTO :QWORD, :QWORD
AutoCmdLineLoadMenuIcon         PROTO :QWORD, :QWORD

.CONST
CRLF                            TEXTEQU <13,10,0> ; carriage return and linefeed for strings that require them (GuiAddLogMessage for example) 

CRYPT_STRING_NOCRLF             EQU 40000000h

CRYPT_STRING_HEXRAW             EQU 0000000ch

ICO_AUTOCMDLINE                 EQU 100
IMG_AUTOCMDLINE                 EQU 101 ; PNG image for plugin menu icon

MENU_PLUGIN1                    EQU 1
;IDD_PluginDlg                   EQU 1000
;IDC_PLUGINDLG_OK                EQU 1001

;AddChangeCmdLine.dlg
IDD_AddCmdLine					equ 1000
IDC_LblAddCmdLineModuleFilename	equ 1001
IDC_LblAddCmdLineCommandLine	equ 1003
IDC_TxtAddCmdLineCommandLine	equ 1004
IDC_TxtAddCmdLineModuleFilename	equ 1002
IDC_BtnAddCmdLineOK				equ 1005
IDC_ChkAddCmdLineRemember		equ 1006
IDC_BtnAddCmdLineCancel			equ 1007

.DATA
align 01
szMenuPlugin1                   DB "Add/Change CmdLine...",0

szAutoCmdLineInfo               DB 13,10         
                                DB "AutoCmdLine x64dbg plugin by fearless 2015 - www.LetTheLight.in",13,10
                                DB 13,10
                                DB "AutoCmdLine Features & Usage:",13,10
                                DB " - Adds a dialog (from plugin menu) where you can see and change command line",13,10  
                                DB " - Option to remember command line for next time the same module is loaded",13,10
                                DB " - Auto sets command line when loading a module - if it was set to remember it",13,10
                                DB 13,10,0

szPluginLoaded                  DB "AutoCmdLine loaded.",CRLF
szPluginUnloaded                DB "AutoCmdLine unloaded.",CRLF
szDebuggingRequired             DB "AutoCmdLine: You need to be debugging to use this option!",CRLF
szAutoCmdLineManualChange       DB "AutoCmdLine: Command line has been changed to: ",0
szAutoCmdLineAutoChange         DB "AutoCmdLine: Command line has been automatically changed to: ",0
szAutoCmdLineRemember           DB "AutoCmdLine: Command line will be remembered: ",0
szAutoCmdLineForgotten          DB "AutoCmdLine: Command line wont be remembered (its forgotten already): ",0
szLogMsg                        DB 1024 DUP (0)



szErrorCryptHashData            DB "AutoCmdLine Error: HashData",CRLF
szErrorCryptCreateHash          DB "AutoCmdLine Error: CryptCreateHash",CRLF
szErrorCryptAcquireContext      DB "AutoCmdLine Error: CryptAcquireContext",CRLF
szErrorCryptGetHashParamSize    DB "AutoCmdLine Error: CryptGetHashParam::Size",CRLF
szErrorCryptGetHashParamVal     DB "AutoCmdLine Error: CryptGetHashParam::Value",CRLF
szCreateHashSuccess             DB "AutoCmdLine Error: CreateHash Success: ",0
szZeroLengthHash                DB "Zero Length Hash",CRLF
szErrorGlobalAlloc              DB "AutoCmdLine Error: GlobalAlloc",CRLF
szIniGetModuleCmdLine           DB "IniGetModuleCmdLine: ",0
szIniSetModuleCmdLine           DB "IniSetModuleCmdLine: ",0
szCBINITDEBUG                   DB "AutoCmdLine (MD5): ",0



szIni                           DB "ini",0
AutoCmdLineIni                  DB MAX_PATH DUP (0)
szModuleFilename                DB MAX_PATH DUP (0)
szCommandLine                   DB 1024 DUP (0)
szNewCommandLine                DB 1024 DUP (0)
dwCmdLineSize                   DD 0
dqRemember                      DQ 0

DebugFilename                   DQ 0
DebugFilenameMD5                DB 256 DUP (0)
;dbgfilename_md5ctext            MD5CTXT <>
;dbgfilename_md5chash            MD5HASH <>

szGetCmdLine                    DB "GetCommandLine",0
szIniCmdLine                    DB "CmdLine",0
szIniRemember                   DB "Remember",0           
szCRLF                          DB 13,10,0
szColon                         DB ":",0
szQuote                         DB 22h,0
szZero                          DB "0",0
szOne                           DB "1",0
szQ                             DB "?",0
szSpace                         DB " ",0
sel                             SELECTIONDATA <>

.DATA?
align 08
hInstance                       HINSTANCE ?
hIcoAutoCmdLine                 DD ?
