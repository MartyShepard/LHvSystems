; 
;   Button Extended mit eigenm Bild
;   Original Source vom Purebasic Board
;   Editiert von Martin Schäfer
;   - Geändert zu einem Modul was ausserhalb des programs läuft
;   - Zentrierung des Textes mittels "DrawText" auf den Buttons Hinzugefügt
;
;   03.07.18
;   - Komplett Überarbeitet
;   - Disable State vs Marked State fixed
;   - Zentrierung des Textes (Y) updated 
;
DeclareModule CheckBoxEX
    
    Enumeration 8621 Step 1
        #CheckBoxEx_Entered
        #CheckBoxEx_Released
        #CheckBoxEx_Pressed
    EndEnumeration
    
    EnumEnd =  8630
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
    Debug #TAB$ + "Constansts Enumeration : 8621 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: CheckBoxEx::(Module))"
    
    Declare Add(WindowID.l,GadgetID.l, 
                X.i,
                Y.i,      
                TextN$="",
                TextH$="",
                TextP$="",                  
                pNorm.l = -1,
                pHovr.l = -1,
                pHovP.l = -1,
                pHovD.l = -1,
                mNorm.l = -1,
                mHovh.l = -1,
                mHovP.l = -1,
                mHovD.l = -1,
                fnt.l = 0,
                RGB_TxtH.l=-1, RGB_TxtF.l=-1, RGB_TxtB.l=-1)
    
    Declare GetState(GadgetID.l)
    Declare SetState(GadgetID.l, state)
    Declare Disable(GadgetID.l, state)    
    Declare IsEnabled(GadgetID.l)
    
    Declare bxEvents(GadgetID.l)
    
EndDeclareModule

Module CheckBoxEX

    Structure CHECKBOXED_STRUCT
        Object.rect
        GadgetID.l
        Pressed.i      
        Disabled.i
        
        Marked.i
        
        TextN.s
        TextH.s
        TextP.s 
        TextSize.Size

        ColorTextFront.l        
        ColorTextBack.l
        ColorTextHover.l        
        FontID.l
        
        WindowID.l
        
        ImageID_Normal.l
        ImageID_Normal_Mark.l
        ImageID_Hover.l        
        ImageID_Hover_Mark.l
        ImageID_Press.l
        ImageID_Press_Mark.l
        ImageID_Disabled.l
        ImageID_Disabled_Mark.l
        
    EndStructure    
    ;********************************************************************************************************************************
    ; Zeichnet den Text Neben der Checkbox
    ; TODO:
    ; Links neben der Checkbox den Text Zeichnen
    ;________________________________________________________________________________________________________________________________          
    Procedure DrawTextString(*CheckBoxEx.CHECKBOXED_STRUCT, cTextColorRGB.l, cText.s)
        Protected CenterY.i
        
        DrawingMode(#PB_2DDrawing_Transparent) 
        
        Box( ImageWidth(*CheckBoxEx\ImageID_Normal), 0, GadgetWidth(*CheckBoxEx\GadgetID) + *CheckBoxEx\TextSize\cx + 2,  GadgetHeight(*CheckBoxEx\GadgetID), *CheckBoxEx\ColorTextBack)  
        
        DrawingFont(FontID(*CheckBoxEx\FontID))
        
        CenterY = Abs( GadgetHeight(*CheckBoxEx\GadgetID) - *CheckBoxEx\TextSize\cy ) / 2
        
        DrawText( ImageWidth(*CheckBoxEx\ImageID_Normal) + 2, CenterY, cText,  cTextColorRGB)   
                
    EndProcedure       
    ;********************************************************************************************************************************
    ;Erstellt das Checkbox Event
    ;________________________________________________________________________________________________________________________________  
    Procedure Draw_Event(*CheckBoxEx.CHECKBOXED_STRUCT, CurrentImageEventID.l, CurrentText$, CurrentRGB.l, FirstDraw = #False)
        
        Protected o.l  
        o.l = StartDrawing( CanvasOutput(*CheckBoxEx\GadgetID) )
        
            Box(0, 0, GadgetWidth(*CheckBoxEx\GadgetID), GadgetHeight(*CheckBoxEx\GadgetID), CurrentRGB)
            DrawingMode(#PB_2DDrawing_AlphaBlend)
            
            DrawImage  ( ImageID( CurrentImageEventID.l ), 0, 0 )
            
            SelectObject_(o.l, FontID(*CheckBoxEx\FontID) )
            
            GetTextExtentPoint32_(o, CurrentText$, Len(CurrentText$), @*CheckBoxEx\TextSize) 
            
            If ( FirstDraw = #True )
                StopDrawing()         
                ResizeGadget(*CheckBoxEx\GadgetID,#PB_Ignore,#PB_Ignore, GadgetWidth(*CheckBoxEx\GadgetID) + *CheckBoxEx\TextSize\cx +8, #PB_Ignore)        
                StartDrawing( CanvasOutput(*CheckBoxEx\GadgetID) )                
            EndIf    

            DrawTextString(*CheckBoxEx, CurrentRGB.l, CurrentText$) 
        StopDrawing()
    EndProcedure    
    ;********************************************************************************************************************************
    ;Event: MouseEnter
    ;________________________________________________________________________________________________________________________________    
    Procedure.i Draw_bxEvents_MouseEnter(*CheckBoxEx.CHECKBOXED_STRUCT)
        Protected cImageEvent.l, cTextString.s, cColorRGB.l
        
        ;
        ; Checkbox Markiert ? 
        cTextString.s = *CheckBoxEx\TextH 
        cColorRGB.l   = *CheckBoxEx\ColorTextHover    

        Select *CheckBoxEx\Marked 
            Case #False: cImageEvent.l = *CheckBoxEx\ImageID_Hover             
            Case #True : cImageEvent.l = *CheckBoxEx\ImageID_Hover_Mark                                  
        EndSelect 
        Debug "Draw_bxEvents_MouseEnter"   
        Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)                      
    EndProcedure     
    ;********************************************************************************************************************************
    ;Event: MouseLeave  
    ;________________________________________________________________________________________________________________________________     
    Procedure.i Draw_bxEvents_MouseLeave(*CheckBoxEx.CHECKBOXED_STRUCT)
        Protected cImageEvent.l, cTextString.s, cColorRGB.l
        
        ;
        ; Checkbox Markiert ?                 
        cColorRGB.l   = *CheckBoxEx\ColorTextFront

        
        Select *CheckBoxEx\Marked 
            Case #False
                cTextString.s = *CheckBoxEx\TextN                 
                cImageEvent.l = *CheckBoxEx\ImageID_Hover             
            Case #True
                cTextString.s = *CheckBoxEx\TextH                 
                cImageEvent.l = *CheckBoxEx\ImageID_Hover_Mark                                  
        EndSelect 
        Debug "Draw_bxEvents_MouseLeave"   
        Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)                      
    EndProcedure     
    ;********************************************************************************************************************************
    ;Event: #PB_EventType_MouseMove  
    ;________________________________________________________________________________________________________________________________     
    Procedure.i Draw_bxEvents_MouseMove(*CheckBoxEx.CHECKBOXED_STRUCT)
        Protected cImageEvent.l, cTextString.s, cColorRGB.l       
        
        If GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseX) <0 Or
           GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseY) <0 Or
           GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseX)> GadgetWidth(*CheckBoxEx\GadgetID) Or
           GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseY)> GadgetHeight(*CheckBoxEx\GadgetID)
            
            cColorRGB.l   = *CheckBoxEx\ColorTextHover
            
            If ( *CheckBoxEx\Pressed = #True )
                cTextString.s = *CheckBoxEx\TextP                 
                Select *CheckBoxEx\Marked 
                    Case #False: cImageEvent.l = *CheckBoxEx\ImageID_Press             
                    Case #True : cImageEvent.l = *CheckBoxEx\ImageID_Press_Mark                                  
                EndSelect 
            Else
                cTextString.s = *CheckBoxEx\TextH                
                Select *CheckBoxEx\Marked 
                    Case #False: cImageEvent.l = *CheckBoxEx\ImageID_Hover             
                    Case #True : cImageEvent.l = *CheckBoxEx\ImageID_Hover_Mark                                  
                EndSelect 
            EndIf
            Debug "Draw_bxEvents_MouseMove"            
            Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)             
        EndIf             
    EndProcedure
    ;********************************************************************************************************************************
    ;Event: #PB_EventType_LeftButtonUp   
    ;________________________________________________________________________________________________________________________________     
    Procedure.i Draw_bxEvents_LeftButtonUp(*CheckBoxEx.CHECKBOXED_STRUCT)
        Protected cImageEvent.l, cTextString.s, cColorRGB.l       
        
            cColorRGB.l   = *CheckBoxEx\ColorTextFront       
            cTextString.s = *CheckBoxEx\TextN
            
            Select *CheckBoxEx\Marked 
                Case #False
                    *CheckBoxEx\Marked = #True  
                    cImageEvent.l = *CheckBoxEx\ImageID_Normal_Mark             
                Case #True  
                    *CheckBoxEx\Marked = #False
                    cImageEvent.l = *CheckBoxEx\ImageID_Normal                                  
            EndSelect 
            Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)
            
        If  GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseX)>0 And
            GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseY)>0 And
            GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseX) < GadgetWidth(*CheckBoxEx\GadgetID) And
            GetGadgetAttribute(*CheckBoxEx\GadgetID, #PB_Canvas_MouseY) < GadgetHeight(*CheckBoxEx\GadgetID)                                
            
            cColorRGB.l   = *CheckBoxEx\ColorTextHover         
            cTextString.s = *CheckBoxEx\TextH
        
            Select *CheckBoxEx\Marked 
                Case #False: cImageEvent.l = *CheckBoxEx\ImageID_Hover  
                Case #True : cImageEvent.l = *CheckBoxEx\ImageID_Hover_Mark                         
            EndSelect  
            Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l) 
            
            Debug "Draw_bxEvents_LeftButtonUp"
            ProcedureReturn #CheckBoxEx_Pressed                              
       EndIf
                                                  
    EndProcedure    
    ;********************************************************************************************************************************
    ;Event: #PB_EventType_LeftButtonUp   
    ;________________________________________________________________________________________________________________________________     
    Procedure.i Draw_bxEvents_LeftButtonDown(*CheckBoxEx.CHECKBOXED_STRUCT)
        Protected cImageEvent.l, cTextString.s, cColorRGB.l      
        ;
        ;
        cColorRGB.l   = *CheckBoxEx\ColorTextHover        
        cTextString.s = *CheckBoxEx\TextP                     
        Select *CheckBoxEx\Marked 
            Case #False: cImageEvent.l = *CheckBoxEx\ImageID_Press             
            Case #True : cImageEvent.l = *CheckBoxEx\ImageID_Press_Mark                                  
        EndSelect 
        Debug "Draw_bxEvents_LeftButtonDown"
        Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)           
    EndProcedure      
    ;********************************************************************************************************************************
    ; Fragt die Events ab
    ;________________________________________________________________________________________________________________________________    
    Procedure bxEvents(GadgetID.l)
        
        Protected *CheckBoxEx.CHECKBOXED_STRUCT = GetGadgetData(GadgetID), Result.i
                
        If ( *CheckBoxEx\Disabled = #True )
            ProcedureReturn
        EndIf    
        
        Select *CheckBoxEx\Disabled
                ;
                ;
            Case #False
                Select EventType()
                        ;
                        ;
                    Case #PB_EventType_MouseMove
                        Draw_bxEvents_MouseMove(*CheckBoxEx.CHECKBOXED_STRUCT)
                        ProcedureReturn #CheckBoxEx_Released  
                        ;
                        ;
                    Case #PB_EventType_MouseEnter
                        Draw_bxEvents_MouseEnter(*CheckBoxEx.CHECKBOXED_STRUCT)
                        ProcedureReturn #CheckBoxEx_Entered      
                        
                    Case #PB_EventType_MouseLeave
                        Draw_bxEvents_MouseLeave(*CheckBoxEx.CHECKBOXED_STRUCT) 
                         ProcedureReturn #CheckBoxEx_Released 
                        ;
                    Case #PB_EventType_LeftButtonUp                        
                        Result = Draw_bxEvents_LeftButtonUp(*CheckBoxEx.CHECKBOXED_STRUCT)
                        ProcedureReturn Result
                        ;
                        ;
                    Case #PB_EventType_LeftButtonDown
                        Draw_bxEvents_LeftButtonDown(*CheckBoxEx.CHECKBOXED_STRUCT)
                        ProcedureReturn -1 
                        
                    Default                        
                EndSelect
        EndSelect                        
    EndProcedure          
    ;********************************************************************************************************************************
    ;GetState, Holt den Status der Checkbox
    ;________________________________________________________________________________________________________________________________ 
    Procedure GetState(GadgetID.l) 
        Protected *CheckBoxEx.CHECKBOXED_STRUCT = GetGadgetData(GadgetID)
        ProcedureReturn *CheckBoxEx\Marked
    EndProcedure
    ;********************************************************************************************************************************
    ;IsEnabled, Überprüft ob der Checkmark Button Eingeschaltet oder ausgeschaltet ist (Disable State)
    ;________________________________________________________________________________________________________________________________ 
    Procedure IsEnabled(GadgetID.l)          
        Protected *CheckBoxEx.CHECKBOXED_STRUCT = GetGadgetData(GadgetID)
        ProcedureReturn *CheckBoxEx\Disabled        
    EndProcedure
    ;********************************************************************************************************************************
    ;SetState, ändert den Status der Chekbox z.b Button, Menu
    ;________________________________________________________________________________________________________________________________ 
    Procedure SetState(GadgetID.l, state)  
        Protected *CheckBoxEx.CHECKBOXED_STRUCT = GetGadgetData(GadgetID)

        If ( *CheckBoxEx\Disabled = #True )
            ProcedureReturn
        EndIf    
        
        Protected cImageEvent.l, cTextString.s, cColorRGB.l
        cTextString.s      = *CheckBoxEx\TextN 
        cColorRGB.l        = *CheckBoxEx\ColorTextFront    
        *CheckBoxEx\Marked = state
        
        Select *CheckBoxEx\Marked 
            Case #False: cImageEvent.l = *CheckBoxEx\ImageID_Normal             
            Case #True : cImageEvent.l = *CheckBoxEx\ImageID_Normal_Mark                                  
        EndSelect 
        Debug "Draw_bxEvents_MouseEnter"   
        Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)          
    EndProcedure

    ;********************************************************************************************************************************
    ;Disable, Schaltet das Gadget aus/ ein
    ;________________________________________________________________________________________________________________________________ 
    Procedure Disable(GadgetID.l, state)               
        Protected *CheckBoxEx.CHECKBOXED_STRUCT = GetGadgetData(GadgetID)                        
        cTextString.s        = *CheckBoxEx\TextN 
        cColorRGB.l          = *CheckBoxEx\ColorTextFront    
        *CheckBoxEx\Disabled = state
        
        Select *CheckBoxEx\Disabled 
            Case #False
                Select *CheckBoxEx\Marked 
                    Case #False
                        cImageEvent.l = *CheckBoxEx\ImageID_Normal                         
                    Case #True
                        cImageEvent.l = *CheckBoxEx\ImageID_Normal_Mark                         
                EndSelect        
                
            Case #True
                Select *CheckBoxEx\Marked 
                    Case #False
                        cImageEvent.l = *CheckBoxEx\ImageID_Disabled                         
                    Case #True
                        cImageEvent.l = *CheckBoxEx\ImageID_Disabled_Mark 
                EndSelect                                                                                                   
        EndSelect 
        Debug "Draw_bxEvents_MouseEnter"   
        Draw_Event(*CheckBoxEx, cImageEvent.l, cTextString.s, cColorRGB.l)                
        DisableGadget(GadgetID, state)        
    EndProcedure
    ;********************************************************************************************************************************
    ;Hole Standard Bilder falss nicht anders angeben
    ;________________________________________________________________________________________________________________________________    
    Procedure Get_Default_Images(*CheckBoxEx.CHECKBOXED_STRUCT)
        DataSection
            _CBX_DEFA1_0N:     
            IncludeBinary "CheckboxEX_IMG\Checkbox_C0_N.png"
            
            _CBX_DEFA1_0H: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C0_H.png"
            
            _CBX_DEFA1_0P: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C0_P.png"    
            
            _CBX_DEFA1_0D: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C0_D.png"     
            
            _CBX_DEFA1_1N: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C1_N.png"
            
            _CBX_DEFA1_1H: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C1_H.png"
            
            _CBX_DEFA1_1P: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C1_P.png"    
            
            _CBX_DEFA1_1D: 
            IncludeBinary "CheckboxEX_IMG\Checkbox_C1_D.png"    ;Kein Disabled 
            
        EndDataSection
              
        *CheckBoxEx\ImageID_Normal       = CatchImage(#PB_Any, ?_CBX_DEFA1_0N)
        *CheckBoxEx\ImageID_Hover        = CatchImage(#PB_Any, ?_CBX_DEFA1_0H)
        *CheckBoxEx\ImageID_Press        = CatchImage(#PB_Any, ?_CBX_DEFA1_0P)
        *CheckBoxEx\ImageID_Disabled     = CatchImage(#PB_Any, ?_CBX_DEFA1_0D)
        
        *CheckBoxEx\ImageID_Normal_Mark  = CatchImage(#PB_Any, ?_CBX_DEFA1_1N)
        *CheckBoxEx\ImageID_Hover_Mark   = CatchImage(#PB_Any, ?_CBX_DEFA1_1H)
        *CheckBoxEx\ImageID_Press_Mark   = CatchImage(#PB_Any, ?_CBX_DEFA1_1P)
        *CheckBoxEx\ImageID_Disabled_Mark= CatchImage(#PB_Any, ?_CBX_DEFA1_1D)     
    EndProcedure
    ;********************************************************************************************************************************
    ;Hole Fraben
    ;________________________________________________________________________________________________________________________________              
    Procedure.l Get_RGB_TextHover(RGB_TxtH.l)
        
        Select RGB_TxtH.l
            Case -1
                RGB_TxtH.l = GetSysColor_(#COLOR_BTNSHADOW)                
        EndSelect 
        
        ProcedureReturn RGB_TxtH.l     
    EndProcedure    
    Procedure.l Get_RGB_TextFront(RGB_TxtF.l)
        
        Select RGB_TxtF.l
            Case -1
                RGB_TxtF.l = GetSysColor_(#COLOR_BTNTEXT)                
        EndSelect 
        
    ProcedureReturn RGB_TxtF.l    
    EndProcedure            
    Procedure.l Get_RGB_TextBack(WindowID.l, RGB_TxtB.l)
        
        If IsWindow(WindowID)
        Else
            If IsWindow( WindowID(WindowID) )
                WindowID =  WindowID(WindowID)
            EndIf
        EndIf
                
        
        Select RGB_TxtB.l 
            Case -1 
                If IsWindow(WindowID)                
                    RGB_TxtB.l = GetWindowColor(WindowID)    
                Else
                    RGB_TxtB.l = GetWindowColor( WindowID(WindowID) )
                EndIf  
                If ( RGB_TxtB.l = -1 )
                    RGB_TxtB.l = GetSysColor_(#COLOR_3DFACE)
                EndIf                 
        EndSelect         
        
        
        ProcedureReturn RGB_TxtB.l         
    EndProcedure
    Procedure.l Get_Font(fnt.l)
        Select fnt.l
            Case 0
                fnt.l = LoadFont(#PB_Any,"Segoe UI", 9)                
        EndSelect           
        ProcedureReturn fnt.l
    EndProcedure    
    Procedure.l Get_Images(pNorm, pHovr, pHovP, pHovD ,mNorm ,mHovh ,mHovP, mHovD, *CheckBoxEx.CHECKBOXED_STRUCT)
        
        If (pNorm.i = -1) And
           (pHovr.i = -1) And
           (pHovP.i = -1) And
           (pHovD.i = -1) And
           (mNorm.i = -1) And
           (mHovh.i = -1) And
           (mHovP.i = -1) And
           (mHovD.i = -1) 
            
            Get_Default_Images(*CheckBoxEx)
        Else
            *CheckBoxEx\ImageID_Normal       = pNorm
            *CheckBoxEx\ImageID_Hover        = pHovr
            *CheckBoxEx\ImageID_Press        = pHovP
            *CheckBoxEx\ImageID_Disabled     = pHovD
            
            *CheckBoxEx\ImageID_Normal_Mark  = mNorm
            *CheckBoxEx\ImageID_Hover_Mark   = mHovh
            *CheckBoxEx\ImageID_Press_Mark   = mHovP
            *CheckBoxEx\ImageID_Disabled_Mark= mHovD             
        EndIf
        ProcedureReturn -1            
    EndProcedure
    
    ;********************************************************************************************************************************
    ; Checkbox Gadetgt Hinzufügen
    ; WindowID.l    = WindowID
    ; GadgetID.l    = GadgetID
    ; X, Y          = Rechts, Oben (Weite und Höhe wird über das bild ermittelt
    ; pNorm         = ImageID (PB ImageID), Normal (Nichtmarkiert)
    ; pHovr         = ImageID (PB ImageID), Hover (Nichtmarkiert) (Wenn man mit Maus rübergeht)
    ; pHovP         = ImageID (PB ImageID), Pressed, Status (Nichtmarkiert)
    ; pHovD         = ImageID (PB ImageID), Disabled (Nichtmarkiert)
    ; mNorm         = ImageID (PB ImageID), Normal (markiert)
    ; mHovr         = ImageID (PB ImageID), Hover (markiert) (Wenn man mit Maus rübergeht)
    ; mHovP         = ImageID (PB ImageID), Pressed, Status (markiert)
    ; mHovD         = ImageID (PB ImageID), Disabled (markiert)    
    ; TextN$, TextH$, TextP$ = Title Normal, Hovered, Pressed
    ; fnt.l         = Purebasic FontID
    ; RGBn, RGBh    = Farbe (Normal, Hovered)
    ; RGB_TxtB      = Text Farbe Hintergrund
    ; RGB_TxtF      = Text Farbe
    ;________________________________________________________________________________________________________________________________ 
    Procedure Add(WindowID.l,GadgetID.l, 
                  X.i,
                  Y.i,      
                  TextN$="",
                  TextH$="",
                  TextP$="",                  
                  pNorm.l = -1,
                  pHovr.l = -1,
                  pHovP.l = -1,
                  pHovD.l = -1,
                  mNorm.l = -1,
                  mHovh.l = -1,
                  mHovP.l = -1,
                  mHovD.l = -1,
                  fnt.l = 0,
                  RGB_TxtH.l=-1, RGB_TxtF.l=-1, RGB_TxtB.l=-1)
               
        Protected TextSize.SIZE                               
        Protected *CheckBoxEx.CHECKBOXED_STRUCT = AllocateMemory( SizeOf(CHECKBOXED_STRUCT) )
        
        *CheckBoxEx\GadgetID             = GadgetID.l
        *CheckBoxEx\WindowID             = WindowID.l
        
        Get_Images(pNorm, pHovr, pHovP, pHovD ,mNorm ,mHovh ,mHovP, mHovD, *CheckBoxEx) 
                
        *CheckBoxEx\Object\right         = X
        *CheckBoxEx\Object\top           = Y                
        *CheckBoxEx\Object\left          = ImageWidth(*CheckBoxEx\ImageID_Normal)        
        *CheckBoxEx\Object\bottom        = ImageHeight(*CheckBoxEx\ImageID_Normal)
        
        *CheckBoxEx\TextN.s              = TextN$
        *CheckBoxEx\TextH.s              = TextH$   
        *CheckBoxEx\TextP.s              = TextP$   
             
        *CheckBoxEx\FontID               = Get_Font(fnt.l)
                       
        *CheckBoxEx\ColorTextFront       = Get_RGB_TextFront(RGB_TxtF) 
        *CheckBoxEx\ColorTextHover       = Get_RGB_TextHover(RGB_TxtH)          
        *CheckBoxEx\ColorTextBack        = Get_RGB_TextBack(WindowID, RGB_TxtB)
        
        *CheckBoxEx\Disabled             = #False

        
        CanvasGadget (*CheckBoxEx\GadgetID, *CheckBoxEx\Object\right, *CheckBoxEx\Object\top, *CheckBoxEx\Object\left, *CheckBoxEx\Object\bottom)        
        SetGadgetData(*CheckBoxEx\GadgetID, *CheckBoxEx)         
        Draw_Event(*CheckBoxEx, *CheckBoxEx\ImageID_Normal,  *CheckBoxEx\TextN, *CheckBoxEx\ColorTextFront, #True)        


EndProcedure
EndModule
CompilerIf #PB_Compiler_IsMainFile
    
    ;
    ; Nur in der #PB_Compiler_IsMainFile 
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
    #TextGadget = 600
    
    ;;
    ;;
    
    Enumeration 101 Step 1
        #_CBX_DEFA1_0N: #_CBX_DEFA1_0H: #_CBX_DEFA1_0P: #_CBX_DEFA1_0D: #_CBX_DEFA1_1N: #_CBX_DEFA1_1H: #_CBX_DEFA1_1P: #_CBX_DEFA1_1D:        
    EndEnumeration
    
    Enums =  200 - #PB_Compiler_EnumerationValue
  
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;
    ; Style als Verkürtzte proecdure   
    Procedure ChkBoxEx(WindowID.l, ObjectID,X.i,Y.i,Text1$="",Text2$="",Text3$="",ColorN.l = 0, ColorH.l = 0,FontID.l=0,Style=0); (Style 0 = Default Button)
        
        Select Style
            Case 0
                ;Die PNG Images MÜSSEN via Constante "angemeldet" werden
                CheckboxEX::Add(WindowID, ObjectID,X.i,Y.i,Text1$,Text2$,Text3$,
                                #_CBX_DEFA1_0N,
                                #_CBX_DEFA1_0H,
                                #_CBX_DEFA1_0H,
                                #_CBX_DEFA1_0D,
                                #_CBX_DEFA1_1N,
                                #_CBX_DEFA1_1H,
                                #_CBX_DEFA1_1H,
                                #_CBX_DEFA1_1D,FontID.l)
        EndSelect
    EndProcedure
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;
    ; Demo   
    
        OpenWindow(0, 100, 200, 560, 148, "Checkbox:EX Test", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_Invisible )
        
        CheckboxEX::Add(#Window_001, #CheckBox_001,10,20,"Checkbox","Checkbox","Checkbox")
        CheckboxEX::Add(#Window_001, #CheckBox_002,10,44,"Test Checkbox Long Name","Test Checkbox Long Name","Test Checkbox Long Name")
        
        ButtonGadget(#Button_001, 10,100,150,30,"Ist Markiert?")
        ButtonGadget(#Button_002, 164,100,150,30,"Checkmark Setzen / Entferne")
        ButtonGadget(#Button_003, 324,100,150,30,"Ein / Aus")
        
        TextGadget(#TextGadget, 10, 70, 500, 30,"")
        
        HideWindow(0,0)

   
        ;
        ;
        
        Repeat        
            Event = WaitWindowEvent()
            Select Event
                    
                Case #PB_Event_Gadget                   
                    Select EventGadget()
                        Case #CheckBox_001
                            Select CheckBoxEX::bxEvents(EventGadget()) 
                                    
                                Case CheckBoxEX::#CheckBoxEx_Entered                                   
                                Case CheckBoxEX::#CheckBoxEx_Released                                                                                                       
                                Case CheckBoxEX::#CheckBoxEx_Pressed                                                                        
                            EndSelect
                            
                        Case #Button_001
                            State.i = CheckBoxEX::GetState(#CheckBox_001)
                            Select State.i
                                Case #True                                   
                                    MessageRequester("CheckBoxEX", "Checkmark ist gesetzt")
                                Case #False    
                                    MessageRequester("CheckBoxEX", "Checkmark ist NICHT gesetzt")
                            EndSelect  
                            
                        Case #Button_002
                            State.i = CheckBoxEX::GetState(#CheckBox_001)
                            Select State.i
                                Case #True                                   
                                    CheckBoxEX::SetState(#CheckBox_001, #False)
                                    SetGadgetText(#TextGadget, "Status: Nicht Markiert")
                                Case #False    
                                    CheckBoxEX::SetState(#CheckBox_001, #True)
                                    SetGadgetText(#TextGadget, "Status: Markiert")                                    
                            EndSelect  
                            
                       Case #Button_003
                            State.i = CheckBoxEX::IsEnabled(#CheckBox_001)
                            Select State.i
                                    ;
                                    ; Checkbox ist disabled. Enable ihn                                    
                                Case #True                                         
                                    CheckBoxEX::Disable(#CheckBox_001, #False)
                                    SetGadgetText(#TextGadget, "Status: Enabled (Ein)")                                    
                                    ;
                                    ; Checkbox ist NICHT disabled. Disable ihn
                                Case #False    
                                    CheckBoxEX::Disable(#CheckBox_001, #True)
                                    SetGadgetText(#TextGadget, "Status: Disabled (Aus)")                                        
                            EndSelect                              
                    EndSelect        
            EndSelect               
        Until Event = #PB_Event_CloseWindow     
CompilerEndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 669
; FirstLine = 240
; Folding = DAA5
; EnableAsm
; EnableThread
; EnableXP
; EnablePurifier
; EnableUnicode