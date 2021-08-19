; CopyFilesEx
; Version 2.0
; Author: Thomas (ts-soft) Schulz
; erstellt: 27.04.2010
; zuletzt geändert: 04.03.2014
; PB-Version: 5.20 und höher
; Crossplattform

DeclareModule CopyFilesEx
    
    CompilerIf Not #PB_Compiler_Thread
        CompilerError "CopyFilesEx requires ThreadSafe Compileroption!"
    CompilerEndIf
    
    Prototype.i CopyFileExCallback(File.s, Dir.s, Sum.f, Procent.f, Current.q, Total.q)
    ; File erhält den Namen der aktuellen Datei
    ; Dir erhält den Namen des Zielverzeichnisses
    ; Sum ist der Gesamtforschritt in Prozent
    ; Procent ist der Fortschritt der aktuellen Datei
    
    ; Wenn das Callback #FALSE zurückgibt, wird der Kopiervorgang beendet, anderenfalls fortgesetzt
    
    
    Structure CopyFilesEx
        List sourcefiles.s()  ; Liste der zu kopierenden Dateien (mit Pfad)
        destinationDir.s      ; Zielverzeichnis
        bufferSize.i          ; der zu verwendente Buffersize beim kopieren der Dateien. Sollte auf #PB_Default gesetzt werden (entspricht 4096)
        callback.CopyFileExCallback ; ProcedureAdresse des Callbacks für den Fortschritt
        FinishEvent.i
        Mutex.i               ; das Ergebnis von CreateMutex()
        pStopVar.i            ; Adresse der globalen StopVariable
        IgnoreAttribute.b     ; auf #True gesetzt, werden Attribute nicht wieder hergestellt
        IgnoreDate.b          ; auf #True gesetzt, wird Dateidatum nicht wieder hergestellt
    EndStructure
    
    Enumeration 3300 Step 1
        #FinishEvent
    EndEnumeration

        EnumEnd =  3301
        EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
        Debug #TAB$ + "Constansts Enumeration : 3300 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: CopyFilesEx::(Module))"
        
    Declare CopyFilesEx(*CFE.CopyFilesEx)
    Define.i CopyFilesMutex = CreateMutex()
    Global CopyFilesStop.i
EndDeclareModule

Module CopyFilesEx
                
   ;**************************************************************************************************
   ;
   ; 
   ;         
    ; interne Funktion
    Procedure.q CopyFileBuffer(sourceID.i, destID.i, buffersize.i)
        Protected *mem, result.q
        
        *mem = AllocateMemory(buffersize)
        
        If *mem And IsFile(sourceID) And IsFile(destID)
            If Loc(sourceID) + buffersize < Lof(sourceID)
                ReadData(sourceID, *mem, buffersize)
                WriteData(destID, *mem, buffersize)
                result = Loc(destID)
            Else
                buffersize = Lof(sourceID) - Loc(destID)
                If buffersize
                    ReadData(sourceID, *mem, buffersize)
                    WriteData(destID, *mem, buffersize)
                EndIf
                CloseFile(sourceID)
                CloseFile(destID)
                result = 0
            EndIf
            FreeMemory(*mem)
        EndIf
        
        ProcedureReturn result
    EndProcedure
   ;**************************************************************************************************
   ;
   ; 
   ;         
    Procedure.i CopyFilesEx(*CFE.CopyFilesEx)
        Protected sourceID.i, destID.i, bufferSize.i, position.q, Size.q, Procent.f, cFiles.i, Sum.f, count.i
        Protected Attribute.i, Date_Created.i, Date_Accessed.i, Date_Modified.i

        If *CFE\Mutex
            LockMutex(*CFE\Mutex)
        EndIf
        

        cFiles = ListSize(*CFE\sourcefiles())
        
        With *CFE
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
                If Right(\destinationDir, 1) <> "\" : \destinationDir + "\" : EndIf ; fehlende Slashes/Backslahes hinzufügen
            CompilerElse
                If Right(\destinationDir, 1) <> "/" : \destinationDir + "/" : EndIf
            CompilerEndIf
            If \bufferSize = #PB_Default : \bufferSize = 4096 : EndIf ; standardbuffer grösse
            If \bufferSize < 1028 : \bufferSize = 1028 : EndIf        ; empfohlene mindestgrösse setzen
        EndWith
        
        If FileSize(*CFE\destinationDir) = -2 ; Zielverzeichnis muß existieren
            ForEach *CFE\sourcefiles()
                With *CFE
                    
                    If FileSize(\sourcefiles()) >= 0 ; Dateien müssen existieren!
                        Attribute = GetFileAttributes(\sourcefiles())
                        Date_Created = GetFileDate(\sourcefiles(), #PB_Date_Created)
                        Date_Accessed = GetFileDate(\sourcefiles(), #PB_Date_Accessed)
                        Date_Modified = GetFileDate(\sourcefiles(), #PB_Date_Modified)
                        
                        sourceID = ReadFile(#PB_Any, \sourcefiles())
                        If IsFile(sourceID) = #False : Continue : EndIf ; lesen fehlgeschlagen, fortsetzen mit nächstem File.
                        FileBuffersSize(sourceID, \bufferSize)
                        Size = Lof(sourceID)
                        destID = CreateFile(#PB_Any, \destinationDir + GetFilePart(\sourcefiles()))
                        If IsFile(destID) = #False : CloseFile(sourceID) : Continue : EndIf ; erstellen fehlgeschlagen, fortsetzen mit nächstem File.
                        FileBuffersSize(destID, \bufferSize)
                        Sum = (100 * count) / cFiles
                        count + 1
                        
                        Repeat
                            position = CopyFileBuffer(sourceID, destID, \bufferSize)
                            Debug position
                            
                            If \callback <> 0
                                Procent = (100 * position) / Size
                                Debug Size
                                If Not \callback(GetFilePart(\sourcefiles()), \destinationDir, Sum, Procent,position,Size ) Or PeekI(\pStopVar) = #True ; abbrechen gewählt
                                    If IsFile(sourceID) : CloseFile(sourceID) : EndIf
                                    If IsFile(destID) : CloseFile(destID) : EndIf
                                    DeleteFile(\destinationDir + GetFilePart(\sourcefiles()))
                                    Break
                                EndIf
                                If position = 0
                                    \callback("", "", 100, 0,0,0)
                                EndIf
                            EndIf
                        Until position = 0
                        
                        If Not \IgnoreAttribute
                            SetFileAttributes(\destinationDir + GetFilePart(\sourcefiles()), Attribute) ; Attribute wieder herstellen
                        EndIf
                        If Not \IgnoreDate
                            SetFileDate(\destinationDir + GetFilePart(\sourcefiles()), #PB_Date_Created, Date_Created)
                            SetFileDate(\destinationDir + GetFilePart(\sourcefiles()), #PB_Date_Accessed, Date_Accessed)
                            SetFileDate(\destinationDir + GetFilePart(\sourcefiles()), #PB_Date_Modified, Date_Modified)
                        EndIf
                        DeleteElement(\sourcefiles()) ; erfolgreich kopierte Dateien aus der Liste entfernen um Überprüfung zu ermöglich z.B. bei Abbruch
                    EndIf
                    If PeekI(\pStopVar) : Break : EndIf     
                EndWith
            Next
        EndIf
        
        If *CFE\Mutex
            UnlockMutex(*CFE\Mutex)
        EndIf
        
        If *CFE\FinishEvent = 0
            *CFE\FinishEvent = #PB_Event_FirstCustomValue
        EndIf
        
        PostEvent(*CFE\FinishEvent)
        
    EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile
    
    
    
    Procedure FileCallback(File.s, Dir.s, Sum.f, Procent.f)
        Static tmpFile.s
        Static tmpDir.s
        
        Debug Int(Sum)
        Debug  Int(Procent)
        If tmpFile <> File And IsGadget(0)
            tmpFile = File
            SetGadgetText(0, "Copy File: " + File)
        EndIf
        If tmpDir <> Dir And IsGadget(1)
            tmpDir = Dir
            SetGadgetText(1, "To: " + Dir)
        EndIf
        If IsGadget(2)
            SetGadgetState(2, Int(Sum))
        EndIf
        If IsGadget(3)
            SetGadgetState(3, Int(Procent))
        EndIf
        If Stop
            ProcedureReturn #False
        EndIf
        ProcedureReturn #True
    EndProcedure
   ;**************************************************************************************************
   ;
    
    Procedure OpenProgress()
        OpenWindow(0, 0, 0, 400, 160, "Progress CopyFilesEx", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        TextGadget(0, 10, 10, 380, 30, "")
        TextGadget(1, 10, 40, 380, 30, "")
        ProgressBarGadget(2, 10, 65, 380, 20, 0, 100)
        ProgressBarGadget(3, 10, 95, 380, 20, 0, 100)
        ButtonGadget(4, 150, 125, 80, 30, "cancel")
    EndProcedure
    ;**************************************************************************************************
   ;   
    Enumeration #PB_Event_FirstCustomValue
        #FinishEvent
    EndEnumeration
   ;**************************************************************************************************
   ;    
    Define.s SPath = PathRequester("Bitte Verzeichnis der zu kopierenden Dateien wählen:", "")
    If SPath = "" : End : EndIf
    Define.s DPath = PathRequester("Bitte Zielordner wählen:", "")
    If DPath = "" : End : EndIf
   ;**************************************************************************************************
   ;    
    ;Define.i CopyFilesMutex = CreateMutex()
    Define.CopyFilesEx::CopyFilesEx CFE
   ;**************************************************************************************************
   ;    
    With CFE
        \destinationDir = DPath
        \Mutex = CopyFilesEx::CopyFilesMutex
        \bufferSize = #PB_Default
        \callback = @FileCallback()
        \FinishEvent = #FinishEvent
        \pStopVar =CopyFilesEx::@CopyFilesStop
        ;\IgnoreAttribute = #True
        ;\IgnoreDate = #True
        
        If ExamineDirectory(0, SPath, "")
            While NextDirectoryEntry(0)
                If DirectoryEntryType(0) = #PB_DirectoryEntry_File
                    AddElement(\sourcefiles())
                    \sourcefiles() = SPath + DirectoryEntryName(0)
                EndIf
            Wend
            FinishDirectory(0)
        EndIf
    EndWith
   ;**************************************************************************************************
   ;    
    OpenProgress()
    
    Define.i Thread = CreateThread(CopyFilesEx::@CopyFilesEx(), @CFE)
    
    Repeat
        Select WaitWindowEvent()
                
            Case #FinishEvent
                Break
            Case #PB_Event_CloseWindow
                Stop = #True
                WaitThread(Thread)
                Break
            Case #PB_Event_Gadget
                Select EventGadget()
                    Case 4
                        Stop = #True
                        WaitThread(Thread)
                        Break
                EndSelect
        EndSelect
    ForEver
    
    If ListSize(CFE\sourcefiles())
        Debug Str(ListSize(CFE\sourcefiles())) + " Dateien nicht kopiert!"
        ForEach CFE\sourcefiles()
            Debug CFE\sourcefiles()
        Next
    EndIf   
CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 38
; FirstLine = 3
; Folding = n-
; EnableAsm
; EnableUnicode
; EnableThread
; EnableXP