
CompilerIf #PB_Compiler_IsMainFile
    
        UseSQLiteDatabase()
        UseJPEG2000ImageDecoder():UseJPEG2000ImageEncoder()
        UseJPEGImageDecoder(): UseJPEGImageEncoder()
        UsePNGImageDecoder(): UsePNGImageEncoder()
        UseTGAImageDecoder(): UseTIFFImageDecoder()
CompilerEndIf     
    
DeclareModule ExecSQL
    
    UseSQLiteDatabase()
    
    Enumeration 598 Step 1
        #_BlobImage        
    EndEnumeration    
    EnumEnd =  599
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
    Debug #TAB$ + "Constansts Enumeration : 0598 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: ExecSQL::(Module), BlobImage)"    
    
    Structure DATABASE_RETURN
        nRowID.i
        Column$
        Value_$
    EndStructure 
    
    Structure DATABASE_SHRINK
        DatabaseContant.i
        Database___File.s
        Database_Thread.i
        Result.i
    EndStructure    
    
    Structure DATABASE_INTEGRITY
        DatabaseContant.i
        Database___File.s
        Database_Thread.i
    EndStructure  
    
    Structure DATABASE_SEARCH
        nRowID.i
        Column$
        ExctMatch$; Case Sensitive
        NxctMatch$; Not Case sensitive
        BestMatch$; Änliche
        GoodMatch$; Ähnliche Weite entfernt
    EndStructure 
    
    Global NewList _IOSQL.DATABASE_RETURN()
    Global NewList _SHSQL.DATABASE_SHRINK()   
    Global NewList _FISQL.DATABASE_SEARCH()
    Global NewList _INSQL.DATABASE_INTEGRITY() 
    
    Global ShrinkThreadID = 0
    Define.DATABASE_SHRINK _SHSQL
    Global IntegrityThreadID = 0
    Global IntegrityThreadX$ = ""
    Define.DATABASE_INTEGRITY _INSQL    
    
    Declare.s StringFix(StringText$, TrimSpaces = #True)
    Declare.s OpenDB(Database,File$,User$="",Password$="")
    Declare.s CloseDB(Database,File$,User$="",Password$="")
    Declare.s TuneDB(Database)
    Declare.i ClearDB(Database,Table$,Datei$)
    Declare.i Shrink(Database,Datei$)
    Declare.i Integritycheck(Database,Datei$)

    
    Declare.s CreateTable(Database,Table$,Index=#False)
    Declare.l CheckTable(Database,Table$) 
    Declare.s DropTable(Database,Table$)
    Declare.s AddColumn(Database,Table$,Column$,Index=#False)
    Declare.s GetColumns(Database,Table$)
    
    Declare.i CountRows(Database,Table$,Column$="*")
    Declare.s nRow(Database,Table$,Column$,Value$,RowID=0,PointToColumn$="",Simple=0, Where$="id",DebugCmd=#False) 
    Declare.i nRows(Database,Table$,Column$, List _IOSQL.DATABASE_RETURN(),RowID=0,ODBY$="",ASC$="asc")
    Declare.i iRow(Database,Table$,Column$,Value=0,RowID=0,PointToColumn$="",Simple=0, Where$="id",DebugCmd=#False) 
    Declare.s lRows(Database,Table$,Column$,iMin,iMax,List _IOSQL.DATABASE_RETURN(),ODBY$="",ASC$="asc")

    Declare.s UpdateRow(Database,Table$,Column$,Value$,RowID=0,PointToValue$="",PointToColumn$="",FinishDB=1, TrimSpaces.i = #True)
    Declare.s InsertRow(Database,Table$,Column$,Value$="",WhereID=#False,ROWID=#Null,ManualMode=0)
    Declare.s DeleteRow(Database,Table$,RowID,Column$="id")
    Declare.l LastRowID(Database,Table$)
    Declare.l MaxRowID(Database,Table$)

    Declare   ImageGet(Database,Table$,Column$,RowID,DefaultID$="id")   
    Declare.s ImageSet(Database,Table$,Column$,ImageFile$,RowID=0,MemoryMode=0,MemoryFile=0,DefaultID$="id")
    
    Declare.s SearchDB(Database,Table$,Find$,QueryColumn$,OrderColumn$,List _FISQL.DATABASE_SEARCH(),Ascent$="asc",Excakt=#False)
EndDeclareModule
Module ExecSQL
    
    Global DatabaseMutex.l = CreateMutex()

    Macro RowLIstIO(Index)
        
        
        If Len(DatabaseColumnName(Database,Index)) = 0
        ElseIf Len(GetDatabaseString(Database,Index)) = 0
        ElseIf Val(GetDatabaseString(Database,0)) = 0    
        Else 
            AddElement(_IOSQL())
            _IOSQL()\nRowID  = Val(GetDatabaseString(Database,0))  
;             Debug "Index: " +Str(Val(GetDatabaseString(Database,0)))
            
            _IOSQL()\Column$ = DatabaseColumnName(Database,Index)
;             Debug "DatabaseColumn: " +DatabaseColumnName(Database,Index)
            
            _IOSQL()\Value_$ = GetDatabaseString(Database,Index) 
;             Debug "DatabaseString: " + GetDatabaseString(Database,Index) 
        EndIf
    EndMacro
        
    ;***************************************************************************************************   
    ;    
     Procedure.s StringFix(StringText$, TrimSpaces = #True)
         
         Protected cout
         
         cout = CountString(StringText$,Chr(39))                        
         Select cout
             Case 0
             Default
                 StringText$ = ReplaceString(StringText$,Chr(39),Chr(39)+Chr(39),0,1,cout) 
                 
         EndSelect
         
         If ( TrimSpaces = #True ) 
             StringText$ = Trim(StringText$)
         EndIf
         
         ProcedureReturn StringText$
     EndProcedure   
  
    ;***************************************************************************************************   
    ;
    Procedure ShowError(erro$)
        If Not erro$ = ""            
            Debug "============ DATABASE ERROR: "+erro$
        EndIf        
    EndProcedure    
       
    ;***************************************************************************************************   
    ;
    ;Öffnen der Datenbank
    Procedure.s OpenDB(Database,File$,User$="",Password$="")
        Protected iResult, Size, error$
        
        Size = FileSize(File$)
        If (Size = -1)
            ProcedureReturn "database not found '"+File$+"'":Debug "database not found '"+File$+"'"
        EndIf
        
            
        iResult = OpenDatabase(Database, File$, "", "", #PB_Database_SQLite)
       
        error$  = DatabaseError() 
        Select iResult
            Case 0                
                ShowError(error$): ProcedureReturn error$
            Default
                ShowError(error$): ProcedureReturn error$
        EndSelect
    EndProcedure    
    ;***************************************************************************************************   
    ;
    ;Schliessen der Datenbank       
    Procedure.s CloseDB(Database,File$,User$="",Password$="")
        Protected error$
        If OpenDatabase(Database, File$, "", "", #PB_Database_SQLite)
             CloseDatabase(Database)
             error$ = DatabaseError() 
         EndIf
         ShowError(error$): ProcedureReturn error$
     EndProcedure   
    ;***************************************************************************************************   
    ;
    ;Optimieren der Datenbank      
    Procedure.s TuneDB(Database)
        ;DatabaseUpdate(Database, "PRAGMA SHOW_DATATYPES=ON;")
        ;DatabaseUpdate(Database, "PRAGMA checkpoint_fullfsync=true;")
        DatabaseUpdate(Database, "PRAGMA synchronous=0;")        
        DatabaseUpdate(Database, "PRAGMA journal_mode = OFF;")        
        DatabaseUpdate(Database, "PRAGMA locking_mode = EXCLUSIVE;")
        DatabaseUpdate(Database, "PRAGMA temp_store = 2;")       
        DatabaseUpdate(Database, "PRAGMA count_changes = OFF;")       
        DatabaseUpdate(Database, "PRAGMA PAGE_SIZE = 4096;")        
        DatabaseUpdate(Database, "PRAGMA default_cache_size=1;")
        DatabaseUpdate(Database, "PRAGMA cache_size=5120 ;")
        DatabaseUpdate(Database, "PRAGMA compile_options;")
        DatabaseUpdate(Database, "PRAGMA auto_vacuum=FULL;")  
        DatabaseUpdate(Database, "PRAGMA secure_delete= TRUE;")
        DatabaseUpdate(Database, "PRAGMA mmap_size=1073741824;")
        DatabaseUpdate(Database, "PRAGMA integrity_check= OFF;")
        DatabaseUpdate(Database, "PRAGMA default_temp_store = 2;")
        DatabaseUpdate(Database, "PRAGMA threads  = "+ProcessEX::SetAffinityCPUS(0,1)+";")          


        error$  = DatabaseError() 
        ShowError(error$): ProcedureReturn error$
    EndProcedure     
    ;***************************************************************************************************   
    ;
    ;Gibt die  Anzhal der Spalten zurück
    Procedure.i CountRows(Database,Table$,Column$="*")
        Protected RowID
       
        If DatabaseQuery(Database,"SELECT COUNT("+Column$+") FROM '"+Table$+"'")
            While NextDatabaseRow(Database)
                RowID = Val(GetDatabaseString(Database, 0))
            Wend
         EndIf
        FinishDatabaseQuery(Database):ProcedureReturn RowID
    EndProcedure 
    
 ;***************************************************************************************************   
    ;
    ; Gibt die ein einzelnen Wert zurück (ALS INTEGER) nach dem Explizit in einer Spalte gesucht wird
    ; 
    ; Beispiel, die Simple Metrode:
    ; Result = nRow(#Database,"Compatbility","File","",2,"",1)
    ; Holt vom Table "Compatbility" in Reihe 2 ,in Spalte "File" den Eintrag
    ;
    ; Beispiel, die Erweiterte Methode: 
    ; 'Result = nRow(#Database,"Compatbility","File","Das Ergebnis",2,"System")'
    ; Springt im Table "Compatbility" in Reihe 2 zum Column "File" und holt das erebnis aus dem Column "System" mit Vergleich
    ;
    ; Beispiel, die Erweiterte Methode: 
    ; 'Result = nRow(#Database,"Compatbility","File","",2,"System")'
    ; Springt im Table "Compatbility" in Reihe 2 zum Column "File" und holt das erebnis aus dem Column "System" ohne Vergleich    
    

    Procedure.i iRow(Database,Table$,Column$,Value=0,RowID=0,PointToColumn$="",Simple=0, Where$="id",DebugCmd=#False) 
        Protected error$, sQuery

        If Len(Column$) = 0: Column$ = "*": EndIf
        
        Select RowID
            Case 0
                
                sQuery = DatabaseQuery(Database, "SELECT "+Column$+" FROM '"+Table$+"'")
            Default
                sQuery = DatabaseQuery(Database, "SELECT "+Column$+" FROM '"+Table$+"' WHERE "+Where$+"="+RowID)
                If (DebugCmd = #True)
                    
                    
                    Debug "Command: - Select "+Column$+" FROM '"+Table$+"' WHERE "+Where$+"="+RowID
                    Debug "Command: sQuery = " +Str(sQuery) + Chr(13)
                EndIf            
                
        EndSelect
        If (sQuery <> 0)     
            
            Select RowID
                Case 0
                    
                    While NextDatabaseRow(Database)
                        
                        iRowID  = GetDatabaseLong(Database, 0)
                        If RowID = 0
                            iResult = GetDatabaseLong(Database,DatabaseColumnIndex(Database, Column$))
                            
                            If (Simple = 1) And ( Value = 0) 
                                error$  = DatabaseError()
                                FinishDatabaseQuery(Database)
                                ShowError(error$)
                                If error$ <> ""
                                Else
                                    ProcedureReturn iResult
                                EndIf
                            EndIf
                            
                            If (Value <> 0) And (Value = iResult) And (Simple = 0)
                                iResult = GetDatabaseLong(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                error$  = DatabaseError()
                                FinishDatabaseQuery(Database)
                                ShowError(error$)
                                If error$ <> "":
                                Else
                                    ProcedureReturn iResult
                                EndIf
                            EndIf
                            
                            If (Value = 0) And (Simple = 0)
                                iResult = GetDatabaseLong(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                error$  = DatabaseError()
                                FinishDatabaseQuery(Database)
                                ShowError(error$)
                                If error$ <> "":
                                Else
                                    ProcedureReturn iResult
                                EndIf
                            EndIf                
                        EndIf
                    Wend                
                
                Default    
                    Select Simple
                        Case 0
                            While NextDatabaseRow(Database)
                                
                                iRowID  = GetDatabaseLong(Database, 0)
                                Select Val(iRowID$)
                                    Case RowID
                                        ;******************************************************************************************
                                        ;
                                        Select Value
                                            Case 0
                                                iResult = GetDatabaseLong(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                                error$  = DatabaseError()
                                                FinishDatabaseQuery(Database)
                                                ShowError(error$)
                                                If error$ <> "":
                                                Else
                                                    ProcedureReturn iResult
                                                EndIf
                                            Default 
                                                iResult = GetDatabaseLong(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                                error$  = DatabaseError()
                                                FinishDatabaseQuery(Database)
                                                ShowError(error$)
                                                If error$ <> "":
                                                Else
                                                    ProcedureReturn iResult
                                                EndIf 
                                        EndSelect                                                
                                EndSelect                                
                            Wend            
                        Case 1      
                            Select RowID
                                Case 0
                                    While NextDatabaseRow(Database)
                                        iRowID  = GetDatabaseLong(Database, 0)
                                        If iRowID = RowID
                                            Break; 
                                        EndIf    
                                    Wend      
                                    iResult = GetDatabaseLong(Database,DatabaseColumnIndex(Database, Column$))
                                Default
                                    NextDatabaseRow(Database)
                                    iResult  = GetDatabaseLong(Database, 0) 
                            EndSelect
                            
                            error$  = DatabaseError()
                            FinishDatabaseQuery(Database)
                            ShowError(error$)
                            If Len(error$) <> 0                             
                            EndIf    
                            ProcedureReturn iResult
                            
                    EndSelect
 
            EndSelect         
            EndIf   
        ProcedureReturn 0
    EndProcedure        
    ;***************************************************************************************************   
    ;
    ; Gibt die ein einzelnen Wert zurück nach dem Explizit in einer Spalte gesucht wird
    ; 
    ; Beispiel, die Simple Metrode:
    ; Result = nRow(#Database,"Compatbility","File","",2,"",1)
    ; Holt vom Table "Compatbility" in Reihe 2 ,in Spalte "File" den Eintrag
    ;
    ; Beispiel, die Erweiterte Methode: 
    ; 'Result = nRow(#Database,"Compatbility","File","Das Ergebnis",2,"System")'
    ; Springt im Table "Compatbility" in Reihe 2 zum Column "File" und holt das erebnis aus dem Column "System" mit Vergleich
    ;
    ; Beispiel, die Erweiterte Methode: 
    ; 'Result = nRow(#Database,"Compatbility","File","",2,"System")'
    ; Springt im Table "Compatbility" in Reihe 2 zum Column "File" und holt das erebnis aus dem Column "System" ohne Vergleich    
    

    Procedure.s nRow(Database,Table$,Column$,Value$,RowID=0,PointToColumn$="",Simple=0, Where$="id",DebugCmd=#False) 
        Protected error$, sQuery

        If Len(Column$) = 0: Column$ = "*": EndIf
        
        Select RowID
            Case 0
                
                sQuery = DatabaseQuery(Database, "SELECT "+Column$+" FROM '"+Table$+"'")
            Default
                sQuery = DatabaseQuery(Database, "SELECT "+Column$+" FROM '"+Table$+"' WHERE "+Where$+"="+RowID)
                If (DebugCmd = #True)
                    
                    
                    Debug "Command: - Select "+Column$+" FROM '"+Table$+"' WHERE "+Where$+"="+RowID
                    Debug "Command: sQuery = " +Str(sQuery) + Chr(13)
                EndIf            
                
        EndSelect
        If (sQuery <> 0)     
            
            Select RowID
                Case 0
                    
                    While NextDatabaseRow(Database)
                        
                        iRowID$  = GetDatabaseString(Database, 0)
                        If RowID = 0
                            iResult$ = GetDatabaseString(Database,DatabaseColumnIndex(Database, Column$))
                            
                            If (Simple = 1) And (Len(Value$) = 0) 
                                error$  = DatabaseError()
                                FinishDatabaseQuery(Database)
                                ShowError(error$)
                                If error$ <> "": ProcedureReturn error$
                                Else
                                    ProcedureReturn iResult$
                                EndIf
                            EndIf
                            
                            If (Len(Value$) <> 0) And (Value$ = iResult$) And (Simple = 0)
                                iResult$ = GetDatabaseString(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                error$  = DatabaseError()
                                FinishDatabaseQuery(Database)
                                ShowError(error$)
                                If error$ <> "": ProcedureReturn error$
                                Else
                                    ProcedureReturn iResult$
                                EndIf
                            EndIf
                            
                            If (Len(Value$) = 0) And (Simple = 0)
                                iResult$ = GetDatabaseString(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                error$  = DatabaseError()
                                FinishDatabaseQuery(Database)
                                ShowError(error$)
                                If error$ <> "": ProcedureReturn error$
                                Else
                                    ProcedureReturn iResult$
                                EndIf
                            EndIf                
                        EndIf
                    Wend                
                
                Default    
                    Select Simple
                        Case 0
                            While NextDatabaseRow(Database)
                                
                                iRowID$  = GetDatabaseString(Database, 0)
                                Select Val(iRowID$)
                                    Case RowID
                                        ;******************************************************************************************
                                        ;
                                        Select Len(Value$) 
                                            Case 0
                                                iResult$ = GetDatabaseString(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                                error$  = DatabaseError()
                                                FinishDatabaseQuery(Database)
                                                ShowError(error$)
                                                If error$ <> "": ProcedureReturn error$
                                                Else
                                                    ProcedureReturn iResult$
                                                EndIf
                                            Default 
                                                iResult$ = GetDatabaseString(Database,DatabaseColumnIndex(Database, PointToColumn$))
                                                error$  = DatabaseError()
                                                FinishDatabaseQuery(Database)
                                                ShowError(error$)
                                                If error$ <> "": ProcedureReturn error$
                                                Else
                                                    ProcedureReturn iResult$
                                                EndIf 
                                        EndSelect                                                
                                EndSelect                                
                            Wend            
                        Case 1      
                            Select RowID
                                Case 0
                                    While NextDatabaseRow(Database)
                                        iRowID$  = GetDatabaseString(Database, 0)
                                        If Val(iRowID$) = RowID
                                            Break; 
                                        EndIf    
                                    Wend      
                                    iResult$ = GetDatabaseString(Database,DatabaseColumnIndex(Database, Column$))
                                Default
                                                                            NextDatabaseRow(Database)
                                                                            iResult$  = GetDatabaseString(Database, 0) 
                                                                    EndSelect
                            
                            error$  = DatabaseError()
                            FinishDatabaseQuery(Database)
                            ShowError(error$)
                            If Len(error$) <> 0
                                ProcedureReturn error$
                            EndIf    
                            ProcedureReturn iResult$
                            
                    EndSelect
 
            EndSelect         
            EndIf   
        ProcedureReturn error$
    EndProcedure    
    ;***************************************************************************************************   
    ;
    ; Gibt die Strings zurück die man sucht via ID, Return = 1/OK, 0=Nicht OK 
    ;   Database                    = #Database
    ;   Table$                      = "Gamebase"
    ;   Column$                     = "GenreA" oder "TitleA,Develop,GenreA,GenreB" (id wird nicht benötigt)
    ;   List IOSQL.DATABASE_RETURN()= Übergebene Liste in der sich die Daten aufhalten
    ;   RowID.i                     = Id nach der gescuht wird
    ;   ODBY$                       = Wird ein (1) Column$ angeben. Dann wird ein OrderBy mit ausgeführt
    ;   ASC$="asc"                  = (asc) Austeigend oder (desc) Absteigend
    ;
    Procedure.i nRows(Database,Table$,Column$, List _IOSQL.DATABASE_RETURN(),RowID=0,ODBY$="",ASC$="asc")
        Protected iResult$, iMax, Query$
        
        iMax = ListIndex(_IOSQL()): If (iMax<>0): ClearList(_IOSQL()):EndIf        
        iMax = CountString(Column$,","):If (iMax >= 1):iMax = iMax+1:EndIf
        
        If Len(ODBY$) <> 0
            ODBY$ = " ORDER BY "+ODBY$+""
            If ASC$ = "asc" : ODBY$ = ODBY$ + " asc"    : EndIf
            If ASC$ = "desc": ODBY$ = ODBY$ + " desc"   : EndIf
        EndIf        
        
        If (Column$ = "*")
            Query$ = "Select * FROM '"+Table$+"' WHERE id="+Str(RowID)+ODBY$
        Else
            Query$ = "Select id,"+Column$+" FROM '"+Table$+"' WHERE id="+Str(RowID)+ODBY$
        EndIf
        
        If DatabaseQuery(Database,Query$)
            If (Column$ = "*"): iMax = DatabaseColumns(Database):EndIf
            
            While NextDatabaseRow(Database)
                If (RowID = Val(GetDatabaseString(Database,0)))
                    
                    Select iMax
                        Case 0                              
                            RowLIstIO(1)                            
                            
                        Case 1 To iMax
                            
                            For d = 1 To iMax
                                RowLIstIO(d)
                            Next
                            FinishDatabaseQuery(Database):ProcedureReturn #True
                    EndSelect                     
                EndIf
            Wend
            FinishDatabaseQuery(Database)
        EndIf
        ProcedureReturn #False
    EndProcedure    
    ;***************************************************************************************************
    ;
    ; Gibt ine Vollständige Liste aus
    ;   Database                    = #Database
    ;   Table$                      = "Gamebase"
    ;   Column$                     = "GenreA" oder "TitleA,Develop,GenreA,GenreB"(id wird nicht benötigt)
    ;   iMin                        = Fange an bei ... Integer
    ;   iMax                        = Bis ... Integer
    ;   List IOSQL.DATABASE_RETURN()= Übergebene Liste in der sich die Daten aufhalten
    ;   ODBY$                       = Wird ein (1) Column$ angeben. Dann wird ein OrderBy mit ausgeführt
    ;   ASC$="asc"                  = (asc) Austeigend oder (desc) Absteigend
    Procedure.s lRows(Database,Table$,Column$,iMin,iMax,List _IOSQL.DATABASE_RETURN(),ODBY$="",ASC$="asc")
        Protected iResult$,MaxCol,Query$,liMax, VerifyColName$, SafeColumnName$
        
        liMax = ListIndex(_IOSQL()): If (liMax<>0): ClearList(_IOSQL()):EndIf        
        MaxCol = CountString(Column$,",")
        
;         If Len(ODBY$) <> 0
;             SafeColumnName$ = ODBY$
;             ODBY$ = " ORDER BY '"+ODBY$+"'"
;             If ASC$ = "asc" : ODBY$ = ODBY$ + " ASC"    : EndIf
;             If ASC$ = "desc": ODBY$ = ODBY$ + " DESC"   : EndIf
;         EndIf
         
        If (Column$ = "*")
            Query$ = "Select * FROM '"+Table$+"'";+ODBY$            
        Else
            Query$ = "Select id,"+Column$+" FROM '"+Table$+"'";+ODBY$
        EndIf
        
        If iMax = 0: Debug "ERROR lRows(): 'iMax' hat 0 Columns": ProcedureReturn: EndIf    
        
        If DatabaseQuery(Database,Query$)
            If (Column$ = "*")
                MaxCol = DatabaseColumns(Database)
            EndIf
            
            If (MaxCol <> 0);Len(ODBY$) <> 0 And
                For i = 1 To MaxCol
                    VerifyColName$ = DatabaseColumnName(Database,i)
                    Debug "Verify Column Name: "+ VerifyColName$
                    If LCase(SafeColumnName$) =LCase(VerifyColName$)
                        Break
                    EndIf
                    If i = MaxCol
                        Debug "OrderBy Column Name Nicht Gefunden: "+ODBY$
                        FinishDatabaseQuery(Database):ProcedureReturn
                    EndIf
                Next
           EndIf
                
                
            For i = iMin To iMax Step 1
                NextDatabaseRow(Database)
                Select MaxCol
                    Case 0                              
                        RowLIstIO(1)                         
                    Case 1 To MaxCol
                        For d = 1 To MaxCol
                            RowLIstIO(d)
                        Next
                EndSelect
                
                If (i = iMax)
                   FinishDatabaseQuery(Database): Break
                EndIf               
            Next
            
            If ( ASC$ = "asc" )  And ( Len(ODBY$) >= 1 )           
                SortStructuredList(_IOSQL() , #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf( DATABASE_RETURN\Value_$),  TypeOf(DATABASE_RETURN\Value_$))                 
            ElseIf ( ASC$ = "desc" )  And ( Len(ODBY$) >= 1 )       
                SortStructuredList(_IOSQL() , #PB_Sort_Descending|#PB_Sort_NoCase, OffsetOf( DATABASE_RETURN\Value_$),  TypeOf(DATABASE_RETURN\Value_$)) 
            EndIf
            
            ProcedureReturn
                 
        EndIf
                
    EndProcedure    
    ;***************************************************************************************************
    ;
    ; Verändet und fügt ein Column hinzu 
    ;
    Procedure.s SetIndex(IndexColumn$)
                
        Protected iMax,iLng,iPos, IndexColumn_Original$      
        
        Structure DATABASE_TYPENAMES
            Index.i
            TYPE.s
        EndStructure 
        NewList DataNames.DATABASE_TYPENAMES() 
        
        IndexColumn_Original$ = IndexColumn$
        
        ; Zähle Leer Zeichen
        iMax = CountString(IndexColumn$,Chr(32))
        If iMax <> 0
            For i = 1 To iMax
                iLng = Len(IndexColumn$)
                
                iPos = FindString(IndexColumn$,Chr(32))
                
                IndexColumn$ = Right(IndexColumn$,iLng-iPos)
            Next
        EndIf
        
        IndexColumn_Original$ = Left(IndexColumn_Original$,Len(IndexColumn_Original$)-Len(IndexColumn$))
        IndexColumn_Original$ = Trim(IndexColumn_Original$)
        
        ; Zähle Klammern '('
        iMax = CountString(IndexColumn$,Chr(40))
        If iMax <> 0
            For i = 1 To iMax
                iLng = Len(IndexColumn$)
                
                iPos = FindString(IndexColumn$,Chr(40))
                
                IndexColumn$ = Left(IndexColumn$,iPos-1)
            Next        
        EndIf

        
        
         
        
        AddElement(DataNames()):DataNames()\TYPE = "NULL"
       
        AddElement(DataNames()):DataNames()\TYPE= "BLOB" 
        
        AddElement(DataNames()):DataNames()\TYPE = "CHAR"        ;TEXT DATATYPES
        AddElement(DataNames()):DataNames()\TYPE = "CLOB"
        AddElement(DataNames()):DataNames()\TYPE = "TEXT"
        AddElement(DataNames()):DataNames()\TYPE = "NCHAR"
        AddElement(DataNames()):DataNames()\TYPE = "NATIVE CHARACTER"              
        AddElement(DataNames()):DataNames()\TYPE = "VARYING CHARACTER" 
        AddElement(DataNames()):DataNames()\TYPE = "NATIONAL VARYING CHARACTER"         
        AddElement(DataNames()):DataNames()\TYPE = "VARCHAR" 
        AddElement(DataNames()):DataNames()\TYPE = "NVARCHAR"
        
        AddElement(DataNames()):DataNames()\TYPE = "REAL"         ;REAL DATATYPES
        AddElement(DataNames()):DataNames()\TYPE = "FLOAT" 
        AddElement(DataNames()):DataNames()\TYPE = "DOUBLE PRECISION"        
        AddElement(DataNames()):DataNames()\TYPE = "DOUBLE"
        
        AddElement(DataNames()):DataNames()\TYPE = "DECIMAL"      ;NUMERIC
        AddElement(DataNames()):DataNames()\TYPE = "DATE"
        AddElement(DataNames()):DataNames()\TYPE = "DATETIME"       
        AddElement(DataNames()):DataNames()\TYPE = "TINYINT"
        AddElement(DataNames()):DataNames()\TYPE = "SMALLINT"
        AddElement(DataNames()):DataNames()\TYPE = "MEDIUMINT"        
        AddElement(DataNames()):DataNames()\TYPE = "UNIQUE"        
        AddElement(DataNames()):DataNames()\TYPE = "INTEGER"
        AddElement(DataNames()):DataNames()\TYPE = "BIGINT"

        AddElement(DataNames()):DataNames()\TYPE = "BOOLEAN"
 
        AddElement(DataNames()):DataNames()\TYPE = "INT"
        AddElement(DataNames()):DataNames()\TYPE = "TIMESTAMP"
        AddElement(DataNames()):DataNames()\TYPE = "NUMERIC"
        AddElement(DataNames()):DataNames()\TYPE = "UNSIGNED BIG INT"
        AddElement(DataNames()):DataNames()\TYPE = "INT2"
        AddElement(DataNames()):DataNames()\TYPE = "INT8"
  
        AddElement(DataNames()):DataNames()\TYPE= "NONE"  
        
        ResetList(DataNames())
        While NextElement(DataNames())
            IndexName$  = ""
            DataName$   = DataNames()\TYPE
            
            Position    = FindString(IndexColumn$,DataName$,1,#PB_String_NoCase)
            If Position <> 0
                ClearList(DataNames()):FreeList(DataNames()):ProcedureReturn IndexColumn_Original$
            EndIf          
        Wend
        ClearList(DataNames()):FreeList(DataNames()):ProcedureReturn  ""       
    EndProcedure
    ;***************************************************************************************************
    ;    
    Procedure.s AddColumn(Database,Table$,Column$,Index=#False)
        Protected error$, IndexName$
        
        
        DatabaseUpdate(Database, "BEGIN EXCLUSIVE TRANSACTION") 
        
        Cout = CountString(Column$,",")
        If (Cout >= 1)
            For i = 1 To Cout+1
                
                IndexColumn$ = StringField(Column$,i,",")
                DatabaseUpdate(Database, "ALTER TABLE '"+Table$+"' ADD COLUMN "+IndexColumn$+"")
                error$ = DatabaseError()
                If Index = #True
                    If (error$ = "")
                        
                        IndexName$ = SetIndex(IndexColumn$)
                        If (IndexName$)                
                            DatabaseUpdate(Database, "CREATE INDEX IF NOT EXISTS 'IDX_"+Table$+"_"+IndexName$+"' ON '"+Table$+"' ("+IndexName$+" ASC)")  
                            error$ = DatabaseError() 
                            DatabaseUpdate(Database, "PRAGMA table_info('"+Table$+"')") 
                        EndIf
                        
                    EndIf
                EndIf
                DatabaseUpdate(Database, "COMMIT TRANSACTION")
            Next
        Else
            DatabaseUpdate(Database, "ALTER TABLE '"+Table$+"' ADD COLUMN "+Column$+"")
            error$ = DatabaseError()
            If Index = #True
                If (error$ = "")
                    IndexName$ = SetIndex(IndexColumn$)
                    If (IndexName$)                      
                        DatabaseUpdate(Database, "CREATE INDEX IF NOT EXISTS 'IDX_"+Table$+"_"+IndexName$+"' ON '"+Table$+"' ("+IndexName$+" ASC)")  
                        error$ = DatabaseError()
                        DatabaseUpdate(Database, "PRAGMA table_info('"+Table$+"')")
                    EndIf
                EndIf
            EndIf
            DatabaseUpdate(Database, "COMMIT TRANSACTION")       
        EndIf           

        DatabaseUpdate(Database, "COMMIT TRANSACTION"): ShowError(error$): ProcedureReturn error$
    EndProcedure
    ;***************************************************************************************************
    ;
    ; Fügt ein Table hinzu wenn es ih nicht gibt
    ;   
    Procedure.s CreateTable(Database,Table$,Index=#False)  
        Protected error$
        
        DatabaseUpdate(Database, "BEGIN EXCLUSIVE TRANSACTION")         
        DatabaseUpdate(Database, "CREATE TABLE IF NOT EXISTS '"+Table$+"' (id INTEGER PRIMARY KEY)")
        error$ = DatabaseError()
        If Len(error$) = 0
            If Index = #True
                DatabaseUpdate(Database, "CREATE INDEX IF NOT EXISTS 'IDX_"+Table$+"_ID' ON '"+Table$+"' (id)")
                error$ = DatabaseError()
            EndIf
        EndIf
        DatabaseUpdate(Database, "PRAGMA table_info('"+Table$+"')") 
        DatabaseUpdate(Database, "COMMIT TRANSACTION")

        ShowError(error$): ProcedureReturn error$
    EndProcedure 
    ;***************************************************************************************************
    ;
    ; Fügt ein Table hinzu wenn es ih nicht gibt
    ;       
    Procedure.l CheckTable(Database,Table$)      
        
        Protected TableRow = 0
        If DatabaseQuery(Database, "Select sql, name FROM sqlite_master WHERE type='table' AND name='"+Table$+"' COLLATE NOCASE") 
           While NextDatabaseRow(Database)
               TableRow = 1
               Break
           Wend    
           FinishDatabaseQuery(Database)
           Select TableRow
                Case 0
                    Debug "ExecSQL CheckTable(): Table nicht gefunden "+Table$
                Case 1 
                    Debug "ExecSQL CheckTable(): Table Existiert "+Table$
                Default                    
            EndSelect                    
            ProcedureReturn TableRow
        EndIf
    EndProcedure
    ;***************************************************************************************************
    ;
    ; Löscht ein Table aus der Datenbank
    ; 
    Procedure.s DropTable(Database,Table$)
        Protected error$
        DatabaseUpdate(Database, "BEGIN EXCLUSIVE TRANSACTION")  
        DatabaseUpdate(Database, "DROP TABLE IF EXISTS '"+Table$+"'")
        error$ = DatabaseError()
        DatabaseUpdate(Database, "COMMIT TRANSACTION")         
        ShowError(error$): ProcedureReturn error$
    EndProcedure 
    ;***************************************************************************************************
    ;
    ; ändert eine Celle, Updated eine Celle
    ;   Database        = #Database
    ;   Table$          = "Gamebase"
    ;   Column$         = "GenreA"
    ;   Value$          = Neuer Inhalt,Gesuchter Inhalt
    ;   PointToColumn$  = Die Reihe in der sich der Inhalt änern soll wenn RowID=0 ist
    ;   RowID (Integer) = die ID , sollte hier 0 stehen wird  die Value& gesucht und der inhalt in
    ;                     PointToColumn$ geändert. Sonst muss eine RowID angeben werden wo sicher der
    ;                     inhalt IN Valiue& ändern soll
    ;  
    
    Procedure.s UpdateRow(Database,Table$,Column$,Value$,RowID=0,PointToValue$="",PointToColumn$="",FinishDB=1, TrimSpaces.i = #True)
        Protected error$, MaxRowID.i
        ;If (Len(Value$) = 0):ProcedureReturn "no Input": EndIf
        
        Value$ = StringFix(Value$, TrimSpaces)
        
        If RowID = 0
            MaxRows     = CountRows(Database,Table$,"*") 
            If MaxRows = 0: ProcedureReturn "": EndIf
            
            
            If DatabaseQuery(Database, "SELECT * FROM "+Table$+"")
               
                MaxColumns = DatabaseColumns(Database)
                For i = 1 To MaxRows Step 1
                    NextDatabaseRow(Database)
                    n_RowID = 0
                    For d = 1 To MaxColumns                             
                                                                               
                        
                        Value__String$ = GetDatabaseString(Database,d)
                        If LCase(Value__String$) = LCase(PointToValue$)
                            Column$ = PointToColumn$
                            n_RowID = Val(GetDatabaseString(Database,0))
                            Column$ = PointToColumn$: RowID   =  n_RowID
                            Break
                        EndIf
                    Next
                    If (n_RowID <> 0): Break: EndIf
                Next
            EndIf            
          EndIf                                                                          
          
          
;         MaxRowID = MaxRowID(Database,Table$)   
;         If MaxRowID = 0
;             error$ = "Database Update: Keine RowID ('s): im Table . benötigt wird Min 1 rowID (InsertRow Ausgeführt?)"
;             
;         EndIf    
          
        DatabaseUpdate(Database, "BEGIN EXCLUSIVE TRANSACTION")        
        DatabaseUpdate(Database, "UPDATE OR REPLACE '"+Table$+"' SET '"+Column$+"'='"+Value$+"' WHERE id="+Str(RowID)+"")
        error$ = DatabaseError()
        If Len(error$) <> 0
            Debug "Database Update: Table:'"+Table$+"' Column:'"+Column$+"' With Value: " +Value$
        EndIf    
        DatabaseUpdate(Database, "COMMIT TRANSACTION")        
        Select FinishDB
            Case 0
            Case 1
                FinishDatabaseQuery(Database)
        EndSelect
        ShowError(error$): ProcedureReturn error$
        
    EndProcedure  
    ;***************************************************************************************************
    ;
    ; Fügt neue Inhlate hinzu
    ;   Database                    = #Database
    ;   Table$                      = "Gamebase"
    ;   Column$                     = "GenreA"  oder "TitleA,Develop,GenreA,GenreB"
    ;   Value$                  = Neuer Inhalt (Muss mit der Anzahl der Column$ übereinstimmen) 
    ;   WhereID=#False              = Wenn #True muss bei ROWID=#Null die ID angebene werden
    ;   ManaulMode              = '', Semikolons in den Values müssen selbst angeben werden 
    Procedure.s InsertRow(Database,Table$,Column$,Value$="",WhereID=#False,ROWID=#Null,ManualMode=0)
        Protected error$, iMaxCol,iMaxInp
        
        If (Len(Value$) = 0):ProcedureReturn "": EndIf
        
        Value$ = StringFix(Value$)
        
        Select ManualMode
            Case 0        
                Value$  = "'"+Value$+"'"        
                
                iMaxCol = CountString(Column$,",")
                iMaxInp = CountString(Value$,",")
                
                If iMaxCol <> 0 And iMaxInp <> 0
                    
                    Value$ = ReplaceString(Value$, "," ,"','" ,#PB_String_NoCase,1,iMaxInp)                    
                EndIf
            Case 1
                
        EndSelect
        
        DatabaseUpdate(Database, "BEGIN;") 
        Select WhereID            
            Case #False
                DatabaseUpdate(Database, "INSERT INTO '"+Table$+"' (id,"+Column$+") VALUES (NULL,"+Value$+")")
                
            Case #True
                DatabaseUpdate(Database, "INSERT INTO '"+Table$+"' (id,"+Column$+") VALUES ("+Str(ROWID)+","+Value$+")")
        EndSelect
        error$ = DatabaseError()
        If Len(error$) <> 0
            Debug "Databse Update: "+Table$+"' (id,"+Column$+") with Value: " +Value$
        EndIf    
        DatabaseUpdate(Database, "COMMIT;")
        ShowError(error$): ProcedureReturn error$
    EndProcedure    
    ;***************************************************************************************************
    ;   Zeigt die Letzte RowID an
  
    Procedure.l LastRowID(Database,Table$)
        Protected RowID = 0
        
        If DatabaseQuery(Database, "SELECT last_insert_rowid()")
            NextDatabaseRow(Database)
            ProcedureReturn GetDatabaseLong(Database, 0)
        EndIf
        
        ProcedureReturn RowID
    EndProcedure          
    
    ;***************************************************************************************************
    ;   Zeigt die Letzte RowID an
  
    Procedure.l MaxRowID(Database,Table$)
        Protected RowID = 0
        
        If DatabaseQuery(Database, "Select MAX(_ROWID_) FROM " +Table$)
            NextDatabaseRow(Database)
            ProcedureReturn GetDatabaseLong(Database, 0)
        EndIf
        
        ProcedureReturn RowID
    EndProcedure 
    
    ;***************************************************************************************************
    ; Löschen einer Ganzen Celle <--------->
    ;
    Procedure.s DeleteRow(Database,Table$,RowID,Column$="id")
        Protected error$
        DatabaseUpdate(Database, "DELETE FROM "+Table$+" WHERE "+Column$+"="+RowID)
        error$ = DatabaseError(): ShowError(error$): ProcedureReturn error$        
    EndProcedure
    ;***************************************************************************************************
    ; Blob Images Rausholen
    ;   Database                    = #Database
    ;   Table$                      = "Gamebase"
    ;   Column$                     = "Pictures" 
    ;   RowID (Integer)             = die ID
    ;   Return Code                 = Der Inhalt des Speichers, FREEMEMORY nicht vergessen
    ;
    Procedure ImageGet(Database,Table$,Column$,RowID,DefaultID$="id")       
        Protected CellSize.q ,*DatabaseBlobMemory

        Query$ = "Select id,"+Column$+" FROM '"+Table$+"' WHERE "+DefaultID$+"="+Str(RowID)
                      
        If DatabaseQuery(Database,Query$)
            NextDatabaseRow(Database)
                
                CellType = DatabaseColumnType(Database,1)
                Select CellType
                    Case #PB_Database_Blob
                        CellSize = 0
                        CellSize = DatabaseColumnSize(Database, 1)
                                                                  
                        If (CellSize <> 0)                           
                            
                            DatabaseUpdate(Database, "PRAGMA cache_size="+CellSize+";") 
                            DatabaseUpdate(Database, "PRAGMA synchronous=0;")        
                            DatabaseUpdate(Database, "PRAGMA journal_mode = OFF;")               
                            DatabaseUpdate(Database, "PRAGMA temp_store = 2;")             
                            DatabaseUpdate(Database, "PRAGMA default_cache_size="+CellSize+";") 
                            DatabaseUpdate(Database, "PRAGMA mmap_size="+CellSize+";")
                            DatabaseUpdate(Database, "PRAGMA threads  = "+ProcessEX::SetAffinityCPUS(0,1)+";")                                
                            
                            
                            *DatabaseBlobMemory = AllocateMemory(CellSize,#PB_Memory_NoClear)                            
                            If *DatabaseBlobMemory
                                GetDatabaseBlob(Database, 1, *DatabaseBlobMemory, CellSize)
                                FinishDatabaseQuery(Database) 
                                ProcedureReturn  *DatabaseBlobMemory
                            EndIf  
                            FinishDatabaseQuery(Database)
                            ProcedureReturn 0
                        EndIf
                    Default
                        FinishDatabaseQuery(Database): ProcedureReturn 0
                EndSelect
            ;Wend
            FinishDatabaseQuery(Database): ProcedureReturn 0           
        EndIf
    EndProcedure 
    ;***************************************************************************************************
    ; Blob Images hinzufügen
    ;   Database                    = #Database
    ;   Table$                      = "Gamebase"
    ;   Column$                     = "Pictures"
    ;   ImageFile$                  = Datei Name des Bildes
    ;   RowID (Integer)             = die ID Wenn 0 wird ein 'INSERT INTO' ausgeführt sonst ein Update
    ;                                 der Celle
    ;   Return Code                 = Der Fehlermessage, sollte 0 sein
    ;
    Procedure.s ImageSet(Database,Table$,Column$,ImageFile$,RowID=0,MemoryMode=0,*MemoryFile=0,DefaultID$="id")
        Protected ImageFileSize, *memory, CellIsBlob=0, SqlUpate$ = "", iResult$, *MemoryHandle
        
        Select MemoryMode
                Case 0
                    ImageFileSize = FileSize(ImageFile$)
                     If ImageFileSize = -1 Or ImageFileSize = 0: ProcedureReturn "file found": EndIf
                 Case 1
                     *MemoryHandle = *MemoryFile
                     If *MemoryHandle = 0:  ProcedureReturn "Kein Bild im Speicher": EndIf
        EndSelect                     
                    
        
        If (RowID <> 0)
            Query$ = "Select id,"+Column$+" FROM '"+Table$+"' WHERE id="+Str(RowID)
                
            If DatabaseQuery(Database,Query$)
                While NextDatabaseRow(Database)
                    CellType = DatabaseColumnType(Database,1)
                    Select CellType
                        Case #PB_Database_Blob 
                            CellIsBlob=1
                        Default    
                            ProcedureReturn "cell is no blob"
                    EndSelect                        
                Wend
            EndIf
            
            SqlUpate$ = "UPDATE OR REPLACE '"+Table$+"' SET '"+Column$+"'=? WHERE "+DefaultID$+"="+Str(RowID)
        EndIf
        
        If (RowID = 0)
            SqlUpate$ = "INSERT INTO '"+Table$+"' (id,'"+Column$+"') VALUES (NULL, ?)" 
        EndIf
        
        Select MemoryMode
            Case 0        
                If ReadFile(#_BlobImage, ImageFile$)
                    ImageFileSize = Lof(#_BlobImage)
                    
                    If (ImageFileSize)
                        *memory = AllocateMemory(ImageFileSize)
                        
                        If (*memory)
                            ReadData(#_BlobImage, *memory, ImageFileSize)
;                             DatabaseUpdate(Database, "PRAGMA cache_size="+ImageFileSize+";") 
                            DatabaseUpdate(Database, "PRAGMA threads  = 16;")                             
                            DatabaseUpdate(Database, "BEGIN EXCLUSIVE TRANSACTION")  
                                                        
                            SetDatabaseBlob(Database, 0, *memory, ImageFileSize)
                            DatabaseUpdate(Database, SqlUpate$)
                            DatabaseUpdate(Database, "COMMIT TRANSACTION")                    
                            error$ = DatabaseError()
                            If Len(error$) <> 0
                                Debug "Databse Update: "+Table$+"' (id,"+Column$+") with Blob: " +ImageFile$
                            EndIf    
                        EndIf
                        FreeMemory(*memory)
                    EndIf
                    CloseFile(#_BlobImage)
                EndIf
                
            Case 1
                ;*memory = AllocateMemory(*MemoryHandle)
                If (*MemoryHandle)
                    
;                     DatabaseUpdate(Database, "PRAGMA cache_size="+ImageFileSize+";") 
;                     DatabaseUpdate(Database, "PRAGMA synchronous=0;")        
;                     DatabaseUpdate(Database, "PRAGMA journal_mode = OFF;")               
;                     DatabaseUpdate(Database, "PRAGMA temp_store = 2;")             
;                     DatabaseUpdate(Database, "PRAGMA default_cache_size="+ImageFileSize+";") 
;                     DatabaseUpdate(Database, "PRAGMA mmap_size="+ImageFileSize+";")
                    DatabaseUpdate(Database, "PRAGMA threads  = 16;") 
                    
                    DatabaseUpdate(Database, "BEGIN EXCLUSIVE TRANSACTION")     
                    SetDatabaseBlob(Database, 0, *MemoryHandle, MemorySize(*MemoryHandle))                            
                    DatabaseUpdate(Database, SqlUpate$)
                    DatabaseUpdate(Database, "COMMIT TRANSACTION")                    
                    error$ = DatabaseError()
                    If Len(error$) <> 0
                        Debug "Databse Update: "+Table$+"' (id,"+Column$+") with Blob: From Memory"
                    EndIf
                EndIf
                FreeMemory(*MemoryHandle)                    
        EndSelect

        ShowError(error$): ProcedureReturn error$        
     EndProcedure

    ;***************************************************************************************************
    ; Shrink Database
    ;
     Procedure ShrinkThread(*p.DATABASE_SHRINK)         
         If *p\DatabaseContant <> 0
             *p\Result = DatabaseUpdate(*p.DATABASE_SHRINK\DatabaseContant, "VACUUM;")
             Debug "shrink: " + Str(*p\Result  )
         EndIf
     EndProcedure    
    ;
     Procedure Shrink(Database,Datei$)
         Protected ThreadID
         AddElement(_SHSQL())
         _SHSQL()\DatabaseContant.i = Database
         _SHSQL()\Database___File.s = Datei$
         ;ShrinkThreadID = CreateThread(@ShrinkThread(),@_SHSQL())                         
         DatabaseUpdate(_SHSQL()\DatabaseContant, "VACUUM;")
         ProcedureReturn
    EndProcedure
     
     ;***************************************************************************************************
    ; Shrink Integritycheck
    ;
     Procedure IntegritycheckThread(*IntCheck.DATABASE_INTEGRITY)         
         If *IntCheck\DatabaseContant <> 0
             DatabaseUpdate(*IntCheck\DatabaseContant, "PRAGMA integrity_check;")
             error$ = DatabaseError(): Debug error$
             
            SQL$ = "PRAGMA integrity_check;"
            
            If DatabaseQuery(*IntCheck\DatabaseContant, SQL$)
                While NextDatabaseRow(*IntCheck\DatabaseContant)
                    ;Debug "Database integrity_check: " + GetDatabaseString(*IntCheck\DatabaseContant, 0)
                    IntegrityThreadX$ = GetDatabaseString(*IntCheck\DatabaseContant, 0)
                Wend
                FinishDatabaseQuery(*IntCheck\DatabaseContant)
            Else
                ;Debug SQL$
                ;Debug DatabaseError()
            EndIf              
         EndIf
     EndProcedure    
    ;
     Procedure Integritycheck(Database,Datei$)
         Protected ThreadID
         AddElement(_INSQL())
         _INSQL()\DatabaseContant.i = Database
         _INSQL()\Database___File.s = Datei$
         IntegrityThreadID = CreateThread(@IntegritycheckThread(),@_INSQL())
     EndProcedure    

    ;***************************************************************************************************
    ; 
    ; Löscht Rows in dem sich keine Daten befinden
     Procedure.i ClearDB(Database,Table$,Datei$)
     
         
         Protected n_RowID, Column$,Value_$,iLenght,IsNull = 0,NullColumns = 0, iMax_Before
         
         iMax = CountRows(Database,Table$,"*")
         iMax_Before = iMax
         Query$ = "Select * FROM '"+Table$+"'"
         

         If DatabaseQuery(Database,Query$)
             MaxColumns = DatabaseColumns(Database)
             For i = 1 To iMax Step 1
                 NextDatabaseRow(Database)
                      
                         IsNull = 0
                         For d = 1 To MaxColumns
                             
                             n_RowID = Val(GetDatabaseString(Database,0))                               
                             Column$ = DatabaseColumnName(Database,d)                             
                             Value_$ = GetDatabaseString(Database,d)
                             iLenght = DatabaseColumnSize(Database,d)
                             
                             If (iLenght = 0) And (Len(Value_$)=0)
                                 IsNull  = IsNull+1
                             EndIf
                             
                             If IsNull = MaxColumns                                 
                                 DeleteRow(Database,Table$,n_RowID)                                 
                                 NullColumns = NullColumns +1:Debug "Rows Line: "+i
                             EndIf
                         Next
                 Debug "Progress "+i+"/Von "+iMax      
                 If (i = iMax)
                     FinishDatabaseQuery(Database)
                     Break
                 EndIf               
             Next
         EndIf
         
         iMax = CountRows(Database,Table$,"*")
        If iMax_Before <> iMax
            Debug "Shrink ... (Database Size:"+FileSize(Datei$)+")" 
            Shrink(Database,Datei$)
            Quit = 0
            Repeat       
                While IsThread(ShrinkThreadID)
                    Delay(1)
                    Debug "Shrink Action... (Database Size:"+FileSize(Datei$)+")" 
                Wend
      
                If Not IsThread(ExecSQL::ShrinkThreadID)
                    Debug "Shrinked ... (New Size:"+FileSize(Datei$)+")"            
                    Delay(2000)
                    Quit = 1
                EndIf 
            
            Until (quit) 
        EndIf
        ProcedureReturn NullColumns
            
     EndProcedure
     
    ;***************************************************************************************************
    ; 
    ;
    Procedure SearchDB_Excact(Database,List _FISQL.DATABASE_SEARCH(),Query$,Find$)
        Protected RowID$,Celle$ ,iCaseSensitive,nCaseSensitive
                
        If DatabaseQuery(Database,Query$+"")
            
            While NextDatabaseRow(Database) 
                
                RowID$ = GetDatabaseString(Database,0)
                Celle$ = GetDatabaseString(Database,1)
                Celle$ = Trim(Celle$)
                
                iCaseSensitive = FindString(Celle$,Find$,1,#PB_String_CaseSensitive)
                
                If (iCaseSensitive <> 0) And (Len(Celle$) = Len(Find$))
                    AddElement(_FISQL())
                    _FISQL()\nRowID     = Val(RowID$)
                    _FISQL()\ExctMatch$ = Celle$            ;:Debug " _FISQL()\ExctMatch$: "+Celle$
                    _FISQL()\Column$    = DatabaseColumnName(Database,1)
                Else
                    nCaseSensitive = FindString(Celle$,Find$,1,#PB_String_NoCase)
                    
                    If (nCaseSensitive <> 0) And (Len(Celle$) = Len(Find$))
                        AddElement(_FISQL())
                        _FISQL()\nRowID     = Val(RowID$)
                        _FISQL()\NxctMatch$ = Celle$        ;:Debug " _FISQL()\NxctMatch$: "+Celle$+" (Is Not Case)"
                        _FISQL()\Column$    = DatabaseColumnName(Database,1)
                    EndIf
                EndIf
            Wend
        EndIf
    EndProcedure
    Procedure SearchDB_BestMatch(Database,List _FISQL.DATABASE_SEARCH(),Query$,Find$)
        Protected RowID$,Celle$ ,AddList = 0, iMax
     
        If DatabaseQuery(Database,Query$+"")
            
            While NextDatabaseRow(Database) 
                
                RowID$ = GetDatabaseString(Database,0)
                Celle$ = GetDatabaseString(Database,1)
                Celle$ = Trim(Celle$)
                AddList= 0
                
                iMax = ListSize(_FISQL())
                If (iMax <> 0)
                    ResetList(_FISQL())
                    While NextElement(_FISQL())
                        If _FISQL()\nRowID = Val(RowID$)
                            AddList= 1;: Debug Celle$ + " Existiert"
                            
                        EndIf
                    Wend
                    
                    If (AddList = 0)
                        nCaseSensitive = FindString(Celle$,Find$,1,#PB_String_NoCase)
                        If (nCaseSensitive <> 0)
                            AddElement(_FISQL())
                            _FISQL()\nRowID     = Val(RowID$)
                            _FISQL()\BestMatch$ = Celle$            ;:Debug " _FISQL()\ExctMatch$: "+Celle$
                            _FISQL()\Column$    = DatabaseColumnName(Database,1)
                            
                        Else
                            
                            AddElement(_FISQL())
                            _FISQL()\nRowID     = Val(RowID$)
                            _FISQL()\GoodMatch$ = Celle$        ;:Debug " _FISQL()\BestMatch$: "+Celle$
                            _FISQL()\Column$    = DatabaseColumnName(Database,1)
                        EndIf
                    EndIf
                Else
                    If (AddList = 0)
                        nCaseSensitive = FindString(Celle$,Find$,1,#PB_String_NoCase)
                        If (nCaseSensitive <> 0)
                            AddElement(_FISQL())
                            _FISQL()\nRowID     = Val(RowID$)
                            _FISQL()\BestMatch$ = Celle$            ;:Debug " _FISQL()\ExctMatch$: "+Celle$
                            _FISQL()\Column$    = DatabaseColumnName(Database,1)
                            
                        Else
                            
                            AddElement(_FISQL())
                            _FISQL()\nRowID     = Val(RowID$)
                            _FISQL()\GoodMatch$ = Celle$        ;:Debug " _FISQL()\BestMatch$: "+Celle$
                            _FISQL()\Column$    = DatabaseColumnName(Database,1)
                        EndIf
                    EndIf
                EndIf
            Wend
        EndIf
    EndProcedure
    ;***************************************************************************************************
    ; 
    ; Suche in Datenbank
    ;   Database                    = #Database
    ;   Table$                      = "Gamebase"
    ;   Find$                       = Der SuchParmater 'Apple oder Birnen'
    ;   QueryColumn$                = Die Column/s in den gesucht werden werrden soll
    ;                                 Mehrere Columns getrennt duch ein Lomma. Employ1,Employ2,Employ3
    ;   OrderColumn$                = Columns nach dem Sortiert werden soll, wird keiner angegeben wird
    ;                                 wird der erste Column von 'QueryColumn$' genommen
    ;   List _FISQL()               = Die interne Liste in der Später alle Resultate enthalten sind
    ;   Ascent$="asc"               = Sortiermodus
    Procedure.s SearchDB(Database,Table$,Find$,QueryColumn$,OrderColumn$,List _FISQL.DATABASE_SEARCH(),Ascent$="asc",Excakt=#False)
        
        Protected iMax, i, cout, LikeStatment$="(", GlobStatment$

        iMax = ListIndex(_FISQL()): If (iMax<>0): ClearList(_FISQL()): EndIf

        GlobStatment$ = "SELECT (id),("
        LikeStatment$ = "SELECT * FROM "+Table$+" WHERE ("
        
        cout = CountString(QueryColumn$,",")
        If (cout >= 1)
            For i = 1 To cout+1
                
                CurrentColumn$ = StringField(QueryColumn$,i,",")
                
                If (i = 1) And (Len(OrderColumn$) = 0): OrderColumn$ = CurrentColumn$: EndIf
                                        
                If (i = cout+1)
                   GlobStatment$ = GlobStatment$+CurrentColumn$+") AS SingleExpression FROM "+Table$
                   LikeStatment$ = LikeStatment$+CurrentColumn$+" LIKE '"+Find$+"') "
                   Break
                EndIf
                
                GlobStatment$  = GlobStatment$+CurrentColumn$+"||"+Chr(34)+" "+Chr(34)+"||"
                LikeStatment$  = LikeStatment$+CurrentColumn$+" LIKE '"+Find$+"') OR ("
            Next
         Else
            GlobStatment$ = GlobStatment$+QueryColumn$+") AS SingleExpression FROM "+Table$
        EndIf

        If (LCase(Ascent$) = "asc") Or (LCase(Ascent$) = "desc")           
            SetGlobStatment$ = GlobStatment$ +" ORDER BY "+OrderColumn$+" "+UCase(Ascent$)
            SetLikeStatment$ = LikeStatment$ +" ORDER BY "+OrderColumn$+" "+UCase(Ascent$)
        Else
            ProcedureReturn "near ORDER BY, need 'ASC' or 'DESC'"
        EndIf
        
        ; Debug "GlobStatment$: "+SetGlobStatment$: Debug "LikeStatment$: "+SetLikeStatment$
        ; Try Excat Entrys ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ;
            Query$ = SetGlobStatment$ : SearchDB_Excact(Database,_FISQL.DATABASE_SEARCH(),Query$,Find$)
            If Excakt=#True: ProcedureReturn: EndIf
        
        ; Try Bestmatches Entrys ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ;
            FindSingle$ = StringField(Find$,1," ")
            SetGlobStatment$ = GlobStatment$ +" WHERE SingleExpression GLOB '"+FindSingle$+"*' ORDER BY "+OrderColumn$+" "+UCase(Ascent$); : Debug "GlobStatment$: "+SetGlobStatment$
            Query$ = SetGlobStatment$ :SearchDB_BestMatch(Database,_FISQL.DATABASE_SEARCH(),Query$,Find$) 
            
            SetGlobStatment$ = GlobStatment$ +" WHERE SingleExpression GLOB '*"+FindSingle$+"' ORDER BY "+OrderColumn$+" "+UCase(Ascent$); : Debug "GlobStatment$: "+SetGlobStatment$
            Query$ = SetGlobStatment$ :SearchDB_BestMatch(Database,_FISQL.DATABASE_SEARCH(),Query$,Find$)
        
            SetGlobStatment$ = GlobStatment$ +" WHERE SingleExpression GLOB '*"+FindSingle$+"*' ORDER BY "+OrderColumn$+" "+UCase(Ascent$); : Debug "GlobStatment$: "+SetGlobStatment$
            Query$ = SetGlobStatment$ :SearchDB_BestMatch(Database,_FISQL.DATABASE_SEARCH(),Query$,Find$)
            
            iLenght= Len(Find$)
            If (iLenght >= 2)
                FindCS$= Mid(Find$,2,iLenght-1)
                FindCS$= "?"+FindCS$

                SetGlobStatment$ = GlobStatment$ +" WHERE SingleExpression GLOB '"+FindCS$+"*' ORDER BY "+OrderColumn$+" "+UCase(Ascent$); : Debug "GlobStatment$: "+SetGlobStatment$
                Query$ = SetGlobStatment$ :SearchDB_BestMatch(Database,_FISQL.DATABASE_SEARCH(),Query$,"") 
                
                SetGlobStatment$ = GlobStatment$ +" WHERE SingleExpression GLOB '*"+FindCS$+"' ORDER BY "+OrderColumn$+" "+UCase(Ascent$); : Debug "GlobStatment$: "+SetGlobStatment$
                Query$ = SetGlobStatment$ :SearchDB_BestMatch(Database,_FISQL.DATABASE_SEARCH(),Query$,"")
                
                SetGlobStatment$ = GlobStatment$ +" WHERE SingleExpression GLOB '*"+FindCS$+"*' ORDER BY "+OrderColumn$+" "+UCase(Ascent$); : Debug "GlobStatment$: "+SetGlobStatment$
                Query$ = SetGlobStatment$ :SearchDB_BestMatch(Database,_FISQL.DATABASE_SEARCH(),Query$,"")
            EndIf
     EndProcedure
     
    ;***************************************************************************************************
    ;     
    ; Gibt alle Columns wider die sich inder Datenbank befinden 
     Procedure.s GetColumns(Database,Table$)
         
         Protected Query$,ReturnColumns$
         Query$ = "Select * FROM '"+Table$+"' LIMIT 1"           
         If DatabaseQuery(Database,Query$)
             MaxCol = DatabaseColumns(Database)
             For i = 0 To iMax Step 1
                 NextDatabaseRow(Database)
                 Select MaxCol
                     Case 0                              
                         ProcedureReturn DatabaseColumnName(Database,MaxCol)                       
                     Case 1 To MaxCol
                         ReturnColumns$ = ""
                         For d = 1 To MaxCol
                             
                             If  (MaxCol = d)
                                 ReturnColumns$ = ReturnColumns$ + DatabaseColumnName(Database,d)
                                 FinishDatabaseQuery(Database):ProcedureReturn ReturnColumns$
                             EndIf
                             ReturnColumns$ = ReturnColumns$ + DatabaseColumnName(Database,d) + ","
                         Next
                 EndSelect
             Next
         EndIf
     EndProcedure    
    
EndModule      
CompilerIf #PB_Compiler_IsMainFile
;////////////////////////////////////////////////////////////////////////////////////////////////////////
;
; Examples
     #DATABASE = 100: Datei$ = "D:\! Source Projects\LH Game Database\Release_Test\MCGDDATA\Database\MCGD_BASE.DB"
     #IMAGE = 100: #WINDOW= 101: #IMAGEGADGET=102
;   
; ; Öffne Datenbank 
; ;//////////////////////////////////////////////////////////////////////////
   iResult$ = ExecSQL::OpenDB(#DATABASE,Datei$): Debug iResult$
;   
; 
; ; Setzt Optimniereungen ein  
; ;//////////////////////////////////////////////////////////////////////////  
   ExecSQL::TuneDB(#DATABASE)
;   
; ; Säubert die Datenbank, such nacht komplett Leeren IDs
; ;//////////////////////////////////////////////////////////////////////////   
;;   Rows = ExecSQL::ClearDB(#DATABASE,"Gamebase",Datei$) : Debug "ClearDB: Gelöschte Rows "+Rows
;   
; ; Löscht ein Table
; ;//////////////////////////////////////////////////////////////////////////    
; ; Debug ExecSQL::DropTable(#DATABASE,"test")
;   
; ; Erstellt ein Table + Index
; ;//////////////////////////////////////////////////////////////////////////      
; ;  Debug ExecSQL::CreateTable(#DATABASE,"TEST",#True)
;   
;   
; ; Fügt ein Column dem Table hinzu + Index
; ;//////////////////////////////////////////////////////////////////////////      
; ;  Debug ExecSQL::AddColumn(#DATABASE,"TEST","Mitarbeiter",#True)
;   
;   
; ; Gibt alle Columns wider die sich inder Datenbank befinden 
; ;//////////////////////////////////////////////////////////////////////////       
; ;   iResult$ = ExecSQL::GetColumns(#DATABASE,"Gamebase")
; ;   Cout = CountString(iResult$,",")
; ;   If Cout >= 2
; ;       For i = 1 To Cout+1
; ;           Debug "Column:" +StringField(iResult$,i,",")
; ;       Next
; ;   Else
; ;       Debug "Column: "+iResult$
; ;   EndIf
; ;//////////////////////////////////////////////////////////////////////////    
;   
;   
;   
; Searchfor$="Resident Evil" : Debug "Suche Nach: "+Searchfor$
; iResult$ = ExecSQL::SearchDB(#DATABASE,"Gamebase",Searchfor$,"TitleA,TitleB,TitleC","TitleA",ExecSQL::_FISQL()):Debug iResult$
; 
;     Debug "------------------- ExzaktMatches ----------------------"
;     ResetList(ExecSQL::_FISQL())
;     iMax = ListSize(ExecSQL::_FISQL())
;     For i = 0 To iMax-1
;         SelectElement(ExecSQL::_FISQL(),i)
; 
;         If Len(ExecSQL::_FISQL()\ExctMatch$) <> 0
;             n_RowIDs = ExecSQL::_FISQL()\nRowID
;             sCellen$ = ExecSQL::_FISQL()\ExctMatch$
;             Columns$ = ExecSQL::_FISQL()\Column$
;             
;             Debug "RowID:"+Str(n_RowIDs)+": "+sCellen$;+"  (IN den Columns: "+Columns$+")"
;         EndIf
;     Next
;     Debug ""
; 
;     Debug "----------- ExzaktMatches (But Not Case Sensitive)------"
;     ResetList(ExecSQL::_FISQL())
;     iMax = ListSize(ExecSQL::_FISQL())
;     For i = 0 To iMax-1
;         SelectElement(ExecSQL::_FISQL(),i)
;         
;         If Len(ExecSQL::_FISQL()\NxctMatch$) <> 0
;             n_RowIDs = ExecSQL::_FISQL()\nRowID
;             sCellen$ = ExecSQL::_FISQL()\NxctMatch$
;             Columns$ = ExecSQL::_FISQL()\Column$
;             
;             Debug "RowID:"+Str(n_RowIDs)+": "+sCellen$;+"  (IN den Columns: "+Columns$+")"
;         EndIf
;     Next
;     Debug ""
; 
;     Debug "---------------------- BestMatches ----------------------"
;     ResetList(ExecSQL::_FISQL())
;     iMax = ListSize(ExecSQL::_FISQL())
;     For i = 0 To iMax-1
;         SelectElement(ExecSQL::_FISQL(),i)
; 
;         If ExecSQL::_FISQL()\BestMatch$
;             n_RowIDs = ExecSQL::_FISQL()\nRowID
;             sCellen$ = ExecSQL::_FISQL()\BestMatch$
;             Columns$ = ExecSQL::_FISQL()\Column$
;             
;             Debug "RowID:"+Str(n_RowIDs)+": "+sCellen$;+"  (IN den Columns: "+Columns$+")"
;         EndIf    
;     Next
;     Debug "--------------------------------------------------------"
;     Debug ""
;     
; 
;     Debug "---------------------- GoodMatches ----------------------"
;     ResetList(ExecSQL::_FISQL())
;     iMax = ListSize(ExecSQL::_FISQL())
;     For i = 0 To iMax-1
;         SelectElement(ExecSQL::_FISQL(),i)
;         
;         If (ExecSQL::_FISQL()\GoodMatch$)
;             n_RowIDs = ExecSQL::_FISQL()\nRowID
;             sCellen$ = ExecSQL::_FISQL()\GoodMatch$
;             Columns$ = ExecSQL::_FISQL()\Column$
;             Debug "RowID:"+Str(n_RowIDs)+": "+sCellen$;+"  (IN den Columns: "+Columns$+")"
;         EndIf
;     Next
;     Debug "---------------------- ----------- ----------------------"
; ; ;
; ;//////////////////////////////////////////////////////////////////////////
;  Rows = ExecSQL::CountRows(#DATABASE,"Gamebase")
;M  Debug "Anzahl der Rows: "+Rows
;   
; ;
; ;//////////////////////////////////////////////////////////////////////////
; ;   RowID = ExecSQL::LastRowID(#DATABASE,"Gamebase")
; ;   Debug "Letzte Gänederte RowID "+RowID 
;   
; ;
; ;//////////////////////////////////////////////////////////////////////////
; ;   Result$ = ExecSQL::CreateTable(#DATABASE,"Test")
; ;   Debug "Table Hinzugefügt 'test' :"+Result$
;   
;  ;
; ;//////////////////////////////////////////////////////////////////////////
; ;   Result$ = ExecSQL::AddColumn(#DATABASE,"Test","Amiga1200")
; ;   Debug "Column Hinzugefügt 'Amiga1200' :"+Result$
;   
; ;
; ;//////////////////////////////////////////////////////////////////////////
; ;   Result$ =  ExecSQL::Indice(#DATABASE,"Test","ID","id")   
; ;   Debug Result$
;   
; 
; ;
; ;//////////////////////////////////////////////////////////////////////////
; ; Shrink
; ;
; ;   Debug "Shrink ... (Database Size:"+FileSize(Datei$)+")" 
; ;   ExecSQL::Shrink(#DATABASE,Datei$)
; ;   quit = 0
; ;  
; ;   Repeat       
; ;       While IsThread(ExecSQL::ShrinkThreadID)
; ;           Delay(10)
; ;           Debug "Shrink Action... (Database Size:"+FileSize(Datei$)+")" 
; ;       Wend
; ;       
; ;       If Not IsThread(ExecSQL::ShrinkThreadID)
; ;           Debug "Shrinked ... (New Size:"+FileSize(Datei$)+")"            
; ;           Delay(2000)
; ;           quit = 1
; ;       EndIf              
; ;               
; ;   Until (quit = 1)  
; ;       
; ;///////////////////////////////////////////////////////////////////////////    
;     
;   
;   
; ; Öffne Bild und Zeige es an
; ;//////////////////////////////////////////////////////////////////////////
; ;    
; ; 
;     For i = 1 To 10
;         iRandom = Random(Rows,1)
;         *memory = ExecSQL::GetImage(#DATABASE,"Gamebase","Scr_Front",1215)
;         If *memory <> 0
;             CatchImage(#IMAGE,*memory)
;             OpenWindow(#WINDOW,0,0,ImageWidth(#IMAGE),ImageHeight(#IMAGE),"",#PB_Window_BorderLess | #WS_SIZEBOX | #PB_Window_ScreenCentered|#PB_Window_Invisible)
;             
;             ImageGadget(#IMAGEGADGET,0,0,0,0,ImageID(#IMAGE))
;             FreeMemory(*memory)
;             
;             AnimateWindow_(WindowID(#WINDOW),500,#AW_BLEND|#AW_SLIDE)      
;             Delay(5000)
;             
;             AnimateWindow_(WindowID(#WINDOW),500,#AW_BLEND|#AW_HIDE)
;             CloseWindow(#WINDOW)
;         Else
;             Debug "Kein Bild in der Celle"
;         EndIf
;         
;         *memory = ExecSQL::GetImage(#DATABASE,"Gamebase","Scr_Back",iRandom)
;         If *memory <> 0        
;             CatchImage(#IMAGE,*memory)
;             OpenWindow(#WINDOW,0,0,ImageWidth(#IMAGE),ImageHeight(#IMAGE),"",#PB_Window_BorderLess | #WS_SIZEBOX | #PB_Window_ScreenCentered|#PB_Window_Invisible)
;             
;             ImageGadget(#IMAGEGADGET,0,0,0,0,ImageID(#IMAGE))
;             FreeMemory(*memory)
;             
;             AnimateWindow_(WindowID(#WINDOW),500,#AW_BLEND|#AW_BLEND)
;             
;             Delay(5000)
;             
;             AnimateWindow_(WindowID(#WINDOW),500,#AW_BLEND|#AW_HIDE)
;             CloseWindow(#WINDOW)
;         Else
;             Debug "Kein Bild in der Celle"
;         EndIf        
;     Next i
; ;///////////////////////////////////////////////////////////////////////////     
; 
; 
; ;
; ; ; Öffne Bild Lege es in die DB und Zeige es an (Insert Into)
; ///////////////////////////////////////////////////////////////////////////
;  
;    
;     Imagefile$ = "N:\! ReOrganisieren\Programm Archiv - Privat\Handy Backup\Pictures\6ecd81b54a62f003ec18958c26fa9e1e.jpg"
;   
;     iResult$ = ExecSQL::ImageSet(#DATABASE,"Gamebase","Scr_Front",ImageFile$): Debug iResult$
;   
;     RowID = ExecSQL::LastRowID(#DATABASE,"Gamebase"):                      Debug "Last Insert RowID:"+Str(RowID)
;   
;     *memory = ExecSQL::ImageGet(#DATABASE,"Gamebase","Scr_Front",RowID)
;     If *memory <> 0
;         CatchImage(#IMAGE,*memory)
;         OpenWindow(#WINDOW,0,0,ImageWidth(#IMAGE),ImageHeight(#IMAGE),"",#PB_Window_BorderLess | #WS_SIZEBOX | #PB_Window_ScreenCentered|#PB_Window_Invisible)
;       
;         ImageGadget(#IMAGEGADGET,0,0,0,0,ImageID(#IMAGE))
;         FreeMemory(*memory)
;       
;         AnimateWindow_(WindowID(#WINDOW),1500,#AW_BLEND)      
;         Delay(9000)
;       
;         AnimateWindow_(WindowID(#WINDOW),250,#AW_BLEND|#AW_HIDE)
;         CloseWindow(#WINDOW)
;     Else
;         Debug "Kein Bild in der Celle"
;     EndIf

;     
;     
; ;
; ; Öffne Bild Lege es in eine bstimmte Celle der DB und Zeige es an  (Update)
; ;///////////////////////////////////////////////////////////////////////////    
; ;     Imagefile$ = "N:\! ReOrganisieren\Programm Archiv - Privat\Handy Backup\Pictures\synR13V9 test7.jpg"
; ;     
; ;     iResult$ = ExecSQL::ImageSet(#DATABASE,"Gamebase","Scr_Front",ImageFile$,2): Debug iResult$
; ;         
; ;     *memory = ExecSQL::ImageGet(#DATABASE,"Gamebase","Scr_Front",2)
; ;     If *memory <> 0
; ;         CatchImage(#IMAGE,*memory)
; ;         OpenWindow(#WINDOW,0,0,ImageWidth(#IMAGE),ImageHeight(#IMAGE),"",#PB_Window_BorderLess | #WS_SIZEBOX | #PB_Window_ScreenCentered|#PB_Window_Invisible)
; ;         
; ;         ImageGadget(#IMAGEGADGET,0,0,0,0,ImageID(#IMAGE))
; ;         FreeMemory(*memory)
; ;         
; ;         AnimateWindow_(WindowID(#WINDOW),1500,#AW_BLEND)      
; ;         Delay(9000)
; ;         
; ;         AnimateWindow_(WindowID(#WINDOW),250,#AW_BLEND|#AW_HIDE)
; ;         CloseWindow(#WINDOW)
; ;     Else
; ;         Debug "Kein Bild in der Celle"
; ;     EndIf  
; ;
; ;    
; ;////////////////////////////////////////////////////////////////////////////////   
;   
;   
;   
; ;Col$="TitleA,TitleB,TitleC,Puplish,Develop,Released,Releasem,Releasey,Protection,Game_version,Game_engine";,"+
;     ; "genrea,genreb,ingamey integer,goldedit,specialedit,dcut,dlc,gameaddon,goty,req_win,req_mem,req_vmem,"+
;     ; "sup_cga,sup_ega,sup_vga,sup_svga,sup_3dfx,sup_ogl,sup_dx,sup_physx,sup_ddraw,sub_dxlvl,ogfx,"+
;   	; "sup_smidi,sup_scsb,sup_sinno,sup_sgus,sup_smt32,sup_sdsound,sup_a3d,sup_eax,sup_osnd,"+
;     ; "ws_native,ws_triple,ws_fix,ws_notice,sys_port_emulation,sys_port_emulationid,sys_percent,"+
;   	;: "sys_win,sys_win_model,sys_mem,sys_hardware,gfx_drv,bpjs,"+
;   	; "screenshot_path,hdd_dbpath,modsupport,covermiss,serialkey,originalplatform,"+
;   	; "language,multiplayer,compmode_winmodel,compmode_colors,compmode_resolution,compmode_theme,compmode_composition,compmode_scale"
;   	
; ; 
; ; ExecSQL::nRows(#DATABASE,"Gamebase","TitleA,TitleB",ExecSQL::_IOSQL(),324)
; ;     ResetList(ExecSQL::_IOSQL())
; ;     While NextElement(ExecSQL::_IOSQL())
; ;         Debug "Current:"+Str(ExecSQL::_IOSQL()\nRowID)+" - "+ExecSQL::_IOSQL()\Column$+" | "+ExecSQL::_IOSQL()\Value_$
; ;     Wend
; ;     Debug ""
; ;     Debug ""
; 
;   	
;     StartTime = ElapsedMilliseconds()
;     ExecSQL::lRows(#DATABASE,"Language","*",1,Rows,ExecSQL::_IOSQL(),"Locale","asc") 
;     ResetList(ExecSQL::_IOSQL())
;     While NextElement(ExecSQL::_IOSQL())
; ;         If LCase(ExecSQL::_IOSQL()\Column$) = "titlea"
;             Debug "RowID:"+Str(ExecSQL::_IOSQL()\nRowID)+" - "+ExecSQL::_IOSQL()\Column$+" | "+ExecSQL::_IOSQL()\Value_$
; ;         EndIf
;     Wend
;     ElapsedTime = ElapsedMilliseconds()
;     Debug ""    
;     Debug "Startzeit"+StartTime +" /Einträge:"+Rows
;     Debug "Ziel-Zeit"+ElapsedTime
;     Debug "---------------------"
;     Debug "Zeit Benötigt:"+Str(ElapsedTime-StartTime)
; 
;Debug ExecSQL::MaxRowID(#DATABASE,"GameBase") 
;  ExecSQL::CloseDB(#DATABASE,Datei$)  

CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1050
; FirstLine = 640
; Folding = +2Aivg-
; EnableAsm
; EnableThread
; EnableXP
; CurrentDirectory = ..\..\LH Game Database\Release_Test\
; EnableUnicode