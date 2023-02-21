DeclareModule vArchiv
		
	Declare.i	FileFormat_Init(szFile.s)
	Declare.i	FileFormat_Drop(szFile.s)
	
	Declare.i	Close()
	Declare.i	List_Header_Generate()
    
EndDeclareModule


Module vArchiv
	
  
	Global *ArchivMemory
	;
	;
	;
	Procedure.i	ErrorMessages(ErrorFormat.i)
		;
		; UnLZX Fehler Meldungen
		; - UnLZX::Examine_Archive
		; -1 : No LZX File
		; -2 : Error Data Listing
		; -3 : Error User Listing
		; -4 : File is In use
		;
		; UnLZX::Extract_Archive
		; -5 : Extractting by File = File Not in the List
		; -6 : Extractting by Nr   = Number excced List
		; -7 : Extractting by Nr   = File Not in the List		
		Select Startup::*LHGameDB\ArchivTyp
			Case "LZX"
				
				Select ErrorFormat
					Case -1
						Request::MSG(Startup::*LHGameDB\TitleVersion, "LZX ERROR","Datei ist kein Amiga LZX Format",2,2,"",0,0,DC::#_Window_001)
						ProcedureReturn #False
					Case 	-2
						Request::MSG(Startup::*LHGameDB\TitleVersion, "LZX ERROR","Fehler beim auflisten der Daten",2,2,"",0,0,DC::#_Window_001)
						ProcedureReturn #False
					Case 	-3
						Request::MSG(Startup::*LHGameDB\TitleVersion, "LZX ERROR","Fehler beim auflisten der User Daten",2,2,"",0,0,DC::#_Window_001)
						ProcedureReturn #False
					Case -4						
						Request::MSG(Startup::*LHGameDB\TitleVersion, "LZX ERROR","Datei ist von einem anderen Programm in Benutzung",2,2,"",0,0,DC::#_Window_001)
						ProcedureReturn #False
				EndSelect
			Default	
		EndSelect
		ProcedureReturn #True
	EndProcedure
	;
	;
	;
	Procedure.i	List_Header_Generate()		
		
		Protected.i ColumnWidthA = 35, ColumnWidthB = 120, ColumnWidthC = 0, ListWidth = GadgetWidth(DC::#ListIcon_004)
		
		;
		; Die Letze Dritte Spalte
		ColumnWidthC = ListWidth - (ColumnWidthA + ColumnWidthB)
		
		
		SetGadgetText( DC::#Text_137,   "Nr."          )
		SetGadgetText( DC::#Text_138,   "UnPack Size"  )
		SetGadgetText( DC::#String_113, "Format Archiv")		
		
		SendMessage_( GadgetID( DC::#ListIcon_004 ), #LVM_SETEXTENDEDLISTVIEWSTYLE, 0, #LVS_EX_LABELTIP | #LVS_EX_FULLROWSELECT)
		
            AddGadgetColumn(DC::#ListIcon_004, 1,"",ColumnWidthA)
            AddGadgetColumn(DC::#ListIcon_004, 2,"",ColumnWidthB)
            AddGadgetColumn(DC::#ListIcon_004, 3,"",ColumnWidthC)		
            
            
            ResizeGadget(DC::#Text_137, #PB_Ignore, #PB_Ignore, ColumnWidthA  ,#PB_Ignore) 
            ResizeGadget(DC::#Text_138, GadgetX(DC::#Text_137) + GadgetWidth(DC::#Text_137),   #PB_Ignore, ColumnWidthB  ,#PB_Ignore)
            ResizeGadget(DC::#String_113, GadgetX(DC::#Text_138) + GadgetWidth(DC::#Text_138), #PB_Ignore, ColumnWidthC  ,#PB_Ignore) 
		
	EndProcedure	
	;
	;
	;
	Procedure.i	List_Clear()
		ClearGadgetItems( DC::#ListIcon_004 )
	EndProcedure
	;
	;
	;	
	Procedure.i	Format_Info()		
		
		Protected.s szFormat
		
		Select Startup::*LHGameDB\ArchivTyp
			Case "LZX"
				szFormat = " Archiv Geladen: Amiga " + Startup::*LHGameDB\ArchivTyp
				
			Case "ZIP", "PK3","PK4"
				Select Startup::*LHGameDB\ArchivTyp
					Case "ZIP": Startup::*LHGameDB\ArchivTyp = "ZIP"
						szFormat = " Archiv Geladen: Standard " + Startup::*LHGameDB\ArchivTyp + " Format"
						
					Case "PK3": Startup::*LHGameDB\ArchivTyp = "PK3"	;Doom3
						szFormat = " Archiv Geladen: Doom 3 (Zip) " + Startup::*LHGameDB\ArchivTyp + " Format"
						
					Case "PK4": Startup::*LHGameDB\ArchivTyp = "PK4"	;Quake4
						szFormat = " Archiv Geladen: Quake 4 (Zip) " + Startup::*LHGameDB\ArchivTyp + " Format"						
						
				EndSelect				
				
			Case "7ZIP", "7Z"
				szFormat = " Archiv Geladen: " + Startup::*LHGameDB\ArchivTyp + " Format"				
		EndSelect		
				
		SetGadgetText( DC::#Text_139,  szFormat )		
		
	EndProcedure
	;
	;
	;
	Procedure.i	Format_Info_Clear()		
		
		Startup::*LHGameDB\ArchivTyp = ""	
		
	EndProcedure		
	;
	;
	;
	Procedure.i	Close()
		;
		; Schliessen des Archiv Typ
		;
		
		If ( *ArchivMemory > 0 )
			
			Select Startup::*LHGameDB\ArchivTyp
				Case "LZX"
					
					UnLZX::Close_Archive(*ArchivMemory)
					ClearList( UnLZX::User_LZX_List() )
					
				Case "ZIP"					
					ClosePack(*ArchivMemory)
				
				Default
					
			EndSelect
			
			*ArchivMemory = 0
			
		EndIf
		
		Format_Info_Clear()
		
		If IsGadget( DC::#ListIcon_004 )
			ClearGadgetItems( DC::#ListIcon_004 )
		EndIf	
		ProcedureReturn 0
	EndProcedure	
	;
	;
	;	
	Procedure.i LZX_List()
		
		Protected.i FileCount 
		Protected.s szNumber, SizeUnpack, szFileName, szPackDate
		
		List_Clear()
			
		If ( *ArchivMemory > 0 )
			With UnLZX::User_LZX_List()
				
				While NextElement( UnLZX::User_LZX_List() )
					
					If  UnLZX::User_LZX_List()\isMerge
						Continue
					EndIf
					
					FileCount + 1
					
					szNumber    =  RSet( Str( FileCount ), 5, " ")
					
					SizeUnpack  =  RSet( MathBytes::FileSizeFormat( Val( \SizeUnpack) ), 10, " ")
					
					szFileName  = \PathFile
					
					;szPackDate  = \szFileDate
					
					AddGadgetItem(DC::#ListIcon_004, -1, "" + Chr(10)+ szNumber + "  " +Chr(10)+ SizeUnpack +"  " +Chr(10)+ szFileName )
				Wend
				
				SendMessage_(GadgetID(DC::#ListIcon_004),#LVM_SETCOLUMNWIDTH,3,#LVSCW_AUTOSIZE_USEHEADER)
				
			EndWith		
		EndIf
	EndProcedure	
	;
	;
	;	
	Procedure.i	LZX_Init(szFile.s)
		
		Protected.i Result				
	
		*ArchivMemory = UnLZX::Process_Archive(szFile)
		If ( *ArchivMemory > 0 )

			Result =  UnLZX::Examine_Archive(*ArchivMemory)	
			If Result < 0	
				Result = ErrorMessages(Result)
				Close()
			EndIf
			
			Format_Info()
			
		EndIf	
		ProcedureReturn Result
	EndProcedure	
	;
	;
	;
	Procedure.i	ZIP_List()
		
		Protected.i FileCount 
		Protected.s szNumber, SizeUnpack, szFileName, szPackDate
		
		List_Clear()
		
		If ( *ArchivMemory > 0 )
			
			If ExaminePack( *ArchivMemory )
				
				While NextPackEntry( *ArchivMemory )
					
					FileCount + 1
					
					szNumber    =  RSet( Str( FileCount ), 5, " ")
					;
					; #PB_Packer_UncompressedSize
					; #PB_Packer_CompressedSize 
					SizeUnpack  =  RSet( MathBytes::FileSizeFormat( PackEntrySize(*ArchivMemory , #PB_Packer_UncompressedSize) ), 10, " ")
					
					szFileName  = PackEntryName( *ArchivMemory )
					
					AddGadgetItem(DC::#ListIcon_004, -1, "" + Chr(10)+ szNumber + "  " +Chr(10)+ SizeUnpack +"  " +Chr(10)+ szFileName )
				Wend	
				
				SendMessage_(GadgetID(DC::#ListIcon_004),#LVM_SETCOLUMNWIDTH,3,#LVSCW_AUTOSIZE_USEHEADER)
				
			EndIf				
		EndIf	
		
	EndProcedure	
	;
	;
	;	
	Procedure.i	ZIP_Init(szFile.s)
		
		*ArchivMemory = OpenPack(#PB_Any , szFile, #PB_PackerPlugin_Zip) 
		If ( *ArchivMemory > 0 )
			
			Format_Info()
			ProcedureReturn #True
			
		EndIf
		
		ProcedureReturn #False
		
	EndProcedure	
	;
	;
	;
	Procedure.i	LZM_List()
		
		Protected.i FileCount 
		Protected.s szNumber, SizeUnpack, szFileName, szPackDate
		
		List_Clear()
		
		If ( *ArchivMemory > 0 )
			
			If ExaminePack( *ArchivMemory )
				
				While NextPackEntry( *ArchivMemory )
					
					FileCount + 1
					
					szNumber    =  RSet( Str( FileCount ), 5, " ")
					;
					; #PB_Packer_UncompressedSize
					; #PB_Packer_CompressedSize 
					SizeUnpack  =  RSet( MathBytes::FileSizeFormat( PackEntrySize(*ArchivMemory , #PB_Packer_UncompressedSize) ), 10, " ")
					
					szFileName  = PackEntryName( *ArchivMemory )
					
					AddGadgetItem(DC::#ListIcon_004, -1, "" + Chr(10)+ szNumber + "  " +Chr(10)+ SizeUnpack +"  " +Chr(10)+ szFileName )
				Wend	
				
				SendMessage_(GadgetID(DC::#ListIcon_004),#LVM_SETCOLUMNWIDTH,3,#LVSCW_AUTOSIZE_USEHEADER)
				
			EndIf				
		EndIf	
		
	EndProcedure	
	;
	;
	;	
	Procedure.i	LZM_Init(szFile.s)
		
		*ArchivMemory = OpenPack(#PB_Any , szFile, #PB_PackerPlugin_Lzma) 
		If ( *ArchivMemory > 0 )
			
			Format_Info()
			
			ProcedureReturn #True
			
		EndIf
		
		ProcedureReturn #False
		
	EndProcedure	
	;
	;
	;
	Procedure.i	FileFormat_Init(szFile.s)
		
		Protected.s szNonPortable, szExtension
		Protected.i Result
		
		;
		; Erstelle Standard Dateinamen aus dem Portablen Dateinamen
		szNonPortable = VEngine::Getfile_Portbale_ModeOut(szFile)
		
		;
		; Erweiterung Prüfen
		szExtension   = GetExtensionPart( szNonPortable )
		
		Select UCase( szExtension )
			Case "LZX"
				Startup::*LHGameDB\ArchivTyp = "LZX"
				Result = LZX_Init(szNonPortable)
				If ( Result = #True )
					LZX_List()
				EndIf	
				
			Case "ZIP", "PK3","PK4"
				;
				; Detaillierte Unterscheidung
				Select UCase( szExtension )
					Case "ZIP": Startup::*LHGameDB\ArchivTyp = "ZIP"
					Case "PK3": Startup::*LHGameDB\ArchivTyp = "PK3"	;Doom3
					Case "PK4": Startup::*LHGameDB\ArchivTyp = "PK4"	;Quake4				
				EndSelect		
				Result = ZIP_Init(szNonPortable)
				If ( Result = #True )
					ZIP_List()
				EndIf	
				
			Case "7ZIP", "7Z"
				Startup::*LHGameDB\ArchivTyp = "7ZIP"
				Result = LZM_Init(szNonPortable)
				If ( Result = #True )
					LZM_List()
				EndIf	
				
			Default
				ProcedureReturn #False
		EndSelect		

	EndProcedure	
	;
	;
	;
	Procedure.i	FileFormat_Drop(szFile.s)
		
		Protected.i Count, i
		Protected.s szDrop
		
		If ( Len( szFile ) > 0 )
			
			Count  = CountString(szFile, Chr(10) ) + 1
			For i = 1 To Count
				;
				; Taking only the First File
				szDrop = StringField(szFile, i, Chr(10) )
				;
				; 
				Close()
				FileFormat_Init(szDrop)
				Break
			Next
			
		EndIf			
	EndProcedure	
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 98
; Folding = zo4
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\release\