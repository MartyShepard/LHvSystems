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
    
    Declare.i	ClearImage(nSlot)
    
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
                
    Global Dim ThumbHold.STRUCT_REZIMAGES(50)


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
    ;
		;
    ;
    Procedure.i ClearImage(nSlot)
    	
    	If IsImage(Startup::*LHImages\CpScreenPB[nSlot])
    		FreeImage( Startup::*LHImages\CpScreenPB[nSlot] )
    		Request::SetDebugLog("Debug: " +#PB_Compiler_Module+ " #LINE: " +Str(#PB_Compiler_Line)+ " # " +#TAB$+ " CpScreenPB Cleared: " + Str(nSlot))     			
    	EndIf
    	If IsImage(Startup::*LHImages\OrScreenPB[nSlot])
    		FreeImage( Startup::*LHImages\OrScreenPB[nSlot] )
    		Request::SetDebugLog("Debug: " +#PB_Compiler_Module+ " #LINE: " +Str(#PB_Compiler_Line)+ " # " +#TAB$+ " OrScreenPB Cleared: " + Str(nSlot))    			
    	EndIf 
    	If IsImage(Startup::*LHImages\OrScreenID[nSlot])
    		FreeImage( Startup::*LHImages\OrScreenID[nSlot] )
    		Request::SetDebugLog("Debug: " +#PB_Compiler_Module+ " #LINE: " +Str(#PB_Compiler_Line)+ " # " +#TAB$+ " OrScreenID Cleared: " + Str(nSlot))
    	EndIf
    	If IsImage(Startup::*LHImages\CpScreenID[nSlot])
    		FreeImage( Startup::*LHImages\CpScreenID[nSlot] )
    		Request::SetDebugLog("Debug: " +#PB_Compiler_Module+ " #LINE: " +Str(#PB_Compiler_Line)+ " # " +#TAB$+ " CpScreenID Cleared: " + Str(nSlot))
    	EndIf
    	If IsImage(Startup::*LHImages\ScreenGDID[nSlot])
    		FreeImage( Startup::*LHImages\ScreenGDID[nSlot] )	
    		Request::SetDebugLog("Debug: " +#PB_Compiler_Module+ " #LINE: " +Str(#PB_Compiler_Line)+ " # " +#TAB$+ " ScreenGDID Cleared: " + Str(nSlot))
    	EndIf    	
    	
    EndProcedure	    
    ;*******************************************************************************************************************************************************************
    ;    
    Procedure.l   Thread_Resize(n)
    	Define.l OriW, OriH, w, h, oriAR, newAR, ImageBlank.l
    	Define.f fw, fh
    	
    	Protected Source.Struct_ImageSize, Factor.Struct_ImageFactor, OrgAspectRatio.f, NewAspectRatio.f, Copy.Struct_ImageSize
    	
    	
    	
    	If IsImage(  ThumbHold(n)\ImageID )
    		Source\w = ImageWidth(  ThumbHold(n)\ImageID)
    		Source\h = ImageHeight( ThumbHold(n)\ImageID)
    		
    		
    		; Calc Factor
    		Factor\w =  ThumbHold(n)\Width  / Source\w
    		Factor\h =  ThumbHold(n)\Height / Source\h
    		
    		; Calc AspectRatio
    		OrgAspectRatio = Round( (Source\w / Source\h) * 10,0)
    		NewAspectRatio = Round( ( ThumbHold(n)\Width /  ThumbHold(n)\Height) * 10,0)
    		
    		
    		
    		; AspectRatio already correct?
    		If     ( OrgAspectRatio = NewAspectRatio )
    			Copy\w =  ThumbHold(n)\Width
    			Copy\h =  ThumbHold(n)\Height
    			
    		ElseIf ( Source\w * Factor\h  <=  ThumbHold(n)\Width )
    			Copy\w = Source\w * Factor\h
    			Copy\h = Source\h * Factor\h
    			
    		ElseIf ( Source\h * Factor\w  <=  ThumbHold(n)\Height)
    			Copy\w = Source\w * Factor\w 
    			Copy\h = Source\h * Factor\w   
    		EndIf
    		
    		ResizeImage( ThumbHold(n)\ImageID,Copy\w,Copy\h,#PB_Image_Smooth )
    		
    		Select  ThumbHold(n)\BoxStyle
    			Case 1
    				w = 0
    				h = 0
    				
    				Select  ThumbHold(n)\Alpha 
    					Case #False: ImageBlank = CreateImage(#PB_Any, ThumbHold(n)\Width, ThumbHold(n)\Height) 
    					Case #True : ImageBlank = CreateImage(#PB_Any, ThumbHold(n)\Width, ThumbHold(n)\Height,32, ThumbHold(n)\ColorBlack.l)   
    				EndSelect                 
    				
    				If Not ( ImageBlank = 0 )
    					StartDraw.i = StartDrawing( ImageOutput( ImageBlank ) )
    					If Not StartDraw = 0
    						
    						
    						Select  ThumbHold(n)\Alpha 
    							Case #False: Box(0,0, ThumbHold(n)\Width, ThumbHold(n)\Height, ThumbHold(n)\ColorBlack.l)                          
    						EndSelect                 
    						
    						
    						Select  ThumbHold(n)\Alpha 
    							Case #False: DrawingMode(#PB_2DDrawing_AlphaBlend)
    							Case #True : DrawingMode(#PB_2DDrawing_Transparent);DrawingMode(#PB_2DDrawing_Default)
    						EndSelect 
    						
    						
    						If (  ThumbHold(n)\Center = #True )
    							w =  ThumbHold(n)\Width -  Abs(ImageWidth(  ThumbHold(n)\ImageID))
    							h =  ThumbHold(n)\Height - Abs(ImageHeight( ThumbHold(n)\ImageID))
    							
    							If ( w <> 0 )
    								w / 2
    							EndIf
    							
    							If ( h <> 0 )
    								h / 2
    							EndIf
    							
    						EndIf
    						
    						
    						Select  ThumbHold(n)\Alpha 
    							Case #False: DrawImage(ImageID( ThumbHold(n)\ImageID), w, h)                                                                        
    							Case #True : DrawAlphaImage(ImageID( ThumbHold(n)\ImageID), w, h, ThumbHold(n)\Level) 
    								
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
    						GrabImage(ImageBlank, ThumbHold(n)\ImageID, 0, 0,  ThumbHold(n)\Width,  ThumbHold(n)\Height)
    						
    						FreeImage(ImageBlank)
    						
    						ProcessEX::DelayMicroSeconds(10)
    						
    						If IsImage( ThumbHold(n)\ImageID )
    							Startup::*LHImages\CpScreenID[n] = ImageID(ThumbHold(n)\ImageID)
    						EndIf	
    						
    					EndIf
    				EndIf
    		EndSelect        
    	EndIf
    	
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
    			
    			ThumbHold(n)\ImageID    = Startup::*LHImages\CpScreenPB[n]
    			ThumbHold(n)\BoxStyle   = 1
    			ThumbHold(n)\ColorBlack = GetGadgetColor(DC::#Contain_10,#PB_Gadget_BackColor)
    			ThumbHold(n)\Height     = Startup::*LHGameDB\hScreenShotGadget 
    			ThumbHold(n)\Width      = Startup::*LHGameDB\wScreenShotGadget      
    			ThumbHold(n)\Center     = #True
    			ThumbHold(n)\Alpha      = #True
    			ThumbHold(n)\Level      = 255
    			ThumbHold(n)\Slot       = n
    			ThumbHold(n)\Thread     = -1    			
    			
    			ThumbHold(n)\Thread  = CreateThread(@Thread_Resize(),n)
    			
    			If IsThread(ThumbHold(n)\Thread )
    				WaitThread(ThumbHold(n)\Thread ,ProcessEX::DelayMicroSeconds(1))
    			EndIf     			
    			
    			If IsImage( ImageID( ThumbHold(n)\ImageID ))
    				FreeImage( ImageID( ThumbHold(n)\ImageID ))
    			EndIf
    			
    			If IsImage( ImageID(Startup::*LHImages\CpScreenPB[n] ))
    				FreeImage( ImageID(Startup::*LHImages\CpScreenPB[n] ))
    			EndIf
    			
    		EndIf	
    		
    	Else
    		Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Kein Bild in der Purebasic"+Str(StructImagePB) )
    	EndIf
    EndProcedure  
    ;
		;
    ;
    Procedure.l   Thumbnail_SetGadgetState(ThumbnailNum.i)
    	
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
    			;FreeImage( Startup::*LHImages\CPScreenPB[ThumbnailNum])
    		EndIf
    		
    	EndIf
    EndProcedure
    ;
		;
    ;    
    Procedure.l  Calc_Thumbnail1(Thumbnail = 1)
    	Protected RowID.i = Startup::*LHGameDB\GameID, Result.i
    	
    	; Geändert  Slotcontent.l to *SlotContent
    	Protected *SlotContent
    	*SlotContent = AllocateMemory(500000)
    	
    	*SlotContent = Startup::SlotShots(Thumbnail)\thumb[RowID]
    	If Not ( *SlotContent = 0 )    		    		    		
    		Result = CatchImage( Startup::*LHImages\OrScreenPB[Thumbnail], *SlotContent, MemorySize( *SlotContent ))
    		
    	EndIf
    	    		
    	If ( Result = 0 ) And ( *SlotContent = 0 )
    		CopyImage(  Startup::*LHImages\NoScreenPB[Thumbnail],  Startup::*LHImages\OrScreenPB[Thumbnail])              
    	EndIf 	
    		
    	Resize_Gadget(Thumbnail, Startup::*LHImages\OrScreenPB[Thumbnail], Startup::*LHImages\ScreenGDID[Thumbnail], #True) 
    	If Not ( *SlotContent = 0 )
    		FreeMemory( *SlotContent )
    	EndIf	
    	Thumbnail_SetGadgetState(Thumbnail)   
    EndProcedure
    ;
		;
    ;
    Procedure.l   Set_Slot( nSlotNum.i )
    	Calc_Thumbnail1(nSlotNum)
    	
    EndProcedure    
    ;
		;
    ;  
    Procedure.i   MainThread(z)
        
        If ( Startup::*LHGameDB\Images_Mutex[z] = 0 )
            Startup::*LHGameDB\Images_Mutex[z] = CreateMutex()
        EndIf    
        LockMutex( Startup::*LHGameDB\Images_Mutex[z])                
        Set_Slot( z )   
        UnlockMutex( Startup::*LHGameDB\Images_Mutex[z])
                
        ProcedureReturn z
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
; CursorPosition = 368
; FirstLine = 286
; Folding = zPA5
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = D:\NewGame\
; Debugger = IDE
; Warnings = Display
; EnablePurifier