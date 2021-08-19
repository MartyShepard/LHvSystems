;================================================================================================================================     
;   Combobox Gadget EX
;   
;_______________________________________________________________________________________________________________________________     


DeclareModule ComboBoxEX 
    
    
    Declare.l CBCreate(ComboBoxGadgetID.i, x.i = 0, y.i = 0, w.i = 128, h.i = 22, flags.l = #Null, CenterText.i = #False)  
    Declare.l CBBorderless(ComboBoxGadgetID.i, ContainerW.i = 0, cboxX.i = -4, cboxY.i = -4, cboxW.i = 22, cboxh = 8)
    
    Declare.l Get_ContainerID(ComboBoxGadgetID.i)
    
    Declare.l SetRGB(ComboBoxGadgetID.i, Back.l = $3D3D3C, Text.l = $06A5A9, Default_Select.l = $767575, HighLighted.l = $767575)
    
    Declare.l Set_Font(ComboBoxGadgetID.i, FontNameID.l = #Null)
    Declare.l SetItemHeight(ComboBoxGadgetID.i, Height.i = 12) 
    Declare.l SetItemWidth (ComboBoxGadgetID.i, Width.i  = 12)   
    
    Declare.l DropDown(ComboBoxGadgetID.i)    
    
    Declare.l CallCombobox(hwnd, msg, wParam, lParam)
    Declare   Set_Callback(pbnr, parent, xyz = 0)
    Declare.l ComboBoxEXCall(lparam, hwnd)
      
EndDeclareModule

Module ComboBoxEX
    
    Structure ComboBoxGadgetData
       parent.i
       gadget.i
       oldprc.i
       ;xyz
       laenge.i
       RGB_Back.i
       RGB_Front.i
   EndStructure 
   
    Structure CBEXOBJECT
        FontData.l              ; Der Fontname (Übergabe als FontID)
        CenterText.i            ; Text in der ComboBox Zentrieren        
        RGB_Back.i              ; Farbe für den Hintergrund
        RGB_TextColor.i         ; Text Farbe
        RGB_Select_DEFAULT.i    ; Farbe des AusgewähltenEintrag
        RGB_Select_HOTLIGHT.i   ; Farbe wenn man den Eintrag Auswählt
        ContainerID.i           ; Container ID
        ContainerID_Width.i     ; Containter Weite (Resize)  
        ComboBox_ID.i           ; Combobox ID (GadgetID)  
        ComboBox_Width.i        ; ComboBox Weite
        ComboBox_Height.i       ; ComboBox Höhe 
        pTextHeight.d           ; Text Höhe in Pixel
        
    EndStructure     
    Global Dim CBData.CBEXOBJECT(128) 
    
    Debug "*DRAWITEM\ItemState: #ODS_SELECTED    : " + Str(#ODS_SELECTED)
    Debug "*DRAWITEM\ItemState: #ODS_COMBOBOXEDIT: " + Str(#ODS_COMBOBOXEDIT) 
    Debug "*DRAWITEM\ItemState: #ODA_DRAWENTIRE  : " + Str(#ODA_DRAWENTIRE)                                      
    Debug "*DRAWITEM\ItemState: #ODA_FOCUS       : " + Str(#ODA_FOCUS)                                        
    Debug "*DRAWITEM\ItemState: #ODA_SELECT      : " + Str(#ODA_SELECT)                                       
    Debug "*DRAWITEM\ItemState: #ODS_CHECKED     : " + Str(#ODS_CHECKED)                                    
    Debug "*DRAWITEM\ItemState: #ODS_DEFAULT     : " + Str(#ODS_DEFAULT)                                       
    Debug "*DRAWITEM\ItemState: #ODS_GRAYED      : " + Str(#ODS_GRAYED)        
    Debug "*DRAWITEM\ItemState: #ODS_HOTLIGHT    : " + Str(#ODS_HOTLIGHT)                                     
    Debug "*DRAWITEM\ItemState: #ODS_INACTIVE    : " + Str(#ODS_INACTIVE)                                   
    Debug "*DRAWITEM\ItemState: #ODS_NOACCEL     : " + Str(#ODS_NOACCEL)        
    Debug "*DRAWITEM\ItemState: #ODS_NOFOCUSRECT : " + Str(#ODS_NOFOCUSRECT) 
    ;****************************************************************************************************
    ; 
    ;____________________________________________________________________________________________________      
    Procedure.l Get_pTextHeight_(hwnd)
        hDC = GetDC_(hwnd) 
        hFont = SendMessage_(hwnd,#WM_GETFONT,0,0)
        If hFont And hDC 
            SelectObject_(hDC,hFont) 
        EndIf 
        GetTextExtentPoint32_(hDC, GetGadgetText(GadgetID(hwnd)), Len(GetGadgetText(GadgetID(hwnd))) , lpSize.SIZE)
        result=lpSize\cy
        ProcedureReturn result
    EndProcedure    
    
    Procedure.l Set_TextHeight(*DrawItem.DRAWITEMSTRUCT, String$, StrLen.i)
        
        Protected fntSinze.i 
                
        GetTextExtentPoint32_(*DrawItem\hDC, String$, StrLen , lpSize.SIZE)
        fntSinze.i = lpSize\cy
        
        boxHeight.i= *DrawItem\rcItem\bottom - *DrawItem\rcItem\top
        If ( boxHeight >= fntSinze )
            
            boxHeight - fntSinze
            boxHeight / 2
            *DrawItem\rcItem\top = *DrawItem\rcItem\top + boxHeight
            ProcedureReturn 
        EndIf 
        
    EndProcedure    
    
  
    ;****************************************************************************************************
    ; 
    ;____________________________________________________________________________________________________               
   Procedure.l ComboBoxEXCall(lparam, hwnd)
       Protected Strings$              

       If IsWindow(hwnd)
           
           *DrawItem.DRAWITEMSTRUCT = lparam
           Select *DrawItem\CtlType                              
               Case #ODT_COMBOBOX      
                   
                   For n = 0 To 127 
                       If ( CBData(n)\ComboBox_ID = *DrawItem\CtlID )
                                                                                
                           Select *DrawItem\ItemState
                               Case #ODS_SELECTED
                                   Debug "*DRAWITEM\ItemState: #ODS_SELECTED    : " + Str(#ODS_SELECTED)
                                   ;
                                   ; Farbe wenn man gerade den Eintrag selelktiert
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Select_DEFAULT))                                  
                               Case #ODS_COMBOBOXEDIT
                                   Debug "*DRAWITEM\ItemState: #ODS_COMBOBOXEDIT: " + Str(#ODS_COMBOBOXEDIT) 
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back))                                   
                               Case #ODA_DRAWENTIRE
                                   Debug "*DRAWITEM\ItemState: #ODA_DRAWENTIRE  : " + Str(#ODA_DRAWENTIRE)                                      
                               Case #ODA_FOCUS
                                   Debug "*DRAWITEM\ItemState: #ODA_FOCUS       : " + Str(#ODA_FOCUS)                                        
                               Case #ODA_SELECT
                                   Debug "*DRAWITEM\ItemState: #ODA_SELECT      : " + Str(#ODA_SELECT)                                       
                               Case #ODS_CHECKED
                                   Debug "*DRAWITEM\ItemState: #ODS_CHECKED     : " + Str(#ODS_CHECKED)                                    
                               Case #ODS_DEFAULT
                                   Debug "*DRAWITEM\ItemState: #ODS_DEFAULT     : " + Str(#ODS_DEFAULT)                                       
                               Case #ODS_GRAYED
                                   Debug "*DRAWITEM\ItemState: #ODS_GRAYED      : " + Str(#ODS_GRAYED)        
                               Case    #ODS_HOTLIGHT
                                   Debug "*DRAWITEM\ItemState: #ODS_HOTLIGHT    : " + Str(#ODS_HOTLIGHT)                                     
                               Case    #ODS_INACTIVE
                                   Debug "*DRAWITEM\ItemState: #ODS_INACTIVE    : " + Str(#ODS_INACTIVE)                                   
                               Case   #ODS_NOACCEL
                                   Debug "*DRAWITEM\ItemState: #ODS_NOACCEL     : " + Str(#ODS_NOACCEL)        
                               Case   #ODS_NOFOCUSRECT
                                   Debug "*DRAWITEM\ItemState: #ODS_NOFOCUSRECT : " + Str(#ODS_NOFOCUSRECT)
                                 
                           EndSelect
                           
                           SetBkMode_(*DrawItem\hDC, #TRANSPARENT)
                  
                           
                           Select *DrawItem\ItemState
                               Case 784                                   
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back))                                   
                               Case 768 
                                   ;
                                   ; Die Hintergrund Farbe der Liste
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back))
                               Case 785
                                   ;
                                   ; Farbe wenn man gerade den Eintrag selelktiert
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Select_DEFAULT))                                   
                               Case 769         
                                   ;
                                   ; Farbe des Selektierten Eintrag. Wird geändert nachdem man in 
                                   ; Ausgewählt hat (Highlighted)
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Select_HOTLIGHT))
                               Case 4864
                                   ;
                                   ; Die Farbe der Box Selbst, Nicht die der Liste
                                   ; (Ist nach ProgrammStart Aktiviert)
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back))
                               Case 4881 
                                   ;
                                   ; Die Farbe der Box Selbst, Nicht die der Liste
                                   ; (Ist nach ein Eintrag ausgewählt wurde Aktiviert und verändert den Status 4864)  
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back))
                               Case 4113
                                   Debug "UPS 4113"
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back)) 
                               Case 17
                                   ;
                                   ; Farbe des Selektierten Eintrag. Wird geändert nachdem man in 
                                   ; Ausgewählt hat (Highlighted)
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Select_HOTLIGHT))                                
                               Case 1
                                   ;
                                   ; Farbe wenn man gerade den Eintrag selelktiert
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Select_DEFAULT))                                       
                               Case 0
                                   Debug "UPS 0"
                                   FillRect_(*DrawItem\hDC,*DrawItem\rcItem,CreateSolidBrush_(CBData(n)\RGB_Back))                                     
                               Default                                   
                                   Debug *DrawItem\ItemState  
                           EndSelect 
                           
                            Strings$ = Space(#MAX_PATH): vCenter.d = 0.0: CBData(n)\pTextHeight = 0:  lpSize.SIZE
                                                       
                   
                            If  ( CBData(n)\FontData <> 0 )
                                SelectObject_(*DrawItem\hDC, CBData(n)\FontData) 
                                SetTextColor_(*DrawItem\hDC, CBData(n)\RGB_TextColor)
                            EndIf
                            
                            SendMessage_(*DrawItem\hwndItem, #CB_GETLBTEXT, *DrawItem\itemID, @Strings$)                            
                            
                           
                            If ( *DrawItem\itemID = -1 )
                                
                                
                            Else
                                
                                Set_TextHeight(*DrawItem, Strings$, Len(Strings$)) 
                                
                                ;TextOut_(*DrawItem\hDC, *DrawItem\rcItem\left+2, *DrawItem\rcItem\top, Strings$, Len(Strings$)) 
                                If ( CBData(n)\CenterText = #True )
                                    DrawText_(*DrawItem\hdc, Strings$, Len(Strings$), *DrawItem\rcItem,0 )
                                    
                                Else
                                    DrawText_(*DrawItem\hdc, Strings$, Len(Strings$), *DrawItem\rcItem,0 )
                                EndIf                                        
                            EndIf  

                            Break
                       EndIf 
                   Next  
           EndSelect
       EndIf                           
   EndProcedure
       
    ;******************************************************************************************************************************************
    ;  ComboBoxGadget Callback Event
    ;__________________________________________________________________________________________________________________________________________   
    Procedure.l CallCombobox(hwnd, msg, wParam, lParam) 
        Protected *sc.ComboBoxGadgetData = GetWindowLongPtr_(hwnd, #GWL_USERDATA)                                          
        
        
          Select wParam >> 16
               Case #CBN_SETFOCUS
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_SETFOCUS     " +Str(wParam >> 16) )
                   
               Case #CBN_CLOSEUP
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_CLOSEUP      " +Str(wParam >> 16) )
                   
               Case #CBN_SELCHANGE
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_SELCHANGE    " +Str(wParam >> 16) )
                   
               Case #CBN_KILLFOCUS
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_KILLFOCUS    " +Str(wParam >> 16) )
                   
               Case #CBN_SELENDOK
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_SELENDOK     " +Str(wParam >> 16) )
                   
               Case #CBN_DROPDOWN 
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_DROPDOWN     " +Str(wParam >> 16) )
                   
               Case #CBN_DBLCLK    
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_DBLCLK       " +Str(wParam >> 16) )
                   
               Case #CBN_EDITCHANGE 
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_EDITCHANGE   " +Str(wParam >> 16) )               
                   
               Case #CBN_EDITUPDATE               
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_EDITUPDATE   " +Str(wParam >> 16) ) 
                   
               Case #CBN_ERRSPACE
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_ERRSPACE     " +Str(wParam >> 16) )
                   
               Case #CBN_SELENDCANCEL
                   Debug( "-- ComboBoxID "+Str(hwnd)+" "+ #PB_Compiler_Module + "Line " +Str(#PB_Compiler_Line) +" #CBN_ERRSPACE     " +Str(wParam >> 16) )                   
               Case 43
                   
               Default
                   ;Debug wParam >> 16
           EndSelect  
           
 
        Select msg                
            Case #WM_CTLCOLOREDIT, #WM_CTLCOLORLISTBOX                
                SetBkMode_   ( wParam, #TRANSPARENT )                
                SetTextColor_( wParam, *sc\RGB_Front ) 
                SetBkColor_  ( wParam, *sc\RGB_Back ) 
                ProcedureReturn *sc\RGB_Back                
                
            Case #WM_DESTROY   
                DeleteObject_    ( *sc\RGB_Back)
                SetWindowLongPtr_( hwnd , #GWL_WNDPROC , *sc\oldprc )
                FreeMemory       ( *sc )                       
        EndSelect
        
        ProcedureReturn CallWindowProc_(*sc\oldprc, hwnd, msg, wParam, lParam) 
     EndProcedure
    ;******************************************************************************************************************************************
    ;  ComboBox Callback Event/ Simple
    ;__________________________________________________________________________________________________________________________________________    
    Procedure.i ComboBoxGadgetRGBCallback ( ComboBoxGadgetID,  RGB.i, Mode.i)
        Protected *sc.ComboBoxGadgetData
        
        If IsGadget ( ComboBoxGadgetID )
            *sc = GetProp_(GadgetID( ComboBoxGadgetID ),"CT_ComboBox" )
            If Not *sc
                ProcedureReturn #False
            EndIf   
            
            Select Mode
                    
                 Case #PB_Gadget_BackColor
                    DeleteObject_( *sc\RGB_Back )
                    *sc\RGB_Back = CreateSolidBrush_(RGB)
                    
                Case #PB_Gadget_FrontColor
                    *sc\RGB_Front = RGB
                    
                Default
                    ProcedureReturn #False                   
            EndSelect
            ProcedureReturn #True
        EndIf
        
        ProcedureReturn #False
    EndProcedure
    ;******************************************************************************************************************************************
    ; ComboBox Callback Event/ Set
    ;__________________________________________________________________________________________________________________________________________      
    Procedure Set_Callback(pbnr, parent, xyz = 0)
        
        If IsGadget(pbnr)
            Protected spid = GadgetID(pbnr)      
            
            Protected *sc.ComboBoxGadgetData = AllocateMemory(SizeOf(ComboBoxGadgetData))
            
            
            *sc\gadget      = pbnr
            *sc\parent      = parent
            *sc\oldprc      = GetWindowLongPtr_(spid, #GWL_WNDPROC)   
            *sc\RGB_Front   = GetSysColor_( #COLOR_BTNTEXT )
            *sc\RGB_Back    = CreateSolidBrush_( GetSysColor_( #COLOR_WINDOW ) )
            
            If ( *sc\gadget  = #PB_Any )
                hWnd = GadgetID ( *sc\gadget  )
            Else
                hWnd = GadgetID ( *sc\gadget  )
            EndIf
            
            SetProp_( hWnd , "CT_ComboBox" , *sc ) 
            
            SetWindowLongPtr_(spid, #GWL_USERDATA, *sc)   
            SetWindowLongPtr_(spid, #GWL_WNDPROC, @CallCombobox())
            
        EndIf    
        
    EndProcedure               
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________        
    Procedure.l CBCreate(ComboBoxGadgetID.i, x.i = 0, y.i = 0, w.i = 128, h.i = 22, flags.l = #Null, CenterText.i = #False)                     
        
        Protected Container.l
        
        Container = ContainerGadget(#PB_Any,x ,y ,w, h,#PB_Container_BorderLess )        
                           
        For n = 0 To 127 
            If ( CBData(n)\ContainerID = 0 )

                CBData(n)\ComboBox_ID        = ComboBoxGadgetID
                CBData(n)\ContainerID        = Container
                CBData(n)\FontData           = #Null
                CBData(n)\RGB_Back           = CreateSolidBrush_( GetSysColor_( #COLOR_WINDOW ) )
                CBData(n)\RGB_TextColor      = GetSysColor_( #COLOR_BTNTEXT)
                CBData(n)\RGB_Select_DEFAULT = CreateSolidBrush_( $767575 )
                CBData(n)\RGB_Select_HOTLIGHT= CreateSolidBrush_( $767575 )                 
                CBData(n)\ComboBox_Width     = GadgetWidth(CBData(n)\ContainerID)
                CBData(n)\ComboBox_Height    = GadgetHeight(CBData(n)\ContainerID)             
                CBData(n)\ContainerID_Width  = w
                CBData(n)\CenterText.i       = CenterText
                CBData(n)\pTextHeight        = 0.0
                
                ComboBoxGadget(CBData(n)\ComboBox_ID, 0 ,0 ,CBData(n)\ComboBox_Width ,CBData(n)\ComboBox_Height,flags.l)
                
                SendMessage_(GadgetID(CBData(n)\ComboBox_ID),#CB_SETITEMHEIGHT,0,h-10)
                SendMessage_(GadgetID(CBData(n)\ComboBox_ID),#CB_SETDROPPEDWIDTH,w,0)
                            
                ;#ES_CENTER
                
                CloseGadgetList()             
                Break
            EndIf
        Next       
        ProcedureReturn CBData(n)\ContainerID         
    EndProcedure    
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________         
    Procedure.l CBBorderless(ComboBoxGadgetID.i, ContainerW.i = 0, cboxX.i = -4, cboxY.i = -4, cboxW.i = 22, cboxh = 8)
        
        
        For n = 0 To 127 
            If ( CBData(n)\ComboBox_ID = ComboBoxGadgetID )
                
                n_Width.i = CBData(n)\ComboBox_Width  + cboxW               
                nHeight.i = CBData(n)\ComboBox_Height + cboxh
                c_Width.i = CBData(n)\ContainerID_Width + ContainerW
                ResizeGadget(CBData(n)\ContainerID, #PB_Ignore, #PB_Ignore, c_Width, #PB_Ignore)              
                ResizeGadget(CBData(n)\ComboBox_ID, cboxX, cboxY, n_Width, nHeight)
               

            EndIf
        Next    
        ProcedureReturn -1        
    EndProcedure    
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l Get_ContainerID(ComboBoxGadgetID.i)
        
        For n = 0 To 127 
            If ( CBData(n)\ComboBox_ID = ComboBoxGadgetID )
                ProcedureReturn CBData(n)\ContainerID
            EndIf
        Next    
        ProcedureReturn -1
    EndProcedure    
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l SetRGB(ComboBoxGadgetID.i, Back.l = $3D3D3C, Text.l = $06A5A9, Default_Select.l = $767575, HighLighted.l = $767575)
        
        For n = 0 To 127 
            If ( CBData(n)\ComboBox_ID = ComboBoxGadgetID )
                 CBData(n)\RGB_Back           = Back.l 
                 CBData(n)\RGB_TextColor      = Text.l 
                 CBData(n)\RGB_Select_DEFAULT = Default_Select.l                  
                 CBData(n)\RGB_Select_HOTLIGHT= HighLighted.l 
                 ComboBoxGadgetRGBCallback (ComboBoxGadgetID, Text, #PB_Gadget_FrontColor)
                 ComboBoxGadgetRGBCallback (ComboBoxGadgetID, Back, #PB_Gadget_BackColor) 
                 SetGadgetColor(CBData(n)\ContainerID, #PB_Gadget_BackColor, Back)   
                 ProcedureReturn CBData(n)\ContainerID
                Break
            EndIf
        Next   
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l Set_Font(ComboBoxGadgetID.i, FontNameID.l = #Null)
        
        For n = 0 To 127 
            If ( CBData(n)\ComboBox_ID = ComboBoxGadgetID )
                 CBData(n)\FontData   = FontNameID
                 SetGadgetFont(CBData(n)\ComboBox_ID, CBData(n)\FontData)
                 ProcedureReturn CBData(n)\ContainerID   
                 Break
            EndIf
        Next 
        
    EndProcedure 
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l DropDown(ComboBoxGadgetID.i) 
            SendMessage_(GadgetID(ComboBoxGadgetID),#CB_SHOWDROPDOWN,1,1)                
    EndProcedure    
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l SetItemHeight(ComboBoxGadgetID.i, Height.i = 12)
        For n = 0 To 127 
            If ( CBData(n)\ComboBox_ID = ComboBoxGadgetID )            
                SendMessage_(GadgetID(ComboBoxGadgetID),#CB_SETITEMHEIGHT,0,Height)                
                Break;
            EndIf
        Next
    EndProcedure
    ;******************************************************************************************************************************************
    ;        
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l SetItemWidth(ComboBoxGadgetID.i, Width.i = 12)         
            SendMessage_(GadgetID(ComboBoxGadgetID),#CB_SETDROPPEDWIDTH,Width,#Null)          
    EndProcedure 
        
EndModule

CompilerIf #PB_Compiler_IsMainFile  
    
 

        Procedure.l CallBackEvnts(hwnd, uMsg, wParam, lParam)
            
            
            Select uMsg  
                Case #WM_DRAWITEM
                    ComboBoxEX::ComboBoxEXCall(lparam, 0)
                    ProcedureReturn #PB_ProcessPureBasicEvents
            EndSelect
            
            ProcedureReturn #PB_ProcessPureBasicEvents
        EndProcedure
    
        OpenWindow(0, 100, 200, 560, 148, "CB Test", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_Invisible )
        
    
    ; ================================================================================================== BEISPIEl 1    
    ;
    ; Combox Normal, Ohne Edit (String) 
    ComboBoxEX::CBCreate(8, 20, 20,230,30,#CBS_OWNERDRAWFIXED|#CBS_HASSTRINGS|#ES_CENTER)

    ;
    ; Combobox Borderless
    ComboBoxEX::CBBorderless(8)   
    ;
    ; Font Hinzufügen
    ComboBoxEX::Set_Font(8, FontID(LoadFont(#PB_Any, "Arial"  ,  14, #PB_Font_Bold)))
    ;
    ; Farbe Einstellen
    ComboBoxEX::SetRGB(8)
    
    ;
    ;
    ; =============================================================================================================  

    ;
    ;

        
    ; ================================================================================================== BEISPIEl 2
    ;
    ; Combox Normal,mit Edit (String)     
    ComboBoxEX::CBCreate(9, 20, 65,230,32,#PB_ComboBox_Editable|#CBS_OWNERDRAWFIXED|#CBS_HASSTRINGS,#True)         
    
        ;
        ; Combobox Borderless
        ComboBoxEX::CBBorderless(9)
    
        ;
        ; Font Hinzufügen    
        ComboBoxEX::Set_Font(9, FontID(LoadFont(#PB_Any, "Segeo UI"  ,  12, #PB_Font_Bold)))    
        
        
    ;
    ;
    ; =============================================================================================================
        


    
    ;
    ; Callback Initialisieren. Im Project über #WM_DRWITEM mit ComboBoxEX::ComboBoxEXCall(lparam, Window(ID))
    ;        
    SetWindowCallback(@CallBackEvnts(),0)     
    
    ;
    ; Benötogtes Callback nur für die Comboboxen die ein "EDIT" besitzen
    ComboBoxEX::Set_Callback(9, 0) 
    
        ;
        ; Farbe für den StringEdit Einstellen, erst nach dem Set_Callback
        ComboBoxEX::SetRGB(9, RGB(17, 35, 62), RGB(204, 204, 17))       
        
        HideWindow(0,0)

    ; ================================================================================================== Fenster Beispiel   
    ;
    ; Button Für Den Edit ComboBox
        ButtonGadget(10,490,20,65,30,"DropDown")
        
        handle = ComboBoxGadget(#PB_Any, 250, 20,230,30,0)
        ;
        ; Test Inhalte
        
        AddGadgetItem(8,-1, "Test #1") 
        AddGadgetItem(8,-1, "Test #2") 
        AddGadgetItem(8,-1, "Test #3")
        AddGadgetItem(8,-1, "Test #4")
        
        AddGadgetItem(handle,-1, "Test #1") 
        AddGadgetItem(handle,-1, "Test #2") 
        AddGadgetItem(handle,-1, "Test #3")        
        AddGadgetItem(handle,-1, "Test #4")           
        
        SetGadgetState(8,2)
        SetGadgetState(handle,2)
        
        handle = ComboBoxGadget(#PB_Any, 250, 65,230,32, #PB_ComboBox_Editable)
        
        For n = 0 To 50
            AddGadgetItem(9,-1, "Test #"+Str(n)) 
            AddGadgetItem(handle,-1, "Test #"+Str(n))             
        Next    
        
        

        SetGadgetState(9,4)
        SetGadgetState(handle,4)
        ;
        ;
        
        Repeat        
            Event = WaitWindowEvent()
            Select Event
                    
                Case #PB_Event_Gadget
                    
                    Select EventGadget()
                        Case 10
                            ;
                            ; Button Aktiveren, List herunterklappen
                            ComboBoxEX::DropDown(9)  
                            
                    EndSelect        
            EndSelect               
        Until Event = #PB_Event_CloseWindow    ; If the user has pressed on the close button
        
        End                                      ; All the opened windows are closed automatically by PureBasic
    

CompilerEndIf        

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 191
; FirstLine = 153
; Folding = -kw-
; EnableAsm
; EnableThread
; EnableXP