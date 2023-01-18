DeclareModule vItemTool
    
    Declare   Item_Select_List()
    Declare   Item_Update_List()
    Declare   Show_Select_List(cat.i = 0, GetOldID.i = #False)
    Declare   Item_New()
    Declare   Item_New_FomMenu(prgDescriptn$, prgShortName$, prg_Commands$, File_Default$ ,Path_Default$)
    Declare   Item_Duplicate()
    Declare   Item_Delete_List()
    Declare   Item_Rename()
    Declare   Item_Programm_Update()
    Declare   Item_Open_File_Check()
    Declare   Item_Cancel(Liste)
    Declare.s Item_GetTitleName(UseSaveFile.i = #False)
    Declare   Item_Process_Loaded()
    Declare   Item_Process_UnLoaded()
    
    Declare.i File_GetFiles(Path.s)
    
    
    ;
    ; Wird auch im Modul vEngine benutzt
    Declare.i DialogRequest_Add(Title.s="Neuer Eintrag",Message.s="Erstelle neuen Eintrag mit dem Title:",ReturnString.s="")
    Declare.i DialogRequest_Def(Title.s="",Message.s="", ButtonNum = 11)
    Declare.i DialogRequest_Dup(Title.s="",Message.s="",ReturnString.s="")
    Declare.i DialogRequest_Sze(Title.s="",Message.s="",ReturnString.s="")
    Declare.i DialogRequest_3BT(Title.s="",Message.s="", ButtonNum = 11)
    
    ;
    ; Alle Dialog Rewquester mit Nummenr sollten dien nun bekommen
    Declare.i DialogRequest_Num(Title.s="",Message.s="",ReturnString.s="")
    
    Declare.l DialogRequest_Screens_Menu_Verfiy_Serie(File.s)
    Declare.l DialogRequest_Screens_Menu_Verfiy_File(File.s)
EndDeclareModule

Module vItemTool
    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
    Structure STRUCT_DBTOLIST
        BaseTable.s
        BaseColumn.s
        ExtnTable.s
        ExtnColumn.s
        Old_It.s        ; Altes Item, wird gehalten wenn man Cancel oder Escape drückt
        Old_Id.i        ; Altes ID, wird gehalten wenn man Cancel oder Escape drückt
    EndStructure    
    
    
    Global *vList.STRUCT_DBTOLIST       = AllocateMemory(SizeOf(STRUCT_DBTOLIST))
    
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s Item_GetTitleName(UseSaveFile.i = #False)
        Protected TitleText$ = ""
        If ( Len( GetGadgetText(DC::#Text_001) ) >= 1 )  And ( Len( GetGadgetText(DC::#Text_002) ) >= 1 )
            If ( UseSaveFile = #False )
                TitleText$ = GetGadgetText(DC::#Text_001) + ": " + GetGadgetText(DC::#Text_002)
            Else
                TitleText$ = GetGadgetText(DC::#Text_001) + " - " + GetGadgetText(DC::#Text_002)
            EndIf    
            
        ElseIf  ( Len(GetGadgetText(DC::#Text_001)) >= 1 )
            TitleText$ = GetGadgetText(DC::#Text_001)
        ElseIf  ( Len(GetGadgetText(DC::#Text_002)) >= 1 )  
            TitleText$ = GetGadgetText(DC::#Text_002)
        EndIf 
        
        If ( Len(TitleText$) >= 1 )
            If ( UseSaveFile = #False )
                TitleText$ = Chr(9) + " [ " +TitleText$+ " ]"
            EndIf                
        EndIf    
        
        If ( UseSaveFile = #True )
            
            For n = 1 To Len(TitleText$)                
                c.c = Asc(Mid(TitleText$,n,1))
                Select c
                    Case 58
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," - ",0,n,1); :
                    Case 60
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," ( ",0,n,1); <
                    Case 62
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," ) ",0,n,1); >
                    Case 63
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," _ ",0,n,1); ?
                    Case 34
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," '' ",0,n,1); "   
                    Case 47
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," - ",0,n,1); /
                    Case 92
                        TitleText$ = ReplaceString(TitleText$, Chr(c)," - ",0,n,1); \                         
                EndSelect                                                
            Next    
        EndIf    
        ProcedureReturn  TitleText$
     EndProcedure      
    ;******************************************************************************************************************************************
    ;  Prüfe ob die Datei existiert/ Alle Bilder
    ;__________________________________________________________________________________________________________________________________________
    Procedure.l  DialogRequest_Screens_Menu_Verfiy_Serie(File.s)
        
        Protected Result.i
        If ( FileSize(File.s) >= 8 )
            Request::*MsgEx\User_BtnTextL = "Überschreiben"
            Request::*MsgEx\User_BtnTextR = "Überspringen"
            Request::*MsgEx\User_BtnTextM = "Abbruch"              
            Request::*MsgEx\CheckBox_Txt  = "Nicht mehr nachfragen. (Existierende Dateien werden Überschrieben) "
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion,"Datei Existiert","Die Datei [ " + File.s + " ] Existiert",16,1,ProgramFilename(),1,0,DC::#_Window_001)
        EndIf
        SetActiveGadget(DC::#ListIcon_001 ): ProcedureReturn Result
        
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Prüfe ob die Datei existiert
    ;__________________________________________________________________________________________________________________________________________    
    Procedure.l  DialogRequest_Screens_Menu_Verfiy_File(File.s)
        
        Protected Result.i
        If ( FileSize(File.s) >= 8 )
            Request::*MsgEx\User_BtnTextL = "Überschreiben"
            Request::*MsgEx\User_BtnTextR = "Abbruch"            
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion,"Datei Existiert","Die Datei [ " + File.s + " ] Existiert",10,1,ProgramFilename(),0,0,DC::#_Window_001 )
        EndIf
        SetActiveGadget(DC::#ListIcon_001 ): ProcedureReturn Result
        
    EndProcedure    
   
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i DialogRequest_Dup(Title.s="",Message.s="",ReturnString.s="")
        
        ; Selektiere die Richtige Window ID. Diese ist wichtig für den Request Dialog
        Select Startup::*LHGameDB\UpdateSection
            Case 2,3                        
                ChildWindow = DC::#_Window_002
            Case 4
                ChildWindow = DC::#_Window_003
            Default
                ChildWindow = DC::#_Window_001                
        EndSelect  
        
        Request::*MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt2 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt3 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\User_BtnTextL = "Ja"
        Request::*MsgEx\User_BtnTextR = "Nö"
        Request::*MsgEx\Checkbox_On   = 0
        Request::*MsgEx\CheckBox_Txt  = ""
        Request::*MsgEx\Return_String = ""
        r = Request::MSG(Startup::*LHGameDB\TitleVersion,"(Test) Frage...", "Sollen die Die Screenshots auch übernommen werden?",10,0,ProgramFilename(),0,0,ChildWindow)
        ProcedureReturn r
    EndProcedure    
    
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i DialogRequest_Sze(Title.s="",Message.s="",ReturnString.s="")
        
        ; Selektiere die Richtige Window ID. Diese ist wichtig für den Request Dialog
        Select Startup::*LHGameDB\UpdateSection
            Case 2,3                        
                ChildWindow = DC::#_Window_002
            Case 4
                ChildWindow = DC::#_Window_003
            Default
                ChildWindow = DC::#_Window_001                
        EndSelect  
        
        Request::*MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt2 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt3 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\User_BtnTextL = "Ja"
        Request::*MsgEx\User_BtnTextR = "Nö"
        Request::*MsgEx\Checkbox_On   = 0
        Request::*MsgEx\CheckBox_Txt  = ""
        Request::*MsgEx\Return_String = ""
        r = Request::MSG(Startup::*LHGameDB\TitleVersion,"(Test) Frage...", "Soll die Thumbnail Grösse mit übernommen werden?",10,0,ProgramFilename(),0,0,ChildWindow)
        ProcedureReturn r
    EndProcedure      
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i DialogRequest_Add(Title.s="Neuer Eintrag",Message.s="Erstelle neuen Eintrag mit dem Title:",ReturnString.s="")
        
        ; Selektiere die Richtige Window ID. Diese ist wichtig für den Request Dialog
        Select Startup::*LHGameDB\UpdateSection
            Case 2,3                        
                ChildWindow = DC::#_Window_002
            Case 4
                ChildWindow = DC::#_Window_003
            Default
                ChildWindow = DC::#_Window_001                
        EndSelect  
        
        Request::*MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt2 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt3 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\User_BtnTextL = "Ok"
        Request::*MsgEx\User_BtnTextR = "Cancel"
        Request::*MsgEx\Checkbox_On   = 1
        Request::*MsgEx\CheckBox_Txt  = ReturnString
        Request::*MsgEx\Return_String = ReturnString
        r = Request::MSG(Startup::*LHGameDB\TitleVersion,Title, Message,10,1,ProgramFilename(),0,1,ChildWindow)
        ProcedureReturn r
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________    
     Procedure.i DialogRequest_Def(Title.s="",Message.s="", ButtonNum = 11)
         Protected Result, ChildWindow
         
        ; Selektiere die Richtige Window ID. Diese ist wichtig für den Request Dialog
        Select Startup::*LHGameDB\UpdateSection
            Case 2,3                        
                ChildWindow = DC::#_Window_002               
            Case 4
                ChildWindow = DC::#_Window_003
            Default
                ChildWindow = DC::#_Window_001
        EndSelect  
        
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion,Title,Message,11,-1,ProgramFilename(),0,0,ChildWindow )
        
        ;
        ; Aktivere das Richtige in dem Jeweiligen Fenster
        Select ChildWindow
            Case 2,3,4                        
                SetActiveGadget(DC::#ListIcon_002)
            Default
                SetActiveGadget(DC::#ListIcon_001)
        EndSelect         
         
         If Result = 0
             ProcedureReturn #True
         EndIf 
         ProcedureReturn #False
    EndProcedure     
    
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________    
     Procedure.i DialogRequest_3BT(Title.s="",Message.s="", ButtonNum = 11)
         Protected Result, ChildWindow
         
        ; Selektiere die Richtige Window ID. Diese ist wichtig für den Request Dialog
        Select Startup::*LHGameDB\UpdateSection
            Case 2,3                        
                ChildWindow = DC::#_Window_002               
            Case 4
                ChildWindow = DC::#_Window_003
            Default
                ChildWindow = DC::#_Window_001
        EndSelect  
        
        Request::*MsgEx\User_BtnTextL = "Löschen"
        Request::*MsgEx\User_BtnTextM = "Löschen (Alle)"
        Request::*MsgEx\User_BtnTextR = "Abbruch"         
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion,Title,Message,16,-1,ProgramFilename(),0,0,ChildWindow )
        Debug Result
        ;
        ; Aktivere das Richtige in dem Jeweiligen Fenster
        Select ChildWindow
            Case 2,3,4                        
                SetActiveGadget(DC::#ListIcon_002)
            Default
                SetActiveGadget(DC::#ListIcon_001)
        EndSelect         
         
         If Result = 0
             ProcedureReturn #True
         ElseIf  Result = 2
             ProcedureReturn 2
         EndIf
         
         ProcedureReturn #False
    EndProcedure       
    ;**********************************************************************************************************************************************************************
    ;Dialog Requester für Nummern Eingabe
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i DialogRequest_Num(Title.s="",Message.s="",ReturnString.s="")
        
        ; Selektiere die Richtige Window ID. Diese ist wichtig für den Request Dialog
        Select Startup::*LHGameDB\UpdateSection
            Case 2,3                        
                ChildWindow = DC::#_Window_002
            Case 4
                ChildWindow = DC::#_Window_003
            Default
                ChildWindow = DC::#_Window_001                
        EndSelect  
        
        Request::*MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt2 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\Fnt3 = FontID(Fonts::#_FIXPLAIN7_12)
        Request::*MsgEx\User_BtnTextL = "Ok"
        Request::*MsgEx\User_BtnTextR = "Cancel"
        Request::*MsgEx\Checkbox_On   = 1
        Request::*MsgEx\CheckBox_Txt  = ReturnString
        Request::*MsgEx\Return_String = ReturnString
        r = Request::MSG(Startup::*LHGameDB\TitleVersion,Title, Message,10,1,ProgramFilename(),0,1,ChildWindow)
        ProcedureReturn r
    EndProcedure        
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure Item_Selector_LoadList()
        ; Neuer Title, Liste Löschen und neu laden
        ClearGadgetItems(DC::#ListIcon_002)                           
        
        Select Startup::*LHGameDB\UpdateSection
            Case 2: vItemTool::Show_Select_List(0)
            Case 3: vItemTool::Show_Select_List(1)
            Case 4: vItemTool::Show_Select_List(2)
        EndSelect                                      
        Delay(2) 

    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i Item_State_Check(Liste.i)
        If ( GetGadgetItemState(Liste,GetGadgetState(Liste)) = -1 )            
            SetGadgetItemState(DC::#ListIcon_002,0,1): SetGadgetText(DC::#String_100,GetGadgetItemText(Liste,GetGadgetState(Liste))): ProcedureReturn #False
        EndIf
        ProcedureReturn #True
    EndProcedure    
    
    Procedure Item_DisableButtons_NoName(DisableButtons.i)
        
        ButtonEX::Disable(DC::#Button_204, DisableButtons)
        ButtonEX::Disable(DC::#Button_205, DisableButtons)
        ButtonEX::Disable(DC::#Button_206, DisableButtons)                                            
     EndProcedure           
    ;**********************************************************************************************************************************************************************
    ;Item_Select_List
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure Item_Select_List()
        
        Protected Liste.i =  DC::#ListIcon_002, RowID.i, LstString$, Prg____Path$ = "", WorkingPath$ = "", Commandline$ = "", Short__Name$ = "" 
        
        Request::SetDebugLog("Lste: GetGadgetItemState :"+ Str(GetGadgetItemState(Liste,GetGadgetState(Liste)))+ " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
        Request::SetDebugLog("Lste: GetGadgetItemData  :"+ Str(GetGadgetItemData(Liste,GetGadgetState(Liste))) + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
        Request::SetDebugLog("Lste: GetGadgetItemText  :"+ GetGadgetItemText(Liste,GetGadgetState(Liste))      + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))           
        Debug ""
        
        Item_DisableButtons_NoName(false)
        If ( Item_State_Check(Liste) )
            
            RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
            Select RowID
                Case 0
                    LstString$ = "[No Name]" 
                    Item_DisableButtons_NoName(#True)
                Default 
                    
                    LstString$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,*vList\ExtnColumn,"",RowID,"",1)  
                    
                    If (*vList\ExtnTable = "Programs")                    
                        ;
                        ; Ist nur Aktiv wenn sich das Table: Programs in der Strukture *vList befindet
                        Short__Name$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"ExShort_Name","",RowID,"",1) ; Kurzer Name wie z.b der Name der Exe                        
                        Prg____Path$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"File_Default","",RowID,"",1) ; Full File and Path
                        WorkingPath$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"Path_Default","",RowID,"",1) ; Working Path                     
                        Commandline$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"Args_Default","",RowID,"",1) ; Commandline                                                               
                    EndIf
                    
                    
            EndSelect  
            
            SetGadgetText(DC::#String_100,LstString$)
            ;
            ;
            If (*vList\ExtnTable = "Programs")  
                SetGadgetText(DC::#String_101,Prg____Path$)
                SetGadgetText(DC::#String_102,WorkingPath$) 
                SetGadgetText(DC::#String_103,Commandline$)
                SetGadgetText(DC::#String_104,Short__Name$)
            EndIf
            
            Item_Update_List()
        EndIf  
    EndProcedure                                    
    ;**********************************************************************************************************************************************************************
    ;Show_Select_List
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure Show_Select_List(cat.i = 0, GetOldID.i = #False)
        
        Protected row.i, RowID.i, ListID.i, LbItemH.i
        Select cat.i
                ;
                ; Language
            Case 0
                *vList\ExtnTable = "Language" : *vList\ExtnColumn  = "Locale"
                *vList\BaseTable = "Gamebase" : *vList\BaseColumn  = "LanguageID"
                Startup::*LHGameDB\UpdateSection = 2
                ;
                ; Platform
            Case 1
                *vList\ExtnTable = "Platform" : *vList\ExtnColumn  = "Platform"
                *vList\BaseTable = "Gamebase" : *vList\BaseColumn  = "PlatformID"
                Startup::*LHGameDB\UpdateSection = 3                
                ;
                ; Port/ Emulator
            Case 2
                *vList\ExtnTable = "Programs" : *vList\ExtnColumn  = "Program_Description"
                *vList\BaseTable = "Gamebase" : *vList\BaseColumn  = "PortID"                 
                Startup::*LHGameDB\UpdateSection = 4                
        EndSelect
        
         ;
         ; Hole die RowID um den Eintrag zu selektieren
        RowID = Val(ExecSQL::nRow(DC::#Database_001,*vList\BaseTable,*vList\BaseColumn,"",Startup::*LHGameDB\GameID,"",1)):  
        
         ;
         ;         
        For row = 0 To 0
            AddGadgetItem(DC::#ListIcon_002, row, "[No Name]")
            SetGadgetItemData(DC::#ListIcon_002, row, row)
        Next row  
        
        If ( ListSize(ExecSQL::_IOSQL() ) <> 0 )
            ClearList(ExecSQL::_IOSQL())
        EndIf
         ;
         ; Gehe durch die anderen Table        
        Rows = ExecSQL::CountRows(DC::#Database_001,*vList\ExtnTable)
        ExecSQL::lRows(DC::#Database_001,*vList\ExtnTable,*vList\ExtnColumn,1,Rows,ExecSQL::_IOSQL(),*vList\ExtnColumn,"asc")
        

        ResetList(ExecSQL::_IOSQL())
        For row = 1 To Rows
            NextElement(ExecSQL::_IOSQL())

            AddGadgetItem (DC::#ListIcon_002,row,ExecSQL::_IOSQL()\Value_$)       
            SetGadgetItemData(DC::#ListIcon_002,row,ExecSQL::_IOSQL()\nRowID)
            
            If ( RowID = ExecSQL::_IOSQL()\nRowID )
                ListID = row
            EndIf    

        Next                     
        
        LbItemH = SendMessage_(GadgetID(DC::#ListIcon_002), #LVM_GETITEMSPACING, #True,  0) >> 16 ; only need to do this once                
        Select ListID
            Case 0,1
                SetGadgetItemState(DC::#ListIcon_002,ListID,1) 
                ;SendMessage_(GadgetID(DC::#ListIcon_002), #LVM_SCROLL, 0, Startup::*LHGameDB\GameLS) ; scroll to top
            Default    
                SetGadgetItemState(DC::#ListIcon_002,ListID,1);
                SendMessage_(GadgetID(DC::#ListIcon_002), #LVM_SCROLL, 0, (ListID-15) * LbItemH)       ; scroll to center hot item in listicon
        EndSelect 
        
        ;
        ; Sichere Die Alte ID wenn man Escape oder Close drückt
        If ( GetOldID = #True )
            *vList\Old_Id = GetGadgetItemData(DC::#ListIcon_002,ListID)
        EndIf    
        SetActiveGadget(DC::#ListIcon_002)          
                
        Item_Select_List()                                
        
        
    EndProcedure  

    ;**********************************************************************************************************************************************************************
    ;Item_Update_List
    ;______________________________________________________________________________________________________________________________________________________________________   
    Procedure Item_Delete_List()
        Protected RowID.i,  Liste.i =  DC::#ListIcon_002, MaxItems.i, CurrentPosition, Result.i
        
        
        RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
        Select RowID
                Case 0
                    ;
                    ; Null Item Can nicht gelöscht werden
                    DialogRequest_Def("Nö","Kann nicht gelöscht werden")
                Default                                       
                    
                    Result = DialogRequest_Def("WTF","Soll der Eintrag " + GetGadgetItemText(Liste,GetGadgetState(Liste)) + " gelöscht werden")
                    If ( Result = #True )
                        
                        ;
                        ; Falls die ID die selbe die man löscht und wenn man Abruchh oder Escape drückt
                        ; Schreibe ID null später beim Item_Cancel() zurück die Haupt Datenbank
                        If ( RowID = *vList\Old_Id )
                            *vList\Old_Id = 0
                        EndIf                          
                        
                        CurrentPosition = GetGadgetState(Liste)
                        
                        Select CurrentPosition
                            Case CountGadgetItems(Liste) - 1
                                CurrentPosition - 1
                        EndSelect                            
                        RemoveGadgetItem(Liste,GetGadgetState(Liste)) 
                        SetGadgetState(Liste,CurrentPosition)
                        
                        LastRowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
                        
                        ExecSQL::DeleteRow(DC::#Database_001,*vList\ExtnTable,RowID)                                                             
                        ExecSQL::UpdateRow(DC::#Database_001,*vList\BaseTable, *vList\BaseColumn, Str(LastRowID),Startup::*LHGameDB\GameID)     
                        
                        Item_Selector_LoadList()
                    EndIf
                    
   
            EndSelect                          
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;Item_Update_List
    ;______________________________________________________________________________________________________________________________________________________________________  
    Procedure Item_Update_List()
        
        Protected Liste.i =  DC::#ListIcon_002
                  
        If Item_State_Check(Liste)        
            RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))                        
            ExecSQL::UpdateRow(DC::#Database_001, *vList\BaseTable,  *vList\BaseColumn, Str(RowID), Startup::*LHGameDB\GameID)        ;*
        EndIf            
    EndProcedure
    
    ;**********************************************************************************************************************************************************************
    ; prgDescriptn$ ist der Title der in der Liste angezeigt wird
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure Item_New_FomMenu(prgDescriptn$, prgShortName$, prg_Commands$, File_Default$ ,Path_Default$)
        
        Protected LastRowID.i ,Liste.i =  DC::#ListIcon_002, Argumente$, xReturn = 228, eLine = 0, StrikeCnt
        
        
        Argumente$ = prg_Commands$
        
        If Len(Argumente$) > = xReturn
            
            StrikeCnt = CountString( Argumente$ , Chr(32)+"-")
            
            If ( StrikeCnt >= 10 )
                Argumente$ = ""  
                For i = 1 To StrikeCnt
                    
                    If i = 1
                        Argumente$ + StringField( prg_Commands$, i, Chr(32)+"-" ) + #CRLF$
                    Else
                        Argumente$ + "-"+StringField( prg_Commands$, i, Chr(32)+"-" ) + #CRLF$
                    EndIf
                Next
            Else
                                         
                Argumente$ = ""            
                For i = 0 To Len(prg_Commands$)
                    
                    ; Don't bomb the Screen
                    If ( Len(prg_Commands$) = i ) 
                        Break;
                    Else
                        
                        asci.i = Asc(Mid(prg_Commands$,i,1) )
                        Argumente$ + Chr(asci)
                        
                        If ( Len(Argumente$) >= xReturn ) And ( asci = 32)
                            Argumente$ + Chr(13)
                            xReturn + 228
                        EndIf                            
                    EndIf    
                Next
            EndIf
        EndIf    
        
        r = DialogRequest_Add("Neuen Eintrag", "Füge " +prgDescriptn$+ " mit den Argumenten" +#CRLF$+ " '" +Argumente$+ "' hinzu ?"+#CRLF$+#CRLF$+ "Angezeigten Titel ändern ?", prgDescriptn$)    
        
        If (r = 1): SetActiveGadget(DC::#ListIcon_002): ProcedureReturn
        Else 
            ;
            ; Neue String Säubern
            prgDescriptn$ = Trim(Request::*MsgEx\Return_String)
            If ( Len(prgDescriptn$) => 1 )
              
                ;
                ;
                ExecSQL::InsertRow(DC::#Database_001,*vList\ExtnTable,  "ExShort_Name,Program_Description,Path_Default,File_Default,Args_Default", ""+prgShortName$+","+prgDescriptn$+","+Path_Default$+","+File_Default$+","+prg_Commands$+"")                                                              
                LastRowID = ExecSQL::LastRowID(DC::#Database_001,*vList\ExtnTable)                
                ExecSQL::UpdateRow(DC::#Database_001,*vList\BaseTable, *vList\BaseColumn, Str(LastRowID),Startup::*LHGameDB\GameID)              
                
                Item_Selector_LoadList()                             
            EndIf                      
        EndIf   
    EndProcedure 
    
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure Item_New()
        
        Protected LastRowID.i 
        
        Protected Title$ = ""
        r = DialogRequest_Add()    
        
        If (r = 1): SetActiveGadget(DC::#ListIcon_002): ProcedureReturn
        Else
            
            ;
            ; Neue String Säubern
            Title$ = Trim(Request::*MsgEx\Return_String)
            If ( Len(Title$) => 1 )
                
                ;
                ; Öffne die Datenbank
                ;                           ExecSQL::OpenDB(DC::#Database_001,Startup::*LHGameDB\Base_Game): Delay(10)
                
                ;
                ;
                ExecSQL::InsertRow(DC::#Database_001,*vList\ExtnTable,  *vList\ExtnColumn, Title$)
                LastRowID = ExecSQL::LastRowID(DC::#Database_001,*vList\ExtnTable)
                ExecSQL::UpdateRow(DC::#Database_001,*vList\BaseTable, *vList\BaseColumn, Str(LastRowID),Startup::*LHGameDB\GameID) 
                
                Item_Selector_LoadList()
                
            EndIf                      
        EndIf   
    EndProcedure      
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure Item_Duplicate()        
        
        Protected RowID.i, LastRowID.i, LstString$ = "", Liste.i =  DC::#ListIcon_002, Short__Name$,Prg____Path$,WorkingPath$,Commandline$, PrgColumn$, PrgValue$
        
        RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
        Select RowID
                Case 0
                    LstString$ = "[No Name]" + " [Copy]"
                Default         
                    LstString$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,*vList\ExtnColumn,"",RowID,"",1) + " [Copy]"
                    
                    ;
                    ;Dupliziere Die Einträge des Programms
                    If (*vList\ExtnTable = "Programs")                    
                        ;
                        ; Ist nur Aktiv wenn sich das Table: Programs in der Strukture *vList befindet
                        Short__Name$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"ExShort_Name","",RowID,"",1) ; Kurzer Name wie z.b der Name der Exe                        
                        Prg____Path$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"File_Default","",RowID,"",1) ; Full File and Path
                        WorkingPath$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"Path_Default","",RowID,"",1) ; Working Path                     
                        Commandline$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,"Args_Default","",RowID,"",1) ; Commandline 
                    EndIf    
        EndSelect
        ;
        ;
        
        ExecSQL::InsertRow(DC::#Database_001,*vList\ExtnTable,  *vList\ExtnColumn, LstString$)           
        LastRowID = ExecSQL::LastRowID(DC::#Database_001,*vList\ExtnTable)
        
        ;
        ;Update und Dupliziere nur die Programm Einstellungen
        If (*vList\ExtnTable = "Programs")
            ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "ExShort_Name", Short__Name$,LastRowID) 
            ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "File_Default", Prg____Path$,LastRowID)
            ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "Path_Default", WorkingPath$,LastRowID)
            ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "Args_Default", Commandline$,LastRowID)
        EndIf            
        
        ExecSQL::UpdateRow(DC::#Database_001,*vList\BaseTable, *vList\BaseColumn, Str(LastRowID),Startup::*LHGameDB\GameID)                     
        
        Item_Selector_LoadList()
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure Item_Rename()
        
        Protected RowID.i, Liste.i =  DC::#ListIcon_002, TestString$
        
        RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
        Select RowID           
                ;
                ; Erster Eintrag [No Name] wir nicht umbenannt
            Case 0                   
            Default
                TestString$ = ExecSQL::nRow(DC::#Database_001,*vList\ExtnTable,*vList\ExtnColumn,"",RowID,"",1)  
                
                SetActiveGadget(-1)
                
                r = DialogRequest_Add("","",TestString$)
                If (r = 1): SetActiveGadget(DC::#ListIcon_002): ProcedureReturn
                Else
                    ;
                    ; Neue String Säubern
                    TestString$ = Trim(Request::*MsgEx\Return_String)
                    If ( Len(TestString$) >= 1 )
                        
                        ;
                        ;
                        ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, *vList\ExtnColumn, TestString$,RowID) 
                        ExecSQL::UpdateRow(DC::#Database_001,*vList\BaseTable, *vList\BaseColumn, Str(RowID),Startup::*LHGameDB\GameID)  
                        Item_Selector_LoadList()                        
                    EndIf    
                EndIf    
        EndSelect
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure Item_Programm_Update()
        Protected RowID.i, prgShortName$, prgDescriptn$, prg_FilePath$, prg_WorkPath$, prg_Commands$, Liste.i =  DC::#ListIcon_002
        
        prgShortName$ = Trim( GetGadgetText(DC::#String_104) )
        prgDescriptn$ = Trim( GetGadgetText(DC::#String_100) )
        prg_FilePath$ = Trim( GetGadgetText(DC::#String_101) )
        prg_WorkPath$ = Trim( GetGadgetText(DC::#String_102) )
        prg_Commands$ = Trim( GetGadgetText(DC::#String_103) )        
        
        RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
        Select RowID
            Case 0
            Default
                ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, *vList\ExtnColumn, prgDescriptn$,RowID)  
                ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "ExShort_Name"   , prgShortName$,RowID) 
                ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "File_Default"   , prg_FilePath$,RowID)
                ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "Path_Default"   , prg_WorkPath$,RowID)
                ExecSQL::UpdateRow(DC::#Database_001,*vList\ExtnTable, "Args_Default"   , prg_Commands$,RowID)                
        EndSelect
        Item_Selector_LoadList()
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure Item_Open_File_Check() 
        
        Protected Liste.i =  DC::#ListIcon_002
        If IsWindow(DC::#_Window_003) 
            Liste.i =  DC::#ListIcon_002
            RowID  = GetGadgetItemData(Liste,GetGadgetState(Liste))
            Select RowID
                Case 0        
                    ;
                    ; Das wir kein Programm angeben oder geändert
                    ProcedureReturn #False
                Default
                    ProcedureReturn #True                 
            EndSelect
        EndIf  
        
        ;
        ; C64 Datei Liste, String Öffnet das Verzeichnis oder Programm
        If IsWindow(DC::#_Window_005)                
            Liste.i =  DC::#ListIcon_003
            ProcedureReturn #True  
        EndIf                
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure Item_Cancel(Liste)
                            
            ExecSQL::UpdateRow(DC::#Database_001, *vList\BaseTable,  *vList\BaseColumn, Str(*vlist\Old_Id), Startup::*LHGameDB\GameID)        ;*
        
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________          
    Procedure Item_Process_Loaded()
        
        Protected Liste.i =  DC::#ListIcon_001        
        
        If ( Startup::*LHGameDB\Settings_Asyncron = #False )
            Startup::*LHGameDB\vItemLoaded  = GetGadgetState(Liste)
        
            Startup::*LHGameDB\vItemColorF = GetGadgetItemColor(Liste,Startup::*LHGameDB\vItemLoaded, #PB_Gadget_FrontColor)
        
            SetGadgetItemColor(Liste, Startup::*LHGameDB\vItemLoaded, #PB_Gadget_FrontColor,RGB(4, 215, 243))
            SetGadgetItemColor(Liste, Startup::*LHGameDB\vItemLoaded, #PB_Gadget_BackColor,RGB(61,61,61)) 
            SetGadgetState(Liste,-1)
            
            ;ButtonEX::Disable(DC::#Button_014, #True)
            ;ButtonEX::Settext(DC::#Button_014, 0, "Kill")
            ;ButtonEX::Settext(DC::#Button_014, 1, "Process")
            ;ButtonEX::Settext(DC::#Button_014, 2, "Now")
            
            Startup::*LHGameDB\Settings_bKillPrc = #True
            
        EndIf    
        
    EndProcedure   
        
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________          
    Procedure Item_Process_UnLoaded()
        
        Protected Liste.i =  DC::#ListIcon_001        
        
        If ( Startup::*LHGameDB\Settings_Asyncron = #False )
            
            SetGadgetItemColor(Liste, Startup::*LHGameDB\vItemLoaded, #PB_Gadget_FrontColor,Startup::*LHGameDB\vItemColorF)        
            SetGadgetItemColor(Liste, Startup::*LHGameDB\vItemLoaded, #PB_Gadget_BackColor,RGB(71,71,71))
            SetGadgetState(Liste,Startup::*LHGameDB\vItemLoaded)
            
            ;ButtonEX::Disable(DC::#Button_014, #False)
            ;ButtonEX::Settext(DC::#Button_014, 0, "Start")
            ;ButtonEX::Settext(DC::#Button_014, 1, "Start")
            ;ButtonEX::Settext(DC::#Button_014, 2, "Start")
            
            Startup::*LHGameDB\Settings_bKillPrc = #False            
        EndIf
        
        
        
    EndProcedure         
    ;**********************************************************************************************************************************************************************
    ;
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i File_GetFiles(Path.s)
            FFS::GetContent(Path, #False, #True, #False, "", "*.png",0, #False, 0 )
            FFS::SortContent()
            ResetList(FFS::FullFileSource())
            ProcedureReturn ListSize( FFS::FullFileSource() )           
    EndProcedure
EndModule  
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 817
; FirstLine = 156
; Folding = XAAA5
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode