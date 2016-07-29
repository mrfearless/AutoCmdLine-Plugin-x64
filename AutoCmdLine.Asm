;=====================================================================================
; x64dbg plugin SDK for Masm - fearless 2015
;
; AutoCmdLine.asm
;
;-------------------------------------------------------------------------------------
.686
.MMX
.XMM
.x64

option casemap : none
option win64 : 11
option frame : auto
option stackbase : rsp

_WIN64 EQU 1
WINVER equ 0501h

Include x64dbgpluginsdk.inc               ; Main x64dbg Plugin SDK for your program, and prototypes for the main exports 

Include AutoCmdLine.inc                   ; plugin's include file
Include AutoCmdLineIni.asm

pluginit	        PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
plugstop            PROTO                   ; Required prototype and export for x64dbg plugin SDK
plugsetup           PROTO :QWORD            ; Required prototype and export for x64dbg plugin SDK
;=====================================================================================


.CONST
PLUGIN_VERSION      EQU 1

.DATA
align 01
PLUGIN_NAME         DB "AutoCmdLine",0

.DATA?
;-------------------------------------------------------------------------------------
; GLOBAL Plugin SDK variables
;-------------------------------------------------------------------------------------
align 08

PUBLIC              pluginHandle
PUBLIC              hwndDlg
PUBLIC              hMenu
PUBLIC              hMenuDisasm
PUBLIC              hMenuDump
PUBLIC              hMenuStack

pluginHandle        DD ?
hwndDlg             DQ ?
hMenu               DD ?
hMenuDisasm         DD ?
hMenuDump           DD ?
hMenuStack          DD ?
;-------------------------------------------------------------------------------------


.CODE

;=====================================================================================
; Main entry function for a DLL file  - required.
;-------------------------------------------------------------------------------------
DllMain PROC hInst:HINSTANCE, fdwReason:DWORD, lpvReserved:LPVOID
    .IF fdwReason == DLL_PROCESS_ATTACH
        mov rax, hInst
        mov hInstance, rax
    .ENDIF
    mov rax,TRUE
    ret
DllMain Endp


;=====================================================================================
; pluginit - Called by debugger when plugin.dp64 is loaded - needs to be EXPORTED
; 
; Arguments: initStruct - a pointer to a PLUG_INITSTRUCT structure
;
; Notes:     you must fill in the pluginVersion, sdkVersion and pluginName members. 
;            The pluginHandle is obtained from the same structure - it may be needed in
;            other function calls.
;
;            you can call your own setup routine from within this function to setup 
;            menus and commands, and pass the initStruct parameter to this function.
;
;-------------------------------------------------------------------------------------
pluginit PROC FRAME USES RBX initStruct:QWORD
    mov rbx, initStruct

    ; Fill in required information of initStruct, which is a pointer to a PLUG_INITSTRUCT structure
    mov eax, PLUGIN_VERSION
    mov [rbx].PLUG_INITSTRUCT.pluginVersion, eax
    mov eax, PLUG_SDKVERSION
    mov [rbx].PLUG_INITSTRUCT.sdkVersion, eax
    Invoke lstrcpy, Addr [rbx].PLUG_INITSTRUCT.pluginName, Addr PLUGIN_NAME
    
    mov rbx, initStruct
    mov eax, [rbx].PLUG_INITSTRUCT.pluginHandle
    mov pluginHandle, eax
    
    ; Do any other initialization here

    ; Construct plugin's .ini file from module filename
    Invoke GetModuleFileName, hInstance, Addr AutoCmdLineIni, SIZEOF AutoCmdLineIni
    Invoke lstrlen, Addr AutoCmdLineIni
    lea rbx, AutoCmdLineIni
    add rbx, rax
    sub rbx, 4 ; move back past 'dp32' extention
    mov byte ptr [rbx], 0 ; null so we can use lstrcat
    Invoke lstrcat, rbx, Addr szIni ; add 'ini' to end of string instead

    Invoke LoadIcon, hInstance, ICO_AUTOCMDLINE
    mov hIcoAutoCmdLine, eax

	mov rax, TRUE
	ret
pluginit endp


;=====================================================================================
; plugstop - Called by debugger when the plugin.dp64 is unloaded - needs to be EXPORTED
;
; Arguments: none
; 
; Notes:     perform cleanup operations here, clearing menus and other housekeeping
;
;-------------------------------------------------------------------------------------
plugstop PROC FRAME
    
    ; remove any menus, unregister any callbacks etc
    Invoke _plugin_menuclear, hMenu
    Invoke GuiAddLogMessage, Addr szPluginUnloaded
    
    mov eax, TRUE
    ret
plugstop endp


;=====================================================================================
; plugsetup - Called by debugger to initialize your plugins setup - needs to be EXPORTED
;
; Arguments: setupStruct - a pointer to a PLUG_SETUPSTRUCT structure
; 
; Notes:     setupStruct contains useful handles for use within x64dbg, mainly Qt 
;            menu handles (which are not supported with win32 api) and the main window
;            handle with this information you can add your own menus and menu items 
;            to an existing menu, or one of the predefined supported right click 
;            context menus: hMenuDisam, hMenuDump & hMenuStack
;            
;            plugsetup is called after pluginit. 
;-------------------------------------------------------------------------------------
plugsetup PROC FRAME USES RBX setupStruct:QWORD
    LOCAL hIconData:ICONDATA
    
    mov rbx, setupStruct

    ; Extract handles from setupStruct which is a pointer to a PLUG_SETUPSTRUCT structure  
    mov rax, [rbx].PLUG_SETUPSTRUCT.hwndDlg
    mov hwndDlg, rax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenu
    mov hMenu, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDisasm
    mov hMenuDisasm, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuDump
    mov hMenuDump, eax
    mov eax, [rbx].PLUG_SETUPSTRUCT.hMenuStack
    mov hMenuStack, eax
    
    ; Do any setup here: add menus, menu items, callback and commands etc
    Invoke GuiAddLogMessage, Addr szAutoCmdLineInfo ;szPluginLoaded
    Invoke _plugin_menuaddentry, hMenu, MENU_PLUGIN1, Addr szMenuPlugin1

    Invoke AutoCmdLineLoadMenuIcon, IMG_AUTOCMDLINE, Addr hIconData
    .IF eax == TRUE
        Invoke _plugin_menuseticon, hMenu, Addr hIconData
        Invoke _plugin_menuentryseticon, pluginHandle, MENU_PLUGIN1, Addr hIconData
    .ENDIF
    
    Invoke GuiGetWindowHandle
    mov hwndDlg, rax
    
    ret
plugsetup endp


;=====================================================================================
; CBMENUENTRY - Called by debugger when a menu item is clicked - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_MENUENTRY structure. The hEntry contains 
;            the resource id of menu item identifiers
;  
; Notes:     hEntry can be used to determine if the user has clicked on your plugins
;            menu item(s) and to do something in response to it.
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBMENUENTRY PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    mov rbx, cbInfo
    mov eax, [rbx].PLUG_CB_MENUENTRY.hEntry
    
    .IF eax == MENU_PLUGIN1
        Invoke DbgIsDebugging
        .IF rax == FALSE
            Invoke GuiAddStatusBarMessage, Addr szDebuggingRequired
            Invoke GuiAddLogMessage, Addr szDebuggingRequired
            ret
        .ELSE
            ; todo add check for not in ntdll.dll
        
            Invoke DialogBoxParam, hInstance, IDD_AddCmdLine, hwndDlg, OFFSET AddCmdLineDlgProc, NULL
        .ENDIF
    .ENDIF
    
    ret

CBMENUENTRY endp


;=====================================================================================
; CBINITDEBUG - Called by debugger when a program is debugged - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - a pointer to a PLUG_CB_INITDEBUG structure. 
;            The szFileName item contains name of file being debugged. 
;  
; Notes:     
;            
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBINITDEBUG PROC FRAME USES RBX cbType:QWORD, cbInfo:QWORD
    LOCAL lpszFilename:QWORD
    
    Invoke RtlZeroMemory, Addr DebugFilenameMD5, SIZEOF DebugFilenameMD5
    
    mov rbx, cbInfo
    mov rax, [rbx]
    mov DebugFilename, rax
    mov lpszFilename, rax

    ; create hash of module filename and path to check in our .ini file for previous cmd line
    Invoke AutoCmdLineCreateHash, lpszFilename, Addr DebugFilenameMD5
    
    ; for debugging to view md5 hash
    ;Invoke lstrcpy, Addr szLogMsg, Addr szCBINITDEBUG
    ;Invoke lstrcat, Addr szLogMsg, Addr DebugFilenameMD5
    ;Invoke lstrcat, Addr szLogMsg, Addr szCRLF
    ;Invoke GuiAddLogMessage, Addr szLogMsg    

    mov rax, TRUE
    ret

CBINITDEBUG endp


;=====================================================================================
; CBSYSTEMBREAKPOINT - Called by debugger at system breakpoint - needs to be EXPORTED
;
; Arguments: cbType
;            cbInfo - reserved 
;            
;  
; Notes:     
;            
;            Needs to be PROC C type procedure call to be compatible with debugger
;-------------------------------------------------------------------------------------
CBSYSTEMBREAKPOINT PROC FRAME cbType:QWORD, cbInfo:QWORD
    Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
    _DbgFunctions ModPathFromAddr, sel.start, Addr szModuleFilename, MAX_PATH

    Invoke IniGetModuleCmdLine, Addr szModuleFilename, Addr szNewCommandLine, Addr dqRemember
    .IF rax == TRUE ; found it
        .IF dqRemember == 1 ; we fetch saved command line
            ; add entry into log to say cmd line has been changed
            Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
            Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineAutoChange
            Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
            Invoke lstrcat, Addr szLogMsg, Addr szCRLF
            Invoke GuiAddLogMessage, Addr szLogMsg
        
            ; do the call to setcmdline
            Invoke lstrcat, Addr szNewCommandLine, Addr szCRLF
            _DbgFunctions SetCmdline, Addr szNewCommandLine
        .ENDIF
    .ENDIF    
    
    mov rax, TRUE
    ret
CBSYSTEMBREAKPOINT ENDP


;=====================================================================================
; AddCmdLineDlgProc Dialog Procedure
;-------------------------------------------------------------------------------------
AddCmdLineDlgProc PROC FRAME hWin:HWND, iMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL dqNewRemember:QWORD
    
    
    mov eax, iMsg
    .IF eax == WM_INITDIALOG
        ; Any initialization here
        Invoke SendMessage, hWin, WM_SETICON, ICON_SMALL, hIcoAutoCmdLine
        ; Get some information to set in dialogbox textboxes and our checkbox
        ;Invoke GuiSelectionGet, GUI_DISASSEMBLY, Addr sel
        ;_DbgFunctions ModPathFromAddr, sel.start, Addr szModuleFilename, MAX_PATH
        Invoke SetDlgItemText, hWin, IDC_TxtAddCmdLineModuleFilename, DebugFilename ;szModuleFilename
        
        ; Search our ini file for a module that matches (using md5 hash of the full path name of file)
        Invoke IniGetModuleCmdLine, DebugFilename, Addr szCommandLine, Addr dqRemember ; szModuleFilename
        .IF eax == FALSE ; we didnt find it in our ini file, so fetch current command line
            ; ok, so we just get the default cmdline instead and present that to our user.
            mov eax, 1024d
            mov dwCmdLineSize, eax
            _DbgFunctions GetCmdline, Addr szCommandLine, Addr dwCmdLineSize
            Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_SETCHECK, BST_UNCHECKED, 0
             
        .ELSE ; we did find it
            .IF dqRemember == 0
                Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_SETCHECK, BST_UNCHECKED, 0
            .ELSE
                Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_SETCHECK, BST_CHECKED, 0
            .ENDIF
        .ENDIF
        Invoke SetDlgItemText, hWin, IDC_TxtAddCmdLineCommandLine, Addr szCommandLine
        
	.ELSEIF eax == WM_CLOSE
        Invoke EndDialog, hWin, NULL
        
	.ELSEIF eax == WM_COMMAND
        mov rax, wParam
        and rax, 0FFFFh
        .IF eax == IDC_BtnAddCmdLineOK
            
            ; get text from command line textbox and get checkbox option
            Invoke RtlZeroMemory, Addr szNewCommandLine, SIZEOF szNewCommandLine
            Invoke GetDlgItemText, hWin, IDC_TxtAddCmdLineCommandLine, Addr szNewCommandLine, SIZEOF szNewCommandLine
            Invoke SendDlgItemMessage, hWin, IDC_ChkAddCmdLineRemember, BM_GETCHECK, 0, 0
            .IF eax == BST_CHECKED
                mov dqNewRemember, 1
            .ELSE
                mov dqNewRemember, 0
            .ENDIF
            
            ; save info to our ini file
            Invoke IniSetModuleCmdLine, DebugFilename, Addr szNewCommandLine, dqNewRemember ;szModuleFilename
            
            .IF dqRemember == 0 && dqNewRemember == 1 ; we are now set to remember so log msg reflects this
                Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
                Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineRemember
                Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
                Invoke lstrcat, Addr szLogMsg, Addr szCRLF
                Invoke GuiAddLogMessage, Addr szLogMsg
            
            .ELSEIF dqRemember == 1 && dqNewRemember == 0 ; set to forget it
                Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
                Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineForgotten
                Invoke lstrcat, Addr szLogMsg, Addr szQ
                Invoke lstrcat, Addr szLogMsg, Addr szCRLF
                Invoke GuiAddLogMessage, Addr szLogMsg
            .ELSE
                ; otherwise we just changed command line
                Invoke RtlZeroMemory, Addr szLogMsg, SIZEOF szLogMsg
                Invoke lstrcpy, Addr szLogMsg, Addr szAutoCmdLineManualChange
                Invoke lstrcat, Addr szLogMsg, Addr szNewCommandLine
                Invoke lstrcat, Addr szLogMsg, Addr szCRLF
                Invoke GuiAddLogMessage, Addr szLogMsg
            .ENDIF
            
            ; do the call to setcmdline
            Invoke lstrcat, Addr szNewCommandLine, Addr szCRLF
            _DbgFunctions SetCmdline, Addr szNewCommandLine
            
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
        
        .ELSEIF eax == IDC_BtnAddCmdLineCancel
            Invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
        
        .ENDIF
    .ELSE
        mov rax, FALSE
        ret
	.ENDIF
    mov rax, TRUE
    ret
AddCmdLineDlgProc endp


;=====================================================================================
; AutoCmdLineCreateHash - Hash a string
;-------------------------------------------------------------------------------------
AutoCmdLineCreateHash PROC FRAME USES RBX StringToHash:QWORD, HashedString:QWORD
    LOCAL hProv:HCRYPTPROV
    LOCAL hHash:HCRYPTHASH
    LOCAL pbHash:QWORD
    LOCAL dwHashLen:DWORD
    LOCAL dwCount:DWORD
    LOCAL lenStringToHash:DWORD
    LOCAL pTempHashString:QWORD
    LOCAL pcchString:DWORD
    
    Invoke lstrlen, StringToHash
    mov lenStringToHash, eax

    
    Invoke CryptAcquireContext, Addr hProv, NULL, NULL, PROV_RSA_FULL, 0; CRYPT_SILENT
    .IF rax != FALSE
        Invoke CryptCreateHash, hProv, CALG_MD5, 0, 0, Addr hHash
        .IF rax != FALSE
            Invoke CryptHashData, hHash, StringToHash, lenStringToHash, 0
            .IF rax != FALSE
                mov dwCount, 4d
                Invoke CryptGetHashParam, hHash, HP_HASHSIZE, Addr dwHashLen, Addr dwCount, 0
                .IF rax != FALSE
                    Invoke GlobalAlloc, GMEM_FIXED+GMEM_ZEROINIT, dwHashLen
                    .IF rax != NULL
                        mov pTempHashString, rax
                        
                        Invoke CryptGetHashParam, hHash, HP_HASHVAL, pTempHashString, Addr dwHashLen, 0
                        .IF rax != FALSE
                            
                            Invoke CryptBinaryToString, pTempHashString, dwHashLen, CRYPT_STRING_HEXRAW + CRYPT_STRING_NOCRLF, HashedString, Addr pcchString
                            
                            ;Invoke MessageBox, hwndDlg, StringToHash, pTempHashString, MB_OK
                            ;Invoke lstrcpyn, HashedString, pTempHashString, dwHashLen
                            
                            .IF dwHashLen == 0
                            ;    Invoke GuiAddLogMessage, Addr szZeroLengthHash
                            .ENDIF
                            
                            ;Invoke lstrcpy, Addr szLogMsg, Addr szCreateHashSuccess
                            ;Invoke lstrcat, Addr szLogMsg, HashedString
                            ;Invoke lstrcat, Addr szLogMsg, Addr szCRLF 
                            ;Invoke GuiAddLogMessage, Addr szLogMsg
                            
                            
                            Invoke GlobalFree, pTempHashString
                            Invoke CryptDestroyHash, hHash
                            Invoke CryptReleaseContext, hProv, 0
                            
                            mov rax, TRUE
                            ret
                        .ELSE
                            ;Invoke GuiAddLogMessage, Addr szErrorCryptGetHashParamVal
                        .ENDIF
                    .ELSE
                        ;Invoke GuiAddLogMessage, Addr szErrorGlobalAlloc
                    .ENDIF
                .ELSE
                    ;Invoke GuiAddLogMessage, Addr szErrorCryptGetHashParamSize
                .ENDIF
            .ELSE
                ;Invoke GuiAddLogMessage, Addr szErrorCryptHashData
            .ENDIF
        .ELSE
            ;Invoke GuiAddLogMessage, Addr szErrorCryptCreateHash
        .ENDIF
    .ELSE
        ;Invoke GuiAddLogMessage, Addr szErrorCryptAcquireContext
    .ENDIF
    mov rax, FALSE
    ret

AutoCmdLineCreateHash endp


;=====================================================================================
; AutoCmdLineLoadMenuIcon - Loads RT_RCDATA png resource and assigns it to ICONDATA
; Returns TRUE in eax if succesful or FALSE otherwise.
;-------------------------------------------------------------------------------------
AutoCmdLineLoadMenuIcon PROC FRAME USES RBX dqImageResourceID:QWORD, lpIconData:QWORD
    LOCAL hRes:QWORD
    
    ; Load image for our menu item
    Invoke FindResource, hInstance, dqImageResourceID, RT_RCDATA ; load png image as raw data
    .IF eax != NULL
        mov hRes, rax
        Invoke SizeofResource, hInstance, hRes
        .IF rax != 0
            mov rbx, lpIconData
            mov [rbx].ICONDATA.size_, rax
            Invoke LoadResource, hInstance, hRes
            .IF rax != NULL
                Invoke LockResource, rax
                .IF rax != NULL
                    mov rbx, lpIconData
                    mov [rbx].ICONDATA.data, rax
                    mov rax, TRUE
                .ELSE
                    ;PrintText 'Failed to lock resource'
                    mov rax, FALSE
                .ENDIF
            .ELSE
                ;PrintText 'Failed to load resource'
                mov rax, FALSE
            .ENDIF
        .ELSE
            ;PrintText 'Failed to get resource size'
            mov rax, FALSE
        .ENDIF
    .ELSE
        ;PrintText 'Failed to find resource'
        mov rax, FALSE
    .ENDIF    
    ret

AutoCmdLineLoadMenuIcon ENDP


END DllMain
















