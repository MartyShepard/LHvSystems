CompilerIf #PB_Compiler_IsMainFile
 
CompilerEndIf
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule Windows

    Enumeration 1 Step 1
        #CURSOR_CROSSHAIR
        #CURSOR_NORMAL
        #CURSOR_WAIT
        #CURSOR_IBEAM
        #CURSOR_HAND
        #CURSOR_HELP
        #CURSOR_MOVE
        #CURSOR_UPARROW
        #CURSOR_STOP
    EndEnumeration
    
        EnumEnd =  10
        EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
        Debug #TAB$ + "Constansts Enumeration : 0001 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: Windows::(Module), Mouse Cursor)"
        
;     Enums =  610 - #PB_Compiler_EnumerationValue
;     Debug "Enumeration = 600 -> " + #PB_Compiler_EnumerationValue +" /Max: 610 /Free: "+Str(Enums)+" ()"    
;     
    Structure IMAGENFO
        ImageBit_Num.l
        ImageBit_Str.s{20}
        Description.s{255}
    EndStructure
    *NativeImage.IMAGENFO       = AllocateMemory(SizeOf(IMAGENFO))
    
    Declare.s GetVersion(iSelect=0) 
    Declare Set_Instances(LHInstanz=1,ProgrammAppName$="",UniqueID$="") 
    Declare Set_FreeMemory()
    Declare Get_FileBitsInto(FilePath$,*NativeImage.IMAGENFO)
    Declare.i Get_Language(GetDecimalCode=0) 
    Declare LoadCursor(Type,WindowHandle)
    Declare.i GetOSBit()
    Declare.s MakeGUID()
    Declare.s FormatMilliseconds(mask.s, MilliSeconds.l)
    

        
EndDeclareModule

Module Windows
    

    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Check if the OS is 32 or 64 bit.
    ;
    Procedure GetOSBit()
        Protected Is64BitOS = 0
        Protected hDLL, IsWow64Process_
        Protected sOSbits = 32
        
        If SizeOf(Integer) = 8
            
            sOSbits = 64
        Else
            
            hDLL = OpenLibrary(#PB_Any,"kernel32.dll")
            If hDLL
                
                IsWow64Process_ = GetFunction(hDLL,"IsWow64Process")
                If IsWow64Process_
                    
                    CallFunctionFast(IsWow64Process_, GetCurrentProcess_(), @Is64BitOS)        
                EndIf
                
                CloseLibrary(hDLL)
            EndIf
            
            If(Is64BitOS = 1) : sOSbits = 64 : EndIf
        EndIf
        
        ProcedureReturn sOSbits
        
    EndProcedure
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;  
    Procedure LoadCursor(Type,WindowHandle)
        Protected Cursor
        Select Type
        Case #CURSOR_HELP       :Cursor=#IDC_HELP
        Case #CURSOR_HAND       :Cursor=#IDC_HAND
        Case #CURSOR_IBEAM      :Cursor=#IDC_IBEAM
        Case #CURSOR_NORMAL     :Cursor=#IDC_ARROW
        Case #CURSOR_CROSSHAIR  :Cursor=#IDC_CROSS
        Case #CURSOR_WAIT       :Cursor=#IDC_WAIT   
        Case #CURSOR_MOVE       :Cursor=#IDC_SIZEALL
        Case #CURSOR_UPARROW    :Cursor=#IDC_UPARROW  
        Case #CURSOR_STOP       :Cursor=#IDC_NO 
    EndSelect
        Debug "Load Cursor "+Cursor
        SetClassLong_(WindowHandle, #GCL_HCURSOR, LoadCursor_(0, Cursor))
    EndProcedure    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;   
    
    Procedure.s GetVersion(iSelect=0)
        Protected sMajor$, sMinor$, sBuild$, Version$, sPlatform$, SystemRoot$, iResult.l
        Define Os.OSVERSIONINFO
        Define WinVersion$
        
        
        Os\dwOSVersionInfoSize = SizeOf(OSVERSIONINFO)
        GetVersionEx_(@Os.OSVERSIONINFO)
        
        Select iSelect
            Case 0:
                sMajor$ = Str(Os\dwMajorVersion)
                sMinor$ = Str(Os\dwMinorVersion)
                ProcedureReturn sMajor$+sMinor$
            Case 1:
                sBuild$ = Str(Os\dwBuildNumber)
                ProcedureReturn sBuild$
            Case 2:
                sSPack$ = PeekS(@Os\szCSDVersion)
                ProcedureReturn sSPack$
            Case 4:
                sPlatform$    = Str(Os\dwPlatformId)
                sMajor$       = Str(Os\dwMajorVersion)
                sMinor$       = Str(Os\dwMinorVersion)        
                
                Version$= sPlatform$+"."+sMajor$+"."+sMinor$
                Select Version$
                        
                    Case "1.0.0":     ProcedureReturn "Windows 95"
                    Case "1.1.0":     ProcedureReturn "Windows 98"
                    Case "1.9.0":     ProcedureReturn "Windows Millenium"
                    Case "2.3.0":     ProcedureReturn "Windows NT 3.51"
                    Case "2.4.0":     ProcedureReturn "Windows NT 4.0"
                    Case "2.5.0":     ProcedureReturn "Windows 2000"
                    Case "2.5.1":     ProcedureReturn "Windows XP"
                    Case "2.5.3":     ProcedureReturn "Windows 2003 (SERVER)"
                    Case "2.6.0":     ProcedureReturn "Windows Vista"
                    Case "2.6.1":     ProcedureReturn "Windows 7"
                    Case "2.6.2":     ProcedureReturn "Windows 8"             ;Build 9200                 
                    Default:          ProcedureReturn "Unknown"
                EndSelect
                
            Case 5:
                If ExamineEnvironmentVariables()
                    While NextEnvironmentVariable()
                        SystemRoot$ = EnvironmentVariableName()
                        If (LCase(SystemRoot$)="systemroot")
                            ProcedureReturn EnvironmentVariableValue() 
                            
                        EndIf
                    Wend
                EndIf
                
            Case 6:
                If ExamineEnvironmentVariables()
                    While NextEnvironmentVariable()
                        SystemRoot$ = EnvironmentVariableName()
                        If (LCase(SystemRoot$)="systemroot")
                            
                            iResult = FileSize(SystemRoot$+"SYSWOW64\")
                            If (iResult = -2)                        
                                ProcedureReturn EnvironmentVariableValue()+"\SYSWOW64\"
                            Else
                                ProcedureReturn EnvironmentVariableValue()+"\SYSTEM32\"
                            EndIf                                                
                        EndIf
                    Wend
                EndIf          
                
        EndSelect
        
        ;-----------------------------------------------------------------------------------------------        
        ; Get_WindowsVersion(iSelect=0), Holt die Aktuelle Windows Version, via iSelect lässt sich
        ; mehrere Information zurückgeben
        ; iSelect=5 gibt das Windows Root Verzeichnis Zurück
        ; iSelect=6 gibt das Windows System Verzeichnis Zurück
        ;-----------------------------------------------------------------------------------------------    
    EndProcedure
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                       Mehrere Instanzen eines Programmes verhindern
    #SI_SESSION_UNIQUE = $0001 ; Allow only one instance per login session
    #SI_DESKTOP_UNIQUE = $0002 ; Allow only one instance on current desktop
    #SI_TRUSTEE_UNIQUE = $0004 ; Allow only one instance for current user
    #SI_SYSTEM_UNIQUE  = $0000 ; Allow only one instance at all (on the whole system)
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure.s CreateUniqueName( name.s, mode.l = #SI_DESKTOP_UNIQUE )
        Protected output.s = "Global\"+name
        
        If mode & #SI_DESKTOP_UNIQUE
            Protected hDesk.i, cchDesk.l, userinfo.s
            output   + "-"
            hDesk    = GetThreadDesktop_( GetCurrentThreadId_() )
            cchDesk  = #MAX_PATH - Len(name) - 1
            userinfo = Space(#MAX_PATH)
            
            If GetUserObjectInformation_( hDesk, #UOI_NAME, @name, cchDesk, @cchDesk )
                output + Trim(name)
            Else
                output + "Win9x"
            EndIf
        EndIf
        If mode & #SI_SESSION_UNIQUE
            Protected hToken.i, cbBytes.l, *pTS
            If OpenProcessToken_( GetCurrentProcess_(), #TOKEN_QUERY, @hToken )
                If GetTokenInformation_( hToken, #TokenStatistics, #Null, cbBytes, @cbBytes )=0 And GetLastError_() = #ERROR_INSUFFICIENT_BUFFER
                    *pTS = AllocateMemory( cbBytes )
                    If *pTS
                        If GetTokenInformation_( hToken, #TokenStatistics, *pTS, cbBytes, @cbBytes )
                            output + "-" + RSet(Hex(PeekQ(*pts+8),#PB_Quad),16,"0")
                        EndIf
                        FreeMemory(*pTS)
                    EndIf
                EndIf
            EndIf
        EndIf
        If mode & #SI_TRUSTEE_UNIQUE
            Protected user.s  , cchUser.l = 64
            Protected domain.s, cchDomain = 64
            user   = Space(cchUser)
            domain = Space(cchDomain)
            If GetUserName_( @user, @cchUser )
                output + "-" + Trim(user)
            EndIf
            cchDomain = GetEnvironmentVariable_( "USERDOMAIN", @domain, cchDomain )
            
            output + "-" + Trim(domain)
        EndIf
        
        ProcedureReturn Left(output,#MAX_PATH)
    EndProcedure
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure IsInstancePresent( name.s , mode.l = #SI_DESKTOP_UNIQUE )
        Protected err, uniqueName.s
        Static hMutex = #Null
        If hMutex = #Null
            uniqueName = CreateUniqueName( name, mode )
            hMutex = CreateMutex_( #Null, #False, @uniqueName )
            err = GetLastError_()
            If err = #ERROR_ALREADY_EXISTS : ProcedureReturn #True : EndIf
            If err = #ERROR_ACCESS_DENIED  : ProcedureReturn #True : EndIf
        EndIf
        ProcedureReturn #False
    EndProcedure
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure.s MakeGUID()
        Protected guid.GUID, lpsz.s{76}
 
        If CoCreateGuid_(@guid) = #S_OK
        ProcedureReturn PeekS(@lpsz, StringFromGUID2_(guid, @lpsz, 76), #PB_Unicode)
    EndIf     
    EndProcedure

    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure Set_Instances(LHInstanz=1,ProgrammAppName$="",UniqueID$="")
        
        Protected iProgram$, iSemaphore, Request0$, Request1$, Request2$, MessageIcon$                
        ;Debug MakeGUID()
        
        Request0$ = "Now Look What You've Done" 
                 
        If (LHInstanz = 8)
            iProgram$   = GetFilePart(ProgramFilename())
            iSemaphore  = CreateSemaphore_(0,0,1,iProgram$)
            
            If (iSemaphore<>0) And GetLastError_()=#ERROR_ALREADY_EXISTS

                MessageIcon$ = GetFilePart(ProgramFilename(),#PB_FileSystem_NoExtension)
                
                Select Windows::Get_Language(1)
                    Case 1031
                        Request1$ = "Fehler - Programm Instanz ist Aktiv"
                        Request2$ = "Mehrere Instanzen von '" + MessageIcon$ + "' können nicht gestartet werden"
                    Default
                        Request1$ = "Error - Already Startet"
                        Request2$ = "Don't run Multiples Instances from  " + MessageIcon$
                    EndSelect                  
                
                Request::MSG(Request0$,Request1$,Request2$,6,2,ProgramFilename())
                CloseHandle_(iSemaphore) ; This line can be omitted
                End
            EndIf
            
            ;         Debug CreateUniqueName(#APPGUID, #SI_SESSION_UNIQUE )
            ;         Debug CreateUniqueName(#APPGUID, #SI_DESKTOP_UNIQUE )
            ;         Debug CreateUniqueName(#APPGUID, #SI_TRUSTEE_UNIQUE )
            ;         Debug CreateUniqueName(#APPGUID, #SI_SYSTEM_UNIQUE  )
            ;         
            ;         Debug CreateUniqueName(#APPGUID, #SI_SESSION_UNIQUE | #SI_DESKTOP_UNIQUE )
            ;         Debug CreateUniqueName(#APPGUID, #SI_TRUSTEE_UNIQUE | #SI_DESKTOP_UNIQUE )
            
            If IsInstancePresent(UniqueID$, #SI_SYSTEM_UNIQUE)
                If ( Len(ProgrammAppName$) = 0 ): ProgrammAppName$ = "Instanz": EndIf
                
                MessageIcon$ = GetFilePart(ProgramFilename(),#PB_FileSystem_NoExtension)
                
                Select Windows::Get_Language(1)
                    Case 1031
                        Request1$ = ProgrammAppName$ + " is Aktiv"
                        Request2$ = "Mehrere Instanzen von '" + MessageIcon$ + "' können nicht gestartet werden"
                    Default
                        Request1$ = ProgrammAppName$ + " Already Startet"
                        Request2$ = "Don't run Multiples Instances from  " + MessageIcon$
                EndSelect
                
                Request::MSG(Request0$,Request1$,Request2$,6,2,ProgramFilename())
                End ; already running
            EndIf
        EndIf 
        
        ;-----------------------------------------------------------------------------------------------        
        ; Set_Instances(), Bestimmt ob das programm mehrmals gestartet werden darf/ Erweitert
        ;-----------------------------------------------------------------------------------------------     
    EndProcedure
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure Set_FreeMemory()
        Protected ProcessID,PHandle,iResult
        
        ProcessID = GetCurrentProcessId_()
        PHandle   = GetCurrentProcess_()
        
        iResult   = SetProcessWorkingSetSize_(PHandle,-1,-1)
        If iResult:Else:EndIf
        
        ;-----------------------------------------------------------------------------------------------        
        ; Set_FreeMemory(), Gibt vom eigenen programm den Speicher Frei
        ;-----------------------------------------------------------------------------------------------         
    EndProcedure
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    Procedure Get_FileBitsInto(FilePath$,*NativeImage.IMAGENFO)
        

        
        #SCS_32BIT_BINARY   = 0: #SCS_64BIT_BINARY   = 6: #SCS_DOS_BINARY     = 1: #SCS_OS216_BINARY   = 5
        #SCS_PIF_BINARY     = 3: #SCS_POSIX_BINARY   = 4: #SCS_WOW_BINARY     = 2:
        
        Define lpBinaryType: GetBinaryType_(@FilePath$,@lpBinaryType)
        Select lpBinaryType
                ;
                ;
            Case #SCS_32BIT_BINARY
                *NativeImage\ImageBit_Num = #SCS_32BIT_BINARY
                *NativeImage\ImageBit_Str = "SCS_32BIT_BINARY"
                Select Windows::Get_Language(1)
                    Case 1031   : *NativeImage\Description =  "32Bit Ausführbare Anwendung"
                    Default     : *NativeImage\Description =  "32Bit Exe Detectet"
                EndSelect       
                ;
                ;                
            Case #SCS_64BIT_BINARY
                *NativeImage\ImageBit_Num = #SCS_64BIT_BINARY
                *NativeImage\ImageBit_Str = "SCS_64BIT_BINARY"
                If (#PB_Processor_x86)
                    Select Windows::Get_Language(1)
                        Case 1031   : *NativeImage\Description =  "64Bit Anwendundgen können unter 32Bit nicht gestartet werden"
                        Default     : *NativeImage\Description =  "Can not run 64Bit Application on 32Bit"
                    EndSelect                     
                EndIf
                If (#PB_Processor_x64) 
                    Select Windows::Get_Language(1)
                        Case 1031   : *NativeImage\Description =  "64Bit Ausführbare Anwendung"
                        Default     : *NativeImage\Description =  "64Bit Exe Detectet"
                    EndSelect 
                EndIf
                ;
                ;
            Case #SCS_DOS_BINARY
                *NativeImage\ImageBit_Num = #SCS_DOS_BINARY
                *NativeImage\ImageBit_Str = "SCS_DOS_BINARY"
                Select Windows::Get_Language(1)
                    Case 1031   : *NativeImage\Description =  "MS-DOS Basierte Datei kann nicht ausgeführt werden"
                    Default     : *NativeImage\Description =  "Can't run MS-DOS based application"
                EndSelect  
                ;
                ;
            Case #SCS_OS216_BINARY
                *NativeImage\ImageBit_Num = #SCS_OS216_BINARY
                *NativeImage\ImageBit_Str = "SCS_OS216_BINARY"
                Select Windows::Get_Language(1)                
                    Case 1031   : *NativeImage\Description =  "Keine unterstüzung für 16-bit OS/2 Applikationen"
                    Default     : *NativeImage\Description =  "No Support for 16-bit OS/2 application"                
                EndSelect
                ;
                ;
            Case #SCS_PIF_BINARY
                *NativeImage\ImageBit_Num = #SCS_PIF_BINARY
                *NativeImage\ImageBit_Str = "SCS_PIF_BINARY"
                Select Windows::Get_Language(1)                
                    Case 1031   : *NativeImage\Description =  "PIF Dateien die MS-DOS Basierte Anwednungen starten kann nicht ausgeführt werden"
                    Default     : *NativeImage\Description =  "Can not run the PIF file that executes an MS-DOS-based application"                
                EndSelect                
                ;
                ;
            Case #SCS_POSIX_BINARY
                *NativeImage\ImageBit_Num = #SCS_POSIX_BINARY
                *NativeImage\ImageBit_Str = "SCS_POSIX_BINARY"
                Select Windows::Get_Language(1)                
                    Case 1031   : *NativeImage\Description =  "Keine unterstüzung für POSIX Basierte Anwendungen"
                    Default     : *NativeImage\Description =  "No Support for POSIX-based application"                
                EndSelect  
                ;
                ;
            Case #SCS_WOW_BINARY  
                *NativeImage\ImageBit_Num = #SCS_WOW_BINARY  
                *NativeImage\ImageBit_Str = "SCS_WOW_BINARY"
                If (#PB_Processor_x86)                
                    Select Windows::Get_Language(1)                
                        Case 1031   : *NativeImage\Description =  "16Bit Ausführbare Anwendung"
                        Default     : *NativeImage\Description =  "16Bit Exe Detected"                
                    EndSelect                  
                EndIf
                If (#PB_Processor_x64)                
                    Select Windows::Get_Language(1)                
                        Case 1031   : *NativeImage\Description =  "16Bit Anwendundgen können unter 64Bit mnicht gestartet werden"
                        Default     : *NativeImage\Description =  "Can not run 16Bit Application on 64Bit"                
                    EndSelect                  
                EndIf  
        EndSelect        
        ;----------------------------------------------------------------------------------------------- 
        ;Get_FileBitsInto(Datei,Requester Language) Überprüfr die Ausfürbare Datei
        ;-----------------------------------------------------------------------------------------------    
    EndProcedure
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;     
        
    Procedure Get_Language(GetDecimalCode=0)              
        
        Protected HexCode, DecCode
        Select GetUserDefaultLangID_() & $0003FF
                           
                
            Case #LANG_ARABIC
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))

            Case #LANG_BULGARIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_CATALAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))                    
                
            Case #LANG_CHINESE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))              
                
            Case #LANG_CZECH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                
            Case #LANG_DANISH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                
            Case #LANG_GERMAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                
            Case #LANG_GREEK
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                
            Case #LANG_ENGLISH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                                
            Case #LANG_SPANISH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                
            Case #LANG_HUNGARIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_ICELANDIC
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_ITALIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_JAPANESE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_JAPANESE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_KOREAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_DUTCH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_NORWEGIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_POLISH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_PORTUGUESE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_ROMANIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_RUSSIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_CROATIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_SERBIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_SLOVAK
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_ALBANIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_SWEDISH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_THAI
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_TURKISH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_FRENCH
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_INDONESIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_UKRAINIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_BELARUSIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_SLOVENIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_LATVIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_ESTONIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_LITHUANIAN
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_())) 
                  
            Case #LANG_FARSI
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_VIETNAMESE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))
                  
            Case #LANG_BASQUE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))  
                  
            Case #LANG_AFRIKAANS
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))  
                  
            Case #LANG_FAEROESE
                  DecCode = GetUserDefaultLangID_()                
                  HexCode = Val(Hex(GetUserDefaultLangID_()))  
                  
            Default
                ProcedureReturn 0
        EndSelect  
        
        Select GetDecimalCode
            Case 0 
                ProcedureReturn HexCode
            Case 1
                ProcedureReturn DecCode
        EndSelect       
    EndProcedure
    
    
    ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ; Project name : FormatMilliseconds
    ; File : Lib_FormatMilliseconds.pb
    ; File Version : 1.0.0
    ; Programmation : OK
    ; Programmed by : Guimauve
    ; Date : 15-04-2009
    ; Last Update : 15-04-2009
    ; Coded for PureBasic V4.30
    ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
    ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    ; <<<<< Conversion de milliseconde vers en j : H : M : S : Ms <<<<<
    
    Procedure.s FormatMilliseconds(mask.s, MilliSeconds.l)
        
        ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        ; <<<<< On fait l'extraction des jours, Heures, minutes, secondes et des MS <<<<<
        
        If MilliSeconds < 0 
            MilliSeconds = MilliSeconds * -1
        EndIf 
        
        Days = MilliSeconds / 86400000 
        MilliSeconds % 86400000
        
        Hours = MilliSeconds / 3600000
        MilliSeconds % 3600000
        
        Minutes = MilliSeconds / 60000
        MilliSeconds % 60000
        
        Seconds = MilliSeconds / 1000
        MilliSeconds % 1000
        
        ; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        ; <<<<< On s'occupe du filtre de sortie <<<<<
        
        If FindString(mask, "%dd", 1)
            
            mask = ReplaceString(mask,"%dd", RSet(Str(Days), 2, "0"))
            
        EndIf 
        
        If FindString(mask, "%hh", 1)
            
            mask = ReplaceString(mask,"%hh", RSet(Str(Hours), 2, "0"))
            
        EndIf 
        
        If FindString(mask, "%mm", 1)
            
            mask = ReplaceString(mask,"%mm", RSet(Str(Minutes), 2, "0"))
            
        EndIf 
        
        If FindString(mask, "%ss", 1)
            
            mask = ReplaceString(mask,"%ss", RSet(Str(Seconds), 2, "0"))
            
        EndIf 
        
        If FindString(mask, "%mss", 1)
            
            mask = ReplaceString(mask,"%mss", RSet(Str(MilliSeconds), 3, "0"))
            
        EndIf
        
        If FindString(mask, "%ms", 1)
            
            mask = ReplaceString(mask,"%ms", RSet(Str(MilliSeconds), 2, "0"))
            
        EndIf 
        
        ProcedureReturn mask
EndProcedure

; <<<<<<<<<<<<<<<<<<<<<<<
; <<<<< END OF FILE <<<<<
; <<<<<<<<<<<<<<<<<<<<<<<    
EndModule

CompilerIf #PB_Compiler_IsMainFile

;/////////////////////////////////////////////////////////////////////////
    Procedure.l Hex2Dec(h$)
    ;===============================================
    ;   convert a hex-string to a integer value
    ;   found @ www.purebasic-lounge.de
    ;
    ;   Original code seems to be from code-archive
    ;   @ www.purearea.net
    ;===============================================
      h$=UCase(h$)
     
      For r=1 To Len(h$)
        d<<4
        a$=Mid(h$,r,1)
        If Asc(a$)>60
          d+Asc(a$)-55
        Else
          d+Asc(a$)-48
        EndIf
      Next
     
      ProcedureReturn d
     
  EndProcedure
  
  
  Debug Hex2Dec("409")
  Debug Hex2Dec(Windows::Get_Language() ) + "Germam"
  Debug Windows::Get_Language(1)

CompilerEndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 18
; FirstLine = 3
; Folding = Xo-
; EnableXP
; EnableUnicode