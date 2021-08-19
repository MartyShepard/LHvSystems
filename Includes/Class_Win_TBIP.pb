DeclareModule TBProgress
    ; http://msdn.microsoft.com/en-us/library/windows/desktop/dd391692%28v=vs.85%29.aspx
    
    Interface ITaskbarList3 Extends ITaskbarList2
        SetProgressValue.i      (hWnd.i,ullCompleted.q,ullTotal.q)
        SetProgressState.i      (hWnd.i,tbpFlags.l)
        RegisterTab.i           (hWndTab.i,hWndMDI.i)
        UnregisterTab.i         (hWndTab.i)
        SetTabOrder.i           (hWndTab.i,hWndInsertBefore.i)
        SetTabActive.i          (hWndTab.i,hWndMDI.i,tbatFlags.l)
        ThumbBarAddButtons.i    (hWnd.i,cButtons.l,*pButton)
        ThumbBarUpdateButtons.i (hWnd.i,cButtons.l,*pButton)
        ThumbBarSetImageList.i  (hWnd.i,himl.i)
        SetOverlayIcon.i        (hWnd.i,hIcon.i,pszDescription$)
        SetThumbnailTooltip.i   (hWnd.i,pszTip$)
        SetThumbnailClip.i      (hWnd.i,*prcClip)
    EndInterface
    
    Declare.i TBC()    
    Declare.i TBD(*tl3)    
EndDeclareModule

Module TBProgress
                
    Interface ITaskbarList4 Extends ITaskbarList3
        SetTabProperties.i (hwndTab.i,stpFlags.l)
    EndInterface
    
    DataSection
        CLSID_TaskBarList:
        Data.l $56FDF344
        Data.w $FD6D, $11D0
        Data.b $95, $8A, $00, $60, $97, $C9, $A0, $90
        IID_ITaskBarList3:
        Data.l $EA1AFB91
        Data.w $9E28,$4B86
        Data.b $90,$E9,$9E,$9F,$8A,$5E,$EF,$AF
    EndDataSection
    
    
    #CLSCTX_INPROC_SERVER            = $1
    #CLSCTX_INPROC_HANDLER           = $2
    #CLSCTX_LOCAL_SERVER             = $4
    #CLSCTX_INPROC_SERVER16          = $8
    #CLSCTX_REMOTE_SERVER            = $10
    #CLSCTX_INPROC_HANDLER16         = $20
    #CLSCTX_RESERVED1                = $40
    #CLSCTX_RESERVED2                = $80
    #CLSCTX_RESERVED3                = $100
    #CLSCTX_RESERVED4                = $200
    #CLSCTX_NO_CODE_DOWNLOAD         = $400
    #CLSCTX_RESERVED5                = $800
    #CLSCTX_NO_CUSTOM_MARSHAL        = $1000
    #CLSCTX_ENABLE_CODE_DOWNLOAD     = $2000
    #CLSCTX_NO_FAILURE_LOG           = $4000
    #CLSCTX_DISABLE_AAA              = $8000
    #CLSCTX_ENABLE_AAA               = $10000
    #CLSCTX_FROM_DEFAULT_CONTEXT     = $20000
    #CLSCTX_ACTIVATE_32_BIT_SERVER   = $40000
    #CLSCTX_ACTIVATE_64_BIT_SERVER   = $80000
    #CLSCTX_ENABLE_CLOAKING          = $100000
    #CLSCTX_PS_DLL                   = $80000000
    
    
    Procedure.i TBC()
        Protected *tl3.ITaskbarList3
        CoInitialize_(#Null)
        CoCreateInstance_ (?CLSID_TaskBarList,#Null,#CLSCTX_INPROC_SERVER,?IID_ITaskBarList3,@*tl3)
        ProcedureReturn *tl3
    EndProcedure
    
    
    Procedure.i TBD(*tl3.ITaskbarList3)
        If *tl3
            *tl3\Release()
        EndIf
        CoUninitialize_()
    EndProcedure
    
EndModule


CompilerIf #PB_Compiler_IsMainFile
    
    Enumeration
        #WIN_MAIN
    EndEnumeration
    
    Procedure Main()
        Protected iEvent, pct, rec.RECT
        Protected *tl3.TBProgress::ITaskbarList3
        
        If OpenWindow(#WIN_MAIN, 0, 0, 300, 150, "", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
            
            ProgressBarGadget(1, 10,10, 280, 130, 0, 100)
            
            *tl3 = TBProgress::TBC()
            *tl3\HrInit()
            *tl3\SetProgressValue(WindowID(#WIN_MAIN),0,100)
            *tl3\SetProgressState(WindowID(#WIN_MAIN), #tbpf_normal)
            
            ; move the mouse to the minimized window in the taskbar to see the real time thumbnail
            GetClientRect_(WindowID(#WIN_MAIN), @rec)
            rec\right / 2 ; only half of the client area :-]
            rec\bottom/ 2 ; only half of the client area :-]
            *tl3\SetThumbnailClip(WindowID(#WIN_MAIN), @rec)
            
            Repeat
                iEvent = WindowEvent()
                
                If iEvent = 0
                    If pct = 101
                        SetWindowTitle(#WIN_MAIN, "Red (ERROR)")
                        *tl3\SetProgressState(WindowID(#WIN_MAIN), #tbpf_error)
                    Else                     
                        SetWindowTitle(#WIN_MAIN, "1/" + Str(pct))
                        SetGadgetState(1, pct)
                        *tl3\SetProgressValue(WindowID(#WIN_MAIN),pct,100)   
                        pct + 1
                    EndIf
                    Delay(100)
                EndIf       
                
            Until iEvent = #PB_Event_CloseWindow
            
        EndIf
        
        TBProgress::TBD(*tl3)
        
    EndProcedure
    
    
    Main()
CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 127
; FirstLine = 87
; Folding = --
; EnableAsm
; EnableUnicode
; EnableXP
; Executable = TBTest.exe