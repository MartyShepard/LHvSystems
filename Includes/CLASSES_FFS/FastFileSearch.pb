CompilerIf #PB_Compiler_IsMainFile
    
    UsePNGImageDecoder()
    
    XIncludeFile "_TEMPLATE\Constants.pb" 
    XIncludeFile "_TEMPLATE\ConstantsFonts.pb"     
    XIncludeFile "Class_Process.pb"
    XIncludeFile "Class_Win_Form.pb"
    XIncludeFile "Class_Win_Style.pb"
    XIncludeFile "Class_Win_Desk.pb"    
    XIncludeFile "Class_Tooltip.pb"
    XIncludeFile "ClassEX_Button.pb"    
    XIncludeFile "ClassEX_Dialog.pb" 
    XIncludeFile "Class_FastFileHandle.pb" 
    
CompilerEndIf    
DeclareModule FFS
    
    
    
    ;################################################################################################################ 
    ;                                                                                             GetDirectoryContent                   
    Structure FILE_ITEM_COUNT
        Files.l
        Dirs.l
    EndStructure
    
    Structure FILE_NAME
        FileIndexID.l
        FileName.s
        Attributes.s
        DateCreated.s
        DateAccessed.s
        DateModified.s
    EndStructure
    
    Structure DIRECTORY_NAME
        FileIndexID.l
        FileName.s
        Attributes.s
        DateCreated.s
        DateAccessed.s
        DateModified.s
    EndStructure 
    
    
    Global NewList FullFileSource.FILE_NAME()                          ; Alle gefundenen Dateien mit kompletten Pfad
    Global NewList FullDirectorySource.DIRECTORY_NAME()                ; und hier alle Ordner
    Global FileCount.FILE_ITEM_COUNT
    Global FFS_Thread.i = 0
    Global FFS_ThreadOnPause.i = #False   
    
    Declare SortContent() 
    Declare DelContent()
    Declare GetContent(iDirectory$, IncludeDirectorys = #True, IncludeFiles = #True, IncludeSubDirectorys = #True,SetFormatDate$ = "", FilePattern$ = "*.*",DirectoryDepth.i = 0,DisplayGui.i = #False, DisplayTime.i = 100 ,iSearching$ = "", Hashstring$ = "")
    Declare.i SizeContent(FileList=#True,FolderList=#False)
EndDeclareModule

Module FFS    
    
    Enumeration 4721 Step 1
        #_NotifyWindow
        #_Notify_Image
        #_NotifyCanvas
        #_Notify__Icon
        #_NotifyString1
        #_NotifyString2
        #_NotifyString3
    EndEnumeration
    
    Structure FILESEARCH_System
        iDirectory.s{4096}
        IncludeDirectorys.l        
        IncludeFiles.l
        IncludeSubDirectorys.i
        SetFormatDate.s{255}
        FilePattern.s
        DirectoryDepth.i
        DisplayGui.i
        DisplayTime.i
        Time_Current.i
        Searching$
        
    EndStructure
    
    DataSection                
        Notifiy01:
        IncludeBinary "FastFileSearch_IMG\FastFileBox.png"
    EndDataSection
    Result = CatchImage(#_Notify_Image, ?Notifiy01)
    
    
    Global UserFilePattern$ = ""
    Global Chr92 = 0
    Global Chr92_Orig = 0
    Global CurrentFile$
    
    
    ;--------------------------------------------------------------------------------------------------------------------------------
    ; OpenWindow
    ;________________________________________________________________________________________________________________________________     
    Procedure OpenToolTip_Window(x = 0, y = 0, width = 284, height = 101)
        If (width = 0 And height = 0)
            OpenWindow(#_NotifyWindow, x, y, 440, 300, "",#PB_Window_BorderLess|#PB_Window_Invisible|#PB_Window_ScreenCentered)
            
        Else    
            OpenWindow(#_NotifyWindow, x, y, width, height, "",#PB_Window_BorderLess|#PB_Window_Invisible)
        EndIf
    EndProcedure  
    
    ;---------------------------------------------------------------------------------------------------------------------------------------------------------------
    ; Erstellung der GuiObjecte für SaveGames
    ;________________________________________________________________________________________________________________________________ 
    Procedure ToolWindow_GuiObjects_1(ChangedX,ChangedY,WindowsX,ToolGameIcon$)
        
        OpenToolTip_Window(ChangedX,ChangedY) 
        
        CanvasGadget(#_NotifyCanvas,0, 0, 284, 101)    
        StartDrawing(CanvasOutput(#_NotifyCanvas)): DrawImage(ImageID(#_Notify_Image), 0, 0): StopDrawing()
        DisableGadget(#_NotifyCanvas, #True) 
        
        ButtonImageGadget(#_Notify__Icon, 9, 3, 40, 40, 0)
        SetGadgetAttribute(#_Notify__Icon,#PB_Button_Image ,ExtractIcon_(0,ToolGameIcon$,0))
        
        TextGadget(#_NotifyString1, 60, 11, 200, 13, "Please Wait", #PB_Text_Center)
        SetGadgetFont(#_NotifyString1, FontID(Fonts::#_FIXPLAIN7_12))
        SetGadgetColor(#_NotifyString1, #PB_Gadget_BackColor,RGBA(71, 71, 71,0)):   SetGadgetColor(#_NotifyString1, #PB_Gadget_FrontColor,RGBA(255, 255, 255, 0));                                        
        
        TextGadget(#_NotifyString2, 12, 45, 220, 16, "")
        SetGadgetFont(#_NotifyString2, FontID(Fonts::#_SEGOEUI10N))
        SetGadgetColor(#_NotifyString2, #PB_Gadget_BackColor,RGBA(226, 226, 227,0)): SetGadgetColor(#_NotifyString2, #PB_Gadget_FrontColor,RGBA(0, 0, 0, 0));   
        
        TextGadget(#_NotifyString3, 12, 71, 262, 14, "",#SS_LEFTNOWORDWRAP)
        SetGadgetFont(#_NotifyString3, FontID(Fonts::#_SEGOEUI10N)) 
        SetGadgetColor(#_NotifyString3, #PB_Gadget_BackColor,RGBA(71, 71, 71,0)):SetGadgetColor(#_NotifyString3, #PB_Gadget_FrontColor,RGBA(255, 255, 255, 0)); 
                                                                                                                                                              ;         
                                                                                                                                                              ;         ProgressBarGadget(DC::#_PROGRESS_01,10, 76, WindowsX-20,  15, 1, Progress_iMax_Files.l, #PB_ProgressBar_Smooth)
    EndProcedure  
    
    ;--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ; Category : 0 = Nichts/ 1 = SaveGames                                                             Haupt Aufruf
    ;________________________________________________________________________________________________________________________________ 
    Procedure NotifiyWindow(ToolGameIcon$)
        
        Protected Primary_ScreenX, Primary_ScreenY, iTaskLeiste.l, ChangedX, ChangedY ,ToolWindowID.l, TB_TaskBar,TB___Start            
        
        If Len(ToolGameIcon$) = 0
            ToolGameIcon$ = ProgramFilename()
        EndIf
        
        If Transparenz.l < 1: Transparenz.l = 220: EndIf
        
        SystemParametersInfo_(#SPI_GETWORKAREA,0,@DesktopWorkArea.RECT,0)
        
        Primary_ScreenX = GetSystemMetrics_(#SM_CXSCREEN)
        
        ProcessEX::TaskListCreate(): iTaskLeiste.l = ProcessEX::TaskListGetPID("explorer.exe")
        If (iTaskLeiste.l <> 0)          
            Primary_ScreenY = GetSystemMetrics_(#SM_CYSCREEN)-DesktopWorkArea\Bottom
            Primary_ScreenY = GetSystemMetrics_(#SM_CYSCREEN)-Primary_ScreenY
            
            TB_TaskBar = FindWindow_("Shell_TrayWnd",0)
            TB___Start = FindWindow_(0,"Start")
            
            If Not (IsWindowVisible_(TB_TaskBar))
                Primary_ScreenY = GetSystemMetrics_(#SM_CYSCREEN)         
            EndIf              
        Else
            Primary_ScreenY = GetSystemMetrics_(#SM_CYSCREEN) 
        EndIf    
        
        OpenToolTip_Window()
        WindowsX = WindowWidth(#_NotifyWindow): WindowsY = WindowHeight(#_NotifyWindow): CloseWindow(#_NotifyWindow)
        
        ChangedX = Primary_ScreenX-WindowsX-6: ChangedY = Primary_ScreenY-WindowsY-6  
        ToolWindow_GuiObjects_1(ChangedX,ChangedY,WindowsX,ToolGameIcon$)
        
        SetWindowLongPtr_(WindowID(#_NotifyWindow),#GWL_EXSTYLE,GetWindowLongPtr_(WindowID(#_NotifyWindow),#GWL_EXSTYLE) | #WS_EX_LAYERED)
        SetLayeredWindowAttributes_(WindowID(#_NotifyWindow), 0,  Transparenz, #LWA_ALPHA) 
    EndProcedure            
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   DelDirectoryContent
    ;   Hardlnks Directories ?
    ;
    
    #GetFileExInfoStandard = 0
    
    Procedure IsJuction_Directory(dirin.s)
        
        attribute.WIN32_FIND_DATA
        
        GetFileAttributesEx_(DirIn ,#GetFileExInfoStandard,@attribute)
        If  attribute\dwFileAttributes & #FILE_ATTRIBUTE_REPARSE_POINT
            ProcedureReturn #True
        Else
            ProcedureReturn #False
        EndIf
    EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   DelDirectoryContent
    ;   Sortiert die Dateien
    ;
    Procedure SortContent()
        iMax = ListSize(FullFileSource())
        If (iMax <> 0)
            SortStructuredList(FullFileSource(), #PB_Sort_Ascending, OffsetOf(FILE_NAME\FileName.s), #PB_String)      
        EndIf
        
        iMax = ListSize(FullDirectorySource())
        If (iMax <> 0)
            SortStructuredList(FullDirectorySource(), #PB_Sort_Ascending, OffsetOf(FILE_NAME\FileName.s), #PB_String) 
        EndIf           
    EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   DelDirectoryContent
    ;   Löscht den Inhalt der Datei Variablen
    ;
    Procedure DelContent()
        
        FileCount.FILE_ITEM_COUNT\Files = 0
        
        iMax = ListSize(FullFileSource())
        If (iMax <> 0)
            ClearList(FullFileSource())
            FileCount.FILE_ITEM_COUNT\Files = 0
        EndIf
        
        iMax = ListSize(FullDirectorySource())
        If (iMax <> 0)
            ClearList(FullDirectorySource())
            FileCount.FILE_ITEM_COUNT\Dirs = 0
        EndIf
        
        If Len(UserFilePattern$) <> 0
            UserFilePattern$ = ""
        EndIf
        
        Chr92 = 0: Chr92_Orig = 0
    EndProcedure
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   DelDirectoryContent
    ;   Datum Übersetzung
    ;            
    Procedure.i EntryDate(*FT.FILETIME)
        FileTimeToLocalFileTime_(*FT.FILETIME,FT2.FILETIME)
        FileTimeToSystemTime_(FT2,ST.SYSTEMTIME)
        ProcedureReturn Date(ST\wYear,ST\wMonth,ST\wDay,ST\wHour,ST\wMinute,ST\wSecond)
    EndProcedure
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   AttDirectoryContent
    ;   Fügt Alle Directorys und Dateien 'Special' der Liste hinzu
    ;
    Procedure AddDirectoryContent_Folder(FileName$,iResult,SetFormatDate$,nIndex.l)
        
        Protected iAttribute, iCreated, iAccessed, iModified
        Protected Folder.WIN32_FIND_DATA
        
        iResult = FindFirstFile_(FileName$+"\*", Folder)
        
        AddElement(FullDirectorySource())
        
        FullDirectorySource()\FileIndexID.l = nIndex.l
        FullDirectorySource()\FileName.s = FileName$
        
        FullDirectorySource()\Attributes.s = Str(GetFileAttributes(FileName$))
        
        FullDirectorySource()\DateCreated.s = FormatDate(SetFormatDate$, EntryDate(Folder\ftCreationTime))                   
        FullDirectorySource()\DateAccessed.s = FormatDate(SetFormatDate$, EntryDate(Folder\ftLastAccessTime))                   
        FullDirectorySource()\DateModified.s = FormatDate(SetFormatDate$, EntryDate(Folder\ftLastWriteTime)) 
        FindClose_(iResult)     
    EndProcedure
    
    Procedure AddDirectoryContent_Files(FileName$,iResult,SetFormatDate$,nIndex.l)
        
        Protected iAttribute, iCreated, iAccessed, iModified
        Protected FileHandle.WIN32_FIND_DATA
        
        iResult = FindFirstFile_(FileName$, FileHandle)
        
        AddElement(FullFileSource())
        FullFileSource()\FileIndexID.l = nIndex.l
        FullFileSource()\FileName.s = FileName$
        
        FullFileSource()\Attributes.s = Str(GetFileAttributes(FileName$))
        
        FullFileSource()\DateCreated.s = FormatDate(SetFormatDate$, EntryDate(FileHandle\ftCreationTime))                   
        FullFileSource()\DateAccessed.s = FormatDate(SetFormatDate$, EntryDate(FileHandle\ftLastAccessTime))                   
        FullFileSource()\DateModified.s = FormatDate(SetFormatDate$, EntryDate(FileHandle\ftLastWriteTime))    
        FindClose_(iResult)    
    EndProcedure
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   AttDirectoryContent
    ;   Thread is Pause
    ;
    Procedure _GetFileList_Continue()
        
        If IsThread(FFS_Thread.i) And FFS::FFS_ThreadOnPause.i = #True
            ResumeThread(FFS_Thread.i)
            FFS::FFS_ThreadOnPause.i = #False
        EndIf    
    EndProcedure    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   AttDirectoryContent
    ;   Thread File and Folder List
    ;
    Procedure _GetFileList(*Params.FILESEARCH_System)   
        
        Protected FileName$, Name$, iResult, Extension$, iExtension$
        Protected f.WIN32_FIND_DATA
        
        iDirectory$          = *Params\iDirectory
        IncludeDirectorys    = *Params\IncludeDirectorys
        IncludeFiles         = *Params\IncludeFiles 
        IncludeSubDirectorys = *Params\IncludeSubDirectorys
        SetFormatDate$       = *Params\SetFormatDate.s
        FilePattern$         = *Params\FilePattern.s
        DirectoryDepth       = *Params\DirectoryDepth
        
        If (*Params\Time_Current <= *Params\DisplayTime) And  (*Params\DisplayGui.i = #True)
            *Params\Time_Current =  *Params\Time_Current+1;: Debug *Params\Time_Current+1
        EndIf
        ;
        ;_____________________________________________________________________________________________________                
        If (*Params\Time_Current = *Params\DisplayTime) And  (*Params\DisplayGui.i = #True)
            HideWindow(#_NotifyWindow,0): SetForegroundWindow_(WindowID(#_NotifyWindow))
        EndIf
        ;
        ;_____________________________________________________________________________________________________                
        Select Chr92_Orig
            Case 0
                Chr92_Orig = CountString(iDirectory$,Chr(92))
            Default
        EndSelect
        ;
        ;_____________________________________________________________________________________________________
        Select Len(UserFilePattern$)
            Case 0
                UserFilePattern$ = FilePattern$
        EndSelect
        ;
        ;_____________________________________________________________________________________________________                
        If FindString(iDirectory$, "System Volume Information", 1) > 0
            ProcedureReturn 0
        EndIf
        ;
        ;_____________________________________________________________________________________________________                
        iResult = FindFirstFile_(iDirectory$+"*.*", f)
        Select iResult
            Case #INVALID_HANDLE_VALUE
                ProcedureReturn 0
            Default
        EndSelect
        ;
        ;_____________________________________________________________________________________________________               
        If iResult
            
            Select Len(SetFormatDate$)
                Case 0
                    SetFormatDate$ = "%dd/%mm/%yyyy"
                Default
            EndSelect
            
            While FindNextFile_(iResult, f)
                Delay(1)
                Name$ = PeekS(@f\cFileName[0]) 
                
                Select Name$
                    Case ".",".."
                    Default
                        
                        If (f\dwFileAttributes & #FILE_ATTRIBUTE_DIRECTORY) And (IncludeDirectorys = #True)
                            
                            FileName$ = iDirectory$+Name$+Chr(92)                           
                            
                            Chr92 = CountString(iDirectory$,Chr(92))
                            Chr92 = Chr92 - Chr92_Orig
                            
                            ;Debug FileName$
                            ;Debug "Depth "+Chr92+ " Stop: "+DirectoryDepth.i
                            
                            FileCount.FILE_ITEM_COUNT\Dirs = FileCount.FILE_ITEM_COUNT\Dirs+1       ; Debug FileName$
;                             Select FileCount.FILE_ITEM_COUNT\Dirs
;                                 Case 100
;                                     PauseThread(FFS::FFS_Thread.i): Debug "PauseThread In Dirs"
;                                     FFS::FFS_ThreadOnPause.i = #True
;                             EndSelect                            
                            AddDirectoryContent_Folder(FileName$,iResult,SetFormatDate$,FileCount.FILE_ITEM_COUNT\Dirs)
                            
                            ;Debug *Params\Time_Current
                            If (*Params\Time_Current >= *Params\DisplayTime) And (*Params\DisplayGui.i = #True)
                                SetGadgetText(#_NotifyString2,*Params\Searching$ ): Debug *Params\iDirectory
                                
                                FFH::CreateShortenedPath(#_NotifyString3,FileName$, #_NotifyWindow)
                            EndIf
                            
                            *Params\iDirectory          = FileName$
                            *Params\IncludeDirectorys   = IncludeDirectorys
                            *Params\IncludeFiles        = IncludeFiles
                            *Params\IncludeSubDirectorys= IncludeSubDirectorys
                            *Params\SetFormatDate.s     = SetFormatDate$
                            *Params\FilePattern.s       = FilePattern$
                            *Params\DirectoryDepth      = DirectoryDepth                                                                       
                            
                            Select DirectoryDepth.i
                                Case 0
                                    If (IncludeSubDirectorys = #True): _GetFileList(*Params): EndIf 
                                    
                                Case Chr92
                                    Chr92 = 0                                                                               
                                    
                                Case DirectoryDepth.i
                                    
                                    If DirectoryDepth.i >= Chr92
                                        
                                        If (IncludeSubDirectorys = #True)                                                
                                            _GetFileList(*Params)  
                                        EndIf
                                        
                                    EndIf                                        
                                Default                                                                                                                
                            EndSelect 
                            
                        Else
                            Extension_Collect = 0
                            If (IncludeFiles = #True)
                                
                                
                                FileName$ = iDirectory$+Name$
                                If FileSize(FileName$+"\") <> -2
                                    
                                    
                                    If (UserFilePattern$ <> "*.*")
                                        iExtension$ = GetExtensionPart(FileName$)
                                        
                                        If ( Left(UserFilePattern$,1) = "*" )
                                            Pattern$ = GetExtensionPart(UserFilePattern$)
                                            
                                            If ( LCase(Pattern$) = LCase(iExtension$) )
                                                Extension_Collect = 1
                                            EndIf    
                                                
                                        Else
                                            If ( Right(UserFilePattern$,1) = "*" )
                                                Pos = FindString(UserFilePattern$,"*",1)
                                                Pattern$ = Left(UserFilePattern$, Pos -2)
                                                
                                                iExtension$ = GetFilePart(FileName$, #PB_FileSystem_NoExtension)
                                                
                                                If ( LCase(Pattern$) = LCase(iExtension$) )
                                                    Extension_Collect = 1
                                                EndIf                                                 
                                            Else                                                                                                
                                                Pattern$ = UserFilePattern$ ; Check for Filenames
                                                iExtension$ = GetFilePart(FileName$)
                                                If ( LCase(Pattern$) = LCase(iExtension$) )
                                                    Extension_Collect = 1
                                                EndIf                                                  
                                            EndIf
                                         EndIf   
                                    EndIf
                                    
                                    If (UserFilePattern$ = "*.*"): Extension_Collect = 1: EndIf
                                    
                                    If (Extension_Collect = 1)
                                        FileCount.FILE_ITEM_COUNT\Files = FileCount.FILE_ITEM_COUNT\Files+1     ; Debug FileName$
                                        
;                                         Select FileCount.FILE_ITEM_COUNT\Files
;                                             Case 100
;                                                 PauseThread(FFS::FFS_Thread.i): Debug "PauseThread"
;                                                 FFS::FFS_ThreadOnPause.i = #True
;                                         EndSelect        
                                        
                                        AddDirectoryContent_Files(FileName$,iResult,SetFormatDate$,FileCount.FILE_ITEM_COUNT\Files)
                                        
                                        If (*Params\Time_Current >= *Params\DisplayTime) And (*Params\DisplayGui.i = #True)
                                            SetGadgetText(#_NotifyString2,*Params\Searching$ )
                                            FFH::CreateShortenedPath(#_NotifyString3,FileName$, #_NotifyWindow)
                                        EndIf
                                        If (FileName$ <> CurrentFile$) Or (CurrentFile$ = "")
                                            CurrentFile$ = FileName$                                               
                                        EndIf    
                                    EndIf
                                    
                                EndIf                                   
                            EndIf
                        EndIf
                EndSelect 
                
            Wend                       
            FindClose_(iResult)
        Else
            Result = IsJuction_Directory(iDirectory$)
            If Result = #True
                Debug "HardLink, Junction Directory/File: " + iDirectory$
            Else
                Debug "ACESS DENIED, Directory/File: " + iDirectory$
                
                sLANGUAGE = 407 
                Select sLANGUAGE
                    Case 407            
                        Request0$ = "Now Look What You've Done" 
                        Request1$ = "ACCESS DENIED"
                        Request2$ = #LFCR$+"Der Zugriff wurde verweigert:"+#LFCR$+iDirectory$
                    Default
                        Request0$ = "Now Look What You've Done"
                        Request1$ = "ACCESS DENIED"
                        Request2$ = "To:"+#LFCR$+#LFCR$+iDirectory$    
                EndSelect                
                MessageRequester(Request0$,Request1$+#LFCR$+Request2$,#PB_MessageRequester_Ok)
            EndIf
        EndIf
        ProcedureReturn 1     
    EndProcedure               
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   GetDirectoryContent
    ;  Holt das Komplette Verzeichnis in eine Structur
    ;
    ;  iDirectory$          : DAS Verzeichnis was durchsucht werden soll
    ;  IncludeDirectorys    : Verzeichnisse Durchsuchen und merken Ja/Nein
    ;  IncludeFiles         : Dateien durchsuchen und merken Ja/Nein  
    ;  IncludeSubDirectorys : Unterverzeichnisse Durchsuchen Ja/Nein
    ;  FilePattern$         : Dateien nur mit bestimmten Endungen suchen und merken
    ;  DirectoryDepth       : Setzt die Verzeichniss Ebene
    ;  DisplayGui           : Informiert den benutzer das die Anwendung noch Aktiv ist und zeigt den Aktuellen Lese Stand
    ;  DisplayTime          ; Öffnet das Fenster ab dem *Wert
    ;  Searching$           ; Wennn icht angeben ist wird die Komplette Strukture als Liste abgelegt sons wird nach dem Dateinamen gesucht (Ohne Verzeichnis angabe)
    ;  Hashstring$          ; Nur in Zusammenhang mit Searching$, Sicht nach dem Dateinamen und dem SHA1 String
    Procedure GetContent(iDirectory$, IncludeDirectorys = #True, IncludeFiles = #True, IncludeSubDirectorys = #True,SetFormatDate$ = "", FilePattern$ = "*.*",DirectoryDepth.i = 0, DisplayGui.i = #False, DisplayTime.i = 100, Searching$ = "", Hashstring$ = "")
        Protected FileExe$,SHA1Num$
        
        *Params.FILESEARCH_System   = AllocateMemory(SizeOf(FILESEARCH_System))
        
        *Params\iDirectory          = iDirectory$
        *Params\IncludeDirectorys   = IncludeDirectorys
        *Params\IncludeFiles        = IncludeFiles
        *Params\IncludeSubDirectorys= IncludeSubDirectorys
        *Params\SetFormatDate.s     = SetFormatDate$
        *Params\FilePattern.s       = FilePattern$
        *Params\DirectoryDepth      = DirectoryDepth
        *Params\DirectoryDepth      = DirectoryDepth
        *Params\DisplayGui.i        = DisplayGui.i    
        *Params\DisplayTime         = DisplayTime
        *Params\Searching$          = Searching$
        
        If DisplayGui.i = #True
            NotifiyWindow(ProgramFilename())
        EndIf    
        
        FFS_Thread.i = CreateThread(@ _GetFileList(),*Params)
        While IsThread(FFS_Thread.i) 

           Delay(1)
            If (Len(Searching$) <> 0) 
                ;Delay(15)                    
                
                If Len(CurrentFile$) <> 0
                    ;Debug CurrentFile$
                    
                    FileExe$ = LCase(GetFilePart(CurrentFile$))
                    
                    Select LCase(Searching$)
                        Case ""
                        Case FileExe$
                            ; Dateienamen gefunden
                            ;
                            PauseThread(FFS_Thread.i)  
                            
                            Debug "Searching For '"+Searching$+"' ::Found >> " + CurrentFile$
                            
                            If Len(Hashstring$) <> 0
                              
                                SHA1Num$ = FileFingerprint(CurrentFile$,#PB_Cipher_SHA1)
                                Select Hashstring$
                                    Case SHA1Num$
                                        ; Dateiname und SHA1 gefunden
                                        If IsThread(FFS_Thread.i)
                                            KillThread(FFS_Thread.i)
                                            Break
                                        EndIf                                
                                EndSelect
                            EndIf
                            If IsThread(FFS_Thread.i)
                                ResumeThread(FFS_Thread.i)
                            EndIf                            
                    EndSelect
                EndIf           
                    
            EndIf
               
            ;                          If PeekMessage_(@Msg.MSG,WindowID(#_NotifyWindow),0,0,#PM_NOREMOVE)   
            ;                              If Msg\message=#WM_KEYDOWN And Msg\wParam=27
            ;                                  MessageRequester("Fake","Fake")
            ;                                  ;Abort_Request(_Action1,0,rPointIcon$,*Params)
            ;                             EndIf                          
            ;                          EndIf     
            If DisplayGui.i = #True
                While WindowEvent() 

            
                ;                     If (*Params\Time_Current = 100) And (*Params\DisplayGui.i = #True)
                ;                         SetGadgetText(#_NotifyString2,"Search For Directorys")
                ;                         RequestPathEx::CreateShortenedPath(#_NotifyString3,*Params\iDirectory, #_NotifyWindow)
                ;                     EndIf                          
                Wend
           EndIf    
        Wend 
        
        
        If IsThread(FFS_Thread.i): KillThread(FFS_Thread.i): EndIf 
        
        Delay(25):FreeMemory(*Params): Delay(75):
        If DisplayGui.i = #True
            CloseWindow(#_NotifyWindow):                    
        EndIf    
    EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;                                                                                                                   AttDirectoryContent
    ;   Fügt Alle Directorys und Dateien 'Special' der Liste hinzu
    ;
    
    Procedure SizeContent(FileList=#True,FolderList=#False)
        
        If (FileList = #True) And (FolderList = #False): ProcedureReturn FileCount.FILE_ITEM_COUNT\Files: EndIf
        If (FileList = #False) And (FolderList = #True): ProcedureReturn FileCount.FILE_ITEM_COUNT\Dirs: EndIf             
    EndProcedure
    
    
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
    ;  
    
    
    
    
EndModule


CompilerIf #PB_Compiler_IsMainFile
    
    XIncludeFile "_TEMPLATE\PC98.pb"
    
    ;SHA1TETS$ = SHA1FileFingerprint("E:\Games\1st Century After Tsunami 2265\Tsunami 2265 (Start,i).exe")
    ;Delay(25)
    Debug "Demo:  Fast File Search"
    Debug "Show All founded Files:"
    Debug "------------------------------------------------------------------------------------------"
    FFS::GetContent("B:\PC998\",#True, #True, #True,"","*.zip",0,#True,100,"")
    FFS::SortContent()
    ResetList(FFS::FullFileSource())
    X = 0
    While NextElement(FFS::FullFileSource())
        
        Debug "FullPath : " +FFS::FullFileSource()\FileName
        
        
        ResetList(PC98())
        While NextElement(PC98())
            Position = FindString(FFS::FullFileSource()\FileName, PC98()\FileNameJ,1)
            If ( Position <> 0 )        
                
                FileName$ = GetFilePart(FFS::FullFileSource()\FileName,#PB_FileSystem_NoExtension)
                FilePath$ = GetPathPart(FFS::FullFileSource()\FileName)
                
                LenTest$ = Mid(FileName$,Position,Len(PC98()\FileNameJ))
                
                
                Debug Chr(13)
                Debug "=============================================================================================="
                Debug "NAME FOUND PART: " + PC98()\FileNameE + " -- ("+ FileName$+ ") / Längen Test: " + LenTest$
                Debug "NAME FOUND VERS: " + PC98()\FileNameE + " -- ("+ PC98()\FileNameE + ")"
                Debug "=============================================================================================="                                              

                If ( LenTest$ = PC98()\FileNameJ)
                    Result =  RenameFile(FFS::FullFileSource()\FileName, FilePath$ + PC98()\FileNameE + ".zip")
                    If ( Result = 0 )
                        Debug "FEHLR BEIM UMEBENNEN: " + FFS::FullFileSource()\FileName
                        CallDebugger
                    Else
                        Debug "=============================================================================================="
                        Debug "UMBENANNT"
                        Debug FilePath$ + PC98()\FileNameE + "zip"
                        Debug "==============================================================================================" 
                        CallDebugger 
                    EndIf    
                    Break
                    Delay(500)
                Else
                EndIf                 
           EndIf     
       Wend
   Wend
   
    Debug ""
    Debug ""
    Debug "Pause"
    
    
    
;     NewList CharList.s()
;     
;     ResetList(FFS::FullDirectorySource())
;     While NextElement(FFS::FullDirectorySource())
;         Debug "Directory: >> "+ FFS::FullDirectorySource()\FileName
;         
;         ResetList(PC98())
;         While NextElement(PC98())
;             Position = FindString(FFS::FullDirectorySource()\FileName, PC98()\FileNameJ,1)
;             If ( Position <> 0 )
;                 
;                 Debug "DIRECTORY FOUND: PART" + FFS::FullDirectorySource()\FileName + "("+ PC98()\FileNameE + ")"
;                 
;                 CallDebugger
;                 OldPath$ = FFS::FullDirectorySource()\FileName
;                 NewPath$ = ""
;                 FFH::PathPartsExt(Path$,CharList.s())
;                 
;                 ResetList( CharList.s() )
;                 
;                 While NextElement(CharList.s())
;                     
;                     OldPartPath$ = CharList.s()
;                     If ( OldPartPath$ = PC98()\FileNameJ )
;                         NewPath$ = ReplaceString(FFS::FullDirectorySource()\FileName,OldPartPath$,PC98()\FileNameE)
;                         Result   = RenameFile(FFS::FullDirectorySource()\FileName, NewPath$)
;                         If ( Result = 0 )
;                             Debug "FEHLR BEIM UMEBENNEN: " + FFS::FullFileSource()\FileName
;                         EndIf
;                         Break
;                         Delay(500) 
;                     EndIf                            
;                 Wend    
;                 
;             EndIf     
;         Wend 
;     Wend
           
        
    ;Wend 
    
    ;     Debug "Demo:  Fast File Search"
    ;     Debug "Sort Content:"
    ;     Debug "------------------------------------------------------------------------------------------"        
    ;     FFS::SortContent()
    ;     ResetList(FFS::FullFileSource())
    ;     While NextElement(FFS::FullFileSource())
    ;         Debug "FullPath: >> " +FFS::FullFileSource()\FileName
    ;     Wend
    ;     Debug ""
    ;     Debug ""
    ;     ResetList(FFS::FullDirectorySource())
    ;     While NextElement(FFS::FullDirectorySource())
    ;         Debug "Directory: >> "+ FFS::FullDirectorySource()\FileName
    ;     Wend 
    ;     
    ;     Debug ""
    ;     Debug ""         
    ;     Debug "Demo:  Fast File Search"
    ;     Debug "Del Content:"
    ;     Debug "------------------------------------------------------------------------------------------"         
    ;     FFS::DelContent()
    ;     
    ;     Debug ""
    ;     Debug ""
    ;     Debug "Demo:  Fast File Search"
    ;     Debug "Show All founded Files only *.appinfo"
    ;     Debug "------------------------------------------------------------------------------------------"             
    ;     FFS::GetContent("V:\",#True, #True, #True,"","*.appinfo")
    ;     ResetList(FFS::FullFileSource())
    ;     While NextElement(FFS::FullFileSource())
    ;         Debug "FullPath: >> " +FFS::FullFileSource()\FileName
    ;     Wend
    ;     Debug ""
    ;     Debug ""
    ;     ResetList(FFS::FullDirectorySource())
    ;     While NextElement(FFS::FullDirectorySource())
    ;         Debug "Directory: >> "+ FFS::FullDirectorySource()\FileName
    ;     Wend       
    
    ;       Debug GetFileDate("C:\Windowswin.ini", #PB_Date_Modified)
    ;       
    ;       Modified = GetFileDate("C:\Windowswin.ini", #PB_Date_Modified)
    ;       FFS::AutoQuickSave_backup("C:\","Windowswin.ini","Backup",Modified)
    
    
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 133
; FirstLine = 107
; Folding = XAw
; EnableAsm
; EnableThread
; EnableXP
; EnableUnicode