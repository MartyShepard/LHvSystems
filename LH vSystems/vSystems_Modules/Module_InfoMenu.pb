DeclareModule vInfoMenu
    
    Declare     MainSelect(EvntMnu)   
    
    Declare     Cmd_Print(EvntGadget)    
    Declare     Cmd_TabRen(EvntGadget, Standard.i = #False)
    Declare     Cmd_ResetWindow()
    Declare     Cmd_DockSettings(nOption)
    
EndDeclareModule

Module vInfoMenu
    
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Cut(EvntGadget.i)
       SendMessage_( GadgetID( EvntGadget ),#WM_CUT,0,0)
       vInfo::Modify_Pressed(EvntGadget)
       vInfo::Caret_GetPosition() 
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Paste( EvntGadget.i )
       SendMessage_( GadgetID( EvntGadget ),#WM_PASTE,0,0)
       vInfo::Modify_Pressed(EvntGadget)
       vInfo::Caret_GetPosition()        
   EndProcedure  
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Copy( EvntGadget.i )
           SendMessage_( GadgetID( EvntGadget ),#WM_COPY,0,0)
   EndProcedure    
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Markall( EvntGadget.i )
           SendMessage_( GadgetID( EvntGadget ),#EM_SETSEL,0,-1)
   EndProcedure         
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_MarkNone( EvntGadget.i )
           SendMessage_( GadgetID( EvntGadget ),#EM_SETSEL,0,0)
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Undo( EvntGadget.i )
       SendMessage_( GadgetID( EvntGadget ),#EM_UNDO,0,0)
       vInfo::Modify_Pressed(EvntGadget)
       vInfo::Caret_GetPosition()        
   EndProcedure         
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Redo( EvntGadget.i )
       SendMessage_( GadgetID( EvntGadget ),#EM_REDO,0,0)
       vInfo::Modify_Pressed(EvntGadget)
       vInfo::Caret_GetPosition()        
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Clear( EvntGadget.i )           
        SendMessage_(GadgetID(EvntGadget),#EM_SETSEL,0,-1)
        keybd_event_(#VK_DELETE, #Null, #Null, #Null)
        keybd_event_(#VK_DELETE, #Null, #KEYEVENTF_KEYUP, #Null)
        vInfo::Modify_Pressed(EvntGadget)
        vInfo::Caret_GetPosition()         
        SetGadgetText( DC::#String_112, "")
    EndProcedure  
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************
    Procedure   Cmd_Find( EvntGadget.i ) 
            vInfo::Find_Dialog( EvntGadget )
    EndProcedure  
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Open( EvntGadget.i )
                vEngine::GetFile_Media(DC::#String_112 )
                vEngine::Text_Show():
   EndProcedure           
   ;**************************************************************************************************************************************************************** 
   ; 
   ;**************************************************************************************************************************************************************** 
   Procedure    Cmd_Save(SaveAsNewFile.i = #False)
       
       Protected szFile.s, szText.s, szFilePath.s, szFileProg.s, szExtension.s , szPattern.s
       Protected nEncoding = #PB_Unicode
       
       szFile.s = vEngine::Getfile_Portbale_ModeOut( GetGadgetText( DC::#String_112 ) )
           
           szFilePath.s = GetPathPart( szFile )
           szFileProg.s = GetFilePart( szFile ) 
           szExtension  = GetExtensionPart( szFile )
           
           If ( SaveAsNewFile = #True )
               
               If  ( szExtension = "")
                   szExtension = "txt"
               EndIf
               
               szPattern = "Auto (*."+LCase(szExtension)+")|*."+LCase(szExtension)+"|Alle Dateien (*.*)|*.*"
               
               szFile = SaveFileRequester( "Save ", szFilePath + GetFilePart( szFileProg,1 ), szPattern,0 )
               
                If ( szFile )
                    szFilePath.s = GetPathPart( szFile )
                    szFileProg.s = GetFilePart( szFile ) 
                    
                    Select SelectedFilePattern()
                        Case 0
                            szFileProg + "." + szExtension
                        Case 1 ; Wir gehen davon aus das der User ein Patten drangeängt hat
                    EndSelect        
                EndIf    
            EndIf
            
           nEncoding    =  vInfo::File_CheckEncode (szFilePath + szFileProg)
           
           Select Startup::*LHGameDB\InfoWindow\bTabNum
               Case 1
                   SetActiveGadget( DC::#Text_128 )
                   vEngine::Text_UpdateDB()
                   szText.s = GetGadgetText( DC::#Text_128  )
               Case 2
                   SetActiveGadget( DC::#Text_129 )                                        
                   vEngine::Text_UpdateDB()
                   szText.s = GetGadgetText( DC::#Text_129  )                  
               Case 3
                   SetActiveGadget( DC::#Text_130 )              
                   vEngine::Text_UpdateDB()
                   szText.s = GetGadgetText( DC::#Text_130  )                 
               Case 4
                   SetActiveGadget( DC::#Text_131 )              
                   vEngine::Text_UpdateDB()
                   szText.s = GetGadgetText( DC::#Text_131  )                    
           EndSelect 
           
           hFile = OpenFile( #PB_Any,  szFilePath + szFileProg)
           If ( hFile )
               Select nEncoding
                   Case 0
                       WriteString(hFile, szText)
                   Default
                       WriteString(hFile, szText, nEncoding)                      
                EndSelect
                CloseFile( hFile )    
            EndIf     
            
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************          
   Procedure    Cmd_Reload( EvntGadget.i )
       
       Protected szFileShort.s, szFileLong.s
       
       szFileShort = GetGadgetText(DC::#String_112 )
              
       If ( szFileShort )
           
           szFileLong = vEngine::Getfile_Portbale_ModeOut( szFileShort )
           
           If ( FileSize( szFileLong ) >= 1 )           
                vEngine::Text_Show():
           Else
                Request::MSG(Startup::*LHGameDB\TitleVersion, "Datei nicht Gefunden" ,Chr(32) + szFileLong + Chr(32) ,2,2)
           EndIf                
       EndIf    
       
   EndProcedure      
   
   ;****************************************************************************************************************************************************************
   ; Das Menu dazu liegt im Callback des EditorGadgets   
   ;****************************************************************************************************************************************************************      
   Procedure    Cmd_Print(EvntGadget)
           vInfo::Print_Text( WindowID( DC::#_Window_006), GetModuleHandle_(0), GadgetID(EvntGadget), 10, 10, 20, 20)                      
   EndProcedure
   ;****************************************************************************************************************************************************************
   ; Font Einstellungen
   ;****************************************************************************************************************************************************************    
   Procedure    Cmd_SetFont(EvntGadget, FixedFonts = 0)
       
       Select EvntGadget
           Case DC::#Text_128: vFont::SetDB(3, FixedFonts) 
           Case DC::#Text_129: vFont::SetDB(4, FixedFonts)                
           Case DC::#Text_130: vFont::SetDB(5, FixedFonts)
           Case DC::#Text_131: vFont::SetDB(6, FixedFonts)                
       EndSelect
       
   EndProcedure
   ;****************************************************************************************************************************************************************
   ; Font Einstellungen, Standard
   ;****************************************************************************************************************************************************************    
   Procedure    Cmd_DefFont(EvntGadget)
       
       Protected nFont.l
       
       Select EvntGadget
           Case DC::#Text_128: vFont::DelDB(3, EvntGadget) 
           Case DC::#Text_129: vFont::DelDB(4, EvntGadget)               
           Case DC::#Text_130: vFont::DelDB(5, EvntGadget)
           Case DC::#Text_131: vFont::DelDB(6, EvntGadget)                
       EndSelect

       ;SetGadgetFont( EvntGadget, FontID( Fonts::#_FIXPLAIN7_12 ) )
       
   EndProcedure   
   ;****************************************************************************************************************************************************************
   ; Tabs Umbennen
   ;****************************************************************************************************************************************************************     
   Procedure    Cmd_TabRen(EvntGadget, Standard.i = #False)       
        vInfo::Tab_SetName(EvntGadget, Standard.i)       
    EndProcedure
   ;****************************************************************************************************************************************************************
   ; Worwrap     
   ;****************************************************************************************************************************************************************        
    Procedure   Cmd_WordWrap()
        vInfo::WordWrap_Set()        
    EndProcedure
   ;****************************************************************************************************************************************************************
   ;Reset Window Position    
   ;****************************************************************************************************************************************************************        
    Procedure   Cmd_ResetWindow()
                vInfo::Window_Reset()
                If IsWindow( DC::#_Window_006 )                               
                    vInfo::Window_Reload()                
                EndIf    
    EndProcedure    
    
    Procedure   Cmd_DockSettings(nOption)        
        Startup::*LHGameDB\InfoWindow\bSide = nOption        
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "DockWindow", Str(nOption),1)
        
        vInfo::Window_SetSnapPos()
    EndProcedure
    
    Procedure   Cmd_OpenFileWith()
        Protected szFile.s
        
        szFile = vEngine::Getfile_Portbale_ModeOut( GetGadgetText( DC::#String_112 ))
        If ( szFile )
            If ( FileSize(szFile) > 0 )  
                Flags.l = 4
                FFH::SHOpenWithDialog_(szFile, Flags)
            Else
                Request::MSG(Startup::*LHGameDB\TitleVersion, "Datei nicht Gefuncen" ,Chr(32) + szFile + Chr(32) ,2,2)
            EndIf    
        EndIf
        
    EndProcedure
    
    Procedure   Cmd_FileProperties()
        
        Protected szFile.s
        
        szFile = vEngine::Getfile_Portbale_ModeOut( GetGadgetText( DC::#String_112 ))
        If ( szFile )
            If ( FileSize(szFile) > 0 )  
                
                verb$ = "properties" 
                SEI.SHELLEXECUTEINFO 
                SEI\cbSize = SizeOf(SHELLEXECUTEINFO) 
                SEI\fMask = #SEE_MASK_NOCLOSEPROCESS | #SEE_MASK_INVOKEIDLIST | #SEE_MASK_FLAG_NO_UI 
                SEI\lpVerb = @verb$ 
                
                File$ = szFile 
                SEI\lpFile = @File$ 
                ShellExecuteEx_(@SEI) 

            Else
                Request::MSG(Startup::*LHGameDB\TitleVersion, "Datei nicht Gefunden" ,Chr(32) + szFile + Chr(32) ,2,2)
            EndIf    
        EndIf
        
    EndProcedure
    
    Procedure   Cmd_WindowsRunning()
        
        SendMessage_(FindWindow_("Shell_TrayWnd",""),#WM_COMMAND,$191,0)
        
    EndProcedure    
    
    Procedure   Cmd_UrlOpenWith()
        
        Protected szURL.s
        
        szURL = Startup::*LHGameDB\InfoWindow\sUrlAdresse
        If ( szURL )

            Flags.l = 4
            
            szProtocol.s = GetURLPart(szURL, #PB_URL_Protocol)
            If ( szProtocol = "" )
                szURL = "http://" + szURL
            EndIf   
            

;             szPath.s = GetURLPart(szURL, #PB_URL_Path)
;             If ( szPath = "" )
;                 szURL + "/"
;             EndIf             
            
            FFH::SHOpenWithDialog_(szURL, Flags)
        EndIf   
        
        Startup::*LHGameDB\InfoWindow\sUrlAdresse = ""        
        Startup::*LHGameDB\InfoWindow\bURLOpnWith = #True                
    EndProcedure
    ;****************************************************************************************************************************************************************
   ; Info Window Menu
   ;****************************************************************************************************************************************************************     
   Procedure    MainSelect(EvntMnu)      

       Select EvntMnu
             Case 500: Cmd_Undo    ( vInfo::Tab_GetGadget() )               
             Case 501: Cmd_Cut     ( vInfo::Tab_GetGadget() )
             Case 502: Cmd_Undo    ( vInfo::Tab_GetGadget() )                   
             Case 503: Cmd_Copy    ( vInfo::Tab_GetGadget() )                
             Case 504: Cmd_Paste   ( vInfo::Tab_GetGadget() )
             Case 505: Cmd_Markall ( vInfo::Tab_GetGadget() )                  
             Case 506: Cmd_MarkNone( vInfo::Tab_GetGadget() )                   
             Case 507: Cmd_Clear   ( vInfo::Tab_GetGadget() )
             Case 508: Cmd_Find    ( vInfo::Tab_GetGadget() )  
             Case 509: Cmd_Open    ( vInfo::Tab_GetGadget() )
             Case 510: vEngine::Text_UpdateDB()
             Case 511: Cmd_Save    ( #False)
             Case 512: Cmd_Save    ( #True )
             Case 513: Cmd_Print   ( vInfo::Tab_GetGadget() )
             Case 514: Cmd_DefFont ( vInfo::Tab_GetGadget() )
             Case 515: Cmd_SetFont ( vInfo::Tab_GetGadget() )  
             Case 517: Cmd_TabRen  ( DC::#Button_283 )
             Case 518: Cmd_TabRen  ( DC::#Button_284 )
             Case 519: Cmd_TabRen  ( DC::#Button_285 )
             Case 520: Cmd_TabRen  ( DC::#Button_286 )
             Case 521: Cmd_TabRen  ( DC::#Button_283, #True )
             Case 522: Cmd_TabRen  ( DC::#Button_284, #True )                     
             Case 523: Cmd_TabRen  ( DC::#Button_285, #True )                     
             Case 524: Cmd_TabRen  ( DC::#Button_286, #True ) 
             Case 525: Cmd_WordWrap()
             Case 526: Cmd_ResetWindow()
             Case 532: vInfo::Tab_AutoOpen_Set()
             Case 527: vEngine::DOS_Open_Directory(0)
             Case 528: vEngine::DOS_Open_Directory(1)                 
             Case 529: vEngine::DOS_Open_Directory(2)                 
             Case 530: vEngine::DOS_Open_Directory(3)                 
             Case 531: vEngine::DOS_Open_Directory(4)                 
             Case 516: ButtonEX::SetState(DC::#Button_016,0): vInfo::Modify_EndCheck(): vInfo::Window_Props_Save(): vInfo::Window_Close()
             Case 533: vFont::SetDB(1)
             Case 534: vFont::SetDB(2)
             Case 542: VEngine::Splitter_SetAll()
             Case 535: vEngine::ServiceOption("uxsms", #True) 
             Case 536: vEngine::ServiceOption("uxsms", #False)   
             Case 537: DesktopEX::StartExplorer()   
             Case 538: DesktopEX::CloseExplorer()    
             Case 539, 540: DesktopEX::SetTaskBar()
             Case 541: vFont::DelDB(1, DC::#Text_001): vFont::DelDB(1 ,DC::#Text_002)
             Case 543: vFont::DelDB(2, DC::#ListIcon_001)
             Case 544: vEngine::Thumbnails_SetAll()
             Case 551: vEngine::Thumbnails_Set(1)
             Case 552: vEngine::Thumbnails_Set(2)   
             Case 553: vEngine::Thumbnails_Set(3)   
             Case 554: vEngine::Thumbnails_Set(4)                    
             Case 555: vEngine::Thumbnails_Set(5)                    
             Case 556: vEngine::Thumbnails_Set(6)                    
             Case 557: vEngine::Thumbnails_Set(7)                 
             Case 545: Cmd_SetFont ( vInfo::Tab_GetGadget(),2 ) 
             Case 546: Cmd_SetFont ( vInfo::Tab_GetGadget(),1 )
             Case 547: vFont::SetDB(1,2)
             Case 548: vFont::SetDB(1,1)                 
             Case 549: vFont::SetDB(2,2)
             Case 550: vFont::SetDB(2,1)
             Case 558: vDiskPath::ReConstrukt(1, #False) ; Search for All on Slot 1
             Case 559: vDiskPath::ReConstrukt(2, #False) ; Search for All on Slot 2                 
             Case 560: vDiskPath::ReConstrukt(3, #False) ; Search for All on Slot 3
             Case 561: vDiskPath::ReConstrukt(4, #False) ; Search for All on Slot 4 
             Case 562: vDiskPath::ReConstrukt(1, #True ) ; Search for Current Item on Slot 1
             Case 563: vDiskPath::ReConstrukt(2, #True ) ; Search for Current Item on Slot 2                 
             Case 564: vDiskPath::ReConstrukt(3, #True ) ; Search for Current Item on Slot 3
             Case 565: vDiskPath::ReConstrukt(4, #True ) ; Search for Current Item on Slot 4
             Case 566: Cmd_DockSettings(0)
             Case 567: Cmd_DockSettings(1)                 
             Case 568: Cmd_DockSettings(-1)
             Case 569: Cmd_DockSettings(2)
             Case 570: Cmd_OpenFileWith()
             Case 571: Cmd_FileProperties()
             Case 572: Cmd_WindowsRunning() 
             Case 573: Cmd_UrlOpenWith()
             Case 574: Cmd_Reload    ( vInfo::Tab_GetGadget() )
                 
             Default
                 Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Edit Item Menu NR: "+ Str(EvntMnu) )
         EndSelect
                    
     EndProcedure    
    
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 166
; FirstLine = 37
; Folding = DACA+
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release