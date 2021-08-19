
; 31.12.2013 PB 5.21 x86 Windows Vista


DeclareModule LVSORTEX
   ; Alle Elemente in diesem Abschnitt sind für den Zugriff von außerhalb verfügbar
   
   Enumeration 
      #ListIcon_Typ_Char      ;Datentypen 
      #ListIcon_Typ_Date
      #ListIcon_Typ_Float
      #ListIcon_Typ_Number
      #ListIcon_Sort_Up       ;Sortier Richtung
      #ListIcon_Sort_Down
   EndEnumeration
   
   Declare ListIconSortListe(pbnr,sort=0)
   Declare ListIconSortSetCol(pbnr, col)
   Declare ListIconSortAddClick(pbnr) 
   Declare ListIconSortAddGadget(pbnr, sort = #ListIcon_Sort_Up)
   Declare ListIconSortAddColumn(pbnr, col, typ = 0, lg = 0, DEC = 0, mask$ = "")
   Declare ListIconSortDelGadget(pbnr)
   
EndDeclareModule


Module LVSORTEX
   
   ;EnableExplicit
   
   Structure ListIconColInfo
      nr.i        ; Spaltennr ab null
      typ.i       ; Datentyp
      charanz.i   ; Anzahl Sortier-Zeichen
      decimals.i  ; Anzahl Dezimalstellen
      datemask.s  ; Mask für ParseDate()
   EndStructure   
   
   Structure ListIconSortInfo
      pbnr.i         ; PB Gadgednr
      sort.i
      direction.i    ; Sortierrichtung
      Array column.ListIconColInfo(0)   
   EndStructure   
   
   ;'lisi' wird von ListIconSortSetCol() mit Sortierdaten gefüllt
   Global lisi.ListIconSortInfo  
   
   ;für SortCallbackIntern, 
   Global original = GetClassLongPtr_(GetDesktopWindow_(), #GCL_HCURSOR) 
   Global idc_wait = LoadCursor_(0, #IDC_WAIT)  
   
   ;Liste mit Felddaten, aus dieser Liste wird 'lisi' mit Daten versorgt
   Global NewList LvFieldtyp.ListIconSortInfo()
   
   Procedure.i ListIconSortDelGadget(pbnr)
      
      ;Entfernt ein ListIconGadget aus der internen Liste
      
      ForEach LvFieldtyp()
         If LvFieldtyp()\pbnr = pbnr                        
            DeleteElement(LvFieldtyp()) 
         EndIf   
      Next
      
   EndProcedure
   
   Procedure.i ListIconSortAddGadget(pbnr, sort = #ListIcon_Sort_Up)
      
      ;Fügt ein ListIconGadget zur internen Liste hinzu
      ; und setzt Vorgaben ins ColumnArray
      
      Protected j
      Protected hd = SendMessage_(GadgetID(pbnr), #LVM_GETHEADER, #Null, #Null) 
      Protected cols = SendMessage_(hd, #HDM_GETITEMCOUNT, 0, 0) 
                  
      AddElement(LvFieldtyp())      
      ReDim LvFieldtyp()\column(cols)
      
      LvFieldtyp()\pbnr = pbnr
      LvFieldtyp()\sort = sort
      
      ;Vorgaben
      For j = 0 To cols
         LvFieldtyp()\column(j)\typ = #ListIcon_Typ_Char
         LvFieldtyp()\column(j)\charanz = 255
         LvFieldtyp()\column(j)\decimals = 0
         LvFieldtyp()\column(j)\datemask = ""
      Next
      
   EndProcedure
   
   Procedure.i ListIconSortAddColumn(pbnr, col, typ = 0, lg = 0, DEC = 0, mask$ = "")
      
      ;schreibt die Sortier-Eigenschaften einer Spalte ins ColumnArray
      
      ;Hinweis: ist die Länge zu klein, 
      ; wird scheinbar falsch sortiert, fällt besonders bei Zahlen auf
      
      ForEach LvFieldtyp()
         If LvFieldtyp()\pbnr = pbnr                        
            If col <= ArraySize(LvFieldtyp()\column())
               If typ: LvFieldtyp()\column(col)\typ = typ: EndIf   
               If lg:  LvFieldtyp()\column(col)\charanz = lg: EndIf   
               If DEC: LvFieldtyp()\column(col)\decimals = DEC: EndIf
               If mask$: LvFieldtyp()\column(col)\datemask = mask$: EndIf
            EndIf
         EndIf   
      Next
      
   EndProcedure   
         
   Procedure.i ListIconSortSetCol(pbnr, col)
      
      ;Holt aus der FieldTypListe die Eigenschaften einer Spalte
      ; und vergrößert 'lisi' um 1 und schreibt diese in 'lisi'
      ; Hinweis nach dem Sortieren wird 'lisi' gelöscht
      
      Protected j, *typ.ListIconSortInfo
      
      ForEach LvFieldtyp()
         If LvFieldtyp()\pbnr = pbnr
            If col <= ArraySize(LvFieldtyp()\column())
               *typ = LvFieldtyp()
            EndIf
         EndIf   
      Next
      
      j = ArraySize(lisi\column()) + 1
      ReDim lisi\column(j)
      
      If *typ
         With lisi         
            \sort = *typ\sort
            \column(j)\nr = col
            \column(j)\typ = *typ\column(col)\typ
            \column(j)\charanz = *typ\column(col)\charanz
            \column(j)\decimals = *typ\column(col)\decimals
            \column(j)\datemask = *typ\column(col)\datemask
         EndWith
      EndIf
      
   EndProcedure
   
   Procedure.i ListIconSortCallbackHeader(hwnd, msg, wParam, lParam) 
      ;hwnd ist die ID vom Header
      
      ;Sub-Callback eines ListiconGadget für Headerclick
      
      Protected oldpt = GetProp_(hwnd, "LvSort")
      Protected *hdn.HD_NOTIFY
      
      Select msg
            
         Case #WM_DESTROY
            RemoveProp_(hwnd, "LvSort")
            SetWindowLongPtr_(hwnd, #GWLP_WNDPROC, oldpt)
            
         Case #WM_NOTIFY 
            *hdn.HD_NOTIFY = lparam
            Select *hdn\hdr\code
               Case #HDN_ITEMCLICKW, #HDN_ITEMCLICK
                  With lisi
                     \pbnr = GetDlgCtrlID_(hwnd)
                     ListIconSortSetCol(\pbnr, *hdn\iItem)
                     ListIconSortSetCol(\pbnr, *hdn\iItem + 1)
                     ListIconSortSetCol(\pbnr, *hdn\iItem + 2)
                     ListIconSortListe (\pbnr,sort.i)
                  EndWith
                  
            EndSelect
            
      EndSelect
      
      ProcedureReturn CallWindowProc_(oldpt, hwnd, msg, wParam, lParam)
      
   EndProcedure
   
   Procedure.i ListIconSortAddClick(pbnr) 
      
      ;Richtet Subclassing für ListiconGadget ein für Headerclick
      
      Protected oldpt = GetWindowLongPtr_(GadgetID(pbnr), #GWL_WNDPROC)   
      
      SetProp_(GadgetID(pbnr), "LvSort", oldpt)                      
      SetWindowLongPtr_(GadgetID(pbnr), #GWL_WNDPROC, @ListIconSortCallbackHeader())
      
   EndProcedure
   
   Procedure.i ListIconSortCallBackIntern(lParam1, lParam2, lParamSort)
      ; dies ist die Vergleichsfunktion von #LVM_SORTITEMSEX
      
      ; lParam1 und lParam2 sind die Itemnummern welche verglichen werden
      ; der Rückgabewert des Vergleichs ist -1, +1 oder 0 für gleich
      
      ; lParamSort ist der Pointer der bei Aufruf von #LVM_SORTITEMSEX übergeben wurde
      
      Static substrg1.s    ;Static beschleunigt das Vergleichen minimal
      Static substrg2.s 
      Static sortitem1.s 
      Static sortitem2.s 
      Static result 
      
      Static umlaute1$ = "ÄÖÜäöüßàâéèêùû"
      Static umlaute2$ = "AeOeUeaeoeuessayazexeyezuyuz"
      Static umlautelg, um1$, um2$


      Protected *lisi.ListIconSortInfo = lParamSort
      Protected j, anzahl
      
      With *lisi
         
         anzahl = ArraySize(\column())    
         
         sortitem1 = ""
         sortitem2 = ""
         
         For j = 1 To anzahl
            
            If \column(j)\charanz 
               
               substrg1 = GetGadgetItemText(\pbnr, lParam1, \column(j)\nr)
               substrg2 = GetGadgetItemText(\pbnr, lParam2, \column(j)\nr)
               
               Select \column(j)\typ
                     
                  Case #ListIcon_Typ_Number
                     substrg1 = Str(Val(substrg1))
                     substrg2 = Str(Val(substrg2))
                     sortitem1 + RSet(substrg1, \column(j)\charanz)
                     sortitem2 + RSet(substrg2, \column(j)\charanz)
                     
                  Case #ListIcon_Typ_Float
                     ReplaceString(substrg1, ",", ".", #PB_String_InPlace)
                     ReplaceString(substrg2, ",", ".", #PB_String_InPlace)                     
                     substrg1 = StrF(ValF(substrg1), \column(j)\decimals)
                     substrg2 = StrF(ValF(substrg2), \column(j)\decimals)                     
                     sortitem1 + RSet(substrg1, \column(j)\charanz)
                     sortitem2 + RSet(substrg2, \column(j)\charanz)
                     
                  Case #ListIcon_Typ_Char                     
                     sortitem1 + LSet(substrg1, \column(j)\charanz)
                     sortitem2 + LSet(substrg2, \column(j)\charanz)
                     
                     ;Umlaute etc ersetzen
                     umlautelg = Len(umlaute1$)                     
                     For j = 1 To umlautelg
                        um1$ = Mid(umlaute1$, j, 1)
                        If FindString(sortitem1, um1$)   
                           um2$ = Mid(umlaute2$, (j * 2) - 1, 2)
                           sortitem1 = ReplaceString(sortitem1, um1$, um2$)
                        EndIf
                        If FindString(sortitem2, um1$)   
                           um2$ = Mid(umlaute2$, (j * 2) - 1, 2)
                           sortitem2 = ReplaceString(sortitem2, um1$, um2$)
                        EndIf
                     Next
                     
                  Case #ListIcon_Typ_Date
                     substrg1 = Str(ParseDate(\column(j)\datemask, substrg1))
                     substrg2 = Str(ParseDate(\column(j)\datemask, substrg2))                     
                     sortitem1 + RSet(substrg1, \column(j)\charanz)
                     sortitem2 + RSet(substrg2, \column(j)\charanz)
                     
               EndSelect
               
            EndIf
            
         Next
         
         ;Vergleich
         If \direction = #ListIcon_Sort_Up
            result = CompareMemoryString(@sortitem1, @sortitem2, #PB_String_NoCase)
         Else
            result = CompareMemoryString(@sortitem2, @sortitem1, #PB_String_NoCase)
         EndIf
         
      EndWith
      
      ProcedureReturn result
   EndProcedure
   
   Procedure.i ListIconSortSetArrow(pbnr, col, firstsort)
      
      ;Löscht und setzt SortierPfeil im Header und gibt Sortrichtung zurück
      ; wird nur von ListIconSortListe() aufgerufen
      
      Protected header = SendMessage_(GadgetID(pbnr), #LVM_GETHEADER, #Null, #Null) 
      Protected colanz = SendMessage_(header, #HDM_GETITEMCOUNT, 0, 0) - 1
      
      Protected j, flags, direction, hdi.HD_ITEM
      
      ;Pfeile löschen, gewählte Spalte Flag setzen
      hdi\mask = #HDI_FORMAT
      For j = 0 To colanz      
         SendMessage_(header, #HDM_GETITEM, j, hdi)
         flags = hdi\fmt                           ;flags merken      
         hdi\fmt & ~ (#HDF_SORTDOWN | #HDF_SORTUP) ;flags löschen       
         If j = col 
            If flags & #HDF_SORTDOWN               ;wenn Downflag
               hdi\fmt | #HDF_SORTUP               ;Upflag setzen 
               direction = #ListIcon_Sort_Up
            ElseIf flags & #HDF_SORTUP             ;wenn Upflag
               hdi\fmt | #HDF_SORTDOWN             ;Downflag setzen
               direction = #ListIcon_Sort_Down
            Else                                   ;wenn keins von beiden
               If firstsort = #ListIcon_Sort_Down
                  hdi\fmt | #HDF_SORTDOWN             ;Downflag setzen
                  direction = #ListIcon_Sort_Down
               ElseIf firstsort = #ListIcon_Sort_Up
                  hdi\fmt | #HDF_SORTUP               ;Upflag setzen 
                  direction = #ListIcon_Sort_Up                  
               EndIf               
            EndIf            
         EndIf
         SendMessage_(header, #HDM_SETITEM, j, hdi)
      Next   
      
      ProcedureReturn direction
      
   EndProcedure
   
   Procedure.i ListIconSortListe(pbnr, sort=0)
      
      ;ruft SortierCallback auf und löscht 'lisi' nach dem sortieren
      
      If ArraySize(lisi\column()) = 0
         Debug "ListIconSortSetCol() oder ListIconSortAddGadget() fehlt"
         ProcedureReturn
      EndIf
      
      lisi\pbnr = pbnr
      Select sort
              Case 0 
                  lisi\direction = ListIconSortSetArrow(pbnr, lisi\column(1)\nr, lisi\sort)
              Case 1
                  lisi\direction = #ListIcon_Sort_Up
              Case 2
                  lisi\direction = #ListIcon_Sort_Down
      EndSelect            
      
      DisableGadget(pbnr, 1)
      SetCursor_(idc_wait): ShowCursor_(#True)   
      
      SendMessage_(GadgetID(pbnr), #LVM_SORTITEMSEX, lisi, @ListIconSortCallBackIntern())
      
      ReDim lisi\column(0)
      
      DisableGadget(pbnr, 0)
      ; Setze Gadet Activ
      SetActiveGadget(pbnr)      
      ;
      ;
      SetCursor_(original): ShowCursor_(#True)      
      SetGadgetState(pbnr, GetGadgetState(pbnr))
   EndProcedure
   
EndModule


CompilerIf #PB_Compiler_IsMainFile
    
       ; LVSORTEX::ListIconSortAddClick(#Gadget)
    
    OpenWindow(0, 100, 100, 400, 150, "ListIcon Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    ListIconGadget(0, 5, 5, 390, 140, "Name", 100, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
    AddGadgetColumn(0, 1, "Address", 270)
    AddGadgetItem(0, -1, "Harry Rannit" + #LF$ + "12 Parliament Way, Battle Street, By the Bay")
    AddGadgetItem(0, -1, "Ginger Brokeit" + #LF$ + "130 PureBasic Road, BigTown, CodeCity")
    AddGadgetItem(0, -1, "John Baker" + #LF$ + "99 Pure Street, Downtown, New York")
    
    
    LVSORTEX::ListIconSortAddClick (0)   
    LVSORTEX::ListIconSortAddGadget(0)   
    
    
    Repeat
        Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
    ;---------------------------------------------------------------------------------------------------------------------///
 ;ListIconSortAddGadget(#Gadget [, flag])   
#datemask = "%yyyy-%mm-%dd, %hh:%mm:%ss"


OpenWindow(0, 100, 100, 510, 150, "ListIcon Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
ListIconGadget(0, 5, 5, 500, 140, "Name", 90, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
AddGadgetColumn(0, 1, "Address", 225)
AddGadgetColumn(0, 2, "Price", 60)
AddGadgetColumn(0, 3, "Date", 120)
AddGadgetItem(0, -1, "Harry Rannit" + #LF$ + "12 Parliament Way, Battle Street, By the Bay")
AddGadgetItem(0, -1, "Ginger Brokeit" + #LF$ + "130 PureBasic Road, BigTown, CodeCity")
AddGadgetItem(0, -1, "John Baker" + #LF$ + "99 Pure Street, Downtown, New York")
AddGadgetItem(0, -1, "Mike Miller" + #LF$ + "4700 Downstreet, Harlem, New York")


For j = 0 To 3
   SetGadgetItemText(0, j, Str(Random(999)) + "," + Str(Random(99)), 2)
   SetGadgetItemText(0, j, FormatDate(#datemask, Random(Date(), 0)), 3)
Next


LVSORTEX::ListIconSortAddClick (0)   
LVSORTEX::ListIconSortAddGadget(0)   
LVSORTEX::ListIconSortAddColumn(0, 0, LVSORTEX::#ListIcon_Typ_Char, 6)
LVSORTEX::ListIconSortAddColumn(0, 1, LVSORTEX::#ListIcon_Typ_Number, 10)
LVSORTEX::ListIconSortAddColumn(0, 2, LVSORTEX::#ListIcon_Typ_Float, 10, 2)
LVSORTEX::ListIconSortAddColumn(0, 3, LVSORTEX::#ListIcon_Typ_Date, 15, 0, #datemask)


Repeat
   Event = WaitWindowEvent()
Until Event = #PB_Event_CloseWindow
   
 
CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 310
; FirstLine = 255
; Folding = 80-
; EnableAsm
; EnableUnicode
; EnableXP