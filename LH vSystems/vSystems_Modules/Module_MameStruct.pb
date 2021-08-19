DeclareModule MameStruct
    
    
    ;***************************************************************************************************
    ;        
    ; Structure für die INI oder DB    
    Structure STRUCT_MAME
        RootPath.s{1024}        ; Standard Mame RootPath
        NonUI.s
        Mame_ini.s{1024}        ; The Mame.ini (default ..\..\ini\)
        Mame_iui.s              ; The ui.ini (default ..\..\ini)
        DebugLogFile.s{1024}    ; Deug Log file for the Programm
        DebugMode.i             ; Setzt den Debug Modus
        Title.s{50}             ; Gui Title
        Version.s{4}            ; Gui Version
        IncQuotes.i             ; Beinhaltet AnführungsZeichen "roms;roms ..."
        cspo_rompath.s{4096}    ; > INI: Core Search Options Path = rompath
        Line_rompath.l          ; > INI: Core Search Options Path = rompath LineNumber
        Line_titles.l           ; > INI: Title Path Zeilennumber
        Line_snapss.l           ; > INI: Snaps Path Zeilennumber
        LastDirectory.s         ; Remember Last Directory
        InputSelect.i           ; Eingabe Selection in den String
        PictureMode.i           ; Bild Modus, 0 zeigt den Titel, 1 das Snap
        PIMGX.i                 ; Bild Position X
        PIMGY.i                 ; Bild Position Y
        PIMGW.i                 ; Bild Weite
        PIMGH.i                 ; Bild Höhe
        BColr.l                 ; Bild Hintergrund Farbe
        Picture_Rom.s           ; Bild Name des Roms
        Picture_Alpha.i         ; 178
        LastMessDirectory.s     ; Remember Last Directory
        JumptoAfterMame.i
        Prefs.s
        CHDOutput.i             ; Output for chadman, 1 = Default CMD, 0 to console
        FirstStart.i   
        
    EndStructure   
   
    Global *mameExt.STRUCT_MAME       = AllocateMemory(SizeOf(STRUCT_MAME))    
    
        
    ;***************************************************************************************************
    ;        
    ; Structure für die INI oder DB  
    Structure STRUCT_MESSAGETIMER
        ObjStringID.i
        Text.s{1024}
        Rext.s{1024}
        DebugInfo.i
        ColorF1.l
        ColorF2.l
    EndStructure   
    Global *idMsg.STRUCT_MESSAGETIMER       = AllocateMemory(SizeOf(STRUCT_MESSAGETIMER))  
      
    
    ;***************************************************************************************************
    ;        
    ; Structure für die Mame INI CORE SEARCH PATH OPTIONS/ CORE OUTPUT DIRECTORY OPTIONS
    Structure STRUCT_COREPATHS_ROM
        INDEX.i
        ROMPATH.s        
    EndStructure   
   
    Global NewList CorePaths_Roms.STRUCT_COREPATHS_ROM()  
 
    Structure STRUCT_COREPATHS_TITLES
        INDEX.i
        ROMPATH.s        
    EndStructure   
   
    Global NewList CorePaths_Titles.STRUCT_COREPATHS_TITLES()     
    
    Structure STRUCT_COREPATHS_SNAPS
        INDEX.i
        ROMPATH.s        
    EndStructure   
   
    Global NewList CorePaths_Snaps.STRUCT_COREPATHS_SNAPS()
    
    
    Structure STRUCT_LETTER_CASE
        INDEX.i
        Case__Up.s
        CaseDown.s
    EndStructure   
   
    Global NewList LetterCase.STRUCT_LETTER_CASE()  
    
    Structure STRUCT_MESS_DEVICES
            INPUTG_ID.i
            GADGET_ID.i
            MENUID.l          
            MOUNTED_A.s
            MOUNTED_B.s
            MOUNTED_C.s
            MOUNTED_D.s
            MOUNTED_E.s
            MOUNTED_F.s 
            MOUNTED_A_TITLE.s
            MOUNTED_B_TITLE.s
            MOUNTED_C_TITLE.s
            MOUNTED_D_TITLE.s
            MOUNTED_E_TITLE.s
            MOUNTED_F_TITLE.s             
            ;FullPath_Slot_A.s
            FullPath_Slot_B.s
            FullPath_Slot_C.s
            FullPath_Slot_D.s
            FullPath_Slot_E.s
            FullPath_Slot_F.s   
            NameOnly_Slot_A.s
            NameOnly_Slot_B.s
            NameOnly_Slot_C.s
            NameOnly_Slot_D.s
            NameOnly_Slot_E.s
            NameOnly_Slot_F.s             
            HoldMM002_ID.i
            HoldMM003_ID.i            
            HoldMM004_ID.i            
            HoldMM005_ID.i            
            HoldMM006_ID.i            
            HoldMM007_ID.i            
    EndStructure   
   
    Global *Devs.STRUCT_MESS_DEVICES = AllocateMemory(SizeOf(STRUCT_MESS_DEVICES)) 
    
    Global *Timer = AllocateMemory(255)
    Global TimerThread.l = 0    
    ;***************************************************************************************************
    ;     
    Declare SetDebugLog(LogMessageText$ = "", LogMode = 0)    
    Declare MessageInfo(ObjStringID.i = 0, MessageText$ = "",Timeout = 20, Kill.i = 0, ShowDbgInfo = 0, ResetMsg$ = "", PrimaryCol.l = 0, ResetCol.l = 0)
    
    Declare Read_Config()
    
EndDeclareModule    

Module MameStruct
    
   
    Mame$ = ""

    
    AddElement(LetterCase()): LetterCase()\Case__Up = "A" : LetterCase()\CaseDown = "a": LetterCase()\INDEX = 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "B" : LetterCase()\CaseDown = "b": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "C" : LetterCase()\CaseDown = "c": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "D" : LetterCase()\CaseDown = "d": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "E" : LetterCase()\CaseDown = "e": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "F" : LetterCase()\CaseDown = "f": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "G" : LetterCase()\CaseDown = "g": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "H" : LetterCase()\CaseDown = "h": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "I" : LetterCase()\CaseDown = "i": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "J" : LetterCase()\CaseDown = "j": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "K" : LetterCase()\CaseDown = "k": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "L" : LetterCase()\CaseDown = "l": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "M" : LetterCase()\CaseDown = "m": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "N" : LetterCase()\CaseDown = "n": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "O" : LetterCase()\CaseDown = "o": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "P" : LetterCase()\CaseDown = "p": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "Q" : LetterCase()\CaseDown = "q": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "R" : LetterCase()\CaseDown = "r": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "S" : LetterCase()\CaseDown = "s": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "T" : LetterCase()\CaseDown = "t": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "O" : LetterCase()\CaseDown = "u": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "V" : LetterCase()\CaseDown = "v": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "W" : LetterCase()\CaseDown = "w": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "X" : LetterCase()\CaseDown = "x": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "Y" : LetterCase()\CaseDown = "y": LetterCase()\INDEX = LetterCase()\INDEX + 1
    AddElement(LetterCase()): LetterCase()\Case__Up = "Z" : LetterCase()\CaseDown = "z": LetterCase()\INDEX = LetterCase()\INDEX + 1
    

    
  
    ;************************************************************************************************************************
    ; Message Info
    ;          
    Procedure MsgTimeout(*x)
        Protected x

        For x = 0 To PeekI(*Timer)
            
            Delay(500)
            If *idMsg\DebugInfo = 1                
                Debug "Message: " + *idMsg\Text + " - Timer: " +Str(x)
            EndIf                          
            Delay(500)
        Next
        If IsGadget(*idMsg\ObjStringID)
            SetGadgetColor(*idMsg\ObjStringID, #PB_Gadget_FrontColor, *idMsg\ColorF2)        
            SetGadgetText(*idMsg\ObjStringID,*idMsg\Rext)
        EndIf    
        
    EndProcedure    
    Procedure MessageInfo(ObjStringID.i = 0, MessageText$ = "",Timeout = 20, Kill.i = 0, ShowDbgInfo = 0, ResetMsg$ = "", PrimaryCol.l = 0, ResetCol.l = 0)
        
        If (Kill = 1) Or (TimerThread <> 0)
           If IsThread(TimerThread)
               KillThread(TimerThread)
               ProcedureReturn
            EndIf
        EndIf
        
        
        If IsThread(TimerThread)
            KillThread(TimerThread)
            If IsGadget(*idMsg\ObjStringID)
                SetGadgetColor(*idMsg\ObjStringID, #PB_Gadget_FrontColor ,*idMsg\ColorF2)
            EndIf    
        EndIf      
        

        If IsGadget(ObjStringID)
            *idMsg\ObjStringID = ObjStringID
            *idMsg\Text        = MessageText$
            *idMsg\Rext        = ResetMsg$
            *idMsg\DebugInfo   = ShowDbgInfo
            
            If (PrimaryCol.l = 0)
                *idMsg\ColorF1 = GetGadgetColor(*idMsg\ObjStringID, #PB_Gadget_FrontColor)
            Else
                *idMsg\ColorF1 = PrimaryCol
            EndIf    
            
            If (ResetCol.l = 0)
                *idMsg\ColorF2 = GetGadgetColor(*idMsg\ObjStringID, #PB_Gadget_FrontColor)
            Else
                *idMsg\ColorF2 = ResetCol                
            EndIf                                 
            
            PokeI(*Timer,Timeout)
            
            
            TimerThread = CreateThread(@MsgTimeout(),Timer)
            
            SetGadgetColor(*idMsg\ObjStringID, #PB_Gadget_FrontColor ,*idMsg\ColorF1)
            SetGadgetText(*idMsg\ObjStringID,*idMsg\Text)    
        EndIf    
    EndProcedure      
    Procedure SetDebugLog(LogMessageText$ = "", LogMode = 0)
        Protected CurrentDate$
        
        Select LogMode
            Case 0
                If Len(LogMessageText$) = 0
                    CurrentLineText$ = FormatDate("[%yyyy-%mm-%dd %hh:%ii:%ss]" , Date())
                Else    
                    CurrentLineText$ = FormatDate("[%yyyy-%mm-%dd %hh:%ii:%ss]: " , Date())
                    CurrentLineText$ = CurrentLineText$ + LogMessageText$
                EndIf    
            Default
        EndSelect 
        
        If OpenFile(DC::#LOGFILE, *mameExt\DebugLogFile, #PB_File_SharedRead)            
            FileSeek(DC::#LOGFILE, FileSize(*mameExt\DebugLogFile))              
            WriteStringN(DC::#LOGFILE ,CurrentLineText$ ,#PB_Ascii)
            CloseFile(DC::#LOGFILE)    
        EndIf                              
    EndProcedure
    ;
    ;
    ;
    
    
    Procedure Read_Config()
        Protected CfgDir$, CfgMain$, CfgPort$, SrcPath$, CurrentDate$, Mame$
        
        *mameExt\Title  = "LH.Mame(NXG,i)"
        *mameExt\Version= "0.07 (2018-04-16)"
        
;         
;         =======================================================================
;         History: 0.08 (2018-04-24) *Priv.Release*          
;           - Mess Part extended
;           - Added 5 Drives More (Dynamic)
;           - Added A Floppy/HD Drives Devices menü (predefined)
;           - Added Optional Commands on the Fly
;           - Fixed "CHdman.exe" on Start if not found a Mame Version
;           - Added Tooltips to missing Gui Objects
;           - Reworked part of the Startup Code
;           - Added Support for Drag'n'Drop it self in the Program
;           - small fixes
        
;         =======================================================================
;         History: 0.06 (2018-04-01)  
;           - Fixed Position List Loading. Mismatch in Path
;           - Fixed Mess Commandline with optionals arguemnt switches
        
;         
;         =======================================================================
;         History: 0.05 (2018-04-01)  
;           - Minor Fixes
;           - Added more Mess Device types
;           - Fixed NeoGeo and NeoCDZ Rom Listing
;           - Added PC-98 in the List
        
;         
;         =======================================================================
;         History: 0.04 (2016-05-25)  
;           - Code Upgraded to Purebasic 5.42 LTS
;           - Old Message Requester Code Changed and Updated
;           - Message's Fixes, yes my English ist not the best
;           - Small Bugfixes
        
;         History: 0.03 (2016-05-21)  
;           - Fix 'in CueSheet's' where Directory not exists
        
;         History: 0.02 (2016-05-19)         
;           - Changed lack info For user Error Message's
;           - Change Color Description For Clones        
;           - Fix Crash For Initial startup
;           - Fix Memory List Count (-1/+1)        
;           - Fix white screen IN Snap/Titles
;           - Fix Machine Names For Snap/Titles
;           - Fix Structure List
;           - Fix Last item on Ini Filter
;           - Increase Speed To Display Maschines
;           - Code Cleanup
;           - Increase Speed For generate the Listxml through LH.Mame(NXG,i)
;           - Maschines Select by Default
;           - Clone's Sorting Mode Order (Default is On)
;           - LH.Mame(NXG,i) use now a ini file To save
;               + the Last Softlist (Rom) Directory (From NeoGeoCD To PC/AT486)
;               + the Default Mess Maschine Rom (From NeoGeoCD To PC/AT486)
;               + the Desktop Position
;               + the Parent And Clone Color Settings
;               + the Clone List Description
;               + the Last Selected Maschine
;               + the Font Settings
;               + the Default Settings For Picture Mode/ Transparency
;               + the Mame File And Path
;               + the Chdman path        
;           - Added PC/AT486 To Tree        
;           - Added CMD Switch: use -m, --m, %m For "Path + (alternate) Mame Executable"
;             e.q: -m D:\Folder1\Folder2\Folder2\myxymamevxyz.exe
;           - Added xml file check on startup
;           - Update Game Status Icon
;           - Added Default Mame List's*
;           - Added To Menu: Picture Mode, Picture Transparency, Color & Font Settings
;           - Insert Automatic Wildcard Rom on Maschine Select (ini)
;           - Added Wildcard (Roms) Explorer For Directory
;           - Change And fixed LH.Mame(NXG,i) Startup Code 
;           - Added a Wildcard (Rom) Explorer 
;           - Fix Autoselect With Drag'n'Drop
;           - More Info Requester Messages
;           - Crashfix on POP/PUSH internal List
;           - Integrate CHDman
;           - Cuesheet Renamer (Rename the cue, Files And files IN the cue)
;           - CHDman Settings (Menu = Select alternate Executable & Outp To Cmd/Console)
;           - Crash IN *MemoryList Drivers > Sublist Elements 1. Fix by Adding +2  
;         
;         
;         History: 0.01 (2016-04-10)
;           - Public Release
;         
;         
;         Bugs
;         *List: Show NonCHD, Missing 1 Item
;         *List: Show Vertical Missing 5 Items
;         *List: Show Horzontal, 6 items To much
;         ====================
                           
        *mameExt\RootPath       = GetCurrentDirectory()
        *mameExt\Mame_ini       = ""
        *mameExt\Mame_iui       = ""
        *mameExt\LastDirectory  = *mameExt\RootPath
        *mameExt\PIMGX          = 0
        *mameExt\PIMGY          = 0
        *mameExt\PIMGH          = 258
        *mameExt\PIMGW          = 354
        *mameExt\BColr          = RGB(61,61,61)
        *mameExt\Picture_Alpha  = 178
        *mameExt\JumptoAfterMame= 3
        *mameExt\Prefs          = "LH.Mame(NXG,i).ini"
        *mameExt\FirstStart     = 1
    EndProcedure      

    
EndModule    
    
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 281
; FirstLine = 165
; Folding = j-
; EnableAsm
; EnableUnicode
; EnableXP
; UseMainFile = ..\LHMOpt.pb
; CurrentDirectory = ..\Release\mame0172b_64bit\