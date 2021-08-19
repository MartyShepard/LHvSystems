        
        Global Title.s, Version.s, dbSVN.s, Builddate.s, OldVersion.s
        
        XIncludeFile "vSystems_Modules\Module_Version.pb"
                
;        If ( MessageRequester( "Update", Title + " auf Version "+ Version +" ( "+ Builddate +" ) "+" Durchführen ?", #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes )
         If ( MessageRequester( "Update", Title + " Update Durchführen ?", #PB_MessageRequester_YesNo|#MB_ICONQUESTION) = #PB_MessageRequester_Yes )
                  
            Debug GetCurrentDirectory() 
            Event = #True
            Fext$ = "VUPDATE"
                                                
            If ExamineDirectory(0, GetCurrentDirectory() , "*." + Fext$)
                
                While NextDirectoryEntry(0)
                    
                    FileName$ = DirectoryEntryName(0)
                    Debug FileName$
                    If DirectoryEntryType(0) = #PB_DirectoryEntry_File
                        
                        FileExte$ = GetExtensionPart( FileName$ )
                        
                        If (FileExte$ = Fext$)
                            CurrentPath$ = GetCurrentDirectory()
                            CurrentFile$ = GetFilePart(FileName$, #PB_FileSystem_NoExtension )
                            OldFileName$ =  CurrentPath$+CurrentFile$+".exe"
                            
                            If FileSize( OldFileName$ ) > 0
                                                                                                                                
                                If OpenFile(1, OldFileName$ )
                                    
                                    CloseFile(1)
                                    Delay(255)
                                    
                                    DeleteFile( OldFileName$ )
                                    
                                    Delay(1000)                
                                    RenameFile( GetCurrentDirectory()+FileName$, CurrentPath$ + CurrentFile$ +".exe")                      
                                    Delay(1000)
                                    MessageRequester( "Update", "Update Durchgeführt", #MB_ICONINFORMATION)
                                    RunProgram( urrentPath$+CurrentFile$+".exe" )
                                    
                                    End
                                EndIf    
                            EndIf
                            
                        EndIf
                    EndIf
                Wend                
            Else
                MessageRequester( "Update Fehler", "Update Fehlgeschlagen", #MB_ICONSTOP)
            EndIf
        EndIf
        
        End 
        
        
;         ;Darstellung der Möglichkeiten von Messagerequester;             ;Läuft nur unter Windows!
;             ;Es wären noch weitere Dinge möglich, nur sind die weniger wichtig
;             ;und sind teilweise in meinem PB 4.20 auch noch nicht vordefiniert.
;         
;             Debug "Button Kombinationen"
;             Debug #MB_OK
;             Debug #MB_OKCANCEL
;             Debug #MB_ABORTRETRYIGNORE
;             Debug #MB_YESNOCANCEL
;             Debug #MB_YESNO
;             Debug #MB_RETRYCANCEL
;             Debug "Icon + Signal"
;             Debug #MB_ICONSTOP
;             Debug #MB_ICONQUESTION
;             Debug #MB_ICONWARNING
;             Debug #MB_ICONINFORMATION
;             Debug 80 ; No Signal - Nicht dokumentiert!
;             Debug "Vorbelegte Tasten"
;             Debug #MB_DEFBUTTON1
;             Debug #MB_DEFBUTTON2
;             Debug #MB_DEFBUTTON3
;             Debug "Rückgabewerte"
;             Debug #IDOK
;             Debug #IDCANCEL
;             Debug #IDABORT
;             Debug #IDRETRY
;             Debug #IDIGNORE
;             Debug #IDYES
;             Debug #IDNO
;             Debug " "
;             For c.l = 0 To 512 Step 256    ;Vorbelegte Tasten
;               For b.l = 0 To 80 Step 16   ;Icon + Signal
;                 For a.l = 0 To 5           ;Button Kombinationen
;                  
;                   d.l = a|b|c
;                  
;                   e.l = MessageRequester("Fenstertitel","Type: "+ Str(d & 15)+" "+Str(d & 240)+" "+Str(d & 768),d)
;                  
;                   Select e
;                     Case #IDABORT
;                       Debug "IDABORT"
;                     Case #IDCANCEL
;                       Debug "IDCANCEL"
;                     Case #IDIGNORE
;                       Debug "IDIGNORE"
;                     Case #IDNO
;                       Debug "IDNO"
;                     Case #IDOK
;                       Debug "IDOK"
;                     Case #IDRETRY
;                       Debug "IDRETRY"
;                     Case #IDYES
;                       Debug "IDYES"
;                   EndSelect
;                 Next
;               Next
;             Next
;             
;             
;         Ergebnis.l = MessageRequester("Fenstertitel","Text", #MB_YESNOCANCEL | 80 )
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 50
; EnableAsm
; EnableXP
; Executable = vSystems_Modules\Update_Modul\_UpdateModul_.exe
; CurrentDirectory = Release\