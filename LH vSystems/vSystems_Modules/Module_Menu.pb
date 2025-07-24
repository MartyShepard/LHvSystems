; DAS Deklaieren findet IN der Config Source Statt
;
;
; TODO
; Code aufräumen und Optimieren

Module INVMNU
	
    Macro  Set_AppMenu_AddMenu(MenuListing)    	
    	For unItem = 0 To MxItem    		
    		NextElement(MenuListing)
    		
    		If MenuListing\bMenuSubBeg = #True                 
    			OpenSubMenu(MenuListing\Description)                
    			Continue
    		ElseIf MenuListing\bMenuSubEnd = #True
    			CloseSubMenu()
    			Continue
    		ElseIf MenuListing\bMenuBar = #True                 
    			MenuBar()
    			Continue                
    		EndIf 
    		If ( MenuListing\MenuImageID > 0 )    			
    			MenuItem(MenuListing\MenuIndex, MenuListing\Description, ImageID(MenuListing\MenuImageID))		
    		Else
    			MenuItem(MenuListing\MenuIndex, MenuListing\Description)	    			
    		EndIf
    	Next    	
    EndMacro
    ;
    ;
    Procedure.i Request_MSG_Quit()
        
        ;
        ; Überprüfr auf nicht gepeicherte Text Änderungen
        If ( vInfo::Modify_EndCheck() = #True )
            
            
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Beenden", Startup::*LHGameDB\TitleVersion + " Beenden ?",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            If Result = 0
                ProcedureReturn #True
            EndIf 
            SetActiveGadget(DC::#ListIcon_001): ProcedureReturn #False
        EndIf
        
        ProcedureReturn #True
    EndProcedure 
    ;
    ;
    Procedure.i MNU_SetGet(state.i)
        If ( state.i = #True )
            ProcedureReturn #False
        EndIf
        If ( state.i = #False )
            ProcedureReturn #True
        EndIf    
    EndProcedure
    ;
    ;
    Procedure.i MNU_SetCheckmark(MenuID.i, Itemm.i, State.i)                
            SetMenuItemState(MenuID, Itemm, State)        
    EndProcedure        
    ;
		;
    Procedure Get_MenuItems_VirtualDriveSupport(MenuID.i)
    	Protected Result.i
    	Select MenuID    
    		Case 2700:	VirtualDriveSupport::MenuActivate()
    		Case 2701:	VirtualDriveSupport::MenuDeActivate(#False)
    		Case 2702:	VirtualDriveSupport::MenuDeActivate(#True)
    			
    		Case 2710 To 2750
    			VirtualDriveSupport::MenuGetVirtualDrive(GetMenuItemText(CLSMNU::*MNU\HandleID[0],MenuID ))
    	EndSelect	    	
    EndProcedure
    ;
		;         
    Procedure Get_MenuItems_RegsSupport(MenuID.i)
    	Protected Result.i
    	Select MenuID    
    		Case 2600:
    		;	RegsTool::Keys_RegistryFile_Check()  
    	EndSelect		
    EndProcedure	
    ;
		;         
    Procedure Get_MenuItems_SaveSupport(MenuID.i)
    	Protected Result.i
    	
    	Select MenuID      	
    		Case 1600:	SaveTool::SaveConfig_Help()            			
    		Case 1601:	SaveTool::SaveConfig_Create(1)         			            			
    		Case 1602:	SaveTool::SaveConfig_AddGame()            			
    		Case 1603:	SaveTool::SaveConfig_Edit()            			
    		Case 1604
    			SaveTool::SaveContent_Read()		; Config Liste Initialiseren
    			SaveTool::SaveContent_Backup(0,1)            			
    		Case 1609
    			SaveTool::SaveContent_Read()		; Config Liste Initialiseren
    			SaveTool::SaveContent_Backup(3,1)            			            			
    		Case 1605
    			SaveTool::SaveContent_Read()		; Config Liste Initialiseren
    			SaveTool::SaveContent_Restore(0,1)            			            			
    		Case 1606: 	;SaveTool::SaveConfig_AddCMD()            			
    			vSystemHelp::vSysCMD_SavegameSupport()
    		Case 1607: 	SaveTool::SaveConfig_OpenSaves()            			
    		Case 1608:	SaveTool::SaveConfig_Edit(1)            			
    		Case 1610: ;Löschen 
    			SaveTool::SaveContent_Delete()
    		Case 1611	;Komprimieren
    			SaveTool::SaveContent_Compress()              			
    		Case 1612; Zeige
    			SaveTool::SaveContent_Read()
    			SaveTool::SaveConfig_ShowDirectories()            			
    		Case 1618:	SaveTool::SaveConfig_GetGameTitle_ClipBaord()             			
    		Case 1620:
    			;
					; SaveConfig_SetKeyValue(KeyValue.s = "Folder", FolderValue.i = 1, KeyBool.i = #False, KeyDelay,i = 250)
    			SaveTool::SaveConfig_SetKeyValue("Folder",1)            				
    		Case 1621:	SaveTool::SaveConfig_SetKeyValue("Folder",2)            				
    		Case 1622:	SaveTool::SaveConfig_SetKeyValue("Folder",3)            				
    		Case 1623:	SaveTool::SaveConfig_SetKeyValue("Folder",4)            				
    		Case 1624:	SaveTool::SaveConfig_SetKeyValue("Folder",5)            				
    		Case 1614:	SaveTool::SaveConfig_SetKeyValue("RestoreData",-1,#True,-1)            				
    		Case 1613:	SaveTool::SaveConfig_SetKeyValue("Backup-Data",-1,#True, -1)            				
    		Case 1617:	SaveTool::SaveConfig_SetKeyValue("BackupCompress",-1,#True,-1)            			            				
    		Case 1615:	SaveTool::SaveConfig_SetKeyValue("RestoreDelay",-1,-1,250)             				
    		Case 1616:	SaveTool::SaveConfig_SetKeyValue("Backup-Delay",-1,-1,250)      	
    	EndSelect
    	
    EndProcedure
		;
  	; App Menu. Ort: Programm, Media Device Einstellungs Fenster
    Procedure Get_AppMenu(MenuID.i, GadgetID.i)
        
        Protected Commandline$, Programm$
        
        Debug "Menü Index: " + Str(MenuID) + " Selectiert"
                     
        Protected IndexA_Beg = PortsHelp::SetMnuIndexNum()
        Protected IndexA_End = PortsHelp::GetMaxMnuIndex()
        
        Protected IndexB_Beg = Compatibility::SetMnuIndexNum_CmpWindows()
        Protected IndexB_End = Compatibility::GetMaxMnuIndex_WindowsSystem()
        
        Protected IndexC_Beg = Compatibility::SetMnuIndexNum_CmpEmulation()  
        Protected IndexC_End = Compatibility::GetMaxMnuIndex_Emulation()  
        
        Protected IndexD_Beg = UnrealHelp::SetMnuIndexNum()
        Protected IndexD_End = UnrealHelp::GetMaxMnuIndex()
        
        Protected IndexE_Beg = UnityHelp::SetMnuIndexNum()
        Protected IndexE_End = UnityHelp::GetMaxMnuIndex()       
        
        Select MenuID
        	Case IndexA_Beg To IndexA_End
        		vSystem::System_MenuItemB_Emulation(MenuID) 
        		
        	Case IndexB_Beg To IndexB_End                             
        		vSystem::System_MenuItemW_Compat(MenuID)            
        		
        	Case IndexC_Beg To IndexC_End                    
        		vSystem::System_MenuItemE_Compat(MenuID)                  
        		
        	Case IndexD_Beg To IndexD_End              
        		vSystem::System_MenuItemC_Unreal(MenuID)          				
        		
        	Case IndexE_Beg To IndexE_End                   
        		vSystem::System_MenuItemD_Unity(MenuID)
        		
        	Case 1600 To 1699
        		Get_MenuItems_SaveSupport(MenuID.i)
        		
        	Case 2600 To 2699
        		Get_MenuItems_RegsSupport(MenuID.i) 
        		      		        		
        	Case 1700 To 1799
        		Select MenuID              	
        				
        			Case 1700:	vSystemHelp::vSysCMD_MiniMize():
        			Case 1701:	vSystemHelp::vSysCMD_Asynchron()
        			Case 1702:	vSystemHelp::vSysCMD_WinApi()
        			Case 1703:	vSystemHelp::vSysCMD_Borderless()
        			Case 1704:	vSystemHelp::vSysCMD_BorderlessC()
        			Case 1705:	vSystemHelp::vSysCMD_BorderlessB()
        			Case 1706:	vSystemHelp::vSysCMD_BorderlessCB()
        			Case 1707:	vSystemHelp::vSysCMD_MetricsCalc()
        			Case 1708:	vSystemHelp::vSysCMD_KeyModShift()
        			Case 1709:	vSystemHelp::vSysCMD_DisableScreenShot()
        			Case 1710:	vSystemHelp::vSysCMD_LockMouse()
        			Case 1711:	vSystemHelp::vSysCMD_FreeMemory()
        			Case 1712:	vSystemHelp::vSysCMD_DisableTaskbar()
        			Case 1713:	vSystemHelp::vSysCMD_DisableExplorer()
        			Case 1714:	vSystemHelp::vSysCMD_DisableAero()
        			Case 1715:	vSystemHelp::vSysCMD_CpuAffinity1()
        			Case 1716:	vSystemHelp::vSysCMD_CpuAffinity2()
        			Case 1717:	vSystemHelp::vSysCMD_CpuAffinity3()
        			Case 1718:	vSystemHelp::vSysCMD_CpuAffinity4()
        			Case 1719:	vSystemHelp::vSysCMD_CpuAffinityF()
        			Case 1720:	vSystemHelp::vSysCMD_Monitoring()
        			Case 1721:	vSystemHelp::vSysCMD_FirewallBlock()
        			Case 1722:	vSystemHelp::vSysCMD_MediaDevice1()
        			Case 1723:	vSystemHelp::vSysCMD_HelpSupport_Main()
        			Case 1724:	vSystemHelp::vSysCMD_HelpSupport_Borderless()	
        			Case 1725:	vSystemHelp::vSysCMD_QuickCommand()
        			Case 1726:	vSystemHelp::vSysCMD_MediaDeviceCommand()
        			Case 1727:	vSystemHelp::vSysCMD_NoOutPut()
        			Case 1728:	vSystemHelp::vSysCMD_LogRedirect()
        			Case 1729:	vSystemHelp::vSysCMD_KeyModDisableTask()	         			
        			Case 1730:	vSystemHelp::vSysCMD_NoDoubleQuotes()          			
        			Case 1731:	vSystemHelp::vSysCMD_MameCMDHelp() 
        			Case 1732:	vSystemHelp::vSysCMD_PackSupport()
        			Case 1733:	vSystemHelp::vSysCMD_SavegameSupport()
        			Case 1734:	vSystemHelp::vSysCMD_VirtualDriveSupport()
        			Case 1735:	vSystemHelp::vSysCMD_QuickCommandAdmin()
        		EndSelect
        	Default          
        		Debug "Kein Menüeintrag beim Index " + Str(MenuID)
        EndSelect
        ProcedureReturn 
    EndProcedure
    ;
    ;    
    Procedure Set_AppMenu_VirtualDriveSupport(MenuID.i)
    	
    		Protected Index.i, MenuIndex.i, MountDrive.s, MountDirectory.s
	    	If IsWindow( DC::#_Window_001 )		    	
	    		OpenSubMenu("VirtualDrive Support")
	    		MenuItem(2700, "Laufwerk: Aktiveren") 
	    		MenuItem(2701, "Laufwerk: Entfernen")
	    		MenuItem(2702, "Laufwerk: Entfernen (Force)")
	    		
	    		;
	    		; Hole angemldete Laufwerke
	    		Index = VirtualDriveSupport::ListGetVirtualDrives()
	    		If ( Index >= 0 )
	    			MenuBar()
	    			MenuIndex.i = 2710
	    			For DriveIndex.i = 0 To Index
	    				MountDrive 			= VirtualDriveSupport::ListGetVirtualDrive(DriveIndex)
	    				MountDirectory 	= VirtualDriveSupport::ListGetVirtualDirectory(DriveIndex)		    					    				
	    				MenuItem(MenuIndex, "Mount " +Chr(34)+ MountDrive +Chr(34)+ " = " + MountDirectory) 	    				
	    			Next
	    		EndIf	
	    		
	    		CloseSubMenu()     
	    	EndIf   	
    	
    	EndProcedure
    	
    Procedure Set_AppMenu_RegsSupport(MenuID.i)
    	
	    	If IsWindow( DC::#_Window_003 )		    	
	    		OpenSubMenu("vSystem: Registry Support", ImageID( DI::#_MNU_SAVESUPPORT))
	    		CloseSubMenu()   
	    	Else
	    		;
	    		; Try Icon
	    		OpenSubMenu("Registry Support", ImageID( DI::#_MNU_SAVESUPPORT))	    		
	    		CloseSubMenu()   
	    	EndIf
	    	
    		MenuItem(2600, "Test")	    	
    	
    EndProcedure
    	
    Procedure Set_AppMenu_SaveSupport(MenuID.i)
    	
    	Protected Index.i
	    	If IsWindow( DC::#_Window_003 )		    	
	    		OpenSubMenu("vSystem: Save Support", ImageID( DI::#_MNU_SAVESUPPORT))
	    	Else
	    		;
	    		; Try Icon
	    		OpenSubMenu("Save Support", ImageID( DI::#_MNU_SAVESUPPORT))	    		
	    	EndIf
	    	
    		MenuItem(1618, "Titel: " + SaveTool::SaveConfig_GetGameTitle())  
    		MenuItem(1619, SaveTool::SaveConfig_MenuFileExists())
    		MenuBar() 
    		MenuItem(1600, "Hilfe")
	    	MenuBar() 
	    	MenuItem(1615, "Info: Verzögerung: Start = " 		+ Str(SaveTool::GetSaveOption(2)) + " Millisekunden")
	    	MenuItem(1616, "Info: Verzögerung: Ende = " 		+ Str(SaveTool::GetSaveOption(3)) + " Millisekunden")
	    	MenuItem(1614, "Info: Save Wiederherstellen")	
	    	MenuItem(1613, "Info: Save Daten Sichern")	    	
	    	MenuItem(1617, "Info: Save Daten Komprimieren")
	    	MenuItem(1612, "Info: Konfigurierte Verzeichnisse")	    	
    		MenuBar() 
    		MenuItem(1601, "Config: Erstellen",					ImageID( DI::#_MNU_SAVECREATE))
	    	If IsWindow( DC::#_Window_003 )	    		
	    		MenuItem(1602, "Config: Spiel Hinzufügen")
	    	EndIf
	    	MenuBar()
	    	If IsWindow( DC::#_Window_003 )		    	
	    		MenuItem(1603, "Config: Editieren",				ImageID( DI::#_MNU_SAVEEDIT))
	    	EndIf
	    	MenuItem(1608, "Config: Editieren (Öffne Mit..)")
	    	MenuItem(1620, "Config: Verzeichnis Nr.1 wählen")
	    	MenuItem(1621, "Config: Verzeichnis Nr.2 wählen")	    	
	    	MenuItem(1622, "Config: Verzeichnis Nr.3 wählen")
	    	MenuItem(1623, "Config: Verzeichnis Nr.4 wählen")
	    	MenuItem(1624, "Config: Verzeichnis Nr.5 wählen")    	
	    	MenuBar() 	    	   	
	    	MenuItem(1607, "Config: vSystem Verzeichnis Öffnen") 	    	
	    	If IsWindow( DC::#_Window_003 )		 	    	
	    			MenuBar() 
	    			MenuItem(1604, "Save Backup: Kopieren",					ImageID( DI::#_MNU_SAVEBCKCOPY))
	    			MenuItem(1609, "Save Backup: Verschieben",			ImageID( DI::#_MNU_SAVEBCKMOVE))        		
	    			MenuItem(1605, "Save Backup: Wiederherstellen",	ImageID( DI::#_MNU_SAVERSTCOPY))
	    			MenuItem(1610, "Save Backup: Löschen",					ImageID( DI::#_MNU_SAVEBCKDEL))
	    	Else
	    			MenuBar() 
	    	EndIf
	    	MenuItem(1611, "Save Backup Komprimieren",					ImageID( DI::#_MNU_SAVECOMPRESS))    		
	    	If IsWindow( DC::#_Window_003 )		    	
	    		MenuBar() 	    		
	    		MenuItem(1606, "Commandline Hinzufügen")    		
	    	EndIf
    		CloseSubMenu()     		   		      	
    		If Not IsWindow( DC::#_Window_003 )    			
    			;
					; Tray Icon
    			MenuItem(1602, "Save Config: Erstellen",				ImageID( DI::#_MNU_SAVECREATE))
    			MenuItem(1603, "Save Config: Editieren",				ImageID( DI::#_MNU_SAVEEDIT))
    			MenuItem(1604, "Save Backup: Kopieren",					ImageID( DI::#_MNU_SAVEBCKCOPY))
    			MenuItem(1609, "Save Backup: Verschieben",			ImageID( DI::#_MNU_SAVEBCKMOVE))
    			MenuItem(1605, "Save Backup: Wiederherstellen",	ImageID( DI::#_MNU_SAVERSTCOPY))
    			MenuItem(1610, "Save Backup: Löschen"					,	ImageID( DI::#_MNU_SAVEBCKDEL))
    		EndIf	
    			
    	If CountGadgetItems(DC::#ListIcon_001) = 0
    		SetMenuItemText(MenuID, 1618, "Keine Spiel Einträge")
    		SetMenuItemText(MenuID, 1619, "Status: --")
    		
    		For Index = 1600 To 1624
    			DisableMenuItem( MenuID, Index, 1)
    		Next	
    		
    	
    	Else	
    		SetMenuItemState(MenuID, 1613, SaveTool::GetSaveOption(1))
	    	SetMenuItemState(MenuID, 1614, SaveTool::GetSaveOption(0))
	    	SetMenuItemState(MenuID, 1617, SaveTool::GetSaveOption(4))	    	
	    EndIf 	
	    
	  EndProcedure
	  
	  
    Procedure Set_AppMenu(MenuID.i)    	
    	Protected MxItem
    	;
			; ============================================================= Windows Compatibility    	
    	OpenSubMenu("Windows Compatiblity")
    	UseModule Compatibility 
    	
	    	MxItem = 	ListSize(CompatibilitySystem()) -1
	    						ResetList(CompatibilitySystem())	    	
	    						Set_AppMenu_AddMenu(CompatibilitySystem())    					 
	    	
	    	MxItem = 	ListSize(CompatibilityEmulation()) -1	    	
	    						ResetList(CompatibilityEmulation())
	    						Set_AppMenu_AddMenu(CompatibilityEmulation())  
    	
    	UnuseModule Compatibility                              
    		CloseSubMenu()
    	CloseSubMenu()
    	;
			; ============================================================= Unreal
    	MenuBar()
    	OpenSubMenu("Support: Unreal")
    	UseModule UnrealHelp
    	
    		MxItem = 	GetMaxItems()-1
    							ResetList(UnrealCommandline())
    							Set_AppMenu_AddMenu(UnrealCommandline()) 
    	
    	UnuseModule UnrealHelp                      
    	CloseSubMenu()
    	;
			; ============================================================= Unity    	
    	;MenuBar()    	
    	OpenSubMenu("Support: Unity")
    	UseModule UnityHelp         
    		MxItem = 	GetMaxItems()-1
    							ResetList(UnityCommandline())
    							Set_AppMenu_AddMenu(UnityCommandline()) 
    	
    	UnuseModule UnityHelp                      
    	CloseSubMenu() 
    	;
			; ============================================================= Unity       	
    	;MenuBar()         	    	
    	OpenSubMenu("Support: Ports/ Nativ")
    	UseModule PortsHelp         
    		MxItem = 	GetMaxItems()-1
    							ResetList(PortCommandline())
    							Set_AppMenu_AddMenu(PortCommandline()) 
    	
    	UnuseModule PortsHelp                      
    	CloseSubMenu() 
    	MenuBar()  

    	MenuItem(1725, "vSystem Schnell Kommando") 
    	MenuItem(1735, "vSystem Schnell Kommando (Admin)")     	
    	MenuItem(1701, "Programm: Starte Asyncron")
    	MenuItem(1702, "Programm: Starte Api-Nativ")
    	OpenSubMenu("Programm: Borderless Modes")
    	MenuItem(1724, "Borderless Hilfe")
    	MenuBar()
    	MenuItem(1703, "Patch: Standard")
    	MenuItem(1705, "Patch: Overlapped-Window")
    	MenuItem(1704, "Patch: Zentrieren")	    		
    	MenuItem(1706, "Patch: Voll")
    	MenuItem(1707, "Patch: System-Metrics")
    	MenuItem(1710, "Lock Mouse (NoGo Outside)")   		
    	CloseSubMenu()     	
    	MenuItem(1711, "Programm: Speicher")
    	OpenSubMenu("Programm: CPU Zugehörgkeit")	 	    	
    	MenuItem(1715, "Benutze: 1 Kern")
    	MenuItem(1716, "Benutze: 2 Kern")
    	MenuItem(1717, "Benutze: 3 Kern")
    	MenuItem(1718, "Benutze: 4 Kern")     	
    	MenuItem(1719, "Benutze: Alle")
    	CloseSubMenu() 	    	
    	MenuItem(1721, "Programm: Firewall Blockieren")
    	MenuItem(1729, "Programm: Disable End-Hotkey")	    	 	
    	MenuBar()	    	
    	MenuItem(1712, "Windows: Disable Taskbar"        ,ImageID( DI::#_MNU_TBD ))
    	MenuItem(1713, "Windows: Disable Explorer"       ,ImageID( DI::#_MNU_EXD ))
    	MenuItem(1714, "Windows: Disable Aero/Uxsms"     ,ImageID( DI::#_MNU_AED ))	    	   		    		
    	MenuBar()	 	    	
    	MenuItem(1722, "vSystems: Media Kommando")
    	MenuItem(1726, "vSystems: Media Kommando ++")
    	MenuBar()	 	    	
    	OpenSubMenu("vSystem: Screenshot Aufnahme")
    	MenuItem(1708, "Taste Shift & Rollen")     	
    	MenuItem(1709, "Hotkey Ausschalten")
    	CloseSubMenu()
    	MenuBar()
    	MenuItem(1734, "Virtuelles Laufwerk aktiveren")    	
    	MenuBar()	     	
    	MenuItem(1720, "vSystems: Aktivere Monitoring"	,ImageID( DI::#_MNU_MON ))	    	
    	MenuItem(1727, "vSystems: Log Erlauben")
    	MenuItem(1728, "vSystems: Log in Datei Schreiben")
    	MenuItem(1700, "vSystems: Minimiere vSystems")		    	
    	MenuItem(1730, "vSystems: Keine Anführungs Zeichen")
    	MenuItem(1731, "vSystems: MAME Hilfe (Off)")
    	MenuItem(1732, "vSystems: Archiv Unterstützung")
    	MenuBar()		    	
    	;
			; vSystem Save Support    	   	    	
    	Set_AppMenu_SaveSupport(MenuID)
    	;
    	MenuBar() 
    	MenuItem(1723, "vSystem: Argument Hilfe")	    	 		
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts (C64 Datei Manager)
    ;
    ;
    ;*******************************************************************************************************************************************************************     
    Procedure Get_C64Menu(MenuID.i, GadgetID.i)
                        
        Select MenuID.i
            Case 1:  INVMNU::*LHMNU64\TRMODE = 0
            Case 2:  INVMNU::*LHMNU64\TRMODE = 1
            Case 3:  INVMNU::*LHMNU64\TRMODE = 2
            Case 4:  INVMNU::*LHMNU64\TRMODE = 3
            Case 5:  INVMNU::*LHMNU64\TRMODE = 4                  
            Case 6:  INVMNU::*LHMNU64\USWARP = MNU_SetGet(INVMNU::*LHMNU64\USWARP) 
            Case 7:  INVMNU::*LHMNU64\FORM40 = MNU_SetGet(INVMNU::*LHMNU64\FORM40) 
            Case 8:  INVMNU::*LHMNU64\FORMAT = 0
            Case 9:  INVMNU::*LHMNU64\FORMAT = 1
            Case 10: INVMNU::*LHMNU64\FORMAT = 2 
            Case 11: INVMNU::*LHMNU64\NIMAGE = 0                  
            Case 12: INVMNU::*LHMNU64\NIMAGE = 1  
            Case 13: INVMNU::*LHMNU64\NIMAGE = 2  
            Case 14: INVMNU::*LHMNU64\NIMAGE = 3  
            Case 15: INVMNU::*LHMNU64\NIMAGE = 4  
            Case 16: INVMNU::*LHMNU64\NIMAGE = 5  
            Case 17: INVMNU::*LHMNU64\NIMAGE = 6  
            Case 18: INVMNU::*LHMNU64\NIMAGE = 7                  
            Case 19: INVMNU::*LHMNU64\NIMAGE = 8                   
            Case 20: INVMNU::*LHMNU64\READDL = MNU_SetGet(INVMNU::*LHMNU64\READDL)
            Case 21: INVMNU::*LHMNU64\READIN = 1
            Case 22: INVMNU::*LHMNU64\READIN = 2
            Case 23: INVMNU::*LHMNU64\READIN = 3
            Case 24: INVMNU::*LHMNU64\READIN = 4
            Case 25: INVMNU::*LHMNU64\READIN = 5
            Case 26: INVMNU::*LHMNU64\READIN = 6
            Case 27: INVMNU::*LHMNU64\READIN = 7
            Case 28: INVMNU::*LHMNU64\READIN = 8
            Case 29: INVMNU::*LHMNU64\READIN = 9
            Case 30: INVMNU::*LHMNU64\READIN = 10
            Case 31: INVMNU::*LHMNU64\READIN = 11  
            Case 32: INVMNU::*LHMNU64\READIN = 12 
            Case 33: INVMNU::*LHMNU64\READIN = 13 
            Case 34: INVMNU::*LHMNU64\READIN = 14 
            Case 35: INVMNU::*LHMNU64\READIN = 15 
            Case 37:
                
                Request::*MsgEx\User_BtnTextL = "Ok"
                Request::*MsgEx\User_BtnTextR = "Cancel"        
                Request::*MsgEx\Return_String = Str(INVMNU::*LHMNU64\RETRYC)              
                
                r = Request::MSG(Startup::*LHGameDB\TitleVersion, "D64Copy Transfer Option","Enter the amount Retry Count (Current: "+INVMNU::*LHMNU64\RETRYC+") ",10,1,"",0,1,DC::#_Window_005)
                SetActiveGadget(DC::#ListIcon_003): 
                If (r = 0)
                    RetryCNT.i = Val( Request::*MsgEx\Return_String )
                    INVMNU::*LHMNU64\RETRYC = RetryCNT    
                EndIf
                If (r = 1)
                    ProcedureReturn -1
                EndIf                    
                
            Case 38: INVMNU::*LHMNU64\BAMOCP = MNU_SetGet(INVMNU::*LHMNU64\BAMOCP)                
            Default
                
                Debug MenuID 
        EndSelect
    ;*******************************************************************************************************************************************************************         
    EndProcedure    
    Procedure Set_C64Menu_SetCheckmarks(MenuID_Min.i, MenuID_Max.i, MenuID.l, MenuID_Aktiv)
        
        Protected CurrentID.i
        
        For CurrentID = MenuID_Min To MenuID_Max
            
            If MenuID_Aktiv = CurrentID
                SetMenuItemState(MenuID, CurrentID, 1)
                ProcedureReturn
            EndIf  
            
            SetMenuItemState(MenuID, CurrentID, 0)
        Next                  
        
    EndProcedure       
    Procedure Set_C64Menu(MenuID)        
        MenuItem(1, "Transfer: Auto")
        MenuItem(2, "Transfer: Original")        
        MenuItem(3, "Transfer: Serial 1")
        MenuItem(4, "Transfer: Serial 2")
        MenuItem(5, "Transfer: Parallel")        
        MenuBar()
        MenuItem(6, "Transfer: Use Warp")
        MenuBar()
        MenuItem(7, "Format: 40 Tracks")
        MenuItem(8, "Format: CBMFormat")
        MenuItem(9, "Format: CBMFormNG") 
        MenuItem(10,"Format: CBMCTRL")
        MenuBar()    
        OpenSubMenu("New Image Format")        
            MenuItem(11,"D64 (VC1541/2031)")
            MenuItem(14,"D71 (VC1571)")          
            MenuItem(17,"D81 (VC1581)") 
            MenuItem(19,"T64 (VC1530)")             
            MenuBar()
            MenuItem(12,"G64 (VC1541/2031)")
            MenuItem(13,"X64 (VC1541/2031)")               
            MenuItem(15,"G71 (VC1571)")
            MenuItem(16,"D80 (CBM8050)")        
            MenuItem(18,"D82 (CBM8250/1001")
       CloseSubMenu()
       MenuBar()            
       OpenSubMenu("Transfer: Options")  
       MenuItem(20,"Read First Directory")  
       MenuItem(38,"BAM Only Copy")         
       MenuItem(37,"Retry Count (Now: "+Str(INVMNU::*LHMNU64\RETRYC)+")")         
       MenuBar()  
       MenuItem(21,"Interleave Read: 01")     
       MenuItem(22,"Interleave Read: 02")
       MenuItem(23,"Interleave Read: 03")
       MenuItem(24,"Interleave Read: 04 (Serial 1)")
       MenuItem(25,"Interleave Read: 05")
       MenuItem(26,"Interleave Read: 06")
       MenuItem(27,"Interleave Read: 07 (Parallel)")
       MenuItem(28,"Interleave Read: 08")
       MenuItem(29,"Interleave Read: 09")
       MenuItem(30,"Interleave Read: 10")
       MenuItem(31,"Interleave Read: 11")
       MenuItem(32,"Interleave Read: 12")
       MenuItem(33,"Interleave Read: 13 (Serial 2)")
       MenuItem(34,"Interleave Read: 14")
       MenuItem(35,"Interleave Read: 15")
       MenuItem(36,"Interleave Read: 16 (Original)")
       CloseSubMenu()
;        
;        
;          -i, --interleave=VALUE    set interleave value; ignored wh
;                             warp mode; default values are:
; 
;                               original     16
; 
;                                         turbo r/w   warp wri
;                               serial1       4            6
;                               serial2      13           12
;                               parallel      7            4
                              
        ;
        ; Checkmark Transfermode 
        Select INVMNU::*LHMNU64\NIMAGE
            Case 0:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 11)                
            Case 1:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 12)                   
            Case 2:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 13)                    
            Case 3:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 14)      
            Case 4:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 15)
            Case 5:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 16)
            Case 6:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 17)                
            Case 7:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 18) 
            Case 8:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 19)                   
        EndSelect 
                    
                
        ;
        ; Checkmark Transfermode 
        Select INVMNU::*LHMNU64\TRMODE
            Case 0:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 1)                
            Case 1:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 2)                
            Case 2:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 3)                
            Case 3:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 4) 
            Case 4:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 5)               
        EndSelect                
        
        MNU_SetCheckmark(MenuID, 6, INVMNU::*LHMNU64\USWARP)
        MNU_SetCheckmark(MenuID, 7, INVMNU::*LHMNU64\FORM40) 
        
        ;
        ; Checkmark Format Programm
        Select INVMNU::*LHMNU64\FORMAT
           Case 0:
                SetMenuItemState(MenuID, 8, 1)
                SetMenuItemState(MenuID, 9, 0)
                SetMenuItemState(MenuID, 10,0)                 
            Case 1:
                SetMenuItemState(MenuID, 8, 0)
                SetMenuItemState(MenuID, 9, 1)
                SetMenuItemState(MenuID, 10,0)  
            Case 2:
                SetMenuItemState(MenuID, 8, 0)
                SetMenuItemState(MenuID, 9, 1)
                SetMenuItemState(MenuID, 10,0)                 
        EndSelect                     
        
        SetMenuItemState(MenuID, 20, INVMNU::*LHMNU64\READDL)
        
        Select INVMNU::*LHMNU64\READIN
            Case 1
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 21)  
            Case 2
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 22)                  
            Case 3
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 23)                  
            Case 4
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 24)                  
            Case 5
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 25)                  
            Case 6
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 26)                  
            Case 7
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 27)  
            Case 8
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 28)                  
            Case 9
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 29)                  
            Case 10
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 30)                  
            Case 11
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 31)                  
            Case 12
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 32)                  
            Case 13
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 33)                  
            Case 14
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 34)                  
            Case 15
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 35)                  
            Case 16
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 36)
        EndSelect
        
        SetMenuItemState(MenuID, 38, INVMNU::*LHMNU64\BAMOCP)        
    EndProcedure  
    
    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts (Thumbnails)
    ;
    ;
    ;*******************************************************************************************************************************************************************     
    Procedure Get_ShotsMenu(MenuID.i, GadgetID.i)
        
        Select MenuID.i
            Case 1: vImages::Screens_Menu_Import(GadgetID.i)
            Case 2: vImages::Screens_Menu_Save_Image(GadgetID.i)
            Case 3: vImages::Screens_Menu_Save_Images_All()
            Case 4: vImages::Screens_Menu_Delete_Single(GadgetID.i)
            Case 5: vImages::Screens_Menu_Delete_All()
            Case 8: vImages::Screens_SzeThumbnails_Reset()
                    vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*1, #True)
            Case 9: VEngine::Splitter_SetAll()
            Case 10: vEngine::Thumbnails_SetAll()
            Case 11: vEngine::Thumbnails_Set(1)
            Case 12: vEngine::Thumbnails_Set(2)   
            Case 13: vEngine::Thumbnails_Set(3)   
            Case 14: vEngine::Thumbnails_Set(4)                    
            Case 15: vEngine::Thumbnails_Set(5)                    
            Case 16: vEngine::Thumbnails_Set(6)                    
           ; Case 17: vEngine::Thumbnails_Set(7)
            Case 18: vImages::Screens_Menu_Copy_Image(GadgetID.i)
            Case 19: vImages::Screens_Menu_Paste_Import(GadgetID.i)                
            Case 20: vEngine::Splitter_SetHeight(0)
            Case 21: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*1, #True)
            Case 22: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*2, #True)                
            Case 23: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*3, #True)                
            Case 24: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*4, #True)                
            Default
                Debug MenuID 
        EndSelect                
        
   
    ;*******************************************************************************************************************************************************************         
    EndProcedure    
    Procedure Set_ShotsMenu()
    	
    	Protected ImageInfo.s = vImages::Screens_Menu_Info_Image()
    	
        MenuItem(1 , "Bild Laden...")           			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 0, #MF_BYPOSITION, ImageID( DI::#_MNU_LOD ),0)       
        MenuBar()        
        MenuItem(2 , "Dieses Bild Speichern")   			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 2, #MF_BYPOSITION, ImageID( DI::#_MNU_SVE ),0)
        MenuItem(3 , "Alle Bilder Speichern")   			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 3, #MF_BYPOSITION, ImageID( DI::#_MNU_SVE ),0)
        MenuBar()
        MenuItem(18 , "Bild Kopieren")          			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 5, #MF_BYPOSITION, ImageID( DI::#_MNU_COP ),0)
        MenuItem(19 , "Bild Einfügen")          			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 6, #MF_BYPOSITION, ImageID( DI::#_MNU_PAS ),0)          
        MenuBar()
        MenuItem(4 , "Dieses Bild Löschen")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 8, #MF_BYPOSITION, ImageID( DI::#_MNU_DPC ),0) 
        MenuItem(5,  "Alle Bilder Löschen")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 9, #MF_BYPOSITION, ImageID( DI::#_MNU_DPC ),0)
        MenuBar()
        MenuItem(20, "Splitter Höhe Einstellen")			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 11, #MF_BYPOSITION, ImageID( DI::#_MNU_SPL ),0)
        MenuItem(9,  "...Gleiche Höhe für alle")			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 12, #MF_BYPOSITION, ImageID( DI::#_MNU_SPL ),0)          
        MenuBar()
        MenuItem(8 , "Thumbnail zurücksetzen")  			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),14, #MF_BYPOSITION, ImageID( DI::#_MNU_WMT ),0)    
        MenuItem(10, "...Gleiche Höhe für alle")			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),15, #MF_BYPOSITION, ImageID( DI::#_MNU_WMT ),0)
        MenuBar()
        MenuItem(11, "1x1 Thumbnail Größe")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),17, #MF_BYPOSITION, ImageID( DI::#_MNU_TB1 ),0)
        MenuItem(12, "2x1 Thumbnail Größe")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),18, #MF_BYPOSITION, ImageID( DI::#_MNU_TB2 ),0)
        MenuItem(13, "3x1 Thumbnail Größe (*)") 			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),19, #MF_BYPOSITION, ImageID( DI::#_MNU_TB3 ),0)                       
        MenuItem(14, "4x1 Thumbnail Größe")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),20, #MF_BYPOSITION, ImageID( DI::#_MNU_TB4 ),0)
        MenuItem(15, "5x1 Thumbnail Größe")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),21, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0)                         
        MenuItem(16, "6x1 Thumbnail Größe")     			:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),22, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0)
        MenuBar()
        OpenSubMenu( "Thumbnail Höhen Option .." )    :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),24, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0)
             MenuItem(21 , "1 Thumbnail Pro Reihe")
             MenuItem(22 , "2 Thumbnail Pro Reihe")
             MenuItem(23 , "3 Thumbnail Pro Reihe")             
             MenuItem(24 , "4 Thumbnail Pro Reihe")             
        CloseSubMenu()
        If Len(ImageInfo) > 0
        	MenuBar()
        	MenuItem(25 , "Information..")							:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),26, #MF_BYPOSITION, ImageID( DI::#_MNU_PIN ),0)
        	MenuItem(26 , ImageInfo			)								:SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),27, #MF_BYPOSITION, ImageID( DI::#_MNU_PIN ),0)               
        EndIf	
        ;MenuItem(17, "7 Thumbnails Pro Reihe")   :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),22, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0) 
        
        If ( vImages::Screens_Menu_Check_Clipboard() = #False)
            DisableMenuItem(CLSMNU::*MNU\HandleID[0], 19, 1)
        EndIf
                     
    EndProcedure      
    Procedure Get_PopMenu1(MenuID.i, GadgetID.i)
    EndProcedure
    ;*******************************************************************************************************************************************************************          
    Procedure Set_PopMenu1() 
    EndProcedure      
    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts
    ;
    ;
    ;*******************************************************************************************************************************************************************    
    Procedure Get_TrayMenu(MenuID.i)
    	Select MenuID.i              
    		Case 5:  vDiskPath::ReConstrukt(1, #False) ; Search for All on Slot 1
    		Case 6:  vDiskPath::ReConstrukt(2, #False) ; Search for All on Slot 2                 
    		Case 8:  vDiskPath::ReConstrukt(3, #False) ; Search for All on Slot 3
    		Case 11: vDiskPath::ReConstrukt(4, #False) ; Search for All on Slot 4 
    		Case 12: vDiskPath::ReConstrukt(1, #True ) ; Search for Current Item on Slot 1
    		Case 13: vDiskPath::ReConstrukt(2, #True ) ; Search for Current Item on Slot 2                 
    		Case 14: vDiskPath::ReConstrukt(3, #True ) ; Search for Current Item on Slot 3
    		Case 15: vDiskPath::ReConstrukt(4, #True ) ; Search for Current Item on Slot 4   
    		Case 16: vInfoMenu::Cmd_DockSettings(0): vInfoMenu::Cmd_ResetWindow() 
    		Case 17: VEngine::Database_Remove(1,#True)  
    		Case 30: DesktopEX::CloseExplorer() 
    		Case 32: DesktopEX::SetTaskBar()
    		Case 35: vEngine::ServiceOption("uxsms", #False)                 
    		Case 34: vEngine::ServiceOption("uxsms", #True) 
    		Case 40: vEngine::MAME_Driver_Import()             	        
    		Case 41: vEngine::MAME_Roms_Check_Import()
    		Case 42: vEngine::MAME_Roms_Check()            	
    		Case 43: vEngine::MAME_Roms_Backup() 
    		Case 44: vEngine::MAME_Roms_GetInfos() 
    		Case 44: vEngine::MAME_Roms_GetInfos() 
    		Case 47: vEngine::MAME_Driver_Info_wwwAI() 
    		Case 48: VEngine::Database_Remove()   
    			
    			; Resetet die Fenster Position
    		Case 20
    			ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WPosX", Str(0),1)    
    			ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WPosY", Str(0),1)                
    			Startup::*LHGameDB\WindowPosition\X = 0
    			Startup::*LHGameDB\WindowPosition\Y = 0         
    			WinGuru::WindowPosition(DC::#_Window_001,Startup::*LHGameDB\WindowPosition\X,Startup::*LHGameDB\WindowPosition\Y)
    			
    		Case 1
    			Startup::*LHGameDB\SortMode = 0
    			Startup::*LHGameDB\SortXtendMode = #False
    			VEngine::Thread_LoadGameList_Sort()
    			
    		Case 2
    			Startup::*LHGameDB\SortMode = 1
    			Startup::*LHGameDB\SortXtendMode = #False
    			VEngine::Thread_LoadGameList_Sort()
    			
    		Case 3
    			Startup::*LHGameDB\SortMode = 2
    			Startup::*LHGameDB\SortXtendMode = #False
    			VEngine::Thread_LoadGameList_Sort()
    			
    		Case 4  			    				    			
    			VEngine::Thread_LoadGameList_Sort()     				
    			
    		Case 45
    			bReloadSort.i = #False
    			
    			If ( Startup::*LHGameDB\SortMode  >= 5 )
    				bReloadSort.i = #True
    			EndIf
    			
    			Startup::*LHGameDB\SortMode = 3
    			Startup::*LHGameDB\SortXtendMode = #False
    			
    			If ( bReloadSort = #True )
    				VEngine::Thread_LoadGameList_Action() 			
    			EndIf          	
    			
    		Case 46    			
    			bReloadSort.i = #False
    			
    			If ( Startup::*LHGameDB\SortMode  <= 4 )
    				bReloadSort.i = #True
    			EndIf
    			
    			Startup::*LHGameDB\SortMode = 5
    			Startup::*LHGameDB\SortXtendMode = #True
    			
    			If ( bReloadSort = #True )
    				VEngine::Thread_LoadGameList_Action() 			
    			EndIf	
    			
    		Case 7, 71 To 85     			    			    	    			
    			Startup::*LHGameDB\bvSystem_Restart = #True
    			
    			Select MenuID
    				Case 71: ;1280x720
    					vEngine::Splitter_SetHeight(0, #False, #True, 0)			: Startup::*LHGameDB\WindowHeight = 0
    				Case 72: ;1920x1080
    					vEngine::Splitter_SetHeight(0, #False, #True, 360)    : Startup::*LHGameDB\WindowHeight = 360				
    				Case 73: ;1024x1280
    					vEngine::Splitter_SetHeight(0, #False, #True, 560)    : Startup::*LHGameDB\WindowHeight = 560
    				Case 74: ;1024x768
    					vEngine::Splitter_SetHeight(0, #False, #True, 48)			: Startup::*LHGameDB\WindowHeight = 48
    				Case 75: ;1280x1024
    					vEngine::Splitter_SetHeight(0, #False, #True, 304)		: Startup::*LHGameDB\WindowHeight = 304
    				Case 76:	;1280x960
    					vEngine::Splitter_SetHeight(0, #False, #True, 240)   	: Startup::*LHGameDB\WindowHeight = 240 				
    				Case 77:	;3840x2160
    					vEngine::Splitter_SetHeight(0, #False, #True, 1440)   : Startup::*LHGameDB\WindowHeight = 1440
    				Case 78: ;1440x2560
    					vEngine::Splitter_SetHeight(0, #False, #True, 1840)   : Startup::*LHGameDB\WindowHeight = 1840
    				Case 79: ;1024x1600
    					vEngine::Splitter_SetHeight(0, #False, #True, 880) 		: Startup::*LHGameDB\WindowHeight = 880
    				Case 80: ;2160x3840
    					vEngine::Splitter_SetHeight(0, #False, #True, 3120)		: Startup::*LHGameDB\WindowHeight = 3120
    				Default
    					
    					r = vItemTool::DialogRequest_Add("Fenster Grösse (Höhe) Einstellen","Einstellung von 0 (Standard) bis unendlich. (Keine Minus Angabe)",Str(Startup::*LHGameDB\WindowHeight))              
    					If ( r = 1 )                   
    						SetActiveGadget(DC::#ListIcon_001)                
    						Startup::*LHGameDB\bvSystem_Restart = #False
    						ProcedureReturn
    					EndIf    				
    					vEngine::Splitter_SetHeight(0, #False, #True, Val(Request::*MsgEx\Return_String))
    					Startup::*LHGameDB\WindowHeight = Val(Request::*MsgEx\Return_String)
    			EndSelect
    			VEngine::Splitter_SetAll()
    			ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WindowHeight", Str(Startup::*LHGameDB\WindowHeight),1)	
    			
    			a.l = CreateFile(#PB_Any, Startup::*LHGameDB\SubF_vSys+"\_Restart.lck" )
    			Delay( 5 )
    			If ( a > 0 )
    				WriteStringN(a, "Restart..")
    				RunProgram(ProgramFilename())               
    				End
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Problem", "Problem beim Anlegen der Textdatei",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
    			EndIf    
    			
    		Case 9 : vFont::SetDB(1) 
    		Case 10: vFont::SetDB(2)                 
    		Case 98: vUpdate::Update_Check()
    			
    		Case 18:
    			File.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" + "stdout.txt"
    			If FileSize(File) <> -1
    				FFH::ShellExec(File, "open")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Die Datei konnte nicht geöffnet werden", File.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf    
    			
    		Case 19: 
    			File.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" + "error.txt"
    			If FileSize(File) <> -1
    				FFH::ShellExec(File, "open")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Die Datei konnte nicht geöffnet werden", File.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf 
    			
    		Case 21:
    			Path.s = Startup::*LHGameDB\Base_Path + "Systeme\SHOT\"
    			If FileSize(Path) = -2
    				FFH::ShellExec(Path, "explore")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Das Verzeichnis Existiert nicht.", Path.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf
    			
    		Case 22:
    			Path.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\"
    			If FileSize(Path) = -2
    				FFH::ShellExec(Path, "explore")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Das Verzeichnis Existiert nicht.", Path.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf                 
    			
    		Case 200 To 300
    			FFH::ShellExec(GetMenuItemText(CLSMNU::*MNU\HandleID[0], MenuID), "open")
    			
    		Case 23
    			ShotPath.s = Startup::*LHGameDB\Base_Path + "Systeme\SHOT\"                
    			ShotSize.i = 0
    			
    			ShotSize = vItemTool::File_GetFiles(ShotPath)
    			If  (ShotSize > 0 )
    				
    				Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Löschen?","Alle Snapshot Dateie(n) löschen? ("+Str(ShotSize)+") " + #CR$ + "Pfad: " + ShotPath,11,2,"",0,0,DC::#_Window_001)
    				If (Result = 0)                
    					While NextElement(FFS::FullFileSource())
    						Delay( 5 )
    						DeleteFile( FFS::FullFileSource()\FileName )
    					Wend
    				EndIf    
    				ClearList( FFS::FullFileSource() )
    				
    				Delay( 5 )
    				ShotSize = vItemTool::File_GetFiles(ShotPath)
    				If ( ShotSize > 0 )
    					Request::MSG(Startup::*LHGameDB\TitleVersion, "Fehler", "Konnte alle Snapshot Dateie(n) nicht löschen" ,2,1,"",0,0,DC::#_Window_001 )
    				Else
    					Request::MSG(Startup::*LHGameDB\TitleVersion, "Erfolgreich", "Alle Snapshot(s) (ShotSize) wurden gelöscht" ,2,1,"",0,0,DC::#_Window_001 )                    
    				EndIf
    			EndIf                    
    			
    		Case 24
    			If ( Startup::*LHGameDB\FileMonitoring = #False )
    				Monitoring::Activate("C:\")
    			Else
    				Monitoring::DeActivate()
    			EndIf
    			
    		Case 25
    			File.s = Startup::*LHGameDB\Monitoring\LatestLog
    			If FileSize(File) <> -1
    				FFH::ShellExec(File, "open")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Die Datei konnte nicht geöffnet werden", File.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf 
    			
    		Case 99: Startup::*LHGameDB\ProgrammQuit = Request_MSG_Quit()
    			
    		Case 1600 To 1699
    			Get_MenuItems_SaveSupport(MenuID.i)
    			
    		Case 2700 To 2750
    			Get_MenuItems_VirtualDriveSupport(MenuID.i)     			
    			
    	EndSelect       
    EndProcedure
    ;*******************************************************************************************************************************************************************    
    Procedure Set_TrayMenu_LoggUtil()    
        Protected LognPath.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\"
        
        MenuItem(22, "Log Verzeichnis Öffnen"                   ,ImageID( DI::#_MNU_EX1 )) 
        
        If ( FileSize(LognPath) <> -2 )      
            DisableMenuItem( CLSMNU::*MNU\HandleID[0], 22, 1)
        Else
            MenuItem(18, "Log Datei Öffnen: stdout"                 ,ImageID( DI::#_MNU_CLR ))
            MenuItem(19, "Log Datei Öffnen: error"                  ,ImageID( DI::#_MNU_CLR ))
        EndIf    
        
    EndProcedure

    ;*******************************************************************************************************************************************************************    
    Procedure Set_TrayMenu_ShotUtil()
    	
        Protected ShotPath.s = Startup::*LHGameDB\Base_Shot
        Protected ShotSize.i = 0
               
        If ( FileSize(ShotPath) <> -2 )
            MenuItem(21, "Capture Verzeichnis Öffnen"              ,ImageID( DI::#_MNU_EX1 ))            
            DisableMenuItem( CLSMNU::*MNU\HandleID[0], 21, 1)            
        Else                        
            ShotSize = vItemTool::File_GetFiles(ShotPath)  
            
            MenuItem(21, "Capture Verzeichnis Öffnen (" + Str(ShotSize) + ")",ImageID( DI::#_MNU_EX1 ))                
                       
            If ( ShotSize > 0 )
                OpenSubMenu("Capture Dateien ...")
                While NextElement(FFS::FullFileSource())
                    
                    MenuItem(200, FFS::FullFileSource()\FileName) 
                    
                    Debug "FullPath : " +FFS::FullFileSource()\FileName
                Wend
                CloseSubMenu()    
                ClearList( FFS::FullFileSource() )                
                MenuItem(23, "Capture Dateien Löschen"              ) 
            EndIf
        EndIf    
    EndProcedure  
    ;*******************************************************************************************************************************************************************    
    Procedure Set_TrayMenu_Monitor()        
                
        If ( Startup::*LHGameDB\FileMonitoring = #False )
            MenuItem(24, "Start: Monitoring"   ,ImageID( DI::#_MNU_MON ))            
            SetMenuItemState(CLSMNU::*MNU\HandleID[0], 24, 0) 
        Else
            MenuItem(24, "Stop: Monitoring"   ,ImageID( DI::#_MNU_MON ))             
            SetMenuItemState(CLSMNU::*MNU\HandleID[0], 24, 1) 
        EndIf          
        
        If ( FileSize(Startup::*LHGameDB\Monitoring\LatestLog) <> -1 ) And (Startup::*LHGameDB\Monitoring\LogHandle = 0)
            MenuItem(25, "Open Monitoring Log File"  ,ImageID( DI::#_MNU_MON ))            
        EndIf    
        
    EndProcedure  
    
    ;*******************************************************************************************************************************************************************    
    Procedure Set_Mame_Menu()        
    	
            MenuItem(41 , "Sets/Roms Einsortieren" 				,ImageID( DI::#_MNU_MIR ))
            MenuItem(42 , "Sets/Roms Überprüfen" 	      	,ImageID( DI::#_MNU_MIV ))
            MenuBar()             
            MenuItem(44 , "Informationen hinzufügen" 	  	,ImageID( DI::#_MNU_MIF ))             
            MenuBar()   
            MenuItem(43 , "Backup aus dem Internet" 	   	,ImageID( DI::#_MNU_MWW ))            
            MenuItem(47 , "Info Database (ArcadeItalia)" 	,ImageID( DI::#_MNU_MWW ))     
            
            If ( CountGadgetItems(DC::#ListIcon_001) > 0 )
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 41, 0)
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 42, 0) 
            	;DisableMenuItem(CLSMNU::*MNU\HandleID[0], 43, 0) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 44, 0)             	
            Else
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 41, 1) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 42, 1) 
            	;DisableMenuItem(CLSMNU::*MNU\HandleID[0], 43, 1) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 44, 1)             	
            EndIf
            
          EndProcedure 
          
    ;*******************************************************************************************************************************************************************    
     Procedure Set_SortBUtton()
     	
     	Protected ButtonText.s = ButtonEx::Gettext(DC::#Button_028, 0)  
    		MenuItem(4 , "Sortieren: "+ButtonText+"  " +Chr(9)+"F4" ,ImageID( DI::#_MNU_VSY ))
    		OpenSubMenu( "Sortieren und Anzeigen .."                ,ImageID( DI::#_MNU_VSI ))   
    		MenuItem(45, "Anzeigen : Programm"					       			,ImageID( DI::#_MNU_VSY ))  
    		MenuItem(46, "Anzeigen : Release"						       			,ImageID( DI::#_MNU_VSY ))
				CloseSubMenu()
			EndProcedure 
		;*******************************************************************************************************************************************************************			        		
			Procedure Set_TrayMenu_SaveSupport() 
				
			; CLSMNU::*MNU\HandleID[0]	MenuHandle
			;
			; ============================================================= vSystem Save Support    	   	    	
				Set_AppMenu_SaveSupport(CLSMNU::*MNU\HandleID[0])
	    	
			EndProcedure 
			
		;*******************************************************************************************************************************************************************				
			Procedure Set_TrayMenu_VirtualDriveSupport() 
				
			; CLSMNU::*MNU\HandleID[0]	MenuHandle
			;
			; ============================================================= VirtualDriveSupport   	   	    	
				Set_AppMenu_VirtualDriveSupport(CLSMNU::*MNU\HandleID[0])
	    	
			EndProcedure 
			
		;*******************************************************************************************************************************************************************			        		
			Procedure Set_TrayMenu_RegsSupport() 
				
			; CLSMNU::*MNU\HandleID[0]	MenuHandle
			;
			; ============================================================= vSystem Save Support    	   	    	
				Set_AppMenu_RegsSupport(CLSMNU::*MNU\HandleID[0])
	    	
			EndProcedure 				
    ;*******************************************************************************************************************************************************************     
    Procedure Set_TrayMenu()
    	
    	If IsWindow(DC::#_Window_001)                            
    		MenuItem(1 , "Sortieren: Gametitle " +Chr(9)+"F1"       ,ImageID( DI::#_MNU_VSY ))
    		MenuItem(2 , "Sortieren: Platform  " +Chr(9)+"F2"       ,ImageID( DI::#_MNU_VSY ))      
    		MenuItem(3 , "Sortieren: Language  " +Chr(9)+"F3"       ,ImageID( DI::#_MNU_VSY ))            
    		Set_SortBUtton()     		  		       
    		MenuBar()            
    		MenuItem(40 , "Import. Titel in die Datenbank"	     		,ImageID( DI::#_MNU_MIP ))
    		OpenSubMenu( "Mame Tools .."                            ,ImageID( DI::#_MNU_MAM ))               
    		Set_Mame_Menu() 
    		CloseSubMenu()             
    		MenuBar()                     
    		MenuItem(48, "Eintrag/ Alle Löschen"                    ,ImageID( DI::#_MNU_SPL ))     		
    		MenuItem(17, "Einträge Löschen bis auf 1"               ,ImageID( DI::#_MNU_SPL ))
    		MenuBar()  
    		Set_TrayMenu_LoggUtil()   
    		MenuBar()              
    		Set_TrayMenu_ShotUtil()
    		MenuBar()
    		Set_TrayMenu_Monitor()
    		MenuBar()              
    		OpenSubMenu( "Pfade .."                                 ,ImageID( DI::#_MNU_DIR ))                       
    		MenuItem(5 , "Alle Prüfen & Reparieren (Slot 1)"        ,ImageID( DI::#_MNU_RAL )) 
    		MenuItem(6 , "Alle Prüfen & Reparieren (Slot 2)"        ,ImageID( DI::#_MNU_RAL ))                       
    		MenuItem(8 , "Alle Prüfen & Reparieren (Slot 3)"        ,ImageID( DI::#_MNU_RAL ))                       
    		MenuItem(11, "Alle Prüfen & Reparieren (Slot 4)"        ,ImageID( DI::#_MNU_RAL ))
    		MenuBar() 
    		MenuItem(12, "Aktuellen Prüfen & Reparieren (Slot 1)"   ,ImageID( DI::#_MNU_RNE )) 
    		MenuItem(13, "Aktuellen Prüfen & Reparieren (Slot 2)"   ,ImageID( DI::#_MNU_RNE ))                        
    		MenuItem(14, "Aktuellen Prüfen & Reparieren (Slot 3)"   ,ImageID( DI::#_MNU_RNE )) 
    		MenuItem(15, "Aktuellen Prüfen & Reparieren (Slot 4)"   ,ImageID( DI::#_MNU_RNE ))            
    		CloseSubMenu()       
    		MenuBar()
    		OpenSubMenu( "Windows Einstellung .."                   ,ImageID( DI::#_MNU_SWN ))      		
    		MenuItem(34, "Enable : Aero/Uxsms"                      ,ImageID( DI::#_MNU_AEE ))
    		MenuBar()
    		MenuItem(30, "Disable: Explorer"                        ,ImageID( DI::#_MNU_EXD ))         
    		MenuItem(32, "Disable: Taskbar"                         ,ImageID( DI::#_MNU_TBD ))                      
    		MenuItem(35, "Disable: Aero/Uxsms"                      ,ImageID( DI::#_MNU_AED ))
    		CloseSubMenu()      		
    		MenuBar()
    		Set_TrayMenu_VirtualDriveSupport()     		
    		MenuBar()    		
    		Set_TrayMenu_SaveSupport()     		
    		MenuBar()
    		;Set_TrayMenu_RegsSupport()     		
    		;MenuBar()      		
    		OpenSubMenu( "Einstellungen"   													,ImageID( DI::#_MNU_VSP )) 
    		MenuItem(9 , "Schriftart: Title..."                     ,ImageID( DI::#_MNU_FDL ))
    		MenuItem(10, "Schriftart: Liste..."                     ,ImageID( DI::#_MNU_FDL )) 
    		MenuBar()                   
    		MenuItem(20, "Fenster Zurücksetzen"                     ,ImageID( DI::#_MNU_WMS ))                                        
    		MenuItem(7 , "Fenster Höhe Ändern"                      ,ImageID( DI::#_MNU_WMH ))    			
    		MenuItem(71, "Fenster Höhe (Desktop 1280x720)"          ,ImageID( DI::#_MNU_WMH )) 
    		MenuItem(72, "Fenster Höhe (Desktop 1920x1080)"         ,ImageID( DI::#_MNU_WMH ))
    		MenuItem(73, "Fenster Höhe (Desktop 1024x1280)"         ,ImageID( DI::#_MNU_WMH ))
    		MenuItem(74, "Fenster Höhe (Desktop 1024x768)"          ,ImageID( DI::#_MNU_WMH ))
    		MenuItem(75, "Fenster Höhe (Desktop 1280x1024)"         ,ImageID( DI::#_MNU_WMH ))
    		MenuItem(76, "Fenster Höhe (Desktop 1280x960)"         ,ImageID( DI::#_MNU_WMH ))
    		MenuItem(77, "Fenster Höhe (Desktop 3840x2160)"         ,ImageID( DI::#_MNU_WMH ))   
    		MenuItem(78, "Fenster Höhe (Desktop 1440x2560)"         ,ImageID( DI::#_MNU_WMH ))    			
    		MenuItem(79, "Fenster Höhe (Desktop 1024x1600)"         ,ImageID( DI::#_MNU_WMH ))  
    		MenuItem(80, "Fenster Höhe (Desktop 2160x3840)"         ,ImageID( DI::#_MNU_WMH ))   
    		MenuBar()            
    		MenuItem(16, "Info Zurücksetzen"                        ,ImageID( DI::#_MNU_WRS ))
    		CloseSubMenu()
    		MenuBar()             
    	EndIf
    	MenuItem(98, "vSystems Update"														,ImageID( DI::#_MNU_VSU ))        
    	MenuItem(99, "vSystems Beenden"														,ImageID( DI::#_MNU_VSY ))
    	
   	
    	
    EndProcedure
    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 440
; FirstLine = 178
; Folding = BEBAc-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\NewGame\
; Debugger = IDE
; EnableUnicode