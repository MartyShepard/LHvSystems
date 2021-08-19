DeclareModule vFont
    
    Declare     DelDB(RowID.i, EvntGadget = -1) 
    Declare     SetDB(RowID.i, FixedFonts.i= 0)      
    Declare.l   GetDB(RowID.i, EvntGadget = -1)
    
EndDeclareModule    

Module vFont
    
    ;****************************************************************************************************************************************************************
    ; Löscht die Einstellunge aus der DB
    ;
    Procedure   DelDB(RowID.i, EvntGadget = -1)
        
        Protected  InternalFontID.i = 4
        
        Select RowID
            Case 1: InternalFontID = 6
            Case 2: InternalFontID = 5                
        EndSelect
        
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fnName", Fonts::GetName(InternalFontID),RowID,"","",1,#False)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fnSize", Str( Fonts::GetHeight(InternalFontID) ),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fColor", "",RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "Italic", "",RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "IsBold", "",RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "UnLine", "",RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "Strike", "",RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fontid", Str( Fonts::GetFontPB(InternalFontID) ) ,RowID)
            
            Debug "vFont:: Using " + Fonts::GetName(InternalFontID) + "Size: " +  Str( Fonts::GetHeight(InternalFontID)) + #TAB$ + " Index: " + Str(InternalFontID)
            
            If ( EvntGadget >= 1 )                
                vFont::GetDB(RowID.i, EvntGadget)               
            EndIf                                       
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Lädt die Font Einstellung aus der DB
    ;      
    Procedure.l GetDB(RowID.i, EvntGadget = -1)
        
        Protected nFont.l
        
        FontEX::*font.FONTPARAMS = AllocateMemory(SizeOf(FontEX::FONTPARAMS))
        InitializeStructure(*font, FontEX::FONTPARAMS)  
        
        
        *font\fnName.s = ExecSQL::nRow(DC::#Database_001,"SetFonts","fnName","",RowID,"",1) ; Der Fontname
        *font\fnSize.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","fnSize",0,RowID,"",1)  ; Die grösse (Integer)
        *font\fColor.l = ExecSQL::iRow(DC::#Database_001,"SetFonts","fColor",0,RowID,"",1)  ; Fontname Text Farbe
        *font\Italic.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","Italic",0,RowID,"",1)  ; Kursiv
        *font\IsBold.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","IsBold",0,RowID,"",1)  ; Fett
        *font\UnLine.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","UnLine",0,RowID,"",1)  ; Unterstrichen
        *font\Strike.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","Strike",0,RowID,"",1)  ; Durchgestrichen
        *font\fontid.l = ExecSQL::iRow(DC::#Database_001,"SetFonts","fontid",0,RowID,"",1)  ; PurebasicID   
        
        If (*font\fontid <> 0)
            
            nFont = LoadFont(#PB_Any, *font\fnName , *font\fnSize, *font\Italic| *font\Strike| *font\UnLine| #PB_Font_HighQuality) 
            
            If ( EvntGadget >= 1 )
                SetGadgetFont(EvntGadget, *font\fontid ) 
                ;
                ;
                FontEX::Dialog_Font_Bold(*font, EvntGadget) ; Zur ünterstüzung mit Font Gewichten (Dünn, Dick. Extra etc...)             
                
                ProcedureReturn 0
            EndIf                 
           
        EndIf    
        
        ClearStructure(*font, FontEX::FONTPARAMS)     
        
        ProcedureReturn nFont
        
    EndProcedure     
    ;****************************************************************************************************************************************************************
    ; Speichert die Font Einstellung in die DB
    ;      
    Procedure   SetDB(RowID.i, FixedFonts.i = 0) 
        Protected  Result.i
        FontEX::*font.FONTPARAMS = AllocateMemory(SizeOf(FontEX::FONTPARAMS))
        InitializeStructure(*font, FontEX::FONTPARAMS)  
        
        ;
        ; Fehlt die Zeile in den Sttings? Lege eine an
        Rows = ExecSQL::MaxRowID(DC::#Database_001,"SetFonts")
        If ( RowID > Rows )
            ExecSQL::InsertRow(DC::#Database_001,"SetFonts", "fnName", "Segoe UI" )
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fnName", "Segoe UI",RowID)
        EndIf    
        ; 
        ; Die Einstellungen aus der DB  laden und übergeben
        *font\fnName.s = ExecSQL::nRow(DC::#Database_001,"SetFonts","fnName","",RowID,"",1) ; Der Fontname
        *font\fnSize.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","fnSize",0,RowID,"",1)  ; Die grösse (Integer)
        *font\fColor.l = ExecSQL::iRow(DC::#Database_001,"SetFonts","fColor",0,RowID,"",1)  ; Fontname Text Farbe
        *font\Italic.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","Italic",0,RowID,"",1)  ; Kursiv
        *font\IsBold.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","IsBold",0,RowID,"",1)  ; Fett
        *font\UnLine.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","UnLine",0,RowID,"",1)  ; Unterstrichen
        *font\Strike.i = ExecSQL::iRow(DC::#Database_001,"SetFonts","Strike",0,RowID,"",1)  ; Durchgestrichen
        *font\fontid.l = ExecSQL::iRow(DC::#Database_001,"SetFonts","fontid",0,RowID,"",1)  ; PurebasicID  
        
        Select FixedFonts
            Case 0: Result = FontEX::Dialog_Font(*font)
            Case 1: Result = FontEX::Dialog_Font(*font, #CF_TTONLY)
            Case 2: Result = FontEX::Dialog_Font(*font, #CF_FIXEDPITCHONLY)                    
        EndSelect
        
        If ( Result = #True )
            
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fnName", *font\fnName.s,RowID,"","",1,#False)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fnSize", Str(*font\fnSize),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fColor", Str(*font\fColor),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "Italic", Str(*font\Italic),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "IsBold", Str(*font\IsBold),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "UnLine", Str(*font\UnLine),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "Strike", Str(*font\Strike),RowID)
            ExecSQL::UpdateRow(DC::#Database_001,"SetFonts", "fontid", Str(*font\fontid),RowID)
            
            Select RowID
                Case 1
                    SetGadgetFont(DC::#Text_001,FontID(*font\fontid) )        :FontEX::Dialog_Font_Bold(*font, DC::#Text_001) 
                    SetGadgetFont(DC::#Text_002,FontID(*font\fontid) )        :FontEX::Dialog_Font_Bold(*font, DC::#Text_002)
                    
                Case 2: SetGadgetFont(DC::#ListIcon_001,FontID(*font\fontid) ):FontEX::Dialog_Font_Bold(*font, DC::#ListIcon_001) 
                Case 3: SetGadgetFont(DC::#Text_128,FontID(*font\fontid) )    :FontEX::Dialog_Font_Bold(*font, DC::#Text_128) 
                Case 4: SetGadgetFont(DC::#Text_129,FontID(*font\fontid) )    :FontEX::Dialog_Font_Bold(*font, DC::#Text_129)                       
                Case 5: SetGadgetFont(DC::#Text_130,FontID(*font\fontid) )    :FontEX::Dialog_Font_Bold(*font, DC::#Text_130)                       
                Case 6: SetGadgetFont(DC::#Text_131,FontID(*font\fontid) )    :FontEX::Dialog_Font_Bold(*font, DC::#Text_131)                      
            EndSelect      
        EndIf
        
        ClearStructure(*font, FontEX::FONTPARAMS) 
        
    EndProcedure
    
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 15
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\