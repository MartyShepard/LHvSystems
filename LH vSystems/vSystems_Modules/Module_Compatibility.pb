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
        
;Compatibility available IN Windows 10
;
; 32-bit Compatibility Modes (90)
;
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "16BitColor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "256Color"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "640X480"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitAggregateBlts"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitDXMaxWinMode"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitGDIRedraw"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitTimedPriSync"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ApplicationMonitor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AppRecorder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Arm64Wow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsVista"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsWin7"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsWin8"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsXP"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Disable8And16BitD3D"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Disable8And16BitModes"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableCicero"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableFadeAnimations"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNXHideUI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNXShowUI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableThemeMenus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableThemes"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableUserCallbackException"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DW"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DWM8And16BitMitigation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXMaximizedWindowedMode"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ElevateCreateProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSorting"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingServer2008"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingVista"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingWindows61"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableNXShowUI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FaultTolerantHeap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FDR"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FixDisplayChangeRefreshRate"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FontMigration"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDxSetupSuccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleRegExpandSzRegistryKeys"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HighDpiAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreAdobeKMPrintDriverMessageBox"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFreeLibrary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Installer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "International"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "iTunesAutoplay"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Layer_Force640x480x8"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Layer_ForceDirectDrawEmulation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Layer_Win95VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadLibraryRedirect"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MsiAuto"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoDTToDITMouseBatch"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NT4SP5"					--- Siehe Weiter Unten
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NullEnvironment"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProfilesSetup"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectCHHlocaletoCHT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsAdmin"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest_GW"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsInvoker"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VerifyVersionInfoLiteLayer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeDeleteFileLayer"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaRTM"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaRTM_GW"				--- Siehe Weiter Unten
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSetup"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1VersionLie"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2VersionLie"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000Sp2"				--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000Sp3"				--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win7RTM"					--- Siehe Weiter Unten
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win7RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win81RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win8RTM"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win8RTMVersionLie"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win95"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win98"					--- Siehe Weiter Unten
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Windows8RC"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinSrv03"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinSrv03Sp1"				--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinSrv08R2RTM"			--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinSrv08SP1"				--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXP"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSp1"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSp2"					--- Siehe Weiter Unten
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSp2_GW"				--- Siehe Weiter Unten
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP2VersionLie"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSp3"					--- Siehe Weiter Unten
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP3VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPMitigation"
        ;
        
        
;64-bit Compatibility Modes (36)
;
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ApplicationMonitor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsVista"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsWin7"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorsWin8"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableUserCallbackException"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DW"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingServer2008"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingVista"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingWindows61"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FaultTolerantHeap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FontMigration"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HighDpiAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFreeLibrary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Installer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadLibraryRedirect"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MsiAuto"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoDTToDITMouseBatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsAdmin"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsInvoker"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VerifyVersionInfoLiteLayer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeDeleteFileLayer"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaRTM"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1VersionLie"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2VersionLie"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win7RTM"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win7RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win81RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win8RTM"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win8RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Windows8RC"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinSrv08R2RTM"
        ;AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinSrv08SP1"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPMitigation"
;
;32-bit Compatibility Fixes (411)
;
;Compatibility Fixes
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitTimedPriSync"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AccelGdipFlush"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AdditiveRunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AddProcessParametersFlags"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AddRestrictedSidInCoInitializeSecurity"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AddWritePermissionsToDeviceFiles"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AliasDXDC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AllocDebugInfoForCritSections"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AllowDesktopSetProp"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AllowMaximizedWindowGamma"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AlwaysActiveMenus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "APILogger"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AspNetRegiis11"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "BIOSRead"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "BlockRunAsInteractiveUser"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ChangeAuthenticationLevel"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ChangeFolderPathToXPStyle"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ClearLastErrorStatusonIntializeCriticalSection"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CopyHKCUSettingsFromOtherUsers"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectACMArgs"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectACMStreamOpen"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectActiveMoviePath"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectBitmapHeader"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectCreateBrushIndirectHatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectCreateEventName"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectCreateIcon"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectCreateSurface"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectDayName"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectFarEastFont"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectFilePathInSetDlgItemText"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectFilePaths"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectFilePathsUninstall"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectInactiveBorder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectOpenFileExclusive"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectShellExecuteHWND"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectShortDateFormat"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectSoundDeviceId"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectVerInstallFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CreateDummyProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CreateWindowConstrainSize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CUASAppFix"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CustomNCRender"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DecorateConnectionString"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DelayAppDllMain"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DelayApplyFlag"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DelayDllInit"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DelayShowGroup"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DelayWin95VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DelayWinMMCallback"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeleteAndCopy"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeleteFileToStopDriverAndDelete"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeleteSpecifiedFiles"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeprecatedServiceShim"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeRandomizeExeName"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DetectorDWM8And16Bit"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DirectPlayEnumOrder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DirectXTrimTextureFormats"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DirectXVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableAdvancedRPCrangeCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableAdvanceRPCClientHardening"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableAnimation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableBoostThread"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableExceptionChainValidation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableFadeAnimations"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableFilterKeys"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableFocusTracking"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableKeyboardAutoInvocation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableKeyboardCues"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableMaybeNULLSizeisConsistencycheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNDRIIDConsistencyCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNewWMPAINTDispatchInOLE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNX"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNXPageProtection"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableScreenSaver"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableStickyKeys"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableSWCursorOnMoveSize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableThemeMenus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableThemes"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableW2KOwnerDrawButtonStates"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableWindowArrangement"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableWindowsDefender"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisallowCOMBindingNotifications"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DPIUnaware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DuplicateHandleFix"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXGICompat"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXMaximizedWindowedMode"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXPrimaryClipping"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXPrimaryEmulation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EarlyMouseDelegation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ElevateCreateProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmptyClipboardtoSet"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateBitmapStride"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateCDFS"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateClipboardDIBFormat"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateCreateFileMapping"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateCreateProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateCursor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateDeleteObject"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateDirectDrawSync"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateDrawText"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateEnvironmentBlock"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateFindHandles"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetCommandLine"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetDeviceCaps"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetDiskFreeSpace"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetProfileString"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetStdHandle"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetStringType"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateGetUIEffects"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateHeap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateIME"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateJoystick"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateLZHandles"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateMissingEXE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateOldPathIsUNC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulatePlaySound"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulatePrinter"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSHGetFileInfo"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSlowCPU"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSorting"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingServer2008"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingVista"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingWindows61"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateTextColor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateToolHelp32"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateUSER"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateVerQueryValue"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateWriteFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableAppConfig"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableDEP"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyExceptionHandlinginOLE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyExceptionHandlingInRPC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyLoadTypeLibForRelativePaths"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyNTFSFlagsForDocfileOpens"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableRestarts"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnlargeGetObjectBufferSize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnterUninitializedCriticalSection"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ExtraAddRefDesktopFolder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ExtractAssociatedIcon"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FailCloseProfileUserMapping"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FailGetStdHandle"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FailObsoleteShellAPIs"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FailOpenFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FailRemoveDirectory"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FakeLunaTheme"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FakeThemeMetrics"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FaultTolerantHeap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FeedbackReport"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FileVersionInfoLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FilterNetworkResources"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FixDisplayChangeRefreshRate"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FixSectionProtection"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FixServiceStartupCircularDependency"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FixSubclassCallingConvention"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FlushFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FontMigration"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Force640x480"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Force640x480x16"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Force640x480x8"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Force8BitColor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceAdminAccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceAnsiGetDisplayNameOf"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceAnsiWindowProc"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceAppendMenuSuccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceApplicationFocus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceAVIWindow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceCDStop"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceCoInitialize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDefaultSystemPaletteEntries"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDirectDrawEmulation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDirectDrawWait"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDisplayMode"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceDXSetupSuccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceInvalidateOnClose"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceInvalidateOnClose2"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceKeepFocus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceKeyWOW6464Key"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceMessageBoxFocus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceSeparateVDM"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceShellLinkResolveNoUI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceSimpleWindow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceTemporaryModeChange"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceWorkingDirectoryToEXEPath"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FUSBadApplicationType1"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FUSBadApplicationType2"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FUSBadApplicationType3"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FUSBadApplicationType4"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GenericInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetDiskFreeSpace2GB"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetDriveTypeWHook"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetShortPathNameNT4"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetTopWindowToShellWnd"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetVolumeInformationLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GiveupForeground"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GlobalMemoryStatus2GB"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GlobalMemoryStatusLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GrabMatchingInformation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleAPIExceptions"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleBadPtr"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleDBCSUserName"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleDBCSUserName2"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleEmptyAccessCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleIELaunch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleMarkedContentNotIndexed"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleRegExpandSzRegistryKeys"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleWvsprintfExceptions"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HardwareAudioMixer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapClearAllocation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapDelayLocalFree"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapForceGrowable"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapIgnoreMoveable"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapLookasideFree"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapPadAllocation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HeapValidateFrees"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HideCursor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HideDisplayModes"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HideTaskBar"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HighDpiAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IEUnHarden"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreAltTab"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreChromeSandbox"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreCoCreateInstance"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreCRTExit"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreDebugOutput"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreDirectoryJunction"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreException"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFloatingPointRoundingControl"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFontQuality"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFreeConsole"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFreeLibrary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreHungAppPaint"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreLoadLibrary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreMCISTOP"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreMessageBox"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreMSOXMLMF"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreNoModeChange"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreOemToChar"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreOleUninitialize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreScheduler"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreSetROP2"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreSysColChanges"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreTAPIDisconnect"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreVBOverflow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreWM_CHARRepeatCount"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreZeroMoveWindow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InjectDll"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InstallComponent"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InstallFonts"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InstallShieldInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InternetSetFeatureEnabled"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "KeepWindowOnMonitor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LanguageNeutralGetFileVersionInfo"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LazyReleaseDC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LimitFindFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadComctl32Version5"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadLibraryCWD"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadLibraryRedirectFlag"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LocalMappedObject"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LowerThreadPriority"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LUA_RegOpenKey_OnlyAsk_KeyRead"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MakeShortcutRunAs"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ManageLinks"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MapMemoryB0000"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MirrorDriverDrawCursor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MirrorDriverWithComposition"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MoveIniToRegistry"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MoveToCopyFileShim"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MoveWinInitRenameToReg"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoDTToDITMouseBatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoGdiBatching"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoGDIHWAcceleration"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoGhost"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoHardeningLoadResource"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NonElevatedIDriver"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoPaddedBorder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoShadow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoSignatureCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoTimerCoalescing"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoVirtualization"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoVirtWndRects"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NullEnvironment"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NullHwndInMessageBox"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Ole32ValidatePointers"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "OpenDirectoryAcl"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "OpenGLEmfAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "OverrideShellAppCompatFlags"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PaletteRestore"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PopulateDefaultHKCUSettings"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PreInitApplication"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PreInstallDriver"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PreventMouseInPointer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PrinterIsolationAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProcessPerfData"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProfilesEnvStrings"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProfilesGetFolderPath"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProfilesRegQueryValueEx"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PromoteDAM"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PromotePointer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PropagateProcessHistory"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ProtectedAdminCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RecopyExeFromCD"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectBDE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectCHHlocaletoCHT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectCRTTempFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectDBCSTempPath"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectDefaultAudioToCommunications"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectEXE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectHKCUKeys"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectMP3Codec"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectShortCut"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectWindowsDirToSystem32"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RegistryReflector"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RelaunchElevated"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveBroadcastPostMessage"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveDDEFlagFromShellExecuteEx"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveInvalidW2KWindowStyles"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveIpFromMsInfoCommandLine"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveNoBufferingFlagFromCreateFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveOverlappedFlagFromCreateFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RemoveReadOnlyAttribute"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ReorderWaveForCommunications"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RepairStringVersionResources"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RestoreSystemCursors"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RetryOpenSCManagerWithReadAccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RetryOpenServiceWithReadAccess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsAdmin"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsInvoker"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ScreenCaptureBinary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SearchPathInAppPaths"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SessionShim"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SetEnvironmentVariable"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SetProtocolHandler"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SetupCommitFileQueueIgnoreWow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ShellExecuteNoZone"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ShellExecuteXP"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ShimViaEAT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ShowWindowIE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Shrinker"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SingleProcAffinity"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SkipDLLRegister"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SpecificInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SpecificNonInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "StackSwap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "StrictLLHook"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SyncSystemAndSystem32"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SystemMetricsLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "TerminateExe"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "TrimDisplayDeviceNames"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "TrimVersionInfo"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UIPIEnableCustomMsgs"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UIPIEnableStandardMsgs"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UnMirrorImageList"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseHighResolutionMouseWheel"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseIntegratedGraphics"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseLegacyMouseWheelRouting"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseLowResolutionMouseWheel"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UserDisableForwarderPatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseSlowMouseWheelScrolling"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseWARPRendering"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeDeleteFile"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeDesktopPainting"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeHKCRLite"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeRegisterTypeLib"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualRegistry"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaRTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WaitAfterCreateProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WaveOutIgnoreBadFormat"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WaveOutUsePreferredDevice"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WerDisableReportException"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP2VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP3VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2k3RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2k3SP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win7RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win81RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win8RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win95VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win98VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinExecRaceConditionFix"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinG32SysToSys32"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinNT4SP5VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP2VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPSP3VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXPVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF_NOWAITFORINPUTIDLE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF_USER_DDENOSYNC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_DELAYTIMEGETTIME"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_FIXLUNATRAYRECT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_HACKPROFILECALL"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_HACKWINFLAGS"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_SETFOREGROUND"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_SYNCSYSFILE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_USEMINIMALENVIRONMENT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_DISPMODE256"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_DIVIDEOVERFLOWPATCH"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_EATDEVMODEMSG"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_FORCEINCDPMI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_PLATFORMVERSIONLIE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_USEWINHELP32"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_WIN31VERSIONLIE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_ZEROINITMEMORY"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPDllRegister"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPMitigation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPRegDeleteKey"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "XPAfxIsValidAddress"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "XPFileDialog"
;
;64-bit Compatibility Fixes (134)
;
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "8And16BitTimedPriSync"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AccelGdipFlush"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AdditiveRunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AddProcessParametersFlags"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AddRestrictedSidInCoInitializeSecurity"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AllocDebugInfoForCritSections"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AllowMaximizedWindowGamma"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "AlwaysActiveMenus"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CopyHKCUSettingsFromOtherUsers"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectFilePaths"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CorrectShellExecuteHWND"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CreateDummyProcess"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "CreateWindowConstrainSize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeleteFileToStopDriverAndDelete"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DeprecatedServiceShim"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableAdvancedRPCrangeCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableAdvanceRPCClientHardening"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableAnimation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableExceptionChainValidation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableFocusTracking"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableKeyboardAutoInvocation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableKeyboardCues"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableMaybeNULLSizeisConsistencycheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNDRIIDConsistencyCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableNewWMPAINTDispatchInOLE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableSWCursorOnMoveSize"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableWindowArrangement"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisableWindowsDefender"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DisallowCOMBindingNotifications"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DPIUnaware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "DXGICompat"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EarlyMouseDelegation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateCursor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingServer2008"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingVista"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EmulateSortingWindows61"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableAppConfig"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableDEP"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyExceptionHandlinginOLE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyExceptionHandlingInRPC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyLoadTypeLibForRelativePaths"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "EnableLegacyNTFSFlagsForDocfileOpens"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FaultTolerantHeap"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FileVersionInfoLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "FontMigration"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ForceKeyWOW6464Key"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GenericInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetDiskFreeSpace2GB"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetShortPathNameNT4"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GetTopWindowToShellWnd"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "GiveupForeground"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HandleIELaunch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HardwareAudioMixer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "HighDpiAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFreeConsole"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "IgnoreFreeLibrary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InstallComponent"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "InstallFonts"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "LoadLibraryRedirectFlag"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MakeShortcutRunAs"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "MirrorDriverDrawCursor"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoDTToDITMouseBatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoGdiBatching"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoGDIHWAcceleration"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoGhost"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoPaddedBorder"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoShadow"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoSignatureCheck"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoTimerCoalescing"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoVirtualization"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "NoVirtWndRects"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Ole32ValidatePointers"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "OpenGLEmfAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "OverrideShellAppCompatFlags"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PreventMouseInPointer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PrinterIsolationAware"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PromoteDAM"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "PromotePointer"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectDefaultAudioToCommunications"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectHKCUKeys"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RedirectShortCut"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RegistryReflector"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RelaunchElevated"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ReorderWaveForCommunications"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsAdmin"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsHighest"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "RunAsInvoker"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "ScreenCaptureBinary"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SetEnvironmentVariable"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SetProtocolHandler"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SpecificInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SpecificNonInstaller"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "StrictLLHook"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "SystemMetricsLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "TerminateExe"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseHighResolutionMouseWheel"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseIntegratedGraphics"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseLegacyMouseWheelRouting"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseLowResolutionMouseWheel"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UserDisableForwarderPatch"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseSlowMouseWheelScrolling"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "UseWARPRendering"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualizeHKCRLite"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VirtualRegistry"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaRTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "VistaSP2VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP2VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000SP3VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2000VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win2k3SP1VersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win7RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win81RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "Win8RTMVersionLie"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF_NOWAITFORINPUTIDLE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF_USER_DDENOSYNC"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_DELAYTIMEGETTIME"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_FIXLUNATRAYRECT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_HACKPROFILECALL"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_HACKWINFLAGS"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_SETFOREGROUND"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_SYNCSYSFILE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCF2_USEMINIMALENVIRONMENT"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_DISPMODE256"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_DIVIDEOVERFLOWPATCH"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_EATDEVMODEMSG"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_FORCEINCDPMI"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_PLATFORMVERSIONLIE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_USEWINHELP32"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_WIN31VERSIONLIE"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WOWCFEX_ZEROINITMEMORY"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPMitigation"
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WRPRegDeleteKey"        
        AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Emulation$ = "WinXXMode"          
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


; 	Compatibility available IN Windows 10
; 	
; 	32-bit Compatibility Modes (90)
; 	
; 	16BitColor	
; 	256Color	
; 	640X480	
; 	8And16BitAggregateBlts	
; 	8And16BitDXMaxWinMode	
; 	8And16BitGDIRedraw	
; 	8And16BitTimedPriSync	
; 	ApplicationMonitor	
; 	AppRecorder	
; 	Arm64Wow	
; 	DetectorsVista	
; 	DetectorsWin7	
; 	DetectorsWin8	
; 	DetectorsXP	
; 	Disable8And16BitD3D	
; 	Disable8And16BitModes	
; 	DisableCicero	
; 	DisableFadeAnimations	
; 	DisableNXHideUI	
; 	DisableNXShowUI	
; 	DisableThemeMenus	
; 	DisableThemes	
; 	DisableUserCallbackException	
; 	DW	
; 	DWM8And16BitMitigation	
; 	DXMaximizedWindowedMode	
; 	ElevateCreateProcess	
; 	EmulateSorting	
; 	EmulateSortingServer2008	
; 	EmulateSortingVista	
; 	EmulateSortingWindows61	
; 	EnableNXShowUI	
; 	FaultTolerantHeap	
; 	FDR	
; 	FixDisplayChangeRefreshRate	
; 	FontMigration	
; 	ForceDxSetupSuccess	
; 	HandleRegExpandSzRegistryKeys	
; 	HighDpiAware	
; 	IgnoreAdobeKMPrintDriverMessageBox	
; 	IgnoreFreeLibrary	
; 	Installer	
; 	International	
; 	iTunesAutoplay	
; 	Layer_Force640x480x8	
; 	Layer_ForceDirectDrawEmulation	
; 	Layer_Win95VersionLie	
; 	LoadLibraryRedirect	
; 	MsiAuto	
; 	NoDTToDITMouseBatch	
; 	NT4SP5	
; 	NullEnvironment	
; 	ProfilesSetup	
; 	RedirectCHHlocaletoCHT	
; 	RunAsAdmin	
; 	RunAsHighest	
; 	RunAsHighest_GW	
; 	RunAsInvoker	
; 	VerifyVersionInfoLiteLayer	
; 	VirtualizeDeleteFileLayer	
; 	VistaRTM	
; 	VistaRTM_GW	
; 	VistaSetup	
; 	VistaSP1	
; 	VistaSP1VersionLie	
; 	VistaSP2	
; 	VistaSP2VersionLie	
; 	Win2000	
; 	Win2000Sp2	
; 	Win2000Sp3	
; 	Win7RTM	
; 	Win7RTMVersionLie	
; 	Win81RTMVersionLie	
; 	Win8RTM	
; 	Win8RTMVersionLie	
; 	Win95	
; 	Win98	
; 	Windows8RC	
; 	WinSrv03	
; 	WinSrv03Sp1	
; 	WinSrv08R2RTM	
; 	WinSrv08SP1	
; 	WinXP	
; 	WinXPSp1	
; 	WinXPSp2	
; 	WinXPSp2_GW	
; 	WinXPSP2VersionLie	
; 	WinXPSp3	
; 	WinXPSP3VersionLie	
; 	WRPMitigation	
; 	
; 	64-bit Compatibility Modes (36)
; 	
; 	ApplicationMonitor	
; 	DetectorsVista	
; 	DetectorsWin7	
; 	DetectorsWin8	
; 	DisableUserCallbackException	
; 	DW	
; 	EmulateSortingServer2008	
; 	EmulateSortingVista	
; 	EmulateSortingWindows61	
; 	FaultTolerantHeap	
; 	FontMigration	
; 	HighDpiAware	
; 	IgnoreFreeLibrary	
; 	Installer	
; 	LoadLibraryRedirect	
; 	MsiAuto	
; 	NoDTToDITMouseBatch	
; 	RunAsAdmin	
; 	RunAsHighest	
; 	RunAsInvoker	
; 	VerifyVersionInfoLiteLayer	
; 	VirtualizeDeleteFileLayer	
; 	VistaRTM	
; 	VistaSP1	
; 	VistaSP1VersionLie	
; 	VistaSP2	
; 	VistaSP2VersionLie	
; 	Win7RTM	
; 	Win7RTMVersionLie	
; 	Win81RTMVersionLie	
; 	Win8RTM	
; 	Win8RTMVersionLie	
; 	Windows8RC	
; 	WinSrv08R2RTM	
; 	WinSrv08SP1	
; 	WRPMitigation	
; 	
; 	32-bit Compatibility Fixes (411)
; 	
; 	Compatibility Fixes	
; 	8And16BitTimedPriSync	
; 	AccelGdipFlush	
; 	AdditiveRunAsHighest	
; 	AddProcessParametersFlags	
; 	AddRestrictedSidInCoInitializeSecurity	
; 	AddWritePermissionsToDeviceFiles	
; 	AliasDXDC	
; 	AllocDebugInfoForCritSections	
; 	AllowDesktopSetProp	
; 	AllowMaximizedWindowGamma	
; 	AlwaysActiveMenus	
; 	APILogger	
; 	AspNetRegiis11	
; 	BIOSRead	
; 	BlockRunAsInteractiveUser	
; 	ChangeAuthenticationLevel	
; 	ChangeFolderPathToXPStyle	
; 	ClearLastErrorStatusonIntializeCriticalSection	
; 	CopyHKCUSettingsFromOtherUsers	
; 	CorrectACMArgs	
; 	CorrectACMStreamOpen	
; 	CorrectActiveMoviePath	
; 	CorrectBitmapHeader	
; 	CorrectCreateBrushIndirectHatch	
; 	CorrectCreateEventName	
; 	CorrectCreateIcon	
; 	CorrectCreateSurface	
; 	CorrectDayName	
; 	CorrectFarEastFont	
; 	CorrectFilePathInSetDlgItemText	
; 	CorrectFilePaths	
; 	CorrectFilePathsUninstall	
; 	CorrectInactiveBorder	
; 	CorrectOpenFileExclusive	
; 	CorrectShellExecuteHWND	
; 	CorrectShortDateFormat	
; 	CorrectSoundDeviceId	
; 	CorrectVerInstallFile	
; 	CreateDummyProcess	
; 	CreateWindowConstrainSize	
; 	CUASAppFix	
; 	CustomNCRender	
; 	DecorateConnectionString	
; 	DelayAppDllMain	
; 	DelayApplyFlag	
; 	DelayDllInit	
; 	DelayShowGroup	
; 	DelayWin95VersionLie	
; 	DelayWinMMCallback	
; 	DeleteAndCopy	
; 	DeleteFileToStopDriverAndDelete	
; 	DeleteSpecifiedFiles	
; 	DeprecatedServiceShim	
; 	DeRandomizeExeName	
; 	DirectPlayEnumOrder	
; 	DirectXTrimTextureFormats	
; 	DirectXVersionLie	
; 	DisableAdvancedRPCrangeCheck	
; 	DisableAdvanceRPCClientHardening	
; 	DisableAnimation	
; 	DisableBoostThread	
; 	DisableExceptionChainValidation	
; 	DisableFadeAnimations	
; 	DisableFilterKeys	
; 	DisableFocusTracking	
; 	DisableKeyboardAutoInvocation	
; 	DisableKeyboardCues	
; 	DisableMaybeNULLSizeisConsistencycheck	
; 	DisableNDRIIDConsistencyCheck	
; 	DisableNewWMPAINTDispatchInOLE	
; 	DisableNX	
; 	DisableNXPageProtection	
; 	DisableScreenSaver	
; 	DisableStickyKeys	
; 	DisableSWCursorOnMoveSize	
; 	DisableThemeMenus	
; 	DisableThemes	
; 	DisableW2KOwnerDrawButtonStates	
; 	DisableWindowArrangement	
; 	DisableWindowsDefender	
; 	DisallowCOMBindingNotifications	
; 	DPIUnaware	
; 	DuplicateHandleFix	
; 	DXGICompat	
; 	DXMaximizedWindowedMode	
; 	DXPrimaryClipping	
; 	DXPrimaryEmulation	
; 	EarlyMouseDelegation	
; 	ElevateCreateProcess	
; 	EmptyClipboardtoSet	
; 	EmulateBitmapStride	
; 	EmulateCDFS	
; 	EmulateClipboardDIBFormat	
; 	EmulateCreateFileMapping	
; 	EmulateCreateProcess	
; 	EmulateCursor	
; 	EmulateDeleteObject	
; 	EmulateDirectDrawSync	
; 	EmulateDrawText	
; 	EmulateEnvironmentBlock	
; 	EmulateFindHandles	
; 	EmulateGetCommandLine	
; 	EmulateGetDeviceCaps	
; 	EmulateGetDiskFreeSpace	
; 	EmulateGetProfileString	
; 	EmulateGetStdHandle	
; 	EmulateGetStringType	
; 	EmulateGetUIEffects	
; 	EmulateHeap	
; 	EmulateIME	
; 	EmulateJoystick	
; 	EmulateLZHandles	
; 	EmulateMissingEXE	
; 	EmulateOldPathIsUNC	
; 	EmulatePlaySound	
; 	EmulatePrinter	
; 	EmulateSHGetFileInfo	
; 	EmulateSlowCPU	
; 	EmulateSorting	
; 	EmulateSortingServer2008	
; 	EmulateSortingVista	
; 	EmulateSortingWindows61	
; 	EmulateTextColor	
; 	EmulateToolHelp32	
; 	EmulateUSER	
; 	EmulateVerQueryValue	
; 	EmulateWriteFile	
; 	EnableAppConfig	
; 	EnableDEP	
; 	EnableLegacyExceptionHandlinginOLE	
; 	EnableLegacyExceptionHandlingInRPC	
; 	EnableLegacyLoadTypeLibForRelativePaths	
; 	EnableLegacyNTFSFlagsForDocfileOpens	
; 	EnableRestarts	
; 	EnlargeGetObjectBufferSize	
; 	EnterUninitializedCriticalSection	
; 	ExtraAddRefDesktopFolder	
; 	ExtractAssociatedIcon	
; 	FailCloseProfileUserMapping	
; 	FailGetStdHandle	
; 	FailObsoleteShellAPIs	
; 	FailOpenFile	
; 	FailRemoveDirectory	
; 	FakeLunaTheme	
; 	FakeThemeMetrics	
; 	FaultTolerantHeap	
; 	FeedbackReport	
; 	FileVersionInfoLie	
; 	FilterNetworkResources	
; 	FixDisplayChangeRefreshRate	
; 	FixSectionProtection	
; 	FixServiceStartupCircularDependency	
; 	FixSubclassCallingConvention	
; 	FlushFile	
; 	FontMigration	
; 	Force640x480	
; 	Force640x480x16	
; 	Force640x480x8	
; 	Force8BitColor	
; 	ForceAdminAccess	
; 	ForceAnsiGetDisplayNameOf	
; 	ForceAnsiWindowProc	
; 	ForceAppendMenuSuccess	
; 	ForceApplicationFocus	
; 	ForceAVIWindow	
; 	ForceCDStop	
; 	ForceCoInitialize	
; 	ForceDefaultSystemPaletteEntries	
; 	ForceDirectDrawEmulation	
; 	ForceDirectDrawWait	
; 	ForceDisplayMode	
; 	ForceDXSetupSuccess	
; 	ForceInvalidateOnClose	
; 	ForceInvalidateOnClose2	
; 	ForceKeepFocus	
; 	ForceKeyWOW6464Key	
; 	ForceMessageBoxFocus	
; 	ForceSeparateVDM	
; 	ForceShellLinkResolveNoUI	
; 	ForceSimpleWindow	
; 	ForceTemporaryModeChange	
; 	ForceWorkingDirectoryToEXEPath	
; 	FUSBadApplicationType1	
; 	FUSBadApplicationType2	
; 	FUSBadApplicationType3	
; 	FUSBadApplicationType4	
; 	GenericInstaller	
; 	GetDiskFreeSpace2GB	
; 	GetDriveTypeWHook	
; 	GetShortPathNameNT4	
; 	GetTopWindowToShellWnd	
; 	GetVolumeInformationLie	
; 	GiveupForeground	
; 	GlobalMemoryStatus2GB	
; 	GlobalMemoryStatusLie	
; 	GrabMatchingInformation	
; 	HandleAPIExceptions	
; 	HandleBadPtr	
; 	HandleDBCSUserName	
; 	HandleDBCSUserName2	
; 	HandleEmptyAccessCheck	
; 	HandleIELaunch	
; 	HandleMarkedContentNotIndexed	
; 	HandleRegExpandSzRegistryKeys	
; 	HandleWvsprintfExceptions	
; 	HardwareAudioMixer	
; 	HeapClearAllocation	
; 	HeapDelayLocalFree	
; 	HeapForceGrowable	
; 	HeapIgnoreMoveable	
; 	HeapLookasideFree	
; 	HeapPadAllocation	
; 	HeapValidateFrees	
; 	HideCursor	
; 	HideDisplayModes	
; 	HideTaskBar	
; 	HighDpiAware	
; 	IEUnHarden	
; 	IgnoreAltTab	
; 	IgnoreChromeSandbox	
; 	IgnoreCoCreateInstance	
; 	IgnoreCRTExit	
; 	IgnoreDebugOutput	
; 	IgnoreDirectoryJunction	
; 	IgnoreException	
; 	IgnoreFloatingPointRoundingControl	
; 	IgnoreFontQuality	
; 	IgnoreFreeConsole	
; 	IgnoreFreeLibrary	
; 	IgnoreHungAppPaint	
; 	IgnoreLoadLibrary	
; 	IgnoreMCISTOP	
; 	IgnoreMessageBox	
; 	IgnoreMSOXMLMF	
; 	IgnoreNoModeChange	
; 	IgnoreOemToChar	
; 	IgnoreOleUninitialize	
; 	IgnoreScheduler	
; 	IgnoreSetROP2	
; 	IgnoreSysColChanges	
; 	IgnoreTAPIDisconnect	
; 	IgnoreVBOverflow	
; 	IgnoreWM_CHARRepeatCount	
; 	IgnoreZeroMoveWindow	
; 	InjectDll	
; 	InstallComponent	
; 	InstallFonts	
; 	InstallShieldInstaller	
; 	InternetSetFeatureEnabled	
; 	KeepWindowOnMonitor	
; 	LanguageNeutralGetFileVersionInfo	
; 	LazyReleaseDC	
; 	LimitFindFile	
; 	LoadComctl32Version5	
; 	LoadLibraryCWD	
; 	LoadLibraryRedirectFlag	
; 	LocalMappedObject	
; 	LowerThreadPriority	
; 	LUA_RegOpenKey_OnlyAsk_KeyRead	
; 	MakeShortcutRunAs	
; 	ManageLinks	
; 	MapMemoryB0000	
; 	MirrorDriverDrawCursor	
; 	MirrorDriverWithComposition	
; 	MoveIniToRegistry	
; 	MoveToCopyFileShim	
; 	MoveWinInitRenameToReg	
; 	NoDTToDITMouseBatch	
; 	NoGdiBatching	
; 	NoGDIHWAcceleration	
; 	NoGhost	
; 	NoHardeningLoadResource	
; 	NonElevatedIDriver	
; 	NoPaddedBorder	
; 	NoShadow	
; 	NoSignatureCheck	
; 	NoTimerCoalescing	
; 	NoVirtualization	
; 	NoVirtWndRects	
; 	NullEnvironment	
; 	NullHwndInMessageBox	
; 	Ole32ValidatePointers	
; 	OpenDirectoryAcl	
; 	OpenGLEmfAware	
; 	OverrideShellAppCompatFlags	
; 	PaletteRestore	
; 	PopulateDefaultHKCUSettings	
; 	PreInitApplication	
; 	PreInstallDriver	
; 	PreventMouseInPointer	
; 	PrinterIsolationAware	
; 	ProcessPerfData	
; 	ProfilesEnvStrings	
; 	ProfilesGetFolderPath	
; 	ProfilesRegQueryValueEx	
; 	PromoteDAM	
; 	PromotePointer	
; 	PropagateProcessHistory	
; 	ProtectedAdminCheck	
; 	RecopyExeFromCD	
; 	RedirectBDE	
; 	RedirectCHHlocaletoCHT	
; 	RedirectCRTTempFile	
; 	RedirectDBCSTempPath	
; 	RedirectDefaultAudioToCommunications	
; 	RedirectEXE	
; 	RedirectHKCUKeys	
; 	RedirectMP3Codec	
; 	RedirectShortCut	
; 	RedirectWindowsDirToSystem32	
; 	RegistryReflector	
; 	RelaunchElevated	
; 	RemoveBroadcastPostMessage	
; 	RemoveDDEFlagFromShellExecuteEx	
; 	RemoveInvalidW2KWindowStyles	
; 	RemoveIpFromMsInfoCommandLine	
; 	RemoveNoBufferingFlagFromCreateFile	
; 	RemoveOverlappedFlagFromCreateFile	
; 	RemoveReadOnlyAttribute	
; 	ReorderWaveForCommunications	
; 	RepairStringVersionResources	
; 	RestoreSystemCursors	
; 	RetryOpenSCManagerWithReadAccess	
; 	RetryOpenServiceWithReadAccess	
; 	RunAsAdmin	
; 	RunAsHighest	
; 	RunAsInvoker	
; 	ScreenCaptureBinary	
; 	SearchPathInAppPaths	
; 	SessionShim	
; 	SetEnvironmentVariable	
; 	SetProtocolHandler	
; 	SetupCommitFileQueueIgnoreWow	
; 	ShellExecuteNoZone	
; 	ShellExecuteXP	
; 	ShimViaEAT	
; 	ShowWindowIE	
; 	Shrinker	
; 	SingleProcAffinity	
; 	SkipDLLRegister	
; 	SpecificInstaller	
; 	SpecificNonInstaller	
; 	StackSwap	
; 	StrictLLHook	
; 	SyncSystemAndSystem32	
; 	SystemMetricsLie	
; 	TerminateExe	
; 	TrimDisplayDeviceNames	
; 	TrimVersionInfo	
; 	UIPIEnableCustomMsgs	
; 	UIPIEnableStandardMsgs	
; 	UnMirrorImageList	
; 	UseHighResolutionMouseWheel	
; 	UseIntegratedGraphics	
; 	UseLegacyMouseWheelRouting	
; 	UseLowResolutionMouseWheel	
; 	UserDisableForwarderPatch	
; 	UseSlowMouseWheelScrolling	
; 	UseWARPRendering	
; 	VirtualizeDeleteFile	
; 	VirtualizeDesktopPainting	
; 	VirtualizeHKCRLite	
; 	VirtualizeRegisterTypeLib	
; 	VirtualRegistry	
; 	VistaRTMVersionLie	
; 	VistaSP1VersionLie	
; 	VistaSP2VersionLie	
; 	WaitAfterCreateProcess	
; 	WaveOutIgnoreBadFormat	
; 	WaveOutUsePreferredDevice	
; 	WerDisableReportException	
; 	Win2000SP1VersionLie	
; 	Win2000SP2VersionLie	
; 	Win2000SP3VersionLie	
; 	Win2000VersionLie	
; 	Win2k3RTMVersionLie	
; 	Win2k3SP1VersionLie	
; 	Win7RTMVersionLie	
; 	Win81RTMVersionLie	
; 	Win8RTMVersionLie	
; 	Win95VersionLie	
; 	Win98VersionLie	
; 	WinExecRaceConditionFix	
; 	WinG32SysToSys32	
; 	WinNT4SP5VersionLie	
; 	WinXPSP1VersionLie	
; 	WinXPSP2VersionLie	
; 	WinXPSP3VersionLie	
; 	WinXPVersionLie	
; 	WOWCF_NOWAITFORINPUTIDLE	
; 	WOWCF_USER_DDENOSYNC	
; 	WOWCF2_DELAYTIMEGETTIME	
; 	WOWCF2_FIXLUNATRAYRECT	
; 	WOWCF2_HACKPROFILECALL	
; 	WOWCF2_HACKWINFLAGS	
; 	WOWCF2_SETFOREGROUND	
; 	WOWCF2_SYNCSYSFILE	
; 	WOWCF2_USEMINIMALENVIRONMENT	
; 	WOWCFEX_DISPMODE256	
; 	WOWCFEX_DIVIDEOVERFLOWPATCH	
; 	WOWCFEX_EATDEVMODEMSG	
; 	WOWCFEX_FORCEINCDPMI	
; 	WOWCFEX_PLATFORMVERSIONLIE	
; 	WOWCFEX_USEWINHELP32	
; 	WOWCFEX_WIN31VERSIONLIE	
; 	WOWCFEX_ZEROINITMEMORY	
; 	WRPDllRegister	
; 	WRPMitigation	
; 	WRPRegDeleteKey	
; 	XPAfxIsValidAddress	
; 	XPFileDialog	
; 	
; 	64-bit Compatibility Fixes (134)
; 	
; 	8And16BitTimedPriSync	
; 	AccelGdipFlush	
; 	AdditiveRunAsHighest	
; 	AddProcessParametersFlags	
; 	AddRestrictedSidInCoInitializeSecurity	
; 	AllocDebugInfoForCritSections	
; 	AllowMaximizedWindowGamma	
; 	AlwaysActiveMenus	
; 	CopyHKCUSettingsFromOtherUsers	
; 	CorrectFilePaths	
; 	CorrectShellExecuteHWND	
; 	CreateDummyProcess	
; 	CreateWindowConstrainSize	
; 	DeleteFileToStopDriverAndDelete	
; 	DeprecatedServiceShim	
; 	DisableAdvancedRPCrangeCheck	
; 	DisableAdvanceRPCClientHardening	
; 	DisableAnimation	
; 	DisableExceptionChainValidation	
; 	DisableFocusTracking	
; 	DisableKeyboardAutoInvocation	
; 	DisableKeyboardCues	
; 	DisableMaybeNULLSizeisConsistencycheck	
; 	DisableNDRIIDConsistencyCheck	
; 	DisableNewWMPAINTDispatchInOLE	
; 	DisableSWCursorOnMoveSize	
; 	DisableWindowArrangement	
; 	DisableWindowsDefender	
; 	DisallowCOMBindingNotifications	
; 	DPIUnaware	
; 	DXGICompat	
; 	EarlyMouseDelegation	
; 	EmulateCursor	
; 	EmulateSortingServer2008	
; 	EmulateSortingVista	
; 	EmulateSortingWindows61	
; 	EnableAppConfig	
; 	EnableDEP	
; 	EnableLegacyExceptionHandlinginOLE	
; 	EnableLegacyExceptionHandlingInRPC	
; 	EnableLegacyLoadTypeLibForRelativePaths	
; 	EnableLegacyNTFSFlagsForDocfileOpens	
; 	FaultTolerantHeap	
; 	FileVersionInfoLie	
; 	FontMigration	
; 	ForceKeyWOW6464Key	
; 	GenericInstaller	
; 	GetDiskFreeSpace2GB	
; 	GetShortPathNameNT4	
; 	GetTopWindowToShellWnd	
; 	GiveupForeground	
; 	HandleIELaunch	
; 	HardwareAudioMixer	
; 	HighDpiAware	
; 	IgnoreFreeConsole	
; 	IgnoreFreeLibrary	
; 	InstallComponent	
; 	InstallFonts	
; 	LoadLibraryRedirectFlag	
; 	MakeShortcutRunAs	
; 	MirrorDriverDrawCursor	
; 	NoDTToDITMouseBatch	
; 	NoGdiBatching	
; 	NoGDIHWAcceleration	
; 	NoGhost	
; 	NoPaddedBorder	
; 	NoShadow	
; 	NoSignatureCheck	
; 	NoTimerCoalescing	
; 	NoVirtualization	
; 	NoVirtWndRects	
; 	Ole32ValidatePointers	
; 	OpenGLEmfAware	
; 	OverrideShellAppCompatFlags	
; 	PreventMouseInPointer	
; 	PrinterIsolationAware	
; 	PromoteDAM	
; 	PromotePointer	
; 	RedirectDefaultAudioToCommunications	
; 	RedirectHKCUKeys	
; 	RedirectShortCut	
; 	RegistryReflector	
; 	RelaunchElevated	
; 	ReorderWaveForCommunications	
; 	RunAsAdmin	
; 	RunAsHighest	
; 	RunAsInvoker	
; 	ScreenCaptureBinary	
; 	SetEnvironmentVariable	
; 	SetProtocolHandler	
; 	SpecificInstaller	
; 	SpecificNonInstaller	
; 	StrictLLHook	
; 	SystemMetricsLie	
; 	TerminateExe	
; 	UseHighResolutionMouseWheel	
; 	UseIntegratedGraphics	
; 	UseLegacyMouseWheelRouting	
; 	UseLowResolutionMouseWheel	
; 	UserDisableForwarderPatch	
; 	UseSlowMouseWheelScrolling	
; 	UseWARPRendering	
; 	VirtualizeHKCRLite	
; 	VirtualRegistry	
; 	VistaRTMVersionLie	
; 	VistaSP1VersionLie	
; 	VistaSP2VersionLie	
; 	Win2000SP1VersionLie	
; 	Win2000SP2VersionLie	
; 	Win2000SP3VersionLie	
; 	Win2000VersionLie	
; 	Win2k3SP1VersionLie	
; 	Win7RTMVersionLie	
; 	Win81RTMVersionLie	
; 	Win8RTMVersionLie	
; 	WOWCF_NOWAITFORINPUTIDLE	
; 	WOWCF_USER_DDENOSYNC	
; 	WOWCF2_DELAYTIMEGETTIME	
; 	WOWCF2_FIXLUNATRAYRECT	
; 	WOWCF2_HACKPROFILECALL	
; 	WOWCF2_HACKWINFLAGS	
; 	WOWCF2_SETFOREGROUND	
; 	WOWCF2_SYNCSYSFILE	
; 	WOWCF2_USEMINIMALENVIRONMENT	
; 	WOWCFEX_DISPMODE256	
; 	WOWCFEX_DIVIDEOVERFLOWPATCH	
; 	WOWCFEX_EATDEVMODEMSG	
; 	WOWCFEX_FORCEINCDPMI	
; 	WOWCFEX_PLATFORMVERSIONLIE	
; 	WOWCFEX_USEWINHELP32	
; 	WOWCFEX_WIN31VERSIONLIE	
; 	WOWCFEX_ZEROINITMEMORY	
; 	WRPMitigation	
; 	WRPRegDeleteKey
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 801
; FirstLine = 746
; Folding = 4
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; Executable = ..\Release\vSystems64Bit.exe
; EnableUnicode