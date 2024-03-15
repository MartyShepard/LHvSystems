DeclareModule Interact
    
    Declare MainCode() 
      
EndDeclareModule




Module Interact
    Global Thread.l
    
    Procedure.w MouseWheelDelta() 
      Protected x.w
      
      x.w = ((EventwParam()>>16)&$FFFF) 
      ProcedureReturn -(x / 120) 
    EndProcedure 

    ;******************************************************************************************************************************************
    ;  Events die "Auschliesslich" Die Objecte der Strings behandeln    
    ;__________________________________________________________________________________________________________________________________________
    Procedure.i MainCode_StringCallBack(GadgetID.i, EvntwParam, EvntWait)
        
        Select EvntWait                 
                ;
                ; Unterstützung für (Doppel) Mausklick in Strings um eine neues Fenster Öffnen
                ; Kann nicht an das Haupt/StringCallback gebunden Werden. WaitWindowEvent() und WatiWindow() Kollidieren
            Case #WM_LBUTTONDBLCLK 
                Select GadgetID.i                        
                    Case DC::#String_003                    : vWindows::OpenWindow_Sys1() :VEngine::ListBox_GetData_LeftMouse(#True)
                    Case DC::#String_004                    : vWindows::OpenWindow_Sys1(1):VEngine::ListBox_GetData_LeftMouse(#True)                                        
                    Case DC::#String_006,   DC::#String_007 : vWindows::OpenWindow_Sys2() :VEngine::ListBox_GetData_LeftMouse(#True)                          
                    Case DC::#String_008 To DC::#String_011 :                              VEngine::GetFile_Media(GadgetID.i)                      
                    Case DC::#String_107                    : vWindows::OpenWindow_Sys64(DC::#String_008,GadgetID) 
                    Case DC::#String_108                    : vWindows::OpenWindow_Sys64(DC::#String_009,GadgetID)
                    Case DC::#String_109                    : vWindows::OpenWindow_Sys64(DC::#String_010,GadgetID)
                    Case DC::#String_110                    : vWindows::OpenWindow_Sys64(DC::#String_011,GadgetID)
                EndSelect
                
            Case #WM_CHAR
                Select EvntwParam
                    Case #VK_RETURN
                        If ( GadgetID = DC::#String_006)
                            vEngine::Database_Set_ProgramTitle(GadgetID)    
                        EndIf                        
                        If ( GadgetID = DC::#String_007)
                            vEngine::Database_Set_ProgramArgs(GadgetID)    
                        EndIf                       
                EndSelect
        EndSelect            
        ProcedureReturn EvntWait
    EndProcedure
    ;******************************************************************************************************************************************
    ; 
    ;__________________________________________________________________________________________________________________________________________   
    Procedure AutoOpen()
                ;
                ; Hole die Auto Öffnen Einstellung
                Startup::*LHGameDB\InfoWindow\bTabAuto = ExecSQL::iRow(DC::#Database_001,"Settings","TabAutoOpen",0,1,"",1)

                If ( Startup::*LHGameDB\InfoWindow\bActivated = #False ) And Not IsWindow(DC::#_Window_006) 
                    
                    If ( vInfo::Tab_AutoOpen() = 1 )
                                                 
                        If ( vEngine::Text_GetDB_Check() = 1 )
                            ButtonEX::SetState(DC::#Button_016,1):
                            vWindows::OpenWindow_EditInfos()                                                     
                        EndIf    
                    EndIf    
                EndIf 
     EndProcedure   
    ;******************************************************************************************************************************************
    ; 
    ;__________________________________________________________________________________________________________________________________________
    Procedure MainCode() 
                  
        Protected TrayIcon.l, ShotX.i, ShotY.i     
        
        ;
        ; Add a Systray Icon
        
        SSTTIP::Tooltip_TrayIcon(ProgramFilename(), DC::#TRAYICON001, DC::#_Window_001, Startup::*LHGameDB\TrayIconTitle) 
        
        
        ; Logitech 
        Logitech_Common::GetLCorePath()
        LCD::Init(Startup::*LHGameDB\TitleVersion, LCD::GetLCD_DLL_Path())  
        If LCD::Color_IsConnected() Or LCD::Mono_IsConnected()
        	;
        	; Can not Color Version test
            LCD::Mono_SetText(0, Startup::*LHGameDB\TitleSimpled )
            LCD::Update()                   
        EndIf        
        
        
       ;StringSetCallback(DC::#String_007, 0)
        
        ; Drag'n Drop für die Dateien/ Siehe WaitWindowEvent()
        ;
        EnableGadgetDrop(DC::#String_001, #PB_Drop_Files|#PB_Drop_Text , #PB_Drag_Copy)        
        EnableGadgetDrop(DC::#String_008, #PB_Drop_Files , #PB_Drag_Copy)
        EnableGadgetDrop(DC::#String_009, #PB_Drop_Files , #PB_Drag_Copy)        
        EnableGadgetDrop(DC::#String_010, #PB_Drop_Files , #PB_Drag_Copy)
        EnableGadgetDrop(DC::#String_011, #PB_Drop_Files , #PB_Drag_Copy)
        
        ;
        ; Drag'nDrop Support für die Screenshots
        vImages::Screens_DragDrop_Support()  
        
        ;
        ; FileSystem im String
        FFH::SHAutoComplete(DC::#String_008, #True)
        FFH::SHAutoComplete(DC::#String_009, #True)
        FFH::SHAutoComplete(DC::#String_010, #True)
        FFH::SHAutoComplete(DC::#String_011, #True)       
        
        
        vFont::GetDB(1, DC::#Text_001)
        vFont::GetDB(1, DC::#Text_002)
        vFont::GetDB(2, DC::#ListIcon_001)
        
        HideWindow(DC::#_Window_001,0) 
       ;VEngine::Switcher_Pres_List(0)        
          
        ; Initialisert die Datenbank
        ;
        SetGadgetText(DC::#Text_004, "Database: Open")
        VEngine::Switcher_Pres_List(DC::#Button_010)  
        VEngine::Switcher_Pres_List(DC::#Button_023)          
        ;
        ; Fenster Anzeigen
        
        ;
        ; Sortier Modus Configuration Laden
        VEngine::Thread_LoadGameList_Sort(#False)        
        
        VEngine::Thread_LoadGameList_Action()                  
        
        ;
				; Sortier Modus Anwenden
        If ( Startup::*LHGameDB\SortMode >= 5)
        	   Startup::*LHGameDB\SortMode = 1
        	
        	   VEngine::Thread_LoadGameList_Sort()
        	   Startup::*LHGameDB\SortMode = 5
       	Else
        	 	VEngine::Thread_LoadGameList_Sort()
        endif
        
        ;
        ; Migrate
        If ( Startup::*LHGameDB\BaseSVNMigrate = #True )
            
            ; Running Migrate
            DB_Update::Update_Base()
            Request::MSG( Startup::*LHGameDB\TitleVersion, "Update/Migration","Backup Database Finished - Restart vSystems" ,2,0) 
            Startup::*LHGameDB\ProgrammQuit = #True
        EndIf
        
        
        ;
        ; initialisierung des Compatibility Modus
        UseModule Compatibility
            DataModes(CompatibilitySystem.CmpOSModus(), CompatibilityEmulation.CmpEmulation())
        UnuseModule Compatibility  
            
        ;
        ; initialisierung Unreal Helper Modus
        UseModule UnrealHelp
            DataModes(UnrealCommandline.CmpUDKModus())
        UnuseModule UnrealHelp             
        
        AutoOpen()
        
        Startup::*LHGameDB\bFirstBootUp = #False
        

        Repeat
            
        	;vSystem::System_InfoToolTip(#True)    
        	vSystem::LCD_Info(#True, #False)
            
            EvntWait = WaitWindowEvent(): EvntWindow = EventWindow(): EvntGadget = EventGadget(): EvntType   = EventType()
            EvntMenu = EventMenu()      : EvntwParam = EventwParam(): EvntlParam = EventlParam(): EvntData   = EventData()                                              
            
            Startup::*LHGameDB\SwitchNoItems = VEngine::Switcher_Pres_NoItems() 
            ;
            ;
            EvntWait = MainCode_StringCallBack(EvntGadget, EvntwParam, EvntWait)                                                     
            
          
            
            Select EvntWait                                                           
                    
                                                               
                Case #PB_Event_GadgetDrop                    
                    vWindows::DragnDrop_Support(EvntGadget.i)                    
                                                   
                    ;***************************************************************************
                    ;        
                Case #WM_MOUSEWHEEL
                    If Form::IsOverObject( GadgetID( DC::#Contain_10 ) )
                        SetGadgetAttribute(DC::#Contain_10, #PB_ScrollArea_Y, GetGadgetAttribute(DC::#Contain_10, #PB_ScrollArea_Y) + ( MouseWheelDelta() * GadgetHeight( DC::#Contain_10 ) ))                                             
                        Continue    
                    EndIf                         
                            
                Case #WM_KEYUP                                               
                    Select EvntwParam 
                        ;
                        ; Beim Loslassen der Taste wird die grössse gespeichert
                        Case #VK_F5, 102, 104,103 ; Grösser
                            If WindowID(DC::#_Window_001) And ( Startup::*LHGameDB\Switch = 0 ) And ( Startup::*LHGameDB\SwitchNoItems = 1 ) And (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                ;
                                ; Resete Tastenwiederholung
                                EvntRepeat = 0                                
                                ;
                                ;
                                vImages::Screens_ChgThumbnails(0,#True,EvntRepeat,EvntWait)  
                                Continue
                            EndIf 
                        Case #VK_F6, 98, 100,105 ; Kleiner (Kein Neuladen der Images)
                            If WindowID(DC::#_Window_001) And ( Startup::*LHGameDB\Switch = 0 ) And ( Startup::*LHGameDB\SwitchNoItems = 1 ) And (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                ;
                                ; Resete Tastenwiederholung
                                EvntRepeat = 0                                
                                ;
                                ;
                                vImages::Screens_ChgThumbnails(0,#True,EvntRepeat,-999)                                                                
                                Continue
                            EndIf                          
                            
                        Case #VK_DELETE
                            If (Startup::*LHGameDB\Switch = 0)  And (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                VEngine::Database_Remove()  
                                Continue
                            EndIf                           
                            ;  
                            ; Benutzer Drückt Escape im Editor Fenster
                        Case #VK_ESCAPE:
                            If (Startup::*LHGameDB\Switch = 1)  And (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                VEngine::ListBox_GetData_LeftMouse(#True)                                        
                                VEngine::Switcher_Pres_List( DC::#Button_024)
                                Continue
                            EndIf    
                        Case #VK_F1                           
                            If (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                Startup::*LHGameDB\SortMode = 0
                                VEngine::Thread_LoadGameList_Sort()                            
                                Continue
                            EndIf
                            
                        Case #VK_F2
                            If (Startup::*LHGameDB\InfoWindow\bActivated = #False)                            
                                Startup::*LHGameDB\SortMode = 1
                                VEngine::Thread_LoadGameList_Sort()                          
                                Continue
                            EndIf
                            
                        Case #VK_F3                           
                            If (Startup::*LHGameDB\InfoWindow\bActivated = #False)                            
                                Startup::*LHGameDB\SortMode = 2
                                VEngine::Thread_LoadGameList_Sort()
                                Continue
                            EndIf
                            
                        Case #VK_F4                                                       
                        	If (Startup::*LHGameDB\InfoWindow\bActivated = #False)                            
                        			If 	(Startup::*LHGameDB\SortMode <= 4)
                        				Startup::*LHGameDB\SortMode = 3
                        			Else
                        				Startup::*LHGameDB\SortMode = 5
                        			EndIf
                              VEngine::Thread_LoadGameList_Sort()
                              Continue
                            EndIf                                             
                        	
                        Case #VK_RETURN                                                       
                            If (Startup::*LHGameDB\InfoWindow\bActivated = #False) And ( GetActiveGadget() = DC::#ListIcon_001 )
                                VEngine::DOS_Prepare()
                               Continue                           
                            EndIf                            
                            
                        Case #VK_UP, #VK_DOWN, #VK_0 To #VK_9, #VK_A To #VK_Z, 34, 33
                            If  ( GetActiveGadget() = DC::#ListIcon_001 ) And (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                vInfo::Modify_EndCheck()
                                vInfo::Modify_Reset()
                                VEngine::ListBox_GetData_KeyBoard(EvntwParam)
                                VEngine::ListBox_GetData_LeftMouse()
                                Debug "MainCode() Up/Down"
                                Continue
                            EndIf                                                                               
                            
                        Default
                            If (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                            EndIf    
                            Debug "MainCode() Main KeyCode : " + EvntwParam + " - Key: " + Chr(EvntwParam)
                    EndSelect     
                    
                    ;
                    ; Registriere Hotkey CTRL-S für Speichern/Updaten                    
                Case #WM_HOTKEY
                    Select EvntwParam
                        Case 1
                            If ( Startup::*LHGameDB\Switch = 1 )
                                 Continue
                             EndIf
                     EndSelect
                                          
                Case #WM_KEYDOWN
                    
                    If ( GetAsyncKeyState_(#VK_CONTROL) & 32768 = 32768 And GetAsyncKeyState_(#VK_S) & 32768 = 32768 And Startup::*LHGameDB\Switch = 1 )And (Startup::*LHGameDB\InfoWindow\bActivated = #False)                                 
                                 VEngine::Update_Changes()
                                 VEngine::ListBox_GetData_LeftMouse(#True)                                        
                                 VEngine::Switcher_Pres_List(DC::#Button_023)
                                Continue
                    EndIf
                             
                    Select EvntwParam
                            ;
                            ; Beim Drücken der Taste wird die Thumbnail grösse geändert                            
                            ; 100 NumKey L w - 1
                            ; 102 NumKey R w + 1
                            ; 104 NumKey U h + 1
                            ;  98 NumKey D h - 1 
                        Case #VK_F5, #VK_F6, 98, 100, 102, 104, 103, 105
                            If WindowID(DC::#_Window_001) And ( Startup::*LHGameDB\Switch = 0 )  And ( Startup::*LHGameDB\SwitchNoItems = 1 )And (Startup::*LHGameDB\InfoWindow\bActivated = #False)
                                ;
                                ; Tastenwiederholung
                                EvntRepeat + 1
                                vImages::Screens_ChgThumbnails(EvntwParam, #False, EvntRepeat,EvntWait)
                                Continue
                            EndIf                                                                             
                        Default
                    EndSelect
                                             
                     
                Case #PB_Event_Gadget                    
                    Select EvntGadget
                                                        
                        Case DC::#String_001 To DC::#String_011
                            Select EvntType
                                Case #PB_EventType_Change 
                                    VEngine::Change_Title(EvntGadget)
                                    Continue
                            EndSelect
                                                   
                        Case DC::#Calendar
                            Select EvntType
                                Case #PB_EventType_Change 
                                    VEngine::Database_Set_Release()
                                    Continue
                            EndSelect 
                            
                            ;
                            ; Splitter Gadget
                        Case  DC::#Splitter1  
                            Select EvntType                                                                                                                                        
                                Case 2  ; Links Doppelklick
                                    ;                                                                        
                                    ; Resette die Höhe der ListIco                                    
                                    VEngine::PicSupport_Hide_Show()                                                                                                                                             
                                    Continue
                                Case #PB_EventType_MouseMove 
                                    ;
                                    ; Verändere die Höhe der ListIcon                                    
                                    ResizeGadget(DC::#ListIcon_001, #PB_Ignore, #PB_Ignore,#PB_Ignore,GadgetHeight(DC::#Contain_02))
                                    Continue
                                    
                                Case #PB_EventType_LeftButtonUp
                                    If WindowID(DC::#_Window_001) And ( Startup::*LHGameDB\Switch = 0 ) And ( Startup::*LHGameDB\SwitchNoItems = 1 )
                                        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", Str(GetGadgetState(DC::#Splitter1) ),Startup::*LHGameDB\GameID)  
                                        Continue
                                    EndIf    
                            EndSelect                                                              
                            
                        Case DC::#ListIcon_001
                        	
                            Select EvntType                                                                                                    
                                Case #PB_EventType_LeftClick
                                    ;BaseCode::GetBaseItem(0)                                   
                                    If ( GetActiveGadget() = DC::#ListIcon_001 ) And (EvntType = #PB_EventType_LeftClick)
                                        vInfo::Modify_EndCheck()
                                        vInfo::Modify_Reset()
                                        VEngine::ListBox_GetData_LeftMouse()
                                        Delay(3)
                                        Continue
                                    EndIf                                                                        
                                    ;                             
                                Case #PB_EventType_RightClick       
                                    If  ( GetActiveGadget() = DC::#ListIcon_001 ) And (EvntType = #PB_EventType_RightClick)
                                    	VEngine::ListBox_GetData_LeftMouse()
                                    	Delay(3)
                                        Continue
                                    EndIf    
                                    
                                    
                                Case #PB_EventType_LeftDoubleClick                                 
                                    If  ( GetActiveGadget() = DC::#ListIcon_001 ) And (EvntType = #PB_EventType_LeftDoubleClick)
                                    	VEngine::DOS_Prepare()
                                    	Delay(3)
                                        Continue
                                    EndIf                                      
                            EndSelect
                            
                               
                            ;
                            ; Button Liste (Standard Ansicht)
                        Case DC::#Button_010 To DC::#Button_014, DC::#Button_016, DC::#Button_283 To DC::#Button_287
                            
                            If Form::IsOverObject(GadgetID(DC::#Button_287)) And ( ToolTipSystemShow = #True )
                                ToolTipSystemShow = #False
                                vSystem::System_InfoToolTip()
                                SSTTIP::ToolTipMode(0,DC::#Button_287,Startup::ToolTipSystemInfo.s)
                                Delay(25)
                            Else
                                ToolTipSystemShow = #True
                                Delay(25)
                            EndIf
                            
                            Select ButtonEX::ButtonExEvent(EvntGadget)  
                                Case ButtonEX::#ButtonGadgetEx_Pressed
                                    Select EvntGadget
                                            ;
                                            ; Add, Neuer Eintrag
                                        Case DC::#Button_010
                                            ButtonEX::SetState(EvntGadget,0): VEngine::DataBase_Add()
                                            Continue
                                            
                                            ;
                                            ; Duplicate
                                        Case DC::#Button_011
                                            ButtonEX::SetState(EvntGadget,0): VEngine::DataBase_Duplicate()
                                            Continue
                                            
                                            ;
                                            ; Eintrag Löschen
                                        Case DC::#Button_012
                                            ButtonEX::SetState(EvntGadget,0): VEngine::Database_Remove()  
                                            Continue
                                            ;
                                            ; Eintrag Editieren
                                        Case DC::#Button_013
                                            ButtonEX::SetState(EvntGadget,0): VEngine::Switcher_Pres_List(EvntGadget)                                               
                                            Continue
                                          
                                            ;
                                            ; Start programm
                                        Case DC::#Button_014
                                            ButtonEX::SetState(EvntGadget,0): VEngine::DOS_Prepare()
                                            Continue
                                            
                                            ;
                                            ; Edit Infos zum Item
                                        Case DC::#Button_016
                                            Select ButtonEX::Getstate(EvntGadget)
                                                Case 0
                                                    
                                                    ButtonEX::SetState(EvntGadget,1):
                                                    vWindows::OpenWindow_EditInfos()                                                                                                         
                                                    Continue
                                                Case 1                                                 
                                                    ButtonEX::SetState(EvntGadget,0):
                                                    vInfo::Modify_EndCheck()
                                                    vInfo::Modify_Reset()                                                       
                                                    vInfo::Window_Props_Save()   
                                                    vInfo::Window_Close()
                                                    Continue
                                            EndSelect  
                                            
                                            ;
                                            ; Edit Infos zum Item
                                        Case DC::#Button_283 To DC::#Button_286
                                            Select ButtonEX::Getstate(EvntGadget)
                                                Case 0                               
                                                    vInfo::Tab_Switch(EvntGadget)
                                                    vEngine::Text_GetDB()
                                                    ButtonEX::SetState(EvntGadget,1):
                                                    Continue
                                                Case 1
                                                    ButtonEX::SetState(EvntGadget,1):
                                                    Continue
                                                    
                                            EndSelect 
                                            
                                           ;
                                           ; Info Button
                                        Case DC::#Button_287                                           
                                            ButtonEX::SetState(EvntGadget,0)
                                            Continue                                            
                                    EndSelect                                          
                            EndSelect                         
                            
                            Select EvntType
                                Case #PB_EventType_RightClick
                                    ButtonEX::SetState(EvntGadget,ButtonEX::GetState(EvntGadget) )
                                    Select ButtonEX::ButtonExEvent(EvntGadget) 
                                        Case ButtonEX::#ButtonGadgetEx_Pressed:
                                            
                                            ;Select EvntGadget
                                                ;
                                                ; Einträge Löschen bias auf den ersten
                                            ;    Case DC::#Button_012
                                            ;        ButtonEX::SetState(EvntGadget,0): VEngine::Database_Remove(1,#True) 
                                            ;        Continue                                                    
                                            ;EndSelect
                                    EndSelect
                                    
                                            Select EvntGadget                                            
                                                Case DC::#Button_283: vInfoMenu::Cmd_TabRen(EvntGadget):Continue 
                                                Case DC::#Button_284: vInfoMenu::Cmd_TabRen(EvntGadget):Continue                                             
                                                Case DC::#Button_285: vInfoMenu::Cmd_TabRen(EvntGadget):Continue                                             
                                                Case DC::#Button_286: vInfoMenu::Cmd_TabRen(EvntGadget):Continue                                             
                                            EndSelect        
                                    ;EndSelect
                            EndSelect                                  
                            ;
                            ;Einstellungen
                            ;                   
                        Case DC::#Button_023, DC::#Button_024
                            Select ButtonEX::ButtonExEvent(EvntGadget)  
                                Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(EvntGadget,0)
                                    Select EvntGadget
                                            ;                                                         
                                            ; Update Title, Year, Subtitle                               
                                        Case DC::#Button_023
                                            VEngine::Update_Changes()                                            
                                            
                                            ;                                            
                                            ; Dont Update Title Year etc..                                            
                                        Case DC::#Button_024
                                            
                                    EndSelect
                                    VEngine::ListBox_GetData_LeftMouse(#True)                                        
                                    VEngine::Switcher_Pres_List(EvntGadget)
                                    
                            EndSelect
                            ;
                            ;
                            ; Disk Image Handling/ Datei Manager
                            ; 
                        Case DC::#Button_103 To DC::#Button_106       
                            Select ButtonEX::ButtonExEvent(EvntGadget)  
                                Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(EvntGadget,0)
                                    Select EvntGadget
                                        Case DC::#Button_103:  vEngine::FileManageR_MediumCheck(DC::#String_008,DC::#String_107):Continue
                                        Case DC::#Button_104:  vEngine::FileManageR_MediumCheck(DC::#String_009,DC::#String_108):Continue
                                        Case DC::#Button_105:  vEngine::FileManageR_MediumCheck(DC::#String_010,DC::#String_109):Continue                                            
                                        Case DC::#Button_106:  vEngine::FileManageR_MediumCheck(DC::#String_011,DC::#String_110):Continue                                            
                                    EndSelect                                                                                                      
                            EndSelect                                             
                            ;
                            ;Sortier Buttons
                            ;                                
                        Case DC::#Button_025 To DC::#Button_028
                            Select ButtonEX::ButtonExEvent(EvntGadget)  
                                Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(EvntGadget,0)
                                    Select EvntGadget
                                            ;                                                         
                                            ; Update Title, Year, Subtitle                               
                                        Case DC::#Button_025: Startup::*LHGameDB\SortMode = 0: VEngine::Thread_LoadGameList_Sort():Continue                                            
                                        Case DC::#Button_026: Startup::*LHGameDB\SortMode = 1: VEngine::Thread_LoadGameList_Sort():Continue   
                                        Case DC::#Button_027: Startup::*LHGameDB\SortMode = 2: VEngine::Thread_LoadGameList_Sort():Continue  
                                        Case DC::#Button_028:
                                        	If ( Startup::*LHGameDB\SortXtendMode = #True )
                                        		Startup::*LHGameDB\SortMode = 5
                                        	Else	
                                        		Startup::*LHGameDB\SortMode = 3
                                        	EndIf
                                        	VEngine::Thread_LoadGameList_Sort()
                                        	Continue                                                                                          
                                    EndSelect                                                                                                      
                            EndSelect                            
                            
                            ;
                            ;Edit Cancel
                            ; 
                        Case DC::#Button_020 To DC::#Button_022, DC::#Button_033
                            Select ButtonEX::ButtonExEvent(EvntGadget)  
                                Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(EvntGadget,0)
                                    Select EvntGadget
                                        Case DC::#Button_020
                                            vWindows::OpenWindow_Sys1()
                                            VEngine::ListBox_GetData_LeftMouse(#True)
                                            Continue
                                            
                                        Case DC::#Button_021                                            
                                            vWindows::OpenWindow_Sys1(1)        
                                            VEngine::ListBox_GetData_LeftMouse(#True)
                                            Continue
                                            
                                        Case DC::#Button_022
                                            vWindows::OpenWindow_Sys2()
                                            VEngine::ListBox_GetData_LeftMouse(#True) 
                                            Continue
                                            
                                        Case DC::#Button_033
                                            ;vWindows::OpenWindow_Sys64()
                                            ;VEngine::ListBox_GetData_LeftMouse(#True)                                              
                                    EndSelect        
                                    
                            EndSelect                             
                            ;
                            ;
                            ; Close , Menu1 und Menu 2 Button?? 
                        Case DC::#Button_001
                            Select ButtonEX::ButtonExEvent(EvntGadget)  
                                Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(EvntGadget,0) 
                                    Select EvntGadget
                                            ;
                                            ; Close Buttons
                                        Case DC::#Button_001                                            
                                            Startup::*LHGameDB\ProgrammQuit = INVMNU::Request_MSG_Quit()                                           
                                   EndSelect        
                            EndSelect
                            
                            ;
                            ; Minimzed Stuff
                        Case DC::#Button_002
                            Select ButtonEX::ButtonExEvent(EvntGadget)
                                 Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(EvntGadget,0) 
                            EndSelect
                            
                            Select EvntType
                                Case #PB_EventType_LeftClick
                                    SetWindowState(DC::#_Window_001, #PB_Window_Minimize)
                                    
                                    If IsWindow( DC::#_Window_006 )
                                        SetWindowState(DC::#_Window_006, #PB_Window_Minimize) 
                                    EndIf    
                                    
                                    Continue
                                    
                                Case #PB_EventType_RightClick
                                    ShowWindow_(WindowID(DC::#_Window_001),#SW_MINIMIZE)
                                    
                                    If IsWindow( DC::#_Window_006 )
                                        ShowWindow_(WindowID(DC::#_Window_006),#SW_MINIMIZE)
                                    EndIf
                                    
                                    DesktopEX::Icon_HideFromTaskBar(WindowID(DC::#_Window_001),1)
  
                                    Continue
                            EndSelect        
                            ;
                            ;
                            ;
                        Case Startup::*LHImages\ScreenGDID[1] To Startup::*LHImages\ScreenGDID[Startup::*LHGameDB\MaxScreenshots]
                            If ( Startup::*LHGameDB\SwitchNoItems = 1 )
                                Select EvntType
                                    Case #PB_EventType_LeftDoubleClick
                                        ;
                                        ; GadgetID Übergeben
                                        vWindows::OpenWindow_Sys3(EvntGadget) :VEngine::ListBox_GetData_LeftMouse(#True) 
                                        Continue
                                    Case #PB_EventType_RightClick
                                        ;
                                        ; Hole die Gadget Position
                                        ;
                                        ;
                                        CLSMNU::SetGetMenu_(EvntGadget,DC::#_Window_001, #PB_Any, 0, GadgetWidth(EvntGadget) - 60, 45, 1,4, #True)
                                        Continue                                                                                                        
                                EndSelect          
                            EndIf  
                    EndSelect  
                    
                   
                    ;***************************************************************************
                    ; Menu Events/ Handler
                Case #PB_Event_SysTray
                    Select EvntType
                        Case #PB_EventType_RightClick
                            CLSMNU::SetGetMenu_(0,DC::#_Window_001, -1, 0, 0, 0, 0, 3)                         
                            
                        Case #PB_EventType_LeftClick
                            Select IsIconic_(WindowID(DC::#_Window_001))
                                Case 1
                                    ShowWindow_(WindowID(DC::#_Window_001),#SW_RESTORE)
                                    
                                    If IsWindow( DC::#_Window_006 )
                                        ShowWindow_(WindowID(DC::#_Window_006),#SW_RESTORE)
                                        SetWindowPos_(WindowID(DC::#_Window_006),#HWND_TOP, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE)
                                        SetActiveWindow( DC::#_Window_001 ): SetActiveGadget( DC::#ListIcon_001  )
                                    EndIf                                      
                                    
                                    DesktopEX::Icon_HideFromTaskBar(WindowID(DC::#_Window_001),0):Continue                                   
                                Case 0  
                                    ShowWindow_(WindowID(DC::#_Window_001),#SW_MINIMIZE)
                                    
                                    If IsWindow( DC::#_Window_006 )
                                        ShowWindow_(WindowID(DC::#_Window_006),#SW_MINIMIZE)
                                    EndIf                                      
                                    
                                    DesktopEX::Icon_HideFromTaskBar(WindowID(DC::#_Window_001),1):Continue                           
                            EndSelect                               
                    EndSelect     
                Case #PB_Event_Menu
                    Select EvntMenu
                        Case 500 To 599
                            vInfoMenu::MainSelect(EvntMenu)
                            Continue
                        Default
                            CLSMNU::MenuItemSelect_(EvntMenu) 
                            Continue
                    EndSelect
                  
            EndSelect                

            
        Until ( Startup::*LHGameDB\ProgrammQuit = #True )       
        
        LCD::Free()
        HideGadget(DC::#Text_004,0)
        SetGadgetText(DC::#Text_004,"Beende... [" + Str(RowID) + "/" + Str(Rows))   
        
        VEngine::Thread_LoadGameList_Sort(#True) 
        
        SetGadgetText(DC::#Text_004,"Beende... [Speichere Einstellungen 0/4]")   
        
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "wScreenShotGadget", Str(Startup::*LHGameDB\wScreenShotGadget),1)
        SetGadgetText(DC::#Text_004,"Beende... [Speichere Einstellungen 1/4]")  
        
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "hScreenShotGadget", Str(Startup::*LHGameDB\hScreenShotGadget),1)
        SetGadgetText(DC::#Text_004,"Beende... [Speichere Einstellungen 2/4]")          
        
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WPosX", Str(WinGuru::WindowPosition(DC::#_Window_001,0,0,#False,#True,#False)),1)    
        SetGadgetText(DC::#Text_004,"Beende... [Speichere Einstellungen 3/4]")          
        
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WPosY", Str(WinGuru::WindowPosition(DC::#_Window_001,0,0,#False,#False,#True)),1)
        SetGadgetText(DC::#Text_004,"Beende... [Speichere Einstellungen 4/4]")          
        
     
        SetGadgetText(DC::#Text_004,"Beende... [Komprimiere Basis  Datenbank...]")                        
        ExecSQL::Shrink(DC::#Database_001,Startup::*LHGameDB\Base_Game): SetGadgetText(DC::#Text_004,"Beende... [Komprimiere Basis Datenbank... OK]") : Delay(60)                    
        
        If ( Startup::*LHGameDB\bisImageDBChanged = #True )
            SetGadgetText(DC::#Text_004,"Beende... [Komprimiere Bilder Datenbank...]")          
            ExecSQL::Shrink(DC::#Database_002,Startup::*LHGameDB\Base_Pict): SetGadgetText(DC::#Text_004,"Beende... [Komprimiere Bilder Datenbank...OK]")  :Delay(60)
        EndIf    
        
        Delay(255)
        FreeMenu(#PB_All)         
        
        ;
        ; Remove  a Systray Icon  
        SetGadgetText(DC::#Text_004,"Beende... ")            
        SSTTIP::Tooltip_TrayIcon(ProgramFilename(), DC::#TRAYICON001, DC::#_Window_001, Startup::*LHGameDB\TrayIconTitle, 1) 
        
        If IsWindow( DC::#_Window_006 )
            CloseWindow( DC::#_Window_006 )
        EndIf
        
        CloseWindow(DC::#_Window_001)
        ;
        ; WIRD Benötigt wegen der Autovervollständigen Routine
        CoUninitialize_()        
        Delay(255)        
        
        ProcessEX::LHFreeMem()
        Delay(255)        
        
        
    EndProcedure  
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 148
; FirstLine = 102
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\MAME\
; EnableUnicode