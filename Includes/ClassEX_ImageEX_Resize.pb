DeclareModule ImageEX
  
  Declare.l ResizeExtendThread(PictureID.l, TargetWidth.i = 320, TargetHeight.i = 240, BackColor.l = $000000, Center.i = #True, Alpha.i = #False, AlphaLevel.i = 255, Smooth.i = #True)
  Declare.l ResizeExtend      (PictureID.l, TargetWidth.i = 320, TargetHeight.i = 240, BackColor.l = $000000, Center.i = #True, Alpha.i = #False, AlphaLevel.i = 255, Smooth.i = #True)
  
  ; ================================================================
  ;  ImageResizeEx (Canvas / Gadget Vorschau)
  ; ================================================================  
  Declare.l ResizeExtendGadget(PictureID.l, TargetWidth.i = 50, TargetHeight.i = 50, BackColor.l = $3D3D3D, Center.i = #True, Smooth.i = #True)
  
EndDeclareModule

Module ImageEX
  Structure ImageResizeInfo
    ImageID.l
    TargetW.l
    TargetH.l
    BackColor.l
    Center.i          ; #True = zentrieren
    Alpha.i           ; #True = DrawAlphaImage
    AlphaLevel.i
    Smooth.i          ; #True = #PB_Image_Smooth
  EndStructure
  
	Enumeration 9000 Step 1
	  #TmpResize  ;
	  #TmpCanvas
	EndEnumeration 
	
	Macro Min(a, b)
	  Bool((a) < (b)) * (a) + Bool((a) >= (b)) * (b)
	EndMacro
	
; ================================================================
;  Hochwertiges Resize mit Aspect Ratio + Optionalem Hintergrund
; ================================================================
Procedure.l ResizeExtend(PictureID.l, TargetWidth.i = 320, TargetHeight.i = 240, BackColor.l = $000000, Center.i = #True, Alpha.i = #False, AlphaLevel.i = 255, Smooth.i = #True)
    
    If Not IsImage(PictureID)
        ProcedureReturn 0
    EndIf
    
    Protected OriW = ImageWidth(PictureID)
    Protected OriH = ImageHeight(PictureID)
    
    If OriW = 0 Or OriH = 0
        ProcedureReturn PictureID
    EndIf
    
    Protected.f ScaleX = TargetWidth  / OriW
    Protected.f ScaleY = TargetHeight / OriH
    Protected.f Scale  = Min(ScaleX, ScaleY)   ; Wichtigster Trick für Aspect Ratio
    
    Protected NewW = Round(OriW * Scale, #PB_Round_Nearest)
    Protected NewH = Round(OriH * Scale, #PB_Round_Nearest)
    
    ; Resize mit gewünschter Qualität
    ResizeImage(PictureID, NewW, NewH, Bool(Smooth) * #PB_Image_Smooth)
    
    ; === Hintergrund + Zentrieren ===
    If NewW < TargetWidth Or NewH < TargetHeight Or Alpha
        
        Protected Canvas = CreateImage(#PB_Any, TargetWidth, TargetHeight, 32, BackColor)
        If Canvas
            
            StartDrawing(ImageOutput(Canvas))
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                
                Protected x = 0, y = 0
                If Center
                    x = (TargetWidth  - NewW) / 2
                    y = (TargetHeight - NewH) / 2
                EndIf
                
                If Alpha
                    DrawAlphaImage(ImageID(PictureID), x, y, AlphaLevel)
                Else
                    DrawImage(ImageID(PictureID), x, y)
                EndIf
            StopDrawing()           
            
            ; Original ImageID überschreiben
	          If PictureID > 100000
	            Define NewPictureId.l = CopyImage(Canvas,#PB_Any)
	            If IsImage(NewPictureId)
	              FreeImage( PictureID )
	              PictureID = NewPictureId	          
	            EndIf	              
	          Else
	            CopyImage(Canvas, PictureID)
	          EndIf
            FreeImage(Canvas)
        EndIf
    EndIf
    
    ProcedureReturn PictureID
EndProcedure

  ;
  ;
  Procedure Thread_ImageResize(*Info.ImageResizeInfo)
    
    Define PictureID.l = ResizeExtend(*Info\ImageID,
                  *Info\TargetW,
                  *Info\TargetH, 
                  *Info\BackColor,
                  *Info\Center,
                  *Info\Alpha, 
                  *Info\AlphaLevel,
                  *Info\Smooth)
    
    *Info\ImageID = PictureID.l
    ;FreeStructure(*Info)
  EndProcedure
  
  Procedure.l ResizeExtendThread(PictureID.l, TargetWidth.i = 320, TargetHeight.i = 240, BackColor.l = $000000, Center.i = #True, Alpha.i = #False, AlphaLevel.i = 255, Smooth.i = #True)
    Protected *Info.ImageResizeInfo = AllocateStructure(ImageResizeInfo)
    If *Info
      *Info\ImageID    = PictureID
      *Info\TargetW    = TargetWidth
      *Info\TargetH    = TargetHeight
      *Info\BackColor  = BackColor
      *Info\Center     = Center
      *Info\Alpha      = Alpha
      *Info\AlphaLevel = AlphaLevel
      *Info\Smooth     = Smooth
      
      Protected Thread = CreateThread(@Thread_ImageResize(), *Info)
      If Thread
        WaitThread(Thread)
      EndIf
      
      Delay(25)
      
      PictureID = *Info\ImageID
      
      Delay(25)
      FreeStructure(*Info)
      ProcedureReturn PictureID
    EndIf
  EndProcedure
  
  ; ================================================================
  ;  ImageResizeEx für Installer (Canvas / Gadget Vorschau)
  ; ================================================================
  Procedure.l ResizeExtendGadget(PictureID.l, TargetWidth.i = 50, TargetHeight.i = 50, BackColor.l = $3D3D3D, Center.i = #True, Smooth.i = #True)
    
    If Not IsImage(PictureID)
      ProcedureReturn 0
    EndIf
    
    Protected OriW.l = ImageWidth(PictureID)
    Protected OriH.l = ImageHeight(PictureID)
    
    If OriW = 0 Or OriH = 0
      ProcedureReturn PictureID
    EndIf
    
    ; === Aspect Ratio korrekt berechnen ===
    Protected.f Scale = Min(TargetWidth / OriW, TargetHeight / OriH)
    
    Protected NewW.l = Round(OriW * Scale, #PB_Round_Nearest)
    Protected NewH.l = Round(OriH * Scale, #PB_Round_Nearest)
    
    ; Bild skalieren
    ResizeImage(PictureID, NewW, NewH, Bool(Smooth) * #PB_Image_Smooth)
    
    ; Neues Canvas-Bild mit Hintergrund erstellen
    Protected Canvas = CreateImage(#PB_Any, TargetWidth, TargetHeight, 32, BackColor)
    If Canvas = 0
      ProcedureReturn PictureID
    EndIf
    
    StartDrawing(ImageOutput(Canvas))
    DrawingMode(#PB_2DDrawing_AlphaBlend)
    
    Protected x = 0, y = 0
    If Center
      x = (TargetWidth - NewW) / 2
      y = (TargetHeight - NewH) / 2
    EndIf
    
    DrawImage(ImageID(PictureID), x, y)
    StopDrawing()
    
    ; Original ImageID überschreiben
    If PictureID > 100000
      Define NewPictureId.l = CopyImage(Canvas,#PB_Any)
      If IsImage(NewPictureId)
        FreeImage( PictureID )
        PictureID = NewPictureId	          
      EndIf	              
    Else
      CopyImage(Canvas, PictureID)
    EndIf
    FreeImage(Canvas)    
    
    ProcedureReturn PictureID
  EndProcedure
  
  Procedure Thread_ResizeExtendGadget(*Info.ImageResizeInfo)
    
    ResizeExtendGadget(*Info\ImageID, *Info\TargetW, *Info\TargetH, *Info\BackColor, *Info\Center, *Info\Smooth)
    
    FreeStructure(*Info)
  EndProcedure
  
  Procedure ResizeExtendGadget_Thread(ImageID.l, w.l, h.l, BackColor=$3D3D3D, Center=#True, Smooth=#True)
    Protected *Info.ImageResizeInfo = AllocateStructure(ImageResizeInfo)
    
    If *Info
      *Info\ImageID   = ImageID
      *Info\TargetW   = w
      *Info\TargetH   = h
      *Info\BackColor = BackColor
      *Info\Center    = Center
      *Info\Smooth    = Smooth
      CreateThread(@Thread_ResizeExtendGadget(), *Info)
    EndIf
    
  EndProcedure   
EndModule

; Beispiel
;   ; Beispiel: Thumbnail für Plugin-Bild
;  If LoadImage(#Image_Preview, "fomod\images\SomeScreenshot.jpg")
;    ImageResizeForGadget(#Image_Preview, 280, 160, $3D3D3D, #True, #True)
    
    ; Jetzt ins ImageGadget setzen
;    SetGadgetState(#Gadget_ImagePreview, ImageID(#Image_Preview))
;  EndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 159
; FirstLine = 165
; Folding = --
; EnableAsm
; EnableXP