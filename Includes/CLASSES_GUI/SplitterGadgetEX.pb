DeclareModule SplitterGadgetEx
   EnumerationBinary   
      ;custom Flags
      #SplitBar_Default=0
      #SplitBar_Vertical=1
      #SplitBar_Grip
      #SplitBar_Locked
      #SplitBar_FixedSize     
      ;custom Statuses
      #SplitBar_IsHighlighted=1
      #SplitBar_IsDragged
      #SplitBar_IsSnapped
   EndEnumeration
   Enumeration
      ;custom Attributes
      #SplitBar_CurrentFlags=2000
      #SplitBar_CurrentStatus
      #SplitBar_CurrentThickness
      #SplitBar_CurrentSnapDistance
      #SplitBar_CurrentFirstGadget
      #SplitBar_CurrentSecondGadget
      #SplitBar_CurrentFirstMinSize
      #SplitBar_CurrentSecondMinSize
      #SplitBar_CurrentDrawingFunction
   EndEnumeration
   Declare.i SplitterGadgetEx(Gadget, x, y, Width, Height, Gadget1=0, Gadget2=0, Flags=#SplitBar_Default, Thickness=6)
EndDeclareModule

Module SplitterGadgetEx
   EnableExplicit
   CompilerIf #PB_Compiler_OS=#PB_OS_Windows
      ;- PB SDK for Windows
      Structure Gadget
         Gadget.i
         *vt.GadgetVT
         UserData.i
         OldCallback.i
         Daten.i[4]
      EndStructure
      Structure GadgetVT
         GadgetType.l
         SizeOf.l
         *GadgetCallback
         *FreeGadget
         *GetGadgetState
         *SetGadgetState
         *GetGadgetText
         *SetGadgetText
         *AddGadgetItem2
         *AddGadgetItem3
         *RemoveGadgetItem
         *ClearGadgetItemList
         *ResizeGadget
         *CountGadgetItems
         *GetGadgetItemState
         *SetGadgetItemState
         *GetGadgetItemText
         *SetGadgetItemText
         *OpenGadgetList2
         *GadgetX
         *GadgetY
         *GadgetWidth
         *GadgetHeight
         *HideGadget
         *AddGadgetColumn
         *RemoveGadgetColumn
         *GetGadgetAttribute
         *SetGadgetAttribute
         *GetGadgetItemAttribute2
         *SetGadgetItemAttribute2
         *SetGadgetColor
         *GetGadgetColor
         *SetGadgetItemColor2
         *GetGadgetItemColor2
         *SetGadgetItemData
         *GetGadgetItemData
         *GetRequiredSize
         *SetActiveGadget
         *GetGadgetFont
         *SetGadgetFont
         *SetGadgetItemImage
      EndStructure
   CompilerElseIf #PB_Compiler_OS=#PB_OS_Linux
      ;- PB SDK for Linux
      Structure Gadget
         Gadget.i
         GadgetContainer.i
         *vt.GadgetVT
         UserData.i
         Daten.i[4]
      EndStructure
      Structure GadgetVT
         SizeOf.l
         GadgetType.l
         *ActivateGadget
         *FreeGadget
         *GetGadgetState
         *SetGadgetState
         *GetGadgetText
         *SetGadgetText
         *AddGadgetItem2
         *AddGadgetItem3
         *RemoveGadgetItem
         *ClearGadgetItemList
         *ResizeGadget
         *CountGadgetItems
         *GetGadgetItemState
         *SetGadgetItemState
         *GetGadgetItemText
         *SetGadgetItemText
         *SetGadgetFont
         *OpenGadgetList2
         *AddGadgetColumn
         *GetGadgetAttribute
         *SetGadgetAttribute
         *GetGadgetItemAttribute2
         *SetGadgetItemAttribute2
         *RemoveGadgetColumn
         *SetGadgetColor
         *GetGadgetColor
         *SetGadgetItemColor2
         *GetGadgetItemColor2
         *SetGadgetItemData
         *GetGadgetItemData
         *GetGadgetFont
         *SetGadgetItemImage
         *HideGadget ;Mac & Windows only
      EndStructure
   CompilerElseIf #PB_Compiler_OS=#PB_OS_MacOS
      ;- PB SDK for MacOs => TODO     
   CompilerEndIf
   
   Structure CustomGadget
      vt.GadgetVT
      vtOld.GadgetVT ;old gadget VT
      isCustom.b       ;determines if customization is active
     
      ;custom properties
      Gadget.i
      Gadget1.i
      Gadget2.i
      Flags.i
      Thickness.i
      x.i : y.i : w.i : h.i
      BackColor.i
      FrontColor.i
      LineColor.i
      State.f
      StatePercent.f
      SnapDistance.i
      FirstMinSize.i
      SecondMinSize.i
      CurrentStatus.i
      DragOffsetX.i
      DragOffsetY.i
      *DrawingFunction
   EndStructure
   Structure CustomContext
      *DraggedGadget.CustomGadget
      DragStartPos.i
   EndStructure
   Global CustomContext.CustomContext        ;Custom global context
   Global NewMap CustomGadget.CustomGadget() ;Custom gadget list
   Declare.i NewCustomGadget(*this.Gadget)
   Declare FreeCustomGadget(*this.Gadget)
   Declare DrawCustomGadget(*this.Gadget)
   Declare UseCustomGadget(*this.Gadget, *CustomGadget.CustomGadget)
   Declare CustomGadgetEvents()
   

   

   ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   ;
   ;   
   Procedure ResizeGadgetSmoothly(Gadget, x, y, w, h, SmoothMode=#True)
      Protected *this.Gadget=GadgetID(Gadget), Gadgetclass.s
 
      If SmoothMode ;prevent flickering
          CompilerIf #PB_Compiler_OS=#PB_OS_Windows 
            FORM::ResizeGadgetOS_Windows(FORM::Get_GadgetClass(Gadget,#False), *this.Gadget)
         CompilerEndIf
      EndIf
      ResizeGadget(Gadget, x, y, w, h)
      If SmoothMode ;prevent flickering
          CompilerIf #PB_Compiler_OS=#PB_OS_Windows
             FORM::ResizeGadgetOS_Windows(FORM::Get_GadgetClass(Gadget,#False), *this.Gadget,#True)          
         CompilerEndIf
      EndIf
   EndProcedure
   
   Procedure _ResizeGadget(*this.Gadget, x, y, w, h)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         If x=#PB_Ignore : x=\x : EndIf
         If y=#PB_Ignore : y=\y : EndIf
         If w=#PB_Ignore : w=\w : EndIf
         If h=#PB_Ignore : h=\h : EndIf
         
         \x=x : \y=y : \w=w : \h=h
         Protected bx=x, by=y, bw.f=w, bh.f=h    ;bar
         Protected fx=x, fy=y, fw.f=w, fh.f=h    ;first gadget
         Protected sx=x, sy=y, sw.f=w, sh.f=h    ;second gadget
         Protected bp, bl.f, fp, fl.f, sp, sl.f  ;generic positions & lengths
         Protected tk=\Thickness, max            ;generic measures
         
         ;convert oriented coordinates into generic coordinates
         If \Flags & #SplitBar_Vertical
            max=w : fp=fx
         Else
            max=h : fp=fy
         EndIf
         ;apply maxsize constraints
         If max<0 Or max>$FFFF : max=0 : EndIf
         If tk>max : tk=max : EndIf
         ;locate 1st gadget
         If \Flags & #SplitBar_FixedSize : fl=\State : Else : fl=\StatePercent * max : EndIf
         If fl<0 : fl=max + fl - tk : EndIf
         ;apply minsize constraints
         If fl<\FirstMinSize : fl=\FirstMinSize : EndIf
         If (fl + tk + \SecondMinSize)>max : fl=max-tk-\SecondMinSize : EndIf
         If fl<0 : fl=0 : EndIf
         ;locate 2nd gadget and bar
         sp=fp + fl + tk : sl=max-fl-tk
         bp=fp + fl : bl=tk
         ;convert generic coordinates into oriented coordinates
         If \Flags & #SplitBar_Vertical
            fw=fl : sx=sp : sw=sl : bx=bp : bw=bl
         Else
            fh=fl : sy=sp : sh=sl : by=bp : bh=bl
         EndIf
                  
         ;resize bar (resized original gadget)
         UseCustomGadget(*this, 0)
         ResizeGadget(\Gadget, bx, by, bw, bh)
         UseCustomGadget(*this, 1)
         DrawCustomGadget(*this)
         
         ;resize first and second gadgets (if possible)
         Protected SmoothMode=Bool(CustomContext\DraggedGadget<>0)
         ;Protected SmoothMode=#False         
         If IsGadget(\Gadget1) : ResizeGadgetSmoothly(\Gadget1, fx, fy, fw, fh, SmoothMode) : EndIf
         If IsGadget(\Gadget2) : ResizeGadgetSmoothly(\Gadget2, sx, sy, sw, sh, SmoothMode) : EndIf
      EndWith
   EndProcedure
   
   Procedure.i _GetGadgetColor(*this.Gadget, ColorType)
      Protected *CustomGadget.CustomGadget=*this\vt, result
      With *CustomGadget
         Select ColorType
            Case #PB_Gadget_LineColor : result=\LineColor
            Case #PB_Gadget_BackColor : result=\BackColor
            Case #PB_Gadget_FrontColor : result=\FrontColor
         EndSelect
         ProcedureReturn result
      EndWith
   EndProcedure
   
   Procedure _SetGadgetColor(*this.Gadget, ColorType, Color)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         Select ColorType
            Case #PB_Gadget_LineColor : \LineColor=Color
            Case #PB_Gadget_BackColor : \BackColor=Color
            Case #PB_Gadget_FrontColor : \FrontColor=Color
         EndSelect
         DrawCustomGadget(*this)
      EndWith
   EndProcedure
   
   Procedure.i _GetGadgetState(*this.Gadget)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         ProcedureReturn \State
      EndWith
   EndProcedure
   
   Procedure _SetGadgetState(*this.Gadget, State.i)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         Protected max
         If (\Flags & #SplitBar_Vertical) : max=\w : Else : max=\h : EndIf
         If (\CurrentStatus & #SplitBar_IsDragged)
            ;Snapped bar constraints
            If \SnapDistance>0
               \CurrentStatus & ~#SplitBar_IsSnapped
               If \StatePercent>=0 And State<\SnapDistance : State=0 : \CurrentStatus | #SplitBar_IsSnapped : EndIf
               If \StatePercent<0 And State>-\SnapDistance : State=0 : \CurrentStatus | #SplitBar_IsSnapped : EndIf
            EndIf
            ;Dragged bar constraints
            If \StatePercent>=0
               If State<1 : State=0 : EndIf
               If State>(max-\Thickness) : State=(max-\Thickness) : EndIf
            Else
               If State>-1 : State=0 : EndIf
               If State<-(max-\Thickness) : State=-(max-\Thickness) : EndIf
            EndIf
         EndIf
         
         If State
            \State=State
            \StatePercent=1e-14*Sign(State)
            If max : \StatePercent=\State / max : EndIf
         Else
            \State=1e-14*Sign(\StatePercent)
            \StatePercent=1e-14*Sign(\StatePercent)
         EndIf
         _ResizeGadget(*this, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndWith
   EndProcedure
   
   Procedure _SetGadgetAttribute(*this.Gadget, Attribute, Value)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         Select Attribute
            Case 0 To 1024
               ;Set original gadget attribute
               UseCustomGadget(*this, 0)
               SetGadgetAttribute(\Gadget, Attribute, Value)
               UseCustomGadget(*this, 1)
            Case #SplitBar_CurrentFlags : \Flags=Value
            Case #SplitBar_CurrentThickness : \Thickness=Value
            Case #SplitBar_CurrentFirstGadget : \Gadget1=Value
            Case #SplitBar_CurrentSecondGadget : \Gadget2=Value
            Case #SplitBar_CurrentSnapDistance : \SnapDistance=Abs(Value)
            Case #SplitBar_CurrentFirstMinSize : \FirstMinSize=Abs(Value)
            Case #SplitBar_CurrentSecondMinSize : \SecondMinSize=Abs(Value)
            Case #SplitBar_CurrentDrawingFunction : \DrawingFunction=Value
         EndSelect
         _ResizeGadget(*this, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndWith
   EndProcedure
   
   Procedure.i _GetGadgetAttribute(*this.Gadget, Attribute)
      Protected *CustomGadget.CustomGadget=*this\vt, result
      With *CustomGadget
         Select Attribute
            Case 0 To 1024
               ;Get original gadget attribute
               UseCustomGadget(*this, 0)
               result=GetGadgetAttribute(\Gadget, Attribute)
               UseCustomGadget(*this, 1)
            Case #SplitBar_CurrentFlags : result=\Flags
            Case #SplitBar_CurrentStatus : result=\CurrentStatus
            Case #SplitBar_CurrentThickness : result=\Thickness
            Case #SplitBar_CurrentFirstGadget : result=\Gadget1
            Case #SplitBar_CurrentSecondGadget : result=\Gadget2
            Case #SplitBar_CurrentSnapDistance : result=\SnapDistance
            Case #SplitBar_CurrentFirstMinSize : result=\FirstMinSize
            Case #SplitBar_CurrentSecondMinSize : result=\SecondMinSize
            Case #SplitBar_CurrentDrawingFunction : result=\DrawingFunction
         EndSelect
         ProcedureReturn result
      EndWith
   EndProcedure
   
   Procedure _FreeGadget(*this.Gadget)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         FreeCustomGadget(*this)
      EndWith
   EndProcedure
   
   Procedure CustomGadgetEvents()
      Protected t=EventType()
      Protected g=EventGadget()
      Protected *this.Gadget=IsGadget(g)
      Protected *CustomGadget.CustomGadget=*this\vt
      With *CustomGadget
         If (\Flags & #SplitBar_Locked)=0
            ;ignore some custom events
            Select t
               Case #PB_EventType_Change
                  ProcedureReturn
            EndSelect
            ;handle some custom events
            Protected win=EventWindow()
            Protected mx=_GetGadgetAttribute(*this, #PB_Canvas_MouseX)
            Protected my=_GetGadgetAttribute(*this, #PB_Canvas_MouseY)
            Protected oldStatus=\CurrentStatus, oldState=\State
            Select t
               Case #PB_EventType_MouseEnter
                  \CurrentStatus | #SplitBar_IsHighlighted
                  DrawCustomGadget(*this)
               Case #PB_EventType_MouseLeave
                  \CurrentStatus & ~#SplitBar_IsHighlighted
                  DrawCustomGadget(*this)
                 
               Case #PB_EventType_LeftButtonDown
                  If CustomContext\DraggedGadget=0
                     CustomContext\DraggedGadget=*CustomGadget
                     CustomContext\DragStartPos=\State
                     \CurrentStatus | #SplitBar_IsDragged
                     \DragOffsetX=mx
                     \DragOffsetY=my
                  EndIf
               Case #PB_EventType_LeftButtonUp, #PB_EventType_LeftDoubleClick
                  If CustomContext\DraggedGadget
                     CustomContext\DraggedGadget=0
                     \CurrentStatus & ~#SplitBar_IsDragged
                  EndIf
                 
               Case #PB_EventType_MouseMove
                  If (\CurrentStatus & #SplitBar_IsDragged)
                     If (\Flags & #SplitBar_Vertical)
                        If mx<>\DragOffsetX : _SetGadgetState(*this, \State + (mx-\DragOffsetX)) : EndIf
                     Else
                        If my<>\DragOffsetY : _SetGadgetState(*this, \State + (my-\DragOffsetY)) : EndIf
                     EndIf
                  EndIf
                  If (\Flags & #SplitBar_Vertical)
                     _SetGadgetAttribute(*this, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
                  Else
                     _SetGadgetAttribute(*this, #PB_Canvas_Cursor, #PB_Cursor_UpDown)
                  EndIf
            EndSelect
            ;post some custom events (new supported events)
            If t<>#PB_EventType_MouseMove And (oldStatus<>\CurrentStatus Or oldState<>\State)
               PostEvent(#PB_Event_Gadget, win, \Gadget, #PB_EventType_Change, \CurrentStatus)
            EndIf
         EndIf
      EndWith
   EndProcedure
   
   Procedure UseCustomGadget(*this.Gadget, isCustom)
      Protected *CustomGadget.CustomGadget=*this\vt
      Protected vtOld.GadgetVT     
      If Bool(isCustom)<>*CustomGadget\isCustom
         ;swap custom gadgetVT and original gadgetVT
         vtOld=*CustomGadget\vtOld
         *CustomGadget\vtOld=*CustomGadget\vt
         *CustomGadget\vt=vtOld
         *CustomGadget\isCustom=Bool(isCustom)
      EndIf
   EndProcedure
   
   Procedure DrawCustomGadget(*this.Gadget)
       Protected *CustomGadget.CustomGadget=*this\vt
       

       With *CustomGadget
         
           If \DrawingFunction             
            CallFunctionFast(\DrawingFunction, \Gadget)
            ProcedureReturn
         EndIf
         
         StartDrawing(CanvasOutput(\Gadget))
         Protected color
         If \CurrentStatus & #SplitBar_IsHighlighted
            color=\FrontColor
         Else
            color=\BackColor
         EndIf
         ;draw bar
         Box(0, 0, \w, \h, color)
         ;draw grip (if enabled)
         If \Flags & #SplitBar_Grip
            Protected i, x, y
            If \Flags & #SplitBar_Vertical
               x=0.5*\Thickness -1
               y=0.5*\h -7
               For i=0 To 12 Step 4
                  Box(x, y + i, 2, 2, \LineColor)
               Next
            Else
               x=0.5*\w -7
               y=0.5*\Thickness -1
               For i=0 To 12 Step 4
                  Box(x + i, y, 2, 2, \LineColor)
               Next
            EndIf
         EndIf
         StopDrawing()          
      EndWith
   EndProcedure
   
   Procedure FreeCustomGadget(*this.Gadget)
      ;find custom gadget data
      Protected *CustomGadget.CustomGadget=FindMapElement(CustomGadget(), "ID-" + *this\Gadget)
      With *CustomGadget
         If *CustomGadget
            ;free original gadget
            UseCustomGadget(*this, 0)
            FreeGadget(\Gadget)
            ;delete custom gadget data
            DeleteMapElement(CustomGadget())
         EndIf
      EndWith
   EndProcedure
   
   Procedure.i NewCustomGadget(*this.Gadget)
      ;create custom gadget data
      Protected *CustomGadget.CustomGadget=AddMapElement(CustomGadget(), "ID-" + *this\Gadget)
      If *CustomGadget
         *CustomGadget\isCustom=1
         CopyMemory(*this\vt, *CustomGadget\vtOld, SizeOf(GadgetVT))
         CopyMemory(*this\vt, *CustomGadget\vt, SizeOf(GadgetVT))
         With *CustomGadget\vt
            ;define mandatory custom method
            \FreeGadget=@_FreeGadget()
           
            ;define other custom methods
            \ResizeGadget=@_ResizeGadget()
            \GetGadgetState=@_GetGadgetState()
            \SetGadgetState=@_SetGadgetState()
            \GetGadgetColor=@_GetGadgetColor()
            \SetGadgetColor=@_SetGadgetColor()
            \GetGadgetAttribute=@_GetGadgetAttribute()
            \SetGadgetAttribute=@_SetGadgetAttribute()           
         EndWith
         
         *this\vt=*CustomGadget              ;apply custom gadgetVT
      EndIf
      ProcedureReturn *CustomGadget
   EndProcedure
   
   Procedure.i SplitterGadgetEx(Gadget, x, y, Width, Height, Gadget1=0, Gadget2=0, Flags=#SplitBar_Default, Thickness=6)
       Protected result=CanvasGadget(Gadget, x, y, Width, Height)
       

      If result=0 : ProcedureReturn #False : EndIf
      If Gadget=#PB_Any : Gadget=result : EndIf
      
      ;SetWindowLongPtr_(Gadget, #GWL_STYLE, GetWindowLongPtr_(Gadget, #GWL_STYLE) | #WS_CLIPCHILDREN)      
      Protected *this.Gadget=IsGadget(Gadget)
      Protected *CustomGadget.CustomGadget=NewCustomGadget(*this)

      With *CustomGadget
         ;define custom properties
         \x=x : \y=y : \w=Width : \h=Height
         \Gadget=Gadget
         \Gadget1=Gadget1
         \Gadget2=Gadget2
         \BackColor=#White
         \FrontColor=$DDDDDD
         \LineColor=#Gray
         \Flags=Flags
         \Thickness=Thickness
         If (\Flags & #SplitBar_Vertical)
            _SetGadgetState(*this, \w / 2-\Thickness / 2)
         Else
            _SetGadgetState(*this, \h / 2-\Thickness / 2)
         EndIf
         
         ;define custom events
         BindGadgetEvent(Gadget, @CustomGadgetEvents())
 
      EndWith
      ProcedureReturn result
   EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile
   ;********************
   ; EXAMPLE (modified)
   ;********************
   UseModule SplitterGadgetEx
   Runtime Enumeration
      #xml : #dialog : #win
      #Split0 : #Split1 : #Split2 : #Split3
      #Left : #Right : #Top : #Bottom : #Center
     
      #ColorContent=$484848
      #ColorBright=$777777
      #ColorDark=$232323
      #ColorGrip=$FFFFFF
   EndEnumeration
   
   Procedure SetGadgetColors(Gadget, BackColor=0, FrontColor=0, LineColor=0, TitleBackColor=0, TitleFrontColor=0)
      SetGadgetColor(Gadget, #PB_Gadget_FrontColor, FrontColor)
      SetGadgetColor(Gadget, #PB_Gadget_BackColor, BackColor)
      SetGadgetColor(Gadget, #PB_Gadget_LineColor, LineColor)
      SetGadgetColor(Gadget, #PB_Gadget_TitleBackColor, TitleBackColor)
      SetGadgetColor(Gadget, #PB_Gadget_TitleFrontColor, TitleFrontColor)
   EndProcedure
   Procedure ResizeSplitters()
      ResizeGadget(#Split3, 0, 0, WindowWidth(#win), WindowHeight(#win))
   EndProcedure
   
   Define xml$="<window id='#win' name='splitter' text='SplitBar Gadgets' width='600' height='300' " +
               "  flags='#PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget'>" +
               "" + ;"  <canvas id='#Split3' />" +
               "</window>"
   If CatchXML(#xml, @xml$, StringByteLength(xml$), 0, #PB_Ascii) And XMLStatus(#xml)=#PB_XML_Success And CreateDialog(#dialog) And OpenXMLDialog(#dialog, #xml, "splitter")
      SetWindowColor(#win, #ColorContent)
      ButtonGadget(#Top, 0, 0, 200, 32, "#Top")
      ButtonGadget(#Left, 0, 0, 200, 32, "#Left")
      ButtonGadget(#Right, 0, 0, 200, 32, "#Right")
      ButtonGadget(#Center, 0, 0, 200, 32, "#Center")
      ButtonGadget(#Bottom, 0, 0, 200, 32, "#Bottom")    
      SplitterGadgetEx(#Split0, 0, 0, 0, 0, #Center, #Bottom)
      SplitterGadgetEx(#Split1, 0, 0, 0, 0, #Left, #Split0, #SplitBar_Vertical | #SplitBar_FixedSize | #SplitBar_Grip)
        
      SplitterGadgetEx(#Split2, 0, 0, 0, 0, #Split1, #Right, #SplitBar_Vertical | #SplitBar_FixedSize | #SplitBar_Grip)
      SplitterGadgetEx(#Split3, 0, 0, 0, 0, #Top, #Split2, #SplitBar_FixedSize | #SplitBar_Locked, 2)
      BindEvent(#PB_Event_SizeWindow, @ResizeSplitters())
      ResizeWindow(#win, #PB_Ignore, #PB_Ignore, #PB_Ignore, 400)
      SetGadgetState(#Split3, 30)
      SetGadgetState(#Split2, -80)
      SetGadgetState(#Split1, 80)
      SetGadgetState(#Split0, -100)
      SetGadgetAttribute(#Split0, #SplitBar_CurrentFirstMinSize, 30)
      SetGadgetAttribute(#Split0, #SplitBar_CurrentSecondMinSize, 50)
      SetGadgetAttribute(#Split1, #SplitBar_CurrentSnapDistance, 80)
      SetGadgetAttribute(#Split2, #SplitBar_CurrentSnapDistance, 80)
      SetGadgetColors(#Split0, #ColorContent, #ColorBright, #ColorGrip)
      SetGadgetColors(#Split1, #ColorContent, #ColorBright, #ColorGrip)
      SetGadgetColors(#Split2, #ColorContent, #ColorBright, #ColorGrip)
      SetGadgetColors(#Split3, #ColorContent, #ColorBright, #ColorGrip)
      Repeat
         e=WaitWindowEvent()
         g=EventGadget()
         t=EventType()
         d=EventData()
         win=EventWindow()
         If t=#PB_EventType_LeftDoubleClick And g=#Split0
            SetGadgetState(g, -100)
            Debug "SplitBar=" + g + " is resetted"
         EndIf
         If t=#PB_EventType_Change
            Debug "SplitBar=" + g + " CurrentStatus=" + d + " State=" + GetGadgetState(g)
         EndIf
      Until e=#PB_Event_CloseWindow
   EndIf
CompilerEndIf
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 517
; FirstLine = 226
; Folding = ----
; EnableAsm
; EnableXP
; EnableUnicode