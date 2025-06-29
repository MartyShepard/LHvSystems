DeclareModule vSystemHelp
	
  Declare 		vSysCMD_MiniMize()
  Declare 		vSysCMD_Asynchron()
  Declare 		vSysCMD_WinApi()
  Declare 		vSysCMD_Borderless()
  Declare 		vSysCMD_BorderlessC()
  Declare 		vSysCMD_BorderlessB()
  Declare 		vSysCMD_BorderlessCB()
  Declare 		vSysCMD_MetricsCalc()
  Declare 		vSysCMD_KeyModShift()
  Declare 		vSysCMD_DisableScreenShot()
  Declare 		vSysCMD_LockMouse()
  Declare 		vSysCMD_FreeMemory()
  Declare 		vSysCMD_DisableTaskbar()
  Declare 		vSysCMD_DisableExplorer()
  Declare 		vSysCMD_DisableAero()
  Declare 		vSysCMD_CpuAffinity1()
  Declare 		vSysCMD_CpuAffinity2()
  Declare 		vSysCMD_CpuAffinity3()
  Declare 		vSysCMD_CpuAffinity4()
  Declare 		vSysCMD_CpuAffinityF()
  Declare 		vSysCMD_Monitoring()
  Declare 		vSysCMD_FirewallBlock()
  Declare		vSysCMD_MediaDevice1() 
  Declare 		vSysCMD_MediaDeviceCommand()
  Declare 		vSysCMD_NoOutPut()
  Declare 		vSysCMD_LogRedirect()
  Declare 		vSysCMD_KeyModDisableTask()	
	Declare 		vSysCMD_NoDoubleQuotes()
	Declare 		vSysCMD_MameCMDHelp()
	Declare 		vSysCMD_PackSupport()
	Declare 		vSysCMD_HelpSupport_Main()
	Declare 		vSysCMD_HelpSupport_Borderless()
	Declare 		vSysCMD_QuickCommand()
	Declare 		vSysCMD_SavegameSupport()
	Declare.s 	vSysCMD_ToolTipHelp()
	
EndDeclareModule

Module vSystemHelp
	
	;
	;
   Procedure.i Caret_SetPosition(nPos.i)
                        
            g.i = GadgetID( DC::#String_103 ): SetActiveGadget(  DC::#String_103 )  
            
            Protected Range.CHARRANGE, ncLine.i, nColumn.i, Caret.Point
            
            ;
            ; Cursor X: Line
            SendMessage_(g,  #EM_EXGETSEL, 0, @Range)
                     
            Range\cpMax = nPos
            Range\cpMin = nPos
            
            SendMessage_(g, #EM_SETSEL, Range\cpMax, Range\cpMin)
            
        ProcedureReturn -1
      EndProcedure
   ;
   ;
  Procedure.i StrGetSet_Text(CurrentCmd.s, Pos.i)
				SetGadgetText( DC::#String_103,  CurrentCmd)
				Caret_SetPosition(Pos.i)      	
	EndProcedure	
		;
   ;
	Procedure.i StrGetSet(Kommando.s, ReplaceCmd.s = "")
		
		Protected PosA.i, PosB.i, PosC.i, CmdLen.i, BorderlessCmd.i
		
		Protected CurrentCmd.s = GetGadgetText( DC::#String_103 )
		
		CmdLen = Len( CurrentCmd )
		
		PosA = FindString( CurrentCmd, Chr(37) + Kommando, 1, #PB_String_CaseSensitive)

		If ( PosA > 0 )
			;
			; Kommando entfernen
			For CharIndex = PosA To CmdLen
				
				CmdChar.s = Mid( CurrentCmd, CharIndex, 1)
				Char.c		= Asc(CmdChar)
				
				;
				; Wenn Space gehe raus
				If ( Char = 32 )
					CurrentCmd = ReplaceString(CurrentCmd, Chr(32),"", #PB_String_CaseSensitive, CharIndex, 1)	
					Break	
				EndIf
				
				If (CmdLen = CharIndex)		
					;
					; Das Ende der Zeile Erreicht
					CurrentCmd = ReplaceString(CurrentCmd, Chr(32) + Chr(Char),"", #PB_String_CaseSensitive, CharIndex-1, 1)	
					CurrentCmd = RTrim(CurrentCmd,Chr(32))
					Break
				EndIf	
				
				CharIndex-1
				CmdLen-1
				
				CurrentCmd = ReplaceString(CurrentCmd, Chr(Char),"", #PB_String_CaseSensitive, CharIndex, 1)		
			Next
			
			StrGetSet_Text(CurrentCmd.s, CharIndex-1)
			Debug "StrGetSet: ProcedureReturn 1"
			ProcedureReturn 1
		EndIf
		
		
		If ( PosA = 0 )
			
			PosA = FindString( CurrentCmd, Chr(37), 1, #PB_String_CaseSensitive)
			If ( PosA > 0 )
			;
			; Kommando nicht gefunden. Suche '%'
				For CharIndex = PosA To CmdLen
					
					CmdChar.s = Mid( CurrentCmd, CharIndex, 1)
					Char.c		= Asc(CmdChar)
					If ( Char = 37 )
						PosB = CharIndex						
					EndIf
					
				Next	
				
				;
				; Suche das enden. Gewähnlich Sapce (32)
				If ( PosB > 0 )
					For CharIndex = PosB To CmdLen
						CmdChar.s = Mid( CurrentCmd, CharIndex, 1)
						Char.c		= Asc(CmdChar)						
						
						If ( Char = 32 )
							PosC = CharIndex
							Break
						EndIf
					Next
					
					If ( PosC = 0 )
						;
						; Keine weiteren Kommandos und das Ende erreicht.
						CurrentCmd + Chr(32) +Chr(37) + Kommando
						StrGetSet_Text(CurrentCmd.s, Len( CurrentCmd ))
						Debug "StrGetSet: ProcedureReturn 2"
						ProcedureReturn 2
					EndIf
						

					CurrentCmd = ReplaceString(CurrentCmd, Chr(32),Chr(37) + Kommando + Chr(32), #PB_String_CaseSensitive,CharIndex, 1)
					StrGetSet_Text(CurrentCmd.s, CharIndex)
					Debug "StrGetSet: ProcedureReturn 3"
					ProcedureReturn 3
				EndIf	
			Else
				CurrentCmd +  Chr(37) + Kommando
				StrGetSet_Text(CurrentCmd.s, 1)
				Debug "StrGetSet: ProcedureReturn 4"
				ProcedureReturn 4
		EndIf
	EndIf
	
	Debug "StrGetSet: ProcedureReturn -1"
	ProcedureReturn -1	
	
  EndProcedure    
  	;
		; Minimize vSystems  
  Procedure vSysCMD_MiniMize()
		StrGetSet("m")
	EndProcedure	
  	;
		; Execute and Run the programm Asynchron 
  Procedure vSysCMD_Asynchron()
		StrGetSet("a")
	EndProcedure
  	;
		; Execute and Run the Programm WinApi Process
  Procedure vSysCMD_WinApi()
		StrGetSet("altexe")
	EndProcedure
  	;
		; Remove Border from Windowed Programs or Games
	Procedure.i vSysCMD_BorderlessCmdCheck(Cmd.s)
		
		Protected PosA.i, PosB.i, PosC.i,PosD.i
		          
		Protected CurrentCmd.s = GetGadgetText( DC::#String_103 ), CmpChar.s
		
		CmdLen = Len( CurrentCmd )
		
		PosA = FindString( CurrentCmd, Chr(37) + "nb", 1, #PB_String_CaseSensitive)
			If ( PosA > 0 )
			;
			; Kommando nicht gefunden. Suche '%'
				For CharIndex = PosA+1 To CmdLen
					
					CmdChar.s = Mid( CurrentCmd, CharIndex, 1)
					Char.c		= Asc(CmdChar)
					
					CmpChar.s + CmdChar
					
					If Len(CmdChar) = 4 Or char = 32 Or (CharIndex = CmdLen)
						Break;
					EndIf										
					
				Next	
				
				If Right(CmpChar, 1) = Chr(32)
					CmpChar = Left(CmpChar, Len(CmpChar)-1)
				EndIf
				
				If ( CmpChar = Cmd )
					StrGetSet(CmpChar)
					ProcedureReturn 
				EndIf
				
				If ( CmpChar = "nbcb" )
					StrGetSet(CmpChar)
				ElseIf ( CmpChar = "nbc" )
					StrGetSet(CmpChar)
				ElseIf ( CmpChar = "nbb" )						
					StrGetSet(CmpChar)					
				ElseIf ( CmpChar = "nb" )							
					StrGetSet(CmpChar)					
				EndIf

			EndIf
			
			StrGetSet(Cmd)
	
		
		
	EndProcedure
	Procedure vSysCMD_Borderless()
		
		vSysCMD_BorderlessCmdCheck("nb")	
						
	EndProcedure
  	;
		; Optional c to Center the Window
	Procedure vSysCMD_BorderlessC()
		
		vSysCMD_BorderlessCmdCheck("nbc")
		
	EndProcedure
  	;
		; Optional b to set real Borderless Window
	Procedure vSysCMD_BorderlessB()
		
		vSysCMD_BorderlessCmdCheck("nbb")
		
	EndProcedure
  	;
		; Optional b to set real Borderless Window and c to Center
	Procedure vSysCMD_BorderlessCB()		
		
		vSysCMD_BorderlessCmdCheck("nbcb")
		
	EndProcedure
  	;
		; Don't use System Metrics Calc. with Remove Border
  Procedure vSysCMD_MetricsCalc()
		StrGetSet("nbgsm")
	EndProcedure
  	;
		; Use Shift with Scroll-Lock Key as Modifier
  Procedure vSysCMD_KeyModShift()
		StrGetSet("nbkeym")
	EndProcedure
  	;
		; Disable Screen Shot Capture with Remove Border
  Procedure vSysCMD_DisableScreenShot()
		StrGetSet("nbkeym")
	EndProcedure
  	;
		; Mouse Locked for Window /Screen Mode (Only with %nb)
  Procedure vSysCMD_LockMouse()
		StrGetSet("lck")
	EndProcedure	
  	;
		; Force to Free Memory Cache on Programm (Beware!)
	Procedure vSysCMD_FreeMemory()
		
		Protected r.i
		
        Request::*MsgEx\User_BtnTextL = "Ok"
        Request::*MsgEx\User_BtnTextR = "Cancel"
        Request::*MsgEx\Return_String = "1024"
        r = Request::MSG(Startup::*LHGameDB\TitleVersion,"Freememory", "Die Speicher grenze ab wann vSystem dem Programm den Speicher entleeren soll (in MB). Funktion mit vorsicht zu genießen.",10,1,ProgramFilename(),0,1,DC::#_Window_001)
        If (r = 0)        	
        	StrGetSet("fmm" + Request::*MsgEx\Return_String)
        EndIf
                
	EndProcedure
  	;
		; Game Compatibilty: Disable Taskbar
  Procedure vSysCMD_DisableTaskbar()
		StrGetSet("tb")
	EndProcedure
  	;
		; Game Compatibilty: Disable Explorer
  Procedure vSysCMD_DisableExplorer()
		StrGetSet("ex")
	EndProcedure
  	;
		; Game Compatibilty: Disable Aero Support
  Procedure vSysCMD_DisableAero()
		StrGetSet("ux")
	EndProcedure
  	;
		; Adjust CPU Affinity from 0-63 (0 is 1 etc.. )
	Procedure.i vSysCMD_CpuAffinityCheck(Cmd.s)
		
		Protected PosA.i, PosB.i, PosC.i,PosD.i
		          
		Protected CurrentCmd.s = GetGadgetText( DC::#String_103 ), CmpChar.s
		
		CmdLen = Len( CurrentCmd )
		
		PosA = FindString( CurrentCmd, Chr(37) + "cpu", 1, #PB_String_CaseSensitive)
			If ( PosA > 0 )
			;
			; Kommando nicht gefunden. Suche '%'
				For CharIndex = PosA+1 To CmdLen
					
					CmdChar.s = Mid( CurrentCmd, CharIndex, 1)
					Char.c		= Asc(CmdChar)
					
					CmpChar.s + CmdChar
					
					If Len(CmdChar) = 4 Or char = 32 Or (CharIndex = CmdLen)
						Break;
					EndIf										
					
				Next	
				
				If Right(CmpChar, 1) = Chr(32)
					CmpChar = Left(CmpChar, Len(CmpChar)-1)
				EndIf
				
				If ( CmpChar = Cmd )
					StrGetSet(CmpChar)
					ProcedureReturn 
				EndIf
				
				If ( CmpChar = "cpu0" )
					StrGetSet(CmpChar)				
				ElseIf  ( CmpChar = "cpu1" )
					StrGetSet(CmpChar)
				ElseIf ( CmpChar = "cpu2" )
					StrGetSet(CmpChar)
				ElseIf ( CmpChar = "cpu3" )											
					StrGetSet(CmpChar)				
				ElseIf ( CmpChar = "cpuf" )							
					StrGetSet(CmpChar)							
				EndIf

			EndIf
			
			StrGetSet(Cmd)

	EndProcedure	
  Procedure vSysCMD_CpuAffinity1()
		vSysCMD_CpuAffinityCheck("cpu0")
	EndProcedure
  	;
		; Adjust CPU Affinity from 0-63 (0 is 1 etc.. )
  Procedure vSysCMD_CpuAffinity2()
		vSysCMD_CpuAffinityCheck("cpu1")
	EndProcedure
  	;
		; Adjust CPU Affinity from 0-63 (0 is 1 etc.. )
  Procedure vSysCMD_CpuAffinity3()
		vSysCMD_CpuAffinityCheck("cpu2")
	EndProcedure
  	;
		; Adjust CPU Affinity from 0-63 (0 is 1 etc.. )
  Procedure vSysCMD_CpuAffinity4()
		vSysCMD_CpuAffinityCheck("cpu3")
	EndProcedure
	  ;
		; Adjust CPU Affinity from 0-63 (0 is 1 etc.. )
  Procedure vSysCMD_CpuAffinityF()
		vSysCMD_CpuAffinityCheck("cpuf")
	EndProcedure
	  ;
		; Activate File/Directory Monitoring on C:\
  Procedure vSysCMD_Monitoring()
		StrGetSet("wmon")
	EndProcedure
	  ;
		; Block Program Executable through the Firewall
  Procedure vSysCMD_FirewallBlock()
		StrGetSet("blockfw")
	EndProcedure
	  ;
		; Placeholder For Media Device File(s) Slots
	Procedure.i vSysCMD_MediaDeviceCheck(Cmd.s, MediaDeviceNum.i)
		
		Protected PosA.i, PosB.i, PosC.i,PosD.i
		          
		Protected CurrentCmd.s = GetGadgetText( DC::#String_103 ), CmpChar.s
		
		CmdLen = Len( CurrentCmd )
		
		Protected Count.i
				
		Count = CountString( CurrentCmd, Chr(37) + "s")
		If ( count =< MediaDeviceNum )
				SetGadgetText( DC::#String_103,  "%s " + CurrentCmd)
			Caret_SetPosition(3)  
		EndIf
			
		ProcedureReturn 

	EndProcedure		
  Procedure vSysCMD_MediaDevice1()
		vSysCMD_MediaDeviceCheck("s",4)
	EndProcedure
	  ;
		; Placeholder For Media Device File(s) Slots
  Procedure vSysCMD_MediaDeviceCommand()
		StrGetSet("sc")
	EndProcedure
	  ;
		; Disable and don't show output Program loggin'
  Procedure vSysCMD_NoOutPut()
		StrGetSet("shout")
	EndProcedure
	  ;
		; Redirect and catch Program output log to file
  Procedure vSysCMD_LogRedirect()
		StrGetSet("svlog")
	EndProcedure
	  ;
		; Disable Taskill Program Hotkey [Alt+Scroll]
  Procedure vSysCMD_KeyModDisableTask()
		StrGetSet("nhkeyt")
	EndProcedure
	  ;
		; Don't use automatic doublequotes for %s Files
  Procedure vSysCMD_NoDoubleQuotes()
		StrGetSet("nq")
	EndProcedure
	  ;
		; Only For M.A.M.E. Commandline Helper
  Procedure vSysCMD_MameCMDHelp()
		StrGetSet("mmhlp")
	EndProcedure
	  ;
		; Packed Files Support for Programs with %s or Program's that has'nt builtin Packer Support. vSystems Uncompress File & give it to the Program.
  Procedure vSysCMD_PackSupport()
		StrGetSet("pk")
	EndProcedure	
		;
		;
	Procedure vSysCMD_QuickCommand()
		vSysCMD_CpuAffinityCheck("cpuf")
		StrGetSet("blockfw")
		vSysCMD_BorderlessCB()	
	EndProcedure
	  ;
		; Block Program Executable through the Firewall
  Procedure vSysCMD_SavegameSupport()
		StrGetSet("savetool")
	EndProcedure	
	Procedure vSysCMD_HelpSupport_Main()	
		
		Protected TipInfo_Text.s = #CR$ +
		                           "Einige Kommandos sind nur dann aktiviert solange das Programm läuft" 								+ #CR$ + #CR$ +		                           				
		                           "Asyncron:"																																					+ #CR$ +
		                           "Läßt das Prgramm Asyncron starten ohne das vSystems ein Auge drauf hat. Desweiteren"+ #CR$ +
		                           "sind aber dann auch Funktion nicht mehr nutzbar wie Borderless, Screenshot Capture" + #CR$ +
		                           "Savegame Backup, CPU Zugehörgkeit, Firewall Blockieren (Hinzufügen, kein entfernen)"+ #CR$ + #CR$ +		                           
		                           "Api-Nativ:"																																					+ #CR$ +
		                           "Benutzt den Windows Api Prozess zum starten des Programms anstatt des von Purebasic."+ #CR$ +
		                           "Für Spiele die ein ungewöhnliches verhalten zeigen die dennoch normal unter Windows"+ #CR$ +
		                           "Starten aber unter vSystems nicht starten (Blackscreens etc...)"										+ #CR$ + #CR$ +	
		                           "Speicher: "																																					 + #CR$ +
		                           "Damit Läßt sich die eine Speicher Grenze für das progrmm setzen. Das gilt für Spiele"+ #CR$ +
		                           "die Probleme mit dem entleeren des Speichers haben und 3.5GB Grenze nicht beachten"	+ #CR$ +
		                           "und abstürzen (für x86)"																														+ #CR$ + #CR$ +	
		                           "CPU Zugehörgkeit:"																																	+ #CR$ +
		                           "Dem Programm wird zugwiesen wieviele Kerne es für die Laufzeit nutzen soll"					+ #CR$ + #CR$ +
		                           "Firewall Blockieren:"																																+ #CR$ +
		                           "Das Programm (eher die Ausführbare Datei) wird in der Windows Firewall Blockiert. Mit"+#CR$ +
		                           "Asyncron wird der eintrag nicht aus der Windows Firewall entfernt"									+ #CR$ + #CR$ +
		                           "Disable End-Hotkey"																																	+ #CR$ +
		                           "Die Hotkey Kombination 'ALT + ROLLEN' wird ausgesschaltet"													+ #CR$ + #CR$ +
		                           "Disable Taskbar"																																		+ #CR$ +
		                           "Die Windows Taskbar wird während das Programm läuft ausgeschaltet"									+ #CR$ + #CR$ +
		                           "Disable Explorer" 																																	+ #CR$ +
		                           "Der Explorer (Oberfläche) wird während das Programm läuft ausgeschaltet"						+ #CR$ + #CR$ +
		                           "Disable Aero Support"		                           																	+ #CR$ +
		                           "Der Aero Support unter Windows 7 wird während das Programm läuft ausgeschaltet"			+ #CR$ + #CR$ +
		                           "Media Kommando"			                           																			+ #CR$ +		                           
		                           "Aktiviert die unterstützung für Programme die CD-Images, Cartdriges, HDD's (Emus)"  + #CR$ +
		                           "Levels (Ports) laden."																															+ #CR$ +
		                           "Media Kommando ++"	                          																			+ #CR$ +			                           
		                           "Ändert die Unterstützung des 1. Slots dahingehend das auch dort Programm Argumente" + #CR$ +
		                           "übergeben werden können."																														+ #CR$ + #CR$ +
		                           "Screenshot Aufnahme"																																+ #CR$ + #CR$ +	
		                           "Dieses Feature funktioniert zurzeit nur mit dem Borderless Mode (%nb) und im Fenster-"+#CR$ +		
		                           "modus zusammen (Nicht im Fullscreen Modus). Dasfür gibt es aber auch jeden menge"		+ #CR$ +
		                           "andere Programme (Afterburner, Hypersnap, Steam Selbst, nVidia im Treiber etc....)."+	#CR$ +
		                           "Taste Shift & Rollen"																																+	#CR$ + #CR$ +
		                           "Standardmäßig wird die Taste 'ROLLEN' zur Aufnhame benutzt. Mit diesem Argument wird"+#CR$ +
		                           "zusätzlich die SHIFT Taste registriert. Also SHIFT+ROLLEN"													+	#CR$ +
		                           "Hotkey Ausschalten"																																	+	#CR$ +#CR$ +
		                           "Registriert nicht den Hotkey zur Schreenshot Aufnahme"			                        +	#CR$ +  
		                           "Aktivere Monitoring"																																+ #CR$ +		                           
		                           "Zeichnet in einer Logdatei (.\LOGS\) änderungen auf welche sich auf C:\ während des"+ #CR$ +
		                           "Programms abspielen. Damit wird auch erkenntlich wo die Spielstände abgelegt werden"+ #CR$ + #CR$ +
		                           "Log Erlauben"																																				+ #CR$ +
		                           "Damit wird die Ausgabe welche das Prgramm zur Laufzeit entwickelt am Ende wenn das" + #CR$ +
		                           "Programm beendet wird in einem Requester angezeigt"																	+ #CR$ + #CR$ +
		                           "Log in Datei Schreiben"   																													+ #CR$ +
		                           "Leitet die Ausgabe in eine Datei ansatt in einem Requester (Siehe .\LOGS\)"					+ #CR$ + #CR$ +
		                           "Keine Anführungs Zeichen"																														+ #CR$ +
		                           "Verändert die Argument übergabe das Interne Anführungszeichen übrgeben werden."     + #CR$ +
		                           "Standardmäßig übergibt vSystems den Medien in den Slots intern Anführungszeichen."  + #CR$ +
		                           "Es gibt Programme die vergeben aber selbst automatisch Anführungszeichen und die"   + #CR$ +
		                           "übergabe erfolgt dann mit Doppelten Anfürhungszeichen was dann zu einem Lade Fehler"+ #CR$ +
		                           "Mit dem Argument %nq wird dies verhindert"																					+ #CR$ + #CR$ +
		                           "Archiv Unterstützung"																																+ #CR$ +
		                           "Einige Programme haben kein 7z Support oder allgmein kein Archiv support.Mit dem %pk"+#CR$ +
		                           "Argument entpackt vSystem das Archiv vor Aufruf in den Temp Ordner und ändert dahin"+ #CR$ +
		                           "auch Intern den Pfad für das Programm"
		
		
		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Argument Hilfe ",TipInfo_Text,2,0,ProgramFilename(),0,0,DC::#_Window_003)
		
	EndProcedure	
	Procedure vSysCMD_HelpSupport_Borderless()	
		Protected TipInfo_Text_Borderless.s = #CR$ +
		                                      "Diese Kommandos sind nur dann aktiviert solange das Programm läuft"			+ #CR$ + #CR$ +	
		                                      "Patch Default"																														+ #CR$ + 
		                                      "vSystems versucht die folgenden Fenstereigenschaften der Window API des" + #CR$ +
		                                      "Programm zu patchen und den Rahmen zu entfernen: (Gilt auch für alte.)"	+ #CR$ +
		                                      "- WS_Border"																															+ #CR$ +
		                                      "- WS_DLGFrame"																														+ #CR$ +
		                                      "- WS_Overlapped"																													+ #CR$ + #CR$ +
		                                      "Patch Overlapped-Window"																									+ #CR$ + 
		                                      "Zuätzlich wird die Eingenschaft WS_OverlappedWindow gepatched falls die" + #CR$ +
		                                      "Standvariante nicht nicht funktioniert"																	+ #CR$ + #CR$ +
		                                      "Patch Zentrieren"																												+ #CR$ + 
		                                      "Damit wird das Fenster auf dem Bildschirm zentriert. Die ältere Spiele"  + #CR$ +
		                                      "benutzen mitunter die Linke obere Ecke des Bildschirms und haben keine"  + #CR$ +
		                                      "Berechnung oder angabe zum Zentrieren des Fensters"											+ #CR$ + #CR$ +
		                                      "Patch Voll"																															+ #CR$ +
		                                      "Damit werden alle oberen Kommmandos verwendet."													+ #CR$ + #CR$ +
		                                      "Patch System-Metrics"																										+ #CR$ + 
		                                      "Folgende API Eigenschaften werden gepatcht und entfernt."								+ #CR$ +
		                                      "- SM_CYCAPTION"																													+ #CR$ +
		                                      "- SM_CXBORDER"																														+ #CR$ +
		                                      "- CXEDGE"																																+ #CR$ + #CR$ +
		                                      "Lock Mouse (NoGo Outside)"																								+ #CR$ + 
		                                      "Damit wird veranlaßt das die Maus das Fenster solange man in seinem Fokus"+ #CR$ +
		                                      "ist nicht verläßt. Für Spiele wo sich die Maus aus dem Fenster bewegt auf"+ #CR$ +
		                                      "Multimonitor Systemen"
		
		Request::MSG(Startup::*LHGameDB\TitleVersion, "vSystem Argument Hilfe ",TipInfo_Text_Borderless,2,0,ProgramFilename(),0,0,DC::#_Window_003)
		
	EndProcedure	 
	
	Procedure.s vSysCMD_ToolTipHelp()
		
		ToolTipInfo_Text$ = #CR$ +
		                    "Edit the Commandline directly here. Supportet Keynames are:"       + #CR$ + #CR$ +                                                                  
		                    "%m      = Minimize vSystems"                                        + #CR$ +
		                    "%a      = Execute and Run the programm Asynchron"                   + #CR$ +
		                    "%altexe = Execute and Run the Programm WinApi Process"              + #CR$ + #CR$ +
		                    "%nb[cb] = Remove Border from Windowed Programs or Games"            + #CR$ +
		                    "        + Optional c to Center the Window"                          + #CR$ +
		                    "        + Optional b to set real Borderless Window"                 + #CR$ +
		                    "        # Screenshot Capture Enbaled: Press Scroll Key"             + #CR$ +                                 
		                    "        # On Capture you hear a Beep Sound"                         + #CR$ +
		                    "%nbgsm  = Don't use System Metrics Calc. with Remove Border"        + #CR$ + #CR$ +
		                    "%nbkeym = Use Shift with Scroll-Lock Key as Modifier"               + #CR$ +
		                    "%nosht  = Disable Screen Shot Capture with Remove Border"           + #CR$ +
		                    "%lck    = Mouse Locked for Window /Screen Mode (Only with %nb)"     + #CR$ + #CR$ +  
		                    "%fmm[mb]= Force to Free Memory Cache on Programm (Beware!)"         + #CR$ +
		                    "          mb from 1 to 3000. Optional Maximum Mem before Clear."    + #CR$ + #CR$ +                                
		                    "%tb     = Game Compatibilty: Disable Taskbar"                       + #CR$ +
		                    "%ex     = Game Compatibilty: Disable Explorer"                      + #CR$ +                                
		                    "%ux     = Game Compatibilty: Disable Aero Support"                  + #CR$ + #CR$ +  
		                    "%c[arg] = Windows Compatibility Mode. Argument is:"                 + #CR$ + #CR$ +   
		                    "%cpu[x] = Adjust CPU Affinity from 0-63 (0 is 1 etc.. )"            + #CR$ +
		                    "          x can be: f to force all Cpu Units"                       + #CR$ +
		                    "          x can be: digit number from 0 to 63"                      + #CR$ + #CR$ +
		                    "%wmon   = Activate File/Directory Monitoring on C:\"                + #CR$ + #CR$ +                            
		                    "%blockfw= Block Program Executable through the Firewall"            + #CR$ + #CR$ +                                
		                    "%s[c]   = Placeholder For Media Device File(s) Slots"               + #CR$ + 
		                    "          c: use as unviersal commandline in the Slots"             + #CR$ +  
		                    "%shout  = Enable and show output Program loggin'"                   + #CR$ + 
		                    "%svlog  = Redirect and catch Program output log to file"            + #CR$ + #CR$ +
		                    "%nhkeyt = Disable Taskill Program Hotkey [Alt+Scroll]"              + #CR$ + #CR$ +                                
		                    "%nq     = Don't use automatic doublequotes for %s Files"            + #CR$ +
		                    "          (For Apps that adding automatic quotes '"+Chr(34)+"')"    + #CR$ 
		ProcedureReturn ToolTipInfo_Text$
	EndProcedure		
EndModule

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 524
; FirstLine = 236
; Folding = vTBxfEc-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\The Chaos Engine\