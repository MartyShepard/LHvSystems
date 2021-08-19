; 
; Button Extended mit eigenm Bild
; Original Source vom Purebasic Board
; Editiert von Martin Schäfer
; - Geändert zu einem Modul was ausserhalb des programs läuft
; - Zentrierung des Textes mittels "DrawText" auf den Buttons Hinzugefügt
; 
; Events und Bild Konstante liegen in seperaten Source
DeclareModule CHECKBOXEX
            
    Enumeration 8621 Step 1
        #CheckBoxEx_Entered
        #CheckBoxEx_Released
        #CheckBoxEx_Pressed
    EndEnumeration
    
        EnumEnd =  8630
        EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
        Debug #TAB$ + "Constansts Enumeration : 8621 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: CheckBoxEx::(Module))"
        
;     Enums =  3270 - #PB_Compiler_EnumerationValue
;     Debug "Enumeration = 3270 -> " + #PB_Compiler_EnumerationValue +" /Max: 3273 /Free: "+Str(Enums)+" ()" 
    
    ; 
    ; ButtonEX
    Declare BoxEvent(GadgetID)
    Declare GetState(GadgetID)
    Declare SetState(GadgetID, state)
    Declare Disable(GadgetID, state)    
    Declare IsEnabled(GadgetID)
    
    Declare Add(GadgetID.l,X.i, Y.i,W.i,H.i,ImageID_Normal,ImageID_Hover,ImageID_Press,ImageID_Disabled,ImageID_Normal_Mark,ImageID_Hover_Mark,ImageID_Press_Mark,ImageID_Disabled_Mark, TextN$="", TextH$="", TextP$="" , FontID.l = 0, ColorN.l=0, ColorH.l=0, ColorTextBack.l=0)
        
EndDeclareModule

Module CHECKBOXEX

    Structure CheckBoxGadgetEx_Struct
        Pressed.i      
        Disabled.i
        
        Marked.i

        ImageID_Normal.i
        ImageID_Normal_Mark.i
        ImageID_Hover.i        
        ImageID_Hover_Mark.i
        ImageID_Press.i
        ImageID_Press_Mark.i
        ImageID_Disabled.i
        ImageID_Disabled_Mark.i        
        
        TextN.s
        TextH.s
        TextP.s 
        
        ColorN.l
        ColorH.l
        ColorTextBack.l
        FontID.l
    EndStructure    

    
    
    Procedure CheckBoxExText(GadgetID.i,Text$,TextLengthX.i,TextLengthY.i,BackColor.l,TextColor.l,CurrentImage.l,FontID.l)
        
        DrawingMode(#PB_2DDrawing_Transparent) 
           Box(ImageWidth(CurrentImage), 0, GadgetWidth(GadgetID)+TextLengthX+2, GadgetHeight(GadgetID),BackColor)        
        
           DrawingFont(FontID(FontID))
           CenterY = Abs(GadgetHeight(GadgetID) - TextLengthY.i) / 2
           DrawText(ImageWidth(CurrentImage)+2,CenterY, Text$,  TextColor.l)       
     EndProcedure   
            
    ;********************************************************************************************************************************
    ;Intern, Zeichnet das Gadget
    ;________________________________________________________________________________________________________________________________      
     Procedure BoxDraw(GadgetID.i,ColorN.l,ImageEvent.l,FontID.l,Text$, Color1.l,Color2.l)
        Protected TextSize.SIZE
         
        _DRAWING = StartDrawing(CanvasOutput(GadgetID))
        Box(0, 0, GadgetWidth(GadgetID), GadgetHeight(GadgetID), ColorN)
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(ImageID(ImageEvent), 0, 0)
        
        SelectObject_(_DRAWING, FontID(FontID))
        
        GetTextExtentPoint32_(_DRAWING, Text$, Len(Text$), @TextSize)  
        
        CheckBoxExText(GadgetID.i,Text$,TextSize\cx,TextSize\cy,Color2,Color1,ImageEvent,FontID)
        StopDrawing() 
        
        ProcedureReturn
    EndProcedure                   
        
    ;********************************************************************************************************************************
    ;Event
    ;________________________________________________________________________________________________________________________________  
    Procedure BoxEvent(GadgetID)
        
        If Not IsGadget(GadgetID): MessageRequester("Now Look What You've Done","Internal Error Code #104CBXGDEX_#"+Str(GadgetID),0)
            ProcedureReturn
        EndIf         
        Protected *CheckBoxEx.CheckBoxGadgetEx_Struct = GetGadgetData(GadgetID)
        
        Select *CheckBoxEx\Disabled
            Case #False                               
                If EventType() = #PB_EventType_MouseEnter  
                    
                    Select *CheckBoxEx\Marked 
                        Case #False
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Hover,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack) 
                        Case #True
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Hover_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack)                           
                    EndSelect        
                    ProcedureReturn #CheckBoxEx_Entered                                         
                    ;
                    ;
                ElseIf EventType() = #PB_EventType_MouseLeave                            
                    
                    Select *CheckBoxEx\Marked 
                        Case #False
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack) 
                        Case #True
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack) 
                            
                    EndSelect   
                    ProcedureReturn #CheckBoxEx_Released                         
                    ;
                    ;
                ElseIf EventType() = #PB_EventType_LeftButtonDown                            
                    
                    Select *CheckBoxEx\Marked 
                        Case #False
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Press,*CheckBoxEx\FontID,*CheckBoxEx\TextP,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack) 
                        Case #True
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Press_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextP,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack) 
                            
                    EndSelect   
                    ProcedureReturn -1 
                    ;
                    ;
                ElseIf EventType() = #PB_EventType_LeftButtonUp                            
                    
                    Select *CheckBoxEx\Marked 
                        Case #False
                            *CheckBoxEx\Marked = #True                             
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack) 
                        Case #True
                            *CheckBoxEx\Marked = #False                            
                            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack) 
                    EndSelect 

                    If  GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX)>0 And GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY)>0 And GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX)<GadgetWidth(GadgetID) And GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY)< GadgetHeight(GadgetID)                                
                        Select *CheckBoxEx\Marked 
                            Case #False
                                BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Hover,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack) 
                            Case #True
                                BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Hover_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack)                          
                        EndSelect  
                        ProcedureReturn #CheckBoxEx_Pressed                              
                    EndIf                          
                      
                    ;
                    ;
                ElseIf EventType() = #PB_EventType_MouseMove
                    If GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX)<0 Or GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY)<0 Or GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX)>GadgetWidth(GadgetID) Or GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY)> GadgetHeight(GadgetID) Or *CheckBoxEx\Pressed = #False
                        If *CheckBoxEx\Pressed = #True
                            Select *CheckBoxEx\Marked 
                                Case #False
                                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Press,*CheckBoxEx\FontID,*CheckBoxEx\TextP,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack) 
                                Case #True
                                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Press_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextP,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack)                           
                            EndSelect   
                        Else
                            Select *CheckBoxEx\Marked 
                                Case #False
                                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Hover,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack)  
                                Case #True
                                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Hover_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextH,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack)                            
                            EndSelect         
                            
                            
                        EndIf
                        ProcedureReturn #CheckBoxEx_Released                         
                    Else
                        Select *CheckBoxEx\Marked 
                            Case #False
                                BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Press,*CheckBoxEx\FontID,*CheckBoxEx\TextP,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack) 
                            Case #True
                                BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Press_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextP,*CheckBoxEx\ColorH,*CheckBoxEx\ColorTextBack)                           
                        EndSelect                 
                    EndIf
                EndIf       
        EndSelect
      
    EndProcedure
    
    ;********************************************************************************************************************************
    ;GetState
    ;________________________________________________________________________________________________________________________________ 
    Procedure GetState(GadgetID)
        
        If Not IsGadget(GadgetID)
            MessageRequester("Now Look What You've Done","Internal Error Code #56BXGDEXTGL_#"+Str(GadgetID),0)
            ProcedureReturn
        EndIf    
        Protected *CheckBoxEx.CheckBoxGadgetEx_Struct = GetGadgetData(GadgetID)
        ProcedureReturn *CheckBoxEx\Marked
    EndProcedure
    ;********************************************************************************************************************************
    ;IsEnabled, Check for Disbale, Enable
    ;________________________________________________________________________________________________________________________________ 
    Procedure IsEnabled(GadgetID)
        
        If Not IsGadget(GadgetID)
            MessageRequester("Now Look What You've Done","Internal Error Code #57BXGDEXTGL_#"+Str(GadgetID),0)
            ProcedureReturn
        EndIf    
        Protected *CheckBoxEx.CheckBoxGadgetEx_Struct = GetGadgetData(GadgetID)
        ProcedureReturn *CheckBoxEx\Disabled
        
    EndProcedure

    ;********************************************************************************************************************************
    ;SetState
    ;________________________________________________________________________________________________________________________________ 
    Procedure SetState(GadgetID, state)
        If Not IsGadget(GadgetID)
            MessageRequester("Now Look What You've Done","Internal Error Code #58BXGDEXDS_#"+Str(GadgetID),0)
            ProcedureReturn
        EndIf   
        Protected *CheckBoxEx.CheckBoxGadgetEx_Struct = GetGadgetData(GadgetID)
        *CheckBoxEx\Marked = state
        
        If state = #True
            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack) 
        Else
            BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack)  
        EndIf
    EndProcedure

    ;********************************************************************************************************************************
    ;Disable
    ;________________________________________________________________________________________________________________________________ 
    Procedure Disable(GadgetID, state)
        
        If Not IsGadget(GadgetID)
            MessageRequester("Now Look What You've Done","Internal Error Code #59BXGDEXDS_#"+Str(GadgetID),0)
            ProcedureReturn
        EndIf   
        
        Protected *CheckBoxEx.CheckBoxGadgetEx_Struct = GetGadgetData(GadgetID)
        
        *CheckBoxEx\Disabled = state
        
        DisableGadget(GadgetID, state)
        If state = #True  
            Select *CheckBoxEx\Marked 
                Case #False
                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Disabled,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack) 
                Case #True
                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Disabled_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack)                            
            EndSelect  
            
        Else
            Select *CheckBoxEx\Marked 
                Case #False
                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack)  
                Case #True
                    BoxDraw(GadgetID,*CheckBoxEx\ColorN,*CheckBoxEx\ImageID_Normal_Mark,*CheckBoxEx\FontID,*CheckBoxEx\TextN,*CheckBoxEx\ColorN,*CheckBoxEx\ColorTextBack)                            
            EndSelect  
        EndIf
    EndProcedure

    ;********************************************************************************************************************************
    ;SetState
    ;________________________________________________________________________________________________________________________________ 
    Procedure Add(GadgetID.l,X.i, Y.i,W.i,H.i,ImageID_Normal,ImageID_Hover,ImageID_Press,ImageID_Disabled,ImageID_Normal_Mark,ImageID_Hover_Mark,ImageID_Press_Mark,ImageID_Disabled_Mark, TextN$="", TextH$="", TextP$="" , FontID.l = 0, ColorN.l=0, ColorH.l=0, ColorTextBack.l=0)
        
        ;     If Not IsGadget(GadgetID)
        ;         MessageRequester("Now Look What You've Done","Internal Error Code #44CBGDEX"+Str(GadgetID),0)
        ;         ProcedureReturn
        ;     EndIf 
        
        Dim PTS.Point(7): Dim Indx.I(7): Protected TextSize.SIZE
        
        
        CanvasGadget(GadgetID, X, Y, W, H)
        
        Protected *CheckBoxEx.CheckBoxGadgetEx_Struct = AllocateMemory(SizeOf(CheckBoxGadgetEx_Struct))
        
        SetGadgetData(GadgetID,*CheckBoxEx)
        
        *CheckBoxEx\ImageID_Normal       = ImageID_Normal
        *CheckBoxEx\ImageID_Hover        = ImageID_Hover
        *CheckBoxEx\ImageID_Press        = ImageID_Press
        *CheckBoxEx\ImageID_Disabled     = ImageID_Disabled
        
        *CheckBoxEx\ImageID_Normal_Mark  = ImageID_Normal_Mark
        *CheckBoxEx\ImageID_Hover_Mark   = ImageID_Hover_Mark
        *CheckBoxEx\ImageID_Press_Mark   = ImageID_Press_Mark
        *CheckBoxEx\ImageID_Disabled_Mark= ImageID_Disabled_Mark    
        
        Select ColorH
            Case 0
                ColorH = GetSysColor_(#COLOR_3DFACE)
        EndSelect                    
        *CheckBoxEx\ColorH               = ColorH
        
        Select ColorN
            Case 0
                ColorN = GetSysColor_(#COLOR_3DFACE)
        EndSelect        
        *CheckBoxEx\ColorN               = ColorN
        
        Select ColorTextBack.l 
            Case 0
                If IsWindow(0)                
                    ColorTextBack = GetWindowColor(0) 
                Else
                    ColorTextBack = 0
                EndIf    
   
        EndSelect            
        *CheckBoxEx\ColorTextBack       = ColorTextBack      
        
        *CheckBoxEx\TextN.s              = TextN$
        *CheckBoxEx\TextH.s              = TextH$   
        *CheckBoxEx\TextP.s              = TextP$   
        
        Select FontID
            Case 0
                FontID.l = LoadFont(#PB_Any,"Segoe UI", 9)           
        EndSelect        
        *CheckBoxEx\FontID               = FontID.l
        

        
        
        _DRAWING = StartDrawing(CanvasOutput(GadgetID))
        Box(0, 0, GadgetWidth(GadgetID), GadgetHeight(GadgetID), *CheckBoxEx\ColorN)
                
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(ImageID(ImageID_Normal), 0, 0)

        DrawingFont(FontID(*CheckBoxEx\FontID))
        SelectObject_(_DRAWING, FontID(*CheckBoxEx\FontID ))
        GetTextExtentPoint32_(_DRAWING, *CheckBoxEx\TextN.s, Len(*CheckBoxEx\TextN.s), @TextSize)        

        StopDrawing() 
        ResizeGadget(GadgetID,#PB_Ignore,#PB_Ignore,GadgetWidth(GadgetID)+TextSize\cx+2,#PB_Ignore)
        
        StartDrawing(CanvasOutput(GadgetID))
        
         CheckBoxExText(GadgetID,*CheckBoxEx\TextN.s ,TextSize\cx,TextSize\cy,*CheckBoxEx\ColorTextBack,*CheckBoxEx\ColorN, *CheckBoxEx\ImageID_Normal,FontID)
         
         StopDrawing()

EndProcedure
EndModule
CompilerIf #PB_Compiler_IsMainFile
    
    UsePNGImageDecoder()
    Close = #False
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;  Constants: Buttons For GadgetEX (Seperate)
    #Window_001 = 0
    #Button_001 = 2
    #Button_002 = 3
    #Button_003 = 4
    #CheckBox_001 = 500
    #CheckBox_002 = 501    
    
    ;;
    ;;
    
    Enumeration 4101 Step 1
        #_CBX_DEFA1_0N: #_CBX_DEFA1_0H: #_CBX_DEFA1_0P: #_CBX_DEFA1_0D: #_CBX_DEFA1_1N: #_CBX_DEFA1_1H: #_CBX_DEFA1_1P: #_CBX_DEFA1_1D:        
    EndEnumeration
    
    Enums =  200 - #PB_Compiler_EnumerationValue
    Debug "Enumeration = 200 -> " + #PB_Compiler_EnumerationValue +" /Max: 200 /Free: "+Str(Enums)+" (Checkbox Buttons For GadgetEX (Seperate)"  
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;
    ; Pictures
     DataSection
    _CBX_DEFA1_0N:     
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C0_N.png"
    
    _CBX_DEFA1_0H: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C0_H.png"
    
    _CBX_DEFA1_0P: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C0_P.png"    
    
    _CBX_DEFA1_0D: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C0_D.png"     
    
    _CBX_DEFA1_1N: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C1_N.png"
    
    _CBX_DEFA1_1H: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C1_H.png"
    
    _CBX_DEFA1_1P: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C1_P.png"    
    
    _CBX_DEFA1_1D: 
    IncludeBinary "_IMAGE_CHECKBOXEX\Checkbox_C1_D.png"    ;Kein Disabled 
    
     EndDataSection
    CatchImage(#_CBX_DEFA1_0N, ?_CBX_DEFA1_0N): CatchImage(#_CBX_DEFA1_0H, ?_CBX_DEFA1_0H): CatchImage(#_CBX_DEFA1_0P, ?_CBX_DEFA1_0P): CatchImage(#_CBX_DEFA1_0D, ?_CBX_DEFA1_0D)
    CatchImage(#_CBX_DEFA1_1N, ?_CBX_DEFA1_1N): CatchImage(#_CBX_DEFA1_1H, ?_CBX_DEFA1_1H): CatchImage(#_CBX_DEFA1_1P, ?_CBX_DEFA1_1P): CatchImage(#_CBX_DEFA1_1D, ?_CBX_DEFA1_1D)
    
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;
    ; Style als proecdure   
    Procedure ChkBoxEx(ObjectID,X.i,Y.i,Text1$="",Text2$="",Text3$="",ColorN.l = 0, ColorH.l = 0,FontID.l=0,Style=0); (Style 0 = Default Button)
        
        Select Style
            Case 0
                CheckboxEX::Add(ObjectID,X.i,Y.i,30,30,#_CBX_DEFA1_0N,#_CBX_DEFA1_0H,#_CBX_DEFA1_0H,
                                #_CBX_DEFA1_0D,
                                #_CBX_DEFA1_1N,
                                #_CBX_DEFA1_1H,
                                #_CBX_DEFA1_1H,
                                #_CBX_DEFA1_1D,Text1$,Text2$,Text3$,FontID.l,ColorN,RGB(Random(255), Random(255), Random(255)),RGB(130,130,130))
        EndSelect
    EndProcedure
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;
    ; Demo   
    OpenWindow(#Window_001, 0, 0, 300, 100, "Window", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
    ButtonGadget(#Button_001,10,10,50,17,"GetState")
    ButtonGadget(#Button_002,GadgetX(#Button_001)+GadgetWidth(#Button_001)+10,GadgetY(#Button_001),50,17,"SetState") 
    ButtonGadget(#Button_003,GadgetX(#Button_002)+GadgetWidth(#Button_002)+10,GadgetY(#Button_002),50,17,"Disable/Enable") 
    
    ChkBoxEx(#CheckBox_001,10,50,"Last Ninja 1 (Subtune 1)","Last Ninja 1 (Subtune 1)","Last Ninja 1 (Subtune 1)")
    ChkBoxEx(#CheckBox_002,GadgetX(#CheckBox_001)+GadgetWidth(#CheckBox_001)+10,GadgetY(#CheckBox_001),"Test","Test","Test")
    
    SetWindowColor(#Window_001,RGB(130,130,130))
    SetActiveWindow(#Window_001)
    
    Repeat

            MainEvent       = WaitWindowEvent()
            MainEventWindow = EventWindow()
            MainEventGadget = EventGadget() ;// GadgetID
            MainEventType   = EventType()
            MainEventMenu   = EventMenu()
            MainEventParam  = EventwParam()
            MainEventParami = EventlParam()
            MainEventData   = EventData()   
            Select MainEvent
                Case #PB_Event_Gadget
                    
                    
                    Select MainEventGadget 
                        Case #CheckBox_001
                            ;Neuer Eintrag
                            ;____________________________________________________________________________________________________________________                            
                            Select CHECKBOXEX::BoxEvent(#CheckBox_001) 
                                    
                                Case CHECKBOXEX::#CheckBoxEx_Entered
                                Case CHECKBOXEX::#CheckBoxEx_Released
                                Case CHECKBOXEX::#CheckBoxEx_Pressed
                                    
                            EndSelect
                            
                        Case #CheckBox_002
                            ;Neuer Eintrag
                            ;____________________________________________________________________________________________________________________                            
                            Select CHECKBOXEX::BoxEvent(#CheckBox_002) 
                                    
                                Case CHECKBOXEX::#CheckBoxEx_Entered
                                Case CHECKBOXEX::#CheckBoxEx_Released
                                Case CHECKBOXEX::#CheckBoxEx_Pressed
                                    
                            EndSelect
                            
                            
                        Case #Button_001
                            State.i = CHECKBOXEX::GetState(#CheckBox_001)
                            Select State.i
                                Case #True                                   
                                    MessageRequester("CheckBoxEX", "Checkmark ist gesetzt")
                                Case #False    
                                    MessageRequester("CheckBoxEX", "Checkmark ist NICHT gesetzt")
                            EndSelect
                        Case #Button_002
                            State.i = CHECKBOXEX::GetState(#CheckBox_001)
                            Select State.i
                                Case #True                                   
                                    CHECKBOXEX::SetState(#CheckBox_001, #False)
                                Case #False    
                                    CHECKBOXEX::SetState(#CheckBox_001, #True)
                            EndSelect                            
                            
                       Case #Button_003
                            State.i = CHECKBOXEX::IsEnabled(#CheckBox_002)
                            Select State.i
                                Case #True                                   
                                    CHECKBOXEX::Disable(#CheckBox_002, #False)
                                Case #False    
                                    CHECKBOXEX::Disable(#CheckBox_002, #True)
                            EndSelect                                                           
               EndSelect                       
            EndSelect
            
              
  Until close = #True

CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 8
; Folding = f5-
; EnableAsm
; EnableUnicode
; EnableThread
; EnableXP
; EnablePurifier