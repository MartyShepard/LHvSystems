

Module vWindows
	
	Procedure Close_ToolTips(WindowHandle.i)    
		
		SSTTIP::ToolTipMode(2,DC::#Button_203)
		SSTTIP::ToolTipMode(2,DC::#Button_204)
		SSTTIP::ToolTipMode(2,DC::#Button_205)
		SSTTIP::ToolTipMode(2,DC::#Button_206)
		SSTTIP::ToolTipMode(2,DC::#Button_207)
		SSTTIP::ToolTipMode(2,DC::#String_100)
		
		If ( WindowHandle = DC::#_Window_003 )
			SSTTIP::ToolTipMode(2,DC::#String_104)
			SSTTIP::ToolTipMode(2,DC::#String_101)
			SSTTIP::ToolTipMode(2,DC::#String_102) 
			SSTTIP::ToolTipMode(2,DC::#String_103) 
		EndIf  
		
		If ( WindowHandle = DC::#_Window_005 )
			SSTTIP::ToolTipMode(2,DC::#Button_263)
			SSTTIP::ToolTipMode(2,DC::#Button_264)
			SSTTIP::ToolTipMode(2,DC::#Button_265) 
			SSTTIP::ToolTipMode(2,DC::#Button_266) 
			SSTTIP::ToolTipMode(2,DC::#Button_270)
			SSTTIP::ToolTipMode(2,DC::#Button_271)
			SSTTIP::ToolTipMode(2,DC::#Button_272) 
			SSTTIP::ToolTipMode(2,DC::#Button_273)
			SSTTIP::ToolTipMode(2,DC::#Button_274)               
			SSTTIP::ToolTipMode(2,DC::#Button_275)               
			SSTTIP::ToolTipMode(2,DC::#Button_276)
			SSTTIP::ToolTipMode(2,DC::#Button_277)             
			SSTTIP::ToolTipMode(2,DC::#Button_279)  
			SSTTIP::ToolTipMode(2,DC::#Button_280)                           
		EndIf         
		
	EndProcedure    
	;
	;
	;  Drag and Drop Support
	;
	Procedure DragnDrop_Support(DropGadget.i)
		
		Select EventDropType()
			Case #PB_Drop_Files                
				Select DropGadget
						;
						; Medien, Wird aufgerufen von GuiInteract
					Case DC::#String_008 To DC::#String_011                        
						VEngine::GetFile_Media( DropGadget.i, EventDropFiles() )
						
						;
						; Programm, Wird aufgerufen von ..siehe weiter unten
					Case DC::#String_101, DC::#String_102
						VEngine::GetFile_Programm( DropGadget.i, EventDropFiles() )
						
						;
						; Nimmt doe Fatei als Titel
					Case DC::#String_001
						VEngine::Database_Set_Title( GetFilePart( EventDropFiles(),#PB_FileSystem_NoExtension ) )
						
						;
						; Screenshot Import
					Case Startup::*LHImages\ScreenGDID[1] To Startup::*LHImages\ScreenGDID[Startup::*LHGameDB\MaxScreenshots]
						If ( Startup::*LHGameDB\SwitchNoItems = 1 )
							vImages::Screens_Import( DropGadget, EventDropFiles() )
						EndIf                                                                                           
						;
						; Info Window String
					Case  DC::#String_112
						VEngine::GetFile_Media( DropGadget.i, EventDropFiles() )
						VEngine::Text_Show()
						vInfo::Caret_GetPosition_NonActiv()
						;
						;
					Case  DC::#Text_128  To DC::#Text_131
						VEngine::GetFile_Media( DC::#String_112, EventDropFiles() )
						VEngine::Text_Show()
						vInfo::Caret_GetPosition_NonActiv()
				EndSelect
				
			Case #PB_Drop_Text               
				Select DropGadget  
					Case DC::#String_001
						VEngine::Database_Set_Title(EventDropText())
				EndSelect
				
		EndSelect                                                        
	EndProcedure  
	;
	;
	;  Drag and Drop Support C64er Manager
	;  
	Procedure DragnDrop_Support_C64(DropGadget.i,GadgetID.i,DestGadgetID.i)    
		Select EventDropType()
			Case #PB_Drop_Files      
				
				Select DropGadget                       
					Case DC::#ListIcon_003                           
						vItemC64E::DragnDrop_Load(EventDropFiles(),DC::#String_102,DestGadgetID.i)                                                
				EndSelect
				
			Case #PB_Drop_Text   
				
		EndSelect
		
	EndProcedure   
	;
	;
	;  Drag and Drop Support - Datei Manager
	;     
	Procedure DragnDrop_Support_Arc(DropGadget.i,GadgetID.i,DestGadgetID.i)    
		Select EventDropType()
			Case #PB_Drop_Files      
				
				Select DropGadget                       
					Case DC::#ListIcon_004         
						SetGadgetText   ( DC::#Text_139,  "" )
						vArchiv::FileFormat_Drop( EventDropFiles() )
				EndSelect
				
			Case #PB_Drop_Text   
				
		EndSelect
		
	EndProcedure   
	;
	;
	; Offnet ein Fnster mit verschiedenen einträgen/ Sprache, Platform
	;       
	Procedure OpenWindow_Sys1(Set_Category.i = 0)                        
		
		Protected  CloseList.i = #False, ItemText$, PopMenuHwnd.l, PopGadgetID.i, hwnd.i       
		
		SetActiveGadget(-1):hwnd = MagicGUI::DefaultWindow(DC::#_Window_002): GuruCallBack::PostEvents_Resize(hwnd) 
		
		; Setze Callback für den String
		GuruCallBack::StringGadgetSetCallback(DC::#String_100, DC::#_Window_002)
		
		vItemTool::Show_Select_List(Set_Category.i, #True) 
		
		SetActiveGadget(DC::#ListIcon_002)
		
		HideWindow(hwnd,0)
		FORM::WindowFlickeringEvade(hwnd)  
		
		Repeat
			ListEvent       = WaitWindowEvent(): ListEventWindow = EventWindow()
			ListEventGadget = EventGadget()    : ListEventType   = EventType()
			ListEventMenu   = EventMenu()      : ListEventParam  = EventwParam()
			ListEventParami = EventlParam()    : ListEventData   = EventData()                        
			
			Select ListEvent                      
					
				Case #PB_Event_Gadget
					;***************************************************************************
					;                     
					;                     Select ListEventGadget
					;                         Case ListEventGadget                                                             
					;                     EndSelect  
					
					;***************************************************************************
					;
					Select ListEventGadget    
						Case DC::#Button_201
							; Close
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case BUTTONEX::#ButtonGadgetEx_Pressed:
									Close_ToolTips(hwnd) 
									vItemTool::Item_Cancel(DC::#ListIcon_002)
									CloseList = GuruCallBack::PostEvents_Close(hwnd) 
							EndSelect
							
						Case DC::#Button_202
							; Resize
							;____________________________________________________________________________________________________________________                            
							
						Case DC::#Button_203 To DC::#Button_207
							; Item Add, Item Copy, Item Remove, Ok and Close Window
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(ListEventGadget,0)  
									Select ListEventGadget
											; Add                                    
										Case DC::#Button_203
											vItemTool::Item_New()
											; Copy                                    
										Case DC::#Button_204
											vItemTool::Item_Duplicate()
											
											; Remove
										Case DC::#Button_205
											vItemTool::Item_Delete_List()
											
											; Rename 
										Case DC::#Button_206
											vItemTool::Item_Rename()
											
											; Close                              
										Case DC::#Button_207
											vItemTool::Item_Update_List()
											Close_ToolTips(hwnd) 
											CloseList = GuruCallBack::PostEvents_Close(hwnd):                                                                      
									EndSelect
							EndSelect    
					EndSelect
					Select ListEventType
						Case #PB_EventType_Change                        
						Case #PB_EventType_LeftDoubleClick
							
							Select ListEventGadget
								Case DC::#ListIcon_002; Wird dann in der DB gespeichert
											    ;                                     ItemText$ = GetGadgetItemText(DC::#ListIcon_004,GetGadgetState(DC::#ListIcon_004))
											    ;                                     CloseList = DBBASEF::Item_Select_List(1,ItemText$)
									vItemTool::Item_Update_List()
									Close_ToolTips(hwnd) 
									CloseList = GuruCallBack::PostEvents_Close(hwnd)                                   
							EndSelect
							
							
						Case #PB_EventType_LeftClick
							Select ListEventGadget 
								Case DC::#ListIcon_002; Wird dann in der DB gespeichert
									vItemTool::Item_Select_List()
									;                                     ItemText$ = GetGadgetItemText(DC::#ListIcon_004,GetGadgetState(DC::#ListIcon_004))
									;                                     CloseList = DBBASEF::Item_Select_List(0,ItemText$)                                                                                  
							EndSelect                         
					EndSelect
					;***************************************************************************
					;                                        
					
					;***************************************************************************
					; 
				Case #WM_KEYDOWN
				Case #WM_KEYUP
					
					Select ListEventParam
							;                           Case #VK_RETURN:  
							;                             Select  ListEventGadget 
							;                                 Case DC::#String_018; Wird dann in der DB gespeichert
							;                                     DBBASEF::Item_Update_List(0)
							;                             EndSelect
						Case #VK_DELETE:  
							If ( GetActiveGadget() = DC::#ListIcon_002 )
								vItemTool::Item_Delete_List()                          
							EndIf    
							;  
							; Benutzer Drückt Escape im Fenster
						Case #VK_ESCAPE:
							Close_ToolTips(hwnd) 
							vItemTool::Item_Cancel(DC::#ListIcon_002)
							CloseList = GuruCallBack::PostEvents_Close(hwnd)   
							
						Case #VK_UP, #VK_DOWN, 33, 34 ;"Bild Hoch", "Bild Runter"      
							If ( GetActiveGadget() = DC::#ListIcon_002 )
								vItemTool::Item_Select_List()
							EndIf    
					EndSelect 
				Case #PB_Event_MoveWindow 
					; Menu Events                 
			EndSelect
		Until CloseList.i = #True:        
		Delay(75)
		
	EndProcedure  
	;
	;
	;  Events die "Auschliesslich" Die Objecte der Strings behandeln    
	;
	Procedure.i OpenWindow_Sys2_StringCallBack(GadgetID.i, EvntwParam, EvntWait)
		Select EvntWait
			Case #WM_LBUTTONUP
			Case #WM_LBUTTONDOWN    
				;
				; Unterstützung für (Doppel) Mausklick in Strings um eine neues Fenster Öffnen
				; Kann nicht an das Haupt/StringCallback gebunden Werden. WaitWindowEvent() und WatiWindow() Kollidieren                     
			Case #WM_LBUTTONDBLCLK                
				Select GadgetID                        
					Case DC::#String_101, DC::#String_102
						If ( vItemTool::Item_Open_File_Check() = #True )
							vEngine::GetFile_Programm(GadgetID.i)  
						EndIf    
				EndSelect                                              
		EndSelect            
		ProcedureReturn EvntWait
	EndProcedure    
	;
	;
	;  Events die "Auschliesslich" Die Objecte der Strings behandeln    
	;
	Procedure.i OpenWindow_Sys64_StringCallBack(GadgetID.i, EvntwParam, EvntWait, DestGadgetID)
		Protected CRT.Point
		Select EvntWait
			Case #WM_LBUTTONUP
			Case #WM_LBUTTONDOWN    
				;
				; Unterstützung für (Doppel) Mausklick in Strings um eine neues Fenster Öffnen
				; Kann nicht an das Haupt/StringCallback gebunden Werden. WaitWindowEvent() und WatiWindow() Kollidieren                     
			Case #WM_LBUTTONDBLCLK                
				Select GadgetID                        
					Case DC::#String_101, DC::#String_102, DC::#String_103, DC::#String_111
						If ( vItemTool::Item_Open_File_Check() = #True )
							vEngine::GetFile_Programm_64(GadgetID.i)  
							;
							; Lade Image
							If ( DC::#String_102 = GadgetID )
								SetActiveGadget(DC::#ListIcon_003)
								vItemC64E::DSK_LoadImage(GadgetID, DestGadgetID)                                
								vItemC64E::Item_Auto_Select()                                 
							EndIf   
						EndIf    
				EndSelect                                              
		EndSelect            
		ProcedureReturn EvntWait
	EndProcedure  
	;
	;
	;  Events die "Auschliesslich" Die Objecte der Strings behandeln    
	;
	Procedure.i OpenWindow_Archiv_StringCallBack(GadgetID.i, EvntwParam, EvntWait, DestGadgetID)
		Protected CRT.Point
		Select EvntWait
			Case #WM_LBUTTONUP
			Case #WM_LBUTTONDOWN    
				;
				; Unterstützung für (Doppel) Mausklick in Strings um eine neues Fenster Öffnen
				; Kann nicht an das Haupt/StringCallback gebunden Werden. WaitWindowEvent() und WatiWindow() Kollidieren                     
			Case #WM_LBUTTONDBLCLK                
				Select GadgetID                        
					Case DC::#String_101, DC::#String_102, DC::#String_103, DC::#String_111
						;If ( vItemTool::Item_Open_File_Check() = #True )
						;    vEngine::GetFile_Programm_64(GadgetID.i)  
						;
						; Lade Image
						;    If ( DC::#String_102 = GadgetID )
						;        SetActiveGadget(DC::#ListIcon_003)
						;        vItemC64E::DSK_LoadImage(GadgetID, DestGadgetID)                                
						;        vItemC64E::Item_Auto_Select()                                 
						;    EndIf   
						;EndIf    
				EndSelect                                              
		EndSelect            
		ProcedureReturn EvntWait
	EndProcedure   
	;
	;
	;  Events die "Auschliesslich" Die Objecte der Strings behandeln    
	;    
	Procedure.i OpenWindow_EditInfo_StringCallBack(GadgetID.i, EvntwParam, EvntWait, DestGadgetID)
		Select EvntWait
			Case #WM_LBUTTONUP
			Case #WM_LBUTTONDOWN    
				;
				; Unterstützung für (Doppel) Mausklick in Strings um eine neues Fenster Öffnen
				; Kann nicht an das Haupt/StringCallback gebunden Werden. WaitWindowEvent() und WatiWindow() Kollidieren                     
			Case #WM_LBUTTONDBLCLK                                                             
		EndSelect            
		ProcedureReturn EvntWait
	EndProcedure       
	;
	;
	; Offnet ein Fnster mit verschiedenen einträgen/ Programme
	;     
	Procedure OpenWindow_Sys2()                        
		
		Protected  CloseList.i = #False, ItemText$, PopMenuHwnd.l, PopGadgetID.i, hwnd.i       
		
		SetActiveGadget(-1):hwnd = MagicGUI::DefaultWindow(DC::#_Window_003): GuruCallBack::PostEvents_Resize(hwnd)                 
		
		;
		;Setze den Callback für die Strings        
		GuruCallBack::StringGadgetSetCallback(DC::#String_100, DC::#_Window_003)
		GuruCallBack::StringGadgetSetCallback(DC::#String_101, DC::#_Window_003) 
		GuruCallBack::StringGadgetSetCallback(DC::#String_102, DC::#_Window_003)
		GuruCallBack::StringGadgetSetCallback(DC::#String_103, DC::#_Window_003)         
		GuruCallBack::StringGadgetSetCallback(DC::#String_104, DC::#_Window_003) 
		
		
		; Drag'n Drop für Programme
		;
		EnableGadgetDrop(DC::#String_101, #PB_Drop_Files , #PB_Drag_Copy) ; Voller Pfad
		EnableGadgetDrop(DC::#String_102, #PB_Drop_Files , #PB_Drag_Copy)	; Nur der Arbetspfad        
		
		;
		; FileSystem im String
		FFH::SHAutoComplete(DC::#String_101, #True)
		
		vItemTool::Show_Select_List(2,#True) 
		
		SetActiveGadget(DC::#ListIcon_002)
		
		HideWindow(hwnd,0)
		FORM::WindowFlickeringEvade(hwnd)        
		Repeat
			ListEvent       = WaitWindowEvent(): ListEventWindow = EventWindow()
			ListEventGadget = EventGadget()    : ListEventType   = EventType()
			ListEventMenu   = EventMenu()      : ListEventParam  = EventwParam()
			ListEventParami = EventlParam()    : ListEventData   = EventData()                        
			
			;
			;
			ListEvent = OpenWindow_Sys2_StringCallBack(ListEventGadget, ListEventParami, ListEvent)            
			
			
			Select ListEvent                      
					
				Case #PB_Event_GadgetDrop                               
					DragnDrop_Support(ListEventGadget.i)     
					
				Case #PB_Event_Gadget
					
					Select ListEventGadget 
							
						Case DC::#Button_201
							; Close
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case BUTTONEX::#ButtonGadgetEx_Pressed:
									Close_ToolTips(hwnd)
									vItemTool::Item_Cancel(DC::#ListIcon_002)
									CloseList = GuruCallBack::PostEvents_Close(hwnd)
							EndSelect
							
							
						Case DC::#Button_202
							; Resize
							;____________________________________________________________________________________________________________________                            
							
						Case DC::#Button_203 To DC::#Button_207, DC::#Button_278
							; Item Add, Item Copy, Item Remove, Ok and Close Window
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(ListEventGadget,0)                            
									Select ListEventGadget
											; Add                                    
										Case DC::#Button_203
											vItemTool::Item_New()
											; Copy                                    
										Case DC::#Button_204
											vItemTool::Item_Duplicate()
											; Remove
										Case DC::#Button_205
											vItemTool::Item_Delete_List()
											
											; Rename 
										Case DC::#Button_206
											;vItemTool::Item_Rename()
											vItemTool::Item_Programm_Update()
											
											; Close                              
										Case DC::#Button_207
											vItemTool::Item_Update_List()
											Close_ToolTips(hwnd) 
											CloseList = GuruCallBack::PostEvents_Close(hwnd):  
											
										Case DC::#Button_278
											CLSMNU::SetGetMenu_(ListEventGadget,DC::#_Window_003, #PB_Any, 0, GadgetWidth(ListEventGadget) - 30, 32, 4,4, #True)                                             
									EndSelect
							EndSelect                     
							
					EndSelect                                     
					;***************************************************************************
					;                     
					;                     Select ListEventGadget
					;                         Case ListEventGadget                                                             
					;                     EndSelect  
					
					;***************************************************************************
					;
					Select ListEventType
						Case #PB_EventType_Change                        
						Case #PB_EventType_LeftDoubleClick
							
							Select ListEventGadget
								Case DC::#ListIcon_002; Wird dann in der DB gespeichert
											    ;                                     ItemText$ = GetGadgetItemText(DC::#ListIcon_004,GetGadgetState(DC::#ListIcon_004))
											    ;                                     CloseList = DBBASEF::Item_Select_List(1,ItemText$)
									vItemTool::Item_Update_List()
									Close_ToolTips(hwnd) 
									CloseList = GuruCallBack::PostEvents_Close(hwnd)                                 
							EndSelect
							
							
						Case #PB_EventType_LeftClick
							Select ListEventGadget 
								Case DC::#ListIcon_002; Wird dann in der DB gespeichert
									If ( GetActiveGadget() = DC::#ListIcon_002 )
										vItemTool::Item_Select_List()
									EndIf    
									;                                     ItemText$ = GetGadgetItemText(DC::#ListIcon_004,GetGadgetState(DC::#ListIcon_004))
									;                                     CloseList = DBBASEF::Item_Select_List(0,ItemText$)                                                                                  
							EndSelect                         
					EndSelect
					;***************************************************************************
					;                                        
					
					;***************************************************************************
					; 
				Case #WM_KEYDOWN
				Case #WM_KEYUP
					
					Select ListEventParam
							;                           Case #VK_RETURN:  
							;                             Select  ListEventGadget 
							;                                 Case DC::#String_018; Wird dann in der DB gespeichert
							;                                     DBBASEF::Item_Update_List(0)
							;                             EndSelect
						Case #VK_DELETE: 
							If ( GetActiveGadget() = DC::#ListIcon_002 )
								vItemTool::Item_Delete_List()                          
							EndIf    
							;  
							; Benutzer Drückt Escape im Fenster
						Case #VK_ESCAPE:
							Close_ToolTips(hwnd)
							vItemTool::Item_Cancel(DC::#ListIcon_002)
							CloseList = GuruCallBack::PostEvents_Close(hwnd)   
							
						Case #VK_UP, #VK_DOWN, 33, 34 ;"Bild Hoch", "Bild Runter"      
							If ( GetActiveGadget() = DC::#ListIcon_002 )
								vItemTool::Item_Select_List()
							EndIf                              
					EndSelect        
				Case #PB_Event_MoveWindow 
					; Menu Events  
				Case #PB_Event_Menu
					CLSMNU::MenuItemSelect_(ListEventMenu)                     
			EndSelect
			;
			;
			
		Until CloseList.i = #True:
		
		
		
	EndProcedure       
	;
	;
	; Offnet ein Fenster für die Screenshots
	;       
	Procedure OpenWindow_Sys3(ImageGadgetID)                        
		
		Protected  CloseList.i = #False, hwnd.i       
		
		SetActiveGadget(-1):hwnd = MagicGUI::DefaultWindow(DC::#_Window_004): GuruCallBack::PostEvents_Resize(hwnd)  
		vImages::Screens_ShowWindow(ImageGadgetID, DC::#_Window_004)
		GuruCallBack::ScrollAreaGadgetSetCallback(DC::#Contain_11, DC::#_Window_004)
		
		;
		; FileSystem im String      
		HideWindow(hwnd,0)           
		FORM::WindowFlickeringEvade(hwnd)
		
		
		
		Repeat
			ListEvent       = WaitWindowEvent(): ListEventWindow = EventWindow()
			ListEventGadget = EventGadget()    : ListEventType   = EventType()
			ListEventMenu   = EventMenu()      : ListEventParam  = EventwParam()
			ListEventParami = EventlParam()    : ListEventData   = EventData()                        
			
			Select ListEvent                      
				Case #WM_MOUSEWHEEL
					Debug "#WM_MOUSEWHEEL"
				Case #PB_Event_GadgetDrop                                                   
				Case #PB_Event_Gadget
					
					Select ListEventGadget 
							
						Case DC::#Button_201
							; Close
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case BUTTONEX::#ButtonGadgetEx_Pressed:
									CloseList = GuruCallBack::PostEvents_Close(hwnd)
							EndSelect
							
						Case DC::#Button_202
							; Resize
							;____________________________________________________________________________________________________________________  
							
						Case DC::#Contain_11
					EndSelect
					
			EndSelect
			;
			;
			
		Until CloseList.i = #True:
	EndProcedure              
	;
	;
	; Untersützung für C64er Images mit Hilfe der Tools
	;      
	Procedure OpenWindow_Sys64(GadgetID.i,DestGadgetID.i)                        
		
		If (Len(GetGadgetText(GadgetID.i)) = 0)
		EndIf
		
		Protected  CloseList.i = #False, ItemText$, PopMenuHwnd.l, PopGadgetID.i, hwnd.i       
		
		SetActiveGadget(-1):hwnd = MagicGUI::DefaultWindow(DC::#_Window_005): GuruCallBack::PostEvents_Resize(hwnd) 
		WindowBounds(hwnd, 
		             WindowWidth(hwnd,  #PB_Window_FrameCoordinate), 
		             WindowHeight(hwnd, #PB_Window_FrameCoordinate),
		             WindowWidth(hwnd,  #PB_Window_FrameCoordinate), #PB_Ignore) 
		
		;
		;Setze den Callback für die Strings        
		GuruCallBack::StringGadgetSetCallback(DC::#String_100, DC::#_Window_005)
		GuruCallBack::StringGadgetSetCallback(DC::#String_101, DC::#_Window_005) 
		GuruCallBack::StringGadgetSetCallback(DC::#String_102, DC::#_Window_005)
		GuruCallBack::StringGadgetSetCallback(DC::#String_103, DC::#_Window_005)         
		GuruCallBack::StringGadgetSetCallback(DC::#String_104, DC::#_Window_005) 
		GuruCallBack::StringGadgetSetCallback(DC::#String_111, DC::#_Window_005)       
		
		; Drag'n Drop für Programme
		;
		;EnableGadgetDrop(DC::#ListIcon_003, #PB_Drop_Files , #PB_Drag_Copy) ; Voller Pfad
		EnableGadgetDrop(DC::#String_102, #PB_Drop_Files , #PB_Drag_Copy) ; Nur der Arbetspfad        
		EnableGadgetDrop(DC::#ListIcon_003,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Copy|#PB_Drag_Link)
		;
		; FileSystem im String
		; FFH::SHAutoComplete(DC::#String_101, #True)
		
		SetActiveGadget(DC::#ListIcon_003)         
		vItemC64E::Item_GetPrograms()               
		vItemC64E::Item_Side_SetAktiv(-1)
		
		If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )             
			vItemC64E::Item_Auto_Select() 
		EndIf        
		
		HideWindow(hwnd,0)
		FORM::WindowFlickeringEvade(hwnd)        
		Repeat
			ListEvent       = WaitWindowEvent(): ListEventWindow = EventWindow()
			ListEventGadget = EventGadget()    : ListEventType   = EventType()
			ListEventMenu   = EventMenu()      : ListEventParam  = EventwParam()
			ListEventParami = EventlParam()    : ListEventData   = EventData()                        
			
			;
			;
			ListEvent = OpenWindow_Sys64_StringCallBack(ListEventGadget, ListEventParami, ListEvent, DestGadgetID)            
			
			
			Select ListEvent                      
					
				Case #PB_Event_GadgetDrop                               
					DragnDrop_Support_C64(ListEventGadget.i,GadgetID.i,DestGadgetID.i)     
					
				Case #PB_Event_Gadget
					
					Select ListEventGadget 
							
						Case DC::#Button_201
							; Close
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case BUTTONEX::#ButtonGadgetEx_Pressed:
									Close_ToolTips(hwnd)
									vItemC64E::DSK_LoadOldFilename()
									CloseList = GuruCallBack::PostEvents_Close(hwnd)
							EndSelect
							
						Case DC::#Button_202
							; Resize
							;____________________________________________________________________________________________________________________                            
							
						Case DC::#Button_203 To DC::#Button_207, DC::#Button_262 To DC::#Button_281
							; Close Window
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(ListEventGadget,0)                            
									Select ListEventGadget
											
											;
											; Get Image Directory
										Case DC::#Button_203
											If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
												vItemC64E::Item_Side_SetAktiv(-1)
												vItemC64E::Item_Auto_Select() 
											EndIf 
											
											;
											; Copy From Image to Real drive
										Case DC::#Button_204
											vItemC64E::Item_Side_SetAktiv(1)  
											vItemC64E::DSK_OpenCBM_Init() 
											vItemC64E::DSK_OpenCBM_Tools("im2real")  
											
											;
											; Rename on Real Drive or in the Image
										Case DC::#Button_205 
											vItemC64E::DSK_OpenCBM_Tools("rename")                                            
											
											;
											; Copy From Real Drive to Image
										Case DC::#Button_206
											If ( vItemC64E::DSK_OpenCBM_Tools("cpytoim") = #True )                                                
												If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
													vItemC64E::Item_Side_SetAktiv(-1)
													vItemC64E::Item_Auto_Select() 
												EndIf 
											EndIf                                              
											
										Case DC::#Button_262
											
											;
											; Transfer a D64 Image to Real Drive                                              
										Case DC::#Button_263                                                                                        
											If ( vItemC64E::DSK_Image_TransferTo1541() = #True )
												vItemC64E::DSK_OpenCBM_Directory()  
											EndIf                                      
											
											;
											; Delete on Image or in Real Drive                                         
										Case DC::#Button_264
											vItemC64E::DSK_OpenCBM_Tools("scratch")                                           
											
											;
											; Creat a Backup from Real Drive as DiskImage.D64    
											
										Case DC::#Button_265    
											vItemC64E::Item_Side_SetAktiv(1)                                            
											vItemC64E::DSK_OpenCBM_Init()                                                                                          
											If ( vItemC64E::DSK_Image_TransferToPCHD() = #True )
												
												If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
													vItemC64E::Item_Side_SetAktiv(-1)
													vItemC64E::Item_Auto_Select() 
												EndIf 
											EndIf                                               
											
											;
											; Initialisere Real Drive und hole den Status
										Case DC::#Button_266 
											vItemC64E::Item_Side_SetAktiv(1)
											vItemC64E::DSK_OpenCBM_Init()  
											
										Case DC::#Button_267                                                                                         
										Case DC::#Button_268   
											If ( vItemC64E::Image_Create() = #True )
												If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
													vItemC64E::Item_Side_SetAktiv(-1)
													vItemC64E::Item_Auto_Select() 
												EndIf 
											EndIf     
											
											
										Case DC::#Button_269                                                                                       
											
											;
											; Format Real Drive or make a New Image                                            
										Case DC::#Button_270    
											vItemC64E::Item_Side_SetAktiv(1)                                            
											vItemC64E::DSK_OpenCBM_Init() 
											vItemC64E::DSK_OpenCBM_Format()   
											
											;
											; Validate Real Drive
										Case DC::#Button_271
											vItemC64E::Item_Side_SetAktiv(1) 
											vItemC64E::DSK_OpenCBM_Init() 
											vItemC64E::DSK_OpenCBM_Val()                                              
											
										Case DC::#Button_272     
											vItemC64E::Item_Side_SetAktiv(-1) 
											vItemC64E::Image_CopyFile_FromHDToImage()
											If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
												vItemC64E::Item_Side_SetAktiv(-1)
												vItemC64E::Item_Auto_Select() 
											EndIf                                           
											
											
										Case DC::#Button_273  
											vItemC64E::Item_Side_SetAktiv(-1) 
											vItemC64E::Image_CopyFile_FromImageToHD()
											;
											; Close Window
										Case DC::#Button_274
											Close_ToolTips(hwnd) 
											CloseList = GuruCallBack::PostEvents_Close(hwnd):    
											
											;
											; Backup Files From Real Drive to HD
										Case DC::#Button_275
											vItemC64E::Item_Side_SetAktiv(1) 
											vItemC64E::DSK_OpenCBM_Tools("cpytopc")
											
											;
											; Backup Files From HD to Real Drive                                         
										Case DC::#Button_276
											vItemC64E::Item_Side_SetAktiv(1)                                            
											vItemC64E::DSK_OpenCBM_Copy_LocalFile_To_1541()  
											
											
										Case DC::#Button_279                                            
											vItemC64E::Item_ChangeFont()
											
											;                                            
											; Image Aktiv
										Case DC::#Button_277
											vItemC64E::Item_Side_SetAktiv(-1) 
											vItemC64E::DSK_Image_Refresh() 
											vItemC64E::Item_Auto_Select() 
											;                                            
											; 1541  Aktiv                                            
										Case DC::#Button_280
											vItemC64E::Item_Side_SetAktiv(1) 
											vItemC64E::DSK_OpenCBM_Refresh()
											vItemC64E::Item_Auto_Select() 
											
											
										Case DC::#Button_278
											CLSMNU::SetGetMenu_(ListEventGadget,DC::#_Window_005, #PB_Any, 0, GadgetWidth(ListEventGadget) - 30, 32, 3,4, #True) 
											
											; Close                              
										Case DC::#Button_207   
											vItemC64E::Item_Side_SetAktiv(1)
											vItemC64E::DSK_OpenCBM_Directory()                                                                                                                                                                                                                     
									EndSelect
							EndSelect                     
							
					EndSelect                                     
					;***************************************************************************
					;                     
					;                     Select ListEventGadget
					;                         Case ListEventGadget                                                             
					;                     EndSelect  
					
					;***************************************************************************
					;
					Select ListEventType
						Case #PB_EventType_Change                        
						Case #PB_EventType_LeftDoubleClick
							
							Select ListEventGadget
								Case DC::#ListIcon_003  
									VEngine::DOS_Prepare()
									; If (vItemC64E::vItemC64E_CanClose = #True)
									;     Close_ToolTips(hwnd)                                        
									;     CloseList = GuruCallBack::PostEvents_Close(hwnd)                                 
									; EndIf
							EndSelect
							
							
						Case #PB_EventType_LeftClick
							Select ListEventGadget 
								Case DC::#ListIcon_003
									If ( GetActiveGadget() = DC::#ListIcon_003 )
										vItemC64E::Item_Select_List()
									EndIf    
							EndSelect
							
						Case #PB_EventType_RightClick
							Select ListEventGadget
								Case DC::#Button_278 
								Case DC::#Button_265
									vItemC64E::Item_Side_SetAktiv(1)                                            
									vItemC64E::DSK_OpenCBM_Init()                                                                                          
									If ( vItemC64E::DSK_Image_TransferToPCHD(#True) = #True )
										
										If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
											vItemC64E::Item_Side_SetAktiv(-1)
											vItemC64E::Item_Auto_Select() 
										EndIf 
									EndIf                                      
							EndSelect                                     
					EndSelect
					;***************************************************************************
					;                                        
					
					;***************************************************************************
					; 
				Case #WM_KEYDOWN
				Case #WM_KEYUP
					
					Select ListEventParam
							;                           Case #VK_RETURN:  
							;                             Select  ListEventGadget 
							;                                 Case DC::#String_018; Wird dann in der DB gespeichert
							;                                     DBBASEF::Item_Update_List(0)
							;                             EndSelect
						Case #VK_DELETE: 
							If ( GetActiveGadget() = DC::#ListIcon_003 )
								; vItemTool::Item_Delete_List()                          
							EndIf    
							;  
							; Benutzer Drückt Escape im Fenster
						Case #VK_ESCAPE:
							Close_ToolTips(hwnd)                            
							vItemC64E::DSK_LoadOldFilename()
							;vItemTool::Item_Cancel(DC::#ListIcon_003)
							CloseList = GuruCallBack::PostEvents_Close(hwnd)   
							
						Case #VK_UP, #VK_DOWN, 33, 34 ;"Bild Hoch", "Bild Runter"      
							If ( GetActiveGadget() = DC::#ListIcon_003 )
								vItemC64E::Item_Select_List()
							EndIf                              
					EndSelect        
				Case #PB_Event_MoveWindow 
					; Menu Events 
				Case #PB_Event_Menu
					CLSMNU::MenuItemSelect_(ListEventMenu)                      
			EndSelect
			;
			;
			
		Until CloseList.i = #True:
		
		
		
	EndProcedure      
	;
	;
	; Editor Fenster
	;        
	Procedure OpenWindow_EditInfos()                        
		
		Protected  CloseList.i = #False, ItemText$, PopMenuHwnd.l, PopGadgetID.i, hwnd.i, Dsk.Rect                      
		
		; Hole die Window Eigenschaften vor dem Öffne ndes Fensters
		;        
		SetActiveGadget(-1): hwnd = MagicGUI::DefaultWindow(DC::#_Window_006): GuruCallBack::PostEvents_Resize(hwnd)
		
		DesktopEX::Icon_HideFromTaskBar(WindowID( hwnd ),1):                   
		
		vInfo::Window_Reload()
		
		GuruCallBack::Window_Get_ClientSize(  WindowID( hwnd ) , WindowWidth(hwnd), WindowHeight( hwnd) )        
		WindowBounds( hwnd, 412, 30, #PB_Ignore, #PB_Ignore)
		
		GuruCallBack::EditGadgetSetCallback(DC::#Text_128, DC::#_Window_006) 
		GuruCallBack::EditGadgetSetCallback(DC::#Text_129, DC::#_Window_006) 
		GuruCallBack::EditGadgetSetCallback(DC::#Text_130, DC::#_Window_006) 
		GuruCallBack::EditGadgetSetCallback(DC::#Text_131, DC::#_Window_006)         
		;
		;Setze den Callback für die Strings        
		GuruCallBack::StringGadgetSetCallback(DC::#String_112, DC::#_Window_006)
		
		
		; Drag'n Drop für Programme
		;
		EnableGadgetDrop(DC::#String_112, #PB_Drop_Files , #PB_Drag_Copy) ; Voller Pfad     
		EnableGadgetDrop(DC::#Text_128,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Link)
		EnableGadgetDrop(DC::#Text_129,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Link)
		EnableGadgetDrop(DC::#Text_130,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Link)
		EnableGadgetDrop(DC::#Text_131,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Link)        
		
		;
		; FileSystem im String
		FFH::SHAutoComplete(DC::#String_112, #True)
		
		vInfo::Tab_Switch( Startup::*LHGameDB\InfoWindow\TabButton ,#True )
		
		vFont::GetDB(3, DC::#Text_128)
		vFont::GetDB(4, DC::#Text_129)        
		vFont::GetDB(5, DC::#Text_130)        
		vFont::GetDB(6, DC::#Text_131)
		
		vInfo::Tab_GetNames()
		vInfo::WordWrap_Get() 
		
		vEngine::Text_GetDB()
		
		HideWindow(hwnd,0)
		FORM::WindowFlickeringEvade(hwnd)    
		
		SetActiveWindow( DC::#_Window_001 ): SetActiveGadget( DC::#ListIcon_001 ): vInfo::Modify_Reset()  
	EndProcedure           
	;
	;
	; Untersützung für Archive
	;        
	Procedure OpenWindow_Archiv(GadgetID.i,DestGadgetID.i)                        
		
		Startup::*LHGameDB\ArchivTyp = ""
		;
		; GadgetID = Datei die von vSystem Übergeben wird
		; DestGadgetID = Datei die von vSystem Übergeben wird (Kleiner String)
		
		If (Len(GetGadgetText(GadgetID.i)) > 0)
			Debug "Datei vom Gadget " + GetGadgetText(DestGadgetID.i)
		EndIf
		
		
		
		Protected  CloseList.i = #False, ItemText$, PopMenuHwnd.l, PopGadgetID.i, hwnd.i       
		
		SetActiveGadget(-1):hwnd = MagicGUI::DefaultWindow(DC::#_Window_007): GuruCallBack::PostEvents_Resize(hwnd) 
		WindowBounds(hwnd, 
		             WindowWidth(hwnd,  #PB_Window_FrameCoordinate), 
		             WindowHeight(hwnd, #PB_Window_FrameCoordinate),
		             WindowWidth(hwnd,  #PB_Window_FrameCoordinate), #PB_Ignore) 
		
		;
		; Kopf und Titleleiste (Länge)
		vArchiv::List_Header_Generate()
		
		ClearGadgetItems( DC::#ListIcon_004 )
		SetGadgetText   ( DC::#Text_139,  Startup::*LHGameDB\ArchivTyp )
		
		;
		;Setze den Callback für die Strings        
		GuruCallBack::StringGadgetSetCallback(DC::#String_100, DC::#_Window_007)
		GuruCallBack::StringGadgetSetCallback(DC::#String_101, DC::#_Window_007) 
		GuruCallBack::StringGadgetSetCallback(DC::#String_102, DC::#_Window_007)
		GuruCallBack::StringGadgetSetCallback(DC::#String_103, DC::#_Window_007)         
		GuruCallBack::StringGadgetSetCallback(DC::#String_104, DC::#_Window_007) 
		GuruCallBack::StringGadgetSetCallback(DC::#String_111, DC::#_Window_007)       
		
		; Drag'n Drop für Programme
		;
		;EnableGadgetDrop(DC::#ListIcon_004, #PB_Drop_Files , #PB_Drag_Copy) ; Voller Pfad
		EnableGadgetDrop(DC::#String_102, #PB_Drop_Files , #PB_Drag_Copy) ; Nur der Arbetspfad        
		EnableGadgetDrop(DC::#ListIcon_004,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Copy|#PB_Drag_Link)
		;
		; FileSystem im String
		; FFH::SHAutoComplete(DC::#String_101, #True)
		
		SetActiveGadget(DC::#ListIcon_004)
		
		;vItemC64E::Item_GetPrograms()               
		;vItemC64E::Item_Side_SetAktiv(-1)
		
		;
		; TODO Archiv Überprüfung
		vArchiv::FileFormat_Init( GetGadgetText(GadgetID.i) )
	
		
		;If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )             
		;     vItemC64E::Item_Auto_Select() 
		;EndIf        
		
		HideWindow(hwnd,0)
		FORM::WindowFlickeringEvade(hwnd)        
		Repeat
			ListEvent       = WaitWindowEvent(): ListEventWindow = EventWindow()
			ListEventGadget = EventGadget()    : ListEventType   = EventType()
			ListEventMenu   = EventMenu()      : ListEventParam  = EventwParam()
			ListEventParami = EventlParam()    : ListEventData   = EventData()                        
			
			;
			;
			ListEvent = OpenWindow_Archiv_StringCallBack(ListEventGadget, ListEventParami, ListEvent, DestGadgetID)            
			
			
			Select ListEvent                      
					
				Case #PB_Event_GadgetDrop                               
					DragnDrop_Support_Arc(ListEventGadget.i,GadgetID.i,DestGadgetID.i)     
					
				Case #PB_Event_Gadget
					
					Select ListEventGadget 
							
						Case DC::#Button_201
							; Close
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case BUTTONEX::#ButtonGadgetEx_Pressed:
									Close_ToolTips(hwnd)
									;vItemC64E::DSK_LoadOldFilename()
									CloseList = GuruCallBack::PostEvents_Close(hwnd)
							EndSelect
							
						Case DC::#Button_202
							; Resize
							;____________________________________________________________________________________________________________________                            
							
						Case DC::#Button_203 To DC::#Button_207, DC::#Button_262 To DC::#Button_281
							; Close Window
							;____________________________________________________________________________________________________________________                            
							Select ButtonEX::ButtonExEvent(ListEventGadget)  
								Case ButtonEX::#ButtonGadgetEx_Pressed: ButtonEX::SetState(ListEventGadget,0)                            
									Select ListEventGadget
											
											;
											; Get Image Directory
										Case DC::#Button_203
											;If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
											;     vItemC64E::Item_Side_SetAktiv(-1)
											;     vItemC64E::Item_Auto_Select() 
											;EndIf 
											
											;
											; Copy From Image to Real drive
										Case DC::#Button_204
											;vItemC64E::Item_Side_SetAktiv(1)  
											;vItemC64E::DSK_OpenCBM_Init() 
											;vItemC64E::DSK_OpenCBM_Tools("im2real")  
											
											;
											; Rename on Real Drive or in the Image
										Case DC::#Button_205 
											;vItemC64E::DSK_OpenCBM_Tools("rename")                                            
											
											;
											; Copy From Real Drive to Image
										Case DC::#Button_206
											;If ( vItemC64E::DSK_OpenCBM_Tools("cpytoim") = #True )                                                
											;    If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
											;         vItemC64E::Item_Side_SetAktiv(-1)
											;         vItemC64E::Item_Auto_Select() 
											;    EndIf 
											;EndIf                                              
											
										Case DC::#Button_262
											
											;
											; Transfer a D64 Image to Real Drive                                              
										Case DC::#Button_263                                                                                        
											;If ( vItemC64E::DSK_Image_TransferTo1541() = #True )
											;     vItemC64E::DSK_OpenCBM_Directory()  
											; EndIf                                      
											
											;
											; Delete on Image or in Real Drive                                         
										Case DC::#Button_264
											;vItemC64E::DSK_OpenCBM_Tools("scratch")                                           
											
											;
											; Creat a Backup from Real Drive as DiskImage.D64    
											
										Case DC::#Button_265    
											;vItemC64E::Item_Side_SetAktiv(1)                                            
											;vItemC64E::DSK_OpenCBM_Init()                                                                                          
											;If ( vItemC64E::DSK_Image_TransferToPCHD() = #True )
											;    
											;    If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
											;         vItemC64E::Item_Side_SetAktiv(-1)
											;         vItemC64E::Item_Auto_Select() 
											;    EndIf 
											;EndIf                                               
											
											;
											; Initialisere Real Drive und hole den Status
										Case DC::#Button_266 
											;vItemC64E::Item_Side_SetAktiv(1)
											;vItemC64E::DSK_OpenCBM_Init()  
											
										Case DC::#Button_267                                                                                         
										Case DC::#Button_268   
											;If ( vItemC64E::Image_Create() = #True )
											;    If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
											;         vItemC64E::Item_Side_SetAktiv(-1)
											;         vItemC64E::Item_Auto_Select() 
											;     EndIf 
											;EndIf     
											
											
										Case DC::#Button_269                                                                                       
											
											;
											; Format Real Drive or make a New Image                                            
										Case DC::#Button_270    
											;vItemC64E::Item_Side_SetAktiv(1)                                            
											;vItemC64E::DSK_OpenCBM_Init() 
											;vItemC64E::DSK_OpenCBM_Format()   
											
											;
											; Validate Real Drive
										Case DC::#Button_271
											;vItemC64E::Item_Side_SetAktiv(1) 
											;vItemC64E::DSK_OpenCBM_Init() 
											;vItemC64E::DSK_OpenCBM_Val()                                              
											
										Case DC::#Button_272     
											;vItemC64E::Item_Side_SetAktiv(-1) 
											;vItemC64E::Image_CopyFile_FromHDToImage()
											;If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
											;     vItemC64E::Item_Side_SetAktiv(-1)
											;     vItemC64E::Item_Auto_Select() 
											;EndIf                                           
											
											
										Case DC::#Button_273  
											;vItemC64E::Item_Side_SetAktiv(-1) 
											;vItemC64E::Image_CopyFile_FromImageToHD()
											;
											; Close Window
										Case DC::#Button_274
											Close_ToolTips(hwnd) 
											CloseList = GuruCallBack::PostEvents_Close(hwnd):    
											
											;
											; Backup Files From Real Drive to HD
										Case DC::#Button_275
											;vItemC64E::Item_Side_SetAktiv(1) 
											;vItemC64E::DSK_OpenCBM_Tools("cpytopc")
											
											;
											; Backup Files From HD to Real Drive                                         
										Case DC::#Button_276
											;vItemC64E::Item_Side_SetAktiv(1)                                            
											;vItemC64E::DSK_OpenCBM_Copy_LocalFile_To_1541()  
											
											
										Case DC::#Button_279                                            
											;vItemC64E::Item_ChangeFont()
											
											;                                            
											; Image Aktiv
										Case DC::#Button_277
											;vItemC64E::Item_Side_SetAktiv(-1) 
											;vItemC64E::DSK_Image_Refresh() 
											;vItemC64E::Item_Auto_Select() 
											;                                            
											; 1541  Aktiv                                            
										Case DC::#Button_280
											;vItemC64E::Item_Side_SetAktiv(1) 
											;vItemC64E::DSK_OpenCBM_Refresh()
											;vItemC64E::Item_Auto_Select() 
											
											
										Case DC::#Button_278
											CLSMNU::SetGetMenu_(ListEventGadget,DC::#_Window_005, #PB_Any, 0, GadgetWidth(ListEventGadget) - 30, 32, 3,4, #True) 
											
											; Close                              
										Case DC::#Button_207   
											;vItemC64E::Item_Side_SetAktiv(1)
											;vItemC64E::DSK_OpenCBM_Directory()                                                                                                                                                                                                                     
									EndSelect
							EndSelect                     
							
					EndSelect                                     
					;***************************************************************************
					;                     
					;                     Select ListEventGadget
					;                         Case ListEventGadget                                                             
					;                     EndSelect  
					
					;***************************************************************************
					;
					Select ListEventType
						Case #PB_EventType_Change                        
						Case #PB_EventType_LeftDoubleClick
							
							Select ListEventGadget
								Case DC::#ListIcon_003  
									VEngine::DOS_Prepare()
									; If (vItemC64E::vItemC64E_CanClose = #True)
									;     Close_ToolTips(hwnd)                                        
									;     CloseList = GuruCallBack::PostEvents_Close(hwnd)                                 
									; EndIf
							EndSelect
							
							
						Case #PB_EventType_LeftClick
							Select ListEventGadget 
								Case DC::#ListIcon_003
									;If ( GetActiveGadget() = DC::#ListIcon_003 )
									;    vItemC64E::Item_Select_List()
									;EndIf    
							EndSelect
							
						Case #PB_EventType_RightClick
							Select ListEventGadget
								Case DC::#Button_278 
								Case DC::#Button_265
									;vItemC64E::Item_Side_SetAktiv(1)                                            
									;vItemC64E::DSK_OpenCBM_Init()                                                                                          
									;If ( vItemC64E::DSK_Image_TransferToPCHD(#True) = #True )
									
									;    If ( vItemC64E::DSK_LoadImage(GadgetID.i,DestGadgetID.i) = #True )
									;        vItemC64E::Item_Side_SetAktiv(-1)
									;        vItemC64E::Item_Auto_Select() 
									;    EndIf 
									;EndIf                                      
							EndSelect                                     
					EndSelect
					;***************************************************************************
					;                                        
					
					;***************************************************************************
					; 
				Case #WM_KEYDOWN
				Case #WM_KEYUP
					
					Select ListEventParam
							;                           Case #VK_RETURN:  
							;                             Select  ListEventGadget 
							;                                 Case DC::#String_018; Wird dann in der DB gespeichert
							;                                     DBBASEF::Item_Update_List(0)
							;                             EndSelect
						Case #VK_DELETE: 
							If ( GetActiveGadget() = DC::#ListIcon_004 )
								; vItemTool::Item_Delete_List()                          
							EndIf    
							;  
							; Benutzer Drückt Escape im Fenster
						Case #VK_ESCAPE:
							Close_ToolTips(hwnd)                            
							; vItemC64E::DSK_LoadOldFilename()
							;vItemTool::Item_Cancel(DC::#ListIcon_004)
							CloseList = GuruCallBack::PostEvents_Close(hwnd)   
							
						Case #VK_UP, #VK_DOWN, 33, 34 ;"Bild Hoch", "Bild Runter"      
											;If ( GetActiveGadget() = DC::#ListIcon_004 )
											;    vItemC64E::Item_Select_List()
											;EndIf                              
					EndSelect        
				Case #PB_Event_MoveWindow 
					; Menu Events 
				Case #PB_Event_Menu
					CLSMNU::MenuItemSelect_(ListEventMenu)                      
			EndSelect
			;
			;
			
		Until CloseList.i = #True:
		
		vArchiv::Close()
		
		
	EndProcedure      
	
  ;
  ;  Window/ Gadget Check
	;
	Procedure GadgetWindowCheck()
		
		If Startup::*LHGameDB\Switch = 0
			
			If ( Form::IsOverObject( WindowID( DC::#_Window_001 ))) = 1 And Not (Startup::*LHGameDB\WindowIDCheck =  DC::#_Window_001)
				
				;SetActiveWindow( DC::#_Window_001)
				Startup::*LHGameDB\WindowIDCheck =  DC::#_Window_001
				SetActiveWindow( Startup::*LHGameDB\WindowIDCheck)	
				
				
			ElseIf IsWindow(  DC::#_Window_006 )
				If ( Form::IsOverObject( WindowID( DC::#_Window_006 ))) = 1 And Not (Startup::*LHGameDB\WindowIDCheck =  DC::#_Window_006)
					;
					;SetActiveWindow( DC::#_Window_006)
					Startup::*LHGameDB\WindowIDCheck =  DC::#_Window_006
					SetActiveWindow( Startup::*LHGameDB\WindowIDCheck)	
					
				EndIf				
			EndIf      												
			
			If ( Startup::*LHGameDB\WindowIDCheck =  DC::#_Window_001 )
				
				If (Form::IsOverObject( GadgetID( DC::#Contain_10 ))) = 1 And Not (Startup::*LHGameDB\GadgetIDCheck =  DC::#Contain_10)
					;
					; Fix Mousewheel zwischen Liste und Thumbnail
					;
					Startup::*LHGameDB\GadgetIDCheck = DC::#Contain_10
					SetActiveGadget(Startup::*LHGameDB\GadgetIDCheck)					
					
				ElseIf (Form::IsOverObject( GadgetID( DC::#ListIcon_001 ))) = 1  And Not (Startup::*LHGameDB\GadgetIDCheck =  DC::#ListIcon_001)
					;
					; Fix Mousewheel zwischen Liste und Thumbnail
					;  				
					Startup::*LHGameDB\GadgetIDCheck = DC::#ListIcon_001
					SetActiveGadget(Startup::*LHGameDB\GadgetIDCheck)	
					
				EndIf							
			EndIf	
		EndIf	
  	
  EndProcedure  	
EndModule 


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 565
; FirstLine = 42
; Folding = Bgw
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode