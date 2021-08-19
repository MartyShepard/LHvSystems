DeclareModule cCommandLine
    
    Declare StartUp()
    
EndDeclareModule    


Module cCommandLine
    ;==============================================================================================================
    ;
    ;      
    Procedure.s Rem_Commandline_Chr34(FilePath$)
        Protected Chr39.i
        
        If ( Left(FilePath$,1) = Chr(34) )
            FilePath$ = ReplaceString(FilePath$,Chr(34),"",1,1,1)
        EndIf
        
        If ( Right(FilePath$,1) = Chr(34) )
            FilePath$ = ReplaceString(FilePath$,Chr(34),"",1,Len(FilePath$),1)
        EndIf                        
        
        If ( FileSize(FilePath$) = -2)            
            If ( Right(FilePath$,1) <> "\" )
                FilePath$ + "\"
            EndIf         
        EndIf
        
        ;
        ; Ersetze die ' duch Anführungszeichen zeichen      
        If ( CountString(FilePath$,Chr(39)) = 2 )                
            FilePath$ = ReplaceString(FilePath$,Chr(39),"",1,1,CountString(FilePath$,Chr(39))) 
        EndIf
            
        ProcedureReturn FilePath$
    EndProcedure    
    ;==============================================================================================================
    ;
    ;      
    Procedure.s Rem_Commandline_Param(Argument$, ParamIndex)
        
        Argument$ = PeekS(GetCommandLine_())
        Argument$ = ReplaceString(Argument$,ProgramFilename(),"")
        Argument$ = Mid(Argument$,4,Len(Argument$)-1)
        Argument$ = Trim(Argument$)                                
        Argument$ = ReplaceString(Argument$,ProgramParameter(ParamIndex),"")
        Argument$ = Trim(Argument$)                        
        ProcedureReturn Argument$
        
    EndProcedure  
    ;==============================================================================================================
    ;
    ;    
    Procedure.s Get_CommandLine()
        
        Protected ParamArgs, PGameArgs, ParamIndex, Argument$, LHCout.i, NoIniCmd.i = -1, svLen.i, Request0$, Request1$, Request2$
        Protected Switches.i = #False, ResultMSG.i, NICout.i, Sign39.i
                
        ParamArgs = CountProgramParameters() - 1
        
        If (ParamArgs <> -1)  
            
            For ParamIndex.i = 0 To  ParamArgs              
                
                Argument$ = ProgramParameter(ParamIndex)
                
                Select Argument$
                    Case "-m", "--m", "%m" ; Mame Path+Exe  
                        
                        Switches = #True                        
                        
                        Argument$ = Rem_Commandline_Param(Argument$, ParamIndex)                                                                               
                        Argument$ = Rem_Commandline_Chr34(Argument$)
                        
                        Select FileSize(Argument$)
                            Case 0,-1
                              Request::MSG(MameStruct::*mameExt\Title,"ERROR", LOCALE::ILoc023(GetFilePart(Argument$)),6,2,ProgramFilename()): End
                        EndSelect 
                        Break                        
                        
                        
                    Case "-p", "--p", "%p" ; Mame Path
                        ;
                        Switches = #True                        
                        Argument$ = Rem_Commandline_Param(Argument$, ParamIndex)   
                        Argument$ = Rem_Commandline_Chr34(Argument$)                                                                       
                                       
                        Break
                    Case "-h", "--h", "%h", "-?", "--?", "%?"
                        ;
                        Request::MSG(MameStruct::*mameExt\Title, "Help: Argument Switches", LOCALE::ILoc007(),2,0,ProgramFilename())
                        End                          
                EndSelect           
            Next      
            
            If (Switches = #False) And (ParamArgs >= 0)                                 
                ;
                Request::MSG(MameStruct::*mameExt\Title, "Error",LOCALE::ILoc008(ProgramParameter(ParamArgs)),6,2,ProgramFilename())
                End
            EndIf
                                                
            ProcedureReturn Argument$
        EndIf              
       EndProcedure      
    ;==============================================================================================================
    ;
    ;
    Procedure.s Check_Executable(argPath$, DirPath$)
        
        Protected Versions.i, ExePart.i, FilePath$
        
        If DirPath$
            For Versions = 0 To 2500
                
                For ExePart = 1 To 6
                    Select ExePart
                        Case Versions To 3
                            FilePath$ = DirPath$ + "mame" +  StringField(",64,_emucr", ExePart, ",")                                
                        Default
                            FilePath$ = DirPath$ + "mame" +  StringField(",_,64_,_0,_1,_2", ExePart, ",") + Versions
                    EndSelect            
                    Debug FilePath$ + ".exe"
                    If ( FileSize(FilePath$ + ".exe") >= 1 )
                        ProcedureReturn FilePath$ + ".exe"
                    EndIf    
                Next
            Next          
        EndIf
         
         ;
         ; argPath beeinhaltet die exe und vollen path
         If argPath$
            If ( FileSize(FilePath$ + ".exe") >= 1 )
                ProcedureReturn FilePath$ + ".exe"
            EndIf                     
         EndIf
        
        ProcedureReturn ""
    EndProcedure
    ;==============================================================================================================
    ;
    ;        
    Procedure StartUp()
        
        Protected MamePath$, SourceKey$, SourceINI$
        SourceKey$ = "Settings"
        
        MamePath$ = Get_CommandLine()
        Select FileSize(MamePath$)                            
            Case -2                                
                MamePath$ = Check_Executable("", MamePath$)
            Default    
                MamePath$ = Check_Executable(MamePath$, "")
        EndSelect
        
        If ( FileSize(MamePath$) >= 1 )            
           SourceINI$ = GetPathPart(MamePath$) + MameStruct::*mameExt\Prefs 
           If ( FileSize(SourceINI$) >=1 )             
                MamePath$ = INIValue::Get_S(SourceKey$, "Mame Path", SourceINI$)
           EndIf    
                            
       Else
            SourceINI$ = GetPathPart(MameStruct::*mameExt\RootPath) + MameStruct::*mameExt\Prefs 
            If ( FileSize(SourceINI$) >= 1 )
                MamePath$ = INIValue::Get_S(SourceKey$, "Mame Path", SourceINI$)
            Else                
                MamePath$ =  Check_Executable("",MameStruct::*mameExt\RootPath)            
             EndIf   
             
        EndIf    
            
        If ( FileSize(MamePath$) <= 0 )   
            MamePath$ = GetCurrentDirectory()
            MamePath$ = Check_Executable("", MamePath$)
            If ( FileSize(MamePath$) <= 0)                
                MamePath$ = FFH::GetFilePBRQ("Select Mame",GetCurrentDirectory(), #False,  "Mame|mame*.exe",  0, #False) 
            EndIf
        EndIf
        
        If ( FileSize(SourceINI$) = -1 )    
            nxgConfig::Write_Config(GetCurrentDirectory())
            MameStruct::*mameExt\Prefs = GetCurrentDirectory() + MameStruct::*mameExt\Prefs
        EndIf    
        If ( FileSize(MamePath$) >= 1 )  And  ( FileSize(SourceINI$) >= 1 )
            MameStruct::*mameExt\Prefs = SourceINI$
        EndIf               
        
        If ( FileSize(MamePath$) >= 1 ) 
            MameStruct::*mameExt\RootPath = GetPathPart(MamePath$)
            
        EndIf              
        
        
        If ( FileSize(MamePath$) >= 1)                        
            
 
        
            MameStruct::*mameExt\RootPath       = GetPathPart(MamePath$)
            
            If ( FileSize(GetPathPart(MamePath$) + "ini\mame.ini") >= 1 ) 
                MameStruct::*mameExt\Mame_ini       = GetPathPart(MamePath$) + "ini\mame.ini"
            Else
                MameStruct::*mameExt\Mame_ini       = GetPathPart(MamePath$) + "mame.ini"
            EndIf    
            
            If ( FileSize( GetPathPart(MamePath$) + "ini\ui.ini") >= 1 ) 
                MameStruct::*mameExt\Mame_iui       = GetPathPart(MamePath$) + "ini\ui.ini"
            Else
                MameStruct::*mameExt\Mame_iui       = GetPathPart(MamePath$) + "ui.ini"
            EndIf  
        
            MameStruct::*mameExt\LastDirectory  = GetPathPart(MamePath$)
            MameStruct::*mameExt\NonUI          = GetFilePart(MamePath$)
            SourceINI$ = MameStruct::*mameExt\Prefs
            
            SourceKey$ = "Settings Picture"                       
            MameStruct::*mameExt\PictureMode    = INIValue::Get_I(SourceKey$, "Mode", SourceINI$)   
            
            SourceKey$ = "Settings"
            INIValue::Set(SourceKey$, "Mame Path", MamePath$, SourceINI$)             
            ;
            ; Check for Inis
            
            If FileSize(MameStruct::*mameExt\Mame_ini) = -1                                      
                ;
                Request::MSG(MameStruct::*mameExt\Title,"Error", LOCALE::ILoc005(MameStruct::*mameExt\Mame_ini),6,2,ProgramFilename())
                End
            EndIf
            
            If FileSize(MameStruct::*mameExt\Mame_iui) = -1                                    
                ;
                Request::MSG(MameStruct::*mameExt\Title,"Error", LOCALE::ILoc006(MameStruct::*mameExt\Mame_iui),6,2,ProgramFilename())
                End
            EndIf              
            ProcedureReturn
        EndIf
        Request::MSG(MameStruct::*mameExt\Title,"ERROR",LOCALE::ILoc004(MamePath$),2,1,ProgramFilename())
        
        
    EndProcedure
    ;==============================================================================================================
    ;
    ;
    ;==============================================================================================================
    ;
    ;
    ;==============================================================================================================
    ;
    ;    
EndModule    
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 236
; FirstLine = 189
; Folding = --
; EnableAsm
; EnableUnicode
; EnableXP
; UseMainFile = ..\LHMOpt.pb
; CurrentDirectory = ..\Release\mame0172b_64bit\