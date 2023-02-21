DeclareModule TDCDAT
	
	Declare.i 	Dat_OpenFile(File.s, GadgetID_CountGames.i = 0, GadgetID_CountFiles.i = 0, GadgetID_GameName.i = 0)
	Declare.i   Dat_WriteFile(*Header, File.s = "", useDate.i = #False, useDateLong.i = #False, UseSort.i = #False, ProgressID.i = 0, GadgetID_GameName.i = 0)
	
	Declare.i	Dat_Convert(*Header)
	Declare.i	GetCountGames(*Header)
	Declare.i	GetCountFiles(*Header)
	
	Declare.i	Dat_Listing(*Header, ListGadgetID.i = 0)

EndDeclareModule

Module TDCDAT
	
	Global ProgressCounter.i
	
	Structure TDC_GameFile
		Name.s
		Size.s
		Date.s
		DateLong.s
		HashCrc32.s		
	EndStructure
	
	Structure TDC_GameName
		Game.s
		Description.s
		List TDC_GameFile.TDC_GameFile()		
	EndStructure
	
	Structure TDC_Main
				; ---------------------------------------
				; <header>
		Name.s	; <name>Total DOS Collection</name>
		Decription.s; <description></description>
		Category.s	; <category>TDC</category>
		Version.s	; <version></version>
		Author.s	; <author></author>	
		Email.s	; <email></email>
		Homepage.s	; <homepage></homepage>
		URL.s		; <url></url>
				; <clrmamepro/>			
				; ---------------------------------------
		File.s
		Path.s
		FileDataR.i	
		FileDataW.i
		CountGames.i
		CountRoms.i
		Encoding.i
		_thread.i
		useDate.i
		useDateLong.i
		useSortIMA.i
		useSortCDR.i
		useSortEDU.i
		useSortGMS.i
		CountWrittenTitles.i
		CountWrittenEntrys.i
		List Content.TDC_GameName()
	EndStructure

	;
	;
	;
	Procedure.i GetCountFiles(*Header.TDC_Main)
		If *Header > 0
			ProcedureReturn *Header\CountRoms
		EndIf
		ProcedureReturn 0
	EndProcedure
	;
	;
	;
	Procedure.i GetCountGames (*Header.TDC_Main)
		If *Header > 0		
			ProcedureReturn *Header\CountGames
		EndIf
		ProcedureReturn 0
	EndProcedure	
	;
	;
	;
	Procedure.s header_GetStr(szLine.s, szReplace.s)
		
		Protected.s szNewString
		Protected.i TabCount, TabsNum
		
	       szNewString = ReplaceString( szLine, szReplace, "", #PB_String_CaseSensitive  )
	       
	       szNewString = Trim( szNewString, Chr(9) )
	       szNewString = LTrim( szNewString)
	       ProcedureReturn szNewString
		
	 EndProcedure
	;
	;
	;
	Procedure.i Header_Store(*Header.TDC_Main, szLine.s)
					
		If FindString( szLine, "Name:", 1, #PB_String_CaseSensitive)						
			*Header\Name = header_GetStr(szLine.s, "Name:")
			ProcedureReturn #True
		EndIf		
		
		If FindString( szLine, "Description:", 1, #PB_String_CaseSensitive)			
			*Header\Decription = header_GetStr(szLine.s, "Description:")
			ProcedureReturn #True
		EndIf	
		
		If FindString( szLine, "Version:", 1, #PB_String_CaseSensitive)						
			*Header\Version = header_GetStr(szLine.s, "Version:")
			ProcedureReturn #True
		EndIf
					
		If FindString( szLine, "Date:", 1, #PB_String_CaseSensitive)						
			;*Header\Version = header_GetStr(szLine.s, "Date:")
			ProcedureReturn #True
		EndIf	
		
		If FindString( szLine, "Author:", 1, #PB_String_CaseSensitive)						
			*Header\Author = header_GetStr(szLine.s, "Author:")
			ProcedureReturn #True
		EndIf		
		
		If FindString( szLine, "Homepage:", 1, #PB_String_CaseSensitive)
			*Header\Homepage = "Total DOS Collection"
			*Header\URL		= header_GetStr(szLine.s, "Homepage:")			
			ProcedureReturn #True
		EndIf			
		
		If FindString( szLine, "Comment:", 1, #PB_String_CaseSensitive)
			;
			; Benutze den Kommentar mit der Description
			*Header\Decription = header_GetStr(szLine.s, "Comment:"); + " [" + *Header\Decription  + "]"
			ProcedureReturn #True
		EndIf	
		
		If FindString( szLine, ")", 1, #PB_String_CaseSensitive)			
			;
			; Header Ende
			ProcedureReturn #False
		EndIf
	EndProcedure	 
	;
	;
	;
	Procedure.i Header_Main(*Header.TDC_Main, szLine.s)
				
		If FindString( szLine, "DOSCenter (", 1, #PB_String_CaseSensitive)
			ProcedureReturn #True	
		EndIf		
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;
	Procedure.s Game_GetName(szLine.s, szReplace.s)
		
		Protected.s szNewString
		Protected.i TabCount, TabsNum
		
		szNewString = ReplaceString( szLine, szReplace, "", #PB_String_CaseSensitive  )
		;
		; Remove .zip suffix from the TDC Dat
		szNewString.s = ReplaceString( szNewString, ".zip", "", #PB_String_CaseSensitive  )		
	       
	      szNewString = Trim( szNewString, Chr(9) )
	       
	      ProcedureReturn szNewString
		
	 EndProcedure	
	;
	;
	;
	Procedure.i Game_Check(szLine.s)
				
		If FindString( szLine, "game (", 1, #PB_String_CaseSensitive)
			ProcedureReturn #True	
		EndIf		
		ProcedureReturn #False
		
	EndProcedure	
	;
	;
	;
	Procedure.i Game_Store_Name(List Content.TDC_GameName(), szLine.s, *Header.TDC_Main)
					
		If FindString( szLine, "name "+Chr(34), 1, #PB_String_CaseSensitive)
			
			AddElement( Content() )
			Content()\Game = Game_GetName(szLine, "name ")
			
			*Header\CountGames = *Header\CountGames  + 1
			Dat_GetCountGames  = *Header\CountGames
			
			ProcedureReturn #True
		EndIf	
	EndProcedure
	;
	;
	;
	Procedure.s Game_Store_Data_Char(szLine.s, *Header.TDC_Main)
		Protected.s szReplaced = ""
		Protected.i i
		Protected.c c
		
		For i = 1 To Len( szLine )			
			c = Asc( Mid( szLine, i,1) )			
			Select c
				Case 34	:szReplaced + "ö"		; Ersetzt das " zeichen .... 			
				Case 35	:szReplaced + "&#35;"
				Case 38	:szReplaced + "&amp;"					
				Case 127	:szReplaced + "&#127;"
				Case 160	:szReplaced + "&nbsp;"
				Case 196	:szReplaced + "&Auml;"	
				Case 214	:szReplaced + "&Ouml;"				
				Case 220	:szReplaced + "&Uuml;"
				Case 228	:szReplaced + "&auml;"			
				Case 214	:szReplaced + "&ouml;"	
				Case 220	:szReplaced + "&uuml;"
				Default
				szReplaced + Chr( c )	
			EndSelect							
		Next
		
		*Header\CountRoms = *Header\CountRoms + 1
		ProcedureReturn szReplaced
	EndProcedure	
	;
	;
	;	
	Procedure.s Game_Store_Data_Name(szLine.s, Start.i, Lenght.i)
		
		
		ProcedureReturn Mid(szLine, Start, Lenght-Start)
		
	EndProcedure	
	;
	;
	;
	Procedure.s Game_Store_Data_Date(szLine.s, List Content.TDC_GameName())	
		
		;
		;
		; ClrMamePro
		; Date Long : allow yyyymmddTHHMMSS As date/timestamp IN dat		
		; Support dat date attribute format YYYY-MM-DD without specifying timestamp
		
		Protected.s Date = "", Time = ""
		Protected.i i
		Protected.c c
			
		For i = 1 To Len( szLine )
			c = Asc( Mid( szLine, i,1) )	
			
			If c = 32 
				Continue
			EndIf
			
			If i > 11
				Time + Chr( c )	
			Else
				
				Date + Chr( c )	
			EndIf							
		Next	
	
		Content()\TDC_GameFile()\Date = FormatDate("%yyyy-%mm-%dd", ParseDate( "%yyyy/%mm/%dd",Date) )
		Content()\TDC_GameFile()\DateLong = FormatDate("%yyyy%mm%dd%hh%ii%ss", ParseDate( "%yyyy/%mm/%dd%hh:%ii:%ss",Date+Time) )
				
		

	EndProcedure	
	;
	;
	;
	Procedure.i Game_Store_Data(List Content.TDC_GameName(), szLine.s, *Header.TDC_Main)		
		Protected.i CountSpace
		Protected.s DataName = "", DataSize = "", DataDate = "", DataCRC32 = "", szStr = ""
		;
		;
		; Convertiertungs process der Zeile
		; file ( name 1.DAT size 128 date 1987/09/08 12:47:22 crc 6A6CA9DB )
		;
		If FindString( szLine, "file ( ", 1, #PB_String_CaseSensitive)
			
			szStr = ReplaceString( szLine, " )", "", #PB_String_CaseSensitive  )
			szStr = Trim( szStr, Chr(9) )
			
			DataName = Game_Store_Data_Name(szStr, FindString( szStr, "( name" , 1, #PB_String_CaseSensitive)+7,  FindString( szStr, " size ", 1, #PB_String_CaseSensitive) )
			DataName = Game_Store_Data_Char(DataName, *Header)
			
			DataSize = Game_Store_Data_Name(szStr, FindString( szStr, " size"  , 1, #PB_String_CaseSensitive)+6,  FindString( szStr, " date ", 1, #PB_String_CaseSensitive) )	
			
			DataDate = Game_Store_Data_Name(szStr, FindString( szStr, " date"  , 1, #PB_String_CaseSensitive)+6,  FindString( szStr, " crc ", 1, #PB_String_CaseSensitive) )
				
			
			DataCRC32= Game_Store_Data_Name(szStr, FindString( szStr, " crc"   , 1, #PB_String_CaseSensitive)+5,  Len( szStr )+1 )
			
			AddElement( Content()\TDC_GameFile() )
			
			Content()\TDC_GameFile()\Name 	=  DataName
			
			;
			;
			; In der TDC Datenbank sind Verzeichnisse hinterlegt die eine grösse und Prüsumme haben. Was nicht sein kann
			If Right( DataName, 1 ) = "\"
				DataSize  = "0"
				DataCRC32 = "00000000"
			EndIf	
				
			Content()\TDC_GameFile()\Size 	=  DataSize
			Game_Store_Data_Date(DataDate, Content.TDC_GameName())
			Content()\TDC_GameFile()\HashCrc32 	=  DataCRC32
			
			;Debug #TAB$ + "<rom name=" + Content()\TDC_GameFile()\Name + " size"+Content()\TDC_GameFile()\Size + " crc=" + Content()\TDC_GameFile()\HashCrc32 + ">"

			ProcedureReturn #True
		EndIf	
		;Debug "</game>"
		ProcedureReturn #False
	EndProcedure	
	;
	;
	;
	Procedure.s Dat_WriteFile_XML_Version()
		Protected.s szXML = ""
		
		szXML = "<?xml version=" +Chr(34)+ "1.0" +Chr(34)+ " encoding=" +Chr(34)+ "UTF-8" +Chr(34)+ "?>"
		ProcedureReturn szXML
	EndProcedure	
	;
	;
	;
	Procedure.s Dat_WriteFile_XML_LogiQX()
		Protected.s szXML = ""
		
		szXML = "<!DOCTYPE datafile PUBLIC "+Chr(34)+"-//Logiqx//DTD ROM Management Datafile//EN"+Chr(34)+ " "+Chr(34)+"http://www.logiqx.com/Dats/datafile.dtd"+Chr(34)+">"
		ProcedureReturn szXML
	EndProcedure
	;
	;
	;
	Procedure.i Dat_WriteFile_XML_Header(*Header.TDC_Main)
		
		If ( *Header\FileDataW > 0)
			WriteStringN(*Header\FileDataW, Dat_WriteFile_XML_Version(), *Header\Encoding)			
			WriteStringN(*Header\FileDataW, Dat_WriteFile_XML_LogiQX () , *Header\Encoding)
			
			WriteStringN(*Header\FileDataW,  "", *Header\Encoding)
			
			WriteStringN(*Header\FileDataW,  "<datafile>", *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + "<header>", *Header\Encoding)
			
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<name>" 		+ *Header\Name 		+ "</name>"		, *Header\Encoding)
			
			If *Header\useDate = #True
				WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<description>" 	+ *Header\Decription + " - Date Only"+ "</description>", *Header\Encoding)
			ElseIf *Header\useDateLong = #True	
				WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<description>" 	+ *Header\Decription + " - Full Timestamp"+ "</description>", *Header\Encoding)
			Else
				WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<description>" 	+ *Header\Decription + "</description>", *Header\Encoding)
			EndIf	
			
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<category>" 	+ *Header\Category 	+ "</category>"	, *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<version>" 	+ *Header\Version 	+ "</version>"	, *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<author>" 		+ *Header\Author 		+ "</author>"	, *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<email>" 		+ *Header\Email 		+ "</email>	"	, *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<homepage>" 	+ *Header\Homepage 	+ "</homepage>"	, *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<url>" 		+ *Header\URL 		+ "</url>"		, *Header\Encoding)
			
			WriteStringN(*Header\FileDataW,  #TAB$ + #TAB$ +"<clrmamepro/>", *Header\Encoding)
			WriteStringN(*Header\FileDataW,  #TAB$ + "</header>", *Header\Encoding)
			ProcedureReturn #True
		EndIf
		
		ProcedureReturn #False
	EndProcedure	
	;
	;
	;
	Procedure.s Dat_WriteFile_NewFileName(*Header.TDC_Main, File.s)
		
		Protected.s szNewFile, szClrMamePro, szPattern
		
		
		If ( Len( File ) = 0 )
			
			File = *Header\Path + *Header\File
			szClrMamePro = "ClrMamePro"
			szPattern    = ".dat"	
			
			szNewFile = GetFilePart(File, 1)
		
			If FindString( UCase( szNewFile), UCase( szClrMamePro), 1)			
				szNewFile = ReplaceString( UCase( szNewFile), UCase( szClrMamePro), "")
			EndIf
		
			szNewFile = GetPathPart(File) + szNewFile + " " + szClrMamePro + szPattern			
		Else
			szNewFile = File
		EndIf	
		
	

		ProcedureReturn szNewFile
	EndProcedure	
	;
	;
	;
	Procedure.i Check_Disk(*Header.TDC_Main)
		
		If ( FindString( UCase( *Header\Content()\Game), "[IMA][180K]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMA][160K]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMA][320K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[IMA][360K]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMA][720K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[IMA][1200K]") Or	; 1200 same how 1220 ???
		     FindString( UCase( *Header\Content()\Game), "[IMA][1220K]") Or					                                                                          
		     FindString( UCase( *Header\Content()\Game), "[IMA][1440K]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMA][360K-1200k]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMA][720k-1220k]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[IMA][1200k-1440k]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMD][180K]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMD][160K]") Or 					                            
		     FindString( UCase( *Header\Content()\Game), "[IMD][360K]") Or
		     FindString( UCase( *Header\Content()\Game), "[IMD][720K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[IMD][1200K]") Or	; 1200 same how 1220 ???
		     FindString( UCase( *Header\Content()\Game), "[IMD][1220K]") Or					                                                                          
		     FindString( UCase( *Header\Content()\Game), "[IMD][1440K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[TD0][160K]") Or
		     FindString( UCase( *Header\Content()\Game), "[TD0][180K]") Or
		     FindString( UCase( *Header\Content()\Game), "[TD0][320K]") Or
		     FindString( UCase( *Header\Content()\Game), "[TD0][360K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[SCP][360K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[SCP][720K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[TC][160K]") Or
		     FindString( UCase( *Header\Content()\Game), "[TC][180K]") Or			     		     
		     FindString( UCase( *Header\Content()\Game), "[TC][320K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[TC][360K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[KFX][180K]") Or
		     FindString( UCase( *Header\Content()\Game), "[KFX][160K]") Or
		     FindString( UCase( *Header\Content()\Game), "[KFX][320K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[KFX][360K]") Or			                            
		     FindString( UCase( *Header\Content()\Game), "[KFX][720K]") Or
		     FindString( UCase( *Header\Content()\Game), "[KFX][1200K]") Or					                                                                          
		     FindString( UCase( *Header\Content()\Game), "[KFX][1220K]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[KFX][1440K]") Or
		     FindString( UCase( *Header\Content()\Game), "[KFX][360K-1200k]") Or
		     FindString( UCase( *Header\Content()\Game), "[KFX][720k-1220k]") Or		     
		     FindString( UCase( *Header\Content()\Game), "[KFX][1200k-1440k]") Or
		     FindString( UCase( *Header\Content()\Game), "[360k][CP][!]"))
			ProcedureReturn #True
		EndIf
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;
	Procedure.i Check_CDROM(*Header.TDC_Main)
		
		;
		;
		; Die Benennung von TDC ist echt sch******
		If ( 	FindString( UCase( *Header\Content()\Game),"[BIN-CUE]") Or
		     	FindString( UCase( *Header\Content()\Game),"[ISO]") Or		     
		     	FindString( UCase( *Header\Content()\Game),"[CCD]") Or 		     	
		     	FindString( UCase( *Header\Content()\Game),"[BIN-") Or
		     	FindString( UCase( *Header\Content()\Game),"[ISO") Or		     
		     	FindString( UCase( *Header\Content()\Game),"[CCD") Or
		     	FindString( UCase( *Header\Content()\Game),"CUE]") Or
		     	FindString( UCase( *Header\Content()\Game),"ISO]") Or		     
		     	FindString( UCase( *Header\Content()\Game),"CCD]") Or
		     	FindString( UCase( *Header\Content()\Game),"_TDC_]") Or 
		     	FindString( UCase( *Header\Content()\Game),"[MDF]") Or
		     	FindString( UCase( *Header\Content()\Game),"[NRG]") Or		     	
		     	FindString( UCase( *Header\Content()\Game),"[CCD_DUPE_OF_REDUMP_BIN-CUE]") Or
		     	FindString( UCase( *Header\Content()\Game),"[CCD CONVERTED To BIN-CUE]") Or
		     	FindString( UCase( *Header\Content()\Game),"[FROM_EXO_ DUPE OF REDUMP BIN-CUE]") Or
		     	FindString( UCase( *Header\Content()\Game),"[ISO__DUPEOFBIN-CUE__]") Or
		     	FindString( UCase( *Header\Content()\Game),"[ISO_DUPE_OF_BIN-CUE_]") Or
		     	FindString( UCase( *Header\Content()\Game),"[ISO_DUPE_OF_BIN-CUE]") Or		     	                                           
		     	FindString( UCase( *Header\Content()\Game),"[_ISO, DUPE OF BIN-CUE_]") Or
		     	FindString( UCase( *Header\Content()\Game),"[_DUPE_OF_REDUMP_BIN-CUE]") Or
		     	FindString( UCase( *Header\Content()\Game),"[_DUPE_OF_BIN_CUE__CCD]") Or
		     	FindString( UCase( *Header\Content()\Game),"[_DUPE_OF_BIN-CUE_ISO]") Or
		     	FindString( UCase( *Header\Content()\Game),"[_DUPE_CONTENTS_OF_BIN-CUE_ISO]") Or
		     	FindString( UCase( *Header\Content()\Game),"[DUPE_OF_TDC_BIN-CUE]") Or		     	
		     	FindString( UCase( *Header\Content()\Game),"[SAME FILES AS OTHER ISO]") Or
		     	FindString( UCase( *Header\Content()\Game),"[NRG__DUPE_OF_BIN-CUE_IN_TDC]") Or
		     	FindString( UCase( *Header\Content()\Game),"[MDF__DUPE OF ISO IN TDC_]") Or
		     	FindString( UCase( *Header\Content()\Game),"[CCD, DUPE OF GREMLIN INTERACTIVE LIMITED ISO IN 1996 CCD]") Or
			FindString( UCase( *Header\Content()\Game),"[_DUPE_OF_EXISTING_BIN-CUE_]"))	
			
			
			ProcedureReturn #True
		EndIf		
		ProcedureReturn #False
	EndProcedure
	;
	;
	;
	Procedure.i Check_Disk_RAW(*Header.TDC_Main)
				
		If (  GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "IMA" Or 
		      GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "IMZ" Or	; IMZ has always another Size
		      GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "IMG" Or 			      
		      GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "RAW" Or 		      
		      GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "SCP" Or
		      GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "TD0" Or
		      GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "DSK" Or
			GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "VFD" Or			      
			GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name )) = "TC" )
			ProcedureReturn #True
		EndIf
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;
	Procedure.i Check_Disk_IMA(*Header.TDC_Main)
				
		If ( GetExtensionPart(UCase(  *Header\Content()\TDC_GameFile()\Name ) ) = "IMA"  Or GetExtensionPart(UCase(  *Header\Content()\TDC_GameFile()\Name ) )  = "IMG" ) And		   
		   ( Val( *Header\Content()\TDC_GameFile()\Size) = 118044 Or	;180
		     Val( *Header\Content()\TDC_GameFile()\Size) = 149576 Or	;160
		     Val( *Header\Content()\TDC_GameFile()\Size) = 327680 Or	;320k
		     Val( *Header\Content()\TDC_GameFile()\Size) = 368640 Or	;360		     
		     Val( *Header\Content()\TDC_GameFile()\Size) = 737280 Or	;720K
		     Val( *Header\Content()\TDC_GameFile()\Size) = 1228800 Or	;1.2MB
		     Val( *Header\Content()\TDC_GameFile()\Size) = 1474560 )	;1.44MB
			  
			ProcedureReturn #True
		EndIf
		ProcedureReturn #False
		
	EndProcedure
	;
	;
	;
	Procedure.i Check_CDROM_File(*Header.TDC_Main)
				
		If (   GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "BIN" Or 
		       GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "CUE" Or
		       GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "CCD" Or		      
		       GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "ISO" Or		      
		       GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "MDF" Or
		       GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "MDS" Or		      
		       GetExtensionPart( UCase( *Header\Content()\TDC_GameFile()\Name ) ) = "NRG"  )
			
			If ( Check_CDROM(*Header) = #False )
				ProcedureReturn #False
			EndIf
			
			ProcedureReturn #True
		EndIf
		ProcedureReturn #False
		
	EndProcedure	
	;
	;
	;
	Procedure.i Dat_WriteFile_CheckDate(*Header.TDC_Main)
		
		If *Header\useDate = #True
			*Header\CountWrittenEntrys + 1
			WriteStringN(*Header\FileDataW,   #TAB$ +#TAB$ + 
			                                  "<rom name=" + Chr(34) + *Header\Content()\TDC_GameFile()\Name 	+ Chr(34) +
			                                  " size=" + Chr(34) + *Header\Content()\TDC_GameFile()\Size      	+ Chr(34) +
			                                  " date=" + Chr(34) + *Header\Content()\TDC_GameFile()\date      	+ Chr(34) +
			                                  " crc="  + Chr(34) + *Header\Content()\TDC_GameFile()\HashCrc32 	+ Chr(34) + "/>",*Header\Encoding)
		ElseIf *Header\useDateLong = #True
			*Header\CountWrittenEntrys + 1
			WriteStringN(*Header\FileDataW,   #TAB$ +#TAB$ + 
			                                  "<rom name=" + Chr(34) + *Header\Content()\TDC_GameFile()\Name 	+ Chr(34) +
			                                  " size=" + Chr(34) + *Header\Content()\TDC_GameFile()\Size      	+ Chr(34) +
			                                  " date=" + Chr(34) + *Header\Content()\TDC_GameFile()\DateLong     	+ Chr(34) +
			                                  " crc="  + Chr(34) + *Header\Content()\TDC_GameFile()\HashCrc32 	+ Chr(34) + "/>",*Header\Encoding)
		Else
			*Header\CountWrittenEntrys + 1
			WriteStringN(*Header\FileDataW,   #TAB$ +#TAB$ + 
			                                  "<rom name=" + Chr(34) + *Header\Content()\TDC_GameFile()\Name 	+ Chr(34) +
			                                  " size=" + Chr(34) + *Header\Content()\TDC_GameFile()\Size      	+ Chr(34) +
			                                  " crc="  + Chr(34) + *Header\Content()\TDC_GameFile()\HashCrc32 	+ Chr(34) + "/>",*Header\Encoding)							
		EndIf			
		
		
	EndProcedure
	;
	;
	;
	Procedure.i Dat_WriteFile_RomLine(*Header.TDC_Main)
		
		Protected nWritten.i = 0
		ResetList( *Header\Content()\TDC_GameFile() )
		
		;
		;    Allowed DiskImages			CDROMS					 Educational				Games			
		If ( *Header\useSortIMA = #True And *Header\useSortCDR  = #False And *Header\useSortEDU = #True  And *Header\useSortGMS = #False )
			If ListIndex( *Header\Content()\TDC_GameFile()) = 0
				If ( Check_Disk_RAW(*Header) = #True )
				Else	
					ProcedureReturn 
				EndIf
			EndIf	
				
		ElseIf ( *Header\useSortIMA = #True And  *Header\useSortCDR  = #False And *Header\useSortEDU = #False  And *Header\useSortGMS = #True )
			If ListIndex( *Header\Content()\TDC_GameFile()) = 0
				If ( Check_Disk_RAW(*Header) = #True )
				Else	
					ProcedureReturn
				EndIf
			EndIf	
				
		ElseIf ( *Header\useSortIMA = #False And  *Header\useSortCDR  = #True And *Header\useSortEDU = #True  And *Header\useSortGMS = #False )
			If ListIndex( *Header\Content()\TDC_GameFile()) = 0
				If ( Check_CDROM_File(*Header) = #True )
				Else	
					ProcedureReturn
				EndIf
			EndIf
		
		ElseIf ( *Header\useSortIMA = #False And  *Header\useSortCDR  = #True And *Header\useSortEDU = #False  And *Header\useSortGMS = #True )
			If ListIndex( *Header\Content()\TDC_GameFile()) = 0			
				If ( Check_CDROM_File(*Header) = #True )
				Else	
					ProcedureReturn
				EndIf
			EndIf
			
		ElseIf (*Header\useSortEDU = #True And *Header\useSortGMS = #False And  *Header\useSortCDR  = #False And *Header\useSortIMA = #False ) 
			If ListIndex( *Header\Content()\TDC_GameFile()) = 0
				If ( Check_Disk_RAW(*Header) = #False ) Or ( Check_CDROM_File(*Header) = #False )
				Else	
					ProcedureReturn
				EndIf
			EndIf
			
		ElseIf ( *Header\useSortEDU = #False And *Header\useSortGMS = #True And  *Header\useSortCDR  = #False And *Header\useSortIMA = #False )
			If ListIndex( *Header\Content()\TDC_GameFile()) = 0
				If ( Check_Disk_RAW(*Header) = #False ) Or ( Check_CDROM_File(*Header) = #False )
				Else	
					ProcedureReturn
				EndIf
			EndIf
		ElseIf ( *Header\useSortGMS = #False And  *Header\useSortCDR  = #False And *Header\useSortEDU = #False  And *Header\useSortIMA = #False )
			; OK Alles
		EndIf	
		
		ProgressCounter + 1
		
		WriteStringN(*Header\FileDataW,  #TAB$ + "<game name="   + *Header\Content()\Game + ">", *Header\Encoding)		
		WriteStringN(*Header\FileDataW,  #TAB$ +#TAB$ + "<description>" +Trim(*Header\Content()\Game, Chr(34)) + "</description>", *Header\Encoding)
				
		While NextElement( *Header\Content()\TDC_GameFile() )
			
			
			;
			;
			; ClrmamePro unterstützt keine Verzeichnisse angabe mit 0 CRC's
			If ( *Header\Content()\TDC_GameFile()\HashCrc32 = "00000000") And ( Right(*Header\Content()\TDC_GameFile()\Name, 1) = "\" )
				;
				; Verzeichnis Gefunden
				*Header\CountWrittenEntrys + 1
				Continue
			EndIf

			
			
			Dat_WriteFile_CheckDate(*Header)			
			
		Wend	

		;
		; Hierarchie für <game> beendet
		WriteStringN(*Header\FileDataW,  #TAB$ + "</game>", *Header\Encoding)					
		
	EndProcedure
	
	;
	;
	;
	Procedure.i	Dat_WriteFile_Thread(*Header.TDC_Main, useIMA = #False)
		
		Protected.i Result
		If ( *Header > 0)
			
			If ( *Header\FileDataW > 0)
				WriteStringFormat(*Header\FileDataW, *Header\Encoding)
			Else
				;
				; Schreibproblem
				ProcedureReturn #False
			EndIf	
			;
			;
			; Schreibe XML Header
			Result = Dat_WriteFile_XML_Header(*Header)
			If ( Result = #False )
				;
				; Schreibproblem
				ProcedureReturn #False
			EndIf	
			

			;
			;
			; Resete die Datei Liste
			ResetList( *Header\Content() )
			
			If ( *Header\FileDataW > 0)			
				While NextElement( *Header\Content() )
					
					;
					;    Allowed DiskImages			CDROMS					 Educational				Games
					If ( *Header\useSortIMA = #True And *Header\useSortCDR  = #False And *Header\useSortEDU = #True  And *Header\useSortGMS = #False )
						
						If ( Check_Disk(*Header)= #True ) And ( FindString( UCase( *Header\Content()\Game),"EDUCATIONAL"));"[EDUCATIONAL]"))
							;
							; Collect Only Edcuational and DiskImages	
							*Header\CountWrittenTitles + 1
							Dat_WriteFile_RomLine(*Header)
						EndIf	
						
					ElseIf ( *Header\useSortIMA = #True And  *Header\useSortCDR  = #False And *Header\useSortEDU = #False  And *Header\useSortGMS = #True )
						
						If ( Check_Disk(*Header) = #True) And ( Not FindString( UCase( *Header\Content()\Game),"EDUCATIONAL"));"[EDUCATIONAL]"))				                            
							;
							; Collect Only Games and DiskImages	
							*Header\CountWrittenTitles + 1
							Dat_WriteFile_RomLine(*Header)
						EndIf	
						
						
					ElseIf ( *Header\useSortIMA = #False And  *Header\useSortCDR  = #True And *Header\useSortEDU = #True  And *Header\useSortGMS = #False )
						
						If ( Check_CDROM(*Header) = #True ) And ( FindString( UCase( *Header\Content()\Game), "EDUCATIONAL"));"[EDUCATIONAL]"))	
							;
							; Collect Only Edcuational and CDROM
							*Header\CountWrittenTitles + 1
							Dat_WriteFile_RomLine(*Header)
						EndIf	
						
						
					ElseIf ( *Header\useSortIMA = #False And  *Header\useSortCDR  = #True And *Header\useSortEDU = #False  And *Header\useSortGMS = #True )
						
						If ( Check_CDROM(*Header) = #True ) And ( Not FindString( UCase( *Header\Content()\Game),"EDUCATIONAL"));"[EDUCATIONAL]"))	
							;
							; Collect Only Games and CDROM
							*Header\CountWrittenTitles + 1
							Dat_WriteFile_RomLine(*Header)						
						EndIf	
						
					ElseIf (*Header\useSortEDU = #True And *Header\useSortGMS = #False And  *Header\useSortCDR  = #False And *Header\useSortIMA = #False ) 
						
						If ( FindString( UCase( *Header\Content()\Game),"EDUCATIONAL"));"[EDUCATIONAL]"))
							
							If ( Check_Disk(*Header)= #True ) Or ( Check_CDROM(*Header) = #True )
							Else
								;
								; Collect Only Edcuational Software and Installer
								*Header\CountWrittenTitles + 1
								Dat_WriteFile_RomLine(*Header)
							EndIf
						EndIf
						
						
					ElseIf ( *Header\useSortEDU = #False And *Header\useSortGMS = #True And  *Header\useSortCDR  = #False And *Header\useSortIMA = #False )
						
						If ( Not FindString( UCase( *Header\Content()\Game),"EDUCATIONAL"));"[EDUCATIONAL]"))
							
							If ( Check_Disk(*Header)= #True ) Or ( Check_CDROM(*Header) = #True )
								Else								
								;
								; Collect Only Games Software and Installer
								*Header\CountWrittenTitles + 1
								Dat_WriteFile_RomLine(*Header)
							EndIf					
						EndIf	
						
						
					ElseIf ( *Header\useSortGMS = #False And  *Header\useSortCDR  = #False And *Header\useSortEDU = #False  And *Header\useSortIMA = #False )
						;
						;
						; Alles
						*Header\CountWrittenTitles + 1
						Dat_WriteFile_RomLine(*Header)
						
					Else
						MessageRequester( "Total DOS Collection", "Achtung: Nicht Konvertiert" + #CRLF$ +  *Header\Content()\Game )
					EndIf	
					
				Wend	
				
				;
				;
				; Hierarchie für <game> beendet			
				WriteStringN(*Header\FileDataW,  "</datafile>", *Header\Encoding)
	
			EndIf
			
		EndIf
		
	EndProcedure	
	;
	;
	;
	Procedure.i	Dat_WriteFile_Standard(*Header.TDC_Main, File.s = "", ProgressID.i = 0, GadgetID_GameName.i = 0)
		
		
		If IsGadget( GadgetID_GameName)
			SetGadgetText(GadgetID_GameName, "Speichere ..." )	
		EndIf	
		;
		;
		; Schreibe das Encofings Format
		*Header\FileDataW = CreateFile( #PB_Any,  Dat_WriteFile_NewFileName(*Header , File) )
		*Header\_thread	= 0

		
		If IsGadget(ProgressID)
			SetGadgetAttribute(ProgressID, #PB_ProgressBar_Minimum,1 )
			SetGadgetAttribute(ProgressID, #PB_ProgressBar_Maximum, *Header\CountGames)				
		EndIf
		
		*Header\_thread  = CreateThread(@Dat_WriteFile_Thread(),*Header)   		   		            
		If *Header\_thread  > 0			
			
			While IsThread(*Header\_thread )
				
				Delay( 5 )
				;
				;
				; Gadget Support						
				If IsGadget(ProgressID)
					SetGadgetState(ProgressID, ProgressCounter ):
				EndIf					
				
				ProgramEventID = WindowEvent()    
				If ( ProgramEventID )
					
				EndIf
				
			Wend   
			;
			;
			; Gadget Support				
			If IsGadget( GadgetID_GameName)
				SetGadgetText(GadgetID_GameName, "Konvertierung und Gespeichert als ClrMamePro Format ... (Geschrieben: "+ *Header\CountWrittenTitles+"/"+*Header\CountWrittenEntrys+")" )	
			EndIf					
			
			If IsGadget(ProgressID)
				SetGadgetState(ProgressID, 0 )
			EndIf	
			
		EndIf
		
		CloseFile(*Header\FileDataW )		
		
		
	EndProcedure
	;
	;
	;	
	Procedure.i Dat_WriteFile(*Header.TDC_Main, File.s = "", useDate.i = #False, useDateLong.i = #False, UseSort.i = #False, ProgressID.i = 0, GadgetID_GameName.i = 0)
		
		
		Protected.s szNewFile, HeaderDecription, szCategory
		Protected.i isDate, isDateLong
		
		Debug "Write Conversion"
		
		If ( *Header > 0)
			
			*Header\useDate	  = useDate
			*Header\useDateLong = useDateLong
			*Header\CountWrittenTitles = 0
			*Header\CountWrittenEntrys = 0			
			
			If ( UseSort = #False )	
				
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... (Fasse alle Titel in einer DAT zusammen)" )	
				EndIf	
								
				*Header\useSortGMS = #False
				*Header\useSortCDR = #False
				*Header\useSortEDU = #False
				*Header\useSortIMA = #False 
				Dat_WriteFile_Standard(*Header, File, ProgressID, GadgetID_GameName)
												
			Else
				
				HeaderDecription = *Header\Decription
				isDate 	     = *Header\useDate
				isDateLong	     = *Header\useDateLong	
				
				;---------------------------------------------------------------------------------
				;
				; 				
				szCategory = "[ TDC Ver."+*Header\Version+" ]( Educational - Floppy [IMA][IMG][RAW][SCP][TD0] )"
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... "+szCategory )	
				EndIf
				
				*Header\Decription = HeaderDecription + "-" + szCategory
				*Header\useDate	  = #False
				*Header\useDateLong = #False
				
				*Header\useSortGMS = #False
				*Header\useSortCDR = #False
				*Header\useSortEDU = #True
				*Header\useSortIMA = #True
												
				szNewFile = ReplaceString( UCase( File ), ".DAT", "-" + szCategory + ".DAT" )				
				Dat_WriteFile_Standard(*Header, szNewFile, ProgressID, GadgetID_GameName)
				
				*Header\_thread = 0
					 
				;---------------------------------------------------------------------------------
				;
				; 
				szCategory = "[ TDC Ver."+*Header\Version+" ]( Games - Floppy [IMA][IMG][RAW][SCP][TD0] )"				
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... "+szCategory )	
				EndIf
				
				*Header\Decription = HeaderDecription + "-" + szCategory
				*Header\useDate	  = #False
				*Header\useDateLong = #False				
				*Header\useSortGMS = #True
				*Header\useSortCDR = #False
				*Header\useSortEDU = #False
				*Header\useSortIMA = #True
				
				szNewFile = ReplaceString( UCase( File ), ".DAT", "-" + szCategory + ".DAT" )					
				Dat_WriteFile_Standard(*Header, szNewFile, ProgressID, GadgetID_GameName)	
				
				*Header\_thread = 0
					 
				;---------------------------------------------------------------------------------
				;
				;
				szCategory = "[ TDC Ver."+*Header\Version+" ]( Educational - CDRoms [ISO][BIN][CCD][NRG][MDF] )"				
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... "+szCategory )	
				EndIf
				
				*Header\Decription = HeaderDecription + "-" + szCategory				
				*Header\useDate	  = #False
				*Header\useDateLong = #False				
				*Header\useSortGMS = #False
				*Header\useSortCDR = #True
				*Header\useSortEDU = #True
				*Header\useSortIMA = #False
				
				szNewFile = ReplaceString( UCase( File ), ".DAT", "-" + szCategory + ".DAT" )					
				Dat_WriteFile_Standard(*Header, szNewFile, ProgressID, GadgetID_GameName)
				
				*Header\_thread = 0
					
				;---------------------------------------------------------------------------------
				;
				; 
				szCategory = "[ TDC Ver."+*Header\Version+" ]( Games - CDRoms [ISO][BIN][CCD][NRG][MDF] )"
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... "+szCategory )	
				EndIf
				
				*Header\Decription = HeaderDecription + "-" + szCategory
				*Header\useDate	  = #False
				*Header\useDateLong = #False				
				*Header\useSortGMS = #True
				*Header\useSortCDR = #True
				*Header\useSortEDU = #False
				*Header\useSortIMA = #False				
				
				szNewFile = ReplaceString( UCase( File ), ".DAT", "-" + szCategory + ".DAT" )					
				Dat_WriteFile_Standard(*Header, szNewFile, ProgressID, GadgetID_GameName)	
				
				*Header\_thread = 0
				
				;---------------------------------------------------------------------------------
				;
				;
				szCategory = "[ TDC Ver."+*Header\Version+" ]( Educational - Software [RIP][INSTALLS][LOSE FILES] )"				
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... "+szCategory )	
				EndIf
				
				*Header\Decription = HeaderDecription + "-" + szCategory
				*Header\useDate	  = isDate
				*Header\useDateLong = isDateLong				
				*Header\useSortGMS = #False
				*Header\useSortCDR = #False
				*Header\useSortEDU = #True
				*Header\useSortIMA = #False				
				
				szNewFile = ReplaceString( UCase( File ), ".DAT", "-" + szCategory + ".DAT" )					
				Dat_WriteFile_Standard(*Header, szNewFile, ProgressID, GadgetID_GameName)	
				
				*Header\_thread = 0
				
				;---------------------------------------------------------------------------------
				;
				;
				szCategory = "[ TDC Ver."+*Header\Version+" ]( Games - Software [RIP][INSTALLS][LOSE FILES] )"					
				If IsGadget( GadgetID_GameName)
					SetGadgetText(GadgetID_GameName, "Speichere ... "+szCategory )	
				EndIf
				
				*Header\Decription = HeaderDecription + "-" + szCategory
				*Header\useDate	  = isDate
				*Header\useDateLong = isDateLong					
				*Header\useSortGMS = #True
				*Header\useSortCDR = #False
				*Header\useSortEDU = #False
				*Header\useSortIMA = #False				
				
				szNewFile = ReplaceString( UCase( File ), ".DAT", "-" + szCategory + ".DAT" )					
				Dat_WriteFile_Standard(*Header, szNewFile, ProgressID, GadgetID_GameName)
			EndIf	
			ProcedureReturn *Header	
		EndIf	
	
	EndProcedure
	;
	;
	;
	Procedure.i	Dat_Convert(*Header.TDC_Main)
		
		Protected.i isHeader = #False,  isStart = #True, isGame = #False, isGameData = #False
		Protected.s szLine
		
		If *Header = 0
			Debug "Read Database - Problem"
		EndIf
		
		If ( *Header\FileDataR > 0)
			Debug "Read Database"
			
			;*Header\Encoding = ReadStringFormat(*Header\FileDataR)
			
			*Header\Encoding = #PB_UTF8
			
			While Eof(*Header\FileDataR) = 0
				
				szLine = ReadString(*Header\FileDataR, *Header\Encoding)
				
				If ( Len(szLine) = 0 )
					Continue
				EndIf
				;
				;
				; Sammle Game Titel (Dateinamen)
				If ( IsGame )
					isHeader = #False
					
					isGameData = Game_Store_Name(*Header\Content(), szLine.s, *Header)
					If isGameData
						IsGame = #False
						Continue
					EndIf	
				EndIf
				;
				;
				; Sammle Spiel Dateien (File/ Rom)
				If isGameData
					isGame = #False
					isGameData = Game_Store_Data(*Header\Content(), szLine.s, *Header)
					Continue
				EndIf	
				;
				;
				; Sammle header Information
				If ( isHeader )
					isHeader = Header_Store(*Header, szLine)
					Continue
				EndIf				 
				
				isHeader = Header_Main(*Header, szLine)								
				isGame   = Game_Check (szLine)										
			Wend	
			
			CloseFile(*Header\FileDataR)
			
			Debug "Read Database - Finsished"
		EndIf

	EndProcedure
	;
	;
	; Module um TDC Dat Dateien nach ClrmamePro zu Konvertieren
	Procedure.i Dat_OpenFile(File.s, GadgetID_CountGames.i = 0, GadgetID_CountFiles.i = 0, GadgetID_GameName.i = 0)
		
		*Header.TDC_Main = AllocateStructure( TDC_Main )
		*Header\File = GetFilePart( File )
		*Header\Path = GetPathPart( File )		
		
		NewList *Header\Content.TDC_GameName()
		
		*Header\Category = "TDC"   		
		*Header\FileDataR = ReadFile( #PB_Any, *Header\Path + *Header\File)
		
		ProgressCounter = 0
		
		
		*Header\useDate = #False
		*Header\useDateLong = #False
		
		*Header\_thread  = CreateThread(@Dat_Convert(),*Header)   		   		            
		If *Header\_thread  > 0			
			
			While IsThread(*Header\_thread )
				
				Delay(255)
				;
				;
				; Gadget Support					
				If IsGadget(GadgetID_CountGames)
					SetGadgetText( GadgetID_CountGames , "Spiele : " + Str( *Header\CountGames) )	
				EndIf	
				
				If IsGadget(GadgetID_CountFiles)
					SetGadgetText( GadgetID_CountFiles , "Dateien: " + Str( *Header\CountRoms) )	
				EndIf	
				
				If IsGadget(GadgetID_GameName)
					SetGadgetText( GadgetID_GameName ,  *Header\Content()\Game )	
				EndIf								
				
				ProgramEventID = WindowEvent()    
				If ( ProgramEventID )
					
				EndIf
				
			Wend   
			
			;
			;
			; Gadget Support				
			If IsGadget(GadgetID_GameName)
				SetGadgetText( GadgetID_GameName ,  "DAT Konvertierung beendet und vorbereitet zum Speichern .... " )

			EndIf				
		EndIf
		ProcedureReturn *Header
		
	EndProcedure	
	;
	;
	;
	Procedure.i Dat_Listing(*Header.TDC_Main, ListGadgetID.i = 0)
		Protected FileList.i
		;
		;
		; Support Listview Gadget
		If ( *Header > 0 ) And IsGadget( ListGadgetID )
			
			ResetList( *Header\Content() )
						
			While NextElement( *Header\Content() )								
				AddGadgetItem( ListGadgetID, -1, *Header\Content()\Game)	
				
				ResetList( *Header\Content()\TDC_GameFile() )
				FileList = ListSize ( *Header\Content()\TDC_GameFile() )
				If ( FileList = 0 )
					MessageRequester( "Total DOS Collection", "Achtung: Keine Dateien bei Titel" + #CRLF$ +  *Header\Content()\Game )
				EndIf	
			Wend	
		EndIf
		
	EndProcedure	
	
	
EndModule

CompilerIf #PB_Compiler_IsMainFile
	
	
	Define *TDCContent, ThreadID.i, CountGames.i
	
	Enumeration FormWindow
	  #Window_0
	EndEnumeration
		
	Enumeration FormGadget
		#Button_0
		#Button_1		
		#Button_2
		#Button_3
		#Button_4
		#Button_5
		#Button_6
		#ProgressBar_0		
		#ListView_0
		#Text_0
		#Text_1
		#Text_2
	EndEnumeration
		
	Enumeration FormFont
		#Font_Window_0_1
	EndEnumeration
		
	LoadFont(#Font_Window_0_1,"Segoe UI", 10)	
	
	
	;
	;
	; --------------------------------------------------------------------------------------------------------------	
	Procedure 	TDC_Convert_Open(*TDCContent)
		Protected.s FileName,  Pattern
		
		Pattern = "TDC Data (*.dat)|*.dat|Alle Dateien (*.*)|*.*"		
		FileName = OpenFileRequester("Total DOS Collection DAT","",Pattern,0)
		
		If ( FileName ) 
			
			ClearGadgetItems( #ListView_0 )
			
			SetGadgetText( #Text_0 , "Spiele : 0")
			SetGadgetText( #Text_1 , "Dateien: 0")			
			SetGadgetText( #Text_2 , "")	
			SetGadgetAttribute(#ProgressBar_0, #PB_ProgressBar_Minimum,1)
			SetGadgetAttribute(#ProgressBar_0, #PB_ProgressBar_Maximum,1)
				
			*TDCContent = TDCDAT::Dat_OpenFile(FileName, #Text_0, #Text_1, #Text_2)			
			
			If *TDCContent > 0
				
				TDCDAT::Dat_Listing(*TDCContent, #ListView_0)
				
				ProcedureReturn *TDCContent
			EndIf
		
		EndIf			
		ProcedureReturn 0
	EndProcedure
	;
	;
	; --------------------------------------------------------------------------------------------------------------
	Procedure TDC_Convert_Write(*TDCContent, useDate.i = #False, useDateLong.i = #False, useSort.i = #False)
		
		Protected.s FileName,  Pattern
		
		Pattern = "TDC Data (*.dat)|*.dat|Alle Dateien (*.*)|*.*"		
		FileName = SaveFileRequester("Total DOS Collection DAT","ClrMamePro.DAT",Pattern,0)
		If ( FileName ) 
			;
			;
			TDCDAT::Dat_WriteFile(*TDCContent, FileName, useDate, useDateLong, useSort, #ProgressBar_0, #Text_2)

		EndIf		
	EndProcedure
	
	;
	;
	; --------------------------------------------------------------------------------------------------------------
	
		
	Procedure OpenWindow_0(x = 0, y = 0, width = 600, height = 426)
		OpenWindow(#Window_0, x, y, width, height, "Total DOS Collection DAT 2 ClrmamePro DAT Konvertierung", #PB_Window_SystemMenu| #PB_Window_ScreenCentered)
		
		ButtonGadget(#Button_0, 4, 378, 116, 28, "Öffne TDC Dat")
	  	ButtonGadget(#Button_1, 130, 364, 130, 28, "Speichern")		
  		ButtonGadget(#Button_2, 266, 364, 160, 28, "Speichern ( Datum )")
  		ButtonGadget(#Button_3, 432, 364, 160, 28, "Speichern ( Stempel )")	  	
  		
  		ButtonGadget(#Button_4, 130, 394, 130, 28, "Speichern (S)")
  		ButtonGadget(#Button_5, 266, 394, 160, 28, "Speichern (S|Datum)")
  		ButtonGadget(#Button_6, 432, 394, 160, 28, "Speichern (S|Stempel)")  		
  		
	  	ProgressBarGadget(#ProgressBar_0, 0, 316, 600, 8, 0, 0)

	  	ListViewGadget(#ListView_0, 0, 28, 600, 286)
	  		  	
	  	TextGadget(#Text_0, 32, 332, 224, 28, "")	  	
	  	TextGadget(#Text_1, 334, 334, 228, 28, "")
	  	TextGadget(#Text_2, 0, 5, 600, 18, "")
	  	
	  	SetGadgetFont(#Button_0, FontID(#Font_Window_0_1))
	  	SetGadgetFont(#Button_1, FontID(#Font_Window_0_1))	
	  	SetGadgetFont(#Button_2, FontID(#Font_Window_0_1))
	  	SetGadgetFont(#Button_3, FontID(#Font_Window_0_1))
	  	SetGadgetFont(#Button_4, FontID(#Font_Window_0_1))	
	  	SetGadgetFont(#Button_5, FontID(#Font_Window_0_1))
	  	SetGadgetFont(#Button_6, FontID(#Font_Window_0_1))
	  	
	  	SetGadgetFont(#Text_0, FontID(#Font_Window_0_1))
	  	SetGadgetFont(#Text_1, FontID(#Font_Window_0_1))	
	  	SetGadgetFont(#Text_2, FontID(#Font_Window_0_1))	
	  		
		SetGadgetText( #Text_0 , "Spiele : 0")
		SetGadgetText( #Text_1 , "Dateien: 0")			
		SetGadgetText( #Text_2 , "")	
		SetGadgetAttribute(#ProgressBar_0, #PB_ProgressBar_Minimum,1)
		SetGadgetAttribute(#ProgressBar_0, #PB_ProgressBar_Maximum,1)
		
		GadgetToolTip(#Button_0, "Total DOS Collection DAT Öffnen")
		GadgetToolTip(#Button_1, "Als ClrMamePro DAT Speichern")
		GadgetToolTip(#Button_2, "Als ClrMamePro DAT Speichern Nur mit Datei Jahres Datum")
		GadgetToolTip(#Button_3, "Als ClrMamePro DAT Speichern komplett mit Datei Zeitstempel")
		GadgetToolTip(#Button_4, "Als ClrMamePro DAT Speichern. Aufgeteilt in 6 DAT Dateien")
		GadgetToolTip(#Button_5, "Als ClrMamePro DAT Speichern. Aufgeteilt in 6 DAT Dateien.  Nur mit Datei Jahres Datum für lose Dateien")	
		GadgetToolTip(#Button_6, "Als ClrMamePro DAT Speichern. Aufgeteilt in 6 DAT Dateien.  Mit Datei Zeitstempel für lose Dateien")			
	EndProcedure	
	
	
	OpenWindow_0()
	
	Repeat
		
		EventID = WaitWindowEvent()
	
		Select EventID

			Case #PB_Event_Gadget
				Select EventGadget()
					Case #Button_0 :
						*TDCContent = TDC_Convert_Open(*TDCContent)
						If *TDCContent > 0
	
						EndIf	
						
            			Case #Button_1 :
            				If *TDCContent > 0
            					TDC_Convert_Write(*TDCContent)             					
            				EndIf	
            			Case #Button_2 :
            				If *TDCContent > 0
            					TDC_Convert_Write(*TDCContent, #True)             					
            				EndIf  
            			Case #Button_3 :
            				If *TDCContent > 0
            					TDC_Convert_Write(*TDCContent, #False, #True)             					
            				EndIf 
            			Case #Button_4 :
            				If *TDCContent > 0
            					TDC_Convert_Write(*TDCContent,#False,#False,#True)             					
            				EndIf	
            			Case #Button_5 :
            				If *TDCContent > 0
            					TDC_Convert_Write(*TDCContent, #True,#False,#True)           					
            				EndIf  
            			Case #Button_6 :
            				If *TDCContent > 0
            					TDC_Convert_Write(*TDCContent, #False, #True,#True)             					
            				EndIf            				
				EndSelect
         		EndSelect
         		
		
		If EventID = #PB_Event_CloseWindow
			End
		EndIf
	ForEver
	
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 750
; FirstLine = 409
; Folding = DQ9-P+
; EnableAsm
; EnableThread
; EnableXP
; Executable = ClassEX_DAT_2_ ClrMamePro_TDC.exe
; DisableDebugger
; EnablePurifier