DeclareModule SaveTool
    
	Declare.i FileCheck()
	Declare.i SaveFile_Close()
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
	Declare.i SaveConfig_SetKeyValue(KeyValue.s = "Folder", FolderValue.i = 1, KeyBool.i = #False, KeyDelay.i = 250)
	
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
    	;Age.l
    	;List Friends.s()
  EndStructure
    
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
		FirstElement( SaveOptions() )	
		bValue.b = SaveOptions()\RestoreData
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
		FirstElement( SaveOptions() )	
		bValue.b = SaveOptions()\BackupData
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
  	If FileSize( Startup::*LHGameDB\SaveTool\SaveFile ) = -1
  		ProcedureReturn "Status: Nicht Konfiguriert"
  	EndIf
  	ProcedureReturn "Status: Konfiguration OK"
  EndProcedure
  	;
		;  
  Procedure.i SaveConfig_ShowDirectories()
  	
  	Protected HomeUserFolder.s = ""
  	
  	If FileSize( Startup::*LHGameDB\SaveTool\SavePath ) = -2
  		
  		If Not FileSize( Startup::*LHGameDB\SaveTool\SaveFile ) = -1
  			ResetList(SaveDirectorys())
  			
  			ForEach SaveDirectorys() 	
  				HomeUserFolder.s +	Slash_Add( SaveDirectorys()\Directory$ ) + #CR$  				
  			Next	
  			
  			
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
  Procedure.i FileSystem_Search(DirectoryPath.s = "")
  	
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
  					
  				Case 1, 2, 4, 32, 128, 2048:
  					Select FileHandle\dwFileAttributes:
	  					Case 1:			;Debug "   1=FILE_ATTRIBUTE_READONLY"
	  					Case 2:			;Debug "   2=FILE_ATTRIBUTE_HIDDEN"
	  					Case 4:			;Debug "	 4=FILE_ATTRIBUTE_SYSTEM"
	  					Case 32:		;Debug "  32=FILE_ATTRIBUTE_ARCHIVE"
	  					Case 128:		;Debug " 128=FILE_ATTRIBUTE_NORMAL"
	  					Case 2048: 	;Debug "2048=FILE_ATTRIBUTE_COMPRESSED"  		
	  				EndSelect
	  					  				
	  				AddElement(FileSystemList())
	  				FileSystemList()\FCount = 1
	  				FileSystemList()\FullPath = DirectoryPath + FileSystemType
  					;Debug 	"Datei: " FileSystemList()\FullPath + " (Anzahl der Dateien: " + Str(FileCnt)
  						
  				Case 16:				;Debug "#FILE_ATTRIBUTE_DIRECTORY"			  		
  					
  					
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
  				Default		:	Debug "Unknown Attribute :" +Str( FileHandle\dwFileAttributes)
  			EndSelect
  		Wend
  	Else
  		Debug #INVALID_HANDLE_VALUE
  	EndIf
  	
  	FindClose_(FileHandle)
  	FindClose_(Result)
  	
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
  Procedure.l FileSystem_CompressOpen(PackDirectory.s)
  	
  	Protected hPackFile.l

		ProcedureReturn hPackFile
		
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
		Date.s = FormatDate("%yyyy-%mm-%dd#", Date())
		Time.s = FormatDate("%hh-%ii-%ss", Date())
		
		
		*PARAMS\PackFile = *PARAMS\Directory + "["+Date + Time + "]" +".7z"
		
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
      			
			CleanListing()
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
  	Protected ItemData.s = "", ItemDirectory.s = ""
  	;
		; Optionen die abgefragt und in die Liste geischert werden
  	Protected Value_RestoreData.s 			= "RestoreData"
  	Protected Value_BackupData.s  			= "Backup-Data" 			 			
  	Protected Value_RestoreDelay.s 		= "RestoreDelay"
  	Protected Value_BackupDelay.s 			= "Backup-Delay"  
  	Protected Value_BackupCompress.s 	= "BackupCompress"
  	;
		;
  	If ( Startup::*LHGameDB\SaveTool\SaveHandle )
  		
  		AddElement(SaveOptions())
  		
  		While Eof( Startup::*LHGameDB\SaveTool\SaveHandle ) = 0
  			
  			ItemData = ReadString(Startup::*LHGameDB\SaveTool\SaveHandle)
  			
  			If Left(ItemData, 1) = "[" And Right(ItemData, 1)= "]"
  				
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
  					Continue
  				EndIf	 
  				
  			ElseIf ( Left(ItemData,6) = "Folder" )
  				
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
  					SaveDirectorys()\Directory$ =  ItemDirectory
  				EndIf 
  				
  			ElseIf ( Left(ItemData,11) = Value_RestoreData )
  				Value.s = Value_RestoreData  				
  				SaveOptions()\RestoreData = SaveContent_Read_Options(Value, 11, ItemData, #True, #False)
  				If SaveOptions()\RestoreData = -1  					
  				EndIf      		
  				
  			ElseIf ( Left(ItemData,11) = Value_BackupData )
  				Value.s = Value_BackupData  				
  				SaveOptions()\BackupData = SaveContent_Read_Options(Value, 11, ItemData, #True, #False)
  				If SaveOptions()\BackupData = -1
  				EndIf	   					
  				
  			ElseIf ( Left(ItemData,12) =	Value_RestoreDelay )  				
  				Value.s = Value_RestoreDelay
  				SaveOptions()\RestoreDelay = SaveContent_Read_Options(Value, 12, ItemData, #False, #True)					      				
  				
  			ElseIf ( Left(ItemData,12) = Value_BackupDelay )  				
  				Value.s = Value_BackupDelay    			
  				SaveOptions()\BackupDelay = SaveContent_Read_Options(Value, 12, ItemData, #False, #True)						      			
  				
  			ElseIf ( Left(ItemData,14) = Value_BackupCompress )  				
  				Value.s = Value_BackupCompress
  				SaveOptions()\BackupCompress = SaveContent_Read_Options(Value, 14, ItemData, #True, #False)
  				If SaveOptions()\BackupData = -1
	 				EndIf					      				
  			EndIf      			      	            	
  		Wend      	    	
  	EndIf 	
  	SaveFile_Close()      
			
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
	Procedure.i SaveConfig_SetKeyValue(KeyValue.s = "Folder", FolderValue.i = 1, KeyBool.i = #False, KeyDelay.i = 250)	
		
  	Protected nPos.i, BrakeCount.i, TitleFound.i = #False
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
				Path = PathRequester("vSystem Save Support: Wähle SaveGame Ordner", "C:\Users\Traxx Amiga EP\")
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
  				Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Restore","Wieviel Zeit soll vergehen zwischen der Widerherstellung und dem Starten des Spiels",12,0,"",0,1,DC::#_Window_001)					
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
  			Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Backup","Wieviel Zeit soll vergehen zwischen dem Sichern und dem beenden des Spiels",12,0,"",0,1,DC::#_Window_001)
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
		           	"Wenn der Spiele Titel geändert wird muss auch der Titel in der"						+ #CR$ +
								"Konfigurations Datei sowie das Verzeichnis geändert werden."
		                   																										  
		           
		
		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support: Help",Helptext,2,0,"",0,0,DC::#_Window_001)	
		
	EndProcedure	
    
EndModule

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1236
; FirstLine = 318
; Folding = DAAABAE9
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\The Chaos Engine\