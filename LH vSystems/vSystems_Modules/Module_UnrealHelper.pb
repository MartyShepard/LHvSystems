;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule UnrealHelp
    Structure CmpUDKModus
         UDKIDX.i
         UDKModus$
         UDK_Description$
         MenuIndex.i
         bCharSwitch.i
         bMenuSubBeg.i
         bMenuSubEnd.i
         bMenuBar.i         
     EndStructure        
          
     Global NewList UnrealCommandline.CmpUDKModus()   
     
     Declare   DataModes(List UnrealCommandline.CmpUDKModus())
     Declare.i GetMaxItems() 
     
EndDeclareModule

Module UnrealHelp
    ; https://steamcommunity.com/sharedfiles/filedetails/?id=2392187717
    ; https://steamcommunity.com/app/399810/discussions/0/1735469230216582968/
    ; https://www.pcgamingwiki.com/wiki/Engine:Unreal_Engine_4
    Procedure DataModes(List UnrealCommandline.CmpUDKModus())
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d8"                             :UnrealCommandline()\UDK_Description$ = "Set Direct3D 8  Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d9"                             :UnrealCommandline()\UDK_Description$ = "Set Direct3D 9  Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d10"                            :UnrealCommandline()\UDK_Description$ = "Set Direct3D 10 Family"        :UnrealCommandline()\bCharSwitch = #True   
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d11"                            :UnrealCommandline()\UDK_Description$ = "Set Direct3D 11 Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "d3d12"                            :UnrealCommandline()\UDK_Description$ = "Set Direct3D 12 Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "opengl"                           :UnrealCommandline()\UDK_Description$ = "Set OpenGL"                    :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "vulkan"                           :UnrealCommandline()\UDK_Description$ = "Set OpenGL Vulkan"             :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "AllowSoftwareRendering"           :UnrealCommandline()\UDK_Description$ = "Software Rendering"            :UnrealCommandline()\bCharSwitch = #True  
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "windowed"                         :UnrealCommandline()\UDK_Description$ = "Render in Window Mode"         :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "fullscreen"                       :UnrealCommandline()\UDK_Description$ = "Render in Fullscreen Mode"     :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "Render Resolutions"            :UnrealCommandline()\bMenuSubBeg = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=640 resy=480"                :UnrealCommandline()\UDK_Description$ = "Render in 640x480"             :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=800 resy=600"                :UnrealCommandline()\UDK_Description$ = "Render in 800x600"             :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=1024 resy=768"               :UnrealCommandline()\UDK_Description$ = "Render in 1024x768"            :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=1024 resy=1024"              :UnrealCommandline()\UDK_Description$ = "Render in 1024x1024"           :UnrealCommandline()\bCharSwitch = #False  
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=1280 resy=720"               :UnrealCommandline()\UDK_Description$ = "Render in 1280x720"            :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=1920 resy=1080"              :UnrealCommandline()\UDK_Description$ = "Render in 1920x1080"           :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=2560 resy=1440"              :UnrealCommandline()\UDK_Description$ = "Render in 2560x1440"           :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "resx=3840 resy=2160"              :UnrealCommandline()\UDK_Description$ = "Render in 3840x2160"           :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = ""                              :UnrealCommandline()\bMenuSubEnd = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "notexturestreaming"               :UnrealCommandline()\UDK_Description$ = "Highest Quality Textures"      :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "novsync"                          :UnrealCommandline()\UDK_Description$ = "No Vertical Sync"              :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "seekfreeloadingpcconsole"         :UnrealCommandline()\UDK_Description$ = "Only Use Cooked Data."         :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "winx=1 winy=2160"                 :UnrealCommandline()\UDK_Description$ = "Set Window Position"           :UnrealCommandline()\bCharSwitch = #False        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "fps=59"                           :UnrealCommandline()\UDK_Description$ = "Set Frames Per Second"         :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "useallavailablecores"             :UnrealCommandline()\UDK_Description$ = "Use All Available Cores"       :UnrealCommandline()\bCharSwitch = #True          
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "PreferAMD"                        :UnrealCommandline()\UDK_Description$ = "Prefer AMD"                    :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "PreferIntel"                      :UnrealCommandline()\UDK_Description$ = "Prefer Intel"                  :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "PreferNVidia"                     :UnrealCommandline()\UDK_Description$ = "Prefer nVidia"                 :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "PreferMS"                         :UnrealCommandline()\UDK_Description$ = "Prefer MS"                     :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True                 
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "language=deu"                     :UnrealCommandline()\UDK_Description$ = "Set Language: German"          :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "language=eng"                     :UnrealCommandline()\UDK_Description$ = "Set Language: English"         :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "ExecCmds="                        :UnrealCommandline()\UDK_Description$ = "Execute Console Commands"      :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "Exec Commandos ..."            :UnrealCommandline()\bMenuSubBeg = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.BloomQuality=0"                 :UnrealCommandline()\UDK_Description$ = "Bloom: Quality"                :UnrealCommandline()\bCharSwitch = 2          
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.DepthOfFieldQuality=0"          :UnrealCommandline()\UDK_Description$ = "Depth Of Field: Quality"       :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "t.MaxFPS=0"                       :UnrealCommandline()\UDK_Description$ = "Disable FPS Cap"               :UnrealCommandline()\bCharSwitch = 2        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "bUseDynamicResolution=False"      :UnrealCommandline()\UDK_Description$ = "Dynamic Resolution"            :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.AllowHDR=0"                     :UnrealCommandline()\UDK_Description$ = "HDR: Allow"                    :UnrealCommandline()\bCharSwitch = 2        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "AllowJoystickInput=0"             :UnrealCommandline()\UDK_Description$ = "Joystick Input: Allow"         :UnrealCommandline()\bCharSwitch = 2        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.MotionBlurQuality=0"            :UnrealCommandline()\UDK_Description$ = "MotionBlur: Quality"           :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.MotionBlur.Max=0"               :UnrealCommandline()\UDK_Description$ = "MotionBlur: Max"               :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.DefaultFeature.MotionBlur=0"    :UnrealCommandline()\UDK_Description$ = "MotionBlur: Default"           :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.PostProcessAAQuality=0"         :UnrealCommandline()\UDK_Description$ = "Post Process AA"               :UnrealCommandline()\bCharSwitch = 2         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.Shadow.MaxResolution=1024"      :UnrealCommandline()\UDK_Description$ = "Shadow Resolution"             :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "bSmoothFrameRate=false"           :UnrealCommandline()\UDK_Description$ = "Smooth Frame Rate"             :UnrealCommandline()\bCharSwitch = 2         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "r.Tonemapper.Quality=0"           :UnrealCommandline()\UDK_Description$ = "Tone Mapper: Quality"          :UnrealCommandline()\bCharSwitch = 2         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = ""                              :UnrealCommandline()\bMenuSubEnd = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = ""                                 :UnrealCommandline()\UDK_Description$ = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "showbuildversion=1"               :UnrealCommandline()\UDK_Description$ = "Build Version"                 :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "log LOG=logfile.txt"              :UnrealCommandline()\UDK_Description$ = "Loggin Events Commands"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "NoHMD"                            :UnrealCommandline()\UDK_Description$ = "Disable Head-Mounted (VR)"     :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "NoSteam"                          :UnrealCommandline()\UDK_Description$ = "Dont use Steamworks"           :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "noscreenmessages"                 :UnrealCommandline()\UDK_Description$ = "No Screen Messages"            :UnrealCommandline()\bCharSwitch = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "NoHomeDir"                        :UnrealCommandline()\UDK_Description$ = "Override My Documents"         :UnrealCommandline()\bCharSwitch = #True 
        AddElement(UnrealCommandline()): UnrealCommandline()\UDKModus$ = "skipallnotifies"                  :UnrealCommandline()\UDK_Description$ = "Skip All Notifies"             :UnrealCommandline()\bCharSwitch = #True        
        
        ResetList(UnrealCommandline())
        Max_Saves_List = ListSize(UnrealCommandline()) 
        For i = 0 To Max_Saves_List-1
            NextElement(UnrealCommandline())
            UnrealCommandline()\UDKIDX = i
            UnrealCommandline()\MenuIndex = 365+i ; Menu Item Index                        
        Next
        
        Debug "Unreal Commands Liste " + Str(Max_Saves_List)
        SortStructuredList(UnrealCommandline(), #PB_Sort_Ascending, OffsetOf(CmpUDKModus\UDKIDX), #PB_Integer)
    
    EndProcedure 
    
    Procedure.i  GetMaxItems()
        ResetList(UnrealCommandline())
        ProcedureReturn ListSize(UnrealCommandline()) 
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
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 24
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\BLACKTAIL\
; Debugger = IDE
; EnableUnicode