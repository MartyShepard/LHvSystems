DeclareModule FORM
    
    Declare TextObject(TextGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,TextString$="",Flags.i=0)
    Declare StrgObject(StringGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,TextString$="",Flags.i=0,Borderless=0)
    Declare EditObject(StringGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,Flags.i=0,Borderless.i = 0,Wordwrap.i = 0)   
    Declare ListObject(ListGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,ItemHeight=0, Mode=0, Title$="",TitleWidth=0,TextColorFront=$000000,TextColorBack=$000000, Flags.l = #Null)
    Declare DateObject(DateGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,MASK$="",Date=#Null,Flags.i=0,Borderless=0)   
    Declare TrackBarFrame(ObjectID.i,X.i,Y.i,W.i,H.i,Min.i = 0, Max.i = 100,Flags.i = #Null,ExtendedFlags.i = #Null)
    Declare Extend(ObjectID,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000)
    Declare.l ListIconSetImages(GadgetID.i,RowCount.i,SizeX.i,SizeY.i,ImageIDStart.i= 0, ImageIDEnd.i= 0, Resize.i= #False, SmoothFlag.i = 0, Directory$ ="")
    Declare ListAutoSelectItem(LBHandleID.i,SearchFor$,FineTuning.i=0)
    Declare.l IsOverObject(hWnd)
    Declare ListAutoSelectItemEx(GadgetID.w,Expression.l,fMode.b=0,Column.b=0,iStart.l=0,Pos.i=-1,CurrentName$ = "")
    Declare GadgetClip(FlickerID.l,CLIPSIBLINGS.l = #False)
    Declare.i CountTreeNodeItems(Gadget, StartLevel = -1)
    Declare.i ReplaceLine(iFileID,sFileName.s,iRepLineNum.i,sReplacement.s,sFormat.i = #PB_Ascii)
    Declare.i AddTextLine(iFileID,sFileName.s,sAddString.s,sFormat.i = #PB_Ascii)
    Declare.l GetTextWidthPix(numb)
    Declare.l GetTextHeightPix(numb)
    Declare.l GetRequiredWidth(Gadget, Flags = 0)
    Declare.l GetRequiredheight(Gadget, Flags = 0)
    Declare.i GetGadgetPosition(ObjectID.i)
    Declare.i StringGadgetCursorX(Gadget) 
    Declare.i StringGadgetCursorY(Gadget)
    Declare.i IsInteger(value.s)
    Declare   StringGadgetTextSelect(Gadget.i, DontMoveCrt=#True, Min=0,Max=-1)
    Declare   ImageResizeEx(ImageID.l,Width.l,Height.l,ColorBack=$000000,Alpha.i = #False, Level.i = 255 )
    Declare   ImageResizeEx_Thread(ImageID.l, w, h, BoxStyle = 0, Color = $000000, Center = #False, Alpha = #False, Level = 255)
    Declare.s Get_GadgetClass(GadgetObject.i,ShowClassDebug = #False)
    Declare   ResizeGadgetOS_Windows(Class.s, ClassLong.l, Update = #False)
    Declare   WindowFlickeringEvade(handle)
    Declare.l WindowSizeBorder(WindowID.l)
    Declare.l WindowSizeTitleB(WindowPBID.l)
    
    
    Declare     VertCenter(StringGadgetID, CenterVertically.I)
    ;
    ; Diesse Strukture kann mit mit dem Source Code verzahnt werden wenn es sich um den Caret von den Jeweiligen
    ; Textboxen oder StringGadget handelt
    ;
    Global PBCaret.point  
EndDeclareModule

Module FORM
    
    #TBS_TOOLTIPS = $100
    #TVM_SETITEMHEIGHT = 4379
    
    Structure STRUCT_REZIMAGES
        ImageID.l
        Width.l
        Height.l 
        ColorBlack.l
        BoxStyle.i
        Center.i
        Alpha.i
        Level.i       
    EndStructure     
  
    CompilerIf Defined(Max, #PB_Procedure) = 0
      Procedure Max(a, b)
        If a > b
          ProcedureReturn a
        Else
          ProcedureReturn b
        EndIf
      EndProcedure
    CompilerEndIf 
    Procedure.l GetWindowHandle(WindowID.l)
        Protected hwnd.l = -1
        
        If IsWindow(WindowID.l)
            ;
            ; Get Window ID Long
            ProcedureReturn WindowID(WindowID.l)
        Else
            ;
            ; Get Purebasic Window ID
             hwnd = GetProp_(WindowID,"PB_WINDOWID") - 1
             ProcedureReturn hwnd
        EndIf
    EndProcedure               
    ;--------------------------------------------------------------------------------------------------------------------------------    
    ; LH.Game(User,Interface) , Kombiniertes Text Gadget
    ;________________________________________________________________________________________________________________________________    
    Procedure TextObject(TextGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,TextString$="",Flags.i=0)
        
        TextGadget(TextGadgetID.i, X, Y, Abs(W), H,TextString$,Flags) 
                       
        SetGadgetFont(TextGadgetID.i, TextFontID)
        SetGadgetColor(TextGadgetID.i,#PB_Gadget_FrontColor,TextColorFront) 
        SetGadgetColor(TextGadgetID.i,#PB_Gadget_BackColor,TextColorBack)
        
    EndProcedure
    
    Procedure VertCenter(StringGadgetID, CenterVertically.I)

      Protected ClientRect.RECT
      Protected DCHandle.I
      Protected Text.S = GetGadgetText(StringGadgetID)
      Protected TextXY.SIZE
     
      DCHandle = GetDC_(GadgetID(StringGadgetID))
      SelectObject_(DCHandle, GetGadgetFont(StringGadgetID))
      GetTextExtentPoint32_(DCHandle, Text, Len(Text), @TextXY)
      ReleaseDC_(GadgetID(StringGadgetID), DCHandle)
      GetClientRect_(GadgetID(StringGadgetID), ClientRect)

      If CenterVertically
        ClientRect\top = (ClientRect\bottom - TextXY\cy) / 2 - 1
      EndIf
     
      SendMessage_(GadgetID(StringGadgetID), #EM_SETRECT, 0, ClientRect)
      InvalidateRect_(GadgetID(StringGadgetID), 0, #True)

  EndProcedure
  
    ;--------------------------------------------------------------------------------------------------------------------------------    
    ; LH.Game(User,Interface) , Kombiniertes String Gadget
    ;________________________________________________________________________________________________________________________________    
    Procedure StrgObject(StringGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,TextString$="",Flags.i=0,Borderless=0)   
        
        StringGadget(StringGadgetID,X,Y,W,H,TextString$,Flags)
        Select Borderless
            Case 1
                SetWindowLongPtr_(GadgetID(StringGadgetID.i), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(StringGadgetID.i), #GWL_EXSTYLE) &(~#WS_EX_CLIENTEDGE))
                SetWindowPos_(GadgetID(StringGadgetID.i), 0, 0, 0, 0, 0, #SWP_SHOWWINDOW | #SWP_NOZORDER | #SWP_NOSIZE | #SWP_NOMOVE | #SWP_FRAMECHANGED)
            Default    
        EndSelect
        
        SetGadgetFont(StringGadgetID, TextFontID)
        SetGadgetColor(StringGadgetID,#PB_Gadget_FrontColor,TextColorFront)         
        SetGadgetColor(StringGadgetID,#PB_Gadget_BackColor ,TextColorBack) 
    EndProcedure
    
    ;--------------------------------------------------------------------------------------------------------------------------------    
    ; LH.Game(User,Interface) , Kombiniertes Date Gadget
    ;________________________________________________________________________________________________________________________________    
    Procedure DateObject(DateGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,MASK$="",Date=#Null,Flags.i=0,Borderless=0)   
        
        DateGadget(DateGadgetID,X,Y,W,H,MASK$,Date,Flags)
        Select Borderless
            Case 1
                SetWindowLongPtr_(GadgetID(DateGadgetID.i), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(DateGadgetID.i), #GWL_EXSTYLE) &(~#WS_EX_CLIENTEDGE))
                SetWindowPos_(GadgetID(DateGadgetID.i), 0, 0, 0, 0, 0, #SWP_SHOWWINDOW | #SWP_NOZORDER | #SWP_NOSIZE | #SWP_NOMOVE | #SWP_FRAMECHANGED)
                ; Dategadget liegt unter dem String
                SetWindowLongPtr_(GadgetID(DateGadgetID), #GWL_STYLE, GetWindowLongPtr_(GadgetID(DateGadgetID), #GWL_STYLE) | #WS_CLIPSIBLINGS &~ #WS_BORDER| #DTS_SHOWNONE)                
                ; Langeformat
                ;SetWindowLongPtr_(GadgetID(DateGadgetID), #GWL_STYLE, GetWindowLongPtr_(GadgetID(DateGadgetID), #GWL_STYLE) | #WS_CLIPSIBLINGS &~ #WS_BORDER| #DTS_LONGDATEFORMAT)
            Default    
        EndSelect
        
        SetGadgetFont(DateGadgetID, TextFontID)
        SetGadgetColor(DateGadgetID,#PB_Gadget_FrontColor,TextColorFront)         
        SetGadgetColor(DateGadgetID,#PB_Gadget_BackColor ,TextColorBack) 
    EndProcedure
    
    ;--------------------------------------------------------------------------------------------------------------------------------    
    ; LH.Game(User,Interface) , Kombiniertes Editor Gadget
    ;________________________________________________________________________________________________________________________________    
    Procedure EditObject(StringGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000,Flags.i=0,Borderless.i = 0,Wordwrap.i = 0)   
        
        EditorGadget(StringGadgetID,X,Y,W,H,Flags)
        Select Borderless
            Case 1
                SetWindowLongPtr_(GadgetID(StringGadgetID.i), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(StringGadgetID.i), #GWL_EXSTYLE) &(~#WS_EX_CLIENTEDGE))
                SetWindowTheme_(GadgetID(StringGadgetID), @null.w, @null.w)                  
            Default    
        EndSelect
        
        If IsFont(TextFontID)
            SetGadgetFont(StringGadgetID,FontID(TextFontID))
        ElseIf (TextFontID <> 0)        
            SetGadgetFont(StringGadgetID, TextFontID)
        EndIf    
        SetGadgetColor(StringGadgetID,#PB_Gadget_FrontColor,TextColorFront)         
        SetGadgetColor(StringGadgetID,#PB_Gadget_BackColor ,TextColorBack)
        If Wordwrap = 1
            SendMessage_(GadgetID(StringGadgetID),#EM_SETTARGETDEVICE,#Null,0)
        EndIf    
    EndProcedure
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ; Generate a Listview or ListIconGadget Gadget without Frame Border
    ;____________________________________________________________________________________________________      
    Procedure  ListObject(ListGadgetID.i,X.i,Y.i,W.i,H.i,TextFontID.i,ItemHeight=0, Mode=0, Title$="",TitleWidth=0,TextColorFront=$000000,TextColorBack=$000000,Flags.l = #Null)  ;(Mode 0=ListViewGadget, Mode 1=ListIconGadget)           
            
        Select Mode
            Case 0
                ListViewGadget(ListGadgetID.i,X,Y,W,H)
            Case 1
                ListIconGadget(ListGadgetID.i,X,Y,W,H,Title$,TitleWidth,#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|Flags)
            Case 2
                ListIconGadget(ListGadgetID.i,X,Y,W,H,Title$,TitleWidth,#PB_ListIcon_FullRowSelect|#LVS_NOCOLUMNHEADER|#PB_ListIcon_AlwaysShowSelection|Flags)
            Case 3
                ListIconGadget(ListGadgetID.i,X,Y,W,H,Title$,TitleWidth,#PB_ListIcon_FullRowSelect|#LVS_NOCOLUMNHEADER|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_CheckBoxes|Flags)
            Case 4                
                TreeGadget(ListGadgetID.i,X,Y,W,H,Flags)
        EndSelect
        
       SetWindowLongPtr_(GadgetID(ListGadgetID.i),#GWL_EXSTYLE,0)
        SetWindowPos_(GadgetID(ListGadgetID.i),0, X, Y, W,H,#SWP_FRAMECHANGED)
        
        If (ItemHeight <> 0)
            Select Mode
                Case 0,1,2              
                    SendMessage_(GadgetID(ListGadgetID.i),#LB_SETITEMHEIGHT,0,ItemHeight)        
                Case 3
                    SendMessage_(GadgetID(ListGadgetID.i),#TVM_SETITEMHEIGHT,ItemHeight, 0)
            EndSelect        
        EndIf
        
        If IsFont(TextFontID)
            SetGadgetFont(ListGadgetID,FontID(TextFontID))
        ElseIf (TextFontID <> 0)   
            SetGadgetFont(ListGadgetID,TextFontID)
        EndIf    
        SetGadgetColor(ListGadgetID,#PB_Gadget_FrontColor,TextColorFront)                 
        SetGadgetColor(ListGadgetID,#PB_Gadget_BackColor,TextColorBack)
        
    EndProcedure
            
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ; Zählt die Subnodes im Tree
    ;____________________________________________________________________________________________________        
    Procedure.i CountTreeNodeItems(Gadget, StartLevel = -1)
        Protected Count.i, Level0.i,Level1.i, TreeIndex.i, SubIndex.i, TreeSubLevel.i
        
        Select StartLevel
            Case -1        
                Level0 = CountGadgetItems(Gadget)
                If ( Level0 >= 1 )
                    ;Debug GetGadgetItemText(Gadget, TreeIndex)
                    
                    For TreeIndex = 1 To Level0

                        TreeSubLevel = TreeIndex
                        Repeat
                            Level1 = GetGadgetItemAttribute(Gadget, TreeSubLevel, #PB_Tree_SubLevel)                                                              
                            If ( Level1 >= 1 )  
                                SubIndex     +1
                                TreeSubLevel +1
                            EndIf    
                        Until Level1 = 0                        
                    Next
                EndIf
            Default
                StartLevel +1
                Repeat

                    Level1 = GetGadgetItemAttribute(Gadget, StartLevel, #PB_Tree_SubLevel)                                                              
                    If ( Level1 >= 1 ) 
                        ;Debug GetGadgetItemText(Gadget, StartLevel)
                        SubIndex     +1
                        StartLevel   +1
                       
                    EndIf    
                Until Level1 = 0   
        EndSelect         
        ProcedureReturn SubIndex
    EndProcedure  
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ; Generate a gadget with Font, and Color
    ;____________________________________________________________________________________________________    
    Procedure Extend(ObjectID,TextFontID.i,TextColorFront=$000000,TextColorBack=$000000)                
        SetGadgetFont(ObjectID,FontID(TextFontID))
        SetGadgetColor(ObjectID,#PB_Gadget_FrontColor,TextColorFront)                 
        SetGadgetColor(ObjectID,#PB_Gadget_BackColor,TextColorBack)
    EndProcedure        
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ; Generate a gadget with Front, and Color
    ;____________________________________________________________________________________________________     
    Procedure.l IsOverObject(hWnd)        
        Protected p.POINT, Result
        
        GetWindowRect_(hWnd,r.RECT)         
        GetCursorPos_(p.POINT) 
        Result = PtInRect_(r,p\y << 32 + p\x) 
        ProcedureReturn Result                           
    EndProcedure
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;
    ; Die Globale Structure, ListIcon Mit Bilder
    Structure LCPIMAGE
        ImageID.l
        Gadget.i
        Filename.s
    EndStructure
    Global NewList HandleImages.LCPIMAGE()
    
    ;
    ; GadgetID.i    = Indent Nummer des ListIcon Gadgets
    ; RowCount.i    = Maximale Anzahl der Elemenste in der ListIcon, Sollte die Liste zu grosszügig angeben werden wird diese Korrigiert
    ; SizeX,SizeY   = Die Breite und gösse der Bilder, wenn Resize nicht verwendet kann man die Orignal Weite angeben
    ; ImageIDStart.i= Die Purebasic ImageID() konstante die in der aufzählung anfängt z.b '#ImageID001'
    ; ImageIDEnd.i  = Die Purebasic ImageID() konstante die in der aufzählung endet z.b '#ImageID004'
    ; Resize.i      = Verkleinert oder vergrössert die Bilder. im zusammenhang mit  SizeX,SizeY verwenden für das Verkleiner/Vergrössern der Bilder
    ; SmoothFlag.i  = PureBasic Flag
    ;                 #PB_Image_Smooth (Bildgröße mit Kantenglättung)
    ;                 #PB_Image_Raw (Bildgröße ohne jegliche Interpolation)
    ; Directory$    = Das Vrzeichnis in dem sich die Bilder befinden, diese werden Optional mit in die Listbox hinzugefügt
    ;                 Kann auch Seperat Verwendet werden ohne die ImageID's, dann muss bei ImageIDStart.i, ImageIDEnd.i eine 0 stehen  
    
    
    Procedure.l ListIconSetImages(GadgetID.i,RowCount.i,SizeX.i,SizeY.i,ImageIDStart.i= 0, ImageIDEnd.i= 0, Resize.i= #False, SmoothFlag.i = 0, Directory$ ="")
        
        ;Resize #PB_Image_Smooth: Änderung der Bildgröße mit Kantenglättung ("smoothing")
        ;Resize #PB_Image_Raw   : Änderung der Bildgröße ohne jegliche Interpolation.
        
        Protected ImageIndex.i, ImageIDent.i, Hwnd.l, ImageIDCount.i, NewImage.l
        SendMessage_(GadgetID(GadgetID.i),#WM_SETREDRAW,0,0)
        
        ClearGadgetItems(GadgetID.i)
        While ListSize(HandleImages()): FreeImage(HandleImages()\ImageID): DeleteElement(HandleImages(), 1): Wend       
        
        For ImageIDent = ImageIDStart.i To  ImageIDEnd.i
            ImageIDCount.i = ImageIDCount.i + 1
        Next
        
        If ImageIDStart.i = 0: ImageIDCount.i = 0: EndIf       ; ImageID's wurde mit 0 angegeben
        If ImageIDEnd.i   = 0: ImageIDCount.i = 0: EndIf       ; ImageID's wurde mit 0 angegeben
                                                               ;
                                                               ;
                                                               ; Der Image Zähler (ID's sind unter dem RowCount oder der ImageCount ist 0
        If (ImageIDCount.i < RowCount.i) Or (ImageIDCount.i = 0)
            
            ; Säubern der Liste
            
            
            If Len(Directory$) <> 0
                
                ; Hinzufügen der Images zur Liste und päter zum ListIcon Gadget
                If Right(Directory$, 1) <> "\" : Directory$ = Directory$ + "\"  : EndIf
                
                If FileSize(Directory$) = -2
                    
                    RowCount.i = ImageIDCount.i
                    
                    If ExamineDirectory(0, Directory$, "*.*")
                        While NextDirectoryEntry(0)
                            Pattern$ = UCase(GetExtensionPart(Directory$ + DirectoryEntryName(0)))
                            Select Pattern$
                                Case "JPG","PNG","TIFF","TGA","BMP"
                                    
                                    NewImage.l = LoadImage(#PB_Any, Directory$ + DirectoryEntryName(0))
                                    
                                    If NewImage
                                        AddElement(HandleImages())
                                        HandleImages()\ImageID.l= NewImage  
                                        HandleImages()\Filename = Directory$ + DirectoryEntryName(0)
                                        ;HandleImages()\Gadget   = ImageGadget(#PB_Any, 0, 0, SizeX.i, SizeY.i, ImageID(HandleImages()\ImageID))
                                        RowCount.i + 1
                                    Else
                                        Debug "Invalid image: " + DirectoryEntryName(0)
                                    EndIf
                            EndSelect  
                        Wend
                    Else
                        RowCount.i = ImageIDCount.i  
                    EndIf
                Else
                    RowCount.i = ImageIDCount.i
                EndIf    
            Else
                RowCount.i = ImageIDCount.i
            EndIf    
        EndIf
        
        
        SetGadgetAttribute(GadgetID.i,#PB_ListIcon_DisplayMode ,#PB_ListIcon_LargeIcon)    
        ;
        ;
        For ImageIndex = 1 To RowCount.i
            AddGadgetItem(GadgetID.i,ImageIndex,"")            
        Next 
        
        
        ; Hinzufügen der Beschreibung, genommen wird der Dateiname (ohne suffix)
        If ListSize(HandleImages()) <> 0
            ResetList(HandleImages())
            While NextElement(HandleImages())
                SetGadgetItemText(GadgetID.i,ListIndex(HandleImages())+ImageIDCount.i,GetFilePart(HandleImages()\Filename,#PB_FileSystem_NoExtension),0)
            Wend        
        EndIf
        ;
        ;
        Select Resize.i
            Case 0
                If IsImage(ImageIDent)
                    If ImageHeight(ImageIDStart) <> SizeY.i
                        SizeY.i = ImageHeight(ImageIDStart)
                        SizeX.i = ImageWidth(ImageIDStart)
                    EndIf
                EndIf
                If ListSize(HandleImages()) <> 0
                    FirstElement(HandleImages())
                    SizeY.i = ImageHeight(HandleImages()\ImageID)
                    SizeX.i = ImageWidth(HandleImages()\ImageID)
                    ResetList(HandleImages())
                EndIf       
            Case 1
                If SizeX.i = 0: SizeX.i = 1: EndIf ; Size 0 Verboten, hat den effekt das Image wird gelöscht
                If SizeY.i = 0: SizeY.i = 1: EndIf ; Size 0 Verboten, hat den effekt das Image wird gelöscht
                
                For ImageIDent = ImageIDStart.i To  ImageIDEnd.i
                    Debug ImageIDent
                    If IsImage(ImageIDent): ResizeImage(ImageIDent,SizeX.i,SizeY.i,SmoothFlag.i): EndIf
                Next
                If ListSize(HandleImages()) <> 0
                    ResetList(HandleImages())
                    
                    While NextElement(HandleImages())
                        ResizeImage(HandleImages()\ImageID,SizeX.i,SizeY.i,SmoothFlag.i)
                    Wend
                EndIf      
        EndSelect        
        
        ;
        ; Die Höhe und Breite muss mit dem Bild übereinstimmen sonst wird es nicht angezeigt
        ; Bei änderungen der Höhen oder Breite muss immer Resize mit angegeben werden
        
        Hwnd = ImageList_Create_(SizeX,SizeY,#ILC_COLOR32|#ILC_MASK, (RowCount.i + ListSize(HandleImages())-1), 500)
        
        For ImageIDent = ImageIDStart.i To  ImageIDEnd.i
            If IsImage(ImageIDent)
                ImageList_Add_(Hwnd,ImageID(ImageIDent),0)
            EndIf
        Next
        
        If ListSize(HandleImages()) <> 0: ResetList(HandleImages())
            While NextElement(HandleImages())
                ImageList_Add_(Hwnd,ImageID(HandleImages()\ImageID),0)
            Wend
        EndIf    
        
        SendMessage_(GadgetID(GadgetID.i), #LVM_SETIMAGELIST, #LVSIL_NORMAL, Hwnd)
        
        lvi.LV_ITEM 
        lvi\mask = #LVIF_IMAGE
        
        For ImageIndex = 0 To (RowCount.i + ListSize(HandleImages())) -1       ; Fängt hier bei 0 an statt bei 1
            lvi\iItem  = ImageIndex
            lvi\iImage = ImageIndex
            SendMessage_(GadgetID(GadgetID.i),#LVM_SETITEM,0,lvi) 
        Next    
        
        
        
        SendMessage_(GadgetID(GadgetID.i),#WM_SETREDRAW,1,0)
        ProcedureReturn Hwnd
        
    EndProcedure          
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;
    ;
    Procedure ListAutoSelectItem(LBHandleID.i,SearchFor$,FineTuning.i=0)
        Protected LbItemH.i, LBState, Index.i, ItemText$
        
        LbItemH = SendMessage_(GadgetID(LBHandleID.i), #LVM_GETITEMSPACING, #True, 0) >> 16 ; only need to do this once       
        
        For Index = 0 To CountGadgetItems(LBHandleID.i)-1
            ItemText$ = GetGadgetItemText(LBHandleID.i,Index)
            If  LCase(ItemText$) = LCase(SearchFor$)
                LBState = Index:Break
            EndIf
        Next         
      
      SetGadgetItemState(LBHandleID.i,LBState,#PB_ListIcon_Selected)
      SendMessage_(GadgetID(LBHandleID.i), #LVM_SCROLL, 0, 0-(CountGadgetItems(LBHandleID.i) * LbItemH)) ; scroll to top
      Select FineTuning.i
          Case 0
              FineTuning.i = LBState
          Default
              FineTuning.i = LBState-FineTuning.i
      EndSelect              
      SendMessage_(GadgetID(LBHandleID.i), #LVM_SCROLL, 0, FineTuning.i * LbItemH)   
  EndProcedure
  
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;
    ;    
    Procedure ListAutoSelectItemEx(GadgetID.w,Expression.l,fMode.b=0,Column.b=0,iStart.l=0,Pos.i=-1,CurrentName$ = "")
      Protected hwndListbox.l, Position.l, ItemCount.l, Length.l, i.l, Label.s
      
      If Not IsGadget(GadgetID) : ProcedureReturn -1 : EndIf
      
      hwndListbox = GadgetID(GadgetID) : Position = -1
      
      ;Wird keine Pos angeben so wird im Gadget gesucht. ISt die Position bekannt .....
      If Pos = -1
          
          If fMode
              Position = Expression
          Else
              ItemCount = CountGadgetItems(GadgetID) - 1
              
              Length = lstrlen_(Expression)
              
              For i=iStart To ItemCount
                  Label = GetGadgetItemText(GadgetID,i,Column)
                  
                  If CompareMemoryString(Expression,@Label,0,Length) = 0
                      Position = i : Break
                  EndIf
              Next
          EndIf
      Else
          If fMode
              Position = Expression
          Else   
              Label   = CurrentName$
              Length  = lstrlen_(Expression)
              Position= Pos    
              
              CompareMemoryString(Expression,@Label,0,Length)
          EndIf   
      EndIf
      
      SendMessage_(hwndListbox,#WM_VSCROLL,#SB_TOP,0)
      SendMessage_(hwndListbox,#LVM_ENSUREVISIBLE,Position,1)
      
      If Position > SendMessage_(hwndListbox,#LVM_GETCOUNTPERPAGE,0,0)-1
          SendMessage_(hwndListbox,#WM_VSCROLL,#SB_PAGEDOWN,0)
          SendMessage_(hwndListbox,#WM_VSCROLL,#SB_LINEUP,0)
      EndIf   
      
      ;SetGadgetItemState(GadgetID,Position,#PB_ListIcon_Selected)     
      ProcedureReturn Position
  EndProcedure
  
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;
    ;      
  Procedure GadgetClip(FlickerID.l,CLIPSIBLINGS.l = #False)
      Select CLIPSIBLINGS
          Case #False
              ClipFlag.l =  #WS_CHILD|#WS_VISIBLE|#WS_CLIPCHILDREN              
          Case #True
              ClipFlag.l =  #WS_CHILD|#WS_VISIBLE|#WS_CLIPCHILDREN|#WS_CLIPSIBLINGS              
          Case -1
              ClipFlag.l = 0
          Default
              ClipFlag.l = CLIPSIBLINGS
       EndSelect 
        SetWindowLongPtr_(GadgetID(FlickerID), #GWL_STYLE, GetWindowLongPtr_(GadgetID(FlickerID), #GWL_STYLE) |ClipFlag) 
    EndProcedure 
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;Vertifter InnenRamen Trackbar Gadgets
    ;____________________________________________________________________________________________________
    Procedure TrackBarFrame(ObjectID.i,X.i,Y.i,W.i,H.i,Min.i = 0, Max.i = 100,Flags.i = #Null,ExtendedFlags.i = #Null)
        
        TrackBarGadget(ObjectID,X,Y,W,H,Min,Max,Flags.i)
        
        If ExtendedFlags.i <> #Null
            SetWindowLongPtr_(GadgetID(ObjectID.i),#GWL_STYLE,GetWindowLongPtr_(GadgetID(ObjectID.i),#GWL_STYLE) | ExtendedFlags.i)  
        EndIf    
    EndProcedure  
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  Ersetzt eine Zeile in einer beliebigen Textdatei (sFormat.i = #PB_Ascii,#PB_Unicode, #PB_UTF8 etc..)
    ;__________________________________________________________________________________________________________________
    Procedure ReplaceLine(iFileID,sFileName.s,iRepLineNum.i,sReplacement.s,sFormat.i = #PB_Ascii)
        NewList sData.s()
        iReturnVal = #True
        
        If ReadFile(iFileID,sFileName)      
            While Eof(iFileID) = 0      
                AddElement(sData())
                sData() = ReadString(iFileID)      
            Wend      
            CloseFile(iFileID)      
            SelectElement(sData(),(iRepLineNum -1)) ; -1 because first element number is zero
            sData() = sReplacement
            
            If CreateFile(iFileID,sFileName)
                
                FirstElement(sData())
                
                For i = 1 To ListSize(sData())      
                    WriteStringN(iFileID,sData(),sFormat)
                    NextElement(sData())      
                Next      
                CloseFile(iFileID)
            Else
                ;MessageRequester("File Issue","File create failed",#PB_MessageRequester_Ok)
                iReturnVal = -1
            EndIf
            
        Else
            ;MessageRequester("File Issue","File read failed",#PB_MessageRequester_Ok)
            iReturnVal = -2
            
        EndIf
        
        FreeList(sData())
        
        ProcedureReturn(iReturnVal)
        
    EndProcedure
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  Ergänzt eine Zeile in einer beliebigen Textdatei (sFormat.i = #PB_Ascii,#PB_Unicode, #PB_UTF8 etc..)
    ;__________________________________________________________________________________________________________________
    Procedure AddTextLine(iFileID,sFileName.s,sAddString.s,sFormat.i = #PB_Ascii)
        NewList sData.s()
        iReturnVal = 0
        
        If ReadFile(iFileID,sFileName)      
            While Eof(iFileID) = 0      
                AddElement(sData())
                sData() = ReadString(iFileID)      
            Wend      
            CloseFile(iFileID)   
            
            AddElement(sData())
            sData() = sAddString            
 
            ResetList( sData() )
            
            If CreateFile(iFileID,sFileName)
                
                FirstElement(sData())
                
                For i = 1 To ListSize(sData())      
                    WriteStringN(iFileID,sData(),sFormat)
                    NextElement(sData())      
                Next      
                CloseFile(iFileID)
            Else
                ;MessageRequester("File Issue","File create failed",#PB_MessageRequester_Ok)
                iReturnVal = -1
            EndIf
            
        Else
            ;MessageRequester("File Issue","File read failed",#PB_MessageRequester_Ok)
            iReturnVal = -2
            
        EndIf
        
        FreeList(sData())
        
        ProcedureReturn(iReturnVal)
        
    EndProcedure    
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;__________________________________________________________________________________________________________________    
    Procedure.l GetTextWidthPix(numb)
        hDC = GetDC_(GadgetID(numb)) 
        hFont = SendMessage_(GadgetID(numb),#WM_GETFONT,0,0)
        If hFont And hDC 
            SelectObject_(hDC,hFont) 
        EndIf 
        GetTextExtentPoint32_(hDC, GetGadgetText(numb), Len(GetGadgetText(numb)) , lpSize.SIZE)
        result=lpSize\cx
        ProcedureReturn result
    EndProcedure
    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;__________________________________________________________________________________________________________________    
    Procedure.l GetTextHeightPix(numb)
        hDC = GetDC_(GadgetID(numb)) 
        hFont = SendMessage_(GadgetID(numb),#WM_GETFONT,0,0)
        If hFont And hDC 
            SelectObject_(hDC,hFont) 
        EndIf 
        GetTextExtentPoint32_(hDC, GetGadgetText(numb), Len(GetGadgetText(numb)) , lpSize.SIZE)
        result=lpSize\cy
        ProcedureReturn result
    EndProcedure  
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;__________________________________________________________________________________________________________________    
    Procedure GetRequiredSize(Gadget, *Width.LONG, *Height.LONG, Flags = 0)
        DC = GetDC_(GadgetID(Gadget))
        oldFont = SelectObject_(DC, GetGadgetFont(Gadget)) 
        Size.SIZE
        
        Select GadgetType(Gadget)
                
            Case #PB_GadgetType_Text
                Text$ = RemoveString(GetGadgetText(Gadget), Chr(10))
                count = CountString(Text$, Chr(13)) + 1
                empty = 0
                maxheight = 0 
                For index = 1 To count 
                    Line$ = StringField(Text$, index, Chr(13))
                    If Line$ = ""
                        empty + 1
                    Else 
                        GetTextExtentPoint32_(DC, @Line$, Len(Line$), @LineSize.SIZE)
                        Size\cx = Max(Size\cx, LineSize\cx)
                        Size\cy + LineSize\cy
                        maxheight = Max(maxheight, LineSize\cy)
                    EndIf
                Next index            
                Size\cy + empty * maxheight  
                
                If Flags & #PB_Text_Border
                    Size\cx + GetSystemMetrics_(#SM_CXEDGE) * 2
                    Size\cy + GetSystemMetrics_(#SM_CYEDGE) * 2
                Else           
                    Size\cx + 2
                    Size\cy + 2
                EndIf
                
            Case #PB_GadgetType_CheckBox, #PB_GadgetType_Option
                Text$ = GetGadgetText(Gadget)
                GetTextExtentPoint32_(DC, @Text$, Len(Text$), @Size.SIZE)
                Size\cx + 20
                Size\cy = Max(Size\cy+2, 20)
                
            Case #PB_GadgetType_Button
                Text$ = GetGadgetText(Gadget)
                GetTextExtentPoint32_(DC, @Text$, Len(Text$), @Size.SIZE)
                Size\cx + GetSystemMetrics_(#SM_CXEDGE)*2
                Size\cy = Max(Size\cy+GetSystemMetrics_(#SM_CYEDGE)*2, 24)
                Size\cx + 10
                
            Case #PB_GadgetType_String
                Text$ = GetGadgetText(Gadget) + "Hg" 
                GetTextExtentPoint32_(DC, @Text$, Len(Text$), @Size.SIZE)
                Size\cx = GetSystemMetrics_(#SM_CXEDGE)*2 
                Size\cy = Max(Size\cy+GetSystemMetrics_(#SM_CXEDGE)*2, 20)
                
            Case #PB_GadgetType_ComboBox
                GetTextExtentPoint32_(DC, @"Hg", 2, @Size.SIZE)
                Size\cy = Max(Size\cy + 8, 21)
                Size\cx = Size\cy  
                
            Case #PB_GadgetType_Image
                Size\cx = GadgetWidth(Gadget)
                Size\cy = GadgetHeight(Gadget)
                
        EndSelect
        
        SelectObject_(DC, oldFont)
        ReleaseDC_(GadgetID(Gadget), DC)
        *Width\l  = Size\cx
        *Height\l = Size\cy        
    EndProcedure     
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;__________________________________________________________________________________________________________________    
    Procedure.l GetRequiredWidth(Gadget, Flags = 0)
        Protected Width.l, Height.l
        GetRequiredSize(Gadget, @Width, @Height, Flags)
        ProcedureReturn Width
    EndProcedure 
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;__________________________________________________________________________________________________________________    
    Procedure.l GetRequiredHeight(Gadget, Flags = 0)
        Protected Width.l, Height.l
        GetRequiredSize(Gadget, @Width, @Height, Flags)
        ProcedureReturn Height
    EndProcedure    
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ; Selektiert die Position in der Liste und gibt diese gleich wieder (als eine Funktion)
    ;_________________________________________________________________________________________________                         
    Procedure.i GetGadgetPosition(ObjectID.i)
       Position = GetGadgetState(ObjectID)
        Select Position
            Case -1
                ProcedureReturn -1
            Default
                ProcedureReturn Position
        EndSelect               
    EndProcedure 
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;________________________________________________________________________________________________________________________________      
    Procedure StringGadgetCursorX(Gadget) 
      SendMessage_(GadgetID(Gadget),#EM_GETSEL,@Min,@Max) 
      ProcedureReturn Max-SendMessage_(GadgetID(Gadget),#EM_LINEINDEX,SendMessage_(GadgetID(Gadget),#EM_LINEFROMCHAR,Min,0),0)+1 
    EndProcedure  
    Procedure StringGadgetCursorY(Gadget) 
      SendMessage_(GadgetID(Gadget),#EM_GETSEL,@Min,@Max) 
      ProcedureReturn SendMessage_(GadgetID(Gadget),#EM_LINEFROMCHAR,Min,0)+1 
  EndProcedure 
  
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ; Selektiert oder DeSelektieret den Text im Text/String Gadget Objekt
    ; Markieren von nach: StringGadgetTextSelect(GadgetID,5,10)
    ; Alles Markieren: StringGadgetTextSelect(GadgetID) 
    ; DestroyCaret_(), HideCaret_(GadgetID(Gadget)), SetCaretPos_(POINT\x,POINT\y), ShowCaret_(GadgetID(Gadget))
    ; DontMoveCrt: Lasse den Cursor nicht rumhoppeln z.b beim Doppeklick
    ;________________________________________________________________________________________________________________________________   
    Procedure StringGadgetTextSelect(Gadget.i,DontMoveCrt=#True, Min=0,Max=-1)      
        Protected POINT.point  
        
        If IsGadget(Gadget)
            SetActiveGadget(Gadget)                     

            If ( DontMoveCrt = #True )
                Max = StringGadgetCursorX(Gadget)-1
                Min = Max
            EndIf          

            SendMessage_(GadgetID(Gadget),#EM_SETSEL,Min,Max)
            SetCaretPos_(PBCaret\x,PBCaret\y)
            Debug "CARET: Min="+Str(Min)+" Max="+Str(Max)+" " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line)      
            
      Else
          Debug "KEIN STRING GADGET DEFINIERT: " +#PB_Compiler_Module + " #" + Str(#PB_Compiler_Line)         
      EndIf    
    EndProcedure
    ;--------------------------------------------------------------------------------------------------------------------------------   
    ;  
    ;__________________________________________________________________________________________________________________    
    Procedure.i IsInteger(value.s)
       Protected *char.Character
       Protected length.i
       
       length = 0
       *char = @value
       While(*char\c <> #NUL)
          
          If *char\c < '0' Or *char\c > '9'
             ProcedureReturn #False
          EndIf
          
          *char + SizeOf(Character)
          length + 1
       Wend
       
       If length = 0
          ProcedureReturn #False
       EndIf
       
       ProcedureReturn #True
    EndProcedure  
    ;**************************************************************************************************
    ;
    ; Resize Image to hold the Aspect Ration, Alternative als Thread
    ;     
    Procedure Thread_Resize(*ImagesResize.STRUCT_REZIMAGES)
        Define.l OriW, OriH, w, h, oriAR, newAR
        Define.f fw, fh
        
        
        OriW = ImageWidth(*ImagesResize\ImageID)
        OriH = ImageHeight(*ImagesResize\ImageID)
        
        If (OriH > OriW And *ImagesResize\Height < *ImagesResize\Width) Or (OriH < OriW And *ImagesResize\Height > *ImagesResize\Width)
            ;Swap *ImagesResize\Width, *ImagesResize\Height
        EndIf
        
        ; Calc Factor
        fw = *ImagesResize\Width /OriW
        fh = *ImagesResize\Height/OriH
        
        ; Calc AspectRatio
        oriAR = Round((OriW / OriH) * 10,0)
        newAR = Round((*ImagesResize\Width / *ImagesResize\Height) * 10,0)
        
        ; AspectRatio already correct?
        If oriAR = newAR 
            w = *ImagesResize\Width
            h = *ImagesResize\Height
            
        ElseIf OriW * fh <= *ImagesResize\Width
            w = OriW * fh
            h = OriH * fh
            
        ElseIf OriH * fw <= *ImagesResize\Height
            w = OriW * fw
            h = OriH * fw  
        EndIf
        
        ResizeImage(*ImagesResize\ImageID,w,h,#PB_Image_Smooth) 
        
        Select *ImagesResize\BoxStyle
            Case 1
                w = 0
                h = 0
                
                Select *ImagesResize\Alpha 
                        Case #False: CreateImage(DC::#ImageBlank,*ImagesResize\Width,*ImagesResize\Height) 
                        Case #True : CreateImage(DC::#ImageBlank,*ImagesResize\Width,*ImagesResize\Height,24,*ImagesResize\ColorBlack.l)
                EndSelect                 
                
                
                StartDrawing(ImageOutput(DC::#ImageBlank))
                
                Select *ImagesResize\Alpha 
                        Case #False: Box(0,0,*ImagesResize\Width,*ImagesResize\Height,*ImagesResize\ColorBlack.l)                          
                EndSelect                 
                
                                
                Select *ImagesResize\Alpha 
                        Case #False: DrawingMode(#PB_2DDrawing_AlphaBlend)
                        Case #True : DrawingMode(#PB_2DDrawing_Default)
                EndSelect 

                
                If ( *ImagesResize\Center = #True )
                    w = *ImagesResize\Width - Abs(ImageWidth(*ImagesResize\ImageID))
                    h = *ImagesResize\Height - Abs(ImageHeight(*ImagesResize\ImageID))
                    
                    If ( w <> 0 )
                        w / 2
                    EndIf
                    
                    If ( h <> 0 )
                        h / 2
                    EndIf
                    
                EndIf
                Select *ImagesResize\Alpha 
                        Case #False: DrawImage(ImageID(*ImagesResize\ImageID), w, h)
                        Case #True : DrawAlphaImage(ImageID(*ImagesResize\ImageID), w, h,*ImagesResize\Level) 
                EndSelect            
                StopDrawing()
                GrabImage(DC::#ImageBlank,*ImagesResize\ImageID, 0, 0, *ImagesResize\Width, *ImagesResize\Height) 
        EndSelect        
        
;         Select Alpha
;                Case #True
;                 CreateImage(DC::#ImageBlank,ImageWidth(ImageID),ImageHeight(ImageID),24,RGB(61,61,61))
;                     StartDrawing(ImageOutput(DC::#ImageBlank))
;                         DrawingMode(#PB_2DDrawing_Default)
;                         DrawAlphaImage(ImageID(ImageID), 0, 0,Level) 
;                     StopDrawing() 
;                 GrabImage(DC::#ImageBlank,ImageID, 0, 0, ImageWidth(ImageID), ImageHeight(ImageID)) 
;         EndSelect        
    EndProcedure         
    Procedure ImageResizeEx_Thread(ImageID.l, w, h, BoxStyle = 0, Color = $000000, Center = #False, Alpha = #False, Level = 255)
        
        *ImagesResize.STRUCT_REZIMAGES       = AllocateStructure(STRUCT_REZIMAGES) 
        InitializeStructure(*ImagesResize, STRUCT_REZIMAGES)          
        Protected ResizeThread
        If IsImage(ImageID.l)
            *ImagesResize\ImageID    = ImageID.l
            *ImagesResize\BoxStyle   = BoxStyle
            *ImagesResize\ColorBlack = Color
            *ImagesResize\Height     = h
            *ImagesResize\Width      = w        
            *ImagesResize\Center     = Center 
            *ImagesResize\Alpha      = Alpha
            *ImagesResize\Level      = Level
            
            ResizeThread = CreateThread(@Thread_Resize(),*ImagesResize)
            If IsThread(ResizeThread)
                WaitThread(ResizeThread)
            EndIf       
        EndIf
    EndProcedure     
    ;**************************************************************************************************
    ;
    ; Resize Image to hold the Aspect Ration
    ;
    Procedure ImageResizeEx(ImageID.l,Width.l,Height.l,ColorBack=$000000,Alpha.i = #False, Level.i = 255 )
        
        If ImageID = 0
            Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" ImageID IST NULL"
            ProcedureReturn
        EndIf    
        
        Define.l OriW, OriH, w, h, oriAR, newAR
        Define.f fw, fh
  
        
        OriW = ImageWidth(ImageID)
        OriH = ImageHeight(ImageID)

        If (OriH > OriW And Height < Width) Or (OriH < OriW And Height > Width)
            ;Swap Width, Height
        EndIf

        ; Calc Factor
        fw = Width/OriW
        fh = Height/OriH

        ; Calc AspectRatio
        oriAR = Round((OriW / OriH) * 10,0)
        newAR = Round((Width / Height) * 10,0)

        ; AspectRatio already correct?
        If oriAR = newAR 
            w = Width
            h = Height
            
        ElseIf OriW * fh <= Width
            w = OriW * fh
            h = OriH * fh
            
        ElseIf OriH * fw <= Height
            w = OriW * fw
            h = OriH * fw  
        EndIf

        ResizeImage(ImageID,w,h,#PB_Image_Smooth) 
        
        Select Alpha
               Case #True
                CreateImage(DC::#ImageBlank,ImageWidth(ImageID),ImageHeight(ImageID),24,RGB(61,61,61))
                    StartDrawing(ImageOutput(DC::#ImageBlank))
                        DrawingMode(#PB_2DDrawing_Default)
                        DrawAlphaImage(ImageID(ImageID), 0, 0,Level) 
                    StopDrawing() 
                GrabImage(DC::#ImageBlank,ImageID, 0, 0, ImageWidth(ImageID), ImageHeight(ImageID)) 
        EndSelect
    EndProcedure  
   ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   ;
   ;
    Procedure WindowFlickeringEvade(handle)
        If IsWindow(handle)
            handle = WindowID(handle)
        EndIf    
        
        SetWindowLongPtr_(hwnd, #GWL_STYLE, GetWindowLongPtr_(hwnd, #GWL_STYLE) |#WS_CLIPSIBLINGS|#WS_BORDER)   
   EndProcedure     
   ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   ;
   ;
   Procedure ResizeGadgetOS_Windows(Class.s, ClassLong.l, Update = #False)
       
       If ( Update = #False )
           Select Class
               Case "PureContainer"
                   SetWindowLongPtr_(ClassLong, #GWL_STYLE, GetWindowLongPtr_(ClassLong, #GWL_STYLE) |#WS_CLIPCHILDREN)                      
               Case "PureScrollArea"
                   SetWindowLongPtr_(ClassLong, #GWL_STYLE, GetWindowLongPtr_(ClassLong, #GWL_STYLE) |#WS_CLIPCHILDREN)                   
               Case "PureCanvas" 
               Case "Button"
                   SendMessage_(ClassLong, #WM_SETREDRAW, 0, 0) 
               Default
                   ;
                   ; Fehlende Klassen anzeigen
                   ;Debug "Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "Klasse Nicht berücksichtigt: " + Class                  
           EndSelect                    
           ProcedureReturn
       EndIf  
       
       If ( Update = #True )      
           Select Class
               Case "PureContainer"                   
               Case "PureScrollArea"                   
                   UpdateWindow_(ClassLong)  
               Case "PureCanvas" 
               Case "Button" 
                   SendMessage_(ClassLong, #WM_SETREDRAW, 1, 0)
                   InvalidateRect_(ClassLong, 0, 0)
                   UpdateWindow_(ClassLong)                     
           EndSelect 
           ProcedureReturn
       EndIf 
   EndProcedure     
 ;--------------------------------------------------------------------------------------------------------------------------------   
 ;  
 ;________________________________________________________________________________________________________________________________            
   Procedure.s Get_GadgetClass(GadgetObject.i,ShowClassDebug = #False)
       
       Define pszTypeReal$ = Space(1024)
       Define pszTypeName$ = Space(1024)            
       Protected GadgetLongID.l
       If IsGadget(GadgetObject)            
           GadgetLongID = GadgetID(GadgetObject)
       Else
           If IsWindow(GadgetObject)
               GadgetLongID = WindowID(GadgetObject)
           Else                     
                ; 
                If ( GadgetObject >= 1 )
                    GadgetLongID = GadgetObject
                Else
                    ProcedureReturn ""
                EndIf    
            EndIf
       EndIf     
              
       RealGetWindowClass_(GadgetLongID, @pszTypeReal$, Len(pszTypeReal$))
       GetClassName_(GadgetLongID,@pszTypeName$,Len(pszTypeName$))                 
       
       If ( ShowClassDebug = #True )             
           Debug "Klassenamen - Real Window Class: " + pszTypeReal$ + " /GadgetID: " +Str(GadgetObject) + " /GadgteLongID: " +Str(GadgetLongID) 
           If ( pszTypeReal$ <> pszTypeName$)               
               Debug "Klassenamen - Get  Class   Name: " + pszTypeName$ + " /GadgetID: " +Str(GadgetObject) + " /GadgteLongID: " +Str(GadgetLongID) + Chr(13)                
           EndIf            
       EndIf     
       ProcedureReturn pszTypeReal$
   EndProcedure    
 ;--------------------------------------------------------------------------------------------------------------------------------   
 ;  Get Window Border and Title in Pxels
 ;________________________________________________________________________________________________________________________________     
    Procedure.l Sub_ClientX(WindowID.l) 
      ClientRect.RECT 
      GetWindowRect_(WindowID, @ClientRect) 
      ClientPoint.POINT 
      ClientToScreen_(WindowID, @ClientPoint) 
      Result.l = WindowX(GetWindowHandle(WindowID)) + (ClientPoint\X - ClientRect\left) 
      ProcedureReturn Result.l 
    EndProcedure     
    Procedure.l Sub_ClientY(WindowID.l) 
      ClientRect.RECT 
      GetWindowRect_(WindowID, @ClientRect) 
      ClientPoint.POINT 
      ClientToScreen_(WindowID, @ClientPoint) 
      Result.l = WindowY(GetWindowHandle(WindowID)) + (ClientPoint\Y - ClientRect\top) 
      ProcedureReturn Result.l 
    EndProcedure 
    
    Procedure.l WindowSizeBorder(WindowPBID.l)                                                   ;> Returns the Border Size
      Result.l   = Sub_ClientX(GetWindowHandle(WindowPBID.l)) - WindowX(WindowPBID.l) 
      ProcedureReturn Result.l 
    EndProcedure 
    
    Procedure.l WindowSizeTitleB(WindowPBID.l)                                                 ;> Returns the Titlebar Size      
      Result.l   = Sub_ClientY(GetWindowHandle(WindowPBID.l)) - WindowY(WindowPBID.l)
      ProcedureReturn Result.l 
    EndProcedure   
EndModule
; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 918
; FirstLine = 396
; Folding = 8XhAAvh
; EnableAsm
; EnableXP
; EnableUnicode