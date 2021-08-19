DeclareModule  DB_Update   
    
    Declare Update_Base()
    
EndDeclareModule

Module DB_Update
         
    ;****************************************************************************************************************************************************
    ;    
    ; Erstellt die Datenbanken
    ;                                                
    Procedure  OpenLoad_Base_Game(BackupFile$, CurrentBase.i, Table$)
        
        Protected  Tbl$, Rows.i, Cows.i, Col$, ColumnTab$, Num.i, Txt.s
        
        TextInfoObj.i = DC::#Text_004
        HideGadget(TextInfoObj,0)  
        
        If ( DB_Create::DB_IsOpen(CurrentBase)  = #True)
            ExecSQL::TuneDB(CurrentBase)
        EndIf    
        
        If ( FileSize( BackupFile$ ) > 1 )
            
            ExecSQL::OpenDB( DC::#DummyBase, BackupFile$ )
            
            If ( DB_Create::DB_IsOpen(DC::#DummyBase)  = #True)
                
                ; Getting Table
                Tbl$ = Table$
                RCnt = ExecSQL::MaxRowID(CurrentBase,Tbl$)                
                Rows = ExecSQL::MaxRowID(DC::#DummyBase,Tbl$)
                Col$ = ExecSQL::GetColumns(DC::#DummyBase,Tbl$)
                
                Cows = CountString(Col$, ",")                                                    
                                
                For RowID = 1 To Rows
                                                             
                    For ColumnIndex = 1 To Cows
                                                
                        ColumnTab$ = StringField(Col$, ColumnIndex, ",")
                        
                        If ( ColumnIndex = 1 ) And (Rows > RCnt )
                            ExecSQL::InsertRow( CurrentBase, Tbl$, ColumnTab$, "NONAME")  
                        EndIf                        
                        
                        Select ColumnTab$
                            Case "dbsvn"
                                ExecSQL::UpdateRow( CurrentBase, Tbl$, ColumnTab$, Startup::History(#True), RowID )
                                ;
                                ; Integer Update (GameBase)
;                            Case "EditSnap", "WordWrap", "EditWinY", "EditWinX", "EditWinW", "EditWinH", "LanguageID", "PlatformID", "Compatibility_PRG", "PortID", "SplitHeight", "GameID", "WPosX", "WPosY", "SortOrder", "SplitHeight", "WindowHeight", "wScreenShotGadget", "hScreenShotGadget", "fnSize", "fColor", "Italic", "IsBold", "UnLine", "Strike", "fontid"
                            Case "DockWindow", "TabAutoOpen", "EditSnap", "WordWrap", "EditWinY", "EditWinX", "EditWinW", "EditWinH", "LanguageID", "PlatformID", "Compatibility_PRG", "PortID", "SplitHeight", "GameID", "WPosX", "WPosY", "SortOrder", "SplitHeight", "WindowHeight", "wScreenShotGadget", "hScreenShotGadget", "fnSize", "fColor", "Italic", "IsBold", "UnLine", "Strike", "fontid"
                                 
                                Num = ExecSQL::iRow( DC::#DummyBase, Tbl$, ColumnTab$, 0, RowID, "", 1 )
                                ExecSQL::UpdateRow( CurrentBase, Tbl$, ColumnTab$, Str(Num) ,RowID )
                                
                                SetGadgetText(DC::#Text_004,"Update: Base "+ Tbl$ + "/ " + ColumnTab$ + ": "+ Str(Num) )  
                                ;
                                ; Text Update         
                            Default      
                                Txt = ExecSQL::nRow( DC::#DummyBase, Tbl$, ColumnTab$, "", RowID, "", 1)
                                      ExecSQL::UpdateRow( CurrentBase, Tbl$, ColumnTab$, Txt, RowID )
                                
                                SetGadgetText(DC::#Text_004,"Update: Base "+ Tbl$ + "/ " + ColumnTab$ + ": "+ Txt )                                
                        EndSelect
                        
                    Next ColumnIndex
                    
                Next  RowID  
                
                sCollection.s = ""
                nCollection.i = 0

                
                For RowID = 1 To Rows
                    
                    For ColumnIndex = 1 To Cows
                        
                        ColumnTab$ = StringField(Col$, ColumnIndex, ",")                     
                        
                        Select ColumnTab$
                                ;
                                ; Integer Update (GameBase)
                            Case "DockWindow", "TabAutoOpen", "EditSnap", "WordWrap", "EditWinY", "EditWinX", "EditWinW", "EditWinH", "LanguageID", "PlatformID", "Compatibility_PRG", "PortID", "SplitHeight", "GameID", "WPosX", "WPosY", "SortOrder", "SplitHeight", "WindowHeight", "wScreenShotGadget", "hScreenShotGadget", "fnSize", "fColor", "Italic", "IsBold", "UnLine", "Strike", "fontid"
                                
                                Num = ExecSQL::iRow( CurrentBase, Tbl$, ColumnTab$, 0, RowID, "", 1 )
                                nCollection + Num                                 
                                ;
                                ; Text Update         
                            Default      
                                Txt = ExecSQL::nRow( CurrentBase, Tbl$, ColumnTab$, "", RowID, "", 1)
                                sCollection + Txt                             
                        EndSelect
                        
                    Next ColumnIndex
                    
                    If ( nCollection = 0 And  sCollection = "" )
                        ExecSQL::DeleteRow(CurrentBase , Tbl$, RowID)
                        SetGadgetText(DC::#Text_004,"Clean: Base - Delete RowID "+ Str(RowID) + " From " + Tbl$) 
                    EndIf    
                    
                    sCollection.s = ""
                    nCollection.i = 0                    
                Next  RowID                  
            EndIf                
        EndIf 

        ExecSQL::CloseDB( DC::#DummyBase, BackupFile$ ): HideGadget(TextInfoObj,1)  
        
    EndProcedure        
    ;****************************************************************************************************************************************************
    ;    
    ; Erstellt die Datenbanken
    ;       
    Procedure  Update_Base()
        
        
        OpenLoad_Base_Game(DB_Migrate::*LHBackupDB\Base_Game, DC::#Database_001, "Gamebase")
        OpenLoad_Base_Game(DB_Migrate::*LHBackupDB\Base_Game, DC::#Database_001, "Language")
        OpenLoad_Base_Game(DB_Migrate::*LHBackupDB\Base_Game, DC::#Database_001, "Platform")
        OpenLoad_Base_Game(DB_Migrate::*LHBackupDB\Base_Game, DC::#Database_001, "Programs")
        OpenLoad_Base_Game(DB_Migrate::*LHBackupDB\Base_Game, DC::#Database_001, "Setfonts")
        OpenLoad_Base_Game(DB_Migrate::*LHBackupDB\Base_Game, DC::#Database_001, "Settings")          

        
    EndProcedure    
    
    
    
    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 85
; FirstLine = 36
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\