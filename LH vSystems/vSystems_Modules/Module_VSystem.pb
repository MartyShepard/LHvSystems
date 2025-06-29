DeclareModule vSystem
    
    
    Declare     System_Set_Priority(szTaskName.s = "", PriorityClass.l = #NORMAL_PRIORITY_CLASS)
    Declare     System_MemoryFree(szTaskName.s = "")
    Declare     System_SetAffinity(szTaskName.s, uCores = -1)
    Declare     System_NoBorder(szTaskName.s = "")
    Declare     System_NoBorder_Handle_Reset()    
    
    Declare.i   System_GetCurrentMemoryUsage()
    Declare.i   System_GetMemoryUsage(ProcID)
    
    Declare     System_MenuItemW_Compat(MenuID)    
    Declare     System_MenuItemE_Compat(MenuID)
    Declare     System_MenuItemC_Unreal(MenuID)    
    Declare     System_MenuItemD_Unity(MenuID)
    Declare     System_MenuItemB_Emulation(MenuID)  
    
    Declare.i   System_CheckInstance()
    
    Declare.s   System_InfoToolTip(LCDInfo.i = #False)
    
    Declare.i   System_ProgrammIsAlive(szTaskName.s)
    Declare.i   System_GetTasklist();
       
    Declare.i   Capture_Screenshot(ProgrammName.s) 
    
    Declare.i   LCD_Info(LCDInfo.i = #False, PrpLoop.i = #False)
    
    Declare.i   Terminate_Programm(*Params)
EndDeclareModule

Module vSystem
    
    Global ShowDebugNB.i = #True       ; Debug Output for NoBorder
    ;
    ; Setz und Holt sich die PriorityClass vom Fremden programm
    Global NewList NoBorderList.PROCESSENTRY32() 
    Global NewList Process32.PROCESSENTRY32()
    ;
    ; SETZ und Holt sich die PriorityClass vom Fremden programm
    Global NewList RunProg.PROCESSENTRY32() 
    ;Global NewList Process32.PROCESSENTRY32()
    ;
    ; Setz und Holt sich die PriorityClass vom Fremden programm
    Global NewList RunProg.PROCESSENTRY32()
    ;
    ; SETZ und Holt sich die PriorityClass vom Fremden programm
    Global NewList PrioRity.PROCESSENTRY32()
    
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
    Procedure.i System_GetTasklist();
        
        ;System_TaskList( PrioRity() )
        ;System_TaskList( RunProg() ) 
        ClearList( Process32() )
        System_TaskList( Process32() ) 
        ;System_TaskList( Process32() )
        ;System_TaskList( NoBorderList() ) 
        
    EndProcedure
    ;
    ;
    ;        
    Procedure   System_Get_Priority(szTaskName.s, uPID.l)
        
        Protected HiProcess.i
        
        HiProcess = OpenProcess_(#PROCESS_QUERY_INFORMATION| #PROCESS_VM_READ, 0, uPID)
        If ( HiProcess )
            Select GetPriorityClass_( HiProcess )
                Case #IDLE_PRIORITY_CLASS         ;:Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Niedrig"
                Case #BELOW_NORMAL_PRIORITY_CLASS ;:Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Niedriger als normal"
                Case #NORMAL_PRIORITY_CLASS       ;:Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Normal"
                Case #ABOVE_NORMAL_PRIORITY_CLASS ;:Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Höher als normal"
                Case #HIGH_PRIORITY_CLASS         ;:Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Hoch"
                Case #REALTIME_PRIORITY_CLASS     ;:Debug "Priorität für " + szTaskName + " : (PID: "+ Str(uPID) +") - Echtzeit"
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
        ; NewList PrioRity.PROCESSENTRY32()        
        
        ; System_TaskList( PrioRity() ) 
        
        ResetList( Process32() )
                
        If ( szTaskName )              

            
            While NextElement( Process32() )                
                If ( LCase( szTaskName ) = LCase( PeekS( @Process32()\szExeFile, 255, #PB_UTF8) ) )
                    
                   ; Debug ""
                   ; Debug "Priorität für " + szTaskName
                   ; Debug " - ProcessID: " + Str( PeekL (@Process32()\th32ProcessID) )
                    
                    uPID = PeekL (@Process32()\th32ProcessID) 
                    
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

       ; ClearList( PrioRity() )

    EndProcedure
    ;
    ;
    ;
    Procedure.i  System_ProgrammIsAlive(szTaskName.s)
        
        Protected bIsAlive.i = #False
        ;
        ; Setz und Holt sich die PriorityClass vom Fremden programm
        ;NewList RunProg.PROCESSENTRY32()        
        
        ;System_TaskList( RunProg() ) 
        
        ResetList( Process32() )
            
        If ( szTaskName )              

            
            While NextElement( Process32() )                
                If ( LCase( szTaskName ) = LCase( PeekS( @Process32()\szExeFile, 255, #PB_UTF8) ) )
                    
                   ; Debug ""
                   ; Debug "Priorität für " + szTaskName
                   ; Debug " - ProcessID: " + Str( PeekL (@Process32()\th32ProcessID) )
                    
                    bIsAlive = #True;
                    Break
                EndIf                    
            Wend    
        EndIf

        ;ClearList( RunProg() )
        
        ProcedureReturn bIsAlive;
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
        
       ; NewList Process32.PROCESSENTRY32()
        
       ; System_TaskList( Process32() ) 
        
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
        
       ; ClearList( Process32() )
    EndProcedure     
    ;
    ;
    ;
    Procedure   System_MemoryFree_Debug( List P32.PROCESSENTRY32(), szTaskname.s, PHandle.l, Result.i, Pid.l)
        
       ; Debug "Free Ram : " + LSet(szTaskname,27,Chr( 32) )+ #TAB$ +
       ;       " | Handle  : " + Str( PHandle)              + #TAB$ + 
       ;       " | Result  : " + Str( Result )              +
       ;       " | PID     : " + Str( PeekL (@P32()\th32ProcessID )) + #TAB$ + 
       ;       " | Threads : " + Str( P32()\cntThreads)     + #TAB$ +
       ;       " | Usage   : " + Str( P32()\cntUsage)       + #TAB$ +
       ;       " | dwSize  : " + Str( P32()\dwSize)         + #TAB$ +
       ;       " | Parent  : " + Str( PeekL (@P32()\th32ParentProcessID ))             
    EndProcedure     
    ;
    ;
    ;
    Procedure   System_MemorySetWorker( List P32.PROCESSENTRY32(), szTaskname.s)
                
        Protected RealProcessID.i, PHandle.i, Result.i, ParentProcess.i, PageDefault.i = -1
        
        If ( Startup::*LHGameDB\Settings_Schwelle > 0 )
            PageDefault = 1048576
           ; Debug "System Memory Free: Schwellenwert (Bytes) Minimum: " + Str( PageDefault ) + " - Maxmimum: "+ Str( Startup::*LHGameDB\Settings_Schwelle )
        Else
           ; Debug "System Memory Free: Vollständig Clear Memory Cache)"
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
        
       ; Debug ""
       ; Debug "System Memory Free:" 
        
        ;GlobalMemoryStatus_(Memory.MEMORYSTATUS)
        ;GlobalFree_        (Memory\dwAvailPhys)
        ;GlobalFree_        (Memory\dwAvailVirtual)
        ;GlobalFree_        (Memory\dwAvailPageFile) 
        
       ; Debug "System Memory Free #1:" 
        NewList Process32.PROCESSENTRY32()
        
        System_TaskList( Process32() )
       ; Debug "System Memory Free #2:"         
        
        ResetList( Process32() )
       ; Debug "System Memory Free #3:"         
        If ( szTaskName )           
        ;    Debug "System Memory Free #4:" 
            While NextElement( Process32() )
                
                If ( LCase( szTaskName ) = LCase( PeekS( @Process32()\szExeFile, 255, #PB_UTF8) ) )                    
         ;           Debug "System Memory Free #6:" 
                    System_MemorySetWorker( Process32(), szTaskName )                      
                    Break                      
                EndIf    
                Delay(5)
            Wend                                            
        Else                        
         ;   Debug "System Memory Free #5:" 
            While NextElement( Process32() )
                
                szTaskName = PeekS( @Process32()\szExeFile, 255, #PB_UTF8)
                
                If ( szTaskName )                     
          ;          Debug "System Memory Free #7:" 
                    System_MemorySetWorker( Process32(), szTaskName ) 
                    Break
                EndIf   
                Delay(5)
            Wend
        EndIf        
        ;Debug "System Memory Free #8:" 
        ClearList( Process32() )
        ;Debug "System Memory Free #9:" 
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
;             Debug "NoBorderDBG: " + LSet(szTaskname,27,Chr( 32) )+ #TAB$ +
;                   " | Handle  : " + Str( PHandle)              + #TAB$ +           
;                   " | PID     : " + Str( PeekL (@P32()\th32ProcessID )) + #TAB$ + 
;                   " | Threads : " + Str( P32()\cntThreads)     + #TAB$ +
;                   " | Usage   : " + Str( P32()\cntUsage)       + #TAB$ +
;                   " | dwSize  : " + Str( P32()\dwSize)         + #TAB$ +
;                   " | Parent  : " + Str( PeekL (@P32()\th32ParentProcessID ))  + #TAB$ +
;                   " | E.MEM   : " + Str( System_GetCurrentMemoryUsage() ) + " >= 10485760 "
    
    EndProcedure    
    ;
    ;
    ; Patch to Remove Border from Window
    ;
    Procedure   _NoBorder_(hwnd)
        
        Protected Taskbar.RECT, Window.RECT, Client.RECT, W.i, H.i, TitleBarH.i, Border.i, CxEdge.i, ClientRect.RECT , Desktop.RECT
        
        GetClientRect_(hwnd, @Client); Ohne Fenster Rahmen
        GetWindowRect_(hwnd, @Window); Mit Fensteer Rahmen
        
        Startup::*LHGameDB\NBWindowhwnd = hwnd;
        Startup::*LHGameDB\NBWindow =  Window.RECT;
        Startup::*LHGameDB\NBClient =  Client.RECT;            
        
        
        If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_BORDER ) Or ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_DLGFRAME )
            
            ;ShowWindow_(hwnd, #SW_SHOWNOACTIVATE);
            
            ; GetWindowRect - gibt ein Rechteck IN Bildschirmkoordinaten zurück, während
            ; GetClientRect ein Rechteck IN Clientkoordinaten zurückgibt.
            
            ; InvalidateRect erhält ein Rect IN Clientkoordinaten. Wenn Sie Ihren gesamten
            ; Clientbereich ungültig machen möchten, übergeben Sie NULL an InvalidateRect.
            ; Sie könnten DAS von GetClientRect zurückgegebene Rect übergeben, aber es ist;
            ; viel einfacher und klarer, NULL zu übergeben.   
            
            W = Window\right - Window\left
            H = Window\bottom - Window\top            
            
            If ( Startup::*LHGameDB\Settings_GetSmtrc = #True )
                CY_C = GetSystemMetrics_(#SM_CYCAPTION)
                CX_B = GetSystemMetrics_(#SM_CXBORDER) *2  ;(2)
                Cx_E = GetSystemMetrics_(#SM_CXEDGE)   *2  ;(4)
            EndIf
            If ( ShowDebugNB = #True)
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
                
                Debug "-- Window\left - Client\left     : " + Str(Window\left - Client\left)
                Debug "-- Window\bottom - Client\bottom : " + Str(Window\bottom - Client\bottom)
            EndIf
            
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_BORDER )
                If ( ShowDebugNB = #True)
                    Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_BORDER"
                EndIf             	
                ;SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_BORDER)
                
                If ( ShowDebugNB = #True)
                	If Not ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_BORDER )
                    Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_BORDER < Entfernt"
                  EndIf  
                 EndIf 
            EndIf    
            
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_DLGFRAME )
                If ( ShowDebugNB = #True)
                    Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_DLGFRAME"
                EndIf            	
                ;SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_DLGFRAME)
                
                If ( ShowDebugNB = #True)
                		If Not ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_DLGFRAME )
                        Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_DLGFRAME < Entfernt"
                    EndIf                	
                EndIf	
                	
            EndIf    
            
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_OVERLAPPED)
                If ( ShowDebugNB = #True)
                    Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPED"
                EndIf            	
                ;SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_OVERLAPPED)                
                
                If ( ShowDebugNB = #True)
                		If Not ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_OVERLAPPED)
                			Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPED < Entfernt"
                		EndIf
                EndIf
            EndIf  
            
            If ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_OVERLAPPEDWINDOW) 
                
                If ( ShowDebugNB = #True)
                    Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPEDWINDOW"
                EndIf
                
                If ( Startup::*LHGameDB\Settings_OvLapped = #True )                   
                	SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd , #GWL_STYLE )&~#WS_OVERLAPPEDWINDOW)   
                	
                	If ( ShowDebugNB = #True)
												If Not ( GetWindowLongPtr_(hwnd,#GWL_STYLE)&#WS_OVERLAPPEDWINDOW)                 		
                        	Debug "- Handle " + Str(hwnd) + " Besitzt: #WS_OVERLAPPEDWINDOW < Entfernt"
                      EndIf
                   EndIf   
                EndIf 
                
            EndIf                                    
            If ( Startup::*LHGameDB\Settings_GetSmtrc = #True)
                MoveWindow_(hwnd, Window\left, Window\top - CY_C +  ( CY_C + CX_B + Cx_E) - ( CX_B + Cx_E), W - ( Cx_E + CX_B),H - ( CY_C + CX_B + Cx_E) , 1)
            EndIf
            
            If ( Startup::*LHGameDB\Settings_NBCenter = #True )
                SetWindowPos_(hwnd, #HWND_TOPMOST, 0, 0, 0, 0, #SWP_NOMOVE | #SWP_NOSIZE| #SW_HIDE|#SWP_FRAMECHANGED)
               
                ;AdjustWindowRectEx_(0,0,0,0)
                
               	  WinGuru::Center(hwnd,Client\right,client\bottom)
                	;Debug "-- Client\right  :" + Str(Client\right)
                	;Debug "-- client\bottom:" + Str(client\bottom)
                	;Debug "Bildschirmauflösung: " +Str (GetSystemMetrics_(#SM_CXSCREEN) )+ "x" +Str(GetSystemMetrics_(#SM_CYSCREEN))
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
            
            If ( ShowDebugNB = #True)
                Debug "- Maus Begrent bewegen für handle: " + Str(hwnd)                         
                Debug "- Fenster/ Screen Aktiv          : " + Str(FGW)   
            EndIf
            GetWindowRect_(hwnd,Current)    
            
            If ( ShowDebugNB = #True)
                Debug "-- Client \Links  :" + Str(Current\left )
                Debug "-- Client \Rechts :" + Str(Current\right )
                Debug "-- Client \Oben   :" + Str(Current\Top )           
                Debug "-- Client \Unten  :" + Str(Current\bottom ) 
            EndIf
            
            Current\left = Current\left   + 2
            Current\right = Current\right - 1                
            
            ClipCursor_(Current)  
            
        Else          
            If ( Startup::*LHGameDB\Settings_LokMouse = #True )
                If ( ShowDebugNB = #True)
                    Debug "- Fenster/ Screen Nicht fokussiert!!" + Str(FGW)                       
                EndIf    
            EndIf
        EndIf                  
        
        If ( ShowDebugNB = #True)
           ; Debug "- Handle " + Str(hwnd) + " Besitzt: Keine Merkmale zum Patchen"  
        EndIf                                
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
;                         If ( ShowDebugNB = #True)
;                                     DbgLog = ""
;                                     DbgLog + "(SEARCH )" + #TAB$ +                                   
;                                      DbgLog.s + "   PID Search: " + RSet( Str( ProcessID   ), 7,Chr(32) )  + #TAB$ +
;                                      DbgLog.s + " | PID Found : " + RSet( Str( ExtProcessID), 7,Chr(32) )  + #TAB$ +
;                                      DbgLog.s + " | CurrHandle: " + RSet( Str( fHandle     ), 7,Chr(32) )  + #TAB$ +
;                                      DbgLog.s + " | FindHandle: " + RSet( Str( hwnd        ), 7,Chr(32) )  + #TAB$ +                                   
;                                      DbgLog.s + " | WindowText: " + Chr(34) + sWindowTitle + Chr(34) + #CR$                                          
;                         EndIf
                        
                        If ( ExtProcessID = ProcessID )
                            
;                             If ( ShowDebugNB = #True)
;                                         DbgLog = ""  + #CR$       
;                                         DbgLog + "(FOUNDED)" + #TAB$ +   
;                                          DbgLog.s + "   PID Search: " + RSet( Str( ProcessID    ), 7,Chr(32) )  + #TAB$ +
;                                          DbgLog.s + " | PID Found : " + RSet( Str( ExtProcessID ), 7,Chr(32) )  + #TAB$ +
;                                          DbgLog.s + " | CurrHandle: " + RSet( Str( fHandle      ), 7,Chr(32) )  + #TAB$ +
;                                          DbgLog.s + " | FindHandle: " + RSet( Str( hwnd         ), 7,Chr(32) )  + #TAB$ + 
;                                          DbgLog.s + " | Own Handle: " + RSet( Str( GetForegroundWindow_() ), 7,Chr(32) )  + #TAB$ +                                              
;                                          DbgLog.s + " | WindowText: " + Chr(34) + sWindowTitle + Chr(34) + #CR$                           
;                                 Debug DbgLog + #CR$
;                             EndIf                                    
                            _NoBorder_(hwnd)                              
                            Startup::*LHGameDB\Thread_ProcessId = ExtProcessID
                            ProcedureReturn #False 
                        EndIf    
                        
                    Else                            
                        If ( ShowDebugNB = #True)                        
                            Debug DbgLog + #CR$  + #CR$                         
                        EndIf    
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
        
        Protected uPID.l, HiProcess.l, hwnd.l
                        
             
        ;
        ; Setz und Holt sich die PriorityClass vom Fremden programm
        ; NewList NoBorderList.PROCESSENTRY32()        
        
        ; System_TaskList( NoBorderList() ) 
        
        ResetList( Process32() )

        If ( Startup::*LHGameDB\Thread_ProcessName )  
            ForEach Process32()
                If ( LCase( Startup::*LHGameDB\Thread_ProcessName ) = LCase( PeekS( @Process32()\szExeFile, 255, #PB_UTF8) ) )
                   
                   ; Debug ""
                   ; Debug "NoBorder für  : " + Startup::*LHGameDB\Thread_ProcessName
                   ; Debug "- ProcessID   : " + Str( PeekL (@Process32()\th32ProcessID) )
                    
                    uPID = PeekL (@Process32()\th32ProcessID) 
                                       
                    HiProcess = OpenProcess_(#PROCESS_SET_INFORMATION, 0, uPID)
                    If ( HiProcess )                                    
                        If ( ShowDebugNB = #True)
                            _NoBorder_Debug( Process32(), Startup::*LHGameDB\Thread_ProcessName, HiProcess)                        
                        EndIf    
                        EnumWindows_(@System_EnumWindows(),PeekL (@Process32()\th32ProcessID) )
                        ;Debug "TH32ProcessID Parent============ :"
                        ;EnumWindows_(@System_EnumWindows(),PeekL (@NoBorderList()\th32ParentProcessID))
                        
                        ;Debug "HiProcess           ============ :"
                        ;EnumWindows_(@System_EnumWindows(),HiProcess)
                        CloseHandle_( HiProcess ) 
                        Break
                    EndIf                                   
                EndIf
                ;Delay( 2 )
            Next    
        EndIf

       ; ClearList( NoBorderList() )
        
        
    EndProcedure
    
    Procedure   System_NoBorder_Handle_Reset()
            Startup::*LHGameDB\NBWindowhwnd   = 0;
            
            Startup::*LHGameDB\NBWindow\left  = 0;
            Startup::*LHGameDB\NBWindow\top   = 0;
            Startup::*LHGameDB\NBWindow\right = 0;
            Startup::*LHGameDB\NBWindow\bottom= 0;            
            
            Startup::*LHGameDB\NBClient\left  = 0;
            Startup::*LHGameDB\NBClient\top   = 0;
            Startup::*LHGameDB\NBClient\right = 0;
            Startup::*LHGameDB\NBClient\bottom= 0;
    EndProcedure
    
   Procedure.i Caret_SetPosition()
                        
            g.i = GadgetID( DC::#String_103 ): SetActiveGadget(  DC::#String_103 )  
            
            Protected Range.CHARRANGE, ncLine.i, nColumn.i, Caret.Point
            
            ;
            ; Cursor X: Line
            SendMessage_(g,  #EM_EXGETSEL, 0, @Range)
                     
            Range\cpMax = Len(GetGadgetText(DC::#String_103))
            Range\cpMin = Len(GetGadgetText(DC::#String_103))
            
            SendMessage_(g, #EM_SETSEL, Range\cpMax, Range\cpMin)
            
        ProcedureReturn -1
   EndProcedure    
    ;
    ;
    ; Aufruf des Compatibility Mode to the Commandline über dem menu
    Procedure   System_MenuItemW_Compat(MenuID) 
        
        Protected sCmdString.s
        
        UseModule Compatibility
        
        ResetList(CompatibilitySystem())                                     
        
        While NextElement(CompatibilitySystem())
                        
            If ( CompatibilitySystem()\MenuIndex = MenuID )
             ;   Debug #CR$ + "Benutze: " + CompatibilitySystem()\OSModus$
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf
                
                If FindString( sCmdString, "%c"+ CompatibilitySystem()\OSModus$, 1) = 0
                    sCmdString + "%c"+CompatibilitySystem()\OSModus$
                EndIf                
                SetGadgetText( DC::#String_103 , sCmdString)
                Caret_SetPosition()
                Break
            EndIf    
        Wend        
        
        UnuseModule Compatibility             
        
    EndProcedure 
    
    ;
    ;
    ; Aufruf des Compatibility Mode to the Commandline über dem menu
    Procedure   System_MenuItemE_Compat(MenuID)
        
        Protected sCmdString.s
        
        UseModule Compatibility
        
        ResetList(CompatibilityEmulation())                                     
        
        While NextElement(CompatibilityEmulation())
                        
            If ( CompatibilityEmulation()\MenuIndex = MenuID )
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf
                
                If ( CompatibilityEmulation()\bCharSwitch = #True )
                		If FindString( sCmdString, "%c"+ CompatibilityEmulation()\Modus, 1) = 0
                    	sCmdString + "%c"+CompatibilityEmulation()\Modus
                    EndIf
                Else                    
                   If FindString( sCmdString, CompatibilityEmulation()\Modus, 1) = 0
                       sCmdString + CompatibilityEmulation()\Modus
                   EndIf  
                EndIf                  	
                SetGadgetText( DC::#String_103 , sCmdString)
                Caret_SetPosition()
                Break
            EndIf    
        Wend        
        
        UnuseModule Compatibility                     
    EndProcedure    
    
    ;
    ;
    ; Aufruf für Unreal Commandlines
    Procedure   System_MenuItemC_Unreal(MenuID)
        
        Protected sCmdString.s
        
        UseModule UnrealHelp
        
        ResetList(UnrealCommandline())                                     
        
        While NextElement(UnrealCommandline())
            
          ;  Debug "MenuIdx:" + Str( UnrealCommandline()\MenuIndex) + #TAB$ + LSet( UnrealCommandline()\UDKModus$, 24, Chr(32) ) + "Num: " +  Str( UnrealCommandline()\UDKIDX)
            
            If ( UnrealCommandline()\MenuIndex = MenuID )
              ;  Debug #CR$ + "Benutze: " + UnrealCommandline()\UDKModus$
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf
                
                If ( UnrealCommandline()\bCharSwitch = 2 )
                    
                    szUnrealExecCommand$ = UnrealCommandline()\Modus
                    If FindString( sCmdString, "-" + "ExecCmds=", 1) = 0
                        sCmdString + "-ExecCmds=" + Chr(34) + szUnrealExecCommand$ + Chr(34)                                                
                    Else
                        If FindString( sCmdString, szUnrealExecCommand$, 1) = 0                         
                           sCmdString = ReplaceString( sCmdString, "-ExecCmds="+Chr(34), "-ExecCmds="+Chr(34)+szUnrealExecCommand$+",")
                        EndIf    
                        
                    EndIf 
                    SetGadgetText( DC::#String_103 , sCmdString)
                    Caret_SetPosition()
                    Break
                Else                                              
                    
                    If ( UnrealCommandline()\bCharSwitch = #True )
                        If FindString( sCmdString, "-"+ UnrealCommandline()\Modus, 1) = 0
                            sCmdString + "-"+UnrealCommandline()\Modus
                        EndIf
                    Else
                        If FindString( sCmdString, UnrealCommandline()\Modus, 1) = 0
                            sCmdString + UnrealCommandline()\Modus
                        EndIf  
                    EndIf    
                    SetGadgetText( DC::#String_103 , sCmdString)
                    Caret_SetPosition()
                    Break
                EndIf    
            EndIf   
        Wend        
        
        UnuseModule UnrealHelp             
        
      EndProcedure
      
    ;
    ;
    ; Aufruf für Unreal Commandlines
    Procedure   System_MenuItemD_Unity(MenuID)
        
        Protected sCmdString.s
        
        UseModule UnityHelp
        
        ResetList(UnityCommandline())                                     
        
        While NextElement(UnityCommandline())
            
          ;  Debug "MenuIdx:" + Str( UnityCommandline()\MenuIndex) + #TAB$ + LSet( UnityCommandline()\UDKModus$, 24, Chr(32) ) + "Num: " +  Str( UnityCommandline()\UDKIDX)
            
            If ( UnityCommandline()\MenuIndex = MenuID )
              ;  Debug #CR$ + "Benutze: " + UnityCommandline()\UDKModus$
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf
                
                If ( UnityCommandline()\bCharSwitch = 2 )
                    
                    ;szUnUnityExecCommand$ = UnityCommandline()\UnityModus$
                    ;If FindString( sCmdString, "-" + "ExecCmds=", 1) = 0
                    ;    sCmdString + "-ExecCmds=" + Chr(34) + szUnUnityExecCommand$ + Chr(34)                                                
                    ;Else
                    ;    If FindString( sCmdString, szUnUnityExecCommand$, 1) = 0                         
                    ;       sCmdString = ReplaceString( sCmdString, "-ExecCmds="+Chr(34), "-ExecCmds="+Chr(34)+szUnUnityExecCommand$+",")
                    ;    EndIf    
                    ;    
                    ;EndIf 
                    ;SetGadgetText( DC::#String_103 , sCmdString)
                    ;Break
                Else                                              
                    
                    If ( UnityCommandline()\bCharSwitch = #True )
                        If FindString( sCmdString, "-"+ UnityCommandline()\Modus, 1) = 0
                            sCmdString + "-"+UnityCommandline()\Modus
                        EndIf
                    Else
                        If FindString( sCmdString, UnityCommandline()\Modus, 1) = 0
                            sCmdString + UnityCommandline()\Modus
                        EndIf  
                    EndIf    
                    SetGadgetText( DC::#String_103 , sCmdString)
                    Caret_SetPosition()
                    Break
                EndIf    
            EndIf   
        Wend        
        
        UnuseModule UnityHelp             
        
      EndProcedure
      
    ;
    ;
    ; Aufruf für Unreal Commandlines
    Procedure   System_MenuItemB_Emulation(MenuID)
        
        Protected sCmdString.s
        
        UseModule PortsHelp
        
        ResetList(PortCommandline())                                     
        
        While NextElement(PortCommandline())
            
          ;  Debug "MenuIdx:" + Str( PortCommandline()\MenuIndex) + #TAB$ + LSet( PortCommandline()\UDKModus$, 24, Chr(32) ) + "Num: " +  Str( PortCommandline()\UDKIDX)
            
            If ( PortCommandline()\MenuIndex = MenuID )
              ;  Debug #CR$ + "Benutze: " + PortCommandline()\UDKModus$
                
                sCmdString = GetGadgetText( DC::#String_103 )
                If Len( sCmdString ) > 0
                    sCmdString + Chr(32)
                EndIf

                If ( PortCommandline()\bCharSwitch = #True )
                    If FindString( sCmdString, "-"+ PortCommandline()\PortModus, 1) = 0
                        sCmdString + "-"+PortCommandline()\PortModus
                   EndIf
               Else
                   If FindString( sCmdString, PortCommandline()\PortModus, 1) = 0
                       sCmdString + PortCommandline()\PortModus
                   EndIf  
                 EndIf 
                 
                 vItemTool::Item_New_FomMenu(PortCommandline()\Description, 
                                             PortCommandline()\Port_ShortName ,
                                             PortCommandline()\PortModus,
                                             PortCommandline()\File_Default ,
                                             PortCommandline()\Path_Default)
                 
                 SetGadgetText( DC::#String_103 , sCmdString)
                 Caret_SetPosition()
               Break
                
            EndIf   
        Wend        
        
        UnuseModule PortsHelp             
        
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
                    
                    Protected ShortFile.s = GetFilePart( ProgramFilename(), #PB_FileSystem_NoExtension )
                    
                    Handle = FindWindowEx_(FindWindow_("vSystems: "+ ShortFile,0),0,"WindowClass_1",0)
                    
                    Request::MSG("", ShortFile + " läuft", "vSystems (Handle: "+ Str(Handle) +") wurde zuvor schon gestartet." + #CR$ + "Pfad: '"+FileName+"'", 2, 2, ProgramFilename(), 0, 0, 0)                
                    
                    If IsIconic_(Handle) = 1
                    	ShowWindow_(Handle,#SW_RESTORE)
                    EndIf    
                    
                    SetForegroundWindow_(Handle)                     
                    ;
					;BringWindowToTop_(Handle) 
                    ;
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
    Procedure.s System_Get_Internal_MEM(LCDInfo.i = #True)
    	
    	Protected Free.s = "", Total.s = ""
    	
    	Free.s = MathBytes::Bytes2String(MemoryStatus(#PB_System_FreePhysical))
    	
    	If ( LCDInfo.i = #True )
    		;
		; Info für den Standard Loop 	 	
    		Total.s = MathBytes::Bytes2String( MemoryStatus(#PB_System_TotalPhysical), #True)
    		
    		ProcedureReturn  Total + "  FREE: " + Free 
    		
    	ElseIf ( LCDInfo.i = 999 )
    		;
		; Info für den Programm Execute Loop        	
    		ProcedureReturn  Free
    	EndIf
    	
    	;
	; Info für den Standard Loop 	     	
    	Total.s = MathBytes::Bytes2String( MemoryStatus(#PB_System_TotalPhysical) )
    	
    	ProcedureReturn  Total + "  ( " + Free + " Verfügabar )"
    EndProcedure
    ;
    ;
    ;
    Procedure.s System_Get_Internal_Count()        
        x = CountGadgetItems(DC::#ListIcon_001)
         ProcedureReturn Str(x)
    EndProcedure
    ;
    ;
    ;    
    Procedure.s   System_InfoToolTip(LCDInfo.i = #False)
        
            TooltipString.s = ""
            TooltipString   = Startup::*LHGameDB\TrayIconTitle + Chr(13) + Chr(13) + 
                              "CPU: " + Trim( CPUName() ) + Chr(13) +
                              "CPU: " + System_Get_Internal_CPU() + Chr(13) +                          
                              "GFX: " + System_Get_Internal_GFX() + Chr(13) +      
                              "WIN: " + System_Get_Internal_WIN() + Chr(13) +                          
                              "MEM: " + System_Get_Internal_MEM() + Chr(13) + Chr(13) + 
                              "Einträge: " + System_Get_Internal_Count() + Chr(13) + Chr(13) +
                              "Developed by Marty Shepard"
            
            Startup::ToolTipSystemInfo = TooltipString     

        ProcedureReturn TooltipString
    EndProcedure
         
    Procedure.i   System_DPI_Helper()
    EndProcedure    
    
    Procedure.i   Capture_Screenshot_Thread(*Interval)
		If (  LCD::Mono_IsConnected()  Or  LCD::Color_IsConnected())              
			LCD::Mono_SetText(0, "VSYSTEMS RUNS" + "  |MEM " + System_Get_Internal_MEM(999) )
             	LCD::Mono_SetText(1, "")			
             	LCD::Mono_SetText(2, "--  SCREENSHOT CAPTURED  --" )             	
             	LCD::Mono_SetText(3, "")
             	LCD::Update()     
             	Delay(*Interval)             	             	
            EndIf    	
    	
    EndProcedure
    ;
    ;
	;
    Procedure.i   Capture_Screenshot_Thread_Error(*Interval)
    	
		If (  LCD::Mono_IsConnected()   Or  LCD::Color_IsConnected())             
			LCD::Mono_SetText(0, "VSYSTEMS RUNS" + "  |MEM " + System_Get_Internal_MEM(999) )
             	LCD::Mono_SetText(1, "--         ERROR         --" )			
             	LCD::Mono_SetText(2, "--  SCREENSHOT CAPTURED  --" )             	
             	LCD::Mono_SetText(3, "--         ERROR         --" )
             	LCD::Update()
             	Delay(*Interval)
             	
             	
            EndIf    	
    	
    EndProcedure    
    ;
    ;
	;
    Procedure CaptureScreen(Left, Top, Width, Height)
    	Protected dm.DEVMODE, BMPHandle
    	Protected old, trgDC, srcDC = CreateDC_("DISPLAY", "", "", dm)
    	
    	If srcDC
    		trgDC = CreateCompatibleDC_(srcDC)
    		If trgDC
    			BMPHandle = CreateCompatibleBitmap_(srcDC, Width, Height)
    			If BMPHandle
    				old = SelectObject_(trgDC, BMPHandle)
    				
    				BitBlt_(trgDC, 0, 0, Width, Height, srcDC, Left, Top, #SRCCOPY)
    				SelectObject_(trgDC, old)
    			EndIf
    			DeleteDC_(trgDC)
    			
			ReleaseDC_(#Null, srcDC)   			
			; --------------------------
				OpenClipboard_(#Null)
				EmptyClipboard_()
				SetClipboardData_(#CF_BITMAP, BMPHandle);  // clipboard now owns the bitmap
				CloseClipboard_()
			; --------------------------	
			EndIf
    		DeleteDC_(srcDC)
    	EndIf
    	
    	ProcedureReturn BMPHandle 
    EndProcedure 
    
    #DWMWA_EXTENDED_FRAME_BOUNDS = 9
    ;
    ;
	;
    Procedure GetWindowRect_modified(hWnd, *rt.RECT)
    	Protected Lib, DwmIsCompositionEnabled, DwmGetWindowAttribute, flag
    	
    	If *rt = 0 : ProcedureReturn 0 : EndIf
    	
    	GetWindowRect_(hWnd, *rt)
    	
    	If OSVersion() >= #PB_OS_Windows_Vista
    		Lib = OpenLibrary(#PB_Any, "dwmapi.dll")
    		If Lib
    			DwmIsCompositionEnabled = GetFunction(Lib, "DwmIsCompositionEnabled")
    			If DwmIsCompositionEnabled
    				CallFunctionFast(DwmIsCompositionEnabled, @flag)
    			EndIf
    			If flag = 1
    				DwmGetWindowAttribute = GetFunction(Lib, "DwmGetWindowAttribute")
    				If DwmGetWindowAttribute
    					CallFunctionFast(DwmGetWindowAttribute, hWnd, #DWMWA_EXTENDED_FRAME_BOUNDS, *rt, SizeOf(RECT))
    				EndIf
    			EndIf
    			CloseLibrary(Lib)
    		EndIf
    	EndIf
    	
    	ProcedureReturn 1
    EndProcedure 
    ;
    ;
	;    
    Procedure CaptureWindow(ImageFileName.s)
    	Protected Image, ScreenCaptureAddress, WindowSize.RECT, WinHndl = Startup::*LHGameDB\NBWindowhwnd
    	If WinHndl

    		GetWindowRect_modified(WinHndl, @WindowSize)
    		
    		ScreenCaptureAddress = CaptureScreen(WindowSize\Left, WindowSize\Top, WindowSize\Right - WindowSize\Left, WindowSize\Bottom - WindowSize\Top)
    		
    		If ScreenCaptureAddress
    			Image = CreateImage(#PB_Any, WindowSize\Right - WindowSize\Left, WindowSize\Bottom - WindowSize\Top)
    			If Image
    				If StartDrawing(ImageOutput(Image))
    					DrawImage(ScreenCaptureAddress, 0, 0)
    					StopDrawing()
    					SaveImage(Image, ImageFileName,#PB_ImagePlugin_PNG)   					
    				EndIf
    				FreeImage(Image)
    			EndIf
    			DeleteObject_(ScreenCaptureAddress)
    		EndIf
		
    	Else
    		ProcedureReturn 0
    	EndIf
    	ProcedureReturn 1
    EndProcedure
    ;
    ;
	;
    Procedure.i   Capture_Screenshot(ProgrammName.s)
        
        If  ( Startup::*LHGameDB\NBWindowhwnd > 0 )
            
          ;  Debug "Capture Screenshot"
            
            Protected Window.RECT, Client.RECT, Directory.s =  Startup::*LHGameDB\Base_Path + "Systeme\", ImageFileName.s 
                       	            
            Beep_(200,300)
            ;OLD
            ;	hImage = CreateImage(#PB_Any,Startup::*LHGameDB\NBClient\right,Startup::*LHGameDB\NBClient\bottom)  
            ;	hDC    = StartDrawing(ImageOutput(hImage))
            
            ;	PrgDC = GetDC_(Startup::*LHGameDB\NBWindowhwnd) 
            ;	BitBlt_(hDC,0,0,Startup::*LHGameDB\NBClient\right,Startup::*LHGameDB\NBClient\bottom,PrgDC,0,0,#SRCCOPY) 
            ;	StopDrawing() 
            
            ;	ReleaseDC_(Startup::*LHGameDB\NBWindowhwnd,PrgDC)
            
            	;
            	; SaveImage (Format PNG)
            	;
            	; Genreate FileName
            
            Delay(1)
            
            Select FileSize( Directory.s + "SHOT")
                Case -1: CreateDirectory( Directory.s + "SHOT" )                    
            EndSelect        
            
            Date$ = FormatDate("%yyyy_%mm_%dd", Date())
            Time$ = FormatDate("%hh_%ii_%ss"  , Date())
                        
            ImageFileName.s = Directory.s + "SHOT\" + ProgrammName.s + " - " + Date$ + " - " + Time$ + ".png"
            
            
            If ( CaptureWindow(ImageFileName.s) = 0)
            	;Debug "ERROR ON CAPTURE: " + ImageFileName  
            	CaptureThread.i = CreateThread(@Capture_Screenshot_Thread_ERROR(), 5000)
            	Beep_(250,200) 
            	Delay(1250)
            Else
            	;Debug "CAPTURED: " + ImageFileName
            	CaptureThread.i = CreateThread(@Capture_Screenshot_Thread(), 5000)
            	Beep_(450,100)  
            	Delay(1250)            	
            EndIf	
            	
            ;OLD                       
            ;	SaveImage(hImage, ImageFileName,#PB_ImagePlugin_PNG,#Null,32)
            ;OLD			
            ;	FreeImage(hImage)

                     	
            ProcedureReturn                                    
        EndIf
    EndProcedure        

    ;
    ;
	;    
    Procedure.i 	  LCD_Info(LCDInfo.i = #False, PrgLoop.i = #False)
    	
    	If ( LCDInfo = #True )  And ( LCD::Color_IsConnected() Or LCD::Mono_IsConnected() ) And (PrgLoop = #False)                 
    		
             LCD::Mono_SetText(0, UCase( Startup::*LHGameDB\TitleSimpled ))
             LCD::Mono_SetText(1, "MEM: " + System_Get_Internal_MEM(#True) )
             LCD::Mono_SetText(2, UCase( GetFilePart(ProgramFilename(),#PB_FileSystem_NoExtension)))
             LCD::Mono_SetText(3, "")
             LCD::Update()
             
             ProcedureReturn 
             
      ElseIf ( LCDInfo = #True ) And ( LCD::Color_IsConnected() Or LCD::Mono_IsConnected() ) And (PrgLoop = #True)         	      		      		 
      	
             LCD::Mono_SetText(0, "VSYSTEMS RUNS" + "  |MEM " + System_Get_Internal_MEM(999) )

             If ( Startup::*LHGameDB\vKeyActivShot = #True )
             	If   ( Startup::*LHGameDB\Settings_hkeyShot = #MOD_SHIFT)
           			LCD::Mono_SetText(1,  "KEY CAPTURE: SHIFT + SCROLL" )
             	Else
           			LCD::Mono_SetText(1,  "KEY CAPTURE: SCROLL" )
             	EndIf             	
             Else
             	LCD::Mono_SetText(1,  "KEY CAPTURE : DISBALED" )
             EndIf	
             
             If ( Startup::*LHGameDB\vKeyActivKill = #True )             	
       			LCD::Mono_SetText(2,  "KEY KILL-PRG: ALT + SCROLL" )
             Else
             	LCD::Mono_SetText(2,  "KEY KILL-PRG : DISBALED" )
             EndIf
             
             sTextLastLine.s = ""
             
             If ( Startup::*LHGameDB\Settings_Affinity => 0)
             	;Debug Startup::*LHGameDB\Settings_Affinity
             	sTextLastLine + "|CPU-"+Str(Startup::*LHGameDB\Settings_Affinity)
             EndIf 
             
             If ( Startup::*LHGameDB\Settings_fMonitor = #True)
             	sTextLastLine + "MON|" 
             EndIf
             
             If ( Startup::*LHGameDB\Settings_aExecute = #True)
             	sTextLastLine + "|EXE"
             EndIf 
                                         
             If ( Startup::*LHGameDB\Settings_bCompatM = #True)
             	sTextLastLine + "|COMP"
             EndIf    
             
             If ( Startup::*LHGameDB\Settings_NoBorder = #True)
             	sTextLastLine + "|NB"
             EndIf               
             
              If ( Startup::*LHGameDB\Settings_NBCenter = #True)
             	sTextLastLine + "C"
             EndIf 
             
             If ( Startup::*LHGameDB\Settings_OvLapped = #True)
             	sTextLastLine + "B"
             EndIf              
             
             If ( Startup::*LHGameDB\Settings_LokMouse = #True)
             	sTextLastLine + "|LCKMS"
             EndIf 
             
             If ( Startup::*LHGameDB\Settings_bBlockFW = #True)
             	sTextLastLine + "|BLOCK"
             EndIf              
             
             If ( Startup::*LHGameDB\Settings_bNoOutPt = #False)
             	sTextLastLine + "|LOG"
             EndIf             
             
             If ( Startup::*LHGameDB\Settings_bSaveLog = #True)
             	sTextLastLine + "|EXTLOG"
             EndIf 
             
             
             LCD::Mono_SetText(3,  sTextLastLine )
             
             LCD::Update()
             	
             ProcedureReturn 
      EndIf    
 
    EndProcedure     		
    ;
    ;
    ;
    Procedure.i    Terminate_Programm(*Params)    	    	
    	
    	Startup::*LHGameDB\ExitSignal = #True
    	
    	If ( Startup::*LHGameDB\Settings_hkeyKill = #True )
    		If ( Startup::*LHGameDB\Settings_aExecute = #True )
    			;
					;
					; Alternative Execute
    			phandle = OpenProcess_(#PROCESS_TERMINATE, #False, Startup::*LHGameDB\Thread_ProcessLow)
    			If phandle <> #Null
    				If TerminateProcess_(phandle, 1)
    					result = #True    					 
    				EndIf
    				CloseHandle_(phandle)
    				CloseHandle_( *Params )
    				Delay(100)
    				ProcedureReturn 0
    			EndIf
    			
    		Else	    			
    			If  IsProgram( Startup::*LHGameDB\Thread_ProcessLow )
    				KillProgram( Startup::*LHGameDB\Thread_ProcessLow )
    				ProcedureReturn 0
    			EndIf 
    		EndIf 
    	EndIf    	
    	ProcedureReturn 1
    EndProcedure	
   	;
	;
	;
    
    
EndModule

; Disabled - Todo
; ------------------------------------------------------------------------------------
;  Gibt die anzahl der Bilder pro sek. zurück.
;    Procedure.l System_GetFPS()
;     	Static GetFPS_Count.l, GetFPS_FPS.l, GetFPS_Start.l
;     	GetFPS_Count + 1
;     	
;     	If GetFPS_Start = 0
;     		GetFPS_Start = GetTickCount_()
;     	EndIf
;     	If GetTickCount_() - GetFPS_Start >= 1000
;     		GetFPS_FPS   = GetFPS_Count
;     		GetFPS_Count = 0
;     		GetFPS_Start + 1000
;     	EndIf
;     	ProcedureReturn GetFPS_FPS
;    EndProcedure  

; ------------------------------------------------------------------------------------
;     Global gCurrentUsage.d
;     
;     Procedure.d EMA_smoothing(raw.d, samples.w)
;     	Static Alpha.d
;     	Protected CurrentEMA.d
;     	Static PriorEMA.d
;     	
;     	Alpha.d = 2 / (samples.w + 1)
;     	CurrentEMA.d = priorEMA.d + (Alpha.d * (raw.d - priorEMA.d))
;     	PriorEMA.d = CurrentEMA.d
;     	
;     	ProcedureReturn CurrentEMA.d
;     EndProcedure
;     
;     Procedure System_MonitorCPU(void)
;     	#EMA_Samples = 20
;     	
;     	Protected creation.FILETIME
;     	Protected exit.FILETIME
;     	Protected kernel.FILETIME
;     	Protected user.FILETIME
;     	Protected sysinfo.SYSTEM_INFO
;     	Protected numprocs
;     	Protected h
;     	Protected oldkernel
;     	Protected olduser
;     	Protected rawCurrentUsage.d
;     	
;     	GetSystemInfo_(@sysinfo)
;     	numprocs = sysinfo\dwNumberOfProcessors
;     	
;     	h = OpenProcess_(#PROCESS_QUERY_INFORMATION, #False, Startup::*LHGameDB\Thread_ProcessLow) 
;     	GetProcessTimes_(h,@creation,@exit,@kernel,@user)
;     	oldkernel=kernel\dwlowdatetime
;     	olduser=user\dwlowdatetime
;     	Delay(100)
;     	
;     	Repeat
;     		GetProcessTimes_(h,@creation,@exit,@kernel,@user)
;     		rawCurrentUsage.d = ((((user\dwlowdatetime-olduser)+(kernel\dwlowdatetime-oldkernel))/500)/100)/numprocs
;     		gCurrentUsage.d = EMA_smoothing(rawCurrentUsage.d, #EMA_Samples)
;     		olduser=user\dwlowdatetime
;     		oldkernel=kernel\dwlowdatetime   
;     		Delay(100)
;     	ForEver
;     EndProcedure
; ------------------------------------------------------------------------------------
;
;     Procedure StateWindow(handle) 
;     	MyWindpl.WINDOWPLACEMENT 
;     	MyWindpl\length=SizeOf(MyWindpl) 
;     	
;     	If GetWindowPlacement_(handle,@MyWindpl) 
;     		MyWindpl\length=SizeOf(MyWindpl) 
;     		;MyWindpl\showCmd=State 
;     		Debug "MyWindpl\showCmd: " + Str(MyWindpl\showCmd)
;     		SetWindowPlacement_(handle,@MyWindpl) 
;     	EndIf 
;     EndProcedure 
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 372
; FirstLine = 392
; Folding = zxz-Ps5-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\The Chaos Engine\