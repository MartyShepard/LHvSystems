CompilerIf #PB_Compiler_IsMainFile
;      XIncludeFile "..\..\LH Game Start\INCLUDES_CLS\Class_Tooltip.pb"  
;      XIncludeFile "..\..\LH Game Start\INCLUDES_CLS\Class_GadgetEX.pb"
;      XIncludeFile "..\..\LH Game Start\INCLUDES_CLS\Class_RequestEX.pb"     
;      XIncludeFile "..\..\LH Game Start\INCLUDES_CLS\Class_Windows.pb"     
;      XIncludeFile "..\..\LH Game Start\INCLUDES_CLS\Class_FileFoldPath.pb"
;      XIncludeFile "..\..\LH Game Start\INCLUDES_CLS\Class_ArchiveZip.pbi"  
CompilerEndIf    

DeclareModule idTech1_WFM
    
    Declare WadOpen(FileConstant.i, File$)
    Declare WadOpen_Memory(*PWAD) 
    Declare WadOpen_Zipped(File$)
    Declare GetLump(FileConstant, File$)
    Declare WadData_Levels()
    Declare WadData_Info(Mode = 0,Filename$ = "", *WadFile = 0, InZipFile$ = "", MapInfoText$ = "")

    
    ;***************************************************************************************************
    ;        
    ; Structure für die automtische Level Selection
    
    Structure STRUCT_IDLVL
        cWadId.s{4}
        cWadLumps.l
        cWadDirOffset.l
        cWarp.s{12}
        cLevel.s{20}
        cMegaWad.i
        cMegaDes.s{255}
        cInfoLine.s{1024}
        cArchivCount.i
        cArchivIndex.i[1000]
        cArchivFiles.s{1024}
        LumpNames.s{1024}
    EndStructure   
        
    Global *idMaps.STRUCT_IDLVL       = AllocateMemory(SizeOf(STRUCT_IDLVL))   
    
    ;***************************************************************************************************
    ;        
    ; Structure für die automtische Level Selection
    
    Structure STRUCT_LUMPS
        Episode1.i     
        Episode2.i
        Episode3.i        
        Episode4.i
        Episode5.i        
        Episode6.i        
        Megawad32.i 
        
        MAP01.i
        MAP02.i
        MAP03.i
        MAP04.i
        MAP05.i
        MAP06.i
        MAP07.i
        MAP08.i
        MAP09.i        
        MAP10.i
        MAP11.i        
        MAP12.i  
        MAP13.i
        MAP14.i
        MAP15.i
        MAP16.i
        MAP17.i
        MAP18.i
        MAP19.i           
        MAP20.i
        MAP21.i
        MAP22.i
        MAP23.i        
        MAP24.i
        MAP25.i
        MAP26.i
        MAP27.i
        MAP28.i
        MAP29.i
        MAP30.i
        MAP31.i
        MAP32.i
        
        ; Hexen
        MAP33.i
        MAP34.i
        MAP35.i
        MAP36.i
        MAP37.i        
        MAP38.i
        MAP39.i
        MAP40.i
        MAP41.i
        ; Hexen DD
        MAP42.i
        MAP43.i        
        MAP44.i
        MAP45.i
        MAP46.i
        MAP47.i
        MAP48.i
        MAP49.i
        MAP50.i
        MAP51.i
        MAP52.i
        MAP53.i        
        MAP54.i
        MAP55.i
        MAP56.i
        MAP57.i
        MAP58.i
        MAP59.i        
        
        E1M1.i
        E1M2.i
        E1M3.i
        E1M4.i
        E1M5.i
        E1M6.i
        E1M7.i
        E1M8.i
        E1M9.i
        
        E2M1.i
        E2M2.i
        E2M3.i
        E2M4.i
        E2M5.i
        E2M6.i
        E2M7.i
        E2M8.i
        E2M9.i
       
        E3M1.i
        E3M2.i
        E3M3.i
        E3M4.i
        E3M5.i
        E3M6.i
        E3M7.i
        E3M8.i
        E3M9.i        
          
        E4M1.i
        E4M2.i
        E4M3.i
        E4M4.i
        E4M5.i
        E4M6.i
        E4M7.i
        E4M8.i
        E4M9.i        
        
        ; Heretic
        E5M1.i
        E5M2.i
        E5M3.i
        E5M4.i
        E5M5.i
        E5M6.i
        E5M7.i
        E5M8.i
        E5M9.i
        
        E6M1.i
        E6M2.i
        E6M3.i
        
        LumpLvl.s{255}
    EndStructure     
    Global *idLumps.STRUCT_LUMPS       = AllocateMemory(SizeOf(STRUCT_LUMPS))  
    
    Global DemoFileCount = -1
EndDeclareModule

Module idTech1_WFM
    
    
    
   
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : ResetLumpStruct
    ; '  DESCRIPTION  : Cleared and set the Structure to 0
    ; ' -------------------------------------------------------------------------------- 
    Procedure ResetLumpStruct()
                
        *idLumps\Episode1.i = 0
        *idLumps\Episode2.i = 0 
        *idLumps\Episode3.i = 0 
        *idLumps\Episode4.i = 0
        *idLumps\Episode5.i = 0        
        *idLumps\Episode6.i = 0        
        *idLumps\Megawad32.i= 0
        
        *idLumps\E1M1 = 0
        *idLumps\E1M2 = 0
        *idLumps\E1M3 = 0
        *idLumps\E1M4 = 0
        *idLumps\E1M5 = 0
        *idLumps\E1M6 = 0
        *idLumps\E1M7 = 0
        *idLumps\E1M8 = 0
        *idLumps\E1M9 = 0
        
        *idLumps\E2M1 = 0
        *idLumps\E2M2 = 0
        *idLumps\E2M3 = 0
        *idLumps\E2M4 = 0
        *idLumps\E2M5 = 0
        *idLumps\E2M6 = 0
        *idLumps\E2M7 = 0
        *idLumps\E2M8 = 0
        *idLumps\E2M9 = 0
        
        *idLumps\E3M1 = 0
        *idLumps\E3M2 = 0
        *idLumps\E3M3 = 0
        *idLumps\E3M4 = 0
        *idLumps\E3M5 = 0
        *idLumps\E3M6 = 0
        *idLumps\E3M7 = 0
        *idLumps\E3M8 = 0
        *idLumps\E3M9 = 0        
        
        *idLumps\E4M1 = 0
        *idLumps\E4M2 = 0
        *idLumps\E4M3 = 0
        *idLumps\E4M4 = 0
        *idLumps\E4M5 = 0
        *idLumps\E4M6 = 0
        *idLumps\E4M7 = 0
        *idLumps\E4M8 = 0
        *idLumps\E4M9 = 0        
        
        *idLumps\E5M1 = 0
        *idLumps\E5M2 = 0
        *idLumps\E5M3 = 0
        *idLumps\E5M4 = 0
        *idLumps\E5M5 = 0
        *idLumps\E5M6 = 0
        *idLumps\E5M7 = 0
        *idLumps\E5M8 = 0
        *idLumps\E5M9 = 0  
        
        *idLumps\E6M1 = 0
        *idLumps\E6M2 = 0
        *idLumps\E6M3 = 0
        
        *idLumps\MAP01 = 0
        *idLumps\MAP02 = 0
        *idLumps\MAP03 = 0
        *idLumps\MAP04 = 0
        *idLumps\MAP05 = 0
        *idLumps\MAP06 = 0
        *idLumps\MAP07 = 0
        *idLumps\MAP08 = 0
        *idLumps\MAP09 = 0
        *idLumps\MAP10 = 0
        *idLumps\MAP11 = 0
        *idLumps\MAP12 = 0
        *idLumps\MAP13 = 0
        *idLumps\MAP14 = 0
        *idLumps\MAP15 = 0
        *idLumps\MAP16 = 0
        *idLumps\MAP17 = 0
        *idLumps\MAP18 = 0
        *idLumps\MAP19 = 0
        *idLumps\MAP20 = 0
        *idLumps\MAP21 = 0
        *idLumps\MAP22 = 0
        *idLumps\MAP23 = 0
        *idLumps\MAP24 = 0
        *idLumps\MAP25 = 0
        *idLumps\MAP26 = 0
        *idLumps\MAP27 = 0
        *idLumps\MAP28 = 0
        *idLumps\MAP29 = 0
        *idLumps\MAP30 = 0        
        *idLumps\MAP31 = 0        
        *idLumps\MAP32 = 0
        ; Hexen
        *idLumps\MAP33 = 0
        *idLumps\MAP34 = 0        
        *idLumps\MAP35 = 0        
        *idLumps\MAP36 = 0        
        *idLumps\MAP37 = 0        
        *idLumps\MAP38 = 0        
        *idLumps\MAP39 = 0        
        *idLumps\MAP40 = 0        
        *idLumps\MAP41 = 0
        ; Hexen DD
        *idLumps\MAP42 = 0        
        *idLumps\MAP43 = 0
        *idLumps\MAP44 = 0
        *idLumps\MAP45 = 0
        *idLumps\MAP46 = 0
        *idLumps\MAP47 = 0
        *idLumps\MAP48 = 0
        *idLumps\MAP49 = 0        
        *idLumps\MAP50 = 0
        *idLumps\MAP51 = 0
        *idLumps\MAP52 = 0
        *idLumps\MAP53 = 0
        *idLumps\MAP54 = 0
        *idLumps\MAP55 = 0
        *idLumps\MAP56 = 0
        *idLumps\MAP57 = 0
        *idLumps\MAP58 = 0
        *idLumps\MAP59 = 0
        
    EndProcedure
    
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : GetLump_Sub
    ; '  DESCRIPTION  : Subfuntion for GetLump and WadMemory
    ; ' --------------------------------------------------------------------------------     
    Procedure GetLump_Sub(LumpName$)
        
        Select UCase(LumpName$)
                
            Case "E1M1"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M1 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M2"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M2 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M3"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M3 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M4"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M4 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M5"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M5 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M6"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M6 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M7"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M7 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M8"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M8 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E1M9"
                Debug "Found Level: " + LumpName$
                *idLumps\E1M9 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M1"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M1 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M2"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M2 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M3"
                Debug "Found Level: " + LumpName$                                        
                *idLumps\E2M3 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M4"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M4 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M5"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M5 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M6"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M6 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M7"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M7 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M8"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M8 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E2M9"
                Debug "Found Level: " + LumpName$
                *idLumps\E2M9 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M1"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M1 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M2"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M2 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M3"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M3 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M4"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M4 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M5"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M5 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M6"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M6 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M7"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M7 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M8"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M8 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E3M9"
                Debug "Found Level: " + LumpName$
                *idLumps\E3M9 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M1"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M1 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M2"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M2 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M3"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M3 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M4"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M4 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M5"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M5 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M6"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M6 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M7"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M7 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M8"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M8 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E4M9"
                Debug "Found Level: " + LumpName$
                *idLumps\E4M9 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                ;
                ;
                ; Heretic
            Case "E5M1"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M1 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M2"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M2 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M3"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M3 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M4"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M4 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M5"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M5 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M6"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M6 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M7"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M7 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M8"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M8 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E5M9"
                Debug "Found Level: " + LumpName$
                *idLumps\E5M9 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E6M1"
                Debug "Found Level: " + LumpName$
                *idLumps\E6M1 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E6M2"
                Debug "Found Level: " + LumpName$
                *idLumps\E6M2 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "E6M3"
                Debug "Found Level: " + LumpName$
                *idLumps\E6M3 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
                ;
                ;
                ; Doom 2, Final Doom Etc
            Case "MAP01"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP01 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP02"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP02 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP03"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP03 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP04"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP04 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP05"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP05 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP06"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP06 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP07"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP07 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP08"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP08 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP09"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP09 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP10"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP10 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP11"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP11 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP12"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP12 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP13"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP13 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP14"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP14 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP15"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP15 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP16"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP16 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP17"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP17 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP18"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP18 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP19" 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP19 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP20"                                    
                Debug "Found Level: " + LumpName$
                *idLumps\MAP20 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
            Case "MAP21"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP21 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP22"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP22 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP23"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP23 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP24"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP24 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP25"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP25 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP26"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP26 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP27"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP27 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP28"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP28 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP29"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP29 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP30"                                    
                Debug "Found Level: " + LumpName$
                *idLumps\MAP30 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP31"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP31 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP32"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP32 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
                ;
                ; Hexen
            Case "MAP33"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP33 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP34"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP34 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                
                
            Case "MAP35"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP35 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                
                
            Case "MAP36"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP36 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                
                
            Case "MAP37"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP37 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP38"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP38 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                          
                
            Case "MAP39"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP39 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                
                
            Case "MAP40"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP40 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                
                
            Case "MAP41"                                 
                Debug "Found Level: " + LumpName$
                *idLumps\MAP41 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                ;
                ;
                ; Hexen: Addon
            Case "MAP42"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP42 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP43"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP43 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP44"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP44 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP45"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP45 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP46"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP46 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP47"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP47 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP48"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP48 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP49"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP49 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", " 
                
            Case "MAP50"                                    
                Debug "Found Level: " + LumpName$
                *idLumps\MAP50 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
            Case "MAP51"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP51 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP52"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP52 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP53"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP53 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP54"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP54 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP55"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP55 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP56"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP56 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP57"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP57 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP58"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP58 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "
                
            Case "MAP59"
                Debug "Found Level: " + LumpName$
                *idLumps\MAP59 = 1
                *idLumps\LumpLvl.s = *idLumps\LumpLvl.s + UCase(LumpName$) + ", "                
            Default                  
        EndSelect                                                                 
    EndProcedure
    
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : WadOpen_Memory
    ; '  DESCRIPTION  : Open the *.Wad(file)
    ; ' --------------------------------------------------------------------------------
    Procedure WadOpen_Memory(*PWAD)
        Protected LumpIndex.i, Offset_Start.l, Offset_Space.l, Set_LumpName.l, LumpName$

        
        If *PWAD = 0
            
            
            ProcedureReturn
            
        EndIf
                ;
                ;
                ; ASCII string "PWAD" or "IWAD", defines whether the WAD is a PWAD or an IWAD        
                *idMaps.STRUCT_IDLVL\cWadId = PeekS(*PWAD,4,#PB_UTF8) 
                
                ;
                ;
                ; An integer specifying the number of entries in the directory  (Lumps)                 
                *idMaps.STRUCT_IDLVL\cWadLumps = PeekL( *PWAD + 4)
                
                ;
                ;
                ; An integer specifying the number of entries in the directory                
                *idMaps.STRUCT_IDLVL\cWadDirOffset = PeekL( *PWAD + 8)
                
                                     
                Offset_Start.l = *idMaps\cWadDirOffset     ; The Entry Offset
                Offset_Space.l = 8                         ; Addin 8 Bytes
                Set_LumpName.l = *idMaps\cWadDirOffset + 8 ; The First Lumpname
                
                For LumpIndex = 0 To idTech1_WFM::*idMaps\cWadLumps - 1
                                                                   
                            LumpName$ = PeekS( *PWAD + Set_LumpName,8,#PB_UTF8)
                            LumpName$ = Trim(LumpName$)
                            
                            If Len(LumpName$) >= 4  
                                
                                GetLump_Sub(LumpName$)
                                If LumpIndex <= 9
                                    *idMaps\LumpNames.s = *idMaps\LumpNames.s + Chr(10) + PeekS( *PWAD + Set_LumpName,8,#PB_UTF8)
                                EndIf     
                                If LumpIndex = 10
                                    *idMaps\LumpNames.s = *idMaps\LumpNames.s + Chr(10) + "......."
                                EndIf                                 
                                Debug "Number: " + Str(LumpIndex) + " -- Offset: " + RSet(Hex(Set_LumpName),8,"0") + " -- LumpName: " + PeekS( *PWAD + Set_LumpName,8,#PB_UTF8)
                            EndIf

                    ;
                    ;
                    ; Adding 16 Bytes to adjust the next Name
                    Set_LumpName = Set_LumpName + 16                    
              Next      
              
              
            *idLumps\LumpLvl = Trim(*idLumps\LumpLvl)        
            *idLumps\LumpLvl = Left(*idLumps\LumpLvl,Len(*idLumps\LumpLvl) - 1)                
            Max = CountString(*idLumps\LumpLvl,",")
            If Max >= 1
                *idLumps\LumpLvl = ReplaceString(*idLumps\LumpLvl,",",Chr(10),0,1,Max)
            EndIf 
        
    EndProcedure    
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : WadOpen
    ; '  DESCRIPTION  : Open the *.Wad(file)
    ; ' --------------------------------------------------------------------------------
    Procedure WadOpen(FileConstant.i, File$)
        Protected Result.i, *MemoryID, hBytes.l
        
        
        *idMaps\cWadId.s       = ""
        *idMaps\cWadLumps.l    = -1
        *idMaps\cWadDirOffset.l= -1
        *idMaps\cWarp.s        = ""
        *idMaps\cLevel.s       = ""
        *idMaps\cMegaWad.i     = -1
        *idMaps\cMegaDes.s     = ""
        *idMaps\cInfoLine.s    = ""
        *idMaps\cArchivCount.i = -1
        *idMaps\cArchivFiles.s = ""
        *idLumps\LumpLvl       = ""
        *idMaps\LumpNames      = ""
        
        Result = OpenFile(FileConstant, File$, #PB_File_SharedRead )   
        Select Result
            Case 0
                
                
            Default
                ReadFile(FileConstant, File$)
                
                FileSeek(FileConstant, 0,#PB_Absolute)
                
                ;
                ;
                ; ASCII string "PWAD" or "IWAD", defines whether the WAD is a PWAD or an IWAD
                *MemoryID = AllocateMemory(4)         ;
                If *MemoryID                    
                    hBytes = ReadData(FileConstant, *MemoryID, 4)   ; einlesen der ersten 4 bytes
                    *idMaps.STRUCT_IDLVL\cWadId = PeekS(*MemoryID,-1,#PB_UTF8) 
                    
                    If MemorySize(*MemoryID) <> -1: FreeMemory( *MemoryID): EndIf
                EndIf          
                
                ;
                ;
                ; An integer specifying the number of entries in the directory  (Lumps)              
                FileSeek(FileConstant, 4,#PB_Absolute)
                *MemoryID = AllocateMemory(4)         ;
                If *MemoryID                    
                    hBytes = ReadData(FileConstant, *MemoryID, 4)   ;                    
                    *idMaps.STRUCT_IDLVL\cWadLumps = PeekI(*MemoryID)                                         
                    If MemorySize(*MemoryID) <> -1: FreeMemory( *MemoryID): EndIf
                EndIf                
                
                ;
                ;
                ; An integer specifying the number of entries in the directory                
                FileSeek(FileConstant, 8,#PB_Absolute)                   
                *MemoryID = AllocateMemory(4)         ;
                If *MemoryID                    
                    hBytes = ReadData(FileConstant, *MemoryID, 4)   ;
                    *idMaps.STRUCT_IDLVL\cWadDirOffset = PeekL(*MemoryID)
                    
                    If MemorySize(*MemoryID) <> -1: FreeMemory( *MemoryID): EndIf
                EndIf 
                
                
                CloseFile(FileConstant)            
        EndSelect              
    EndProcedure
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : GetLump
    ; '  DESCRIPTION  : Read a lump from a wad and return the data
    ; ' -------------------------------------------------------------------------------- 
    Procedure GetLump(FileConstant, File$)
        Protected Offset_Start.l, Offset_Space.l, Set_LumpName.l, LumpIndex.i, *MemoryID, hBytes.i, LumpName$
        
        ResetLumpStruct()
        
        Result = OpenFile(FileConstant,File$,#PB_File_SharedRead )   
        Select Result
            Case 0
            Default
                
                If idTech1_WFM::*idMaps\cWadLumps = -1: ProcedureReturn: EndIf                                   
                
                ReadFile(FileConstant, File$)
                  
                Offset_Start.l = *idMaps\cWadDirOffset     ; The Entry Offset
                Offset_Space.l = 8                         ; Addin 8 Bytes
                Set_LumpName.l = *idMaps\cWadDirOffset + 8 ; The First Lumpname
                
                For LumpIndex = 0 To idTech1_WFM::*idMaps\cWadLumps - 1
                                        
                    FileSeek(FileConstant, Set_LumpName)
                    
                    *MemoryID = AllocateMemory(8)         ;
                    If *MemoryID
                        hBytes = ReadData(FileConstant, *MemoryID, 8)
                        
                        If hBytes >= 1
                            
                            LumpName$ = PeekS(*MemoryID,hBytes,#PB_UTF8)
                            LumpName$ = Trim(LumpName$)
                            
                            If Len(LumpName$) >= 4   
                                
                                GetLump_Sub(LumpName$)
                                If LumpIndex <= 9
                                    *idMaps\LumpNames.s = *idMaps\LumpNames.s + Chr(10) + PeekS(*MemoryID,hBytes,#PB_UTF8)
                                EndIf  
                                If LumpIndex = 10
                                    *idMaps\LumpNames.s = *idMaps\LumpNames.s + Chr(10) + "......."
                                EndIf    
                                Debug "Number: " + Str(LumpIndex) + " -- Offset: " + RSet(Hex(Set_LumpName),8,"0") + " -- LumpName: " + PeekS(*MemoryID,hBytes,#PB_UTF8)
                                                        
                            EndIf
                        EndIf  

                        If MemorySize(*MemoryID) <> -1: FreeMemory( *MemoryID): EndIf
                    EndIf
                    ;
                    ;
                    ; Adding 16 Bytes to adjust the next Name
                    Set_LumpName = Set_LumpName + 16
                Next    
        EndSelect
                
        *idLumps\LumpLvl = Trim(*idLumps\LumpLvl)        
        *idLumps\LumpLvl = Left(*idLumps\LumpLvl,Len(*idLumps\LumpLvl) - 1)                
        Max = CountString(*idLumps\LumpLvl,",")
        If Max >= 1
            *idLumps\LumpLvl = ReplaceString(*idLumps\LumpLvl,",",Chr(10),0,1,Max)
        EndIf    
        
    EndProcedure    
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : WadData_Levels
    ; '  DESCRIPTION  : Set Level Description and Start Mode
    ; 
    Procedure WadData_Levels()
        
        Select UCase(*idMaps\cWadId)
                
;             Case "IWAD"
;                 *idMaps\cWarp = ""
;                 *idMaps\cLevel= ""
                
            Case "PWAD", "IWAD"
                
                ;
                ;
                ; Get the First Level
                If *idLumps\E1M1 = 1
                    *idMaps\cWarp = "-warp 1 1"
                    *idMaps\cLevel= "E1M1"
                    
                ElseIf *idLumps\E1M2 = 1
                    *idMaps\cWarp = "-warp 1 2"
                    *idMaps\cLevel= "E1M2"                
                    
                ElseIf *idLumps\E1M3 = 1
                    *idMaps\cWarp = "-warp 1 3"
                    *idMaps\cLevel= "E1M3"                     
                    
                ElseIf *idLumps\E1M4 = 1
                    *idMaps\cWarp = "-warp 1 4"
                    *idMaps\cLevel= "E1M4"                     
                    
                ElseIf *idLumps\E1M5 = 1
                    *idMaps\cWarp = "-warp 1 2"
                    *idMaps\cLevel= "E1M5"                     
                    
                ElseIf *idLumps\E1M6 = 1
                    *idMaps\cWarp = "-warp 1 6"
                    *idMaps\cLevel= "E1M6"                     
                    
                ElseIf *idLumps\E1M7 = 1
                    *idMaps\cWarp = "-warp 1 7"
                    *idMaps\cLevel= "E1M7"                                
                    
                ElseIf *idLumps\E1M8 = 1
                    *idMaps\cWarp = "-warp 1 8"
                    *idMaps\cLevel= "E1M8" 
                    
                ElseIf *idLumps\E1M9 = 1
                    *idMaps\cWarp = "-warp 1 9"
                    *idMaps\cLevel= "E1M9"                     
                    
                ElseIf *idLumps\E2M1 = 1
                    *idMaps\cWarp = "-warp 2 1"
                    *idMaps\cLevel= "E2M1"                     
                    
                ElseIf *idLumps\E2M2 = 1
                    *idMaps\cWarp = "-warp 2 2"
                    *idMaps\cLevel= "E2M2"                
                    
                ElseIf *idLumps\E2M3 = 1
                    *idMaps\cWarp = "-warp 2 3"
                    *idMaps\cLevel= "E2M3"                     
                    
                ElseIf *idLumps\E2M4 = 1
                    *idMaps\cWarp = "-warp 2 4"
                    *idMaps\cLevel= "E2M4"                     
                    
                ElseIf *idLumps\E2M5 = 1
                    *idMaps\cWarp = "-warp 2 2"
                    *idMaps\cLevel= "E2M5"                     
                    
                ElseIf *idLumps\E2M6 = 1
                    *idMaps\cWarp = "-warp 2 6"
                    *idMaps\cLevel= "E2M6"                     
                    
                ElseIf *idLumps\E2M7 = 1
                    *idMaps\cWarp = "-warp 2 7"
                    *idMaps\cLevel= "E2M7" 
                    
                ElseIf *idLumps\E2M8 = 1
                    *idMaps\cWarp = "-warp 2 8"
                    *idMaps\cLevel= "E2M8"                     
                                        
                ElseIf *idLumps\E2M9 = 1
                    *idMaps\cWarp = "-warp 2 9"
                    *idMaps\cLevel= "E2M9" 
                    
                ElseIf *idLumps\E3M1 = 1
                    *idMaps\cWarp = "-warp 3 1"
                    *idMaps\cLevel= "E3M1"                     
                    
                ElseIf *idLumps\E3M2 = 1
                    *idMaps\cWarp = "-warp 3 2"
                    *idMaps\cLevel= "E3M2"                
                    
                ElseIf *idLumps\E3M3 = 1
                    *idMaps\cWarp = "-warp 3 3"
                    *idMaps\cLevel= "E3M3"                     
                    
                ElseIf *idLumps\E3M4 = 1
                    *idMaps\cWarp = "-warp 3 4"
                    *idMaps\cLevel= "E3M4"                     
                    
                ElseIf *idLumps\E3M5 = 1
                    *idMaps\cWarp = "-warp 3 2"
                    *idMaps\cLevel= "E3M5"                     
                    
                ElseIf *idLumps\E3M6 = 1
                    *idMaps\cWarp = "-warp 3 6"
                    *idMaps\cLevel= "E3M6"                     
                    
                ElseIf *idLumps\E3M7 = 1
                    *idMaps\cWarp = "-warp 3 7"
                    *idMaps\cLevel= "E3M7" 
                                         
                ElseIf *idLumps\E3M8 = 1
                    *idMaps\cWarp = "-warp 3 8"
                    *idMaps\cLevel= "E3M8" 
                    
                ElseIf *idLumps\E3M9 = 1
                    *idMaps\cWarp = "-warp 3 9"
                    *idMaps\cLevel= "E3M9"                    
                    
                ElseIf *idLumps\E4M1 = 1
                    *idMaps\cWarp = "-warp 4 1"
                    *idMaps\cLevel= "E4M1"                     
                    
                ElseIf *idLumps\E4M2 = 1
                    *idMaps\cWarp = "-warp 4 2"
                    *idMaps\cLevel= "E4M2"                
                    
                ElseIf *idLumps\E4M3 = 1
                    *idMaps\cWarp = "-warp 4 3"
                    *idMaps\cLevel= "E4M3"                     
                    
                ElseIf *idLumps\E4M4 = 1
                    *idMaps\cWarp = "-warp 4 4"
                    *idMaps\cLevel= "E4M4"                     
                    
                ElseIf *idLumps\E4M5 = 1
                    *idMaps\cWarp = "-warp 4 2"
                    *idMaps\cLevel= "E4M5"                     
                    
                ElseIf *idLumps\E4M6 = 1
                    *idMaps\cWarp = "-warp 4 6"
                    *idMaps\cLevel= "E4M6"                     
                    
                ElseIf *idLumps\E4M7 = 1
                    *idMaps\cWarp = "-warp 4 7"
                    *idMaps\cLevel= "E4M7" 
                    
                ElseIf *idLumps\E4M8 = 1
                    *idMaps\cWarp = "-warp 4 8"
                    *idMaps\cLevel= "E4M8"                     
                                        
                ElseIf *idLumps\E4M9 = 1
                    *idMaps\cWarp = "-warp 4 9"
                    *idMaps\cLevel= "E4M9"
                    ;
                    ; Heretic
                    ;
                ElseIf *idLumps\E5M1 = 1
                    *idMaps\cWarp = "-warp 5 1"
                    *idMaps\cLevel= "E5M1"                     
                    
                ElseIf *idLumps\E5M2 = 1
                    *idMaps\cWarp = "-warp 5 2"
                    *idMaps\cLevel= "E5M2"                
                    
                ElseIf *idLumps\E5M3 = 1
                    *idMaps\cWarp = "-warp 5 3"
                    *idMaps\cLevel= "E5M3"                     
                    
                ElseIf *idLumps\E5M4 = 1
                    *idMaps\cWarp = "-warp 5 4"
                    *idMaps\cLevel= "E5M4"                     
                    
                ElseIf *idLumps\E5M5 = 1
                    *idMaps\cWarp = "-warp 5 2"
                    *idMaps\cLevel= "E5M5"                     
                    
                ElseIf *idLumps\E5M6 = 1
                    *idMaps\cWarp = "-warp 5 6"
                    *idMaps\cLevel= "E5M6"                     
                    
                ElseIf *idLumps\E5M7 = 1
                    *idMaps\cWarp = "-warp 5 7"
                    *idMaps\cLevel= "E5M7" 
                    
                ElseIf *idLumps\E5M8 = 1
                    *idMaps\cWarp = "-warp 5 8"
                    *idMaps\cLevel= "E4M8"                     
                                        
                ElseIf *idLumps\E5M9 = 1
                    *idMaps\cWarp = "-warp 5 9"
                    *idMaps\cLevel= "E5M9" 
                    
                ElseIf *idLumps\E6M1 = 1
                    *idMaps\cWarp = "-warp 6 1"
                    *idMaps\cLevel= "E5M1"                     
                    
                ElseIf *idLumps\E6M2 = 1
                    *idMaps\cWarp = "-warp 6 2"
                    *idMaps\cLevel= "E5M2"                
                    
                ElseIf *idLumps\E6M3 = 1
                    *idMaps\cWarp = "-warp 6 3"
                    *idMaps\cLevel= "E5M3"  
                    
                    ;
                    ; Doonm, Final Doom Etc...
                    ;
                ElseIf *idLumps\MAP01 = 1
                    *idMaps\cWarp = "-warp 01"
                    *idMaps\cLevel= "Map01"
                    
                ElseIf *idLumps\MAP02 = 1
                    *idMaps\cWarp = "-warp 02"
                    *idMaps\cLevel= "Map02"
                    
                ElseIf *idLumps\MAP03 = 1
                    *idMaps\cWarp = "-warp 03"
                    *idMaps\cLevel= "Map03"
                    
                ElseIf *idLumps\MAP04 = 1
                    *idMaps\cWarp = "-warp 04"
                    *idMaps\cLevel= "Map04"
                    
                ElseIf *idLumps\MAP05 = 1
                    *idMaps\cWarp = "-warp 05"
                    *idMaps\cLevel= "Map05"
                    
                ElseIf *idLumps\MAP06 = 1
                    *idMaps\cWarp = "-warp 06"
                    *idMaps\cLevel= "Map06"
                    
                ElseIf *idLumps\MAP07 = 1
                    *idMaps\cWarp = "-warp 07"
                    *idMaps\cLevel= "Map07"
                    
                ElseIf *idLumps\MAP08 = 1
                    *idMaps\cWarp = "-warp 08"
                    *idMaps\cLevel= "Map08"
                    
                ElseIf *idLumps\MAP09 = 1
                    *idMaps\cWarp = "-warp 09"
                    *idMaps\cLevel= "Map09"
                    
                ElseIf *idLumps\MAP10 = 1
                    *idMaps\cWarp = "-warp 10"
                    *idMaps\cLevel= "Map10"
                    
                ElseIf *idLumps\MAP11 = 1
                    *idMaps\cWarp = "-warp 11"
                    *idMaps\cLevel= "Map11"
                    
                ElseIf *idLumps\MAP12 = 1
                    *idMaps\cWarp = "-warp 12"
                    *idMaps\cLevel= "Map12"
                    
                ElseIf *idLumps\MAP13 = 1
                    *idMaps\cWarp = "-warp 13"
                    *idMaps\cLevel= "Map13"
                    
                ElseIf *idLumps\MAP14 = 1
                    *idMaps\cWarp = "-warp 14"
                    *idMaps\cLevel= "Map14"
                    
                ElseIf *idLumps\MAP15 = 1
                    *idMaps\cWarp = "-warp 15"
                    *idMaps\cLevel= "Map15"
                    
                ElseIf *idLumps\MAP16 = 1
                    *idMaps\cWarp = "-warp 16"
                    *idMaps\cLevel= "Map16"
                    
                ElseIf *idLumps\MAP17 = 1
                    *idMaps\cWarp = "-warp 17"
                    *idMaps\cLevel= "Map17"
                    
                ElseIf *idLumps\MAP18 = 1
                    *idMaps\cWarp = "-warp 18"
                    *idMaps\cLevel= "Map18"
                    
                ElseIf *idLumps\MAP19 = 1
                    *idMaps\cWarp = "-warp 19"
                    *idMaps\cLevel= "Map19"
                    
                ElseIf *idLumps\MAP20 = 1
                    *idMaps\cWarp = "-warp 20"
                    *idMaps\cLevel= "Map20"
                    
                ElseIf *idLumps\MAP21 = 1
                    *idMaps\cWarp = "-warp 21"
                    *idMaps\cLevel= "Map21"
                    
                ElseIf *idLumps\MAP22 = 1
                    *idMaps\cWarp = "-warp 22"
                    *idMaps\cLevel= "Map22"
                    
                ElseIf *idLumps\MAP23 = 1
                    *idMaps\cWarp = "-warp 23"
                    *idMaps\cLevel= "Map23"
                    
                ElseIf *idLumps\MAP24 = 1
                    *idMaps\cWarp = "-warp 24"
                    *idMaps\cLevel= "Map24"
                    
                ElseIf *idLumps\MAP25 = 1
                    *idMaps\cWarp = "-warp 25"
                    *idMaps\cLevel= "Map25"
                    
                ElseIf *idLumps\MAP26 = 1
                    *idMaps\cWarp = "-warp 26"
                    *idMaps\cLevel= "Map26"
                    
                ElseIf *idLumps\MAP27 = 1
                    *idMaps\cWarp = "-warp 27"
                    *idMaps\cLevel= "Map27"
                    
                ElseIf *idLumps\MAP28 = 1
                    *idMaps\cWarp = "-warp 28"
                    *idMaps\cLevel= "Map28"
                    
                ElseIf *idLumps\MAP29 = 1
                    *idMaps\cWarp = "-warp 29"
                    *idMaps\cLevel= "Map29"
                    
                ElseIf *idLumps\MAP30 = 1
                    *idMaps\cWarp = "-warp 30"
                    *idMaps\cLevel= "Map30"                    
                    
                ElseIf *idLumps\MAP31 = 1
                    *idMaps\cWarp = "-warp 31"
                    *idMaps\cLevel= "Map31"                    
                    
                ElseIf *idLumps\MAP32 = 1
                    *idMaps\cWarp = "-warp 32"
                    *idMaps\cLevel= "Map32"                                    
                ;
                ; Hexen
                ElseIf *idLumps\MAP33 = 1
                    *idMaps\cWarp = "-warp 33"
                    *idMaps\cLevel= "Map33"                                   
                
                ElseIf *idLumps\MAP34 = 1
                    *idMaps\cWarp = "-warp 34"
                    *idMaps\cLevel= "Map34"                    

                ElseIf *idLumps\MAP35 = 1
                    *idMaps\cWarp = "-warp 35"
                    *idMaps\cLevel= "Map35"                    

                ElseIf *idLumps\MAP36 = 1
                    *idMaps\cWarp = "-warp 36"
                    *idMaps\cLevel= "Map36"                    

                ElseIf *idLumps\MAP37 = 1
                    *idMaps\cWarp = "-warp 37"
                    *idMaps\cLevel= "Map37"                    

                ElseIf *idLumps\MAP38 = 1
                    *idMaps\cWarp = "-warp 38"
                    *idMaps\cLevel= "Map38"                    

                ElseIf *idLumps\MAP39 = 1
                    *idMaps\cWarp = "-warp 39"
                    *idMaps\cLevel= "Map39"                    

                ElseIf *idLumps\MAP40 = 1
                    *idMaps\cWarp = "-warp 40"
                    *idMaps\cLevel= "Map40"                    

                ElseIf *idLumps\MAP41 = 1
                    *idMaps\cWarp = "-warp 41"
                    *idMaps\cLevel= "Map41"   
                    
                    ;
                    ; Hexen: Addon
                ElseIf *idLumps\MAP42 = 1
                    *idMaps\cWarp = "-warp 42"
                    *idMaps\cLevel= "Map42"
                    
                ElseIf *idLumps\MAP43 = 1
                    *idMaps\cWarp = "-warp 43"
                    *idMaps\cLevel= "Map43"
                    
                ElseIf *idLumps\MAP44 = 1
                    *idMaps\cWarp = "-warp 44"
                    *idMaps\cLevel= "Map44"
                    
                ElseIf *idLumps\MAP45 = 1
                    *idMaps\cWarp = "-warp 45"
                    *idMaps\cLevel= "Map45"
                    
                ElseIf *idLumps\MAP46 = 1
                    *idMaps\cWarp = "-warp 46"
                    *idMaps\cLevel= "Map46"
                    
                ElseIf *idLumps\MAP47 = 1
                    *idMaps\cWarp = "-warp 47"
                    *idMaps\cLevel= "Map47"
                    
                ElseIf *idLumps\MAP48 = 1
                    *idMaps\cWarp = "-warp 48"
                    *idMaps\cLevel= "Map48"
                    
                ElseIf *idLumps\MAP49 = 1
                    *idMaps\cWarp = "-warp 49"
                    *idMaps\cLevel= "Map49"
                    
                ElseIf *idLumps\MAP50 = 1
                    *idMaps\cWarp = "-warp 50"
                    *idMaps\cLevel= "Map50"
                    
                ElseIf *idLumps\MAP51 = 1
                    *idMaps\cWarp = "-warp 51"
                    *idMaps\cLevel= "Map51"
                    
                ElseIf *idLumps\MAP52 = 1
                    *idMaps\cWarp = "-warp 52"
                    *idMaps\cLevel= "Map52"
                    
                ElseIf *idLumps\MAP53 = 1
                    *idMaps\cWarp = "-warp 53"
                    *idMaps\cLevel= "Map53"
                    
                ElseIf *idLumps\MAP54 = 1
                    *idMaps\cWarp = "-warp 54"
                    *idMaps\cLevel= "Map54"
                    
                ElseIf *idLumps\MAP55 = 1
                    *idMaps\cWarp = "-warp 55"
                    *idMaps\cLevel= "Map55"
                    
                ElseIf *idLumps\MAP56 = 1
                    *idMaps\cWarp = "-warp 56"
                    *idMaps\cLevel= "Map56"
                    
                ElseIf *idLumps\MAP57 = 1
                    *idMaps\cWarp = "-warp 57"
                    *idMaps\cLevel= "Map57"
                    
                ElseIf *idLumps\MAP58 = 1
                    *idMaps\cWarp = "-warp 58"
                    *idMaps\cLevel= "Map58"
                    
                ElseIf *idLumps\MAP59 = 1
                    *idMaps\cWarp = "-warp 59"
                    *idMaps\cLevel= "Map59"                    
                    
                EndIf                 
                ;
                ;
                ; Get MegaWads
                *idLumps\Episode1 = *idLumps\E1M1 + *idLumps\E1M2 + *idLumps\E1M3 + *idLumps\E1M4 + *idLumps\E1M5 + *idLumps\E1M6 + *idLumps\E1M7 + *idLumps\E1M8 + *idLumps\E1M9
                *idLumps\Episode2 = *idLumps\E2M1 + *idLumps\E2M2 + *idLumps\E2M3 + *idLumps\E2M4 + *idLumps\E2M5 + *idLumps\E2M6 + *idLumps\E2M7 + *idLumps\E2M8 + *idLumps\E2M9                
                *idLumps\Episode3 = *idLumps\E3M1 + *idLumps\E3M2 + *idLumps\E3M3 + *idLumps\E3M4 + *idLumps\E3M5 + *idLumps\E3M6 + *idLumps\E3M7 + *idLumps\E3M8 + *idLumps\E3M9                 
                *idLumps\Episode4 = *idLumps\E4M1 + *idLumps\E4M2 + *idLumps\E4M3 + *idLumps\E4M4 + *idLumps\E4M5 + *idLumps\E4M6 + *idLumps\E4M7 + *idLumps\E4M8 + *idLumps\E4M9 
                *idLumps\Episode5 = *idLumps\E5M1 + *idLumps\E5M2 + *idLumps\E5M3 + *idLumps\E5M4 + *idLumps\E5M5 + *idLumps\E5M6 + *idLumps\E5M7 + *idLumps\E5M8 + *idLumps\E5M9 
                *idLumps\Episode6 = *idLumps\E6M1 + *idLumps\E6M2 + *idLumps\E6M3
                
                *idLumps\Megawad32= *idLumps\MAP01 + *idLumps\MAP02 + *idLumps\MAP03 + *idLumps\MAP04 + *idLumps\MAP05 + *idLumps\MAP06 + *idLumps\MAP07 + *idLumps\MAP08 + *idLumps\MAP09 + *idLumps\MAP10 +
                                    *idLumps\MAP11 + *idLumps\MAP12 + *idLumps\MAP13 + *idLumps\MAP14 + *idLumps\MAP15 + *idLumps\MAP16 + *idLumps\MAP17 + *idLumps\MAP18 + *idLumps\MAP19 + *idLumps\MAP20 +
                                    *idLumps\MAP21 + *idLumps\MAP22 + *idLumps\MAP23 + *idLumps\MAP24 + *idLumps\MAP25 + *idLumps\MAP26 + *idLumps\MAP27 + *idLumps\MAP28 + *idLumps\MAP29 + *idLumps\MAP30 +
                                    *idLumps\MAP31 + *idLumps\MAP32 + *idLumps\MAP33 + *idLumps\MAP34 + *idLumps\MAP35 + *idLumps\MAP36 + *idLumps\MAP37 + *idLumps\MAP38 + *idLumps\MAP39 + *idLumps\MAP40 +
                                    *idLumps\MAP41 + *idLumps\MAP42 + *idLumps\MAP43 + *idLumps\MAP44 + *idLumps\MAP45 + *idLumps\MAP46 + *idLumps\MAP47 + *idLumps\MAP48 + *idLumps\MAP49 + *idLumps\MAP50 +
                                    *idLumps\MAP51 + *idLumps\MAP52 + *idLumps\MAP53 + *idLumps\MAP54 + *idLumps\MAP55 + *idLumps\MAP56 + *idLumps\MAP57 + *idLumps\MAP58 + *idLumps\MAP59
                Debug ""
                Debug "*idLumps\Episode1 : "+ Str(*idLumps\Episode1)
                Debug "*idLumps\Episode2 : "+ Str(*idLumps\Episode2)                
                Debug "*idLumps\Episode3 : "+ Str(*idLumps\Episode3)                
                Debug "*idLumps\Episode4 : "+ Str(*idLumps\Episode4)                
                Debug "*idLumps\Megawad32: "+ Str(*idLumps\Megawad32)                
                ;
                ;
                ; Doom 1 MegaWad
                
                If (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 48
                    *idMaps\cMegaWad = 48
                    *idMaps\cMegaDes = "Megawad (6 Episodes)" 
                    
                ElseIf (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4 + *idLumps\Episode5) = 45
                    *idMaps\cMegaWad = 45
                    *idMaps\cMegaDes = "Megawad (5 Episodes)" 
                    
                ElseIf (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4) = 36
                    *idMaps\cMegaWad = 36
                    *idMaps\cMegaDes = "Megawad (4 Episodes)" 
                    
                ElseIf (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3) = 27 And (*idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 27
                    *idMaps\cMegaDes = "Megawad (3 Episodes)"
                    
                ElseIf *idLumps\Episode1 + *idLumps\Episode2 = 18 And (*idLumps\Episode3 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP1 and EP2)"  
                    
                ElseIf *idLumps\Episode1 + *idLumps\Episode3 = 18 And (*idLumps\Episode2 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP1 and EP3)"                      
                    
                ElseIf *idLumps\Episode1 + *idLumps\Episode4 = 18 And (*idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP1 and EP4)"                      
                    
                ElseIf *idLumps\Episode2 + *idLumps\Episode3 = 18 And (*idLumps\Episode1 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP2 and EP3)"                      
                    
                ElseIf *idLumps\Episode2 + *idLumps\Episode4 = 18 And (*idLumps\Episode1 + *idLumps\Episode3 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP2 and EP4)"                      
                    
                ElseIf *idLumps\Episode3 + *idLumps\Episode4 = 18 And (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP3 and EP4)"  
                    
                ElseIf *idLumps\Episode1 + *idLumps\Episode5 = 18 And (*idLumps\Episode3 + *idLumps\Episode2 + *idLumps\Episode4 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP1 and EP5)" 
                    
                ElseIf *idLumps\Episode2 + *idLumps\Episode5 = 18 And (*idLumps\Episode3 + *idLumps\Episode1 + *idLumps\Episode4 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP2 and EP5)" 
                    
                ElseIf *idLumps\Episode3 + *idLumps\Episode5 = 18 And (*idLumps\Episode3 + *idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP3 and EP5)" 
                    
                ElseIf *idLumps\Episode4 + *idLumps\Episode5 = 18 And (*idLumps\Episode3 + *idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3) = 0
                    *idMaps\cMegaWad = 18
                    *idMaps\cMegaDes = "Megawad (EP4 and EP5)"                                       
                    
                ElseIf *idLumps\Episode1 = 9 And (*idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 9
                    *idMaps\cMegaDes = "Episodic 1 Replacement"                      
                    
                ElseIf *idLumps\Episode2 = 9 And (*idLumps\Episode1 + *idLumps\Episode3 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 9
                    *idMaps\cMegaDes = "Episodic 2 Replacement"         
                    
                ElseIf *idLumps\Episode3 = 9 And (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode4 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 9
                    *idMaps\cMegaDes = "Episodic 3 Replacement"                      
                    
                ElseIf *idLumps\Episode4 = 9 And (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode5 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 9
                    *idMaps\cMegaDes = "Episodic 4 Replacement"
                    
                ElseIf *idLumps\Episode5 = 9 And (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4 + *idLumps\Episode6) = 0
                    *idMaps\cMegaWad = 9
                    *idMaps\cMegaDes = "Episodic 5 Replacement"                       
                    
                ElseIf *idLumps\Episode6 = 3 And (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode5 + *idLumps\Episode4) = 0
                    *idMaps\cMegaWad = 9
                    *idMaps\cMegaDes = "Episodic 4 Replacement"                       
                    
                    
                ElseIf *idLumps\Megawad32 = 32
                    *idMaps\cMegaWad = 32
                    *idMaps\cMegaDes = "Megawad (32 Levels)"
                    
                ElseIf *idLumps\Megawad32 = 41
                    *idMaps\cMegaWad = 41
                    *idMaps\cMegaDes = "Total Megawad (41 Levels)"  ; ???                  
                    
                ElseIf *idLumps\Megawad32 = 59
                    *idMaps\cMegaWad = 59
                    *idMaps\cMegaDes = "Ultra Megawad (59 Levels)"  ; Hehe, not seen
                    
                Else
                    
                    If (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4) <> 0
                        *idMaps\cMegaWad = *idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4
                        *idMaps\cMegaDes = Chr(10) + " " +*idLumps\LumpLvl.s
                        
                    ElseIf *idLumps\Megawad32 <> 0
                        *idMaps\cMegaWad = *idLumps\Megawad32
                        *idMaps\cMegaDes = Chr(10) + " " +*idLumps\LumpLvl.s
                        
                    ElseIf (*idLumps\Episode1 + *idLumps\Episode2 + *idLumps\Episode3 + *idLumps\Episode4) = 0 And *idLumps\Megawad32 = 0
                        *idMaps\cLevel   = "No Map"
                        *idMaps\cMegaWad = 0
                        *idMaps\cMegaDes = "No Levels"+ Chr(10) + "Lump Index:" + *idMaps\LumpNames.s
                    EndIf  
                EndIf    
            Default
                *idMaps\cWarp = ""
                *idMaps\cLevel= ""                
                Debug "Unknown Wad Header: " + UCase(*idMaps\cWadId)                
        EndSelect        
        
    EndProcedure
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : WadData_Info
    ; '  DESCRIPTION  : Set Level Info Description
    ; 
    Procedure WadData_Info(Mode = 0,Filename$ = "", *WadFile = 0, InZipFile$ = "", MapInfoText$ = "")
        
        Protected InfoLine$
        
         *idMaps\cInfoLine = ""
        Select Mode
                Case 0 ; Fom File
                    InfoLine$ =  "File  : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + #CR$ +
                                 "Size  : " + FFH::ConvertHDSize(FileSize(Path$ + Filename$)) + #CR$ +
                                 "Wad ID: " + idTech1_WFM::*idMaps\cWadId + #CR$ +  #CR$ +                                                                 
                                 "WadFile Info" + #CR$ +
                                 "Lumps        : " + idTech1_WFM::*idMaps\cWadLumps + #CR$ +                                
                                 "Start Level  : " + idTech1_WFM::*idMaps\cLevel + #CR$ +
                                 "Level's        : " + idTech1_WFM::*idMaps\cMegaWad + #CR$ +
                                 "Level Names: " + idTech1_WFM::*idMaps\cMegaDes
                    
;                     If idTech1_WFM::*idMaps\cWadId = "IWAD"
;                        InfoLine$ + #CR$ + "IWad Hash SH1 : " + SHA1FileFingerprint(Path$ + Filename$)
;                     EndIf
                   
                    Debug "Entry Offset: " + "$" + idTech1_WFM::*idMaps\cWadDirOffset + " >Hex: " + RSet(Hex(idTech1_WFM::*idMaps\cWadDirOffset),8,"0")
                Case 1
                    
                    InfoLine$ =  "File  : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + InZipFile$ + #CR$ +
                                 "Size  : " + FFH::ConvertHDSize(MemorySize(*WadFile)) + #CR$ +
                                 "Wad ID: " + idTech1_WFM::*idMaps\cWadId + #CR$ +  #CR$ +                                                                 
                                 "WadFile Info" + #CR$ +
                                 "Lumps        : " + idTech1_WFM::*idMaps\cWadLumps + #CR$ +  
                                 "Start Level  : " + idTech1_WFM::*idMaps\cLevel + #CR$ +
                                 "Level's        : " + idTech1_WFM::*idMaps\cMegaWad + #CR$ +
                                 "Level Names: " + idTech1_WFM::*idMaps\cMegaDes
                                 Debug "Entry Offset: " + "$"  + RSet(Hex(idTech1_WFM::*idMaps\cWadDirOffset),8,"0")
                    
                Case 3
                    
                    InfoLine$ =  "File  : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + InZipFile$ + #CR$ + #CR$ +
                                 "No Wad Files Found" + #CR$ +
                                 UCase(GetExtensionPart(Filename$)) + " Archiv Content :" + Mid(MapInfoText$,2,Len(MapInfoText$))
                    
                Case 4
                    
                    InfoLine$ =  "File  : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + InZipFile$ + #CR$ +
                                 "Size  : " + 0 + #CR$ +
                                 "Wad ID: Nothing Found" + #CR$ +  #CR$ +                                                                 
                                 "Error : Loading from Zip File (Size is null)"                   
                    
                Case 5
                    
                    InfoLine$ =  "Selected MAPINO" + #CR$ +
                                 "File   : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + InZipFile$ + #CR$ + #CR$ +
                                 "MAPINFO: " +  #CR$ +   MapInfoText$
                    
                Case 6
                    
                    InfoLine$ =  "File   : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + InZipFile$ + #CR$ + #CR$ +                                                             
                                 "Warning: Archiv Size too big " + FFH::ConvertHDSize(FileSize(Filename$))
                    
                Case 7                    
                    InfoLine$ =  "File  : " + GetFilePart(Filename$,#PB_FileSystem_NoExtension) + #CR$ +
                                 "Size  : " + FFH::ConvertHDSize(FileSize(Path$ + Filename$)) 
                                 
            EndSelect     

            *idMaps\cInfoLine = InfoLine$
      EndProcedure  
      
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : WadData_Info
    ; '  DESCRIPTION  : Set Level Info Description
    ; 
    Procedure WadData_MapInfo(*MapInfo,File$)  
        Protected MapInfoText$, MaxCrLF.i, Episode$, Currentline$, PositionE.i, PositionM.i, MapInfoLine$
        
        ;ShowMemoryViewer(*MapInfo, MemorySize(*MapInfo)) 
        
        MapInfoText$ = PeekS(*MapInfo,MemorySize(*MapInfo),#PB_UTF8)
                         
        MaxCrLF = CountString(MapInfoText$,#CRLF$)
        For Index = 1 To MaxCrLF
            
            Currentline$ = StringField(MapInfoText$,Index,#CRLF$)
            
            PositionE = FindString(Currentline$,"episode",1)
            If (PositionE <> 0)
                Episode$ = StringField(MapInfoText$,Index+1,#CRLF$)
                Episode$ = Mid(Episode$,5,Len(Episode$))
                Episode$ = Trim(Episode$)
            EndIf
            
            PositionM = FindString(Currentline$,"map ",1)            
            If (PositionM <> 0)
                Currentline$ = Mid(Currentline$,4,Len(Currentline$))
                MapInfoLine$ = MapInfoLine$ + Chr(10) + Currentline$
                MapInfoLine$ = Trim(MapInfoLine$)
            EndIf                                
        Next                                 
        
        If MemorySize(*MapInfo)  >= 1: FreeMemory(*MapInfo): EndIf 
        
        If Len(Episode$) = 0
            ;
            ; No Episode Text Found
            Episode$ = "'\Mapinfo' Contains No Episode"
        EndIf    
        
        If Len(MapInfoLine$) = 0
            ;
            ; No Episode Text Found
            MapInfoLine$ = "'\Mapinfo' Contains Maps"
        EndIf 
        
        MapInfoText$ = "Episode: " + Episode$ + #CRLF$ + "Maps:" + MapInfoLine$
        
        ;Debug MapInfoText$
        WadData_Info(5,File$, 0,"", MapInfoText$)
    EndProcedure      
    ;***************************************************************************************************
    ;     
    ; ' --------------------------------------------------------------------------------
    ; '  FUNCTION     : Get Info from Zipped Archiv, Need PB ArcZip Module
    ; '  DESCRIPTION  : Set Level Info Description
    ; 
    Procedure WadOpen_Zipped(File$)
        
        Protected FilesCount.i, ZipIndex.i, CurrentFile$, Extension$, *Memory, WhereAllTheData$
                
        *idMaps\cWadId.s       = ""
        *idMaps\cWadLumps.l    = -1
        *idMaps\cWadDirOffset.l= -1
        *idMaps\cWarp.s        = ""
        *idMaps\cLevel.s       = ""
        *idMaps\cMegaWad.i     = -1
        *idMaps\cMegaDes.s     = ""
        *idMaps\cInfoLine.s    = ""
        *idMaps\cArchivCount.i = -1
        *idMaps\cArchivFiles.s = ""
        *idLumps\LumpLvl.s     = ""
        *idMaps\LumpNames      = ""
        DemoFileCount          = -1
        ResetLumpStruct()
        
        
        For ZipIndex = 0 To 999
            *idMaps\cArchivIndex[ZipIndex] = -1
        Next    
        
        ;
        ; Dont' load Big Files in Memory        
        If FileSize(File$) >= 206235208
            WadData_Info(6,File$, 0, "", ""): ProcedureReturn
        EndIf    
            
        If CLZIP::IsZipArchive(File$) = 0
            
            FilesCount.i = CLZIP::GetFilesCount(File$)
            ;
            ;
            ; Reduce Loading Time, Break at 999 Entrys
            If FilesCount => 999
                FilesCount = 999
            EndIf
            
            Debug "WadOpen_Zipped()\FilesCount.i" + Str(FilesCount)
            For ZipIndex = 0 To FilesCount
                
                
                CurrentFile$ = CLZIP::GetFileInfo(File$, ZipIndex)
                
                ;
                ; zDoom MapInfo (Zip, Pk3)
                If UCase(CurrentFile$) = "MAPINFO"
                    
                    *Memory = CLZIP::CatchFile(File$, ZipIndex, 0)
                    If *Memory = 0
                        WadData_Info(4,File$)
                    Else                                
                        WadData_MapInfo(*Memory, File$)
                        ProcedureReturn                                                
                    EndIf
                    
                Else                        
                    
                    Extension$ = GetExtensionPart(CurrentFile$)
                    Select LCase(Extension$)                            
                        Case "lmp"
                            ;
                            ; Count Demo Files (-playdemo)
                            ; DemoFileCount = DemoFileCount + 1
                            ;
                            ; No Source Port can handle packed default Doom demofiles
                    EndSelect        
                    
                    If ZipIndex >= 25
                        Break
                    EndIf                                                        
                    *idMaps\cArchivIndex[ZipIndex] = ZipIndex
                    *idMaps\cArchivCount    = *idMaps\cArchivCount + 1                       
                EndIf    
            Next
            
            CurrentFile$ = ""
            If *idMaps\cArchivCount  >= 0
                
                If *idMaps\cArchivCount = 0
                    For ZipIndex = 0 To 999  
                        IndexFile.i = *idMaps\cArchivIndex[ZipIndex]
                        If IndexFile <> -1
                            Break
                        EndIf    
                    Next
                    *Memory = CLZIP::CatchFile(File$, IndexFile, 0)
                    If *Memory = 0
                        WadData_Info(4,File$)
                    Else        
                        WadOpen_Memory(*Memory)
                        WadData_Levels()  
                        WadData_Info(1, File$, *Memory)  ; ShowMemoryViewer(*Memory, MemorySize(*Memory)) 
                        If MemorySize(*Memory)  >= 1: FreeMemory(*Memory): EndIf 
                    EndIf
                    
                Else    
                
                    For ZipIndex = 0 To 999                                                                                
                        IndexFile.i = *idMaps\cArchivIndex[ZipIndex]
                        If (IndexFile <> -1)
                            
                            WhereAllTheData$ = CLZIP::GetFileInfo(File$, IndexFile)
                            
                            Extension$ = GetExtensionPart(WhereAllTheData$)
                            Select LCase(Extension$)                            
                                Case "wad"
                                    
                                    CurrentFile$ = CurrentFile$ + Chr(10) + #TAB$ + GetFilePart(File$,#PB_FileSystem_NoExtension) + "\" + WhereAllTheData$
                                    
                                    If *idMaps\cMegaWad = -1
                                        *Memory  = CLZIP::CatchFile(File$, IndexFile, 0)  
                                        If *Memory = 0
                                            WadData_Info(4,File$)
                                        Else                                   
                                            WadFile$ = CLZIP::GetFileInfo(File$, IndexFile)
                                            WadOpen_Memory(*Memory)
                                            WadData_Levels()
                                            WadData_Info(1, File$, *Memory,  "\" + WadFile$)
                                            ;
                                            ;
                                            ; More Wads in the Archiv, Search for the Level
                                            If (*idMaps\cMegaWad = 0) And (*idMaps\cArchivCount <> ZipIndex)
                                                *idMaps\cMegaWad = -1
                                            EndIf                                                                                                                                                          
                                            If MemorySize(*Memory)  >= 1
                                                FreeMemory(*Memory)
                                            EndIf 
                                        EndIf    
                                    EndIf
                                Default
                                     If (ZipIndex >= 1)
                                         NonWad$ = NonWad$ + Chr(10) + #TAB$ + GetFilePart(File$,#PB_FileSystem_NoExtension) + "\" + WhereAllTheData$
                                     EndIf    
                             EndSelect   
                            
                        EndIf    
                    Next  
                    If Len(Trim(CurrentFile$)) <> 0
                        *idMaps\cArchivFiles.s  = #CR$ + #CR$ + "WadFiles In the Archiv: " + CurrentFile$
                        
;                         If Len(Trim(NonWad$)) <> 0 
;                             *idMaps\cArchivFiles.s  = *idMaps\cArchivFiles.s + #CR$ + #CR$ + "Files In the Archiv: "  + NonWad$ 
;                         EndIf
                        
                    Else    
                        If Len(Trim(NonWad$)) = 0 
                            WadData_Info(7,File$)
                            NonWad$ = #CR$ + Chr(10) + #TAB$ + "Archiv is Empty ?"
                        Else    
                            WadData_Info(7,File$)
                           *idMaps\cArchivFiles.s  = #CR$ + #CR$ + "Files In the Archiv: " + NonWad$ 
                       EndIf     
                    EndIf    
                    *idMaps\cInfoLine = *idMaps\cInfoLine  + *idMaps\cArchivFiles
                        
                EndIf                               
            Else
                
                If CLZIP::IsZipArchive(File$) = 0
                    
                    FilesCount.i = CLZIP::GetFilesCount(File$)
                    
                    For ZipIndex = 0 To FilesCount                
                        CurrentFile$ = CurrentFile$ + Chr(10) + CLZIP::GetFileInfo(File$, ZipIndex)
                        If (ZipIndex = 25)
                            CurrentFile$ = CurrentFile$ + Chr(10) + "........"
                            Break;
                        EndIf    
                    Next    
                EndIf       
                
                WadData_Info(3,File$, 0,"", CurrentFile$)
            EndIf
         EndIf   
    EndProcedure      
EndModule


CompilerIf #PB_Compiler_IsMainFile
    Enumeration
        #TESTFILE  
    EndEnumeration
    
    
    File$ = OpenFileRequester("Wad","","*.*",0,0)
    If File$
        
        
        Extension$ = GetExtensionPart(File$)
        Select LCase(Extension$)
            Case "zip", "pk3" ;Zipped
               idTech1_WFM::WadOpen_Zipped(File$)
  
            Case "pk7"                  ; Seven Zip
            Case "wad"  
                idTech1_WFM::WadOpen(#TESTFILE, File$)
                idTech1_WFM::GetLump(#TESTFILE, File$)
                idTech1_WFM::WadData_Levels()
                idTech1_WFM::WadData_Info(0, File$)
        EndSelect                     
        
        
;         Debug ""    
;         Debug "---------------------------------------------------------"
;         Debug "File  : " + File$
;         Debug "Wad ID: " + idTech1_WFM::*idMaps\cWadId
;         Debug "Lumps : " + idTech1_WFM::*idMaps\cWadLumps
;         Debug "Offset: " + "$" + idTech1_WFM::*idMaps\cWadDirOffset + " >Hex: " + RSet(Hex(idTech1_WFM::*idMaps\cWadDirOffset),8,"0")
;         Debug ""
;         Debug "Start Level: " + idTech1_WFM::*idMaps\cLevel
;         Debug "Warp  Level: " + idTech1_WFM::*idMaps\cWarp
;         Debug "Level's    : " + idTech1_WFM::*idMaps\cMegaWad
;         Debug "Level Names: " + idTech1_WFM::*idMaps\cMegaDes
;         Debug "---------------------------------------------------------"
        
        
        Debug idTech1_WFM::*idMaps\cInfoLine
    EndIf
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1968
; FirstLine = 1559
; Folding = -9-
; EnableAsm
; EnableXP
; UseMainFile = ..\LHid.pb
; EnableUnicode