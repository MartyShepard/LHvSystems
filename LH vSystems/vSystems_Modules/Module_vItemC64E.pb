DeclareModule vItemC64E
    
    
    Declare.i DSK_Image_Refresh()
    Declare.i DSK_LoadOldFilename()
    Declare.s DSK_SetCharSet(OldFileName$)
    Declare.i DSK_LoadImage(GadgetID.i,DestGadgetID.i, DropLoad = 0);<< C64LoadS8_TXID Variabel wird hier erstellt
    Declare.i DSK_FormatCheck(D64_Image$)
    Declare.i DSK_OpenCBM_Tools(Tool$ = "rename")
    
    Declare.i Image_Create()
    Declare.i Image_CopyFile_FromImageToHD()
    Declare.i Image_CopyFile_FromHDToImage(FileRequester = #True)
    
    Declare.i Item_GetPrograms()
    Declare.i Item_ChangeFont()
    Declare.i Item_Auto_Select()
    Declare.s Item_Select_List()
    Declare   Item_GetPrograms()  
    Declare.i Item_Side_AutoChange()
    Declare.i Item_Side_SetAktiv(C64LoadS8_Side)
    
    Declare.i DragnDrop_Load(Files$,GadgetID.i,DestGadgetID.i)
    
    Declare.i DSK_OpenCBM_Init()
    Declare.i DSK_OpenCBM_Directory()
    Declare.i DSK_OpenCBM_Refresh()
    Declare.i DSK_OpenCBM_Format()
    Declare.i DSK_OpenCBM_Val()    
    Declare.i DSK_OpenCBM_Copy_LocalFile_To_1541(FileRequester.i = #True)   
    
    Declare.i DSK_Image_TransferToPCHD(TrackOnly = #False)
    Declare.i DSK_Image_TransferTo1541()
    
    Global vItemC64E_CanClose.i = #False 
EndDeclareModule

Module vItemC64E        
    
    Structure PROGRAM_BOOT
        Program.s
        PrgPath.s
        WrkPath.s
        Command.s
        Logging.s
        PrgFlag.l
        ExError.i  
        StError.s
        Modus$
        LowProcess.i
    EndStructure  
    
    Structure CharFont
         c.a[16]
    EndStructure
        
    Structure DISKDRIVE_ERROR
        UCaseError.s
        LCaseError.s
        Info.s
    EndStructure    
        
    Structure D64
        dskFileName.s
    EndStructure
    
    Structure R64
        dskFileName.s
    EndStructure    
    
    Global NewList D64.D64() 
    Global NewList R64.R64()  
    Global NewList ERR.DISKDRIVE_ERROR()
    
    Global C64LoadS8_OldFN$ = "" ;  Alter Datei Name falls man Escape oder das Fenster Schliesst (Nicht Ok Button)
    Global C64LoadS8_Mutx.l = 0
    Global C64LoadS8_Spin.l = 0
    Global C64LoadS8_Side.i = -1 ; -1 = Image Disk/ 1 = Real Drive
    Global C64LoadS8_TXID.l = 0
    Global C64LoadS8_CopyF$ = ""
    Global C64Format_Name$  = ""    
    Global LastDrive_Error$ = ""    
    Global C64_PackedImage$ = ""  
    Global C64DskInterface$ = ""   
    Global C64DskDriveHard$ = ""    
    Global Enable_Gadgets.i = #True
    Global RealDiskDrive$   = "0"
    Global C64LoadS8_Delete = 0 ; All Files = 1, Single File = 0
    Global UseCBMModule     = #True
    Global ShowErrorAfter   = #False
      
    
    ;****************************************************************************************************************************************************************
    ; Macros für den Thread um diesen in Falle eines Falles zu unterbrechen
    ;________________________________________________________________________________________________________________________________________________________________    
    Macro KeyIsDown(key)
        Bool(GetAsyncKeyState_(key) & $8000)
    EndMacro    
    Macro KeyIsUp(key)
        Bool(Not (GetAsyncKeyState_(key) & $8000))
    EndMacro
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________    
    Procedure.i Item_Side_AutoChange()
        
        Select C64LoadS8_Side
            Case -1
                C64LoadS8_Side = 1 ; Real Drive Aktiv
                ButtonEX::SetState(DC::#Button_277, 1)
                ButtonEX::SetState(DC::#Button_280, 0)   
                Request::SetDebugLog("Aktive Seite: Echtes 1541 " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line)) 
                ProcedureReturn
            Case 1
                C64LoadS8_Side = -1 ; Image Aktiv
                ButtonEX::SetState(DC::#Button_277, 0)
                ButtonEX::SetState(DC::#Button_280, 1) 
                Request::SetDebugLog("Aktive Seite: Image Datei " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                 
                ProcedureReturn
         EndSelect       
                
     EndProcedure
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________       
    Procedure.i Item_Side_SetAktiv(Aktiv.i)
        
        Select Aktiv.i
            Case -1
                C64LoadS8_Side = -1 ; Image Aktiv
                ButtonEX::SetState(DC::#Button_277, 1)
                ButtonEX::SetState(DC::#Button_280, 0)
                ButtonEX::Disable(DC::#Button_206, #True)
                ButtonEX::Disable(DC::#Button_204, #False)
                ButtonEX::Disable(DC::#Button_275, #True)
                ButtonEX::Disable(DC::#Button_276, #True)
                ButtonEX::Disable(DC::#Button_272, #False)
                ButtonEX::Disable(DC::#Button_273, #False)                  
                Request::SetDebugLog("Aktive Seite: Image Datei " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                
                ProcedureReturn
            Case 1
                C64LoadS8_Side = 1 ; Real Drive Aktiv                
                ButtonEX::SetState(DC::#Button_277, 0)
                ButtonEX::SetState(DC::#Button_280, 1)
                ButtonEX::Disable(DC::#Button_206, #False)
                ButtonEX::Disable(DC::#Button_204, #True)
                ButtonEX::Disable(DC::#Button_275, #False)
                ButtonEX::Disable(DC::#Button_276, #False)
                ButtonEX::Disable(DC::#Button_272, #True)
                ButtonEX::Disable(DC::#Button_273, #True)                  
                Request::SetDebugLog("Aktive Seite: Echtes 1541 " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                                  
                ProcedureReturn
         EndSelect       
                
     EndProcedure
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________      
     Procedure.i Error_DiskDrive_List()
         
         ClearList( ERR() )         
         AddElement( ERR()): ERR()\UCaseError = "01,FILES SCRATCHED"        : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "20,Read ERROR"             : ERR()\LCaseError = LCase( ERR()\UCaseError )         
         AddElement( ERR()): ERR()\UCaseError = "21,Read ERROR"             : ERR()\LCaseError = LCase( ERR()\UCaseError )  
         AddElement( ERR()): ERR()\UCaseError = "23,Read ERROR"             : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "24,Read ERROR"             : ERR()\LCaseError = LCase( ERR()\UCaseError )         
         AddElement( ERR()): ERR()\UCaseError = "25,WRITE ERROR"            : ERR()\LCaseError = LCase( ERR()\UCaseError )  
         AddElement( ERR()): ERR()\UCaseError = "26,WRITE PROTECT ON"       : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "27,Read ERROR"             : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "28,WRITE ERROR"            : ERR()\LCaseError = LCase( ERR()\UCaseError )         
         AddElement( ERR()): ERR()\UCaseError = "29,DISK ID MISMATCH"       : ERR()\LCaseError = LCase( ERR()\UCaseError ) 
         AddElement( ERR()): ERR()\UCaseError = "30,SYNTAX ERROR,"          : ERR()\LCaseError = LCase( ERR()\UCaseError ) 
         AddElement( ERR()): ERR()\UCaseError = "31,SYNTAX ERROR,"          : ERR()\LCaseError = LCase( ERR()\UCaseError ) 
         AddElement( ERR()): ERR()\UCaseError = "32,SYNTAX ERROR,"          : ERR()\LCaseError = LCase( ERR()\UCaseError )         
         AddElement( ERR()): ERR()\UCaseError = "33,SYNTAX ERROR,"          : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "34,SYNTAX ERROR,"          : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "39,SYNTAX ERROR,"          : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "50,RECORD Not PRESENT,"    : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "51,OVERFLOW IN RECORD,"    : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "52,FILE TOO LARGE,"        : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "60,WRITE FILE OPEN,"       : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "61,FILE Not OPEN,"         : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "62,FILE Not FOUND,"        : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "63,FILE EXISTS,"           : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "64,FILE TYPE MISMATCH,"    : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "65,NO BLOCK,"              : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "66,ILLEGAL TRACK Or SECTOR,":ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "67,ILLEGAL TRACK Or SECTOR,":ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "70,NO CHANNEL,"            : ERR()\LCaseError = LCase( ERR()\UCaseError )
         AddElement( ERR()): ERR()\UCaseError = "71,DIR ERROR,"             : ERR()\LCaseError = LCase( ERR()\UCaseError )         
         AddElement( ERR()): ERR()\UCaseError = "72,DISK FULL,"             : ERR()\LCaseError = LCase( ERR()\UCaseError )  
         AddElement( ERR()): ERR()\UCaseError = "74,DRIVE Not READY,"       : ERR()\LCaseError = LCase( ERR()\UCaseError )           
            
     EndProcedure 
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________      
    Procedure.i Error_DiskDrive_Show()
        
        
        ; 00,OK,00,00
        ; Es ist kein Fehler aufgetreten.
        
        ; 01,FILES SCRATCHED,XX,00
        ; Rückmeldung nach SCRATCH-Befehl (XX=Anzahl der gelöschten Dateien). Es handelt sich hier nicht wirklich um einen Fehler, sondern um einen informellen Hinweis bzw. Status.
        
        ; 20,Read ERROR,TT,SS
        ; Kopf des Datenblocks wurde nicht gefunden.
        
        ; 21,Read ERROR,TT,SS
        ; SYNC-Markierung eines Datenblockes wurde nicht gefunden.
        
        ; 22,Read ERROR,TT,SS
        ; Prüfsummenfehler im Kopf eines Datenblocks.
        
        ; 23,Read ERROR,TT,SS
        ; Prüfsummenfehler im Datenteil eines Datenblocks.
        
        ; 24,Read ERROR,TT,SS
        ; Prüfsummenfehler
        
        ; 25,WRITE ERROR,TT,SS
        ; Datenblock wurde fehlerhaft auf Disk geschrieben.
        
        ; 26,WRITE PROTECT ON,TT,SS
        ; Schreibversuch auf Diskette mit aktiviertem Schreibschutz.
        
        ; 27,Read ERROR,TT,SS
        ; Prüfsummenfehler
        
        ; 28,WRITE ERROR,TT,SS
        ; SYNC-Markierung eines Datenblocks wurde nicht gefunden.
        
        ; 29,DISK ID MISMATCH,TT,SS
        ; Disk-ID ist fehlerhaft.
        
        ; 30,SYNTAX ERROR,00,00
        ; Gesendeter DOS-Befehl ist syntaktisch nicht korrekt aufgebaut.
        
        ; 31,SYNTAX ERROR,00,00
        ; Gesendeter DOS-Befehl ist nicht bekannt (bzw. implementiert).
        
        ; 32,SYNTAX ERROR,00,00
        ; Gesendeter DOS-Befehl ist länger als 40 Zeichen.
        
        ; 33,SYNTAX ERROR,00,00
        ; Unzulässige Verwendung eines Jokerzeichens.
        
        ; 34,SYNTAX ERROR,00,00
        ; IN einem DOS-Befehl wurde der Dateiname nicht gefunden.
        
        ; 39,SYNTAX ERROR,00,00
        ; Programm vom Typ USR wurde nicht gefunden.
        
        ; 50,RECORD Not PRESENT,00,00
        ; Es wurde ein Datensatz einer relativen Datei angesprochen, der noch nicht existiert. 
        ; Sofern ein Schreibzugriff erfolgt ist, wurde der Datensatz angelegt. Es handelt sich hier 
        ; nicht wirklich um einen Fehler, sondern um einen informellen Hinweis bzw. Status zu einer relativen Datei.
        
        ; 51,OVERFLOW IN RECORD,00,00
        ; Die gesendeten Daten überschreiten die Datensatzlänge einer relativen Datei.
        
        ; 52,FILE TOO LARGE,00,00
        ; Datensatznummer einer relativen Datei ist zu groß bzw. die Datei kann nicht weiter vergrößert werden.
        
        ; 60,WRITE FILE OPEN,00,00
        ; Es wurde versucht, eine Datei zu öffnen, die beim letzten Schreibversuch nicht ordnungsgemäß geschlossen wurde.
        
        ; 61,FILE Not OPEN,00,00
        ; Eine angesprochene Datei wurde zuvor nicht geöffnet.
        
        ; 62,FILE Not FOUND,00,00
        ; Die angesprochene Datei existiert auf der Diskette nicht.
        
        ; 63,FILE EXISTS,00,00
        ; Es wurde versucht, eine Datei mit einem auf der Diskette bereits existierenden Namen anzulegen.
        
        ; 64,FILE TYPE MISMATCH,00,00
        ; Beim Öffnen einer Datei wurde ein falscher Dateityp angegeben.
        
        ; 65,NO BLOCK,TT,TT
        ; Es wurde versucht, einen Datenblock zu belegen, der bereits belegt war.
        
        ; 66,ILLEGAL TRACK Or SECTOR,TT,SS
        ; Es wurde versucht, auf einem nicht existierenden Datenblock zuzugreifen.
        
        ; 67,ILLEGAL TRACK Or SECTOR,TT,SS
        ; Die Track-Sektor-Verkettung einer Datei ist fehlerhaft.
        
        ; 70,NO CHANNEL,00,00
        ; Es wurde versucht, mehr Dateien zu öffnen als Kanäle vorhanden sind.
        
        ; 71,DIR ERROR,TT,SS
        ; Die Anzahl der freien Datenblöcke im DOS-Speicher stimmt mit dem Bit-Muster der BAM nicht überein.
        
        ; 72,DISK FULL,00,00
        ; Diskette ist komplett mit Daten belegt.
        
        ; 73,CBM DOS V2.6 1541,00,00
        ; DAS ist kein Fehler, sondern die Einschaltmeldung der Floppy. Die Meldung kommt immer,
        ; wenn nach dem Einschalten der Floppy oder einem Reset bevor ein Befehl an die Floppy gesendet wurde.         
        ; Der tatsächliche Text nach der Meldungsnummer hängt vom Laufwerk beziehungsweise dem dort eingebauten ROM ab.
        
        ; 74,DRIVE Not READY,00,00
        ; Es wurde versucht die Floppy anzusprechen, ohne dass sich eine Diskette im Laufwerk befindet.

        Protected Code$
        
        If Len( LastDrive_Error$ ) = 0
            LastDrive_Error$ = ""
            ProcedureReturn #True
        EndIf
            
        Code$ = Mid( LastDrive_Error$, 1, 3)
        Select Code$
            Case "00,": ProcedureReturn #True
            Case "01,": ProcedureReturn #True
            Case "73,": ProcedureReturn #True 
            Default
        EndSelect
        
        Request::MSG(Startup::*LHGameDB\TitleVersion, C64DskDriveHard$ + ": Disk Error",LastDrive_Error$,2,0,"",0,0,DC::#_Window_005)
        SetActiveGadget(DC::#ListIcon_003)
        ProcedureReturn #False
    EndProcedure     
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________      
     Procedure.i Error_DiskDrive_Find(sTextLine$)
                  
         ResetList( ERR() )
         
         While NextElement( ERR() )
             
             If ( FindString( sTextLine$, ERR()\UCaseError, 1) )
                 LastDrive_Error$ =  sTextLine$
                 Error_DiskDrive_Show()
                 ProcedureReturn
             EndIf
             If ( FindString( sTextLine$, ERR()\UCaseError, 1) )
                 LastDrive_Error$ =  sTextLine$
                 Error_DiskDrive_Show()
                 ProcedureReturn
             EndIf             
         Wend            
     EndProcedure 
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________    
    Procedure Item_Select_Index(ListID.i, OldPosition.i)
        
            Protected ItemCnt
        
            SetActiveGadget(ListID)
        
            ItemCnt = CountGadgetItems(ListID)-1
            Select ItemCnt
                Case  0:                     
                    SetGadgetItemState(ListID,0,1): Item_Select_List() 
                                        
                Case -1: 
                    SetGadgetText(DC::#String_100, "")                
                    SetGadgetText(DC::#String_104, "")    
                    
                Default
                    If ( ItemCnt >= OldPosition )
                        SetGadgetItemState(ListID,OldPosition,1); 
                    Else
                        If ( ( OldPosition - ItemCnt ) = 1)                                                    
                            SetGadgetItemState(ListID,OldPosition-1,1); 
                        Else
                            SetGadgetItemState(ListID,ItemCnt,1);
                        EndIf   
                    EndIf
                    Item_Select_List() 
            EndSelect         
        
        EndProcedure
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________        
    Procedure Gadgets_Enbale_Disble(ModeSwitch, InMode = 0)
            
            
            ButtonEX::Disable(DC::#Button_203, ModeSwitch)
            ButtonEX::Disable(DC::#Button_204, ModeSwitch)
            ButtonEX::Disable(DC::#Button_205, ModeSwitch)
            ButtonEX::Disable(DC::#Button_206, ModeSwitch)  
            ButtonEX::Disable(DC::#Button_207, ModeSwitch) 
            ButtonEX::Disable(DC::#Button_262, ModeSwitch)
            ButtonEX::Disable(DC::#Button_263, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_264, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_265, ModeSwitch)
            ButtonEX::Disable(DC::#Button_266, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_267, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_268, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_269, ModeSwitch)    
            ButtonEX::Disable(DC::#Button_270, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_271, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_272, ModeSwitch)            
            ButtonEX::Disable(DC::#Button_273, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_274, ModeSwitch)           
            ButtonEX::Disable(DC::#Button_275, ModeSwitch)              
            ButtonEX::Disable(DC::#Button_276, ModeSwitch) 
            ButtonEX::Disable(DC::#Button_279, ModeSwitch)             
            
            If ( ModeSwitch = #True )
                ProcedureReturn
            EndIf    
                
            
            Select C64LoadS8_Side
                Case -1
                    ButtonEX::Disable(DC::#Button_206, #True)
                    ButtonEX::Disable(DC::#Button_204, #False)
                    
                    ButtonEX::Disable(DC::#Button_275, #True)
                    ButtonEX::Disable(DC::#Button_276, #True) 
                    
                    ButtonEX::Disable(DC::#Button_272, #False)
                    ButtonEX::Disable(DC::#Button_273, #False)                     
                Case 1
                    ButtonEX::Disable(DC::#Button_206, #False)
                    ButtonEX::Disable(DC::#Button_204, #True)
                    
                    ButtonEX::Disable(DC::#Button_275, #False)
                    ButtonEX::Disable(DC::#Button_276, #False)                     
                    
                    ButtonEX::Disable(DC::#Button_272, #True)
                    ButtonEX::Disable(DC::#Button_273, #True)                     
            EndSelect     
            
            
     EndProcedure
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________
    Procedure.s Request_CopyFileExists(Return_String$, CopyDest$, Destination$)
        Repeat
            If ( FileSize( CopyDest$ ) >= 1 )
                Request::*MsgEx\User_BtnTextL = "Rename"
                Request::*MsgEx\User_BtnTextM = "Overwrite"
                Request::*MsgEx\User_BtnTextR = "Abort"
                Request::*MsgEx\Return_String = Return_String$
                r = Request::MSG(Startup::*LHGameDB\TitleVersion, "File Exists","Enter a New name or Overwrite",16,1,"",0,1,DC::#_Window_005)
                Select r
                    Case 0: 
                        If (Len( Request::*MsgEx\Return_String ) <> 0)
                            Return_String$ = Request::*MsgEx\Return_String
                            CopyDest$ = Destination$+ Return_String$
                        EndIf
                    Case 1: 
                        ProcedureReturn ""
                    Case 2:
                EndSelect                                
            EndIf                                   
        Until ( FileSize( CopyDest$ ) = -1 )  Or ( r = 2 )
        ProcedureReturn CopyDest$
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________    
    Procedure.i Request_RenameDialog(CurrentFile$)
        
        Protected r.i
        Request::*MsgEx\User_BtnTextL = "Rename"
        Request::*MsgEx\User_BtnTextR = "Cancel"        
        Request::*MsgEx\Return_String = CurrentFile$
        Request::*MsgEx\Fnt3 = FontID(Fonts::#_C64_CHARS3_REQ)
        
        r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Rename File","Enter new File Name",10,1,"",0,1,DC::#_Window_005)        
        SetActiveGadget(DC::#ListIcon_003): 
        If (r = 0)                                   
            
            If ( Len(Request::*MsgEx\Return_String) = 0 )   
                Request_RenameDialog(CurrentFile$)
            EndIf
            
            ProcedureReturn #True
            
        EndIf
        If (r = 1) 
            ProcedureReturn #False
        EndIf                   
        
    EndProcedure   
    ;****************************************************************************************************************************************************************
    ; Prüfe Datei Gegebenheiten
    ;________________________________________________________________________________________________________________________________________________________________         
    Procedure.i Request_FileSizeDialog(DiskImage$)
        
        Protected Message$, Ups = #True
        
        Select FileSize(DiskImage$)                
            Case -1 : Message$ = "File Not Found: ... "+#CR$+Chr(34)+DiskImage$+Chr(34)       :Ups = #False                
            Case -2 : Message$ = "File is Directory: ... "+#CR$+Chr(34)+DiskImage$+Chr(34)    :Ups = #False                
            Case  0 : Message$ = "File has Null Bytes: ... "+#CR$+Chr(34)+DiskImage$+Chr(34)  :Ups = #False
        EndSelect
        
        If ( Ups = #False )
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ",Message$,2,2,"",0,0,DC::#_Window_005)
        EndIf
        
        ProcedureReturn Ups
    EndProcedure 
    ;****************************************************************************************************************************************************************
    ; 
    ;________________________________________________________________________________________________________________________________________________________________    
    Procedure Item_GetPrograms()                               
        
        Startup::*LHGameDB\C64LoadS8         = ExecSQL::nRow(DC::#Database_001,"Settings","C64Load$8","",1,"",1)
        If ( Startup::*LHGameDB\C64LoadS8 <> "")
            SetGadgetText( DC::#String_101, Startup::*LHGameDB\C64LoadS8 ) 
        EndIf
        
        Startup::*LHGameDB\OpenCBM_Tools         = ExecSQL::nRow(DC::#Database_001,"Settings","OpenCBMTools","",1,"",1)
        If ( Startup::*LHGameDB\OpenCBM_Tools <> "")        
            SetGadgetText(DC::#String_103 , Startup::*LHGameDB\OpenCBM_Tools)   
        EndIf
              
        Startup::*LHGameDB\OpenCBM_BPath  = ExecSQL::nRow(DC::#Database_001,"Settings","OpenCBMBPath","",1,"",1)          
        If ( Startup::*LHGameDB\OpenCBM_BPath <> "")          
            SetGadgetText(DC::#String_111 , Startup::*LHGameDB\OpenCBM_BPath)          
        EndIf
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Programm läuft, Hole das Verzeichnis (Image Basiert)
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_OpenCBM_GetDirectory(*Params.PROGRAM_BOOT)
        
        Protected Image_Text$, DiskHeader$, DiskBottom$, DiskInhalt$
        While ProgramRunning(*Params\LowProcess) 
            
            Image_Text$ = ReadProgramString(*Params\LowProcess) 
            
            
            EndOfFile   + 1
            Select EndOfFile
                Case 1
                    For i = 48 To 57                
                        If ( FindString(Image_Text$, Chr(i), 0) = 1 )                                     
                            AddElement(R64()): R64()\dskFileName = Image_Text$: DiskHeader$ = Image_Text$;
                            Break                                                                        ;
                        EndIf
                    Next
                    
                Default
                    If ( FindString(Image_Text$, "blocks free", 2,0) > 2 )                                                 
                        AddElement(R64()): R64()\dskFileName = Image_Text$: DiskBottom$ = Image_Text$:SetGadgetText(DC::#Text_124,Image_Text$) 
                    Else                     
                        For i = 48 To 57  
                            If ( FindString(Image_Text$, Chr(i), 0) = 1 )                                                                 
                                AddElement(R64()): R64()\dskFileName = Image_Text$: DiskInhalt$ = DiskInhalt$ +Chr(13)+ Image_Text$
                                Break;
                            EndIf
                        Next
                    EndIf
            EndSelect                
           ; Delay(1) 
        Wend  
        
        If FindString( DiskHeader$ , "74,drive not ready,00,00", 1)
            LastDrive_Error$ = DiskHeader$
            ProcedureReturn
        EndIf                
        
        Request::SetDebugLog("LIST : ---------------------------------------  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
        Request::SetDebugLog("     : "+DiskHeader$ +"                         ")    
        Request::SetDebugLog("     : ---------------------------------------  ")
        Request::SetDebugLog("     : "+DiskInhalt$ +"                         ")            
        Request::SetDebugLog("     : ---------------------------------------  ")        
        Request::SetDebugLog("     : "+DiskBottom$ +"                         ") 
        Request::SetDebugLog("     : ---------------------------------------  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))           
                
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;
    ;________________________________________________________________________________________________________________________________________________________________      
    Procedure.i DSK_OpenCBM_ErrDiskDrive()
        
          SetGadgetText(DC::#Text_121," 0")              
          SetGadgetText(DC::#Text_123," ?? ??")            
          SetGadgetText(DC::#Text_124," Laufwerk Nicht Initialisiert")   
          ProcedureReturn #False
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Programm läuft, Merke von OpenCBM das Diskdrive
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_OpenCBM_GetDiskDrive(*Params.PROGRAM_BOOT)
        
        Protected Position.i
        
        C64DskDriveHard$ = ""
        C64DskInterface$ = Trim( *Params\Logging )

        Position = FindString(*Params\Logging, "8:",1)
        If (Position <> 0)
            RealDiskDrive$   = "8" 
            C64DskDriveHard$ = Mid( C64DskInterface$, Position+2, Len(C64DskInterface$) - Position+2) 
            ProcedureReturn
        EndIf    
        
        Position = FindString(*Params\Logging, "9:",1)
        If (Position <> 0)
            RealDiskDrive$ = "9" 
            C64DskDriveHard$ = Mid( C64DskInterface$, Position+2, Len(C64DskInterface$) - Position+2)             
            ProcedureReturn
        EndIf
        
        Position = FindString(*Params\Logging, "10:",1)
        If (Position <> 0)
            RealDiskDrive$ = "10" 
            C64DskDriveHard$ = Mid( C64DskInterface$, Position+2, Len(C64DskInterface$) - Position+2)             
            ProcedureReturn
        EndIf                   
        
        Position = FindString(*Params\Logging, "11:",1)
        If (Position <> 0)
            RealDiskDrive$ = "11" 
            C64DskDriveHard$ = Mid( C64DskInterface$, Position+2, Len(C64DskInterface$) - Position+2)             
            ProcedureReturn
        EndIf                   
        

     DSK_OpenCBM_ErrDiskDrive()         
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Programm läuft, OpenCBM Commando Schleife
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)
        
        Protected ErrOut$ = "", SdtOut$ ="", DOS_NOP = 1
        C64LoadS8_Spin = 0
        Repeat
        ;While ProgramRunning(l_ProcID) 
            If AvailableProgramOutput(*Params\LowProcess)   
 
                             
                SdtOut$ = ReadProgramString(*Params\LowProcess)
                
                If ( Len(SdtOut$) <> 0 )                    
                    *Params\Logging = *Params\Logging + SdtOut$
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #LOGGING : " + *Params\Logging )                     
                EndIf  
                
                                
                ErrOut$ = ReadProgramError(*Params\LowProcess)
                If ( Len(ErrOut$) <> 0 )                    
                    *Params\StError = *Params\StError + ErrOut$
                    Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #STD.OUT : " +  *Params\StError)                  
                EndIf
                ;Delay(1)
            EndIf                                                
            ;Wend  
            
            
            If Not (ProgramRunning(*Params\LowProcess))
                DOS_NOP = 0
            EndIf            
        Until DOS_NOP = 0              
        
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Programm läuft, Hole das Verzeichnis (Image Basiert)
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_StdOut(Line.s)
        
        Protected Track$, SectorView$
        ;   1: --*------------------     0%     1/683
        ;  35: *****************       100%   683/683
        
        Track$      = Mid(Line, 1, 3)
        Track$      = Trim(Track$, Chr(13) )
        Track$      = Trim(Track$, Chr(32) )
        
        SectorView$ = Mid(Line, 6, 21)
        Percent$    = Trim( Mid(Line, 31, 4) )
        Cylinder$   = Trim( Mid(Line, 37, 7) )
        
        SetGadgetText(DC::#Text_123, " " + Cylinder$)
        
        For Tracks = 0 To 39
            
            If ( Str(Tracks) = Track$ ) And ( Len(Percent$) >= 1 )
                If Percent$ = "00%"
                    Percent$ = "100%"
                EndIf    
                SetGadgetItemText(DC::#ListIcon_003,Tracks-1,  " " +RSet(Str(Tracks),2,"0"), 0)
                SetGadgetItemText(DC::#ListIcon_003,Tracks-1,  SectorView$, 1) 
                SetGadgetItemText(DC::#ListIcon_003,Tracks-1,  RSet(Percent$,4,"0"), 2) 
                
                ;
                ; Autoscroll
                ;SendMessage_(GadgetID(DC::#ListIcon_003),#LVM_ENSUREVISIBLE,CountGadgetItems(DC::#ListIcon_003)-1,0)
                ProcedureReturn
            EndIf
        Next
                
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Programm läuft, Hole das Verzeichnis (Image Basiert)
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_Modus_D64ImageBackup(*Params.PROGRAM_BOOT)
                        
        Protected ErrOut$ = "", SdtOut$ ="", DOS_NOP = 1, DSK_StdOut$
        C64LoadS8_Spin = 0
 
        For Tracks = 0 To 39
            AddGadgetItem(DC::#ListIcon_003, Tracks-1, " " +RSet(Str(Tracks),2,"0") + Chr(10) +""+ Chr(10) + "" )
        Next    
            
        While ProgramRunning(*Params\LowProcess)
            bytes.i= AvailableProgramOutput(*Params\LowProcess)
            
            If bytes
                *CMDBuffer = AllocateMemory(bytes)
                
                ReadProgramData(*Params\LowProcess, *CMDBuffer, bytes)
                DSK_StdOut$ = PeekS(*CMDBuffer, bytes, #PB_Ascii)
                
                If ( FindString( DSK_StdOut$ , "[Fatal]",1 ) )
                    *Params\Logging = DSK_StdOut$
                    ProcedureReturn
                EndIf
                
                If ( FindString( DSK_StdOut$ , "blocks copied.",1 ) )
                    *Params\Logging = DSK_StdOut$
                    ProcedureReturn
                EndIf                
                
                FreeMemory(*CMDBuffer)
                
                DSK_StdOut( DSK_StdOut$ )                 
            EndIf
           ; Delay(200)
        Wend                                                    
    EndProcedure    
    
    ;****************************************************************************************************************************************************************
    ; Programm läuft, Hole das Verzeichnis (Image Basiert)
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_StdOut_FormatTable(Sign.s, SignCount.i)
        
        Protected Track$ = "", CurrentLineTrack = 0, Views.i, Current_Cylinder = 0
        
        Debug Sign
        If ( SignCount >= 1 ) And  ( SignCount <= 10 )       
            CurrentLineTrack = 3 
            Current_Cylinder = SignCount
        
        ElseIf ( SignCount >= 11 ) And  ( SignCount <= 20 )       
            CurrentLineTrack = 4
            Current_Cylinder = SignCount - 10
        
        ElseIf ( SignCount >= 21 ) And  ( SignCount <= 30 )       
            CurrentLineTrack = 5
            Current_Cylinder = SignCount - 20
        
        ElseIf ( SignCount >= 31 )       
            CurrentLineTrack = 6
            Current_Cylinder = SignCount - 30
        EndIf            
        
        For Views = 1 To Current_Cylinder
            Track$ + "#"
        Next    
        
        If ( INVMNU::*LHMNU64\FORM40 = #True )
            FormatFourty$ + "/40"
        Else
            FormatFourty$ + "/35"
        EndIf
        
        If ( INVMNU::*LHMNU64\FORM40 = #True ) And (SignCount+1 = 41) 
            SetGadgetItemText(DC::#ListIcon_003,8,  "... FINISHED 40 TRACKS, PLEASE WAIT", 1) 
        EndIf
        
        If ( INVMNU::*LHMNU64\FORM40 = #False ) And (SignCount+1 = 36) 
            SetGadgetItemText(DC::#ListIcon_003,8,  "... FINISHED 35 TRACKS, PLEASE WAIT", 1) 
        EndIf        
 
        For Tracks = 3 To 6
            
            If ( Tracks = CurrentLineTrack )                
                SetGadgetItemText(DC::#ListIcon_003,Tracks,  RSet(Str(Tracks-2),2,"0"), 0)
                SetGadgetItemText(DC::#ListIcon_003,Tracks,  LSet(Track$,10,"-"),1) 
                SetGadgetItemText(DC::#ListIcon_003,Tracks,  RSet(Str(SignCount),2,"0")+FormatFourty$, 2) 
                ProcedureReturn SignCount
            EndIf
        Next
                
    EndProcedure  
    
    ;****************************************************************************************************************************************************************
    ; Format Drive
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_Thread_FormatDiskDrive(*Params.PROGRAM_BOOT)
                        
        Protected ErrOut$ = "", SdtOut$ ="", SignCount = 0, FormatFourty$ = ""
        C64LoadS8_Spin = 0
                        
        ClearGadgetItems(DC::#ListIcon_003)        
        
        AddGadgetItem(DC::#ListIcon_003, 0, "")
        AddGadgetItem(DC::#ListIcon_003, 1, "" + Chr(10) +"N:" +UCase(C64Format_Name$) + Chr(10) + "TRACK" ) 
        AddGadgetItem(DC::#ListIcon_003, 2, "")
        
        For Tracks = 3 To 6
            AddGadgetItem(DC::#ListIcon_003, Tracks, RSet(Str(Tracks-2),2," ") + Chr(10) +"----------"+ Chr(10) + "" )
        Next                    
        
        AddGadgetItem(DC::#ListIcon_003, 7, "")
        AddGadgetItem(DC::#ListIcon_003, 8, "")       
        
        While ProgramRunning(*Params\LowProcess)
            bytes.i= AvailableProgramOutput(*Params\LowProcess)
            
            If bytes
                *CMDBuffer = AllocateMemory(bytes)
                
                ReadProgramData(*Params\LowProcess, *CMDBuffer, bytes)
                
                StdOut$   = PeekS(*CMDBuffer, bytes, #PB_Ascii)  
                SignCount + 1                           
                
                FreeMemory(*CMDBuffer)
                
                SignCount = DSK_StdOut_FormatTable(StdOut$, SignCount.i)               
                
            EndIf
            ;Delay(200)
        Wend                                                    
    EndProcedure      
    ;****************************************************************************************************************************************************************
    ; Programm läuft, Hole das Verzeichnis (Image Basiert)
    ;________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_Modus_D64ImageRead(*Params.PROGRAM_BOOT)
        
                Protected Image_Text$, DiskHeader$, DiskBottom$, DiskInhalt$
                While ProgramRunning(*Params\LowProcess) 
                    Image_Text$ = ReadProgramString(*Params\LowProcess) 
                    EndOfFile   + 1
                    Select EndOfFile
                        Case 1
                           For i = 48 To 57                
                                If ( FindString(Image_Text$, Chr(i), 0) = 1 )                              
                                    AddElement(D64()): D64()\dskFileName = Image_Text$: DiskHeader$ = Image_Text$
                                    Break;
                                EndIf
                            Next
                            
                        Default
                            If ( FindString(Image_Text$, "blocks free", 2,0) > 2 )                                                 
                                AddElement(D64()): D64()\dskFileName = Image_Text$: DiskBottom$ = Image_Text$
                            Else                     
                                For i = 48 To 57  
                                    If ( FindString(Image_Text$, Chr(i), 0) = 1 )                                                                 
                                        AddElement(D64()): D64()\dskFileName = Image_Text$: DiskInhalt$ = DiskInhalt$ +Chr(13)+ Image_Text$   
                                        Break;
                                    EndIf
                                Next
                            EndIf
                    EndSelect                
                    ;Delay(1) 
                Wend  
                 
             Request::SetDebugLog("Image: Content : ---------------------------------------  " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
             Request::SetDebugLog("Image: Content : "+DiskHeader$ +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))    
             Request::SetDebugLog("Image: Content : ---------------------------------------  " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
             Request::SetDebugLog("Image: Content : "+DiskInhalt$ +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))            
             Request::SetDebugLog("Image: Content : ---------------------------------------  " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))        
             Request::SetDebugLog("Image: Content : "+DiskBottom$ +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                                                      
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Programm läuft,  While ProgramRunnin...., Modus
    ;________________________________________________________________________________________________________________________________________________________________                       
    Procedure.s DSK_Thread_PrgLoop(*Params.PROGRAM_BOOT)
        
        Protected Mame_Window.i, DOS_NOP = 1, WindowState = #False, StdOutErrors$, FatalError_A$, FatalError_B$        

        Select *Params\Modus$
            Case "D64ImageRead"                     : DSK_Modus_D64ImageRead(*Params.PROGRAM_BOOT)
                ProcedureReturn
                
            Case "OpenCBM.cbmctrl.reset"            : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT) 
                ProcedureReturn
                
            Case "OpenCBM.cbmctrl.command"          : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT) 
                ProcedureReturn                
                
            Case "OpenCBM.cbmctrl.status"           : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn
                
            Case "OpenCBM.cbmctrl.detect"           : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn   
                
            Case "OpenCBM.cbmctrl.format"           : DSK_Thread_FormatDiskDrive(*Params.PROGRAM_BOOT)                 
                ProcedureReturn  
                
            Case "OpenCBM.cbmctrl.rename"           : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn 
                
            Case "OpenCBM.cbmctrl.scratch"          : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn                 
                
            Case "OpenCBM.cbmctrl.directory"        : DSK_OpenCBM_GetDirectory(*Params.PROGRAM_BOOT)                 
                ProcedureReturn                
                
            Case "OpenCBM.cbmctrl.copyfiletopc"     : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn                 
                
            Case "OpenCBM.cbmctrl.copypcfileto1541" : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn   
                
            Case "OpenCBM.cbmctrl.copyimgfileto1541": DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn   
                
            Case "OpenCBM.cbmctrl.validate"         : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn                 
                
            Case "OpenCBM.cbmctrl.backupimage"      : ClearGadgetItems(DC::#ListIcon_003): DSK_Modus_D64ImageBackup(*Params.PROGRAM_BOOT)                 
                ProcedureReturn      
                
            Case "OpenCBM.cbmctrl.transferimage"    : ClearGadgetItems(DC::#ListIcon_003): DSK_Modus_D64ImageBackup(*Params.PROGRAM_BOOT)                 
                ProcedureReturn   
                
            Case "OpenCBM.cbmctrl.newimage"         : DSK_Thread_OpenCBMInit(*Params.PROGRAM_BOOT)                 
                ProcedureReturn                    

            Default 
         EndSelect                                                         
        ;Delay(1)                
        ProcedureReturn ""        
    EndProcedure            
    ;****************************************************************************************************************************************************************
    ; Programm läuft,  While ProgramRunnin.... Game Mode
    ;________________________________________________________________________________________________________________________________________________________________                                
    Procedure DSK_Thread_Create(*Params.PROGRAM_BOOT)
                
        Protected l_ProcID.l, h_ProcID.l, exitCodeH, exitCodeL                
                           
        *Params\LowProcess = RunProgram(*Params\PrgPath +  *Params\Program,*Params\Command,*Params\WrkPath,*Params\PrgFlag, #PB_Program_Ascii): Delay(255)            
                
        If ( *Params\LowProcess = 0 ) Or (IsProgram(*Params\LowProcess) = 0)
            ProcedureReturn
        EndIf
                            
        h_ProcID = OpenProcess_(#PROCESS_QUERY_INFORMATION, 0, ProgramID(*Params\LowProcess))          
                     
        DSK_Thread_PrgLoop(*Params.PROGRAM_BOOT)    
        
        GetExitCodeProcess_(h_ProcID, @exitCodeH): GetExitCodeProcess_(*Params\LowProcess, @exitCodeL)
               
        CloseProgram(*Params\LowProcess)
             
                     
    EndProcedure            
    ;****************************************************************************************************************************************************************
    ; Startet Programm (Threaded)
    ;________________________________________________________________________________________________________________________________________________________________               
    Procedure DSK_Thread(*Params.PROGRAM_BOOT)                     
            LockMutex(C64LoadS8_Mutx)
                   
            ;Delay(25)
            
            DSK_Thread_Create(*Params.PROGRAM_BOOT)        
            UnlockMutex(C64LoadS8_Mutx)
            ProcedureReturn
        EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Startet Programm (Vorbereitung)
    ;________________________________________________________________________________________________________________________________________________________________          
    Procedure.i DSK_Thread_Prepare(Program$, Command$, Modus$)            
        
        Protected sTime.i, EyeStdError$ = ""
        
        *Params.PROGRAM_BOOT = AllocateMemory(SizeOf(PROGRAM_BOOT))
        InitializeStructure(*Params, PROGRAM_BOOT)
        
        
            *Params\PrgPath         = ""        
            *Params\Program         = Program$ 
            *Params\WrkPath         = GetPathPart(Program$)
            *Params\Command         = Command$
            *Params\Logging         = ""
            *Params\ExError         = 0
            *Params\PrgFlag         = #PB_Program_Open|#PB_Program_Read|#PB_Program_Error|#PB_Program_Hide
            *Params\StError         = ""
            *Params\Modus$          = Modus$
    
            ;
            ; Normalisiere, 
            *Params\PrgPath         = GetPathPart(*Params\Program)
            *Params\Program         = GetFilePart(*Params\Program)
            
            If (Len(*Params\Program) = 0 ):
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to Run. Please Select a Program",2,2,"",0,0,DC::#_Window_005)
                ProcedureReturn
            EndIf 
            
            If (FileSize(*Params\PrgPath) <> -2 )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Program Folder Does Not Exists",2,2,"",0,0,DC::#_Window_005)
                ProcedureReturn
            EndIf 
            
            If (FileSize(*Params\PrgPath + *Params\Program  ) = -1 )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to Run. Cant Find it..",2,2,"",0,0,DC::#_Window_005)
                ProcedureReturn
            EndIf              
            
            TxtString_Abort$ = UCase( " (Press Escape to Abort) ") 
            
            
            SetGadgetText(DC::#Text_122, TxtString_Abort$)              
            Gadgets_Enbale_Disble(#True)
            
            Select *Params\Modus$ 
                    ;
                    ; 
                Case "OpenCBM.cbmctrl.reset"                  
                    SetGadgetText(DC::#Text_123," INIT")                     
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Reset ...")                      
                    ;
                    ; 
                Case "OpenCBM.cbmctrl.detect"
                    SetGadgetText(DC::#Text_123," INIT")                     
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Get IO Number")                                       
                    ;
                    ; 
                Case "OpenCBM.cbmctrl.command"
                    SetGadgetText(DC::#Text_123," INIT")                     
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Get IO Interface")                     
                    ;
                    ;
                Case "OpenCBM.cbmctrl.status" 
                    SetGadgetText(DC::#Text_123," INIT")                       
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Get Status")                    
                    ;
                    ;
                Case "OpenCBM.cbmctrl.directory" 
                    SetGadgetText(DC::#Text_123," LIST")                      
                    SetGadgetText(DC::#Text_124," Read Directory .. LOAD" +Chr(34)+ "$" +Chr(34)+ "," +RealDiskDrive$)
                    
                Case "OpenCBM.cbmctrl.format", "OpenCBM.cbmctrl.format2"  
                    SetGadgetText(DC::#Text_123," FORMAT")                       
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Format Drive " + RealDiskDrive$ + ": ...") 
                    
                Case "OpenCBM.cbmctrl.validate" 
                    SetGadgetText(DC::#Text_123," VALIDATE")                       
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Validate Drive " + RealDiskDrive$ + ": ...") 
                    
                Case "OpenCBM.cbmctrl.copyfiletopc" :  
                    SetGadgetText(DC::#Text_123," COPY")                     
                    SetGadgetText(DC::#Text_124," Copy " + C64LoadS8_CopyF$+" ...") 
                    
                Case "OpenCBM.cbmctrl.scratch" : 
                    SetGadgetText(DC::#Text_123," SCRATCH")   
                    SetGadgetText(DC::#Text_124," Scratch " + C64LoadS8_CopyF$+" ...") 
                    
                Case "OpenCBM.cbmctrl.rename" : 
                    SetGadgetText(DC::#Text_123," RENAME")   
                    SetGadgetText(DC::#Text_124," Rename " + C64LoadS8_CopyF$+" ...")  
                    
                Case "OpenCBM.cbmctrl.copypcfileto1541" :   
                    SetGadgetText(DC::#Text_123," COPY")                     
                    SetGadgetText(DC::#Text_124," Copy " + C64LoadS8_CopyF$+" ...") 
                    
                Case "OpenCBM.cbmctrl.copyimgfileto1541" :  
                    SetGadgetText(DC::#Text_123," COPY")                     
                    SetGadgetText(DC::#Text_124," Copy " + C64LoadS8_CopyF$+" ...")                    
                    
                Case "OpenCBM.cbmctrl.backupimage" :
                    SetGadgetText(DC::#Text_122, "")                      
                    SetGadgetText(DC::#Text_124," Create: " + C64LoadS8_CopyF$+" ...")                         
                    
                Case "OpenCBM.cbmctrl.transferimage" : 
                    SetGadgetText(DC::#Text_122, "")                     
                    SetGadgetText(DC::#Text_124," Write: " + C64LoadS8_CopyF$+" ... to "+ C64DskDriveHard$ )  
                    
                Default                
                    ;
                    ;
            EndSelect        
            
            C64LoadS8_Spin = 0
            C64LoadS8_Mutx = CreateMutex():            
            
            _Action1 = 0:
            _Action1 = CreateThread(@DSK_Thread(),*Params)
            
            sTime.i = Second(Date())
            InitKeyboard()
            While IsThread(_Action1)
                
                If sTime <> Second(Date())
                    sTime.i = Second(Date())
                    C64LoadS8_Spin + 1                   
                EndIf
                SetGadgetText(DC::#Text_121, " "+Str(C64LoadS8_Spin))   
                If GetActiveWindow() =  DC::#_Window_005
                    If KeyIsDown(#VK_ESCAPE) 
                            If ( *Params\LowProcess <> 0 )
                                KillProgram(*Params\LowProcess)
                            EndIf                        
                            KillThread(_Action1)   
                            Delay(500)                  
                            *Params\Modus$ = "OpenCBM.cbmctrl.ThreadBreach"
                        EndIf
                EndIf
                Delay(25)
                While WindowEvent()                   
                Wend
            Wend              
                                                       
            If  ( Len(*Params\StError) >= 1 )  
                                                                   
                    xReturn = 60
                    For i = 1 To 5000                                
                        
                        ;
                        ; Don't bomb the Screen
                        If ( Len(*Params\StError) = i ) Or (i = 5000) 
                            Break;
                        Else
                             asci.i = Asc(Mid(*Params\StError,i,1) )
                             EyeStdError$ + Chr(asci)
                             
                            If ( Len(EyeStdError$) >= xReturn ) And ( asci = 32)
                                EyeStdError$ + Chr(13)
                                xReturn+60
                            EndIf                            
                        EndIf
                     Next   
                                          
                     Request::MSG(Startup::*LHGameDB\TitleVersion,"W.T.F. Output: " + GetFilePart(*Params\Program),*Params\Logging + Chr(13) + Chr(13) + EyeStdError$,2,2,*Params\PrgPath + *Params\Program,0,0,DC::#_Window_005)
                     SetActiveGadget(DC::#ListIcon_003): 
            EndIf 
                                                
            Select *Params\Modus$ 
                Case "OpenCBM.cbmctrl.detect"
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$) 
                    SetGadgetText(DC::#Text_124,"")                  
                    DSK_OpenCBM_GetDiskDrive(*Params.PROGRAM_BOOT)
                    ;
                    ; 
                Case "OpenCBM.cbmctrl.command"
                    SetGadgetText(DC::#Text_122,"")                       
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                   
                    SetGadgetText(DC::#Text_124,"")
                    ;
                    ;
                Case "OpenCBM.cbmctrl.status" 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                        
                    SetGadgetText(DC::#Text_124," Disk Drive Status: " + *Params\Logging)   
                    LastDrive_Error$ = *Params\Logging
                    ;
                    ;
                Case "OpenCBM.cbmctrl.directory" 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                    
                    SetGadgetText(DC::#Text_124,"")                     
                    
                Case "OpenCBM.cbmctrl.format" 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                          
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Format Drive " + RealDiskDrive$ + ": Finished ...") 
                    
                Case "OpenCBM.cbmctrl.format2" 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                          
                    SetGadgetText(DC::#Text_124," Wait for Format is Finishd (Check the Lights) ...")                     
                    
                Case "OpenCBM.cbmctrl.copyfiletopc" :
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                     
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Copy Finished ... ") 
                    
                Case "OpenCBM.cbmctrl.copyfiletopc" :
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                     
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Copy Finished ... ") 
                    
                Case "OpenCBM.cbmctrl.scratch" : 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123,"")                    
                    SetGadgetText(DC::#Text_124,"")  
                    
                Case "OpenCBM.cbmctrl.rename" 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                    
                    SetGadgetText(DC::#Text_124,"") 
                    
                Case "OpenCBM.cbmctrl.validate" 
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123," "+C64DskInterface$)                          
                    SetGadgetText(DC::#Text_124," Disk Drive Status: Validate Drive " + RealDiskDrive$ + ": Finished ...") 
                    
                Case "OpenCBM.cbmctrl.copyimgfileto1541" :  
                    SetGadgetText(DC::#Text_122,"")                      
                    SetGadgetText(DC::#Text_123,"")                    
                    SetGadgetText(DC::#Text_124,"")                          
                    
                Case "OpenCBM.cbmctrl.backupimage" :                    
                    SetGadgetText(DC::#Text_124," "+*Params\Logging)
                    
                Case "OpenCBM.cbmctrl.transferimage" :                    
                    SetGadgetText(DC::#Text_124," "+*Params\Logging)
                    
                Case "OpenCBM.cbmctrl.ThreadBreach":
                    SetGadgetText(DC::#Text_123,"")                      
                    SetGadgetText(DC::#Text_122,UCase( " There was a Error on OpenCBM")) 
                    SetGadgetText(DC::#Text_122," ERROR")                     
                    SetGadgetText(DC::#Text_124," Please Unplug and turn off and turn on agin your Drive")
                    
                    
                Default                                    
            EndSelect               
            

            Gadgets_Enbale_Disble(#False)
     EndProcedure 
    ;****************************************************************************************************************************************************************
    ; Packer Support für das erstellen von Sicherheitskopien
    ;________________________________________________________________________________________________________________________________________________________________     
     Procedure.s PackerSupport_Create_FileCopy(DiskImageFile$, PackCopyCount = 0)
         
         Protected nDiskKopie = 0, Disk_Path$ = "", Disk_Name$ = "", Disk_Pattern$ = "", Result.i, NewDiskImage$
         Disk_Path$    = GetPathPart(DiskImageFile$)
         Disk_Name$    = GetFilePart(DiskImageFile$, #PB_FileSystem_NoExtension)
         Disk_Pattern$ = GetExtensionPart(DiskImageFile$)         
         ;
         ; Check For Packed Format
         Select UCase( Disk_Pattern$ )
             Case "ZIP", "7Z", "RAR":
                 ; Bearbeiten von Komprimierte Disk Archiven
                 ; Ist so eine Sache !
                 ; Vorgang:
                 ; - Das Image Liegt im Temp
                 ; - Eine Archiv Kopie wird erstellt
                 ; - Rename, Scratch wird abgearbeitet
                 ; - Diese Datei wird wieder gepackt
                 ; - Kopiert wird si dan zum ursprünglichen ort
                 ; - Geladen und angezeigt
                 
                 ;
                 ; Kopie Eerstellen 
                 Select UCase( Disk_Pattern$ )
                     Case "7Z"
                         Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Support For 7z",5,2,"",0,0,DC::#_Window_005)
                         SetActiveGadget(DC::#ListIcon_003): ProcedureReturn ""           
                         
                     Case "RAR"
                         Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Support For RAR",5,2,"",0,0,DC::#_Window_005)
                         SetActiveGadget(DC::#ListIcon_003): ProcedureReturn ""      
                 EndSelect      
                 ;
                 ; NoCopy: Übergebe nur den Temporären Dateinamen 
                 If ( PackCopyCount = 1)
                     Repeat             
                         nDiskKopie + 1
                         NewDiskImage$ = Disk_Path$ + Disk_Name$ + "(Kopie " + RSet( Str(nDiskKopie),3,"0" ) + ")." + Disk_Pattern$
                         
                         If ( FileSize( NewDiskImage$ ) = -1 )
                             Result = CopyFile( DiskImageFile$, NewDiskImage$ )
                         EndIf 
                         
                         ;
                         ; Excceed
                         If ( nDiskKopie >= 999 )
                             Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","You Have 1000 Copys from"+#CR$+ Disk_Path$ + Disk_Name$+"." + Disk_Pattern$,5,2,"",0,0,DC::#_Window_005)
                             SetActiveGadget(DC::#ListIcon_003)
                             ProcedureReturn ""
                         EndIf     
                         
                     Until (Result <> 0) 
                 EndIf                                                                       
                 ProcedureReturn C64_PackedImage$
             Default        
                 ProcedureReturn DiskImageFile$
         EndSelect
     EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        Erstelle neue PackDatei vom bearbeiteten Image 
    ;______________________________________________________________________________________________________________________________________________________________________        
     Procedure.i PackerSupport_Create_PackFile()
         
         Protected Disk_Path$ = "", Disk_Name$ = "", Disk_Pattern$ = "", NewDiskImage$, PBPackPlugin.i, PBPackLevel.i = 0, TemporaryD64$ =""
         
         DiskImageFile$ = GetGadgetText(DC::#String_102)
         
         Disk_Path$    = GetPathPart(DiskImageFile$)
         Disk_Name$    = GetFilePart(DiskImageFile$, #PB_FileSystem_NoExtension)
         Disk_Pattern$ = GetExtensionPart(DiskImageFile$)  
         
         TemporaryD64$ = C64_PackedImage$
         
         If ( Len( TemporaryD64$ ) = 0 )
             ProcedureReturn #True
         EndIf    
         
         Select UCase( Disk_Pattern$ )
             Case "ZIP", "7Z", "RAR":  

                 Select UCase( Disk_Pattern$ )
                     Case "ZIP"
                         PBPackPlugin.i = #PB_PackerPlugin_Zip 
                         PBPackLevel.i  = 9
                     Case "7Z"
                         Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Support For 7z",5,2,"",0,0,DC::#_Window_005)
                         SetActiveGadget(DC::#ListIcon_003): ProcedureReturn #False
                     Case "RAR" 
                         Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Support For RAR",5,2,"",0,0,DC::#_Window_005)
                         SetActiveGadget(DC::#ListIcon_003): ProcedureReturn #False                          
                 EndSelect                            
                 
                 
                 If ( CreatePack(DC::#PackFile, DiskImageFile$, PBPackPlugin, PBPackLevel) ) 
                     
                     AddPackFile(DC::#PackFile, TemporaryD64$, Disk_Name$ + "." + GetExtensionPart(TemporaryD64$) ) 
                     
                     ClosePack(DC::#PackFile): Delay(1): ProcedureReturn #True
                 EndIf 
             Default
         EndSelect  
         
     EndProcedure             
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i Item_Clear()        
         SetGadgetText(DC::#String_100, "")                
         SetGadgetText(DC::#String_104, "") 
         SetGadgetText(DC::#Text_121,"")
         SetGadgetText(DC::#Text_122,"")
         SetGadgetText(DC::#Text_123,"")  
         SetGadgetText(DC::#Text_124,"")
         ClearGadgetItems(DC::#ListIcon_003)
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.i Item_ChangeFont()
        
        Select Startup::*LHGameDB\CBMFONT                
            Case FontID(Fonts::#_C64_CHARS)
                Startup::*LHGameDB\CBMFONT = FontID(Fonts::#_C64_CHARS2)                               
            Case FontID(Fonts::#_C64_CHARS2)
                Startup::*LHGameDB\CBMFONT = FontID(Fonts::#_C64_CHARS)                  
        EndSelect
        SetGadgetFont(DC::#ListIcon_003, Startup::*LHGameDB\CBMFONT) 
        SetGadgetFont(DC::#Text_122, Startup::*LHGameDB\CBMFONT)       
        SetGadgetFont(DC::#Text_123, Startup::*LHGameDB\CBMFONT)     
        
        ;SetGadgetFont(DC::#String_100, Startup::*LHGameDB\CBMFONT)       
        ;SetGadgetFont(DC::#String_104, Startup::*LHGameDB\CBMFONT)        
    EndProcedure
    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i DSK_SaveOldFilename()              
        C64LoadS8_OldFN$ = GetGadgetText(C64LoadS8_TXID)                
    EndProcedure  
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i DSK_LoadOldFilename()              
        SetGadgetText(C64LoadS8_TXID, C64LoadS8_OldFN$)                
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s ConvertFont_PetsciToAscii(sText$)
        Protected  Pos.i, c.c
        
        *c.CharFont = AllocateMemory( SizeOf(CharFont) )
        
        PokeS( *c, sText$, 16, #PB_Ascii)
        
        For Pos = 0 To 15
            
            c = *c\c[Pos]
            
            Select c 
                    ;
                    ; Convet other Signt to '*' for Vice Startup Load                    
                Case 163 To 193, 219 To 255
                    c = 42
                Case 160
                    c = 0                    
                Case 193 To 218
                    c - 128
                Case 'A' To 'Z'
                    c + 32
                Case 'a' To 'z'    
                    c - 32
                Default                    
            EndSelect 
            
            *c\c[Pos] = c
        Next

        sText$ = PeekS( *c, 16, #PB_Ascii): FreeMemory(*c)
        ;sText$ = Trim(sText$)
        ProcedureReturn sText$
    EndProcedure   
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s ConvertFont_AsciiTooPetsci(sText$)
        Protected  Pos.i, c.c
        
        *c.CharFont = AllocateMemory( SizeOf(CharFont) )
        
        
        
        PokeS( *c, sText$, 16, #PB_Ascii)
        
        
        For Pos = 0 To 15
            
            c = *c\c[Pos]            
            Select c
                Case 65 To 90
                    c - 128
                Case 'A' To 'Z'
                    c + 32
                Case 'a' To 'z'    
                    c - 32
                Case 0
                    c = 160
                Default 
                    
            EndSelect 
            
            *c\c[Pos] = c
        Next
        
        sText$ = PeekS( *c, 16, #PB_Ascii): FreeMemory(*c)
        ProcedureReturn sText$
    EndProcedure      
    ;******************************************************************************************************************************************
    ;    
    ;__________________________________________________________________________________________________________________________________________       
    Procedure.s Item_Select_List()
                
        Protected Liste.i =  DC::#ListIcon_003, DiskImageFilename$ = "", DiskImageSuffix$ = ""     
        
        SetActiveGadget(DC::#ListIcon_003): 
        
        
        DiskImageFilename$ = GetGadgetItemText(Liste,GetGadgetState(Liste),1)
        DiskImageFilename$ = Trim(DiskImageFilename$,Chr(34))
              
        DiskImageSuffix$ = GetGadgetItemText(Liste,GetGadgetState(Liste),2)
        DiskImageSuffix$ = Trim(DiskImageSuffix$,Chr(34))
        DiskImageSuffix$ = Trim(DiskImageSuffix$,Chr(32))        
                
        Select UCase(DiskImageSuffix$)
            Case "PRG", "PRG<"  
                
                Select UseCBMModule
                    Case #False
                        SetGadgetText(DC::#String_100, DSK_SetCharSet(DiskImageFilename$))  
                        SetGadgetText(C64LoadS8_TXID,  DSK_SetCharSet(DiskImageFilename$))                    
                    Case #True
                        SetGadgetText(DC::#String_100, ConvertFont_PetsciToAscii(DiskImageFilename$))  
                        SetGadgetText(C64LoadS8_TXID,  ConvertFont_PetsciToAscii(DiskImageFilename$))                     
                EndSelect        
                SetGadgetText(DC::#String_104, DiskImageSuffix$) 
                vItemC64E_CanClose = #True
                
            Case ":RUN<"
                SetGadgetText(DC::#String_100, "*")                
                SetGadgetText(DC::#String_104, ":RUN<")                 
                SetGadgetText(C64LoadS8_TXID,  "*")                 
            Default
                ;SetGadgetText(DC::#String_100, "«® FILE IS NOT USABLE TO LOAD °³")                
                ;SetGadgetText(DC::#String_104, "ÀÀÀ") 
                SetGadgetText(DC::#String_100, "*")                
                SetGadgetText(DC::#String_104, "")                 
                SetGadgetText(C64LoadS8_TXID,  "")   
        EndSelect  
        
        
     EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
    Procedure.i Item_State_Check()

        
        Protected Liste.i =  DC::#ListIcon_003
        
        If ( GetGadgetItemState(Liste,GetGadgetState(Liste)) = -1 )            
            SetGadgetItemState(Liste,0,1):

            ProcedureReturn #False
        EndIf
        ProcedureReturn #True
    EndProcedure   
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s DSK_CmpCharSet(AFN$, sReplacer$ = "-")        
        
        Protected NFN$ = "", asci.a, i.i
        
        For i = 1 To Len(AFN$)            
            asci = Asc( Mid(AFN$,i,1) )           
            Select asci
                Case  34: NFN$ + sReplacer$     ; "    
                Case  42: NFN$ + "_(Asterisk)"  ; *                      
                Case  47: NFN$ + sReplacer$     ; /
                Case  58: NFN$ + sReplacer$     ; :
                Case  60: NFN$ + "_(Less-Than)" ; <
                Case  62: NFN$ + sReplacer$     ; >
                Case  63: NFN$ + sReplacer$     ; ?                       
                Case  92: NFN$ + sReplacer$     ; \  
                Case 127: NFN$ + sReplacer$     ; DEL  
                Default
                    NFN$ + Chr(asci)
            EndSelect     
        Next        
        ProcedureReturn NFN$
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________      
    Procedure.s DSK_SetCharSet(OldFileName$)
               
        Protected NewFileName$ = ""
        For i = 1 To Len(OldFileName$)
            
            asci.i = Asc( Mid(OldFileName$,i,1) )
                        
            Select asci.i
                Case  65: NewFileName$ + Chr(asci+32)
                Case  66: NewFileName$ + Chr(asci+32)                   
                Case  67: NewFileName$ + Chr(asci+32)   
                Case  68: NewFileName$ + Chr(asci+32)
                Case  69: NewFileName$ + Chr(asci+32)                   
                Case  70: NewFileName$ + Chr(asci+32)                      
                Case  71: NewFileName$ + Chr(asci+32)   
                Case  72: NewFileName$ + Chr(asci+32)   
                Case  73: NewFileName$ + Chr(asci+32)   
                Case  74: NewFileName$ + Chr(asci+32)   
                Case  75: NewFileName$ + Chr(asci+32)   
                Case  76: NewFileName$ + Chr(asci+32)   
                Case  77: NewFileName$ + Chr(asci+32)   
                Case  78: NewFileName$ + Chr(asci+32)   
                Case  79: NewFileName$ + Chr(asci+32)   
                Case  80: NewFileName$ + Chr(asci+32)     
                Case  81: NewFileName$ + Chr(asci+32)   
                Case  82: NewFileName$ + Chr(asci+32)   
                Case  83: NewFileName$ + Chr(asci+32)   
                Case  84: NewFileName$ + Chr(asci+32)   
                Case  85: NewFileName$ + Chr(asci+32)   
                Case  86: NewFileName$ + Chr(asci+32)   
                Case  87: NewFileName$ + Chr(asci+32)   
                Case  88: NewFileName$ + Chr(asci+32)   
                Case  89: NewFileName$ + Chr(asci+32)   
                Case  90: NewFileName$ + Chr(asci+32)  
 
                                          
                Case  97: NewFileName$ + Chr(asci-32)
                Case  98: NewFileName$ + Chr(asci-32)                   
                Case  99: NewFileName$ + Chr(asci-32)   
                Case 100: NewFileName$ + Chr(asci-32)
                Case 101: NewFileName$ + Chr(asci-32)                   
                Case 102: NewFileName$ + Chr(asci-32)                      
                Case 103: NewFileName$ + Chr(asci-32)   
                Case 104: NewFileName$ + Chr(asci-32)   
                Case 105: NewFileName$ + Chr(asci-32)   
                Case 106: NewFileName$ + Chr(asci-32)   
                Case 107: NewFileName$ + Chr(asci-32)   
                Case 108: NewFileName$ + Chr(asci-32)   
                Case 109: NewFileName$ + Chr(asci-32)   
                Case 110: NewFileName$ + Chr(asci-32)   
                Case 111: NewFileName$ + Chr(asci-32)   
                Case 112: NewFileName$ + Chr(asci-32)     
                Case 113: NewFileName$ + Chr(asci-32)   
                Case 114: NewFileName$ + Chr(asci-32)   
                Case 115: NewFileName$ + Chr(asci-32)   
                Case 116: NewFileName$ + Chr(asci-32)   
                Case 117: NewFileName$ + Chr(asci-32)   
                Case 118: NewFileName$ + Chr(asci-32)   
                Case 119: NewFileName$ + Chr(asci-32)   
                Case 120: NewFileName$ + Chr(asci-32)   
                Case 121: NewFileName$ + Chr(asci-32)   
                Case 122: NewFileName$ + Chr(asci-32)  
                    
                Case 127: NewFileName$ + Chr(asci+32)                     
                Case 128: NewFileName$ + Chr(asci+32)                      
                    
                Case 159: NewFileName$ + Chr(asci-32)                     
                Case 160: NewFileName$ + Chr(asci-32)  
                                     
                    
                    
                 Default
                     NewFileName$ + Chr(asci) 
            EndSelect                     
        Next
        ProcedureReturn NewFileName$
    EndProcedure
    
    Procedure Item_Add_Fastload()
       AddGadgetItem(DC::#ListIcon_003, -1, "   0"   +Chr(10)+         "----------------"+Chr(10)+ "*DEL<" )            
       AddGadgetItem(DC::#ListIcon_003, -1, "FSLOAD" +Chr(10)+         "^      **      ^"+Chr(10)+ ":RUN<" )
       AddGadgetItem(DC::#ListIcon_003, -1, "   0"   +Chr(10)+         "­ÀÀÀÀÀÀÀÀÀÀÀÀÀÀ½"+Chr(10)+ "*DEL<" ) 
    EndProcedure   
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
     Procedure Item_Compare_List(sStr$)
         
         Protected D64ListCnt.i, R64ListCnt.i, sCmp$, Chr34_Beg.i, Chr34_End.i
         
         D64ListCnt = -1
         R64ListCnt = -1
         
         ResetList( D64() ): ResetList( R64() )
         
         If ( C64LoadS8_Side = 1 )
             While NextElement( D64() )
                 sCmp$ =  D64()\dskFileName
                 
                 Chr34_Beg.i = FindString(sCmp$, Chr(34), 0)
                 Chr34_End.i = FindString(sCmp$, Chr(34), Chr34_Beg +1)                
                 
                 sCmp$       = Mid(sCmp$, Chr34_Beg +1, Chr34_End - Chr34_Beg - 1)
                 sCmp$       = DSK_SetCharSet(sCmp$)
                 
                 If ( sCmp$ = sStr$ )                     
                     Request::MSG(Startup::*LHGameDB\TitleVersion, "63,FILE EXISTS,00,00","Es wurde versucht, die Datei "+sCmp$+" mit einem auf"+#CR$+"der Diskette bereits existierenden Namen anzulegen." ,2,2,"",0,0,DC::#_Window_005) 
                     SetActiveGadget(DC::#ListIcon_003): ProcedureReturn 63                      
                 EndIf    
             Wend
             ProcedureReturn 0
         EndIf
         
         If ( C64LoadS8_Side = -1 )
             While NextElement( R64() )
                 sCmp$ =  R64()\dskFileName
                 
                 Chr34_Beg.i = FindString(sCmp$, Chr(34), 0)
                 Chr34_End.i = FindString(sCmp$, Chr(34), Chr34_Beg +1)                
                 
                 sCmp$       = Mid(sCmp$, Chr34_Beg +1, Chr34_End - Chr34_Beg - 1)
                 sCmp$       = DSK_SetCharSet(sCmp$)
                 
                 If ( sCmp$ = sStr$ )
                     Request::MSG(Startup::*LHGameDB\TitleVersion, "63,FILE EXISTS,00,00","Es wurde versucht, die Datei "+sCmp$+" mit einem auf"+#CR$+"der Diskette bereits existierenden Namen anzulegen." ,2,2,"",0,0,DC::#_Window_005) 
                     SetActiveGadget(DC::#ListIcon_003): ProcedureReturn 63                     
                 EndIf    
             Wend
             ProcedureReturn 0
         EndIf                           
     EndProcedure       
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i Item_Auto_Select()
        
        Protected cnt.i, Liste.i = DC::#ListIcon_003, CBM_FileName$, LST_FileName$
        
        cnt.i = CountGadgetItems(Liste.i)
        If ( cnt = -1 )
            ProcedureReturn #False
        EndIf
        
        Select UseCBMModule
            Case #False
                CBM_FileName$ = DSK_SetCharSet( GetGadgetText(C64LoadS8_TXID) )                  
            Case #True
                CBM_FileName$ = ConvertFont_AsciiTooPetsci( GetGadgetText(C64LoadS8_TXID) )                  
        EndSelect          
                
        If ( CBM_FileName$ = "" )
            SetGadgetItemState(Liste,0,1);
            Item_Select_List()
            ProcedureReturn
        EndIf    
            
        For i = 0 To cnt -1
            LST_FileName$ = Trim( GetGadgetItemText(Liste.i, i, 1), Chr(34) )
            If ( LST_FileName$ = CBM_FileName$ )
                SetGadgetItemState(Liste, i ,1);
                Item_Select_List()
                ProcedureReturn
            EndIf
        Next    
                
        SetGadgetItemState(Liste,0,1);        
        Item_Select_List()
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s ListImage_Content(Image_Text$, isFile = #True)
        
        Protected Chr34_Beg.i, Chr34_End.i, FileSze$, FileNme$, Suffix$
                
        FileSze$ = "";
        FileNme$ = "";
        Suffix$  = "";
        
        Chr34_Beg.i = FindString(Image_Text$, Chr(34), 0)
        Chr34_End.i = FindString(Image_Text$, Chr(34), Chr34_Beg +1)        
        
        FileSze$ = Mid(Image_Text$, 0, Chr34_Beg -1)
        FileNme$ = Mid(Image_Text$, Chr34_Beg +1, Chr34_End - Chr34_Beg - 1)
        Suffix$  = Mid(Image_Text$, Chr34_End +1, Len(Image_Text$) - Chr34_End)       
        
        FileNme$ = DSK_SetCharSet(FileNme$)
        Suffix$  = DSK_SetCharSet(Suffix$)
        
        FileSze$ = Trim(FileSze$)
        Suffix$ = Trim(Suffix$)
        
        Select isFile
            Case #True
                AddGadgetItem(DC::#ListIcon_003, -1, RSet(FileSze$,3," ") + Chr(10) + Chr(34)+ FileNme$ + Chr(34)+ Chr(10) + Suffix$)
                ProcedureReturn
            Case #False
                SetGadgetText(DC::#Text_121, " " +FileSze$)
                SetGadgetText(DC::#Text_122, Chr(34)+ FileNme$ + Chr(34))
                SetGadgetText(DC::#Text_123, "  " +Suffix$)
                ProcedureReturn
        EndSelect
       
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s ConvertFont_Petsci0To31(sText$)
        Protected  Pos.i, c.c
        
        *c.CharFont = AllocateMemory( SizeOf(CharFont) )
        
        PokeS( *c, sText$, 16, #PB_Ascii)
        
        For Pos = 0 To 15
            
            c = *c\c[Pos]
            
            Select c
                Case 0 
                    c = 32
                Case 1 To 31
                    c + 224
            EndSelect 
            
            *c\c[Pos] = c
        Next
        
        sText$ = PeekS( *c, 16, #PB_Ascii): FreeMemory(*c)
        ProcedureReturn sText$
    EndProcedure      
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure Module_LoadComma8(DELFiles = 0)
        
        UseModule CBMDiskImage  
      
        Item_Clear()
        If ( ListSize( CBMDirectoryList() ) > 0)
            ResetList( CBMDirectoryList() )
            Item_Add_Fastload()            
            While NextElement( CBMDirectoryList() )
                
                CBMFileSize.i = CBMDirectoryList()\C64Size
                CBMFileName.s = CBMDirectoryList()\C64File
                CBMFileType.S = CBMDirectoryList()\C64Type
                
                If Len(CBMFileName) = 0 And (FindString(CBMFileType,"*DEL",1) >= 1) And (DELFiles = 0)
                    Continue
                EndIf  
                
                If Len(CBMFileName) = 0 And (FindString(CBMFileType,"FRZ",1) >= 1) And (DELFiles = 0)
                    ;
                    ; T64 Memory Snapshots
                    Continue
                EndIf 
                ;CBMFileName = ConvertFont_Petsci0To31(CBMFileName)
                
                AddGadgetItem(DC::#ListIcon_003, -1, " " + RSet( Str(CBMFileSize), 3," ") +Chr(10)+ CBMFileName +Chr(10)+ CBMFileType)                             
            Wend             
         EndIf
    EndProcedure     
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________       
    Procedure.i Module_LoadDirectory( dsk$ )
        
        Protected sFreeBlocks$, GEOS$
        
        UseModule CBMDiskImage
        
        If ( CBM_Load_Directory( dsk$ ) ! -1)             
            Module_LoadComma8(DELFiles)
            
            SetGadgetText(DC::#Text_121, "BLOCKS")
            
            ;
            ; Show Disk Title
            SetGadgetText(DC::#Text_122, CBM_Disk_Image_Tools( dsk$) )             
            
            ;
            ; Show Disk ID
            SetGadgetText(DC::#Text_123, " " +CBM_Disk_Image_Tools( dsk$,  "ID") )               
            
            ;
            ; Show Disk Blocks/ Error
            sFreeBlocks$ = " " + CBM_Disk_Image_Tools( dsk$,  "FREE") + " blocks free."
            
            V(dsk$, #False, #True)
            sFreeBlocks$ + " / Errors [" + *er\s + "]"
            
            GEOS$        =  CBM_Disk_Image_Tools( dsk$,  "GEOSCHECK")
            If GEOS$
               sFreeBlocks$ + " / " + GEOS$
            EndIf
           
            SetGadgetText(DC::#Text_124, sFreeBlocks$ )  
            
            If ( ShowErrorAfter = #True) And ( *er\s <> "0" )
                
                If ( V(dsk$) = -1)
                    Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ",*er\s,2,2,"",0,0,DC::#_Window_005)  
                Else
                    Request::MSG(Startup::*LHGameDB\TitleVersion, "Found Errors",*er\s,2,2,"",0,0,DC::#_Window_005)  
                EndIf                  
            EndIf  
            
            ShowErrorAfter = #False
            SetActiveGadget(DC::#ListIcon_003):             
        EndIf    
        
    EndProcedure     
     ;**********************************************************************************************************************************************************************
     ;        
     ;______________________________________________________________________________________________________________________________________________________________________ 
     Procedure.i DSK_Image_Refresh()
         
         Select UseCBMModule
             Case #True
                 Module_LoadComma8(DELFiles)
             Case #False
                 
                 ResetList( D64.D64() )
                 If ( ListSize ( D64.D64() ) >= 1 )
                     ClearGadgetItems(DC::#ListIcon_003)
                     
                     LastElement(D64()) : SetGadgetText(DC::#Text_124, "  " + D64()\dskFileName)            
                     FirstElement(D64()): ListImage_Content(D64()\dskFileName,#False) 
                     
                     While  NextElement(D64())               
                         
                         If ( ( ListSize ( D64.D64() ) -1) = ListIndex( D64.D64() ) ) 
                             Break
                         Else
                             ListImage_Content(D64()\dskFileName) 
                         EndIf                                    
                     Wend  
                 EndIf  
         EndSelect
         
     EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure.i OpenCBM_ListLoad()
        
        Protected BlockFreeFound = #False
        
        If ( RealDiskDrive$ = "0" )
            SetGadgetText(DC::#Text_124, " Mit "+Chr(34)+"Status"+Chr(34)+" oder "+Chr(34)+"Verzeichnis"+Chr(34)+" Initialisieren")
            ProcedureReturn
        EndIf
        
        SetActiveGadget(DC::#ListIcon_003)
        
        ResetList( R64.R64() )
        If ( ListSize ( R64.R64() ) = 1 )
            ;
            ; Error Code at Directory Reading
            FirstElement(R64()):
             If ( FindString(R64()\dskFileName,"74",1) >= 1)
                  BlockFreeFound = #True
                  SetGadgetText(DC::#Text_124, " Disk Drive Status: " + R64()\dskFileName)  
              EndIf  
             ProcedureReturn 
        EndIf
             
        If ( ListSize ( R64.R64() ) >= 1 )
            ClearGadgetItems(DC::#ListIcon_003)              
            
            LastElement(R64()) : SetGadgetText(DC::#Text_124, "  " + R64()\dskFileName)            
            FirstElement(R64()): ListImage_Content(R64()\dskFileName,#False) 

            While  NextElement(R64())
                                                          
                If ( FindString(R64()\dskFileName,"cks free.",1) >= 1)
                    BlockFreeFound = #True
                    SetGadgetText(DC::#Text_124, "  " + R64()\dskFileName) 
                    Item_Auto_Select()
                    ProcedureReturn
                EndIf
                
                If ( FindString(R64()\dskFileName,"blocks free.",1) >= 1)
                    BlockFreeFound = #True
                    SetGadgetText(DC::#Text_124, "  " + R64()\dskFileName) 
                    Item_Auto_Select()
                    ProcedureReturn
                EndIf
                                
                
                
                If ( ( ListSize ( R64.R64() ) -1) = ListIndex( R64.R64() ) ) 
                    Break
                Else
                    ListImage_Content(R64()\dskFileName) 
                EndIf                                    
           Wend  
         EndIf        
         
         If ( BlockFreeFound = #False )
             SetGadgetText(DC::#Text_124, " Verzeichnis wurde nicht vollständig geladen.")
         EndIf
         
         
     EndProcedure       
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________
     Procedure.s GetProgramm_Lister(Prog.i)
         
         Protected FileStream$ = "", TestSize.i          
            
         Select Prog.i
             Case 0: FileStream$ = Startup::*LHGameDB\C64LoadS8  
             Case 1: FileStream$ = Startup::*LHGameDB\OpenCBM_Tools + "cbmctrl.exe"
             Case 2: FileStream$ = Startup::*LHGameDB\OpenCBM_Tools + "cbmformat.exe"       
             Case 3: FileStream$ = Startup::*LHGameDB\OpenCBM_Tools + "cbmcopy.exe"   
             Case 4: FileStream$ = Startup::*LHGameDB\OpenCBM_Tools + "cbmforng.exe" 
             Case 5: FileStream$ = Startup::*LHGameDB\OpenCBM_Tools + "d64copy.exe"                     
         EndSelect
                     
         If ( Request_FileSizeDialog(FileStream$) = #False )
              ProcedureReturn ""
         EndIf
         
         ProcedureReturn FileStream$

     EndProcedure 
   
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_RunC1541(D64_Image$)       
        
        Protected szCommand$ = "", C1541Arg$ = ""
        C1541Prg$ = GetProgramm_Lister(0)           
 
        
        ; Various Commands to Show the List
        C1541App$ = GetFilePart(C1541Prg$)
        If ( (UCase(C1541App$)) = "C1541.EXE" )
            C1541Arg$ = " -list" 
        EndIf
        If ( (UCase(C1541App$)) = "DM.EXE" )
            C1541Arg$ = "" 
        EndIf       
        If ( (UCase(C1541App$)) = "CC1541.EXE" )
            C1541Arg$ = "" 
        EndIf         
        
        szCommand$ = Chr(34)+D64_Image$+Chr(34)+C1541Arg$       
        
        If ( C1541Prg$ = "" )
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Program to show the Files. Please Select c1541 (from Vice Directory) or dm",2,2,"",0,0,DC::#_Window_005)
            SetActiveGadget(DC::#ListIcon_003)
            ProcedureReturn
        EndIf
  
        
        ClearList( D64.D64() )   
        
        DSK_Thread_Prepare(C1541Prg$, szCommand$, "D64ImageRead")       
        DSK_Image_Refresh()
        
        
    EndProcedure
    
                                                        
    Procedure RecycleFile(file$)
        
        Protected  Result = 0
        
        *Memory = AllocateMemory( Len( file$ ) +2)
        If Result
            PokeS(*Memory, file$)
            SHFileOp.SHFILEOPSTRUCT
            SHFileOp\pFrom = *Memory
            SHFileOp\wFunc = #FO_DELETE
            SHFileOp\fFlags = #FOF_ALLOWUNDO | #FOF_NOERRORUI
            
            Result = SHFileOperation_(SHFileOp)
            FreeMemory( *Memory )
            
            If ( Result = 0 )
                Result = 1
            Else
                Result = 0
            EndIf
        EndIf
        ProcedureReturn Result
    EndProcedure
                                                        
                                                        RecycleFile("Datei.txt")    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________       
    Procedure.s DSK_Uncompress_ZIP(D64_Image$, PowerPacker.i)
        Protected PowerPackFile$, PPFileName$,  PPSWildcat$, PPFilesize.q, TMPWildcat$
        
        
        If OpenFile( DC::#TMPFile , D64_Image$)
           CloseFile( DC::#TMPFile )
      EndIf
        
      If OpenPack(DC::#PackFile, D64_Image$, PowerPacker ) 
          
          If ExaminePack( DC::#PackFile )
              
              While NextPackEntry( DC::#PackFile )
                  
                       If (Len(PackEntryName( DC::#PackFile )) = 0) And ( PackEntrySize( DC::#PackFile ) = 0 )
                           ; 
                           ; No Filename and Items
                           ClosePack(#PB_All): ProcedureReturn
                       EndIf 
                       
                       ;
                       ;Use the First Filename
                       If ( Len(PackEntryName( DC::#PackFile )) >= 1)  
                                                      
                           PowerPackFile$ = PackEntryName( DC::#PackFile )
                           PPFileName$    = GetFilePart( PackEntryName( DC::#PackFile ), 1)
                           PPSWildcat$    = GetExtensionPart( PackEntryName( DC::#PackFile ) )
                           PPFilesize     = PackEntrySize( DC::#PackFile )
                           
                           Debug #CRLF$
                           Request::SetDebugLog("Powerpacked File: "+ PowerPackFile$ + "  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                           Request::SetDebugLog("Powerpacked Size: "+ PackEntrySize( DC::#PackFile ) + "  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                              
                       
                           Select UCase ( PPSWildcat$)
                               Case  "D64", "D71", "D81","T64", "D80", "D82", "G64", "LNX", "X64", "G71", "TAP", "CRT", "PRG", "P00"                                                   
                                   
                                   
                                   PPFileName$ = "_DecompC64File"                                     
                                   PPFileName$ = GetTemporaryDirectory() + PPFileName$ + "." + PPSWildcat$
                                   
                                   Request::SetDebugLog("ZIP Found & Extract : "+ PowerPackFile$ +"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))     
                                   
                                   *PackeMemory = AllocateMemory( PPFilesize )
                                   UncompressPackMemory( DC::#PackFile, *PackeMemory, MemorySize( *PackeMemory ),  PowerPackFile$)
                                   ClosePack(#PB_All)   
                                   
                                   Define SaveFile = CreateFile(#PB_Any, PPFileName$,#PB_File_SharedRead|#PB_File_SharedWrite)           
                                   If ( SaveFile )
                                      WriteData(SaveFile, *PackeMemory, PPFilesize)
                                      CloseFile(SaveFile)     
                                   EndIf  
                                   FreeMemory(*PackeMemory)
                                   
                                   
                                  ; PPFilesize = UncompressPackFile( DC::#PackFile ,PPFileName$, PowerPackFile$ )
                                                                                                  
                                                                      
                                   If ( FileSize(PPFileName$) ! PPFilesize ) Or ( PPFilesize = -1)                                                                           
                                       Message1$ = "W.T.F: "
                                       Message2$ = "There was a error to uncompress File " + #CRLF$ + GetFilePart( D64_Image$ ) + #CRLF$ + "Extract Error: " + PowerPackFile$ + " ("+Str(PPFilesize)+")"
                                       
                                       Request::MSG(Startup::*LHGameDB\TitleVersion, Message1$, Message2$ ,2,2,"",0,0,DC::#_Window_005)
                                       ProcedureReturn ""
                                   EndIf 
                                   
                                   C64_PackedImage$ = PPFileName$
                                   Request::SetDebugLog("Compressed Image Packed  : "+Chr(34)+D64_Image$      +Chr(34)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                                   Request::SetDebugLog("Compressed Image UnPacked: "+Chr(34)+C64_PackedImage$+Chr(34)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                                   ProcedureReturn PPFileName$
                               Default
                                   Continue
                           EndSelect                                                   
                           ; Löschen nicht vergessen
                      EndIf 
                    Wend
                EndIf
            EndIf
      
   EndProcedure    
   
   ;**********************************************************************************************************************************************************************
   ;        
   ;______________________________________________________________________________________________________________________________________________________________________    
   Procedure .i TAP_Format( D64_Image$ )
                       
       SetGadgetText(DC::#Text_121, "")
       SetGadgetText(DC::#Text_122, Chr(34)+  ">  DATASETTE  <"+ Chr(34))
       SetGadgetText(DC::#Text_123, "   15 30")
       
       ClearGadgetItems( DC::#ListIcon_003 )
       Item_Add_Fastload()           
       AddGadgetItem(    DC::#ListIcon_003, -1, "   0" + Chr(10) + Chr(34)+ "PRESS PLAY TO START" + Chr(34)+ Chr(10) + " TAP")         
                                                 
       SetGadgetText(DC::#Text_124, "0 blocks free. / [TAP Size: "+ MathBytes::Bytes2String(FileSize( D64_Image$),2)+"]" )         
       
   EndProcedure        
   ;**********************************************************************************************************************************************************************
   ;        
   ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure .i CRT_Format( D64_Image$ )
        
       Protected  HardwareTyp$, CartVersion.i, CartFileName$
       
        Structure CRT_Image
            c.a[0]
        EndStructure 
        
        Structure CRT_Signature
            c.a[16]
        EndStructure 
        
        Structure CRT_Version
            c.a[2]
        EndStructure 
                
        Structure CRT_Hardware
            c.a[2]
        EndStructure 
        
        Structure CRT_Port
            c.a[1]
        EndStructure          
        
        Structure CRT_Filename
            c.a[32]
        EndStructure  
        
        Protected  *Rawfile.CRT_Image, *Header.CRT_Signature, *Version.CRT_Version, *Type.CRT_Hardware, *Exrom.CRT_Port, *Game.CRT_Port,  *FileName.CRT_Filename
        
        *Rawfile    = AllocateMemory( FileSize(  D64_Image$ ) ) 
        *Header     = AllocateMemory(16) 
        *Version    = AllocateMemory(2)        
        *Type       = AllocateMemory(2)         
        *Exrom      = AllocateMemory(1)
        *Game       = AllocateMemory(1)
        *FileName   = AllocateMemory(32)        
        
        PC64File.a = OpenFile( 0, D64_Image$, #PB_File_SharedRead|#PB_File_SharedWrite)
        If ( PC64File )
            If ReadFile(PC64File, D64_Image$, #PB_File_SharedRead|#PB_File_SharedWrite) 
                
                ;
                ; $0000-000F - 16-byte cartridge signature 
                Bytes = ReadData(PC64File, *Header, 16)
                Debug  PeekS(*Header,16, #PB_Ascii)
                If ( PeekS(*Header,16, #PB_Ascii)  <> "C64 CARTRIDGE   " )    
                    ProcedureReturn 0
                EndIf
                
                ;
                ; 0010-0013 - File header length  ($00000040,  in  high/low  format,
                ;             calculated from offset $0000). The Default And minimum
                ;             value is $40. Some faulty cartridge images exist which
                
                ; 0014-0015 - Cartridge version (high/low, presently 01.00)
                FileSeek( PC64File, $14 )
                Bytes = ReadData(PC64File, *Version, 2)
                CartVersion =  *Version\c[0] + *Version\c[1]
                
                ; 0016-0017 - Cartridge hardware type ($0000, high/low)
                FileSeek( PC64File, $16 )
                Bytes = ReadData(PC64File, *Type, 2)   
                
                Select ( *type\c[0] + *type\c[1] )
                       Case 00: HardwareTyp$ = "Normal Cartridge"
                       Case 01: HardwareTyp$ = "Action Replay"
                       Case 02: HardwareTyp$ = "KCS Power Cartridge"
                       Case 03: HardwareTyp$ = "Final Cartridge III"
                       Case 04: HardwareTyp$ = "Simons Basic"
                       Case 05: HardwareTyp$ = "Ocean type 1"
                       Case 06: HardwareTyp$ = "Expert Cartridge"
                       Case 07: HardwareTyp$ = "Fun Play, Power Play"
                       Case 08: HardwareTyp$ = "Super Games"
                       Case 09: HardwareTyp$ = "Atomic Power"
                       Case 10: HardwareTyp$ = "Epyx Fastload"
                       Case 11: HardwareTyp$ = "Westermann Learning"
                       Case 12: HardwareTyp$ = "Rex Utility"
                       Case 13: HardwareTyp$ = "Final Cartridge I"
                       Case 14: HardwareTyp$ = "Magic Formel"
                       Case 15: HardwareTyp$ = "C64 Game System, System 3"
                       Case 16: HardwareTyp$ = "WarpSpeed"
                       Case 17: HardwareTyp$ = "Dinamic"
                       Case 18: HardwareTyp$ = "Zaxxon, Super Zaxxon (SEGA)"
                       Case 19: HardwareTyp$ = "Magic Desk, Domark, HES Australia"
                       Case 20: HardwareTyp$ = "Super Snapshot 5"
                       Case 21: HardwareTyp$ = "Comal-80"
                       Case 22: HardwareTyp$ = "Structured Basic"
                       Case 23: HardwareTyp$ = "Ross"
                       Case 24: HardwareTyp$ = "Dela EP64"
                       Case 25: HardwareTyp$ = "Dela EP7x8"
                       Case 26: HardwareTyp$ = "Dela EP256"                           
                       Case 27: HardwareTyp$ = "Rex EP256"
                       Case 28: HardwareTyp$ = "Mikro Assembler"
                       Case 29: HardwareTyp$ = "Reserved"
                       Case 30: HardwareTyp$ = "Action Replay 4"
                       Case 31: HardwareTyp$ = "StarDOS"
                       Case 32: HardwareTyp$ = "EasyFlash"
                       Default: HardwareTyp$ = "Unknown Cartridge"                
                EndSelect
                   
                ; 0018      - Cartridge port /EXROM line status
                FileSeek( PC64File, $18 )
                Bytes = ReadData(PC64File, *Exrom, 1)
                
                ; 0019      - Cartridge port /GAME line status
                FileSeek( PC64File, $18 )
                Bytes = ReadData(PC64File, *Game, 1)
                
                ;001A-001F - Reserved for future use
                
                ;0020-003F - 32-byte cartridge  name  "CCSMON"  (uppercase,  padded With null characters)                
                FileSeek( PC64File, $20 )   
                Bytes = ReadData(PC64File, *FileName, 32)                
                CartFileName$ = PeekS(*FileName, 32, #PB_Ascii)                 
                                
            EndIf
            CloseFile( PC64File )
        EndIf
       
        FreeMemory(*Rawfile)
        FreeMemory(*Header)        
        FreeMemory(*Version) 
        FreeMemory(*Type) 
        FreeMemory(*Exrom) 
        FreeMemory(*Game) 
        FreeMemory(*FileName)         
                       
       SetGadgetText(DC::#Text_121, "TYPE")
       SetGadgetText(DC::#Text_122, Chr(34)+  ""+UCase( HardwareTyp$ )+ ""+ Chr(34))
       SetGadgetText(DC::#Text_123, "   00 00")   
       
       ClearGadgetItems( DC::#ListIcon_003 )       
       Item_Add_Fastload()               
       AddGadgetItem(DC::#ListIcon_003, -1, "   0"   +Chr(10) + Chr(34)+ UCase( CartFileName$ ) + Chr(34)+ Chr(10) + " CRT") 

       SetGadgetText(DC::#Text_124, "0 blocks free. / [CART Size: "+ MathBytes::Bytes2String(FileSize( D64_Image$))+" / Version: "+Str(CartVersion)+"]" )         
       
    EndProcedure   
   
   ;**********************************************************************************************************************************************************************
   ;        
   ;______________________________________________________________________________________________________________________________________________________________________    
   Procedure .i PRG_Format( D64_Image$ )
       
       Protected nPos
       
       PRGFile$ = GetFilePart( UCase( D64_Image$ ),1 )
       If ( Len( PRGFile$)  >= 16 )
           
           nPos = FindString( PRGFile$, "(", 1)
           If nPos = 0
               nPos = 16
           Else
               nPos - 2
           EndIf    
           
           PRGFile$ = UCase( Left( PRGFile$ , nPos) )          
       EndIf    
       
       SetGadgetText(DC::#Text_121, "")
       SetGadgetText(DC::#Text_122, Chr(34)+  ">  PROGRAM  <"+ Chr(34))
       SetGadgetText(DC::#Text_123, "   00 00")
       
       ClearGadgetItems( DC::#ListIcon_003 )
       Item_Add_Fastload()           
       AddGadgetItem(    DC::#ListIcon_003, -1, "   0" + Chr(10) + Chr(34)+ PRGFile$ + Chr(34)+ Chr(10) + " PRG") 

       SetGadgetText(DC::#Text_124, "0 blocks free. / [PRG Size: "+ MathBytes::Bytes2String(FileSize( D64_Image$))+"]" )         
       
    EndProcedure    
   
   ;**********************************************************************************************************************************************************************
   ;        
   ;______________________________________________________________________________________________________________________________________________________________________    
   Procedure .i P00_Format( D64_Image$ )
       
       ; Read File to Memory                         
       
       SetGadgetText(DC::#Text_121, "")
       SetGadgetText(DC::#Text_122, Chr(34)+  ">  PROGRAM  <"+ Chr(34))
       SetGadgetText(DC::#Text_123, "   0P 00")
       
        Structure header
            c.a[8]
        EndStructure 
        
        Structure filename
            c.a[16]
        EndStructure   
        
        Protected  *rawfile.filename, *header.header
        
        *rawfile  = AllocateMemory(16) 
        *header   = AllocateMemory(6) 
        
        PC64File.a = OpenFile( 0, D64_Image$, #PB_File_SharedRead|#PB_File_SharedWrite)
        If ( PC64File )
            If ReadFile(PC64File, D64_Image$, #PB_File_SharedRead|#PB_File_SharedWrite) 
                
                bytes = ReadData(PC64File, *header, 7)
                
                If ( PeekS(*header,8, #PB_Ascii) <> "C64File" )                                        
                    ProcedureReturn 0
                EndIf
                
                FileSeek( PC64File, 8 )

                bytes = ReadData(PC64File, *rawfile, 16)
                
                
            EndIf
        EndIf       
         
       ClearGadgetItems( DC::#ListIcon_003 )
       Item_Add_Fastload()            
       AddGadgetItem(    DC::#ListIcon_003, -1, "   0" + Chr(10) + Chr(34)+ PeekS(*rawfile,16,#PB_Ascii) + Chr(34)+ Chr(10) + " PRG") 
       SetGadgetText(DC::#Text_124, "0 blocks free. / [PRG Size: "+ MathBytes::Bytes2String(FileSize( D64_Image$))+"]" )         
       
    EndProcedure     
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.i DSK_FormatCheck(D64_Image$)
        
        Protected DiskFormat$
        
        UseCBMModule = #False
        
        DiskFormat$      = GetExtensionPart(D64_Image$)
        Select UCase ( DiskFormat$ )
            Case  "D64", "D71", "D81","T64"
                UseCBMModule = #True
                Module_LoadDirectory( D64_Image$ )
                ;
                ; Use CBM Disk Imge Modul
            Case  "D80", "D82", "G64", "LNX", "X64", "G71"
                DSK_RunC1541(D64_Image$)
                
             Case "ZIP"
                 D64_Image$ = DSK_Uncompress_ZIP(D64_Image$, #PB_PackerPlugin_Zip): DSK_FormatCheck(D64_Image$)
                 
             Case "7Z"   
                 D64_Image$ = DSK_Uncompress_ZIP(D64_Image$, #PB_PackerPlugin_Lzma): DSK_FormatCheck(D64_Image$)
                 
             Case "TAR"   
                 D64_Image$ = DSK_Uncompress_ZIP(D64_Image$, #PB_PackerPlugin_Tar): DSK_FormatCheck(D64_Image$)
                 
             Case "LZ"   
                 D64_Image$ = DSK_Uncompress_ZIP(D64_Image$, #PB_PackerPlugin_BriefLZ): DSK_FormatCheck(D64_Image$)
                 
             Case "TAP"
                 TAP_Format( D64_Image$ )
                 
             Case "CRT"    
                 CRT_Format( D64_Image$ )
                 
             Case "PRG"
                 PRG_Format( D64_Image$ )
                 
             Case "P00"    
                 P00_Format( D64_Image$ )                 

                 
             Case "D1M", "D2M", "D4M", "DHD", "DNP", "DFI", "M2I"
                 ;
                 ; Not Supportet
                 
            Default
         EndSelect       
        
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.i DSK_ExistsFile(D64_Image$)
        
                              
        Select FileSize(D64_Image$)                
            Case -1                
;                 If ( Startup::*LHGameDB\CBMFONT = FontID(Fonts::#_C64_CHARS) )
;                     Item_ChangeFont()
;                 EndIf                
                SetGadgetText(DC::#Text_121, "")
                SetGadgetText(DC::#Text_122, Chr(34)+  "ß© UNKNOWN ß©" + Chr(34))
                SetGadgetText(DC::#Text_123, "   99 ßß")
                
                AddGadgetItem(DC::#ListIcon_003, -1, "")
                AddGadgetItem(DC::#ListIcon_003, -1, "  #" + Chr(10) + Chr(34)+ "DISK IMAGE NOT FOUND" + Chr(34)+ Chr(10) + "ERR")                
                AddGadgetItem(DC::#ListIcon_003, -1, "" )  
                AddGadgetItem(DC::#ListIcon_003, -1, "  #" + Chr(10) + Chr(34)+ UCase( GetPathPart(D64_Image$) + GetFilePart(D64_Image$,#PB_FileSystem_NoExtension)) + Chr(34)+ Chr(10) + GetExtensionPart(D64_Image$) )
                ProcedureReturn #False
                
            Case  -2      
;                 If ( Startup::*LHGameDB\CBMFONT = FontID(Fonts::#_C64_CHARS) )
;                     Item_ChangeFont()
;                 EndIf                
                SetGadgetText(DC::#Text_121, " ")
                SetGadgetText(DC::#Text_122, Chr(34)+ " ß© EMPTY ß©" + Chr(34))
                SetGadgetText(DC::#Text_123, "   ©0 0©") 
                
                AddGadgetItem(DC::#ListIcon_003, -1, "")
                AddGadgetItem(DC::#ListIcon_003, -1, "  #" + Chr(10) + Chr(34)+ "NO DISK IMAGE LOADED" + Chr(34)+ Chr(10) + "NDL")                
            Default
                ProcedureReturn #True
        EndSelect
    EndProcedure           
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_LoadImage(GadgetID.i,DestGadgetID.i, DropLoad = 0)
        
        Request::SetDebugLog("DatabaseID: "+Str( Startup::*LHGameDB\GameID)+"  "+#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))    
        
        
        C64LoadS8_TXID     = DestGadgetID;                
        C64_PackedImage$   = ""        
        vItemC64E_CanClose = #False
        
        Error_DiskDrive_List()
        
        ;
        ; Sichert den Disk Dateinamen im Speicher
        DSK_SaveOldFilename()    
        
        ;
        ; Lädt die Disk
        D64_Image$  = VEngine::Getfile_Portbale_ModeOut(GetGadgetText(GadgetID.i))
            If ( DSK_ExistsFile(D64_Image$) = #False)
                ProcedureReturn #False
            EndIf  
        
            
        SetGadgetText(DC::#String_102,D64_Image$)
            
        
        ;
        ; Checkt das Image Format
            
        DSK_FormatCheck(D64_Image$)                   
        
        ProcedureReturn #True        
    EndProcedure      
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_OpenCBM_CheckR64List()
        
        If ( ListSize (R64.R64() ) = -1 )
            ProcedureReturn #False
        EndIf
        ProcedureReturn #True
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________        
    Procedure.i DSK_OpenCBM_Reset()
        
        ; Needed
        ; cbmctrl.exe, 
        Protected szCMD_Init$, OpenCBMPrg$
        
        OpenCBMPrg$ = GetProgramm_Lister(1)
        szCMD_Init$ = "reset"        
         
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.reset")
        
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________        
    Procedure.i DSK_OpenCBM_Detect()
                
        ; Needed
        ; cbmctrl.exe, 
        Protected szCMD_Init$, OpenCBMPrg$                
        
        OpenCBMPrg$ = GetProgramm_Lister(1)
        szCMD_Init$ = "detect"        
        
        If ( OpenCBMPrg$ = "" )
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Missing OpenCBM Tools Folder.",2,2,"",0,0,DC::#_Window_005)
            SetActiveGadget(DC::#ListIcon_003)
            ProcedureReturn #False
        EndIf
        If ( OpenCBMPrg$ = "0" )
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: "," 0 Byte File? Can not run ....",2,2,"",0,0,DC::#_Window_005)
            SetActiveGadget(DC::#ListIcon_003)
            ProcedureReturn #False
        EndIf    
        
        If ( RealDiskDrive$ = "0" )
                    
            DSK_OpenCBM_Reset()        
            ;Delay(255)   
        
            Item_Clear() 
            
            DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.detect")  
            ;Delay(255) 
            
            If ( RealDiskDrive$ = "0" )
                DSK_OpenCBM_ErrDiskDrive()              
                ProcedureReturn #False
            Else
                  
                ProcedureReturn #True
            EndIf            
        EndIf         
                     
        ProcedureReturn #True
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_OpenCBM_Init()
        
        Protected szCMD_Init$, OpenCBMPrg$, OpenCBM_Continue = #True
        
        LastDrive_Error$ = ""
        
        If ( DSK_OpenCBM_Detect() = #False )
            ProcedureReturn
        EndIf
        
        OpenCBMPrg$ = GetProgramm_Lister(1)
        szCMD_Init$ = "command "+RealDiskDrive$+" IO"
                            
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.command")
        ;Delay(255) 
                
        OpenCBMPrg$ = GetProgramm_Lister(1)        
        szCMD_Init$ = "status "+RealDiskDrive$        
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.status")
        ;Delay(255)                  
                             
     EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_OpenCBM_Directory()
        
        Protected szCMD_Init$, OpenCBMPrg$
        
        If ( DSK_OpenCBM_Detect() = #False )
            ProcedureReturn
        EndIf
        
        Item_Clear() 
        
        If ( DSK_OpenCBM_CheckR64List() = #False) 
            DSK_OpenCBM_Init()       
        EndIf
        
        ;Delay(255)
        OpenCBMPrg$ = GetProgramm_Lister(1)
        szCMD_Init$ = "dir " + RealDiskDrive$
        
        ClearList( R64.R64() )   
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.directory")        
        
        OpenCBM_ListLoad()
        
    EndProcedure  
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_OpenCBM_Refresh()   
        OpenCBM_ListLoad()
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_OpenCBM_D64Copy()    
        OpenCBM_ListLoad()
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i DSK_OpenCBM_Val()
        
        Protected szCMD_Init$, OpenCBMPrg$
        
        If ( DSK_OpenCBM_Detect() = #False )
            ProcedureReturn
        EndIf
        
        If ( DSK_OpenCBM_CheckR64List() = #False)         
            DSK_OpenCBM_Init() 
        EndIf
                
        OpenCBMPrg$ = GetProgramm_Lister(1)
        szCMD_Init$ = "command " + RealDiskDrive$ + Chr(34) + "V0:" + Chr(34) 
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.validate")        
                        
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i OpenCBM_Format()
        
        Protected r.i, OpenCBMPrg$ = "", szCMD_Init$ = ""
        
        If ( DSK_OpenCBM_Detect() = #False )
            ProcedureReturn
        EndIf
                
        If ( DSK_OpenCBM_CheckR64List() = #False)         
            ;DSK_OpenCBM_Init()
            DSK_OpenCBM_Directory()
        EndIf
        
        DSK_OpenCBM_Refresh()
        
        Request::*MsgEx\User_BtnTextL = "Format"
        Request::*MsgEx\User_BtnTextR = "Cancel"     
        
        If ( INVMNU::*LHMNU64\FORMAT = 0 ) Or ( INVMNU::*LHMNU64\FORMAT = 1 )
            
            If ( INVMNU::*LHMNU64\FORM40 = #False )
                Request::*MsgEx\Return_String = Chr(34) +"35 Tracks,id" +Chr(34)
            EndIf
            
            If ( INVMNU::*LHMNU64\FORM40 = #True )
                Request::*MsgEx\Return_String = Chr(34) +"40 Tracks,id" +Chr(34)
            EndIf        
        EndIf    
        
        If ( INVMNU::*LHMNU64\FORMAT = 2 )       
            Request::*MsgEx\Return_String = "35 Tracks,id"
        EndIf    
        
        r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Format Disk Drive: "+ RealDiskDrive$,"Enter the Label and the Disk ID",10,1,"",0,1,DC::#_Window_005)
        SetActiveGadget(DC::#ListIcon_003): 
        If (r = 0)
            
            ;
            ; Nur mit cbmformat und cbmformng
            If ( INVMNU::*LHMNU64\FORMAT = 0 ) Or ( INVMNU::*LHMNU64\FORMAT = 1 )
                
                If ( INVMNU::*LHMNU64\FORMAT = 0 )
                    OpenCBMPrg$ = GetProgramm_Lister(2)
                    szCMD_Init$ = RealDiskDrive$ +" "+Request::*MsgEx\Return_String+" -v -p"
                    C64Format_Name$ = Request::*MsgEx\Return_String
                EndIf    
                
                If ( INVMNU::*LHMNU64\FORMAT = 1 )
                    OpenCBMPrg$ = GetProgramm_Lister(4)
                    szCMD_Init$ = RealDiskDrive$ +" "+Request::*MsgEx\Return_String+" -v -p"
                     C64Format_Name$ = Request::*MsgEx\Return_String
                EndIf 
                
                If ( INVMNU::*LHMNU64\FORM40 = #True )
                    szCMD_Init$ + " -x"
                EndIf
                
                
                Request::*MsgEx\User_BtnTextL = "Yes"
                Request::*MsgEx\User_BtnTextR = "No"              
                
                
                r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Format Disk Drive: "+ RealDiskDrive$,"Clear (demagnetize) this disk?."+#CR$+
                                                                                                        "This is highly recommended If the disk is used"+#CR$+
                                                                                                        "For the first time, Or If it was previously"+#CR$+
                                                                                                        "formatted For another system (i.e., MS-DOS)."+#CR$+
                                                                                                        "Note that this option takes much time.",10,1,"",0,0,DC::#_Window_005)
                SetActiveGadget(DC::#ListIcon_003): 
                If ( r = 0 )
                    szCMD_Init$ + " -c"
                EndIf
                Request::SetDebugLog("OpenCBM Command Format:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))     
                DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.format")   
                ;Delay(255)
                DSK_OpenCBM_Directory()                
            EndIf             
            
            If ( INVMNU::*LHMNU64\FORMAT = 2 )
                
                OpenCBMPrg$ = GetProgramm_Lister(1)
                
                szCMD_Init$ = "command " +RealDiskDrive$ +" "+Chr(34)+"N0:"+Request::*MsgEx\Return_String+Chr(34)+""
                C64Format_Name$ = Request::*MsgEx\Return_String
                Request::SetDebugLog("OpenCBM Command Format:" + OpenCBMPrg$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))                
                Request::SetDebugLog("OpenCBM Command Format:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.format2")   
                ;Delay(255)
                ;DSK_OpenCBM_Directory()                    
            EndIf                  
            
        EndIf
        C64Format_Name$ = "";
        SetActiveGadget(DC::#ListIcon_003)
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________      
    Procedure.i DSK_OpenCBM_Format()
          OpenCBM_Format()                  
    EndProcedure        
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________  
     Procedure.i OpenCBM_Rename(CurrentFile$)
         
        Protected r.i, OpenCBMPrg$ = "", szCMD_Init$ = ""
                                                   
        OpenCBMPrg$ = GetProgramm_Lister(1)
        
        Request::*MsgEx\User_BtnTextL = "Rename"
        Request::*MsgEx\User_BtnTextR = "Cancel"        
        Request::*MsgEx\Return_String = DSK_SetCharSet(CurrentFile$)
        r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Rename File","Enter new File Name",10,1,"",0,1,DC::#_Window_005)        
        SetActiveGadget(DC::#ListIcon_003): 
        If (r = 0)
            
            C64LoadS8_CopyF$ = Chr(34)+DSK_SetCharSet(Request::*MsgEx\Return_String)+Chr(34)+" = "+Chr(34)+CurrentFile$+Chr(34)
                    
            szCMD_Init$ = "command "+RealDiskDrive$+" "+Chr(34)+"R0:"+DSK_SetCharSet(Request::*MsgEx\Return_String)+"="+CurrentFile$+Chr(34)
            Request::SetDebugLog("OpenCBM Command Rename:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))     
            
            DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.rename")  
            C64LoadS8_CopyF$ = ""
            ;Delay(255)            
            ProcedureReturn #True
        EndIf   
        ProcedureReturn 999
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________  
    Procedure.i OpenCBM_Scratch_All(MessageA$, MessageB$)
        
        If ( C64LoadS8_Delete = 0 )
            r = Request::MSG(Startup::*LHGameDB\TitleVersion, MessageA$,MessageB$,10,1,"",0,0,DC::#_Window_005)
            SetActiveGadget(DC::#ListIcon_003): 
            If ( r = 0 ) 
                C64LoadS8_Delete = 1 
                ProcedureReturn #True
            EndIf
            If ( r = 1 ) 
                ProcedureReturn #False
            EndIf            
        EndIf
        ProcedureReturn #True
        
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________  
    Procedure.i OpenCBM_Scratch(CurrentFile$, CurrentPatt$, Counts.i, CurrentPos)
        
        Protected r.i, OpenCBMPrg$ = "", szCMD_Init$ = "", MessageA$= "", MessageB$= "", C64_Pattern$
                            
        OpenCBMPrg$  = GetProgramm_Lister(1)
                    
        Select UCase( CurrentPatt$ )
            Case "PRG": C64_Pattern$ = ",P"
            Case "SEQ": C64_Pattern$ = ",S"
            Case "REL": C64_Pattern$ = ",R"    
            Case "USR": C64_Pattern$ = ",U"                
            Case "DEL": C64_Pattern$ = ",D"                  
            Default
               C64_Pattern$ = ""
        EndSelect        
        
        szCMD_Init$  = "command "+RealDiskDrive$+" "+Chr(34)+"S0:"+CurrentFile$+C64_Pattern$+Chr(34)
                
        Request::SetDebugLog("OpenCBM Command Scratch:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))             
        
        Request::*MsgEx\User_BtnTextR = "Cancel"           
        
        If ( Counts >= 2)            
            Request::*MsgEx\User_BtnTextL = "Scratch All"
            MessageA$ = "Scratch All Files ( Delete Files) ?"            
            MessageB$ = "This will Scratch (Delete) "+Str(Counts)+" Files"
            
            If ( OpenCBM_Scratch_All(MessageA$, MessageB$) = #True )
                C64LoadS8_CopyF$ = Chr(34)+CurrentFile$+"."+CurrentPatt$+Chr(34)
                
                
                DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.scratch")  
                ;Delay(255)
                C64LoadS8_CopyF$ = ""
                If ( Counts >= 2)                 
                    SetGadgetItemState(DC::#ListIcon_003, CurrentPos, 0) 
                    ;Delay(255)                   
                EndIf                   
                ProcedureReturn #True
            Else
                ProcedureReturn 999
            EndIf    
                
        Else
            C64LoadS8_Delete = 0 ; Single File
            
            Request::*MsgEx\User_BtnTextL = "Scratch"
            MessageA$ = "Scratch ( Delete ) ?"             
            MessageB$ = CurrentFile$
            
            r = Request::MSG(Startup::*LHGameDB\TitleVersion, MessageA$,MessageB$,10,1,"",0,0,DC::#_Window_005)
            SetActiveGadget(DC::#ListIcon_003): 
            If ( r = 0 )   
                DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.scratch")  
                ;Delay(255)
                ProcedureReturn #True
            EndIf
            ProcedureReturn 999
        EndIf                                                      
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;   
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.s DSK_TransferSign_Check(FileStream$, Pattern.i = #False)        
                
        Protected NewFileName$ = "", sReplacer$ = "_"
        
        If ( Pattern = #True )
            sReplacer$ = ""
        EndIf
        
        For i = 1 To Len(FileStream$)
            
            asci.i = Asc( Mid(FileStream$,i,1) )           
            Select asci.i
                Case  34: NewFileName$ + sReplacer$ ; "    
                Case  42: NewFileName$ + sReplacer$ ; *                      
                Case  47: NewFileName$ + sReplacer$ ; /
                Case  58: NewFileName$ + sReplacer$ ; :
                Case  60: NewFileName$ + sReplacer$ ; <
                Case  62: NewFileName$ + sReplacer$ ; >
                Case  63: NewFileName$ + sReplacer$ ; ?                       
                Case  92: NewFileName$ + sReplacer$ ; \  
                Case 127: NewFileName$ + sReplacer$ ; DEL  
                Default
                    NewFileName$ + Chr(asci)
            EndSelect
            ;Request::SetDebugLog("Transferfilename :" + NewFileName$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))              
        Next
        
        ProcedureReturn NewFileName$
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;   Transfer Mode
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure.s DSK_TransferMode()
        
        Protected TransferMode$ = ""
        
        Select INVMNU::*LHMNU64\TRMODE
                Case 0: TransferMode$ = "--transfer=auto"
                Case 1: TransferMode$ = "--transfer=original"                
                Case 2: TransferMode$ = "--transfer=serial1"
                Case 3: TransferMode$ = "--transfer=serial2"  
                Case 4: TransferMode$ = "--transfer=parallel"                     
        EndSelect           
        ProcedureReturn TransferMode$
        
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;   Warp Mode
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.s DSK_TransferWarp(sCommand.s)
        
        If ( INVMNU::*LHMNU64\USWARP = #False )
            sCommand + "--no-warp "
            C64LoadS8_CopyF$ + " ( NO WARP )"
            ProcedureReturn sCommand        
        EndIf 
        
        C64LoadS8_CopyF$ + " ( WARP )"        
        ProcedureReturn sCommand 
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;   Kopiert eine Datei aus dem echten Laufwerk. Mode dienst zur steurung: 0 (Lokales Verzeichnis)/ 1 zum Image
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure.i OpenCBM_CopyFileToPC(CurrentFile$, CurrentPatt$, Counts, Blocks.s, CurrentPos.i)
        
       Protected OpenCBMPrg$ = "", szCMD_Init$ = "", CopySrce$ = "", CopyDest$ = ""
       
       C64_FileNme$ = DSK_SetCharSet(CurrentFile$)        
       C64_Pattern$ = Mid(  CurrentPatt$, 1,1)
       
       PCC_FileNme$ = DSK_TransferSign_Check(CurrentFile$)
       PCC_Pattern$ = DSK_TransferSign_Check(CurrentPatt$, #True)
       
       HDD_Backup$  = GetGadgetText(DC::#String_111)
       
       
       If ( FileSize(HDD_Backup$) = -2 )                    
           
           OpenCBMPrg$      = GetProgramm_Lister(3) 
           
           C64LoadS8_CopyF$ = Chr(34)+ C64_FileNme$+ "." +PCC_Pattern$+Chr(34)+ " ( " + Blocks + " block[s] )"
           
           CopySrce$        = Chr(34)+ C64_FileNme$+ "," +C64_Pattern$+Chr(34)
           CopyDest$        = HDD_Backup$ + PCC_FileNme$ + "." + PCC_Pattern$                         
           
           CopyDest$        = Request_CopyFileExists(PCC_FileNme$ + "." + PCC_Pattern$, CopyDest$, HDD_Backup$)                    
           If ( CopyDest$ = "" )
               ProcedureReturn 999
           EndIf
                      
           szCMD_Init$      = DSK_TransferMode()+" -q -r "+RealDiskDrive$+" " +CopySrce$+ " --output=" + Chr(34)+ CopyDest$ +Chr(34)                        
           Request::SetDebugLog("OpenCBM Command Transfer/> PC:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line)) 
           
           DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyfiletopc")
           
           If ( FileSize( CopyDest$ ) >= 1 )
               If ( Counts = 1)
                   Request::MSG(Startup::*LHGameDB\TitleVersion, "Succesfully Copied:","File has been Copied to: "+#CR$+CopyDest$ ,2,0,"",0,0,DC::#_Window_005) 
                   SetActiveGadget(DC::#ListIcon_003): 
               EndIf    
               If ( Counts >= 2)
                   SetGadgetItemState(DC::#ListIcon_003, CurrentPos, 0) 
               EndIf    
               ProcedureReturn 998
           Else
               Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Copy Problem ? ... Please Check ...",2,2,"",0,0,DC::#_Window_005)
               SetActiveGadget(DC::#ListIcon_003): 
               ProcedureReturn 999
           EndIf                                   
           
       Else                   
           Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Directory Not Found:"+#CR$+HDD_Backup$,2,2,"",0,0,DC::#_Window_005)                  
           SetActiveGadget(DC::#ListIcon_003): 
           ProcedureReturn 999
       EndIf                                      
     EndProcedure              
    ;**********************************************************************************************************************************************************************
    ;   Kopiert eine Datei aus dem echten Laufwerk. Mode dienst zur steurung: 0 (Lokales Verzeichnis)/ 1 zum Image
    ;______________________________________________________________________________________________________________________________________________________________________ 
     Procedure.i OpenCBM_CopyFileToIM(CurrentFile$, CurrentPatt$, Counts, Blocks.s, CurrentPos.i, PackCopyCount.i)
         
         Protected OpenCBMPrg$ = "", szCMD_Init$ = "", CopySrce$ = "", CopyDest$ = "", C64Unpacked$, DiskIsCompressed.i = #False, CopyCount.i = 0, BackupFile$
         
         ; ------------------------------------------------ Teil 1, Kopiere die Datei vom Echten Laufwerk in das Temp Verzeichnis
            C64_FileNme$ = DSK_SetCharSet(CurrentFile$)   
            
            If ( Item_Compare_List(CurrentFile$) = 63 )            
                ProcedureReturn 997
            EndIf
            
            ;
            ; C64 Dateinamen Check
            Select UCase( CurrentPatt$ )
                Case "PRG": C64_Pattern$ = ",P"
                Case "SEQ": C64_Pattern$ = ",S"
                Case "REL": C64_Pattern$ = ",R"    
                Case "USR": C64_Pattern$ = ",U"  
                Case "DEL": C64_Pattern$ = ",U"                      
                Default
                   C64_Pattern$ = ""
            EndSelect             

            PCC_FileNme$ = DSK_TransferSign_Check(CurrentFile$)
            PCC_Pattern$ = DSK_TransferSign_Check(CurrentPatt$, #True)

            C64DiskImage$ = GetGadgetText(DC::#String_102)
            If ( Request_FileSizeDialog(C64DiskImage$) = #False )
                 ProcedureReturn 999
            EndIf
        
         
            ;
            ; Generiere Randm Datei                    
              TempRnd.i = Random(99999,10000)
              TempSfx.s = GetExtensionPart(C64DiskImage$)
              TempNme.s = GetTemporaryDirectory() + "ds50f_" + TempRnd + ".tmp"
              
            ; Erstelle die Kopie
              OpenCBMPrg$      = GetProgramm_Lister(3)
              
              C64LoadS8_CopyF$ = Chr(34)+ C64_FileNme$+ "." +PCC_Pattern$+Chr(34)+ " ( " + Blocks + " block[s] )" ; Info
              CopySrce$        = Chr(34)+ C64_FileNme$+ LCase( C64_Pattern$ )+Chr(34)               
                       
              szCMD_Init$ = DSK_TransferMode()+" -q -r "+RealDiskDrive$+" "+CopySrce$+" --output="+TempNme
              Request::SetDebugLog("OpenCBM Copy File: " + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line)) 
         
              DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyfiletopc")
         
              If ( Request_FileSizeDialog(TempNme) = #False )
                   ProcedureReturn 999
              EndIf
         
         ; ------------------------------------------------ Teil 2, Kopiere die Datei ins Image         
         ;
         ; 
         ; Prüfe ob das Image  gepackt ist und erstelle eine Kopie
          If ( PackCopyCount = 1 )
                 
                  If  ( PackerSupport_Create_FileCopy(C64DiskImage$, PackCopyCount) = "")
                ;
                ; Keine Untersützung (Pattern)
                ProcedureReturn 999
             EndIf
         EndIf 
         ;
         ; Bin nicht wirklich damit einverstanden
         
         If ( C64_PackedImage$ <> "" )
             C64DiskImage$ = C64_PackedImage$
         EndIf    
                      
        ;  
        ; Info String
        C64LoadS8_CopyF$ = " To Image " +C64DiskImage$                       
                  
        OpenCBMPrg$ = GetProgramm_Lister(0) ;
        szCMD_Init$ = Chr(34)+ C64DiskImage$+Chr(34)+" -write "+TempNme+ " "+ CopySrce$
        
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyfiletopc")                       
        
        If ( PackerSupport_Create_PackFile() = #False )
                ;
                ; Keine Untersützung (Pattern)
                ProcedureReturn 999
        EndIf 
        
        ;Delay(255)
        
        DeleteFile(TempNme,#PB_FileSystem_Force)
        If ( Counts >= 2)
           SetGadgetItemState(DC::#ListIcon_003, CurrentPos, 0) 
        EndIf           
        
        ProcedureReturn 997
        
        
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure.i DSK_OpenCBM_Copy_LocalFile_To_1541(FileRequester.i = #True)
        
        
        Protected CurrentFile$ = "", Output_File$ = "", DiskInterface$ = "", Pos.i, FileNames$, Patterns$, C64Pattern$, szCMD_Init_Filetype$ =""
        
        NewMap Dateien.s()
        
        If ( DSK_OpenCBM_Detect() = #False )
            ProcedureReturn
        EndIf
        
        If ( RealDiskDrive$ = "0" )
            
            DSK_OpenCBM_Init()
            DSK_OpenCBM_Directory() 
            If ( RealDiskDrive$ = "0" )
                DSK_OpenCBM_ErrDiskDrive()    
                ProcedureReturn
            EndIf    
        EndIf  
                              
        Item_Select_Index(DC::#ListIcon_003, 1)          
        
        Select FileRequester
                
            Case #True
                Patterns$ = "C64 Files "
                Patterns$ + "(Supportet Patterns)"
                Patterns$ + "|*.prg;*.seq;*.rel;*.usr;*.txt;*.p00;*.s00;*.r00;*.u00;*.cvt;*.del|"
                Patterns$ + "C64: PRG   (*.prg)|*.prg|"
                Patterns$ + "C64: SEQ   (*.seq)|*.seq|"                
                Patterns$ + "C64: REL   (*.rel)|*.rel|"
                Patterns$ + "C64: USR   (*.usr)|*.usr|"
                Patterns$ + "C64: ASC   (*.txt)|*.txt|"
                Patterns$ + "C64: DEL   (*.del)|*.del|"                
                Patterns$ + "PC64 Files (*.p00;*.s00;*.r00;*.u00)|*.p00;*.s00;*.r00;*.u00|"
                Patterns$ + "GEOS Files (*.cvt)|*.cvt;"                
                
                FileNames$ = OpenFileRequester("Wählen Sie einige Dateien aus", "", Patterns$, 0, #PB_Requester_MultiSelection)
                
            Case #False
                ;
                ; DragnDrop
        EndSelect
                    
        ;
        ; Sammle Dateien
        If ( FileNames$ )
            
            While FileNames$ 
                Dateien( LCase(FileNames$) )= FileNames$
                FileNames$=NextSelectedFileName()
            Wend    
        EndIf

        ; Info String mit DiskInterface
        Pos.i = FindString(C64DskInterface$, ":",1)
        DiskInterface$ = Trim( Mid(C64DskInterface$, Pos.i+1, Len(C64DskInterface$) - Pos.i))
        

        ForEach Dateien()
            CurrentFile$ = Dateien()
            Output_File$ = GetFilePart(CurrentFile$,#PB_FileSystem_NoExtension)
            
            If ( Len( Output_File$ ) >= 17 )
                Request::*MsgEx\User_BtnTextL = "Rename"
                Request::*MsgEx\User_BtnTextR = "Cancel"                 
                Request::*MsgEx\Return_String = Output_File$
                r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Rename File","Enter new File Name ( Max 16 Letters )",10,1,"",0,1,DC::#_Window_005)
                SetActiveGadget(DC::#ListIcon_003): 
                If (r = 0)                     
                    Output_File$ = Request::*MsgEx\Return_String
                EndIf
                If (r = 1)
                    ProcedureReturn
                EndIf    
            EndIf    
                
            C64Pattern$ = GetExtensionPart(CurrentFile$)
            Select UCase( C64Pattern$ )
                Case "PRG"
                    szCMD_Init_Filetype$ = " --file-type P"
                Case "SEQ"
                    szCMD_Init_Filetype$ = " --file-type S"
                Case "REL"    
                    Output_File$ +"."+ C64Pattern$
                Case "USR"
                    szCMD_Init_Filetype$ = " --file-type U"
                Case "TXT"
                    szCMD_Init_Filetype$ = " --file-type S" 
                Case "P00","S00", "R00", "U00"
                    Output_File$ +"."+ C64Pattern$     
                Case "CVT"                    
                    Output_File$ +"."+ C64Pattern$                                           
                Case "DEL"
                    szCMD_Init_Filetype$ = " --file-type D"                     
                Default
                    Output_File$ +"."+ C64Pattern$   
            EndSelect
            
            
            ; CBMCopy.exe Starten
            OpenCBMPrg$ = GetProgramm_Lister(3) ;            
            szCMD_Init$ = DSK_TransferMode()+" -q -w "+RealDiskDrive$+" "+Chr(34)+ CurrentFile$ +Chr(34)+" --output="+Chr(34)+ Output_File$ +Chr(34) +""+szCMD_Init_Filetype$
            Request::SetDebugLog("OpenCBM Copy To 1541:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))     
            
            ; Copy Info String
            C64LoadS8_CopyF$ = Chr(34)+ CurrentFile$ +Chr(34)+ " to " +DiskInterface$
            
            
            DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copypcfileto1541")                
        Next
        
        DSK_OpenCBM_Directory() 
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure.i DSK_OpenCBM_Copy_ImageFile_To_1541(CurrentFile$,CurrentPatt$,Counts,CurrentSize$, CurrentPos.i)    
        
        Protected D64_Image$, D64_Pattern$
        
        D64_Image$  = GetGadgetText(DC::#String_102)
        D64_Pattern$=  GetExtensionPart(D64_Image$)
        ;
        ; Check For Packed Format
        Select UCase( D64_Pattern$ )
            Case "ZIP": D64_Image$ = C64_PackedImage$                
            Case "7Z" : D64_Image$ = C64_PackedImage$    
            Case "RAR": D64_Image$ = C64_PackedImage$
            Default        
        EndSelect
        
        OpenCBMPrg$ = GetProgramm_Lister(0)   
        
        C64File$ = GetFilePart(CurrentFile$, #PB_FileSystem_NoExtension)
        C64File$ = DSK_SetCharSet(C64File$)
        
        ;
        ; Save Program to Binary
        ;
        TempRnd.i = Random(99999,10000)
        Tempsfx.s = GetExtensionPart(CurrentPatt$)
        TempNme.s = GetTemporaryDirectory() + "ds50f_" + Str(TempRnd) + ".tmp"
        
        C64LoadS8_CopyF$ =  Chr(34)+ C64File$ +Chr(34) + " to 1541"
        ;
        ; 
        szCMD_Init$ = Chr(34)+ D64_Image$ +Chr(34)+" -read " +Chr(34)+ C64File$ +Chr(34)+ " " +Chr(34)+ TempNme.s  +Chr(34)
        Request::SetDebugLog("c1541 Command Transfer/> Image:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))         
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyimgfileto1541")
        ;Delay(255)
                
        OpenCBMPrg$ = GetProgramm_Lister(3)
        szCMD_Init$ = DSK_TransferMode()+" -q -w " +RealDiskDrive$+" "+Chr(34)+ TempNme.s  +Chr(34)+ " --output=" +Chr(34)+ C64File$ +Chr(34)
        Request::SetDebugLog("OpenCBM Command Transfer/> Image:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))           
        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyimgfileto1541")        
        ;Delay(255)
        
        DeleteFile(TempNme,#PB_FileSystem_Force)
        If ( Counts >= 2)
           SetGadgetItemState(DC::#ListIcon_003, CurrentPos, 0) 
        EndIf             
        ProcedureReturn #True                        
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________  
    Procedure.i DSK_Image_TransferToPCHD(TrackOnly = #False)
        
        
       Protected D64Image$ = "", HDD_Backup$ = "", OpenCBMPrg$ = "", szCMD_Init$ = "", DriveError$, Exists.i
       
       Select INVMNU::*LHMNU64\READDL
               Case 1
                    Item_Clear() 
                    DSK_OpenCBM_Directory()
       EndSelect             
       
       If Error_DiskDrive_Show() = #False
          ProcedureReturn #False
       EndIf
         
       ;Delay(255)                 
       
       HDD_Backup$  = GetGadgetText(DC::#String_111)
              
       If ( FileSize(HDD_Backup$) <> -2 )                      
           Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Directory Not Found:"+#CR$+HDD_Backup$,2,2,"",0,0,DC::#_Window_005)
           SetActiveGadget(DC::#ListIcon_003): 
           ProcedureReturn
       EndIf
       
        
       ;
       D64Image$ =         GetGadgetText(DC::#Text_122)
       D64Image$ =         Trim(D64Image$,Chr(34))
       D64Image$ =         Trim(D64Image$,Chr(32))        
       D64Image$ + " (ID,"+ UCase( Trim(GetGadgetText(DC::#Text_123)))+")"
       
       Request::*MsgEx\User_BtnTextL = "Ok"
       Request::*MsgEx\User_BtnTextR = "Cancel"        
       Request::*MsgEx\Return_String = DSK_CmpCharSet(D64Image$, ",")
       
       
       ;
       ; Gebe Datei Namen
       Repeat
           r = Request::MSG(Startup::*LHGameDB\TitleVersion, "D64 File Name","Enter Image File Name (without .d64) ",10,1,"",0,1,DC::#_Window_005)
           SetActiveGadget(DC::#ListIcon_003): 
           If (r = 0)
               D64Image$ = Request::*MsgEx\Return_String            
           EndIf
           If (r = 1)
               ProcedureReturn #False
           EndIf    
       Until ( Len(D64Image$) <> 0 )
       
       ;
       ; Prüfe Gewisse Zeichen
       
       
       ;
       ; Datei schon vorhanden ?
       Repeat
          Exists = 0
          If ( FileSize( HDD_Backup$ + D64Image$ + ".D64") > 0 )              
              Request::*MsgEx\User_BtnTextM = "Overwrite"
              
              r = Request::MSG(Startup::*LHGameDB\TitleVersion, "D64 File Exists","Enter a New Image File (without .d64)",16,1,"",0,1,DC::#_Window_005)
              SetActiveGadget(DC::#ListIcon_003):               
              If (r = 0)
                  D64Image$ = Request::*MsgEx\Return_String               
                  Exists =  1                   
              EndIf
              If (r = 1)
                  ProcedureReturn #False                                    
              EndIf            
              If (r = 2)
                  Exists = 0
              EndIf 
           EndIf
       Until ( Exists = 0 )
       
       
       TrackBeg$ = ""
       TrackEnd$ = ""
       If TrackOnly = #True
          Request::*MsgEx\Return_String = "1;35"
          r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Copy Tracks From Start (1) to End (42/70) Track","Enter Track (for example 1;23)",10,1,"",0,1,DC::#_Window_005) 
          If (r = 0)
              
              S$ = StringField(Request::*MsgEx\Return_String,1,";")
              E$ = StringField(Request::*MsgEx\Return_String,2,";")              
              
              TrackBeg$ = " --start-track=" + S$
              TrackEnd$ = " --end-track="   + E$ + " " 
              
              D64Image$ = D64Image$ + "_TC_("+ S$ +"-"+ E$ +")"
          EndIf
          If (r = 1)
              ProcedureReturn #False                                    
          EndIf         
      EndIf  
      
       D64Image$ + ".D64"
       
       C64LoadS8_CopyF$ = Chr(34)+ D64Image$ + Chr(34)
       OpenCBMPrg$      = GetProgramm_Lister(5)
       
       ;
       ; Erstelle die Argumente
       szCMD_Init$      = DSK_TransferMode()+" "
       If ( INVMNU::*LHMNU64\USWARP = #False )
           szCMD_Init$      + "--no-warp "
           szCMD_Init$      + "--interleave="+Str( INVMNU::*LHMNU64\READIN ) + " "
           C64LoadS8_CopyF$ + " ( NO WARP )" 

       Else
           C64LoadS8_CopyF$ + " ( WARP )"
           szCMD_Init$      + "--warp "

       EndIf                   
       
       If ( INVMNU::*LHMNU64\RETRYC ! 0 )
           szCMD_Init$      + "--retry-count="+Str(INVMNU::*LHMNU64\RETRYC ) + " "       
       EndIf    
       
       If ( INVMNU::*LHMNU64\BAMOCP ! 0 )  
           szCMD_Init$      + "--bam-only "              
       EndIf
       
       szCMD_Init$ + TrackBeg$+ TrackEnd$+ RealDiskDrive$+" "+Chr(34)+ HDD_Backup$+D64Image$ +Chr(34)
       Request::SetDebugLog("OpenCBM Command Transfer/> Image:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))   
       
       DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.backupimage") 
       ;Delay(255)
       
       ;
       ; Image Finished, Prüfe ob es existiert
       If (FileSize( HDD_Backup$+D64Image$ ) >= 1)    
           Request::MSG(Startup::*LHGameDB\TitleVersion, "Finished","D64 "+ Chr(34)+ D64Image$ + Chr(34)+" Image stored in:"+#CR$+HDD_Backup$,2,0,"",0,0,DC::#_Window_005)
           SetActiveGadget(DC::#ListIcon_003): 
           ;
           ; Leg das Fertig image in den 1. Slot
           SetGadgetText(DC::#String_102, HDD_Backup$+D64Image$ )
           SetGadgetText(DC::#String_008, HDD_Backup$+D64Image$ )
           
            ;
            ; Öffnet ein Requester 
            If ( UseCBMModule = #True )
                ShowErrorAfter = #True
            Else
                ShowErrorAfter = #False
            EndIf 
       
           ProcedureReturn #True
       Else
           Request::MSG(Startup::*LHGameDB\TitleVersion, "Error","Problem: "+#CR$+"Image "+ Chr(34)+ D64Image$ + Chr(34)+" could'nt created",2,0,"",0,0,DC::#_Window_005)
           SetActiveGadget(DC::#ListIcon_003): 
           ProcedureReturn #False
       EndIf
       
   
       
    EndProcedure        
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________  
    Procedure.i DSK_Image_TransferTo1541()
        
        
        Protected D64Image$ = ""
        
        D64_Image$   = GetGadgetText(DC::#String_102)
        D64_Pattern$ = GetExtensionPart(D64_Image$)       
        ;
        ; Check For Packed Format
        Select UCase( D64_Pattern$ )
            Case "ZIP", "7Z", "RAR"
                D64_Image$ = C64_PackedImage$                                
            Default        
        EndSelect
        
        If ( FileSize(D64_Image$) >= 1 )
            
            DSK_OpenCBM_Init()
            Item_Side_SetAktiv(1)
            
            C64LoadS8_CopyF$ = Chr(34)+ GetFilePart( D64_Image$ ) + Chr(34)
            OpenCBMPrg$      = GetProgramm_Lister(5)        
            
            szCMD_Init$ = Chr(34)+ D64_Image$ +Chr(34)+ " " +RealDiskDrive$   ;DSK_TransferMode()+" "+DSK_TransferWarp(szCMD_Init$) +         
            
            Request::SetDebugLog("D64 Copy Image to Real:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))   
            
            DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.transferimage") 
            ;Delay(255)        
            ProcedureReturn #True
        Else
            Request::MSG(Startup::*LHGameDB\TitleVersion, "ERROR","Image Not Found" + Chr(34)+ D64_Image$ + Chr(34),2,0,"",0,0,DC::#_Window_005)
            ProcedureReturn #False
        EndIf
        
    EndProcedure  
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________                   
    Procedure.i Image_Rename_File( CurrentFile$ , CurrentPattern$ = "")
        
        Protected nDiskKopie.i = 0, C64_FileNme$ = "", C64_FileRen$ = "", DiskImage$ = "", Disk_Path$ = "", Disk_Name$ = "", Disk_Pattern$ = ""
        
        DiskImage$    = GetGadgetText(DC::#String_102)
        
        Select  UseCBMModule
            Case #False
                C64_FileNme$    = DSK_SetCharSet(CurrentFile$) 
                C64_FileNme$    = GetFilePart(C64_FileNme$, #PB_FileSystem_NoExtension)
                CurrentPattern$ = ""
                
            Case #True
                UseModule CBMDiskImage
                CurrentFile$    = Trim(CurrentFile$)
                CurrentPattern$ = Trim(CurrentPattern$)
               
                C64_FileNme$    = CurrentFile$+ ";" +CurrentPattern$
                C64_FileNme$    = DSK_SetCharSet(C64_FileNme$) 
;                 Select UCase( GetExtensionPart( DiskImage$ ) )
;                     Case "T64"
;                         C64_FileNme$ = DSK_SetCharSet(C64_FileNme$)
;                 EndSelect                 
        EndSelect
                          
        
        
        
        Disk_Path$    = GetPathPart(DiskImage$)
        Disk_Name$    = GetFilePart(DiskImage$, #PB_FileSystem_NoExtension)
        Disk_Pattern$ = GetExtensionPart(DiskImage$)
        
        If ( Request_FileSizeDialog(DiskImage$) = #False )
            ProcedureReturn 599
        EndIf    
        
        ;
        ; Rename Dialog
        If ( Request_RenameDialog(C64_FileNme$) = #True )
            
            C64_FileRen$ = Request::*MsgEx\Return_String
            If ( C64_FileRen$ = C64_FileNme$ )
                ;
                ; Beide Dateien sind Identisch
                ProcedureReturn 599
            EndIf
            
            ;
            ; Check Packed File
            DiskImage$ = PackerSupport_Create_FileCopy(DiskImage$)                     
            If ( DiskImage$ = "")
                ;
                ; Keine Untersützung (Pattern)
                ProcedureReturn 599
            EndIf
            
            Select  UseCBMModule
                Case #False
                        OpenCBMPrg$      = GetProgramm_Lister(0)             
                        C64LoadS8_CopyF$ = Chr(34)+C64_FileRen$+Chr(34)+" = "+Chr(34)+C64_FileNme$+Chr(34)                                      
                        szCMD_Init$      = Chr(34)+ DiskImage$ +Chr(34)+ " -rename " +Chr(34)+ C64_FileNme$ +Chr(34)+ " "  +Chr(34)+ C64_FileRen$ +Chr(34)
                        
                        Request::SetDebugLog("WinVice c1541.exe/ Rename:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))     
                        
                        DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.rename")  
                        
                        C64LoadS8_CopyF$ = "": ;Delay(255)   
                    Case #True
                        
                        C64_FileRen$    = DSK_SetCharSet(C64_FileRen$) 
                        NCbmfile$ = StringField(C64_FileRen$, 1, ";")
                        NCbmPatt$ = StringField(C64_FileRen$, 2, ";")
                        
                        
                        If ( R(DiskImage$, CurrentFile$, NCbmfile$,CurrentPattern$, NCbmPatt$) = -1)
                            Request::MSG(Startup::*LHGameDB\TitleVersion, "Rename File",*er\s,10,1,"",0,1,DC::#_Window_005)  
                        EndIf
            
            EndSelect
            If ( PackerSupport_Create_PackFile() = #False )
                ;
                ; Keine Untersützung (Pattern)
                ProcedureReturn 599
            EndIf               
            
            ProcedureReturn 500
        EndIf
        
        ProcedureReturn 599
    EndProcedure 
    ;**********************************************************************************************************************************************************************
    ;     Image Delete File
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure Image_Delete_File( CurrentFile$,CurrentPatt$,Counts,CurrentPos.i, PackCopyCount )
                
        Protected nDiskKopie.i = 0, C64_FileNme$ = "", C64_FileRen$ = "",Disk_Path$ = "", Disk_Name$ = "", Disk_Pattern$ = "", C64_Pattern$ = ""
        
        C64_FileNme$  = DSK_SetCharSet(CurrentFile$)           
        C64_FileNme$  = GetFilePart(C64_FileNme$, #PB_FileSystem_NoExtension)
        
        DiskImage$    = GetGadgetText(DC::#String_102)
        
        Disk_Path$    = GetPathPart(DiskImage$)
        Disk_Name$    = GetFilePart(DiskImage$, #PB_FileSystem_NoExtension)
        Disk_Pattern$ = GetExtensionPart(DiskImage$)
        
        If ( Request_FileSizeDialog(DiskImage$) = #False )
            ProcedureReturn 599
        EndIf 
        
        ;
        ; C64 Dateinamen Check
        Select UCase( CurrentPatt$ )
            Case "PRG": C64_Pattern$ = ",P"
            Case "SEQ": C64_Pattern$ = ",S"
            Case "REL": C64_Pattern$ = ",R"    
            Case "USR": C64_Pattern$ = ",U"  
            Case "DEL": C64_Pattern$ = ",U"                      
            Case "PRG<": C64_Pattern$ = ",P"                
            Default
                C64_Pattern$ = ""
        EndSelect  
           
        ;
        ; Nur eine Datei oder alle
        If ( Counts >= 2)
            
            Request::*MsgEx\User_BtnTextL = "Scratch All"
            MessageA$ = "Scratch All Files ( Delete Files) ?"            
            MessageB$ = "This will Scratch (Delete) "+Str(Counts)+" Files"
            
            If ( OpenCBM_Scratch_All(MessageA$, MessageB$) = #True )                            
                ;
                ; Check Packed File
                DiskImage$ = PackerSupport_Create_FileCopy(DiskImage$,PackCopyCount)                     
                If ( DiskImage$ = "")
                    ;
                    ; Keine Untersützung (Pattern)
                    ProcedureReturn 599
                EndIf
                
                OpenCBMPrg$      = GetProgramm_Lister(0)             
                C64LoadS8_CopyF$ = Chr(34)+CurrentFile$+"."+CurrentPatt$+Chr(34)  
                
                CurrentFile$ = DSK_SetCharSet(CurrentFile$)
                C64_Pattern$ = DSK_SetCharSet(C64_Pattern$)  
                
                szCMD_Init$      = Chr(34)+ DiskImage$ +Chr(34)+ " -delete " +Chr(34)+CurrentFile$+C64_Pattern$+Chr(34)  
                
                Request::SetDebugLog("WinVice c1541.exe/ Delete:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.scratch")  
               
                If ( PackerSupport_Create_PackFile() = #False )
                    ;
                    ; Keine Untersützung (Pattern)
                    ProcedureReturn 599
                EndIf 
            
                C64LoadS8_CopyF$ = ""
                If ( Counts >= 2)                 
                    SetGadgetItemState(DC::#ListIcon_003, CurrentPos, 0)                   
                EndIf                   
                ProcedureReturn 500
            Else
                ProcedureReturn 599
            EndIf    
                
        Else            
            Request::*MsgEx\User_BtnTextL = "Scratch"
            Request::*MsgEx\User_BtnTextR = "Abort"            
            MessageA$ = "Scratch ( Delete ) ?"             
            MessageB$ = CurrentFile$
            
            r = Request::MSG(Startup::*LHGameDB\TitleVersion, MessageA$,MessageB$,10,1,"",0,0,DC::#_Window_005)
            SetActiveGadget(DC::#ListIcon_003): 
            If ( r = 0 )   
                
                ;
                ; Check Packed File
                DiskImage$ = PackerSupport_Create_FileCopy(DiskImage$,PackCopyCount)                     
                If ( DiskImage$ = "")
                    ;
                    ; Keine Untersützung (Pattern)
                    ProcedureReturn 599
                EndIf
                
                OpenCBMPrg$      = GetProgramm_Lister(0)             
                C64LoadS8_CopyF$ = Chr(34)+CurrentFile$+"."+CurrentPatt$+Chr(34)   
                
                CurrentFile$ = DSK_SetCharSet(CurrentFile$)
                C64_Pattern$ = DSK_SetCharSet(C64_Pattern$)                  
                
                szCMD_Init$      = Chr(34)+ DiskImage$ +Chr(34)+ " -delete " +Chr(34)+CurrentFile$+C64_Pattern$+Chr(34)  
                
                Request::SetDebugLog("WinVice c1541.exe/ Delete:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.scratch")  
                
                If ( PackerSupport_Create_PackFile() = #False )
                    ;
                    ; Keine Untersützung (Pattern)
                    ProcedureReturn 599
                EndIf                 
                ProcedureReturn 500
            EndIf
            ProcedureReturn 599
        EndIf  
            
        
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        Creat a New Disk Image File
    ;______________________________________________________________________________________________________________________________________________________________________        
    Procedure.i Image_Create()
        
        Protected HDD_Backup$, Message$, Pattern$ = ".D64", FileName$, DiskTitle$, ExTracks.i = #False
        
        HDD_Backup$  = GetGadgetText(DC::#String_111)       
        
        If ( FileSize(HDD_Backup$) = -2 )           
            Debug INVMNU::*LHMNU64\NIMAGE
            
            Select INVMNU::*LHMNU64\NIMAGE
                Case 0: Pattern$ = "D64":  Message$ = "Create a New D64 (VC1541/2031) Image"
                Case 1: Pattern$ = "G64":  Message$ = "Create a New G64 (VC1541/2031 but in GCR coding) Image"                      
                Case 2: Pattern$ = "X64":  Message$ = "Create a New X64 (VC1541/2031)Image"
                Case 3: Pattern$ = "D71":  Message$ = "Create a New D71 (VC1571) Image"  
                Case 4: Pattern$ = "G71":  Message$ = "Create a New G71 (VC1571 but in GCR coding) Image"
                Case 5: Pattern$ = "D80":  Message$ = "Create a New D80 (CBM8050) Image"                      
                Case 6: Pattern$ = "D81":  Message$ = "Create a New D81 (VC1581) Image"
                Case 7: Pattern$ = "D82":  Message$ = "Create a New D82 (CBM8250/1001) Image"
                Case 8: Pattern$ = "T64":  Message$ = "Create a New Datasette Tape T64 (1530)"                        
            EndSelect   
            
            Request::*MsgEx\User_BtnTextL = "Create Image"
            Request::*MsgEx\User_BtnTextR = "Cancel"        
            Request::*MsgEx\Return_String = "NEWIMAGE"
            r = Request::MSG(Startup::*LHGameDB\TitleVersion,Message$,"Enter new File Name",10,1,"",0,1,DC::#_Window_005)        
            SetActiveGadget(DC::#ListIcon_003): 
            If (r = 0)            
                
                FileName$ = Request::*MsgEx\Return_String
                
                Request::*MsgEx\User_BtnTextL = "Ok"
                Request::*MsgEx\User_BtnTextR = "Cancel"        
                Request::*MsgEx\Return_String = "newdisk-"+LCase(Pattern$)+",id"
                r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Disk Header Title","Enter new Diskname and Disk ID",10,1,"",0,1,DC::#_Window_005)        
                SetActiveGadget(DC::#ListIcon_003): 
                If (r = 0)            
                    
                    
                    DiskTitle$ = Request::*MsgEx\Return_String
                    
                    Select Pattern$
                        Case "D64", "D71", "D81", "T64"
                            
                            UseModule CBMDiskImage
                            
                            DiskTitle$ = StringField(DiskTitle$,1,",")
                            DiskID$    = StringField(DiskTitle$,2,",") 
                            
                            If Pattern$ = "D64"
                                ExTracks = 1
                                If INVMNU::*LHMNU64\FORMAT = 0                                
                                    ExTracks = 3
                                EndIf    
                            EndIf
                            
                            If Pattern$ = "D71"
                                ExTracks = 1
                            EndIf             
                            
                            If Pattern$ = "D81" Or Pattern$ = "T64"
                                ExTracks = 0
                            EndIf                                                                                                                     
                           
                            If ( N(HDD_Backup$+FileName$, Pattern$, DiskTitle$ , DiskID$, ExTracks.i) = -1)
                                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ",*er\s,2,2,"",0,0,DC::#_Window_005)
                                SetActiveGadget(DC::#ListIcon_003): 
                                ProcedureReturn  #False                              
                            EndIf
                            
                            
                        Default    
                            OpenCBMPrg$      = GetProgramm_Lister(0) 
                            szCMD_Init$      = "-format "+Chr(34)+ DiskTitle$ +Chr(34)+" "+Pattern$+" "+Chr(34)+HDD_Backup$+FileName$+"."+Pattern$+Chr(34)
                            DSK_Thread_Prepare(OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.newimage")
                    EndSelect    
                    
                    If ( Request_FileSizeDialog(HDD_Backup$+FileName$+"."+Pattern$) = #True) 
                        SetGadgetText(DC::#String_102, HDD_Backup$+FileName$+"."+Pattern$ )
                        SetGadgetText(DC::#String_008, HDD_Backup$+FileName$+"."+Pattern$ )
                        ProcedureReturn #True
                    EndIf                                                
                    
                Else
                    ProcedureReturn #False
                EndIf                    
            Else
                ProcedureReturn #False
            EndIf
            
        Else
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Directory Not Found:"+#CR$+HDD_Backup$,2,2,"",0,0,DC::#_Window_005)                  
            SetActiveGadget(DC::#ListIcon_003): 
            ProcedureReturn
        EndIf                
    EndProcedure    
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________         
    Procedure.i DSK_OpenCBM_Tools(Tool$ = "rename")
        
        Protected ListID.i = DC::#ListIcon_003, Counts.i = 0, Result.i, PackCopyCount = 0
        
        If ( GetGadgetItemState(ListID,GetGadgetState(ListID) ) = 0 )            
              Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","No Filename Selected. Please Select a Filename ...",2,2,"",0,0,DC::#_Window_005)
              ProcedureReturn
          Else

              If ( RealDiskDrive$ = "0" ) And ( C64LoadS8_Side.i = 1 )                                  
                    DSK_OpenCBM_ErrDiskDrive()                        
                  ProcedureReturn #False
              EndIf                 
              
              
              For SelItem = 0 To CountGadgetItems(ListID)  
                  If ( GetGadgetItemState(ListID, SelItem) = #PB_ListIcon_Selected )
                      Counts + 1
                  EndIf
              Next
                                                                                   ;
              ; Setzt die Delete auf Null
              C64LoadS8_Delete = 0              
              
              For SelItem = 0 To CountGadgetItems(ListID)            
                  If GetGadgetItemState(ListID, SelItem) = #PB_ListIcon_Selected
                      CurrentPos.i = SelItem
                      CurrentFile$ = Trim( GetGadgetItemText(ListID, CurrentPos , 1), Chr(34) ) 
                      CurrentPatt$ = Trim( GetGadgetItemText(ListID, CurrentPos , 2), Chr(34) ) 
                      CurrentSize$ = Trim( GetGadgetItemText(ListID, CurrentPos,  0), Chr(34) )
                      PackCopyCount + 1
                      
                      Select Tool$
                          Case "rename"   : 
                              ; Dateien im Echten Laufwerk umbenennen
                              If ( C64LoadS8_Side.i = 1 )                                  
                                  Result = OpenCBM_Rename(  CurrentFile$)
                              EndIf
                              ; Dateien im Image Laufwerk umbenennen
                              If ( C64LoadS8_Side.i = -1 )                                  
                                  Result = Image_Rename_File(  CurrentFile$, CurrentPatt$)
                              EndIf    
                              
                          Case "scratch"  : 
                              ; Dateien im Echten Laufwerk umbenennen
                              If ( C64LoadS8_Side.i = 1 )                                  
                                   Result = OpenCBM_Scratch( CurrentFile$,CurrentPatt$,Counts,CurrentPos.i)
                              EndIf
                              ; Dateien im Image Laufwerk umbenennen
                              If ( C64LoadS8_Side.i = -1 )                                  
                                  Result = Image_Delete_File( CurrentFile$,CurrentPatt$,Counts,CurrentPos.i, PackCopyCount)
                              EndIf 
                                                           
                          Case "cpytopc"  : Result = OpenCBM_CopyFileToPC(CurrentFile$,CurrentPatt$,Counts,CurrentSize$, CurrentPos.i)
                          Case "cpytoim"  : Result = OpenCBM_CopyFileToIM(CurrentFile$,CurrentPatt$,Counts,CurrentSize$, CurrentPos.i, PackCopyCount)
                          Case "im2real"  : Result = DSK_OpenCBM_Copy_ImageFile_To_1541(CurrentFile$,CurrentPatt$,Counts,CurrentSize$, CurrentPos.i)  
                      EndSelect        
                  EndIf        
                  If ( Result = 999 ) Or ( Result = 599 )
                      Break;
                  EndIf
              Next                             
              
              If ( Result = #True)
                  If ( DSK_OpenCBM_Detect() = #False )
                       ProcedureReturn
                  EndIf
                   
                  If ( DSK_OpenCBM_CheckR64List() = #False)         
                       DSK_OpenCBM_Init()
                       Item_Clear() 
                       DSK_OpenCBM_Directory()
                   Else
                       ;DSK_OpenCBM_Init()
                        Item_Clear() 
                       DSK_OpenCBM_Directory()
                  EndIf
              EndIf
              
              If (Result = 999) Or ( Result = 998 ) 
                  OpenCBM_ListLoad()
              EndIf 
              
              If ( Result = 500 ) 
                  DSK_FormatCheck(GetGadgetText(DC::#String_102)) 
              EndIf               
              ;
              ; Setzt die Delete auf Null
              C64LoadS8_Delete = 0
              
              SetGadgetState(ListID, -1)
              Select Tool$
                  Case "rename"   : SetGadgetItemState(ListID,CurrentPos,1): Item_Select_List() 
                  Case "scratch"  : Item_Select_Index(ListID, CurrentPos.i)    
                  Case "cpytopc"  : Item_Select_Index(ListID, CurrentPos.i) 
                  Case "cpytoim"  : ProcedureReturn #True    
                  Case "im2real"  : Item_Select_Index(ListID, CurrentPos.i)                 
              EndSelect              
       EndIf 
    EndProcedure            
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________     
    Procedure.i Image_CopyFile_FromImageToHD()
        
        Protected ListID.i = DC::#ListIcon_003, CurrentPos.i, CurrentFile$, CurrentPatt$, CurrentSize$, HDD_Backup$
        
        HDD_Backup$  = GetGadgetText(DC::#String_111)
        
        If ( FileSize(HDD_Backup$) = -2 )   
            
            DiskImage$    = GetGadgetText(DC::#String_102)
            
            Disk_Path$    = GetPathPart(DiskImage$)
            Disk_Name$    = GetFilePart(DiskImage$, #PB_FileSystem_NoExtension)
            Disk_Pattern$ = GetExtensionPart(DiskImage$)           
            
            For SelItem = 0 To CountGadgetItems(ListID)            
                If GetGadgetItemState(ListID, SelItem) = #PB_ListIcon_Selected
                    CurrentPos.i = SelItem
                    CurrentFile$ = Trim( GetGadgetItemText(ListID, CurrentPos , 1), Chr(34) ) 
                    CurrentPatt$ = Trim( GetGadgetItemText(ListID, CurrentPos , 2), Chr(34) ) 
                    CurrentSize$ = Trim( GetGadgetItemText(ListID, CurrentPos,  0), Chr(34) )
                    
                    ;
                    ; C64 Dateinamen Check
                    Select UCase( CurrentPatt$ )
                        Case "PRG": C64_Pattern$ = ",P"
                        Case "SEQ": C64_Pattern$ = ",S"
                        Case "REL": C64_Pattern$ = ",R"    
                        Case "USR": C64_Pattern$ = ",U"  
                        Case "DEL": C64_Pattern$ = ",U"                      
                        Case "PRG<": C64_Pattern$ = ",P"                
                        Default
                            C64_Pattern$ = ""
                    EndSelect 
                    
                    CurrentFile$ = DSK_TransferSign_Check(CurrentFile$)                    
                    CurrentPatt$ = DSK_TransferSign_Check(CurrentPatt$,#True)
                    
                    CopyDest$        = HDD_Backup$ + CurrentFile$ + "." + CurrentPatt$                    
                    CopyDest$        = Request_CopyFileExists(CurrentFile$ + "." + CurrentPatt$, CopyDest$, HDD_Backup$)                    
                    If ( CopyDest$ = "" )
                        ProcedureReturn
                    EndIf                    
                    ;
                    ; Check Packed File
                    DiskImage$ = PackerSupport_Create_FileCopy(DiskImage$)                     
                    If ( DiskImage$ = "")
                        ;
                        ; Keine Untersützung (Pattern)
                        ProcedureReturn
                    EndIf
                    
                    OpenCBMPrg$      = GetProgramm_Lister(0)             
                    C64LoadS8_CopyF$ = Chr(34)+CurrentFile$+"."+CurrentPatt$+Chr(34)   
                    
                    CurrentFile$ = DSK_SetCharSet(CurrentFile$)
                    C64_Pattern$ = DSK_SetCharSet(C64_Pattern$)                  
                    
                    szCMD_Init$      = Chr(34)+ DiskImage$ +Chr(34)+ " -read " +Chr(34)+CurrentFile$+C64_Pattern$+Chr(34)+" "+Chr(34)+CopyDest$+Chr(34)
                    
                    Request::SetDebugLog("WinVice c1541.exe/ Copy To HD:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
                    DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyfiletopc")                  
                    
                    If ( FileSize( CopyDest$ ) >= 1 )
                        If ( Counts = 1)
                            Request::MSG(Startup::*LHGameDB\TitleVersion, "Succesfully Copied:","File has been Copied to: "+#CR$+CopyDest$ ,2,0,"",0,0,DC::#_Window_005) 
                            SetActiveGadget(DC::#ListIcon_003): 
                        EndIf    
                        If ( Counts >= 2)
                            SetGadgetItemState(DC::#ListIcon_003, CurrentPos, 0) 
                        EndIf    
                        ProcedureReturn 
                    Else
                        Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Copy Problem ? ... Please Check ...",2,2,"",0,0,DC::#_Window_005)
                        SetActiveGadget(DC::#ListIcon_003): 
                        ProcedureReturn
                    EndIf                                   
                EndIf
            Next
        Else                   
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","Directory Not Found:"+#CR$+HDD_Backup$,2,2,"",0,0,DC::#_Window_005)                  
            SetActiveGadget(DC::#ListIcon_003): 
            ProcedureReturn 999
        EndIf        
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________    
    Procedure.i Image_CopyFile_FromHDToImage(FileRequester = #True)
        
        Protected CurrentFile$ = "", Output_File$ = "", DiskInterface$ = "", Pos.i, FileNames$, Patterns$, C64Pattern$, szCMD_Init_Filetype$ ="", PackCopyCount = 0
        Protected C64_Pattern$ = ""
                
        NewMap Dateien.s()                              
        
        DiskImage$    = GetGadgetText(DC::#String_102)
        
        Disk_Path$    = GetPathPart(DiskImage$)
        Disk_Name$    = GetFilePart(DiskImage$, #PB_FileSystem_NoExtension)
        Disk_Pattern$ = GetExtensionPart(DiskImage$)
        
        If ( Request_FileSizeDialog(DiskImage$) = #False )
            ProcedureReturn 599
        EndIf  
        
        Select FileRequester
                
            Case #True
                Patterns$ = "C64 Files "
                Patterns$ + "(Supportet Patterns)"
                Patterns$ + "|*.prg;*.seq;*.rel;*.usr;*.txt;*.p00;*.s00;*.r00;*.u00;*.cvt;*.del|"
                Patterns$ + "C64: PRG   (*.prg)|*.prg|"
                Patterns$ + "C64: SEQ   (*.seq)|*.seq|"                
                Patterns$ + "C64: REL   (*.rel)|*.rel|"
                Patterns$ + "C64: USR   (*.usr)|*.usr|"
                Patterns$ + "C64: ASC   (*.txt)|*.txt|"
                Patterns$ + "C64: DEL   (*.del)|*.del|"                
                Patterns$ + "PC64 Files (*.p00;*.s00;*.r00;*.u00)|*.p00;*.s00;*.r00;*.u00|"
                Patterns$ + "GEOS Files (*.cvt)|*.cvt;"                
                
                FileNames$ = OpenFileRequester("Wählen Sie einige Dateien aus", "", Patterns$, 0, #PB_Requester_MultiSelection)
                
            Case #False
                ;
                ; DragnDrop
        EndSelect
        
        ;
        ; Sammle Dateien
        If ( FileNames$ )
            
            While FileNames$ 
                Dateien( LCase(FileNames$) )= FileNames$
                FileNames$=NextSelectedFileName()
                PackCopyCount + 1
            Wend    
        EndIf
                      
        ForEach Dateien()
            CurrentFile$ = Dateien()
            Output_File$ = GetFilePart(CurrentFile$,#PB_FileSystem_NoExtension)
            
            C64_FileNme$ = DSK_SetCharSet(CurrentFile$)
            C64_FileNme$ = GetFilePart(C64_FileNme$,#PB_FileSystem_NoExtension)            
            
            ;
            ; C64 Dateinamen Check
            Select UCase( GetExtensionPart(CurrentFile$) )
                Case "PRG": C64_Pattern$ = ",P"
                Case "SEQ": C64_Pattern$ = ",S"
                Case "REL": C64_Pattern$ = ",R"    
                Case "USR": C64_Pattern$ = ",U"  
                Case "DEL": C64_Pattern$ = ",D"                      
                Default
                   C64_Pattern$ = ""
           EndSelect 
           C64_Pattern$ = DSK_SetCharSet(C64_Pattern$)  
           
            ;
            ; Check Packed File
            DiskImage$ = PackerSupport_Create_FileCopy(DiskImage$, PackCopyCount)                     
            If ( DiskImage$ = "")
                ;
                ; Keine Untersützung (Pattern)
                ProcedureReturn
            EndIf           
            
            OpenCBMPrg$      = GetProgramm_Lister(0)             
            C64LoadS8_CopyF$ = Chr(34)+CurrentFile$+"."+CurrentPatt$+Chr(34)   
                    
            szCMD_Init$      = Chr(34)+ DiskImage$ +Chr(34)+ " -write " +Chr(34)+LCase(CurrentFile$)+Chr(34)+ " "+Chr(34)+LCase( C64_FileNme$+C64_Pattern$ )+Chr(34)
                    
             Request::SetDebugLog("WinVice c1541.exe/ Copy To HD:" + szCMD_Init$ + " " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))  
             DSK_Thread_Prepare(OpenCBMDir$+OpenCBMPrg$, szCMD_Init$, "OpenCBM.cbmctrl.copyfiletopc")              
             
            C64LoadS8_CopyF$ = "": ;Delay(255)   
            
            
            If ( PackerSupport_Create_PackFile() = #False )
                ;
                ; Keine Untersützung (Pattern)
                ProcedureReturn
            EndIf                
        Next        
        ProcedureReturn
    EndProcedure
    ;**********************************************************************************************************************************************************************
    ;        
    ;______________________________________________________________________________________________________________________________________________________________________ 
    Procedure.i DragnDrop_Load(Files$,GadgetID.i,DestGadgetID.i)
        
        Protected Count.i, cnt.i, CurrentFile$
        
        Count = CountString(Files$, Chr(10)) + 1
        
        ; TODO
        ; Need nice Solution for Copy PRG to Image and Quick Loading
        
        For cnt = 1 To Count
            CurrentFile$ = StringField(Files$, cnt, Chr(10))
            
            If CurrentFile$
                
                Select UCase (GetExtensionPart(CurrentFile$) )
                    Case "D64", "D71", "D80", "D81", "D82", "G64", "G71", "NIB", "T64", "X64", "7Z", "LNX", "RAR", "ZIP", "TAP", "CRT", "PRG", "P00"
                        ;
                        ; Fake Load for Drag and Drop
                        
                        Select UCase (GetExtensionPart(CurrentFile$) )
                            Case "D64", "D71", "D81", "T64"
                                UseCBMModule = #True
                                
                            Case "D80", "D82", "G64", "G71", "NIB", "X64", "7Z", "LNX", "RAR", "ZIP" 
                                UseCBMModule = #False
                                
                            Case "TAP" , "CRT", "PRG", "P00"  
                                UseCBMModule = #False
                                
                        EndSelect
                        
                        Item_Side_SetAktiv(-1)
                        
                        vEngine::GetFile_Programm_64(GadgetID.i, CurrentFile$)   
                        
                       If ( DSK_LoadImage(GadgetID.i,DestGadgetID.i, 1) = #True )             
                             Item_Auto_Select() 
                            Break
                        EndIf   
                        
                         
                   Case  "DEL","SEQ","PRG","USR","REL","D00","S00","P00","U00","R00"
                       
                       Select UseCBMModule
                           Case #True
                               UseModule CBMDiskImage
                               
                                ; Shift Chars
                                Prg$ = DSK_SetCharSet( CurrentFile$ )
                                
                                ;
                                ; Simple Copy File to Image Argument. No Specials like Splat or Locked File and Copy As.
                                ; Look at the Copy Argument For more Info
                                
                                If C(GetGadgetText(DC::#String_102), GetPathPart(Prg$), GetFilePart(Prg$,1), GetExtensionPart(Prg$), "DS", "", 0) = -1                                    
                                    Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: Copy File Error",*er\s,2,2,"",0,0,DC::#_Window_005)                                                                                          
                                EndIf 
                                SetActiveGadget(DC::#ListIcon_003)
                
                           Case #False
                       EndSelect
                       
                       ; WriteCBMFile(Charset, #False, CurrentFile$) 
                EndSelect 
            EndIf
        Next cnt                        
        
    EndProcedure    
    ;     Procedure.i DSK_OpenCBM_View()
;     EndProcedure        
;     Procedure.i DSK_OpenCBM_Reset()
;     EndProcedure        
;     Procedure.i DSK_OpenCBM_Status()
;     EndProcedure       
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 468
; FirstLine = 413
; Folding = vbH+58f-+-QB1fz
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\