DeclareModule RegsTool
	
	Declare.i	Keys_RegistryFile_Check()
	
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
	
	
	
  Structure FILE_REGISTRYCFG
  	Path.s								; Config Path
    File.s								; vSystems-RegistrySupport.ini
    Handle.i        				; Datei Handle für die Registry Dateien
  EndStructure   	
	
	;
	;
	Procedure.i ConfigFile_Read()		
			Startup::*LHGameDB\RegsTool\Configandle =  ReadFile( #PB_Any,  Startup::*LHGameDB\RegsTool\ConfigFile )
	EndProcedure	
	
	Procedure.i	Keys_UpdatePath()
	EndProcedure
	
	Procedure.i	Keys_RegistryFile_Check()
		
		Protected rHandle = ReadFile( #PB_Any,  "D:\NewGame\Systeme\REGS\AG-A Installation.reg" )
		
  	If ( rHandle )
  		  		
  		While Eof( rHandle ) = 0
  			  				
  			ItemData.s = ReadString(rHandle)		
  			Debug ItemData
  		Wend
  	EndIf
		
	EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 44
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\NewGame\