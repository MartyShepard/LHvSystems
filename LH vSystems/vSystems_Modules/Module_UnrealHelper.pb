;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule UnrealHelp
    Structure CmpUDKModus
         UDKIDX.i
         UDKModus$
         UDK_Description$
         MenuIndex.i
     EndStructure        
          
     Global NewList UnrealCommandline.CmpUDKModus()   
     
     Declare DataModes(List UnrealCommandline.CmpUDKModus())
     
EndDeclareModule

Module UnrealHelp
    
    Procedure DataModes(List UnrealCommandline.CmpUDKModus())       
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d9"                     :UnrealCommandline()\UDK_Description$ = "use Direct3D 9 Family"
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d10"                    :UnrealCommandline()\UDK_Description$ = "use Direct3D 10 Family"   
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d11"                    :UnrealCommandline()\UDK_Description$ = "use Direct3D 11 Family"     
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "language=deu"             :UnrealCommandline()\UDK_Description$ = "Set Language: German"
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "novsync"                  :UnrealCommandline()\UDK_Description$ = "No Vertical Sync"
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "noscreenmessages"         :UnrealCommandline()\UDK_Description$ = "No Screen Mwssages"        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "notexturestreaming"       :UnrealCommandline()\UDK_Description$ = "No Texture Streaming"        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "seekfreeloadingpcconsole" :UnrealCommandline()\UDK_Description$ = "Seek Free Loading PC Console"
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "showbuildversion=1"       :UnrealCommandline()\UDK_Description$ = "Build Version"       
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "skipallnotifies"          :UnrealCommandline()\UDK_Description$ = "Skip All Notifies"        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "useallavailablecores"     :UnrealCommandline()\UDK_Description$ = "Use All Available Cores"         
        
        ResetList(UnrealCommandline())
        Max_Saves_List = ListSize(UnrealCommandline()) 
        For i = 0 To Max_Saves_List-1
            NextElement(UnrealCommandline())
            UnrealCommandline()\UDKIDX = i
            UnrealCommandline()\MenuIndex = 365+i ; Menu Item Index                        
        Next

        SortStructuredList(UnrealCommandline(), #PB_Sort_Ascending, OffsetOf(CmpUDKModus\UDKIDX), #PB_Integer)
    
    EndProcedure    
      
EndModule

; UseModule Compatibility
;     DataModes(CompatibilitySystem.CmpOSModus(), CompatibilityEmulation.CmpEmulation())
;     UnuseModule Compatibility
; 
;     ResetList(Compatibility::CompatibilitySystem())
;                     
;     For i = 0 To ListSize(Compatibility::CompatibilitySystem()) 
;                  NextElement(Compatibility::CompatibilitySystem())
;                  sCmpMod$ = Compatibility::CompatibilitySystem()\OSModus$
;                             
;                  Debug "Compatibility Modus:"
;                  Debug "- Gefunden: " + sCmpMod$                                                   
;     Next
;Compatibilty::DataVersionFix("Hallo")
; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 34
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; EnableUnicode