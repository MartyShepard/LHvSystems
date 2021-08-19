Module DB_Migrate
        
    ;****************************************************************************************************************************************************
    ;    
    ; Schliesse Datenbank
    ;      
    Procedure Base_Close(BaseNumb.i, BaseName$)
        
        Protected Result.s
        
        Result = ExecSQL::CloseDB(BaseNumb,Startup::*LHGameDB\Base_Path)
        
        If ( Result <> "" )                                                         
            Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","vSystems has Stopped: "+BaseName$ + " ("+Result+")" ,2,2)
            End
        EndIf
              
    EndProcedure 
    ;****************************************************************************************************************************************************
    ;    
    ; Kopiere Datenbank/ Backup
    ;      
    Procedure.s Base_Backup(File$)
        
        Protected BackupBase$, BackupBuild$, BackupTime$, Result.i
                  
        BackupBuild$ = FormatDate("%yyyy-%mm-%dd,", #PB_Compiler_Date) 
        BackupTime$  = FormatDate("%hh-%mm-%ss", #PB_Compiler_Date)
                
        BackupBase$ = Startup::*LHGameDB\SubF_vSys + GetFilePart( File$ , 1) +" "+BackupBuild$ + BackupTime$ + ".DB"
        
        Debug File$
        Debug BackupBase$
        If ( CopyFile( File$, BackupBase$) ! 0)
            
            If ( FileSize( File$ ) = FileSize( BackupBase$ ) )
                ProcedureReturn BackupBase$
            EndIf    
        EndIf    
            
        Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","vSystems has Stopped: Could'nt Backup " +GetFilePart( File$ , 1),2,2)
        End    
    EndProcedure
    ;****************************************************************************************************************************************************
    ;    
    ; Lösche die alten Datenbanken
    ;      
    Procedure.s Base_Delete(File$)    
        
        If FileSize( File$ ) >= 0
            If ( DeleteFile( File$,#PB_FileSystem_Force ) = 0 )
                Request::MSG(Startup::*LHGameDB\TitleVersion, "W.T.F: ","vSystems has Stopped: Could'nt Remove " +GetFilePart( File$ , 1),2,2)
                End                
            EndIf    
        EndIf
        
    EndProcedure    
    ;****************************************************************************************************************************************************
    ;    
    ; Vorbereiten zum schliessen
    ;     
    Procedure.i Prepare_Migrate_CloseDB()                      
        Base_Close(DC::#Database_001, "#Database_001")                    
    EndProcedure   
    ;****************************************************************************************************************************************************
    ;    
    ; Kopiere und erstelle Backup von der alten Datenbank
    ; 
    Procedure Prepare_Migrate_BackupB()        
        *LHBackupDB\Base_Game = Base_Backup(Startup::*LHGameDB\Base_Game)                               
    EndProcedure 
    ;****************************************************************************************************************************************************
    ;    
    ; Lösche die alten
    ;     
    Procedure Prepare_Migrate_DeleteO()        
        Base_Delete(Startup::*LHGameDB\Base_Game)    
        Base_Delete(Startup::*LHGameDB\Base_Strt)      
    EndProcedure    
    ;****************************************************************************************************************************************************
    ;    
    ; Vorbereiten zum schliessen
    ;          
    Procedure Prepare_Migrate()
        
        Prepare_Migrate_CloseDB()         
        Prepare_Migrate_BackupB() 
        Prepare_Migrate_DeleteO() 
        
    EndProcedure
    
    
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 77
; FirstLine = 13
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\