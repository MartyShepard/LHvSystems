CompilerIf #PB_Compiler_IsMainFile
  UseSQLiteDatabase()
  UsePNGImageDecoder()
  
  IncludeFile "Class_ProcessEX.pb"
  ;     IncludeFile "Class_Fonts.pb"
  ;     IncludeFile "Class_GadgetEX.pb"
  ;     IncludeFile "Class_RequestEX.pb"
  
CompilerEndIf
DeclareModule DesktopEX
  
  Define hWndPM.WINDOWPLACEMENT 
  
  Structure _Struc_Windows_Command
    Window_Handle.l
    Window_Name.s
  EndStructure 
  
  #LH_WINDOWLOG=304
  
  Declare GetWindowPosition(LogFile$)
  Declare MinWindow()    
  Declare ResWindowPosition(LogFile$)     
  Declare CloseExplorer()
  Declare StartExplorer()
  Declare SetTaskBar()
  Declare SetShortCut(Path.s, Link.s, WorkingDir.s = "", Argument.s = "", ShowCommand.l = #SW_SHOWNORMAL, Description.s =  "", HotKey.l = #Null, IconFile.s = "|", IconIndex.l = 0)
  Declare.s SystemSpecDirectory(clsi_const.l)
  Declare.s GetTime(Format=0)
  Declare Icon_HideFromTaskBar(hWnd.l, Flag.l)
  Declare.l Icon_SingleExtractEx(File.s, Size.l = 1,Selected.l = #True)
  Declare RemoveBorders(ProgWindow.l, BorderX.i, BorderY.i, BorderW.i, BorderH.i, BorderAutoXY.i, WindowTop.l, HideTheWindow.i = 0, HideFlag.l = #SW_HIDE, ViewFlag.l = #SW_SHOW)
  Declare Get_TaskbarHeight(WindowID.i, GetTaskbarHeight.i = #False)
  Declare.l GetWindows(Search.s = "")
  
  ;
  ; Look procdure for Info
  Declare.s MonitorInfo_DisplayName()
  Declare.l MonitorInfo_Display_Size(GetHeight.i = #False, GetWidth.i = #False)
  Declare.l MonitorInfo_Display_Depth()
  Declare.l MonitorInfo_Display_Freq()
  Declare.l MonitorInfo_Display_GetPrimary(WindowID = -1)
EndDeclareModule

Module DesktopEX
  
  Global NewList WindowList_._Struc_Windows_Command()
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure.s Get_WindowsVersion(iSelect = 0)

    Protected sMajor$, sMinor$, sBuild$, Version$, sPlatform$, SystemRoot$, iResult.l, PBOsVersion.i
    Define Os.OSVERSIONINFO
    Define WinVersion$
    
    
    Os\dwOSVersionInfoSize = SizeOf(OSVERSIONINFO)
    GetVersionEx_(@Os.OSVERSIONINFO)
    
    Select iSelect
      Case 0:
        sMajor$ = Str(Os\dwMajorVersion)
        sMinor$ = Str(Os\dwMinorVersion)
        ProcedureReturn sMajor$+sMinor$
      Case 1:
        sBuild$ = Str(Os\dwBuildNumber)
        ProcedureReturn sBuild$
      Case 2:
        sSPack$ = PeekS(@Os\szCSDVersion)
        ProcedureReturn sSPack$
      Case 4:
        sPlatform$    = Str(Os\dwPlatformId)
        sMajor$       = Str(Os\dwMajorVersion)
        sMinor$       = Str(Os\dwMinorVersion)        
        
        Version$= sPlatform$+"."+sMajor$+"."+sMinor$
        Select Version$
            
          Case "1.0.0":     ProcedureReturn "Windows 95"
          Case "1.1.0":     ProcedureReturn "Windows 98"
          Case "1.9.0":     ProcedureReturn "Windows Millenium"
          Case "2.3.0":     ProcedureReturn "Windows NT 3.51"
          Case "2.4.0":     ProcedureReturn "Windows NT 4.0"
          Case "2.5.0":     ProcedureReturn "Windows 2000"
          Case "2.5.1":     ProcedureReturn "Windows XP"
          Case "2.5.3":     ProcedureReturn "Windows 2003 (SERVER)"
          Case "2.6.0":     ProcedureReturn "Windows Vista"
          Case "2.6.1":     ProcedureReturn "Windows 7"
          Case "2.6.2":     ProcedureReturn "Windows 8"             ;Build 9200   
          Case "2.6.3":     ProcedureReturn "Windows 10"            ;Build 9800                   
          Default:          ProcedureReturn "Unknown"
        EndSelect
        
      Case 5:
        If ExamineEnvironmentVariables()
          While NextEnvironmentVariable()
            SystemRoot$ = EnvironmentVariableName()
            If (LCase(SystemRoot$)="systemroot")
              ProcedureReturn EnvironmentVariableValue() 
              
            EndIf
          Wend
        EndIf
        
      Case 6:
        If ExamineEnvironmentVariables()
          While NextEnvironmentVariable()
            SystemRoot$ = EnvironmentVariableName()
            If (LCase(SystemRoot$)="systemroot")
              
              iResult = FileSize(SystemRoot$+"SYSWOW64\")
              If (iResult = -2)                        
                ProcedureReturn EnvironmentVariableValue()+"\SYSWOW64\"
              Else
                ProcedureReturn EnvironmentVariableValue()+"\SYSTEM32\"
              EndIf                                                
            EndIf
          Wend
        EndIf          
        
      Case 7 ; Simple
        PBOsVersion = OSVersion()
        Select PBOsVersion
          Case #PB_OS_Windows_NT3_51
            ProcedureReturn "Windows NT3.51"
          Case #PB_OS_Windows_95
            ProcedureReturn "Windows'95"
          Case #PB_OS_Windows_NT_4
            ProcedureReturn "Windows NT4"
          Case #PB_OS_Windows_98
            ProcedureReturn "Windows'98"
          Case #PB_OS_Windows_ME
            ProcedureReturn "Windows Millenium"
          Case #PB_OS_Windows_2000
            ProcedureReturn "Windows 2000"
          Case #PB_OS_Windows_XP
            ProcedureReturn "WindowsXP"
          Case #PB_OS_Windows_Server_2003
            ProcedureReturn "Server 2003"
          Case #PB_OS_Windows_Vista
            ProcedureReturn "Windows Vista"
          Case #PB_OS_Windows_Server_2008
            ProcedureReturn "Server 2008"
          Case #PB_OS_Windows_7
            ProcedureReturn "Windows 7"
          Case #PB_OS_Windows_Server_2008_R2
            ProcedureReturn "Server 2008R2"
          Case #PB_OS_Windows_8
            ProcedureReturn "Windows 8"
          Case #PB_OS_Windows_Server_2012
            ProcedureReturn "Server 2012"
          Case #PB_OS_Windows_8_1
            ProcedureReturn "Windows 8.1"
          Case #PB_OS_Windows_Server_2012_R2
            ProcedureReturn "Server 2012R2"
          Case #PB_OS_Windows_10
            ProcedureReturn "Windows 10"
          Case #PB_OS_Windows_Future  
            ProcedureReturn "Unknown Windows Version"
        EndSelect
    EndSelect
    
    ;-----------------------------------------------------------------------------------------------        
    ; Get_WindowsVersion(iSelect=0), Holt die Aktuelle Windows Version, via iSelect lässt sich
    ; mehrere Information zurückgeben
    ; iSelect=5 gibt das Windows Root Verzeichnis Zurück
    ; iSelect=6 gibt das Windows System Verzeichnis Zurück
    ;-----------------------------------------------------------------------------------------------    
  EndProcedure    
  
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure.l GetWindows(Search.s="")
      Protected Handle.i ,DataSize$, iResult.i, FindPos.i
      
      If ListSize(WindowList_()) <> 0: ClearList(WindowList_()): EndIf
      
      Search = ReplaceString(Search,".exe","",0,1)
      Handle.i = GetWindow_(GetDesktopWindow_(),#GW_CHILD)
      
      Repeat        
        If IsWindowVisible_(Handle.i)= #True And IsIconic_(Handle.i) = 0
          DataSize$ = Space(999)
          
          GetWindowText_(Handle.i,DataSize$,999)
          If Len(DataSize$) = 0
          Else 
              AddElement(WindowList_())                            
              WindowList_()\Window_Handle = Handle.i
              WindowList_()\Window_Name.s = DataSize$ 
              
          EndIf
      EndIf
      Handle.i=GetWindow_(Handle.i,#GW_HWNDNEXT)
      Until Handle.i = 0
      
      Search = ReplaceString(Search,".exe","",0,1)
      
      ResetList(WindowList_())
      While NextElement(WindowList_())
          Debug "Suche Nach dem Fenster: " +Search+ " [" + WindowList_()\Window_Name + "]"
          FindPos = FindString(WindowList_()\Window_Name, Search,1,#PB_String_NoCase )
          If (FindPos)
              Debug "===================================================================GEFUNDEN"
              Debug "Suche Nach dem Fenster: " +Search+ " [" + WindowList_()\Window_Name + "]"
              Debug "==========================================================================="             
              ProcedureReturn WindowList_()\Window_Handle
          EndIf     
      Wend
    
      ProcedureReturn 0
  
  EndProcedure  
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure GetWindowPosition(LogFile$)
    Protected Handle.i ,DataSize$, FileSize.i, iResult.i: timeBeginPeriod_(1)
    
    FileSize = FileSize(LogFile$)
    Select FileSize
      Case 0, -1
      Default
        iResult = DeleteFile(LogFile$)
        Delay(25)
    EndSelect         
    
    If CreateFile(#LH_WINDOWLOG, LogFile$)
      CloseFile(#LH_WINDOWLOG)          
    EndIf  
    
    If OpenDatabase(#LH_WINDOWLOG, LogFile$, "", "")
      
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA SHOW_DATATYPES=ON;")
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA default_cache_size=65536;")
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA cache_size=65536;")
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA checkpoint_fullfsync=true;")
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA journal_mode = MEMORY;")
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA temp_store = MEMORY;")
      DatabaseUpdate(#LH_WINDOWLOG, "PRAGMA synchronous=OFF;")        
      
      DatabaseUpdate(#LH_WINDOWLOG, "CREATE TABLE IF NOT EXISTS WindowPosition (id INTEGER PRIMARY KEY,Window CHAR(255), Handle INT)")
      DatabaseUpdate(#LH_WINDOWLOG, "CREATE INDEX IF NOT EXISTS 'IDX_ID' ON 'WindowPosition'('id' ASC)")
      DatabaseUpdate(#LH_WINDOWLOG, "CREATE INDEX IF NOT EXISTS 'IDX_WN' ON 'WindowPosition'('Window' ASC)")
      DatabaseUpdate(#LH_WINDOWLOG, "CREATE INDEX IF NOT EXISTS 'IDX_HD' ON 'WindowPosition'('Handle' ASC)")
      
      Debug DatabaseError()
      Handle.i = GetWindow_(GetDesktopWindow_(),#GW_CHILD)
      
      Repeat        
          If IsWindowVisible_(Handle.i)= #True And IsIconic_(Handle.i) = 0
              DataSize$ = Space(999)
              
              GetWindowText_(Handle.i,DataSize$,999)
              If Len(DataSize$) = 0
              Else 
                  AddElement(WindowList_())
                  If FindString(DataSize$,"PureBasic",1) = 0
                      If FindString(DataSize$,"Sysinternals",1) = 0
                          If FindString(DataSize$,"Task-Manager",1) = 0
                              If FindString(DataSize$,"Notepad++",1) = 0
                                  If FindString(DataSize$,"Windows Virtual PC",1) = 0
                                      
                                      WindowList_()\Window_Handle = Handle.i
                                      WindowList_()\Window_Name.s = DataSize$ 
                                      
                                      DatabaseUpdate(#LH_WINDOWLOG, "INSERT INTO WindowPosition (id, Window, Handle) VALUES (NULL,'"+DataSize$ +"', '"+Handle.i+"')")
                                      Debug DatabaseError()
                                  EndIf
                              EndIf
                          EndIf
                      EndIf
                  EndIf
              EndIf
          EndIf
          Handle.i=GetWindow_(Handle.i,#GW_HWNDNEXT)
      Until Handle.i = 0
      timeEndPeriod_(1) :CloseDatabase(#LH_WINDOWLOG) 
  EndIf
EndProcedure
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure MinWindow()
    
    If ListSize(WindowList_()) <> 0
      ResetList(WindowList_())
      While NextElement(WindowList_())  
        ShowWindow_(WindowList_()\Window_Handle, #SW_HIDE)
        Debug "Minimiere "+WindowList_()\Window_Name
      Wend
    EndIf
    
  EndProcedure
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure ResWindowPosition(LogFile$)
    Protected Handle.i: timeBeginPeriod_(1)
    If ListSize(WindowList_()) <> 0
      
      ResetList(WindowList_())
      While NextElement(WindowList_())
        ShowWindow_(WindowList_()\Window_Handle, #SW_SHOW)  :Debug "Memory: Maximiere "+WindowList_()\Window_Name
      Wend
      ClearList(WindowList_());: FreeList(WindowList_())
    Else
      If OpenDatabase(#LH_WINDOWLOG, LogFile$, "", "")
        
        If DatabaseQuery(#LH_WINDOWLOG, "SELECT * FROM WindowPosition")
          While NextDatabaseRow(#LH_WINDOWLOG)
            Handle.i = Val(GetDatabaseString(#LH_WINDOWLOG,2))
            ShowWindow_(Handle.i , #SW_SHOW)            :Debug "Database: Maximiere "+GetDatabaseString(#LH_WINDOWLOG,1)
            
          Wend
          FinishDatabaseQuery(#LH_WINDOWLOG)
        EndIf
      EndIf
      CloseDatabase(#LH_WINDOWLOG)
    EndIf
    
    FileSize = FileSize(LogFile$)
    If (FileSize <> 0) Or (FileSize <> -1): iResult = DeleteFile(LogFile$): Delay(5): EndIf : timeEndPeriod_(1)
  EndProcedure
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure CloseExplorer()
    
    Protected iPrcExplore
    
    ProcessEX::TaskListCreate()
    iPrcExplore = ProcessEX::TaskListGetPID("explorer.exe"):Debug "ProcessID Explorer.exe :"+iPrcExplore
    If (iPrcExplore <> 0)
      Repeat
        ProcessEX::KillProcess(iPrcExplore)
        Delay(25)
        ProcessEX::TaskListCreate()
        iPrcExplore = ProcessEX::TaskListGetPID("explorer.exe")
      Until iPrcExplore = 0
    EndIf
    ProcedureReturn ExploreHndl
  EndProcedure
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure StartExplorer()
    Protected iPrcExplore
    
    Define ShExec.SHELLEXECUTEINFO
    
    ProcessEX::TaskListCreate()
    iPrcExplore = ProcessEX::TaskListGetPID("explorer.exe"):Debug "ProcessID Explorer.exe :"+iPrcExplore
    
    If (iPrcExplore = 0)
      OpenPath$ = Get_WindowsVersion(5)+"\explorer.exe"
      Paramter$ = ""
      Verb$      = "runas"
      ShExec\cbSize = SizeOf(SHELLEXECUTEINFO)
      
      ShExec\fMask = #SEE_MASK_NOCLOSEPROCESS
      ShExec\hwnd = iPrcExplore
      ShExec\lpVerb = #Null
      ShExec\lpFile = @OpenPath$
      ShExec\lpParameters = @Paramter$
      ShExec\lpDirectory = #Null
      ShExec\nShow =  #SW_SHOWNORMAL           
      
      If (ShellExecuteEx_(@ShExec.SHELLEXECUTEINFO))
        WaitForSingleObject_(ShExec\hwnd, INFINITE);
        CloseHandle_(ShExec\hwnd)
        
      EndIf
    EndIf
    
  EndProcedure
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________
  Procedure SetTaskBar()
    Protected TB_TaskBar, TB___Start, Flag1.l, Flag2.l
    
    TB_TaskBar = FindWindow_("Shell_TrayWnd",0)
    TB___Start = FindWindow_(0,"Start")
        
    If (IsWindowVisible_(TB_TaskBar))
        Flag1 = #SW_HIDE
        Flag2 = #SWP_HIDEWINDOW
        
    ElseIf Not (IsWindowVisible_(TB_TaskBar))
        Flag1 = #SW_SHOW
        Flag2 = #SWP_SHOWWINDOW
      
    EndIf     
      
    SetWindowPos_(TB_TaskBar, 0, 0, 0, 0, 0, Flag2)
    ShowWindow_(TB_TaskBar,Flag1)
    ShowWindow_(TB___Start,Flag1)
   
  EndProcedure
  ;====================================================================================================================
  ; Set Shortcut on a Desktop
  ;____________________________________________________________________________________________________________________   
  Procedure.s SystemSpecDirectory(clsi_const.l)
    
    Protected path.s = Space(2048)
    Protected pidl.l
    
    SHGetSpecialFolderLocation_(0,clsi_const,@pidl.l)
    SHGetPathFromIDList_(pidl,@path)
    CoTaskMemFree_(pidl)
    
    ProcedureReturn path+"\"
  EndProcedure
  Macro DEFINE_GUID(Name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8)
    CompilerIf Defined(Name, #PB_Variable)
      If SizeOf(Name) = SizeOf(GUID)
        Name\Data1    = l
        Name\Data2    = w1
        Name\Data3    = w2
        Name\Data4[0] = b1
        Name\Data4[1] = b2
        Name\Data4[2] = b3
        Name\Data4[3] = b4
        Name\Data4[4] = b5
        Name\Data4[5] = b6
        Name\Data4[6] = b7
        Name\Data4[7] = b8
      Else
        Debug "Error - variable not declared as guid"
      EndIf
    CompilerEndIf
  EndMacro
  Procedure SetShortCut(Path.s, Link.s, WorkingDir.s = "", Argument.s = "", ShowCommand.l = #SW_SHOWNORMAL, Description.s =  "", HotKey.l = #Null, IconFile.s = "|", IconIndex.l = 0)
    
    Protected psl.IShellLinkW, ppf.IPersistFile, Result
    Protected.GUID CLSID_ShellLink, IID_IShellLink, IID_IPersistFile
    
    DEFINE_GUID(CLSID_ShellLink, $00021401, $0000,$0000, $C0, $00, $00, $00, $00, $00, $00, $46) ; {00021401-0000-0000-C000-000000000046}
    DEFINE_GUID(IID_IShellLink, $000214F9, $0000,$0000, $C0, $00, $00, $00, $00, $00, $00, $46)  ; {000214F9-0000-0000-C000-000000000046}
    DEFINE_GUID(IID_IPersistFile, $0000010B, $0000,$0000, $C0, $00, $00, $00, $00, $00, $00, $46); {0000010b-0000-0000-C000-000000000046}
    
    If IconFile = "|"
      IconFile = Path
    EndIf
    
    If Len(WorkingDir) <> 0
      WorkingDir = GetPathPart(Path)
    EndIf
    
    CoInitialize_(0)
    If CoCreateInstance_(@CLSID_ShellLink, 0, 1, @IID_IShellLink, @psl) =  #S_OK
      
      Set_ShellLink_preferences:
      psl\SetPath(Path)
      psl\SetArguments(Argument)
      psl\SetWorkingDirectory(WorkingDir)
      psl\SetDescription(DESCRIPTION)
      psl\SetShowCmd(ShowCommand)
      psl\SetHotkey(HotKey)
      psl\SetIconLocation(IconFile, IconIndex)
      ShellLink_SAVE:
      If psl\QueryInterface(@IID_IPersistFile, @ppf) = #S_OK
        ppf\Save(Link, #True)
        result = 1
        ppf\Release()
      EndIf
      psl\Release()
    EndIf
    CoUninitialize_()
    ProcedureReturn result
  EndProcedure
  ;********************************************************************************************************************
  ;____________________________________________________________________________________________________________________ 
  Procedure.s _SignFix_DT(iTime.s)
    If Len(iTime.s) = 1
      ProcedureReturn"0"+iTime.s
    EndIf
    ProcedureReturn iTime.s  
  EndProcedure  
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________    
  Procedure.s GetTime(Format=0)
    
    Define iTimeDate.SYSTEMTIME
    GetSystemTime_(iTimeDate)
    
    Select Format
      Case 0
        Time_Date.s =   _SignFix_DT(Str(iTimeDate\wYear))+
                        "-" +  _SignFix_DT(Str(iTimeDate\wMonth))+
                        "-" +  _SignFix_DT(Str(iTimeDate\wDay))+
                        " # ("+_SignFix_DT(Str(iTimeDate\wHour+1))+
                        ";" +  _SignFix_DT(Str(iTimeDate\wMinute))+
                        ";" +  _SignFix_DT(Str(iTimeDate\wSecond))+")"               
    EndSelect
    ProcedureReturn Time_Date.s
  EndProcedure    
  ;====================================================================================================================
  ;
  ;____________________________________________________________________________________________________________________  
  Procedure Icon_HideFromTaskBar(hWnd.l, Flag.l) ; Hide window in the taskbar
    
    Protected TBL.ITaskbarList
    CoInitialize_(0)
    If CoCreateInstance_(?CLSID_TaskBarList, 0, 1, ?IID_ITaskBarList, @TBL) = #S_OK
      TBL\HrInit()
      If Flag
        TBL\DeleteTab(hWnd)
      Else
        TBL\AddTab(hWnd)
      EndIf
      TBL\Release()
    EndIf
    CoUninitialize_()
    
    DataSection
      CLSID_TaskBarList:
      Data.l $56FDF344
      Data.w $FD6D, $11D0
      Data.b $95, $8A, $00, $60, $97, $C9, $A0, $90
      IID_ITaskBarList:
      Data.l $56FDF342
      Data.w $FD6D, $11D0
      Data.b $95, $8A, $00, $60, $97, $C9, $A0, $90
    EndDataSection
  EndProcedure        
  ;====================================================================================================================
  ;
  ;Description : Returns ImageId of an Icon embedded IN a file (Exe Or Dll )
  ; Size = 0 Get Small Icon / 1 Get Big Icon, If Selected = #True : Icon is Selected   
  ; Returns ImageId of an Icon embedded in a file (Exe Or Dll )
  ;____________________________________________________________________________________________________________________ 
  Procedure.l Icon_SingleExtractEx(File.s, Size.l = 1,Selected.l = #True) 
    
    If Selected
      Type=#SHGFI_SELECTED
    EndIf
    
    If Size
      SHGetFileInfo_(File, 0, @InfosFile.SHFILEINFO, SizeOf(SHFILEINFO), Type | #SHGFI_ICON | #SHGFI_LARGEICON)
      ProcedureReturn InfosFile\hIcon
    Else
      SHGetFileInfo_(File, 0, @InfosFile.SHFILEINFO, SizeOf(SHFILEINFO), Type | #SHGFI_ICON |#SHGFI_SMALLICON)
      ProcedureReturn InfosFile\hIcon
    EndIf
    
  EndProcedure
  ;====================================================================================================================
  ;
  ;
  ;____________________________________________________________________________________________________________________   
    Procedure RemoveBorders(ProgWindow.l, BorderX.i, BorderY.i, BorderW.i, BorderH.i, BorderAutoXY.i, WindowTop.l, HideTheWindow.i = 0, HideFlag.l = #SW_HIDE, ViewFlag.l = #SW_SHOW)
        
        Protected Taskbar.RECT, Window.RECT, Clent.RECT, W.i, H.i, TitleBarH.i, Border.i, CxEdge.i, ClientRect.RECT 
        
        Delay(200)
        SystemParametersInfo_(#SPI_GETWORKAREA, 0, @Taskbar, 0)  
        
        
        
        If GetWindowLongPtr_(ProgWindow,#GWL_STYLE)&#WS_DLGFRAME
            
            
            Debug "Fensterrahmen: JA"
            
            GetClientRect_(ProgWindow, @Clent);
            GetWindowRect_(ProgWindow, @Window)
            
            W = Window\right - Window\left
            H = Window\bottom - Window\top
            
            If ( BorderAutoXY = 0 )
                Window\left = BorderX                                                
                Window\top = BorderY                     
            EndIf    
            If ( BorderW.i <> 0)
                W = Window\right - Window\left
            EndIf                   
            If ( BorderH.i <> 0)
                H = Window\bottom - Window\top
            EndIf            
            
            If ( BorderAutoXY <> 0 )
                TitleBarH = GetSystemMetrics_(#SM_CYCAPTION)
                Border    = GetSystemMetrics_(#SM_CXBORDER) *2  ;(2)
                CxEdge    = GetSystemMetrics_(#SM_CXEDGE) *2    ;(4)
            EndIf
            
            
            If ( HideTheWindow = 1 )
                ShowWindow_(ProgWindow,HideFlag)   
            EndIf    
            
            MoveWindow_(ProgWindow, Window\left,  Window\top - TitleBarH +  ( TitleBarH + Border + CxEdge) - ( Border + CxEdge), W - ( CxEdge + Border),H - ( TitleBarH + Border + CxEdge) ,1)
            
            SetWindowLongPtr_(ProgWindow,#GWL_STYLE,GetWindowLongPtr_(ProgWindow,#GWL_STYLE)&~(#WS_DLGFRAME|#WS_CAPTION | #WS_THICKFRAME | #WS_MINIMIZE | #WS_MAXIMIZE | #WS_SYSMENU))
            SetWindowLongPtr_(ProgWindow,#GWL_EXSTYLE,GetWindowLongPtr_(ProgWindow,#GWL_EXSTYLE)&~(#WS_EX_DLGMODALFRAME | #WS_EX_CLIENTEDGE | #WS_EX_STATICEDGE))                      
                        
            
            Select WindowTop
                Case 0: WindowTop = #HWND_TOP
                Case 1: WindowTop = #HWND_TOPMOST    
            EndSelect             
            
            SetWindowPos_(ProgWindow, WindowTop, 0,0,0,0, #SWP_NOMOVE | #SWP_NOSIZE)
            ;
            ; Neu, Nicht für Half Life
                    
             GetWindowRect_(ProgWindow, @ClientRect) 
;            ClientPoint.POINT 
;            ClientToScreen_(ProgWindow, @ClientPoint)             
             WinGuru::Center(ProgWindow.l,ClientRect\right,ClientRect\bottom)
             
            If ( HideTheWindow = 1 )
                ShowWindow_(ProgWindow,ViewFlag)
            EndIf             
        Else
            ;Debug "Fensterrahmen: Nein"
        EndIf
                
    EndProcedure   
  ;====================================================================================================================
  ;
  ;
  ;____________________________________________________________________________________________________________________     
    Procedure Get_TaskbarHeight(WindowID.i, GetTaskbarHeight.i = #False)
        Protected Taskbar.rect
        
        #ABM_SETSTATE = $A
        tb.AppBarData
        tb\cbSize = SizeOf(tb)        
        
        #CCHILDREN_TITLEBAR = 5 
        
        Structure MONITORINFOEXA
            cbSize.l
            rcMonitor.RECT
            rcWork.RECT
            dwFlags.l
            szDevice.s {#CCHDEVICENAME}
        EndStructure
        
        Structure TITLEBARINFO
            cbSize.l
            rcTitleBar.RECT
            rgstate.l[#CCHILDREN_TITLEBAR+1]
        EndStructure
    
        Define pt.Point
        
        If GetCursorPos_(@pt)
            HMONITOR = MonitorFromPoint_(PeekQ(@pt), #MONITOR_DEFAULTTONEAREST)
            If IsWindow(WindowID)
                HPRIMIRY = MonitorFromPoint_(WindowID(WindowID), #MONITOR_DEFAULTTOPRIMARY)
            Else
                HPRIMIRY = MonitorFromPoint_(WindowID, #MONITOR_DEFAULTTOPRIMARY)
            EndIf       
        EndIf
                
        pti.TITLEBARINFO\cbSize = SizeOf(TITLEBARINFO)
        TitleHeight = pti\rcTitleBar\bottom-pti\rcTitleBar\top        
        
        Define mi.MONITORINFOEXA
        
        mi\cbSize = SizeOf(mi)
        
        If GetMonitorInfo_(HMONITOR, @mi)
            
            If HPRIMIRY = HMONITOR        
                SystemParametersInfo_(#SPI_GETWORKAREA, 0, @Taskbar.RECT, 0)
        
                If  ( SHAppBarMessage_(#ABM_GETSTATE,tb) = 0 )
                    If ( GetTaskbarHeight = #False )
                        MoveWindow_(WindowID(WindowID),Taskbar\left,Taskbar\top,Taskbar\right-Taskbar\left,Taskbar\bottom-Taskbar\top,1)
                    Else    
                        ProcedureReturn Taskbar\bottom-Taskbar\top
                    EndIf    
                EndIf  
            EndIf
         EndIf
           
     EndProcedure
     
  ;====================================================================================================================
  ;
  ; Get Monitor Info
  ;____________________________________________________________________________________________________________________      
   Procedure.s MonitorInfo_DisplayName()
       
        
        Define mi.MONITORINFOEXA
        Define pt.Point
        
        If GetCursorPos_(@pt)
            HMONITOR = MonitorFromPoint_(PeekQ(@pt), #MONITOR_DEFAULTTONEAREST)
            If IsWindow(WindowID)
                HPRIMIRY = MonitorFromPoint_(WindowID(WindowID), #MONITOR_DEFAULTTOPRIMARY)
            Else
                HPRIMIRY = MonitorFromPoint_(WindowID, #MONITOR_DEFAULTTOPRIMARY)
            EndIf       
        EndIf        
        
        mi\cbSize = SizeOf(mi)
        If GetMonitorInfo_(HMONITOR, @mi)
            ProcedureReturn mi\szDevice
        EndIf
    EndProcedure 
    
   Procedure.l MonitorInfo_Display_Size(GetHeight.i = #False, GetWidth.i = #False)
        
        For k=0 To ExamineDesktops()-1
            If ( MonitorInfo_DisplayName() = DesktopName(k) )
                If ( GetHeight = #True ) And ( GetWidth = #False )                
                    ProcedureReturn DesktopHeight(k)
                    
                ElseIf  ( GetHeight = #False ) And ( GetWidth = #True ) 
                    ProcedureReturn DesktopWidth(k)                    
                    
                EndIf
                Break:
            EndIf
        Next   
   EndProcedure     
   Procedure.l MonitorInfo_Display_Depth()
                
        For k=0 To ExamineDesktops()-1
            If MonitorInfo_DisplayName() = DesktopName(k)
                If ( Height = #True ) And ( Width = #False )                
                    ProcedureReturn DesktopDepth(k)                   
                EndIf
                Break:
            EndIf
       Next         
   EndProcedure    
   Procedure.l MonitorInfo_Display_Freq()
                
        For k=0 To ExamineDesktops()-1
            If MonitorInfo_DisplayName() = DesktopName(k)
                If ( Height = #True ) And ( Width = #False )                
                    ProcedureReturn DesktopFrequency(k)                   
                EndIf
                Break:
            EndIf
        Next        
    EndProcedure         
   Procedure.l MonitorInfo_Display_GetPrimary(WindowID = -1)
    	
        Define mi.MONITORINFOEXA
        Define pt.Point
        
        If GetCursorPos_(@pt)
            HMONITOR = MonitorFromPoint_(PeekQ(@pt), #MONITOR_DEFAULTTONEAREST)
            If IsWindow(WindowID)
                HPRIMIRY = MonitorFromPoint_(WindowID(WindowID), #MONITOR_DEFAULTTOPRIMARY)
            Else
                HPRIMIRY = MonitorFromPoint_(WindowID, #MONITOR_DEFAULTTOPRIMARY)
            EndIf       
        EndIf        
        
        mi\cbSize = SizeOf(mi)
        If GetMonitorInfo_(HMONITOR, @mi)
            ProcedureReturn HMONITOR
        EndIf
   	
    	
   EndProcedure 	
EndModule
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CompilerIf #PB_Compiler_IsMainFile
Debug DesktopEX::GetTime()    

DesktopEX::GetWindowPosition("C:\bginfo\WindowLog.db")
DesktopEX::MinWindow()
MessageRequester("Windows Minimize Demo",#CRLF$+"Restore My System")
;RequestEX::MSG("", "Windows Minimize Demo", #CRLF$+"Restore My System",0,0,"",2)
DesktopEX::ResWindowPosition("C:\WindowLog.db")

DesktopEX::CloseTaskbar() 
MessageRequester("Task Bar Demo", #CRLF$+"Restore My System")
;RequestEX::MSG("", "Task Bar Demo", #CRLF$+"Restore My System",0,0,"",2,"",1)
DesktopEX::StartTaskbar()

DesktopEX::CloseExplorer()
MessageRequester("Explorer Demo", #CRLF$+"Restore My System")
;RequestEX::MSG("", "Explorer Demo", #CRLF$+"Restore My System",0,0,"",2,"",1)
DesktopEX::StartExplorer()
CompilerEndIf


; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 10
; FirstLine = 10
; Folding = HAAA+
; EnableAsm
; EnableXP
; Executable = Test_Explorer_Ex.exe