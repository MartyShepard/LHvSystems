; Mame CHD Manager
; Komprimiere: "40 Winks (ES) [!][SLES-01941].cue"
; 
; 
; chdman - MAME Compressed Hunks of Data (CHD) manager 0.223 (mame0223)
; Output CHD:   O:\Retro Playstation\Sony PlayStation PAL - 0-9\\40 Winks (ES) [!][SLES-01941].cue.chd
; Input file:   40 Winks (ES) [!][SLES-01941].cue
; Input tracks: 1
; Input length: 52:05:08
; Compression:  cdlz (CD LZMA), cdzl (CD Deflate), cdfl (CD FLAC)
; Logical size: 573,772,032
; Compression complete ... final ratio = 65.6%
; 
; 
; chdman - MAME Compressed Hunks of Data (CHD) manager 0.223 (mame0223)
; Raw SHA1 verification successful!
; Overall SHA1 verification successful!
; 
; Drücken Sie eine beliebige Taste . . .

; ========================================================================================================
;
; 

; CHD Info
; 
; chdman - MAME Compressed Hunks of Data (CHD) manager 0.223 (mame0223)
; Input file:   O:\Retro Playstation\Sony PlayStation PAL - 0-9\\3D Lemmings (EU) (MT)[!][SCES-00009].cue.chd
; File Version: 5
; Logical size: 567,475,776 bytes
; Hunk Size:    19,584 bytes
; Total Hunks:  28,977
; Unit Size:    2,448 bytes
; Total Units:  231,812
; Compression:  cdlz (CD LZMA), cdzl (CD Deflate), cdfl (CD FLAC)
; CHD size:     355,822,495 bytes
; Ratio:        62.7%
; SHA1:         3df567cf15ae0cbdb065376a7b8dc27bf6a51880
; Data SHA1:    da86d92c2110470787db51cd25cbac8f3bc0e521
; Metadata:     Tag='CHT2'  Index=0  Length=92 bytes
;               TRACK:1 TYPE:MODE2_RAW SUBTYPE:NONE FRAMES:81624 PREGAP:0 PG
; Metadata:     Tag='CHT2'  Index=1  Length=90 bytes
;               TRACK:2 TYPE:AUDIO SUBTYPE:NONE FRAMES:7543 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=2  Length=90 bytes
;               TRACK:3 TYPE:AUDIO SUBTYPE:NONE FRAMES:6630 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=3  Length=90 bytes
;               TRACK:4 TYPE:AUDIO SUBTYPE:NONE FRAMES:7069 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=4  Length=90 bytes
;               TRACK:5 TYPE:AUDIO SUBTYPE:NONE FRAMES:6717 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=5  Length=90 bytes
;               TRACK:6 TYPE:AUDIO SUBTYPE:NONE FRAMES:6510 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=6  Length=90 bytes
;               TRACK:7 TYPE:AUDIO SUBTYPE:NONE FRAMES:6237 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=7  Length=90 bytes
;               TRACK:8 TYPE:AUDIO SUBTYPE:NONE FRAMES:6370 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=8  Length=90 bytes
;               TRACK:9 TYPE:AUDIO SUBTYPE:NONE FRAMES:6517 PREGAP:150 PGTYP
; Metadata:     Tag='CHT2'  Index=9  Length=91 bytes
;               TRACK:10 TYPE:AUDIO SUBTYPE:NONE FRAMES:6786 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=10  Length=91 bytes
;               TRACK:11 TYPE:AUDIO SUBTYPE:NONE FRAMES:7991 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=11  Length=91 bytes
;               TRACK:12 TYPE:AUDIO SUBTYPE:NONE FRAMES:7809 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=12  Length=91 bytes
;               TRACK:13 TYPE:AUDIO SUBTYPE:NONE FRAMES:6206 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=13  Length=91 bytes
;               TRACK:14 TYPE:AUDIO SUBTYPE:NONE FRAMES:6287 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=14  Length=91 bytes
;               TRACK:15 TYPE:AUDIO SUBTYPE:NONE FRAMES:7291 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=15  Length=91 bytes
;               TRACK:16 TYPE:AUDIO SUBTYPE:NONE FRAMES:6735 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=16  Length=91 bytes
;               TRACK:17 TYPE:AUDIO SUBTYPE:NONE FRAMES:6587 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=17  Length=91 bytes
;               TRACK:18 TYPE:AUDIO SUBTYPE:NONE FRAMES:6393 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=18  Length=91 bytes
;               TRACK:19 TYPE:AUDIO SUBTYPE:NONE FRAMES:6653 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=19  Length=91 bytes
;               TRACK:20 TYPE:AUDIO SUBTYPE:NONE FRAMES:6407 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=20  Length=91 bytes
;               TRACK:21 TYPE:AUDIO SUBTYPE:NONE FRAMES:6537 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=21  Length=91 bytes
;               TRACK:22 TYPE:AUDIO SUBTYPE:NONE FRAMES:5439 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=22  Length=91 bytes
;               TRACK:23 TYPE:AUDIO SUBTYPE:NONE FRAMES:4715 PREGAP:150 PGTY
; Metadata:     Tag='CHT2'  Index=23  Length=91 bytes
;               TRACK:24 TYPE:AUDIO SUBTYPE:NONE FRAMES:4715 PREGAP:150 PGTY
; 
; chdman - MAME Compressed Hunks of Data (CHD) manager 0.223 (mame0223)
; Raw SHA1 verification successful!
; Overall SHA1 verification successful!
; 
; Drücken Sie eine beliebige Taste . . .

DeclareModule CHD
	
	Declare		Compress()
	Declare		Start_Manager()
	Declare.s	Set_UtilityPath()

	Declare.s 	MessagesRequest(UserInfo.i = 0, szStringA$ = "", szStringB$ = "")
	
	Structure ISO_STRUCT
            CueFileList.s{4096}
            BinFileList.s{4096}
            TocFileList.s{4096}
            GdiFileList.s{4096} 
    EndStructure  
        
    Global NewList ISOFileList.ISO_STRUCT()
    Global NewList ISOFileCount.ISO_STRUCT()
    Global NewList ISOFileErros.ISO_STRUCT() 
    
    Declare szLineSplit(sText.s, sChar$, RemoveChar.i = #False)
EndDeclareModule

Module CHD    
	
    Structure PROCESS_BASIC_INFORMATION
        ExitStatus.i
        PebBaseAddress.i
        AffinityMask.i
        BasePriority.i
        UniqueProcessId.i
        InheritedFromUniqueProcessId.i
    EndStructure

    Structure PROGRAM_BOOT
        Program.s
        PrgPath.s
        DstPath.s
        Command.s
        Logging.s
        PrgFlag.l
        ExError.i  
        StError.s
        IsoFile.s
        CHDFile.s
        LoProcess.l
        HiProcess.l
        Semaphore.i
        Thread.i
        bVersion.i
        bInputFile.i
        bInputTracks.i 
        bInputLength.i
        bCompression.i 
        bLogicalSize.i
        exitCodeLo.c
        exitCodeHi.c
        PrgMutex.l
        PrgThread.l
        ForceBreak.i
        bInfo.i
        bInfoVersion.i
        bInfoRatio.i
        bInfoRawSHA1.i
        bInfoDtaSHA1.i
        szVersion.s
        szRatio.s        
        szRawSHA1.s        
        szDtaSHA1.s
        List szSplittetList.s ()
    EndStructure    
    
    Structure tChar
       StructureUnion
          c.c
          s.s { 1 }
       EndStructureUnion
    EndStructure
   
    Global MainEventMutex = CreateMutex()
    
    Global szScrollAreaMessage$
    Global ComplettSourceSize.q
    Global NewList szSplittetList.s()
    ;****************************************************************************************************************************************************************
    ; Macros für den Thread um diesen in Falle eines Falles zu unterbrechen
    ;________________________________________________________________________________________________________________________________________________________________    
    Macro KeyIsDown(key)
        Bool(GetAsyncKeyState_(key) & $8000)
    EndMacro    
    Macro KeyIsUp(key)
        Bool(Not (GetAsyncKeyState_(key) & $8000))
    EndMacro
    ;
	;
    ; Splittet die Ausgabe der Commandline
    Procedure 	szLineSplit(sText.s, sChar$, RemoveChar.i = #False)
    	Protected nLines.l , lCounter.l , iMax, *Source .tChar, nCharsPerLine.w
    	
;         If ( ListSize(  LinkedList() ) > 0 )
;             Debug ListSize( LinkedList() )            
;             ResetList( LinkedList() )
;             
;             While NextElement( LinkedList() )
;                 Debug LinkedList()
;             Wend 
;             
;             ResetList( LinkedList() )
;     	EndIf
    			    
    	iMax = CountString(sText,sChar$)
    	
    	If ( iMax = 0 ) And ( Len(sText) = 0 ) : ProcedureReturn: EndIf       
    	
    	If ( Len(sText) >= 1 )
    		
    	    For i = 1 To iMax+3
    	        Delay(1000)
    			index$ = StringField(sText, i, sChar$) :lCounter = 0               
    			
    			*Source.tChar   = @index$                
    			nCharsPerLine.w = Len ( index$ )
    			
    			If nCharsPerLine.w <> 0                               
    				nLines.l = Len ( index$ ) / nCharsPerLine  
    			EndIf
    			
    			If ( *Source\c <> 0 )
;     			    If ( ListSize(  LinkedList() ) > 0 )
;     			        ResetList( LinkedList() )
;     			        
;                         While NextElement( LinkedList() )
;                             Debug "szLineSplit :: DEBUG :: " + LinkedList()
;                         Wend 
;             
;                         ResetList( LinkedList() )    			        
;     			    EndIf
    			    AddElement ( szSplittetList() )    			  
    				While *Source\c
   					 
    					If nCharsPerLine - 1 < lCounter
    						AddElement ( szSplittetList() )                           
    						lCounter = 0
    					EndIf
    					
    					szSplittetList() + *Source\s
    					lCounter + 1
    					*Source  + SizeOf ( CHARACTER )
    				Wend 
    			EndIf
    		Next
    	EndIf
    	
    	;CopyList( sLits(), LinkedList() )
    	;FreeList( sLits())
    	ProcedureReturn #True
    EndProcedure
    ;	
	; Informations Fenster Öffnen
	;
	Procedure	uiGenerateWindow()
		
		Structure MONITORINFOEXA
            cbSize.l
            rcMonitor.RECT
            rcWork.RECT
            dwFlags.l
            szDevice.s {#CCHDEVICENAME}
        EndStructure
        
        Define MonitorInfo.MONITORINFOEXA
        Protected X.i  = 0
        Protected Y.i  = 0
        Protected H.i = 276
        Protected W.i = 480
        Protected F.l = FontID(Fonts::#_FIXPLAIN7_12)
        Protected t.l = FontID(Fonts::#_DROIDSANS_11)
        MonitorInfo\cbSize = SizeOf(MonitorInfo)
        
		GetMonitorInfo_(DesktopEX::MonitorInfo_Display_GetPrimary(DC::#_Window_001), @MonitorInfo)
		
		X = ( MonitorInfo\rcWork\right  - W) - 4
		Y = ( MonitorInfo\rcWork\bottom - H) - 4
		
		WinGuru::Style(DC::#_Window_005, X, Y, W, H, #PB_Window_BorderLess|#PB_Window_Invisible, $000000, #True, #True, #True, #Null, #False, #True, WindowID(DC::#_Window_001), $3A3C3B)
		WinGuru::SetTransparenz(DC::#_Window_005,230)
		
		;
		; Versteckter Text Gadget umd die Länge eines Textes zu errechnen
		FORM::TextObject(DC::#Text_024, 0, 0 , 0, 0, t,$0,$0,"")
		HideGadget(DC::#Text_024,1)
		
		FORM::TextObject(DC::#Text_023, 5, 10 , W - 10, 18, F,$04F8FF,$3A3C3B,"")
		
		ScrollAreaGadget(DC::#ScrollArea_002, 5, 32, W - 10, H - ( 32 + 32), W - 36, 0, 1, #PB_ScrollArea_BorderLess)
		SetGadgetColor(DC::#ScrollArea_002, #PB_Gadget_BackColor,$000000)
		
			FORM::TextObject(DC::#Text_022, 2, 0, 9999, 9999 , F,$B5852A,$000000,"")
			CloseGadgetList()
			
		FORM::TextObject(DC::#Text_021, 5, WindowHeight(DC::#_Window_005)-22 , W - 10, 18, F,$04F8FF,$3A3C3B,"",#PB_Text_Center)
			
		SetGadgetText(DC::#Text_021,"")
		SetGadgetText(DC::#Text_022,"")	
		SetGadgetText(DC::#Text_023,"")
		SetGadgetText(DC::#Text_024,"")			
	EndProcedure
    ;
	;
    ; Lösche Structuriekten Inhalt
	Procedure	FileList_Clear()
		
		If ( ListSize( ISOFileList.ISO_STRUCT() ) >= 1 )
			ClearList( ISOFileList.ISO_STRUCT() ) 
		EndIf
		If ( ListSize( ISOFileCount.ISO_STRUCT() ) >= 1 )
			ClearList( ISOFileCount.ISO_STRUCT() ) 
		EndIf
		If ( ListSize( ISOFileErros.ISO_STRUCT() ) >= 1 )
			ClearList( ISOFileErros.ISO_STRUCT() ) 
		EndIf		
	EndProcedure
	;
	;
	; Verschiedene Requester
	Procedure.s MessagesRequest(UserInfo.i = 0, szStringA$ = "", szStringB$ = "")
		
		Protected szMsg0$ = "Now Look What You've Done": 
		Protected szMsg1$ = ""
		Protected szMsg2$ = ""
		
		
		Select ( Windows::Get_Language() )
				;_____________________________________________________________________________
				;
				; German Language
			Case 407
				Select ( UserInfo.i )
					Case 1
						szMsg1$ = "CHDMan? ... wo is?"
						szMsg2$ = "Das Programm CHDman konnt nicht gefunden werden" +#CR$+
						          "Liegt dem Mame Packet bei und kann optional mit" +#CR$+
						          "dem Menüpunkt unter 'CHD Options'eingerichtet"   +#CR$+
						          "werden."
						
					Case 2
						szMsg1$ = "Nichts zu tun.."
						szMsg2$ = "Keine Dateien gefunden die man Komprimieren Könnte.."
						
					Case 3
						szMsg1$ = "CUE Datei Fehler"
						szMsg2$ = "Konnte die CUE-Datei " + szStringA$ + " nicht öffnen."
						
					Case 4
						szMsg1$ = "CUE Datei Fehler"
						szMsg2$ = "Konnte die CUE-Datei " + szStringA$ + " nicht lesen."
						
					Case 5
						szMsg1$ = "Binary Datei Nicht Gefunden"
						szMsg2$ = "Konnte die BIN-Datei " + szStringA$ +" nicht Finden."
						
					Case 6
						szMsg1$ = "CUE Sheet Lese Fehler"
						szMsg2$ = "Konnte das Ende des Binary Dateinamens nicht ermitteln."
						
					Case 7
						szMsg1$ = "CUE Sheet Lese Fehler"
						szMsg2$ = "Konnte den Anfang des Binary Dateinamens nicht ermitteln."
						
					Case 8
						szMsg1$ = "CUE Sheet Info"
						szMsg2$ = "Konnte kein Binary Dateinamen ermitteln."
						
					Case 9
						szMsg1$ = "Kein Zielverzeichnis"
						szMsg2$ = "Konnte das Zielverzeichnis nicht ermitteln."						
					;
					;
					; Messages ohne Requester
					Case 50	: ProcedureReturn "Komprimiere Image ..." + szStringA$
					Case 51 : ProcedureReturn "-[ Fertig ]-"
					Case 52 : ProcedureReturn ")- [- Abbruch -] -("	
					Case 53 : ProcedureReturn "Öffne CUE File .."
					Case 54	: ProcedureReturn "Bitte Warten. M.A.M.E. CHD Tool Komprimiert .."
					Case 55 : ProcedureReturn "Überprüfe ... Bitte Warten"
						
				EndSelect		
				
				;_____________________________________________________________________________
				;
				; English Default
			Default
				Select ( UserInfo.i )
					Case 1
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 2
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 3
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 4
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 5
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 6
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 7
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"
					Case 8
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"						
					Case 9
						szMsg1$ = "Missing Translation (Note 0)"
						szMsg2$ = "Missing Translation (Note 0)"						
					;
					;
					; Messages ohne Requester
					Case 50	: ProcedureReturn "Compress Image ..."
					Case 51 : ProcedureReturn "-[ Finished ]-"
					Case 52 : ProcedureReturn ")- [- Abort -] -("
					Case 53 : ProcedureReturn "Open CUE Sheet File .."
					Case 54	: ProcedureReturn "Please Wait. M.A.M.E. CHD Tool is Compressing .."						
                    Case 55 : ProcedureReturn "Verfiy ... Please Wait"					    
				EndSelect		
		EndSelect	

		Request::MSG(szMsg0$, szMsg1$ ,szMsg2$ ,2 , 1, ProgramFilename(), 0, 0, DC::#_Window_001)
        ProcedureReturn ""                	
	EndProcedure
	;
	;
	; Überprüfung des CHDman Tool
	Procedure	VerifyToolPath()
		
		If (FileSize( CFG::*Config\CHDszPath ) >= 2000000 )
			
			;
			; OK
							Debug CFG::*Config\CHDszPath
		Else
			If (FileSize( GetPathPart(ProgramFilename()) + "chdman.exe" ) >= 2000000 )
				
				CFG::*Config\CHDszPath = GetPathPart(ProgramFilename()) + "chdman.exe"
				Debug CFG::*Config\CHDszPath 
			Else
				ProcedureReturn 1
			EndIf
		EndIf
		
		ProcedureReturn -1
	EndProcedure
	;
	;
	; Message Text für das ScrollAreaGadget in höhe setzen
	;
	Procedure.l SetScrollWidth(szCurrentString.s)
	    	    
		Protected nTextWidth.i, nScrollWidth.i, oScrollWidth.i
		
		SetGadgetText( DC::#Text_024, szCurrentString)
		
		nTextWidth.i = FORM::GetTextWidthPix(DC::#Text_024)/2
		
		oScrollWidth = GetGadgetAttribute(DC::#ScrollArea_002,#PB_ScrollArea_InnerWidth)
		
		If ( nTextWidth >= oScrollWidth )
		
		    nScrollWidth = nTextWidth - oScrollWidth
		    nScrollWidth + oScrollWidth
		
		    SetGadgetAttribute(DC::#ScrollArea_002,#PB_ScrollArea_InnerWidth, nScrollWidth)
		EndIf
	EndProcedure	
	;
	;
	; Message Text für das ScrollAreaGadget in höhe setzen
	;
	Procedure.l SetScrollHeight()
		Protected nTextHeight.i, nScrollHeight.i
		
		nScrollHeight = GetGadgetAttribute(DC::#ScrollArea_002,#PB_ScrollArea_InnerHeight)
		nTextHeight.i = FORM::GetTextHeightPix(DC::#Text_022) + nScrollHeight
		
		If ( nScrollHeight <= nTextHeight.i )		
		    SetGadgetAttribute(DC::#ScrollArea_002,#PB_ScrollArea_InnerHeight, nTextHeight)
		    SetGadgetAttribute(DC::#ScrollArea_002,#PB_ScrollArea_Y, nTextHeight):
		EndIf		
	EndProcedure	
	;
	; Message Text für den ScrollArea
	Procedure.s	SetScrollAreaText(szMessageOption.i, szStr$ = "")
		
		Protected sz$
		
		Select szMessageOption
			Case 0
				ProcedureReturn GetGadgetText(DC::#Text_022) + 
								"Lese Binary/Music Datei aus dem Cue " +#CR$+#CR$
			Case 1
				ProcedureReturn GetGadgetText(DC::#Text_022) + 
								"Verzeichnis:" +#CR$+ szStr$ +#CR$
			Case 2	
				ProcedureReturn GetGadgetText(DC::#Text_022) + 
							    " - CUE  :" + szStr$ +#CR$
			Case 3
				ProcedureReturn GetGadgetText(DC::#Text_022) + 
								" - BIN  :" + szStr$ +#CR$
			Case 4
				ProcedureReturn GetGadgetText(DC::#Text_022) + 
								"  (ERR) :" + szStr$ +#CR$
			Case 5
				;
				; Extracted Version from Commandline
				ProcedureReturn GetGadgetText(DC::#Text_022) + 
				#CR$ + " Komprimiere mit CHDTool Version: " + szStr$ +#CR$+#CR$
				
			Case 6
				;
				; Extracted Input File/ Track/Lenght/Compression from Commandline
				ProcedureReturn GetGadgetText(DC::#Text_022) + " - " + szStr$ +#CR$
				
			Case 7
			    ;
                ; CHDman Info - File Version
			    ProcedureReturn GetGadgetText(DC::#Text_022) +#CR$ + " Information: " +#CR$ + " - "+szStr$ +#CR$
			    
			Case 8
			    ProcedureReturn GetGadgetText(DC::#Text_022) + " - " + szStr$ + #CR$
			    
			Case 9
			    ProcedureReturn GetGadgetText(DC::#Text_022) + szStr$    
		EndSelect
		
	EndProcedure
	;
	;
	; Öffnen der Cue Datei und die Binary Datei lesen und den Path Überprüfen ob diese auch existiert
	Procedure	Open_CueFile(File$)
		
		Protected FileName$, FileCount.i, Position.i, DoubleQuotePos1.i, DoubleQuotePos2.i
		Protected BinaryFile$, BinaryPath$, ImageCount.i, VerfiyFILE$, nErrorCode.i
		
		SetGadgetText(DC::#Text_021, MessagesRequest(53) )
		SetGadgetText(DC::#Text_022, SetScrollAreaText(0) )
		
		SetScrollHeight();			
		SetScrollHeight(); Return Code
		
		ComplettSourceSize = 0
		
		If ( OpenFile(DC::#CUEFILE, File$ ,#PB_File_SharedRead|#PB_File_SharedWrite) )
			
			If ( ReadFile(DC::#CUEFILE, File$) ) 
				While Eof(DC::#CUEFILE) = 0
					;
					;
					; Suche nach "FILE" im CUE
					FileName$ = ReadString(DC::#CUEFILE)
					
					;
					; Prüfen wir obe die ersten 4 zeichen "FILE" ist
					IsSzFILE$ = Left(FileName$,4)
					If Not (UCase(IsSzFILE$) = "FILE" )
						Continue
					EndIf
					
					Position  = FindString( FileName$, "FILE ", 1, #PB_String_CaseSensitive)
					If Not (Position = -1) 
						
						DoubleQuotePos1 = FindString( FileName$, "" + Chr(34) + "", Position + 1)
						If Not (DoubleQuotePos1 = -1)
							
							DoubleQuotePos2 = FindString( FileName$, "" + Chr(34) + "", DoubleQuotePos1 + 1)			
							If Not (DoubleQuotePos2 = -1)
								
								DoubleQuotePos1 + 1 ; Überspringen 'Space'
								
								BinaryFile$ = Mid( FileName$ , DoubleQuotePos1, DoubleQuotePos2 - DoubleQuotePos1)
								If (BinaryFile$ = "")
									Continue
								EndIf
								
								BinaryPath$ = GetPathPart( BinaryFile$ )						
								If ( BinaryPath$ = "" )
									;
									; Bekommen haben wir nur die reine Datei
									; ersetzen wir den Cue File path mit dem Binary Path
									BinaryPath$ = GetPathPart( File$ )
									BinaryFile$ = BinaryPath$ + BinaryFile$
								EndIf
								If ( FileSize( BinaryFile$ ) >= 4096 )
									If  (ImageCount = 0)
										AddElement( ISOFileList() ): 
										ISOFileList()\CueFileList = File$
										ISOFileList()\BinFileList = BinaryFile$
										
; 										SetGadgetText(DC::#Text_022, SetScrollAreaText(1, BinaryPath$) )
										SetGadgetText(DC::#Text_022, SetScrollAreaText(2, GetFilePart( ISOFileList()\CueFileList )))
										SetGadgetText(DC::#Text_022, SetScrollAreaText(3, GetFilePart( ISOFileList()\BinFileList) ))
										SetScrollHeight()
										SetScrollWidth( ISOFileList()\BinFileList)
										ImageCount + 1;	
										Continue
									EndIf
									AddElement( ISOFileCount() ):
									ISOFileCount()\CueFileList = File$
									ISOFileCount()\BinFileList = BinaryFile$								
									SetGadgetText(DC::#Text_022, SetScrollAreaText(3, GetFilePart( ISOFileCount()\BinFileList) )):SetScrollHeight(): SetScrollWidth(ISOFileCount()\BinFileList)
									Continue
								Else
									nErrorCode = 5
									AddElement( ISOFileErros() ):
									ISOFileErros()\CueFileList = File$
									ISOFileErros()\BinFileList = BinaryFile$
									SetGadgetText(DC::#Text_022, SetScrollAreaText(4, GetFilePart( ISOFileErros()\BinFileList) )):SetScrollHeight(): SetScrollWidth(ISOFileErros()\BinFileList)				
									
									If ( ImageCount = 0 )
										CloseFile(DC::#CUEFILE)
										ProcedureReturn nErrorCode
									EndIf	
										
								EndIf	
							Else
								nErrorCode = 6
							EndIf
						Else
							nErrorCode = 7
						EndIf
					EndIf
    			Wend
    			CloseFile(DC::#CUEFILE)
    		Else
    			;
    			; Datei konnte nicht gelesen werden
				ProcedureReturn 4
			EndIf	
		Else
    			;
    			; Datei konnte nicht geöffnet werden			
			ProcedureReturn 3
		EndIf
		
		
		SetScrollHeight()		
		If ( ListSize( ISOFileList() ) = 0 )
			ProcedureReturn 8
		EndIf
		
		If ( nErrorCode >= 1 )
			ProcedureReturn nErrorCode
		EndIf
		
				
		ProcedureReturn -1
	EndProcedure
	;
	;
	; Öffnen der Cue Datei und die Binarys dateien in einer Liste packen sowie überprüfen ob sie all existieren
	Procedure	FileList_CueBin(File$)
		
		Protected nError.i
		nError = Open_CueFile(File$)
		If ( nError >= 3 )
			ProcedureReturn nError
		EndIf
		
		ProcedureReturn -1
	EndProcedure
	;
	;
	; Öffnen der Iso Datei und die Iso Datei lesen und den Path Überprüfen ob diese auch existiert
	Procedure	Open_IsoFile(File$)
		
		Protected FileName$, FileCount.i, Position.i, DoubleQuotePos1.i, DoubleQuotePos2.i
		Protected BinaryFile$, BinaryPath$, ImageCount.i, VerfiyFILE$, nErrorCode.i
		
		SetGadgetText(DC::#Text_021, MessagesRequest(53) )
		SetGadgetText(DC::#Text_022, SetScrollAreaText(0) )
		
		SetScrollHeight();			
		SetScrollHeight(); Return Code
		
		ComplettSourceSize = 0
		
			
		BinaryFile$ = File$
		If (BinaryFile$ = "")
		    ProcedureReturn 
		EndIf
		
		If ( FileSize( BinaryFile$ ) >= 4096 )
		    If  (ImageCount = 0)
		        AddElement( ISOFileList() ): 
		        ISOFileList()\CueFileList = File$
		        ISOFileList()\BinFileList = BinaryFile$
		        
		        ; 										SetGadgetText(DC::#Text_022, SetScrollAreaText(1, BinaryPath$) )
		        SetGadgetText(DC::#Text_022, SetScrollAreaText(2, GetFilePart( ISOFileList()\CueFileList )))
		        SetGadgetText(DC::#Text_022, SetScrollAreaText(3, GetFilePart( ISOFileList()\BinFileList) ))
		        SetScrollHeight()
		        SetScrollWidth( ISOFileList()\BinFileList)	
		        ProcedureReturn 
		    EndIf
		Else
		    nErrorCode = 5
		    AddElement( ISOFileErros() ):
		    ISOFileErros()\CueFileList = File$
		    ISOFileErros()\BinFileList = BinaryFile$
		    SetGadgetText(DC::#Text_022, SetScrollAreaText(4, GetFilePart( ISOFileErros()\BinFileList) )):SetScrollHeight(): SetScrollWidth(ISOFileErros()\BinFileList)				
		    
		    If ( ImageCount = 0 )
		        CloseFile(DC::#CUEFILE)
		        ProcedureReturn nErrorCode
		    EndIf	
		    
		EndIf	
		
		SetScrollHeight()		
		If ( ListSize( ISOFileList() ) = 0 )
			ProcedureReturn 8
		EndIf
		
		If ( nErrorCode >= 1 )
			ProcedureReturn nErrorCode
		EndIf
		
				
		ProcedureReturn -1
	EndProcedure	
	;
	;
    ;
	Procedure	FileList_IsoBin(File$)
		
		Protected nError.i
		nError = Open_IsoFile(File$)
		If ( nError >= 3 )
			ProcedureReturn nError
		EndIf
		
		ProcedureReturn -1
	EndProcedure
	
	Procedure.i  FileList_FormatCheck(File$)
	    
        Select ( UCase( GetExtensionPart( File$ ) ) )
        	Case "CUE"
        		nError = FileList_CueBin(File$)
        		If ( nError >=3 )
        			ProcedureReturn nError
        		EndIf
        		
        	Case "BIN"
        	    Request::MSG("Format ERR0R", "M.A.M.E. CHDMan Tool"  ,"*.BIN not yet Supportet", 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)
        	    ProcedureReturn 9
        	Case "ISO"
        		nError = FileList_IsoBin(File$)
        		If ( nError >=3 )
        			ProcedureReturn nError
        		EndIf
        	Case "TOC"
        	    Request::MSG("Format ERR0R", "M.A.M.E. CHDMan Tool"  ,"*.TOC not yet Supportet", 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)
        	    ProcedureReturn 9         	    
        	Case "GDI"
        	    Request::MSG("Format ERR0R", "M.A.M.E. CHDMan Tool"  ,"*.GDI not yet Supportet", 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)
        	    ProcedureReturn 9
        	Case "CHD"
        	    Request::MSG("Format ERR0R", "M.A.M.E. CHDMan Tool"  , " " + GetFilePart(File$) + " is already Compressed as CHD Image", 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)
        	    ProcedureReturn 9       	    
        	Default       	    
        	    Request::MSG("Format ERR0R", "M.A.M.E. CHDMan Tool"  ,"Can not Compress "+ UCase( GetExtensionPart( File$ )), 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)         	    
        		ProcedureReturn 9
        EndSelect	    
	    
	EndProcedure    
    ;
    ;
	;
	Procedure.i	FileList_GetFormat(ItemNr.i)
		
		Protected Path$, File$, RawImage$, nError.i
		
		Path$ = GetGadgetItemText(DC::#ListIcon_001,ItemNr,0)              
        File$ = GetGadgetItemText(DC::#ListIcon_001,ItemNr,1)
        
        SrceImage$ = Path$ + File$
        
        ProcedureReturn FileList_FormatCheck(SrceImage$)

        
        
	EndProcedure
	;
	;
	; Hole die Datiene die Markiert sind oder nimm alle
	Procedure	FileList_Marked()
		
		Protected iMarked.i 	= 0 
		Protected iMarkState.i	= 0
		Protected x.i			= 0
		Protected iMax.i		= 0
		Protected nError.i		= 0	

		;
		;
		; Suche nach der einen Markierten Datei. Diese wird dann auch nur Komprimiert
		; Sonst alle komprimieren
		
        For x = 0 To iMax
           iMarkState = GetGadgetItemState(DC::#ListIcon_001, x)
           If  ( iMarkState = 3 Or iMarkState = 2 )
           		 iMarked = 1
           		 Break
           EndIf 
        Next
        
        Select (iMarked)
        	Case 0
        		;
				; 
        		For x = 0 To iMax
        			nError = FileList_GetFormat(x)
        			If Not ( nError = -1 )
        				ProcedureReturn nError
        			EndIf
        		Next
        		
        	Case 1
        		For x = 0 To iMax
        			iMarkState = GetGadgetItemState(DC::#ListIcon_001, x)
        			If  ( iMarkState = 3 Or iMarkState = 2 )
        				FileList_GetFormat(x)
        			EndIf
        		Next
       	EndSelect     
	EndProcedure
    ;
    ;
    ;
	Procedure.s FileList_BinarySize()
	    
	    Protected BinarySize.q
	    
	    FirstElement( ISOFileList() )
		BinarySize + FileSize( ISOFileList()\BinFileList )	
		;
        ; Grösse der Binary Dateien
		ResetList( ISOFileCount() )
		ForEach ISOFileCount()
		    BinarySize + FileSize( ISOFileCount()\BinFileList )		    
		Next    
		
		ProcedureReturn MathBytes::ConvertSize(BinarySize, -1,"", 0, #True)
		
    EndProcedure	
	;
	;
	; Überprüfe CD Image Dateien
	Procedure	VerifyFiles()
		
		Protected cnt.i
		Protected err.i
		
		cnt  = CountGadgetItems(DC::#ListIcon_001)
		If ( cnt <> 0 )
			
			;
			; Dateien gefunden, Liste erstellen
			FileList_Clear()
			
			err = FileList_Marked()
			If (err >= 3)
				ProcedureReturn err
			EndIf
		
		Else
			ProcedureReturn 2
		EndIf
		
		ProcedureReturn -1
	EndProcedure
	;
    ;
    ;
	Procedure   WindowEv_Clear(*P.PROGRAM_BOOT)
	                            
            If IsWindow( DC::#_Window_005 )
                                
                FreeMemory(*P)               
                StickyWindow(DC::#_Window_005,0): 
                CloseWindow( DC::#_Window_005 )
                
            EndIf 	    
            
            If IsWindow( DC::#_Window_001 )
                SetActiveWindow(DC::#_Window_001)
                StickyWindow(DC::#_Window_001,CFG::*Config\Sticky)
            	DropCode::SetUIElements_Global(0)
            	SetWindowTitle(DC::#_Window_001,CFG::*Config\WindowTitle.s)  
            EndIf            
	EndProcedure	
	;
	;
    ;	
	Procedure	Compress()
		
		uiGenerateWindow()
		Protected err.i

			; Prüfen Mame CHDManager
			If ( VerifyToolPath() = 1 )
				ProcedureReturn 1
			EndIf
			
			; Prüfe Dateien
			err = VerifyFiles()
			If ( err >= 0)
			    If IsWindow( DC::#_Window_005 )           
			        StickyWindow(DC::#_Window_005,0): 
			        CloseWindow( DC::#_Window_005 )			        
			    EndIf			    
			    ProcedureReturn err
			EndIf    
			HideWindow(DC::#_Window_005,0)
			
		; Prüfen CDRDAO .toc/.bin, CDRWIN .bin/.cue, or Sega Dreamcast .GDI file from a CHD\-CD image.
		; Optional Verzeichnisse Durchsuchen und Komprimieren
		; Optional dabei die cue Files prüfen ob der Dateiname stimmt
		; Komprimieren
		ProcedureReturn err
	EndProcedure
	;
	;
	; Extract Version from Streamed Commandline
	Procedure.s Thread_sZGetVersion(szStrin$)
		
		Protected szSearch$ = "chdman - MAME Compressed Hunks of Data (CHD) manager "
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
			szFoundz$ = ReplaceString( szStrin$, szSearch$, "")
			;
			; Schneide weiteres weg
			nPosition = FindString(szFoundz$, Chr(40) , 1)
			If Not (nPosition = -1)
				
				szFoundz$ = Mid( szFoundz$, 0, nPosition-1 )
				ProcedureReturn szFoundz$
			EndIf
		EndIf
		ProcedureReturn ""
		
	EndProcedure	
	;
	;
	; Extract Input File from Streamed Commandline
	Procedure.s	Thread_sZGetInputFile(szStrin$) 
		
		Protected szSearch$ = "Input file: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
			
			szFoundz$ = ReplaceString( szStrin$, szSearch$, "")
			szFoundz$ = GetFilePart(szFoundz$)
			
			szFoundz$ = "Input File  : " + szFoundz$
			
			ProcedureReturn szFoundz$	
		EndIf
		ProcedureReturn ""
		
	EndProcedure
	;
	;
	; Extract Input Tracks from Streamed Commandline
	Procedure.s	Thread_sZGetInputTracks(szStrin$) 
		
		Protected szSearch$ = "Input tracks: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
			szFoundz$ = ReplaceString( szStrin$, szSearch$, "")
			szFoundz$ = "Input Tracks: " + szFoundz$
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
	EndProcedure
	;
	;
	; Extract Input Lenght from Streamed Commandline
	Procedure.s	Thread_sZGetInputLenght(szStrin$) 
		
		Protected szSearch$ = "Input length: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
			szFoundz$ = ReplaceString( szStrin$, szSearch$, "")
			szFoundz$ = "Input Lenght: " + szFoundz$
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
	EndProcedure
	;
	;
	; Extract Compression from Streamed Commandline
	Procedure.s	Thread_sZGetCompression(szStrin$) 
		
		Protected szSearch$ = "Compression: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )	
			szFoundz$ = ReplaceString( szStrin$, szSearch$, "")
			szFoundz$ = Trim(szFoundz$)
			szFoundz$ = ReplaceString( szFoundz$, ",", #CR$+"                ")			
			szFoundz$ = "Compression : " + szFoundz$
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
	EndProcedure
	;
	;
	; Extract Compression from Streamed Commandline
	Procedure.s	Thread_sZGetLogicalSize(szStrin$) 
		
		Protected szSearch$ = "Logical size: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0
		Protected szNumber$ = ""
		Protected CHDSize.q = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )	
			szFoundz$ = ReplaceString( szStrin$, szSearch$, "")			
			szFoundz$ = Trim(szFoundz$)
				
			szNumber$ = ReplaceString( szFoundz$, ",", "")
			CHDSize	  = Val(szNumber$)
				
			szFoundz$ = "Logical Size: " + MathBytes::ConvertSize(CHDSize, -1,"", 0, #True) 
							 
			ProcedureReturn szFoundz$	
		EndIf
		ProcedureReturn ""
		
	EndProcedure	
	;
	;
	; Extract File Version from Command Argument 'Info -i file'
	Procedure.s	Thread_sZGetInfoVersion(szStrin$, *P.PROGRAM_BOOT) 
		
		Protected szSearch$ = "File Version: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
		    *P\szVersion = ReplaceString( szStrin$, szSearch$, "")

			szFoundz$ = "File Version: " + *P\szVersion			
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
		
	EndProcedure	
	;
	;
	; Extract Ratio from Command Argument 'Info -i file'
	Procedure.s	Thread_sZGetInfoRatio(szStrin$, *P.PROGRAM_BOOT) 
		
		Protected szSearch$ = "Ratio: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
		    *P\szRatio = ReplaceString( szStrin$, szSearch$, "")
		    *P\szRatio = Trim( *P\szRatio )   
			szFoundz$ = "Ratio       : " + *P\szRatio			            
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
		
	EndProcedure
	;
	;
	; Extract SHA1 from Command Argument 'Info -i file'
	Procedure.s	Thread_sZGetInfoRawSHA1(szStrin$, *P.PROGRAM_BOOT) 
		
		Protected szSearch$ = "SHA1: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
		    *P\szRawSHA1 = ReplaceString( szStrin$, szSearch$, "")
            *P\szRawSHA1 = Trim( *P\szRawSHA1 )   	    
			szFoundz$ = "SHA1        : " + *P\szRawSHA1			            			            
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
		
	EndProcedure	
	;
	;
	; Extract Data SHA1 from Command Argument 'Info -i file'
	Procedure.s	Thread_sZGetInfoDtaSHA1(szStrin$, *P.PROGRAM_BOOT) 
		
		Protected szSearch$ = "Data SHA1: "	
		Protected szResult$ = ""
		Protected szFoundz$ = ""
		Protected nPosition = 0		
		
		If ( FindString(szStrin$, szSearch$, 1, #PB_String_CaseSensitive) )
		    *P\szDtaSHA1 = ReplaceString( szStrin$, szSearch$, "")
            *P\szDtaSHA1 = Trim( *P\szDtaSHA1 ) 
			szFoundz$ = "Data SHA1   : " + *P\szDtaSHA1
			
			ProcedureReturn szFoundz$
		EndIf
		ProcedureReturn ""
		
	EndProcedure	
	;
	;
    ;
	
	Procedure.s Thread_GetConsoleOut(*P.PROGRAM_BOOT)
		
  
	        
	    Delay(125)   
		CHD::szLineSplit( *P\Logging , #CR$,  #True )
		Delay(125)
		
		ForEach szSplittetList()
			
			szSplittetList() = ReplaceString( szSplittetList(), Chr(10), Chr(0),0) 
			
			If  ( *P\bVersion = #False ) And ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #False )
				szText$ = Thread_sZGetVersion( szSplittetList() )
				If ( szText$ ) 
					SetGadgetText(DC::#Text_022, SetScrollAreaText( 5, szText$) )
					SetScrollHeight()
					*P\bVersion = #True
					Continue
				EndIf	
			EndIf
			
; 			If  ( *P\bInputFile = #False ) And  ( Len(*P\Logging) >= 1 )
; 				szText$ = Thread_sZGetInputFile( szSplittetList () )
; 				If ( szText$ )                     			
; 					SetGadgetText(DC::#Text_022, SetScrollAreaText( 6, szText$) )
; 					SetScrollHeight()
; 					SetScrollHeight()
; 					*P\bInputFile = #True
; 					Continue
; 				EndIf	
; 			EndIf
			
			If  ( *P\bInputTracks = #False ) And  ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #False )
				szText$ = Thread_sZGetInputTracks( szSplittetList() )
				If ( szText$ )    
					SetGadgetText(DC::#Text_022, SetScrollAreaText( 6, (szText$) ) )
					SetScrollHeight()
					*P\bInputTracks = #True
					Continue
				EndIf	
			EndIf
			
			If  ( *P\bInputLength = #False ) And  ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #False )
				szText$ = Thread_sZGetInputLenght( szSplittetList() )
				If ( szText$ )    
					SetGadgetText(DC::#Text_022, SetScrollAreaText( 6, (szText$) ) )
					SetScrollHeight()
					*P\bInputLength = #True
					Continue
				EndIf	
			EndIf
			
			If  ( *P\bCompression = #False ) And  ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #False )
				szText$ = Thread_sZGetCompression( szSplittetList() )
				If ( szText$ )    
					SetGadgetText(DC::#Text_022, SetScrollAreaText( 6, (szText$) ) )
					SetScrollHeight()
					SetScrollHeight()
					SetScrollHeight()
					SetScrollHeight()
                    SetScrollHeight()					
					*P\bCompression = #True
					Continue
				EndIf	
			EndIf 
			
			If  ( *P\bLogicalSize = #False ) And ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #False )
				szText$ = Thread_sZGetLogicalSize( szSplittetList() )
				If ( szText$ )    
					SetGadgetText(DC::#Text_022, SetScrollAreaText( 6, (szText$) ) )
					SetScrollHeight()					
					*P\bLogicalSize = #True
					Continue
				EndIf	
			EndIf	
			
			If  ( *P\bInfoVersion = #False ) And ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #True)
			    szText$ = Thread_sZGetInfoVersion( szSplittetList(), *P )
			    If ( szText$ )
			        SetGadgetText(DC::#Text_022, SetScrollAreaText( 7, (szText$) ) )
			        SetScrollHeight()
					*P\bInfoVersion = #True
					Continue			        
			    EndIf    
			EndIf 
			
			If  ( *P\bInfoRatio   = #False ) And ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #True)
			    szText$ = Thread_sZGetInfoRatio( szSplittetList(), *P )
			    If ( szText$ ) 
			        SetGadgetText(DC::#Text_022, SetScrollAreaText( 8, (szText$) ) )
			        SetScrollHeight()
					*P\bInfoRatio = #True
					Continue				        
			    EndIf			    
			EndIf 
			
			If  ( *P\bInfoRawSHA1 = #False ) And ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #True)
			    szText$ = Thread_sZGetInfoRawSHA1( szSplittetList(), *P )
			    If ( szText$ ) 
			        SetGadgetText(DC::#Text_022, SetScrollAreaText( 8, (szText$) ) )
			        SetScrollHeight()
					*P\bInfoRawSHA1 = #True
					Continue				        
			    EndIf			    
			EndIf
			
			If  ( *P\bInfoDtaSHA1 = #False ) And ( Len(*P\Logging) >= 1 ) And ( *P\bInfo = #True)
			    szText$ = Thread_sZGetInfoDtaSHA1( szSplittetList(), *P )
			    If ( szText$ ) 
			        SetGadgetText(DC::#Text_022, SetScrollAreaText( 8, (szText$) ) )	
			        SetScrollHeight()
			        SetScrollHeight()
			        SetScrollHeight()
					*P\bInfoDtaSHA1 = #True
					Continue				        
			    EndIf			    
			EndIf 			
			Delay(25)
		Next		
		
		ClearList( szSplittetList() )
	EndProcedure
    ;
	;
    ;
	Procedure.s Thread_GetVerifyOut(*P.PROGRAM_BOOT)
	       
	    Protected szString$, Position.i
	    
	    If ( GetGadgetState( DC::#CheckBox_002) = #PB_Checkbox_Checked ) ; Verify Checkbox ist gesetzt
	        
	        Position = FindString(*P\Logging,"Raw SHA1 verification successful!", 0, #PB_String_CaseSensitive)
	        If ( Position >= 0)
	            szString$ = #CR$ + "    Raw SHA1 Verification Successful!" + #CR$
	            
	            Position = FindString(*P\Logging,"Overall SHA1 verification successful!", 0, #PB_String_CaseSensitive)
	            
	            If ( Position >= 0)
	                szString$ + "Overall SHA1 Verification Successful!" + #CR$ + #CR$
	                
	                szString$ + "SHA1      :" + *P\szRawSHA1 + #CR$
	                szString$ + "Data SHA1 :" + *P\szDtaSHA1 
	                SetGadgetText(DC::#Text_022, SetScrollAreaText( 9, (szString$) ) )
	                SetScrollHeight()
	                SetScrollHeight()	
	                SetScrollHeight()	
	                SetScrollHeight()			
	                ProcedureReturn szString$
	            EndIf
	        EndIf
	    Else
	        
	        szString$ = #CR$
	        szString$ + "SHA1      :" + *P\szRawSHA1 + #CR$
	        szString$ + "Data SHA1 :" + *P\szDtaSHA1 	    
	        SetScrollHeight()
	        SetScrollHeight()	
	        SetScrollHeight()	
	        SetScrollHeight()	
	        ProcedureReturn szString$
	    EndIf
	    
	EndProcedure    
    ;	
    ;
	;
    Procedure 	Thread_HandleIO(*P.PROGRAM_BOOT)
    	
    	Protected ReadLen.i, WriteLen.i, Error$
    	
    	*Buffer = AllocateMemory(4096)
    	
    	If *Buffer
    		
    		*P\LoProcess = RunProgram(*P\PrgPath +  *P\Program,*P\Command,*P\DstPath,*P\PrgFlag, #PB_Program_UTF8):
    		
    		If IsProgram(*P\LoProcess)
    			*P\HiProcess = OpenProcess_(#PROCESS_QUERY_INFORMATION, 0, ProgramID(*P\LoProcess)) 	
    		EndIf
     		Delay(5) 
    	  		
    		If *P\LoProcess
    			
    			Repeat
    				
    			    ReadLen = AvailableProgramOutput(*P\LoProcess)
    			    If ReadLen
    			        
    			        Debug #CR$ + "Speichergrösse ProgrammOutput: " + Str( ReadLen )
    			        Debug        "Speichergrösse des Buffers   : " + Str (MemorySize( *Buffer ) )    			        
    			        
    			        If ( ReadLen >= MemorySize( *Buffer ) )                            
    			            *Buffer = ReAllocateMemory( *Buffer , ReadLen +1): Delay(5)
    			            Debug    "Buffer Wurde vergrössert     : " + Str (MemorySize( *Buffer ) ) + #CR$+ #CR$
    			            
    			        ElseIf ( ReadLen <= MemorySize( *Buffer ) )  			        
    			            *Buffer = ReAllocateMemory( *Buffer , ReadLen +1): Delay(5)
    			            Debug    "Buffer wurde verkleinert     : " + Str (MemorySize( *Buffer ) ) + #CR$+ #CR$
    			            
    			       EndIf     
    			        
    					ReadLen = ReadProgramData(*P\LoProcess, *Buffer, ReadLen)
    					If ReadLen        					    
    					    *P\Logging = PeekS(*Buffer, ReadLen, #PB_UTF8)
    					    Debug *P\Logging
    						Thread_GetConsoleOut(*P)
    					EndIf
    				EndIf
    				
    				Error$ = ReadProgramError(*P\LoProcess, #PB_UTF8)
    				If Len(Error$)
    					*P\StError = Error$
    					Thread_GetConsoleOut(*P)
    				EndIf
    							    				
    				Delay(1)
    				
    			Until ( *P\LoProcess = 0 ) Or (IsProgram(*P\LoProcess) = 0) Or Not ProgramRunning(*P\LoProcess)
    			
    		    GetExitCodeProcess_(*P\HiProcess, @exitCodeH)
    		    GetExitCodeProcess_(*P\LoProcess, @exitCodeL)
    		    
    		    *P\exitCodeHi = exitCodeH
    		    *P\exitCodeLo = exitCodeL
    	    			
    		    If ( *P\exitCodeHi >=1 ) And ( *P\exitCodeLo >=1 )
    		        
    			    Debug "exitCodeH:" + Str(*P\exitCodeHi)
    			    Debug "exitCodeL:" + Str(*P\exitCodeLo)    		        
    			    Debug *P\StError
    			EndIf
    			
    			CloseProgram(*P\LoProcess)
    			
    		EndIf
    		
    		FreeMemory(*Buffer)
    	EndIf
    	
    EndProcedure
	;
	;
	;	
	Procedure 	Thread_Prep(*P.PROGRAM_BOOT) 
		LockMutex(*P\PrgMutex)
		
		Thread_HandleIO(*P.PROGRAM_BOOT)        
				
		UnlockMutex(*P\PrgMutex)
		ProcedureReturn
	EndProcedure	
	;
	;
    ; Überprüft ob am ende des Zeilverzeichnis ein backslah dran hängt
	Procedure.s CheckDestPath(szDestPath.s)
	    
	    If Not Right(szDestPath,1) = "\"
	        szDestPath + "\"
	        ProcedureReturn szDestPath
	    EndIf
	    ProcedureReturn szDestPath
	EndProcedure
    ;
    ;
    ;
	Procedure   UpdateSuffix()
	    
	    Suffix$ = UCase( Right( GetGadgetText(DC::#String_001), 4) )
	    If Not (Suffix$ = ".CHD" )
	        SetGadgetText(DC::#String_001, GetGadgetText(DC::#String_001) + ".chd")
	    EndIf    
	
	EndProcedure
    ;
    ;
    ; --compression, -c <none|type1[,type2[,...]]>: which compression codecs to use (up to 4)
	Procedure.s GetCompression()
     
	     Select GetGadgetState(DC::#ComboBox_005) 
	         Case 0: ProcedureReturn " -c0"
	         Case 1: ProcedureReturn " -c1"
	         Case 2: ProcedureReturn " -c2"
	         Case 3: ProcedureReturn " -c3"
	         Case 4: ProcedureReturn " -c4"
	         Default
	             ProcedureReturn " -c4"
	    EndSelect 
	     
	EndProcedure
    ;
    ;
    ;
	Procedure.s GetCompressionUpdateInfo()
	    
	     Select GetGadgetState(DC::#ComboBox_005) 
	         Case 0: ProcedureReturn " Compression Type: None"
	         Case 1: ProcedureReturn " Compression Type: 1"
	         Case 2: ProcedureReturn " Compression Type: 2"
	         Case 3: ProcedureReturn " Compression Type: 3"
	         Case 4: ProcedureReturn " Compression Type: 4"
	         Default
	             ProcedureReturn " Compression Type: 4"
	    EndSelect 
	     
	EndProcedure
	;
    ;
    ;
	Procedure.i GetMenuMenuEntry_Sticky()
	    
	    If ( IsWindow( DC::#_Window_005 ))	        
	         StickyWindow(DC::#_Window_005,CFG::*Config\CHDbSticky)
	   EndIf     
	EndProcedure

    ;
    ;
    ; Überprpfe ob die Datei existiert und Optionl Lösche diese
	
	Procedure.i FileExists_Check(*P.PROGRAM_BOOT)
	    
 		; Check For File Exists		
	    If FileSize( *P\CHDFile  ) >= 0
	        
	        szMsgTitle$ = "Datei Existiert"
	        szMsgNote$  = GetFilePart(*P\CHDFile ) + #CR$ + "Überschreiben ?"

	        Select Request::MSG("", szMsgTitle$, szMsgNote$, 12,1,ProgramFilename(),0,0,DC::#_Window_001)
	                ;
	                ;
                Case 1: WindowEv_Clear(*P): ProcedureReturn 1
                    ;
                    ;
                Case 0:
                        If ( FileSize(  *P\CHDFile  ) >= 0 )
                            DeleteFile( *P\CHDFile  )
                            Delay(1000)
                        EndIf
                        ProcedureReturn 0
            EndSelect 		
        EndIf
        
    EndProcedure
    ;
    ;
    ;
    Procedure.s SetConsoleCmd_CreateCD(*P.PROGRAM_BOOT)
        
        Protected ChdCreatCD$
        
            ; Input 
            ChdCreatCD$ = "createcd -i "
            ChdCreatCD$ + Chr(34) + *P\IsoFile + Chr(34)
            
            ; Output
            ChdCreatCD$ + " -o "
            ChdCreatCD$ + Chr(34) + *P\CHDFile  + Chr(34)
            
            ; Compression Type
            ChdCreatCD$ + GetCompression()
            
            ; Cores to use
            ChdCreatCD$ + " -np"+ Str( ProcessEX::SetAffinityCPUS() )
            
            ; Force to Overwrite (??? Ich weiss noch nicht ob ich das drinlasse)
            ChdCreatCD$ + " --force"      
            
            Debug  #CR$ +"SetConsoleCmd_CreateCD" + #CR$ + ChdCreatCD$
            
            ProcedureReturn ChdCreatCD$
    EndProcedure   
    ;
    ;
    ;
    Procedure.s SetConsoleCmd_Verify(*P.PROGRAM_BOOT)
        
        Protected ChdCreatCD$

            ChdCreatCD$ = "verify -i "
            ChdCreatCD$ + Chr(34) + *P\CHDFile + Chr(34) 
            
            Debug  #CR$ +"SetConsoleCmd_Verify" + #CR$ + ChdCreatCD$
            
            ProcedureReturn ChdCreatCD$
    EndProcedure
    ;
    ;
    ;
    Procedure.s SetConsoleCmd_GetInfo(*P.PROGRAM_BOOT)
        
        Protected ChdCreatCD$

            ChdCreatCD$ = "info -i "
            ChdCreatCD$ + Chr(34) + *P\CHDFile + Chr(34) 
            
            Debug  #CR$ +"SetConsoleCmd_GetInfo" + #CR$ + ChdCreatCD$
            
            ProcedureReturn ChdCreatCD$
    EndProcedure          
    ;
    ;
    ;
    Procedure Thread_StartCHD_CreatCD(*P.PROGRAM_BOOT)
        
        Protected CurrSize.q, LastSize.q
        
            *P\PrgMutex  = CreateMutex()
        
        	*P\PrgThread = 0 
        	*P\PrgThread = CreateThread(@Thread_Prep(),*P)
        	*p\ForceBreak= #False
                       
            SetActiveWindow(DC::#_Window_001)
            SetWindowTitle (DC::#_Window_001,MessagesRequest(54) )
            
            DropCode::SetUIElements_Global(1)       
            	
            SetActiveWindow(DC::#_Window_005)
            ;
            GetMenuMenuEntry_Sticky()
             
            ;
            SetGadgetText (DC::#Text_021,   MessagesRequest(50, #TAB$ + GetCompressionUpdateInfo() + #TAB$ +" Core(s):  " + Str( ProcessEX::SetAffinityCPUS() )))
            
            While IsThread(*P\PrgThread)  
                                
            	If GetActiveWindow() =  DC::#_Window_005
            	    
            	    If KeyIsDown(#VK_ESCAPE)
            			
           			    SetGadgetColor(DC::#Text_023, #PB_Gadget_FrontColor,$6A6AFB)            			
           			    SetGadgetText (DC::#Text_023, MessagesRequest(52))
           			    
                        *p\ForceBreak = #True           			    
                        
                        If ( *P\LoProcess <> 0 )           			        
            				KillProgram(*P\LoProcess)
            			EndIf                        
            			            			
            			If IsThread(*P\PrgThread)
            			    KillThread(*P\PrgThread)  
            			EndIf
            			
            			Delay(2525) 
            			Break
            			
            		EndIf
            		
            	EndIf      

            	While WindowEvent()
            	Wend    
            	
                ;
                ; Notify das System
                ReadFile( DC::#_TempFile , *P\CHDFile, #PB_File_SharedWrite | #PB_File_SharedRead)
 
                ;
                ; Hole die aktuelle Dateigrösse
            	CurrSize = FileSize( *P\CHDFile )            	
                If ( LastSize <> CurrSize )
                     LastSize = CurrSize
                	    
                    SetGadgetText(DC::#Text_023, " Komprimiertes CHD (ISO) Image: " + MathBytes::ConvertSize(LastSize, -1,"", 0, #True) ) 
                    Delay(1)
                EndIf                               
            Wend         
            
            SetGadgetText(DC::#Text_021,MessagesRequest(51))
            
     EndProcedure    
    ;
    ;
    ;
    Procedure Thread_StartCHD_Verify(*P.PROGRAM_BOOT) 
        
         *P\bInfo     = #False          
         *P\PrgMutex  = CreateMutex()         
         *P\PrgThread = 0 
         *P\PrgThread = CreateThread(@Thread_Prep(),*P)
         *p\ForceBreak= #False
         
         SetGadgetText (DC::#Text_021, MessagesRequest(55))
         While IsThread(*P\PrgThread )  
             
             If GetActiveWindow() =  DC::#_Window_005
                 
                 If KeyIsDown(#VK_ESCAPE)
                     
                     *p\ForceBreak= #True
                     
                     SetGadgetColor(DC::#Text_023,#PB_Gadget_FrontColor,$6A6AFB)            			
                     SetGadgetText (DC::#Text_023, MessagesRequest(52))
                     
                     If ( *P\LoProcess <> 0 )
                         KillProgram(*P\LoProcess)
                     EndIf                        
                     
                     If IsThread(*P\PrgThread )
                         KillThread(*P\PrgThread )  
                     EndIf
                     
                     Delay(2525) 
                     Break
                 EndIf
                 
             EndIf      
             
             While WindowEvent()
             Wend            	                                
         Wend          
         
        SetGadgetText (DC::#Text_021, MessagesRequest(51) )         
    EndProcedure
    ;
    ;
    ;
    Procedure Thread_StartCHD_InfoNote(*P.PROGRAM_BOOT) 
                
         *P\bInfo     = #True        
         *P\PrgMutex  = CreateMutex()         
         *P\PrgThread = 0 
         *P\PrgThread = CreateThread(@Thread_Prep(),*P)

         
         SetGadgetText (DC::#Text_021, MessagesRequest(55))
         While IsThread(*P\PrgThread )  
                         
             While WindowEvent()
             Wend            	                                
         Wend          
         
        SetGadgetText (DC::#Text_021, MessagesRequest(51) )         
    EndProcedure    
    ;
    ;
    ;
    Procedure CopyInfoToClibBoard()
        
        Protected Result.s
        
        If ( CFG::*Config\CHDbClipBoard = 1 )        
                
            If OpenClipboard_(0)
                EmptyClipboard_()
                SetClipboardText( GetGadgetText( DC::#Text_022 ) )
                CloseClipboard_()
                ProcedureReturn 1
            EndIf
            ProcedureReturn 0
        EndIf
        ProcedureReturn 0

   EndProcedure
   ;
   ;
   ;
    Procedure	Start_Manager()
        
        Protected BinaryString$ , szVerifyOut$
        
        SetGadgetText (DC::#Text_021, "")
        
        *P.PROGRAM_BOOT = AllocateMemory(SizeOf(PROGRAM_BOOT))
        InitializeStructure(*P, PROGRAM_BOOT)	    
        
        *P\IsoFile         = ""
        *P\CHDFile         = ""  
        *P\PrgPath         = ""      
        *P\Program         = CFG::*Config\CHDszPath 
        *P\DstPath         = GetGadgetText( DC::#String_002 )
        *P\Logging         = ""        
        *P\ExError         = 0        
        *P\StError         = ""
        *P\exitCodeLo      = 0
        *P\exitCodeHi      = 0
        
        ;=========================================== 		
        ;
        ; Wenn der Suffix mal fehlt ......
        UpdateSuffix()
        
        ;=========================================== 		
        ;
        ; Überprüfe ob die Liste nicht 0 ist
        If ( ListSize( ISOFileList() ) = 0 )
            WindowEv_Clear(*P): ProcedureReturn
        EndIf
        
        FirstElement( ISOFileList() )
        *P\IsoFile = ISOFileList()\CueFileList		
        *P\CHDFile = CheckDestPath( *P\DstPath ) + GetGadgetText( DC::#String_001 )
        
        ;
        ; Normalisiere, 
        *P\PrgPath         = GetPathPart(*P\Program)
        *P\Program         = GetFilePart(*P\Program)		
        
        *P\bVersion		= #False
        *P\bInputFile	= #False
        *P\bInputTracks	= #False
        *P\bInputLength	= #False 
        *P\bCompression	= #False
        *P\bLogicalSize	= #False
        *P\bInfo        = #False
        *P\bInfoVersion = #False
        *P\bInfoRatio   = #False
        *P\bInfoRawSHA1 = #False
        *P\bInfoDtaSHA1 = #False
        

                
        ;=========================================== 		
        ; Check For Directory Exists
        If Not ( FileSize( CheckDestPath( *P\DstPath ) ) = -2 )		    
            MessagesRequest(9): WindowEv_Clear(*P): ProcedureReturn
        EndIf 
        
        ;=========================================== 		
        If ( FileExists_Check( *P ) = 1 )
            ProcedureReturn 
        EndIf
        
        ;=========================================== 		
        *P\Command         = SetConsoleCmd_CreateCD(*P)
        
        *P\PrgFlag         = #PB_Program_Hide|
                             #PB_Program_Open|
                             #PB_Program_Read|
                             #PB_Program_Error|
                             #PB_Program_UTF8
        
        ;===========================================        
        Thread_StartCHD_CreatCD(*P.PROGRAM_BOOT)
        
        ;===========================================
        ;
        ; Datei Extra schliessen
        If ( OpenFile( DC::#_TempFile , *P\CHDFile, #PB_File_SharedWrite | #PB_File_SharedRead) )
            CloseFile( DC::#_TempFile)
        EndIf
        
        ;=========================================== 		
        ;        
        ; Was ist Passiert - Abruch oder nicht
        
        
        If (*P\exitCodeLo = 1)
            Request::MSG("ERR0R", "M.A.M.E. CHDMan Tool"  ,*P\StError, 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)
        Else 
            ;
            ; Kein Abbruch des programms oder vom user
            If ( *P\ForceBreak = #False )
                
                SetGadgetColor(DC::#Text_023,#PB_Gadget_FrontColor,$71F28A)
                Delay(1525)
                
                ; Info Thread
                ; ===================================================================================================
                ;
                *P\Command = SetConsoleCmd_GetInfo(*P)
                *P\exitCodeLo      = 0
                *P\exitCodeHi      = 0                            
                
                Thread_StartCHD_InfoNote(*P.PROGRAM_BOOT)
                
                Delay(1000)
                
                ; Verify Thread
                ; ===================================================================================================
                ;
                *P\exitCodeLo      = 0
                *P\exitCodeHi      = 0 
                                
                If ( GetGadgetState( DC::#CheckBox_002) = #PB_Checkbox_Checked ) 
                    *P\Command = SetConsoleCmd_Verify(*P)                                          
                    Thread_StartCHD_Verify(*P.PROGRAM_BOOT)
                EndIf
                
                If (*P\exitCodeLo = 1)                                
                    Request::MSG("Verify ERR0R", "M.A.M.E. CHDMan Tool"  ,*P\StError, 2, 2, ProgramFilename(), 0, 0, DC::#_Window_001)
                    
                Else
                    szVerifyOut$ = #CR$ + #CR$ + Thread_GetVerifyOut(*P)                                                                
                    
                    Request::*MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12)
                    Request::*MsgEx\Fnt2 = FontID(Fonts::#_FIXPLAIN7_12)
                    Request::*MsgEx\Fnt3 = FontID(Fonts::#_FIXPLAIN7_12)
                    
                    Request::*MsgEx\User_BtnTextM = "Fertig"
                    
                    szMessage$ = "ISO wurde komprimiert" + #CR$ + #CR$
                    szMessage$ + "Vorher : " + FileList_BinarySize() + #CR$ 
                    szMessage$ + "Nachher: " + MathBytes::ConvertSize( FileSize( *P\CHDFile ) , -1,"", 0, #True) + szVerifyOut$
                    
                    If ( CopyInfoToClibBoard() = 1 )
                        szMessage$ + #CR$ + #CR$ + "Info Ergebnis in die Zwischenablage kopiert .."
                    EndIf
                    
                    Request::MSG("Successfully", "M.A.M.E. CHDMan Tool"  , szMessage$ ,0, 0, ProgramFilename(), 0, 0, DC::#_Window_001)
                    
                    
                EndIf                            
                
                ; ===================================================================================================                          
                
            EndIf
            If ( *P\ForceBreak = #True )
                If ( FileSize(  *P\CHDFile ) >= 0 )
                    DeleteFile( *P\CHDFile )
                EndIf
            EndIf    
        EndIf
        
        FileList_Clear()
        WindowEv_Clear(*P)
        
    EndProcedure
    ;
	;
	;
    Procedure.s	Set_UtilityPath()
    	
    	Protected Extension$
    	
    	Extension$ = "Mame CHDMan |chdman.exe;"
    	szpChdMan$ = ""
    	
    	szpChdMan$ = FFH::GetFilePBRQ("","",#False, Extension$, 0)
    	ProcedureReturn szpChdMan$
    	
    EndProcedure
EndModule
    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 210
; FirstLine = 181
; Folding = TBAAAIBQx
; EnableAsm
; EnableXP
; UseMainFile = ..\..\LH Drop7z 1\Drop7z.pb