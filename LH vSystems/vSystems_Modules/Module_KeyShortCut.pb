DeclareModule vKeys   
    
    Declare   Init_Capture()
    Declare.i Init_Terminate() 
    
EndDeclareModule


Module vKeys
    ;
    ;
    ;     
    Procedure Init_Capture()

        ;
        ; Capture Screen Shot
        If  ( Startup::*LHGameDB\NBWindowhwnd  > 0 And 
              Startup::*LHGameDB\vKeyActivShot = #False) And
            ( Startup::*LHGameDB\Settings_NBNoShot = #False )
            
            RegisterHotKey_(  WindowID(DC::#_Window_001), 1, Startup::*LHGameDB\Settings_hkeyShot, #VK_SCROLL)
            
            Startup::*LHGameDB\vKeyActivShot = #True
            
            Debug "REGISTER HotKey to Capture Screenshot (Handle " + Str(Startup::*LHGameDB\NBWindowhwnd) + ")"
        EndIf         
    EndProcedure            
    ;
    ;
    ;    
    Procedure.i Init_Terminate()        
        
        If ( Startup::*LHGameDB\Settings_hkeyKill = #True )
            
            If IsProgram( Startup::*LHGameDB\Thread_ProcessLow ) And ( Startup::*LHGameDB\vKeyActivKill  = #False)
                RegisterHotKey_(  WindowID(DC::#_Window_001), 2, #MOD_ALT, #VK_SCROLL)
                
                Startup::*LHGameDB\vKeyActivKill = #True
                
                Debug "REGISTER HotKey to Kill Programm (Process ID: "+ Startup::*LHGameDB\Thread_ProcessLow +")"                                    
            EndIf
        EndIf        
    EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 13
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\MAME\