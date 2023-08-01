DeclareModule Monitoring
    
    Declare.i   Activate(Path.s, Stop.i = #False)
    Declare.i   DeActivate()
    
EndDeclareModule

Module Monitoring
    
    
    #FILE_NOTIFY_CHANGE_FILE_NAME   = 1
    #FILE_NOTIFY_CHANGE_DIR_NAME    = 2
    #FILE_NOTIFY_CHANGE_ATTRIBUTES  = 4
    #FILE_NOTIFY_CHANGE_SIZE        = 8
    #FILE_NOTIFY_CHANGE_LAST_WRITE  = $10
    #FILE_NOTIFY_CHANGE_LAST_ACCESS = $20
    #FILE_NOTIFY_CHANGE_CREATION    = $40
    #FILE_NOTIFY_CHANGE_SECURITY    = $100
    #FILE_NOTIFY_CHANGE_ALL         = $17F
    #FILE_SHARE_DELETE              = 4
    #FILE_ACTION_ADDED              = 1
    #FILE_ACTION_REMOVED            = 2
    #FILE_ACTION_MODIFIED           = 3
    #FILE_ACTION_RENAMED_OLD_NAME   = 4
    #FILE_ACTION_RENAMED_NEW_NAME   = 5
  
    Structure FILE_NOTIFY_INFORMATION
        NextEntryOffset.l
        Action.l
        FileNameLength.l
        Filename.s{255}
    EndStructure
       
    Import "kernel32.lib"
        ReadDirectoryChangesW(a, b, c, d, e, f, g, h)
    EndImport
    
    Global StreamThreaded = 0
    
    Procedure StreamThread_WriteString(FileAction.s, ActionMessage.s)
        
        Protected szDate.s, szTime.s, szString.s
        
          If ( Startup::*LHGameDB\Monitoring\LogHandle > 0)
              
                szDate    = FormatDate("%yyyy/%mm/%dd", Date())
                szTime    = FormatDate("%hh:%ii:%ss"  , Date())    
                
                szString  = szDate + " " + szTime + ActionMessage +  Startup::*LHGameDB\Monitoring\Directory + FileAction
                
                WriteStringN(  Startup::*LHGameDB\Monitoring\LogHandle , szString)
                
                Debug "Monitoring "+ szString               
          EndIf         
        
    EndProcedure
    ;
    ;
    ;
    Procedure StreamThread(z)
        
        Protected NotifyFilter.l = #FILE_NOTIFY_CHANGE_ALL
        Protected FileAction.s
        Protected hDir
        Protected bytesRead
        Protected buffer.FILE_NOTIFY_INFORMATION, ovlp.OVERLAPPED

        
        hDir = CreateFile_( Startup::*LHGameDB\Monitoring\Directory, #FILE_LIST_DIRECTORY, #FILE_SHARE_READ | #FILE_SHARE_WRITE | #FILE_SHARE_DELETE, #Null, #OPEN_EXISTING, #FILE_FLAG_BACKUP_SEMANTICS, #Null)
        
        While ReadDirectoryChangesW(hDir, @buffer, SizeOf(FILE_NOTIFY_INFORMATION), #True, NotifyFilter, bytesRead, ovlp, 0)

            FileAction = PeekS(@buffer\Filename, -1, #PB_Unicode)
            
            ;
            ; Sammele keine unötigen Berichte über Aktivitäten mit der
            ; - NTUSER(.dat)
            If FindString(FileAction, "ntuser",1,#PB_String_NoCase )
                Continue
            EndIf
            ; - OPERAGX
            If FindString(FileAction, "\opera",1,#PB_String_NoCase )
                Continue
            EndIf
            ; - FireFox
            If FindString(FileAction, "\mozilla",1,#PB_String_NoCase )
                Continue
            EndIf            
                        
            
            Select buffer\Action
                Case #FILE_ACTION_ADDED     : StreamThread_WriteString(FileAction, " - Added    : ")
                Case #FILE_ACTION_REMOVED   : StreamThread_WriteString(FileAction, " - Deleted  : ")                    
                Case #FILE_ACTION_MODIFIED  : StreamThread_WriteString(FileAction, " - Modified : ")                    
                Case #FILE_ACTION_RENAMED_OLD_NAME  ;Dateiumbenennung: Alter Dateiname
                Case #FILE_ACTION_RENAMED_NEW_NAME  ;Dateiumbenennung: Neuer Dateiname
            EndSelect
            
            buffer\Filename = ""
            
        Wend
    EndProcedure
    ;
    ;
    ;
    Procedure.i Activate(Path.s, Stop.i = #False)
        
        Protected Date$, Time$         
        
        If  ( Startup::*LHGameDB\FileMonitoring = #False )
                        
            Path = "C:\"        
            
            Startup::*LHGameDB\Monitoring\Directory   = Path        
            Startup::*LHGameDB\Monitoring\LogHandle   = 0
            Startup::*LHGameDB\Monitoring\LatestLog   = ""
            
            Date$ = FormatDate("%yyyy_%mm_%dd", Date())
            Time$ = FormatDate("%hh_%ii_%ss"  , Date())            
            
            ;
            ; Verzeichnis Anlegen
            Select FileSize( Startup::*LHGameDB\Base_Path + "Systeme\")
                Case -1: CreateDirectory( Startup::*LHGameDB\Base_Path + "Systeme\" )                    
            EndSelect             
            ;
            ; Verzeichnis Anlegen
            Select FileSize( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\")
                Case -1: CreateDirectory( Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" )                    
            EndSelect 
            
            
            Date$ = FormatDate("%yyyy_%mm_%dd", Date())
            Time$ = FormatDate("%hh_%ii_%ss"  , Date())
            
            ;
            ; Sicher den Handle um diesen später zu überprüfen. Genriere den DateiNamen
            Startup::*LHGameDB\Monitoring\LogHandle =  OpenFile( #PB_Any,  Startup::*LHGameDB\Monitoring\LogPath + Date$ + "-" + Time$ + "-" + Startup::*LHGameDB\Monitoring\LogFile )      
            
            ;
            ; Letzte LogDatei über das Traymenü Öffnen           
            Startup::*LHGameDB\Monitoring\LatestLog =  Startup::*LHGameDB\Monitoring\LogPath + Date$ + "-"+ Time$ + "-" + Startup::*LHGameDB\Monitoring\LogFile

                                    
            If (  Startup::*LHGameDB\Monitoring\LogHandle )
                ;
                ; Schreibe Kppfstring 
                WriteString( Startup::*LHGameDB\Monitoring\LogHandle, "vSystems Monitoring: "+  Startup::*LHGameDB\Monitoring\Directory + #CR$ + #CR$ )                        
            EndIf
            
            Debug "Starte Monitoring"
            
            StreamThreaded = CreateThread(@StreamThread(),0)   
            
            Startup::*LHGameDB\FileMonitoring = #True
            
            ProcedureReturn  #True  
            
        ElseIf ( Startup::*LHGameDB\FileMonitoring = #True )
            
            Debug "Monitoring - Beende"            
            If IsThread(StreamThreaded)
                
                If ( Startup::*LHGameDB\Monitoring\LogHandle)                              
                    KillThread(StreamThreaded)   
                    
                    Delay( 5 )
                    
                    CloseFile( Startup::*LHGameDB\Monitoring\LogHandle)
                    
                    Delay( 5 )                     
                EndIf                
            EndIf
            
            StreamThreaded = 0
            Startup::*LHGameDB\Monitoring\LogHandle = 0
            Startup::*LHGameDB\FileMonitoring       = #False
            
            Debug "Monitoring - Beended"              
            
            ProcedureReturn  #True  
        EndIf
    EndProcedure     
    ;
    ;
    ;
    Procedure DeActivate()
        
        If ( Startup::*LHGameDB\FileMonitoring = #True)
            Activate("", #True)
        EndIf    
    EndProcedure    
    
EndModule

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 141
; FirstLine = 94
; Folding = f-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb