

DeclareModule Fonts
    
    Debug ""
    Debug "Purebasic Constants Enumeration [Fonts::]"    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    MaxPBEnums.i = 2401    
        Enumeration 2201 Step 1               
            #_FIXPLAIN7_12
                       
            #_SEGOEUI08N    :#_SEGOEUI09N   :#_SEGOEUI10N    :#_SEGOEUI11N   
            #_SEGOEUI08B    :#_SEGOEUI09B   :#_SEGOEUI10B    :#_SEGOEUI11B        
            
            #_EUROSTILE_10  :#_EUROSTILE_11 :#_EUROSTILE_12  :#_EUROSTILE_14 :#_EUROSTILE_18  :#_EUROSTILE_24 :#_EUROSTILE_28  
            #_EUROSTILE_20  :#_EUROSTILE_22
            
            #_C64_CHARS     :#_C64_CHARS2   :#_C64_CHARS3_REQ
            
            #PC_Clone_09
            #DEJAVUSANS_MONO_09
            
                            ; Fonts Unbenutzt
                            ;         #_DIGITAL7_12
                            ;         
                            ;         #_ABERDEEN_12
                            ;         #_THING_12        
                            ;         #_XBOXBOOK_08   :#_XBOXBOOK_09  :#_XBOXBOOK_10   
                            ;         #_DEJAVU_08     :#_DEJAVU_09    :#_DEJAVU_10     :#_DEJAVU_11        
                            ;         #_LIBSANSR_08   :#_LIBSANSR_09  :#_LIBSANSR_10        
                            ;         #_LIBMONOR_08   :#_LIBMONOR_09  :#_LIBMONOR_10        
                            ;         #_SUIMONO_08    :#_SUIMONOB08:                  
                            ;         #_Ascii_10     
                            ;         #_CONSOLE
        
        EndEnumeration       
        Debug "- Fonts       #2201 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))    
        
        Declare.l     GetHandle(FnIndex)
        Declare.s     GetName  (FnIndex) 
        Declare.l     GetFontID(FnIndex)
        Declare.l     GetFontPB(FnIndex)
        Declare.i     GetHeight(FnIndex)
        
        ;         HANDLE AddFontMemResourceEx(
        ;         PVOID pbFont,       	// font resource                        - A pointer To a font resource.
        ;         DWORD cbFont,       	// number of bytes in font resource     - The number of bytes in the font resource that is pointed To by pbFont.
        ;         PVOID pdv,          	// Reserved. Must be 0.                 - Reserved. Must be 0.
        ;         DWORD *pcFonts      	// number of fonts installed            - A pointer To a variable that specifies the number of fonts installed.
        ;         );   
        
EndDeclareModule

Module Fonts
    
    Structure FONT_MEM_RESOURCE_STRUCT
        nHandle.l
        nFontID.l            
        sFnName.s
        nFnSize.i
        nFontPB.i
    EndStructure 
    
    Structure FONT_MEM_RESOURCE_LIST
        pFont.FONT_MEM_RESOURCE_STRUCT[100]
    EndStructure 
    
    Global *MemResource.FONT_MEM_RESOURCE_LIST       = AllocateMemory(SizeOf(FONT_MEM_RESOURCE_LIST)) 
    
    ;****************************************************************************************************************************************************************
    ; Zählt den Index
    ;    
    Procedure.i LstFontIndex()
        
        Protected  nSize.i
        
        For nSize = 0 To 99
            If *MemResource\pFont[nSize]\nFontID = 0
                ProcedureReturn nSize
                Break
            EndIf
        Next          
        ProcedureReturn nSize
        
    EndProcedure     
    ;****************************************************************************************************************************************************************
    ; Gibt den Handle Zurück
    ;       
    Procedure.l GetHandle(FnIndex)
        
        nIndex = LstFontIndex()
        
        If ( nIndex >= FnIndex )
            ProcedureReturn *MemResource\pFont[FnIndex]\nHandle
        EndIf
        ProcedureReturn 0
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ; Gibt den Namen Zurück
    ;       
    Procedure.s GetName(FnIndex)
        
        nIndex = LstFontIndex()
        
        If ( nIndex >= FnIndex )
            ProcedureReturn *MemResource\pFont[FnIndex]\sFnName
        EndIf
        ProcedureReturn ""
    EndProcedure      
    ;****************************************************************************************************************************************************************
    ; Gibt die ID Zurück
    ;       
    Procedure.l GetFontID(FnIndex)
        
        nIndex = LstFontIndex()
        
        If ( nIndex >= FnIndex )
            ProcedureReturn *MemResource\pFont[FnIndex]\nFontID
        EndIf
        ProcedureReturn 0
    EndProcedure
    ;****************************************************************************************************************************************************************
    ; Gibt die PB ID Zurück
    ;       
    Procedure.l GetFontPB(FnIndex)
        
        nIndex = LstFontIndex()
        
        If ( nIndex >= FnIndex )
            ProcedureReturn *MemResource\pFont[FnIndex]\nFontPB
        EndIf
        ProcedureReturn 0
    EndProcedure 
    ;****************************************************************************************************************************************************************
    ; Gibt die Grösse Zurück
    ;       
    Procedure.i GetHeight(FnIndex)
        
        nIndex = LstFontIndex()
        
        If ( nIndex >= FnIndex )
            ProcedureReturn *MemResource\pFont[FnIndex]\nFnSize
        EndIf
        ProcedureReturn 0
    EndProcedure      
    ;****************************************************************************************************************************************************************
    ; Füght Fonts Local von dem System oder aus dem programm hinzu
    ;       
    Procedure   AddFontMemResource( pbFont, cbFont, szName.s, FnSize.i, Local.i = #False )
                
        nIndex = LstFontIndex()
        
        *MemResource\pFont[nIndex]\nHandle = 0 
        *MemResource\pFont[nIndex]\sFnName = szName
        *MemResource\pFont[nIndex]\nFnSize = FnSize    
        *MemResource\pFont[nIndex]\nFontID = LoadFont(#PB_Any ,szName , FnSize, #PB_Font_HighQuality)
        *MemResource\pFont[nIndex]\nFontPB = FontID( *MemResource\pFont[nIndex]\nFontID )
            
        
        If ( Local = #False )
            nDynamicLib = 0
            nDynamicLib = OpenLibrary(#PB_Any,"gdi32.dll") 
        
            If ( nDynamicLib >= 1 )            
                *MemResource\pFont[nIndex]\nHandle = CallFunction(nDynamicLib, "AddFontMemResourceEx" ,pbFont, cbFont, 0, @"1")    
                
                CloseLibrary(nDynamicLib)  
            Else
                *MemResource\pFont[nIndex]\nHandle = 0
                Debug " Font Resource Error. Konnte gdi32.dll nicht Öffnen"
            EndIf    
            
        EndIf    
                
        Debug " Font Resource [Fonts::] = [" + Str( nIndex) + "] \ ( Size: "+Str( FnSize )+")"+#TAB$+ szName
               
    EndProcedure
    
    
    
    AddFontMemResource( ?BEG_C64CHARSET , ?END_C64CHARSET  - ?BEG_C64CHARSET , "Fixplain7/C64/Shift-U", 12 )         
    AddFontMemResource( ?BEG_C64CHARSET2, ?END_C64CHARSET2 - ?BEG_C64CHARSET2, "Fixplain7/C64/Shift-D", 12 )   
    AddFontMemResource( ?BEG_C64CHARSET3, ?END_C64CHARSET3 - ?BEG_C64CHARSET3, "Fixplain7/C64/Request", 12 )   
    AddFontMemResource( ?BEG_FIXPLAIN7  , ?END_FIXPLAIN7   - ?BEG_FIXPLAIN7  , "fixplain7 12"         , 12 )
    AddFontMemResource( ?BEG_PCCLONE    , ?END_PCCLONE     - ?BEG_PCCLONE    , "PC-Clone                       ", 9 )             
    AddFontMemResource( ?BEG_DEJAVUSM   , ?END_DEJAVUSM    - ?BEG_DEJAVUSM   , "DejaVu Sans Mono"     , 9 )    
    AddFontMemResource( ?BEG_EUROSTILE  , ?END_EUROSTILE   - ?BEG_EUROSTILE  , "Xbox Book"            , 20 )
    AddFontMemResource( 0               , 0                                  , "Segoe UI"             , 10, #True )     
    AddFontMemResource( 0               , 0                                  , "Segoe UI"             , 11, #True )  
           
    LoadFont(#_FIXPLAIN7_12     ,"fixplain7 12"         ,12)
    LoadFont(#PC_Clone_09       ,"PC-Clone"             ,9)    

    LoadFont(#DEJAVUSANS_MONO_09,"DejaVu Sans Mono"     ,9  ,#PB_Font_HighQuality)       
    LoadFont(#_EUROSTILE_20     ,"Xbox Book"            ,20 ,#PB_Font_HighQuality)
    LoadFont(#_EUROSTILE_18     ,"Xbox Book"            ,13 ,#PB_Font_HighQuality)     
          
    LoadFont(#_C64_CHARS        ,"Fixplain7/C64/Shift-U",12, #PB_Font_HighQuality)   
    LoadFont(#_C64_CHARS2       ,"Fixplain7/C64/Shift-D",12, #PB_Font_HighQuality) 
    LoadFont(#_C64_CHARS3_REQ   ,"Fixplain7/C64/Request",12, #PB_Font_HighQuality)    
    LoadFont(#_SEGOEUI10N       ,"Segoe UI"             ,10, #PB_Font_HighQuality)
    LoadFont(#_SEGOEUI11N       ,"Segoe UI"             ,11, #PB_Font_HighQuality)
    
    DataSection        
        BEG_C64CHARSET: 
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\FIXPLAIN7_C64_DirectoryUP.fon"
        END_C64CHARSET:
        
        BEG_C64CHARSET2:
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\FIXPLAIN7_C64_DirectoryDown.fon"
        END_C64CHARSET2: 
        
        BEG_C64CHARSET3:
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\FIXPLAIN7_C64_Requester.fon"
        END_C64CHARSET3: 
               
        BEG_FIXPLAIN7:
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\FIXPLAIN7.FON"
        END_FIXPLAIN7:
                        
        BEG_EUROSTILE:
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\XBOXBOOK.TTF"  
        END_EUROSTILE:
                    
        BEG_PCCLONE:
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\PCCLONE.FON"  
        END_PCCLONE:            
        
        BEG_DEJAVUSM:
            IncludeBinary "..\..\INCLUDES\_FONTS_EMBEDDED\DEJAVUSANSMONOTEST.TTF"  
        END_DEJAVUSM:  
            
    EndDataSection    
        
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 196
; FirstLine = 120
; Folding = j0
; EnableXP
; EnableUnicode