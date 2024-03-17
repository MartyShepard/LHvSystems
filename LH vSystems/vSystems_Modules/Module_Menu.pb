; DAS Deklaieren findet IN der Config Source Statt

Module INVMNU
    
    Procedure.i Request_MSG_Quit()
        
        ;
        ; Überprüfr auf nicht gepeicherte Text Änderungen
        If ( vInfo::Modify_EndCheck() = #True )
            
            
            Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Beenden", Startup::*LHGameDB\TitleVersion + " Beenden ?",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
            If Result = 0
                ProcedureReturn #True
            EndIf 
            SetActiveGadget(DC::#ListIcon_001): ProcedureReturn #False
        EndIf
        
        ProcedureReturn #True
    EndProcedure 
    
    Procedure.i MNU_SetGet(state.i)
        If ( state.i = #True )
            ProcedureReturn #False
        EndIf
        If ( state.i = #False )
            ProcedureReturn #True
        EndIf    
    EndProcedure
    
    Procedure.i MNU_SetCheckmark(MenuID.i, Itemm.i, State.i)                
            SetMenuItemState(MenuID, Itemm, State)        
    EndProcedure
    
    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts (Vordefinierte Programme)
    ;
    ;
    ;*******************************************************************************************************************************************************************                                    
    Procedure Get_AppMenu(MenuID.i, GadgetID.i)
        
        Protected Commandline$, Programm$
        
        Select MenuID.i
            Case 1:
                prgDescriptn$ = "PC MsDOS: DOSBox"
                prg_Commands$ = "-conf %s -nocosole"
                prgShortName$ = "Dosbox"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 2:
                prgDescriptn$ = "Port: ScummVM"
                prg_Commands$ = "-no-console -c %s"
                prgShortName$ = "ScummVM"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                   
                
            Case 3:
                prgDescriptn$ = "PC MsDOS: DOSBox-X"
                prg_Commands$ = "-conf %s -nocosole"
                prgShortName$ = "Dosbox-X"          :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                
                
            Case 4:
                prgDescriptn$ = "Commodore C16/ C116/ c232/ Plus/4"
                prg_Commands$ = "%s"
                prgShortName$ = "Yape"              :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                
                
            Case 5:
                prgDescriptn$ = "Nintendo 64: Mupen64Plus"
                prg_Commands$ = "%s"
                prgShortName$ = "Mupen64Plus"       :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 6:
                prgDescriptn$ = "PC9801: Anex86"
                prg_Commands$ = "%s"
                prgShortName$ = "Anex86"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 7:
                prgDescriptn$ = "PC9801: Neko Project II - 386SX CPU (32-bit with 16-bit bus)"
                prg_Commands$ = "%s"
                prgShortName$ = "np2sx"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 8:
                prgDescriptn$ = "PC9821: Neko Project II - IA-32 CPU (32-bit)"
                prg_Commands$ = "%s"
                prgShortName$ = "np21nt"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 9:
                prgDescriptn$ = "PC9801: Neko Project II - 286 CPU (16-bit)"
                prg_Commands$ = "%s"
                prgShortName$ = "np2"               :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 10:
                prgDescriptn$ = "Windows: Media Player 32Bit"
                prg_Commands$ = "%s /Fullscreen"
                prgShortName$ = "wmplayer"          :File_Default$ = "C:\Program Files (x86)\Windows Media Player\wmplayer.exe" :Path_Default$ = "C:\Program Files (x86)\Windows Media Player"    
                
            Case 11:
                prgDescriptn$ = "Windows: Media Player 64Bit"
                prg_Commands$ = "%s /Fullscreen"
                prgShortName$ = "wmplayer"          :File_Default$ = "C:\Program Files\Windows Media Player\wmplayer.exe"       :Path_Default$ = "C:\Program Files\Windows Media Player" 
                
            Case 12:
                prgDescriptn$ = "eDuke32: WW2 GI"
                prg_Commands$ = "-ww2gi -j%s"
                prgShortName$ = "eDuke32"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 13:
                prgDescriptn$ = "eDuke32: NAM (Napalm)"
                prg_Commands$ = "-nam -j%s"
                prgShortName$ = "eDuke32"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 14:
                prgDescriptn$ = "eDuke32: Duke Nukem 3D"
                prg_Commands$ = "-j%s"
                prgShortName$ = "eDuke32"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 15:
                prgDescriptn$ = "eDuke32: Duke Nukem 3D"
                prg_Commands$ = "-j%s"
                prgShortName$ = "eDuke32"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 16:
                prgDescriptn$ = "Commodore C64: Micro64 (F9 For Options)"
                prg_Commands$ = "%s"
                prgShortName$ = "Micro64"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                 
                
            Case 17:
                prgDescriptn$ = "Commodore C64: Hoxs64"
                prg_Commands$ = "-autoload %s"
                prgShortName$ = "Hoxs64"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 18:
                prgDescriptn$ = "Commodore C64: Hoxs64 (Prg Load)"
                prg_Commands$ = "-quickload %s"
                prgShortName$ = "Hoxs64"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                     
                
            Case 19:
                prgDescriptn$ = "Commodore C64: Hoxs64"
                prg_Commands$ = "-autoload %s"+Chr(34)+":<directoryitemname>"+Chr(34)+""
                prgShortName$ = "Hoxs64"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 20:
                prgDescriptn$ = "Commodore C64: Hoxs64"
                prg_Commands$ = "-autoload %s #<directoryprgnumber>"
                prgShortName$ = "Hoxs64"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 21:
                prgDescriptn$ = "Atari: SteamSSE (Family)"
                prg_Commands$ = "%s"
                prgShortName$ = "SteamSSE"          :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 22:
                prgDescriptn$ = "Atari-ST: Hatari"
                prg_Commands$ = "--disk-a %s --machine st --memsize 2 --drive-b false -vdi false"
                prgShortName$ = "Hatari"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""       
                
            Case 23:
                prgDescriptn$ = "Atari-ST: Hatari"
                prg_Commands$ = "--disk-a %s --disk-b %s --machine st --memsize 2 --drive-b false -vdi false"
                prgShortName$ = "Hatari"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 24:
                prgDescriptn$ = "Atari-TT: Hatari"
                prg_Commands$ = "--disk-a %s --machine tt --cpulevel 68020 --memsize 4 --drive-b false -vdi false"
                prgShortName$ = "Hatari"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""       
                
            Case 25:
                prgDescriptn$ = "Atari-TT: Hatari"
                prg_Commands$ = "--disk-a %s --disk-b %s --machine tt --cpulevel 68020 --memsize 4 --drive-b false -vdi false"
                prgShortName$ = "Hatari"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 26:
                prgDescriptn$ = "Atari Falcon: Hatari"
                prg_Commands$ = "--disk-a %s --machine falcon --cpulevel 68060 --memsize 14 --drive-b false -vdi false"
                prgShortName$ = "Hatari"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""       
                
            Case 27:
                prgDescriptn$ = "Atari Falcon: Hatari"
                prg_Commands$ = "-disk-a %s --disk-b %s --machine falcon --cpulevel 68060 --memsize 14 --drive-b false -vdi false"
                prgShortName$ = "Hatari"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 28:
                prgDescriptn$ = "Commodore C64: Vice64 (1x Floppy)"
                prg_Commands$ = "-autostart %s -drive8type 1542 -silent -controlport1device 1 -controlport2device 0 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +warp +autostart-warp -device8 1 +iecdevice8"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 29:
                prgDescriptn$ = "Commodore C64: Vice64 (2x Floppy)"
                prg_Commands$ = "-autostart %s -9 %s-drive8type 1542 -drive9type 1542 -silent -controlport1device 1 -controlport2device 0 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 1 +iecdevice8 +warp +autostart-warp"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 30:
                prgDescriptn$ = "Commodore C64: Vice64 (1x Floppy/ Cart/ Datasette)"
                prg_Commands$ = "-cartcrt %s -8 %s -drive8type 1542 -silent -controlport1device 1 -controlport2device 3 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 1 +iecdevice8 +warp +autostart-warp"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 31:
                prgDescriptn$ = "Commodore C64: Vice64 (1x Floppy/ Cart/ Datasette)"
                prg_Commands$ = "-cartcrt %s -8 %s -9 %s -drive8type 1542 -drive9type 1542 -silent -controlport1device 1 -controlport2device 3 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 -device8 1 +iecdevice8 +datasette +warp +autostart-warp"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 32:
                prgDescriptn$ = "Commodore C64: Vice64 (1x Floppy OpenCBM Aktiv)"
                prg_Commands$ = "-autostart %s -drive8type 1542 -silent -device8 opencbm -controlport1device 1 -controlport2device 0 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 2 -iecdevice8 +warp +autostart-warp"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 33:
                prgDescriptn$ = "Commodore C64: Vice64 (1x Floppy OpenCBM Aktiv & Cart)"
                prg_Commands$ = "-cartcrt %s -8 %s -drive8type 1542 -silent -device8 opencbm -controlport1device 1 -controlport2device 3 -sdlinitialw 1420 -sdlinitialh 1082 -sidenginemodel 258 +datasette -device8 2 -iecdevice8 +warp +autostart-warp"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 34:
                prgDescriptn$ = "Commodore C64: Vice64"
                prg_Commands$ = "-config "+Chr(34)+"YourConfig.ini"+Chr(34)+" -autostart %s %pk"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 35:
                prgDescriptn$ = "Commodore C64: Vice64"
                prg_Commands$ = "-autostart %s %pk"
                prgShortName$ = "x64SC"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 36:
                prgDescriptn$ = "Commodore Amiga Family"
                prg_Commands$ = "-f <yourConfig or %s> -cfgparam use_gui=no  -0 %s -1 %s -2 %s -3 %s"
                prgShortName$ = "WinUAE"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 37:
                prgDescriptn$ = "Commodore Amiga CD32/CDTV"
                prg_Commands$ = "-f <yourConfig or %s> -cfgparam use_gui=no -cfgparam=cdimage0=%s"
                prgShortName$ = "WinUAE"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 38:
                prgDescriptn$ = "Nintendo NES: RockNES"
                prg_Commands$ = "%s"
                prgShortName$ = "RockNES"           :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 39:
                prgDescriptn$ = "Nintendo NES: FCeux"
                prg_Commands$ = "%s"
                prgShortName$ = "FCeux"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 40:
                prgDescriptn$ = "Nintendo NES: Nestopia"
                prg_Commands$ = "%s"
                prgShortName$ = "Nestopia"          :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 41:
                prgDescriptn$ = "Nintendo NES: puNES"
                prg_Commands$ = "%s"
                prgShortName$ = "puNES"             :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 42:
                prgDescriptn$ = "Nintendo 64: Project64"
                prg_Commands$ = "%s"
                prgShortName$ = "Project64"         :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 43:
                prgDescriptn$ = "Nintendo DS: DeSEmu"
                prg_Commands$ = "%s"
                prgShortName$ = "DeSEmu"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                 
                
            Case 44:
                prgDescriptn$ = "Nintendo GameCube: Dolphin"
                prg_Commands$ = "--exec=%s --batch"
                prgShortName$ = "Dolphin"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                  
                
            Case 45:
                prgDescriptn$ = "Nintendo Wii: Dolphin"
                prg_Commands$ = "--exec=%s --batch"
                prgShortName$ = "Dolphin"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 46:
                prgDescriptn$ = "Nintendo GameBoy/GBC/GBA: VisualAdvance-M"
                prg_Commands$ = "%s"
                prgShortName$ = "VisualAdvance-M"    :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 47:
                prgDescriptn$ = "Sega Genesis: Kega Fusion"
                prg_Commands$ = "%s -gen -auto"
                prgShortName$ = "KegaFusion"         :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 48:
                prgDescriptn$ = "Sega 32X: Kega Fusion"
                prg_Commands$ = "%s -32x -auto"
                prgShortName$ = "KegaFusion"         :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 49:
                prgDescriptn$ = "Sega CD: Kega Fusion"
                prg_Commands$ = "%s -scd -auto"
                prgShortName$ = "KegaFusion"         :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 50:
                prgDescriptn$ = "Sega Master System: Kega Fusion"
                prg_Commands$ = "%s -sms -auto"
                prgShortName$ = "KegaFusion"         :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 51:
                prgDescriptn$ = "Sega GameGear: Kega Fusion"
                prg_Commands$ = "%s -sms -auto"
                prgShortName$ = "KegaFusion"         :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 52:
                prgDescriptn$ = "Sega Genesis (SMD): GensHD"
                prg_Commands$ = "%s -gen"
                prgShortName$ = "GensHD"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""      
                
            Case 53:
                prgDescriptn$ = "Sega 32x: GensHD"
                prg_Commands$ = "%s -32x"
                prgShortName$ = "GensHD"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 54:
                prgDescriptn$ = "Sega CD: GensHD"
                prg_Commands$ = "%s -scd"
                prgShortName$ = "GensHD"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 55:
                prgDescriptn$ = "Sega Saturn: Yabuse"
                prg_Commands$ = "--autostart --enable-scsp-frame-accurate --iso=%s"
                prgShortName$ = "Yabuse"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 56:
                prgDescriptn$ = "Sega Dreamcast: nullDC"
                prg_Commands$ = "-config ImageReader:defaultImage=%s"
                prgShortName$ = "nullDC"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 57:
                prgDescriptn$ = "Sega Dreamcast: Demul"
                prg_Commands$ = "-run=dc %s"
                prgShortName$ = "Demul"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 58:
                prgDescriptn$ = "PcEngine/TG16: Ootake"
                prg_Commands$ = "-nogui %s"
                prgShortName$ = "Ootake"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 59:
                prgDescriptn$ = "Sony Playstation 1: ePSXe"
                prg_Commands$ = "-loadbin %s -nogui"
                prgShortName$ = "ePSXe"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                  
                
            Case 60:
                prgDescriptn$ = "Sony Playstation 2: PcSX2"
                prg_Commands$ = "--fullboot --nogui %s"
                prgShortName$ = "PcSX2"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 61:
                prgDescriptn$ = "Sony Playstation 3: rPcS3"
                prg_Commands$ = "%s"
                prgShortName$ = "rPcS3"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 62:
                prgDescriptn$ = "Sony Playatation Portable: PpSsPp"
                prg_Commands$ = "%s"
                prgShortName$ = "ppsspp"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 63:
                prgDescriptn$ = "Panasonic 3DO: 4DO"
                prg_Commands$ = "-StartLoadFile %s"
                prgShortName$ = "4DO"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 64:
                prgDescriptn$ = "Arcade: M.A.M.E"
                prg_Commands$ = "%s -skip_gameinfo -nowindow"
                prgShortName$ = "Mame"            :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 65:
                prgDescriptn$ = "Arcade: NeoGeoCD - NeoRaine32"
                prg_Commands$ = "-nogui %s"
                prgShortName$ = "NeoRaine"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 66:
                prgDescriptn$ = "Arcade: Final Burn Alpha"
                prg_Commands$ = "%name -r 640x480x32"
                prgShortName$ = "FinalBurn"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 67:
                prgDescriptn$ = "Atari Jaguar: VirtualJaguar"
                prg_Commands$ = "%s"
                prgShortName$ = "VirtualJaguar"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 68:
                prgDescriptn$ = "Bandai Wonderswan: Oswan (v1.7+)"
                prg_Commands$ = "%s -f"
                prgShortName$ = "Oswan"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 69:
                prgDescriptn$ = "Wonderswan: OswanHack"
                prg_Commands$ = "-r=%s -f"
                prgShortName$ = "OswanHack"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 70:
                prgDescriptn$ = "Amiga 500 [1 Drive]"
                prg_Commands$ = "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 71:
                prgDescriptn$ = "Amiga 500 [2 Drives]"
                prg_Commands$ = "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 72:
                prgDescriptn$ = "Amiga 500 [3 Drives]"
                prg_Commands$ = "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 73:
                prgDescriptn$ = "Amiga 500 [4 Drives]"
                prg_Commands$ = "a500n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 74:
                prgDescriptn$ = "Amiga 2000 [1 Drive]"
                prg_Commands$ = "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""        
                
            Case 75:
                prgDescriptn$ = "Amiga 2000 [2 Drives]"
                prg_Commands$ = "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 76:
                prgDescriptn$ = "Amiga 2000 [3 Drives]"
                prg_Commands$ = "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 77:
                prgDescriptn$ = "Amiga 2000 [4 Drives]"
                prg_Commands$ = "a2000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 78:
                prgDescriptn$ = "Amiga 3000 [1 Drive]"
                prg_Commands$ = "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""        
                
            Case 79:
                prgDescriptn$ = "Amiga 3000 [2 Drives]"
                prg_Commands$ = "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 80:
                prgDescriptn$ = "Amiga 3000 [3 Drives]"
                prg_Commands$ = "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 81:
                prgDescriptn$ = "Amiga 3000 [4 Drives]"
                prg_Commands$ = "a3000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 82:
                prgDescriptn$ = "Amiga 1200 [1 Drive]"
                prg_Commands$ = "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 83:
                prgDescriptn$ = "Amiga 1200 [2 Drives]"
                prg_Commands$ = "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 84:
                prgDescriptn$ = "Amiga 1200 [3 Drives]"
                prg_Commands$ = "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 85:
                prgDescriptn$ = "Amiga 1200 [4 Drives]"
                prg_Commands$ = "a1200n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 86:
                prgDescriptn$ = "Amiga 4000/030 [1 Drive]"
                prg_Commands$ = "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 87:
                prgDescriptn$ = "Amiga 4000/030 [2 Drives]"
                prg_Commands$ = "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 88:
                prgDescriptn$ = "Amiga 4000/030 [3 Drives]"
                prg_Commands$ = "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 89:
                prgDescriptn$ = "Amiga 4000/030 [4 Drives]"
                prg_Commands$ = "a400030n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 90:
                prgDescriptn$ = "Amiga 4000/040 [1 Drive]"
                prg_Commands$ = "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 91:
                prgDescriptn$ = "Amiga 4000/040 [2 Drives]"
                prg_Commands$ = "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 92:
                prgDescriptn$ = "Amiga 4000/040 [3 Drives]"
                prg_Commands$ = "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 93:
                prgDescriptn$ = "Amiga 4000/040 [4 Drives]"
                prg_Commands$ = "a4000n -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -fdc:2 35dd -flop3 %s -fdc:3 35dd -flop4 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 94:
                prgDescriptn$ = "Amiga CDTV"
                prg_Commands$ = "cdtvn -skip_gameinfo -cdrom %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""        
                
            Case 95:
                prgDescriptn$ = "Amiga CD32"
                prg_Commands$ = "cd32n -skip_gameinfo -cdrom %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 96:
                prgDescriptn$ = "Amstrad CPC4-64"
                prg_Commands$ = "cpc464 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 97:
                prgDescriptn$ = "Amstrad CPC4-64+"
                prg_Commands$ = "cpc464p -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 98:
                prgDescriptn$ = "Apple 1"
                prg_Commands$ = "apple1 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 99:
                prgDescriptn$ = "Apple //+"
                prg_Commands$ = "apple2p -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""             
                
            Case 100:
                prgDescriptn$ = "Apple //c"
                prg_Commands$ = "apple2c -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                 
                
            Case 101:
                prgDescriptn$ = "Apple //c (OME)"
                prg_Commands$ = "apple2c3 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
            Case 102:
                prgDescriptn$ = "Apple //c (Rev4)"
                prg_Commands$ = "apple2c4 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                  
                
            Case 103:
                prgDescriptn$ = "Apple //c (Unidisk 3.5)"
                prg_Commands$ = "apple2c0 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
            Case 104:
                prgDescriptn$ = "Apple //c (Plus)"
                prg_Commands$ = "apple2cp -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                
                
            Case 105:
                prgDescriptn$ = "Apple //e (Cartdrige)"
                prg_Commands$ = "apple2e -cart %s -skip_gameinfo -gameio joy"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 106:
                prgDescriptn$ = "Apple //e (Floppy)"
                prg_Commands$ = "apple2e -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 107:
                prgDescriptn$ = "Apple //e (Enhanced)"
                prg_Commands$ = "apple2ee -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                   
                
            Case 108:
                prgDescriptn$ = "Apple //e (Enhanced)(UK)"
                prg_Commands$ = "apple2eeuk -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 109:
                prgDescriptn$ = "Apple //e (Platinum)"
                prg_Commands$ = "apple2ep -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 110:
                prgDescriptn$ = "Apple //e (UK)"
                prg_Commands$ = "apple2euk -flop1 %s -skip_gameinfo -sl1 mouse -gameio joy"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 111:
                prgDescriptn$ = "Apple //gs (Cart)"
                prg_Commands$ = "apple2gs -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 112:
                prgDescriptn$ = "Apple //gs (Flop)"
                prg_Commands$ = "apple2gs -flop3 %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                 
                
            Case 113:
                prgDescriptn$ = "Apple ///"
                prg_Commands$ = "apple3 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 114:
                prgDescriptn$ = "Atari 400"
                prg_Commands$ = "a400 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 115:
                prgDescriptn$ = "Atari 800/800XL"
                prg_Commands$ = "a800 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 116:
                prgDescriptn$ = "Atari 2600"
                prg_Commands$ = "a2600 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
            Case 117:
                prgDescriptn$ = "Atari 5200"
                prg_Commands$ = "5200 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 118:
                prgDescriptn$ = "Atari 7800"
                prg_Commands$ = "7800 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
            Case 119:
                prgDescriptn$ = "Atari Lynx"
                prg_Commands$ = "lynx -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
            Case 120:
                prgDescriptn$ = "Atari Jaguar (Cart)"
                prg_Commands$ = "jaguar -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
            Case 121:
                prgDescriptn$ = "Atari Jaguar (CD)"
                prg_Commands$ = "jaguarcd -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 122:
                prgDescriptn$ = "Atari ST (DE) [1 Drive]"
                prg_Commands$ = "st_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 123:
                prgDescriptn$ = "Atari ST (DE) [2 Drive]"
                prg_Commands$ = "st_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""         
                
             Case 124:
                prgDescriptn$ = "Atari ST (US) [1 Drive]"
                prg_Commands$ = "st -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 125:
                prgDescriptn$ = "Atari ST (US) [2 Drives]"
                prg_Commands$ = "st -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 126:
                prgDescriptn$ = "Atari ST/e (DE) [1 Drive]"
                prg_Commands$ = "ste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 127:
                prgDescriptn$ = "Atari ST/e (DE) [2 Drive]"
                prg_Commands$ = "ste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""         
                
             Case 128:
                prgDescriptn$ = "Atari ST/e (US) [1 Drive]"
                prg_Commands$ = "ste -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 129:
                prgDescriptn$ = "Atari ST/e (US) [2 Drives]"
                prg_Commands$ = "ste -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 130:
                prgDescriptn$ = "Atari MegaST (DE) [1 Drive]"
                prg_Commands$ = "megast_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 131:
                prgDescriptn$ = "Atari MegaST (DE) [2 Drive]"
                prg_Commands$ = "megast_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""         
                
             Case 132:
                prgDescriptn$ = "Atari MegaST (US) [1 Drive]"
                prg_Commands$ = "megast -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 133:
                prgDescriptn$ = "Atari MegaST (US) [2 Drives]"
                prg_Commands$ = "megast -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                    
                
             Case 134:
                prgDescriptn$ = "Atari MegaST/e (DE) [1 Drive]"
                prg_Commands$ = "megaste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 135:
                prgDescriptn$ = "Atari MegaST/e (DE) [2 Drive]"
                prg_Commands$ = "megaste_de -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""         
                
             Case 136:
                prgDescriptn$ = "Atari MegaST/e (US) [1 Drive]"
                prg_Commands$ = "megaste -skip_gameinfo -wd1772:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 137:
                prgDescriptn$ = "Atari MegaST/e (US) [2 Drives]"
                prg_Commands$ = "megaste -skip_gameinfo -wd1772:0 35dd -flop1 %s -wd1772:1 35dd -flop2 $s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""        
                
             Case 138:
                prgDescriptn$ = "Coleco Vision (NTSC)"
                prg_Commands$ = "coleco -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""             
                
             Case 139:
                prgDescriptn$ = "Coleco Vision (Pal)"
                prg_Commands$ = "colecop -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 140:
                prgDescriptn$ = "Commodore 64 [Cart]"
                prg_Commands$ = "c64 -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 141:
                prgDescriptn$ = "Commodore 64 [Cart & Datasette]"
                prg_Commands$ = "c64 -skip_gameinfo -cart %s -tape %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 142:
                prgDescriptn$ = "[Cart & 1x 1541-II]"
                prg_Commands$ = "c64 -skip_gameinfo -cart %s -iec8 c1541ii -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 143:
                prgDescriptn$ = "[Cart & 2x 1541-II]"
                prg_Commands$ = "c64 -skip_gameinfo -cart %s -iec8 c1541ii -flop1 %s -iec9 c1541ii -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 144:
                prgDescriptn$ = "[Datasette]"
                prg_Commands$ = "c64 -skip_gameinfo -tape %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 145:
                prgDescriptn$ = "[Datasette & 1x 1541-II]"
                prg_Commands$ = "c64 -skip_gameinfo -tape %s -iec8 c1541ii -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""    
                
             Case 146:
                prgDescriptn$ = "[Datasette & 2x 1541-II]"
                prg_Commands$ = "c64 -skip_gameinfo -tape %s -iec8 c1541ii -flop1 %s -iec9 c1541ii -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 147:
                prgDescriptn$ = "[1x 1541-II]"
                prg_Commands$ = "c64 -skip_gameinfo -iec8 c1541ii -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 148:
                prgDescriptn$ = "[2x 1541-II]"
                prg_Commands$ = "c64 -skip_gameinfo -iec8 c1541ii -flop1 %s -iec9 c1541ii -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 149:
                prgDescriptn$ = "Vic20 (NTSC)"
                prg_Commands$ = "vic20 -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 150:
                prgDescriptn$ = "Vic20 (PAL)"
                prg_Commands$ = "vic20p -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 151:
                prgDescriptn$ = "Emerson Aracdia 2001"
                prg_Commands$ = "arcadia -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 152:
                prgDescriptn$ = "Entex Adventure Vision"
                prg_Commands$ = "advision -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 153:
                prgDescriptn$ = "Epoch Super Casette Vision"
                prg_Commands$ = "epoch -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 154:
                prgDescriptn$ = "Fairchild Channel F"
                prg_Commands$ = "channlf -skip_gameinfo -cart %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 155:
                prgDescriptn$ = "FM-Towns Marty [CD-Rom]"
                prg_Commands$ = "fmtowns -skip_gameinfo -cdrom %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 156:
                prgDescriptn$ = "FM-Towns Marty [1x Floppy]"
                prg_Commands$ = "fmtowns -skip_gameinfo -fdc:0 35dd -flop1 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 157:
                prgDescriptn$ = "FM-Towns Marty [2x Floppy]"
                prg_Commands$ = "fmtowns -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 158:
                prgDescriptn$ = "FM-Towns Marty [2 Drive & CD-Rom]"
                prg_Commands$ = "fmtowns -skip_gameinfo -fdc:0 35dd -flop1 %s -fdc:1 35dd -flop2 %s -cdrom %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 159:
                prgDescriptn$ = "NEC PC-9821 [2 Drives & CD-Rom]"
                prg_Commands$ = "pc9821 -skip_gameinfo -upd765_2hd:0 525hd -flop1 %s -upd765_2hd:1 525hd -flop2 %s -cdrom %s"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 160:
                prgDescriptn$ = "NEC PC-Engine"
                prg_Commands$ = "pce -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 161:
                prgDescriptn$ = "NEC SuperGrafx"
                prg_Commands$ = "sgx -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""        
                
             Case 162:
                prgDescriptn$ = "NEC TurboGrafx 16"
                prg_Commands$ = "tg16 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 163:
                prgDescriptn$ = "PC-Engine (CD-Rom)"
                prg_Commands$ = "pce -cart %s -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 164:
                prgDescriptn$ = "SuperGrafx (CD-Rom)"
                prg_Commands$ = "sgx -cart %s -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 165:
                prgDescriptn$ = "NEC TurboGrafx 16 (CD-Rom)"
                prg_Commands$ = "tg16 -cart %s -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 166:
                prgDescriptn$ = "SNK NeoGeo CD"
                prg_Commands$ = "neocd -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 167:
                prgDescriptn$ = "SNK NeoGeo CD/z"
                prg_Commands$ = "neocdz -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 168:
                prgDescriptn$ = "SNK NeoGeo Pocket (Mono)"
                prg_Commands$ = "ngp -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
             Case 169:
                prgDescriptn$ = "SNK NeoGeo Pocket (Color)"
                prg_Commands$ = "ngpc -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""      
                
                
             Case 170:
                prgDescriptn$ = "GCE Vectrex"
                prg_Commands$ = "vectrex -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""         
                
             Case 171:
                prgDescriptn$ = "Magnavox Odyssey2"
                prg_Commands$ = "odyssey2 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""        
                
             Case 172:
                prgDescriptn$ = "MSX 1"
                prg_Commands$ = "msx -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 173:
                prgDescriptn$ = "MSX 2"
                prg_Commands$ = "msx2 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 174:
                prgDescriptn$ = "Philips CD-i (Mono-1/ PAL)"
                prg_Commands$ = "cdimono1 -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 175:
                prgDescriptn$ = "Philips CD-i (Mono-2/ PAL)"
                prg_Commands$ = "cdimono2 -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
             Case 176:
                prgDescriptn$ = "Philips CD-i 490 (PAL)"
                prg_Commands$ = "cdi490a -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 177:
                prgDescriptn$ = "Philips CD-i 910 (PAL)"
                prg_Commands$ = "cdi910 -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = "" 
                
             Case 178:
                prgDescriptn$ = "Philips VidePAC+"
                prg_Commands$ = "videopac -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""      
                
             Case 179:
                prgDescriptn$ = "Panasonic 3DO (PAL)"
                prg_Commands$ = "3do_pal -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 180:
                prgDescriptn$ = "Panasonic 3DO (NTSC)"
                prg_Commands$ = "3do -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""          
                
             Case 181:
                prgDescriptn$ = "Sega SG-1000"
                prg_Commands$ = "sg1000 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""      
                
             Case 182:
                prgDescriptn$ = "Sega SG-1000 (m3)"
                prg_Commands$ = "sg1000m3 -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""         
                
             Case 183:
                prgDescriptn$ = "Sega Pico"
                prg_Commands$ = "picou -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 184:
                prgDescriptn$ = "Sega Game Gear (JP)"
                prg_Commands$ = "gamegear -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""          
                
             Case 185:
                prgDescriptn$ = "Sega Game Gear (EU/US)"
                prg_Commands$ = "gamegeaj -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 186:
                prgDescriptn$ = "Sega Master System 1 (PAL)"
                prg_Commands$ = "sms1pal -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 187:
                prgDescriptn$ = "Sega Master System 1 (JP)"
                prg_Commands$ = "smsj -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 188:
                prgDescriptn$ = "Sega Master System II"
                prg_Commands$ = "sms -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 189:
                prgDescriptn$ = "Sega Master System II (PAL)"
                prg_Commands$ = "smspal -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 190:
                prgDescriptn$ = "Sega Mega-Drive / Genesis (US)"
                prg_Commands$ = "genesis -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
                
             Case 191:
                prgDescriptn$ = "Sega Mega-Drive / Genesis (US/ TMSS Chip)"
                prg_Commands$ = "genesis_tmss -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 192:
                prgDescriptn$ = "Sega Mega-Drive / Genesis (EU)"
                prg_Commands$ = "megadriv -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""
                
             Case 193:
                prgDescriptn$ = "Sega Mega-Drive / Genesis (JP)"
                prg_Commands$ = "megadriv -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""       
                
             Case 194:
                prgDescriptn$ = "Sega Mega-CD / Sega-CD (US)"
                prg_Commands$ = "segacd -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""     
                
             Case 195:
                prgDescriptn$ = "Sega Mega-CD / Sega-CD (EU)"
                prg_Commands$ = "megacd -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""  
                
             Case 196:
                prgDescriptn$ = "Sega Mega-CD / Sega-CD (JP)"
                prg_Commands$ = "megacdj -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""    
                
             Case 197:
                prgDescriptn$ = "Sega Mega-CD II / Sega-CD 2 (US)"
                prg_Commands$ = "segacd2 -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""       
                
             Case 198:
                prgDescriptn$ = "Sega Mega-CD II / Sega-CD 2 (EU)"
                prg_Commands$ = "megacd2 -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 199:
                prgDescriptn$ = "Sega Mega-CD II / Sega-CD 2 (JP)"
                prg_Commands$ = "aiwamcd -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""        
                
             Case 200:
                prgDescriptn$ = "Sega Mega-Drive 32X (US)"
                prg_Commands$ = "32x -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""    
                
             Case 201:
                prgDescriptn$ = "Sega Mega-Drive 32X (EU)"
                prg_Commands$ = "32xe -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 202:
                prgDescriptn$ = "Sega Mega-Drive 32X (JP)"
                prg_Commands$ = "32xj -cart %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                
                
             Case 203:
                prgDescriptn$ = "Sega Mega-CD 32x / Sega-CD 32x (US)"
                prg_Commands$ = "32x_scd -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                
                
             Case 204:
                prgDescriptn$ = "Sega Mega-CD 32x / Sega-CD 32x (EU)"
                prg_Commands$ = "32x_mcd -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""        
                
             Case 205:
                prgDescriptn$ = "Sega Mega-CD 32x / Sega-CD 32x (JP)"
                prg_Commands$ = "32x_mcdj -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 206:
                prgDescriptn$ = "Sega Saturn (US)"
                prg_Commands$ = "saturn -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""       
                
             Case 207:
                prgDescriptn$ = "Sega Saturn (JP)"
                prg_Commands$ = "saturnjp -cdrom %s -skip_gameinfo"
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 208:
                prgDescriptn$ = "Sega Saturn (EU)"
                prg_Commands$ = "saturneu -cdrom %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 209:
                prgDescriptn$ = "Sega Dreamcast (EU)"
                prg_Commands$ = "dceu -cdrom %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 210:
                prgDescriptn$ = "Sega Dreamcast (JP)"
                prg_Commands$ = "dcjp -cdrom %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""     
                
             Case 211:
                prgDescriptn$ = "Sega Dreamcast (US)"
                prg_Commands$ = "dc -cdrom %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 212:
                prgDescriptn$ = "Sharp X68000"
                prg_Commands$ = "x68000 -flop1 %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""     
                
             Case 213:
                prgDescriptn$ = "Sinclair ZX Spectrum"
                prg_Commands$ = "spectrum -flop %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 214:
                prgDescriptn$ = "Nintendo NES/ Famicon (NTSC)"
                prg_Commands$ = "nes -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 215:
                prgDescriptn$ = "Nintendo NES/ Famicon (PAL)"
                prg_Commands$ = "nespal -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                
                
             Case 216:
                prgDescriptn$ = "Nintendo SNES/ Super Famicon (NTSC)"
                prg_Commands$ = "snes -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 217:
                prgDescriptn$ = "Nintendo SNES/ Super Famicon (PAL)"
                prg_Commands$ = "snespal -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
             Case 218:
                prgDescriptn$ = "Nintendo 64"
                prg_Commands$ = "n64 -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 219:
                prgDescriptn$ = "Nintendo 64 DD"
                prg_Commands$ = "64DD -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
             Case 220:
                prgDescriptn$ = "Nintendo Virtual Boy"
                prg_Commands$ = "vboy -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = "" 
                
             Case 221:
                prgDescriptn$ = "Nintendo Game Boy"
                prg_Commands$ = "gameboy -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""    
                
             Case 222:
                prgDescriptn$ = "Nintendo Game Boy Pocket"
                prg_Commands$ = "gbpocket -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                  
                
             Case 223:
                prgDescriptn$ = "Nintendo Game Boy Color"
                prg_Commands$ = "gbcolor -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = "" 
                
             Case 224:
                prgDescriptn$ = "Nintendo Game Boy Advance"
                prg_Commands$ = "gba -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""    
                
             Case 225:
                prgDescriptn$ = "Nintendo Super Game Boy"
                prg_Commands$ = "supergb -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
             Case 226:
                prgDescriptn$ = "Nintendo Super Game Boy II"
                prg_Commands$ = "supergb2 -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 227:
                prgDescriptn$ = "Bandai Wonderswan (Mono)"
                prg_Commands$ = "wswan -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                
                
             Case 228:
                prgDescriptn$ = "Bandai Wonderswan (Color)"
                prg_Commands$ = "wscolor -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 229:
                prgDescriptn$ = "TRS-80"
                prg_Commands$ = "trs80m3 -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = "" 
                
             Case 230:
                prgDescriptn$ = "VTech CreatVision"
                prg_Commands$ = "crvisio -cart %s -skip_gameinfo"                
                prgShortName$ = "Mame"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 231:
                prgDescriptn$ = "DoomsDay: Doom 1"
                prg_Commands$ = "-wnd -game doom1 -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 232:
                prgDescriptn$ = "DoomsDay: Doom 1 (Ultimate)"
                prg_Commands$ = "-wnd -game doom1-ultimate -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 233:
                prgDescriptn$ = "DoomsDay: Doom 1 Shareware"
                prg_Commands$ = "-wnd -game doom1-share -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 234:
                prgDescriptn$ = "DoomsDay: Doom 2"
                prg_Commands$ = "-wnd -game doom2 -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 235:
                prgDescriptn$ = "DoomsDay: Doom 2 Plutonia"
                prg_Commands$ = "-wnd -game doom2-plut -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
             Case 236:
                prgDescriptn$ = "DoomsDay: TNT Evilution"
                prg_Commands$ = "-wnd -game doom2-tnt -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                
                
             Case 237:
                prgDescriptn$ = "DoomsDay: Chex Quest"
                prg_Commands$ = "-wnd -game chex -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                
                
             Case 238:
                prgDescriptn$ = "DoomsDay: HacX"
                prg_Commands$ = "-wnd -game hacx -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
             Case 239:
                prgDescriptn$ = "DoomsDay: Heretic 1 Shareware"
                prg_Commands$ = "-wnd -game heretic-share -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 240:
                prgDescriptn$ = "DoomsDay: Heretic 1"
                prg_Commands$ = "-wnd -game heretic -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 241:
                prgDescriptn$ = "DoomsDay: Heretic 1 Serpent Riders"
                prg_Commands$ = "-wnd -game heretic-ext -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = "" 
                                
             Case 242:
                prgDescriptn$ = "DoomsDay: Hexen 1 Demo"
                prg_Commands$ = "-wnd -game hexen-demo -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 243:
                prgDescriptn$ = "DoomsDay: Hexen 1"
                prg_Commands$ = "-wnd -game hexen -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 244:
                prgDescriptn$ = "DoomsDay: Hexen 1 DeathKings"
                prg_Commands$ = "-wnd -game hexen-dk -iwad %s"                
                prgShortName$ = "DoomsDay"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 245:
                prgDescriptn$ = "D2X-XL: Descent 1 and 2"
                prg_Commands$ = "-fullscreen 0 -userdir %s"                
                prgShortName$ = "D2X-XL"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""  
                
             Case 246:
                prgDescriptn$ = "bSnes: Super Nintendo"
                prg_Commands$ = "%s"                
                prgShortName$ = "bsnes"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""     
                
             Case 247:
                prgDescriptn$ = "Snes9x: Super Nintendo"
                prg_Commands$ = "%s %pk"                
                prgShortName$ = "snes9x-x64"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 248:
                prgDescriptn$ = "Mednafen: Sega Saturn"
                prg_Commands$ = "-ss.input.port1 gamepad -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"                
                prgShortName$ = "Mednafen"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 249:
                prgDescriptn$ = "Mednafen: Sega Saturn"
                prg_Commands$ = "-ss.input.port1 3dpad -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"                
                prgShortName$ = "Mednafen"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 250:
                prgDescriptn$ = "Mednafen: Sega Saturn"
                prg_Commands$ = "-ss.input.port1 mouse -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"                
                prgShortName$ = "Mednafen"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 251:
                prgDescriptn$ = "Mednafen: Sega Saturn"
                prg_Commands$ = "-ss.input.port1 wheel -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"                
                prgShortName$ = "Mednafen"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 252:
                prgDescriptn$ = "Mednafen: Sega Saturn"
                prg_Commands$ = "-ss.input.port1 gun -ss.xscale 3.800000 -ss.yscale 4.220000 -ss.scanlines 66 -ss.stretch 0 -ss.shader none -ss.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -ss.videoip 0 -video.fs 0 -video.frameskip 0 -ss.bios_sanity 1 -ss.cd_sanity 1 -filesys.untrusted_fip_check 0 -ss.smpc.autortc.lang german -ss.shader goat -ss.shader.goat.pat borg -ss.shader.goat.hdiv 0.25 -ss.shader.goat.slen 1 -ss.shader.goat.tp 0.7 -ss.h_blend 1 -ss.cart.auto_default cs1ram16 -ss.cart cs1ram16 -loadcd ss %s"                
                prgShortName$ = "Mednafen"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 253:
                prgDescriptn$ = "Mednafen: Playstation 1"
                prg_Commands$ = "-psx.input.port1 dualshock -psx.region_autodetect 1 -psx.xscale 3.800000 -psx.yscale 3.8 -psx.scanlines 66 -psx.stretch 0 -psx.shader none -psx.special none -video.driver opengl -video.glvsync 0 -sound 1 -video.blit_timesync 0 -psx.videoip 0 -video.fs 0 -video.frameskip 0 -psx.bios_sanity 1 -psx.cd_sanity 1 -filesys.untrusted_fip_check 0 -psx.shader goat -psx.shader.goat.pat borg -psx.shader.goat.hdiv 0.25 -psx.shader.goat.slen 1 -psx.shader.goat.tp 0.7 -psx.input.port1.memcard 1 -loadcd psx %s"                
                prgShortName$ = "Mednafen"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                 
                
             Case 254:
                prgDescriptn$ = "Microsoft Xbox360: Xenia"
                prg_Commands$ = "%s"                
                prgShortName$ = "Xenia"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""    
                
             Case 255:
                prgDescriptn$ = "Microsoft Xbox Classic: CXBX"
                prg_Commands$ = "%s"                
                prgShortName$ = "cxbx"      :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""   
                
             Case 256:
                prgDescriptn$ = "Sega Dreamcast: ReDream"
                prg_Commands$ = "%s"                
                prgShortName$ = "redream"   :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""                   
                
             Case 257:
                prgDescriptn$ = "Nintendo Wii-U: Cemu"
                prg_Commands$ = "-g %s"                
                prgShortName$ = "cemu"   :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
             Case 258:
                prgDescriptn$ = "Sega Saturn: Kronos"
                prg_Commands$ = "--autostart --iso=%s"
                prgShortName$ = "Kronos"  :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""                  
                
             Case 259:
                prgDescriptn$ = "Microsoft Xbox360: Xenia Canary"
                prg_Commands$ = "%s"                
                prgShortName$ = "xenia-canary"   :File_Default$ = prgShortName$ + ".exe" :   Path_Default$  = ""
                
            Case 260:
                prgDescriptn$ = "Sony Playstation 1: DuckStation (SDL)"
                prg_Commands$ = "%s"
                prgShortName$ = "duckstation-sdl-x64-ReleaseLTCG" :File_Default$ = prgShortName$ + ".exe" :   Path_Default$ = ""   
            Case 261 To 280               
                
                    vSystem::System_Compat_MenuItemW(MenuID)            
                    ProcedureReturn 
            Case 284 To 364
                    
                    vSystem::System_Compat_MenuItemE(MenuID) 
                    ProcedureReturn   
                    
            Case 365 To ( 365 + UnrealHelp::GetMaxItems()-1 )                    
                    vSystem::System_Unreal_MenuItemC(MenuID)
                    ProcedureReturn   
                    
                    
                
        EndSelect           

        vItemTool::Item_New_FomMenu(prgDescriptn$, prgShortName$, prg_Commands$, File_Default$ ,Path_Default$)
        
    EndProcedure
    Procedure Set_AppMenu()        
        ;
        ; ============================================================= Windows Compatibility
        OpenSubMenu("Windows Compatiblity")
            ;OpenSubMenu("Compatibility Mode")  
                MenuItem(261, "Windows 95") 
                MenuItem(262, "Windows 98")
                MenuItem(263, "Windows 2000 SP2")                
                MenuItem(264, "Windows 2000 SP2")
                MenuItem(265, "Windows 2000 SP3")
                MenuItem(266, "Windows XP")
                MenuItem(267, "Windows XP SP1")
                MenuItem(268, "Windows XP SP2")
                MenuItem(269, "Windows XP SP2 (GW)")
                MenuItem(270, "Windows XP SP3")
                MenuItem(271, "Windows Vista RTM")
                MenuItem(272, "Windows Vista RTM (GW)")
                MenuItem(273, "Windows Vista SP1")
                MenuItem(274, "Windows Vista SP2")
                MenuItem(275, "Windows 7 /RTM")
                MenuItem(276, "Windows NT4 SP5")
                MenuBar()                
                MenuItem(277, "Server 2003")
                MenuItem(278, "Server 2003 SP1")
                MenuItem(279, "Server 2008R2 RTM")
                MenuItem(280, "Server 2008 SP1")               
                ;CloseSubMenu()
            MenuBar()
            OpenSubMenu("Privilege Level")
                MenuItem(343, "Run as Admin")
                MenuItem(344, "Run as Highest")       
                MenuItem(345, "Run as Highest GW") 
                MenuItem(346, "Run as Invoker") 
                MenuItem(310, "Elevate Create Process")                
            CloseSubMenu()
            MenuBar() 
 
            OpenSubMenu("Standard Settings") 
                MenuItem(287, "Reduced 8-bit (256) Color")
                MenuItem(288, "Run in 640 x 480 Screen") 
                MenuItem(304, "Disable Visual Themes")
                MenuItem(299, "Disable Desktop Composition")
                MenuItem(324, "Disable High DPI Settings") 
            CloseSubMenu()
                
            OpenSubMenu("Settings DirectX") 
                MenuItem(284, "8 And 16Bit GDI Redraw")  
                MenuItem(285, "8 And 16Bit Aggregate Blts") 
                MenuItem(286, "8 And 16Bit DX Max WinMode")
                MenuItem(297, "Disable 8 And 16Bit D3D")             
                MenuItem(291, "Accel Gdi pFlush")
                MenuItem(306, "DWM 8 And 16Bit Mitigation") 
                MenuItem(307, "DirectX Trim Texture Formats") 
                MenuItem(308, "DirectX Version Lie")
                                ;Sie können diese Korrektur weiter steuern, indem Sie den folgenden Befehl an der Eingabeaufforderung eingeben:
                                ;MAJORVERSION. MINORVERSION. LETTER
                                ;Beispiel: 9.0.c.                  
                MenuItem(309, "DXGI Compat")
                MenuItem(349, "Text Art") 
                MenuItem(350, "Trim DisplayDevice Names") 
            CloseSubMenu()                              
            OpenSubMenu("Settings Optional") 
                ;MenuItem(289, "API Tracing") 
                ;MenuItem(290, "App Recorder") 
                MenuItem(296, "Custom NC Render") 
                MenuItem(292, "Change FolderPath To XP Style")             
                MenuItem(293, "Clear Last Error Status on Intialize Critical Section") 
                ;MenuItem(294, "Correct Create Brush Indirect Hatch") 
                MenuItem(295, "Correct File Paths")                 
                ;MenuItem(298, "Disable Cicero")                  
                MenuItem(300, "Disable FadeAnimations")
                MenuItem(301, "Disable NX Hide UI")
                MenuItem(302, "Disable NX Show UI") 
                MenuItem(303, "Disable Theme Menus")                 
                ;MenuItem(305, "DW")                                 
                MenuItem(311, "Emulate Sorting")
                MenuItem(312, "Emulate Sorting Server 2008")
                MenuItem(313, "Emulate GetDisk FreeSpace") 
                ;MenuItem(314, "Enable II SBizTalk") 
                MenuItem(315, "Enable NX Show UI") 
                MenuItem(316, "Fault Tolerant Heap") 
                ;MenuItem(317, "FDR") 
                ;MenuItem(318, "Force Dx Setup Success") 
                MenuItem(319, "Global Memory Status 2GB") 
                MenuItem(310, "Global Memory Status Lie") 
                MenuItem(321, "GetDrive TypeW Hook") 
                MenuItem(322, "HandleBad Ptr")
                MenuItem(323, "Heap Clear Allocation")                
                ;MenuItem(325, "Ignore Adobe KM PrintDriver MessageBox") 
                MenuItem(326, "Ignore AltTab") 
                MenuItem(327, "Ignore Directory Junction") 
                MenuItem(328, "Ignore Exception") 
                MenuItem(329, "Ignore Floating Point Rounding Control") 
                MenuItem(320, "Ignore Font Quality") 
                MenuItem(331, "Ignore SetROP2")  
                MenuItem(332, "Layer Force 640x480x8")
                MenuItem(333, "Layer Force Direct Draw Emulation") 
                MenuItem(334, "Layer Win95 Version Lie") 
                MenuItem(335, "Load Library Redirect") 
                ;MenuItem(336, "Msi Auto") 
                ;MenuItem(337, "Null Environment") 
                ;MenuItem(338, "pLayer GetProc Addr Ex Override") 
                MenuItem(339, "PopCap Games Force Res Perf") 
                MenuItem(330, "Process Perf Data") 
                ;MenuItem(341, "Profiles Setup")   
                ;MenuItem(342, "Redirect CHH locale to CHT")                 
                ;MenuItem(347, "SecuROM 7")                
                MenuItem(348, "System Metrics Lie")                                                     
                MenuItem(351, "Verify Version Info Lite Layer")  
                MenuItem(352, "Virtual Registry")   
                MenuItem(355, "WinG32 Sys to Sys32")  
                MenuItem(356, "WRP Mitigation Layer")                                  
            CloseSubMenu() 
            OpenSubMenu("Settings Windows Lie")
                MenuItem(353, "Win95 Version Lie")  
                MenuItem(354, "Win98 Version Lie")  
                MenuItem(355, "WinNT4 SP5 Version Lie")  
                MenuItem(356, "Win2000 Version Lie")  
                MenuItem(357, "Win2000 SP1 Version Lie")  
                MenuItem(358, "Win2000 SP2 Version Lie")  
                MenuItem(359, "Win2000 SP3 Version Lie")  
                MenuItem(360, "WinXP Version Lie")  
                MenuItem(361, "WinXP SP2 Version Lie")  
                MenuItem(362, "WinXP SP3 Version Lie")  
                MenuItem(363, "Vista SP1 Version Lie")  
                MenuItem(364, "Vista SP2 Version Lie")             
            CloseSubMenu()             
            ; https://docs.microsoft.com/de-de/windows/deployment/planning/compatibility-fixes-for-windows-8-windows-7-and-windows-vista
        CloseSubMenu()
      
        MenuBar()
        OpenSubMenu("Unreal Command")
        UseModule UnrealHelp
        Debug "Open Unreal Menü"           
        MxItem = GetMaxItems()-1
        For unItem = 0 To MxItem
            
            NextElement(UnrealCommandline())
                            
            If UnrealCommandline()\bMenuSubBeg = #True                 
                OpenSubMenu(UnrealCommandline()\UDK_Description$)                
                Continue
            ElseIf UnrealCommandline()\bMenuSubEnd = #True
                CloseSubMenu()
                Continue
            ElseIf UnrealCommandline()\bMenuBar = #True                 
                MenuBar()
                Continue                
            EndIf    
            
            MenuItem(UnrealCommandline()\MenuIndex, UnrealCommandline()\UDK_Description$)                                                  
                            
            Debug "Adding Unreal Menü " + UnrealCommandline()\UDK_Description$
        Next
        UnuseModule UnrealHelp                      
        CloseSubMenu() 
        MenuBar()
        ;
        ; ============================================================= Ports / Nativ        
        OpenSubMenu("Ports, Nativ")         
            OpenSubMenu("CheX Quest")
                MenuItem(237, "DoomsDay: CheX Quest")                
            CloseSubMenu()         
            MenuBar()              
            OpenSubMenu("Descent 1 && 1")
                MenuItem(245, "D2X-XL: Descent 1 and 2")                
            CloseSubMenu()  
            MenuBar()                  
            OpenSubMenu("Doom 1")
                MenuItem(231, "DoomsDay: Doom 1")        
                MenuItem(232, "DoomsDay: Doom 1 Ultimate")
                MenuItem(233, "DoomsDay: Doom 1 Shareware")           
            CloseSubMenu()         
            MenuBar()              
            OpenSubMenu("Doom 2")
                MenuItem(234, "DoomsDay: Doom 2")                
            CloseSubMenu()             
            OpenSubMenu("Doom 2: Plutonia")
                MenuItem(235, "DoomsDay: Plutonia")                
            CloseSubMenu()                         
            OpenSubMenu("Doom 2: TNT")
                MenuItem(236, "DoomsDay: TNT")                
            CloseSubMenu()               
            MenuBar()                          
            OpenSubMenu("Duke Nukem 3D")
                MenuItem(14, "eDuke32: Default Load")        
                MenuItem(12, "eDuke32: WW2 GI Load")
                MenuItem(13, "eDuke32: NAM (Napalm) Load")           
            CloseSubMenu() 
            MenuBar()                  
            OpenSubMenu("HacX")
                MenuItem(238, "DoomsDay: HacX")                
            CloseSubMenu()
            MenuBar()                  
            OpenSubMenu("Heretic 1")
                MenuItem(239, "DoomsDay: Heretic 1")                
                MenuItem(240, "DoomsDay: Serpent Riders")  
                MenuItem(241, "DoomsDay: Shareware")                
            CloseSubMenu()            
            MenuBar()              
            OpenSubMenu("Hexen 1")
                MenuItem(242, "DoomsDay: Hexen 1")                
                MenuItem(243, "DoomsDay: DeathKings")  
                MenuItem(244, "DoomsDay: Shareware")                
            CloseSubMenu()              
            MenuBar()              
            OpenSubMenu("Window Media Player")
                MenuItem(10, "32 Bit: Movie Load/ Fullscreen")
                MenuItem(11, "64 Bit: Movie Load/ Fullscreen")            
            CloseSubMenu()              
        CloseSubMenu()         
        MenuBar()          
        
        ;
        ; ============================================================= Adventure Vision        
        OpenSubMenu("System: Adventure Vision")  
            OpenSubMenu("Entex: Mame/Mess")
                MenuItem(152, "Variant: Image Load")
            CloseSubMenu()        
        CloseSubMenu()  
        
        ;
        ; ============================================================= Amstrad          
        OpenSubMenu("System: Amstrad")
            OpenSubMenu("M.A.M.E.")
                MenuItem(96, "Variant: CPC4-64")
                MenuItem(97, "Variant: CPC4-64/ Plus")            
            CloseSubMenu()         
        CloseSubMenu()
        
        ;
        ; ============================================================= Arcade            
        OpenSubMenu("System: Arcade")
            OpenSubMenu("M.A.M.E.")
                MenuItem(64, "Variant: Load Default Rom")
            CloseSubMenu()             
            OpenSubMenu("Final Burn Alpha")
                MenuItem(65, "Variant: Load Default CD")
            CloseSubMenu()             
        CloseSubMenu()
        
        ;
        ; ============================================================= Aracdia 2001          
        OpenSubMenu("System: Aracdia 2001")  
            OpenSubMenu("Aracdia: Mame/Mess")
                MenuItem(151, "Variant: Image Load")
            CloseSubMenu()        
        CloseSubMenu()  
        
        ;
        ; ============================================================= Atari        
        OpenSubMenu("System: Atari")
            OpenSubMenu("400: Mame/Mess")
                MenuItem(114, "Variant: Cart Load")             
            CloseSubMenu()         
            OpenSubMenu("800xl: Mame/Mess")
                MenuItem(115, "Variant: Cart Load")               
            CloseSubMenu()
            OpenSubMenu("2600: Mame/Mess")
                MenuItem(116, "Variant: Cart Load")             
            CloseSubMenu()                  
            OpenSubMenu("5200: Mame/Mess")
                MenuItem(117, "Variant: Cart Load")             
            CloseSubMenu()                  
            OpenSubMenu("7800: Mame/Mess")
                MenuItem(118, "Variant: Cart Load")             
            CloseSubMenu()                  
            MenuBar()                                                                      
            OpenSubMenu("ST: Hatari")
                MenuItem(22, "Variant: Floppy 1x")
                MenuItem(23, "Variant: Floppy 2x")            
            CloseSubMenu()                 
            OpenSubMenu("ST: Mame/Mess")
                MenuItem(122, "Variant: 1 Drive [DE]")
                MenuItem(123, "Variant: 2 Drive [DE]")    
                MenuItem(124, "Variant: 1 Drive [US]")
                MenuItem(125, "Variant: 2 Drive [US]")                 
            CloseSubMenu() 
            MenuBar()             
            OpenSubMenu("ST/e: Mame/Mess")
                MenuItem(126, "Variant: 1 Drive [DE]")
                MenuItem(127, "Variant: 2 Drive [DE]")    
                MenuItem(128, "Variant: 1 Drive [US]")
                MenuItem(129, "Variant: 2 Drive [US]")                 
            CloseSubMenu()             
            MenuBar()             
            OpenSubMenu("MegaST: Mame/Mess")
                MenuItem(130, "Variant: 1 Drive [DE]")
                MenuItem(131, "Variant: 2 Drive [DE]")    
                MenuItem(132, "Variant: 1 Drive [US]")
                MenuItem(133, "Variant: 2 Drive [US]")                 
            CloseSubMenu()
            MenuBar()             
            OpenSubMenu("MegaST/e: Mame/Mess")
                MenuItem(134, "Variant: 1 Drive [DE]")
                MenuItem(135, "Variant: 2 Drive [DE]")    
                MenuItem(136, "Variant: 1 Drive [US]")
                MenuItem(137, "Variant: 2 Drive [US]")                 
            CloseSubMenu()            
            MenuBar()             
            OpenSubMenu("TT: Hatari")
                MenuItem(24, "Variant: Floppy 1x")
                MenuItem(25, "Variant: Floppy 2x")            
            CloseSubMenu()  
            MenuBar()                 
            OpenSubMenu("Falcon: Hatari")
                MenuItem(26, "Variant: Floppy 1x")
                MenuItem(27, "Variant: Floppy 2x")             
            CloseSubMenu()              
            OpenSubMenu("Other: SteemSSE")
                MenuItem(21, "Variant: Image Load")
            CloseSubMenu() 
            MenuBar()                 
            OpenSubMenu("Lynx: Mame/Mess")
                MenuItem(119, "Variant: Rom Load")             
            CloseSubMenu()  
            MenuBar()             
            OpenSubMenu("Jaguar: Mame/Mess")
                MenuItem(120, "Variant: Rom Load")             
            CloseSubMenu()              
            OpenSubMenu("Jaguar: VirtualJaguar")
                MenuItem(67, "Variant: Rom Load")
            CloseSubMenu()            
            OpenSubMenu("Jaguar CD: Mame/Mess")
                MenuItem(121, "Variant: CD Load")
            CloseSubMenu()           
         CloseSubMenu() 
         
        ;
        ; ============================================================= Apple            
        OpenSubMenu("System: Apple")
            OpenSubMenu(" Apple 1: Mame/Mess")
                MenuItem(98, "Variant: Cart Load")           
            CloseSubMenu() 
            OpenSubMenu(" Apple //: Mame/Mess")
                MenuItem(99 , "Variant: Cart Load [Plus]") 
                MenuBar() 
                MenuItem(100, "Variant: Cart Load [//c]")              
                MenuItem(101, "Variant: Cart Load [//c OME]")                
                MenuItem(102, "Variant: Cart Load [//c Rev 4]")                 
                MenuItem(103, "Variant: Cart Load [//c Unidisk]")     
                MenuItem(104, "Variant: Cart Load [//c Plus]")                 
                MenuBar() 
                MenuItem(105, "Variant: Cart Load [//e]")                
                MenuItem(106, "Variant: Flop Load [//e]")                 
                MenuItem(107, "Variant: Cart Load [//e Enhanced]")               
                MenuItem(108, "Variant: Cart Load [//e Enhanced, UK]")
                MenuItem(109, "Variant: Cart Load [//e Platinum]")                 
                MenuItem(110, "Variant: Cart Load [//e UK]")  
                MenuItem(111, "Variant: Cart Load [//gs]")                 
                MenuItem(112, "Variant: Flop Load [//gs]")                 
           CloseSubMenu()                 
            OpenSubMenu(" Apple ///: Mame/Mess")
                MenuItem(98, "Variant: Cart Load")           
            CloseSubMenu()             
        CloseSubMenu() 
        
        ;
        ; ============================================================= Coleco         
        OpenSubMenu("System: Coleco")         
            OpenSubMenu(" Coleco Vision: Mame/Mess")
                MenuItem(138, "Variant: Cart Load [NTSC]")
                MenuItem(139, "Variant: Cart Load [PAL]")          
            CloseSubMenu()       
        CloseSubMenu()
        
        ;
        ; ============================================================= Commodore          
        OpenSubMenu("System: Commodore") 
            OpenSubMenu("C=64: Hoxs64")
                MenuItem(17, "Variant: Autoload")
                MenuItem(18, "Variant: PRG Load")  
                MenuItem(19, "Variant: Image:FileName")
                MenuItem(20, "Variant: Image:Number")            
            CloseSubMenu()         
            OpenSubMenu("C=64: Micro64")
                MenuItem(16, "Variant: Image Load")
            CloseSubMenu() 
            OpenSubMenu("C=64: Vice")  
                MenuItem(35, "Variant: Default")  
                MenuItem(34, "Variant: Use Config File")   
                MenuBar()                  
                MenuItem(28, "Variant: Floppy 1x")
                MenuItem(29, "Variant: Floppy 2x")
                MenuBar() 
                MenuItem(30, "Variant: Floppy 1x, Cart, Cass")   
                MenuItem(31, "Variant: Floppy 2x, Cart, Cass")             
                MenuBar()   
                MenuItem(32, "Variant: OpenCBM")
                MenuItem(33, "Variant: OpenCBM, Cart")   
            CloseSubMenu()    
            OpenSubMenu("C=64: Mame/Mess")                  
                MenuItem(147, "Variant: 1x 1541-II")     
                MenuItem(148, "Variant: 2x 1541-II")             
                MenuBar()                 
                MenuItem(140, "Variant: Cart Only")                 
                MenuItem(141, "Variant: Cart & Datasette")       
                MenuItem(142, "Variant: Cart & 1x 1541-II")     
                MenuItem(143, "Variant: Cart & 2x 1541-II")     
                MenuBar()                 
                MenuItem(144, "Variant: Datasette")     
                MenuItem(145, "Variant: Datasette & 1x 1541-II")     
                MenuItem(146, "Variant: Datasette & 2x 1541-II")                             
            CloseSubMenu()
            MenuBar()                 
            OpenSubMenu("C= Amiga: Mame/Mess")
                MenuItem(70, "Variant: Amiga 500, 1 Drive")
                MenuItem(71, "Variant: Amiga 500, 2 Drives")
                MenuItem(72, "Variant: Amiga 500, 3 Drives")            
                MenuItem(73, "Variant: Amiga 500, 4 Drives")                
                MenuBar() 
                MenuItem(74, "Variant: Amiga 2000, 1 Drive")
                MenuItem(75, "Variant: Amiga 2000, 2 Drives")
                MenuItem(76, "Variant: Amiga 2000, 3 Drives")            
                MenuItem(77, "Variant: Amiga 2000, 4 Drives")                
                MenuBar() 
                MenuItem(78, "Variant: Amiga 3000, 1 Drive")
                MenuItem(79, "Variant: Amiga 3000, 2 Drives")
                MenuItem(80, "Variant: Amiga 3000, 3 Drives")            
                MenuItem(81, "Variant: Amiga 3000, 4 Drives")                 
                MenuBar() 
                MenuItem(82, "Variant: Amiga 1200, 1 Drive")
                MenuItem(83, "Variant: Amiga 1200, 2 Drives")
                MenuItem(84, "Variant: Amiga 1200, 3 Drives")            
                MenuItem(85, "Variant: Amiga 1200, 4 Drives")                
                MenuBar() 
                MenuItem(86, "Variant: Amiga 4000/030, 1 Drive")
                MenuItem(87, "Variant: Amiga 4000/030, 2 Drives")
                MenuItem(88, "Variant: Amiga 4000/030, 3 Drives")            
                MenuItem(89, "Variant: Amiga 4000/030, 4 Drives")                 
                MenuBar() 
                MenuItem(90, "Variant: Amiga 4000/040, 1 Drive")
                MenuItem(91, "Variant: Amiga 4000/040, 2 Drives")
                MenuItem(92, "Variant: Amiga 4000/040, 3 Drives")            
                MenuItem(93, "Variant: Amiga 4000/040, 4 Drives")
                MenuBar() 
                MenuItem(94, "Variant: Amiga CDTV")
                MenuItem(95, "Variant: Amiga CD32")                
            CloseSubMenu()                  
            OpenSubMenu("C= Amiga: WinUAE)")
                MenuItem(36, "Variant: Use Config, 4 Drives")
                MenuItem(37, "Variant: Use Config, CDRom")
            CloseSubMenu()   
            MenuBar()                 
            OpenSubMenu("C= Plus/4: Yape")
                MenuItem(4, "Variant: Image Load")
            CloseSubMenu()
            OpenSubMenu("C= Vic20: Mame/Mess")
                MenuItem(149, "Variant: Cart Load [NTSC]")
                MenuItem(150, "Variant: Cart Load [PAL]")            
            CloseSubMenu()                             
        CloseSubMenu() 
        
        ;
        ; ============================================================= Fairchild Channel F            
        OpenSubMenu("System: Fairchild Channel F")  
            OpenSubMenu("ChannelF: Mame/Mess")
                MenuItem(154, "Variant: Image Load")
            CloseSubMenu()        
        CloseSubMenu() 
        
        ;
        ; ============================================================= FM-Towns Marty          
        OpenSubMenu("System: FM-Towns Marty")  
            OpenSubMenu("ChannelF: Mame/Mess")
                MenuItem(155, "Variant: CD-Rom")
                MenuItem(156, "Variant: 1 Drive")      
                MenuItem(157, "Variant: 2 Drives") 
                MenuItem(158, "Variant: 2 Driveas & CD")                  
            CloseSubMenu()        
        CloseSubMenu()         
        
        ;
        ; ============================================================= GCE Vectrex         
        OpenSubMenu("System: GCE Vectrex")  
            OpenSubMenu("Vectrex: Mame/Mess")
                MenuItem(170, "Variant: Cart Load")
            CloseSubMenu()        
        CloseSubMenu()        
        
        ;
        ; ============================================================= Magnavox Odyssey 2         
         OpenSubMenu("System: Magnavox Odyssey 2")  
            OpenSubMenu("Odyssey 2: Mame/Mess")
                MenuItem(171, "Variant: Cart Load")
            CloseSubMenu()        
        CloseSubMenu()         
        
        ;
        ; ============================================================= MSX          
         OpenSubMenu("System: MSX")  
            OpenSubMenu("MSX 1: Mame/Mess")
                MenuItem(172, "Variant: Cart Load")
            CloseSubMenu() 
            OpenSubMenu("MSX 2: Mame/Mess")
                MenuItem(173, "Variant: Cart Load")
            CloseSubMenu()                 
        CloseSubMenu()  
            
        ;
        ; ============================================================= Microsoft
        OpenSubMenu("System: Microsoft")  
            OpenSubMenu("Xbox 1 (Classic): cXBX")
                MenuItem(255, "Variant: XBE Load")
            CloseSubMenu()         
            OpenSubMenu("Xbox 360: Xenia")
                MenuItem(254, "Variant: ISO Load")
            CloseSubMenu()   
            OpenSubMenu("Xbox 360: Xenia Canary")
                MenuItem(259, "Variant: ISO Load")
            CloseSubMenu()                  
        CloseSubMenu()              
        
        ;
        ; ============================================================= Nintendo           
        OpenSubMenu("System: Nintendo")
            OpenSubMenu("GB/GBC/GBA: Mame/Mess")
                MenuItem(221, "Variant: Rom Load (GB)")
                MenuItem(222, "Variant: Rom Load (Pocket)")    
                MenuItem(223, "Variant: Rom Load (GBC)")
                MenuItem(224, "Variant: Rom Load (GBA)")  
                MenuItem(225, "Variant: Rom Load (SGB)")    
                MenuItem(226, "Variant: Rom Load (SGB2)")                
            CloseSubMenu()          
            OpenSubMenu("GB/GBC/GBA: VisualAdvance-M")
                MenuItem(46, "Variant: Rom Load")
            CloseSubMenu()  
            OpenSubMenu("DS: DeSEmu")
                MenuItem(43, "Variant: Rom Load")
            CloseSubMenu() 
                 
            MenuBar() 
            
            OpenSubMenu("NES: FCeux")
                MenuItem(39, "Variant: Rom Load")
            CloseSubMenu()   
            OpenSubMenu("NES: Nestopia")
                MenuItem(40, "Variant: Rom Load")
            CloseSubMenu()
            OpenSubMenu("NES: puNES")
                MenuItem(41, "Variant: Rom Load")
            CloseSubMenu()               
            OpenSubMenu("NES: RockNES")
                MenuItem(38, "Variant: Rom Load")
            CloseSubMenu()
            OpenSubMenu("NES: Mame/Mess")
                MenuItem(214, "Variant: Rom Load (Ntsc)")
                MenuItem(215, "Variant: Rom Load (Pal)")            
            CloseSubMenu()                 
            MenuBar() 
            OpenSubMenu("SNES: Mame/Mess")
                MenuItem(216, "Variant: Rom Load (Ntsc)")
                MenuItem(217, "Variant: Rom Load (Pal)")            
            CloseSubMenu()  
            OpenSubMenu("SNES: bSnes")
                MenuItem(246, "Variant: Rom Load")                
            CloseSubMenu()   
            OpenSubMenu("SNES: Snes9x")
                MenuItem(247, "Variant: Rom Load")                
            CloseSubMenu()                 
            MenuBar()                               
            OpenSubMenu("N64: Mupen64Plus")
                MenuItem(5, "Variant: Rom Load")
            CloseSubMenu()
            OpenSubMenu("N64: Project64")
                MenuItem(42, "Variant: Rom Load")
            CloseSubMenu()
            OpenSubMenu("N64: Mame/Mess")
                MenuItem(218, "Variant: Rom Load")
                MenuItem(219, "Variant: Rom Load (DD)")            
            CloseSubMenu()                                
            MenuBar()                 
            OpenSubMenu("GC: Dolphin")
                MenuItem(44, "Variant: CD Load")
            CloseSubMenu()                
            MenuBar()                 
            OpenSubMenu("Wii: Dolphin")
                MenuItem(45, "Variant: CD Load")
            CloseSubMenu()
            OpenSubMenu("Wii-U: Cemu")
                MenuItem(257, "Variant: CD/File Load")
            CloseSubMenu()                 
            MenuBar()    
            OpenSubMenu("Virtual Boy: Mame/Mess")
                MenuItem(220, "Variant: Rom Load")
            CloseSubMenu()                    
        CloseSubMenu()               
        ;
        ; ============================================================= NEC                             
        OpenSubMenu("System: NEC")
            OpenSubMenu("PC9801: Dosbox-X")
                MenuItem(3, "Variant:: No Console & use Config")
            CloseSubMenu() 
            MenuBar()                 
            OpenSubMenu("PC9801: Anex86")
                MenuItem(6, "Variant: Image Load")
            CloseSubMenu()
            OpenSubMenu("PC9801: Neko Project II (286)")
                MenuItem(9, "Variant: Image Load")
            CloseSubMenu()             
            OpenSubMenu("PC9801: Neko Project II (386SX)")
                MenuItem(7, "Variant: Image Load")
            CloseSubMenu() 
            MenuBar()                 
            OpenSubMenu("PC9821: Neko Project II (IA-32)")
                MenuItem(8, "Variant: Image Load")
            CloseSubMenu()              
            OpenSubMenu("PC9821: Mame/Mess")
                MenuItem(159, "Variant: 2 Drives & CD")
            CloseSubMenu()             
            MenuBar()  
            OpenSubMenu("PC Engine: Ootake")
                MenuItem(58, "Variant: Rom/ CD Load")
            CloseSubMenu()         
            OpenSubMenu("PC Engine: Mame/Mess")
                MenuItem(160, "Variant: Cart Load")
                MenuItem(163, "Variant: Cart & CD")            
            CloseSubMenu()              
            OpenSubMenu("SuperGrafx: Mame/Mess")
                MenuItem(161, "Variant: Cart Load")
                MenuItem(164, "Variant: Cart & CD")             
            CloseSubMenu()                        
            OpenSubMenu("TurboGrafx 16: Mame/Mess")
                MenuItem(162, "Variant: Cart Load")
                MenuItem(165, "Variant: Cart & CD")             
            CloseSubMenu()                
         CloseSubMenu()            
        ;
        ; ============================================================= Panasonic 3DO         
        OpenSubMenu("System: Panasonic 3DO")
            OpenSubMenu("3DO: Mame/Mess")
                MenuItem(179, "Variant: CD Load (Pal)")
                MenuItem(180, "Variant: CD Load (Ntsc)")            
            CloseSubMenu()         
            OpenSubMenu("3DO: 4DO")
                MenuItem(63, "Variant: CD Load")
            CloseSubMenu()         
        CloseSubMenu()        
        ;
        ; ============================================================= Philips CD-i 
        OpenSubMenu("System: Pc DOS")           
            OpenSubMenu("MsDOS: Dosbox")
                MenuItem(1, "Variant: No Console & use Config")
            CloseSubMenu()
            OpenSubMenu("MsDOS: Dosbox-X")
                MenuItem(3, "Variant:: No Console & use Config")
            CloseSubMenu() 
            MenuBar()                 
            OpenSubMenu("DOS & WIN: ScummVM")
                MenuItem(2, "Variant: No Console & use Config")            
            CloseSubMenu()                                       
        CloseSubMenu()                 
        ;
        ; ============================================================= Philips CD-i           
         OpenSubMenu("System: Philips CD-i")  
            OpenSubMenu("CD-I: Mame/Mess")
                MenuItem(174, "Variant: CD Load (Mono-1/ PAL)")
                MenuItem(175, "Variant: CD Load (Mono-2/ PAL)")                
                MenuItem(176, "Variant: CD Load 490 (PAL)")                
                MenuItem(177, "Variant: CD Load 910 (PAL)")                
             CloseSubMenu()  
            OpenSubMenu("VideoPac+: Mame/Mess")
                MenuItem(178, "Variant: Cart Load")               
             CloseSubMenu()                                 
        CloseSubMenu()         
        ;
        ; ============================================================= Sega          
         OpenSubMenu("System: Sega")           
            OpenSubMenu("SG-1000: Mame/Mess")
                MenuItem(181, "Variant: Cart Load")
                MenuItem(182, "Variant: Cart Load (M3)")            
            CloseSubMenu()
            MenuBar()             
            OpenSubMenu("Pico: Mame/Mess")
                MenuItem(183, "Variant: Rom Load")
            CloseSubMenu()
            MenuBar()             
            OpenSubMenu("GameGear: Kega Fusion")
                MenuItem(51, "Variant: Rom Load")
            CloseSubMenu()            
            OpenSubMenu("GameGear: Mame/Mess")
                MenuItem(184, "Variant: Rom Load [JP]")
                MenuItem(185, "Variant: Rom Load [US/EU]")            
            CloseSubMenu()                
            MenuBar()                
            OpenSubMenu("Mega Drive: GensHD")
                MenuItem(52, "Variant: Rom Load")
            CloseSubMenu()             
            OpenSubMenu("Mega Drive: Kega Fusion")
                MenuItem(47, "Variant: Rom Load")
            CloseSubMenu()
            OpenSubMenu("Mega Drive: Mame/Mess")
                MenuItem(190, "Variant: Rom Load (US)")
                MenuItem(191, "Variant: Rom Load (US/ TMSS Chip)")            
                MenuItem(192, "Variant: Rom Load (EU)")
                MenuItem(193, "Variant: Rom Load (JP)")                
            CloseSubMenu()              
            MenuBar()                             
            OpenSubMenu("Master System: Kega Fusion")
                MenuItem(50, "Variant: Rom Load")
            CloseSubMenu()               
            OpenSubMenu("Master System: Mame/Mess")
                MenuItem(187, "Variant: Rom Load [MS 1]")               
                MenuItem(186, "Variant: Rom Load [MS 1, PAL]")         
                MenuItem(188, "Variant: Rom Load [MS 2]")
                MenuItem(189, "Variant: Rom Load [MS 2, PAL]")                 
            CloseSubMenu()                          
            MenuBar()                             
            OpenSubMenu("32X: GensHD")
                MenuItem(53, "Variant: Rom Load")
            CloseSubMenu()             
            OpenSubMenu("32X: Kega Fusion")
                MenuItem(48, "Variant: Rom Load")
            CloseSubMenu()
            OpenSubMenu("32X: Mame/Mess")
                MenuItem(200, "Variant: Rom Load (US)")
                MenuItem(201, "Variant: Rom Load (EU)")            
                MenuItem(202, "Variant: Rom Load (JP)")                 
                MenuBar() 
                MenuItem(203, "Variant: CD Load (US)")
                MenuItem(204, "Variant: CD Load (EU)")            
                MenuItem(205, "Variant: CD Load (JP)")                 
            CloseSubMenu()                 
            MenuBar()                       
            OpenSubMenu("MegaCD: GensHD")
                MenuItem(54, "Variant: CD Load")
            CloseSubMenu()              
            OpenSubMenu("MegaCD: Kega Fusion")
                MenuItem(49, "Variant: CD Load")
            CloseSubMenu()
            OpenSubMenu("MegaCD: Mame/Mess")
                MenuItem(194, "Variant: CD Load (US)")
                MenuItem(195, "Variant: CD Load (EU)")            
                MenuItem(196, "Variant: CD Load (JP)")                 
                MenuBar() 
                MenuItem(197, "Variant: CD Load (SCD-2 US)")
                MenuItem(198, "Variant: CD Load (MCD-2 EU)")            
                MenuItem(199, "Variant: CD Load (Aiwa-MCD JP)")                 
            CloseSubMenu()                 
            MenuBar()                   
            OpenSubMenu("Saturn: Yabuse")
               MenuItem(55, "Variant: CD Load")            
            CloseSubMenu()
            OpenSubMenu("Saturn: Kronos")
                MenuItem(258, "Variant: CD Load") 
            CloseSubMenu()            
            OpenSubMenu("Saturn: Mednafen")
                MenuItem(248, "Variant: CD Load (Port1: Gamepad)")
                MenuItem(249, "Variant: CD Load (Port1: 3D Pad)")
                MenuItem(250, "Variant: CD Load (Port1: Mouse)")
                MenuItem(251, "Variant: CD Load (Port1: Wheel)")
                MenuItem(252, "Variant: CD Load (Port1: Gun)")
            CloseSubMenu()                
            OpenSubMenu("Saturn: Mame/Mess")
                MenuItem(208, "Variant: CD Load (US)") 
                MenuItem(206, "Variant: CD Load (EU)")
                MenuItem(207, "Variant: CD Load (JP)")                 
            CloseSubMenu()                                                
            MenuBar()                 
            OpenSubMenu("Dreamcast: Demul")
                MenuItem(57, "Variant: CD Load")
            CloseSubMenu()             
            OpenSubMenu("Dreamcast: nullDC")
                MenuItem(56, "Variant: CD Load")
            CloseSubMenu()   
            OpenSubMenu("Dreamcast: ReDream")
                MenuItem(256, "Variant: CD Load")
            CloseSubMenu()                  
            OpenSubMenu("Dreamcast: Mame/Mess")
                MenuItem(211, "Variant: CD Load (US)")             
                MenuItem(209, "Variant: CD Load (EU)")              
                MenuItem(210, "Variant: CD Load (JP)")               
            CloseSubMenu()                  
        CloseSubMenu()
        ;
        ; ============================================================= Sharp X68000           
        OpenSubMenu("System: Sharp X68000")  
            OpenSubMenu("X68000: Mame/Mess")
                MenuItem(212, "Variant: Floppy Load")
            CloseSubMenu()        
        CloseSubMenu()          
        ;
        ; ============================================================= Sinclair ZX Spectrum          
        OpenSubMenu("System: Sinclair ZX Spectrum")  
            OpenSubMenu("Speccy: Mame/Mess")
                MenuItem(213, "Variant: Floppy Load")
            CloseSubMenu()        
        CloseSubMenu()             
        ;        
        ; ============================================================= Sony         
        OpenSubMenu("System: Sony")
            OpenSubMenu("PS1: Mednafen")
                MenuItem(253, "Variant: CD Load")
            CloseSubMenu()
            OpenSubMenu("PS1: ePSXe")
                MenuItem(59, "Variant: CD Load")
            CloseSubMenu()  
            OpenSubMenu("PS1: Duckstation")
                MenuItem(260, "Variant: CD Load")
            CloseSubMenu()                 
            MenuBar()                  
            OpenSubMenu("PS2: PcSX2")
                MenuItem(60, "Variant: CD Load")
            CloseSubMenu()             
            MenuBar()                  
            OpenSubMenu("PS3: rPcS3")
                MenuItem(61, "Variant: CD Load")
            CloseSubMenu()  
            MenuBar()                  
            OpenSubMenu("PSP: PpSsPp")
                MenuItem(62, "Variant: CD Load")
            CloseSubMenu()             
         CloseSubMenu()  
        ;
        ; ============================================================= SNK NeoGeo            
        OpenSubMenu("System: SNK NeoGeo")           
            OpenSubMenu("NeoGeo/CD: Mame/Mess")
                MenuItem(166, "Variant: CD Load")
                MenuItem(167, "Variant: CD Load [CDz]")            
            CloseSubMenu()          
            OpenSubMenu("NeoGeo/CD: NeoRaine32")
                MenuItem(66, "Variant: CD Load")
            CloseSubMenu()  
            MenuBar()                
            OpenSubMenu("NeoGeo Pocket: Mame/Mess")
                MenuItem(168, "Variant: Rom Load (Mono)")
                MenuItem(169, "Variant: Rom Load (Color)")            
            CloseSubMenu()                           
        CloseSubMenu()           
        ;
        ; ============================================================= Super Casette Vision 
        OpenSubMenu("System: Super Casette Vision")  
            OpenSubMenu("Epoch: Mame/Mess")
                MenuItem(153, "Variant: Image Load")
            CloseSubMenu()        
        CloseSubMenu() 
        ;
        ; ============================================================= Bandai Wonderswan             
         OpenSubMenu("System: Wonderswan") 
            OpenSubMenu("Oswan (v1.7+)")
                MenuItem(68, "Variant: Rom Load")
            CloseSubMenu() 
            OpenSubMenu("OswanHack")
                MenuItem(69, "Variant: Rom Load")
            CloseSubMenu()  
            OpenSubMenu("Mame/Mess")
                MenuItem(227, "Variant: Rom Load (Mono)")
                MenuItem(228, "Variant: Rom Load (Color)")            
            CloseSubMenu()                 
        CloseSubMenu()             
        ;
        ; ============================================================= TRS-80
        OpenSubMenu("System: TRS-80")  
            OpenSubMenu("TRS-80: Mame/Mess")
                MenuItem(229, "Variant: Floppy Load")
            CloseSubMenu()        
        CloseSubMenu()
        ;
        ; ============================================================= VTech CreatVision
        OpenSubMenu("System: VTech CreatVision")  
            OpenSubMenu("TRS-80: Mame/Mess")
                MenuItem(230, "Variant: Cart Load")
            CloseSubMenu()        
        CloseSubMenu()             
    EndProcedure    

    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts (C64 Datei Manager)
    ;
    ;
    ;*******************************************************************************************************************************************************************     
    Procedure Get_C64Menu(MenuID.i, GadgetID.i)
                        
        Select MenuID.i
            Case 1:  INVMNU::*LHMNU64\TRMODE = 0
            Case 2:  INVMNU::*LHMNU64\TRMODE = 1
            Case 3:  INVMNU::*LHMNU64\TRMODE = 2
            Case 4:  INVMNU::*LHMNU64\TRMODE = 3
            Case 5:  INVMNU::*LHMNU64\TRMODE = 4                  
            Case 6:  INVMNU::*LHMNU64\USWARP = MNU_SetGet(INVMNU::*LHMNU64\USWARP) 
            Case 7:  INVMNU::*LHMNU64\FORM40 = MNU_SetGet(INVMNU::*LHMNU64\FORM40) 
            Case 8:  INVMNU::*LHMNU64\FORMAT = 0
            Case 9:  INVMNU::*LHMNU64\FORMAT = 1
            Case 10: INVMNU::*LHMNU64\FORMAT = 2 
            Case 11: INVMNU::*LHMNU64\NIMAGE = 0                  
            Case 12: INVMNU::*LHMNU64\NIMAGE = 1  
            Case 13: INVMNU::*LHMNU64\NIMAGE = 2  
            Case 14: INVMNU::*LHMNU64\NIMAGE = 3  
            Case 15: INVMNU::*LHMNU64\NIMAGE = 4  
            Case 16: INVMNU::*LHMNU64\NIMAGE = 5  
            Case 17: INVMNU::*LHMNU64\NIMAGE = 6  
            Case 18: INVMNU::*LHMNU64\NIMAGE = 7                  
            Case 19: INVMNU::*LHMNU64\NIMAGE = 8                   
            Case 20: INVMNU::*LHMNU64\READDL = MNU_SetGet(INVMNU::*LHMNU64\READDL)
            Case 21: INVMNU::*LHMNU64\READIN = 1
            Case 22: INVMNU::*LHMNU64\READIN = 2
            Case 23: INVMNU::*LHMNU64\READIN = 3
            Case 24: INVMNU::*LHMNU64\READIN = 4
            Case 25: INVMNU::*LHMNU64\READIN = 5
            Case 26: INVMNU::*LHMNU64\READIN = 6
            Case 27: INVMNU::*LHMNU64\READIN = 7
            Case 28: INVMNU::*LHMNU64\READIN = 8
            Case 29: INVMNU::*LHMNU64\READIN = 9
            Case 30: INVMNU::*LHMNU64\READIN = 10
            Case 31: INVMNU::*LHMNU64\READIN = 11  
            Case 32: INVMNU::*LHMNU64\READIN = 12 
            Case 33: INVMNU::*LHMNU64\READIN = 13 
            Case 34: INVMNU::*LHMNU64\READIN = 14 
            Case 35: INVMNU::*LHMNU64\READIN = 15 
            Case 37:
                
                Request::*MsgEx\User_BtnTextL = "Ok"
                Request::*MsgEx\User_BtnTextR = "Cancel"        
                Request::*MsgEx\Return_String = Str(INVMNU::*LHMNU64\RETRYC)              
                
                r = Request::MSG(Startup::*LHGameDB\TitleVersion, "D64Copy Transfer Option","Enter the amount Retry Count (Current: "+INVMNU::*LHMNU64\RETRYC+") ",10,1,"",0,1,DC::#_Window_005)
                SetActiveGadget(DC::#ListIcon_003): 
                If (r = 0)
                    RetryCNT.i = Val( Request::*MsgEx\Return_String )
                    INVMNU::*LHMNU64\RETRYC = RetryCNT    
                EndIf
                If (r = 1)
                    ProcedureReturn -1
                EndIf                    
                
            Case 38: INVMNU::*LHMNU64\BAMOCP = MNU_SetGet(INVMNU::*LHMNU64\BAMOCP)                
            Default
                
                Debug MenuID 
        EndSelect
    ;*******************************************************************************************************************************************************************         
    EndProcedure    
    Procedure Set_C64Menu_SetCheckmarks(MenuID_Min.i, MenuID_Max.i, MenuID.l, MenuID_Aktiv)
        
        Protected CurrentID.i
        
        For CurrentID = MenuID_Min To MenuID_Max
            
            If MenuID_Aktiv = CurrentID
                SetMenuItemState(MenuID, CurrentID, 1)
                ProcedureReturn
            EndIf  
            
            SetMenuItemState(MenuID, CurrentID, 0)
        Next                  
        
    EndProcedure    
    
    Procedure Set_C64Menu(MenuID)        
        MenuItem(1, "Transfer: Auto")
        MenuItem(2, "Transfer: Original")        
        MenuItem(3, "Transfer: Serial 1")
        MenuItem(4, "Transfer: Serial 2")
        MenuItem(5, "Transfer: Parallel")        
        MenuBar()
        MenuItem(6, "Transfer: Use Warp")
        MenuBar()
        MenuItem(7, "Format: 40 Tracks")
        MenuItem(8, "Format: CBMFormat")
        MenuItem(9, "Format: CBMFormNG") 
        MenuItem(10,"Format: CBMCTRL")
        MenuBar()    
        OpenSubMenu("New Image Format")        
            MenuItem(11,"D64 (VC1541/2031)")
            MenuItem(14,"D71 (VC1571)")          
            MenuItem(17,"D81 (VC1581)") 
            MenuItem(19,"T64 (VC1530)")             
            MenuBar()
            MenuItem(12,"G64 (VC1541/2031)")
            MenuItem(13,"X64 (VC1541/2031)")               
            MenuItem(15,"G71 (VC1571)")
            MenuItem(16,"D80 (CBM8050)")        
            MenuItem(18,"D82 (CBM8250/1001")
       CloseSubMenu()
       MenuBar()            
       OpenSubMenu("Transfer: Options")  
       MenuItem(20,"Read First Directory")  
       MenuItem(38,"BAM Only Copy")         
       MenuItem(37,"Retry Count (Now: "+Str(INVMNU::*LHMNU64\RETRYC)+")")         
       MenuBar()  
       MenuItem(21,"Interleave Read: 01")     
       MenuItem(22,"Interleave Read: 02")
       MenuItem(23,"Interleave Read: 03")
       MenuItem(24,"Interleave Read: 04 (Serial 1)")
       MenuItem(25,"Interleave Read: 05")
       MenuItem(26,"Interleave Read: 06")
       MenuItem(27,"Interleave Read: 07 (Parallel)")
       MenuItem(28,"Interleave Read: 08")
       MenuItem(29,"Interleave Read: 09")
       MenuItem(30,"Interleave Read: 10")
       MenuItem(31,"Interleave Read: 11")
       MenuItem(32,"Interleave Read: 12")
       MenuItem(33,"Interleave Read: 13 (Serial 2)")
       MenuItem(34,"Interleave Read: 14")
       MenuItem(35,"Interleave Read: 15")
       MenuItem(36,"Interleave Read: 16 (Original)")
       CloseSubMenu()
;        
;        
;          -i, --interleave=VALUE    set interleave value; ignored wh
;                             warp mode; default values are:
; 
;                               original     16
; 
;                                         turbo r/w   warp wri
;                               serial1       4            6
;                               serial2      13           12
;                               parallel      7            4
                              
        ;
        ; Checkmark Transfermode 
        Select INVMNU::*LHMNU64\NIMAGE
            Case 0:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 11)                
            Case 1:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 12)                   
            Case 2:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 13)                    
            Case 3:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 14)      
            Case 4:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 15)
            Case 5:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 16)
            Case 6:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 17)                
            Case 7:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 18) 
            Case 8:
                Set_C64Menu_SetCheckmarks(11, 19, MenuID, 19)                   
        EndSelect 
                    
                
        ;
        ; Checkmark Transfermode 
        Select INVMNU::*LHMNU64\TRMODE
            Case 0:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 1)                
            Case 1:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 2)                
            Case 2:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 3)                
            Case 3:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 4) 
            Case 4:
                Set_C64Menu_SetCheckmarks(1, 5, MenuID, 5)               
        EndSelect                
        
        MNU_SetCheckmark(MenuID, 6, INVMNU::*LHMNU64\USWARP)
        MNU_SetCheckmark(MenuID, 7, INVMNU::*LHMNU64\FORM40) 
        
        ;
        ; Checkmark Format Programm
        Select INVMNU::*LHMNU64\FORMAT
           Case 0:
                SetMenuItemState(MenuID, 8, 1)
                SetMenuItemState(MenuID, 9, 0)
                SetMenuItemState(MenuID, 10,0)                 
            Case 1:
                SetMenuItemState(MenuID, 8, 0)
                SetMenuItemState(MenuID, 9, 1)
                SetMenuItemState(MenuID, 10,0)  
            Case 2:
                SetMenuItemState(MenuID, 8, 0)
                SetMenuItemState(MenuID, 9, 1)
                SetMenuItemState(MenuID, 10,0)                 
        EndSelect                     
        
        SetMenuItemState(MenuID, 20, INVMNU::*LHMNU64\READDL)
        
        Select INVMNU::*LHMNU64\READIN
            Case 1
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 21)  
            Case 2
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 22)                  
            Case 3
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 23)                  
            Case 4
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 24)                  
            Case 5
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 25)                  
            Case 6
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 26)                  
            Case 7
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 27)  
            Case 8
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 28)                  
            Case 9
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 29)                  
            Case 10
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 30)                  
            Case 11
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 31)                  
            Case 12
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 32)                  
            Case 13
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 33)                  
            Case 14
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 34)                  
            Case 15
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 35)                  
            Case 16
                Set_C64Menu_SetCheckmarks(21, 36, MenuID, 36)
        EndSelect
        
        SetMenuItemState(MenuID, 38, INVMNU::*LHMNU64\BAMOCP)        
    EndProcedure  
    
    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts (Thumbnails)
    ;
    ;
    ;*******************************************************************************************************************************************************************     
    Procedure Get_ShotsMenu(MenuID.i, GadgetID.i)
        
        Select MenuID.i
            Case 1: vImages::Screens_Menu_Import(GadgetID.i)
            Case 2: vImages::Screens_Menu_Save_Image(GadgetID.i)
            Case 3: vImages::Screens_Menu_Save_Images_All()
            Case 4: vImages::Screens_Menu_Delete_Single(GadgetID.i)
            Case 5: vImages::Screens_Menu_Delete_All()
            Case 8: vImages::Screens_SzeThumbnails_Reset()
                    vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*1, #True)
            Case 9: VEngine::Splitter_SetAll()
            Case 10: vEngine::Thumbnails_SetAll()
            Case 11: vEngine::Thumbnails_Set(1)
            Case 12: vEngine::Thumbnails_Set(2)   
            Case 13: vEngine::Thumbnails_Set(3)   
            Case 14: vEngine::Thumbnails_Set(4)                    
            Case 15: vEngine::Thumbnails_Set(5)                    
            Case 16: vEngine::Thumbnails_Set(6)                    
           ; Case 17: vEngine::Thumbnails_Set(7)
            Case 18: vImages::Screens_Menu_Copy_Image(GadgetID.i)
            Case 19: vImages::Screens_Menu_Paste_Import(GadgetID.i)                
            Case 20: vEngine::Splitter_SetHeight(0)
            Case 21: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*1, #True)
            Case 22: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*2, #True)                
            Case 23: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*3, #True)                
            Case 24: vEngine::Splitter_SetHeight(Startup::*LHGameDB\hScreenShotGadget*4, #True)                
            Default
                Debug MenuID 
        EndSelect                
        
   
    ;*******************************************************************************************************************************************************************         
    EndProcedure    
    Procedure Set_ShotsMenu()
    	
    	Protected ImageInfo.s = vImages::Screens_Menu_Info_Image()
    	
        MenuItem(1 , "Bild Laden...")           :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 0, #MF_BYPOSITION, ImageID( DI::#_MNU_LOD ),0)       
        MenuBar()        
        MenuItem(2 , "Dieses Bild Speichern")   :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 2, #MF_BYPOSITION, ImageID( DI::#_MNU_SVE ),0)
        MenuItem(3 , "Alle Bilder Speichern")   :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 3, #MF_BYPOSITION, ImageID( DI::#_MNU_SVE ),0)
        MenuBar()
        MenuItem(18 , "Bild Kopieren")          :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 5, #MF_BYPOSITION, ImageID( DI::#_MNU_COP ),0)
        MenuItem(19 , "Bild Einfügen")          :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 6, #MF_BYPOSITION, ImageID( DI::#_MNU_PAS ),0)          
        MenuBar()
        MenuItem(4 , "Dieses Bild Löschen")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 8, #MF_BYPOSITION, ImageID( DI::#_MNU_DPC ),0) 
        MenuItem(5,  "Alle Bilder Löschen")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 9, #MF_BYPOSITION, ImageID( DI::#_MNU_DPC ),0)
        MenuBar()
        MenuItem(20, "Splitter Höhe Einstellen"):SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 11, #MF_BYPOSITION, ImageID( DI::#_MNU_SPL ),0)
        MenuItem(9,  "...Gleiche Höhe für alle"):SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ), 12, #MF_BYPOSITION, ImageID( DI::#_MNU_SPL ),0)          
        MenuBar()
        MenuItem(8 , "Thumbnail zurücksetzen")  :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),14, #MF_BYPOSITION, ImageID( DI::#_MNU_WMT ),0)    
        MenuItem(10, "...Gleiche Höhe für alle"):SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),15, #MF_BYPOSITION, ImageID( DI::#_MNU_WMT ),0)
        MenuBar()
        MenuItem(11, "1x1 Thumbnail Größe")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),17, #MF_BYPOSITION, ImageID( DI::#_MNU_TB1 ),0)
        MenuItem(12, "2x1 Thumbnail Größe")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),18, #MF_BYPOSITION, ImageID( DI::#_MNU_TB2 ),0)
        MenuItem(13, "3x1 Thumbnail Größe (*)") :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),19, #MF_BYPOSITION, ImageID( DI::#_MNU_TB3 ),0)                       
        MenuItem(14, "4x1 Thumbnail Größe")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),20, #MF_BYPOSITION, ImageID( DI::#_MNU_TB4 ),0)
        MenuItem(15, "5x1 Thumbnail Größe")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),21, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0)                         
        MenuItem(16, "6x1 Thumbnail Größe")     :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),22, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0)
        MenuBar()
        OpenSubMenu( "Thumbnail Höhen Option .." )        :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),24, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0)
             MenuItem(21 , "1 Thumbnail Pro Reihe")
             MenuItem(22 , "2 Thumbnail Pro Reihe")
             MenuItem(23 , "3 Thumbnail Pro Reihe")             
             MenuItem(24 , "4 Thumbnail Pro Reihe")             
             CloseSubMenu()
        If Len(ImageInfo) > 0
        	MenuBar()
        	MenuItem(25 , "Information..")
        	MenuItem(26 , ImageInfo)               
        EndIf	
        ;MenuItem(17, "7 Thumbnails Pro Reihe")   :SetMenuItemBitmaps_( MenuID( CLSMNU::*MNU\HandleID[0] ),22, #MF_BYPOSITION, ImageID( DI::#_MNU_TB5 ),0) 
        
        If Not IsImage( GetClipboardImage(#PB_Any) )
            DisableMenuItem(CLSMNU::*MNU\HandleID[0], 19, 1)
        EndIf 
                     
    EndProcedure   
    
    Procedure Get_PopMenu1(MenuID.i, GadgetID.i)
    EndProcedure
    ;*******************************************************************************************************************************************************************          
    Procedure Set_PopMenu1() 
    EndProcedure      
    ;*******************************************************************************************************************************************************************
    ;
    ; Individuelle Layouts
    ;
    ;
    ;*******************************************************************************************************************************************************************    
    Procedure Get_TrayMenu(MenuID.i)
    	Select MenuID.i              
    		Case 5:  vDiskPath::ReConstrukt(1, #False) ; Search for All on Slot 1
    		Case 6:  vDiskPath::ReConstrukt(2, #False) ; Search for All on Slot 2                 
    		Case 8:  vDiskPath::ReConstrukt(3, #False) ; Search for All on Slot 3
    		Case 11: vDiskPath::ReConstrukt(4, #False) ; Search for All on Slot 4 
    		Case 12: vDiskPath::ReConstrukt(1, #True ) ; Search for Current Item on Slot 1
    		Case 13: vDiskPath::ReConstrukt(2, #True ) ; Search for Current Item on Slot 2                 
    		Case 14: vDiskPath::ReConstrukt(3, #True ) ; Search for Current Item on Slot 3
    		Case 15: vDiskPath::ReConstrukt(4, #True ) ; Search for Current Item on Slot 4   
    		Case 16: vInfoMenu::Cmd_DockSettings(0): vInfoMenu::Cmd_ResetWindow() 
    		Case 17: VEngine::Database_Remove(1,#True)  
    		Case 30: DesktopEX::CloseExplorer() 
    		Case 32: DesktopEX::SetTaskBar()
    		Case 35: vEngine::ServiceOption("uxsms", #False)                 
    		Case 34: vEngine::ServiceOption("uxsms", #True) 
    		Case 40: vEngine::MAME_Driver_Import()             	        
    		Case 41: vEngine::MAME_Roms_Check_Import()
    		Case 42: vEngine::MAME_Roms_Check()            	
    		Case 43: vEngine::MAME_Roms_Backup() 
    		Case 44: vEngine::MAME_Roms_GetInfos() 
    			
    			; Resetet die Fenster Position
    		Case 20
    			ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WPosX", Str(0),1)    
    			ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WPosY", Str(0),1)                
    			Startup::*LHGameDB\WindowPosition\X = 0
    			Startup::*LHGameDB\WindowPosition\Y = 0         
    			WinGuru::WindowPosition(DC::#_Window_001,Startup::*LHGameDB\WindowPosition\X,Startup::*LHGameDB\WindowPosition\Y)
    			
    		Case 1
    			Startup::*LHGameDB\SortMode = 0
    			Startup::*LHGameDB\SortXtendMode = #False
    			VEngine::Thread_LoadGameList_Sort()
    			
    		Case 2
    			Startup::*LHGameDB\SortMode = 1
    			Startup::*LHGameDB\SortXtendMode = #False
    			VEngine::Thread_LoadGameList_Sort()
    			
    		Case 3
    			Startup::*LHGameDB\SortMode = 2
    			Startup::*LHGameDB\SortXtendMode = #False
    			VEngine::Thread_LoadGameList_Sort()
    			
    		Case 4  			    				    			
    			VEngine::Thread_LoadGameList_Sort()     				
    					
    		Case 45
    			bReloadSort.i = #False
    			
    			If ( Startup::*LHGameDB\SortMode  >= 5 )
    				bReloadSort.i = #True
    			EndIf
    			
    			Startup::*LHGameDB\SortMode = 3
    			Startup::*LHGameDB\SortXtendMode = #False
    			
    			If ( bReloadSort = #True )
    				VEngine::Thread_LoadGameList_Action() 			
    			EndIf          	
    			
    		Case 46    			
    			bReloadSort.i = #False
    			
    			If ( Startup::*LHGameDB\SortMode  <= 4 )
    				bReloadSort.i = #True
    			EndIf
    			
    			Startup::*LHGameDB\SortMode = 5
    			Startup::*LHGameDB\SortXtendMode = #True
    			
    			If ( bReloadSort = #True )
    				VEngine::Thread_LoadGameList_Action() 			
    			EndIf	
    			
    		Case 7                               
    			r = vItemTool::DialogRequest_Add("Fenster Grösse (Höhe) Einstellen","Einstellung von 0 (Standard) bis unendlich. (Keine Minus Angabe)",Str(Startup::*LHGameDB\WindowHeight))              
    			If ( r = 1 )                   
    				SetActiveGadget(DC::#ListIcon_001)                
    				ProcedureReturn
    			EndIf
    			Startup::*LHGameDB\bvSystem_Restart = #True
    			
    			vEngine::Splitter_SetHeight(0, #False, #True, Val(Request::*MsgEx\Return_String))
    			VEngine::Splitter_SetAll()
    			; vEngine::Splitter_SetHeight(SetHeight.i = 289, ThumbnailMode = #False, NewWindowHeight = #False, SetWindowHeight = 0)
					; wHeight.i = Startup::*LHGameDB\WindowHeight     ; Fenster Höhe
					; sHeight.i = GetGadgetState(DC::#Splitter1)      ; Splitter Höhe   
    			
    			; If ( nHeight = 0)                          
					;     sHeight = 289
					; ElseIf ( nHeight > WHeight)  
					;     sHeight = Abs((wHeight+nHeight) +  sHeight)
					; ElseIf  ( nHeight < WHeight)
					;     sHeight = Abs((wHeight-nHeight) -  sHeight)
					; EndIf   
    			
    			;Debug "Fenster Höhe ändern: "
					;Debug "Manuelle Eingabe: " + Str(Val(Request::*MsgEx\Return_String) )
					;Debug "Fensterhöhe     : " + Str(wHeight)
					;Debug "Splitterhöhe    : " + Str(GetGadgetState(DC::#Splitter1) )
					;Debug "................: "
					;Debug "Neue Fensterhöhe: " + Str(wHeight)
					;Debug "Neue Splitterhöhe: " + Str(sHeight)
					;Debug "................: "               
    			
    			Startup::*LHGameDB\WindowHeight     = Val(Request::*MsgEx\Return_String)
    			
    			
    			ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WindowHeight", Str(Startup::*LHGameDB\WindowHeight),1)
    			; Splitter Höhe
					;ExecSQL::UpdateRow(DC::#Database_001,"Gamebase", "SplitHeight", Str(sHeight),Startup::*LHGameDB\GameID)
					;ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight", Str(sHeight),1)                                
    			
    			
    			
    			a.l = CreateFile(#PB_Any, Startup::*LHGameDB\SubF_vSys+"\_Restart.lck" )
    			Delay( 5 )
    			If ( a > 0 )
    				WriteStringN(a, "Restart..")
    				RunProgram(ProgramFilename())               
    				End
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Problem", "Problem beim Anlegen der Textdatei",11,-1,ProgramFilename(),0,0,DC::#_Window_001 )
    			EndIf    
    			
    		Case 9 : vFont::SetDB(1) 
    		Case 10: vFont::SetDB(2)                 
    		Case 98: vUpdate::Update_Check()
    			
    		Case 18:
    			File.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" + "stdout.txt"
    			If FileSize(File) <> -1
    				FFH::ShellExec(File, "open")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Die Datei konnte nicht geöffnet werden", File.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf    
    			
    		Case 19: 
    			File.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\" + "error.txt"
    			If FileSize(File) <> -1
    				FFH::ShellExec(File, "open")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Die Datei konnte nicht geöffnet werden", File.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf 
    			
    		Case 21:
    			Path.s = Startup::*LHGameDB\Base_Path + "Systeme\SHOT\"
    			If FileSize(Path) = -2
    				FFH::ShellExec(Path, "explore")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Das Verzeichnis Existiert nicht.", Path.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf
    			
    		Case 22:
    			Path.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\"
    			If FileSize(Path) = -2
    				FFH::ShellExec(Path, "explore")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Das Verzeichnis Existiert nicht.", Path.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf                 
    			
    		Case 200 To 300
    			FFH::ShellExec(GetMenuItemText(CLSMNU::*MNU\HandleID[0], MenuID), "open")
    			
    		Case 23
    			ShotPath.s = Startup::*LHGameDB\Base_Path + "Systeme\SHOT\"                
    			ShotSize.i = 0
    			
    			ShotSize = vItemTool::File_GetFiles(ShotPath)
    			If  (ShotSize > 0 )
    				
    				Result = Request::MSG(Startup::*LHGameDB\TitleVersion, "Löschen?","Alle Snapshot Dateie(n) löschen? ("+Str(ShotSize)+") " + #CR$ + "Pfad: " + ShotPath,11,2,"",0,0,DC::#_Window_001)
    				If (Result = 0)                
    					While NextElement(FFS::FullFileSource())
    						Delay( 5 )
    						DeleteFile( FFS::FullFileSource()\FileName )
    					Wend
    				EndIf    
    				ClearList( FFS::FullFileSource() )
    				
    				Delay( 5 )
    				ShotSize = vItemTool::File_GetFiles(ShotPath)
    				If ( ShotSize > 0 )
    					Request::MSG(Startup::*LHGameDB\TitleVersion, "Fehler", "Konnte alle Snapshot Dateie(n) nicht löschen" ,2,1,"",0,0,DC::#_Window_001 )
    				Else
    					Request::MSG(Startup::*LHGameDB\TitleVersion, "Erfolgreich", "Alle Snapshot(s) (ShotSize) wurden gelöscht" ,2,1,"",0,0,DC::#_Window_001 )                    
    				EndIf
    			EndIf                    
    			
    		Case 24
    			If ( Startup::*LHGameDB\FileMonitoring = #False )
    				Monitoring::Activate("C:\")
    			Else
    				Monitoring::DeActivate()
    			EndIf
    			
    		Case 25
    			File.s = Startup::*LHGameDB\Monitoring\LatestLog
    			If FileSize(File) <> -1
    				FFH::ShellExec(File, "open")
    			Else
    				Request::MSG(Startup::*LHGameDB\TitleVersion, "Die Datei konnte nicht geöffnet werden", File.s ,2,1,"",0,0,DC::#_Window_001 )
    			EndIf 
    			
    		Case 99: Startup::*LHGameDB\ProgrammQuit = Request_MSG_Quit()
    			
    	EndSelect       
    EndProcedure
    ;*******************************************************************************************************************************************************************    
    Procedure Set_TrayMenu_LoggUtil()    
        Protected LognPath.s = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\"
        
        MenuItem(22, "Log Verzeichnis Öffnen"                   ,ImageID( DI::#_MNU_EX1 )) 
        
        If ( FileSize(LognPath) <> -2 )      
            DisableMenuItem( CLSMNU::*MNU\HandleID[0], 22, 1)
        Else
            MenuItem(18, "Log Datei Öffnen: stdout"                 ,ImageID( DI::#_MNU_CLR ))
            MenuItem(19, "Log Datei Öffnen: error"                  ,ImageID( DI::#_MNU_CLR ))
        EndIf    
        
    EndProcedure

    ;*******************************************************************************************************************************************************************    
    Procedure Set_TrayMenu_ShotUtil()
    	
        Protected ShotPath.s = Startup::*LHGameDB\Base_Shot
        Protected ShotSize.i = 0
               
        If ( FileSize(ShotPath) <> -2 )
            MenuItem(21, "Capture Verzeichnis Öffnen"              ,ImageID( DI::#_MNU_EX1 ))            
            DisableMenuItem( CLSMNU::*MNU\HandleID[0], 21, 1)            
        Else                        
            ShotSize = vItemTool::File_GetFiles(ShotPath)  
            
            MenuItem(21, "Capture Verzeichnis Öffnen (" + Str(ShotSize) + ")",ImageID( DI::#_MNU_EX1 ))                
                       
            If ( ShotSize > 0 )
                OpenSubMenu("Capture Dateien ...")
                While NextElement(FFS::FullFileSource())
                    
                    MenuItem(200, FFS::FullFileSource()\FileName) 
                    
                    Debug "FullPath : " +FFS::FullFileSource()\FileName
                Wend
                CloseSubMenu()    
                ClearList( FFS::FullFileSource() )                
                MenuItem(23, "Capture Dateien Löschen"              ) 
            EndIf
        EndIf    
    EndProcedure  
    ;*******************************************************************************************************************************************************************    
    Procedure Set_TrayMenu_Monitor()        
                
        If ( Startup::*LHGameDB\FileMonitoring = #False )
            MenuItem(24, "Start: Disk Monitoring"   ,ImageID( DI::#_MNU_MON ))            
            SetMenuItemState(CLSMNU::*MNU\HandleID[0], 24, 0) 
        Else
            MenuItem(24, "Stop: Disk Monitoring"   ,ImageID( DI::#_MNU_MON ))             
            SetMenuItemState(CLSMNU::*MNU\HandleID[0], 24, 1) 
        EndIf          
        
        If ( FileSize(Startup::*LHGameDB\Monitoring\LatestLog) <> -1 ) And (Startup::*LHGameDB\Monitoring\LogHandle = 0)
            MenuItem(25, "Open Monitoring Log File"  ,ImageID( DI::#_MNU_MON ))            
        EndIf    
        
    EndProcedure  
    
    ;*******************************************************************************************************************************************************************    
    Procedure Set_Mame_Menu()        
    	
            MenuItem(41 , "Tool : Sets/Roms Einsortieren" 			,ImageID( DI::#_MNU_MAM ))
            MenuItem(42 , "Tool : Sets/Roms Überprüfen" 	      	,ImageID( DI::#_MNU_MAM ))
            MenuBar()             
            MenuItem(44 , "Tool : Informationen hinzufügen" 	  	,ImageID( DI::#_MNU_MAM ))             
            MenuBar()   
            MenuItem(43 , "Tool : Backup aus dem Internet" 	      	,ImageID( DI::#_MNU_MAM ))
     
            
            If ( CountGadgetItems(DC::#ListIcon_001) > 0 )
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 41, 0)
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 42, 0) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 43, 0) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 44, 0)             	
            Else
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 41, 1) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 42, 1) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 43, 1) 
            	DisableMenuItem(CLSMNU::*MNU\HandleID[0], 44, 1)             	
            EndIf
            
          EndProcedure 
          
    ;*******************************************************************************************************************************************************************    
     Procedure Set_SortBUtton()
     	
     	Protected ButtonText.s = ButtonEx::Gettext(DC::#Button_028, 0)  
    		MenuItem(4 , "Sortieren: "+ButtonText+"  " +Chr(9)+"F4" ,ImageID( DI::#_MNU_VSY ))
    		MenuBar()             
    		MenuItem(45, "Anzeigen : Programm"					       ,ImageID( DI::#_MNU_VSY ))  
    		MenuItem(46, "Anzeigen : Release"						       ,ImageID( DI::#_MNU_VSY ))
    		
    EndProcedure      	
    ;*******************************************************************************************************************************************************************     
    Procedure Set_TrayMenu()
    	
    	If IsWindow(DC::#_Window_001)                            
    		MenuItem(1 , "Sortieren: Gametitle " +Chr(9)+"F1"       ,ImageID( DI::#_MNU_VSY ))
    		MenuItem(2 , "Sortieren: Platform  " +Chr(9)+"F2"       ,ImageID( DI::#_MNU_VSY ))      
    		MenuItem(3 , "Sortieren: Language  " +Chr(9)+"F3"       ,ImageID( DI::#_MNU_VSY ))
				Set_SortBUtton()         
    		MenuBar()            
    		MenuItem(40 , "Import. Titel in die Datenbank"	     	,ImageID( DI::#_MNU_MAM ))
    		OpenSubMenu( "Mame Tools .."                            ,ImageID( DI::#_MNU_MAM ))               
    		Set_Mame_Menu() 
    		CloseSubMenu()             
    		MenuBar()                     
    		MenuItem(17, "Lösche Einträge = 1"                      ,ImageID( DI::#_MNU_SPL ))            
    		MenuBar()  
    		Set_TrayMenu_LoggUtil()   
    		MenuBar()              
    		Set_TrayMenu_ShotUtil()
    		MenuBar()
    		Set_TrayMenu_Monitor()
    		MenuBar()              
    		OpenSubMenu( "Pfade .."                                 ,ImageID( DI::#_MNU_DIR ))                       
    		MenuItem(5 , "Alle Prüfen & Reparieren (Slot 1)"        ,ImageID( DI::#_MNU_RAL )) 
    		MenuItem(6 , "Alle Prüfen & Reparieren (Slot 2)"        ,ImageID( DI::#_MNU_RAL ))                       
    		MenuItem(8 , "Alle Prüfen & Reparieren (Slot 3)"        ,ImageID( DI::#_MNU_RAL ))                       
    		MenuItem(11, "Alle Prüfen & Reparieren (Slot 4)"        ,ImageID( DI::#_MNU_RAL ))
    		MenuBar() 
    		MenuItem(12, "Aktuellen Prüfen & Reparieren (Slot 1)"   ,ImageID( DI::#_MNU_RNE )) 
    		MenuItem(13, "Aktuellen Prüfen & Reparieren (Slot 2)"   ,ImageID( DI::#_MNU_RNE ))                        
    		MenuItem(14, "Aktuellen Prüfen & Reparieren (Slot 3)"   ,ImageID( DI::#_MNU_RNE )) 
    		MenuItem(15, "Aktuellen Prüfen & Reparieren (Slot 4)"   ,ImageID( DI::#_MNU_RNE ))            
    		CloseSubMenu()       
    		MenuBar()            
    		MenuItem(34, "Enable : Aero/Uxsms"                      ,ImageID( DI::#_MNU_AEE ))
    		MenuBar()
    		MenuItem(30, "Disable: Explorer"                        ,ImageID( DI::#_MNU_EXD ))         
    		MenuItem(32, "Disable: Taskbar"                         ,ImageID( DI::#_MNU_TBD ))                      
    		MenuItem(35, "Disable: Aero/Uxsms"                      ,ImageID( DI::#_MNU_AED ))              
    		MenuBar()
    		OpenSubMenu( "Einstellungen"   							,ImageID( DI::#_MNU_VSP )) 
    		MenuItem(9 , "Schriftart: Title..."                     ,ImageID( DI::#_MNU_FDL ))
    		MenuItem(10, "Schriftart: Liste..."                     ,ImageID( DI::#_MNU_FDL )) 
    		MenuBar()                   
    		MenuItem(20, "Fenster Zurücksetzen"                     ,ImageID( DI::#_MNU_WMS ))                                        
    		MenuItem(7 , "Fenster Höhe Ändern"                      ,ImageID( DI::#_MNU_WMH ))
    		MenuBar()            
    		MenuItem(16, "Info Zurücksetzen"                        ,ImageID( DI::#_MNU_WRS ))
    		CloseSubMenu()
    		MenuBar()             
    	EndIf
    	MenuItem(98, "vSystems Update"							,ImageID( DI::#_MNU_VSU ))        
    	MenuItem(99, "vSystems Beenden"							,ImageID( DI::#_MNU_VSY ))
    	
    	
    	
    	
    	
    EndProcedure
    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 2549
; FirstLine = 72
; Folding = D5--
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; Debugger = IDE
; EnableUnicode