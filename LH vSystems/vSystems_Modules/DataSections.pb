UsePNGImageDecoder(): UseJPEG2000ImageDecoder(): UseJPEGImageDecoder(): UseTGAImageDecoder(): UseTIFFImageDecoder()
UsePNGImageEncoder(): UseJPEG2000ImageEncoder(): UseJPEGImageEncoder(): UsePNGImageEncoder():

DeclareModule DI
    
    Debug ""
    Debug "Purebasic Constants Datasection [DI::]"      
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes: Menu Items
    ;
    MaxPBEnums.i = 2800  
    
    Enumeration 2601 Step 1
        #_MNU_CUT: #_MNU_COP: #_MNU_RED: #_MNU_UND: #_MNU_PAS: #_MNU_FND: #_MNU_CLR: #_MNU_EX1: #_MNU_EX2: #_MNU_UPD
        #_MNU_DSK: #_MNU_SVE: #_MNU_LOD: #_MNU_PRN: #_MNU_SET: #_MNU_FDF: #_MNU_FDL: #_MNU_TDF: #_MNU_TRN: #_MNU_WRS
        #_MNU_CLS: #_MNU_WMS: #_MNU_WMT: #_MNU_WMH: #_MNU_SPL: #_MNU_DPC: #_MNU_ATO: #_MNU_EXE: #_MNU_EXD: #_MNU_AEE
        #_MNU_AED: #_MNU_TBD: #_MNU_TBE: #_MNU_SWN: #_MNU_SFN: #_MNU_TB1: #_MNU_TB2: #_MNU_TB3: #_MNU_TB4: #_MNU_TB5
        #_MNU_DIR: #_MNU_RAL: #_MNU_RNE: #_MNU_FEX: #_MNU_FPS: #_MNU_URL: #_MNU_RUN: 
    EndEnumeration
    Debug "- Menu ImageIcon #2601 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    ;////////////////////////////////////////////////////////////////////////////////////////////////////////// Reserved Classes: Buttons For GadgetEX (Seperate)
    ;
    MaxPBEnums.i = 3100  
    
    Enumeration 2801 Step 1
        
        #_BTN_GREY4_0N  : #_BTN_GREY4_0H    : #_BTN_GREY4_0P    : #_BTN_GREY4_0D                         
        #_BTN_CLOSE_0N  : #_BTN_CLOSE_0H    : #_BTN_CLOSE_0P    : #_BTN_CLOSE_0D
        #_BTN_MINIM_0N  : #_BTN_MINIM_0H    : #_BTN_MINIM_0P    : #_BTN_MINIM_0D
        #_BTN_RESIZ_0N  : #_BTN_RESIZ_0H    : #_BTN_RESIZ_0P    : #_BTN_RESIZ_0D             
        
        #_BTN_ITEM_ADD_N: #_BTN_ITEM_ADD_H  : #_BTN_ITEM_ADD_P  : #_BTN_ITEM_ADD_D
        #_BTN_ITEM_COP_N: #_BTN_ITEM_COP_H  : #_BTN_ITEM_COP_P  : #_BTN_ITEM_COP_D
        #_BTN_ITEM_DEL_N: #_BTN_ITEM_DEL_H  : #_BTN_ITEM_DEL_P  : #_BTN_ITEM_DEL_D             
        #_BTN_ITEM_OKK_N: #_BTN_ITEM_OKK_H  : #_BTN_ITEM_OKK_P  : #_BTN_ITEM_OKK_D  
        
        #_BTN_LBOXE_N   : #_BTN_LBOXE_H     : #_BTN_LBOXE_P     : #_BTN_LBOXE_D
        #_BTN_LBOXP_N   : #_BTN_LBOXP_H     : #_BTN_LBOXP_P     : #_BTN_LBOXP_D
        #_BTN_LBOXL_N   : #_BTN_LBOXL_H     : #_BTN_LBOXL_P     : #_BTN_LBOXL_D
        #_BTN_LBOXT_N   : #_BTN_LBOXT_H     : #_BTN_LBOXT_P     : #_BTN_LBOXT_D 
        
        #_BTN_MENU_N    : #_BTN_MENU_H      : #_BTN_MENU_P      : #_BTN_MENU_D               
        #_BTN_SELECT_N  : #_BTN_SELECT_H    : #_BTN_SELECT_P    : #_BTN_SELECT_D 
        
        #_BTN_FLOPPY_N  : #_BTN_FLOPPY_H    : #_BTN_FLOPPY_P    : #_BTN_FLOPPY_D   
        #_BTN_BLUELITE_N: #_BTN_BLUELITE_H  : #_BTN_BLUELITE_P  : #_BTN_BLUELITE_D 
        #_BTN_GREY4_1H  : #_BTN_GREY4_2H    : #_BTN_GREY4_LC    : #_BTN_GREY4_RC
        
        #_BTN_TAB_N     : #_BTN_TAB_H       : #_BTN_TAB_P       : #_BTN_TAB_D     
        #_BTN_SWT_P     :
        #_BTN_INFO_0N  : #_BTN_INFO_0H    : #_BTN_INFO_0P    : #_BTN_INFO_0D        
        
    EndEnumeration
    Debug "- Button ImageID #2801 -> #" + RSet( Str( #PB_Compiler_EnumerationValue-1), 4,"0") + #TAB$ + "| End Value: #"+ RSet( Str(MaxPBEnums) ,4,"0") +"| Free: " + Str(MaxPBEnums - ( #PB_Compiler_EnumerationValue-1))
    
    
EndDeclareModule

Module DI
    
    ;
    ; Tab Images
    CatchImage(#_BTN_TAB_N,?_BTN_TAB_N):CatchImage(#_BTN_TAB_H,?_BTN_TAB_H):CatchImage(#_BTN_TAB_P,?_BTN_TAB_P):CatchImage(#_BTN_TAB_D,?_BTN_TAB_P)
    
    ;
    ; Menu Items
    CatchImage(#_MNU_CUT, ?_MNU_CUT):   CatchImage(#_MNU_COP, ?_MNU_COP):   CatchImage(#_MNU_RED, ?_MNU_RED):   CatchImage(#_MNU_UND, ?_MNU_UND):   CatchImage(#_MNU_PAS, ?_MNU_PAS)
    CatchImage(#_MNU_FND, ?_MNU_FND):   CatchImage(#_MNU_CLR, ?_MNU_CLR):   CatchImage(#_MNU_EX1, ?_MNU_EX1):   CatchImage(#_MNU_EX2, ?_MNU_EX2):   CatchImage(#_MNU_UPD, ?_MNU_UPD)
    CatchImage(#_MNU_DSK, ?_MNU_DSK):   CatchImage(#_MNU_SVE, ?_MNU_SVE):   CatchImage(#_MNU_LOD, ?_MNU_LOD):   CatchImage(#_MNU_PRN, ?_MNU_PRN):   CatchImage(#_MNU_SET, ?_MNU_SET)
    CatchImage(#_MNU_FDF, ?_MNU_FDF):   CatchImage(#_MNU_FDL, ?_MNU_FDL):   CatchImage(#_MNU_TDF, ?_MNU_TDF):   CatchImage(#_MNU_TRN, ?_MNU_TRN):   CatchImage(#_MNU_WRS, ?_MNU_WRS)
    CatchImage(#_MNU_CLS, ?_MNU_CLS):   CatchImage(#_MNU_WMS, ?_MNU_WMS):   CatchImage(#_MNU_WMT, ?_MNU_WMT):   CatchImage(#_MNU_WMH, ?_MNU_WMH):   CatchImage(#_MNU_SPL, ?_MNU_SPL)
    CatchImage(#_MNU_DPC, ?_MNU_DPC):   CatchImage(#_MNU_ATO, ?_MNU_ATO):   CatchImage(#_MNU_EXD, ?_MNU_EXD):   CatchImage(#_MNU_EXE, ?_MNU_EXE):   CatchImage(#_MNU_AED, ?_MNU_AED)
    CatchImage(#_MNU_AEE, ?_MNU_AEE):   CatchImage(#_MNU_TBD, ?_MNU_TBD):   CatchImage(#_MNU_TBE, ?_MNU_TBE):   CatchImage(#_MNU_SWN, ?_MNU_SWN):   CatchImage(#_MNU_SFN, ?_MNU_SFN)
    CatchImage(#_MNU_TB1, ?_MNU_TB1):   CatchImage(#_MNU_TB2, ?_MNU_TB2):   CatchImage(#_MNU_TB3, ?_MNU_TB3):   CatchImage(#_MNU_TB4, ?_MNU_TB4):   CatchImage(#_MNU_TB5, ?_MNU_TB5)
    CatchImage(#_MNU_DIR, ?_MNU_DIR):   CatchImage(#_MNU_RAL, ?_MNU_RAL):   CatchImage(#_MNU_RNE, ?_MNU_RNE):   CatchImage(#_MNU_FEX, ?_MNU_FEX):   CatchImage(#_MNU_FPS, ?_MNU_FPS)
    CatchImage(#_MNU_URL, ?_MNU_URL):   CatchImage(#_MNU_RUN, ?_MNU_RUN):
    
    ;
    ; Button Images
    CatchImage(#_BTN_GREY4_0N, ?_BTN_GREY4_0N): CatchImage(#_BTN_GREY4_0H, ?_BTN_GREY4_0H): CatchImage(#_BTN_GREY4_0P, ?_BTN_GREY4_0P): CatchImage(#_BTN_GREY4_0D, ?_BTN_GREY4_0D)
    CatchImage(#_BTN_GREY4_1H,?_BTN_GREY4_1H) : CatchImage(#_BTN_GREY4_2H,?_BTN_GREY4_2H) : CatchImage(#_BTN_GREY4_LC,?_BTN_GREY4_LC) : CatchImage(#_BTN_GREY4_RC,?_BTN_GREY4_RC)
    
    CatchImage(#_BTN_CLOSE_0N, ?_BTN_CLOSE_0N): CatchImage(#_BTN_CLOSE_0H, ?_BTN_CLOSE_0H): CatchImage(#_BTN_CLOSE_0P, ?_BTN_CLOSE_0P): CatchImage(#_BTN_CLOSE_0D, ?_BTN_CLOSE_0D)
    CatchImage(#_BTN_MINIM_0N, ?_BTN_MINIM_0N): CatchImage(#_BTN_MINIM_0H, ?_BTN_MINIM_0H): CatchImage(#_BTN_MINIM_0P, ?_BTN_MINIM_0P): CatchImage(#_BTN_MINIM_0D, ?_BTN_MINIM_0D)
    CatchImage(#_BTN_INFO_0N, ?_BTN_INFO_0N): CatchImage(#_BTN_INFO_0H, ?_BTN_INFO_0H): CatchImage(#_BTN_INFO_0P, ?_BTN_INFO_0P): CatchImage(#_BTN_INFO_0D, ?_BTN_INFO_0D)    
    CatchImage(#_BTN_RESIZ_0N, ?_BTN_RESIZ_0N): CatchImage(#_BTN_RESIZ_0H, ?_BTN_RESIZ_0H): CatchImage(#_BTN_RESIZ_0P, ?_BTN_RESIZ_0P): CatchImage(#_BTN_RESIZ_0D, ?_BTN_RESIZ_0D)
    CatchImage(#_BTN_MENU_N  , ?_BTN_MENU_N  ): CatchImage(#_BTN_MENU_H  , ?_BTN_MENU_H  ): CatchImage(#_BTN_MENU_P  , ?_BTN_MENU_P  ): CatchImage(#_BTN_MENU_D  , ?_BTN_MENU_D  )
    
    CatchImage(#_BTN_LBOXE_N, ?_BTN_LBOXE_N)  : CatchImage(#_BTN_LBOXE_H, ?_BTN_LBOXE_H)  : CatchImage(#_BTN_LBOXE_P, ?_BTN_LBOXE_P)  : CatchImage(#_BTN_LBOXE_D, ?_BTN_LBOXE_D)
    CatchImage(#_BTN_LBOXP_N, ?_BTN_LBOXP_N)  : CatchImage(#_BTN_LBOXP_H, ?_BTN_LBOXP_H)  : CatchImage(#_BTN_LBOXP_P, ?_BTN_LBOXP_P)  : CatchImage(#_BTN_LBOXP_D, ?_BTN_LBOXP_D)
    CatchImage(#_BTN_LBOXL_N, ?_BTN_LBOXL_N)  : CatchImage(#_BTN_LBOXL_H, ?_BTN_LBOXL_H)  : CatchImage(#_BTN_LBOXL_P, ?_BTN_LBOXL_P)  : CatchImage(#_BTN_LBOXL_D, ?_BTN_LBOXL_D)
    CatchImage(#_BTN_LBOXT_N, ?_BTN_LBOXT_N)  : CatchImage(#_BTN_LBOXT_H, ?_BTN_LBOXT_H)  : CatchImage(#_BTN_LBOXT_P, ?_BTN_LBOXT_P)  : CatchImage(#_BTN_LBOXT_D, ?_BTN_LBOXT_D)
    
    CatchImage(#_BTN_FLOPPY_N,?_BTN_FLOPPY_N) : CatchImage(#_BTN_FLOPPY_H,?_BTN_FLOPPY_H) : CatchImage(#_BTN_FLOPPY_P,?_BTN_FLOPPY_P) : CatchImage(#_BTN_FLOPPY_D,?_BTN_FLOPPY_D)
    
    CatchImage(DC::#_PNG_NOSA, ?_PNG_NOSA)    : CatchImage(DC::#_PNG_NOSB, ?_PNG_NOSB)    : CatchImage(DC::#_PNG_NOSC, ?_PNG_NOSC)    : CatchImage(DC::#_PNG_NOSD, ?_PNG_NOSD):    
    
    CatchImage(#_BTN_BLUELITE_N,?_BTN_BLUELITE_N)
    CatchImage(#_BTN_BLUELITE_H,?_BTN_BLUELITE_H)
    CatchImage(#_BTN_BLUELITE_P,?_BTN_BLUELITE_P)
    CatchImage(#_BTN_BLUELITE_D,?_BTN_BLUELITE_D)

    CatchImage(#_BTN_SWT_P,?_INFO_SWICH_P)
      
    CatchImage(DC::#_PNG_LEER, ?_PNG_LEER)
    
    
    DataSection
        
        
        ;//----------------------------------------------------------------------------;Grey4 (Size 83x20)
        _BTN_GREY4_0N:
        IncludeBinary "Data_Images\Buttons\Grey4_Normal.png"
        _BTN_GREY4_0H:
        IncludeBinary "Data_Images\Buttons\Grey4_Hover.png"
        _BTN_GREY4_0P:
        IncludeBinary "Data_Images\Buttons\Grey4_Pressed.png"
        _BTN_GREY4_0D:
        IncludeBinary "Data_Images\Buttons\Grey4_Disabled.png"
        
        _BTN_GREY4_1H:
        IncludeBinary "Data_Images\Buttons\Grey4_HoverLS.png"    
        
        _BTN_GREY4_2H:
        IncludeBinary "Data_Images\Buttons\Grey4_HoverBS.png"   
        
        _BTN_GREY4_LC:
        IncludeBinary "Data_Images\Buttons\Grey4_HoverLC.png"    
        
        _BTN_GREY4_RC:
        IncludeBinary "Data_Images\Buttons\Grey4_HoverRC.png"      
        
        _BTN_CLOSE_0N:
        IncludeBinary "Data_Images\Buttons\CloseN.png"
        _BTN_CLOSE_0H:
        IncludeBinary "Data_Images\Buttons\CloseH.png"
        _BTN_CLOSE_0P:
        IncludeBinary "Data_Images\Buttons\CloseP.png"
        _BTN_CLOSE_0D:
        IncludeBinary "Data_Images\Buttons\CloseD.png"
        
        _BTN_INFO_0N:
        IncludeBinary "Data_Images\Buttons\InfoN.png"
        _BTN_INFO_0H:
        IncludeBinary "Data_Images\Buttons\InfoH.png"
        _BTN_INFO_0P:
        IncludeBinary "Data_Images\Buttons\InfoP.png"
        _BTN_INFO_0D:
        IncludeBinary "Data_Images\Buttons\InfoD.png"
        
        ;//----------------------------------------------------------------------------;Grey4 (Size 83x20)
        _BTN_TAB_N:
        IncludeBinary "Data_Images\Buttons\Tab1_N.png"
        _BTN_TAB_H:
        IncludeBinary "Data_Images\Buttons\Tab1_H.png"
        _BTN_TAB_P:
        IncludeBinary "Data_Images\Buttons\Tab1_P.png"
        _BTN_TAB_D:
        IncludeBinary "Data_Images\Buttons\Grey4_Disabled.png"
        
        ;//----------------------------------------------------------------------------;Minimized Button (Size 30x30)
        _BTN_MINIM_0N:
        IncludeBinary "Data_Images\Buttons\MinmN.png"
        _BTN_MINIM_0H:
        IncludeBinary "Data_Images\Buttons\MinmH.png"
        _BTN_MINIM_0P:
        IncludeBinary "Data_Images\Buttons\MinmP.png"
        _BTN_MINIM_0D:
        IncludeBinary "Data_Images\Buttons\MinmD.png"     
        
        ;//----------------------------------------------------------------------------;Resize Button (Size 30x30)
        _BTN_RESIZ_0N:
        IncludeBinary "Data_Images\Buttons\ReszN.png"
        _BTN_RESIZ_0H:
        IncludeBinary "Data_Images\Buttons\ReszH.png"
        _BTN_RESIZ_0P:
        IncludeBinary "Data_Images\Buttons\ReszP.png"
        _BTN_RESIZ_0D:
        IncludeBinary "Data_Images\Buttons\ReszD.png"          
        
        ;//----------------------------------------------------------------------------;Listbox Button Sort Title (Size 341x21)
        _BTN_LBOXT_N:
        IncludeBinary "Data_Images\Buttons\LBOXT_N.png"
        _BTN_LBOXT_H:
        IncludeBinary "Data_Images\Buttons\LBOXT_H.png"
        _BTN_LBOXT_P:
        IncludeBinary "Data_Images\Buttons\LBOXT_P.png"
        _BTN_LBOXT_D:
        IncludeBinary "Data_Images\Buttons\LBOXT_N.png"       
        
        ;//----------------------------------------------------------------------------;Listbox Button Sort Platform (Size 98x21)
        _BTN_LBOXP_N:
        IncludeBinary "Data_Images\Buttons\LBOXP_N.png"
        _BTN_LBOXP_H:
        IncludeBinary "Data_Images\Buttons\LBOXP_H.png"
        _BTN_LBOXP_P:
        IncludeBinary "Data_Images\Buttons\LBOXP_P.png"
        _BTN_LBOXP_D:
        IncludeBinary "Data_Images\Buttons\LBOXP_N.png"  
        
        ;//----------------------------------------------------------------------------;Listbox Button Sort Language (Size 88x21)
        _BTN_LBOXL_N:
        IncludeBinary "Data_Images\Buttons\LBOXL_N.png"
        _BTN_LBOXL_H:
        IncludeBinary "Data_Images\Buttons\LBOXL_H.png"
        _BTN_LBOXL_P:
        IncludeBinary "Data_Images\Buttons\LBOXL_P.png"
        _BTN_LBOXL_D:
        IncludeBinary "Data_Images\Buttons\LBOXL_D.png"  
        
        ;//----------------------------------------------------------------------------;Listbox Button Sort Programm (Size 93x21)
        _BTN_LBOXE_N:
        IncludeBinary "Data_Images\Buttons\LBOXE_N.png"
        _BTN_LBOXE_H:
        IncludeBinary "Data_Images\Buttons\LBOXE_H.png"
        _BTN_LBOXE_P:
        IncludeBinary "Data_Images\Buttons\LBOXE_P.png"
        _BTN_LBOXE_D:
        IncludeBinary "Data_Images\Buttons\LBOXE_N.png"     
        
        ;//----------------------------------------------------------------------------;Flop Icon 20x20
        _BTN_FLOPPY_N:
        IncludeBinary "Data_Images\Buttons\FLOPPYN.png"
        _BTN_FLOPPY_H:
        IncludeBinary "Data_Images\Buttons\FLOPPYH.png"
        _BTN_FLOPPY_P:
        IncludeBinary "Data_Images\Buttons\FLOPPYP.png"
        _BTN_FLOPPY_D:
        IncludeBinary "Data_Images\Buttons\FLOPPYN.png"  
        
        ;//----------------------------------------------------------------------------;Lite Blue Icon 170x20
        _BTN_BLUELITE_N:
        IncludeBinary "Data_Images\Buttons\BLUELITEN.png"
        _BTN_BLUELITE_H:
        IncludeBinary "Data_Images\Buttons\BLUELITEH.png"
        _BTN_BLUELITE_P:
        IncludeBinary "Data_Images\Buttons\BLUELITEP.png"
        _BTN_BLUELITE_D:
        IncludeBinary "Data_Images\Buttons\BLUELITED.png"       
        
        ;  //----------------------------------------------------------------------------;Menu Button (Size 30x30)
        _BTN_MENU_N:
        IncludeBinary "Data_Images\Buttons\MENUN.png"
        _BTN_MENU_H:
        IncludeBinary "Data_Images\Buttons\MENUH.png"
        _BTN_MENU_P:
        IncludeBinary "Data_Images\Buttons\MENUP.png"
        _BTN_MENU_D:
        IncludeBinary "Data_Images\Buttons\MENUD.png"     
        
        ;//----------------------------------------------------------------------------;No-Screenshots (Size 256x192)   
        _PNG_NOSA:
        IncludeBinary "Data_Images\BUTTONS\NoScreen1.png"
        _PNG_NOSB:
        IncludeBinary "Data_Images\BUTTONS\NoScreen2.png"
        _PNG_NOSC:
        IncludeBinary "Data_Images\BUTTONS\NoScreen3.png"
        _PNG_NOSD:
        IncludeBinary "Data_Images\BUTTONS\NoScreen4.png"  
        
        ;//----------------------------------------------------------------------------;Leer PNG (Size 2x2)   
        _PNG_LEER:
        IncludeBinary "Data_Images\BUTTONS\Leer.png" 
        
        _INFO_SWICH_P:
        IncludeBinary "Data_Images\BUTTONS\Switch_P.PNG"    
        
        ;// ----------------------------------------------------------------------------; MenuItem Cut
        _MNU_CUT:
        IncludeBinary "Data_Images\MENU\MnuCut.PNG"    
        _MNU_COP:
        IncludeBinary "Data_Images\MENU\MnuCopy.PNG"
        _MNU_RED:
        IncludeBinary "Data_Images\MENU\MnuRedo.PNG"
        _MNU_UND:
        IncludeBinary "Data_Images\MENU\MnuUndo.PNG"
        _MNU_PAS:
        IncludeBinary "Data_Images\MENU\MnuPaste.PNG"  
        _MNU_FND:
        IncludeBinary "Data_Images\MENU\MnuFind.PNG"
        _MNU_CLR:
        IncludeBinary "Data_Images\MENU\MnuClear.PNG"
        _MNU_EX1:
        IncludeBinary "Data_Images\MENU\MnuExplore1.PNG" 
        _MNU_EX2:
        IncludeBinary "Data_Images\MENU\MnuExplore2.PNG"
        _MNU_UPD:
        IncludeBinary "Data_Images\MENU\MnuUpdate.PNG"
        _MNU_DSK:
        IncludeBinary "Data_Images\MENU\MnuDisk.PNG"
        _MNU_SVE:
        IncludeBinary "Data_Images\MENU\MnuSave.PNG"
        _MNU_LOD:
        IncludeBinary "Data_Images\MENU\MnuLoad.PNG"
        _MNU_PRN:
        IncludeBinary "Data_Images\MENU\MnuPrint.PNG"      
        _MNU_SET:
        IncludeBinary "Data_Images\MENU\MnuSettings.PNG"
        _MNU_FDF:
        IncludeBinary "Data_Images\MENU\MnuFontDefault.PNG"
        _MNU_FDL:
        IncludeBinary "Data_Images\MENU\MnuFontLoad.PNG" 
        _MNU_TDF:
        IncludeBinary "Data_Images\MENU\MnuTabDefault.PNG"   
        _MNU_TRN:
        IncludeBinary "Data_Images\MENU\MnuTabRename.PNG"
        _MNU_WRS:
        IncludeBinary "Data_Images\MENU\MnuWinReset.PNG"
        _MNU_CLS:
        IncludeBinary "Data_Images\MENU\MnuClose.PNG"  
        _MNU_WMS:
        IncludeBinary "Data_Images\MENU\MnuWinMainReset.PNG"     
        _MNU_WMT:
        IncludeBinary "Data_Images\MENU\MnuWinThumbReset.PNG"         
        _MNU_WMH:
        IncludeBinary "Data_Images\MENU\MnuWinMainHeight.PNG"
        _MNU_SPL:
        IncludeBinary "Data_Images\MENU\MnuWinSplitterHeight.PNG"
        _MNU_DPC:
        IncludeBinary "Data_Images\MENU\MnuDeletePicture.png"
        _MNU_ATO:
        IncludeBinary "Data_Images\MENU\MnuAuto.png"
        _MNU_EXD:
        IncludeBinary "Data_Images\MENU\MnuExplorerOff.png"
        _MNU_EXE:
        IncludeBinary "Data_Images\MENU\MnuExplorerOn.png"   
        _MNU_AED:
        IncludeBinary "Data_Images\MENU\MnuAeroOff.png"
        _MNU_AEE:
        IncludeBinary "Data_Images\MENU\MnuAeroOn.png"          
        _MNU_TBD:
        IncludeBinary "Data_Images\MENU\MnuTaskbarOff.png"
        _MNU_TBE:
        IncludeBinary "Data_Images\MENU\MnuTaskbarOn.png"
        _MNU_SWN:
        IncludeBinary "Data_Images\MENU\MnuSettingsWin.png"         
        _MNU_SFN:
        IncludeBinary "Data_Images\MENU\MnuSettingsFonts.png"
        _MNU_TB1:
        IncludeBinary "Data_Images\MENU\MnuThumbNailSize1.png"
        _MNU_TB2:
        IncludeBinary "Data_Images\MENU\MnuThumbNailSize2.png"
        _MNU_TB3:
        IncludeBinary "Data_Images\MENU\MnuThumbNailSize3.png"         
        _MNU_TB4:
        IncludeBinary "Data_Images\MENU\MnuThumbNailSize4.png"         
        _MNU_TB5:
        IncludeBinary "Data_Images\MENU\MnuThumbNailSize5.png"
        _MNU_DIR:
        IncludeBinary "Data_Images\MENU\MnuDirectory.png"
        _MNU_RAL:
        IncludeBinary "Data_Images\MENU\MnuRepAll.png"
        _MNU_RNE:
        IncludeBinary "Data_Images\MENU\MnuRepOne.png" 
        _MNU_FEX:
        IncludeBinary "Data_Images\MENU\MnuFileExtern.png" 
        _MNU_FPS:
        IncludeBinary "Data_Images\MENU\MnuFileProps.png"    
        _MNU_URL:
        IncludeBinary "Data_Images\MENU\MnuUrlOpen.png"
        _MNU_RUN:
        IncludeBinary "Data_Images\MENU\MnuRun.png"         
    EndDataSection
    

EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 148
; FirstLine = 120
; Folding = -
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode