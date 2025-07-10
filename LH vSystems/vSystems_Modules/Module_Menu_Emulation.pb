;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule PortsHelp
	Structure CmpPortModus		
         PortIDX.i
         PortModus.s					; prg_Commands$
         Description.s		; prgDescriptn$
         Port_ShortName.s			; 
         Path_Default.s				; Path_Default$
         File_Default.s				; File_Default$
         WorkFolder.s
         MediaDeviceA.s
         MediaDeviceB.s
         MediaDeviceC.s
         MediaDeviceD.s         
         MenuItemText.s
         MenuIndex.i         
         bCharSwitch.i
         bMenuSubBeg.i
         bMenuSubEnd.i
         bMenuBar.i
         MenuImageID.i
     EndStructure        
          
     Global NewList PortCommandline.CmpPortModus()   
     
     Declare   DataModes(List PortCommandline.CmpPortModus())
     Declare.i GetMaxItems()
     Declare.i GetMaxMnuIndex()
     Declare.i SetMnuIndexNum()
     
EndDeclareModule

Module PortsHelp
	Procedure DataModes(List PortCommandline.CmpPortModus())
		
			; 
			; Dosbox Optionals
		; ============================================================================================================================================================================			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "DOSBox Optionals" 							:PortCommandline()\bMenuSubBeg = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description				= "System: MS-DOS"
			PortCommandline()\PortModus  			 	= "conf %s -conf %s %a"			
			PortCommandline()\Port_ShortName 		= "DOSBox"
			PortCommandline()\MenuItemText    	= "Load MS-DOS" 
			PortCommandline()\File_Default 			= ".\Systeme\" + PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			PortCommandline()\WorkFolder				= ".\Systeme\"
			PortCommandline()\MediaDeviceA			= ".\Systeme\DATA\ConfigDOS.conf"
			PortCommandline()\MediaDeviceB			= ".\InSerie\[ MS-DOS ]\CONFIGS\DOS-GAME.CONF"			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description				= "System: Windows 3.x"
			PortCommandline()\PortModus  			 	= "conf %s -conf %s %a"			
			PortCommandline()\Port_ShortName 		= "DOSBox"
			PortCommandline()\MenuItemText    	= "Load Windows 3.x" 
			PortCommandline()\File_Default 			= ".\Systeme\" + PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			PortCommandline()\WorkFolder				= ".\Systeme\"
			PortCommandline()\MediaDeviceA			= ".\Systeme\DATA\ConfigW31.conf"
			PortCommandline()\MediaDeviceB			= ".\InSerie\[ WIN-31 ]\CONFIGS\WIN3X-GAME.CONF"
			
			AddElement(PortCommandline()):
			PortCommandline()\Description				= "System: Windows 95"
			PortCommandline()\PortModus  			 	= "conf %s -conf %s %a"			
			PortCommandline()\Port_ShortName 		= "DOSBox"
			PortCommandline()\MenuItemText    	= "Load Windows 95" 
			PortCommandline()\File_Default 			= ".\Systeme\" + PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			PortCommandline()\WorkFolder				= ".\Systeme\"
			PortCommandline()\MediaDeviceA			= ".\Systeme\DATA\ConfigW95.conf"
			PortCommandline()\MediaDeviceB			= ".\InSerie\[ WIN-95 ]\CONFIGS\WIN95-GAME.CONF"
			
			AddElement(PortCommandline()):
			PortCommandline()\Description				= "System: Windows 98"
			PortCommandline()\PortModus  			 	= "conf %s -conf %s %a"			
			PortCommandline()\Port_ShortName 		= "DOSBox"
			PortCommandline()\MenuItemText    	= "Load Windows 98" 
			PortCommandline()\File_Default 			= ".\Systeme\" + PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			PortCommandline()\WorkFolder				= ".\Systeme\"
			PortCommandline()\MediaDeviceA			= ".\Systeme\DATA\ConfigW98.conf"
			PortCommandline()\MediaDeviceB			= ".\InSerie\[ WIN-98 ]\CONFIGS\WIN98-GAME.CONF"
			
			AddElement(PortCommandline()):
			PortCommandline()\Description				= "System: Windows ME"
			PortCommandline()\PortModus  			 	= "conf %s -conf %s %a"			
			PortCommandline()\Port_ShortName 		= "DOSBox"
			PortCommandline()\MenuItemText    	= "Load Windows Millenium" 
			PortCommandline()\File_Default 			= ".\Systeme\" + PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			PortCommandline()\WorkFolder				= ".\Systeme\"
			PortCommandline()\MediaDeviceA			= ".\Systeme\DATA\ConfigWME.conf"
			PortCommandline()\MediaDeviceB			= ".\InSerie\[ WIN-98 ]\CONFIGS\WIN98-GAME.CONF"
			
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  	:PortCommandline()\Description = ""  :PortCommandline()\bMenuSubEnd = #True	
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Pc DOS" :PortCommandline()\bMenuSubBeg = #True  		
		AddElement(PortCommandline()):
			PortCommandline()\Description	= "PC MsDOS: DOSBox"
			PortCommandline()\PortModus  			 	= "-conf %s -nocosole"
			PortCommandline()\Port_ShortName 		= "Dosbox"
			PortCommandline()\MenuItemText    	= "Variant: No Console & use Config"				
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
							
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "PC MsDOS: DOSBox-X"
			PortCommandline()\PortModus  			 	= "-conf %s -nocosole"
			PortCommandline()\Port_ShortName 		= "Dosbox-X"
			PortCommandline()\MenuItemText    	= "Variant: No Console & use Config"				
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True				
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
		AddElement(PortCommandline()):
			PortCommandline()\Description	= "Port: ScummVM"
			PortCommandline()\PortModus  			 	= "-no-console -c %s"
			PortCommandline()\Port_ShortName 		= "ScummVM"
			PortCommandline()\MenuItemText    	= "Variant: No Console & use Config"				
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True	
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
    AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================					
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "Support: Ports/ Nativ" :PortCommandline()\bMenuSubBeg = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Doom 1"
			PortCommandline()\PortModus  			 	= "-wnd -game doom1 -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Doom 1" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Doom 1 (Ultimate)"
			PortCommandline()\PortModus  			 	= "-wnd -game doom1-ultimate -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Doom 1 Ultimate"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Doom 1 Shareware"
			PortCommandline()\PortModus  			 	= "-wnd -game doom1-share -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Doom 1 Shareware" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Doom 2"
			PortCommandline()\PortModus  			 	= "-wnd -game doom2 -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Doom 2" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Doom 2 Plutonia"
			PortCommandline()\PortModus  			 	= "-wnd -game doom2-plut -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Plutonia"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
 			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: TNT Evilution"
			PortCommandline()\PortModus  			 	= "-wnd -game doom2-tnt -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: TNT"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
						 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Chex Quest"
			PortCommandline()\PortModus  			 	= "-wnd -game chex -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: CheX Quest"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: HacX"
			PortCommandline()\PortModus  			 	= "-wnd -game hacx -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: HacX"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Heretic 1 Shareware"
			PortCommandline()\PortModus  			 	= "-wnd -game heretic-share -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Heretic 1" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Heretic 1"
			PortCommandline()\PortModus  			 	= "-wnd -game heretic -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Serpent Riders"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Heretic 1 Serpent Riders"
			PortCommandline()\PortModus  			 	= "-wnd -game heretic-ext -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Shareware"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Hexen 1 Demo"
			PortCommandline()\PortModus  			 	= "-wnd -game hexen-demo -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Hexen 1"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Hexen 1"
			PortCommandline()\PortModus  			 	= "-wnd -game hexen -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: DeathKings"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "DoomsDay: Hexen 1 DeathKings"
			PortCommandline()\PortModus  			 	= "-wnd -game hexen-dk -iwad %s"			
			PortCommandline()\Port_ShortName 		= "DoomsDay"
			PortCommandline()\MenuItemText    	= "DoomsDay: Shareware"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "D2X-XL: Descent 1 and 2"
			PortCommandline()\PortModus  			 	= "-fullscreen 0 -userdir %s"			
			PortCommandline()\Port_ShortName 		= "D2X-XL"
			PortCommandline()\MenuItemText    	= "D2X-XL: Descent 1 and 2"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "eDuke32: WW2 GI"
			PortCommandline()\PortModus  			 	= "-ww2gi -j%s"
			PortCommandline()\Port_ShortName 		= "eDuke32"
			PortCommandline()\MenuItemText    	= "eDuke32: Mod WW2 GI "			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "eDuke32: NAM (Napalm)"
			PortCommandline()\PortModus  			 	= "-nam -j%s"
			PortCommandline()\Port_ShortName 		= "eDuke32"
			PortCommandline()\MenuItemText    	= "eDuke32: Mod NAM (Napalm) "			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "eDuke32: Duke Nukem 3D"
			PortCommandline()\PortModus  			 	= "-j%s"
			PortCommandline()\Port_ShortName 		= "eDuke32"
			PortCommandline()\MenuItemText    	= "eDuke32: Default"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "eDuke32: Duke Nukem 3D (Doppelt)"
			PortCommandline()\PortModus  			 	= "-j%s"
			PortCommandline()\Port_ShortName 		= "eDuke32"
			PortCommandline()\MenuItemText    	= "eDuke32: Default"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Windows: Media Player 32Bit"
			PortCommandline()\PortModus  			 	= "%s /Fullscreen"
			PortCommandline()\Port_ShortName 		= "wmplayer"
			PortCommandline()\MenuItemText    	= "32 Bit: Movie Load/ Fullscreen"			
			PortCommandline()\File_Default 			= "C:\Program Files (x86)\Windows Media Player\"+PortCommandline()\Port_ShortName+".exe"	:PortCommandline()\Path_Default = "C:\Program Files (x86)\Windows Media Player" :PortCommandline()\bCharSwitch = #True
			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Windows: Media Player 64Bit"
			PortCommandline()\PortModus  			 	= "%s /Fullscreen"
			PortCommandline()\Port_ShortName 		= "wmplayer"
			PortCommandline()\MenuItemText    	= "64 Bit: Movie Load/ Fullscreen"			
			PortCommandline()\File_Default 			= "C:\Program Files\Windows Media Player\"		 +PortCommandline()\Port_ShortName+".exe"	:PortCommandline()\Path_Default = "C:\Program Files\Windows Media Player" 				:PortCommandline()\bCharSwitch = #True
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Arcade" :PortCommandline()\bMenuSubBeg = #True 	
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Arcade: Final Burn Alpha"
			PortCommandline()\PortModus  			 	= "%name -r 640x480x32"
			PortCommandline()\Port_ShortName 		= "FinalBurn"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Arcade: M.A.M.E"
			PortCommandline()\PortModus  			 	= "%s -skip_gameinfo -nowindow"
			PortCommandline()\Port_ShortName 		= "Variant: Load Default Rom"
			PortCommandline()\MenuItemText    	= "Mame"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Aracdia 2001" :PortCommandline()\bMenuSubBeg = #True 	
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Emerson Aracdia 2001"
			PortCommandline()\PortModus  			 	= "arcadia -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Adventure Vision" :PortCommandline()\bMenuSubBeg = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Entex Adventure Vision"
			PortCommandline()\PortModus  			 	= "advision -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Amstrad" :PortCommandline()\bMenuSubBeg = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amstrad CPC4-64"
			PortCommandline()\PortModus  			 	= "cpc464 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CPC4-64"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amstrad CPC4-64+"
			PortCommandline()\PortModus  			 	= "cpc464p -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CPC4-64/ Plus"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Atari" :PortCommandline()\bMenuSubBeg = #True 			
		AddElement(PortCommandline()):
		
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari 400"
			PortCommandline()\PortModus  			 	= "a400 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari 800/800XL"
			PortCommandline()\PortModus  			 	= "a800 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari 2600"
			PortCommandline()\PortModus  			 	= "a2600 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari 5200"
			PortCommandline()\PortModus  			 	= "5200 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari 7800"
			PortCommandline()\PortModus  			 	= "7800 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"	
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari Lynx"
			PortCommandline()\PortModus  			 	= "lynx -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari Jaguar: VirtualJaguar"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "VirtualJaguar"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari Jaguar (Cart)"
			PortCommandline()\PortModus  			 	= "jaguar -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"	
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari Jaguar (CD)"
			PortCommandline()\PortModus  			 	= "jaguarcd -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Atari: SteamSSE (Family)"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "SteamSSE"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
				
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari-ST: Hatari"
			PortCommandline()\PortModus  			 	= "--disk-a %s --machine st --memsize 2 --drive-b false -vdi false"
			PortCommandline()\Port_ShortName 		= "Hatari"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 1x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari-ST: Hatari"
			PortCommandline()\PortModus  			 	= "--disk-a %s --disk-b %s --machine st --memsize 2 --drive-b false -vdi false"
			PortCommandline()\Port_ShortName 		= "Hatari"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 1x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari-TT: Hatari"
			PortCommandline()\PortModus  			 	= "--disk-a %s --machine tt --cpulevel 68020 --memsize 4 --drive-b false -vdi false"
			PortCommandline()\Port_ShortName 		= "Hatari"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 1x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari-TT: Hatari"
			PortCommandline()\PortModus  			 	= "--disk-a %s --disk-b %s --machine tt --cpulevel 68020 --memsize 4 --drive-b false -vdi false"
			PortCommandline()\Port_ShortName 		= "Hatari"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 2x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari Falcon: Hatari"
			PortCommandline()\PortModus  			 	= "--disk-a %s --machine falcon --cpulevel 68060 --memsize 14 --drive-b false -vdi false"
			PortCommandline()\Port_ShortName 		= "Hatari"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 1x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari Falcon: Hatari"
			PortCommandline()\PortModus  			 	= "--disk-a %s --disk-b %s --machine falcon --cpulevel 68060 --memsize 14 --drive-b false -vdi false"
			PortCommandline()\Port_ShortName 		= "Hatari"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 2x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST (DE) [1 Drive]"
			PortCommandline()\PortModus  			 	= "st_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST (DE) [2 Drive]"
			PortCommandline()\PortModus  			 	= "st_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM    
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST (US) [1 Drive]"
			PortCommandline()\PortModus  			 	= "st -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
 			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST (US) [2 Drives]"
			PortCommandline()\PortModus  			 	= "st -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  							
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST/e (DE) [1 Drive]"
			PortCommandline()\PortModus  			 	= "ste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST/e (DE) [2 Drive]"
			PortCommandline()\PortModus  			 	= "ste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM    
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST/e (US) [1 Drive]"
			PortCommandline()\PortModus  			 	= "ste -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari ST/e (US) [2 Drives]"
			PortCommandline()\PortModus  			 	= "ste -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  							
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST (DE) [1 Drive]"
			PortCommandline()\PortModus  			 	= "megast_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST (DE) [2 Drive]"
			PortCommandline()\PortModus  			 	= "megast_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST (US) [1 Drive]"
			PortCommandline()\PortModus  			 	= "megast -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST (US) [2 Drives]"
			PortCommandline()\PortModus  			 	= "megast -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  	  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST/e (DE) [1 Drive]"
			PortCommandline()\PortModus  			 	= "megaste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST/e (DE) [2 Drive]"
			PortCommandline()\PortModus  			 	= "megaste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [DE]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM    
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST/e (US) [1 Drive]"
			PortCommandline()\PortModus  			 	= "megaste -skip_gameinfo -wd1772:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Atari MegaST/e (US) [2 Drives]"
			PortCommandline()\PortModus  			 	= "megaste -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drive [US]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   			
						
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Apple" :PortCommandline()\bMenuSubBeg = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple 1"
			PortCommandline()\PortModus  			 	= "apple1 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  							
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //+"
			PortCommandline()\PortModus  			 	= "apple2p -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [Plus]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
        
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //c"
			PortCommandline()\PortModus  			 	= "apple2c -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//c]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //c (OME)"
			PortCommandline()\PortModus  			 	= "apple2c3 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//c OME]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //c (Rev4)"
			PortCommandline()\PortModus  			 	= "apple2c4 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//c Rev 4]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //c (Unidisk 3.5)"
			PortCommandline()\PortModus  			 	= "apple2c0 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//c Unidisk]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //c (Plus)"
			PortCommandline()\PortModus  			 	= "apple2cp -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//c Plus]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //e (Cartdrige)"
			PortCommandline()\PortModus  			 	= "apple2e -cart %s -skip_gameinfo -gameio joy"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//e]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //e (Floppy)"
			PortCommandline()\PortModus  			 	= "apple2e -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Flop Load [//e]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //e (Enhanced)"
			PortCommandline()\PortModus  			 	= "apple2ee -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//e Enhanced]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //e (Enhanced)(UK)"
			PortCommandline()\PortModus  			 	= "apple2eeuk -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//e Enhanced, UK]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //e (Platinum)"
			PortCommandline()\PortModus  			 	= "apple2ep -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//e Platinum]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //e (UK)"
			PortCommandline()\PortModus  			 	= "apple2euk -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//e UK]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //gs (Cart)"
			PortCommandline()\PortModus  			 	= "apple2gs -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [//gs]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple //gs (Flop)"
			PortCommandline()\PortModus  			 	= "apple2gs -flop3 %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Flop Load [//gs]"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Apple ///"
			PortCommandline()\PortModus  			 	= "apple3 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Coleco" :PortCommandline()\bMenuSubBeg = #True 
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Coleco Vision (NTSC)"
			PortCommandline()\PortModus  			 	= "coleco -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [NTSC]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM      
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Coleco Vision (Pal)"
			PortCommandline()\PortModus  			 	= "colecop -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [PAL]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Commodore" :PortCommandline()\bMenuSubBeg = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore C16/ C116/ c232/ Plus/4"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "Yape"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
					
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 Vic20 (NTSC)"
			PortCommandline()\PortModus  			 	= "vic20 -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [NTSC]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
 			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 Vic20 (PAL)"
			PortCommandline()\PortModus  			 	= "vic20p -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load [PAL]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Commodore 64" :PortCommandline()\bMenuSubBeg = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Micro64 (F9 For Options)"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "Micro64"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Hoxs64"
			PortCommandline()\PortModus  			 	= "-autoload %s"
			PortCommandline()\Port_ShortName 		= "Hoxs64"
			PortCommandline()\MenuItemText    	= "Variant: Autoload"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Hoxs64"
			PortCommandline()\PortModus  			 	= "-quickload %s"
			PortCommandline()\Port_ShortName 		= "Hoxs64"
			PortCommandline()\MenuItemText    	= "Variant: PRG Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Hoxs64"
			PortCommandline()\PortModus  			 	= "-autoload %s"+Chr(34)+":<directoryitemname>"+Chr(34)+""
			PortCommandline()\Port_ShortName 		= "Hoxs64"
			PortCommandline()\MenuItemText    	= "Variant: Image:FileName"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Hoxs64"
			PortCommandline()\PortModus  			 	= "-autoload %s #<directoryprgnumber>"
			PortCommandline()\Port_ShortName 		= "Hoxs64"
			PortCommandline()\MenuItemText    	= "Variant: Image:Number"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64 (1x Floppy)"
			PortCommandline()\PortModus  			 	= "-autostart %s -drive8type 1542 -silent -controlport1device 1 -controlport2device 0 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +warp +autostart-warp -device8 1 +iecdevice8"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 1x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64 (2x Floppy)"
			PortCommandline()\PortModus  			 	= "-autostart %s -9 %s-drive8type 1542 -drive9type 1542 -silent -controlport1device 1 -controlport2device 0 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 1 +iecdevice8 +warp +autostart-warp"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 2x"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64 (1x Floppy/ Cart/ Datasette)"
			PortCommandline()\PortModus  			 	= "-cartcrt %s -8 %s -drive8type 1542 -silent -controlport1device 1 -controlport2device 3 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 1 +iecdevice8 +warp +autostart-warp"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 1x, Cart, Cass"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64 (2x Floppy/ Cart/ Datasette)"
			PortCommandline()\PortModus  			 	= "-cartcrt %s -8 %s -9 %s -drive8type 1542 -drive9type 1542 -silent -controlport1device 1 -controlport2device 3 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 -device8 1 +iecdevice8 +datasette +warp +autostart-warp"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: Floppy 2x, Cart, Cass"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64 (1x Floppy OpenCBM Aktiv)"
			PortCommandline()\PortModus  			 	= "-autostart %s -drive8type 1542 -silent -device8 opencbm -controlport1device 1 -controlport2device 0 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 2 -iecdevice8 +warp +autostart-warp"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: OpenCBM"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64 (1x Floppy OpenCBM Aktiv & Cart)"
			PortCommandline()\PortModus  			 	= "-cartcrt %s -8 %s -drive8type 1542 -silent -device8 opencbm -controlport1device 1 -controlport2device 3 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 2 -iecdevice8 +warp +autostart-warp"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: OpenCBM, Cart"		
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64"
			PortCommandline()\PortModus  			 	= "-config "+Chr(34)+"YourConfig.ini"+Chr(34)+" -autostart %s %pk"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: Use Config File"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64: Vice64"
			PortCommandline()\PortModus  			 	= "-autostart %s %pk"
			PortCommandline()\Port_ShortName 		= "x64SC"
			PortCommandline()\MenuItemText    	= "Variant: Default"		
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Cart]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Only"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Cart & Datasette]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -cart %s -tape %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart & Datasette"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Cart & 1x 1541-II]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -cart %s -iec8 c1541ii -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart & 1x 1541-II"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Cart & 2x 1541-II]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -cart %s -iec8 c1541ii -flop1 %s -iec9 c1541ii -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart & 2x 1541-II"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Datasette]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -tape %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Datasette"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Datasette & 1x 1541-II]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -tape %s -iec8 c1541ii -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Datasette & 1x 1541-II"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [Datasette & 2x 1541-II]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -tape %s -iec8 c1541ii -flop1 %s -iec9 c1541ii -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Datasette & 2x 1541-II"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [1x 1541-II]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -iec8 c1541ii -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1x 1541-II"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Commodore 64 [2x 1541-II]"
			PortCommandline()\PortModus  			 	= "c64 -skip_gameinfo -iec8 c1541ii -flop1 %s -iec9 c1541ii -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2x 1541-II"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  						
			
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Commodore Amiga" :PortCommandline()\bMenuSubBeg = #True		
		
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga Family"
			PortCommandline()\PortModus  			 	= "-f <yourConfig or %s> -cfgparam use_gui=no  -0 %s -1 %s -2 %s -3 %s"
			PortCommandline()\Port_ShortName 		= "WinUAE"
			PortCommandline()\MenuItemText    	= "Variant: Use Config, 4 Drives"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga CD32/CDTV"
			PortCommandline()\PortModus  			 	= "-f <yourConfig or %s> -cfgparam use_gui=no -cfgparam=cdimage0=%s"
			PortCommandline()\Port_ShortName 		= "WinUAE"
			PortCommandline()\MenuItemText    	= "Variant: Use Config, CDRom"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga CDTV"
			PortCommandline()\PortModus  			 	= "cdtvn -skip_gameinfo -cdrom %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga CDTV"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga CD32"
			PortCommandline()\PortModus  			 	= "cd32n -skip_gameinfo -cdrom %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga CD32"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 500 [1 Drive]"
			PortCommandline()\PortModus  			 	= "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 500, 1 Drive"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 500 [2 Drives]"
			PortCommandline()\PortModus  			 	= "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 500, 2 Drives"		
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 500 [3 Drives]"
			PortCommandline()\PortModus  			 	= "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 500, 3 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 500 [4 Drives]"
			PortCommandline()\PortModus  			 	= "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 500, 4 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 2000 [1 Drive]"
			PortCommandline()\PortModus  			 	= "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 2000, 1 Drive"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 2000 [2 Drives]"
			PortCommandline()\PortModus  			 	= "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 2000, 2 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 2000 [3 Drives]"
			PortCommandline()\PortModus  			 	= "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 2000, 3 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 2000 [4 Drives]"
			PortCommandline()\PortModus  			 	= "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 2000, 4 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 3000 [1 Drive]"
			PortCommandline()\PortModus  			 	= "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 3000, 1 Drive"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 3000 [2 Drives]"
			PortCommandline()\PortModus  			 	= "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 3000, 2 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 3000 [3 Drives]"
			PortCommandline()\PortModus  			 	= "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 3000, 3 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 3000 [4 Drives]"
			PortCommandline()\PortModus  			 	= "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 3000, 4 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 1200 [1 Drive]"
			PortCommandline()\PortModus  			 	= "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 1200, 1 Drive"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 1200 [2 Drives]"
			PortCommandline()\PortModus  			 	= "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 1200, 2 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 1200 [3 Drives]"
			PortCommandline()\PortModus  			 	= "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 1200, 3 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 1200 [4 Drives]"
			PortCommandline()\PortModus  			 	= "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 1200, 4 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 4000/030 [1 Drive]"
			PortCommandline()\PortModus  			 	= "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/030, 1 Drive"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 4000/030 [2 Drives]"
			PortCommandline()\PortModus  			 	= "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/030, 2 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 4000/030 [3 Drives]"
			PortCommandline()\PortModus  			 	= "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/030, 3 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 4000/030 [4 Drives]"
			PortCommandline()\PortModus  			 	= "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/030, 4 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Amiga 4000/040 [1 Drive]"
			PortCommandline()\PortModus  			 	= "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/040, 1 Drive"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 4000/040 [2 Drives]"
			PortCommandline()\PortModus  			 	= "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/040, 2 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 4000/040 [3 Drives]"
			PortCommandline()\PortModus  			 	= "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/040, 3 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):			
			PortCommandline()\Description	= "Amiga 4000/040 [4 Drives]"
			PortCommandline()\PortModus  			 	= "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Amiga 4000/040, 4 Drives"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			

			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Fairchild Channel F" :PortCommandline()\bMenuSubBeg = #True				
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Fairchild Channel F"
			PortCommandline()\PortModus  			 	= "channlf -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True			
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: FM-Towns Marty" :PortCommandline()\bMenuSubBeg = #True		
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "FM-Towns Marty [CD-Rom]"
			PortCommandline()\PortModus  			 	= "fmtowns -skip_gameinfo -cdrom %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD-Rom"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
 			AddElement(PortCommandline()):
			PortCommandline()\Description	= "FM-Towns Marty [1x Floppy]"
			PortCommandline()\PortModus  			 	= "fmtowns -skip_gameinfo -fdc:0 35dd -flop1 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 1 Drive" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "FM-Towns Marty [2x Floppy]"
			PortCommandline()\PortModus  			 	= "fmtowns -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drives" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "FM-Towns Marty [2 Drive & CD-Rom]"
			PortCommandline()\PortModus  			 	= "fmtowns -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -cdrom %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Driveas & CD" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: GCE Vectrex" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "GCE Vectrex"
			PortCommandline()\PortModus  			 	= "vectrex -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Magnavox Odyssey 2" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Magnavox Odyssey2"
			PortCommandline()\PortModus  			 	= "odyssey2 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: MSX" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "MSX 1"
			PortCommandline()\PortModus  			 	= "msx -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "MSX 1: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-08Bit-Handheld_GBA --noMenuBar --system MSX %cpuf"
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True		
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "MSX 2"
			PortCommandline()\PortModus  			 	= "msx2 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "MSX 2: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-08Bit-Handheld_GBA --noMenuBar --system MSX2 %cpuf"
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True		
						
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Microsoft" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Microsoft Xbox Classic: CXBX"
			PortCommandline()\PortModus  			 	= "%s"			
			PortCommandline()\Port_ShortName 		= "cxbx"
			PortCommandline()\MenuItemText    	= "Variant: XBE Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Microsoft Xbox360: Xenia"
			PortCommandline()\PortModus  			 	= "%s"			
			PortCommandline()\Port_ShortName 		= "Xenia"
			PortCommandline()\MenuItemText    	= "Variant: ISO Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Microsoft Xbox360: Xenia Canary"
			PortCommandline()\PortModus  			 	= "%s"			
			PortCommandline()\Port_ShortName 		= "xenia-canary"
			PortCommandline()\MenuItemText    	= "Variant: ISO Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Nintendo" :PortCommandline()\bMenuSubBeg = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo NES: RockNES"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "RockNES"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo NES: FCeux"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "FCeux"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo NES: Nestopia"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "Nestopia"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo NES: puNES"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "puNES" 
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo NES/ Famicon (NTSC)"
			PortCommandline()\PortModus  			 	= "nes -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Ntsc)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo NES/ Famicon (PAL)"
			PortCommandline()\PortModus  			 	= "nespal -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Pal)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  	
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "bSnes: Super Nintendo"
			PortCommandline()\PortModus  			 	= "%s"			
			PortCommandline()\Port_ShortName 		= "bsnes"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Snes9x: Super Nintendo"
			PortCommandline()\PortModus  			 	= "%s %pk"			
			PortCommandline()\Port_ShortName 		= "snes9x-x64"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  	 			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo SNES/ Super Famicon (NTSC)"
			PortCommandline()\PortModus  			 	= "snes -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Ntsc)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo SNES/ Super Famicon (PAL)"
			PortCommandline()\PortModus  			 	= "snespal -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Pal)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo 64: Project64"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "Project64"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"	
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo 64: Mupen64Plus"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "Mupen64Plus"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True	
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo 64: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-32Bit-Console_N64 --noMenuBar %cpuf"
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True	
			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo 64"
			PortCommandline()\PortModus  			 	= "n64 -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  		 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo 64 DD"
			PortCommandline()\PortModus  			 	= "64DD -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (DD)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 						
 			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Game Boy"
			PortCommandline()\PortModus  			 	= "gameboy -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (GB)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Game Boy Pocket"
			PortCommandline()\PortModus  			 	= "gbpocket -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Pocket)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Game Boy Color"
			PortCommandline()\PortModus  			 	= "gbcolor -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (GBC)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Game Boy Advance"
			PortCommandline()\PortModus  			 	= "gba -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (GBA)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Game Boy Advance: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-08Bit-Handheld_GBA --noMenuBar"			
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (GBA)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Super Game Boy"
			PortCommandline()\PortModus  			 	= "supergb -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (SGB)" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Super Game Boy II"
			PortCommandline()\PortModus  			 	= "supergb2 -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (SGB2)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo GameBoy/GBC/GBA: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-08Bit-Handheld_GBM --noMenuBar %cpuf"
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo GameBoy/GBC/GBA: VisualAdvance-M"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "VisualAdvance-M"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo DS: DeSEmu"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "DeSEmu"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo GameCube: Dolphin"
			PortCommandline()\PortModus  			 	= "--exec=%s --batch"
			PortCommandline()\Port_ShortName 		= "Dolphin"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"		
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Wii: Dolphin"
			PortCommandline()\PortModus  			 	= "--exec=%s --batch"
			PortCommandline()\Port_ShortName 		= "Dolphin"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Wii-U: Cemu"
			PortCommandline()\PortModus  			 	= "-g %s"			
			PortCommandline()\Port_ShortName 		= "cemu"
			PortCommandline()\MenuItemText    	= "Variant: CD/File Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Nintendo Virtual Boy"
			PortCommandline()\PortModus  			 	= "vboy -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM							
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: NEC" :PortCommandline()\bMenuSubBeg = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "PC MsDOS: DOSBox"
			PortCommandline()\PortModus  			 	= "-conf %s -nocosole"
			PortCommandline()\Port_ShortName 		= "Dosbox"
			PortCommandline()\MenuItemText    	= "Variant: No Console & use Config"				
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC PC-9801: Anex86"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "Anex86"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True	
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC PC-9801: Neko Project II - 386SX CPU (32-bit with 16-bit bus)"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "np2sx"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC PC-9821: Neko Project II - IA-32 CPU (32-bit)"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "np21nt"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC PC-9801: Neko Project II - 286 CPU (16-bit)"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "np2"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True

			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC PC-9821 [2 Drives & CD-Rom]"
			PortCommandline()\PortModus  			 	= "pc9821 -skip_gameinfo -upd765_2hd:0 525hd -flop1 %s -upd765_2hd:1 525hd -flop2 %s -cdrom %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: 2 Drives & CD"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True 						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "PcEngine/TG16: Ootake"
			PortCommandline()\PortModus  			 	= "-nogui %s"
			PortCommandline()\Port_ShortName 		= "Ootake"
			PortCommandline()\MenuItemText    	= "Variant: Rom/ CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC PC-Engine"
			PortCommandline()\PortModus  			 	= "pce -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC SuperGrafx"
			PortCommandline()\PortModus  			 	= "sgx -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC TurboGrafx 16"
			PortCommandline()\PortModus  			 	= "tg16 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "PC-Engine (CD-Rom)"
			PortCommandline()\PortModus  			 	= "pce -cart %s -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart & CD"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "SuperGrafx (CD-Rom)"
			PortCommandline()\PortModus  			 	= "sgx -cart %s -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart & CD"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
  		AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC TurboGrafx 16 (CD-Rom)"
			PortCommandline()\PortModus  			 	= "tg16 -cart %s -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart & CD"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
  		AddElement(PortCommandline()):
			PortCommandline()\Description	= "NEC TurboGrafx 16: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-16Bit-ConsolesA --noMenuBar --system "+Chr(34)+"PC Engine CD"+Chr(34)
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Cart & CD"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================	
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Panasonic 3DO" :PortCommandline()\bMenuSubBeg = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Panasonic 3DO: 4DO"
			PortCommandline()\PortModus  			 	= "-StartLoadFile %s"
			PortCommandline()\Port_ShortName 		= "4DO"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
        
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Panasonic 3DO (PAL)"
			PortCommandline()\PortModus  			 	= "3do_pal -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Pal)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Panasonic 3DO (NTSC)"
			PortCommandline()\PortModus  			 	= "3do -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Ntsc)" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Philips CD-i" :PortCommandline()\bMenuSubBeg = #True		
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Philips CD-i (Mono-1/ PAL)"
			PortCommandline()\PortModus  			 	= "cdimono1 -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Mono-1/ PAL)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Philips CD-i (Mono-2/ PAL)"
			PortCommandline()\PortModus  			 	= "cdimono2 -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Mono-2/ PAL)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Philips CD-i 490 (PAL)"
			PortCommandline()\PortModus  			 	= "cdi490a -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load 490 (PAL)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Philips CD-i 910 (PAL)"
			PortCommandline()\PortModus  			 	= "cdi910 -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load 910 (PAL)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Philips VidePAC+"
			PortCommandline()\PortModus  			 	= "videopac -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: SEGA" :PortCommandline()\bMenuSubBeg = #True											
		
		AddElement(PortCommandline()):
		
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega SG-1000"
			PortCommandline()\PortModus  			 	= "sg1000 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega SG-1000 (m3)"
			PortCommandline()\PortModus  			 	= "sg1000m3 -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load (M3)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			PortCommandline()\Description	= "Sega GameGear: Kega Fusion"
			PortCommandline()\PortModus  			 	= "%s -sms -auto"
			PortCommandline()\Port_ShortName 		= "KegaFusion"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Game Gear (JP)"
			PortCommandline()\PortModus  			 	= "gamegear -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load [JP]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Game Gear (EU/US)"
			PortCommandline()\PortModus  			 	= "gamegeaj -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load [US/EU]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Master System: Kega Fusion"
			PortCommandline()\PortModus  			 	= "%s -sms -auto"
			PortCommandline()\Port_ShortName 		= "KegaFusion"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Master System 1 (PAL)"
			PortCommandline()\PortModus  			 	= "sms1pal -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load [MS 1, PAL]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Master System 1 (JP)"
			PortCommandline()\PortModus  			 	= "smsj -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load [MS 1]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Master System II"
			PortCommandline()\PortModus  			 	= "sms -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load [MS 2]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Master System II (PAL)"
			PortCommandline()\PortModus  			 	= "smspal -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load [MS 2, PAL]"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Genesis: Kega Fusion"
			PortCommandline()\PortModus  			 	= "%s -gen -auto"
			PortCommandline()\Port_ShortName 		= "KegaFusion"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Genesis (SMD): GensHD"
			PortCommandline()\PortModus  			 	= "%s -gen"
			PortCommandline()\Port_ShortName 		= "GensHD"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Genesis (SMD): Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-16Bit-ConsolesA --noMenuBar --system "+Chr(34)+"Mega Drive"+Chr(34)
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive / Genesis (US)"
			PortCommandline()\PortModus  			 	= "genesis -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (US)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive / Genesis (US/ TMSS Chip)"
			PortCommandline()\PortModus  			 	= "genesis_tmss -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (US/ TMSS Chip)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive / Genesis (EU)"
			PortCommandline()\PortModus  			 	= "megadriv -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive / Genesis (JP)"
			PortCommandline()\PortModus  			 	= "megadriv -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (JP)" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega 32X: Kega Fusion"
			PortCommandline()\PortModus  			 	= "%s -32x -auto"
			PortCommandline()\Port_ShortName 		= "KegaFusion"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega 32x: GensHD"
			PortCommandline()\PortModus  			 	= "%s -32x"
			PortCommandline()\Port_ShortName 		= "GensHD"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive 32X (US)"
			PortCommandline()\PortModus  			 	= "32x -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (US)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive 32X (EU)"
			PortCommandline()\PortModus  			 	= "32xe -cart %s -skip_gameinfo" 
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-Drive 32X (JP)"
			PortCommandline()\PortModus  			 	= "32xj -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (JP)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM		
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega CD: Kega Fusion"
			PortCommandline()\PortModus  			 	= "%s -scd -auto"
			PortCommandline()\Port_ShortName 		= "KegaFusion"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega CD: GensHD"
			PortCommandline()\PortModus  			 	= "%s -scd"
			PortCommandline()\Port_ShortName 		= "GensHD"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True			
			
 			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Pico"
			PortCommandline()\PortModus  			 	= "picou -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD / Sega-CD (US)"
			PortCommandline()\PortModus  			 	= "segacd -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (US)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD / Sega-CD (EU)"
			PortCommandline()\PortModus  			 	= "megacd -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD / Sega-CD (JP)"
			PortCommandline()\PortModus  			 	= "megacdj -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (JP)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD II / Sega-CD 2 (US)"
			PortCommandline()\PortModus  			 	= "segacd2 -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (SCD-2 US)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD II / Sega-CD 2 (EU)"
			PortCommandline()\PortModus  			 	= "megacd2 -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (MCD-2 EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD II / Sega-CD 2 (JP)"
			PortCommandline()\PortModus  			 	= "aiwamcd -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Aiwa-MCD JP)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD 32x / Sega-CD 32x (US)"
			PortCommandline()\PortModus  			 	= "32x_scd -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (US)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD 32x / Sega-CD 32x (EU)"
			PortCommandline()\PortModus  			 	= "32x_mcd -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Mega-CD 32x / Sega-CD 32x (JP)"
			PortCommandline()\PortModus  			 	= "32x_mcdj -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (JP)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Saturn: Yabuse"
			PortCommandline()\PortModus  			 	= "--autostart --enable-scsp-frame-accurate --iso=%s"
			PortCommandline()\Port_ShortName 		= "Yabuse"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Saturn: Kronos"
			PortCommandline()\PortModus  			 	= "--autostart --iso=%s"
			PortCommandline()\Port_ShortName 		= "Kronos"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Saturn (US)"
			PortCommandline()\PortModus  			 	= "saturn -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Saturn (JP)"
			PortCommandline()\PortModus  			 	= "saturnjp -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (JP)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Saturn (EU)"
			PortCommandline()\PortModus  			 	= "saturneu -cdrom %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (US)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Mednafen: Sega Saturn"
			PortCommandline()\PortModus  			 	= "-ss.input.port1 gamepad -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"			
			PortCommandline()\Port_ShortName 		= "Mednafen"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Port1: Gamepad)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Mednafen: Sega Saturn"
			PortCommandline()\PortModus  			 	= "-ss.input.port1 3dpad -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"			
			PortCommandline()\Port_ShortName 		= "Mednafen"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Port1: 3D Pad)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Mednafen: Sega Saturn"
			PortCommandline()\PortModus  			 	= "-ss.input.port1 mouse -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"			
			PortCommandline()\Port_ShortName 		= "Mednafen"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Port1: Mouse)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Mednafen: Sega Saturn"
			PortCommandline()\PortModus  			 	= "-ss.input.port1 wheel -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"			
			PortCommandline()\Port_ShortName 		= "Mednafen"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Port1: Wheel)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True   
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Mednafen: Sega Saturn"
			PortCommandline()\PortModus  			 	= "-ss.input.port1 gun -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"			
			PortCommandline()\Port_ShortName 		= "Mednafen"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (Port1: Gun)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Dreamcast: ReDream"
			PortCommandline()\PortModus  			 	= "%s"			
			PortCommandline()\Port_ShortName 		= "redream"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Dreamcast: nullDC"
			PortCommandline()\PortModus  			 	= "-config ImageReader:defaultImage=%s"
			PortCommandline()\Port_ShortName 		= "nullDC"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Dreamcast: Demul"
			PortCommandline()\PortModus  			 	= "-run=dc %s"
			PortCommandline()\Port_ShortName 		= "Demul"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
						
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Dreamcast (EU)"
			PortCommandline()\PortModus  			 	= "dceu -cdrom %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (EU)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Dreamcast (JP)"
			PortCommandline()\PortModus  			 	= "dcjp -cdrom %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (JP)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sega Dreamcast (US)"
			PortCommandline()\PortModus  			 	= "dc -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load (US)" 			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 

		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================		
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Sharp X68000" :PortCommandline()\bMenuSubBeg = #True				
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sharp X68000"
			PortCommandline()\PortModus  			 	= "x68000 -flop1 %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Floppy Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True :	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Sinclair ZX Spectrum" :PortCommandline()\bMenuSubBeg = #True				
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sinclair ZX Spectrum"
			PortCommandline()\PortModus  			 	= "spectrum -flop %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Floppy Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  	
			
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Sony" :PortCommandline()\bMenuSubBeg = #True										
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playstation 1: Ares (Fork)"
			PortCommandline()\PortModus  			 	= "%s --shader CRT-16Bit-ConsolesA --noMenuBar --system "+Chr(34)+"PlaySation"+Chr(34)
			PortCommandline()\Port_ShortName 		= "Ares"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
											
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playstation 1: Duckstation"
			PortCommandline()\PortModus  			 	= "%s -fastboot"
			PortCommandline()\Port_ShortName 		= "Duckstation"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
																	
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playstation 1: ePSXe"
			PortCommandline()\PortModus  			 	= "-loadbin %s -nogui"
			PortCommandline()\Port_ShortName 		= "ePSXe"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Mednafen: Playstation 1"
			PortCommandline()\PortModus  			 	= "-psx.input.port1 dualshock -psx.region_autodetect 1 -psx.xscale 3.800000 -psx.yscale 3.8 -psx.scanlines 66 -psx.stretch 0 -psx.shader none -psx.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -psx.videoip 0 -video.fs 0 -video.frameskip 0 -psx.bios_sanity 1 -psx.cd_sanity 1 -filesys.untrusted_fip_check 0 -psx.shader goat -psx.shader.goat.pat borg -psx.shader.goat.hdiv 0.25 -psx.shader.goat.slen 1 -psx.shader.goat.tp 0.7 -psx.input.port1.memcard 1 -loadcd psx %s"			
			PortCommandline()\Port_ShortName 		= "Mednafen"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playstation 1: DuckStation (SDL)"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "duckstation-sdl-x64-ReleaseLTCG"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playstation 2: PcSX2"
			PortCommandline()\PortModus  			 	= "--fullboot --nogui %s"
			PortCommandline()\Port_ShortName 		= "PcSX2"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playstation 3: rPcS3"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "rPcS3"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Sony Playatation Portable: PpSsPp"
			PortCommandline()\PortModus  			 	= "%s"
			PortCommandline()\Port_ShortName 		= "ppsspp"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: SNK NeoGeo" :PortCommandline()\bMenuSubBeg = #True				
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Arcade: NeoGeoCD - NeoRaine32"
			PortCommandline()\PortModus  			 	= "-nogui %s"
			PortCommandline()\Port_ShortName 		= "NeoRaine"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True			
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "SNK NeoGeo CD"
			PortCommandline()\PortModus  			 	= "neocd -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "SNK NeoGeo CD/z"
			PortCommandline()\PortModus  			 	= "neocdz -cdrom %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: CD Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "SNK NeoGeo Pocket (Mono)"
			PortCommandline()\PortModus  			 	= "ngp -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Mono)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "SNK NeoGeo Pocket (Color)"
			PortCommandline()\PortModus  			 	= "ngpc -cart %s -skip_gameinfo"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Color)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Super Casette Vision" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Epoch Super Casette Vision"
			PortCommandline()\PortModus  			 	= "epoch -skip_gameinfo -cart %s"
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Image Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: Wonderswan" :PortCommandline()\bMenuSubBeg = #True			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Bandai Wonderswan: Oswan (v1.7+)"
			PortCommandline()\PortModus  			 	= "%s -f"
			PortCommandline()\Port_ShortName 		= "Oswan"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Wonderswan: OswanHack"
			PortCommandline()\PortModus  			 	= "-r=%s -f"
			PortCommandline()\Port_ShortName 		= "OswanHack"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load"			
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Bandai Wonderswan (Mono)"
			PortCommandline()\PortModus  			 	= "wswan -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Mono)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM  
			
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "Bandai Wonderswan (Color)"
			PortCommandline()\PortModus  			 	= "wscolor -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Color)"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: TRS-80" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "TRS-80"
			PortCommandline()\PortModus  			 	= "trs80m3 -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Rom Load (Color)" 
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM			

		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
		;AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "-----------------------------" :PortCommandline()\bMenuBar = #True  				
		; ============================================================================================================================================================================				
		AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = "System: VTech" :PortCommandline()\bMenuSubBeg = #True
			AddElement(PortCommandline()):
			PortCommandline()\Description	= "VTech CreatVision"
			PortCommandline()\PortModus  			 	= "crvisio -cart %s -skip_gameinfo"			
			PortCommandline()\Port_ShortName 		= "Mame"
			PortCommandline()\MenuItemText    	= "Variant: Cart Load"
			PortCommandline()\File_Default 			= PortCommandline()\Port_ShortName  + ".exe"	:PortCommandline()\Path_Default = "" :PortCommandline()\bCharSwitch = #True:	PortCommandline()\MenuImageID = DI::#_MNU_MAM 
			
			AddElement(PortCommandline()): PortCommandline()\PortModus = ""                  :PortCommandline()\Description = ""                              :PortCommandline()\bMenuSubEnd = #True
	
	
      
        ResetList(PortCommandline())
        Protected Max_Saves_List = ListSize(PortCommandline()) 
        Protected Index.i = SetMnuIndexNum()
        
        For i = 0 To Max_Saves_List-1
            NextElement(PortCommandline())
            PortCommandline()\PortIDX = i
            If Len( PortCommandline()\PortModus ) >= 1            	
            	Index + 1
            	PortCommandline()\MenuIndex = Index ; Menu Item Index 
            EndIf
            ;Debug "Emulation Last MenuIndex " + Str( PortCommandline()\MenuIndex )
        Next
        
        index -1
        Debug "Menü Erstellung: List Einträge " + Str(Max_Saves_List) +" / Menü Index Einträge von (" + Str(SetMnuIndexNum()) + " bis " + Str( Index ) + ") - Ports/ Nativ"
        SortStructuredList(PortCommandline(), #PB_Sort_Ascending, OffsetOf(CmpPortModus\PortIDX), #PB_Integer)
			
    EndProcedure                   
                
	
    Procedure.i SetMnuIndexNum()
        ProcedureReturn 100    	
    EndProcedure
      
    Procedure.i  GetMaxItems()
        ResetList(PortCommandline())
        ProcedureReturn ListSize(PortCommandline()) 
    EndProcedure    
    
    Procedure.i GetMaxMnuIndex()
    	
        ResetList(PortCommandline())
        Protected Max_Saves_List = ListSize(PortCommandline()) 
        Protected Index.i 				= SetMnuIndexNum()
        
        For i = 0 To Max_Saves_List-1
            NextElement(PortCommandline())
            PortCommandline()\PortIDX = i
            If Len( PortCommandline()\PortModus ) >= 1
            	Index + 1
            EndIf
        Next   
        ProcedureReturn Index
    	
   	EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 50
; FirstLine = 30
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\BLACKTAIL\
; Debugger = IDE
; EnableUnicode