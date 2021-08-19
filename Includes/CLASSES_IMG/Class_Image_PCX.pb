DeclareModule PCX    
    Declare.l Load( ImageID.l = #PB_Any, file.s = "")
    
EndDeclareModule
Module PCX
    
    Structure PCXinfoS
        ID.b
        Version.b
        Compression.b
        BitsPerPixel.b
        
        Xmin.w
        Ymin.w
        Xmax.w
        Ymax.w
        
        horDPI.w
        verDPI.w
        ColorMap.b[48]
        reserved.b
        Planes.b
        BytesPerLine.w
        PaletteInfo.w
        Width.w
        Height.w
        fillHeader.b[54]
    EndStructure
    
    
    
    Procedure.l Load( ImageID.l = #PB_Any, file.s = "")        
        Protected header.PCXinfoS, fileNr.l, result.l, *imageOutput, w.l,h.l,b.b,count.b,val.b,i.l,k.l,plane.l,countBytes.l, color.l
        Dim p.l(1,1) ; to be redimensioned                
        Dim pal.l(255)

        
        fileNr = ReadFile(#PB_Any, file)
        If fileNr
            ReadData(fileNr,header,SizeOf(header))
            With header
                If (\ID = 10) And (\Version = 5) And (\Compression = 1) And (\BitsPerPixel = 8)
                    w = \xMax-\xMin +1
                    h = \yMax-\yMin +1
                    
                    
                    FileSeek(fileNr, 128)
                    Dim p.l(w-1,h-1)
                    For k=0 To h-1
                        For plane=0 To \planes-1
                            For i=0 To w-1
                                If count<1
                                    b.b = ReadByte(fileNr)
                                    If (b & %11000000) = %11000000
                                        count = (b & %00111111)
                                        val.b = ReadByte(fileNr)
                                    Else
                                        count = 1
                                        val.b = b
                                    EndIf
                                EndIf
                                p(i,k) | ( ($FF&val)<<(plane*8) )
                                count-1
                                countBytes+1
                            Next
                            While countBytes < (\BytesPerLine)
                                ReadByte(fileNr)
                                countBytes+1
                            Wend
                            countBytes=0
                        Next
                    Next
                    
                    
                    If Not Eof(fileNr) And ReadByte(fileNr)=12 And \Planes=1
                        For i=0 To 255
                            color =  ($FF&ReadByte(fileNr))
                            color | (($FF&ReadByte(fileNr))<<8)
                            color | (($FF&ReadByte(fileNr))<<16)
                            pal(i)= color
                        Next
                        For k=0 To h-1
                            For i=0 To w-1
                                color = p(i,k)
                                p(i,k) = pal(color)
                            Next
                        Next
                    EndIf
                    
                    ;##################### ARRAY TO IMAGE #####                   
                    image = CreateImage(ImageID, w, h)
                    If image
                        
                        If ImageID = #PB_Any
                            *imageOutput = ImageOutput(image)
                        Else
                            *imageOutput = ImageOutput(ImageID)
                        EndIf 
                    
                        StartDrawing( *imageOutput )
                        For k=0 To h-1
                            For i=0 To w-1
                                Plot( i,k, p(i,k) )
                            Next
                        Next
                        StopDrawing()
                    EndIf
                    ;##########################################
                    
                EndIf
            EndWith
            CloseFile(fileNr)
        EndIf
        PCXBitsPerPixel.i = header\BitsPerPixel
        PCX_Compression.i = header\Compression        
        ProcedureReturn image
    EndProcedure   
EndModule

CompilerIf #PB_Compiler_IsMainFile
    file.s = OpenFileRequester("select file", "E:\ProjectsPureBasic\PCX\", "*.pcx|*.pcx",0)
    
    imgNr=PCX::Load(#PB_Any,file)
    If Not imgNr
        MessageRequester("fehler", file+#CRLF$+"kann nicht geladen werden.")
        End
    EndIf
    
    OpenWindow(0, 50,50,ImageWidth(imgNr)+4,ImageHeight(imgNr)+4,"PCX")
    ImageGadget(1, 2,2, 0,0, ImageID(imgNr) )
    
    Repeat
        event=WaitWindowEvent()
    Until event=#PB_Event_CloseWindow
CompilerEndIf
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 116
; FirstLine = 53
; Folding = -
; EnableAsm
; EnableUnicode
; EnableXP