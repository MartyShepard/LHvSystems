;================================================================================================================================     
;   Font Dialog
;   Example 
;       Structure FONTPARAMS
;           fnName.s    ; Der Fontname
;           fnSize.i    ; Die grösse (Integer)
;           fColor.l    ; Fontname Text Farbe
;           Italic.i    ; Kursiv
;           IsBold.i    ; Fett
;           UnLine.i    ; Unterstrichen
;           Strike.i    ; Durchgestrichen
;           fontid.l    ; Die Purebasic Rückgabe ID
;       EndStructure   
;       
;       *font.FONTPARAMS = AllocateMemory(SizeOf(FONTPARAMS))
;       InitializeStructure(*font, FONTPARAMS) 
;       
;       *font\fnName = "Segoe UI"
;       *font\fnSize = 12
;       *font\fColor = $FFFFFF
;       *font\Italic = 0
;       *font\Strike = 0     
;       *font\UnLine = 0   
;
;       Dialog_Font() <- procedure Aufrufen
;       (Dinge erledigen)
;       ClearStructure(*font, FONTPARAMS)
;
;       Flags: #CF_FIXEDPITCHONLY           ChooseFont should enumerate and allow selection of only fixed-pitch fonts.
;_______________________________________________________________________________________________________________________________ 

CompilerIf #PB_Compiler_IsMainFile
  XIncludeFile "..\..\INCLUDES\Class_Debug_WM_MSG.pb" ; WM::
CompilerEndIf  
DeclareModule FontEX 
    
    Structure FONTPARAMS
        fnName.s    ; Der Fontname
        fnSize.l    ; Die grösse (Integer)
        fColor.l    ; Fontname Text Farbe
        Italic.i    ; Kursiv
        IsBold.i    ; Fett
        UnLine.i    ; Unterstrichen
        Strike.i    ; Durchgestrichen
        Qualty.l    ; Qualität oder Clear
        DTitle.s    ; Dialog Title
        Intern.b    ; Interner Front
        fontid.l    ; Die Purebasic Rückgabe ID
        Height.i    ; Höhe des Fenster
    EndStructure 
    
    Declare.i   Dialog_Font(*font.FONTPARAMS, StructChooseFontFlags.l = 0)
    Declare.i   Dialog_Font_Bold(*font.FONTPARAMS, EvntGadget.i)
    Declare.b   Dialog_Font_Neu(*font.FONTPARAMS, GadgetToPreview.i, ExtraFlags.l = 0, WindowHandle.l = 0)
    Declare.l   Dialog_Font_Read_InternDB(*font.FONTPARAMS,PB_GadgetID.i)
    
    
EndDeclareModule
Module FontEX
    ;
    ;
    ; Hook-Prozedur für Live-Preview
    Procedure.b FontHook_Proc()
      
      Shared *TargetGadget, *CurrentFont.FONTPARAMS, lf.LOGFONT
      
      Protected FontName.s  = PeekS(@lf\lfFaceName)

      Protected hdc = GetDC_(hWnd)
      Protected Size.l = -MulDiv_(lf\lfHeight, 72, GetDeviceCaps_(hdc, #LOGPIXELSY))
      ReleaseDC_(hWnd, hdc)
            
      Protected Style.i = 0
      If lf\lfWeight >= #FW_BOLD : Style | #PB_Font_Bold      : EndIf
      If lf\lfItalic             : Style | #PB_Font_Italic    : EndIf
      If lf\lfStrikeOut          : Style | #PB_Font_StrikeOut : EndIf
      If lf\lfUnderline          : Style | #PB_Font_Underline : EndIf
      
      
      Debug ""            
      Debug "Selected Fontname : " + FontName
      Debug "Selected FontSize : " + Str(Size)
      Debug "Selected FnWeight : " + Str(lf\lfWeight)
      Debug "Selected FnItalic : " + Str(lf\lfItalic)
      Debug "Selected StrikeOut: " + Str(lf\lfStrikeOut)
      Debug "SelectedUnderline : " + Str(lf\lfUnderline)      
      Debug "Selected FnStyle  : " + Str(Style)       
      Debug "======================================="        
      
      Protected TempFont.l = LoadFont(#PB_Any, FontName, Size, Style | #PB_Font_HighQuality)
      If TempFont 
        SetGadgetFont(*TargetGadget, FontID(TempFont))
        If (DC::#Text_001 = *TargetGadget)
          SetGadgetFont(DC::#Text_002, FontID(TempFont))
        EndIf
        ;Freefont kann nicht angwendet werden weil sonst der Schrit Vorschau für die Listicon Box nicht funktioniert
        ;FreeFont(TempFont)
      EndIf
      ProcedureReturn #True
    EndProcedure    
    ;
    ;
    ; Wert (wParam >> 16)
    ; Konstante     Bedeutung
    ; 1             #CBN_SELCHANGE    Auswahl wurde geändert
    ; 2             #CBN_DBLCLK       Doppelklick
    ; 3             #CBN_SETFOCUS     ComboBox hat Fokus bekommen
    ; 4             #CBN_KILLFOCUS    ComboBox hat Fokus verloren
    ; 5             #CBN_EDITCHANGE   Text im Edit-Feld wurde geändert
    ; 6             #CBN_EDITUPDATE   Edit-Feld wird aktualisiert
    ; 9             #CBN_DROPDOWN     Dropdown-Liste wird aufgeklappt
    ; 10            #CBN_CLOSEUP      Dropdown-Liste wird geschlossen
    ; 11            #CBN_SELENDOK     Auswahl bestätigt (OK)
    ; 12            #CBN_SELENDCANCEL Auswahl abgebrochen
    ; 
    ;     
    Global LogFont_Old.LOGFONT
    Global DlgTitle.s = ""
    
    Macro LOWORD( word )   : (word & $FFFF)             : EndMacro
    Macro HIWORD( word )   : ((word >> 16) & $FFFF)     : EndMacro
    ;
    ;
    Procedure.l FontHook_GetRGB(cbSelection.i = 0)
      Protected FontFarbe.l, FarbName.s = ""
      
      Select cbSelection
        Case 0
          FarbName  = "Schwarz"
          FontFarbe = RGB(0,0,0)
          
        Case 1
          FarbName  = "Kastanienbraun - Long 128"
          FontFarbe = RGB(128,0,0)
          
        Case 2
          FarbName  = "Grün - Long 32768"
          FontFarbe = RGB(0,128,0)        
          
        Case 3
          FarbName  = "Olivegrün - Long 32896"
          FontFarbe = RGB(128,128,0)         
          
        Case 4
          FarbName  = "Marineblau - Long 8388608"
          FontFarbe = RGB(0,0,128) 
          
        Case 5
          FarbName  = "Lila - Long 8388736"
          FontFarbe = RGB(128,0,128)
          
        Case 6
          FarbName  = "Blaugrün - Long 8421376"
          FontFarbe = RGB(0,128,128)
          
        Case 7
          FarbName  = "Grau - Long 8421504"
          FontFarbe = RGB(128,128,128)
          
        Case 8
          FarbName  = "Silber - Long 12632256"
          FontFarbe = RGB(192,192,192)
          
        Case 9
          FarbName  = "Rot - Long 255"
          FontFarbe = RGB(255,0,0)
          
        Case 10
          FarbName  = "Gelbgrün - Long 65280"
          FontFarbe = RGB(0,255,0)
          
        Case 11
          FarbName  = "Gelb - Long 65535"
          FontFarbe = RGB(255,255,0)
          
        Case 12
          FarbName  = "Blaugrün - Long 16711680"
          FontFarbe = RGB(0,0,255)
          
        Case 13
          FarbName  = "Violett - Long 16711935"
          FontFarbe = RGB(255,0,255 )
          
        Case 14
          FarbName  = "Aquamarin - Long 16776960"
          FontFarbe = RGB(0,255,255)
          
        Case 15
          FarbName  = "Weiß - Long 16777215"
          FontFarbe = RGB(255,255,255)
          
        Default
        ProcedureReturn RGB(0,0,0)  
      EndSelect
      
      Debug "Selected FontColr : " + FarbName
      ProcedureReturn FontFarbe
      
    EndProcedure
    Procedure.b FontDialogHook(hWnd.l, Msg.l, wParam.l, lParam.l)
      
      Shared *TargetGadget, *CurrentFont.FONTPARAMS, lf.LOGFONT, lpcf.CHOOSEFONT 
     
      Select Msg
        Case #WM_INITDIALOG
          
          If lpcf
            ; Zeiger auf unsere Struktur holen
            *CurrentDialog = lpcf\lCustData
            
            If *CurrentDialog
              ; Fenster-Titel setzen
              SetWindowText_(hWnd, DlgTitle)
              
              ; Dialog zentrieren
              Protected r1.RECT, r2.RECT
              GetWindowRect_(hWnd, @r2)
              SystemParametersInfo_(#SPI_GETWORKAREA, 0, @r1, 0)
              
              Protected x = (r1\right  - (r2\right  - r2\left)) / 2
              Protected y = (r1\bottom - (r2\bottom - r2\top)) / 2
              
              
              MoveWindow_(hWnd, x, y+*CurrentFont\Height , r2\right-r2\left, r2\bottom-r2\top, #True)
              
              ; Hintergrundfarbe (z.B. Hellgrau)
              If hBrush
                DeleteObject_(hBrush)
              EndIf
              hBrush = CreateSolidBrush_(RGB(240,240,240))
              CopyMemory(@lf, @LogFont_Old, SizeOf(LOGFONT))                
            EndIf
          EndIf
          
        Case #WM_CTLCOLORLISTBOX
          ;Debug "#WM_CTLCOLORLISTBOX"
        Case #WM_CTLCOLORDLG, #WM_CTLCOLORSTATIC

          If hBrush
            SetBkMode_(wParam, #TRANSPARENT)
            SetBkColor_(wParam, RGB(240,240,240))                            
            ProcedureReturn hBrush
          EndIf
          
        Case #WM_LBUTTONDOWN,#WM_LBUTTONUP,#WM_NOTIFY,#WM_ACTIVATE
            If (Msg = #WM_NOTIFY)
              SetTimer_(hWnd,1,1,#Null)
            EndIf
            SendMessage_(hWnd, #WM_CHOOSEFONT_GETLOGFONT, 0, @lf)
            ProcedureReturn #True
          
       Case #WM_DESTROY
          If hBrush
            DeleteObject_(hBrush)
            hBrush = 0
          EndIf
          Protected Class.s = Space(64)
          GetClassName_(hWnd,@Class,64)
          ;Debug "Destroy HWND = " + Hex(hWnd)
          ;Debug "Class = " + PeekS(@Class)
          
        Case #WM_CHOOSEFONT_SETLOGFONT        
          FontHook_Proc()
          FillMemory( @LogFont_Old, 0)
          SendMessage_(hWnd, #WM_DESTROY, 0, 0)
          
        Case #WM_CHOOSEFONT_SETFLAGS                    
        Case #WM_CHOOSEFONT_GETLOGFONT
          If CompareMemory(@lf,@LogFont_Old,SizeOf(LOGFONT)) = 0
            FontHook_Proc()
            CopyMemory(@lf, @LogFont_Old, SizeOf(LOGFONT)) 
          EndIf
          
        Case #WM_TIMER
          SetTimer_(hWnd,1,1,#Null)
        Case #WM_COMMAND        
          If (msg = #WM_COMMAND)
            
            Define nLOW.w = LOWORD(wParam)
            Define nHIW.w = HIWORD(wParam)            
            
            Select nLOW
              Case #CBN_SELCHANGE
                ;
                ; Standard Selektion                
                SendMessage_(hWnd, #WM_CHOOSEFONT_GETLOGFONT, 0, @lf)
                FillMemory( @LogFont_Old, 0)
              Case 9
                ;
                ; Standard Selektion                
                SendMessage_(hWnd, #WM_CHOOSEFONT_GETLOGFONT, 0, @lf)
                FillMemory( @LogFont_Old, 0)                
              Case 3,4
                ;
                ; Focus eigenschaft
                ProcedureReturn #False
              Case 1040, 1041
                ;
                ; Checkbox Durchgestrichen
                SendMessage_(hWnd, #WM_CHOOSEFONT_GETLOGFONT, 0, @lf)
                FillMemory( @LogFont_Old, 0)
                ProcedureReturn #True             
              Case 1139
                cbHwnd.l = GetDlgItem_(hWnd,1139)
                Select nHIW
                  Case #CBN_SELCHANGE
                    ;Debug "Farbe geändert" 
                    ;Debug "Farbe: " + Str(lpcf\rgbColors)                    
                  Case #CBN_SELENDOK
                    ;Debug  "endgültig ausgewählt"
                    ;Debug "Farbe: " + Str(lpcf\rgbColors)                    
                    lpcf\rgbColors = FontHook_GetRGB(SendMessage_(cbHwnd,#CB_GETCURSEL,0,0))
                    SetGadgetColor(*TargetGadget, #PB_Gadget_FrontColor , lpcf\rgbColors)
                    If (DC::#Text_001 = *TargetGadget)
                        SetGadgetColor(DC::#Text_002, #PB_Gadget_FrontColor , lpcf\rgbColors)
                    EndIf                    
                    FontHook_Proc()
                EndSelect                
                Debug "Aktuelles Item: "+Str(SendMessage_(cbHwnd,#CB_GETCURSEL,0,0))
                
              Default
                Debug "unknown #WM_COMMAND Loword: "+ Str(nLOW)
            EndSelect
            
            Select nHIW    
              Case 0
                ;
                ; Aktiviert das aussteigen
                SendMessage_(hWnd, #WM_DESTROY, 0, 0) 
              Default
                Debug "Unknown #WM_COMMAND HiWord: "+ Str(nHIW)                
            EndSelect
          EndIf
          
        Case #WM_PAINT         
        Default
          ;WM::DebugConstant(Msg)
          ;Debug "hwnd = " + Str(hwnd)
      EndSelect
      
      ProcedureReturn #False
    EndProcedure
    ;
    ;
    Procedure.b Dialog_Font_Neu(*font.FONTPARAMS, GadgetToPreview.i, ExtraFlags.l = 0, WindowHandle.l = 0)
        
       ; Protected lf.LOGFONT, lpcf.CHOOSEFONT
        Protected hdc.l = CreateDC_("DISPLAY", 0, 0, 0)
        Protected Result.i = #False
        
        Shared *TargetGadget, *CurrentFont.FONTPARAMS, lf.LOGFONT, lpcf.CHOOSEFONT   ; Für Hook
        
        *TargetGadget = GadgetToPreview
        *CurrentFont  = *font

        ; Standardwerte
        
        If ( Len(*font\fnName) = 0 )
                 *font\fnName = "Segoe UI"
        EndIf
        
        If ( *font\fnSize = 0 )
             *font\fnSize = 12
        EndIf
                 
        ; LOGFONT füllen
        lf\lfHeight = -MulDiv_(*font\fnSize, GetDeviceCaps_(hdc, #LOGPIXELSY), 72)
        lf\lfWeight = *font\IsBold
        
        If *font\Italic : lf\lfItalic    = #True : EndIf
        If *font\Strike : lf\lfStrikeOut = #True : EndIf
        If *font\UnLine : lf\lfUnderline = #True : EndIf
        
        
        PokeS(@lf\lfFaceName, *font\fnName, #LF_FACESIZE)
        
        DeleteDC_(hdc)
        
        ; CHOOSEFONT
        lpcf\lStructSize  = SizeOf(CHOOSEFONT)
        lpcf\hwndOwner    = WindowHandle          ; oder deine Fenster-ID
        lpcf\lpLogFont    = @lf
        lpcf\Flags        = #CF_INITTOLOGFONTSTRUCT | #CF_BOTH| #CF_ENABLEHOOK |#CF_WYSIWYG | #CF_EFFECTS | ExtraFlags
        lpcf\rgbColors    = *font\fColor
        lpcf\lpfnHook     = @FontDialogHook()
        lpcf\lCustData    = *font          ; Wichtig: Zeiger auf unsere Struktur
        lpcf\hDC          = hdc
        
        DlgTitle = *font\DTitle
        
        If ChooseFont_(@lpcf)
                      
            *font\IsBold = #Null
            *font\Italic = #Null          
            *font\UnLine = #Null
            *font\Strike = #Null
            
            Protected Style.i = 0
            
            Select lf\lfWeight
                Case #FW_DONTCARE   : Style = 0            : *font\IsBold = #FW_DONTCARE
                Case #FW_THIN       : Style = 0            : *font\IsBold = #FW_THIN
                Case #FW_EXTRALIGHT : Style = 0            : *font\IsBold = #FW_EXTRALIGHT
                Case #FW_ULTRALIGHT : Style = 0            : *font\IsBold = #FW_ULTRALIGHT                 
                Case #FW_LIGHT      : Style = 0            : *font\IsBold = #FW_LIGHT                
                Case #FW_NORMAL     : Style = 0            : *font\IsBold = #FW_NORMAL  
                Case #FW_REGULAR    : Style = 0            : *font\IsBold = #FW_REGULAR          
                Case #FW_MEDIUM     : Style = 0            : *font\IsBold = #FW_MEDIUM      
                Case #FW_SEMIBOLD   : Style = 0            : *font\IsBold = #FW_SEMIBOLD       
                Case #FW_DEMIBOLD   : Style = 0            : *font\IsBold = #FW_DEMIBOLD          
                Case #FW_BOLD       : Style = #PB_Font_Bold: *font\IsBold = #FW_BOLD
                Case #FW_EXTRABOLD  : Style = 0            : *font\IsBold = #FW_EXTRABOLD          
                Case #FW_ULTRABOLD  : Style = 0            : *font\IsBold = #FW_ULTRABOLD            
                Case #FW_HEAVY      : Style = 0            : *font\IsBold = #FW_HEAVY       
                Case #FW_BLACK      : Style = 0            : *font\IsBold = #FW_BLACK       
              EndSelect
              
            ; === OK geklickt → endgültig übernehmen ===
            *font\fnName = PeekS(@lf\lfFaceName)
            *font\fnSize = lpcf\iPointSize / 10
            *font\fColor = lpcf\rgbColors
             
            If ( lf\lfItalic <> 0 )
                Style = Style|#PB_Font_Italic:     
                *font\Italic = #PB_Font_Italic
            EndIf  
            If ( lf\lfUnderline <> 0 )
                Style = Style|#PB_Font_Underline
                *font\UnLine = #PB_Font_Underline
            EndIf              
            If ( lf\lfStrikeOut <> 0 )
                Style = Style|#PB_Font_StrikeOut
                *font\Strike = #PB_Font_StrikeOut
           EndIf  
           
            Debug "Übernommen - Fontname: " + *font\fnName
            Debug "               Size  : " + Str(lpcf\iPointSize/10)
            Debug "               Bold  : " + Str(lf\lfWeight)
            Debug "             Italic  : " + Str(lf\lfItalic)           
            Debug "          Underline  : " + Str(lf\lfUnderline)   
            Debug "          StrikeOut  : " + Str(lf\lfStrikeOut)
            Debug "          Color      : " + Str(*font\fColor)   
            
           ; If lf\lfWeight >= #FW_BOLD     : Style | #PB_Font_Bold      : EndIf
           ; If lf\lfItalic                 : Style | #PB_Font_Italic    : EndIf
           ; If lf\lfUnderline              : Style | #PB_Font_Underline : EndIf
           ; If lf\lfStrikeOut              : Style | #PB_Font_StrikeOut : EndIf
            
            ; Alten Font freigeben
            ;If *font\fontid : FreeFont(*font\fontid) : EndIf
            
            *font\fontid = LoadFont(#PB_Any, *font\fnName, *font\fnSize, Style | #PB_Font_HighQuality)
            
            ; Endgültig auf Gadget anwenden
            ;If GadgetToPreview
            ;    SetGadgetFont(GadgetToPreview, *font\fontid
            ;EndIf
            
            Result = #True
        EndIf
        
        ProcedureReturn Result
    EndProcedure    
    ;
    ; 
    Procedure.i Dialog_Font(*font.FONTPARAMS, StructChooseFontFlags.l = 0)
        
        Protected hdc.l, lf.LOGFONT, lpcf.CHOOSEFONT, GetFontID.l, PBWeightType.l
        
        hdc = CreateDC_("DISPLAY",0,0,0)
        
        If ( Len(*font\fnName) = 0 )
            *font\fnName = "Segoe UI"
        EndIf
        
        If ( *font\fnSize = 0 )          
            *font\fnSize = 12
        EndIf
        
        If ( *font\fontid = 0 )
            *font\fontid = LoadFont(#PB_Any, *font\fnName , *font\fnSize, *font\IsBold|
                                                                          *font\Italic|
                                                                          *font\Strike|
                                                                          *font\UnLine|
                                                                          #PB_Font_HighQuality)  
        EndIf    
        
        lf\lfHeight       = -MulDiv_(*font\fnSize,GetDeviceCaps_(hdc,#LOGPIXELSX),72)
        lf\lfWeight       = *font\IsBold   
        
        If ( *font\Italic = #PB_Font_Italic )
            lf\lfItalic     = #True
        EndIf
        
        If ( *font\Strike = #PB_Font_StrikeOut )                
            lf\lfStrikeOut  = #True
        EndIf
        
        If ( *font\UnLine = #PB_Font_Underline )                  
            lf\lfUnderline  = #True
        EndIf        
        
        PokeS(@lf\lfFaceName,*font\fnName)
        
        DeleteDC_(hdc)
          
        lpcf.CHOOSEFONT
        lpcf\lStructSize  = SizeOf(CHOOSEFONT)
        
        lpcf\lpLogFont    = lf           
        lpcf\Flags        =  #CF_EFFECTS| #CF_INITTOLOGFONTSTRUCT | #CF_BOTH | StructChooseFontFlags ;#CF_TTONLY| #CF_FIXEDPITCHONLY     
        lpcf\rgbColors    = *font\fColor 
        
        If ( ChooseFont_(lpcf) = #True )
            Debug "Fontname: " + PeekS(@lf\lfFaceName)
            Debug "  Size  : " + Str(lpcf\iPointSize/10)
            Debug "  Bold  : " + Str(lf\lfWeight)
            Debug "  Italic: " + Str(lf\lfItalic)
            
            *font\IsBold = #Null
            *font\Italic = #Null          
            *font\UnLine = #Null
            *font\Strike = #Null
            *font\fColor = lpcf\rgbColors
            
            Select lf\lfWeight
                Case #FW_DONTCARE   : PBWeightType = 0            : *font\IsBold = #FW_DONTCARE
                Case #FW_THIN       : PBWeightType = 0            : *font\IsBold = #FW_THIN
                Case #FW_EXTRALIGHT : PBWeightType = 0            : *font\IsBold = #FW_EXTRALIGHT
                Case #FW_ULTRALIGHT : PBWeightType = 0            : *font\IsBold = #FW_ULTRALIGHT                 
                Case #FW_LIGHT      : PBWeightType = 0            : *font\IsBold = #FW_LIGHT                
                Case #FW_NORMAL     : PBWeightType = 0            : *font\IsBold = #FW_NORMAL  
                Case #FW_REGULAR    : PBWeightType = 0            : *font\IsBold = #FW_REGULAR          
                Case #FW_MEDIUM     : PBWeightType = 0            : *font\IsBold = #FW_MEDIUM      
                Case #FW_SEMIBOLD   : PBWeightType = 0            : *font\IsBold = #FW_SEMIBOLD       
                Case #FW_DEMIBOLD   : PBWeightType = 0            : *font\IsBold = #FW_DEMIBOLD          
                Case #FW_BOLD       : PBWeightType = #PB_Font_Bold: *font\IsBold = #FW_BOLD
                Case #FW_EXTRABOLD  : PBWeightType = 0            : *font\IsBold = #FW_EXTRABOLD          
                Case #FW_ULTRABOLD  : PBWeightType = 0            : *font\IsBold = #FW_ULTRABOLD            
                Case #FW_HEAVY      : PBWeightType = 0            : *font\IsBold = #FW_HEAVY       
                Case #FW_BLACK      : PBWeightType = 0            : *font\IsBold = #FW_BLACK       
            EndSelect
            
            *font\fnName = PeekS(@lf\lfFaceName)
            *font\fnSize = lpcf\iPointSize/10
            
            If ( lf\lfItalic = -1 )
                PBWeightType = PBWeightType|#PB_Font_Italic:     
                *font\Italic = #PB_Font_Italic
            EndIf  
            If ( lf\lfUnderline = 1 )
                PBWeightType = PBWeightType|#PB_Font_Underline
                *font\UnLine = #PB_Font_Underline
            EndIf              
            If ( lf\lfStrikeOut = 1 )
                PBWeightType = PBWeightType|#PB_Font_StrikeOut
                *font\Strike = #PB_Font_StrikeOut
            EndIf      
            
            *font\fontid = LoadFont(#PB_Any, *font\fnName , *font\fnSize , PBWeightType|#PB_Font_HighQuality)                      
            ProcedureReturn  #True
            
        EndIf
        ProcedureReturn  #False 
    EndProcedure
    ;
    ;     
    Procedure.i Dialog_Font_Bold(*font.FONTPARAMS, EvntGadget.i)
        Protected fnt.l, szFace.s
        
        If IsGadget( EvntGadget )
            
            hdc = CreateDC_("DISPLAY",0,0,0)
            
            fnt = SendMessage_(GadgetID( EvntGadget ) ,#WM_GETFONT,0,0)
            
            GetObject_( fnt, SizeOf(LOGFONT) , lg.LOGFONT )
            
            PokeS(@lg\lfFaceName,*font\fnName)
            
            lg\lfHeight     = -MulDiv_(*font\fnSize,GetDeviceCaps_(hdc,#LOGPIXELSX),72)
            
            If ( *font\Italic = #PB_Font_Italic )
                lg\lfItalic = #True
            EndIf
                        
            If ( *font\Strike = #PB_Font_StrikeOut )                
                lg\lfStrikeOut  = #True
            EndIf
            
            If ( *font\UnLine = #PB_Font_Underline )                  
                lg\lfUnderline  = #True
            EndIf
            
            lg\lfQuality = #CLEARTYPE_QUALITY            
            lg\lfWeight = *font\IsBold
            
            fnt = CreateFontIndirect_(lg)
            SendMessage_(GadgetID( EvntGadget ) , #WM_SETFONT, fnt, 1)
            
        EndIf  
      EndProcedure
      ;
      ;
      Procedure.l Dialog_Font_Read_InternDB(*font.FONTPARAMS,PB_GadgetID.i)
        
        If IsGadget( PB_GadgetID )
          Define hdc.l = CreateDC_("DISPLAY",0,0,0)
          
          Define Fnt.l = SendMessage_(GadgetID( PB_GadgetID ) ,#WM_GETFONT,0,0)
          If (Fnt = 0)
            ;
            ; Versuche es mit dem Gadget
            Fnt = GetGadgetFont(PB_GadgetID)
          EndIf
          
          GetObject_( Fnt, SizeOf(LOGFONT) , InternFnt.LOGFONT )
          
          *font\fnName =  PeekS  (@InternFnt\lfFaceName)
          *font\fnSize = -MulDiv_(InternFnt\lfHeight, 72, GetDeviceCaps_(hdc, #LOGPIXELSY))
          *font\fontid = Fnt
              
          If (InternFnt\lfItalic <> 0)
            *font\Italic = #PB_Font_Italic 
          EndIf
          
          If (InternFnt\lfQuality  <> 0)              
          EndIf            
          
          If ( InternFnt\lfStrikeOut <> 0 )                
            *font\Strike = #PB_Font_StrikeOut
          EndIf            
          
          If ( InternFnt\lfUnderline )                  
            *font\UnLine = #PB_Font_Underline
          EndIf            
          
          If ( InternFnt\lfWeight <> 0 ) 
            *font\IsBold = InternFnt\lfWeight
          EndIf
          
          ProcedureReturn Fnt        
        EndIf             
        ProcedureReturn -1
      EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile
    
    FontEX::*font.FONTPARAMS = AllocateMemory(SizeOf(FontEX::FONTPARAMS))
    InitializeStructure(*font, FontEX::FONTPARAMS)                   
    
    
    If OpenWindow(0, 100, 200, 460, 148, "Font Test") = 0        
        MessageRequester("Error", "Can't open Window", 0)
        End
    EndIf
    
    TextGadget(5,20,20,420,120,"Franz jagt komplett mit einem Taxi druch Bayern")
    ;;FontEX::Dialog_Font(*font )
    FontEX::Dialog_Font_Neu(*font, 5, 0, WindowID(0))

    Repeat
        
        Event = WaitWindowEvent()
        
    Until Event = #PB_Event_CloseWindow    ; If the user has pressed on the close button
    
    End                                      ; All the opened windows are closed automatically by PureBasic
    
    ClearStructure(*font, FontEX::FONTPARAMS)
CompilerEndIf        

; typedef struct tagCHOOSEFONTA {
;   DWORD        lStructSize        ;The length of the structure, in bytes.

;   HWND         hwndOwner          ;A handle to the window that owns the dialog box.        
;This member can be any valid window handle, Or it
;can be NULL If the dialog box has no owner.

;   HDC          hDC;               ;This member is ignored by the ChooseFont function.

;   LPLOGFONTA   lpLogFont          ;A pointer to a LOGFONT structure. If you set the
;CF_INITTOLOGFONTSTRUCT flag IN the Flags member
;AND initialize the other members, the ChooseFont
;function initializes the dialog box With a font
;that matches the LOGFONT members. If the user clicks
;the OK button, ChooseFont SETS the members of the
;LOGFONT Structure based on the user's selections.

;   INT          iPointSize             ;The size of the selected font, in units of 1/10 of a point.
;The ChooseFont function SETS this value after the user
;closes the dialog box.

;   DWORD        Flags;
;   COLORREF     rgbColors;
;   LPARAM       lCustData;
;   LPCFHOOKPROC lpfnHook;
;   LPCSTR       lpTemplateName;
;   HINSTANCE    hInstance;
;   LPSTR        lpszStyle;
;   WORD         nFontType;
;   WORD         ___MISSING_ALIGNMENT__;
;   INT          nSizeMin;
;   INT          nSizeMax;
;   } CHOOSEFONTA        ;

; Choosefont Flags

; CF_APPLY   0x00000200L
; Causes the dialog box To display the Apply button. You should provide a hook Procedure To process WM_COMMAND messages 
; For the Apply button. The hook Procedure can send the WM_CHOOSEFONT_GETLOGFONT message To the dialog box To retrieve
;the address of the Structure that contains the current selections For the font.

; CF_ANSIONLY
; 0x00000400L
; This flag is obsolete. To limit font selections To all scripts except those that use the OEM Or Symbol character SETS, use CF_SCRIPTSONLY. To get the original CF_ANSIONLY behavior, use CF_SELECTSCRIPT And specify ANSI_CHARSET IN the lfCharSet member of the LOGFONT Structure pointed To by lpLogFont.

; CF_BOTH
; 0x00000003
; This flag is ignored For font Enumeration.
; Windows Vista And Windows XP/2000:  Causes the dialog box To List the available printer And screen fonts. The hDC member is a handle To the device context Or information context associated With the printer. This flag is a combination of the CF_SCREENFONTS And CF_PRINTERFONTS flags.
; 
; CF_EFFECTS
; 0x00000100L
; Causes the dialog box To display the controls that allow the user To specify strikeout, underline, And text color options. If this flag is set, you can use the rgbColors member To specify the initial text color. You can use the lfStrikeOut And lfUnderline members of the Structure pointed To by lpLogFont To specify the initial settings of the strikeout And underline check boxes. ChooseFont can use these members To Return the user's selections.

; CF_ENABLEHOOK
; 0x00000008L
; Enables the hook Procedure specified IN the lpfnHook member of this Structure.

; CF_ENABLETEMPLATE
; 0x00000010L
; Indicates that the hInstance And lpTemplateName members specify a dialog box template To use IN place of the Default template.

; CF_ENABLETEMPLATEHANDLE
; 0x00000020L
; Indicates that the hInstance member identifies a Data block that contains a preloaded dialog box template. The system ignores the lpTemplateName member If this flag is specified.

; CF_FIXEDPITCHONLY
; 0x00004000L
; ChooseFont should enumerate And allow selection of only fixed-pitch fonts.
; 
; CF_FORCEFONTEXIST
; 0x00010000L
; ChooseFont should indicate an error condition If the user attempts To Select a font Or style that is Not listed IN the dialog box.
; 

; CF_INACTIVEFONTS
; 0x02000000L
; ChooseFont should additionally display fonts that are set To Hide IN Fonts Control Panel.
; 
; Windows Vista And Windows XP/2000:  This flag is Not supported Until Windows 7.
; 

; CF_INITTOLOGFONTSTRUCT
; 0x00000040L
; ChooseFont should use the Structure pointed To by the lpLogFont member To initialize the dialog box controls.
; 

; CF_LIMITSIZE
; 0x00002000L
; ChooseFont should Select only font sizes within the range specified by the nSizeMin And nSizeMax members.
; 

; CF_NOOEMFONTS
; 0x00000800L
; Same As the CF_NOVECTORFONTS flag.

; CF_NOFACESEL
; 0x00080000L
; When using a LOGFONT Structure To initialize the dialog box controls, use this flag To prevent the dialog box from displaying an initial selection For the font name combo box. This is useful when there is no single font name that applies To the text selection.

; CF_NOSCRIPTSEL
; 0x00800000L
; Disables the Script combo box. When this flag is set, the lfCharSet member of the LOGFONT Structure is set To DEFAULT_CHARSET when ChooseFont returns. This flag is used only To initialize the dialog box.

; CF_NOSIMULATIONS
; 0x00001000L
; ChooseFont should Not display Or allow selection of font simulations.
; 
; CF_NOSIZESEL
; 0x00200000L
; When using a Structure To initialize the dialog box controls, use this flag To prevent the dialog box from displaying an initial selection For the Font Size combo box. This is useful when there is no single font size that applies To the text selection.

; CF_NOSTYLESEL
; 0x00100000L
; When using a LOGFONT Structure To initialize the dialog box controls, use this flag To prevent the dialog box from displaying an initial selection For the Font Style combo box. This is useful when there is no single font style that applies To the text selection.

; CF_NOVECTORFONTS
; 0x00000800L
; ChooseFont should Not allow vector font selections.
; 
; CF_NOVERTFONTS
; 0x01000000L
; Causes the Font dialog box To List only horizontally oriented fonts.

; CF_PRINTERFONTS
; 0x00000002
; This flag is ignored For font Enumeration.
; Windows Vista And Windows XP/2000:  Causes the dialog box To List only the fonts supported by the printer associated With the device context Or information context identified by the hDC member. It also causes the font type description label To appear at the bottom of the Font dialog box.
; 
; CF_SCALABLEONLY
; 0x00020000L
; Specifies that ChooseFont should allow only the selection of scalable fonts. Scalable fonts include vector fonts, scalable printer fonts, TrueType fonts, And fonts scaled by other technologies.

; CF_SCREENFONTS
; 0x00000001
; This flag is ignored For font Enumeration.
; Windows Vista And Windows XP/2000:  Causes the dialog box To List only the screen fonts supported by the system.
; 
; CF_SCRIPTSONLY
; 0x00000400L
; ChooseFont should allow selection of fonts For all non-OEM And Symbol character SETS, As well As the ANSI character set. This supersedes the CF_ANSIONLY value.
; 
; CF_SELECTSCRIPT
; 0x00400000L
; When specified on input, only fonts With the character set identified IN the lfCharSet member of the LOGFONT Structure are displayed. The user will Not be allowed To change the character set specified IN the Scripts combo box.

; CF_SHOWHELP
; 0x00000004L
; Causes the dialog box To display the Help button. The hwndOwner member must specify the window To receive the HELPMSGSTRING registered messages that the dialog box sends when the user clicks the Help button.

; CF_TTONLY
; 0x00040000L
; ChooseFont should only enumerate And allow the selection of TrueType fonts.
; 
; CF_USESTYLE
; 0x00000080L
; The lpszStyle member is a pointer To a buffer that contains style Data that ChooseFont should use To initialize the Font Style combo box. When the user closes the dialog box, ChooseFont copies style Data For the user's selection to this buffer.
; Note  To globalize your application, you should specify the style by using the lfWeight And lfItalic members of the LOGFONT Structure pointed To by lpLogFont. The style name may change depending on the system user Interface language.
;  
; CF_WYSIWYG
; 0x00008000L
; Obsolete. ChooseFont ignores this flag.
; Windows Vista And Windows XP/2000:  ChooseFont should allow only the selection of fonts available on both the printer And the display. If this flag is specified, the CF_SCREENSHOTS And CF_PRINTERFONTS, Or CF_BOTH flags should also be specified.
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 223
; FirstLine = 133
; Folding = -G-
; EnableAsm
; EnableXP