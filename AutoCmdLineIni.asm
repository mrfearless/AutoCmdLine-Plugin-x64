
include winreg.INC
;include advapi32.inc
includelib advapi32.lib

IniGetModuleCmdLine         PROTO :QWORD, :QWORD, :QWORD
IniSetModuleCmdLine         PROTO :QWORD, :QWORD, :QWORD

.CONST


.DATA


.DATA?


.CODE

;=====================================================================================
; Get cmdline for specified debugfilename (hashed value of it) from our ini
;-------------------------------------------------------------------------------------
IniGetModuleCmdLine PROC FRAME USES RBX lpszModuleFilename:QWORD, lpszCommandLine:QWORD, lpqwRememberOption:QWORD
    LOCAL szIniCommandLineString[MAX_PATH+2]:BYTE
    LOCAL lenModuleFilename:DWORD
    
    Invoke lstrlen, Addr DebugFilenameMD5
    .IF eax == 0 ; havnt got the hash of this module name yet, so do it now

       ; Invoke lstrlen, lpszModuleFilename
        ;mov lenModuleFilename, eax

        ; create hash of module filename and path to check in our .ini file for cmd line entry
        Invoke AutoCmdLineCreateHash, lpszModuleFilename, Addr DebugFilenameMD5
        
        Invoke lstrcpy, Addr szLogMsg, Addr szIniGetModuleCmdLine
        Invoke lstrcat, Addr szLogMsg, Addr DebugFilenameMD5
        Invoke lstrcat, Addr szLogMsg, Addr szCRLF
        Invoke GuiAddLogMessage, Addr szLogMsg
        
	    ;invoke MD5_Startup
	    ;invoke MD5_Init, offset dbgfilename_md5ctext
	    ;invoke MD5_Read, offset dbgfilename_md5ctext, lpszModuleFilename, lenModuleFilename
	    ;invoke MD5_Digest, offset dbgfilename_md5ctext, offset dbgfilename_md5chash
	    ;invoke MD52StringA, offset dbgfilename_md5chash, offset DebugFilenameMD5, 1
    
        IFDEF DEBUG32
        PrintText 'IniGetModuleCmdLine'
        PrintString DebugFilenameMD5
        ENDIF
    .ENDIF

    Invoke GetPrivateProfileString, Addr DebugFilenameMD5, Addr szIniCmdLine, Addr szColon, Addr szIniCommandLineString, SIZEOF szIniCommandLineString, Addr AutoCmdLineIni
    .IF eax == 0 || eax == 1 ; just got nothing or the colon and nothing else, so no command line stored for this
        mov rbx, lpszCommandLine
        mov byte ptr [rbx], 0
        mov rax, FALSE
    .ELSE
        Invoke GetPrivateProfileInt, Addr DebugFilenameMD5, Addr szIniRemember, 0, Addr AutoCmdLineIni
        mov rbx, lpqwRememberOption
        mov [rbx], rax
        
        Invoke lstrcpy, lpszCommandLine, Addr szQuote
        Invoke lstrcat, lpszCommandLine, Addr szIniCommandLineString
        Invoke lstrcat, lpszCommandLine, Addr szQuote
        ;Invoke lstrcpy, lpszCommandLine, Addr szIniCommandLineString
        mov rax, TRUE
    .ENDIF
    ret

IniGetModuleCmdLine endp


;=====================================================================================
; Set cmdline for the specified debugfilename (that is hashed) into our ini
;-------------------------------------------------------------------------------------
IniSetModuleCmdLine PROC FRAME USES RBX lpszModuleFilename:QWORD, lpszCommandLine:QWORD, qwRememberOption:QWORD
    LOCAL szIniCommandLineString[MAX_PATH]:BYTE
    LOCAL lenModuleFilename:DWORD

    ; create hash of module filename and path to check in our .ini file for cmd line entry
    Invoke AutoCmdLineCreateHash, lpszModuleFilename, Addr DebugFilenameMD5
        
    Invoke lstrcpy, Addr szLogMsg, Addr szIniSetModuleCmdLine
    Invoke lstrcat, Addr szLogMsg, Addr DebugFilenameMD5
    Invoke lstrcat, Addr szLogMsg, Addr szSpace
    Invoke lstrcat, Addr szLogMsg, lpszModuleFilename
    Invoke lstrcat, Addr szLogMsg, Addr szCRLF
    Invoke GuiAddLogMessage, Addr szLogMsg        
    
    Invoke WritePrivateProfileString, Addr DebugFilenameMD5, Addr szIniCmdLine, lpszCommandLine, Addr AutoCmdLineIni
    .IF qwRememberOption == 0
        Invoke WritePrivateProfileString, Addr DebugFilenameMD5, Addr szIniRemember, Addr szZero, Addr AutoCmdLineIni
    .ELSE
        Invoke WritePrivateProfileString, Addr DebugFilenameMD5, Addr szIniRemember, Addr szOne, Addr AutoCmdLineIni
    .ENDIF
    ret

IniSetModuleCmdLine endp

