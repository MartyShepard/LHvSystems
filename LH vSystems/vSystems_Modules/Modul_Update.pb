DeclareModule vUpdate
    
    Declare     Update_Check(bAutomatic = #False)
    
EndDeclareModule

Module vUpdate
    
    Procedure Ansi2Uni(ansi.s)
      Protected memziel
      
      SHStrDup_(@ansi, @memziel)
      
      ProcedureReturn memziel
    EndProcedure

    Procedure.i Update_Copy()
        
    If OpenLibrary(#PB_Any,"shdocvw.dll")
        CallFunction(#UpdateFile, "DoFileDownload", Ansi2Uni("file:///D:/!%20Source%20Projects%205.60/LH%20vSystems/Release/vSystems64Bit.exe"))
    EndIf        
        
    
    Procedure.i Request_Update()
        
        ;
        ; Überprüft auf nicht gepeicherte Text Änderungen
        If ( vInfo::Modify_EndCheck() = #True )
            
            
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Update Test", Startup::*LHGameDB\TitleVersion + " Updaten ?",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            If Result = 0
                ProcedureReturn #True
            EndIf 

        EndIf
        
        ProcedureReturn #True
    EndProcedure 
    
    Procedure Update_Check(bAutomatic = #False)
        
        If (bAutomatic = #False)
            
            If ( Request_Update() = #True )
                Update_Copy()
            EndIf    
        EndIf
        
    EndProcedure    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 2
; Folding = --
; EnableAsm
; EnableXP