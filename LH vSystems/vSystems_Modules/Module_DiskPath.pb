DeclareModule vDiskPath
    
    Declare     ReConstrukt(nSlot.b, bUseBaseGameID.b)
    
EndDeclareModule

Module vDiskPath
    
    Structure RAWNAME
        s.s{#MAX_PATH}
    EndStructure
    
    Structure PATH_CONSTRUCT            
        nRows.i
        RowID.i
        nNFound.i                        ; Anzahl der Nicht gefundenen 
        nSucces.i                        ; Anzahl der gefundenen
        nDouble.i                        ; Anzahl der Gleichen
        szCol.s{#MAX_PATH}               ; Column Name wo der Pfad rausgeholt wird
        pszChoosed.s{#MAX_PATH}          ; Pfad der von User gewählt woren ist (Suchpfad)
        pszMediaDB.s{#MAX_PATH}          ; Pfad der aus der Datenbank geholt wurde (Slot)
        sPortedPathOld.s{#MAX_PATH}      ; Portable path (Alt)   
        sPortedPathNew.s{#MAX_PATH}      ; Portable path (Neu)         
        *Buffer.RAWNAME                  ; Hält den Pfad der gefunden wurde
        bBackSlash.b                     ; Prüft ob der Ursprüngliche Pfad am ende ein Backslash ("\") hat
        List pszNotFound.s()             ; Liste mit Pfaden die nicht gefunde wurden
        List pSplitParts.s()             ; Gesplittet Pathder aus der Datenbank kommt
        gMutex.i                          
        gThread.i
        bUseBaseGameID.i
        bKill.i
    EndStructure 
    
    Global sEntryName.s{#MAX_PATH} 
    Global MsgHook
    ;==========================================================================================================================================
    ;       
    Procedure.s GetSlot(szMediaFilePath.s, RowID.i)        
        ProcedureReturn ExecSQL::nRow(DC::#Database_001,"Gamebase",szMediaFilePath,"",RowID,"",1):           
    EndProcedure          
    ;==========================================================================================================================================
    ;        
    Procedure.b PathCompare(List szCompare.s(), szPathName.s )
        
        Protected  szNewPath.s, Count.i = 0
        
        ResetList( szCompare() ) 
                
        While NextElement( szCompare() )
            
            Count + 1
            Debug  "Vergleiche ("+RSet(Str(Count),2,"$0")+"): " + RSet(szPathName,30," ") + " = "+ szCompare()
            
            sEntryName = szPathName
            
            If ( LCase( szPathName) = LCase(szCompare() ) )                                    
                
                szNewPath + szCompare() 
                For nListElement = 1 To Count
                    Debug "Entferne   ("+RSet(Str(Count),2,"$0")+"): " + RSet(szCompare(),30," ")
                    DeleteElement( szCompare(),nListElement )
                Next    
                
                
                ;Debug ""
                ProcedureReturn #True
            EndIf                                                 
        Wend
        
        ProcedureReturn #False
    EndProcedure
    ;==========================================================================================================================================
    ;
    Procedure   Find_GetDirectory(*p.PATH_CONSTRUCT, Path.s, Compare.s, List szCompare.s(), *MemoryID.Rawname ,rekursiv.b = #True, bForce.b = #False)
        
        Protected dir.l, Size.q, szPname.s, szDateModifed.s, szDateCreated.s, szNewPath.s
        
        If ( *p\bKill = #True )
            *MemoryID\s = ""
            Debug ">> Breche ab"
            ProcedureReturn 
        EndIf    
        ;Check for Drive Letter and remove backslash
        If Len( Path ) = 3 And Right( Path, 1) = "\"
            Path = Left(Path, 2)
            PathCompare( szCompare(), Path )
        EndIf    
        
        Path = ReplaceString( Path, "\\", "\")
        
        If ( ListSize( szCompare() ) = 0 )
            If ( Path)
                If ( FileSize( Path ) = -2 ) Or ( FileSize( Path ) >= 1 )
                    If ( *MemoryID\s = "")
                        
                        *MemoryID\s = path 
                        ;Debug "Pfad im Speicher: " + *MemoryID\s
                        
                        rekursiv = #False
                        bForce   = #False
                    EndIf    
                EndIf    
            EndIf 
            
        Else
            dir = ExamineDirectory(#PB_Any, Path, "")
            
            If ( dir )
                
                While NextDirectoryEntry(dir)
                                         
                    szPname = DirectoryEntryName(dir)
                    
                    ;
                    ;===============================================================================
                    ;                    
                    If ( szPname = "." ) Or ( szPname = ".." )
                        Continue
                    ;
                    ;===============================================================================
                    ;                        
                    ElseIf DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory

                        If Not ( PathCompare( szCompare(), szPname ) = #False )                            
                            Find_GetDirectory(*p, Path + "\" + szPname + "\", Compare, szCompare(), *MemoryID, #False, bForce)                                                   
                        EndIf
                        If ( bForce = #True )
                            Find_GetDirectory(*p, Path + "\" + szPname + "\", Compare, szCompare(), *MemoryID, rekursiv, bForce) 
                        EndIf                           
                        
                    ;
                    ;===============================================================================
                    ;                        
                    ElseIf DirectoryEntryType(dir) = #PB_DirectoryEntry_File
                        
                        ; Dateiname = Ende der Fahnenstange                     
                        If Not ( PathCompare( szCompare(), szPname ) = #False )                                                                                               
                            Find_GetDirectory(*p, Path + "\" + szPname , Compare, szCompare(), *MemoryID, #False, bForce)  
                        EndIf                       
                    ;
                    ;===============================================================================
                    ;                        
                    ElseIf rekursiv                      
                        Find_GetDirectory(*p, Path + "\" + szPname +"\", Compare, szCompare(), *MemoryID, rekursiv, bForce)                
                    ;
                    ;===============================================================================
                    ;                        
                    EndIf
                Wend            
                FinishDirectory(dir)                  
            EndIf
        EndIf 
    EndProcedure 
    ;******************************************************************************************************************************************
    ;     
    Procedure   PathPartsExt_Backslash( List szCompare.s() )
        
        ResetList( szCompare() ) 
        
        While NextElement( szCompare() )
            If (Right( szCompare() ,1) = Chr( 92) )
                szCompare() = Left( szCompare(), Len( szCompare() ) -1 )
            EndIf                                                                                           
        Wend        
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;  
    Procedure   ModifyPath_CheckSlash(*p.PATH_CONSTRUCT)
        If ( *p\bBackSlash = #False ) And ( Right( *p\Buffer\s, 1) = Chr( 92) )
            ;
            ; Entferne den backslash
            *p\Buffer\s = Left(*p\Buffer\s, Len(*p\Buffer\s) -1 )
        EndIf        
    EndProcedure 
    ;******************************************************************************************************************************************
    ;  
    Procedure   ModifyPath_Success(*p.PATH_CONSTRUCT)
        
            Protected szNewSlot.s
        
            *p\nSucces + 1        

            Debug ""            
            Debug "("+ Str(*p\RowID) +") ["+*p\szCol+"] Portable Pfad : " + *p\sPortedPathNew
            Debug "("+ Str(*p\RowID) +") ["+*p\szCol+"] Voller Pfad   : " + *p\Buffer\s
            
            ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", *p\szCol,  *p\sPortedPathNew , *p\RowID)  
            
    EndProcedure
    ;******************************************************************************************************************************************
    ;  
    Procedure.i ModifyPath_Doubles(*p.PATH_CONSTRUCT)
        
        *p\sPortedPathNew = vEngine::Getfile_Portbale_Modein( *p\Buffer\s ) 
        
        Debug ""
        Debug "Gleiche Dateien ?"
        Debug "Alt : "+ *p\sPortedPathOld 
        Debug "Neu : "+ *p\sPortedPathNew
                       
        If ( LCase( *p\sPortedPathOld ) = LCase( *p\sPortedPathNew ) )
             *p\nDouble + 1       
             ProcedureReturn #True
         EndIf
         ProcedureReturn #False
    EndProcedure        
    ;******************************************************************************************************************************************
    ;  
    Procedure   ModifyPath_NotFound(*p.PATH_CONSTRUCT)
        Protected szTitle.s
        
        With *p
        \nNFound + 1
        
        AddElement( \pszNotFound() )
        szTitle = ExecSQL::nRow(DC::#Database_001,"Gamebase","GameTitle","",*p\RowID,"",1)  
        If ( szTitle = "" )
            szTitle = "Eintrag Gelöscht!?"
        EndIf                
        \pszNotFound() = szTitle + #CR$ + *p\pszMediaDB + #CR$
        
        EndWith
    EndProcedure
    ;******************************************************************************************************************************************
    ;      
    Procedure   ModifyPath_RemDrive(*p.PATH_CONSTRUCT)
        ResetList( *p\pSplitParts() )
        
;         Debug ListSize( *p\pSplitParts() )
        
        While NextElement( *p\pSplitParts() )
                                    
            If ( Len( *p\pSplitParts() ) = 2 And Right( *p\pSplitParts() ,1) = ":" )
                
                DeleteElement( *p\pSplitParts() )
                Break;
            EndIf    
        Wend       
;         Debug ListSize( *p\pSplitParts() )
        
        ResetList( *p\pSplitParts() )
;         While NextElement( *p\pSplitParts() )
;             
;             If ( Len( *p\pSplitParts() ) = 2 And Right( *p\pSplitParts() ,1) = ":" )
;                 
;                 Debug *p\pSplitParts() 
;                 ;Break;
;             EndIf    
;         Wend          
    EndProcedure
    ;******************************************************************************************************************************************
    ;  
    Procedure.l ModifyPath_Thread(*p.PATH_CONSTRUCT)
        
        Protected Rows.i  = *p\nRows, RowID.i, szFilePath.s, NewList *p\pszNotFound(), RowID_Start.i = 1
        
        sEntryName = ""
        
        If ( *p\bUseBaseGameID = #True )
            RowID_Start = Startup::*LHGameDB\GameID
        EndIf    
        
        For RowID = RowID_Start To Rows                        
            
            LockMutex( *p\gMutex )
                        
            ;NextElement(ExecSQL::_IOSQL())   
            *p\RowID      = RowID
            
            *p\sPortedPathOld = GetSlot(*p\szCol ,*p\RowID )
            
            If ( *p\sPortedPathOld )   
                *p\pszMediaDB = vEngine::Getfile_Portbale_ModeOut(*p\sPortedPathOld) 
                ;
                ;---------------------------------------------------------------------------
                ;
                NewList *p\pSplitParts()
               
                    FFH::PathPartsExt(*p\pszMediaDB, *p\pSplitParts() )
                    PathPartsExt_Backslash( *p\pSplitParts() )
                    ModifyPath_RemDrive(*p)   
                ;
                ;---------------------------------------------------------------------------
                ;                        
                If (Right( *p\pszMediaDB ,1) = Chr( 92) )
                    *p\bBackSlash = #True
                Else                
                    *p\bBackSlash = #False                   
                EndIf                          
                ;
                ;---------------------------------------------------------------------------
                ;                               
                *p\Buffer = AllocateMemory( SizeOf(RAWNAME) )
                
                If ( *p\bKill = #False ) 
                    Find_GetDirectory(*p, *p\pszChoosed , *p\pszMediaDB, *p\pSplitParts() , *p\Buffer)
                    If ( *p\bKill = #True )                       
                        Break
                    EndIf               
                    If ( *p\Buffer\s )
                        
                        ModifyPath_CheckSlash(*p)
                        
                        If ( ModifyPath_Doubles(*p) = #False )                         
                            ModifyPath_Success   (*p)
                        EndIf
                        
                    Else                    
                        ; Versuche es mit Force
                        FreeMemory( *p\Buffer ): *p\Buffer = AllocateMemory( SizeOf(RAWNAME) )
                        
                        If ( *p\bKill = #False )  
                            Find_GetDirectory(*p, *p\pszChoosed , *p\pszMediaDB, *p\pSplitParts() , *p\Buffer,#True,#True)
                            If ( *p\Buffer\s )           
                                ModifyPath_CheckSlash(*p)
                                If ( ModifyPath_Doubles(*p) = #False )
                                    ModifyPath_Success   (*p)
                                EndIf
                            Else                                                
                                ModifyPath_NotFound(*p)                      
                            EndIf                             
                        EndIf  
                    EndIf
                EndIf
                
                ClearList( *p\pSplitParts()): FreeList( *p\pSplitParts() )
                
                FreeMemory( *p\Buffer )
                ;
                ;---------------------------------------------------------------------------
                ;                       
                If ( *p\bKill = #True )                       
                    Break
                EndIf                  
            EndIf 
            UnlockMutex( *p\gMutex )
    
        Next
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;     
    Procedure   ModifyPath_EndInfo(*p.PATH_CONSTRUCT, szSlot.s)                                                       
            MessageText$ = ""
            If ( *p\bKill = #True )
                 MessageText$ + "Aktion abgebrochen"
                 Request::MSG(Startup::*LHGameDB\TitleVersion, "Pfad Info" ,MessageText$, 2, 1, ProgramFilename(), 0, 0,DC::#_Window_001)     
                 ProcedureReturn 
            EndIf     
            
            
            If ( *p\nNFound = 0 And *p\nDouble = 0 And *p\nSucces = 0)
                Select szSlot.s
                    Case "MediaDev0": szSlot.s = "1"
                    Case "MediaDev1": szSlot.s = "2"                
                    Case "MediaDev2": szSlot.s = "3"                
                    Case "MediaDev3": szSlot.s = "4"                
                EndSelect                   
                MessageText$ = ""
                MessageText$ + "Nichts zu tun .. Keine Pfade im Verzeichnis/Datei Slot " + szSlot
            EndIf    
            
            If ( *p\nNFound >= 1 )
                
                If FileSize( Startup::*LHGameDB\PortablePath + "vSystem-FehlerPfad.log" ) >= 1
                    DeleteFile( Startup::*LHGameDB\PortablePath + "vSystem-FehlerPfad.log" )
                EndIf
                
                fLog = OpenFile(#PB_Any, Startup::*LHGameDB\PortablePath + "vSystem-FehlerPfad.log")
                If ( fLog )
                    
                    If ( ListSize( *p\pszNotFound() ) > 0 )
                        ResetList(*p\pszNotFound() )
                        
                        While NextElement( *p\pszNotFound() )
                            WriteStringN(fLog, *p\pszNotFound() )
                            
                        Wend    
                    EndIf
                    CloseFile(fLog)                    
                EndIf  
                
                If ( *p\nNFound = 1 )
                    MessageText$ + Str( *p\nNFound ) + " Pfad von " + Str( ExecSQL::CountRows(DC::#Database_001,"Gamebase")  ) +" wurde nicht gefunden." + #CR$
                    
                    If *p\nNFound >= 1 And *p\nNFound <= 20
                        ResetList(*p\pszNotFound() )
                        While NextElement( *p\pszNotFound() )                         
                            MessageText$ + *p\pszNotFound() + #CR$
                        Wend    
                    EndIf    
                Else 
                    MessageText$ + Str( *p\nNFound ) + " von " + Str( *p\nRows  ) +" Pfaden wurden nicht gefunden." + #CR$
                EndIf
                
                MessageText$ + "Log Datei wurde angelegt" + #CR$ + Startup::*LHGameDB\PortablePath + "vSystem-FehlerPfad.log" + #CR$     
                
                ;ClearList( *p\pszNotFound() ): FreeList( *p\pszNotFound() )                     
            EndIf    
            
            If ( *p\nSucces >= 1 )
                
                If ( *p\nSucces = 1 )
                    MessageText$ + Str( *p\nSucces ) + " Pfad von " + Str( ExecSQL::CountRows(DC::#Database_001,"Gamebase")  ) +" wurde erfolgreich korrigiert."+ #CR$                    
                Else
                    MessageText$ + Str( *p\nSucces ) + " von " + Str( *p\nRows  ) +" Pfaden wurden erfolgreich korrigiert" + #CR$                   
                EndIf
                
            EndIf                       
            
            If ( *p\nDouble >= 1 )               
                If ( *p\nDouble = 1 )
                    MessageText$ + Str( *p\nDouble ) + " Pfad wurde nicht geändert und ist gleich."+ #CR$
                Else
                    MessageText$ + Str( *p\nDouble ) + " Pfade wurden nicht geändert und sind gleich" + #CR$                    
                EndIf    
                
            EndIf                        
            
            If ( *p\nNFound >= 1 )
                  Request::*MsgEx\User_BtnTextL = "Ok"
                  Request::*MsgEx\User_BtnTextR = "Log Öffnen"
                  r = Request::MSG(Startup::*LHGameDB\TitleVersion, "Pfad Info" ,MessageText$, 10, 2, ProgramFilename(), 0, 0,DC::#_Window_001)                    
                  If ( r = 1 )
                      FFH::ShellExec( Startup::*LHGameDB\PortablePath + "vSystem-FehlerPfad.log","open")
                  EndIf    
            Else
                Request::MSG(Startup::*LHGameDB\TitleVersion, "Pfad Info" ,MessageText$, 2, 0, ProgramFilename(), 0, 0,DC::#_Window_001)           
            EndIf    
            
            
                    
    EndProcedure
    ;******************************************************************************************************************************************
    ;          
     Procedure  ModifyPath_ShowInfo(*p.PATH_CONSTRUCT)
         
         If ( *p\bKill = #True )
             sEntryName = "Bitte Warten. Beende .."
         EndIf
         
         SetGadgetText(DC::#Text_004,"Suche: " + 
                                     RSet( Str(*p\RowID)  ,  4, "0") + "/" + 
                                     RSet( Str(*p\nRows)  ,  4, "0") +" | Gefunden: "+ 
                                     RSet( Str(*p\nSucces),  4, " ") +" | Gleiche :" +
                                     RSet( Str(*p\nDouble),  4, " ") +" | Nicht Gefunden:" +
                                     RSet( Str(*p\nNFound),  4, " ") + "|" + " " + sEntryName )
         
;          Debug                       "Suche: " + 
;                                      RSet( Str(*p\RowID)  ,  4, "0") + "/" + 
;                                      RSet( Str(*p\nRows)  ,  4, "0") +" | Gefunden: "+ 
;                                      RSet( Str(*p\nSucces),  4, " ") +" | Gleiche :" +
;                                      RSet( Str(*p\nDouble),  4, " ") +" | Nicht Gefunden:" +
;                                      RSet( Str(*p\nNFound),  4, " ") + "|" + " " + sEntryName         
     EndProcedure    
    ;******************************************************************************************************************************************
    ;             
     Procedure  Switch_Buttons(bState.b)    
         SetActiveGadget( DC::#ListIcon_001)
         
         ButtonEX::Disable(DC::#Button_010, bState)
         ButtonEX::Disable(DC::#Button_011, bState)
         ButtonEX::Disable(DC::#Button_012, bState)
         ButtonEX::Disable(DC::#Button_013, bState)                            
         ButtonEX::Disable(DC::#Button_014, bState)            
         ButtonEX::Disable(DC::#Button_016, bState)
             
     EndProcedure
     
    ;
    ; Notify Hook
    ;        
    Procedure.l NotifyHook(lMsg.l, wParam.l, lParam.l)
        If lMsg = #HCBT_ACTIVATE
            SetWindowText_ (GetDlgItem_(wParam, #IDOK),  "Weiter ..")
            SetWindowText_ (GetDlgItem_(wParam, #IDCANCEL),  "Abbrechen")
            UnhookWindowsHookEx_ (MsgHook)
        EndIf
    EndProcedure     
    ;
    ; Notify Requester Message
    ;      
    Procedure   ModifyPath_Abort()
        Protected MsgReply.l, szPakName.s
        
        ;Have to call this is we havent already created a window
        InitCommonControls_()   
        
        MsgHook = SetWindowsHookEx_(#WH_CBT, @NotifyHook(), GetModuleHandle_(0), GetCurrentThreadId_())         
               
            MsgReply.l = MessageBox_(#HWND_DESKTOP, "Pfad Überprüfung und Wiederherstellung abbrechen ?", Startup::*LHGameDB\TitleVersion, #MB_OKCANCEL + #MB_ICONINFORMATION)
        
            Select MsgReply
                Case #IDOK    : ProcedureReturn #False
                Case #IDCANCEL: ProcedureReturn #True 
            EndSelect              
            
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  
    Procedure   ModifyPath_Loop(szSlot.s, bUseBaseGameID.b)        
        Protected bInfoOpen.b = #False, nCurrentItem.i, szLpPath.s
        
        If IsWindow( DC::#_Window_006)
            bInfoOpen = #True
            ButtonEX::SetState(DC::#Button_016,0):
            vInfo::Modify_EndCheck()
            vInfo::Modify_Reset()
            vInfo::Window_Props_Save()   
            vInfo::Window_Close()
        EndIf
        
        nCurrentItem = GetGadgetState( DC::#ListIcon_001 )
        
        Switch_Buttons(#True)

        *p.PATH_CONSTRUCT    
        *p = AllocateMemory( SizeOf(PATH_CONSTRUCT) )                   
        
        If Not ( Startup::*LHGameDB\InfoWindow\szlastPath = "")
            szLpPath = Startup::*LHGameDB\InfoWindow\szlastPath
            
            If      ( FileSize( szLpPath ) = -2 )                
            ElseIf  ( FileSize( szLpPath ) > 0  )  
                szLpPath = GetPathPart( szLpPath )
            Else
                szLpPath = ""
            EndIf
        EndIf    
                        
        *p\pszChoosed = PathRequester("Ordner/Laufwerk für die Suche wählen", szLpPath ) 
        
        
        ; Anzahl der Items in der DB Prüfen            
        *p\nRows        = ExecSQL::CountRows(DC::#Database_001,"Gamebase")
        
        *p\szCol        = szSlot        
        *p\bBackSlash   = #False
        *p\gThread      = 0
        *p\gMutex       = 0
        *p\bKill        = #False
        If ( *p\pszChoosed = "" )
             *p\nRows = 0
        EndIf        
        
        Startup::*LHGameDB\InfoWindow\szlastPath = *p\pszChoosed 
        
        Select ( *p\nRows )
            Case 0
                
            Default
                
                If ( bUseBaseGameID = #True )
                    ;
                    ; Damit wird nur der Aktuellen Eintrag bearbeitet
                    *p\nRows          = Startup::*LHGameDB\GameID
                    *p\bUseBaseGameID = #True
                    
                EndIf    
                
                ResetList(ExecSQL::_IOSQL()) 
                HideGadget(DC::#Text_004,0)
                
                
                *p\gMutex  = CreateMutex()
                *p\gThread = CreateThread( @ModifyPath_Thread(),*p )
                
                While IsThread( *p\gThread )   
                    Delay(5)                
                    While WindowEvent()
                        If Not ( GetGadgetState( DC::#ListIcon_001 ) = nCurrentItem )
                            SetGadgetState( DC::#ListIcon_001 ,nCurrentItem)
                        EndIf   
                        
                        If ( Form::IsOverObject( WindowID( DC::#_WINDOw_001 )) = 1 And GetActiveWindow() =  DC::#_WINDOw_001 And GetAsyncKeyState_(#VK_ESCAPE) )   
                                PauseThread( *p\gThread )
                            
                                *p\bKill = ModifyPath_Abort()
                                Delay(500)

                                ResumeThread(*p\gThread)                         
                        EndIf    
                     Wend
                    ModifyPath_ShowInfo(*p)
                    Delay(5)                    
                Wend 
                
                HideGadget(DC::#Text_004,1)                         
                SetGadgetText(DC::#Text_004,"")
                
                ModifyPath_EndInfo(*p, szSlot)

        EndSelect             
        
        FreeMemory(*p):
        
        Switch_Buttons(#False)
        
        If ( bInfoOpen = #True )
            ButtonEX::SetState(DC::#Button_016,1):
            vWindows::OpenWindow_EditInfos()   
        EndIf
        
        vEngine::Database_Get(Startup::*LHGameDB\GameID) 
    EndProcedure    
    ;******************************************************************************************************************************************
    ;     
    Procedure ReConstrukt(nSlot.b, bUseBaseGameID.b)              
        
        Select nSlot.b
            Case 1: szSlot.s = "MediaDev0"
            Case 2: szSlot.s = "MediaDev1"                
            Case 3: szSlot.s = "MediaDev2"                
            Case 4: szSlot.s = "MediaDev3"                
        EndSelect        
        
        ModifyPath_Loop(szSlot, bUseBaseGameID) 
    EndProcedure    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 581
; FirstLine = 125
; Folding = DAg-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; Debugger = IDE
; Warnings = Ignore