DeclareModule WinGuru
    
    
    Declare Center(WindowID.l, W.i=0, H.i=0,ParentWindowID = 0)
    
    Declare.l ThemeImg(WindowID.l, ImageID.l)
    Declare.l ThemeBox(WindowID.l, W.i, H.i, SetPosX.i, SetPosY.i, BC.l = $1F1F1F, DrawModeFlag.l = #PB_2DDrawing_Default, Gadget_ID = 0)
    Declare SetTransparenz(WindowID.i,AlphaValue.l = 255)  
    Declare WindowPosition(WindowID.l,X.i,Y.i,OnSet = #True, OnGetX.i = #False, OnGetY.i = #False, Flags.l = #HWND_TOP)
    Declare.i Style(WindowID.i,x.i = 0,y.i = 0,W.i = 1280,H.i = 720,Flags.i = 0, BC.l = $1F1F1F, UseWC.i = #False, UseBox.i = #False, UseGWLEX.i = #False, FlagsEX.l = #Null, UseNOF.i = #False,UseSmart.l = #False, ParentID.i = 0, BoxC.l = $1F1F1F)
    Declare.i StyleSkin(WindowID.i, ImageID.l, x.i = 0, y.i = 0,Flags.i = 0, BC.l = #Black, ParentID.i = 0,UseSmart.l = #False, AttrKey.l = #LWA_COLORKEY, AlphaValue.l = 0)
    Declare.i  Transform_Resize(hwnd)
    
EndDeclareModule


Module WinGuru
    
    #CCHILDREN_TITLEBAR = 5 
    
    Structure MONITORINFOEXA
        cbSize.l
        rcMonitor.RECT
        rcWork.RECT
        dwFlags.l
        szDevice.s {#CCHDEVICENAME}
    EndStructure
    
    Structure TITLEBARINFO
        cbSize.l
        rcTitleBar.RECT
        rgstate.l[#CCHILDREN_TITLEBAR+1]
    EndStructure
        
        
    ;************************************************************************************************************************
    ; Zentriert das Fenster auf Mult Monitor Systemen
    ;       
    Procedure Center(WindowID.l, W.i=0, H.i=0,ParentWindowID = 0)
        
        Protected Left, Top, HMONITOROLD, TitleHeight.i
        
        Define pt.Point
        
        If GetCursorPos_(@pt)
            HMONITOR = MonitorFromPoint_(PeekQ(@pt), #MONITOR_DEFAULTTONEAREST)
            If IsWindow(WindowID)
                HPRIMIRY = MonitorFromPoint_(WindowID(WindowID), #MONITOR_DEFAULTTOPRIMARY)
            Else
                HPRIMIRY = MonitorFromPoint_(WindowID, #MONITOR_DEFAULTTOPRIMARY)
            EndIf    
            If HMONITOR = HMONITOROLD
                ProcedureReturn #False
            Else
                HMONITOROLD = HMONITOR
            EndIf    
        EndIf
        
        
        pti.TITLEBARINFO\cbSize = SizeOf(TITLEBARINFO)
        TitleHeight = pti\rcTitleBar\bottom-pti\rcTitleBar\top        
        
        Define mi.MONITORINFOEXA
        
        mi\cbSize = SizeOf(mi)
        
        If GetMonitorInfo_(HMONITOR, @mi)
            
            If HPRIMIRY = HMONITOR
                SystemParametersInfo_(#SPI_GETWORKAREA,0,@DesktopWorkArea.RECT,0)
                
                ProcessEX::TaskListCreate(): iTaskLeiste.l = ProcessEX::TaskListGetPID("explorer.exe")
                If (iTaskLeiste.l <> 0)
                    mi\rcMonitor\left   = DesktopWorkArea\left
                    mi\rcMonitor\right  = DesktopWorkArea\right - DesktopWorkArea\left
                    mi\rcMonitor\top    = DesktopWorkArea\top
                    mi\rcMonitor\bottom = DesktopWorkArea\bottom - DesktopWorkArea\top
                    
                    mi\rcMonitor\right  = mi\rcMonitor\right - GetSystemMetrics_(#SM_CXFIXEDFRAME)*2
                    mi\rcMonitor\bottom = mi\rcMonitor\bottom - (GetSystemMetrics_(#SM_CYCAPTION) + GetSystemMetrics_(#SM_CYFIXEDFRAME)*2)
                EndIf
            EndIf   
            
            
            Left = mi\rcMonitor\left + (mi\rcMonitor\right  - mi\rcMonitor\left - W) / 2
            Top  = mi\rcMonitor\top  + (mi\rcMonitor\bottom - mi\rcMonitor\top  - H) / 2
           ; Left = mi\rcMonitor\right / 2
           ; Top  = mi\rcMonitor\bottom / 2            
            
            ;Left/ 2
            ;Top / 2 
            If (Top <= -1)
                Top = 0
            EndIf            
            
            If (ParentWindowID <> 0): WindowID = ParentWindowID: EndIf    
            If IsWindow(WindowID.l)
                SetWindowPos_(WindowID(WindowID.l), #HWND_TOPMOST, Left, Top, 0, 0,#SWP_NOSIZE | #SWP_NOZORDER | #SWP_NOACTIVATE)
                SetActiveWindow(WindowID.l)
            Else    
                SetWindowPos_(WindowID.l, #HWND_TOPMOST, Left, Top, 0, 0,#SWP_NOSIZE | #SWP_NOZORDER | #SWP_NOACTIVATE)
            EndIf    
            
            
        Else
            ProcedureReturn #False
        EndIf
        
        ProcedureReturn #True
    EndProcedure   
    
    ;***************************************************************************************************
    ;   
    ; Set Window Theme Image Background
    ;    
    Procedure.l ThemeImg(WindowID.l, ImageID.l)
        
        Protected hBrush, hImage = #False, hWnd
        
        If IsWindow(WindowID.l)
            
            hWnd = WindowID(WindowID.l)
            
            If IsImage(ImageID)
                hImage = ImageID(ImageID)
            Else
                If ImageID : hImage = ImageID : EndIf
            EndIf
            
            If hWnd And hImage
                hBrush = CreatePatternBrush_(hImage)
                SetClassLongPtr_(hWnd, #GCL_HBRBACKGROUND, hBrush)
                InvalidateRect_(hWnd, #Null, #True)
                UpdateWindow_(hWnd)
                ProcedureReturn #True
            EndIf
        EndIf        
        ProcedureReturn #False
        
    EndProcedure
    
    ;***************************************************************************************************
    ;   
    ; Set Window Theme Image Background
    ;          
    Procedure.l ThemeBox(WindowID.l, W.i,H.i,SetPosX.i,SetPosY.i,BC.l = $1F1F1F,DrawModeFlag.l = #PB_2DDrawing_Default, Gadget_ID = 0)
        
        Protected BoxImage.l, FrameImage.l
        ;      
        If ( Gadget_ID = 0 )
            Gadget_ID = #PB_Any: BoxImage.l = CreateImage(Gadget_ID, W, H)
        Else
            CreateImage(Gadget_ID, W, H): BoxImage = Gadget_ID
        EndIf    

        
        
        If IsImage(BoxImage.l)
            StartDrawing(ImageOutput(BoxImage.l))
            Box(0, 0, W, H, BC.l): DrawingMode(DrawModeFlag.l)
            StopDrawing()
            FrameImage = ImageGadget(Gadget_ID,SetPosX, SetPosY,W, H, ImageID(BoxImage)) 
            
            If IsGadget(FrameImage)
                DisableGadget(FrameImage,1): ProcedureReturn FrameImage          
            EndIf
            
            If IsGadget(BoxImage)
                DisableGadget(BoxImage,1): ProcedureReturn BoxImage          
            EndIf           
        EndIf            
        ProcedureReturn 0
    EndProcedure    
    
    ;************************************************************************************************************************
    ; Standard Fenster
    ;     
    ;   #PB_Window_SystemMenu    : Schaltet DAS System-Menü IN der Fenster-Titelzeile ein. (Standard)
    ;   #PB_Window_MinimizeGadget: Fügt DAS Minimieren-Gadget der Fenster-Titelzeile hinzu.
    ;                              #PB_Window_SystemMenu wird automatisch hinzugefügt.
    ;   #PB_Window_MaximizeGadget: Fügt DAS Maximieren-Gadget der Fenster-Titelzeile hinzu.
    ;                              #PB_Window_SystemMenu wird automatisch hinzugefügt.
    ;                              (nur auf MacOS: #PB_Window_SizeGadget wird ebenfalls automatisch hinzugefügt)
    ;   #PB_Window_SizeGadget    : Fügt DAS Größenänderungs-Gadget zum Fenster hinzu.
    ;   #PB_Window_Invisible     : Erstellt ein Fenster, zeigt es aber nicht an.
    ;   #PB_Window_TitleBar      : Erstellt ein Fenster mit einer Titelzeile.
    ;   #PB_Window_Tool          : Erstellt ein Fenster mit einer schmaleren Titelzeile und ohne Taskleisten-Eintrag.
    ;   #PB_Window_BorderLess    : Erstellt ein Fenster ohne jegliche Ränder.
    ;   #PB_Window_ScreenCentered: Zentriert DAS Fenster IN der Mitte des Bildschirms. Die Parameter x,y werden ignoriert.
    ;   #PB_Window_WindowCentered: Zentriert DAS Fenster IN der Mitte des übergeordneten Fensters ("parent window" - 
    ;                              'ParentWindowID' muss dazu angegeben werden). Die Parameter x,y werden ignoriert.
    ;   #PB_Window_Maximize      : Öffnet DAS Fenster maximiert. (Hinweis: Unter Linux unterstützen dies nicht alle
    ;                              Window-Manager.)
    ;   #PB_Window_Minimize      : Öffnet DAS Fenster minimiert.
    ;   #PB_Window_NoGadgets     : Verhindert DAS Erstellen einer Gadgetliste. UseGadgetList() kann verwendet werden, um dies später zu tun.
    ;   #PB_Window_NoActivate    : Aktiviert DAS Fenster nach dem Öffnen nicht.
    ;
    ;   $5A5A5A RGB(90,90,90)
    ;   
    ;   UseWC    = SetwindowColor
    ;   UseBox   = Draw Box (Unten und Oben)
    ;   UseGWLEX = Set #GWL_EXSTYLE
    ;   FlagsEX  = Nur inVerbindung mit #GWL_EXSTYLE
    Procedure Style_Limit(WindowID.i,MinW.i,MinH.i,MaxW.i,MaxH.i)
        WindowBounds(WindowID,MinW.i,MinH.i,MaxW.i,MaxH.i)
    EndProcedure 
    
    ;***************************************************************************************************
    ;   
    ; Style Window
    ;     
    Procedure.i Style(WindowID.i,x.i = 0,y.i = 0,W.i = 1280,H.i = 720,Flags.i = 0, BC.l = $1F1F1F, UseWC.i = #False, UseBox.i = #False, UseGWLEX.i = #False, FlagsEX.l = #Null, UseNOF.i = #False,UseSmart.l = #False, ParentID.i = 0, BoxC.l = $1F1F1F)
        
        Protected Result, BoxGadget.i
        
        If (X = 0 And Y = 0)
            Flags = Flags + #PB_Window_ScreenCentered 
        EndIf
       
        Result = OpenWindow(WindowID, x, y, w, h , "", Flags, ParentID)
        
        If (Result <> 0)                            
            
            If (UseWC.i = #True)
                SetWindowColor(WindowID.i, BC.l)
            EndIf    
            
            If (UseBox.i = #True)                
                BoxGadget = ThemeBox(WindowID,W.i, 30, 0, 0, BoxC.l)            
                BoxGadget = ThemeBox(WindowID,W.i, 30, 0, H.i-30, BoxC.l)
            EndIf                            
            
            If (UseGWL.i = #True)
                ;SetWindowLong_(WindowID(WindowID),#GWL_EXSTYLE,#WS_EX_APPWINDOW|FlagsEX.l) 
            EndIf 
            
            If (UseNOF.i = #True)
                SetWindowLongPtr_(WindowID(WindowID), #GWL_STYLE, GetWindowLongPtr_(WindowID(WindowID), #GWL_STYLE) | #WS_CLIPCHILDREN|#WS_CLIPSIBLINGS )
            EndIf 
            
            Style_Limit(WindowID.i,W,H,#PB_Ignore ,#PB_Ignore )              
            SmartWindowRefresh(WindowID.i, UseSmart.l )
        Else
            Debug "Fatal Error - Could Not Open Main Window"
            End
        EndIf                            
    EndProcedure
    
    ;***************************************************************************************************
    ;   
    ; Style Window Temded
    ;         
    Procedure StyleSkin(WindowID.i, ImageID.l, x.i = 0, y.i = 0,Flags.i = 0, BC.l = #Black, ParentID.i = 0,UseSmart.l = #False, AttrKey.l = #LWA_COLORKEY, AlphaValue.l = 0)
        
        If IsImage(ImageID)    
            
            If (X = 0 And Y = 0)
                Flags = Flags + #PB_Window_ScreenCentered 
            EndIf            
            
            Result = OpenWindow(WindowID, x, y, ImageWidth(ImageID), ImageHeight(ImageID) , "", Flags, ParentID)
            
            If (Result <> 0)        
                
                SetWindowColor(WindowID, BC)
  
                SetWindowLongPtr_(WindowID(WindowID),#GWL_EXSTYLE,GetWindowLongPtr_(WindowID(WindowID),#GWL_EXSTYLE)|#WS_EX_LAYERED);#WS_CLIPSIBLINGS)    ;
                SetLayeredWindowAttributes_(WindowID(WindowID),BC,AlphaValue,AttrKey)
  
                ImageObject = ImageGadget(#PB_Any,0,0,w,h,ImageID(ImageID))
                DisableGadget(ImageObject,1)
                
                Style_Limit(WindowID.i,W,H,#PB_Ignore ,#PB_Ignore )    
                SmartWindowRefresh(WindowID.i, UseSmart.l )
                ; #WS_EX_LAYERED
                ; #WS_EX_WINDOWEDGE
                ; #WS_EX_CONTROLPARENT
                ; #WS_EX_APPWINDOW
            EndIf
        EndIf    

  
EndProcedure  

    ;***************************************************************************************************
    ;   
    ; SetTransparenz Window
    ;      
    Procedure SetTransparenz(WindowID.i,AlphaValue.l = 255)        
        
        SetWindowLongPtr_(WindowID(WindowID),#GWL_EXSTYLE,GetWindowLongPtr_(WindowID(WindowID),#GWL_EXSTYLE) | #WS_EX_LAYERED)
        
        If AlphaValue >= 255
            AlphaValue = 255
        EndIf
        
        AlphaValue = Abs(AlphaValue)
        
        SetLayeredWindowAttributes_(WindowID(WindowID), 0,  AlphaValue, #LWA_ALPHA)           
    EndProcedure    
    ;***************************************************************************************************
    ;   
    ; Change WindowPosition
    ;     
    Procedure.i WindowPosition(WindowID.l,X.i,Y.i,OnSet = #True, OnGetX.i = #False, OnGetY.i = #False, Flags.l = #HWND_TOP)
        Protected DeskH.i, DeskW.i, CXVW.i, CXVY.i
        
        DeskH = WindowHeight(WindowID,#PB_Window_InnerCoordinate)
        DeskW = WindowWidth(WindowID ,#PB_Window_InnerCoordinate) 
        
        If (OnSet = #True)  
            
            If (X = -1 And Y = -1) Or  (X = 0 And Y = 0)                               
                Center(WindowID.l, DeskW, DeskH): ProcedureReturn
                
            Else       
                CXVW = GetSystemMetrics_(#SM_CXVIRTUALSCREEN)
                CXVY = GetSystemMetrics_(#SM_CYVIRTUALSCREEN)
                
                If (X >= CXVW)
                    Center(WindowID.l, DeskW, DeskH): ProcedureReturn
                Else
                    If (Y >= CXVY)
                        Center(WindowID.l, DeskW, DeskH): ProcedureReturn
                    Else    
                        SetWindowPos_((WindowID(WindowID)),Flags.l, X , Y , DeskW, DeskH, #NUL)
                        ProcedureReturn
                   EndIf                     
                EndIf
            EndIf     
        EndIf
        
        If (OnGetX = #True)
            X = WindowX(WindowID): ProcedureReturn X
        EndIf
        
        If (OnGetY = #True)
            Y = WindowY(WindowID): ProcedureReturn Y
        EndIf          

    EndProcedure    
    ;***************************************************************************************************
    ;   
    ; Verändert in der Laufzeit des Fenster die Eigenschaft das man es "Resizen" kann
    ;       
    Procedure.i Transform_Resize(hwnd)
        Protected PBWindowID.l
        
        PBWindowID = hwnd
        If IsWindow(hwnd)
            PBWindowID = WindowID(hwnd)
        EndIf                    
        
        SetWindowLongPtr_(PBWindowID,#GWL_STYLE,GetWindowLongPtr_(PBWindowID,#GWL_STYLE) !#WS_SIZEBOX | #WS_VISIBLE)      
        If ( GetWindowLongPtr_(PBWindowID,#GWL_STYLE) = 2525757440 )
            ProcedureReturn #True
        EndIf
        ProcedureReturn #False        
    EndProcedure
EndModule    
    
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 233
; FirstLine = 149
; Folding = H0
; EnableAsm
; EnableXP
; EnableUnicode