;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
DeclareModule UnityHelp
    Structure CmpUnityModus
         UnityIDX.i
         Modus.s
         Description.s
         MenuIndex.i
         bCharSwitch.i
         bMenuSubBeg.i
         bMenuSubEnd.i
         bMenuBar.i
         MenuImageID.i
     EndStructure        
          
     Global NewList UnityCommandline.CmpUnityModus()   
     
     Declare   DataModes(List UnityCommandline.CmpUnityModus())
     Declare.i GetMaxItems()
     Declare.i GetMaxMnuIndex()
     Declare.i SetMnuIndexNum()
     
EndDeclareModule

Module UnityHelp
	Procedure DataModes(List UnityCommandline.CmpUnityModus())
			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "show-screen-selector"   								:UnityCommandline()\Description = "Start Configuration Tool"        				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-d3d11"	  					        			:UnityCommandline()\Description = "Direct3D: 11"				       							:UnityCommandline()\bCharSwitch = #True
    AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = "Direct3D: 11 - Rendering" 							:UnityCommandline()\bMenuSubBeg = #True 		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-d3d11-bitblt-model"	  		   			:UnityCommandline()\Description = "Render as DXGI BitBlt SwapChain"				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-d3d11-flip-model"	  		 	  			:UnityCommandline()\Description = "Render as DXGI Flip SwapChain"					:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-d3d11-no-singlethreaded"	   			:UnityCommandline()\Description = "Render as Singlethreaded: No"						:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-d3d11-singlethreaded"	   					:UnityCommandline()\Description = "Render as Singlethreaded: Yes"					:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-driver-type-warp"	   							:UnityCommandline()\Description = "Render as D3D11 (Warp Type)"						:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-feature-level-10-0"	   						:UnityCommandline()\Description = "Render as D3D11 Feature Level 10.0"			:UnityCommandline()\bCharSwitch = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-feature-level-10-1"	   						:UnityCommandline()\Description = "Render as D3D11 Feature Level 10.1"			:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-feature-level-11-0"	   						:UnityCommandline()\Description = "Render as D3D11 Feature Level 11.0"			:UnityCommandline()\bCharSwitch = #True
    AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = ""                              					:UnityCommandline()\bMenuSubEnd = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-d3d12"	   												:UnityCommandline()\Description = "Direct3D: 12"														:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-gfx-direct"	  										:UnityCommandline()\Description = "Direct3D: Force SingleThread"						:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = "OpengGL: Render Core" 									:UnityCommandline()\bMenuSubBeg = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore"	  												:UnityCommandline()\Description = "Use Default Profile"										:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore32"  												:UnityCommandline()\Description = "Use Profile 3.2"												:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore33"  												:UnityCommandline()\Description = "Use Profile 3.3"												:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore40"  												:UnityCommandline()\Description = "Use Profile 4.0"												:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore41"  												:UnityCommandline()\Description = "Use Profile 4.1"												:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore42"  												:UnityCommandline()\Description = "Use Profile 4.2"												:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore43"  												:UnityCommandline()\Description = "Use Profile 4.3"												:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-glcore44"  												:UnityCommandline()\Description = "Use Profile 4.4"												:UnityCommandline()\bCharSwitch = #True
    AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = ""                              					:UnityCommandline()\bMenuSubEnd = #True			
    AddElement(UnityCommandline()): UnityCommandline()\Modus = "force-vulkan"  													:UnityCommandline()\Description = "OpenGL: Vulkan Core"										:UnityCommandline()\bCharSwitch = #True    
    AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True   
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-fullscreen=1"	  								:UnityCommandline()\Description = "Force Fullscreen"					       				:UnityCommandline()\bCharSwitch = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-fullscreen=0"	  								:UnityCommandline()\Description = "Force Windowed"						       				:UnityCommandline()\bCharSwitch = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "popupwindow"         										:UnityCommandline()\Description = "Fullscreen Borderless Windowed"    			:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "window-mode=exclusive"  								:UnityCommandline()\Description = "Fullscreen Exclusive Mode"       				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "window-mode=borderless"  								:UnityCommandline()\Description = "Fullscreen Borderless Mode"       			:UnityCommandline()\bCharSwitch = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=1280 -screen-height=720"	:UnityCommandline()\Description = "Force Resolution 1280x 720"      				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=1920 -screen-height=1080"	:UnityCommandline()\Description = "Force Resolution 1920x1080"      				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=1920 -screen-height=1200"	:UnityCommandline()\Description = "Force Resolution 1920x1200"      				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=1920 -screen-height=1440"	:UnityCommandline()\Description = "Force Resolution 1920x1440"      				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=2048 -screen-height=1536"	:UnityCommandline()\Description = "Force Resolution 2048x1536"      				:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=2560 -screen-height=1440"	:UnityCommandline()\Description = "Force Resolution 2560x1440"      				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=2560 -screen-height=1600"	:UnityCommandline()\Description = "Force Resolution 2560x1600"      				:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "-screen-width=3840 -screen-height=2160"	:UnityCommandline()\Description = "Force Resolution 3840x2160"      				:UnityCommandline()\bCharSwitch = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""																				:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True 	    
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "monitor=0"  														:UnityCommandline()\Description = "Use Monitor 0"													:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "monitor=1"  														:UnityCommandline()\Description = "Use Monitor 1"													:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "monitor=2"  														:UnityCommandline()\Description = "Use Monitor 2"													:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = "Set Quality Level" 											:UnityCommandline()\bMenuSubBeg = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-quality=fastest"  								:UnityCommandline()\Description = "AF=Off, 0xMSAA, LOD=0.3: Fastest"	  		:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-quality=fast"  									:UnityCommandline()\Description = "AF=Off, 0xMSAA, LOD=0.4: Fast"					:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-quality=simple"  								:UnityCommandline()\Description = "AF=Def, 0xMSAA, LOD=0.7: Simple"	  		:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-quality=good"  									:UnityCommandline()\Description = "AF=Def, 0xMSAA, LOD=1.0: Good"	  			:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-quality=beautiful" 							:UnityCommandline()\Description = "AF=Frc, 2xMSAA, LOD=1.5: Beautiful"  		:UnityCommandline()\bCharSwitch = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "screen-quality=fantastic" 							:UnityCommandline()\Description = "AF=Frc, 2xMSAA, LOD=2.0: Fantastic" 		:UnityCommandline()\bCharSwitch = #True	
    AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = ""                              					:UnityCommandline()\bMenuSubEnd = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True	
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = "Unity 5.1+: VR support" 								:UnityCommandline()\bMenuSubBeg = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "vrmode=None"      											:UnityCommandline()\Description = "Disable No VR"       										:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "vrmode=Stereo"      										:UnityCommandline()\Description = "Stereo 3D "    													:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "vrmode=Split"      											:UnityCommandline()\Description = "Split screen"  													:UnityCommandline()\bCharSwitch = #True			
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "vrmode=Oculus"      										:UnityCommandline()\Description = "Oculus "       													:UnityCommandline()\bCharSwitch = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "vrmode=PlayStationVR"   								:UnityCommandline()\Description = "PlayStationVR"													:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                                 			:UnityCommandline()\Description = ""                              					:UnityCommandline()\bMenuSubEnd = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = ""                       								:UnityCommandline()\Description = "-----------------------------"   				:UnityCommandline()\bMenuBar = #True		
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "logFile=C:\Unity.log"  									:UnityCommandline()\Description = "Enable  LogFile"												:UnityCommandline()\bCharSwitch = #True
		AddElement(UnityCommandline()): UnityCommandline()\Modus = "nolog"  																:UnityCommandline()\Description = "Disable LogFile"												:UnityCommandline()\bCharSwitch = #True
		
		ResetList(UnityCommandline())
                       
        Protected Max_Saves_List 	= ListSize(UnityCommandline()) 
        Protected Index.i 					= SetMnuIndexNum()
        
        For i = 0 To Max_Saves_List-1
            NextElement(UnityCommandline())
            UnityCommandline()\UnityIDX = i
            If Len( UnityCommandline()\Modus ) >= 1
            	Index + 1
            	UnityCommandline()\MenuIndex =  Index ; Menu Item Index 
            EndIf            
        Next
        
        Index +1
        Debug "Menü Erstellung: List Einträge " + Str(Max_Saves_List) +" / Menü Index Einträge von (" + Str(SetMnuIndexNum()) + " bis " + Str( Index ) + ") - Unity"
        SortStructuredList(UnityCommandline(), #PB_Sort_Ascending, OffsetOf(CmpUnityModus\UnityIDX), #PB_Integer)
    
    EndProcedure 
	
  	Procedure.i SetMnuIndexNum()
  		ProcedureReturn 1400
  	EndProcedure
  
    Procedure.i  GetMaxItems()
        ResetList(UnityCommandline())
        ProcedureReturn ListSize(UnityCommandline()) 
    EndProcedure
      
    Procedure.i GetMaxMnuIndex()
    	
        ResetList(UnityCommandline())
        Protected Max_Saves_List 	= ListSize(UnityCommandline()) 
        Protected Index.i 					= SetMnuIndexNum()
        
        For i = 0 To Max_Saves_List-1
            NextElement(UnityCommandline())
						Index + 1  
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
; CurrentDirectory = D:\NewGame\
; Debugger = IDE
; EnableUnicode