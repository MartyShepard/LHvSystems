DeclareModule vUpdate
    
    Declare     Update_Check(bAutomatic = #False)
    
EndDeclareModule

Module vUpdate
    
    ;     Structure CharString
    ;          c.a[4096]
    ;      EndStructure
     
    ;     Procedure Ansi2Uni(ansi.s)
    ;       Protected memziel
    ;       
    ;       SHStrDup_(@ansi, @memziel)
    ;       
    ;       ProcedureReturn memziel
    ;     EndProcedure
       
    ;
    ;****************************************************************************************************************************************************      
    ;     Procedure DownloadFile(Url.s, TargetPath.s)
    ;       #INET_E_DOWNLOAD_FAILURE = $800C0008
    ;       
    ;       If Not DeleteUrlCacheEntry_(@Url)
    ;         If GetLastError_() = #ERROR_ACCESS_DENIED
    ;           ProcedureReturn #False
    ;         EndIf
    ;       EndIf
    ;         
    ;       Select URLDownloadToFile_(0, @Url, @TargetPath, 0, 0)
    ;         Case #S_OK
    ;           ProcedureReturn #True
    ;         Case #E_OUTOFMEMORY
    ;             ProcedureReturn #False 
    ;         Case #INET_E_DOWNLOAD_FAILURE
    ;             ProcedureReturn #False
    ;       EndSelect
    ;     EndProcedure       
    ;
    ;****************************************************************************************************************************************************      
    ;     Procedure.s Update_GetLokalFile()
    ;         
    ;         Protected FileLokal.s = "D:/! Source Projects 5.60/LH vSystems/Release/vSystems64Bit.exe", sOut$
    ;         
    ;         For i = 1 To Len(FileLokal)
    ;             
    ;             char.c = Asc(Mid( FileLokal, i, 1))
    ;             Select char
    ;                 Case '0' To '9'
    ;                     sOut$ + Chr( char )                   
    ;                 Case 'a' To 'z'
    ;                     sOut$ + Chr( char )
    ;                 Case 'A' To 'Z'
    ;                     sOut$ + Chr( char )                    
    ;                 Case 32
    ;                     sOut$ + "%20"
    ;                 Case 33 To 47, 58 To 63
    ;                     sOut$ + Chr( char )
    ;             EndSelect
    ;         Next      
    ;         
    ;         sOut$ = "file:///"+sOut$
    ;         
    ;         ProcedureReturn sOut$ 
    ;         
    ;    EndProcedure
    ;
    ;****************************************************************************************************************************************************  
    
    Structure tChar
       StructureUnion
          c.c
          s.s { 1 }
       EndStructureUnion
    EndStructure
    ;
    ;****************************************************************************************************************************************************    
    Procedure LineSplit (sText.s, List LinkedList.s ())
        Protected *Source .tChar       = @ sText
        
        
        If Not *Source
            ProcedureReturn #False
        EndIf
        
        AddElement ( LinkedList () )
        
        While *Source\c           
            Select  *Source\c 
                Case 10, 13                
                    AddElement ( LinkedList () )                                                   
                Default                  
                    LinkedList () + *Source\s                   
            EndSelect                 
            *Source  + SizeOf ( CHARACTER )          
        Wend
        
        ProcedureReturn #True
    EndProcedure
    ;
    ;****************************************************************************************************************************************************  
    Procedure.i Request_NoNewUpdate(oldCRC.s, newCRC.s )
                               
        Request::MSG(Startup::*LHGameDB\TitleVersion, "Update", "Keine neue Version verfügbar." + #CR$ + #CR$ +
                                                                "CRC (MD5) Alte Version: "+oldCRC +#CR$+
                                                                "CRC (MD5) Neue Version: "+newCRC ,2,0,ProgramFilename(),0,0,DC::#_Window_001 )
    EndProcedure    
    ;
    ;****************************************************************************************************************************************************  
    Procedure.i Request_FailUpdate_()
                               
        Request::MSG(Startup::*LHGameDB\TitleVersion, "Update", "Verbindungsfehler ..." ,2,1,ProgramFilename(),0,0,DC::#_Window_001 )
    EndProcedure      
    ;
    ;****************************************************************************************************************************************************  
    Procedure.i Request_IsOffline__()
                               
        Request::MSG(Startup::*LHGameDB\TitleVersion, "Update", "Keine Internet verbindung ..." ,2,0,ProgramFilename(),0,0,DC::#_Window_001 )
    EndProcedure     
    ;
    ;****************************************************************************************************************************************************  
    Procedure.s GetVersion(sHttFile.s)
        
        InitNetwork()
        
        Protected sData.s, bResult = #False
        
        NewList List.s ()
        
        *Buffer = ReceiveHTTPMemory(sHttFile)
        If *Buffer
            
            lSize = MemorySize(*Buffer)
            sData = PeekS(*Buffer, lSize, #PB_UTF8|#PB_ByteLength)
            
            LineSplit ( sData ,  List () )
            
            ForEach List ()
                lData.s = List ()
                lsPos.i = FindString(lData, "Version     =" )
                If ( lsPos >= 1 )
                    lData = ReplaceString( lData, "Version     =", "")
                    lData = Trim(lData)
                    lData = Mid( lData, 2, 5)
                    bResult = #True
                    Break
                EndIf                        
            Next                                                   
            FreeMemory(*Buffer)
            
            If ( bResult = #True)
                ProcedureReturn lData
            Else
                ProcedureReturn ""
            EndIf    
        Else
            If InetIsOffline_(#Null) = #False  
                Request_FailUpdate_()
            Else
                Request_IsOffline__()
            EndIf    
        EndIf
        
    EndProcedure
    ;
    ;****************************************************************************************************************************************************  
    Procedure.s Request_Update_Message()
        
        Protected NextVersion.s, tFile_Versions.s, UpdateMsg.s
            tFile_Versions = "https://github.com/MartyShepard/LHvSystems/raw/main/LH%20vSystems/vSystems_Modules/Module_Version.pb"
            
            NextVersion = GetVersion(tFile_Versions)   
            UpdateMsg.s = Startup::*LHGameDB\TitleVersion
            
            If Len(NextVersion) > 1
                
                If ( Startup::*LHGameDB\VersionNumber  = NextVersion )
                    UpdateMsg + " aktualisieren?" + #CR$ +"Version ist Identisch. Trotztdem aktualisieren?"    
                Else    
                    UpdateMsg + " auf Version " +  NextVersion + " aktualisieren?"
                EndIf                
            Else
                UpdateMsg + " aktualisieren? " +#CR$+ "( Problem beim holen der Version's Nummer )"
            EndIf
                       
            ProcedureReturn UpdateMsg
    EndProcedure    
    ;
    ;****************************************************************************************************************************************************  
       
    Procedure.i Request_Update()        
        ;
        ; Überprüft auf nicht gepeicherte Text Änderungen
        If ( vInfo::Modify_EndCheck() = #True )            
            
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Update", Request_Update_Message() ,11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            If Result = 0
                ProcedureReturn #True
            Else
                SetActiveGadget( DC::#ListIcon_001 )
                ProcedureReturn #False
            EndIf 

        EndIf
        
        ProcedureReturn #True
    EndProcedure              
    ;
    ;****************************************************************************************************************************************************        
    Procedure.i Update_Copy()                

        Protected FileToDownload.s, FileToSaveAs.s, NextVersion.s
        
      ; Debug
      ; FileToDownload.s = Update_GetLokalFile()

        FileToDownload.s = "https://github.com/MartyShepard/LHvSystems/raw/main/LH%20vSystems/Release/"
        
        If ( startup::*LHGameDB\bBuild32Bit = #False )
            FileToDownload + "vSystems64Bit.exe"
        Else
            FileToDownload + "vSystems32Bit.exe"
        EndIf        
        
        
        FileToSaveAs.s   = GetCurrentDirectory()+ GetFilePart( ProgramFilename() , #PB_FileSystem_NoExtension)        
        FileToSaveAs     + ".VUPDATE"                 
        
        If InetIsOffline_(#Null) = #False                       
            
            If ReceiveHTTPFile(FileToDownload, FileToSaveAs)
                
                UseMD5Fingerprint()
                
                oldCRC.s = FileFingerprint( ProgramFilename() , #PB_Cipher_MD5 )
                newCRC.s = FileFingerprint( FileToSaveAs , #PB_Cipher_MD5 )
                
                If ( oldCRC = newCRC )
                    
                    DeleteFile( FileToSaveAs )
                    
                    Request_NoNewUpdate(oldCRC, newCRC )
                    
                    SetActiveGadget( DC::#ListIcon_001 )
                Else    
                    
                    If CreateFile(DC::#UpdateModul, GetCurrentDirectory() + "_UpdateModul_.exe" ) 
                        WriteData(DC::#UpdateModul,DC::?_UPDATEMODUL_BEG, DC::?_UPDATEMODUL_END- DC::?_UPDATEMODUL_BEG)
                        CloseFile(DC::#UpdateModul) 
                    EndIf         
                    
                    Startup::*LHGameDB\bUpdateProcess = #True 
                    Startup::*LHGameDB\ProgrammQuit  =  #True
                EndIf                 
            Else
                Request_FailUpdate_()
            EndIf            
        Else
            Request_IsOffline__()
        EndIf
        
    EndProcedure

    ;
    ;****************************************************************************************************************************************************    
    Procedure Update_Check(bAutomatic = #False)
        
        If (bAutomatic = #False)
            
            If ( Request_Update() = #True )
                Update_Copy()
            EndIf    
        EndIf
        
    EndProcedure    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 201
; FirstLine = 57
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\