DeclareModule vUpdate
    
    Declare     Update_Check(bAutomatic = #False)
    
EndDeclareModule

Module vUpdate
    
    Structure CharString
         c.a[4096]
     EndStructure
     
    Procedure Ansi2Uni(ansi.s)
      Protected memziel
      
      SHStrDup_(@ansi, @memziel)
      
      ProcedureReturn memziel
    EndProcedure
       
    ;
    ;****************************************************************************************************************************************************      
    Procedure DownloadFile(Url.s, TargetPath.s)
      #INET_E_DOWNLOAD_FAILURE = $800C0008
      
      If Not DeleteUrlCacheEntry_(@Url)
        If GetLastError_() = #ERROR_ACCESS_DENIED
          ProcedureReturn #False
        EndIf
      EndIf
        
      Select URLDownloadToFile_(0, @Url, @TargetPath, 0, 0)
        Case #S_OK
          ProcedureReturn #True
        Case #E_OUTOFMEMORY, #INET_E_DOWNLOAD_FAILURE
          ProcedureReturn #False
      EndSelect
    EndProcedure       
    ;
    ;****************************************************************************************************************************************************      
    Procedure.s Update_GetLokalFile()
        
        Protected FileLokal.s = "D:/! Source Projects 5.60/LH vSystems/Release/vSystems64Bit.exe", sOut$
        
        For i = 1 To Len(FileLokal)
            
            char.c = Asc(Mid( FileLokal, i, 1))
            Select char
                Case '0' To '9'
                    sOut$ + Chr( char )                   
                Case 'a' To 'z'
                    sOut$ + Chr( char )
                Case 'A' To 'Z'
                    sOut$ + Chr( char )                    
                Case 32
                    sOut$ + "%20"
                Case 33 To 47, 58 To 63
                    sOut$ + Chr( char )
            EndSelect
        Next      
        
        sOut$ = "file:///"+sOut$
        
        ProcedureReturn sOut$ 
        
   EndProcedure
    ;
    ;****************************************************************************************************************************************************  
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
    
    ;
    ;****************************************************************************************************************************************************  
    Procedure.i Request_NoNewUpdate(oldCRC.s, newCRC.s )
                               
        Request::MSG(Startup::*LHGameDB\TitleVersion, "Update", "Update wird nicht benötigt. vSystems ist auf dem neusten stand" + #CR$ + #CR$ +
                                                                "CRC (MD5) Alte Version: "+oldCRC +#CR$+
                                                                "CRC (MD5) Neue Version: "+newCRC ,2,0,ProgramFilename(),0,0,DC::#_Window_001 )
    EndProcedure    
    ;
    ;****************************************************************************************************************************************************
    Procedure.i Update_Copy()
        
        Protected FileToDownload.s, FileToSaveAs.s
        
        FileToDownload.s = Update_GetLokalFile()
        FileToSaveAs.s   = GetCurrentDirectory()+ GetFilePart( ProgramFilename() , #PB_FileSystem_NoExtension)
        FileToSaveAs     + ".VUPDATE"
        
        DownloadFile(FileToDownload, FileToSaveAs)        
        
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
; CursorPosition = 116
; FirstLine = 76
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\