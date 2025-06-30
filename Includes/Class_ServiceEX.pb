DeclareModule ServiceEX
  
  Declare.i Service_Start(Servicename$)
  Declare.i Service_Stop(Servicename$)
  Declare.i Service_Exists(Servicename$)
EndDeclareModule
    
Module ServiceEX
    ;******************************************************************************************************************************************
    ;   Service_Start    
    Procedure Service_Start(Servicename$)
        Protected hSCManager, hServ, lResult
        hSCManager = OpenSCManager_(#Null, #Null, #GENERIC_READ	| #SC_MANAGER_CONNECT)
        If hSCManager
            hServ = OpenService_(hSCManager, Servicename$, #GENERIC_EXECUTE)
            If hServ
                lResult = StartService_(hServ, 0, #Null)
                CloseServiceHandle_(hServ)
            EndIf
            CloseServiceHandle_(hSCManager)
        EndIf
        If hServ And lResult
            ProcedureReturn #True
        EndIf
        ProcedureReturn #False
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Service_Stop  
    Procedure Service_Stop(Servicename$)
        
        Protected hSCManager, hServ, lResult
        Protected *p.SERVICE_STATUS = AllocateMemory(SizeOf(SERVICE_STATUS))
        
        hSCManager = OpenSCManager_(#Null, #Null, #GENERIC_READ   | #SC_MANAGER_CONNECT)
        If hSCManager
            hServ = OpenService_(hSCManager, Servicename$, #GENERIC_EXECUTE)
            If hServ
                If *p
                    lResult = ControlService_(hServ, #SERVICE_CONTROL_STOP, *p)
                    FreeMemory(*p)
                EndIf
                CloseServiceHandle_(hServ)
            EndIf
            CloseServiceHandle_(hSCManager)
        EndIf
        
        If hServ And lResult
            ProcedureReturn #True
        EndIf
        ProcedureReturn #False
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Service_Exists    
    Procedure Service_Exists(Servicename$)
        Protected hSCManager, hServ
        hSCManager = OpenSCManager_(#Null, #Null, #GENERIC_READ	| #SC_MANAGER_CONNECT)
        If hSCManager
            hServ = OpenService_(hSCManager, Servicename$, #GENERIC_READ)
            If hServ
                CloseServiceHandle_(hServ)
            EndIf
            CloseServiceHandle_(hSCManager)
        EndIf
        If hServ
            ProcedureReturn #True
        EndIf
        ProcedureReturn #False
    EndProcedure 
 EndModule


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 4
; Folding = -
; EnableXP
; EnableAdmin
; EnableUnicode