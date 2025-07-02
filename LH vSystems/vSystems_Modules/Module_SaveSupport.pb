DeclareModule SaveTool
    
	Declare.i FileCheck()
	Declare.i SaveFile_Close()
	Declare	 SaveContent_Delete()
	Declare   SaveConfig_AddCMD()
	Declare.i SaveConfig_AddGame()
	Declare   SaveConfig_Help()
	Declare	 SaveConfig_Edit(Option.i = 0)
	Declare.i SaveConfig_Create(Request.i = 0)
	Declare	 SaveContent_Backup(Options.i = 0, Request.i = 0)
	Declare	 SaveContent_Restore(Options.i = 0, Request.i = 0)
	Declare.i SaveContent_Compress()
	Declare.i SaveContent_Read()
	Declare.i SaveConfig_OpenSaves()
	Declare.i SaveConfig_ShowDirectories()
	Declare.i GetSaveOption(KeyOption.i)
	Declare.s SaveConfig_MenuFileExists()
	Declare.s SaveConfig_GetGameTitle()
	Declare   SaveConfig_GetGameTitle_ClipBaord()
	Declare.i SaveConfig_SetKeyValue(KeyValue.s = "Folder", FolderValue.i = 1, KeyBool.i = #False, KeyDelay.i = 250, NewGameTitle.s = "", OldGameTitle.s = "")	
	Declare.i SaveFile_ChangeTitle(NewGameTitle.s, OldGameTitle.s)
	
	;
	; Für den Automatischen Modus
	Declare.i SaveFile_GetRestore()
	Declare.i SaveFile_GetRestoreDelay()
	Declare.i SaveFile_GetBackup()
	Declare.i SaveFile_GetBackupDelay()	
	Declare.i SaveFile_GetBackupCompress()
	Declare	 CleanListing()
	
EndDeclareModule

Module SaveTool
	
; 	;======================================================================
; 	;                [ SHFileOperation API Procedure ]
; 	;======================================================================
; 	Procedure.l Button_Click(Index.l)
; 		
; 		;define variables
; 		lFileOp.f
; 		lresult.l
; 		lFlags.w
; 		
; 		;Get status of checkboxes
; 		ChkDir.l = GetGadgetState(#W1Check4) 
; 		ChkFilesOnly.l = GetGadgetState(#W1Check5) 
; 		ChkRename.l = GetGadgetState(#W1Check3) 
; 		ChkSilent.l = GetGadgetState(#W1Check1) 
; 		ChkYesToAll.l = GetGadgetState(#W1Check2)  
; 		
; 		;Get the edit box values
; 		FromDirectory.s = GetGadgetText(#W1String1) 
; 		ToDirectory.s = GetGadgetText(#W1String2)
; 		
; 		;Find out which button was pressed 
; 		Select Index
; 			Case 0
; 				lFileOp = #FO_COPY
; 			Case 1
; 				lFileOp = #FO_MOVE
; 			Case 2
; 				lFileOp = #FO_RENAME
; 			Case 3
; 				ChkYesToAll = 0      ;No mattter what - confirm Deletes! Prevents OOPS!
; 				lFileOp = #FO_DELETE
; 		EndSelect
; 		
; 		If ChkSilent:lFlags = lFlags | #FOF_SILENT: EndIf
; 		If ChkYesToAll: lFlags = lFlags | #FOF_NOCONFIRMATION:EndIf
; 		If ChkRename: lFlags = lFlags | #FOF_RENAMEONCOLLISION: EndIf
; 		If ChkDir: lFlags = lFlags | #FOF_NOCONFIRMMKDIR: EndIf
; 		If ChkFilesOnly: lFlags = lFlags | #FOF_FILESONLY: EndIf
; 		
; 		; NOTE:  If you add the #FOF_ALLOWUNDO Flag you can move
; 		;        a file to the Recycle Bin instead of deleting it.
; 		
; 		SHFileOp\wFunc = lFileOp
; 		SHFileOp\pFrom = @FromDirectory
; 		SHFileOp\pTo = @ToDirectory 
; 		SHFileOp\fFlags = lFlags
; 		
; 		lresult = SHFileOperation_(SHFileOp)
; 		
; 		;  If User hit Cancel button While operation is in progress,
; 		;  the fAnyOperationsAborted parameter will be true
; 		;  - see win32api.inc For Structure details.
; 		
; 		If lresult <> 0 | SHFileOp\fAnyOperationsAborted:EndIf: ProcedureReturn 0
; 		
; 		MessageRequester("Operation Has Completed", "PureBasic Rules!", 0)
; 		ProcedureReturn lresult
; 	EndProcedure

	Structure STRUCT_SAVETOOL
		Directory$
		GameTitle$
 	EndStructure        
 	Global NewList SaveDirectorys.STRUCT_SAVETOOL()
 	
	Structure STRUCT_SAVETOOLOPTIONS
		RestoreData.i
		BackupData.i
		RestoreDelay.i
		BackupDelay.i
		BackupCompress.i
 	EndStructure        
 	Global NewList SaveOptions.STRUCT_SAVETOOLOPTIONS()
 	
 	Structure STRUCT_FSDIRECTORY
 		Directoy.s
 		FullPath.s
 		DCount.i
 		FCount.i
	EndStructure
	Global NewList FileSystemList.STRUCT_FSDIRECTORY()
	
  Structure COMPRESSPARAMS
  	Directory.s
  	Count.i
  	PackFile.s
  EndStructure
  
   ;
   ; Prototyp = Procedure
  Prototype SHGetKnownFolderPath__(rfid, dwFlags.l, hToken, *ppszPath)
   ;    
   ; Hole den Windows programm CLSID Ordner
   ;     
  Procedure.s SHGetFolderPath_Function(*FOLDERID_CLSID)

  	 		Protected Result.s, *UnicodeBuffer, kfFlag.l, SHGetKnownFolderPath.SHGetKnownFolderPath__
        
        If *FOLDERID_CLSID = 0
        		Debug "Schwerwiegender Fehler im Modul RequestPathEx"
        		CallDebugger
        EndIf
        
        If OpenLibrary(0, "Shell32.dll")
            SHGetKnownFolderPath = GetFunction(0, "SHGetKnownFolderPath")
            If SHGetKnownFolderPath
                If SHGetKnownFolderPath(*FOLDERID_CLSID, kfFlag, #Null, @*UnicodeBuffer) = #S_OK And *UnicodeBuffer
                    Result = PeekS(*UnicodeBuffer, -1, #PB_Unicode) + "\"
                    CoTaskMemFree_(*UnicodeBuffer)
                EndIf
            EndIf
            CloseLibrary(0)
        EndIf
        
        If Result = ""
        	;Result = GetHomeDirectory()
        	
        EndIf        
        ProcedureReturn Result
	EndProcedure
  	;
		;  
  Procedure.s RemoveSlash(file.s)
  	
  	If ( Right(file, 1) = "\")
					ProcedureReturn Left( file, Len(file)-1)
		EndIf
				
		ProcedureReturn file
  EndProcedure	  
  	;
		;  
  Procedure.s Slash_Add(file.s)
  	
  	If Not ( Right(file, 1) = "\")
					ProcedureReturn file + "\"
		EndIf
				
		ProcedureReturn file
	EndProcedure		
		;    
    ; Hole den Windows Programm CLSID Ordner (Angabe Variabel, Returncode ist der echte Path)
		; 
	Procedure.s SHGetFolderPath(ShPath.s) 
    	    	
      Protected nPos.i, rPath.s = ShPath
      
  		Structure STRUCT_DATASH
         shData1.l
         shData2.w
         shData3.b
  		EndStructure
  
  
			Structure STRUCT_SHFOLDERS
				SHDirectory.s
				Username.s
				*STRUCT_DATASH.STRUCT_DATASH
 			EndStructure   
 			 			
 			NewList ShFolders.STRUCT_SHFOLDERS()
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%DESKTOP%\"				:ShFolders()\STRUCT_DATASH = ?FOLDERID_DESKTOP						:ShFolders()\Username = ""
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%DOCUMENTS%\" 		:ShFolders()\STRUCT_DATASH = ?FOLDERID_DOCUMENTS					:ShFolders()\Username = ""
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%APPDATA%\" 			:ShFolders()\STRUCT_DATASH = ?FOLDERID_RoamingAppData			:ShFolders()\Username = ""
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%LOCALAPPDATA%\" 	:ShFolders()\STRUCT_DATASH = ?FOLDERID_LOCALAPPDATA				:ShFolders()\Username = ""
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%USERPROFILE%\"		:ShFolders()\STRUCT_DATASH = ?FOLDERID_UserProfiles				:ShFolders()\Username = UserName() + "\"
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%SAVEDGAMES%\"		:ShFolders()\STRUCT_DATASH = ?FOLDERID_SavedGames					:ShFolders()\Username = ""
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%GAMETASKS%\"			:ShFolders()\STRUCT_DATASH = ?FOLDERID_GameTasks					:ShFolders()\Username = "" 
 			;
 			; Diese FOLDERID ist IN Windows 10 Version 1803 und höher veraltet. IN diesen Versionen wird 0x80070057 zurückgegeben: E_INVALIDARG
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%GAMES%\"					:ShFolders()\STRUCT_DATASH = ?FOLDERID_Games							:ShFolders()\Username = "" 
 			
 			AddElement( ShFolders() ): ShFolders()\SHDirectory = "%USERNAME%\"			:ShFolders()\STRUCT_DATASH = 0														:ShFolders()\Username = UserName() + "\" 
 			
 			;AddElement( ShFolders() ): ShFolders()\SHDirectory = "%HOMEDRIVE%\"
 			
		
			Debug "SaveSupport CLSID: Eingangs Verzeichnis: " + ShPath
			
 			ResetList( ShFolders() )
 			While NextElement(  ShFolders() )
 				
 				nPos = FindString(ShPath, ShFolders()\SHDirectory ,1,#PB_String_NoCase)
 				If (nPos > 0)
 					
 					If (Len( ShFolders()\Username )) > 0 And Not ( ShFolders()\SHDirectory = "%USERNAME%\" )
 						ShPath = ReplaceString(ShPath, ShFolders()\SHDirectory, ShFolders()\SHDirectory + ShFolders()\Username )
 					EndIf
 					 					
 					If ( UCase( ShFolders()\SHDirectory ) = "%USERNAME%\" )
 						; C:\users\%username%\.....
 						ShPath = ReplaceString(ShPath, ShFolders()\SHDirectory, ShFolders()\Username,#PB_String_NoCase   )
 						Break;
 					EndIf
 					ShPath = ReplaceString(ShPath, ShFolders()\SHDirectory, SHGetFolderPath_Function( ShFolders()\STRUCT_DATASH) )
 				EndIf
 			Wend 		
 			 			
 			FreeList ( ShFolders() )
 			
 			If ShPath = ""
 				ShPath = rPath
 			EndIf
 			
 			Debug "SaveSupport CLSID: Ausgangs Verzeichnis: " + ShPath
		ProcedureReturn ShPath
    EndProcedure
 		;
		;
 	Procedure SaveConfig_GetGameTitle_ClipBaord()
 		SetClipboardText(SaveConfig_GetGameTitle())
		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Restore","Der Spiele Titel wurde in die Zwischenablage gepeichert.",2,1,"",0,0,DC::#_Window_001)
 	EndProcedure 	
 		;
    ;
 	Procedure.s SaveConfig_GetGameTitle()
 		ProcedureReturn  ExecSQL::nRow(DC::#Database_001,"Gamebase","GameTitle","",Startup::*LHGameDB\GameID ,"",1)
 	EndProcedure	
		;
		;
	Procedure.i SaveFile_Read()		
			Startup::*LHGameDB\SaveTool\SaveHandle =  ReadFile( #PB_Any,  Startup::*LHGameDB\SaveTool\SaveFile )
	EndProcedure
    ;
    ;	      
	Procedure.i SaveFile_Open(lOptions = 0)
		Protected PBFileFlag.i
		
		Select lOptions
			Case 0: PBFileFlag = #PB_File_SharedRead| #PB_File_SharedWrite
			Case 1: PBFileFlag = #PB_File_SharedRead| #PB_File_SharedWrite|	#PB_File_Append ; #PB_File_Append = Sprint an das ende der Datei
			Case 2: PBFileFlag = #PB_File_SharedRead| #PB_File_SharedWrite
		EndSelect		
		
		Startup::*LHGameDB\SaveTool\SaveHandle =  OpenFile( #PB_Any,  Startup::*LHGameDB\SaveTool\SaveFile, PBFileFlag )
		Debug Startup::*LHGameDB\SaveTool\SaveHandle 
	EndProcedure 	
    ;
    ;     
	Procedure.i SaveFile_Create()		
			Startup::*LHGameDB\SaveTool\SaveHandle =  CreateFile( #PB_Any,  Startup::*LHGameDB\SaveTool\SaveFile )
	EndProcedure
    ;
    ;	 		
	Procedure.i SaveFile_Close()
		If ( Startup::*LHGameDB\SaveTool\SaveHandle )
			CloseFile( Startup::*LHGameDB\SaveTool\SaveHandle )
		EndIf
	EndProcedure
		;
		;
	Procedure.i SaveFile_GetRestore()
		
		Protected bValue.b
		bValue = #False
		If ListIndex( SaveOptions() )  > -1
			FirstElement( SaveOptions() )	
			bValue.b = SaveOptions()\RestoreData
		EndIf
		
		ProcedureReturn bValue
		
	EndProcedure
		;
		;
	Procedure.i SaveFile_GetRestoreDelay()
		
		Protected Value.i
		FirstElement( SaveOptions() )	
		Value.i = SaveOptions()\RestoreDelay
		ProcedureReturn Value
		
	EndProcedure	
		;
		;
	Procedure.i SaveFile_GetBackup()
		
		Protected bValue.b
		bValue = #False
		If ListIndex( SaveOptions() )  > -1		
				FirstElement( SaveOptions() )	
				bValue.b = SaveOptions()\BackupData
		EndIf		
		ProcedureReturn bValue
		
	EndProcedure
		;
		;
	Procedure.i SaveFile_GetBackupDelay()
		
		Protected Value.i
		FirstElement( SaveOptions() )	
		Value.i = SaveOptions()\BackupDelay
		ProcedureReturn Value
		
	EndProcedure	
		;
		;
	Procedure.i SaveFile_GetBackupCompress()
		
		Protected bValue.b
		FirstElement( SaveOptions() )	
		bValue.b = SaveOptions()\BackupCompress
		ProcedureReturn bValue
		
	EndProcedure		
		;
    ;	
  Procedure.i GetMaxItems()
        ResetList(SaveDirectorys())
        ProcedureReturn ListSize(SaveDirectorys())-1 
  EndProcedure   
    ;
		;
  Procedure.s ErrorCodes(Value.i)
  	
  	Select Value
  		Case 2, 3, 124:
  			ProcedureReturn "Not Found"
  		Case 4:
  			ProcedureReturn "Access is denied."
  		Case 14:  			
  			ProcedureReturn "The system cannot find the drive specified."  			
  		Case 19:
  			ProcedureReturn "The media is write protected."
  		Case 23:
  			ProcedureReturn "Data error (cyclic redundancy check)."
  		Case 25:
  			ProcedureReturn "The drive cannot locate a specific area or track on the disk."
  		Case 30:
  			ProcedureReturn "The system cannot read from the specified device."
  		Case 39:
  			ProcedureReturn "The disk is full."
  		Case 206:
  			ProcedureReturn "The filename or extension is too long." 
  		Case 222:
  			ProcedureReturn "The file type being saved or retrieved has been blocked."
  		Case 223:
  			ProcedureReturn "The file size exceeds the limit allowed and cannot be saved."
  		Case 224:
  			ProcedureReturn "Access Denied. Before opening files in this location, you must first add the web site to"+#CR$+
  			                   "your trusted sites list, browse to the web site, and select the option to login automatically."
  		Case 225:
  			ProcedureReturn "Operation did not complete successfully because the file contains a virus or potentially unwanted software."
  		Case 226:
  			ProcedureReturn "This file contains a virus or potentially unwanted software and cannot be opened. Due To" +#CR$+ 
  			                  "the nature of this virus Or potentially unwanted software, the file has been removed from" +#CR$+ 
  			                  "this location."
  		Default:
  			ProcedureReturn "unknown (Missing Description)"
  	EndSelect		
  	
  	ProcedureReturn ""
  EndProcedure	
  	;
		;  
	Procedure.i CleanListing()
        ClearList( SaveDirectorys() )
        ClearList( SaveOptions() )		
  EndProcedure
  	;
		;
  Procedure.i GetSaveOption(KeyOption.i)
  	
  	SaveContent_Read()  	
  	ResetList(SaveOptions())
  	Protected *Element = FirstElement(SaveOptions())
  	If *Element	
  		Protected Value.i
  		
  		Select KeyOption
  			Case 0:	Value = SaveOptions()\RestoreData
  			Case 1:	Value = SaveOptions()\BackupData
  			Case 2:	Value = SaveOptions()\RestoreDelay
  			Case 3:	Value = SaveOptions()\BackupDelay
  			Case 4:	Value = SaveOptions()\BackupCompress
  			Default
  				Value = -1
  		EndSelect  			
  	EndIf

  	CleanListing()
  	ProcedureReturn Value
  	  	
  EndProcedure
  	;
		;
  Procedure.s SaveConfig_MenuFileExists()
  	
  	Protected ConfigGameTitle.s = "", DataBaseGameTitle.s, Count.i, StatusMsg.s, CountFolder.i
  	If FileSize( Startup::*LHGameDB\SaveTool\SaveFile ) = -1
  		ProcedureReturn "Status: Keine Konfiguration"
  	EndIf
  	
  	SaveContent_Read()
  	
  	ResetList( SaveDirectorys() )
  	
  	Count = ListSize( SaveDirectorys() )
  	
  	Select Count
  		Case -1, 0
  			StatusMsg = "Status: Nicht Konfiguriert"
  		Default
  			FirstElement( SaveDirectorys() )
  			ConfigGameTitle		= SaveDirectorys()\GameTitle$
  			DataBaseGameTitle = SaveConfig_GetGameTitle()
  			
  			If LCase( DataBaseGameTitle ) = LCase( ConfigGameTitle )
  				StatusMsg = "Status: Konfiguration OK"
  				
	  			ResetList( SaveDirectorys() )
	  			ForEach SaveDirectorys()
	  				If Len( SaveDirectorys()\Directory$ ) > 0
	  					CountFolder + 1
	  				EndIf
	  			Next
	  			If ( CountFolder = 0 )
	  				StatusMsg = "Status: Keine Verzeichnisse"
	  			EndIf
	  			
  			Else
  				StatusMsg = "Status: Falscher Spieletitel"
  			EndIf
  			

  			
  	EndSelect

  	ClearList( SaveDirectorys() )
  	
  	ProcedureReturn StatusMsg
  EndProcedure
  	;
		;  
  Procedure.i SaveConfig_ShowDirectories()
  	
  	Protected HomeUserFolder.s = "", Count.i = 0
  	
  	If FileSize( Startup::*LHGameDB\SaveTool\SavePath ) = -2
  		
  		If Not FileSize( Startup::*LHGameDB\SaveTool\SaveFile ) = -1
  			ResetList(SaveDirectorys())
  			
  			ForEach SaveDirectorys() 	
  				HomeUserFolder.s +	Slash_Add( SaveDirectorys()\Directory$ ) + #CR$  				
  				Count + 1
  			Next	
  			
  			If ( Count = 0 )
  				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Keine Verzeichnisse Konfiguriert",2,2,"",0,0,DC::#_Window_001)
  				ProcedureReturn  0
  			EndIf	
  			
  			Protected Message.s = "Verzeichnisse die Kopiert werden:" + Chr(13) + Chr(13) + HomeUserFolder
  			HomeUserFolder = ""
  			
        Request::*MsgEx\User_BtnTextL = "Editieren"
        Request::*MsgEx\User_BtnTextM = "Verzeichnis"
        Request::*MsgEx\User_BtnTextR = "Abbruch"
        Request::*MsgEx\CheckBox_Txt 	= "Edititieren und Öffnen Mit..."
        Result = Request::MSG(Startup::*LHGameDB\TitleVersion,"vSystem Save Support",Message,16,-1,ProgramFilename(),1,0,DC::#_Window_001 )
        Debug "Result " + Str(Result)
        Select Result
        	Case 0: SaveConfig_Edit()
        	Case 2: SaveConfig_OpenSaves()
        	Case 4: SaveConfig_Edit(1)        	
        EndSelect
        
				CleanListing()
        ProcedureReturn  0
  			
  		Else
  			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","vSystem SaveSupport Konfigurations Datei wurde nicht gefunden." + #CR$ + 
  			                                                                     #CR$ + Startup::*LHGameDB\SaveTool\SaveFile,2,2,"",0,0,DC::#_Window_001)
  			ProcedureReturn 0
  		EndIf
  	Else
  		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","vSystem Internes Save Backup Verzeichnis nicht gefunden."+ #CR$ +
  		                                                                     #CR$ + Startup::*LHGameDB\SaveTool\SavePath+"\",2,2,"",0,0,DC::#_Window_001)
  		ProcedureReturn 0
  	EndIf
  EndProcedure
  	;
		;
  Procedure.i FileSystem_Search(DirectoryPath.s = "", CheckAttrib.i = #False)
  	
  	Debug 	"Save Support: FileSearch (BEG)" 
  	Protected FileHandle.WIN32_FIND_DATA
  	
  	Protected FileSystemType.s = ""
  	Protected FileSystemSize.q = 0
  	
  	Result.l = FindFirstFile_(DirectoryPath + "*", FileHandle)
  	If ( Result > 0 )
  		
  		While FindNextFile_(Result, FileHandle)
  			
  			FileSystemType = PeekS(@FileHandle\cFileName[0]) 
  			
  			
  			If FileSystemType = "." Or FileSystemType = ".."
  				Continue
  			EndIf
  			
  			Select FileHandle\dwFileAttributes:
  					
  				Case 1, 2, 3, 4, 5, 32, 33, 128, 129, 2048, 2049, 8224
  					Select FileHandle\dwFileAttributes:
  						Case 1:			;Debug "   1=FILE_ATTRIBUTE_READONLY"
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Datei ist Schreibgeschütz" + Chr(32) + DirectoryPath + FileSystemType,2,2,"",0,0,DC::#_Window_001)
  						Case 2:			;Debug "   2=FILE_ATTRIBUTE_HIDDEN"
  						Case 3:			;Debug "   2=FILE_ATTRIBUTE_HIDDEN  [& FILE_ATTRIBUTE_READONLY]"
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Datei ist Schreibgeschütz" + Chr(32) + DirectoryPath + FileSystemType,2,2,"",0,0,DC::#_Window_001)
  						Case 4:			;Debug "	 4=FILE_ATTRIBUTE_SYSTEM"
  						Case 5:			;Debug "	 4=FILE_ATTRIBUTE_SYSTEM [& FILE_ATTRIBUTE_READONLY]"  							
  						Case 32:		;Debug "  32=FILE_ATTRIBUTE_ARCHIVE"
  						Case 33:		;Debug "  32=FILE_ATTRIBUTE_ARCHIVE [& FILE_ATTRIBUTE_READONLY]"
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Datei ist Schreibgeschütz" + Chr(32) + DirectoryPath + FileSystemType,2,2,"",0,0,DC::#_Window_001)
  						Case 128:		;Debug " 128=FILE_ATTRIBUTE_NORMAL"
  						Case 129:		;Debug " 128=FILE_ATTRIBUTE_NORMAL [& FILE_ATTRIBUTE_READONLY]"
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Datei ist Schreibgeschütz" + Chr(32) + DirectoryPath + FileSystemType,2,2,"",0,0,DC::#_Window_001)
  						Case 8224:	;Debug "		 FILE_ATTRIBUTE_NORMAL [& FILE_ATTRIBUTE_NOT_CONTENT_INDEXED]  		  						
  						Case 2048:	;Debug "2048=FILE_ATTRIBUTE_COMPRESSED"
  						Case 2049:	;Debug "2048=FILE_ATTRIBUTE_COMPRESSED [& FILE_ATTRIBUTE_READONLY]" 											
  					EndSelect
  					
  					
  					AddElement(FileSystemList())
  					FileSystemList()\FCount = 1
  					FileSystemList()\FullPath = DirectoryPath + FileSystemType
  					;Debug 	"Datei: " FileSystemList()\FullPath + " (Anzahl der Dateien: " + Str(FileCnt)
  					
  				Case 16, 17, 8208
  					Select FileHandle\dwFileAttributes:
  						Case 16:		;	Debug #FILE_ATTRIBUTE_DIRECTORY"
  						Case 17:		; Debug #FILE_ATTRIBUTE_DIRECTORY [& Debug #FILE_ATTRIBUTE_READONLY]
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Verzeichnis ist Schreibgeschütz" + Chr(32) + DirectoryPath + FileSystemType,2,2,"",0,0,DC::#_Window_001)
  						Case 8208: ;	Debug #FILE_ATTRIBUTE_DIRECTORY [& Debug #FILE_ATTRIBUTE_NOT_CONTENT_INDEXED] 					
  					EndSelect			
  					AddElement(FileSystemList())
  					FileSystemType = Slash_Add(FileSystemType)
  					
  					FileSystemList()\DCount = 1
  					FileSystemList()\Directoy = DirectoryPath + FileSystemType 
  					
  					FindClose_(FileHandle)
  					;Debug DirectoryPath + FileSystemType  + " (Anzahl der Verzeichnisse: " + Str(FoldCnt)
  					
  					FileSystem_Search(DirectoryPath + FileSystemType)  				
  					
  				Case 64:			Debug "FILE_ATTRIBUTE_DEVICE"
  				Case 256:			Debug "FILE_ATTRIBUTE_TEMPORARY"
  				Case 512:			Debug "FILE_ATTRIBUTE_SPARSE_FILE"
  				Case 1024:		Debug "FILE_ATTRIBUTE_REPARSE_POINT"	  					  		
  				Case 4096:		Debug "FILE_ATTRIBUTE_OFFLINE"
  				Case 8192:		Debug "FILE_ATTRIBUTE_NOT_CONTENT_INDEXED"	
  				Case 16384:		Debug "FILE_ATTRIBUTE_ENCRYPTED"
  				Case 32768:		Debug "FILE_ATTRIBUTE_INTEGRITY_STREAM"
  				Case 65536:		Debug "FILE_ATTRIBUTE_VIRTUAL"
  				Case 131072:	Debug "FILE_ATTRIBUTE_NO_SCRUB_DATA"
  				Case 262144:	Debug "FILE_ATTRIBUTE_EA"			  		
  				Default		:	Debug "Unknown Attribute :" +Str( FileHandle\dwFileAttributes) + " - '" + FileSystemType + "'"
  			EndSelect
  		Wend
  	Else
  		Debug #INVALID_HANDLE_VALUE
  	EndIf
  	
  	FindClose_(FileHandle)
  	FindClose_(Result)
  	Debug 	"Save Support: FileSearch (END)" 
  EndProcedure
  	;
		;
  Procedure.i FileSystem_GetMaxDirs()
  	Protected Count.i
  	
		ResetList( FileSystemList() )
		
		While NextElement( FileSystemList() )			
			If Len( FileSystemList()\Directoy ) > 0
				Count + FileSystemList()\DCount		
			EndIf
		Wend
		
		ProcedureReturn Count
  EndProcedure	
  	;
		;
  Procedure.i FileSystem_GetMaxFiles()
  	Protected Count.i
  	
		ResetList( FileSystemList() )
		
		While NextElement( FileSystemList() )			
			If Len( FileSystemList()\FullPath ) > 0
				Count + FileSystemList()\FCount		
			EndIf
		Wend
		
		ProcedureReturn Count
  EndProcedure	  
  	;
		;
	Procedure.i FileSystem_CompressAddTo(PackDirectory.s, hPackFile.l, bMemory = #False, *Memory = 0, FileLength.q = 0)
		
		Protected PackFilePath.s, PackError.i
		
		PackDirectory = Slash_Add(PackDirectory)
		PackFilePath = ReplaceString( FileSystemList()\FullPath, PackDirectory , "", 0)
		
		Select bMemory
			Case #False:				
				PackError 	 = AddPackFile(hPackFile, FileSystemList()\FullPath, PackFilePath)
			Case #True:	
				PackError 	 = AddPackMemory(hPackFile, *Memory, FileLength, PackFilePath)
		EndSelect
		
		ProcedureReturn PackError
		
	EndProcedure
  	;
		;	
  Procedure.i FileSystem_CompressFiles(*PARAMS.COMPRESSPARAMS)
  	
  	Protected hPackFile.l, hFile.l, hFLen.q,  PackError.i, PackDirectory.s, Count.i, Current.i
  	
		ResetList( FileSystemList() )
		
		*PARAMS\Directory = RemoveSlash(*PARAMS\Directory)
		
		
  	;
		; Erstellung des Archiv mit Datum und Zeit angabe
		; 
		Date.s = FormatDate("%yyyy-%mm-%dd", Date())
		Time.s = FormatDate("%hh-%ii-%ss", Date())
		
		
		*PARAMS\PackFile = *PARAMS\Directory + "-["+Date +" # "+ Time + "]" +".7z"
		
		hPackFile = CreatePack(#PB_Any, *PARAMS\PackFile , #PB_PackerPlugin_Lzma, 9)  	
		If PackError = 0
				Debug "ERROR: FileSystem_CompressFiles: Pack Datei kann nicht erstellt werden"
		EndIf				
			
  	HideGadget(DC::#Text_004,0)
  	SetGadgetText(DC::#Text_004,"")    
  	
  	
  	
		While NextElement( FileSystemList() )
			
			If Len( FileSystemList()\FullPath ) > 0
				
					Current + 1
					SetGadgetText(DC::#Text_004,"Please Wait Compress File ("+Current+"/"+*PARAMS\Count+"): " + GetFilePart(FileSystemList()\FullPath ))
				
					hFile.l 			= ReadFile(#PB_Any, FileSystemList()\FullPath)
					hFLen.q 			= Lof(hFile)
					
					If ( hFLen = 0 )
						PackError = FileSystem_CompressAddTo(*PARAMS\Directory, hPackFile)
						If PackError = 0
							Debug "ERROR: FileSystem_CompressFiles: 0 Byte Dateien"
						EndIf							
						CloseFile(hFile)							
					Else		
							
							*hFileBuffer 	= AllocateMemory(hFLen)
							If ( *hFileBuffer )
						
							Time1	=	ElapsedMilliseconds()	
						
							ReadData(hFile, *hFileBuffer, hFLen)
							CloseFile(hFile)				
																			
							PackError = FileSystem_CompressAddTo(*PARAMS\Directory, hPackFile, #True *hFileBuffer, hFLen)
							If PackError = 0
								Debug "ERROR: FileSystem_CompressFiles: Puffer Fehler"
							EndIf	
						
							Time2	=	ElapsedMilliseconds()
							
							Debug "Compress Zeit: "+ Str(Time2-Time1)
							
							FreeMemory( *hFileBuffer )
						EndIf	
								
						Debug FileSystemList()\FullPath
					EndIf
					SetGadgetText(DC::#Text_004,"")
				EndIf	
			Wend
  	
  	;
		; Info hinzufügen wpo die Verzeichnisse waren.
  	InegrateTextFile.s = "Directory-Path-Save-Info.txt"
  	
  	InegrateInfoFile.s = Startup::*LHGameDB\TitleVersion +
  	                     ": Save Support"  + 
  	                     Chr(10) + 
  	                     Chr(13) +
  	                     "Directoy(s):" +
  	                     Chr(10) +
  	                     Chr(13)
  	
			ForEach SaveDirectorys() 
				InegrateInfoFile.s + ReplaceString( SaveDirectorys()\Directory$, UserName() , "%username%" ) + Chr(13)
			Next
			
			InegrateInfoFile + Chr(10) +
			                   Chr(13) +
			                   "* You can Copy and Paste the line with the variable in the Explorer Path Stringfield."  +
			                   Chr(10) +
			                   Chr(13)
			
			*IntegrateMemory = AllocateMemory( Len(InegrateInfoFile) )
			
			Protected Result.i = PokeS(*IntegrateMemory, InegrateInfoFile, MemorySize(*IntegrateMemory ) ,#PB_Ascii )
			If ( *IntegrateMemory )
				PackError = AddPackMemory(hPackFile, *IntegrateMemory, MemorySize(*IntegrateMemory ) , InegrateTextFile)
				If PackError = 0
					Debug "ERROR: FileSystem_CompressFiles: Puffer Fehler"
					CallDebugger
				EndIf					
			EndIf	
			
			FreeMemory( *IntegrateMemory )
			
			ClosePack(hPackFile)
			
  		HideGadget(DC::#Text_004,1)
  		SetGadgetText(DC::#Text_004,"")  			
  		
  		ProcedureReturn 0
  EndProcedure
  	;
  	;
  Procedure.i SaveContent_Compress()
  	
  	Protected Directory.s = ""
  	Protected Count.i
  	
  	SaveContent_Read()
  	
		ForEach SaveDirectorys() 	  			
			Directory =	Slash_Add( Startup::*LHGameDB\SaveTool\SavePath + SaveDirectorys()\GameTitle$ )
			Break
		Next
		
		If Not ( FileSize( Directory ) = -2 )
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Compress","Das Save Game Verzeichnis nicht gefunden"	+ #CR$ +			                                                                              
			                                                                          		Chr(34) + Directory + Chr(34) + #CR$ + #CR$ +
									                                                                  "Pack vorgang abgebrochen. Hint: Titel Geändert?",2,1,"",0,0,DC::#_Window_001)
			ProcedureReturn  -1
		EndIf
		
		
		;
		; Listet alle Dateien und Ordner im 'Save'-Verzeichnis auf
		FileSystem_Search(Directory) 
		
		If ( FileSystem_GetMaxFiles() = 0 ) And ( FileSystem_GetMaxDirs() = 0)
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Compress","Weder Verzeichnisse noch Dateien wurden im Save Game Ordner gefunden"	+ #CR$ + "Pack vorgang abgebrochen.",2,1,"",0,0,DC::#_Window_001)
			ProcedureReturn  -1
		EndIf		
		;
		; Compress Files
		;FileSystem_CompressFiles(Directory)
		

    *Params.COMPRESSPARAMS = AllocateMemory(SizeOf(COMPRESSPARAMS))
    InitializeStructure(*Params, COMPRESSPARAMS) 
    
    *Params\Directory = Directory
    *Params\Count			= FileSystem_GetMaxFiles()

    ThreadCompress = 0 
    ThreadCompress = CreateThread(@FileSystem_CompressFiles(),*Params.COMPRESSPARAMS)  		
    While IsThread(ThreadCompress) 
    	Delay(25)
    	 ProgramEventID = WindowEvent()
    Wend
			
		Debug "Dateien: " + Str(FileSystem_GetMaxFiles())
		
		If ListSize( FileSystemList() ) > -1 And  Not IsThread(ThreadCompress)			
			ClearList( FileSystemList() )			
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support Compress","Save Game Backup wurde Komprimiert " +#CR$+ "("+ GetFilePart(*Params\PackFile) + ").",2,0,"",0,0,DC::#_Window_001)  
		EndIf	
  EndProcedure  
  	;
		;
		; Options = 0 = Normaler Kopiermodus
		; Options = 1 = Normaler Kopiermodus und keine Aufforderung
  Procedure.i SaveContent_Restore(Options.i = 0, Request.i = 0)
  	
 		Protected lFileOp.f
 		Protected lresult.l
 		Protected lFlags.w 
 		Protected Notify.s
 		
  	SHFileOp.SHFILEOPSTRUCT    ;Windows API Structure
  	
  	;  #FO_MOVE, #FO_RENAME
  	Select Options
  		Case 0: lFileOp = #FO_COPY 
  		Case 1: lFileOp = #FO_COPY: lFlags = #FOF_NOCONFIRMATION
  	EndSelect		
  	
  	If (GetMaxItems() = -1)
  		If ( Request.i = 1 )
  				 Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Restore: Es befinden sich keine Verzeichnisse in der Konfigurations datei.",2,3,"",0,0,DC::#_Window_001)  				 
  		EndIf		 
			ProcedureReturn   				
  	EndIf	

  	If (GetMaxItems() > -1)
  		
  		If (Options = 1) And (Request = 0)
  	 		Notify = "[ .. Save Restore .. ]: Verzeichnis wird wiederhergestellt"
  			HideGadget(DC::#Text_004,0)
      	SetGadgetText(DC::#Text_004,Notify)    		    		
    	EndIf
    
  		ForEach SaveDirectorys() 			  			
						;
						; Der Letzte Backslash muss für die SHFileOp etnfernt werden	  			
						Protected Source.s =	Startup::*LHGameDB\SaveTool\SavePath + SaveDirectorys()\GameTitle$
						Protected DestTo.s = 	RemoveSlash(SaveDirectorys()\Directory$)
												
						DestDirName.s = ""
						DestSavePath.s= ""
						
						Reverse.s 		= ReverseString(DestTo)
						nPos      		= FindString( Reverse, "\" , 0)
						nLen      		= Len( Reverse )
						
						DestDirName 	= Mid( Reverse, 0, nPos-1)
						DestDirName   = ReverseString(DestDirName)
						Source				= Source + "\" + DestDirName
						
						DestSavePath 	= Mid( Reverse, nPos+1, nLen - nPos)						
						DestSavePath  = ReverseString(DestSavePath)
						
						Select FileSize( Source )
							Case -1	
								;
								; Keine Aufforderung wenn das Spiel startet und der ordner nicht gefunden werden kann
								If (Options = 0) And (Request = 1)
									Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Restore","Keine Save Daten zum Wiederherstellen (Verzeichnis nicht gefunden)"+ #CR$ + 
									                                                                              Source + #CR$ + #CR$ +
									                                                                              "Hint: Titel Geändert?",2,1,"",0,0,DC::#_Window_001)
								EndIf	
								Continue
						EndSelect		
						
	  				MemorySource = AllocateMemory(( Len(Source)+2 ) * SizeOf(Character) )
	  				If MemorySource
	  					PokeS(MemorySource,Source)
	  				EndIf
	  				MemoryDestTo = AllocateMemory(( Len(DestTo)+2 ) * SizeOf(Character) )
	  				If MemoryDestTo
	  					PokeS(MemoryDestTo,DestSavePath)
	  				EndIf	
	  				
  			 		SHFileOp\wFunc  = lFileOp
						SHFileOp\pFrom 	= MemorySource
						SHFileOp\pTo 		= MemoryDestTo 
						SHFileOp\fFlags = lFlags
						
						lresult = SHFileOperation_(SHFileOp)
						
						FreeMemory(MemorySource)
						FreeMemory(MemoryDestTo)							
						If lresult <> 0 | SHFileOp\fAnyOperationsAborted
							If (lresult <> 0)
								Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Restore","Fehler Code: " + Str(lresult)+ " " +ErrorCodes(lresult)+ #CR$+ #CR$+ DestTo,2,2,"",0,0,DC::#_Window_001)
							EndIf						
						Else					
							If ( Request.i = 1 )
								Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Restore",Chr(34) + ".\" + DestDirName + "\" + Chr(34) + #CR$ + #CR$ + "Save Game Backup wurde wiederhergestellt"+ #CR$ + Chr(34) + DestSavePath + Chr(34), 2,0,"",0,0,DC::#_Window_001)
							Else
  	 						Notify = "[ .. Save Restore .. ]: Verzeichnis wurde wiederhergestellt - ("+DestSavePath+"\"+DestDirName+")"
      					SetGadgetText(DC::#Text_004,Notify) 																
							EndIf
							
							Debug "vSystem Save Support: Restore - Verzeichnis '"+DestDirName+"' wiederhergestellt in " +#CR$+ DestSavePath
						EndIf
					Next
					
					CleanListing()					
  				If (Options = 1) And (Request = 0)
  						HideGadget(DC::#Text_004,1)
      				SetGadgetText(DC::#Text_004,"")    
      	  EndIf
      			
  		ProcedureReturn 0
  	EndIf		  		  		  	
  EndProcedure  
  	;
		;
		; Options = 0 = Normaler Kopiermodus
		; Options = 1 = Normaler Kopiermodus und keine Aufforderung
  	; Options = 2 = Verschiebe Modus und keine Aufforderung  (Dateien befinde sich dann im Mülleimer)
  Procedure.i SaveContent_Backup(Options.i = 0, Request.i = 0)
  	
  	Debug "vSystem Save Support: Backup (BEG)"
 		Protected lFileOp.f
 		Protected lresult.l
 		Protected lFlags.w
 		Protected Notify.s, CopyFlag.s
 		
 		If ( Request = 1 ) And (Options = 2)
 			   Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support", "Backup: Die Sicherungsdateien des Spiels nach vSystems Verschieben?."+#CR$+" (Löschung verschiebt den Quell Inhalt in den Müllemier) ",11,1,ProgramFilename(),0,0,DC::#_Window_001 )         
         If Result > 0
             ProcedureReturn #False
           EndIf          
    EndIf
  	SHFileOp.SHFILEOPSTRUCT    ;Windows API Structure
  	
  	lFileOp = #FO_COPY ;  #FO_MOVE, #FO_RENAME
  	
  	Select Options
  		Case 0:
  			lFileOp = #FO_COPY
  			CopyFlag= "Copy Modus"
  			Debug "vSystem Save Support: Backup - Wird gesichert: Normales Kopieren"
  		Case 1
  			lFileOp = #FO_COPY
  			lFlags  = #FOF_NOCONFIRMATION
  			CopyFlag= "Copy Modus"  			
  			Debug "vSystem Save Support: Backup - Wird gesichert: Normales Kopieren/ Keine bestätigung"
  		Case 2
  			lFileOp = #FO_MOVE
  			lFlags  = #FOF_NOCONFIRMATION|#FOF_ALLOWUNDO  			
  			CopyFlag= "Move Modus"  			
  			Debug "vSystem Save Support: Backup - Wird gesichert: Verschieben/ Keine bestätigung"
  	EndSelect	
  	
  	If (GetMaxItems() = -1)
  		If ( Request.i = 1 )
  				 Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Backup: Es befinden sich keine Verzeichnisse in der Konfigurations datei.",2,3,"",0,0,DC::#_Window_001)  				 
  		EndIf
			ProcedureReturn  				
  	EndIf	
  		
  	If (GetMaxItems() > -1)
  		
  		If (Options = 2) And (Request = 0)
  	 		Notify = "[ .. Save Backup .. ]: " + CopyFlag + ": Verzeichnis wird sichergestellt"
  			HideGadget(DC::#Text_004,0)
      	SetGadgetText(DC::#Text_004,Notify)    		    		
    	EndIf
    
  		ForEach SaveDirectorys()
	  			
						Source.s = SaveDirectorys()\Directory$
						DestTo.s = Startup::*LHGameDB\SaveTool\SavePath + SaveDirectorys()\GameTitle$
						
						If ( Request = 1 ) And (Options = 2)
           		Select FileSize( RemoveSlash(Source) )
           			Case -1		
           				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Spiel Sicherungs Daten Verzeichnis nicht gefunden"+#CR$+ Source,2,2,"",0,0,DC::#_Window_001)
           				Continue
           		EndSelect	
           	EndIf
						
	  				MemorySource = AllocateMemory(( Len(Source)+2 ) * SizeOf(Character) )
	  				If MemorySource
	  					PokeS(MemorySource,Source)
	  				EndIf
	  				MemoryDestTo = AllocateMemory(( Len(DestTo)+2 ) * SizeOf(Character) )
	  				If MemoryDestTo
	  					PokeS(MemoryDestTo,DestTo)
	  				EndIf	  													
						
						Select FileSize( DestTo )
							Case -1		
								CreateDirectory(DestTo)
						EndSelect		
						
  			 		SHFileOp\wFunc  = lFileOp
						SHFileOp\pFrom 	= MemorySource
						SHFileOp\pTo 		= MemoryDestTo 
						SHFileOp\fFlags = lFlags
						
						lresult = SHFileOperation_(SHFileOp)
						
						FreeMemory(MemorySource)
						FreeMemory(MemoryDestTo)							
						If lresult <> 0 | SHFileOp\fAnyOperationsAborted
							If (lresult <> 0)
									Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Fehler Code: " + Str(lresult) + " " +ErrorCodes(lresult)+ #CR$+ #CR$+ SaveDirectorys()\Directory$,2,2,"",0,0,DC::#_Window_001)		
								EndIf
						Else					
							If ( Request.i = 1 )
								Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Verzeichnis wurde sichergestellt" + #CR$ + Chr(34) + Source + "\" + Chr(34),2,1,"",0,0,DC::#_Window_001)
							EndIf
							
							If (Options = 2)
								Select FileSize( Source )
									Case -2		
										FFH::_Recycle(Source + "\")
								EndSelect										
							EndIf
							
	  					If (Options = 2) And (Request = 0)
	  	 					Notify = "[ .. Save Backup .. ]: " + CopyFlag + ": Verzeichnis wurde sichergestellt"
	  	 					SetGadgetText(DC::#Text_004,Notify)	  	 						
	      			EndIf							
	      				
							Debug "vSystem Save Support: Backup - Verzeichnis wurde sichergestellt"
						EndIf
			Next
			
  		If (Options = 2) And (Request = 0)
  			HideGadget(DC::#Text_004,1)
      	SetGadgetText(DC::#Text_004,"")    
      EndIf
      
      ;
      ; Check Attributes
      ;FileSystem_Search(Slash_Add(DestTo), #True)
			;If ListSize( FileSystemList() ) > -1			
			;	ClearList( FileSystemList() )	
			;EndIf
      
      CleanListing()
  		Debug "vSystem Save Support: Backup (END)"      
  		ProcedureReturn 0
  	EndIf		  		  		  	
  EndProcedure
    ;
    ;  
  Procedure.i SaveContent_Read_Options(sOptions.s, StartPos.i, ItemData.s ,isBool.b = #False, isNumber.b = #False)
  	
  	Protected  nPos.i, sValue.s, iValue.i
  		
  		nPos = FindString( ItemData, "=", StartPos)
  		If nPos > StartPos
  			nPos 					= Len (ItemData) - nPos
  			
  			If nPos = 0
  				ProcedureReturn -1
  			EndIf      				
  			
  			If ( isBool )
  				sValue.s = Right(ItemData,nPos)
  				
  				If LCase( sValue ) = LCase("true")
  					ProcedureReturn #True
  				Else
	  				ProcedureReturn #False     					
	  			EndIf		  		
	  		
	  		ElseIf ( isNumber )
	  			ProcedureReturn Val( Right(ItemData,nPos) )	  			
	  		EndIf
	  		
	  	EndIf				
	  	ProcedureReturn -1
  EndProcedure
  	;
    ;  
  Procedure.i  SaveContent_Read()
  	
  	SaveFile_Read()
  	
  	Protected nPos.i, BrakeCount.i
  	Protected ItemData.s = "", ItemDirectory.s = "", TitleFound.i
  	;
		; Optionen die abgefragt und in die Liste geischert werden
  	Protected Value_RestoreData.s 			= "RestoreData"
  	Protected Value_BackupData.s  			= "Backup-Data" 			 			
  	Protected Value_RestoreDelay.s 		= "RestoreDelay"
  	Protected Value_BackupDelay.s 			= "Backup-Delay"  
  	Protected Value_BackupCompress.s 	= "BackupCompress"
  	;
		;
  	TitleFound = #False
  	
  	If ( Startup::*LHGameDB\SaveTool\SaveHandle )
  		
  		AddElement(SaveOptions())
  		
  		While Eof( Startup::*LHGameDB\SaveTool\SaveHandle ) = 0
  			
  			ItemData = ReadString(Startup::*LHGameDB\SaveTool\SaveHandle)
  			
  			If Left(ItemData, 1) = "[" And Right(ItemData, 1)= "]" And TitleFound = #False
  				
  				If (BrakeCount = 1)
  					;
						; Spiel Gefunden, nicht mehr zu tun
  					Break
  				EndIf      			
  				
  				;
					; Vergleiche den Title aus der Config mit dem aus der Datenbank
					; 
  				ItemData = Mid(ItemData, 2, Len(ItemData)-2 )
  				If LCase(SaveConfig_GetGameTitle()) = LCase(ItemData)    				
  					BrakeCount + 1
  					TitleFound = #True
  					Continue
  				EndIf	 
  				
  			ElseIf ( Left(ItemData,6) = "Folder" ) And TitleFound = #True
  				
  				;
					; Hole die Verzeichnisse
  				nPos = FindString( ItemData, "=", 6)
  				If nPos > 6
  					nPos 					= Len (ItemData) - nPos
  					If nPos = 0
  						Continue
  					EndIf
  					;
						; Todo CLSID
  					ItemDirectory = Right(ItemData,nPos)
  					
  					;If Not Right(ItemDirectory, 1) = "\"
						;	ItemDirectory + "\"
						;EndIf	
  					
  					AddElement(SaveDirectorys())
  					SaveDirectorys()\GameTitle$ =  SaveConfig_GetGameTitle()  					  					
  					SaveDirectorys()\Directory$ =  SHGetFolderPath(ItemDirectory) 
  				EndIf 
  				
  			ElseIf ( Left(ItemData,11) = Value_RestoreData ) And TitleFound = #True
  				Value.s = Value_RestoreData  				
  				SaveOptions()\RestoreData = SaveContent_Read_Options(Value, 11, ItemData, #True, #False)
  				If SaveOptions()\RestoreData = -1  					
  				EndIf      		
  				
  			ElseIf ( Left(ItemData,11) = Value_BackupData ) And TitleFound = #True
  				Value.s = Value_BackupData  				
  				SaveOptions()\BackupData = SaveContent_Read_Options(Value, 11, ItemData, #True, #False)
  				If SaveOptions()\BackupData = -1
  				EndIf	   					
  				
  			ElseIf ( Left(ItemData,12) =	Value_RestoreDelay ) And TitleFound = #True 				
  				Value.s = Value_RestoreDelay
  				SaveOptions()\RestoreDelay = SaveContent_Read_Options(Value, 12, ItemData, #False, #True)					      				
  				
  			ElseIf ( Left(ItemData,12) = Value_BackupDelay ) And TitleFound = #True 				
  				Value.s = Value_BackupDelay    			
  				SaveOptions()\BackupDelay = SaveContent_Read_Options(Value, 12, ItemData, #False, #True)						      			
  				
  			ElseIf ( Left(ItemData,14) = Value_BackupCompress ) And TitleFound = #True				
  				Value.s = Value_BackupCompress
  				SaveOptions()\BackupCompress = SaveContent_Read_Options(Value, 14, ItemData, #True, #False)
  				If SaveOptions()\BackupData = -1
  				EndIf
  				;
					; Letzte Keyvalue für den Spiele Titel, aussteighen
  				Break
  			EndIf      			      	            	
  		Wend      	    	
  	EndIf 	
  	SaveFile_Close()      
			
	EndProcedure
    ;
		;
	Procedure.i	SaveContent_Delete_Modus(FileType.s)
			
		Protected lFileOp.f, MemorySource.i, lFlags.w, lresult.i
		
		SHFileOp.SHFILEOPSTRUCT
		
		MemorySource = AllocateMemory(( Len(FileType)+2 ) * SizeOf(Character) )
		If MemorySource
			PokeS(MemorySource,FileType)
		EndIf
		
		
		lFileOp = #FO_DELETE
		lFlags 	= #FOF_ALLOWUNDO|#FOF_SILENT|#FOF_NOCONFIRMATION
		;
		; Delete Ohne Mülleimer
		;lFlags 	=  #FOF_SILENT|#FOF_NOCONFIRMATION
		
			SHFileOp\pFrom  = MemorySource
			SHFileOp\wFunc  = lFileOp
			SHFileOp\fFlags = lFlags
			lresult = SHFileOperation_(SHFileOp)
			
			FreeMemory(MemorySource)
			ProcedureReturn lresult
			
	EndProcedure		
		;
		;	
	Procedure.i SaveContent_Delete()
		Protected HasConfig.b = #False, HasGameSaveDir.b = #False, Result.i
		
		Select FileSize( Startup::*LHGameDB\SaveTool\SaveFile )
			Case -1								
			Default
				HasConfig  = #True 
		EndSelect		
		Select FileSize( Startup::*LHGameDB\SaveTool\SavePath + SaveConfig_GetGameTitle() )
			Case -2		
				HasGameSaveDir = #True				
			Default

		EndSelect
		
		If 	( HasConfig  = #False And HasGameSaveDir = #False )
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Keine Konfiguration sowie Spielstand Verzeichnis zu  zu "+SaveConfig_GetGameTitle()+" Gefunden",2,0,"",0,0,DC::#_Window_001)
			ProcedureReturn 
			
		ElseIf ( HasConfig  = #True And HasGameSaveDir = #False )
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Konfiguration entdeckt",2,0,"",0,0,DC::#_Window_001)		
				
		ElseIf ( HasConfig  = #False And HasGameSaveDir = #True )			
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Spielstand Verzeichnis zu "+SaveConfig_GetGameTitle()+" Gefunden",2,0,"",0,0,DC::#_Window_001)					
		EndIf
		
		If ( HasConfig  = #True )
			Result = SaveContent_Delete_Modus(Startup::*LHGameDB\SaveTool\SaveFile)
			
			Select FileSize( Startup::*LHGameDB\SaveTool\SaveFile )
				Case -1:
					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Konfiguration Gelöscht (Liegt im Mülleimer)",2,0,"",0,0,DC::#_Window_001)		
				Default
					Debug "Save Game Support: Result - Fehler beim löschen: " + ErrorCodes(Result) + "("+ Str(Result) + ")"
			EndSelect
		EndIf
		
		If (HasGameSaveDir = #True)	
			Result = SaveContent_Delete_Modus( Startup::*LHGameDB\SaveTool\SavePath + SaveConfig_GetGameTitle() )
			Select FileSize( Startup::*LHGameDB\SaveTool\SaveFile )
				Case -1:
					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Backup Gelöscht  (Liegt im Mülleimer)",2,0,"",0,0,DC::#_Window_001)		
				Default
					Debug "Save Game Support: Result - Fehler beim löschen: " + ErrorCodes(Result) + "("+ Str(Result) + ")"
			EndSelect
		EndIf		
		
	EndProcedure
		;
    ;
	Procedure.b Exists_GameTitle()
		
			SaveFile_Open()
 			If ( Startup::*LHGameDB\SaveTool\SaveHandle )
    		While Eof( Startup::*LHGameDB\SaveTool\SaveHandle ) = 0
    			
      		ItemData.s = ReadString(Startup::*LHGameDB\SaveTool\SaveHandle)
      		      		
      		If Left(ItemData, 1) = "[" And Right(ItemData, 1)= "]"      		   		    				
    				;
						; Vergleiche den Title aus der Config mit dem aus der Datenbank
    				; 
    				ItemData = Mid(ItemData, 2, Len(ItemData)-2 )
    				If LCase(SaveConfig_GetGameTitle()) = LCase(ItemData) 
    					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Der Titel: '"+ItemData+"' existiert in der Konfiguration",2,1,"",0,0,DC::#_Window_001)
    					SaveFile_Close()
							ProcedureReturn #True
    				EndIf			
    			EndIf
    			
    		Wend	    		
    	EndIf    
    	SaveFile_Close()
    	ProcedureReturn #False
   EndProcedure	    
   ;
	 ;	
	Procedure.b SaveConfig_CreateDirectory()
		
		Select FileSize( Startup::*LHGameDB\SaveTool\SavePath )			
				; Kein Verzeichnis
				; MessageRequester
			Case -1
				CreateDirectory( Startup::*LHGameDB\SaveTool\SavePath )
				ProcedureReturn #True
				
    EndSelect 			
    
    ProcedureReturn #False
	EndProcedure	
		;
		;
	Procedure.i SaveConfig_Generate_Options()
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Folder001=")			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Folder002=")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Folder003=")	
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Folder004=")	
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Folder005=")		
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "RestoreData=true")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Backup-Data=true")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "RestoreDelay=250")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "Backup-Delay=250")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "BackupCompress=false")		
	EndProcedure
	Procedure.i SaveConfig_Generate()
		
		SaveConfig_CreateDirectory() 
		
		SaveFile_Create()
		If ( Startup::*LHGameDB\SaveTool\SaveHandle )
		; Da muss ich mir ein Text ausdenken
			WriteString (Startup::*LHGameDB\SaveTool\SaveHandle, "" + #CR$)
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# vSystems Save Support: Backup and Restore Save Profiles from HomeDrive/UserPath")			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# Hints: GameTitle     : Database 1st Title & 2nd Title. Folder[count] = Directory")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# Hints: Folder[count] : Folder[count] = Point to Directory(s) Backup/Restore")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "#")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# Most Importants Key Variables on Windows: ")			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# %DESKTOP%      : C:\Users\%username%\Desktop\")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# %DOCUMENTS%    : C:\Users\%username%\Documents\")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# %APPDATA%      : C:\Users\%username%\AppData\Roaming\")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# %LOCALAPPDATA% : C:\Users\%username%\AppData\Local\")				
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# %USERPROFILE%  : C:\Users\%username%\")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# %SAVEDGAMES%   : C:\Users\%username%\Documents\Saved Games")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "#")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# Examples: You can use variables.")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# 001=C:\Users\%username%\AppData\Roaming\SuperBoombasticPlasticGame\")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# 001=%APPDATA%\SuperBoombasticPlasticGame")			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# 002=%DOCUMENTS%\My Games\SuperBoombasticPlasticGame\")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# 004=%USERPROFILE%\SuperBoombasticPlasticGame")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "#")			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# GameSaves will be saved in the SAVE Directory named [GAMETITLE]")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# GAMETITLE is the exzact the same Game and Sub Title in vSystem]")		
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# Example Saved: .\SAVE\GAMETITLE\SuperBoombasticPlasticGame")
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "# Backslashs are Optional")					
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "")			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "[GameTitle]")
			
			SaveConfig_Generate_Options()

		EndIf
		SaveFile_Close()
	EndProcedure
    ;
    ;
	Procedure.i SaveConfig_Create(Request.i = 0)
		
		Select FileSize( Startup::*LHGameDB\SaveTool\SaveFile )
			Case -1					
				SaveConfig_Generate()
				If (Request = 1)
					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Eine Blanko Konfigurations Datei  wurde Hinzugefügt",2,0,"",0,0,DC::#_Window_001)	
				EndIf				
				ProcedureReturn 
			Default
					
		EndSelect			
		
		If (Request = 1)
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Konfigurations Datei Exisitiert bereits",2,0,"",0,0,DC::#_Window_001)	
		EndIf	

	EndProcedure
    ;
    ;
	Procedure.i SaveConfig_AddGame()
		
		SaveConfig_Create()
		
		If Exists_GameTitle() = #True			
			ProcedureReturn 
		EndIf
		
		SaveFile_Open(1)
		
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "")	
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, "["+SaveConfig_GetGameTitle()+"]")

			SaveConfig_Generate_Options()
			
    	Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Der Titel: '"+SaveConfig_GetGameTitle()+"' wurde in die Config Hinzugefügt",2,0,"",0,0,DC::#_Window_001)			
		SaveFile_Close()	
	EndProcedure
		;
		;
	Procedure.i SaveConfig_SetKeyValue(KeyValue.s = "Folder", FolderValue.i = 1, KeyBool.i = #False, KeyDelay.i = 250, NewGameTitle.s = "", OldGameTitle.s = "")	
		
  	Protected nPos.i, BrakeCount.i, TitleFound.i = #False, ChangeGameTitle.i = #False
  	Protected ItemData.s = "", Path.s = "", DelayVal.s
  	
		Select FileSize( Startup::*LHGameDB\SaveTool\SaveFile )
			Case -1		
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Konfigurations Datei Exisitert nicht",2,2,"",0,0,DC::#_Window_001)
				ProcedureReturn -1
		EndSelect	
		
		If ( GetFileAttributes_(Startup::*LHGameDB\SaveTool\SaveFile) = #FILE_ATTRIBUTE_READONLY )
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Konfigurations Datei ist schreibgeschützt.",2,2,"",0,0,DC::#_Window_001)
		EndIf
		
		If	( KeyValue.s = "Folder" )
				PathInit.s 	= SHGetFolderPath("%DOCUMENTS%\")
				Path 				= PathRequester("vSystem Save Support: Wähle SaveGame Ordner", PathInit)
				If ( Path = "" )
					ProcedureReturn -1
				EndIf	
 		EndIf
 		
		Structure STRUCT_SAVECHANGE
			SaveLine.s
 		EndStructure        
 		NewList SaveChange.STRUCT_SAVECHANGE()
		;
		; 1st Read File an save content in the List
  	SaveFile_Read()
  	 	
  	;
		;
  	If ( Startup::*LHGameDB\SaveTool\SaveHandle )  		  		  		 		
  		While Eof( Startup::*LHGameDB\SaveTool\SaveHandle ) = 0  			  
  			AddElement( SaveChange() )
  			SaveChange()\SaveLine = ReadString(Startup::*LHGameDB\SaveTool\SaveHandle)
  		Wend
  		
  		SaveFile_Close()    		
  	EndIf
  	
  	;
  	; 2nd. Search for the Game Title
  	ResetList( SaveChange() )
  	While NextElement(SaveChange())		
 		;
		; Vergleiche den Title aus der Config mit dem aus der Datenbank
		;   		
  		If ( Left(SaveChange()\SaveLine, 1) = "[" And Right(SaveChange()\SaveLine, 1)= "]" And TitleFound = #False )
  			
  			ItemData = Mid(SaveChange()\SaveLine, 2, Len( SaveChange()\SaveLine)-2 )

  			If LCase(SaveConfig_GetGameTitle()) = LCase(ItemData)
  				
  				If Len( NewGameTitle.s ) > 0 And Len( OldGameTitle.s ) > 0
  					;
						; Spiele Titel Umbennenung
  					SaveChange()\SaveLine = "[" + NewGameTitle + "]"
  					If FileSize( Startup::*LHGameDB\SaveTool\SavePath + OldGameTitle ) = -2
  						OldGameTitle = Startup::*LHGameDB\SaveTool\SavePath + OldGameTitle
  						NewGameTitle = Startup::*LHGameDB\SaveTool\SavePath + NewGameTitle
  						Result.i = RenameFile(OldGameTitle , NewGameTitle )
  						If Result = 0
  							Debug "vSystem Save Game Support: Fehler beim Umbennen "
  							Debug "vSystem Save Game Support: von: " + OldGameTitle
  							Debug "vSystem Save Game Support: -->: " + NewGameTitle
  						EndIf
  						;
  						; Nach der Umbenneung Steige aus
  						Break
  					EndIf	
  				EndIf  				
  				TitleFound = #True
  				Continue
  			EndIf
  			
  		ElseIf	( Left(SaveChange()\SaveLine,6) = KeyValue ) And TitleFound = #True
  				;
					; Hole die Verzeichnisse
  				nPos = FindString( SaveChange()\SaveLine, "=", 9)
  				If nPos > 5
  					If ( FolderValue = Val( Mid( SaveChange()\SaveLine, 7,3) )) 					
  					
  					Select FolderValue
  						Case 1:  SaveChange()\SaveLine = "Folder001=" + Path
  							Break
  						Case 2:  SaveChange()\SaveLine = "Folder002=" + Path
  							Break
  						Case 3:  SaveChange()\SaveLine = "Folder003=" + Path
  							Break
  						Case 4:  SaveChange()\SaveLine = "Folder004=" + Path
  							Break
  						Case 5:  SaveChange()\SaveLine = "Folder005=" + Path
  							Break
  					EndSelect
  				EndIf  				
  			EndIf
  			
  		ElseIf	TitleFound = #True And KeyBool = #True And KeyDelay = -1
  			
  			nPos = FindString( SaveChange()\SaveLine, "=", 11)
  			If nPos >= 12
  				BoolKey.s = Mid( SaveChange()\SaveLine, 1,nPos-1)
  				
  				If ( LCase( BoolKey ) = LCase( KeyValue ))
  					
  					BoolVal.s = Right( SaveChange()\SaveLine, Len( SaveChange()\SaveLine ) - nPos )
  					
  					If LCase( BoolVal ) = LCase( "true" )
  						BoolVal = "false"
  					Else
  						BoolVal = "true"
  					EndIf
  					
  					Select ( LCase( KeyValue ))
  						Case LCase( "RestoreData" )
  							SaveChange()\SaveLine = KeyValue + "=" + BoolVal	:Break
  							
  						Case LCase( "Backup-Data" )
  							SaveChange()\SaveLine = KeyValue + "=" + BoolVal	:Break
  							
  						Case LCase( "BackupCompress" )
  							SaveChange()\SaveLine = KeyValue + "=" + BoolVal	:Break
  					EndSelect		
  				EndIf
  			EndIf		  			
  			
  		ElseIf	TitleFound = #True And KeyBool = -1 And KeyDelay > 0
  			
  			If FindString( SaveChange()\SaveLine, "RestoreDelay", 0) And  ( LCase(KeyValue) = LCase("RestoreDelay") )
  				
  				nPos = FindString( SaveChange()\SaveLine, "=", 11)
  				If nPos >= 12
  					DelayVal = Right( SaveChange()\SaveLine, Len( SaveChange()\SaveLine ) - nPos )
  				EndIf
  				
  				Request::*MsgEx\Return_String = DelayVal
  				Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Restore","Wieviel Zeit soll vergehen zwischen der Widerherstellung und dem Starten des Spiels" + 
  				                                                                                       #CR$ + "In Millisekunden (1000 = 1 Sekunde, 600000 = 1 Minute)",12,0,"",0,1,DC::#_Window_001)					
  				If ( Result = 0 )  					  					  					
  					SaveChange()\SaveLine = "RestoreDelay=" + Request::*MsgEx\Return_String 
  				EndIf	
  				
  			Break 				
  			
  		ElseIf FindString( SaveChange()\SaveLine, "Backup-Delay", 0) And  ( LCase(KeyValue) = LCase("Backup-Delay") )
  			
  			nPos = FindString( SaveChange()\SaveLine, "=", 11)
  			If nPos >= 12
  				DelayVal = Right( SaveChange()\SaveLine, Len( SaveChange()\SaveLine ) - nPos )
  			EndIf
  			
  			Request::*MsgEx\Return_String = DelayVal
  			Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Wieviel Zeit soll vergehen zwischen dem Sichern und dem beenden des Spiels" +
  			                                                                                      #CR$ + "In Millisekunden (1000 = 1 Sekunde, 600000 = 1 Minute)",12,0,"",0,1,DC::#_Window_001)		
  			If ( Result = 0 )  			
  				SaveChange()\SaveLine = "Backup-Delay=" + Request::*MsgEx\Return_String
  			EndIf
  			
  			Break   				
  		EndIf    					  		
  	EndIf  	
  Wend
  

  	;
  	; 3rd Save List content to the File
  	ResetList( SaveChange() )
  	SaveFile_Create()
  	While NextElement(SaveChange())	  			
			WriteStringN(Startup::*LHGameDB\SaveTool\SaveHandle, SaveChange()\SaveLine)
  	Wend	
  	
  	SaveFile_Close()
  	ClearList( SaveChange() )
  	FreeList( SaveChange() )
  	
	EndProcedure
		;
		;
	Procedure.i SaveFile_ChangeTitle(NewGameTitle.s, OldGameTitle.s)
				Protected  CurrentCmd.s = GetGadgetText( DC::#String_007 )				
				If FindString(CurrentCmd, "%savetool", 1 , #PB_String_NoCase  )					
					SaveConfig_SetKeyValue("", -1, #False, 250, NewGameTitle.s, OldGameTitle.s)	
				EndIf
				ProcedureReturn -1
	EndProcedure  	
		;
    ;	
	Procedure.i FileCheck()
		
		Protected Result.i = 0
					
		If ( SaveConfig_CreateDirectory() )
			; True = Verzeichnis Erstellt
		EndIf
		
		SaveConfig_Create()
			
		SaveContent_Read()
		
		SaveContent_Backup()	
					
	EndProcedure	
    ;
    ;
	Procedure   SaveConfig_Edit(Option.i = 0)
		
		Select FileSize( Startup::*LHGameDB\SaveTool\SaveFile )
			Case -1		
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Konfigurations Datei Exisitert nicht",2,2,"",0,0,DC::#_Window_001)
				ProcedureReturn 
		EndSelect	
		
		Select Option
			Case 0
				FFH::ShellExec(Startup::*LHGameDB\SaveTool\SaveFile, "open") 
				ProcedureReturn 
			Case 1				 
        FFH::SHOpenWithDialog_(Startup::*LHGameDB\SaveTool\SaveFile, 4)		
		 EndSelect
	EndProcedure	
    ;
    ;
	Procedure   SaveConfig_AddCMD()
		
			Protected CommandlineString.s = "%savetool", sCmdString.s = GetGadgetText( DC::#String_103 )
			
      If FindString( sCmdString, CommandlineString, 1) = 0
      	sCmdString + CommandlineString
      	SetGadgetText( DC::#String_103, sCmdString )
      EndIf	      
           
	EndProcedure	
		;
		;
	Procedure   SaveConfig_OpenSaves()
		Select FileSize( Startup::*LHGameDB\SaveTool\SavePath )
			Case -1		
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Save Pfad Exisitert nicht",2,2,"",0,0,DC::#_Window_001)
				ProcedureReturn 
		EndSelect	
		
		FFH::ShellExec(Startup::*LHGameDB\SaveTool\SavePath, "explore") 
			
	EndProcedure
		;
		;	
	Procedure   SaveConfig_Help()
		
		Protected Helptext.s
		
		Helptext = 	"1. Die Konfgurations Datei (Save.ini) muss erstellt werden" 					+ #CR$ + #CR$ +
		           	"2. Aktuell den Titel hinzufügen. Dieser wird auch gleichzeitig" 			+ #CR$ +
		           	"   als Verzeichnis verwendet IN dem sich die Daten befindet." 				+ #CR$ + #CR$ +
		           	"3. Manuell muß das Verzeichnis in die Konfgurations Datei" 					+ #CR$ +
		           	"   hinzugefügt werden." 																							+ #CR$ + #CR$ +
		           	"4. Um Herauszufinden wo das SaveGame Verzeichnis vom Spiel"					+ #CR$ +
		           	"   befindet kann man das Monitoring einschalten oder %wmon in "			+ #CR$ +
		           	"   der Kommandozeile angeben und in der Log ansehen."								+ #CR$ + #CR$ +
		           	"Hints:"																															+ #CR$ +
		           	"Wenn der Spiele Titel geändert wird muss auch der Titel in der"			+ #CR$ +
		           	"Konfigurations Datei sowie das Verzeichnis geändert werden."					+ #CR$ + #CR$ +
		           	"Status Meldungen:"																										+ #CR$ +
		           	"Nicht Konfiguriert"																									+ #CR$ +
		           	"- Keine Verzeichnisse Gefunden"																			+ #CR$ +
		           	"  Lösung: Verzeichnis hinzufügen"																		+ #CR$ +
		           	"- Der Spieletitel wurde in der Konfiguration nicht gefunden"		      + #CR$ +
		           	"  Lösung; Prüfen ob der Titel mit dem in der Datenbank übereinstimmt" 
		                   																										  
		           
		
		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Help",Helptext,2,0,"",0,0,DC::#_Window_001)	
		
	EndProcedure	
	
 DataSection
         FOLDERID_NetworkFolder: ; {D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}
         Data.l $D20BEEC4
         Data.w $5CA8,$4905
         Data.b $AE,$3B,$BF,$25,$1E,$A0,$9B,$53
         
         FOLDERID_ComputerFolder: ; {0AC0837C-BBF8-452A-850D-79D08E667CA7}
         Data.l $0AC0837C
         Data.w $BBF8,$452A
         Data.b $85,$0D,$79,$D0,$8E,$66,$7C,$A7
         
         FOLDERID_InternetFolder: ; {4D9F7874-4E0C-4904-967B-40B0D20C3E4B}
         Data.l $4D9F7874
         Data.w $4E0C,$4904
         Data.b $96,$7B,$40,$B0,$D2,$0C,$3E,$4B
         
         FOLDERID_ControlPanelFolder: ; {82A74AEB-AEB4-465C-A014-D097EE346D63}
         Data.l $82A74AEB
         Data.w $AEB4,$465C
         Data.b $A0,$14,$D0,$97,$EE,$34,$6D,$63
         
         FOLDERID_PrintersFolder: ; {76FC4E2D-D6AD-4519-A663-37BD56068185}
         Data.l $76FC4E2D
         Data.w $D6AD,$4519
         Data.b $A6,$63,$37,$BD,$56,$06,$81,$85
         
         FOLDERID_SyncManagerFolder: ; {43668BF8-C14E-49B2-97C9-747784D784B7}
         Data.l $43668BF8
         Data.w $C14E,$49B2
         Data.b $97,$C9,$74,$77,$84,$D7,$84,$B7
         
         FOLDERID_SyncSetupFolder: ; {0F214138-B1D3-4A90-BBA9-27CBC0C5389A}
         Data.l $F214138
         Data.w $B1D3,$4A90
         Data.b $BB,$A9,$27,$CB,$C0,$C5,$38,$9A
         
         FOLDERID_ConflictFolder: ; {4BFEFB45-347D-4006-A5BE-AC0CB0567192}
         Data.l $4BFEFB45
         Data.w $347D,$4006
         Data.b $A5,$BE,$AC,$0C,$B0,$56,$71,$92
         
         FOLDERID_SyncResultsFolder: ; {289A9A43-BE44-4057-A41B-587A76D7E7F9}
         Data.l $289A9A43
         Data.w $BE44,$4057
         Data.b $A4,$1B,$58,$7A,$76,$D7,$E7,$F9
         
         FOLDERID_RecycleBinFolder: ; {B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}
         Data.l $B7534046
         Data.w $3ECB,$4C18
         Data.b $BE,$4E,$64,$CD,$4C,$B7,$D6,$AC
         
         FOLDERID_ConnectionsFolder: ; {6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}
         Data.l $6F0CD92B
         Data.w $2E97,$45D1
         Data.b $88,$FF,$B0,$D1,$86,$B8,$DE,$DD
         
         FOLDERID_Fonts: ; {FD228CB7-AE11-4AE3-864C-16F3910AB8FE}
         Data.l $FD228CB7
         Data.w $AE11,$4AE3
         Data.b $86,$4C,$16,$F3,$91,$0A,$B8,$FE
         
         FOLDERID_Desktop: ; {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
         Data.l $B4BFCC3A
         Data.w $DB2C,$424C
         Data.b $B0,$29,$7F,$E9,$9A,$87,$C6,$41
         
         FOLDERID_Startup: ; {B97D20BB-F46A-4C97-BA10-5E3608430854}
         Data.l $B97D20BB
         Data.w $F46A,$4C97
         Data.b $BA,$10,$5E,$36,$08,$43,$08,$54
         
         FOLDERID_Programs: ; {A77F5D77-2E2B-44C3-A6A2-ABA601054A51}
         Data.l $A77F5D77
         Data.w $2E2B,$44C3
         Data.b $A6,$A2,$AB,$A6,$01,$05,$4A,$51
         
         FOLDERID_StartMenu: ; {625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}
         Data.l $625B53C3
         Data.w $AB48,$4EC1
         Data.b $BA,$1F,$A1,$EF,$41,$46,$FC,$19
         
         FOLDERID_Recent: ; {AE50C081-EBD2-438A-8655-8A092E34987A}
         Data.l $AE50C081
         Data.w $EBD2,$438A
         Data.b $86,$55,$8A,$09,$2E,$34,$98,$7A
         
         FOLDERID_SendTo: ; {8983036C-27C0-404B-8F08-102D10DCFD74}
         Data.l $8983036C
         Data.w $27C0,$404B
         Data.b $8F,$08,$10,$2D,$10,$DC,$FD,$74
         
         FOLDERID_Documents: ; {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
         Data.l $FDD39AD0
         Data.w $238F,$46AF
         Data.b $AD,$B4,$6C,$85,$48,$03,$69,$C7
         
         FOLDERID_Favorites: ; {1777F761-68AD-4D8A-87BD-30B759FA33DD}
         Data.l $1777F761
         Data.w $68AD,$4D8A
         Data.b $87,$BD,$30,$B7,$59,$FA,$33,$DD
         
         FOLDERID_NetHood: ; {C5ABBF53-E17F-4121-8900-86626FC2C973}
         Data.l $C5ABBF53
         Data.w $E17F,$4121
         Data.b $89,$00,$86,$62,$6F,$C2,$C9,$73
         
         FOLDERID_PrintHood: ; {9274BD8D-CFD1-41C3-B35E-B13F55A758F4}
         Data.l $9274BD8D
         Data.w $CFD1,$41C3
         Data.b $B3,$5E,$B1,$3F,$55,$A7,$58,$F4
         
         FOLDERID_Templates: ; {A63293E8-664E-48DB-A079-DF759E0509F7}
         Data.l $A63293E8
         Data.w $664E,$48DB
         Data.b $A0,$79,$DF,$75,$9E,$05,$09,$F7
         
         FOLDERID_CommonStartup: ; {82A5EA35-D9CD-47C5-9629-E15D2F714E6E}
         Data.l $82A5EA35
         Data.w $D9CD,$47C5
         Data.b $96,$29,$E1,$5D,$2F,$71,$4E,$6E
         
         FOLDERID_CommonPrograms: ; {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}
         Data.l $0139D44E
         Data.w $6AFE,$49F2
         Data.b $86,$90,$3D,$AF,$CA,$E6,$FF,$B8
         
         FOLDERID_CommonStartMenu: ; {A4115719-D62E-491D-AA7C-E74B8BE3B067}
         Data.l $A4115719
         Data.w $D62E,$491D
         Data.b $AA,$7C,$E7,$4B,$8B,$E3,$B0,$67
         
         FOLDERID_PublicDesktop: ; {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}
         Data.l $C4AA340D
         Data.w $F20F,$4863
         Data.b $AF,$EF,$F8,$7E,$F2,$E6,$BA,$25
         
         FOLDERID_ProgramData: ; {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}
         Data.l $62AB5D82
         Data.w $FDC1,$4DC3
         Data.b $A9,$DD,$07,$0D,$1D,$49,$5D,$97
         
         FOLDERID_CommonTemplates: ; {B94237E7-57AC-4347-9151-B08C6C32D1F7}
         Data.l $B94237E7
         Data.w $57AC,$4347
         Data.b $91,$51,$B0,$8C,$6C,$32,$D1,$F7
         
         FOLDERID_PublicDocuments: ; {ED4824AF-DCE4-45A8-81E2-FC7965083634}
         Data.l $ED4824AF
         Data.w $DCE4,$45A8
         Data.b $81,$E2,$FC,$79,$65,$08,$36,$34
         
         FOLDERID_RoamingAppData: ; {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}
         Data.l $3EB685DB
         Data.w $65F9,$4CF6
         Data.b $A0,$3A,$E3,$EF,$65,$72,$9F,$3D
         
         FOLDERID_LocalAppData: ; {F1B32785-6FBA-4FCF-9D55-7B8E7F157091}
         Data.l $F1B32785
         Data.w $6FBA,$4FCF
         Data.b $9D,$55,$7B,$8E,$7F,$15,$70,$91
         
         FOLDERID_LocalAppDataLow: ; {A520A1A4-1780-4FF6-BD18-167343C5AF16}
         Data.l $A520A1A4
         Data.w $1780,$4FF6
         Data.b $BD,$18,$16,$73,$43,$C5,$AF,$16
         
         FOLDERID_InternetCache: ; {352481E8-33BE-4251-BA85-6007CAEDCF9D}
         Data.l $352481E8
         Data.w $33BE,$4251
         Data.b $BA,$85,$60,$07,$CA,$ED,$CF,$9D
         
         FOLDERID_Cookies: ; {2B0F765D-C0E9-4171-908E-08A611B84FF6}
         Data.l $2B0F765D
         Data.w $C0E9,$4171
         Data.b $90,$8E,$08,$A6,$11,$B8,$4F,$F6
         
         FOLDERID_History: ; {D9DC8A3B-B784-432E-A781-5A1130A75963}
         Data.l $D9DC8A3B
         Data.w $B784,$432E
         Data.b $A7,$81,$5A,$11,$30,$A7,$59,$63
         
         FOLDERID_System: ; {1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}
         Data.l $1AC14E77
         Data.w $02E7,$4E5D
         Data.b $B7,$44,$2E,$B1,$AE,$51,$98,$B7
         
         FOLDERID_SystemX86: ; {D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}
         Data.l $D65231B0
         Data.w $B2F1,$4857
         Data.b $A4,$CE,$A8,$E7,$C6,$EA,$7D,$27
         
         FOLDERID_Windows: ; {F38BF404-1D43-42F2-9305-67DE0B28FC23}
         Data.l $F38BF404
         Data.w $1D43,$42F2
         Data.b $93,$05,$67,$DE,$0B,$28,$FC,$23
         
         FOLDERID_Profile: ; {5E6C858F-0E22-4760-9AFE-EA3317B67173}
         Data.l $5E6C858F
         Data.w $0E22,$4760
         Data.b $9A,$FE,$EA,$33,$17,$B6,$71,$73
         
         FOLDERID_Pictures: ; {33E28130-4E1E-4676-835A-98395C3BC3BB}
         Data.l $33E28130
         Data.w $4E1E,$4676
         Data.b $83,$5A,$98,$39,$5C,$3B,$C3,$BB
         
         FOLDERID_ProgramFilesX86: ; {7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}
         Data.l $7C5A40EF
         Data.w $A0FB,$4BFC
         Data.b $87,$4A,$C0,$F2,$E0,$B9,$FA,$8E
         
         FOLDERID_ProgramFilesCommonX86: ; {DE974D24-D9C6-4D3E-BF91-F4455120B917}
         Data.l $DE974D24
         Data.w $D9C6,$4D3E
         Data.b $BF,$91,$F4,$45,$51,$20,$B9,$17
         
         FOLDERID_ProgramFilesX64: ; {6D809377-6AF0-444B-8957-A3773F02200E}
         Data.l $6D809377
         Data.w $6AF0,$444B
         Data.b $89,$57,$A3,$77,$3F,$02,$20,$0E
         
         FOLDERID_ProgramFilesCommonX64: ; {6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}
         Data.l $6365D5A7
         Data.w $F0D,$45E5
         Data.b $87,$F6,$D,$A5,$6B,$6A,$4F,$7D
         
         FOLDERID_ProgramFiles: ; {905E63B6-C1BF-494E-B29C-65B732D3D21A}
         Data.l $905E63B6
         Data.w $C1BF,$494E
         Data.b $B2,$9C,$65,$B7,$32,$D3,$D2,$1A
         
         FOLDERID_ProgramFilesCommon: ; {F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}
         Data.l $F7F1ED05
         Data.w $9F6D,$47A2
         Data.b $AA,$AE,$29,$D3,$17,$C6,$F0,$66
         
         FOLDERID_UserProgramFiles: ; {5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}
         Data.l $5CD7AEE2
         Data.w $2219,$4A67
         Data.b $B8,$5D,$6C,$9C,$E1,$56,$60,$CB
         
         FOLDERID_UserProgramFilesCommon: ; {BCBD3057-CA5C-4622-B42D-BC56DB0AE516}
         Data.l $BCBD3057
         Data.w $CA5C,$4622
         Data.b $B4,$2D,$BC,$56,$DB,$0A,$E5,$16
         
         FOLDERID_AdminTools: ; {724EF170-A42D-4FEF-9F26-B60E846FBA4F}
         Data.l $724EF170
         Data.w $A42D,$4FEF
         Data.b $9F,$26,$B6,$0E,$84,$6F,$BA,$4F
         
         FOLDERID_CommonAdminTools: ; {D0384E7D-BAC3-4797-8F14-CBA229B392B5}
         Data.l $D0384E7D
         Data.w $BAC3,$4797
         Data.b $8F,$14,$CB,$A2,$29,$B3,$92,$B5
         
         FOLDERID_Music: ; {4BD8D571-6D19-48D3-BE97-422220080E43}
         Data.l $4BD8D571
         Data.w $6D19,$48D3
         Data.b $BE,$97,$42,$22,$20,$08,$0E,$43
         
         FOLDERID_Videos: ; {18989B1D-99B5-455B-841C-AB7C74E4DDFC}
         Data.l $18989B1D
         Data.w $99B5,$455B
         Data.b $84,$1C,$AB,$7C,$74,$E4,$DD,$FC
         
         FOLDERID_Ringtones: ; {C870044B-F49E-4126-A9C3-B52A1FF411E8}
         Data.l $C870044B
         Data.w $F49E,$4126
         Data.b $A9,$C3,$B5,$2A,$1F,$F4,$11,$E8
         
         FOLDERID_PublicPictures: ; {B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}
         Data.l $B6EBFB86
         Data.w $6907,$413C
         Data.b $9A,$F7,$4F,$C2,$AB,$F0,$7C,$C5
         
         FOLDERID_PublicMusic: ; {3214FAB5-9757-4298-BB61-92A9DEAA44FF}
         Data.l $3214FAB5
         Data.w $9757,$4298
         Data.b $BB,$61,$92,$A9,$DE,$AA,$44,$FF
         
         FOLDERID_PublicVideos: ; {2400183A-6185-49FB-A2D8-4A392A602BA3}
         Data.l $2400183A
         Data.w $6185,$49FB
         Data.b $A2,$D8,$4A,$39,$2A,$60,$2B,$A3
         
         FOLDERID_PublicRingtones: ; {E555AB60-153B-4D17-9F04-A5FE99FC15EC}
         Data.l $E555AB60
         Data.w $153B,$4D17
         Data.b $9F,$04,$A5,$FE,$99,$FC,$15,$EC
         
         FOLDERID_ResourceDir: ; {8AD10C31-2ADB-4296-A8F7-E4701232C972}
         Data.l $8AD10C31
         Data.w $2ADB,$4296
         Data.b $A8,$F7,$E4,$70,$12,$32,$C9,$72
         
         FOLDERID_LocalizedResourcesDir: ; {2A00375E-224C-49DE-B8D1-440DF7EF3DDC}
         Data.l $2A00375E
         Data.w $224C,$49DE
         Data.b $B8,$D1,$44,$0D,$F7,$EF,$3D,$DC
         
         FOLDERID_CommonOEMLinks: ; {C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}
         Data.l $C1BAE2D0
         Data.w $10DF,$4334
         Data.b $BE,$DD,$7A,$A2,$0B,$22,$7A,$9D
         
         FOLDERID_CDBurning: ; {9E52AB10-F80D-49DF-ACB8-4330F5687855}
         Data.l $9E52AB10
         Data.w $F80D,$49DF
         Data.b $AC,$B8,$43,$30,$F5,$68,$78,$55
         
         FOLDERID_UserProfiles: ; {0762D272-C50A-4BB0-A382-697DCD729B80}
         Data.l $0762D272
         Data.w $C50A,$4BB0
         Data.b $A3,$82,$69,$7D,$CD,$72,$9B,$80
         
         FOLDERID_Playlists: ; {DE92C1C7-837F-4F69-A3BB-86E631204A23}
         Data.l $DE92C1C7
         Data.w $837F,$4F69
         Data.b $A3,$BB,$86,$E6,$31,$20,$4A,$23
         
         FOLDERID_SamplePlaylists: ; {15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}
         Data.l $15CA69B3
         Data.w $30EE,$49C1
         Data.b $AC,$E1,$6B,$5E,$C3,$72,$AF,$B5
         
         FOLDERID_SampleMusic: ; {B250C668-F57D-4EE1-A63C-290EE7D1AA1F}
         Data.l $B250C668
         Data.w $F57D,$4EE1
         Data.b $A6,$3C,$29,$0E,$E7,$D1,$AA,$1F
         
         FOLDERID_SamplePictures: ; {C4900540-2379-4C75-844B-64E6FAF8716B}
         Data.l $C4900540
         Data.w $2379,$4C75
         Data.b $84,$4B,$64,$E6,$FA,$F8,$71,$6B
         
         FOLDERID_SampleVideos: ; {859EAD94-2E85-48AD-A71A-0969CB56A6CD}
         Data.l $859EAD94
         Data.w $2E85,$48AD
         Data.b $A7,$1A,$09,$69,$CB,$56,$A6,$CD
         
         FOLDERID_PhotoAlbums: ; {69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}
         Data.l $69D2CF90
         Data.w $FC33,$4FB7
         Data.b $9A,$0C,$EB,$B0,$F0,$FC,$B4,$3C
         
         FOLDERID_Public: ; {DFDF76A2-C82A-4D63-906A-5644AC457385}
         Data.l $DFDF76A2
         Data.w $C82A,$4D63
         Data.b $90,$6A,$56,$44,$AC,$45,$73,$85
         
         FOLDERID_ChangeRemovePrograms: ; {DF7266AC-9274-4867-8D55-3BD661DE872D}
         Data.l $DF7266AC
         Data.w $9274,$4867
         Data.b $8D,$55,$3B,$D6,$61,$DE,$87,$2D
         
         FOLDERID_AppUpdates: ; {A305CE99-F527-492B-8B1A-7E76FA98D6E4}
         Data.l $A305CE99
         Data.w $F527,$492B
         Data.b $8B,$1A,$7E,$76,$FA,$98,$D6,$E4
         
         FOLDERID_AddNewPrograms: ; {DE61D971-5EBC-4F02-A3A9-6C82895E5C04}
         Data.l $DE61D971
         Data.w $5EBC,$4F02
         Data.b $A3,$A9,$6C,$82,$89,$5E,$5C,$04
         
         FOLDERID_Downloads: ; {374DE290-123F-4565-9164-39C4925E467B}
         Data.l $374DE290
         Data.w $123F,$4565
         Data.b $91,$64,$39,$C4,$92,$5E,$46,$7B
         
         FOLDERID_PublicDownloads: ; {3D644C9B-1FB8-4F30-9B45-F670235F79C0}
         Data.l $3D644C9B
         Data.w $1FB8,$4F30
         Data.b $9B,$45,$F6,$70,$23,$5F,$79,$C0
         
         FOLDERID_SavedSearches: ; {7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}
         Data.l $7D1D3A04
         Data.w $DEBB,$4115
         Data.b $95,$CF,$2F,$29,$DA,$29,$20,$DA
         
         FOLDERID_QuickLaunch: ; {52A4F021-7B75-48A9-9F6B-4B87A210BC8F}
         Data.l $52A4F021
         Data.w $7B75,$48A9
         Data.b $9F,$6B,$4B,$87,$A2,$10,$BC,$8F
         
         FOLDERID_Contacts: ; {56784854-C6CB-462B-8169-88E350ACB882}
         Data.l $56784854
         Data.w $C6CB,$462B
         Data.b $81,$69,$88,$E3,$50,$AC,$B8,$82
         
         FOLDERID_PublicGameTasks: ; {DEBF2536-E1A8-4C59-B6A2-414586476AEA}
         Data.l $DEBF2536
         Data.w $E1A8,$4C59
         Data.b $B6,$A2,$41,$45,$86,$47,$6A,$EA
         
         FOLDERID_GameTasks: ; {054FAE61-4DD8-4787-80B6-090220C4B700}
         Data.l $54FAE61
         Data.w $4DD8,$4787
         Data.b $80,$B6,$9,$2,$20,$C4,$B7,$0
         
         FOLDERID_SavedGames: ; {4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}
         Data.l $4C5C32FF
         Data.w $BB9D,$43B0
         Data.b $B5,$B4,$2D,$72,$E5,$4E,$AA,$A4
         
         FOLDERID_Games: ; {CAC52C1A-B53D-4EDC-92D7-6B2E8AC19434}
         Data.l $CAC52C1A
         Data.w $B53D,$4EDC
         Data.b $92,$D7,$6B,$2E,$8A,$C1,$94,$34
         
         FOLDERID_SEARCH_MAPI: ; {98EC0E18-2098-4D44-8644-66979315A281}
         Data.l $98EC0E18
         Data.w $2098,$4D44
         Data.b $86,$44,$66,$97,$93,$15,$A2,$81
         
         FOLDERID_SEARCH_CSC: ; {EE32E446-31CA-4ABA-814F-A5EBD2FD6D5E}
         Data.l $EE32E446
         Data.w $31CA,$4ABA
         Data.b $81,$4F,$A5,$EB,$D2,$FD,$6D,$5E
         
         FOLDERID_Links: ; {BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}
         Data.l $BFB9D5E0
         Data.w $C6A9,$404C
         Data.b $B2,$B2,$AE,$6D,$B6,$AF,$49,$68
         
         FOLDERID_UsersFiles: ; {F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F}
         Data.l $F3CE0F7C
         Data.w $4901,$4ACC
         Data.b $86,$48,$D5,$D4,$4B,$04,$EF,$8F
         
         FOLDERID_UsersLibraries: ; {A302545D-DEFF-464B-ABE8-61C8648D939B}
         Data.l $A302545D
         Data.w $DEFF,$464B
         Data.b $AB,$E8,$61,$C8,$64,$8D,$93,$9B
         
         FOLDERID_SearchHome: ; {190337D1-B8CA-4121-A639-6D472D16972A}
         Data.l $190337D1
         Data.w $B8CA,$4121
         Data.b $A6,$39,$6D,$47,$2D,$16,$97,$2A
         
         FOLDERID_OriginalImages: ; {2C36C0AA-5812-4B87-BFD0-4CD0DFB19B39}
         Data.l $2C36C0AA
         Data.w $5812,$4B87
         Data.b $BF,$D0,$4C,$D0,$DF,$B1,$9B,$39
         
         FOLDERID_DocumentsLibrary: ; {7B0DB17D-9CD2-4A93-9733-46CC89022E7C}
         Data.l $7B0DB17D
         Data.w $9CD2,$4A93
         Data.b $97,$33,$46,$CC,$89,$02,$2E,$7C
         
         FOLDERID_MusicLibrary: ; {2112AB0A-C86A-4FFE-A368-0DE96E47012E}
         Data.l $2112AB0A
         Data.w $C86A,$4FFE
         Data.b $A3,$68,$D,$E9,$6E,$47,$1,$2E
         
         FOLDERID_PicturesLibrary: ; {A990AE9F-A03B-4E80-94BC-9912D7504104}
         Data.l $A990AE9F
         Data.w $A03B,$4E80
         Data.b $94,$BC,$99,$12,$D7,$50,$41,$4
         
         FOLDERID_VideosLibrary: ; {491E922F-5643-4AF4-A7EB-4E7A138D8174}
         Data.l $491E922F
         Data.w $5643,$4AF4
         Data.b $A7,$EB,$4E,$7A,$13,$8D,$81,$74
         
         FOLDERID_RecordedTVLibrary: ; {1A6FDBA2-F42D-4358-A798-B74D745926C5}
         Data.l $1A6FDBA2
         Data.w $F42D,$4358
         Data.b $A7,$98,$B7,$4D,$74,$59,$26,$C5
         
         FOLDERID_HomeGroup: ; {52528A6B-B9E3-4ADD-B60D-588C2DBA842D}
         Data.l $52528A6B
         Data.w $B9E3,$4ADD
         Data.b $B6,$D,$58,$8C,$2D,$BA,$84,$2D
         
         FOLDERID_DeviceMetadataStore: ; {5CE4A5E9-E4EB-479D-B89F-130C02886155}
         Data.l $5CE4A5E9
         Data.w $E4EB,$479D
         Data.b $B8,$9F,$13,$0C,$02,$88,$61,$55
         
         FOLDERID_Libraries: ; {1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}
         Data.l $1B3EA5DC
         Data.w $B587,$4786
         Data.b $B4,$EF,$BD,$1D,$C3,$32,$AE,$AE
         
         FOLDERID_PublicLibraries: ; {48DAF80B-E6CF-4F4E-B800-0E69D84EE384}
         Data.l $48DAF80B
         Data.w $E6CF,$4F4E
         Data.b $B8,$00,$0E,$69,$D8,$4E,$E3,$84
         
         FOLDERID_UserPinned: ; {9E3995AB-1F9C-4F13-B827-48B24B6C7174}
         Data.l $9E3995AB
         Data.w $1F9C,$4F13
         Data.b $B8,$27,$48,$B2,$4B,$6C,$71,$74
         
         FOLDERID_ImplicitAppShortcuts: ; {BCB5256F-79F6-4CEE-B725-DC34E402FD46}
         Data.l $BCB5256F
         Data.w $79F6,$4CEE
         Data.b $B7,$25,$DC,$34,$E4,$2,$FD,$46
     EndDataSection	
EndModule

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 478
; FirstLine = 194
; Folding = DGBQAAAg-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\NewGame\