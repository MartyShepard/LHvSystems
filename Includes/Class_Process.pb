DeclareModule ProcessEX

    Declare.i TaskListCreate()
    Declare.i TaskListGetPID(ProcessName$,ParentID=0,FreeTaskMemory=0)    
    
    Declare.i SetAffinityCPUS(SetActiv=0,SetNormal=1)
    Declare.i SetAffinityActiv(ProcessID,_CpuAffinityMask.i)
    Declare.d SlowDown(ProcessID,dTime.d,NTdll_Library,CpuMHZ.d)
    
    Declare.b AdjustCurrentProcessPrivilege(ProcessID)
    
    Declare.i GetCpuTaktInfo(ReturnCPUState=0)
    
    ;Declare.f Get_CPU_MHz(Delay.l=0)
    
    Declare Get_Prozessor_String_W(StringAdresse)
    Declare LHFreeMem()
    Declare LHFreeMemGlobal(ProcessName$="")
    
    Declare KillProcess(Pid)
    Declare.s GetProcessPriority(hProcess)
    Declare SetProcessPriority(hProcess, PriorityClass)
    
      
EndDeclareModule

Module ProcessEX
    
    #TH32CS_SNAPHEAPLIST  = $1
    #TH32CS_SNAPPROCESS   = $2
    #TH32CS_SNAPTHREAD    = $4
    #TH32CS_SNAPMODULE    = $8
    #TH32CS_SNAPALL       = #TH32CS_SNAPHEAPLIST | #TH32CS_SNAPPROCESS | #TH32CS_SNAPTHREAD | #TH32CS_SNAPMODULE
    #TH32CS_INHERIT       = $80000000
    #INVALID_HANDLE_VALUE = -1
    #PROCESS32LIB         = 9999
    #PROCESS_SET_INFORMATION = $0200
    #TRM_TICKINTERVAL = 1
        
    Structure PROCESS_BASIC_INFORMATION
        ExitStatus.i
        PebBaseAddress.i
        AffinityMask.i
        BasePriority.i
        UniqueProcessId.i
        InheritedFromUniqueProcessId.i
    EndStructure  
    
    Prototype protoNtSuspendProcess(ProcessHandle)
    Prototype protoNtResumeProcess(ProcessHandle) 
    
    Global NewList Process32.PROCESSENTRY32()  
    

    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    ; Erstellt eine Taskliste der Processe
    Procedure.i TaskListCreate()
        
        Protected pbi.PROCESS_BASIC_INFORMATION, SnapShot
        
        If OpenLibrary (#PROCESS32LIB, "kernel32.dll")
            SnapShot = CallFunction (#PROCESS32LIB, "CreateToolhelp32Snapshot", #TH32CS_SNAPPROCESS, 0)
            
            If (SnapShot)
                Define.PROCESSENTRY32 Proc32
                Proc32\dwSize = SizeOf (PROCESSENTRY32)  
                
                If CallFunction (#PROCESS32LIB, "Process32First", SnapShot, @Proc32)
                    AddElement(Process32())
                    CopyMemory (@Proc32, @Process32 (), SizeOf(PROCESSENTRY32))
                    
                    While CallFunction (#PROCESS32LIB, "Process32Next", SnapShot, @Proc32)
                        AddElement (Process32())
                        CopyMemory (@Proc32, @Process32(), SizeOf(PROCESSENTRY32))
                    Wend
                    
                EndIf
                CloseHandle_(SnapShot)
            EndIf
            
            CloseLibrary (#PROCESS32LIB)
        EndIf           
    EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; FreeMem  Global    
    Procedure LHFreeMemGlobal(ProcessName$="")
        
        Protected RealProcessID.l,PHandle,Result
        
        GlobalMemoryStatus_(Memory.MEMORYSTATUS)
        GlobalFree_(Memory\dwAvailPhys)
        GlobalFree_(Memory\dwAvailVirtual)
        GlobalFree_(Memory\dwAvailPageFile) 
        
        ResetList (Process32())
        While NextElement(Process32())
            
            TaskName$ = PeekS(@Process32()\szExeFile,255,#PB_UTF8);:         Debug "Tasknames: "+UCase(TaskName$)+" = "+UCase(ProcessName$)
            
            
            If (Len(TaskName$) <> 0)
                
                RealProcessID.l = PeekL (@Process32()\th32ProcessID)
                
                PHandle = OpenProcess_(#PROCESS_ALL_ACCESS, #False, RealProcessID)
                Result= SetProcessWorkingSetSize_(PHandle,-1,-1)
                If Result
                    ;Debug "Free Ram: "+TaskName$
                Else
                    ;Debug "Free Ram: "+TaskName$+ " Failed > Try Parent"
                    
                    ParentProcess.l = PeekL (@Process32()\th32ParentProcessID)
                    
                    PHandle = OpenProcess_(#PROCESS_ALL_ACCESS, #False, ParentProcess)
                    Result= SetProcessWorkingSetSize_(PHandle,-1,-1)
                    If Result
                        ;Debug "Free Ram /Parent: "+TaskName$
                    Else
                        ;Debug "Free Ram /Parent: "+TaskName$+ " Failed > Try Parent"
                    EndIf                             
                EndIf                                                                                                                
                
            EndIf                           
        Wend
        ClearList(Process32()):ProcedureReturn 0
    EndProcedure
        
        
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; FreeMem  Global    
    Procedure LHFreeMemLocal(CurrentProcess.l)
        ;Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Durchgang Beginnt"   
        Protected RealProcessID.l,PHandle,Result, MemFreeProcess.l
        
        ResetList (Process32())
        While NextElement(Process32())
            
            RealProcessID.l = PeekL (@Process32()\th32ProcessID)
            Select RealProcessID.l
                Case 0
                    MemFreeProcess.l = 0
                    
                    ParentProcess.l = PeekL (@Process32()\th32ParentProcessID)
                    Select ParentProcess.l
                        Case 0
                            MemFreeProcess.l = 0
                        Default
                            MemFreeProcess.l = ParentProcess.l
                    EndSelect
                    
                Default 
                    MemFreeProcess.l = RealProcessID.l
                    
            EndSelect      
            ;Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Durchgang Im Whhile"       
            Select MemFreeProcess.l
                Case 0
                Case CurrentProcess.l
                Case GetCurrentProcessId_()
                Default
                    PHandle = OpenProcess_(#PROCESS_ALL_ACCESS, #False, MemFreeProcess)
                    Result= SetProcessWorkingSetSize_(PHandle,-1,-1)
                    If Result
                        ;Debug "Free Ram: "+TaskName$
                    Else
                        ;Debug "Free Ram: "+TaskName$+ " Failed > Try Parent"                  
                    EndIf    
            EndSelect
        Wend
        ;Debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Durchgang Finished"
        ProcedureReturn
    EndProcedure
        
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    ; Holt die processid aus dem Task oder die ParentProcessID
    Procedure.i TaskListGetPID(ProcessName$,ParentID=0,FreeTaskMemory=0)  
        
            Protected PHandle, RealProcessID.l, ParentProcess.l, Result
            ResetList (Process32())
            While NextElement(Process32())

                TaskName$ = PeekS(@Process32()\szExeFile,255,#PB_UTF8);:         Debug "Tasknames: "+UCase(TaskName$)+" = "+UCase(ProcessName$)
                
                
                If (UCase(TaskName$) = UCase(ProcessName$)):                    ;Debug "Tasknames BINGO: "+UCase(TaskName$)+"="+UCase(ProcessName$)
                    
                  If (ParentID = 0)
                      RealProcessID.l = PeekL (@Process32()\th32ProcessID)
                      
                      If (FreeTaskMemory=1)
                          LHFreeMemLocal(RealProcessID.l)
                      EndIf
                      
                      ClearList(Process32())
                      ProcedureReturn RealProcessID.l
                      
                      If RealProcessID.l = 0
                         ParentProcess.l = PeekL (@Process32()\th32ParentProcessID)
                         ClearList(Process32())
                         ProcedureReturn ParentProcess.l
                      EndIf
                  EndIf                 
              EndIf
              
            Wend
            ClearList(Process32()):ProcedureReturn 0
        EndProcedure
    
        
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Setzt die Processor Nummer in die Variable und überprüft die Anzahl
    Procedure.i SetAffinityCPUS(SetActiv=0,SetNormal=1)
            
        Protected SI.SYSTEM_INFO, NumberOfProcessors
        
        GetSystemInfo_(@SI)
        NumberOfProcessors = SI\dwNumberOfProcessors
        
        If (SetNormal = 1)
            ProcedureReturn NumberOfProcessors
        EndIf
        
        If (SetActiv = 0)
            ProcedureReturn NumberOfProcessors
        EndIf
        
        If (SetActiv <= NumberOfProcessors) And (SetActiv <> 0)
            ProcedureReturn SetActiv
        EndIf
        ProcedureReturn 9999
    EndProcedure 
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Setzt Live die Affinity (Repeat Mode)
    Procedure.i SetAffinityActiv(ProcessID,_CpuAffinityMask.i)
        Protected CustomAffinity.q = (1 << _CpuAffinityMask) - 1
        Protected PHSet
                
        If (_CpuAffinityMask = 64): CustomAffinity = -1: EndIf        
        
        PHSet = OpenProcess_(#PROCESS_SET_INFORMATION, #False, ProcessID)
        SetProcessAffinityMask_(PHSet, CustomAffinity): CloseHandle_(PHSet)
    EndProcedure 
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Setzt Die Privilegoin für den Slow down
    Procedure.b AdjustCurrentProcessPrivilege(ProcessID)
        Result.b = #False
        
        If OpenProcessToken_(ProcessID, #TOKEN_ADJUST_PRIVILEGES | #TOKEN_QUERY, @TokenHandle)
            lpLuid.LUID
            
            If LookupPrivilegeValue_(#Null, #SE_DEBUG_NAME, @lpLuid)
                NewState.TOKEN_PRIVILEGES
                
                With NewState
                    \PrivilegeCount = 1
                    \Privileges[0]\Luid\LowPart = lpLuid\LowPart
                    \Privileges[0]\Luid\HighPart = lpLuid\HighPart
                    \Privileges[0]\Attributes = #SE_PRIVILEGE_ENABLED
                EndWith
                
                Result = AdjustTokenPrivileges_(TokenHandle, #False, @NewState, SizeOf(TOKEN_PRIVILEGES), @PreviousState.TOKEN_PRIVILEGES, @ReturnLength)
            EndIf
            
            CloseHandle_(TokenHandle)
        EndIf
        
        ProcedureReturn Result
    EndProcedure
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Setzt Die Process Priorität    
    Procedure SetProcessPriority(hProcess, PriorityClass)
        SetPriorityClass_(hProcess, PriorityClass)
        ProcedureReturn hProcess
    EndProcedure
    
    Procedure KillProcess(Pid) ; Kill a process by specifying it's Pid
      
      phandle = OpenProcess_ (#PROCESS_TERMINATE, #False, Pid) 
      If phandle <> #Null 
        If TerminateProcess_ (phandle, 1) 
          Result = #True 
        EndIf 
        CloseHandle_ (phandle) 
      EndIf 
      ProcedureReturn Result 
    EndProcedure 
    
    Procedure.s GetProcessPriority(hProcess)
        Result.s = ""
        
        Select GetPriorityClass_(hProcess)
            Case #IDLE_PRIORITY_CLASS
                Result = "Idle"
            Case #BELOW_NORMAL_PRIORITY_CLASS
                Result = "Below"
            Case #NORMAL_PRIORITY_CLASS
                Result = "Normal"
            Case #ABOVE_NORMAL_PRIORITY_CLASS
                Result = "Above"
            Case #HIGH_PRIORITY_CLASS
                Result = "High"
            Case #REALTIME_PRIORITY_CLASS
                Result = "Realtime"
            Default
                dwMessageId = GetLastError_()
                *lpBuffer = AllocateMemory(255)
                FormatMessage_(#FORMAT_MESSAGE_FROM_SYSTEM, #Null, dwMessageId, #Null, *lpBuffer, MemorySize(*lpBuffer), #Null)
                Result = "Error: " + Str(dwMessageId) + " - " + PeekS(*lpBuffer)
                FreeMemory(*lpBuffer)
        EndSelect
        ProcedureReturn Result
    EndProcedure  

    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    Procedure GetCpuTaktInfo(ReturnCPUState=0)
        pwr = OpenLibrary (#PB_Any, "powrprof.dll")
        
        CallNtPowerInformation   = GetFunction (pwr, "CallNtPowerInformation")   ; Requires 2000 or above       
        
        GetSystemInfo_ (sys.SYSTEM_INFO)
        cpus = sys\dwNumberOfProcessors       
        
        buffsize = SizeOf (PROCESSOR_POWER_INFORMATION) * cpus
        Dim buffer.PROCESSOR_POWER_INFORMATION (cpus - 1)
        
        CallFunctionFast (CallNtPowerInformation, 11, #Null, #Null, @buffer (0), buffsize)
        
;         For cpu = 0 To cpus - 1
;             Debug "CPU: " + Str (buffer (cpu)\Number)
;             Debug ""
;             Debug "Max MHz: " + Str (buffer (cpu)\MaxMhz)
;             Debug "Current MHz: " + Str (buffer (cpu)\CurrentMhz)
;             Debug "MHz Limit: " + Str (buffer (cpu)\MhzLimit)
;             Debug "Max idle state: " + Str (buffer (cpu)\MaxIdleState)
;             Debug "Current idle state: " + Str (buffer (cpu)\CurrentIdleState)
;             Debug ""
;         Next
        
        For cpu = 0 To cpus - 1
            Select ReturnCPUState
                Case 0
                    ProcedureReturn
                Case 1
                    ProcedureReturn buffer(cpu)\MaxMhz
                EndSelect                                      
        Next                
                
    EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
;     Procedure.q Get_CPU_Cycles()
;         Protected Zyklus.q
;         ; Zähler abrufen
;         !RDTSC 
;         !MOV [esp],Eax
;         !MOV [esp+4],Edx
;         ProcedureReturn Zyklus
;     EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; 
;     Procedure.f Get_CPU_MHz(Delay.l=0) ; CPU Speed in MHz (approx.)
;         Protected MHZ.d,sec.f,ref.q,tstart.l,diff.l,cdiff.q,tlim.l,tnow.l
;         If Delay<=0
;             ;  CPU Geschwindigkeit anhand von System-start Werten berechnen (Millisekunden- und Zyklenanzahl)
;             ;  Mit zunehmender Zeit ungenauer
;             sec = ElapsedMilliseconds()/1000.0   
;             MHZ = Get_CPU_Cycles()
;             MHZ / 1000000.0 ;  Mega
;             MHZ / sec       ; Hz
;             ProcedureReturn (MHZ)   ;
;             
;         EndIf        
;     EndProcedure
    
    
    

    Procedure DelayMicroSeconds(Time.d)
        
      QueryPerformanceFrequency.q : QueryPerformanceFrequency_(@QueryPerformanceFrequency)
        
      Protected StartTime.q, EndTime.q
      
      QueryPerformanceCounter_(@StartTime)
      Repeat
        Sleep_(0)
        QueryPerformanceCounter_(@EndTime)
      Until (EndTime-StartTime)*1e6/QueryPerformanceFrequency > Time
      
    EndProcedure
  
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Setzt Die Privilegoin für den Slow down   
    Procedure.d SlowDown(ProcessID,SetTime.d,NTdll_Library,CpuMHZ.d)
        

        Protected NtSuspendProcess.protoNtSuspendProcess
        Protected NtResumeProcess.protoNtResumeProcess                       
        Protected timecaps.TIMECAPS
        Protected SlowTime,  Newtime.q
        
        Newtime.q = SetTime.d
    
        For i = 1 To 100
            Select i
                Case Newtime.q
                    SlowTime = 100 - Newtime.q
                    SlowTime = SlowTime*1000; Debug x 
            EndSelect
        Next

        
        timeGetDevCaps_(timecaps,SizeOf(TIMECAPS)) 
        timeBeginPeriod_(timecaps\wPeriodMin)
        
        If (NTdll_Library)
            
            NtSuspendProcess = GetFunction(NTdll_Library, "NtSuspendProcess")
            NtResumeProcess = GetFunction(NTdll_Library, "NtResumeProcess")                     
            hProcess = OpenProcess_(#PROCESS_ALL_ACCESS, #False, ProcessID)
                        
            NtSuspendProcess(hProcess)
            DelayMicroSeconds(SlowTime)     
            
            NtResumeProcess(hProcess)
            
            DelayMicroSeconds(1) ;Sleep_(1)
            CloseHandle_(hProcess)
            timeEndPeriod_(timecaps\wPeriodMin)            
        EndIf

        ProcedureReturn  SlowTime
    EndProcedure
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; FreeMem      
    Procedure LHFreeMem()
        
      Protected ProcessID,PHandle,Result
  
        ProcessID   = GetCurrentProcessId_()
        PHandle     = GetCurrentProcess_()
 
        Result= SetProcessWorkingSetSize_(PHandle,-1,-1)
        If Result
        Else
        ; it failed
        EndIf
    EndProcedure    
    
    
    ;/////////////////////////////////////////////////////////////////////////////////////////////////////////
    ; Liest den Prozessor Typ aus
    
    Procedure Get_Prozessor_String_W(StringAdresse)
        !mov eax,80000000h       ;Test, ob CPU aktuell genug ist um den String zu liefern
        !cpuid
        !cmp eax,80000004h
        !jae @f                  ;alles o.K.
        !xor eax,eax             ;Rückgabewert = Null für eventuelle Auswertung Fehlschlag
        ProcedureReturn
        !@@:
        !mov esi,[p.v_StringAdresse]
        !xor edi,edi
        !pxor xmm7,xmm7
        !@@:   
        !mov eax,80000002h
        !add eax,edi
        !cpuid       
        !movd xmm0,eax
        !punpcklbw xmm0,xmm7     ;wenn die CPU obigen Test bestanden hat, sollte auch dies funktionieren (SSE2)
        !movq [esi],xmm0   
        !movd xmm0,ebx
        !punpcklbw xmm0,xmm7
        !movq [esi+8],xmm0         
        !movd xmm0,ecx
        !punpcklbw xmm0,xmm7
        !movq [esi+16],xmm0   
        !movd xmm0,edx
        !punpcklbw xmm0,xmm7
        !movq [esi+24],xmm0           
        
        !inc edi
        !cmp edi,3
        !je @f
        !add esi,32
        !jmp @b
        !@@:
        !mov byte[esi+32],0      ;Zero-Byte; mal ganz vorbildlich, obwohl hier im speziellen Fall nicht nötig
        !mov eax,1               ;Rückgabewert <> Null für Erfolg
        ProcedureReturn   
    EndProcedure    
    


  
EndModule

;//////////////////////////////////////////////////////////////////////////////////////////////////////////////
; 

CompilerIf #PB_Compiler_IsMainFile
; 
; ProcessEX::TaskListCreate()
; ProcessID = ProcessEX::TaskListGetPID("explorer.exe")
; Debug ProcessID
; 
; _CpuAffinityMask = ProcessEX::SetAffinityCPUS(1)
; For i = 0 To 1000
;     ProcessEX::SetAffinityActiv(ProcessID,_CpuAffinityMask.i)
;     Delay(75):Debug Str(i)+"/ Set 'explorer.exe' ("+Str(ProcessID)+") To  "+Str(_CpuAffinityMask)+" CPU/s"
; Next
; 
; 
; 
; Speed.d = ProcessEX::Get_CPU_MHz()
;     
; ProcessEX::SetAffinityActiv(ProcessID,0)
; ProcessEX::AdjustCurrentProcessPrivilege(ProcessID)
; ntdll = OpenLibrary(#PB_Any, "ntdll.dll")
; iSlowDown_Percent.d = 100
; timeBeginPeriod_(1)
; For i = 0 To 100
;     iDown.d = ProcessEX::SlowDown(ProcessID,iSlowDown_Percent,ntdll,Speed.d)
;     Delay(75):Debug Str(i)+"/ Set 'Slow Down "+iDown.d+" on' ("+Str(ProcessID)+") To  "+Str(_CpuAffinityMask)+" CPU/s"
; Next
; 
; iSlowDown_Percent.d = 90
; For i = 0 To 100
;     iDown.d = ProcessEX::SlowDown(ProcessID,iSlowDown_Percent,ntdll,Speed.d)
;     Delay(75):Debug Str(i)+"/ Set 'Slow Down "+iDown.d+" on' ("+Str(ProcessID)+") To  "+Str(_CpuAffinityMask)+" CPU/s"
; Next
; 
; iSlowDown_Percent.d = 80
; For i = 0 To 100
;     iDown.d = ProcessEX::SlowDown(ProcessID,iSlowDown_Percent,ntdll,Speed.d)
;     Delay(75):Debug Str(i)+"/ Set 'Slow Down "+iDown.d+" on' ("+Str(ProcessID)+") To  "+Str(_CpuAffinityMask)+" CPU/s"
; Next
; 
; iSlowDown_Percent.d = 5.52
; For i = 0 To 100
;     iDown.d = ProcessEX::SlowDown(ProcessID,iSlowDown_Percent,ntdll,Speed.d)
;     Delay(75):Debug Str(i)+"/ Set 'Slow Down "+iDown.d+" on' ("+Str(ProcessID)+") To  "+Str(_CpuAffinityMask)+" CPU/s"
; Next
; 
; iSlowDown_Percent.d = 100
; For i = 0 To 100
;     iDown.d = ProcessEX::SlowDown(ProcessID,iSlowDown_Percent,ntdll,Speed.d)
;     Delay(75):Debug Str(i)+"/ Set 'Slow Down "+iDown.d+" on' ("+Str(ProcessID)+") To  "+Str(_CpuAffinityMask)+" CPU/s"
; Next
; 
;  KillProcess(ProcessID)
; timeEndPeriod_(1)
;                         ProcessEX::TaskListCreate()                      
;                     ProcessEX::LHFreeMemGlobal("firefox.exe") 
    
    ;Debug ProcessEX::SetAffinityCPUS(1)
                   
    ;Debug ProcessEX::Get_Prozessor_String_W(Space(49))
    
    ;Debug ProcessEX::Get_CPU_MHz()
   ; Debug ProcessEX::GetCpuTaktInfo()
            
CompilerEndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 179
; Folding = DRh-
; EnableAsm
; EnableXP
; EnableUnicode