DeclareModule vSystem
    
    
    Declare     System_Set_Priority(szTaskName.s = "", PriorityClass.l = #NORMAL_PRIORITY_CLASS)
    Declare     System_MemoryFree(szTaskName.s = "")
    Declare     System_SetAffinity(szTaskName.s, uCores = -1)
    Declare     System_NoBorder(szTaskName.s = "")
    
    Declare.i   System_GetCurrentMemoryUsage()
    Declare.i   System_GetMemoryUsage(ProcID)
    
    Declare     System_Compat_MenuItemW(MenuID)    
    Declare     System_Compat_MenuItemE(MenuID)
    
    Declare.i   System_CheckInstance()
    
    Declare.s   System_InfoToolTip()
    
EndDeclareModule

Module vSystem
    
    Global bNBSet.i = #False
    ;    
    ; Holt die Liste der Tasks
    ; 
    Procedure.i System_TaskList( List P32.PROCESSENTRY32() )
        
        #PROCESS32LIB         = 9999
        
        Structure PROCESS_BASIC_INFORMATION
            ExitStatus.i
            PebBaseAddress.i
            AffinityMask.i
            BasePriority.i
            UniqueProcessId.i
            InheritedFromUniqueProcessId.i
        EndStructure 
        
        Protected pbi.PROCESS_BASIC_INFORMATION, SnapShot
        
        If OpenLibrary (#PROCESS32LIB, "kernel32.dll")
            SnapShot = CallFunction (#PROCESS32LIB, "CreateToolhelp32Snapshot", #TH32CS_SNAPPROCESS, 0)
            
            If (SnapShot)
                
                Define.PROCESSENTRY32 Proc32
                
                Proc32\dwSize = SizeOf (PROCESSENTRY32)  
                
                If CallFunction (#PROCESS32LIB, "Process32First", SnapShot, @Proc32)
                    
                    AddElement(P32())
                    
                    CopyMemory (@Proc32, @P32 (), SizeOf(PROCESSENTRY32))
                    
                    While CallFunction (#PROCESS32LIB, "Process32Next", SnapShot, @Proc32)
                        
                        AddElement (P32())
                        
                        CopyMemory (@Proc32, @P32(), SizeOf(PROCESSENTRY32))                                               
                    Wend
                    
                EndIf
                CloseHandle_(SnapShot)
            EndIf
            
            CloseLibrary (#PROCESS32LIB)
        EndIf           
              
    EndProcedure 
    ;
    ;
    ;    
    Procedure   System_Get_Priority(szTaskName.s, uPID.l)
        
        Protected HiProcess.i
        
        HiProcess = OpenProcess_(#PROCESS_QUERY_INFORMATION| #PROCESS_VM_READ, 0, uPID)
        If ( HiProcess )
            Select GetPriorityClass_( HiProcess )
                Case #IDLE_PRIORITY_CLASS         :Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Niedrig"
                Case #BELOW_NORMAL_PRIORITY_CLASS :Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Niedriger als normal"
                Case #NORMAL_PRIORITY_CLASS       :Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Normal"
                Case #ABOVE_NORMAL_PRIORITY_CLASS :Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Höher als normal"
                Case #HIGH_PRIORITY_CLASS         :Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Hoch"
                Case #REALTIME_PRIORITY_CLASS     :Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Echtzeit"
            EndSelect 
            CloseHandle_( HiProcess )            
        EndIf
        
    EndProcedure
    ;
    ;
    ;
    Procedure   System_Set_Priority(szTaskName.s = "", PriorityClass.l = #NORMAL_PRIORITY_CLASS)
        
        Protected uPID.l, HiProcess.l
        ;
        ; Setz und Holt sich die PriorityClass vom Fremden programm
        NewList PrioRity.PROCESSENTRY32()        
        
        System_TaskList( PrioRity() ) 
        
        ResetList( PrioRity() )
                
        If ( szTaskName )              

            
            While NextElement( PrioRity() )                
                If ( LCase( szTaskName ) = LCase( PeekS( @PrioRity()\szExeFile, 255, #PB_UTF8) ) )
                    
                    Debug ""
                    Debug "Priorität für " + szTaskName
                    Debug " - ProcessID: " + Str( PeekL (@PrioRity()\th32ProcessID) )
                    
                    uPID = PeekL (@PrioRity()\th32ProcessID) 
                    
                    System_Get_Priority(szTaskName + " = ", uPID )
                    
                    HiProcess = OpenProcess_(#PROCESS_SET_INFORMATION, 0, uPID)
                    If ( HiProcess )
                        SetPriorityClass_( HiProcess , PriorityClass)
                        CloseHandle_( HiProcess )  

                    EndIf
                    
                    System_Get_Priority(szTaskName + " > ", uPID )
             
                    Break
                EndIf                    
            Wend    
        EndIf

        ClearList( PrioRity() )

    EndProcedure
    ;
    ;
    ;
    Procedure.i System_Get_CPUCores()
            
        Protected SI.SYSTEM_INFO, NumberOfProcessors.i
        
        GetSystemInfo_(@SI)
        NumberOfProcessors = SI\dwNumberOfProcessors
        
        ProcedureReturn NumberOfProcessors
    EndProcedure
    ;
    ; Holt sich die Anzahl der Cpu Cores
    ;
    Procedure.i System_SetAffinity_Cores(PID.i,_CpuAffinityMask.i)
        
        Protected CustomAffinity.q = (1 << _CpuAffinityMask) - 1
        Protected Result.l
                
        If (_CpuAffinityMask = 64)
            ;
            ; Zuviele ? ...
             CustomAffinity = -1
        EndIf        
        
        Result = OpenProcess_(#PROCESS_SET_INFORMATION, #False, PID)
        If ( Result )
            SetProcessAffinityMask_(Result, CustomAffinity)
            CloseHandle_(Result)
        EndIf
        
    EndProcedure 
    ;
    ; Setzt und forciert die CPU Affinity
    ;
    Procedure   System_SetAffinity(szTaskName.s, uCores = -1)
        
        NewList Process32.PROCESSENTRY32()
        
        System_TaskList( Process32() ) 
        
        ResetList( Process32() )
        
        If ( szTaskName )  
            While NextElement( Process32() )
                
                If ( LCase( szTaskName ) = LCase( PeekS( @Process32()\szExeFile, 255, #PB_UTF8) ) )
                    If ( uCores = -1)
                        System_SetAffinity_Cores(PeekL (@Process32()\th32ProcessID), System_Get_CPUCores() )
                    Else
                        System_SetAffinity_Cores(PeekL (@Process32()\th32ProcessID), uCores )
                    EndIf
                    
                    Break;
                EndIf    

            Wend    
        EndIf
        
        ClearList( Process32() )
    EndProcedure     
    ;
    ;
    ;
    Procedure   System_MemoryFree_Debug( List P32.PROCESSENTRY32(), szTaskname.s, PHandle.l, Result.i, Pid.l)
        
        Debug "Free Ram : " + LSet(szTaskname,27,Chr( 32) )+ #TAB$ +
              " | Handle  : " + Str( PHandle)              + #TAB$ + 
              " | Result  : " + Str( Result )              +
              " | PID     : " + Str( PeekL (@P32()\th32ProcessID )) + #TAB$ + 
              " | Threads : " + Str( P32()\cntThreads)     + #TAB$ +
              " | Usage   : " + Str( P32()\cntUsage)       + #TAB$ +
              " | dwSize  : " + Str( P32()\dwSize)         + #TAB$ +
              " | Parent  : " + Str( PeekL (@P32()\th32ParentProcessID ))             
    EndProcedure     
    ;
    ;
    ;
    Procedure   System_MemorySetWorker( List P32.PROCESSENTRY32(), szTaskname.s)
                
        Protected RealProcessID.i, PHandle.i, Result.i, ParentProcess.i, PageDefault.i = -1
        
        If ( Startup::*LHGameDB\Settings_Schwelle > 0 )
            PageDefault = 1048576
            Debug "System Memory Free: Schwellenwert (Bytes) Minimum: " + Str( PageDefault ) + " - Maxmimum: "+ Str( Startup::*LHGameDB\Settings_Schwelle )
        Else
            Debug "System Memory Free: Vollständig Clear Memory Cache)"
        EndIf   
        
                
        RealProcessID = PeekL (@P32()\th32ProcessID)
                             
        PHandle = OpenProcess_(#PROCESS_ALL_ACCESS, #False, RealProcessID)
        
      If ( PHandle )
        Result  = SetProcessWorkingSetSize_(PHandle,PageDefault,Startup::*LHGameDB\Settings_Schwelle)
        
        If ( Result )            
            System_MemoryFree_Debug( P32(), szTaskname.s, PHandle, Result.i, RealProcessID)         
        Else
            
            ParentProcess = PeekL (@P32()\th32ParentProcessID)
            If ( ParentProcess )
                
                PHandle = OpenProcess_(#PROCESS_ALL_ACCESS, #False, ParentProcess)
                If ( PHandle )
                    
                    Result  = SetProcessWorkingSetSize_(PHandle,PageDefault,Startup::*LHGameDB\Settings_Schwelle)
            
                    If ( Result )
                        System_MemoryFree_Debug( P32(), szTaskname.s + " (Parent)", PHandle, Result.i, RealProcessID) 
                    EndIf                             
                EndIf    
            EndIf 
         EndIf
     EndIf   
    EndProcedure    
    ;
    ; Memory Manager
    ; Cona Exiles oder Das Devkit verbrauchen krass Speicher. Dieser wird
    ; beim Absturz oder sinstiges nicht wirklich geleert
    ;
    Procedure   System_MemoryFree(szTaskName.s = "")                
        
        Debug ""
        Debug "System Memory Free:" 
        
        ;GlobalMemoryStatus_(Memory.MEMORYSTATUS)
        ;GlobalFree_        (Memory\dwAvailPhys)
        ;GlobalFree_        (Memory\dwAvailVirtual)
        ;GlobalFree_        (Memory\dwAvailPageFile) 
        
        Debug "System Memory Free #1:" 
        NewList Process32.PROCESSENTRY32()
        
        System_TaskList( Process32() )
        Debug "System Memory Free #2:"         
        
        ResetList( Process32() )
        Debug "System Memory Free #3:"         
        If ( szTaskName )           
            Debug "System Memory Free #4:" 
            While NextElement( Process32() )
                
                If ( LCase( szTaskName ) = LCase( PeekS( @Process32()\szExeFile, 255, #PB_UTF8) ) )                    
                    Debug "System Memory Free #6:" 
                    System_MemorySetWorker( Process32(), szTaskName )                      
                    Break                      
                EndIf    
                Delay(5)
            Wend                                            
        Else                        
            Debug "System Memory Free #5:" 
            While NextElement( Process32() )
                
                szTaskName = PeekS( @Process32()\szExeFile, 255, #PB_UTF8)
                
                If ( szTaskName )                     
                    Debug "System Memory Free #7:" 
                    System_MemorySetWorker( Process32(), szTaskName ) 
                    Break
                EndIf   
                Delay(5)
            Wend
        EndIf        
        Debug "System Memory Free #8:" 
        ClearList( Process32() )
        Debug "System Memory Free #9:" 
    EndProcedure
    
    ;
    ;
    ; Eigenen/ Fremdem Speicherverbrauch Lesen
    ;    
    Prototype.i GetProcessMemoryInfo( hProcess.i, *ppsmemCounters.PROCESS_MEMORY_COUNTERS, cb.i)
    Procedure.i GetProcessMemoryUsage(processid)
        
        Protected Result.i
        Protected PMC.PROCESS_MEMORY_COUNTERS
        Protected GetProcessMemoryInfo.GetProcessMemoryInfo

        Protected lib_psapi = OpenLibrary(#PB_Any, "psapi.dll")
        
        If lib_psapi
            GetProcessMemoryInfo.GetProcessMemoryInfo = GetFunction(lib_psapi,"GetProcessMemoryInfo")
            If GetProcessMemoryInfo(GetCurrentProcess_(), @PMC, SizeOf(PROCESS_MEMORY_COUNTERS))
                Result = PMC\WorkingSetSize   
            EndIf
            CloseLibrary(lib_psapi)   
        EndIf
   
        ProcedureReturn Result
    EndProcedure 

    Procedure.i System_GetCurrentMemoryUsage()
        ;
        ; Eigenen Speicherverbrauch
      ProcedureReturn GetProcessMemoryUsage(GetCurrentProcess_())
    EndProcedure
  
    Procedure.i System_GetMemoryUsage(ProcID)
        ;
        ; Frender Speicherverbrauchm
      ProcedureReturn GetProcessMemoryUsage(ProcID)
    EndProcedure  
    ;
    ;
    ;

    Procedure   _NoBorder_Debug( List P32.PROCESSENTRY32(), szTaskname.s, PHandle.l)
        
        Debug "NoBorderDBG: " + LSet(szTaskname,27,Chr( 32) )+ #TAB$ +
              " | Handle  : " + Str( PHandle)              + #TAB$ +           
              " | PID     : " + Str( PeekL (@P32()\th32ProcessID )) + #TAB$ + 
              " | Threads : " + Str( P32()\cntThreads)     + #TAB$ +
              " | Usage   : " + Str( P32()\cntUsage)       + #TAB$ +
              " | dwSize  : " + Str( P32()\dwSize)         + #TAB$ +
              " | Parent  : " + Str( PeekL (@P32()\th32ParentProcessID ))  + #TAB$ +
              " | E.MEM   : " + Str( System_GetCurrentMemoryUsage() ) + " >= 10485760 "
    EndProcedure    
    ;
    ;
    ; Patch to Remove Border from Window
    ;
    Procedure   _NoBorder_(hwnd)
        
        Protected Taskbar.RECT, Window.RECT, Client.RECT, W.i, H.i, TitleBarH.i, Border.i, CxEdge.i, ClientRect.RECT 
        
        If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_BORDER ) Or ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_DLGFRAME )
                       
            
            GetClientRect_(hwnd, @Client);
            GetWindowRect_(hwnd, @Window) 
            
            
            W = Window\right - Window\left
            H = Window\bottom - Window\top            
            
           CY_C = GetSystemMetrics_(#SM_CYCAPTION)
           CX_B = GetSystemMetrics_(#SM_CXBORDER) *2  ;(2)
           Cx_E = GetSystemMetrics_(#SM_CXEDGE) *2    ;(4)
           
           Debug "-- Client \Links  :" + Str(Client\left )
           Debug "-- Client \Rechts :" + Str(Client\right )
           Debug "-- Client \Oben   :" + Str(Client\Top )           
           Debug "-- Client \Unten  :" + Str(Client\bottom )
           
           Debug "-- Window \Links  :" + Str(Window\left )
           Debug "-- Window \Rechts :" + Str(Window\right )
           Debug "-- Window \Oben   :" + Str(Window\Top )           
           Debug "-- Window \Unten  :" + Str(Window\bottom )
           
           Debug "-- System Metrics #SM_C Y CAPTION: "+ Str( CY_C )
           Debug "-- System Metrics #SM_C X BORDER : "+ Str( CX_B )
           Debug "-- System Metrics #SM_C X EDGE   : "+ Str( Cx_E )
           
           If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_BORDER )
                SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_BORDER)               
                Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_BORDER"
            EndIf    
                
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_DLGFRAME )
                SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_DLGFRAME)
                Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_DLGFRAME"
            EndIf    
            
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_OVERLAPPED)
                SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_OVERLAPPED)                
                Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPED"
            EndIf  
            
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_OVERLAPPEDWINDOW)                                
                Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPEDWINDOW"
                
                If ( Startup::*LHGameDB\Settings_OvLapped = #True )                   
                    SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_OVERLAPPEDWINDOW)   
                    Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPEDWINDOW < Entfernt"
                EndIf 
                
            EndIf             
            
            MoveWindow_(hwnd, Window\left, Window\top - CY_C +  ( CY_C + CX_B + Cx_E) - ( CX_B + Cx_E), W - ( Cx_E + CX_B),H - ( CY_C + CX_B + Cx_E) , 1)
            
            If ( Startup::*LHGameDB\Settings_NBCenter = #True )
                SetWindowPos_(hwnd, #HWND_TOPMOST, 0,0,0,0, #SWP_NOMOVE | #SWP_NOSIZE| #SW_HIDE)
                               
                WinGuru::Center(hwnd,Client\right-1,Client\bottom-1)
                ShowWindow_(hwnd, 5)
                EnableWindow_(hwnd, #True)
                SendMessage_(hwnd, #WM_UPDATEUISTATE, $30002,0)
                                                
            Else    
                SetWindowPos_(hwnd, #HWND_TOPMOST, 0,0,0,0, #SWP_NOMOVE | #SWP_NOSIZE)
                EnableWindow_(hwnd, #True)
                SendMessage_(hwnd, #WM_UPDATEUISTATE, $30002,0)
                              
            EndIf                        
            ProcedureReturn 
        EndIf
        
        
        FGW.l=GetForegroundWindow_()         
        If ( Startup::*LHGameDB\Settings_LokMouse = #True ) And ( hwnd = FGW )
            
                Protected Current.rect
            
                Debug "- Maus Begrent bewegen für handle: " + Str(hwnd)                         
                Debug "- Fenster/ Screen Aktiv          : " + Str(FGW)   
                
                GetWindowRect_(hwnd,Current)    
                
                Debug "-- Client \Links  :" + Str(Current\left )
                Debug "-- Client \Rechts :" + Str(Current\right )
                Debug "-- Client \Oben   :" + Str(Current\Top )           
                Debug "-- Client \Unten  :" + Str(Current\bottom ) 
                
                Current\left = Current\left   + 2
                Current\right = Current\right - 1                
                
                ClipCursor_(Current)  
                
         Else
                Debug "- Fenster/ Screen Nicht fokussiert!!" + Str(FGW)   
         EndIf  
        
        Debug "- Handle " + Str(hwnd) + " Besitzt: Keine Merkmale zum Patchen"  
            
       ;     GetClientRect_(hwnd, @Clent);
       ;     GetWindowRect_(hwnd, @Window)
            
       ;     W = Window\right - Window\left
       ;     H = Window\bottom - Window\top
            
       ;     If ( BorderAutoXY = 0 )
       ;         Window\left = BorderX                                                
       ;         Window\top = BorderY                     
       ;     EndIf    
            
      ;      If ( BorderW.i <> 0)
      ;          W = Window\right - Window\left
      ;      EndIf                   
            
      ;      If ( BorderH.i <> 0)
      ;          H = Window\bottom - Window\top
      ;      EndIf            
            
      ;      If ( BorderAutoXY <> 0 )
      ;          TitleBarH = GetSystemMetrics_(#SM_CYCAPTION)
      ;          Border    = GetSystemMetrics_(#SM_CXBORDER) *2  ;(2)
      ;          CxEdge    = GetSystemMetrics_(#SM_CXEDGE) *2    ;(4)
      ;      EndIf
            
            
      ;      If ( HideTheWindow = 1 )
      ;          ShowWindow_(hwnd,HideFlag)   
      ;      EndIf    
            
      ;      MoveWindow_(hwnd, Window\left,  Window\top - TitleBarH +  ( TitleBarH + Border + CxEdge) - ( Border + CxEdge), W - ( CxEdge + Border),H - ( TitleBarH + Border + CxEdge) ,1)
            
      ;      SetWindowLongPtr_(hwnd,#GWL_STYLE,GetWindowLongPtr_(hwnd,#GWL_STYLE)&~(#WS_DLGFRAME|#WS_CAPTION | #WS_THICKFRAME | #WS_MINIMIZE | #WS_MAXIMIZE | #WS_SYSMENU))
      ;      SetWindowLongPtr_(hwnd,#GWL_EXSTYLE,GetWindowLongPtr_(hwnd,#GWL_EXSTYLE)&~(#WS_EX_DLGMODALFRAME | #WS_EX_CLIENTEDGE | #WS_EX_STATICEDGE))                      
                        
            
      ;      Select WindowTop
      ;          Case 0: WindowTop = #HWND_TOP
      ;          Case 1: WindowTop = #HWND_TOPMOST    
      ;      EndSelect             
            
      ;      SetWindowPos_(hwnd, WindowTop, 0,0,0,0, #SWP_NOMOVE | #SWP_NOSIZE)
            ;
            ; Neu, Nicht für Half Life
                    
      ;      GetWindowRect_(hwnd, @ClientRect) 
      ;      ClientPoint.POINT 
      ;      ClientToScreen_(hwnd, @ClientPoint)             
      ;      WinGuru::Center(hwnd.l,ClientRect\right,ClientRect\bottom)
             
      ;      If ( HideTheWindow = 1 )
      ;          ShowWindow_(ProgWindow,ViewFlag)
      ;      EndIf             
      ;  Else
            ;Debug "Fensterrahmen: Nein"
      ;  EndIf
                
    EndProcedure  
    ;
    ;
    ;   Enumerate Windows for NoBorder        
    Procedure   System_EnumWindows(hWnd, ProcessID.l)
        
        Protected  sWindowTitle.s = "", DbgLog.s = "", fHandle.i, ExtProcessID.l
        
        If IsWindowVisible_(hWnd)
                           
            *Buffer   = AllocateMemory( 4096 )
            
            length.i  = GetWindowTextLength_(hWnd) + 1;
            If ( length > 1 )
                                               
                If ( length > *Buffer )                
                    *Buffer = ReAllocateMemory( *Buffer, length + 1 )
                EndIf    
                               
                If ( length > 1 ) And ( *Buffer > 1)
                                       
                    GetWindowText_(hwnd,*Buffer,length)
                                    
                    sWindowTitle = PeekS(*Buffer)
    
                    If ( sWindowTitle )
                        
                        fHandle = FindWindow_(@sWindowTitle,#Null)
                        
                        GetWindowThreadProcessId_(hwnd, @ExtProcessID)                                                                       
                        
                        DbgLog = ""
                        DbgLog + "(SEARCH )" + #TAB$ +                                   
                        DbgLog.s + "   PID Search: " + RSet( Str( ProcessID   ), 7,Chr(32) )  + #TAB$ +
                        DbgLog.s + " | PID Found : " + RSet( Str( ExtProcessID), 7,Chr(32) )  + #TAB$ +
                        DbgLog.s + " | CurrHandle: " + RSet( Str( fHandle     ), 7,Chr(32) )  + #TAB$ +
                        DbgLog.s + " | FindHandle: " + RSet( Str( hwnd        ), 7,Chr(32) )  + #TAB$ +                                   
                        DbgLog.s + " | WindowText: " + Chr(34) + sWindowTitle + Chr(34) + #CR$                                          

                        
                        If ( ExtProcessID = ProcessID )
                            
                                DbgLog = ""  + #CR$       
                                DbgLog + "(FOUNDED)" + #TAB$ +   
                                DbgLog.s + "   PID Search: " + RSet( Str( ProcessID    ), 7,Chr(32) )  + #TAB$ +
                                DbgLog.s + " | PID Found : " + RSet( Str( ExtProcessID ), 7,Chr(32) )  + #TAB$ +
                                DbgLog.s + " | CurrHandle: " + RSet( Str( fHandle      ), 7,Chr(32) )  + #TAB$ +
                                DbgLog.s + " | FindHandle: " + RSet( Str( hwnd         ), 7,Chr(32) )  + #TAB$ + 
                                DbgLog.s + " | Own Handle: " + RSet( Str( GetForegroundWindow_() ), 7,Chr(32) )  + #TAB$ +                                              
                                DbgLog.s + " | WindowText: " + Chr(34) + sWindowTitle + Chr(34) + #CR$                           
                                Debug DbgLog + #CR$
                                                                
                                _NoBorder_(hwnd)                                                                
                                ProcedureReturn #False 
                            EndIf    
                        Else                            
                            Debug DbgLog + #CR$  + #CR$                         
                        EndIf
                     EndIf                                                                                        
                EndIf    
            EndIf
        ProcedureReturn #True       
    EndProcedure
    ;
    ;
    ; Patch Games/Apps to remove Border  
  
    Procedure   System_NoBorder(szTaskName.s = "")   
        
        Startup::*LHGameDB\Thread_ProcessName = szTaskName
        
        Debug ""
        
        Protected uPID.l, HiProcess.l, hwnd.l
                        
            
        ;
        ; Setz und Holt sich die PriorityClass vom Fremden programm
        NewList NoBorderList.PROCESSENTRY32()        
        
        System_TaskList( NoBorderList() ) 
        
        ResetList( NoBorderList() )

        If ( Startup::*LHGameDB\Thread_ProcessName )  
            ForEach NoBorderList()
                
                
                If ( LCase( Startup::*LHGameDB\Thread_ProcessName ) = LCase( PeekS( @NoBorderList()\szExeFile, 255, #PB_UTF8) ) )
                    
                    Debug ""
                    Debug "NoBorder für  : " + Startup::*LHGameDB\Thread_ProcessName
                    Debug "- ProcessID   : " + Str( PeekL (@NoBorderList()\th32ProcessID) )
                    
                    uPID = PeekL (@NoBorderList()\th32ProcessID) 
                                       
                    HiProcess = OpenProcess_(#PROCESS_SET_INFORMATION, 0, uPID)
                    If ( HiProcess )            
                        Debug "- TH32 ID List: "                        
                        _NoBorder_Debug( NoBorderList(), Startup::*LHGameDB\Thread_ProcessName, HiProcess)                        
                        EnumWindows_(@System_EnumWindows(),PeekL (@NoBorderList()\th32ProcessID) )
                        ;Debug "TH32ProcessID Parent============ :"
                        ;EnumWindows_(@System_EnumWindows(),PeekL (@NoBorderList()\th32ParentProcessID))
                        
                        ;Debug "HiProcess           ============ :"
                        ;EnumWindows_(@System_EnumWindows(),HiProcess)
                        CloseHandle_( HiProcess ) 
                    EndIf
                    
                                        
                    Break

                EndIf
                Delay( 2 )
            Next    
        EndIf

        ClearList( NoBorderList() )
        
        
    EndProcedure
    
    ;
    ;
    ; Aufruf des Compatibility Mode to the Commandline über dem menu
    Procedure   System_Compat_MenuItemW(MenuID)
        
        Protected sCmdString.s
        
        UseModule Compatibility
        
        ResetList(CompatibilitySystem())                                     
        
        While NextElement(CompatibilitySystem())
            
            Debug "MenuIdx:" + Str( CompatibilitySystem()\MenuIndex) + #TAB$ + LSet( CompatibilitySystem()\OSModus$, 24, Chr(32) ) + "Num: " +  Str( CompatibilitySystem()\OSIDX)
            
            If ( CompatibilitySystem()\MenuIndex = MenuID )
                Debug #CR$ + "Benutze: " + CompatibilitySystem()\OSModus$
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf
                
                If FindString( sCmdString, "%c"+ CompatibilitySystem()\OSModus$, 1) = 0
                    sCmdString + "%c"+CompatibilitySystem()\OSModus$
                EndIf
                SetGadgetText( DC::#String_103 , sCmdString)
                Break
            EndIf    
        Wend        
        
        UnuseModule Compatibility             
        
    EndProcedure 
    
    ;
    ;
    ; Aufruf des Compatibility Mode to the Commandline über dem menu
    Procedure   System_Compat_MenuItemE(MenuID)
        
        Protected sCmdString.s
        
        UseModule Compatibility
        
        ResetList(CompatibilityEmulation())                                     
        
        While NextElement(CompatibilityEmulation())
            
            Debug "MenuIdx:" + Str( CompatibilityEmulation()\MenuIndex) + #TAB$ + LSet( CompatibilityEmulation()\Emulation$, 24, Chr(32) ) + "Num: " +  Str( CompatibilityEmulation()\EMUIDX)
            
            If ( CompatibilityEmulation()\MenuIndex = MenuID )
                Debug #CR$ + "Benutze: " + CompatibilityEmulation()\Emulation$
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf
                
                If FindString( sCmdString, "%c"+ CompatibilityEmulation()\Emulation$, 1) = 0
                    sCmdString + "%c"+CompatibilityEmulation()\Emulation$
                EndIf
                SetGadgetText( DC::#String_103 , sCmdString)
                Break
            EndIf    
        Wend        
        
        UnuseModule Compatibility             
        
    EndProcedure    
     
    ;
    ;
    ; Prüfng ob es schon gestartet ist
    Procedure.i   System_CheckInstance()
                
            FileName.s = GetFilePart( ProgramFilename() )            
            sCurPath.s = GetPathPart( ProgramFilename() )  + "Systeme\Data\VSYSDB\_Restart.lck"
            ; VSystems Prüfverfahren          
            If ( FileSize(sCurPath) = 11 )
                DeleteFile(sCurPath,#PB_FileSystem_Force )
                Delay(255)
                System_CheckInstance()
            Else   
            
            
                *a = CreateSemaphore_(0, 0, 1, FileName)
                            
                If ( *a <> 0 ) And ( GetLastError_() = #ERROR_ALREADY_EXISTS )
                    CloseHandle_(*a)                      
                    
                    Request::MSG("", "Programm läuft", "Programm wurde zuvor schon gestartet." + #CR$ + "Pfad: '"+ProgramFilename() , 2, 2, ProgramFilename(), 0, 0, 0)            
                    End             
                EndIf
            EndIf
    EndProcedure
    
    
    ;
    ;
    ; Just for fun  
    Procedure.s GetCPUName()
        Protected sBuffer.s
        Protected Zeiger1.l, Zeiger2.l, Zeiger3.l, Zeiger4.l
 
          !MOV eax, $80000002
          !CPUID
          ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
          !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
          !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
          !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
          !MOV [p.v_Zeiger4], EDX ; move edx to the buffer
         
          ;Now move the content of Zeiger (4*4=16 Bytes to a string
          sBuffer = PeekS(@Zeiger1, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)
         
          ;Second Part of the Name
          !MOV eax, $80000003
          !CPUID
          ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
          !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
          !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
          !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
          !MOV [p.v_Zeiger4], EDX ; move edx to the buffer
         
          ;Now move the content of Zeiger (4*4=16 Bytes to a string
          sBuffer + PeekS(@Zeiger1, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)
         
         
          ;Third Part of the Name
          !MOV eax, $80000004
          !CPUID
          ; the CPU-Name is now stored in EAX-EBX-ECX-EDX
          !MOV [p.v_Zeiger1], EAX ; move eax to the buffer
          !MOV [p.v_Zeiger2], EBX ; move ebx to the buffer
          !MOV [p.v_Zeiger3], ECX ; move ecx to the buffer
          !MOV [p.v_Zeiger4], EDX ; move edx to the buffer
         
          ;Now move the content of Zeiger (4*4=16 Bytes to a string
          sBuffer + PeekS(@Zeiger1, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger2, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger3, 4, #PB_Ascii)
          sBuffer + PeekS(@Zeiger4, 4, #PB_Ascii)
     
      ProcedureReturn Trim(sBuffer)
    EndProcedure

Debug GetCPUName()
    ;
    ;
    ;
    Procedure.s System_Get_Internal_WIN()
        Define OsVersion.OSVERSIONINFO
     
        Arch.s = "";
        
        OsVersion\dwOSVersionInfoSize = SizeOf(OSVERSIONINFO)
        GetVersionEx_(OsVersion.OSVERSIONINFO)
        
        Major.s = Str(OsVersion\dwMajorVersion)
        Minor.s = Str(OsVersion\dwMinorVersion)  
        Build.s = Str(OsVersion\dwBuildNumber)          
        
        Select OSVersion()
        ;   Case #PB_OS_Windows_NT3_51          : Arch = "Windows NT (NT 3.5)"
        ;   Case #PB_OS_Windows_95              : Arch = "Windows'95"
        ;   Case #PB_OS_Windows_NT_4            : Arch = "Windows NT (NT)"
        ;   Case #PB_OS_Windows_98              : Arch = "Windows'98"
        ;   Case #PB_OS_Windows_ME              : Arch = "Windows'98"
            Case #PB_OS_Windows_2000            : Arch = "Windows 2000"
            Case #PB_OS_Windows_XP              : Arch = "Windows XP"
            Case #PB_OS_Windows_Server_2003     : Arch = "Windows Server 2003"
            Case #PB_OS_Windows_Vista           : Arch = "Windows Vista"
            Case #PB_OS_Windows_Server_2008     : Arch = "Windows Server 2008"
            Case #PB_OS_Windows_7               : Arch = "Windows 7"
            Case #PB_OS_Windows_Server_2008_R2  : Arch = "Windows Server 2008R2"
            Case #PB_OS_Windows_8               : Arch = "Windows 8"
            Case #PB_OS_Windows_Server_2012     : Arch = "Windows Server 2012"
            Case #PB_OS_Windows_8_1             : Arch = "Windows 8.1"
            Case #PB_OS_Windows_Server_2012_R2  : Arch = "Windows Server 2012R2"
            Case #PB_OS_Windows_10              : Arch = "Windows 10" : ProcedureReturn Arch
            Case #PB_OS_Windows_Future          : Arch = "Windows 11+": ProcedureReturn Arch
        EndSelect
       
        ProcedureReturn Arch + " (" + Build + ")"
    EndProcedure
    ;
    ;
    ;    
    Procedure.s System_Get_Internal_CPU()
        
        ProcedureReturn "Cores " + Str(CountCPUs(#PB_System_CPUs))
        
    EndProcedure
    ;
    ;
    ;    
    Procedure.s System_Get_Internal_GFX()
        
            Protected device.DISPLAY_DEVICE
            Protected settings.DEVMODE
            
            device\cb = SizeOf(DISPLAY_DEVICE)
            settings\dmSize = SizeOf(DEVMODE)
            
            EnumDisplayDevices_(#Null,#Null,device,#Null)
            ProcedureReturn PeekS(@device\DeviceString,128)
            
    EndProcedure
    ;
    ;
    ;
    Procedure.s   System_Get_Internal_MEM()
               
        Free.s = MathBytes::Bytes2String(MemoryStatus(#PB_System_FreePhysical))
        Total.s= MathBytes::Bytes2String(MemoryStatus(#PB_System_TotalPhysical))

        ProcedureReturn  Total + "  ( " + Free + " available )"
    EndProcedure
    ;
    ;
    ;    
    Procedure.s   System_InfoToolTip()
        
        TooltipString.s = ""
        TooltipString   = Startup::*LHGameDB\TrayIconTitle + Chr(13) + Chr(13) + 
                          "CPU: " + Trim( CPUName() ) + Chr(13) +
                          "CPU: " + System_Get_Internal_CPU() + Chr(13) +                          
                          "GFX: " + System_Get_Internal_GFX() + Chr(13) +      
                          "WIN: " + System_Get_Internal_WIN() + Chr(13) +                          
                          "MEM: " + System_Get_Internal_MEM() + Chr(13) + Chr(13) +  
                          "Developed by Marty Shepard"
        
        Debug TooltipString
        ProcedureReturn TooltipString
    EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 724
; FirstLine = 397
; Folding = 4-T9-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\