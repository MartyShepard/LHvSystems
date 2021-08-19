DeclareModule DC
    
    Debug ""
    Debug "Purebasic Constants Enumeration [DC::]"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:  Windows
    ;
    MaxPBEnums.i = 20
    
    Enumeration 01 Step 1
        #_Window_001: #_Window_002: #_Window_003: #_Window_004: #_Window_005: #_Window_006
    EndEnumeration            
    
    Debug "- Windows        #0001 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   Dateien
    ;
    MaxPBEnums.i = 40        
    Enumeration 21 Step 1
        #LOGFILE: #PACKFILE: #TMPFile: #XML: #UpdateFile: #UpdateLib: #UpdateModul
    EndEnumeration
    
    Debug "- Dateien        #0021 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   ListIcon
    ;       
    MaxPBEnums.i = 90        
    Enumeration 41 Step 1
        #ListIcon_001: #ListIcon_002: #ListIcon_003
    EndEnumeration
    
    Debug "- Listicon       #0041 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))

    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   ImageGadget
    ;
    MaxPBEnums.i = 140
    Enumeration 91 Step 1
        #TRAYICON001: #TRAYICON002:        
    EndEnumeration
    
    Debug "- Image Gadget   #0091 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:  Strings
    ;    
    MaxPBEnums.i = 499         
    Enumeration 141 Step 1
        #String_001: #String_002: #String_003: #String_004: #String_005: #String_006: #String_007: #String_008
        #String_009: #String_010: #String_011: #String_012: #String_013: #String_014: #String_015: #String_016
        #String_017: #String_018: #String_019: #String_020: #String_021: #String_022: #String_023: #String_024
        #String_025: #String_026: #String_027: #String_028: #String_029: #String_030: #String_031: #String_032
        #String_033: #String_034: #String_035: #String_036: #String_037: #String_038: #String_039: #String_040
        #String_041: #String_042: #String_043: #String_044: #String_045: #String_046: #String_047: #String_048
        #String_049: #String_050: #String_051: #String_052: #String_053: #String_054: #String_055: #String_056
        #String_057: #String_058: #String_059: #String_060: #String_061
        #String_100: #String_101: #String_102: #String_103: #String_104: #String_105: #String_106: #String_107
        #String_108: #String_109: #String_110: #String_111
        
        ; Info Window
        #String_112
    EndEnumeration
    
    Debug "- Strings        #0141 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   Database
    ;     
    MaxPBEnums.i = 598            
    Enumeration 500 Step 1
        #Database_001: #Database_002: #Database_003: #DummyBase
    EndEnumeration
    
    Debug "- Database       #0500 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:  Buttons
    ;
    MaxPBEnums.i = 1600          
    Enumeration 611 Step 1
        #Button_001: #Button_002: #Button_003: #Button_004: #Button_005: #Button_006: #Button_007: #Button_008: #Button_009
        #Button_010: #Button_011: #Button_012: #Button_013: #Button_014: #Button_015: #Button_016: #Button_017:  
        #Button_020: #Button_021: #Button_022: #Button_023: #Button_024: #Button_025: #Button_026: #Button_027: #Button_028
        #Button_031: #Button_032: #Button_033
        
        #Button_050: #Button_051: #Button_052: #Button_053: #Button_054: #Button_055: #Button_056: #Button_057: #Button_058
        #Button_059: #Button_060: #Button_061: #Button_062: #Button_063: #Button_064: #Button_065: #Button_066: #Button_067
        #Button_068: #Button_069: #Button_070: #Button_071: #Button_072: #Button_073: #Button_074: #Button_075: #Button_076
        #Button_077: #Button_078: #Button_079: #Button_080: #Button_081: #Button_082: #Button_083:
        
        #Button_087:
        
        #Button_090: #Button_091: #Button_092: #Button_093: #Button_094: #Button_095: #Button_096: #Button_097: #Button_098
        #Button_099: #Button_100: #Button_101: #Button_102: #Button_103: #Button_104: #Button_105: #Button_106
        
        #Button_115: #Button_116: #Button_117: #Button_118: #Button_119: #Button_120: #Button_121: #Button_122: #Button_123 
        #Button_125: #Button_126: #Button_127: #Button_128: #Button_129: #Button_130: #Button_131: #Button_132: #Button_133
        #Button_135: #Button_136: #Button_137: #Button_138: #Button_139: #Button_140: #Button_141: #Button_142: #Button_143
        #Button_145: #Button_146: #Button_147: #Button_148: #Button_149: #Button_150: #Button_151: #Button_152: #Button_153
        #Button_155: #Button_156: #Button_157: #Button_158: #Button_159: #Button_160: #Button_161: #Button_162: #Button_163
        #Button_165: #Button_166: #Button_167: #Button_168: #Button_169: #Button_170: #Button_171: #Button_172: #Button_173
        #Button_175: #Button_176: #Button_177: #Button_178: #Button_179: #Button_180: #Button_181: #Button_182: #Button_183
        #Button_185: #Button_186: #Button_187: #Button_188: #Button_189: #Button_190: #Button_191: #Button_192: #Button_193
        #Button_195: #Button_196: #Button_197: #Button_198: #Button_199: #Button_200:
        
        ; External Window (Close/Resize)
        #Button_201: #Button_202:
        
        ; External Windows             
        #Button_203: #Button_204
        #Button_205: #Button_206: #Button_207: #Button_208: #Button_209: #Button_210: #Button_211: #Button_212: #Button_213
        #Button_215: #Button_216: #Button_217: #Button_218: #Button_219: #Button_220: #Button_221: #Button_222: #Button_223
        #Button_231: #Button_232: #Button_233: #Button_234: #Button_235: #Button_236: #Button_237: #Button_238: #Button_239
        #Button_240: #Button_241: #Button_242
        #Button_243: #Button_244: #Button_245: #Button_246: #Button_247: #Button_248: #Button_249: #Button_250: #Button_251
        #Button_252: #Button_253: #Button_254: #Button_255: #Button_256: #Button_257: #Button_258: #Button_259: #Button_260
        #Button_261: #Button_262: #Button_263: #Button_264: #Button_265: #Button_266: #Button_267: #Button_268: #Button_269
        #Button_270: #Button_271: #Button_272: #Button_273: #Button_274: #Button_275: #Button_276
        #Button_277: #Button_278: #Button_279: #Button_280: #Button_281: #Button_282
        
        ; Info Window
        #Button_283: #Button_284: #Button_285: #Button_286
        
        
    EndEnumeration
    Debug "- Button Gadget  #0611 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes: Text Gadget
    ;
    MaxPBEnums.i = 2100  
    
    Enumeration 1601 Step 1
        #Text_001: #Text_002: #Text_003: #Text_004: #Text_005: #Text_006: #Text_007: #Text_008: #Text_009: #Text_010
        #Text_011: #Text_012: #Text_013: #Text_014: #Text_015: #Text_016: #Text_017: #Text_018: #Text_019: #Text_020
        #Text_021: #Text_022: #Text_023: #Text_024: #Text_025: #Text_026: #Text_027: #Text_028: #Text_029: #Text_030
        #Text_031: #Text_032: #Text_033: #Text_034: #Text_035: #Text_036: #Text_037: #Text_038: #Text_039: #Text_040
        #Text_041: #Text_042: #Text_043: #Text_044: #Text_045: #Text_046: #Text_047: #Text_048: #Text_049: #Text_050
        #Text_051: #Text_052: #Text_053: #Text_054: #Text_055: #Text_056: #Text_057: #Text_058: #Text_059: #Text_060
        #Text_061: #Text_062: #Text_063: #Text_064: #Text_065: #Text_066: #Text_067: #Text_068: #Text_069: #Text_070
        #Text_071: #Text_072: #Text_073: #Text_074: #Text_075: #Text_076: #Text_077: #Text_078: #Text_079: #Text_080             
        #Text_081: #Text_082: #Text_083: #Text_084: #Text_085: #Text_086: #Text_087: #Text_088: #Text_089: #Text_090
        #Text_091: #Text_092: #Text_093: #Text_094: #Text_095: #Text_096: #Text_097: #Text_098: #Text_099: #Text_100
        #Text_101: #Text_102: #Text_103: #Text_104: #Text_105: #Text_106: #Text_107: #Text_108: #Text_109: #Text_110
        #Text_111: #Text_112: #Text_113: #Text_114: #Text_115: #Text_116: #Text_117: #Text_118: #Text_119: #Text_120
        
        
        ;C64 Window
        #Text_121: #Text_122: #Text_123: #Text_124: #Text_125: #Text_126
        
        ; MainWindow Info text
        #Text_127
        
        ; Info Window
        #Text_128: #Text_129: #Text_130: #Text_131
        
        ; Informationen im Info am Unteren Builschirmrand
        #Text_132: #Text_133: #Text_134: #Text_135: #Text_136
        
    EndEnumeration
    Debug "- Text Gadget    #1601 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   Frame Gadget
    ;
    MaxPBEnums.i = 2160  
    
    Enumeration 2101 Step 1                         
        #ImageBlank: #ImageCont11: #ImageAlpha : #_TestImage: #_PNG_LEER
        ;
        ; Screenshots ImagesID
        #_PNG_NOSA     : #_PNG_NOSB     : #_PNG_NOSC     : #_PNG_NOSD 
        ;
        ; Screenshots Gadget
        #ScreenShot_001: #ScreenShot_002: #ScreenShot_003: #ScreenShot_004: #ScreenShot_005: #ScreenShot_006               
        #ScreenShot_007: #ScreenShot_008: #ScreenShot_009: #ScreenShot_010: #ScreenShot_011: #ScreenShot_012
        #ScreenShot_013: #ScreenShot_014: #ScreenShot_015: #ScreenShot_016: #ScreenShot_017: #ScreenShot_018
        #ScreenShot_019: #ScreenShot_020: #ScreenShot_021: #ScreenShot_022: #ScreenShot_023: #ScreenShot_024
        #ScreenShot_025: #ScreenShot_026: #ScreenShot_027: #ScreenShot_028: #ScreenShot_029: #ScreenShot_030              
        #ScreenShot_031: #ScreenShot_032: #ScreenShot_033: #ScreenShot_034: #ScreenShot_035: #ScreenShot_036
        #ScreenShot_037: #ScreenShot_038: #ScreenShot_039: #ScreenShot_040: #ScreenShot_041: #ScreenShot_042
        #ScreenShot_043: #ScreenShot_044: #ScreenShot_045: #ScreenShot_046: #ScreenShot_047: #ScreenShot_048
        #ScreenShot_049: #ScreenShot_050              
        
    EndEnumeration
    Debug "- Frame Gadget   #2101 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes: Screenshots ImagesID
    ;
    MaxPBEnums.i = 2600  
    
    Enumeration 2201 Step 1
        #_PNG_COPY1     : #_PNG_COPY2   : #_PNG_COPY3     : #_PNG_COPY4     : #_PNG_COPY5  : #_PNG_COPY6
        #_PNG_COPY7     : #_PNG_COPY8   : #_PNG_COPY9     : #_PNG_COPY10    : #_PNG_COPY11 : #_PNG_COPY12 
        #_PNG_COPY13    : #_PNG_COPY14  : #_PNG_COPY15    : #_PNG_COPY16    : #_PNG_COPY17 : #_PNG_COPY18
        #_PNG_COPY19    : #_PNG_COPY20  : #_PNG_COPY21    : #_PNG_COPY22    : #_PNG_COPY23 : #_PNG_COPY24 
        #_PNG_COPY25    : #_PNG_COPY26  : #_PNG_COPY27    : #_PNG_COPY28    : #_PNG_COPY29 : #_PNG_COPY30
        #_PNG_COPY31    : #_PNG_COPY32  : #_PNG_COPY33    : #_PNG_COPY34    : #_PNG_COPY35 : #_PNG_COPY36             
        #_PNG_COPY37    : #_PNG_COPY38  : #_PNG_COPY39    : #_PNG_COPY40    : #_PNG_COPY41 : #_PNG_COPY42
        #_PNG_COPY43    : #_PNG_COPY44  : #_PNG_COPY45    : #_PNG_COPY46    : #_PNG_COPY47 : #_PNG_COPY48
        #_PNG_COPY49    : #_PNG_COPY50             
        
        #_PNG_ORGY1     : #_PNG_ORGY2   : #_PNG_ORGY3     : #_PNG_ORGY4     : #_PNG_ORGY5  : #_PNG_ORGY6
        #_PNG_ORGY7     : #_PNG_ORGY8   : #_PNG_ORGY9     : #_PNG_ORGY10    : #_PNG_ORGY11 : #_PNG_ORGY12 
        #_PNG_ORGY13    : #_PNG_ORGY14  : #_PNG_ORGY15    : #_PNG_ORGY16    : #_PNG_ORGY17 : #_PNG_ORGY18
        #_PNG_ORGY19    : #_PNG_ORGY20  : #_PNG_ORGY21    : #_PNG_ORGY22    : #_PNG_ORGY23 : #_PNG_ORGY24 
        #_PNG_ORGY25    : #_PNG_ORGY26  : #_PNG_ORGY27    : #_PNG_ORGY28    : #_PNG_ORGY29 : #_PNG_ORGY30
        #_PNG_ORGY31    : #_PNG_ORGY32  : #_PNG_ORGY33    : #_PNG_ORGY34    : #_PNG_ORGY35 : #_PNG_ORGY36             
        #_PNG_ORGY37    : #_PNG_ORGY38  : #_PNG_ORGY39    : #_PNG_ORGY40    : #_PNG_ORGY41 : #_PNG_ORGY42
        #_PNG_ORGY43    : #_PNG_ORGY44  : #_PNG_ORGY45    : #_PNG_ORGY46    : #_PNG_ORGY47 : #_PNG_ORGY48
        #_PNG_ORGY49    : #_PNG_ORGY50            
    EndEnumeration
    Debug "- ImageID        #2201 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   Container
    ;
    MaxPBEnums.i = 3150  
    
    Enumeration 3101 Step 1
        #Contain_01: #Contain_02: #Contain_03: #Contain_04: #Contain_05: #Contain_06: #Contain_07: #Contain_08: #Contain_09: #Contain_10
        #Contain_11: #Contain_12: #Contain_13: #Contain_14: #Contain_15: 
        
        ; Info Window Container
        #Contain_16: #Contain_17: #Contain_18: #Contain_19
    EndEnumeration
    Debug "- Container      #3101 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes:   Sonstiges
    ;
    MaxPBEnums.i = 3270  
    
    Enumeration 3251 Step 1
        #Dummy001: #Editor002: #Calendar: #Splitter1: #TrackMenu: #EditMenu
        #DesignBox001: #DesignBox002: #DesignBox003: #DesignBox004: #DesignBox005: #DesignBox006:
    EndEnumeration
    Debug "- Sondstige      #3251 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))            
    
    
    DataSection   
        _UPDATEMODUL_BEG:
        IncludeBinary "Update_Modul\_UpdateModul_.exe"
        _UPDATEMODUL_END:         
    EndDataSection
    
EndDeclareModule

Module DC
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 19
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode