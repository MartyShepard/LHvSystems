DeclareModule GuruCallBack
    
    Declare.l CallBackEvnts(hwnd, uMsg, wParam, lParam)
    Declare   PostEvents_Resize(hwnd.i)
    Declare.i PostEvents_Close(hwnd.i) 
    Declare.i StringGadgetCallBack(hwnd, msg, wParam, lParam) 
    Declare StringGadgetSetCallback(pbnr, parent, xyz = 0)
    
    Declare.i ListGadgetSetCallback(pbnr, parent, xyz = 0)
    Declare ListGadgetCallBack(hwnd, msg, wParam, lParam) 
    
    Declare.i SplitGadgetSetCallback(pbnr, parent, xyz = 0)
    Declare SplitGadgetCallBack(hwnd, msg, wParam, lParam)  
    
    Declare.i ScrollAreaGadgetSetCallback(pbnr, parent, xyz = 0)
    Declare ScrollAreaGadgetCallBack(hwnd, msg, wParam, lParam)  
    
    Declare.l CallBackEvnts_Edit(hwnd, uMsg, wParam, lParam)
    
    Declare.i EditGadgetCallBack(hwnd, msg, wParam, lParam) 
    Declare EditGadgetSetCallback(pbnr, parent, xyz = 0)
    
    Declare     Window_Get_ClientSize(hWnd, nWidth, nHeight)
    
   
    
    
    Global isMediaMouseBack.i = #False
    
   Enumeration #PB_EventType_FirstCustomValue  
       #PB_EventType_StrgReturn
       #PB_EventType_StrgEscape
       #PB_EventType_StrgUp
       #PB_EventType_StrgDown
   EndEnumeration
   
EndDeclareModule

Module GuruCallBack
          
    Structure StringGadgetData
       parent.i
       gadget.i
       oldprc.i
       ;xyz
       laenge.i
    EndStructure
    
    Structure ListGadgetData
       parent.i
       gadget.i
       oldprc.i
       ;xyz
       laenge.i
    EndStructure    
    
    Structure SplitterGadgetData
       parent.i
       gadget.i
       oldprc.i
       ;xyz
       laenge.i
   EndStructure    
   
    Structure ScrollAreaGadgetData
       parent.i
       gadget.i
       oldprc.i
       ;xyz
       laenge.i
   EndStructure  
   
    Structure EditGadgetData
       parent.i
       gadget.i
       oldprc.i
       ;xyz
       laenge.i
    EndStructure   

    Enumeration
        #COLOR_BTNFACE                  = 15
        #APPCOMMAND_VOLUME_MUTE         = 8
        #APPCOMMAND_VOLUME_DOWN
        #APPCOMMAND_VOLUME_UP
        #APPCOMMAND_MEDIA_NEXTTRACK
        #APPCOMMAND_MEDIA_PREVIOUSTRACK
        #APPCOMMAND_MEDIA_STOP
        #APPCOMMAND_MEDIA_PLAY_PAUSE
        #APPCOMMAND_MEDIA_PLAY          = 46
        #APPCOMMAND_MEDIA_PAUSE
        #APPCOMMAND_MEDIA_RECORD
        #APPCOMMAND_MEDIA_FAST_FORWARD
        #APPCOMMAND_MEDIA_REWIND
        #APPCOMMAND_MEDIA_CHANNEL_UP
        #APPCOMMAND_MEDIA_CHANNEL_DOWN 
        #APPCOMMAND_BROWSER_BACKWARD    = $8001 ;//32769
        #APPCOMMAND_BROWSER_FORWARD     = $8002 ; //32770        
    EndEnumeration
    
    Macro LOWORD( word )   : (word & $FFFF)             : EndMacro   
   ;**************************************************************************************************************************************************************** 
   ; 
   ;****************************************************************************************************************************************************************
    Macro IsModified( EvntGadget )  
        Bool(SendMessage_( GadgetID ( EvntGadget ), #EM_GETMODIFY, 0, 0) )        
    EndMacro    
    
    Procedure.l CallBack_AppCommand(hwnd,lParam)
                ;
                ;
                ;
                ;Select (lParam >> 16) & $FFFF
                ;Case #APPCOMMAND_VOLUME_MUTE          :Request::SetDebugLog("#APPCOMMAND_VOLUME_MUTE          : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_VOLUME_DOWN          :Request::SetDebugLog("#APPCOMMAND_VOLUME_DOWN          : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_VOLUME_UP            :Request::SetDebugLog("#APPCOMMAND_VOLUME_UP            : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_NEXTTRACK      :Request::SetDebugLog("#APPCOMMAND_MEDIA_NEXTTRACK      : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_PREVIOUSTRACK  :Request::SetDebugLog("#APPCOMMAND_MEDIA_PREVIOUSTRACK  : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_STOP           :Request::SetDebugLog("#APPCOMMAND_MEDIA_STOP           : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_PLAY_PAUSE     :Request::SetDebugLog("#APPCOMMAND_MEDIA_PLAY_PAUSE     : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_RECORD         :Request::SetDebugLog("#APPCOMMAND_MEDIA_RECORD         : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_PLAY           :Request::SetDebugLog("#APPCOMMAND_MEDIA_PLAY           : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_FAST_FORWARD   :Request::SetDebugLog("#APPCOMMAND_MEDIA_FAST_FORWARD   : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_REWIND         :Request::SetDebugLog("#APPCOMMAND_MEDIA_REWIND         : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_CHANNEL_DOWN   :Request::SetDebugLog("#APPCOMMAND_MEDIA_CHANNEL_DOWN   : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_MEDIA_CHANNEL_UP     :Request::SetDebugLog("#APPCOMMAND_MEDIA_CHANNEL_UP     : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;Case #APPCOMMAND_BROWSER_BACKWARD     :Request::SetDebugLog("#APPCOMMAND_BROWSER_BACKWARD     : "+ #PB_Compiler_Module + " #" + Str(#PB_Compiler_Line))
                ;  If ( IsWindow(hwndID.i) And GetActiveWindow() = hwndID.i ): isMediaMouseBack = 32769: EndIf
                    ;Default
                        ;Debug Str( (lParam >> 16) & $FFFF)
                        ;isMediaMouseBack = #WM_APPCOMMAND
                ;EndSelect                 
                ;
                ;        
    EndProcedure   
    ;******************************************************************************************************************************************
    ;  
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.i Window_Get_ClientSize(hWnd, nWidth, nHeight)
        
        Define rcClient.RECT
        Define rcWind.RECT
        Define ptDiff.POINT
        
        GetClientRect_( hwnd , @rcClient)
        GetWindowRect_( hwnd , @rcWind)       
        
        ptDiff\x = (rcWind\right - rcWind\left) - rcClient\right
        ptDiff\y = (rcWind\bottom - rcWind\top) - rcClient\bottom
        
        MoveWindow_(hwnd ,rcWind\left, rcWind\top, nWidth + ptDiff\x, nHeight + ptDiff\y, #True);                     
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Combobox Call
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.l ComboBoxCol( hWnd.l, Message.l, wParam.l, lParam.l )                     
        Select Message 
          Case #WM_CTLCOLOREDIT, #WM_CTLCOLORLISTBOX   
                                                        ; Background Color
              SetBkMode_(wParam,#TRANSPARENT)           ; wParam ist das DC  
              
              SetTextColor_(wParam, RGB(17, 188, 244))   ; Schriftfarbe
              
               ProcedureReturn CreateSolidBrush_(RGB(71,71,71)); ProcedureReturn GetStockObject_(#WHITE_BRUSH)
        EndSelect 
                      
    EndProcedure     
    
    ;******************************************************************************************************************************************
    ; 
    ;__________________________________________________________________________________________________________________________________________        
    Procedure CallBackResetButton(hwnd)
        
        If IsWindow(DC::#_Window_001)
        ElseIf IsWindow(DC::#_Window_006)            
        Else
            ;
            ; Resete den Close Button
            ButtonEX::SetState(DC::#Button_203,0) 
            ButtonEX::SetState(DC::#Button_278,0)             
        EndIf
         
    EndProcedure  
    
    ;******************************************************************************************************************************************
    ; Resize nur für bestimmte Fenster
    ;__________________________________________________________________________________________________________________________________________        
    Procedure CallBackResze(hwnd)
        
        ;
        ; Resize nur für bestimmte Fenster
        Select hwnd
                ;
                ; 
            Case DC::#_Window_001
                ;
                ;
            Case DC::#_Window_006                             
                MagicGui::InteractiveGadgets_Edit(hwnd, 1)                
                 
             Default
                MagicGui::InteractiveGadgets(hwnd, 1)
        EndSelect        
    EndProcedure        
    
    
    ;******************************************************************************************************************************************
    ; Verändert den Status des Fenster
    ;__________________________________________________________________________________________________________________________________________
    Procedure CallBackOver_WinState_MAX_RESTORE(hwnd)
        
        Protected state.i
        
        ;
        ; Selektiere nur Fenster die das unterstützen
        Select hwnd
                ;
                ; 
            Case DC::#_Window_001
                ;
                ;
            Default
                ;
                ; *********************************************
                state.i = GetWindowState(hwnd)
                            
            Select state
                    ;
                    ;
                Case #PB_Window_Normal
                    ShowWindow_(WindowID(hwnd), #SW_MAXIMIZE)
                    DesktopEX::Get_TaskbarHeight(hwnd)
                    ;
                    ;
                Default
                    ShowWindow_(WindowID(hwnd), #SW_RESTORE)                    
            EndSelect  
             RedrawWindow_(hwnd,#Null,#Null,#RDW_INVALIDATE|#RDW_UPDATENOW)
        EndSelect  
         
       
    EndProcedure
    
                                  
    ;******************************************************************************************************************************************
    ; 
    ;__________________________________________________________________________________________________________________________________________        
    Procedure CallBackOver(hwnd, uMsg, TempW, TempH, lParam, SnapHeight.i = 30)
        Protected pt.Point, TitleText$
                                         
        Select Form::IsOverObject(WindowID(hwnd))
                
            Case 1                                  
                 pt\y = (lParam>>16) & $FFFF
                 pt\x = lParam & $FFFF  
                 
                 
                 If  (pt\x >= 0)  And (pt\y >= 0) And (pt\x <= TempW) And (pt\y <= TempH) 
                    ;
                    ;=============================================================================
                    ;                                 
                     If (pt\y >= 0) And (pt\y <= SnapHeight)  
                         
                         
                         ;
                         ; Message vom WindowsOS abfangen
                         Select uMsg      
                                ;
                                ;
                                ; Maus Halten und Fenster Verschieben                                 
                             Case #WM_LBUTTONDOWN,#WM_MOUSEMOVE
                                ReleaseCapture_() 
                                SendMessage_(WindowID(hwnd), #WM_NCLBUTTONDOWN, #HTCAPTION, 0)   
                                ;                           
                                ; Mit Links DoppelKlick den Status des Fenster Verändern
                            Case #WM_LBUTTONDBLCLK                                                
                                CallBackOver_WinState_MAX_RESTORE(hwnd) 
                                
                            Case #WM_RBUTTONUP
                                If hwnd = DC::#_Window_001
                                    
                                    
                                    If WindowHeight(hwnd) <> 30                                         
                                        SSTTIP::ToolTipMode(0,DC::#Button_287,vSystem::System_InfoToolTip() )   
                                        ResizeWindow(hwnd,#PB_Ignore,#PB_Ignore,#PB_Ignore,SnapHeight)
                                        
                                        ; Hide Info Window
                                        If IsWindow( DC::#_Window_006 )
                                            HideWindow( DC::#_Window_006, 1)
                                        EndIf    
                                        ;
                                        ; Zeigt den Aktullen Title in der Titelseite
                                        SetGadgetText(DC::#Text_005, Startup::*LHGameDB\TitleVersion + vItemTool::Item_GetTitleName())
                                    Else 
                                        SSTTIP::ToolTipMode(0,DC::#Button_287,vSystem::System_InfoToolTip() )   
                                        ResizeWindow(hwnd,#PB_Ignore,#PB_Ignore,#PB_Ignore,720 + Startup::*LHGameDB\WindowHeight)
                                        
                                        SetGadgetText(DC::#Text_005, Startup::*LHGameDB\TitleVersion)
                                        
                                        ; Resize Info Window nur wenn man sich nicht im Edit Modus befindet
                                        If IsWindow( DC::#_Window_006 ) And (Startup::*LHGameDB\Switch = 0)
                                            HideWindow( DC::#_Window_006, 0,#PB_Window_NoActivate  )
                                        EndIf                                     
                                        
                                    EndIf 
                                EndIf
                                
                        EndSelect 
                        
                          
                    ;
                    ;=============================================================================
                    ;    
                    ElseIf (pt\y >= (TempH-SnapHeight)) And (pt\y <= TempH)
                        ;
                        ;
                      
                        Select uMsg
                                ;
                                ;
                                ; Maus Halten und Fenster Verschieben                                
                            Case #WM_LBUTTONDOWN,#WM_MOUSEMOVE
                                ReleaseCapture_() 
                                SendMessage_(WindowID(hwnd), #WM_NCLBUTTONDOWN, #HTCAPTION, 0)                                           
                            Case #WM_LBUTTONDBLCLK     
                                ;                           
                                ; Mit Links DoppelKlick den Status des Fenster Verändern                                
                                CallBackOver_WinState_MAX_RESTORE(hwnd)                                                     
                        EndSelect                         
                    EndIf 
                    ;
                    ;=============================================================================
                    ;                     
                EndIf                
        EndSelect       
    EndProcedure            
    ;******************************************************************************************************************************************
    ; 
    ;__________________________________________________________________________________________________________________________________________     
    Procedure OnDrawItem(hWnd, lParam)
        
        Protected  Text$ = Space(#MAX_PATH)
        
        *lpdis.DRAWITEMSTRUCT = lparam        
        
        If (*lpdis\itemID > -1 )
            
            Select *lpdis\itemAction
                Case #ODA_DRAWENTIRE               
                    
                    ;
                    ; Text Color
                    If( *lpdis\itemState & #ODS_SELECTED )
                        ;
                        ; Highlighted
                        SetTextColor_(*lpdis\hDC,RGB(28, 58, 119)) ;$4F1920
                        SetBkColor_( *lpdis\hDC, RGB(177, 203, 239));;$DF9DA6 
                        hBackBrush = CreateSolidBrush_( RGB(177, 203, 239)  );
                        
                    Else
                        ;
                        ; Not Highlighted
                        SetTextColor_(*lpdis\hDC,RGB(177, 203, 239)) ;$B55D6C
                        SetBkColor_( *lpdis\hDC,  RGB(28, 58, 119))  ;$792731 
                        hBackBrush = CreateSolidBrush_( RGB(28, 58, 119) ); $792731                       
                    EndIf  
                    
                    Dim itemrect.RECT(3)
                    For i = 0 To 2                                      ; Columns
                        RtlZeroMemory_(@itemrect(i),SizeOf(RECT))
                        
                        itemrect(i)\top = i
                        
                        SendMessage_(*lpdis\hwndItem, #LVM_GETSUBITEMRECT, *lpdis\itemid, @itemrect(i))
                        
                        text$ = GetGadgetItemText(GetDlgCtrlID_(*lpdis\hwndItem), *lpdis\itemid, i)
                        
                        SelectObject_(*lpdis\hDC, GetStockObject_(#NULL_PEN))
                        
                        SelectObject_(*lpdis\hDC, hBackBrush)
                        Rectangle_ (*lpdis\hDC, itemrect(i)\left, itemrect(i)\top+1, itemrect(i)\right, itemrect(i)\bottom-1)
                        TextOut_(*lpdis\hDC, itemrect(i)\left, itemrect(i)\top, text$, Len(text$))
                        
                        DeleteObject_(hBackBrush)                        
                    Next            
                Case #ODA_SELECT                    
                Case #ODA_FOCUS  
            EndSelect
        EndIf      
    EndProcedure              
    
    Procedure Lmit_Window_Move(lparam, hwndID)  
        
;         Protected screenwidth.i  = DesktopEX::MonitorInfo_Display_Size(#False ,#True ) 
;         Protected screenheight.i = DesktopEX::MonitorInfo_Display_Size(#True  ,#False)          
; 
;         *windowRect.Rect = lparam 
;         
;         If  *windowRect\left <= 0 
;             *windowRect\left = 0 
;             *windowRect\right = *windowRect\left + WindowWidth( hwndID,#PB_Window_FrameCoordinate)            
;         EndIf 
;         
;         If  *windowRect\Top < 0  
;             *windowRect\Top = 0 
;             *windowRect\bottom = *windowRect\Top + WindowHeight( hwndID,#PB_Window_FrameCoordinate)                    
;         EndIf 
;         
;         If  *windowRect\right >= screenwidth  
;             *windowRect\left = screenwidth -  WindowWidth( hwndID,#PB_Window_FrameCoordinate) 
;             *windowRect\right = *windowRect\left + WindowWidth( hwndID,#PB_Window_FrameCoordinate) 
;         EndIf 
;         
;         If  *windowRect\bottom >= screenheight  
;             *windowRect\Top = screenheight  -  WindowHeight( hwndID,#PB_Window_FrameCoordinate) 
;             *windowRect\bottom = *windowRect\top + WindowHeight( hwndID,#PB_Window_FrameCoordinate) 
;         EndIf               
      EndProcedure      
    
      Procedure Dock_Window()           
        If IsWindow( DC::#_Window_006 ) And IsWindow( DC::#_Window_001 )
            
;             Define SnapSrcePos.Point, SnapDestPos.Point
;             
;             GetWindowRect_(WindowID(DC::#_Window_001), SrceWindow.RECT)
;             GetWindowRect_(WindowID(DC::#_Window_006), DestWindow.RECT)
;             
;             SnapSrcePos\x =  WindowX( DC::#_Window_001 ) + WindowWidth( DC::#_Window_001 )
;             SnapSrcePos\y =  WindowY( DC::#_Window_001 )             
            
            ;SetWindowPos_(WindowID(DC::#_Window_006), 0, SnapSrcePos\x, DestWindow\top, 0, 0, #SWP_NOSIZE|#SWP_NOACTIVATE) 
        EndIf 
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Editor Information Windows Callback
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l CallBackEvnts_Edit(hwnd, uMsg, wParam, lParam)
        Protected hwndID.i, TempX.i, TempY.i, TempH.i, TempW.i
        
        Protected Result = #PB_ProcessPureBasicEvents 
        
        If IsWindow(DC::#_Window_006): hwndID.i = DC::#_Window_006: EndIf                 
        
        If IsWindow(hwndID.i) <> 0                
            TempX = WindowX(hwndID.i): TempY = WindowY(hwndID.i): TempW = WindowWidth(hwndID.i): Temph = WindowHeight(hwndID.i)
            GetWindowRect_(WindowID(hwndID.i), WR)  
        EndIf        
        
            
        Select uMsg         
                ;
                ;
            Case #WM_MOVE,#WM_SIZE,#WM_SIZING
                If ( hwndID.i <> 0 )
                    FORM::ResizeGadgetOS_Windows(FORM::Get_GadgetClass(hwndID), hwndID)
                    ;
                    ; Window Resize, Position Veränderung
                    Select uMsg
                        Case #WM_MOVE
                        Case #WM_SIZE
                        Case #WM_SIZING                                
                    EndSelect     
                    
                    vInfo::Window_Live_Update()
                    hwndID.i = CallBackResze(hwndID.i)                           
                    ProcedureReturn Result
                EndIf
                ;
                ;
                
            Case #WM_LBUTTONDOWN,#WM_MOUSEMOVE,#WM_LBUTTONDBLCLK, #WM_RBUTTONUP                
                
                
                If ( hwndID.i <> 0 )
                    
                    
                    ;
                    ;
                    ; Mouse befindet sich über dem Object
                    ; Fenster Verschieben
                    CallBackOver(hwndID.i, uMsg, TempW, TempH, lParam)
                    
                    ProcedureReturn Result
                EndIf  
                
            Case #WM_MOVING
                If ( hwndID.i <> 0 )                    
                    ;ResizeWindow( hwndID, #PB_Ignore, #PB_Ignore,#PB_Ignore, #PB_Ignore)
                    ;Lmit_Window_Move(lparam, hwndID) 
                    ProcedureReturn Result
                EndIf
                
                
            Case #WM_EXITSIZEMOVE
                If ( hwndID.i <> 0 )                              
                    vInfo::Window_Props_Save()                        
                    vInfo::Window_Reload()
                    ProcedureReturn Result
                EndIf
                
            Case #WM_NOTIFY
                If ( hwndID.i <> 0 )                     
                    Protected *el.ENLINK = lParam
                    
        
                    If ( *el\nmhdr\code = #EN_LINK )

                        If ( *el\msg = #WM_LBUTTONDOWN ) Or ( *el\msg = #WM_RBUTTONDOWN )
                            
                            Protected *Buffer = AllocateMemory(512)
                            If *Buffer
                                Protected txt.TEXTRANGE                      
                                txt\chrg\cpMin = *el\chrg\cpMin
                                txt\chrg\cpMax = *el\chrg\cpMax
                                txt\lpstrText  = *Buffer
                                If ( GetActiveGadget( ) = vInfo::Tab_GetGadget() )
                                    
                                    SendMessage_( GadgetID( vInfo::Tab_GetGadget() ), #EM_GETTEXTRANGE, 0, txt)
                                    Select *el\msg
                                        Case #WM_LBUTTONDOWN : RunProgram( PeekS( *Buffer) )
                                            
                                        Case #WM_RBUTTONDOWN :
                                            Startup::*LHGameDB\InfoWindow\bURLOpnWith = #False
                                            Startup::*LHGameDB\InfoWindow\sUrlAdresse = PeekS( *Buffer)
                                    EndSelect
                                    
                                EndIf
                                FreeMemory(*Buffer)                                    
                            EndIf    
                        EndIf                
                    EndIf 
                EndIf
                
        EndSelect 
        ProcedureReturn Result
    EndProcedure      
    ;******************************************************************************************************************************************
    ;  Haupt Callback Event
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l CallBackEvnts(hwnd, uMsg, wParam, lParam)
        Protected hwndID.i, TempX.i, TempY.i, TempH.i, TempW.i, *Notify.NMDATETIMECHANGE, CurrentAktivGadget.i
        
        Protected Result = #PB_ProcessPureBasicEvents 
        
             
        If IsWindow(DC::#_Window_001): hwndID.i = DC::#_Window_001: EndIf
        If IsWindow(DC::#_Window_002): hwndID.i = DC::#_Window_002: EndIf
        If IsWindow(DC::#_Window_003): hwndID.i = DC::#_Window_003: EndIf 
        If IsWindow(DC::#_Window_004): hwndID.i = DC::#_Window_004: EndIf      
        If IsWindow(DC::#_Window_005): hwndID.i = DC::#_Window_005: EndIf                
        
        If ( IsWindow(hwndID.i) <> 0 )
            TempX = WindowX(hwndID.i): TempY = WindowY(hwndID.i): TempW = WindowWidth(hwndID.i): Temph = WindowHeight(hwndID.i)
            GetWindowRect_(WindowID(hwndID.i), WR)  
        EndIf
             
            
        Select uMsg         
            Case Startup::*LHGameDB\TaskbarCreate
                ;
                ; Explorer wurde neugeladen und das Icon muss 'aufgefrischt' werden
                SSTTIP::Tooltip_TrayIcon(ProgramFilename(), DC::#TRAYICON001, DC::#_Window_001, Startup::*LHGameDB\TrayIconTitle)                
                
            Case #WM_DRAWITEM
                If IsWindow(DC::#_Window_005 )
                    OnDrawItem(hwnd, lParam)
                EndIf    
                
            Case #WM_MEASUREITEM 
                If IsWindow(DC::#_Window_005 )
                    *lpmis.MEASUREITEMSTRUCT = lparam
                    *lpmis\itemheight = 12                       
                EndIf    
                
            Case #WM_APPCOMMAND
                CallBack_AppCommand(hwnd,lParam)
                
            Case #WM_COMMAND
                ;Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #WM_COMMAND: " + Str( LOWORD (wParam) ))                
                
            Case #WM_EXITSIZEMOVE                
                CallBackResetButton(hwndID.i)
                    If IsWindow(DC::#_Window_006)                    
                        vInfo::Window_Props_Save()                        
                        vInfo::Window_SetSnapPos()
                     ProcedureReturn Result
                    EndIf                

            Case #WM_NOTIFY                
                ;
                ; Kalender Event. 
                *Notify = lParam
                
                Select *Notify\nmhdr\code
                    Case #DTN_DROPDOWN:                     
                        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #WM_NOTIFY: Calendar is dropped down  "+Str(Result) )                     
                        
                    Case #DTN_CLOSEUP :                     
                        Request::SetDebugLog("Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" #WM_NOTIFY: Calendar is closed        "+Str(Result) )
                        
                        SetActiveGadget(DC::#String_005):                           
                        SendMessage_(GadgetID(DC::#String_005), #EM_SETSEL, Len(GetGadgetText(DC::#String_005)), Len(GetGadgetText(DC::#String_005)))
                EndSelect                
                ;
                ;
            Case #WM_MOVE,#WM_SIZE,#WM_SIZING
                If ( hwndID.i <> 0 )                                      
                    FORM::ResizeGadgetOS_Windows(FORM::Get_GadgetClass(hwndID), hwndID)
                    ;
                    ; Window Resize, Position Veränderung
                    Select uMsg
                        Case #WM_MOVE
                        Case #WM_SIZE
                        Case #WM_SIZING  
                    EndSelect 
                    
                    hwndID.i = CallBackResze(hwndID.i)                
                    ProcedureReturn Result
                EndIf
                ;
                ;
            Case #WM_MOVING
                If IsWindow(DC::#_Window_006)    
                        vInfo::Window_SetSnapPos()
                    ProcedureReturn Result
                EndIf    
                
            Case #WM_LBUTTONDOWN,#WM_MOUSEMOVE,#WM_LBUTTONDBLCLK, #WM_RBUTTONUP
                
                If ( hwndID.i <> 0 ) 
                     
                    ;
                    ;
                    ; Mouse befindet sich über dem Object
                    ; Fenster Verschieben
                    CallBackOver(hwndID.i, uMsg, TempW, TempH, lParam)
                    ProcedureReturn Result
                EndIf  
                
            Case #WM_ACTIVATE
                If IsWindow( DC::#_Window_006 ) 
                    Select (wParam & $FFFF)
                        Case 0; #WA_INACTIVE
                            ProcedureReturn Result
                            
                        Case 1; #WA_ACTIVE                            
                            SetWindowPos_(WindowID(DC::#_Window_006),#HWND_TOP, 0, 0, 0, 0, #SWP_NOMOVE     | 
                                                                                            #SWP_NOSIZE     |
                                                                                            #SWP_NOACTIVATE)
                            
                            SetActiveWindow( DC::#_Window_001 ): SetActiveGadget( DC::#ListIcon_001  )
                            ProcedureReturn Result
                            
                        Case 2; #WA_CLICKACTIVE
                            ProcedureReturn Result
                    EndSelect
                EndIf                    
          
                
            Case #WM_SYSCOMMAND 

                Select wParam
                    Case 61472
                        If IsWindow( DC::#_Window_006 )
                            ShowWindow_(WindowID(DC::#_Window_006),#SW_MINIMIZE)
                            SetActiveWindow( DC::#_Window_001 ): SetActiveGadget( DC::#ListIcon_001)
                            ProcedureReturn Result
                        EndIf    
                    Case 61728
                        If IsWindow( DC::#_Window_006 )
                            ShowWindow_(WindowID(DC::#_Window_006),#SW_RESTORE)
                            SetActiveWindow( DC::#_Window_001 ): SetActiveGadget( DC::#ListIcon_001)
                            ProcedureReturn Result
                        EndIf      
                EndSelect
                
            Case #WM_NCACTIVATE                
            Case #WM_INITMENUPOPUP        

              
        EndSelect 
        ProcedureReturn Result
    EndProcedure  
      
    ;****************************************************************************************************
    ; ZUsätzlicher Aufruf zu den Strings wie Automatische Farbänderung
    ;____________________________________________________________________________________________________               
    Procedure StringGadgetCallBack_Focus(lParam, activated.i = #False)        
        
        Protected ColorBack.i, ColorFrnt.i, CRT.point
        

        Select activated
            Case #True
                ColorFrnt = MagicGui::*ObjPos\c\rgb_FocusFrnt_New
                ColorBack = MagicGui::*ObjPos\c\rgb_FocusBack_New                               
            Case #False
                ColorFrnt = MagicGui::*ObjPos\c\rgb_FocusFrnt_Old 
                ColorBack = MagicGui::*ObjPos\c\rgb_FocusBack_Old              
        EndSelect        
        SetGadgetColor(lParam,#PB_Gadget_BackColor ,ColorBack)
        SetGadgetColor(lParam,#PB_Gadget_FrontColor,ColorFrnt)        
        
       
        
        Select lParam                                
                ;
                ; Nur Ausgewählte Gadgets die auf Seprate Code Befehel Reagieren sollen
        EndSelect
        
     EndProcedure
            
    ;****************************************************************************************************
    ; ZUsätzlicher Aufruf zu den Strings wie Automatische Farbänderung
    ;____________________________________________________________________________________________________               
    Procedure EditGadgetCallBack_Focus(lParam, activated.i = #False)        
        
        Protected ColorBack.i, ColorFrnt.i, CRT.point
        
        Startup::*LHGameDB\InfoWindow\bActivated = activated   
        
        Select activated
            Case #True                
                ColorFrnt = MagicGui::*ObjPos\c\rgb_FocusFrnt_Old
                ColorBack = MagicGui::*ObjPos\c\rgb_FocusBack_New      
            Case #False
                ColorFrnt = MagicGui::*ObjPos\c\rgb_FocusFrnt_Old 
                ColorBack = MagicGui::*ObjPos\c\rgb_FocusBack_Old                      
        EndSelect        
        SetGadgetColor(lParam,#PB_Gadget_BackColor ,ColorBack)
        SetGadgetColor(lParam,#PB_Gadget_FrontColor,ColorFrnt)        
        
        
        
        Select lParam                                
                ;
                ; Nur Ausgewählte Gadgets die auf Seprate Code Befehel Reagieren sollen
        EndSelect
        
     EndProcedure
                     
    ;******************************************************************************************************************************************
    ;  String Callback Event
    ;__________________________________________________________________________________________________________________________________________          
     Procedure.i StringGadgetCallBack(hwnd, msg, wParam, lParam) 
         
         Protected *strg.StringGadgetData = GetWindowLongPtr_(hwnd, #GWL_USERDATA)
         
         Select msg
                 ;
                 ;==================================================================================================================
                 ;               
             Case #WM_CHAR
                 
                 Select wparam                         
                     Case #VK_RETURN: PostEvent(#PB_Event_Gadget, *strg\parent, *strg\gadget, #PB_EventType_StrgReturn): ProcedureReturn 0                         
                     Case #VK_ESCAPE: PostEvent(#PB_Event_Gadget, *strg\parent, *strg\gadget, #PB_EventType_StrgEscape): ProcedureReturn 0                                                
                     Case 17,19     : PostEvent(#PB_Event_Gadget, *strg\parent, *strg\gadget, #PB_EventType_LostFocus ): ProcedureReturn 0                            
                     Default                                                       
                 EndSelect
                 
                 ;
                 ;==================================================================================================================
                 ;
             Case #WM_KEYDOWN             
                 ;
                 ;                  
                 Select wparam                                              
                     Case #VK_DOWN : PostEvent(#PB_Event_Gadget, *strg\parent, *strg\gadget, #PB_EventType_StrgDown): ProcedureReturn 0                                              
                     Case #VK_UP   : PostEvent(#PB_Event_Gadget, *strg\parent, *strg\gadget, #PB_EventType_StrgUp  ): ProcedureReturn 0                             
                     Default                                                               
                 EndSelect                                        
                 ;
                 ;==================================================================================================================
                 ;                                  
             Case #WM_LBUTTONDBLCLK 
                 Select *strg\gadget
                     Case DC::#String_112: VEngine::GetFile_Media(DC::#String_112 ): vEngine::Text_Show():    ProcedureReturn 0                           
                 EndSelect                                          
                 ;
                 ;==================================================================================================================
                 ;
             Case #WM_SETFOCUS     : PostEvent(StringGadgetCallBack_Focus(*strg\gadget,#True), *strg\parent, *strg\gadget) 
                 ;
                 ;==================================================================================================================
                 ;
             Case #WM_KILLFOCUS    : PostEvent(StringGadgetCallBack_Focus(*strg\gadget,#False), *strg\parent, *strg\gadget)                              
         EndSelect
         
         ProcedureReturn CallWindowProc_(*strg\oldprc, hwnd, msg, wParam, lParam) 
         
     EndProcedure 
           
    ;******************************************************************************************************************************************
    ; String Callback Event/ Set
    ;__________________________________________________________________________________________________________________________________________      
    Procedure StringGadgetSetCallback(pbnr, parent, xyz = 0)
        
        If IsGadget(pbnr)
            Protected strgid = GadgetID(pbnr)      
       
            Protected *strg.StringGadgetData = AllocateMemory(SizeOf(StringGadgetData))
       
            *strg\gadget = pbnr
            *strg\parent = parent
            *strg\oldprc = GetWindowLongPtr_(strgid, #GWL_WNDPROC)   
       
            SetWindowLongPtr_(strgid, #GWL_USERDATA, *strg)   
            SetWindowLongPtr_(strgid, #GWL_WNDPROC, @StringGadgetCallBack())
       EndIf    
       
   EndProcedure       
   ;******************************************************************************************************************************************
    ;  Listicon Callback Event
    ;__________________________________________________________________________________________________________________________________________          
     Procedure.i ListGadgetCallBack(hwnd, msg, wParam, lParam) 
         

         Protected *lb.ListGadgetData = GetWindowLongPtr_(hwnd, #GWL_USERDATA)
             
         Select msg
                 ;
                 ;==================================================================================================================
                 ; Entferne die Horizontale Scrollbar von der Hauptliste    
            Case #WM_NCCALCSIZE                
                ShowScrollBar_(GadgetID( *lb\gadget ),#SB_HORZ,#False)              
                 ;
                 ;==================================================================================================================
                 ;                
            Case #WM_SIZE                   
                RedrawWindow_(GadgetID( *lb\gadget ),#Null,#Null,#RDW_UPDATENOW|#RDW_INVALIDATE)                  
                 ;
                 ;==================================================================================================================
                 ;  Disable Numblock keys um zu vermiden das der Cursor gesetzt wird
            Case #WM_CHAR, #WM_KEYUP,#WM_KEYDOWN, #WM_SYSKEYDOWN, #WM_SYSKEYUP 
                If GetKeyState_(#VK_NUMPAD0)
                    ProcedureReturn 0
                EndIf 
                If GetKeyState_(#VK_NUMPAD1)
                    ProcedureReturn 0
                EndIf
                If GetKeyState_(#VK_NUMPAD2)
                    ProcedureReturn 0
                EndIf
                If GetKeyState_(#VK_NUMPAD3)
                    ProcedureReturn 0
                EndIf
                If GetKeyState_(#VK_NUMPAD4)
                    ProcedureReturn 0
                EndIf
                If GetKeyState_(#VK_NUMPAD5)
                    ProcedureReturn 0
                EndIf
                If GetKeyState_(#VK_NUMPAD6)
                    ProcedureReturn 0
                EndIf
                If GetKeyState_(#VK_NUMPAD7)
                    ProcedureReturn 0
                EndIf    
                If GetKeyState_(#VK_NUMPAD8)
                    ProcedureReturn 0
                EndIf 
                If GetKeyState_(#VK_NUMPAD9)
                    ProcedureReturn 0
                EndIf                   
                
            Case #WM_LBUTTONDBLCLK
            Case #WM_SETFOCUS        
            Case #WM_KILLFOCUS
            Case #WM_SIZING
            Case #WM_EXITSIZEMOVE
            Case #WM_SETREDRAW                                                             
            Case #WM_ERASEBKGND	               
            Case #WM_PAINT                
            Case #WM_CTLCOLORSCROLLBAR            
            Case #WM_HSCROLL
            Case #WM_VSCROLL, #WM_MOUSEWHEEL  
         EndSelect
         
         ProcedureReturn CallWindowProc_(*lb\oldprc, hwnd, msg, wParam, lParam) 
         
     EndProcedure 
     
    ;******************************************************************************************************************************************
    ; Listicon Callback Event/ Set
    ;__________________________________________________________________________________________________________________________________________      
    Procedure ListGadgetSetCallback(pbnr, parent, xyz = 0)
        
        If IsGadget(pbnr)
            Protected lbid = GadgetID(pbnr)      
       
            Protected *lb.ListGadgetData = AllocateMemory(SizeOf(ListGadgetData))
       
            *lb\gadget = pbnr
            *lb\parent = parent
            *lb\oldprc = GetWindowLongPtr_(lbid, #GWL_WNDPROC)   
       
            SetWindowLongPtr_(lbid, #GWL_USERDATA, *lb)   
            SetWindowLongPtr_(lbid, #GWL_WNDPROC, @ListGadgetCallBack())
       EndIf    
       
   EndProcedure    
   
    ;******************************************************************************************************************************************
    ;  SplitterGadget Callback Event
    ;__________________________________________________________________________________________________________________________________________          
   Procedure.i SplitGadgetCallBack(hwnd, msg, wParam, lParam) 
       
       Protected *sp.SplitterGadgetData = GetWindowLongPtr_(hwnd, #GWL_USERDATA) 
       
         Select msg
            Case #WM_NCCALCSIZE           
            Case #WM_SIZE                                  
            Case #WM_SIZING
            Case #WM_EXITSIZEMOVE
            Case #WM_SETREDRAW                                                             
            Case #WM_ERASEBKGND	               
            Case #WM_PAINT                
            Case #WM_CTLCOLORSCROLLBAR            
            Case #WM_HSCROLL
            Case #WM_VSCROLL, #WM_MOUSEWHEEL                       
            Case #WM_CHAR
            Case #WM_KEYDOWN                           
            Case #WM_LBUTTONDBLCLK 
            Case #WM_SETFOCUS
            Case #WM_KILLFOCUS                                         
                 
         EndSelect
         
       ProcedureReturn CallWindowProc_(*sp\oldprc, hwnd, msg, wParam, lParam) 
         
     EndProcedure    
    ;******************************************************************************************************************************************
    ; SplitterGadget Callback Event/ Set
    ;__________________________________________________________________________________________________________________________________________      
    Procedure SplitGadgetSetCallback(pbnr, parent, xyz = 0)
        
        If IsGadget(pbnr)
            Protected spid = GadgetID(pbnr)      
       
            Protected *sp.SplitterGadgetData = AllocateMemory(SizeOf(SplitterGadgetData))
       
            *sp\gadget = pbnr
            *sp\parent = parent
            *sp\oldprc = GetWindowLongPtr_(spid, #GWL_WNDPROC)   
       
            SetWindowLongPtr_(spid, #GWL_USERDATA, *sp)   
            SetWindowLongPtr_(spid, #GWL_WNDPROC, @SplitGadgetCallBack())
       EndIf    
       
   EndProcedure   
   
   ;******************************************************************************************************************************************
    ;  SplitterGadget Callback Event
    ;__________________________________________________________________________________________________________________________________________          
   Procedure.i ScrollAreaGadgetCallBack(hwnd, msg, wParam, lParam) 
       
       Protected *sc.SplitterGadgetData = GetWindowLongPtr_(hwnd, #GWL_USERDATA) 
       
       Select msg
               ;
               ;==================================================================================================================
               ;               
           Case #WM_VSCROLL
               Request::SetDebugLog("#ScrollArea "+Str(hwnd)+" "+ #PB_Compiler_Module + " #WM_VSCROLL       " + Str(#PB_Compiler_Line)) 
               ;SendMessage_( GadgetID( *sc\gadget), msg, #SB_THUMBTRACK,#SB_THUMBPOSITION)
           Case #WM_HSCROLL
               Request::SetDebugLog("#ScrollArea "+Str(hwnd)+" "+ #PB_Compiler_Module + " #WM_HSCROLL       " + Str(#PB_Compiler_Line))                      
           Case #SB_THUMBTRACK
               Request::SetDebugLog("#ScrollArea "+Str(hwnd)+" "+ #PB_Compiler_Module + " #SB_THUMBTRACK    " + Str(#PB_Compiler_Line))                                           
           Case #SB_THUMBPOSITION
               Request::SetDebugLog("#ScrollArea "+Str(hwnd)+" "+ #PB_Compiler_Module + " #SB_THUMBPOSITION " + Str(#PB_Compiler_Line))
               ;
               ;==================================================================================================================
               ;                                 
               
       EndSelect        
       ProcedureReturn CallWindowProc_(*sc\oldprc, hwnd, msg, wParam, lParam) 
         
     EndProcedure    
    ;******************************************************************************************************************************************
    ; SplitterGadget Callback Event/ Set
    ;__________________________________________________________________________________________________________________________________________      
    Procedure ScrollAreaGadgetSetCallback(pbnr, parent, xyz = 0)
        
        If IsGadget(pbnr)
            Protected spid = GadgetID(pbnr)      
       
            Protected *sc.ScrollAreaGadgetData = AllocateMemory(SizeOf(ScrollAreaGadgetData))
       
            *sc\gadget = pbnr
            *sc\parent = parent
            *sc\oldprc = GetWindowLongPtr_(spid, #GWL_WNDPROC)   
       
            SetWindowLongPtr_(spid, #GWL_USERDATA, *sc)   
            SetWindowLongPtr_(spid, #GWL_WNDPROC, @ScrollAreaGadgetCallBack())
       EndIf    
       
   EndProcedure      
   


   Procedure.i EditGadgetCallBack_NCCaclsize(hwnd)   
       
   EndProcedure    
   Procedure.i EditGadgetCallBack_NCPaint(hwnd)
       Static border_thickness = -2;
     
       
   EndProcedure    
   Procedure.i EditGadgetCallBack(hwnd, msg, wParam, lParam) 
       
       Protected *ed.EditGadgetData = GetWindowLongPtr_(hwnd, #GWL_USERDATA) 
       
       Static border_thickness = -2;       
       
       ;WM::DebugConstant(msg)
       
       
       If ( (msg >= #WM_KEYFIRST And msg <= #WM_KEYLAST) Or  (msg >= #WM_MOUSEFIRST And msg <= #WM_MOUSELAST)) And IsWindow( DC::#_Window_006 ) And ( GetActiveWindow() = DC::#_Window_006 )
           vInfo::Get_MaxLines()  
           Protected Range.CHARRANGE
           SendMessage_(hwnd, #EM_EXGETSEL, 0, @Range);
           
           Startup::*LHGameDB\InfoWindow\nMarked = Range\cpMax - Range\cpMin
           If (Range\cpMax = Range\cpMin)
               ; Debug "Caret Position" + Str(Startup::*LHGameDB\InfoWindow\nMarked)               
               SetGadgetText(DC::#Text_133, "")               
           ElseIf (Range\cpMax > Range\cpMin)
               Debug "Markiert +> " + Str(Startup::*LHGameDB\InfoWindow\nMarked)
               SetGadgetText(DC::#Text_133, " [ " + Str( Startup::*LHGameDB\InfoWindow\nMarked )+ " ]" )             
           ElseIf (Range\cpMax < Range\cpMin) 
               Debug "Markiert -< " + Str(Startup::*LHGameDB\InfoWindow\nMarked)
               SetGadgetText(DC::#Text_133, " [ " + Str( Startup::*LHGameDB\InfoWindow\nMarked )+ " ]"  )               
           EndIf
           
           
       EndIf
       
       Select msg
               
           Case Startup::*LHGameDB\InfoWindow\RegFndRpl
           ;Case #EM_EXGETSEL


           Case #WM_NCPAINT, #WM_EXITSIZEMOVE

               Flags = GetWindowLong_(hwnd,#GWL_STYLE)                 
               
               hdc = GetWindowDC_(GadgetID( *ed\gadget ));
               rc.RECT
               GetClientRect_(GadgetID( *ed\gadget ), rc);
               
               If ( Flags & #WS_VSCROLL )                  
                   rc\right  + 2 * border_thickness + 1
                   rc\bottom + 2 * border_thickness + 1
               Else
                   ;ResizeGadget( *ed\gadget, rc\left -1,rc\top -1,rc\right +2,rc\bottom +2)
                   ProcedureReturn 0
               EndIf                    
               
               
               hbrush   = GetStockObject_(#NULL_BRUSH);
               hpen     = CreatePen_(#PS_SOLID, 2 * border_thickness, GetWindowColor( DC::#_Window_006) );
               oldbrush = SelectObject_(hdc, hbrush)
               oldpen   = SelectObject_(hdc, hpen)     
              
               Rectangle_(hdc, rc\left, rc\top, rc\right, rc\bottom)
               
               SelectObject_(hdc, oldpen);
               SelectObject_(hdc, oldbrush);
               DeleteObject_(hpen)         ;
               DeleteObject_(hbrush)       ;
               
               ReleaseDC_(GadgetID( *ed\gadget ), hdc);                   
                   
           Case #WM_NCCALCSIZE
               *sz.NCCALCSIZE_PARAMS = lParam               
               InflateRect_(*sz\rgrc[0], -border_thickness, -border_thickness);
                ;                    Debug "" 
                ;                    Debug "*sz\lppos\cx             :" + Str( *sz\lppos\cx )
                ;                    Debug "*sz\lppos\cy             :" + Str( *sz\lppos\cy )
                ;                    Debug "*sz\lppos\flags          :" + Str( *sz\lppos\flags )
                ;                    Debug "*sz\lppos\hwnd           :" + Str( *sz\lppos\hwnd )
                ;                    Debug "*sz\lppos\hwndInsertAfter:" + Str( *sz\lppos\hwndInsertAfter )
                ;                    Debug "*sz\lppos\x              :" + Str( *sz\lppos\x )
                ;                    Debug "*sz\lppos\y              :" + Str( *sz\lppos\y )
                ;                    Debug "*sz\rgrc[0]\bottom       :" + Str( *sz\rgrc[0]\bottom )
                ;                    Debug "*sz\rgrc[0]\left         :" + Str( *sz\rgrc[0]\left )
                ;                    Debug "*sz\rgrc[0]\right        :" + Str( *sz\rgrc[0]\right )
                ;                    Debug "*sz\rgrc[0]\top          :" + Str( *sz\rgrc[0]\top )           
                                            
           Case #WM_CHAR                             
               If IsWindow( DC::#_Window_006 ) And ( GetActiveGadget() = vInfo::Tab_GetGadget()  )
                   
                   If ( GetAsyncKeyState_(#VK_CONTROL) & 32768 = 32768 And GetAsyncKeyState_(#VK_F) & 32768 = 32768)
                        vInfoMenu::MainSelect(508)
                        ProcedureReturn 0
                   EndIf    
                   If ( GetAsyncKeyState_(#VK_CONTROL) & 32768 = 32768 And GetAsyncKeyState_(#VK_O) & 32768 = 32768)
                        VEngine::GetFile_Media(DC::#String_112 ): vEngine::Text_Show():
                        ProcedureReturn 0                                              
                   EndIf                    
                   If ( GetAsyncKeyState_(#VK_CONTROL) & 32768 = 32768 And GetAsyncKeyState_(#VK_S) & 32768 = 32768)
                        VEngine::Text_UpdateDB()
                        ProcedureReturn 0                                              
                   EndIf 
                   If ( GetAsyncKeyState_(#VK_CONTROL) & 32768 = 32768 And GetAsyncKeyState_(#VK_P) & 32768 = 32768)
                        VInfoMenu::Cmd_Print( vInfo::Tab_GetGadget() )
                        ProcedureReturn 0                                              
                   EndIf                     
               EndIf    
               ;                     
               ; 
               ;                         
               ;                        ; CTRL+F : Such Dialog Öffnen
               ;                         If  GetKeyState_(#VK_CONTROL) & #VKeyIsDown)
               ;                             vEngine::MenuEdit_Select_(508)
               ;                             ProcedureReturn 0
               ;                         EndIf 
               ;                         
               ;                        ; CTRL+O : Öffnen Dialog Öffnen
               ;                         If ( GetKeyState_(#VK_CONTROL) And  GetKeyState_(#VK_O) )
               ;                             VEngine::GetFile_Media(DC::#String_112 ): vEngine::Text_Show():
               ;                             ProcedureReturn 0
               ;                         EndIf                         
               ; 
               ;                     
               ;                 EndIf
               If IsWindow( DC::#_Window_006 )
                   vInfo::Get_MaxLines()    
               EndIf   

  
           Case #WM_KEYUP   
                
               ;
               ;           
               If IsWindow( DC::#_Window_006 )
                   
                   Protected EvntGadget = vInfo::Tab_GetGadget()                     
                   
                   If ( GetActiveGadget() = EvntGadget )
                       
                           
                       
                       Select wparam                    
                               ;
                               ; Tasten die den text Modifizieren
                           Case #VK_0 To #VK_9                             
                               vInfo::Modify_Pressed(EvntGadget)
                               
                               
                           Case #VK_NUMPAD0 To #VK_NUMPAD9                             
                               vInfo::Modify_Pressed(EvntGadget)
                               vInfo::Caret_GetPosition() 
                               
                           Case #VK_A, #VK_B, #VK_C,#VK_D,#VK_E,#VK_F,#VK_G,#VK_H,#VK_I,#VK_J,#VK_K,#VK_L,#VK_M,#VK_N,#VK_O,#VK_P,#VK_Q,#VK_R,#VK_S,#VK_T,#VK_U,#VK_V,#VK_W,#VK_X,#VK_Y,#VK_Z                              
                               vInfo::Modify_Pressed(EvntGadget)
                               vInfo::Caret_GetPosition() 
                               
                           Case #VK_BACK, #VK_SPACE, #VK_RETURN, #VK_DELETE, #VK_TAB                              
                               vInfo::Modify_Pressed(EvntGadget)
                               vInfo::Caret_GetPosition() 
                               
                           Case #VK_ADD, #VK_SUBTRACT, #VK_MULTIPLY, #VK_DIVIDE                                   
                               vInfo::Modify_Pressed(EvntGadget)
                               vInfo::Caret_GetPosition() 
                               
                           Case #VK_OEM_MINUS, #VK_OEM_PLUS, #VK_OEM_PERIOD, #VK_OEM_COMMA, #VK_OEM_1, #VK_OEM_2, #VK_OEM_3, #VK_OEM_4, #VK_OEM_6, #VK_OEM_7, #VK_OEM_102                               
                               vInfo::Modify_Pressed(EvntGadget)
                               vInfo::Caret_GetPosition() 
                               ;
                               ; Tasten die den Text nicht ändern
;                            Case #VK_UP, #VK_DOWN, #VK_LEFT, #VK_RIGHT
                               
                           Default
;                                Debug "Edit CallBack Down :" + Str( wparam ) + " Code:" + Chr( wparam )                         
;                                
;                                If ( #VK_ACCEPT            = wparam ): Debug "Pressed : #VK_ACCEPT"            : EndIf
;                                If ( #VK_APPS              = wparam ): Debug "Pressed : #VK_APPS"              : EndIf
;                                If ( #VK_ATTN              = wparam ): Debug "Pressed : #VK_ATTN"              : EndIf
;                                
;                                If ( #VK_BROWSER_BACK      = wparam ): Debug "Pressed : #VK_BROWSER_BACK"      : EndIf
;                                If ( #VK_BROWSER_FAVORITES = wparam ): Debug "Pressed : #VK_BROWSER_FAVORITES" : EndIf
;                                If ( #VK_BROWSER_FORWARD   = wparam ): Debug "Pressed : #VK_BROWSER_FORWARD"   : EndIf
;                                If ( #VK_BROWSER_HOME      = wparam ): Debug "Pressed : #VK_BROWSER_HOME"      : EndIf
;                                If ( #VK_BROWSER_REFRESH   = wparam ): Debug "Pressed : #VK_BROWSER_REFRESH"   : EndIf
;                                If ( #VK_BROWSER_SEARCH    = wparam ): Debug "Pressed : #VK_BROWSER_SEARCH"    : EndIf
;                                If ( #VK_BROWSER_STOP      = wparam ): Debug "Pressed : #VK_BROWSER_STOP"      : EndIf
;                                
;                                If ( #VK_CANCEL            = wparam ): Debug "Pressed : #VK_CANCEL"            : EndIf
;                                If ( #VK_CAPITAL           = wparam ): Debug "Pressed : #VK_CAPITAL"           : EndIf 
;                                If ( #VK_CLEAR             = wparam ): Debug "Pressed : #VK_CLEAR"             : EndIf 
;                                If ( #VK_CONTROL           = wparam ): Debug "Pressed : #VK_CONTROL"           : EndIf 
;                                If ( #VK_CONVERT           = wparam ): Debug "Pressed : #VK_CONVERT"           : EndIf 
;                                If ( #VK_CRSEL             = wparam ): Debug "Pressed : #VK_CRSEL"             : EndIf
;                                
;                                If ( #VK_DECIMAL           = wparam ): Debug "Pressed : #VK_DECIMAL"           : EndIf 
;                                
;                                If ( #VK_END               = wparam ): Debug "Pressed : #VK_END"               : EndIf
;                                If ( #VK_EREOF             = wparam ): Debug "Pressed : #VK_EREOF"             : EndIf  
;                                If ( #VK_ESCAPE            = wparam ): Debug "Pressed : #VK_ESCAPE"            : EndIf  
;                                If ( #VK_EXECUTE           = wparam ): Debug "Pressed : #VK_EXECUTE"           : EndIf  
;                                If ( #VK_EXSEL             = wparam ): Debug "Pressed : #VK_EXSEL"             : EndIf  
;                                
;                                If ( #VK_FINAL             = wparam ): Debug "Pressed : #VK_FINAL"             : EndIf
;                                If ( #VK_F1                = wparam ): Debug "Pressed : #VK_F1"                : EndIf                          
;                                If ( #VK_F2                = wparam ): Debug "Pressed : #VK_F2"                : EndIf   
;                                If ( #VK_F3                = wparam ): Debug "Pressed : #VK_F3"                : EndIf   
;                                If ( #VK_F4                = wparam ): Debug "Pressed : #VK_F4"                : EndIf   
;                                If ( #VK_F5                = wparam ): Debug "Pressed : #VK_F5"                : EndIf   
;                                If ( #VK_F6                = wparam ): Debug "Pressed : #VK_F6"                : EndIf   
;                                If ( #VK_F7                = wparam ): Debug "Pressed : #VK_F7"                : EndIf   
;                                If ( #VK_F8                = wparam ): Debug "Pressed : #VK_F8"                : EndIf   
;                                If ( #VK_F9                = wparam ): Debug "Pressed : #VK_F9"                : EndIf   
;                                If ( #VK_F10               = wparam ): Debug "Pressed : #VK_F10"               : EndIf   
;                                If ( #VK_F11               = wparam ): Debug "Pressed : #VK_F11"               : EndIf   
;                                If ( #VK_F12               = wparam ): Debug "Pressed : #VK_F12"               : EndIf   
;                                If ( #VK_F13               = wparam ): Debug "Pressed : #VK_F13"               : EndIf   
;                                If ( #VK_F14               = wparam ): Debug "Pressed : #VK_F14"               : EndIf   
;                                If ( #VK_F15               = wparam ): Debug "Pressed : #VK_F15"               : EndIf   
;                                If ( #VK_F16               = wparam ): Debug "Pressed : #VK_F16"               : EndIf   
;                                If ( #VK_F17               = wparam ): Debug "Pressed : #VK_F17"               : EndIf                            
;                                If ( #VK_F18               = wparam ): Debug "Pressed : #VK_F18"               : EndIf   
;                                If ( #VK_F19               = wparam ): Debug "Pressed : #VK_F19"               : EndIf                           
;                                If ( #VK_F20               = wparam ): Debug "Pressed : #VK_F20"               : EndIf                           
;                                If ( #VK_F21               = wparam ): Debug "Pressed : #VK_F21"               : EndIf    
;                                If ( #VK_F22               = wparam ): Debug "Pressed : #VK_F22"               : EndIf    
;                                If ( #VK_F23               = wparam ): Debug "Pressed : #VK_F23"               : EndIf    
;                                If ( #VK_F24               = wparam ): Debug "Pressed : #VK_F24"               : EndIf 
;                                
;                                If ( #VK_HANGEUL           = wparam ): Debug "Pressed : #VK_HANGEUL"           : EndIf                             
;                                If ( #VK_HANGUL            = wparam ): Debug "Pressed : #VK_HANGUL"            : EndIf   
;                                If ( #VK_HANJA             = wparam ): Debug "Pressed : #VK_HANJA"             : EndIf   
;                                If ( #VK_HELP              = wparam ): Debug "Pressed : #VK_HELP"              : EndIf   
;                                If ( #VK_HOME              = wparam ): Debug "Pressed : #VK_HOME"              : EndIf 
;                                
;                                If ( #VK_ICO_00             = wparam ): Debug "Pressed : #VK_ICO_00"            : EndIf                            
;                                If ( #VK_ICO_CLEAR          = wparam ): Debug "Pressed : #VK_ICO_CLEAR"         : EndIf 
;                                If ( #VK_ICO_HELP           = wparam ): Debug "Pressed : #VK_ICO_HELP"          : EndIf 
;                                If ( #VK_INSERT             = wparam ): Debug "Pressed : #VK_INSERT"            : EndIf    
;                                
;                                If ( #VK_JUNJA              = wparam ): Debug "Pressed : #VK_JUNJA"             : EndIf                            
;                                
;                                If ( #VK_KANA               = wparam ): Debug "Pressed : #VK_KANA"              : EndIf                            
;                                If ( #VK_KANJI              = wparam ): Debug "Pressed : #VK_KANJI"             : EndIf                            
;                                
;                                If ( #VK_LAUNCH_APP1        = wparam ): Debug "Pressed : #VK_LAUNCH_APP1"       : EndIf                            
;                                If ( #VK_LAUNCH_APP2        = wparam ): Debug "Pressed : #VK_LAUNCH_APP2"       : EndIf                            
;                                If ( #VK_LAUNCH_MAIL        = wparam ): Debug "Pressed : #VK_LAUNCH_MAIL"       : EndIf                            
;                                If ( #VK_LAUNCH_MEDIA_SELECT= wparam ): Debug "Pressed : #VK_LAUNCH_MEDIA_SELECT":EndIf    
;                                If ( #VK_LBUTTON            = wparam ): Debug "Pressed : #VK_LBUTTON"           : EndIf    
;                                If ( #VK_LCONTROL           = wparam ): Debug "Pressed : #VK_LCONTROL"          : EndIf                                                      
;                                If ( #VK_LMENU              = wparam ): Debug "Pressed : #VK_LMENU"             : EndIf                            
;                                If ( #VK_LSHIFT             = wparam ): Debug "Pressed : #VK_LSHIFT"            : EndIf                            
;                                If ( #VK_LWIN               = wparam ): Debug "Pressed : #VK_LWIN"              : EndIf                            
;                                
;                                If ( #VK_MBUTTON            = wparam ): Debug "Pressed : #VK_MBUTTON"           : EndIf                            
;                                If ( #VK_MEDIA_NEXT_TRACK   = wparam ): Debug "Pressed : #VK_MEDIA_NEXT_TRACK"  : EndIf                            
;                                If ( #VK_MEDIA_PLAY_PAUSE   = wparam ): Debug "Pressed : #VK_MEDIA_PLAY_PAUSE"  : EndIf                            
;                                If ( #VK_MEDIA_PREV_TRACK   = wparam ): Debug "Pressed : #VK_MEDIA_PREV_TRACK"  : EndIf                            
;                                If ( #VK_MEDIA_STOP         = wparam ): Debug "Pressed : #VK_MEDIA_STOP"        : EndIf                            
;                                If ( #VK_MENU               = wparam ): Debug "Pressed : #VK_MENU"              : EndIf                            
;                                If ( #VK_MODECHANGE         = wparam ): Debug "Pressed : #VK_MODECHANGE"        : EndIf                                                   
;                                
;                                If ( #VK_NEXT               = wparam ): Debug "Pressed : #VK_NEXT"              : EndIf                            
;                                If ( #VK_NONAME             = wparam ): Debug "Pressed : #VK_NONAME"            : EndIf                            
;                                If ( #VK_NONCONVERT         = wparam ): Debug "Pressed : #VK_NONCONVERT"        : EndIf                                
;                                
;                                If ( #VK_OEM_5              = wparam ): Debug "Pressed : #VK_OEM_5"             : EndIf 
;                                If ( #VK_OEM_8              = wparam ): Debug "Pressed : #VK_OEM_8"             : EndIf  
;                                If ( #VK_OEM_ATTN           = wparam ): Debug "Pressed : #VK_OEM_ATTN"          : EndIf 
;                                If ( #VK_OEM_AUTO           = wparam ): Debug "Pressed : #VK_OEM_AUTO"          : EndIf 
;                                If ( #VK_OEM_AX             = wparam ): Debug "Pressed : #VK_OEM_AX"            : EndIf 
;                                If ( #VK_OEM_BACKTAB        = wparam ): Debug "Pressed : #VK_OEM_BACKTAB"       : EndIf 
;                                If ( #VK_OEM_CLEAR          = wparam ): Debug "Pressed : #VK_OEM_CLEAR"         : EndIf 
;                                If ( #VK_OEM_COPY           = wparam ): Debug "Pressed : #VK_OEM_COPY"          : EndIf 
;                                If ( #VK_OEM_CUSEL          = wparam ): Debug "Pressed : #VK_OEM_CUSEL"         : EndIf 
;                                If ( #VK_OEM_ENLW           = wparam ): Debug "Pressed : #VK_OEM_ENLW"          : EndIf 
;                                If ( #VK_OEM_FINISH         = wparam ): Debug "Pressed : #VK_OEM_FINISH"        : EndIf 
;                                If ( #VK_OEM_FJ_JISHO       = wparam ): Debug "Pressed : #VK_OEM_FJ_JISHO"      : EndIf 
;                                If ( #VK_OEM_FJ_LOYA        = wparam ): Debug "Pressed : #VK_OEM_FJ_LOYA"       : EndIf 
;                                If ( #VK_OEM_FJ_MASSHOU     = wparam ): Debug "Pressed : #VK_OEM_FJ_MASSHOU"    : EndIf 
;                                If ( #VK_OEM_FJ_ROYA        = wparam ): Debug "Pressed : #VK_OEM_FJ_ROYA"       : EndIf 
;                                If ( #VK_OEM_FJ_TOUROKU     = wparam ): Debug "Pressed : #VK_OEM_FJ_TOUROKU"    : EndIf 
;                                If ( #VK_OEM_JUMP           = wparam ): Debug "Pressed : #VK_OEM_JUMP"          : EndIf                       
;                                If ( #VK_OEM_NEC_EQUAL      = wparam ): Debug "Pressed : #VK_OEM_NEC_EQUAL"     : EndIf 
;                                If ( #VK_OEM_PA1            = wparam ): Debug "Pressed : #VK_OEM_PA1"           : EndIf 
;                                If ( #VK_OEM_PA2            = wparam ): Debug "Pressed : #VK_OEM_PA2"           : EndIf 
;                                If ( #VK_OEM_PA3            = wparam ): Debug "Pressed : #VK_OEM_PA3"           : EndIf 
;                                If ( #VK_OEM_RESET          = wparam ): Debug "Pressed : #VK_OEM_RESET"         : EndIf 
;                                If ( #VK_OEM_WSCTRL         = wparam ): Debug "Pressed : #VK_OEM_WSCTRL"        : EndIf 
;                                
;                                If ( #VK_PA1                = wparam ): Debug "Pressed : #VK_PA1"               : EndIf 
;                                If ( #VK_PACKET             = wparam ): Debug "Pressed : #VK_PACKET"            : EndIf 
;                                If ( #VK_PAUSE              = wparam ): Debug "Pressed : #VK_PAUSE"             : EndIf 
;                                If ( #VK_PLAY               = wparam ): Debug "Pressed : #VK_PLAY"              : EndIf 
;                                If ( #VK_PRINT              = wparam ): Debug "Pressed : #VK_PRINT"             : EndIf 
;                                If ( #VK_PRIOR              = wparam ): Debug "Pressed : #VK_PRIOR"             : EndIf 
;                                If ( #VK_PROCESSKEY         = wparam ): Debug "Pressed : #VK_PROCESSKEY"        : EndIf                      
;                                
;                                If ( #VK_RBUTTON            = wparam ): Debug "Pressed : #VK_RBUTTON"           : EndIf                      
;                                If ( #VK_RCONTROL           = wparam ): Debug "Pressed : #VK_RCONTROL"          : EndIf                                                                
;                                If ( #VK_RMENU              = wparam ): Debug "Pressed : #VK_RMENU"             : EndIf                      
;                                If ( #VK_RSHIFT             = wparam ): Debug "Pressed : #VK_RSHIFT"            : EndIf                      
;                                If ( #VK_RWIN               = wparam ): Debug "Pressed : #VK_RWIN"              : EndIf                      
;                                
;                                If ( #VK_SCROLL             = wparam ): Debug "Pressed : #VK_SCROLL"            : EndIf                      
;                                If ( #VK_SELECT             = wparam ): Debug "Pressed : #VK_SELECT"            : EndIf                      
;                                If ( #VK_SEPARATOR          = wparam ): Debug "Pressed : #VK_SEPARATOR"         : EndIf                      
;                                If ( #VK_SHIFT              = wparam ): Debug "Pressed : #VK_SHIFT"             : EndIf                      
;                                If ( #VK_SLEEP              = wparam ): Debug "Pressed : #VK_SLEEP"             : EndIf                      
;                                If ( #VK_SNAPSHOT           = wparam ): Debug "Pressed : #VK_SNAPSHOT"          : EndIf                                                               
;                                
;                                If ( #VK_VOLUME_DOWN        = wparam ): Debug "Pressed : #VK_VOLUME_DOWN"       : EndIf                      
;                                If ( #VK_VOLUME_MUTE        = wparam ): Debug "Pressed : #VK_VOLUME_MUTE"       : EndIf                      
;                                If ( #VK_VOLUME_UP          = wparam ): Debug "Pressed : #VK_VOLUME_UP"         : EndIf                      
;                                
;                                If ( #VK_XBUTTON1           = wparam ): Debug "Pressed : #VK_XBUTTON1"          : EndIf                      
;                                If ( #VK_XBUTTON2           = wparam ): Debug "Pressed : #VK_XBUTTON2"          : EndIf                      
;                                
;                                If ( #VK_ZOOM               = wparam ): Debug "Pressed : #VK_ZOOM"              : EndIf                      
                               
                       EndSelect  
                        
                   EndIf
               EndIf
               
           Case #WM_SETFOCUS  : PostEvent(EditGadgetCallBack_Focus(*ed\gadget,#True), *ed\parent, *ed\gadget)
               
           Case #WM_KILLFOCUS : PostEvent(EditGadgetCallBack_Focus(*ed\gadget,#False), *ed\parent, *ed\gadget)  
               
           Case #WM_CONTEXTMENU
               If IsWindow( DC::#_Window_006 )    
                   
                   DisableMenuItem (DC::#EditMenu, 527, vEngine::DOS_Open_Directory(0, #True) )
                   DisableMenuItem (DC::#EditMenu, 528, vEngine::DOS_Open_Directory(1, #True) )                   
                   DisableMenuItem (DC::#EditMenu, 529, vEngine::DOS_Open_Directory(2, #True) )                   
                   DisableMenuItem (DC::#EditMenu, 530, vEngine::DOS_Open_Directory(3, #True) )                   
                   DisableMenuItem (DC::#EditMenu, 531, vEngine::DOS_Open_Directory(4, #True) )                   
                   
                   SetMenuItemState(DC::#EditMenu, 525, vInfo::Wordwrap_Get_MnuItem() )
                   SetMenuItemState(DC::#EditMenu, 532, vInfo::Tab_AutoOpen() )                   
                   
                   SetMenuItemState (DC::#EditMenu, 566, #False )
                   SetMenuItemState (DC::#EditMenu, 567, #False )                   
                   SetMenuItemState (DC::#EditMenu, 568, #False )
                   SetMenuItemState (DC::#EditMenu, 569, #False )
                   
                   DisableMenuItem (DC::#EditMenu, 573, Startup::*LHGameDB\InfoWindow\bURLOpnWith)                   

                   
                   Select Startup::*LHGameDB\InfoWindow\bSide
                       Case 1 : SetMenuItemState (DC::#EditMenu, 567, #True ): Debug "Docking Rechts   = " + Str(Startup::*LHGameDB\InfoWindow\bSide)                            
                       Case -1: SetMenuItemState (DC::#EditMenu, 568, #True ): Debug "Docking Links    = " + Str(Startup::*LHGameDB\InfoWindow\bSide)
                       Case 2 : SetMenuItemState (DC::#EditMenu, 569, #True ): Debug "Docking Lose     = " + Str(Startup::*LHGameDB\InfoWindow\bSide) 
                       Default: SetMenuItemState (DC::#EditMenu, 566, #True ): Debug "Docking Standard = " + Str(Startup::*LHGameDB\InfoWindow\bSide)                           
                   EndSelect 
                   
                   Select Startup::*LHGameDB\InfoWindow\bTabNum
                       Case 0
                       Case 1 To 4: DisplayPopupMenu(DC::#EditMenu, WindowID(DC::#_Window_006 ) )
                   EndSelect

               EndIf                  
               
           Case #WM_RBUTTONDOWN
               If IsWindow( DC::#_Window_006 )
                   vInfo::Caret_GetPosition() 
                   If CreatePopupImageMenu( DC::#EditMenu )
                       MenuItem(500, "&Rückgängig"      + Chr(9) +"Strg+Z"          ,ImageID( DI::#_MNU_UND ))
                       MenuItem(502, "&Wiederholen"     + Chr(9) +"Strg+Y"          ,ImageID( DI::#_MNU_RED ))                    
                       MenuBar()                    
                       MenuItem(501, "&Ausschneiden"    + Chr(9) +"Strg+X"          ,ImageID( DI::#_MNU_CUT ))
                       MenuItem(503, "&Kopieren"        + Chr(9) +"Strg+C"          ,ImageID( DI::#_MNU_COP ))
                       MenuItem(504, "&Einfügen"        + Chr(9) +"Strg+V"          ,ImageID( DI::#_MNU_PAS ))
                       MenuBar()                        
                       MenuItem(505, "&Alles auswählen" + Chr(9) +"Strg+A")
                       ;MenuItem(506, "Nichts auswählen")                      
                       ;MenuBar()                    
                       MenuItem(508, "&Suchen"          + Chr(9) +"Strg+F"          ,ImageID( DI::#_MNU_FND ))                     
                       MenuBar() 
                       MenuItem(507, "&Text Löschen"    + Chr(9) +"Delete"          ,ImageID( DI::#_MNU_CLR ))                       
                       MenuItem(510, "&Text Sichern/Updaten"  + Chr(9) +"Strg+S"   ,ImageID( DI::#_MNU_UPD ))
                       MenuItem(575, "Text Syncron Speichern"                      ,ImageID( DI::#_MNU_SVE ))                       
                       MenuBar() 
                       MenuItem(527, "Durchsuchen: Programm"                        ,ImageID( DI::#_MNU_EX1 ))   
                       MenuBar()                        
                       MenuItem(528, "Durchsuchen: Slot 1"                          ,ImageID( DI::#_MNU_EX2 )) 
                       MenuItem(529, "Durchsuchen: Slot 2"                          ,ImageID( DI::#_MNU_EX2 ))                       
                       MenuItem(530, "Durchsuchen: Slot 3"                          ,ImageID( DI::#_MNU_EX2 ))                      
                       MenuItem(531, "Durchsuchen: Slot 4"                          ,ImageID( DI::#_MNU_EX2 ))                         
                       MenuBar()                         
                       OpenSubMenu( "Datei"                                         ,ImageID( DI::#_MNU_DSK ))
                       MenuItem(509, "&Öffnen..."       + Chr(9) +"Ctrl+O"          ,ImageID( DI::#_MNU_LOD ))
                       MenuItem(574, "Neuladen"                                     ,ImageID( DI::#_MNU_SVE ))
                       MenuBar()                           
                       MenuItem(511, "Speichern"                                    ,ImageID( DI::#_MNU_SVE ))
                       MenuItem(512, "Speichern als..."                             ,ImageID( DI::#_MNU_SVE ))
                       MenuBar() 
                       MenuItem(513, "Drucken"                                      ,ImageID( DI::#_MNU_PRN ))                     
                       MenuBar()
                       MenuItem(570, "Extern Öffnen ..."                            ,ImageID( DI::#_MNU_FEX ))
                       MenuItem(571, "Eigenschaften ..."                            ,ImageID( DI::#_MNU_FPS ))                         
                       CloseSubMenu()   
                       OpenSubMenu( "Pfade .."                                      ,ImageID( DI::#_MNU_DIR ))                       
                       MenuItem(558, "Alle Prüfen & Reparieren (Slot 1)"            ,ImageID( DI::#_MNU_RAL )) 
                       MenuItem(559, "Alle Prüfen & Reparieren (Slot 2)"            ,ImageID( DI::#_MNU_RAL ))                       
                       MenuItem(560, "Alle Prüfen & Reparieren (Slot 3)"            ,ImageID( DI::#_MNU_RAL ))                       
                       MenuItem(561, "Alle Prüfen & Reparieren (Slot 4)"            ,ImageID( DI::#_MNU_RAL ))
                       MenuBar() 
                       MenuItem(562, "Aktuellen Prüfen & Reparieren (Slot 1)"       ,ImageID( DI::#_MNU_RNE )) 
                       MenuItem(563, "Aktuellen Prüfen & Reparieren (Slot 2)"       ,ImageID( DI::#_MNU_RNE ))                        
                       MenuItem(564, "Aktuellen Prüfen & Reparieren (Slot 3)"       ,ImageID( DI::#_MNU_RNE )) 
                       MenuItem(565, "Aktuellen Prüfen & Reparieren (Slot 4)"       ,ImageID( DI::#_MNU_RNE ))                      
                       CloseSubMenu()
                       MenuBar()  
                       MenuItem(573, "URL Adresse Öffnen Mit ..."                   ,ImageID( DI::#_MNU_URL ))                        
                       MenuBar()
                       MenuItem(525, "Zeilenumbruch") 
                       MenuBar()
                       
                       OpenSubMenu( "Info Einstellung"                              ,ImageID( DI::#_MNU_SET ))                     
                       MenuItem(517, "Umbennen: Tab 1"                              ,ImageID( DI::#_MNU_TRN ))
                       MenuItem(518, "Umbennen: Tab 2"                              ,ImageID( DI::#_MNU_TRN ))   
                       MenuItem(519, "Umbennen: Tab 3"                              ,ImageID( DI::#_MNU_TRN ))  
                       MenuItem(520, "Umbennen: Tab 4"                              ,ImageID( DI::#_MNU_TRN ))
                       MenuBar() 
                       MenuItem(521, "Zurücksetzen: Tab 1"                          ,ImageID( DI::#_MNU_TDF ))
                       MenuItem(522, "Zurücksetzen: Tab 2"                          ,ImageID( DI::#_MNU_TDF ))    
                       MenuItem(523, "Zurücksetzen: Tab 3"                          ,ImageID( DI::#_MNU_TDF ))    
                       MenuItem(524, "Zurücksetzen: Tab 4"                          ,ImageID( DI::#_MNU_TDF ))
                       MenuBar() 
                       MenuItem(532, "Automatisch Öffnen"                                                   )                           
                       MenuBar()                       
                       MenuItem(542, "Splitter Höhe"                                ,ImageID( DI::#_MNU_SPL ))
                       MenuItem(544, "Thumbail Grösse"                              ,ImageID( DI::#_MNU_WMT ))
                       MenuBar()
                       MenuItem(551, "1 Thumbnail Pro Reihe"                        ,ImageID( DI::#_MNU_TB1 ))
                       MenuItem(552, "2 Thumbnails Pro Reihe"                       ,ImageID( DI::#_MNU_TB2 ))
                       MenuItem(553, "3 Thumbnails Pro Reihe"                       ,ImageID( DI::#_MNU_TB3 ))                       
                       MenuItem(554, "4 Thumbnails Pro Reihe"                       ,ImageID( DI::#_MNU_TB4 ))                        
                       MenuItem(555, "5 Thumbnails Pro Reihe"                       ,ImageID( DI::#_MNU_TB5 ))                         
                       MenuItem(556, "6 Thumbnails Pro Reihe"                       ,ImageID( DI::#_MNU_TB5 ))
                       MenuItem(557, "7 Thumbnails Pro Reihe"                       ,ImageID( DI::#_MNU_TB5 ))                        
                       MenuBar() 
                       MenuItem(526, "Fenster Anpassen"                             ,ImageID( DI::#_MNU_WRS ))
                       MenuBar()                        
                       MenuItem(566, "Andocken Standard"                            ,ImageID( DI::#_MNU_WRS ))
                       MenuItem(569, "Andocken Lose"                                ,ImageID( DI::#_MNU_WRS ))                          
                       MenuItem(567, "Andocken Rechts"                              ,ImageID( DI::#_MNU_WRS ))                       
                       MenuItem(568, "Andocken Links"                               ,ImageID( DI::#_MNU_WRS ))
                      
                       CloseSubMenu()                          
                       OpenSubMenu( "Schriftarten .."                               ,ImageID( DI::#_MNU_SFN ))  
                       MenuItem(514, "Info Zurücksetzen"                            ,ImageID( DI::#_MNU_FDF ))      
                       MenuItem(515, "Wählen..."                                    ,ImageID( DI::#_MNU_FDL ))   
                       MenuItem(545, "Wählen... (Fixed)"                            ,ImageID( DI::#_MNU_FDL ))
                       MenuItem(546, "Wählen... (TrueType)"                         ,ImageID( DI::#_MNU_FDL ))                        
                       MenuBar()              
                       MenuItem(541, "Titel Zurücksetzen"                           ,ImageID( DI::#_MNU_FDF ))                        
                       MenuItem(533, "Wählen..."                                    ,ImageID( DI::#_MNU_FDL ))
                       MenuItem(547, "Wählen... (Fixed)"                            ,ImageID( DI::#_MNU_FDL ))
                       MenuItem(548, "Wählen... (TrueType)"                         ,ImageID( DI::#_MNU_FDL ))                        
                       MenuBar()
                       MenuItem(543, "Liste Zurücksetzen"                           ,ImageID( DI::#_MNU_FDF ))                         
                       MenuItem(534, "Wählen..."                                    ,ImageID( DI::#_MNU_FDL ))
                       MenuItem(549, "Wählen... (Fixed)"                            ,ImageID( DI::#_MNU_FDL ))
                       MenuItem(550, "Wählen... (TrueType)"                         ,ImageID( DI::#_MNU_FDL ))                        
                       CloseSubMenu()                         
                       
                       OpenSubMenu( "System Modifikation"                           ,ImageID( DI::#_MNU_SWN ))
                       MenuItem(535, "Enable : Aero/Uxsms"                          ,ImageID( DI::#_MNU_AEE ))                   
                       MenuItem(536, "Disable: Aero/Uxsms"                          ,ImageID( DI::#_MNU_AED )) 
                       MenuBar() 
                       MenuItem(537, "Enable : Explorer"                            ,ImageID( DI::#_MNU_EXE ))                        
                       MenuItem(538, "Disable: Explorer"                            ,ImageID( DI::#_MNU_EXD ))         
                       MenuBar() 
                       MenuItem(539, "Enable : Taskbar"                             ,ImageID( DI::#_MNU_TBE ))                       
                       MenuItem(540, "Disable: Taskbar"                             ,ImageID( DI::#_MNU_TBD ))                                          
                       CloseSubMenu()                       
                       
                       MenuBar()  
                       MenuItem(572, "Ausführen"                                    ,ImageID( DI::#_MNU_RUN ))                
                       MenuItem(516, "Info Schliessen"                              ,ImageID( DI::#_MNU_CLS ))  
                                             
                   EndIf                 
               EndIf               
           Case #WM_LBUTTONUP
               vInfo::Caret_GetPosition()  
               
           
       EndSelect
       
       ProcedureReturn CallWindowProc_(*ed\oldprc, hwnd, msg, wParam, lParam) 
       
   EndProcedure           
    ;******************************************************************************************************************************************
    ; EditGadget Callback Event/ Set
    ;__________________________________________________________________________________________________________________________________________      
    Procedure EditGadgetSetCallback(pbnr, parent, xyz = 0)
        
        If IsGadget(pbnr)
            Protected spid = GadgetID(pbnr)      
       
            Protected *ed.EditGadgetData = AllocateMemory(SizeOf(EditGadgetData))
       
            *ed\gadget = pbnr
            *ed\parent = parent
            *ed\oldprc = GetWindowLongPtr_(spid, #GWL_WNDPROC)   
       
            SetWindowLongPtr_(spid, #GWL_USERDATA, *ed)   
            SetWindowLongPtr_(spid, #GWL_WNDPROC, @EditGadgetCallBack())
       EndIf    
       
   EndProcedure 
   
   ;******************************************************************************************************************************************
    ;
    ; Procedure die bei jden Fenster Stafindet BEVOR es aktiv wird
    ;__________________________________________________________________________________________________________________________________________     
    Procedure PostEvents_Resize(hwnd.i)    
                   
        SetWindowLong_(WindowID(hwnd),#GWL_EXSTYLE,#WS_EX_APPWINDOW)  
        
        If ( hwnd = DC::#_Window_006 )
            SetWindowCallback(@CallBackEvnts_Edit(),hwnd):  
            SetForegroundWindow_( WindowID(DC::#_Window_001 ))          
        Else
            SetWindowCallback(@CallBackEvnts(),hwnd): 
            SetForegroundWindow_(WindowID(hwnd))            
        EndIf
        

     
    EndProcedure 
    ;******************************************************************************************************************************************
    ; Procedure die bei jden Fenster Schliessen Stattfindet 
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.i PostEvents_Close(hwnd.i)    
            
        SetWindowCallback(0,hwnd):         
        
        CloseWindow(hwnd)
        SetActiveWindow(DC::#_Window_001)

        ProcedureReturn #True
    EndProcedure     
EndModule  
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1384
; FirstLine = 1105
; Folding = vcuF9-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; EnableUnicode