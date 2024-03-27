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
    
    Declare.i Screen_GetThumnbailSlot( ThumbnailGadget.i )
    
    Declare.i Screens_Menu_Check_Clipboard()
    Declare.s Screens_Menu_Info_Image()
    
    Declare Screens_Import(CurrentGadget.i, FileStream.s = "")
    
    Declare Screens_Show()   
    Declare Screens_ShowWindow(CurrentGadgetID.i, Hwnd.i)
    Declare Screens_ShowWindow_Info()
    
    Declare.i Screens_SetThumbnails(OffsetX.i = 4,OffsetY.i = 4)
    Declare Screens_SzeThumbnails_Reset()
    Declare Screens_ChgThumbnails(key.i, save.i = #False, DelayTime.i = 0, WMKeyUP = -1)
    Declare.l Screens_ChgThumbnails_Sub(*ScreenShots,n)
    Declare Screens_Copy_ResizeToGadget(n.i,StructImagePB.i, ImageGadgetID.i, Resize.i = #True)
    
    Declare     Thumbnails_SetReDraw( bReDraw.i = #True )
    
    Declare		Window_ZoomScroll(ZoomDelta.w = 0)    
    Declare.l	Window_GetCurrentRaw( CurrentGadgetID.i )
    Declare.i	Window_GetCurrentPbs( ImageData.l       )
    
    
    
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
        slot.i
    EndStructure   
    
    Procedure   Thumbnails_SetReDraw( GadgetRedraw.i = #True )        
        Protected cnt        
        For cnt = 1 To Startup::*LHGameDB\MaxScreenshots
        	SendMessage_( Startup::*LHImages\ScreenGDID[n], #WM_SETREDRAW, GadgetRedraw, 0)        	
        Next
        
    EndProcedure
    ;
		;
    ;
    Procedure Thread_DoEvents() 
    	Protected msg.MSG    	
    	If PeekMessage_(msg,0,0,0,1) 
    		TranslateMessage_(msg) 
    		DispatchMessage_(msg) 
    	Else
    		Sleep_(1) 
    	EndIf 
  	
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
                        FreeImage(ImageBlank)
                        Startup::*LHImages\CpScreenID[*ImagesResize\Slot] = ImageID(*ImagesResize\ImageID)
                    EndIf
                EndIf
        EndSelect        
               
    EndProcedure         
    
    ;******************************************************************************************************************************************
    ;  Erstellt ein Kopie des Bildes und legt diese in Die Strukture
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Copy_ResizeToGadget(n.i,StructImagePB.i, ImageGadgetID.i, Resize.i = #True)
        
        If IsImage(StructImagePB)           
        	;        		    			
					; Erstelle eine Kopie und lege diesen handle in die Strukture, Mit Originaler Höhe und Breite              
	       	CopyImage( StructImagePB, Startup::*LHImages\CpScreenPB[n] )
	       		
	    		Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])
	    		
	       	If IsImage( StructImagePB )
	       		FreeImage( StructImagePB )
	       	EndIf	    		
	    		
	    		If ( Resize = #True )            	
	    			*Memory.STRUCT_REZIMAGES       = AllocateMemory(SizeOf( STRUCT_REZIMAGES)) 
	    			
	    			*Memory\ImageID    = Startup::*LHImages\CpScreenPB[n]
	    			*Memory\BoxStyle   = 1
	    			*Memory\ColorBlack = GetGadgetColor(DC::#Contain_10,#PB_Gadget_BackColor)
	    			*Memory\Height     = Startup::*LHGameDB\hScreenShotGadget 
	    			*Memory\Width      = Startup::*LHGameDB\wScreenShotGadget      
	    			*Memory\Center     = #True
	    			*Memory\Alpha      = #True
	    			*Memory\Level      = 255    			
	    			*Memory\slot		   = n
	    			;*Memory 					 = Thread_Resize(*Memory)
	    			
		    		Startup::*LHGameDB\Images_Thread[1] = CreateThread(@Thread_Resize(),*Memory)
		    		If IsThread(Startup::*LHGameDB\Images_Thread[1])
		    			WaitThread(Startup::*LHGameDB\Images_Thread[1],ProcessEX::DelayMicroSeconds(100))
		    		EndIf    			
		    			    			
	    		
	    			If IsImage( ImageID(Startup::*LHImages\CpScreenPB[n] ))
	    				FreeImage( ImageID(Startup::*LHImages\CpScreenPB[n] ))
	    			EndIf
	    			
	    			If IsImage( ImageID(*Memory\ImageID))
	    				FreeImage( ImageID(*Memory\ImageID))
	    			EndIf    			
	    			
	    			FreeMemory(*Memory)
	    			
	    		EndIf	
	    		
	    		;Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Kein Bild in der Purebasic"+Str(StructImagePB) )
        EndIf
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Hole die Screenshots aus der Datenbank
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_GetDB()          
        Protected RowID.i = Startup::*LHGameDB\GameID        
        For n = 1 To Startup::*LHGameDB\MaxScreenshots            
        	Startup::SlotShots(n)\thumb[RowID] = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Thb",RowID,"BaseGameID")
        	Thread_DoEvents() 
        Next                 
    EndProcedure   
    ;
		;
    ;
    Procedure Screens_Show_A_Thread(*interval)         
    	    	
    	For nSlot = 1 To Startup::*LHGameDB\MaxScreenshots                                                  		
Debug Startup::*LHGameDB\GameID
    		Startup::SlotShots(nSlot)\thumb[Startup::*LHGameDB\GameID] = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlot)+ "_Thb",Startup::*LHGameDB\GameID,"BaseGameID")        		        		        		
    		ProcessEX::DelayMicroSeconds(*Interval)
    		Select nSlot
    			Case 4,12,20,28,36,44,52     				
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()                	
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread(),nSlot) 
    				 
	
    			Case 1,9,17,25,33,41,49 
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_2(),nSlot)
  				
    			Case 2,10,18,26,34,42,50                 	
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_3(),nSlot)                                         
    				
    			Case 3,11,19,27,35,43,51
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_4(),nSlot) 
    				
    			Case 8,16,24,32,40,48
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_5(),nSlot)
    				
    			Case 5,13,21,29,37,45
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_6(),nSlot)                      
    				
    			Case 6,14,22,30,38,46
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_7(),nSlot)     				
    				
    			Case 7,15,23,31,39,47
    				vThumbSys::ClearImage(nSlot)
    				Startup::*LHGameDB\Images_Mutex[nSlot] = CreateMutex()
    				Startup::*LHGameDB\Images_Thread[nSlot] = CreateThread( vThumbSys::@MainThread_8(),nSlot)                      				
    		EndSelect
    		Thread_DoEvents()				
    	Next  
    	
    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Erster Start/ Lade und Sichere die Scrennshots
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_Show()    	    	          	
    	
    	DisableGadget( DC::#Contain_10, #True)            
    	
    	Protected IntervalThread.i  = CreateThread(@Screens_Show_A_Thread(), 1)
    	
    	While IsThread(IntervalThread)        	
    		WaitThread( IntervalThread, ProcessEX::DelayMicroSeconds(100))
    	Wend
    	
    	DisableGadget( DC::#Contain_10, #False)     
    	
    	Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Routine Finished")
    EndProcedure 
    
    ;******************************************************************************************************************************************
    ;  Erster Start/ Lade und Sichere die Screnshots/NoScreenshots
    ;__________________________________________________________________________________________________________________________________________  
    Procedure NoScreens_Prepare()        
        
        Debug "Start: NoScreens_Prepare()" 
        Protected n.i
        
        ; Random Modus
        ; Würfel die 4 NoScreenshots Durcheinander
        For n = 1 To Startup::*LHGameDB\MaxScreenshots
        	Startup::*LHImages\NoScreenPB[n] = Random(DC::#_PNG_NOSD, DC::#_PNG_NOSA)        	        	
          Startup::*LHImages\NoScreenID[n] = ImageID(Startup::*LHImages\NoScreenPB[n])             
                      
          ;Debug "NoScreen Nr. " + RSet( Str(n),2,"0" ) + " / NoScreenPB: " + RSet( Str(Startup::*LHImages\NoScreenPB[n]),4,"0") + " / NoScreenID: " + Str(Startup::*LHImages\NoScreenID[n])
          
          ProcessEX::DelayMicroSeconds(1)      
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
    ; Übergibt das aktuelle Gadget
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.i Screens_Menu_GetSlot()
    	
    	Protected Unknown.l, Format.l, Extension$,  Result.i
    	
    	For n = 1 To Startup::*LHGameDB\MaxScreenshots
    		
    		If ( Form::IsOverObject( GadgetID( Startup::*LHImages\ScreenGDID[n] )) = 1 )    			
    				Debug "Slot Nummer: " + Str(n)
						ProcedureReturn n
    		EndIf
    		Thread_DoEvents() 
    	Next
    	Debug "Slot Nummer Not found"
    	ProcedureReturn -1         
    EndProcedure
    
    ;******************************************************************************************************************************************
    ; Übergibt das aktuelle Gadget
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.i Screens_Menu_GetGadget()
    	
    	Protected Unknown.l, Format.l, Extension$,  Result.i
    	
    	For n = 1 To Startup::*LHGameDB\MaxScreenshots
    		
    		If ( Form::IsOverObject( GadgetID( Startup::*LHImages\ScreenGDID[n] )) = 1 )    			
						ProcedureReturn GadgetID( Startup::*LHImages\ScreenGDID[n])
    		EndIf
    		Thread_DoEvents() 
    	Next
    	ProcedureReturn -1         
    EndProcedure
    
    ;******************************************************************************************************************************************
    ; Übergibt das aktuelle Gadget (Alterantiv)
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.i Screens_Menu_GetSlot_Alt(GadgetID.i)
    	
    	Protected Unknown.l, Format.l, Extension$,  Result.i
    	
    	For n = 1 To Startup::*LHGameDB\MaxScreenshots
    		
    		  If ( GadgetID = Startup::*LHImages\ScreenGDID[n] )     		
						ProcedureReturn n
    		EndIf
    		Thread_DoEvents() 
    	Next
    	n = -1
    	ProcedureReturn GadgetID         
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
     	
     	If Not ( ImageData = 0 )
     		*m = AllocateMemory( ImageData, #PB_Memory_NoClear )
     		
     		If ( *m )                 
     			Screens_SetInfo(szFile, FileSize(szFile) )
     			
     			;ShowMemoryViewer(ImageData, MemorySize( ImageData ) )                 
     			GenImage  = CatchImage(#PB_Any, ImageData, MemorySize( ImageData ) )
     			
     			;ShowMemoryViewer(GenImage, MemorySize( ImageData ) )
     			ImageData = EncodeImage(GenImage, #PB_ImagePlugin_PNG)
     			
     			If Not ( ImageData = 0 )
     				ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(ImgNum) +"_Big","",Startup::*LHGameDB\GameID,1,ImageData,"BaseGameID"):Delay(1)  
     			EndIf
     			
     			If IsImage( GenImage )                                	
     				FreeImage ( GenImage )
     			EndIf                
     			
     			FreeMemory( *m) 
     		EndIf
     		
     		If IsImage( ImageData )                                	
     			FreeImage ( ImageData )
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
          
          If Not ( ImageData = 0 )
              
              *m = AllocateMemory( ImageData, #PB_Memory_NoClear )
                    
               If ( *m )
                   
                   ConvPngImage = CatchImage(#PB_Any, ImageData, MemorySize( ImageData ) ) 
                   If Not ( ConvPngImage = 0 )
                       
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
    ;  Glipboard Image Prüfung
    ;__________________________________________________________________________________________________________________________________________       
    Procedure.i Screens_Menu_Check_Clipboard()
        
        Protected Extension$, GenImage.l
        
        ClipBoardImage.l = GetClipboardImage(#PB_Any)
        
        If IsImage( ClipBoardImage.l )
            
            GenImage.l  = GrabImage(ClipBoardImage, #PB_Any,0,0, ImageWidth(ClipBoardImage),ImageHeight(ClipBoardImage))
            
            Debug ""
            Debug "Import Clibboard Image"
            Debug "Image Weite  : " + Str(ImageWidth(ClipBoardImage))
            Debug "Image Höhe   : " + Str(ImageHeight(ClipBoardImage))
            Debug "Image Format : " + Str(ImageFormat(ClipBoardImage))            
                  
            ProcedureReturn #True
        EndIf                                       
        ProcedureReturn #False                       
      EndProcedure 
      
    ;******************************************************************************************************************************************
    ;  Import image über der Ablage
    ;__________________________________________________________________________________________________________________________________________       
    Procedure Screens_Menu_Paste_Import(GadgetID.i)
        
    	Protected Extension$, GenImage.l, *ImageData, nSlot.i
    	
    	ClipBoardImage.l = GetClipboardImage(#PB_Any)
    	
    	If IsImage( ClipBoardImage.l )
    		
    		GenImage.l  = GrabImage(ClipBoardImage, #PB_Any,0,0, ImageWidth(ClipBoardImage),ImageHeight(ClipBoardImage))
    		
    		Debug ""
    		Debug "Import Clibboard Image"
    		Debug "Image Weite  : " + Str(ImageWidth(ClipBoardImage))
    		Debug "Image Höhe   : " + Str(ImageHeight(ClipBoardImage))
    		Debug "Image Format : " + Str(ImageFormat(ClipBoardImage))     
    		Debug "Image Tiefe  : " + Str(ImageDepth(ClipBoardImage,#PB_Image_OriginalDepth))     		
    		
    		For n = 1 To Startup::*LHGameDB\MaxScreenshots
    			If ( GadgetID = Startup::*LHImages\ScreenGDID[n] )                             
    				nSlot = n
    				Break
    			EndIf
    		Next    
    		
    		If ( Screens_Overwrite(nSlot) = 0 )
    			If IsImage( GenImage )
    				FreeImage( GenImage )
    			EndIf	
    			ProcedureReturn 
    		EndIf    
    		
    		HideGadget(DC::#Text_004,0)  
    		
    		Startup::*LHGameDB\bisImageDBChanged = #True 
    		
    		*ImageData = EncodeImage(ClipBoardImage, #PB_ImagePlugin_PNG)
    		
    		If Not ( *ImageData = 0 )
    			ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(nSlot) +"_Big","",Startup::*LHGameDB\GameID,1,*ImageData,"BaseGameID"):Delay(1)  
    			
    			Screens_Copy_ResizeToGadget(nSlot, GenImage, Startup::*LHImages\ScreenGDID[nSlot]) 
    			
    			If IsImage( GenImage )
    				FreeImage( GenImage )
    			EndIf	
    			
    			Screens_Import_Save_Thumbnail(nSlot)    			
    		EndIf
    		
    		Screens_Show(): SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1)                       
    	EndIf                                    
    	ProcedureReturn                        
    EndProcedure          
    ;******************************************************************************************************************************************
    ;  Lädt und Importiert die Screenshots über das menu
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.s Screens_Menu_Info_Image()
    	
    	Protected Unknown.l, Extension.s
   	
    	Slot.i = Screens_Menu_GetSlot()
    	
    	If Not Slot   = -1
    		Unknown.l  = Screens_Menu_Get_Original(Slot)
    		
    		If ( Unknown <> 0 )
    			Extension = Screens_Menu_Save_Format(Unknown.l)
    			
    			If ( Len(Extension) >= 1 )                     				
    				InfoString.s = UCase(Extension) + " - " + Str(ImageWidth(Unknown)) + "x" + Str(ImageHeight(Unknown)) + "x"  + Str(ImageDepth(Unknown,#PB_Image_OriginalDepth)) + "bit"
    				InfoString   = "Slot "+Slot+": " + InfoString
    				ProcedureReturn InfoString
    			EndIf    
    			
    		EndIf    		
    	EndIf
    	ProcedureReturn ""
    	Delay(250)
    	SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,1)          
    EndProcedure  
    ;******************************************************************************************************************************************
    ;  Holt Infos
		;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_Menu_Save_Image(CurrentGadget.i)
    	
   Protected Unknown.l, Format.l, Extension.s,  Result.i, File.s
   
        Slot.i = Screens_Menu_GetSlot_Alt(CurrentGadget)
        If Not Slot   = -1
        	
        	Unknown = Screens_Menu_Get_Original(Slot)
        	
        	If ( Unknown <> 0 )
        		Extension = Screens_Menu_Save_Format(Unknown.l)
        		
        		If ( Len(Extension) >= 1 )                 
        			
        			File.s = FFH::GetFilePBRQ("Speichere "+Extension+" Bild", Screens_Menu_Set_Filename("", Extension, Slot), #True, "." + LCase(Extension))
        			If ( File )
        				Result = vItemTool::DialogRequest_Screens_Menu_Verfiy_File(File)                        
        				
        				If ( Result = 0 )                        
        					Screens_Menu_Save_ImageFormat(File, Unknown.l, Extension)
        				EndIf  
        				
        			EndIf
        		EndIf    
        	EndIf       
        EndIf
        Delay(250)
        SetGadgetText(DC::#Text_004, ""): HideGadget(DC::#Text_004,1)          
        
    	
    EndProcedure
    ;******************************************************************************************************************************************
    ;  Lädt und Importiert die Screenshots über das menu
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure Screens_Menu_Copy_Image(CurrentGadget.i)
               
        Slot.i = Screens_Menu_GetSlot_Alt(CurrentGadget)
        If Not Slot   = -1                                             
           SetClipboardImage( Screens_Menu_Get_Original( Slot) )
        EndIf        
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
            Thread_DoEvents() 
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
    ;
		;
		;
    Procedure 	Screens_ShowWindow_Info()
    	
    	Protected sMsg.s
    	
    	sMsg + "Original "
    	sMsg + Startup::*LHimgEdit\bmOrig\format
    	sMsg + " "    	
    	sMsg + Str( Startup::*LHimgEdit\bmOrig\w )
    	sMsg + "x"
    	sMsg + Str( Startup::*LHimgEdit\bmOrig\h )
    	sMsg + "x"
    	sMsg + Str( Startup::*LHimgEdit\bmOrig\bits )
    	sMsg + " Dateigröße: "
    	sMsg + Startup::*LHimgEdit\bmOrig\imgsize

     	SetGadgetText(DC::#Text_140, sMsg)
     	
    EndProcedure
    ;
		;
		;
    Procedure.q	Get_BitmapSize(imagedata.l)
    	Protected *ImageBuffer, ImageSize.q
    	
    	If IsImage( imagedata )

    		If Not ( ImageFormat(ImageData) = 0 )
    			
    			Select ImageFormat(ImageData)
    				Case #PB_ImagePlugin_JPEG			:	Debug "Bild liegt im JPG Format vor"    					
    				Case #PB_ImagePlugin_JPEG2000	: Debug "Bild liegt im JPEG2000 Format vor"     					
    				Case #PB_ImagePlugin_PNG			: Debug "Bild liegt im PNG Format vor"      					
    				Case #PB_ImagePlugin_TGA			: Debug "Bild liegt im TGA Format vor"      				    					
    				Case #PB_ImagePlugin_TIFF			: Debug "Bild liegt im TIFF Format vor"      					
    				Case #PB_ImagePlugin_BMP			: Debug "Bild liegt im BMP Format vor"      					
    				Case #PB_ImagePlugin_ICON			: Debug "Bild liegt im ICON Format vor"     					
    				Case #PB_ImagePlugin_GIF			: Debug "Bild liegt im GIF Format vor"  
    				Default
    					Debug "FEHELR Unbekanntes Format"	
    					
    			EndSelect
    			
    			*ImageBuffer = EncodeImage(ImageData, ImageFormat(ImageData),0,ImageDepth(ImageData,#PB_Image_OriginalDepth))
    		Else

    			*ImageBuffer = EncodeImage(ImageData, #PB_ImagePlugin_PNG,0,ImageDepth(ImageData,#PB_Image_OriginalDepth))
    		EndIf
    		
    		ImageSize.q = MemorySize(*ImageBuffer)
    		
    		FreeMemory(*ImageBuffer)
    	EndIf
    	ProcedureReturn ImageSize
    EndProcedure
		;
		;
		;
    Procedure.i Window_GetCurrentPbs(ImageData.l)
    	Protected Result.i = 0
    	
    	Result = CopyImage(ImageData, DC::#EditImage)
    	
    	If Not ( Result = 0 )      		    		    		
    		ProcedureReturn Result
    	EndIf    	
    	
    EndProcedure     
    ;
		;
		;   	
    Procedure Window_ConvertDepth(Source.l,Destination.l,Depth.i, width.i, height.i)
    	    	
    	If Not ( ImageDepth(Source) = Depth )    		  
    		NewImage.l = CreateImage(Destination, width, height, Depth)
    		StartDrawing( ImageOutput( NewImage ))
    		DrawImage( ImageID( Source ),0,0 )
    		StopDrawing()    		
    	Else
    		NewImage.l = CopyImage(Source,Destination)    		    		
    	EndIf
    	    	
    	ProcedureReturn NewImage    	
    	
    EndProcedure
    ;
		;
		;     
    Procedure.l Window_GetCurrentInfo( ImageData.l, CurrentGadgetID.i, nSlot.i)
   	   	
    	NewDepthID.l = Window_ConvertDepth(ImageData, #PB_Any, 32, ImageWidth( ImageData ), ImageHeight( ImageData ) )    	
    	
    	If IsImage( ImageData )
    		FreeImage( ImageData )
    	EndIf
    	
    	ProcedureReturn NewDepthID
    	
    EndProcedure	
    ;
		;
		;
    Procedure.l Window_GetCurrentRaw( CurrentGadgetID.i )
    	
    	Protected ImageData.l
    	
    	For n = 1 To Startup::*LHGameDB\MaxScreenshots    		
    		
    		If ( CurrentGadgetID = Startup::*LHImages\ScreenGDID[n] )
    			;
					;
					; Das original Bild aus der DB holen
					;
    			;
    			ImageData = Screens_Menu_Get_Original(n)    			
    			If ( ImageData = 0)
    				;
    				; Hole NoScreen Image
						ImageData = CopyImage(Startup::*LHImages\NoScreenPB[n],#PB_Any )
    			EndIf
    			
    			If Not ( ImageData = 0 )
    				
    				Startup::*LHimgEdit\cPBID 	 			= CurrentGadgetID
    				
    				Startup::*LHimgEdit\OrgData 			= CopyImage( ImageData, #PB_Any)
    				Startup::*LHimgEdit\bmOrig\w 	  	= ImageWidth(ImageData)
    				Startup::*LHimgEdit\bmOrig\h 	  	= ImageHeight(ImageData)
    				Startup::*LHimgEdit\bmOrig\bits 	= ImageDepth(ImageData, #PB_Image_OriginalDepth)
    				Startup::*LHimgEdit\bmOrig\format	=	Screens_Menu_Save_Format(ImageData) 
    				Startup::*LHimgEdit\bmOrig\rawsize=	Get_BitmapSize(imagedata)
    				Startup::*LHimgEdit\bmOrig\imgsize=	MathBytes::Bytes2String( Startup::*LHimgEdit\bmOrig\rawsize)
    				
    				
    				;
    				; Convert to 32Bit for Zoom Mode    				
    				ImageData = Window_GetCurrentInfo( ImageData, CurrentGadgetID, n)    				
    				
    				Startup::*LHimgEdit\CpyData 			= CopyImage( ImageData, #PB_Any)
    				Startup::*LHimgEdit\bmCopy\w 	  	= Startup::*LHimgEdit\bmOrig\w
    				Startup::*LHimgEdit\bmCopy\h 	  	= Startup::*LHimgEdit\bmOrig\h 
    				Startup::*LHimgEdit\bmCopy\bits 	= ImageDepth(ImageData, #PB_Image_OriginalDepth)
    				Startup::*LHimgEdit\bmCopy\format	=	Screens_Menu_Save_Format(ImageData) 
    				Startup::*LHimgEdit\bmCopy\rawsize=	Get_BitmapSize(imagedata)
    				Startup::*LHimgEdit\bmCopy\imgsize=	MathBytes::Bytes2String( Startup::*LHimgEdit\bmCopy\rawsize)  
    				
    			EndIf	
    			ProcedureReturn ImageData    			   			
    		EndIf
    	Next
    EndProcedure    
    ;
		;
		;
    Procedure 	 Screen_ShowWindow_ChangeImgSize(ImageData.l, NewWidth.i = #PB_Ignore, NewHeight.i = #PB_Ignore, ThumbnailSlot.i = -1)
    	
    	If ( NewWidth  = #PB_Ignore )
    		NewWidth  = ImageWidth (Startup::*LHimgEdit\CpyData )
    	EndIf	
    	If ( NewHeight = #PB_Ignore )
    		NewHeight = ImageHeight(Startup::*LHimgEdit\CpyData )
    	EndIf      		
    							
    	Startup::*LHimgEdit\CpyData = CopyImage( FORM::ImageResizeEx(ImageData, NewWidth, NewHeight),#PB_Any)
;     	If IsImage( ImageData)
;     		FreeImage( ImageData )
;     	EndIf	
    	
  
    	
    EndProcedure
    ;
		;
		;      
    Procedure.i Screen_ShowWindow_GetDimensionW(Hwnd.i, ImageDim.i, WindowDim.i, TaskbarHeight.i, BorderSize.i, TitlebarBorderSize.i, SnapSize.i, ThumbnailSlot.i, ImageData.l)
    	;
			; Procedure Return Übergibt die Fenster Weite      	
    	If ( ImageDim = WindowDim) : Debug " -- Bild Weite Hat die selbe Desktop Weite"
    		
    		Screen_ShowWindow_ChangeImgSize(ImageData,  WindowDim - ( BorderSize * 4 ),#PB_Ignore,ThumbnailSlot)    		
    		ProcedureReturn ImageDim
    	EndIf
    	
    	If ( ImageDim > WindowDim) : Debug " -- Bild Weite ist größer als der Desktop : Nutze Desktop Weite"   		
    		Screen_ShowWindow_ChangeImgSize(ImageData,  WindowDim - ( BorderSize * 4 ), #PB_Ignore,ThumbnailSlot)
    		
    		ProcedureReturn WindowDim - (BorderSize * 2) 
    	EndIf	
    	
    	If ( ImageDim <  WindowDim)	: Debug " -- Bild Weite ist kleiner als der Desktop: Nutze die Bild Weite"
    		
    		ProcedureReturn ImageDim + (BorderSize * 2) 
    	EndIf     	
    	
    EndProcedure      
    ;
		;
		;
    Procedure.i Screen_ShowWindow_GetDimensionH(Hwnd.i, ImageDim.i, WindowDim.i, TaskbarHeight.i, BorderSize.i, TitlebarBorderSize.i, SnapSize.i, ThumbnailSlot.i, ImageData.l)      	
    	;
			; Procedure Return Übergibt die Fenster Höhe 
    	Protected nSlot.i = ThumbnailSlot
    	
    	If ( ImageDim = WindowDim) : Debug " -- Bild Höhe Hat die selbe Desktop Höhe" 
    		Screen_ShowWindow_ChangeImgSize( ImageData, #PB_Ignore , WindowDim - ( (SnapSize * 2)  ), nSlot )      		      	
    		
    		ProcedureReturn ImageDim - (TitlebarBorderSize * 2) 
    	EndIf 
    	
    	If ( ImageDim > WindowDim) : Debug " -- Bild Höhe ist größer als Desktop : Nutze Desktop Höhe"
    		Screen_ShowWindow_ChangeImgSize( ImageData, #PB_Ignore , WindowDim - ( (SnapSize * 2) + (TitlebarBorderSize * 2) ), nSlot )
    		
    		ProcedureReturn WindowDim - (TitlebarBorderSize * 2)   			        			        			
    	EndIf
    	
    	If ( ImageDim <  WindowDim): Debug " -- Bild Höhe ist kleiner als der Desktop: Nutze die Bild Höhe"	      	     		
    		
    		If ( ImageDim + (SnapSize * 2) >  WindowDim )      			
    			Screen_ShowWindow_ChangeImgSize(ImageData, #PB_Ignore, ImageDim - ( (SnapSize * 2) - (TitlebarBorderSize * 2) ), nSlot )
    			
    			ProcedureReturn WindowDim - (TitlebarBorderSize * 2)
    		Else
    			
    			ProcedureReturn ImageDim + ( SnapSize * 2 )
    		EndIf
    	EndIf     	
    	
    	
    EndProcedure
    ;
		;
		;
    Procedure.i 		Screen_ShowWindow_AreaHeight()
    	
    	;
			; Code not finished
    	;
    	Protected ImageH.i = Startup::*LHimgEdit\bmCopy\h
    	Protected GadgtH.i = GadgetHeight (DC::#Contain_11 )
    	Protected InnerH.i = GetGadgetAttribute (DC::#Contain_11,#PB_ScrollArea_InnerHeight )
    	Protected WindowH  = WindowWidth (  DC::#_Window_004 )
    	
    	Top  = Abs( GadgetHeight(DC::#Contain_11  ) + ( GadgetY(DC::#Contain_11  )  - GadgetHeight(DC::#Contain_11  ) - WindowHeight(  DC::#_Window_004 )) / 2 ) 
    	Startup::*LHimgEdit\bmCopy\y = Top 
    	
    	SM_CXHSCROLL.i = GetSystemMetrics_(#SM_CXHSCROLL)
    	
    	Debug "Image  Höhe : " + Str( ImageH )
    	Debug "Gadget Höhe : " + Str( GadgtH ) 
    	Debug "Innere Höhe : " + Str( InnerH )
     	Debug "FensterHöhe : " + Str( WindowH)    	

    	PositionY.i = ( GadgtH - ImageH ) /2
    	
    	Debug "Position Y  : " + Str( PositionY )
    	
    	If ( ImageH >= GadgtH+Top+30 )
    		PositionY /2
    		ShowScrollBar_(GadgetID(DC::#Contain_11 ), #SB_VERT, #True)    		
    		SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_Y,-PositionY ) 
    		SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_InnerHeight, ImageH )    		    		    		
    	Else
    		ShowScrollBar_(GadgetID(DC::#Contain_11 ), #SB_VERT, #False)
    		SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_InnerHeight, GadgtH )    		
    	EndIf	
    	ProcedureReturn PositionY
    	
    EndProcedure
    ;
		;
		;
    Procedure.i 		Screen_ShowWindow_AreaWidth()
    	
    	
    	;
			; Code not finished
    	;    	
    	Protected ImageW.i = Startup::*LHimgEdit\bmCopy\w
    	Protected GadgtW.i = GadgetWidth (DC::#Contain_11 )
    	Protected InnerW.i = GetGadgetAttribute (DC::#Contain_11,#PB_ScrollArea_InnerWidth )
    	Protected WindowW  = WindowWidth (  DC::#_Window_004 )
    	
    	Left = Abs( GadgetWidth (DC::#Contain_11  ) + ( GadgetX(DC::#Contain_11  )  - GadgetWidth (DC::#Contain_11  ) - WindowWidth (  DC::#_Window_004 )) / 2 )
    	Startup::*LHimgEdit\bmCopy\x = Left 
    	
    	SM_CXVSCROLL.i = GetSystemMetrics_(#SM_CXVSCROLL) 
    	
    	Debug "Image  Weite: " + Str( ImageW )
    	Debug "Gadget Weite: " + Str( GadgtW ) 
    	Debug "Innere Weite: " + Str( InnerW )
    	Debug "FensterWeite: " + Str( WindowW)    	
    	    	
    	PositionX.i = ( GadgtW - ImageW ) /2

    	Debug "Position X  : " + Str( PositionX )
    	
    	If ( ImageW > GadgtW )
    		PositionX / 2  
    		ShowScrollBar_(GadgetID(DC::#Contain_11 ), #SB_HORZ, #True)
    		SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_X,-PositionX ) 
    		SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_InnerWidth, ImageW )
    		;PositionX + ( SM_CXVSCROLL/2)
    	Else
    		ShowScrollBar_(GadgetID(DC::#Contain_11 ), #SB_HORZ, #False)
    		SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_InnerWidth, GadgtW )
    	EndIf	
    	ProcedureReturn PositionX
    	
    EndProcedure    
		;
		;
    ;
    Procedure 		Screen_ShowWindow_SetAreaScroll()
    	
    	Protected AreaID.i =  DC::#Contain_11 		

    	If ( Startup::*LHimgEdit\bmCopy\w < 32767 ) Or ( Startup::*LHimgEdit\bmCopy\h < 32767 )   		
   			ResizeGadget(DC::#ImageCont11    ,Screen_ShowWindow_AreaWidth(), Screen_ShowWindow_AreaHeight(), Startup::*LHimgEdit\bmCopy\w, Startup::*LHimgEdit\bmCopy\h) 
   		EndIf	

    EndProcedure    
    ;******************************************************************************************************************************************
    ;  Bild Ins Fenster Packen
    ;__________________________________________________________________________________________________________________________________________     
    Procedure Screens_ShowWindow(CurrentGadgetID.i, Hwnd.i)
    	
    		Debug #CRLF$ + "Screens ShowWindow ([Thumbnail Gadget] " + CurrentGadgetID + ",[Hwnd] " + Hwnd + ")"
    		
    		HideGadget(DC::#Text_004,0)
    		SetGadgetText(DC::#Text_004, "Lade und Öffne Bild .. [ Extrahiere aus der DB ID " + CurrentGadgetID + "]")
    		
        Protected DesktopW.i	= DesktopEX::MonitorInfo_Display_Size(#False,#True)        
        Protected DesktopH.i	= DesktopEX::MonitorInfo_Display_Size(#True)

      	Protected TaskbarH.i	= DesktopEX::Get_TaskbarHeight(Hwnd, #True)        
        		
        Protected BordSize.i	=	FORM::WindowSizeBorder(Hwnd)
        Protected TitlSize.i	=	FORM::WindowSizeTitleB(Hwnd)

        Protected WindowW.i = 0
        Protected WindowH.i = 0
        
        Protected SnapSize.i  = 30
        
        Protected ImageData = vImages::Window_GetCurrentRaw( CurrentGadgetID )
        
        If IsImage( ImageData ) And Not ( ImageData = 0 )
        	
        	; AKuelle Grösse des Bildes (Hinterlegt als Oroiginal in der Datenbank)
					; 
        	ThumbnailSlot.i = Screen_GetThumnbailSlot(CurrentGadgetID)
        	ImageWidth .i   = ImageWidth ( ImageData )         	
        	ImageHeight.i   = ImageHeight( ImageData )                   
        	
        	If Not ( Startup::*LHimgEdit\CpyData = 0 )
        		       		
        		Debug " Desktop Size (Weite/Höhe):" + Str( DesktopW ) + "x" + Str( DesktopH ) 
        		Debug " Taskbar Höhe             :" + Str( TaskbarH )
        		Debug " Rahmen Größe             :" + Str( BordSize )
        		Debug " Title Border Größe       :" + Str( TitlSize )          		
        		Debug " Bild Größe   (Weite/Höhe):" + Str( ImageWidth ) + "x" + Str( ImageHeight )
        		
        		Debug " Weite des Bildes Prüfen  :"
        		WindowW.i = Screen_ShowWindow_GetDimensionW(Hwnd, ImageWidth , DesktopW, TaskbarH, BordSize, TitlSize, SnapSize, ThumbnailSlot, ImageData)  
        		
        		Debug " Höhe des Bildes Prüfen  :"      		
        		WindowH.i = Screen_ShowWindow_GetDimensionH(Hwnd, ImageHeight, DesktopH, TaskbarH, BordSize, TitlSize, SnapSize, ThumbnailSlot, ImageData)        		
        		
        		Debug " Fenstergröße (Weite/Höhe):" + Str( WindowW ) + "x" + Str( WindowH )
        		
  					Startup::*LHimgEdit\bmCopy\x = 0
						Startup::*LHimgEdit\bmCopy\y = 0
						Startup::*LHimgEdit\bmCopy\w = ImageWidth (Startup::*LHimgEdit\CpyData )
						Startup::*LHimgEdit\bmCopy\h = ImageHeight(Startup::*LHimgEdit\CpyData )
						
						SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_InnerWidth  , Startup::*LHimgEdit\bmCopy\w )
						SetGadgetAttribute( DC::#Contain_11, #PB_ScrollArea_InnerHeight , Startup::*LHimgEdit\bmCopy\h )
						
        		ResizeWindow(hwnd, #PB_Ignore, #PB_Ignore, WindowW-(BordSize*2), WindowH)
        		 
						If IsImage( ImageData )
        			FreeImage( ImageData )
        		EndIf	
        		
        		WinGuru::Center(Hwnd, WindowW, WindowH, Hwnd) 
        		
        		vImages::Window_ZoomScroll()         		        		
        		
        		If ImageWidth >= WindowW
        				ShowWindow_(WindowID(Hwnd), #SW_MAXIMIZE)
        				DesktopEX::Get_TaskbarHeight(Hwnd)
        		EndIf		
        		
    				HideGadget(DC::#Text_004,1)
    				SetGadgetText(DC::#Text_004, "")        		
        	EndIf
        EndIf	

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
            Thread_DoEvents() 
        Next    
        
        SetGadgetAttribute(DC::#Contain_10, #PB_ScrollArea_InnerHeight, Y + Startup::*LHGameDB\hScreenShotGadget)
        SetGadgetAttribute(DC::#Contain_10, #PB_ScrollArea_InnerWidth, wScroll-GetSystemMetrics_(#SM_CXHTHUMB)-4) 
        ProcedureReturn  Y + Startup::*LHGameDB\hScreenShotGadget
    EndProcedure  
    
    ;******************************************************************************************************************************************
    ;  Ändere Live Thumbnail Grösse. (Taste,Gui) * THREAD
    ;__________________________________________________________________________________________________________________________________________   
    Procedure Thread(*params.STRUCT_IMAGEPARAM)
        ;
        ; Speicher die Gadget Grösse in die Datenbank Zelle                
        Screens_Copy_ResizeToGadget(*params\n,CatchImage(#PB_Any, *params\ScreenShots, MemorySize(*params\ScreenShots)), Startup::*LHImages\ScreenGDID[*params\n])
       
        *params\ScreenShots = EncodeImage(Startup::*LHImages\CpScreenPB[*params\n], #PB_ImagePlugin_PNG)
        
        If ( MemorySize(*params\ScreenShots) <> 0 )
        	ExecSQL::ImageSet(DC::#Database_002,"GameShot","Shot"+ Str(*params\n) +"_Thb","",Startup::*LHGameDB\GameID,1,*params\ScreenShots,"BaseGameID")
        	
        	If IsImage( *params\ScreenShots )
        		FreeImage(*params\ScreenShots)
        	EndIf
        	
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
              
             ; SendMessage_( Startup::*LHImages\CpScreenPB[*params\n], #WM_SETREDRAW,#False,0)
              
              Thread = CreateThread(@Thread(), *params.STRUCT_IMAGEPARAM)
              If IsThread(Thread)
              	WaitThread(Thread,ProcessEX::DelayMicroSeconds(1))
              EndIf	
              
             ; SendMessage_( Startup::*LHImages\CpScreenPB[*params\n], #WM_SETREDRAW,#True,0)	
              FreeMemory( *params )
              
          EndIf            
      EndProcedure      
    ;******************************************************************************************************************************************
    ;  Ändere Live Thumbnail Grösse. (Taste,Gui)
    ;__________________________________________________________________________________________________________________________________________      
    Procedure Screens_ChgThumbnails(key.i, save.i = #False, DelayTime.i = 0, WMKeyUP = -1)
        
        ;
        ; Bewege nicht den Listbox Cursor
    		SetGadgetState( DC::#ListIcon_001, GetGadgetState(DC::#ListIcon_001) ) 
    	
				Startup::*LHGameDB\GadgetIDCheck = DC::#ListIcon_001
				SetActiveGadget(Startup::*LHGameDB\GadgetIDCheck)		    	
        
        If ( CountGadgetItems(DC::#ListIcon_001) = 0 )
            ;
            ; Null Items in der Liste - mach nichts
            ProcedureReturn
        EndIf
                

        If ( save = #True ) And (WMKeyUP = 257)
            
            SetGadgetText(DC::#Text_004,"Save and Update Thumbnails Preview")
            
            Protected *ScreenShots, MemorySize.q       
            
            SetPriorityClass_(GetCurrentProcess_(),#HIGH_PRIORITY_CLASS)
            
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsW", Str(Startup::*LHGameDB\wScreenShotGadget),Startup::*LHGameDB\GameID)
            ExecSQL::UpdateRow(DC::#Database_002,"GameShot", "ThumbnailsH", Str(Startup::*LHGameDB\hScreenShotGadget),Startup::*LHGameDB\GameID)              
            
            
            For n = 1 To Startup::*LHGameDB\MaxScreenshots
                
                *ScreenShots = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(n)+ "_Big",Startup::*LHGameDB\GameID,"BaseGameID")
                
                If (  *ScreenShots <> 0 )
                    
                    MemorySize + MemorySize(*ScreenShots)         
                    DatabaseUpdate(DC::#Database_002, "PRAGMA mmap_size="+MemorySize+";") 
                                   
                    SetGadgetText(DC::#Text_004,"Save and Update Thumbnails Preview ("+MathBytes::Bytes2String(MemorySize) +")")
                    
                    Screens_ChgThumbnails_Sub(*ScreenShots,n) 
                    
                    If IsImage( *ScreenShots )
                    	FreeImage(*ScreenShots)
                    EndIf
                    
                    FreeMemory(*ScreenShots)
                EndIf 
            Next
            ProcessEX::DelayMicroSeconds(DelayTime/100000)
            Screens_Show()             
            SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1)
            SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
            ProcedureReturn
            
        ElseIf ( save = #True ) And (WMKeyUP = -999)
            SetGadgetText(DC::#Text_004,"Create Thumbnails Preview")
            Screens_Show()             
            SetGadgetText(DC::#Text_004,""): HideGadget(DC::#Text_004,1)
            SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
            ProcedureReturn
        Else     
            
        	
        	DelayTimeDouble.d = DelayTime/10.0
        	Debug DelayTimeDouble
            ; 100 NumKey L w - 1
            ; 102 NumKey R w + 1
            ; 104 NumKey U h + 1
            ;  98 NumKey D h - 1  
            
            Select key
                Case #VK_F5,103
                    Startup::*LHGameDB\wScreenShotGadget + DelayTimeDouble
                    Startup::*LHGameDB\hScreenShotGadget + DelayTimeDouble  
                    
                Case #VK_F6,105
                    Startup::*LHGameDB\wScreenShotGadget - DelayTimeDouble
                    Startup::*LHGameDB\hScreenShotGadget - DelayTimeDouble                                
                    
                Case 104: Startup::*LHGameDB\hScreenShotGadget + DelayTimeDouble                                                             
                Case 98 : Startup::*LHGameDB\hScreenShotGadget - DelayTimeDouble
                    
                Case 102: Startup::*LHGameDB\wScreenShotGadget + DelayTimeDouble                  
                Case 100: Startup::*LHGameDB\wScreenShotGadget - DelayTimeDouble                  
            EndSelect          
            
            If (Startup::*LHGameDB\wScreenShotGadget <= 33 )
                Startup::*LHGameDB\wScreenShotGadget  = 34
            EndIf
            
            If (Startup::*LHGameDB\hScreenShotGadget <= 33 )
                Startup::*LHGameDB\hScreenShotGadget  = 34
            EndIf        
            
            HideGadget(DC::#Text_004,0)
            SetGadgetText(DC::#Text_004,"Resize Thumnails Size  Width:" + Startup::*LHGameDB\wScreenShotGadget+ " Height:" + Startup::*LHGameDB\hScreenShotGadget)
            
            Debug "Resize Thumnails Size  Width:" + Str(Startup::*LHGameDB\wScreenShotGadget) + " Height:" + Str(Startup::*LHGameDB\hScreenShotGadget)
            
            ;SendMessage_( DC::#Contain_10, #WM_SETREDRAW,#False,0)
            vImages::Screens_SetThumbnails() 
            ;SendMessage_( DC::#Contain_10, #WM_SETREDRAW,#True,0)
            vImages::Screens_Show()              
            SetPriorityClass_(GetCurrentProcess_(),#NORMAL_PRIORITY_CLASS)
            ProcessEX::DelayMicroSeconds(DelayTime/100000)
          
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
    ;
		;
		;
    Procedure.w MouseWheelDelta() 
      Protected x.w     
      x.w = ( (EventwParam() >>16) &$FFFF )
Debug "EventwParam: " + Str(x)
      ProcedureReturn -(x / 120) 
    EndProcedure
    ;
		;
		;

    Procedure.i Screen_GetThumnbailSlot( ThumbnailGadget.i )
    	Protected nSlot.i
    	
    	For nSlot = 1 To Startup::*LHGameDB\MaxScreenshots   
    		If ( ThumbnailGadget = Startup::*LHImages\ScreenGDID[n] )
    			ProcedureReturn nSlot
    		EndIf    		
    	Next    	
    EndProcedure
    ;
		;
		;
    Procedure.i Window_SetImage(ScrollArea.i, ImageBox.i, x.i, y.i, Width.i, Height.i)
    	
     	If IsImage( Startup::*LHimgEdit\OrgData )
     		Debug "Original Daten"
     	EndIf     	
     	
     	If IsImage( Startup::*LHimgEdit\CpyData )
     		FreeImage(  Startup::*LHimgEdit\CpyData )
     	EndIf
     	
     	Startup::*LHimgEdit\CpyData = CopyImage(Startup::*LHimgEdit\OrgData , #PB_Any)
     	
     	DisableGadget(ImageBox, #True)     	
     	FORM::ImageResizeEx(Startup::*LHimgEdit\CpyData , Width, Height,GetGadgetColor( ScrollArea ,#PB_Gadget_BackColor),#True)

   		Screen_ShowWindow_SetAreaScroll()      	
   		
   		SetGadgetState(ImageBox, ImageID( Startup::*LHimgEdit\CpyData ) ) 
   		;DisableGadget(ImageBox, #False )
   		RedrawWindow_(GadgetID(ImageBox), #Null, #Null, #RDW_INVALIDATE | #RDW_ERASE | #RDW_ALLCHILDREN | #RDW_UPDATENOW)

    	
    EndProcedure    
		;
		;
		;
    Procedure.i Window_ZoomScroll_Max()
    	
    	If ( Startup::*LHimgEdit\bmCopy\w > 32767 ) Or ( Startup::*LHimgEdit\bmCopy\h > 32767 )
    		;
				; MAX Gadget is 32767
    		    		
    		If ( Startup::*LHimgEdit\bmCopy\w > 35516 ) Or ( Startup::*LHimgEdit\bmCopy\h > 35516 )

    			sMsg.s = GetGadgetText(DC::#Text_140) + " Max Zoom Reached"
    			
    			SetGadgetText(DC::#Text_140, "") 
    			SetGadgetText(DC::#Text_140, sMsg)     			
    			Startup::*LHimgEdit\MaxReached = #True
    		Else
    			
    			Startup::*LHimgEdit\MaxReached = #False
    			Screens_ShowWindow_Info()
    		EndIf    		
    	EndIf
    	ProcedureReturn Startup::*LHimgEdit\MaxReached
    	    	
    EndProcedure
		;
		;
    ;    
    Procedure Window_ZoomScroll(ZoomDelta.w = 0)     	    	    	

    	Protected x	=	Startup::*LHimgEdit\bmCopy\x
    	Protected y	=	Startup::*LHimgEdit\bmCopy\y 
    	Protected w	=	Startup::*LHimgEdit\bmCopy\w 
    	Protected h	=	Startup::*LHimgEdit\bmCopy\h      		
    	
    	Debug "--------------------------------------------"
    	Debug "PB ID: " + Str( Startup::*LHimgEdit\CpyData )    	
    	Debug "Start (Weite): "+ Str(w) + "x" + Str(h) + " :(Höhe) / " + " Depth: " + Str(ImageDepth(Startup::*LHimgEdit\CpyData ))      	
    	
    	Startup::*LHimgEdit\mWheelActiv = #True 
    	
    	w+( w*( -ZoomDelta )/100 )
    	h+( h*( -ZoomDelta )/100 )    	
    	    	
    	Startup::*LHimgEdit\bmCopy\x = x
    	Startup::*LHimgEdit\bmCopy\y = y
    	Startup::*LHimgEdit\bmCopy\w = w
    	Startup::*LHimgEdit\bmCopy\h = h
    	     	
    	If Window_ZoomScroll_Max() = #True
    		ProcedureReturn 
    	EndIf	   				
    		
    	Window_SetImage(DC::#Contain_11, DC::#ImageCont11, x, y, w, h) 
    	Startup::*LHimgEdit\mWheelActiv = #False
    	
    	Debug "Ziel (Weite): "+ Str(w) + "x" + Str(h) + " :(Höhe) / " + " Depth: " + Str(ImageDepth(Startup::*LHimgEdit\CpyData ))  
    	    	
    EndProcedure	
  EndModule
  
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 240
; FirstLine = 223
; Folding = -PA1zygB5B-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\release\
; EnableUnicode