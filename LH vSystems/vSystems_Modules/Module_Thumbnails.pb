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
                        Case #True : ImageBlank = CreateImage(#PB_Any,*Memory\Width,*Memory\Height,24,*Memory\ColorBlack.l)   
                EndSelect                 
                
                If ( ImageBlank > 1 )
                    If StartDrawing( ImageOutput( ImageBlank ) )
                        
                        Select *Memory\Alpha 
                            Case #False: Box(0,0,*Memory\Width,*Memory\Height,*Memory\ColorBlack.l)                          
                        EndSelect                 
                        
                        
                        Select *Memory\Alpha 
                            Case #False: DrawingMode(#PB_2DDrawing_AlphaBlend)
                            Case #True : DrawingMode(#PB_2DDrawing_Default)
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
                        StopDrawing()
                        GrabImage(ImageBlank,*Memory\ImageID, 0, 0, *Memory\Width, *Memory\Height) 
                    EndIf
                EndIf
        EndSelect        
               
    EndProcedure
    
    Procedure.l ImageResizeEx_AddMem( *Memory.STRUCT_REZIMAGES, id.l, bs.i, rgb.l, h.i, w.i, c.i, alpha.i, level.i, slot.i)
         
        *Memory\ImageID    = id
        *Memory\BoxStyle   = bs
        *Memory\ColorBlack = rgb
        *Memory\Height     = h
        *Memory\Width      = w        
        *Memory\Center     = c
        *Memory\Alpha      = alpha
        *Memory\Level      = level
        *Memory\Slot       = slot
        *Memory\Thread     = -1
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;      
    Procedure   ImageResizeEx_Thread(Image.l, w.i, h.i, BoxStyle.i = 0, Color.l = $000000, Center.i = #False, Alpha.i = #False, Level.i = 255, Slot.i = 0)
        
        If IsImage(Image)            
            
            Select Slot
                Case 0    
                Case 1
                    *Memory01.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory01, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory01, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory01 > 0 )  
                        *Memory01\Mutex = CreateMutex()
                        
                        LockMutex( *Memory01\Mutex )   
                        *Memory01\Thread = CreateThread(@Thread_Resize(),*Memory01)
                        
                        
                        If IsThread(*Memory01\Thread)
                            WaitThread(*Memory01\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory01\Mutex  )
                    EndIf                                          
                    FreeStructure( *Memory01 )                     
                Case 2
                    *Memory02.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory02, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory02, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory02 > 0 )  
                        *Memory02\Mutex = CreateMutex()
                        
                        LockMutex( *Memory02\Mutex )   
                        *Memory02\Thread = CreateThread(@Thread_Resize(),*Memory02)
                        
                        
                        If IsThread(*Memory02\Thread)
                            WaitThread(*Memory02\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory02\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory02 )                    
                Case 3         
                    *Memory03.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory03, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory03, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory03 > 0 )  
                        *Memory03\Mutex = CreateMutex()
                        
                        LockMutex( *Memory03\Mutex )   
                        *Memory03\Thread = CreateThread(@Thread_Resize(),*Memory03)
                        
                        
                        If IsThread(*Memory03\Thread)
                            WaitThread(*Memory03\Thread,5000)
                        EndIf   
                        UnlockMutex( *Memory03\Mutex  )
                        
                    EndIf                   
                    FreeStructure( *Memory03 )                    
                Case 4
                    *Memory04.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory04, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory04, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory04 > 0 )  
                        *Memory04\Mutex = CreateMutex()
                        
                        LockMutex( *Memory04\Mutex )   
                        *Memory04\Thread = CreateThread(@Thread_Resize(),*Memory04)
                        
                        
                        If IsThread(*Memory04\Thread)
                            WaitThread(*Memory04\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory04\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory04 )                    
                Case 5
                    *Memory05.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory05, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory05, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory05 > 0 )  
                        *Memory05\Mutex = CreateMutex()
                        
                        LockMutex( *Memory05\Mutex )   
                        *Memory05\Thread = CreateThread(@Thread_Resize(),*Memory05)
                        
                        
                        If IsThread(*Memory05\Thread)
                            WaitThread(*Memory05\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory05\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory05 )                    
                Case 6
                    *Memory06.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory06, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory06, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory06 > 0 )  
                        *Memory06\Mutex = CreateMutex()
                        
                        LockMutex( *Memory06\Mutex )   
                        *Memory06\Thread = CreateThread(@Thread_Resize(),*Memory06)
                        
                        
                        If IsThread(*Memory06\Thread)
                            WaitThread(*Memory06\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory06\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory06 )                    
                Case 7
                    *Memory07.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory07, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory07, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory07 > 0 )  
                        *Memory07\Mutex = CreateMutex()
                        
                        LockMutex( *Memory07\Mutex )   
                        *Memory07\Thread = CreateThread(@Thread_Resize(),*Memory07)
                        
                        
                        If IsThread(*Memory07\Thread)
                            WaitThread(*Memory07\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory07\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory07 )                    
                Case 8
                    *Memory08.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory08, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory08, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory08 > 0 )  
                        *Memory08\Mutex = CreateMutex()
                        
                        LockMutex( *Memory08\Mutex )   
                        *Memory08\Thread = CreateThread(@Thread_Resize(),*Memory08)
                        
                        
                        If IsThread(*Memory08\Thread)
                            WaitThread(*Memory08\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory08\Mutex  )
                    EndIf      
                    FreeStructure( *Memory08 )                    
                Case 9
                    *Memory09.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory09, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory09, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory09 > 0 )  
                        *Memory09\Mutex = CreateMutex()
                        
                        LockMutex( *Memory09\Mutex )   
                        *Memory09\Thread = CreateThread(@Thread_Resize(),*Memory09)
                        
                        
                        If IsThread(*Memory09\Thread)
                            WaitThread(*Memory09\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory09\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory09 )                    
                Case 10
                    *Memory10.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory10, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory10, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory10 > 0 )  
                        *Memory10\Mutex = CreateMutex()
                        
                        LockMutex( *Memory10\Mutex )   
                        *Memory10\Thread = CreateThread(@Thread_Resize(),*Memory10)
                        
                        
                        If IsThread(*Memory10\Thread)
                            WaitThread(*Memory10\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory10\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory10 )                    
                Case 11
                    *Memory11.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory11, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory11, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory11 > 0 )  
                        *Memory11\Mutex = CreateMutex()
                        
                        LockMutex( *Memory11\Mutex )   
                        *Memory11\Thread = CreateThread(@Thread_Resize(),*Memory11)
                        
                        
                        If IsThread(*Memory11\Thread)
                            WaitThread(*Memory11\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory11\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory11 )                    
                Case 12
                    *Memory12.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory12, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory12, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory12 > 0 )  
                        *Memory12\Mutex = CreateMutex()
                        
                        LockMutex( *Memory12\Mutex )   
                        *Memory12\Thread = CreateThread(@Thread_Resize(),*Memory12)
                        
                        
                        If IsThread(*Memory12\Thread)
                            WaitThread(*Memory12\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory12\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory12 )                    
                Case 13 
                    *Memory13.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory13, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory13, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory13 > 0 )  
                        *Memory13\Mutex = CreateMutex()
                        
                        LockMutex( *Memory13\Mutex )   
                        *Memory13\Thread = CreateThread(@Thread_Resize(),*Memory13)
                        
                        
                        If IsThread(*Memory13\Thread)
                            WaitThread(*Memory13\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory13\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory13 )                    
                Case 14
                    *Memory14.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory14, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory14, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory14 > 0 )  
                        *Memory14\Mutex = CreateMutex()
                        
                        LockMutex( *Memory14\Mutex )   
                        *Memory14\Thread = CreateThread(@Thread_Resize(),*Memory14)
                        
                        
                        If IsThread(*Memory14\Thread)
                            WaitThread(*Memory14\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory14\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory14 )                    
                Case 15  
                    *Memory15.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory15, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory15, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory15 > 0 )  
                        *Memory15\Mutex = CreateMutex()
                        
                        LockMutex( *Memory15\Mutex )   
                        *Memory15\Thread = CreateThread(@Thread_Resize(),*Memory15)
                        
                        
                        If IsThread(*Memory15\Thread)
                            WaitThread(*Memory15\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory15\Mutex  )
                    EndIf
                    FreeStructure( *Memory15 )                    
                Case 16 
                    *Memory16.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory16, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory16, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory16 > 0 )  
                        *Memory16\Mutex = CreateMutex()
                        
                        LockMutex( *Memory16\Mutex )   
                        *Memory16\Thread = CreateThread(@Thread_Resize(),*Memory16)
                        
                        
                        If IsThread(*Memory16\Thread)
                            WaitThread(*Memory16\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory16\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory16 )                    
                Case 17
                    *Memory17.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory17, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory17, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory17 > 0 )  
                        *Memory17\Mutex = CreateMutex()
                        
                        LockMutex( *Memory17\Mutex )   
                        *Memory17\Thread = CreateThread(@Thread_Resize(),*Memory17)
                        
                        
                        If IsThread(*Memory17\Thread)
                            WaitThread(*Memory17\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory17\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory17 )                    
                Case 18
                    *Memory18.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory18, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory18, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory18 > 0 )  
                        *Memory18\Mutex = CreateMutex()
                        
                        LockMutex( *Memory18\Mutex )   
                        *Memory18\Thread = CreateThread(@Thread_Resize(),*Memory18)
                        
                        
                        If IsThread(*Memory18\Thread)
                            WaitThread(*Memory18\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory18\Mutex  )
                    EndIf                      
                    FreeStructure( *Memory18 )                    
                Case 19
                    *Memory19.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory19, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory19, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory19 > 0 )  
                        *Memory19\Mutex = CreateMutex()
                        
                        LockMutex( *Memory19\Mutex )   
                        *Memory19\Thread = CreateThread(@Thread_Resize(),*Memory19)
                        
                        
                        If IsThread(*Memory19\Thread)
                            WaitThread(*Memory19\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory19\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory19 )                    
                Case 20
                    *Memory20.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory20, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory20, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory20 > 0 )  
                        *Memory20\Mutex = CreateMutex()
                        
                        LockMutex( *Memory20\Mutex )   
                        *Memory20\Thread = CreateThread(@Thread_Resize(),*Memory20)
                        
                        
                        If IsThread(*Memory20\Thread)
                            WaitThread(*Memory20\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory20\Mutex  )
                    EndIf 
                    FreeStructure( *Memory20 )                    
                Case 21
                    *Memory21.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory21, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory21, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory21 > 0 )  
                        *Memory21\Mutex = CreateMutex()
                        
                        LockMutex( *Memory21\Mutex )   
                        *Memory21\Thread = CreateThread(@Thread_Resize(),*Memory21)
                        
                        
                        If IsThread(*Memory21\Thread)
                            WaitThread(*Memory21\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory21\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory21 )                    
                Case 22
                    *Memory22.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory22, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory22, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory22 > 0 )  
                        *Memory22\Mutex = CreateMutex()
                        
                        LockMutex( *Memory22\Mutex )   
                        *Memory22\Thread = CreateThread(@Thread_Resize(),*Memory22)
                        
                        
                        If IsThread(*Memory22\Thread)
                            WaitThread(*Memory22\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory22\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory22 )                    
                Case 23
                    *Memory23.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory23, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory23, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory23 > 0 )  
                        *Memory23\Mutex = CreateMutex()
                        
                        LockMutex( *Memory23\Mutex )   
                        *Memory23\Thread = CreateThread(@Thread_Resize(),*Memory23)
                        
                        
                        If IsThread(*Memory23\Thread)
                            WaitThread(*Memory23\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory23\Mutex  )
                    EndIf
                    FreeStructure( *Memory23 )                    
                Case 24
                    *Memory24.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory24, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory24, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory24 > 0 )  
                        *Memory24\Mutex = CreateMutex()
                        
                        LockMutex( *Memory24\Mutex )   
                        *Memory24\Thread = CreateThread(@Thread_Resize(),*Memory24)
                        
                        
                        If IsThread(*Memory24\Thread)
                            WaitThread(*Memory24\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory24\Mutex  )
                    EndIf
                    FreeStructure( *Memory24 )                    
                Case 25
                    *Memory25.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory25, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory25, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory25 > 0 )  
                        *Memory25\Mutex = CreateMutex()
                        
                        LockMutex( *Memory25\Mutex )   
                        *Memory25\Thread = CreateThread(@Thread_Resize(),*Memory25)
                        
                        
                        If IsThread(*Memory25\Thread)
                            WaitThread(*Memory25\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory25\Mutex  )
                    EndIf
                    FreeStructure( *Memory25 )                    
                Case 26
                    *Memory26.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory26, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory26, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory26 > 0 )  
                        *Memory26\Mutex = CreateMutex()
                        
                        LockMutex( *Memory26\Mutex )   
                        *Memory26\Thread = CreateThread(@Thread_Resize(),*Memory26)
                        
                        
                        If IsThread(*Memory26\Thread)
                            WaitThread(*Memory26\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory26\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory26 )
                Case 27
                    *Memory27.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory27, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory27, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory27 > 0 )  
                        *Memory27\Mutex = CreateMutex()
                        
                        LockMutex( *Memory27\Mutex )   
                        *Memory27\Thread = CreateThread(@Thread_Resize(),*Memory27)
                        
                        
                        If IsThread(*Memory27\Thread)
                            WaitThread(*Memory27\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory27\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory27 )                    
                Case 28
                    *Memory28.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory28, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory28, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory28 > 0 )  
                        *Memory28\Mutex = CreateMutex()
                        
                        LockMutex( *Memory28\Mutex )   
                        *Memory28\Thread = CreateThread(@Thread_Resize(),*Memory28)
                        
                        
                        If IsThread(*Memory28\Thread)
                            WaitThread(*Memory28\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory28\Mutex  )
                    EndIf                      
                    FreeStructure( *Memory28 )                    
                Case 29
                    *Memory29.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory29, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory29, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory29 > 0 )  
                        *Memory29\Mutex = CreateMutex()
                        
                        LockMutex( *Memory29\Mutex )   
                        *Memory29\Thread = CreateThread(@Thread_Resize(),*Memory29)
                        
                        
                        If IsThread(*Memory29\Thread)
                            WaitThread(*Memory29\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory29\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory29 )
                Case 30 
                    *Memory30.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory30, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory30, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory30 > 0 )  
                        *Memory30\Mutex = CreateMutex()
                        
                        LockMutex( *Memory30\Mutex )   
                        *Memory30\Thread = CreateThread(@Thread_Resize(),*Memory30)
                        
                        
                        If IsThread(*Memory30\Thread)
                            WaitThread(*Memory30\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory30\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory30 )                       
                Case 31
                    *Memory31.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory31, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory31, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory31 > 0 )  
                        *Memory31\Mutex = CreateMutex()
                        
                        LockMutex( *Memory31\Mutex )   
                        *Memory31\Thread = CreateThread(@Thread_Resize(),*Memory31)
                        
                        
                        If IsThread(*Memory31\Thread)
                            WaitThread(*Memory31\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory31\Mutex  )
                    EndIf
                    FreeStructure( *Memory31 )                       
                Case 32
                    *Memory32.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory32, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory32, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory32 > 0 )  
                        *Memory32\Mutex = CreateMutex()
                        
                        LockMutex( *Memory32\Mutex )   
                        *Memory32\Thread = CreateThread(@Thread_Resize(),*Memory32)
                        
                        
                        If IsThread(*Memory32\Thread)
                            WaitThread(*Memory32\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory32\Mutex  )
                    EndIf 
                    FreeStructure( *Memory32 )                       
                Case 33 
                    *Memory33.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory33, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory33, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory33 > 0 )  
                        *Memory33\Mutex = CreateMutex()
                        
                        LockMutex( *Memory33\Mutex )   
                        *Memory33\Thread = CreateThread(@Thread_Resize(),*Memory33)
                        
                        
                        If IsThread(*Memory33\Thread)
                            WaitThread(*Memory33\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory33\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory33 )                    
                Case 34 
                    *Memory34.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory34, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory34, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory34 > 0 )  
                        *Memory34\Mutex = CreateMutex()
                        
                        LockMutex( *Memory34\Mutex )   
                        *Memory34\Thread = CreateThread(@Thread_Resize(),*Memory34)
                        
                        
                        If IsThread(*Memory34\Thread)
                            WaitThread(*Memory34\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory34\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory34 )                    
                Case 35
                    *Memory35.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory35, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory35, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory35 > 0 )  
                        *Memory35\Mutex = CreateMutex()
                        
                        LockMutex( *Memory35\Mutex )   
                        *Memory35\Thread = CreateThread(@Thread_Resize(),*Memory35)
                        
                        
                        If IsThread(*Memory35\Thread)
                            WaitThread(*Memory35\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory35\Mutex  )
                    EndIf                   
                    FreeStructure( *Memory35 )                    
                Case 36
                    *Memory36.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory36, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory36, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory36 > 0 )  
                        *Memory36\Mutex = CreateMutex()
                        
                        LockMutex( *Memory36\Mutex )   
                        *Memory36\Thread = CreateThread(@Thread_Resize(),*Memory36)
                        
                        
                        If IsThread(*Memory36\Thread)
                            WaitThread(*Memory36\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory36\Mutex  )
                    EndIf
                    FreeStructure( *Memory36 )                    
                Case 37
                    *Memory37.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory37, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory37, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory37 > 0 )  
                        *Memory37\Mutex = CreateMutex()
                        
                        LockMutex( *Memory37\Mutex )   
                        *Memory37\Thread = CreateThread(@Thread_Resize(),*Memory37)
                        
                        
                        If IsThread(*Memory37\Thread)
                            WaitThread(*Memory37\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory37\Mutex  )
                    EndIf                    
                    FreeStructure( *Memory37 )
                Case 38
                    *Memory38.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory38, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory38, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory38 > 0 )  
                        *Memory38\Mutex = CreateMutex()
                        
                        LockMutex( *Memory38\Mutex )   
                        *Memory38\Thread = CreateThread(@Thread_Resize(),*Memory38)
                        
                        
                        If IsThread(*Memory38\Thread)
                            WaitThread(*Memory38\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory38\Mutex  )
                    EndIf
                     FreeStructure( *Memory38 )                    
                Case 39
                    *Memory39.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory39, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory39, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory39 > 0 )  
                        *Memory39\Mutex = CreateMutex()
                        
                        LockMutex( *Memory39\Mutex )   
                        *Memory39\Thread = CreateThread(@Thread_Resize(),*Memory39)
                        
                        
                        If IsThread(*Memory39\Thread)
                            WaitThread(*Memory39\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory39\Mutex  )
                    EndIf                    
                     FreeStructure( *Memory39 )
                Case 40
                    *Memory40.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory40, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory40, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory40 > 0 )  
                        *Memory40\Mutex = CreateMutex()
                        
                        LockMutex( *Memory40\Mutex )   
                        *Memory40\Thread = CreateThread(@Thread_Resize(),*Memory40)
                        
                        
                        If IsThread(*Memory40\Thread)
                            WaitThread(*Memory40\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory40\Mutex  )
                    EndIf                     
                     FreeStructure( *Memory40 )
                Case 41
                    *Memory41.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory41, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory41, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory41 > 0 )  
                        *Memory41\Mutex = CreateMutex()
                        
                        LockMutex( *Memory41\Mutex )   
                        *Memory41\Thread = CreateThread(@Thread_Resize(),*Memory41)
                        
                        
                        If IsThread(*Memory41\Thread)
                            WaitThread(*Memory41\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory41\Mutex  )
                    EndIf                    
                     FreeStructure( *Memory41 )
                Case 42
                    *Memory42.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory42, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory42, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory42 > 0 )  
                        *Memory42\Mutex = CreateMutex()
                        
                        LockMutex( *Memory42\Mutex )   
                        *Memory42\Thread = CreateThread(@Thread_Resize(),*Memory42)
                        
                        
                        If IsThread(*Memory42\Thread)
                            WaitThread(*Memory42\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory42\Mutex  )
                    EndIf
                     FreeStructure( *Memory42 )
                Case 43
                    *Memory43.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory43, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory43, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory43 > 0 )  
                        *Memory43\Mutex = CreateMutex()
                        
                        LockMutex( *Memory43\Mutex )   
                        *Memory43\Thread = CreateThread(@Thread_Resize(),*Memory43)
                        
                        
                        If IsThread(*Memory43\Thread)
                            WaitThread(*Memory43\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory43\Mutex  )
                    EndIf                      
                    FreeStructure( *Memory43 )
                    
                Case 44
                    *Memory44.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory44, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory44, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory44 > 0 )  
                        *Memory44\Mutex = CreateMutex()
                        
                        LockMutex( *Memory44\Mutex )   
                        *Memory44\Thread = CreateThread(@Thread_Resize(),*Memory44)
                        
                        
                        If IsThread(*Memory44\Thread)
                            WaitThread(*Memory44\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory44\Mutex  )
                    EndIf                      
                    FreeStructure( *Memory44 )
                    
                Case 45
                    *Memory45.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory45, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory45, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory45 > 0 )  
                        *Memory45\Mutex = CreateMutex()
                        
                        LockMutex( *Memory45\Mutex )   
                        *Memory45\Thread = CreateThread(@Thread_Resize(),*Memory45)
                        
                        
                        If IsThread(*Memory45\Thread)
                            WaitThread(*Memory45\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory45\Mutex  )
                    EndIf  
                    FreeStructure( *Memory45 )
                    
                Case 46
                    *Memory46.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory46, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory46, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory46 > 0 )  
                        *Memory46\Mutex = CreateMutex()
                        
                        LockMutex( *Memory46\Mutex )   
                        *Memory46\Thread = CreateThread(@Thread_Resize(),*Memory46)
                        
                        
                        If IsThread(*Memory46\Thread)
                            WaitThread(*Memory46\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory46\Mutex  )
                    EndIf                   
                    
                    FreeStructure( *Memory46 )
                Case 47
                    *Memory47.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory47, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory47, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory47 > 0 )  
                        *Memory47\Mutex = CreateMutex()
                        
                        LockMutex( *Memory47\Mutex )   
                        *Memory47\Thread = CreateThread(@Thread_Resize(),*Memory47)
                        
                        
                        If IsThread(*Memory47\Thread)
                            WaitThread(*Memory47\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory47\Mutex  )
                    EndIf                   
                    
                    FreeStructure( *Memory47 )
                Case 48
                    *Memory48.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory48, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory48, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory48 > 0 )  
                        *Memory48\Mutex = CreateMutex()
                        
                        LockMutex( *Memory48\Mutex )   
                        *Memory48\Thread = CreateThread(@Thread_Resize(),*Memory48)
                        
                        
                        If IsThread(*Memory48\Thread)
                            WaitThread(*Memory48\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory48\Mutex  )
                    EndIf                   
                    
                    FreeStructure( *Memory48 )
                Case 49
                    *Memory49.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory49, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory49, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory49 > 0 )  
                        *Memory49\Mutex = CreateMutex()
                        
                        LockMutex( *Memory49\Mutex )   
                        *Memory49\Thread = CreateThread(@Thread_Resize(),*Memory49)
                        
                        
                        If IsThread(*Memory49\Thread)
                            WaitThread(*Memory49\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory49\Mutex  )
                    EndIf                     
                    
                    FreeStructure( *Memory49 )
                Case 50
                    *Memory50.STRUCT_REZIMAGES       = AllocateStructure( STRUCT_REZIMAGES)
                    InitializeStructure ( *Memory50, STRUCT_REZIMAGES)
                                                           
                    ImageResizeEx_AddMem( *Memory50, Image, BoxStyle, Color, h, w, Center, alpha, level, Slot)
                    
                    If ( *Memory50 > 0 )  
                        *Memory50\Mutex = CreateMutex()
                        
                        LockMutex( *Memory50\Mutex )   
                        *Memory50\Thread = CreateThread(@Thread_Resize(),*Memory50)
                        
                        
                        If IsThread(*Memory50\Thread)
                            WaitThread(*Memory50\Thread,5000)
                        EndIf
                        UnlockMutex( *Memory50\Mutex  )                                                
                    EndIf                      
                    
                    FreeStructure( *Memory50 )
            EndSelect                
        EndIf  

        

        
;         *ImagesResize.STRUCT_REZIMAGES       = AllocateStructure(STRUCT_REZIMAGES) 
;         InitializeStructure(*ImagesResize, STRUCT_REZIMAGES)          
;         Protected ResizeThread
;         If IsImage(ImageID.l)
;             

; 
;             *ImagesResize\ImageID    = ImageID.l
;             *ImagesResize\BoxStyle   = BoxStyle
;             *ImagesResize\ColorBlack = Color
;             *ImagesResize\Height     = h
;             *ImagesResize\Width      = w        
;             *ImagesResize\Center     = Center 
;             *ImagesResize\Alpha      = Alpha
;             *ImagesResize\Level      = Level
            
;              Startup::*LHGameDB\Images_Thread[4] = CreateThread(@Thread_Resize(),*ImagesResize)
;              If IsThread(Startup::*LHGameDB\Images_Thread[4])
;                  WaitThread(Startup::*LHGameDB\Images_Thread[4],5000)
;              EndIf 
;                        Thread_Resize(*ImagesResize)
             
;         EndIf

        
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
            
             Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])          
            
            ;
            ; Das Bild im Aspekt Ration Verhältnis an die Gadgets Anpassen
                If ( Resize = #True )                 
                    ImageResizeEx_Thread(Startup::*LHImages\CpScreenPB[n],PbGadget_w,PbGadget_h, 1, GetGadgetColor(DC::#Contain_10,#PB_Gadget_BackColor) ,#True, #True, 255, n) 
                    Delay(25)
                EndIf               
            ;
            ; Das Neue Bild in die Structure Koieren           
            Startup::*LHImages\CpScreenID[n]  = ImageID(Startup::*LHImages\CpScreenPB[n])        
        Else
            Request::SetDebugLog("Debug Modul: " + #PB_Compiler_Module + " #LINE:" + Str(#PB_Compiler_Line) + "#"+#TAB$+" Kein Bild in der Purebasic"+Str(StructImagePB) )
        EndIf
    EndProcedure  
    ;*******************************************************************************************************************************************************************
    ;
    Procedure   Thumbnail_SetGadgetState(ThumbnailNum.i)
        
        ;Delay(2)
        Debug "SetGadgetState " + Str( ThumbnailNum )
        SetGadgetState(Startup::*LHImages\ScreenGDID[ThumbnailNum], -1)                
        SetGadgetState(Startup::*LHImages\ScreenGDID[ThumbnailNum], Startup::*LHImages\CpScreenID[ThumbnailNum])  
        
        ; Get information about the image 
        GetObject_(ImageID(Startup::*LHImages\NoScreenPB[ThumbnailNum]), SizeOf(BITMAP), @bmp.BITMAP) 
        
        With bmp             
            Debug "Slot           :" + Str( ThumbnailNum )
            Debug "\bmWidth       :" + Str( \bmWidth) 
            Debug "\bmHeight      :" + Str( \bmHeight)
            Debug "\bmWidthBytes  :" + Str( \bmWidthBytes)
            Debug "\bmBitsPixel   :" + Str( \bmBitsPixel)
            Debug "\bmBits        :" + Str( \bmBits)
            Debug "----------------------------------------"               
        EndWith
        
    EndProcedure
    ;*******************************************************************************************************************************************************************
    ;
     Procedure  Thumbnail_UseDefaultImage(ThumbnailNum.i)

         ;Delay(2)
         Debug "Resize_Gadget " + Str( ThumbnailNum )
         
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
; CursorPosition = 114
; FirstLine = 57
; Folding = -4AAAAAAAA--
; EnableAsm
; EnableXP
; UseMainFile = ..\vOpt.pb
; CurrentDirectory = ..\Release\
; Debugger = IDE
; Warnings = Display
; EnablePurifier