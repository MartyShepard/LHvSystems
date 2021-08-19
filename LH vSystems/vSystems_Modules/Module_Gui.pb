DeclareModule MagicGUI
    
    Declare SetGuiWindow()
    
    Declare.i DefaultWindow(ChildWindowID)
    Declare.i InteractiveGadgets(ChildWindowID.i, Resize.i = 0, SnapHeight = 30)
    Declare.i InteractiveGadgets_Edit(ChildWindowID.i, Resize.i = 0, SnapHeight = 30)
    
    
    
    Structure OBJECT_COLOR
        rgb_StrinBC.i
        rgb_StrinFC.i
        rgb_CntBckC.i
        rgb_strBckC.i
        rgb_strFrCk.i
        rgb_backgrd.i
        rgb_darkgrd.i
        rgb_31_31_31.i
        rgb_41_41_41.i
        rgb_46_46_46.i            
        rgb_51_51_51.i             
        rgb_54_54_54.i
        rgb_58_58_58.i             
        rgb_61_61_61.i            
        rgb_68_68_68.i
        rgb_71_71_71.i
        rgb_250_250_250.i             
        rgb_FocusBack_New.i
        rgb_FocusFrnt_New.i
        rgb_FocusBack_Old.i
        rgb_FocusFrnt_Old.i 
        rgb_C64_BG1.i
        rgb_C64_BG2.i
        rgb_C64_BG3.i
        rgb_C64_BG4.i              
        rgb_C64_Front1.i
        rgb_C64_Front2.i
    EndStructure
    
    Structure OBJECT_POSITION
        h.i
        w.i 
        x.i
        y.i
        c.OBJECT_COLOR 
    EndStructure
    
    Global *ObjPos.OBJECT_POSITION       = AllocateMemory(SizeOf(OBJECT_POSITION))
    
    Declare Set_Tooltypes()
    Declare Set_Tooltypes_Ext(ChildWindowID.i)
    
EndDeclareModule

Module MagicGUI                
    Prototype.l NoBorder(Gadget.l, String_1.p-unicode,String_2.p-unicode)
    
    *ObjPos\c\rgb_StrinBC    = RGB(101,101,101)
    *ObjPos\c\rgb_StrinFC    = RGB(250,250,250) 
    *ObjPos\c\rgb_CntBckC    = RGB(61,61,61)
    *ObjPos\c\rgb_strBckC    = RGB(71,71,71)
    *ObjPos\c\rgb_strFrCk    = RGB(149, 160, 33) 
    *ObjPos\c\rgb_backgrd    = RGB(61,61,61)
    *ObjPos\c\rgb_darkgrd    = RGB(81,81,81)
    *ObjPos\c\rgb_31_31_31   = RGB(31,31,31) 
    *ObjPos\c\rgb_41_41_41   = RGB(41,41,41)
    *ObjPos\c\rgb_46_46_46   = RGB(46,46,46)        
    *ObjPos\c\rgb_51_51_51   = RGB(51,51,51)         
    *ObjPos\c\rgb_54_54_54   = RGB(54,54,54)
    *ObjPos\c\rgb_58_58_58   = RGB(58,58,58)        
    *ObjPos\c\rgb_61_61_61   = RGB(61,61,61)        
    *ObjPos\c\rgb_68_68_68   = RGB(68,68,68)
    *ObjPos\c\rgb_71_71_71   = RGB(71,71,71)        
    *ObjPos\c\rgb_250_250_250= RGB(250,250,250)
    *ObjPos\c\rgb_C64_BG1    = RGB(7, 36, 153)
    *ObjPos\c\rgb_C64_BG2    = RGB(53, 40, 121) 
    *ObjPos\c\rgb_C64_BG3    = RGB(28, 58, 119)
    *ObjPos\c\rgb_C64_BG4    = $792731
    *ObjPos\c\rgb_C64_Front1  = RGB(108, 94, 181)
    *ObjPos\c\rgb_C64_Front2  = RGB(177, 203, 239)           
    
    Structure BOXGADGETS
        nr.i[19]         
    EndStructure
    Global *ObjBox.BOXGADGETS            = AllocateMemory(SizeOf(BOXGADGETS)) 
    
    Structure EXT_WINDOWS
        x.i
        y.i
        w.i
        h.i
    EndStructure
    
    Global *r.EXT_WINDOWS            = AllocateMemory(SizeOf(EXT_WINDOWS))        
    
    
    
    ;******************************************************************************************************************************************
    ;   
    ; Button Procedure
    ;__________________________________________________________________________________________________________________________________________
    Procedure SetButton(ObjectID,X.i,Y.i,Text1$="",Text2$="",Text3$="",Style=0); (Style 0 = Default Button)
        
        Select Style
            Case 0
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_0H,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI11N) 
                
            Case 1
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_0H,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,SetColorBlue1,SetColorBlue2,Fonts::#_SEGOEUI10N)
                
            Case 2
                ButtonEX::Add(ObjectID,X.i,Y.i,30,30,                                   ; Close
                              DI::#_BTN_CLOSE_0N,
                              DI::#_BTN_CLOSE_0H,
                              DI::#_BTN_CLOSE_0P,
                              DI::#_BTN_CLOSE_0D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE))     
                
            Case 3
                ButtonEX::Add(ObjectID,X.i,Y.i,30,30,                                   ; Minimized
                              DI::#_BTN_MINIM_0N,
                              DI::#_BTN_MINIM_0H,
                              DI::#_BTN_MINIM_0P,
                              DI::#_BTN_MINIM_0D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE)) 
                
            Case 4
                ButtonEX::Add(ObjectID,X.i,Y.i,30,30,                                   ; Resize
                              DI::#_BTN_RESIZ_0N,
                              DI::#_BTN_RESIZ_0H,
                              DI::#_BTN_RESIZ_0P,
                              DI::#_BTN_RESIZ_0D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE))       
                
            Case 5
                ButtonEX::Add(ObjectID,X.i,Y.i,302,21,                                   ; Lisbox Sort Title
                              DI::#_BTN_LBOXT_N,
                              DI::#_BTN_LBOXT_H,
                              DI::#_BTN_LBOXT_P,
                              DI::#_BTN_LBOXT_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE),$F3AF64,Fonts::#_SEGOEUI11N)     
                
            Case 6
                ButtonEX::Add(ObjectID,X.i,Y.i,138,21,                                   ; Lisbox Sort Platform
                              DI::#_BTN_LBOXP_N,
                              DI::#_BTN_LBOXP_H,
                              DI::#_BTN_LBOXP_P,
                              DI::#_BTN_LBOXP_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE),$F3AF64,Fonts::#_SEGOEUI11N)                  
                
            Case 7
                ButtonEX::Add(ObjectID,X.i,Y.i,98,21,                                   ; Lisbox Sort Language
                              DI::#_BTN_LBOXL_N,
                              DI::#_BTN_LBOXL_H,
                              DI::#_BTN_LBOXL_P,
                              DI::#_BTN_LBOXL_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE),$F3AF64,Fonts::#_SEGOEUI11N)   
                
            Case 8
                ButtonEX::Add(ObjectID,X.i,Y.i,83,21,                                   ; Lisbox Sort Programm
                              DI::#_BTN_LBOXE_N,
                              DI::#_BTN_LBOXE_H,
                              DI::#_BTN_LBOXE_P,
                              DI::#_BTN_LBOXE_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE),$F3AF64,Fonts::#_SEGOEUI11N)    
                
            Case 9
                ButtonEX::Add(ObjectID,X.i,Y.i,30,30,                                   ; Screenshots Anzeigen/Verbergen
                              DI::#_BTN_SELECT_N,
                              DI::#_BTN_SELECT_H,
                              DI::#_BTN_SELECT_P,
                              DI::#_BTN_SELECT_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE))     
                
            Case 10
                ButtonEX::Add(ObjectID,X.i,Y.i,30,30,                                   ; Screenshots Anzeigen/Verbergen
                              DI::#_BTN_MENU_N,
                              DI::#_BTN_MENU_H,
                              DI::#_BTN_MENU_P,
                              DI::#_BTN_MENU_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE))   
                
            Case 11
                ButtonEX::Add(ObjectID,X.i,Y.i,20,20,                                   ; Floppy
                              DI::#_BTN_FLOPPY_N,
                              DI::#_BTN_FLOPPY_H,
                              DI::#_BTN_FLOPPY_P,
                              DI::#_BTN_FLOPPY_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE))                   
                
            Case 12
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_0H,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI10N) 
                
            Case 13
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI10N) 
                
            Case 14
                ButtonEX::Add(ObjectID,X.i,Y.i,170,20,
                              DI::#_BTN_BLUELITE_N,
                              DI::#_BTN_BLUELITE_H,
                              DI::#_BTN_BLUELITE_P,
                              DI::#_BTN_BLUELITE_D ,Text1$,Text2$,Text3$,RGB(28, 58, 119),RGB(7, 36, 153),Fonts::#_SEGOEUI10N) 
                
            Case 15
                ButtonEX::Add(ObjectID,X.i,Y.i,30,30,                                   ; Menu
                              DI::#_BTN_MENU_N,
                              DI::#_BTN_MENU_H,
                              DI::#_BTN_MENU_P,
                              DI::#_BTN_MENU_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE))       
                
                
            Case 16                                                                        ; Hover Left Side
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_1H,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI10N)       
                
            Case 17                                                                        ; Hover Both Side
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_2H,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI10N)                 
                
            Case 18                                                                        ; Hover Copy Left
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_LC,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI10N)      
                
            Case 19                                                                        ; Hover Copy Right
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_GREY4_0N,
                              DI::#_BTN_GREY4_RC,
                              DI::#_BTN_GREY4_0P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,RGB(255,255,255),$F3AF64,Fonts::#_SEGOEUI10N)
                
            Case 20
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_BLUELITE_N,
                              DI::#_BTN_BLUELITE_H,
                              DI::#_BTN_BLUELITE_P,
                              DI::#_BTN_BLUELITE_D ,Text1$,Text2$,Text3$,RGB(28, 58, 119),RGB(7, 36, 153),Fonts::#_SEGOEUI10N)                  
                
            Case 21
                ButtonEX::Add(ObjectID,X.i,Y.i,83,20,
                              DI::#_BTN_BLUELITE_N,
                              DI::#_BTN_BLUELITE_H,
                              DI::#_BTN_BLUELITE_P,
                              DI::#_BTN_GREY4_0D ,Text1$,Text2$,Text3$,$200F07,RGB(7, 36, 153),Fonts::#_SEGOEUI10N)                 
                
            Case 22
                ButtonEX::Add(ObjectID,X.i,Y.i,98,21, 
                              DI::#_BTN_TAB_N,
                              DI::#_BTN_TAB_H,
                              DI::#_BTN_TAB_P,
                              DI::#_BTN_TAB_D ,Text1$,Text2$,Text3$,RGB(113, 147, 165),$F3AF64,Fonts::#_SEGOEUI10N)                  
                
            Case 23
                ButtonEX::Add(ObjectID,X.i,Y.i,98,21,                                   ; Lisbox Sort Language
                              DI::#_BTN_LBOXL_N,
                              DI::#_BTN_LBOXL_H,
                              DI::#_BTN_SWT_P,
                              DI::#_BTN_LBOXL_D ,Text1$,Text2$,Text3$,GetSysColor_(#COLOR_3DFACE),$F3AF64,Fonts::#_SEGOEUI11N)                  
        EndSelect                 
        
        
    EndProcedure   
    ;******************************************************************************************************************************************
    ;__________________________________________________________________________________________________________________________________________       
    Procedure SetExtendLIst(lsObjectID)
        SendMessage_(GadgetID(lsObjectID),#LVM_SETEXTENDEDLISTVIEWSTYLE,0,#LVS_EX_LABELTIP|
                                                                          #LVS_EX_FULLROWSELECT|
                                                                          #LVS_EX_DOUBLEBUFFER|
                                                                          #LVS_EX_BORDERSELECT|
                                                                          #LVS_EX_FLATSB|
                                                                          #LVS_EX_TRANSPARENTSHADOWTEXT);|
                                                                                                        ;#LVS_EDITLABELS)
        
        FORM::GadgetClip(lsObjectID,#True)     
    EndProcedure      
    
    ;******************************************************************************************************************************************
    ;__________________________________________________________________________________________________________________________________________       
    Procedure SetExtendLIst1(lsObjectID)
        SendMessage_(GadgetID(lsObjectID),#LVM_SETEXTENDEDLISTVIEWSTYLE,0,#LVS_EX_LABELTIP|
                                                                          #LVS_EX_FULLROWSELECT|
                                                                          #LVS_EX_DOUBLEBUFFER|
                                                                          #LVS_EX_BORDERSELECT|
                                                                          #LVS_EX_FLATSB|
                                                                          #LVS_EX_TRANSPARENTSHADOWTEXT|
                                                                          #LVS_OWNERDRAWFIXED|
                                                                          #LVS_AUTOARRANGE)
        
    EndProcedure    
             
    ;******************************************************************************************************************************************
    ;  Gui_MiddleTop() /Titel/ Mitte
    ;__________________________________________________________________________________________________________________________________________    
    Procedure Gui_MiddleTop()       
        Protected nFont.l
        
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 10
        *ObjPos\h = 160        
        *ObjPos\x = 4    
        *ObjPos\y = 35        
        
        ContainerGadget(DC::#Contain_01, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,0)
        
        *ObjPos\x = 0
        *ObjPos\y = 35        
        *ObjPos\w = GadgetWidth(DC::#Contain_01)
        *ObjPos\h = 36
        c= RGB(120, 163, 188)
        ;
        ; Title
        ;
        nFont = Fonts::#_EUROSTILE_20        
        FORM::TextObject(DC::#Text_001,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,FontID(nFont),c,*ObjPos\c\rgb_strBckC,"",1)
        
        *ObjPos\y = GadgetHeight(DC::#Text_001) + GadgetY(DC::#Text_001) + 5
        FORM::TextObject(DC::#Text_002,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,FontID(nFont),c,*ObjPos\c\rgb_strBckC,"",1)           
        
        *ObjPos\x = GadgetWidth(DC::#Contain_01) - 210
        *ObjPos\y = GadgetHeight(DC::#Text_002) + GadgetY(DC::#Text_002) + 26
        *ObjPos\w = 100
        FORM::TextObject(DC::#Text_006,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,FontID(Fonts::#_EUROSTILE_18),RGB(88, 133, 155),*ObjPos\c\rgb_strBckC,"Release:",2)            
        
        *ObjPos\x = GadgetX(DC::#Text_006) + GadgetWidth(DC::#Text_006)
        FORM::TextObject(DC::#Text_007,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,FontID(Fonts::#_EUROSTILE_18),RGB(88, 133, 155),*ObjPos\c\rgb_strBckC,"",2)
        
        *ObjPos\x = 8
        *ObjPos\y = GadgetY(DC::#Text_006)
        *ObjPos\w = 200
        FORM::TextObject(DC::#Text_008,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,FontID(Fonts::#_EUROSTILE_18),RGB(88, 133, 155),*ObjPos\c\rgb_strBckC,"",0)
        
        CloseGadgetList()
        SetGadgetColor(DC::#Contain_01,#PB_Gadget_BackColor,*ObjPos\c\rgb_strBckC) 
    EndProcedure
    
    ;******************************************************************************************************************************************
    ;  Gui_MiddleTopTop() Einstellungen
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Gui_MiddleTopII()
        
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 6
        *ObjPos\h = 21        
        *ObjPos\x = 2    
        *ObjPos\y = GadgetHeight(DC::#Contain_01) + GadgetY(DC::#Contain_01) + 4
        
        ContainerGadget(DC::#Contain_09, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,0)
                
            *ObjPos\x = 2
            *ObjPos\y = 0        
            *ObjPos\w = 0
            *ObjPos\h = 0
            ;
            ; Listbox Button Sort Title 
            SetButton(DC::#Button_025,*ObjPos\x,*ObjPos\y,"Title","Title","Title",5)   
            
            *ObjPos\x = GadgetWidth(DC::#Button_025) + GadgetX(DC::#Button_025) + 4
            ;
            ; Listbox Button Sort Title 
            SetButton(DC::#Button_026,*ObjPos\x,*ObjPos\y,"Platform","Platform","Platform",6); 6        
            
            *ObjPos\x = GadgetWidth(DC::#Button_026) + GadgetX(DC::#Button_026) + 4
            ;
            ; Listbox Button Sort Title 
            SetButton(DC::#Button_027,*ObjPos\x,*ObjPos\y,"Language","Language","Language",7) 
            
            *ObjPos\x = GadgetWidth(DC::#Button_027) + GadgetX(DC::#Button_027) + 4
            ;
            ; Listbox Button Sort Title 
            SetButton(DC::#Button_028,*ObjPos\x,*ObjPos\y,"Program","Program","Program",7)  ;8            
        
        CloseGadgetList()
        SetGadgetColor(DC::#Contain_09,#PB_Gadget_BackColor,*ObjPos\c\rgb_61_61_61)         
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Gui_MiddleMiddle() Einstellungen
    ;__________________________________________________________________________________________________________________________________________    
    Procedure Gui_MiddleMiddle_Prefs()
        
        ;
        ; Farbe die Strings
        Protected RGB_FrntStR.i = *ObjPos\c\rgb_strFrCk        
        Protected RGB_BackStR.i = *ObjPos\c\rgb_54_54_54
        Protected Font_StR.i    = FontID(Fonts::#_SEGOEUI11N)
        ;
        ; Farbe der Texboxes
        Protected RGB_FrntTxt.i = *ObjPos\c\rgb_strFrCk        
        Protected RGB_BackTxT.i = *ObjPos\c\rgb_strBckC
        Protected Font_Txt.i    = FontID(Fonts::#_SEGOEUI10N)        
        
        *ObjPos\c\rgb_FocusFrnt_New = *ObjPos\c\rgb_250_250_250
        *ObjPos\c\rgb_FocusBack_New = *ObjPos\c\rgb_46_46_46
        *ObjPos\c\rgb_FocusFrnt_Old = RGB_FrntStR      
        *ObjPos\c\rgb_FocusBack_Old = RGB_BackStR         
        ;
        ;
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 8
        *ObjPos\h = 463 + Startup::*LHGameDB\WindowHeight       
        *ObjPos\x = 4  
        *ObjPos\y = GadgetHeight(DC::#Contain_01) + GadgetY(DC::#Contain_01) + 4
        
        ;
        ; 
        ;
        ContainerGadget(DC::#Contain_06, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,0)
        
            *ObjPos\x = 20      
            *ObjPos\y = 30
            *ObjPos\w = GadgetWidth(DC::#Contain_06) - (*ObjPos\x*2)
            *ObjPos\h = 20             
            
            ;
            ; Title
            FORM::StrgObject(DC::#String_001, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",1,1)
            FORM::TextObject(DC::#Text_011,   *ObjPos\x,*ObjPos\y-*ObjPos\h,*ObjPos\w,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Title",0)
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h*3)
            ;
            ; SubTitle
            FORM::StrgObject(DC::#String_002, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",1,1)
            FORM::TextObject(DC::#Text_012,   *ObjPos\x,*ObjPos\y-*ObjPos\h,*ObjPos\w,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Subtitle",0)            
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h*3)
            ;
            ; Sprache
            FORM::StrgObject(DC::#String_003, *ObjPos\x,*ObjPos\y,*ObjPos\w/3,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0 ,1)
            FORM::TextObject(DC::#Text_013,   *ObjPos\x,*ObjPos\y-*ObjPos\h,*ObjPos\w/3,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Language",0)             
            ;
            ; Platform
            FORM::StrgObject(DC::#String_004, *ObjPos\x + GadgetWidth(DC::#String_003)+4,*ObjPos\y,*ObjPos\w/3,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)
            FORM::TextObject(DC::#Text_014,   *ObjPos\x + GadgetWidth(DC::#String_003)+4,*ObjPos\y-*ObjPos\h,*ObjPos\w/3,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Platform",0)             
            ;
            ; Year            
            FORM::StrgObject(DC::#String_005, GadgetX(DC::#String_004) + GadgetWidth(DC::#String_004)+4,*ObjPos\y,*ObjPos\w/3-38,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",1,1)
            SendMessage_(GadgetID(DC::#String_005),#EM_LIMITTEXT,10,0)
            FORM::TextObject(DC::#Text_015,   GadgetX(DC::#String_004) + GadgetWidth(DC::#String_004)+4,*ObjPos\y-*ObjPos\h,*ObjPos\w/3-8,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Release",0)             
            FORM::DateObject(DC::#Calendar,   GadgetX(DC::#String_004) + GadgetWidth(DC::#String_004)+4,*ObjPos\y,*ObjPos\w/3-8,*ObjPos\h,Font_StR, RGB_FrntStR, RGB_BackStR,Startup::*LHGameDB\DateFormat,0,0 ,1)
            
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h*3)
            ;
            ; Start
            FORM::StrgObject(DC::#String_006, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",1,1)
            FORM::TextObject(DC::#Text_016,   *ObjPos\x,*ObjPos\y-*ObjPos\h,*ObjPos\w,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Start: Emulator/Port or Nativ",0)
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h*3)
            ;
            ; Commandline
            FORM::StrgObject(DC::#String_007, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",1,1)
            FORM::TextObject(DC::#Text_017,   *ObjPos\x,*ObjPos\y-*ObjPos\h,*ObjPos\w,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Commandline",0)            
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h*3) 
            ;
            ; Medium #1
            FORM::StrgObject(DC::#String_008, *ObjPos\x,*ObjPos\y,*ObjPos\w-24,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)
            FORM::TextObject(DC::#Text_018,   *ObjPos\x,*ObjPos\y-*ObjPos\h,*ObjPos\w,*ObjPos\h,Font_Txt,RGB_FrntTxt,RGB_BackTxT,"Device:0-3 (Floppy, HD, CD-Rom, Rom, Cartdrige, Tape)",0)             
            Setbutton(DC::#Button_103, GadgetX(DC::#String_008) + GadgetWidth(DC::#String_008)+4, *ObjPos\y,"","","",11)
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h+5)
            ;
            ; Medium #2
            FORM::StrgObject(DC::#String_009, *ObjPos\x,*ObjPos\y,*ObjPos\w-24,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)    
            Setbutton(DC::#Button_104, GadgetX(DC::#String_009) + GadgetWidth(DC::#String_009)+4, *ObjPos\y,"","","",11)
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h+5)
            ;
            ; Medium #3
            FORM::StrgObject(DC::#String_010, *ObjPos\x,*ObjPos\y,*ObjPos\w-24,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1) 
            Setbutton(DC::#Button_105, GadgetX(DC::#String_010) + GadgetWidth(DC::#String_010)+4, *ObjPos\y,"","","",11)            
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h+5)            
            ;
            ; Medium #4
            FORM::StrgObject(DC::#String_011, *ObjPos\x,*ObjPos\y,*ObjPos\w-24,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1) 
            Setbutton(DC::#Button_106, GadgetX(DC::#String_011) + GadgetWidth(DC::#String_011)+4, *ObjPos\y,"","","",11) 
            
            *ObjPos\y = *ObjPos\y + (*ObjPos\h+10)     
            ;
            ; File 1 für Medium 1 (z.b für WinVice)
            FORM::StrgObject(DC::#String_107, *ObjPos\x,*ObjPos\y,*ObjPos\w/4 -2,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)             
            
            *ObjPos\x = GadgetX(DC::#String_107) + GadgetWidth(DC::#String_107) +3  
            ;
            ; File 2 für Medium 2 (z.b für Hosx)
            FORM::StrgObject(DC::#String_108, *ObjPos\x,*ObjPos\y,*ObjPos\w/4-2,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)             
            
            *ObjPos\x = GadgetX(DC::#String_108) + GadgetWidth(DC::#String_108) +4             
            ;
            ; File 2 für Medium 3 (z.b für FREI)
            FORM::StrgObject(DC::#String_109, *ObjPos\x,*ObjPos\y,*ObjPos\w/4 -2,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)             
            
            *ObjPos\x = GadgetX(DC::#String_109) + GadgetWidth(DC::#String_109) +3             
            ;
            ; File 3 für Medium 4 (z.b für FREI)
            FORM::StrgObject(DC::#String_110, *ObjPos\x,*ObjPos\y,*ObjPos\w/4 -2,*ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",0,1)
        
        CloseGadgetList()
        SetGadgetColor(DC::#Contain_06,#PB_Gadget_BackColor,*ObjPos\c\rgb_strBckC)   
        
    EndProcedure
    
    ;******************************************************************************************************************************************
    ;  Gui_MiddleMiddle() Hauptliste
    ;__________________________________________________________________________________________________________________________________________    
    Procedure Gui_MiddleMiddle()
        
        Protected nFont.l
        
        Gui_MiddleMiddle_Prefs()
        
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 10
        *ObjPos\h = 236 + Startup::*LHGameDB\WindowHeight;436       
        *ObjPos\x = 4    
        *ObjPos\y = 224        
        
        ContainerGadget(DC::#Contain_02, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,0): Form::GadgetClip(DC::#Contain_02,#True)
        
            *ObjPos\x = 0
            *ObjPos\y = 160        
            *ObjPos\w = GadgetWidth(DC::#Contain_02)
            *ObjPos\h = 32
            
            ;
            ; Zeige Anzahl beim Laden
            ;
            FORM::TextObject(DC::#Text_003,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,FontID(Fonts::#_EUROSTILE_20),*ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_61_61_61,"",1)
            HideGadget(DC::#Text_003,1)
            ;
            ; Hauptliste
            ;
            *ObjPos\x = 0
            *ObjPos\y = 0       
            *ObjPos\w = GadgetWidth(DC::#Contain_02)
            *ObjPos\h = GadgetHeight(DC::#Contain_02)
            
            nFont = Fonts::#DEJAVUSANS_MONO_09           
            
            FORM::ListObject(DC::#ListIcon_001,*ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h + Startup::*LHGameDB\WindowHeight,FontID(nFont),0, 2, "", 0, *ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_strBckC) ;Path Liste
            SetExtendLIst(DC::#ListIcon_001)
            
            ;
            SetGadgetItemAttribute(DC::#ListIcon_001,0,#PB_ListIcon_ColumnWidth,302,0):
            AddGadgetColumn(DC::#ListIcon_001,1,"",142); 142  
            AddGadgetColumn(DC::#ListIcon_001,2,"",102)          
            AddGadgetColumn(DC::#ListIcon_001,3,"",98) ; 81
            
            ;
            ; ListIcon Sortiermodus Aktiveren
            LVSORTEX::ListIconSortAddGadget(DC::#ListIcon_001,LVSORTEX::#ListIcon_Sort_Up) 
            ;
            ;
            CloseGadgetList()        
        SetGadgetColor(DC::#Contain_02,#PB_Gadget_BackColor,*ObjPos\c\rgb_CntBckC)          
        HideGadget(DC::#Contain_06,1)
        
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Gui_MiddleMiddle_Screens() /
    ;__________________________________________________________________________________________________________________________________________        
    
    Procedure Gui_MiddleMiddle_Screens()
        Protected ObjPosSpace.i, w.i,h.i 
        
        
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 10
        *ObjPos\h = 198 + Startup::*LHGameDB\WindowHeight       
        *ObjPos\x = 4    
        *ObjPos\y = WindowHeight(DC::#_Window_001) - 256         
        ObjPosSpace.i = 4        
        
        ScrollAreaGadget(DC::#Contain_10, *ObjPos\x,*ObjPos\y,*ObjPos\w, *ObjPos\h,*ObjPos\w-24,4,0,#PB_ScrollArea_BorderLess)
            *ObjPos\w = Startup::*LHGameDB\wScreenShotGadget
            *ObjPos\h = Startup::*LHGameDB\hScreenShotGadget        
            *ObjPos\y = 0
            ObjPosSpace.i = 4  
            
            ; PUrebasic Gadget ID's in ide Structure Legen
            
            ; Purebasic Gadgets ID, 6 Screen Shots Slots
            
            x.i   = 0
            Max.i = Startup::*LHGameDB\MaxScreenshots
            
            For n = DC::#ScreenShot_001 To (DC::#ScreenShot_001 + Max) -1
                ;
                ; Beginne ab 1
                x + 1 
                ;
                ; Sezte die Purebasic in die Strukture, Siehe Constants
                Startup::*LHImages\ScreenGDID[x] = n
            Next    
            
            ; Purebasic Screen SHots Copy ID'S
            x.i = 0
            For n = DC::#_PNG_COPY1 To (DC::#_PNG_COPY1 + Max) -1
                ;
                ; Beginne ab 1
                x + 1 
                ;
                ; Sezte die Purebasic in die Strukture, Siehe Constants
                Startup::*LHImages\CpScreenPB[x] = n
            Next          
            
            ;
            ; Purebasic Screen SHots Copy ID'S
            x.i = 0
            For n = DC::#_PNG_ORGY1 To (DC::#_PNG_ORGY1 + Max) -1
                ;
                ; Beginne ab 1
                x + 1 
                ;
                ; Sezte die Purebasic in die Strukture, Siehe Constants
                Startup::*LHImages\OrScreenPB[x] = n
            Next                         
            
            ;
            ; Lege die Screenshots in die "Elemente"
            vImages::NoScreens_Prepare() 
            
            For  n = 1 To Max
                ImageGadget(Startup::*LHImages\ScreenGDID[n],*ObjPos\x,*ObjPos\y ,*ObjPos\w,*ObjPos\h,0)
            Next    
            
            vImages::Screens_SetThumbnails(4,4) 
        
        CloseGadgetList()
        
        SetGadgetColor(DC::#Contain_10,#PB_Gadget_BackColor,*ObjPos\c\rgb_strBckC)
        
        FORM::GadgetClip(DC::#Contain_10,#True)       
    EndProcedure    
    
    ;******************************************************************************************************************************************
    ;  Gui_MiddleBottom() / Button Liste
    ;__________________________________________________________________________________________________________________________________________    
    Procedure Gui_MiddleBottom_Alternate()
        Protected ObjPosSpace.i 
        
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 10
        *ObjPos\h = 30        
        *ObjPos\x = 4    
        *ObjPos\y = WindowHeight(DC::#_Window_001) - 54         
        ObjPosSpace.i = 4
        
        ContainerGadget(DC::#Contain_07, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,0)
        *ObjPos\x = 0
        *ObjPos\y = 0        
        *ObjPos\w = 0
        *ObjPos\h = 0
        ;
        ; OK Button for Edit
        SetButton(DC::#Button_020,*ObjPos\x,*ObjPos\y,"Language","Language","Language")           
        
        *ObjPos\x = GadgetX(DC::#Button_020) + GadgetWidth(DC::#Button_020) + ObjPosSpace
        SetButton(DC::#Button_021,*ObjPos\x,*ObjPos\y,"Platform","Platform","Platform")
        
        *ObjPos\x = GadgetX(DC::#Button_021) + GadgetWidth(DC::#Button_020) + ObjPosSpace
        SetButton(DC::#Button_022,*ObjPos\x,*ObjPos\y,"Program","Program","Program")            
        
        *ObjPos\x = GadgetX(DC::#Button_022) + GadgetWidth(DC::#Button_020) + ObjPosSpace
        SetButton(DC::#Button_023,*ObjPos\x,*ObjPos\y,"Update","Update","Update")
        
        ;*ObjPos\x = GadgetX(DC::#Button_023) + GadgetWidth(DC::#Button_020) + ObjPosSpace
        ;SetButton(DC::#Button_033,*ObjPos\x,*ObjPos\y,"C64 Inhalt","C64 Inhalt","C64 Inhalt")            
        
        *ObjPos\x = GadgetWidth(DC::#Contain_07) - GadgetWidth(DC::#Button_022) 
        SetButton(DC::#Button_024,*ObjPos\x,*ObjPos\y,"Cancel","Cancel","Cancel")               
        CloseGadgetList()
        SetGadgetColor(DC::#Contain_07,#PB_Gadget_BackColor,*ObjPos\c\rgb_backgrd)    
        HideGadget(DC::#Contain_07,1)
    EndProcedure   
    ;******************************************************************************************************************************************
    ;  Gui_MiddleBottom() / Button Liste
    ;__________________________________________________________________________________________________________________________________________    
    Procedure Gui_MiddleBottom()
        Protected ObjPosSpace.i, ObjSpace.i
        
        Gui_MiddleBottom_Alternate()
        
        *ObjPos\w = WindowWidth(DC::#_Window_001) - 10
        *ObjPos\h = 30        
        *ObjPos\x = 4 
        *ObjPos\y = WindowHeight(DC::#_Window_001) - 54        
        ObjPosSpace.i = 4
        
        ContainerGadget(DC::#Contain_03, *ObjPos\x,*ObjPos\y,*ObjPos\w,*ObjPos\h,0)
            *ObjPos\x = 0
            *ObjPos\y = 0        
            *ObjPos\w = 0
            *ObjPos\h = 0
            
            SetButton(DC::#Button_010,*ObjPos\x,*ObjPos\y,"New","New","New")
            
            *ObjPos\x = GadgetX(DC::#Button_010) + GadgetWidth(DC::#Button_010) + ObjPosSpace
            SetButton(DC::#Button_011,*ObjPos\x,*ObjPos\y,"Duplicate","Duplicate","Duplicate")
            
            *ObjPos\x = GadgetX(DC::#Button_011) + GadgetWidth(DC::#Button_011) + ObjPosSpace
            SetButton(DC::#Button_012,*ObjPos\x,*ObjPos\y,"Delete","Delete","Delete")
            
            *ObjPos\x = GadgetX(DC::#Button_012) + GadgetWidth(DC::#Button_011) + ObjPosSpace
            SetButton(DC::#Button_013,*ObjPos\x,*ObjPos\y,"Edit","Edit","Edit") 
                    
            ;             
            ;             *ObjPos\x = GadgetX(DC::#Button_016) + GadgetWidth(DC::#Button_011) + ObjPosSpace
            ;             SetButton(DC::#Button_017,*ObjPos\x,*ObjPos\y,"Thumb-","Thumb-","Thumb-")             
            
            *ObjPos\x = GadgetWidth(DC::#Contain_03) - GadgetWidth(DC::#Button_013) 
            SetButton(DC::#Button_014,*ObjPos\x,*ObjPos\y,"Start","Start","Start")               

            ObjSpace = Abs(  GadgetX(DC::#Button_013) + GadgetWidth(DC::#Button_013) - GadgetX(DC::#Button_014) /2 )
            
            ;
            ; Info Window Button
            *ObjPos\x = GadgetX(DC::#Button_013) + GadgetWidth(DC::#Button_011) + ObjPosSpace + ObjSpace
            SetButton(DC::#Button_016,*ObjPos\x,*ObjPos\y,"Infos","Infos","Infos",23)
            ButtonEX::Toggle(DC::#Button_016, 0)
            
            CloseGadgetList()
        SetGadgetColor(DC::#Contain_03,#PB_Gadget_BackColor,*ObjPos\c\rgb_backgrd)  
    EndProcedure     
    
    ;******************************************************************************************************************************************
    ;         
    ;__________________________________________________________________________________________________________________________________________    
    Procedure SetGuiObjects()     
        
        ;
        ; Close, Minimzed
        ; Button 3 - 9 Frei
        SetButton(DC::#Button_001,WindowWidth(DC::#_Window_001) - 30 ,0,"","","",2) ; Close
        SetButton(DC::#Button_002,WindowWidth(DC::#_Window_001) - 60 ,0,"","","",3) ; Minimized  
        
        FORM::TextObject(DC::#Text_005,10,5, WindowWidth(DC::#_Window_001) - 90,20,FontID(Fonts::#_SEGOEUI11N),RGB(113, 147, 165),$1F1F1F,Startup::*LHGameDB\TitleVersion ,0)
        
        FORM::TextObject(DC::#Text_004,20,WindowHeight(DC::#_Window_001) - 24,WindowWidth(DC::#_Window_001)-30,20,FontID(Fonts::#_SEGOEUI10N),*ObjPos\c\rgb_strFrCk,$1F1F1F,"",0)
        
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;         
    ;__________________________________________________________________________________________________________________________________________
    Procedure Gui_MiddleMiddle_Combine()        
        SplitterGadgetEx::SplitterGadgetEx(DC::#Splitter1, 4,224,WindowWidth(DC::#_Window_001) - 10,438+Startup::*LHGameDB\WindowHeight,DC::#Contain_02, DC::#Contain_10, SplitterGadgetEx::#SplitBar_Default, 4)
        SetGadgetColor(DC::#Splitter1, #PB_Gadget_BackColor, *ObjPos\c\rgb_51_51_51)
        SetGadgetColor(DC::#Splitter1, #PB_Gadget_FrontColor, *ObjPos\c\rgb_46_46_46)
        ;
        ; Setzen der Höhe anhande der Infor aus der DB
        VEngine::Splitter_SetGet(#True): vImages::Screens_Show(): FORM::GadgetClip(DC::#Splitter1,#True)                  
    EndProcedure    
    
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________    
    Procedure SetGuiWindow()
        Protected Flags.l, FlagsEX.l, DeskX.i, DeskY.i
        
        Flags.l   = #PB_Window_Invisible|                  
                    ; #WS_SIZEBOX       |
                    ; #WS_MAXIMIZEBOX   |
                    #WS_MINIMIZEBOX     |
                    #WS_POPUPWINDOW     
                        
        WinGuru::Style(DC::#_Window_001,0 ,0 ,658 ,720 + Startup::*LHGameDB\WindowHeight ,Flags ,RGB(61,61,61) ,#True, #True, #True, #Null ,#True,#False)
        
        
        Gui_MiddleTop()   
        Gui_MiddleTopII()      
        Gui_MiddleMiddle()
        Gui_MiddleMiddle_Screens()          
        Gui_MiddleMiddle_Combine()
        Gui_MiddleBottom()        
        SetGuiObjects()
        
        
        
        ;MameStruct::SetDebugLog("SUCCESSFULL: "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line)) 
        ;
        ; Read WindowPosition
        Startup::*LHGameDB\WindowPosition\X = ExecSQL::iRow(DC::#Database_001,"Settings","WPosX",0,1,"",1)
        Startup::*LHGameDB\WindowPosition\Y = ExecSQL::iRow(DC::#Database_001,"Settings","WPosY",0,1,"",1)
        Startup::*LHGameDB\InfoWindow\bSide = ExecSQL::iRow(DC::#Database_001,"Settings","DockWindow",0,1,"",1)
        
        WinGuru::WindowPosition(DC::#_Window_001,Startup::*LHGameDB\WindowPosition\X,Startup::*LHGameDB\WindowPosition\Y)        
        
        ;HideWindow(DC::#_Window_001,0) 
        
        Set_Tooltypes()
    EndProcedure
    
    
    Procedure.i InteractiveGadgets_Window_004_Def(Resize.i = 0, SnapHeight = 30)
        
        
        Protected ObjPosSpace.i
        
        *ObjPos\x = 0 
        *ObjPos\y = SnapHeight                  
        *ObjPos\w = *r\w
        *ObjPos\h = *r\h        
        ObjPosSpace.i = 4
        
        Select Resize
                ;
                ; Build Mode
            Case 0                               
                ScrollAreaGadget(DC::#Contain_11, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h-(*ObjPos\y*2),1,1,1,#PB_ScrollArea_BorderLess|#PB_ScrollArea_Center)
                ;Form::GadgetClip(DC::#Contain_11,#True)
                
                
                *ObjPos\x = 0 
                *ObjPos\y = 0
                *ObjPos\w = GadgetWidth(DC::#Contain_11)
                *ObjPos\h = GadgetHeight(DC::#Contain_11)                
                
                ImageGadget(DC::#ImageCont11,0,0,1,1,0)
                Form::GadgetClip(DC::#Contain_11,#True)                
                
                CloseGadgetList()
                SetGadgetColor(DC::#Contain_11,#PB_Gadget_BackColor,*ObjPos\c\rgb_backgrd)  
                ;
                ; Resize Mode
            Case 1               
                ResizeGadget(DC::#Contain_11    ,#PB_Ignore, SnapHeight, *r\w, *r\h-60)                    
                
        EndSelect        
    EndProcedure     
    ;******************************************************************************************************************************************
    ;  Fenster Für Infos und Texte
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i InteractiveGadgets_Window_006_Def(Resize.i = 0, SnapHeight = 30)
        
        Protected ObjPosSpace.i, DesignControl1.i = DC::#DesignBox005 , nFont.l
        
        *ObjPos\x = 0 
        *ObjPos\y = SnapHeight                  
        *ObjPos\w = *r\w
        *ObjPos\h = *r\h        
        ObjPosSpace.i = 4
        nFont.l = FontID(Fonts::#PC_Clone_09)
        ; String für die Text Dateien
          Protected RGB_FrntStR.i = *ObjPos\c\rgb_strFrCk        
          Protected RGB_BackStR.i = *ObjPos\c\rgb_54_54_54
          Protected Font_StR.i    = FontID(Fonts::#_SEGOEUI10N)    
                        
        Select Resize
                ;
                ; Build Mode
            Case 0                               
                ContainerGadget(DC::#Contain_14, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h-(*ObjPos\y*2),0) 
                
                    *ObjPos\x = ObjPosSpace
                    *ObjPos\y = ObjPosSpace                 
                    *ObjPos\w = 0
                    *ObjPos\h = 0              
                    
                    SetButton(DC::#Button_283,*ObjPos\x,*ObjPos\y,"General Info","General Info","General Info",22)
                    
                    *ObjPos\x = GadgetX( DC::#Button_283 ) + GadgetWidth( DC::#Button_283 ) +ObjPosSpace
                    *ObjPos\y = ObjPosSpace
                    *ObjPos\w = 0
                    *ObjPos\h = 0                 
                    SetButton(DC::#Button_284,*ObjPos\x,*ObjPos\y,"Overview","Overview","Overview",22)                
                    
                    *ObjPos\x = GadgetX( DC::#Button_284 ) + GadgetWidth( DC::#Button_284 ) +ObjPosSpace
                    *ObjPos\y = ObjPosSpace
                    *ObjPos\w = 0
                    *ObjPos\h = 0                 
                    SetButton(DC::#Button_285,*ObjPos\x,*ObjPos\y,"Trivia","Trivia","Trivia",22)  
                    
                    *ObjPos\x = GadgetX( DC::#Button_285 ) + GadgetWidth( DC::#Button_285 ) +ObjPosSpace
                    *ObjPos\y = ObjPosSpace
                    *ObjPos\w = 0
                    *ObjPos\h = 0                 
                    SetButton(DC::#Button_286,*ObjPos\x,*ObjPos\y,"Additional","Additional","Additional",22) 
                    
                    ButtonEX::Toggle(DC::#Button_283, 0)                
                    ButtonEX::Toggle(DC::#Button_284, 0)  
                    ButtonEX::Toggle(DC::#Button_285, 0)                
                    ButtonEX::Toggle(DC::#Button_286, 0)                 
                    
                    ; Strich, Dieser Container Dient Lediglich als Optic
                        *ObjPos\x = ObjPosSpace
                        *ObjPos\y = GadgetY( DC::#Button_283 ) + GadgetHeight( DC::#Button_283 ) +ObjPosSpace               
                        *ObjPos\w = GadgetWidth( DC::#Contain_14 )
                        *ObjPos\h = 0   
                        ContainerGadget(DC::#DesignBox005, *ObjPos\x,*ObjPos\y, *ObjPos\w, 2,0) 
                        CloseGadgetList()
                        SetGadgetColor(DC::#DesignBox005,#PB_Gadget_BackColor,$1F1F1F)    
                        
                     ;
                     ; Info Editor Eigenschaften
                        *ObjPos\x = GadgetX     ( DC::#DesignBox005 )
                        *ObjPos\y = GadgetY     ( DC::#DesignBox005 )+ GadgetHeight( DC::#DesignBox005 )
                        *ObjPos\w = GadgetWidth ( DC::#DesignBox005 )
                        *ObjPos\h = GadgetHeight( DC::#Contain_14   ) - 60  
                        
                     ; Info Editor 1
                        ContainerGadget(DC::#Contain_16, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\w,0)                                                
                        
                        
                            FORM::EditObject(DC::#Text_128,0,0,GadgetWidth ( DC::#Contain_16 ),GadgetHeight ( DC::#Contain_16 ),nFont,*ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_61_61_61,0,0,1) 
                            Form::GadgetClip(DC::#Text_128,#True)                        
                        CloseGadgetList()
                        
                        Form::GadgetClip(DC::#Contain_16,#True)                        
                        SetGadgetColor(DC::#Contain_16,#PB_Gadget_BackColor,*ObjPos\c\rgb_58_58_58)
                        
                        HideGadget( DC::#Contain_16,1 )
                        
                     ; Info Editor 2
                        ContainerGadget(DC::#Contain_17, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\w,0)   
                          
                            FORM::EditObject(DC::#Text_129,0,0,GadgetWidth ( DC::#Contain_17 ),GadgetHeight ( DC::#Contain_17 ),nFont,*ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_61_61_61,0,0,1) 
                            Form::GadgetClip(DC::#Text_129,#True)                        
                        CloseGadgetList()
                            
                        Form::GadgetClip(DC::#Contain_17,#True)                            
                        SetGadgetColor(DC::#Contain_17,#PB_Gadget_BackColor,*ObjPos\c\rgb_58_58_58)
                        
                        HideGadget( DC::#Contain_17,1 )                        
                        
                     ; Info Editor 3
                        ContainerGadget(DC::#Contain_18, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\w,0) 
                         
                            FORM::EditObject(DC::#Text_130,0,0,GadgetWidth ( DC::#Contain_18 ),GadgetHeight ( DC::#Contain_18 ),nFont,*ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_61_61_61,0,0,1) 
                            Form::GadgetClip(DC::#Text_130,#True)                        
                        CloseGadgetList()
                            
                        Form::GadgetClip(DC::#Contain_18,#True)                              
                        SetGadgetColor(DC::#Contain_18,#PB_Gadget_BackColor,*ObjPos\c\rgb_58_58_58)
                        
                        HideGadget( DC::#Contain_18,1 )                         
                        
                     ; Info Editor 3
                        ContainerGadget(DC::#Contain_19, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\w,0)                                                 
                          
                            FORM::EditObject(DC::#Text_131,0,0,GadgetWidth ( DC::#Contain_19 ),GadgetHeight ( DC::#Contain_19 ),nFont,*ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_61_61_61,0,0,1)
                            Form::GadgetClip(DC::#Text_131, #True)                        
                        CloseGadgetList()                        

                        Form::GadgetClip(DC::#Contain_19, #True) 
                        
                        SetGadgetColor(DC::#Contain_19,#PB_Gadget_BackColor,*ObjPos\c\rgb_58_58_58)
                        
                        HideGadget( DC::#Contain_19,1 )                          
                        
                    ; Strich, Dieser Container Dient Lediglich als Optic
                        *ObjPos\x = GadgetX( DC::#DesignBox005)
                        *ObjPos\y = GadgetY( DC::#Contain_16 ) + GadgetHeight( DC::#Contain_16 )
                        *ObjPos\w = GadgetWidth ( DC::#DesignBox005 )
                        *ObjPos\h = GadgetHeight( DC::#DesignBox005 ) 
                        ContainerGadget(DC::#DesignBox006, *ObjPos\x,*ObjPos\y, *ObjPos\w, 2,0) 
                        CloseGadgetList()
                        SetGadgetColor(DC::#DesignBox006,#PB_Gadget_BackColor,$1F1F1F)   
                        
                    ; String für die Text Dateien                         
                        
                        *ObjPos\x = GadgetX( DC::#DesignBox005)
                        *ObjPos\y = GadgetY(DC::#DesignBox006) + GadgetHeight(DC::#DesignBox006) + ObjPosSpace
                        *ObjPos\w = GadgetWidth(DC::#Contain_16)
                        *ObjPos\h = 20                          
                        FORM::StrgObject(DC::#String_112,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"",1,1)                        
                        
                CloseGadgetList()
                SetGadgetColor(DC::#Contain_14,#PB_Gadget_BackColor,*ObjPos\c\rgb_58_58_58)
                FORM::GadgetClip(DC::#Contain_19,#True)
                
                        *ObjPos\x = 4
                        *ObjPos\y = WindowHeight(DC::#_Window_006) -25
                        *ObjPos\w = WindowWidth( DC::#_Window_006)-80     
                        
                FORM::TextObject(DC::#Text_132, *ObjPos\x ,*ObjPos\y ,*ObjPos\w ,20 , FontID(Fonts::#_SEGOEUI10N),RGB(113, 147, 165),$1F1F1F,"" ,0) ;$1F1F1F
                        
                        *ObjPos\x = WindowWidth( DC::#_Window_006)-80
                        *ObjPos\w = 60
                        
                FORM::TextObject(DC::#Text_133, *ObjPos\x ,*ObjPos\y ,*ObjPos\w ,20 , FontID(Fonts::#_SEGOEUI10N),RGB(113, 147, 165),$1F1F1F,"" ,0)                
                

 
                ;
                ; Resize Mode
            Case 1
                                    
                ResizeGadget(DC::#Contain_14    ,#PB_Ignore, SnapHeight, *r\w, *r\h-60)
                
                *ObjPos\x = GadgetWidth( DC::#Contain_14  ) - ( ( GadgetWidth( DC::#Button_283  ) +ObjPosSpace) *4 )                             
                *ObjPos\y = ObjPosSpace +2                
                *ObjPos\w = GadgetWidth( DC::#Button_283  )
                *ObjPos\h = 0                              
                
                ResizeGadget(DC::#Button_283    ,*ObjPos\x/2+2, *ObjPos\y, #PB_Ignore,  #PB_Ignore)
                                
                *ObjPos\x =  GadgetX( DC::#Button_283 ) + GadgetWidth( DC::#Button_283 ) +ObjPosSpace             
                ResizeGadget(DC::#Button_284    ,*ObjPos\x, *ObjPos\y, #PB_Ignore,  #PB_Ignore) 
                
                *ObjPos\x =  GadgetX( DC::#Button_284 ) + GadgetWidth( DC::#Button_284 ) +ObjPosSpace                     
                ResizeGadget(DC::#Button_285    ,*ObjPos\x, *ObjPos\y, #PB_Ignore,  #PB_Ignore)                  
                
                *ObjPos\x =  GadgetX( DC::#Button_285 ) + GadgetWidth( DC::#Button_285 ) +ObjPosSpace                 
                ResizeGadget(DC::#Button_286    ,*ObjPos\x , *ObjPos\y, #PB_Ignore,  #PB_Ignore)                                  
                
                ; Strich
                *ObjPos\x = ObjPosSpace
                *ObjPos\y = GadgetY( DC::#Button_283 ) + GadgetHeight( DC::#Button_283 )*2 + ObjPosSpace+20               
                *ObjPos\w = GadgetWidth( DC::#Contain_14 )- 8
                *ObjPos\h = 0                 
                ResizeGadget(DC::#DesignBox005 ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  #PB_Ignore)         
                
                *ObjPos\x = GadgetX     ( DC::#DesignBox005 )
                *ObjPos\y = GadgetY     ( DC::#DesignBox005 )+ GadgetHeight( DC::#DesignBox005 )
                *ObjPos\w = GadgetWidth ( DC::#DesignBox005 )
                *ObjPos\h = GadgetHeight( DC::#Contain_14   ) - 60                
                ResizeGadget(DC::#Contain_16   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)                  
                ResizeGadget(DC::#Contain_17   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)    
                ResizeGadget(DC::#Contain_18   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)    
                ResizeGadget(DC::#Contain_19   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)                    
                
                *ObjPos\x = 0
                *ObjPos\y = 0
                *ObjPos\w = GadgetWidth ( DC::#Contain_16 )
                *ObjPos\h = GadgetHeight( DC::#Contain_16 )                   
                ResizeGadget(DC::#Text_128   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)
                ResizeGadget(DC::#Text_129   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)
                ResizeGadget(DC::#Text_130   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)
                ResizeGadget(DC::#Text_131   ,#PB_Ignore , #PB_Ignore, *ObjPos\w ,  *ObjPos\h)
                
                ; Strich
                *ObjPos\y = GadgetY     ( DC::#Contain_16 )+ GadgetHeight( DC::#Contain_16 )                
                *ObjPos\w = GadgetWidth ( DC::#DesignBox005 )
                ResizeGadget(DC::#DesignBox006 ,#PB_Ignore , *ObjPos\y , *ObjPos\w ,   #PB_Ignore)                 
                
                *ObjPos\x = GadgetX(DC::#DesignBox005)
                *ObjPos\y = GadgetY(DC::#DesignBox006) + GadgetHeight(DC::#DesignBox006) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#Contain_16)
                *ObjPos\h = 20                          
                ResizeGadget(DC::#String_112,#PB_Ignore,*ObjPos\y, *ObjPos\w, #PB_Ignore )   
                
                 *ObjPos\w = WindowWidth( DC::#_Window_006)-80
                 *ObjPos\y = WindowHeight(DC::#_Window_006) -25
                 
                 ResizeGadget(DC::#Text_132,#PB_Ignore,*ObjPos\y ,*ObjPos\w , #PB_Ignore )
                 
                 *ObjPos\x = WindowWidth( DC::#_Window_006)-80
                 
                ResizeGadget(DC::#Text_133,*ObjPos\x, *ObjPos\y,#PB_Ignore, #PB_Ignore )                              

        EndSelect        
    EndProcedure     
    ;******************************************************************************************************************************************
    ;  Fenster Für das Disketten Image
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i InteractiveGadgets_Window_005_Def(Resize.i = 0, SnapHeight = 30)
        
        Protected ObjPosSpace.i
        
        *ObjPos\x = 0 
        *ObjPos\y = SnapHeight                  
        *ObjPos\w = *r\w
        *ObjPos\h = *r\h        
        ObjPosSpace.i = 4
        Select Resize
                ;
                ; Build Mode
            Case 0                               
                ContainerGadget(DC::#Contain_12, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h-(*ObjPos\y*2),0) 
                
                
                If ( Startup::*LHGameDB\CBMFONT = 0 )
                    Startup::*LHGameDB\CBMFONT = FontID(Fonts::#_C64_CHARS)
                EndIf
                ;WinGuru::ThemeBox(-1,GadgetWidth(DC::#Contain_12)-40, GadgetHeight(DC::#Contain_12)-165, 20, 0, *ObjPos\c\rgb_C64Screen, BoxC.l) 
                ;
                ;
                ;
                ; Farbe die Strings
                Protected RGB_FrntStR.i = *ObjPos\c\rgb_StrinFC       
                Protected RGB_BackStR.i = *ObjPos\c\rgb_C64_BG2
                Protected Font_StR.i    = FontID(Fonts::#_FIXPLAIN7_12)  
                
                ;
                ; C64 Disk Label Header = Bytes
                *ObjPos\x = 40 
                *ObjPos\y = 8                  
                *ObjPos\w = 48
                *ObjPos\h = 12                                                   
                FORM::TextObject(DC::#Text_121,  *ObjPos\x,  *ObjPos\y,   *ObjPos\w, *ObjPos\h, Font_StR.i ,*ObjPos\c\rgb_C64_Front2,*ObjPos\c\rgb_C64_BG3.i," 999",0)
                
                ;
                ; C64 Disk Label Header = Label                    
                *ObjPos\x = GadgetX(DC::#Text_121) + GadgetWidth(DC::#Text_121)                 
                *ObjPos\w = GadgetWidth(DC::#Contain_12)-208                                  
                FORM::StrgObject(DC::#Text_122,  *ObjPos\x,  *ObjPos\y,   *ObjPos\w, *ObjPos\h, Startup::*LHGameDB\CBMFONT ,*ObjPos\c\rgb_C64_BG3,*ObjPos\c\rgb_C64_Front2 ,"Disk Label",1,1)
                
                ;
                ; C64 Disk Label Header = ID                        
                *ObjPos\x = GadgetX(DC::#Text_122) + GadgetWidth(DC::#Text_122)                 
                *ObjPos\w = 80                                             
                FORM::TextObject(DC::#Text_123,   *ObjPos\x,  *ObjPos\y,   *ObjPos\w, *ObjPos\h, Startup::*LHGameDB\CBMFONT ,*ObjPos\c\rgb_C64_Front2,*ObjPos\c\rgb_C64_BG3.i," 2A 2A",0)
                
                ;
                ; Listbox
                *ObjPos\x = 40 
                *ObjPos\y = 20                  
                *ObjPos\w = GadgetWidth(DC::#Contain_12)-80
                *ObjPos\h = GadgetHeight(DC::#Contain_12)-295
                Form::ListObject(DC::#ListIcon_003, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Startup::*LHGameDB\CBMFONT, 0, 2, "", 0, *ObjPos\c\rgb_C64_Front2,*ObjPos\c\rgb_C64_BG3, #PB_ListIcon_MultiSelect|#LVS_OWNERDRAWFIXED)
                
                SendMessage_(GadgetID(DC::#ListIcon_003),#LVM_SETEXTENDEDLISTVIEWSTYLE,0,#LVS_EX_LABELTIP| #LVS_EX_FULLROWSELECT) 
                AddGadgetColumn(DC::#ListIcon_003, 0,"",92)
                AddGadgetColumn(DC::#ListIcon_003, 1,"",190)
                AddGadgetColumn(DC::#ListIcon_003, 2,"",52)
                EnableWindow_(SendMessage_(GadgetID(DC::#ListIcon_003),#LVM_GETHEADER,#Null,#Null),0) ; Header Breite Fixieren                                                                                        
                
                RGB_FrntStR.i = *ObjPos\c\rgb_strFrCk        
                RGB_BackStR.i = *ObjPos\c\rgb_54_54_54
                Font_StR.i    = FontID(Fonts::#_SEGOEUI10N)                         
                *ObjPos\x = 40
                *ObjPos\y = GadgetHeight(DC::#ListIcon_003) +  GadgetY(DC::#ListIcon_003)
                *ObjPos\w = GadgetWidth(DC::#ListIcon_003)
                *ObjPos\h = 12            
                
                FORM::TextObject(DC::#Text_124,  *ObjPos\x,  *ObjPos\y,   *ObjPos\w, *ObjPos\h, FontID(Fonts::#_FIXPLAIN7_12) ,*ObjPos\c\rgb_C64_BG3,*ObjPos\c\rgb_C64_Front2," --- blocks Free",0)                    
                
                *ObjPos\x = 0
                *ObjPos\y = GadgetHeight(DC::#Text_124) +  GadgetY(DC::#Text_124) + ObjPosSpace + 8
                *ObjPos\w = GadgetWidth(DC::#Contain_12) - 140
                *ObjPos\h = 20                      
                
                FORM::StrgObject(DC::#String_100,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,FontID(Fonts::#_FIXPLAIN7_12),RGB_FrntStR,RGB_BackStR,"> NO FILENAME SELECTED <",1,1)
                
                *ObjPos\x = GadgetWidth(DC::#String_100) +  GadgetX(DC::#String_100) + ObjPosSpace                  
                *ObjPos\w = 140                    
                FORM::StrgObject(DC::#String_104,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,FontID(Fonts::#_FIXPLAIN7_12),RGB_FrntStR,RGB_BackStR,"---",1,1)                    
                
                
                ;
                ;
                *ObjPos\x = 0                    
                *ObjPos\y = GadgetHeight(DC::#String_100) +  GadgetY(DC::#String_100) +ObjPosSpace                        
                *ObjPos\w = GadgetWidth(DC::#Contain_12)                    
                FORM::StrgObject(DC::#String_102,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"No Disk Image Load",0,1)
                
                ;
                ;
                *ObjPos\y = GadgetHeight(DC::#String_102) +  GadgetY(DC::#String_102) +ObjPosSpace                        
                FORM::StrgObject(DC::#String_101,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Please Select c1541.exe or dm.exe",0,1)                    
                
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#String_101) +  GadgetY(DC::#String_101) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#ListIcon_003)
                *ObjPos\h = 20  
                
                SetButton(DC::#Button_277,*ObjPos\x,*ObjPos\y,"Local - Image","Local - Image","Local - Image",14)         
                SetButton(DC::#Button_279,GadgetX(DC::#Button_277)+GadgetWidth(DC::#Button_277)+ObjPosSpace, *ObjPos\y,"Charset","Charset","Charset",17)  
                SetButton(DC::#Button_280,GadgetX(DC::#Button_279)+GadgetWidth(DC::#Button_279)+ObjPosSpace,*ObjPos\y,"Real - Drive","Real - Drive","Real - Drive",14) 
                
                ;SetButton(DC::#Button_281,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_279)+1), *ObjPos\y,"","","",12)  
                ButtonEX::Toggle(DC::#Button_277, 1): ButtonEX::SetState(DC::#Button_277, 0)
                ButtonEX::Toggle(DC::#Button_280, 1): ButtonEX::SetState(DC::#Button_280, 0)                     
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#Button_280) +  GadgetY(DC::#Button_280) +ObjPosSpace                       
                *ObjPos\w = GadgetWidth(DC::#ListIcon_003)
                *ObjPos\h = 20                       
                SetButton(DC::#Button_203,*ObjPos\x,*ObjPos\y,"Directory","Directory","Directory",16)  ; Show Image Directory
                
                SetButton(DC::#Button_204,GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace, *ObjPos\y,"Copy Files  ","Copy Files  ","Copy Files  ",19)                                         
                SetButton(DC::#Button_205,GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace, *ObjPos\y,"Rename","Rename","Rename",17)                                       
                SetButton(DC::#Button_206,GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace, *ObjPos\y,"  Copy Files","  Copy Files","  Copy Files",18)                     
                SetButton(DC::#Button_207,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1), *ObjPos\y,"Directory","Directory","Directory",12)  
                
                
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#Button_280) +  GadgetY(DC::#Button_280) + ObjPosSpace + 24
                *ObjPos\w = GadgetWidth(DC::#ListIcon_003)
                *ObjPos\h = 20  
                
                SetButton(DC::#Button_262,GadgetX(DC::#Button_203), *ObjPos\y,"","","",12)        
                SetButton(DC::#Button_263,GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace, *ObjPos\y,"Write D64  ","Write D64  ","Write D64  ",19)    
                SetButton(DC::#Button_264,GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace, *ObjPos\y,"Scratch","Scratch","Scratch",17)    
                SetButton(DC::#Button_265,GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace, *ObjPos\y,"  Create D64","  Create D64","  Create D64",18)                      
                SetButton(DC::#Button_266,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1), *ObjPos\y,"Status","Status","Status",12)                     
                
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#Button_262) +  GadgetY(DC::#Button_262) + ObjPosSpace 
                *ObjPos\w = GadgetWidth(DC::#ListIcon_003)
                *ObjPos\h = 20  
                
                SetButton(DC::#Button_267,GadgetX(DC::#Button_203), *ObjPos\y,"","","",12)        
                SetButton(DC::#Button_268,GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace, *ObjPos\y,"New Image","New Image","",13)    
                SetButton(DC::#Button_269,GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace, *ObjPos\y,"","","",17)    
                SetButton(DC::#Button_270,GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace, *ObjPos\y,"Format","Format","Format",13)                      
                SetButton(DC::#Button_271,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1), *ObjPos\y,"Validate","Validate","Validate",12)   
                
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#Button_271) +  GadgetY(DC::#Button_271) + ObjPosSpace 
                *ObjPos\w = GadgetWidth(DC::#ListIcon_003)
                *ObjPos\h = 20  
                
                SetButton(DC::#Button_272,GadgetX(DC::#Button_203), *ObjPos\y,"Transfer Files","Transfer Files","Transfer Files",21)        
                SetButton(DC::#Button_273,GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace, *ObjPos\y,"Backup Files","Backup Files","Backup Files",21)    
                SetButton(DC::#Button_274,GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace, *ObjPos\y,"Ok","Ok","Ok",17)    
                SetButton(DC::#Button_275,GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace, *ObjPos\y,"Backup Files","Backup Files","Backup Files",21)                      
                SetButton(DC::#Button_276,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1), *ObjPos\y,"Transfer Files","Transfer Files","Transfer Files",21)                      
                ;
                ;
                *ObjPos\y = GadgetHeight(DC::#Button_276) +  GadgetY(DC::#Button_276) + ObjPosSpace  + 4
                *ObjPos\w = GadgetWidth(DC::#Contain_12) 
                FORM::StrgObject(DC::#String_103,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"OpenCBM Tools",0,1) 
                
                ;
                ;
                *ObjPos\y = GadgetHeight(DC::#String_103) +  GadgetY(DC::#String_103) + ObjPosSpace 
                *ObjPos\w = GadgetWidth(DC::#Contain_12) 
                FORM::StrgObject(DC::#String_111,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"OpenCBM Backup Path",0,1)                     
                
                
                CloseGadgetList()
                SetGadgetColor(DC::#Contain_12,#PB_Gadget_BackColor,*ObjPos\c\rgb_backgrd)  
                ;
                ; Resize Mode
            Case 1
                ResizeGadget(DC::#Contain_12    ,#PB_Ignore, SnapHeight, *r\w, *r\h-60)
                
                ResizeGadget(DC::#ListIcon_003  , #PB_Ignore,          #PB_Ignore, GadgetWidth(DC::#Contain_12)-80, GadgetHeight(DC::#Contain_12)-294)
                
                SetGadgetItemAttribute(DC::#ListIcon_003,0,#PB_ListIcon_ColumnWidth,GadgetWidth(DC::#Contain_12)-243,1  )                                                                  
                
                ResizeGadget(DC::#Text_122, GadgetX(DC::#Text_121) + GadgetWidth(DC::#Text_121), #PB_Ignore, GadgetWidth(DC::#Contain_12)-208,#PB_Ignore)
                ResizeGadget(DC::#Text_123, GadgetX(DC::#Text_122) + GadgetWidth(DC::#Text_122), #PB_Ignore, #PB_Ignore ,#PB_Ignore) 
                
                ResizeGadget(DC::#Text_124, #PB_Ignore, GadgetHeight(DC::#ListIcon_003) +  GadgetY(DC::#ListIcon_003),  GadgetWidth(DC::#ListIcon_003), #PB_Ignore)   
                
                ;                 Center.LV_COLUMN\mask=#LVCF_FMT
                ;                 Center\fmt=#LVCFMT_LEFT
                ;                 SendMessage_(GadgetID(DC::#ListIcon_003), #LVM_SETCOLUMN,1,@Center)                
                *ObjPos\x = 0 
                *ObjPos\y = GadgetHeight(DC::#Text_124) +  GadgetY(DC::#Text_124)  + ObjPosSpace + 8
                *ObjPos\w = GadgetWidth(DC::#Contain_12) - 140                   
                *ObjPos\h = 20 
                ResizeGadget(DC::#String_100,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h)
                
                *ObjPos\x = GadgetWidth(DC::#String_100) +  GadgetX(DC::#String_100) + ObjPosSpace                  
                *ObjPos\w = 140                    
                ResizeGadget(DC::#String_104,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h)                 
                ;
                ;              
                *ObjPos\x = 0                     
                *ObjPos\y = GadgetHeight(DC::#String_100) +  GadgetY(DC::#String_100) +ObjPosSpace                  
                *ObjPos\w = GadgetWidth(DC::#Contain_12)                      
                ResizeGadget(DC::#String_102,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                ;
                ;                    
                *ObjPos\y = GadgetHeight(DC::#String_102) +  GadgetY(DC::#String_102) +ObjPosSpace                       
                ResizeGadget(DC::#String_101,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                
                
                
                
                ;
                ;
                *ObjPos\x = GadgetWidth(DC::#Contain_12) - 432
                *ObjPos\y = GadgetHeight(DC::#String_101) +  GadgetY(DC::#String_101) + ObjPosSpace     
                ResizeGadget(DC::#Button_277    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_277)+GadgetWidth(DC::#Button_277)+ObjPosSpace                    
                ResizeGadget(DC::#Button_279   ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_279)+GadgetWidth(DC::#Button_279)+ObjPosSpace                    
                ResizeGadget(DC::#Button_280    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                
                ;
                ;                    
                ;ResizeGadget(DC::#Button_281    ,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)  
                
                ;
                ;
                *ObjPos\x = GadgetWidth(DC::#Contain_12) - 432
                *ObjPos\y = GadgetHeight(DC::#Button_280) +  GadgetY(DC::#Button_280) +ObjPosSpace                      
                ResizeGadget(DC::#Button_203    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace
                *ObjPos\y = GadgetY(DC::#Button_203)               
                ResizeGadget(DC::#Button_204    , *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace                    
                ResizeGadget(DC::#Button_205    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace                    
                ResizeGadget(DC::#Button_206    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;                    
                ResizeGadget(DC::#Button_207    ,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetWidth(DC::#Contain_12) - 432
                *ObjPos\y = GadgetHeight(DC::#Button_207) +  GadgetY(DC::#Button_207) + ObjPosSpace
                ResizeGadget(DC::#Button_262    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace             
                ResizeGadget(DC::#Button_263    , *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace                    
                ResizeGadget(DC::#Button_264   ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace                    
                ResizeGadget(DC::#Button_265    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                
                ;
                ;                    
                ResizeGadget(DC::#Button_266    ,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetWidth(DC::#Contain_12) - 432
                *ObjPos\y = GadgetHeight(DC::#Button_262) +  GadgetY(DC::#Button_262) + ObjPosSpace      
                ResizeGadget(DC::#Button_267    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace             
                ResizeGadget(DC::#Button_268    , *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace                    
                ResizeGadget(DC::#Button_269   ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace                    
                ResizeGadget(DC::#Button_270    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                
                ;
                ;                    
                ResizeGadget(DC::#Button_271    ,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)                        
                
                *ObjPos\x = GadgetWidth(DC::#Contain_12) - 432
                *ObjPos\y = GadgetHeight(DC::#Button_271) +  GadgetY(DC::#Button_271) + ObjPosSpace      
                ResizeGadget(DC::#Button_272    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace             
                ResizeGadget(DC::#Button_273    , *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace                    
                ResizeGadget(DC::#Button_274   ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace                    
                ResizeGadget(DC::#Button_275    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                
                ;
                ;                    
                ResizeGadget(DC::#Button_276    ,GadgetWidth(DC::#Contain_12) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)    
                
                ;
                ;                    
                *ObjPos\y = GadgetHeight(DC::#Button_276) +  GadgetY(DC::#Button_276) + ObjPosSpace +4
                *ObjPos\w = GadgetWidth(DC::#Contain_12)                                        
                ResizeGadget(DC::#String_103, #PB_Ignore,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                
                ;
                ;                    
                *ObjPos\y = GadgetHeight(DC::#String_103) +  GadgetY(DC::#String_103) + ObjPosSpace 
                *ObjPos\w = GadgetWidth(DC::#Contain_12)                                        
                ResizeGadget(DC::#String_111, #PB_Ignore,*ObjPos\y, *ObjPos\w, *ObjPos\h)                     
                
        EndSelect        
    EndProcedure       
    ;******************************************************************************************************************************************
    ;  Fenster Für Programme
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i InteractiveGadgets_Window_003_Def(Resize.i = 0, SnapHeight = 30)
        
        Protected ObjPosSpace.i
        
        *ObjPos\x = 0 
        *ObjPos\y = SnapHeight                  
        *ObjPos\w = *r\w
        *ObjPos\h = *r\h        
        ObjPosSpace.i = 4
        Select Resize
                ;
                ; Build Mode
            Case 0                               
                ContainerGadget(DC::#Contain_08, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h-(*ObjPos\y*2),0) 
                
                ;
                ; Listbox
                *ObjPos\x = 40 
                *ObjPos\y = 20                  
                *ObjPos\w = GadgetWidth(DC::#Contain_08)-80
                *ObjPos\h = GadgetHeight(DC::#Contain_08)-145
                Form::ListObject(DC::#ListIcon_002, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h, Fonts::#_SEGOEUI10N, 0, 2, "", 0, *ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_backgrd)
                
                ;SetExtendLIst(DC::#ListIcon_002)
                SendMessage_(GadgetID(DC::#ListIcon_002),#LVM_SETEXTENDEDLISTVIEWSTYLE,0,#LVS_EX_LABELTIP| #LVS_EX_FULLROWSELECT) 
                AddGadgetColumn(DC::#ListIcon_002, 0,"",*ObjPos\w)
                SetGadgetItemAttribute(DC::#ListIcon_002,0,#PB_ListIcon_ColumnWidth,GadgetWidth(DC::#ListIcon_002)-20) 
                EnableWindow_(SendMessage_(GadgetID(DC::#ListIcon_002),#LVM_GETHEADER,#Null,#Null),0) ; Header Breite Fixieren 
                LVSORTEX::ListIconSortAddGadget(DC::#ListIcon_002,LVSORTEX::#ListIcon_Sort_Up)
                LVSORTEX::ListIconSortSetCol(DC::#ListIcon_002, 0)
                ;
                ;
                ;
                ; Farbe die Strings
                Protected RGB_FrntStR.i = *ObjPos\c\rgb_strFrCk        
                Protected RGB_BackStR.i = *ObjPos\c\rgb_54_54_54
                Protected Font_StR.i    = FontID(Fonts::#_SEGOEUI11N) 
                
                *ObjPos\x = 0
                *ObjPos\y = GadgetHeight(DC::#ListIcon_002) +  GadgetY(DC::#ListIcon_002) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#Contain_08) - 140
                *ObjPos\h = 20                          
                FORM::StrgObject(DC::#String_100,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Description in the List",1,1)
                
                *ObjPos\x = GadgetWidth(DC::#String_100) +  GadgetX(DC::#String_100) + ObjPosSpace                  
                *ObjPos\w = 140                    
                FORM::StrgObject(DC::#String_104,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Short name",1,1)                    
                
                
                ;
                ;
                *ObjPos\x = 0                    
                *ObjPos\y = GadgetHeight(DC::#String_100) +  GadgetY(DC::#String_100) +ObjPosSpace                        
                *ObjPos\w = GadgetWidth(DC::#Contain_08)                    
                FORM::StrgObject(DC::#String_101,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Programm Path",0,1)
                
                ;
                ;
                *ObjPos\y = GadgetHeight(DC::#String_101) +  GadgetY(DC::#String_101) +ObjPosSpace                        
                FORM::StrgObject(DC::#String_102,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Working Path",0,1)
                
                ;
                ;
                *ObjPos\y = GadgetHeight(DC::#String_102) +  GadgetY(DC::#String_102) +ObjPosSpace                       
                FORM::StrgObject(DC::#String_103,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Commandline",0,1)                                                        
                
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#String_103) +  GadgetY(DC::#String_103) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#ListIcon_002)
                *ObjPos\h = 20                       
                SetButton(DC::#Button_203,*ObjPos\x,*ObjPos\y,"New","New","New")  
                
                SetButton(DC::#Button_204,GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace, *ObjPos\y,"Duplicate","Duplicate","Duplicate") 
                
                SetButton(DC::#Button_205,GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace, *ObjPos\y,"Delete","Delete","Delete")                   
                
                SetButton(DC::#Button_206,GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace, *ObjPos\y,"Save","Save","Save") 
                
                SetButton(DC::#Button_207,GadgetWidth(DC::#Contain_08) - (GadgetWidth(DC::#Button_206)+1), *ObjPos\y,"Ok","Ok","Ok")  
                
                CloseGadgetList()
                SetGadgetColor(DC::#Contain_08,#PB_Gadget_BackColor,*ObjPos\c\rgb_backgrd)  
                ;
                ; Resize Mode
            Case 1
                ResizeGadget(DC::#Contain_08    ,#PB_Ignore, SnapHeight, *r\w, *r\h-60)
                
                ResizeGadget(DC::#ListIcon_002  , 40,          20, GadgetWidth(DC::#Contain_08)-80, GadgetHeight(DC::#Contain_08)-144)
                
                SetGadgetItemAttribute(DC::#ListIcon_002,0,#PB_ListIcon_ColumnWidth,GadgetWidth(DC::#ListIcon_002)-20)                 
                
                *ObjPos\x = 0 
                *ObjPos\y = GadgetHeight(DC::#ListIcon_002) +  GadgetY(DC::#ListIcon_002) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#Contain_08) - 140                   
                *ObjPos\h = 20 
                ResizeGadget(DC::#String_100,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h)
                
                *ObjPos\x = GadgetWidth(DC::#String_100) +  GadgetX(DC::#String_100) + ObjPosSpace                  
                *ObjPos\w = 140                    
                ResizeGadget(DC::#String_104,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h)                 
                ;
                ;              
                *ObjPos\x = 0                     
                *ObjPos\y = GadgetHeight(DC::#String_100) +  GadgetY(DC::#String_100) +ObjPosSpace                  
                *ObjPos\w = GadgetWidth(DC::#Contain_08)                      
                ResizeGadget(DC::#String_101,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                ;
                ;                    
                *ObjPos\y = GadgetHeight(DC::#String_101) +  GadgetY(DC::#String_101) +ObjPosSpace                       
                ResizeGadget(DC::#String_102,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                ;
                ;                    
                *ObjPos\y = GadgetHeight(DC::#String_102) +  GadgetY(DC::#String_102) +ObjPosSpace                       
                ResizeGadget(DC::#String_103,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                
                
                ;
                ;
                *ObjPos\x = GadgetWidth(DC::#Contain_08) - 432
                *ObjPos\y = GadgetHeight(DC::#String_103) +  GadgetY(DC::#String_103) + ObjPosSpace           
                ResizeGadget(DC::#Button_203    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace
                *ObjPos\y = GadgetY(DC::#Button_203)               
                ResizeGadget(DC::#Button_204    , *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace                    
                ResizeGadget(DC::#Button_205    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace                    
                ResizeGadget(DC::#Button_206    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;                    
                ResizeGadget(DC::#Button_207    ,GadgetWidth(DC::#Contain_08) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
        EndSelect        
    EndProcedure  
    
    ;******************************************************************************************************************************************
    ; Fenster für Sprache und Platform
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i InteractiveGadgets_Window_002_Def(Resize.i = 0, SnapHeight = 30)
        
        Protected ObjPosSpace.i
        
        *ObjPos\x = 0 
        *ObjPos\y = SnapHeight                  
        *ObjPos\w = *r\w
        *ObjPos\h = *r\h        
        ObjPosSpace.i = 4
        Select Resize
                ;
                ; Build Mode
            Case 0                               
                ContainerGadget(DC::#Contain_08, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h-(*ObjPos\y*2),0) 
                
                
                
                ;
                ; Listbox
                *ObjPos\x = 40 
                *ObjPos\y = 20                  
                *ObjPos\w = GadgetWidth(DC::#Contain_08)-80
                *ObjPos\h = GadgetHeight(DC::#Contain_08)-72            
                Form::ListObject(DC::#ListIcon_002, *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h, Fonts::#_SEGOEUI10N, 0, 2, "", 0, *ObjPos\c\rgb_strFrCk,*ObjPos\c\rgb_backgrd)
                
                ;SetExtendLIst(DC::#ListIcon_002)
                ;SendMessage_(GadgetID(DC::#ListIcon_002),#LVM_SETEXTENDEDLISTVIEWSTYLE,0,#LVS_EX_LABELTIP| #LVS_EX_FULLROWSELECT) 
                SetExtendLIst1(DC::#ListIcon_002)
                AddGadgetColumn(DC::#ListIcon_002, 0,"",*ObjPos\w) 
                SetGadgetItemAttribute(DC::#ListIcon_002,0,#PB_ListIcon_ColumnWidth,GadgetWidth(DC::#ListIcon_002)-20) 
                EnableWindow_(SendMessage_(GadgetID(DC::#ListIcon_002),#LVM_GETHEADER,#Null,#Null),0) ; Header Breite Fixieren 
                LVSORTEX::ListIconSortAddGadget(DC::#ListIcon_002,LVSORTEX::#ListIcon_Sort_Up)
                LVSORTEX::ListIconSortSetCol(DC::#ListIcon_002, 0)
                ;
                ;
                ;
                ; Farbe die Strings
                Protected RGB_FrntStR.i = *ObjPos\c\rgb_strFrCk        
                Protected RGB_BackStR.i = *ObjPos\c\rgb_54_54_54
                Protected Font_StR.i    = FontID(Fonts::#_SEGOEUI11N)   
                
                *ObjPos\x = 0
                *ObjPos\y = GadgetHeight(DC::#ListIcon_002) +  GadgetY(DC::#ListIcon_002) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#Contain_08)
                *ObjPos\h = 20                          
                
                
                FORM::StrgObject(DC::#String_100,*ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h,Font_StR,RGB_FrntStR,RGB_BackStR,"Test",1,1)
                
                
                ;
                ;
                *ObjPos\x = 1 
                *ObjPos\y = GadgetHeight(DC::#String_100) +  GadgetY(DC::#String_100) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#ListIcon_002)
                *ObjPos\h = 20                      
                
                SetButton(DC::#Button_203,*ObjPos\x,*ObjPos\y,"New","New","New")  
                
                SetButton(DC::#Button_204,GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace, *ObjPos\y,"Duplicate","Duplicate","Duplicate") 
                
                SetButton(DC::#Button_205,GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace, *ObjPos\y,"Delete","Delete","Delete")                   
                
                SetButton(DC::#Button_206,GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace, *ObjPos\y,"Rename","Rename","Rename") 
                
                SetButton(DC::#Button_207,GadgetWidth(DC::#Contain_08) - (GadgetWidth(DC::#Button_206)+1), *ObjPos\y,"Ok","Ok","Ok")                    
                
                
                CloseGadgetList()
                SetGadgetColor(DC::#Contain_08,#PB_Gadget_BackColor,*ObjPos\c\rgb_backgrd)  
                ;
                ; Resize Mode
            Case 1
                ResizeGadget(DC::#Contain_08    ,#PB_Ignore, SnapHeight, *r\w, *r\h-60)
                
                ResizeGadget(DC::#ListIcon_002  , 40,          20, GadgetWidth(DC::#Contain_08)-80, GadgetHeight(DC::#Contain_08)-72)
                
                SetGadgetItemAttribute(DC::#ListIcon_002,0,#PB_ListIcon_ColumnWidth,GadgetWidth(DC::#ListIcon_002)-20)                 
                
                *ObjPos\x = 0 
                *ObjPos\y = GadgetHeight(DC::#ListIcon_002) +  GadgetY(DC::#ListIcon_002) + ObjPosSpace
                *ObjPos\w = GadgetWidth(DC::#Contain_08)                    
                *ObjPos\h = 20 
                ResizeGadget(DC::#String_100,  *ObjPos\x,*ObjPos\y, *ObjPos\w, *ObjPos\h) 
                
                ;
                ;
                *ObjPos\x = GadgetWidth(DC::#Contain_08) - 432
                *ObjPos\y = GadgetHeight(DC::#String_100) +  GadgetY(DC::#String_100) + ObjPosSpace           
                ResizeGadget(DC::#Button_203    , *ObjPos\x, *ObjPos\y, #PB_Ignore, #PB_Ignore)                    
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_203)+GadgetWidth(DC::#Button_203)+ObjPosSpace
                *ObjPos\y = GadgetY(DC::#Button_203)               
                ResizeGadget(DC::#Button_204    , *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_204)+GadgetWidth(DC::#Button_204)+ObjPosSpace                    
                ResizeGadget(DC::#Button_205    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_205)+GadgetWidth(DC::#Button_205)+ObjPosSpace                    
                ResizeGadget(DC::#Button_206    ,  *ObjPos\x,*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
                ;
                ;
                *ObjPos\x = GadgetX(DC::#Button_206)+GadgetWidth(DC::#Button_206)+ObjPosSpace*8                      
                ResizeGadget(DC::#Button_207    , GadgetWidth(DC::#Contain_08) - (GadgetWidth(DC::#Button_206)+1),*ObjPos\y, #PB_Ignore, #PB_Ignore)
                
        EndSelect       
    EndProcedure  
    ;******************************************************************************************************************************************
    ;   
    ; Standard Objekte für die Fenster, In den Meisten Fällen Close, Resize    
    ; Aufbau der Buttons sowie Resize der BUttons; Resize Objecte werde im Callback gestartet   
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i InteractiveGadgets(ChildWindowID.i, Resize.i = 0, SnapHeight = 30)
        
        ;
        ; rxy = Aktuelle Resize Position des Windows
        ; rwh = Aktuelle Resize Grösse des Windows
        *r\x = WindowX(ChildWindowID)
        *r\y = WindowY(ChildWindowID)
        *r\w = WindowWidth(ChildWindowID)
        *r\h = WindowHeight(ChildWindowID)                   
        ;  
        Protected bClose = DC::#Button_201
        Protected bResze = DC::#Button_202
        Protected bpMenu = DC::#Button_278 ; Menu Button
        
        *ObjBox\nr[0] = DC::#DesignBox001    ; Leiste Oben
        *ObjBox\nr[1] = DC::#DesignBox002    ; Leiste Unten
        
        Select Resize.i
                ; ======================================================================================================
                ; Build Mode
                ; ======================================================================================================                
            Case 0
                ;
                ; Title und Untere Status leiste (Design). Resize mit einem BoxImage führt zu Flacker Bugs.
                ; Nimm statdessen eine sehr grosse lange breite.
                WinGuru::ThemeBox(ChildWindowID,16840, SnapHeight, 0,       0,$1F1F1F, #PB_2DDrawing_Default, *ObjBox\nr[0])                 
                WinGuru::ThemeBox(ChildWindowID,16840, SnapHeight, 0, *r\h-SnapHeight,$1F1F1F, #PB_2DDrawing_Default, *ObjBox\nr[1])                
                
                Select ChildWindowID  
                ;
                ; Close Button and Resize Button
                    Case DC::#_Window_002, DC::#_Window_003, DC::#_Window_004, DC::#_Window_005
                        SetButton(bClose,*r\w-SnapHeight,      0,"","","",2)
                        SetButton(bResze,*r\w-SnapHeight,*r\h-SnapHeight,"","","",4)
                    Case DC::#_Window_006                        
                        SetButton(bResze,*r\w-SnapHeight,*r\h-SnapHeight,"","","",4)
                    Default
                EndSelect
                
                Select ChildWindowID                      
                    Case DC::#_Window_005: SetButton(bpMenu,*r\w-(SnapHeight*2),0 ,"","","",15)
                    Case DC::#_Window_003: SetButton(bpMenu,*r\w-(SnapHeight*2),0 ,"","","",15)
                EndSelect        
                
                ;
                ; Je Window Unterschiedliche Gadgets
                Select ChildWindowID
                    Case DC::#_Window_002: InteractiveGadgets_Window_002_Def()
                    Case DC::#_Window_003: InteractiveGadgets_Window_003_Def() 
                    Case DC::#_Window_004: InteractiveGadgets_Window_004_Def()    
                    Case DC::#_Window_005: InteractiveGadgets_Window_005_Def()
                    Case DC::#_Window_006: InteractiveGadgets_Window_006_Def()                         
                    Default
                EndSelect
                ; ======================================================================================================
                ; Resize Mode
                ; ======================================================================================================
            Case 1
                ;
                ; Title und Untere Status leiste (Design)            
                ResizeGadget(*ObjBox\nr[1], 0,*r\h-SnapHeight, #PB_Ignore, #PB_Ignore) 
                
                ;
                ; Menu PopUp Button
                Select ChildWindowID                       
                    Case DC::#_Window_005: ResizeGadget(bpMenu,*r\w-(SnapHeight*2)   , #PB_Ignore, #PB_Ignore, #PB_Ignore)
                    Case DC::#_Window_003: ResizeGadget(bpMenu,*r\w-(SnapHeight*2)   , #PB_Ignore, #PB_Ignore, #PB_Ignore)
                EndSelect 
                
                Select ChildWindowID  
                ;
                ; Close Button and Resize Button
                    Case DC::#_Window_002, DC::#_Window_003, DC::#_Window_004, DC::#_Window_005
                        ResizeGadget(bClose,*r\w-SnapHeight   , #PB_Ignore, #PB_Ignore, #PB_Ignore)
                        ResizeGadget(bResze,*r\w-SnapHeight   ,*r\h-SnapHeight    , #PB_Ignore, #PB_Ignore)
                    Case DC::#_Window_006
                        ResizeGadget(bResze,*r\w-SnapHeight   ,*r\h-SnapHeight    , #PB_Ignore, #PB_Ignore)
                    Default
                EndSelect
               
                
                
                ;
                ; Je Window Unterschiedliche Gadgets
                Select ChildWindowID
                    Case DC::#_Window_002: InteractiveGadgets_Window_002_Def(1)
                    Case DC::#_Window_003: InteractiveGadgets_Window_003_Def(1) 
                    Case DC::#_Window_004: InteractiveGadgets_Window_004_Def(1)     
                    Case DC::#_Window_005: InteractiveGadgets_Window_005_Def(1) 
                    Case DC::#_Window_006: InteractiveGadgets_Window_006_Def(1)                           
                    Default
                EndSelect
                
                Delay(1)
        EndSelect
        
        ProcedureReturn 0
    EndProcedure 
    
    ;******************************************************************************************************************************************
    ;   
    ; Standard Objekte für die Fenster, In den Meisten Fällen Close, Resize    
    ; Aufbau der Buttons sowie Resize der BUttons; Resize Objecte werde im Callback gestartet   
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i InteractiveGadgets_Edit(ChildWindowID.i, Resize.i = 0, SnapHeight = 30)
        
        ;
        ; rxy = Aktuelle Resize Position des Windows
        ; rwh = Aktuelle Resize Grösse des Windows
        *r\x = WindowX(ChildWindowID)
        *r\y = WindowY(ChildWindowID)
        *r\w = WindowWidth(ChildWindowID)
        *r\h = WindowHeight(ChildWindowID)                   
        ;  
        Protected bResze = DC::#Button_282
        
        *ObjBox\nr[0] = DC::#DesignBox003    ; Leiste Oben
        *ObjBox\nr[1] = DC::#DesignBox004    ; Leiste Unten
        
        Select Resize.i
                
                ; ======================================================================================================
                ; Build Mode
                ; ======================================================================================================                
                
            Case 0
                ;
                ; Title und Untere Status leiste (Design). Resize mit einem BoxImage führt zu Flacker Bugs.
                ; Nimm statdessen eine sehr grosse lange breite.
                WinGuru::ThemeBox(ChildWindowID,16840, SnapHeight, 0,               0,$1F1F1F, #PB_2DDrawing_Default, *ObjBox\nr[0])                 
                WinGuru::ThemeBox(ChildWindowID,16840, SnapHeight, 0, *r\h-SnapHeight,$1F1F1F, #PB_2DDrawing_Default, *ObjBox\nr[1])                
                
                SetButton(bResze,*r\w-SnapHeight,*r\h-SnapHeight,"","","",4)      
                
                ;
                ; Je Window Unterschiedliche Gadgets
                InteractiveGadgets_Window_006_Def()                                                      
                
                ; ======================================================================================================
                ; Resize Mode
                ; ======================================================================================================
                
            Case 1
                ;
                ; Title und Untere Status leiste (Design)            
                ResizeGadget(*ObjBox\nr[1],                0, *r\h-SnapHeight, #PB_Ignore, #PB_Ignore) 
                ;
                ; Close Button and Resize Button
                ResizeGadget(bResze,        *r\w-SnapHeight , *r\h-SnapHeight, #PB_Ignore, #PB_Ignore)                            

                ;
                ; Je Window Unterschiedliche Gadgets
                InteractiveGadgets_Window_006_Def(1)                                          
                Delay(1)
        EndSelect
        
        ProcedureReturn 0
    EndProcedure     
    ;******************************************************************************************************************************************
    ;   
    ; Fenster Status
    ;    
    ;__________________________________________________________________________________________________________________________________________     
    Procedure DefaultWindow_State(ChildWindowID.i, Base_WindowID.i, Width.i, Height.i)
        
        Protected Flags.l
        Flags.l = #PB_Window_Invisible| #WS_SIZEBOX| #WS_MAXIMIZEBOX| #WS_MINIMIZEBOX| #WS_POPUPWINDOW| #PB_Window_WindowCentered
        Select GetWindowState(Base_WindowID)
                ;
                ; Andere Handhabung falls der Status vom Hauptfenster anders ist
            Case #PB_Window_Maximize
                Select ChildWindowID
                    Case  DC::#_Window_006                               
                        WinGuru::Style(ChildWindowID,0 ,0 , Width ,Height ,Flags ,RGB(61,61,61) ,#True, #False, #True, 0 ,-1,#False)
                    Default                        
                        WinGuru::Style(ChildWindowID,0 ,0 , Width ,Height ,Flags ,RGB(61,61,61) ,#True, #False, #True, 0 ,-1,#False,WindowID(Base_WindowID))
                EndSelect        
                
            Default
                Select ChildWindowID
                    Case  DC::#_Window_006
                        WinGuru::Style(ChildWindowID,0 ,0 , Width ,Height ,Flags ,RGB(61,61,61) ,#False, #False, #True, 0,-1,#False)                         
                    Default                 
                        WinGuru::Style(ChildWindowID,0 ,0 , Width ,Height ,Flags ,RGB(61,61,61) ,#False, #False, #True, 0,-1,#False,WindowID(Base_WindowID))                         
                EndSelect                        
        EndSelect
        
        SetWindowColor(ChildWindowID, RGB(61,61,61)): ResizeWindow(ChildWindowID, 0, 0, Width, Height)
        
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;   
    ; Fenster Bau für die Verschiedenen Listen
    ; ChildWindowID: Neue FensterID wird Live übergeben   
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i DefaultWindow(ChildWindowID)
        Protected w.i, h.i
        ;
        ;
        ; Current Window       
        Protected Base_WindowID = DC::#_Window_001 
        
        Select ChildWindowID
            Case DC::#_Window_002 , DC::#_Window_003
                w = 433
                h = 790   
            ;
            ; Fenster für die Screenshots                
            Case DC::#_Window_004   
                w = 1
                h = 61
                
            Case DC::#_Window_005
                w = 433
                h = 790 
                
            Case DC::#_Window_006
                
                w = vInfo::Props_GetWidth()  - (GetSystemMetrics_(#SM_CXSIZEFRAME) *2 )                
                h = vInfo::Props_GetHeight() - (GetSystemMetrics_(#SM_CXSIZEFRAME) *2 )                  
        EndSelect
        
        DefaultWindow_State(ChildWindowID.i, Base_WindowID.i, w, h)
        
        Select ChildWindowID
            Case DC::#_Window_002 , DC::#_Window_003, DC::#_Window_004, DC::#_Window_005
                InteractiveGadgets(ChildWindowID)  
                WinGuru::Center(ChildWindowID,w, h, ChildWindowID)    
                
            Case DC::#_Window_006
                InteractiveGadgets_Edit(ChildWindowID)                  
        EndSelect
                  
        

        Delay(25)
        ;
        ; Für den Callback die PB WindowID Widergeben        
        Set_Tooltypes_Ext(ChildWindowID.i)
        
        ProcedureReturn ChildWindowID
    EndProcedure   
    
    Procedure Set_Tooltypes()
        
        Protected ToolTipFont.l = Fonts::#_SEGOEUI10N, ToolTipLen.i = 318, ToolTipFontEx.l = Fonts::#_SEGOEUI10N, ToolTipInfo$
        
        ToolTipInfoTitle$ = "New"
        ToolTipInfo_Text$ = "Enter New Title"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_010 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Duplicate"
        ToolTipInfo_Text$ = "Duplicate Current Entry"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_011 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Delete"
        ToolTipInfo_Text$ = "Delete Current Entry"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_012 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Edit"
        ToolTipInfo_Text$ = "Edit Settings For The Current Entry"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_013 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Start"
        ToolTipInfo_Text$ = "Start the Game/Port/Emulator That You Have Edited In The Settings."
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_014 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)         
        ;
        ;
        ;
        ToolTipInfoTitle$ = "Title (Drag'n'Drop Supportet)"
        ToolTipInfo_Text$ = "Edit Title. You can Drag'n'Drop a File or Text. If you Drag a File, you get the Filename without Extension"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_001 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)         
        
        ToolTipInfoTitle$ = "Title"
        ToolTipInfo_Text$ = "Edit Subtitle"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_002 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)          
        
        ToolTipInfoTitle$ = "Language"
        ToolTipInfo_Text$ = "Press and Doubleklick the Left Mouse Button in the String to open a Window and select a Language"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_003 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "System Choice"
        ToolTipInfo_Text$ = "Press and Doubleklick the Left Mouse Button in the String to open a Window and select a Platform/System"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_004 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)  
        
        ToolTipInfoTitle$ = "Release Data"
        ToolTipInfo_Text$ = "Edit the Release Date."
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_005 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Configure the Program"
        ToolTipInfo_Text$ = "Press and Doubleklick the Left Mouse Button in the String to open a Window and select a Configured Program"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_006 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
        
        ToolTipInfoTitle$ = "Configure the Program Commandline"
        ToolTipInfo_Text$ = "Press and Doubleklick the Left Mouse Button in the String to open and select a window with Programs to Edit the Commandline"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_007 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Media Device 0 (Drag'n'Drop Supportet)"
        ToolTipInfo_Text$ = "Full Path to Rom/Media File. This will be controlled by '%s' in the commandline." + #CR$ +
                            "Press and Doubleklick the Left Mouse Button in the String to open and select a File." + #CR$ + #CR$ +
                            "Hint: You can make this fully Portable. If you see a '.\'. Portable mode is activated." + #CR$ + #CR$ +
                            "Hint: If the Title String is Empty. The Filename will be used As Title"+ #CR$ + #CR$ +
                            "Remove and Clear Media Files" +Chr(9)+ "Shotcut: SHIFT+ENTF"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_008 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        ToolTipInfoTitle$ = "Media Device 1 (Drag'n'Drop Supportet)"        
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_009 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
        ToolTipInfoTitle$ = "Media Device 2 (Drag'n'Drop Supportet)"        
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_010 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
        ToolTipInfoTitle$ = "Media Device 3 (Drag'n'Drop Supportet)"        
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_011 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Autoload Program for WinVice"
        ToolTipInfo_Text$ = "Doubleclick in the String or Select the Disk Icon to Open a Disk Manager"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_107 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
        
        ToolTipInfoTitle$ = "Autoload Program for Hoxs64"
        ToolTipInfo_Text$ = "Doubleclick in the String or Select the Disk Icon to Open a Disk Manager"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#String_108 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)         
        ;
        ;
        ;
        ToolTipInfoTitle$ = "Language"
        ToolTipInfo_Text$ = "Press to open a Window and select a Languages"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_020 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)        
        
        ToolTipInfoTitle$ = "System Choice"
        ToolTipInfo_Text$ = "Press to open a Window and select a Platform"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_021 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
        
        ToolTipInfoTitle$ = "Configure the Program"
        ToolTipInfo_Text$ = "Press to open a Window and select a Configured Program"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_022 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Save Changes (CTRL-S)"
        ToolTipInfo_Text$ = "Save the Current Changes. Except Language, Platform and Program. These were already Saved when selecting from the window."
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_023 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
        
        ToolTipInfoTitle$ = "Close (ESC)"
        ToolTipInfo_Text$ = "Close this window and goes back to the Game List. Alternatively, you can press the key Escape."
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_024 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
        
        ToolTipInfoTitle$ = "Sort: Title"
        ToolTipInfo_Text$ = "Sort the list by Titles" +Chr(9)+"ShortKey: F1"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_025 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)  
        
        ToolTipInfoTitle$ = "Sort: Platform"
        ToolTipInfo_Text$ = "Sort the list by Platform/Systems" +Chr(9)+"ShortKey: F2"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_026 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)   
        
        ToolTipInfoTitle$ = "Sort: Language"
        ToolTipInfo_Text$ = "Sort the list by Language" +Chr(9)+"ShortKey: F3"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_027 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
        
        ToolTipInfoTitle$ = "Sort: Program"
        ToolTipInfo_Text$ = "Sort the list by Preogram/ Emulator/ Port" +Chr(9)+"ShortKey: F4"
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Button_028 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
        
        ToolTipInfoTitle$ = "Thumbnail: (Drag'n'Drop Supportet)"
        ToolTipInfo_Text$ = "Supportet Images:"+ Chr(13) + 
                            "BMP, GIF (Not Anim), ICO, JPG, PCX, PNG, TGA, TIFF" + Chr(13) + 
                            "Amiga  :  IFF, ILBM" + Chr(13) + 
                            "Texture:  DDS" + Chr(13) +  Chr(13) + 
                            "Press Left Doubleclick to Show the Picture" + Chr(13) + 
                            "Increase the Thumbnail Size (+)"+Chr(9)+"ShortKey: F5" + Chr(13) +
                            "Decrease the Thumbnail Size (-)"+Chr(9)+"ShortKey: F6" + Chr(13) +
                            "Adjust the Width   Increase (+)"+Chr(9)+"ShortKey: Numpad 4" + Chr(13) +                            
                            "Adjust the Width   decrease (-)"+Chr(9)+"ShortKey: Numpad 6" + Chr(13) +                            
                            "Adjust the Height  Increase (+)"+Chr(9)+"ShortKey: Numpad 8" + Chr(13) +                            
                            "Adjust the height  decrease (-)"+Chr(9)+"ShortKey: Numpad 2"                           
        SSTTIP::TooltTip(WindowID(DC::#_Window_001), DC::#Contain_10 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen+50, 0, ToolTipFont ,#False)         
    EndProcedure    
    Procedure Set_Tooltypes_Ext(ChildWindowID.i)
        
        Protected ToolTipFont.l = Fonts::#_SEGOEUI10N, ToolTipLen.i = 318, ToolTipFontEx.l = Fonts::#_SEGOEUI10N, ToolTipInfo$
        
        If ( ChildWindowID = DC::#_Window_003 )
            
            ToolTipInfoTitle$ = "Programm Description"
            ToolTipInfo_Text$ = "Edit the Programm Description"
            SSTTIP::TooltTip(WindowID( DC::#_Window_003), DC::#String_100 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Short Description"
            ToolTipInfo_Text$ = "Edit Short Description. Appears in the Game List."
            SSTTIP::TooltTip(WindowID( DC::#_Window_003), DC::#String_104 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Program and Path (Drag'n'Drop Supportet)"
            ToolTipInfo_Text$ = "Press and Doubleklick the Left Mouse Button in the String to open and select a Programm. The WorkPath will be filled automatically. "
            SSTTIP::TooltTip(WindowID( DC::#_Window_003), DC::#String_101 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Workpath (Drag'n'Drop Supportet)"
            ToolTipInfo_Text$ = "Press and Doubleklick the Left Mouse Button in the String to open and select a other path."
            SSTTIP::TooltTip(WindowID( DC::#_Window_003), DC::#String_102 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "The Commandline"
            ToolTipInfo_Text$ = #CR$ +
                                "Edit the Commandline directly here. Supportet Keynames are:"       + #CR$ + #CR$ +                                                                  
                                "%m      = Minimize vSystems"                                        + #CR$ +
                                "%a      = Execute and Run the programm Asynchron"                   + #CR$ + #CR$ +                                 
                                "%nb[cb] = Remove Border from Windowed Programs or Games"            + #CR$ +
                                "        + Optional c to Center the Window"                          + #CR$ +
                                "        + Optional b to set real Borderless Window"                 + #CR$ + #CR$ + 
                                "%lck    = Mouse Locked for Window /Screen Mode (Only with %nb)"     + #CR$ + #CR$ +  
                                "%fmm[mb]= Force to Free Memory Cache on Programm (Beware!)"         + #CR$ +
                                "          mb from 1 to 3000. Optional Maximum Mem before Clear."    + #CR$ + #CR$ +                                
                                "%tb     = Game Compatibilty: Disable Taskbar"                       + #CR$ +
                                "%ex     = Game Compatibilty: Disable Explorer"                      + #CR$ +                                
                                "%ux     = Game Compatibilty: Disable Aero Support"                  + #CR$ + #CR$ +  
                                "%c[arg] = Windows Compatibility Mode. Argument is:"                 + #CR$ +
                                "          Win95, Win98, WinXP, WinXPSp3, VistaRTM, RunAsAdmin"      + #CR$ +
                                "          It exists more switches. This is not completely!"         + #CR$ + #CR$ + 
                                "%cpu[x] = Adjust CPU Affinity from 0-63 (0 is 1 etc.. )"            + #CR$ +
                                "          x can be: f to force all Cpu Units"                       + #CR$ +
                                "          x can be: digit number from 0 to 63"                      + #CR$ + #CR$ +                               
                                "%s      = Placeholder For Media Device File(s) Slots"               + #CR$ + 
                                "%nq     = Don't use automatic doublequotes for %s Files"            + #CR$ +
                                "          (For Apps that adding automatic quotes '"+Chr(34)+"')"    + #CR$ +                                
                                "%pk     = Packed Files Support for Programs with %s"                + #CR$ + 
                                "          For Program's that has'nt builtin Packer Support."        + #CR$ + 
                                "          vSystems Uncompress the File & give it to the Program."
                                
                               
                                 For TxtIndex = 1 To Len(ToolTipInfo_Text$)
                                     
                                     char.c = Asc(Mid(ToolTipInfo_Text$,TxtIndex,1))
                                     Select char
                                         Case 'a' To 'z'
                                              sOut$ + UCase( Chr( char ) )
                                         Case 'A' To 'Z'
                                              sOut$ + LCase( Chr( char ) )
                                         Default
                                             sOut$ + Chr( char )
                                       EndSelect
                                   Next
                                   
            SSTTIP::TooltTip(WindowID( DC::#_Window_003), DC::#String_103 ,sOut$, ToolTipInfoTitle$,1, ToolTipLen+110, 0, Fonts::#_C64_CHARS2 ,#False)  
        EndIf
        
        If ( ChildWindowID = DC::#_Window_003 ) Or ( ChildWindowID = DC::#_Window_002 )
            ToolTipInfoTitle$ = "New"
            ToolTipInfo_Text$ = "Enter New Entry"
            SSTTIP::TooltTip(WindowID(ChildWindowID), DC::#Button_203 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Duplicate"
            ToolTipInfo_Text$ = "Duplicate Current Entry"
            SSTTIP::TooltTip(WindowID(ChildWindowID), DC::#Button_204 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Delete"
            ToolTipInfo_Text$ = "Delete Current Entry"
            SSTTIP::TooltTip(WindowID(ChildWindowID), DC::#Button_205 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            Select ChildWindowID
                Case DC::#_Window_002
                    ToolTipInfoTitle$ = "Rename"
                    ToolTipInfo_Text$ = "Rename the Current Entry"
                Case DC::#_Window_003
                    ToolTipInfoTitle$ = "Save Changes"
                    ToolTipInfo_Text$ = "Saved the Current chnages to the Database"                   
            EndSelect            
            SSTTIP::TooltTip(WindowID(ChildWindowID), DC::#Button_206 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Close and Take"
            ToolTipInfo_Text$ = "Close this window and take the current Entry to the Game"
            SSTTIP::TooltTip(WindowID(ChildWindowID), DC::#Button_207 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
        EndIf
        If ( ChildWindowID = DC::#_Window_005)
            ToolTipInfoTitle$ = "Load"+Chr(34)+"$"+Chr(34)+",Image"
            ToolTipInfo_Text$ = "Re/load the Directory of the Current Mounted Image"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_203 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Copy Files to Real Drive"
            ToolTipInfo_Text$ = "Copy Selected Files to the Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_204 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)  
            
            ToolTipInfoTitle$ = "Rename File(s)"
            ToolTipInfo_Text$ = "Rename Selected Files"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_205 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Copy Files to Image"
            ToolTipInfo_Text$ = "Read and Write Selected Files from Real Drive to Mounted Image"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_206 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Write Image To Drive"
            ToolTipInfo_Text$ = "Write the Mounted Image to Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_263 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Delete File(s)"
            ToolTipInfo_Text$ = "Delete Selected Files"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_264 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)             
            
            ToolTipInfoTitle$ = "Create a Image from Drive"
            ToolTipInfo_Text$ = "Read and Create a D64 Image from Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_265 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)            
            
            ToolTipInfoTitle$ = "Initialize Real Drive"
            ToolTipInfo_Text$ = "Init and Reset the Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_266 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
            
            ToolTipInfoTitle$ = "Create a New Image"
            ToolTipInfo_Text$ = "Creat a New Image on Local HD"+#CR$+"Use the Menu for Format Options"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_268 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)              
            
            ToolTipInfoTitle$ = "Format Disk"
            ToolTipInfo_Text$ = "Format a Disk in the Real Drive"+#CR$+"Use the Menu for Format Options"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_270 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)             
            
            ToolTipInfoTitle$ = "Validate Disk"
            ToolTipInfo_Text$ = "Validate a Disk in the Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_271 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)  
            
            ToolTipInfoTitle$ = "Copy Files From HD"
            ToolTipInfo_Text$ = "Copy Local Files to the Current Mounted Image"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_272 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Copy Files To HD"
            ToolTipInfo_Text$ = "Copy Selected Files from the Current Mounted Image to the Backup Path"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_273 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Quit 64Listing"
            ToolTipInfo_Text$ = "Exit the Window and Put the Current File and Disk in the Base Slots"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_274 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Copy Files to HD"
            ToolTipInfo_Text$ = "Copy Selected Files from the Current Real Drive to the Backup Path"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_275 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)             
            
            ToolTipInfoTitle$ = "Copy Files From HD"
            ToolTipInfo_Text$ = "Copy Local Files to Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_276 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
            
            ToolTipInfoTitle$ = "Change Font"
            ToolTipInfo_Text$ = "Shift Up and Down the Font"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_279 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)    
            
            ToolTipInfoTitle$ = "Set Aktiv: Image"
            ToolTipInfo_Text$ = "Refresh and or Set Aktiv the Current Loaded Image"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_277 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)
            
            ToolTipInfoTitle$ = "Set Aktiv: Reasl Drive"
            ToolTipInfo_Text$ = "Refresh and or Set Aktiv the Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_280 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False) 
            
            ToolTipInfoTitle$ = "Load"+Chr(34)+"$"+Chr(34)+",Real Drive"
            ToolTipInfo_Text$ = "Re/load the Directory of the Real Drive"
            SSTTIP::TooltTip(WindowID( DC::#_Window_005), DC::#Button_207 ,ToolTipInfo_Text$, ToolTipInfoTitle$,1, ToolTipLen, 0, ToolTipFont ,#False)            
        EndIf
    EndProcedure    
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 2096
; FirstLine = 946
; Folding = nmH5-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode