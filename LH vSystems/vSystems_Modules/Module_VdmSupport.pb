DeclareModule VirtualDriveSupport
	
	Declare.i 	Activate(Drive.s, Folder.s)
	Declare.i	Deactivate(Drive.s, Folder.s, Force.b = #False)
	Declare    MenuActivate()
	Declare		MenuDeActivate(Force.b)
	Declare.i	ListGetVirtualDrives()
	Declare.s  ListGetVirtualDrive(Index.i)
	Declare.s  ListGetVirtualDirectory(Index.i)
	Declare		MenuGetVirtualDrive(MountText.s)
	
EndDeclareModule

Module VirtualDriveSupport
	
	Structure STRUCT_VIRTUALDRIVEHOLD
		char.c
		directory.s
 	EndStructure        
 	Global NewList listVDrives.STRUCT_VIRTUALDRIVEHOLD()
 	
 	;
 	;
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
	;
	Procedure.c GetDriveToChar(Drives.s)
		ProcedureReturn Asc( Left( Drives, 1 ))
	EndProcedure
	;
 	;
 	Procedure.i ListGetVirtualDrives()
 		
 		ResetList( listVDrives() )
 		;
 		; Fängt ab 0 an
 		ProcedureReturn ListSize( listVDrives() )-1
 		
 	EndProcedure
 	;
	;
 	Procedure.s ListGetVirtualDrive(Index.i)
 		
 		If ( ListGetVirtualDrives() >= 0 )
 			SelectElement( listVDrives(), Index ) 		
 			ProcedureReturn Chr(listVDrives()\char) + "\:"
 		EndIf
 		ProcedureReturn ""
 		
 	EndProcedure
	;
	;
 	Procedure.s ListGetVirtualDirectory(Index.i)
 		
 		If ( ListGetVirtualDrives() >= 0 )
 			SelectElement( listVDrives(), Index ) 		
 			ProcedureReturn listVDrives()\directory
 		EndIf
 		ProcedureReturn ""
 		
 	EndProcedure 	
	;
 	;
 	Procedure.i ListSetAndCompare(Drives.s, Folder.s)
 		
 		Protected char.c
 		
 		If Len( Drives ) > 0
 			char = GetDriveToChar(Drives)
 			
 			If Len( Folder ) > 0
 				
 				If ( ListGetVirtualDrives() >= 0 )
 					While NextElement( listVDrives() )
 						
 						If ( listVDrives()\char = char And listVDrives()\directory = Folder )
 							ProcedureReturn ListIndex( listVDrives() )
 						EndIf
 					Wend
 				EndIf
 			EndIf
 		EndIf	
 		
		AddElement(listVDrives())
		listVDrives()\char =  char
		listVDrives()\directory = Folder
		
		ProcedureReturn -1
 	EndProcedure
 	;
	; 		
 	Procedure.i ListGetAndCompare(Drives.s)
 		
 		Protected char.c
 		
 		If Len( Drives ) > 0
 			char = GetDriveToChar(Drives)
 			
 			If ( ListGetVirtualDrives() >= 0 )
 				While NextElement( listVDrives() )
 					
 					If ( listVDrives()\char = char ) 						
 						ProcedureReturn ListIndex( listVDrives() )
 					EndIf
 				Wend
 			EndIf
 		EndIf

		ProcedureReturn -1
 	EndProcedure
 	;
	;
 	Procedure.i ListRemove(Index)
 		If ( ListGetVirtualDrives() >= 0 ) 			 		
 			SelectElement( listVDrives(), Index ) 
 			DeleteElement(listVDrives(), Index ) 
 		EndIf
 	EndProcedure 	
 	;
	;
	Procedure.b ApiCodeDefineDos(Activate.b = #True,MountDrive.s = "", MountDirectory.s = "", Force.b = #False)
		
		Protected  ErrorMsg3.s, Index.i
		
		; 	BOOL DefineDosDeviceW(
		;   [IN]           DWORD   dwFlags,
		;   [IN]           LPCWSTR lpDeviceName,
		;   [IN, optional] LPCWSTR lpTargetPath	);
		;
		;		Flags
		;		DDD_EXACT_MATCH_ON_REMOVE	:	0x00000004
		;		DDD_NO_BROADCAST_SYSTEM		: 0x00000008
		;		DDD_RAW_TARGET_PATH				: 0x00000001
		; 	DDD_REMOVE_DEFINITION			:	0x00000002
		;
		;		Return value
		;		If the function succeeds, the Return value is nonzero. (succeeds > 0) (Fail is 0)?? ist das nicht andersrum?
		;		If the function fails, the Return value is zero. To get extended error information, CALL GetLastError.
		
		Protected dddFlags.l
		
		If ( Activate = #False )
			
			If ( Force = #False )
				dddFlags = #DDD_REMOVE_DEFINITION|#DDD_EXACT_MATCH_ON_REMOVE
			Else
				dddFlags = #DDD_REMOVE_DEFINITION
			EndIf
			
		Else
			dddFlags = 0
		EndIf
		
		
		Result = DefineDosDevice_(dddFlags, MountDrive +":" ,MountDirectory)
		If ( Result = 0 )
			
			ErrorMsg3 = GetLastError()
			
			If ( Activate = #True )
				ErrorMsg3 + #CR$ +  "[ Start abgebrochen ]"
			EndIf
			
			Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support","Define Dos Device Message: " + #CR$ + ErrorMsg3 ,2,1,"",0,0,DC::#_Window_001)
						
			ProcedureReturn #False
		EndIf
		
		If ( Activate = #False )
			Index.i = ListGetAndCompare(MountDrive + ":\")
			If ( index >= 0 )
				ListRemove(Index)
			EndIf
		EndIf	
		
		ProcedureReturn #True
	EndProcedure
	;
	; 	
	Procedure.s RemoveDirectorySlash(Path.s)
	
			If Right(Path,1) = "\"
					Path = Left(Path,Len(Path)-1)
			EndIf		
			
			ProcedureReturn Path
	EndProcedure
	;
	;
	Procedure.s GetDriveType(Drive.s)
	  Protected result
	  
	  result=GetDriveType_(Drive+":\")
	  Select result
	  		; Case 1
				; DRIVE_NO_ROOT_DIR
	  		; The root path is invalid; for example, there is no volume mounted at the specified path.
	  	Case 2
	  		; DRIVE_REMOVABLE
	  		; The drive has removable media; for example, a floppy drive, thumb drive, or flash card reader.
	    	ProcedureReturn "Wechseldatenträger [Diskette oder USB]"
	    Case 3
	    	; DRIVE_FIXED
	    	; The drive has fixed media; for example, a hard disk drive or flash drive.
	      ProcedureReturn "HD [Hard Disk]";"Festplatte"
	    Case 4
	    	; DRIVE_REMOTE
	    	; The drive is a remote (network) drive.
	      ProcedureReturn "Netzwerk";"Netzwerk"
	    Case 5
	    	; DRIVE_CDROM
	    	; The drive is a CD-ROM drive.    	
	    	ProcedureReturn "CD/DVD" ;"CD-Rom"
	    Case 6
	    	; DRIVE_RAMDISK
				; The drive is a RAM disk.
	      ProcedureReturn "Ram-Disk"
	  EndSelect
	  
	  ProcedureReturn ""
	  
	EndProcedure
	;
	;
	Procedure.i CheckDrive(Drive.s)
		
		Protected char.c	, ErrorMsg.s
		
			ErrorMsg = "Laufwerk " +Chr(34) + UCase(Left(Drive,1)) + ":\"+ Chr(34) +" kann nicht vergeben werden. " +#CR$ + #CR$ +"[ Drive Letter Not Allowed ]"
			ErrorMsg + #CR$ + "[ Start abgebrochen ]"
			
			Select Asc(Left(Drive,1))
				Case 65 To 90, 97 To 122					
							ProcedureReturn #True							
			EndSelect
			
			Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support",ErrorMsg,2,2,"",0,0,DC::#_Window_001)
			ProcedureReturn #False
			
	EndProcedure
	;
	;
	Procedure.i CheckDriveLength(Drive.s)
		Protected ErrorMsg1.s
		
		ErrorMsg1 = "Kein Laufwerk im Argument '%vdm' angegeben."	
		If Len(Drive) = 0
			ErrorMsg1 + #CR$ + "[ Start abgebrochen ]"
			Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support",ErrorMsg1,2,2,"",0,0,DC::#_Window_001)
			ProcedureReturn #False
		EndIf		
		ProcedureReturn #True
	EndProcedure
	;
	;
	Procedure.b CheckDirectoryLength(Folder.s)
		
		Protected ErrorMsg1.s
		ErrorMsg1 = "Verzeichnis nicht gefunden : " + Folder
		
		If FileSize( Folder ) > -2
			Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support",ErrorMsg1,2,2,"",0,0,DC::#_Window_001)
			ProcedureReturn #False
		EndIf
		
		ProcedureReturn #True
		
	EndProcedure
	;
	;
	Procedure.i Activate(Drive.s, Folder.s)
		Protected MountDirectory.s, Result.i, Error.s, MountDrive.s, ErrorMsg2.s
		
			
		ErrorMsg2 = "Kann " +Chr(34) + Left(UCase(Drive),1)+ ":\"+ Chr(34) + " nicht als Virtuelles Laufwerk anmelden. " + GetDriveType(Left(UCase(Drive),1)) + " Volume entdeckt"
		ErrorMsg2 + #CR$ + "[ Start abgebrochen ]"
		
		MountDrive 			= Left(UCase(Drive),1)		
		MountDirectory 	= RemoveDirectorySlash(Folder)	
		
		If ( CheckDriveLength(MountDrive) = #False )
			ProcedureReturn #False
		EndIf		
		
		If ( CheckDrive(MountDrive) = #False)
			ProcedureReturn #False
		EndIf
				
		If ( GetDriveType(MountDrive) = "" )									
			If ( ListSetAndCompare(MountDrive, MountDirectory) = -1 )				
				ProcedureReturn ApiCodeDefineDos(#True,MountDrive, MountDirectory)		
			EndIf
		Else
			Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support",ErrorMsg2,2,2,"",0,0,DC::#_Window_001)
			ProcedureReturn #False
		EndIf
			
		ProcedureReturn #True		
	EndProcedure
	;
	;
	Procedure.i Deactivate(Drive.s, Folder.s, Force.b = #False)
		Protected MountDirectory.s, Result.i, Error.s, MountDrive.s
				
		MountDrive 			= Left(UCase(Drive),1)		
		MountDirectory 	= RemoveDirectorySlash(Folder)
		
		If ( CheckDirectoryLength(MountDirectory) = #True)
		
			If ( GetDriveType(MountDrive)  = "HD [Hard Disk]" )
					ProcedureReturn ApiCodeDefineDos(#False,MountDrive, MountDirectory, Force)				
			Else
				Debug "ERROR -- DefineDosDefination Deactivate Fail -- Dieser abschnitt sollte nicht erreicht werden"
			EndIf
		EndIf
		
	EndProcedure
	;
	;
	Procedure.s SetDialogReturnString()
		Protected Index.i
		
		For index = 90 To 65 Step -1
			
			If ( GetDriveType(Chr(index)) = "")       
				ProcedureReturn  Chr(index) + ":\"
				Break
			EndIf       		
		Next
       
	EndProcedure
	;
	;
	Procedure.s SetDialogInitialPath()
		Protected InitialPath.s
		
		InitialPath = Startup::*LHGameDB\Base_Path + "InSerie\"
		
		If FileSize(InitialPath) > -2
			;
			; -2 Verzeichnis nicht gefunden
			InitialPath = Startup::*LHGameDB\Base_Path
		EndIf
		
		ProcedureReturn InitialPath
	EndProcedure
	;
	;
	Procedure.i MenuActivate()
		
		Protected Result.i,  Path.s
		
		
		Request::*MsgEx\User_BtnTextL = "Weiter"       
		Request::*MsgEx\User_BtnTextR = "Abbruch"       
		Request::*MsgEx\Return_String = SetDialogReturnString()
		
		Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support" ,"Welcher Laufwerks Buchstaben soll vergeben werden.",10,0,ProgramFilename(),0,1) 
		Select Result
			Case 0:       		
				
				Path = PathRequester("Bitte wähle den Pfad für den Laufwerksbuchstaben", SetDialogInitialPath())
				If ( Path = "" )
					ProcedureReturn 
				EndIf
				
				Activate(Request::*MsgEx\Return_String, Path)       		
		EndSelect
		
	EndProcedure
	;
	;
	Procedure.c MenuDialogCheckDrive(Drive.s)
		
			Select Asc(Left(Drive,1))
				Case 65 To 90, 97 To 122	
					ProcedureReturn Asc(Left(Drive,1))
			EndSelect
			
			ProcedureReturn 0
	EndProcedure
	;
	;
	Procedure.s MenuDialogGetUserPath(Char.c,Path.s, Option.b = #False)
		Protected Message.s
		
		Message = "Bitte wähle den Pfad für den Laufwerksbuchstaben: "+Chr(34) + Chr(char) + ":\" + Chr(34)
		If ( Option = #True )
			Message = "Verzeichnis für den Laufwerksbuchstaben: "+Chr(34) + Chr(char) + ":\" + Chr(34) + " Entdeckt"
		EndIf
		
		 Path = PathRequester("Bitte wähle den Pfad für den Laufwerksbuchstaben: "+Chr(34) + Chr(char) + ":\" + Chr(34), Path)
		 If ( path = "")
		 			ProcedureReturn ""
		 EndIf		
		ProcedureReturn Path
	EndProcedure
	;
	;
	Procedure.i MenuDeActivate(Force.b)	
		
		Protected CharDrive.c, Index.i, Folder.s, Path.s, MountDirectory.s, Drive.s
		
		Request::*MsgEx\User_BtnTextL = "Auswahl"     
		Request::*MsgEx\User_BtnTextM = "Ok"
		Request::*MsgEx\User_BtnTextR = "Abbruch"
		Request::*MsgEx\Return_String = "X:\"
		
		Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support" ,"Welches Laufwerk soll entfernt.",16,0,ProgramFilename(),0,1) 
		
		Select Result
			Case 0:
				
				Drive = PathRequester("Bitte wähle den Laufwerksbuchstaben", "")
				If Not ( Drive = "" )
					CharDrive 		 = MenuDialogCheckDrive(Drive)
					
					Index.i = ListGetAndCompare(Drive)
					If ( index >= 0 )
						MountDirectory = MenuDialogGetUserPath(CharDrive,ListGetVirtualDirectory(Index.i), #True)
					Else
						MountDirectory = MenuDialogGetUserPath(CharDrive,SetDialogInitialPath())
					EndIf
					
				EndIf
				
			Case 1:
				ProcedureReturn
				
			Case 2:
				
				CharDrive = MenuDialogCheckDrive(Request::*MsgEx\Return_String)
				If CharDrive = 0 
					ProcedureReturn 
				EndIf
				
				Index.i = ListGetAndCompare(Chr(CharDrive) + ":\")
				If ( Index > 0 )
					Folder = ListGetVirtualDirectory(Index.i)
					
					If Len(Folder) = 0
						MountDirectory = MenuDialogGetUserPath(CharDrive,SetDialogInitialPath()) 
					Else
						MountDirectory = MenuDialogGetUserPath(CharDrive, Folder,#True) 
					EndIf
				Else		 				 			
					MountDirectory = MenuDialogGetUserPath(CharDrive, SetDialogInitialPath()) 
				EndIf
				
				If ( MountDirectory = "" )		 					 		
					ProcedureReturn 
				EndIf		 				 				 			
		EndSelect  		
		
		Deactivate(Chr(CharDrive) + ":\", MountDirectory, Force)		 
	EndProcedure
	;
	;
	Procedure.i MenuGetVirtualDrive(MountText.s)
		
		Protected Drive.s, PosDrive.i, PosDirectory.i, MountDirectory.s, DirectoryLen.i
		
		If ( Len(MountText) > 0 )
			
			;
			;
			; Hole das Laufwerk
			PosDrive = FindString( MountText, ":", 1 )
			If ( PosDrive > 0 )				
				Drive = Mid( MountText,  PosDrive-2, 3)
				
				;
				;
				; Hole das Verzeichnis
				PosDirectory = FindString( MountText, "=", PosDrive )
				If ( PosDirectory > 0 )
					DirectoryLen 		= Len( MountText ) - ( PosDirectory+1 )
					MountDirectory 	= Mid( MountText,  PosDirectory+2, DirectoryLen )
				EndIf				
			EndIf						
		EndIf	
		
		Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Virtual Drive Support" ,"Soll Laufwerk " + Chr(34) + Drive + Chr(34) +" entfernt werden?",10,0,ProgramFilename(),0,0) 
		If Result = 0
			Deactivate(Drive, MountDirectory, #False)	 
		EndIf
		
	EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 496
; FirstLine = 152
; Folding = zBAw-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\NewGame\