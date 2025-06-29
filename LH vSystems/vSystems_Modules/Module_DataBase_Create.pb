DeclareModule DB_Create
    
    Declare DB_Create_Game(BaseID,UniqeName$ = "Gamebase")    
    Declare DB_Create_Pict(BaseID,UniqeName$ = "GameShot")       
    
    Declare DB_First_Start(BaseID)
    Declare DB_IsOpen(BaseID)
    
EndDeclareModule



Module DB_Create
    ;***************************************************************************************************
    ;    
    ; Sicherheits Prüfung ob die Datenbak auch noch offen ist
    ;          
    Procedure.i DB_IsOpen(BaseID)
        If IsDatabase(BaseID)
            ProcedureReturn #True
        Else
            Request::MSG("vSystems", "FATAL ERROR","Database Not Open",2,-1,ProgramFilename())
            End
        EndIf    
    EndProcedure
    ;***************************************************************************************************
    ;    
    ; Start Einstellungen Setzen
    ;      
    Procedure DB_First_Start(BaseID)
        
        If ( DB_IsOpen(BaseID) = #True )
                        
;             For i = 0 To 1000000000000000
;                 ExecSQL::InsertRow(BaseID,"Gamebase", "GameTitle ", "Tayler Game " + Str(i))    
;             Next i
            ; Table Settings besitz nur Eine Zeile
            ExecSQL::InsertRow(BaseID,"Settings", "GameID", Str(1))                            ;*
            ExecSQL::UpdateRow(BaseID,"Settings", "WPosX" , Str(0),1)                           ;*
            ExecSQL::UpdateRow(BaseID,"Settings", "WPosY" , Str(0),1)                           ;*
            ExecSQL::UpdateRow(BaseID,"Settings", "dbsvn" , "db004",1)
            
        EndIf                        
    EndProcedure
    ;***************************************************************************************************
    ;    
    ; DB Create Game
    ;   
    Procedure Db_Create_Game(BaseID,UniqeName$ = "Gamebase")
        
        ;
        ;Table Erstellen
        ; 
        
        ExecSQL::CreateTable(BaseID,UniqeName$,#True)               ; Standard Master Datenbank
        ExecSQL::CreateTable(BaseID,"Settings",#True)               ; Enthält all Master Einstellungen
        ExecSQL::CreateTable(BaseID,"Platform",#True)               ; Enthält System (Windows, PSP etc..)
        ExecSQL::CreateTable(BaseID,"Programs",#True)               ; Entählt die Standard Programme (PcSX2, Dolphin etc..)
        ExecSQL::CreateTable(BaseID,"Language",#True)               ; Entählt Languages) 
        ExecSQL::CreateTable(BaseID,"SetFonts",#True)               ; Entählt Font Settings)          
                
        ;
        ; Columns Erstellen (Gamebase)
        ;
        ExecSQL::AddColumn(BaseID,UniqeName$,"id (INT,PRIMARY KEY)," +
                                             "GameTitle VARCHAR(255)," +
                                             "Publisher VARCHAR(255),"+
                                             "Developer VARCHAR(255),"+
                                             "Release DATE,"+
                                             "Version VARCHAR(255)," +                                              
                                             "LanguageID INT,"+
                                             "PlatformID INT," +                          ; ID wird aus dem Table Platform geholt
                                             "Compatibility_TXT TEXT,"+                                             
                                             "Compatibility_PRG INT," +
                                             "PC_Serial VARCHAR(255),"+
                                             "PortID INT,"+
                                             "MediaDev0 TEXT,"+
                                             "MediaDev1 TEXT,"+
                                             "MediaDev2 TEXT,"+
                                             "MediaDev3 TEXT,"+
                                             "FileDev0 TEXT,"+
                                             "FileDev1 TEXT,"+
                                             "FileDev2 TEXT,"+
                                             "FileDev3 TEXT,"+                                             
                                             "SplitHeight INT," +
                                             "EditWinH INT," +
                                             "EditWinW INT," +
                                             "EditWinX INT," +
                                             "EditWinY INT," +
                                             "EditSnap INT," +
                                             "WordWrap INT," +                                              
                                             "EditTxt1 TEXT," +
                                             "EditTxt2 TEXT," +                                              
                                             "EditTxt3 TEXT," +                                              
                                             "EditTxt4 TEXT," +  
                                             "EditTtl1 TEXT," +
                                             "EditTtl2 TEXT," +                                              
                                             "EditTtl3 TEXT," +                                              
                                             "EditTtl4 TEXT," +                                               
                                             "EditDat1 TEXT," +                                              
                                             "EditDat2 TEXT," +
                                             "EditDat3 TEXT," +                                             
                                             "EditDat4 TEXT" ,#True)
                                       
        
        
        ;
        ; Columns Erstellen (Einstellungen)
        ;
        ExecSQL::AddColumn(BaseID,"Settings","id (INT,PRIMARY KEY)," +
                                             "GameID INT," +
                                             "WPosX INT,"  +
                                             "WPosY INT,"   +
                                             "SortOrder INT," + 
                                             "SplitHeight INT," +
                                             "WindowHeight INT," +
                                             "wScreenShotGadget INT,"+
                                             "hScreenShotGadget INT,"+
                                             "C64Load$8 TEXT,"+
                                             "OpenCBMTools TEXT,"+
                                             "OpenCBMBPath TEXT,"+
                                             "Tab1 TEXT,"+
                                             "Tab2 TEXT,"+
                                             "Tab3 TEXT,"+
                                             "Tab4 TEXT,"+
                                             "TabAutoOpen INT,"+
                                             "DockWindow INT,"+
                                             "dbsvn TEXT",#True)


        
        ;
        ;
        ; Language
        ExecSQL::AddColumn(BaseID,"Language","id (INT,PRIMARY KEY),Locale TEXT",#True)   
        
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Australia")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Austria")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Brazil")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Canada")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","China")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Czech-Republic")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","European")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","France")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Germany")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","English/ DE")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","English/ JP")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Deutsch")                 
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Hong-Kong")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Italy")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Japan")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Japan-English")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Poland")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Russia")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Russia-English") 
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Spain")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Sweden")             
                ExecSQL::InsertRow(BaseID,"Language", "Locale","United-Kingdoms")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","United-States")      
                ExecSQL::InsertRow(BaseID,"Language", "Locale","United-States-Germany")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","World")  
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Turkey")                 
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Turkey-English")                 
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Iran")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Multi 2")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Multi 3")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Multi 4")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Multi 5")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Multi 6")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Multi 10")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","English")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,De")                  
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,De,Fr")                  
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,De,Fr,It")                  
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,De,Fr,It,Sp")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De,Es,It,Nl,Da")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De,Es,It,Nl")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De,Es,It")                
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De") 
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De")                 
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Fr,De")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De,Es,It,Nl,Pt,Sv,No,Da,Fi")
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De,Es,It,Nl,Sv")  
                ExecSQL::InsertRow(BaseID,"Language", "Locale","Fr,De,It")  
                ExecSQL::InsertRow(BaseID,"Language", "Locale","En,Fr,De,Es,It,Fi")                
  
          ;
                
                ExecSQL::AddColumn(BaseID,"Platform","id (INT,PRIMARY KEY), Platform TEXT",#True)
                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Amiga 500") ; (~1985)               
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Amiga 1200"); (~1986)                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Amiga CDTV"); (~1987)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Amiga CD32"); (~1988)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Apple iOS")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Apple Macintosh")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Arcade Machine")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari 2600")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari 5200")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari 7800")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari Jaguar")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari Jaguar CD")                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari Lynx")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari ST")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari MegaST")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Atari Falcon")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Coleco Vision")                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Commodore C64");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Commodore C128")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Commodore Vic20"); 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","FmTowns")        ;  
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Game Wave")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Gizmondo")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Google Android")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Intelli Vision")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Linux")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Magnavox Odyssey")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Magnavox Odyssey II") 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Microvision")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","MSX")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nec PC-FX")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nec PcEngine TGFX-16")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nec PcEngine TGFX-16 CD")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","NeoGeo")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","NeoGeo CD")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","NeoPocket")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","NeoPocket Color")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo 64")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo Entertainment System")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo GameBoy")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo GameBoy Color")                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo Gameboy Advance")                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo GameCube")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo SNES")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo VirtualBoy")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo Wii")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo Wii-U")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo 3DS")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo DS")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo DSi")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo Switch 1")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nintendo Switch 2")                  
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Nokia N-Gage")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Oric 1 Atmos")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Panasonic Real 3DO")
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC 8801")                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC 9801")                ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Booter");                   
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC MS-DOS"); (PC-DOS) (~1981)              
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 3.00"); (~1990)                  
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 3.10"); (~1992)                  
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 3.11"); (~1994)                 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 3.1"); (~1992)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows NT4"); (~1996)  
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 95"); (~1995-1997)                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 98"); (~1998-1999)                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows Me"); (~2000) 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 2000"); (~2000)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows XP"); (~2001) 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows Vista"); (~2007)                 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 7"); (~2009)                 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 8"); (~2012)                 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 10"); (~2015)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 11"); (~2021)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 12"); (~2026)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 13"); (~????)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 14"); (~2015)
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","PC Windows 15"); (~2015)                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega 32X")     ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega 32X CD")  ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega Dreamcast");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega GameGear") ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega Master System");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega Mega Drive")   ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega Mega Drive CD");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sega Saturn")       ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sharp X68000")      ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Playstation")  ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Playstation 2");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Playstation 3");                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Playstation 4");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Playstation 5");                
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Playstation Portable");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Sony Vita")                ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Spectravideo")             ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Texas Instruments TI-99-4A");
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","TRS-80, Coco")              ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Vectrex")                   ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Wonderswan")                ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Wonderswan Color")          ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","XBox 360")                  ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","XBox One")									;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","XBox Series S")							;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","XBox Series X")             ;                 
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","Xbox Classic")              ;
                ExecSQL::InsertRow(BaseID,"Platform", "Platform","ZX Spectrum");                
                
                ;
                ; Programms
                ;
                
                ExecSQL::AddColumn(BaseID,"Programs","id (INT,PRIMARY KEY),"+
                                                     "ExShort_Name TEXT," +
                                                     "Program_Description TEXT," +
                                                     "Path_Default VARCHAR(255)," +       ; Standard Arbeits Verzeichnis
                                                     "File_Default VARCHAR(255)," +       ; Standard Dateiname + Verzeichnis
                                                     "Args_Default VARCHAR(255)", #True)  ; Standard Argument (%s) << für ROM/IMAGE
                                             
        ;
        ; Columns Erstellen (FontSettings)
        ; ID ist Jeweils das Object
        ;
                ExecSQL::AddColumn(BaseID,"SetFonts","id (INT,PRIMARY KEY)," +  
                                                     "fnName TEXT," +       ; Der Fontname
                                                     "fnSize INT," +        ; Die grösse (Integer)
                                                     "fColor INT," +        ;Fontname Text Farbe
                                                     "Italic INT," +        ; Kursiv
                                                     "IsBold INT," +        ; Fett
                                                     "UnLine INT," +        ; Unterstrichen
                                                     "Strike INT," +        ; Durchgestrichen
                                                     "fontid INT", #True)   ; Die Purebasic Rückgabe ID
                
                
                
               ExecSQL::InsertRow(BaseID,"SetFonts", "fontid", "0" ) ; Title                                
               ExecSQL::InsertRow(BaseID,"SetFonts", "fontid", "0" ) ; ListIcon
               ExecSQL::InsertRow(BaseID,"SetFonts", "fontid", "0" ) ; Info Gadget 1
               ExecSQL::InsertRow(BaseID,"SetFonts", "fontid", "0" ) ; Info Gadget 2
               ExecSQL::InsertRow(BaseID,"SetFonts", "fontid", "0" ) ; Info Gadget 3
               ExecSQL::InsertRow(BaseID,"SetFonts", "fontid", "0" ) ; Info Gadget 4               
                
             
    EndProcedure 
    ;***************************************************************************************************
    ;    
    ; DB Create Pict
    ;  
    Procedure DB_Create_Pict(BaseID,UniqeName$ = "GameShot")
        
        ;
        ;Table Erstellen
        ; 
        
        ExecSQL::CreateTable(BaseID,UniqeName$,#True)               ; Standard Master Datenbank
        
       ;
        ; Columns Erstellen (Gamebase)
        ;
        ExecSQL::AddColumn(BaseID,UniqeName$,"id (INT,PRIMARY KEY)," +
                                             "BaseGameID INT," +
                                             "Shot1_Big BLOB," +
                                             "Shot2_Big BLOB," +
                                             "Shot3_Big BLOB," +
                                             "Shot4_Big BLOB," +
                                             "Shot5_Big BLOB," +
                                             "Shot6_Big BLOB," +
                                             "Shot7_Big BLOB," +
                                             "Shot8_Big BLOB," +
                                             "Shot9_Big BLOB," +
                                             "Shot10_Big BLOB," +
                                             "Shot11_Big BLOB," +
                                             "Shot12_Big BLOB," +
                                             "Shot13_Big BLOB," +
                                             "Shot14_Big BLOB," +
                                             "Shot15_Big BLOB," +
                                             "Shot16_Big BLOB," +
                                             "Shot17_Big BLOB," +
                                             "Shot18_Big BLOB," + 
                                             "Shot19_Big BLOB," +
                                             "Shot20_Big BLOB," +
                                             "Shot21_Big BLOB," +
                                             "Shot22_Big BLOB," +
                                             "Shot23_Big BLOB," +
                                             "Shot24_Big BLOB," +
                                             "Shot25_Big BLOB," +
                                             "Shot26_Big BLOB," +
                                             "Shot27_Big BLOB," +
                                             "Shot28_Big BLOB," +
                                             "Shot29_Big BLOB," +
                                             "Shot30_Big BLOB," +
                                             "Shot31_Big BLOB," +
                                             "Shot32_Big BLOB," +
                                             "Shot33_Big BLOB," +
                                             "Shot34_Big BLOB," +
                                             "Shot35_Big BLOB," +
                                             "Shot36_Big BLOB," +
                                             "Shot37_Big BLOB," +
                                             "Shot38_Big BLOB," +
                                             "Shot39_Big BLOB," +
                                             "Shot40_Big BLOB," +
                                             "Shot41_Big BLOB," +
                                             "Shot42_Big BLOB," +
                                             "Shot43_Big BLOB," +
                                             "Shot44_Big BLOB," +
                                             "Shot45_Big BLOB," +
                                             "Shot46_Big BLOB," +
                                             "Shot47_Big BLOB," +
                                             "Shot48_Big BLOB," +
                                             "Shot49_Big BLOB," +
                                             "Shot50_Big BLOB," +
                                             "Shot1_Thb BLOB," +
                                             "Shot2_Thb BLOB," +
                                             "Shot3_Thb BLOB," +
                                             "Shot4_Thb BLOB," +
                                             "Shot5_Thb BLOB," +
                                             "Shot6_Thb BLOB," +
                                             "Shot7_Thb BLOB," +
                                             "Shot8_Thb BLOB," +
                                             "Shot9_Thb BLOB," +
                                             "Shot10_Thb BLOB," +
                                             "Shot11_Thb BLOB," +
                                             "Shot12_Thb BLOB," +
                                             "Shot13_Thb BLOB," +
                                             "Shot14_Thb BLOB," +
                                             "Shot15_Thb BLOB," +
                                             "Shot16_Thb BLOB," +
                                             "Shot17_Thb BLOB," +
                                             "Shot18_Thb BLOB," +
                                             "Shot19_Thb BLOB," +
                                             "Shot20_Thb BLOB," +
                                             "Shot21_Thb BLOB," +
                                             "Shot22_Thb BLOB," +
                                             "Shot23_Thb BLOB," +
                                             "Shot24_Thb BLOB," +
                                             "Shot25_Thb BLOB," +
                                             "Shot26_Thb BLOB," +
                                             "Shot27_Thb BLOB," +
                                             "Shot28_Thb BLOB," +
                                             "Shot29_Thb BLOB," +
                                             "Shot30_Thb BLOB," +
                                             "Shot31_Thb BLOB," +
                                             "Shot32_Thb BLOB," +
                                             "Shot33_Thb BLOB," + 
                                             "Shot34_Thb BLOB," +
                                             "Shot35_Thb BLOB," +
                                             "Shot36_Thb BLOB," +
                                             "Shot37_Thb BLOB," +
                                             "Shot38_Thb BLOB," +
                                             "Shot39_Thb BLOB," +
                                             "Shot40_Thb BLOB," +
                                             "Shot41_Thb BLOB," +
                                             "Shot42_Thb BLOB," +
                                             "Shot43_Thb BLOB," +
                                             "Shot44_Thb BLOB," +
                                             "Shot45_Thb BLOB," +
                                             "Shot46_Thb BLOB," +
                                             "Shot47_Thb BLOB," +
                                             "Shot48_Thb BLOB," +
                                             "Shot49_Thb BLOB," +
                                             "Shot50_Thb BLOB," +
                                             "ThumbnailsW INT," +
                                             "ThumbnailsH INT",True)   
        
    EndProcedure    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 241
; FirstLine = 42
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode