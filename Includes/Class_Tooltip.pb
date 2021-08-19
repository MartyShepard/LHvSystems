DeclareModule SSTTIP
    
        
    ;
    ; ToolTIPEx
    Declare TooltTip(WindowID, ObjectID, Text$ , Title$, TIcon=0, TextWidth=500, ToolTipMode=0, TF=0,BallonType=#False,CFrt=$00FFFFFF, CBck=$00FF0000); - ToolTipMode: 0-Normal, 1-Purebasic Default, 2-Chnage Text,3-Hide, 4-Remove, 5-Show   
    Declare.s ToolTipMode(Modus=1,ToolTipID=0,Text$="")
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
Procedure TooltTip(WindowID, ObjectID, Text$ , Title$, TIcon=0, TextWidth=500, ToolTipMode=0, TF=0,BallonType=#False,CFrt=$00FFFFFF, CBck=$00FF0000); 
    
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
            
            SetWindowPos_(ToolTip.i, #HWND_TOPMOST,0, 0, 0, 0,#SWP_NOMOVE | #SWP_NOSIZE | #SWP_NOACTIVATE)    
            
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
; CursorPosition = 52
; FirstLine = 12
; Folding = f-
; EnableAsm
; EnableXP
; EnableUnicode