DeclareModule DB_Migrate
    
    Declare Prepare_Migrate()
    
        Structure STRUCT_BACKUP
        Base_Game.s{1024}           ;Dtatabase Datei
        Base_Pict.s{1024}           ;Databasee Datei, Covers,Screenshots
        Base_Strt.s{1024}           ;Databasee Datei, Enthält die Infos zum starten der Programme und Emulation           
        EndStructure           
    
        Global *LHBackupDB.STRUCT_BACKUP       = AllocateMemory(SizeOf(STRUCT_BACKUP))
        
EndDeclareModule 

DeclareModule INVMNU
    
    Declare.i   Request_MSG_Quit()
    
    Declare     Set_TrayMenu()
    Declare     Get_TrayMenu(MenuID.i)
    
    Declare     Set_ShotsMenu()
    Declare     Get_ShotsMenu(MenuID.i, GadgetID.i)
    
    Declare     Set_PopMenu1()
    Declare     Get_PopMenu1(MenuID.i, GadgetID.i) 
    
    Declare     Set_C64Menu(MenuID.i)
    Declare     Get_C64Menu(MenuID.i, GadgetID.i)  
    
    Declare     Set_AppMenu(MenuID.i)
    Declare     Get_AppMenu(MenuID.i, GadgetID.i)
    
    
    Structure MNU_C64ITEMS
        TRMODE.i      
        FORM40.i        
        USWARP.i  
        FORMAT.i  
        NIMAGE.i
        READDL.i
        READIN.i
        RETRYC.i
        BAMOCP.i
    EndStructure
    Global *LHMNU64.MNU_C64ITEMS       = AllocateMemory(SizeOf(MNU_C64ITEMS))        
    
    INVMNU::*LHMNU64\FORM40 = #True
    INVMNU::*LHMNU64\USWARP = #True
    INVMNU::*LHMNU64\TRMODE = 3
    INVMNU::*LHMNU64\FORMAT = 0 ; 0 Use cbmformat, 1 Use   cbmforng; 2 use cbmctrl
    INVMNU::*LHMNU64\NIMAGE = 0    
    INVMNU::*LHMNU64\READDL = 1      
    INVMNU::*LHMNU64\READIN = 13
    INVMNU::*LHMNU64\RETRYC = 0 
    INVMNU::*LHMNU64\BAMOCP = 0
    
EndDeclareModule

DeclareModule vWindows
    Declare OpenWindow_Sys1(Set_Category.i = 0)
    Declare OpenWindow_Sys2()    
    Declare OpenWindow_Sys3(ImageGadgetID.i)   
    
    Declare OpenWindow_Sys64(GadgetID.i,DestGadgetID.i)
    Declare OpenWindow_Archiv(GadgetID.i,DestGadgetID.i)
    
    Declare OpenWindow_EditInfos()
    
    Declare DragnDrop_Support(DropGadget.i)
    
    Declare GadgetWindowCheck()
    
EndDeclareModule

DeclareModule GuruCallBack
    
    Declare.l CallBackEvnts(hwnd, uMsg, wParam, lParam)
    Declare   PostEvents_Resize(hwnd.i)
    Declare.i PostEvents_Close(hwnd.i) 
    Declare.i StringGadgetCallBack(hwnd, msg, wParam, lParam) 
    Declare StringGadgetSetCallback(pbnr, parent, xyz = 0)
    
    Declare.i ListGadgetSetCallback(pbnr, parent, xyz = 0)
    Declare ListGadgetCallBack(hwnd, msg, wParam, lParam) 
    
    Declare.i SplitGadgetSetCallback(pbnr, parent, xyz = 0)
    Declare SplitGadgetCallBack(hwnd, msg, wParam, lParam)  
    
    Declare.i ScrollAreaGadgetSetCallback(pbnr, parent, xyz = 0)
    Declare ScrollAreaGadgetCallBack(hwnd, msg, wParam, lParam)  
    
    Declare.l CallBackEvnts_Edit(hwnd, uMsg, wParam, lParam)
    
    Declare.i EditGadgetCallBack(hwnd, msg, wParam, lParam) 
    Declare EditGadgetSetCallback(pbnr, parent, xyz = 0)
    
    Declare Window_Get_ClientSize(hWnd, nWidth, nHeight)

    Global isMediaMouseBack.i = #False
    
   Enumeration #PB_EventType_FirstCustomValue  
       #PB_EventType_StrgReturn
       #PB_EventType_StrgEscape
       #PB_EventType_StrgUp
       #PB_EventType_StrgDown
   EndEnumeration
   
EndDeclareModule

DeclareModule vItemC64E
    
    
    Declare.i DSK_Image_Refresh()
    Declare.i DSK_LoadOldFilename()
    Declare.s DSK_SetCharSet(OldFileName$)
    Declare.i DSK_LoadImage(GadgetID.i,DestGadgetID.i, DropLoad = 0);<< C64LoadS8_TXID Variabel wird hier erstellt
    Declare.i DSK_FormatCheck(D64_Image$)
    Declare.i DSK_OpenCBM_Tools(Tool$ = "rename")
    
    Declare.i Image_Create()
    Declare.i Image_CopyFile_FromImageToHD()
    Declare.i Image_CopyFile_FromHDToImage(FileRequester = #True)
    
    Declare.i Item_GetPrograms()
    Declare.i Item_ChangeFont()
    Declare.i Item_Auto_Select()
    Declare.s Item_Select_List()
    Declare   Item_GetPrograms()  
    Declare.i Item_Side_AutoChange()
    Declare.i Item_Side_SetAktiv(C64LoadS8_Side)
    
    Declare.i DragnDrop_Load(Files$,GadgetID.i,DestGadgetID.i)
    
    Declare.i DSK_OpenCBM_Init()
    Declare.i DSK_OpenCBM_Directory()
    Declare.i DSK_OpenCBM_Refresh()
    Declare.i DSK_OpenCBM_Format()
    Declare.i DSK_OpenCBM_Val()    
    Declare.i DSK_OpenCBM_Copy_LocalFile_To_1541(FileRequester.i = #True)   
    
    Declare.i DSK_Image_TransferToPCHD(TrackOnly = #False)
    Declare.i DSK_Image_TransferTo1541()
    
    Global vItemC64E_CanClose.i = #False 
EndDeclareModule

DeclareModule Startup
    
    Global      ToolTipSystemInfo.s
    Declare     DB_Read_Config()
    Declare.s   History(svn = #False, Option = 0)
    ;****************************************************************************************************************************************************
    ;        
    Structure SCROLLITEM_PB
        LVM_PBSID.i
        LVM_WINID.i
        LVM_CITEM.i
        LVM_ITEMS.i
        LVM_SPACE.i  
    EndStructure    
    
;     Structure OBJECT_EDIT_CLIPBOARD
;         Field1.s
;         Field2.s
;         Field3.s
;         Field4.s
;     EndStructure        
    
    Structure OBJECT_EDIT_MODIFIED
        bEdit1.i
        bEdit2.i
        bEdit3.i        
        bEdit4.i
        szTxt1.s
        szTxt2.s
        szTxt3.s
        szTxt4.s        
    EndStructure
    
    Structure OBJECT_EDIT_STANDARD
        h.i
        w.i
    EndStructure
    
    Structure OBJECT_EDIT_WINDOW
        h.i                         ; Infos Window Höhe
        w.i                         ; Infos Window Weite
        x.i                         ; Infos Winoow Position X (Left)
        y.i                         ; Infos Window Position Y (Top)        
        DesktopW.i                  ; Desktop Grösse
        MainWinY.i                  ; Infos Window Weite
        bSide.i                     ; Fenster Poition (Links = -1, Rechts = 1, Standard = 0)
        bActivated.i
        SnapHeight.i
        bAktivated.i
        bTabNum.i
        RegFndRpl.l
        lHwndDlg.l
        kFind_Return.i              ; KeyCode Return (Via Window )
        bPrint.i
        bTabAuto.i                  ; Öffnet den text Reader Automatisch
        TabButton.i                 ; Der Standard Button der für Auto Öffnen Registriert ist
        nMaxLines.i                 ; 
        szXmlText.s
        nMarked.l
        bLeft.i
        bURLOpnWith.i
        sURLAdresse.s
        ; Haupt Fenster Y Position um die Differenz zum Edit Window (Y) zu Docken und zuberechnen
        Reset.OBJECT_EDIT_STANDARD       
        FindReplace.FINDREPLACE
        Modified.OBJECT_EDIT_MODIFIED
        Range.CHARRANGE
        szlastPath.s
    EndStructure
    
    Structure FILE_MONITORING
        Directory.s
        LogPath.s
        LogFile.s
        LogHandle.i
        LatestLog.s
      EndStructure
      
    Structure FILE_SAVESUPPORT
        Directory.s
        SavePath.s
        SaveFile.s
        SaveHandle.i        
      EndStructure
      
      Structure FILE_REGSSUPPORT
      	ConfigPath.s								; Config Path
        ConfigFile.s								; vSystems-RegistrySupport.ini
        Configandle.i        				; Datei Handle für die Registry Dateien
    EndStructure        
    
    Structure STRUCT_LH_DATABASE        
        TitleVersion.s{255}         ;Version und Title
        TitleSimpled.s{255}         ;Version und Title (Einfach)
        Base_Path.s{4096}           ;Programm Verzeichis        
        Base_Game.s{1024}           ;Dtatabase Datei
        Base_Pict.s{1024}           ;Databasee Datei, Covers,Screenshots
        Base_Strt.s{1024}           ;Databasee Datei, Enthält die Infos zum starten der Programme und Emulation
        SubF_Data.s{4096}           ;Unterverzeichnis für Daten "DATA"
        SubF_vSys.s{4096}			;Unterverzeichnis für Daten "VSYSDB"   
        Base_Shot.s{4096}
        GameID.i                    ;RowID
        GameLS.i                    ;Beim Auflisten die Nummer der ListIcon Box Data asuwählen
        Switch.i                    ;Container Umschalter 0=Listbox;
        SwitchNoItems.i             ;Verkürzt und erleichtert die Routine wenn keine Items Selektiert sind
        Anim_LodGameList.i          ;Benutze Game Lade Animation
        UpdateSection.i             ;Bestimmt nach dem das Fenster offen war welche Kategiere in den Strings aktualisert wird (-1 Alles)
        DateFormat.s                ;Die Datumsmaske die in den Strings benutzt wird
        Settings_NoBorder.i         ;Hack: Entfernt die Fenster von den Prgrammen
        Settings_Minimize.i         ;Minimierr vSystem wenn das programm gestartet wird
        Settings_Asyncron.i         ;Vsystem Startet das Programm im Asyncronene Modus
        Settings_aProcess.i         ;Alternativer Start des programms (Process)   
        Settings_Taskbar.i          ;Hide, unHide Windows Taskbar
        Settings_Explorer.i         ;Hide, UnHide Explorer.exe
        Settings_DwmUxsms.i         ;Hide, Unhide Aero Support
        Settings_NBCenter.i         ;Center NoBorder Image
        Settings_LokMouse.i         ;Lock Mouse in Window Mode      
        Settings_OvLapped.i         ;Remove Overlappedwindow Style in Window Mode   
        Settings_CenterWN.i         ;Center Window (Not Yet)
        Settings_Affinity.i         ;Prozessor Zugehörigkeit Festlegen
        Settings_bCompatM.i         ;Bool für Compatibility Modus
        Settings_sCmpFile.s{255}    ;Path und Programm der in die Registry geschrieben werden soll
        Settings_sCmpArgs.s{255}    ;Registry Werte für den Compatibility Modus
        Settings_FreeMemE.i
        Settings_Schwelle.q         ; Speicherschwelle ab wann der speicher geleert werden
        Settings_bKillPrc.i         ; Killz den process
        Settings_bBlockFW.i         ; Blocks programs from Inet/ Add Temporay to Firewall     
        Settings_bNoOutPt.i        
        Settings_NoBoTime.i         ;NoBorder Time
        Settings_GetSmtrc.i         ;GetSystemmetrics Options
        Settings_bSaveLog.i         ;Disabled Outputlog and Redirect to StdOut.txt
        Settings_NBNoShot.i         ;Disable Screenshot Capture Support
        Settings_hkeyKill.i         ;Disbale/Enable Hotkey für das Beenden eines Programs
        Settings_hkeyShot.i         ;Hotkey Modifier für das Aufnehmen der Screenshots
        Settings_hkeyMMBT.i         ;Hotkey Modifier für das Aufnehmen der Screenshots        
        Settings_fMonitor.i         ;Sepaerates Aktivieren des Monitoring der Datei Aktivität wenn das Spiel/Programm gestartet wird
        Settings_MameHelp.i					;Mame / Mess Commandline Hilfe für Medien in Kombination mit Image und HD anweisungen
        Settings_aExecute.i					;Alternativer Process für das Ausführen von programmen
        Settings_SaveTool.i					;Save Support: Backup/Restore
        Settings_VrtlDrve.i					;Virtual Drive Support     
        vKeyActivShot.i             ;Temporäre Var für den Loop
        vKeyActivKill.i             ;Temporäre Var für den Loop
        vKeyActivMMBT.i			;Temporäre Var für den Loop
        ArchivTyp.s			
        
        PortablePath.s{4096}        ;Portabler Pfad, wird übernommen von Base_Path
        WindowPosition.Point        ;Fenster Position  
        TaskbarCreate.l             ;Callback Message falls die Windows Taskbar (explorer neugeladen wird und das Pictogramm aufgefrischt werden muss)
                                    ;Siehe dazu die Message im Callback
        SortMode.i                  ;Sortier Modus für die Hauptliste (1 > Tile, 2 > Platform, 3 > Sprache, 4 > Emulator)
        ProgrammQuit.i              ;True oder False
        
        FileMonitoring.i            ;Acrivate/DeActivateed with #True/False
        Monitoring.FILE_MONITORING  ;
        
        SaveTool.FILE_SAVESUPPORT
        RegsTool.FILE_REGSSUPPORT
        
        DriveLetter.s            		; Virtual Drive Support: Laufwerksbuchstaben
        
        hSplitterDef.i              ;Die Splitter Standard Höhe
        hSplitterSav.i              ;Die Alten Höhe
        
        WindowHeight.i              ;Die Höhe Einstellbar
        
        hScreenShotGadget.i         ;Die Statndard höhe für die Screenshots
        wScreenShotGadget.i         ;Die Statndard höhe für die Screenshots 
        
        MaxScreenshots.i            ;Die Maximale Anzhal an Screenshots
        
        bisImageDBChanged.i         ; 
        isGIF.i                     ; Fremd Bilder in Purebasic, Wird Konvertiert nach PNG
        isIFF.i                     ; Fremd Bilder in Purebasic, Wird Konvertiert nach PNG
        isPCX.i                     ; Fremd Bilder in Purebasic, Wird Konvertiert nach PNG
        isDDS.i                     ; Fremd Bilder in Purebasic, Wird Konvertiert nach PNG        
        
        ;Images_Thread.i
        Images_Mutex.i[1024]
        Resize_Mutex.i 
        Resize_Thread.i
        Images_Thread.i[1024]
        Images_Threaded.i[51]        
        
        CBMFONT.l                   ; Commodore 64 Font
        C64LoadS8.s                 ; c1541.exe oder dm.exe, um das verzeichnis von C64er Images zu lesen
        OpenCBM_Tools.s             ; verzeichnis für OpenCBM Programme
        OpenCBM_BPath.s             ; Zielverzeichnis für OpenCBM
        
        BaseSVNCurrent.s            ; The Current Database Version
        BaseSVNLoaded.s             ; The Version in Database
        BaseSVNMigrate.i 
        
        TrayIconTitle.s             ; Tray Icon Titles 
                
        bRegHotKey.i                ; true/False 
        
        bFirstBootUp.i              ; true/False 
        
        bUpdateProcess.i            ; true/False
        vItemLoaded.i               ; Nummer für das gestartete Programm > Siehe vItemTool
        vItemColorF.i               ; TextFarbe                          > Siehe vItemTool
        
        bBuild32Bit.i               ; bool Is32Bit Exe
        VersionNumber.s             ; Version String (Nummer)
        Thread_ProcessHigh.i        ; 
        Thread_ProcessLow.i
        Thread_ProcessName.s        ; szTaskanem
        Thread_ProcessId.i
        NBWindowhwnd.l              ; Handle des Fremden Fensters
        NBWindow.RECT
        NBClient.RECT 
        NBWindowAppName.s
        bvSystem_Restart.i          ; Wenn die Höhe des Fentser angegeben wird und vSystem neustartet, denb Konlikt vermiden das es schon im System Task Existiert
        InfoWindow.OBJECT_EDIT_WINDOW; Einstellungen für das Infor Fenster
        aUseless.s
        FolderWWW.s
        FolderMameSource.s
        SortXtendMode.i
        GadgetIDCheck.i
        WindowIDCheck.i
        FormIsChecked.i
        LastSplitHeight.i
        Max_Saves_List.i					; Maximal Entrys ab Unreal Menüleist
        ExitSignal.i
        
    EndStructure           
    Global *LHGameDB.STRUCT_LH_DATABASE       = AllocateMemory(SizeOf(STRUCT_LH_DATABASE))
    
    Structure STRUCT_LH_IMAGES
        
        OrScreenID.l[51]             ;Die Pure Windows ID des Screenshot (Original, Unverändert)
        OrScreenPB.l[51]             ;Die Pure Basic   ID des Screenshot (Original, Unverändert)
        NoScreenID.l[51]             ;Die Pure Windows ID des NoScreenshot (Original, Unverändert)
        NoScreenPB.l[51]             ;Die Pure Basic   ID des NoScreenshot  (Original, Unverändert)       
        CpScreenID.l[51]             ;Die Pure Windows ID des Screenshot (Copy)
        CpScreenPB.l[51]             ;Die Pure Basic   ID des Screenshot (Copy)        
        ScreenGDID.l[51]             ;Die Pure Basic Gadget ID des Screenshot      
    EndStructure           
    Global *LHImages.STRUCT_LH_IMAGES       = AllocateMemory(SizeOf(STRUCT_LH_DATABASE))        
    
    ;
    ; ******************************************************************************
    ; Strukture Hält 50 Screenshots   
    Structure STRUCT_MEMIMAGES      
        thumb.i[100000]
        bsize.i[100000]               
    EndStructure            
    Global Dim SlotShots.STRUCT_MEMIMAGES(50)    
    
    Structure EDIT_XY_IMAGES
    	x.i
    	y.i
    	w.i
    	h.i
    	bits.i
    	format.s
    	rawsize.q
    	imgsize.s
    EndStructure
    Structure EDIT_XY_SCROLLAREAGADGET
    	x.i
    	y.i
    	w.i
    	h.i
    EndStructure
    
    Structure EDIT_LH_IMAGES
    	cPBID.i
    	CpyData.l    	
    	OrgData.l
    	mWheelActiv.i
    	MaxReached.i
    	GadgetMax.i
    	bmCopy.EDIT_XY_IMAGES
    	bmOrig.EDIT_XY_IMAGES
    	SGDID.EDIT_XY_SCROLLAREAGADGET
    EndStructure
    
		Global *LHimgEdit.EDIT_LH_IMAGES       = AllocateMemory(SizeOf(EDIT_LH_IMAGES))       
    ;
    ;****************************************************************************************************************************************************
    Declare Prepare()
EndDeclareModule

Module Startup    
    Procedure.s History(svn = #False, Option = 0)
        Protected Version.s, Title.s, BuildDate.s, dbSVN.s
               
        XIncludeFile "Module_Version.pb"
        
        
        ;
				; Version 0.60.12
				; Virtual Drive Support hinzugefügt. Commandline "%vdm[drive]"
        ; Schnell Kommando mit Admin Mode mode Hinzugefügt
        
        ;
				; Version 0.60.11
				; Slot Unterstützung hinzugefügt für Conf,ini.bat um diese dateien direct oder mit Auswahl an den Editoren weiterzuleiten
        
        
        ;
				; Version 0.60.10
				; Save Game Support: Ersten Icons hinzugefügt
				; Save Game Support: Requester ausgearbeitet        
				; Dialog Resquester Rename für untergruppen aktualisiert
				; Emulations/Ports Liste erweitert
				; Dialog Requester: Höhe Fixed
        
        ;
				; Version 0.60.8
				; Save Game Support: Compression Level hinzugefügt        
        ; Prüft ob die Konfigurations Datenbnak anhand eines anderen Datei Namens von vSystems im selben verzeichnis schon geöffnet ist
        
        ;
				; Version 0.60.7
				; Save Game Support. Large Compression Memory Fix
				; ButtonExState Updated (Compression, Prgramm Running)
        
        ;
				; Version 0.60.6
				; Beim beenden des Programs 1x Speicher säubern
        ; WatWindowEvent -> WaitWindow. Handelt doch besser das Beenden der Programme... bisher
        
        ;
				; Version 0.60.5
				; Save-Game Support: Native Home-User sind nicht erlaubt
        ; Save-Game Support: Added FOLDERID_LocalAppDataLow
        
        ;
				; Version 0.60.4
				; Fixed Save Support Nicht intialisierte Liste (doof)
        ; Mehrere Absicherungen und KOrrekturen für das Save Game Support
        
        ;
				; Version 0.60.3
				; Savegame Support: Bennung des Titles ändert auch den Title in der Konfig sowie das Backup Verzeichnis
				; Fixed Start-End Routine     
        
        ;
				; Version 0.60.2
				; Variable Geändert für das ablegen der Thumbnnails in die Datenbank
				; Hinzufügen einer Info Textdatei beim erstellen einer Geapckten Spielstand Sicherung
        ; Routinen ausgekklammert.
        
        ;
				; Version 0.60.1
				;
				; Borderless Code changed (%nb). Calculation Routine sollte nun funktionieren ohne das das Fenster sich verkleiner *doohh
				; SaveGame Menü ins Tray zeitgleich verankert
				; SaveGame Multiple Verzeichnisse Einträge für jeden einzelen DB Eintrag fixed
        ; Rare Speicher Fix für Thumbnnail
        
        ;
				; Version 0.60.0
				;
				; Versionscheck fixed
        
        ;
				; Version 0.59.9
				;	Temporär CursorPos abgeschaltet
				; CTRL+S im Editor (Speichern des Texts) und dann dem anwählen eines anderen Eintrags das "Fenster zum Speichern" gefixed
				; Unity Commanlined hinzugefügt
				; Output std und Error wurde nicht freigeben und routine überarbeitet
				; Menu im Programm Editor überarbeitet        
				; Mehr Hilfe und wie was funktioniert hinzugefügt
				; Savegame System Hinzugefügt

        
        ;
				; Version 0.52b
				; Kompatibilitäts Assisitenten erweitert. Alle Modi's und Fixe sind mit "%c<Mode/Fix>" startbar
				; Text Speichen Openfile ist jetzt Createfile mit Backup
				; Update und Korrektur für den Portable Path Modus
        ; Bessere Extension Auflösung
				;
	    	; Version 0.51b
	    	; Alternative Windows API Process für das Ausführen von Programmen falls die Routine von Purebasic
	    	; nicht greift. "%altexe"
	    	; Logitech LCD Support (Mono erstmal)
        ; 
        ;
        ; Version 0.50b
        ; Cue Banner für ein paar String Einstellungs Fenster
        ; Format Routine für den C64 Datei Manager geändert
        ; Zusatz Datei laden geändert
        ; MAME Kommandozeile Hilfe für Leer Stehende Slot(s) aber mit Konfigurierten Image Angabe (%mmhlp)
        ; Tooltypes bearbeitet.
        
        ;
        ; Version 0.49b
        ; Überwachung der Datei und Verzeichnis Aktivität für C:\ hinzugefügt
        ; - Hintergrund: Neben Programmen sichern Spiele, Ports, Emulatoren Dateien im Home Verzeichnis des Users
        ;   meist "C:\User\xxxx\...." oder auch Programdata/ Programme/ Programme (x86).
        ;   Das Überwachen dient leiglich dazu die Verzeichnisse ausfindig zu machen. So kann man diese Später
        ;   Sichern und so über die Verzeichnisse den Überblick behalten. Welches Programm/Spiel/Port Emulator
        ;   wo und was gesichert/geändert oder entfernt hat.
        ; - Wird im TrayMenu aktiviert oder über die Arguments Zeile mit "%wmon"
        ;
        ; Version 0.48b
        ; Rekationszeit zwischen dem Starten des Programs und dem Registrieren des Capture Hotkeys (Fixed)
        ; Schnelle Änderung des Titles vom Program sowie schnelle änderung des Arguments hinzugefügt
        
        ;
        ; Version 0.47b        
        ; Rekationszeit zwischen dem Starten des Programs und dem Registrieren des Capture Hotkeys
        ; Tray Menu erweiter. Ansicht der Capture und öffnen des Bildes mit dem Standard Programm
        
        ;
        ; Version 0.46b
        ; Thumbnail und Splitter ausgearbeitet
        ; HotKey für das Beenden (quasi Taskill) des gestarteten Programm hunzugefügt
        ; Hoitkey ist: ALT und SCROLL/Rollen
        
        ;
        ; Version 0.45b
        ; Code Routine für Log Output geändert
        ; Tray Menü Einträge für den zugriff auf Log und Screenshot Dateien hinzugefügt
        
        ;
        ; Version 0.44b       
        ; Möglichkeit ein Schnappschuss von dem Fensterhinhalt zu machen. Nur in Verbindung mit "No Border"
        ; (Screenshot werden im Unterverzeichns von ".\System\SHOT\" gespeichert). Voreingestellte Taste ist
        ;  "Rollen / Scroll". (Erst mal). Als hinweis wird beim "Speichern" wird ein Ton abgespielt.)
        ; "%nbsht" als argument hinzugefügt. Damit wird die ScreenShot Capture funktion deaktiviert
        ; Ein paar Code änderungen ...
        
        ;
        ; Version 0.43b
        ; "%nbgsm" als argument hinzugefügt. Nur in Verbindung mit "No Border". System Metrics wierden nicht beachtet
        ; "%svlvg" als argument hinzugefügt. Leitet die Program Ausgabe in eine Text Datei
        
        ;
        ; Version 0.42b
        ; Ups, Bug Fix (Löschen)
        ;
        ; Version 0.41b  
        ; Löscheintrag Hinzugefügt um Alle Einträge Löschen
        ; Speziellen Löscheintrag hinzugefügt - Löschen aller einträge bis auf den ersten
        ; Info Fenster: Text Syncron Speichern (Speichert den geänderten inhalt in die Datenbank und in die Datei)
        
        ;
        ; Version 0.40b          
        ; Kalender eingabe bearbeitet
        ; Programm Dateirequester Filter bearbeitet
        ; OS Spezifische Dateinamen behandlung beim Speichern der Bilder
        ; Clibbaord Aktion für die Bilder (Kopieren und einfügen)       
        ; Dim Strukture erweitert
        ; 3 PNG Bilder convert von 32bit nach 8Bit
        ; Compiled Exes without DPI Awareness (Compile with DPI Awarenss is not good under Breaks Windows 8+)
        
        
        ; Version 0.39b          
        ; CPU Cycles be NoBorder etc.. gesenkt
        ; Requester Source: #WMKDown gegen #WMkeyup geändert
        ; Requester Source: Delay Cycles abgesenkt
        
        ;
        ; Version 0.38b          
        ; ??
        
        ;
        ; Version 0.37b          
        ; Tooltip Info About Zeigt wieviele Einträge vorhanden sind
        ;      
        ; Version 0.36b   
        ; Added Command %noout: Disable and dont show Loggin Output from programs
        ; Verify for check if Program alive
        ; Added Timer 0-9 for noborder command (Only for StartTime*255; For Prg's the opens a console window)
        
        ; Version 0.35b        
        ; Fix Findwindow ... ups
        ; Reload Window -> Height Korrigiert
        
        ; Version 0.33b
        ; Design Fix
        
        ; Version 0.32b
        ; Fix Konflikt start
        ; Fix Commandline Order
        
        ;        
        ; Version 0.31b
        ; More work on Thumbnail Loading
        
        ;        
        ; Version 0.30b
        ; Hinzugefügt %sc als universelle Kommandozeilen übergabe von den Slots aus
        ;        
        ; Version 0.29b          
        ; Fixed HighCpu mit %Cpu[x] Argument
        ; Vesetzt vSystem von Normal in Idle wenn ein programm gestartet wird
        ; Intanz Nachricht an user wennn das "selbe" vSystems gestartet
        ; Thread Optimierung für die Thumnails. Möglicher Crash Fix
        
        ;        
        ; Version 0.28b          
        ; Optimize Thumbnail Loading
        ; Add Support to Block Program in the Firewall
        
        ;        
        ; Version 0.27b          
        ; Update Test
        
        ; Version 0.26b         
        ; Github Release
        ; (Beta) Update System bearbeitet
        
        ; Version 0.25b         
        ; Thread Optimiert und gesplttet den Code für die Thumbnails
        ; Crashfix Windows 10
        
        ; Version 0.24b 
        ; 1. Version des Update Moduls Implentiert
        ; - Erstmal Lokal um zu testen
        ;
        ; Bugfix: Keyboard List Handle
        ; Markierung hinzugefügt wenn das programm gestartet ist
        ; - Unterstzüng für 32bit Programme mit oder ohne 4GB Patch wo es vorkommt
        ;   das es ein Überlauf des Cache Speichers von den erlaubten 3.2GB gibt
        ; - Maxmimum Schwellenwert angabe bis der Cache wieder aufgeräumt wird
        ;   Von 1mb bis 3000mb
        
        ; Version 0.23b 
        ; Added Windows Compatibility Mode(s)
        ; - Can be used from the Commandline, look Tooltip help
        
        ; Version 0.22b    
        ; Minor corrections to "Center for NoBorder Window"
        ; Added CPU Affinity Mode
        ; - For Games they have Problems with more as one/ four CPU Units
        ;   or that dont use real all CPU Units
        ; ReCoded Media Files Slots Routine
        ; Changed Tooltip Help Font and Description for the Commandline
        ; Fixed Universal Message Requester for Big and lot of Programm Texts
        ;
        ; Added Ability to Remove Window Style #Overlappedwindow
        ; - Without this you have a thin scaleable window
        ;
        ; Added Mouselock for Windowed/Borderless Games
        ; - use as a Temporary Fix that leaving the Mouse Pointer from
        ;   Game on Multi Monitor Systems
        ; Fixed Focus for Locked Screen/ Window
                                              
        ; Version 0.21b    
        ; Support Center for NoBorder Window
        
        ; Version 0.20b           
        ; ReCode for NoBorder (Successfully testet on Window Apps/ AVPx )
        
        ; Version 0.19b           
        ; Fixed Asnyc Loading
        
        ; Version 0.18b        
        ; Save text to File saves now first to DB
        ; Added Text Reload
        
        ; Version 0.17b        
        ; Font FixPlain with Pc-Clone for Default Reader Replaced
        ; Small Fixes
        ; Change Thumbnail Routine
        
        ; Version 0.16b
        ; More Options for Info Window Docking, Added, Left, Right and Lose (not Dock)
        ; Remember the Last Path on Search for Path/s
        ; Added Windows Cmd Run
        ; Added File Open with External Program
        ; Added File Properties
        ; Added Notify URL Open with
        ; FindWindow_ empty string lenght Fixed
        
        ; Version 0.15b
        ; Add Support for Check and Repairing for Full and Portable Path's 
        ; Thumbnail Sizing Optimize
        ; Add more Thumbnail Size's (Check Thumbnail Menu)        
        ; More Minor Fixes
        
        ; Version 0.14b
        ; Fixed Edit Info Windw State on Edit Main Item
        ; More Fixes to Borderless RichControl
        ; Fix Font Save/Load Bug
        ; Is there a Text? Color Adjust for Tab Switch
        ; Added Ctrl-F, Ctrl-O, Ctrl-S for Edit Info Window
        ; Added support to Disable/Enable Explorer, Taskbar, Aero (W7)
        ; Fixed Non Asociated Tab Switch
        ; No Fontchchanges for DOC, RTF
        ; Support Raw Read DOCX (Zipped), ODT (Zipped), XML
        ; Fixed Reset Font - Use Internal
        
        ; Version 0.13b
        ; CTRL-S for Edit Page
        ; vSystems Filename to Show in TrayIcon Title
        ; Support Mousewheel for Screenshots
        ; Speedup Realtime Adjuste for Screenshots
        ; Minor Bugfixes        
        ; Resize Button Fixed
        ; Instance Used ProgrammFileName
        ; Added Info Text Editor Dynamic Window        
        
        ; Version 0.9b
        ; - SupportetDiskimages :
        ;       *Builtin        : D64, D71, D81, T64, TAP, CRT, PRG, P00        
        ;       *Need dd  : D80, D82, G64, G71. NIB, X64, LNX
        ;   For QuickLoading To Emulator's
        ; - Added 7z, Zip, Tar and Lz support for Programs and Emualtors that
        ;   has no Support/Bultin Arc. (Using %pk at the Commandline)
        ; - Moved Predefined Programs to the Program Selector Window (= is Menu)
        ; - P00, Load in Memory nd Show the Original Filename
        ; - Database: Predefined Apps don't update. Do Insert
        ; - Added bSnes & Snes9x to predefined Programs
        ; - Add a Migrate/Update database Technic
        ; - Add Support vor CRT (Only Show)
        ; - Fix uncompress to Memory
        ; - Add Mednafen Saturn /PSX to predefined Programs
        
        ; Version 0.9a
        ; - Database Function Routine fixed for ascii 32 on command
        ; - Added files mode for WinVice "Image:File"
        ; - Added Disk Image Lister for Commodore 64 Stuff
        ; - Support for OpenCBM, DM.exe and C1541.exe
        ; - Little bit Delayed Exit Routine with Free Memory
        ; ( Background:
        ; ( I need a quick File Lister and Starter For C64 Stuff
        ; ( in combination with WinVice and my own Config as Args.
        ; ( CBM Transfer is Quick with Loading c64 Prgs from Floppy
        ; ( But has not support for own Winvice Config arguments.
        ; ( Dirmaster does'nt load SDL2Vice, no idea and no Feedback to my mail)
        
        ; Version 0.8a
        ; - fixed id syncro for language, port, platform
        ; - heavy optimze speed
        ; - New Menuitem: Set Splitterheight All. (Change all Entrys to use the same Spltterheight)
        ; - Additional more Infos on Duplicate and on Quit
        ; - typo's fixed
        
        ; Version 0.7a
        ; - (Duplicate Screenshots) Message Requester Added to ask user
        ; - (Import Images) Added Overwrite Requester
        ; - Menu for Images added
        ; - (Images Menu) Added Load and Import via Menu
        ; - (Images Menu) Added Save Image(s)
        ; - (Images Menu) Added Delete Image(s)    
        ;
        ; Version 0.0 -> 0.06a
        ; Private Release, Development, Testing
        ;        
        ; 
        ; 
        ; 
        
        ; Beschreibung
        ; Ein Minimalistic Starter für Ports/ Emulatoren und Programme/Spiele wobei im hintergrund dafür eine SQL DB verwendet wird. 
        ; Minimalistic Design. Keine Cover oder Screenshot unterstützung
        ;
        ; Features: 
        ; - 2.3Mb Gross. Eine Einzlene Exe. Keine DLL's
        ; - Portable. Keine Installation notwendig. Ist nicht von der Registry abhängig. Speichert nichts ins User Verzeichnis
        ; - Programme die sich innerhalb von vSystems aufhalten werden ebenfals von vSystems Portable gehandhabt
        ; - Verzeichnisse und SQL Lite DB werden beim ersten Progamm Start angelegt.
        ;
        ; Oberflächen Technik
        ; - Verschieben (Drag) des Fenster kann an der Fenster Leiste OBEN (standard) oder UNTEN erfolgen
        ; - TrayIcon mit selbst Schutz. Falls der Windows Explorer im Laufenden Betrieb Aus -und wieder Eingeschaltet wird.
        ; - Drag'n'Drop Support
        ; - Multi Monitor Support; mit Fenster Position's Reset falls ein Monitor ausbleibt.        
        ; - Eingabefelder sind auch gleichzeitig 'Buttons' um Dateien/ Programme hinzufügen. Alternativ lässt sich es mit 'Pfad Angabe' Steuern
        ; - Ein Rollen und Ausrollen mit Rechter Maustaste auf der Title Liste (wie WinRoll aka Fenster Minimieren zur eigenen Titel Liste)
        ; - Sortierungs (Titel, Platform, Language, Program). Auch mit der Taste F1 bis F4 Steuerbar
        ; 
        ; Schlüssel Argumente
        ; vSystems Bietet Schlüssel Arguemnte für Kommandozeilen Befehle
        ; - %s  = Übergibt dem Programm das hinterlegte Medium
        ; - %nb = Dem Programm wird der Rahmen entzogen (Test Phase)

        If ( svn = #True )
            ProcedureReturn dbSVN
        EndIf    
        
        If ( Option = 1 )       
        	
        	;
        	; Prüft ob die Datenbank Geöffnet werden kann
        	Protected fSize.q = FileSize( *LHGameDB\Base_Game )
        	If fSize > -1
        		Protected isOpenTest.l = ReadFile(#PB_Any,*LHGameDB\Base_Game)
         		If ( isOpenTest > 0 )
         			CloseFile( isOpenTest )
         		Else
         			Request::MSG("vSystems", "ERROR","Kann nicht auf die Datenbank Konfiguration zugreifen:" + #CR$ + *LHGameDB\Base_Game ,2,2,"",0,0)
         			End
         		EndIf	
         	EndIf	
         
          ProcedureReturn  Title + ": " + GetFilePart( ProgramFilename() ,1)
        EndIf         
        
        
        If ( Option = 2 )
            ProcedureReturn  Version
        EndIf
        
        If ( Option = 3 )
            ProcedureReturn   Title + " " + Version
        EndIf        
        
        ProcedureReturn Title + " " + Version + " "+ "(Build: " + Builddate +")"
        
    EndProcedure
    ;****************************************************************************************************************************************************
    ;    
    ; Database zum arbeiten Öffnen/ Nun Wirklich 
    ;         
    Procedure Work_Database(BaseID, DatabaseFile$)
        
        ExecSQL::OpenDB(BaseID,DatabaseFile$) 
        ExecSQL::TuneDB(BaseID)
    EndProcedure       
    ;****************************************************************************************************************************************************
    ;    
    ; Erstellt die Datenbanken
    ;    
    Procedure.i Module_Create(BaseID,FileID$, DatabaseFile)  
        
        Debug "=============================================================================="
        Debug "Datenbank: "  + FileID$ + " Wird erstellt (PBID: " + Str(BaseID) + ")"
        
        CreateFile(BaseID, FileID$,#PB_File_SharedRead|#PB_File_SharedWrite)
        
        Delay(10)
        ExecSQL::OpenDB(BaseID,FileID$)
        ExecSQL::TuneDB(BaseID)
        
        Select DatabaseFile
            Case 0                
                DB_Create::Db_Create_Game(BaseID); Ersellt die Datenbank        
                DB_Create::DB_First_Start(BaseID)                   
                ; Beim Allersten Start die GameID auf 1 bzw bei keinen Items auf 0 Setzen
                *LHGameDB\GameID = 1
                *LHGameDB\GameLS = 1
                ;
                ; Erster Start, die Höhe des Splitters Einstellen
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "SplitHeight" , Str(Startup::*LHGameDB\hSplitterDef),1)
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "WindowHeight", Str(Startup::*LHGameDB\WindowHeight),1) 
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "wScreenShotGadget", Str(Startup::*LHGameDB\wScreenShotGadget),1)
                ExecSQL::UpdateRow(DC::#Database_001,"Settings", "hScreenShotGadget", Str(Startup::*LHGameDB\hScreenShotGadget),1)                                 
                
            Case 1
                ;
                ; Picture DB Erstellen
                ;
                DB_Create::DB_Create_Pict(BaseID)
            Case 2    
                ;
                ; Start Commandos erstellen
                ;
        EndSelect
     
        
        ExecSQL::CloseDB(BaseID,FileID$)
        
        If FileSize(FileID$) >= 84
            Debug "Datenbank: "  + FileID$ + " OK (PBID: " + Str(BaseID) + ")"
            Work_Database(BaseID, FileID$)
            ProcedureReturn #True
        Else
            Debug "Datenbank: "  + FileID$ + " NICHT OK (PBID: " + Str(BaseID) + ")"
            ProcedureReturn #False
        EndIf
        
      
    EndProcedure   

    ;****************************************************************************************************************************************************
    ;    
    ; Database Erstellen
    ;      
    Procedure.i Make_Database()
        Protected Result.i
        If (FileSize(*LHGameDB\Base_Game) = -1)
            ;
            ; Erstellen
            Result.i = Module_Create(DC::#Database_001,*LHGameDB\Base_Game,0)
            
        EndIf
        
         If (FileSize(*LHGameDB\Base_Pict) = -1)
            ;
            ; Erstellen
             Result.i = Module_Create(DC::#Database_002,*LHGameDB\Base_Pict,1)  
         EndIf      
        
        
    EndProcedure    

    ;****************************************************************************************************************************************************
    ;    
    ;  Database Files Prüfen und öffnen
    Procedure Verify_DatabaseFiles()
        
        
        If (FileSize(*LHGameDB\Base_Game) >= 84)
            Work_Database(DC::#Database_001, *LHGameDB\Base_Game)
            ;
            ;
            ; Lese Einstellungen
            DB_Read_Config()
            
        Else
            Make_Database()
        EndIf    
        
        
        If (FileSize(*LHGameDB\Base_Pict) >= 84)
            Work_Database(DC::#Database_002, *LHGameDB\Base_Pict)
        Else
            Make_Database()
        EndIf 
        
    EndProcedure
        
    ;****************************************************************************************************************************************************
    ;    
    ;  Unterverzeichnis Prüfen
    ;
    Procedure Verify_Directories()
        
        Protected Error.i, Exists
        
        
        For DirCTest = 0 To 2
        
            If ( FileSize(*LHGameDB\SubF_vSys ) <> -2 )
                
                Error = FFH::ForceCreateDirectories(*LHGameDB\SubF_vSys)
                Select Error
                    Case 1 
                        ;
                        ;
                        If ( DirCTest = 2 ): Break: EndIf
                        
                    Case 0
                        ;
                        ;
                        If ( FileSize(*LHGameDB\SubF_vSys) <> -2 )
                            Error = CreateDirectory(*LHGameDB\SubF_vSys)
                            
                            If ( Error <> 0 And  DirCTest = 2 )
                                ;
                                ; ERROR
                                ;
                                Request::MSG("vSystems", "ERROR","Can't Create Directories" + Chr(13) + "Error Code is : " + Str(Error),2,-1,ProgramFilename())
                                End
                            EndIf
                        EndIf                        
                    
                    Default
                    
                EndSelect
                
            Else: Break: EndIf
        Next DirCTest 
    EndProcedure
    ;****************************************************************************************************************************************************
    ;    
    ; Vorbereitungen, Pfade Lesen
    ;       
     Procedure Prepare()                
         
         *LHGameDB\Base_Path            = GetCurrentDirectory()
         *LHGameDB\SubF_Data            = *LHGameDB\Base_Path + "Systeme\DATA\"
         *LHGameDB\SubF_vSys            = *LHGameDB\SubF_Data + "VSYSDB\"         
         *LHGameDB\Base_Game            = *LHGameDB\Base_Path + "Systeme\DATA\VSYSDB\BASE.DB"
         *LHGameDB\Base_Pict            = *LHGameDB\Base_Path + "Systeme\DATA\VSYSDB\PICT.DB"
         *LHGameDB\Base_Strt            = *LHGameDB\Base_Path + "Systeme\Data\VSYSDB\STRT.DB"
         *LHGameDB\Base_Shot            = *LHGameDB\Base_Path + "Systeme\SHOT\"
         *LHGameDB\UpdateSection        = -1
         *LHGameDB\DateFormat           = "%yyyy/%mm/%dd"
         *LHGameDB\PortablePath         = *LHGameDB\Base_Path
         *LHGameDB\TitleVersion         = History()
         *LHGameDB\TitleSimpled         = History(#False,3)
         *LHGameDB\BaseSVNCurrent       = History(#True)                                     ; The Database Version, for Update and changes
         *LHGameDB\TrayIconTitle        = History(#False,1)  
         *LHGameDB\VersionNumber        = History(#False,2) 
         *LHGameDB\TaskbarCreate        = RegisterWindowMessage_("TaskbarCreated")
         *LHGameDB\SortMode             = 0
         *LHGameDB\ProgrammQuit         = #False
         *LHGameDB\hSplitterDef         = 289
         *LHGameDB\WindowHeight         = 0 ; Standard Höhe
         *LHGameDB\wScreenShotGadget    = 202
         *LHGameDB\hScreenShotGadget    = 142
         *LHGameDB\MaxScreenshots       = 50
         *LHGameDB\isGIF                = #False
         *LHGameDB\isIFF                = #False
         *LHGameDB\isPCX                = #False
         *LHGameDB\isDDS                = #False
         *LHGameDB\bisImageDBChanged    = #False          
         *LHGameDB\CBMFONT.l            = 0    
         *LHGameDB\BaseSVNMigrate       = #False
         
         *LHGameDB\bFirstBootUp        = #True ; Erste Start des programms
         *LHGameDB\Images_Mutex         = -1
         *LHGameDB\Images_Thread        = -1
         
         *LHGameDB\bRegHotKey           = #False
         
         *LHGameDB\bUpdateProcess       = #False
         
         *LHGameDB\Monitoring\LogFile   = "StdWatch.txt"
         *LHGameDB\Monitoring\LogPath   = Startup::*LHGameDB\Base_Path + "Systeme\LOGS\"
         
         *LHGameDB\SaveTool\SavePath     = Startup::*LHGameDB\Base_Path + "Systeme\SAVE\"
         *LHGameDB\SaveTool\SaveFile     = *LHGameDB\SaveTool\SavePath + "vSystem-SaveSupport.ini"
         
         *LHGameDB\RegsTool\ConfigPath   = Startup::*LHGameDB\Base_Path + "Systeme\REGS\"
         *LHGameDB\RegsTool\ConfigPath   = *LHGameDB\SaveTool\SavePath + "vSystem-RegistrySupport.ini"         

         *LHGameDB\InfoWindow\bActivated= #False
         *LHGameDB\InfoWindow\bPrint    = #False
         *LHGameDB\InfoWindow\bTabNum   = 0
         *LHGameDB\InfoWindow\bTabAuto  = #False
         *LHGameDB\InfoWindow\TabButton = DC::#Button_283
         *LHGameDB\InfoWindow\nMaxLines = 0         
         *LHGameDB\InfoWindow\x         = 0   
         *LHGameDB\InfoWindow\y         = 0
         *LHGameDB\InfoWindow\w         = 420
         *LHGameDB\InfoWindow\h         = 720
         *LHGameDB\InfoWindow\Reset\w   = 420         
         *LHGameDB\InfoWindow\Reset\h   = 720    
         *LHGameDB\InfoWindow\bSide     = 0 ; (1- Links, Rechts -1)
         *LHGameDB\InfoWindow\DesktopW  = DesktopEX::MonitorInfo_Display_Size(#False, #True)
         *LHGameDB\InfoWindow\RegFndRpl = RegisterWindowMessage_("commdlg_FindReplace")                  
         
         *LHGameDB\InfoWindow\FindReplace\lStructSize = SizeOf( FINDREPLACE )
         *LHGameDB\InfoWindow\kFind_Return            = #False
         *LHGameDB\InfoWindow\bURLOpnWith= #True
         
         If ( #PB_Compiler_Processor = #PB_Processor_x86 )
              *LHGameDB\bBuild32Bit          = #True
         EndIf
         
         If ( #PB_Compiler_Processor = #PB_Processor_x64 )
              *LHGameDB\bBuild32Bit          = #False
         EndIf
         
         Verify_Directories()
         Verify_DatabaseFiles() 
         
         *LHGameDB\bvSystem_Restart = #False
         *LHGameDB\aUseless     		= "/degrem-emam/degrem-emam/daolnwod/gro.evihcra//"
         *LHGameDB\FolderWWW				= *LHGameDB\Base_Path + "Systeme\INET\"
         *LHGameDB\FolderMameSource	= "B:\MSYS2_MAME\src\Mame\"; *LHGameDB\Base_Path
         *LHGameDB\SortXtendMode		= #False
         
         ; Lösche Das Update Modul
          If FileSize(*LHGameDB\Base_Path + "_UpdateModul_.exe" )
              DeleteFile( *LHGameDB\Base_Path + "_UpdateModul_.exe" )
            EndIf
            
          *LHGameDB\ExitSignal			= #False
         
     EndProcedure 
    ;****************************************************************************************************************************************************
    ;       
     Procedure.i DB_Read_Check()
         
         If ( FindString( ExecSQL::GetColumns(DC::#Database_001,"Settings"), "dbsvn", 1, #PB_String_CaseSensitive ) = 0 ) 
             *LHGameDB\BaseSVNLoaded = "db000": ProcedureReturn 1
         EndIf    
         
         *LHGameDB\BaseSVNLoaded = ExecSQL::nRow(DC::#Database_001,"Settings","dbsvn"  ,"",1,"",1)  ;Lies die Version Number
         
         If ( *LHGameDB\BaseSVNLoaded  <> *LHGameDB\BaseSVNCurrent )
             ProcedureReturn 1
         EndIf 
         
         ProcedureReturn 0
         
     EndProcedure
    ;****************************************************************************************************************************************************
    ;    
    ; DB Lese Einstellungen
    ;          
    Procedure DB_Read_Config()
        
        Protected r.i
        
        
        If ( DB_Create::DB_IsOpen(DC::#Database_001) = #True)
            
            *LHGameDB\GameID              = Val(ExecSQL::nRow(DC::#Database_001,"Settings","GameID"           ,"",1,"",1))
            *LHGameDB\WindowHeight        = Val(ExecSQL::nRow(DC::#Database_001,"Settings","WindowHeight"     ,"",1,"",1))
            *LHGameDB\wScreenShotGadget   = Val(ExecSQL::nRow(DC::#Database_001,"Settings","wScreenShotGadget","",1,"",1)) ;Lies die Letzte Einstellung
            *LHGameDB\hScreenShotGadget   = Val(ExecSQL::nRow(DC::#Database_001,"Settings","hScreenShotGadget","",1,"",1)) ;Lies die Letzte Einstellung
            
            ; Check for Database Version
            If DB_Read_Check() = 1                
                r = Request::MSG( *LHGameDB\TitleVersion, "Update/Migration" ,"vSystems needs To update the Database" + #CRLF$ +
                                                                              "New Version: "  + *LHGameDB\BaseSVNCurrent +
                                                                              " You have: "    + *LHGameDB\BaseSVNLoaded,12)                
                If ( r = 1 )
                    End
                EndIf
                
                DB_Migrate::Prepare_Migrate()                
                Request::MSG( *LHGameDB\TitleVersion, "Update/Migration","Backup Database Successfull" + #CRLF$ + "File: " + GetFilePart(DB_Migrate::*LHBackupDB\Base_Game) ,2,0)                
                Prepare()                 
                
                *LHGameDB\BaseSVNMigrate   = #True
                
            EndIf                                       
        EndIf        
    EndProcedure
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 435
; FirstLine = 412
; Folding = -L+
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode