DeclareModule VEngine
       
    Declare     Thread_LoadGameList_Action()
    Declare     Thread_LoadGameList(t)
    Declare     Thread_LoadGameList_Sort(Save.i = -1)
    
    Declare     ListBox_GetData_LeftMouse(ForceUpdate = #False)
    Declare     ListBox_GetData_KeyBoard(KeyPressed.i)
    
    Declare     DataBase_Add()    
    Declare     Database_Get(RowID)
    Declare     Database_Set_Title(Str$)
    Declare     Database_Remove(SafeItems.i = 0, Special.i = #False)
    Declare     Database_Set_Release()
    Declare     DataBase_Duplicate() 
    Declare     Update_Changes()    
    Declare     Database_Set_ProgramArgs(StringID.i)
    Declare     Database_Set_ProgramTitle(StringID.i)    
    
    Declare     GadObjects_ClrRve_MediaOnly()
    
    Declare     GetFile_Media       (DPGadgetID.i, FileStream.s = "")
    Declare     GetFile_Programm    (DPGadgetID.i, FileStream.s = "") 
    Declare     GetFile_Programm_64 (DPGadgetID.i, FileStream.s = "")    
    
    
    Declare     Change_Title(GadgetID.i)
      
    Declare     Switcher_Pres_NoItems()
    Declare     Switcher_Pres_List(Obj.i)    
    
    Declare     Splitter_SetGet(Get = #True, Height = 289)  
    Declare     Splitter_SetAll(NoAsk = #False)
    Declare     Splitter_SetHeight(SetHeight.i = 289, ThumbnailMode = #False, NewWindowHeight = #False, SetWindowHeight = 0)
       
    Declare     DOS_Prepare()
    Declare.i   DOS_Open_Directory(nOption, bCheck = #False)
    
    Declare     ListIconBox_Get_InfoPosition()
    
    Declare     PicSupport_Hide_Show()
    
    Declare.s   Getfile_Portbale_ModeOut(TestFile$)
    Declare.s   Getfile_Portbale_Modein(TestFile$)
    
    Declare     Text_Show()
    Declare     Text_GetDB()
    Declare.i   Text_GetDB_Check()
    Declare     Text_UpdateDB()
    
    Declare     Thumbnails_SetAll()
    Declare     Thumbnails_Set(nSize.i)
    
    Declare.i   FileManageR_MediumCheck(GadgetID.i, DestGadgetID.i)
    
    Declare	 MAME_Driver_Import() 
    Declare	 MAME_Roms_Check_Import()
    Declare	 MAME_Roms_Check()    
    Declare.i MAME_Roms_Backup(UserFile.s = "")
    Declare.i MAME_Roms_GetInfos() 
    Declare	 Thread_HTTP_MAME_Roms_DoEvents() 
    Declare	 MAME_Driver_Info_wwwAI() 
    
    Declare	 vSys_MainButtonsConfig(state.i = #True)
    
    Declare     ServiceOption(service$, Start.i = #True) 
EndDeclareModule

Module VEngine
    
    Structure PROCESS_BASIC_INFORMATION
        ExitStatus.i
        PebBaseAddress.i
        AffinityMask.i
        BasePriority.i
        UniqueProcessId.i
        InheritedFromUniqueProcessId.i
    EndStructure
        	
    Structure PROGRAM_BOOT
        Program.s
        PrgPath.s
        WrkPath.s
        Command.s
        Logging.s
        PrgFlag.l
        ExError.i  
        StError.s
        ErrorLg.l
        StdOutL.i
        hThread.i
        hProcess.i
    EndStructure
    
    Structure DELETE_ENTRIES
        GadgetTextID.i
        GadgetListID.i
        ItemEntries.i
        MaxEntries.i
        SafeItem.i
    EndStructure     
    
    Structure HTTP_INDEX
        File.s
        Urls.s
        Size.q       
    EndStructure 
    
    Structure MAME_DRIVER_IMPORT_LIST
       	DriverName.s
    	Title.s
     	Region.s
    EndStructure
    
    Structure MAME_DRIVER_PARAMS_LIST
    	List mdil.MAME_DRIVER_IMPORT_LIST()
    EndStructure
    
    Structure MAME_SOURCECODE_INFO_FLAGS
    	MACHINE_NOT_WORKING.i
    	MACHINE_NO_SOUND.i
    	MACHINE_IMPERFECT_SOUND.i
    	MACHINE_IMPERFECT_COLORS.i
    	MACHINE_SUPPORTS_SAVE.i
    	MACHINE_WRONG_COLORS.i
    	MACHINE_UNEMULATED_PROTECTION.i
    	MACHINE_MECHANICAL.i
    	MACHINE_NODEVICE_LAN.i
    	MACHINE_IS_SKELETON_MECHANICAL.i
    	MACHINE_NO_COCKTAIL.i
    	MACHINE_IS_BIOS_ROOT.i
    	MACHINE_REQUIRES_ARTWORK.i
    	MACHINE_CLICKABLE_ARTWORK.i
    	MACHINE_UNOFFICIAL.i
    	MACHINE_IS_INCOMPLETE.i
    EndStructure	
         
    Structure MAME_SOURCECODE_INFO_PERFILE
    	YEAR.s
    	NAME.s
    	PARENT.s
    	COMPAT.s
    	MACHINE.s
    	INPUT.s
    	CLASS.s
    	INIT.s
    	COMPANY.s
    	FULLNAME.s
    	FLAGS.s
    	SOURCECODE.s
    	PLATFORM.s
    	List MSIF.MAME_SOURCECODE_INFO_FLAGS()
    EndStructure
    
    Structure MAME_SOURCECODE_INFO_COLLECTION    	
    	FullFilePath.s
    EndStructure
    
    Structure MAME_SOURCECODE_INFO
    	SingleElement.i
    	List MSIC.MAME_SOURCECODE_INFO_COLLECTION()
    	List MSIP.MAME_SOURCECODE_INFO_PERFILE()    	
    EndStructure	
    
    Structure DATABASE_INDEX_LIST
    	Index.i
    	RomFile.s
    	Section.s
    	Single.i
    	SingleFound.i
    EndStructure	
    
    Global NewList DIL.DATABASE_INDEX_LIST()
    
    Global MainEventMutex = CreateMutex()
    Global ProgrammMutex
      
    ;****************************************************************************************************************************************************************
    ; Enable Disbale Services
    ;****************************************************************************************************************************************************************    
    Procedure ServiceOption(service$, Start.i = #True)
        
        If (ServiceEX::Service_Exists(service$) = #False)
            ; TODO "FATAL"
            ProcedureReturn #False
        EndIf
        
        If ( Start = #True )
            ServiceEX::Service_Start(Service$)    
        EndIf
        If ( Start = #False )
            ServiceEX::Service_Stop(Service$)    
        EndIf        
    EndProcedure      
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure DataBase_Edt()    
        
        
        SetGadgetText(DC::#String_001,""): SetGadgetText(DC::#String_002,""): SetGadgetText(DC::#String_003,""): SetGadgetText(DC::#String_004,"")
        SetGadgetText(DC::#String_005,""): SetGadgetText(DC::#String_006,""): SetGadgetText(DC::#String_007,""): SetGadgetText(DC::#String_008,"")
        SetGadgetText(DC::#String_009,""): SetGadgetText(DC::#String_010,""): SetGadgetText(DC::#String_011,"")
       
        ;
        ; Öffne die Datenbank
;         ExecSQL::OpenDB(DC::#Database_001,Startup::*LHGameDB\Base_Game): Delay(2)        
        
        VEngine::Database_Get(Startup::*LHGameDB\GameID)
        
    EndProcedure    
  
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure DataBase_Add()
        
                Protected Title$ = ""
                
                  SetActiveGadget(-1)
                  r = vItemTool::DialogRequest_Add()
                  
                  If (r = 1)
                                        
                    SetActiveGadget(DC::#ListIcon_001): ProcedureReturn
                  Else
                      
                      ;
                      ; Neue String Säubern
                      Title$ = Trim(Request::*MsgEx\Return_String)
                      If ( Len(Title$) => 1 )
                          
                          HideGadget(DC::#Contain_06,0) ;Container: Edit 
                          HideGadget(DC::#Contain_07,0) ;Container: Button Edit               
                          HideGadget(DC::#Contain_02,1) ;Container: Liste
                          HideGadget(DC::#Contain_03,1) ;Container: Button Liste
                          HideGadget(DC::#Contain_09,1) ;Container: Button Liste
                          HideGadget(DC::#Contain_10,1) ;Container: Screens 
                          HideGadget(DC::#Splitter1,1)  ; Der Splitter
                          ;
                          ; Öffne die Datenbank
;                           ExecSQL::OpenDB(DC::#Database_001,Startup::*LHGameDB\Base_Game): Delay(10)
                          
                          ;
                          ;
                          Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #NEU: ALTE ROWID: "+Str(Startup::*LHGameDB\GameID) ) 
                          ExecSQL::InsertRow(DC::#Database_001,"Gamebase", "GameTitle ", Title$)                      
                          Startup::*LHGameDB\GameID = ExecSQL::LastRowID(DC::#Database_001,"Gamebase")
                          ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1)
                     
                          Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #NEU: LAST-ROWID: "+Str(ExecSQL::LastRowID(DC::#Database_001,"Gamebase")) )                           
                          Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #NEU: NEUE ROWID: "+Str(Startup::*LHGameDB\GameID) ) 
                          
                          ;
                          ; Screenshot Zelle hinzufügen
                          ExecSQL::InsertRow(DC::#Database_002,"GameShot", "BaseGameID ", Str(Startup::*LHGameDB\GameID)) 
                          ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str(202),Startup::*LHGameDB\GameID)
                          ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str(142),Startup::*LHGameDB\GameID)                            
                          VEngine::Splitter_SetGet(#False)
                         
                          ;
                          ;Pict LIste nicht vergessen
                          
                          ; Nach dem Update wieder schliessen
                          ; Wird in der Procedure Thread_LoadGameList() geschlossen
                          
                          ;
                          ;
                          ; Neuer Title, Liste Löschen
                          VEngine::Thread_LoadGameList_Action()
                          vImages::Screens_Show() 
                          ;Delay(2)
                          VEngine::Switcher_Pres_List(DC::#Button_010)
                          
                      EndIf                      
                  EndIf   
     EndProcedure        
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure DataBase_Duplicate()
        Protected LastGameID.i, TestString$, TestValID.i, *ScreenShots, Width.i, Height.i, rDupShots.i, TextInfoObj.i = DC::#Text_004, rSzeShots.i
        
        HideGadget(TextInfoObj,0)                          
        SendMessage_(GadgetID(DC::#ListIcon_001),#WM_SETREDRAW,0,0)
        
        SetPriorityClass_(GetCurrentProcess_(),#REALTIME_PRIORITY_CLASS)
        ;
        ; Neuer Leerer Eintrag
         SetGadgetText(TextInfoObj,"Duplicate..")           
         ExecSQL::InsertRow(DC::#Database_001,"Gamebase", "GameTitle ", "NONAME")             
        
        ;
        ; Letzte id aus der Datenbank holen und in die Viaribale Speichern
        ; Voerher die Letzte id Sichern von der wir aus die Daten kopieren
        SetGadgetText(DC::#Text_004,"Duplicate...")            
        SourceGameID.i            = Startup::*LHGameDB\GameID 
        Startup::*LHGameDB\GameID = ExecSQL::LastRowID(DC::#Database_001,"Gamebase")
         
                        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Title]")            
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","GameTitle","",SourceGameID,"",1) + " [COPY]"
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "GameTitle", TestString$, Startup::*LHGameDB\GameID)
          
                
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Publisher]")   
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","Publisher","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Publisher", TestString$, Startup::*LHGameDB\GameID)
                          
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Developer]")   
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","Developer","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Developer", TestString$, Startup::*LHGameDB\GameID)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Release]")   
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","Release","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Release", TestString$, Startup::*LHGameDB\GameID)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [LanguageID]") 
        TestValID.i = 0
        TestValID.i = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","LanguageID","",SourceGameID,"",1))
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "LanguageID", Str(TestValID), Startup::*LHGameDB\GameID)
                
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [PlatformID]") 
        TestValID.i = 0
        TestValID.i = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PlatformID","",SourceGameID,"",1))
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "PlatformID", Str(TestValID), Startup::*LHGameDB\GameID)     
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Compatibility_TXT]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","Compatibility_TXT","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Compatibility_TXT", TestString$, Startup::*LHGameDB\GameID)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Compatibility_PRG]") 
        TestValID.i = 0
        TestValID.i = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","Compatibility_PRG","",SourceGameID,"",1))
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Compatibility_PRG", Str(TestValID), Startup::*LHGameDB\GameID)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [PC_Serial]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","PC_Serial","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "PC_Serial", TestString$, Startup::*LHGameDB\GameID) 
                
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [PortID]") 
        TestValID.i = 0
        TestValID.i = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","",SourceGameID,"",1))
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "PortID", Str(TestValID), Startup::*LHGameDB\GameID)
                
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [MediaDev0]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev0", TestString$, Startup::*LHGameDB\GameID) 
                
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [MediaDev1]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev1","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev1", TestString$, Startup::*LHGameDB\GameID) 
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [MediaDev2]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev2","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev2", TestString$, Startup::*LHGameDB\GameID)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [MediaDev3]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev3","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev3", TestString$, Startup::*LHGameDB\GameID)         
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [FileDev0]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev0","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev0", TestString$, Startup::*LHGameDB\GameID) 
                
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [FileDev1]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev1","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev1", TestString$, Startup::*LHGameDB\GameID) 
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [FileDev2]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev2","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev2", TestString$, Startup::*LHGameDB\GameID)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [FileDev3]") 
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev3","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev3", TestString$, Startup::*LHGameDB\GameID)         
        
        ;
        ; Copy Spltterheight
        TestString$ = ""
        TestString$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","SplitHeight","",SourceGameID,"",1)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", TestString$, Startup::*LHGameDB\GameID)        
        
        ExecSQL::InsertRow(DC::#Database_002,"GameShot", "BaseGameID ", Str(Startup::*LHGameDB\GameID))         
        
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots                    
            *ScreenShots = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Thb",SourceGameID,"BaseGameID")  
            If ( *ScreenShots <> 0 )
                rDupShots = vItemTool::DialogRequest_Dup()                   
                Break;
            EndIf
        Next    
        ; Screen Shots Duplicate
        ; 
        
        
        If ( rDupShots <> 0 ) 
            
            If ( Startup::*LHGameDB\wScreenShotGadget <> 202 ) And ( Startup::*LHGameDB\hScreenShotGadget <> 142 )
                rSzeShots = vItemTool::DialogRequest_Sze() 
            EndIf    
        EndIf   
                 
        If ( rDupShots = 0 )  
            
            For n = 1 To Startup::*LHGameDB\MaxScreenshots
                 SetGadgetText(TextInfoObj,"Duplicate... [Image Thumbnail "+n+"/"+Startup::*LHGameDB\MaxScreenshots+"] (Load & Get ..)")                   
                *ScreenShots = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Thb",SourceGameID,"BaseGameID")     
                If ( *ScreenShots <> 0 )
                    ;
                    ; 
                    SetGadgetText(TextInfoObj,"Duplicate... [Image Thumbnail "+n+"/"+Startup::*LHGameDB\MaxScreenshots+"] (Save & Set ..) [Size: "+MathBytes::Bytes2String(MemorySize(*ScreenShots)-1)+ "]")                     
                    ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(n) +"_Thb","",Startup::*LHGameDB\GameID,1,*ScreenShots,"BaseGameID"):Delay(2)

                EndIf    
            Next 
            
            For n = 1 To Startup::*LHGameDB\MaxScreenshots
                SetGadgetText(TextInfoObj,"Duplicate... [Image Original "+n+"/"+Startup::*LHGameDB\MaxScreenshots+"] (Load & Get ..)") 
                *ScreenShots = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Big",SourceGameID,"BaseGameID")     
                If ( *ScreenShots <> 0 )
                    SetGadgetText(TextInfoObj,"Duplicate... [Image Original "+n+"/"+Startup::*LHGameDB\MaxScreenshots+"] (Save & Set ..) [Size: "+MathBytes::Bytes2String(MemorySize(*ScreenShots)-1)+ "]")                    
                    ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(n) +"_Big","",Startup::*LHGameDB\GameID,1,*ScreenShots,"BaseGameID"):Delay(1)

                EndIf    
            Next  
            
             
        EndIf    
        
        If ( rDupShots = 0 ) Or  ( rSzeShots = 0 )
            ;
            ; Übertrage den Thumbnail Size
            ;
            ; 
            SetGadgetText(TextInfoObj,"Duplicate... [Thumbnail Size]") 
            
            Width  = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsW",0,SourceGameID,"",1)
            Height = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsH",0,SourceGameID,"",1)             
        
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str(Width),Startup::*LHGameDB\GameID)
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str(Height),Startup::*LHGameDB\GameID)    
        EndIf 
        
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1)
        
        ;
        ; 
        SetGadgetText(TextInfoObj,"Duplicate... [Finished ...]") 
        
        VEngine::Thread_LoadGameList_Action()
        SendMessage_(GadgetID(DC::#ListIcon_001),#WM_SETREDRAW,1,0)
        vImages::Screens_Show() 
        ;Delay(2)
        ;
        ; 
        SetGadgetText(TextInfoObj,"") 
        HideGadget(TextInfoObj,1)
       
        ProcessEX::LHFreeMem() :SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
    EndProcedure               
    
    Procedure GadObjects_ClrRve_MediaOnly()
        
        SetGadgetText(DC::#String_008,"")
        SetGadgetText(DC::#String_009,"")
        SetGadgetText(DC::#String_010,"")
        SetGadgetText(DC::#String_011,"") 
        SetGadgetText(DC::#String_107,"")
        SetGadgetText(DC::#String_108,"")
        SetGadgetText(DC::#String_109,"")
        SetGadgetText(DC::#String_110,"")          
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
    Procedure GadObjects_ClrRve()
        SetGadgetText(DC::#Text_001,""): SetGadgetText(DC::#Text_002,""): HideGadget(DC::#Text_006,1): SetGadgetText(DC::#Text_006,"Release:"): 
        SetGadgetText(DC::#Text_007,""): SetGadgetText(DC::#Text_008,"")
        
        SetGadgetText(DC::#String_001,""): SetGadgetText(DC::#String_002,""): SetGadgetText(DC::#String_003,""): SetGadgetText(DC::#String_004,""): 
        SetGadgetText(DC::#String_005,""): SetGadgetText(DC::#String_006,""): SetGadgetText(DC::#String_007,""): SetGadgetText(DC::#String_008,""): 
        SetGadgetText(DC::#String_009,""): SetGadgetText(DC::#String_010,""): SetGadgetText(DC::#String_011,""):
        
        SetGadgetText(DC::#String_107,""): SetGadgetText(DC::#String_108,""): SetGadgetText(DC::#String_109,""): SetGadgetText(DC::#String_110,""):         
      EndProcedure            
    ;****************************************************************************************************************************************************************
    ;
    ;**************************************************************************************************************************************************************** 
    Procedure Database_Set_Title(Title.s)
        Protected Position.i, Text_001$, Text_002$, cnt.i
        
        Text_001$ = Title
        Text_002$ = ""
        
        cnt = CountString( Text_001$, "-")
        If (cnt > 0)
            Position = FindString(Title,"-",1)
            If ( Position > 0 )
             
              Text_001$ = Mid(Title, 1, Position-1)
              Text_002$ = Mid(Title, Position + 1,Len(Title))

            EndIf            
        Else
            cnt = CountString( Text_001$, ":")
            If (cnt > 0)
                Position = FindString(Title,":",1)
                If ( Position > 0 )
             
                Text_001$ = Mid(Title, 1, Position-1)
                Text_002$ = Mid(Title, Position + 1,Len(Title))

                EndIf             
            EndIf
        EndIf    
        
        
        Text_001$ = Trim(Text_001$)
        Text_002$ = Trim(Text_002$)
        
        SetGadgetText(DC::#Text_001,Text_001$)
        SetGadgetText(DC::#Text_002,Text_002$)
        SetGadgetText(DC::#String_001,Text_001$)
        SetGadgetText(DC::#String_002,Text_002$)
         
          
    EndProcedure        
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
    Procedure.i Change_Title_VerifyAscii(TestString$)
        
        Protected Start.i, Char.i, AsciiPos.i, Result.i = #False
        
        ;For  AsciiPos = 1 To Len(TestString$)           
        
        SendMessage_(GadgetID(DC::#String_005), #EM_GETSEL, @Start, 0)            
        
        Char = Asc(Right(TestString$,1))
        
        Debug "Ascii : " + Chr(Char) + " AsciiPos:" + Str(Start.i)
     
            
        Select Start
            Case 0 To 4, 6 To 7, 9 To 10
                Select Char
                   Case 48 To 57
                       Result = #True                                                                        
                    Default  
                        TestString$ = ReplaceString(TestString$,Chr(Char),"0",0,Start,1)  
                EndSelect 
            AsciiPos = Start
            
            Case 5, 8
                Select Char
                   Case 47
                       Result = #True                         
                       AsciiPos = Start
                   Default      
                        Select Char
                           Case 48 To 57
                               TestString$ = ReplaceString(TestString$,Chr(Char),"/"+Chr(Char),0,Start,1) 
                               AsciiPos = Start+1 
                           Default    
                               TestString$ = ReplaceString(TestString$,Chr(Char),"/",0,Start,1)
                               AsciiPos = Start
                        EndSelect                        
                EndSelect
       EndSelect
         
        
       ; Select Char
       ;     Case 48 To 57
       ;         Result = #True                                                                                 
       ;     Default  
       ;        TestString$ = ReplaceString(TestString$,Chr(Char),"",0,Len(TestString$),1)                            
       ; EndSelect       
        
       ; Select Result
       ;     Case #True
       ;     Select start
       ;         Case 5,8
       ;             Debug "Kalender: " + Chr(Char) + " AsciiPos:" + Str(Len(TestString$))
        ;            TestString$ = ReplaceString(TestString$,Chr(Char),"/"+Chr(Char),0,start,1)
        ;    EndSelect                
        ;        
        ;        Select Len(TestString$)
        ;            Case 5
        ;                TestString$ = ReplaceString(TestString$,Chr(Char),"/"+Chr(Char),0,5,1)
        ;            Case 8   
        ;                TestString$ = ReplaceString(TestString$,Chr(Char),"/"+Chr(Char),0,8,1)                        
        ;            Default                            
        ;        EndSelect       
                
                ;Break
                
        ;    Default
        ;EndSelect
        ;Next    
        SetGadgetText(DC::#String_005,TestString$)
        SendMessage_(GadgetID(DC::#String_005), #EM_SETSEL, AsciiPos, AsciiPos)         
        ProcedureReturn Result            

    EndProcedure 
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************     
    Procedure.s Change_Title_VerifyDate(TestString$)
        Protected s.s, i.i
        ;
        ; Prüfe Monat
        If ( Len(TestString$) >= 7 )
            s = Mid(TestString$,6,2)
            ;s = Val(s)
            If ( i >= 12 )
                SetGadgetText(DC::#String_005, ReplaceString(TestString$,s,"12",0,6,1))
                SendMessage_(GadgetID(DC::#String_005), #EM_SETSEL, Len(TestString$), Len(TestString$))
            EndIf                               
        EndIf   
        
        ;
        ; Prüfe Tage
        If ( Len(TestString$) = 10 )
            s = Mid(TestString$,9,2)
            ;i = Val(s)
            If ( i >= 31 )
                SetGadgetText(DC::#String_005, ReplaceString(TestString$,s,"31",1,8,1))
                SendMessage_(GadgetID(DC::#String_005), #EM_SETSEL, Len(TestString$), Len(TestString$))                
            EndIf                               
        EndIf         
    EndProcedure 
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
    Procedure.s Database_Get_Set_Release(Str$, Get=#True)
        
        Protected Result.i, ParseDate.i
        
        If ( Len(Str$) = 0 )
           HideGadget(DC::#Text_006,1)
           HideGadget(DC::#Text_007,1)
            ProcedureReturn ""
        Else
            HideGadget(DC::#Text_006,0)
            HideGadget(DC::#Text_007,0)
        EndIf                            
                
        Select Len(Str$)
            Case 0 To 3
                Startup::*LHGameDB\DateFormat = "%yyyy" 
            Case 4
                Startup::*LHGameDB\DateFormat = "%yyyy"
            Case 5
                Startup::*LHGameDB\DateFormat = "%yyyy"
                
            Case 6,7
                Startup::*LHGameDB\DateFormat = "%yyyy/%mm"                     
            Case 8
                Startup::*LHGameDB\DateFormat = "%yyyy/%mm"               
                
            Case 9,10
                Startup::*LHGameDB\DateFormat = "%yyyy/%mm/%dd"                                                
            Default
        EndSelect
        
        If ( Get = #False )
            Result = Change_Title_VerifyAscii(Str$)
            
            If ( Result = #True )  And ( Get = #False )
                Change_Title_VerifyDate(GetGadgetText(DC::#String_005))
                
                SetGadgetText(DC::#Calendar,Startup::*LHGameDB\DateFormat)
                
                ParseDate = ParseDate(Startup::*LHGameDB\DateFormat, GetGadgetText(DC::#String_005))                                
                SetGadgetState(DC::#Calendar,ParseDate)
                
                SetGadgetText(DC::#Text_007,  Str$)
            EndIf            
        EndIf    
                   
        
        If ( Get = #True )
                SetGadgetText(DC::#Calendar,Startup::*LHGameDB\DateFormat)
                
                ParseDate = ParseDate(Startup::*LHGameDB\DateFormat, Str$)
                SetGadgetState(DC::#Calendar,ParseDate)                                

                SetGadgetText(DC::#Text_007,  GetGadgetText(DC::#Calendar))
            ProcedureReturn Str$
        EndIf        
                
    EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure Database_Set_Release()
        Protected NewDate$
        
        HideGadget(DC::#Text_006,0)
        HideGadget(DC::#Text_007,0)            
        
        Startup::*LHGameDB\DateFormat = "%yyyy/%mm/%dd"
        SetGadgetText(DC::#Calendar,Startup::*LHGameDB\DateFormat)
        
        NewDate$ = Trim(GetGadgetText(DC::#Calendar))          
        SetGadgetText(DC::#String_005,NewDate$)
        SetGadgetText(DC::#Text_007,  NewDate$)
      
    EndProcedure        
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************        
    Procedure Database_Get_Emulator(id)

        
        Protected Rows.i,Str$,Cli$, PortID.i
         Rows = ExecSQL::CountRows(DC::#Database_001,"Programs")  
         
         If ( id <> 0 )
            For RowID = 1 To Rows                 
                
                
                PortID = ExecSQL::iRow(DC::#Database_001,"Programs","id",0,id,"",1)
                If ( PortID = id )
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Programs","Program_Description","",id,"",1)
                    Cli$ = ExecSQL::nRow(DC::#Database_001,"Programs","Args_Default","",id,"",1) 
                    Break;
                EndIf
            Next RowID        
         EndIf   
         
         SetGadgetText(DC::#String_006,Str$)  
         SetGadgetText(DC::#String_007,Cli$)  
    EndProcedure
    ;****************************************************************************************************************************************************************
    ;Wird in der Routine MainCode_StringCallBack ausgeführt
    ;****************************************************************************************************************************************************************   
    Procedure Database_Set_ProgramArgs(StringID.i)
        
        Protected id.i, szArgs.s, szText.s        
        ;
        ; Hole die Aktuelle ID unter dem Konfigurieten Program
        id = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","",Startup::*LHGameDB\GameID,"",1))         
        If ( id = 0 )
            ProcedureReturn 
        EndIf  
        
        ;
        ; Hole dazu das Aktuelle Argument (Konfiguration) aus der DB
        szArgs = ExecSQL::nRow(DC::#Database_001,"Programs","Args_Default","",id,"",1)
        
        ;
        ; Update
        szText = GetGadgetText(StringID)                       
        ExecSQL::UpdateRow( DC::#Database_001,"Programs", "Args_Default"   , szText,id) 
        
        Debug "Update: Database_Set_ProgramArgs() " + szText
         
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ;Wird in der Routine MainCode_StringCallBack ausgeführt
    ;****************************************************************************************************************************************************************   
    Procedure Database_Set_ProgramTitle(StringID.i)
        
        Protected id.i, szArgs.s, szText.s        
        ;
        ; Hole die Aktuelle ID unter dem Konfigurieten Program
        id = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","",Startup::*LHGameDB\GameID,"",1))
        If ( id = 0 )
            ProcedureReturn 
        EndIf    
        
        ;
        ; Hole dazu das Aktuelle Argument (Konfiguration) aus der DB
        szArgs = ExecSQL::nRow(DC::#Database_001,"Programs","Program_Description","",id,"",1)
        
        ;
        ; Update
        szText = GetGadgetText(StringID)                       
        ExecSQL::UpdateRow( DC::#Database_001,"Programs", "Program_Description"   , szText,id) 
        
        Debug "Update: Database_Set_ProgramTitle() " + StrszText
         
    EndProcedure     
    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
    Procedure Database_Set_Platform(str$)      
        
        If ( Len(Str$) >= 1 )
            HideGadget(DC::#Text_008,0)  
            SetGadgetText(DC::#String_004,Str$)
            SetGadgetText(DC::#Text_008,Str$)             
        Else
            HideGadget(DC::#Text_008,1)
            SetGadgetText(DC::#String_004,"")
        EndIf          
         
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure Database_Get_Platform(id)                
        Protected Rows.i,Str$, PlatFormID.i
        
         Rows = ExecSQL::CountRows(DC::#Database_001,"Platform")  
         
         If ( id <> 0 )
            For RowID = 1 To Rows                 
                
                PlatFormID = ExecSQL::iRow(DC::#Database_001,"Platform","id",0,id,"",1)                
                If ( PlatFormID = id )
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Platform","Platform","",id,"",1) 
                    Break;
                EndIf
            Next RowID        
        EndIf   
        Database_Set_Platform(str$)         
    EndProcedure      
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure Database_Get_Language(id)
        
        Protected Rows.i,Str$, LanguageID.i
         Rows = ExecSQL::CountRows(DC::#Database_001,"Language")  
         
         If ( id <> 0 )
            For RowID = 1 To Rows                 
                
                LanguageID = ExecSQL::iRow(DC::#Database_001,"Language","id",0,id,"",1) 
                If ( LanguageID = id )
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Language","Locale","",id,"",1)
                    Break
                EndIf
            Next RowID        
         EndIf   
         
         SetGadgetText(DC::#String_003,Str$)
     EndProcedure 
     
    ;****************************************************************************************************************************************************************
    ; Bezieht die Information von der aktuellen RowID
    ;**************************************************************************************************************************************************************** 
    Procedure Database_Get(RowID)
          
          Protected Str$, id.i
          If  ( RowID >= 1 )
                            
                ; GameTitle, setzte ein Bruch zwischen ":"
                ; 
              If (Startup::*LHGameDB\UpdateSection = -1) Or (Startup::*LHGameDB\UpdateSection = 1)
                  
                    ProcessEX::LHFreeMem()
                  
                    VEngine::Splitter_SetGet(#True)
                    
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","GameTitle","",RowID,"",1)                      
                    Database_Set_Title(Str$)
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","Release","",RowID,"",1) 
                    Str$ = Database_Get_Set_Release(Str$)
                    SetGadgetText(DC::#String_005,Str$)   
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",RowID,"",1)                      
                    SetGadgetText(DC::#String_008,Str$)                   
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev1","",RowID,"",1)                      
                    SetGadgetText(DC::#String_009,Str$)                     
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev2","",RowID,"",1)                      
                    SetGadgetText(DC::#String_010,Str$)                     
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev3","",RowID,"",1)                      
                    SetGadgetText(DC::#String_011,Str$)   
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev0","",RowID,"",1)                      
                    SetGadgetText(DC::#String_107,Str$)                   
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev1","",RowID,"",1)                      
                    SetGadgetText(DC::#String_108,Str$)                     
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev2","",RowID,"",1)                      
                    SetGadgetText(DC::#String_109,Str$)                     
                    
                    Str$ = ""
                    Str$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev3","",RowID,"",1)                      
                    SetGadgetText(DC::#String_110,Str$)                     
              EndIf
                              
              If (Startup::*LHGameDB\UpdateSection = -1) Or (Startup::*LHGameDB\UpdateSection = 2)              
                  id  = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","LanguageID","",RowID,"",1))
                  Database_Get_Language(id)
              EndIf
              
              If (Startup::*LHGameDB\UpdateSection = -1) Or (Startup::*LHGameDB\UpdateSection = 3)                
                  id = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PlatformID","",RowID,"",1))
                  Database_Get_Platform(id)
              EndIf   
                  
              If (Startup::*LHGameDB\UpdateSection = -1) Or (Startup::*LHGameDB\UpdateSection = 4)                
                  id = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","",RowID,"",1))
                  Database_Get_Emulator(id)
              EndIf
              
              ;
              ; Hole die Höhe und Breite des Jeweiligen "Spiels"
              Startup::*LHGameDB\wScreenShotGadget   = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsW",0,RowID,"",1)
              Startup::*LHGameDB\hScreenShotGadget   = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsH",0,RowID,"",1) 
              
              If ( Startup::*LHGameDB\wScreenShotGadget  = 0 )
                   Startup::*LHGameDB\wScreenShotGadget = 202
              EndIf
              If ( Startup::*LHGameDB\hScreenShotGadget  = 0 )
                   Startup::*LHGameDB\hScreenShotGadget = 142
              EndIf              
              
              ;
              ; Edit Info Window
              If IsWindow( DC::#_Window_006 )
                        vInfo::Window_Props_Save()                        
                        vInfo::Window_Reload()
                        vEngine::Text_GetDB()
              EndIf          
                  
                  
              ;
              ; Zeige Screenshots
              If ( Startup::*LHGameDB\bFirstBootUp = #False )
                vImages::Screens_SetThumbnails(4,4)             
                vImages::Screens_Show() 
              EndIf  
              
              ;
              ; Resete die Update Section. Siehe Modul Itemslist            
              Startup::*LHGameDB\UpdateSection = -1
              Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Routine Finished - Aktuelle ID " + Str(Startup::*LHGameDB\GameID))        
              
          EndIf    
      EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
      Procedure Database_Remove_DB(RemoveID.i)
            ExecSQL::DeleteRow(DC::#Database_001,"Gamebase",RemoveID)                          
            Delay(1)
            
            ExecSQL::DeleteRow(DC::#Database_002,"GameShot",RemoveID,"BaseGameID")
            Delay(1)
            
            ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1) 
            Delay(1)
     EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************          
    Procedure MarqueeTimer(*x.DELETE_ENTRIES)
        Protected BracketL$, BracketR$, SpaceLen$, item.i, RemoveID.i
        
            SetGadgetState(*x\GadgetListID,*x\MaxEntries)
        
            HideGadget(*x\GadgetListID,1)        
            HideGadget(*x\GadgetTextID,0)
            
            SetGadgetColor(*x\GadgetTextID, #PB_Gadget_BackColor, RGB(61,61,61))
            SetGadgetText(*x\GadgetTextID ,"[ ]")
            
            Delay(85)
            
            BracketL$ = "["
            BracketR$ = "]"
            SpaceLen$ = " " 
        
            For i = 0 To 26 Step 3
                SpaceLen$ = Space(i+1)
                SetGadgetText(*x\GadgetTextID,BracketL$ + SpaceLen$ + BracketR$): Delay(12)   
            Next    
        
            Delay(5)
            SetGadgetText(*x\GadgetTextID,BracketL$ + " " + "Lösche: #######" + " " + BracketR$)
            
            Startup::*LHGameDB\GameID = GetGadgetItemData(*x\GadgetListID,*x\MaxEntries-1)
            
            For item = *x\MaxEntries To *x\SafeItem Step -1                                              
                RemoveGadgetItem(*x\GadgetListID,item)                                
                SetGadgetState(*x\GadgetListID,item-1)
                
                RemoveID = Startup::*LHGameDB\GameID
                Startup::*LHGameDB\GameID = GetGadgetItemData(*x\GadgetListID,GetGadgetState(*x\GadgetListID))
        
                Database_Remove_DB(RemoveID.i)
                
                TextA$ = "Lösche: "
                TextB$ = Str(item)
                TextC$ = RSet(TextB$, 7 , "#")
                Delay(5)
                SetGadgetText(*x\GadgetTextID,BracketL$ + " " + TextA$ + TextC$ + " " + BracketR$)
                
                If ( CountGadgetItems(*x\GadgetListID) = 0 )
                    Break
                EndIf                                
            Next           
            
            Delay(85)
            SetGadgetText(*x\GadgetTextID,"[       Finished       ]")
            Delay(255)
            
            For i = 26 To 0 Step -5
                SpaceLen$ = Space(i+1)
                SetGadgetText(*x\GadgetTextID,BracketL$ + SpaceLen$ + BracketR$): Delay(9)   
            Next    
        
            Delay(5) 
            HideGadget(*x\GadgetTextID,1)
            HideGadget(*x\GadgetListID,0)
            
    EndProcedure         
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
     Procedure Database_Remove(SafeItems.i = 0, Special.i = #False)
         
        Protected RemoveID.i,  Liste.i =  DC::#ListIcon_001, MaxItems.i, CurrentPosition, Result.i, LocalThread.i, *LEER
        
        ;
        ; Wenn das Edit Fenster Aktiv ist, benutze nicht VK_Delete von der Liste
        If (Startup::*LHGameDB\Switch = 1)   
            ProcedureReturn
        EndIf
        
        ;
        ; Kein Einträge, Nichts zu tun        
        If Startup::*LHGameDB\GameID = 0
            ProcedureReturn
        EndIf
        
        ;
        ; Handhabung für den Menüeintrag buas auf ein Eintrag löschen
        If Special = #False
            Result = vItemTool::DialogRequest_3BT(Startup::*LHGameDB\TitleVersion,"Soll der Eintrag " + GetGadgetItemText(Liste,GetGadgetState(Liste)) + " gelöscht werden?")
        Else
            ; Für den Menü Eintrag um alle bis auf einen Eintrag löschen
            If ( CountGadgetItems(Liste) > SafeItems ) 
                Result = vItemTool::DialogRequest_Def(Startup::*LHGameDB\TitleVersion,"Sollen Alle Einträge bis auf den Ersten gelöscht werden?")
                If ( Result = #True ) 
                     Result = 2
                Else
                    ProcedureReturn 
                EndIf    
            Else
                ProcedureReturn
            EndIf
        EndIf
        
        If ( Result = #True ) 
            
            CurrentPosition = GetGadgetState(Liste)
                        
            Select CurrentPosition
                Case CountGadgetItems(Liste) - 1
                     CurrentPosition - 1
            EndSelect    
             
            RemoveGadgetItem(Liste,GetGadgetState(Liste)) 
            SetGadgetState(Liste,CurrentPosition)
                        
            RemoveID = Startup::*LHGameDB\GameID 
            Startup::*LHGameDB\GameID = GetGadgetItemData(Liste,GetGadgetState(Liste))
                        
            Database_Remove_DB(RemoveID.i)
            
            If ( CountGadgetItems(Liste) = 0 )
                Thread_LoadGameList_Action()
            Else    
                Database_Get(Startup::*LHGameDB\GameID)
            EndIf 
            vImages::Screens_Show()
            
        ElseIf ( Result = 2 ) 
                       
            *Delete.DELETE_ENTRIES = AllocateMemory(SizeOf(DELETE_ENTRIES))
            InitializeStructure(*Delete, DELETE_ENTRIES)
            
            *Delete\MaxEntries   = CountGadgetItems(Liste)
            *Delete\GadgetTextID = DC::#Text_003
            *Delete\GadgetListID = Liste
            *Delete\ItemEntries  = 0
            *Delete\SafeItem     = SafeItems
                             
            Debug "Lösche Alle Einträge: " + Str( *Delete\MaxEntries - SafeItems) 
            
            ButtonEX::Disable(DC::#Button_001, #True)            
            ButtonEX::Disable(DC::#Button_002, #True) 
            ButtonEX::Disable(DC::#Button_287, #True)
            ButtonEX::Disable(DC::#Button_010, #True)
            ButtonEX::Disable(DC::#Button_011, #True)
            ButtonEX::Disable(DC::#Button_012, #True)
            ButtonEX::Disable(DC::#Button_013, #True)                            
            ButtonEX::Disable(DC::#Button_014, #True)            
            ButtonEX::Disable(DC::#Button_016, #True)
           
            LocalThread = CreateThread(@MarqueeTimer(),*Delete)
            While IsThread(LocalThread)                           
                While WindowEvent()                                    
                Wend
            Wend 
                
            Debug "Lösche Alle Einträge:  - Fertig"
                         
            If ( CountGadgetItems(Liste) = 0 )
                Thread_LoadGameList_Action()
                 ButtonEX::Disable(DC::#Button_001, #False)            
                 ButtonEX::Disable(DC::#Button_002, #False) 
                 ButtonEX::Disable(DC::#Button_287, #False)                 
             Else
                 ButtonEX::Disable(DC::#Button_001, #False)            
                 ButtonEX::Disable(DC::#Button_002, #False) 
                 ButtonEX::Disable(DC::#Button_287, #False)                 
                 ButtonEX::Disable(DC::#Button_010, #False)
                 ButtonEX::Disable(DC::#Button_011, #False)
                 ButtonEX::Disable(DC::#Button_012, #False)
                 ButtonEX::Disable(DC::#Button_013, #False)                            
                 ButtonEX::Disable(DC::#Button_014, #False)            
                 ButtonEX::Disable(DC::#Button_016, #False)                 
                 Database_Get(Startup::*LHGameDB\GameID)
           EndIf
                
           vImages::Screens_Show()
           FreeMemory(*Delete)
        EndIf    
        
    EndProcedure
    ;
	;
	;
    Procedure vSys_MainButtonsConfig(state.i = #True)
    	
        ; Anzahl der Items in der DB Prüfen
        Protected Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
                
        Select Rows
            Case 0
            	
            	ButtonEX::Disable(DC::#Button_001, state)            
            	ButtonEX::Disable(DC::#Button_002, state) 
            	ButtonEX::Disable(DC::#Button_287, state)
            	ButtonEX::Disable(DC::#Button_010, state)
            	ButtonEX::Disable(DC::#Button_011, #True)
            	ButtonEX::Disable(DC::#Button_012, #True)
            	ButtonEX::Disable(DC::#Button_013, #True)                            
            	ButtonEX::Disable(DC::#Button_014, #True)            
            	ButtonEX::Disable(DC::#Button_016, #True)
            	
            Default
        
            	ButtonEX::Disable(DC::#Button_001, state)            
            	ButtonEX::Disable(DC::#Button_002, state) 
            	ButtonEX::Disable(DC::#Button_287, state)
            	ButtonEX::Disable(DC::#Button_010, state)
            	ButtonEX::Disable(DC::#Button_011, state)
            	ButtonEX::Disable(DC::#Button_012, state)
            	ButtonEX::Disable(DC::#Button_013, state)                            
            	ButtonEX::Disable(DC::#Button_014, state)            
            	ButtonEX::Disable(DC::#Button_016, state)
        
        EndSelect
            
    EndProcedure	
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
     Procedure ListIconBox_Get_InfoPosition()
         
         Protected LVM_GETITEMSPACE.i, LVM_PBSID = DC::#ListIcon_001, LVM_WINID = GadgetID(DC::#ListIcon_001)
         
         ;
         ; Höhe des Einzlenen Item
;          Startup::*LHGameDB\LBScItem\LVM_SPACE = SendMessage_(LVM_WINID, #LVM_GETITEMSPACING, #True, 0) >> 16
         
         ;
         ; Struktur Füllen die sich in der Config Befindet
;          Startup::*LHGameDB\LBScroll\cbSize = SizeOf(Startup::*LHGameDB\LBScroll)
;          Startup::*LHGameDB\LBScroll\fMask  = #SIF_ALL         
         
         ;
         ;
;          Startup::*LHGameDB\LBScItem\LVM_CITEM = GetGadgetState(DC::#ListIcon_001)
;          Startup::*LHGameDB\LBScItem\LVM_ITEMS = CountGadgetItems(DC::#ListIcon_001)         
         ;
         ; Information holen
;          GetScrollInfo_(LVM_WINID, #SB_VERT, Startup::*LHGameDB\LBScroll)
         
;          Debug "=============================================================================="            
;          Debug "(Maximum Position ) SCROLL\nMax      :" +Str(Startup::*LHGameDB\LBScroll\nMax)
;          Debug "(Minimum Position ) SCROLL\nMin      :" +Str(Startup::*LHGameDB\LBScroll\nMin)
;          Debug "(Sichtbare Items  ) SCROLL\nPage     :" +Str(Startup::*LHGameDB\LBScroll\nPage)
;          Debug "(Aktuelle Position) SCROLL\nPos      :" +Str(Startup::*LHGameDB\LBScroll\nPos)
;          Debug "(Track Position   ) SCROLL\nTrackPos :" +Str(Startup::*LHGameDB\LBScroll\nTrackPos) 
;          Debug "# GetGadgetState                     :" +Str(Startup::*LHGameDB\LBScItem\LVM_CITEM)
;          Debug "# CountGadgetItems                   :" +Str(Startup::*LHGameDB\LBScItem\LVM_ITEMS)
;          Debug "# Höhe x CountGadgetItems            :" +Str(Startup::*LHGameDB\LBScItem\LVM_SPACE * Startup::*LHGameDB\LBScItem\LVM_ITEMS)
;          Debug "# Höhe x GetGadgetState              :" +Str(Startup::*LHGameDB\LBScItem\LVM_SPACE * Startup::*LHGameDB\LBScItem\LVM_CITEM)
;          Debug "# Höhe x (Aktuelle Position)         :" +Str(Startup::*LHGameDB\LBScItem\LVM_SPACE * Startup::*LHGameDB\LBScroll\nPos)          
;          Debug "=============================================================================="    
         
     EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************            
     Procedure List_AutoSelect()                                 
     EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************      
    Procedure Thread_LoadGameList_Anim(SpaceLenght.i,TxtObject)
        Protected BracketL$, BracketR$, SpaceLen$
        
        If ( Startup::*LHGameDB\Anim_LodGameList = 0 )
            
            HideGadget(TxtObject,0)
        
            BracketL$ = "["
            BracketR$ = "]"
            SpaceLen$ = " "
        
            For i = 0 To SpaceLenght Step 3
                SpaceLen$ = Space(i+1)
                SetGadgetText(TxtObject,BracketL$ + SpaceLen$ + BracketR$): Delay(12)   
            Next    
        
            Delay(65)
                      
            Startup::*LHGameDB\Anim_LodGameList = 1
        EndIf
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure Thread_LoadGameList_NoItems()
        
        Protected TxtObject.i = DC::#Text_003, LstObject.i = DC::#ListIcon_001, Intro$ =  "[ No Items ]"
                                                                                           
         
         ;
         ; Verstecke die Liste
         HideGadget(LstObject,1): RemoveGadgetItem(LstObject,0)
         
         ;BaseCode::NoItemsInList() << NoCovers und Screenshots
         ;BaseForm::EnableGadgets(#True, 1, 0, 0, 1, 0,0,DC::#Button_001)
         
         ;
         ;Zeige Intro
         HideGadget(TxtObject,0)
         
         If ( Startup::*LHGameDB\BaseSVNMigrate = #True )
             Intro$ = "[ Update.. ]"
         EndIf
         
         SetGadgetColor(TxtObject, #PB_Gadget_BackColor, RGB(61,61,61)):SetGadgetText(TxtObject,"[ ]"): Delay(85): Thread_LoadGameList_Anim(10, TxtObject): SetGadgetText(TxtObject,Intro$)
         
         ; Entfernen der Einträge
         ;ClearDBObjects()          
     EndProcedure
     
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
     Procedure Thread_LoadGameList_GetItems(Rows.i)
         
         Protected TxtObject.i = DC::#Text_003, LstObject.i = DC::#ListIcon_001, RowID.i, Lnguage$, Pltform$, PrgDesc$
         
         ;
         ; Verstecke das Intro

         HideGadget(TxtObject,1)
         SetGadgetColor(TxtObject, #PB_Gadget_BackColor, RGB(71,71,71)): SetGadgetText(TxtObject,""): HideGadget(LstObject,0): Thread_LoadGameList_Anim(39,TxtObject):
         
         ;
         ; Database Stuff
         If ( ListSize(ExecSQL::_IOSQL()) >= 1 )             
             ;
             ; WICHTIG, RowID Liste Löschen
             ClearList(ExecSQL::_IOSQL())
             GadObjects_ClrRve()
         EndIf
         
         ExecSQL::lRows(DC::#Database_001,"Gamebase","GameTitle",1,Rows,ExecSQL::_IOSQL(),"GameTitle","asc")          
         ResetList(ExecSQL::_IOSQL())
         LockMutex(MainEventMutex)         
         
         SetGadgetText(DC::#Text_004, "Database: Count"):

         SendMessage_(GadgetID(DC::#ListIcon_001),#WM_SETREDRAW,0,0) 
         
         For RowID = 1 To Rows 
             
             SetGadgetText(DC::#Text_003,"[ LoadHigh " +Str(RowID)+ "/" +Str(Rows)+ " ]")
             SetWindowText_(WindowID(DC::#_Window_001), GetGadgetText(DC::#Text_003) )  
             
             NextElement(ExecSQL::_IOSQL()) 
             ;Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #SELECT LOOP: "+Str( ExecSQL::_IOSQL()\nRowID) ) 
             Select ExecSQL::_IOSQL()\nRowID
                     
                 Case Startup::*LHGameDB\GameID
                     ;
                     ; Hole die GameID über die Auflistung der ListIconBox raus
                     ;                         
                     If ( RowID = 1 )
                         Startup::*LHGameDB\GameLS = 0
                     Else                      
                         Startup::*LHGameDB\GameLS = RowID                     
                     EndIf                      
                 Default    
             EndSelect                      

             ; Fügt den Inhalt und in den Data die RowID hinzu             
             ;    
             GameTitle1$ = ""
             GameTitle1$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","GameTitle","",ExecSQL::_IOSQL()\nRowID,"",1) 
             
            ;
            ; Hole weitere Infos
             id  = Val(ExecSQL::nRow(DC::#Database_001 ,"Gamebase","LanguageID","",ExecSQL::_IOSQL()\nRowID,"",1))
             Lnguage$ = ""
             If ( id <> 0 )
                Lnguage$ = ExecSQL::nRow(DC::#Database_001,"Language","Locale"    ,"",id,"",1) 
             EndIf
            
             id  = Val(ExecSQL::nRow(DC::#Database_001 ,"Gamebase","PlatformID","",ExecSQL::_IOSQL()\nRowID,"",1))
             Pltform$ = ""
             If ( id <> 0 )             
                 Pltform$ = ExecSQL::nRow(DC::#Database_001,"Platform","Platform"  ,"",id,"",1)
             EndIf
                         
             id  = Val(ExecSQL::nRow(DC::#Database_001 ,"Gamebase","PortID"    ,"",ExecSQL::_IOSQL()\nRowID,"",1))
             PrgDesc$ = ""
             If ( id <> 0 )              
                 PrgDesc$ = ExecSQL::nRow(DC::#Database_001,"Programs","ExShort_Name","",id,"",1)
             EndIf
             
             
             ReleaseYear.s = ExecSQL::nRow(DC::#Database_001,"Gamebase","Release","",ExecSQL::_IOSQL()\nRowID,"",1) 
             
             If ( Startup::*LHGameDB\SortMode = 5)
             	Startup::*LHGameDB\SortXtendMode = #True
             	
             	ButtonEx::Settext(DC::#Button_028, 0, "Release")             	
             	ButtonEx::Settext(DC::#Button_028, 1, "Release")
             	
             	AddGadgetItem(LstObject,-1,GameTitle1$ + Chr(10) + Pltform$ + Chr(10) + Lnguage$ + Chr(10) +LSet(ReleaseYear,10, Chr(32)))             	
             Else             	
             	Startup::*LHGameDB\SortXtendMode = #False             	
             	ButtonEx::Settext(DC::#Button_028, 0, "Program")             	
             	ButtonEx::Settext(DC::#Button_028, 1, "Program")               	
             	
             	AddGadgetItem(LstObject,-1,GameTitle1$ + Chr(10) + Pltform$ + Chr(10) + Lnguage$ + Chr(10) +PrgDesc$)
             EndIf	
                          
             SetGadgetItemData(LstObject,RowID ,ExecSQL::_IOSQL()\nRowID) 
             Thread_HTTP_MAME_Roms_DoEvents() 
         Next RowID
         
         SendMessage_(GadgetID(DC::#ListIcon_001),#WM_SETREDRAW,1,0) 
         UnlockMutex(MainEventMutex)          
         
         HideGadget(TxtObject,1): HideGadget(LstObject,0): RemoveGadgetItem(LstObject,0)
         
         SetWindowText_(WindowID(DC::#_Window_001), Startup::*LHGameDB\TrayIconTitle)  
     EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
     Procedure Thread_LoadGameList_SelectItem()
         Protected LbItemH.i
         ; 
         ; TODO:
         ; Muss überarbeitet Werden
                 
         ItemHIGH = SendMessage_(GadgetID(DC::#ListIcon_001), #LVM_GETITEMSPACING, #True, 0) >> 16  ; only need to do this once                  

        
        Select Startup::*LHGameDB\GameLS
            Case 0,1
                SetGadgetState(DC::#ListIcon_001,Startup::*LHGameDB\GameLS)
                
            Default 
                SendMessage_(GadgetID(DC::#ListIcon_001),#WM_VSCROLL,#SB_TOP,0)             
                SendMessage_(GadgetID(DC::#ListIcon_001),#LVM_ENSUREVISIBLE,Startup::*LHGameDB\GameLS-1,1)
                
                If Startup::*LHGameDB\GameLS-1 > SendMessage_(GadgetID(DC::#ListIcon_001),#LVM_GETCOUNTPERPAGE,0,0)-1
                    SendMessage_(GadgetID(DC::#ListIcon_001),#WM_VSCROLL,#SB_PAGEDOWN,0)                
                    SendMessage_(GadgetID(DC::#ListIcon_001),#WM_VSCROLL,#SB_LINEUP,0)
                EndIf   
                SetGadgetItemState(DC::#ListIcon_001,Startup::*LHGameDB\GameLS-1,#PB_ListIcon_Selected)                 
        EndSelect       
                
        SetActiveGadget(DC::#ListIcon_001)                         
        Database_Get(GetGadgetItemData(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001)))
                
     EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure Thread_LoadGameList(t)
        
        Protected Rows.i = 0
        
        ;
        ; Resette/Clear Gadget Obejcts
        ;
        GadObjects_ClrRve()
        
        ;SendMessage_(GadgetID(DC::#ListIcon_001),#WM_SETREDRAW,0,0)
        
        ;
        ;
        ; Initialisiere das Listicon
        ClearGadgetItems(DC::#ListIcon_001) 
        AddGadgetItem(DC::#ListIcon_001, 0, "                           "): SetGadgetItemData(DC::#ListIcon_001, 0, 0)                       
          
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
                
        Select Rows
            Case 0
                ;
                ; Keine Einträge, setze die GameID und den Listbox State Selector auf 0
                ;
                Startup::*LHGameDB\GameID = 0
                Startup::*LHGameDB\GameLS = 0                
                Thread_LoadGameList_NoItems()
            Default
            	vSys_MainButtonsConfig()
                ;
                ;
                ; Liste Einträge Auf
            	Thread_LoadGameList_GetItems(Rows.i)                
            	vSys_MainButtonsConfig(#False)
                Thread_LoadGameList_SelectItem()
        
        EndSelect      
        ;SendMessage_(GadgetID(DC::#ListIcon_001),#WM_SETREDRAW,1,0)  
         ;        
         ;
         ; DONT FORGET

        ;ListIconBox_Get_InfoPosition()       
     
        ;
        ;
        ; Schliesse Datenbank
;         If DB_Create::DB_IsOpen(DC::#Database_001)
;             ExecSQL::CloseDB(DC::#Database_001,Startup::*LHGameDB\Base_Game)                         ;* 
;         EndIf         
    EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************
    Procedure Thread_LoadGameList_Action()
        Protected ActionThread.i
        ActionThread = CreateThread(@Thread_LoadGameList(),0)  
        
        ;Delay(25)
        ThreadPriority(ActionThread, 31) 
        
        While IsThread(ActionThread)
                           
            While WindowEvent()                                    
            Wend
        Wend 
        SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,1)
        SetActiveGadget(DC::#ListIcon_001)
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************  
    Procedure ListBox_GetData_KeyBoard(KeyPressed.i)
        
        Debug "Keypressed" + Str( KeyPressed)
        
        Select KeyPressed
            Case 38; Hoch
                SetGadgetItemState(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001) -1,#PB_ListIcon_Selected )
                
            Case 40; Runter
                SetGadgetItemState(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001) +1,#PB_ListIcon_Selected )
        EndSelect        
        
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************      
    Procedure ListBox_GetData_LeftMouse(ForceUpdate = #False)
        Protected DebugText$, DebugLSRowID.i, DebugLSBoxID.i, ListTextID.s, ListGameID.i
        Debug__Text$ = GetGadgetItemText(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001))
        DebugLSRowID = GetGadgetItemData(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001))
        DebugLSBoxID = GetGadgetState(DC::#ListIcon_001)                
        
        If ( DebugLSBoxID = -1 )
            ;
            ; Kein Eintrag Selektiert
            ProcedureReturn
        EndIf    
        
        ListTextID = GetGadgetItemText(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001))
        ListGameID = GetGadgetItemData(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001))
        Startup::*LHGameDB\GameLS = DebugLSBoxID
        
        ;
        ; Neue Id Wählen falls tatasächlich eine Neue ID ausgewählt wird
        If ( Startup::*LHGameDB\GameID <> ListGameID )
            
            ;             Debug "=============================================================================="
            ;             Debug "Linksklick: " + Debug__Text$
            ;             Debug "Row ID    : " + Str(DebugLSRowID)
            ;             Debug "Lst ID    : " + Str(DebugLSBoxID)
            ;             Debug "ITM HH    : " + Str(Startup::*LHGameDB\ItemSelectHeight)            
            ;             Debug "==============================================================================" + Chr(13) 
            
             Startup::*LHGameDB\GameID = ListGameID
        
            ;
            ; Öffne die Datenbank
           ; ExecSQL::OpenDB(DC::#Database_001,Startup::*LHGameDB\Base_Game)
            ;
            ;
            ; Hole den Stuff
;             If DB_Create::DB_IsOpen(DC::#Database_001)
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1)        ;*
                
                ;
                ; Information aus der DB holen
                Database_Get(Startup::*LHGameDB\GameID)
                
                ; Nach dem Update wieder schliessen
;                 ExecSQL::CloseDB(DC::#Database_001,Startup::*LHGameDB\Base_Game) 
;             EndIf
        Else
            ;
            ; Nach dem man Einstellungen vorgenommen hat
            If ( ForceUpdate = #True )
                Database_Get(Startup::*LHGameDB\GameID)
            EndIf    
;             Debug "============================================================SELBE ID=========="
;             Debug "Linksklick: " + Debug__Text$
;             Debug "Row ID    : " + Str(DebugLSRowID)
;             Debug "Lst ID    : " + Str(DebugLSBoxID)
;             Debug "ITM HH    : " + Str(Startup::*LHGameDB\ItemSelectHeight)
;             Debug "==============================================================================" + Chr(13)             
        EndIf
        
        ListIconBox_Get_InfoPosition()
        
        ;List_AutoSelect()
        SetActiveGadget(DC::#ListIcon_001)
    EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************      
    Procedure Thread_LoadGameList_Sort(Save.i = -1)
       
        Select Save
                ;
                ; Sicher beim Beenden die Sortierungs ID
                ;
            Case #True
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SortOrder", Str(Startup::*LHGameDB\SortMode),1)                  
                ; Hole die Sortierungs ID aus der DB                
                ;
            Case #False
                Startup::*LHGameDB\SortMode =  ExecSQL::iRow(DC::#Database_001,"Settings","SortOrder",0,1,"",1)
            Default 
            		;
								;
								; Wir haben nur 4 Spalten (0 - 3)
            		Protected Column.i = Startup::*LHGameDB\SortMode
            		
            		If Column > 3
            			Column = 3
            		EndIf
            		
                LVSORTEX::ListIconSortSetCol(DC::#ListIcon_001,Column)          
                LVSORTEX::ListIconSortListe(DC::#ListIcon_001,0)  
                SetActiveGadget(DC::#ListIcon_001)
        EndSelect        

    EndProcedure
    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************       
    Procedure Switcher_Pres_List(Obj.i)
        Select Obj
            Case DC::#Button_010, DC::#Button_013
                
                ;
                ; Edit Info Window
                If IsWindow( DC::#_Window_006 )
                    HideWindow( DC::#_Window_006, 1)
                    SetActiveWindow( DC::#_Window_001)
                EndIf 
              
                SetActiveGadget(-1)
                Startup::*LHGameDB\Switch = 1 ;Edit Aktiv
                
                HideGadget(DC::#Contain_06,0) ;Container: Edit 
                HideGadget(DC::#Contain_07,0) ;Container: Button Edit               
                HideGadget(DC::#Contain_02,1) ;Container: Liste
                HideGadget(DC::#Contain_03,1) ;Container: Button Liste
                HideGadget(DC::#Contain_09,1) ;Container: Button Liste
                HideGadget(DC::#Contain_10,1) ;Container: Screens 
                HideGadget(DC::#Splitter1,1)  ; Der Splitter                
                SetActiveGadget(DC::#Contain_06)            
                SetWindowText_(WindowID(DC::#_Window_001), "(Edit Mode) " + Startup::*LHGameDB\TrayIconTitle)                                
                
            Case DC::#Button_023, DC::#Button_024
                ;
                ; Edit Info Window
                If IsWindow( DC::#_Window_006 )
                    HideWindow( DC::#_Window_006, 0)
                    SetForegroundWindow_( WindowID( DC::#_Window_001) )
                EndIf 
                
                SetActiveGadget(-1)
                Startup::*LHGameDB\Switch = 0 ;Listbox Aktiv               
              
                HideGadget(DC::#Contain_06,1) ;Container: Edit 
                HideGadget(DC::#Contain_07,1) ;Container: Button Edit               
                HideGadget(DC::#Contain_02,0) ;Container: Liste
                HideGadget(DC::#Contain_03,0) ;Container: Button Liste
                HideGadget(DC::#Contain_09,0) ;Container: Button Liste
                HideGadget(DC::#Contain_10,0) ;Container: Screens 
                HideGadget(DC::#Splitter1,0)  ; Der Splitter                
                SetActiveGadget(DC::#ListIcon_001) 
                SetWindowText_(WindowID(DC::#_Window_001), Startup::*LHGameDB\TrayIconTitle)  
                                
        EndSelect        
    EndProcedure        
    
    Procedure Switcher_Pres_NoItems()
        Protected szMemDate.i, szMemSysm.i, szMemLang.i, szMemFile.i
        Structure SZDATE
            c.a[20]
        EndStructure 
                
        Structure SZSYSM
            c.a[30]
        EndStructure 
        
        Structure SZLANG
            c.a[14]
        EndStructure          
        
        Structure SZFILE
            c.a[30]
        EndStructure   
        
        Protected  *szMemDate.SZDATE,*szMemSysm.SZSYSM,*szMemLang.SZLANG,*szMemFile.SZFILE

        *szMemDate = AllocateMemory(20) 
        *szMemSysm = AllocateMemory(30)        
        *szMemLang = AllocateMemory(14)         
        *szMemFile = AllocateMemory(30)
      
        ;
        ; Alternativ Text für die Sprache System
        ;szMemLang = AllocateMemory(7)
        PokeS(*szMemLang, "English", -1, #PB_Unicode)           
        ;
        ; Alternativ Text für  das System
        ;szMemSysm = AllocateMemory(26):
        PokeS(*szMemSysm, "PC Windows/ DOS", -1, #PB_Unicode)        
        ;
        ; Alternativ Text fürs Datum         
        ;szMemDate = AllocateMemory(10)
        PokeS(*szMemDate, "2000/01/01", -1, #PB_Unicode)
        ;
        ; Alternativ Text Für die ZusatzDatei
        ;szMemFile = AllocateMemory(100)
        PokeS(*szMemFile, "Optional File", -1, #PB_Unicode)        
        ;
        
        
        If ( GetGadgetState(DC::#ListIcon_001) = -1 )
            If ( Startup::*LHGameDB\SwitchNoItems = -1 )
                
                If ( CountGadgetItems(DC::#ListIcon_001) = 0 )
                    ButtonEX::Disable(DC::#Button_010, #False)
                EndIf
                
                ProcedureReturn -1
            Else    
                ButtonEX::Disable(DC::#Button_010, #True)
                ButtonEX::Disable(DC::#Button_011, #True)
                ButtonEX::Disable(DC::#Button_012, #True)
                ButtonEX::Disable(DC::#Button_013, #True)                            
                ButtonEX::Disable(DC::#Button_014, #True)            
                ButtonEX::Disable(DC::#Button_016, #True)
                
                If ( CountGadgetItems(DC::#ListIcon_001) = 0 )
                    ButtonEX::Disable(DC::#Button_010, #False)
                EndIf
                
                Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE: " + Str(#PB_Compiler_Line) + "- Buttons Disabled") 
                FreeMemory(*szMemLang)
                FreeMemory(*szMemSysm)
                FreeMemory(*szMemDate)
                FreeMemory(*szMemFile)                
                ProcedureReturn -1
            EndIf    
            
        Else
            
            If ( Startup::*LHGameDB\SwitchNoItems = 1 )    
                ProcedureReturn 1
            Else            
                ButtonEX::Disable(DC::#Button_010, #False)
                ButtonEX::Disable(DC::#Button_011, #False)
                ButtonEX::Disable(DC::#Button_012, #False)
                ButtonEX::Disable(DC::#Button_013, #False)            
                ButtonEX::Disable(DC::#Button_014, #False)
                ButtonEX::Disable(DC::#Button_016, #False)
                Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE: " + Str(#PB_Compiler_Line) + "- Buttons Enabled")
                
                SendMessage_(GadgetID(DC::#String_003), #EM_SETCUEBANNER, 0, *szMemLang)                 
                SendMessage_(GadgetID(DC::#String_004), #EM_SETCUEBANNER, 0, *szMemSysm)                   
                SendMessage_(GadgetID(DC::#String_005), #EM_SETCUEBANNER, 0, *szMemDate)
                SendMessage_(GadgetID(DC::#String_107), #EM_SETCUEBANNER, 0, *szMemFile) 
                SendMessage_(GadgetID(DC::#String_108), #EM_SETCUEBANNER, 0, *szMemFile)                
                SendMessage_(GadgetID(DC::#String_109), #EM_SETCUEBANNER, 0, *szMemFile)                
                SendMessage_(GadgetID(DC::#String_110), #EM_SETCUEBANNER, 0, *szMemFile)                
                
                FreeMemory(*szMemFile) 
                FreeMemory(*szMemLang)
                FreeMemory(*szMemSysm)
                FreeMemory(*szMemDate)
                
								If Len(GetGadgetText(DC::#String_008) ) = 0
										*szMemFile1 = AllocateMemory(256)
										PokeS(*szMemFile1, "<Media/ Image/ Rom/ Cart/ Iso 1 ( Doppelklick Öffnet Auswahl Fenster )>", -1, #PB_Unicode) 
										SendMessage_(GadgetID(DC::#String_008), #EM_SETCUEBANNER, 0, *szMemFile1)
										FreeMemory(*szMemFile1)  
								EndIf
				
								If Len(GetGadgetText(DC::#String_009) ) = 0
										*szMemFile2 = AllocateMemory(256)
										PokeS(*szMemFile2, "<Media/ Image/ Rom/ Cart/ Iso 2 ( Doppelklick Öffnet Auswahl Fenster )>", -1, #PB_Unicode) 							
										SendMessage_(GadgetID(DC::#String_009), #EM_SETCUEBANNER, 0, *szMemFile2)
										FreeMemory(*szMemFile2) 							
								EndIf							
					
								If Len(GetGadgetText(DC::#String_010) ) = 0	
										*szMemFile3 = AllocateMemory(256)
										PokeS(*szMemFile3, "<Media/ Image/ Rom/ Cart/ Iso 3 ( Doppelklick Öffnet Auswahl Fenster )>", -1, #PB_Unicode) 							
										SendMessage_(GadgetID(DC::#String_010), #EM_SETCUEBANNER, 0, *szMemFile3) 								
										FreeMemory(*szMemFile3) 							
								EndIf							
							
								If Len(GetGadgetText(DC::#String_011) ) = 0	
										*szMemFile4 = AllocateMemory(256)
										PokeS(*szMemFile4, "<Media/ Image/ Rom/ Cart/ Iso 4 ( Doppelklick Öffnet Auswahl Fenster )>", -1, #PB_Unicode) 							
										SendMessage_(GadgetID(DC::#String_011), #EM_SETCUEBANNER, 0, *szMemFile4)							
										FreeMemory(*szMemFile4) 							
								EndIf                
                

                                
                ProcedureReturn  1
            EndIf    
        EndIf
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************  
    Procedure.s Getfile_Portbale_ModeOut(TestFile$)
        
        
        Protected OptOUT$ = "..\", OptIN$ = ".\", CharsCountOut.i, CharsCountIn.i, ReplaceShortChars = #False, ShortChar$ = "", sMaxChars.i, sMaxList
                  
            ;
        ; Datei normal Testeb ob sie vorhanden
        ;If ( FileSize( TestFile$ ) >= 1 )
        ;    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #File Out SIZE: " + Chr(13) + TestFile$ + "::SIZE: " + Str(FileSize( TestFile$ ) ))
        ;Else           
                                     
        ;
        ; Prüfen auf den Verkürzten Pfad namen (Ausserhalb des Verzeichniss)
        CharsCountOut = CountString(TestFile$,OptOUT$)
        
        If ( CharsCountOut >= 1 )
            ReplaceShortChars = #True: ShortChar$ = OptOUT$: sMaxChars = CharsCountOut
        Else
            CharsCountIn  = CountString(TestFile$,OptIN$)                         
            If ( CharsCountIn  >= 1 )
                ReplaceShortChars = #True: ShortChar$ = OptIN$ : sMaxChars = CharsCountIn
                If ( CharsCountIn = 1 )
                    TestFile$ = ReplaceString(TestFile$,ShortChar$,"",0,1,sMaxChars)
                    ReplaceShortChars = #False
                EndIf    
            EndIf                    
        EndIf    
        
        If ( ReplaceShortChars = #True )
            NewList SourceParts.s()
            ;
            ; Splitte den Source Path und Vergleiche diesen
            FFH::PathPartsExt(Startup::*LHGameDB\PortablePath, SourceParts())                        
            
            ResetList( SourceParts() ):
            sMaxList = ListSize(SourceParts())
                     
            
            SString$ = ""
            For  Index = 0 To sMaxChars -1
                  
                If ( SelectElement( SourceParts(),Index) <> 0)
                    SString$ = SString$ + SourceParts()
                EndIf    
            Next Index    
            
            TestFile$ = ReplaceString(TestFile$,ShortChar$,"",0,1,sMaxChars)
            TestFile$ = SString$ + TestFile$
            
            Select FileSize(TestFile$)
                Case 0,-1
                Case -2                                
                    ;If ( Right(TestFile$, 1) <> "\" ) 
                        ;TestFile$ + "\"
                        ;TestFile$ = Left(TestFile$, Len(TestFile$) - 1) 
                    ;EndIf
                Default
            EndSelect                               
        EndIf                   
        
        If ( ReplaceShortChars = #False )
            ;
            ; Prüfen wir den pfad obe dieser auf das programm Verzeichnis zeigt
            Select FileSize( Startup::*LHGameDB\PortablePath + TestFile$ )
                Case 0
                Case -1
                Case -2
                    TestFile$ = Startup::*LHGameDB\PortablePath + TestFile$
                    ProcedureReturn TestFile$
                Default
                    TestFile$ = Startup::*LHGameDB\PortablePath + TestFile$
                    ProcedureReturn TestFile$
            EndSelect 
            
            ;
            ; Prüfen wir den pfad ob gan wonders liegt            
            Select FileSize( TestFile$ )
                Case 0                    
                Case -1
                Case -2
                    ProcedureReturn TestFile$
                Default
                    ProcedureReturn TestFile$
            EndSelect             
        EndIf
        ;EndIf        
        
        ;Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #File Out: " + Chr(13) + TestFile$)
        ProcedureReturn TestFile$        
    EndProcedure
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************     
    Procedure.s Getfile_Portbale_ModeIn(TestFile$)
        
        Protected sMaxList.i, dMaxList.i, Index.i, MaxIndex.i, SString$, DString$, CompareBaseP$ = "", CompareResult.i
        Protected OrigSourcePath$, OrigDestinPath$, OrigDestinFile$, OptDIR$, OptIn = #False, OptOut = #False 
        
        If (TestFile$)
            NewList SourceParts.s()
            NewList Destn_Parts.s()
            ; 
            ; Original Path. Nicht kleingesschrieben
            
            OrigSourcePath$ = Startup::*LHGameDB\PortablePath
            OrigDestinPath$ = GetPathPart(TestFile$)
            OrigDestinFile$ = GetFilePart(TestFile$)
            
            If ( OrigSourcePath$ = OrigDestinPath$ )
                ; Beide Pfade sind von anfang an identisch
                ; Übernehmen wir so
                OrigDestinPath$ = ReplaceString(OrigDestinPath$,OrigSourcePath$,"",0,1,1)
                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #File In: " + Chr(13) + OrigDestinPath$ + OrigDestinFile$)
                ProcedureReturn OrigDestinPath$ + OrigDestinFile$
            EndIf
            
            ;
            ; Splitte den Source Path und Vergleiche diesen
            FFH::PathPartsExt(OrigSourcePath$, SourceParts())
            FFH::PathPartsExt(OrigDestinPath$, Destn_Parts())        
            
            ResetList( SourceParts() ): ResetList( Destn_Parts() )
            
            sMaxList = ListSize(SourceParts())
            dMaxList = ListSize(Destn_Parts())
            
            If ( sMaxList > dMaxList )
                ;
                ; Source Pfad ist grösser als der Destinations Pfad                
                 MaxIndex = dMaxList
            ElseIf ( sMaxList < dMaxList )
                ;
                ; Destinations Pfad ist grösser als der Source Pfad                
                 MaxIndex = sMaxList                
            ElseIf ( sMaxList = dMaxList )
                ;
                ; Destinations Pfad ist gleich gross wie der Source Pfad                 
                 MaxIndex = sMaxList                 
            EndIf    
            
            For Index = 0 To MaxIndex -1
                SelectElement( SourceParts(),Index)
                SelectElement( Destn_Parts(),Index)
                
                SString$ = SourceParts()
                DString$ = Destn_Parts()
                If ( SString$ <> DString$ )
                    Break;
                EndIf    
                    
                If ( SString$ = DString$ )
                    
                    CompareResult + 1
                    CompareBaseP$ + DString$
                    
                    If ( CompareBaseP$ = Startup::*LHGameDB\PortablePath )
                        ;
                        ; Der Programm Path ist gleich
                        OptIn = #True
                        Break;
                    EndIf    
                    
                    If (Index = MaxIndex -1)
                        ;
                        ;Liegt ausserhalb des Programms Verzeichnisses
                        OptOut = #True
                        Break
                    EndIf 
                    
                    If ( CompareResult = 0 And Index = 0 )
                        ;
                        ; Die Root Laufwerke sind anders, break schon mal hier dsurchführen
                        Break;
                    EndIf    
                EndIf                                
            Next
            
            ;
            ; Liste Löschen
            ClearList( Destn_Parts() )  
            ;
            ; Pfad splitten anhand des ORIGINALEN Pfad
            FFH::PathPartsExt(OrigDestinPath$ , Destn_Parts()): ResetList( Destn_Parts() )
            
            If ( CompareResult >= 1 )
                
                OptDIR$ = "..\": CreateInsidePath = #False
                If      ( sMaxList > dMaxList ) And ( OptOut = #True ): OptDIR$ = "..\"                                                            
                    ;
                    ; Ziel befindet sich im Verzeichnis wo auch die Datenbank ist                    
                ElseIf  ( sMaxList < dMaxList ) And ( OptIn  = #True ): OptDIR$ = ".\"
                    
                    CompareResult - 1
                    
                    For Index = 0 To CompareResult
                        
                        SelectElement( Destn_Parts(),Index)
                        
                        If ( CompareResult = Index )
                            OrigDestinPath$ = ReplaceString(OrigDestinPath$,Destn_Parts(),OptDIR$,0,1,1)
                        Else
                            OrigDestinPath$ = ReplaceString(OrigDestinPath$,Destn_Parts(),"",0,1,1)
                        EndIf    
                    Next  
                    
                    CreateInsidePath = #True
                    ;
                    ; Ziel befindet sich ausserhalb des Verzeichnis auf der selben Platte                   
                EndIf    
                
                If ( CreateInsidePath = #False )
                    For Index = 0 To CompareResult -1
                        SelectElement( Destn_Parts(),Index)
                        OrigDestinPath$ = ReplaceString(OrigDestinPath$,Destn_Parts(),OptDIR$,0,1,1)
                    Next Index                      
                EndIf
            EndIf
            
            Startup::*LHGameDB\PortablePath = OrigSourcePath$
            TestFile$ = OrigDestinPath$ + OrigDestinFile$ 
        EndIf  
        
         Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #File In: " + Chr(13) + TestFile$)
        ProcedureReturn TestFile$
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************     
    Procedure.s GetFile_Selector(DPGadgetID)
            SourcePath$ = GetPathPart( GetGadgetText(DPGadgetID) )
            If ( SourcePath$ = "" )
                SourcePath$ = Startup::*LHGameDB\PortablePath
            Else
                SourcePath$ = Getfile_Portbale_ModeOut(SourcePath$)
            EndIf 
            ProcedureReturn SourcePath$
     EndProcedure      
    ;****************************************************************************************************************************************************************
    ;
    ;**************************************************************************************************************************************************************** 
    Procedure GetFile_Programm(DPGadgetID.i, FileStream.s = "")    
        Protected TestFile$, TestPath$, TestSize.i,Title$,Char$, Endung$, Current$
        
        SetActiveGadget(-1)

        ;
        ; Procedure Aktiviert, aber nicht durch Drag'nDrop
        If ( FileStream = "" )
            Select DPGadgetID
                    
                    ;
                    ; Gadget um EINE datie auszuwählen
                Case DC::#String_101     
                    ;
                    ; Pfad aus dem Gadget Entnehmen
                    TestPath$  = GetFile_Selector(DPGadgetID)
                    
                    If ( Len( GetGadgetText( DPGadgetID ) ) > 0 )
                        TestPath$ = GetGadgetText(DPGadgetID)
                        TestPath$ = Getfile_Portbale_ModeOut( TestPath$ )
                        Current$  + GetFilePart(TestPath$,1) + "|"+ GetFilePart(TestPath$,1) +"."+ GetExtensionPart( TestPath$ ) +"|"
                    EndIf 
                    
                    ; Generate Suffix
                    ;                   
                    Endung$  + "Filter: Programm (*.exe)|*.exe|"
                    If (Current$)
                        Endung$  + "Filter: " + Current$
                    EndIf    
                    Endung$  + "Filter: IconLink (*.lnk)|*.lnk|"
                    Endung$  + "Filter: BatchDatei (*.bat)|*.bat|"
                    Endung$  + "Filter: BatchDatei (*.cmd)|*.cmd|"                      
                    Endung$  + "Filter: Java App (*.jar)|*.jar;"
                    
                    FileStream = FFH::GetFilePBRQ("Program",TestPath$, #False, Endung$, 0, #False)
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream: "+FileStream)
                    ;
                    ; Gadgets um Verzeichnissw Auszuwählen
                Case DC::#String_102
                    
                    If ( Len( GetGadgetText( DPGadgetID ) ) > 0 )
                        TestPath$ = GetGadgetText(DPGadgetID)
                        TestPath$ = Getfile_Portbale_ModeOut( TestPath$ )
                    EndIf 
                    
                    TestPath$  = GetFile_Selector(DPGadgetID)
                    FileStream = FFH::GetPathPBRQ("ArbeitsPfad Auswählen",TestPath$)
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream: "+FileStream)
            EndSelect            
        EndIf
                    
        ;
        ; Datei oder Path ?
        TestSize = FileSize(FileStream)
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream Size: "+Str(TestSize))
        Select TestSize
                ;
                ; Nicht gefunden, das sollte NIE vorkommen beim auswählen
            Case -1
                SetActiveGadget(DC::#ListIcon_002): ProcedureReturn

                
                ;
                ; Verzeichnis / Arbeits Pfad               
            Case -2
                TestPath$ = Getfile_Portbale_ModeIn(FileStream)
                SetGadgetText(DC::#String_102 , TestPath$)               
                ;
                ;
            Default              
               TestFile$ = GetFilePart(FileStream)
               TestPath$ = GetPathPart(FileStream) 
               TestPath$ = Getfile_Portbale_ModeIn(TestPath$)  
               
               SetGadgetText(DC::#String_101, TestPath$ + TestFile$)
               SetGadgetText(DC::#String_102, TestPath$)
               
               Title$ = GetFilePart(FileStream,#PB_FileSystem_NoExtension)
               Char$  = UCase(Left(Title$,1))
               Title$ = Char$ + Mid(Title$,2,Len(Title$)-1)
               SetGadgetText(DC::#String_104, Title$)
        EndSelect                
    EndProcedure        
    
    ;****************************************************************************************************************************************************************
    ;
    ;**************************************************************************************************************************************************************** 
    Procedure GetFile_Programm_64(DPGadgetID.i, FileStream.s = "")    
        Protected TestFile$, TestPath$, TestSize.i,Title$,Char$
        
        SetActiveGadget(-1)

        ;
        ; Procedure Aktiviert, aber nicht durch Drag'nDrop
        If ( FileStream = "" )
            Select DPGadgetID
                    
                    ;
                    ; Gadget um EINE datie auszuwählen
                Case DC::#String_101     
                    ;
                    ; Pfad aus dem Gadget Entnehmen
                    TestPath$  = GetFile_Selector(DPGadgetID)
                    If ( Len( GetGadgetText( DPGadgetID ) ) > 0 )
                        TestPath$ = GetGadgetText(DPGadgetID)
                        TestPath$ = Getfile_Portbale_ModeOut( TestPath$ )
                    EndIf 
                    
                    FileStream = FFH::GetFilePBRQ("Program",TestPath$, #False, "(C1541.exe)|c1541.exe|(CC1541.exe)|cc1541.exe|(DM.exe)|dm.exe|(CBMLS.exe)|cbmls.exe;", 0, #False)
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream: "+FileStream)
                    
                Case DC::#String_102    
                    

                        FilePatterns$ = ""
                        FilePatterns$ + "Disk Images "
                        FilePatterns$ + " (Support Images)"
                        FilePatterns$ + "|*.D64;*.D71;*.D80:*.D81;*.D82;*.G64;*.G71;*.NIB;*.T64;*.X64;*.7Z;*.LNX;*.RAR;*.ZIP|"
                        FilePatterns$ + "C64:1541 (*.D64)|*.D64|"
                        FilePatterns$ + "C64:1571 (*.D71)|*.D71|"
                        FilePatterns$ + "C64:8050 (*.D80)|*.D80|"
                        FilePatterns$ + "C64:1581 (*.D81)|*.D81|"
                        FilePatterns$ + "C64:8250 (*.D82)|*.D82|"
                        FilePatterns$ + "C64:1541 GCR (*.G64)|*.G64|"
                        FilePatterns$ + "C64:1541 GCR (*.G71)|*.G71|"                    
                        FilePatterns$ + "C64:1541 GCR (*.NIB)|*.NIB|"
                        FilePatterns$ + "C64:Cart (*.CRT)|*.CRT|"  
                        FilePatterns$ + "C64:Prog (*.PRG;*.P00)|*.PRG;*.P00|"                         
                        FilePatterns$ + "C64:Tape (*.T64)|*.T64|"
                        FilePatterns$ + "C64:Tape (*.TAP)|*.TAP|"  
                        FilePatterns$ + "C64:Tape (*.X64)|*.X64|"                         
                        FilePatterns$ + "Archiv (*.7Z)|*.7z|"
                        FilePatterns$ + "Archiv (*.LNX)|*.LNX|"
                        FilePatterns$ + "Archiv (*.RAR)|*.RAR|"
                        FilePatterns$ + "Archiv (*.ZIP)|*.ZIP;"                   
                        
                    ;
                    ; Pfad aus dem Gadget Entnehmen
                    TestPath$  = GetFile_Selector(DPGadgetID)
                    If ( Len( GetGadgetText( DPGadgetID ) ) > 0 )
                        TestPath$ = GetGadgetText(DPGadgetID)
                        TestPath$ = Getfile_Portbale_ModeOut( TestPath$ )
                    EndIf                     

                    FileStream = FFH::GetFilePBRQ("Wähle Diskimage",TestPath$, #False, FilePatterns$, 0, #False)

                    
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream: "+FileStream)
                    
                    ;
                    ; Gadgets um Verzeichnissw Auszuwählen
                Case DC::#String_111, DC::#String_103
                    TestPath$  = GetFile_Selector(DPGadgetID)
                    
                    If ( Len( GetGadgetText( DPGadgetID ) ) > 0 )
                        TestPath$ = GetGadgetText(DPGadgetID)
                        TestPath$ = Getfile_Portbale_ModeOut( TestPath$ )
                    EndIf 
            
                    FileStream = FFH::GetPathPBRQ("ArbeitsPfad Auswählen",TestPath$)
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream: "+FileStream)
            EndSelect            
        EndIf
                    
        ;
        ; Datei oder Path ?
        TestSize = FileSize(FileStream)
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" FileStream Size: "+Str(TestSize))
        Select TestSize
                ;
                ; Nicht gefunden, das sollte NIE vorkommen beim auswählen
            Case -1
                SetActiveGadget(DC::#ListIcon_003): ProcedureReturn

                
                ;
                ; Verzeichnis / Arbeits Pfad               
            Case -2
                TestPath$ = Getfile_Portbale_ModeIn(FileStream)
                           
                ;
                ;
            Default  
               TestFile$ = GetFilePart(FileStream)
               TestPath$ = GetPathPart(FileStream) 
               TestPath$ = Getfile_Portbale_ModeIn(TestPath$)                 
       EndSelect  
       
       Select DPGadgetID
               ;
               ; c1541.exe/ dm.exe
           Case DC::#String_101: SetGadgetText(DPGadgetID, TestPath$ + TestFile$)  
               Startup::*LHGameDB\C64LoadS8 = TestPath$ + TestFile$
               ExecSQL::UpdateRow(DC::#Database_001,"Settings", "C64Load$8", Startup::*LHGameDB\C64LoadS8,1)
               ;
               ; Disk Image
           Case DC::#String_102: SetGadgetText(DPGadgetID, TestPath$ + TestFile$)
                                 SetGadgetText(DC::#String_008, TestPath$ + TestFile$)   ; Lege Image Testerweise in den ersten Slot
               ;
               ; OpenCBM Tools Path
           Case DC::#String_103: SetGadgetText(DPGadgetID , TestPath$) 
                Startup::*LHGameDB\OpenCBM_Tools = TestPath$
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "OpenCBMTools", Startup::*LHGameDB\OpenCBM_Tools,1)                                
               ;
               ; OpenCBM Backup Path
            Case DC::#String_111: SetGadgetText(DPGadgetID , TestPath$) 
                Startup::*LHGameDB\OpenCBM_BPath = TestPath$
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "OpenCBMBPath", Startup::*LHGameDB\OpenCBM_BPath,1)                   
       EndSelect
       
    EndProcedure      
    ;****************************************************************************************************************************************************************
    ;Fake Drag'n'Drop
    ;**************************************************************************************************************************************************************** 
    Procedure.s GetFile_MultiSelect(FileStreams.s)
        Protected TestFile$, FileStream$     
        
        If (Len(FileStreams) = 0): ProcedureReturn "": EndIf
        
        ;
        ; Die erste Datei
        FileStream$ + FileStreams
        
        While FileStreams
            ;
            ; Folgend dann die 2t
            TestFile$ = NextSelectedFileName()
                        
            If ( Len(TestFile$) = 0 ) 
                Debug "Multi Select Support:" +Chr(13)+ FileStream$
                ProcedureReturn FileStream$
                
            Else
                FileStream$ + Chr(10) + TestFile$
            EndIf
       Wend         
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ;
    ;**************************************************************************************************************************************************************** 
    Procedure GetFile_Media(DPGadgetID.i, FileStream.s = "")
        
        
        Protected MaxFiles.i, index.i, GadgetFileA$, GadgetFileB$, GadgetFileC$, GadgetFileD$, TestFile$, SourcePath$
        
        SetActiveGadget(-1)
        ;
        ;
        ; Wegen Drag'nDrop den String durchzählen. Chr(10) = umbruch        
        MaxFiles  = CountString(FileStream, Chr(10)) + 1
                       
        ;
        ; Procedure Aktiviert, aber nicht durch Drag'nDrop
        If ( FileStream = "" )
            
            SourcePath$  = GetFile_Selector(DPGadgetID) 
            
            If ( Len( GetGadgetText( DPGadgetID ) ) > 0 )
                SourcePath$ = GetGadgetText(DPGadgetID)
                SourcePath$ = Getfile_Portbale_ModeOut( SourcePath$ )
            EndIf    
            
            TestFile$   = FFH::GetFilePBRQ("Media Load",SourcePath$, #False, "Alle Media Dateien (*.*)|*.*;", 0, #True)
            FileStream  = GetFile_MultiSelect(TestFile$)
            If ( FileStream = "" )
                ;
                ; Nothing to do, No File(s)
                ProcedureReturn
            EndIf
            ;
            ; Widerhole die Procdure um ein 'Fake' Drag'n'Drop auszuführen. Weniger Code zu schreiben
            GetFile_Media(DPGadgetID, FileStream)                              
        EndIf
        
        
        ;
        ;
        ; Bis zu 4 Dateien Erlaubt, 1 je String
        For  index = 1 To MaxFiles
            Select index
                Case 1: GadgetFileA$ =  StringField(FileStream, index, Chr(10))
                    
                    ;
                    ; Falls im Title String nichts steht nimm den Dateinamen als Title
                    If ( Len( GetGadgetText(DC::#String_001) ) = 0 )
                        Database_Set_Title( GetFilePart(GadgetFileA$, #PB_FileSystem_NoExtension) )             
                    EndIf 
                    
                   ;
                   ; Autofill
                    GadgetFileA$ = Getfile_Portbale_ModeIn(GadgetFileA$)
                    SetGadgetText(DPGadgetID, GadgetFileA$)
                    Select DPGadgetID
                            ;
                            ; Das Autofüllen stoppen wenn es sich nicht um ersten GadgetString handelt
                        Case DC::#String_009 To DC::#String_011
                            Break
                    EndSelect
                    
               Case 2: GadgetFileB$ =  StringField(FileStream, index, Chr(10)): GadgetFileB$ = Getfile_Portbale_ModeIn(GadgetFileB$): SetGadgetText(DC::#String_009, GadgetFileB$)                   
               Case 3: GadgetFileC$ =  StringField(FileStream, index, Chr(10)): GadgetFileC$ = Getfile_Portbale_ModeIn(GadgetFileC$): SetGadgetText(DC::#String_010, GadgetFileC$)                   
               Case 4: GadgetFileD$ =  StringField(FileStream, index, Chr(10)): GadgetFileD$ = Getfile_Portbale_ModeIn(GadgetFileD$): SetGadgetText(DC::#String_011, GadgetFileD$)
               Default: Break
            EndSelect           
        Next index    
        
        
    EndProcedure          
    ;****************************************************************************************************************************************************************
    ;
    ;**************************************************************************************************************************************************************** 
    Procedure Change_Title(GadgetID.i)
        Protected Title$, Result.i, ParseDate.i
        ;
        ;Ändert den Title
        Select GadgetID
                ; 
                ; Title
            Case DC::#String_001
                Title$ = GetGadgetText(GadgetID)
                SetGadgetText(DC::#Text_001,Title$)
                
                ;
                ; Subtitle
            Case DC::#String_002    
                Title$ = GetGadgetText(GadgetID)
                SetGadgetText(DC::#Text_002,Title$)  
                                
                ;
                ; Platform
            Case DC::#String_004
                Title$ = GetGadgetText(GadgetID)                
                Database_Set_Platform(Title$)
                SendMessage_(GadgetID(GadgetID), #EM_SETSEL, Len(Title$), Len(Title$)) 
                ;
                ; Release
            Case DC::#String_005
                Title$ = GetGadgetText(GadgetID)                               
                Database_Get_Set_Release(Title$,#False)              
            Default  
        EndSelect        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;**************************************************************************************************************************************************************** 
    Procedure Update_Changes()
        
        Protected FsTitle$, Sbtitle$, Lnguage$, Pltform$, DMMYYYY$, Command$, Device1$, Device2$, Device3$, Device4$, IntFle1$, IntFle2$, IntFle3$, IntFle4$
        
        FsTitle$ = GetGadgetText(DC::#String_001): FsTitle$ = Trim(FsTitle$)
        Sbtitle$ = GetGadgetText(DC::#String_002): Sbtitle$ = Trim(Sbtitle$)
        Lnguage$ = GetGadgetText(DC::#String_003)
        Pltform$ = GetGadgetText(DC::#String_004)
        DMMYYYY$ = GetGadgetText(DC::#String_005): DMMYYYY$ = Trim(DMMYYYY$)       
        PrgDesc$ = GetGadgetText(DC::#String_006)  
        Command$ = GetGadgetText(DC::#String_007)
        Device1$ = GetGadgetText(DC::#String_008): Device1$ = Trim(Device1$)  
        Device2$ = GetGadgetText(DC::#String_009): Device2$ = Trim(Device2$)    
        Device3$ = GetGadgetText(DC::#String_010): Device3$ = Trim(Device3$)   
        Device4$ = GetGadgetText(DC::#String_011): Device4$ = Trim(Device4$)  
        IntFle1$ = GetGadgetText(DC::#String_107): 
        IntFle2$ = GetGadgetText(DC::#String_108):   
        IntFle3$ = GetGadgetText(DC::#String_109):   
        IntFle4$ = GetGadgetText(DC::#String_110):         
                
        ;
        ; Update Title        
        If ( Len(Sbtitle$) >= 1 ): FsTitle$ + " - " +  Sbtitle$: EndIf
        Database_Set_Title(FsTitle$)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "GameTitle", FsTitle$ ,Startup::*LHGameDB\GameID)
        
        ;
        ; Update Date
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Release"  , DMMYYYY$ ,Startup::*LHGameDB\GameID)        
        
        ;
        ; Update Media
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev0", Device1$ ,Startup::*LHGameDB\GameID)        
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev1", Device2$ ,Startup::*LHGameDB\GameID)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev2", Device3$ ,Startup::*LHGameDB\GameID)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev3", Device4$ ,Startup::*LHGameDB\GameID)        
        
        ;
        ; Update Files
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev0", IntFle1$ ,Startup::*LHGameDB\GameID,"","",1,#False)        
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev1", IntFle2$ ,Startup::*LHGameDB\GameID,"","",1,#False)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev2", IntFle3$ ,Startup::*LHGameDB\GameID,"","",1,#False)
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "FileDev3", IntFle4$ ,Startup::*LHGameDB\GameID,"","",1,#False)  
        
        ;
        ; Update ListIconBox
        id  = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","LanguageID","",Startup::*LHGameDB\GameID,"",1))
        Lnguage$ = ""       
        If ( id <> 0 )                      
            Lnguage$ = ExecSQL::nRow(DC::#Database_001,"Language","Locale","",id,"",1) 
        EndIf
                
        id  = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PlatformID","",Startup::*LHGameDB\GameID,"",1))        
        Pltform$ = ""        
        If ( id <> 0 )                      
            Pltform$ = ExecSQL::nRow(DC::#Database_001,"Platform","Platform","",id,"",1) 
        EndIf
                
        id  = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","",Startup::*LHGameDB\GameID,"",1))
        PrgDesc$ = ""        
        If ( id <> 0 )                      
            PrgDesc$ = ExecSQL::nRow(DC::#Database_001,"Programs","ExShort_Name","",id,"",1) 
        EndIf
        
        If ( Startup::*LHGameDB\SortMode = 5)
        			PrgDesc$ = LSet(DMMYYYY$, 10, Chr(32) )
        EndIf	        
        
        Database_Set_ProgramTitle(DC::#String_006)          
        Database_Set_ProgramArgs(DC::#String_007)      
        
        SetGadgetItemText(DC::#ListIcon_001 ,GetGadgetState(DC::#ListIcon_001),FsTitle$ ,0)
        SetGadgetItemText(DC::#ListIcon_001 ,GetGadgetState(DC::#ListIcon_001),Pltform$ ,1)
        SetGadgetItemText(DC::#ListIcon_001 ,GetGadgetState(DC::#ListIcon_001),Lnguage$ ,2)                                               
        SetGadgetItemText(DC::#ListIcon_001 ,GetGadgetState(DC::#ListIcon_001),PrgDesc$ ,3)        
        
    EndProcedure     
    ;**************************************************************************************************************************************************************** 
    ; Programm läuft,  While ProgramRunnin.... Fenster/ Programm hacks
    ;________________________________________________________________________________________________________________________________________________________________
    Procedure.i DOS_Thread_HideWindow(WindowName$, l_ProcID, Flags.l, State.i = #False)
        
        Protected HandleWindow.i
        
        ;If State = #False
            
        If Startup::*LHGameDB\Settings_NoBorder = #True
            
            ;vSystem::System_NoBorder(szTaskName.s = "")  
            ;    HandleWindow.i = FindWindow_(0,WindowName$) 
            ;EndIf    
                        
            ;If ( HandleWindow = 0)  
            ;    If Startup::*LHGameDB\Settings_NoBorder = #True
            ;        HandleWindow.i =  DesktopEX::GetWindows(WindowName$)
            ;     EndIf   
            ;EndIf 
            
            ;If ( HandleWindow )
            ;    State = #True
            ;    
            ;    If Startup::*LHGameDB\Settings_NoBorder = #True
            ;        ShowWindow_(HandleWindow,Flags)      
            ;        
            ;        DesktopEX::RemoveBorders(HandleWindow, 0, 0, 0, 0, 0, 1,1)
            ;        Delay(250)  
            ;    EndIf                
            EndIf    
                
        ;EndIf    
        
        ;ProcessEX::SetAffinityActiv(l_ProcID,ProcessEX::SetAffinityCPUS(0))         
        ProcedureReturn State        
    EndProcedure        
    
    ;**************************************************************************************************************************************************************** 
    ; Minimiert vSystems
    ;________________________________________________________________________________________________________________________________________________________________    
    Procedure.i DOS_Thread_Minimze(Minimze.i= -1)
        Protected state.i
        
        Select Minimze
                
            Case -1
                ProcedureReturn -1
                
            Case #True
                state.i = GetWindowState(DC::#_Window_001)
                Select state
                        ;
                        ;
                    Case #PB_Window_Normal
                        ShowWindow_(WindowID(DC::#_Window_001), #SW_MINIMIZE)
                        ;
                        ;                    
                EndSelect
                ProcedureReturn #False
                
            Case #False
                state.i = GetWindowState(DC::#_Window_001)
                Select state
                        ;
                        ;
                    Case #PB_Window_Minimize
                        ShowWindow_(WindowID(DC::#_Window_001), #SW_RESTORE)
                        ;
                        ;                    
                EndSelect            
                ProcedureReturn -1            
                
        EndSelect       
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ; Programm läuft,  Sammle Textausgabe
    ;________________________________________________________________________________________________________________________________________________________________                       
    Procedure DOS_Thread_OutPut(*Params.PROGRAM_BOOT)
        
    	Protected stdout.s, NewLines.i, stLogging.s, Result.i
    	
    	If Startup::*LHGameDB\ExitSignal = #True
    		  ProcedureReturn
    		EndIf
    		
    	If Not IsProgram(Startup::*LHGameDB\Thread_ProcessLow)	
    		ProcedureReturn 
    	EndIf
    	
    	If ( Startup::*LHGameDB\Settings_bSaveLog = #False ) Or (Startup::*LHGameDB\Settings_bNoOutPt = #True)
    		ProcedureReturn 
    	EndIf
    		
    	If AvailableProgramOutput( Startup::*LHGameDB\Thread_ProcessLow )
    		
    		stLogging = ReadProgramString( Startup::*LHGameDB\Thread_ProcessLow ,#PB_UTF8) 
    		
    		Debug "Programm Läuft"
    		If 			(Startup::*LHGameDB\Settings_bNoOutPt = #False)
    						*Params\Logging + stLogging + Chr(13) + Chr(10)
    				    
    						Debug #TAB$ + "Standard Output Log: " + stLogging
    						stLogging = Chr(0)
    						; Zuviele Linefeeds
    						;NewLines = CountString(*Params\Logging, Chr(10) )
    						;If ( NewLines > 200 )
    						;	*Params\Logging = Chr(0)
    					 	;	Debug #TAB$ + "Standard Output Log NewLines > 200: Clear"
    						;EndIf     						
    						
    		ElseIf ( Startup::*LHGameDB\Settings_bSaveLog = #True ) 
    				
    			If ( (*Params\StdOutL) > 0 )
    				If IsFile(*Params\StdOutL)
    						Result = WriteStringN(*Params\StdOutL, stLogging ) 
    						Debug #TAB$ + "Standard Output Log Leite Um (Result "+Str(Result)+"): " + stLogging
    					EndIf
    				EndIf
    		EndIf	
    			
    		;
				; Fehler stdOut
    		If 			(Startup::*LHGameDB\Settings_bNoOutPt = #False) And IsProgram( Startup::*LHGameDB\Thread_ProcessLow )
    				
    				stdout.s = ReadProgramError( Startup::*LHGameDB\Thread_ProcessLow ,#PB_UTF8)
    				    				      						
    				If ( Len( stdout.s)  > 0 )
    					*Params\StError + stdout.s
    					stdout = Chr(0)
    					Debug #TAB$ + "Error Output Log: " + stdout 
    				EndIf
    					
    		ElseIf ( Startup::*LHGameDB\Settings_bSaveLog = #True ) And IsProgram( Startup::*LHGameDB\Thread_ProcessLow ) 
    			
    			If (*Params\ErrorLg) > 0
    				If IsFile(*Params\StdOutL)
    					WriteStringN(*Params\ErrorLg,stdout)
    					Debug #TAB$ + "Error Output Log Schreibe in den String: " + stdout
    				EndIf
    			EndIf
    		EndIf
    		
    		

    	EndIf
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Programm läuft,  While ProgramRunnin....
    ;________________________________________________________________________________________________________________________________________________________________                       
    Procedure.s DOS_Thread_PrgLoop(*Params.PROGRAM_BOOT, l_ProcID.l)
        
        Protected Mame_Window.i, DOS_NOP = 1, WindowState = #False, StdOutErrors$, FatalError_A$, FatalError_B$, x.i=0, y.i= 0, exitCodeL
        
        Repeat
            If ( x = 10000)
                x = 0                
            EndIf
            
            If (x = 0)  
                vSystem::System_GetTasklist();               
            EndIf                       
            x + 1                        
            
            If ( Startup::*LHGameDB\Settings_Affinity >= 0   ) Or
               ( Startup::*LHGameDB\Settings_NoBorder = #True) Or
               ( Startup::*LHGameDB\Settings_FreeMemE = #True)                 
            EndIf
            
            
            If ( Startup::*LHGameDB\Settings_Affinity >= 0 )               
                If ( Startup::*LHGameDB\Settings_Affinity = 999 )   
                    ;
                    ; 999 - Forciere alle CPU's
                    vSystem::System_SetAffinity(*Params\Program)
                Else
                    vSystem::System_SetAffinity(*Params\Program, Startup::*LHGameDB\Settings_Affinity+1)
                EndIf
                ; Aktivere den Patch nur einmal
                Startup::*LHGameDB\Settings_Affinity = -1                    
            EndIf                                         
            
            If Startup::*LHGameDB\Settings_FreeMemE = #True            
                vSystem::System_MemoryFree(*Params\Program) 
                ; TODO
                ; Schwellenwert angabe                 
            EndIf   
            
            
            If Startup::*LHGameDB\Settings_NoBorder = #True 
                
                If ( Startup::*LHGameDB\Settings_NoBoTime >= 1)
                    Delay(Startup::*LHGameDB\Settings_NoBoTime)
                    
                    ;
                    ; Nur für den Start
                    Startup::*LHGameDB\Settings_NoBoTime = 0
                EndIf    
                
                vSystem::System_NoBorder(*Params\Program)    
            EndIf 
            
            If ( vSystem::System_GetCurrentMemoryUsage() > 10485760 )               
                ProcessEX::LHFreeMem()
            EndIf                 
            
            If ( Startup::*LHGameDB\Settings_aExecute = #False )
            	If Not (ProgramRunning(l_ProcID))
                		DOS_NOP = 0
                	EndIf 
                Else
                	;
                	; Exits Codes (Muss geändert oder verbessert werden)
           		GetExitCodeProcess_(*Params\hProcess, @exitCodeL)
           		If ( exitCodeL = 0 ) Or ( exitCodeL = 1 )
           			DOS_NOP = 0
           		EndIf
           	EndIf
           	           	            
            If ( vSystem::System_ProgrammIsAlive(*Params\Program) = #False )            
                DOS_NOP = 0
            Else
                ; OutputThread = CreateThread(@DOS_Thread_OutPut(),*Params)    
                If ( Startup::*LHGameDB\Settings_aExecute = #False )
                	DOS_Thread_OutPut(*Params)
                EndIf                                      
            EndIf   
            
            
            Delay(25)
        Until DOS_NOP = 0    
        
        Delay(1)
        
        If (Startup::*LHGameDB\Settings_bNoOutPt = #False) And ( Startup::*LHGameDB\Settings_aExecute = #False )
            FatalError_A$ = ""
            FatalError_B$ = ""
            
            FatalError_A$ = ReadProgramError(l_ProcID,#PB_Ascii)
            FatalError_B$ = ReadProgramError(l_ProcID,#PB_Ascii)
            
            If ( Len(FatalError_A$) >1 )
                *Params\ExError = 1            
                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #ERROR.1 : " + FatalError_A$) 
            EndIf
            
            If ( Len(FatalError_B$) >1 )
                *Params\ExError = 1
                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #ERROR.2 : " + FatalError_B$) 
            EndIf
        EndIf
        
        ProcedureReturn ""        
    EndProcedure        
    
    ;****************************************************************************************************************************************************************
    ; Programm Starten via CreateProcess
    ;________________________________________________________________________________________________________________________________________________________________ 
    Procedure.l DOS_Thread_CreatProcess(*Params.PROGRAM_BOOT, DOS_PatH.s,DOS_ExeC.s,DOS_CliC.s)
        
            Protected ProcessPriority = $20
            
            lpStartUpInfo.STARTUPINFO 
            lpProcessInfo.PROCESS_INFORMATION 
             
            lpStartUpInfo\cb            = SizeOf(STARTUPINFO)                          
            lpStartUpInfo\dwFlags       =#STARTF_USESHOWWINDOW|#STARTF_USESTDHANDLES
            lpStartUpInfo\wShowWindow   =#SW_NORMAL 
            
            szCmdline.s = ""
            szPrgLine.s = ""
            
            
            If ( Len(DOS_CliC) >= 1 )
                szCmdline = DOS_PatH + DOS_ExeC +  " " +DOS_CliC
                CreateProcess_(0, @szCmdline, #Null,#Null,#False,ProcessPriority,#Null,@DOS_PatH,@lpStartUpInfo,@lpProcessInfo) ; Return 1 if success / 0 = fail
            Else
                szPrgLine = DOS_PatH + DOS_ExeC
                CreateProcess_(0, @szPrgLine, #Null,#Null,#False,ProcessPriority,#Null,@DOS_PatH,@lpStartUpInfo,@lpProcessInfo) ; Return 1 if success / 0 = fail
            EndIf    
                                   
            Delay(25)
            l_ProcID = lpProcessInfo\dwProcessId
            *Params\hProcess = lpProcessInfo\hProcess
            *Params\hThread  = lpProcessInfo\hThread
 
            
            ProcedureReturn l_ProcID 
        
    EndProcedure
    
    ;****************************************************************************************************************************************************************
    ; Programm läuft,  While ProgramRunnin.... Game Mode
    ;________________________________________________________________________________________________________________________________________________________________                                
    Procedure DOS_Thread_GameMode(*Params.PROGRAM_BOOT)

                
        Protected l_ProcID.l, h_ProcID.l, DOS_ExeC$, DOS_PatH$, DOS_WorK$, DOS_CliC$, exitCodeH, exitCodeL, REG_KNAME$, REG_SZ$, REG_VALUE$
        
        DOS_ExeC$ = *Params\Program
        DOS_PatH$ = *Params\PrgPath
        DOS_WorK$ = *Params\WrkPath
        DOS_CliC$ = *Params\Command
        
        Startup::*LHGameDB\Thread_ProcessLow = -1
        ;
        ; Prüfung der Programm Eingenschaften
        If FileSize( DOS_PatH$ + DOS_ExeC$ ) = 0
            ;
            ; TODO:
            ; FEHLER Kein Programm
        EndIf
        
        If FileSize( DOS_WorK$ ) <> -2
            ;
            ; TODO:
            ; FEHLER. Der ArbeitsPfad ist nicht vorhanden Kein Programm
        EndIf        
        
        ;
        ;
        ; Compatibility Mod Setzen
        If ( Startup::*LHGameDB\Settings_bCompatM = #True )        
            
            UseModule Registry
            
            REG_KNAME$ = "Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            REG_SZ$    = Startup::*LHGameDB\Settings_sCmpArgs
            REG_VALUE$ = Startup::*LHGameDB\Settings_sCmpFile
            
  
            If  WriteValue(#HKEY_CURRENT_USER, REG_KNAME$, REG_VALUE$ , REG_SZ$, #REG_SZ)
                Debug ReadValue(#HKEY_CURRENT_USER, REG_KNAME$, REG_VALUE$)
                ;If DeleteValue(#HKEY_CURRENT_USER, "Software\ts-soft", "demo")
                ;Debug "Value deleted"
                ;Else
                ;Debug "Value not deleted"
            Else
                Request::MSG(Startup::*LHGameDB\TitleVersion, "ERROR", "Konnte den Registry Wert nicht setzen!",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            EndIf    
            
            UnuseModule Registry
        EndIf

        ;
        ;
        ; 
        If ( Startup::*LHGameDB\Settings_Taskbar = #True )
            DesktopEX::SetTaskBar()
            Debug #TAB$ + "- Disable Taskbar"
        EndIf
        
        If ( Startup::*LHGameDB\Settings_Explorer= #True )
            DesktopEX::CloseExplorer() 
            Debug #TAB$ + "- Close Explorer"
        EndIf          
        
        If ( Startup::*LHGameDB\Settings_DwmUxsms= #True )
            ServiceOption("uxsms", #False) 
            Debug #TAB$ + "- Close Aero"
        EndIf 
        
        If ( Startup::*LHGameDB\Settings_bBlockFW= #True )
            UseModule ClassFirewall
                Rule("vSystems " + *Params\Program ,"Acitvated and Configuration with "+ Startup::*LHGameDB\TitleVersion, *Params\PrgPath + *Params\Program, #True, #NET_FW_IP_PROTOCOL_TCP)
                Rule("vSystems " + *Params\Program ,"Acitvated and Configuration with "+ Startup::*LHGameDB\TitleVersion, *Params\PrgPath + *Params\Program, #True, #NET_FW_IP_PROTOCOL_UDP)
            UnuseModule ClassFirewall    
        EndIf    
        
        
        
        ;vSystem::System_Set_Priority(GetFilePart( ProgramFilename() ), #IDLE_PRIORITY_CLASS)
        ; Minimiert vSystems, auch wenn mit Settings_Asyncron gestartet wurde
        ;
        Startup::*LHGameDB\Settings_Minimize = DOS_Thread_Minimze(Startup::*LHGameDB\Settings_Minimize)
        
        ;
        ; Settings_aExecute = Benutze alternativen Api process (inWork)
        If ( Startup::*LHGameDB\Settings_Asyncron = #True ) Or (Startup::*LHGameDB\Settings_aExecute = #True)

            Debug ""
            Debug "Programm Load: Async "
            Debug "Path         : " + DOS_PatH$
            Debug "Exec         : " + DOS_ExeC$ 
            Debug "Command      : " + DOS_CliC$           
            l_ProcID = DOS_Thread_CreatProcess(*Params, DOS_PatH$,DOS_ExeC$,DOS_CliC$) 
            Startup::*LHGameDB\Thread_ProcessLow = l_ProcID
            Delay(25) 
        Else                             
            Debug ""
            Debug "Programm Load: NonAsync "
            Debug "Path         : " + DOS_PatH$
            Debug "Exec         : " + DOS_ExeC$ 
            Debug "Command      : " + DOS_CliC$
            Debug "Working      : " + DOS_WorK$
            l_ProcID.l = RunProgram(DOS_PatH$ + DOS_ExeC$,DOS_CliC$,DOS_WorK$,*Params\PrgFlag)
            Startup::*LHGameDB\Thread_ProcessLow = l_ProcID
            Delay(25)            
        EndIf    
             
        
        If ( Startup::*LHGameDB\Settings_Asyncron = #True )
        	ProcedureReturn
        EndIf
        
        If ( Startup::*LHGameDB\Settings_aExecute = #False ) And (IsProgram(Startup::*LHGameDB\Thread_ProcessLow) = 0)
        	ProcedureReturn 
        EndIf	
        
        If ( Startup::*LHGameDB\Thread_ProcessLow = 0 )
        	ProcedureReturn 
        EndIf
        
        ;If ( l_ProcID.l = 0 ) Or ( Startup::*LHGameDB\Settings_Asyncron = #True ) Or (IsProgram(l_ProcID) = 0)
        ;    ProcedureReturn
        ;EndIf
        
         
        If ( Startup::*LHGameDB\Settings_aExecute = #False )     
        	h_ProcID = OpenProcess_(#PROCESS_QUERY_INFORMATION, 0, ProgramID(Startup::*LHGameDB\Thread_ProcessLow))          
        Else
        	h_ProcID = OpenProcess_(#PROCESS_QUERY_INFORMATION, 0, Startup::*LHGameDB\Thread_ProcessLow)
        EndIf	
     

        DOS_Thread_PrgLoop(*Params.PROGRAM_BOOT, Startup::*LHGameDB\Thread_ProcessLow)    
        
        ; If ( Startup::*LHGameDB\Settings_aExecute = #True )
        ; 	WaitForSingleObject_( h_ProcID, #INFINITE );
        ; EndIf	
        
        GetExitCodeProcess_(h_ProcID, @exitCodeH)
        GetExitCodeProcess_(Startup::*LHGameDB\Thread_ProcessLow, @exitCodeL)
        
        ;Startup::*LHGameDB\Thread_ProcessLow = l_ProcID
        
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@ExitCode Low : " + Str(exitCodeL) )         
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@ExitCode High: " + Str(exitCodeH) ) 
        
         If ( Startup::*LHGameDB\Settings_aExecute = #True )
         	CloseHandle_( h_ProcID)
         	CloseHandle_( *Params\hThread )
         Else                  
         	CloseProgram(l_ProcID)                
         EndIf	
        
        ;vSystem::System_Set_Priority(GetFilePart( ProgramFilename() ), #NORMAL_PRIORITY_CLASS)
        ;
        ;
        ; Game Helper
        If ( Startup::*LHGameDB\Settings_DwmUxsms = #True)
            ServiceOption("uxsms", #True) 
            Debug #TAB$ + "-  Run Aero"
        EndIf  
        
        If ( Startup::*LHGameDB\Settings_Taskbar  = #True )
            DesktopEX::SetTaskBar()
            Debug #TAB$ + "- Enable Taskbar"
        EndIf
        If ( Startup::*LHGameDB\Settings_Explorer = #True)
            DesktopEX::StartExplorer()
            Debug #TAB$ + "- Start Explorer"
        EndIf 
        
        If ( Startup::*LHGameDB\Settings_bBlockFW= #True )
            UseModule ClassFirewall
                Rule("vSystems " + *Params\Program ,"Acitvated and Configuration with "+ Startup::*LHGameDB\TitleVersion, *Params\PrgPath + *Params\Program, #False, #NET_FW_IP_PROTOCOL_TCP)
                Rule("vSystems " + *Params\Program ,"Acitvated and Configuration with "+ Startup::*LHGameDB\TitleVersion, *Params\PrgPath + *Params\Program, #False, #NET_FW_IP_PROTOCOL_UDP)
            UnuseModule ClassFirewall    
        EndIf        
        ;
        ;
        ; Compatibility Mod Setzen
        If ( Startup::*LHGameDB\Settings_bCompatM = #True )        
            
            UseModule Registry          
  
            If ReadValue(#HKEY_CURRENT_USER, REG_KNAME$, REG_VALUE$)
                If DeleteValue(#HKEY_CURRENT_USER, REG_KNAME$, REG_VALUE$)
                
                Else
                    Request::MSG(Startup::*LHGameDB\TitleVersion, "ERROR", "Konnte den Registry Wert nicht löschen!",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
                EndIf                    
            EndIf    
            
            UnuseModule Registry
        EndIf
        
        Select exitCodeL
            Case 0:   Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Successful " + Str(exitCodeL))                 
            Case 1:   Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Warning: Non fatal error(s) occurred " + Str(exitCodeL))                                 
            Case 3:   Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Archive Error: A CRC error occurred when unpacking " + Str(exitCodeL))                                 
            Case 4:   Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Archive Error: Attempt to modify an archive previously locked " + Str(exitCodeL))                                  
            Case 5:   Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Error Loading Rom: Unknown Maschine " + Str(exitCodeL))                               
            Case 6:   Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Commandline Error " + Str(exitCodeL))                                
            Case 255: Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: User stopped the process " + Str(exitCodeL))                                   
            Default : Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@Exit: Unknow " + Str(exitCodeL))                    
        EndSelect               
                     
    EndProcedure        
    ;****************************************************************************************************************************************************************
    ; Startet Programm (Threaded)
    ;________________________________________________________________________________________________________________________________________________________________               
    Procedure DOS_Thread(*Params.PROGRAM_BOOT)
    	
    		
            LockMutex(ProgrammMutex)    
            Delay(25)
            DOS_Thread_GameMode(*Params.PROGRAM_BOOT)        
            UnlockMutex(ProgrammMutex)
            ProcedureReturn
    EndProcedure
    
    ;****************************************************************************************************************************************************************
    ; Section Set Media Device, Prüfe dateien auf Leerzeichen
    ;****************************************************************************************************************************************************************
    Procedure.s DOS_Device_VerifySpace(Device.s)
        
        If ( Len(Device) >= 1 )
            For  Index = 0 To Len(Device)            
                c = Asc(Mid(Device,Index,1))
                If ( c = 32 )
                    ;
                    ; Füge " hinzu 
                    ProcedureReturn Chr(34) + Device +  Chr(34)
                EndIf                            
            Next Index    
        EndIf
        ;
        ; Bypass
        ProcedureReturn Device
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ; Section Set Media Device, Adding File(s)
    ;****************************************************************************************************************************************************************
    Procedure.s DOS_Device_GetInternalFile(Device.s, Drive.i, CheckPrg.s) ; Drive = veraltetet
        
        Protected SubFile.s       
        
        If IsWindow(DC::#_Window_005)           ; C64 File Manager                                   
            ;
            ; Im Einstellungs Fenster hole aktuell den Dateinamen aus den unteren 4 Strings
            ; Die Gadget Nummer darf nicht geändert !!
            For szInput = DC::#String_107 To DC::#String_110
                SubFile = GetGadgetText( szInput )
                If Len( SubFile ) = 0
                    Continue
                Else
                    Break
                EndIf
            Next
            
        Else   
            
            If ( Startup::*LHGameDB\Switch = 0) ; Haupt List Fenster ist Aktiv
                For szInput = 1 To 4
                    SubFile = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev"+Str(szInput-1),"",Startup::*LHGameDB\GameID,"",1):
                    If Len( SubFile ) = 0
                        Continue
                    Else
                        Break
                    EndIf    
                Next
            Else
                ;
                ; Im Einstellungs Fenster hole aktuell den Dateinamen aus den unteren 4 Strings
                ; Die Gadget Nummer darf nicht geändert !!
                For szInput = DC::#String_107 To DC::#String_110
                    SubFile = GetGadgetText( szInput )
                    If Len( SubFile ) = 0
                        Continue
                    Else
                        Break
                    EndIf
                Next
            EndIf    
            
            
        EndIf    
        
        ;
        ;
        ; HOXS64 benutzt Anfürhungstriche während vide keine benutzt ????
        If ( Len( SubFile ) ! 0 )
            If ( "HOXS64.EXE" = UCase( CheckPrg ) )
                ProcedureReturn Device +Chr(34)+ " " +Chr(34)+ ":" + SubFile 
            Else    
                ProcedureReturn Device + ":" +SubFile   
            EndIf                 
        EndIf
        
        ProcedureReturn Device           
        
    EndProcedure 
    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________       
    Procedure.s DOS_PKARC_UNARC(Device.s, n.i, PowerPacker.i)           
        
        Protected z = DC::#PACKFILE, Extension$       
        
       If OpenPack(z, Device, PowerPacker ) 
           If ExaminePack(z)
               While NextPackEntry(z)
                   
                   Request::SetDebugLog("Packed : "+PackEntryName(z)+ ", Size: "+ PackEntrySize(z) +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                   
                   If (Len(PackEntryName(z)) = 0) And ( PackEntrySize(z) = 0 )
                       ; 
                       ; No Filename and Items
                       ClosePack(z)
                       ProcedureReturn Device
                   EndIf 
                                                                            
                   ;
                   ;Use the First Filename
                   If ( Len(PackEntryName(z)) >= 1)      
                       
                       PackEntryFileName$ = PackEntryName(z)
                       ; Check for Various Text and Grafik Files
                       Extension$ = UCase ( GetExtensionPart( PackEntryFileName$ ) )
                       Select Extension$
                           Case "TEXT", "TXT", "RTF", "DOK", "DOKS", "NFO", "DIZ", "DOC", "DOCS", "Read", "README", "ORG", "COM", "READ", "GUIDE", "PDF"
                               Continue
                           Case "GIF", "PNG", "JPG", "JPG2000", "BMP", "TIFF", "TIF"
                               Continue
                           Case "SID"
                               Continue                               
                       EndSelect        
                       
                       ; Preapre For Uncompress
                       ;    FileRnd.i = Random(99999,10000)                                 ; Set a Random File                        
                            Filesfx.s = GetExtensionPart( PackEntryFileName$ )                  ; Extract Extension
                            FileNme.s = GetTemporaryDirectory() + "_MediaDevice_"+ Str(n) + "." + Filesfx   ; Extract File
                            
                            Filesze.i = UncompressPackFile(z, FileNme, PackEntryFileName$ )   ; Uncpmpress File to Temp
                            
                            If FileSize(FileNme) ! Filesze
                                ; There was a Error
                                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","There was a error to uncompress File " +#CRLF$+ 
                                                                                        GetFilePart(Device)+#CRLF$+
                                                                                        "Extract Error: "+ PackEntryFileName$,2,2,"",0,0,DC::#_Window_005)
                                ClosePack(z)  
                                ProcedureReturn Device
                            EndIf    
                            
                            Request::SetDebugLog("Extract : "+ FileNme +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                                                   
                            Request::SetDebugLog("Compressed Image Packed  : "+Chr(34)+ Device             +Chr(34)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                             
                            Request::SetDebugLog("Compressed Image UnPacked: "+Chr(34)+ PackEntryFileName$ +Chr(34)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                       ClosePack(z)     
                       ProcedureReturn FileNme
                       ; Löschen nicht vergessen
                       Break
                  EndIf 
                Wend
            EndIf
            ClosePack(z)  
        EndIf
        
        ProcedureReturn Device
     EndProcedure   
    ;****************************************************************************************************************************************************************
    ; Section, Support for Media but Programm has no bultiin Archive Support 
    ;****************************************************************************************************************************************************************    
    Procedure .s DOS_PKARC(Device.s, n.i)
        Protected Extension$
        UseTARPacker(): UseZipPacker(): UseLZMAPacker(): UseBriefLZPacker()
        
        Extension$ = UCase ( GetExtensionPart( Device ) )
        Select Extension$
            Case "ZIP"
                Device = DOS_PKARC_UNARC(Device.s, n.i, #PB_PackerPlugin_Zip)
            Case "7Z"
                Device = DOS_PKARC_UNARC(Device.s, n.i, #PB_PackerPlugin_Lzma)
            Case "TAR"
                Device = DOS_PKARC_UNARC(Device.s, n.i, #PB_PackerPlugin_Tar )
            Case "LZ"
                Device = DOS_PKARC_UNARC(Device.s, n.i, #PB_PackerPlugin_BriefLZ )                
         EndSelect       
        ProcedureReturn Device 
    EndProcedure   
    ;****************************************************************************************************************************************************************
    ; Section Set Media Device, Hole die Bekannten Arguemntse aus der Commandline und lösche sie
    ;****************************************************************************************************************************************************************
    Procedure.s DOS_TrimArg(Args.s, StringToTrim.s)
        CommandPos = FindString(Args,StringToTrim,1,1)
        If ( CommandPos >= 1 )
            Args = ReplaceString(Args,StringToTrim, "",0,CommandPos,1)  
        EndIf 
        Args = Trim( Args )
        ProcedureReturn Args
    EndProcedure      
    ;
    ;
    ;
    Procedure.s Compat_GetCmdString(StartIndex, CmdLen, Switches.s )
                        
        Protected sCompArg.s, sComIndex, char.c
        
        For sComIndex = StartIndex To CmdLen
            
            char.c = Asc(Mid(Switches,sComIndex,1))
            Select char
                Case 'a' To 'z': sCompArg + Chr( char )
                Case 'A' To 'Z': sCompArg + Chr( char )
                Case '0' To '9': sCompArg + Chr( char )
                Case 0, 32
                    Break
            EndSelect    
        Next 
        ProcedureReturn sCompArg
        
    EndProcedure  
    ;
    ;
    ;
    Procedure.s DOS_Argv_MameHelp(Args.s)
        
        ;
        ; Komandozeilen Hilfe für MAME. 
        ; z.b hat man -flop1 %s -flop2 %s -hard %s in der Argument zeile aber in den Slots ist nun das Harddisk Image nicht drinne
        ; lädt Mame nicht und man muss wieder umkonfigueren. Diese Routine soll überflüssige Mame befehle entfernen.
        Structure MameCommands
            CMD.s
            POS.i
            NUM.i
        EndStructure

        
        NewList MameCommands.MameCommands()
        AddElement(MameCommands()): MameCommands()\CMD = "-flop1"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop2"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop3"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop4"
        AddElement(MameCommands()): MameCommands()\CMD = "-flop5"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop6"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop7"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop8"         
        AddElement(MameCommands()): MameCommands()\CMD = "-flop"    ; (auch -flop1-8?)        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard1"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard2"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard3"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard4"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard5"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard6"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard7"        
        AddElement(MameCommands()): MameCommands()\CMD = "-hard8"
        AddElement(MameCommands()): MameCommands()\CMD = "-hard"    ;   (auch -hard1-8?)
        AddElement(MameCommands()): MameCommands()\CMD = "-cdrom"   ;        
        
        Protected  szArgsCopy.s = Args, Count.i, Medium.s, DevCount.i = -1, MameCount.i = -1
        
        ResetList( MameCommands() )
        Count = CountString(szArgsCopy, Chr(45))
        
        PosCont.i = 0
        NrCount.i = -1
        
        For sz = 1 To Count
            ForEach MameCommands()                
                
                Pos = FindString( szArgsCopy, MameCommands()\CMD, PosCont+1)
                
                If (Pos > 0)
                    PosCont = Pos
                    NrCount + 1
                    MameCommands()\POS = PosCont
                    MameCommands()\NUM = NrCount  ; 
                EndIf                    
            Next
        Next
            
        For x = 0 To 3            
            Medium = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev"+Str(x),"",Startup::*LHGameDB\GameID,"",1):  
            If ( Len(Medium) > 0 )
                DevCount + 1
            EndIf    
        Next    
        
        ResetList( MameCommands() )
        ForEach MameCommands() 
            If ( MameCommands()\POS > 0 )
                MameCount + 1
            EndIf
        Next
       
        If (DevCount < MameCount)              
            ResetList( MameCommands() )
                                    
            ForEach MameCommands() 
                If ( MameCommands()\NUM = MameCount )                    
                    Args = ReplaceString( Args, MameCommands()\CMD, "", #PB_String_CaseSensitive, MameCommands()\POS)
                    MameCount - 1
                    ResetList( MameCommands() )
                EndIf
                               
                If ( MameCount = -1 ) Or ( DevCount = MameCount)
                    Break
                EndIf                        
            Next                        
        EndIf                      
        
        FreeList( MameCommands() )
        
        ProcedureReturn Args        
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; 
    ;****************************************************************************************************************************************************************    
    Procedure.s DOS_Argv_GetSlotContent(Args.s, ArgIndex.i)
        Protected s.s
        
        s.s = Mid(Args,ArgIndex,1)                
        If ( s =  "%" )
            s.s + Mid(Args,ArgIndex+1,1)
            If ( s =  "%s" )                         
                s.s + Mid(Args,ArgIndex+2,1)
                If ( s =  "%sc" )        
                    ProcedureReturn s
                Else
                    s = Trim(s)
                    If ( s =  "%s" )
                        ProcedureReturn s
                    EndIf    
                EndIf    
            EndIf
        EndIf      
        ProcedureReturn ""
        
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ; Section Einstellungen setzen
    ;****************************************************************************************************************************************************************    
    Procedure  DOS_Prepare_Argument_Settings()
        Startup::*LHGameDB\Settings_NoBorder = #False
        Startup::*LHGameDB\Settings_NBNoShot = #False
        Startup::*LHGameDB\Settings_Minimize = -1 ; -1 = Commando Wurde nicht angebeben.
        Startup::*LHGameDB\Settings_Asyncron = #False
        Startup::*LHGameDB\Settings_aProcess = #False
        Startup::*LHGameDB\Settings_DwmUxsms = #False
        Startup::*LHGameDB\Settings_Taskbar  = #False
        Startup::*LHGameDB\Settings_Explorer = #False
        Startup::*LHGameDB\Settings_NBCenter = #False
        Startup::*LHGameDB\Settings_LokMouse = #False        
        Startup::*LHGameDB\Settings_OvLapped = #False
        Startup::*LHGameDB\Settings_Affinity = -1; -1 = Commando für die Zugehörigkeit wird nicht benutzt
        Startup::*LHGameDB\Settings_bCompatM = #False
        Startup::*LHGameDB\Settings_sCmpFile = ""   ; Reset String
        Startup::*LHGameDB\Settings_sCmpArgs = ""   ; Reset String
        Startup::*LHGameDB\Settings_FreeMemE = #False   ; Free Memory (For 32Bit, 4GB > Over Size 3.2GB) 
        Startup::*LHGameDB\Settings_Schwelle = -1
        Startup::*LHGameDB\Settings_bBlockFW = #False
        Startup::*LHGameDB\Settings_bNoOutPt = #True; Stand kein Output
        Startup::*LHGameDB\Settings_GetSmtrc = #True;
        Startup::*LHGameDB\Settings_bSaveLog = #False;
        Startup::*LHGameDB\Settings_hkeyKill = #True ;
        Startup::*LHGameDB\Settings_hkeyMMBT = #True 
        Startup::*LHGameDB\Settings_fMonitor = #False;
        Startup::*LHGameDB\Settings_MameHelp = #False;  
        Startup::*LHGameDB\Settings_aExecute = #False
        Startup::*LHGameDB\Settings_SaveTool = #False        
        
        Startup::*LHGameDB\vKeyActivShot = #False       ; Einstellung für den Loop
        Startup::*LHGameDB\vKeyActivKill = #False       ; Einstellung für den Loop  
        Startup::*LHGameDB\vKeyActivMMBT = #False       ; Einstellung für den Loop         
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Section Set Media Device
    ;****************************************************************************************************************************************************************    
    
    
    Procedure.s DOS_Device(Args.s, CheckPrg.s, sSlot.i = 0, FullPath.s = "")
        
        Protected s.s, Device1$, Device2$, Device3$, Device4$, DevPosition1 = -1, DevPosition2 = -1, DevPosition3 = -1, DevPosition4 = -1, CommandPos.i = -1, NoQuotes.i = -1, nq.s,  ArcSupport.i = -1
        
        DOS_Prepare_Argument_Settings()
        
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + #CR$ +"#"+#TAB$+" #Commandline Support : =======================================")   
        ;
        ; Medien Gespeichert. Prüfen wir
        ;
        ; Lege die Medien in die Strings Device1$ bis 4
        
        Debug Args
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)
            If ( s = "%" )
                ;
                ;Besonderes Zeichen aus der Commandline gefunden. Prüfen wir die nächste Position
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%s" )                    
                    ;
                    ; Winvice example "Datei.d64:Programm.prg"
                     
                    If      ( DevPosition1 = -1 )                                
                        DevPosition1 = ArgIndex: s.s = ""
                        
                    ElseIf  ( DevPosition2 = -1 )                                   
                        DevPosition2 = ArgIndex: s.s = ""
                        
                    ElseIf  ( DevPosition3 = -1 )                                   
                        DevPosition3 = ArgIndex: s.s = ""
                        
                    ElseIf  ( DevPosition4 = -1 )   
                        DevPosition4 = ArgIndex: s.s = "" 
                        Break
                    EndIf                                 
                EndIf                                
            EndIf
            
        Next ArgIndex 
        
        
        ;
        ;
        ; Block Programm in Firewall
        szCommand.s = "%blockfw"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_bBlockFW = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Block Firewall Net (Activ)")  
        EndIf         
            
        ;
        ;
        ; Command: NoBorder
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)
            If ( s = "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%n" )
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%nb" )
                        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: NoBorder (Activ)")                         
                        Startup::*LHGameDB\Settings_NoBorder = #True
                        s.s + Mid(Args,ArgIndex+3,1)
                        
                        If ( s =  "%nbc" )                        
                            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: NoBorder (Activ) ( +Center Window )")                         
                            Startup::*LHGameDB\Settings_NBCenter = #True
                            s.s + Mid(Args,ArgIndex+4,1)
                            
                            If ( s =  "%nbcb" )
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: NoBorder (Activ) ( +Remove Style #OverlappedWindow )")  
                                Startup::*LHGameDB\Settings_OvLapped = #True
                            EndIf                            
                        EndIf
                        
                        If ( s =  "%nbb" ) 
                            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: NoBorder (Activ) ( +Remove Style #OverlappedWindow )")  
                            Startup::*LHGameDB\Settings_OvLapped = #True                                
                        EndIf   

                        For NBIndex = 1 To 9
                            NBTime.s = Str(NBIndex)                                                        
                            If ( Mid(Args,ArgIndex+5,1) =  NBTime) And (s =  "%nbcb")
                                
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline:  NoBorder Time ["+Str(NBIndex+1)+" ] (Activ)")
                                Startup::*LHGameDB\Settings_NoBoTime = NBIndex*255  
                                s.s + Mid(Args,ArgIndex+5,1)
                                Break;
                            ElseIf ( s =  "%nbc"+NBTime Or s =  "%nbb"+NBTime)
                                
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline:  NoBorder Time ["+Str(NBIndex+1)+" ] (Activ)")
                                Startup::*LHGameDB\Settings_NoBoTime = NBIndex*255  
                                Break;
                            ElseIf (s =  "%nb"+NBTime)
                                
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline:  NoBorder Time ["+Str(NBIndex+1)+" ] (Activ)")
                                Startup::*LHGameDB\Settings_NoBoTime = NBIndex*255  
                                Break;
                            EndIf                             
                        Next
                                    
                        Args = DOS_TrimArg(Args.s, s)     
                        Break;
                    EndIf    
                EndIf
            EndIf            
        Next ArgIndex 
        
       ; Einstellung für Get System Metrics
        If ( Startup::*LHGameDB\Settings_NoBorder = #True )
            szCommand.s = "%nbgsm"
            
            ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
            If ( ArgPos > 0 )
                Args = DOS_TrimArg(Args.s, szCommand.s) 
                Startup::*LHGameDB\Settings_GetSmtrc = #False
            EndIf            
        EndIf    
        
        
        ;
        ; Einstellung: Deaktiviere Screenhsot Capture
        If ( Startup::*LHGameDB\Settings_NoBorder = #True )                    
            szCommand.s = "%nosht"
            ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
            If ( ArgPos > 0 )
                Args = DOS_TrimArg(Args.s, szCommand.s) 
                Startup::*LHGameDB\Settings_NBNoShot  = #True
            EndIf  
        EndIf
        
        ;
        ; Einstellung: Für die Auswahl der Taste für die Speicherung des Screenshots
        If ( Startup::*LHGameDB\Settings_NoBorder = #True ) 
            If ( Startup::*LHGameDB\Settings_NBNoShot  = #False )                
                szCommand.s = "%nbkeym"
                Startup::*LHGameDB\Settings_hkeyShot  = #Null
                ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
                If ( ArgPos > 0 )
                    Args = DOS_TrimArg(Args.s, szCommand.s) 
                    Startup::*LHGameDB\Settings_hkeyShot  = #MOD_SHIFT
                EndIf   
            EndIf  
        EndIf        
        
        ;
        ;
        ; Command: Set Affinity         
            For  ArgIndex = 1 To Len(Args)            
                s.s = Mid(Args,ArgIndex,1)
                If ( s = "%" )
                    s.s + Mid(Args,ArgIndex+1,1)
                    If ( s =  "%c" )
                        s.s + Mid(Args,ArgIndex+2,1)
                        If ( s =  "%cp" )
                            s.s + Mid(Args,ArgIndex+3,1)
                            If ( s =  "%cpu" )
                                s.s + Mid(Args,ArgIndex+4,1)
                                
                                If ( s =  "%cpuf" )
                                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Zugehörigkeit Alle CPUS (Activ)")                         
                                    Startup::*LHGameDB\Settings_Affinity = 999
                                    Args = DOS_TrimArg(Args.s, s) 
                                    Break;
                                Else
                                    For CPUIndex = 0 To 64
                                        CPUNum.s = Str(CPUIndex)
                                        If ( s =  "%cpu"+CPUNum )
                                            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Zugehörigkeit ["+Str(CPUIndex+1)+" CPU] (Activ)") 
                                            Startup::*LHGameDB\Settings_Affinity = CPUIndex
                                            Args = DOS_TrimArg(Args.s, s) 
                                            Break;
                                        EndIf
                                    Next
                                    Break    
                                EndIf                                                                           
                            EndIf
                        EndIf    
                    EndIf
                EndIf            
            Next ArgIndex 
            
            
            
            
        ;
        ;
        ; Command: Free memory
            For  ArgIndex = 1 To Len(Args)            
                s.s = Mid(Args,ArgIndex,1)
                If ( s = "%" )
                    s.s + Mid(Args,ArgIndex+1,1)
                    If ( s =  "%f" )
                        s.s + Mid(Args,ArgIndex+2,1)
                        If ( s =  "%fm" )
                            s.s + Mid(Args,ArgIndex+3,1)
                            
                            If ( s =  "%fmm" )                        
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Freemory External programm (Activ)")                         
                                Startup::*LHGameDB\Settings_FreeMemE = #True                                                                
                                
                                SchwellenMemory.s = ""
                                
                                For SWIndex = 0 To 4
                                    NumCharc.c = Asc( Mid(Args,ArgIndex + 4 + SWIndex,1) )
                                    
                                    If ( NumCharc >= 48 And NumCharc <= 57 )                                    
                                        
                                        SchwellenMemory + Chr(NumCharc)
                                        Continue
                                    Else
                                        Break
                                    EndIf    
                                Next    
                                
                                If ( SchwellenMemory )
                                    Size.q = Val( SchwellenMemory )
                                    
                                    If ( Size = 0 )
                                        Size = -1
                                    ElseIf  Size > 1 
                                        
                                        If ( Size > 3000 )                                            
                                            Size = 3000
                                        EndIf
                                        
                                        Size * 1024 
                                        Size * 1024                                                                                                                                                 
                                                                             
                                    EndIf                                      
                                    
                                    SchwellenMemory = MathBytes::ConvertFileSize(Size.q,0,1)                                                                  
                                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Freemory "+SchwellenMemory+" (Activ)")                                                
                                      
                                    Startup::*LHGameDB\Settings_Schwelle = Size
                                    
                                    Break
                                EndIf
                                
                            EndIf
                            Break
                        EndIf                                                    
                    EndIf    
                EndIf           
            Next ArgIndex 
            
                      
        
                  
        ;
        ;
        ; Command: Asyncron                
        ;For  ArgIndex = 1 To Len(Args)
        ;    
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%a" )
        ;            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Asyncron (Activ)")                         
        ;            Startup::*LHGameDB\Settings_Asyncron = #True
        ;            Args = DOS_TrimArg(Args.s, s) 
        ;        EndIf    
        ;    EndIf                                   
        ;Next ArgIndex 
        
        
        
        ;
        ;
        ; Command: NoQuotes                
        ;For  ArgIndex = 0 To Len(Args)
        ;    
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%n" )
        ;            s.s + Mid(Args,ArgIndex+2,1)
        ;            If ( s =  "%nq" )                    
        ;                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Dont Use Double Quotes (Activ)")      
        ;                NoQuotes = 1
        ;                Args = DOS_TrimArg(Args.s, s) 
        ;            EndIf
        ;        EndIf    
        ;    EndIf                                   
        ;Next ArgIndex   
        
        
        ;
        ;
        ; Command: Archive Support               
        ;For  ArgIndex = 1 To Len(Args)
        ;    
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%p" )
        ;            s.s + Mid(Args,ArgIndex+2,1)
        ;            If ( s =  "%pk" )                    
        ;                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
        ;                ArcSupport = 1
        ;                Args = DOS_TrimArg(Args.s, s) 
        ;            EndIf
        ;        EndIf    
        ;    EndIf                                   
        ;Next ArgIndex   
        
        ;
        ;
        ; Command: Minimize        
        ;For  ArgIndex = 1 To Len(Args)
            
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%m" )
        ;            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Minimze (Activ)")                    
        ;            Startup::*LHGameDB\Settings_Minimize = #True
        ;            Args = DOS_TrimArg(Args.s, s) 
        ;        EndIf    
        ;    EndIf
        ;Next ArgIndex 
        

                             
            
        ;
        ;
        ; Aktiveren des Alternativen process
        szCommand.s = "%altexe"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_aExecute = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Alternativer Process")  
        EndIf             
       
        ;
        ;
        ; Aktiveren des Mame Helper
        szCommand.s = "%mmhlp"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_MameHelp = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Mame Help")  
        EndIf  
                        
        ;
        ;
        ; Disable Hotkey
        szCommand.s = "%nhkeyt"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_hkeyKill = #False
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Hotkey: Terminate Programm (Ausgeschaltet)")  
        EndIf          
         
        ;
        ;
        ; Enable Output
        szCommand.s = "%shout"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_bNoOutPt = #False
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Disable Output (Activ)")  
        EndIf  
        
        ;
        ;
        ; Save Support
        szCommand.s = "%savetool"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_SaveTool = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Save Support (Backup and Restore)")  
        EndIf 
           
        ;
        ;
        ; Redirect Output
        szCommand.s = "%svlog"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_bSaveLog = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Redirect Output (Activ)")  
         EndIf   
         
        ;
        ;
        ; Aktiveren Monitoring
        szCommand.s = "%wmon"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_fMonitor = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Monitoring Disk Activity")  
        EndIf     
         
        ;
        ;
        ; Command: Lock Mouse in Window
        szCommand.s = "%lck"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_LokMouse = #True 
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Mouse Lock (Activ)")   
        EndIf          
         
        ; Zwei Buchstaben ============================================================================================================================================         
        ;
        ;
        ; Command: Hide, Unhide Explorer 
        szCommand.s = "%ex"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_Explorer = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")    
        EndIf         
        ;
        ;
        ; Command: NoQuotes  
        szCommand.s = "%nq"         
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             NoQuotes = 1
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Dont Use Double Quotes (Activ)")  
        EndIf 
         
        ;
        ;
        ; Command: Archive Support   
        szCommand.s = "%pk"         
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             ArcSupport = 1
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")  
         EndIf 
         
        ;
        ;
        ; Command: Hide, Unhide Taskbar 
        szCommand.s = "%tb"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_Taskbar = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")  
        EndIf 
                
        ;
        ;
        ; Command: Hide, Unhide Explorer 
        szCommand.s = "%ux"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_DwmUxsms = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")  
        EndIf  
        
        ; Einzelne Buchstaben ============================================================================================================================================
        ;
        ;
        ; Command: Minimize    
        szCommand.s = "%m"         
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_Minimize = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Minimze (Activ)") 
        EndIf          
        ;
        ;
        ; Command: Asyncron 
        szCommand.s = "%a"          
        ArgPos.i = FindString( Args ,szCommand.s,1,#PB_String_CaseSensitive)
        If ( ArgPos > 0 )
             Args = DOS_TrimArg(Args.s, szCommand.s) 
             Startup::*LHGameDB\Settings_Asyncron = #True
             Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Asyncron (Activ)")      
        EndIf          
        ;
        ;
        ; Command: Hide, Unhide Taskbar 
        ;For  ArgIndex = 1 To Len(Args)
        ;    
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%t" )
        ;            s.s + Mid(Args,ArgIndex+2,1)
        ;            If ( s =  "%tb" )                    
        ;                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
        ;                Startup::*LHGameDB\Settings_Taskbar = #True
        ;                Args = DOS_TrimArg(Args.s, s) 
        ;            EndIf
        ;        EndIf    
        ;    EndIf                                   
        ;Next ArgIndex  
        
        
        ;
        ;
        ; Command: Hide, Unhide Explorer 
        ;For  ArgIndex = 1 To Len(Args)
        ;    
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%e" )
        ;            s.s + Mid(Args,ArgIndex+2,1)
        ;            If ( s =  "%ex" )                    
        ;                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
        ;                Startup::*LHGameDB\Settings_Explorer = #True
        ;                Args = DOS_TrimArg(Args.s, s) 
        ;            EndIf
        ;        EndIf    
        ;    EndIf                                   
        ;Next ArgIndex        
        
        
        
        ;
        ;
        ; Command: Hide, Unhide Explorer 

        ;For  ArgIndex = 1 To Len(Args)
        ;    
        ;    s.s = Mid(Args,ArgIndex,1)                
        ;    If ( s =  "%" )
        ;        s.s + Mid(Args,ArgIndex+1,1)
        ;        If ( s =  "%u" )
        ;            s.s + Mid(Args,ArgIndex+2,1)
        ;            If ( s =  "%ux" )                    
        ;                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
        ;                Startup::*LHGameDB\Settings_DwmUxsms = #True
        ;                Args = DOS_TrimArg(Args.s, s) 
        ;            EndIf
        ;        EndIf    
        ;    EndIf                                   
        ;Next ArgIndex          
        
        
        ;
        ;
        ; Command: Add Windows Compatibility
        ; Ich denke:
        ; als Commando .... %cwin98 %cWinXP
        
        sCmpArg$ = ""
        sCmpMod$ = ""
        sCmpEmu$ = ""
        sCMPFound.i = #False
        
        ArgLen   = Len(Args) 
        For  ArgIndex = 1 To ArgLen           
            s.s = Mid(Args,ArgIndex,1)
            If ( s = "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%c" )                                      
                    sCompArg$ = Compat_GetCmdString(ArgIndex+2, ArgLen, Args )
                                     
                    If Len(sCompArg$) > 0
                        
                        UseModule Compatibility
                        ; Lese OSModi
                        
                        ResetList(CompatibilitySystem())                    
                        For LstIndex = 0 To ListSize(CompatibilitySystem()) 
                            NextElement(CompatibilitySystem())
                            sCmpMod$ = CompatibilitySystem()\OSModus$
                            
                            If UCase( sCompArg$ ) = UCase( sCmpMod$ )
                                
                                Startup::*LHGameDB\Settings_bCompatM = #True                                
                                Startup::*LHGameDB\Settings_sCmpFile = FullPath + CheckPrg          ;Path und Programm der in die Registry geschrieben werden soll
                                
                                If Len(Startup::*LHGameDB\Settings_sCmpArgs) > 0
                                    sCmpMod$ = " " + sCmpMod$ 
                                EndIf
                                
                                Startup::*LHGameDB\Settings_sCmpArgs + UCase( sCmpMod$ )            ;Registry Werte für den Compatibility Modus                                
                                
                                Args     = DOS_TrimArg(Args.s, s+sCompArg$)
                                ArgLen   = Len(Args) 
                                ArgIndex = 0
                                sCMPFound= #True
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Compatibility Mode (Activ)")   
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Modus: "+Startup::*LHGameDB\Settings_sCmpArgs)  
                                Break
                                Continue
                            EndIf    
                                
                        Next
                        
                        ; Lese Emulations Modi
                        ResetList(CompatibilityEmulation())                    
                        For LstIndex = 0 To ListSize(CompatibilityEmulation()) 
                            NextElement(CompatibilityEmulation())
                            sCmpEmu$ = CompatibilityEmulation()\Modus
                            
                            If UCase( sCompArg$ ) = UCase( sCmpEmu$ )
                                
                                Startup::*LHGameDB\Settings_bCompatM = #True                                
                                Startup::*LHGameDB\Settings_sCmpFile = FullPath + CheckPrg          ;Path und Programm der in die Registry geschrieben werden soll
                                
                                If Len(Startup::*LHGameDB\Settings_sCmpArgs) > 0
                                    sCmpEmu$ = " " + sCmpEmu$ 
                                EndIf
                                
                                Startup::*LHGameDB\Settings_sCmpArgs + UCase( sCmpEmu$ )            ;Registry Werte für den Compatibility Modus                                
                                
                                Args     = DOS_TrimArg(Args.s, s+sCompArg$)
                                ArgLen   = Len(Args) 
                                ArgIndex = 0
                                sCMPFound= #True
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Compatibility Emulation (Activ)")
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Modus: "+Startup::*LHGameDB\Settings_sCmpArgs)                                  
                                Break
                            EndIf    
                                
                        Next                        
                                       
                        UnuseModule Compatibility     
                        
                        If ( sCMPFound = #False )
                        	;MessageRequester( "vSystem  Support","Compatibility: '" + sCompArg$ + "' nicht gefunden.")
                        	Delay(250)
                        	
                        				  Request::*MsgEx\User_BtnTextL = "Starten"                 
                						  Request::*MsgEx\User_BtnTextR = "Abbruch"                          	
                        	CmpLogResult= Request::MSG(Startup::*LHGameDB\TitleVersion, "Windows Kompatibilitäts-Assistent","Ubekannter Kompatibilitäts Modus: "+#CR$+#CR$+#TAB$+Chr(34)+sCompArg$+Chr(34)+""+#CR$+#CR$+"Weiter?",10,1,"",0,0,DC::#_Window_001)
                        	
                        	SetActiveWindow(DC::#_Window_001)
                        	SetActiveGadget(DC::#ListIcon_001)                        	
                        	Delay(250)
                        	
                        	Select CmpLogResult
	                    		Case 0; Ok                        	
							    Case 1; Abbruch
							    	ProcedureReturn "KZV78EUKIQAH5QS4V4T5C6RGQGB5M"
						    EndSelect	
                        EndIf
                     EndIf                                             
                EndIf
            EndIf            
        Next ArgIndex  
        
        
        
        Device1$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",Startup::*LHGameDB\GameID,"",1):  
        Device2$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev1","",Startup::*LHGameDB\GameID,"",1): 
        Device3$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev2","",Startup::*LHGameDB\GameID,"",1): 
        Device4$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev3","",Startup::*LHGameDB\GameID,"",1):
        
        If IsWindow(DC::#_Window_005)
            ; Quck Start - For C64 File Manager
            ;
           Device1$ = GetGadgetText( DC::#String_102 )
        EndIf   
            
        If ( Len(Device1$) >= 1 ) Or  ( Len(Device2$) >= 1 ) Or ( Len(Device3$) >= 1 ) Or ( Len(Device4$) >= 1 )
            
            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + #CR$ +"#"+#TAB$+" #Adding Files Support : =======================================") 
            
            If ( Len(Device1$) >= 1 )
                
                Device1$ = Getfile_Portbale_ModeOut(Device1$)
                
                If ( ArcSupport  = 1 )
                    Device1$ = DOS_PKARC(Device1$, 1)
                EndIf
                
                Device1$ = DOS_Device_GetInternalFile(Device1$, 1, CheckPrg)
                
                If (NoQuotes = -1 )
                    Device1$ = DOS_Device_VerifySpace(Device1$)
                EndIf   
                Debug "Loaded Slot 1 Dir /File : " + Device1$
            EndIf
            
            
            If ( Len(Device2$) >= 1 )
                Device2$ = Getfile_Portbale_ModeOut(Device2$)
                
                If ( ArcSupport  = 1 )
                    Device2$ = DOS_PKARC(Device2$, 2)
                EndIf
                
                Device2$ = DOS_Device_GetInternalFile(Device2$, 2, CheckPrg)
                If (NoQuotes = -1 )
                    Device2$ = DOS_Device_VerifySpace(Device2$)
                EndIf              
                
                Debug "Loaded Slot 2 Dir /File : " + Device2$
                
            EndIf
            
            
            If ( Len(Device3$) >= 1 )
                Device3$ = Getfile_Portbale_ModeOut(Device3$)
                
                If ( ArcSupport  = 1 )
                    Device3$ = DOS_PKARC(Device3$, 3)
                EndIf
                
                Device3$ = DOS_Device_GetInternalFile(Device3$, 3, CheckPrg)
                If (NoQuotes = -1 )
                    Device3$ = DOS_Device_VerifySpace(Device3$)
                EndIf               
                
                Debug "Loaded Slot 3 Dir /File : " + Device3$
            EndIf
            
            If ( Len(Device4$) >= 1 )            
                Device4$ = Getfile_Portbale_ModeOut(Device4$)
                
                If ( ArcSupport  = 1 )
                    Device4$ = DOS_PKARC(Device4$, 4)
                EndIf :Device4$ = DOS_Device_GetInternalFile(Device4$, 4, CheckPrg)
                
                If (NoQuotes = -1 )
                    Device4$ = DOS_Device_VerifySpace(Device4$)
                EndIf                 
                
                Debug "Loaded Slot 4 Dir /File : " + Device4$
            EndIf 
            
            Args = Trim(Args)
            
            ;
            ;
            ; Mame/ Mess Helper.
            If ( Startup::*LHGameDB\Settings_MameHelp = #True )
                Args = DOS_Argv_MameHelp(Args.s)
            EndIf    
            ;
            ;
            
            SlotsToUse = CountString(Args,"%sc")    ; Universelles Argument, Kommando übergabe an das programm
            SlotsToUse + CountString(Args,"%s")        
            
            If ( SlotsToUse >= 1 )
                
                For SlotsIndex = 1 To SlotsToUse
                    
                    If ( SlotsIndex > SlotsToUse )
                        Break;
                    EndIf
                    
                    ArgLen = Len(Args)
                    For  ArgIndex = 1 To ArgLen
                        
                        ;
                        ; Routine für das Ausleen von Argumenten in den Media Slots
                        If ( DOS_Argv_GetSlotContent(Args, ArgIndex) = "%sc" )
                            
                            If     ( Len(Device1$) <> 0 )
                                
                                If ( Right(Device1$, 1) = Chr( 34 ) ) And ( Left(Device1$, 1) = Chr( 34 ) )
                                    Device1$ = Mid( Device1$, 2, Len(Device1$)-2 ) 
                                EndIf
                                
                                Args = ReplaceString(Args,"%sc", Device1$,0,ArgIndex,1)
                                Device1$ = "" 
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue 
                                
                            ElseIf ( Len(Device2$) <> 0 )
                                If ( Right(Device2$, 1) = Chr( 34 ) ) And ( Left(Device2$, 1) = Chr( 34 ) )
                                    Device2$ = Mid( Device2$, 2, Len(Device2$)-2 ) 
                                EndIf     
                                
                                Args = ReplaceString(Args,"%sc", Device2$,0,ArgIndex,1)
                                Device2$ = ""  
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue
                                
                            ElseIf ( Len(Device3$) <> 0 )
                                If ( Right(Device3$, 1) = Chr( 34 ) ) And ( Left(Device3$, 1) = Chr( 34 ) )
                                    Device3$ = Mid( Device3$, 2, Len(Device3$)-2 ) 
                                EndIf                                              
                                
                                Args = ReplaceString(Args,"%sc", Device3$,0,ArgIndex,1)
                                Device3$ = ""
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue
                                
                            ElseIf ( Len(Device4$) <> 0 )
                                If ( Right(Device4$, 1) = Chr( 34 ) ) And ( Left(Device4$, 1) = Chr( 34 ) )
                                    Device4$ = Mid( Device4$, 2, Len(Device4$)-2 ) 
                                EndIf                                              
                                
                                Args = ReplaceString(Args,"%sc", Device4$,0,ArgIndex,1)
                                Device4$ = ""
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue                         
                            EndIf
                            
                        ElseIf ( DOS_Argv_GetSlotContent(Args, ArgIndex) = "%s" )
                            If     ( Len(Device1$) <> 0 )
                                Args = ReplaceString(Args,"%s", Device1$,0,ArgIndex,1)
                                Device1$ = ""
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue 
                                
                            ElseIf ( Len(Device2$) <> 0 )
                                Args = ReplaceString(Args,"%s", Device2$,0,ArgIndex,1)
                                Device2$ = ""
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue
                                
                            ElseIf ( Len(Device3$) <> 0 )
                                Args = ReplaceString(Args,"%s", Device3$,0,ArgIndex,1)
                                Device3$ = ""
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue
                                
                            ElseIf ( Len(Device4$) <> 0 )
                                Args = ReplaceString(Args,"%s", Device4$,0,ArgIndex,1)
                                Device4$ = ""
                                ArgIndex = 0
                                ArgLen = Len(Args)
                                Continue                         
                            EndIf
                            
                        ElseIf ( DOS_Argv_GetSlotContent(Args, ArgIndex) = "" )
                            Continue
                        EndIf         
                        
                    Next                   
                Next
            EndIf   
            
        EndIf
        Debug Args
        
        ArgIndex = CountString(Args,"%su")
        If ( ArgIndex > 0 )
            Args = ReplaceString(Args,"%su", "",0,1,ArgIndex)
        EndIf                   
        ;
        ; Prüfe und ersetze die Restlichen %s die nicht benötigt werden obwohl diese gesetzt sind
        ArgIndex = CountString(Args,"%sc")
        If ( ArgIndex > 0 )
            Args = ReplaceString(Args,"%sc", "",0,1,ArgIndex)
        EndIf
        
        ;
        ; Prüfe und ersetze die Restlichen %s die nicht benötigt werden obwohl diese gesetzt sind     
        ArgIndex = CountString(Args,"%s")
        If ( ArgIndex > 0 )
            Args = ReplaceString(Args,"%s", "",0,1,ArgIndex)
        EndIf        
        
        Args = Trim(Args)
        
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: (Siehe nächste Zeile)" + Chr(13) + "'"+Args+"'")
    

        
        ProcedureReturn Args
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Section Log Outpout    
    ;****************************************************************************************************************************************************************    
    Procedure DOS_Output_SaveLog(SvLogFileIcn$)
                            
            Protected  SvLogMessage$ = "", SvLogErrorMs$ = "error" , SvLogStdout$  = "stdout", SvFileSaved$  = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\"
            Protected  SvLogginFile$ = "", SvLogResult   = 0       , SvLogErrorSz.q= 0       , SvLogStdOutSz.q= 0 
                                    
            SvLogErrorSz = FileSize( SvFileSaved$ + SvLogErrorMs$ + ".txt" )
            Select SvLogErrorSz
                Case 0 To 60
                    DeleteFile(SvFileSaved$ + SvLogErrorMs$ + ".txt")
                  Default
                    SvLogResult   + 1
                    SvLogMessage$ = SvLogErrorMs$ + " Datei vorhanden"
                    SvLogginFile$ = SvFileSaved$ + SvLogErrorMs$ + ".txt"
            EndSelect       
                                    
            SvLogStdOutSz= FileSize( SvFileSaved$ + SvLogStdout$ + ".txt" )
            Select SvLogErrorSz
                Case 0 To 60
                    DeleteFile(SvFileSaved$ + SvLogStdout$ + ".txt")
                  Default
                    SvLogResult   + 2
                    SvLogMessage$ = SvLogStdout$ + " Datei vorhanden"
                    SvLogginFile$ = SvFileSaved$ + SvLogStdout$ + ".txt"
            EndSelect             
                       
            If ( SvLogResult = 3 )
                SvLogMessage$ ="Stdout / Error Dateien vorhanden"
            EndIf    
            
                       
            If ( SvLogResult > 1)               
            	
            	
                Select  SvLogResult                   
                    Case 2:  Request::*MsgEx\User_BtnTextM = "Stdout Öffnen": SvFileSaved$ + SvLogErrorMs$ + ".txt"    
                    Default: Request::*MsgEx\User_BtnTextM = "Error Öffnen" : SvFileSaved$ + SvLogStdout$  + ".txt"
                EndSelect
                
                Request::*MsgEx\User_BtnTextL = "Ok"                 
                Request::*MsgEx\User_BtnTextR = "Verzeichnis"                    
                SvLogResult = Request::MSG(Startup::*LHGameDB\TitleVersion, SvLogMessage$,"Gespeichert in " + SvFileSaved$,16,2,SvLogFileIcn$,0,0,DC::#_Window_001)
                
                
                Select SvLogResult
                    Case 0; Ok
                    Case 1; Verzeichniss Öffnen
                        FFH::ShellExec(GetPathPart( SvFileSaved$ ), "explore")
                    Case 2; Öffnen
                        FFH::ShellExec(SvLogginFile$, "open")
                EndSelect                           
            EndIf    
           
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Section Log Outpout Anlgen   
    ;****************************************************************************************************************************************************************      
    Procedure DOS_Output_CreateLog(*Params.PROGRAM_BOOT)
            ;
            ; Log Datei anlegen?
            If  ( Startup::*LHGameDB\Settings_bSaveLog = #True )
                
                ;
                ; Verzeichnis Anlegen
                Select FileSize( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\")
                    Case -1: CreateDirectory( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" )                    
                EndSelect 
                
								Date.s = FormatDate("%yyyy-%mm-%dd#", Date())
								Time.s = FormatDate("%hh-%ii-%ss"		, Date())
								
                If FileSize( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\Error.txt") > 0
                	RenameFile( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\Error.txt",
                	            Startup::*LHGameDB\Base_Path + "Systeme\LOGS\Errors-Preview"+"["+ Date + Time + "]"+".txt")
                EndIf
                
                If FileSize( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\StdOut.txt") > 0
                	RenameFile( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\StdOut.txt",
                	            Startup::*LHGameDB\Base_Path + "Systeme\LOGS\StdOut-Preview"+"["+ Date + Time + "]"+".txt")
								EndIf
								
                *Params\ErrorLg =  OpenFile( #PB_Any,  Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" + "Error.txt")      
                *Params\StdOutL =  OpenFile( #PB_Any,  Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" + "StdOut.txt")
                
                If ( *Params\ErrorLg )
                    WriteString(*Params\ErrorLg, "vSystems Logging: ERRORS" + #CR$ + #CR$ )
                EndIf
                If ( *Params\StdOutL )
                    WriteString(*Params\StdOutL, "vSystems Logging: Standard" + #CR$ + #CR$ )
                EndIf            
            EndIf        
          EndProcedure
    ;****************************************************************************************************************************************************************
    ; Section Save Funktion Backup
    ;****************************************************************************************************************************************************************      
		Procedure DOS_SaveSupport_Backup(*Params.PROGRAM_BOOT)
			
			
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Section Save Funktion Restore 
    ;****************************************************************************************************************************************************************      
    Procedure DOS_SaveSupport_Restore(*Params.PROGRAM_BOOT)
    	
    	
    EndProcedure     
    ;****************************************************************************************************************************************************************
    ; Section Programm Starten
		;****************************************************************************************************************************************************************

        	
    Procedure DOS_Prepare()
        
        Protected PrgID.i, Base.i = DC::#Database_001, Table$ = "Programs", LSRowID.i, LSBoxID.i
        
        Startup::*LHGameDB\ExitSignal = #False
        Startup::*LHGameDB\Thread_ProcessName = ""
            
        *Params.PROGRAM_BOOT = AllocateMemory(SizeOf(PROGRAM_BOOT))
        InitializeStructure(*Params, PROGRAM_BOOT)
        
        LSRowID = GetGadgetItemData(DC::#ListIcon_001,GetGadgetState(DC::#ListIcon_001))
        LSBoxID = GetGadgetState(DC::#ListIcon_001)
        If ( LSBoxID = -1 )
            ProcedureReturn
        EndIf
        
        PrgID = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","",Startup::*LHGameDB\GameID,"",1)):  
        
            *Params\PrgPath         = ""        
            *Params\Program         = Getfile_Portbale_ModeOut(ExecSQL::nRow(Base,Table$,"File_Default","",PrgID,"",1)) 
            *Params\WrkPath         = Getfile_Portbale_ModeOut(ExecSQL::nRow(Base,Table$,"Path_Default","",PrgID,"",1))
            *Params\Command         = ExecSQL::nRow(Base,Table$,"Args_Default","",PrgID,"",1)
            *Params\Logging         = ""
            *Params\ExError         = 0
            *Params\PrgFlag         = #PB_Program_Open
            *Params\StError         = ""           
            
            ;
            ; Normalisiere, 
            *Params\PrgPath         = GetPathPart(*Params\Program)
            *Params\Program         = GetFilePart(*Params\Program)
            ;
            ; Für den Alternativen Process
            *Params\hThread 		= 0 
            *Params\hProcess		= 0
            
            If ( Startup::*LHGameDB\Settings_bSaveLog = #True) Or (Startup::*LHGameDB\Settings_bNoOutPt = #False)
            	*Params\PrgFlag  			= #PB_Program_Open|#PB_Program_Read|#PB_Program_Error
    				EndIf 
            
            If ( Startup::*LHGameDB\Settings_NBNoShot = #False )
                ; Reset NoBorder Handle Vars
                VSystem::System_NoBorder_Handle_Reset()
            EndIf
             
            
            If (Len(*Params\Program) = 0 )	Or	(FileSize(*Params\PrgPath) <> -2 )	Or	(FileSize(*Params\PrgPath + *Params\Program  ) = -1 )
            	
            	;Delay(25)
            	;keybd_event_(#VK_RETURN, 0, 0, #Null)
            	;Delay(250)
            	
            	If (Len(*Params\Program) = 0 )
            		Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to Run. Please Select a Program",2,2,"",0,0,DC::#_Window_001)
            	ElseIf (FileSize(*Params\PrgPath) <> -2 )
            		Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Program Folder Does Not Exists",2,2,"",0,0,DC::#_Window_001)
            	ElseIf (FileSize(*Params\PrgPath + *Params\Program  ) = -1 )
            		
            	;	vItemTool::DialogRequest_Def( "W.T.F: ","No Program to Run. Cant Find it..",2)
            		
            		Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to Run. Cant Find it..",2,2,"",0,0,DC::#_Window_001)
            	EndIf
            	
            	;Delay(250)
            	SetActiveWindow(DC::#_Window_001)            	
            	SetActiveGadget(DC::#ListIcon_001)
              ProcedureReturn
            EndIf               
            
            
            ;
						; Prüfe Nach Speziellen Kommandos
            *Params\Command         = DOS_Device(*Params\Command, *Params\Program, 0, *Params\PrgPath)
            
            ;If *Params\Command  = "KZV78EUKIQAH5QS4V4T5C6RGQGB5M"
            ;	ProcedureReturn
            ;EndIf	
            
            Debug #CR$+ "Volle Commandline: " +#CR$+ *Params\Command
            
            ;
            ; Log Datei anlegen?
            DOS_Output_CreateLog(*Params)
            
            ;
            ; Markiere Item welches gestartet ist
            vItemTool::Item_Process_Loaded()
            
            If ( Startup::*LHGameDB\Settings_Asyncron = #False )
            	
	            If ( Startup::*LHGameDB\Settings_fMonitor = #True )
	                 ;
	                 ; Aktviere MONITOR Disk Activity
	                 Monitoring::DeActivate()
	                 Delay( 5 )
	                 Monitoring::Activate("C:\")
	            EndIf             
	            
	            If ( 	Startup::*LHGameDB\Settings_SaveTool = #True )
	            			Debug "SaveSupport: Init Restore"
	            	
	            			SaveTool::SaveContent_Read()		; Config Liste Initialiseren
	            	
	            			If ( SaveTool::SaveFile_GetRestore() = #True )
	            		
	            				DoDelay.i = SaveTool::SaveFile_GetRestoreDelay()
	            				Debug "SaveSupport: Restore Delay = " +Str(DoDelay) 
	            				Debug "SaveSupport: Restore Copy"
	            										SaveTool::SaveContent_Restore(1,0)           				            				
	            				Delay(DoDelay)
	            			Else
	            				Debug "SaveSupport: Restore Clean List Only"
	            				SaveTool::CleanListing()
	            			EndIf	
	            EndIf			            
	          EndIf
	            
	            
            ProgrammMutex  = CreateMutex()
            _Action1 = 0 
            _Action1 = CreateThread(@DOS_Thread(),*Params)                                             
            
            
            ;
            ; ======================================================================================== Loop
            While IsThread(_Action1) 
               
                Delay(1)                                                       
                vKeys::Init_Capture()
                
                ;Delay(1)
                ;vKeys::Init_MM3DFocus()                  
                
                Delay(1)
                vKeys::Init_Terminate()                        
                               

                ProgramEventID = WaitWindowEvent()             
                If ( ProgramEventID = #WM_HOTKEY )
                	Select EventwParam()
                			
                		Case 10
                			If  ( Startup::*LHGameDB\NBWindowhwnd > 0 ) And ( Startup::*LHGameDB\Settings_NBNoShot = #False )                               
                				Beep_(257,150)
                				vSystem::Capture_Screenshot( GetFilePart(*Params\Program,#PB_FileSystem_NoExtension))
                			EndIf
                			
                		Case 20                  			
                			If ( ( vSystem::Terminate_Programm(*Params\hThread) = 0 ) )
                				Break
                			EndIf
                			
                		Case 30 
                			If ( Startup::*LHGameDB\Settings_hkeyMMBT = #True )
                			EndIf                            
                	EndSelect
                EndIf
              
              vSystem::LCD_Info(#True, #True)
                ;While WindowEvent()
                ;Wend  
            Wend  
            ; ======================================================================================== Loop
            
            ;
            ; Minimiert vSystems/ Setzt den Zustand des programms Wieder her. Minimiren befindet sich Modul 
            ; DOS_Thread_GameMode(*Params.PROGRAM_BOOT)
            ; Sollte das Programm Asyncron gestartet werden lass das Window in Ruhe
            If ( Startup::*LHGameDB\Settings_Asyncron = #False )
                 Startup::*LHGameDB\Settings_Minimize = DOS_Thread_Minimze(Startup::*LHGameDB\Settings_Minimize)  
            
               
		            If ( Startup::*LHGameDB\Settings_fMonitor = #True )
		                ;
		                ; Aktviere Monitor Disk Activity
		                Monitoring::DeActivate()
		                Startup::*LHGameDB\Settings_fMonitor = #False
		            EndIf
		            
		            
		            If ( 	Startup::*LHGameDB\Settings_SaveTool = #True )
		            			Debug "SaveSupport: Init Backup"
		            			SaveTool::SaveContent_Read()		; Config Liste Initialiseren
		            			
		            			If ( SaveTool::SaveFile_GetBackup() = #True )            	          			
		            					  DoDelay.i = SaveTool::SaveFile_GetBackupDelay()
		            						DoCmprs.i = SaveTool::SaveFile_GetBackupCompress() 
		            						Debug "SaveSupport: Backup Delay = " +Str(DoDelay)
		            						Delay( DoDelay )            				
		            										Debug "SaveSupport: Backup Copy"
		            										SaveTool::SaveContent_Backup(2,0)
		            				 					 
		            						If ( DoCmprs = #True )
		        											Debug "SaveSupport: Backup Compress Start"
		        											Delay(25)
		        											SaveTool::SaveContent_Read()
		            				 				 	SaveTool::SaveContent_Compress()
		            				 				 	Delay(25)
		            				 				 	SaveTool::CleanListing()
		            				 				 	Debug "SaveSupport: Backup Compress Finished"
		            						EndIf 				  
		            					Else
		            				Debug "SaveSupport: Backup Clean List Only"
		            				SaveTool::CleanListing()
		            			EndIf	           			            	    
		           	EndIf
            EndIf 		
   
            
            ;
						;
            If (Startup::*LHGameDB\Settings_bNoOutPt = #False)     
            	If ( Len(*Params\Logging) >= 1 )  Or  ( Len(*Params\StError) >= 1 )   
            		
            		If (Startup::*LHGameDB\ExitSignal = #True)
            			If ( Len(*Params\Logging) >= 1 ) 
            				*Params\Logging + Chr(13) + "Programm Abruch vom User"
            			EndIf
            			
            			If ( Len(*Params\StError) >= 1 )  
            				*Params\StError + Chr(13) + "Programm Abruch vom User"
            			EndIf
            		EndIf            		
            		ReturnCodes = CountString(*Params\StError, Chr(13) )
            		NewLines    = CountString(*Params\StError, Chr(10) )
            		Delay(3)
            		Request::MSG(Startup::*LHGameDB\TitleVersion, "("+Str(ReturnCodes)+ "/ "+Str( NewLines) +") W.T.F. Output: " + GetFilePart(*Params\Program),*Params\Logging + Chr(13) + Chr(13) + *Params\StError,2,2,*Params\PrgPath + *Params\Program,0,0,DC::#_Window_001)
            		SetActiveWindow(DC::#_Window_001)
            		SetActiveGadget(DC::#ListIcon_001)                         
            	EndIf         
            ;
            ;
						ElseIf  ( Startup::*LHGameDB\Settings_bSaveLog = #True ) ; And (Startup::*LHGameDB\Settings_bNoOutPt = #False) 
							
								If (Startup::*LHGameDB\ExitSignal = #True)
									WriteStringN(*Params\ErrorLg, Chr(13) + "Programm Abruch vom User"  ) 
									WriteStringN(*Params\StdOutL, Chr(13) + "Programm Abruch vom User"  )
								EndIf
                If ( *Params\ErrorLg ) > 0
                    CloseFile( *Params\ErrorLg )
                EndIf
                If ( *Params\StdOutL ) > 0
                    CloseFile( *Params\StdOutL )
                EndIf
                ; Saved Log? Message to the user
                DOS_Output_SaveLog(*Params\PrgPath + *Params\Program)
            EndIf
            

		
            ;
            ; Markiere Item welches gestartet ist
            vItemTool::Item_Process_UnLoaded()
            
            ;
            ; NoBorder, Screenshot Aktiv
            If  ( Startup::*LHGameDB\NBWindowhwnd > 0 ) And ( Startup::*LHGameDB\Settings_NBNoShot = #False )    
                UnregisterHotKey_( WindowID(DC::#_Window_001) , 10)
                VSystem::System_NoBorder_Handle_Reset()               
            EndIf   
            
            If ( Startup::*LHGameDB\Settings_hkeyKill = #True )
                UnregisterHotKey_( WindowID(DC::#_Window_001) , 20)
            EndIf    
            
           
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Versteckt/ Öffnet die Screenshots
		;****************************************************************************************************************************************************************
    Procedure.i Splitter_GetLastPosition(CurrentHeight.i,WindowHeight.i)
    	
    	Protected ResultHeight.i
    	
    	Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")
    	If ( Rows > 0 )
    		ProcedureReturn ExecSQL::iRow(DC::#Database_001,"Gamebase","SplitHeight",0,Startup::*LHGameDB\GameID,"",1)    				
    	Else
    		
    		If ( GetGadgetState(DC::#Splitter1) = 0 )
    			;
    			; SplitterGadget is ganz Oben (Fensterhöhe = 0)
    		EndIf
    		
    		If ( GetGadgetState(DC::#Splitter1) = WindowHeight )
    			;
    			; Fenster Höhe ist gleich dem Splitter Gadget
    		EndIf
    		
    		 ResultHeight = Startup::*LHGameDB\LastSplitHeight
    		ProcedureReturn ResultHeight
    	EndIf
    	
    EndProcedure
    ;
		;
    ;
    Procedure PicSupport_Hide_Show()
    	
    	Protected SplitHeight.i        
    	
    	Protected StepPxl.i 		= 3    	
    	Protected CurrentH.i  	= GetGadgetState(DC::#Splitter1 )    	
    	Protected MaxSplitH.i 	= ( WindowHeight(DC::#_Window_001 ) - 62) - GadgetY(DC::#ListIcon_001,#PB_Gadget_WindowCoordinate )
    	Select CurrentH
    			
    		Case 0, MaxSplitH
    			
    			If ( CurrentH = 0 )
    				;
						; GadgetHeight( Startup::*LHImages\ScreenGDID[1] ) 
    				
						; Splitter ist ganz Oben - Setze die höhe auf die Stndar Screenshot grösse
    				Startup::*LHGameDB\LastSplitHeight = Startup::*LHGameDB\hScreenShotGadget
    				SetGadgetState(DC::#Splitter1, Startup::*LHGameDB\LastSplitHeight )
    				  
    				ProcedureReturn
    			EndIf

    			;
    			; Splitter ist ganz unten   			    			  			    	
    			SetGadgetState(DC::#Splitter1, Startup::*LHGameDB\LastSplitHeight)
    		Default 
    			;
    			; Position ist nicht 0 oder gnaz unten, Position merken    			
    			Startup::*LHGameDB\LastSplitHeight = CurrentH   			    			
    			
    			SetGadgetState(DC::#Splitter1,MaxSplitH)
    	EndSelect
    	
    	ResizeGadget(DC::#ListIcon_001, #PB_Ignore, #PB_Ignore,#PB_Ignore,GadgetHeight(DC::#Contain_02))
    	
    	ProcedureReturn                
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Setzt die Höhe des Splitters
    ;****************************************************************************************************************************************************************    
    Procedure Splitter_SetGet(Get = #True, Height = 289)      
       ; Höhe Setzen, aus der DB lesen
        If  ( Get = #True )
            SetGadgetState(DC::#Splitter1,GadgetHeight(DC::#Contain_02)) 
            Height = ExecSQL::iRow(DC::#Database_001,"Gamebase","SplitHeight",0,Startup::*LHGameDB\GameID,"",1)
            If ( Height = 0 )
                Height = 289
            EndIf
            SetGadgetState(DC::#Splitter1,Height) 
            ResizeGadget(DC::#ListIcon_001, #PB_Ignore, #PB_Ignore,#PB_Ignore,GadgetHeight(DC::#Contain_02))              
        Else
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", Str(Height),Startup::*LHGameDB\GameID)
            ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight", Str(Height),1)                
        EndIf                
    EndProcedure   

    ;****************************************************************************************************************************************************************
    ; Ändert die Splitterhöhe 
    ;****************************************************************************************************************************************************************
    Procedure Splitter_SetHeight(SetHeight.i = 289, ThumbnailMode = #False, NewWindowHeight = #False, SetWindowHeight = 0)
        ;
        ; Current Splitter height
        Protected CHSplit.i = GadgetHeight(DC::#Contain_02)
        
        ;
        ; Current Listview Height
        Protected CHListe.i = GadgetHeight(DC::#ListIcon_001)
               
        ; 
        Protected StepPxl.i = 3, NewHeight.i = 0, x.i = 0
        
        ;
        ; Thumbnail Screenhot Height
        Protected CHThumb.i = Startup::*LHGameDB\hScreenShotGadget + StepPxl
        If ( ThumbnailMode = #True )
            CHThumb = SetHeight + StepPxl
        EndIf
        
        ;
        ; Maximum Splitter Height/ Auch Übergabe der neuen Fensterhöhe
        Protected MxSplit.i =   ( WindowHeight(DC::#_Window_001 ) - 62) - GadgetY(DC::#ListIcon_001,#PB_Gadget_WindowCoordinate )
        If ( NewWindowHeight )
            Debug "Splitter_SetHeight : *LHGameDB\WindowHeight " + Str(Startup::*LHGameDB\WindowHeight)
            Debug "Splitter_SetHeight : SetWindowHeight        " + Str(SetWindowHeight)
            
            If (Startup::*LHGameDB\WindowHeight = SetWindowHeight)
                ProcedureReturn 
                
            ElseIf (SetWindowHeight = 0)
                MxSplit = 434
                
            ElseIf (SetWindowHeight => Startup::*LHGameDB\WindowHeight)
                MxSplit  + SetWindowHeight
                SetHeight = CHSplit + SetWindowHeight
                
            Else
                MxSplit  - SetWindowHeight
                SetHeight = SetWindowHeight - CHSplit 
            EndIf
            
        EndIf
        
        If ( ThumbnailMode = #False ) And ( NewWindowHeight = #False )
        ;
        ; Frage
            r  = vItemTool::DialogRequest_Num("Neue Höhe einstellen","Höhe Aktuell   : " + Str(CHSplit) + Chr(13) + 
                                                                 "Höhe Maximum   : " + Str(MxSplit) + Chr(13) + 
                                                                 "Thumbnail Größe: " + Str(CHThumb) ,Str(CHSplit))
            If ( r = 1 )
                ProcedureReturn 
            EndIf
            
        
            SetHeight = Val(Request::*MsgEx\Return_String)                     
         EndIf   

        NewHeight = SetHeight
                
        If ( NewHeight > MxSplit )
            ;
            ; Das Fenster (die Liste ist zu klein)
            Request::MSG(Startup::*LHGameDB\TitleVersion, "Thumbnail Splitter Einstellung","Für diese Einstellung ist die Fensterhöhe zu klein.",1,1,"",0,0,DC::#_Window_001 )            
            ProcedureReturn
            
            ;
            ; Begrenze durch die Thumbnail Grösse                                    
            x = MxSplit - CHThumb
                
            NewHeight = x                
            
        ElseIf ( NewHeight = MxSplit )            
            NewHeight = MxSplit
        Else                     
            
            If ( ThumbnailMode )                
                x =  (MxSplit - CHListe) / CHThumb
                If ( x = 0 )
                    x + 1
                EndIf
                
                NewHeight =  MxSplit - (CHThumb * x)
            Else                
                NewHeight = SetHeight
            EndIf    
        EndIf                        
        
        SetGadgetState(DC::#Splitter1,NewHeight) 
        ResizeGadget(DC::#ListIcon_001, #PB_Ignore, #PB_Ignore,#PB_Ignore,GadgetHeight(DC::#Contain_02)) 
        
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", Str(NewHeight),Startup::*LHGameDB\GameID)
        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight", Str(NewHeight),1)            
       
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ; Ändert die Splitterhöhe für ALLE einträge
    ;****************************************************************************************************************************************************************
    Procedure Splitter_SetAll(NoAsk = #False)
        
        Protected Rows.i , result.i, oHeight.i, nHeight.s, strIndex.i, c.c, SetHeight.i, RowID.i
        
        If (NoAsk = #False)
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Splitter Höhe Einstellen","Für alle Einträge die gleiche Höhe einstellen wie von dem Markierten Eintrag?",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            If Result = 1
                ProcedureReturn
            EndIf 
        EndIf    
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
        
        Select Rows
            Case 0
            Default
                SetHeight = (ExecSQL::iRow(DC::#Database_001,"Gamebase","SplitHeight",0,Startup::*LHGameDB\GameID,"",1))
                
                ResetList(ExecSQL::_IOSQL())   
                
                HideGadget(DC::#Text_004,0)
                
                For RowID = 1 To Rows              
                    NextElement(ExecSQL::_IOSQL())   
                    
                    SetGadgetText(DC::#Text_004,"Ändere Splitterhöhe ID: " + Str(RowID) + "/" + Str(Rows))
                    
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", Str(SetHeight),ExecSQL::_IOSQL()\nRowID)                             
                Next
                
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight", Str(SetHeight),1)
                ; Splitter_SetGet(#True) 
                HideGadget(DC::#Text_004,1)                                
        EndSelect                
    
EndProcedure  
    ;****************************************************************************************************************************************************************
    ; Ändert die Thumbnail Weite und Höhe für alle Einträge
    ;****************************************************************************************************************************************************************
    Procedure Thumbnails_SetAll()
        
        Protected Rows.i , result.i, oHeight.i, oWidth.i, nHeight.s, strIndex.i, c.c, SetHeight.s, RowID.i
        
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Thumbnail Größe  Einstellen","Für alle Einträge die gleiche größe einstellen wie von dem Markierten Eintrag?",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
        If Result = 1
            ProcedureReturn
        EndIf         
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_002,"GameShot")  
                
        Select Rows
            Case 0
            Default
             oWidth  = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsW",0,Startup::*LHGameDB\GameID,"",1)
             oHeight = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsH",0,Startup::*LHGameDB\GameID,"",1)
             Debug "Thumbnails_SetAll(): " +Str(oWidth)
             Debug "Thumbnails_SetAll(): " +Str(oHeight)
                                                              
             ResetList(ExecSQL::_IOSQL())                                                   
             HideGadget(DC::#Text_004,0)
             
             For RowID = 1 To Rows
                 
                 NextElement(ExecSQL::_IOSQL())                                                         
                 
                 ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str( oWidth ),ExecSQL::_IOSQL()\nRowID)
                 ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str( oHeight),ExecSQL::_IOSQL()\nRowID) 
                 SetGadgetText(DC::#Text_004,"Change Thumbnail Size: "+Str(oWidth)+"x"+Str( oHeight) +" ( "+ Str(RowID) + "/" + Str(Rows) + ")")
                 
                 Debug "Thumbnails_SetAll(): Row ID" + Str(RowID) 
                 
             Next                                   
             HideGadget(DC::#Text_004,1)
        EndSelect                        
    EndProcedure  
    ;****************************************************************************************************************************************************************
    ; Ändert die Thumbnail Weite und Höhe für alle Einträge
    ;****************************************************************************************************************************************************************
    Procedure Thumbnails_Thr(*Thumbnail.POINT)
        
        Protected szInfo.s
        
        For RowID = 1 To Rows
            
            Debug "Thumbnails_Thr(*Thumbnail.POINT)"
            
            NextElement(ExecSQL::_IOSQL())                                                         
            
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str( *Thumbnail\x ),ExecSQL::_IOSQL()\nRowID)
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str( *Thumbnail\y ),ExecSQL::_IOSQL()\nRowID)                                         
            
            For nSlot = 1 To Startup::*LHGameDB\MaxScreenshots
                
                *blobBig = vThumbSys::GetBig_FromDB(nSlot)
                *blobSml = vThumbSys::GetSml_FromDB(nSlot)
                
                If (*blobBig > 0) And (*blobSml > 0)
                    
                    ImgDataBig = CatchImage( #PB_Any, *blobBig, MemorySize( *blobBig))
                    ImgDataThb = CatchImage( #PB_Any, *blobSml, MemorySize( *blobSml))                                                                                                                                      
                    
                    If ( ImageWidth( ImgDataThb ) = *Thumbnail\x ) And ( ImageHeight( ImgDataThb ) =  *Thumbnail\y ) 
                        Continue
                    EndIf
                    
                    If ( ImageWidth( ImgDataThb ) <  *Thumbnail\x ) Or ( ImageHeight( ImgDataThb ) <  *Thumbnail\y )                                                                                                        
                        ImgResized = CopyImage( ImgDataBig, #PB_Any)
                        MemorySize = MemorySize( *blobBig)                                
                    Else
                        ImgResized = CopyImage( ImgDataThb, #PB_Any)
                        MemorySize = MemorySize( *blobSml)
                    EndIf    
                    
                    szInfo = "Calculate Thumbnails -"
                    szInfo + " Item: "    + RSet( Str(RowID                    ), 4,"0") + "/" + RSet( Str(Rows), 4,"0")
                    szInfo + " [ BaseID: "+ RSet( Str(ExecSQL::_IOSQL()\nRowID ), 4,"0") + " - "
                    szInfo + " Slot: "    + RSet( Str(nSlot                    ), 4,"0") + " ] "                                    
                    szInfo + " [ Size: "  + MathBytes::Bytes2String( MemorySize) + " ]"
                    szInfo + " ( " + Str( *Thumbnail\x )+ "x" + Str( *Thumbnail\y ) + " )"
                    
                    SetGadgetText(DC::#Text_004, szInfo)
                    
                    DatabaseUpdate(DC::#Database_002, "PRAGMA mmap_size=" + MemorySize + ";") 
                    
                    vImages::Screens_Copy_ResizeToGadget(nSlot,ImgResized, Startup::*LHImages\ScreenGDID[nSlot]) 
                    
                    ExecSQL::ImageSet(DC::#Database_002             ,
                                      "GameShot"                    ,
                                      "Shot" + Str(nSlot) + "_Thb"  ,
                                      ""                            ,
                                      ExecSQL::_IOSQL()\nRowID      ,
                                      1                             ,
                                      CatchImage(Startup::*LHImages\CpScreenPB[nSlot], #PB_ImagePlugin_PNG),"BaseGameID")
                    
                    FreeMemory( *blobBig   ): FreeMemory( *blobSml   ): FreeImage ( ImgDataBig ): FreeImage ( ImgDataThb ): szInfo  = ""
                EndIf
            Next                    
        Next                                  
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;            
    Procedure Thumbnails_Set(nSize.i)
        
        Protected Rows.i ,RowID.i, *ImageData, *blobBig, *blobSml, szInfo.s, ImgDataBig.l,ImgDataThb.l, ImgResized.l, *Thumbnail.POINT, MemorySize.q
        
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_002,"GameShot")  
        
        Select Rows
            Case 0
                
            Default
                ;vImages::Thumbnails_SetReDraw(#False)
                ;DisableGadget( DC::#Contain_10, #True)
                
                *Thumbnail = AllocateMemory( SizeOf( POINT ) )                
                *Thumbnail = vThumbSys::Get_ThumbnailSize(nSize)
                
               
                ResetList(ExecSQL::_IOSQL())                                                   
                HideGadget(DC::#Text_004,0)
                
                Thread = CreateThread(@ Thumbnails_Thr(), *Thumbnail)
              
                HideGadget(DC::#Text_004,1)                
                ;
                ; Hole die Höhe und Breite des Jeweiligen "Spiels"
                Startup::*LHGameDB\wScreenShotGadget   = *Thumbnail\x
                Startup::*LHGameDB\hScreenShotGadget   = *Thumbnail\y            
                
                vImages::Screens_ChgThumbnails(0,#False)             
                vImages::Screens_ChgThumbnails(0,#True,0, 257)
                
                ;vImages::Thumbnails_SetReDraw(#True)
                
                Splitter_SetHeight(*Thumbnail\y, #True)
        EndSelect  
    EndProcedure
   
    ;****************************************************************************************************************************************************************
    ; Info Window Texte in die DB Speichern
    ;****************************************************************************************************************************************************************         
    Procedure    Text_UpdateDB()
        
        Select Startup::*LHGameDB\InfoWindow\bTabNum
                Case 1
                	SetActiveGadget( DC::#Text_128 )
                	ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat1", "",Startup::*LHGameDB\GameID)
                	
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat1", szText ,Startup::*LHGameDB\GameID)
                Case 2
                	SetActiveGadget( DC::#Text_129 )               
                	ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat2", "",Startup::*LHGameDB\GameID)
                	
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat2", szText ,Startup::*LHGameDB\GameID)                    
                Case 3
                	SetActiveGadget( DC::#Text_130 )              
                	ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat3", "",Startup::*LHGameDB\GameID)
                	
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat3", szText ,Startup::*LHGameDB\GameID)                    
                Case 4                	
                	SetActiveGadget( DC::#Text_131 )                              
                	ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat4", "",Startup::*LHGameDB\GameID)
                	
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat4", szText ,Startup::*LHGameDB\GameID)                   
            EndSelect 
            
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt1", "" ,Startup::*LHGameDB\GameID) 
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt2", "" ,Startup::*LHGameDB\GameID) 
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt3", "" ,Startup::*LHGameDB\GameID) 
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt4", "" ,Startup::*LHGameDB\GameID)             
            
            szText.s = ""
            szText.s = GetGadgetText( DC::#Text_128  )           
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt1", szText ,Startup::*LHGameDB\GameID) 
            
            szText.s = ""
            szText.s = GetGadgetText( DC::#Text_129  )         
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt2", szText ,Startup::*LHGameDB\GameID)           
            
            szText.s = ""
            szText.s = GetGadgetText( DC::#Text_130  )          
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt3", szText ,Startup::*LHGameDB\GameID)              
            
            szText.s = ""
            szText.s = GetGadgetText( DC::#Text_131  )      
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt4", szText ,Startup::*LHGameDB\GameID) 
        	
            vInfo::Modify_Reset()
            vInfo::Caret_GetPosition()
            
            
    EndProcedure   
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************         
    Procedure Text_GetDB_ColorState()    
        
        Debug ""
        If ( ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt1","",Startup::*LHGameDB\GameID,"",1) )
           Debug "Farbwechsel für DC::#Button_283 durch DC::#Text_128"
           ButtonEX::SetColor(DC::#Button_283, GetSysColor_(#COLOR_3DFACE), $F3AF64)
       Else
           Debug "Standard Farbe für DC::#Button_283 durch DC::#Text_128"             
           ButtonEX::SetColor(DC::#Button_283, RGB(113, 147, 165),$F3AF64 )           
       EndIf
       
       If ( ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt2","",Startup::*LHGameDB\GameID,"",1) )  
           Debug "Farbwechsel für DC::#Button_284 durch DC::#Text_129"           
           ButtonEX::SetColor(DC::#Button_284, GetSysColor_(#COLOR_3DFACE), $F3AF64)
       Else
           Debug "Standard Farbe für DC::#Button_284 durch DC::#Text_129"             
           ButtonEX::SetColor(DC::#Button_284, RGB(113, 147, 165),$F3AF64 )
       EndIf  
       
       If ( ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt3","",Startup::*LHGameDB\GameID,"",1) )      
           Debug "Farbwechsel für DC::#Button_285 durch DC::#Text_130"           
           ButtonEX::SetColor(DC::#Button_285, GetSysColor_(#COLOR_3DFACE), $F3AF64)
       Else
           Debug "Standard Farbe für DC::#Button_285 durch DC::#Text_130"             
           ButtonEX::SetColor(DC::#Button_285, RGB(113, 147, 165),$F3AF64 )
       EndIf  
       
       If ( ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt4","",Startup::*LHGameDB\GameID,"",1) )      
           Debug "Farbwechsel für DC::#Button_286 durch DC::#Text_131"
           ButtonEX::SetColor(DC::#Button_286,GetSysColor_(#COLOR_3DHIGHLIGHT), $F3AF64)
       Else
           Debug "Standard Farbe für DC::#Button_286 durch DC::#Text_131"             
           ButtonEX::SetColor(DC::#Button_286, RGB(113, 147, 165),$F3AF64 )           
       EndIf  
              
       ButtonEX::Setstate(DC::#Button_283, ButtonEX::Getstate( DC::#Button_283) )
       ButtonEX::Setstate(DC::#Button_284, ButtonEX::Getstate( DC::#Button_284) )
       ButtonEX::Setstate(DC::#Button_285, ButtonEX::Getstate( DC::#Button_285) )
       ButtonEX::Setstate(DC::#Button_286, ButtonEX::Getstate( DC::#Button_286) )          
       
   EndProcedure
    ;****************************************************************************************************************************************************************
    ; Textinhalt Frage
    ;****************************************************************************************************************************************************************   
   Procedure.s Text_Load(szText.s, Evntgadget.i)
       Protected Message$
       
       If Not ( GetGadgetText( Evntgadget ) = "" )
           
           Message$ = "Den aktuellen Text Inhalt Löschen und Ersetzen oder Erweitern/ Hinzufügen ?"
           Request::*MsgEx\User_BtnTextL = "Ersetzen"
           Request::*MsgEx\User_BtnTextM = "Erweitern"
           Request::*MsgEx\User_BtnTextR = "Abbruch"                         
           r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Text Löschen oder Erweitern"  ,Message$,16,1,ProgramFilename(),0,0,DC::#_Window_006)
           Select ( r ) 
               Case 0: ;Ersetzen
                   ProcedureReturn szText
               Case 1: ;Abbaruch
                   ProcedureReturn ""
               Case 2: ;Erweitern
                   ProcedureReturn GetGadgetText( Evntgadget ) + #CR$ + szText
           EndSelect                                                                
       EndIf
       ProcedureReturn szText
   EndProcedure
    ;****************************************************************************************************************************************************************
    ; Info Window Get Text and Show
    ;**************************************************************************************************************************************************************** 
    Procedure   Text_Show()
        Protected szFile.s, szText.s      
                  
        Startup::*LHGameDB\InfoWindow\szXmlText = ""
        
        szFile.s = Getfile_Portbale_ModeOut( GetGadgetText( DC::#String_112 ) )
        
        If ( FileSize( szFile ) >= 1 )            
            
            If vInfo::TextFile_isPacked(szFile) >= 1
                szText.s = Startup::*LHGameDB\InfoWindow\szXmlText
            Else                
                szText.s = vInfo::TextFile_Read(szFile, 0, FileSize(szFile) , vInfo::File_CheckEnCode(szFile)) 
            EndIf
            
            Select Startup::*LHGameDB\InfoWindow\bTabNum
                Case 1
                    
                    szText = Text_Load(szText, DC::#Text_128)
                    If szText = ""
                        ProcedureReturn 
                    EndIf    
                    SetGadgetText( DC::#Text_128,szText)
                    SetActiveGadget( DC::#Text_128 )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat1", szFile ,Startup::*LHGameDB\GameID)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt1", szText ,Startup::*LHGameDB\GameID)
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt1 = szText
                    vInfo::TextFile_GetFormat( GetGadgetText( DC::#String_112 ), DC::#Text_128 )
                Case 2
                    szText = Text_Load(szText, DC::#Text_129)
                    If szText = ""
                        ProcedureReturn 
                    EndIf                      
                    SetGadgetText( DC::#Text_129,szText)
                    SetActiveGadget( DC::#Text_129 )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat2", szFile ,Startup::*LHGameDB\GameID)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt2", szText ,Startup::*LHGameDB\GameID)
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt2 = szText
                    vInfo::TextFile_GetFormat( GetGadgetText( DC::#String_112 ), DC::#Text_129 )
                Case 3
                    szText = Text_Load(szText, DC::#Text_130)
                    If szText = ""
                        ProcedureReturn 
                    EndIf                      
                    SetGadgetText( DC::#Text_130,szText)                 
                    SetActiveGadget( DC::#Text_130 )                
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat3", szFile ,Startup::*LHGameDB\GameID)                      
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt3", szText ,Startup::*LHGameDB\GameID)                      
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt3 = szText
                    vInfo::TextFile_GetFormat( GetGadgetText( DC::#String_112 ), DC::#Text_131 )
                Case 4
                    szText = Text_Load(szText, DC::#Text_131)
                    If szText = ""
                        ProcedureReturn 
                    EndIf                       
                    SetGadgetText( DC::#Text_131,szText)                 
                    SetActiveGadget( DC::#Text_131 )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat4", szFile ,Startup::*LHGameDB\GameID)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTxt4", szText ,Startup::*LHGameDB\GameID)                     
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt4 = szText
                    vInfo::TextFile_GetFormat( GetGadgetText( DC::#String_112 ), DC::#Text_132 )
           EndSelect 
           
           
                        
       EndIf
   EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Info Window Get Text and Show
   ;****************************************************************************************************************************************************************   
   Procedure    Text_GetDB()
       
       Protected szFile.s = "", szText.s = ""
       
       vInfo::Tab_GetNames()
       
       ;Select Startup::*LHGameDB\InfoWindow\bTabNum
       ;    Case 1   
               szText = ""
               szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt1","",Startup::*LHGameDB\GameID,"",1)               
                                 
               Startup::*LHGameDB\InfoWindow\Modified\szTxt1 = szText
               
               SetGadgetText( DC::#Text_128,szText)                
           
               ;    Case 2
               szText = ""               
               szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt2","",Startup::*LHGameDB\GameID,"",1)
                           
               Startup::*LHGameDB\InfoWindow\Modified\szTxt2 = szText
               
               SetGadgetText( DC::#Text_129,szText)                                                
                        
               ;    Case 3
               szText = ""               
               szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt3","",Startup::*LHGameDB\GameID,"",1)
                          
               Startup::*LHGameDB\InfoWindow\Modified\szTxt3 = szText

               SetGadgetText( DC::#Text_130,szText)                       
               
                 
               ;    Case 4
               szText = ""               
               szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt4","",Startup::*LHGameDB\GameID,"",1)
                                            
               Startup::*LHGameDB\InfoWindow\Modified\szTxt4 = szText
               
               SetGadgetText( DC::#Text_131,szText)                       
               
       ;EndSelect                                                      
               
       Select Startup::*LHGameDB\InfoWindow\bTabNum
           Case 1          
               szFile = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditDat1","",Startup::*LHGameDB\GameID,"",1)
               vInfo::TextFile_GetFormat( szFile, DC::#Text_128 )   
           Case 2
               szFile = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditDat2","",Startup::*LHGameDB\GameID,"",1)  
               vInfo::TextFile_GetFormat( szFile, DC::#Text_129 ) 
           Case 3
               szFile = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditDat3","",Startup::*LHGameDB\GameID,"",1) 
               vInfo::TextFile_GetFormat(szFile, DC::#Text_130 )
           Case 4
               szFile = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditDat4","",Startup::*LHGameDB\GameID,"",1) 
               vInfo::TextFile_GetFormat( szFile, DC::#Text_131 )               
        EndSelect       
               
       szFile = Getfile_Portbale_ModeIn( szFile ): SetGadgetText( DC::#String_112,szFile)            
       
       vInfo::Get_MaxLines()
       vInfo::Caret_GetPosition_NonActiv()
       
       Text_GetDB_ColorState()
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************  
   Procedure.i Text_GetDB_Check()
       
       Protected bText1.i = #False, bText2.i = #False, bText3.i = #False, bText4.i = #False, szText.s
       
       szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt1","",Startup::*LHGameDB\GameID,"",1)
       If ( szText )
           bText1 = #True
       Else
                      
           szText = ""
           szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt2","",Startup::*LHGameDB\GameID,"",1)
           If ( szText )
               bText2 = #True
           Else
               
               
               szText = ""
               szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt3","",Startup::*LHGameDB\GameID,"",1)
               If ( szText )
                   bText3 = #True
               Else
                   
                   
                   szText = ""
                   szText = ExecSQL::nRow(DC::#Database_001,"Gamebase","EditTxt4","",Startup::*LHGameDB\GameID,"",1)
                   If ( szText )
                       bText4 = #True
                   EndIf
               EndIf
           EndIf
       EndIf
       
      
       
       If   ( bText1 = #True ) 
           Startup::*LHGameDB\InfoWindow\bTabNum    = 1
           Startup::*LHGameDB\InfoWindow\TabButton = DC::#Button_283           
           ProcedureReturn 1
                    
       ElseIf   ( bText2 = #True )
           Startup::*LHGameDB\InfoWindow\bTabNum    = 2
           Startup::*LHGameDB\InfoWindow\TabButton = DC::#Button_284
           ProcedureReturn 1
           
       ElseIf   ( bText3 = #True )
           Startup::*LHGameDB\InfoWindow\bTabNum    = 3       
           Startup::*LHGameDB\InfoWindow\TabButton = DC::#Button_285           
           ProcedureReturn 1
            
       ElseIf   ( bText4 = #True )  
           Startup::*LHGameDB\InfoWindow\bTabNum    = 4                    
           Startup::*LHGameDB\InfoWindow\TabButton = DC::#Button_285
           ProcedureReturn 1        
       Else
           ProcedureReturn 0
       EndIf    
       
         
   EndProcedure   

   ;****************************************************************************************************************************************************************
   ; Open Path
   ;****************************************************************************************************************************************************************          
    Procedure.i   DOS_Open_Directory(nOption, bCheck = #False)
        
        Protected PrgID.i, PrgEX.s
        
        Select nOption
            Case 0
                PrgID = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID"      ,"",Startup::*LHGameDB\GameID,"",1))
                PrgEX =     ExecSQL::nRow(DC::#Database_001,"Programs","File_Default","",PrgID                    ,"",1) 
               
                
            Case 1: PrgEX = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",Startup::*LHGameDB\GameID,"",1)
            Case 2: PrgEX = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev1","",Startup::*LHGameDB\GameID,"",1)
            Case 3: PrgEX = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev2","",Startup::*LHGameDB\GameID,"",1)                
            Case 4: PrgEX = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev3","",Startup::*LHGameDB\GameID,"",1)                
                
        EndSelect 
        
        If (PrgEX)        
            PrgEX =  Getfile_Portbale_ModeOut(PrgEX)                                
            
            If ( bCheck = #True )
                ProcedureReturn 0
            EndIf    
            
            If FileSize( PrgEX ) >=1 Or FileSize( PrgEX ) =-2
               FFH::ShellExec(GetPathPart( PrgEX ), "explore")
            Else                              
                
                If ( Mid(PrgEX,2,1) = ":" )                                    
                    Request::MSG(Startup::*LHGameDB\TitleVersion, "Path Not Found" ,"Not Found: " + Chr(32) + GetPathPart( PrgEX ) + Chr(32),2,2)    
                Else
                    Request::MSG(Startup::*LHGameDB\TitleVersion, "Path Not Found" ,"Portable Path Not Found: " + Chr(32) + GetPathPart( PrgEX ) + Chr(32),2,2)                     
                EndIf  
            EndIf            
        EndIf         
        
        If ( bCheck = #True )
             ProcedureReturn 1
        EndIf          
        
    EndProcedure        
    ;
    ;
    ; Return Codes als Identifikation zur Weiterleitung
    ; -1 : Kein Unterstützung
    ; 64 : C64er Images
    ;
    Procedure.i     FileManageR_MediumDecmp(szMedium.s, PackPluginID.i )
        
        Protected Count.i = 0, PackedData.s, PackedFile.s, PackedPath.s, PackedExts.s, PackedSize.q
        Protected isC64.i = 0   ; Commodore 64/128
        Protected isWAD.i = 0   ; Doom Wads
        Protected isAMI.i = 0   ; Commodore Amiga
        Protected isPK3.i = 0   ;
        
        Protected RtCode.i= -1  
        
        
        If OpenPack(DC::#PackFile, szMedium, PackPluginID ) 
            
            If ExaminePack( DC::#PackFile )
                
                While NextPackEntry( DC::#PackFile )

                    If ( Len(PackEntryName( DC::#PackFile )) >= 1)        
                        Count + 1 
                                                
                        PackedData = PackEntryName( DC::#PackFile )     ; Könnte datei oder Verzeichnis xsein
                        PackedSize = PackEntrySize( DC::#PackFile )     ; Size
                        Debug "FileManager - Medium Decompress: [" + Str(Count) + "] " + PackedData
                        Debug "FileManager - Medium Decompress: [" + Str(Count) + "] " + Str(PackedSize)
                        
                        If Right( PackedData , 1) = "/"
                            PackedPath = PackedData
                            Debug "FileManager - Medium Verzeichnis [" + Str(Count) + "] " + PackedPath +#CR$
                            
                        Else
                            PackedPath = PackedData
                            PackedFile = GetFilePart( PackedData, #PB_FileSystem_NoExtension )
                            PackedExts = GetExtensionPart( PackedData )
                            Debug "FileManager - Medium Voller Pfad [" + Str(Count) + "] " + PackedPath                            
                            Debug "FileManager - Medium Datei       [" + Str(Count) + "] " + PackedFile
                            Debug "FileManager - Medium Erweiterung [" + Str(Count) + "] " + PackedExts +#CR$                                                     
                        EndIf                    
                    EndIf 
                    
                    Select UCase ( PackedExts )
                        Case  "D64", "D71", "D81","T64","D80", "D82", "G64", "LNX", "X64", "G71","TAP","CRT", "PRG", "P00"
                            isC64 + 1: RtCode = 64
                        Case "WAD"
                            isWAD + 1: RtCode = -1
                        Case "ADF", "ADZ", "DMS"
                            isAMI + 1: RtCode = -1
                        Case "PK3"    
                            isPK3 + 1: RtCode = -1
                        Default 
                            RtCode = -1
                    EndSelect        
                    
                Wend   
            EndIf    
                        
            ClosePack( DC::#PackFile ) 
            ProcedureReturn RtCode
        EndIf    
        
        
        
    EndProcedure    
    ;
    ;
    ;
    Procedure.i     FileManageR_MediumCheck(GadgetID.i, DestGadgetID.i)
        
        Protected szMedium.s, szFormat.s, RtCode.i = 1
        
        If ( Len(GetGadgetText(GadgetID)) = 0 )                                   ;
             Request::MSG(Startup::*LHGameDB\TitleVersion, "Keine Datei Im Slot!","Im dem Datei Slot befindet sich keine Datei" ,2,2,"",0,0,DC::#_Window_001)
             ProcedureReturn 
        EndIf        
        
        szMedium  = Getfile_Portbale_ModeOut(GetGadgetText(GadgetID.i))
        szFormat  = GetExtensionPart(szMedium)
        
             
        Select FileSize( szMedium ) 
            Case -1     ; Datei wurde nicht gefunden.
                        ;
                        ; Fehler Message
                Request::MSG(Startup::*LHGameDB\TitleVersion, "Datei nicht gefunden!","Die Datei "+ Chr(34) + GetFilePart( szMedium, #PB_FileSystem_NoExtension ) + Chr(34) + " wurde nicht gefunden" ,2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn  
                
            Case -2     ; Datei ist ein Verzeichnis.
                        ;
                        ;  Verzeichnis ...                     
            Default
                If (Len(szFormat) = 0)
                    ;
                    ; Kein Format ()
                EndIf                 
                
        EndSelect    
        
        ;
        ;
        ; Auf Packer Prüfen
        Select UCase ( szFormat )
            Case "LZ"
                RtCode = FileManageR_MediumDecmp( szMedium.s, #PB_PackerPlugin_BriefLZ )
                
            Case "ZIP"               
                RtCode = FileManageR_MediumDecmp( szMedium.s, #PB_PackerPlugin_Zip     )               
                
            Case "7Z","LHA"                
                RtCode = FileManageR_MediumDecmp( szMedium.s,  #PB_PackerPlugin_Lzma   )               
                
            Case "TAR"
                RtCode = FileManageR_MediumDecmp( szMedium.s, #PB_PackerPlugin_Tar     )                
                
            Case "RAR"
                ;
                ; Ja super ... da muss man wieder war machen ...
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","RAR wird Nativ (noch) nicht unterstützt",2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn 
            Case "LZX"
            	vWindows::OpenWindow_Archiv(GadgetID.i, DestGadgetID.i)
            	ProcedureReturn 
        EndSelect
        
        Select RtCode
                ;
                ; Return Code 64 öffent das C64er Image Fenster, da sich im gepackten image C64er Image Befindet
            Case 64
                vWindows::OpenWindow_Sys64(GadgetID.i, DestGadgetID.i)
                ProcedureReturn 
                
          Default
          	    ;
          	    ; Öffnet den Standard Archiv Manager
          	    vWindows::OpenWindow_Archiv(GadgetID.i, DestGadgetID.i)
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Der Inhalt der [ "+ szFormat +" ] Datei wird noch nicht unterstützt",2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn 
                
        EndSelect        
        ;
        ;
        ; Prüfe Medium 
        Select UCase ( szFormat )
                
            Case  "D64", "D71", "D81","T64","D80", "D82", "G64", "LNX", "X64", "G71","TAP","CRT", "PRG", "P00" 
                vWindows::OpenWindow_Sys64(GadgetID.i, DestGadgetID.i)
                ProcedureReturn 
                
          Default
                vWindows::OpenWindow_Archiv(GadgetID.i, DestGadgetID.i)
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","[ "+ szFormat +" ] wird für den Internen Datei Manager nicht unterstützt",2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn
                
        EndSelect
        
    EndProcedure    
    
  ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________       
;     Procedure.s DSK_Uncompress_ZIP(D64_Image$, PowerPacker.i)
;         Protected PowerPackFile$, PPFileName$,  PPSWildcat$, PPFilesize.q, TMPWildcat$
;         
;         
;         If OpenFile( DC::#TMPFile , D64_Image$)
;            CloseFile( DC::#TMPFile )
;       EndIf
;         
;       If OpenPack(DC::#PackFile, D64_Image$, PowerPacker ) 
;           
;           If ExaminePack( DC::#PackFile )
;               
;               While NextPackEntry( DC::#PackFile )
;                   
;                        If (Len(PackEntryName( DC::#PackFile )) = 0) And ( PackEntrySize( DC::#PackFile ) = 0 )
;                            ; 
;                            ; No Filename and Items
;                            ClosePack(#PB_All): ProcedureReturn
;                        EndIf 
;                        
;                        ;
;                        ;Use the First Filename
;                        If ( Len(PackEntryName( DC::#PackFile )) >= 1)  
;                                                       
;                            PowerPackFile$ = PackEntryName( DC::#PackFile )
;                            PPFileName$    = GetFilePart( PackEntryName( DC::#PackFile ), 1)
;                            PPSWildcat$    = GetExtensionPart( PackEntryName( DC::#PackFile ) )
;                            PPFilesize     = PackEntrySize( DC::#PackFile )
;                            
;                            Debug #CRLF$
;                            Request::SetDebugLog("Powerpacked File: "+ PowerPackFile$ + "  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
;                            Request::SetDebugLog("Powerpacked Size: "+ PackEntrySize( DC::#PackFile ) + "  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                              
;                        
;                            Select UCase ( PPSWildcat$)
;                                Case  "D64", "D71", "D81","T64", "D80", "D82", "G64", "LNX", "X64", "G71", "TAP", "CRT", "PRG", "P00"                                                   
;                                    
;                                    
;                                    PPFileName$ = "_DecompC64File"                                     
;                                    PPFileName$ = GetTemporaryDirectory() + PPFileName$ + "." + PPSWildcat$
;                                    
;                                    Request::SetDebugLog("ZIP Found & Extract : "+ PowerPackFile$ +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))     
;                                    
;                                    *PackeMemory = AllocateMemory( PPFilesize )
;                                    UncompressPackMemory( DC::#PackFile, *PackeMemory, MemorySize( *PackeMemory ),  PowerPackFile$)
;                                    ClosePack(#PB_All)   
;                                    
;                                    Define SaveFile = CreateFile(#PB_Any, PPFileName$,#PB_File_SharedRead|#PB_File_SharedWrite)           
;                                    If ( SaveFile )
;                                       WriteData(SaveFile, *PackeMemory, PPFilesize)
;                                       CloseFile(SaveFile)     
;                                    EndIf  
;                                    FreeMemory(*PackeMemory)
;                                    
;                                    
;                                   ; PPFilesize = UncompressPackFile( DC::#PackFile ,PPFileName$, PowerPackFile$ )
;                                                                                                   
;                                                                       
;                                    If ( FileSize(PPFileName$) ! PPFilesize ) Or ( PPFilesize = -1)                                                                           
;                                        Message1$ = "W.T.F: "
;                                        Message2$ = "There was a error to uncompress File " + #CRLF$ + GetFilePart( D64_Image$ ) + #CRLF$ + "Extract Error: " + PowerPackFile$ + " ("+Str(PPFilesize)+")"
;                                        
;                                        Request::MSG(Startup::*LHGameDB\TitleVersion, Message1$, Message2$ ,2,2,"",0,0,DC::#_Window_005)
;                                        ProcedureReturn ""
;                                    EndIf 
;                                    
;                                    C64_PackedImage$ = PPFileName$
;                                    Request::SetDebugLog("Compressed Image Packed  : "+Chr(34)+D64_Image$      +Chr(34)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
;                                    Request::SetDebugLog("Compressed Image UnPacked: "+Chr(34)+C64_PackedImage$+Chr(34)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
;                                    ProcedureReturn PPFileName$
;                                Default
;                                    Continue
;                            EndSelect                                                   
;                            ; Löschen nicht vergessen
;                       EndIf 
;                     Wend
;                 EndIf
;             EndIf
;       
;    EndProcedure 
    ;
	;
	;   
    Procedure Thread_HTTP_MAME_Roms_DoEvents() 
    	Protected msg.MSG
    	
    	If PeekMessage_(msg,0,0,0,1) 
    		TranslateMessage_(msg) 
    		DispatchMessage_(msg) 
    	Else 
    		Sleep_(1) 
    	EndIf 
    EndProcedure 
  ;
	;
	;     
  Procedure.i  Thread_MAME_Driver_Import(*Params.MAME_DRIVER_PARAMS_LIST)   
    	
    	ResetList( *Params\mdil() )
    	
    	
    	Protected Listingsize.i = ListSize( *Params\mdil() )-1
    	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")  
    	
    	While NextElement(*Params\mdil())
    		Delay(5)
    		
    		Debug "ID Index : " + Str(Startup::*LHGameDB\GameID)
    		Debug "Insert   : " + *Params\mdil()\Title
    		Debug "FileDev0 : " + *Params\mdil()\DriverName
    		Debug "Region   : " + *Params\mdil()\Region
    		    		
    		SetGadgetText(DC::#Text_001, "Insert")
    		SetGadgetText(DC::#Text_002,  *Params\mdil()\Title)	     				
    		SetGadgetText(DC::#Text_003, "..In Progress: Import [Remaining: " +Str(Listingsize) + "]")   
    		
    		ExecSQL::InsertRow(DC::#Database_001,"Gamebase", "GameTitle ", *Params\mdil()\Title)				
    		
    		Startup::*LHGameDB\GameID = ExecSQL::LastRowID(DC::#Database_001,"Gamebase")
    		ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "GameTitle", *Params\mdil()\Title, Startup::*LHGameDB\GameID) ; Force
    		
    		Delay(1)                
    		ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1)                         
    		
    		; Screenshot Zelle hinzufügen
				;
    		ExecSQL::InsertRow(DC::#Database_002,"GameShot", "BaseGameID ", Str(Startup::*LHGameDB\GameID))
    		
    		ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str(202),Startup::*LHGameDB\GameID)
    		ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str(142),Startup::*LHGameDB\GameID)                            
    		
    		;VEngine::Splitter_SetGet(#False)
    		ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", Str(GetGadgetState(DC::#Splitter1) ),Startup::*LHGameDB\GameID)
    		ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight", Str(GetGadgetState(DC::#Splitter1) ),1)                  
    		
    		Delay(1)                  
    		
    		ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "MediaDev0", *Params\mdil()\DriverName, Startup::*LHGameDB\GameID)
    		
    		Delay(1)
    		
    		If ( Len( *Params\mdil()\Region ) > 0)
    			
    			RegionFound.i = #False
    			
    			For RowID = 1 To ExecSQL::CountRows(DC::#Database_001,"Language")
    				
    				LanguageID.i = ExecSQL::iRow(DC::#Database_001,"Language","id",0,RowID,"",1)
    				LanguageST.s = ExecSQL::nRow(DC::#Database_001,"Language","Locale","",RowID,"",1)
    				
    				If  ( UCase( *Params\mdil()\Region ) = UCase( LanguageST ) )	            			
    					RegionFound = #True
    					Debug "Founded"
    					ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "LanguageID", Str(LanguageID), Startup::*LHGameDB\GameID)
    					Break
    				EndIf	                    		                    	
    			Next RowID 
    			
    			
    			; Nicht Gefunden -> Füge die Region der Liste hinzu und dem Aktuellen Titel
    			If ( RegionFound.i = #False )
    				ExecSQL::InsertRow(DC::#Database_001,"Language", "Locale ",  *Params\mdil()\Region)
    				ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "LanguageID", Str(ExecSQL::LastRowID(DC::#Database_001,"Language")), Startup::*LHGameDB\GameID)
    			EndIf	
    		EndIf
    		
    		Listingsize - 1
    	Wend
    	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")  
    	
   EndProcedure
  ;
  ;
	;
  Procedure.s  MAME_Search_ExportFile(ExportFiles.s)  
  	
  	Protected ResultFile.s = ""
  	
  	FFS::DelContent()    		
  	FFS::GetContent(Startup::*LHGameDB\Base_Path ,#True, #True, #True,"","*.txt",4,#False,100,"")
  	FFS::SortContent()
  	ResetList(FFS::FullFileSource())
  	
  	While NextElement( FFS::FullFileSource() )    			
  		IndexFiles.s = GetFilePart( FFS::FullFileSource()\FileName,#PB_FileSystem_NoExtension)
  		If UCase (IndexFiles) = UCase(ExportFiles)
  				ResultFile = FFS::FullFileSource()\FileName
					Break
  		EndIf	
  		Thread_HTTP_MAME_Roms_DoEvents() 	
  	Wend	
  	
  	FFS::DelContent()
  	
  	ProcedureReturn  ResultFile
  EndProcedure
  ;
  ;
	;   
  Procedure.i  MAME_Driver_Import()   
    	
    	Protected FileHandle.l, StrLine.s, StrRead.s, StrRegion.s, ExportDirectory.s  	            
        
    	Structure MAME_DRIVER_REGION
        	Region.s
        EndStructure
        
        NewList mdil.MAME_DRIVER_IMPORT_LIST()
        NewList mdr.MAME_DRIVER_REGION()
        
        
        
        SetActiveGadget(-1) 
        
        ; Intro
				;
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Import", "Mame Titel und Rom Namen Importieren?" + #CRLF$ + #CRLF$ + "Welche Datei?" +#CRLF$ +"Die Datei zum importieren muss vorher mit 'Mame.exe -listdevices' erstellt werden.",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
        If ( Result = 1 ) 
        	SetActiveWindow(DC::#_Window_001)           
        	SetActiveGadget(DC::#ListIcon_001)         	
        	ProcedureReturn 
        EndIf
        
        Delay(30)
        
        
        ExportFile$ = MAME_Search_ExportFile("ROMS-DEVICES")  
        If ( Len( ExportFile$ ) = 0 )
        	ExportFile$ = FFH::GetFilePBRQ("-ListDevices Exported File",Startup::*LHGameDB\Base_Path, #False, "Mame Driver Export File [Devices] (*.*)|*.*;", 0, #True)
        	If ( Len( ExportFile$ ) = 0 )
        		SetActiveWindow(DC::#_Window_001)
        		SetActiveGadget(DC::#ListIcon_001)          	
        		ProcedureReturn 
        	EndIf    			    			
        EndIf
    		        
        ExportPath$ = Getfile_Portbale_ModeOut(ExportFile$)
    	
    	If ( Len( ExportPath$ ) >= 1 )
    		
    		; Intro
			;
    		vSys_MainButtonsConfig()
    		
    		SetGadgetText(DC::#Text_003,"Reading List")
    		
    		AddElement( mdr() ): mdr()\Region = "Asia"
    		AddElement( mdr() ): mdr()\Region = "Brazil"
    		AddElement( mdr() ): mdr()\Region = "China"
     		AddElement( mdr() ): mdr()\Region = "European"   		
    		AddElement( mdr() ): mdr()\Region = "Europe"
    		AddElement( mdr() ): mdr()\Region = "Euro"    		
    		AddElement( mdr() ): mdr()\Region = "English"
    		AddElement( mdr() ): mdr()\Region = "French"
    		AddElement( mdr() ): mdr()\Region = "Germany"    		
    		AddElement( mdr() ): mdr()\Region = "German"
    		AddElement( mdr() ): mdr()\Region = "Hispanic"
    		AddElement( mdr() ): mdr()\Region = "Hong Kong"    		
    		AddElement( mdr() ): mdr()\Region = "Italian"
    		AddElement( mdr() ): mdr()\Region = "Korea"      		
    		AddElement( mdr() ): mdr()\Region = "Japan"
     		AddElement( mdr() ): mdr()\Region = "Spain"    		
     		AddElement( mdr() ): mdr()\Region = "Taiwan"
    		AddElement( mdr() ): mdr()\Region = "UK"     		
    		AddElement( mdr() ): mdr()\Region = "USA"
    		AddElement( mdr() ): mdr()\Region = "US"    		
     		AddElement( mdr() ): mdr()\Region = "World"   		

     		
    		FileHandle = ReadFile(#PB_Any, ExportPath$)
    		
    		If ( FileHandle >= 0 )
    			
    		While Eof(FileHandle) = 0
    			
    			StrRead   =  ReadString(FileHandle)
    			StrLine   =  StrRead
    			
    			sLen.i    = Len( StrLine )
    			
    			StrRegion = ""
    			
    			If ( Right(StrLine, 1) = ":" ) And ( Left( StrLine, 6) = "Driver")
    				
    				StrLine      = ReplaceString( StrLine, "Driver", "", #PB_String_CaseSensitive ,0,1)
    				
    				; Suche nach der ersten Klammer
    				sKlammerO.i  = FindString( StrLine, "(",0)    				
    				
    				; Hole Rom Name vor dem zeichen der ersten Klammer
    				DriverName.s = Mid( StrLine, 0, sKlammerO - 1 )
    				
    				DriverName.s = Trim( DriverName, Chr(32) )
    				
    				StrLine      = ReplaceString( StrLine, DriverName, "", #PB_String_CaseSensitive ,0,1)
    				StrLine      = Trim( StrLine, Chr(32) )
    				
    				Title.s      = Mid( StrLine, 2, Len( StrLine ) -3 )
    				    				
        			ResetList( mdr() )
        			While NextElement( mdr() )
        				If FindString( Title, mdr()\Region,1,#PB_String_CaseSensitive)
        					
        					If FindString( Title, "(" + mdr()\Region,1,#PB_String_CaseSensitive)
        						StrRegion = mdr()\Region
        						Title	  = ReplaceString( Title, "(" + StrRegion, "(",#PB_String_CaseSensitive,1,1)
        						
        					ElseIf FindString( Title, ", " + mdr()\Region,1,#PB_String_CaseSensitive)	
        						StrRegion = mdr()\Region
        						Title	  = ReplaceString( Title, ", " + StrRegion, "(",#PB_String_CaseSensitive,1,1)
        					EndIf	
        					Break
        				EndIf	
        			Wend
        			
        			If FindString( Title, "set ",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "set ", "Set ",#PB_String_CaseSensitive,1,1)	
        			EndIf     			
        			
        			If FindString( Title, "revision",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "revision", "Revision",#PB_String_CaseSensitive,1,1)	
        			EndIf    
        			
        			If FindString( Title, "rev ",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "rev ", "Revision ",#PB_String_CaseSensitive,1,1)	
        			EndIf
        			
        			If FindString( Title, "prototype",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "prototype", "Prototype",#PB_String_CaseSensitive,1,1)	
        			EndIf
        			
        			If FindString( Title, "bootleg",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "bootleg", "Bootleg",#PB_String_CaseSensitive,1,1)	
        			EndIf
        			
        			If FindString( Title, "harder",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "harder", "Harder",#PB_String_CaseSensitive,1,1)	
        			EndIf   
        			
        			If FindString( Title, "ver.",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "ver.", "Version",#PB_String_CaseSensitive,1,1)	
        			EndIf
        			
        			If FindString( Title, "Ver.",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "ver.", "Version",#PB_String_CaseSensitive,1,1)	
        			EndIf        			
        			
        			If FindString( Title, "hack",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "hack", "Hack",#PB_String_CaseSensitive,1,1)	
        			EndIf
        			
        			If FindString( Title, "protected",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "protected", "Protected",#PB_String_CaseSensitive,1,1)	
        			EndIf        			    			
        			        			
        			If FindString( Title, "()",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "()", "",#PB_String_CaseSensitive,1,1)
        			EndIf 
        			
        			If FindString( Title, "( ",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "( ", "(",#PB_String_CaseSensitive,1,1)
        			EndIf 
        			
        			If FindString( Title, "(, ",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "(, ", "(",#PB_String_CaseSensitive,1,1)
        			EndIf
        			
        			If FindString( Title, "  (",1,#PB_String_CaseSensitive)
        				Title	  = ReplaceString( Title, "  (", " (",#PB_String_CaseSensitive,1,1)
        			EndIf         			
        			
        			
        			AddElement( mdil() )
        			mdil()\DriverName = DriverName
        			mdil()\Title      = Title
        			mdil()\Region     = StrRegion         			
        			
    				Debug "Titel: " + Title        				
    				Debug "Rom  : " + DriverName 				
    				Debug "Read : " + StrRead
    				Debug "" 
    				
    				SetGadgetText(DC::#Text_001, mdil()\Title )
    				SetGadgetText(DC::#Text_002, mdil()\DriverName)	     				
    				SetGadgetText(DC::#Text_003, "..In Progress: "+RSet("Read",5,Chr(32)) + " [" + ListSize( mdil() ) + "]")   				    				
    			EndIf
    			Thread_HTTP_MAME_Roms_DoEvents() 
    		Wend
    		
    		CloseFile(FileHandle)
    		
    		SetGadgetText(DC::#Text_001, "")
    		SetGadgetText(DC::#Text_002, "")	     				
    		SetGadgetText(DC::#Text_003, "")     		
  			Else
  				Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Konnte Datei nicht öffnen!",2,2,"",0,0,DC::#_Window_001)
           		ButtonEX::Disable(DC::#Button_001, false)            
           		ButtonEX::Disable(DC::#Button_002, false) 
           		ButtonEX::Disable(DC::#Button_287, false)  				
            	SetActiveWindow(DC::#_Window_001)
            	SetActiveGadget(DC::#ListIcon_001)            
           		VEngine::Thread_LoadGameList_Action()
           		vImages::Screens_Show()            	
                ProcedureReturn  				
  			EndIf
  			
    		SetGadgetText(DC::#Text_001, "")
    		SetGadgetText(DC::#Text_002, "")	     				
    		SetGadgetText(DC::#Text_003, "")
    		
  			ResetList( mdil() ): ls.i = ListSize ( mdil() )
  			
  			; Prüfen ob die Liste nicht null ist
  			;
  			If ( ls = 0 )
            	Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Keine Titel zum Importieren gefunden",2,2,"",0,0,DC::#_Window_001)
           		ButtonEX::Disable(DC::#Button_001, false)            
           		ButtonEX::Disable(DC::#Button_002, false) 
           		ButtonEX::Disable(DC::#Button_287, false)  				
            	SetActiveWindow(DC::#_Window_001)
            	SetActiveGadget(DC::#ListIcon_001)            
           		VEngine::Thread_LoadGameList_Action()
           		vImages::Screens_Show()            	
                ProcedureReturn  				
            EndIf
            
                        
            Delay(30)
            
            ; Auswählen mit welchen Programm die Spiele verknüpft werden sollen            
            ;
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  Str(ls) +" Titel Gefunden", "Ok und bereit zum Importieren der Titel?",12,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            If ( Result = 1 ) 
           		ButtonEX::Disable(DC::#Button_001, false)            
           		ButtonEX::Disable(DC::#Button_002, false) 
           		ButtonEX::Disable(DC::#Button_287, false)  				
            	SetActiveWindow(DC::#_Window_001)
            	SetActiveGadget(DC::#ListIcon_001)            
           		VEngine::Thread_LoadGameList_Action()
           		vImages::Screens_Show()            	
            	ProcedureReturn 
            EndIf
            
            
            ; Anzahl der Items in der DB Prüfen
            ;
        	Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
                
        	Delay(30)
        	
        	Startup::*LHGameDB\GameID = ExecSQL::LastRowID(DC::#Database_001,"Gamebase")
        	
        	SourceGameID.i            = Startup::*LHGameDB\GameID
        	If ( SourceGameID = 0 )
        		SourceGameID + 1
        	EndIf
        	
        	ResetList( mdil() )

            *Params.MAME_DRIVER_PARAMS_LIST = AllocateMemory(SizeOf(MAME_DRIVER_PARAMS_LIST))
          	InitializeStructure(*Params, MAME_DRIVER_PARAMS_LIST)
          	
          	CopyList( mdil(), *Params\mdil() )		
            		
        	Protected MAME_Driver_Import.i
        	MAME_Driver_Import = CreateThread(@Thread_MAME_Driver_Import(), *Params )  
        	ThreadPriority(MAME_Driver_Import, 31) 
        	
        	While IsThread(MAME_Driver_Import)		                           
        		While WindowEvent()                                    
        		Wend
        	Wend
    	           
    			SetGadgetText(DC::#Text_001, "")
    			SetGadgetText(DC::#Text_002, "")	     				
    			SetGadgetText(DC::#Text_003, "...")
        	
        	ClearStructure(*Params,MAME_DRIVER_PARAMS_LIST)
        	FreeMemory(*Params)
        	
        	ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1)
        	
        	Startup::*LHGameDB\GameID = SourceGameID
        	
        	; Auswählen mit welchen Programm die Spiele verknüpft werden sollen            
					;
        	Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  Str(ls) +" Titel Verknüpfen", "Für die zu Importierten ("+ Str(ls) +") Titel ein Programm auswählen?",12,-1,ProgramFilename(),0,0,DC::#_Window_001 )                        
        	If ( Result = 0 ) 
        		Delay(10)
        		vWindows::OpenWindow_Sys2()                
        		
        		PortValID.i = 0
        		PortValID   = Val(ExecSQL::nRow(DC::#Database_001,"Gamebase","PortID","", SourceGameID,"",1))    				
        		
        		ResetList( mdil() )
        		
        		CurrentIndexID =  SourceGameID-1        		
        		While NextElement( mdil() )
        			Delay(5)        			
        			CurrentIndexID + 1

        			SetGadgetText(DC::#Text_003, "..In Progress: Linking [ " + Str( CurrentIndexID ) +" ]")  
        			
        			ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "PortID", Str(PortValID), CurrentIndexID)
        			Thread_HTTP_MAME_Roms_DoEvents() 
        		Wend
        		SetGadgetText(DC::#Text_003,"...")
        	EndIf 
        	
           ButtonEX::Disable(DC::#Button_001, false)            
           ButtonEX::Disable(DC::#Button_002, false) 
           ButtonEX::Disable(DC::#Button_287, false)
            
           VEngine::Thread_LoadGameList_Action()
           vImages::Screens_Show()
           
           SetActiveWindow(DC::#_Window_001)
           SetActiveGadget(DC::#ListIcon_001)           
           
           ListBox_GetData_LeftMouse(#True)           
           
           Delay(150)
                   	
           Request::MSG(Startup::*LHGameDB\TitleVersion, "Ergebnis" , Str(ls) + " Titel wurden Importiert" ,2,0,"",0,0,DC::#_Window_001)
           
           SetActiveWindow(DC::#_Window_001)
           SetActiveGadget(DC::#ListIcon_001)
           
           ClearList( mdil() )
           
           
    	EndIf	
    	
    	 ProcedureReturn 
   	EndProcedure  
  ;
  ;
	;   
	Procedure 		Thread_HTTP_MAME_Roms(*Params.HTTP_INDEX) 
		
	  Protected isLoop.b	= 1 
	  Protected Bytes.l	= 0 
	  Protected fBytes.l	= 0 
	  Protected Buffer.l	=4096 
	  Protected OpenType.b	= 1 
	  Protected memID
	  Protected hInet
	  Protected hURL
	  Protected myMax
	  Protected EndSize.s = MathBytes::FileSizeFormat(*Params\Size)
	  
	  File.s = *Params\File
	  
	  memID = AllocateMemory(Buffer) 
	  
	  FileHandle.l = CreateFile(#PB_Any, File) 
	  
	  hInet 	= InternetOpen_("", OpenType, #Null, #Null, 0) 
	  hURL 		= InternetOpenUrl_(hInet, *Params\Urls , #Null, 0, #INTERNET_FLAG_RELOAD, 0) 
	  	
	  	SetGadgetText(DC::#Text_001, GetFilePart( File) + " ( Size: "+ EndSize + " ) ")
		  SetGadgetText(DC::#Text_002,".. Get and Download ..")			       				        	
		  SetGadgetText(DC::#Text_003, "...")    						
		  
		  Delay( 250 )
		  
		  Repeat 
		  	InternetReadFile_(hURL, memID, Buffer, @Bytes) 
		  	If Bytes = 0 
		  		isLoop=0 
		  	Else 
		  		fBytes=fBytes+Bytes
		  		SetGadgetText(DC::#Text_002,".. Download ..")   		  		
		  		SetGadgetText(DC::#Text_003, GetFilePart( File,#PB_FileSystem_NoExtension )+ ": " + EndSize + " / " + MathBytes::FileSizeFormat(fBytes) )
		  		WriteData(FileHandle, memID, Bytes) 
		  	EndIf 
		  	
		  	Thread_HTTP_MAME_Roms_DoEvents()
		  Until isLoop=0 

		
	  InternetCloseHandle_(hURL) 
	  InternetCloseHandle_(hInet) 
	  
	  CloseFile(FileHandle)    
	  
	  FreeMemory(memID) 
	  SetGadgetText(DC::#Text_002,".. Finished ..")	  
	  SetGadgetText(DC::#Text_003, GetFilePart( File,#PB_FileSystem_NoExtension )+ ": " + EndSize + " / OK ..")
	  Delay(500)
	  
	EndProcedure   
	;
	;
	;
	Procedure.i  MAME_End_Procedure()
		
		SetActiveWindow(DC::#_Window_001)
		SetActiveGadget(DC::#ListIcon_001)
		vSys_MainButtonsConfig(#False)           	
		ListBox_GetData_LeftMouse(#True)           	
		HideGadget(DC::#ListIcon_001,0)           
		HideGadget(DC::#Text_003,1)              	
	EndProcedure		
	;
	;
	;		
  Procedure.i  MAME_Roms_Check_Import()  
  	
  	
  	; Intro
		;
    	vSys_MainButtonsConfig()
    	
        SetGadgetText(DC::#Text_001,"")
        SetGadgetText(DC::#Text_002,"")    	
    	
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Rom Copy", "Mame Roms Sortiert kopieren?" + #CRLF$ + #CRLF$ + "Welche Datei?" +#CRLF$ +"Die Datei zum importieren muss vorher mit 'Mame.exe -listroms' erstellt werden.",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
        If ( Result = 1 ) 
			MAME_End_Procedure()
        	ProcedureReturn 
        EndIf    	

        HideGadget(DC::#ListIcon_001,1)           
        HideGadget(DC::#Text_003,0)
         
        Intro$ = "[ .. M.A.M.E. .. ]"         
        SetGadgetColor(DC::#Text_003, #PB_Gadget_BackColor, RGB(61,61,61)):SetGadgetText(DC::#Text_003,"[ ]"): Delay(85): Thread_LoadGameList_Anim(10, DC::#Text_003): SetGadgetText(DC::#Text_003,Intro$)
                 
        
    	Protected ExportFile$, FileHandle.l, StrLine.s, StrRead.s, QDirectory.s, RomCount.i = 0
    	
    	Structure MAME_ROMS_IMPORT_LIST
    		rom.s
    		RomDescription.s    		
        EndStructure    	
        
    	Structure MAME_ROMS_DIRECTORY_LIST
    		FullPath.s
    		CopyOK.i
    		SHA1.s
    		NotFound.s
    		NotOK.i
    		RomDescription.s
        EndStructure 
        
    	Structure MAME_ROMS_FILESUFFIX_LIST
        	suffix.s
        EndStructure  
        
        *Params.HTTP_INDEX = AllocateMemory(SizeOf(HTTP_INDEX))
        InitializeStructure(*Params, HTTP_INDEX)
        
        
        NewList MRIL.MAME_ROMS_IMPORT_LIST()
        NewList MRDL.MAME_ROMS_DIRECTORY_LIST()        
        NewList MRFL.MAME_ROMS_FILESUFFIX_LIST() 
        
        ; Dateieindungen hinzufügen
        ;
        AddElement( MRFL() ):  MRFL()\suffix = ".zip"
        AddElement( MRFL() ):  MRFL()\suffix = ".7z"
        AddElement( MRFL() ):  MRFL()\suffix = ".rar"
        ResetList(  MRFL() )
        
        SetActiveGadget(-1) 
    	
        ExportFile$ = MAME_Search_ExportFile("ROMS-LIST")  
        If ( Len( ExportFile$ ) = 0 )
        	ExportFile$ = FFH::GetFilePBRQ("-Listroms Exported File",Startup::*LHGameDB\Base_Path, #False, "Mame Listroms Export File [Roms] (*.*)|*.*;", 0, #True)
        	If ( Len( ExportFile$ ) = 0 )
        		MAME_End_Procedure()         	
        		ProcedureReturn 
        	EndIf    			    			
        EndIf
        
    	    	
    	ExportPath$ = Getfile_Portbale_ModeOut(ExportFile$)
    		
    	If ( Len( ExportPath$ ) >= 1 )
    		
    		FileHandle = ReadFile(#PB_Any, ExportPath$)
    		
    		If ( FileHandle >= 0 )
    			
    			While Eof(FileHandle) = 0
    				
    				StrRead   =  ReadString(FileHandle)
    				StrLine   =  StrRead    			
    				sLen.i    = Len( StrLine )    		    			
    				
    				StrFindOk.s = "ROMs required for "
    				StrFindNO.s = "No ROMs required for "
    				
    				If FindString(StrLine, StrFindOk, #Null, #PB_String_CaseSensitive)
    					
    					If FindString(StrLine, StrFindNO, #Null, #PB_String_CaseSensitive)
    						Continue
    					EndIf	
    					StrQuotBeg = FindString(StrLine, Chr(34), 1)
    					StrQuotEnd = FindString(StrLine, Chr(34), StrQuotBeg+1)
    					
    					; Hole Rom Name vor dem zeichen der ersten Anführungszeichen
    					RomsName.s = Mid( StrLine, StrQuotBeg+1, (StrQuotEnd - StrQuotBeg) - 1 )
    					
    					AddElement( MRIL() )
    					MRIL()\rom = RomsName
    					
    					If FindString(StrLine, " driver ", #Null, #PB_String_CaseSensitive)
    						MRIL()\RomDescription = "Driver"
    					ElseIf FindString(StrLine, " device ", #Null, #PB_String_CaseSensitive)
    						MRIL()\RomDescription = "Device"
    					EndIf
    					
    					RomCount + 1
    					SetGadgetText(DC::#Text_001, MRIL()\RomDescription)
    					SetGadgetText(DC::#Text_002, MRIL()\rom)	     					
							SetGadgetText(DC::#Text_003, "..In Progress: "+RSet("Found",5,Chr(32)))
    				Else	
    					Continue
    				EndIf
    				
    				Thread_HTTP_MAME_Roms_DoEvents() 
    			Wend
    			
    			CloseFile(FileHandle)
    		Else
    			
    			Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Konnte die Datei nicht öffnen!",2,2,"",0,0,DC::#_Window_001)
    			MAME_End_Procedure()
    			ProcedureReturn  				
    		EndIf    			
    		
    		SetGadgetText(DC::#Text_001,"")
    		SetGadgetText(DC::#Text_002,"")	      		
  			SetGadgetText(DC::#Text_003,"")
    		
    		; Prüfe Roms vom Quellen Verzeichnis (zip, 7z, rar)
    		;    		
  			ResetList( MRIL() ): ls.i = ListSize ( MRIL() )
  			
  			; Prüfen ob die Liste nicht null ist
  			;
  			If ( ls = 0 )
  				Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Keine Roms gefunden",2,2,"",0,0,DC::#_Window_001)
  				MAME_End_Procedure()
  				ProcedureReturn  				
  			EndIf
            
    		If ( ls > 0 )
    			
    			; Verzeichnis Auswahl
    			
    			Directory.s = FFH::GetPathPBRQ("Für ["+Str(RomCount)+"] M.A.M.E Rom(s) - Quell Verzeichnis Auswählen",Startup::*LHGameDB\Base_Path)
    			If ( Len( Directory ) = 0 )
    				MAME_End_Procedure()
    				ProcedureReturn #False
    			EndIf    			
    			
    			QDirectory	= Directory
    			
    			While NextElement( MRIL() )
    				
    				ResetList( MRFL() )
    				
    				AddElement( MRDL() )
    				MRDL()\CopyOK 	= #False 
    				MRDL()\NotOK	= #True
    				MRDL()\RomDescription = MRIL()\RomDescription
    				
    				; Datei Name und Endung 
						;
    				While NextElement( MRFL() )    					    					
    					Select FileSize( Directory + MRIL()\rom + MRFL()\suffix)
    						Case -1
    							MRDL()\NotFound = Directory + MRIL()\rom
    							Continue
    						Case -2      							
    							Continue
    							
    						Default
    							MRDL()\NotOK	= #False
    							MRDL()\FullPath = Directory + MRIL()\rom + MRFL()\suffix   			
    							
    							; SHA1 Prüfung abtasten für das spätere Kopieren
									;
    							MRDL()\SHA1		= FileFingerprint(MRDL()\FullPath, #PB_Cipher_SHA1 )
    							
    							SetGadgetText(DC::#Text_001,MRIL()\rom + " (Größe: "+ MathBytes::FileSizeFormat( FileSize( Directory + MRIL()\rom + MRFL()\suffix  ))+")")
    							SetGadgetText(DC::#Text_002,"..Gefunden..")	    				
									SetGadgetText(DC::#Text_003, "..In Progress: "+RSet("Suche",5,Chr(32))) 							
    							Break
    					EndSelect
    				Wend    				
    				Thread_HTTP_MAME_Roms_DoEvents() 
    			Wend	
    			
    		EndIf
    		
    		SetGadgetText(DC::#Text_001,"")
    		SetGadgetText(DC::#Text_002,"")	    		
    		SetGadgetText(DC::#Text_003,"")
    		
    		; Kopiere Roms zum Zielverzeichnis
    		;
    		ResetList( MRDL() ): ls.i = ListSize ( MRDL() )
    		
    		; Verzeichnis Asuwahl
			; 
    		    		
    		Directory.s = FFH::GetPathPBRQ("Für ["+Str(RomCount)+"] M.A.M.E Rom(s) - Ziel Verzeichnis Auswählen",GetPathPart(ExportFile$))
    		If ( Len( Directory ) = 0 )
				MAME_End_Procedure()
            	ProcedureReturn #False
            EndIf
            	
    		If (QDirectory = Directory)
    			; Selbes Verzeichnis
				; 
    			Repeat
    				Delay( 100 )
    				
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Quell -und Ziel Verzeichnis gleich", "Dateien können nicht in Kopiert werden" ,2,1,"",0,0,DC::#_Window_001 )     			
    				
    				Directory.s = FFH::GetPathPBRQ("Für ["+Str(RomCount)+"] M.A.M.E Rom(s) - Quell Verzeichnis Auswählen",Startup::*LHGameDB\Base_Path)
    				
    			Until (Len(Directory) = 0 ) Or  Not ( QDirectory = Directory )
    			
    			; Aussteigen
    			; 
    			If (Len(Directory) = 0 )
					MAME_End_Procedure()
    				ProcedureReturn #False
    			EndIf
    		EndIf	
    		
    		;
			;   Dateien Kopieren
    		;
    		RequestUser.i = #True
    		RequestResult = 0
    		
    		While NextElement( MRDL() )
    			;
					;
    			If ( MRDL()\NotOK = #False )
    				
    				; Existiert die Datei schon
						;    				
    				If ( FileSize( Directory + GetFilePart( MRDL()\FullPath) ) > 0 )
    					
    					If ( RequestUser = #True ) And ( RequestResult = 0 )
    						
    						Request::*MsgEx\User_BtnTextL = "Überschreiben"
    						Request::*MsgEx\User_BtnTextM = "Überspringen"    					
    						Request::*MsgEx\User_BtnTextR = "Abbruch"
    						Request::*MsgEx\CheckBox_Txt  = "Alle Überspringen oder Überschreiben?"
    						TempMessage.s = "Die Datei '" + GetFilePart( MRDL()\FullPath) + "' überschreiben?" + #CRLF$ + #CRLF$ + "Ziel: "+ Directory + #CRLF$ + "Alle existierenden Dateien Überspringen?"
    						
    						Result.i = Request::MSG(Startup::*LHGameDB\TitleVersion, "Datei Existiert!", TempMessage ,16,1,"",1,0,DC::#_Window_001)
    						Select Result
    							Case 2
    								MRDL()\CopyOK = #True
    								Continue
    								
    							Case 4 ; Alle Überschreiben
    								RequestUser = #False
    								RequestResult = 4
    								
    							Case 6 ; Alle Überspringen
    								RequestUser   = #False
    								RequestResult = 6
    								MRDL()\CopyOK = #True
    								Continue
    								
    							Case 1,5 ; Abbruch
    								MAME_End_Procedure()
    								ProcedureReturn #False
    								
    						EndSelect			                   		
    					EndIf
    					
    					If RequestResult = 6
    						; Alle Überspringen und wird als OK Markiert
    						MRDL()\CopyOK = #True
    						Continue
    					EndIf
    				EndIf    					
    				
    				CopyFile( MRDL()\FullPath , Directory + GetFilePart( MRDL()\FullPath) )
    				SetGadgetText(DC::#Text_001,"..Kopiere..")
    				SetGadgetText(DC::#Text_002, GetFilePart( MRDL()\FullPath,#PB_FileSystem_NoExtension) + " (Größe: "+ MathBytes::FileSizeFormat( FileSize( MRDL()\FullPath ))+")")	
    						
    				SetGadgetText(DC::#Text_003, "..In Progress: "+RSet("Copy",5,Chr(32))+"..")
    				
    				Delay( 25 )	    			
    				; 
						;
    				Select FileSize( Directory + GetFilePart( MRDL()\FullPath) )
    					Case -1
    						Continue
    					Case -2
    						Continue
    					Default
    						SHA1ZIEL.s = FileFingerprint( Directory + GetFilePart( MRDL()\FullPath), #PB_Cipher_SHA1 )
    						
    						If (SHA1ZIEL = MRDL()\SHA1)
    							SetGadgetText(DC::#Text_003, "..In Progress: "+RSet("Ok",5,Chr(32))+"..")
    							MRDL()\CopyOK = #True
    							
    							; Löschen
									;									    						
    						Else
    							SetGadgetText(DC::#Text_003, "..In Progress: ERROR")
    							Request::MSG(Startup::*LHGameDB\TitleVersion, "Datei Kopier Fehler!?","Kopierte Datei und Original sind unterschiedlich"  + #CRLF$ + #CRLF$ +
    							                                                                      "SHA1 Wert Original: " +  MRDL()\SHA1  + #CRLF$ +
    							                                                                      "SHA1 Wert Kopiert : " +  SHA1ZIEL     + #CRLF$ + #CRLF$ +
    							                                                                      "Datei: " + Directory + GetFilePart( MRDL()\FullPath),2,2,"",0,0,DC::#_Window_001)
    							MRDL()\CopyOK = #False
    						EndIf    					    					
    				EndSelect
    			EndIf
    			Thread_HTTP_MAME_Roms_DoEvents() 
    		Wend	    		    		
    	EndIf
    	
    	;
		; Beendigungs Teil
		;
    	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")	    		
    	SetGadgetText(DC::#Text_003,"")
    	ResetList( MRDL() )
    	Protected ErrorFiles.s 	= ""
    	Protected ErrorCount.i 	= 0
    	Protected ErrorCntSHA1.i	= 0
    	Protected DriverCount.i 	= 0
    	Protected DeviceCount.i 	= 0
    	Protected FileToDownload.s
    	Protected AchvHead.s		= "sptth" 
    	
    	While NextElement( MRDL() )
    		If ( MRDL()\NotOK = #True )
    			;
				; Fehler festhalten
    			;
    			ErrorCount + 1
    			ErrorFiles.s + MRDL()\RomDescription+ ": "+  GetFilePart( MRDL()\NotFound) + #CRLF$
    		EndIf
    		If ( MRDL()\CopyOK = #False )
    			ErrorCntSHA1 + 1
    		EndIf	
    		
    		If ( MRDL()\RomDescription = "Driver" )
    			If ( MRDL()\CopyOK = #True )
    				DriverCount + 1
    			EndIf
    		EndIf
    		
    		If ( MRDL()\RomDescription = "Device" )
    			If ( MRDL()\CopyOK = #True )
    				DeviceCount + 1
    			EndIf	
    		EndIf 
    		Thread_HTTP_MAME_Roms_DoEvents() 
    	Wend
    	
    	If (ErrorCount > 0 )
    		    		
    		Request::*MsgEx\User_BtnTextL = "Beziehen"
    		Request::*MsgEx\User_BtnTextR = "Beenden"
    		EnableCheckBox.i 			  = 1
    		
    		If ( DriverCount > 0 )    			
    			Request::*MsgEx\CheckBox_Txt  = "Kopierte Roms löschen? ("+Str(DriverCount)+" Driver in den Papierkorb verschieben)"
    		Else
    			EnableCheckBox = 0
    		EndIf
    		
    		Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Dateien konnten nicht gefunden werden.","Backup aus dem Internet beziehen ?" + #CRLF$ +  #CRLF$ + "Zielverzeichnis:" + #CRLF$ +  Directory +  #CRLF$ + #CRLF$ + ErrorFiles,10,0,ProgramFilename(),EnableCheckBox,0,DC::#_Window_001)
    		If Result = 0 Or Result = 4 Or Result = 5
    			
    			;Try To Download
    			ResetList( MRDL() )
    			While NextElement( MRDL() )
    				
    				*Params\File = ""
    				*Params\Size = 0
    				*Params\Urls = ""
    				Filesize.q	 = 0
    				
    				SetGadgetText(DC::#Text_001,"")
    				SetGadgetText(DC::#Text_002,"")				       				        	
    				SetGadgetText(DC::#Text_003,"")
    				
    				If ( MRDL()\NotOK = #True )
    					If ( Result = 0 ) Or ( Result = 4 )
    						
    						SetGadgetText(DC::#Text_001,"Rom: " + GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension)  )
    						SetGadgetText(DC::#Text_002,"Dir: " + Directory + " (Remaining: " + Str(ErrorCount) + ")")				       				        	
    						SetGadgetText(DC::#Text_003, ".. Get Size ..")
    						
    						Filesize = FFH::HTTP_GetContentLength( ReverseString( AchvHead ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) + GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension) + ReverseString( "piz." ) )			        				        	
    						
    						*Params\File = Directory + GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension) + ".zip"
    						
    						If Filesize = 0
    							
    							SetGadgetText(DC::#Text_003, ".. Error not found: "+ GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension) +"..")
    							Thread_HTTP_MAME_Roms_DoEvents() 
    							Delay( 1100 )
    							ErrorCount - 1    							
    							Continue
    							
    						ElseIf ( Filesize = FileSize( *Params\File ) )		
    							SetGadgetText(DC::#Text_003, ".. Existiert: "+ GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension) +"..")
    							Thread_HTTP_MAME_Roms_DoEvents() 
    							Delay( 1100 ) 
    							ErrorCount - 1
    							Continue
    						EndIf
    						
    						*Params\Size = Filesize
    						*Params\Urls = ReverseString( AchvHead ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) + GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension) + ReverseString( "piz.")
    						    						
    						Protected HTTP_Thread.i
    						HTTP_Thread = CreateThread(@Thread_HTTP_MAME_Roms(),*Params)  
    						ThreadPriority(HTTP_Thread, 31) 
    						
    						While IsThread(HTTP_Thread)		                           
    							While WindowEvent()                                    
    							Wend
    						Wend 	        		
    						
    						Delay(500)
    						If Not Filesize = FileSize( *Params\File )
    							Request::*MsgEx\User_BtnTextL = "Download"
    							Request::*MsgEx\User_BtnTextR = "Weiter"       							
    							Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Fehler beim Sichern der Datei. Größe ist unterschielich." + #CRLF$ + "Local: " + MathBytes::FileSizeFormat( FileSize( *Params\File ) ) + #CRLF$ + "Remote: " + MathBytes::FileSizeFormat(Filesize)  +  #CRLF$ + #CRLF$ + "ReDownload? Datei neu runterladen?" ,10,2,"",0,0,DC::#_Window_001)
    							If Result = 0
    								PreviousElement( MRDL() )
    								Thread_HTTP_MAME_Roms_DoEvents() 
    							EndIf	
    							Continue
    						EndIf
    						
    						SetGadgetText(DC::#Text_001,"Rom: " + GetFilePart( MRDL()\NotFound,#PB_FileSystem_NoExtension)  )		            	
    						SetGadgetText(DC::#Text_002,"Dir: " + Directory + " (Remaining: " + Str(ErrorCount) + ")")	
    						SetGadgetText(DC::#Text_003, ".. Finished ..")
    						ErrorCount - 1
    						Delay(800)
    					EndIf
    				EndIf			        
    				
    				If ( Result = 4 ) Or (Result = 5)			        
    					If ( MRDL()\CopyOK = #True) 	
    						If ( MRDL()\RomDescription = "Driver" )  
    							FFH::_Recycle(  MRDL()\FullPath )
    							SetGadgetText(DC::#Text_001,"Lösche und verschiebe in den Papierkorb..")
    							SetGadgetText(DC::#Text_002,"")     							
    							SetGadgetText(DC::#Text_003, "[ Remaining: " + RSet( Str(DriverCount), 4,"#") +" ] " + GetFilePart( MRDL()\FullPath) )
    							DriverCount-1
    							Delay(25)
    						EndIf	
    					EndIf			        
    				EndIf
    				Thread_HTTP_MAME_Roms_DoEvents() 
    			Wend
    		EndIf
    		
	    ElseIf (ErrorCount = 0)  
	    	
    		Request::*MsgEx\User_BtnTextL = "Ok" 					
    		Request::*MsgEx\CheckBox_Txt  = "Kopierte Roms löschen ("+Str(DriverCount)+" Driver in den Papierkorb verschieben) ?"
    		
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Dateien Kopiert", "Dateien wurden Kopiert: " + Str(RomCount) + " (Mame Export List)/ " + Str( ListSize( MRDL() )) + " (Dateien)/ Fehler " + Str(ErrorCntSHA1),2,0,ProgramFilename(),1,0,DC::#_Window_001)
            If Result = 4 
            	
            	ResetList( MRDL() )
            	While NextElement( MRDL() )
            		
            		If ( MRDL()\RomDescription = "Driver" )            		
            			Debug "Lösche : " +  MRDL()\FullPath
            			FFH::_Recycle(  MRDL()\FullPath )
    							SetGadgetText(DC::#Text_001,"Lösche und verschiebe in den Papierkorb..")
    							SetGadgetText(DC::#Text_002,"")     							
    							SetGadgetText(DC::#Text_003, "[ Remaining: " + RSet( Str(DriverCount), 4,"#") +" ] " + GetFilePart( MRDL()\FullPath) )
    							DriverCount-1            			
            			Delay(25)
            		EndIf
            		Thread_HTTP_MAME_Roms_DoEvents() 
            	Wend	
            EndIf	
        EndIf        
		    
		MAME_End_Procedure()
		ProcedureReturn 
			
	EndProcedure
	;
	;
	;		
	Procedure.i 	MAME_Roms_Check()				;-verifyroms
		
		vSys_MainButtonsConfig()
    	
        SetGadgetText(DC::#Text_001,"")
        SetGadgetText(DC::#Text_002,"")    	      
        
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Rom Check", "Roms Überprüfen?" + #CRLF$ + #CRLF$ + "Welche Datei?" +#CRLF$ +"Benötigt wird die Datei die vorher mit 'Mame.exe -verifyroms' erstellt wurde.",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
        If ( Result = 1 ) 
			MAME_End_Procedure()
        	ProcedureReturn 
        EndIf    	

        HideGadget(DC::#ListIcon_001,1)           
        HideGadget(DC::#Text_003,0)
         
        Intro$ = "[ .. M.A.M.E. .. ]"         
        SetGadgetColor(DC::#Text_003, #PB_Gadget_BackColor, RGB(61,61,61)):SetGadgetText(DC::#Text_003,"[ ]"): Delay(85): Thread_LoadGameList_Anim(10, DC::#Text_003): SetGadgetText(DC::#Text_003,Intro$)
        
    	Structure MAME_ROMS_CHECK_FILES
    		Filename.s
    	EndStructure	
    	Structure MAME_ROMS_CHECK_LIST
    		RomSet.s
    		NotFound.i
    		Good.i
    		Bad.i
    		NoDump.s
    		Files.s
    		Clone.i
    		RomClone.s
    		NeedRedump.s
    		List MRCF.MAME_ROMS_CHECK_FILES()
    	EndStructure   
    	
    	NewList MRCL.MAME_ROMS_CHECK_LIST()  	
    	
      ExportFile$ = MAME_Search_ExportFile("ROMS-VERIFY")  
       If ( Len( ExportFile$ ) = 0 )
    		ExportFile$ = FFH::GetFilePBRQ("-VerifyRoms Exportet File",Startup::*LHGameDB\Base_Path, #False, "Mame Verify Export File [Roms] (*.*)|*.*;", 0, #True)
       	If ( Len( ExportFile$ ) = 0 )
       		MAME_End_Procedure()         	
       		ProcedureReturn 
       	EndIf    			    			
       EndIf

    	
    	ExportPath$ = Getfile_Portbale_ModeOut(ExportFile$)
    		
    	If ( Len( ExportPath$ ) >= 1 )
    		
			FileHandle = ReadFile(#PB_Any, ExportPath$)
    		
    		If ( FileHandle >= 0 )
    			    			
    			While Eof(FileHandle) = 0
    				
	   				StrRead.s   =  ReadString(FileHandle)
	    			StrLine.s   =  StrRead    			
	    			sLen.i    	= Len( StrLine )    		    			
	    			
	    			Position.i	= -1
	    			
	    			If FindString(StrLine, "0 romsets found, 0 were OK.",0,#PB_String_CaseSensitive)
	    				Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Keine Roms wurden in der Datei zum überprüfen gefunden" + #CRLF$ + #CRLF$ + "0 romsets found, 0 were OK.",2,2,"",0,0,DC::#_Window_001)
							CloseFile(FileHandle)	    				
							MAME_End_Procedure()
							ProcedureReturn  
					EndIf	
	    			
	    			Position = FindString( StrLine , "romset",1)
	    			If ( Position > 0 )	
	    				If FindString( StrLine , " is bad",1) Or FindString( StrLine , " is good",1)	 Or FindString( StrLine , " is best available",1)
	    					
	    					AddElement( MRCL() )
	    					
	    					MainRom.s = ""
	    					Cloned.s  = ""
	    					
	    					If FindString( StrLine , " is bad",1)
	    						MRCL()\Bad 	 = #True
	    						Pos.i 	 = FindString( StrLine , " is bad",1)	
	    					EndIf
	    					
	    					If FindString( StrLine , " is good",1)	 
	    						MRCL()\Good	 = #True
	    						Pos.i 	 = FindString( StrLine , " is good",1)	
	    					EndIf
	    					
	    					If FindString( StrLine , " is best available",1)	 
	    						MRCL()\Good	 = #True
	    						Pos.i 	 = FindString( StrLine , " is best available",1)	
	    					EndIf	    					
	    					
	    					MRCL()\Clone = #False	
	    					MainRom 	 =  Mid( StrLine, Position + 7, Pos - (Position + 7) )
	    					
	    					PosKlammerBeg.i = FindString( StrLine , " [",1)
	    					PosKlammerEnd.i = FindString( StrLine , "] ",PosKlammerBeg + 1)	 
	    					
	    					If ( PosKlammerBeg > 1 ) And ( PosKlammerEnd > 1 ) 
	    						;
	    						; Clone gefunden, in den Klammenr is es das Hauptrom
								;		
	    						MRCL()\Clone = #True	    						
	    						Cloned   = Mid( StrLine, PosKlammerBeg + 2,  ( PosKlammerEnd -1) - ( PosKlammerBeg +1) )
	    						MainRom  = ReplaceString( MainRom, " [" + Cloned  + "]",Chr(32) )	    						
	    					EndIf
	    					MRCL()\RomSet   = Trim( MainRom, Chr(32) )
	    					MRCL()\RomClone = Trim( Cloned, Chr(32) ) 					
	    					SetGadgetText(DC::#Text_003,"[..Get Titles ("+Str(ListSize( MRCL() ) ) +")..]")	    					
	    				EndIf
	    			EndIf
	    			Thread_HTTP_MAME_Roms_DoEvents()
	    		Wend	    			    			    		
	    		CloseFile(FileHandle)
	    		
	    		FileHandle = ReadFile(#PB_Any, ExportPath$)
	    		While Eof(FileHandle) = 0
	    			
	    			StrRead.s   =  ReadString(FileHandle)
	    			StrLine.s   =  StrRead    			
	    			sLen.i    	= Len( StrLine ) 
	    			
	    			Position.i	= -1
	    			Position = FindString( StrLine , " : ",1)
	    			If ( Position > 0 )
							  If ( FindString( StrLine , ") - NOT FOUND",1, #PB_String_CaseSensitive) )
	    					
	    					ErrorRom.s = ""
	    					ErrorRom   = Trim( Mid( StrLine,0, Position-1), Chr(32) )    					
	    					
	    					ResetList( MRCL() )
	    					
	    					While NextElement(  MRCL() )
	    						If  ( MRCL()\RomSet = ErrorRom )
	    							
	    							MRCL()\NotFound = #True
	    							MRCL()\Bad = #True 	    							
	    							AddElement(  MRCL()\MRCF() )
	    								    							
	    							PosKlammerBeg.i = FindString( StrLine , " (",1)
	    							PosKlammerEnd.i = FindString( StrLine , ") ",PosKlammerBeg + 1)
	    							
	    							MRCL()\MRCF()\Filename = Mid( StrLine, Position + 3, ( PosKlammerBeg - 2) -  Position)
	    							SetGadgetText(DC::#Text_003,"[..Search Files: "+MRCL()\MRCF()\Filename+" (Adding)..]")	
	    							
	    							If ( FindString( StrLine , "NOT FOUND - NO GOOD DUMP KNOWN",1, #PB_String_CaseSensitive) )
	    								MRCL()\NoDump = "No Good Dump Known"
	    								MRCL()\MRCF()\Filename = "[**]" + MRCL()\MRCF()\Filename
	    							EndIf
	    							Break
	    						EndIf
	    						Thread_HTTP_MAME_Roms_DoEvents() 	    						
	    					Wend
	    					Continue
	    				EndIf
	    				
	    				If ( FindString( StrLine , ") - NEEDS REDUMP",1, #PB_String_CaseSensitive) )
	    					ErrorRom.s = ""
	    					ErrorRom   = Trim( Mid( StrLine,0, Position-1), Chr(32) )    					
	    					ResetList( MRCL() )
	    					While NextElement(  MRCL() )
	    						If  ( MRCL()\RomSet = ErrorRom )
	    							MRCL()\NotFound = #True
	    							MRCL()\Bad = #True 
	    							MRCL()\NeedRedump = "Needs Redump"
	    							AddElement(  MRCL()\MRCF() )
	    							
	    							
	    							PosKlammerBeg.i = FindString( StrLine , " (",1)
	    							PosKlammerEnd.i = FindString( StrLine , ") ",PosKlammerBeg + 1)
	    							
	    							MRCL()\MRCF()\Filename = Mid( StrLine, Position + 3, ( PosKlammerBeg - 2) -  Position)
	    							SetGadgetText(DC::#Text_003,"[..Search Files: "+MRCL()\MRCF()\Filename+" (Adding)..]")
	    							
	    							MRCL()\MRCF()\Filename = MRCL()\MRCF()\Filename + "[!!]"
	    							
	    							Break
	    						EndIf
	    						Thread_HTTP_MAME_Roms_DoEvents() 
	    					Wend
	    					
	    				EndIf	
	    			EndIf	    			
	    		Wend	
	    		CloseFile(FileHandle)
	    		
    		Else  			
    			Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Konnte die Datei nicht öffnen!",2,2,"",0,0,DC::#_Window_001)
    			MAME_End_Procedure()
    			ProcedureReturn  				
    		EndIf
    		
    		ResetList( MRCL() )
    		
    		Protected CountGood.i		= 0
    		Protected CountBad.i		= 0
    		Protected CountNotFnd.i	= 0            
    		Protected ErrorNotFound.s	= ""
    		Protected CloneMessage.s	= ""
    		Protected CurrentRomSet.s	= ""
    		While NextElement( MRCL() )	
    			If MRCL()\Bad = #True 
    				CountBad + 1         		
    			EndIf
    			If MRCL()\Good = #True 
    				CountGood + 1         		
    			EndIf  
    			If MRCL()\NotFound = #True 
    				CountNotFnd + 1         		
    			EndIf             		
    		Wend	
    		
    		SetGadgetText(DC::#Text_003,"")  
    		
    		If CountBad > 0
    			ResetList( MRCL() )
    			CountNotFndA = CountNotFnd
    			
    			While NextElement( MRCL() )
    				
    				Debug ""
    				Debug "ROM       : " +  MRCL()\RomSet
    				Debug "ROM(Clone): " +  MRCL()\RomClone
    				Debug "No Dump   : " +  MRCL()\NoDump	
    				
    				DumpMessage.s = ""
    				NeedsRedump.s = ""
    				
    				If MRCL()\Bad = #True 
    					If MRCL()\NotFound = #True
    						
    						If Len( MRCL()\NoDump ) > 0
    							DumpMessage = MRCL()\NoDump
    						EndIf	
    						If Len( MRCL()\NeedRedump ) > 0
    							NeedsRedump = MRCL()\NeedRedump
    						EndIf    						
    							
    							CloneMessage = ""
    							If MRCL()\Clone = #True
    								CloneMessage = " [ Cloned: " + MRCL()\RomClone + " ]"
    							EndIf
    							
    							If ( ListSize( MRCL()\MRCF() ) > 0 )  
    								ResetList( MRCL()\MRCF() )
    								ErrorNotFound + #CRLF$
    								While NextElement( MRCL()\MRCF() )
    									If FindString( MRCL()\MRCF()\Filename , "[!!]",1)
    										ReGoodDumpFile.s = ReplaceString( MRCL()\MRCF()\Filename, "[!!]","" )      										  
    										ErrorNotFound + #CRLF$ + "Rom: " + LSet( MRCL()\RomSet,20,Chr(32) )  +  "| [!!]: " + LSet( ReGoodDumpFile        ,16,Chr(32) ) + " (Not Found) " + CloneMessage
    										  
    									ElseIf FindString( MRCL()\MRCF()\Filename , "[**]",1)
    										NoGoodDumpFile.s = ReplaceString( MRCL()\MRCF()\Filename, "[**]","" )    										
    										ErrorNotFound + #CRLF$ + "Rom: " + LSet( MRCL()\RomSet,20,Chr(32) )  +  "| [**]: " + LSet( NoGoodDumpFile        ,16,Chr(32) ) + " (Not Found) " + CloneMessage
    										
    									Else
    										ErrorNotFound + #CRLF$ + "Rom: " + LSet( MRCL()\RomSet,20,Chr(32) )  +  "| File: " + LSet( MRCL()\MRCF()\Filename,16,Chr(32) ) + " (Not Found) " + CloneMessage
    										
    									EndIf
    									
    									Thread_HTTP_MAME_Roms_DoEvents()
    									SetGadgetText(DC::#Text_003,"[..Create Result ("+ Str(CountNotFndA) +")..]")    									
    								Wend
    								
    								If Len( DumpMessage ) > 0 And Len( NeedsRedump ) > 0
    									
    									ErrorNotFound + #CRLF$ + DumpMessage +  " [**]" + "/ " + NeedsRedump + " [!!]"
    									
    								ElseIf Len( DumpMessage ) > 0 And Len( NeedsRedump ) = 0
    									ErrorNotFound + #CRLF$ + DumpMessage +  " [**]" 
    									
    								ElseIf Len( DumpMessage ) = 0 And Len( NeedsRedump ) > 0	
    									ErrorNotFound + #CRLF$  + NeedsRedump + " [!!]" 								
    								EndIf		
    								
										CountNotFndA - 1    								
    							EndIf		            						            				            				            				
    						EndIf	            			
    					EndIf            		            		
    	
    			Wend
				
    			SetGadgetText(DC::#Text_003,"") 
    			
    			Request::*MsgEx\Fnt2 = FontID(Fonts::#DEJAVUSANS_MONO_09)
    			Request::*MsgEx\User_BtnTextL = "Download"
    			Request::*MsgEx\User_BtnTextR = "Beenden"
    			
    			Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Ergebnis",ErrorNotFound,10,0,ProgramFilename(),0,0,DC::#_Window_001)				
    			If ( Result = 0 )
    				; Verzeichnis Asuwahl
						;     				
    				Directory.s = FFH::GetPathPBRQ("M.A.M.E Rom(s) - Ziel Verzeichnis Auswählen",GetPathPart(ExportFile$))
    				If ( Len( Directory ) = 0 )
    					MAME_End_Procedure()
    					ProcedureReturn #False
    				EndIf    		
    				
    				*Params.HTTP_INDEX = AllocateMemory(SizeOf(HTTP_INDEX))
    				InitializeStructure(*Params, HTTP_INDEX)
    				
    				Protected AchvHead.s		= "sptth" 
    				Protected HTTP_Thread.i
    				CurrentRomSet = "" 
    				
    				ResetList( MRCL() )
    				While NextElement( MRCL() )
    					
    					*Params\File = ""
    					*Params\Size = 0
    					*Params\Urls = ""
    					
    					
    					If MRCL()\Bad = #True And MRCL()\NotFound = #True ;And Len( MRCL()\NoDump ) = 0 
    						
    						If CurrentRomSet = MRCL()\RomSet
    							Continue
    						EndIf
    						
    						CurrentRomSet = MRCL()\RomSet
    						
    						SetGadgetText(DC::#Text_001,"Rom: " + CurrentRomSet  )
    						SetGadgetText(DC::#Text_002,"Dir: " + Directory + " (Remaining: " + Str(CountNotFnd) + ")")
    						SetGadgetText(DC::#Text_003, "...")	
    						
    						NoGoodDumps.i = 0
    						FileDumpsLs.i = 0
   							FileReDumps.i = 0
    						If ( ListSize( MRCL()\MRCF() ) > 0 )  
    								ResetList( MRCL()\MRCF() )
    								While NextElement( MRCL()\MRCF() )    						
    									FileDumpsLs + 1
    									If FindString( MRCL()\MRCF()\Filename , "[**]",1)
    										NoGoodDumps + 1    										
    									EndIf
    									If FindString( MRCL()\MRCF()\Filename , "[!!]",1)    										
    										FileReDumps + 1
    									EndIf    									
    									Thread_HTTP_MAME_Roms_DoEvents() 
    								Wend
    						EndIf	    						
    						
    						If ( NoGoodDumps = FileDumpsLs )
    							SetGadgetText(DC::#Text_002,"No Good Dump Known")
    							SetGadgetText(DC::#Text_003,"..No Good Dump Known..")    							
    							Delay( 1100 )
    							Continue
    						EndIf	
    						
    						If ( FileReDumps = FileDumpsLs )
    							SetGadgetText(DC::#Text_002,"Re-Dump Needed")
    							SetGadgetText(DC::#Text_003,"..Re-Dump Needed..")    							
    							Delay( 1100 )
    							Continue
    						EndIf  
    						
    						If ( (FileReDumps + NoGoodDumps) = FileDumpsLs )
    							SetGadgetText(DC::#Text_002,"Re-Dump Needed/No Good Dump Known")
    							SetGadgetText(DC::#Text_003,"..Re-Dump / No Good Dump..")    							
    							Delay( 1100 )
    							Continue
    						EndIf    						
    							
    						If MRCL()\Clone = #True
    							
    							SetGadgetText(DC::#Text_001,"Rom: " + CurrentRomSet + " (Cloned: "+ MRCL()\RomClone +")")
    							;
									; Merged Only
									;
									;CurrentRomSet = MRCL()\RomClone
    							
    						EndIf
    						
    						SetGadgetText(DC::#Text_003, ".. Get Size ..")
    						FileSize.q = FFH::HTTP_GetContentLength( ReverseString( AchvHead ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) + CurrentRomSet + ReverseString( "piz." ) )				        					        	
    						If FileSize( Directory + CurrentRomSet + ".zip" ) = FileSize
    							SetGadgetText(DC::#Text_003, ".. File Exists: "+ CurrentRomSet +"..")				        		
    							Delay( 800 )
    							CountNotFnd - 1	
    							MRCL()\Bad 		= #False
    							MRCL()\NotFound = #False	
    							Thread_HTTP_MAME_Roms_DoEvents() 
    							Continue
    							
    						ElseIf FileSize = 0				        						        						        								        						
    							
    							SetGadgetText(DC::#Text_003, ".. Not Found: "+ CurrentRomSet +"..")				        		
    							Delay( 500 )
    							;
									;
									; Try Merged Rom
    							If MRCL()\Clone = #True
    								CurrentRomSet = MRCL()\RomClone
    								
    								SetGadgetText(DC::#Text_003, ".. Get Merged: "+ CurrentRomSet +"..")
    								
    								FileSize.q = FFH::HTTP_GetContentLength( ReverseString( AchvHead ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) + CurrentRomSet + ReverseString( "piz." ) )
    								If FileSize( Directory + CurrentRomSet + ".zip" ) = FileSize
    									SetGadgetText(DC::#Text_003, ".. File Exists: "+ CurrentRomSet +"..")
    									Thread_HTTP_MAME_Roms_DoEvents() 
    									Delay( 800 )				        		
    									CountNotFnd - 1	
    									MRCL()\Bad 		= #False
    									MRCL()\NotFound = #False				        				
    									Continue				        			
    									
    								ElseIf FileSize = 0	
    									SetGadgetText(DC::#Text_003, ".. Not Found: "+ CurrentRomSet +"..")				        		
    									Thread_HTTP_MAME_Roms_DoEvents() 
    									Delay( 800 )			        		
    									Continue
    								EndIf	
    							Else
    								Continue
    							EndIf	
    						EndIf
    						
    						*Params\File = Directory + CurrentRomSet + ".zip"
    						*Params\Size = FileSize
    						*Params\Urls = ReverseString( AchvHead ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) + CurrentRomSet + ReverseString( "piz.")
    						
    						HTTP_Thread = CreateThread(@Thread_HTTP_MAME_Roms(),*Params)  
    						ThreadPriority(HTTP_Thread, 31) 
    						
    						While IsThread(HTTP_Thread)		                           
    							While WindowEvent()                                    
    							Wend
    						Wend
    						
    						Delay(250)
    						If Not Filesize = FileSize( *Params\File )
    							Request::*MsgEx\User_BtnTextL = "Download"
    							Request::*MsgEx\User_BtnTextR = "Weiter"    							
    							Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Fehler beim Sichern der Datei. Größe ist unterschiedlich." + #CRLF$ + "Local: " + MathBytes::FileSizeFormat( FileSize( *Params\File ) ) + #CRLF$ + "Remote: " + MathBytes::FileSizeFormat(Filesize) +  #CRLF$ + #CRLF$ + "ReDownload? Datei neu runterladen?" ,10,2,"",0,0,DC::#_Window_001)
    							If Result = 0
    								PreviousElement( MRCL() )
    							EndIf	    							
    							Continue
    						EndIf
    						
    						SetGadgetText(DC::#Text_001,"Rom: " + CurrentRomSet)				            	
    						SetGadgetText(DC::#Text_002,"Dir: " + Directory + " (Remaining: " + Str(CountNotFnd) + ")")
    						SetGadgetText(DC::#Text_003, "...")
    						
    						MRCL()\Bad 		= #False
    						MRCL()\NotFound = #False
    						CountNotFnd - 1	
    						Delay(250)
    						
    					EndIf
    				Wend
    				
    				CountGood.i		= 0
    				CountBad.i		= 0
    				ErrorNotFound.s	= ""
    				CloneMessage.s	= ""
    				CurrentRomSet.s	= ""
    				ResetList( MRCL() )
    				
    				While NextElement( MRCL() )
    					Debug MRCL()\Bad
    					If MRCL()\Bad = #True 
    						CountBad + 1         		
    					EndIf
    					If MRCL()\Good = #True 
    						CountGood + 1         		
    					EndIf            		
    				Wend
    				
    				If CountBad > 0
    					ResetList( MRCL() )
    					While NextElement( MRCL() )
    						
    						If MRCL()\Bad = #True 
    							If MRCL()\NotFound = #True
    								
    								If Len( MRCL()\NoDump )= 0 
    									
    									CloneMessage = ""
    									If MRCL()\Clone = #True
    										CloneMessage = " [ Cloned: " + MRCL()\RomClone + " ]"
    									EndIf
    									
    									If ( ListSize( MRCL()\MRCF() ) > 0 )  
    										
    										ResetList( MRCL()\MRCF() )
    										While NextElement( MRCL()\MRCF() )
    											ErrorNotFound + #CRLF$ + "Download Error: " + LSet( MRCL()\RomSet,20,Chr(32) )  + "| File: " + MRCL()\MRCF()\Filename + " (Not Found) " + CloneMessage	
    										Wend    										
    									EndIf	            				
    								EndIf	            			
    							EndIf            		            		
    						EndIf
    						Thread_HTTP_MAME_Roms_DoEvents() 
    					Wend
    					If ( Len( ErrorNotFound ) > 0 )
    						Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Ergebnis mit Fehler",#CRLF$ + ErrorNotFound,2,1,ProgramFilename(),0,0,DC::#_Window_001)	
    					Else
    						CountBad = 0
    					EndIf	
    				EndIf
    			EndIf
    		EndIf	
    		
    		If CountBad = 0
    			Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Ergebnis", Str( CountGood ) + " Rom(s) gefunden und Überprüft. Sets sind soweit Komplett",2,0,ProgramFilename(),0,0,DC::#_Window_001)
    		EndIf
    	EndIf
    	
    	MAME_End_Procedure()
    	ProcedureReturn                 
  EndProcedure
	;
	;
	;	    
  Procedure.i 	MAME_Roms_Backup(UserFile.s = "")
    	
    	vSys_MainButtonsConfig()
    	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")    	      
    	
    	HideGadget(DC::#ListIcon_001,1)           
    	HideGadget(DC::#Text_003,0) 
    	
    	SetActiveGadget(-1) 
    	
    	Intro$ = "[ ..25.12.1976.. ]"         
    	SetGadgetColor(DC::#Text_003, #PB_Gadget_BackColor, RGB(61,61,61)):SetGadgetText(DC::#Text_003,"[ ]"): Delay(85): Thread_LoadGameList_Anim(10, DC::#Text_003): SetGadgetText(DC::#Text_003,Intro$)
    	
    	Protected Result.i
    	
    	Request::*MsgEx\Return_String = UserFile
    	Request::*MsgEx\User_BtnTextL = "Ok"
    	Request::*MsgEx\User_BtnTextR = "Abbruch"
    	Request::*MsgEx\User_BtnTextM = "Ändern"       
    	Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Backup", #CRLF$ + "Backup aus dem Internet beziehen? Datei ohne endung angeben" + #CRLF$ + #CRLF$ + "Zielverzeichnis: '" + Startup::*LHGameDB\FolderWWW + "'" ,16,-1,ProgramFilename(),0,1,DC::#_Window_001 )        
    	
    	Debug "Requester Eergebnis: " +  #CRLF$ + Str(Result)
    	If ( Result = 1 )
    		MAME_End_Procedure()      	
    		ProcedureReturn 
    	EndIf
    	
    	If ( Result = 2 )
    		; Verzeichnis Asuwahl
				; 		    		    		
    		Directory.s = FFH::GetPathPBRQ("Ziel Verzeichnis Auswählen",Startup::*LHGameDB\Base_Path)
    		If ( Len( Directory ) = 0 )
    			MAME_End_Procedure()
    			ProcedureReturn
    		Else
    			Startup::*LHGameDB\FolderWWW = Directory
    			MAME_Roms_Backup(Request::*MsgEx\Return_String)
    			ProcedureReturn
    		EndIf   	         
    	EndIf
    	
    	UserFile = Request::*MsgEx\Return_String
    	
    	If Len( UserFile ) = 0
    		Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Backup", #CRLF$ + "Keine Datei angegeben!" ,2,1,ProgramFilename(),0,0,DC::#_Window_001 ) 
    		MAME_Roms_Backup()
    		ProcedureReturn
    	EndIf
    	;
			; Verzeichnis Anlegen
    	Select FileSize(Startup::*LHGameDB\FolderWWW)
    		Case -1: CreateDirectory( Startup::*LHGameDB\FolderWWW )                    
    	EndSelect 
    	
    	If Not ( Result = 1 )
    		SetGadgetText(DC::#Text_001,"Receive: " + UserFile)
    		SetGadgetText(DC::#Text_002,"Local  : " + Startup::*LHGameDB\FolderWWW)
    		SetGadgetText(DC::#Text_003, ".. Get Filesize ..")	
    		
    		Protected Head.s	= "sptth"
    		Protected FileSize.q = FFH::HTTP_GetContentLength( ReverseString( Head ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) + UserFile + ReverseString( "piz." ) )	    
    		
    		If FileSize( Startup::*LHGameDB\FolderWWW + UserFile + ReverseString( "piz." ) ) = FileSize
    			
    			SetGadgetText(DC::#Text_003, ".. File Exists ..")	    	
    			Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Backup", #CRLF$ + "Backup '"+ UserFile +"' existiert bereits in dem Verzeichnis:" + #CRLF$ + #CRLF$ + Startup::*LHGameDB\FolderWWW ,2,1,ProgramFilename(),0,0,DC::#_Window_001 )      
    			Delay(500)
    			MAME_Roms_Backup(UserFile)	
    			ProcedureReturn
    		EndIf
    		
    		If FileSize = 0
    			
    			SetGadgetText(DC::#Text_003, ".. File Not Found ..")
    			Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Backup", #CRLF$ + "Backup '"+ UserFile +"' konnte nicht erreicht werden." ,2,1,ProgramFilename(),0,0,DC::#_Window_001 ) 
    			Delay(500)
    			MAME_Roms_Backup(UserFile)	        	
    			ProcedureReturn
    		EndIf	    
    		
    		
    		SetGadgetText(DC::#Text_001,"Remote : " + UserFile + " ("+ MathBytes::FileSizeFormat( FileSize )+ ")")
    		SetGadgetText(DC::#Text_002,"Local  : " + Startup::*LHGameDB\FolderWWW)	    
    		
    		
    		*Params.HTTP_INDEX = AllocateMemory(SizeOf(HTTP_INDEX))
    		InitializeStructure(*Params, HTTP_INDEX)                
    		
    		
    		*Params\File = Startup::*LHGameDB\FolderWWW +  UserFile + ReverseString( "piz." )
    		*Params\Size = FileSize
    		*Params\Urls = ReverseString( Head ) + ":" + ReverseString( Startup::*LHGameDB\aUseless ) +  Request::*MsgEx\Return_String + ReverseString( "piz.")        
    		
    		Protected HTTP_Thread = CreateThread(@Thread_HTTP_MAME_Roms(),*Params)  
    		ThreadPriority(HTTP_Thread, 31) 
    		
    		While IsThread(HTTP_Thread)		                           
    			While WindowEvent()                                    
    			Wend
    		Wend
    		
    		Delay(150)
    		If Not Filesize = FileSize( *Params\File )
    			Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Fehler beim Sichern der Datei. Größe ist unterschiedlich." + #CRLF$ + "Local: " + MathBytes::FileSizeFormat( FileSize( *Params\File ) ) + #CRLF$ + "Remote: " + MathBytes::FileSizeFormat(Filesize)  ,2,2,"",0,0,DC::#_Window_001)
    		EndIf
    		
    		SetGadgetText(DC::#Text_001,"Received: " + UserFile + " ("+ MathBytes::FileSizeFormat( FileSize )+ ")")			            	
    		SetGadgetText(DC::#Text_002,"Local   : " + Startup::*LHGameDB\FolderWWW)	  
    		SetGadgetText(DC::#Text_003, "...")                    		
    		
    		Request::*MsgEx\User_BtnTextL = "Ok"
    		Request::*MsgEx\User_BtnTextR = "Öffnen"			
    		Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E Backup", #CRLF$ + "Backup '"+ UserFile +"' heruntergeladen." + #CRLF$ + #CRLF$ +"Zielverzeichnis: '" + Startup::*LHGameDB\FolderWWW + "' (Öffnen?)" ,10,-1,ProgramFilename(),0,0,DC::#_Window_001 )    
    		Delay(150)
    		If Result = 1 
    			FFH::ShellExec(Startup::*LHGameDB\FolderWWW, "explore")
    		EndIf
    		
    	EndIf
    	MAME_End_Procedure()
    	Thread_LoadGameList_Action()
    	ProcedureReturn         
  EndProcedure   
	;
	;
	;	    
  Procedure.i 	MAME_Roms_GetInfos_System(SuchString.s, CodeFile.s, Stringline.s, sDebug.i, *Params.MAME_SOURCECODE_INFO, List DIL.DATABASE_INDEX_LIST())
    	        		
    	If FindString( Stringline, SuchString , 1, #PB_String_CaseSensitive )    		    		    	    			    		
    		EnumKommas = 11; CountString(Stringline, Chr(44) )
    		
    		For i = 1 To EnumKommas
    			
    			Celle.s = StringField(Stringline, i, Chr(44) )
    			
    			If ( Celle = " 0 )" )
    				ProcedureReturn #True
    			EndIf	
    			Select i
    				Case 1	; YEAR
    					strYear.s = Trim( ReplaceString( Celle, SuchString, ""), Chr(32) )
    					AddElement( *Params\MSIP() )
    					;
							;
							; Kommentar String //
							;
    					If FindString( strYear, "//")
    						;
								; Entferne Kommentar
    						strYear = ReplaceString( strYear, "//", "")    						
    					EndIf	
    					If FindString( strYear, "year",0,#PB_String_CaseSensitive)
    						;
								; Korrigiere Fake Jahr    						
    						strYear = ReplaceString( strYear, "year", "1900")
    						strYear = Trim( strYear, Chr(9) )
    					EndIf
    					If ( Right( strYear, 1) = "?" )
    						strYear = Left(strYear, 4)
    					EndIf
    					
    					If FindString( strYear, "?")
    						;
								; Korrigiere -soweit- Jahr      					
    						strYear = ReplaceString( strYear, "?", "0",0,0, CountString( strYear, "?")+1 )
    					EndIf    					
    					strYear = Trim( strYear, Chr(32) )
    					;
							; Existiert '?'
    					If Len( strYear ) >= 5    					
    							For nYear = 1948 To 2030
    								If FindString( strYear, Str(nYear),1)
    									strYear = Str(nYear)
    									Break
    								EndIf
    								; Debug CodeFile + ": '" + strYear + "'"
    							Next    						
    					EndIf
    					
    					*Params\MSIP()\SOURCECODE = CodeFile
    					*Params\MSIP()\YEAR = strYear
    					
    				Case 2	; NAME (*) Rom Name in Medie String
    					strNAME.s = Trim( Celle, Chr(32) )
    					*Params\MSIP()\NAME = strNAME
    					
    				Case 3	; PARENT
    					strPARENT.s = Trim( Celle, Chr(32) )
    					*Params\MSIP()\PARENT = strPARENT
    					
    				Case 4	; COMPAT
    					strCOMPAT.s = Trim( Celle, Chr(32) )
    					*Params\MSIP()\COMPAT = strCOMPAT    					
    					
    				Case 5	; MACHINE
    					strMACHINE.s = Trim( Celle, Chr(32) ) 						
    					*Params\MSIP()\MACHINE = strMACHINE
    					
    				Case 6	; INPUT
    					strINPUT.s = Trim( Celle, Chr(32) )
    					*Params\MSIP()\INPUT = strINPUT
    					
    				Case 7	; CLASS
    					strCLASS.s = Trim( Celle, Chr(32) )
    					*Params\MSIP()\CLASS = strCLASS
    					
    				Case 8	; INIT
    					strINIT.s = Trim( Celle, Chr(32) )
    					*Params\MSIP()\INIT = strINIT        					
    				Case 9	; COMPANY
    					strCOMPANY.s = Celle
    					strCOMPANY   = Trim( strCOMPANY, Chr(32) ) 
    					
    					lPosQuote.i	 = 0
    					rPosQuote.i	 = 0
    					
    					lPosQuote	 = FindString( strCOMPANY, Chr(34) )
    					rPosQuote	 = FindString( strCOMPANY, Chr(34), lPosQuote+1)
    					
    					If ( lPosQuote > 0 ) And ( rPosQuote > 0 )
    						strCOMPANY   = RTrim( strCOMPANY, Chr(34) )
    						strCOMPANY   = LTrim( strCOMPANY, Chr(34) )
    						*Params\MSIP()\COMPANY = strCOMPANY      						
    						Continue
    					Else
    						;
								; Das abschliessende Ende Anführungszeichen nicht gefunden      							
    						tmpPos.i = FindString( Stringline, strCOMPANY, 0)
    						If ( tmpPos > 0 )    								    							
    							rPosQuote   = FindString( Stringline, Chr(34), tmpPos+1)
    							
    							strCOMPANY = Mid( Stringline, tmpPos , rPosQuote - tmpPos)
    							strCOMPANY = RTrim( strCOMPANY, Chr(34) )
    							strCOMPANY = LTrim( strCOMPANY, Chr(34) ) 
    							qResult.i  = CountString(strCOMPANY, Chr(44) )
    							Stringline = ReplaceString( Stringline, Chr(44), "",0,tmpPos,qResult)
    							i	      = 9 
    							*Params\MSIP()\COMPANY = strCOMPANY      							
    							Continue
    						EndIf    							  							
    					EndIf	
    					
    					
    				Case 10	; FULLNAME
    					strFULLNAME.s = Celle
    					strFULLNAME   = Trim( strFULLNAME, Chr(32) )  
    					
    					lPosQuote.i	 = 0
    					rPosQuote.i	 = 0
    					
    					lPosQuote	 = FindString( strFULLNAME, Chr(34) )
    					rPosQuote	 = FindString( strFULLNAME, Chr(34), lPosQuote+1)
    					
    					If ( lPosQuote > 0 ) And ( rPosQuote > 0 )
    						
    						strFULLNAME   = RTrim( strFULLNAME, Chr(34) )
    						strFULLNAME   = LTrim( strFULLNAME, Chr(34) )
    						*Params\MSIP()\FULLNAME = strFULLNAME 
    						Continue
    					Else    							
    						;
								; Das abschliessende Ende Anführungszeichen nicht gefunden    							
    						tmpPos.i = FindString( Stringline, strFULLNAME, 0)
    						If ( tmpPos > 0 )    								    							
    							rPosQuote   = FindString( Stringline, Chr(34), tmpPos+1)
    							
    							strFULLNAME = Mid( Stringline, tmpPos , rPosQuote - tmpPos)
    							strFULLNAME = RTrim( strFULLNAME, Chr(34) )
    							strFULLNAME = LTrim( strFULLNAME, Chr(34) )    								
    							qResult.i   = CountString(strFULLNAME, Chr(44) )
    							Stringline  = ReplaceString( Stringline, Chr(44), "",0,tmpPos,qResult)
    							i		  = 10
    							*Params\MSIP()\FULLNAME = strFULLNAME       							
    							Continue
    						EndIf						
    					EndIf
    					
    				Case 11	; FLAGS
    					strFLAGS.s = Celle 
    					; Weiviele und welche Flags
    					
    					Flags.i  = CountString(strFLAGS, Chr(124) )
    					
    					MACHINE_NOT_WORKING.i 			= #False
    					MACHINE_IS_INCOMPLETE.i 		= #False
    					
    					If FindString(strFLAGS,"MACHINE_NOT_WORKING",0,1)
    						MACHINE_NOT_WORKING = #True
    					EndIf    					
    					If FindString(strFLAGS,"MACHINE_IS_INCOMPLETE",0,1)
    						MACHINE_IS_INCOMPLETE = #True     						
    					EndIf
    					
    					If (MACHINE_NOT_WORKING = #True) Or(MACHINE_IS_INCOMPLETE = #True)
    						
    						AddElement( *Params\MSIP()\MSIF() )
    						If ( MACHINE_NOT_WORKING	= #True )
    							*Params\MSIP()\MSIF()\MACHINE_NOT_WORKING = #True
    						EndIf
    						If ( MACHINE_IS_INCOMPLETE	= #True )
    							*Params\MSIP()\MSIF()\MACHINE_IS_INCOMPLETE = #True
    						EndIf
    						
    						
    					EndIf
    			EndSelect
    			
    			If ( sDebug )
    				Debug "YEAR	: " + strYear + #CRLF$ +
    				      " NAME  	: " + strNAME +#CRLF$ +
    				      " PARENT	: " + strPARENT +#CRLF$ +
    				      " COMPAT	: " + strCOMPAT +#CRLF$ +
    				      " MACHINE	: " + strMACHINE +#CRLF$ +
    				      " INPUT	: " + strINPUT +#CRLF$ +
    				      " CLASS	: " + strCLASS + #CRLF$ +
    				      " INIT	: " + strINIT +#CRLF$ +
    				      " COMPANY	: " + strCOMPANY +#CRLF$ +
    				      " FULLNAME: " + strFULLNAME +#CRLF$ +
    				      " FLAGS	: " + strFLAGS + #CRLF$	    				    			
    			EndIf    			
    			;
					;
					; Nur das Aktuelle Rom Wurde gefunden
    			If ( DIL()\RomFile = strNAME) And ( *Params\SingleElement = #True ) And (DIL()\SingleFound = #False)
    				DIL()\SingleFound = #True
    				ProcedureReturn #True
    			EndIf	    		
    			;SetGadgetText(DC::#Text_004,"M.A.M.E.: Sammle Information " + strFULLNAME)
					;Thread_HTTP_MAME_Roms_DoEvents() 
    		Next  
    		ProcedureReturn #True
    	EndIf    		        			    	    
    	ProcedureReturn #False
    	
    	; CONS(YEAR, NAME, PARENT, COMPAT, MACHINE, INPUT, CLASS, INIT, COMPANY, FULLNAME, FLAGS)
  EndProcedure	
  ;
	;
	;	    
  Procedure 		MAME_Roms_GetInfos_FileThread(*Params.MAME_SOURCECODE_INFO)
    	    	
    	FileListSize.i =  ListSize( *Params\MSIC() )-1
    	
    	
    		While NextElement(*Params\MSIC())    			   			    			
    			
    			If ( FindString( *Params\MSIC()\FullFilePath, "_v.cpp") )
    				FileListSize - 1
    				Continue
    			EndIf
    			If ( FindString( *Params\MSIC()\FullFilePath, "_m.cpp") )
    				FileListSize - 1
    				Continue
    			EndIf
    			If ( FindString(*Params\MSIC()\FullFilePath, "_copro.cpp") )
    				FileListSize - 1
    				Continue
    			EndIf 
    			If ( FindString( *Params\MSIC()\FullFilePath, "_kbd.cpp") )
    				FileListSize - 1
    				Continue
    			EndIf
    			If ( FindString( *Params\MSIC()\FullFilePath, "_dbg.cpp") )
    				FileListSize - 1
    				Continue
    			EndIf
    			If ( FindString( *Params\MSIC()\FullFilePath, "_tape.cpp") )
    				FileListSize - 1
    				Continue
    			EndIf     			
    			If ( FindString( *Params\MSIC()\FullFilePath, "\layout\") )
    				FileListSize - 1
    				Continue
    			EndIf   			
    			If ( FindString( *Params\MSIC()\FullFilePath, "\shared\") )
    				FileListSize - 1
    				Continue
    			EndIf     			
    			
    			SourceFileHandle.l = ReadFile(#PB_Any, *Params\MSIC()\FullFilePath)
    			SetGadgetText(DC::#Text_004,"M.A.M.E.: Durchsuche " + "("+ RSet( Str(FileListSize ),4, "#") + ") Datei(en) " + GetFilePart(*Params\MSIC()\FullFilePath) )
    			;Thread_HTTP_MAME_Roms_DoEvents() 	
    			
    			If ( SourceFileHandle >= 0 )
    			
	    			While Eof(SourceFileHandle) = 0
	    				
	    				If ( DIL()\SingleFound = #True And DIL()\Single = #True )
	    					Break;
	    				EndIf
	    				StrRead.s   = ReadString(SourceFileHandle)
	    				StrLine.s	= StrRead
	    				If ( Len(StrLine) > 0 )
	    						    					
		    				If ( MAME_Roms_GetInfos_System("CONS(", *Params\MSIC()\FullFilePath, StrLine, #False,*Params, DIL()) = #True )
		    					*Params\MSIP()\PLATFORM = "Konsole"
		    					Continue
		    					
		    				ElseIf ( MAME_Roms_GetInfos_System("GAME(", *Params\MSIC()\FullFilePath, StrLine, #False,*Params, DIL()) = #True )
		    					*Params\MSIP()\PLATFORM = "Arcade"
		    					Continue
		    					
		    				ElseIf  ( MAME_Roms_GetInfos_System("COMP(", *Params\MSIC()\FullFilePath, StrLine, #False,*Params, DIL()) = #True)
		    					*Params\MSIP()\PLATFORM = "Computer"	    					
		    					Continue
		    					
		    				ElseIf ( MAME_Roms_GetInfos_System("SYST(", *Params\MSIC()\FullFilePath, StrLine, #False,*Params, DIL()) = #True)
		    					*Params\MSIP()\PLATFORM = "SoundSystem"
		    					Continue
		    				EndIf
		    				
						EndIf
	    			Wend	    		     		 	    		 
	    		EndIf	
	    		FileListSize - 1
	    		CloseFile( SourceFileHandle )	    			    		
	    		
	    		If ( DIL()\SingleFound = #True And DIL()\Single = #True )
	    			Break
	    		EndIf	    		
	    	Wend
	    	
	EndProcedure	
  ;
	;
	;	    
	Procedure 		MAME_Roms_GetInfos_UpdateThread(*Params.MAME_SOURCECODE_INFO)
		
		;
		;
		; Informationen Setzen			
		ResetList( DIL() )
		While NextElement( DIL() )	
			
			ResetList( *Params\MSIP() )
			While NextElement(  *Params\MSIP() )
				
				If ( UCase(DIL()\RomFile) = UCase(*Params\MSIP()\NAME) )
															
					Debug *Params\MSIP()\NAME
					Debug *Params\MSIP()\YEAR
					Debug *Params\MSIP()\SOURCECODE
					Debug *Params\MSIP()\PLATFORM
					ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Release", *Params\MSIP()\YEAR, DIL()\Index)

					SetGadgetText(DC::#Text_004,"M.A.M.E.: Update " + *Params\MSIP()\NAME)    				
    			ResetList( *Params\MSIP()\MSIF() )
					While NextElement(  *Params\MSIP()\MSIF() )	
						
						If ( *Params\MSIP()\MSIF()\MACHINE_IS_INCOMPLETE = #True )
							*Params\MSIP()\PLATFORM = "Incomplete"
							Debug *Params\MSIP()\PLATFORM
						EndIf						
						If ( *Params\MSIP()\MSIF()\MACHINE_NOT_WORKING = #True )
							*Params\MSIP()\PLATFORM = "Not Working"
							Debug *Params\MSIP()\PLATFORM
						EndIf												
					Wend				         
					
					PlatformFound.i = #False
					For RowID = 1 To ExecSQL::CountRows(DC::#Database_001,"Platform")
						
						PlatformID.i = ExecSQL::iRow(DC::#Database_001,"Platform","id",0,RowID,"",1)
						PlatformST.s = ExecSQL::nRow(DC::#Database_001,"Platform","Platform","",RowID,"",1)
						
						If  ( UCase( *Params\MSIP()\PLATFORM ) = UCase( PlatformST ) )	            			
							PlatformFound = #True
							ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "PlatformID", Str(PlatformID), DIL()\Index)
							Break
						EndIf	                    		                    	
					Next RowID 
										
					; Nicht Gefunden -> Füge die Region der Liste hinzu und dem Aktuellen Titel
					If ( PlatformFound = #False )																							
						ExecSQL::InsertRow(DC::#Database_001,"Platform", "Platform", *Params\MSIP()\PLATFORM)
						ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "PlatformID", Str(ExecSQL::LastRowID(DC::#Database_001,"Platform")), DIL()\Index)
					EndIf	                
					Break
				EndIf
			Wend
		Wend		
    EndProcedure	
	;
	;
	;
  Procedure 		Mame_Roms_GetInfos_Thread(CurrentThread.i)
    	
    	  				
    		WM_MsgID.i = WindowEvent()	: Debug "(Hex) $" + RSet( Hex(WM_MsgID),6,"0") + " / Dec: " +Str(WM_MsgID)
    		Select WM_MsgID
    			Case #WM_KEYDOWN
    			Case #WM_KEYUP    						
    			Case #WM_CHAR
    				
    				If IsThread( CurrentThread ) And ( EventwParam() = 27 ) ; 27 = Taste ESC
    					PauseThread( CurrentThread )
    					
    					Delay( 1000 )
    					
    					Request::*MsgEx\User_BtnTextL = "Weiter"
    					Request::*MsgEx\User_BtnTextR = "Abbruch"			
    					Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "Operation Abbrechen?", "Import von Infos abbrechen" ,10,-1,ProgramFilename(),0,0,DC::#_Window_001 )
    					
    					If ( Result = 1 )
    						HideGadget(DC::#Text_004,1)
    						SetGadgetText(DC::#Text_004,"")				
    						MAME_End_Procedure()
    						ProcedureReturn #False
    					Else
    						ResumeThread( CurrentThread )
    						ProcedureReturn #True
    					EndIf		    									
    				EndIf    						
    		EndSelect
    	ProcedureReturn #True
  EndProcedure
	;
	;
	;    
  Procedure 	 	MAME_Roms_GetInfos()
    	
    	
    	vSys_MainButtonsConfig()
    	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")    	      
    	
    	Request::*MsgEx\User_BtnTextL = "Gewählt"
    	Request::*MsgEx\User_BtnTextR = "Abbruch"
    	Request::*MsgEx\User_BtnTextM = "Alle"         
    	Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E", "Datanbank mit Infos füllen?" + #CRLF$ + #CRLF$ + "Dafür wird der Quelle Code von Mame benötigt. Diesen entpacken und das verzeichnis wählen." + #CRLF$ + "Es werden nur die Rom Namen im ersten Media Platzhalter abgefragt."+ #CRLF$ + #CRLF$ + "Nur den aktuellen gewählten Eintrag oder alle aktualisieren?",16,-1,ProgramFilename(),0,0,DC::#_Window_001 )
    	If ( Result = 1 ) 
    		MAME_End_Procedure()
    		ProcedureReturn 
    	EndIf    	
    	
    	HideGadget(DC::#ListIcon_001,1)           
    	HideGadget(DC::#Text_003,0)
    	
    	Intro$ = "[ .. M.A.M.E. .. ]"         
    	SetGadgetColor(DC::#Text_003, #PB_Gadget_BackColor, RGB(61,61,61)):SetGadgetText(DC::#Text_003,"[ ]"): Delay(85): Thread_LoadGameList_Anim(10, DC::#Text_003): SetGadgetText(DC::#Text_003,Intro$)
    	
    	
    	*Params.MAME_SOURCECODE_INFO = AllocateMemory(SizeOf(MAME_SOURCECODE_INFO))
    	InitializeStructure(*Params, MAME_SOURCECODE_INFO)
    	
    	SizeList = CountGadgetItems(DC::#ListIcon_001)
    	
    	;
			;Single Titel
			;         
    	*Params\SingleElement = #False
    	
    	If (Result = 0)
    		*Params\SingleElement = #True
    	EndIf
    	
    	HideGadget(DC::#Text_004,0)
    	SetGadgetText(DC::#Text_004,"")
    	
    	If ( *Params\SingleElement = #False )
    		For i = 0 To SizeList - 1
    			
    			DataIndexID.i = GetGadgetItemData(DC::#ListIcon_001, i)
    			RomName.s     = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",DataIndexID,"",1)
    			If ( Len( RomName ) > 0)
    				;
						;
						; Liste mit IDs die inder Datenbank sind     		
    				
    				AddElement( DIL() )
    				DIL()\Index = DataIndexID
    				DIL()\RomFile = RomName    		
    				DIL()\Section = "MediaDev0" 
    				DIL()\Single  = #False
    				DIL()\SingleFound = #False
    				Debug "ID Index       : " + RSet( Str( DataIndexID ),3,"0") + " >> Mediafile: " + RomName    			
    				SetGadgetText(DC::#Text_004,"M.A.M.E.: Hole Infos über " + RomName)
    				SetGadgetText(DC::#Text_003,".. Get Infos ..")
    			Else
    				;
						; KEIN ROM - ERROR
						; 
    			EndIf	
    			Thread_HTTP_MAME_Roms_DoEvents() 
    		Next
    	Else
    		RomName.s     = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",Startup::*LHGameDB\GameID,"",1)
    		If ( Len( RomName ) > 0)
    			AddElement( DIL() )
    			DIL()\Index = Startup::*LHGameDB\GameID
    			DIL()\RomFile = RomName    		
    			DIL()\Section = "MediaDev0"  
    			DIL()\Single  = #True
    			DIL()\SingleFound = #False
    			Debug "ID Index       : " + RSet( Str( Startup::*LHGameDB\GameID ),3,"0") + " >> Mediafile: " + RomName
    			SetGadgetText(DC::#Text_004,"M.A.M.E.: Hole Infos über " + RomName)
    			SetGadgetText(DC::#Text_003,".. Get Infos ..")	    				
    		Else
    			;
					; KEIN ROM - ERROR
					; 
    		EndIf
    		
    		
    	EndIf
    	
    	SetGadgetText(DC::#Text_003,"")
    	
    	
    	ResetList( DIL() )
    	If ( ListSize( DIL() ) = 0 )
    		Request::MSG(Startup::*LHGameDB\TitleVersion, "Ausgeführt!" , "Keine Titel in der Datenbank gefunden" ,2,0,"",0,0,DC::#_Window_001)
    		HideGadget(DC::#Text_004,1)
    		SetGadgetText(DC::#Text_004,"")				
    		MAME_End_Procedure()
    		ProcedureReturn
    	EndIf 
    	
    	
    	Directory.s = FFH::GetPathPBRQ("Quelle Code Verzeichnis Auswählen",Startup::*LHGameDB\FolderMameSource)
    	If ( Len( Directory ) = 0 )
    		HideGadget(DC::#Text_004,1)
    		SetGadgetText(DC::#Text_004,"")				
    		MAME_End_Procedure()
    		ProcedureReturn
    	EndIf 
    	
    	;
			; 
			; Verzeichnis des Source Codes
    	MameCodeDirectory.s = Directory;"B:\MSYS2_MAME\src\Mame\"

    	If FileSize(MameCodeDirectory + "access\acvirus.cpp" )  = -1 
    		Startup::*LHGameDB\FolderMameSource = MameCodeDirectory + "src\mame\"
    	EndIf
    	
    	Debug Startup::*LHGameDB\FolderMameSource   	

    	;
			;
			; Informationen Bekommen
    	
    	;If ( *Params\SingleElement = #True )
    	ResetList( DIL() )
    	FirstElement( DIL() )	
    	;EndIf	
    	
    	If FileSize(Startup::*LHGameDB\FolderMameSource ) = -2
    		
    		SetGadgetText(DC::#Text_003,".. do Filelist ..")
    		SetGadgetText(DC::#Text_004,"M.A.M.E.: Dateien suche ...")
    		
    		FFS::DelContent()
    		
    		FFS::GetContent(Startup::*LHGameDB\FolderMameSource ,#True, #True, #True,"","*.cpp",0,#True,100,"")
    		FFS::SortContent()
    		SetGadgetText(DC::#Text_004,"")
    		ResetList(FFS::FullFileSource())
    		
    		While NextElement( FFS::FullFileSource() )    			
    			AddElement( *Params\MSIC() )
    			*Params\MSIC()\FullFilePath =  FFS::FullFileSource()\FileName
    			SetGadgetText(DC::#Text_003, ".. Collect: " + GetFilePart(*Params\MSIC()\FullFilePath))
    			Thread_HTTP_MAME_Roms_DoEvents() 	
    		Wend	
    		
    		FFS::DelContent()
    		Startup::*LHGameDB\Base_Shot = Startup::*LHGameDB\Base_Path + "Systeme\Shot\"
    		
    		If ( ListSize(  *Params\MSIC() ) = 0 )
    			Request::MSG(Startup::*LHGameDB\TitleVersion, "Ausgeführt!" , "Keine Dateien gefunden [" + Str( ListSize(  *Params\MSIC() )) + "]" + #CRLF$ + Startup::*LHGameDB\FolderMameSource  ,2,0,"",0,0,DC::#_Window_001)
    			HideGadget(DC::#Text_004,1)
    			SetGadgetText(DC::#Text_004,"")				
    			MAME_End_Procedure()
    			ProcedureReturn
    		EndIf    		
    		
    		Delay( 500 )
    		SetGadgetText(DC::#Text_003,".. Searching ..")
    		
    		ResetList(*Params\MSIC())
    		
    		Protected File_Thread = CreateThread(@MAME_Roms_GetInfos_FileThread(),*Params)  
    		ThreadPriority(File_Thread, 31) 
    		While IsThread(File_Thread)
    			
    			While WindowEvent()  
    				If ( Mame_Roms_GetInfos_Thread(File_Thread) =	#False )
    					KillThread(File_Thread)
    				EndIf
    			Wend	    			
    		Wend
    		
    		Delay( 500 )
    		
    	EndIf	
    	SetGadgetText(DC::#Text_003,"")
    	;
			;
			; Informationen Setzen	    
    	ResetList( *Params\MSIP() )
    	Delay( 500 )			
    	SetGadgetText(DC::#Text_003,".. Update List ..")
    	
    	File_Thread = CreateThread(@MAME_Roms_GetInfos_UpdateThread(),*Params)  
    	ThreadPriority(File_Thread, 31) 
    	
    	While IsThread(File_Thread)		                           
    		While WindowEvent()                                    
    		Wend
    	Wend
    	
    	Delay( 500 )	
    	
    	ResetList( *Params\MSIP() )
    	
    	If ( ListSize(  *Params\MSIP() ) = 0 )
    		Request::MSG(Startup::*LHGameDB\TitleVersion, "Ausgeführt!" , "Keine Übereinstimmungen gefunden" ,2,0,"",0,0,DC::#_Window_001)
    		HideGadget(DC::#Text_004,1)
    		SetGadgetText(DC::#Text_004,"")				
    		MAME_End_Procedure()
    		ProcedureReturn
    	EndIf  			
    	
    	If ( ListSize( DIL() ) > 0 )
    		ClearList( DIL() )
    	EndIf
    	
    	SetGadgetText(DC::#Text_003,"")
    	
    	ClearStructure( *Params, MAME_SOURCECODE_INFO )
    	
    	If ( *Params > 0 )
    		FreeMemory( *Params )
    	EndIf	
    	
    	HideGadget(DC::#Text_004,1)
    	SetGadgetText(DC::#Text_004,"")	
    	
    	ButtonEX::Disable(DC::#Button_001, false)            
    	ButtonEX::Disable(DC::#Button_002, false) 
    	ButtonEX::Disable(DC::#Button_287, false)
    	
    	VEngine::Thread_LoadGameList_Action()
    	vImages::Screens_Show()
    	
    	SetActiveWindow(DC::#_Window_001)
    	SetActiveGadget(DC::#ListIcon_001)           
    	
    	ListBox_GetData_LeftMouse(#True)           
    	
    	Delay(150)
    	
    	Request::MSG(Startup::*LHGameDB\TitleVersion, "Ausgeführt!" , "Titel wurden mit Platform und Jahr aktualisiert" ,2,0,"",0,0,DC::#_Window_001)
    	
    	SetActiveWindow(DC::#_Window_001)
    	SetActiveGadget(DC::#ListIcon_001)
    	
    EndProcedure
  ;
	;
	;
  Procedure 		MAME_Driver_Info_wwwAI()
  	
  	Protected RomName.s
  	
			vSys_MainButtonsConfig()
    	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")    	          	 	
    	
    	HideGadget(DC::#ListIcon_001,1)           
    	HideGadget(DC::#Text_003,0)
    	
    	SetActiveGadget(-1) 
    	
    	Intro$ = "[ .. M.A.M.E. .. ]"         
    	SetGadgetColor(DC::#Text_003, #PB_Gadget_BackColor, RGB(61,61,61)):SetGadgetText(DC::#Text_003,"[ ]"): Delay(85): Thread_LoadGameList_Anim(10, DC::#Text_003): SetGadgetText(DC::#Text_003,Intro$)
    	    	    	    	
    	SizeList = CountGadgetItems(DC::#ListIcon_001)
    	
    	;
			;Single Titel
			;             	
    	If ( SizeList > 0 )
    			
    		RomName = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev0","",Startup::*LHGameDB\GameID,"",1)
    		If ( Len( RomName ) > 0)    		
    		Else
    			;
					; KEIN ROM - ERROR
					; 
    			RomName = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev1","",Startup::*LHGameDB\GameID,"",1)
	    		If ( Len( RomName ) > 0)    		
	    		Else
	    			;
						; KEIN ROM - ERROR
						; 
	    			RomName = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev2","",Startup::*LHGameDB\GameID,"",1)
		    		If ( Len( RomName ) > 0)    		
		    		Else
		    			;
							; KEIN ROM - ERROR
							; 
		    			RomName = ExecSQL::nRow(DC::#Database_001,"Gamebase","MediaDev3","",Startup::*LHGameDB\GameID,"",1)
		    		EndIf	    			
	    		EndIf    			
    		EndIf
    		    		
    	EndIf
    	
    	Request::*MsgEx\Return_String = RomName
    	Request::*MsgEx\User_BtnTextL = "Aufrufen"
    	Request::*MsgEx\User_BtnTextR = "Abbruch"
    	Request::*MsgEx\User_BtnTextM = "Download"       
    	Result = Request::MSG(Startup::*LHGameDB\TitleVersion,  "M.A.M.E. Information", #CRLF$ + "Rom/ Driver/ Device Information von Arcade Italia Database beziehen?" ,16,-1,ProgramFilename(),0,1,DC::#_Window_001 )        
    	  	    	
    	If ( Result = 2 )
    		MAME_Roms_Backup(Request::*MsgEx\Return_String)
    		ProcedureReturn 
    	EndIf
    	
    	If ( Result = 0 )   And ( Len(Request::*MsgEx\Return_String) > 0 )   		
    		
    	 szAsk.s = "=eman_emag?php.emam_oilgatted/ten.ailatiedacra.bda//:ptth"
    	 szAsk   = ReverseString(szAsk) + Request::*MsgEx\Return_String
    	 RunProgram( szAsk) 
 		    		
    	EndIf	
    	SetGadgetText(DC::#Text_001,"")
    	SetGadgetText(DC::#Text_002,"")     	
    	SetGadgetText(DC::#Text_003,"")
    	HideGadget(DC::#Text_004,1)
    	SetGadgetText(DC::#Text_004,"")	
    	
    	MAME_End_Procedure()
    	
    	ButtonEX::Disable(DC::#Button_001, false)            
    	ButtonEX::Disable(DC::#Button_002, false) 
    	ButtonEX::Disable(DC::#Button_287, false)
    	
    	SetActiveWindow(DC::#_Window_001)
    	SetActiveGadget(DC::#ListIcon_001)           
    	
    	ListBox_GetData_LeftMouse(#True)  
    	
    	SetActiveWindow(DC::#_Window_001)
    	SetActiveGadget(DC::#ListIcon_001)
    	
  EndProcedure  
EndModule    




; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 4256
; FirstLine = 4172
; Folding = 8--------8--fzT++
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\Adult The Klub\
; Debugger = IDE
; Warnings = Display
; EnablePurifier
; EnableUnicode