;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule Compatibility
	Structure CmpOSModus
		OSIDX.i
		OSModus$
		Description.s
		MenuIndex.i
		bCharSwitch.i
		bMenuSubBeg.i
		bMenuSubEnd.i
		bMenuBar.i
    MenuImageID.i		
	EndStructure        
	
	Structure CmpEmulation
		EMUIDX.i
		Modus.s
		Description.s
		MenuIndex.i
		bCharSwitch.i
		bMenuSubBeg.i
		bMenuSubEnd.i
		bMenuBar.i
    MenuImageID.i		
	EndStructure       
	
	Global NewList CompatibilitySystem.CmpOSModus()
	Global NewList CompatibilityEmulation.CmpEmulation()    
	
	
	Declare.s DataVersionFix(Value$)
	Declare DataModes(List CompatibilitySystem.CmpOSModus(), List CompatibilityEmulation.CmpEmulation())
	
	Declare.i GetMaxMnuIndex_Emulation()
	Declare.i SetMnuIndexNum_CmpEmulation()     
	
	Declare.i GetMaxMnuIndex_WindowsSystem()
	Declare.i SetMnuIndexNum_CmpWindows()
	
EndDeclareModule

; https://docs.microsoft.com/de-de/windows/deployment/planning/compatibility-fixes-for-windows-8-windows-7-and-windows-vista

Module Compatibility
	Procedure DataModes(List CompatibilitySystem.CmpOSModus(), List CompatibilityEmulation.CmpEmulation())
		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""             										:CompatibilityEmulation()\Description = "-----------------------------"   :CompatibilityEmulation()\bMenuBar = #True			
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                	:CompatibilityEmulation()\Description = "Privilege Level"									:CompatibilityEmulation()\bMenuSubBeg = #True	
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsAdmin"												:CompatibilityEmulation()\Description = "Run as Admin" 										:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest"											:CompatibilityEmulation()\Description = "Run as Highest" 									:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest_GW"									:CompatibilityEmulation()\Description = "Run as Highest GW" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsInvoker"											:CompatibilityEmulation()\Description = "Run as Invoker" 									:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ElevateCreateProcess"							:CompatibilityEmulation()\Description = "Elevate Create Process" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                 :CompatibilityEmulation()\Description = ""                              	:CompatibilityEmulation()\bMenuSubEnd = #True		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""             										:CompatibilityEmulation()\Description = "-----------------------------"   :CompatibilityEmulation()\bMenuBar = #True	  
		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                	:CompatibilityEmulation()\Description = "Standard Settings"								:CompatibilityEmulation()\bMenuSubBeg = #True	
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "256Color"													:CompatibilityEmulation()\Description = "Reduced 8-bit (256) Color" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "640x480"													:CompatibilityEmulation()\Description = "Run in 640 x 480 Screen" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableThemes"										:CompatibilityEmulation()\Description = "Disable Visual Themes" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableDWM"												:CompatibilityEmulation()\Description = "Disable Desktop Composition" 		:CompatibilityEmulation()\bCharSwitch = #True	
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HighDpiAware" 										:CompatibilityEmulation()\Description = "Disable High DPI Settings" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                 :CompatibilityEmulation()\Description = ""                              	:CompatibilityEmulation()\bMenuSubEnd = #True			
		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                	:CompatibilityEmulation()\Description = "Settings DirectX"								:CompatibilityEmulation()\bMenuSubBeg = #True		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitGDIRedraw"								:CompatibilityEmulation()\Description = "8 And 16Bit GDI Redraw" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitAggregateBlts"						:CompatibilityEmulation()\Description = "8 And 16Bit Aggregate Blts" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitDXMaxWinMode"       			:CompatibilityEmulation()\Description = "8 And 16Bit DX Max WinMode" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AccelGdipFlush"  									:CompatibilityEmulation()\Description = "Accel Gdi pFlush" 								:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DWM8And16BitMitigation"						:CompatibilityEmulation()\Description = "DWM 8 And 16Bit Mitigation" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DirectXTrimTextureFormats"   			:CompatibilityEmulation()\Description = "DirectX Trim Texture Formats" 		:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DirectXVersionLie"								:CompatibilityEmulation()\Description = "DirectX Version Lie" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Disable8And16BitD3D" 							:CompatibilityEmulation()\Description = "Disable 8 And 16Bit D3D" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableMaxWindowedMode" 					:CompatibilityEmulation()\Description = "Disable Max Windowed Mode " 			:CompatibilityEmulation()\bCharSwitch = #True			
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXMaximizedWindowedMode"					:CompatibilityEmulation()\Description = "DirectX Maximized WindowedMode"	:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXPrimaryEmulation"								:CompatibilityEmulation()\Description = "DirectX Primary Emulation"				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceSimpleWindow"								:CompatibilityEmulation()\Description = "Force Simple Window"							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGDIHWAcceleration"							:CompatibilityEmulation()\Description = "No GDI Hardware Acceleration"		:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGDIHWAcceleration"							:CompatibilityEmulation()\Description = "No GDI Hardware Acceleration"		:CompatibilityEmulation()\bCharSwitch = #True			
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""		
                                ;Sie können diese Korrektur weiter steuern, indem Sie den folgenden Befehl an der Eingabeaufforderung eingeben:
                                ;MAJORVERSION. MINORVERSION. LETTER
																;Beispiel: 9.0.c.
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXGICompat"												:CompatibilityEmulation()\Description = "DXGI Compat" 										:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "TextArt"													:CompatibilityEmulation()\Description = "Text Art" 												:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "TrimDisplayDeviceNames" 					:CompatibilityEmulation()\Description = "Trim DisplayDevice Names" 				:CompatibilityEmulation()\bCharSwitch = #True		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                 :CompatibilityEmulation()\Description = ""                              	:CompatibilityEmulation()\bMenuSubEnd = #True				
		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                	:CompatibilityEmulation()\Description = "Settings Optional"								:CompatibilityEmulation()\bMenuSubBeg = #True	
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CustomNCRender"  									:CompatibilityEmulation()\Description = "Custom NC Render" 								:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ChangeFolderPathToXPStyle"				:CompatibilityEmulation()\Description = "Change FolderPath To XP Style" 	:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ClearLastErrorStatusonIntializeCriticalSection":CompatibilityEmulation()\Description = "Clear Last Error Status on Intialize Critical Section" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectFilePaths"									:CompatibilityEmulation()\Description = "Correct File Paths" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableFadeAnimations"						:CompatibilityEmulation()\Description = "Disable FadeAnimations" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNXHideUI"									:CompatibilityEmulation()\Description = "Disable NX Hide UI" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNXShowUI"									:CompatibilityEmulation()\Description = "Disable NX Show UI" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableThemeMenus"								:CompatibilityEmulation()\Description = "Disable Theme Menus" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSorting"										:CompatibilityEmulation()\Description = "Emulate Sorting" 								:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingServer2008"					:CompatibilityEmulation()\Description = "Emulate Sorting Server 2008" 		:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetDiskFreeSpace" 					:CompatibilityEmulation()\Description = "Emulate GetDisk FreeSpace" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableNXShowUI" 									:CompatibilityEmulation()\Description = "Enable NX Show UI" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FaultTolerantHeap"								:CompatibilityEmulation()\Description = "Fault Tolerant Heap" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GlobalMemoryStatus2GB"        		:CompatibilityEmulation()\Description = "Global Memory Status 2GB" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GlobalMemoryStatusLie"						:CompatibilityEmulation()\Description = "Global Memory Status Lie" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetDriveTypeWHook"								:CompatibilityEmulation()\Description = "GetDrive TypeW Hook" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleBadPtr"         						:CompatibilityEmulation()\Description = "HandleBad Ptr" 									:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapClearAllocation"  						:CompatibilityEmulation()\Description = "Heap Clear Allocation" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreAltTab"											:CompatibilityEmulation()\Description = "Ignore AltTab" 									:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreDirectoryJunction"					:CompatibilityEmulation()\Description = "Ignore Directory Junction" 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreException"									:CompatibilityEmulation()\Description = "Ignore Exception" 								:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFloatingPointRoundingControl":CompatibilityEmulation()\Description = "Ignore Floating Point Rounding Control":CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFontQuality"								:CompatibilityEmulation()\Description = "Ignore Font Quality" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreSetROP2"               			:CompatibilityEmulation()\Description = "Ignore SetROP2" 									:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Layer_Force640x480x8"							:CompatibilityEmulation()\Description = "Layer Force 640x480x8" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Layer_ForceDirectDrawEmulation"		:CompatibilityEmulation()\Description = "Layer Force Direct Draw Emulation":CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Layer_Win95VersionLie"						:CompatibilityEmulation()\Description = "Layer Win95 Version Lie" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadLibraryRedirect"        			:CompatibilityEmulation()\Description = "Load Library Redirect" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PopCapGamesForceResPerf"         	:CompatibilityEmulation()\Description = "PopCap Games Force Res Perf" 		:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProcessPerfData"									:CompatibilityEmulation()\Description = "Process Perf Data" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SystemMetricsLie"									:CompatibilityEmulation()\Description = "System Metrics Lie" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VerifyVersionInfoLiteLayer"				:CompatibilityEmulation()\Description = "Verify Version Info Lite Layer" 	:CompatibilityEmulation()\bCharSwitch = #True		
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SingleProcAffinity"								:CompatibilityEmulation()\Description = "Single Proccess Affinity"	 			:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualRegistry"									:CompatibilityEmulation()\Description = "Virtual Registry" 								:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Wing32SystoSys32"        					:CompatibilityEmulation()\Description = "WinG32 Sys to Sys32" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPMitigationLayer"								:CompatibilityEmulation()\Description = "WRP Mitigation Layer" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                 :CompatibilityEmulation()\Description = ""                              	:CompatibilityEmulation()\bMenuSubEnd = #True				
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                	:CompatibilityEmulation()\Description = "Settings Windows Lie"						:CompatibilityEmulation()\bMenuSubBeg = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win95VersionLie"       						:CompatibilityEmulation()\Description = "Win95 Version Lie" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win98VersionLie"             			:CompatibilityEmulation()\Description = "Win98 Version Lie" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinNT4SP5VersionLie"       				:CompatibilityEmulation()\Description = "WinNT4 SP5 Version Lie" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000VersionLie"								:CompatibilityEmulation()\Description = "Win2000 Version Lie" 						:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP1VersionLie"       			:CompatibilityEmulation()\Description = "Win2000 SP1 Version Lie" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP2VersionLie"             :CompatibilityEmulation()\Description = "Win2000 SP2 Version Lie" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP3VersionLie"       			:CompatibilityEmulation()\Description = "Win2000 SP3 Version Lie" 				:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPVersionLie" 									:CompatibilityEmulation()\Description = "WinXP Version Lie" 							:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP2VersionLie"       				:CompatibilityEmulation()\Description = "WinXP SP2 Version Lie" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP3VersionLie"        				:CompatibilityEmulation()\Description = "WinXP SP3 Version Lie" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1VersionLie"       				:CompatibilityEmulation()\Description = "Vista SP1 Version Lie" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2VersionLie" 							:CompatibilityEmulation()\Description = "Vista SP2 Version Lie" 					:CompatibilityEmulation()\bCharSwitch = #True
		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = ""                                 :CompatibilityEmulation()\Description = ""                              	:CompatibilityEmulation()\bMenuSubEnd = #True						
		

 		ResetList(CompatibilityEmulation())
		Protected Max_Saves_List 	= ListSize(CompatibilityEmulation()) 
		Protected Index.i 					= SetMnuIndexNum_CmpEmulation()
		
		For i = 0 To Max_Saves_List
			NextElement(CompatibilityEmulation())
			CompatibilityEmulation()\EMUIDX    = i
			If Len( CompatibilityEmulation()\Modus ) >= 1				
				CompatibilityEmulation()\MenuIndex = Index ; Menu Item Index
				Index + 1				
			EndIf	
		Next
		
		Debug "Menü Erstellung: List Einträge " + Str(Max_Saves_List) +" / Menü Index Einträge von (" + Str(SetMnuIndexNum_CmpEmulation()) + " bis " + Str( Index ) + ") - Compatibility Emulation"
		;SortStructuredList(CompatibilityEmulation(), #PB_Sort_Ascending, OffsetOf(CmpEmulation\EMUIDX), #PB_Integer)
		
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win95"        :CompatibilitySystem()\Description = "Windows 95"															:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win98"        :CompatibilitySystem()\Description = "Windows 98"   													:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win2000"      :CompatibilitySystem()\Description = "Windows 2000"														:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win2000Sp2"   :CompatibilitySystem()\Description = "Windows 2000 /SP2"       								:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win2000Sp3"   :CompatibilitySystem()\Description = "Windows 2000 /SP3"      								:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXP"        :CompatibilitySystem()\Description = "Windows XP"															:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp1"     :CompatibilitySystem()\Description = "Windows XP /SP1"												:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp2"     :CompatibilitySystem()\Description = "Windows XP /SP2"												:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp2_GW"  :CompatibilitySystem()\Description = "Windows XP /SP2 (GW)"										:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinXPSp3"     :CompatibilitySystem()\Description = "Windows XP /SP3"												:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaRTM"     :CompatibilitySystem()\Description = "Windows Vista RTM"											:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaRTM_GW"  :CompatibilitySystem()\Description = "Windows Vista RTM (GW)"        					:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaSP1"     :CompatibilitySystem()\Description = "Windows Vista /SP1"											:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "VistaSP2"     :CompatibilitySystem()\Description = "Windows Vista /SP2"											:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "Win7RTM"      :CompatibilitySystem()\Description = "Windows 7 /RTM"													:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "NT4SP5"       :CompatibilitySystem()\Description = "WindowsNT4 /SP5" 												:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = ""             :CompatibilitySystem()\Description = "-----------------------------"   				:CompatibilitySystem()\bMenuBar = #True	        
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv03"     :CompatibilitySystem()\Description = "Server 2003"														:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv03Sp1"  :CompatibilitySystem()\Description = "Server 2003 /SP1"												:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv08R2RTM":CompatibilitySystem()\Description = "Server 2008R2 /RTM"											:CompatibilitySystem()\bCharSwitch = #True
		AddElement(CompatibilitySystem()): CompatibilitySystem()\OSModus$ = "WinSrv08SP1"  :CompatibilitySystem()\Description = "Server 2008 /SP1"          							:CompatibilitySystem()\bCharSwitch = #True
		
		ResetList(CompatibilitySystem())
		Max_Saves_List 	= ListSize(CompatibilitySystem())
		Index.i 				= SetMnuIndexNum_CmpWindows()
		
		For i = 0 To Max_Saves_List
			NextElement(CompatibilitySystem())			     
			CompatibilitySystem()\OSIDX = i
			If Len( CompatibilitySystem()\OSModus$ ) >= 1				
				CompatibilitySystem()\MenuIndex = Index ; Menu Item Index
				Index + 1				
			EndIf				
		Next
		Debug "Menü Erstellung: List Einträge " + Str(Max_Saves_List) +" / Menü Index Einträge von (" + Str(SetMnuIndexNum_CmpWindows()) + " bis " + Str( Index ) + ") - Compatibility Windows"
		
		SortStructuredList(CompatibilitySystem(), #PB_Sort_Ascending, OffsetOf(CmpOSModus\OSIDX), #PB_Integer)
		
	EndProcedure        
	
	Procedure.i SetMnuIndexNum_CmpEmulation()
		ProcedureReturn 400    	
	EndProcedure
	
	Procedure.i SetMnuIndexNum_CmpWindows()
		ProcedureReturn 1200    	
	EndProcedure
	
	Procedure.i GetMaxMnuIndex_Emulation()
		
		ResetList(CompatibilityEmulation())
		Protected Max_Saves_List = ListSize(CompatibilityEmulation()) 
		Protected Index.i = SetMnuIndexNum_CmpEmulation()
		
		For i = 0 To Max_Saves_List-1
			NextElement(CompatibilityEmulation())
			;If Len( CompatibilityEmulation()\Modus ) >= 1
				Index + 1				
			;EndIf	
		Next    	
		ProcedureReturn Index
		
	EndProcedure
	
	Procedure.i GetMaxMnuIndex_WindowsSystem()
		
		ResetList(CompatibilitySystem())
		Protected Max_Saves_List = ListSize(CompatibilitySystem()) 
		Protected Index.i = SetMnuIndexNum_CmpWindows()
		
		For i = 0 To Max_Saves_List-1        		
			NextElement(CompatibilitySystem())
			Index + 1 
		Next				
		ProcedureReturn Index
		
	EndProcedure		
		
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "APITracing"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AppRecorder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectCreateBrushIndirectHatch"     
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableCicero"        
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DW"      
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableIISBizTalk"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FDR"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDxSetupSuccess"      
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreAdobeKMPrintDriverMessageBox"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MsiAuto"        
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NullEnvironment"        
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "pLayerGetProcAddrExOverride" 
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProfilesSetup"        
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectCHHlocaletoCHT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SecuROM7"
	
	
		;Compatibility available IN Windows 10
		;
		; 32-bit Compatibility Modes (90)
		;
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "16BitColor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "256Color"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "640X480"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitAggregateBlts"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitDXMaxWinMode"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitGDIRedraw"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitTimedPriSync"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ApplicationMonitor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AppRecorder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Arm64Wow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsVista"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsWin7"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsWin8"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsXP"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Disable8And16BitD3D"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Disable8And16BitModes"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableCicero"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableFadeAnimations"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNXHideUI"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNXShowUI"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableThemeMenus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableThemes"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableUserCallbackException"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DW"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DWM8And16BitMitigation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXMaximizedWindowedMode"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ElevateCreateProcess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSorting"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingServer2008"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingVista"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingWindows61"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableNXShowUI"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FaultTolerantHeap"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FDR"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FixDisplayChangeRefreshRate"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FontMigration"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDxSetupSuccess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleRegExpandSzRegistryKeys"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HighDpiAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreAdobeKMPrintDriverMessageBox"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFreeLibrary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Installer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "International"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "iTunesAutoplay"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Layer_Force640x480x8"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Layer_ForceDirectDrawEmulation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Layer_Win95VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadLibraryRedirect"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MsiAuto"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoDTToDITMouseBatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NT4SP5"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NullEnvironment"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProfilesSetup"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectCHHlocaletoCHT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsAdmin"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest_GW"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsInvoker"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VerifyVersionInfoLiteLayer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeDeleteFileLayer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaRTM"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaRTM_GW"				--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSetup"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000Sp2"				--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000Sp3"				--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win7RTM"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win7RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win81RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win8RTM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win8RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win95"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win98"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Windows8RC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinSrv03"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinSrv03Sp1"				--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinSrv08R2RTM"			--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinSrv08SP1"				--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXP"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSp1"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSp2"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSp2_GW"				--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSp3"					--- Siehe Weiter Unten
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP3VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPMitigation"
		;
		
		
		;64-bit Compatibility Modes (36)
		;
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ApplicationMonitor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsVista"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsWin7"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorsWin8"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableUserCallbackException"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DW"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingServer2008"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingVista"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingWindows61"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FaultTolerantHeap"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FontMigration"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HighDpiAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFreeLibrary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Installer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadLibraryRedirect"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MsiAuto"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoDTToDITMouseBatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsAdmin"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsInvoker"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VerifyVersionInfoLiteLayer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeDeleteFileLayer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaRTM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win7RTM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win7RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win81RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win8RTM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win8RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Windows8RC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinSrv08R2RTM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinSrv08SP1"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPMitigation"
		;
		;32-bit Compatibility Fixes (411)
		;
		;Compatibility Fixes
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitTimedPriSync"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AccelGdipFlush"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AdditiveRunAsHighest"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AddProcessParametersFlags"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AddRestrictedSidInCoInitializeSecurity"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AddWritePermissionsToDeviceFiles"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AliasDXDC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AllocDebugInfoForCritSections"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AllowDesktopSetProp"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AllowMaximizedWindowGamma"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AlwaysActiveMenus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "APILogger"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AspNetRegiis11"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "BIOSRead"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "BlockRunAsInteractiveUser"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ChangeAuthenticationLevel"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ChangeFolderPathToXPStyle"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ClearLastErrorStatusonIntializeCriticalSection"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CopyHKCUSettingsFromOtherUsers"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectACMArgs"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectACMStreamOpen"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectActiveMoviePath"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectBitmapHeader"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectCreateBrushIndirectHatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectCreateEventName"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectCreateIcon"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectCreateSurface"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectDayName"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectFarEastFont"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectFilePathInSetDlgItemText"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectFilePaths"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectFilePathsUninstall"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectInactiveBorder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectOpenFileExclusive"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectShellExecuteHWND"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectShortDateFormat"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectSoundDeviceId"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectVerInstallFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CreateDummyProcess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CreateWindowConstrainSize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CUASAppFix"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CustomNCRender"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DecorateConnectionString"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DelayAppDllMain"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DelayApplyFlag"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DelayDllInit"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DelayShowGroup"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DelayWin95VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DelayWinMMCallback"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeleteAndCopy"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeleteFileToStopDriverAndDelete"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeleteSpecifiedFiles"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeprecatedServiceShim"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeRandomizeExeName"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DetectorDWM8And16Bit"        
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DirectPlayEnumOrder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DirectXTrimTextureFormats"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DirectXVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableAdvancedRPCrangeCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableAdvanceRPCClientHardening"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableAnimation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableBoostThread"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableExceptionChainValidation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableFadeAnimations"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableFilterKeys"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableFocusTracking"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableKeyboardAutoInvocation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableKeyboardCues"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableMaybeNULLSizeisConsistencycheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNDRIIDConsistencyCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNewWMPAINTDispatchInOLE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNX"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNXPageProtection"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableScreenSaver"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableStickyKeys"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableSWCursorOnMoveSize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableThemeMenus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableThemes"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableW2KOwnerDrawButtonStates"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableWindowArrangement"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableWindowsDefender"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisallowCOMBindingNotifications"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DPIUnaware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DuplicateHandleFix"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXGICompat"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXMaximizedWindowedMode"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXPrimaryClipping"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXPrimaryEmulation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EarlyMouseDelegation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ElevateCreateProcess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmptyClipboardtoSet"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateBitmapStride"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateCDFS"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateClipboardDIBFormat"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateCreateFileMapping"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateCreateProcess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateCursor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateDeleteObject"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateDirectDrawSync"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateDrawText"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateEnvironmentBlock"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateFindHandles"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetCommandLine"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetDeviceCaps"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetDiskFreeSpace"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetProfileString"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetStdHandle"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetStringType"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateGetUIEffects"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateHeap"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateIME"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateJoystick"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateLZHandles"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateMissingEXE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateOldPathIsUNC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulatePlaySound"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulatePrinter"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSHGetFileInfo"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSlowCPU"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSorting"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingServer2008"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingVista"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingWindows61"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateTextColor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateToolHelp32"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateUSER"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateVerQueryValue"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateWriteFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableAppConfig"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableDEP"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyExceptionHandlinginOLE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyExceptionHandlingInRPC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyLoadTypeLibForRelativePaths"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyNTFSFlagsForDocfileOpens"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableRestarts"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnlargeGetObjectBufferSize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnterUninitializedCriticalSection"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ExtraAddRefDesktopFolder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ExtractAssociatedIcon"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FailCloseProfileUserMapping"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FailGetStdHandle"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FailObsoleteShellAPIs"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FailOpenFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FailRemoveDirectory"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FakeLunaTheme"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FakeThemeMetrics"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FaultTolerantHeap"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FeedbackReport"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FileVersionInfoLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FilterNetworkResources"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FixDisplayChangeRefreshRate"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FixSectionProtection"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FixServiceStartupCircularDependency"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FixSubclassCallingConvention"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FlushFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FontMigration"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Force640x480"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Force640x480x16"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Force640x480x8"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Force8BitColor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceAdminAccess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceAnsiGetDisplayNameOf"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceAnsiWindowProc"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceAppendMenuSuccess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceApplicationFocus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceAVIWindow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceCDStop"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceCoInitialize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDefaultSystemPaletteEntries"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDirectDrawEmulation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDirectDrawWait"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDisplayMode"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceDXSetupSuccess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceInvalidateOnClose"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceInvalidateOnClose2"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceKeepFocus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceKeyWOW6464Key"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceMessageBoxFocus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceSeparateVDM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceShellLinkResolveNoUI"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceSimpleWindow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceTemporaryModeChange"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceWorkingDirectoryToEXEPath"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FUSBadApplicationType1"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FUSBadApplicationType2"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FUSBadApplicationType3"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FUSBadApplicationType4"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GenericInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetDiskFreeSpace2GB"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetDriveTypeWHook"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetShortPathNameNT4"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetTopWindowToShellWnd"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetVolumeInformationLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GiveupForeground"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GlobalMemoryStatus2GB"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GlobalMemoryStatusLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GrabMatchingInformation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleAPIExceptions"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleBadPtr"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleDBCSUserName"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleDBCSUserName2"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleEmptyAccessCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleIELaunch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleMarkedContentNotIndexed"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleRegExpandSzRegistryKeys"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleWvsprintfExceptions"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HardwareAudioMixer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapClearAllocation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapDelayLocalFree"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapForceGrowable"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapIgnoreMoveable"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapLookasideFree"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapPadAllocation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HeapValidateFrees"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HideCursor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HideDisplayModes"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HideTaskBar"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HighDpiAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IEUnHarden"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreAltTab"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreChromeSandbox"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreCoCreateInstance"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreCRTExit"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreDebugOutput"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreDirectoryJunction"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreException"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFloatingPointRoundingControl"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFontQuality"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFreeConsole"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFreeLibrary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreHungAppPaint"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreLoadLibrary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreMCISTOP"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreMessageBox"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreMSOXMLMF"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreNoModeChange"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreOemToChar"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreOleUninitialize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreScheduler"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreSetROP2"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreSysColChanges"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreTAPIDisconnect"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreVBOverflow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreWM_CHARRepeatCount"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreZeroMoveWindow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InjectDll"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InstallComponent"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InstallFonts"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InstallShieldInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InternetSetFeatureEnabled"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "KeepWindowOnMonitor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LanguageNeutralGetFileVersionInfo"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LazyReleaseDC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LimitFindFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadComctl32Version5"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadLibraryCWD"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadLibraryRedirectFlag"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LocalMappedObject"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LowerThreadPriority"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LUA_RegOpenKey_OnlyAsk_KeyRead"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MakeShortcutRunAs"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ManageLinks"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MapMemoryB0000"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MirrorDriverDrawCursor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MirrorDriverWithComposition"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MoveIniToRegistry"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MoveToCopyFileShim"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MoveWinInitRenameToReg"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoDTToDITMouseBatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGdiBatching"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGDIHWAcceleration"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGhost"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoHardeningLoadResource"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NonElevatedIDriver"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoPaddedBorder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoShadow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoSignatureCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoTimerCoalescing"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoVirtualization"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoVirtWndRects"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NullEnvironment"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NullHwndInMessageBox"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Ole32ValidatePointers"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "OpenDirectoryAcl"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "OpenGLEmfAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "OverrideShellAppCompatFlags"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PaletteRestore"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PopulateDefaultHKCUSettings"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PreInitApplication"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PreInstallDriver"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PreventMouseInPointer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PrinterIsolationAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProcessPerfData"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProfilesEnvStrings"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProfilesGetFolderPath"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProfilesRegQueryValueEx"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PromoteDAM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PromotePointer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PropagateProcessHistory"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ProtectedAdminCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RecopyExeFromCD"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectBDE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectCHHlocaletoCHT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectCRTTempFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectDBCSTempPath"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectDefaultAudioToCommunications"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectEXE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectHKCUKeys"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectMP3Codec"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectShortCut"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectWindowsDirToSystem32"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RegistryReflector"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RelaunchElevated"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveBroadcastPostMessage"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveDDEFlagFromShellExecuteEx"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveInvalidW2KWindowStyles"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveIpFromMsInfoCommandLine"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveNoBufferingFlagFromCreateFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveOverlappedFlagFromCreateFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RemoveReadOnlyAttribute"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ReorderWaveForCommunications"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RepairStringVersionResources"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RestoreSystemCursors"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RetryOpenSCManagerWithReadAccess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RetryOpenServiceWithReadAccess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsAdmin"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsInvoker"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ScreenCaptureBinary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SearchPathInAppPaths"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SessionShim"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SetEnvironmentVariable"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SetProtocolHandler"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SetupCommitFileQueueIgnoreWow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ShellExecuteNoZone"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ShellExecuteXP"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ShimViaEAT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ShowWindowIE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Shrinker"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SingleProcAffinity"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SkipDLLRegister"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SpecificInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SpecificNonInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "StackSwap"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "StrictLLHook"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SyncSystemAndSystem32"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SystemMetricsLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "TerminateExe"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "TrimDisplayDeviceNames"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "TrimVersionInfo"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UIPIEnableCustomMsgs"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UIPIEnableStandardMsgs"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UnMirrorImageList"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseHighResolutionMouseWheel"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseIntegratedGraphics"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseLegacyMouseWheelRouting"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseLowResolutionMouseWheel"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UserDisableForwarderPatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseSlowMouseWheelScrolling"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseWARPRendering"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeDeleteFile"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeDesktopPainting"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeHKCRLite"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeRegisterTypeLib"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualRegistry"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaRTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WaitAfterCreateProcess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WaveOutIgnoreBadFormat"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WaveOutUsePreferredDevice"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WerDisableReportException"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP3VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2k3RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2k3SP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win7RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win81RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win8RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win95VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win98VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinExecRaceConditionFix"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinG32SysToSys32"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinNT4SP5VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPSP3VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXPVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF_NOWAITFORINPUTIDLE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF_USER_DDENOSYNC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_DELAYTIMEGETTIME"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_FIXLUNATRAYRECT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_HACKPROFILECALL"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_HACKWINFLAGS"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_SETFOREGROUND"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_SYNCSYSFILE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_USEMINIMALENVIRONMENT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_DISPMODE256"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_DIVIDEOVERFLOWPATCH"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_EATDEVMODEMSG"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_FORCEINCDPMI"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_PLATFORMVERSIONLIE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_USEWINHELP32"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_WIN31VERSIONLIE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_ZEROINITMEMORY"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPDllRegister"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPMitigation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPRegDeleteKey"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "XPAfxIsValidAddress"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "XPFileDialog"
		;
		;64-bit Compatibility Fixes (134)
		;
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "8And16BitTimedPriSync"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AccelGdipFlush"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AdditiveRunAsHighest"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AddProcessParametersFlags"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AddRestrictedSidInCoInitializeSecurity"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AllocDebugInfoForCritSections"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AllowMaximizedWindowGamma"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "AlwaysActiveMenus"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CopyHKCUSettingsFromOtherUsers"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectFilePaths"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CorrectShellExecuteHWND"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CreateDummyProcess"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "CreateWindowConstrainSize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeleteFileToStopDriverAndDelete"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DeprecatedServiceShim"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableAdvancedRPCrangeCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableAdvanceRPCClientHardening"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableAnimation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableExceptionChainValidation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableFocusTracking"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableKeyboardAutoInvocation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableKeyboardCues"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableMaybeNULLSizeisConsistencycheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNDRIIDConsistencyCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableNewWMPAINTDispatchInOLE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableSWCursorOnMoveSize"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableWindowArrangement"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisableWindowsDefender"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DisallowCOMBindingNotifications"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DPIUnaware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "DXGICompat"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EarlyMouseDelegation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateCursor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingServer2008"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingVista"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EmulateSortingWindows61"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableAppConfig"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableDEP"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyExceptionHandlinginOLE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyExceptionHandlingInRPC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyLoadTypeLibForRelativePaths"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "EnableLegacyNTFSFlagsForDocfileOpens"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FaultTolerantHeap"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FileVersionInfoLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "FontMigration"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ForceKeyWOW6464Key"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GenericInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetDiskFreeSpace2GB"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetShortPathNameNT4"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GetTopWindowToShellWnd"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "GiveupForeground"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HandleIELaunch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HardwareAudioMixer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "HighDpiAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFreeConsole"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "IgnoreFreeLibrary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InstallComponent"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "InstallFonts"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "LoadLibraryRedirectFlag"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MakeShortcutRunAs"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "MirrorDriverDrawCursor"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoDTToDITMouseBatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGdiBatching"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGDIHWAcceleration"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoGhost"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoPaddedBorder"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoShadow"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoSignatureCheck"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoTimerCoalescing"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoVirtualization"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "NoVirtWndRects"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Ole32ValidatePointers"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "OpenGLEmfAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "OverrideShellAppCompatFlags"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PreventMouseInPointer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PrinterIsolationAware"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PromoteDAM"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "PromotePointer"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectDefaultAudioToCommunications"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectHKCUKeys"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RedirectShortCut"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RegistryReflector"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RelaunchElevated"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ReorderWaveForCommunications"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsAdmin"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsHighest"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "RunAsInvoker"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "ScreenCaptureBinary"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SetEnvironmentVariable"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SetProtocolHandler"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SpecificInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SpecificNonInstaller"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "StrictLLHook"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "SystemMetricsLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "TerminateExe"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseHighResolutionMouseWheel"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseIntegratedGraphics"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseLegacyMouseWheelRouting"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseLowResolutionMouseWheel"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UserDisableForwarderPatch"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseSlowMouseWheelScrolling"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "UseWARPRendering"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualizeHKCRLite"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VirtualRegistry"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaRTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "VistaSP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP2VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000SP3VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2000VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win2k3SP1VersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win7RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win81RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "Win8RTMVersionLie"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF_NOWAITFORINPUTIDLE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF_USER_DDENOSYNC"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_DELAYTIMEGETTIME"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_FIXLUNATRAYRECT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_HACKPROFILECALL"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_HACKWINFLAGS"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_SETFOREGROUND"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_SYNCSYSFILE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCF2_USEMINIMALENVIRONMENT"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_DISPMODE256"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_DIVIDEOVERFLOWPATCH"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_EATDEVMODEMSG"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_FORCEINCDPMI"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_PLATFORMVERSIONLIE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_USEWINHELP32"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_WIN31VERSIONLIE"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WOWCFEX_ZEROINITMEMORY"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPMitigation"
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WRPRegDeleteKey"        
; 		AddElement(CompatibilityEmulation()): CompatibilityEmulation()\Modus = "WinXXMode"   
		

	

	
	
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
; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 122
; FirstLine = 84
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; Executable = ..\Release\vSystems64Bit.exe
; EnableUnicode