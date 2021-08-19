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
DeclareModule FontEX 
    
    Structure FONTPARAMS
        fnName.s    ; Der Fontname
        fnSize.i    ; Die grösse (Integer)
        fColor.l    ; Fontname Text Farbe
        Italic.i    ; Kursiv
        IsBold.i    ; Fett
        UnLine.i    ; Unterstrichen
        Strike.i    ; Durchgestrichen
        fontid.l    ; Die Purebasic Rückgabe ID
    EndStructure 
    
    Declare.i   Dialog_Font(*font.FONTPARAMS, StructChooseFontFlags.l = 0)
    Declare.i   Dialog_Font_Bold(*font.FONTPARAMS, EvntGadget.i)
    
    
EndDeclareModule
Module FontEX
    ;******************************************************************************************************************************************
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
    ;******************************************************************************************************************************************
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
                lg\lfItalic     = #True
            EndIf
            
            lg\lfQuality    = #CLEARTYPE_QUALITY
            
            If ( *font\Strike = #PB_Font_StrikeOut )                
                lg\lfStrikeOut  = #True
            EndIf
            
            If ( *font\UnLine = #PB_Font_Underline )                  
                lg\lfUnderline  = #True
            EndIf
            
            lg\lfWeight     = *font\IsBold
            
            fnt = CreateFontIndirect_(lg)
            SendMessage_(GadgetID( EvntGadget ) , #WM_SETFONT, fnt, 1)
            
        EndIf  
    EndProcedure 
EndModule

CompilerIf #PB_Compiler_IsMainFile
    
    FontEX::*font.FONTPARAMS = AllocateMemory(SizeOf(FontEX::FONTPARAMS))
    InitializeStructure(*font, FontEX::FONTPARAMS)                   
    
    
    If OpenWindow(0, 100, 200, 460, 148, "Font Test") = 0        
        MessageRequester("Error", "Can't open Window", 0)
        End
    EndIf
    
    FontEX::Dialog_Font(*font )
    
    Debug FontID(*font\fontid)
    
    If CreateImage(0, 450, 130)
        
        If StartDrawing(ImageOutput(0))           ;
            Box(0, 0, 450, 130, RGB(255, 255, 255)) ; White background
            
            DrawingMode(1)                          ; Transparent TextBackground
            
            DrawingFont(FontID(*font\fontid))                 ; Use the 'Courier' font
                                                              ;FontEX::Dialog_Font_Bold(*font, 0, @x )
            DrawText(10,10, "Font: "+ *font\fnName +" - Size: "+ Str(*font\fnSize) +" - Color: " + Str(*font\fColor),*font\fColor)    ; Print our text
            
            
            StopDrawing()                        ; This is absolutely needed when the drawing operations are 
        EndIf                                    ; finished !!! Never forget it !
        
    EndIf
    
    ; Display the image on the window
    ;
    ImageGadget(0, 5, 10, 450, 130, ImageID(0))
    
    ;
    ; This is the 'event loop'. All the user actions are processed here.
    ; It's very easy to understand: when an action occurs, the Event
    ; isn't 0 and we just have to see what have happened...
    ;
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
; CursorPosition = 96
; FirstLine = 75
; Folding = n
; EnableAsm
; EnableXP