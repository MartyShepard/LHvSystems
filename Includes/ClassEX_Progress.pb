DeclareModule ProgressBarEx
    
    Declare Gadget(Gadget.l,x.l,y.l,Width.l,Height.l,Min.l,Max.l,outline.i=0,Flags.l=#Null)
    
    Declare SetAttribute(Gadget.l,Attribute.l,Value.l)
    Declare.l GetAttribute(Gadget.l,Attribute.l)
    
    Declare FreeExGadget(Gadget.l)
    
    Declare.l SetState(Gadget.l,State.l)
    Declare.l Getstate(Gadget.l)
    
    Declare.l SetColor(Gadget.l,ColorType.l,Color.l)
    Declare.l GetColor(Gadget.l,ColorType.l)
EndDeclareModule

Module ProgressBarEx
    
    Structure STRUCT_PGBAREX
        gadget.l
        image.l
        imageid.l
        w.l
        h.l
        floor.l
        ceiling.l
        state.l
        color.l
        colorlight.l
        colordark.l
        bgcolor.l
        bgcolorlight.l
        bgcolordark.l
        redraw.l
        resolution.f
        outline.i
    EndStructure
    
    Global NewList ExPB.STRUCT_PGBAREX()
    
   ;**************************************************************************************************
   ;
   ; 
   ;         
    Procedure Gadget(Gadget.l,x.l,y.l,Width.l,Height.l,Min.l,Max.l,outline.i=0,Flags.l=#Null)
        Protected r.l,g.l,b.l,handle.l=#False,image.l
        If AddElement(ExPB())
            ExPB()\gadget=Gadget
            ExPB()\w=Width
            ExPB()\h=Height
            ExPB()\outline=outline.i
            If Max>Min
                ExPB()\floor=Min
                ExPB()\ceiling=Max
            Else
                ExPB()\floor=Max
                ExPB()\ceiling=Min
            EndIf
            ExPB()\state=Min
            ExPB()\resolution=ExPB()\w/(1.0*(ExPB()\ceiling-ExPB()\floor))
            
            ExPB()\color=RGB($00,$D3,$28)
            
            r=Red(ExPB()\color)
            g=Green(ExPB()\color)
            b=Blue(ExPB()\color)
            ExPB()\colordark=RGB(r-(r>>2),g-(g>>2),b-(b>>2))
            ExPB()\colorlight=RGB(255-((255-r)>>1),255-((255-g)>>1),255-((255-b)>>1))
            ExPB()\bgcolor=RGB($CC,$CC,$CC)
            r=Red(ExPB()\bgcolor)
            g=Green(ExPB()\bgcolor)
            b=Blue(ExPB()\bgcolor)
            ExPB()\bgcolordark=RGB(r-(r>>2),g-(g>>2),b-(b>>2))
            ExPB()\bgcolorlight=RGB(255-((255-r)>>1),255-((255-g)>>1),255-((255-b)>>1))
            image=CreateImage(#PB_Any,Width,Height)
            If IsImage(image)
                ExPB()\image=image
                ExPB()\imageid=ImageID(image)
                If StartDrawing(ImageOutput(image))
                    Box(ExPB()\outline,ExPB()\outline,ExPB()\w,ExPB()\h,ExPB()\bgcolor)
                    
                    Line(1,1,ExPB()\w+2,0,ExPB()\bgcolorlight)
                    Line(1,2,0,ExPB()\h+1,ExPB()\bgcolorlight)
                    Line(1,ExPB()\h+2,ExPB()\w+2,0,ExPB()\bgcolordark)
                    Line(ExPB()\w+2,2,0,ExPB()\h,ExPB()\bgcolordark)
                    StopDrawing()
                    handle=ImageGadget(Gadget,x,y,Width,Height,ExPB()\imageid,Flags)
                    If Gadget=#PB_Any
                        ExPB()\gadget=handle
                    EndIf
                EndIf
            EndIf
            If handle=#False
                If IsImage(image)
                    FreeImage(image)
                EndIf
                DeleteElement(ExPB())
            EndIf
        EndIf
        ProcedureReturn handle
    EndProcedure
    
   ;**************************************************************************************************
   ;
   ; 
   ;      
    Procedure SetAttribute(Gadget.l,Attribute.l,Value.l)
        Protected Min.l,Max.l
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                Min=ExPB()\floor
                Max=ExPB()\ceiling
                Select Attribute
                    Case #PB_ProgressBar_Minimum
                        Min=Value
                    Case #PB_ProgressBar_Maximum
                        Max=Value
                EndSelect
                If Max>Min
                    ExPB()\floor=Min
                    ExPB()\ceiling=Max
                Else
                    ExPB()\floor=Max
                    ExPB()\ceiling=Min
                EndIf
                ExPB()\resolution=ExPB()\w/(1.0*(ExPB()\ceiling-ExPB()\floor))
                Break
            EndIf
        Next
    EndProcedure
    
   ;**************************************************************************************************
   ;
   ; 
   ;        
    Procedure.l GetAttribute(Gadget.l,Attribute.l)
        Protected result.l
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                Select Attribute
                    Case #PB_ProgressBar_Minimum
                        result=ExPB()\floor
                    Case #PB_ProgressBar_Maximum
                        result=ExPB()\ceiling
                EndSelect
                Break
            EndIf
        Next
        ProcedureReturn result
    EndProcedure
    
   ;**************************************************************************************************
   ;
   ; 
   ;     
    Procedure FreeExGadget(Gadget.l)
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                If IsGadget(gadget)
                    FreeGadget(gadget)
                EndIf
                If IsImage(ExPB()\image)
                    FreeImage(ExPB()\image)
                EndIf
                DeleteElement(ExPB())
                Break
            EndIf
        Next
    EndProcedure
   ;**************************************************************************************************
   ;
   ; 
   ;        
    Procedure.l SetState(Gadget.l,State.l)
        Protected w.l,result.l=#False,output.l
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                If State<ExPB()\floor ;Ensure State is within the valid range, clip to floor or ceiling where needed.
                    State=ExPB()\floor
                ElseIf State>ExPB()\ceiling
                    State=ExPB()\ceiling
                EndIf
                If (ExPB()\state<>State) Or ExPB()\redraw ;Is the state different from last time? If so, let's draw.
                    If IsImage(ExPB()\image)
                        output=ImageOutput(ExPB()\image)
                        If output
                            If StartDrawing(output)
                                If State<ExPB()\state ;Redraw background only if State is less than previously.
                                    ExPB()\redraw=#True
                                EndIf
                                If ExPB()\redraw
                                    ExPB()\redraw=#False
                                    Box(ExPB()\outline,ExPB()\outline,ExPB()\w,ExPB()\h,ExPB()\bgcolor)
                                    Line(1,1,ExPB()\w+2,0,ExPB()\bgcolorlight)
                                    Line(1,2,0,ExPB()\h+1,ExPB()\bgcolorlight)
                                    Line(1,ExPB()\h+2,ExPB()\w+2,0,ExPB()\bgcolordark)
                                    Line(ExPB()\w+2,2,0,ExPB()\h,ExPB()\bgcolordark)
                                EndIf
                                If State>ExPB()\floor ;Do we need to draw the progress bar or not?
                                    w=Round(ExPB()\resolution*(State-ExPB()\floor),#PB_Round_Nearest)
                                    Line(1,1,w+1,0,ExPB()\colorlight)
                                    Line(1,2,0,ExPB()\h+1,ExPB()\colorlight)
                                    Line(1,ExPB()\h+2,w+2,0,ExPB()\colordark)
                                    Line(w+2,1,0,ExPB()\h+1,ExPB()\colordark)
                                    Box(ExPB()\outline,ExPB()\outline,w,ExPB()\h,ExPB()\color)
                                EndIf
                                StopDrawing()
                                If IsGadget(Gadget)
                                    SetGadgetState(Gadget,ExPB()\imageid)
                                EndIf
                                ExPB()\state=State ;Store new state.
                                result=#True
                            EndIf
                        EndIf
                    EndIf
                EndIf
                Break
            EndIf
        Next
        ProcedureReturn result
    EndProcedure
   ;**************************************************************************************************
   ;
   ; 
   ;    
    Procedure.l Getstate(Gadget.l)
        Protected result.l=#Null
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                result=ExPB()\state
                Break
            EndIf
        Next
        ProcedureReturn result
    EndProcedure
   ;**************************************************************************************************
   ;
   ; 
   ;      
    Procedure.l SetColor(Gadget.l,ColorType.l,Color.l)
        Protected result.l=#False,r.l,g.l,b.l
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                Select ColorType
                    Case #PB_Gadget_FrontColor
                        ExPB()\color=Color
                        r=Red(Color)
                        g=Green(Color)
                        b=Blue(Color)
                        ExPB()\colordark=RGB(r-(r>>2),g-(g>>2),b-(b>>2))
                        ExPB()\colorlight=RGB(255-((255-r)>>1),255-((255-g)>>1),255-((255-b)>>1))
                        ExPB()\redraw=#True
                    Case #PB_Gadget_BackColor
                        ExPB()\bgcolor=Color
                        r=Red(Color)
                        g=Green(Color)
                        b=Blue(Color)
                        ExPB()\bgcolordark=RGB(r-(r>>2),g-(g>>2),b-(b>>2))
                        ExPB()\bgcolorlight=RGB(255-((255-r)>>1),255-((255-g)>>1),255-((255-b)>>1))
                        ExPB()\redraw=#True
                EndSelect
                result=#True
                Break
            EndIf
        Next
        ProcedureReturn result
    EndProcedure
   ;**************************************************************************************************
   ;
   ; 
   ;     
    Procedure.l GetColor(Gadget.l,ColorType.l)
        Protected result.l=#False
        ForEach ExPB()
            If ExPB()\gadget=Gadget
                Select ColorType
                    Case #PB_Gadget_FrontColor
                        result=ExPB()\color
                    Case #PB_Gadget_BackColor
                        result=ExPB()\bgcolor
                EndSelect
                Break
            EndIf
        Next
        ProcedureReturn result
    EndProcedure
    
EndModule
   ;**************************************************************************************************
   ;
   ; 
   ;     
CompilerIf #PB_Compiler_IsMainFile
    
    UsePNGImageDecoder()
     Procedure.l Hex2Dec(h$)
    ;===============================================
    ;   convert a hex-string to a integer value
    ;   found @ www.purebasic-lounge.de
    ;
    ;   Original code seems to be from code-archive
    ;   @ www.purearea.net
    ;===============================================
      h$=UCase(h$)
     
      For r=1 To Len(h$)
        d<<4
        a$=Mid(h$,r,1)
        If Asc(a$)>60
          d+Asc(a$)-55
        Else
          d+Asc(a$)-48
        EndIf
      Next
     
      ProcedureReturn d
     
  EndProcedure
  
  
  Debug Hex2Dec ("373737")   

    Procedure Demo(gadget.l)
        Protected Statev1.l=0,Statev2.l=0
        Repeat
            
;             If Statev1 = 101
;                 Statev1 = 0
;             EndIf
;             If Random(9)=5
;                 Select Random(3)
;                     Case 0
;                         ProgressBarEx::SetColor(5,#PB_Gadget_FrontColor,RGB($D2,$00,$0)) ;Error
;                     Case 1
;                         ProgressBarEx::SetColor(5,#PB_Gadget_FrontColor,RGB($00,$D3,$28)) ;Normal
;                     Case 2
;                         ProgressBarEx::SetColor(5,#PB_Gadget_FrontColor,RGB($D2,$CA,$0)) ;Paused
;                     Case 3
;                         ProgressBarEx::SetColor(5,#PB_Gadget_FrontColor,RGB($33,$99,$FF)) ;Classic
;                 EndSelect
;             EndIf
;             ProgressBarEx::SetState(5,Statev1)
;             Statev1 + 1
;             
;             If Statev2 = -101
;                 Statev2 = 0
;             EndIf
;             If Random(9)=5
;                 Select Random(3)
;                     Case 0
;                         ProgressBarEx::SetColor(6,#PB_Gadget_FrontColor,RGB($D2,$00,$0)) ;Error
;                     Case 1
;                         ProgressBarEx::SetColor(6,#PB_Gadget_FrontColor,RGB($00,$D3,$28)) ;Normal
;                     Case 2
;                         ProgressBarEx::SetColor(6,#PB_Gadget_FrontColor,RGB($D2,$CA,$0)) ;Paused
;                     Case 3
;                         ProgressBarEx::SetColor(6,#PB_Gadget_FrontColor,RGB($33,$99,$FF)) ;Classic
;                 EndSelect
;             EndIf
;              ProgressBarEx::SetColor(6,#PB_Gadget_BackColor,RGB(Random(255),Random(255),Random(255)))
;             ProgressBarEx::SetState(6,Statev2)
;             Statev2 - 1
            
            
;                 r = RB - i * 0.13
;                 g = 55 + i * 0.75     
;                 b = 55 + i * 1.20             
                
            ColorBegin = RGB(75,75,75)    
            ColorEnd   = RGB(41,130,175)
            
            RB.i = Red(ColorBegin)
            GB.i = Green(ColorBegin)
            BB.i = Blue(ColorBegin)
            
            RE.d = Abs(Red(ColorEnd) - RB.i)
            GE.d = Abs(Green(ColorEnd) - GB.i)
            BE.d = Abs(Blue(ColorEnd) - BB.i)
           
            sRE$ = Str(RE): RE = ValD(sRE$)/100
            sGE$ = Str(GE): GE = ValD(sGE$)/100
            sBE$ = Str(BE): BE = ValD(sBE$)/100       
        
            For i = 1 To 100

                r = RB - i * RE
                g = GB + i * GE     
                b = BB + i * BE            
                 Debug "RED: "+r
                 Debug "GRE: "+g
                 Debug "BLU: "+b
                BackColor = RGB(r,g,b)

                ProgressBarEx::SetColor(5,#PB_Gadget_FrontColor,BackColor)
                ProgressBarEx::SetState(5,i)
                Delay(100)
                ;Debug 
            Next       
        
            
        ForEver
    EndProcedure
    
    Define event.l,thread.l,gadget1.l,gadget2.l
    
    If OpenWindow(0, 0, 0, 300, 100, "Progress Demo",#PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        
        gadget1=ProgressBarEx::Gadget(5,10,10,280,30,0,100)
        gadget2=ProgressBarEx::Gadget(6,10,60,280,30,0,-100)
        ;Except for the FreeProgressBarExGadget(), this progressbar gadget behaves like a imagegadget
        ;so you can use a gadget tooltip, catch imagegadget events and so on.
        GadgetToolTip(6,"Cool huh?")
        
        thread=CreateThread(@Demo(),#Null)
        
        Repeat
            event = WaitWindowEvent()
            If event=#PB_Event_Gadget
                If EventGadget()=6
                    If EventType()=#PB_EventType_LeftClick
                        Debug "Click!"
                    EndIf
                EndIf
            EndIf
        Until event = #PB_Event_CloseWindow
    EndIf
    
    ProgressBarEx::FreeExGadget(5) ;Make sure we free not just the gadget but the image we draw on and the list element as well.
    ProgressBarEx::FreeExGadget(6) ;You only need to do this if you plan to free the gadget or the window, otherwise PureBasic will clean up when it quits as usual.
    
    KillThread(thread)
    
    End

CompilerEndIf
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 368
; FirstLine = 323
; Folding = f0-
; EnableAsm
; EnableUnicode
; EnableXP