DeclareModule VEngine
       
    Declare     Thread_LoadGameList_Action()
    Declare     Thread_LoadGameList(t)
    Declare     Thread_LoadGameList_Sort(Save.i = -1)
    
    Declare     ListBox_GetData_LeftMouse(ForceUpdate = #False)
    Declare     ListBox_GetData_KeyBoard(KeyPressed.i)
    
    Declare     DataBase_Add()    
    Declare     Database_Get(RowID)
    Declare     Database_Set_Title(Str$)
    Declare     Database_Remove()
    Declare     Database_Set_Release()
    Declare     DataBase_Duplicate() 
    Declare     Update_Changes()    
    
    Declare     GadObjects_ClrRve_MediaOnly()
    
    Declare     GetFile_Media       (DPGadgetID.i, FileStream.s = "")
    Declare     GetFile_Programm    (DPGadgetID.i, FileStream.s = "") 
    Declare     GetFile_Programm_64 (DPGadgetID.i, FileStream.s = "")    
    
    
    Declare     Change_Title(GadgetID.i)
      
    Declare     Switcher_Pres_NoItems()
    Declare     Switcher_Pres_List(Obj.i)    
    
    Declare     Splitter_SetGet(Get = #True, Height = 289)  
    Declare     Splitter_SetAll()
       
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
    
    Declare      Thumbnails_SetAll()
    Declare      Thumbnails_Set(nSize.i)

    

    
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
    EndStructure    
    
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
        
        Protected Char.i, AsciiPos.i, Result.i = #False
        
        ;For  AsciiPos = 1 To Len(TestString$)           
            
        Char = Asc(Right(TestString$,1))                             
        Debug "Ascii : " + Chr(Char) + " AsciiPos:" + Str(Len(TestString$))
        
        Select Char
            Case 48 To 57
                Result = #True                                                                                 
            Default  
               TestString$ = ReplaceString(TestString$,Chr(Char),"",0,Len(TestString$),1)                            
        EndSelect       
        
        Select Result
            Case #True
                
                Select Len(TestString$)
                    Case 5
                        TestString$ = ReplaceString(TestString$,Chr(Char),"/"+Chr(Char),0,5,1)
                    Case 8   
                        TestString$ = ReplaceString(TestString$,Chr(Char),"/"+Chr(Char),0,8,1)                        
                    Default                            
                EndSelect       
                
                ;Break
                
            Default
        EndSelect
        ;Next    
        SetGadgetText(DC::#String_005,TestString$)
        SendMessage_(GadgetID(DC::#String_005), #EM_SETSEL, Len(TestString$), Len(TestString$))         
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
              Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Routine Finished")        
              
          EndIf    
     EndProcedure      
    ;****************************************************************************************************************************************************************
    ;
    ;****************************************************************************************************************************************************************    
     Procedure Database_Remove()
         
        Protected RemoveID.i,  Liste.i =  DC::#ListIcon_001, MaxItems.i, CurrentPosition, Result.i, *LEER
        
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
        
        Result = vItemTool::DialogRequest_Def(Startup::*LHGameDB\TitleVersion,"Soll der Eintrag " + GetGadgetItemText(Liste,GetGadgetState(Liste)) + " gelöscht werden")
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
            
            
            ExecSQL::DeleteRow(DC::#Database_001,"Gamebase",RemoveID)                          
            ExecSQL::DeleteRow(DC::#Database_002,"GameShot",RemoveID,"BaseGameID")              
            ExecSQL::UpdateRow(DC::#Database_001,"Settings", "GameID", Str(Startup::*LHGameDB\GameID),1) 
            
            If ( CountGadgetItems(Liste) = 0 )
                Thread_LoadGameList_Action()
            Else    
                Database_Get(Startup::*LHGameDB\GameID)
            EndIf 
            vImages::Screens_Show()
           
        EndIf
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
                          
             AddGadgetItem(LstObject,-1,GameTitle1$ + Chr(10) + Pltform$ + Chr(10) + Lnguage$ + Chr(10) +PrgDesc$): SetGadgetItemData(LstObject,RowID ,ExecSQL::_IOSQL()\nRowID)                         
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
                ;
                ;
                ; Liste Einträge Auf
                Thread_LoadGameList_GetItems(Rows.i)                
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
                
                LVSORTEX::ListIconSortSetCol(DC::#ListIcon_001,Startup::*LHGameDB\SortMode)          
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
        Protected TestFile$, TestPath$, TestSize.i,Title$,Char$, Endung$
        
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
                        Endung$   + GetFilePart(TestPath$,1) + "|"+ GetFilePart(TestPath$,1) +"."+ GetExtensionPart( TestPath$ ) +"|"
                    EndIf 
                    
                    ; Generate Suffix
                    ;
                    Endung$ + "Script (*.bat)|*.bat|"                     
                    Endung$ + "Programm (*.exe)|*.exe|"
                    Endung$ + "IconLink (*.lnk)|*.lnk|"                     
                    Endung$ + "Java App (*.jar)|*.jar;"
                    
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
        
        Protected stdout.s
        
            If AvailableProgramOutput( Startup::*LHGameDB\Thread_ProcessLow ) 
                
                *Params\Logging + ReadProgramString( Startup::*LHGameDB\Thread_ProcessLow ,#PB_UTF8) + #CR$
                Debug #TAB$ + "Loggin: " + *Params\Logging                
                
                If IsProgram( Startup::*LHGameDB\Thread_ProcessLow )
                    stdout = ReadProgramError( Startup::*LHGameDB\Thread_ProcessLow ,#PB_UTF8)
                
                    If ( Len( stdout)  > 0 )
                        *Params\StError + stdout
                        Debug #TAB$ + "StdOut: " + *Params\StError  
                    EndIf                    
                EndIf
            EndIf        
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Programm läuft,  While ProgramRunnin....
    ;________________________________________________________________________________________________________________________________________________________________                       
    Procedure.s DOS_Thread_PrgLoop(*Params.PROGRAM_BOOT, l_ProcID.l)
        
        Protected Mame_Window.i, DOS_NOP = 1, WindowState = #False, StdOutErrors$, FatalError_A$, FatalError_B$        

        Repeat
            
            ;WindowState = DOS_Thread_HideWindow(*Params\Program, l_ProcID, #SW_HIDE, WindowState)  
               
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
                
                If Startup::*LHGameDB\Settings_NoBorder = #True   
                    
                    If ( Startup::*LHGameDB\Settings_NoBoTime >= 1)
                        Delay(Startup::*LHGameDB\Settings_NoBoTime)
                        ;
                        ; Nur für den Start
                        Startup::*LHGameDB\Settings_NoBoTime = 0
                    EndIf    
                    
                    vSystem::System_NoBorder(*Params\Program)                                  
                EndIf                
                
                If Startup::*LHGameDB\Settings_FreeMemE = #True            
                   vSystem::System_MemoryFree(*Params\Program) 
                   ; TODO
                   ; Schwellenwert angabe                 
                EndIf   
                
                
                If ( vSystem::System_GetCurrentMemoryUsage() > 10485760 )               
                    ProcessEX::LHFreeMem()
                EndIf
                
                If (Startup::*LHGameDB\Settings_bNoOutPt = #False)
                    CreateThread(@DOS_Thread_OutPut(),*Params)     
                EndIf    
                
                If Not (ProgramRunning(l_ProcID))
                    DOS_NOP = 0
                EndIf 
                
                If ( vSystem::System_ProgrammIsAlive(*Params\Program) = #False )            
                    DOS_NOP = 0
                EndIf    
            Delay(25)
        Until DOS_NOP = 0    
        
        Delay(1)
        
        If (Startup::*LHGameDB\Settings_bNoOutPt = #False)
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
    Procedure.l DOS_Thread_CreatProcess(DOS_PatH.s,DOS_ExeC.s,DOS_CliC.s)
        
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
        
        If ( Startup::*LHGameDB\Settings_Asyncron = #True )
            
            Debug ""
            Debug "Programm Load: Async "
            Debug "Path         : " + DOS_PatH$
            Debug "Exec         : " + DOS_ExeC$ 
            Debug "Command      : " + DOS_CliC$           
            l_ProcID = DOS_Thread_CreatProcess(DOS_PatH$,DOS_ExeC$,DOS_CliC$) 
             Startup::*LHGameDB\Thread_ProcessLow = l_ProcID
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
        
       
        
        If ( l_ProcID.l = 0 ) Or ( Startup::*LHGameDB\Settings_Asyncron = #True ) Or (IsProgram(l_ProcID) = 0)
            ProcedureReturn
        EndIf
        
       
            
        h_ProcID = OpenProcess_(#PROCESS_QUERY_INFORMATION, 0, ProgramID(l_ProcID))          
     

        DOS_Thread_PrgLoop(*Params.PROGRAM_BOOT, l_ProcID.l)    
                
        GetExitCodeProcess_(h_ProcID, @exitCodeH)
        GetExitCodeProcess_(l_ProcID, @exitCodeL)
        
        Startup::*LHGameDB\Thread_ProcessLow = l_ProcID
        
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@ExitCode Low : " + Str(exitCodeL) )         
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #@ExitCode High: " + Str(exitCodeH) ) 
        
        CloseProgram(l_ProcID)                
        
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
    Procedure.s DOS_Device_GetInternalFile(Device.s, Drive.i, CheckPrg.s)
        
        Protected InternalFile$, StringObject.i, Hold.i               
                 
                If IsWindow(DC::#_Window_005)           ; C64 File Manager
                   ; Select  Drive
                ;Case 1: 
                    InternalFile$ = GetGadgetText( DC::#String_100 )                           
                 ;       Case 2: InternalFile$ = GetGadgetText( DC::#String_108 )
                 ;       Case 3: InternalFile$ = GetGadgetText( DC::#String_109 )
                 ;       Case 4: InternalFile$ = GetGadgetText( DC::#String_110 )                                                        
                 ;   EndSelect                                                
                Else    
                    InternalFile$ = ExecSQL::nRow(DC::#Database_001,"Gamebase","FileDev"+Str(Drive-1),"",Startup::*LHGameDB\GameID,"",1):                    
                EndIf    
                
                If ( Len( InternalFile$ ) ! 0 )
                    If ( "HOXS64.EXE" = UCase( CheckPrg ) )
                        ProcedureReturn Device.s +Chr(34)+ " " +Chr(34)+ ":" + InternalFile$ 
                    Else    
                        ProcedureReturn Device.s + ":" +InternalFile$   
                    EndIf                 
                EndIf
                
        ProcedureReturn Device.s           
        
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
    ; Section Set Media Device
    ;****************************************************************************************************************************************************************    
    Procedure.s DOS_Device(Args.s, CheckPrg.s, sSlot.i = 0, FullPath.s = "")
        
        Protected s.s, Device1$, Device2$, Device3$, Device4$, DevPosition1 = -1, DevPosition2 = -1, DevPosition3 = -1, DevPosition4 = -1, CommandPos.i = -1, NoQuotes.i = -1, nq.s,  ArcSupport.i = -1
        
        Startup::*LHGameDB\Settings_NoBorder = #False
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
        Startup::*LHGameDB\Settings_bNoOutPt = #False;
        
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
        For  ArgIndex = 1 To Len(Args)       
            s.s = Mid(Args,ArgIndex,1)
            If ( s = "%" )
                
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%b" )
                    
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%bl" )
                        
                        s.s + Mid(Args,ArgIndex+3,1)
                        If ( s =  "%blo" )
                            
                            s.s + Mid(Args,ArgIndex+4,1)
                            If ( s =  "%bloc" )
                                
                                s.s + Mid(Args,ArgIndex+5,1)
                                If ( s =  "%block" )
                                    
                                    s.s + Mid(Args,ArgIndex+6,1)
                                    If ( s =  "%blockf" )
                                        
                                        s.s + Mid(Args,ArgIndex+7,1)
                                        If ( s =  "%blockfw" )
                                            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Block Firewall Net (Activ)")  
                                            Startup::*LHGameDB\Settings_bBlockFW = #True                        
                                            Args = DOS_TrimArg(Args.s, s)     
                                            Break;                        
                                        EndIf                                                                
                                    EndIf                                                            
                                EndIf                                                        
                            EndIf                                                    
                        EndIf                                                
                    EndIf                    
                EndIf                    
            EndIf    
        Next ArgIndex       
        
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
        ; Command: Lock Mouse in Window
            For  ArgIndex = 1 To Len(Args)            
                s.s = Mid(Args,ArgIndex,1)
                If ( s = "%" )
                    s.s + Mid(Args,ArgIndex+1,1)
                    If ( s =  "%l" )
                        s.s + Mid(Args,ArgIndex+2,1)
                        If ( s =  "%lc" )
                            s.s + Mid(Args,ArgIndex+3,1)
                            If ( s =  "%lck" )                        
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Mouse Lock (Activ)")                         
                                Startup::*LHGameDB\Settings_LokMouse = #True 
                                Args = DOS_TrimArg(Args.s, s) 
                            EndIf                            
                            Break;
                        EndIf    
                    EndIf
                EndIf            
            Next ArgIndex             
        
        ;
        ;
        ; Command: Minimize        
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%m" )
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Minimze (Activ)")                    
                    Startup::*LHGameDB\Settings_Minimize = #True
                    Args = DOS_TrimArg(Args.s, s) 
                EndIf    
            EndIf
        Next ArgIndex 
                  
        ;
        ;
        ; Command: Asyncron                
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%a" )
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Asyncron (Activ)")                         
                    Startup::*LHGameDB\Settings_Asyncron = #True
                    Args = DOS_TrimArg(Args.s, s) 
                EndIf    
            EndIf                                   
        Next ArgIndex 
        
        
        ;
        ;
        ; Command: NoQuotes                
        For  ArgIndex = 0 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%n" )
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%nq" )                    
                        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Dont Use Double Quotes (Activ)")      
                        NoQuotes = 1
                        Args = DOS_TrimArg(Args.s, s) 
                    EndIf
                EndIf    
            EndIf                                   
        Next ArgIndex   
        
        ;
        ;
        ; Command: Archive Support               
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%p" )
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%pk" )                    
                        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
                        ArcSupport = 1
                        Args = DOS_TrimArg(Args.s, s) 
                    EndIf
                EndIf    
            EndIf                                   
        Next ArgIndex   
        
        ;
        ;
        ; Block Programm in Firewall
        For  ArgIndex = 1 To Len(Args)       
            s.s = Mid(Args,ArgIndex,1)
            If ( s = "%" )
                
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%n" )
                    
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%no" )
                        
                        s.s + Mid(Args,ArgIndex+3,1)
                        If ( s =  "%noo" )
                            
                            s.s + Mid(Args,ArgIndex+4,1)
                            If ( s =  "%noou" )
                                
                                s.s + Mid(Args,ArgIndex+5,1)
                                If ( s =  "%noout" )                                                                      
                                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Disable Output (Activ)")  
                                     Startup::*LHGameDB\Settings_bNoOutPt = #True
                                    Args = DOS_TrimArg(Args.s, s)     
                                    Break;                                                                                   
                                EndIf                                                        
                            EndIf                                                    
                        EndIf                                                
                    EndIf                    
                EndIf                    
            EndIf    
        Next ArgIndex   
        
        ;
        ;
        ; Command: Hide, Unhide Taskbar 
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%t" )
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%tb" )                    
                        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
                        Startup::*LHGameDB\Settings_Taskbar = #True
                        Args = DOS_TrimArg(Args.s, s) 
                    EndIf
                EndIf    
            EndIf                                   
        Next ArgIndex  
        
        ;
        ;
        ; Command: Hide, Unhide Explorer 
        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%e" )
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%ex" )                    
                        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
                        Startup::*LHGameDB\Settings_Explorer = #True
                        Args = DOS_TrimArg(Args.s, s) 
                    EndIf
                EndIf    
            EndIf                                   
        Next ArgIndex        
        
        ;
        ;
        ; Command: Hide, Unhide Explorer 

        For  ArgIndex = 1 To Len(Args)
            
            s.s = Mid(Args,ArgIndex,1)                
            If ( s =  "%" )
                s.s + Mid(Args,ArgIndex+1,1)
                If ( s =  "%u" )
                    s.s + Mid(Args,ArgIndex+2,1)
                    If ( s =  "%ux" )                    
                        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Archive (Activ)")      
                        Startup::*LHGameDB\Settings_DwmUxsms = #True
                        Args = DOS_TrimArg(Args.s, s) 
                    EndIf
                EndIf    
            EndIf                                   
        Next ArgIndex          
        
        
        ;
        ;
        ; Command: Add Windows Compatibility
        ; Ich denke:
        ; als Commando .... %cwin98 %cWinXP
        
        sCmpArg$ = ""
        sCmpMod$ = ""
        sCmpEmu$ = ""
        
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
                            sCmpEmu$ = CompatibilityEmulation()\Emulation$
                            
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
                                
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Support for Compatibility Emulation (Activ)")
                                Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: Modus: "+Startup::*LHGameDB\Settings_sCmpArgs)                                  
                                Break
                            EndIf    
                                
                        Next                        
                        
                        UnuseModule Compatibility                                                 
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
               
                Device1$ = Getfile_Portbale_ModeOut(Device1$):  If ( ArcSupport  = 1 ): Device1$ = DOS_PKARC(Device1$, 1): EndIf :Device1$ = DOS_Device_GetInternalFile(Device1$, 1, CheckPrg): If (NoQuotes = -1 ): Device1$ = DOS_Device_VerifySpace(Device1$) :EndIf   
                Debug "Loaded Slot 1 Dir /File : " + Device1$
            EndIf
            
            If ( Len(Device2$) >= 1 )
                Device2$ = Getfile_Portbale_ModeOut(Device2$):  If ( ArcSupport  = 1 ): Device2$ = DOS_PKARC(Device2$, 2): EndIf :Device2$ = DOS_Device_GetInternalFile(Device2$, 2, CheckPrg):  If (NoQuotes = -1 ): Device2$ = DOS_Device_VerifySpace(Device2$) :EndIf              
                Debug "Loaded Slot 2 Dir /File : " + Device2$
            EndIf
            
            If ( Len(Device3$) >= 1 )
                Device3$ = Getfile_Portbale_ModeOut(Device3$):  If ( ArcSupport  = 1 ): Device3$ = DOS_PKARC(Device3$, 3): EndIf :Device3$ = DOS_Device_GetInternalFile(Device3$, 3, CheckPrg):  If (NoQuotes = -1 ): Device3$ = DOS_Device_VerifySpace(Device3$) :EndIf               
                Debug "Loaded Slot 3 Dir /File : " + Device3$
            EndIf
            
            If ( Len(Device4$) >= 1 )            
                Device4$ = Getfile_Portbale_ModeOut(Device4$):  If ( ArcSupport  = 1 ): Device4$ = DOS_PKARC(Device4$, 4): EndIf :Device4$ = DOS_Device_GetInternalFile(Device4$, 4, CheckPrg):  If (NoQuotes = -1 ): Device4$ = DOS_Device_VerifySpace(Device4$) :EndIf                 
                Debug "Loaded Slot 4 Dir /File : " + Device4$
            EndIf 
            
            Args = Trim(Args)
            
            SlotsToUse = CountString(Args,"%sc")    ; Universelles Argument, Kommando übergabe an das programm
            SlotsToUse + CountString(Args,"%s")        
             
            If ( SlotsToUse >= 1 )
                
                For SlotsIndex = 1 To SlotsToUse
                    
                   If ( SlotsIndex > SlotsToUse )
                        Break;
                    EndIf
                    
                    ArgLen = Len(Args)
                    For  ArgIndex = 1 To ArgLen
                        
                        
                        If ( DOS_Argv_GetSlotContent(Args, ArgIndex) = "%sc" )
                            
                            If     ( Len(Device1$) <> 0 )
                                
                                If ( Right(Device1$, 1) = Chr( 34 ) ) And ( Left(Device1$, 1) = Chr( 34 ) )
                                    Device1$ = Mid( Device1$, 2, Len(Device1$)-2 ) 
                                EndIf    
                                Args = ReplaceString(Args,"%sc", Device1$,0,ArgIndex,1): Device1$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue 
                                
                            ElseIf ( Len(Device2$) <> 0 )
                                If ( Right(Device2$, 1) = Chr( 34 ) ) And ( Left(Device2$, 1) = Chr( 34 ) )
                                    Device2$ = Mid( Device2$, 2, Len(Device2$)-2 ) 
                                EndIf     
                                Args = ReplaceString(Args,"%sc", Device2$,0,ArgIndex,1): Device2$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue
                                
                            ElseIf ( Len(Device3$) <> 0 )
                                If ( Right(Device3$, 1) = Chr( 34 ) ) And ( Left(Device3$, 1) = Chr( 34 ) )
                                    Device3$ = Mid( Device3$, 2, Len(Device3$)-2 ) 
                                EndIf                                              
                                Args = ReplaceString(Args,"%sc", Device3$,0,ArgIndex,1): Device3$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue
                                
                            ElseIf ( Len(Device4$) <> 0 )
                                If ( Right(Device4$, 1) = Chr( 34 ) ) And ( Left(Device4$, 1) = Chr( 34 ) )
                                    Device4$ = Mid( Device4$, 2, Len(Device4$)-2 ) 
                                EndIf                                              
                                Args = ReplaceString(Args,"%sc", Device4$,0,ArgIndex,1): Device4$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue                         
                            EndIf
                            
                        ElseIf ( DOS_Argv_GetSlotContent(Args, ArgIndex) = "%s" )
                                 If     ( Len(Device1$) <> 0 )
                                     Args = ReplaceString(Args,"%s", Device1$,0,ArgIndex,1): Device1$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue 
                                     
                                 ElseIf ( Len(Device2$) <> 0 )
                                     Args = ReplaceString(Args,"%s", Device2$,0,ArgIndex,1): Device2$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue
                                     
                                 ElseIf ( Len(Device3$) <> 0 )
                                     Args = ReplaceString(Args,"%s", Device3$,0,ArgIndex,1): Device3$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue
                                     
                                 ElseIf ( Len(Device4$) <> 0 )
                                     Args = ReplaceString(Args,"%s", Device4$,0,ArgIndex,1): Device4$ = ""  : ArgIndex = 0: ArgLen = Len(Args): Continue                         
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
        
        Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #Commandline: (Siehe nächste Zeile)" + Chr(13) + Args)
    

        
        ProcedureReturn Args
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Section Programm Starten
    ;****************************************************************************************************************************************************************
    Procedure DOS_Prepare()
        
        Protected PrgID.i, Base.i = DC::#Database_001, Table$ = "Programs", LSRowID.i, LSBoxID.i
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
            *Params\PrgFlag         = #PB_Program_Open|#PB_Program_Read|#PB_Program_Error
            *Params\StError         = ""
    
            ;
            ; Normalisiere, 
            *Params\PrgPath         = GetPathPart(*Params\Program)
            *Params\Program         = GetFilePart(*Params\Program)
            
            If (Len(*Params\Program) = 0 )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to Run. Please Select a Program",2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn
            EndIf 
            
            If (FileSize(*Params\PrgPath) <> -2 )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Program Folder Does Not Exists",2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn
            EndIf 
            
            If (FileSize(*Params\PrgPath + *Params\Program  ) = -1 )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to Run. Cant Find it..",2,2,"",0,0,DC::#_Window_001)
                ProcedureReturn
            EndIf              
            
            ;
            ; Prüfe Nach Speziellen Kommandos
            *Params\Command         = DOS_Device(*Params\Command, *Params\Program, 0, *Params\PrgPath)
            Debug #CR$+ "Volle Commandline: " +#CR$+ *Params\Command
            
            ;
            ; Markiere Item welches gestartet ist
            vItemTool::Item_Process_Loaded()
            
            ProgrammMutex  = CreateMutex()
            _Action1 = 0 
            _Action1 = CreateThread(@DOS_Thread(),*Params)                      
            
            ;If ( Startup::*LHGameDB\Settings_Asyncron = #False ) 
                While IsThread(_Action1)   
                    Delay(25)                
                    While WindowEvent()                         
                    Wend  
                Wend                 
            ;EndIf
            ;
            ; Minimiert vSystems/ Setzt den Zustand des programms Wieder her. Minimiren befindet sich Modul 
            ; DOS_Thread_GameMode(*Params.PROGRAM_BOOT)
            ; Sollte das Programm Asyncron gestartet werden lass das Window in Ruhe
            If ( Startup::*LHGameDB\Settings_Asyncron = #False )
                 Startup::*LHGameDB\Settings_Minimize = DOS_Thread_Minimze(Startup::*LHGameDB\Settings_Minimize)  
            EndIf    
            
            If (Startup::*LHGameDB\Settings_bNoOutPt = #True)    
                *Params\StError = "";
            EndIf
            
            If  ( Len(*Params\StError) >= 1 )     
                    
                ReturnCodes = CountString(*Params\StError, Chr(13) )
                NewLines    = CountString(*Params\StError, Chr(10) )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "("+Str(ReturnCodes)+ "/ "+Str( NewLines) +") W.T.F. Output: " + GetFilePart(*Params\Program),*Params\Logging + Chr(13) + Chr(13) + *Params\StError,2,2,*Params\PrgPath + *Params\Program,0,0,DC::#_Window_001)
            EndIf    

            
            ;
            ; Markiere Item welches gestartet ist
            vItemTool::Item_Process_UnLoaded()            
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Versteckt/ Öffnet die Screenshots
    ;****************************************************************************************************************************************************************
    Procedure PicSupport_Hide_Show()
        
        Protected SplitHeight.i        
        SplitHeight = GetGadgetState(DC::#Splitter1)
        h = WindowHeight(DC::#_Window_001 ) -30
          
            Select SplitHeight                    
                    ;
                    ; Höhe ist Obene -> Verschiebe komplett Nach Oben
                Case 0                
                    SetGadgetState(DC::#Splitter1,GadgetHeight(Startup::*LHImages\ScreenGDID[1]))
                    
                Case h
                    ;
                    ; Höhe ist Unten -> Verschiebe komplett Nach Oben                
                    SetGadgetState(DC::#Splitter1,GadgetHeight(Startup::*LHImages\ScreenGDID[1]))
                    
                Default 
                    SetGadgetState(DC::#Splitter1,h)
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
    ; Ändert die Splitterhöhe für ALLE einträge
    ;****************************************************************************************************************************************************************
    Procedure Splitter_SetAll()
        
        Protected Rows.i , result.i, oHeight.i, nHeight.s, strIndex.i, c.c, SetHeight.s, RowID.i
        
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
                
        Select Rows
            Case 0
            Default
                oHeight = ExecSQL::iRow(DC::#Database_001,"Gamebase","SplitHeight",0,Startup::*LHGameDB\GameID,"",1)
                result  = vItemTool::DialogRequest_Num("SplitterHeight","Use the default current Splitterheight for all entry's?" + Chr(13) + "Standard Höhe ist: 289",Str(oHeight))
                
                If ( result = 0 )
                    
                    nHeight = Request::*MsgEx\Return_String
                    
                    If ( Val(nHeight) = oHeight )
                       ; Ich denke das wird nicht benötigt
                       ; ProcedureReturn
                    EndIf
                    
                    If ( Len(nHeight) <> 0 )                         
                        For strIndex = 0 To Len(nHeight)                            
                            c = Asc( Left(nHeight,strIndex) )
                            Select c
                                Case 48 To 57
                                    SetHeight.s + Mid(nHeight,strIndex,1)
                                Default                                    
                            EndSelect                            
                        Next                                            
                        
                        ResetList(ExecSQL::_IOSQL())   
                        
                        HideGadget(DC::#Text_004,0)
                        
                        For RowID = 1 To Rows              
                            NextElement(ExecSQL::_IOSQL())   
                            
                            SetGadgetText(DC::#Text_004,"Ändere Splitterhöhe ID: " + Str(RowID) + "/" + Str(Rows))
                            
                            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", SetHeight,ExecSQL::_IOSQL()\nRowID)                             
                        Next
                        
                        ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight", SetHeight,1)
                        Splitter_SetGet(#True) 
                        HideGadget(DC::#Text_004,1)
                    EndIf                        
                EndIf                                   
        EndSelect                
        
    EndProcedure  
    ;****************************************************************************************************************************************************************
    ; Ändert die Thumbnail Weite und Höhe für alle Einträge
    ;****************************************************************************************************************************************************************
    Procedure Thumbnails_SetAll()
        
        Protected Rows.i , result.i, oHeight.i, oWidth.i, nHeight.s, strIndex.i, c.c, SetHeight.s, RowID.i
        
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_002,"GameShot")  
                
        Select Rows
            Case 0
            Default
             oWidth  = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsW",0,Startup::*LHGameDB\GameID,"",1)
             oHeight = ExecSQL::iRow(DC::#Database_002,"GameShot","ThumbnailsH",0,Startup::*LHGameDB\GameID,"",1)
             Debug oWidth
             Debug oHeight
                                                              
             ResetList(ExecSQL::_IOSQL())                                                   
             HideGadget(DC::#Text_004,0)
             
             For RowID = 1 To Rows
                 
                 NextElement(ExecSQL::_IOSQL())                                                         
                 
                 ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str( oWidth ),ExecSQL::_IOSQL()\nRowID)
                 ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str( oHeight),ExecSQL::_IOSQL()\nRowID) 
                 SetGadgetText(DC::#Text_004,"Change Thumbnail Size: "+Str(oWidth)+"x"+Str( oHeight) +" ( "+ Str(RowID) + "/" + Str(Rows) + ")")
                 
                 
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
                vImages::Thumbnails_SetReDraw(#False)
                
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
                
                vImages::Thumbnails_SetReDraw(#True)
        EndSelect  
    EndProcedure
   
    ;****************************************************************************************************************************************************************
    ; Info Window Texte in die DB Speichern
    ;****************************************************************************************************************************************************************         
    Procedure    Text_UpdateDB()
        
        Select Startup::*LHGameDB\InfoWindow\bTabNum
                Case 1
                    SetActiveGadget( DC::#Text_128 )
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat1", szText ,Startup::*LHGameDB\GameID)
                Case 2
                    SetActiveGadget( DC::#Text_129 )                                        
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat2", szText ,Startup::*LHGameDB\GameID)                    
                Case 3
                    SetActiveGadget( DC::#Text_130 )              
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat3", szText ,Startup::*LHGameDB\GameID)                    
                Case 4
                    SetActiveGadget( DC::#Text_131 )              
                    szText.s = GetGadgetText( DC::#String_112  )
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditDat4", szText ,Startup::*LHGameDB\GameID)                   
            EndSelect 
            
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
    
    
    
EndModule    




; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 2752
; FirstLine = 1873
; Folding = 8egDaH9-QnE5
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = L:\Sortet Games\Doom 3\Windows Doom3 vTotal\
; Debugger = IDE
; Warnings = Display
; EnablePurifier
; EnableUnicode