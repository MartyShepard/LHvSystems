

CompilerIf #PB_Compiler_IsMainFile
CompilerEndIf


DeclareModule INIValue
  Declare.s Get_S(Section.s,Key.s,iFile.s)                  ; Bezieht den String
  Declare.i Get_I(Section.s,Key.s,iFile.s)                  ; Beziht den String als Integer
  Declare.i Get_Value(Section.s,Key.s,iFile.s)              ; Holt die Value Trut/False als Integer 0/1
  Declare.i Set_Value(Section.s,Key$,TrueFalse.i,iFile.s)   ; Setzt die Value True/False in der Ini (Übergabe als Integer 0/1)
  Declare.i Set(Section$,Key$,iValue$,iFile$)               ; Setzt die Value in das Ini (Übergabe als String)
EndDeclareModule

Module INIValue
;/////////////////////////////////////////////////////////////////////////////////////////////////// 
;                                                                      Read and Return to a String
    Procedure.s Get_S(Section.s,Key.s,iFile.s) 
        Protected iValue$, ValueString.l
        
        iValue$ = Space(4096) 
        ValueString.l = GetPrivateProfileString_ (Section, Key, '', iValue$, Len(iValue$), iFile) 
        iValue$ = Left(iValue$, ValueString.l) 
        ProcedureReturn iValue$
        
    EndProcedure

;/////////////////////////////////////////////////////////////////////////////////////////////////// 
;                                                                    Read and Return as a Integer
    Procedure.i Get_I(Section.s,Key.s,iFile.s) 
        Protected iValue$, ValueString.l, lValue.l
        
        iValue$ = Space(255) 
        ValueString.l = GetPrivateProfileString_ (Section, Key, '', iValue$, Len(iValue$), iFile) 
        iValue$ = Left(iValue$, ValueString.l)
        ProcedureReturn Val(iValue$)
        
    EndProcedure

;/////////////////////////////////////////////////////////////////////////////////////////////////// 
;                                          Read False/or True String and Return to a Integer as 0/1
    Procedure.i Get_Value(Section.s,Key.s,iFile.s) 
        Protected iValue$, ValueString.l, lValue.l
        
        iValue$ = Space(7) 
        ValueString.l = GetPrivateProfileString_ (Section.s, Key, '', iValue$, Len(iValue$), iFile) 
        iValue$ = Left(iValue$, ValueString.l)
        
        Select LCase(iValue$)
            Case "true"
                ProcedureReturn 1
            Case "false"    
                ProcedureReturn 0
            Case "default"                 
                ProcedureReturn -1
            Default    
                INIValue::Set_Value(Section.s,Key.s,0,iFile.s)                
                ProcedureReturn 0 
        EndSelect
        ProcedureReturn 0 
    EndProcedure
    
;/////////////////////////////////////////////////////////////////////////////////////////////////// 
;                                          Read False/or True String and Return to a Integer as 0/1
    Procedure.i Set_Value(Section.s,Key$,TrueFalse.i,iFile.s) 
        
        Protected iValue$, ValueString.l, lValue.l
        Select TrueFalse.i
            Case 0
                WritePrivateProfileString_(Section.s, Key$, "false",iFile.s)
                ProcedureReturn 0
            Case 1
                WritePrivateProfileString_(Section.s, Key$, "true",iFile.s)
                ProcedureReturn 0
            Case -1
                WritePrivateProfileString_(Section.s, Key$, "default",iFile.s)
                ProcedureReturn 0                
            Default
                Debug "ERROR: Write on INI: "+iFile.s+" /TrueFalse Variable" 
                ProcedureReturn 1
          EndSelect                
    EndProcedure
    
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
;
    Procedure.i Set(Section$,Key$,iValue$,iFile$)
        Protected IniError.i
        IniError = WritePrivateProfileString_(Section$, Key$, iValue$,iFile$) 
        ProcedureReturn IniError
    EndProcedure     
EndModule 


CompilerIf #PB_Compiler_IsMainFile
    INIValue::Set("Test","Test","Haloo",GetHomeDirectory()+"\Desktop\disciple.ini")
CompilerEndIf    
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 6
; FirstLine = 5
; Folding = P-
; EnableAsm
; EnableUnicode
; EnableThread
; EnableXP
; Compiler = PureBasic 5.42 LTS (Windows - x86)