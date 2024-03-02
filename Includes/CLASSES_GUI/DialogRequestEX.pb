CompilerIf #PB_Compiler_IsMainFile
    
    UsePNGImageDecoder()
     XIncludeFile "..\..\LH vSystems\vSystems_Modules\Constants.pb"   
    XIncludeFile "..\..\LH vSystems\vSystems_Modules\ConstantsFonts.pb"
    XIncludeFile "..\Class_Tooltip.pb"     
    XIncludeFile "..\Class_Process.pb"
    XIncludeFile "..\Class_Win_Form.pb"
    XIncludeFile "..\Class_Win_Style.pb"        
    XIncludeFile "ButtonGadgetEX.pb"
    XIncludeFile "..\Class_Win_Desk.pb"
 

CompilerEndIf

DeclareModule Request             
    UsePNGImageDecoder()         
    ;================================================================================================================================
    ;Message Structur
    ;________________________________________________________________________________________________________________________________ 
    Structure MsgReqEx
      Window_Title.s
      TopHead_Text.s
      Message_Text.s
      CheckBox_Txt.s
      
      ButtonStyle.i
      Checkbox_On.i
      CheckBox_En.i
      Default_Btn.i
      
      Icon_Message.i
      Icon_Program.s
      
      Text_Justify.i
      
      Return__Input.i
      Return_String.s
      Return__Flags.l
      
      Message_Flags.l
      
      Fnt1.l
      Fnt2.l
      Fnt3.l
      
      User_BtnTextL.s
      User_BtnTextM.s
      User_BtnTextR.s
      
      WW.i
      WH.i
      WP.l
      WP_NonID.l      
      
      Col__Window.l
      Col__WinBox.l
      Col_HeadFrn.l
      Col_HeadBck.l
      Col_TextFrn.l
      Col_TextBck.l 
      Col_StrgFrn.l
      Col_StrgBck.l
      ReturnCode.i
    EndStructure 
    
    Global *MsgEx.MsgReqEx = AllocateMemory(SizeOf(MsgReqEx)) 
        
    Declare Dialog_Execute()
    Declare Dialog_Reboot()
    Declare Dialog_Restart()
    Declare Dialog_Color()
    Declare Dialog_NetConnectPrint()
    Declare Dialog_NetConnectDrive()
    Declare Dialog_NetUsersPass()
    Declare Dialog_Icon()
    Declare SetDebugLog(LogMessageText$ = "", LogMode = 0, LogFile$ = "")
    Declare.l DialogEx_RGB(CurrentColor.l,Mode.i, WindowID.i) 

    Declare.i MSG(Window_Title$ = "",
                  TopHead_Text$ = "",
                  Message_Text$ = "",
                  ButtonStyle.i = 2, Icon.i =  0, Icon_Program$ = "", sCheckBox.i = 0, sInput.i = 0,ParentID = 0, bInputNums = #False)
        
  EndDeclareModule

  Module Request
      
      Enumeration 4721 Step 1 ;AB 996 GadgetEX
          #REXW0: #REXT0: #REXT1: #REXT2
          #REXB1: #REXB2: #REXB3: #REXS1 
          #REXBTNGR11N: #REXBTNGR11P
          #REXBTNGR11H: #REXBTNGR11D
          #REXCBBTN
          #REXIG1: #REXIG2: #REXICA: #REXIBL: #REXICB             
      EndEnumeration ;997
      
        EnumEnd =  4751
        EnumVal =  EnumEnd - #PB_Compiler_EnumerationValue  
        Debug #TAB$ + "Constansts Enumeration : 4721 -> " +RSet(Str(EnumEnd),4,"0") +" /Used: "+ RSet(Str(#PB_Compiler_EnumerationValue),4,"0") +" /Free: " + RSet(Str(EnumVal),4,"0") + " ::: DialogEX::(Module), Message Requester)"
      
      #Dummy_Font_ID = 8661
      
      #CCHILDREN_TITLEBAR = 5       
      Structure TITLEBARINFO
          cbSize.l
          rcTitleBar.RECT
          rgstate.l[#CCHILDREN_TITLEBAR+1]
      EndStructure
      
      Prototype KRShowKeyMgr(hwParent,hInstance,pszCmdLine,CmdShow)
      Prototype.l PickIconDlg(hwnd,pszIconPath.p-unicode,cchIconPath,piIconIndex)
      
      ;================================================================================================================================
      ;Datasection
      ;________________________________________________________________________________________________________________________________         
      DataSection        
          _BTN_GREY1_1N:
          IncludeBinary "DialogRequestEX_IMG\Grey4_Normal.png"
          
          _BTN_GREY1_1H:        
          IncludeBinary "DialogRequestEX_IMG\Grey4_Hover.png"
          
          _BTN_GREY1_1P:
          IncludeBinary "DialogRequestEX_IMG\Grey4_Pressed.png"
          
          _BTN_GREY1_1D:
          IncludeBinary "DialogRequestEX_IMG\Grey4_Disabled.png" 
          
          RequestEX_ICON0:
          IncludeBinary "DialogRequestEX_IMG\IcoNFO.png" ;Information                      
          
          RequestEX_ICON1:
          IncludeBinary "DialogRequestEX_IMG\IcoAtt.png" ;Attention
          
          RequestEX_ICON2:
          IncludeBinary "DialogRequestEX_IMG\IcoStp.png" ;Stop
          
          RequestEX_ICON3:
          IncludeBinary "DialogRequestEX_IMG\icoHlp.Png" ;Help 
          
          RequestEX_ICON4:
          IncludeBinary "DialogRequestEX_IMG\IcoNFO22.png" ;Information                      
          
          RequestEX_ICON5:
          IncludeBinary "DialogRequestEX_IMG\IcoAtt22.png" ;Attention
          
          RequestEX_ICON6:
          IncludeBinary "DialogRequestEX_IMG\IcoStp22.png" ;Stop
          
          RequestEX_ICON7:
          IncludeBinary "DialogRequestEX_IMG\icoHlp22.Png" ;Help         
          
      EndDataSection
      
      
      CatchImage(#REXBTNGR11N, ?_BTN_GREY1_1N): CatchImage(#REXBTNGR11H, ?_BTN_GREY1_1H)
      CatchImage(#REXBTNGR11P, ?_BTN_GREY1_1P): CatchImage(#REXBTNGR11D, ?_BTN_GREY1_1D) 
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________          
      Procedure.l Ansi2Uni(ansi.s)
          Protected memziel         
          SHStrDup_(@ansi,@memziel)
          ProcedureReturn memziel
      EndProcedure        
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________        
      Procedure SetDebugLog(LogMessageText$ = "", LogMode = 0, LogFile$ = "")
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
            
            If ( LogFile$ <> "" )
                If OpenFile(DC::#LOGFILE, LogFile$, #PB_File_SharedRead)            
                    FileSeek(DC::#LOGFILE, FileSize(LogFile$))              
                    WriteStringN(DC::#LOGFILE ,CurrentLineText$ ,#PB_Ascii)
                    CloseFile(DC::#LOGFILE)    
                EndIf                              
            EndIf     
            
            Debug CurrentLineText$
       EndProcedure      
      ;================================================================================================================================      
      ;   Startet des Ausführen Dialog
      ;________________________________________________________________________________________________________________________________  
      Procedure Dialog_Execute()
          SendMessage_(FindWindow_("Shell_TrayWnd",""),#WM_COMMAND,$191,0)
      EndProcedure
      
      ;================================================================================================================================
      ;   Fragt den Benutzer nach System Neustart
      ;_______________________________________________________________________________________________________________________________ 
      Procedure Dialog_Reboot()
          SetupPromptReboot_(0,0,0)
      EndProcedure    
      
      ;================================================================================================================================    
      ;   Fragt den Benutzer um sich vom System Abzumelden
      ;_______________________________________________________________________________________________________________________________
      Procedure Dialog_Restart()
          RestartDialog_(0, Ansi2Uni("Zusatzinformationen" + Chr(13)), #EWX_LOGOFF)
      EndProcedure
      
      ;================================================================================================================================   
      ;   Fragt den Benutzer nach System Neustart
      ;_______________________________________________________________________________________________________________________________
      Procedure Dialog_Color()
          Structure COLORREF
              RGB.l[16]
          EndStructure 
          
          Define CHOOSECOLOR.CHOOSECOLOR
          Define COLORREF.COLORREF
          
          COLORREF\RGB[0] = RGB(255, 0, 0)
          COLORREF\RGB[1] = RGB(0, 255, 0)
          COLORREF\RGB[2] = RGB(0, 0, 255)
          
          CHOOSECOLOR\LStructSize = SizeOf(CHOOSECOLOR)
          CHOOSECOLOR\hwndOwner = 0;WindowID(#Window)
          CHOOSECOLOR\rgbResult = RGB(100, 200, 50)
          CHOOSECOLOR\lpCustColors = COLORREF
          CHOOSECOLOR\flags = #CC_ANYCOLOR | #CC_FULLOPEN | #CC_RGBINIT
          
          If ChooseColor_(@CHOOSECOLOR)
              Debug "Farbe: " + CHOOSECOLOR\rgbResult
          Else
              Debug "Keine Farbe ausgew�hlt."
          EndIf
      EndProcedure      
      
      ;================================================================================================================================   
      ;   Netzwerk Drucker Verbinden
      ;_______________________________________________________________________________________________________________________________    
      Procedure Dialog_NetConnectPrint()
          ConnectToPrinterDlg_(0,0)
      EndProcedure    
      
      ;================================================================================================================================     
      ;   Netzwerk Netzlaufwerk Verbinden
      ;_______________________________________________________________________________________________________________________________    
      Procedure Dialog_NetConnectDrive()
          WNetConnectionDialog_(0,#RESOURCETYPE_DISK)
      EndProcedure  
      
      ;================================================================================================================================      
      ;   Gespeicherte Kennwörte Dialog
      ;_______________________________________________________________________________________________________________________________   
      Procedure Dialog_NetUsersPass()
          
          If OpenLibrary(0,"keymgr.dll")
              
              Define KRShowKeyMgr.KRShowKeyMgr = GetFunction(0,"KRShowKeyMgr")   
              KRShowKeyMgr(0,0,0,0)
          EndIf
      EndProcedure   
      
      ;================================================================================================================================      
      ;   Icon Dialog Öffnen
      ;_______________________________________________________________________________________________________________________________   
      Procedure Dialog_Icon()
          Define IcoLibPath$ = "C:\Windows\System32\shell32.dll"
          Define DlgResult
          Define hWnd=0
          Define DefaultIconID = 5
          
          If OpenLibrary(0,"Shell32.dll")
              
              Define PickIconDlg.PickIconDlg = GetFunction(0,"PickIconDlg")   
              DlgResult = PickIconDlg(hWnd,IcoLibPath$,Len(IcoLibPath$),@DefaultIconID)
              ProcedureReturn DlgResult
          EndIf
      EndProcedure             
      ;================================================================================================================================
      ; Color Requester, Mode 0 (Windows), Mode 1 (PB)
      ;_______________________________________________________________________________________________________________________________  
      Procedure.l DialogEx_RGB(CurrentColor.l,Mode.i, WindowID.i)    
          Protected ColReq.l
          Select Mode
              Case 0
                  ;                Structure COLORREF
                  ;                     RGB.l[16]
                  ;                EndStructure 
                  
                  Define CHOOSECOLOR.CHOOSECOLOR
                  Define COLORREF.COLORREF
                  
                  COLORREF\RGB[0] = RGB(255, 0, 0)
                  COLORREF\RGB[1] = RGB(0, 255, 0)
                  COLORREF\RGB[2] = RGB(0, 0, 255)
                  
                  CHOOSECOLOR\LStructSize = SizeOf(CHOOSECOLOR)
                  CHOOSECOLOR\hwndOwner = WindowID(WindowID)
                  CHOOSECOLOR\rgbResult = CurrentColor
                  CHOOSECOLOR\lpCustColors = COLORREF
                  CHOOSECOLOR\flags = #CC_ANYCOLOR | #CC_FULLOPEN | #CC_RGBINIT
                  
                  If ChooseColor_(@CHOOSECOLOR)
                      ProcedureReturn CHOOSECOLOR\rgbResult
                  EndIf  
              Case 1
                  ColReq = ColorRequester(CurrentColor)
                  If ColReq > -1
                      ProcedureReturn ColReq
                  EndIf    
          EndSelect        
          ProcedureReturn -1
      EndProcedure
  
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________ 
      Procedure MSG_Internal_Paint(ImageID.l, Mode.i = 0, Alpha.i = 190)
          Protected DrawingMode.l
          ; Draw an Image
          Select Mode
              Case 0
                  CreateImage(#REXIBL,ImageWidth(ImageID),ImageHeight(ImageID),32, *MsgEx\Col__Window)
                  DrawingMode = #PB_2DDrawing_Transparent
              Case 1
                  CreateImage(#REXIBL,ImageWidth(ImageID),ImageHeight(ImageID),32)
                  DrawingMode = #PB_2DDrawing_AllChannels
          EndSelect            
          
          StartDrawing(ImageOutput(#REXIBL))
          DrawingMode(DrawingMode)
          DrawAlphaImage(ImageID(ImageID), 0, 0,Alpha) 
          StopDrawing() 
          
          GrabImage(#REXIBL,ImageID, 0, 0, ImageWidth(ImageID), ImageHeight(ImageID)) 
      EndProcedure               
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________          
      Procedure MSG_Internal_Image()
          Protected nCountIcons, iMax, ImagePosY.i,cnIcons.i, ico.i, pIcon.l = -1
          
          Structure SHELLICONLIST
              hLarge.l
              hSmall.l
          EndStructure    
          NewList nCountIcons.SHELLICONLIST()
          
          If IsImage(#REXICA): FreeImage(#REXICA): EndIf
          
          Select *MsgEx\Icon_Message
              Case 0: CatchImage(#REXICA, ?RequestEX_ICON0) ; Info        
              Case 1: CatchImage(#REXICA, ?RequestEX_ICON1) ; Attention
              Case 2: CatchImage(#REXICA, ?RequestEX_ICON2) ; Stop
              Case 3: CatchImage(#REXICA, ?RequestEX_ICON3) ; help
              Default
          EndSelect    
          
          If ( Len(*MsgEx\Icon_Program) >= 1 ) And ( FileSize(*MsgEx\Icon_Program) >= 1 )
              
              ; GetIcons
              cnIcons = ExtractIconEx_(*MsgEx\Icon_Program,-1,0,0,0)
              For ico = 0 To cnIcons -1
                  AddElement(nCountIcons())
                  ExtractIconEx_(*MsgEx\Icon_Program,ico, @nCountIcons()\hLarge.l, @nCountIcons()\hSmall, cnIcons)
              Next  
              
              ResetList( nCountIcons() )
              ForEach nCountIcons()
                  If ( nCountIcons()\hLarge >= 1 )
                      pIcon = nCountIcons()\hLarge
                      Break;
                  Else
                    If ( nCountIcons()\hSmall >= 1 )
                          pIcon = nCountIcons()\hSmall
                        Break
                    EndIf              
                 EndIf   
              Next  
              FreeList( nCountIcons() )           
              
              If ( pIcon >= 1 )                  
                  CreateImage(#REXICB,40,40, 32)           
                  StartDrawing(ImageOutput(#REXICB))
                  DrawingMode(#PB_2DDrawing_AllChannels)
                  DrawImage(pIcon,0,0,40,40)
                  StopDrawing()
                  
              EndIf            
          EndIf  
          
          
          If ( IsImage(#REXICA) And  Not IsImage(#REXICB) )
              ImagePosY.i = 50
              MSG_Internal_Paint(#REXICA)
              ImageGadget(#REXIG1,20,ImagePosY,32,32,0): SetGadgetState(#REXIG1,ImageID(#REXICA))
              ProcedureReturn
          EndIf
          
          If ( Not IsImage(#REXICA) And  IsImage(#REXICB) )
              ImagePosY.i = 50
              MSG_Internal_Paint(#REXICB)
              ImageGadget(#REXIG2,18,ImagePosY,40,40,0): SetGadgetState(#REXIG2,ImageID(#REXICB))
              ProcedureReturn
          EndIf
          
          If ( IsImage(#REXICA) And IsImage(#REXICB) )
              
              FreeImage(#REXICA)
              ;
              ; Select  22 Grösse
              Select *MsgEx\Icon_Message
                  Case 0: CatchImage(#REXICA, ?RequestEX_ICON4)         
                  Case 1: CatchImage(#REXICA, ?RequestEX_ICON5)  
                  Case 2: CatchImage(#REXICA, ?RequestEX_ICON6) 
                  Case 3: CatchImage(#REXICA, ?RequestEX_ICON7)
                  Default
              EndSelect 
              
              ImagePosY.i = 4
              ImagePosX.i = WindowWidth(#REXW0) - ( ImageWidth(#REXICA) + 4 )
              MSG_Internal_Paint(#REXICA,1,155)           
              ImageGadget(#REXIG1,ImagePosX,ImagePosY,32,32,0): SetGadgetState(#REXIG1,ImageID(#REXICA))
              
              ImagePosY.i = 50
              MSG_Internal_Paint(#REXICB)
              ImageGadget(#REXIG2,18,ImagePosY,40,40,0): SetGadgetState(#REXIG2,ImageID(#REXICB))
              ProcedureReturn
          EndIf     
          
          
      EndProcedure
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________                   
      Procedure.i MSG_Internal_Return(ObjectID)
          
          Select *MsgEx\ButtonStyle
              Case 0 To 9
                  If ( ObjectID = #REXB2 )
                      *MsgEx\ReturnCode = 0
                  EndIf
                  
              Case 10 To 15
                  If ( ObjectID = #REXB1 )
                      *MsgEx\ReturnCode = 0
                  EndIf             
                  If ( ObjectID = #REXB3 )
                      *MsgEx\ReturnCode = 1
                  EndIf           
                  
              Case 16 To 20
                  If ( ObjectID = #REXB1 )
                      *MsgEx\ReturnCode = 0
                  EndIf  
                  If ( ObjectID = #REXB2 )
                      *MsgEx\ReturnCode = 2
                  EndIf           
                  If ( ObjectID = #REXB3 )
                      *MsgEx\ReturnCode = 1
                  EndIf  
                  
          EndSelect
          
          If IsGadget(#REXCBBTN)
              If ( GetGadgetState(#REXCBBTN) = 1 ) And ( *MsgEx\Checkbox_On = 1 )
                  *MsgEx\ReturnCode + 4
              EndIf  
          EndIf    
          
          ; Reset Values
          *MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12)
          *MsgEx\Fnt2 = FontID(Fonts::#_SEGOEUI10N)
          *MsgEx\Fnt3 = FontID(Fonts::#_SEGOEUI10N)  
          
          *MsgEx\WH   = -1
          *MsgEx\WW   = -1
          
          *MsgEx\Col__Window = $505050
          *MsgEx\Col__WinBox = $1F1F1F          
          *MsgEx\Col_HeadFrn = $EFF0EB
          *MsgEx\Col_HeadBck = $1F1F1F
          *MsgEx\Col_TextFrn = $EFF0EB
          *MsgEx\Col_TextBck = $505050
          *MsgEx\Col_StrgFrn = $EFF0EB
          *MsgEx\Col_StrgBck = $515151
          
          *MsgEx\Return__Flags = 0
          

          
          If IsGadget(#REXB1) : SSTTIP::ToolTipMode(2, #REXB1): EndIf            
          If IsGadget(#REXB3) : SSTTIP::ToolTipMode(2, #REXB3): EndIf
          If Not IsGadget(#REXB1) And Not IsGadget(#REXB3)
              If IsGadget(#REXB2): SSTTIP::ToolTipMode(2, #REXB2): EndIf
          EndIf 
          
          If IsImage(#REXICB): FreeImage(#REXICB): EndIf
                   
          ;AnimateWindow_(WindowID(#REXW0),1125,#AW_BLEND|#AW_HIDE)
          StickyWindow(#REXW0,0): Delay(55): HideWindow(#REXW0,1): CloseWindow(#REXW0)        
          ProcedureReturn #True
      EndProcedure   
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________                    
      Procedure MSG_Internal_CallBack(hWnd, uMsg, wParam, lParam)
          Protected pbMsg
          pbMsg = #PB_ProcessPureBasicEvents
          Select uMsg
              Case #WM_CTLCOLORSTATIC            
                  If IsGadget(#REXCBBTN)
                      Select lparam
                          Case GadgetID(#REXCBBTN)          
                              ProcedureReturn CreateSolidBrush_(*MsgEx\Col_TextBck) ;RGB(227, 227, 228             
                      EndSelect
                  EndIf
          EndSelect
          ProcedureReturn pbMsg
      EndProcedure      
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________              
      Procedure MSG_Internal_MouseToDefBtn(ObjectID)       
                  Protected hWnd.i
                  Protected GadgetRect.RECT
                  
                  If IsWindow_(ObjectID)
                      hWnd=ObjectID
                  ElseIf IsGadget(ObjectID)
                      hWnd=GadgetID(ObjectID)
                  Else
                      ProcedureReturn #False
                  EndIf
                  
                  GetWindowRect_(hWnd,@GadgetRect)
                  If ( GadgetRect\left = 0 And GadgetRect\right = 0 And GadgetRect\top = 0 And GadgetRect\bottom = 0 )
                      ProcedureReturn 0
                  EndIf    
                  
                  ProcedureReturn SetCursorPos_((GadgetRect\left + GadgetRect\right) / 2,(GadgetRect\top + GadgetRect\bottom) / 2)       
      EndProcedure 
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________             
      Procedure MSG_Internal_Language(*MsgEx.MsgReqEx)
          
          Dim Lng.s(7)
          
          Select GetUserDefaultLangID_() & $0003FF
              Case #LANG_GERMAN
                  lng(1) ="JA"
                  lng(2) = "Ok"
                  lng(3) = "Nein"
                  lng(4) = "Cancel"
                  lng(5) = "Abbruch"
                  lng(6) = "Weiter"
                  lng(7) = "Beenden"
                  ;Case #LANG_RUSSIAN
                  ;Case #LANG_SPANISH
                  ;Case #LANG_ENGLISH
                  ;Case #LANG_FRENCH                
              Default
                  lng(1) = "Yes"
                  lng(2) = "Ok"
                  lng(3) = "No"
                  lng(4) = "Cancel"
                  lng(5) = "Abort"
                  lng(6) = "Continue"
                  lng(7) = "Quit"
          EndSelect     
          
          
          Select *MsgEx\ButtonStyle
                  ; ---------------- One Button Version
                  ; Using Own text
              Case 0: 
                  ;
                  ; Yes
              Case 1: *MsgEx\User_BtnTextM = lng(1)
                  ;
                  ; Ok
              Case 2: *MsgEx\User_BtnTextM = lng(2)
                  ;
                  ; No
              Case 3: *MsgEx\User_BtnTextM = lng(3)
                  ;
                  ; Cancel
              Case 4: *MsgEx\User_BtnTextM = lng(4)
                  ;
                  ; Abort
              Case 5: *MsgEx\User_BtnTextM = lng(5)
                  ;
                  ; Quit
              Case 6: *MsgEx\User_BtnTextM = lng(7)
                  ; ---------------- Two Button Version (10>15)
                  ; Two Button Version From 10
                  ; Use Own text  
              Case 10
                  ;
                  ; Yes/ No
              Case 11
                  *MsgEx\User_BtnTextL = lng(1)
                  *MsgEx\User_BtnTextR = lng(3)
                  ;
                  ; Ok, Cancel
              Case 12
                  *MsgEx\User_BtnTextL = lng(2)
                  *MsgEx\User_BtnTextR = lng(4)
                  ;
                  ; Ok/ Quit
              Case 13
                  *MsgEx\User_BtnTextL = lng(2)
                  *MsgEx\User_BtnTextR = lng(7)           
                  ; ---------------- Three Button Version (16>20)
                  ; Use Own text
              Case 16
                  ; Yes, No, Cancel
              Case 17           
                  *MsgEx\User_BtnTextL = lng(1)
                  *MsgEx\User_BtnTextM = lng(3)           
                  *MsgEx\User_BtnTextR = lng(4)
                  
                  ; Yes, No Abort
              Case 18           
                  *MsgEx\User_BtnTextL = lng(1)
                  *MsgEx\User_BtnTextM = lng(3)           
                  *MsgEx\User_BtnTextR = lng(5)           
                  
                  ; Ok, Abort, Cancel
              Case 19        
                  *MsgEx\User_BtnTextL = lng(2)
                  *MsgEx\User_BtnTextM = lng(5)           
                  *MsgEx\User_BtnTextR = lng(4)           
                  
                  ; Yes No, Quit
              Case 20
                  *MsgEx\User_BtnTextL = lng(1)
                  *MsgEx\User_BtnTextM = lng(3)           
                  *MsgEx\User_BtnTextR = lng(7)           
          EndSelect   
          
          
      EndProcedure   
      
      ;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      ;
      ;________________________________________________________________________________________________________________________________     
      Procedure MSG_Internal_SetBtn(*MsgEx.MsgReqEx)
          
          Protected BtnH.l = 20, BtnW.l = 83, PosY.l = WindowHeight(#REXW0) - 25, TTT1$, TTT2$, TTT3$
          
          
          
          MSG_Internal_Language(*MsgEx.MsgReqEx)
          
          ; One Button Version
          Select *MsgEx\ButtonStyle
                  ;======================================================================================================================================
                  ; One Button Version
              Case 0 To 6        
                  PosX.l = WindowWidth(#REXW0) / 2 - (42.5)  
                  
                  ButtonEX::Add(#REXB2,PosX, PosY,BtnW, BtnH,
                                #REXBTNGR11N,
                                #REXBTNGR11H,
                                #REXBTNGR11P,
                                #REXBTNGR11D,*MsgEx\User_BtnTextM,*MsgEx\User_BtnTextM,*MsgEx\User_BtnTextM,GetSysColor_(#COLOR_3DFACE))           
                  
                  MSG_Internal_MouseToDefBtn(#REXB2)
                  
                  ;======================================================================================================================================
                  ; Two Button Version            
              Case 10 To 15
                  PosX.l = WindowWidth(#REXW0) - (BtnW + 4)
                  
                  ButtonEX::Add(#REXB1,004, PosY,BtnW, BtnH,
                                #REXBTNGR11N,
                                #REXBTNGR11H,
                                #REXBTNGR11P,
                                #REXBTNGR11D,*MsgEx\User_BtnTextL,*MsgEx\User_BtnTextL,*MsgEx\User_BtnTextL,GetSysColor_(#COLOR_3DFACE))
                  
                  ButtonEX::Add(#REXB3,PosX, PosY,BtnW, BtnH,
                                #REXBTNGR11N,
                                #REXBTNGR11H,
                                #REXBTNGR11P,
                                #REXBTNGR11D,*MsgEx\User_BtnTextR,*MsgEx\User_BtnTextR,*MsgEx\User_BtnTextR,GetSysColor_(#COLOR_3DFACE))            
                  
                  Select  *MsgEx\Default_Btn
                      Case 0: MSG_Internal_MouseToDefBtn(#REXB1)
                      Case 1: MSG_Internal_MouseToDefBtn(#REXB3)
                  EndSelect
                  
                  ;======================================================================================================================================
                  ; Three Button Version            
              Case 16 To 20
                  
                  
                  ButtonEX::Add(#REXB1,004, PosY,BtnW, BtnH,
                                #REXBTNGR11N,
                                #REXBTNGR11H,
                                #REXBTNGR11P,
                                #REXBTNGR11D,*MsgEx\User_BtnTextL,*MsgEx\User_BtnTextL,*MsgEx\User_BtnTextL,GetSysColor_(#COLOR_3DFACE))
                  
                  PosX.l = WindowWidth(#REXW0) / 2 - (42.5)             
                  ButtonEX::Add(#REXB2,PosX, PosY,BtnW, BtnH,
                                #REXBTNGR11N,
                                #REXBTNGR11H,
                                #REXBTNGR11P,
                                #REXBTNGR11D,*MsgEx\User_BtnTextM,*MsgEx\User_BtnTextM,*MsgEx\User_BtnTextM,GetSysColor_(#COLOR_3DFACE)) 
                  
                  PosX.l = WindowWidth(#REXW0) - (BtnW + 4)
                  ButtonEX::Add(#REXB3,PosX, PosY,BtnW, BtnH,
                                #REXBTNGR11N,
                                #REXBTNGR11H,
                                #REXBTNGR11P,
                                #REXBTNGR11D,*MsgEx\User_BtnTextR,*MsgEx\User_BtnTextR,*MsgEx\User_BtnTextR,GetSysColor_(#COLOR_3DFACE))            
                  
                  Select  *MsgEx\Default_Btn
                      Case 0: MSG_Internal_MouseToDefBtn(#REXB1)
                      Case 1: MSG_Internal_MouseToDefBtn(#REXB2)                          
                      Case 1: MSG_Internal_MouseToDefBtn(#REXB3)
                  EndSelect                                  
          EndSelect
          
          TTT1$ = "'Return' (" +*MsgEx\User_BtnTextL+ ")" 
          TTT2$ = "'Return' (" +*MsgEx\User_BtnTextM+ ")"
          TTT3$ = "'Escape' (" +*MsgEx\User_BtnTextR+ ")"
          
          If IsGadget(#REXB1)
              SSTTIP::TooltTip(WindowID(#REXW0), #REXB1, TTT1$, "", 0)
          EndIf            
          
          If IsGadget(#REXB3)
              SSTTIP::TooltTip(WindowID(#REXW0), #REXB3, TTT3$ , "", 0)
          EndIf
          
          If ( Not IsGadget(#REXB1) And Not IsGadget(#REXB3) )
              If IsGadget(#REXB2)
                  SSTTIP::TooltTip(WindowID(#REXW0), #REXB2, TTT2$, "", 0)
              EndIf
          EndIf          
          
          
      EndProcedure       
      
      ;================================================================================================================================
      ;
      ;________________________________________________________________________________________________________________________________                    
      Procedure.i MSG(Window_Title$ = "",
                      TopHead_Text$ = "",
                      Message_Text$ = "",
                      ButtonStyle.i = 2, Icon.i =  0, Icon_Program$ = "", sCheckBox.i = 0, sInput.i = 0,ParentID = #Null, bInputNums = #False)
          
          Protected FlagsEX.l, DeskX.i, DeskY.i, TxtBoxH.i = 105, TempW.i = 400, TempH.i = 135, MessPosX.i = 88, MessPosY.i = 32, WP_NonID.l = 0
          
          ;
          ; 
          Delay( 50 )
          
          If ( ParentID = #Null) 
              ParentID =  0
              WP_NonID = 0
          Else
            WP_NonID = ParentID
            ParentID = WindowID(ParentID)
          EndIf          
          
          ;
          ; Pflicht
          *MsgEx\Window_Title = Window_Title$
          *MsgEx\Message_Text = Message_Text$
          *MsgEx\TopHead_Text = TopHead_Text$
          *MsgEx\ButtonStyle  = ButtonStyle.i
          *MsgEx\Icon_Message = Icon.i
          *MsgEx\Icon_Program = Icon_Program$
          *MsgEx\WP           = ParentID
          *MsgEx\WP_NonID     = WP_NonID          
          *MsgEx\Checkbox_On  = sCheckBox.i
          *MsgEx\Return__Input= sInput.i
          
          
          Select *MsgEx\Text_Justify
              Case 0: *MsgEx\Text_Justify = #SS_LEFT
              Case 1: *MsgEx\Text_Justify = #SS_CENTER
              Case 2: *MsgEx\Text_Justify = #SS_RIGHT            
          EndSelect 
          
          If *MsgEx\Fnt1 = 0: *MsgEx\Fnt1 = FontID(Fonts::#_FIXPLAIN7_12): EndIf
          If *MsgEx\Fnt2 = 0: *MsgEx\Fnt2 = FontID(Fonts::#_SEGOEUI10N): EndIf
          If *MsgEx\Fnt3 = 0: *MsgEx\Fnt3 = FontID(Fonts::#_SEGOEUI10N)  : EndIf
          
          If *MsgEx\WH   = 0:  *MsgEx\WH   = -1: EndIf
          If *MsgEx\WW   = 0:  *MsgEx\WW   = -1: EndIf
          
          If *MsgEx\Col__Window  = 0: *MsgEx\Col__Window = $505050: EndIf
          If *MsgEx\Col__WinBox  = 0: *MsgEx\Col__WinBox = $1F1F1F: EndIf          
          If *MsgEx\Col_HeadFrn  = 0: *MsgEx\Col_HeadFrn = $EFF0EB: EndIf
          If *MsgEx\Col_HeadBck  = 0: *MsgEx\Col_HeadBck = $1F1F1F: EndIf
          If *MsgEx\Col_TextFrn  = 0: *MsgEx\Col_TextFrn = $EFF0EB: EndIf
          If *MsgEx\Col_TextBck  = 0: *MsgEx\Col_TextBck = $505050: EndIf
          If *MsgEx\Col_StrgFrn  = 0: *MsgEx\Col_StrgFrn = $EFF0EB: EndIf
          If *MsgEx\Col_StrgBck  = 0: *MsgEx\Col_StrgBck = $515151: EndIf
          
          
          
          
          ; ==================================================================================================================
          ; Window Prepare (In Hide Mode)
          
          Flags.l   = #PB_Window_Invisible 
          FlagsEX.l = #WS_EX_WINDOWEDGE    
          
          WinGuru::Style(#REXW0,0 ,0 ,2 ,2 ,Flags ,RGB(0,0,0) ,#True, #True, #True, #Null ,#True,#False,*MsgEx\WP)
   
          DesktopEx::Icon_HideFromTaskBar(WindowID(#REXW0),1)
          ; Message text
          FORM::TextObject(#REXT1,88 ,32 ,357, 60, *MsgEx\Fnt2,RGB(0, 0, 0),RGB(0, 0, 0),*MsgEx\Message_Text,0)
          
          ; Checkbox text
          If (*MsgEx\Checkbox_On = 1)
              FORM::TextObject(#REXT2,88 ,32 ,357, 60,*MsgEx\Fnt3,RGB(0, 0, 0),  RGB(0, 0, 0),*MsgEx\CheckBox_Txt,0)
          EndIf 
          ; Input text
          If (*MsgEx\Return__Input= 1)
              FORM::StrgObject(#REXS1,88 ,32 ,357, 60,*MsgEx\Fnt3, RGB(0, 0, 0), RGB(0, 0, 0),"@",0)
          EndIf             
          
          If ( *MsgEx\WW  = -1 )
              *MsgEx\WW = TempW              
          EndIf
          
          If ( *MsgEx\WH  = -1 )
              *MsgEx\WH = TempH
          EndIf
          
          ;
          ; Set Dynamic Heigh
          rFntPixH.i = FORM::GetRequiredHeight(#REXT1)
          rFntPixW.i = FORM::GetRequiredWidth(#REXT1)
          If (*MsgEx\Checkbox_On   = 1)
              rFntPixC.i= FORM::GetRequiredHeight(#REXT2)
              If rFntPixC <= 20
                  rFntPixC = 20
              EndIf    
          EndIf   
          
          If (*MsgEx\Return__Input = 1)
              rFntPixS.i= FORM::GetTextHeightPix(#REXS1)
              rFntPixT.i= FORM::GetRequiredHeight(#REXS1)
          EndIf 
          
          *MsgEx\WW = MessPosX + rFntPixW + 20
          *MsgEx\WH = 60 + rFntPixH + rFntPixC + rFntPixS
          
          If (rFntPixC >= 1)
              *MsgEx\WH + 6
              TempH     + 6
          EndIf
          If (rFntPixS >= 1)
              *MsgEx\WH + 6
              TempH     + 6
          EndIf
          
          ; Set Message Position
          If ( TempW >= *MsgEx\WW )
              MessPosX - 36
              *MsgEx\WW = TempW
              GetMiddleW = 306
              GetMiddleW - rFntPixW
              GetMiddleW / 2
              MessPosX + GetMiddleW
          EndIf  
          
          If ( TempH >= *MsgEx\WH )
              *MsgEx\WH = TempH + rFntPixC + rFntPixS               
              GetMiddleH = TempH - 64
              GetMiddleH - rFntPixH
              GetMiddleH / 2
              MessPosY + GetMiddleH
          EndIf  
          
          bDlgResize= #False
          If ( *MsgEx\WH > 640 )
              Debug "DialogRequest Height" + Str(*MsgEx\WH  )
              *MsgEx\WH = 640
              bDlgResize = #True
              Debug "DialogRequest Height" + Str(*MsgEx\WH  ) + " Geändert"
          EndIf
          If ( *MsgEx\WW > 960 )
              Debug "DialogRequest Width" + Str(*MsgEx\WW  )              
              *MsgEx\WW = 960
              rFntPixW  = 960 - (MessPosX*2)
              bDlgResize = #True
              Debug "DialogRequest Width" + Str(*MsgEx\WW  )  + " Geändert"  
          EndIf  
          
          ;
          ;  
          ; Close Window ===================================================================================================== 
          CloseWindow(#REXW0)
          
          Flags.l   = #PB_Window_Invisible 
          FlagsEX.l = #WS_EX_WINDOWEDGE
          
         
          WinGuru::Style(#REXW0,0 ,0,*MsgEx\WW,*MsgEx\WH+4, Flags, *MsgEx\Col__Window ,#True, #True, #True, FlagsEX ,#True,#True,*MsgEx\WP,*MsgEx\Col__WinBox)
          
          If (*MsgEx\WP <> 0)
              WinGuru::Center(#REXW0,*MsgEx\WW,*MsgEx\WH+4, #REXW0)
              DisableWindow(*MsgEx\WP_NonID,1)
          EndIf 
          
          
          
          DesktopEx::Icon_HideFromTaskBar(WindowID(#REXW0),1)
          StickyWindow(#REXW0,1)
          ; Window Title Text
          SetWindowTitle(#REXW0,*MsgEx\Window_Title)  
          ; Top Head text
          FORM::TextObject(#REXT0,02 ,10 ,*MsgEx\WW -4, 18,
                           *MsgEx\Fnt1,
                           *MsgEx\Col_HeadFrn,
                           *MsgEx\Col_HeadBck,
                           *MsgEx\TopHead_Text,#PB_Text_Center)
          
          
            
          

          
          If ( bDlgResize = #False )
          ; Message text
              FORM::TextObject(#REXT1,MessPosX ,MessPosY ,rFntPixW, rFntPixH,
                               *MsgEx\Fnt2,
                               *MsgEx\Col_TextFrn,
                               *MsgEx\Col_TextBck,
                               *MsgEx\Message_Text,*MsgEx\Text_Justify)
          Else    
          
              FORM::EditObject(#REXT1,MessPosX ,MessPosY ,rFntPixW+20, *MsgEx\WH-60,
                               *MsgEx\Fnt2,
                               *MsgEx\Col_TextFrn,
                               *MsgEx\Col_TextBck,
                               *MsgEx\Text_Justify|#PB_Editor_ReadOnly,1) 
                SetGadgetText(#REXT1, *MsgEx\Message_Text)
                
                WinGuru::Center(#REXW0,WindowWidth(#REXW0),WindowHeight(#REXW0), #REXW0)
          EndIf
          
          MSG_Internal_SetBtn(*MsgEx.MsgReqEx)
          MSG_Internal_Image()
          
          ; ==================================================================================================================
          ; Checkbox and Text
          If (*MsgEx\Checkbox_On = 1)        
              PosY.i = WindowHeight(#REXW0) - (rFntPixC + 30)
              PosW.i = WindowWidth(#REXW0) - 4
              
              CheckBoxGadget(#REXCBBTN,PosW - 20 ,PosY+3, rFntPixC/1.5, rFntPixC/1.5,"")
              
              FORM::TextObject(#REXT2,4, PosY, PosW -32, rFntPixC,
                               *MsgEx\Fnt3,
                               *MsgEx\Col_TextFrn,
                               *MsgEx\Col_TextBck,
                               *MsgEx\CheckBox_Txt,#SS_RIGHT) 
              
              WinGuru::ThemeBox(#REXW0,PosW , 1, 0, PosY -2, $1F1F1F)
              
              SetWindowCallback(@MSG_Internal_CallBack(), #REXW0): SetGadgetState(#REXCBBTN,*MsgEx\CheckBox_En)
          EndIf
          ;
          ; ==================================================================================================================
          
          ; ==================================================================================================================
          ; Input String
          If (*MsgEx\Return__Input= 1)        
              PosY.i = WindowHeight(#REXW0) - (rFntPixT + 30)
              PosW.i = WindowWidth(#REXW0)
              StrH.i = rFntPixT - rFntPixS                                          
              WinGuru::ThemeBox(#REXW0,PosW , 1, 0, PosY-1 , $1F1F1F)
              WinGuru::ThemeBox(#REXW0,PosW , rFntPixT, 0, PosY, *MsgEx\Col_StrgBck)              
              
              FORM::StrgObject(#REXS1,1, PosY + StrH/2 , PosW, rFntPixS,
                               *MsgEx\Fnt3,
                               *MsgEx\Col_StrgFrn,
                               *MsgEx\Col_StrgBck,
                               *MsgEx\Return_String,#SS_CENTER|*MsgEx\Return__Flags,1)
              
              If ( Len(*MsgEx\Return_String) >= 1 )
                  SendMessage_(GadgetID(#REXS1),#EM_SETSEL,Len(*MsgEx\Return_String),-1)
                  
                  If ( bInputNums = #True )
                      sReturnLenght.s = "[" + Str( Len( *MsgEx\Return_String ))+ "] " + Window_Title$                      
                      SetWindowTitle(#REXW0 , sReturnLenght)
                  EndIf    
                                
              EndIf
              SetActiveGadget(#REXS1) 
          EndIf
          ;
          ;==================================================================================================================             
          Delay( 5 )
          HideWindow(#REXW0,0)                     
          
          Repeat    
              EvntWait = WaitWindowEvent(): EvntWindow = EventWindow(): EvntGadget = EventGadget(): EvntType   = EventType()
              EvntMenu = EventMenu()      : EvntwParam = EventwParam(): EvntlParam = EventlParam(): EvntData   = EventData()           
              
              
              Select EvntWait                                          
                  Case #WM_KEYUP
                      
                      Select EvntwParam
                          Case 13 
                              ; Return
                              If IsGadget(#REXB1)                                  
                              	rQuit= MSG_Internal_Return(#REXB1)                             	
                                  
                              ElseIf Not IsGadget(#REXB1)    
                              	rQuit= MSG_Internal_Return(#REXB2)                            	
                              EndIf    
                                  
                          Case 27
                              ; ESC
                              If IsGadget(#REXB1)
                              	rQuit= MSG_Internal_Return(#REXB3)                             	
                              EndIf    
                      EndSelect        
                  Case #PB_Event_CloseWindow
                  Case #PB_Event_Gadget

                        
                      Select EvntType                              
                      	Case #PB_EventType_LeftClick
                      		rClicked = #True
                      EndSelect 
                      
                      Select EvntGadget
                          Case #REXB1, #REXB2, #REXB3          ; Button left; Button Middle ; Button Right                                                                                                       
                          	Select ButtonEX::ButtonExEvent(EvntGadget)
                          			
                              	Case ButtonEX::#ButtonGadgetEx_Pressed
                              		ButtonEX::SetState(EvntGadget,0)
                              		rQuit= MSG_Internal_Return(EvntGadget)
                              		Break;
                            EndSelect                            
                              
                          Case #REXS1
                              If SendMessage_(GadgetID(#REXS1), #EM_GETMODIFY, 0, 0)
                                  
                                  sReturnLenght.s = ""
                                 
                                 *MsgEx\Return_String = GetGadgetText(#REXS1)
                                
                                Debug *MsgEx\Return_String
                                If ( bInputNums = #True )
                                    sReturnLenght = "[" + Str( Len( *MsgEx\Return_String ))+ "] " + Window_Title$
                                                                
                                    SetWindowTitle(#REXW0 , sReturnLenght)
                                EndIf                                
                            EndIf    
                                                        
                          Case #REXCBBTN                              
                              
                      EndSelect
              EndSelect    
          Until rQuit = #True
                    
          SetWindowCallback(0, #REXW0)
         
          
          Debug #TAB$ + "========================================="
          Debug #TAB$ + "Message Requester Result: " + Str(*MsgEx\ReturnCode)
          Debug #TAB$ + "Message Requester String: " + *MsgEx\Return_String          
          Debug #TAB$ + "=========================================" +#CR$                      
          
          If (*MsgEx\WP <> 0)             
              DisableWindow(*MsgEx\WP_NonID,0)
          EndIf 
          
          ProcedureReturn *MsgEx\ReturnCode
          
          
      EndProcedure 
      
      
  EndModule

;////////////////////////////////////////////////////////////////////////////////////////////////// #PB_Compiler_IsMainFile


CompilerIf #PB_Compiler_IsMainFile
    
    

        
    Define Null.l
    
    If OpenWindow(0, 0, 0, 120, 100, "ButtonImage", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        ButtonGadget(1,10,50,100,20,"Button",0)
        
        SetWindowTheme_(GadgetID(1),@Null,@Null)
        SetWindowLongPtr_(GadgetID(1),#GWL_STYLE,GetWindowLongPtr_(GadgetID(1),#GWL_STYLE)|#BS_FLAT) 
        
        
        Repeat
            Event = EventGadget()    
            Select Event
                Case 1
                    
                    ;RequestEX::Dialog_Execute()
                    ;RequestEX::Dialog_Reboot()
                    ;RequestEX::Dialog_Color()
                    ;RequestEX::Dialog_NetConnectPrint() 
                    ;RequestEX::Dialog_NetUsersPass()
                    ;RequestEX::Dialog_Restart()
                    ;RequestEX::Dialog_Font("Verdana", 1, 1, 1 , 1, 20, RGB(255, 0, 0))
                    
                    MessageText$ = "Fritzchen schreibt aus dem Ferienlager:"      +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+                                   
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                   "Liebe Mami, lieber Papi. Mir geht es hier"    +#CR$+
                                   "sehr gut! Was ist eigentlich eine Epidemie?"  +#CR$+
                                 "'import site' failed; use -v for traceback###############################################################################Traceback (most recent call last):  File string, line 1, IN ?NameError: name '_get_trace' is Not defined###############################################################################"    +#CR$+
                                 "sehr gut! Was ist eigentlich eine Epidemie?"                                     
                  
                  BoxText$     = "Diesen Dialog Zukünftig nicht mehr anzeigen"
                  
                  ;MessageText$ = "Keine Updates im Verzeichnis: " + #CR$ + "D:\! Source Projects 5.42\LH Windows Updater"
                  Request::*MsgEx\User_BtnTextM = "Test Button"
                  r = Request::MSG("Test", "Button mit Eigenen Text",MessageText$,0,-1,ProgramFilename())
                  
;                   r = Request::MSG("Test", "Single Button JA"     ,MessageText$,1,0) ; Info Icon
;                   r = Request::MSG("Test", "Single Button OK"     ,MessageText$,2,1) ; Attention
;                   r = Request::MSG("Test", "Single Button Nein"   ,MessageText$,3,2) ; Stop
;                   r = Request::MSG("Test", "Single Button Cancel" ,MessageText$,4,3) ; Help
;                   r = Request::MSG("Test", "Single Button Abbruch",MessageText$,5)
;                   r = Request::MSG("Test", "Single Button Quit"   ,MessageText$,6)
;                   
;                   Request::*MsgEx\CheckBox_Txt = BoxText$
;                   r = Request::MSG("Test", "Single Mit Checkbox"  ,MessageText$,1,0,"",1)
;                   
;                   
;                   Request::*MsgEx\User_BtnTextL = "Button Links"
;                   Request::*MsgEx\User_BtnTextR = "Button Rechts"
;                   Request::*MsgEx\CheckBox_Txt  = BoxText$
;                   Request::*MsgEx\Return_String = BoxText$                  
;                   r = Request::MSG("Test", "2 Buttons mit Eigenen Text",MessageText$,10)
;                   r = Request::MSG("Test", "2 Buttons Ja / Nein"       ,MessageText$,11)
;                   r = Request::MSG("Test", "2 Buttons Ok / Cancel"     ,MessageText$,12)
;                   r = Request::MSG("Test", "2 Buttons Ok / Beenden"    ,MessageText$,13)
;                   
;                   Request::*MsgEx\User_BtnTextL = "Button Links"
;                   Request::*MsgEx\User_BtnTextM = "Button Mitte"
;                   Request::*MsgEx\User_BtnTextR = "Button Links"                  
;                   r = Request::MSG("Test", "3 Buttons, Eigene Text"    ,MessageText$,16)
;                   r = Request::MSG("Test", "3 Buttons Yes, No, Cancel" ,MessageText$,17)
;                   r = Request::MSG("Test", "3 Buttons Yes, No, Abort"  ,MessageText$,18)                 
;                   r = Request::MSG("Test", "3 Buttons Yes No, Quit"    ,MessageText$,19)                  
;                   
;                   MessageText$ = MessageText$ + #CR$ + MessageText$ + "Benutze Anderen Font"   
;                   
;                   Request::*MsgEx\Fnt1 = FontID(Fonts::#_EUROSTILE_12)
;                   Request::*MsgEx\Fnt2 = FontID(Fonts::#_EUROSTILE_12)
;                   Request::*MsgEx\Fnt3 = FontID(Fonts::#_EUROSTILE_12)
;                   Request::*MsgEx\User_BtnTextL = "Button Links"
;                   Request::*MsgEx\User_BtnTextM = "Button Mitte"
;                   Request::*MsgEx\User_BtnTextR = "Button Links"
;                   Request::*MsgEx\Checkbox_On   = 1
;                   Request::*MsgEx\CheckBox_Txt  = BoxText$
;                   Request::*MsgEx\Return_String = BoxText$
;                   r = Request::MSG("Test", "Dark Theme"    ,MessageText$,16,2,ProgramFilename(),0,1) 
;                   Debug Request::*MsgEx\Return_String
;                   
;                   
;                   Request::*MsgEx\Fnt1 = FontID(Fonts::#_EUROSTILE_12)
;                   Request::*MsgEx\Fnt2 = FontID(Fonts::#_EUROSTILE_12)
;                   Request::*MsgEx\Fnt3 = FontID(Fonts::#_EUROSTILE_12)
;                   Request::*MsgEx\User_BtnTextL = "Button Links"
;                   Request::*MsgEx\User_BtnTextM = "Button Mitte"
;                   Request::*MsgEx\User_BtnTextR = "Button Links"                                                       
;                   Request::*MsgEx\Col__Window = $00D5D5D5
;                   Request::*MsgEx\Col__WinBox = $666666  
;                   Request::*MsgEx\Col_HeadFrn = $EFF0EB
;                   Request::*MsgEx\Col_HeadBck = $666666
;                   Request::*MsgEx\Col_TextFrn = $00272727
;                   Request::*MsgEx\Col_TextBck = $00D5D5D5
;                   Request::*MsgEx\Col_StrgFrn = $00171717
;                   Request::*MsgEx\Col_StrgBck = $00F6F6F6              
;                   
;                    r = Request::MSG("Test", "Light Theme"    ,MessageText$,16,2,ProgramFilename(),0,1) 
;                   Debug Request::*MsgEx\Return_String
;                   
;                   r = Request::MSG("Test", "3 Buttons, Eigene Text"    ,MessageText$+#CR$+MessageText$+#CR$+MessageText$,16,2,ProgramFilename(),1,0) 
;                   Debug Request::*MsgEx\Return_String                  
;                   
;                 
;                   MessageText$ = "Programm Beenden ?"
;                   r = Request::MSG("Test", "Exit"       ,MessageText$,11)
                  
            EndSelect
        Until WaitWindowEvent() = #PB_Event_CloseWindow 
    EndIf


CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 919
; FirstLine = 676
; Folding = HCw-
; EnableAsm
; EnableThread
; EnableXP
; UseIcon = C:\Workbench\Utilities DesignICO\Programme\Dropbox FUSION.ico
; Executable = Test_Requester.exe
; CurrentDirectory = Release\
; CompileSourceDirectory
; EnableUnicode