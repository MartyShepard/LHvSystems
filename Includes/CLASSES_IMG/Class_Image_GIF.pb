;================================================================================================================
; Project:             Animation Gadget
;
; Author:              netmaestro
; Contributors:        Wilbert
;
; Date:                December 11, 2013
;
; Revision:            1.0.3
; Revision date:       December 30, 2013
;
; Target compiler:     PureBasic 5.21
;
; Target OS:           Microsoft Windows
;                      Mac OSX
;                      Linux                           
;                       
; License:             Free to use, modify or share
;                      NO WARRANTY expressed or implied
;
; Exported commands:   GifObjectFromBuffer(*buffer, buffersize)
;                      GifObjectFromFile(file$)
;                      FreeGifObject(*gifobject)
;                      
;                      AnimationGadget(gadget, x, y, width, height, *obj.GifObject, transparentcolor, flags=0)
;                      FreeAnimationGadget(gadget)
;
;================================================================================================================

;================================================================
;                 CODESECTION: GIF DECODER
;================================================================

DeclareModule GIF
  
  Global animationgadget_mutex
  
  Structure GIF_Frame
    frameindex.i
    image.i
    left.u
    top.u
    width.u
    height.u
    delay.u
    interlaced.i
    disposalmethod.a
    transparencyflag.a
    transparentcolor.l
  EndStructure
  
  Structure GifObject
    globaltransparency.i
    transparentcolor.i
    containerwidth.i
    containerheight.i
    backgroundcolor.i
    ColorCount.i
    framecount.i
    repeats.u
    Array Frame.GIF_Frame(0)
  EndStructure
  
  Structure GIF_HEADER_AND_LOGICAL_SCREEN_DESCRIPTOR
    HeaderBytes.a[6]
    Width.u
    Height.u
    PackedByte.a
    BackgroundColorIndex.a
    PixelAspectRatio.a
  EndStructure
  
  Structure GRAPHICS_CONTROL_EXTENSION
    Introducer.a
    Label.a
    BlockSize.a
    PackedByte.a
    DelayTime.u
    TransparentColorIndex.a
    BlockTerminator.a
  EndStructure
  
  Structure IMAGE_DESCRIPTOR
    Separator.a
    ImageLeft.w
    ImageTop.w
    ImageWidth.w
    ImageHeight.w
    PackedByte.a
  EndStructure
  
  Structure codetable Align 4
    prev.l
    color.a
    size.l
  EndStructure
  
  Structure codestream
    tblentry.codetable[4096]
  EndStructure
  
  Structure colorstream
    index.i
    color.a[0]
  EndStructure
  
  Structure colortable
    color.l[0]
  EndStructure
  
  #GIFHEADER89a      = $613938464947
  #GIFHEADER87a      = $613738464947
  #GIFHEADERMASK     = $FFFFFFFFFFFF
  #COLORTABLE_EXISTS = $80
  #LOOPFOREVER       = $00
  
  Enumeration
    #DISPOSAL_NONE
    #DISPOSAL_LEAVEINPLACE
    #DISPOSAL_FILLBKGNDCOLOR
    #DISPOSAL_RESTORESTATE
  EndEnumeration
  
  Declare.l GetBaseImage(*object.GifObject, Frame.i = 0)
  
;   Declare IsLocalColorTable(*buffer)
;   Declare IsGlobalColorTable(*buffer)
  Declare GifImageHeight(*buffer)
  Declare GifImageWidth(*buffer)
;  Declare GetBackgroundColor(*buffer)
;   Declare OutputCodeString(*ct.codestream, this_code, *stream.colorstream)
;   Declare CreateBaseImage(*object.GifObject, index=0)
;   Declare ProcessGifData(*buffer, buffersize)
  Declare GifObjectFromBuffer(*buffer, size)
  Declare GifObjectFromFile(filename$)
  Declare FreeGifObject(*object.GifObject)
;   Declare Animate(gadget)
;   Declare FreeAnimationGadget(gadget)
;   Declare AnimationGadget(Window = 9, gadget = 0, x=0, y=0, w=0, h=0, *object.GifObject=0, flags=0)
   Declare AnimationGadget(gadgetnumber=0, x=0, y=0, width=0, height=0, *animation.GifObject=0, transcolor=0, flags=0)
EndDeclareModule

Module GIF
  
  Procedure IsLocalColorTable(*buffer)
    
    Protected *ptr.IMAGE_DESCRIPTOR = *buffer
    
    If *ptr\PackedByte & #COLORTABLE_EXISTS
      ProcedureReturn  2 << (*ptr\PackedByte & 7) *3
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure IsGlobalColorTable(*gifdata)
    
    Protected *ptr.GIF_HEADER_AND_LOGICAL_SCREEN_DESCRIPTOR = *gifdata
    
    If *ptr\PackedByte & #COLORTABLE_EXISTS
      ProcedureReturn 2 << (*ptr\PackedByte & 7) * 3
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure GifImageWidth(*gifdata)
    
    Protected *ptr.GIF_HEADER_AND_LOGICAL_SCREEN_DESCRIPTOR = *gifdata
    
    ProcedureReturn *ptr\Width
  EndProcedure
  
  Procedure GifImageHeight(*gifdata)
    
    Protected *ptr.GIF_HEADER_AND_LOGICAL_SCREEN_DESCRIPTOR = *gifdata
    
    ProcedureReturn *ptr\Height
  EndProcedure
  
  Procedure GetBackgroundColor(*gifdata)
    
    Protected *ptr.GIF_HEADER_AND_LOGICAL_SCREEN_DESCRIPTOR = *gifdata
    Protected index = *ptr\BackgroundColorIndex
    Protected *readcolors.Long
    
    If IsGlobalColorTable(*ptr)
      *readcolors.Long = *gifdata + 13 + (index * 3)
      ProcedureReturn RGBA(PeekA(*readcolors),PeekA(*readcolors+1),PeekA(*readcolors+2), 255)
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure.l GetBaseImage(*obj.GifObject, Frame.i = 0)
      
      If ( *obj <> 0 )
          
          For n = 0 To *obj\framecount
              If ( n = frame )           
                ProcedureReturn *obj\Frame.GIF_Frame(n)\image
             EndIf
          Next       
      EndIf
      ProcedureReturn 0
      
  EndProcedure
  
  Procedure CreateBaseImage(*obj.GifObject, index=0)         
      ProcedureReturn CreateImage(#PB_Any, *obj\containerwidth, *obj\containerheight, 32, #PB_Image_Transparent)
  EndProcedure
  
  Procedure OutputCodeString(*ct.codestream, this_code, *stream.colorstream)
    *stream\index + *ct\tblentry[this_code]\size-1
    While *ct\tblentry[this_code]\size > 1
      *stream\color[*stream\index] = *ct\tblentry[this_code]\color
      this_code = *ct\tblentry[this_code]\prev
      *stream\index - 1
    Wend
    *stream\color[*stream\index] = *ct\tblentry[this_code]\color
    ProcedureReturn *ct\tblentry[this_code]\color
  EndProcedure
  
  Macro m_InitCodeTable
    For j=0 To clr_code-1 : *ct\tblentry[j]\color = j : *ct\tblentry[j]\size = 1 : Next
    For j=clr_code To 4095 : *ct\tblentry[j]\color=0 : *ct\tblentry[j]\prev=0 : *ct\tblentry[j]\size=0 : Next
  EndMacro
  
  Procedure ProcessGifData(*buffer, buffersize)
    
    Protected *colors.colortable  = AllocateMemory(1024)
    Protected *stream.colorstream = AllocateMemory(1024)
    Protected *ct.codestream      = AllocateMemory(SizeOf(codestream))
    
    Protected *gifobject.GifObject, *readcolors.Long, *readptr, *gcereader.GRAPHICS_CONTROL_EXTENSION
    Protected *idreader.IMAGE_DESCRIPTOR, *writeptr, *packed
    
    Protected.l codesize, offset, cur_code, mask, clr_code, next_code, prev_code, end_code, bytesleft
    Protected.i index, bytes_colortable, colorcount, extension_label, transparency, tc_index
    Protected.i morebytes, disposalmethod, repeats, thisframe, result, nextblock
    Protected.i min_codesize, totalcodebytes, nextimage
    Protected.i i, j, y, cc, k
    Protected.u delaytime
    
    If PeekQ(*buffer) & #GIFHEADERMASK <> #GIFHEADER89a And PeekQ(*buffer) & #GIFHEADERMASK <> #GIFHEADER87a
      ProcedureReturn 0 
    EndIf
    
    If PeekQ(*buffer) & #GIFHEADERMASK | #GIFHEADER89a
        Debug "#GIFHEADER89a"
    EndIf    
    
    If PeekQ(*buffer) & #GIFHEADERMASK | #GIFHEADER87a
        Debug "#GIFHEADER87a"
    EndIf 
    
    *gifobject.GifObject = AllocateMemory(SizeOf(GifObject))
    InitializeStructure(*gifobject, GifObject)
    With *gifobject
      \backgroundcolor = GetBackgroundColor(*buffer) 
      \containerheight = GifImageHeight(*buffer)     
      \containerwidth  = GifImageWidth(*buffer)      
    EndWith
    *readptr = *buffer + 13
    bytes_colortable = IsGlobalColorTable(*buffer)
    If bytes_colortable
      *readptr + bytes_colortable    
    EndIf
    Repeat
      Select PeekA(*readptr)
          
        Case $21 
          extension_label = PeekA(*readptr + 1)
          Select extension_label
            Case $F9 
              *gcereader.GRAPHICS_CONTROL_EXTENSION = *readptr
              transparency   =  *gcereader\PackedByte & 1
              disposalmethod =  (*gcereader\PackedByte & (7<<2))>>2
              delaytime.u    = *gcereader\DelayTime
              If transparency
                tc_index = *gcereader\TransparentColorIndex
              EndIf
              *readptr + SizeOf(GRAPHICS_CONTROL_EXTENSION)
              
            Case $FE, $01 
              *readptr+2
              While PeekA(*readptr)
                *readptr+1
                If *readptr >= *buffer+buffersize
                  Break
                EndIf
              Wend
              *readptr+1
              
              Case $FF
              *readptr + 2
              morebytes = PeekA(*readptr) 
              *readptr + morebytes + 1
              morebytes = PeekA(*readptr)
              repeats = PeekU(*readptr+2)
              *readptr + morebytes+1
              morebytes = PeekA(*readptr)
              While morebytes
                *readptr+morebytes+1
                morebytes = PeekA(*readptr)
              Wend
              *readptr+1
              
            Default 
              Break
              
          EndSelect
          
        Case $3B
          Break
          
        Case $2C
          thisframe = ArraySize(*gifobject\Frame())
          *gifobject\framecount + 1
          ReDim *gifobject\Frame(*gifobject\framecount)
          *gifobject\frame(thisframe)\frameindex=thisframe
          *gifobject\repeats = repeats
          *idreader.IMAGE_DESCRIPTOR = *readptr
          *readptr + SizeOf(IMAGE_DESCRIPTOR)
          With *gifobject\Frame(thisframe)
            \left       = *idreader\ImageLeft
            \top        = *idreader\ImageTop
            \width      = *idreader\ImageWidth
            \height     = *idreader\ImageHeight
            \interlaced = *idreader\PackedByte >> 6 & 1
            \delay      = delaytime * 10
            \transparencyflag = transparency
            \disposalmethod   = disposalmethod
          EndWith
          result = IsLocalColorTable(*idreader) 
          If result 
            bytes_colortable = result
            colorcount = bytes_colortable/3
            With *gifobject
                \colorcount.i = colorcount
            EndWith    
            *colors.colortable = ReAllocateMemory(*colors, (bytes_colortable/3)*4)
            *readcolors.Long = *readptr
            For i=0 To colorcount-1
              *colors\color[i] = RGBA(PeekA(*readcolors),PeekA(*readcolors+1),PeekA(*readcolors+2), 255)
              *readcolors + 3
            Next
            If *gifobject\Frame(thisframe)\transparencyflag
              *colors\color[tc_index]  &~ $FF000000 
            EndIf
            *readptr + bytes_colortable
          Else
            bytes_colortable = IsGlobalColorTable(*buffer)
            If bytes_colortable
                colorcount = bytes_colortable/3
                With *gifobject
                    \colorcount.i = colorcount
                EndWith                  
              *colors.colortable = ReAllocateMemory(*colors, (bytes_colortable/3)*4)
              *readcolors.Long = *buffer + 13
              For i=0 To colorcount-1
                *colors\color[i] = RGBA(PeekA(*readcolors),PeekA(*readcolors+1),PeekA(*readcolors+2), 255)
                *readcolors + 3
              Next
              If *gifobject\Frame(thisframe)\transparencyflag
                *colors\color[tc_index] &~ $FF000000
              EndIf
            EndIf
          EndIf
          If *gifobject\Frame(thisframe)\transparencyflag
            *gifobject\Frame(thisframe)\transparentcolor = *colors\color[tc_index]
          EndIf
          If thisframe=0 And *gifobject\Frame(0)\transparencyflag
            *gifobject\backgroundcolor = *colors\color[tc_index]
          EndIf
          *gifobject\Frame(thisframe)\image = CreateImage(#PB_Any, *gifobject\Frame(thisframe)\width, *gifobject\frame(thisframe)\height, 32, #PB_Image_Transparent)
          min_codesize   = PeekA(*readptr)
          totalcodebytes = 0
          *readptr+1
          nextblock = PeekA(*readptr)
          *packed = AllocateMemory(buffersize<<1)
          *writeptr = *packed
          While nextblock
            *readptr + 1
            CopyMemory(*readptr, *writeptr, nextblock)
            *readptr+nextblock : *writeptr+nextblock
            totalcodebytes+nextblock
            nextblock = PeekA(*readptr)
          Wend
          *packed = ReAllocateMemory(*packed, totalcodebytes)
          *stream.colorstream = ReAllocateMemory(*stream, *gifobject\frame(thisframe)\width * *gifobject\frame(thisframe)\height + SizeOf(colorstream))
          *stream\index=0
          codesize = min_codesize+1
          index=*packed : offset=0 : bytesleft=MemorySize(*packed) : mask = 1<<codesize-1
          clr_code  = 1 << min_codesize
          cur_code  = clr_code
          end_code  = clr_code + 1
          next_code = end_code 
          m_InitCodeTable
          Repeat
            prev_code = cur_code
            cur_code = (PeekL(index) & (mask<<offset))>>offset
            offset+codesize
            While offset>=8
              index+1
              bytesleft-1
              offset-8
            Wend
            If bytesleft > 0
              If cur_code <> end_code
                If cur_code <> clr_code
                  If prev_code <> clr_code
                    If cur_code <= next_code
                      If next_code < 4095
                        next_code + 1                
                        *ct\tblentry[next_code]\prev  = prev_code
                        *ct\tblentry[next_code]\color = OutputCodeString(*ct, cur_code, *stream)
                        *stream\index+*ct\tblentry[cur_code]\size
                        *ct\tblentry[next_code]\size  = *ct\tblentry[prev_code]\size + 1
                      Else
                        OutputCodeString(*ct, cur_code, *stream)
                        *stream\index+*ct\tblentry[cur_code]\size
                      EndIf
                    Else
                      next_code + 1
                      *ct\tblentry[cur_code]\prev  = prev_code
                      *ct\tblentry[cur_code]\color = OutputCodeString(*ct, prev_code, *stream)
                      *stream\index+*ct\tblentry[prev_code]\size
                      *stream\color[*stream\index] = *ct\tblentry[next_code]\color : *stream\index + 1
                      *ct\tblentry[cur_code]\size  = *ct\tblentry[prev_code]\size + 1
                    EndIf
                  Else
                    *stream\color[*stream\index]=cur_code
                    *stream\index + 1
                  EndIf
                Else
                  codesize  = min_codesize + 1
                  mask = 1 << codesize - 1
                  next_code = end_code 
                EndIf
              Else
                Break
              EndIf
            Else
              Break
            EndIf
            
            If next_code = mask And codesize < 12
              codesize + 1
              mask = 1 << codesize - 1
            EndIf
            
          ForEver
          cc=0
          StartDrawing(ImageOutput(*gifobject\Frame(thisframe)\image))
            DrawingMode(#PB_2DDrawing_AllChannels)
            If *gifobject\Frame(thisframe)\interlaced
              For k = 0 To 3
                y = 1 << (3 - k) & 7
                While y < *gifobject\Frame(thisframe)\height
                  For i=0 To *gifobject\Frame(thisframe)\width-1
                    Plot(i,y, *colors\color[*stream\color[cc]])
                    cc+1
                  Next
                  y + (2 << (3 - k) - 1) & 7 + 1
                Wend
              Next
            Else
              For j=0 To *gifobject\Frame(thisframe)\height-1
                For i=0 To *gifobject\Frame(thisframe)\width-1
                  Plot(i,j, *colors\color[*stream\color[cc]])
                  cc+1
                Next
              Next
            EndIf
          StopDrawing()
          FreeMemory(*packed)
          *readptr+1
          
        Default
          Break
          
      EndSelect
      
    ForEver
    
    ; Compose images in container & apply disposal methods
    If *gifobject\Frame(0)\transparencyflag
      *gifobject\globaltransparency = #True
      *gifobject\transparentcolor = *gifobject\Frame(0)\transparentcolor
    EndIf
    
    nextimage = CreateBaseImage(*gifobject, 0)
    For i=0 To *gifobject\framecount-1
        
      StartDrawing(ImageOutput(nextimage))
        DrawAlphaImage(ImageID(*gifobject\Frame(i)\image), *gifobject\Frame(i)\left, *gifobject\Frame(i)\top)
      StopDrawing()
      FreeImage(*gifobject\Frame(i)\image)
      *gifobject\Frame(i)\image=nextimage
      If i<*gifobject\framecount-1
        Select *gifobject\Frame(i)\disposalmethod
          Case #DISPOSAL_NONE, #DISPOSAL_LEAVEINPLACE
            nextimage = CopyImage(*gifobject\Frame(i)\image, #PB_Any)

          Case #DISPOSAL_FILLBKGNDCOLOR
            nextimage = CopyImage(*gifobject\frame(i)\image, #PB_Any)
            StartDrawing(ImageOutput(nextimage))
              DrawingMode(#PB_2DDrawing_AllChannels)
              Box(*gifobject\Frame(i)\left,*gifobject\Frame(i)\top,*gifobject\Frame(i)\width,*gifobject\Frame(i)\height, *gifobject\backgroundcolor)
            StopDrawing()

          Case #DISPOSAL_RESTORESTATE
            If *gifobject\Frame(0)\disposalmethod = #DISPOSAL_LEAVEINPLACE
              nextimage = CopyImage(*gifobject\Frame(0)\image, #PB_Any)
            Else
              nextimage = CreateBaseImage(*gifobject, i)
            EndIf
            
          Default
            If *gifobject\Frame(0)\disposalmethod = #DISPOSAL_LEAVEINPLACE
              nextimage = CopyImage(*gifobject\Frame(0)\image, #PB_Any)
            Else
              nextimage = CreateBaseImage(*gifobject, i)
            EndIf
            
        EndSelect
      EndIf
      If *gifobject\frame(i)\delay < 20
        If i<>0
          *gifobject\frame(i)\delay = 100
        EndIf
      EndIf
      If *gifobject\framecount = 1 
        *gifobject\repeats = 1
      EndIf
    Next
    
    FreeMemory(*stream)
    FreeMemory(*colors)
    FreeMemory(*ct)

    ProcedureReturn *gifobject
    
  EndProcedure
  
  Procedure.i GifObjectFromFile(file$)
    
    Protected.i buffersize, *buffer, result
    
    If ReadFile(0, file$)
      buffersize = Lof(0)
      *buffer = AllocateMemory(buffersize)
      ReadData(0, *buffer, buffersize)
      CloseFile(0)
      result = ProcessGifData(*buffer, buffersize)
      FreeMemory(*buffer)
      ProcedureReturn result
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure.i GifObjectFromBuffer(*buffer, buffersize)
    ProcedureReturn ProcessGifData(*buffer, buffersize)
  EndProcedure
  
  Procedure FreeGifObject(*object.GifObject)
    
    Protected i
    
    If *object
      For i=0 To *object\framecount-1
        If IsImage(*object\frame(i)\image)
          FreeImage(*object\frame(i)\image)
        EndIf
      Next
      ClearStructure(*object, GifObject)
      FreeMemory(*object)
    EndIf
  EndProcedure
  
  ;================================================================
  ;                 CODESECTION: ANIMATION GADGET 
  ;================================================================
  
  Structure frame
    index.i
    image.i
    delay.i
  EndStructure
  
  Structure animation
    globaltransparency.i
    transparentcolor.i
    threadid.i
    repeats.u
    List frames.frame()
  EndStructure
  
  Procedure Animate(gadgetnumber)
    
    Protected *this.animation = GetGadgetData(gadgetnumber), cc
    
    Repeat
      ForEach *this\frames()
        If IsGadget(gadgetnumber) And IsImage(*this\frames()\image)
          SetGadgetState(gadgetnumber, ImageID(*this\frames()\image))
          Delay(*this\frames()\delay)
        EndIf
      Next
      If *this\repeats
        cc + 1
        If cc > *this\repeats
          Break
        EndIf
      EndIf
    ForEver
    
  EndProcedure
  
  Procedure FreeAnimationGadget(gadgetnumber)
    
    Protected *this.animation
    
    If IsGadget(gadgetnumber)
      *this.animation = GetGadgetData(gadgetnumber)
      If *this
        If IsThread(*this\threadid)
          KillThread(*this\threadid)
          WaitThread(*this\threadid)
        EndIf
        ForEach *this\frames()
          If IsImage(*this\frames()\image)
            FreeImage(*this\frames()\image)
          EndIf
        Next
        FreeList(*this\frames())
        ClearStructure(*this, animation)
        FreeMemory(*this)
        FreeGadget(gadgetnumber)
      EndIf
    EndIf
  EndProcedure
  
  Procedure AnimationGadget(gadgetnumber=0, x=0, y=0, width=0, height=0, *animation.GifObject=0, transcolor=0, flags=0)
    
    Protected result, *this.animation, i
    
    If Not *animation
      ProcedureReturn 0
    EndIf
    
    If gadgetnumber = #PB_Any
      result = ImageGadget(gadgetnumber, x, y, width, height, 0, flags)
    Else
      ImageGadget(gadgetnumber, x, y, width, height, 0, flags)
      result = gadgetnumber
    EndIf
    *this.animation = AllocateMemory(SizeOf(animation))
    InitializeStructure(*this, animation)
    For i=0 To *animation\framecount-1
      AddElement(*this\frames())
      *this\frames()\index = *animation\frame(i)\frameindex
      *this\frames()\delay = *animation\frame(i)\delay
      *this\globaltransparency=*animation\globaltransparency
      *this\transparentcolor=*animation\transparentcolor
      *this\frames()\image = CreateImage(#PB_Any, *animation\containerwidth, *animation\containerheight, 24, transcolor)
      StartDrawing(ImageOutput(*this\frames()\image))
        DrawAlphaImage(ImageID(*animation\frame(i)\image),0,0)
      StopDrawing()
    Next
    *this\repeats = *animation\repeats
    SetGadgetData(result, *this) 
    FreeGifObject(*animation)
    *this\threadid = CreateThread(@Animate(), result)
    ProcedureReturn result
  EndProcedure
  
EndModule

;================================================================
;                END OF CODE: ANIMATION GADGET
;================================================================

CompilerIf #PB_Compiler_IsMainFile
;     CompilerIf #PB_Compiler_Thread = 0
;         MessageRequester("","Please turn threadsafe on, the gadget uses a thread!")
;         End
;     CompilerEndIf
    
    
    ;XIncludeFile "AnimationGadget.pbi"
    
 ;   UseModule GIF
    
;     Procedure TreeProc()
;         Static last=0
;         If GetGadgetState(0)<>last
;             LockMutex(animationgadget_mutex)
;             FreeAnimationGadget(1)
;             *this.GifObject = GifObjectFromFile(GetGadgetText(0))
;             w=*this\containerwidth
;             h=*this\containerheight
;             AnimationGadget(1, 210+325-w/2,100+350-h/2, 0, 0, *this, RGB(128,128,128))
;             last = GetGadgetState(0)
;             UnlockMutex(animationgadget_mutex)
;         EndIf
;     EndProcedure
;     
;     animationgadget_mutex = CreateMutex()
;     OpenWindow(0,0,0,1000,900,"",#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
;     SetWindowColor(0, RGB(128,128,128))
;     
;     ExamineDirectory(0, "K:\! Database System\Programm Archiv - All txts\", "*.gif")
;     TreeGadget(0, 10, 10, 200, 680)
;     BindGadgetEvent(0, @TreeProc(), #PB_EventType_Change)
;     While NextDirectoryEntry(0)
;         AddGadgetItem(0, -1, DirectoryEntryName(0))
;     Wend
;     FinishDirectory(0)
;     SetActiveGadget(0)
;     
;     FreeAnimationGadget(1)
;     SetGadgetState(0, 0)
;     ; *this.GifObject = GifObjectFromFile(GetGadgetText(0))
;     ; w=*this\containerwidth
;     ; h=*this\containerheight
;     AnimationGadget(1, 210+325-w/2,350-h/2, 0, 0, *this, RGB(128,128,128))
;     
;     Repeat : Until WaitWindowEvent()=#PB_Event_CloseWindow
    
;    UnuseModule GIF
    


; CompilerIf #PB_Compiler_Debugger
;   MessageRequester("","Please turn the debugger off to run these tests!")
;   ;End
; CompilerEndIf
; 
; CompilerIf #PB_Compiler_Thread = 0
;   MessageRequester("","Please turn threadsafe on, the gadget uses a thread!")
;   ;End
; CompilerEndIf
; 
; ;XIncludeFile "AnimationGadget.pbi"
; 
; UseModule GIF
; 
; InitNetwork()
; 
; Global gifready
; 
; Procedure GetNewGif(*file)
;   Debug PeekS(*file)
;   If ReceiveHTTPFile(PeekS(*file), GetTemporaryDirectory() + GetFilePart(PeekS(*file)))
;     gifready = 1
;   Else
;     gifready = 2
;   EndIf
; EndProcedure
; 
; OpenWindow(0,0,0,900,700,"Rightclick window to paste from web or drag-drop from your filesystem",#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
; StickyWindow(0,1)
; EnableWindowDrop(0, #PB_Drop_Files, #PB_Drag_Copy)
; SetWindowColor(0, RGB(128,128,128))
; CreatePopupMenu(0)
; MenuItem(1, "Paste")
; 
; Repeat 
;   ev=WaitWindowEvent()
;   
;   Select ev
;     Case #PB_Event_RightClick
;       DisplayPopupMenu(0, WindowID(0))
;       
;     Case #PB_Event_Menu
;       Select EventMenu()
;         Case 1
;           FreeAnimationGadget(1)
;           file$ = GetClipboardText()
;           If LCase(Right(file$, 4)) = ".gif"
;             *this.GifObject = GifObjectFromFile("win8_loading.gif")
;             w=*this\containerwidth
;             h=*this\containerheight
;             AnimationGadget(1, 210+325-w/2,350-h/2, 0, 0, *this, RGB(128,128,128))
;             gifready=0
;             file$ = GetClipboardText()
;             dest$ = GetTemporaryDirectory()+GetFilePart(file$)
;             CreateThread(@GetNewGif(),@file$)
;             AddWindowTimer(0, 1, 100)
;           EndIf
;       EndSelect
;       
;     Case #PB_Event_WindowDrop
;       FreeAnimationGadget(1)
;       file$ = EventDropFiles()
;       If LCase(Right(file$, 4)) = ".gif"
;         *this.GifObject = GifObjectFromFile(file$)
;         w=*this\containerwidth
;         h=*this\containerheight
;         AnimationGadget(1, 210+325-w/2,350-h/2, 0, 0, *this, RGB(128,128,128))
;       EndIf
;       
;     Case #PB_Event_Timer
;       If gifready = 1
;         FreeAnimationGadget(1)
;         If IsGadget(0):FreeGadget(0):EndIf
;         *this.GifObject = GifObjectFromFile(dest$)
;         If *this
;           w=*this\containerwidth
;           h=*this\containerheight
;           Debug *this
;           ContainerGadget(0, 40+430-w/2,350-h/2,w,h)
;           SetGadgetColor(0, #PB_Gadget_BackColor, RGB(128,128,128))
;           AnimationGadget(1, 0, 0, 0, 0, *this, RGB(128,128,128))
;           CloseGadgetList()
;         EndIf
;         RemoveWindowTimer(0,1)
;       ElseIf gifready=2
;         FreeAnimationGadget(1)
;         RemoveWindowTimer(0,1)
;       EndIf
;       
;   EndSelect
;   
; Until ev=#PB_Event_CloseWindow
; 
; UnuseModule GIF
CompilerEndIf

; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 203
; FirstLine = 144
; Folding = TGo-
; EnableThread
; EnableXP
; Executable = TestGifDecoder.exe
; EnablePurifier = 1,1,1,1