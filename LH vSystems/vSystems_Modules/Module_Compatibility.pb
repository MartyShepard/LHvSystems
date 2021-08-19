;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule Compatibility
    Structure CmpOSModus
         OSIDX.i
         OSModus$
         OSModus_Description$
         MenuIndex.i
     EndStructure        
     
     Structure CmpEmulation
        EMUIDX.i
        Emulation$
        Emulation_Description$
        MenuIndex.i        
     EndStructure       
      
     Global NewList CompatibilitySystem.CmpOSModus()
     Global NewList CompatibilityEmulation.CmpEmulation()    
     
     
     Declare.s DataVersionFix(Value$)
     Declare DataModes(List CompatibilitySystem.CmpOSModus(), List CompatibilityEmulation.CmpEmulation())
     
EndDeclareModule

Module Compatibility
    
    Procedure DataModes(List CompatibilitySystem.CmpOSModus(), List CompatibilityEmulation.CmpEmulation())
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitGDIRedraw"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitAggregateBlts"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitDXMaxWinMode"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "256Color"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "640x480"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "APITracing"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AppRecorder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AccelGdipFlush"  
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ChangeFolderPathToXPStyle"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ClearLastErrorStatusonIntializeCriticalSection"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectCreateBrushIndirectHatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectFilePaths"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CustomNCRender"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Disable8And16BitD3D"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableCicero"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableDWM" 
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableFadeAnimations"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNXHideUI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNXShowUI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableThemeMenus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableThemes"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DW"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DWM8And16BitMitigation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DirectXTrimTextureFormats"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DirectXVersionLie" 
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXGICompat"         
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ElevateCreateProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSorting"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingServer2008"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetDiskFreeSpace"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableIISBizTalk"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableNXShowUI" 
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FaultTolerantHeap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FDR"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDxSetupSuccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GlobalMemoryStatus2GB"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GlobalMemoryStatusLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetDriveTypeWHook"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleBadPtr"         
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapClearAllocation"         
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HighDpiAware"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreAdobeKMPrintDriverMessageBox"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreAltTab"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreDirectoryJunction"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreException"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFloatingPointRoundingControl"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFontQuality"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreSetROP2"               
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Layer_Force640x480x8"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Layer_ForceDirectDrawEmulation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Layer_Win95VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadLibraryRedirect"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MsiAuto"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NullEnvironment"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "pLayerGetProcAddrExOverride" 
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PopCapGamesForceResPerf"         
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProcessPerfData"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProfilesSetup"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectCHHlocaletoCHT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsAdmin"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest_GW"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsInvoker"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SecuROM7"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SystemMetricsLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "TextArt"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "TrimDisplayDeviceNames"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VerifyVersionInfoLiteLayer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualRegistry"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win95VersionLie"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win98VersionLie"             
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinNT4SP5VersionLie"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP1VersionLie"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP2VersionLie"             
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP3VersionLie"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPVersionLie" 
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP2VersionLie"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP3VersionLie"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1VersionLie"       
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2VersionLie"             
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Wing32SystoSys32"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPMitigationLayer"         

        ResetList(CompatibilityEmulation())
        Max_Saves_List = ListSize(CompatibilityEmulation()) 
        For i = 0 To Max_Saves_List
            NextElement(CompatibilityEmulation())
            CompatibilityEmulation()\EMUIDX    = i
            CompatibilityEmulation()\MenuIndex = 284+i ; Menu Item Index
        Next              

        ;SortStructuredList(CompatibilityEmulation(), #PB_Sort_Ascending, OffsetOf(CmpEmulation\EMUIDX), #PB_Integer)
        
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win95"        :CompatibilitySystem()\OSModus_Description$ = "Windows 95"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win98"        :CompatibilitySystem()\OSModus_Description$ = "Windows 98"   
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win2000"      :CompatibilitySystem()\OSModus_Description$ = "Windows 2000"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win2000Sp2"   :CompatibilitySystem()\OSModus_Description$ = "Windows 2000 /SP2"       
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win2000Sp3"   :CompatibilitySystem()\OSModus_Description$ = "Windows 2000 /SP3"      
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXP"        :CompatibilitySystem()\OSModus_Description$ = "Windows XP"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp1"     :CompatibilitySystem()\OSModus_Description$ = "Windows XP /SP1"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp2"     :CompatibilitySystem()\OSModus_Description$ = "Windows XP /SP2"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp2_GW"  :CompatibilitySystem()\OSModus_Description$ = "Windows XP /SP2 (GW)"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp3"     :CompatibilitySystem()\OSModus_Description$ = "Windows XP /SP3"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaRTM"     :CompatibilitySystem()\OSModus_Description$ = "Windows Vista RTM"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaRTM_GW"  :CompatibilitySystem()\OSModus_Description$ = "Windows Vista RTM (GW)"        
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaSP1"     :CompatibilitySystem()\OSModus_Description$ = "Windows Vista /SP1"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaSP2"     :CompatibilitySystem()\OSModus_Description$ = "Windows Vista /SP2"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win7RTM"      :CompatibilitySystem()\OSModus_Description$ = "Windows 7 /RTM"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "NT4SP5"       :CompatibilitySystem()\OSModus_Description$ = "WindowsNT4 /SP5"        
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv03"     :CompatibilitySystem()\OSModus_Description$ = "Server 2003"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv03Sp1"  :CompatibilitySystem()\OSModus_Description$ = "Server 2003 /SP1"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv08R2RTM":CompatibilitySystem()\OSModus_Description$ = "Server 2008R2 /RTM"
        AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv08SP1"  :CompatibilitySystem()\OSModus_Description$ = "Server 2008 /SP1"          
        
        ResetList(CompatibilitySystem())
        Max_Saves_List = ListSize(CompatibilitySystem()) 
        For i = 0 To Max_Saves_List
            NextElement(CompatibilitySystem())
            CompatibilitySystem()\OSIDX = i
            CompatibilitySystem()\MenuIndex = 261+i ; Menu Item Index                        
        Next

        SortStructuredList(CompatibilitySystem(), #PB_Sort_Ascending, OffsetOf(CmpOSModus\OSIDX), #PB_Integer)
    
    EndProcedure    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure.s Get_WindowsVersion(iSelect=0)
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
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////

    Procedure.s DataVersionFix(Value$)

        Select Val(Get_WindowsVersion())
            Case 51 To 61
                Debug "Windows XP/Windows 7"
                ProcedureReturn Value$
            Case 62 To 99
                Debug "Windows 8/ Windows 9"
                ProcedureReturn "~ "+Value$
            Default
                Debug "OS: '"+Get_WindowsVersion(4)+"' Wird nicht unterstützt"
                ;Request::MSG(Startup::*LHGameDB\TitleVersion, "ERROR:","vSystems doesn't Support the OS: '"+Get_WindowsVersion(4)+"'",2,2,"",0,0,DC::#_Window_001)
                ;End        
        EndSelect
        
    EndProcedure    
      ;-----------------------------------------------------------------------------------------------        
      ; DataVersionFix(Value$), Gibt den richtigen String für die Kompatibilitäts Fixex zurück
      ; Seit Windows 8/Windows 9 wird eine Tilde '~' an den Kompatibilitätsfixes mit angehängt
      ; Resukt = Compatibilty::DataVersionFix(Value$) als letztes Kommando mit dem String der Sammlung
      ; an fixes übergeben
      ;-----------------------------------------------------------------------------------------------         
EndModule

; UseModule Compatibility
;     DataModes(CompatibilitySystem.CmpOSModus(), CompatibilityEmulation.CmpEmulation())
;     UnuseModule Compatibility
; 
;     ResetList(Compatibility::CompatibilitySystem())
;                     
;     For i = 0 To ListSize(Compatibility::CompatibilitySystem()) 
;                  NextElement(Compatibility::CompatibilitySystem())
;                  sCmpMod$ = Compatibility::CompatibilitySystem()\OSModus$
;                             
;                  Debug "Compatibility Modus:"
;                  Debug "- Gefunden: " + sCmpMod$                                                   
;     Next
;Compatibilty::DataVersionFix("Hallo")
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 121
; FirstLine = 93
; Folding = 4
; EnableAsm
; EnableXP
; EnableUnicode