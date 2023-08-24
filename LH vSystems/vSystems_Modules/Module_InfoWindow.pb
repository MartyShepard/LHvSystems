DeclareModule vInfo
    
    Declare     Debug_Logging(szInfo.s, bSnapHeight.i = #False)
    
    Declare     Window_Close()              ; Schliessen des Fensters
    Declare     Window_Reset()              ; Window Neusetzen
    Declare     Window_Reload()             ; Window Neuladen
    
    Declare     Window_SetSnapPos()         ; Setzt die Window Position (Auch im Callback)
    Declare     Window_Live_Update()        ; Callback Update
    
    Declare     Window_Props_Save()         ; Eigenschaften Speichern
    Declare     Window_Props_SetD()         ; Eigenschaften Standard
    
    Declare.i   Props_GetWidth()            ; Weite Beziehen
    Declare.i   Props_GetHeight()           ; Höhe Beziehen
    Declare     Props_GetCoords()           ; X/Y und Y des Hauptfenster beziehen
    
    Declare     Items_Default()             ; Setzt alle Einträge mit dem Aktullen Fenster Werten
    Declare     Items_Reset()               ; Setzt alle Einträge mit den Stanard Werten
    
    Declare     Tab_Switch(oGadgetID, ForceOpen.i = #False) 
    Declare     Tab_GetGadget()
    Declare     Tab_GetNames()
    Declare     Tab_SetName(EventGD.i, Standard.i)
    Declare.i   Tab_AutoOpen()
    Declare     Tab_AutoOpen_Set()
    
    Declare.i   File_CheckEncode (sFilename.s)
    
    Declare     Print_Text(hWnd, hInst, rtfEdit, LM, TM, RM, BM)
    
    Declare     Find_Dialog( EvntGadget.i ) 
    
    Declare     Modify_Reset()
    Declare     Modify_Pressed(EvntGadget.i)
    Declare.i   Modify_EndCheck()
    
    Declare.i   Wordwrap_Get()
    Declare     Wordwrap_Set()
    Declare.i   Wordwrap_Get_MnuItem()
    
    Declare     Caret_GetPosition()
    Declare     Caret_GetPosition_NonActiv()
    
    Declare     Get_MaxLines()
    
    Declare     TextFile_GetFormat(szFile.s, EvntEditGadget = -1)
    Declare     TextFile_isPacked(szFile.s)
    
    Declare.s   TextFile_Read(Filename. S, start_adr, end_adr, nEncode) 

EndDeclareModule
Module vInfo
    
    ; TODO
    ; Url Detect
    ; Auto Changes
    ; Title Rename
    ; Wordwrap
    ; Infos am Unteren Rand
    ; Buttons unten
    
    Macro ReadByteR (_HANDLE_)
    ReadByte (_HANDLE_) + 256
    EndMacro

    Enumeration
       #CODING_ERROR
       #CODING_ANY
       #CODING_UTF8
       #CODING_UTF16
    EndEnumeration
    
   ;**************************************************************************************************************************************************************** 
   ; 
    Macro IsModified( EvntGadget )  
        Bool(SendMessage_( GadgetID ( EvntGadget ), #EM_GETMODIFY, 0, 0) )        
    EndMacro
   ;**************************************************************************************************************************************************************** 
   ; 
   ;     Macro NoModified( EvntGadget )  
   ;         Bool(SendMessage_( GadgetID ( EvntGadget ), #EM_SETMODIFY, 0, 0) )        
   ;     EndMacro     
    ;****************************************************************************************************************************************************************
    ; Info Window Internal Reader
    ;****************************************************************************************************************************************************************    
    Procedure. S TextFile_Read(Filename. S, start_adr, end_adr, nEncode) 
        
        If ReadFile (0, Filename. S, nEncode);  opens an existing file or create if it does not exist yet 
            
            If end_adr <1 
                end_adr = Lof (0) 
                end_adr = end_adr - 1 
            EndIf 
            
            lenght = end_adr - start_adr 
            
            If lenght> 0 Or (start_adr> = 0 And start_adr <= Lof (0)) 
                
                Dim Buff.A (lenght) 
                
                If ArraySize (Buff ()) = lenght 
                    FileSeek (0, start_adr) 
                    
                    If ReadData (0, @Buff (), lenght + 1) 
                        
                        ;  Consider how many bytes are needed. 
                        CountBytes = Round (lenght / 16, #PB_Round_Up);  Find out skoltko lines will c sokrugleniem in a big way. 
                        CountBytes * ((16 * 4) + 2)                   ;  16 - The number of bytes in the string.  4 - a two HEX characters + 1 space + 1 in stock.  2 - byte newline. 
                        
                        Dim Result. C (CountBytes);  buffer under HEX data. 
                        
                        Pos = 0: EndPos = 0: NewLinePos = 0
                        
                        *Point = @Result() 
                        CopyMemoryString (0, @ *Point) 

                        Repeat                 
                        	;Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + #CR$ +"#"+#TAB$+" #Commandline Support : =======================================") 
                            
                        	Select Buff (Pos)
                        		Case 10
                        			Debug #PB_Compiler_Module + " = Position " + RSet( Str(pos), 10 , "0") + " [ 10 = Buffer Position - "+ RSet( Str(pos), 4 ," ") + "] (Special Char 10: Newline) "
                        			;String. S = ReplaceString( String. S, Chr(10), Chr(10), 0, pos, 1)
                        			NewLinePos = Pos
                        		Case 13	
                        			Debug #PB_Compiler_Module + " = Position " + RSet( Str(pos), 10 , "0") + " [ 13 = Buffer Position - "+ RSet( Str(pos), 4 ," ") + "] (Special Char 13: Return) "                        			
                        			;String. S = ReplaceString( String. S, Chr(13), #CR$, 0, pos, 1)
                        			EndPos = Pos
                        		Case 146
                        			;Debug #PB_Compiler_Module + " = Position " + RSet( Str(pos), 10 , "0") + " [" + RSet( Chr(Buff (Pos) ), 3 , " ") + " = Buffer Position - "+ RSet( Str(pos), 4 ," ") + "] (Special Database Char 146) "
                        			String. S + "'"
                        			Pos + 1
                        			lenght + 1
                                Case 130
                        			;Debug #PB_Compiler_Module + " = Position " + RSet( Str(pos), 10 , "0") + " [" + RSet( Chr(Buff (Pos) ), 3 , " ") + " = Buffer Position - "+ RSet( Str(pos), 4 ," ") + "] (Special Database Char 130) "
                        			String. S + ","                                               
                        			Pos + 1
                        			lenght + 1
                                Default          
                        			;Debug #PB_Compiler_Module + " = Position " + RSet( Str(pos), 10 , "0") + " [" + RSet( Chr(Buff (Pos) ), 3 , " ") + " = Buffer Position - "+ RSet( Str(pos), 4 , " ")                                   	                                                                	
                                    String. S + Chr (Buff (Pos) ) 
                             EndSelect       
                            
;                             Debug String
;                             For k = 0 To Len(String)
;                                 g.c = Asc( Mid( String,k,1 ) )
;                                 Debug Str( g ) + " Asc: " +Chr(g)
;                             Next                                                          
                             
                            Pos + 1
                            If ( EndPos >= 1 ) Or ( Pos >= lenght )
                                String + #CR$ 
                                CopyMemoryString (@ String) 
                                String = "" 
                                EndPos = 0 
                            ElseIf ( NewLinePos >= 1 ) Or ( Pos >= lenght )
                                String + #LF$ 
                                CopyMemoryString (@ String) 
                                String = "" 
                                NewLinePos = 0                             	
                            EndIf 
                            
                            
                        Until Pos>= lenght 
                        
                        sodergimoe$ = PeekS (@Result ()) 
                        
                        
                    Else 
                        MessageRequester ("Information", "Failed to load data") 
                    EndIf 
                    
                Else 
                    MessageRequester ("Information", "Memory allocation error") 
                EndIf 
                
            Else 
                MessageRequester ("Information", "Error of function arguments") 
            EndIf 
            
            CloseFile (0);  close the previously opened file 
            
        Else 
            MessageRequester ("Information", "Could not open file" + Filename.S + "to read") 
        EndIf 
        
       ; Debug "FULL TEXT"
       ; Debug "========="
       ; Debug sodergimoe$
        
        ProcedureReturn sodergimoe$
    EndProcedure      
    Procedure.i Tab_GetGadget()
        
        Protected EvntGadget = -1
        
           Select Startup::*LHGameDB\InfoWindow\bTabNum
           Case 1: EvntGadget = DC::#Text_128
           Case 2: EvntGadget = DC::#Text_129
           Case 3: EvntGadget = DC::#Text_130
           Case 4: EvntGadget = DC::#Text_131
       EndSelect
       
       If ( EvntGadget = -1 )
            msg.s = "Modul: " + #PB_Compiler_Module + #CR$ + "Line :" + Str(#PB_Compiler_Line) + #CR$ + "Lost Object Edit Focus - Activ = " + Str(Startup::*LHGameDB\InfoWindow\bTabNum) + #CR$ + "Use Tab 1.."
            Request::MSG(Startup::*LHGameDB\TitleVersion, "vSyst3ms Err0r"   ,msg,2,2)
            EvntGadget = DC::#Text_128
       EndIf
        
       ProcedureReturn EvntGadget
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
    Procedure.i Modify_EndCheck()
        Protected bSave.i = -1
        
        If ( Startup::*LHGameDB\InfoWindow\Modified\bEdit1 = 1 )
             bSave.i + 1
            ;
            ; Frage um zu Speichern
        EndIf
        
        If ( Startup::*LHGameDB\InfoWindow\Modified\bEdit2 = 1 )
            bSave.i + 1
            ;
            ; Frage um zu Speichern
        EndIf
        
        If ( Startup::*LHGameDB\InfoWindow\Modified\bEdit4 = 1 )
            bSave.i + 1
            ;
            ; Frage um zu Speichern
        EndIf
        
        If ( Startup::*LHGameDB\InfoWindow\Modified\bEdit3 = 1 )
            bSave.i + 1
            ;
            ; Frage um zu Speichern
        EndIf        
        
        If ( bSave >= 0 )
             
             MessageText$ = "There are still unsaved text changes in the memory."
             Request::*MsgEx\User_BtnTextL = "Save"
             Request::*MsgEx\User_BtnTextR = "Cancel"                  
             
             r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Save Changes"    ,MessageText$,10)
             If ( r = 0 )                 
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
                    
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt1 = ""
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt2 = ""
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt3 = ""
                    Startup::*LHGameDB\InfoWindow\Modified\szTxt4 = ""
                    Startup::*LHGameDB\InfoWindow\Modified\bEdit1 = 0
                    Startup::*LHGameDB\InfoWindow\Modified\bEdit2 = 0
                    Startup::*LHGameDB\InfoWindow\Modified\bEdit3 = 0
                    Startup::*LHGameDB\InfoWindow\Modified\bEdit4 = 0
                    Caret_GetPosition_NonActiv()
             EndIf
             
             If ( r = 1 )
             EndIf             
        EndIf     
        ProcedureReturn #True                           
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;    
    Procedure   Modify_Pressed(EvntGadget.i)
                        
        Select EvntGadget
            Case DC::#Text_128: 
                Startup::*LHGameDB\InfoWindow\Modified\bEdit1 = IsModified(EvntGadget)
                
                If ( Startup::*LHGameDB\InfoWindow\Modified\szTxt1 = GetGadgetText( EvntGadget ) )
                     Startup::*LHGameDB\InfoWindow\Modified\bEdit1 = 0           
                     ProcedureReturn 
                EndIf                                  
                ProcedureReturn
                
            Case DC::#Text_129: 
                Startup::*LHGameDB\InfoWindow\Modified\bEdit2 = IsModified(EvntGadget)              
                
                If ( Startup::*LHGameDB\InfoWindow\Modified\szTxt2 = GetGadgetText( EvntGadget ) )
                     Startup::*LHGameDB\InfoWindow\Modified\bEdit2 = 0
                     ProcedureReturn 
                EndIf                                  
                ProcedureReturn
                
            Case DC::#Text_130: 
                
                Startup::*LHGameDB\InfoWindow\Modified\bEdit3 = IsModified(EvntGadget)
                
                If ( Startup::*LHGameDB\InfoWindow\Modified\szTxt3 = GetGadgetText( EvntGadget ) )
                     Startup::*LHGameDB\InfoWindow\Modified\bEdit3 = 0
                     ProcedureReturn 
                EndIf                                  
                ProcedureReturn                
                
            Case DC::#Text_131: 
                Startup::*LHGameDB\InfoWindow\Modified\bEdit4 = IsModified(EvntGadget)              
                
                If ( Startup::*LHGameDB\InfoWindow\Modified\szTxt4 = GetGadgetText( EvntGadget ) )
                     Startup::*LHGameDB\InfoWindow\Modified\bEdit4 = 0
                     ProcedureReturn 
                EndIf                                  
                ProcedureReturn                
        EndSelect        
                
        
    EndProcedure     
   ;**************************************************************************************************************************************************************** 
   ;    
    Procedure   Modify_Reset()     
        
        Startup::*LHGameDB\InfoWindow\Modified\bEdit1 = 0
        Startup::*LHGameDB\InfoWindow\Modified\bEdit2 = 0        
        Startup::*LHGameDB\InfoWindow\Modified\bEdit3 = 0
        Startup::*LHGameDB\InfoWindow\Modified\bEdit4 = 0
        Startup::*LHGameDB\InfoWindow\Modified\szTxt1 = ""
        Startup::*LHGameDB\InfoWindow\Modified\szTxt2 = ""
        Startup::*LHGameDB\InfoWindow\Modified\szTxt3 = ""
        Startup::*LHGameDB\InfoWindow\Modified\szTxt4 = ""
        
    EndProcedure   
   ;****************************************************************************************************************************************************************
   ; Return the Encoding Format   
    Procedure.i File_CheckEnCode(sFilename.s)
        Protected hFile.l
        
        hFile = ReadFile (#PB_Any , sFilename)
        If Not hFile
            ProcedureReturn #CODING_ERROR
        EndIf
        
        Select ReadStringFormat(hFile)
            Case #PB_Ascii  : CloseFile (hFile): ProcedureReturn #PB_Ascii  ;Kein BOM gefunden. Dies kennzeichnet üblicherweise eine normale Textdatei.
            Case #PB_UTF8   : CloseFile (hFile): ProcedureReturn #PB_UTF8   ;UTF-8 BOM gefunden.
            Case #PB_Unicode: CloseFile (hFile): ProcedureReturn #PB_Unicode;UTF-16 (Little Endian) BOM gefunden.
            Case #PB_UTF16BE: CloseFile (hFile): ProcedureReturn #PB_UTF16BE;UTF-16 (Big Endian) BOM gefunden.
            Case #PB_UTF32  : CloseFile (hFile): ProcedureReturn #PB_UTF32  ;UTF-32 (Little Endian) BOM gefunden.
            Case #PB_UTF32BE: CloseFile (hFile): ProcedureReturn #PB_UTF32BE;UTF-32 (Big Endian) BOM gefunden.
        EndSelect 
        
        Select ReadByteR (hFile)
            Case $EF 
                Select ReadByteR (hFile)
                    Case $BB
                        
                        Select ReadByteR (hFile)
                            Case $BF: CloseFile (hFile):ProcedureReturn #CODING_UTF8
                            Default : CloseFile (hFile):ProcedureReturn #CODING_ANY
                        EndSelect
                        
                    Case $FE
                        Select ReadByteR (hFile)
                            Case $FF: CloseFile (hFile):ProcedureReturn #CODING_UTF16
                            Default : CloseFile (hFile):ProcedureReturn #CODING_ANY
                        EndSelect
                        
                    Case $FF
                        Select ReadByteR (hFile)
                            Case $FE: CloseFile (hFile):ProcedureReturn #CODING_UTF16
                            Default : CloseFile (hFile):ProcedureReturn #CODING_ANY
                        EndSelect
                        
                    Default
                        CloseFile (hFile): ProcedureReturn #CODING_ANY
                EndSelect
        EndSelect
        
        
        CloseFile (hFile)
        ProcedureReturn 0
    EndProcedure
   ;****************************************************************************************************************************************************************
   ; Debug Infos     
    Procedure   Debug_Logging(szInfo.s, bSnapHeight.i = #False)        
        ProcedureReturn 
        
        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "."+#TAB$+" Window GameID :"+Str( Startup::*LHGameDB\GameID            ))        
        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "."+#TAB$+" Window "+szInfo+"(X):"+Str( Startup::*LHGameDB\InfoWindow\x))
        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "."+#TAB$+" Window "+szInfo+"(Y):"+Str( Startup::*LHGameDB\InfoWindow\y))
        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "."+#TAB$+" Window "+szInfo+"(W):"+Str( Startup::*LHGameDB\InfoWindow\w))
        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "."+#TAB$+" Window "+szInfo+"(H):"+Str( Startup::*LHGameDB\InfoWindow\h))
        
        If ( bSnapHeight )
            Debug "." + #TAB$+ " Window Snap(H):"+Str( Startup::*LHGameDB\InfoWindow\SnapHeight )
            Debug "." + #TAB$+ " Window Snap(R):"+Str( Startup::*LHGameDB\InfoWindow\y + Startup::*LHGameDB\InfoWindow\SnapHeight)
        EndIf
        
            Debug "." + #TAB$+ " BorderSize 01 :"+ Str( WindowWidth( DC::#_Window_001, #PB_Window_FrameCoordinate) - WindowWidth(DC::#_Window_001) )
            Debug "." + #TAB$+ " BorderSize 06 :"+ Str( WindowWidth( DC::#_Window_006, #PB_Window_FrameCoordinate) - WindowWidth(DC::#_Window_006) ) 

        
        Debug "" 
        
    EndProcedure 
   ;****************************************************************************************************************************************************************
   ; Schliessen des Edit Fensters
    Procedure   Window_Close()
        
        If IsWindow( DC::#_Window_006 )
            CloseWindow( DC::#_Window_006 )   
        EndIf
        
        SetActiveWindow(DC::#_Window_001)         
    EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Schliessen des Edit Fensters
    Procedure   Window_Props_Save()
        
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinX", Str( Startup::*LHGameDB\InfoWindow\x) ,Startup::*LHGameDB\GameID)       
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinY", Str( Startup::*LHGameDB\InfoWindow\y) ,Startup::*LHGameDB\GameID)           
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinW", Str( Startup::*LHGameDB\InfoWindow\w) ,Startup::*LHGameDB\GameID)           
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinH", Str( Startup::*LHGameDB\InfoWindow\h) ,Startup::*LHGameDB\GameID)        
        
        Debug_Logging("Save", #True)       
    EndProcedure 
   ;****************************************************************************************************************************************************************
   ; Info Window Standard Eigenschaften Setzen     
    Procedure   Window_Props_SetD()
;         Startup::*LHGameDB\InfoWindow\x = 0
;         Startup::*LHGameDB\InfoWindow\y = WindowY( DC::#_Window_001,#PB_Window_InnerCoordinate )
;         Startup::*LHGameDB\InfoWindow\w = Startup::*LHGameDB\InfoWindow\Reset\w
;         Startup::*LHGameDB\InfoWindow\h = WindowHeight( DC::#_Window_001, #PB_Window_FrameCoordinate)
        
        Define rcClient.RECT
        Define rcWindow.RECT       
        
        GetClientRect_( WindowID ( DC::#_Window_001 ) , @rcClient)
        GetWindowRect_( WindowID ( DC::#_Window_001 ) , @rcWindow)  
        
        Startup::*LHGameDB\InfoWindow\SnapHeight = 0
        
        Startup::*LHGameDB\InfoWindow\x = 0
        Startup::*LHGameDB\InfoWindow\y = WindowY( DC::#_Window_001 ) -2
        Startup::*LHGameDB\InfoWindow\w = Startup::*LHGameDB\InfoWindow\Reset\w
        Startup::*LHGameDB\InfoWindow\h = rcClient\bottom + (GetSystemMetrics_(#SM_CXSIZEFRAME) *2 )         
    EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Info Window Eigenschaften Reseten   
    Procedure   Window_Reset()
        
        Window_Props_SetD()
        Window_Props_Save()          
        
    EndProcedure    
   ;****************************************************************************************************************************************************************
   ;       
    Procedure   Items_Update()
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinX", Str( Startup::*LHGameDB\InfoWindow\x) ,ExecSQL::_IOSQL()\nRowID)       
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinY", Str( Startup::*LHGameDB\InfoWindow\y) ,ExecSQL::_IOSQL()\nRowID)           
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinW", Str( Startup::*LHGameDB\InfoWindow\w) ,ExecSQL::_IOSQL()\nRowID)           
        ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditWinH", Str( Startup::*LHGameDB\InfoWindow\h) ,ExecSQL::_IOSQL()\nRowID)          
    EndProcedure
   ;****************************************************************************************************************************************************************
   ; Resetet Alle Einnträge mit der Standard Höhe des Info Window
    Procedure   Items_Reset()
        
        Protected Rows.i , result.i, oHeight.i, nHeight.s, strIndex.i, c.c, SetHeight.s, RowID.i
        
        Window_Props_SetD()
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
        
        Select Rows
            Case 0
            Default                                                                 
                ResetList(ExecSQL::_IOSQL())   
                
                HideGadget(DC::#Text_004,0)                
                
                For RowID = 1 To Rows              
                    NextElement(ExecSQL::_IOSQL())   
                    
                    SetGadgetText(DC::#Text_004," " + Str(RowID) + "/" + Str(Rows))
                    Items_Update()
                           
                Next                
                HideGadget(DC::#Text_004,1)                                 
        EndSelect                
        
    EndProcedure      
   ;****************************************************************************************************************************************************************
   ; Info Window Hole die Weite aus der DB    
    Procedure.i Props_GetWidth()
        
        Protected w.i
        
        w = ExecSQL::iRow(DC::#Database_001,"Gamebase","EditWinW",0,Startup::*LHGameDB\GameID,"",1)
        If ( w <> 0 )
            Startup::*LHGameDB\InfoWindow\w = w             
        EndIf
        
        ProcedureReturn Startup::*LHGameDB\InfoWindow\w                                       
    EndProcedure        
   ;****************************************************************************************************************************************************************
   ; Info Window Hole die Höhe aus der DB       
    Procedure.i Props_GetHeight()
                
        Protected h.i
               
        Define rcClient.RECT
        Define rcWindow.RECT
        Define ptDiffnt.POINT        
        
        GetClientRect_( WindowID ( DC::#_Window_001 ) , @rcClient) 
        GetWindowRect_( WindowID ( DC::#_Window_001 ) , @rcWindow)           
        
        ptDiffnt\y = (rcWindow\bottom - rcWindow\top) - rcClient\bottom
        
        h = ExecSQL::iRow(DC::#Database_001,"Gamebase","EditWinH",0,Startup::*LHGameDB\GameID,"",1)                
        If ( h = 0 )
            Startup::*LHGameDB\InfoWindow\h = rcClient\bottom
        Else
            Startup::*LHGameDB\InfoWindow\h = h
        EndIf 
        
        ProcedureReturn Startup::*LHGameDB\InfoWindow\h        
    EndProcedure 
   ;****************************************************************************************************************************************************************
   ; Info Window Hole X und Y aus der DB     
    Procedure   Props_GetCoords() 
        
        Startup::*LHGameDB\InfoWindow\x        = ExecSQL::iRow(DC::#Database_001,"Gamebase","EditWinX",0,Startup::*LHGameDB\GameID,"",1)          
        Startup::*LHGameDB\InfoWindow\y        = ExecSQL::iRow(DC::#Database_001,"Gamebase","EditWinY",0,Startup::*LHGameDB\GameID,"",1) + Startup::*LHGameDB\InfoWindow\SnapHeight
        
        Startup::*LHGameDB\InfoWindow\MainWinY   = WindowY( DC::#_Window_001 )         
        Startup::*LHGameDB\InfoWindow\SnapHeight = WindowY( DC::#_Window_001 ) - Startup::*LHGameDB\InfoWindow\MainWinY                  
        
    EndProcedure
   ;****************************************************************************************************************************************************************
   ;    
    Procedure   Window_Live_Update()
                
        Define rcClient.RECT
        Define rcWindow.RECT  
        Define ptDiffnt.POINT        
        
        Define xcClient.RECT
        Define xcWindow.RECT  
        Define xtDiffnt.POINT 
        
        Define desktop.RECT
        
        Protected hDesktop = GetDesktopWindow_();        
        
        GetClientRect_( WindowID ( DC::#_Window_006 ) , @rcClient)
        GetWindowRect_( WindowID ( DC::#_Window_006 ) , @rcWindow)          
        
        GetClientRect_( WindowID ( DC::#_Window_001 ) , @xcClient)
        GetWindowRect_( WindowID ( DC::#_Window_001 ) , @xcWindow)
        
        GetWindowRect_(hDesktop, @desktop);
        
        ptDiffnt\x = (rcWindow\right  -rcWindow\left) - rcClient\right
        ptDiffnt\y = (rcWindow\bottom - rcWindow\top) - rcClient\bottom

        horizontal = desktop\right
        vertical   = desktop\bottom
                
        Startup::*LHGameDB\InfoWindow\x = rcWindow\left
        Startup::*LHGameDB\InfoWindow\y = rcWindow\top  - Startup::*LHGameDB\InfoWindow\SnapHeight                
        
        Startup::*LHGameDB\InfoWindow\w = rcWindow\right - rcWindow\left
        Startup::*LHGameDB\InfoWindow\h = rcWindow\bottom - rcWindow\top 
        
        
        Debug_Logging("Live", #True)    
    EndProcedure
        
   ;****************************************************************************************************************************************************************
   ; Info Window, Fenster bleibt je nach Platz auf der Rechten oder Linken seite   
    Procedure   Window_Snap_Default()
        
        
        Startup::*LHGameDB\InfoWindow\x = WindowX( DC::#_Window_001 ) + WindowWidth( DC::#_Window_001,#PB_Window_FrameCoordinate )
        
        DesktopSpace.i = Startup::*LHGameDB\InfoWindow\DesktopW - Startup::*LHGameDB\InfoWindow\x
        
        Startup::*LHGameDB\InfoWindow\SnapHeight = WindowY( DC::#_Window_001 )- Startup::*LHGameDB\InfoWindow\MainWinY          
                             
        
        If ( DesktopSpace < Startup::*LHGameDB\InfoWindow\w )                                  
            Startup::*LHGameDB\InfoWindow\x  =  WindowX( DC::#_Window_001 ) - Startup::*LHGameDB\InfoWindow\w
        EndIf            
        
        

    EndProcedure
   ;****************************************************************************************************************************************************************
   ; Info Window, Fenster bleibt je nach Platz auf der Rechten oder Linken seite   
    Procedure   Window_Snap_Rechts()            
        Startup::*LHGameDB\InfoWindow\SnapHeight = WindowY( DC::#_Window_001 )- Startup::*LHGameDB\InfoWindow\MainWinY                                          
        Startup::*LHGameDB\InfoWindow\x  =  WindowX( DC::#_Window_001 ) - Startup::*LHGameDB\InfoWindow\w                       
    EndProcedure    
    ;****************************************************************************************************************************************************************
   ; Info Window, Fenster bleibt auf der Linken seite
    Procedure   Window_Snap_Left()     
        Startup::*LHGameDB\InfoWindow\x          = WindowX( DC::#_Window_001 ) + WindowWidth( DC::#_Window_001,#PB_Window_FrameCoordinate )                
        Startup::*LHGameDB\InfoWindow\SnapHeight = WindowY( DC::#_Window_001 )- Startup::*LHGameDB\InfoWindow\MainWinY                        
    EndProcedure        
   ;****************************************************************************************************************************************************************
   ; Info Window, Fenster bleibt auf der Linken seite
    Procedure   Window_Snap_Loose()
        
        ;Startup::*LHGameDB\InfoWindow\x = WindowX( DC::#_Window_006 )
        
        Startup::*LHGameDB\InfoWindow\y = WindowY( DC::#_Window_006)
        
        SetWindowPos_(WindowID(DC::#_Window_006), 0,
                      Startup::*LHGameDB\InfoWindow\x , 
                      Startup::*LHGameDB\InfoWindow\y  , ;Startup::*LHGameDB\InfoWindow\x + Startup::*LHGameDB\InfoWindow\SnapHeight
                      Startup::*LHGameDB\InfoWindow\w ,
                      Startup::*LHGameDB\InfoWindow\h , #SWP_NOACTIVATE)          
        
        Debug_Logging("Call", #True)        
        
    EndProcedure    
    ;****************************************************************************************************************************************************************
   ; Info Window, Update Eigenschaften       
    Procedure   Window_SetSnapPos()
        
        Protected DesktopSpace.i, Position.i
        ;
        ; TODO
        ; Startup::*LHGameDB\InfoWindow\SnapHeight
        ; Dynamische Andocken funktioniert noch nicht richtig 
        
        Select Startup::*LHGameDB\InfoWindow\bSide
            Case 1 : Window_Snap_Left() 
            Case -1: Window_Snap_Rechts() 
            Case 2 : Window_Snap_Loose() : ProcedureReturn                  
            Default: Window_Snap_Default()                
        EndSelect        
        
        
        SetWindowPos_(WindowID(DC::#_Window_006), 0,
                      Startup::*LHGameDB\InfoWindow\x , 
                      WindowY( DC::#_Window_001 )-2   , ;Startup::*LHGameDB\InfoWindow\x + Startup::*LHGameDB\InfoWindow\SnapHeight
                      Startup::*LHGameDB\InfoWindow\w ,
                      Startup::*LHGameDB\InfoWindow\h , #SWP_NOACTIVATE)        
        
        Debug_Logging("Call", #True)
    EndProcedure
   ;****************************************************************************************************************************************************************
   ; Info Window, Reload     
    Procedure   Window_Reload()    
        
        Props_GetCoords()        
        Props_GetWidth()
        Props_GetHeight()
        Debug_Logging("Load", #True) 
        
        Window_SetSnapPos()
                     
    EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Setze Alle Einträge mit der Standard Höhe des Aktullen Info Window
    Procedure   Items_Default()
        
        Protected Rows.i , result.i, oHeight.i, nHeight.s, strIndex.i, c.c, SetHeight.s, RowID.i
        
        ; Anzahl der Items in der DB Prüfen
        Rows = ExecSQL::CountRows(DC::#Database_001,"Gamebase")  
        
        Select Rows
            Case 0
            Default                                                                 
                ResetList(ExecSQL::_IOSQL())   
                
                HideGadget(DC::#Text_004,0)
                
                For RowID = 1 To Rows              
                    NextElement(ExecSQL::_IOSQL())   
                    
                    SetGadgetText(DC::#Text_004," " + Str(RowID) + "/" + Str(Rows))
                    
                    Items_Update()                          
                Next                
                HideGadget(DC::#Text_004,1)                                 
        EndSelect                
        
    EndProcedure 
   ;****************************************************************************************************************************************************************
   ; Websiten Detector     
    Procedure   Edit_Url_Support(oGadgetID)        
        SendMessage_(GadgetID(oGadgetID), #EM_SETEVENTMASK, 0, #ENM_LINK|SendMessage_(GadgetID(oGadgetID), #EM_GETEVENTMASK, 0, 0))
        SendMessage_(GadgetID(oGadgetID), #EM_AUTOURLDETECT, #True, 0)
  
    EndProcedure
   ;****************************************************************************************************************************************************************
   ; Tab Selector, Force Open. Wird nur bentz wenn der Screen geöffnet wird  
    Procedure   Tab_Switch(oGadgetID, ForceOpen.i = #False)
          
       
       If ( oGadgetID = DC::#Button_283  And Startup::*LHGameDB\InfoWindow\bTabNum = 1 ) And ( ForceOpen = #False)
           ProcedureReturn 
       EndIf
       If ( oGadgetID = DC::#Button_284  And Startup::*LHGameDB\InfoWindow\bTabNum = 2 ) And ( ForceOpen = #False)
           ProcedureReturn 
       EndIf
       If ( oGadgetID = DC::#Button_285  And Startup::*LHGameDB\InfoWindow\bTabNum = 3 ) And ( ForceOpen = #False)
           ProcedureReturn 
       EndIf
       If ( oGadgetID = DC::#Button_286  And Startup::*LHGameDB\InfoWindow\bTabNum = 4 ) And ( ForceOpen = #False)
           ProcedureReturn 
       EndIf
       
       ButtonEX::SetState(DC::#Button_283,0):
       ButtonEX::SetState(DC::#Button_284,0):     
       ButtonEX::SetState(DC::#Button_285,0):     
       ButtonEX::SetState(DC::#Button_286,0):
       
       HideGadget( DC::#Contain_16,1)
       HideGadget( DC::#Contain_17,1)
       HideGadget( DC::#Contain_18,1)
       HideGadget( DC::#Contain_19,1)
       
       SetActiveGadget(-1)
       SetFocus_( -1 )
       
      
       Select oGadgetID
               
           Case DC::#Button_283               
                ButtonEX::SetState(DC::#Button_283,1):               
                HideGadget( DC::#Contain_16,0)
                SetActiveGadget( DC::#Text_128 )
                SetFocus_( GadgetID( DC::#Text_128  ) )
                Edit_Url_Support(DC::#Text_128 ) 
                Startup::*LHGameDB\InfoWindow\bTabNum = 1
                vInfo::Wordwrap_Get()
                vInfo::Get_MaxLines()                
                vInfo::Caret_GetPosition()                
                ProcedureReturn 
                
            Case DC::#Button_284                      
                ButtonEX::SetState(DC::#Button_284,1):                
                HideGadget( DC::#Contain_17,0)
                SetActiveGadget( DC::#Text_129 )
                SetFocus_( GadgetID( DC::#Text_129  ) )
                Edit_Url_Support(DC::#Text_129 ) 
                Startup::*LHGameDB\InfoWindow\bTabNum = 2
                vInfo::Wordwrap_Get()
                vInfo::Get_MaxLines()                
                vInfo::Caret_GetPosition()
                ProcedureReturn 
                
            Case DC::#Button_285         
                ButtonEX::SetState(DC::#Button_285,1):                
                HideGadget( DC::#Contain_18,0)               
                SetActiveGadget( DC::#Text_130 )
                SetFocus_( GadgetID( DC::#Text_130  ) )                
                Edit_Url_Support(DC::#Text_130 ) 
                Startup::*LHGameDB\InfoWindow\bTabNum = 3
                vInfo::Wordwrap_Get()
                vInfo::Get_MaxLines()
                vInfo::Caret_GetPosition()
                ProcedureReturn 
                
            Case DC::#Button_286    
                ButtonEX::SetState(DC::#Button_286,1):                
                HideGadget( DC::#Contain_19,0)                
                SetActiveGadget( DC::#Text_131 )
                SetFocus_( GadgetID( DC::#Text_131  ) )                
                Edit_Url_Support(DC::#Text_131 ) 
                Startup::*LHGameDB\InfoWindow\bTabNum = 4
                vInfo::Wordwrap_Get()
                vInfo::Get_MaxLines()                
                vInfo::Caret_GetPosition()
                ProcedureReturn 
        EndSelect 
        
        
    EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Text Drucken , Set Margin 
    Procedure   Print_Dialog_SetMargin(nGadget, PageW, PageH, LM, TM, RM, BM, PrinterDC)
        
        r.RECT
        r\left  = LM
        r\top   = TM
        r\right = PageW - RM
        r\bottom= PageH - BM 
        
        SendMessage_( GadgetID( nGadget ), #EM_SETRECTNP, 0, r)
        
    EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Text Drucken , Start Druck     
    Procedure   Print_Dialog_StartPrint(szDocument.s, PrinterDC)

        d.DOCINFO
        d\cbSize      = SizeOf(d)
        d\lpszDocName = @Doc
        d\lpszOutput  = 0
        
        StartDoc_(PrinterDC,d)
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; Text Drucken , Callback
    Procedure.l Print_Dialog_Callback(hdlg, uMsg, wParam, lParam)
        
        Protected Result = #PB_ProcessPureBasicEvents, szMarked.s = "", rPosition.RECT
        
        Static *pd.PRINTDLG 
        
        Select uMsg
            Case #WM_INITDIALOG
                *pd = lParam                           
                
                rPosition\left   = WindowX     ( DC::#_Window_006)
                rPosition\right  = WindowWidth ( DC::#_Window_006)
                rPosition\top    = WindowY     ( DC::#_Window_006)
                rPosition\bottom = WindowHeight( DC::#_Window_006)
                
                SetWindowPos_(hDlg, WindowID( DC::#_Window_006 ), rPosition\left, rPosition\top + 65 , 0,0, #SW_SHOWNORMAL)               

                SetFocus_(GadgetID( Tab_GetGadget() ))

                
            Case #WM_COMMAND                
                button = wparam & $ffff
                
                Select button                                 
                    Case 1:    Debug "Starten" 
                        startup::*LHGameDB\InfoWindow\bPrint = #True
                        ProcedureReturn 0 
                    Case 2:    Debug "Abbrechen"
                        startup::*LHGameDB\InfoWindow\bPrint = #False
                        ProcedureReturn 0                     
                    Default
                        Debug "Print Window Action " + Str( button )
                        
                EndSelect                                 
        EndSelect        
        
   EndProcedure    
   ;****************************************************************************************************************************************************************
   ; Text Drucken (Alpha)       
    Procedure   Print_Text(hWnd, hInst, rtfEdit, LM, TM, RM, BM)
        
        Protected  PrinterDC
        
            #PD_ALLPAGES                  = $00000000
            #PD_COLLATE                   = $10
            #PD_DISABLEPRINTTOFILE        = $80000
            #PD_ENABLEPRINTHOOK           = $1000
            #PD_ENABLEPRINTTEMPLATE       = $4000
            #PD_ENABLEPRINTTEMPLATEHANDLE = $10000
            #PD_ENABLESETUPHOOK           = $2000
            #PD_ENABLESETUPTEMPLATE       = $8000
            #PD_ENABLESETUPTEMPLATEHANDLE = $20000
            #PD_HIDEPRINTTOFILE           = $100000
            #PD_NONETWORKBUTTON           = $200000
            #PD_NOPAGENUMS                = $8
            #PD_NOSELECTION               = $4
            #PD_NOWARNING                 = $80
            #PD_PAGENUMS                  = $2
            #PD_PRINTSETUP                = $40
            #PD_PRINTTOFILE               = $20
            #PD_RETURNDC                  = $100
            #PD_RETURNDEFAULT             = $400
            #PD_RETURNIC                  = $200
            #PD_SELECTION                 = $1
            #PD_SHOWHELP                  = $800
            #PD_USEDEVMODECOPIES          = $40000
            #PD_USEDEVMODECOPIESANDCOLLATE= $40000        
                
        pd.PRINTDLG
        
        pd\lStructSize          = SizeOf(PRINTDLG)
        pd\hwndOwner            = hWnd
        pd\hDevMode             = 0
        pd\hDevNames            = 0
        pd\nFromPage            = 0
        pd\nToPage              = 0
        pd\nMinPage             = 0
        pd\nMaxPage             = 0
        pd\nCopies              = 0
        pd\hInstance            = hInst
        pd\Flags                = #PD_HIDEPRINTTOFILE | #PD_NONETWORKBUTTON |#PD_RETURNDC | #PD_PRINTSETUP|#PD_ENABLESETUPHOOK
        pd\lpfnSetupHook        = @Print_Dialog_Callback()
        pd\lpSetupTemplateName  = 0
        pd\lpfnPrintHook        = 0
        pd\lpPrintTemplateName  = 0
        
        If PrintDlg_(pd)
            PrinterDC = pd\hDC
        Else
            PrinterDC = DefaultPrinter()
        EndIf
        ;
        ; Drucken abbrechen
        If startup::*LHGameDB\InfoWindow\bPrint = #False
            ProcedureReturn 
        EndIf
        
        
        If PrinterDC 
            cxPhysOffset = GetDeviceCaps_(PrinterDC, #PHYSICALOFFSETX)
            cyPhysOffset = GetDeviceCaps_(PrinterDC, #PHYSICALOFFSETY)
            
            cxPhys = GetDeviceCaps_(PrinterDC, #PHYSICALWIDTH)
            cyPhys = GetDeviceCaps_(PrinterDC, #PHYSICALHEIGHT)
            SendMessage_(rtfEdit, #EM_SETTARGETDEVICE, PrinterDC, cxPhys*20)
                                                 
            fr.FORMATRANGE       
            fr\hdc          = PrinterDC
            fr\hdcTarget    = PrinterDC
            
            fr\chrg\cpMin   = 0
            fr\chrg\cpMax   = -1
            
            fr\rcPage\left  = 0
            fr\rcPage\top   = 0
            fr\rcpage\right = 0
            fr\rcPage\bottom= 0
            
            fr\rc\left      = LM*20
            fr\rc\top       = TM*20
            fr\rc\right     = cxPhys * 1440/ GetDeviceCaps_(PrinterDC, #LOGPIXELSX)- RM*20
            fr\rc\Bottom    = cyPhys * 1440/ GetDeviceCaps_(PrinterDC, #LOGPIXELSY)- BM*20
            
            Print_Dialog_StartPrint("Printing", PrinterDC)
            
            StartPage_(PrinterDC)
            
            iTextOut = 0
            iTextAmt = SendMessage_(rtfEdit, #WM_GETTEXTLENGTH, 0, 0)
            

            ; Setze die Standard Farbe auf Schawrz
            SetGadgetColor(Tab_GetGadget() ,#PB_Gadget_FrontColor,$000000d)
            
            While iTextOut < iTextAmt
                iTextOut = SendMessage_(rtfEdit, #EM_FORMATRANGE, 1, fr)           
                
                If ( iTextOut < iTextAmt )
                    
                    EndPage_  (PrinterDC)
                    StartPage_(PrinterDC)
                    
                    fr\chrg\cpMin = iTextOut
                    fr\chrg\cpMax = -1
                    
                    iTextAmt = iTextAmt - iTextOut
                    iTextOut = 0
                EndIf
            Wend
            
            SendMessage_(rtfEdit, #EM_FORMATRANGE, 0, 0)
            
            EndPage_ (PrinterDC)
            EndDoc_  (PrinterDC)
            DeleteDC_(PrinterDC)
            
            ;
            ; Standard Einstellungen Setzen
            
            SetGadgetColor( Tab_GetGadget() ,#PB_Gadget_FrontColor, RGB(149, 160, 33) )
            SendMessage_  (rtfEdit     , #EM_SETTARGETDEVICE , #Null ,        0)
            
            DesktopEX::Icon_HideFromTaskBar(WindowID( DC::#_Window_006 ),1): 
            ;
            ; Vatriable Resetten
            startup::*LHGameDB\InfoWindow\bPrint = #False
            
        EndIf
    EndProcedure   
   ;****************************************************************************************************************************************************************
   ; Suche Dialog - Such Richtung
    Procedure   Find_Dialog_FRDOWN(hdlg, frdown = 1)        
        SetFocus_(hdlg)        
        Select frdown
            Case 1 : Startup::*LHGameDB\InfoWindow\FindReplace\Flags | #FR_DOWN                    
            Case 0: Startup::*LHGameDB\InfoWindow\FindReplace\Flags & (~#FR_DOWN)                   
        EndSelect
        Debug "Find Call: FRDOWN " + Str(Startup::*LHGameDB\InfoWindow\FindReplace\Flags)        
    EndProcedure 
   ;****************************************************************************************************************************************************************
   ; Suche Dialog - Gross - Kleinschreibung
    Procedure   Find_Dialog_MATCHCS(hdlg)        
        SetFocus_(hdlg)        
        
        If ( Startup::*LHGameDB\InfoWindow\FindReplace\Flags & #FR_MATCHCASE)             
             Startup::*LHGameDB\InfoWindow\FindReplace\Flags & (~#FR_MATCHCASE)
        Else
             Startup::*LHGameDB\InfoWindow\FindReplace\Flags | #FR_MATCHCASE
        EndIf
        
        Debug "Find Call: Match " + Str(Startup::*LHGameDB\InfoWindow\FindReplace\Flags)        
    EndProcedure     
   ;**************************************************************************************************************************************************************** 
   ; Suche Dialog - Ganzes Wort
    Procedure   Find_Dialog_WHWORD(hdlg)        
        SetFocus_(hdlg)        
        
        If ( Startup::*LHGameDB\InfoWindow\FindReplace\Flags & #FR_WHOLEWORD)             
             Startup::*LHGameDB\InfoWindow\FindReplace\Flags & (~#FR_WHOLEWORD)
        Else
             Startup::*LHGameDB\InfoWindow\FindReplace\Flags | #FR_WHOLEWORD
        EndIf
        
        Debug "Find Call: WHWORD " + Str(Startup::*LHGameDB\InfoWindow\FindReplace\Flags)        
    EndProcedure        
   ;**************************************************************************************************************************************************************** 
   ; 
    Procedure.l Find_Dialog_Start(hdlg, *p)
        
        Protected szText$ = ""
        
        fnt.FINDTEXTEX 
        SetFocus_(hdlg)
                        
        Protected  *fr.FINDREPLACE = *p                
        
        ;
        ; Copy Flags            
        *fr\Flags = Startup::*LHGameDB\InfoWindow\FindReplace\Flags 
        
        result = GetDlgItemText_(hDlg, 1152, *fr\lpstrFindWhat, *fr\wFindWhatLen)
        If result                                           
                       
            If ( *fr\Flags & #FR_FINDNEXT ):    uFlags = uFlags | #FR_FINDNEXT : EndIf
            If ( *fr\Flags & #FR_DOWN     ):    uFlags = uFlags | #FR_DOWN     : EndIf  
            If ( *fr\Flags & #FR_WHOLEWORD):    uFlags = uFlags | #FR_WHOLEWORD: EndIf  
            If ( *fr\Flags & #FR_MATCHCASE):    uFlags = uFlags | #FR_MATCHCASE: EndIf 
            
            szText$ = PeekS(*fr\lpstrFindWhat)  : fnt\lpstrText = @szText$ 
            
            Debug "Find Call: Suche Wort = " + szText$
            
           If ( uFlags & #FR_FINDNEXT )
                
                SendMessage_( GadgetID( Tab_GetGadget() ) , #EM_EXGETSEL,0, fnt\chrg )
                
                If (fnt\chrg\cpMin <> fnt\chrg\cpMax And uFlags & #FR_DOWN) Or (uFlags & #FR_DOWN)
                    fnt\chrg\cpMin = fnt\chrg\cpMax
                    fnt\chrg\cpMax = -1
                Else
                    fnt\chrg\cpMax = 0
                EndIf
                
                c = SendMessage_( GadgetID( Tab_GetGadget() ) , #EM_FINDTEXT, uFlags, fnt)
                If c <> -1
                    fnt\chrgText\cpMin = c
                    fnt\chrgText\cpMax = c + Len(szText$)                    
                    SendMessage_( GadgetID( Tab_GetGadget() ) ,#EM_EXSETSEL   , 0     , fnt\chrgText)
                Else                    
                    MessageRequester(Startup::*LHGameDB\TitleVersion, "No More to Find" + #CR$ + #CR$ + "End of Search for: " + Chr(32) + szText$ + Chr(32), #PB_MessageRequester_Ok)
                EndIf
                vInfo::Caret_GetPosition_NonActiv()   
            EndIf             
        EndIf
        ProcedureReturn *fr
    EndProcedure    
   ;**************************************************************************************************************************************************************** 
   ; 
    Procedure.l Find_Callback(hdlg, uMsg, wParam, lParam)
        
        Protected Result = #PB_ProcessPureBasicEvents, szMarked.s = "", rPosition.RECT
        
        Static *fr.FINDREPLACE 
        
        
        Select uMsg
            Case #WM_INITDIALOG
                *fr = lParam                           
                
                rPosition\left   = WindowX     ( DC::#_Window_006)
                rPosition\right  = WindowWidth ( DC::#_Window_006)
                rPosition\top    = WindowY     ( DC::#_Window_006)
                rPosition\bottom = WindowHeight( DC::#_Window_006)
                
                
                SetWindowPos_(hdlg, #HWND_TOPMOST, rPosition\left + 248 , rPosition\top + 202 , 0,0, #SW_SHOWNORMAL) 

                SetFocus_(GadgetID( Tab_GetGadget() ))
                
                Startup::*LHGameDB\InfoWindow\FindReplace\Flags       = *fr\flags 
                
                ProcedureReturn Result
                
            Case #WM_COMMAND                
                button = wparam & $ffff
                
                Select button                                 
                    Case 1:    Debug "Find Window Action: Weitersuchen" 
                        Find_Dialog_Start(hdlg , *fr)
                                                
                    Case 2:    Debug "Find Window Action: Abbrechen"
                        ProcedureReturn 0
                        
                    Case 1152: Debug "Find Window Action: Stringgadget"  ;$480                     
                        Startup::*LHGameDB\InfoWindow\kFind_Return = #False: ProcedureReturn 0
                        
                    Case 1040: Debug "Find Window Action: Ganzes Wort"
                        Find_Dialog_WHWORD(hdlg)
                        
                    Case 1041: Debug "Find Window Action: Groß Klein"
                        Find_Dialog_MATCHCS(hdlg)
                        
                    Case 1056: Debug "Find Window Action: Oben"
                         Find_Dialog_FRDOWN(hdlg,0)
                        
                    Case 1057: Debug "Find Window Action: Unten"
                        Find_Dialog_FRDOWN(hdlg,1)
                        
                    Default
                        Debug "Find Window Action " + Str( button )
                        
                EndSelect                                 
        EndSelect        
        
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;           
    Procedure   Find_Dialog( EvntGadget.i )                  
       Static fndrplc.FINDREPLACE, fnt.FINDTEXTEX 
       
       szFindWhat.s{4096}
       
       fndrplc\lStructSize    = SizeOf( FINDREPLACE )
       fndrplc\hwndOwner      = GadgetID( EvntGadget)     
       fndrplc\flags          = #FR_DOWN|#FR_ENABLEHOOK|#FR_FINDNEXT
       ;        #FR_ENABLEHOOK
       ;        #FR_HIDEUPDOWN
       ;        #FR_HIDEWHOLEWORD
       ;        #FR_DIALOGTERM
       ;        #FR_ENABLETEMPLATE
       ;        #FR_ENABLETEMPLATEHANDLE
       ;        #FR_FINDNEXT
       ;        #FR_HIDEMATCHCASE
       ;        #FR_HIDEUPDOWN
       ;        #FR_HIDEWHOLEWORD
       ;        #FR_MATCHCASE
       ;        #FR_NOMATCHCASE
       ;        #FR_NOUPDOWN
       ;        #FR_NOWHOLEWORD
       ;        #FR_REPLACE
       ;        #FR_REPLACEALL
       ;        #FR_SHOWHELP
       ;        #FR_WHOLEWORD
       
       ;
       ; Füge Markierten Text in den Such Dialog
       SendMessage_( GadgetID(EvntGadget) , #EM_EXGETSEL,0, fnt\chrgText )
       
       ;If ( fnt\chrgText\cpMax > 0 And fnt\chrgText\cpMin > 0 )
           
           SendMessage_( GadgetID(EvntGadget) , #EM_GETSELTEXT,0, @szFindWhat )
           If (szFindWhat)
               szFindWhat = Trim( szFindWhat )
               fndrplc\lpstrFindWhat  = @szFindWhat
               fndrplc\wFindWhatLen   = Len(szFindWhat)+1               
          Else         
               fndrplc\lpstrFindWhat  = @szFindWhat
               fndrplc\wFindWhatLen   = #MAX_PATH
            EndIf        
       ;EndIf    

       fndrplc\lpfnHook       = @Find_Callback()
       
       Startup::*LHGameDB\InfoWindow\kFind_Return = #True
       hdlg                                       = FindText_(fndrplc)

    EndProcedure       
   ;**************************************************************************************************************************************************************** 
   ;   
    Procedure   Tab_Set_NewName(EventGD.i, szTab.s)
                    
            ButtonEX::SetText( EventGD, 0, szTab)
            ButtonEX::SetText( EventGD, 1, szTab)
            ButtonEX::SetText( EventGD, 2, szTab)                                         
            
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;         
    Procedure.s Tab_Get_Name_Item(EventGD.i, szTab.s, szGet_GameItem.s)
        
            ;
            ; Aus dem Jeweiligen Eintrag Laden
            szTab.s = ExecSQL::nRow(DC::#Database_001,"Gamebase",szGet_GameItem,"",Startup::*LHGameDB\GameID,"",1)
        
            If ( szTab )
                Debug "Tab Use Individual New Name (Button Gadget " +Str( EventGD.i) + "): " + szTab.s
                Tab_Set_NewName(EventGD.i, szTab.s)
                ProcedureReturn szTab
            EndIf
            
            ProcedureReturn ""
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;            
    Procedure   Tab_Get_Name(EventGD)
        
        Protected szGet_Standard.s, szGet_GameItem.s, szDefaultTab.s, szTab.s
        
        Select EventGD
                Case DC::#Button_283: szGet_Standard.s = "Tab1": szGet_GameItem.s = "EditTtl1"
                Case DC::#Button_284: szGet_Standard.s = "Tab2": szGet_GameItem.s = "EditTtl2"
                Case DC::#Button_285: szGet_Standard.s = "Tab3": szGet_GameItem.s = "EditTtl3"                   
                Case DC::#Button_286: szGet_Standard.s = "Tab4": szGet_GameItem.s = "EditTtl4"               
        EndSelect         
        ;
        ; Auslesen aus der Einstellung
        szDefaultTab.s = ExecSQL::nRow(DC::#Database_001,"Settings",szGet_Standard,"",1,"",1)
        If (szDefaultTab)

            
            szTab = Tab_Get_Name_Item(EventGD.i, szTab.s, szGet_GameItem.s)
            If ( szTab )
                Tab_Set_NewName(EventGD.i, szTab.s)
                ProcedureReturn 
            Else
                        
                Debug "Tab Use Default    New Name (Button Gadget " +Str( EventGD.i) + "): " + szDefaultTab.s
                Tab_Set_NewName(EventGD.i, szDefaultTab.s)
                ProcedureReturn 
            EndIf    
            
        Else
            
            szTab = Tab_Get_Name_Item(EventGD.i, szTab.s, szGet_GameItem.s)
            If ( szTab )
                Tab_Set_NewName(EventGD.i, szTab.s)
                ProcedureReturn 
            Else
                        
                Debug "Tab Use Very  Default Name (Button Gadget " +Str( EventGD.i) + ")"
                Select EventGD
                    Case DC::#Button_283: Tab_Set_NewName(EventGD.i, "General"   ):ProcedureReturn 
                    Case DC::#Button_284: Tab_Set_NewName(EventGD.i, "Overview"  ):ProcedureReturn 
                    Case DC::#Button_285: Tab_Set_NewName(EventGD.i, "Trivia"    ):ProcedureReturn 
                    Case DC::#Button_286: Tab_Set_NewName(EventGD.i, "Additional"):ProcedureReturn 
                EndSelect             
            EndIf    
        EndIf    
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;     
    Procedure   Tab_GetNames()
        
        ; Tab Individual Names
        Debug ""
        Debug "- Use Tab Name(s)"
        Tab_Get_Name(DC::#Button_283)
        Tab_Get_Name(DC::#Button_284) 
        Tab_Get_Name(DC::#Button_285) 
        Tab_Get_Name(DC::#Button_286)                          
        
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
    Procedure   Tab_SetName(EventGD.i, Standard.i)
        
        Protected MessageText$, szTab.s
        
        If  ( Standard = #False )       
            MessageText$ = "Rename Tab"
            
            Request::*MsgEx\User_BtnTextL = "As Default"
            Request::*MsgEx\User_BtnTextM = "For This"             
            Request::*MsgEx\User_BtnTextR = "Cancel" 
            
            If GetGadgetText( DC::#String_112)                                                
                Request::*MsgEx\Return_String = ButtonEX::Gettext(EventGD) +" - " + GetFilePart( GetGadgetText( DC::#String_112), 1)
            Else                
                Request::*MsgEx\Return_String = ButtonEX::Gettext(EventGD)
            EndIf    
            
            
            r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Save Changes" ,MessageText$,16,0,ProgramFilename(),0,1,DC::#_Window_006)
            If ( r = 0 )    
                
                szTab = Request::*MsgEx\Return_String
                
                Select EventGD
                    Case DC::#Button_283: ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab1", szTab ,1)
                    Case DC::#Button_284: ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab2", szTab ,1)
                    Case DC::#Button_285: ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab3", szTab ,1)
                    Case DC::#Button_286: ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab4", szTab ,1)                 
                EndSelect        
                Tab_GetNames()
                ProcedureReturn 
            EndIf    
            
            If ( r = 2 )
                szTab = Request::*MsgEx\Return_String                
                
                Select EventGD
                    Case DC::#Button_283: ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl1", szTab ,Startup::*LHGameDB\GameID)
                    Case DC::#Button_284: ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl2", szTab ,Startup::*LHGameDB\GameID)
                    Case DC::#Button_285: ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl3", szTab ,Startup::*LHGameDB\GameID)
                    Case DC::#Button_286: ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl4", szTab ,Startup::*LHGameDB\GameID)                 
                EndSelect
                Tab_GetNames()
                ProcedureReturn 
            EndIf
        Else
            Select EventGD
                Case DC::#Button_283: 
                    ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab1", "" ,1)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl1", "" ,Startup::*LHGameDB\GameID)
                    
                Case DC::#Button_284: 
                    ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab2", "" ,1)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl2", "" ,Startup::*LHGameDB\GameID)
                    
                Case DC::#Button_285: 
                    ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab3", "" ,1)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl3", "" ,Startup::*LHGameDB\GameID)
                    
                Case DC::#Button_286: 
                    ExecSQL::UpdateRow(DC::#Database_001,"Settings", "Tab4", "" ,1)
                    ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "EditTtl4", "" ,Startup::*LHGameDB\GameID) 
            EndSelect
            Tab_GetNames() 
            ProcedureReturn 
        EndIf   
        
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;     
    Procedure.i Wordwrap_Get_MnuItem()    
        
        Protected bWordwrap.i
        
        bWordwrap.i = ExecSQL::iRow(DC::#Database_001,"Gamebase","Wordwrap",0,Startup::*LHGameDB\GameID,"",1)
        
        If ( bWordwrap = #False )
             bWordwrap = #True
             Debug "Zeilenumbruch Aktiv:" + Str(bWordwrap ) 
        Else
            bWordwrap = #False
            Debug "Zeilenumbruch Nicht Aktiv:" + Str(bWordwrap ) 
        EndIf
        
       
        
        ProcedureReturn bWordwrap
    EndProcedure            
   ;**************************************************************************************************************************************************************** 
   ;        
    Procedure.i Wordwrap_Get()
                
        Select Wordwrap_Get_MnuItem() 
            Case 1:
                Debug "Zeilenumbruch Ein"
                SetGadgetAttribute(DC::#Text_128, #PB_Editor_WordWrap,1) 
                SetGadgetAttribute(DC::#Text_129, #PB_Editor_WordWrap,1) 
                SetGadgetAttribute(DC::#Text_130, #PB_Editor_WordWrap,1) 
                SetGadgetAttribute(DC::#Text_131, #PB_Editor_WordWrap,1)                 
                ;                 SendMessage_(GadgetID( DC::#Text_128 ), #EM_SETTARGETDEVICE, #Null, $FFFF)
                ;                 SendMessage_(GadgetID( DC::#Text_129 ), #EM_SETTARGETDEVICE, #Null, $FFFF)
                ;                 SendMessage_(GadgetID( DC::#Text_130 ), #EM_SETTARGETDEVICE, #Null, $FFFF)
                ;                 SendMessage_(GadgetID( DC::#Text_131 ), #EM_SETTARGETDEVICE, #Null, $FFFF)
                
            Case 0:                              
                Debug "Zeilenumbruch Aus"  
                SetGadgetAttribute(DC::#Text_128, #PB_Editor_WordWrap,0) 
                SetGadgetAttribute(DC::#Text_129, #PB_Editor_WordWrap,0) 
                SetGadgetAttribute(DC::#Text_130, #PB_Editor_WordWrap,0) 
                SetGadgetAttribute(DC::#Text_131, #PB_Editor_WordWrap,0) 
                ;                 SendMessage_(GadgetID( DC::#Text_128), #EM_SETTARGETDEVICE, #Null, 0) 
                ;                 SendMessage_(GadgetID( DC::#Text_129), #EM_SETTARGETDEVICE, #Null, 0)
                ;                 SendMessage_(GadgetID( DC::#Text_130), #EM_SETTARGETDEVICE, #Null, 0)
                ;                 SendMessage_(GadgetID( DC::#Text_131), #EM_SETTARGETDEVICE, #Null, 0)                
        EndSelect        
        vInfo::Caret_GetPosition_NonActiv()
        
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;    
   Procedure    Wordwrap_Set()
        
        Select Wordwrap_Get_MnuItem() 
            Case 0:
                Debug "Zeilenumbruch an -  Saved 1"
                ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Wordwrap", Str(0) ,Startup::*LHGameDB\GameID)                 
            Case 1:
                Debug "Zeilenumbruch aus - Saved 0"                
                ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "Wordwrap", Str(1) ,Startup::*LHGameDB\GameID)              
        EndSelect        
        
        Wordwrap_Get()
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ; 
   Procedure    Caret_Set_Infos(x.i, y.i, nMax.i, nPos.i)
       
       Protected szMod.s ="", szEditInfo.s, szMarked.s = ""
       
       If (Startup::*LHGameDB\InfoWindow\Modified\bEdit1 = 1) Or
          (Startup::*LHGameDB\InfoWindow\Modified\bEdit2 = 1) Or
          (Startup::*LHGameDB\InfoWindow\Modified\bEdit3 = 1) Or
          (Startup::*LHGameDB\InfoWindow\Modified\bEdit4 = 1)
           szMod = "($) "
       EndIf
       
       Debug "\nModify"
       Debug "Startup::*LHGameDB\InfoWindow\Modified\bEdit1 =" + Str( Startup::*LHGameDB\InfoWindow\Modified\bEdit1 ) 
       Debug "Startup::*LHGameDB\InfoWindow\Modified\bEdit2 =" + Str( Startup::*LHGameDB\InfoWindow\Modified\bEdit2 )        
       Debug "Startup::*LHGameDB\InfoWindow\Modified\bEdit3 =" + Str( Startup::*LHGameDB\InfoWindow\Modified\bEdit3 )        
       Debug "Startup::*LHGameDB\InfoWindow\Modified\bEdit4 =" + Str( Startup::*LHGameDB\InfoWindow\Modified\bEdit4 )        
       
       szEditInfo + szMod + "Items: "+ Str( CountGadgetItems( DC::#ListIcon_001) ) + " - "
       szEditInfo + "Sel: "   + RSet( Str( GetGadgetState( DC::#ListIcon_001)+1 ), 3, Chr(32) ) + " | " 
       szEditInfo + "Line: " + RSet( Str(y), 4, Chr(32) ) + "/"
       szEditInfo + RSet( Str( nMax ), 4, Chr(32) ) +" | " 
       szEditInfo + "Pos: "  + RSet( Str( nPos ), 8, Chr(32) ) +" | "  
                          
       SetGadgetText(DC::#Text_132, szEditInfo )
                     
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;    
   Procedure.i Caret_GetPosition_NonActiv()
        
          g.i = GadgetID( Tab_GetGadget() )
            
            Protected Range.CHARRANGE, ncLine.i, nColumn.i, Caret.Point
            
            ;
            ; Cursor X: Line
            SendMessage_(g,  #EM_EXGETSEL, 0, @Range)
            Caret\x = Range\cpMax - (SendMessage_(g, #EM_LINEINDEX, SendMessage_(g, #EM_EXLINEFROMCHAR, 0, Range\cpMin), 0)) + 1
            
            Range\cpMax = 0
            Range\cpMin = 0
            ;
            ;
            SendMessage_(g,  #EM_EXGETSEL, 0, @Range)
            Caret\y = SendMessage_(g, #EM_EXLINEFROMCHAR, 0, Range\cpMin) + 1
            
            Caret_Set_Infos(Caret\x, Caret\y, Startup::*LHGameDB\InfoWindow\nMaxLines, Range\cpMax)      
            
        ProcedureReturn -1
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;    
   Procedure.i Caret_GetPosition()
                        
        If ( GetActiveGadget() =  Tab_GetGadget() )
            g.i = GadgetID( GetActiveGadget())
            
            Protected Range.CHARRANGE, ncLine.i, nColumn.i, Caret.Point
            
            ;
            ; Cursor X: Line
            SendMessage_(g,  #EM_EXGETSEL, 0, @Range)
            Caret\x = Range\cpMax - (SendMessage_(g, #EM_LINEINDEX, SendMessage_(g, #EM_EXLINEFROMCHAR, 0, Range\cpMin), 0)) + 1
                        
            Range\cpMax = 0
            Range\cpMin = 0
            ;
            ;
            SendMessage_(g,  #EM_EXGETSEL, 0, @Range)
            Caret\y = SendMessage_(g, #EM_EXLINEFROMCHAR, 0, Range\cpMin) + 1
             
            Caret_Set_Infos(Caret\x, Caret\y, Startup::*LHGameDB\InfoWindow\nMaxLines, Range\cpMax)   
        EndIf
        ProcedureReturn -1
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;      
   Procedure  Get_MaxLines()
       
       Protected dwRange, Range.CHARRANGE
       
       If ( IsGadget( Tab_GetGadget() ) )
           
           g.i = GadgetID( Tab_GetGadget() )
           
           Startup::*LHGameDB\InfoWindow\nMaxLines = SendMessage_(g, #EM_GETLINECOUNT, 0, 0)
           
           
       EndIf    
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;     
   Procedure.i Tab_AutoOpen()        
        If ( Startup::*LHGameDB\InfoWindow\bTabAuto = #True )
            ProcedureReturn 0
        EndIf
        ProcedureReturn 1
   EndProcedure     
   ;**************************************************************************************************************************************************************** 
   ;   
   Procedure  Tab_AutoOpen_Set()        
        If (Startup::*LHGameDB\InfoWindow\bTabAuto = #True )
            ExecSQL::UpdateRow(DC::#Database_001,"Settings", "TabAutoOpen" , Str(0),1)            
        Else
            ExecSQL::UpdateRow(DC::#Database_001,"Settings", "TabAutoOpen" , Str(1),1)
        EndIf
        Startup::*LHGameDB\InfoWindow\bTabAuto = ExecSQL::iRow(DC::#Database_001,"Settings","TabAutoOpen",0,1,"",1)                       
   EndProcedure   
   ;**************************************************************************************************************************************************************** 
   ;    
   Procedure.s  PB_GetPrivateProfileString(lpAppName.s, lpKeyName.s , lpDefault.s , lpReturnedString.s , nSize.i, lpFileName.s) 
       
            ;        DWORD GetPrivateProfileString(
            ;           LPCTSTR lpAppName,
            ;           LPCTSTR lpKeyName,
            ;           LPCTSTR lpDefault,
            ;           LPTSTR  lpReturnedString,
            ;           DWORD   nSize,
            ;           LPCTSTR lpFileName
            ;        );   
       
       GetPrivateProfileString_ (@lpAppName, @lpKeyName , @lpDefault , @lpReturnedString , nSize, @lpFileName) 
       ProcedureReturn lpReturnedString       
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;    
   Procedure.s   TextFile_GetURL(szFile.s)
       
       Protected  szText.s
       szText.s = PB_GetPrivateProfileString( "DEFAULT", "BASEURL", "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), szFile)
       If Not (szText = "")
           ProcedureReturn szText
       EndIf
       
       szText.s = PB_GetPrivateProfileString( "InternetShortcut", "URL", "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), szFile)       
       If Not (szText = "")
           ProcedureReturn szText
       EndIf
       
       ProcedureReturn ""
       
   EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;     
   Procedure.s  TextFile_isURL(szFile.s)   
       
       Startup::*LHGameDB\InfoWindow\szXmlText = ""
       
       sztext.s = TextFile_GetURL(szFile.s)
       If (sztext)                                  
           ;Startup::*LHGameDB\InfoWindow\szXmlText + RSet("=", 50, "=")  + #CR$         
           Startup::*LHGameDB\InfoWindow\szXmlText + "       : " + GetFilePart( szFile, 1)+ #CR$
           Startup::*LHGameDB\InfoWindow\szXmlText + "Website: " + sztext + #CR$
           Startup::*LHGameDB\InfoWindow\szXmlText + RSet("=", 50, "=")  + #CR$         
           ;Startup::*LHGameDB\InfoWindow\szXmlText + #CR$
       EndIf    
       
   EndProcedure          
   ;**************************************************************************************************************************************************************** 
   ;  
   Procedure.i  TextFile_isDOC(szFile.s)
       
       If OpenFile( DC::#TMPFile, szFile )
           
           szFileFormat.s = ""
           
           If ReadFile(DC::#TMPFile, szFile )   
               
               length = Lof(DC::#TMPFile)                            ; Länge der geöffneten Datei ermitteln
                 
                *MemoryID = AllocateMemory(length)         ; Reservieren des benötigten Speichers
                If *MemoryID
                    
                    bytes = ReadData(DC::#TMPFile, *MemoryID, length)   ; Einlesen aller Daten in den Speicherblock
                    Debug "Anzahl der gelesenen Bytes: " + Str(bytes)
                    
                    For b = 0 To bytes
                        
                        FileSeek(DC::#TMPFile, b)
                        
                        szFileFormat + Chr( ReadAsciiCharacter(DC::#TMPFile) )
                        
                        Select szFileFormat
                            Case "{\rtf1": ProcedureReturn 1                               
                        EndSelect       
                        
                        If ( b = 10 )
                            Break;
                        EndIf
                        
                    Next    
                EndIf
            EndIf  
            CloseFile(DC::#TMPFile)
        EndIf
        ProcedureReturn 0
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;         
    Procedure.s TextFile_XML_Tree(*CurrentNode, CurrentSublevel)
        
        Protected CatchNodeText.i = #False, szRaw.s =""
        ; Ignore anything except normal nodes. See the manual for
        ; XMLNodeType() for an explanation of the other node types.
        ;
        If XMLNodeType(*CurrentNode) = #PB_XML_Normal
            
            ; Add this node to the tree. Add name and attributes
            ;
            Text$ = GetXMLNodeName(*CurrentNode) + ": "
             If ( Text$ = "w:t: " ) Or (Text$ =  "text:span: ")
                 CatchNodeText = #True
             EndIf    
            
            If ExamineXMLAttributes(*CurrentNode)
                While NextXMLAttribute(*CurrentNode)
                    Text$ + " Attribute:" + XMLAttributeName(*CurrentNode) + "=" + Chr(34) + XMLAttributeValue(*CurrentNode) + Chr(34) + " "    
                Wend
            EndIf
            
            Text$ + " " + GetXMLNodeText(*CurrentNode)
            Debug "[+]" + Text$ + #TAB$ + "CurrentSublevel: " + Str(CurrentSublevel)
                
            If ( CatchNodeText = #True )
                CatchNodeText = #False
                If GetXMLNodeText(*CurrentNode)
                     Startup::*LHGameDB\InfoWindow\szXmlText + GetXMLNodeText(*CurrentNode) + Chr(13)
                EndIf    
            EndIf                
            
            ; Now get the first child node (if any)
            ;    
            *ChildNode = ChildXMLNode(*CurrentNode)
            
            ; Loop through all available child nodes and call this procedure again
            ;
            While *ChildNode <> 0
                TextFile_XML_Tree(*ChildNode, CurrentSublevel + 1)      
                *ChildNode = NextXMLNode(*ChildNode)
            Wend                                 
        EndIf                
    EndProcedure    
   ;**************************************************************************************************************************************************************** 
   ;     
    Procedure   TextFile_XML_Catch(*Memory, nSize)  
        
        If ( CatchXML(DC::#XML, *Memory, nSize) )
                                    
             *MainNode = MainXMLNode(DC::#XML)      
             If *MainNode                 
                 TextFile_XML_Tree(*MainNode, 0)
            EndIf
        EndIf                
    EndProcedure     
   ;**************************************************************************************************************************************************************** 
   ;  
   Procedure.i TextFile_isXML(szFile.s)
       
       If OpenFile( DC::#TMPFile, szFile )
                      
           If ReadFile(DC::#TMPFile, szFile )   
               
               length = Lof(DC::#TMPFile)                            ; Länge der geöffneten Datei ermitteln
                 
                *MemoryID = AllocateMemory(length)         ; Reservieren des benötigten Speichers
                If *MemoryID
                    
                    bytes = ReadData(DC::#TMPFile, *MemoryID, length)   ; Einlesen aller Daten in den Speicherblock
                    TextFile_XML_Catch(*MemoryID, bytes)
    
                EndIf
            EndIf  
            CloseFile(DC::#TMPFile)
        EndIf
        ProcedureReturn 0
    EndProcedure    
   ;**************************************************************************************************************************************************************** 
   ; 
    Procedure.i TextFile_isExtension(szFile.s) 
        
        Select UCase( GetExtensionPart( szFile ) )
            Case "DOCX", "ODT"
                ProcedureReturn 1
            Case "XML" 
                TextFile_isXML(szFile)
                ProcedureReturn 2
            Case "URL"
                TextFile_isURL(szFile)
                ProcedureReturn 2
            Default
                ProcedureReturn 0
        EndSelect        
    EndProcedure     
   ;**************************************************************************************************************************************************************** 
   ; 
    Procedure.i TextFile_isPacked(szFile.s)
        
        UseZipPacker()  ; Öffnet die gepackte Datei
        
        Select TextFile_isExtension(szFile)
            Case 0: ProcedureReturn 0
            Case 2: ProcedureReturn 2
        EndSelect                         
            
        If OpenPack(DC::#TMPFile, szFile)         ; Listet alle Einträge auf
                    
            If ExaminePack(DC::#TMPFile)      
                
                While NextPackEntry(DC::#TMPFile)
                    
                    Debug "Document Content:"
                    Debug "       Filename    : " + PackEntryName(DC::#TMPFile)                  
                    Debug "       Uncompressed: " + Str(PackEntrySize(DC::#TMPFile, #PB_Packer_UncompressedSize))
                    
                    Select PackEntryName(DC::#TMPFile)
                        Case "word/document.xml", "content.xml"
                            
                            ; now uncompress file entry To memory
                            
                            *MemoryPack = AllocateMemory( PackEntrySize( DC::#TMPFile, #PB_Packer_UncompressedSize) )
                            
                            If ( *MemoryPack )                               
                                UncompressPackMemory(  DC::#TMPFile, *MemoryPack, MemorySize( *MemoryPack ))
                                ;PeekS( *MemoryPack,MemorySize( *MemoryPack ),#PB_UTF8)
                                
                                TextFile_XML_Catch(*MemoryPack,  MemorySize( *MemoryPack ))
                                
                                If ( Startup::*LHGameDB\InfoWindow\szXmlText )
                                    ClosePack(DC::#TMPFile)
                                    ProcedureReturn 1
                                EndIf    
                            EndIf                           
                            
                    EndSelect                                              
                Wend    
            EndIf        
            ClosePack(DC::#TMPFile)
        EndIf
        ProcedureReturn 0
    EndProcedure
   ;**************************************************************************************************************************************************************** 
   ;      
   Procedure  TextFile_GetFormat(szFile.s, EvntEditGadget = -1)
       
       If ( FileSize( szFile ) >= 4096 )
           
           Select UCase( GetExtensionPart( szFile ) )
                   
               Case "RTF", "DOC"         
                   If ( TextFile_isDOC(szFile) = 1 )
                       Select EvntEditGadget
                           Case DC::#Text_128: vFont::GetDB(3, DC::#Text_128)
                           Case DC::#Text_129: vFont::GetDB(4, DC::#Text_129)
                           Case DC::#Text_130: vFont::GetDB(5, DC::#Text_130)
                           Case DC::#Text_131: vFont::GetDB(6, DC::#Text_131)                           
                       EndSelect
                   EndIf
                   ;TextFile_isXML(szFile)
               Default
                   
           EndSelect 
       EndIf
       
   EndProcedure
EndModule    
; Rich Edit Shortcut Keys
; Rich edit controls support the following shortcut keys.
; 
; RICH EDIT SHORTCUT KEYS
; Keys	                Operations	                                Comments
; Shift+Backspace	    Generate a LRM/LRM on a bidi keyboard	    BiDi specific
; Ctrl+Tab	            Tab	
; Ctrl+Clear	        Select all	
; Ctrl+Number Pad 5	    Select all	
; Ctrl+A	            Select all	
; Ctrl+E	            Center alignment	
; Ctrl+J	            Justify alignment	
; Ctrl+R	            Right alignment	
; Ctrl+L	            Left alignment	
; Ctrl+C	            Copy	
; Ctrl+V	            Paste	
; Ctrl+X	            Cut	
; Ctrl+Z	            Undo	
; Ctrl+Y	            Redo	
; Ctrl+'+'              (Ctrl+Shift+'=')	Superscript	
; Ctrl+'='	            Subscript	
; Ctrl+1	            Line spacing = 1 line.	
; Ctrl+2	            Line spacing = 2 lines.	
; Ctrl+5    	        Line spacing = 1.5 lines.	
; Ctrl+'                (apostrophe)	Accent acute	            After pressing the short cut key, press the appropriate letter (for example a, e, or u).
;                                                                   This applies To English, French, German, Italian, And Spanish keyboards only.
; Ctrl+` (grave)	    Accent grave	                            See Ctrl+' comments.
; Ctrl+~ (tilde)	    Accent tilde	                            See Ctrl+' comments.
; Ctrl+; (semicolon)	Accent umlaut	                            See Ctrl+' comments.
; Ctrl+Shift+6	        Accent caret (circumflex)	                See Ctrl+' comments.
; Ctrl+, (comma)	    Accent cedilla	                            See Ctrl+' comments.
; Ctrl+Shift+'          (apostrophe)	Activate smart quotes	
; Backspace	            If text is Protected, beep And do Not delete it. Otherwise, delete previous character.	
; Ctrl+Backspace	    Delete previous word. This generates a VK_F16 code.	
; F16	                Same As Backspace.	
; Ctrl+Insert	        Copy	
; Shift+Insert	        Paste	
; Insert	            Overwrite	DBCS does Not overwrite.
; Ctrl+Left Arrow	    Move cursor one word To the left.	On bidi keyboard, this depends on the direction of the text.
; Ctrl+Right Arrow	    Move cursor one word To the right.	See Ctrl+Left Arrow comments.
; Ctrl+Left Shift	    Left alignment	IN BiDi documents, this is For left-To-right reading order.
; Ctrl+Right Shift	    Right alignment	IN BiDi documents, this is For right-To-left reading order.
; Ctrl+Up               Arrow	Move To the line above.	
; Ctrl+Down Arrow	    Move To the line below.	
; Ctrl+Home	            Move To the beginning of the document.	
; Ctrl+End	            Move To the End of the document.	
; Ctrl+Page Up	        Move one page up.	If IN SystemEditMode And Single Line control, do nothing.
; Ctrl+Page Down	    Move one page down.	See Ctrl+Page Up comments.
; Ctrl+Delete	        Delete the Next word Or selected characters.	
; Shift+Delete	        Cut the selected characters.	
; ESC	                Stop drag-drop.	While doing a drag-drop of text.
; Alt+ESC	            Change the active application.	
; Alt+X	                Converts the Unicode hexadecimal value preceding the insertion point To the corresponding Unicode character.	
; Alt+Shift+X	        Converts the Unicode character preceding the insertion point To the corresponding Unicode hexadecimal value.	
; Alt+0xxx (Number Pad)	Inserts Unicode values If xxx is greater than 255. When xxx is less than 256, ASCI range text is inserted based on the current keyboard.	Must ENTER decimal values.
; Alt+Shift+Ctrl+F12	Hex To Unicode.	IN Case Alt+X is already taken For another use.
; Alt+Shift+Ctrl+F11	Selected text will be output To the debugger window And saved To %temp%\DumpFontInfo.txt.	For Debug only (need To set Flag=8 IN Win.ini)
; Ctrl+Shift+A	        Set all caps.	
; Ctrl+Shift+L	        Fiddle bullet style.	
; Ctrl+Shift+Right Arrow	Increase font size.	Font size changes by 1 point IN the range 4pt-11pt; by 2points for 12pt-28pt; it changes from 28pt -> 36pt -> 48pt -> 72pt -> 80pt; it changes by 10 points in the range 80pt - 1630pt; the maximum value is 1638.
; Ctrl+Shift+Left Arrow	Decrease font size.	See Ctrl+Shift+Right Arrow comments.
; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 188
; FirstLine = 140
; Folding = -bB+45f+-H-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = Release\