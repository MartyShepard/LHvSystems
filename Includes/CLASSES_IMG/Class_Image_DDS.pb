;****************************************************
;*********      Miloo DDS Image Decoder      ********
;*********       Miloo King 2014.12.01       ********
;*********       QQ:714095563  - CHI -       ********
;****************************************************

;-
;- [Constants] 
;{
DeclareModule DDS
    
    #MIP_ImageFlags_DDS = $20534444 
    ; DDS共15种格式,
    #MIP_ImageFormat_DDS_DTX1       = $04156506
    #MIP_ImageFormat_DDS_DTX1A      = $04A56506
    #MIP_ImageFormat_DDS_DTX3       = $04388806
    #MIP_ImageFormat_DDS_DTX5       = $04588806
    #MIP_ImageFormat_DDS_DTX5NM     = $04F88806
    #MIP_ImageFormat_DDS_A8         = $02000806
    #MIP_ImageFormat_DDS_L8         = $01000806
    #MIP_ImageFormat_DDS_A8L8       = $01008806
    #MIP_ImageFormat_DDS_R5G6B5     = $00056506
    #MIP_ImageFormat_DDS_R8G8B8     = $00088806
    #MIP_ImageFormat_DDS_X1R5G5B5   = $00155506
    #MIP_ImageFormat_DDS_A1R5G5B5   = $01155506
    #MIP_ImageFormat_DDS_A4R4G4B4   = $01444406
    #MIP_ImageFormat_DDS_X8R8G8B8   = $00888806
    #MIP_ImageFormat_DDS_A8R8G8B8   = $01888806
    
    #MIP_ImageFormat_DDS_A8$        = "DDS:A8"
    #MIP_ImageFormat_DDS_L8$        = "DDS:L8"
    #MIP_ImageFormat_DDS_A8L8$      = "DDS:A8L8"   
    #MIP_ImageFormat_DDS_DTX1$      = "DDS:DTX1"
    #MIP_ImageFormat_DDS_DTX1A$     = "DDS:DTX1A"
    #MIP_ImageFormat_DDS_DTX3$      = "DDS:DTX3" 
    #MIP_ImageFormat_DDS_DTX5$      = "DDS:DTX5" 
    #MIP_ImageFormat_DDS_A8R8G8B8$  = "DDS:A8R8G8B8"                
    #MIP_ImageFormat_DDS_R8G8B8$    = "DDS:R8G8B8" 
    #MIP_ImageFormat_DDS_A4R4G4B4$  = "DDS:A4R4G4B4"  
    #MIP_ImageFormat_DDS_A1R5G5B5$  = "DDS:A1R5G5B5"  
    #MIP_ImageFormat_DDS_X8R8G8B8$  = "DDS:X8R8G8B8"             
    #MIP_ImageFormat_DDS_R8G8B8$    = "DDS:R8G8B8"  
    #MIP_ImageFormat_DDS_X1R5G5B5$  = "DDS:X1R5G5B5"  
    #MIP_ImageFormat_DDS_R5G6B5$    = "DDS:R5G6B5" 
    
    Declare Load(ImageID, FileName$)
    
    Global MIP_ImageFormat_DDS$ = ""
EndDeclareModule
Module DDS
    
 
    ;}    
    ;-
    ;- [Structure] 
    ;- __MPD_Pixel_BGRA
    Structure __MPD_Pixel_BGRA
        B.a
        G.a
        R.a
        A.a   
    EndStructure
    
    ;DDS图片的头部结构
    ;- __MPD_DDS_HeaderInfo
    Structure __MIP_DDS_HeaderInfo 
        ImageFlags.l      ;DDS标志 
        InfoSize.l        ;头部大小,恒为$7C,不包括ImgFlags的大小
        Format.l          ;DDS的标志
        ImageH.l          ;图片高的像素值
        ImageW.l          ;图片宽的像素值
        PixelSize.l       ;压缩标志,相当于数据大小
        Depth.l           ;纹理的深度(像素为单位)
        MapCount.l        ;MipMap的数量
        Reserved1.l[11]   ;保留值部分
        
        StructSize.l      ;Pixel结构的大小
        PixelFlags.l      ;Pixel标志,#DDPF_xxxx
        FourCC.l          ;图像的代码标志,如DTX1,DTX2
        RGBBitCount.l     ;RGB结构的大小
        RBitMask.l        ;红色的标志,如在A8R8G8B8中, 为$00ff0000.
        GBitMask.l        ;绿色的标志,如在A8R8G8B8中, 为$0000ff00.
        BBitMask.l        ;蓝色的标志,如在A8R8G8B8中, 为$000000ff.
        ABitMask.l        ;通道的标志,如在A8R8G8B8中, 为$ff000000.
        
        Caps1.l           ;纹理表面的标志.
        Caps2.l           ;纹理表面的详细信息
        Caps3.l           ;保留
        Caps4.l           ;保留
        Reserved2.l       ;保留
    EndStructure
    
    ;- __MIP_ImageInfo
    Structure __MIP_ImageInfo
        ImageFlags.l
        ImageFlags$   
        ImageID.l
        hImage.l
        ImageW.l
        ImageH.l
    EndStructure
    
    
    ;-
    ;- [Check Funcs]
    ; 获取DDS文件的类型
    Procedure MIP_CheckImageFormat(*MemData, *pImageInfo.__MIP_ImageInfo)
        MIP_ImageFormat_DDS$ = ""
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        With *pDDSHeader
            If \ImageFlags <> #MIP_ImageFlags_DDS 
                ProcedureReturn #False 
            EndIf 
            Select \PixelFlags
                Case $00002 
                    If \RGBBitCount=$08 
                        Result=#MIP_ImageFormat_DDS_A8
                        Result$ = #MIP_ImageFormat_DDS_A8$  
                    EndIf 
                Case $20000
                    If \RGBBitCount=$08
                        Result=#MIP_ImageFormat_DDS_L8
                        Result$ = #MIP_ImageFormat_DDS_L8$
                    EndIf 
                Case $20001
                    If \RGBBitCount=$10
                        Result=#MIP_ImageFormat_DDS_A8L8
                        Result$ = #MIP_ImageFormat_DDS_A8L8$
                    EndIf       
                Case $00004 ;DTX系列
                    Select \FourCC 
                        Case $31545844 
                            Result  = #MIP_ImageFormat_DDS_DTX1
                            Result$ = #MIP_ImageFormat_DDS_DTX1$ 
                            ; DTX1 分带A和不带A两种
                            Pos = *pDDSHeader\InfoSize+4
                            For Y = 0 To *pDDSHeader\ImageH/4-1
                                For X = 0 To *pDDSHeader\ImageW/4-1
                                    Color = PeekL(*MemData+Pos)  : Pos+8         
                                    If Color = $010000
                                        Result = #MIP_ImageFormat_DDS_DTX1A 
                                        Result$ = #MIP_ImageFormat_DDS_DTX1A$
                                        Break 2 
                                    EndIf 
                                Next 
                            Next  
                        Case $33545844 
                            Result = #MIP_ImageFormat_DDS_DTX3
                            Result$ = #MIP_ImageFormat_DDS_DTX3$
                        Case $35545844
                            Result = #MIP_ImageFormat_DDS_DTX5 
                            Result$ = #MIP_ImageFormat_DDS_DTX5$
                    EndSelect
                    
                Case $00041 :
                    Select \RGBBitCount
                        Case $20
                            Result=#MIP_ImageFormat_DDS_A8R8G8B8
                            Result$ = #MIP_ImageFormat_DDS_A8R8G8B8$               
                        Case $18
                            Result=#MIP_ImageFormat_DDS_R8G8B8
                            Result$ = #MIP_ImageFormat_DDS_R8G8B8$
                        Case $10 
                            If \GBitMask=$F0 
                                Result=#MIP_ImageFormat_DDS_A4R4G4B4
                                Result$ = #MIP_ImageFormat_DDS_A4R4G4B4$
                            Else
                                Result=#MIP_ImageFormat_DDS_A1R5G5B5
                                Result$ = #MIP_ImageFormat_DDS_A1R5G5B5$
                            EndIf    
                    EndSelect                  
                Case $00040 :
                    Select \RGBBitCount
                        Case $20
                            Result=#MIP_ImageFormat_DDS_X8R8G8B8
                            Result$ = #MIP_ImageFormat_DDS_X8R8G8B8$            
                        Case $18
                            Result=#MIP_ImageFormat_DDS_R8G8B8
                            Result$ = #MIP_ImageFormat_DDS_R8G8B8$ 
                        Case $10 
                            If \GBitMask=$3E0
                                Result=#MIP_ImageFormat_DDS_X1R5G5B5
                                Result$ = #MIP_ImageFormat_DDS_X1R5G5B5$ 
                            Else
                                Result=#MIP_ImageFormat_DDS_R5G6B5
                                Result$ = #MIP_ImageFormat_DDS_R5G6B5$ 
                            EndIf 
                    EndSelect
            EndSelect 
        EndWith
        *pImageInfo\ImageFlags  = Result
        *pImageInfo\ImageFlags$ = Result$
        *pImageInfo\ImageW = *pDDSHeader\ImageW
        *pImageInfo\ImageH = *pDDSHeader\ImageH
        Debug Result$
        MIP_ImageFormat_DDS$ = *pImageInfo\ImageFlags$
        ProcedureReturn Result
    EndProcedure
    
    
    ;-
    ;- [Catch Funcs]
    ;- ARGB32
    Procedure MIP_DDStoBMP32_A8R8G8B8(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 4
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS32 = *MemData + $80 + RowBytes * R
            CopyMemory_(*pBMP32, *pDDS32, RowBytes) : *pBMP32+RowBytes
        Next 
    EndProcedure
    
    Procedure MIP_DDStoBMP32_X8R8G8B8(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 4
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS32 = *MemData+$80 + RowBytes * R
            CopyMemory_(*pBMP32, *pDDS32, RowBytes) : *pBMP32+RowBytes
        Next 
        DrawingMode(#PB_2DDrawing_AlphaChannel)
        Box(0, 0, *pDDSHeader\ImageW, *pDDSHeader\ImageH, $FF000000)   
        
    EndProcedure
    
    ;-
    ;- RGB24
    Procedure MIP_DDStoBMP32_R8G8B8(*MemData)
        
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 3
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS24 = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                CopyMemory_(*pBMP32, *pDDS24, 3) : *pBMP32+4 : *pDDS24+3
            Next 
        Next 
    EndProcedure
    
    ;-
    ;- ARGB16
    Procedure MIP_DDStoBMP32_A4R4G4B4(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 2
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS16.Word = *MemData + $80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                *pBMP32\B = (*pDDS16\w>>00 & $0F) | (*pDDS16\w<<04 & $F0)
                *pBMP32\G = (*pDDS16\w>>04 & $0F) | (*pDDS16\w<<00 & $F0)
                *pBMP32\R = (*pDDS16\w>>08 & $0F) | (*pDDS16\w>>04 & $F0)
                *pBMP32\A = (*pDDS16\w>>12 & $0F) | (*pDDS16\w>>08 & $F0)
                *pBMP32+4 : *pDDS16+2
            Next 
        Next 
    EndProcedure
    
    Procedure MIP_DDStoBMP32_A1R5G5B5(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 2
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS16.word = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                *pBMP32\B = (*pDDS16\w>>02 & $07) | (*pDDS16\w<<03 & $F8)
                *pBMP32\G = (*pDDS16\w>>07 & $07) | (*pDDS16\w>>02 & $F8)
                *pBMP32\R = (*pDDS16\w>>12 & $07) | (*pDDS16\w>>07 & $F8)
                *pBMP32\A = (*pDDS16\w>>15 & $01) * $FF
                *pBMP32+4 : *pDDS16+2
            Next 
        Next 
    EndProcedure
    
    Procedure MIP_DDStoBMP32_X1R5G5B5(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 2
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS16.word = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                Color = PeekW(*pDDS16)
                *pBMP32\B = (*pDDS16\w>>02 & $07) | (*pDDS16\w<<03 & $F8)
                *pBMP32\G = (*pDDS16\w>>07 & $07) | (*pDDS16\w>>02 & $F8)
                *pBMP32\R = (*pDDS16\w>>12 & $07) | (*pDDS16\w>>07 & $F8)
                *pBMP32+4 : *pDDS16+2
            Next 
        Next 
    EndProcedure
    
    Procedure MIP_DDStoBMP32_R5G6B5(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 2
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS16.word = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                *pBMP32\B = (*pDDS16\w>>02 & $07) | (*pDDS16\w<<03 & $F8)
                *pBMP32\G = (*pDDS16\w>>09 & $03) | (*pDDS16\w>>03 & $FC)
                *pBMP32\R = (*pDDS16\w>>13 & $07) | (*pDDS16\w>>08 & $F8)
                *pBMP32+4 : *pDDS16+2
            Next 
        Next 
    EndProcedure
    
    Procedure MIP_DDStoBMP32_A8L8(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 2
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS16.byte = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                *pBMP32\B = *pDDS16\b
                *pBMP32\G = *pDDS16\b
                *pBMP32\R = *pDDS16\b : *pDDS16+1
                *pBMP32\A = *pDDS16\b : *pDDS16+1 : *pBMP32+4
            Next 
        Next 
    EndProcedure
    
    ;-
    ;- A8
    Procedure MIP_DDStoBMP32_A8(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW 
        DrawingMode(#PB_2DDrawing_AllChannels)
        Box(0, 0, *pDDSHeader\ImageW, *pDDSHeader\ImageH, $FFFFFFFF)   
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS08.byte = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                *pBMP32\A = *pDDS08\b : *pDDS08+1 : *pBMP32+4
            Next 
        Next 
    EndProcedure
    
    Procedure MIP_DDStoBMP32_L8(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32.__MPD_Pixel_BGRA = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW 
        DrawingMode(#PB_2DDrawing_AllChannels)
        Box(0, 0, *pDDSHeader\ImageW, *pDDSHeader\ImageH, $FFFFFFFF)   
        For R = *pDDSHeader\ImageH-1 To 0 Step -1
            *pDDS08.byte = *MemData+$80 + RowBytes * R
            For C = 1 To *pDDSHeader\ImageW
                *pBMP32\A = *pDDS08\b : 
                *pBMP32\A = *pDDS08\b : 
                *pBMP32\A = *pDDS08\b : 
                *pBMP32\A = *pDDS08\b : *pDDS08+1 : *pBMP32+4
            Next 
        Next 
    EndProcedure
    
    
    ;-
    ;- DTX [SUB]
    ; 从DTX格式的DDS原始数据中分离出XRGB值
    Procedure MIP_DTXGetXRGB(*MemData, *pColor)
        ; 获取原数据
        Color0 = PeekW(*MemData+0) & $FFFF       
        Color1 = PeekW(*MemData+2) & $FFFF      
        BitVal = PeekL(*MemData+4) 
        ; 解压的像素值
        *pPixel0.__MPD_Pixel_BGRA = *pColor+00
        *pPixel0\B = (Color0>>00 & $1F)*$FF/$1F
        *pPixel0\G = (Color0>>05 & $3F)*$FF/$3F 
        *pPixel0\R = (Color0>>11 & $1F)*$FF/$1F
        
        *pPixel1.__MPD_Pixel_BGRA = *pColor+04
        *pPixel1\B = (Color1>>00 & $1F)*$FF/$1F
        *pPixel1\G = (Color1>>05 & $3F)*$FF/$3F
        *pPixel1\R = (Color1>>11 & $1F)*$FF/$1F
        
        *pPixel2.__MPD_Pixel_BGRA = *pColor+08
        *pPixel2\B = (*pPixel0\B*2/3 + *pPixel1\B/3) & $FF 
        *pPixel2\G = (*pPixel0\G*2/3 + *pPixel1\G/3) & $FF 
        *pPixel2\R = (*pPixel0\R*2/3 + *pPixel1\R/3) & $FF
        
        *pPixel3.__MPD_Pixel_BGRA = *pColor+12
        *pPixel3\B = (*pPixel1\B*2/3 + *pPixel0\B/3) & $FF
        *pPixel3\G = (*pPixel1\G*2/3 + *pPixel0\G/3) & $FF 
        *pPixel3\R = (*pPixel1\R*2/3 + *pPixel0\R/3) & $FF 
        ProcedureReturn BitVal
    EndProcedure
    
    ; 从DTX格式的DDS原始数据中分离出ARGB值
    Procedure MIP_DTXGetARGB(*MemData, *pColor)
        ; 获取原数据
        Color0 = PeekW(*MemData+0) & $FFFF       
        Color1 = PeekW(*MemData+2) & $FFFF      
        BitVal = PeekL(*MemData+4) 
        ; 解压的像素值
        *pPixel0.__MPD_Pixel_BGRA = *pColor+00
        *pPixel0\B = (Color0>>00 & $1F)*$FF/$1F
        *pPixel0\G = (Color0>>05 & $3F)*$FF/$3F 
        *pPixel0\R = (Color0>>11 & $1F)*$FF/$1F
        *pPixel0\A = $FF
        
        *pPixel1.__MPD_Pixel_BGRA = *pColor+04
        *pPixel1\B = (Color1>>00 & $1F)*$FF/$1F
        *pPixel1\G = (Color1>>05 & $3F)*$FF/$3F
        *pPixel1\R = (Color1>>11 & $1F)*$FF/$1F
        *pPixel1\A = $FF
        
        If Color0 > Color1              
            *pPixel2.__MPD_Pixel_BGRA = *pColor+08
            *pPixel2\B = (*pPixel0\B*2/3 + *pPixel1\B/3) & $FF 
            *pPixel2\G = (*pPixel0\G*2/3 + *pPixel1\G/3) & $FF 
            *pPixel2\R = (*pPixel0\R*2/3 + *pPixel1\R/3) & $FF
            *pPixel2\A = $FF
            *pPixel3.__MPD_Pixel_BGRA = *pColor+12
            *pPixel3\B = (*pPixel1\B*2/3 + *pPixel0\B/3) & $FF
            *pPixel3\G = (*pPixel1\G*2/3 + *pPixel0\G/3) & $FF 
            *pPixel3\R = (*pPixel1\R*2/3 + *pPixel0\R/3) & $FF 
            *pPixel3\A = $FF
        Else
            *pPixel2.__MPD_Pixel_BGRA = *pColor+08
            *pPixel2\B = ((*pPixel0\B + *pPixel1\B)/2) & $FF 
            *pPixel2\G = ((*pPixel0\G + *pPixel1\G)/2) & $FF 
            *pPixel2\R = ((*pPixel0\R + *pPixel1\R)/2) & $FF
            *pPixel2\A = $FF
            *pPixel3.__MPD_Pixel_BGRA = *pColor+12
            *pPixel3\B = 0
            *pPixel3\G = 0
            *pPixel3\R = 0
            *pPixel3\A = 0
        EndIf 
        ProcedureReturn BitVal
    EndProcedure
    
    Procedure MIP_DTXGetAlpha(*MemData,  *pPixels.__MPD_Pixel_BGRA)
        ; 获取原数据
        Alpha1 = PeekB(*MemData+Pos) & $FF           : Pos+1   
        Alpha2 = PeekB(*MemData+Pos) & $FF           : Pos+1   
        BitVal = PeekQ(*MemData+Pos) & $FFFFFFFFFFFF : Pos+6
        *pAlpha.ascii = @Alpha.q
        If Alpha1 > Alpha2
            *pAlpha\a = Alpha1 : *pAlpha+1
            *pAlpha\a = Alpha2 : *pAlpha+1
            *pAlpha\a = (6*Alpha1+1*Alpha2+3)/7 & $FF : *pAlpha+1
            *pAlpha\a = (5*Alpha1+2*Alpha2+3)/7 & $FF : *pAlpha+1
            *pAlpha\a = (4*Alpha1+3*Alpha2+3)/7 & $FF : *pAlpha+1
            *pAlpha\a = (3*Alpha1+4*Alpha2+3)/7 & $FF : *pAlpha+1
            *pAlpha\a = (2*Alpha1+5*Alpha2+3)/7 & $FF : *pAlpha+1
            *pAlpha\a = (1*Alpha1+6*Alpha2+3)/7 & $FF : *pAlpha+1
        Else 
            *pAlpha\a = Alpha1 : *pAlpha+1
            *pAlpha\a = Alpha2 : *pAlpha+1
            *pAlpha\a = (4*Alpha1+1*Alpha2+2)/5 & $FF : *pAlpha+1
            *pAlpha\a = (3*Alpha1+2*Alpha2+2)/5 & $FF : *pAlpha+1
            *pAlpha\a = (2*Alpha1+3*Alpha2+2)/5 & $FF : *pAlpha+1
            *pAlpha\a = (1*Alpha1+4*Alpha2+2)/5 & $FF : *pAlpha+1
            *pAlpha\a = $00 : *pAlpha+1
            *pAlpha\a = $FF : *pAlpha+1
        EndIf 
        For k = 0 To 15 
            *pAlpha = @Alpha + (BitVal >> (k*3)) & %111 
            *pPixels\A = *pAlpha\a : *pPixels+4
        Next 
        
    EndProcedure
    
    ;-
    ;- DTX [Funcs]
    Procedure MIP_DDStoBMP32_DTX1(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 4
        *pColor = AllocateMemory(4*4)
        Pos = $80
        For Y = *pDDSHeader\ImageH/4-1 To 0 Step -1
            For X = 0 To *pDDSHeader\ImageW/4-1
                BitVal = MIP_DTXGetXRGB(*MemData+Pos, *pColor) : Pos+8 : K = 0 
                For Row = 3 To 0 Step -1
                    For Col = 0 To 3
                        Index = (BitVal >> K) & %11 : K+2 
                        *pDTXPixel.__MPD_Pixel_BGRA = *pColor + Index * 4
                        *pBMPPixel.__MPD_Pixel_BGRA = *pBMP32+(Y*4+Row) * RowBytes + (X*4+Col)*4
                        *pBMPPixel\R = *pDTXPixel\R
                        *pBMPPixel\G = *pDTXPixel\G
                        *pBMPPixel\B = *pDTXPixel\B
                    Next 
                Next  
            Next 
        Next  
        FreeMemory(*pColor)
    EndProcedure
    
    Procedure MIP_DDStoBMP32_DTX1A(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 4
        *pColor = AllocateMemory(4*4)
        Pos = $80
        For Y = *pDDSHeader\ImageH/4-1 To 0 Step -1
            For X = 0 To *pDDSHeader\ImageW/4-1
                BitVal = MIP_DTXGetARGB(*MemData+Pos, *pColor) : Pos+8 : K = 0 
                For Row = 3 To 0 Step -1
                    For Col = 0 To 3
                        Index=(BitVal >> K) & %11 : K+2 
                        *pDTXPixel.__MPD_Pixel_BGRA = *pColor + Index * 4
                        *pBMPPixel.__MPD_Pixel_BGRA = *pBMP32+(Y*4+Row) * RowBytes + (X*4+Col)*4
                        *pBMPPixel\R = *pDTXPixel\R
                        *pBMPPixel\G = *pDTXPixel\G
                        *pBMPPixel\B = *pDTXPixel\B
                        *pBMPPixel\A = *pDTXPixel\A
                    Next 
                Next  
            Next 
        Next  
        FreeMemory(*pColor)
    EndProcedure
    
    Procedure MIP_DDStoBMP32_DTX3(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        RowBytes = *pDDSHeader\ImageW * 4
        *pColor = AllocateMemory(4*4)
        Pos = $80
        For Y = *pDDSHeader\ImageH/4-1 To 0 Step -1
            For X = 0 To *pDDSHeader\ImageW/4-1
                Alpha = PeekQ(*MemData+Pos) : Pos+8
                BitVal = MIP_DTXGetXRGB(*MemData+Pos, *pColor) : Pos+8 : K = 0 
                For Row = 3 To 0 Step -1
                    For Col = 0 To 3
                        Index=(BitVal >> K) & %11   
                        *pDTXPixel.__MPD_Pixel_BGRA = *pColor + Index * 4
                        *pBMPPixel.__MPD_Pixel_BGRA = *pBMP32+(Y*4+Row) * RowBytes + (X*4+Col)*4
                        A = Alpha >> (K*2) & %1111
                        *pBMPPixel\R = *pDTXPixel\R
                        *pBMPPixel\G = *pDTXPixel\G
                        *pBMPPixel\B = *pDTXPixel\B
                        *pBMPPixel\A = A | A << 4
                        K+2
                    Next 
                Next 
            Next 
        Next  
        FreeMemory(*pColor)
    EndProcedure
    
    Procedure MIP_DDStoBMP32_DTX5(*MemData)
        *pDDSHeader.__MIP_DDS_HeaderInfo = *MemData
        *pBMP32 = DrawingBuffer() 
        *pColor = AllocateMemory(4*4*4)   
        RowBytes = *pDDSHeader\ImageW * 4
        Pos = $80
        For Y = *pDDSHeader\ImageH/4-1 To 0 Step -1
            For X = 0 To *pDDSHeader\ImageW/4-1
                MIP_DTXGetAlpha(*MemData+Pos,  *pColor)             : Pos+8 
                BitVal = MIP_DTXGetXRGB(*MemData+Pos, *pColor)  : Pos+8 : K = 0 
                For Row = 3 To 0 Step -1
                    For Col = 0 To 3
                        Index=(BitVal >> K) & %11   
                        *pDTXPixel.__MPD_Pixel_BGRA = *pColor + Index * 4
                        *pBMPPixel.__MPD_Pixel_BGRA = *pBMP32+(Y*4+Row) * RowBytes + (X*4+Col)*4
                        A = Alpha >> (K*2) & %1111
                        *pBMPPixel\R = *pDTXPixel\R
                        *pBMPPixel\G = *pDTXPixel\G
                        *pBMPPixel\B = *pDTXPixel\B
                        *pBMPPixel\A = *pDTXPixel\A
                        K+2
                    Next 
                Next 
            Next 
        Next  
        FreeMemory(*pColor)
    EndProcedure
    
    
    ;-
    ;- [Main Funcs]
    Procedure MIP_CatchDDSImage(ImageID, *MemData, *pImageFlags.__MIP_ImageInfo)
        
        If *pImageFlags\ImageFlags
            If ImageID = #PB_Any
                ImageID = CreateImage(#PB_Any, *pImageFlags\ImageW, *pImageFlags\ImageH, 32)
                Result  = ImageID
            Else 
                hImage  = CreateImage(ImageID, *pImageFlags\ImageW, *pImageFlags\ImageH, 32)
                Result  = hImage
            EndIf 
            If StartDrawing(ImageOutput(ImageID))
                Select *pImageFlags\ImageFlags
                    Case #MIP_ImageFormat_DDS_DTX1       : MIP_DDStoBMP32_DTX1    (*MemData) 
                    Case #MIP_ImageFormat_DDS_DTX1A      : MIP_DDStoBMP32_DTX1A   (*MemData)
                    Case #MIP_ImageFormat_DDS_DTX3       : MIP_DDStoBMP32_DTX3    (*MemData)   
                    Case #MIP_ImageFormat_DDS_DTX5       : MIP_DDStoBMP32_DTX5    (*MemData)         
                    Case #MIP_ImageFormat_DDS_DTX5NM     
                    Case #MIP_ImageFormat_DDS_A8         : MIP_DDStoBMP32_A8      (*MemData)
                    Case #MIP_ImageFormat_DDS_L8         : MIP_DDStoBMP32_L8      (*MemData)
                    Case #MIP_ImageFormat_DDS_A8L8       : MIP_DDStoBMP32_A8L8    (*MemData)
                    Case #MIP_ImageFormat_DDS_R5G6B5     : MIP_DDStoBMP32_R5G6B5  (*MemData)
                    Case #MIP_ImageFormat_DDS_R8G8B8     : MIP_DDStoBMP32_R8G8B8  (*MemData)
                    Case #MIP_ImageFormat_DDS_X1R5G5B5   : MIP_DDStoBMP32_X1R5G5B5(*MemData)
                    Case #MIP_ImageFormat_DDS_A1R5G5B5   : MIP_DDStoBMP32_A1R5G5B5(*MemData)
                    Case #MIP_ImageFormat_DDS_A4R4G4B4   : MIP_DDStoBMP32_A4R4G4B4(*MemData)
                    Case #MIP_ImageFormat_DDS_X8R8G8B8   : MIP_DDStoBMP32_X8R8G8B8(*MemData)
                    Case #MIP_ImageFormat_DDS_A8R8G8B8   : MIP_DDStoBMP32_A8R8G8B8(*MemData)
                EndSelect
                StopDrawing()
            EndIf 
        EndIf 
        ProcedureReturn Result
    EndProcedure
    
    
    Procedure MIP_LoadFileData(FileName$)
        FileID = ReadFile(#PB_Any, FileName$)
        If FileID
            DataSize = Lof(FileID)
            *MemImage = AllocateMemory(DataSize)
            ReadData(FileID, *MemImage, DataSize)
            CloseFile(FileID)
        EndIf 
        ProcedureReturn *MemImage
    EndProcedure
    
    
    Procedure Load(ImageID, FileName$)
        *MemImage = MIP_LoadFileData(FileName$)
        If *MemImage
            If MIP_CheckImageFormat(*MemImage, @ImageFlags.__MIP_ImageInfo)
                Result = MIP_CatchDDSImage(ImageID, *MemImage, @ImageFlags)
            EndIf 
            FreeMemory(*MemImage)
        EndIf 
        ProcedureReturn Result
    EndProcedure
EndModule



CompilerIf #PB_Compiler_IsMainFile
    ;-
    ;- ==============================
    ;- [Debug]
    hWindow = OpenWindow(0, 0, 0, 400, 400, "迷路DDS图像解码器 - 测试", $CA0001)
    CanvasGadget(1, 00, 00, 400, 400)
    
    StartTimer.l = GetTickCount_() 
    hImage = DDS::Load(1, "F:\Games - Modded\Stalker 1 - Clear Sky\GAMEDATA_MOD_HOMEOFHOMELSS\gamedata\textures\controller\controller_blood_01.dds")
    Debug GetTickCount_() - StartTimer
    
    If StartDrawing(CanvasOutput(1))
        ;Box(0, 0, 400, 400, $00FF80FF)
        Box(0, 0, ImageWidth(1), ImageHeight(1), 0)
        DrawingMode(#PB_2DDrawing_Transparent) 
        DrawAlphaImage(hImage, 0, 0)
        StopDrawing()
    EndIf 
    
    Repeat
        wEventID  = WindowEvent()
        WindowID  = EventWindow()
        GadgetID  = EventGadget()
        EventType = EventType() 
        MenuID    = EventMenu() 
        Select wEventID
            Case #PB_Event_CloseWindow 
                IsExitTool = #True
        EndSelect
        Delay(1)
        
    Until IsExitTool = #True
CompilerEndIf  
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 632
; FirstLine = 156
; Folding = HAAg-
; EnableAsm
; EnableUnicode
; EnableXP