DeclareModule vThumbSys
    
    Declare     MainThread(z)
    Declare     MainThread_2(z)
    Declare     MainThread_3(z)
    Declare     MainThread_4(z)
    Declare     MainThread_5(z)
    Declare     MainThread_6(z)
    Declare     MainThread_7(z)
    Declare     MainThread_8(z)
    
    Declare.l   GetBig_FromDB(nSlotNum.i)
    Declare.l   GetSml_FromDB(nSlotNum.i)
    
    Declare.i   Get_ThumbnailSize(nSizeOption.i)
    
    Declare		GetImagesSize(nSlot)
    Declare		GetImagesSize_Reset()
    
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
        Slot.i
        Mutex.i
        Thread.i
        bWorking.i
    EndStructure
    
    Structure Struct_ImageSize
        w.i
        h.i
        x.i
        y.i
    EndStructure    
    
    Structure Struct_ImageFactor
        w.f
        h.f
        x.f
        y.f
    EndStructure      
    
    Structure Struct_OriginalImageSize
        w.i
        h.i
        x.i
        y.i
        d.i
        n.i
        NoScreen.i
    EndStructure
    
    Global NewList OIS.Struct_OriginalImageSize()
    
    Global NewList Queue()
    
    Global ResizeMutex = 0

    Procedure GetImagesSize_Reset()
    	
    	If ( ListSize( OIS() ) > 0 )
    		ClearList( OIS() )
    	EndIf
    	
    EndProcedure  	
    Procedure GetImagesSize(nSlot)
    	    	   	
    	AddElement( OIS() )
    	OIS()\n = nSlot
    	    	
      *Shot = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlot)+ "_Big",Startup::*LHGameDB\GameID,"BaseGameID")        					      					 					          
                
      If Not ( *Shot = 0 )
      	
      	*Buffer = AllocateMemory( *Shot )								      						                      
      	TestImage.l = 0
      	TestImage = CatchImage(#PB_Any, *Shot, *Buffer)
      	
      	; Get information about the image 
      	GetObject_(ImageID(TestImage), SizeOf(BITMAP), @bmp.BITMAP) 
      	
;      	With bmp             
;       		Debug "Slot           :" + Str( ThumbnailNum )
;       		Debug "\bmWidth       :" + Str( \bmWidth) 
;       		Debug "\bmHeight      :" + Str( \bmHeight)
;       		Debug "\bmWidthBytes  :" + Str( \bmWidthBytes)
;       		Debug "\bmBitsPixel   :" + Str( \bmBitsPixel)
;       		Debug "\bmBits        :" + Str( \bmBits)
;       		Debug "\bmPlanes      :" + Str( \bmPlanes)
;       		Debug "\bmType        :" + Str( \bmType)      		
;       		Debug "----------------------------------------"               
      		OIS()\w = ImageWidth(TestImage); \bmWidth
      		OIS()\h = ImageHeight(TestImage); \bmHeight
      		OIS()\d = ImageDepth(TestImage);\bmBits
      		OIS()\NoScreen = #False
      		
;      	EndWith      	
      	
      	FreeImage(TestImage)
      	FreeMemory(*Buffer)
      	*Shot = 0     
      EndIf        	
    EndProcedure
        
    ;*******************************************************************************************************************************************************************
    ;    
    Procedure.l   Thread_Resize(*Memory.STRUCT_REZIMAGES)
    	Define.l OriW, OriH, w, h, oriAR, newAR, ImageBlank.l
    	Define.f fw, fh
    	
    	Protected Source.Struct_ImageSize, Factor.Struct_ImageFactor, OrgAspectRatio.f, NewAspectRatio.f, Copy.Struct_ImageSize
    	
    	
    	Source\w = ImageWidth( *Memory\ImageID)
    	Source\h = ImageHeight(*Memory\ImageID)
    	
    	
    	; Calc Factor
    	Factor\w = *Memory\Width  / Source\w
    	Factor\h = *Memory\Height / Source\h
    	
    	; Calc AspectRatio
    	OrgAspectRatio = Round( (Source\w / Source\h) * 10,0)
    	NewAspectRatio = Round( (*Memory\Width / *Memory\Height) * 10,0)
    	
    	
    	
    	; AspectRatio already correct?
    	If     ( OrgAspectRatio = NewAspectRatio )
    		Copy\w = *Memory\Width
    		Copy\h = *Memory\Height
    		
    	ElseIf ( Source\w * Factor\h  <= *Memory\Width )
    		Copy\w = Source\w * Factor\h
    		Copy\h = Source\h * Factor\h
    		
    	ElseIf ( Source\h * Factor\w  <= *Memory\Height)
    		Copy\w = Source\w * Factor\w 
    		Copy\h = Source\h * Factor\w   
    	EndIf

    	ResizeImage(*Memory\ImageID,Copy\w,Copy\h,#PB_Image_Smooth )
    	
    	Select *Memory\BoxStyle
    		Case 1
    			w = 0
    			h = 0

    			Select *Memory\Alpha 
    				Case #False: ImageBlank = CreateImage(#PB_Any,*Memory\Width,*Memory\Height) 
    				Case #True : ImageBlank = CreateImage(#PB_Any,*Memory\Width,*Memory\Height,32,*Memory\ColorBlack.l)   
    			EndSelect                 
    			
    			If Not ( ImageBlank = 0 )
    				StartDraw.i = StartDrawing( ImageOutput( ImageBlank ) )
    				If Not StartDraw = 0
    					
    					
    					Select *Memory\Alpha 
    						Case #False: Box(0,0,*Memory\Width,*Memory\Height,*Memory\ColorBlack.l)                          
    					EndSelect                 
    					
    					
    					Select *Memory\Alpha 
    						Case #False: DrawingMode(#PB_2DDrawing_AlphaBlend)
    						Case #True : DrawingMode(#PB_2DDrawing_Transparent);DrawingMode(#PB_2DDrawing_Default)
    					EndSelect 
    					
    					
    					If ( *Memory\Center = #True )
    						w = *Memory\Width -  Abs(ImageWidth( *Memory\ImageID))
    						h = *Memory\Height - Abs(ImageHeight(*Memory\ImageID))
    						
    						If ( w <> 0 )
    							w / 2
    						EndIf
    						
    						If ( h <> 0 )
    							h / 2
    						EndIf
    						
    					EndIf
    					
    					
    					Select *Memory\Alpha 
    						Case #False: DrawImage(ImageID(*Memory\ImageID), w, h)                                                                        
    						Case #True : DrawAlphaImage(ImageID(*Memory\ImageID), w, h,*Memory\Level) 
    							
    					EndSelect    
    					
    					;Debug "ImageText " + Str( *Memory\ImageID) + " -- " + Str(ImageBlank)
    					
    					; 	      					ResetList( OIS() )
							; 	      					If ( ListSize( OIS() ) > 0 )
							; 	      						While NextElement( OIS() )
							; 	      							If OIS()\n = *memory\Slot
							; 	      								Debug OIS()\w
							; 	      								Debug OIS()\h
							; 	      								Debug OIS()\d
							; 	      								If Not ( OIS()\w = 0 )
							; 	      									DrawingFont(Fonts::#PC_Clone_09) 	
							; 	      									DrawText(1,*Memory\Height-18, Str( OIS()\w )+"x"+Str( OIS()\h )+"x"+Str( OIS()\d ), RGB(255,255,255))																					      									
							; 	      								EndIf	
							; 	      								Break
							; 	      							EndIf      							
							; 	      						Wend	      						
							; 	      					EndIf     
							;DrawText(*Memory\Width-40,*Memory\Height-18, Str( *Memory\ImageID ), RGBA(255, 255, 255, 0),RGBA(0, 0, 0, 255) )	      					
    					StopDrawing()     					
    					GrabImage(ImageBlank,*Memory\ImageID, 0, 0, *Memory\Width, *Memory\Height)
    					
    					FreeImage(ImageBlank)
    				EndIf
    			EndIf
    	EndSelect        
    	ProcedureReturn *Memory
    	
    EndProcedure
    ;
		;
    ;  
    Procedure   Resize_Gadget(n.i,StructImagePB.l, ImageGadgetID.i, Resize.i = #True)
    	
    	If IsImage(StructImagePB)                       
    		;
				; Erstelle eine Kopie und lege diesen handle in die Strukture, Mit Originaler Höhe und Breite              
    		CopyImage( StructImagePB, Startup::*LHImages\CpScreenPB[n] )
    		
    		Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])
    		
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
    			*Memory\Slot       = n
    			*Memory\Thread     = -1
    			
    			*Memory 					 = Thread_Resize(*Memory)
    			
    			Startup::*LHImages\CpScreenID[n] = ImageID(*Memory\ImageID)
    			
    			If IsImage( ImageID(Startup::*LHImages\CpScreenPB[n] ))
    				FreeImage( ImageID(Startup::*LHImages\CpScreenPB[n] ))
    			EndIf

    			FreeMemory(*Memory)
    			
    		EndIf	
    		
    	Else
    		Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Kein Bild in der Purebasic"+Str(StructImagePB) )
    	EndIf
    EndProcedure  
    ;
		;
    ;
    Procedure   Thumbnail_SetGadgetState(ThumbnailNum.i)
    	
      ; Get information about the image 
      ;GetObject_(ImageID(Startup::*LHImages\NoScreenPB[ThumbnailNum]), SizeOf(BITMAP), @bmp.BITMAP)         
			;         With bmp             
			;             Debug "Slot           :" + Str( ThumbnailNum )
			;             Debug "\bmWidth       :" + Str( \bmWidth) 
			;             Debug "\bmHeight      :" + Str( \bmHeight)
			;             Debug "\bmWidthBytes  :" + Str( \bmWidthBytes)
			;             Debug "\bmBitsPixel   :" + Str( \bmBitsPixel)
			;             Debug "\bmBits        :" + Str( \bmBits)
			;             Debug "----------------------------------------"               
			;         EndWith

      If IsGadget( Startup::*LHImages\ScreenGDID[ThumbnailNum] )
       	SetGadgetState(Startup::*LHImages\ScreenGDID[ThumbnailNum], -1) 
      EndIf	
        
    	If IsImage( Startup::*LHImages\ScreenGDID[ThumbnailNum] )
    		FreeImage( Startup::*LHImages\ScreenGDID[ThumbnailNum])
    	EndIf	
    	
    	;
    	;
    	SetGadgetState(Startup::*LHImages\ScreenGDID[ThumbnailNum], Startup::*LHImages\CpScreenID[ThumbnailNum])  
    	
    	If IsImage( Startup::*LHImages\CpScreenID[ThumbnailNum] )
    		FreeImage( Startup::*LHImages\CpScreenID[ThumbnailNum])
    	EndIf
    	
    	If IsImage( Startup::*LHImages\OrScreenID[ThumbnailNum] )
    		FreeImage( Startup::*LHImages\OrScreenID[ThumbnailNum])
    	EndIf    		
    	
    	If IsImage( Startup::*LHImages\OrScreenPB[ThumbnailNum] )
    		FreeImage( Startup::*LHImages\OrScreenPB[ThumbnailNum])
    	EndIf 
    	
    	If IsImage( Startup::*LHImages\CPScreenPB[ThumbnailNum] )
    		FreeImage( Startup::*LHImages\CPScreenPB[ThumbnailNum])
    	EndIf
    	  	    	
        
    EndProcedure
    ;
		;
    ;
     Procedure  DebugInfo( InfoNum.i, sztext.s = "")
         
         Request::SetDebugLog("Debug: " + #PB_Compiler_Module + " (Line " + Str(#PB_Compiler_Line) + " ) " + #TAB$ + "ERROR - CatchImage on Slot " + sztext)
         
     EndProcedure
    ;
		;
    ;    
    Procedure   Calc_Thumbnail1(Thumbnail = 1)
        Protected ImageData.l, RowID.i = Startup::*LHGameDB\GameID
        
        SlotContent.l = Startup::SlotShots(Thumbnail)\thumb[RowID]        
        If Not ( SlotContent = 0 )
        	
        	Result.i = CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], Startup::SlotShots(Thumbnail)\thumb[RowID], MemorySize( Startup::SlotShots(Thumbnail)\thumb[RowID] ))          	
        	If Not ( Result = 0 )
            	
                Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True)                 
          Else
                DebugInfo( InfoNum.i)
          EndIf 
            
        Else        		        		
        		Resize_Gadget(Thumbnail, Startup::*LHImages\NoScreenPB[Thumbnail] , Startup::*LHImages\ScreenGDID[Thumbnail])
        EndIf
        
        Thumbnail_SetGadgetState(Thumbnail)
        

    EndProcedure
    ;
		;
    ;
    Procedure   Set_Slot( nSlotNum.i )
    	
    	;Debug "Lege die Screenshots IN die Slots: " + Str(nSlotNum)
    	Calc_Thumbnail1(nSlotNum)
    EndProcedure    
    ;
		;
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
  
    Procedure   MainThread_5(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure  
    
    Procedure   MainThread_6(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure
    
    Procedure   MainThread_7(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure
    
    Procedure   MainThread_8(z)
        
        Protected nSlot.i   
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])
        
        Set_Slot( z )           
        
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])                                
    EndProcedure         
    ;
		;
    ;  
    Procedure.l GetBig_FromDB(nSlotNum.i)
        Protected *Memory
        
        *Memory = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlotNum)+ "_Big",ExecSQL::_IOSQL()\nRowID,"BaseGameID")              
     
        ProcedureReturn *Memory
    EndProcedure    
    ;
		;
    ;  
    Procedure.l GetSml_FromDB(nSlotNum.i)
        Protected *Memory
        
        *Memory = ExecSQL::ImageGet(DC::#Database_002,"GameShot","Shot" +Str(nSlotNum)+ "_thb",ExecSQL::_IOSQL()\nRowID,"BaseGameID") 
                
        ProcedureReturn *Memory
    EndProcedure 
    ;
		;
    ;        
    Procedure.i Get_ThumbnailSize(nSizeOption.i)
        
        Protected *Thumbnail.POINT
        
        *Thumbnail = AllocateMemory(SizeOf(POINT))
        Select nSizeOption
            Case 1: *Thumbnail\x  = 624: *Thumbnail\y = 495                ;Case 1: *Thumbnail\x  = 649: *Thumbnail\y = 520
            Case 2: *Thumbnail\x  = 310: *Thumbnail\y = 240                ;Case 2: *Thumbnail\x  = 313: *Thumbnail\y = 243
            Case 3: *Thumbnail\x  = 202: *Thumbnail\y = 142                ;Case 3: *Thumbnail\x  = 205: *Thumbnail\y = 163                         
            Case 4: *Thumbnail\x  = 153: *Thumbnail\y = 119
            Case 5: *Thumbnail\x  = 122: *Thumbnail\y = 99
            Case 6: *Thumbnail\x  = 101: *Thumbnail\y = 81
            Case 7: *Thumbnail\x  = 86:  *Thumbnail\y = 69                         
        EndSelect
        
        Debug "Set Thumbnail Size :" + Str(*Thumbnail\x) + "x" + Str( *Thumbnail\y)
        
        ProcedureReturn *Thumbnail
    EndProcedure
EndModule    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 500
; FirstLine = 300
; Folding = -PA-
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\release\
; Debugger = IDE
; Warnings = Display
; EnablePurifier