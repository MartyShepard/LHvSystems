
; Button Extended mit eigenm Bild
; Original Source vom Purebasic Board
; Editiert von Martin Schäfer
; - Geändert zu einem Modul was ausserhalb des programs läuft
; - Zentrierung des Textes mittels "DrawText" auf den Buttons Hinzugefügt
; 
; Events und Bild Konstante liegen in seperaten Source
DeclareModule ButtonEX  
            
    Enumeration 8601 Step 1
        #ButtonGadgetEx_Entered
        #ButtonGadgetEx_Released
        #ButtonGadgetEx_Pressed
    EndEnumeration
    
        EnumEnd =  8610
        EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
        Debug #TAB$ + "Constansts Enumeration : 8601 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: ButtonEX::(Module))"
        
;     Enums =  964 - #PB_Compiler_EnumerationValue
;     Debug "Enumeration = 960 -> " + #PB_Compiler_EnumerationValue +" /Max: 964 /Free: "+Str(Enums)+" ()" 
    
    ; 
    ; ButtonEX
    Declare     ButtonExEvent(GadgetID)
    
    Declare     Toggle(GadgetID, state)
    
    Declare     GetState(GadgetID)
    Declare     SetState(GadgetID, state)
    
    Declare.s   Gettext(GadgetID, TextID = 0)
    Declare     Settext(GadgetID, TextID = 0, szNewString.s = "")
    
    Declare.l   GetColor(GadgetID, Hover.i = #False)
    Declare     SetColor(GadgetID, RGB_Normal.l = $00FFFFFF, RGB_Hover.l = $00FFFFFF)
    
    Declare     Disable(GadgetID, state)
    Declare     IsEnabled(GadgetID)
    
    Declare     Add(GadgetID, x, y, Width, Height, ImageN,   ImageH,  ImageP, ImageD, TextN$="", TextH$="", TextP$="", ColorN.l=0, ColorH.l=0, FontID.l = 0)
    
EndDeclareModule

Module ButtonEX
    
 

    ;********************************************************************************************************************************
    ;Structure
    ;________________________________________________________________________________________________________________________________ 
    Structure gadgetex
        Pressed.i
        Disabled.i
        
        toggle.i
        toggled.i
        
        ImageNormal.i
        ImageOver.i
        ImagePressed.i
        ImageDisabled.i
        
        FACE.l
        
        TextNormal.s
        TextOver.s
        TextPressed.s 
        
        ColorOver.l
        
        Font.l
    EndStructure    
    
    ;********************************************************************************************************************************
    ;Set Text
    ;________________________________________________________________________________________________________________________________ 
    Procedure SetGadgetTextEx(_DRAWING, W.i,H.i, Text$ = "Not Clicked", TextColor.l = $00FFFFFF,FontID.l = 0)
        
        Protected TextSize.SIZE, CenterY.i ,CenterX.i
        
        SelectObject_(_DRAWING, FontID(FontID))
        
        GetTextExtentPoint32_(_DRAWING, Text$, Len(Text$), @TextSize) 
        Size.d = TextSize\cx
        SizY.d = TextSize\cy        
        
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawingFont(FontID(FontID))
        
        CenterY = Abs(H - TextSize\cy ) / 2
        CenterX = Abs(W - TextSize\cx) / 2        
        DrawText(CenterX,CenterY, Text$, TextColor)                
    EndProcedure     


    ;********************************************************************************************************************************
    ;GrayscaleCallback
    ;________________________________________________________________________________________________________________________________ 
    Procedure GrayscaleCallback(x, y, TopColor, BottomColor)
        Define Gray.i
        Gray = Red(TopColor)*0.56+Green(TopColor)*0.33+Blue(TopColor)*0.11+Alpha(BottomColor)
        ProcedureReturn Gray<<16+Gray<<8+Gray<<24+Gray
    EndProcedure

    ;********************************************************************************************************************************
    ;BoxDraw
    ;________________________________________________________________________________________________________________________________ 
    Procedure BoxDraw(GadgetID.i,CurrentImage.l,ColorN.l,Text$, TextColor.l,FontID.l)
        Protected _DRAWING        
        _DRAWING = StartDrawing(CanvasOutput(GadgetID))
        
        Box(0, 0, GadgetWidth(GadgetID), GadgetHeight(GadgetID), ColorN)
        
        DrawingMode(#PB_2DDrawing_AlphaBlend)
        DrawImage(ImageID(CurrentImage), 0, 0)
        
        
        ;Debug "BoxDraw(GadgetID.i,CurrentImage.l,ColorN.l,Text$, TextColor.l,FontID.l)"
        ;Debug Str(GadgetID)
        
        SetGadgetTextEx(_DRAWING,GadgetWidth(GadgetID), GadgetHeight(GadgetID),Text$,TextColor, FontID)
        
        StopDrawing()                
    EndProcedure  
          
    ;********************************************************************************************************************************
    ;Event Type
    ;________________________________________________________________________________________________________________________________ 
    Procedure ButtonExEvent(GadgetID)
        
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code #54GDEX"                  
            MessageRequester("Now Look What You've Done","Internal Error Code #54GDEX"+Str(GadgetID),0)
            ProcedureReturn
        EndIf 
        
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
                
        If *GadgetEx\Disabled = #False
            ;
            ;
            Select EventType()
                    ;
                    ;
                Case #PB_EventType_MouseMove 
                    If ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX) < 0 ) Or
                       ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY) < 0 ) Or
                       ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX) > GadgetWidth (GadgetID) ) Or
                       ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY) > GadgetHeight(GadgetID) ) Or ( *GadgetEx\Pressed = #False )
                    
                        If ( *GadgetEx\Pressed = #True )
                        
                            If ( *GadgetEx\toggle = #True) And ( *GadgetEx\toggled = #True )
                                BoxDraw(GadgetID.i,*GadgetEx\ImagePressed, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\ColorOver,*GadgetEx\Font)                            
                            Else
                                BoxDraw(GadgetID.i,*GadgetEx\ImageNormal, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\ColorOver,*GadgetEx\Font) 
                            EndIf
                            ProcedureReturn #ButtonGadgetEx_Released
                        EndIf
                    Else
                        BoxDraw(GadgetID.i,*GadgetEx\ImagePressed, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font) 
                    EndIf                                        
                    ;
                    ;
                Case #PB_EventType_MouseEnter
                    Select *GadgetEx\toggle
                        Case #True, #False
                            If ( *GadgetEx\toggled = #False )
                                BoxDraw(GadgetID.i,*GadgetEx\ImageOver, *GadgetEx\FACE,*GadgetEx\TextOver, *GadgetEx\ColorOver,*GadgetEx\Font)  
                                ProcedureReturn #ButtonGadgetEx_Entered
                            EndIf
                    EndSelect        
                    ;
                    ;
                Case #PB_EventType_MouseLeave
                    Select *GadgetEx\toggle
                        Case #True, #False
                            If ( *GadgetEx\toggled = #False )
                                BoxDraw(GadgetID.i,*GadgetEx\ImageNormal, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font)  
                                ProcedureReturn #ButtonGadgetEx_Released
                            EndIf
                    EndSelect                      
                    ;
                    ;
                Case #PB_EventType_LeftButtonUp
                    *GadgetEx\Pressed=#False
                    BoxDraw(GadgetID.i,*GadgetEx\ImageNormal, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font)                      
                    
                    If  ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX) > 0 ) And 
                        ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY) > 0 ) And
                        ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseX) < GadgetWidth (GadgetID) ) And
                        ( GetGadgetAttribute(GadgetID, #PB_Canvas_MouseY) < GadgetHeight(GadgetID) )
                    
                        If ( *GadgetEx\toggle = #True )
                             *GadgetEx\toggled!1
                        EndIf
                    
                        If ( *GadgetEx\toggle = #True ) And ( *GadgetEx\toggled = #True )
                            BoxDraw(GadgetID.i,*GadgetEx\ImagePressed, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font)                         
                        Else
                            BoxDraw(GadgetID.i,*GadgetEx\ImageOver, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font) 
                        EndIf                    
                        ProcedureReturn #ButtonGadgetEx_Pressed
                    EndIf                                    
                    ;
                    ;
                Case #PB_EventType_LeftButtonDown
                    *GadgetEx\Pressed = #True
                    BoxDraw(GadgetID.i,*GadgetEx\ImagePressed, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\ColorOver,*GadgetEx\Font)                  
                    ProcedureReturn -1                      
                Default
                    ProcedureReturn -1 
            EndSelect
        EndIf                        
    EndProcedure
    ;********************************************************************************************************************************
    ; Get Text
    ;________________________________________________________________________________________________________________________________     
    Procedure.s Gettext(GadgetID, TextID = 0)
        
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code on Gettext()" 
            ProcedureReturn
        EndIf            
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        
        Select TextID
            Case 0: ProcedureReturn *GadgetEx\TextNormal
            Case 1: ProcedureReturn *GadgetEx\TextOver
            Case 2: ProcedureReturn *GadgetEx\TextPressed
        EndSelect        
        
    EndProcedure
    ;********************************************************************************************************************************
    ;Get Color
    ;________________________________________________________________________________________________________________________________     
    Procedure.l GetColor(GadgetID, Hover.i = #False)
        
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code on Settext()" 
            ProcedureReturn
        EndIf            
        
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        If ( Hover = #False )
            ProcedureReturn  *GadgetEx\FACE
        Else
            ProcedureReturn  *GadgetEx\ColorOver
        EndIf
    EndProcedure      
    ;********************************************************************************************************************************
    ;Set Color
    ;________________________________________________________________________________________________________________________________     
    Procedure SetColor(GadgetID, RGB_Normal.l = $00FFFFFF, RGB_Hover.l = $00FFFFFF)
        
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code on Settext()" 
            ProcedureReturn
        EndIf            
        
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
            *GadgetEx\ColorOver  = RGB_Hover
            *GadgetEx\FACE       = RGB_Normal             
        
    EndProcedure     
    ;********************************************************************************************************************************
    ;Set Text
    ;________________________________________________________________________________________________________________________________     
    Procedure Settext(GadgetID, TextID = 0, szNewString.s = "")
        
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code on Settext()" 
            ProcedureReturn
        EndIf            
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        
        Select TextID
            Case 0: *GadgetEx\TextNormal  = szNewString
                
                    If *GadgetEx\toggled = #True
                        BoxDraw(GadgetID.i,*GadgetEx\ImagePressed, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font) 
                    Else
                        BoxDraw(GadgetID.i,*GadgetEx\ImageNormal,  *GadgetEx\FACE, *GadgetEx\TextNormal,*GadgetEx\FACE,*GadgetEx\Font)         
                    EndIf                
                
            Case 1: *GadgetEx\TextOver    = szNewString
            Case 2: *GadgetEx\TextPressed = szNewString
        EndSelect        
        
    EndProcedure      
    ;********************************************************************************************************************************
    ;Toggle
    ;________________________________________________________________________________________________________________________________     
    Procedure Toggle(GadgetID, state)
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code Toggle()"            
            MessageRequester("Now Look What You've Done","Internal Error Code #54GDEXTG"+Str(GadgetID),0)
            ProcedureReturn
        EndIf
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        *GadgetEx\toggle = state
    EndProcedure

    ;********************************************************************************************************************************
    ;GetState
    ;________________________________________________________________________________________________________________________________
    Procedure GetState(GadgetID)
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code #56GDEXTGS"            
            MessageRequester("Now Look What You've Done","Internal Error Code #56GDEXTGS"+Str(GadgetID),0)
            ProcedureReturn
        EndIf    
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        ProcedureReturn *GadgetEx\toggled
    EndProcedure

    ;********************************************************************************************************************************
    ;IsEnabled
    ;________________________________________________________________________________________________________________________________
    Procedure IsEnabled(GadgetID)
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code #56GDEXTGL"
            MessageRequester("Now Look What You've Done","Internal Error Code #56GDEXTGL"+Str(GadgetID),0)
            ProcedureReturn
        EndIf    
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        ProcedureReturn *GadgetEx\Disabled
    EndProcedure

    ;********************************************************************************************************************************
    ;SetState
    ;________________________________________________________________________________________________________________________________ 
    Procedure SetState(GadgetID, state)
        If Not IsGadget(GadgetID)
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Internal Error Code #58GDEXDS"
            MessageRequester("Now Look What You've Done","Internal Error Code #58GDEXDS"+Str(GadgetID),0)
            ProcedureReturn
        EndIf   
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        *GadgetEx\toggled = state
        
        If state=#True
            BoxDraw(GadgetID.i,*GadgetEx\ImagePressed, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font) 
        Else
            BoxDraw(GadgetID.i,*GadgetEx\ImageNormal, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font)         
        EndIf
    EndProcedure

    ;********************************************************************************************************************************
    ;Disable
    ;________________________________________________________________________________________________________________________________ 
    Procedure Disable(GadgetID, state)
        
        Protected *GadgetEx.gadgetex = GetGadgetData(GadgetID)
        
        *GadgetEx\Disabled = state
        
        DisableGadget(GadgetID, state)
        If state=#True          
            _DRAWING = StartDrawing(CanvasOutput(GadgetID))        
            Box(0, 0, GadgetWidth(GadgetID), GadgetHeight(GadgetID), *GadgetEx\FACE)   
            DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_AlphaClip    ) 
            CustomFilterCallback(@GrayscaleCallback())    
            If *GadgetEx\toggled=#True
                DrawImage(ImageID(*GadgetEx\ImageDisabled), 0, 0)
            Else
                DrawImage(ImageID(*GadgetEx\ImageDisabled), 0, 0)
            EndIf
            SetGadgetTextEx(_DRAWING,GadgetWidth(GadgetID), GadgetHeight(GadgetID),*GadgetEx\TextNormal.s,*GadgetEx\FACE, *GadgetEx\Font) ;// Disabled 1     
            StopDrawing()
            
        Else
            _DRAWING = StartDrawing(CanvasOutput(GadgetID))
            Box(0, 0, GadgetWidth(GadgetID), GadgetHeight(GadgetID), *GadgetEx\FACE)
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            If *GadgetEx\toggled=#True
                DrawImage(ImageID(*GadgetEx\ImagePressed), 0, 0)
            Else
                DrawImage(ImageID(*GadgetEx\ImageNormal), 0, 0)
            EndIf
            SetGadgetTextEx(_DRAWING,GadgetWidth(GadgetID), GadgetHeight(GadgetID),*GadgetEx\TextNormal.s,*GadgetEx\FACE, *GadgetEx\Font) ;// Disabled     
            StopDrawing()
        EndIf
    EndProcedure

    ;********************************************************************************************************************************
    ;Disable
    ;________________________________________________________________________________________________________________________________ 
    Procedure Add(GadgetID, x, y, Width, Height, ImageN,   ImageH,  ImageP, ImageD, TextN$="", TextH$="", TextP$="", ColorN.l=0, ColorH.l=0, FontID.l = 0)
        
        Dim PTS.Point(7)
        Dim Indx.I(7)
        
        CanvasGadget(GadgetID, x, y, Width, Height)
        
        Protected *GadgetEx.gadgetex = AllocateMemory(SizeOf(gadgetex))
        
        SetGadgetData(GadgetID,*GadgetEx)
        
        *GadgetEx\ImageNormal   = ImageN
        *GadgetEx\ImageOver     = ImageH
        *GadgetEx\ImagePressed  = ImageP
        *GadgetEx\ImageDisabled = ImageD
        
        Select ColorN
            Case 0
                ColorN = $00FFFFFF         
        EndSelect     
        *GadgetEx\FACE          = ColorN
        
        Select ColorH
            Case 0
                ColorH = $00FFFFFF         
        EndSelect     
        *GadgetEx\ColorOver     = ColorH
        
        *GadgetEx\TextNormal.s  = TextN$
        *GadgetEx\TextOver.s    = TextH$   
        *GadgetEx\TextPressed.s = TextP$   
        
        Select FontID
            Case 0
                FontID.l = LoadFont(#PB_Any,"Segoe UI", 9)           
        EndSelect         
        *GadgetEx\Font          =  FontID.l
        
        BoxDraw(GadgetID.i,*GadgetEx\ImageNormal, *GadgetEx\FACE,*GadgetEx\TextNormal, *GadgetEx\FACE,*GadgetEx\Font)  


EndProcedure
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 82
; FirstLine = 45
; Folding = ff7
; EnableAsm
; EnableXP
; CurrentDirectory = ..\..\LH Game Database\Release_Test\
; EnableUnicode