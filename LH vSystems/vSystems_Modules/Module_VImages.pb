DeclareModule vImages 
    
    Declare NoScreens_Prepare() 
    
    Declare Screens_DragDrop_Support()
    
    Declare Screens_Menu_Import(GadgetID.i)
    Declare Screens_Menu_Save_Image(GadgetID.i)
    Declare Screens_Menu_Save_Images_All()
    Declare Screens_Menu_Delete_Single(CurrentGadget.i)
    Declare Screens_Menu_Delete_All()
    Declare Screens_Menu_Copy_Image(GadgetID.i)
    Declare Screens_Menu_Paste_Import(GadgetID.i)
    
    Declare Screens_Import(CurrentGadget.i, FileStream.s = "")
    
    Declare Screens_Show()   
    Declare Screens_ShowWindow(CurrentGadgetID.i, hwnd)
    
    Declare.i Screens_SetThumbnails(OffsetX.i = 4,OffsetY.i = 4)
    Declare Screens_SzeThumbnails_Reset()
    Declare Screens_ChgThumbnails(key.i, save.i = #False, DelayTime.i = 0, WMKeyUP = -1)
    Declare.l Screens_ChgThumbnails_Sub(*ScreenShots,n)
    Declare Screens_Copy_ResizeToGadget(n.i,StructImagePB.i, ImageGadgetID.i, Resize.i = #True)
    
    Declare     Thumbnails_SetReDraw( bReDraw.i = #True )
    
    
    
EndDeclareModule

Module vImages
    

    
    Structure STRUCT_IMAGEPARAM     
        *ScreenShots      
        n.i
    EndStructure   
    
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
    
    Procedure   Thumbnails_SetReDraw( bReDraw.i = #True )
        
        Protected cnt
        
        For cnt = 1 To Startup::*LHGameDB\MaxScreenshots
            ;SendMessage_( Startup::*LHImages\ScreenGDID[n], #WM_SETREDRAW,bReDraw,0)
        Next
        
    EndProcedure
    
    ;**************************************************************************************************
    ;
    ; Resize Image to hold the Aspect Ration, Alternative als Thread
    ;     
    Procedure Thread_Resize(*ImagesResize.STRUCT_REZIMAGES)
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
            
             Startup::*LHGameDB\Images_Thread[1] = CreateThread(@Thread_Resize(),*ImagesResize)
             If IsThread(Startup::*LHGameDB\Images_Thread[1])
                 WaitThread(Startup::*LHGameDB\Images_Thread[1],1100)
             EndIf 
        EndIf
    EndProcedure      
    ;******************************************************************************************************************************************
    ;  Erstellt ein Kopie des Bildes und legt diese in Die Strukture
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Copy_ResizeToGadget(n.i,StructImagePB.i, ImageGadgetID.i, Resize.i = #True)
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
            Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])           
            
            ;
            ; Das Bild im Aspekt Ration Verhältnis an die Gadgets Anpassen
            If ( Resize = #True )   
                ImageResizeEx_Thread(Startup::*LHImages\CpScreenPB[n],PbGadget_w,PbGadget_h, 1, GetGadgetColor(DC::#Contain_10,#PB_Gadget_BackColor) ,#True, #True, 255) 
            EndIf    
            
            ;
            ; Das Neue Bild in die Structure Koieren           
            Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])               
        Else
            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Kein Bild in der Purebasic"+Str(StructImagePB) )
        EndIf
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Hole die Screenshots aus der Datenbank
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_GetDB()          
        Protected RowID.i = Startup::*LHGameDB\GameID        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots            
            Startup::SlotShots(n)\thumb[RowID] = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Thb",RowID,"BaseGameID")     
        Next                 
    EndProcedure   
    
    Procedure Screens_Show_Thread(z)
        
        Protected nSlot.i, RowID.i = Startup::*LHGameDB\GameID, ImageData.l, *MemoryID
        
        *MemoryID = AllocateMemory(4096)
        
        LockMutex( Startup::*LHGameDB\Images_Mutex)        
        For nSlot = 1 To Startup::*LHGameDB\MaxScreenshots
                                   
            Debug ""
            Debug "Lege die Screenshots IN die Slots: " + Str(nSlot)
            
            If IsImage(Startup::*LHImages\NoScreenPB[nSlot])
                
                ; Hier wäre der Gute Zeitpunkt die Images aus der DB zu lesen?                   
                
                *MemoryID = Startup::SlotShots(nSlot)\thumb[RowID]
                Debug "Lege die Screenshots IN die Slots: " + Str(*MemoryID)
                
                If ( *MemoryID > 1 )
                    
                    *MemoryID = ReAllocateMemory( *MemoryID , MemorySize( *MemoryID ), #PB_Memory_NoClear )
                    
                    If ( MemorySize(*MemoryID) > 1 )
                        
                        If ( CatchImage( Startup::*LHImages\OrScreenPB[nSlot], *MemoryID, MemorySize( *MemoryID ) ) )
                            Screens_Copy_ResizeToGadget(nSlot, Startup::*LHImages\OrScreenPB[nSlot], Startup::*LHImages\ScreenGDID[nSlot], #True) 
                        Else
                            Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " (Line " + Str(#PB_Compiler_Line) + " ) " + #TAB$ + "ERROR - CatchImage")
                        EndIf     
                        
                        If (*MemoryID > 1)
                            FreeMemory( *MemoryID )
                        EndIf                       
                        
                    Else
                        Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " (Line " + Str(#PB_Compiler_Line) + " ) " + #TAB$ + "ERROR - No MemoryID")
                    EndIf    
                    
                Else
                    
                    Screens_Copy_ResizeToGadget(nSlot, Startup::*LHImages\NoScreenPB[nSlot], Startup::*LHImages\ScreenGDID[nSlot] )    
                    
                EndIf                   
                SetGadgetState(Startup::*LHImages\ScreenGDID[nSlot], -1)                
                SetGadgetState(Startup::*LHImages\ScreenGDID[nSlot], Startup::*LHImages\CpScreenID[nSlot])                
            EndIf
        Next
        UnlockMutex( Startup::*LHGameDB\Images_Mutex)      
        If (*MemoryID > 1)
            FreeMemory( *MemoryID )            
        EndIf    
        
    EndProcedure                         
    
    Procedure Screens_Show_A_Thread(*interval)         
        ;
        ; Startup::SlotShots(nSlot)\thumb[Startup::*LHGameDB\GameID]        
        ; Vorerst : :SlotShots(nSlot)\thumb Sollte nicht mehr als 50000 Items überschreuiten
        
        For nSlot = 1 To Startup::*LHGameDB\MaxScreenshots                                              
             Startup::SlotShots(nSlot)\thumb[Startup::*LHGameDB\GameID] = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlot)+ "_Thb",Startup::*LHGameDB\GameID,"BaseGameID")                          
            Delay(*Interval)
            Select nSlot
                Case 4,12,20,28,36,44,52            
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[0] = CreateThread( vThumbSys::@MainThread(),nSlot)     
                Case 1,9,17,25,33,41,49
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[1] = CreateThread( vThumbSys::@MainThread_2(),nSlot)                                       
                Case 2,10,18,26,34,42,50
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[2] = CreateThread( vThumbSys::@MainThread_3(),nSlot)                                         
                Case 3,11,19,27,35,43,51
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[3] = CreateThread( vThumbSys::@MainThread_4(),nSlot) 
                Case 8,16,24,32,40,48            
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[5] = CreateThread( vThumbSys::@MainThread_5(),nSlot)
                Case 5,13,21,29,37,45
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[6] = CreateThread( vThumbSys::@MainThread_6(),nSlot)                      
                Case 6,14,22,30,38,46
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[7] = CreateThread( vThumbSys::@MainThread_7(),nSlot)  
                Case 7,15,23,31,39,47
                    Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
                    Startup::*LHGameDB\Images_Thread[8] = CreateThread( vThumbSys::@MainThread_8(),nSlot)                     
            EndSelect         
        Next  
        
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Erster Start/ Lade und Sichere die Scrennshots
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Show()
        
        Protected IntervalThread.i
                   
        IntervalThread = CreateThread(@Screens_Show_A_Thread(), 2)
        If IntervalThread
            WaitThread(IntervalThread)
        EndIf

        Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Routine Finished")
    EndProcedure 
    
    ;******************************************************************************************************************************************
    ;  Erster Start/ Lade und Sichere die Screnshots/NoScreenshots
    ;__________________________________________________________________________________________________________________________________________  
    Procedure NoScreens_Prepare()        
        
        Debug "START: NoScreens_Prepare()" 
        Protected n.i
        
        ; Random Modus
        ; Würfel die 4 NoScreenshots Durcheinander
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            Startup::*LHImages\NoScreenPB[n] = Random(DC::#_PNG_NOSD, DC::#_PNG_NOSA)
            
            Delay(1)
            
            If IsImage(Startup::*LHImages\NoScreenPB[n])                              
                Startup::*LHImages\NoScreenID[n] = ImageID(Startup::*LHImages\NoScreenPB[n])             
            EndIf                      
        Next            
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Konvertiere nach PNG
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.l Screens_Convert(UnknownImage.l)
        Protected *MemoryImage, Image.l
        If ( UnknownImage.l <> 0 )
            ;
            ; Konvertire DAS Bild nach PNG
            *MemoryImage = EncodeImage(UnknownImage, #PB_ImagePlugin_PNG)         
            If ( *MemoryImage <> 0 )                                                    
                ;
                ; Return Memory
                ProcedureReturn *MemoryImage      
            Else
                ProcedureReturn 0
            EndIf
        EndIf   
        ProcedureReturn 0
    EndProcedure
    
    ;******************************************************************************************************************************************
    ;  DDS (Texture)
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.l Screens_DetectImage_DDS(file.s)
        Protected DDSImage.l, *MemoryImage
        
        DDSImage = DDS::Load(#PB_Any, file) 
        If ( DDSImage <> 0 )
            Startup::*LHGameDB\isDDS = #True
            *MemoryImage = Screens_Convert(DDSImage.l)              
        EndIf
        ProcedureReturn *MemoryImage
    EndProcedure       
    ;******************************************************************************************************************************************
    ;  PCX
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.l Screens_DetectImage_PCX(file.s)
        Protected PCXImage.l, *MemoryImage
        
        PCXImage = PCX::Load(#PB_Any, file) 
        If ( PCXImage <> 0 )
            Startup::*LHGameDB\isPCX = #True
            *MemoryImage = Screens_Convert(PCXImage.l)              
        EndIf
        ProcedureReturn *MemoryImage
    EndProcedure         
    ;******************************************************************************************************************************************
    ;  GIF
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.l Screens_DetectImage_GIF(file.s)
        Protected GIFImage.l, *MemoryImage
        GIF::*this.GifObject  = GIF::GifObjectFromFile(file)
        ;
        ; Get The First Image
        GIFImage = GIF::GetBaseImage(GIF::*this.GifObject)
        If ( GIFImage <> 0 )
            Startup::*LHGameDB\isGIF = #True
            *MemoryImage = Screens_Convert(GIFImage.l)                             
        EndIf
        ProcedureReturn *MemoryImage
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Amiga IFF/ILBM
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.l Screens_DetectImage_IFF(file.s)
        Protected IFFImage.l
        IFFImage = IFF::Load(#PB_Any, file)
        If ( IFFImage <> 0 )
            Startup::*LHGameDB\isIFF = #True
            *MemoryImage = Screens_Convert(IFFImage.l)                             
        EndIf
        ProcedureReturn *MemoryImage
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Lade Purebasic Fremdformate
    ;__________________________________________________________________________________________________________________________________________         
    Procedure.l Screens_LoadNonPBImage(ImageFile.s)
        
        Protected Extension$ = UCase(GetExtensionPart(ImageFile.s))
        
        Select  Extension$   
                ;
                ; GIF: Not Supportet by Purebasic
            Case "GIF", "GIFANIM"              
                ProcedureReturn Screens_DetectImage_GIF(ImageFile.s)
                ;
                ; Amiga IFF: Not Supportet by Purebasic                  
            Case "IFF", "ILBM", "LBM"
                ProcedureReturn Screens_DetectImage_IFF(ImageFile.s)                               
                ;
                ; PCX: Not Supportet by Purebasic                
            Case "PCX"    
                ProcedureReturn Screens_DetectImage_PCX(ImageFile.s)  
                ;
                ; DDS: Not Supportet by Purebasic                
            Case "DDS"    
                ProcedureReturn Screens_DetectImage_DDS(ImageFile.s)                  
                
        EndSelect 
        
        ProcedureReturn -1         
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Erster Start/ Lade und Sichere die Screnshots/NoScreenshots
    ;__________________________________________________________________________________________________________________________________________         
    Procedure.i Screens_DetectImage(ImageFile.s)
        
        Protected Extension$ = UCase(GetExtensionPart(ImageFile))
        
        Startup::*LHGameDB\isPCX = #False
        Startup::*LHGameDB\isGIF = #False
        Startup::*LHGameDB\isIFF = #False
        Startup::*LHGameDB\isDDS = #False        
        
        Select  Extension$   
            Case "BMP"                
                ProcedureReturn #PB_ImagePlugin_BMP 
            Case "ICON"
                ProcedureReturn #PB_ImagePlugin_ICON                
            Case "JPG", "JPEG", "JFIF", "JPE"               
                ProcedureReturn #PB_ImagePlugin_JPEG
            Case "JP2", "J2K", "JPF", "JPG2", "JPX", "JPM", "MJ2", "MJP2", "JPC", "J2C"
                ProcedureReturn  #PB_ImagePlugin_JPEG2000
            Case "PNG"
                ProcedureReturn #PB_ImagePlugin_PNG                
            Case "TGA", "BPX", "ICB", "PIX"
                ProcedureReturn #PB_ImagePlugin_TGA                
            Case "TIFF", "TIF"
                ProcedureReturn #PB_ImagePlugin_TIFF
            Case "GIF"
                ProcedureReturn -1
        EndSelect 
        
        ProcedureReturn -1
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Original Bild aus der DB (Volle Grösse holen)
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l Screens_ShowWindow_GetDB(CurrentGadgetID.i, n) 
        
        Protected *MemScreenShot, RowID.i = Startup::*LHGameDB\GameID
        
        Startup::SlotShots(n)\bsize[RowID] = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Big",RowID,"BaseGameID")    
        *MemScreenShot = Startup::SlotShots(n)\bsize[RowID]                    
        
        ProcedureReturn *MemScreenShot
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Bild Überschreiben und ersetzen?
    ;__________________________________________________________________________________________________________________________________________    
    Procedure.i Screens_Overwrite(nThumbnail.i)
        Protected rOverWrite.i
        ;
        ; SicherheistFrage, Screen Shot Überschreiben
        If ( ExecSQL::ImageGet(DC::#Database_002, "GameShot","Shot" +Str( nThumbnail )+ "_Big", Startup::*LHGameDB\GameID, "BaseGameID") >= 1  )                              
            
            rOverWrite = vItemTool::DialogRequest_Def("Image Existiert","Soll das Image Überschrieben werden?")
            If ( rOverWrite = 0 )
                ProcedureReturn 0
            Else
                ProcedureReturn 1
            EndIf    
        EndIf 
        ProcedureReturn 1    
    EndProcedure           
    ;******************************************************************************************************************************************
    ;  Setze Information
    ;__________________________________________________________________________________________________________________________________________
     Procedure.s Screens_SetInfo(szFile.s, nSize.q)
         
         Protected  szInfo.s = ""
         
         szInfo = ""
         szInfo + "Import Image and Convert to PNG: "+ GetFilePart(szFile, #PB_FileSystem_NoExtension ) + " "
         szInfo + "Size: "        + MathBytes::Bytes2String(nSize)         
         
         Debug "Screens_SetInfo: " + szInfo
         SetGadgetText(DC::#Text_004, szInfo )         
         
     EndProcedure
    ;******************************************************************************************************************************************
    ;  Speichere als Thumbnail in die Datenbank
    ;__________________________________________________________________________________________________________________________________________     
     Procedure Screens_Import_Save_Thumbnail(ImgNum.i)
         Protected ImageData.l
         
         ; Bild in den Speicher Kopieren
         ImageData = EncodeImage(Startup::*LHImages\CpScreenPB[ImgNum], #PB_ImagePlugin_PNG)
         
         If ( ImageData > 0 )
             *m = AllocateMemory( ImageData, #PB_Memory_NoClear )
             
             If ( *m )
                 ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(ImgNum) +"_Thb","",Startup::*LHGameDB\GameID,1,ImageData,"BaseGameID")
                 Delay(1)
                 
                 FreeMemory( *m )
             EndIf    
             ImageData  = 0
             ProcedureReturn 
         EndIf           
         MessageRequester("ERROR", "Modul: " + #PB_Compiler_Module + " #LINE: " + Str(#PB_Compiler_Line) + " # Screens_Import_Save_Thumbnail" )
         
     EndProcedure
    ;******************************************************************************************************************************************
    ;  Speichere Fremdformat in die DB
    ;__________________________________________________________________________________________________________________________________________      
     Procedure Screens_Import_Save_NonPBFormat(ImgNum.i, ImageData.l, szFile.s)
         Protected *m, GenImage.l
         
         If (ImageData > 0)
             *m = AllocateMemory( ImageData, #PB_Memory_NoClear )
             
             If ( *m )                 
                 Screens_SetInfo(szFile, FileSize(szFile) )
                 
                 ;ShowMemoryViewer(ImageData, MemorySize( ImageData ) )                 
                 GenImage  = CatchImage(#PB_Any, ImageData, MemorySize( ImageData ) )
                 
                 ;ShowMemoryViewer(GenImage, MemorySize( ImageData ) )
                 ImageData = EncodeImage(GenImage, #PB_ImagePlugin_PNG)
                 
                 If ( ImageData > 0)
                     ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(ImgNum) +"_Big","",Startup::*LHGameDB\GameID,1,ImageData,"BaseGameID"):Delay(1)  
                 EndIf
                                
                 FreeImage ( GenImage ) :FreeMemory( *m) 
             EndIf 
             ProcedureReturn 
          EndIf
         MessageRequester("ERROR", "Modul: " + #PB_Compiler_Module + " #LINE: " + Str(#PB_Compiler_Line) + " # Screens_Import_Save_NonPBFormat" )                
     EndProcedure
    ;******************************************************************************************************************************************
    ;  Speichere Fremdformat als Thumbnail in die Datenbank, Vorher laden/ neueinlesen
    ;__________________________________________________________________________________________________________________________________________      
      Procedure.l Screens_Import_Save_NonPBThumb(ImgNum.i)
          Protected ImageData.l, *m, ConvPngImage.l
          
          ImageData = Screens_ShowWindow_GetDB(Startup::*LHImages\ScreenGDID[ImgNum], ImgNum)
          
          If ( ImageData > 0 )
              
              *m = AllocateMemory( ImageData, #PB_Memory_NoClear )
                    
               If ( *m )
                   
                   ConvPngImage = CatchImage(#PB_Any, ImageData, MemorySize( ImageData ) ) 
                   If ( ConvPngImage > 0 )
                       
                      FreeMemory( *m) 
                      FreeMemory( ImageData) 
                      ProcedureReturn  ConvPngImage 
                  EndIf
                  MessageRequester("ERROR", "Modul: " + #PB_Compiler_Module + " #LINE: " + Str(#PB_Compiler_Line) + " # Screens_Import_Save_ConvPngImage" ) 
              EndIf              
          EndIf 
          MessageRequester("ERROR", "Modul: " + #PB_Compiler_Module + " #LINE: " + Str(#PB_Compiler_Line) + " # Screens_Import_Save_NonPBThumb" )                
          ProcedureReturn 0
     EndProcedure     
    ;******************************************************************************************************************************************
    ;  Drag'n'Drop: Bilder Importieren
    ;__________________________________________________________________________________________________________________________________________
    Procedure Screens_Import(CurrentGadget.i, FileStream.s = "")
        
        Protected GenericImageID.l, *Memory, *MemoryImage, n = 0  
        
        GenericImageID.l = LoadImage(#PB_Any, FileStream, 0)            
        
        ;
        ; Detect Image Format
        If ( Screens_DetectImage(FileStream.s) = -1 )
                        
            *MemoryImage = Screens_LoadNonPBImage(FileStream.s)
            If ( *MemoryImage = 0 )
                ;
                ; TODO Message Requester
                If IsImage( GenericImageID )
                    FreeImage( GenericImageID )
                EndIf 
                
                ProcedureReturn                
            EndIf    
            ;
            ; TDOD: Detect Images
        EndIf    
        
        ; TODO: MessageRequester
                    
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            If ( CurrentGadget = Startup::*LHImages\ScreenGDID[n] )                             
                
                If ( Screens_Overwrite(n) = 0 )
                    ProcedureReturn 
                EndIf    
                
                HideGadget(DC::#Text_004,0)  
                
                Startup::*LHGameDB\bisImageDBChanged = #True 
                
                ;
                ; Speicher die original Grösse in die Datenbank Zelle, Importieren von Fremdformaten die PB nicht kennt
                
                If ( Startup::*LHGameDB\isPCX = #True ) Or
                   ( Startup::*LHGameDB\isGIF = #True ) Or
                   ( Startup::*LHGameDB\isIFF = #True ) Or
                   ( Startup::*LHGameDB\isDDS = #True )   
                    
                    Screens_Import_Save_NonPBFormat(n, *MemoryImage, FileStream)                                         
                                                                                 
                Else                    
                    
                    Screens_SetInfo(FileStream, FileSize(FileStream) )
                    
                    ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(n) +"_Big",FileStream,Startup::*LHGameDB\GameID,0,0,"BaseGameID"):Delay(1)
                EndIf    
                
                ;-----------------------------------------------------------------------------------------------------------------------------------------
                ;
                ; Speicher als Thumbnail Grösse in die Datenbank Zelle                  
                If ( Startup::*LHGameDB\isPCX = #True ) Or
                   ( Startup::*LHGameDB\isGIF = #True ) Or
                   ( Startup::*LHGameDB\isIFF = #True ) Or
                   ( Startup::*LHGameDB\isDDS = #True ) 
                    
                    GenericImageID = Screens_Import_Save_NonPBThumb(n)

                EndIf    
              
                Screens_Copy_ResizeToGadget(n.i,GenericImageID, Startup::*LHImages\ScreenGDID[n]) 
                
                If IsImage( GenericImageID )
                    FreeImage( GenericImageID )
                EndIf 
                
                Screens_Import_Save_Thumbnail(n)
                
                Screens_Show(): SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1): Break
            EndIf            
        Next                   
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Lädt und Importiert die Screenshots über das menu
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Menu_Import(GadgetID.i)
        Protected File$, Extension$
        
        Extension$ = "Alle Dateien (*.*)|*.*|"
        Extension$ + "Amiga Interchange File Format (*.iff)|*.iff|"
        Extension$ + "Amiga InterLeaved BitMap (*.ilbm;*.lbm)|*.ilbm;*.lbm|" 
        Extension$ + "Direct Draw Surface (*.dds)|*.dds|"
        Extension$ + "Graphics Interchange Format (*.gif)|*.gif|" 
        Extension$ + "Joint Photographic Experts Group (*.jpg;*.jpeg;*.jfif;*.jfif)|*.jpg;*.jpeg;*.jfif;*.jfif|"
        Extension$ + "Joint Photographic Experts 2000 (*.jp2;*.j2k;*.jpf;*.jp2;*.jpg2;*.jpx;*.jpm;*.mj2;*.mjp2;*.jpc;*.j2c)|*.jp2;*.j2k;*.jpf;*.jp2;*.jpg2;*.jpx;*.jpm;*.mj2;*.mjp2;*.jpc;*.j2c|"
        Extension$ + "Picture Exchange (*.pcx)|*.pcx|"
        Extension$ + "Portable Network Graphics (*.png)|*.png|"         
        Extension$ + "Tagged Image File Format  (*.tif;*.tiff)|*.tif;*.tiff|"          
        Extension$ + "Targa Image File (*.tga;*.bpx;*.icb;*.pix)|*.tga*.bpx;*.icb;*.pix|"    
        Extension$ + "Windows Bitmap (*.bmp)|*.bmp|"
        Extension$ + "Windows Icon (*.ico)|*.ico;"        
      
        File$ = FFH::GetFilePBRQ("Select Image","", #False, Extension$)
        If ( File$ )
            Screens_Import(GadgetID, File$)
        EndIf         
    EndProcedure                 
    ;******************************************************************************************************************************************
    ;  Holt das Format aus der DB
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.s Screens_Menu_Save_Format(ImageHandle.l)
        Format.l  = ImageFormat(ImageHandle)
        
        Select  Format   
            Case #PB_ImagePlugin_BMP                
                Extension$ = "BMP"
            Case #PB_ImagePlugin_ICON
                Extension$ = "ICON"                
            Case #PB_ImagePlugin_JPEG                
                Extension$ = "JPG"
                JpgQuality = 10
            Case #PB_ImagePlugin_JPEG2000
                Extension$ = "JPG2"                   
            Case #PB_ImagePlugin_PNG
                Extension$ = "PNG"                
            Case #PB_ImagePlugin_TGA
                Extension$ = "TGA"                
            Case #PB_ImagePlugin_TIFF
                Extension$ = "TIFF"            
            Default   
                Extension$ = ""
        EndSelect
        ProcedureReturn Extension$
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Holt das Originale Bild aus der DB
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l Screens_Menu_Get_Original(n)        
        *MemoryImage = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Big",Startup::*LHGameDB\GameID,"BaseGameID")  
        If ( *MemoryImage <> 0 )
            Unknown.l = CatchImage(#PB_Any, *MemoryImage ,MemorySize(*MemoryImage))
            ;Unknown.l = CatchImage(#PB_Any, *MemoryImage ,MemorySize(*MemoryImage) -1)            
            ProcedureReturn Unknown
           
        EndIf
        ProcedureReturn 0
    EndProcedure  
    ;******************************************************************************************************************************************
    ;  Setzte Jpg Qualität
    ;__________________________________________________________________________________________________________________________________________
    Procedure.i Screens_Menu_Set_JpgQuality(Extension$)
          ;
          ; Setze die JPEG Qualität             
          If ( Extension$ = "JPG" )
               ProcedureReturn 10
          EndIf        
        ProcedureReturn 0
    EndProcedure  
    ;******************************************************************************************************************************************
    ;  Speichert das Bild auf den Datenträger
    ;__________________________________________________________________________________________________________________________________________    
    Procedure Screens_Menu_Save_ImageFormat(File$,ImageData.l,Extension$)
        
        Protected Result              
        
        SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,0): 
        SetGadgetText(DC::#Text_004, "Speichere: "+ GetFilePart(File$) )                    
        
        Result = SaveImage(ImageData, File$, ImageFormat(ImageData) , Screens_Menu_Set_JpgQuality(Extension$), ImageDepth(ImageData, #PB_Image_OriginalDepth))  
        Delay(250)
        ;
        ; Fehler beim Spichern des Bildes
        If ( Result = 0 )
            Error = vItemTool::DialogRequest_Def("Fehler","Fehler Beim Speichern des Bildes " + Chr(34) + File$)
        EndIf   
                            
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Generiere Datei Namen
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.s Screens_Menu_Set_Filename(Path$, Extension$, n)
        Protected File$
        File$ = Path$ + vItemTool::Item_GetTitleName(#True)
        
        File$ + " [" + Str(n) + "]."
        File$ +    LCase(Extension$)
        
        ProcedureReturn File$
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Import image über der Ablage
    ;__________________________________________________________________________________________________________________________________________       
    Procedure Screens_Menu_Paste_Import(GadgetID.i)
        
        Protected Extension$, GenImage.l, *ImageData
        
        ClipBoardImage.l = GetClipboardImage(#PB_Any)
        
        If IsImage( ClipBoardImage.l )
            
            GenImage.l  = GrabImage(ClipBoardImage, #PB_Any,0,0, ImageWidth(ClipBoardImage),ImageHeight(ClipBoardImage))
            
            Debug ""
            Debug "Import Clibboard Image"
            Debug "Image Weite  : " + Str(ImageWidth(ClipBoardImage))
            Debug "Image Höhe   : " + Str(ImageHeight(ClipBoardImage))
            Debug "Image Format : " + Str(ImageFormat(ClipBoardImage))            
                  
            For n = 1 To Startup::*LHGameDB\MaxScreenshots
                If ( GadgetID = Startup::*LHImages\ScreenGDID[n] )                             
                    
                    If ( Screens_Overwrite(n) = 0 )
                        ProcedureReturn 
                    EndIf    
                    
                    HideGadget(DC::#Text_004,0)  
                    
                    Startup::*LHGameDB\bisImageDBChanged = #True 

                   *ImageData = EncodeImage(GenImage, #PB_ImagePlugin_PNG)

                    If ( *ImageData > 0)                        
                        ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(n) +"_Big","",Startup::*LHGameDB\GameID,1,*ImageData,"BaseGameID"):Delay(1)  
                    EndIf
                    
                    Screens_Copy_ResizeToGadget(n.i,GenImage.l, Startup::*LHImages\ScreenGDID[n]) 
                    
                    FreeImage ( ClipBoardImage.l )
                    FreeImage ( GenImage.l       )

                    Screens_Import_Save_Thumbnail(n)
                    
                    Screens_Show(): SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1): Break                        
                EndIf                
            Next                 
        EndIf                                       
        ProcedureReturn                        
    EndProcedure          
    ;******************************************************************************************************************************************
    ;  Lädt und Importiert die Screenshots über das menu
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_Menu_Save_Image(CurrentGadget.i)
        
        Protected Unknown.l, Format.l, Extension$,  Result.i
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            If ( CurrentGadget = Startup::*LHImages\ScreenGDID[n] ) 
                Unknown.l  = Screens_Menu_Get_Original(n)
                If ( Unknown <> 0 )
                    Extension$ = Screens_Menu_Save_Format(Unknown.l)
                                        
                    If ( Len(Extension$) >= 1 )                 
                        
                        File$ = FFH::GetFilePBRQ("Speichere "+Extension$+" Bild", Screens_Menu_Set_Filename("", Extension$, n), #True, "." + LCase(Extension$))
                        If ( File$ )
                            Result = vItemTool::DialogRequest_Screens_Menu_Verfiy_File(File$)                        
                            
                            If ( Result = 0 )                        
                                Screens_Menu_Save_ImageFormat(File$,Unknown.l,Extension$)
                            EndIf  
                       EndIf
                    EndIf    
                EndIf
                Break
            EndIf
        Next
        Delay(250)
        SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,1)          
    EndProcedure  
    
    ;******************************************************************************************************************************************
    ;  Lädt und Importiert die Screenshots über das menu
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_Menu_Copy_Image(CurrentGadget.i)
        
        Protected Unknown.l, Format.l, Extension$,  Result.i
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            If ( CurrentGadget = Startup::*LHImages\ScreenGDID[n] )                                               
                SetClipboardImage(Screens_Menu_Get_Original(n))
                Break
            EndIf
        Next
        Delay(250)
        SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,1)          
    EndProcedure      
    
    ;******************************************************************************************************************************************
    ;  Sicher und Eportiert die Screenshots über das menu
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_Menu_Save_Images_All()
        
        Protected Unknown.l, Extension$, Result.i, AskPath.i = #True, Path$, Error.i, DontAsk.i = #False
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            Unknown.l  = Screens_Menu_Get_Original(n)
            If ( Unknown <> 0 )                        
                File$ = ""
                If ( AskPath = #True )
                    Path$ = FFH::GetFilePath("Wo sollen die Bilder gespeichert werden ?", "",#True, #False ,#False, "*",#PB_Default)
                    AskPath = #False
                EndIf    
                
                If ( Path$ )                    
                    ; Hole und erkenne das Format
                    
                    Extension$  = Screens_Menu_Save_Format(Unknown.l)
                    File$       = Screens_Menu_Set_Filename(Path$, Extension$, n) 
                    
                    If ( DontAsk = #False )
                        Result      = vItemTool::DialogRequest_Screens_Menu_Verfiy_Serie( File$ )
                    Else
                        Result = 0
                    EndIf    
                    
                    Select Result
                        Case 0    
                            Screens_Menu_Save_ImageFormat(File$,Unknown.l,Extension$)   
                        Case 1
                        Case 2
                            Break
                        Case 4
                            DontAsk = #True
                    EndSelect                    
                Else     
                    Break;
                EndIf                                      
            EndIf      
        Next
       
        Delay(250)
        SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,1)

    EndProcedure      
    ;******************************************************************************************************************************************
    ;  Löschen des Bildes
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Menu_Delete_Single(CurrentGadget.i)
        Protected ImageData.l
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            If ( CurrentGadget = Startup::*LHImages\ScreenGDID[n] ) 
                ImageData.l  = Screens_Menu_Get_Original(n)
                If ( ImageData <> 0 )
                     Result.i = vItemTool::DialogRequest_Def("Bild Löschen ...","Soll das Bild gelöscht werden ?")                    
                     If (Result = 1) 
                        ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "Shot"+ Str(n) +"_Thb", "",Startup::*LHGameDB\GameID)                     
                        ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "Shot"+ Str(n) +"_big", "",Startup::*LHGameDB\GameID)              
                        Screens_Show()
                     EndIf   
                     Break                        
                EndIf
            EndIf
        Next        
    EndProcedure   
    
    ;******************************************************************************************************************************************
    ;  Löschen des Bildes
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Menu_Delete_All()
        
        Protected ImageData.l, UserAsk.i = #True
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            ImageData.l  = Screens_Menu_Get_Original(n)
            If ( ImageData <> 0 )
                
                If ( UserAsk = #True )
                    Result.i = vItemTool::DialogRequest_Def("Löschen","Wirklich ALLE Bilder Löschen ?")
                    UserAsk = #False
                EndIf
                
                If (Result = 1) And (UserAsk = #False)
                    ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "Shot"+ Str(n) +"_Thb", "",Startup::*LHGameDB\GameID)                     
                    ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "Shot"+ Str(n) +"_big", "",Startup::*LHGameDB\GameID)              
                Else
                    ProcedureReturn                    
                EndIf                  
            EndIf        
        Next     
        vImages::Screens_SzeThumbnails_Reset(): Screens_Show()       
    EndProcedure      
    ;******************************************************************************************************************************************
    ;  Drag'n'Drop Unterstützung bei den Gadgets für die Screenshot's hinzufügen
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_DragDrop_Support()
    For n = 1 To Startup::*LHGameDB\MaxScreenshots
        EnableGadgetDrop(Startup::*LHImages\ScreenGDID[n], #PB_Drop_Files , #PB_Drag_Copy)
    Next  
    EndProcedure        
    ;******************************************************************************************************************************************
    ;  Fenster Grösse  Anpassen
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_ShowWindow_ReszWindow(hwnd, ImageHeight.i, DeskHeight.i, DeskWidth.i)             
        ;
        ; Fenstergrösse Setzen ( + 60 = Leiste Oben und Unten)

        If ( ImageHeight > DeskHeight + 61 )                
            ResizeWindow(hwnd, 0, 0, DeskWidth, DeskHeight) 
        Else
            ResizeWindow(hwnd, 0, 0, DeskWidth, DeskHeight + 60)
                        
            If WindowHeight(hwnd) < ImageHeight + 60
                ResizeWindow(hwnd, 0, 0, DeskWidth, DeskHeight) 
            EndIf    
        EndIf                               
    EndProcedure   
    ;******************************************************************************************************************************************
    ;  Im ScrolGadget die #SM_CXVSCROLL berücksichtigen
    ;__________________________________________________________________________________________________________________________________________     
    Procedure.l Screens_ShowWindow_ReszScrolls(hwnd, ImageWidth.i, ImageHeight.i, DeskWidth.i, DeskHeight.i) 
        
        ;
        ;
        If  (ImageWidth = DeskWidth) And (ImageHeight = DeskHeight)
            ProcedureReturn
            
        ElseIf ( ImageWidth <> DeskWidth) And (ImageHeight <> DeskHeight)
            ProcedureReturn
            
        ElseIf ( ImageWidth <= DeskWidth + GetSystemMetrics_(#SM_CXVSCROLL)  ) And (ImageHeight >= DeskHeight)
            
            ResizeWindow(hwnd, #PB_Ignore, #PB_Ignore, WindowWidth(hwnd)+GetSystemMetrics_(#SM_CXVSCROLL), #PB_Ignore)
            ProcedureReturn
            
        ElseIf ( ImageWidth >= DeskWidth ) And (ImageHeight <= DeskHeight + GetSystemMetrics_(#SM_CXVSCROLL) )              
            ResizeWindow(hwnd, #PB_Ignore, #PB_Ignore, #PB_Ignore, WindowHeight(hwnd)+GetSystemMetrics_(#SM_CXVSCROLL))                     
            ProcedureReturn
        EndIf 
        
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Bild Ins Fenster Packen
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_ShowWindow(CurrentGadgetID.i, hwnd)
        
        Protected hFull, wFull, DskX, DskH, DskW, *MemScreenShot ,ForeignImage.l, ImageData.l
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            
            If ( CurrentGadgetID = Startup::*LHImages\ScreenGDID[n] ) 
                ImageData = Screens_ShowWindow_GetDB(CurrentGadgetID, n)
                Break
            EndIf
        Next 
        
        If ( ImageData = 0 )
            hfull = ImageHeight(Startup::*LHImages\NoScreenPB[n])                   
            wFull = ImageWidth (Startup::*LHImages\NoScreenPB[n])
            CopyImage( Startup::*LHImages\NoScreenPB[n], Startup::*LHImages\OrScreenPB[n])
            
        Else
            
            CatchImage(Startup::*LHImages\OrScreenPB[n], ImageData, MemorySize(ImageData)) 
            
            If IsImage(Startup::*LHImages\OrScreenPB[n])                                                      
                hfull = ImageHeight(Startup::*LHImages\OrScreenPB[n])
                wFull = ImageWidth(Startup::*LHImages\OrScreenPB[n])                
                FreeMemory(ImageData)            
                
            EndIf   
        EndIf                  

        ;
        ;
        DskH = DesktopEX::MonitorInfo_Display_Size(#True)
        DskW = DesktopEX::MonitorInfo_Display_Size(#False,#True)
        
        If ( hfull >= DskH )
            TskH = DesktopEX::Get_TaskbarHeight(hwnd, #True)
            If (TskH <> 0 )
                DskX = hfull - TskH
                DskH = hfull - DskX
            EndIf    
            ;
            ; Höhe der Fenster Rahmen abziehen (Ink. Titlebar)
            DskH - FORM::WindowSizeBorder(hwnd) 
            DskH - FORM::WindowSizeTitleB(hwnd)              
        Else
            DskH = hfull
        EndIf
        
        If ( wFull >= DskW )
            DskX = Abs(wFull - DskW)
            DskW = Abs(wFull - DskX)
            DskW - (FORM::WindowSizeBorder(hwnd)*2)
        Else
            DskW = wFull
        EndIf                   
        
        
        If ( DskW < 64 ): DskW = 64: EndIf
        If ( DskH < 64 ): DskH = 64: EndIf         
        
        ;
        ; Resize Image (Test höhe)
        If ( ImageHeight(Startup::*LHImages\OrScreenPB[n]) > DesktopEX::MonitorInfo_Display_Size(#True) Or 
             ImageWidth(Startup::*LHImages\OrScreenPB[n])  > DesktopEX::MonitorInfo_Display_Size(#False,#True))
            
            
            TskH = DesktopEX::Get_TaskbarHeight(hwnd, #True)
            If ( TskH <> 0 )
                TskH = DesktopEX::MonitorInfo_Display_Size(#True) - TskH
            EndIf
            
            TskH + 30
            FORM::ImageResizeEx(Startup::*LHImages\OrScreenPB[n],DskW,DskH-TskH)
            
            AltH =  ImageHeight(Startup::*LHImages\OrScreenPB[n])
            AltW =  ImageWidth(Startup::*LHImages\OrScreenPB[n])
            ;
            ; 
            Screens_ShowWindow_ReszWindow(hwnd, AltH, AltH, AltW )
            
            ;
            ;
            ResizeGadget(DC::#Contain_11, #PB_Ignore, #PB_Ignore , AltW, AltH )  
            SetGadgetAttribute(DC::#Contain_11,#PB_ScrollArea_InnerWidth,AltW)
            SetGadgetAttribute(DC::#Contain_11,#PB_ScrollArea_InnerHeight,AltH)
            ;
            ;
            Screens_ShowWindow_ReszScrolls(hwnd, AltW, AltH, AltW, AltH) 
            
            ;
            ResizeGadget(DC::#ImageCont11,#PB_Ignore, #PB_Ignore,AltW ,AltH )
            
            ;
            ; Den Container Zentrieren
            WinGuru::Center(hwnd,AltW, AltH+30, hwnd)  
            
        Else  
            ;
            ; 
            Screens_ShowWindow_ReszWindow(hwnd, hfull, DskH, DskW)
            
            ;
            ;
            ResizeGadget(DC::#Contain_11, #PB_Ignore, #PB_Ignore , DskW, DskH )  
            SetGadgetAttribute(DC::#Contain_11,#PB_ScrollArea_InnerWidth,wFull)
            SetGadgetAttribute(DC::#Contain_11,#PB_ScrollArea_InnerHeight,hfull)
            
            
            Screens_ShowWindow_ReszScrolls(hwnd, wFull, hfull, DskW, DskH) 
            
            ;
            ;
            ResizeGadget(DC::#ImageCont11,#PB_Ignore, #PB_Ignore,wFull ,hfull )
            
            ;
            ; Den Container Zentrieren
            WinGuru::Center(hwnd,DskW, DskH, hwnd)            
        EndIf

        
        ;
        ; Mindesgrösse Gestelgen
        WindowBounds(hwnd,60,60,#PB_Ignore,#PB_Ignore)
        ;
        ; Lege eine Kopie jeweils in das Gadget 
        SetGadgetState(DC::#ImageCont11, -1)                
        SetGadgetState(DC::#ImageCont11, ImageID(Startup::*LHImages\OrScreenPB[n]))        
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Setze Thumbnail Grösse. LastImage = Die Letzte ImageGadget Nummer (Anzahl)
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.i Screens_SetThumbnails(OffsetX.i = 4,OffsetY.i = 4)
        
        Protected X.i = 0, Y.i = 0, wScroll = GadgetWidth(DC::#Contain_10)
        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
            ResizeGadget(Startup::*LHImages\ScreenGDID[n], X + OffsetX, Y + OffsetY, #PB_Ignore, #PB_Ignore)
            
            ;
            ; Breche den Loop Vorzeitig abe wenn die Maximale Anzahl erreich wurde sonst entshet ein grosse leerer Platz am Ende der Thumbnails 
            If ( n = Startup::*LHGameDB\MaxScreenshots ): Break: EndIf    
            
            If (X + Startup::*LHGameDB\wScreenShotGadget*2 + OffsetX + GetSystemMetrics_(#SM_CXHTHUMB)) > wScroll
                X = 0
                Y + Startup::*LHGameDB\hScreenShotGadget + OffsetY-1
            Else
                X + Startup::*LHGameDB\wScreenShotGadget + OffsetY-1
            EndIf            
        Next    
        
        SetGadgetAttribute(DC::#Contain_10, #PB_ScrollArea_InnerHeight, Y + Startup::*LHGameDB\hScreenShotGadget)
        SetGadgetAttribute(DC::#Contain_10, #PB_ScrollArea_InnerWidth, wScroll-GetSystemMetrics_(#SM_CXHTHUMB)-4) 
        ProcedureReturn  Y + Startup::*LHGameDB\hScreenShotGadget
    EndProcedure  
    
    ;******************************************************************************************************************************************
    ;  Ändere Live Thumbnail Grösse. (Taste,Gui) * THREAD
    ;__________________________________________________________________________________________________________________________________________   
    Procedure Thread(*params.STRUCT_IMAGEPARAM)
        ; GenericImageID.l = CatchImage(#PB_Any, *ScreenShots, MemorySize(*ScreenShots)-1)
        ;
        ; Speicher die Gadget Grösse in die Datenbank Zelle                
        Screens_Copy_ResizeToGadget(*params\n,CatchImage(#PB_Any, *params\ScreenShots, MemorySize(*params\ScreenShots)), Startup::*LHImages\ScreenGDID[*params\n])
        ;Screens_Copy_ResizeToGadget(*params\n,CatchImage(#PB_Any, *params\ScreenShots, MemorySize(*params\ScreenShots)-1), Startup::*LHImages\ScreenGDID[*params\n])         
        *params\ScreenShots = EncodeImage(Startup::*LHImages\CpScreenPB[*params\n], #PB_ImagePlugin_PNG)
        
        If ( MemorySize(*params\ScreenShots) <> 0 )
            ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(*params\n) +"_Thb","",Startup::*LHGameDB\GameID,1,*params\ScreenShots,"BaseGameID");:Delay(5)
        Else
            Debug "ERROR Memery is 0"
        EndIf               
    EndProcedure
    
   ;******************************************************************************************************************************************
   ;  Ändere Live Thumbnail Grösse. (Taste,Gui)
   ;__________________________________________________________________________________________________________________________________________  
      Procedure.l Screens_ChgThumbnails_Sub(*ScreenShots,n)
                    
          If ( *ScreenShots <> 0 )
                                      
              *params.STRUCT_IMAGEPARAM       = AllocateMemory(SizeOf(STRUCT_IMAGEPARAM))           
              *params\ScreenShots = *ScreenShots
              *params\n = n
              
              Thread = CreateThread(@Thread(), *params.STRUCT_IMAGEPARAM)
              WaitThread(Thread) ; Warte auf das Beenden des Threads           
              ClearStructure(*params, STRUCT_IMAGEPARAM)
              
          EndIf            
      EndProcedure      
    ;******************************************************************************************************************************************
    ;  Ändere Live Thumbnail Grösse. (Taste,Gui)
    ;__________________________________________________________________________________________________________________________________________      
    Procedure Screens_ChgThumbnails(key.i, save.i = #False, DelayTime.i = 0, WMKeyUP = -1)
        
        ;
        ; Bewege nicht den Listbox Cursor
        SetGadgetState( DC::#ListIcon_001, GetGadgetState(DC::#ListIcon_001) ) 
        
        If ( CountGadgetItems(DC::#ListIcon_001) = 0 )
            ;
            ; Null Items in der Liste - mach nichts
            ProcedureReturn
        EndIf
                

        If ( save = #True ) And (WMKeyUP = 257)
            
            SetGadgetText(DC::#Text_004,"Save and Create Thumbnails Preview")
            
            Protected *ScreenShots, MemorySize.q
            
            ;ProcessEX::SetAffinityActiv(GetCurrentProcessId_(),ProcessEX::SetAffinityCPUS(0,1))
            
            ;ExecSQL::TuneDB(DC::#Database_002)               
            
            SetPriorityClass_(GetCurrentProcess_(),#HIGH_PRIORITY_CLASS)
            
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str(Startup::*LHGameDB\wScreenShotGadget),Startup::*LHGameDB\GameID)
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str(Startup::*LHGameDB\hScreenShotGadget),Startup::*LHGameDB\GameID)              
            
            ;vImages::Thumbnails_SetReDraw(#False)
            For n = 1 To Startup::*LHGameDB\MaxScreenshots
                
                *ScreenShots = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Big",Startup::*LHGameDB\GameID,"BaseGameID")
                
                If (  *ScreenShots <> 0 )
                    
                    MemorySize + MemorySize(*ScreenShots)         
                    DatabaseUpdate(DC::#Database_002, "PRAGMA mmap_size="+MemorySize+";") 
                                   
                    SetGadgetText(DC::#Text_004,"Save and Create Thumbnails Preview ("+MathBytes::Bytes2String(MemorySize) +")")
                    
                    Screens_ChgThumbnails_Sub(*ScreenShots,n) 
                    ;                 If ( *ScreenShots <> 0 )
                    ;                     
                    ;                     GenericImageID.l = CatchImage(#PB_Any, *ScreenShots, MemorySize(*ScreenShots)-1)                     
                    ;                     ;
                    ;                     ; Speicher die Gadget Grösse in die Datenbank Zelle                
                    ;                     Screens_Copy_ResizeToGadget(n.i,GenericImageID, Startup::*LHImages\ScreenGDID[n]) 
                    ;                     ; Bild in den Speicher Kopieren
                    ;                     *ScreenShots = EncodeImage(Startup::*LHImages\CpScreenPB[n], #PB_ImagePlugin_PNG)
                    ;                     
                    ;                     If ( MemorySize(*ScreenShots) <> 0 )
                    ;                         ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(n) +"_Thb","",Startup::*LHGameDB\GameID,1,*ScreenShots,"BaseGameID");:Delay(5)
                    ;                     Else
                    ;                         Debug "ERROR Memery is 0"
                    ;                     EndIf                                        
                    ;                 EndIf
                    FreeMemory(*ScreenShots)
                EndIf 
            Next
            Delay(DelayTime)
            Screens_Show()             
            ;vImages::Thumbnails_SetReDraw(#True)
            SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1)
            SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
            ProcedureReturn
            
        ElseIf ( save = #True ) And (WMKeyUP = -999)
            SetGadgetText(DC::#Text_004,"Create Thumbnails Preview")
            Screens_Show()             
            ;vImages::Thumbnails_SetReDraw(#True)
            SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1)
            SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
            ProcedureReturn
        Else     
            

            ; 100 NumKey L w - 1
            ; 102 NumKey R w + 1
            ; 104 NumKey U h + 1
            ;  98 NumKey D h - 1  
            
            Select key
                Case #VK_F5,103
                    Startup::*LHGameDB\wScreenShotGadget + DelayTime
                    Startup::*LHGameDB\hScreenShotGadget + DelayTime  
                    
                Case #VK_F6,105
                    Startup::*LHGameDB\wScreenShotGadget - DelayTime
                    Startup::*LHGameDB\hScreenShotGadget - DelayTime                                
                    
                Case 104: Startup::*LHGameDB\hScreenShotGadget + DelayTime                                                             
                Case 98 : Startup::*LHGameDB\hScreenShotGadget - DelayTime
                    
                Case 102: Startup::*LHGameDB\wScreenShotGadget + DelayTime                  
                Case 100: Startup::*LHGameDB\wScreenShotGadget - DelayTime                  
            EndSelect          
            
            If (Startup::*LHGameDB\wScreenShotGadget <= 33 )
                Startup::*LHGameDB\wScreenShotGadget  = 34
            EndIf
            
            If (Startup::*LHGameDB\hScreenShotGadget <= 33 )
                Startup::*LHGameDB\hScreenShotGadget  = 34
            EndIf        
            
            HideGadget(DC::#Text_004,0)
            SetGadgetText(DC::#Text_004,"Resize Thumnails Size  Width:" + Startup::*LHGameDB\wScreenShotGadget+ " Height:" + Startup::*LHGameDB\hScreenShotGadget)
            vImages::Screens_SetThumbnails()            
            vImages::Screens_Show()
            ;vImages::Thumbnails_SetReDraw(#True)
            SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
        EndIf        
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Ändere Thumbnail Grösse. 
    ;__________________________________________________________________________________________________________________________________________        
    Procedure Screens_SzeThumbnails_Reset()        
        Startup::*LHGameDB\wScreenShotGadget = 202
        Startup::*LHGameDB\hScreenShotGadget = 142        
        Screens_ChgThumbnails(0,#False)      
        Screens_ChgThumbnails(0,#True,0, 257)        
    EndProcedure    
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 338
; FirstLine = 243
; Folding = vcAUAED5
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = B:\MAME
; EnableUnicode