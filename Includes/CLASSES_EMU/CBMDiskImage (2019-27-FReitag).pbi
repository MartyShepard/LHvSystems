DeclareModule CBMDiskImage
  
  ; Purebasic CBM DiskImage Tools
  ; Engine Adapted from DiskImagery64 (Diskimage Source v0.95) 
  ;
  ; http://lallafa.de/blog/c64-projects/diskimagery64/
  ; https://sourceforge.net/p/diskimagery64/code/HEAD/tree/
  ;
  ; Features & todo
  ; Supportet D64, D71, D81
  ; Directory Show with C64 Font Support
  ; Listing: Opional Show *DEL Files
  ; Create Disk Images (Scratch)
  ; Write CBM Files from Images to HD (Support Pc64 *.P00,*.S00, *.U00 )
  ; Disk Bam View
  ; D64: Support Sector Error Info Format Track & Extended Tracks (40)
  ; D64: Support DosType version 2A, 4A, 2P
  ; D71: Support Sector Error Info Format Track
  
  
  Enumeration
    #D64 = 1
    #D71
    #D80
    #D81
    #D82
  EndEnumeration
  
  
  Structure FileList
    C64File.s
    C64Type.s 
    C64Size.c
  EndStructure
  NewList CBMDirectoryList.FileList()
  
  Structure LastError
    s.s{255}
  EndStructure
  *er.LastError = AllocateMemory(SizeOf(LastError))
  
  Declare.i N(ImageFile$ = "", Title$ = "testdisk", DiskID$ = "id", Format.i = #D64 , ExTracks.i = 0, DOSType = 0) ; Create a new Disk Image
  Declare.i C(ImageFile$ = "", DIR$ = "", FN$ = "", CopyTo$ = "HD", SaveConversion.i = 0)                          ; Copy a File from DiskImage to PC Drive:\Path
  
  Declare.s CBM_Load_Directory(DiskImage$)                                                                      ; Show Directory
  Declare.s CBM_Disk_Image_Tools(DiskImage$, Selection.s = "title")                                             ; Additional Tools
  Declare.i CBM_Test_Full_Info(DiskImage$, HidePattern$ = "")                                                   ; Tester  
  
EndDeclareModule

Module CBMDiskImage
  
  EnableExplicit
  
  Structure BSect
    Sector.a
    Used.i
  EndStructure   
  
  Structure BTrck
    Number.a
    IsFree.a
    MaxSector.i
    BlockStart.i
    List Sector.BSect()
  EndStructure 
  
  Structure BlockAvailabilityMap
    List Track.BTrck()
  EndStructure    
  
  Global NewList BAM.BlockAvailabilityMap()
  
  
  Structure TrackSector
    track.a
    sector.a
  EndStructure
  
  Structure Rawname
    c.a[16]
  EndStructure
  
  Structure GEOS_Location
    c.a[6]
  EndStructure
  
  Structure Image
    b.b
  EndStructure
  
  Structure CharBuffer
    c.a[0]
  EndStructure
  
  Structure offset
    c.a[0]
  EndStructure    
  
  Structure SavePattern
    s.s
    o.s
    a.a
  EndStructure 
  
  Structure DebugModes
    write_info.i       
  EndStructure 
  
  Structure Diskimage
    filename.s
    filepath.s
    size.i
    Type.i
    *image     
    bam.TrackSector
    bam2.TrackSector
    dir.TrackSector
    openfiles.i
    blocksfree.i
    modified.i
    status.i
    interleave.i
    statusts.TrackSector 
    pattern.SavePattern
    SizeOffset.i
    DebugInfo.DebugModes
  EndStructure
  
  Structure  Rawdirentry
    ;     OFF1: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F -------------------
    ;           00 00 82 09 0C 52 49 43 4B 20 44 41 4E 47 52 2B : .....RICK DANGR+
    ;     	          |  |  |  |
    ;     			  |  |  |  |______________________________16 character filename
    ;     			  |  |  |
    ;     			  |  |  |
    ;     			  |  |  |
    ;     			  |  Track/sector location of first sector of file
    ;     			  |
    ;     	          File type (Look below For Bits)
    ;     	  
    ;     OFF2: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F -------------------
    ;           33 2F 50 41 4E 00 00 00 00 00 00 00 00 00 A2 00 : 3/PAN...........
    ;     	  |               |  |  |  |              |  |  |
    ;     	  |               |  |  |  |              |  |  |
    ;     	  |               |  |  |  |              |  |  |
    ;     	  |               |  |  |  |              |  |File Size ($1E+$1F*256)
    ;     	  |               |  |  |  |              |
    ;     	  |               |  |  |  |______________GEOS Only
    ;     	  |               |  |  |
    ;     	  |               |  |  |REL file record length
    ;     	  |               |  |
    ;     	  |               |T/S location of First Side-sector block (REL file only)
    ;     	  |
    ;         |____________16 character filename (05 - 14) 
    ;
    nextts.TrackSector          ; 00-01: Track/Sector location of next directory sector ($00 $00 if NOT the first entry IN the sector)
    type.a                      ;    02: File type.          
    startts.TrackSector         ; 03-04: Track/sector location of first sector of file
    rawname.Rawname             ; 05-14: 16 character filename (in PETASCII, padded with $A0)
    relsidets.TrackSector       ; 15-16: Track/Sector location of first side-sector block (REL file only)
    relrecsize.a                ;    17: REL file record length (REL file only, max. value 254)
    GEOS_Location.GEOS_Location ; 18-1D: Unused (except with GEOS disks) 
    sizelo.a                    ; 1E-1F: File size IN sectors, low/high byte  order  ($1E+$1F*256).
    sizehi.a                    ; The approx. filesize in bytes is <= #sectors * 254
                                ;replacetemp.TrackSector     ;        
  EndStructure
  
  Structure  ImageFile
    *diskimage.Diskimage
    *rawdirentry.Rawdirentry         
    mode.s
    position.i
    ts.TrackSector
    nextts.TrackSector         
    *buffer.offset
    bufptr.i
    buflen.i        
    List FileList.FileList()
  EndStructure 
  
  Structure UnsignedChar
    a.a[0]      
    b.b[0]
    c.c[0]       
  EndStructure 
  
  Structure UnsignedCharFormat
    b.a[0]
  EndStructure 
  
  Structure char
    c.a[255]
  EndStructure
  
  Structure char32
    c.a[32]
  EndStructure
  
  Structure ptoa
    c.a[16]
  EndStructure
  
  Structure rawpattern
    c.a[16]
  EndStructure   
  
  Structure CharID
    c.a[2]
  EndStructure  
  
  Structure ByteArrayStructure
    c.a[0]
  EndStructure  
  
  Structure ByteArray4096
    b.a[4096]
  EndStructure      
  
  ;---------------------------------------------------------------------------------------------------------
  ; /* Read Disk Image File
  ;---------------------------------------------------------------------------------------------------------     
  Macro LoadCBMFile(diFileName, diFileSize)
    
    *infile = AllocateMemory(diFileSize)
    
    Define DiskImage = OpenFile( #PB_Any, diFileName,#PB_File_SharedRead|#PB_File_SharedWrite)
    If DiskImage
      While Not Eof( DiskImage )             
        ReadData(DiskImage, *infile, diFileSize)
      Wend
      CloseFile(DiskImage)
    EndIf
  EndMacro    
  ;---------------------------------------------------------------------------------------------------------
  ; /* Read Disk Image File
  ;---------------------------------------------------------------------------------------------------------     
  Macro LoadDiskImage(diFileName, diFileSize)
    
    *di\image = AllocateMemory(diFileSize, #PB_Memory_NoClear)
    
    Define DiskImage = OpenFile(#PB_Any, diFileName, #PB_File_SharedRead|#PB_File_SharedWrite)
    If DiskImage
      ReadData(DiskImage, *di\image, diFileSize)
      CloseFile(DiskImage)
    EndIf
  EndMacro
  ;---------------------------------------------------------------------------------------------------------
  ; /* Save Directory in List
  ;---------------------------------------------------------------------------------------------------------     
  Macro LoadC64List(SourceList, DestList)
    CopyList(SoureList, DestList)
  EndMacro
  ;---------------------------------------------------------------------------------------------------------
  ; /* Save Directory in List
  ;---------------------------------------------------------------------------------------------------------    
  Macro SetError(sText)                        
    CBMDiskImage::*er\s = sText + #CRLF$ +
                          "Error: " + Str(#PB_Compiler_Line) + " in " +  #PB_Compiler_Module
    ProcedureReturn -1
  EndMacro
  ;---------------------------------------------------------------------------------------------------------
  ; /* Get File Type PC64
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.i Filetype_GetP00(Filename$)
    
    Protected Pattern$, FileTypeNum = -1, sFileType.s, i.i
    
    Pattern$ = UCase( GetExtensionPart( Filename$ ) )
    For i = 0 To 98
      
      If ( FindString( Pattern$ , LSet( Str(i), 2, "0" ) ,1) >= 1 )
        FileTypeNum = i
        Break
      EndIf
    Next i
    
    sFileType =  LSet( Str(FileTypeNum), 2, "0" )
    Select Pattern$
      Case "D"+sFileType:ProcedureReturn 0 
      Case "S"+sFileType:ProcedureReturn 1
      Case "P"+sFileType:ProcedureReturn 2
      Case "U"+sFileType:ProcedureReturn 3
      Case "R"+sFileType:ProcedureReturn 4
    EndSelect                
    ProcedureReturn  -1
    
  EndProcedure    
  ;---------------------------------------------------------------------------------------------------------
  ; /* Get File Type /string
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i Filetype_Set(Filename$)
    Protected  a.i, c.c, Pattern$
    
    Pattern$ = GetExtensionPart( Filename$ )        
    
    For a = 0 To Len( Pattern$ )
      c = Asc( Mid( Pattern$, a, 1) )
      
      If c = '*'
        Pattern$ = ReplaceString(Pattern$, "*","") 
      ElseIf  c = '<'
        Pattern$ = ReplaceString(Pattern$, "<","") 
      EndIf
    Next a
    
    Select UCase( Pattern$ )
      Case "DEL":ProcedureReturn 0 
      Case "SEQ":ProcedureReturn 1
      Case "PRG":ProcedureReturn 2
      Case "USR":ProcedureReturn 3
      Case "REL":ProcedureReturn 4
      Case "CBM":ProcedureReturn 5
      Case "DIR":ProcedureReturn 6
      Default
        ProcedureReturn -1
    EndSelect       
  EndProcedure       
  ;---------------------------------------------------------------------------------------------------------
  ; /* Get File Type /string
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.s Filetype_Get(type)
    
    Select type
      Case 0:ProcedureReturn "DEL"
      Case 1:ProcedureReturn "SEQ"
      Case 2:ProcedureReturn "PRG"
      Case 3:ProcedureReturn "USR"                               
      Case 4:ProcedureReturn "REL"
      Case 5:ProcedureReturn "CBM"                                 
      Case 6:ProcedureReturn "DIR"                                                               
      Default
        ProcedureReturn "???"
    EndSelect       
  EndProcedure       
  ;---------------------------------------------------------------------------------------------------------
  ; /* Get File Type
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i Filetype(type)
    
    
    Select type
      Case 0:ProcedureReturn 0; ftype = "del"
      Case 1:ProcedureReturn 1; ftype = "seq"
      Case 2:ProcedureReturn 2; ftype = "prg"
      Case 3:ProcedureReturn 3; ftype = "usr"                               
      Case 4:ProcedureReturn 4; ftype = "rel"
      Case 5:ProcedureReturn 5; ftype = "cbm"                                 
      Case 6:ProcedureReturn 6; ftype = "dir"                                                               
    EndSelect
    
  EndProcedure       
  ;*********************************************************************************************************
  ;   
  ;_________________________________________________________________________________________________________
  Procedure.s ptoa_CompatibilityMode(FileStream$, sReplacer$ = "-")        
    
    Protected NewFileName$, asci.i, i.i
    
    For i = 1 To Len(FileStream$)
      
      asci = Asc( Mid(FileStream$,i,1) )
      Select asci
        Case  34: NewFileName$ + sReplacer$   ; "
        Case  42: NewFileName$ + "(Asterisk)" ; *
        Case  47: NewFileName$ + sReplacer$   ; /
        Case  58: NewFileName$ + sReplacer$   ; :
        Case  60: NewFileName$ + "(Less-Than)"; <
        Case  62: NewFileName$ + sReplacer$   ; >
        Case  63: NewFileName$ + sReplacer$   ; ?
        Case  92: NewFileName$ + sReplacer$   ; \
        Case 127: NewFileName$ + sReplacer$   ; DEL
        Default
          NewFileName$ + Chr(asci)
      EndSelect
    Next
    
    ProcedureReturn NewFileName$
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Convert CBM Ascii 128+ to Readable
  ;---------------------------------------------------------------------------------------------------------
  Procedure.s ptou_back(sText$)
    
    Protected  *c.rawname, c.c, i.i
    
    *c = AllocateMemory(16)
    PokeS(*c, sText$, 16, #PB_Ascii)
    
    
    For i = 0 To 15
      c = *c\c[i]
      
      If c >= 'A' And c <= 'Z'
        c + 32
      ElseIf c >= 'a' And c <= 'z'
        c - 32            
      EndIf
      
      *c\c[i] = c
    Next    
    
    sText$ = PeekS(*c, 16, #PB_Ascii)
    ProcedureReturn  sText$
  EndProcedure      
  ;---------------------------------------------------------------------------------------------------------
  ; Convert CBM Ascii 128+ to Readable
  ;---------------------------------------------------------------------------------------------------------
  Procedure.s ptou(sText$)
    
    Protected  *c.rawname, c.c, i.i
    
    *c = AllocateMemory(16)
    PokeS(*c, sText$, 16, #PB_Ascii)
    
    
    For i = 0 To 15
      c = *c\c[i]
      
      If c >= 'A' And c <= 'Z'
        c + 32
      ElseIf c >= 'a' And c <= 'z'
        c - 32            
      ElseIf c >= 128
        c - 128
      EndIf
      
      *c\c[i] = c
    Next    
    
    sText$ = PeekS(*c, 16, #PB_Ascii)
    ProcedureReturn  sText$
  EndProcedure    
  ;---------------------------------------------------------------------------------------------------------
  ; /* convert Ascii to Pet */
  ;---------------------------------------------------------------------------------------------------------   
  Procedure atop( *c.rawname, Lenght.i)
    
    Protected c.a, i.i
    
    For i = 0 To Lenght-1
      c = *c\c[i]            
      
      c & $7f
      If c >= 'A' And c <= 'Z'
        c + 32
      ElseIf c >= 'a' And c <= 'z'            
        c - 32          
      EndIf
      *c\c[i] = c        
    Next i
    
  EndProcedure    
  ;---------------------------------------------------------------------------------------------------------
  ; /* convert Pet to Ascii */
  ;---------------------------------------------------------------------------------------------------------       
  Procedure ptoa(*c.rawname, DefLen = 15)
    
    Protected c.a, i.i
    
    For i = 0 To DefLen
      c = *c\c[i]
      
      If c = 0
        Break
      EndIf
      
      c & $7f
      
      If c >= 'A' And c <= 'Z'
        c + 32
      ElseIf c >= 'a' And c <= 'z'
        c - 32
      ElseIf c = $7f
        c = $3f                           
      EndIf
      *c\c[i] = c
    Next i   
  EndProcedure   
  ;---------------------------------------------------------------------------------------------------------
  ; /* convert to rawname */
  ;---------------------------------------------------------------------------------------------------------       
  
  Procedure.i di_rawname_from_name(*rawname.Rawname, *name.Rawname)
    
    Protected i.i, x.i, c.a
    
    FillMemory( *rawname, 16, $a0)  
    
    x = 0
    For i = 0 To 15
      c = *name\c[i]
      If c ! 0
        x + 1
      EndIf
    Next i    
    CopyMemory( *name, *rawname, x)       
  EndProcedure   
  ;---------------------------------------------------------------------------------------------------------
  ; /* convert from rawname */
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.i di_name_from_rawname(*name.rawname, *rawname.Rawname)
    
    Protected TitleLenght.i, s.s
    
    For TitleLenght = 0 To 15
      If *rawname\c[TitleLenght] = $a0
        Break
      EndIf
      *name\c[TitleLenght] = *rawname\c[TitleLenght]               
      
    Next TitleLenght
    ; *name\c[TitleLenght] = 0       
    
    ProcedureReturn TitleLenght       
    
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ; /* return number of tracks for image type *
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i set_status(*di.DiskImage, status.i, track.i, sector.i)       
    *di\status          = status
    *di\statusts\track  = track     
    *di\statusts\sector = sector
    ProcedureReturn status       
  EndProcedure   
  ;---------------------------------------------------------------------------------------------------------
  ; /* return write interleave */
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i interleave(Type.i)
    Select Type
      Case #D64 : ProcedureReturn 10
      Case #D71 : ProcedureReturn 6
      Case #D81 : ProcedureReturn 1
      Case #D80 : ProcedureReturn 3
      Case #D82 : ProcedureReturn 3
      Default   : ProcedureReturn 1
    EndSelect
  EndProcedure 
  
  ;---------------------------------------------------------------------------------------------------------
  ; /* return number of tracks for image type *
  ;--------------------------------------------------------------------------------------------------------- 
  Procedure.i di_tracks(*di.DiskImage)
    
    Protected Tracks.i
    
    
    Select *di\Type
        
      Case #D64
        Select *di\size
          Case 174848, 175531 : Tracks = 35
          Case 196608, 197376 : Tracks = 40
          Case 205312, 206114 : Tracks = 42 
        EndSelect  
        
      Case #D71 : Tracks = 70
        
      Case #D81 : Tracks = 80 
        
      Case #D80 : Tracks = 77
        
      Case #D82 : Tracks = 154                 
        
    EndSelect
    
    ProcedureReturn Tracks
    
  EndProcedure 
  ;---------------------------------------------------------------------------------------------------------
  ; /* return disk geometry for track */
  
  
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i di_sectors_per_track(*di.DiskImage, track.i)
    
    Protected Sectors.i
    
    
    Select *di\Type
      Case #D64
        ;   Track #Sect #SectorsIn D64 Offset   Track #Sect #SectorsIn D64 Offset
        ;   ----- ----- ---------- ----------   ----- ----- ---------- ----------
        ;     1     21       0       $00000      21     19     414       $19E00
        ;     2     21      21       $01500      22     19     433       $1B100
        ;     3     21      42       $02A00      23     19     452       $1C400
        ;     4     21      63       $03F00      24     19     471       $1D700
        ;     5     21      84       $05400      25     18     490       $1EA00
        ;     6     21     105       $06900      26     18     508       $1FC00
        ;     7     21     126       $07E00      27     18     526       $20E00
        ;     8     21     147       $09300      28     18     544       $22000
        ;     9     21     168       $0A800      29     18     562       $23200
        ;    10     21     189       $0BD00      30     18     580       $24400
        ;    11     21     210       $0D200      31     17     598       $25600
        ;    12     21     231       $0E700      32     17     615       $26700
        ;    13     21     252       $0FC00      33     17     632       $27800
        ;    14     21     273       $11100      34     17     649       $28900
        ;    15     21     294       $12600      35     17     666       $29A00
        ;    16     21     315       $13B00      36(*)  17     683       $2AB00
        ;    17     21     336       $15000      37(*)  17     700       $2BC00
        ;    18     19     357       $16500      38(*)  17     717       $2CD00
        ;    19     19     376       $17800      39(*)  17     734       $2DE00
        ;    20     19     395       $18B00      40(*)  17     751       $2EF00
        Select track
          Case  1 To 17: Sectors = 21 
          Case 18 To 24: Sectors = 19    
          Case 25 To 30: Sectors = 18
          Case 31 To 42: Sectors = 17                           
            ; 36 -> 40 xtended Track
        EndSelect
        
      Case #D71
        ;
        ;   Track #Sect #SectorsIn D71 Offset    Track #Sect #SectorsIn D71 Offset
        ;   ----- ----- ---------- ----------    ----- ----- ---------- ----------
        ;     1     21       0       $00000        36    21     683       $2AB00
        ;     2     21      21       $01500        37    21     704       $2C000
        ;     3     21      42       $02A00        38    21     725       $2D500
        ;     4     21      63       $03F00        39    21     746       $2EA00
        ;     5     21      84       $05400        40    21     767       $2FF00
        ;     6     21     105       $06900        41    21     788       $31400
        ;     7     21     126       $07E00        42    21     809       $32900
        ;     8     21     147       $09300        43    21     830       $33E00
        ;     9     21     168       $0A800        44    21     851       $35300
        ;    10     21     189       $0BD00        45    21     872       $36800
        ;    11     21     210       $0D200        46    21     893       $37D00
        ;    12     21     231       $0E700        47    21     914       $39200
        ;    13     21     252       $0FC00        48    21     935       $3A700
        ;    14     21     273       $11100        49    21     956       $3BC00
        ;    15     21     294       $12600        50    21     977       $3D100
        ;    16     21     315       $13B00        51    21     998       $3E600
        ;    17     21     336       $15000        52    21    1019       $3FB00
        ;    18     19     357       $16500        53    19    1040       $41000
        ;    19     19     376       $17800        54    19    1059       $42300
        ;    20     19     395       $18B00        55    19    1078       $43600
        ;    21     19     414       $19E00        56    19    1097       $44900
        ;    22     19     433       $1B100        57    19    1116       $45C00
        ;    23     19     452       $1C400        58    19    1135       $46F00
        ;    24     19     471       $1D700        59    19    1154       $48200
        ;    25     18     490       $1EA00        60    18    1173       $49500
        ;    26     18     508       $1FC00        61    18    1191       $4A700
        ;    27     18     526       $20E00        62    18    1209       $4B900
        ;    28     18     544       $22000        63    18    1227       $4CB00
        ;    29     18     562       $23200        64    18    1245       $4DD00
        ;    30     18     580       $24400        65    18    1263       $4EF00
        ;    31     17     598       $25600        66    17    1281       $50100
        ;    32     17     615       $26700        67    17    1298       $51200
        ;    33     17     632       $27800        68    17    1315       $52300
        ;    34     17     649       $28900        69    17    1332       $53400
        ;    35     17     666       $29A00        70    17    1349       $54500          
        Select track
          Case  1 To 17 : Sectors = 21 
          Case 18 To 24 : Sectors = 19    
          Case 25 To 30 : Sectors = 18
          Case 31 To 35 : Sectors = 17  
          Case 36 To 52 : Sectors = 21 
          Case 53 To 59 : Sectors = 19
          Case 60 To 65 : Sectors = 18
          Case 66 To 70 : Sectors = 17                  
        EndSelect
        
        
      Case #D81 : Sectors = 40
        
      Case #D80
        Select track
          Case  1 To 39 : Sectors = 29
          Case 40 To 53 : Sectors = 27
          Case 54 To 64 : Sectors = 25
          Case 65 To 77 : Sectors = 23
        EndSelect                
        
      Case #D82
        Select track
          Case   1 To  39 : Sectors = 29
          Case  40 To  53 : Sectors = 27
          Case  54 To  64 : Sectors = 25
          Case  65 To  77 : Sectors = 23
          Case  78 To 116 : Sectors = 29 
          Case 117 To 130 : Sectors = 27
          Case 131 To 141 : Sectors = 25
          Case 142 To 154 : Sectors = 23
        EndSelect
        
    EndSelect
    
    ProcedureReturn Sectors
    
  EndProcedure
  
  
  Procedure.i di_get_block_pa_sectors(*di.DiskImage, *ts.TrackSector)
    
    Protected.i Result, block, SaveTrack
    
    Select *di\Type
      Case #D64
        
        If *ts\track > 35
          block       = 17
          SaveTrack  = *ts\track
          *ts\track   - 1
        EndIf    
        
        If *ts\track < 18
          block + (*ts\track - 1) * 21
        ElseIf *ts\track < 25
          block + (*ts\track - 18) * 19 + 17 * 21
        ElseIf *ts\track < 31
          block + (*ts\track - 25) * 18 + 17 * 21 + 7 * 19
        Else
          block + (*ts\track - 31) * 17 + 17 * 21 + 7 * 19 + 6 * 18
        EndIf
        
        If SaveTrack > 35
          *ts\track = SaveTrack
        EndIf                
        
        Result = block 
        
      Case #D71
        If *ts\track > 35
          block       = 683
          SaveTrack  = *ts\track
          *ts\track   - 35
        EndIf
        
        If *ts\track < 18
          block + (*ts\track - 1) * 21
        ElseIf *ts\track < 25
          block + (*ts\track - 18) * 19 + 17 * 21
        ElseIf *ts\track < 31
          block + (*ts\track - 25) * 18 + 17 * 21 + 7 * 19
        Else
          block + (*ts\track - 31) * 17 + 17 * 21 + 7 * 19 + 6 * 18
        EndIf 
        
        If SaveTrack > 35
          *ts\track = SaveTrack
        EndIf
        
        Result = block
        
      Case #D81
        Result = (*ts\track - 1) * 40 
        
    EndSelect
    
    ProcedureReturn Result
    
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ; /* convert track, sector to blocknum */
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.i di_get_block_num(*di.DiskImage, *ts.TrackSector)
    
    Protected block.i, SaveTrack.i
    
    Select *di\Type
      Case #D64
        If *ts\track > 35
          block       = 17
          SaveTrack  = *ts\track
          *ts\track   - 1
        EndIf    
        
        If *ts\track < 18
          block + (*ts\track - 1) * 21
        ElseIf *ts\track < 25
          block + (*ts\track - 18) * 19 + 17 * 21
        ElseIf *ts\track < 31
          block + (*ts\track - 25) * 18 + 17 * 21 + 7 * 19
        Else
          block + (*ts\track - 31) * 17 + 17 * 21 + 7 * 19 + 6 * 18
        EndIf 
        
        If SaveTrack > 35
          *ts\track = SaveTrack
        EndIf
        
        block + *ts\sector
        
      Case #D71
        If *ts\track > 35
          block       = 683
          SaveTrack  = *ts\track
          *ts\track  - 35
        EndIf
        
        If *ts\track < 18
          block + (*ts\track - 1) * 21
        ElseIf *ts\track < 25
          block + (*ts\track - 18) * 19 + 17 * 21
        ElseIf *ts\track < 31
          block + (*ts\track - 25) * 18 + 17 * 21 + 7 * 19
        Else
          block + (*ts\track - 31) * 17 + 17 * 21 + 7 * 19 + 6 * 18
        EndIf 
        
        If SaveTrack > 35
          *ts\track = SaveTrack
        EndIf
        block + *ts\sector
        
      Case #D81
        block = (*ts\track - 1) * 40 + *ts\sector
        
    EndSelect   
    
    ProcedureReturn block
    
  EndProcedure   
  ;---------------------------------------------------------------------------------------------------------
  ; /* get a pointer to block data */
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i di_get_ts_addr(*di.DiskImage, *ts.TrackSector)
    ProcedureReturn *di\Image + di_get_block_num(*di, *ts) * 256
  EndProcedure   
  ;---------------------------------------------------------------------------------------------------------
  ; /* return a pointer to the next block in the chain */
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i next_ts_in_chain(*di.DiskImage,  *ts.TrackSector)
    
    Define *p.ByteArrayStructure
    
    Static newts.TrackSector
    
    *p = di_get_ts_addr(*di, *ts)
    newts\track  = *p\c[0]
    newts\sector = *p\c[1]
    
    If ( *p\c[0] > di_tracks(*di) )
      newts\track     = 0
      newts\sector    = 0
    ElseIf ( *p\c[1] > di_sectors_per_track(*di, *p\c[0] ) )
      newts\track     = 0
      newts\sector    = 0
    EndIf
    ProcedureReturn @newts
    
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ; /* return a pointer to the disk title */
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.i di_title(*di.DiskImage)
    Select (*di\Type)
      Case #D64 : ProcedureReturn di_get_ts_addr( *di, *di\dir ) + 144
      Case #D71 : ProcedureReturn di_get_ts_addr( *di, *di\dir ) + 144
      Case #D81 : ProcedureReturn di_get_ts_addr( *di, *di\dir ) + 4       
      Default   : ProcedureReturn #Null ; Not supported
    EndSelect
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ; /* return number of free blocks in track */
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.i di_track_blocks_free(*di.DiskImage, track.i)
    
    Define *bam.ByteArrayStructure
    
    Select *di\Type
      Case #D64
        If track < 36
          *bam = di_get_ts_addr(*di, *di\bam)
        Else
          ; Marty2PB: Added Extended Tracks Support 36 to 40
          *bam = di_get_ts_addr(*di, *di\bam); + 152                                       
          ProcedureReturn *bam\c[ (16 + track) * 3 +  track]
        EndIf                 
        
      Case #D71
        *bam = di_get_ts_addr(*di, *di\bam)
        If track > 35
          ProcedureReturn *bam\c[track + 185]
        EndIf 
        
      Case #D81
        If track < 41
          *bam = di_get_ts_addr(*di, *di\bam)
        Else
          *bam = di_get_ts_addr(*di, *di\bam2)
          track - 40
        EndIf
        ProcedureReturn *bam\c[track * 6 + 10]
        
    EndSelect       
    
    ProcedureReturn *bam\c[track * 4]
    
  EndProcedure   
  
  ;---------------------------------------------------------------------------------------------------------
  ; count number of free blocks
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.i blocks_free(*di.DiskImage)       
    Protected Track.i, Blocks.i = 0
    
    For Track = 1 To di_tracks(*di.DiskImage)           
      If ( Track <> *di\dir\track )
        Blocks + di_track_blocks_free(*di, Track)
      EndIf
    Next
    ProcedureReturn Blocks
  EndProcedure
  
  ;---------------------------------------------------------------------------------------------------------
  ; /* check If track, sector is free IN BAM */
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i di_is_ts_free( *di.DiskImage, *ts.TrackSector)
    
    Protected mask.l
    Define *bam.ByteArray4096
    
    Select *di\Type
      Case #D64
        mask = 1 << ( *ts\sector & 7)
        *bam = di_get_ts_addr(*di, *di\bam)
        If *ts\track < 36
          ProcedureReturn *bam\b[*ts\track * 4 + *ts\sector / 8 + 1] & mask
        Else
          ; Marty2PB: Added Extended Tracks Support 36 to 40                                  
          ProcedureReturn *bam\b[ (16 + *ts\track) * 3 + *ts\track + *ts\sector / 8 + 1] & mask
        EndIf
        
      Case #D71
        mask = 1 << (*ts\sector & 7)
        If *ts\track < 36
          *bam = di_get_ts_addr(*di, *di\bam)
          ProcedureReturn *bam\b[*ts\track * 4 + *ts\sector / 8 + 1] & mask
        Else
          *bam = di_get_ts_addr(*di, *di\bam2)
          ProcedureReturn *bam\b[ (*ts\track - 35) * 3 + *ts\sector / 8 - 3 ] & mask
        EndIf
        
      Case #D81
        mask = 1 << (*ts\sector & 7)
        If *ts\track < 41
          *bam = di_get_ts_addr(*di, *di\bam)
        Else
          *bam = di_get_ts_addr(*di, *di\bam) + 16
        EndIf
        ProcedureReturn *bam\b[*ts\track * 6 + *ts\sector / 8 + 11] & mask
        
    EndSelect       
    
    ProcedureReturn 0
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Test and Show BAM
  ;--------------------------------------------------------------------------------------------------------- 
  Procedure.i di_do_bam(*di.DiskImage)
    
    Protected Track.i, Sector.i
    Static ts.TrackSector
    
    
    ClearList( BAM() )
    
    For Track = 1 To di_tracks( *di )
      ts\track = Track
      
      AddElement( BAM() )
      AddElement( BAM()\Track() )
      
      BAM()\Track()\Number     = ts\track
      BAM()\Track()\IsFree     = di_track_blocks_free(*di, BAM()\Track()\Number )
      BAM()\Track()\BlockStart = di_get_block_pa_sectors(*di, @ts )
      BAM()\Track()\MaxSector  = di_sectors_per_track(*di, BAM()\Track()\Number)
      
      For Sector = 0 To BAM()\Track()\MaxSector -1
        ts\sector = Sector
        
        AddElement( BAM()\Track()\Sector() )
        
        BAM()\Track()\Sector()\Sector = Sector
        BAM()\Track()\Sector()\Used   = di_is_ts_free(*di, @ts)
      Next        
      
    Next    
    
  EndProcedure     
  
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; /* Load image into ram */
  ;---------------------------------------------------------------------------------------------------------
  Procedure.l di_load_image(DiskImageFile$)
    
    Protected *di.DiskImage, ImageFileSize.i
    
    
    If FileSize(DiskImageFile$) < 0
      CBMDiskImage::*er\s = "File "+Chr(34)+DiskImageFile$+Chr(34)+" Not Found"
      ProcedureReturn -1
    EndIf
    
    *di = AllocateStructure(DiskImage)
    
    ImageFileSize = FileSize(DiskImageFile$)
    Select ImageFileSize
      Case 174848                       ; /* D64 image, 35 tracks */
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam               
      Case 175531                       ; /* D64 image, 35 tracks with errors */ (which we just ignore)   
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam    
      Case 196608                       ; /* D64 image, 40 tracks   
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam  
      Case 197376                       ; /* D64 image, 40 tracks with errors 
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam    
      Case 205312                        ; /* D64 image, 42 tracks   
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam  
      Case 206114                        ; /* D64 image, 42 tracks with errors 
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam             
      Case 176640       ;                ; /* D67 image, 35 tracks DOS1 */
        CBMDiskImage::*er\s          = "D67: Not Supportet"
        ProcedureReturn -1               
      Case 349696                       ;  /* 1366 Blocks    /* 1328 free */
        *di\Type       = #D71
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\bam2\track = 53
        *di\bam2\sector= 0
        *di\dir        = *di\bam
      Case 351062                       ; /* D71 image, 70 tracks With errors */
        *di\Type       = #D71
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\bam2\track = 53
        *di\bam2\sector= 0
        *di\dir        = *di\bam  
      Case 533248   
        CBMDiskImage::*er\s          = "D80: Not Supportet, 77 tracks"
        ProcedureReturn -1
        ;                 *di\Type       = "D80"
        ;                 *di\bam\track  = 38
        ;                 *di\bam\sector = 0
        ;                 *di\bam2\track = 38
        ;                 *di\bam2\sector= 3
        ;                 *di\dir\track  = 39
        ;                 *di\dir\sector = 0               
      Case 819200                       ; /* D81 image, 80 tracks */
        *di\Type       = #D81
        *di\bam\track  = 40
        *di\bam\sector = 1
        *di\bam2\track = 40
        *di\bam2\sector= 2
        *di\dir\track  = 40
        *di\dir\sector = 0
        
      Case 822400                       ; /* D81 image, 80 tracks With errors */
        *di\Type       = #D81
        *di\bam\track  = 40
        *di\bam\sector = 1
        *di\bam2\track = 40
        *di\bam2\sector= 2
        *di\dir\track  = 40
        *di\dir\sector = 0   
      Case 832680
        CBMDiskImage::*er\s          = "D81: Not Supportet, 81 tracks"            
        ProcedureReturn -1                    
      Case 829440
        CBMDiskImage::*er\s          = "D81: Not Supportet, 81 tracks with errors info"            
        ProcedureReturn -1            
      Case 839680
        CBMDiskImage::*er\s          = "D81: Not Supportet, 82 tracks" 
        ProcedureReturn -1    
      Case 842960
        CBMDiskImage::*er\s          = "D81: Not Supportet, 82 tracks with errors info" 
        ProcedureReturn -1 
      Case 849920
        CBMDiskImage::*er\s          = "D81: Not Supportet, 83 tracks" 
        ProcedureReturn -1                
      Case 853240
        CBMDiskImage::*er\s          = "D81: Not Supportet, 83 tracks with errors info"                  
        ProcedureReturn -1  
      Case 1066496                      
        ;              *di\Type       = "D82"
        ;              *di\bam\track  = 38
        ;              *di\bam\sector = 0
        ;              *di\bam2\track = 38
        ;              *di\bam2\sector= 3
        ;              *di\dir\track  = 39
        ;              *di\dir\sector = 0                    
        CBMDiskImage::*er\s          = "D82: Not Supportet, 77 tracks"               
        ProcedureReturn -1                   
      Case 829440
        CBMDiskImage::*er\s          = "D1M: Not Supportet, 81 tracks"               
        ProcedureReturn -1 
      Case 832680
        CBMDiskImage::*er\s          = "D1M: Not Supportet, 81 tracks with errors info"               
        ProcedureReturn -1  
      Case 1658880
        CBMDiskImage::*er\s          = "D2M: Not Supportet, 81 tracks"               
        ProcedureReturn -1             
      Case 1665360
        CBMDiskImage::*er\s          = "D2M: Not Supportet, 81 tracks with errors info"               
        ProcedureReturn -1 
      Case 3317760
        CBMDiskImage::*er\s          = "D4M: Not Supportet, 81 tracks"               
        ProcedureReturn -1
      Case 3330720
        CBMDiskImage::*er\s          = "D4M: Not Supportet, 81 tracks with errors info"               
        ProcedureReturn -1          
      Case 0
        CBMDiskImage::*er\s          = "Images has 0 Bytes"
        ProcedureReturn -1
      Case -1
        CBMDiskImage::*er\s          = "Image " + DiskImageFile$ + "Not Found"
        ProcedureReturn -1
      Case -2   
        CBMDiskImage::*er\s          = "Mismatch Error"               
        ProcedureReturn -1
        
      Default
        Select UCase( GetExtensionPart(DiskImageFile$) )
          Case "G64"
            CBMDiskImage::*er\s          = "G64: Not Supportet" 
            ProcedureReturn -1
          Case "P64"
            CBMDiskImage::*er\s          = "P64: Not Supportet"                    
            ProcedureReturn -1
          Case "X64" 
            CBMDiskImage::*er\s          = "X64: Not Supportet" 
            ProcedureReturn -1
          Case "TAP"  
            CBMDiskImage::*er\s          = "TAP: Not Supportet"       
            ProcedureReturn -1
          Case "G71"
            CBMDiskImage::*er\s          = "G71: Not Supportet"                    
            ProcedureReturn -1
          Case "NIB"
            CBMDiskImage::*er\s          = "NIB: Not Supportet"                    
            ProcedureReturn -1                    
          Default
            CBMDiskImage::*er\s          = UCase( GetExtensionPart(DiskImageFile$)) + ": Not Supportet" 
            ProcedureReturn -1
        EndSelect          
        
    EndSelect
    
    LoadDiskImage(DiskImageFile$, ImageFileSize)
    
    ;ShowMemoryViewer(*di\image, ImageFileSize)
    
    *di\size        = ImageFileSize 
    *di\filename    = GetFilePart(DiskImageFile$)
    *di\filepath    = GetPathPart(DiskImageFile$)
    *di\openfiles   = 0
    *di\blocksfree  = blocks_free(*di);
    *di\modified    = 0               ;
    *di\interleave  = interleave(*di\type)
    *di\DebugInfo\write_info = #True
    
    di_do_bam(*di)
    
    set_status(*di, 254, 0, 0)        ;
    
    ProcedureReturn *di
    
  EndProcedure 
  ;---------------------------------------------------------------------------------------------------------
  ; Creat Image
  ;---------------------------------------------------------------------------------------------------------
  Procedure di_create_image(DiskImageFile$, ImageFileSize)
    
    Protected *di.DiskImage
    
    *di = AllocateMemory(SizeOf(DiskImage))
    InitializeStructure(*di, DiskImage)
    
    Select ImageFileSize
      Case 174848                       ; /* D64 image, 35 tracks */
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam 
      Case 175531                       ; /* D64 image, 35 tracks with errors */ (which we just ignore)   
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam                   
      Case 196608                       ; /* D64 image, 40 tracks   
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam   
      Case 197376                       ; /* D64 image, 40 tracks with errors 
        *di\Type       = #D64
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\dir        = *di\bam    
      Case 349696                       ;  /* 1366 Blocks    /* 1328 free */
        *di\Type       = #D71
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\bam2\track = 53
        *di\bam2\sector= 0
        *di\dir        = *di\bam 
      Case 351062                       ; /* D71 image, 70 tracks With errors */
        *di\Type       = #D71
        *di\bam\track  = 18
        *di\bam\sector = 0
        *di\bam2\track = 53
        *di\bam2\sector= 0
        *di\dir        = *di\bam                  
      Case 819200                       ; /* D81 image, 80 tracks */
        *di\Type       = #D81
        *di\bam\track  = 40
        *di\bam\sector = 1
        *di\bam2\track = 40
        *di\bam2\sector= 2
        *di\dir\track  = 40
        *di\dir\sector = 0                
    EndSelect
    
    *di\size        = ImageFileSize
    *di\image       = AllocateMemory(ImageFileSize)
    *di\filename    = GetFilePart(DiskImageFile$)
    *di\filepath    = GetPathPart(DiskImageFile$)
    *di\openfiles   = 0
    *di\blocksfree  = blocks_free(*di);
    *di\modified    = 1               ;
    set_status(*di, 254, 0, 0)        ;
    
    ProcedureReturn *di
    
  EndProcedure    
  ;---------------------------------------------------------------------------------------------------------
  ; Get Error
  ;---------------------------------------------------------------------------------------------------------
  Procedure.s di_get_error_OpenDiskImage(*er.LastError)        
    ProcedureReturn *er\s
  EndProcedure    
  ;---------------------------------------------------------------------------------------------------------
  ; /* allocate track, sector in BAM */
  ;--------------------------------------------------------------------------------------------------------- 
  Procedure di_alloc_ts(*di.DiskImage, *ts.TrackSector)   
    
    Structure checker
      c.a[4063]
    EndStructure
    
    Define *bam.ByteArrayStructure, *checker.checker
    Protected mask.i
    
    *di\modified = 1      
    
    Select *di\Type
      Case #D64
        mask = 1 << ( *ts\sector & 7)
        *bam = di_get_ts_addr(*di, *di\bam)
        
        If *ts\track < 36
          *bam\c[ *ts\track * 4  ] - 1
          *bam\c[ *ts\track * 4 + *ts\sector / 8 + 1] & ~mask
        Else       
          ; Marty2PB: Added Extended Tracks Support 36 to 40                         
          *bam\c[ (16 + *ts\track)  *3 +  *ts\track ] - 1
          *bam\c[ (16 + *ts\track)  *3 +  *ts\track + *ts\sector / 8 + 1] & ~mask    
        EndIf 
        
      Case #D71
        mask = 1 << ( *ts\sector & 7)
        
        If *ts\track < 36
          *bam = di_get_ts_addr(*di, *di\bam)
          *bam\c[ *ts\track * 4  ] - 1
          *bam\c[ *ts\track * 4 + *ts\sector / 8 + 1] & ~mask
        Else
          *bam = di_get_ts_addr(*di, *di\bam)
          *bam\c[ *ts\track + 185] - 1
          
          *bam = di_get_ts_addr(*di, *di\bam2)
          *bam\c[ (*ts\track - 35) * 3 + *ts\sector / 8 - 3] & ~mask
        EndIf 
        
      Case #D81
        If *ts\track < 41
          *bam = di_get_ts_addr(*di, *di\bam)
        Else
          *bam = di_get_ts_addr(*di, *di\bam2)
          *ts\track - 40    
          *bam\c[ *ts\track * 6 + 10] - 1
          
          mask = 1 << (*ts\sector & 7)
          *bam\c[*ts\track * 6 + *ts\sector / 8 + 11] & ~mask
        EndIf
    EndSelect
    
  EndProcedure     
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; 
  ;---------------------------------------------------------------------------------------------------------      
  Procedure.i alloc_next_ts_spt_ts(*di.DiskImage, *ts.TrackSector, *prevts.TrackSector)
    Protected spt.i          
    ProcedureReturn (*prevts\sector + interleave(*di\type) ) % di_sectors_per_track(*di, *ts\track)        
  EndProcedure 
  ;---------------------------------------------------------------------------------------------------------
  ; 
  ;---------------------------------------------------------------------------------------------------------    
  Procedure.s debug_write_info( *di.DiskImage, *ts.TrackSector)
    
    If ( *di\DebugInfo\write_info = #True)
      
      Protected  Offset.i, FreeBlocks.i, DebugText$
      
      offset =  *di\Image + di_get_block_num(*di, *ts) * 256
      FreeBlocks.i = di_is_ts_free(*di, *ts)
      DebugText$          =   "Allocate & Write ................................"
      DebugText$ +#CRLF$+     ""
      DebugText$ +#CRLF$+     "Track      :  "+ Str(*ts\track)+ "/ Sector:  " +RSet(Str(*ts\sector),2,"0") 
      DebugText$ +#CRLF$+     "Track      : $"+ Hex(*ts\track)+ "/ Sector: $" +RSet(Hex(*ts\sector),2,"0")                     
      DebugText$ +#CRLF$+     "Offset     : " + Str(di_get_block_num(*di, *ts) * 256)
      DebugText$ +#CRLF$+     "Offset     : $"+ Hex(di_get_block_num(*di, *ts) * 256) + " #Sectors In: "+Str( di_get_block_num(*di, *ts) )
      DebugText$ +#CRLF$+     "Blocks Free: " + Str(FreeBlocks)
      DebugText$ +#CRLF$+     "-------------------------------------------------"
      ShowMemoryViewer(offset, 254)                    
      CallDebugger
      ProcedureReturn DebugText$
    EndIf
    ProcedureReturn ""
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; 
  ;---------------------------------------------------------------------------------------------------------    
  Procedure.i alloc_next_ts_GetSectors(*di.DiskImage, CurrentTrack.i)
    
    Protected *bam.ByteArrayStructure, SectorPoint.i
    Protected boff.i
    
    
    *bam = di_get_ts_addr(*di, *di\bam)
    
    If *di\Type = #D64
      Select CurrentTrack
        Case 1 To 17, 19 To 35                         
          SectorPoint = *bam\c[ CurrentTrack * 4 + boff ]
        Case 18
          ProcedureReturn  -1
        Case 36 To 40
          SectorPoint = *bam\c[ (16 + CurrentTrack)  *3 +  CurrentTrack + boff ]
      EndSelect
    EndIf
    
    ProcedureReturn SectorPoint
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; 
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i alloc_next_ts(*di.DiskImage, *prevts.TrackSector)
    
    Protected.i spt, s1, s2, t1, t2, bpt, boff, res1, res2, tsTrack
    Protected FirstTrack, LastTrack, RootTrack, CurrentTrack, SectorCount, SectorMaxNr, x, FreeBlocks
    Define *bam.ByteArrayStructure, *ts.TrackSector
    
    *ts = AllocateMemory(SizeOf(TrackSector))
    
    Select *di\Type
      Case #D64
        FirstTrack      = 17     ; Start Track
        LastTrack       = 35     ; End Track  , Default D64 with Size 174848
        RootTrack      =  18     ;
                                 ;         res1    = 18    ; Directory Entry
                                 ;         res2    = -1    ; Second Directory
                                 ;         bpt     =  4
                                 ;         bpt2    =  3
                                 ;         boff    =  0
                                 ;         tx      =  1
        Select  *di\size
          Case 174848, 175531: LastTrack = 35    ; End track
          Case 196608, 197376: LastTrack = 40    ; End track
        EndSelect                
        
      Case #D71
        s1      =  1
        t1      = 35
        s2      = 36
        t2      = 70
        res1    = 18
        res2    = 53
        bpt     =  4
        boff    =  0
      Case #D81
        s1      =  1
        t1      = 40
        s2      = 41
        t2      = 80
        res1    = 40
        res2    =  0
        bpt     =  6
        boff    = 10       
      Default
        ; Not Support
    EndSelect
    
    If (*prevts\track = 0)
      CurrentTrack = 1
    Else
      CurrentTrack = *prevts\track
    EndIf
    
    
    
    For CurrentTrack = CurrentTrack To LastTrack  
      
      *ts\track = CurrentTrack
      
      If *ts\track = 18
        Continue
      EndIf
      
      SectorCount = alloc_next_ts_GetSectors(*di, *ts\track) 
      If SectorCount = 0
        Continue
      EndIf
      SectorMaxNr.i = di_sectors_per_track(*di, *ts\track)                         
      
      
      SectorMaxNr - SectorCount 
      
      For x = *ts\sector To SectorMaxNr
        
        *ts\sector = x
        
        FreeBlocks = di_is_ts_free(*di, *ts)
        If FreeBlocks
          
          ;Debug debug_write_info( *di, *ts)                                         
          
          di_alloc_ts(*di, *ts)
          
          ProcedureReturn *ts
        EndIf
      Next x                                                                  
    Next CurrentTrack
    
    
    *ts\track  = 0
    *ts\sector = 0
    
    ProcedureReturn *ts
    
  EndProcedure   
  
  
  ;---------------------------------------------------------------------------------------------------------
  ;
  ;---------------------------------------------------------------------------------------------------------  
  Procedure di_sync(*di.DiskImage)
    
    Protected File.i
    
    File = CreateFile(#PB_Any, *di\filepath + *di\filename, #PB_File_SharedRead|#PB_File_SharedWrite)           
    If File
      If WriteData(File, *di\image, *di\size) = *di\size
        *di\modified = #False
      EndIf
      CloseFile(File)
    EndIf
    
  EndProcedure  
  ;---------------------------------------------------------------------------------------------------------
  ;
  ;---------------------------------------------------------------------------------------------------------  
  Procedure di_free_image(*di.DiskImage)
    
    If *di\modified
      di_sync(*di)
    EndIf
    
    *di\filename = ""
    *di\filepath = ""
    
    FreeMemory(*di\image)
    FreeStructure(*di)
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ;
  ;---------------------------------------------------------------------------------------------------------
  Procedure.i match_pattern(*rawpattern.Rawname, *rawname.Rawname)       
    Protected i.i     
    For i = 0 To 15                       
      
      If ( *rawpattern\c[i] = '*' )                
        ProcedureReturn 1                           
      EndIf                       
      
      If (*rawname\c[i] = $a0 )
        
        If (*rawpattern\c[i] = $a0)
          ProcedureReturn  1                
        Else
          ProcedureReturn  0
        EndIf
        
      Else            
        If (*rawpattern\c[i] = '?' ) Or ( *rawpattern\c[i] = *rawname\c[i] )
        Else
          ProcedureReturn 0
        EndIf
      EndIf      
    Next i   
    ProcedureReturn 1
  EndProcedure
  
  Procedure.c Filetype_Get_Locked(*buffer.ByteArrayStructure, offset)  
    ProcedureReturn *buffer\c[offset +2] & $40    ; // locked file?                
  EndProcedure
  Procedure.c Filetype_Get_Closed(*buffer.ByteArrayStructure, offset)         
    ProcedureReturn *buffer\c[offset +2] & $80    ; // closed file?                
  EndProcedure
  ;   ;---------------------------------------------------------------------------------------------------------
  ;   ;
  ;   ;---------------------------------------------------------------------------------------------------------   
  Procedure.l find_file_entry(*di.DiskImage, *rawpattern.Rawname, type.i)
    
    Protected Result.i, pResult.s, offset.i
    
    Protected *p.UnsignedChar
    
    Protected *ts.TrackSector
    Protected *rde.RawDirEntry
    Protected *buffer
    
    *ts = next_ts_in_chain(*di, *di\bam)   
    While *ts\track
      
      *buffer = di_get_ts_addr(*di, *ts)
      
      For offset = 0 To 255 Step 32
        
        ;ShowMemoryViewer(*buffer+offset, 32)
        
        *rde = *buffer + offset
        
        ;If (*rde\type & ~$40) = (type | $80)
        If *rde\type & $3f
          If match_pattern(*rawpattern, *rde\rawname)
            
            *di\pattern\a = *rde\type & 7
            *di\pattern\s = Filetype_Get(*di\pattern\a) ; Pattern for SaveFile
            
            pResult = Filetype_Get(*di\pattern\a)                        
            
            If Filetype_Get_Closed(*rde\rawname, offset) > 1
              pResult = "*"+pResult
            EndIf
            
            If Filetype_Get_Locked(*rde\rawname, offset) = 0
              pResult + "<"
            EndIf                    
            
            *di\pattern\o = pResult  ; Original Pattern
            
            ProcedureReturn *rde
          EndIf
        EndIf
      Next offset
      
      *ts = next_ts_in_chain(*di, *ts);
    Wend                     
  EndProcedure 
  ;---------------------------------------------------------------------------------------------------------
  ; /* allocate next available directory block */
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i alloc_next_dir_ts(*di.DiskImage)
    
    Define *p.UnsignedChar
    
    Protected *ts.TrackSector, *lastts.TrackSector, spt.i
    
    If (di_track_blocks_free( *di, *di\bam\track) )
      
      *ts\track = *di\bam\track
      *ts\sector = 0
      While (*ts\track) 
        *lastts = *ts
        *ts = next_ts_in_chain(*di, *ts)
      Wend   
      *ts\track = *lastts\track
      *ts\sector = *lastts\sector + 3
      spt = di_sectors_per_track(*di, *ts\track)
      While ( *ts\sector = (*ts\sector + 1) % spt )
        
        If (di_is_ts_free(*di, *ts) )
          *p = di_get_ts_addr(*di, *lastts)
          *p\b[0] = *ts\track
          *p\b[1] = *ts\sector
          *p = di_get_ts_addr(*di, *ts);
          FillMemory( *p, 256, 0)
          *p\b[1] = $ff
          *di\modified = 1
          ProcedureReturn *ts
        EndIf
        
      Wend    
      
    Else
      *ts\track = 0
      *ts\sector = 0
      ProcedureReturn *ts
    EndIf
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ; 
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.l alloc_file_entry(*di.DiskImage, *rawname.rawname, type.i)
    
    Protected *buffer.ByteArrayStructure, *ts.TrackSector, *lastts.TrackSector,*rde.RawDirEntry, offset.i, *er.LastError
    Protected n.i, x.i
    
    ; /* check If file already exists */
    *ts = next_ts_in_chain(*di, *di\bam)
    While (*ts\track)
      
      *buffer = di_get_ts_addr(*di, *ts)
      
      For offset = 0 To 255 Step 32
        
        *rde = *buffer + offset
        If *rde\type & $3f       ; cv: mask OUT file type To ignore closed/locked DEL files
          
          ;If (*rawname = *rde\rawname)
          For n = 0 To 15
            If *rawname\c[n] = *rde\rawname\c[n]
              x + 1                                                                                                     
            EndIf    
            If ( x = 16 )
              Set_status(*di, 63, 0, 0); 
              CBMDiskImage::*er\s = "File Exists: " + PeekS(*rde\rawname, 16, #PB_Ascii) + "," + Str(*rde\type & ~$3f)
              ProcedureReturn 0  
            EndIf    
          Next
          ;EndIf                        
        EndIf                    
      Next offset
      *ts = next_ts_in_chain(*di, *ts)
    Wend
    
    ;/* allocate empty slot */
    *ts = next_ts_in_chain(*di, *di\bam)
    While (*ts\track)
      
      *buffer = di_get_ts_addr(*di, *ts)
      
      For offset = 0 To 255 Step 32
        
        *rde = *buffer + offset
        
        If (*rde\type = 0)
          
          FillMemory( *rde + 4, 28, 0)
          CopyMemory( *rawname, *rde\rawname,16 )
          
          *rde\type    = type
          *di\modified = 1
          *di\SizeOffset  = offset                    ; Remember Offset For Block File Size			        
          ProcedureReturn *rde
        EndIf    
      Next offset
      *lastts = *ts
      *ts = next_ts_in_chain(*di, *ts)
    Wend    
    
    ;/* allocate new dir block */
    *ts = alloc_next_dir_ts(*di);
    If (*ts\track)
      
      *rde = di_get_ts_addr(*di, *ts)
      FillMemory(*rde + 2, 30, 0)
      CopyMemory(*rawname, *rde\rawname, 16)
      
      *rde\type       = type            
      *di\modified    = 1            
      *di\SizeOffset  = offset                    ; Remember Offset For Block File Size
      ProcedureReturn *rde
    Else
      set_status(*di, 72, 0, 0)
      ProcedureReturn 0
    EndIf
    
    
  EndProcedure   
  ;---------------------------------------------------------------------------------------------------------
  ; /* open a file */
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.i di_open(*di.DiskImage, *rawname.rawname, type.i, Mode.s)
    
    Protected *p.ByteArrayStructure
    Protected *imgfile.ImageFile, *rde.RawDirEntry
    
    
    If *di = 0
      ProcedureReturn 0
    ElseIf *di = -1
      ProcedureReturn -1
    ElseIf *di = -2
      ProcedureReturn -2
    EndIf
    
    *imgfile = AllocateStructure(ImageFile)
    
    *rde.RawDirEntry = AllocateStructure(RawDirEntry)
    
    ;type = Filetype(type)
    
    set_status(*di, 255, 0, 0)
    
    Select Mode
      Case "rb"
        
        If ( *rawname = '$' )
          *imgfile\mode = "r"
          *imgfile\ts   = *di\dir
          
          *p = di_get_ts_addr(*di, *di\dir)
          *imgfile\buffer = *p + 2;
          
          Select *di\type
            Case #D64
              *imgfile\nextts\track = 18  ; // 1541/71 ignores bam t/s link
              *imgfile\nextts\sector = 1  ;
            Case #D71
              *imgfile\nextts\track = 18  ; // 1541/71 ignores bam t/s link
              *imgfile\nextts\sector = 1  ;                           
            Case #D81
              *imgfile\nextts\track = *p\c[0]
              *imgfile\nextts\sector =*p\c[1]             
            Default
              ; No Supportet and NULL
          EndSelect
          *imgfile\buflen = 254;                   
          *rde = 0                               
        Else
          
          *rde = find_file_entry(*di, *rawname, type)
          If *rde = #Null
            set_status(*di, 62, 0, 0)
            FreeStructure(*imgfile)   
            ProcedureReturn 0
          EndIf
          
          
          *imgfile\mode = "r"
          *imgfile\ts = *rde\startts
          
          If (*imgfile\ts\track > di_tracks(*di))
            ProcedureReturn 0
          EndIf   
          
          *p = di_get_ts_addr(*di, *rde\startts)
          
          *imgfile\buffer        = *p + 2
          
          *imgfile\nextts\track  = *p\c[0]
          *imgfile\nextts\sector = *p\c[1]
          
          
          If (*imgfile\nextts\track = 0)
            *imgfile\buflen = *imgfile\nextts\sector - 1
          Else
            *imgfile\buflen = 254
          EndIf                     
          
        EndIf         
      Case "wb"
        
        *rde = alloc_file_entry(*di, *rawname, type)
        If *rde = #Null
          ProcedureReturn 0
        EndIf
        
        *imgfile\mode       = "w"
        *imgfile\ts\track   = 0
        *imgfile\ts\sector  = 0                    
        *imgfile\buffer     = AllocateMemory(254)
        *imgfile\buflen     = 254
        *di\modified        = 1                                                                                     
    EndSelect
    
    *imgfile\diskimage      = *di
    *imgfile\rawdirentry    = *rde
    *imgfile\position       = 0
    *imgfile\bufptr         = 0
    
    *di\openfiles           + 1
    
    set_status(*di, 0, 0, 0)
    
    ProcedureReturn *imgfile
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; ;   /* Read first block INTO buffer */
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.i di_read(*imgfile.ImageFile, *buffer.CharBuffer, len.i)
    
    Protected *p.ByteArrayStructure , bytesleft.i ,  counter.i
    Protected *tts.TrackSector
    
    FillMemory(*buffer, 255, 0)     
    
    While len
      bytesleft = *imgfile\buflen - *imgfile\bufptr
      
      If bytesleft = 0
        
        If *imgfile\nextts\track = 0
          ProcedureReturn counter
        EndIf
        
        Select *imgfile\diskimage\Type
          Case #D64, #D71
            If ( *imgfile\ts\track = 18) And (*imgfile\ts\sector = 0 )
              *imgfile\ts\track  = 18
              *imgfile\ts\sector = 1
            Else
              *tts = next_ts_in_chain(*imgfile\diskimage, *imgfile\ts)
              *imgfile\ts\sector = *tts\sector
              *imgfile\ts\track  = *tts\track  
            EndIf
          Default     
            *tts = next_ts_in_chain(*imgfile\diskimage, *imgfile\ts)
            *imgfile\ts\sector = *tts\sector
            *imgfile\ts\track  = *tts\track                
        EndSelect        
        
        If (*imgfile\ts\track = 0)
          ProcedureReturn counter
        EndIf
        
        *p = di_get_ts_addr(*imgfile\diskimage, *imgfile\ts)
        *imgfile\buffer        = *p + 2
        *imgfile\nextts\track  = *p\c[0]
        *imgfile\nextts\sector = *p\c[1]
        
        If (*imgfile\nextts\track = 0)
          *imgfile\buflen = *imgfile\nextts\sector - 1
        Else
          *imgfile\buflen = 254
        EndIf
        
        *imgfile\bufptr = 0
        
      Else
        If len >= bytesleft
          While bytesleft
            *buffer\c[counter] = *imgfile\buffer\c[*imgfile\bufptr]
            *imgfile\bufptr + 1
            len         - 1
            bytesleft   - 1
            counter     + 1
            *imgfile\position + 1
          Wend                                                               
        Else   
          While len                       
            *buffer\c[counter] = *imgfile\buffer\c[*imgfile\bufptr]
            *imgfile\bufptr + 1
            len         - 1
            bytesleft   - 1
            counter     + 1
            *imgfile\position + 1
          Wend
        EndIf
      EndIf
    Wend
    
    ProcedureReturn counter
    
  EndProcedure          
  ;---------------------------------------------------------------------------------------------------------
  ; /* Read and get directory & blocks */
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i di_read_directory_blocks(*imgfile.ImageFile, ViewDelFiles.i = #True)
    
    Structure ByteArray
      c.a[0]
    EndStructure
    
    Protected *buffer.ByteArray
    
    Protected offset.i, type.i, closed.i, locked.i, size.i, C64FileLen.i, C64File.s, ftype.s, FileTypeOffset.i, i.i
    
    Protected *name.char
    Protected ptoasc.ptoa
    Protected DelOffset.i = 0
    
    *buffer = AllocateMemory(254)
    *name   = AllocateMemory(17)
    
    If di_read(*imgfile, *buffer, 254) <> 254
      ProcedureReturn 0
    EndIf   
    
    ;/* Read directory blocks */
    ClearList(*imgfile\FileList())       
    
    While di_read(*imgfile, *buffer, 254)
      
      For offset = -2 To 253 Step 32             
        
        If ViewDelFiles = #False            ; ADD DEL Files (true/false)
          offset + 2
        EndIf
        
        If *buffer\c[ offset+2 ] >= DelOffset
          
          C64FileLen = di_name_from_rawname(*name, *buffer +  offset + 5)
          
          type    = *buffer\c[ offset + 2] & 7
          ftype   = Filetype_Get(type)
          
          closed  = *buffer\c[offset + 2] & $80    ; // closed/locked file?
          locked  = *buffer\c[offset + 2] & $40    ; // closed/locked file?
          size    = *buffer\c[offset + 31] << 8 | *buffer\c[offset + 30]; // blocks size
          
          If closed : ftype = " "+ftype: Else: ftype = "*"+ftype: EndIf                       
          If locked : ftype + "<"      : Else: ftype + " "      : EndIf     
          
          For i = 0 To 15
            If ( *name\c[i] = 173 )
              *name\c[i] = 237
            EndIf     
          Next
          
          C64File.s = PeekS(*name, C64FileLen, #PB_Ascii)
          
          AddElement( *imgfile\FileList() ) 
          *imgfile\FileList()\C64File = C64File
          *imgfile\FileList()\C64Size = size
          *imgfile\FileList()\C64Type = ftype
          
        EndIf
      Next offset
    Wend       
    ProcedureReturn *imgfile
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Write a CBM File to Image
  ;---------------------------------------------------------------------------------------------------------    
  Procedure di_write(*imgfile.ImageFile, *buffer.offset, length.i, *di.DiskImage)
    
    Protected bytesleft.i, counter.i = 0, *nextts.Tracksector, CBMSize.i = 0, *p.offset
    
    
    While length
      bytesleft = *imgfile\buflen - *imgfile\bufptr
      
      If bytesleft = 0
        If *imgfile\diskimage\blocksfree = 0
          set_status(*imgfile\diskimage, 72, 0, 0)
          ProcedureReturn counter
        EndIf
        
        *nextts = alloc_next_ts(*imgfile\diskimage, *imgfile\ts)
        *imgfile\nextts\sector =  *nextts\sector
        *imgfile\nextts\track =  *nextts\track
        
        If (*imgfile\ts\track = 0)
          *imgfile\rawdirentry\startts = *imgfile\nextts
        Else
          *p = di_get_ts_addr(*imgfile\diskimage, *imgfile\ts)
          *p\c[0] = *imgfile\nextts\track
          *p\c[1] = *imgfile\nextts\sector
        EndIf
        
        *imgfile\ts = *imgfile\nextts
        *p = di_get_ts_addr(*imgfile\diskimage, *imgfile\ts)
        *p\c[0] = $00
        *p\c[1] = $FF
        
        CopyMemory( *imgfile\buffer,  *p + 2,  *imgfile\bufptr)
        
        *imgfile\bufptr = 0
        
        *imgfile\rawdirentry\sizelo + 1
        If *imgfile\rawdirentry\sizelo = 0
          *imgfile\rawdirentry\sizehi + 1
        EndIf
        
        *imgfile\diskimage\blocksfree - 1
      Else
        
        If length >= bytesleft
          While bytesleft
            *imgfile\buffer\c[*imgfile\bufptr] = *buffer\c[counter]
            *imgfile\bufptr + 1
            counter         + 1
            length          - 1
            bytesleft       - 1
            *imgfile\position + 1
          Wend
        Else
          While length
            *imgfile\buffer\c[*imgfile\bufptr] = *buffer\c[counter]
            *imgfile\bufptr + 1
            counter         + 1
            length          - 1
            bytesleft       - 1
            *imgfile\position + 1
          Wend
        EndIf
        
      EndIf
    Wend
    ProcedureReturn counter
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------
  ;
  ;---------------------------------------------------------------------------------------------------------
  Procedure di_close(*imgfile.ImageFile)          
    
    Protected *tts.TrackSector, *p.offset
    
    Select *imgfile\mode
      Case "w"                                
        If (*imgfile\bufptr)                                         
          
          If (*imgfile\diskimage\blocksfree)
            
            *tts.TrackSector = alloc_next_ts(*imgfile\diskimage, *imgfile\ts)
            
            *imgfile\nextts\sector = *tts\sector
            *imgfile\nextts\track = *tts\track
            
            If (*imgfile\ts\track = 0)
              *imgfile\rawdirentry\startts = *imgfile\nextts
            Else
              *p = di_get_ts_addr(*imgfile\diskimage, *imgfile\ts)
              *p\c[0] = *imgfile\nextts\track
              *p\c[1] = *imgfile\nextts\sector
            EndIf
            
            *imgfile\ts = *imgfile\nextts
            
            *p = di_get_ts_addr(*imgfile\diskimage, *imgfile\ts); - 
            *p\c[0] = $00
            *p\c[1] = *imgfile\bufptr+1
            
            *imgfile\buffer = ReAllocateMemory(*imgfile\buffer, *imgfile\bufptr )                                                
            CopyMemory(*imgfile\buffer,*p + 2 , *imgfile\bufptr)                     
            
            *imgfile\bufptr = 0
            *imgfile\rawdirentry\sizelo + 1
            If ( (*imgfile\rawdirentry\sizelo + 1) = 0 )                           
              *imgfile\rawdirentry\sizehi + 1
            EndIf
            
            *imgfile\diskimage\blocksfree - 1
            *imgfile\rawdirentry\type | $80                                             
          EndIf
        Else
          *imgfile\rawdirentry\type | $80                                                               
        EndIf
        
        FreeMemory(*imgfile\buffer)
    EndSelect
    
    *imgfile\diskimage\openfiles - 1
    FreeMemory(*imgfile)                         
  EndProcedure        
  ;---------------------------------------------------------------------------------------------------------
  ;
  ;---------------------------------------------------------------------------------------------------------
  Procedure di_free_ts_bam2(*di.DiskImage, *ts.TrackSector)  
    ;     Starting at Offset 41000
    ;  
    ;               00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F        ASCII
    ;         -----------------------------------------------   ----------------
    ;     00: FF FF 1F FF FF 1F FF FF 1F FF FF 1F FF FF 1F FF   תת.תת.תת.תת.תת.ת
    ;     10: FF 1F FF FF 1F FF FF 1F FF FF 1F FF FF 1F FF FF   ת.תת.תת.תת.תת.תת
    ;     20: 1F FF FF 1F FF FF 1F FF FF 1F FF FF 1F FF FF 1F   .תת.תת.תת.תת.תת.
    ;     30: FF FF 1F 00 00 00 FF FF 07 FF FF 07 FF FF 07 FF   תת.תתתתת.תת.תת.ת
    ;     40: FF 07 FF FF 07 FF FF 07 FF FF 03 FF FF 03 FF FF   ת.תת.תת.תת.תת.תת
    ;     50: 03 FF FF 03 FF FF 03 FF FF 03 FF FF 01 FF FF 01   .תת.תת.תת.תת.תת.
    ;     60: FF FF 01 FF FF 01 FF FF 01 00 00 00 00 00 00 00   תת.תת.תת.תתתתתתת
    ;     70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     A0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     B0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     C0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     D0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     F0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   תתתתתתתתתתתתתתתת
    ;     
    ;     Each track from 36-70 has 3 byte entries, starting at address $00.
    ;     
    ;           Byte: $00-02: FF FF 1F  - BAM Map For track 36
    ;                  03-05: FF FF 1F  - BAM Map For track 37
    ;                  ...
    ;                  33-35: 00 00 00  - BAM Map For track 53
    ;                  ...
    ;                  66-68: FF FF 01  - BAM Map For track 70
    ;                  69-FF:           - Not used
    Define *bam.UnsignedChar
    Protected mask.i, track.i
    
    *di\modified = 1
    
    For track = 0 To 52
      *ts\track = track
      *bam = di_get_ts_addr(*di, *di\bam2);
      Select track
        Case 0,3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51
          *bam\c[$0 + *ts\track]  = $FFFF 
        Case 1,4,7,10,13,16,19,22
          *bam\c[$0 + *ts\track]  = $FF1F
        Case 2,5,8,11,14,17,20,23
          *bam\c[$0 + *ts\track]  = $1FFF 
        Case 25
          *bam\c[$0 + *ts\track]  = $001F                      
        Case 26
          *bam\c[$0 + *ts\track]  = $0000 
        Case 28,31,34
          *bam\c[$0 + *ts\track]  = $FF07  
        Case 29,32,35
          *bam\c[$0 + *ts\track]  = $07FF
        Case 37,40,43
          *bam\c[$0 + *ts\track]  = $FF03
        Case 38,41,44
          *bam\c[$0 + *ts\track]  = $03FF
        Case 46,49
          *bam\c[$0 + *ts\track]  = $FF01 
        Case 47,50
          *bam\c[$0 + *ts\track]  = $01FF  
        Case 52
          *bam\c[$0 + *ts\track]  = $0001
      EndSelect 
      
      ;*bam\b[ (*ts\track - 35) * 3 + *ts\sector / 8 - 3] | mask                  
    Next 
    
  EndProcedure                   
  ;---------------------------------------------------------------------------------------------------------
  ; /* free a block in the BAM */
  ;---------------------------------------------------------------------------------------------------------   
  Procedure di_free_ts(*di.DiskImage, *ts.TrackSector) 
    
    Define *bam.UnsignedChar
    Protected mask.i
    
    *di\modified = 1
    
    Select *di\Type
      Case #D64
        mask = 1 << (*ts\sector & 7)
        *bam = di_get_ts_addr(*di, *di\bam)                  
        Select *ts\track
          Case 1 To 35
            *bam\a[*ts\track * 4 + *ts\sector / 8 + 1] | mask
            *bam\a[*ts\track * 4] + 1
            
          Case 36 To 40
            ; Marty2PB: Added Extended Tracks Support 36 to 40   
            *bam\c[ (16 + *ts\track)  *3 +  *ts\track + *ts\sector / 8 + 1] | mask                           
            *bam\c[ (16 + *ts\track)  *3 +  *ts\track ] + 1
            
            ;*bam = get_ts_addr(*di, *di\bam);
            ;*bam\a[*ts\track + 185] + 1   
        EndSelect        
        ProcedureReturn
        
      Case #D71
        Select *ts\track
            
          Case 0 To 35
            ; Starting at offset 16500
            mask = 1 << (*ts\sector & 7)
            *bam = di_get_ts_addr(*di, *di\bam)
            *bam\a[*ts\track * 4 + *ts\sector / 8 + 1] | mask
            *bam\a[*ts\track * 4] + 1
            
          Case 36 To 70
            ; Starting at offset 165DC
            *bam = di_get_ts_addr(*di, *di\bam);
            *bam\a[*ts\track + 185] + 1   
            
            ; in the Original Source, Tracks 36 - 70 does'nt prepare the
            ; Tracks at Offset 41000. I have no idea.. So I added and 
            ; changed this With di_free_ts_bam2 and free Blocks are correct.                       
        EndSelect              
        ProcedureReturn
        
      Case #D81
        
        ; The Code from the Orignal does'nt work really
        ; It missing the Bam Track Sector Preapre and
        ; overwritten some thing. It missed the 16 Byte
        ; Track Selection for BAM 2
        Select *ts\track
          Case 1 To 39
            *bam = di_get_ts_addr(*di, *di\bam)
            mask = 1 << (*ts\sector & 7)
            *bam\a[*ts\track * 6 + *ts\sector / 8 + 11] | mask
            *bam\a[*ts\track * 6 + 10] + 1  
          Case 40
            *bam = di_get_ts_addr(*di, *di\bam)                  
            *bam\a[*ts\track*6 + 10] = $24
            *bam\a[*ts\track*6 + 11] = $F0
            *bam\a[*ts\track*6 + 12] = $FF                  
            *bam\a[*ts\track*6 + 13] = $FF
            *bam\a[*ts\track*6 + 14] = $FF
            *bam\a[*ts\track*6 + 15] = $FF
          Case 41 To 80
            *bam = di_get_ts_addr(*di, *di\bam) + 16
            mask = 1 << (*ts\sector & 7)
            *bam\a[*ts\track * 6 + *ts\sector / 8 + 11] | mask
            *bam\a[*ts\track * 6 + 10] + 1                   
        EndSelect                      
    EndSelect
  EndProcedure    
  ;---------------------------------------------------------------------------------------------------------
  ; /* Create Image (Format) */
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i di_format(*di.DiskImage, *rawname.char, *rawid.charID, ImageSize.q = 0, DosType.i = 0)
    
    ; * Fixed D71 Format, use a false 
    
    Define *p.UnsignedCharFormat
    Static ts.TrackSector
    Protected tsTrack.i, tsSectr.i, Offst.i, ExTrk.i, x.i, i.i
    Protected c.a
    
    *di\modified = 1
    
    ; Format matched with c1541.exe and the Source for D64, D71 and D81 Description
    
    Select *di\Type
      Case #D64
        ;---------------------------------------------------------/* erase disk */
        If *rawid
          FillMemory(*di\image, ImageSize, $01)
          
          Offst = 0
          For ExTrk = 0 To 682                          
            FillMemory( *di\image + Offst , 1, $4B )
            
            Offst + 256
          Next ExTrk                     
        EndIf 
        
        
        ;------------------------------------------------------/* get ptr To bam */
        *p = di_get_ts_addr(*di, *di\bam)              
        ;--------------------------------------------------------/* setup header */             
        *p\b[0] = 18
        *p\b[1] = 1
        *p\b[2] = 'A'
        *p\b[3] = 0
        
        ;-------------------------------------------------------- /* clear bam */
        FillMemory( *p + 4, $8c, 0)   
        
        ;-------------------------------------------------------- /* free blocks */              
        tsTrack = 0
        tsSectr = 0
        
        For tsTrack = 1 To di_tracks(*di)
          ts\track = tsTrack
          
          For tsSectr = 0 To di_sectors_per_track(*di, ts\track) -1
            ts\sector = tsSectr                    
            di_free_ts(*di, @ts)
            
          Next  tsSectr
          
        Next tsTrack
        
        ;------------------------------------------------------- /* allocate bam And dir */
        ts\track = 18
        ts\sector = 0
        di_alloc_ts(*di, @ts)
        ts\sector = 1
        di_alloc_ts(*di, @ts)
        
        ;------------------------------------------------------- /* copy name */
        FillMemory( *p + $90, 16, $a0)
        x = 0
        For i = 0 To 15
          c = *rawname\c[i]
          If c ! 0
            x + 1
          EndIf
        Next i     
        CopyMemory( *rawname, *p + $90, x)
        
        ;------------------------------------------------------- /* set id */
        
        ;         Disk format             |Tracks|Header 7/8|Dos type|DiskDos
        ;                                 |      |allsechdrs|        |vs.type
        ;        ============================================================
        ;         Original CBM DOS v2.6   |  35  | $0f  $0f |  "2A"  |$41/'A'
        ;        ------------------------------------------------------------
        ;         *SpeedDOS+              |  40  | $0f  $0f |  "2A"  |$41/'A'
        ;        ------------------------------------------------------------
        ;         ProfessionalDOS Initial |  35  | $0f  $0f |  "2A"  |$41/'A'
        ;           (Version 1/Prototype) |  40  | $0f  $0f |  "2A"  |$41/'A'
        ;        ------------------------------------------------------------
        ;         ProfDOS Release         |  40  | $0f  $0f |  "4A"  |$41/'A'
        ;        ------------------------------------------------------------
        ;         Dolphin-DOS 2.0/3.0     |  35  | $0f  $0f |  "2A'  |$41/'A'
        ;         Dolphin-DOS 2.0/3.0     |  40  | $0d  $0f |  "2A'  |$41/'A'
        ;        ------------------------------------------------------------
        ;         PrologicDOS 1541        |  35  | $0f  $0f |  "2A'  |$41/'A'
        ;         PrologicDOS 1541        |  40  | $0f  $0f |  "2P'  |$50/'P'
        ;         ProSpeed 1571 2.0       |  35  | $0f  $0f |  "2A'  |$41/'A'
        ;         ProSpeed 1571 2.0       |  40  | $0f  $0f |  "2P'  |$50/'P'
        ;        ------------------------------------------------------------    
        FillMemory( *p + $a0, 2, $a0)   
        If (*rawid)
          CopyMemory( *rawid, *p + $a2, 2)
        EndIf
        FillMemory( *p + $a4, 7, $a0) 
        
        Select  DosType
          Case 0:                        
            *p\b[$a5] = '2' 
            *p\b[$a6] = 'A'                        
          Case 1:
            *p\b[$a5] = '4'
            *p\b[$a6] = 'A'                        
          Case 2:
            *p\b[$a5] = '2'
            *p\b[$a6] = 'P'                         
        EndSelect
        
        
        ;------------------------------------------------------- /* clear unused bytes */
        FillMemory(*p + $ab, $55, 0)
        
        ;------------------------------------------------------- /* clear first dir block */      
        FillMemory( *p + 256, 256, 0) 
        *p\b[257] = $ff
        
        ;------------------------------------------------------- /* Adding Infos
        Select ImageSize
          Case 175531: FillMemory( *p + 83456, 683, 01)       ; Sector Error Info
            
          Case 196608:                                        ; Extended Tracks
            ExTrk = 0: Offst = 83456 
            For ExTrk = 0 To 84                          
              *p\b[Offst  ] = $4B
              *p\b[Offst+1] = $01
              FillMemory( *p + Offst +2, 254, 01)
              Offst + 256
            Next ExTrk
            FillMemory( *p + 192   ,  20, $01FFFF11, #PB_Long); Mark as Free
            
          Case 197376:                                        ; Extended Tracks & Sector Error Info
            ExTrk = 0: Offst = 83456 
            For ExTrk = 0 To 84                          
              *p\b[Offst  ] = $4B
              *p\b[Offst+1] = $01
              FillMemory( *p + Offst +2, 254, 01)
              Offst + 256
            Next ExTrk 
            
            FillMemory( *p + Offst , 768, 01)
            FillMemory( *p + 192   ,  20, $01FFFF11, #PB_Long); Mark as Free
        EndSelect
        
        
        
      Case #D71
        ;------------------------------------------------------- /* erase disk */
        If *rawid
          FillMemory( *di\image, ImageSize, 0)    
        EndIf   
        ;------------------------------------------------------- /* get ptr To bam2 */
        *p = di_get_ts_addr(*di, *di\bam2)
        
        ;------------------------------------------------------- /* clear bam2 */
        FillMemory(*p, 256, 0)
        
        ;------------------------------------------------------- /* get ptr To bam */
        *p = di_get_ts_addr(*di, *di\bam)                             
        *p\b[0] = 18
        *p\b[1] = 1
        *p\b[2] = 'A'
        *p\b[3] = $80  
        
        ;--------------------------------------------------------/* clear bam */              
        FillMemory( *p + 4, $8c, 0)
        
        
        ;--------------------------------------------------------/* clear bam2 counters */              
        FillMemory(*p + $dd, $23, 0)
        
        ;-------------------------------------------------------- /* free blocks */              
        tsTrack = 0
        tsSectr = 0
        
        For tsTrack = 1 To di_tracks(*di)
          ts\track = tsTrack
          If ts\track ! 53
            For tsSectr = 0 To di_sectors_per_track(*di, ts\track) -1
              ts\sector = tsSectr                     
              di_free_ts(*di, @ts)                                              
            Next  tsSectr
          EndIf
          
        Next tsTrack         
        
        ;-------------------------------------------------------- /* free blocks bam 2*/              
        di_free_ts_bam2(*di, @ts)                                                   
        
        ;-------------------------------------------------------- /* allocate bam And dir */
        ts\track = 18
        ts\sector = 0
        di_alloc_ts(*di, @ts)
        ts\sector = 1
        di_alloc_ts(*di, @ts)
        
        ;------------------------------------------------------- /* copy name */
        FillMemory( *p + $90, 16, $a0)
        x = 0
        For i = 0 To 15
          c.a = *rawname\c[i]
          If c ! 0
            x + 1
          EndIf
        Next i    
        CopyMemory( *rawname, *p + $90, x)
        
        ;------------------------------------------------------- /* set id */
        FillMemory( *p + $a0, 2, $a0)   
        If (*rawid)
          CopyMemory( *rawid, *p + $a2, 2)
        EndIf
        FillMemory( *p + $a4, 7, $a0)                  
        *p\b[$a5] = '2'
        *p\b[$a6] = 'A'
        
        ;------------------------------------------------------- /* clear unused bytes */
        FillMemory(*p + $ab, $32, 0)
        
        ;------------------------------------------------------- /* clear first dir block */
        FillMemory(*p + 256, 256, 0)
        *p\b[257] = $ff
        ;------------------------------------------------------- /* Adding Infos
        Select ImageSize
          Case 351062: FillMemory( *p + 258304, 1366, 01)       ; Sector Error Info
          Default                        
        EndSelect
        
      Case #D81
        ;------------------------------------------------------- /* erase disk */
        If ( *rawid )
          FillMemory( *di\image, ImageSize, 0)    
        EndIf 
        ;------------------------------------------------------- /* get ptr To bam */
        *p = di_get_ts_addr(*di, *di\bam)  
        
        ;--------------------------------------------------------/* setup header */ and /* set id */
        *p\b[0] = $28
        *p\b[1] = $02
        *p\b[2] = $44
        *p\b[3] = $BB
        *p\b[4] = *rawid\c[0]
        *p\b[5] = *rawid\c[1]              
        *p\b[6] = $c0            
        ;--------------------------------------------------------/* clear bam */                            
        FillMemory( *p + 7, $fa, 0) 
        
        ;--------------------------------------------------------/* get ptr To bam2 */
        *p = di_get_ts_addr(*di, *di\bam2)             
        
        ;--------------------------------------------------------/* setup header */ and /* set id */ Bam 2
        *p\b[0] = $00
        *p\b[1] = $ff
        *p\b[2] = $44
        *p\b[3] = $bb
        *p\b[4] = *rawid\c[0]
        *p\b[5] = *rawid\c[1]                
        *p\b[6] = $c0              
        
        ;--------------------------------------------------------/* set id */
        
        ;--------------------------------------------------------/* clear bam */                            
        FillMemory( *p + 7, $fa, 0)               
        
        ;--------------------------------------------------------/* free blocks */              
        tsTrack = 0
        tsSectr = 0
        
        For tsTrack = 1 To di_tracks(*di)
          ts\track = tsTrack
          For tsSectr = 0 To di_sectors_per_track(*di, ts\track) -1
            ts\sector = tsSectr   
            di_free_ts(*di, @ts)                                              
          Next tsSectr                  
        Next tsTrack                
        
        ;--------------------------------------------------------/* allocate bam And dir */
        ts\track = 40
        ts\sector = 0
        di_alloc_ts(*di, @ts)
        ts\sector = 1
        di_alloc_ts(*di, @ts)
        ts\sector = 2
        di_alloc_ts(*di, @ts)
        ts\sector = 3
        di_alloc_ts(*di, @ts)
        
        ;--------------------------------------------------------/* get ptr To dir */
        *p = di_get_ts_addr(*di, *di\dir)
        
        ;--------------------------------------------------------/* copy name */              
        *p\b[0] = $28
        *p\b[1] = $03
        *p\b[2] = $44              
        
        FillMemory( *p + 4, 16, $a0)
        x = 0
        For i = 0 To 15
          c.a = *rawname\c[i]
          If c ! 0
            x + 1
          EndIf
        Next i    
        
        CopyMemory( *rawname, *p + 4, x)              
        
        ;--------------------------------------------------------/* set id */
        FillMemory( *p + $14, 2, $a0)
        If (*rawid)                   
          CopyMemory( *rawid, *p + $16, 2)                     ; Copy ID the Directory name
        EndIf
        
        FillMemory(*p + $18, 5, $a0);
        *p\b[$19] = '3'
        *p\b[$1A] = 'D'
        
        ;--------------------------------------------------------/* clear unused bytes */
        FillMemory(*p + $1D, $E3, 0);              
        
        ;--------------------------------------------------------/* clear first dir block */
        FillMemory(*p + 768, 256, 0);
        *p\b[769] = $ff   
        
      Case #D80
        ;------------------------------------------------------- /* erase disk */
        If ( *rawid )
          FillMemory( *di\image, ImageSize, 0)    
        EndIf 
        ;------------------------------------------------------- /* get ptr To bam */
        *p = di_get_ts_addr(*di, *di\bam)             
    EndSelect
    
    *di\blocksfree = blocks_free(*di)
    
    set_status(*di, 0, 0, 0)
    
    ProcedureReturn *di
    
  EndProcedure
  ;*********************************************************************************************************
  ;        
  ;_________________________________________________________________________________________________________      
  Procedure.s di_Set_CharSet(OldFileName$)
    
    Protected NewFileName$, i.i, asci.i
    
    
    For i = 1 To Len(OldFileName$)
      
      asci = Asc( Mid(OldFileName$, i, 1) )
      
      Select asci
        Case  65: NewFileName$ + Chr(asci+32)
        Case  66: NewFileName$ + Chr(asci+32)                   
        Case  67: NewFileName$ + Chr(asci+32)   
        Case  68: NewFileName$ + Chr(asci+32)
        Case  69: NewFileName$ + Chr(asci+32)                   
        Case  70: NewFileName$ + Chr(asci+32)                      
        Case  71: NewFileName$ + Chr(asci+32)   
        Case  72: NewFileName$ + Chr(asci+32)   
        Case  73: NewFileName$ + Chr(asci+32)   
        Case  74: NewFileName$ + Chr(asci+32)   
        Case  75: NewFileName$ + Chr(asci+32)   
        Case  76: NewFileName$ + Chr(asci+32)   
        Case  77: NewFileName$ + Chr(asci+32)   
        Case  78: NewFileName$ + Chr(asci+32)   
        Case  79: NewFileName$ + Chr(asci+32)   
        Case  80: NewFileName$ + Chr(asci+32)     
        Case  81: NewFileName$ + Chr(asci+32)   
        Case  82: NewFileName$ + Chr(asci+32)   
        Case  83: NewFileName$ + Chr(asci+32)   
        Case  84: NewFileName$ + Chr(asci+32)   
        Case  85: NewFileName$ + Chr(asci+32)   
        Case  86: NewFileName$ + Chr(asci+32)   
        Case  87: NewFileName$ + Chr(asci+32)   
        Case  88: NewFileName$ + Chr(asci+32)   
        Case  89: NewFileName$ + Chr(asci+32)   
        Case  90: NewFileName$ + Chr(asci+32)  
          
          
        Case  97: NewFileName$ + Chr(asci-32)
        Case  98: NewFileName$ + Chr(asci-32)                   
        Case  99: NewFileName$ + Chr(asci-32)   
        Case 100: NewFileName$ + Chr(asci-32)
        Case 101: NewFileName$ + Chr(asci-32)                   
        Case 102: NewFileName$ + Chr(asci-32)                      
        Case 103: NewFileName$ + Chr(asci-32)   
        Case 104: NewFileName$ + Chr(asci-32)   
        Case 105: NewFileName$ + Chr(asci-32)   
        Case 106: NewFileName$ + Chr(asci-32)   
        Case 107: NewFileName$ + Chr(asci-32)   
        Case 108: NewFileName$ + Chr(asci-32)   
        Case 109: NewFileName$ + Chr(asci-32)   
        Case 110: NewFileName$ + Chr(asci-32)   
        Case 111: NewFileName$ + Chr(asci-32)   
        Case 112: NewFileName$ + Chr(asci-32)     
        Case 113: NewFileName$ + Chr(asci-32)   
        Case 114: NewFileName$ + Chr(asci-32)   
        Case 115: NewFileName$ + Chr(asci-32)   
        Case 116: NewFileName$ + Chr(asci-32)   
        Case 117: NewFileName$ + Chr(asci-32)   
        Case 118: NewFileName$ + Chr(asci-32)   
        Case 119: NewFileName$ + Chr(asci-32)   
        Case 120: NewFileName$ + Chr(asci-32)   
        Case 121: NewFileName$ + Chr(asci-32)   
        Case 122: NewFileName$ + Chr(asci-32)  
          
        Case 127: NewFileName$ + Chr(asci+32)                     
        Case 128: NewFileName$ + Chr(asci+32)                      
          
        Case 159: NewFileName$ + Chr(asci-32)                     
        Case 160: NewFileName$ + Chr(asci-32)  
        Default
          NewFileName$ + Chr(asci) 
      EndSelect                     
    Next
    ProcedureReturn NewFileName$
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Do Listing
  ;--------------------------------------------------------------------------------------------------------- 
  Procedure.i di_Get_List(*imgfile.ImageFile)
    ;LoadC64List(*imgfile\FileList(), CBMDiskImage::CBMDirectoryList())
    CopyList(*imgfile\FileList(), CBMDiskImage::CBMDirectoryList())
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Test and Show BAM
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.s di_load_bam(*di.DiskImage)
    
    Protected FreeSector.i, FullBamLstings$, S$, Free$
    Protected CurrenTrack.i , CurrenSectr.i, free.i, Blocks.i, Sector.i
    
    S$ = "TRACK" +#TAB$+ "FREE/ DEFAULT"+#TAB$+"(SECT.IN)"+#TAB$+"MAP > BAM OVERVIEW ([ ]: FREE/ [*]:FULL)" + #CRLF$
    FullBamLstings$ + S$
    
    
    Static ts.TrackSector
    
    CurrenTrack = ts\track
    CurrenSectr = ts\sector
    
    For CurrenTrack = 1 To di_tracks( *di )           
      ts\track   = CurrenTrack   
      free =  di_track_blocks_free(*di, CurrenTrack)        ; Get Free Blocks From Current Track
      
      Free$ = ""
      Blocks = di_get_block_pa_sectors(*di, @ts)            ; Get Max Blocks from Current Track
      Sector = di_sectors_per_track(*di, CurrenTrack)       ; Get Max Sector from Current Track
      
      For CurrenSectr = 0 To Sector-1            
        ts\sector  = CurrenSectr
        
        FreeSector = di_is_ts_free(*di, @ts)                ; Is Current Sector Free ? 0 (used) / Free
        
        Select FreeSector
          Case 0
            Free$ + "|*"               
          Default
            Free$ + "|-"                       
        EndSelect                       
      Next
      ts\track = 0
      ts\sector = 0
      Free$ + "|"
      
      S$ = " "+Str(CurrenTrack) + ":  "+#TAB$+ RSet( Str(free),2,"0")+" / "+Str(CurrenSectr)+#TAB$+" ( "+RSet(Str(Blocks),4,"0")+" )" +#TAB$+ Free$ +#CRLF$
      
      FullBamLstings$ + S$
    Next       
    FullBamLstings$ + #CRLF$
    ProcedureReturn FullBamLstings$        
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Return Disk Image Format
  ;---------------------------------------------------------------------------------------------------------         
  Procedure.s di_get_FormatImage(*di.DiskImage)
    
    Protected Result$
    
    If *di <> 0 And *di <> -1 And *di <> -2
      
      Select *di\Type
        Case #D64 : Result$ = "D64"
        Case #D71 : Result$ = "D71"
        Case #D80 : Result$ = "D80"
        Case #D81 : Result$ = "D81"
        Case #D82 : Result$ = "D82"
      EndSelect
      
    EndIf
    
    ProcedureReturn Result$
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Return Disk Filename
  ;---------------------------------------------------------------------------------------------------------         
  Procedure.s di_get_Filename(*di.DiskImage, Fullpath.i = #False)
    
    Protected Result$
    
    
    If *di <> 0 And *di <> -1 And *di <> -2
      Select Fullpath
        Case #False
          Result$ = *di\filename
        Case #True
          Result$ = *di\filepath + *di\filename
      EndSelect
    EndIf
    
    ProcedureReturn Result$
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Return Free Blocks Of the C64 Disk Image
  ;---------------------------------------------------------------------------------------------------------         
  Procedure.i di_sho_FreeBlocks(*di.DiskImage)
    
    If *di = 0
      ProcedureReturn 0
    ElseIf *di = -1
      ProcedureReturn -1
    ElseIf *di = -2
      ProcedureReturn -2
    EndIf
    
    ProcedureReturn *di\blocksfree
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Get C64 Disk Image Title
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.s di_Get_TitleHead(*di.DiskImage)
    
    Protected TitleLenght.i = 0, Title.s = "", *name.char
    
    If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
      ProcedureReturn ""
    EndIf
    
    *name  = AllocateMemory(16)
    
    ;Convert title To ascii
    TitleLenght.i = di_name_from_rawname(*name.char, di_title(*di) )        
    ;ptoa(*name)
    
    Title.s = PeekS(*name, TitleLenght ,#PB_Ascii )        
    ProcedureReturn Title.s
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Get C64 Disk Image ID
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.s di_Get_Title_ID(*di.DiskImage)
    
    Protected TitleLenght.i, ident.s, *id.char
    
    If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
      ProcedureReturn ""
    EndIf
    *id  = AllocateMemory(6)
    
    CopyMemory(di_title(*di) +18 , *id.char, 6)    ; Convert ID To ascii
    
    *id\c[5] = 0
    
    ;ptoa(*id,6)
    
    ident = PeekS(*id, 5, #PB_Ascii)
    
    ProcedureReturn ident
    
  EndProcedure   
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Get C64 Disk Image ID
  ;---------------------------------------------------------------------------------------------------------
  Procedure.s CBM_Disk_Image_Tools(DiskImage$, Selection.s = "title")
    
    Protected *di.DiskImage, *imgfile.ImageFile, *er.LastError, Result$
    
    
    *di = di_load_image(DiskImage$)
    If *di = 0
      Result$ = "Couldn't Load Disk Image: " + DiskImage$ + #CR$
      Result$ + *er
      ProcedureReturn Result$
    EndIf
    
    
    Select UCase(Selection)
      Case "TITLE"    : Result$ = di_Get_TitleHead(*di)        ; Return Title
      Case "ID"       : Result$ = di_Get_Title_ID(*di)         ; Return Disk ID
      Case "FILE"     : Result$ = di_get_Filename(*di)         ; Return Filename
      Case "PATHFILE" : Result$ = di_get_Filename(*di,#True)   ; Return Filename              
      Case "FREE"     : Result$ = Str( di_sho_FreeBlocks(*di) ); Return Free Blocks
      Case "FORMAT"   : Result$ = di_get_FormatImage(*di)      ; Show DiskImage Format
      Case "BAM"      : Result$ = di_load_bam(*di) 
    EndSelect         
    
    di_free_image(*di)         
    
    ProcedureReturn Result$
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Format N:testdisk,88,C:\Purebasic, D64,false
  ; ExTracks: 0 = Default, 1 = With Error Info, 2 = Extened Tracks, 3 =  Extended Tracks & Error Info
  ; DosType = 0:  Original CBM DOS v2.6 
  ;              *SpeedDOS+
  ;               ProfessionalDOS Initial (Version 1/Prototype)
  ;               Dolphin-DOS 2.0/3.0 (35 Tracks)
  ;               Dolphin-DOS 2.0/3.0 (40 Tracks)
  ;               PrologicDOS 1541 (35 Tracks)
  ;               ProSpeed 1571 2.0 (35 Tracks)
  ; 
  ;           1:  ProfDOS Release (40 Tracks)
  ; 
  ;           2:  PrologicDOS 1541 (40 Tracks)
  ;               ProSpeed 1571 2.0 (40 Tracks)
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.i N(ImageFile$ = "", Title$ = "testdisk", DiskID$ = "id", Format.i = #D64 , ExTracks.i = 0, DOSType.i = 0)
    
    Protected ImageSize.q, *Title.char, *Buffer.char, *id.CharID, FileName$, *di.DiskImage, *er.LastError
    
    If ImageFile$ = ""
      CBMDiskImage::*er\s = "No path and file name selected"
      ProcedureReturn -1
    EndIf                        
    
    If ExTracks >= 4
      CBMDiskImage::*er\s = "Error on Extended Tracks Command (Max Value: 3)"
      ProcedureReturn -1
    EndIf
    
    If DOSType >= 3
      CBMDiskImage::*er\s = "Error on Dos Type Command (Max Value: 2)"
      ProcedureReturn -1
    EndIf
    
    Select Format
      Case #D64
        If ( ExTracks = 0 Or ExTracks = 1) And ( DOSType = 1 Or DOSType = 2 )
          CBMDiskImage::*er\s = "False Disk DosType for 35 Tracks selected"
          ProcedureReturn  -1
        EndIf                  
        
        Select ExTracks
          Case 0: ImageSize = 174848  ; Standard
          Case 1: ImageSize = 175531  ; Standard + Sector Error Info
          Case 2: ImageSize = 196608  ; Extended 40 Tracks
          Case 3: ImageSize = 197376  ; Extended 40 Tracks + + Sector Error Info
        EndSelect                   
        ImageFile$ + ".D64"
        
      Case #D71
        Select ExTracks                    
          Case 0: ImageSize = 349696  ; Standard
          Case 1: ImageSize = 351062  ; Standard + Sector Error Info                          
        EndSelect        
        ImageFile$ + ".D71"
        
      Case #D81
        ImageSize = 819200
        ImageFile$ + ".D81"
        
      Default
        CBMDiskImage::*er\s = "Pattern: Format is Not supported"
        ProcedureReturn -1
        
    EndSelect       
    
    *di = di_create_image(ImageFile$, ImageSize)
    
    If ( Len( Title$ ) >= 17 )
      Title$ = Left( Title$ , 16) 
    EndIf    
    
    *Buffer = AllocateMemory(16)
    *Title  = AllocateMemory(16)     
    *id     = AllocateMemory(2)              
    
    PokeS(*Title, Title$, 16, #PB_Ascii)
    
    atop( *Title, 16 )            
    
    di_rawname_from_name( *Buffer, *Title)        ; /* Convert title */ 
    
    If (DiskID$)
      PokeS(*id, DiskID$, 2, #PB_Ascii)
    Else 
      PokeS(*id, "id", 2, #PB_Ascii)
    EndIf         
    
    atop( *id,  2 ) 
    
    di_format(*di, *Buffer, *id, ImageSize, DOSType);
    
    di_free_image(*di);
    
    FreeMemory(*id): FreeMemory(*Title): FreeMemory(*Buffer): CBMDiskImage::*er\s = ""
    ProcedureReturn 0
  EndProcedure     
  ;---------------------------------------------------------------------------------------------------------
  ; Copy File
  ;   CopyTo$ = "HD" : Copy a File FROM Image to PC HD
  ;   CopyTo$ = "DS" : Copy a File FROM PC HD to Image
  ;
  ;   SaveConversion = 0: Standard CBM File           (Only Important save to HD)
  ;   SaveConversion = 1: PC64 File (*.p00 etc..)     (Only Important save to HD)
  ;
  ;--------------------------------------------------------------------------------------------------------- 
  Procedure.i C_Sub_Prepare(FN$, CopyTo$ ,DIR$)        
    
    If ( Len(FN$) = 0 )
      SetError( "No C64 Filename Selected")
      ProcedureReturn -1
    EndIf            
    
    Select CopyTo$
      Case "HD"
      Case "DS"
        If ( FileSize(DIR$ + FN$) = -1 )
          CBMDiskImage::*er\s = "File "+ Chr(34) + FN$ + Chr(34) + " Not Found"
          ProcedureReturn -1
        EndIf
      Default
        CBMDiskImage::*er\s = "Error On Copy Command"
        ProcedureReturn -1
    EndSelect         
    ProcedureReturn 0
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i C_Sub_ReadBytes(*fi.ImageFile)
    
    Protected *buffer.CharBuffer, Bytes.i
    
    *buffer   = AllocateMemory(1048576)   ; For a single file, it should be big enough
    If ( *buffer )
      
      Bytes.i = di_read(*fi, *buffer, MemorySize(*buffer))
      
      If ( Bytes = 0 )
        SetError("Could'nt File Read")                  
      EndIf
      
      *buffer = ReAllocateMemory(*buffer, Bytes)
      ProcedureReturn *buffer
    Else              
      SetError("Could'nt Allocate Memory")
    EndIf
    ProcedureReturn 
  EndProcedure         
  ;---------------------------------------------------------------------------------------------------------         
  Procedure.s C_Sub_SavePattern(*di.DiskImage, FN$, SaveConversion.i)   
    
    Protected  SF$, Pattern$, Wildc64$
    
    Select *di\pattern\o
      Case "DEL", "*DEL", "DEL<"
        Pattern$ = "PC64(*.d00)|*.d00"
        Wildc64$ = "d00"
        
      Case "SEQ", "*SEQ", "SEQ<" 
        Pattern$ = "PC64(*.s00)|*.s00"                 
        Wildc64$ = "s00"
        
      Case "PRG", "*PRG", "PRG<"
        Pattern$ = "PC64(*.p00)|*.p00" 
        Wildc64$ = "p00"
        
      Case "USR", "*USR", "USR<"
        Pattern$ = "PC64(*.u00)|*.u00"                
        Wildc64$ ="u00"
        
      Case "REL", "*REL", "REL<"
        Pattern$ = "PC64(*.r00)|*.r00" 
        Wildc64$ = "r00"
        
    EndSelect
    Pattern$ = "CBM (*."+*di\pattern\s +")|*."+*di\pattern\s +"|" + Pattern$
    
    Select  SaveConversion
      Case 0: FN$ = FN$ + "." + *di\pattern\s
      Case 1: FN$ = FN$ + "." +  Wildc64$   
    EndSelect
    
    ; -------------------------------------------------------------------------- Save File Requester                
    
    FN$ = ptoa_CompatibilityMode(FN$)
    ProcedureReturn FN$                   
  EndProcedure
  ;--------------------------------------------------------------------------------------------------------- 
  Procedure.i C_Sub_SaveBytes(*buffer.offset, FN$, DIR$, Lenght.i)
    
    Protected  bytes.i
    Define SaveFile = CreateFile( #PB_Any, DIR$ + FN$ )               
    
    If ( SaveFile )
      bytes = WriteData(SaveFile, *Buffer, Lenght)
      
      CloseFile(SaveFile)              
      
      If ( bytes = Lenght)  And ( FileSize(DIR$ + FN$) = bytes )
        ProcedureReturn 0
      Else
        SetError("Could'nt write file")
      EndIf     
    EndIf  
    
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------       
  Procedure.i C_Sub_MakePC64(*buffer.offset, FN$, Lenght)
    
    Protected  PC64ByteSize.i, PC64FileLen.i, PC64ShiftUp$, *PC64BufferName.char ,*PC64BufferTotal.ByteArrayStructure
    
    PC64ByteSize =  Lenght + 26
    PC64FileLen  = Len( "C64File "+ FN$)
    PC64ShiftUp$ = "C64File " + FN$
    
    *PC64BufferName = AllocateMemory(PC64FileLen)
    *PC64BufferTotal= AllocateMemory(PC64ByteSize) 
    If ( *PC64BufferName = 0 )
      SetError("Could'nt Allocate Memory")
    EndIf
    
    If ( *PC64BufferTotal = 0 )
      SetError("Could'nt Allocate Memory")
    EndIf        
    
    PokeS( *PC64BufferName, PC64ShiftUp$ , -1, #PB_Ascii)
    *PC64BufferName\c[7] = $00            
    
    FillMemory( *PC64BufferTotal, PC64ByteSize , 0)         
    
    CopyMemory( *PC64BufferName, *PC64BufferTotal ,MemorySize( *PC64BufferName ) )
    CopyMemory( *buffer, *PC64BufferTotal + $1A,  Lenght )        
    
    FreeMemory(*PC64BufferName)    
    
    ProcedureReturn  *PC64BufferTotal                      
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------    
  Procedure.i C_Sub_ReadPC64_Name(DIR$, FN$)
    
    Protected PC64File.i
    Protected *buffer
    
    
    PC64File = ReadFile(#PB_Any, DIR$ + FN$, #PB_File_SharedRead| #PB_File_SharedWrite) 
    If PC64File
      
      *buffer  = AllocateMemory(16)
      
      If ReadData(PC64File, *buffer, 7) = 7
        
        If PeekS(*buffer, 7, #PB_Ascii) = "C64File"
          If ReadData(PC64File, *buffer, 16) = 16
            Debug PeekS(*buffer, 16, #PB_Ascii)
          Else
            FreeMemory(*buffer)
            *buffer = #Null
          EndIf
        Else
          SetError("File is't PC64 Format")
          FreeMemory(*buffer)
          *buffer = #Null
        EndIf
        
      EndIf
      
      CloseFile(PC64File)
    EndIf
    
    ProcedureReturn *buffer
    
  EndProcedure
  ;---------------------------------------------------------------------------------------------------------      
  Procedure.i C_Sub_Write_PC64(*imgfile.ImageFile, *di.DiskImage, DIR$, FN$)
    
    Protected PC64Size.q, *buffer.offset, PC64File.i, bytes.i
    
    PC64Size.q = FileSize(DIR$ + FN$) - 26
    *buffer  = AllocateMemory(PC64Size)
    
    PC64File = OpenFile( 0, DIR$ + FN$, #PB_File_SharedRead | #PB_File_SharedWrite)
    If PC64File
      If ReadFile(PC64File, DIR$ + FN$, #PB_File_SharedRead| #PB_File_SharedWrite) 
        
        FileSeek( PC64File,  26)
        bytes = ReadData(PC64File, *buffer, PC64Size)
        
        If (di_write(*imgfile, *buffer, bytes ,*di) !bytes )
          SetError("Could'nt Write File ("+FN$+") To Disk")
        EndIf                 
        
      Else
        SetError("Could'nt Open and Read File " + FN$)                
      EndIf
      CloseFile(PC64File)
    EndIf
  EndProcedure 
  ;---------------------------------------------------------------------------------------------------------         
  Procedure.i C_Sub_WriteBytes(*imgfile.ImageFile, *di.DiskImage, DIR$, FN$)
    
    Protected  FileLenght.i, Position.i, ReadBytes.i, *infile, bytes.i, WriteFile.a
    
    
    WriteFile = OpenFile( 0, DIR$ + FN$, #PB_File_SharedRead | #PB_File_SharedWrite)
    If ( WriteFile )
      If ReadFile(WriteFile, DIR$ + FN$, #PB_File_SharedRead| #PB_File_SharedWrite) 
        FileLenght  = Lof(WriteFile) 
        Position    = 0
        ReadBytes   = FileSize(DIR$ + FN$)
        
        FileSeek(WriteFile, Position)
        
        While FileLenght
          
          *infile = AllocateMemory(ReadBytes) 
          If *infile
            bytes = ReadData(WriteFile, *infile, ReadBytes)
            
            If (di_write(*imgfile, *infile, bytes ,*di) !bytes )
              SetError("Could'nt Write File ("+FN$+") To Disk")
            EndIf 
            
            Position    + bytes
            FileSeek(WriteFile, Position)
            
            If FileLenght = Position
              Break;
            EndIf
            
          EndIf
        Wend  
        CloseFile(WriteFile)
      Else
        SetError("Could'nt Open and Read File " + FN$)                
      EndIf
    EndIf
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------     
  Procedure.i C(ImageFile$ = "", DIR$ = "", FN$ = "", CopyTo$ = "HD", SaveConversion.i = 0)
    
    Protected *di.DiskImage, *fi.ImageFile, *out, Pattern.i, Mode$, Result.i, WritePC64.i
    Protected *cbmfile, *rawfile
    
    If C_Sub_Prepare(FN$, CopyTo$ ,DIR$) = -1
      ProcedureReturn -1
    EndIf 
    
    *cbmfile  = AllocateMemory(16)
    *rawfile  = AllocateMemory(16)
    
    
    ; Extract P00 Name
    Pattern = Filetype_GetP00(FN$)
    If Pattern >= 0 And CopyTo$ = "DS"
      FreeMemory(*cbmfile)
      *cbmfile = C_Sub_ReadPC64_Name(DIR$, FN$)
      If *cbmfile = -1
        ProcedureReturn  -1
      EndIf
      WritePC64 = #True
      
    Else                      
      Pattern.i = Filetype_Set(FN$)
      If Pattern = -1
        SetError("Needed file extension")
      EndIf
      FN$ = Left( FN$, Len(FN$) - 4 )
      
      If CopyTo$ = "DS"
        FN$ = ptou_back(FN$) 
      EndIf 
      
      PokeS( *cbmfile, FN$, 16, #PB_Ascii ) 
      WritePC64 = #False
      
    EndIf
    
    
    Select CopyTo$
      Case "HD":Mode$ = "rb"               
      Case "DS":Mode$ = "wb": 
    EndSelect        
    
    *di = di_load_image(ImageFile$)
    If *di <= 0
      ProcedureReturn -1
    EndIf         
    
    di_rawname_from_name(*rawfile, *cbmfile)
    
    *fi = di_open(*di, *rawfile, Pattern ,Mode$)
    If *fi = #Null
      di_free_image(*di) 
      ProcedureReturn -1
    EndIf 
    
    
    Select CopyTo$
        ;
        ; Read, Create and Save File From Image to HD
      Case "HD":
        
        *out = C_Sub_ReadBytes(*fi)
        
        If *out = -1
          di_free_image(*di)
          ProcedureReturn -1
        EndIf              
        
        If SaveConversion = 1
          *out = C_Sub_MakePC64(*out, FN$, MemorySize(*out))
          If *out = #Null
            ProcedureReturn -1
          EndIf    
        EndIf
        
        FN$ = ptou(FN$)               
        FN$ = C_Sub_SavePattern(*di.DiskImage, FN$, SaveConversion.i) 
        
        di_close(*fi)
        di_free_image(*di)
        FreeMemory(*cbmfile): 
        FreeMemory(*rawfile)                                  
        
        If C_Sub_SaveBytes( *out, FN$, DIR$, MemorySize(*out) ) = -1
          FreeMemory(*out) 
          ProcedureReturn -1
        EndIf 
        FreeMemory(*out) 
        ;
        ; Write File to C64 Disk Image
      Case "DS":
        
        FreeMemory(*cbmfile)
        FreeMemory(*rawfile)                                  
        If Not WritePC64
          FN$+ "." + Filetype_Get(Pattern)
        EndIf                         
        
        If WritePC64
          If C_Sub_Write_PC64(*fi, *di, DIR$, FN$) = -1
            di_close(*fi)
            di_free_image(*di)
            ProcedureReturn -1
          EndIf
        Else
          If C_Sub_WriteBytes(*fi, *di, DIR$, FN$) = -1
            di_close(*fi)
            di_free_image(*di)
            ProcedureReturn -1
          EndIf
        EndIf
        di_close(*fi)
        di_free_image(*di)
    EndSelect
    
    ProcedureReturn 0
    
  EndProcedure
  
  
  ;---------------------------------------------------------------------------------------------------------
  ; Test Directory and Show Disk Bam
  ;---------------------------------------------------------------------------------------------------------      
  Procedure.s CBM_Load_Directory(DiskImage$)        
    Protected *di.DiskImage
    Protected *imgfile.ImageFile        
    
    ClearList ( CBMDiskImage::CBMDirectoryList() )
    
    *di = di_load_image(DiskImage$)
    If ( *di = 0 )
      Debug "Couldn't Load Disk Image: " + DiskImage$
      Debug UCase( di_get_error_OpenDiskImage(CBMDiskImage::*er) )
      ProcedureReturn
    EndIf 
    
    *imgfile = di_open(*di, '$', 2 ,"rb")
    If ( *imgfile = 0 )
      Debug UCase ("Couldn't open directory for Disk Image: " + DiskImage$ )
      ProcedureReturn
    EndIf      
    
    *imgfile = di_read_directory_blocks(*imgfile)   
    If ( *imgfile = 0 )
      Debug UCase( "BAM Read failed for Disk Image: " + DiskImage$ )
      ProcedureReturn
    EndIf
    
    di_Get_List(*imgfile)
    
    di_close(*imgfile)        
    di_free_image(*di) 
    
    ProcedureReturn 
  EndProcedure            
  ;---------------------------------------------------------------------------------------------------------
  ; Test Directory and Show Disk Bam
  ;---------------------------------------------------------------------------------------------------------   
  Procedure.i CBM_Test_Full_Info(DiskImage$, HidePattern$ = "")
    
    Protected *di.DiskImage, *imgfile.ImageFile, *er.LastError
    Protected CBMFileSize.i, CBMFileName.s, CBMFileType.s
    
    *di = di_load_image(DiskImage$)
    If ( *di = 0 )
      Debug "Couldn't Load Disk Image: " + DiskImage$
      ProcedureReturn
    EndIf         
    
    *imgfile = di_open(*di, '$', 2 ,"rb")
    If ( *imgfile = 0 )
      Debug "Couldn't open directory for Disk Image: " + DiskImage$
      ProcedureReturn
    EndIf      
    
    *imgfile = di_read_directory_blocks(*imgfile)   
    If ( *imgfile = 0 )
      Debug "BAM Read failed for Disk Image: " + DiskImage$
      ProcedureReturn
    EndIf
    
    di_Get_List(*imgfile)
    
    Debug "| DISK   :" + di_Set_CharSet( di_get_Filename(*di) )
    Debug "| FORMAT :" + di_get_FormatImage(*di)
    Debug "| --------------------------------| DISK ID |"
    Debug "| DISK NAME  :  0 " + Chr(34) + LSet( di_Get_TitleHead(*di),16,Chr(32) ) + Chr(34)  + " "+di_Get_Title_ID(*di) 
    
    While NextElement( CBMDiskImage::CBMDirectoryList() )
      CBMFileSize = CBMDiskImage::CBMDirectoryList()\C64Size
      CBMFileName = CBMDiskImage::CBMDirectoryList()\C64File
      CBMFileType = CBMDiskImage::CBMDirectoryList()\C64Type
      
      If ( FindString( CBMFileType, HidePattern$ , 1) = 0 )                  
        Debug "| FILE NAME  :"+ RSet( Str( CBMFileSize ),3,Chr(32)) +" "+ Chr(34) + LSet( CBMFileName ,16,Chr(32) ) + Chr(34) + CBMFileType
      EndIf    
    Wend        
    
    Debug "| FREE BLOCKS: " + Str(di_sho_FreeBlocks(*di))
    Debug "| TEST DSKBAM: " + #CRLF$
    
    Debug di_load_bam(*di)   
    Debug "| ---------------------------------------|" +#CRLF$+#CRLF$              
    
    di_close(*imgfile)
    di_free_image(*di)                
  EndProcedure   
EndModule

CompilerIf #PB_Compiler_IsMainFile
  ;
  ; Creata a D64 Image
  If CBMDiskImage::N("c:\purebasic", "testdisk", "88", CBMDiskImage::#D64 , 2) = -1
    Debug CBMDiskImage::*er\s
  EndIf
  
  ; CBMDiskImage::CBM_Test_Full_Info("B:\FUR DIE SCHULE,DiskID-2A  1.d64")
  ; If CBMDiskImage::C("B:\FUR DIE SCHULE,DiskID-2A  1.d64", "C:\", "ÍÐÓ 1000/ÉÂÍ.PRG", "HD") = -1
  ;     Debug CBMDiskImage::*er\s
  ; EndIf
  ; If CBMDiskImage::C("B:\Hexenküche2.d64", "C:\", "hexenkueche ii.PRG", "HD") = -1
  ;     Debug CBMDiskImage::*er\s
  ; EndIf
  ; 
  If CBMDiskImage::C("C:\purebasic.D64", "C:\", "rick dangr+3-pan.prg", "DS") = -1
    Debug CBMDiskImage::*er\s
  EndIf
  
  If CBMDiskImage::C("C:\purebasic.D64", "C:\", "hexenkueche ii.prg", "DS") = -1
    Debug CBMDiskImage::*er\s
  EndIf  
  
  If CBMDiskImage::C("C:\purebasic.D64", "C:\", "••˜cccrun.prg", "DS") = -1
    Debug CBMDiskImage::*er\s
  EndIf   
  
  If CBMDiskImage::C("C:\purebasic.D64", "C:\", "barbarian cp-rdi.prg", "DS") = -1
    Debug CBMDiskImage::*er\s
  EndIf  
  
  If CBMDiskImage::C("C:\purebasic.D64", "C:\", "batman[dcs].prg", "DS") = -1
    Debug CBMDiskImage::*er\s
  EndIf       
  
CompilerEndIf
; IDE Options = PureBasic 5.71 LTS (Windows - x86)
; CursorPosition = 3426
; FirstLine = 3391
; Folding = -------------
; Markers = 1381,1389
; EnableXP
; CompileSourceDirectory