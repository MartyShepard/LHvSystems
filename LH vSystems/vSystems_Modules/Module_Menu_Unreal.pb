;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule UnrealHelp
    Structure CmpUDKModus
         UDKIDX.i
         Modus.s
         Description.s
         MenuIndex.i
         bCharSwitch.i
         bMenuSubBeg.i
         bMenuSubEnd.i
         bMenuBar.i
         MenuImageID.i
     EndStructure        
          
     Global NewList UnrealCommandline.CmpUDKModus()   
     
     Declare   DataModes(List UnrealCommandline.CmpUDKModus())
     Declare.i GetMaxItems()
     Declare.i GetMaxMnuIndex()
     Declare.i SetMnuIndexNum()
     
EndDeclareModule

Module UnrealHelp
    ; https://steamcommunity.com/sharedfiles/filedetails/?id=2392187717
    ; https://steamcommunity.com/app/399810/discussions/0/1735469230216582968/
		; https://www.pcgamingwiki.com/wiki/Engine:Unreal_Engine_4     
    Procedure DataModes(List UnrealCommandline.CmpUDKModus())
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "d3d8"                             :UnrealCommandline()\Description = "Set Direct3D 8  Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "d3d9"                             :UnrealCommandline()\Description = "Set Direct3D 9  Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "d3d10"                            :UnrealCommandline()\Description = "Set Direct3D 10 Family"        :UnrealCommandline()\bCharSwitch = #True   
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "d3d11"                            :UnrealCommandline()\Description = "Set Direct3D 11 Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "d3d12"                            :UnrealCommandline()\Description = "Set Direct3D 12 Family"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "opengl"                           :UnrealCommandline()\Description = "Set OpenGL"                    :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "vulkan"                           :UnrealCommandline()\Description = "Set OpenGL Vulkan"             :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "AllowSoftwareRendering"           :UnrealCommandline()\Description = "Software Rendering"            :UnrealCommandline()\bCharSwitch = #True  
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "windowed"                         :UnrealCommandline()\Description = "Render in Window Mode"         :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "fullscreen"                       :UnrealCommandline()\Description = "Render in Fullscreen Mode"     :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "Render Resolutions"            :UnrealCommandline()\bMenuSubBeg = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=640 resy=480"                :UnrealCommandline()\Description = "Render in 640x480"             :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=800 resy=600"                :UnrealCommandline()\Description = "Render in 800x600"             :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=1024 resy=768"               :UnrealCommandline()\Description = "Render in 1024x768"            :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=1024 resy=1024"              :UnrealCommandline()\Description = "Render in 1024x1024"           :UnrealCommandline()\bCharSwitch = #False  
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=1280 resy=720"               :UnrealCommandline()\Description = "Render in 1280x720"            :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=1920 resy=1080"              :UnrealCommandline()\Description = "Render in 1920x1080"           :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=2560 resy=1440"              :UnrealCommandline()\Description = "Render in 2560x1440"           :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "resx=3840 resy=2160"              :UnrealCommandline()\Description = "Render in 3840x2160"           :UnrealCommandline()\bCharSwitch = #False
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = ""                              :UnrealCommandline()\bMenuSubEnd = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "notexturestreaming"               :UnrealCommandline()\Description = "Highest Quality Textures"      :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "novsync"                          :UnrealCommandline()\Description = "No Vertical Sync"              :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "seekfreeloadingpcconsole"         :UnrealCommandline()\Description = "Only Use Cooked Data."         :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "winx=1 winy=2160"                 :UnrealCommandline()\Description = "Set Window Position"           :UnrealCommandline()\bCharSwitch = #False        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "fps=59"                           :UnrealCommandline()\Description = "Set Frames Per Second"         :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "useallavailablecores"             :UnrealCommandline()\Description = "Use All Available Cores"       :UnrealCommandline()\bCharSwitch = #True          
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "PreferAMD"                        :UnrealCommandline()\Description = "Prefer AMD"                    :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "PreferIntel"                      :UnrealCommandline()\Description = "Prefer Intel"                  :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "PreferNVidia"                     :UnrealCommandline()\Description = "Prefer nVidia"                 :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "PreferMS"                         :UnrealCommandline()\Description = "Prefer MS"                     :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True                 
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "language=deu"                     :UnrealCommandline()\Description = "Set Language: German"          :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "culture=de"                     	:UnrealCommandline()\Description = "Set Language: German (Alt)"    :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "language=eng"                     :UnrealCommandline()\Description = "Set Language: English"         :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "culture=en"                     	:UnrealCommandline()\Description = "Set Language: English (Alt)"   :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "ExecCmds="                        :UnrealCommandline()\Description = "Execute Console Commands"      :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "Exec Commandos ..."            :UnrealCommandline()\bMenuSubBeg = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.BloomQuality=0"                 :UnrealCommandline()\Description = "Bloom: Quality"                :UnrealCommandline()\bCharSwitch = 2          
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.DepthOfFieldQuality=0"          :UnrealCommandline()\Description = "Depth Of Field: Quality"       :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "t.MaxFPS=0"                       :UnrealCommandline()\Description = "Disable FPS Cap"               :UnrealCommandline()\bCharSwitch = 2        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "bUseDynamicResolution=False"      :UnrealCommandline()\Description = "Dynamic Resolution"            :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.AllowHDR=0"                     :UnrealCommandline()\Description = "HDR: Allow"                    :UnrealCommandline()\bCharSwitch = 2        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "AllowJoystickInput=0"             :UnrealCommandline()\Description = "Joystick Input: Allow"         :UnrealCommandline()\bCharSwitch = 2        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.MotionBlurQuality=0"            :UnrealCommandline()\Description = "MotionBlur: Quality"           :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.MotionBlur.Max=0"               :UnrealCommandline()\Description = "MotionBlur: Max"               :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.DefaultFeature.MotionBlur=0"    :UnrealCommandline()\Description = "MotionBlur: Default"           :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.PostProcessAAQuality=0"         :UnrealCommandline()\Description = "Post Process AA"               :UnrealCommandline()\bCharSwitch = 2         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.Shadow.MaxResolution=1024"      :UnrealCommandline()\Description = "Shadow Resolution"             :UnrealCommandline()\bCharSwitch = 2
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "bSmoothFrameRate=false"           :UnrealCommandline()\Description = "Smooth Frame Rate"             :UnrealCommandline()\bCharSwitch = 2         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "r.Tonemapper.Quality=0"           :UnrealCommandline()\Description = "Tone Mapper: Quality"          :UnrealCommandline()\bCharSwitch = 2         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = ""                              :UnrealCommandline()\bMenuSubEnd = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = ""                                 :UnrealCommandline()\Description = "-----------------------------" :UnrealCommandline()\bMenuBar = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "showbuildversion=1"               :UnrealCommandline()\Description = "Build Version"                 :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "log LOG=logfile.txt"              :UnrealCommandline()\Description = "Loggin Events Commands"        :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "NoHMD"                            :UnrealCommandline()\Description = "Disable Head-Mounted (VR)"     :UnrealCommandline()\bCharSwitch = #True        
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "NoSteam"                          :UnrealCommandline()\Description = "Dont use Steamworks"           :UnrealCommandline()\bCharSwitch = #True
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "noscreenmessages"                 :UnrealCommandline()\Description = "No Screen Messages"            :UnrealCommandline()\bCharSwitch = #True         
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "NoHomeDir"                        :UnrealCommandline()\Description = "Override My Documents"         :UnrealCommandline()\bCharSwitch = #True 
        AddElement(UnrealCommandline()): UnrealCommandline()\Modus = "skipallnotifies"                  :UnrealCommandline()\Description = "Skip All Notifies"             :UnrealCommandline()\bCharSwitch = #True        
        
        ResetList(UnrealCommandline())
        Protected Max_Saves_List = ListSize(UnrealCommandline()) 
        Protected Index.i = SetMnuIndexNum()
        
        For i = 0 To Max_Saves_List-1
            NextElement(UnrealCommandline())
            UnrealCommandline()\UDKIDX = i
            If Len( UnrealCommandline()\Modus ) >= 1
            	Index + 1
            	UnrealCommandline()\MenuIndex =  Index ; Menu Item Index 
            EndIf
        Next
        
        Index -1
        Debug "Menü Erstellung: List Einträge " + Str(Max_Saves_List) +" / Menü Index Einträge von (" + Str(SetMnuIndexNum()) + " bis " + Str( Index ) + ") - Unreal"
        
        SortStructuredList(UnrealCommandline(), #PB_Sort_Ascending, OffsetOf(CmpUDKModus\UDKIDX), #PB_Integer)
    
    EndProcedure 
	
    Procedure.i SetMnuIndexNum()
        ProcedureReturn 1300
    EndProcedure    
      
    Procedure.i  GetMaxItems()
        ResetList(UnrealCommandline())
        ProcedureReturn ListSize(UnrealCommandline()) 
    EndProcedure 
      
    Procedure.i GetMaxMnuIndex()
    	
        ResetList(UnrealCommandline())
        Protected Max_Saves_List = ListSize(UnrealCommandline()) 
        Protected Index.i = SetMnuIndexNum()
        
        For i = 0 To Max_Saves_List-1
            NextElement(UnrealCommandline())
            If Len( UnrealCommandline()\Modus ) >= 1
            	Index + 1
            EndIf
        Next
        ProcedureReturn Index
    	
   	EndProcedure      
      
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 12
; Folding = --
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\BLACKTAIL\
; Debugger = IDE
; EnableUnicode