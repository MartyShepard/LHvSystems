DeclareModule vThumbSys
    
    Declare     MainThread(z)
    Declare     MainThread_2(z)
    Declare     MainThread_3(z)
    Declare     MainThread_4(z)
    
    Declare.l   GetBig_FromDB(nSlotNum.i)
    Declare.l   GetSml_FromDB(nSlotNum.i)
    
    Declare.i   Get_ThumbnailSize(nSizeOption.i)
    
EndDeclareModule

Module vThumbSys
    
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
    
    Global NewList Queue()
    
    Global ResizeMutex = 0
    ;*******************************************************************************************************************************************************************
    ;     
    Procedure   Clr_MemoryImg(*MemoryID, nSlot.i) 
        
        If (*MemoryID > 0)
            If IsImage( *MemoryID )
                FreeImage( *MemoryID)
                Debug "Thumbnail " + Str( nSlot ) + " Image Cleared"
            Else    
                If MemorySize(*MemoryID) > 0
                
                FreeMemory( *MemoryID )
                Debug "Thumbnail " + Str( nSlot ) + " Memory Cleared"
                EndIf
            EndIf         
            
        EndIf   
        
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;    
    Procedure   Thread_Resize(*ImagesResize.STRUCT_REZIMAGES)
        Define.l OriW, OriH, w, h, oriAR, newAR, ImageBlank.l
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
        
        ResizeImage(*ImagesResize\ImageID,w,h,#PB_Image_Smooth ) ;#PB_Image_Raw
        
        Select *ImagesResize\BoxStyle
            Case 1
                w = 0
                h = 0
                
                Select *ImagesResize\Alpha 
                        Case #False: ImageBlank = CreateImage(#PB_Any,*ImagesResize\Width,*ImagesResize\Height) 
                        Case #True : ImageBlank = CreateImage(#PB_Any,*ImagesResize\Width,*ImagesResize\Height,24,*ImagesResize\ColorBlack.l)   
                EndSelect                 
                
                If ( ImageBlank > 1 )
                    If StartDrawing( ImageOutput( ImageBlank ) )
                        
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
                            Case #True :DrawAlphaImage(ImageID(*ImagesResize\ImageID), w, h,*ImagesResize\Level) 
                                
                        EndSelect            
                        StopDrawing()
                        GrabImage(ImageBlank,*ImagesResize\ImageID, 0, 0, *ImagesResize\Width, *ImagesResize\Height) 
                    EndIf
                EndIf
        EndSelect        
               
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   ImageResizeEx_Thread(ImageID.l, w, h, BoxStyle = 0, Color = $000000, Center = #False, Alpha = #False, Level = 255)
        
;         If IsThread(Startup::*LHGameDB\Images_Thread[2])
;             
;             KillThread(Startup::*LHGameDB\Images_Thread[2] )
;         EndIf 
        ResizeMutex = CreateMutex()
        LockMutex( ResizeMutex )
        
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
            
             Startup::*LHGameDB\Images_Thread[4] = CreateThread(@Thread_Resize(),*ImagesResize)
             If IsThread(Startup::*LHGameDB\Images_Thread[4])
                 WaitThread(Startup::*LHGameDB\Images_Thread[4],2000)
             EndIf 
             ;           Thread_Resize(*ImagesResize)
             UnlockMutex( ResizeMutex )
        EndIf
    EndProcedure      
    ;*******************************************************************************************************************************************************************
    ;    
    Procedure   Resize_Gadget(n.i,StructImagePB.i, ImageGadgetID.i, Resize.i = #True)
        Protected PbGadget_w, PbGadget_h, OldIMG_w, OldIMG_h
        
        If IsImage(StructImagePB)
            
            ;
            ; Höhe und Breite des Screenshots Slots Bekommen
            PbGadget_w = Startup::*LHGameDB\wScreenShotGadget; GadgetWidth(ImageGadgetID)
            PbGadget_h = Startup::*LHGameDB\hScreenShotGadget; GadgetHeight(ImageGadgetID) 
            
            ;
            ; Die Alte Höhe und Breite sichern
            OldIMG_w = ImageWidth(StructImagePB)
            OldIMG_h = ImageHeight(StructImagePB)
            
            ;
            ; Den alten Inhalt vorher Löschen
            If IsImage(Startup::*LHImages\CpScreenPB[n])
                FreeImage(        Startup::*LHImages\CpScreenPB[n] )
                
                If ( Startup::*LHImages\CpScreenID[n] <> 0 )
                    Startup::*LHImages\CpScreenID[n] = 0
                EndIf
            EndIf                
            ;
            ; Erstelle eine Kopie und lege diesen handle in die Strukture, Mit Originaler Höhe und Breite              
            CopyImage(StructImagePB, Startup::*LHImages\CpScreenPB[n])
            ;If IsImage( Startup::*LHImages\CpScreenPB[n] )  
                Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])
            ;EndIf    
            
            ;
            ; Das Bild im Aspekt Ration Verhältnis an die Gadgets Anpassen
            If ( Resize = #True )   
                ImageResizeEx_Thread(Startup::*LHImages\CpScreenPB[n],PbGadget_w,PbGadget_h, 1, GetGadgetColor(DC::#Contain_10,#PB_Gadget_BackColor) ,#True, #True, 255) 
            EndIf               
            ;
            ; Das Neue Bild in die Structure Koieren
            ;If IsImage( Startup::*LHImages\CpScreenPB[n] )                
                Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])
            ;EndIf    
        Else
            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Kein Bild in der Purebasic"+Str(StructImagePB) )
        EndIf
    EndProcedure  
    ;*******************************************************************************************************************************************************************
    ;
    Procedure   Thumbnail_SetGadgetState(ThumbnailNum.i)
        
        Delay(2)
            SetGadgetState(Startup::*LHImages\ScreenGDID[ThumbnailNum], -1)                
            SetGadgetState(Startup::*LHImages\ScreenGDID[ThumbnailNum], Startup::*LHImages\CpScreenID[ThumbnailNum])  
            
     EndProcedure
    ;*******************************************************************************************************************************************************************
    ;
     Procedure  Thumbnail_UseDefaultImage(ThumbnailNum.i)
         
         Delay(2)
         Resize_Gadget(ThumbnailNum, Startup::*LHImages\NoScreenPB[ThumbnailNum], Startup::*LHImages\ScreenGDID[ThumbnailNum] )  
         
     EndProcedure
    ;*******************************************************************************************************************************************************************
    ;
     Procedure  DebugInfo( InfoNum.i, sztext.s = "")
         
         Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " (Line " + Str(#PB_Compiler_Line) + " ) " + #TAB$ + "ERROR - CatchImage on Slot " + sztext)
         
     EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail1(Thumbnail = 1)
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail2(Thumbnail = 2)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail3(Thumbnail = 3)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail4(Thumbnail = 4)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail5(Thumbnail = 5)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail6(Thumbnail = 6)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail7(Thumbnail = 7)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail8(Thumbnail = 8)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail9(Thumbnail = 9)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail10(Thumbnail = 10)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail11(Thumbnail = 11)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail12(Thumbnail = 12)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail13(Thumbnail = 13)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail14(Thumbnail = 14)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail15(Thumbnail = 15)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail16(Thumbnail = 16)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail17(Thumbnail = 17)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail18(Thumbnail = 18)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail19(Thumbnail = 19)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail20(Thumbnail = 20)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail21(Thumbnail = 21)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail22(Thumbnail = 22)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail23(Thumbnail = 23)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail24(Thumbnail = 24)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail25(Thumbnail = 25)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail26(Thumbnail = 26)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail27(Thumbnail = 27)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail28(Thumbnail = 28)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail29(Thumbnail = 29)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail30(Thumbnail = 30)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure     
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail31(Thumbnail = 31)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail32(Thumbnail = 32)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail33(Thumbnail = 33)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail34(Thumbnail = 34)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail35(Thumbnail = 35)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail36(Thumbnail = 36)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail37(Thumbnail = 37)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail38(Thumbnail = 38)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail39(Thumbnail = 39)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail40(Thumbnail = 40)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail41(Thumbnail = 41)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail42(Thumbnail = 42)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail43(Thumbnail = 43)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail44(Thumbnail = 44)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail45(Thumbnail = 45)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure 
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail46(Thumbnail = 46)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail47(Thumbnail = 47)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail48(Thumbnail = 48)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail49(Thumbnail = 49)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   Calc_Thumbnail50(Thumbnail = 50)             
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        If ( Startup::SlotShots(Thumbnail)\thumb[RowID] > 1)
            
            If ( CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] )))
                
                Clr_MemoryImg(ImageData, Thumbnail)
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
                
            Else
                DebugInfo( InfoNum.i)
            EndIf 
            
        Else
            Thumbnail_UseDefaultImage(Thumbnail)
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
    EndProcedure     
    ;*******************************************************************************************************************************************************************
    ;          
    Procedure   Set_Slot( nSlotNum.i )
        
            Debug "Lege die Screenshots IN die Slots: " + Str(nSlotNum)

            Select nSlotNum
                Case 1 : Calc_Thumbnail1()
                Case 2 : Calc_Thumbnail2() 
                Case 3 : Calc_Thumbnail3() 
                Case 4 : Calc_Thumbnail4()
                Case 5 : Calc_Thumbnail5()
                Case 6 : Calc_Thumbnail6()
                Case 7 : Calc_Thumbnail7()
                Case 8 : Calc_Thumbnail8()
                Case 9 : Calc_Thumbnail9()
                Case 10: Calc_Thumbnail10()  
                    
                Case 11 : Calc_Thumbnail11()
                Case 12 : Calc_Thumbnail12() 
                Case 13 : Calc_Thumbnail13() 
                Case 14 : Calc_Thumbnail14()
                Case 15 : Calc_Thumbnail15()
                Case 16 : Calc_Thumbnail16()
                Case 17 : Calc_Thumbnail17()
                Case 18 : Calc_Thumbnail18()
                Case 19 : Calc_Thumbnail19()
                Case 20 : Calc_Thumbnail20()                     
                    
                Case 21 : Calc_Thumbnail21()
                Case 22 : Calc_Thumbnail22() 
                Case 23 : Calc_Thumbnail23() 
                Case 24 : Calc_Thumbnail24()
                Case 25 : Calc_Thumbnail25()
                Case 26 : Calc_Thumbnail26()
                Case 27 : Calc_Thumbnail27()
                Case 28 : Calc_Thumbnail28()
                Case 29 : Calc_Thumbnail29()
                Case 30 : Calc_Thumbnail30()                     
                    
                Case 31 : Calc_Thumbnail31()
                Case 32 : Calc_Thumbnail32() 
                Case 33 : Calc_Thumbnail33() 
                Case 34 : Calc_Thumbnail34()
                Case 35 : Calc_Thumbnail35()
                Case 36 : Calc_Thumbnail36()
                Case 37 : Calc_Thumbnail37()
                Case 38 : Calc_Thumbnail38()
                Case 39 : Calc_Thumbnail39()
                Case 40 : Calc_Thumbnail40()                     
                    
                Case 41 : Calc_Thumbnail41()
                Case 42 : Calc_Thumbnail42() 
                Case 43 : Calc_Thumbnail43() 
                Case 44 : Calc_Thumbnail44()
                Case 45 : Calc_Thumbnail45()
                Case 46 : Calc_Thumbnail46()
                Case 47 : Calc_Thumbnail47()
                Case 48 : Calc_Thumbnail48()
                Case 49 : Calc_Thumbnail49()
                Case 50 : Calc_Thumbnail50()                     
                    
            EndSelect
    EndProcedure    
    ;*******************************************************************************************************************************************************************
    ;    
    Procedure   MainThread(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure  
    
    Procedure   MainThread_2(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure
    
    Procedure   MainThread_3(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure
    
    Procedure   MainThread_4(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure     
    ;*******************************************************************************************************************************************************************
    ;  
    Procedure.l GetBig_FromDB(nSlotNum.i)
        Protected *Memory
        
        *Memory = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlotNum)+ "_Big",ExecSQL::_IOSQL()\nRowID,"BaseGameID")
                
        ProcedureReturn *Memory
    EndProcedure    
    ;****************************************************************************************************************************************************************
    ;  
    Procedure.l GetSml_FromDB(nSlotNum.i)
        Protected *Memory
        
        *Memory = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlotNum)+ "_thb",ExecSQL::_IOSQL()\nRowID,"BaseGameID") 
        
        ProcedureReturn *Memory
    EndProcedure 
    ;****************************************************************************************************************************************************************
    ;      
    Procedure.i Get_ThumbnailSize(nSizeOption.i)
        
        Protected *Thumbnail.POINT
        
        *Thumbnail = AllocateMemory(SizeOf(POINT))
        Select nSizeOption
            Case 1: *Thumbnail\x  = 649: *Thumbnail\y = 520
            Case 2: *Thumbnail\x  = 313: *Thumbnail\y = 243
            Case 3: *Thumbnail\x  = 205: *Thumbnail\y = 163                         
            Case 4: *Thumbnail\x  = 153: *Thumbnail\y = 119
            Case 5: *Thumbnail\x  = 122: *Thumbnail\y = 99
            Case 6: *Thumbnail\x  = 101: *Thumbnail\y = 81
            Case 7: *Thumbnail\x  = 86:  *Thumbnail\y = 69                         
        EndSelect
        
        ProcedureReturn *Thumbnail
    EndProcedure
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 220
; FirstLine = 117
; Folding = 8DAAAAAAAg--
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; Debugger = IDE
; Warnings = Display
; EnablePurifier