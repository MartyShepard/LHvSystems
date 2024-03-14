    ;
    ; Include Modules, Local Code
    ;
        XIncludeFile ".\vSystems_Modules\Constants.pb" 
        XIncludeFile ".\vSystems_Modules\ConstantsFonts.pb"
        XIncludeFile ".\vSystems_Modules\DataSections.pb" 
        
    ;
    ; Include Modules, Global Code Modules
    ;   
        XIncludeFile "..\INCLUDES\Class_Process.pb"     
        XIncludeFile "..\INCLUDES\Class_ServiceEX.pb"           
        
        XIncludeFile "..\INCLUDES\Class_Win_Form.pb"
        XIncludeFile "..\INCLUDES\Class_Win_Style.pb"         
        XIncludeFile "..\INCLUDES\Class_Win_Desk.pb"
                       
        XIncludeFile "..\INCLUDES\Class_ListIcon_Sort.pb"          
        XIncludeFile "..\INCLUDES\Class_Tooltip.pb"
        
        XIncludeFile "..\INCLUDES\CLASSES_GUI\ButtonGadgetEX.pb"
        XIncludeFile "..\INCLUDES\CLASSES_GUI\SplitterGadgetEX.pb"
        XIncludeFile "..\INCLUDES\CLASSES_GUI\DialogRequestEX.pb" 
        XIncludeFile "..\INCLUDES\CLASSES_GUI\DialogFontEX.pb"         
        
        XIncludeFile "..\INCLUDES\Class_Windows.pb"
        
        XIncludeFile "..\INCLUDES\Class_FastFilePeInfo.pb"
        XIncludeFile "..\INCLUDES\Class_FastFileHandle.pb"       
        XIncludeFile "..\INCLUDES\CLASSES_FFS\FastFileSearch.pb"
        
        XIncludeFile "..\INCLUDES\Class_Database.pb"        
        
        XIncludeFile "..\INCLUDES\CLASSES_IMG\Class_Image_IFF.pb"
        XIncludeFile "..\INCLUDES\CLASSES_IMG\Class_Image_GIF.pb"
        XIncludeFile "..\INCLUDES\CLASSES_IMG\Class_Image_PCX.pb"
        XIncludeFile "..\INCLUDES\CLASSES_IMG\Class_Image_DDS.pb"
        
        XIncludeFile "..\INCLUDES\CLASSES_SUB\Math_Bytes.pb"
        
        XIncludeFile "..\INCLUDES\CLASSES_EMU\FileFormat_DiskImageC64.pb"     
        XIncludeFile "..\INCLUDES\ClassEX_ArchiveLZX.pb"         
                  
        XIncludeFile "..\INCLUDES\Class_Debug_WM_MSG.pb"                    ; WM::
        
        XIncludeFile ".\vSystems_Modules\Module_LogitechLCD.pb"   
        
        UseZipPacker(): UseLZMAPacker(): UseSHA1Fingerprint()

        InitKeyboard()
        
        ;SetThemeAppProperties_(0)
        ;
        ; Include Modules, LOCAL
        ;           
        ProcessEX::SetAffinityActiv(GetCurrentProcessId_(),ProcessEX::SetAffinityCPUS(0,1))
        ;XIncludeFile ".\vSystems_Modules\LocaleModule.pb"
        
        XIncludeFile ".\vSystems_Modules\Module_Registry.pbi"
        XIncludeFile ".\vSystems_Modules\Module_Firewall.pb"        
    
        XIncludeFile ".\vSystems_Modules\Module_DataBase_Create.pb"     ; DB_Create::           
        XIncludeFile ".\vSystems_Modules\Module_Config.pb"              ; Startup::
        XIncludeFile ".\vSystems_Modules\Module_Monitoring.pb"          ; Monitor::    
        XIncludeFile ".\vSystems_Modules\Module_Compatibility.pb"
        XIncludeFile ".\vSystems_Modules\Module_UnrealHelper.pb"
        XIncludeFile ".\vSystems_Modules\Module_DataBase_Migrate.pb"    ; DB_Migrate::           
              
        XIncludeFile "..\INCLUDES\ClassEX_MenuSystem.pb"                ; Include Modules, Global Code Module (Menu System)              
              
        XIncludeFile ".\vSystems_Modules\Module_Font_Settings.pb"       ; vFont::
        XIncludeFile ".\vSystems_Modules\Module_KeyShortCut.pb"         ; vKeys::        
        XIncludeFile ".\vSystems_Modules\Module_ItemList.pb"            ; vItemTool::
        XIncludeFile ".\vSystems_Modules\Module_Thumbnails.pb"          ; vThumbSys::
        XIncludeFile ".\vSystems_Modules\Module_VImages.pb"             ; vImage::
        XIncludeFile ".\vSystems_Modules\Module_InfoWindow.pb"          ; vInfo::
        XIncludeFile ".\vSystems_Modules\Module_VSystem.pb"             ; vSystem::         
        XIncludeFile ".\vSystems_Modules\Module_VEngine.pb"             ; vEngine::       
        XIncludeFile ".\vSystems_Modules\Module_DiskPath.pb"            ; vDiskPath::
        XIncludeFile ".\vSystems_Modules\Module_InfoMenu.pb"            ; vInfoMenu::
        XIncludeFile ".\vSystems_Modules\Module_vItemC64E.pb"			  ; vItem64E::
        XIncludeFile ".\vSystems_Modules\Module_ArchivManager.pb"       ; vItem64E::        
        BackupRestart:       
        vSystem::System_CheckInstance()
        
        Startup::Prepare()                               
        
        XIncludeFile ".\vSystems_Modules\Module_Gui.pb"                 ; Haupt Fenster
        XIncludeFile ".\vSystems_Modules\Module_MameCall.pb"            ; Callback für das Programm
        XIncludeFile ".\vSystems_Modules\Module_vWindows.pb"            ; Externe Fenster/ Code Sachen
              
        ; Update System
        XIncludeFile ".\vSystems_Modules\Module_Update.pb"              ; Update System
        ; Menu System
               
        XIncludeFile ".\vSystems_Modules\Module_Menu.pb"                ; Beinhaltet die Individuellen Menüs        
              
        XIncludeFile ".\vSystems_Modules\Module_DataBase_Update.pb"    ; DB_Update:: 
        XIncludeFile ".\vSystems_Modules\Module_GuiInteract.pb"         ; Haupt Code Geschichten
        

        ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
        ;
        ;   Für Programm eine einmalige UNIQUE GUI ID Erstellen    
        ;
        ;   LH.Game (Start,i)               :{876DB3FE-C62A-4B50-BD93-F173A070BD21}
        ;   LH.Game (Install Assitant)      :{23D92E5B-5E22-4222-A15D-EEBB72F98C33}
        ;   LH.Game (User Interface)        :{A50F4281-4BD7-4553-BF27-5F29C2BB6CB3}
        ;   LH.CheckSum (Verify,i)          :{5B9B7B3C-28F2-4D41-A087-532FD56323F6}
        ;   LH.Game (Database,i)            :{461F7334-B83B-4C4D-94E0-E1A776A92A98}
        ;   LH.idTech1(Start,i)             :{461F7334-B83B-4C4D-94E0-E1A776A92A98}
        ;   LH.Mame(Config,i)               :{BE6F8917-A0D0-446D-B43A-77556A2FCCB1}
        ;   LH.vSystems                     :{BC0CFC12-12E4-4CBF-9D24-00D5263112AE}        
        ;Debug Windows::MakeGUID()
        
       
        Windows::Set_Instances(1, GetFilePart( ProgramFilename() ,#PB_FileSystem_NoExtension),"{BC0CFC12-12E4-4CBF-9D24-00D5263112AE}")      
         
        MagicGUI::SetGuiWindow()        
        ;
        ; Callback Events und Strind die im Hauptfenster 'verzahnt sind'

        SetWindowCallback(GuruCallBack::@CallBackEvnts(),DC::#_Window_001):
        GuruCallBack::StringGadgetSetCallback(DC::#String_001, DC::#_Window_001)
        GuruCallBack::StringGadgetSetCallback(DC::#String_002, DC::#_Window_001)
        GuruCallBack::StringGadgetSetCallback(DC::#String_003, DC::#_Window_001)         
        GuruCallBack::StringGadgetSetCallback(DC::#String_004, DC::#_Window_001)         
        GuruCallBack::StringGadgetSetCallback(DC::#String_005, DC::#_Window_001)         
        GuruCallBack::StringGadgetSetCallback(DC::#String_006, DC::#_Window_001)         
        GuruCallBack::StringGadgetSetCallback(DC::#String_007, DC::#_Window_001)        
        GuruCallBack::StringGadgetSetCallback(DC::#String_008, DC::#_Window_001)          
        GuruCallBack::StringGadgetSetCallback(DC::#String_009, DC::#_Window_001)          
        GuruCallBack::StringGadgetSetCallback(DC::#String_010, DC::#_Window_001)
        GuruCallBack::StringGadgetSetCallback(DC::#String_011, DC::#_Window_001)        
        GuruCallBack::ListGadgetSetCallback(DC::#ListIcon_001, DC::#_Window_001)
        GuruCallBack::SplitGadgetSetCallback(DC::#Splitter1, DC::#_Window_001)
        GuruCallBack::ScrollAreaGadgetSetCallback(DC::#Contain_10, DC::#_Window_001)
        

        
                                                            Interact::MainCode()  
        If ( Startup::*LHGameDB\BaseSVNMigrate = #True )
            Goto  BackupRestart
        EndIf
        
        If ( Startup::*LHGameDB\bUpdateProcess = #True )
            RunProgram( GetCurrentDirectory() + "_UpdateModul_.exe" )
        EndIf    
        
        End
        
        Delay(25)
        
        If IsProgram( GetCurrentProcessId_() )
            KillProgram( GetCurrentProcessId_() )
        EndIf    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 98
; FirstLine = 54
; EnableAsm
; EnableThread
; EnableXP
; UseIcon = vSystems_Modules\Data_Images\Icon\icon pro.ico
; Executable = Release\vSystems64Bit.exe
; CPU = 5
; CurrentDirectory = Release\
; Compiler = PureBasic 5.73 LTS (Windows - x64)
; Debugger = IDE
; Warnings = Display
; EnableUnicode