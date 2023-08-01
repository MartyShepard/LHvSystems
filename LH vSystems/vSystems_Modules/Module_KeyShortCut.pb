DeclareModule vKeys   
    
    Declare   Init_Capture()
    Declare   Init_MM3DFocus()
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
            RegisterHotKey_(  WindowID(DC::#_Window_001), 10, Startup::*LHGameDB\Settings_hkeyShot, #VK_SCROLL)
            
            Startup::*LHGameDB\vKeyActivShot = #True
            
            Debug "Init_Capture(): REGISTER HotKey to Capture Screenshot (Handle " + Str(Startup::*LHGameDB\NBWindowhwnd) + ")"
        EndIf         
    EndProcedure            
    ;
    ;
    ;                
    Procedure.i Init_Terminate()        
        
        If ( Startup::*LHGameDB\Settings_hkeyKill = #True )
            
            If IsProgram( Startup::*LHGameDB\Thread_ProcessLow ) And ( Startup::*LHGameDB\vKeyActivKill  = #False)
                RegisterHotKey_(  WindowID(DC::#_Window_001), 20, #MOD_ALT, #VK_SCROLL)
                
                Startup::*LHGameDB\vKeyActivKill = #True
                
                Debug "Init_Terminate() REGISTER HotKey to Kill Programm (Process ID: "+ Startup::*LHGameDB\Thread_ProcessLow +")"                                    
            EndIf
          
          	If ( Startup::*LHGameDB\Thread_ProcessLow > 0) And ( Startup::*LHGameDB\Settings_aExecute  = #True)
                RegisterHotKey_(  WindowID(DC::#_Window_001), 20, #MOD_ALT, #VK_SCROLL)
                
                Startup::*LHGameDB\vKeyActivKill = #True
                
                Debug "Init_Terminate() REGISTER HotKey to Kill Programm (Process ID: "+ Startup::*LHGameDB\Thread_ProcessLow +")"            	
          EndIf  
            
      EndIf   
      
      
    EndProcedure
    ;
    ;
    ;     
    Procedure Init_MM3DFocus()

        If  ( Startup::*LHGameDB\NBWindowhwnd  > 0 And 
              Startup::*LHGameDB\vKeyActivMMBT = #False)           
              Startup::*LHGameDB\vKeyActivMMBT = #True
            
            Debug "Init_MM3DFocus(): REGISTER Mouse Button 3 für Focus/Defocus (Handle " + Str(Startup::*LHGameDB\NBWindowhwnd) + ")"                     
        EndIf  
        
    EndProcedure     
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 48
; FirstLine = 2
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\MAME\