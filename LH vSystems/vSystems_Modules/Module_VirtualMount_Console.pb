;;===============================================================================
    ;; Module:      CLI_Helper.pbi
    ;; Version:     1,0
    ;; Date:        03.02.2010
    ;; Author:      Michael 'neotoma' Taupitz
    ;; TargetOS:    ALL.(i hope so...)
    ;; Compiler:    PureBasic >=4.4 for Windows.
    ;;
    ;; Licence:     Do as you wish with it! No warranties either implied
    ;;              or given... blah blah! :)
    ;;
    ;; Description
    ;;
    ;; CLI-Helper makes the using of the Commandline-Interface much easier.
    ;; Instead of  walking through each parameter in your code, you can define
    ;; which parameters are wanted, also if they are has arguments.
    ;;
    ;; Example:
    ;;
    ;; At first we define the wanted parameters. We have two 'names' per paremeter, a
    ;; ahort one r.g. 'm' was and a longer 'mode'. We can say if we expect a argument
    ;; and priovide a small descripetion.
    ;; You see, this looks much cleaner in your code:
    ;;
    ;; CLI_AddOption("m"  ,"mode"    ,#True ,"encode|decode" ,"Switch to a encoding or decoding mode")
    ;; CLI_AddOption("if" ,"infile"  ,#True ,"filename"      ,"Sourcefile to en/decode")
    ;; CLI_AddOption("of" ,"outfile" ,#True ,"filename"      ,"Destinationfile (will be overwritten)") 
    ;; CLI_AddOption("k"  ,"key"     ,#True ,"encryption key","Key for en/decryption") 
    ;; CLI_AddOption("h"  ,"help"    ,#False ,""             ,"Prints out this usage")
    ;; CLI_AddOption("V"  ,"version" ,#False ,""             ,"Prints out version details.")
    ;;
    ;; Next we do the scanning:
    ;;  CLI_ScanCommandline()
    ;;
    ;; Now we can ask if a parameter was found and do whatever we need to do.
    ;; ;Print Usage 
    ;; If CLI_HasOption("h")
    ;;   CLI_Usage()
    ;; EndIf
    ;;
    ;; The CLI_Usage is also very helpfull - it prints the possible Parameter with ther description.
    ;; We have also everything stored nicely in the first functions.
    ;;
    ;;
    ;; The short parameter wants a '-' (-m or -h) the longer '--' (--mode or --help).
    ;;
    ;;
    ;; Changes / History
    ;;===============================================================================

    CompilerIf #PB_Compiler_Version >= 440


    ;; - Define the information of each entry.
    Structure sCliOption
      opt.s           ; short name
      longOpt.s       ; long name
      hasArgs.i       ; bool if Argument wanted
      argName.s       ; name of the argument (for usage)
      optDescription.s; description of the parameter
      optAvailable.i  ; is option available
      optValue.s      ; value of the argument
      required.i      ; bool to remember required parameters
      foundcount.i    ; count how often a option was found
    EndStructure

    ;Here we Store the definitions
    NewMap  mapOptions.sCliOption()
    ;Here we store the found options
    NewList llOptions.sCliOption()
    ;This is our Error-Output.
;     Define CLI_ERROR_STRING.s

    ;; -----------------------------------------------------------------------------
    ;; - CLI_AddOption(opt.s, longOpt.s, hasArgs.i, argName.s, optDescription.s)
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -  Add a allowed option to the CLI.
    ;; -
    ;; - Parameters:
    ;; -  opt.s            - Short Option-Name ("m")
    ;; -  longOpt.s        - Long Option-Name ("mode")
    ;; -  hasArgs.i        - Boolean. If #True, the next entry is catched as argument
    ;; -  argName.s        - Name of the Argument for usage-output. ("filename")
    ;; -  optDescription.s - Description of the Option. Used for Usage.
    ;; -
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Nothing
    ;; -
    ;;
    Procedure CLI_AddOption(opt.s, longOpt.s, hasArgs.i, argName.s, optDescription.s)
      Shared mapOptions()
      mapOptions(opt)\opt = opt
      mapOptions(opt)\longOpt = longOpt
      mapOptions(opt)\hasArgs = hasArgs
      mapOptions(opt)\argName = argName
      mapOptions(opt)\optDescription = optDescription
      mapOptions(opt)\optAvailable = #False
      mapOptions(opt)\foundcount = 0
    EndProcedure


    ;; -----------------------------------------------------------------------------
    ;; - CLI_ScanComandline()
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Scans the Commandline. Make Sure you defined the possible options before.
    ;; -
    ;; - Parameters:
    ;; -
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Nothing
    ;; -
    ;;
    Procedure CLI_ScanCommandline()
      Shared mapOptions(), llOptions()

      Protected pcount.i = CountProgramParameters()
      Protected param.s
      Protected i.i = 0
     
      While i < pcount
        param = ProgramParameter(i)
        ForEach mapOptions()
          If param = "-"+mapOptions()\opt Or  param= "--"+mapOptions()\longOpt
            AddElement( llOptions() )
            llOptions()\opt = mapOptions()\opt
            llOptions()\longOpt= mapOptions()\longOpt
            llOptions()\hasArgs= mapOptions()\hasArgs
            llOptions()\optDescription= mapOptions()\optDescription
            llOptions()\optAvailable = #True       
            mapOptions()\foundcount + 1
            If mapOptions()\hasArgs
              i+1         
              llOptions()\optValue = ProgramParameter(i)
              mapOptions()\optValue = llOptions()\optValue 
            EndIf
          EndIf
        Next
       
        i+1
      Wend
    EndProcedure

    ;; -----------------------------------------------------------------------------
    ;; - CLI_HasOption(opt.s)
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Checks if the option (opt.s) was found on the commandline
    ;; -
    ;; - Parameters:
    ;; -    opt.s  - Short name of the option
    ;; -----------------------------------------------------------------------------
    ;; - Returns: #True if the Options was found, otherwise #False
    ;; -
    ;;
    Procedure.i CLI_HasOption(opt.s)
      Shared llOptions()
      Protected RetVal.i = #False
      ForEach  llOptions() 
        If llOptions()\opt = opt Or llOptions()\longOpt = opt
          RetVal = #True
          Break
        EndIf
      Next
      ProcedureReturn RetVal
    EndProcedure 

    ;; -----------------------------------------------------------------------------
    ;; - CLI_GetOptionValue(opt.s)
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Returns the argument of the option (opt.s).
    ;; -
    ;; - Parameters:
    ;; -    opt.s  - Short name of the option
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Argument of the Option
    ;; -
    ;;
    Procedure.s CLI_GetOptionValue(opt.s)
      Shared llOptions()
      ForEach  llOptions() 
        If llOptions()\opt = opt Or llOptions()\longOpt = opt
          ProcedureReturn llOptions()\optValue
        EndIf
      Next
      ProcedureReturn ""
    EndProcedure 
             
    ;; -----------------------------------------------------------------------------
    ;; - CLI_SetRequired(opt.s, bReq.i = #True) 
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Set the option (opt) to required.
    ;; -
    ;; - Parameters:
    ;; -    opt.s  - Short name of the option
    ;; -    bReq.i - (optional) the Falg. if #True the Option is marked as required.
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Nothing
    ;; -
    ;;
    Procedure CLI_SetRequired(opt.s, bReq.i = #True) 
      Shared mapOptions()
      If FindMapElement(mapOptions(),opt)
        mapOptions(opt)\required = bReq
      EndIf
    EndProcedure

    ;; -----------------------------------------------------------------------------
    ;; - CLI_isRequired(opt.s) 
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Checks if a option was required
    ;; -
    ;; - Parameters:
    ;; -    opt.s  - Short name of the option
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Required-Flag
    ;; -
    ;;
    Procedure CLI_isRequired(opt.s) 
      Shared mapOptions()
      ProcedureReturn mapOptions(opt)\required
    EndProcedure


    ;; -----------------------------------------------------------------------------
    ;; - CLI_CheckRequired() 
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Checks if a required option was missing.
    ;; -   For each missed option it prompts a Info to the Commandline.
    ;; -
    ;; -----------------------------------------------------------------------------
    ;; - Returns: #False if one or more required options missed
    ;; -
    ;;
    Procedure.i CLI_CheckRequired() 
      Shared mapOptions()
      Protected  retVal = #True
       
      ForEach mapOptions()
        If mapOptions()\required And mapOptions()\foundcount > 0
        	Print("-"+mapOptions()\opt)
          If mapOptions()\hasArgs
            Print(" <"+mapOptions()\argName+">")
          EndIf
          Print(" is Missing!")
          PrintN("")
          retVal = #False
        EndIf
      Next
      ProcedureReturn RetVal
    EndProcedure

    
    ;; -----------------------------------------------------------------------------
    ;; - CLI_CheckRequired() 
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Checks if a required argument option was missing.
    ;; -   For each missed option it prompts a Info to the Commandline.
    ;; -
    ;; -----------------------------------------------------------------------------
    ;; - Returns: #False if one or more required options missed
    ;; -
    ;;
    Procedure.i CLI_CheckRequiredOpt() 
      Shared mapOptions()
      Protected  retVal = #True
       
      ForEach mapOptions()
        If mapOptions()\required And mapOptions()\foundcount > 0 And mapOptions()\optValue = ""
        	Print("-"+mapOptions()\opt)
          If mapOptions()\hasArgs
            Print(" <"+mapOptions()\argName+">")
          EndIf
          Print(" is Missing!")
          PrintN("")
          retVal = #False
        EndIf
      Next
      ProcedureReturn RetVal
    EndProcedure
    
    ;; -----------------------------------------------------------------------------
    ;; - CLI_Usage()
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Prints a Usage-Information to the Commandline.
    ;; -   The output is based on the defined Options.
    ;; -
    ;; - Parameters:
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Nothing
    ;; -
    ;;
    Procedure CLI_Usage()
      Shared mapOptions()
      Protected strTemp.s = "  Usage:"
     
      ForEach mapOptions()
        If mapOptions()\hasArgs
          strTemp +" [-"+mapOptions()\opt+" <"+mapOptions()\argName+">]"
        Else
          strTemp +" [-"+mapOptions()\opt+"]"
        EndIf
      Next
      
      PrintN(strTemp)
      PrintN("")    
      
      ForEach mapOptions()
        strTemp = " -"+mapOptions()\opt+",--"+mapOptions()\longOpt
        If mapOptions()\hasArgs
          strTemp+" <"+mapOptions()\argName+">"
        EndIf
       
        PrintN( " " + LSet(strTemp, 40, " ") + mapOptions()\optDescription )
      Next         

    EndProcedure 

    ;; -----------------------------------------------------------------------------
    ;; - CLI_HelpPrinter(Header.s, Footer.s)
    ;; -----------------------------------------------------------------------------
    ;; - Description:
    ;; -   Prints the Header, the Usage and Footer
    ;; -
    ;; - Parameters:
    ;; -----------------------------------------------------------------------------
    ;; - Returns: Nothing
    ;; -
    ;;
    Procedure CLI_HelpPrinter(Header.s, Footer.s)
      PrintN(Header)
      PrintN(RSet("",Len(Header),"-"))
      PrintN("")
      CLI_Usage()
      PrintN(Footer)
      PrintN("")
    EndProcedure 

    CompilerElse
      CompilerError "CLI_Helper needs PureBasic 4.40 or greater. (Maps)"
    CompilerEndIf
                            
      
		;Man gibt vorher an, welche Parameter erwartet werden:
		;CLI_AddOption("m"  ,"mode"    	,#True ,"encode|decode" ,"Switch to a encoding or decoding mode")
		;CLI_AddOption("h"  ,"help"    	,#False ,""     	,"Prints out this usage")
		;CLI_AddOption("V"  ,"version" 	,#False ,""     	,"Prints out version details.")
    
		 CLI_AddOption("m"  ,"mount" 		,#True 	,"drive" 	,"Drive Letter to Mount")    
		 CLI_AddOption("d"  ,"dir"			,#True 	,"folder"	,"Directory Path (Optional)")    
		 CLI_AddOption("n"  ,"noaero" 	,#False ,""				,"Disable Aero Background")
     CLI_AddOption("w"  ,"nowait" 	,#False ,""				,"Disable User Input. Autoquit")			 

		 CLI_SetRequired("m")
		 CLI_SetRequired("d")		 
		 
		 
		;Dann l‰ﬂt man die Programmparameter scannen
		 CLI_ScanCommandline()		
		 		 
		;Nun lassen sich die Kommandozeilenparameter abfragen:
		;Print Usage 
		; If CLI_HasOption("h")
		;   CLI_Usage()
		; EndIf

		;Autor: SFSxOI, ts-soft
		 
		 ; ------------------------------------------------------------------------------------------------------------
		 ; vSystems Virtual Drive Mount
		 ; Commandline Standalone Tool to make old games that have terrible programming code, like IIlussion's (RIP) 
		 ; Des Blood Racing, run well with a few GetDriveType changes.
		 ; ------------------------------------------------------------------------------------------------------------
		 
Define ConsoleHandle
	
Import "Kernel32.lib"
    GetConsoleWindow.l() As "GetConsoleWindow"	
    GetVolumeNameForVolumeMountPoint.l(*VolumeMountPoint, *VolumeName, Length.l) As "GetVolumeNameForVolumeMountPointW"
EndImport

  
	#DWM_BB_ENABLE 								= 1
	#DWM_BB_BLURREGION 						= 2
	#DWM_BB_TRANSITIONONMAXIMIZED = 4

	Structure DWM_BLURBEHIND
	  dwFlags.l
	  fEnable.b
	  hRgnBlur.l
	  fTransitionOnMaximized.b
	EndStructure

Procedure EnableBlurBehindWindow(hWnd, enable.b = #True, region.l = 0, transitionOnMaximized.b = #False)
	Protected blurBehind.DWM_BLURBEHIND
	Protected Lib
	Protected *pAfunc
	
	blurBehind\dwFlags = #DWM_BB_ENABLE | #DWM_BB_TRANSITIONONMAXIMIZED
	;blurBehind\dwFlags = #DWM_BB_ENABLE
	blurBehind\fEnable = enable
	blurBehind\fTransitionOnMaximized = transitionOnMaximized
	
	;Lib = LoadLibrary_("dwmapi.dll")
	Lib = OpenLibrary(#PB_Any, "dwmapi.dll")
	If Lib
		If (enable And 0) <> region
			blurBehind\dwFlags = #DWM_BB_BLURREGION
			blurBehind\hRgnBlur = region
		EndIf
		;*pAfunc = GetProcAddress_(Lib, "DwmEnableBlurBehindWindow")
		*pAfunc = GetFunction(Lib,  "DwmEnableBlurBehindWindow")
		CallFunctionFast(*pAfunc, hWnd, @blurBehind)
		;FreeLibrary_(Lib)
		CloseLibrary(Lib)
	EndIf
	
	ProcedureReturn
EndProcedure

; ------------------------------------------------------------------------------------------------------------

Procedure.s GetDriveType(Drive$)
  Protected result
  
  result=GetDriveType_(Drive$+":\")
  Select result
  		; Case 1
			; DRIVE_NO_ROOT_DIR
  		; The root path is invalid; for example, there is no volume mounted at the specified path.
  	Case 2
  		; DRIVE_REMOVABLE
  		; The drive has removable media; for example, a floppy drive, thumb drive, or flash card reader.
    	ProcedureReturn "Removable Media [Floppy or USB]";"Diskettenlaufwerk"    	
    Case 3
    	; DRIVE_FIXED
    	; The drive has fixed media; for example, a hard disk drive or flash drive.
      ProcedureReturn "HD [Hard Disk]";"Festplatte"
    Case 4
    	; DRIVE_REMOTE
    	; The drive is a remote (network) drive.
      ProcedureReturn "Network";"Netzwerk"
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
Procedure.s GetLastError()
  Protected ErrorBufferPointer.L
  Protected ErrorCode.L
  Protected ErrorText.S
  Protected ferr
  
  ErrorCode = GetLastError_()
  ferr = FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER | #FORMAT_MESSAGE_FROM_SYSTEM, 0 , ErrorCode, GetUserDefaultLangID_(), @ErrorBufferPointer, 0, 0)
  If ErrorBufferPointer <> 0
    ErrorText = PeekS(ErrorBufferPointer)
    LocalFree_(ErrorBufferPointer)
    ProcedureReturn RemoveString(ErrorText, #CRLF$)
  EndIf
  
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
Procedure   MountVirtual_CommandLong(MountCommand.s)
	
			If Len( MountCommand )	> 1
				PrintN("Command Argument to long. Taking only the First Ascii letter...")
			EndIf
			
EndProcedure
;
;
Procedure.i MountVirtualDrive()
	
	Protected MountCommand.s, MountDrive.s , CheckDriveTyp.s, MountDirectory.s, Result.i, VolumeMountPoint.s, VolumeName.s = Space(255)

	
	MountCommand = CLI_GetOptionValue("m")
	
	If CLI_HasOption("d")
		
		If CLI_CheckRequiredOpt() = #False
			ProcedureReturn
		Else
			
			MountDirectory = CLI_GetOptionValue("d")
			If FileSize( MountDirectory ) = -2 
				MountDirectory 	= RemoveDirectorySlash(MountDirectory)
			Else
				PrintN("")
				PrintN(" Error Directory Not found :... ")
				PrintN(" > " + Chr(34) + MountDirectory + Chr(34))
				ProcedureReturn 
			EndIf	
			
		EndIf		
		
	Else
		MountDirectory 	= RemoveDirectorySlash(GetCurrentDirectory())
	EndIf
		
			
	For i=0 To Len(MountCommand)
		
		char.c = Asc(Left(MountCommand,1))
		If ( char.c >= 65 And char.c <= 90 ) Or ( char.c >= 97 And char.c <= 122 )
			Break
		Else
			PrintN("")
			PrintN(" Can't Mount Drive: " +Chr(34) + UCase(Chr(char)) + ":\"+ Chr(34) +" [Drive Letter Not Allowed]")					
			ProcedureReturn
			Break
		EndIf
	Next	
	
	MountDrive 			= UCase(Chr(char))							
	MountVirtual_CommandLong(MountCommand.s)		
	
	
	CheckDriveTyp = GetDriveType(MountDrive)
	If ( CheckDriveTyp = "" )
		; Mounting
		PrintN("")		
		PrintN(" Assigned : " +Chr(34) + UCase(Chr(char)) + ":\"+ Chr(34) )
		PrintN(" Directory: " +Chr(34) + MountDirectory + "\" + Chr(34) )
		
		Result = DefineDosDevice_(0, MountDrive +":" ,MountDirectory)
		If ( Result > 0 )
				PrintN("")
				PrintN(" " + GetLastError())				
		EndIf
		
		ProcedureReturn 
		
	Else
		
		If FileSize( MountDirectory ) = -2 
			
			If ( CheckDriveTyp = "HD [Hard Disk]" ) Or ( CheckDriveTyp = "Network")					
				
				;
				; Remove Mount Drive Automatisch wenn
				; - der Laufwerksbuchstaben vergegeben ist
				; - keine Guid ID bekommt	
				; - sich es um eine HD oder Network handelt
				VolumeMountPoint = UCase(Chr(char)) + ":\"
				Result = GetVolumeNameForVolumeMountPoint(@VolumeMountPoint, @VolumeName, 255)
				If ( Result = 0 )
					
					Result = DefineDosDevice_(#DDD_REMOVE_DEFINITION|#DDD_EXACT_MATCH_ON_REMOVE ,MountDrive +":" ,MountDirectory)
					If ( Result > 0 )					
						PrintN(" Successfully Removed...")
						PrintN(" Mounted Drive :... " +Chr(34) + UCase(Chr(char)) + ":\"+ Chr(34))
						PrintN(" Directory was :... " +Chr(34) + MountDirectory + Chr(34))
						PrintN("")
						PrintN(" " + GetLastError())						
						ProcedureReturn 
						
					Else					
						PrintN("")					
						PrintN(" " + GetLastError())
						PrintN("")						
						
					EndIf
					
					PrintN(" HDD:... ")
					PrintN(" GUID-Pfad: " + VolumeName)		
					
				EndIf																					
			EndIf			
		EndIf
		
		PrintN("")
		PrintN(" Can't Mount " +Chr(34) + UCase(Chr(char)) + ":\"+ Chr(34) + " as a Virtual Drive  because is mounted as " + CheckDriveTyp + " Volume.")
	EndIf							
EndProcedure
;
;
Procedure.i MountVirtualConsoleWait(ConsoleHandle)
	
	
	PrintN("")	
	PrintN(" ------------------------------------------------------------------------------")		
	
	If CLI_HasOption("w")
		CloseConsole()
		ProcedureReturn 
	EndIf
	
	PrintN(" Press a key to Quit")
	Input()	
	PrintN(" Close...")
	Delay(1000)	
	CloseConsole()	
	If CLI_HasOption("n")
	Else	
		EnableBlurBehindWindow(ConsoleHandle,#False)
	EndIf
	
EndProcedure


If OpenConsole("vSystems Virtual Drive Mount")
	
	ConsoleHandle = GetConsoleWindow()

	SetConsoleCtrlHandler_(?ConsoleCtrlHandler, #True)
	
	EnableGraphicalConsole(1)
	
	PrintN("")
	PrintN(" vSystems Virtual Mount v0.01")
	PrintN(" A standalone part of vSystems by Marty Shepard")
	PrintN(" Quick Assign and Mount a Drive to a Directory.")
	PrintN("")
	PrintN(" ------------------------------------------------------------------------------")	
	
	If CLI_HasOption("n")
	Else	
		EnableBlurBehindWindow(ConsoleHandle)
	EndIf
				
	If CLI_HasOption("m")
		If CLI_CheckRequiredOpt() = #False
			
		Else
 			MountVirtualDrive()
			MountVirtualConsoleWait(ConsoleHandle)
			End
		EndIf		
	EndIf
	
	CLI_Usage()
	MountVirtualConsoleWait(ConsoleHandle)
	
EndIf

End

ConsoleCtrlHandler:
PrintN("")
PrintN(" Close...")
Delay(1000)

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; ExecutableFormat = Console
; CursorPosition = 378
; FirstLine = 240
; Folding = BAg-
; EnableAsm
; EnableThread
; EnableXP
; EnableAdmin
; DPIAware
; UseIcon = Data_Images\Icon\icon pro vdm.ico
; Executable = ..\..\Includes\vSysVDM.exe
; CommandLine = -m x -d "B:\golden Ball - Completion Language Pack 1.0"
; CurrentDirectory = B:\Golden Ball - Completion Language Pack 1.0\