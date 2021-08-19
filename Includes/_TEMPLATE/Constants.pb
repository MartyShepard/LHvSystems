DeclareModule DC
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Windows 1-10
    
    Enumeration 01 Step 1
        #_Window_001        
    EndEnumeration
    
    EnumEnd =  23
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue              
    Debug #TAB$ + "Constansts Enumeration : 0001 -> " + RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0")  +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Windows"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Dateien
    
    Enumeration 24 Step 1
        #LOGFILE        
    EndEnumeration
    
    EnumEnd =  40
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0024 -> " + RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Dateien"       
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: ListIcon
    
    Enumeration 41 Step 1
        #ListIcon_001        
    EndEnumeration
    
    EnumEnd =  70
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0041 -> " + RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0")+" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::ListIcon Gadget"     
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Tray/PopUpMenu
    
    Enumeration 71 Step 1
        #MouseMenu001
    EndEnumeration
    
    EnumEnd =  87
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0071 -> " + RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Tray/ PopUpMenu Gadget"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: ProgressBar
    
    Enumeration 88 Step 1
        #Progress_001
    EndEnumeration
    
    EnumEnd =  90
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0088 -> " + RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::ProgressBar Gadget"   
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: ImageGadget
    
    Enumeration 91 Step 1
        #ImageGadget_001
    EndEnumeration
    
    EnumEnd =  120
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0091 -> " + RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::ImageGadget Gadget"  
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Scrollarea
    
    Enumeration 121 Step 1
        #ScAr001
    EndEnumeration        
    
    EnumEnd =  140
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0121 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::ScrollArea Gadget"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Strings
    
    Enumeration 141 Step 1
        #String_001        
    EndEnumeration
    
    EnumEnd =  499
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0141 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::String Gadget / Modul: Mouse Cursor Enmumeration"
    
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Database
    
    Enumeration 500 Step 1
        #Database_001
    EndEnumeration
    
    EnumEnd =  598
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0500 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Database"
    
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Images(ID)
    
    Enumeration 611 Step 1
        #ImageBlank
    EndEnumeration
    
    EnumEnd =  810
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0611 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Images, Picture ID's"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Buttons
    
    Enumeration 811 Step 1
        #Button_001
    EndEnumeration
    
    EnumEnd =  959
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 0811 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Button Gadgets / Modul: GadgetEX/RequestEX Enumeration"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: ComboBox
    
    Enumeration 1001 Step 1
        #ComboBox_001: #ComboBox_002: #ComboBox_003: #ComboBox_004: #ComboBox_005: #ComboBox_006
    EndEnumeration
    
    EnumEnd =  1300
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 1001 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::ComboBox Gadgets"
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: CheckBox
    
    Enumeration 1301 Step 1
        #CheckBox_001:
    EndEnumeration
    
    EnumEnd =  1600
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 1301 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::CheckBox Gadgets"
    
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Text Gadget
    
    Enumeration 1601 Step 1
        #Text_001:
    EndEnumeration
    
    EnumEnd =  2100
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 1601 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Text Gadgets"        
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Frame Gadget
    
    Enumeration 2101 Step 1
        #Frame_001             
    EndEnumeration
    
    EnumEnd =  2160
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 2101 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Frame Gadgets"                  
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Background Images
    
    Enumeration 2201 Step 1
        #SkinBase_001
    EndEnumeration
    
    EnumEnd =  2400
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 2201 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Background Images"        
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Canvas Gadgets
    
    Enumeration 2401 Step 1
    EndEnumeration
    
    EnumEnd =  2600
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 2401 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Canvas Gadget's"          
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Aspect Ratio Background Images
    
    Enumeration 2601 Step 1
    EndEnumeration
    
    EnumEnd =  2620
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 2601 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Aspect Ratio Background Images"         
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Icons
    
    Enumeration 2621 Step 1
        #Icon_001
    EndEnumeration
    
    EnumEnd =  2800
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 2621 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Icons"         
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Buttons For GadgetEX (Seperate)
    
    Enumeration 2801 Step 1
    EndEnumeration
    
    EnumEnd =  3100
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 2801 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Buttons For GadgetEX (Seperate)"         
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Container
    
    Enumeration 3101 Step 1
    EndEnumeration
    
    EnumEnd =  3150
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 3101 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Container Gadgets I)"        
    
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Sonstiges
    
    Enumeration 3251 Step 1
    EndEnumeration                
    
    EnumEnd =  3270
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 3251 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Sonstiges Gadgets)"          
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Container 3 
    
    Enumeration 4101 Step 1
    EndEnumeration
    
    EnumEnd =  4700
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 4101 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Container Gadgets II)"         
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes
    ;
    ;   Constants: Buttons For GadgetEX (Seperate)
    
    Enumeration 4701 Step 1
        #_CBX_DEFA1_0N: #_CBX_DEFA1_0H: #_CBX_DEFA1_0P: #_CBX_DEFA1_0D: #_CBX_DEFA1_1N: #_CBX_DEFA1_1H: #_CBX_DEFA1_1P: #_CBX_DEFA1_1D:                          
    EndEnumeration
    
    EnumEnd =  4720
    EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue             
    Debug #TAB$ + "Constansts Enumeration : 4701 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DC::Checkbox Buttons For GadgetEX (Seperate))"          
EndDeclareModule
Module DC
EndModule
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 241
; Folding = -
; EnableAsm
; EnableUnicode
; EnableXP