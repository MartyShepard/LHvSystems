
DeclareModule CLSMNU        
    
    Declare.l SetGetMenu_(GadgetID.i, WindowID.i, MenuPBID.i = #PB_Any, FlagsUINT.l=0, X.i=0, Y.i=0,  Layout.i=-1, MenuMode=0 ,TrackMenu = #False)
    Declare.l MenuItemSelect_(MenuEvntNum.i)
    
     Structure STRUCT_CLSMNUHANDLES      
        PB_MnuID.i[1] ; Purebasic MenuID
        HandleID.i[1] ; Der Handle der erstellt wird mit Create....
        LayoutID.i[1] ; Das Layout welches mit 'LAYOUT.i=XX' aufgerufen wird
        MnItemID.i[1] ; Die Id die von EventMenu() übergeben worde
        GadgetID.i[1] ; GadgetID, falls man diese zu einem menu Übergeben Muss
     EndStructure        
     Global *MNU.STRUCT_CLSMNUHANDLES = AllocateStructure(STRUCT_CLSMNUHANDLES)
    
    InitializeStructure(*MNU, STRUCT_CLSMNUHANDLES)

EndDeclareModule

Module CLSMNU      
    ;*******************************************************************************************************************************************************************
    ; Test Menu
    ; 
    Procedure Get_Layout_TestMenu()
        ;
        ; Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu
        ; Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu 
        Select *MNU\MnItemID[0]
            Case 1: Debug "OPEN"
            Case 2: Debug "Save"
            Case 3: Debug "Save as"
            Case 4: Debug "Quit"
            Case 5: Debug "PureBasic.exe"
            Case 6: Debug "Test.txt"
            Case 7: Debug "Open"
            Case 8: Debug "Save As"                        
            Case 9: Debug "Save As"                        
            Case 10: Debug "Close"                        
        EndSelect         
    EndProcedure    
    Procedure Set_Layout_TestMenu()        
        ;
        ; Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu
        ; Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu Test Menu                
        MenuItem(1, "Open")      ; Sie können alle Befehle zum Erstellen eines Menüs
        MenuItem(2, "Save")      ; verwenden, ganz wie bei einem normalen Menü...
        MenuItem(3, "Save as")
        MenuItem(4, "Quit")
        MenuBar()
        OpenSubMenu("Recent files")
        MenuItem(5, "PureBasic.exe")
        MenuItem(6, "Test.txt")
        CloseSubMenu()
        MenuTitle("Project")
        MenuItem(7, "Open"   +Chr(9)+"Ctrl+O")
        MenuItem(8, "Save"   +Chr(9)+"Ctrl+S")
        MenuItem(9, "Save as"+Chr(9)+"Ctrl+A")
        MenuItem(10, "Close"  +Chr(9)+"Ctrl+C")                
        ;
        ;______________________________________________________________________________________________________                
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ; Hier die LayoutID für das Menu angeben
    ;___________________________________________________________________________________________________________________________________________________________________    
    Procedure.l MenuItemSelect_(MenuEvntNum.i)
        
        *MNU\MnItemID[0] = MenuEvntNum
        
        Select *MNU\LayoutID[0]
                ;
                ; Holt sich aus den Menus den Befehle
            Case 0: INVMNU::Get_TrayMenu( *MNU\MnItemID.i[0])                
            Case 1: INVMNU::Get_ShotsMenu(*MNU\MnItemID.i[0],*MNU\GadgetID[0])
            Case 2: INVMNU::Get_PopMenu1( *MNU\MnItemID.i[0],*MNU\GadgetID[0])
            Case 3: INVMNU::Get_C64Menu(  *MNU\MnItemID.i[0],*MNU\GadgetID[0])                                    
            Case 4: INVMNU::Get_AppMenu(  *MNU\MnItemID.i[0],*MNU\GadgetID[0])  ; Vordefierte Programme    
            Case 5: ;INVMNU::Get_MainMnu(  *MNU\MnItemID.i[0],*MNU\GadgetID[0])  ; Hauptmenu  
            Default          
                Get_Layout_TestMenu()
        EndSelect        
        
        ;
        ; Nachdem alles 
        *MNU\HandleID[0] = 0
        *MNU\PB_MnuID[0] = 0
        *MNU\LayoutID[0] = 0
        *MNU\MnItemID[0] = -1
        ProcedureReturn *MNU\HandleID
    EndProcedure   
    ;*******************************************************************************************************************************************************************
    ; Hier die Layout's angeben siehe Set_Layout_TestMenu() 
    ;___________________________________________________________________________________________________________________________________________________________________
    Procedure MenuLayout_()
        Select *MNU\LayoutID[0]
            Case 0: INVMNU::Set_TrayMenu()
            Case 1: INVMNU::Set_ShotsMenu()                
            Case 2: INVMNU::Set_PopMenu1()                  
            Case 3: INVMNU::Set_C64Menu(*MNU\HandleID) ;Handle wird für die Checkmarks benötigt             
            Case 4: INVMNU::Set_AppMenu(*MNU\HandleID) ;Vordefierte Programme  
            Case 5: ;INVMNU::Set_MainMnu()              ; Hauptmenu 
            Default                
                Set_Layout_TestMenu() 
        EndSelect
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ;
    ;
    ; FlagsUINT ========================================================================================================================================================
    ; https://zsdn.microsoft.com/en-us/library/windows/desktop/ms647997(v=vs.85).aspx
    ; SInd schon In Purebasic drin
    ; TPM_CENTERALIGN         =   0x0004L  Centers the shortcut menu horizontally relative To the coordinate specified by the x parameter.
    ; TPM_RIGHTALIGN          =   0x0008L  Positions the shortcut menu so that its right side is aligned With the coordinate specified by the x parameter.  
    ; TPM_LEFTALIGN           =   0x0000L  Positions the shortcut menu so that its left side is aligned With the coordinate specified by the x parameter.   
    ; TPM_LEFTBUTTON          =   0x0000L  The user can Select menu items With only the left mouse button.
    ; TPM_RIGHTBUTTON         =   0x0002L  The user can Select menu items With both the left And right mouse buttons.    
    ; TPM_HORIZONTAL          =   $0000 
    ; TPM_RECURSE             =   $0001 ; Use the flag to display a menu when another menu is already displayed. This is intended to support context menus within a menu.
    ; TPM_VERTICAL            =   $0040 
    ; TPM_NONOTIFY            =   $0080 ; The function does not send notification messages when the user clicks a menu item.
    ; TPM_RETURNCMD           =   $0100 ; The function returns the menu item identifier of the user's selection in the return value.
    ; TPM_NOANIMATION         =   $4000 ; Displays menu without animation.
    ; TPM_BOTTOMALIGN         =   $0020 ; Positions the shortcut menu so that its bottom side is aligned with the coordinate specified by the y parameter
    ; TPM_TOPALIGN            =   $0000 ; Positions the shortcut menu so that its top side is aligned with the coordinate specified by the y parameter.
    ; TPM_VCENTERALIGN        =   $0010 ; Centers the shortcut menu vertically relative To the coordinate specified by the y parameter.
    #TPM_HORPOSANIMATION      =   $0400 ; Animates the menu from left to right.
    #TPM_HORNEGANIMATION      =   $0800 ; Animates the menu from right To left
    #TPM_VERPOSANIMATION      =   $1000 ; Animates the menu from top to bottom.
    #TPM_VERNEGANIMATION      =   $2000 ; Animates the menu from bottom to top.    
    
    Procedure CreateTrackMenu(MenuIDHnd,WindowID.i,GadgetID, Flags.i = 0, X.i = 0, Y.i = 0)
        Protected MenuFlags = 0          ;          
        
        GetWindowRect_(GadgetID(GadgetID),GadgetRect.RECT)                         
        X = GadgetRect\left + X
        Y = GadgetRect\top +  Y
        
        Select Flags
            Case 0
                MenuFlags + #TPM_TOPALIGN
        EndSelect       

        TrackPopupMenuEx_( MenuID(MenuIDHnd),  MenuFlags, X, Y , WindowID(WindowID.i), 0) 
        
        Handle.l = MenuIDHnd
        
        ProcedureReturn Handle        
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ; MenuLayout_Style (Style Menu) wird über das WaitwindowEvent aufgerufen
    ;
    ;
    ;
    ;
    ;Standard Menu
    ; GadgetID  = Die Purebaic ID von dem aus der Event gestartet wird (z.b Button), Wenn -1 wird #PB_Any genommen
    ; WindowID  = die FensterID auf dem der Menu Event ausgeführt wird
    ; MenuPBID  = die Purebasic MenuID (zb DC:.#MouseMenu), Wenn -1 wird #PB any genommen
    ; X/Y       = Die Position des Menus
    ; FlagsUINT = Siehe Oben #TPM_
    ; Layout    = Das MenuLayOut (Wird in *MNU\MnItemID[0] gesichertt)
    ; Menumode  = 0: Kein Menu
    ;           = 1:  Standard PB, CreateMenu
    ;           = 2:  Standard PB, CreateImageMenu
    ;           = 3:  Standard PB, CreatePopupImageMenu
    ;           = 4:  Standard PB, CreatePopupMenu    
    ;
    ; Trackmenu = Flase/True
    ;           = Erstellt ein TrackMenu mit den benötigten Angaben der GadgetID, Flags, MenuMode=4, Layout=[Num]
    ;
    ; Beispiel Event Loop
    ;
    ; Menu Events/ Handler
    ;   Case #PB_Event_SysTray
    ;     Select EvntType
    ;         Case #PB_EventType_RightClick
    ;             CLSMNU::SetGetMenu_(0,DC::#_Window_001, -1, 0, 0, 0, -1, 3)                         
    ;             
    ;         Case #PB_EventType_LeftClick
    ;     EndSelect     
    ; Case #PB_Event_Menu
    ;     CLSMNU::MenuItemSelect_(EvntMenu)    
    ;            
    Procedure.l SetGetMenu_(GadgetID.i, WindowID.i, MenuPBID.i = #PB_Any, FlagsUINT.l=0, X.i=0, Y.i=0,  Layout.i=-1, MenuMode=0 ,TrackMenu = #False)
        Protected GadgetRect.RECT, MousePoint.Point  

        *MNU\GadgetID[0] = GadgetID
        
        If (MenuPBID = #PB_Any)            
            *MNU\PB_MnuID[0] = #PB_Any
        Else
            *MNU\PB_MnuID[0] = MenuPBID
        EndIf
        
        ;
        ; Aktiviert das TrackMenuEx_
        If ( MenuMode = 0 )
        EndIf    
        
        ;
        ; Menu Modes (1-2 Sind Normale Menus, 3 + 4 sind Popupmenu)
        ; 0 ist ein TrackPopupMenuEx_
        Select MenuMode
            Case 0
            Case 1: *MNU\HandleID[0] = CreateMenu(*MNU\PB_MnuID[0], WindowID.i)   
            Case 2: *MNU\HandleID[0] = CreateImageMenu(*MNU\PB_MnuID[0],WindowID.i)                
            Case 3: *MNU\HandleID[0] = CreatePopupImageMenu(*MNU\PB_MnuID[0])                 
            Case 4: *MNU\HandleID[0] = CreatePopupMenu(*MNU\PB_MnuID[0])           
        EndSelect 
        
        ;
        ; Handle ist NULL, Sollte nicht passieren
        If ( *MNU\HandleID[0] = 0 )
            Debug "Das Menu Handle ist NULL"
        Else
            Debug "Menu Erfogreich geöffnet " + Str(*MNU\HandleID[0])
        EndIf    
        
        ;
        ; Sicherere das Layout 
        *MNU\LayoutID[0] = Layout
        
        ;
        ; Standard Purebasic Menu
        
        If ( MenuMode >= 1 And MenuMode <= 4 )
                           
               
            MenuLayout_()
            
            ;
            ; PopUp Menu anzeigen (Nur CreatePopupImageMenu & CreatePopupMenu)
            If ( MenuMode >= 3 And MenuMode <= 4 )
                
                If ( TrackMenu = #False )
                    DisplayPopupMenu(*MNU\HandleID[0], WindowID(WindowID)) 
                Else
                    *MNU\HandleID[0] = CreateTrackMenu(*MNU\HandleID[0], WindowID.i, GadgetID.i, FlagsUINT, X, Y)
                EndIf    
            EndIf    
        Else    
        EndIf
                
    EndProcedure
    
EndModule   
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 98
; FirstLine = 26
; Folding = z-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode