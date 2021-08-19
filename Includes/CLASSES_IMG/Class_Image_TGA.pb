
;   Image type
;   #TGA_NULL   =0  ;No image data included
;   #TGA_CMAP   =1  ;Uncompressed, color-mapped image
;   #TGA_RGB    =2  ;Uncompressed, true-color image
;   #TGA_MONO   =3  ;Uncompressed, black-and-white image
;   #TGA_RLECMAP=9  ;Run-length encoded, color-mapped image
;   #TGA_RLERGB =10 ;Run-length encoded, true-color image
;   #TGA_RLEMONO=11 ;Run-length encoded, black-and-white image

DeclareModule TGA
    ;- Structures
    
    Structure TGAHEADER
        idlength.b ;ID length
        cmtype.b   ;Color map type
        imagetype.b;Image type
        cmfirstentry.w ;First entry index
        cmlength.w     ;Color map length
        cmsize.b       ;Color map entry size, in bits
        xorigin.w      ;X-origin of image
        yorigin.w      ;Y-origin of image
        width.w        ;Image width
        height.w       ;Image height
        pixeldepth.b   ;Pixel depth
        imagedescriptor.b ;Image descriptor
    EndStructure
    
    Declare.l LoadTGA_(ImageConstant.l, filename.s)
    Global TGA_Descript$   = ""
    Global TGA_DepthBits.i = -1
    Global TGA_DepthPxls.i = -1    
EndDeclareModule

Module TGA
    
    Procedure.l LoadTGA(filename.s)
        ;From FreeImage source "PluginTARGA.cpp"
        ;Loads 8/15/16/24/32-bit Targa files, ignores extended info
        
        Protected th.TGAHEADER
        Protected bgra.RGBQUAD
        Protected *dib.BITMAPINFOHEADER
        Protected *pal.RGBQUAD
        Protected file.l,idlength.l,width.l,height.l,line.l,pitch.l
        Protected bhsize.l,ncolors.l,count.l,hDIB.l,cmap.l
        Protected pixel.l,sline.l,ix.l,iy.l,rle.l
        
        ;Open the file
        file=ReadFile(#PB_Any,filename)
        If file=0
            MessageRequester("LOAD ERROR","File could not be opened")
            ProcedureReturn #False
        EndIf
        
        ;Read the tga header
        ReadData(file,th,SizeOf(TGAHEADER))
        
        ;Calculate some information
        idlength=th\idlength & 255
        If th\pixeldepth=15 ;15-bit is the same size as 16-bit
            th\pixeldepth=16
        EndIf
        width=th\width & $FFFF
        height=th\height & $FFFF
        line=((width*th\pixeldepth)+7)/8 ;BYTE-aligned width
        pitch=(((width*th\pixeldepth)+31)/32)*4 ;DWORD-aligned width
        bhsize=SizeOf(BITMAPINFOHEADER)         ;DIB info header size
        If th\pixeldepth<16                     ;8-bit, there is no 1/4-bit in tga files
            ncolors=1 << th\pixeldepth          ;256 colors in DIB
        Else
            ncolors=0 ;No DIB palette
        EndIf
        
        FileSeek(file,SizeOf(TGAHEADER)+idlength) ;Skip comment if any
        
        ;Seek past the color map if not 8-bit, cmsize is Bits per pixel
        If th\cmtype>0 And th\pixeldepth>8
            count=((th\cmsize+7)/8)*th\cmlength ;Should be BYTE-aligned
            FileSeek(file,SizeOf(TGAHEADER)+idlength+count)
        EndIf
        
        ;Allocate the DIB
        hDIB=AllocateMemory(bhsize+(ncolors*4)+(pitch*height))
        If hDIB=0
            CloseFile(file)
            MessageRequester("LOAD ERROR","Memory allocation failed")
            ProcedureReturn #False
        EndIf
        
        ;Fill in the DIB info header
        *dib=hDIB ;Pointer to DIB
        With *dib
            \biSize=SizeOf(BITMAPINFOHEADER)
            \biWidth=width
            \biHeight=height
            \biPlanes=1
            \biBitCount=th\pixeldepth
            \biCompression=#BI_RGB
            \biSizeImage=pitch*height
            \biXPelsPerMeter=0
            \biYPelsPerMeter=0
            \biClrUsed=ncolors
            \biClrImportant=0
        EndWith
        
        Select th\pixeldepth ;8/15/16/24/32-bit tga
                
            Case 8 ;8-bit tga
                
                ;Read the palette
                If th\cmtype=0 ;No color map data is included with this image
                    
                    *pal=hDIB+bhsize ;Pointer to DIB palette
                    For count=0 To ncolors-1 ;Build a greyscale palette
                        *pal\rgbBlue=count   ;blue
                        *pal\rgbGreen=count  ;green
                        *pal\rgbRed=count    ;red
                        *pal+4
                    Next
                    
                Else
                    
                    ;Allocate the color map, Number of colors*Bits per pixel/8
                    cmap=AllocateMemory((th\cmlength*(th\cmsize/8))+1)
                    If cmap=0
                        CloseFile(file)
                        MessageRequester("LOAD ERROR","Memory allocation failed")
                        ProcedureReturn #False
                    EndIf
                    
                    ReadData(file,cmap,th\cmlength*(th\cmsize/8)) ;Read the color map
                    
                    *pal=hDIB+bhsize ;Pointer to DIB palette
                    If th\cmsize=16  ;2 bytes
                        For count=th\cmfirstentry To th\cmlength-1
                            pixel=PeekW(cmap+(count*2))
                            *pal\rgbBlue=(((pixel & $001F) >> 0)*$FF)/$1F ;blue
                            *pal\rgbGreen=(((pixel & $03E0) >> 5)*$FF)/$1F;green
                            *pal\rgbRed=(((pixel & $7C00) >> 10)*$FF)/$1F ;red
                            *pal+4
                        Next
                    ElseIf th\cmsize=24 ;3 bytes
                        For count=th\cmfirstentry To th\cmlength-1
                            *pal\rgbBlue=PeekB(cmap+(count*3)) ;blue
                            *pal\rgbGreen=PeekB(cmap+(count*3)+1) ;green
                            *pal\rgbRed=PeekB(cmap+(count*3)+2)   ;red
                            *pal+4
                        Next
                    ElseIf th\cmsize=32 ;4 bytes
                        For count=th\cmfirstentry To th\cmlength-1
                            *pal\rgbBlue=PeekB(cmap+(count*4)) ;blue
                            *pal\rgbGreen=PeekB(cmap+(count*4)+1) ;green
                            *pal\rgbRed=PeekB(cmap+(count*4)+2)   ;red
                            *pal\rgbReserved=PeekB(cmap+(count*4)+3) ;alpha
                            *pal+4
                        Next
                    EndIf
                    
                    FreeMemory(cmap) ;Free the color map
                    
                EndIf
                
                ;Read the bits
                Select th\imagetype
                        
                    Case 1,3 ;TGA_CMAP=1,TGA_MONO=3
                        
                        For iy=0 To height-1 ;Read uncompressed pixels
                            sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                            ReadData(file,sline,line)
                        Next
                        
                    Case 9,11 ;TGA_RLECMAP=9,TGA_RLEMONO=11
                        
                        sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                        ix=0
                        iy=0 ;Reset
                        
                        While iy<height ;Ignore extended info
                            
                            rle=ReadByte(file) & 255 ;RLE count minus 1
                            
                            If rle>127 ;Run packet
                                
                                rle-127
                                pixel=ReadByte(file) & 255 ;Pixel index
                                
                                For count=0 To rle-1 ;Read RLE pixels
                                    PokeB(sline+ix,pixel)
                                    ix+1
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                                    EndIf
                                Next
                                
                            Else ;Raw packet
                                
                                rle+1
                                
                                For count=0 To rle-1 ;Read non-RLE pixels
                                    pixel=ReadByte(file) & 255 ;Pixel index
                                    PokeB(sline+ix,pixel)
                                    ix+1
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                                    EndIf
                                Next
                                
                            EndIf
                            
                        Wend
                        
                    Default ;Not TGA_CMAP=1,TGA_MONO=3,TGA_RLECMAP=9,TGA_RLEMONO=11
                        
                        CloseFile(file)
                        FreeMemory(hDIB)
                        MessageRequester("LOAD ERROR","Image type not supported")
                        ProcedureReturn #False
                        
                EndSelect
                
            Case 16 ;15/16-bit tga
                
                ;Read the bits
                Select th\imagetype
                        
                    Case 2 ;TGA_RGB=2
                        
                        For iy=0 To height-1 ;Read uncompressed pixels
                            sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                            For ix=0 To width-1
                                pixel=ReadWord(file)
                                PokeB(sline,pixel & $00FF)
                                PokeB(sline+1,(pixel & $FF00) >> 8)
                                sline+2 ;pixel size
                            Next
                        Next
                        
                    Case 10 ;TGA_RLERGB=10
                        
                        sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                        ix=0
                        iy=0 ;Reset
                        
                        While iy<height ;Ignore extended info
                            
                            rle=ReadByte(file) & 255 ;RLE count minus 1
                            
                            If rle>127 ;Run packet
                                
                                rle-127
                                pixel=ReadWord(file)
                                
                                For count=0 To rle-1 ;Read RLE pixels
                                    PokeB(sline+ix,pixel & $00FF)
                                    PokeB(sline+ix+1,(pixel & $FF00) >> 8)
                                    ix+2 ;pixel size
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                                    EndIf
                                Next
                                
                            Else ;Raw packet
                                
                                rle+1
                                
                                For count=0 To rle-1 ;Read non-RLE pixels
                                    pixel=ReadWord(file)
                                    PokeB(sline+ix,pixel & $00FF)
                                    PokeB(sline+ix+1,(pixel & $FF00) >> 8)
                                    ix+2 ;pixel size
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(ncolors*4)+(iy*pitch)
                                    EndIf
                                Next
                                
                            EndIf
                            
                        Wend
                        
                    Default ;Not TGA_RGB=2,TGA_RLERGB=10
                        
                        CloseFile(file)
                        FreeMemory(hDIB)
                        MessageRequester("LOAD ERROR","Image type not supported")
                        ProcedureReturn #False
                        
                EndSelect
                
            Case 24 ;24-bit tga
                
                ;Read the bits
                Select th\imagetype
                        
                    Case 2 ;TGA_RGB=2
                        
                        For iy=0 To height-1 ;Read uncompressed pixels
                            sline=hDIB+bhsize+(iy*pitch)
                            For ix=0 To width-1
                                ReadData(file,bgra,3)
                                PokeB(sline,bgra\rgbBlue) ;blue
                                PokeB(sline+1,bgra\rgbGreen) ;green
                                PokeB(sline+2,bgra\rgbRed)   ;red
                                sline+3                      ;pixel size
                            Next
                        Next
                        
                    Case 10 ;TGA_RLERGB=10
                        
                        sline=hDIB+bhsize+(iy*pitch)
                        ix=0
                        iy=0 ;Reset
                        
                        While iy<height ;Ignore extended info
                            
                            rle=ReadByte(file) & 255 ;RLE count minus 1
                            
                            If rle>127 ;Run packet
                                
                                rle-127
                                ReadData(file,bgra,3)
                                
                                For count=0 To rle-1 ;Read RLE pixels
                                    PokeB(sline+ix,bgra\rgbBlue) ;blue
                                    PokeB(sline+ix+1,bgra\rgbGreen) ;green
                                    PokeB(sline+ix+2,bgra\rgbRed)   ;red
                                    ix+3                            ;pixel size
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(iy*pitch)
                                    EndIf
                                Next
                                
                            Else ;Raw packet
                                
                                rle+1
                                
                                For count=0 To rle-1 ;Read non-RLE pixels
                                    ReadData(file,bgra,3)
                                    PokeB(sline+ix,bgra\rgbBlue) ;blue
                                    PokeB(sline+ix+1,bgra\rgbGreen) ;green
                                    PokeB(sline+ix+2,bgra\rgbRed)   ;red
                                    ix+3                            ;pixel size
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(iy*pitch)
                                    EndIf
                                Next
                                
                            EndIf
                            
                        Wend
                        
                    Default ;Not TGA_RGB=2,TGA_RLERGB=10
                        
                        CloseFile(file)
                        FreeMemory(hDIB)
                        MessageRequester("LOAD ERROR","Image type not supported")
                        ProcedureReturn #False
                        
                EndSelect
                
            Case 32 ;32-bit tga
                
                ;Read the bits
                Select th\imagetype
                        
                    Case 2 ;TGA_RGB=2
                        
                        For iy=0 To height-1 ;Read uncompressed pixels
                            sline=hDIB+bhsize+(iy*pitch)
                            For ix=0 To width-1
                                ReadData(file,bgra,4)
                                PokeB(sline,bgra\rgbBlue) ;blue
                                PokeB(sline+1,bgra\rgbGreen) ;green
                                PokeB(sline+2,bgra\rgbRed)   ;red
                                PokeB(sline+3,bgra\rgbReserved) ;alpha
                                sline+4                         ;pixel size
                            Next
                        Next
                        
                    Case 10 ;TGA_RLERGB=10
                        
                        sline=hDIB+bhsize+(iy*pitch)
                        ix=0
                        iy=0 ;Reset
                        
                        While iy<height ;Ignore extended info
                            
                            rle=ReadByte(file) & 255 ;RLE count minus 1
                            
                            If rle>127 ;Run packet
                                
                                rle-127
                                ReadData(file,bgra,4)
                                
                                For count=0 To rle-1 ;Read RLE pixels
                                    PokeB(sline+ix,bgra\rgbBlue) ;blue
                                    PokeB(sline+ix+1,bgra\rgbGreen) ;green
                                    PokeB(sline+ix+2,bgra\rgbRed)   ;red
                                    PokeB(sline+ix+3,bgra\rgbReserved) ;alpha
                                    ix+4                               ;pixel size
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(iy*pitch)
                                    EndIf
                                Next
                                
                            Else ;Raw packet
                                
                                rle+1
                                
                                For count=0 To rle-1 ;Read non-RLE pixels
                                    ReadData(file,bgra,4)
                                    PokeB(sline+ix,bgra\rgbBlue) ;blue
                                    PokeB(sline+ix+1,bgra\rgbGreen) ;green
                                    PokeB(sline+ix+2,bgra\rgbRed)   ;red
                                    PokeB(sline+ix+3,bgra\rgbReserved) ;alpha
                                    ix+4                               ;pixel size
                                    If ix>=line
                                        ix=0
                                        iy+1
                                        If iy>=height : Break : EndIf
                                        sline=hDIB+bhsize+(iy*pitch)
                                    EndIf
                                Next
                                
                            EndIf
                            
                        Wend
                        
                    Default ;Not TGA_RGB=2,TGA_RLERGB=10
                        
                        CloseFile(file)
                        FreeMemory(hDIB)
                        MessageRequester("LOAD ERROR","Image type not supported")
                        ProcedureReturn #False
                        
                EndSelect
                
        EndSelect
        
        Select th\imagetype                        
                Case 0 : TGA_Descript$   = "No image data included"
                Case 1 : TGA_Descript$   = "Uncompressed, color-mapped image"
                Case 2 : TGA_Descript$   = "Uncompressed, true-color image"
                Case 3 : TGA_Descript$   = "Uncompressed, black-and-white image"
                Case 9 : TGA_Descript$   = "Run-length encoded, color-mapped image"
                Case 10: TGA_Descript$   = "Run-length encoded, true-color image"
                Case 11: TGA_Descript$   = "Run-length encoded, black-and-white image"
        EndSelect           
        CloseFile(file) ;Close the file
        ProcedureReturn hDIB
        
    EndProcedure

    
    Procedure.l LoadTGA_(ImageConstant.l, filename.s)
        
        Protected *dib.BITMAPINFOHEADER
        Protected bits.l,hDC.l,hBitmap.l
        
        TGA_Descript$   = ""
        TGA_DepthBits.i = -1
        TGA_DepthPxls.i = -1          
        
        *dib = LoadTGA(filename)
        If *dib=0 ;Avoid errors
            ProcedureReturn #False
        EndIf
        
        bits =*dib+*dib\biSize+(*dib\biClrUsed*4) ;Pointer to bits
        
        ;Create the DDB bitmap
        hDC     = GetDC_(#Null)
        hBitmap = CreateDIBitmap_(hDC,*dib,#CBM_INIT,bits,*dib,#DIB_RGB_COLORS)
        
         If *dib\biSize
            If ImageConstant = #PB_Any
                ImageConstant = CreateImage(#PB_Any, *dib\biWidth, *dib\biHeight, 32)
                Result  = ImageConstant
            Else 
                hImage  = CreateImage(ImageConstant,  *dib\biWidth, *dib\biHeight,32)
                Result  = hImage
            EndIf 
            If StartDrawing(ImageOutput(ImageConstant))
                DrawImage(hBitmap,0,0,*dib\biWidth,*dib\biHeight)  
                
            EndIf
            StopDrawing()
            
            TGA_DepthBits.i = *dib\biBitCount
            TGA_DepthPxls.i = *dib\biClrUsed              
        EndIf
        
        FreeMemory(*dib) ;Free the DIB
        ProcedureReturn hBitmap
        
    EndProcedure
EndModule

CompilerIf #PB_Compiler_IsMainFile
    
    #ImageID = 100

    
    If OpenWindow(0,0,0,640,480,"Load TGA",#PB_Window_SystemMenu | #PB_Window_ScreenCentered) And CreateGadgetList(WindowID(0))
        ButtonGadget(0,10,10,80,20,"Open File")
        ImageGadget(1,10,50,300,300,0,#PB_Image_Border)
    EndIf
    
    Repeat
        Select WaitWindowEvent()
            Case #PB_Event_Gadget
                Select EventGadget()
                    Case 0
                        Pattern.s="All Supported Formats|*.tga"
                        filename.s=OpenFileRequester("Choose An Image File To Open","",Pattern,0)
                        If filename
                            hBitmap.l=TGA::LoadTGA_(#ImageID,filename)
                            SendMessage_(GadgetID(1),#STM_SETIMAGE,#IMAGE_BITMAP,hBitmap)
                        EndIf
                EndSelect
            Case #PB_Event_CloseWindow
                End
        EndSelect
    ForEver
CompilerEndIf  
; IDE Options = PureBasic 5.31 (Windows - x64)
; CursorPosition = 468
; FirstLine = 451
; Folding = -
; EnableAsm
; EnableUnicode
; EnableXP