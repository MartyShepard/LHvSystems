DeclareModule SSTTIP
    
        
    ;
    ;
    ; ToolTipMode: 0-Normal, 1-Purebasic Default, 2-Chnage Text,3-Hide, 4-Remove, 5-Show      
    Declare TooltTip(WindowID, ObjectID, Text$ , Title$, TIcon=0, TextWidth=500, ToolTipMode=0, TF=0,BallonType=#False,CFrt=$00FFFFFF, CBck=$00FF0000, YPosition = 0)   
    
    Declare.l ToolTipEx(WindowID.i,
                         Gadget.i,
                         Text.s       = "",
                         Title.s      = "",
                         IconHandle.l = 0,
                         TextWidth.i  = 500,
                         ToolTipMode.i= 0,
                         FontID.l     = 0,
                         Ballon.b     = #False,
                         TextColor.l  = $00FFFFFF,
                         BackColor.l  = $00FF0000,
                         YPosition.i  = 0,
                         ImagePath.s  = "",
                         ImageHandle.l= 0)
      
    
    Declare.s ToolTipMode(Modus=1,ToolTipID=0,Text$="")
    Declare.s ToolTipModeEx(Modus=1,ToolTipID=0,Text$="")    
    Declare ToolTipFont(ToolTipID,FontType.l)
    Declare.l Tooltip_TrayIcon(File$, TrayID.i, Window.i, IconDescription$="", Command.i = 0) 
    Declare BalloonInfo(WindowID, Text$ , Title$, Icon, PosX, PosY, MaxWidth,pMonitor)
    Global Dim PtrToolTip(4000)
    
    
EndDeclareModule



Module SSTTIP
    
    #LVM_FIRST = $1000
    #LVM_GETTOOLTIPS = (#LVM_FIRST + 78)
    Structure STRUCT_TOOLTIPHANDLES      
        Tool_Tip.i[4096]
        ObjectID.i[4096]                 
    EndStructure        
    Global *TT.STRUCT_TOOLTIPHANDLES = AllocateStructure(STRUCT_TOOLTIPHANDLES)
    InitializeStructure(*TT, STRUCT_TOOLTIPHANDLES)
    
    Structure ToolTipData
      hToolTip.i
      hImage.i          ; PureBasic Image ID
      ImagePath.s
      Gadget.i
    EndStructure

    Global NewList ToolTips.ToolTipData()
  
Procedure MAKELONG(low, high)
  ProcedureReturn low | (high<<16)
EndProcedure

Procedure BalloonInfo(WindowID, Text$ , Title$, Icon, PosX, PosY, MaxWidth, pMonitor)
    
    Define EventID
    Define TT
    
    #TTF_ABSOLUTE = $0080
    #TTF_TRACK = $0020
    #TTS_CLOSE = $80

    Protected ToolTip
    Protected Balloon.TOOLINFO
  
  ToolTip=CreateWindowEx_(#WS_EX_TOPMOST,#TOOLTIPS_CLASS,#Null,#WS_POPUP | #TTS_NOPREFIX | #TTS_ALWAYSTIP | #TTS_BALLOON | #TTS_CLOSE,0,0,0,0,WindowID,0,GetModuleHandle_(0),0)
  
  ExamineDesktops()

  SendMessage_(ToolTip,#TTM_SETTIPTEXTCOLOR,GetSysColor_(#COLOR_INFOTEXT),0)
  SendMessage_(ToolTip,#TTM_SETTIPBKCOLOR,GetSysColor_(#COLOR_INFOBK),0)
  SendMessage_(ToolTip,#TTM_SETMAXTIPWIDTH,0,MaxWidth)
  SendMessage_(ToolTip,#TTM_SETDELAYTIME,0,0)
  SendMessage_(ToolTip, #TTM_TRACKPOSITION, 0, MAKELONG(DesktopWidth(pMonitor)-150,DesktopHeight(pMonitor)-80 ))
  
  If Title$ > ""
    SendMessage_(ToolTip, #TTM_SETTITLE, Icon, @Title$)
  EndIf
  
  Balloon.TOOLINFO\cbSize=SizeOf(TOOLINFO)
  Balloon\uFlags=#TTF_IDISHWND  | #TTF_ABSOLUTE | #TTF_TRACK
  Balloon\hwnd=WindowID
  Balloon\uId=WindowID
  Balloon\lpszText=@Text$
  Balloon\hinst = GetModuleHandle_(0)
  
  GetWindowRect_(WindowID,@Balloon\rect)
  SendMessage_(ToolTip, #TTM_ADDTOOL, 0, @Balloon)
  SendMessage_(ToolTip, #TTM_TRACKACTIVATE, 1, @Balloon)
  
  ProcedureReturn ToolTip
  
EndProcedure  

;**************************************************************************************************
;
; ToolTipMode, Text ändern, entfernen, Permanent anzeigen
; 0 - Change Text
; 1 - Hide
; 2 - Remove
; 3 - Permanet Show 
; 5 - show    
; TooltipID = GadgetNummer
Procedure.s ToolTipMode(Modus=1,ToolTipID=0,Text$="")
    
    Protected ToolTip.i, Rect.rect, Pt.point, GetString$, *MemoryID, Buffer$
    
    If Not IsGadget(ToolTipID)
        Debug "ERROR ToolTipMode: Die GadgetID für DAS Tooltip wurde Nicht gefunden oder ist nicht mehr aktiv. GadgetID: "+Str(ToolTipID)
        ProcedureReturn
    EndIf
    
    For i = 0 To 4095
        If *TT\ObjectID[i] = ToolTipID
            
            ToolTip.i = *TT\Tool_Tip[i];Toolip Handle
            Break                    ;
        EndIf
    Next   
    If (ToolTip.i <> 0)
        
                TTIP.TOOLINFO\cbSize = SizeOf(TOOLINFO) 
                TTIP\hWnd            = GadgetID(ToolTipID) 
                TTIP\uId             = GadgetID(ToolTipID)        
        Select Modus    
                ;
                ;
                ;
            Case 0 
                  TTIP\lpszText = @Text$
                  SendMessage_(ToolTip, #TTM_UPDATETIPTEXT, 0, TTIP)
                ProcedureReturn ""
                ;
                ;
                ;
            Case 1
                SendMessage_(ToolTip, #TTM_TRACKACTIVATE, 0,TTIP) 
                ProcedureReturn ""
                ;
                ;
                ;
            Case 2
                SendMessage_(ToolTip, #TTM_DELTOOL, 0, TTIP) 
                For i = 0 To 4095
                    If *TT\ObjectID[i]  =ToolTipID
                        *TT\ObjectID[i] =0
                        *TT\Tool_Tip[i] =0
                        Break                    ;
                    EndIf
                Next
                ProcedureReturn ""
                ;
                ;
                ;
            Case 3           
                GetClientRect_(GadgetID(ToolTipID), @Rect)
                Pt\x = Rect\left - 1
                Pt\y = Rect\bottom
                ClientToScreen_(GadgetID(ToolTipID), @Pt)                    
                
                SendMessage_(ToolTip, #TTM_TRACKACTIVATE, 1, TTIP) 
                SetWindowPos_(GadgetID(ToolTipID) , 0, Pt\x,Pt\y, -1, -1, #SWP_NOSIZE | #SWP_NOZORDER | #SWP_SHOWWINDOW | #SWP_NOACTIVATE)
                ProcedureReturn ""
                ;
                ;
                ;
            Case 4                
                Buffer$ = Space(#MAX_PATH)
                With TTIP
                    \lpszText = @Buffer$                  
                EndWith                               
                
                SendMessage_(ToolTip, #TTM_GETTEXTW, 0,TTIP) 

                ProcedureReturn Buffer$                           
                ;
                ;
                ;
            Case 5
                SendMessage_(ToolTip, #TTM_TRACKACTIVATE, 1,TTIP) 
                ProcedureReturn ""
        EndSelect    
    EndIf         
EndProcedure
Procedure.s ToolTipModeEx(Modus = 1, ToolTipID.i = 0, szText$ = "")
    
    Protected hTip.l, Rect.rect, Pt.point, GetString$, *MemoryID, Buffer$
    
    If Not IsGadget(ToolTipID)
        Debug "ERROR ToolTipMode: Die GadgetID für DAS Tooltip wurde Nicht gefunden oder ist nicht mehr aktiv. GadgetID: "+Str(ToolTipID)
        ProcedureReturn
    EndIf
    
  ; Falls schon ein Tooltip für dieses Gadget existiert → ändern
    ForEach ToolTips()
      If ToolTips()\Gadget = ToolTipID
          hTip = ToolTips()\hToolTip
        Break
      EndIf
    Next
    
    If (hTip <> 0)
        
                TTIP.TOOLINFO\cbSize = SizeOf(TOOLINFO) 
                TTIP\hWnd            = GadgetID(ToolTipID) 
                TTIP\uId             = GadgetID(ToolTipID)        
        Select Modus    
                ;
                ;
                ;
          Case 0
                  TTIP\lpszText = @szText$
                  SendMessage_(hTip, #TTM_UPDATETIPTEXT, 0, TTIP)
                ProcedureReturn ""
                ;
            Case 1
                SendMessage_(hTip, #TTM_TRACKACTIVATE, 0,TTIP) 
                ProcedureReturn ""
                ;
                ;
                ;
              Case 2
                SendMessage_(hTip, #TTM_DELTOOL, 0, TTIP) 
                ForEach ToolTips()
                  If ToolTips()\Gadget = ToolTipID
                    DestroyWindow_(ToolTips()\hToolTip)
                    If ToolTips()\hImage
                      FreeImage(ToolTips()\hImage)
                    EndIf
                    DeleteElement(ToolTips())
                    Break
                  EndIf
                Next
                ProcedureReturn ""
                ;
                ;
                ;
            Case 3           
                GetClientRect_(GadgetID(ToolTipID), @Rect)
                Pt\x = Rect\left - 1
                Pt\y = Rect\bottom
                ClientToScreen_(GadgetID(ToolTipID), @Pt)                    
                
                SendMessage_(hTip, #TTM_TRACKACTIVATE, 1, TTIP) 
                SetWindowPos_(GadgetID(ToolTipID) , 0, Pt\x,Pt\y, -1, -1, #SWP_NOSIZE | #SWP_NOZORDER | #SWP_SHOWWINDOW | #SWP_NOACTIVATE)
                ProcedureReturn ""
                ;
                ;
                ;
            Case 4                
                Buffer$ = Space(#MAX_PATH)
                With TTIP
                    \lpszText = @Buffer$                  
                EndWith                               
                
                SendMessage_(hTip, #TTM_GETTEXTW, 0,TTIP) 

                ProcedureReturn Buffer$                           
                ;
                ;
                ;
            Case 5
                SendMessage_(hTip, #TTM_TRACKACTIVATE, 1,TTIP) 
                ProcedureReturn ""
        EndSelect    
    EndIf         
EndProcedure

Procedure ToolTipFont(ToolTipID,FontType.l)
    
        Protected ToolTip.i, Rect.rect, Pt.point, GetString$, *MemoryID
    
    If Not IsGadget(ToolTipID)
        Debug "ERROR ToolTipMode: GadgetID für DAS Tooltip Nicht gefunden. ID: "+Str(ToolTipID)
        ProcedureReturn
    EndIf
    
    If FontType.l = 0
        Debug "ERROR ToolTipMode: GadgetID für DAS Tooltip Nicht gefunden. ID: "+Str(ToolTipID)
        ProcedureReturn
    EndIf
    
    For i = 0 To 100
        If *TT\ObjectID[i] = ToolTipID
            
            ToolTip.i = *TT\Tool_Tip[i];Toolip Handle
            Break                    ;
        EndIf
    Next   
    If (ToolTip.i <> 0)
        
                TTIP.TOOLINFO\cbSize = SizeOf(TOOLINFO) 
                TTIP\hWnd            = GadgetID(ToolTipID) 
                TTIP\uId             = GadgetID(ToolTipID)    
                SendMessage_(ToolTip, #WM_SETFONT, FontID(FontType.l), #True) 
     EndIf           
EndProcedure    

;**************************************************************************************************
;
; Tooltip Hinzufügen  0-Normal, 1-Alternate
;        
; -  WindowID    = WindowID(XXX)
; -  ObjectID    = Gadget 'ohne GadgetID()' 
; -  Text$       = Der String
; -  Title$      = Title Text
; -  TIcon       = ToolTip Icon
; -  TextWidth   = Text weite
; -  ToolTipMode = Mode 0: Erweiterte Variante, Modus 1: PB Version
; -  TF          = Font 'FontID()'
; -  BallonType  = Ja,Nein
; -  CFrt        = Front Farbe
; -  CBck        = Back  Farbe               
Procedure TooltTip (WindowID, ObjectID, Text$ , Title$, TIcon=0, TextWidth=500, ToolTipMode=0, TF=0,BallonType=#False,CFrt=$00FFFFFF, CBck=$00FF0000, YPosition = 0); 
    
    Protected ToolTip.i
    
    If Not IsGadget(ObjectID)
        Debug "Tooltip für Gadget Nummer :"+Str(ObjectID)+" nicht Initialisiert"
        ProcedureReturn    
    EndIf   
    Select ToolTipMode
        Case 0
            
            
            For i = 0 To 4095
                If *TT\ObjectID[i] = ObjectID
                    
                    ProcedureReturn
                    Break                      ;
                EndIf
            Next 
    
            If BallonType=#True   ;/ Ballon
                BallonType  = #WS_POPUP|#TTS_ALWAYSTIP|#TTS_NOPREFIX|#TTS_BALLOON
            Else      ;/ Or Square
                BallonType  = #WS_EX_TRANSPARENT|#WS_POPUP|#WS_POPUPWINDOW|#TTS_NOPREFIX|#TTS_ALWAYSTIP
            EndIf
            
            ToolTip.i = CreateWindowEx_(0,"ToolTips_Class32","",BallonType,0,0,0,0,WindowID,0,GetModuleHandle_(0),0)
            
            
            
            SendMessage_(ToolTip, #TTM_SETTIPTEXTCOLOR, CFrt,0) ;GetSysColor_(#COLOR_INFOTEXT), 0)
            SendMessage_(ToolTip, #TTM_SETTIPBKCOLOR,   CBck,0) ;GetSysColor_(#COLOR_INFOBK), 0) 
            
            Balloon.TOOLINFO\cbSize=SizeOf(TOOLINFO)
            Balloon\uFlags  = #TTF_IDISHWND | #TTF_SUBCLASS 
            SendMessage_(ToolTip,#TTM_SETMAXTIPWIDTH,0,TextWidth)
            
            Balloon\hWnd    = GadgetID(ObjectID)
            Balloon\uId     = GadgetID(ObjectID)
            Balloon\hInst   = 0
            Balloon\lpszText= @Text$
            
            
            If TF=0
                TF = LoadFont(#PB_Any,"Segoe UI", 9)   
            EndIf
            
            SendMessage_(ToolTip, #WM_SETFONT, FontID(TF), #True) 
            
            
            SendMessage_(ToolTip, #TTM_ADDTOOL, 0, Balloon)
            SendMessage_(ToolTip, #TTM_SETDELAYTIME, #TTDT_AUTOPOP, 29999) 
            
            
            If Title$ > ""
                SendMessage_(ToolTip, #TTM_SETTITLE,TIcon,@Title$)
            EndIf
            
            SetWindowPos_(ToolTip.i, #HWND_TOPMOST,0, YPosition, 0, 0, #SWP_NOSIZE | #SWP_NOACTIVATE)    
            
            For i = 0 To 4096
                If *TT\Tool_Tip[i] = 0
                   *TT\Tool_Tip[i] = ToolTip.i ;Toolip Handle
                   *TT\ObjectID[i] = ObjectID  ; GadgetID
                   Break                    ;
                EndIf
            Next
            
            ProcedureReturn
        Case 1     
            
            GadgetToolTip(ObjectID,Text$) : ProcedureReturn   
    EndSelect
           
EndProcedure

; ================================================================
Procedure.l ToolTipEx(WindowID.i, Gadget.i, Text.s = "", Title.s = "", IconHandle.l = 0, TextWidth.i = 500, ToolTipMode.i = 0, FontID.l = 0, Ballon.b = #False, TextColor.l = $00FFFFFF , BackColor.l = $00FF0000, YPosition.i = 0, ImagePath.s = "", ImageHandle.l = 0)
  
  Protected hTip.i, hImg.i = 0, tFlags.i = 0
  
  If Not IsGadget(Gadget)    
    ProcedureReturn 0    
  EndIf
    
  ; Falls schon ein Tooltip für dieses Gadget existiert → löschen
  ForEach ToolTips()
    If ToolTips()\Gadget = Gadget
      DestroyWindow_(ToolTips()\hToolTip)
      If ToolTips()\hImage : FreeImage(ToolTips()\hImage) : EndIf
      DeleteElement(ToolTips())
      Break
    EndIf
  Next
  
  Select ToolTipMode
    Case 0
        ; Kein System Handle. PB Enmueration. Wenn die nummer gößer als 1000
        ; ist sollte es sich um ein Handle handeln
        ; Mehr als 1000 Fenster wird es in keinem PB project geben
        If (WindowID =< 1000)
          If IsWindow(WindowID)
            WindowID = WindowID(WindowID)
          EndIf
        EndIf     
      
      ; Neuer Tooltip
      If (Ballon)
          tFlags = #WS_POPUP|#TTS_ALWAYSTIP| #TTS_NOPREFIX| #TTS_BALLOON
      Else
          tFlags = #WS_POPUP|#TTS_ALWAYSTIP| #TTS_NOPREFIX| #WS_EX_TRANSPARENT|#WS_POPUPWINDOW
      EndIf

      hTip = CreateWindowEx_(0, "Tooltips_Class32", "", tFlags, 0, 0, 0, 0, WindowID, 0, GetModuleHandle_(0), 0)
      
      If (hTip = 0): ProcedureReturn 0: EndIf
      
      ; Bild laden (falls angegeben)
      If (ImagePath <> "" And FileSize(ImagePath) > 0) Or (ImageHandle > 0)
        If (ImagePath <> "" And FileSize(ImagePath) > 0)
          hImg = LoadImage(#PB_Any, ImagePath)
        Else
          hImg = ImageHandle
        EndIf
        
        If (hImg)
          ; In Icon umwandeln für TTM_SETTITLE (max. Qualität)
          Protected hIcon = CopyImage_(ImageID(hImg), #IMAGE_BITMAP, 200, 200, 0)
          SendMessage_(hTip, #TTM_SETTITLE, hIcon, @Title)
        EndIf
        
      ElseIf (IconHandle <> 0)
        SendMessage_(hTip, #TTM_SETTITLE, IconHandle, @Title)
      EndIf
      
      ; Tooltip Einstellungen
      SendMessage_(hTip, #TTM_SETMAXTIPWIDTH, 0, TextWidth)
      SendMessage_(hTip, #TTM_SETTIPTEXTCOLOR, TextColor, 0)
      SendMessage_(hTip, #TTM_SETTIPBKCOLOR,   BackColor, 0)
      
      Balloon.TOOLINFO\cbSize = SizeOf(TOOLINFO)
      Balloon\uFlags = #TTF_IDISHWND | #TTF_SUBCLASS
      Balloon\hWnd   = GadgetID(Gadget)
      Balloon\uId    = GadgetID(Gadget)
      Balloon\lpszText = @Text
      
      If (FontID = 0)
        FontID = LoadFont(#PB_Any,"Segoe UI", 9)
        FontID = FontID(FontID)
        
      ElseIf (FontID > 0)    
        If IsFont(FontID)
          FontID = FontID(FontID)
        EndIf  
      EndIf
      
      SendMessage_(hTip, #WM_SETFONT,FontID, #True) 
      
      SendMessage_(hTip, #TTM_ADDTOOL, 0, @Balloon)
      
      ; Tooltip speichern
      AddElement(ToolTips())
      ToolTips()\hToolTip = hTip
      ToolTips()\Gadget   = Gadget
      ToolTips()\hImage   = hImg
      ToolTips()\ImagePath = ImagePath

    Case 1      
      GadgetToolTip(Gadget,Text) : ProcedureReturn 0
  EndSelect  
  
  ProcedureReturn hTip
EndProcedure

;**************************************************************************************************
;
; - Command: 0 = Add
Procedure.l Tooltip_TrayIcon(File$, TrayID.i, Window.i, IconDescription$="", Command.i = 0) 
    Protected hMod, hIcon
    
    If ( IsSysTrayIcon(TrayID) And  ( Command = 1 ) )
        RemoveSysTrayIcon(TrayID)
        ProcedureReturn 0
    EndIf
                    
    hMod  = GetModuleHandle_(0) 
    ;Name$ = Space(1024) 
    
    GetModuleFileName_(0,File$,1024) 
    hIcon = ExtractIcon_(hMod,File$,0) 
    If hIcon 
        Select Command
                Case 0
                    ;
                    ; Add a Systray Icon       
                    AddSysTrayIcon(TrayID, WindowID(Window), hIcon)
                    SysTrayIconToolTip(TrayID, IconDescription$)
               Default
        EndSelect            
        ProcedureReturn hIcon
        
        
    Else 
        GetSystemDirectory_(File$,1024) 
        Select Command
                Case 0
                    ;
                    ; Add a Systray Icon       
                    AddSysTrayIcon(TrayID, WindowID(Window), ExtractIcon_(hMod,File$,2) )
                    SysTrayIconToolTip(TrayID, IconDescription$)   
                Default
        EndSelect         
        ProcedureReturn 
        ;ProcedureReturn LoadIcon_(0,#IDI_APPLICATION) ; alternatively 
    EndIf 
  EndProcedure
  
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 217
; FirstLine = 78
; Folding = n1
; EnableAsm
; EnableXP
; EnableUnicode