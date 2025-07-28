DeclareModule RegsTool
	
	Declare.i	Init()
	Declare.i 	Init_vEngineImport(Path.s = "", FileNum.i = 0)
	
	Declare.i  Menu_CreatConfig()
	Declare.i	Menu_AddGame()
	Declare.i	Menu_Import(FileNum = 0)
	Declare.s  RegsConfig_MenuFileExists()
	Declare.s	RegsConfig_GetGameTitle()
	Declare.i	RegsConfig_Edit(Option.i = 0)
	Declare.s	RegsConfigFile_Read_EncondingOnly(FileNum.i = 0)
	Declare.i  Menu_OpenAndEdit(FileNum.i = 0,szPath.s = "")
	Declare.i  Menu_OpenAndConvert(FileNum.i = 0,szPath.s = "")
	Declare.i  GameTitle_Change(szNewTitle.s = "", szOldTitle.s = "")
	Declare.i 	GameTitle_Compare()
	Declare.i	Registry_Cleaner()

	
EndDeclareModule

Module RegsTool
	
	
	;
	; Mehrere Schlüssel wo der Pfad geändert werden muss
	; Idee:
	; eine vSystem-RegistrySettings.ini
	;
	; Aufbau:
	;
	;	# PathUpdate-Keys=Install;Install1;Install2;Install3
	;	- Diese Keys werden automatisch von vSystems geändert und vor dem Import aktualisiert
			
	Structure STRUCT_PATHKEYCONTAINER
		Keys.s				
	EndStructure	
	NewList PathKeyContainer.STRUCT_PATHKEYCONTAINER()
	
	Structure STRUCT_PATHKEYCONTAINER_FOUND
		Keys.s				
	EndStructure	
	NewList PathKeyContFound.STRUCT_PATHKEYCONTAINER_FOUND()
	
	Structure STRUCT_SAFETOPKEYS
		TopKeyPath.s
		TopKey.i
		SubKeyPath.s
	EndStructure	
	NewList SafeTopKeys.STRUCT_SAFETOPKEYS()
	
	Structure STRUCT_REGISTRYFILE
		File.s
		Header.s
		Path.s
		Key.s
		Value.s
		EndofFile.i
		Separator.i
		TopKey.i		;like #HKEY_LOCAL_MACHINE, #HKEY_CURRENT_USER, #HKEY_CLASSES_ROOT ...
		Type.l			;like #REG_DWORD, #REG_EXPAND_SZ, #REG_SZ
	EndStructure
	NewList StructRegistryFile.STRUCT_REGISTRYFILE()
	
	Structure STRUCT_CONFIGREGISTRYFILE
		szString.s
	EndStructure
	NewList ConfigRegistryFile.STRUCT_CONFIGREGISTRYFILE()	
	
	Procedure.s GetLastError()
	  Protected ErrorBufferPointer.L
	  Protected ErrorCode.L
	  Protected ErrorText.S
	  Protected ferr
	  
	  ErrorCode = GetLastError_()
	  ferr = FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER | #FORMAT_MESSAGE_FROM_SYSTEM | #FORMAT_MESSAGE_IGNORE_INSERTS, 0 , ErrorCode, GetUserDefaultLangID_(), @ErrorBufferPointer, 0, 0)
	  If ErrorBufferPointer <> 0
	    ErrorText = PeekS(ErrorBufferPointer)
	    LocalFree_(ErrorBufferPointer)
	    ProcedureReturn RemoveString(ErrorText, #CRLF$)
	  EndIf
	  
	EndProcedure 
	;
  ; Liste in der sich Schlüssel Strings aufhalten die den Pfad beeinhalten
  Procedure.i Collect_SafeTopKeys()
  	
  	Shared SafeTopKeys()
  	
  	If ( ListSize( SafeTopKeys() ) -1 = -1 )
  		
  		AddElement( SafeTopKeys() ): SafeTopKeys()\TopKey = #HKEY_LOCAL_MACHINE:		SafeTopKeys()\TopKeyPath = "HKEY_LOCAL_MACHINE\"	: SafeTopKeys()\SubKeyPath = "Software\Wow6432Node\"  
  		AddElement( SafeTopKeys() ): SafeTopKeys()\TopKey = #HKEY_LOCAL_MACHINE:		SafeTopKeys()\TopKeyPath = "HKEY_LOCAL_MACHINE\"	: SafeTopKeys()\SubKeyPath = "Software\"
  		AddElement( SafeTopKeys() ): SafeTopKeys()\TopKey = #HKEY_CURRENT_USER :		SafeTopKeys()\TopKeyPath = "HKEY_CURRENT_USER\" 	: SafeTopKeys()\SubKeyPath = "Software\" 		
  	EndIf
  EndProcedure  	
	;
  ; Liste in der sich Schlüssel Strings aufhalten die den Pfad beeinhalten
  Procedure.i Collect_PathKeys()
  	
  	Shared PathKeyContainer()
  	
  	If ( ListSize( PathKeyContainer() ) -1 = -1 )
  		
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "InstExec"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "InstPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "Installdir"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "InstallPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "ArchivePath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "Shared"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "UserSelect"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "SavePath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "ScreenShotPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "MoviePath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "MusicPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "LogPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "ModPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "FaceMatePath"  			
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "ImportPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "CommunityPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "CommunityCustomizerPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "CommunitySequencerPath"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "NewGameLocationMod"
  			AddElement( PathKeyContainer() ): PathKeyContainer()\Keys = "NewGameLocationPE"   			
			
  			ResetList( PathKeyContainer() )
  		Else
  			ResetList( PathKeyContainer() )
  	EndIf
  			
  EndProcedure  
  ;
	;
  Procedure.i ClearListings()
  	
  	Shared PathKeyContainer(), StructRegistryFile()
  	
  	If ( ListSize( StructRegistryFile() ) -1 > -1 )
				ClearList( StructRegistryFile() )	
		EndIf
		
  	If ( ListSize( PathKeyContainer() ) -1 > -1 )
				ClearList( PathKeyContainer() )	
		EndIf
			
  EndProcedure
 	;
 	;
	Procedure.i RegsConfigFile_Create()		
		Startup::*LHGameDB\RegsTool\Configandle =  CreateFile( #PB_Any,  Startup::*LHGameDB\RegsTool\ConfigFile )
	EndProcedure 
    ;
    ;	      
	Procedure.i RegsConfigFile_Open(lOptions = 0)
		Protected PBFileFlag.i
		
		Select lOptions
			Case 0: PBFileFlag = #PB_File_SharedRead| #PB_File_SharedWrite
			Case 1: PBFileFlag = #PB_File_SharedRead| #PB_File_SharedWrite|	#PB_File_Append ; #PB_File_Append = Sprint an das ende der Datei
			Case 2: PBFileFlag = #PB_File_SharedRead| #PB_File_SharedWrite
		EndSelect
		
		Startup::*LHGameDB\RegsTool\Configandle =  OpenFile( #PB_Any,  Startup::*LHGameDB\RegsTool\ConfigFile, PBFileFlag )
		
	EndProcedure  	
	;
	;
	Procedure.i RegsConfigFile_Close()
		If ( Startup::*LHGameDB\RegsTool\Configandle )
			CloseFile( Startup::*LHGameDB\RegsTool\Configandle )
		EndIf
	EndProcedure
	;
	;	
	Procedure.s PB_GetPrivateProfileString(lpAppName.s, lpKeyName.s , lpDefault.s , lpReturnedString.s , nSize.i, lpFileName.s) 		
  	
  	;        DWORD GetPrivateProfileString(
		;           LPCTSTR lpAppName,
		;           LPCTSTR lpKeyName,
		;           LPCTSTR lpDefault,
		;           LPTSTR  lpReturnedString,
		;           DWORD   nSize,
		;           LPCTSTR lpFileName
		;        );   
  	
  	GetPrivateProfileString_ (@lpAppName, @lpKeyName , @lpDefault , @lpReturnedString , nSize, @lpFileName) 
  	ProcedureReturn lpReturnedString       
	EndProcedure 
	;
	;
 	Procedure.s RegsConfig_GetGameTitle()
 		ProcedureReturn  ExecSQL::nRow(DC::#Database_001,"Gamebase","GameTitle","",Startup::*LHGameDB\GameID ,"",1)
 	EndProcedure	
	;
	; 
	Procedure.i RegsConfigFile_ReadSettings() 
		
		Protected FileHandle.l, szString.s
		
		Shared ConfigRegistryFile()
		
		If ( ListSize( ConfigRegistryFile() ) -1 = -1 )			
			RegsConfigFile_Open()
			If ( Startup::*LHGameDB\RegsTool\Configandle > 0)
				
				While Eof( Startup::*LHGameDB\RegsTool\Configandle ) = 0
					AddElement( ConfigRegistryFile() )
					ConfigRegistryFile()\szString = ReadString( Startup::*LHGameDB\RegsTool\Configandle)
				Wend
				RegsConfigFile_Close()
				ProcedureReturn ListSize( ConfigRegistryFile() ) -1 				
			EndIf									
		EndIf
		ProcedureReturn -1       
	EndProcedure
	;
	;
	Procedure.i RegsConfigFile_SaveSettings()
		
		Protected FileHandle.l
		          
		Shared ConfigRegistryFile()
		
		If ( ListSize( ConfigRegistryFile() ) -1 > -1 )	
			
			ResetList( ConfigRegistryFile() )
			
			RegsConfigFile_Create()
			If ( Startup::*LHGameDB\RegsTool\Configandle > 0)
				While NextElement(  ConfigRegistryFile() )					
					WriteStringN( Startup::*LHGameDB\RegsTool\Configandle, ConfigRegistryFile()\szString )					
				Wend
				RegsConfigFile_Close()
				ProcedureReturn #True
			EndIf
		EndIf
		ProcedureReturn #False		
		
	EndProcedure
	;
	; 	
	Procedure.i	GameTitle_GetandChange(szNewTitle.s = "", szOldTitle.s = "", bChange.b = #False)
		
		Protected CurrentTitle.s = "[" + szOldTitle + "]"
		
		If ( Len( szNewTitle ) > 0 ) And ( bChange = #True )
			szNewTitle.s =  "[" + szNewTitle + "]"			
		EndIf
		
		
		Shared ConfigRegistryFile()
		
		RegsConfigFile_ReadSettings() 
		
		If ( ListSize( ConfigRegistryFile() ) -1 > -1 )	
			
			ResetList( ConfigRegistryFile() )
			
			While NextElement( ConfigRegistryFile() )				
				If ( Left(ConfigRegistryFile()\szString, 1) = "[" And Right(ConfigRegistryFile()\szString, 1)= "]" )		
					Debug ConfigRegistryFile()\szString
					
					If UCase(CurrentTitle) = UCase(ConfigRegistryFile()\szString)
						
						If UCase(CurrentTitle) = UCase(szNewTitle)
							;
							; Keine änderung nötig
							ClearList(  ConfigRegistryFile() )
							ProcedureReturn #False
						EndIf
						
						If ( bChange = #True )
							ConfigRegistryFile()\szString = szNewTitle
							RegsConfigFile_SaveSettings()							
						EndIf
						ClearList(  ConfigRegistryFile() )
						ProcedureReturn #True
					EndIf
				EndIf
			Wend	
		EndIf

		ProcedureReturn #False
	EndProcedure	
	;
	;
	Procedure.i GameTitle_Change(szNewTitle.s = "", szOldTitle.s = "")
		
		If FileSize( Startup::*LHGameDB\RegsTool\ConfigFile  ) > 0
			GameTitle_GetandChange(szNewTitle.s,szOldTitle, #True)		
		EndIf
		
	EndProcedure
	;
	;
	Procedure.i GameTitle_Compare()
		
		Protected Result.i
		If FileSize( Startup::*LHGameDB\RegsTool\ConfigFile  ) > 0
			Result = GameTitle_GetandChange("",RegsConfig_GetGameTitle(), #False)		
			ProcedureReturn Result
		EndIf
		ProcedureReturn #False
		
	EndProcedure
	;
	; Prüft beim Hinzufügen eines Titles ob dieser schon exisitert
	Procedure.b Exists_GameTitle()
		
			RegsConfigFile_Open()
 			If ( Startup::*LHGameDB\RegsTool\Configandle )
    		While Eof( Startup::*LHGameDB\RegsTool\Configandle ) = 0
    			
      		ItemData.s = ReadString(Startup::*LHGameDB\RegsTool\Configandle)
      		      		
      		If Left(ItemData, 1) = "[" And Right(ItemData, 1)= "]"      		   		    				
    				;
						; Vergleiche den Title aus der Config mit dem aus der Datenbank
    				; 
    				ItemData = Mid(ItemData, 2, Len(ItemData)-2 )
    				If (LCase(RegsConfig_GetGameTitle()) = LCase(ItemData) )
    					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Save Support","Der Titel: '"+ItemData+"' existiert in der Konfiguration",2,1,"",0,0,DC::#_Window_001)
    					RegsConfigFile_Close()
							ProcedureReturn #True
    				EndIf			
    			EndIf
    			
    		Wend	    		
    	EndIf    
    	RegsConfigFile_Close()
    	ProcedureReturn #False
   EndProcedure		
	;
	;	
	Procedure.b RegsConfig_CreateDirectory()
		Select FileSize( Startup::*LHGameDB\RegsTool\ConfigPath )			
				; Kein Verzeichnis
				; MessageRequester
			Case -1
				CreateDirectory( Startup::*LHGameDB\RegsTool\ConfigPath )
				ProcedureReturn #True
				
    EndSelect 			
    
    ProcedureReturn #False
	EndProcedure		
	;
	;
	Procedure.i RegsConfigFile_Generate_Options()
			;
			; 5 Registry Dateien per Game sollten reichen. Mehr habe ich in einem Spiel noch nicht gesehen
			; Uninstall Information mit einbrechnet
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "RegFile001=")			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "RegFile002=")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "RegFile003=")	
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "RegFile004=")	
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "RegFile005=")	
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "KeysToChange=")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "Clean=false")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "Is32Biton64=true")
			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "")				
	EndProcedure
	Procedure.i RegsConfigFile_Generate()
		
		RegsConfig_CreateDirectory() 
		
		RegsConfigFile_Create()
		If ( Startup::*LHGameDB\RegsTool\Configandle )
		; Da muss ich mir ein Text ausdenken
			WriteString (Startup::*LHGameDB\RegsTool\Configandle, "" + #CR$)
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# vSystem Registry Support: Import & Export for Oldgames (~1998 - ~2016)")		
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# Hints: GameTitle        : Database 1st Title & 2nd Title. Folder[count] = Directory")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# Hints: Folder[count]    : Folder[count] = Point to Directory(s) Backup/Restore")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#")			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# GAMETITLE is the exzact the Game and Sub Title in vSystem]")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#")				
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# RegFile 1 - 5 are the ReistryFile in the Folder .\REGS\")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# KeysToChange are the Keys in the Registryfile the old the Path(s)")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# For Example KeysToChange=Install(0); Path(1); InstExec(2); InstallPath")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# - Das Trennzeichen für die Keys ist der delimter ';'")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   Mehrere Pfade und unterschiedliche Schlüssel drinstehen")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# - Die Nummern in den Klammern sind die Anzahl der Backslashs (Unterordner)")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   (0) = vSystem Ändert den Pfad komplett sowie wie er drinsteht")			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   (1) = vSystem Achtet auf den letzten Unterodner")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   (2) = vSystem Achtet auf die  letzten 2 Unterodner und so weiter")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   Beispiele: Das [AV] Aktuelles Verzeichnis ist das in vSystem Konfigurierte Program")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   Beispiel: KeysToChange=Install(0) ist das selbe wie KeysToChange=Install")			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   - Ändert: Install=C:\Program Files\GameXYZ > Install=[X]:\[AV] ")	
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   Beispiel: KeysToChange=Path(1)")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   - Ändert: Path=C:\Program Files\GameXYZ\Subordner > Install=[X]:\[AV]\Subordner ")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   Beispiel: KeysToChange=InstExec(2)")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#   - Ändert: InstExec=C:\Program Files\GameXYZ\bin\Prg.exe > Install=[X]:\[AV]\bin\Prg.exe ")				
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#  Clean")		
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#  Löscht die Importierten Keys die beim Programm Start importiert wurden nachdem beenden.")					
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#  Gilt nur für Local Maschine\software Pfad und Current User Pfad\Software.  ")
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "#")					
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# Is32Biton64")			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# Ändert beim Import den HKLM Pfad von Software\Firma\Game\ = Software\WoW6432Node\Firma\Game\ ")	
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "# Gilt nur für 32Bit Prgramme unter Windows 64Bit")						
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "")			
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "[GameTitle]")
			
			RegsConfigFile_Generate_Options()

		EndIf
		RegsConfigFile_Close()
	EndProcedure	
  ;
  ;
	Procedure.i RegsConfig_Create(Request.i = 0)
		
		Select FileSize( Startup::*LHGameDB\RegsTool\ConfigFile )
			Case -1					
				RegsConfigFile_Generate()
				If (Request = 1)
					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Eine Blanko Konfigurations Datei wurde Hinzugefügt",2,0,"",0,0,DC::#_Window_001)	
				EndIf				
				ProcedureReturn 
			Default
					
		EndSelect			
		
		If (Request = 1)
			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Konfigurations Datei Exisitiert bereits",2,0,"",0,0,DC::#_Window_001)	
		EndIf	

	EndProcedure
	;
	;	
	Procedure.i RegsConfig_AddGame()
		
		RegsConfig_Create()
		
		If Exists_GameTitle() = #True			
			ProcedureReturn 
		EndIf
		
		RegsConfigFile_Open(1)
		
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "")	
			WriteStringN(Startup::*LHGameDB\RegsTool\Configandle, "["+RegsConfig_GetGameTitle()+"]")

			RegsConfigFile_Generate_Options()
			
    	Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Der Titel: '"+RegsConfig_GetGameTitle()+"' wurde der Konfiguration Hinzugefügt",2,0,"",0,0,DC::#_Window_001)			
		RegsConfigFile_Close()	
	EndProcedure
	;
	; Return the Encoding Format for Windows9x and Windows NT
	; Windows9x benutze UTF8 während nachfolgende Generation Windows UCS-2 LE BOM benutzt	
	Procedure.i RegistryFile_CheckEncoding(szRegistryFile.s)
    
		hFile = ReadFile (#PB_Any , szRegistryFile)
		If Not hFile
			ProcedureReturn 0
		EndIf
				
		Select ReadStringFormat(hFile)
			Case #PB_Ascii  : CloseFile (hFile): ProcedureReturn #PB_Ascii  		;Kein BOM gefunden. Dies kennzeichnet üblicherweise eine normale Textdatei.
			Case #PB_UTF8   : CloseFile (hFile): ProcedureReturn #PB_UTF8			;UTF-8 BOM gefunden.
			Case #PB_Unicode: CloseFile (hFile): ProcedureReturn #PB_Unicode		;UTF-16 (Little Endian) BOM gefunden.
			Case #PB_UTF16BE: CloseFile (hFile): ProcedureReturn #PB_UTF16BE		;UTF-16 (Big Endian) BOM gefunden.
			Case #PB_UTF32  : CloseFile (hFile): ProcedureReturn #PB_UTF32			;UTF-32 (Little Endian) BOM gefunden.
			Case #PB_UTF32BE: CloseFile (hFile): ProcedureReturn #PB_UTF32BE		;UTF-32 (Big Endian) BOM gefunden.
		EndSelect 
		
		CloseFile (hFile)
		ProcedureReturn 0
	EndProcedure	
	;
	;
	; Liest den Windows Registry header.
	Procedure.s RegistryFile_GetWindowsHeader(szRegistryFile.s,EncondingHandle.i)				
		
		Protected hFile.l, szRegHead.s
		
		hFile 		= ReadFile (#PB_Any , szRegistryFile)
		;
		; Vermeide $FF$FF am Anfang der Registry Datei da es sich bei dier um eine UCS-2 LE BOM Datei handelt
		If ( EncondingHandle = #PB_Unicode )
				 FileSeek(hFile, 2) 
		EndIf
				
		szRegHead = ReadString(hFile, EncondingHandle)
		
		CloseFile( hFile )

		ProcedureReturn szRegHead

	EndProcedure
	;
	;
	;
	Procedure.s SetProfilingKey(szRegString.s)
		
			Shared StructRegistryFile()
		
			AddElement( StructRegistryFile() )
			StructRegistryFile()\Key 	= StringField(szRegString, 1, "=")
			StructRegistryFile()\Value= StringField(szRegString, 2, "=")					
	EndProcedure
	;
	;
	;"REG_SZ"=""
	Procedure.s GetREG_SZ(szRegString.s)
		
		;
		;
		; Suche nach Pfade ":" oder "\\"
		If ( FindString(szRegString, ":\\") )
			;
			; Laufwerk Gefunden								
			SetProfilingKey(szRegString.s)
			ProcedureReturn ""
		EndIf
		
		If ( FindString(szRegString, ".\\") )
			;
			; Relativ Pfade gefunden
			SetProfilingKey(szRegString.s)
			ProcedureReturn ""
			
		EndIf
		
		If ( FindString(szRegString, "\\") )
			;
			; Backslahs Pfade gefunden
			SetProfilingKey(szRegString.s)
			ProcedureReturn ""
			
		EndIf
		
		If ( FindString(szRegString, ":/") ) ; Auf Windows?... unüblich
			;
			; Backslahs Pfade gefunden
			SetProfilingKey(szRegString.s)
			ProcedureReturn ""
			
		EndIf
		
		If ( FindString(szRegString, "/") ) ; Auf Windows?... unüblich
			;
			; Backslahs Pfade gefunden
			SetProfilingKey(szRegString.s)
			ProcedureReturn ""
			
		EndIf		
		
		SetProfilingKey(szRegString.s)
		ProcedureReturn szRegString
					
	EndProcedure
	;
	;
	;"REG_DWORD"=dword:00000000
	Procedure.b GetREG_DWORD(szRegString.s)
		
		If ( FindString( szRegString, "dword:", #PB_String_CaseSensitive) )
			SetProfilingKey(szRegString.s)
			ProcedureReturn #True		
		EndIf
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;"REG_BINARY"=hex:12,34,56,78,90
	Procedure.b GetREG_BINANRY(szRegString.s)
		
		If ( FindString( szRegString, "hex:", #PB_String_CaseSensitive) )
			SetProfilingKey(szRegString.s)
			ProcedureReturn #True		
		EndIf
		ProcedureReturn #False
		
	EndProcedure	
	;
	;
	;"REG_QWORD"=hex(b):00,00,00,00,00,00,00,00
	Procedure.b GetREG_QWORD(szRegString.s)
		
		If ( FindString( szRegString, "hex(b):", #PB_String_CaseSensitive) )
			SetProfilingKey(szRegString.s)
			ProcedureReturn #True		
		EndIf
		
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;"REG_BINARY"=hex(7):12,34,56,78,90
	Procedure.b GetREG_MULTI_SZ(szRegString.s,szHandle.l, EncondingHandle.i)
		
		If ( FindString( szRegString, "hex(7):", #PB_String_CaseSensitive) )
			
			If ( Right(szRegString,1 ) = "\" )
				
				While Eof( szHandle ) = 0
					szRegString + Chr(13)	+ Chr(10) + ReadString(szHandle, EncondingHandle)
					
					If Not ( Right(szRegString,1 ) = "\" )
						Break
					EndIf
				Wend				
			EndIf			
						
			SetProfilingKey(szRegString.s)			
			ProcedureReturn #True		
		EndIf		
		
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;"REG_EXPAND_SZ"=hex(2):00,00
	Procedure.b GetREG_EXPAND_SZ(szRegString.s,szHandle.l, EncondingHandle.i)
		
		If ( FindString( szRegString, "hex(2):", #PB_String_CaseSensitive) )
			
			If ( Right(szRegString,1 ) = "\" )
				
				While Eof( szHandle ) = 0
					szRegString + Chr(13)	+ Chr(10) + ReadString(szHandle, EncondingHandle)
					
					If Not ( Right(szRegString,1 ) = "\" )
						Break
					EndIf
				Wend				
			EndIf	
			
			SetProfilingKey(szRegString.s)
			ProcedureReturn #True		
		EndIf		
		
		ProcedureReturn #False
		
	EndProcedure		
	;
	;
	; Holt alle Schlüssek aus der Registry Datei
	Procedure.s RegistryFile_GetHKKeys(szHandle.l, EncondingHandle.i)
		
		Protected szRegKeys.s
		
		Shared StructRegistryFile()
		
		;
		; Datei wird während der Schlüssel abgreifung nicht geschlossen
		While Eof( szHandle ) = 0			
				szRegKeys = ReadString(szHandle, EncondingHandle)			
				Debug szRegKeys
				;
				; Kein Anführungszeichen gefunden = fertig
				If Not (Left(szRegKeys,1) = Chr(34) )
					ProcedureReturn 
				EndIf				
				;
				; Entferne die Anführunsgzeichen
				szRegKeys = ReplaceString( szRegKeys, Chr(34), "", #PB_String_CaseSensitive, 1, 2)
				
				If ( GetREG_EXPAND_SZ(szRegKeys,szHandle, EncondingHandle) 	= #True )
					StructRegistryFile()\Type = #REG_EXPAND_SZ
					Continue
				EndIf
				If ( GetREG_MULTI_SZ(szRegKeys,szHandle, EncondingHandle) 	= #True )					
					StructRegistryFile()\Type = #REG_MULTI_SZ											
					Continue
				EndIf
				If ( GetREG_QWORD(szRegKeys) 			= #True )
					StructRegistryFile()\Type = #REG_QWORD					
					Continue
				EndIf
				If ( GetREG_BINANRY(szRegKeys) 		= #True )
					StructRegistryFile()\Type = #REG_BINARY			
					Continue
				EndIf
				If ( GetREG_DWORD(szRegKeys) 			= #True )
					StructRegistryFile()\Type = #REG_DWORD
					Continue
				EndIf
				
				GetREG_SZ(szRegKeys)
				StructRegistryFile()\Type = #REG_SZ
		Wend			
		
	EndProcedure
	;
	;
	Procedure.i RegistryFile_GetHKType(szKeyPath.s)
		Shared StructRegistryFile()
		
		If FindString( szKeyPath, "[HKEY_CLASSES_ROOT\")
			StructRegistryFile()\TopKey = #HKEY_CLASSES_ROOT
			ProcedureReturn #True
		EndIf
		
		If FindString( szKeyPath, "[HKEY_CURRENT_USER\")
			StructRegistryFile()\TopKey = #HKEY_CURRENT_USER
			ProcedureReturn #True
		EndIf
		
		If FindString( szKeyPath, "[HKEY_LOCAL_MACHINE\")
			StructRegistryFile()\TopKey = #HKEY_LOCAL_MACHINE
			ProcedureReturn #True
		EndIf
		
		If FindString( szKeyPath, "[HKEY_USERS\")
			StructRegistryFile()\TopKey = #HKEY_USERS
			ProcedureReturn #True
		EndIf
		
		If FindString( szKeyPath, "[HKEY_CURRENT_CONFIG\")
			StructRegistryFile()\TopKey = #HKEY_CURRENT_CONFIG
			ProcedureReturn #True
		EndIf
		
		;
		; Windows 9x.... 
		If FindString( szKeyPath, "[HKEY_DYN_DATA\")
			StructRegistryFile()\TopKey = #HKEY_DYN_DATA
			ProcedureReturn #True
		EndIf		
		
		If FindString( szKeyPath, "[HKEY_PERFORMANCE_DATA\")
			StructRegistryFile()\TopKey = #HKEY_PERFORMANCE_DATA
			ProcedureReturn #True
		EndIf
		
	EndProcedure
	;
	;
	; Holt alle Registry Pfade aus der *.reg datei
	Procedure.s RegistryFile_GetHKPath(szRegistryFile.s, EncondingHandle.i)
		
		Shared StructRegistryFile()
		
		Protected hFile.l, szRegPath.s
		
		hFile 		= ReadFile (#PB_Any , szRegistryFile)			
		While Eof( hFile ) = 0
			
			szRegPath = ReadString(hFile, EncondingHandle)
			If ( Left(szRegPath,1) = "[" And Right(szRegPath,1) = "]" )
				
			AddElement( StructRegistryFile() )
			StructRegistryFile()\Path 	= szRegPath
			RegistryFile_GetHKType(StructRegistryFile()\Path)
			
			
			RegistryFile_GetHKKeys(hFile, EncondingHandle)
			
			AddElement( StructRegistryFile() )
			StructRegistryFile()\Separator = #True
		
			EndIf
		Wend	
		
								
		CloseFile( hFile )
	EndProcedure
	;
	;
	Procedure.i RegsConfigFile_Read(FileNum.i = 0, szOwnRegistryFile.s = "")
		
		Shared StructRegistryFile()
		
		Protected  szFile.s, szTitle.s = RegsConfig_GetGameTitle(), szRegistryFile.s, EncondingHandle.i, szWindowsHeader.s, Result.i
		
		; TODO
		; Loop
		
		For IndexFolder = 1 To 5
			
			If ( Len(szOwnRegistryFile) > 0 )
				;
				; Befehl aus dem Menu und öffnet eine Registry Datei die nicht in der Einstellungsdatei verankert ist
				IndexFolder = 1
				szFile 			= GetFilePart( szOwnRegistryFile, #PB_FileSystem_NoExtension)
			Else
				If ( FileNum > 0 ) And ( FileNum < 6 )
					;
					; Befehl aus dem Menu eine Spezielle verankerte Registry Datei zu öffnen
					IndexFolder = FileNum
				EndIf
				
				If ( FileSize( Startup::*LHGameDB\RegsTool\ConfigFile ) > 0 )
					szFile = PB_GetPrivateProfileString(szTitle, "RegFile00"+Str(IndexFolder), "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), Startup::*LHGameDB\RegsTool\ConfigFile)
				Else
					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Die Konfigurations Datei "+Chr(34)+"vSystem-RegsSupport.ini"+Chr(34)+" nicht gefunden."+
					                                                                         #CR$+"Konfguration erstellen oder das argument %regssp entfernen."+
					                                                                         #CR$+#CR$+"Start abgebrochen..." ,2,2,"",0,0,DC::#_Window_001) 	
					ProcedureReturn #False
				EndIf
			EndIf	
			
			If Len( szFile ) > 0  		
				
				If Len(szOwnRegistryFile) > 0					
					szRegistryFile 	= szOwnRegistryFile
				Else
					szRegistryFile 	= Startup::*LHGameDB\RegsTool\ConfigPath +  szFile + ".REG"
				EndIf
				
				If Not ( FileSize( szRegistryFile ) = -1 )
					
					EncondingHandle = RegistryFile_CheckEncoding(szRegistryFile)
					
					szWindowsHeader = RegistryFile_GetWindowsHeader(szRegistryFile, EncondingHandle)
					
					If ( szWindowsHeader = "Windows Registry Editor Version 5.00"  Or szWindowsHeader = "REGEDIT4" )
						
						AddElement( StructRegistryFile() )
						StructRegistryFile()\File 	= szFile
						StructRegistryFile()\Header = szWindowsHeader
						
						AddElement( StructRegistryFile() )
						StructRegistryFile()\Separator = #True
					
						RegistryFile_GetHKPath(szRegistryFile.s, EncondingHandle)
						
						
					Else
						Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Keine Registry Datei",2,1,"",0,0,DC::#_Window_001) 								
					EndIf
					
				Else
					Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Registry Datei nicht gefunden: " + Chr(34) + szFile + ".reg. Dennoch fortfahren?" + Chr(34),11,2,"",0,0,DC::#_Window_001) 			
					If Result = 1		
						ProcedureReturn #False
					EndIf
				EndIf
				AddElement( StructRegistryFile() )
				StructRegistryFile()\EndofFile 	= #True				
			EndIf

			
			If ( Len(szOwnRegistryFile) > 0 ) Or ( FileNum > 0 )
				Break
			EndIf			
		Next
	
		ProcedureReturn #True
	EndProcedure
	;
	;
	Procedure.s RegsConfigFile_Read_EncondingOnly(FileNum.i = 0)
			
		Protected  szFile.s, szTitle.s = RegsConfig_GetGameTitle(), szRegistryFile.s, EncondingHandle.i, szEncodingsFiles.s
		
		szFile = PB_GetPrivateProfileString(szTitle, "RegFile00"+Str(FileNum), "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), Startup::*LHGameDB\RegsTool\ConfigFile)
		
		If Len( szFile ) > 0  		
			
			szRegistryFile 	= Startup::*LHGameDB\RegsTool\ConfigPath +  szFile + ".REG"
			
			If Not ( FileSize( szRegistryFile ) = -1 )
				
				EncondingHandle = RegistryFile_CheckEncoding(szRegistryFile)													
				Select EncondingHandle
					Case #PB_Unicode
						szEncodingsFiles +Chr(34) + szFile +Chr(34)+ " (Aktuell: 2K/XP+)"
					Default
						szEncodingsFiles +Chr(34) + szFile +Chr(34)+ " (Aktuell: 9x/NT4)"
				EndSelect
				
				ProcedureReturn szEncodingsFiles
				
			Else
				ProcedureReturn "Datei nicht gefunden: " + 	szFile	
			EndIf
			
		Else
			ProcedureReturn ""			
		EndIf

	ProcedureReturn ""
	EndProcedure	
	;
	;
	Procedure.s RegsConfigFile_GetRegistryFile(FileNum.i = 0)	
		
		Protected  szFile.s, szTitle.s = RegsConfig_GetGameTitle(), szRegistryFile.s, EncondingHandle.i, szEncodingsFiles.s
		
		szFile = PB_GetPrivateProfileString(szTitle, "RegFile00"+Str(FileNum), "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), Startup::*LHGameDB\RegsTool\ConfigFile)
		If Len( szFile ) > 0  
			szRegistryFile 	= Startup::*LHGameDB\RegsTool\ConfigPath +  szFile + ".REG"
			If ( FileSize( szRegistryFile ) = -1 )
				ProcedureReturn ""
			EndIf
			
		EndIf
		ProcedureReturn szRegistryFile
	EndProcedure
	;
	; Entferne Anführungs Zeichen
	Procedure.s Name_RemoveDoubleQuotePath(szPath.s)
		
		If ( Len( szPath ) > 0 )
			
			If ( Left( szPath, 1)  = Chr(34) )
				szPath = Right( szPath, Len(szPath)-1 )
			EndIf
			
			If ( Right( szPath, 1) = Chr(34) )
				szPath = Left( szPath, Len(szPath)-1 )
			EndIf			
		EndIf
		
		ProcedureReturn szPath
	EndProcedure
	;
	; Entferne Eckige Klammern vom Path
	Procedure.s Name_RemoveBracketsPath(szPath.s)
		
		If ( Len( szPath ) > 0 )
			
			If ( Left( szPath, 1)  = Chr(91) )
				szPath = Right( szPath, Len(szPath)-1 )
			EndIf
			
			If ( Right( szPath, 1) = Chr(93) )
				szPath = Left( szPath, Len(szPath)-1 )
			EndIf			
		EndIf
		
		ProcedureReturn szPath		
	EndProcedure	
	;
	;
	Procedure.s Name_RemoveBackSlash(szPath.s)	
		If Right( szPath, 1 ) = "\"
			szPath = Left(szPath, Len(szPath)-1)
		EndIf
		ProcedureReturn szPath
	EndProcedure
	;	
	;
	Procedure.i Name_CheckLastBackSlash(szPath.s)
		
		If Right( szPath ,1 ) = "\"
			ProcedureReturn #True
		EndIf		
		
		ProcedureReturn #False
	EndProcedure
	;
	;
	Procedure.s Name_AddChangeFolder(szKeyPath.s, szvSysPath.s, SubFolderCount.i, LastBackSlash.i)
				
		Protected SlashCount.i, SlashIndex.i, AddLastDiectorys.i
		
		szvSysPath 	= ReplaceString( szvSysPath, "\" , "\\")
		
		If ( SubFolderCount > 0 )
			;
			; Zähle die '\\' (Backslashs) aus dem Path in Registry. ** Merke die Anzahl durch die hälte zu teilen
			
			SlashCount.i 		= CountString(  szKeyPath, "\") /2
			
			AddLastDiectorys 	= ( SlashCount - SubFolderCount ) +2
			
			For SlashIndex = 1 To (SlashCount + 1)
				
				If ( SlashIndex >= AddLastDiectorys)
					
					szvSysPath + "\\"+ StringField( szKeyPath, SlashIndex, "\\")					
				EndIf
			Next									
		EndIf
		
		If ( LastBackSlash = #True )
			szvSysPath + "\"
		EndIf
		
		ProcedureReturn szvSysPath
	EndProcedure
	;
	;
	Procedure.s Name_ReplaceUserKeyNums(UserKey.s, Index.i)
	
	If ( Index > 0 )		
		ProcedureReturn ReplaceString( UserKey, "("+Str(Index)+")", "")
	EndIf
	ProcedureReturn UserKey
	
	EndProcedure
	;
	;
	Procedure.i Name_GetSubfolders(UserKey.s)
		
		Protected SubFolderIndex.i
		;
		; Unterordner Anzahl beachten
		For SubFolderIndex = 0 To 10
			If FindString( UserKey , "("+Str(SubFolderIndex)+")")				
				ProcedureReturn SubFolderIndex
				Break
			EndIf
		Next	
		
		ProcedureReturn 0			
	EndProcedure
	;
	;
	Procedure.i RegsConfigFile_Read_ChangeTargetArch()
		Protected Is32Biton64.b, szIs32Biton64.s, ChangedHKLM.s, szTitle.s = RegsConfig_GetGameTitle()
		
		Shared StructRegistryFile() 
		
		szIs32Biton64 = PB_GetPrivateProfileString( szTitle, "Is32Biton64", "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), Startup::*LHGameDB\RegsTool\ConfigFile)
		If UCase(szIs32Biton64) = "TRUE" Or UCase(szIs32Biton64) = "YES" Or UCase(szIs32Biton64) = "ON"
			Is32Biton64 = #True
		Else
			Is32Biton64 = #False
		EndIf
		
		If ( #PB_Processor_x86 ) Or ( Is32Biton64 = #False )
			;
			; Nicht auf x86 Prozessoren
			Is32Biton64 = #False
			ProcedureReturn Is32Biton64
		EndIf
		
		If ( ListSize( StructRegistryFile() ) -1 > -1 )
				ResetList( StructRegistryFile() )	
		Else
				ProcedureReturn #False
		EndIf	
			
		While NextElement( StructRegistryFile() )
			
			If ( Len( StructRegistryFile() \Path ) > 0 ) And ( StructRegistryFile() \TopKey = #HKEY_LOCAL_MACHINE )
				
				;
				;
				; HKEY_LOCAL_MACHINE\SOFTWARE\Programm\ to HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Programm\
				ChangedHKLM =  StructRegistryFile() \Path
				If FindString(ChangedHKLM, "[HKEY_LOCAL_MACHINE\SOFTWARE\" )
					
					If FindString( ChangedHKLM, "[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\" )
						Continue
					EndIf
					
					ChangedHKLM = ReplaceString( ChangedHKLM, "HKEY_LOCAL_MACHINE\SOFTWARE\", "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\" )
 					StructRegistryFile() \Path = ChangedHKLM
				EndIf					
			EndIf	
		Wend
		
		ProcedureReturn #True
		
	EndProcedure
	;
	;
	Procedure.s RegsConfigFile_Read_ChangeRemoveWOW(szPath.s)
		Protected ChangedHKLM.s
		
		If FindString(szPath, "[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\" )									
			;
			;
			; HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Programm\ to HKEY_LOCAL_MACHINE\SOFTWARE\Programm\
			ChangedHKLM =  szPath			
			ChangedHKLM = ReplaceString( ChangedHKLM, "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\", "HKEY_LOCAL_MACHINE\SOFTWARE\" )			
			ProcedureReturn ChangedHKLM					
		EndIf
		
		ProcedureReturn szPath
				
	EndProcedure
	;
	;
	Procedure.i RegsConfigFile_Read_Options(vSysPath.s = "")		
		
		Shared StructRegistryFile()
		
		Protected ChangeKeys.s, szTitle.s = RegsConfig_GetGameTitle(),DelimterCount.i, DelimeterIndex.i, UserKey.s, SubFolderCount.i, LastBackSlash.i = #False, PathChanged.s, ValuePath.s
		
		ChangeKeys = PB_GetPrivateProfileString( szTitle, "KeysToChange", "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), Startup::*LHGameDB\RegsTool\ConfigFile)
		If Len( ChangeKeys ) > 0
			
			If ( ListSize( StructRegistryFile() ) -1 > -1 )
				ResetList( StructRegistryFile() )	
			Else
				ProcedureReturn #False
			EndIf
			
			DelimterCount = CountString( ChangeKeys, ";")
			;If ( DelimterCount > 0 )
				
				;
				; Trennzeichen Filtern
				For DelimeterIndex = 1 To DelimterCount+1
					
					UserKey = StringField( ChangeKeys, DelimeterIndex, ";")
					
					;
					; Unterordner Anzahl beachten
					SubFolderCount 	= Name_GetSubfolders(UserKey)
					UserKey 				= Name_ReplaceUserKeyNums(UserKey, SubFolderCount)
					
					ResetList( StructRegistryFile() )	
					
					While NextElement( StructRegistryFile() )
						
						If ( Len( StructRegistryFile() \Key ) > 0 )
							
							If UCase( UserKey) = UCase( StructRegistryFile() \Key )
								;
								; key gefunden									
								If ( Len( StructRegistryFile() \value ) > 0)
									
									
									;
									; Entferne Anführungs Zeichen
									ValuePath 		= Name_RemoveDoubleQuotePath(StructRegistryFile() \Value)
									If (ValuePath ) = ".\\"
										;
										; Diese Pfade müssen nicht geändert werden. Nur importiert
										Break
									EndIf
									
									LastBackSlash	= Name_CheckLastBackSlash(ValuePath)
									
									PathChanged 	= Name_AddChangeFolder(ValuePath, vSysPath, SubFolderCount, LastBackSlash)																				
									PathChanged 	= Chr(34) + PathChanged + Chr(34)
									
									If UCase( PathChanged ) =  UCase( StructRegistryFile() \Value )
										Break
									Else
										
										Debug #CR$ + "Changed"
										Debug "Key      :" + UserKey
										Debug "Voher    :" + StructRegistryFile() \value
										Debug "Nachher  :" + PathChanged
										StructRegistryFile() \Value  = 	PathChanged
										Break
									EndIf
								EndIf
							EndIf								
						EndIf							
					Wend						
					
				Next				
			;EndIf												
		EndIf	
		
		ProcedureReturn #True
		
	EndProcedure
	;
	;
	Procedure.s RegsConfigFile_Import_GetPath(szPath.s,szReplace.s)
		
		szPath = Name_RemoveBracketsPath(szPath)
		szPath = ReplaceString( szPath, szReplace, "")
		ProcedureReturn szPath
		
	EndProcedure
	;
	;	
	Procedure.s RegsConfigFile_Import_SelectPath(szPath.s)
		
		;
		; Die Eckigen Klammern weren vorher im code RegsConfigFile_Import_GetPath() entfernt
		; bevor der HKPath entfertn wird
		
		Shared  StructRegistryFile()
		
		Select StructRegistryFile() \TopKey
			Case #HKEY_CLASSES_ROOT
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_CLASSES_ROOT\")
				
			Case #HKEY_CURRENT_USER
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_CURRENT_USER\")
				
			Case #HKEY_LOCAL_MACHINE
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_LOCAL_MACHINE\")
				
			Case #HKEY_USERS
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_USERS\")
				
			Case #HKEY_CURRENT_CONFIG
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_CURRENT_CONFIG\")				
				
			Case #HKEY_DYN_DATA
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_DYN_DATA\")
				
			Case #HKEY_PERFORMANCE_DATA
				ProcedureReturn RegsConfigFile_Import_GetPath(szPath,"HKEY_PERFORMANCE_DATA\")			
				
			Default
				ProcedureReturn ""
		EndSelect		
				
		ProcedureReturn 
		
	EndProcedure
	;
	;
	Procedure.s RegsConfigFile_Import_ConvertHex(szString.s, InCalc.i = 4 )
		
		Protected Lenght.i, HexValue.s, Index.i, Temp.s, Decimal.l
		
      HexValue	=	UCase(szString)
     
      For Index = 1 To Len(HexValue)
      	Decimal << InCalc
      	
        Temp = Mid(HexValue,Index,1)
        
        If Asc(Temp) > 60
          Decimal + Asc(Temp) - 55
        Else
          Decimal + Asc(Temp)-48
        EndIf
      Next
           
		ProcedureReturn Str(Decimal)
	EndProcedure  	
	;
	;
	Procedure.s RegsConfigFile_Import_MultiGetHex(szString.s)
		
		Protected Index.i, szConvertet.s, szNewString.s, value.b, szWorking.s, szChar.s
		
		szWorking = ReplaceString( szString, ",00", "")
		szWorking = ReplaceString( szWorking, ",\", "")
		szWorking = ReplaceString( szWorking, Chr(13) + Chr(10), ",")
		szWorking = ReplaceString( szWorking, Chr(32) + Chr(32), "")
		Debug szWorking
		
		DelimterCount = CountString( szWorking, ",")
		For DelimeterIndex = 1 To DelimterCount+1
			
			szChar = StringField( szWorking, DelimeterIndex, ",")
			szConvertet = RegsConfigFile_Import_ConvertHex(szChar)
			ValueByte.b = Val( szConvertet )
			szNewString + Chr(ValueByte)			
		Next	

		Debug szNewString
		ProcedureReturn szNewString
  EndProcedure
	;
	; Import #REG_BINARY
  Procedure.l RegsConfigFile_Import_Binary(szValue.s)
  	
  	Protected *BinValue, szChar.s, szConvertet.s, DelimterCount.i, DelimeterIndex.i
  	;
  	; Same max how Reg_Binary bytes...
  	*BinValue = AllocateMemory(2096)
	  	If ( *BinValue )
	  	;
	  	; +1 take the last signs after the delimeter
	  	DelimterCount = CountString( szValue, ",") +1
	  	
	  	UseModule Registry		
	  	
	  		RegValue.RegValue								
		  	RegValue\TYPE = #REG_BINARY
		  	RegValue\SIZE = DelimterCount
		  	RegValue\BINARY = AllocateMemory(RegValue\SIZE)
		  	
		  	For DelimeterIndex = 1 To DelimterCount
		  		
		  		szChar 			=	StringField( szValue, DelimeterIndex, ",")
		  		szConvertet = RegsConfigFile_Import_ConvertHex(szChar)
		  		ValueByte.b = Val( szConvertet )
		  				  		
		  		PokeB(RegValue\BINARY + (DelimeterIndex-1),ValueByte)
		  		
		  	Next
		  	CopyStructure(RegValue,*BinValue,RegValue)
		  	
	  	UnuseModule Registry
	  	ProcedureReturn *BinValue
	  EndIf
	  
	  Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Konnte 2096 Bytes nicht Zuweisen",2,1,"",0,0,DC::#_Window_001)  
	  
  	ProcedureReturn 0 
  EndProcedure
	;
  ;
	Procedure.s RegsConfigFile_Import_DwordGetHex(szString.s)		           
		ProcedureReturn RegsConfigFile_Import_ConvertHex(szString)
	EndProcedure  	
	;
	;
	Procedure.s RegsConfigFile_Import_QwordSet(szString.s)
		Protected szChar.s, szConvertet.s, DelimterCount.i, DelimeterIndex.i, szNewString.s
		
		DelimterCount = CountString( szString, ",") +1
		For DelimeterIndex = DelimterCount To 1 Step -1
			
			szChar 			=	StringField( szString, DelimeterIndex, ",")			
			ValueByte.b = Val( szChar )
			szNewString + Str(ValueByte)
			szConvertet = RegsConfigFile_Import_ConvertHex(szNewString)			
		Next
		
		ProcedureReturn szConvertet
	EndProcedure
	;
	;
	Procedure.s RegsConfigFile_Import_SelectType(szKey.s, szValue.s)
		
		;
		; Die Eckigen Klammern weren vorher im code RegsConfigFile_Import_GetPath() entfernt
		; bevor der HKPath entfertn wird
		
		Shared  StructRegistryFile()
		
		Select StructRegistryFile() \Type
			Case #REG_EXPAND_SZ
				szValue = ReplaceString(szValue, "hex(2)","")
				ProcedureReturn RegsConfigFile_Import_MultiGetHex(szValue)
								
			Case #REG_QWORD
				szValue = ReplaceString(szValue, "hex(b):","")
				szValue = RegsConfigFile_Import_QwordSet(szValue)
				ProcedureReturn szValue
				
			Case #REG_MULTI_SZ
				szValue = ReplaceString(szValue, "hex(7):","")	
				ProcedureReturn RegsConfigFile_Import_MultiGetHex(szValue)		
				
			Case #REG_BINARY	
				ProcedureReturn ReplaceString(szValue, "hex:","")				
				
			Case #REG_DWORD				
				szValue = ReplaceString(szValue, "dword:","")
				ProcedureReturn RegsConfigFile_Import_DwordGetHex(szValue)
				
			Case #REG_SZ	
				szValue = Name_RemoveDoubleQuotePath(szValue)	
				ProcedureReturn ReplaceString(szValue, "\\","\")
				
			Default
				ProcedureReturn ""
		EndSelect		
				
		ProcedureReturn ""
		
	EndProcedure	 
	;
	;  
	Procedure.i RegsConfigFile_Import()
		
		Shared  StructRegistryFile()
		
		Protected HKTopKey.i, HKSubPath.s, KeyName.s, ValueName.s, *RegValue
		
		
		If ( ListSize( StructRegistryFile() ) -1 > -1 )
			ResetList( StructRegistryFile() )	
		Else
			ProcedureReturn #False
		EndIf		
		
		ResetList( StructRegistryFile() )	
		
		While NextElement( StructRegistryFile() )			
			
			
			If StructRegistryFile() \Separator = 1
				Continue
			EndIf
			If ( Len( ( StructRegistryFile() \Path )) > 0) And (StructRegistryFile() \TopKey > 0)
				
				If ( StructRegistryFile() \TopKey = #HKEY_PERFORMANCE_DATA )
					;
					; Dont Import Old Windows NT 
					Continue
				EndIf
				
				If ( StructRegistryFile() \TopKey = #HKEY_DYN_DATA )
					;
					; Dont Import Old Windows NT 
					Continue
				EndIf
				
				HKTopKey 	= StructRegistryFile() \TopKey
				HKSubPath = RegsConfigFile_Import_SelectPath(StructRegistryFile() \Path )
				
			ElseIf	( Len( ( StructRegistryFile() \Key )) > 0) And ( StructRegistryFile() \Type > 0)
				
				;While NextElement( StructRegistryFile() )
					
					
					KeyName 	= StructRegistryFile() \Key
					ValueName = StructRegistryFile() \Value								
					ValueName = RegsConfigFile_Import_SelectType(KeyName, ValueName)
					
					If ( StructRegistryFile() \Type = #REG_BINARY)			
						*RegValue = RegsConfigFile_Import_Binary(ValueName)	
						If ( *RegValue > 0 )
							Registry::WriteValue(HKTopKey, HKSubPath, KeyName, ValueName, StructRegistryFile() \Type, #False, *RegValue)
							FreeMemory( *RegValue )
						EndIf
					Else									
						Registry::WriteValue(HKTopKey, HKSubPath, KeyName, ValueName, StructRegistryFile() \Type, #False )
					EndIf
				;Wend
			EndIf	
			
			If  StructRegistryFile()\EndofFile = #True
				HKTopKey 	= 0
				HKSubPath = ""
				KeyName   = ""
				ValueName = ""					
				Continue
			EndIf					
		Wend
			
		ProcedureReturn #True
	EndProcedure
	;
	;
	Procedure.i RegistryFile_OpenDialogAndRead()	
		
		Protected  szFile.s,  szRegistryFile.s, EncondingHandle.i, szWindowsHeader.s
		
		Shared StructRegistryFile()
		;
		; TODO
		; File Requester
		
		If Len( szFile ) > 0  		
			
			szRegistryFile 	= Startup::*LHGameDB\RegsTool\ConfigPath + "\" + szFile + ".REG"
			
			If Not ( FileSize( szRegistryFile ) = -1 )
				
				EncondingHandle = RegistryFile_CheckEncoding(szRegistryFile)
				
				szWindowsHeader = RegistryFile_GetWindowsHeader(szRegistryFile, EncondingHandle)
				
				If ( szWindowsHeader = "Windows Registry Editor Version 5.00"  Or szWindowsHeader = "REGEDIT4" )
					
					AddElement( StructRegistryFile() )
					StructRegistryFile()\File 	= szFile
					StructRegistryFile()\Header = szWindowsHeader
					
					AddElement( StructRegistryFile() )
					StructRegistryFile()\Separator = #True
					
					RegistryFile_GetHKPath(szRegistryFile.s, EncondingHandle)
					
					
				Else
					Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Keine Registry Datei",2,2,"",0,0,DC::#_Window_001)  		
				EndIf
				
			Else
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Registry Datei nicht gefunden: " + Chr(34) + szFile + ".reg" + Chr(34),2,2,"",0,0,DC::#_Window_001) 			
			EndIf
		EndIf
		AddElement( StructRegistryFile() )
		StructRegistryFile()\EndofFile 	= #True
			
		
		
	EndProcedure
	;
	; Schreibe die Registry Datei
	Procedure.i	RegistryFile_Create(szFile.s)
		
		If ( FileSize( Startup::*LHGameDB\RegsTool\ConfigPath + "\" + szFile + "_Original.reg" ) = -1 )
			RenameFile( Startup::*LHGameDB\RegsTool\ConfigPath + "\" + szFile + ".reg", 
			            Startup::*LHGameDB\RegsTool\ConfigPath + "\" + szFile + "_Original.reg")
		EndIf
		
		ProcedureReturn CreateFile( #PB_Any,  Startup::*LHGameDB\RegsTool\ConfigPath + "\" + szFile + ".reg" )
	EndProcedure
	;
	;
	Procedure.i	RegistryFile_Write_Header(szHead.s, Encoding.i, FileHandle.i)
		
		Select Encoding
			Case #PB_Unicode:
				;
				; USC-2 LE BOM oder UTF6LE. Die ersten 2 Bytes schreiben danach als Unicode
				WriteByte(FileHandle, 255)
				WriteByte(FileHandle, 254)				
				For CharsIndex.i = 1 To Len( szHead )
					char.c = Asc( Mid(szHead,CharsIndex,1) )
					WriteCharacter(FileHandle, char,	Encoding)
				Next
				WriteCharacter(FileHandle, 13 ,Encoding)
				WriteCharacter(FileHandle, 10 ,Encoding)							
				ProcedureReturn Encoding
				
			Default																										
				;
				; Standard UTF8 (Windows9x)
				WriteStringN(FileHandle, szHead, Encoding)
				ProcedureReturn Encoding
		EndSelect
										
	EndProcedure
	;
	; Holt Header und gib als Return das Encoding aus
	Procedure.i	RegistryFile_Encode_Header(szHead.s, Convert.b = #False)
		Protected Encoding.i
		
		Shared StructRegistryFile()
		
		If ( szHead = "REGEDIT4")
			Encoding =  #PB_UTF8
			
			If ( Convert = #True )
				StructRegistryFile() \Header = "Windows Registry Editor Version 5.00"
				ProcedureReturn #PB_Unicode
			EndIf	
			
		EndIf
				
		If ( szHead = "Windows Registry Editor Version 5.00")							 
			Encoding = #PB_Unicode
			
			If ( Convert = #True )
				StructRegistryFile() \Header = "REGEDIT4"
				ProcedureReturn #PB_UTF8
			EndIf				
			
		EndIf

		ProcedureReturn Encoding
	EndProcedure
	;
	; Schreibe die Registry
	Procedure.i	RegistryFile_Write(Convert.b = #False)
		Protected hFile.i, hEncode.i = #PB_UTF8
		
		Shared StructRegistryFile()
		
		If ( ListSize( StructRegistryFile() ) -1 > -1 )
			ResetList( StructRegistryFile() )
			
			While NextElement( StructRegistryFile() )
				
				If ( Len( StructRegistryFile() \Header) > 0 )
					hEncode = RegistryFile_Encode_Header(StructRegistryFile() \Header,Convert)
					If ( hEncode = 0 )						
						ProcedureReturn #False
					EndIf
				EndIf  
					
				If ( Len( StructRegistryFile() \File ) > 0 )
					hFile = RegistryFile_Create( StructRegistryFile() \File )
					If ( hFile > 0 )
						hEncode = RegistryFile_Write_Header(StructRegistryFile() \Header, hEncode.i, hFile)						
					Else
						ProcedureReturn #False
					EndIf	
				EndIf
				
				If ( hFile > 0 )

					If ( Len( StructRegistryFile() \Path ) > 0 )
						;
						; Encode #PB_UTF8 Remove WOW6432Node
						If ( StructRegistryFile() \TopKey = #HKEY_LOCAL_MACHINE ) And ( hEncode = #PB_UTF8 )
							StructRegistryFile() \Path = RegsConfigFile_Read_ChangeRemoveWOW(StructRegistryFile() \Path)							
						EndIf
						
						WriteStringN(hFile, StructRegistryFile() \Path, hEncode)	
					EndIf  		 	
					
					If ( Len( StructRegistryFile() \Key ) > 0 )
						WriteStringN(hFile, Chr(34) + StructRegistryFile() \Key +Chr(34)+ "=" + StructRegistryFile() \Value , hEncode)						 		
					EndIf    		 	
					
					If ( StructRegistryFile() \Separator = #True ) 
						WriteStringN(hFile, "" , hEncode)						
					EndIf
					
					If ( StructRegistryFile() \EndofFile = #True )
						CloseFile(hFile)
						hFile = 0
					EndIf
				EndIf
			Wend
		EndIf
		
		ProcedureReturn #True
	EndProcedure
	;
	;
	Procedure.i	Registry_Clean()		
		
		Protected Result.i, szTopKeyPath.s, szKeyToDelete.s, szkeyPathParth.s, szSubFolder.s, Index.i
		Protected szHKEYFound.s ="" , Nextkey.i = #False
		Shared StructRegistryFile(), SafeTopKeys()
  	
  	;Path = Name_RemoveBackSlash(Path)	
		Result = RegsConfigFile_Read()   	
  	If ( Result = #False )
  		ProcedureReturn #False
  	EndIf
  	
  	Result = RegsConfigFile_Read_ChangeTargetArch()  	
  	If ( Result = #False )
  		ProcedureReturn #False
  	EndIf
  	
  	ResetList( StructRegistryFile() )
  	
  	While NextElement(  StructRegistryFile() )
  		
			If StructRegistryFile()\Separator = #True			
					Continue
				EndIf   				

									
  		If ( StructRegistryFile()\TopKey = #HKEY_LOCAL_MACHINE ) Or ( StructRegistryFile()\TopKey = #HKEY_CURRENT_USER )  			
  			
  			Collect_SafeTopKeys()
  			ResetList( SafeTopKeys() )
  			
  			
  			While NextElement( SafeTopKeys()  )
  				

					
  				If ( SafeTopKeys()\TopKey = StructRegistryFile()\TopKey )
  					
  					
  					szTopKeyPath = StructRegistryFile()\Path
  					
  					szTopKeyPath = Trim(szTopKeyPath, "[")
  					szTopKeyPath = Trim(szTopKeyPath, "]")
  					
  					
  					If FindString( UCase(szTopKeyPath) , UCase(SafeTopKeys()\TopKeyPath), 0)
  						
  						
  						szKeyToDelete = ReplaceString( szTopKeyPath , SafeTopKeys()\TopKeyPath ,"",#PB_String_NoCase )
  						szKeyToDelete = ReplaceString( szKeyToDelete, SafeTopKeys()\SubKeyPath ,"",#PB_String_NoCase )
  						szkeyPathParth= SafeTopKeys()\TopKeyPath
  						
  						CountSlash = CountString( szKeyToDelete, "\")
							;
							; Trennzeichen Backslash Filtern 							  						
  						Result = Registry::DeleteTree(StructRegistryFile()\TopKey, SafeTopKeys()\SubKeyPath + szKeyToDelete)  						
  						If ( Result = #False )
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Konnte nicht entfernt werden: " + 
  							                                                                         SafeTopKeys()\SubKeyPath + szKeyToDelete,2,1,"",0,0,DC::#_Window_001)  
  						EndIf
  						
  						Result = Registry::DeleteKey(StructRegistryFile()\TopKey, SafeTopKeys()\SubKeyPath + szKeyToDelete)
  						If ( Result = #False )
  							Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Konnte nicht entfernt werden: " +
  							                                                                         SafeTopKeys()\SubKeyPath + szKeyToDelete,2,1,"",0,0,DC::#_Window_001)  
  						EndIf  						
  						
  						If ( CountSlash > 0 )
  							For Index = 1  To CountSlash
  								
  								szSubFolder 	= StringField( szKeyToDelete, index, "\")  								  				  								
  								szKeyToDelete = ReplaceString(szKeyToDelete, szSubFolder + "\", "", #PB_String_NoCase)
  								
  								Result = Registry::DeleteKey(StructRegistryFile()\TopKey, SafeTopKeys()\SubKeyPath + szSubFolder)
  								If ( Result = #False )
  									Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Konnte nicht entfernt werden: " +
  									                                                                         SafeTopKeys()\SubKeyPath + szKeyToDelete,2,1,"",0,0,DC::#_Window_001)  
  								EndIf  	  								
  								
  								If ( FindString( szKeyToDelete , "\", 0) = 0 )  									
  									Break
  								EndIf  								
  							Next
  						EndIf 						
  						While NextElement(  StructRegistryFile() )
  							If StructRegistryFile()\EndofFile = #True	
  								Nextkey = #True
  								Break  								
  							EndIf
  						Wend
  					Else
  						szHKEYFound = SafeTopKeys()\TopKeyPath
  					EndIf	
  				EndIf
  				If ( Nextkey = #True )
  					Nextkey = #False
  					Break
  				EndIf
  			Wend
  		EndIf	
  	Wend
  	
  	ClearList( SafeTopKeys() )
  	
  	If ( Len( szHKEYFound ) > 0 )
  		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Wurde nicht gelöscht: " + szHKEYFound,2,1,"",0,0,DC::#_Window_001)  		
  	EndIf
  	
  	ProcedureReturn #True
  EndProcedure		
	;
	;
  Procedure.i	Registry_Cleaner()
  	Protected szClean.s, szTitle.s = RegsConfig_GetGameTitle()
  	szClean = PB_GetPrivateProfileString( szTitle, "Clean", "",  Space( #MAX_PATH ), Len( Space( #MAX_PATH ) ), Startup::*LHGameDB\RegsTool\ConfigFile)
  	If UCase(szClean) = "TRUE" Or UCase(szClean) = "YES" Or UCase(szClean) = "ON"
  		Registry_Clean()
  	EndIf  	  		  				
  EndProcedure
  ; TODO
	; Init wird nicht mehr gebraucht
  Procedure.i	Init()	  

		;Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Registry Path Löschen? : " + Chr(34) + SafeTopKeys()\TopKeyPath + szKeyToDelete+ Chr(34) ,11,2,"",0,0,DC::#_Window_001) 			
		;If Result = 1		
		;	ProcedureReturn #False
		;EndIf  	
		
	;	Debug szKeyToDelete
		;Registry::DeleteKey(#HKEY_LOCAL_MACHINE,szKeyToDelete)
		;Registry::DeleteKey(#HKEY_LOCAL_MACHINE, "SOFTWARE\Wow6432Node\elf\dragonknight4")
		
	;	Registry::DeleteKey(#HKEY_LOCAL_MACHINE, "Software\Wow6432Node\ELF")
		
		;
		; Menu 
		; Open Registry in File Requester
		; Convert Registry
		; 
		
;   	Collect_PathKeys()
;   	
;   	RegsConfig_Create(1) ; System Settings Datei anlegen
;   	
;   	RegsConfigFile_Read() ; Read Registry File von der Settings Datei
;   	RegsConfigFile_Read_ChangeTargetArch(); Change  HKLM\SOFTWARE\
;   	RegsConfigFile_Read_Options()
;   	
;   	RegsConfigFile_Import() ; Importiert den Key benötigt die Befehler Darüber
;   	
;   	;RegistryFile_OpenDialogAndRead()	; Öffnet eine Registry via filepath Requester
;   	
;   	RegistryFile_Write()
; 
;   	ClearListings()
  	
  EndProcedure
  ;
  ; Öffnen und Editieren der vSystem Konfigurations Datei
	Procedure   RegsConfig_Edit(Option.i = 0)
		
		Select FileSize( Startup::*LHGameDB\RegsTool\ConfigFile )
			Case -1		
				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Konfigurations Datei Exisitert nicht",2,2,"",0,0,DC::#_Window_001)
				ProcedureReturn 
		EndSelect	
		
		Select Option
			Case 0
				FFH::ShellExec(Startup::*LHGameDB\RegsTool\ConfigFile, "open") 
				ProcedureReturn 
			Case 1				 
        FFH::SHOpenWithDialog_(Startup::*LHGameDB\RegsTool\ConfigFile, 4)		
		 EndSelect
	EndProcedure	  
  ;
	;
  Procedure.s RegsConfig_MenuFileExists()
  	
  	Protected Result.i
  	
  	If FileSize( Startup::*LHGameDB\RegsTool\ConfigFile ) = -1
  		ProcedureReturn "Status: Keine Konfiguration"
  	EndIf
  			  	
  	Result = GameTitle_Compare()
  	If (Result = #True)
  		ProcedureReturn "Status: OK"
  	Else
  		ProcedureReturn "Status: Falscher Spieletitel"
  	EndIf
  	
  	ProcedureReturn ""
  EndProcedure  
	;
	; TODO
  Procedure.i Init_vEngineImport(Path.s = "", FileNum.i = 0)
  	Protected Result.i
  	
  	
  	Path = Name_RemoveBackSlash(Path)
  	  	
  	Result = RegsConfigFile_Read(FileNum)   	  	
  	If ( Result = #False )
  		ProcedureReturn #False
  	EndIf
  	
  	Result = RegsConfigFile_Read_ChangeTargetArch()  	
  	If ( Result = #False )
  		ProcedureReturn #False
  	EndIf
  	
  	Result = RegsConfigFile_Read_Options(Path)
  	If ( Result = #False )
  		ProcedureReturn #False
  	EndIf
  	
  	Result = RegsConfigFile_Import()
  	If ( Result = #False )
  		ProcedureReturn #False
  	EndIf
  	
  	ClearListings()
  	ProcedureReturn #True
  EndProcedure
	;
	; vSystem Konfigurations Datei anlegen
  Procedure.i Menu_CreatConfig()
  	RegsConfig_Create(1) ; System Settings Datei anlegen
  EndProcedure
	;
	; vSystem Konfigurations Datei neues Piel hinzufügen
  Procedure.i Menu_AddGame()
  	RegsConfig_AddGame() ; System Settings Datei anlegen
  EndProcedure  
	;
	;
  Procedure.i Menu_Import(FileNum.i = 0)
  	Protected szRegistryFile.s, szPath.s, Result.i
  	 		
  		szPath = PathRequester("Ziel Verzeichnis wählen wo sich das Programm befindet", Startup::*LHGameDB\Base_Path)
  		If ( szPath = "" )
  			ProcedureReturn #False
  		EndIf
  		
  		
  		Result = Init_vEngineImport(szPath, FileNum)
  		If Result = #True
  			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Datei importiert",2,0,"",0,0,DC::#_Window_001)
  		Else
  			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Datei nicht importiert",2,2,"",0,0,DC::#_Window_001)
  		EndIf
  		
  		ProcedureReturn #True
  EndProcedure
  ;
	;
  Procedure.i Menu_OpenAndEdit(FileNum.i = 0,szPath.s = "")
  	
  	Protected Result.i
  	
  	If FileNum > 5
  		szPath = FFH::GetFilePBRQ("Registry Datei Öffnen",Startup::*LHGameDB\RegsTool\ConfigPath + "\" , #False, "Registry Dateien (*.reg)|*.reg|Alle Dateien (*.*)|*.*;", 0, #False)
  		If ( szPath = "" )
  			ProcedureReturn #False
  		EndIf
  	Else  		  	
  		szPath = RegsConfigFile_GetRegistryFile(FileNum)	
  	EndIf
  	
  	Select FileSize( szPath )
  		Case -1		
  			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Datei "+Chr(34)+ szPath +".reg "+Chr(34)+" nicht gefunden",2,2,"",0,0,DC::#_Window_001)
  			ProcedureReturn #False
  	EndSelect	
  	
  	Request::*MsgEx\User_BtnTextL = "Editieren"
  	Request::*MsgEx\User_BtnTextM = "Öffne Mit.."
  	Request::*MsgEx\User_BtnTextR = "Abbruch"		
  	Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Datei  "+ GetPathPart( szPath ) +" Öffnen und Editieren?",16,0,"",0,0,DC::#_Window_001)
  	Select Result
  		Case 0
  			FFH::ShellExec(szPath, "edit") 
  			ProcedureReturn #True
  		Case 2				 
  			FFH::SHOpenWithDialog_(szPath, 4)		
  		Default
  			ProcedureReturn #True
  	EndSelect
  	
  EndProcedure
  ;
	;
  Procedure Menu_OpenAndConvert(FileNum.i = 0,szPath.s = "")
  	
  	Protected Result.i, EncodingHandle.i, szError.s, CodingDesc.s
  	
  	If FileNum > 5
  		szPath = FFH::GetFilePBRQ("Registry Datei Öffnen",Startup::*LHGameDB\RegsTool\ConfigPath + "\" , #False, "Registry Dateien (*.reg)|*.reg|Alle Dateien (*.*)|*.*;", 0, #False)
  		If ( szPath = "" )
  			ProcedureReturn #False
  		EndIf
  		
  	Else    	
  		szPath = RegsConfigFile_GetRegistryFile(FileNum)
  	EndIf
  	
  	Select FileSize( szPath )
  		Case -1		
  			Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Datei "+Chr(34)+ szPath +".reg "+Chr(34)+" nicht gefunden",2,2,"",0,0,DC::#_Window_001)
  			ProcedureReturn #False
  	EndSelect	
  	
  	EncodingHandle = RegistryFile_CheckEncoding(szPath)
  	If ( EncodingHandle = #PB_Unicode )
  		CodingDesc = "Unicode (Windows 2000 und neuer)"
  	ElseIf ( EncodingHandle = #PB_UTF8 ) Or ( EncodingHandle = #PB_Ascii ) 
  		CodingDesc = "UTF8/Ascii (Windows NT4, 95 oder 98)"
  	Else
  		CodingDesc = "Unbekannt: Code nr. " + Str(EncodingHandle)
  	EndIf
  	
  	Request::*MsgEx\User_BtnTextL = "Konvertiren"
  	Request::*MsgEx\User_BtnTextR = "Abbruch"		
  	Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support",Chr(34)+ GetFilePart( szPath ) +Chr(34)+"'s Kodierung Konvertieren?"+
  	                                                                              #CR$+
  	                                                                              "Aktuell: " + CodingDesc ,10,0,"",0,0,DC::#_Window_001)
  	Select Result
  		Case 0
  			RegsConfigFile_Read(FileNum, szPath)
  			
  			Result = RegistryFile_Write(#True)
  			If ( Result = #False )
  				szError = GetLastError()
  				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Fehler beim Konvertieren:" + szError,2,2,"",0,0,DC::#_Window_001)
  			Else 
  				
  				Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Registry Support","Datei "+Chr(34)+ GetFilePart( szPath ) +Chr(34)+" Konvertiert.",2,0,"",0,0,DC::#_Window_001)
  				Debug "Menu_OpenAndConvert: " + GetLastError()
  			EndIf  			
  			ClearListings()
  		Default
  			ProcedureReturn #False
  	EndSelect		
  EndProcedure	

EndModule

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 865
; FirstLine = 321
; Folding = HZACAwAAAgIp-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\NewGame\