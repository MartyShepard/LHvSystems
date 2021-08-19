DeclareModule CBMDiskImage
    
    ; ----------------------------------------------------------------------    
    ; Purebasic CBM DiskImage Tools
    ; Engine Adapted from DiskImagery64 (Diskimage Source v0.95) 
    ; Engine Tape64 adapted from T64Fix 
    ;
    ; http://lallafa.de/blog/c64-projects/diskimagery64/
    ; https://sourceforge.net/p/diskimagery64/code/HEAD/tree/
    ;
    ; 
    ; Supportet Diskimages: D64, D71, D81, T64
    ; Directory Show with C64 Font Support, Opional Show *DEL Files
    ; ----------------------------------------------------------------------
    ;
    ; Create Disk Images (Scratch)
    ; D64: Support DosType version 2A, 4A, 2P
    ; Format Support D64: [Extended] [Sector Error] [Various DosTypes]
    ; Format Support D71: [--------] [Sector Error] [----------------]
    ; Format Support D81: [--------] [------------] [----------------]   
    ; Format Support T64: Create a new 256 Bytes Image with Header
    ;
    ; ----------------------------------------------------------------------
    ;
    ; Copy Support D64, D71, D81, T64
    ; Write Standard CBM Files:     From HD to Image
    ; Copy  Standard CBM Files:     From Image to HD    
    ; Write *.P00, *.S00, *.U00 etc.. to Image (Not yet T64)
    ; Save  *.P00, *.S00, *.U00 etc.. to HD    (Not yet T64)
    ; Write and Modifiy the Filetype ("*", "<")
    ; Write and add Text Files from HD to Image as SEQ Filetype
    ;
    ; ----------------------------------------------------------------------
    ; Verify and Fix for T64
    ;
    ; ----------------------------------------------------------------------
    ;
    ; Tools:
    ; Show Title, Show ID, Show Current File, Show Free Blocks
    ; Show Disk Image Format, Rename Files, Disk Bam View, Title Rename
    ; 
    ; ---------------------------------------------------------------------- 
    
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
    
    ; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
    Declare.i N(ImageFile$ = "", Format$ = "D64", Title$ = "testdisk", DiskID$ = "id", ExTracks.i = 0, DOSType.i = 0)                                   ; Create a new Disk Image
    Declare.i C(ImageFile$ = "", DIR$ = "", FN$ = "", PT$ ="", CopyTo$ = "HD", SaveAs$ = "", Container.i = 0, IsLock.i = #False, IsSplat.i = #False)    ; Copy/ Write a File from/to DiskImage
    Declare.i R(ImageFile$ = "", afn$="", nfn$="",apn$ = "", npn$ = "")                                                                                 ; Rename File
    Declare.i T(ImageFile$ = "", tn$="")                                                                                                                ; Rename Disk Title
    Declare.i S(ImageFile$ = "", sn$="",  sp$="")                                                                                                       ; Scratch File
    Declare.i V(ImageFile$, FixImage = #False, ReportOnlyErrors = #False)                                                                               ; Verfiy and Check
    
    Declare.i CBM_Load_Directory(DiskImage$)                                                                                                            ; Load & Show Directory
    Declare.s CBM_Disk_Image_Tools(DiskImage$, Selection.s = "TITLE")                                                                                   ; Additional Tools
    
    Declare.l CBMFontCharset1()                                                                                              ; Directory Font A. C64 Fixed 12' Font (Modified Amiga Fixplain7)
    Declare.l CBMFontCharset2()                                                                                              ; Directory Font B, C64 Fixed 12' Font (Modified Amiga Fixplain7)
    Declare.l CBMFontCharset3()                                                                                              ; Default Font, Amiga Fixplain7 12'
    ; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
    
    
    CompilerIf #PB_Compiler_IsMainFile
        Declare.s di_Set_CharSet(AFN$, Shifting = 0)
        Declare.l CBMFontCharset1()
        Declare.l CBMFontCharset2()            
        Declare.i CBM_Test_Full_Info(DiskImage$, HidePattern$ = "") ; Tester          
    CompilerEndIf
    ; ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------     
EndDeclareModule

Module CBMDiskImage
    
    
    Structure WriteProfil
        s1.a
        s2.a
        t1.a
        t2.a
        res1.a
        res2.a
        bpt1.a
        bpt2.a
        Boff.a
    EndStructure
    
    Structure BSect
        Sector.a
        Used.i
        ErrorCode.a
        ErrorDesc.s
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
    
    Structure sAdress
        c.a[2]
    EndStructure 
    
    Structure eAdress
        c.a[2]
    EndStructure     
    
    Structure reserved
        c.a[2]
    EndStructure 
    
    Structure OffsetIn
        c.a[4]
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
    
    Structure Unused
        c.a[4]
    EndStructure
    
    Structure SavePattern
        s.s
        o.s
        a.a
    EndStructure 
    
    Structure DiskDOSType
        Type.s
        Ident.s
    EndStructure
    
    Structure DebugModes
        write_info.i
        alloc_file_entry_info.i
    EndStructure 
    
    Structure BlocksPerFile
        Blocks.c
        Bytes.l
        KBytes.l
    EndStructure     
    
    Enumeration
        #T64_REC_OK     = 0
        #T64_REC_FIXED  = 1
        #T64_REC_SKIPPED= 2
    EndEnumeration
    
    Structure T64_Record
        Filename.rawname
        Offset.l
        StartAddr.l
        EndAddr.l
        Real_End_Addr.l
        C64s__FileType.b
        C1541_FileType.b
        Index.i
        Blocks.i
        Bytes.i
        Status.i
    EndStructure    
    
    Structure TapeKassette
        HeaderResult.i                ;Contains the Result of Tap String in The Header
        RecMax.i
        RecUse.i
        RecCurrrent.i
        Fixes.i
        Fixit.i
        TapeName.Rawname  
        List Records.T64_Record()
        List FixesDescriptions.s()
    EndStructure 
    
    Structure Diskimage
        dateiname.s
        dateipath.s
        size.i
        openfiles.i
        blocksfree.i
        modified.i
        status.i        
        Type.s
        SizeOffset.i
        ExtraType.i
        Tape.TapeKassette
        BlocksPerFile.BlocksPerFile
        DiskDOS.DiskDOSType                    
        bam.TrackSector
        bam2.TrackSector
        bam3.TrackSector
        dir.TrackSector     
        statusts.TrackSector 
        pattern.SavePattern
        error.TrackSector
        DebugInfo.DebugModes   
        *image
    EndStructure   
    
    Structure TapeDescr
        c.a[32]
    EndStructure   
    
    Structure TapeChar
        c.a[2]
    EndStructure 
    
    Structure UserDescr
        c.a[24]
    EndStructure  
    
    Structure TapHeader
        ;   000000: 43 36 34 53 20 74 61 70 65 20 69 6D 61 67 65 20   C64S.tape.image.
        ;   000010: 66 69 6C 65 00 00 00 00 00 00 00 00 00 00 00 00   file............
        ;         	  < ------------------------------------------>
        ;                               |
        ;                               |
        ;                               |Header, The first 32 bytes ($000000-00001F)
        ;                
        ; -----------------------------------------------------------------------------------
        ;   000020: 01 01 90 01 05 00 00 00 43 36 34 53 20 44 45 4D   ........C64S.DEM
        ;            \ /   \ /   \ /         |
        ;             |     |     |          |
        ;             |     |     |          |Tape container name, 24 characters, padded
        ;             |     |     |           with $20 (space)
        ;             |     |     |
        ;             |     |     Total number of used entries, once again in low/high     
        ;             |     |     byte (Used = $0005 = 5 entries.)
        ;             |     |
        ;             |     Maximum number of entries in the directory stored in 
        ;             |     low/high byte order (IN this Case $0190 = 400 total)
        ;             |
        ;             Tape version number of either $0100 Or $0101
        ; 
        ;  000030: 4F 20 54 41 50 45 20 20 20 20 20 20 20 20 20 20   O TAPE..........
        
        TapeDescr.TapeDescr   ;$00 - $1F
        Version.TapeChar      ;$20 - $21
        Rec_Max.TapeChar      ;$22 - $23
        Rec_Used.TapeChar     ;$24 - $25
        Reserved.TapeChar     ;$26 - $27 Not used
        UserDescr.UserDescr   ;$28 - $3F
    EndStructure   
    
    Structure TapDirEntry       
        ;    000040: 01 01 01 08 85 1F 00 00 00 04 00 00 00 00 00 00   ................
        ;             | |   \ /   \ /         |        |
        ;             | |    |     |          |________|
        ;             | |    |     |             |
        ;             | |    |     |             |
        ;             | |    |     |             | 
        ;             | |    |     |             Offset INTO the conatiner file (from
        ;             | |    |     |             the beginning) of where the C64 file
        ;             | |    |     |             starts (stored as low/high byte)
        ;             | |    |     |                                                       
        ;             | |    |     End address (actual end address in memory, if the file
        ;             | |    |     was loaded into a C64). If the file is a snapshot, then        
        ;             | |    |     the address will be a 0.        
        ;             | |    |        
        ;             | |    Start address (or Load address). This is the first two bytes
        ;             | |    of the C64 file which is usually the load  address (typically
        ;             | |    $01 $08). If the file is a snapshot, the address will be 0.
        ;             | |            
        ;             | |
        ;             | 1541 file type (0x82 for PRG, 0x81 for  SEQ,  etc).  You  will
        ;             | find it can vary  between  0x01,  0x44,  and  the  normal  D64
        ;             | values. In reality any value that is not a $00 is  seen  as  a
        ;             | PRG file. When this value is a $00 (and the previous  byte  at
        ;             | $40 is >1), then the file is a special T64 "FRZ" (frozen) C64s
        ;             | session snapshot.        
        ;             |
        ;             C64s filetype:
        ;              0     = free (usually)
        ;              1     = Normal tape file
        ;              3     = Memory Snapshot, v .9, uncompressed
        ;              2-255 = Reserved (for memory snapshots)
        ;
        ;    000050: 53 50 59 4A 4B 45 52 48 4F 45 4B 20 20 20 20 20   SPYJKERHOEK.....
        ;         	  < ------------------------------------------>
        ;              |
        ;              |
        ;              |C64 filename (in PETASCII, padded with $20, not $A0)
        ;
        ;    000060: 01 01 01 08 B0 CA 00 00 84 1B 00 00 00 00 00 00   ................
        ;    000070: 49 4D 50 4F 53 53 49 42 4C 45 20 4D 49 53 53 2E   IMPOSSIBLE MISS.        
        ; -------------------------------------------------------------------------------
        EntryUsed.b             ;$40 
        FileType.b              ;$41
        StartAddr.sAdress       ;$42 - $43
        EndAddr.eAdress         ;$44 - $45
        Reserved.reserved       ;$46 - $47 Not used
        Container.OffsetIn       ;$48 - $49 -$4A - $4B     
        Unused.Unused           ;$4C - $4F
        FileName.Rawname        ;$50 - 5F       
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
        type.b                      ;    02: File type.          
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
        *TapHeader.TapHeader        ;/*  $0000  -  $003F  */
        *TapDirentry.TapDirentry    ; /*  $0040  - ($03FF) */         
        mode.s
        position.i
        ts.TrackSector
        nextts.TrackSector         
        *buffer.offset
        bufptr.i
        buflen.i        
        List FileList.FileList()
    EndStructure 
    
    Structure Uint16
        c.a[2]
    EndStructure 
    
    Structure Uint32
        c.a[4]
    EndStructure 
    
    Structure SectorBlock
        c.a[254]
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
   
    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Read File   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Read Disk Image File  
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Macro LoadDiskImage(diFileName, diFileSize)
        
        *di\image = AllocateMemory(diFileSize)
        
        Define DiskImage = OpenFile( #PB_Any, diFileName,#PB_File_SharedRead|#PB_File_SharedWrite)
        If DiskImage
            While Not Eof( DiskImage )             
                ReadData(DiskImage, *di\image, diFileSize)
            Wend
            CloseFile(DiskImage)
        EndIf
    EndMacro
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Save Directory in List
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Macro LoadC64List(SourceList, DestList)                             
        ResetList ( SourceList )
        If ( ListSize (DestList) ! 0 )
            ClearList( DestList )
        EndIf
        
        While NextElement( SourceList )                    
            AddElement(DestList)
            DestList\C64File = SourceList\C64File
            DestList\C64Size = SourceList\C64Size
            DestList\C64Type = SourceList\C64Type
        Wend        
        ResetList ( DestList )
    EndMacro
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;   
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Macro SetError(sText)                        
        CBMDiskImage::*er\s = sText + #CRLF$ +
                              "Error: " + Str(#PB_Compiler_Line) + " in " +  #PB_Compiler_Module
        ProcedureReturn -1
    EndMacro   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;   
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Macro T64_AddFix_Element(Fix, FixesDescriptions )
        AddElement( FixesDescriptions )
        FixesDescriptions = Fix
    EndMacro    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Read unsigned 16-bit little endian value  
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i get_uint16(*p.Uint16)        
        ProcedureReturn *p\c[0] + (1<<8) * *p\c[1]
    EndProcedure    
    Procedure.i set_uint16(*p.Uint16, Unsigned.i)       
    *p\c[0] = Unsigned & $ff
    *p\c[1] = ( Unsigned >> 8) & $ff 
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;  Read unsigned 32-bit little endian value
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i get_uint32(*p.Uint32)  
        
        ProcedureReturn get_uint16(*p) + (1<<16) * *p\c[2] + (1<<24) * *p\c[3]
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    ; Do Listing
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure.i di_Get_List(*imgfile.ImageFile)            
        LoadC64List(*imgfile\FileList() ,CBMDiskImage::CBMDirectoryList() )       
    EndProcedure      
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type /Convert    
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i Filetype_Convert(FN$)
        Protected  Pattern$
        Pattern$ = UCase( GetExtensionPart( FN$ ) )
        Select Pattern$
            Case "TEXT", "TXT", "ASC", "NFO", "DOK", "DOC", "README","INI"       ; Convert this as SEQ
                ProcedureReturn 1
        EndSelect        
        ProcedureReturn 2
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type /Get Num   
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i Filetype_Set(Pattern$)
        Protected  a.i, c.c                  
        
        Pattern$ = Trim( Pattern$)
        Pattern$ = UCase(Pattern$)
        
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type / Explizit Convert
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    Procedure.s Filetype_Check(Type.b)
        Select Abs(Type.b)
            Case 122 : ProcedureReturn "DIR ($"+ Hex(Type,#PB_Byte) +")"
            Case 123 : ProcedureReturn "CBM ($"+ Hex(Type,#PB_Byte) +")"
            Case 124 : ProcedureReturn "REL ($"+ Hex(Type,#PB_Byte) +")"
            Case 125 : ProcedureReturn "USR ($"+ Hex(Type,#PB_Byte) +")"
            Case 126 : ProcedureReturn "PRG ($"+ Hex(Type,#PB_Byte) +")"
            Case 127 : ProcedureReturn "SEQ ($"+ Hex(Type,#PB_Byte) +")"
                
            Case 58 : ProcedureReturn "DIR< ($"+ Hex(Type,#PB_Byte) +")"
            Case 59 : ProcedureReturn "CBM< ($"+ Hex(Type,#PB_Byte) +")"
            Case 60 : ProcedureReturn "REL< ($"+ Hex(Type,#PB_Byte) +")"
            Case 61 : ProcedureReturn "USR< ($"+ Hex(Type,#PB_Byte) +")"
            Case 62 : ProcedureReturn "PRG< ($"+ Hex(Type,#PB_Byte) +")"
            Case 63 : ProcedureReturn "SEQ< ($"+ Hex(Type,#PB_Byte) +")"
                
            Case  6 : ProcedureReturn "*DIR ($"+ Hex(Type,#PB_Byte) +")"
            Case  5 : ProcedureReturn "*CBM ($"+ Hex(Type,#PB_Byte) +")"
            Case  4 : ProcedureReturn "*REL ($"+ Hex(Type,#PB_Byte) +")"
            Case  1 : ProcedureReturn "*USR ($"+ Hex(Type,#PB_Byte) +")"
            Case  2 : ProcedureReturn "*PRG ($"+ Hex(Type,#PB_Byte) +")"
            Case  3 : ProcedureReturn "*SEQ ($"+ Hex(Type,#PB_Byte) +")"   
                
            Case 70 : ProcedureReturn "*DIR< ($"+ Hex(Type,#PB_Byte) +")"
            Case 69 : ProcedureReturn "*CBM< ($"+ Hex(Type,#PB_Byte) +")"
            Case 68 : ProcedureReturn "*REL< ($"+ Hex(Type,#PB_Byte) +")"
            Case 67 : ProcedureReturn "*USR< ($"+ Hex(Type,#PB_Byte) +")"
            Case 66 : ProcedureReturn "*PRG< ($"+ Hex(Type,#PB_Byte) +")"
            Case 65 : ProcedureReturn "*SEQ< ($"+ Hex(Type,#PB_Byte) +")"  
        EndSelect       
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type /PC64      
    ; -----------------------------------------------------------------------------------------------------------------------------------------            
    Procedure.i Filetype_GetP00(Pattern$)                
        Protected FileTypeNum = -1, sFileType.s = "", CBMPattern
               
        If ( Filetype_Set(Pattern$) ! -1)
            ProcedureReturn Filetype_Set(Pattern$)
        EndIf    
        
        Pattern$ = UCase( Pattern$)
        Select LSet( Pattern$ ,1)
            Case "D", "S", "P", "U", "R"                                
            Default
                ProcedureReturn -1
        EndSelect        
        
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type /Get as String   
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s Filetype_Get(PatternNum.i)        
        Select PatternNum
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type /Get as String   
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s Filetype_Get_Tape(PatternNum.i)        
        Select PatternNum
            Case 0:ProcedureReturn "FRZ"
            Case 1:ProcedureReturn "SEQ"
            Case 2:ProcedureReturn "PRG"
            Case 3:ProcedureReturn "REL"                               
            Case 4:ProcedureReturn "USR"                                                              
            Default
                ProcedureReturn "???"
        EndSelect       
    EndProcedure        
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* File Type/ Add     
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i Filetype_ModfiyType(*di.Diskimage,*imgfile.ImageFile, PatternType.i)        
        
        
        Select *di\Type
                Case "D64", "D71", "D81"
                    *imgfile\rawdirentry\type  = PatternType | $80
                    
                    Select *di\ExtraType        
                        Case 1 ; Write As Locked File
                            *imgfile\rawdirentry\type = PatternType | $40
                            *imgfile\rawdirentry\type | $80                 
                        Case 2 ; Write As Splat File                 
                            *imgfile\rawdirentry\type & PatternType
                            
                        Case 3 ; Write Locked & Splat file                 
                            *imgfile\rawdirentry\type & PatternType            
                            *imgfile\rawdirentry\type | PatternType | $40                 
                    EndSelect
                    
                Case "T64"
                    *imgfile\TapDirentry\FileType = PatternType | $80
                    
                    Select *di\ExtraType        
                        Case 1 ; Write As Locked File
                            *imgfile\TapDirentry\FileType = PatternType | $40
                            *imgfile\TapDirentry\FileType | $80                 
                        Case 2 ; Write As Splat File                 
                            *imgfile\TapDirentry\FileType & PatternType
                            
                        Case 3 ; Write Locked & Splat file                 
                            *imgfile\TapDirentry\FileType & PatternType            
                            *imgfile\TapDirentry\FileType | PatternType | $40                 
                    EndSelect                     
         EndSelect           
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;  /* Remove Special Letters for Save File to HD
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s ptoa_CompatibilityMode(AFN$, sReplacer$ = "-")        
        
        Protected NFN$ = "", asci.a, i.i
        
        For i = 1 To Len(AFN$)            
            asci = Asc( Mid(AFN$,i,1) )           
            Select asci
                Case  34: NFN$ + sReplacer$     ; "    
                Case  42: NFN$ + "_(Asterisk)"  ; *                      
                Case  47: NFN$ + sReplacer$     ; /
                Case  58: NFN$ + sReplacer$     ; :
                Case  60: NFN$ + "_(Less-Than)" ; <
                Case  62: NFN$ + sReplacer$     ; >
                Case  63: NFN$ + sReplacer$     ; ?                       
                Case  92: NFN$ + sReplacer$     ; \  
                Case 127: NFN$ + sReplacer$     ; DEL  
                Default
                    NFN$ + Chr(asci)
            EndSelect     
        Next        
        ProcedureReturn NFN$
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;  /* Convert Ascii 0 to CBM Ascii 160
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s Ascii_2_Petscii_Convert_Zero(*name.Rawname, Tape = #False)       
        Protected  c.c, i.i
        
        For i = 0 To 15
            c = *name\c[i]
                        
            If      ( c = 0 And Tape  = #False )  Or ( c = 0 And Tape  = #True )
                
                     If ( Tape  = #False )
                         c = 160
                     EndIf
                     
                     If ( Tape  = #True )
                         c = 32
                     EndIf                     
                     
            Else
                
                Continue
            EndIf
            *name\c[i] = c
        Next
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;  /* Convert Petscii 160 to Ascii 0
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s Petscii_2_Ascii_Convert_Zero(*name.Rawname)       
        Protected  c.c, i.i
        
        For i = 0 To 15
            c = *name\c[i]
            
            If ( c = 160 )
                c = 0
            Else
                Continue
            EndIf
            *name\c[i] = c
        Next
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    ; --- FIXME: Convert CBM Ascii 128+ to Readable
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s ptou_back(FN$)
        
        Protected  *c.rawname, c.c
        
        *c = AllocateMemory(16)
        PokeS(*c, FN$, 16, #PB_Ascii)
                
        For i = 0 To 15
            c = *c\c[i]
            
            If c >= 'A' And c <= 'Z'
                c + 32
            ElseIf c >= 'a' And c <= 'z'
                c - 32            
            EndIf
            
            *c\c[i] = c
        Next    
        
        FN$ = PeekS(*c, 16, #PB_Ascii)
        ProcedureReturn  FN$
    EndProcedure      
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; --- FIXME: Convert CBM Ascii 128+ to Readable
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s ptou(FN$)
        
        Protected  *c.rawname,c.c
        
        *c = AllocateMemory(16)
        PokeS(*c, FN$, 16, #PB_Ascii)
        
        
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
        
        FN$ = PeekS(*c, 16, #PB_Ascii)
        ProcedureReturn  FN$
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; --- FIXME: convert Ascii to Pet
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure atop( *c.rawname)
        
        Protected c.a 
        
        For i = 0 To 15
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; --- FIXME: convert Pet to Ascii       
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure ptoa(*c.rawname)
        
        Protected c.a
        
        For i = 0 To 15
            c = *c\c[i]
            
            If c = 160
                Continue
            EndIf
            
            If c = 0
                Continue
            EndIf
            
            ;c & $7f
            
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;        
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.s di_Set_CharSet(AFN$, Shifting = 0)
        
        Protected NFN$ = "", asci.i, index.i, Char.a
        
        For index = 1 To Len(AFN$)
            
            Char  = Asc( Mid(AFN$,index,1) )
            Select Shifting
                Case 0
                    Select Char
                        Case 'A' To 'Z': Char -'A' + 'a'  
                        Case 'a' To 'z': Char -'a' + 'A' 
                    EndSelect        
                    
                Case 1
                    Select Char
                       ; Case 'a' To 'z':  Char -'a' + 'A'
                    EndSelect
                    
                Case 2
                    ; Save File To HD (Set Comp.)
                    Select Char
                        Case 'A' To 'Z': Char -'A' + 'a'                            
                        Case 193 To 255: Char - 128
                        Case  34: Char = '-' ; "    
                        Case  42: Char = '-' ; "_(Asterisk)"  ; *                      
                        Case  47: Char = '-' ; /
                        Case  58: Char = '-' ; :
                        Case  60: Char = '-' ;"_(Less-Than)" ; <
                        Case  62: Char = '-' ; >
                        Case  63: Char = '-' ; ?                       
                        Case  92: Char = '-' ; \  
                        Case 127: Char = '-' ; DEL  
                    EndSelect         
            EndSelect
            
            NFN$ + Chr(Char)
        Next
        
        ProcedureReturn NFN$
    EndProcedure        
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* convert to rawname */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i Base_Setup_RawName(*sRawName.Rawname, *dRawName.rawname, Fill.a, Lenght.i)
        
        Protected CharPos.i
        
        FillMemory( *dRawName, Lenght, Fill) 
        
        For CharPos = 0 To Lenght -1
            
            If ( *sRawName\c[CharPos] = 0 )
                 *dRawName\c[CharPos] = Fill
            Else
                *dRawName\c[CharPos] = *sRawName\c[CharPos]
            EndIf        
                
        Next CharPos
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Pointer to String */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.s Search_Result(*RawName.Rawname)
        ProcedureReturn Chr(34)+ PeekS(*RawName,16, #PB_Ascii) +Chr(34)  + #CRLF$
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* PB Rset with Int */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.s Base_RSet_Int(Value.i, Fill$ = "0", Lengt.i = 2)        
        ProcedureReturn  RSet( Str(Value),Lengt,Fill$)        
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* convert to rawname */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i di_rawname_from_name(*rawname.Rawname, *name.Rawname)               
        Protected i.i,x.i
        
        FillMemory( *rawname, 16, $a0)          
        x = 0
        For i = 0 To 15
            c.a = *name\c[i]
            If c ! 0
                x + 1
            EndIf
        Next i    
        CopyMemory( *name, *rawname, x)       
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* convert from rawname */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_name_from_rawname(*name.rawname, *rawname.Rawname)
        
        Protected TitleLenght.i, s.s
        
        For TitleLenght = 0 To 15
            If *rawname\c[TitleLenght] = $a0
                Break
            EndIf
            *name\c[TitleLenght] = *rawname\c[TitleLenght]               
            
        Next TitleLenght         
        ProcedureReturn TitleLenght       
        
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Return Free Blocks for Write */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_bytes_to_blocks(*di.DiskImage, FN$)
        
        ; 1 block = 256 bytes (ie. 4 blocks = 1k).
        ; First two bytes in each block = Pointer to the next block (track/sector) of the file.
        ; This leaves 254 bytes For file Data. 
        
        Protected Blocks.i
        Blocks.i = Round(FileSize(FN$) / 254,#PB_Round_Up)
        
        If *di\blocksfree >= Blocks
            ProcedureReturn 0
        EndIf
        
        If *di\blocksfree <= Blocks
            ProcedureReturn Blocks - *di\blocksfree
        EndIf
        
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i set_status(*di.DiskImage, status.i, track.i, sector.i)       
        *di\status          = status
        *di\statusts\track  = track     
        *di\statusts\sector = sector
        ProcedureReturn status       
    EndProcedure       
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return write interleave */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i interleave(ImageFormat.s)       
        Select ImageFormat
            Case "D64": ProcedureReturn 10
            Case "D71": ProcedureReturn 6
            Case "D81": ProcedureReturn 1     
        EndSelect       
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return number of tracks for image type *
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_tracks(*di.DiskImage)       
        Select *di\Type
                ;
                ; Various D64 Formats
            Case "D64":
                Select *di\size
                    Case 174848, 175531: ProcedureReturn 35                        
                    Case 196608, 197376: ProcedureReturn 40                        
                    Case 205312, 206114: ProcedureReturn 42 
                EndSelect  
                ;
                ;
            Case "D71":ProcedureReturn 70                
            Case "D81":ProcedureReturn 80
                ;
                ; T64 Has no Tracks
            Case "T64":ProcedureReturn 0
        EndSelect               
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return disk geometry for track */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_sectors_per_track(*di.DiskImage, Track.i)
        
        Select *di\Type              
            Case "D64"
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
                Select Track.i
                    Case  1 To 17: ProcedureReturn 21 
                    Case 18 To 24: ProcedureReturn 19    
                    Case 25 To 30: ProcedureReturn 18
                    Case 31 To 42: ProcedureReturn 17 ; 36 - 42: Extended Tracks                           
                EndSelect 
                
            Case "D71"   
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
                Select Track.i
                    Case  1 To 17, 36 To 52: ProcedureReturn 21 
                    Case 18 To 24, 53 To 59: ProcedureReturn 19    
                    Case 25 To 30, 60 To 65: ProcedureReturn 18
                    Case 31 To 35, 66 To 70: ProcedureReturn 17                
                EndSelect
                
                
            Case "D81"
                ;   Track #Sect #SectorsIn D81 Offset  |  Track #Sect #SectorsIn D81 Offset
                ;   ----- ----- ---------- ----------  |  ----- ----- ---------- ----------
                ;     1     40       0       $00000    |    41     40    1600       $64000
                ;     2     40      40       $02800    |    42     40    1640       $66800
                ;     3     40      80       $05000    |    43     40    1680       $69000
                ;     4     40     120       $07800    |    44     40    1720       $6B800
                ;     5     40     160       $0A000    |    45     40    1760       $6E000
                ;     6     40     200       $0C800    |    46     40    1800       $70800
                ;     7     40     240       $0F000    |    47     40    1840       $73000
                ;     8     40     280       $11800    |    48     40    1880       $75800
                ;     9     40     320       $14000    |    49     40    1920       $78000
                ;    10     40     360       $16800    |    50     40    1960       $7A800
                ;    11     40     400       $19000    |    51     40    2000       $7D000
                ;    12     40     440       $1B800    |    52     40    2040       $7F800
                ;    13     40     480       $1E000    |    53     40    2080       $82000
                ;    14     40     520       $20800    |    54     40    2120       $84800
                ;    15     40     560       $23000    |    55     40    2160       $87000
                ;    16     40     600       $25800    |    56     40    2200       $89800
                ;    17     40     640       $28000    |    57     40    2240       $8C000
                ;    18     40     680       $2A800    |    58     40    2280       $8E800
                ;    19     40     720       $2D000    |    59     40    2320       $91000
                ;    20     40     760       $2F800    |    60     40    2360       $93800
                ;    21     40     800       $32000    |    61     40    2400       $96000
                ;    22     40     840       $34800    |    62     40    2440       $98800
                ;    23     40     880       $37000    |    63     40    2480       $9B000
                ;    24     40     920       $39800    |    64     40    2520       $9D800
                ;    25     40     960       $3C000    |    65     40    2560       $A0000
                ;    26     40    1000       $3E800    |    66     40    2600       $A2B00
                ;    27     40    1040       $41000    |    67     40    2640       $A5000
                ;    28     40    1080       $43800    |    68     40    2680       $A7800
                ;    29     40    1120       $46000    |    69     40    2720       $AA000
                ;    30     40    1160       $48800    |    70     40    2760       $AC800
                ;    31     40    1200       $4B000    |    71     40    2800       $AF000
                ;    32     40    1240       $4D800    |    72     40    2840       $B1800
                ;    33     40    1280       $50000    |    73     40    2880       $B4000
                ;    34     40    1320       $52800    |    74     40    2920       $B6800
                ;    35     40    1360       $55000    |    75     40    2960       $B9000
                ;    36     40    1400       $57800    |    76     40    3000       $BB800
                ;    37     40    1440       $5A000    |    77     40    3040       $BE000
                ;    38     40    1480       $5C800    |    78     40    3080       $C0800
                ;    39     40    1520       $5F000    |    79     40    3120       $C3000
                ;    40     40    1560       $61800    |    80     40    3160       $C5800                
                ProcedureReturn 40                                
        EndSelect        
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* convert track, sector to blocknum */ 
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_get_block_num(*di.DiskImage, *ts.TrackSector, ResultBlocksOnly = #False)
        
        Protected Blocks.i = 0, HighTrack.i
        
        Select *di\Type
            Case "D64", "D71"
                
                If (*ts\track > 35) And ( *di\Type = "D64" )
                    Blocks       = 17
                    HighTrack    = *ts\track
                    *ts\track   - 1                   
                EndIf
                
                If (*ts\track > 35) And ( *di\Type = "D71" )
                    Blocks       = 683
                    HighTrack  = *ts\track
                    *ts\track   - 35                
                EndIf                
                
                
                If (*ts\track < 18)
                    Blocks + (*ts\track - 1) * 21
                ElseIf (*ts\track < 25)
                    Blocks + (*ts\track - 18) * 19 + 17 * 21
                ElseIf (*ts\track < 31)
                    Blocks + (*ts\track - 25) * 18 + 17 * 21 + 7 * 19
                Else
                    Blocks + (*ts\track - 31) * 17 + 17 * 21 + 7 * 19 + 6 * 18
                EndIf 
                
                If (HighTrack > 35)
                    *ts\track = HighTrack
                EndIf      
                
                
                Select ResultBlocksOnly
                    Case #False
                        ProcedureReturn (Blocks + *ts\sector) 
                    Case #True
                        ProcedureReturn (Blocks)
                EndSelect            
                
            Case "D81":
                Select ResultBlocksOnly
                    Case #False                
                        ProcedureReturn (*ts\track - 1) * 40 + *ts\sector
                    Case #True 
                        ProcedureReturn (*ts\track - 1) * 40 
                EndSelect
                
                ;
                ; T64: Return the Offset after Header Description
            Case "T64": ProcedureReturn $40 + *di\Tape\RecCurrrent 
        EndSelect   
        
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* get a pointer to block data */ 
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i get_ts_addr(*di.DiskImage,  *ts.TrackSector)   
        
        Select *di\Type
            Case "D64", "D71", "D81" 
                ProcedureReturn ( *di\Image + di_get_block_num(*di, *ts) * 256 )
            Case "T64"    
                ProcedureReturn ( *di\Image + di_get_block_num(*di, *ts) * $20 )
        EndSelect        
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return a pointer to the next block in the chain */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i next_ts_in_chain(*di.DiskImage,  *ts.TrackSector)
        
        Define *p.ByteArrayStructure
        
        Static newts.TrackSector
        
        *p = get_ts_addr(*di, *ts)
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return a pointer to the disk title */  
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure di_title(*di.DiskImage)
        Select (*di\Type)
            Case "D64": ProcedureReturn (get_ts_addr( *di, *di\dir ) + 144)
            Case "D71": ProcedureReturn (get_ts_addr( *di, *di\dir ) + 144)
            Case "D81": ProcedureReturn (get_ts_addr( *di, *di\dir ) + 4)
            Case "T64": ProcedureReturn (get_ts_addr( *di, *di\dir ) + $28)                 
        EndSelect
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return a description to the disk error info */   
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s di_error_codes_desc(ErrorNum.i)        
        Select ErrorNum
            Case 20: ProcedureReturn "Header Block Not Found"
            Case 21: ProcedureReturn "No Sync Character "                
            Case 22: ProcedureReturn "Data Block Not Present"
            Case 23: ProcedureReturn "Checksum Error In Data Block" 
            Case 24: ProcedureReturn "Byte Decoding Error"     
            Case 25: ProcedureReturn "Write Verify Error"
            Case 26: ProcedureReturn "Write Protect On"
            Case 27: ProcedureReturn "Checksum Error IN Header Block"
            Case 29: ProcedureReturn "Disk sector ID mismatch"
        EndSelect
        ProcedureReturn ""
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return a pointer to the disk error info */ 
    ; --- TODO: D81, Error Sector Info
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_error_codes(*di.DiskImage, *ts.TrackSector)
        
        Protected  *p.UnsignedCharFormat, Result.i
        
        If *di\error\track = 0
            ProcedureReturn 0
        EndIf
        
        Select (*di\Type)
            Case "D64":
                
                Select *di\size
                    Case 175531: *p= (get_ts_addr( *di, *di\error ) )
                    Case 197376: *p= (get_ts_addr( *di, *di\error ) ) +256 +4096  
                    Case 206114: *p= (get_ts_addr( *di, *di\error ) ) +256 +4096
                EndSelect
                
            Case "D71":  *p= (get_ts_addr( *di, *di\error ) ) + 4352
            Case "D81":  *p= (get_ts_addr( *di, *di\error ) ) 
        EndSelect
        
        Result = *p\b[di_get_block_num(*di, *ts)]
        Select  Result
            Case 0,1  : ProcedureReturn 0   ;OK
            Case 2,$14: ProcedureReturn 20  ;Header Block Not Found
            Case 3,$15: ProcedureReturn 21  ;No Sync Character 
            Case 4,$16: ProcedureReturn 22  ;Data Block Not Present 
            Case 5,$17: ProcedureReturn 23  ;Checksum Error In Data Block
            Case 6    : ProcedureReturn 24  ;Byte Decoding Error
            Case 7    : ProcedureReturn 25  ;Write Verify Error
            Case 8    : ProcedureReturn 26  ;Write Protect On 
            Case 9    : ProcedureReturn 27  ;Checksum Error in Header Block  
                                            ;Case $0A  : ProcedureReturn 28  ; Write error  (In actual fact, this error never occurs)              
            Case $0B: ProcedureReturn 29    ; Disk sector ID mismatch
        EndSelect          
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* return number of free blocks in track */
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.l di_track_blocks_free(*di.DiskImage, track.i)
        
        Define *bam.ByteArrayStructure
        
        Select *di\Type
            Case "D64":
                ;
                ; Marty2PB: Added Extended Tracks Support 36 to 40
                *bam = get_ts_addr(*di, *di\bam)                
                If (track > 35)                                   
                    ProcedureReturn ( *bam\c[ (16 + track)  *3 +  track] )                                                     
                EndIf                 
                
            Case "D71":
                *bam = get_ts_addr(*di, *di\bam)
                If (track > 35)
                    ProcedureReturn ( *bam\c[track + 185] )
                EndIf 
                
            Case "D81":
                If (track <=40)
                    *bam = get_ts_addr(*di, *di\bam);
                Else
                    *bam = get_ts_addr(*di, *di\bam2);
                    track - 40                       ;
                EndIf
                ProcedureReturn ( *bam\c[track * 6 + 10]);  
        EndSelect       
        
        ProcedureReturn ( *bam\c[track * 4]  )       
    EndProcedure       
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; count number of free blocks
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i blocks_free(*di.DiskImage)       
        Protected Track.i, Blocks.i = 0        
        For Track = 1 To di_tracks(*di.DiskImage)           
            If ( Track <> *di\dir\track )
                Blocks + di_track_blocks_free(*di, Track)
            EndIf
        Next
        ProcedureReturn Blocks
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* check If track, sector is free IN BAM */
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i di_is_ts_free( *di.DiskImage, *ts.TrackSector)
        
        Protected mask.l
        Define *bam.offset
        
        Select *di\Type
            Case "D64"  
                ;
                ; Marty2PB: Added Extended Tracks Support 36 to 40  
                mask = 1 << ( *ts\sector & 7)
                *bam = get_ts_addr(*di, *di\bam)                 
                If (*ts\track < 36)                                             
                    ProcedureReturn (*bam\c[*ts\track * 4 + *ts\sector / 8 + 1] & mask)  
                Else                 

                    Select *di\DiskDOS\Type
                        Case "2P"
                            ProcedureReturn ( *bam\c[ *ts\track *4 + *ts\sector / 8 + 1] & mask )                                                    
                        Default
                            ProcedureReturn ( *bam\c[ (16 + *ts\track)  *3 +  *ts\track + *ts\sector / 8 + 1] & mask )                            
                    EndSelect        
                EndIf
                
            Case "D71"                 
                mask = 1 << (*ts\sector & 7) 
                If (*ts\track < 36)
                    *bam = get_ts_addr(*di, *di\bam)                   
                    ProcedureReturn (*bam\c[*ts\track * 4 + *ts\sector / 8 + 1] & mask)
                Else                  
                    *bam = get_ts_addr(*di, *di\bam2)                  
                    ProcedureReturn ( *bam\c[ (*ts\track - 35) * 3 + *ts\sector / 8 - 3 ] & mask )
                EndIf   
                
                
            Case "D81"                  
                mask = 1 << (*ts\sector & 7)
                If (*ts\track < 41)
                    *bam = get_ts_addr(*di, *di\bam) 
                    ProcedureReturn (*bam\c[*ts\track * 6 + *ts\sector / 8 + 11] & mask )   
                Else
                    *bam = get_ts_addr(*di, *di\bam2)                 
                    ProcedureReturn (*bam\c[(*ts\track -40) * 6 + *ts\sector / 8 + 11] & mask )   
                EndIf                                   
        EndSelect       
        
    EndProcedure       
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Add BAM to the List
    ; --- TODO: BAM List Structure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i di_do_bam(*di.DiskImage)
        
        ClearList( BAM() )
        Static ts.TrackSector
        
        For Track = 1 To di_tracks( *di )  
            ts\track = Track
            
            AddElement( BAM() )
            AddElement( BAM()\Track() )
            
            BAM()\Track()\Number     = ts\track
            BAM()\Track()\IsFree     = di_track_blocks_free(*di, BAM()\Track()\Number )
            BAM()\Track()\BlockStart = di_get_block_num(*di, @ts, #True )
            BAM()\Track()\MaxSector  = di_sectors_per_track(*di, BAM()\Track()\Number)
            
            For Sector = 0 To BAM()\Track()\MaxSector-1
                ts\sector = Sector
                
                AddElement( BAM()\Track()\Sector() )
                
                BAM()\Track()\Sector()\Sector   = Sector
                BAM()\Track()\Sector()\Used     = di_is_ts_free(*di, @ts)
                BAM()\Track()\Sector()\ErrorCode= di_error_codes(*di, @ts)  
                BAM()\Track()\Sector()\ErrorDesc= di_error_codes_desc( BAM()\Track()\Sector()\ErrorCode )                          
            Next        
            
        Next    
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Get DISK, TAPE Dos ID Type
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_dos_vs_type(*di.DiskImage)        
        Protected *id.offset
        
        *id = AllocateMemory(6)
        
        Select *di\Type
            Case "D64","D71", "D81"
                
                CopyMemory(di_title(*di) +38 , *id, 6)            
                *id\c[5] = 0
                
                If ( *id\c[3] = '2') And ( *id\c[4] = $50 )
                    ;
                    ; PrologicDOS 1541  |  40  | $0f  $0f |  "2P'  |$50/'P', it's not really testet. it uses the Documentary from D64 Format   
                    ; ProSpeed 1571 2.0 |  40  | $0f  $0f |  "2P'  |$50/'P', it's not really testet. it uses the Documentary from D64 Format   
                    *di\DiskDOS\ Type = Chr( *id\c[3] ) + Chr( *id\c[4] ) 
                    *di\DiskDOS\Ident = Chr( *id\c[0] ) + Chr( *id\c[1] )             
                Else
                    CopyMemory(di_title(*di) +18 , *id, 6)
                    *di\DiskDOS\ Type = Chr( *id\c[3] ) + Chr( *id\c[4] ) 
                    *di\DiskDOS\Ident = Chr( *id\c[0] ) + Chr( *id\c[1] ) 
                EndIf 
                
            Case "T64"     
                CopyMemory( *di\image + $20, *id, 2) 
                ;Chr('V') + Chr('E')+ Chr('R') + Chr('S') + Chr('I') + Chr('O') + Chr('N') + Chr(' ') + Str( *id\b[0] ) + Str(*id\b[1]) 
                *di\DiskDOS\ Type = Chr('V') + Str( *id\c[0] ) + Str(*id\c[1])   
                *di\DiskDOS\Ident = Chr('T') + Chr('A')+ Chr('P') + Chr('E')                                    
        EndSelect           
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* List of 'magic bytes' found in different t64 files*/
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i T64_Check_Header(Kassette$, GetName.i = #False)
        
        Protected T64.a
        
        NewList  T64_Header.s()              
        
        AddElement( T64_Header() ): T64_Header() = "C64S tape image file"                 ;/* the correct one */
        AddElement( T64_Header() ): T64_Header() = "C64S tape file"
        AddElement( T64_Header() ): T64_Header() = "C64 tape image file"
        
        ResetList( T64_Header() )
        
        T64 = OpenFile( 0, Kassette$, #PB_File_SharedRead | #PB_File_SharedWrite)
        If ( T64 )
            If ReadFile(T64, Kassette$, #PB_File_SharedRead| #PB_File_SharedWrite) 
                
                While NextElement( T64_Header() )
                    *T64 = ReAllocateMemory( *T64, Len(T64_Header()) )
                    
                    FileSeek( T64, 0)
                    
                    ReadData(T64, *T64, Len(T64_Header()))
                    
                    If ( PeekS(*T64, Len(T64_Header()), #PB_Ascii) = T64_Header()) 
                        Select GetName
                            Case #False
                                CloseFile( T64 )
                                 ProcedureReturn ListIndex( T64_Header() )
                             Case #True 
                                 CloseFile( T64 )
                                 ProcedureReturn *T64    
                        EndSelect         
                    EndIf
                Wend
            EndIf        
        EndIf
        CloseFile( T64 )
        ProcedureReturn -1
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Load image into ram */
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.l di_load_image(DiskImageFile$)
        Protected  *di.DiskImage
        
        *di.DiskImage = AllocateMemory(SizeOf(DiskImage))
        InitializeStructure(*di, DiskImage)
        
        InitializeStructure(*er, LastError)
        
        Protected ImageFileSize.i, Warning$
        
        If ( FileSize(DiskImageFile$) = -1 )
            SetError("File "+Chr(34)+DiskImageFile$+Chr(34)+" Not Found")
        EndIf
        
        ImageFileSize = FileSize( DiskImageFile$ )
        Select ImageFileSize
                ;
                ; ........................................................................................ D64 image, 35 - 42 tracks
            Case 174848, 175531, 196608, 197376, 205312, 206114               
                *di\Type       = "D64"                
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\dir        = *di\bam 
                
                ; Error Track Info
                Select ImageFileSize
                    Case 175531   
                        *di\error\track = 36
                        *di\error\sector= 0 
                    Case 197376  
                        *di\error\track = 40
                        *di\error\sector= 0  
                    Case 206114                          
                        *di\error\track = 42    ; Not Finished
                        *di\error\sector= 0 
                EndSelect                               
                
                ;
                ; ........................................................................................ D71 image, 70 tracks
            Case 349696, 351062
                *di\Type       = "D71" 
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\bam2\track = 53
                *di\bam2\sector= 0
                *di\dir        = *di\bam
                
                ; Error Track Info
                Select ImageFileSize
                    Case 351062 
                        *di\error\track = 70
                        *di\error\sector= 0 
                EndSelect
                
                ; 
                ; ........................................................................................ D81 image, 80 tracks                 
            Case 819200, 822400                       
                *di\Type       = "D81"
                *di\bam\track  = 40
                *di\bam\sector = 1
                *di\bam2\track = 40
                *di\bam2\sector= 2
                *di\bam3\track = 40
                *di\bam3\sector= 3                   
                *di\dir\track  = 40
                *di\dir\sector = 0
                
                ; Error Track Info
                Select ImageFileSize
                    Case 822400 
                        *di\error\track = 80    ; Not Finished
                        *di\error\sector= 0 
                EndSelect
                
                ;
                ; ........................................................................................ Not Supportet                 
            Case  176640: CBMDiskImage::*er\s  = "D67: Not Supportet, 35 tracks DOS1"            :ProcedureReturn -1                  
            Case  533248: CBMDiskImage::*er\s  = "D80: Not Supportet, 77 tracks"                 :ProcedureReturn -1                   
            Case  832680: CBMDiskImage::*er\s  = "D81: Not Supportet, 81 tracks"                 :ProcedureReturn -1                    
            Case  829440: CBMDiskImage::*er\s  = "D81: Not Supportet, 81 tracks with errors info":ProcedureReturn -1            
            Case  839680: CBMDiskImage::*er\s  = "D81: Not Supportet, 82 tracks"                 :ProcedureReturn -1    
            Case  842960: CBMDiskImage::*er\s  = "D81: Not Supportet, 82 tracks with errors info":ProcedureReturn -1 
            Case  849920: CBMDiskImage::*er\s  = "D81: Not Supportet, 83 tracks"                 :ProcedureReturn -1                
            Case  853240: CBMDiskImage::*er\s  = "D81: Not Supportet, 83 tracks with errors info":ProcedureReturn -1  
            Case 1066496: CBMDiskImage::*er\s  = "D82: Not Supportet, 77 tracks"                 :ProcedureReturn -1                   
            Case  829440: CBMDiskImage::*er\s  = "D1M: Not Supportet, 81 tracks"                 :ProcedureReturn -1 
            Case  832680: CBMDiskImage::*er\s  = "D1M: Not Supportet, 81 tracks with errors info":ProcedureReturn -1  
            Case 1658880: CBMDiskImage::*er\s  = "D2M: Not Supportet, 81 tracks"                 :ProcedureReturn -1             
            Case 1665360: CBMDiskImage::*er\s  = "D2M: Not Supportet, 81 tracks with errors info":ProcedureReturn -1 
            Case 3317760: CBMDiskImage::*er\s  = "D4M: Not Supportet, 81 tracks"                 :ProcedureReturn -1
            Case 3330720: CBMDiskImage::*er\s  = "D4M: Not Supportet, 81 tracks with errors info":ProcedureReturn -1          
            Case       0: CBMDiskImage::*er\s  = "Images has 0 Bytes"                            :ProcedureReturn -1
            Case      -1: CBMDiskImage::*er\s  = "Image " + DiskImageFile$ + "Not Found"         :ProcedureReturn -1
            Case      -2: CBMDiskImage::*er\s  = "Mismatch Error (Directory???)"                 :ProcedureReturn -1               
            Default
                Select UCase( GetExtensionPart(DiskImageFile$) )
                        ;
                        ; .............................................................................. C64 Tape Image T64
                    Case "T64"
                        Protected  *T64.offset                        
        
                        ImageFileSize = FileSize(DiskImageFile$) 
                        Result.i      = T64_Check_Header(DiskImageFile$)
                        
                        If ( Result = -1 )                         
                            *di\Tape\Fixes + 1
                            Result         = 1
                            Warning$ = "Fatal! Couldn't find Header for Tape T64. Please Fix it"                               
                            T64_AddFix_Element(Warning$, *di\Tape\FixesDescriptions())  
                            
                        ElseIf  ( Result > 0 )
                            *T64 = T64_Check_Header(DiskImageFile$, #True)
                            
                            Warning$ = "Header Corrupt. Correct is: "+Chr(34)+"C64S tape image file"+Chr(34)+". Found: " +Chr(34)+ PeekS(*T64, MemorySize(*t64), #PB_Ascii) +Chr(34)+ "."
                            *di\Tape\Fixes + 1
                            T64_AddFix_Element(Warning$, *di\Tape\FixesDescriptions())                            
                        EndIf                      
                                              
                        *di\Type             = "T64"
                        *di\Tape\HeaderResult= Result
                        *di\bam\track        = 1
                        *di\bam\sector       = 0
                        *di\dir              = *di\bam 
                        ;
                        ; .............................................................................. Not Supportet  
                    Case "G64" :CBMDiskImage::*er\s          = "G64: Not Supportet"              :ProcedureReturn -1
                    Case "P64" :CBMDiskImage::*er\s          = "P64: Not Supportet"              :ProcedureReturn -1
                    Case "X64" :CBMDiskImage::*er\s          = "X64: Not Supportet"              :ProcedureReturn -1
                    Case "TAP" :CBMDiskImage::*er\s          = "TAP: Not Supportet"              :ProcedureReturn -1                        
                    Case "G71" :CBMDiskImage::*er\s          = "G71: Not Supportet"              :ProcedureReturn -1
                    Case "NIB" :CBMDiskImage::*er\s          = "NIB: Not Supportet"              :ProcedureReturn -1                    
                    Default    :CBMDiskImage::*er\s          = DiskImageFile$ + ": Not Supportet":ProcedureReturn -1
                EndSelect          
        EndSelect
        LoadDiskImage(DiskImageFile$, ImageFileSize)
                    
        *di\size        = ImageFileSize 
        *di\dateiname   = GetFilePart(DiskImageFile$)
        *di\dateipath   = GetPathPart(DiskImageFile$)
        *di\openfiles   = 0
        *di\blocksfree  = blocks_free(*di)
        *di\modified    = 0               
        *di\DebugInfo\write_info            = #False
        *di\DebugInfo\alloc_file_entry_info = #False
        
        ; Get DosType Version
        di_dos_vs_type(*di) 
        
        ; Create Bam View on the Fly
        di_do_bam(*di)
        
        set_status(*di, 254, 0, 0)        
        
        ProcedureReturn *di.DiskImage
        
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Format Image Infos */
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure di_create_image(DiskImageFile$, ImageFileSize)
        
        *di.DiskImage = AllocateMemory(SizeOf(DiskImage))
        InitializeStructure(*di, DiskImage)    
        InitializeStructure(*er, LastError)
        
        Select ImageFileSize
            Case 174848                       ; /* D64 image, 35 tracks */
                *di\Type       = "D64"
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\dir        = *di\bam 
            Case 175531                       ; /* D64 image, 35 tracks with errors */ (which we just ignore)   
                *di\Type       = "D64"
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\dir        = *di\bam                   
            Case 196608                       ; /* D64 image, 40 tracks   
                *di\Type       = "D64"
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\dir        = *di\bam   
            Case 197376                       ; /* D64 image, 40 tracks with errors 
                *di\Type       = "D64"
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\dir        = *di\bam    
            Case 349696                       ;  /* 1366 Blocks    /* 1328 free */
                *di\Type       = "D71" 
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\bam2\track = 53
                *di\bam2\sector= 0
                *di\dir        = *di\bam 
            Case 351062                       ; /* D71 image, 70 tracks With errors */
                *di\Type       = "D71" 
                *di\bam\track  = 18
                *di\bam\sector = 0
                *di\bam2\track = 53
                *di\bam2\sector= 0
                *di\dir        = *di\bam                  
            Case 819200                       ; /* D81 image, 80 tracks */
                *di\Type       = "D81"
                *di\bam\track  = 40
                *di\bam\sector = 1
                *di\bam2\track = 40
                *di\bam2\sector= 2
                *di\dir\track  = 40
                *di\dir\sector = 0 
            Default  
                Select GetExtensionPart( UCase( DiskImageFile$ ) )
                    Case "T64" 
                        ImageFileSize = 256 
                        *di\Type      = "T64"
                        *di\Tape\HeaderResult= 0                       
                        *di\bam\track        = 1
                        *di\bam\sector       = 0
                        *di\dir              = *di\bam                         
                    Default    
                        SetError("Can't Create Image")
                EndSelect
        EndSelect
        
        
        *di\size        = ImageFileSize
        *di\image       = AllocateMemory(ImageFileSize)
        *di\dateiname   = GetFilePart(DiskImageFile$)
        *di\dateipath   = GetPathPart(DiskImageFile$)
        *di\openfiles   = 0
        *di\blocksfree  = blocks_free(*di)
        *di\modified    = 1
        
        set_status(*di, 254, 0, 0)        
        
        ProcedureReturn *di.DiskImage    
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Get Error
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.s di_get_error_OpenDiskImage(*er.LastError)        
        ProcedureReturn *er\s
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* allocate track, sector in BAM */
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    Procedure di_alloc_ts(*di.DiskImage, *ts.TrackSector)                  
        Define *bam.offset
        Protected mask.i
        
        *di\modified = 1      
        
        Select *di\Type
            Case "D64"
                mask = 1 << ( *ts\sector & 7)
                *bam = get_ts_addr(*di, *di\bam)
                
                If (*ts\track < 36)                   
                    *bam\c[ *ts\track * 4  ] - 1
                    *bam\c[ *ts\track * 4 + *ts\sector / 8 + 1] & ~mask
                Else       
                    ;
                    ; Marty2PB: Added Extended Tracks Support 36 to 40 
                    Select *di\DiskDOS\Type
                            ;
                            ; BAM Sectors
                        Case "2P"
                            *bam\c[ *ts\track * 4  ] - 1
                            *bam\c[ *ts\track * 4 + *ts\sector / 8 + 1] & ~mask                            
                        Default                    
                            *bam\c[ (16 + *ts\track)  *3 +  *ts\track ] - 1
                            *bam\c[ (16 + *ts\track)  *3 +  *ts\track + *ts\sector / 8 + 1] & ~mask    
                    EndSelect        
                EndIf 
                
            Case "D71"                
                mask = 1 << ( *ts\sector & 7)
                If (*ts\track < 36)
                    *bam = get_ts_addr(*di, *di\bam)
                    *bam\c[ *ts\track * 4  ] - 1
                    *bam\c[ *ts\track * 4 + *ts\sector / 8 + 1] & ~mask
                Else
                    *bam = get_ts_addr(*di, *di\bam)
                    *bam\c[ *ts\track + 185] - 1
                    
                    *bam = get_ts_addr(*di, *di\bam2)
                    *bam\c[ (*ts\track - 35) * 3 + *ts\sector / 8 - 3] & ~mask
                EndIf 
                
            Case "D81"
                mask = 1 << (*ts\sector & 7)
                If (*ts\track < 41)    
                    *bam = get_ts_addr(*di, *di\bam)
                    *bam\c[ *ts\track * 6 + 10] - 1
                    *bam\c[ *ts\track * 6 + *ts\sector / 8 + 11] & ~mask  
                    
                Else    
                    *bam = get_ts_addr(*di, *di\bam2)
                    *bam\c[ (*ts\track -40) * 6 + 10 ] - 1
                    *bam\c[ (*ts\track -40) * 6  + *ts\sector / 8 + 11] & ~mask                    
                EndIf                      
        EndSelect
        
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; 
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.i alloc_next_ts_spt_ts(*di.DiskImage, *ts.TrackSector, *prevts.TrackSector)  
        ProcedureReturn (*prevts\sector + interleave(*di\type) ) % di_sectors_per_track(*di, *ts\track)        
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.s debug_alloc_File_Entry( *di.DiskImage, *ts.TrackSector, *rde.Rawdirentry)
        
        If ( *di\DebugInfo\alloc_file_entry_info = #True)        
            offset =  *di\Image + di_get_block_num(*di, *ts) * 256
            FreeBlocks.i = di_is_ts_free(*di, *ts)
            DebugText$          =   "Allocate File Entry ................................"
            DebugText$ +#CRLF$+     ""
            DebugText$ +#CRLF$+     "Track      :  "+ Str(*ts\track)+ "/ Sector:  " +RSet(Str(*ts\sector),2,"0") 
            DebugText$ +#CRLF$+     "Track      : $"+ Hex(*ts\track)+ "/ Sector: $" +RSet(Hex(*ts\sector),2,"0")                     
            DebugText$ +#CRLF$+     "Offset     : " + Str(di_get_block_num(*di, *ts) * 256)
            DebugText$ +#CRLF$+     "Offset     : $"+ Hex(di_get_block_num(*di, *ts) * 256) + " #Sectors In: "+Str( di_get_block_num(*di, *ts) )
            DebugText$ +#CRLF$+     "Blocks Free: " + Str(FreeBlocks)
            DebugText$ +#CRLF$+     "File Found : " + PeekS(*rde\rawname,16, #PB_Ascii)
            DebugText$ +#CRLF$+     "-------------------------------------------------"
            Debug DebugText$    
            ProcedureReturn DebugText$
        EndIf
        ProcedureReturn ""
    EndProcedure           
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; 
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
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
            Debug DebugText$       
            ProcedureReturn DebugText$
        EndIf
        ProcedureReturn ""
    EndProcedure      
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i alloc_next_ts_GetSectors(*di.DiskImage, Track.i, *disk.WriteProfil)        
        Define *bam.offset, SectorPoint.i
        
        If *di\Type = "D64"
            *bam = get_ts_addr(*di, *di\bam)
            Select Track
                Case 1 To 17, 19 To 35                         
                    SectorPoint = *bam\c[ Track * *disk\bpt1 + *disk\Boff ]  
                Case 18
                    ProcedureReturn  -1
                Case 36 To 40
                    Select *di\DiskDOS\Type
                        Case "2P"
                            SectorPoint = *bam\c[ Track * *disk\bpt1 + *disk\Boff ]  
                        Default    
                            SectorPoint = *bam\c[ (16 + Track)  * *disk\bpt2 +  Track + *disk\Boff ]                  
                    EndSelect       
            EndSelect 
        EndIf                                    
        ProcedureReturn SectorPoint
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Write D64
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    Procedure.i alloc_next_ts_D64(*di.DiskImage, *ts.TrackSector, *prevts.TrackSector,  *disk.WriteProfil, CurrentTrack)
        
        *disk\s1    = 17    ; Start Track
        *disk\t1    = 35    ; End Track  , Default D64 with Size 174848
        *disk\res1  = 18    ; Direcory Track
        *disk\bpt1  = 4
        *disk\bpt2  = 3
        *disk\Boff  = 0
        
        Select  *di\size
            Case 174848, 175531: *disk\t1  = 35    ; End track
            Case 196608, 197376: *disk\t1  = 40    ; End track
        EndSelect 
        
        For CurrentTrack = CurrentTrack To 0  Step -1
            
            *ts\track = CurrentTrack
            
            If (*ts\track = 0) Or (*ts\track >= 19)
                CurrentTrack = *ts\track
                Break
            EndIf
            
            If (*ts\track = 18)
                Continue
            EndIf
            
            SectorCount.i = alloc_next_ts_GetSectors(*di, *ts\track, *disk) 
            If ( SectorCount = 0)
                Continue
            EndIf
            SectorMaxNr.i = di_sectors_per_track(*di, *ts\track)                         
            ;
            ; --- TODO: Interleave Write
            ;SectorInter.i = alloc_next_ts_spt_ts(*di, *ts, *prevts)
            
            SectorMaxNr - SectorCount 
            
            For x = *ts\sector  To  SectorMaxNr            
                *ts\sector = x
                
                FreeBlocks.i = di_is_ts_free(*di, *ts)
                If FreeBlocks
                    debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                EndIf
            Next x      
            
        Next CurrentTrack
        
        If (CurrentTrack = 0) Or (CurrentTrack >= 19)
            For CurrentTrack = CurrentTrack To *disk\t1
                
                *ts\track = CurrentTrack
                
                If (*ts\track = 18)
                    Continue
                EndIf
                
                SectorCount.i = alloc_next_ts_GetSectors(*di, *ts\track, *disk) 
                If ( SectorCount = 0)
                    Continue
                EndIf
                SectorMaxNr.i = di_sectors_per_track(*di, *ts\track) 
                ;
                ; --- TODO: Interleave Write                
                ;SectorInter.i = alloc_next_ts_spt_ts(*di, *ts, *prevts)
                
                SectorMaxNr - SectorCount 
                
                For x = *ts\sector To  SectorMaxNr            
                    *ts\sector = x
                    
                    FreeBlocks.i = di_is_ts_free(*di, *ts)
                    If FreeBlocks
                        debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                    EndIf
                Next x      
                
            Next CurrentTrack
        EndIf
        
        *ts\track  = 0
        *ts\sector = 0
        FreeMemory(*disk)
        ProcedureReturn *ts  
        
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Write D71
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i alloc_next_ts_D71(*di.DiskImage, *ts.TrackSector, *prevts.TrackSector,  *disk.WriteProfil, CurrentTrack)
        
        Define *bam.offset 
        
        *disk\s1    = 17 ; chain from 17 to 1
        *disk\s2    = 36 ; chain from 52 to 36               
        *disk\t1    = 35 ; chain from 35 to 19
        *disk\t2    = 70 ; chain from 70 to 54 
        *disk\res1  = 18
        *disk\res2  = 53
        *disk\bpt1  = 4
        *disk\bpt2  = 0
        *disk\Boff  = 0                  
        If ( CurrentTrack <= *disk\s1 )
            
            *bam = get_ts_addr(*di, *di\bam)
            
            For CurrentTrack = *disk\s1 To 1 Step -1
                
                *ts\track = CurrentTrack                    
                
                If  (*bam\c[*ts\track * *disk\bpt1 + boff])
                    
                    spt = di_sectors_per_track(*di, *ts\track)      
                    ;
                    ; --- TODO: Interleave Write    
                    ;*ts\sector = (*prevts\sector + interleave(*di\type)) % spt;
                                        
                    For n = 0 To spt-1
                        *ts\sector  = n
                        FreeBlocks.i = di_is_ts_free(*di, *ts)
                        If FreeBlocks          
                            debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                        EndIf			
                    Next        
                EndIf
                
            Next CurrentTrack
        EndIf
        
        If ( CurrentTrack = 0)  Or ( CurrentTrack >= (*disk\s1+1) And CurrentTrack <= *disk\t1 )
            
            *bam = get_ts_addr(*di, *di\bam)
            
            For CurrentTrack = *disk\s1+1 To *disk\t1
                
                *ts\track = CurrentTrack
                
                If (*ts\track = *disk\res1)
                    Continue    
                EndIf
                
                If  (*bam\c[*ts\track * *disk\bpt1 + *disk\Boff])
                    
                    spt = di_sectors_per_track(*di, *ts\track)                    
                    ;
                    ; --- TODO: Interleave Write    
                    ;*ts\sector = (*prevts\sector + interleave(*di\type)) % spt;
                    
                    
                    For n = 0 To spt-1
                        *ts\sector  = n
                        FreeBlocks.i = di_is_ts_free(*di, *ts)
                        If FreeBlocks          
                            debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                        EndIf			
                    Next        
                EndIf                 
            Next CurrentTrack
        EndIf         
        
        If CurrentTrack>=*disk\s2
            
            *bam = get_ts_addr(*di, *di\bam2)
            
            For CurrentTrack = *disk\s2 To *disk\t2
                *ts\track = CurrentTrack
                
                If (*ts\track = *disk\res2 )
                    Continue
                EndIf    
                If  (*bam\c[(*ts\track - *disk\t1) * *disk\bpt1 + boff])
                    
                    spt = di_sectors_per_track(*di, *ts\track);
                    ;
                    ; --- TODO: Interleave Write    
                    ;*ts\sector = (*prevts\sector + interleave(*di\type)) % spt;
                    
                    For n = 0 To spt-1
                        *ts\sector  = n
                        FreeBlocks.i = di_is_ts_free(*di, *ts)
                        If FreeBlocks          
                            debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                        EndIf			
                    Next
                EndIf          
            Next CurrentTrack
        EndIf
        
        *ts\track  = 0
        *ts\sector = 0
        FreeMemory(*disk)
        ProcedureReturn *ts  
        
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Write D81
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i alloc_next_ts_D81(*di.DiskImage, *ts.TrackSector, *prevts.TrackSector,  *disk.WriteProfil, CurrentTrack)
        
        Define *bam.offset 
        
        *disk\s1    = 1
        *disk\s2    = 41
        *disk\t1    = 40
        *disk\t2    = 80
        *disk\res1  = 40
        *disk\res2  = 0
        *disk\bpt1  = 6
        *disk\bpt2  = 0
        *disk\Boff  = 10            
        
        If ( CurrentTrack <= ( *disk\t1) )
            
            *bam = get_ts_addr(*di, *di\bam)
            
            For CurrentTrack =  CurrentTrack To *disk\s1 Step -1
                
                *ts\track = CurrentTrack                    
                
                If *disk\res1 = CurrentTrack 
                    ; Track 40, jump over
                    Continue
                EndIf
                
                If  (*bam\c[*ts\track * *disk\bpt1 + *disk\Boff])
                    
                    spt = di_sectors_per_track(*di, *ts\track)                    
                    ;
                    ; --- TODO: Interleave Write    
                    ;*ts\sector = (*prevts\sector + interleave(*di\type)) % spt;
                                        
                    For n = 0 To spt-1
                        *ts\sector  = n
                        FreeBlocks.i = di_is_ts_free(*di, *ts)
                        If FreeBlocks          
                            debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                        EndIf			
                    Next        
                EndIf
                
            Next CurrentTrack
        EndIf
        
        If ( CurrentTrack = 0 )
            CurrentTrack = *disk\s2
        EndIf
        
        ; Side B 40 Tracks, Starting at Track 41
        If ( CurrentTrack >= *disk\s2 )
            
            *bam = get_ts_addr(*di, *di\bam2)
            
            For CurrentTrack = CurrentTrack To *disk\t2
                
                *ts\track = CurrentTrack
                
                If  (*bam\c[(*ts\track - *disk\res1) * *disk\bpt1 + *disk\Boff])
                    
                    spt = di_sectors_per_track(*di, *ts\track)                    
                    ;
                    ; --- TODO: Interleave Write    
                    ;*ts\sector = (*prevts\sector + interleave(*di\type)) % spt;
                                        
                    For n = 0 To spt-1
                        *ts\sector  = n
                        FreeBlocks.i = di_is_ts_free(*di, *ts)
                        If FreeBlocks          
                            debug_write_info( *di, *ts): di_alloc_ts(*di, *ts): FreeMemory(*disk): ProcedureReturn *ts
                        EndIf			
                    Next        
                EndIf                 
            Next CurrentTrack
        EndIf         
        
        *ts\track  = 0
        *ts\sector = 0
        FreeMemory(*disk)
        ProcedureReturn *ts  
        
    EndProcedure         
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i alloc_next_ts(*di.DiskImage, *prevts.TrackSector)
        
        Protected CurrentTrack.i
        Define *bam.ByteArrayStructure, *ts.TrackSector, *test.TrackSector, *disk.WriteProfil
        
        *ts     = AllocateMemory(2)
        *disk   = AllocateMemory(SizeOf(WriteProfil))
        
        Select *di\Type
            Case "D64", "D71" 
                If (*prevts\track = 0)
                    CurrentTrack = 17            
                Else
                    CurrentTrack = *prevts\track
                EndIf    
            Case "D81"  
                If (*prevts\track = 0)
                    CurrentTrack = 39            
                Else
                    CurrentTrack = *prevts\track
                EndIf                  
        EndSelect 
        
                
        Select *di\Type
            Case "D64"        
                ProcedureReturn alloc_next_ts_D64(*di, *ts, *prevts, *disk, CurrentTrack)
            Case "D71"   
                ProcedureReturn alloc_next_ts_D71(*di, *ts, *prevts, *disk, CurrentTrack)
            Case "D81"   
                ProcedureReturn alloc_next_ts_D81(*di, *ts, *prevts, *disk, CurrentTrack)                    
        EndSelect            
        
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Save DiskImage
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    Procedure di_sync( *di.DiskImage )
        
        Protected SaveFile, Diskimage, li.i, left.i
        
        Define Diskimage = OpenFile( #PB_Any, *di\dateipath+*di\dateiname,#PB_File_SharedRead|#PB_File_SharedWrite )
        
        If ( Diskimage )
            *file  = AllocateMemory(MemorySize( *di\image))
            *file  = *di\image        
            left.i = *di\size
            CloseFile( Diskimage )
        EndIf
        
        Define SaveFile = CreateFile(#PB_Any, *di\dateipath+*di\dateiname,#PB_File_SharedRead|#PB_File_SharedWrite)           
        If ( SaveFile )
            WriteData(SaveFile, *file, left)
            CloseFile(SaveFile)     
        EndIf    
        
        *di\modified = 0 
        ProcedureReturn      
    EndProcedure  
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure di_free_image(*di.DiskImage)
        If (*di\modified) 
            di_sync(*di)
        EndIf        
        FreeMemory( *di )          
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------
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
                    Continue
                Else
                    ProcedureReturn 0
                EndIf
                
            EndIf      
        Next
        
        ProcedureReturn 1
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i Check_Zero_Pattern(*rawname.Rawname) 
        
        Protected CharPos.i, Count.i
        For CharPos = 0 To 15
            If *rawname\c[CharPos] = 0
                Count + 1
            EndIf
        Next        
        ProcedureReturn Count
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.c Filetype_Get_Locked(*buffer.ByteArrayStructure, offset)  
        ProcedureReturn *buffer\c[offset +2] & $40    ; // locked file?                
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.c Filetype_Get_Closed(*buffer.ByteArrayStructure, offset)         
        ProcedureReturn *buffer\c[offset +2] & $80    ; // closed file?                
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* parse t64 header for required information */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i T64_GetFile_Records(*di.DiskImage, *the.TapHeader)
        
        
        *di\Tape\RecMax =  PeekW(*the\Rec_Max)
        *di\Tape\RecUse =  PeekW(*the\Rec_Used)
       
        If (*di\Tape\RecMax = 0)
            Warning$ = "Maximum Records count reported as 0. Adjusting to 1"
            T64_AddFix_Element(Warning$, *di\Tape\FixesDescriptions())               
            *di\Tape\RecMax = 1
            *di\Tape\Fixes  + 1
            If ( *di\Tape\Fixit = #True )            
                FillMemory( *di\image + $22, 1, $01) 
            EndIf    
        EndIf
        
        If (*di\Tape\RecUse = 0)           
            Warning$ = "The used Records count reported as 0. Adjusting to 1"           
            T64_AddFix_Element(Warning$, *di\Tape\FixesDescriptions())             
            ; this fix is required For the other fixes To work
            *di\Tape\RecUse = 1
            *di\Tape\Fixes  + 1
            If ( *di\Tape\Fixit = #True )            
                FillMemory( *di\image + $24, 1, $01) 
            EndIf    
        EndIf
        
        If (*di\Tape\RecUse > *di\Tape\RecMax)     
            Warning$ = "The header reports more used ("+Str(*di\Tape\RecUse)+") Records than Max Records ("+Str(*di\Tape\RecMax)+")."
            *di\Tape\RecUse = *di\Tape\RecMax
            *di\Tape\Fixes  + 1  
        EndIf    
        
        ; copy tape name: warning: NOT 0-terminated
        CopyMemory(*the\UserDescr, *di\Tape\TapeName, 16)                                                          
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    Procedure.i T64_Scratch_File(*di.DiskImage, *tde.TapDirEntry, *the.TapHeader)
        
        Protected *TapeFile.offset, *mve.TapDirEntry, *CurrentEntry.offset, *NextStep.Offset,  *sOffset.Uint16,  *gOffset.OffsetIn, *dta.offset
        Protected i.i, bOffset.l,  DataLenght.q, IndexCount.i
        
        Structure TapeFile
            *cEntry.TapDirEntry
            *cData.offset
        EndStructure
        
        Dim Tape.TapeFile(1)
        
        *sOffset      = AllocateMemory(2)        
        ;
        ;
        ; Set New File Size
        TapeFileT64Size = *di\size - ( get_uint16(*tde\EndAddr) - get_uint16(*tde\StartAddr) )     
        TapeFileT64Size- $20 
        ;
        ; Alloc the New Tape
        *TapeFile = AllocateMemory( TapeFileT64Size )
        If MemorySize( *TapeFile )                    
            
            ;
            ; ================================================================== Create New Tape, Header & Entrys            
            ;
            ;
            ; Header to *Tape
            CopyMemory( *di\image , *TapeFile, $40 )
            
            ;
            ; Move Entrys
            For Records = 0 To  PeekW(*the\Rec_Max) -1                                    
                
                *mve   = *di\image + $40 + Records * $20
                
                If ( CompareMemory(*tde, *mve, $20 ) = 0 )                                                             
                    ReDim Tape.TapeFile(IndexCount)
                    
                    DataLenght      = get_uint16( *mve\EndAddr) - get_uint16( *mve\StartAddr)
                    DataOffeset     = get_uint16( *mve\Container )
                    
                    *dta = AllocateMemory( DataLenght )
                    If MemorySize( *dta ) 
                        
                        MoveMemory( *di\image + DataOffeset, *dta , DataLenght )
                        
                        Tape(IndexCount)\cEntry = *mve
                        Tape(IndexCount)\cData  = *dta 
                    EndIf
                    IndexCount.i + 1                                
                EndIf
            Next                
            
            DataLen = 0
            Records = ArraySize( Tape() ) 
            
            ;
            ; ================================================================== Create New Tape, New End Adress
            For IndexCount = 0 To Records
                
                ;
                ; Kopiere die Einträge
                CopyMemory( Tape(IndexCount)\cEntry, *TapeFile + $40 + IndexCount * $20, $20)                                               
                
                ;
                ; Berechne die neue Endadresse, bei der 1.sten Datei fange wir mit 0 nun
                ; da die Daten sofort nach dem letzten Tape eintrag beginnen             
                Set_uint16( *sOffset , $40 + (Records +1) * $20 + DataLen)
                
                *NextStep = *TapeFile + $40 + IndexCount * $20
                *NextStep + 8
                Highbyte  = 0
                
                FillMemory( *NextStep   ,  1, *sOffset\c[0] )  ; New Offset                
                FillMemory( *NextStep +1,  1, *sOffset\c[1] )  ; New Offset                 
                
                If ( DataLen > 65535 )
                    For High = 65535 To DataLen Step 65535
                        Highbyte + 1
                    Next    
                    
                    Set_uint16( *sOffset , Highbyte)
                    
                    FillMemory( *NextStep +2,  1, *sOffset\c[0] )  ; New Offset                
                    FillMemory( *NextStep +3,  1, *sOffset\c[1] )  ; New Offset                        
                EndIf                  
                ;
                ; Gibt es weitere Datei Enträge ??
                If ( IndexCount + 1 <= Records )
                    ;
                    ; Fortführend ab der 2. Datei
                    DataLen +  MemorySize( Tape(IndexCount)\cData )
                EndIf                               
            Next  
            ;
            ; ================================================================== Create New Tape, New End Adress Copy Data
            ;
            Records   = ArraySize( Tape() )           
            nOffset   = 0                                           ; Der nächste Offset wo die Daten im
                                                                    ; neuen Tape abgelegt werden
            For IndexCount = 0 To Records
                ;
                ; Hole die Datenlänge
                DataLen =  MemorySize( Tape(IndexCount)\cData )
                ;
                ; Kopiere die Daten Vom Jeweiligemn Datei Eintrag
                CopyMemory( Tape(IndexCount)\cData, *TapeFile + $40 +  (Records +1) * $20 + nOffset, DataLen)                                               
                ;
                ; Gibt es weitere Datei Enträge ??                
                If ( IndexCount + 1 <= Records )
                    ;
                    ; Die Datenlänge ist das Ende des neuen Offsets
                    nOffset + DataLen
                EndIf                    
            Next             
            
            ;
            ; Update the File Entry Counts
            FillMemory( *TapeFile + $22                ,  1, Records+1 ,#PB_Byte)
            FillMemory( *TapeFile + $24                ,  1, Records+1 ,#PB_Byte)              
            ;
            ; ================================================================== Ersetze das neue Abbild im Pointer
            FreeMemory( *di\image)
            *di\image = AllocateMemory( TapeFileT64Size)
            *di\image = *TapeFile
            
            ProcedureReturn *tde 
       EndIf 
        
   EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.l T64_FindFile_Entry(*di.DiskImage, *Oldpattern.Rawname, *NewPattern.Rawname, FileType.i, Option$)
        
        Define *p.UnsignedChar
        
        Protected *tde.TapDirEntry, *the.TapHeader, *buffer, *Record.T64_Record, SearchResult$
        
        *the = AllocateMemory(SizeOf (TapHeader) )
        
        CopyMemory(*di\image, *the, $3F)              ; Copy Header To The Strucutre                            
        T64_GetFile_Records(*di, *the)
        
        
        ResetList( *di\Tape\Records() )                                
        
        SearchResult$ = "File Not Found: " + Search_Result(*Oldpattern) + #CRLF$
        ; ===================================================================================== ;                
        For Records = 0 To *di\Tape\RecUse -1
            
            *tde =  *di\image + $40 + Records * $20
            If *tde
                
                
                SearchResult$ + "Found File #"+ Base_RSet_Int(Records) +": " + Search_Result(*tde\FileName)
                If ( Check_Zero_Pattern(*tde\FileName) = 16 )                                            
                    Continue
                EndIf  
                
                Matched = match_pattern(*tde\FileName, *Oldpattern)
                If Matched = 0
                    
                    ;
                    ; --- FIXME: Try Shifted Down/Up ?
                    ptoa(*Oldpattern)
                    Matched = match_pattern(*tde\FileName, *Oldpattern)
                    If Matched = 0
                        ptoa(*Oldpattern)
                        Continue
                    EndIf
                EndIf
                
                If Matched
                    Select Option$
                        Case "RENAME"                            
                            CopyMemory( *NewPattern, *tde\FileName, 16 )                           
                            ProcedureReturn *tde
                        Case "SCRATCH"
                            T64_Scratch_File(*di, *tde, *the)
                            ProcedureReturn *tde                            
                    EndSelect
                EndIf
            EndIf                 
        Next 
        CBMDiskImage::*er\s = SearchResult$
    EndProcedure           
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------            
    Procedure.l find_file_entry(*di.DiskImage, *rawpattern.Rawname, FileType.i)
        
        Protected Result.i, pResult.s = "", Matched.i, CharPos.i, SearchResult$
        
        Define *p.UnsignedChar
        
        Protected *ts.TrackSector
        Protected *rde.RawDirEntry
        Protected *buffer
        
        Select  *di\Type
            Case "D81"
                ; Go to the First Directory Entry
                *ts = next_ts_in_chain(*di, *di\dir)                   
            Default
                *ts = next_ts_in_chain(*di, *di\bam) 
        EndSelect 
        
        SearchResult$ = "File Not Found: " + Search_Result(*rawpattern) + #CRLF$
        ; ===================================================================================== ;  
        While (*ts\track)
            
            *buffer = get_ts_addr(*di, *ts);              
            
            For offset = 0 To 255 Step 32
                
                *rde = *buffer + offset
                
                If *rde
                    
                    SearchResult$ + "Found File #"+ Base_RSet_Int(Records) +": " + Search_Result(*rde\rawname)
                    If ( Check_Zero_Pattern(*rde\rawname) = 16 )                                            
                         Continue
                    EndIf    
                                
                    If (*rde\type = 0)
                        ;CBMDiskImage::*er\s = "Found Deleted File: " + PeekS(*rde\rawname,16, #PB_Ascii)
                    EndIf
                                        
                    If (*rde\type & $3f) Or (*rde\type & 64) Or (*rde\type = 0) Or (*rde\type = -128)               ; Mask out Splat and Locked Files (Type, 63, 64)
                        
                        Matched = match_pattern(*rde\rawname, *rawpattern)
                        If Matched = 0
                            ;
                            ; --- FIXME: Try Shifted Down/Up ?
                            ptoa(*rawpattern)
                            Matched = match_pattern(*rde\rawname, *rawpattern)
                            If Matched = 0
                                ptoa(*rawpattern)
                                Continue
                            EndIf
                        EndIf                                                       
                        
                        If Matched
                            *di\pattern\a = *rde\type & 7
                            *di\pattern\s = Filetype_Get(*di\pattern\a) ; Pattern for SaveFile
                            
                            pResult = Filetype_Get(*di\pattern\a)                        
                            
                            If Filetype_Get_Closed(*rde\rawname, offset) > 1
                                pResult = "*"+pResult
                            EndIf
                            
                            If Filetype_Get_Locked(*rde\rawname, offset) = 0
                                pResult + "<"
                            EndIf                    
                            
                            *di\pattern\o            = pResult                          ; Original Pattern                   
                            *di\BlocksPerFile\Blocks = *rde\sizelo + *rde\sizehi        ; Block Size
                            *di\BlocksPerFile\Bytes  = *di\BlocksPerFile\Blocks * 254   ; Byte Size
                            *di\BlocksPerFile\KBytes = *di\BlocksPerFile\Bytes / 1024   ; Kilobyte.. however
                            
                            ProcedureReturn *rde 
                        EndIf
                    EndIf
                EndIf
            Next offset
            
            *ts = next_ts_in_chain(*di, *ts);
        Wend 
        CBMDiskImage::*er\s = SearchResult$
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* allocate next available directory block */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i alloc_next_dir_ts(*di.DiskImage)
        
        Protected   spt.i, x.i
        Define      *p.offset
        Static      ts.TrackSector, lastts.TrackSector
        
        If (di_track_blocks_free( *di, *di\bam\track) )
            
            ts\track  = *di\bam\track;
            ts\sector = 0
            
            While (ts\track)                
                lastts   = ts
                *p       = next_ts_in_chain(*di, @ts)
                ts\track = *p\c[0]
                ts\sector= *p\c[1]
                
            Wend 
            
            ts\track  = lastts\track
            ts\sector = lastts\sector + 3
            spt       = di_sectors_per_track(*di, ts\track)
                        
            For  x = ts\sector To spt-1
                
                If (di_is_ts_free(*di, @ts) )
                    
                    *p      = get_ts_addr(*di, @lastts)
                    *p\c[0] = ts\track
                    *p\c[1] = ts\sector
                    *p      = get_ts_addr(*di, @ts);
                    
                    FillMemory( *p, 256, 0)
                    *p\c[1] = $ff
                    
                    *di\modified = 1
                    ProcedureReturn @ts
                EndIf
                
            Next    
            
        Else
            ts\track = 0
            ts\sector= 0
            ProcedureReturn @ts
        EndIf
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.l alloc_file_entry(*di.DiskImage, *rawname.rawname, FileType.i)
        
        Protected *buffer.offset, *ts.TrackSector, *lastts.TrackSector,*rde.RawDirEntry, offset.i, *er.LastError, x.i, n.i, File$
        ;
        ; -------------------------------------------------------------------------- check If file already exists
        *ts = next_ts_in_chain(*di, *di\bam)                                        ; 
        While (*ts\track)
            
            *buffer = get_ts_addr(*di, *ts)
            
            For offset = 0 To 255 Step 32
                
                *rde = *buffer + offset           
                If (*rde\type & $3f)                                                ; mask OUT file type To ignore closed/locked DEL files
                    
                    x = 0
                    For n = 0 To 15
                        If *rawname\c[n] ! *rde\rawname\c[n]
                            Continue
                        Else    
                            x + 1                                                                                                     
                        EndIf    
                        
                        If ( x = 16 )
                            Set_status(*di, 63, 0, 0); 
                            
                            Petscii_2_Ascii_Convert_Zero(*rde\rawname)
                            File$ = PeekS(*rde\rawname, 16, #PB_Ascii)
                            File$ = Trim( File$ )
                            CBMDiskImage::*er\s = "File Exists: " + File$ + "," + Filetype_Check(*rde\type)
                            
                            ProcedureReturn 0  
                        EndIf    
                        
                    Next                      
                EndIf 
            Next offset
            *ts = next_ts_in_chain(*di, *ts)
        Wend
        
        ;
        ; -------------------------------------------------------------------------- Allocate empty slot                     
        Select  *di\Type                                                            ;
            Case "D81"
                ; Go to the First Directory Entry
                *ts = next_ts_in_chain(*di, *di\dir) 
            Default
                *ts = next_ts_in_chain(*di, *di\bam) 
        EndSelect 
        
        While (*ts\track)
            
            *buffer = get_ts_addr(*di, *ts)
            
            For offset = 0 To 255 Step 32             
                *rde = *buffer + offset
                
                debug_alloc_File_Entry( *di, *ts, *rde)
                
                If (*rde\type = 0)
                    
                    FillMemory( *rde + 4, 28, 0)                    
                    CopyMemory( *rawname, *rde\rawname,16 )
                    
                    *rde\type       = FileType
                    *di\modified    = 1
                    *di\SizeOffset  = offset                                        ; Remember Offset For Block File Size	
                    ProcedureReturn *rde
                EndIf
                
            Next offset
            *lastts = *ts          
            *ts     = next_ts_in_chain(*di, *ts)          
        Wend    
        
        ;
        ; -------------------------------------------------------------------------- Allocate new directory block
        
        *ts = alloc_next_dir_ts(*di)
        If (*ts\track)
            
            *rde             = get_ts_addr(*di, *ts)
            
            FillMemory( *rde + 2, 30, 0)
            CopyMemory( *rawname, *rde\rawname,16 )
            
            *rde\type       = FileType            
            *di\modified    = 1            
            *di\SizeOffset  = offset                                                ; Remember Offset For Block File Size
            
            debug_alloc_File_Entry( *di, *ts, *rde)
            ProcedureReturn *rde
        Else
            set_status(*di, 72, 0, 0);
            ProcedureReturn 0
        EndIf
        
        
    EndProcedure 

    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Fix T64 Header
    ; -----------------------------------------------------------------------------------------------------------------------------------------      
    Procedure.i T64_Header_Fix(*di.DiskImage)        
        Protected  *C64SMagic.Rawname  
        
        If ( *di\Tape\HeaderResult > 0 ) And ( *di\Tape\Fixit = #True )
            
            *C64SMagic = AllocateMemory(20)            
            
            PokeS(*C64SMagic, "C64S tape image file", 20, #PB_Ascii)            
            
            FillMemory(*di\image ,        32,  0)
            CopyMemory(*C64SMagic, *di\image, 20)                        
        EndIf
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Open a File */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.l di_open(*di.DiskImage, *rawname.rawname, Filetype.i, Mode.s)
        
        Define *p.offset
        
        If ( *di = 0 )      :ProcedureReturn  0
        ElseIf  ( *di = -1 ):ProcedureReturn -1
        ElseIf  ( *di = -2 ):ProcedureReturn -2
        EndIf   
        
        *imgfile.ImageFile = AllocateMemory( SizeOf(ImageFile)  )
        InitializeStructure(*imgfile, ImageFile)
        
        *rde.RawDirEntry   = AllocateMemory( SizeOf(RawDirEntry))
        InitializeStructure(*rde, RawDirEntry)  
        
        *the.TapHeader   = AllocateMemory( SizeOf(TapHeader))
        InitializeStructure(*rde, TapHeader)
        
        *tde.TapDirEntry   = AllocateMemory( SizeOf(TapDirEntry))
        InitializeStructure(*rde, TapDirEntry)         
                                
        set_status(*di, 255, 0, 0);

        Select Mode
            ;
            ; ------------------------------------------------------------- ; Read Mode                
            Case "rb"                
                If ( *rawname = '$' )
                    
                    *imgfile\mode   = "r"
                    *imgfile\ts     = *di\dir                    
                    *p              = get_ts_addr(*di, *di\dir)
                    *imgfile\buflen = 254;                   
                    *rde            = 0                       
                    
                    Select *di\type
                        Case "D64", "D71"
                            *imgfile\buffer         = *p + 2;
                            *imgfile\nextts\track   = 18                  ; 1541/71 ignores bam t/s link
                            *imgfile\nextts\sector  = 1 
                 
                        Case "D81"
                            *imgfile\buffer         = *p + 2;
                            *imgfile\nextts\track   = *p\c[0]
                            *imgfile\nextts\sector  = *p\c[1]  
                        Case "T64"      
                            
                            T64_Header_Fix(*di.DiskImage)
                            CopyMemory(*di\image, *the, $3F)              ; Copy Header To The Strucutre                            
                            T64_GetFile_Records(*di, *the)
                            
                            *imgfile\buffer = *p - $20 
                            *imgfile\nextts\track   = 1
                            *imgfile\nextts\sector  = 0                              
                    EndSelect                            
                Else
                    
                    Select *di\type
                        Case "D64", "D71", "D81"                    
                            *rde = find_file_entry(*di, *rawname, Filetype)
                            If ( *rde = 0 )
                                set_status(*di, 62, 0, 0): FreeMemory(*imgfile): ProcedureReturn 0
                            EndIf
                            
                            *imgfile\mode = "r"
                            *imgfile\ts = *rde\startts
                            
                            If (*imgfile\ts\track > di_tracks(*di))
                                ProcedureReturn 0
                            EndIf   
                            
                            *p                     = get_ts_addr(*di, *rde\startts)
                            
                            *imgfile\buffer        = *p + 2                    
                            *imgfile\nextts\track  = *p\c[0]
                            *imgfile\nextts\sector = *p\c[1]
                            
                            If (*imgfile\nextts\track = 0)
                                *imgfile\buflen = *imgfile\nextts\sector - 1
                            Else
                                *imgfile\buflen = 254
                            EndIf  
                            
                        Case "T64"
                            
                            T64_Header_Fix(*di.DiskImage)
                            CopyMemory(*di\image, *the, $3F)              ; Copy Header To The Strucutre                            
                            T64_GetFile_Records(*di, *the)                            
                            
                            *imgfile\buffer         = *p - $20 
                            *imgfile\nextts\track   = 1
                            *imgfile\nextts\sector  = 0                              
                    EndSelect        
                EndIf 
            ;
            ; ------------------------------------------------------------- ; Write Mode                
            Case "wb"
                
                Select *di\type
                    Case "D64", "D71", "D81"                  
                        *rde = alloc_file_entry(*di, *rawname, Filetype)
                        If (*rde = 0)                      
                            ProcedureReturn 0
                        EndIf
                        
                        Case "T64"                            
                            T64_Header_Fix(*di.DiskImage)
                            CopyMemory(*di\image, *the, $3F)              ; Copy Header To The Strucutre                            
                            T64_GetFile_Records(*di, *the) 
                EndSelect            
                *imgfile\mode       = "w"
                *imgfile\ts\track   = 0
                *imgfile\ts\sector  = 0                    
                *imgfile\buffer     = AllocateMemory(254)
                *imgfile\buflen     = 254
                *di\modified        = 1                                                                                     
                
        EndSelect
        
        *imgfile\diskimage      = *di
        *imgfile\rawdirentry    = *rde
        *imgfile\TapHeader      = *the
        *imgfile\TapDirentry    = *tde
        *imgfile\position       = 0
        *imgfile\bufptr         = 0
        
        *di\openfiles           + 1
        
        set_status(*di, 0, 0, 0)
        
        ProcedureReturn *imgfile
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Calculate the End Adress Offset */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i T64_Calculate_End_Adress( *EndAdress.Uint16, StartAdress.i, BytesLenght.i)
        set_uint16(*EndAdress, BytesLenght + StartAdress)
    EndProcedure      
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;    * Fix End addresses by sorting file records on Data offset And then using
    ;    * either the Data offset of the Next entry, Or the length of the t64 file
    ;    * To get the proper End address
    ;    * sort entries based on offset/ Index
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i T64_QSort_Compare_Offsets(List Records.T64_Record())                   
        SortStructuredList( Records(), 0, OffsetOf(T64_Record\Offset), TypeOf(T64_Record\Offset) )        
    EndProcedure 
    Procedure.i T64_QSort_Compare_Index(List Records.T64_Record())                   
        SortStructuredList( Records(), 0, OffsetOf(T64_Record\Index), TypeOf(T64_Record\Index) )        
    EndProcedure       
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; 
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i T64_Verify_Size_and_Offsets(*image.ImageFile)
        
        Protected rec_size.i ;  /* file size according to record */
        Protected act_size.i ;  /* actual file size */
        Protected i.i, IllegalValue$, *sOffset.Uint16
        
        *sOffset = AllocateMemory(2)
        
        ; ------------------------------------------------------------------------------------- /* check maximum record count           */
        If (*image\diskimage\Tape\RecMax = 0)     
            Warning$ = "Maximum Records count reported as 0. Adjusting To 1"
            T64_AddFix_Element(Warning$, *image\diskimage\Tape\FixesDescriptions()) 
            *image\diskimage\Tape\RecMax =  1
            *image\diskimage\Tape\Fixes  +  1
            If ( *image\diskimage\Tape\Fixit = #True )
                FillMemory( *image\diskimage\image + $22, 1, $01) 
            EndIf    
        EndIf

        
        ; ------------------------------------------------------------------------------------- /* check number of used records         */
        If (*image\diskimage\Tape\RecUse = 0)      
            Warning$ = "The used Records count reported as 0. Adjusting To 1"
            T64_AddFix_Element(Warning$, *image\diskimage\Tape\FixesDescriptions())             
            
            ; this fix is required For the other fixes To work
            *image\diskimage\Tape\RecUse = 1
            *image\diskimage\Tape\Fixes  + 1
            If ( *image\diskimage\Tape\Fixit = #True )           
                FillMemory( *image\diskimage\image + $24, 1, $01) 
            EndIf    
        EndIf
                              
        T64_QSort_Compare_Offsets(*image\diskimage\Tape\Records())
        
        ; ------------------------------------------------------------------------------------- /* process records, reporting any       */
                                                                                              ; /* invalid Data, optionally fixing it   */
        For i = 0 To *image\diskimage\Tape\RecUse -1
            
            SelectElement( *image\diskimage\Tape\Records() , i)
            
            *CurrRecords.T64_Record = *image\diskimage\Tape\Records()
            *NextRecords.T64_Record = AllocateMemory(SizeOf( T64_Record ))
            
            ; Check file type
            If (*CurrRecords\C64s__FileType > $01)
                
                ; Memory Snapshot Found
                *CurrRecords\Status           = #T64_REC_SKIPPED                
            Else
                
                If (*CurrRecords\C1541_FileType < $80 ) And (*CurrRecords\C1541_FileType >= $85)
                    IllegalValue$ = Hex(*CurrRecords\C1541_FileType,#PB_Byte)
                    
                    Warning$ = "Illegal Value $"+ IllegalValue$ + " for 1541 FileType. Assuming (PRG) ($82)"
                    
                    T64_AddFix_Element(Warning$, *image\diskimage\Tape\FixesDescriptions())                      
                    
                    *CurrRecords\C1541_FileType   = $82
                    *CurrRecords\Status         = #T64_REC_FIXED
                    *image\diskimage\Tape\Fixes + 1
                    If ( *image\diskimage\Tape\Fixit = #True )
                        FillMemory( *image\diskimage\image + $40 + i + $02, 1, $82)                    
                    EndIf    
                    
                EndIf

                *CurrRecords = *image\diskimage\Tape\Records()
                
                If (i < *image\diskimage\Tape\RecUse - 1)
                    SelectElement( *image\diskimage\Tape\Records(),  i + 1)
                    *NextRecords = *image\diskimage\Tape\Records();
                Else
                    *NextRecords = 0
                EndIf                
                
                ; /* get reported size */                                
                rec_size = Abs( *CurrRecords\EndAddr - *CurrRecords\StartAddr)
                ; /* determine actual size */
                If (i < *image\diskimage\Tape\RecUse - 1)
                    act_size = *NextRecords\Offset   - *CurrRecords\Offset
                Else    
                    act_size = *image\diskimage\size - *CurrRecords\Offset
                EndIf
                
                *CurrRecords\Bytes             = *CurrRecords\EndAddr - *CurrRecords\StartAddr 
                *CurrRecords\Blocks            = Round(*CurrRecords\Bytes / 254,#PB_Round_Up)
                
                If (rec_size ! act_size)
                    
                    If ( ( i = (*image\diskimage\Tape\RecUse -1) ) And ( rec_size < act_size) )
                        ; /* don't fix last record when actual size is larger: some
                        ; * T64's have padding for the last record */
                        Continue
                    EndIf                    
                    Warning$ = "The Reported size of "+Str(rec_size)+"b doesn't match actual size of "+Str(act_size)+"b for Filename "+ PeekS(*CurrRecords\Filename, 16, #PB_Ascii )
                    
                    T64_AddFix_Element(Warning$, *image\diskimage\Tape\FixesDescriptions())  
                    
                    *CurrRecords\Status         = #T64_REC_FIXED
                    *image\diskimage\Tape\Fixes + 1
                    
                    *CurrRecords\Real_End_Addr = *CurrRecords\StartAddr + act_size
                    
                    If ( *image\diskimage\Tape\Fixit = #True )
                        T64_Calculate_End_Adress(*sOffset, 2049, act_size)
                    
                        FillMemory( *image\diskimage\image + $40 + (Records + $04),  1, *sOffset\c[0] )  ; New End Adress                
                        FillMemory( *image\diskimage\image + $40 + (Records + $05),  1, *sOffset\c[1] )  ; New End Adress                     
                    EndIf    
                    
                Else
                    *CurrRecords\Real_End_Addr =  *CurrRecords\EndAddr
                EndIf
                

            EndIf
            
        Next i   
        
        ; /* Restore original record order */
        T64_QSort_Compare_Index(*image\diskimage\Tape\Records())
        
        ProcedureReturn *image\diskimage\Tape\Fixes   
    EndProcedure                  
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Read a single record into \a record using \a data
    ; 0x08 < offset in container to file data, 32-bit little endian
    ; -----------------------------------------------------------------------------------------------------------------------------------------        
    Procedure.i T64_Read_Record(RecUsedIndex, *buffer.offset, List Records.T64_Record())                             
        AddElement( Records() )  
        FillMemory( Records()\Filename , 16, $a0)
        
        CopyMemory( *buffer+$10 ,Records()\Filename , 16)

        Records()\Offset            = get_uint32(*buffer + $08)        
        Records()\StartAddr         = get_uint16(*buffer + $02)     
        Records()\EndAddr           = get_uint16(*buffer + $04)
        Records()\C64s__FileType    = PeekB( *buffer + $00 )
        Records()\C1541_FileType    = PeekB( *buffer + $01 )                
        Records()\Index             = RecUsedIndex        
        Records()\Status            = #T64_REC_OK
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; allocate and read records
    ; 0x40    < offset IN container of records
    ; 0x20    < size of a file record    
    ; -----------------------------------------------------------------------------------------------------------------------------------------      
    Procedure.i  T64_Allocte_and_Read_Records(*imgfile.ImageFile)                
        For RecUsedIndex = 0 To *imgfile\diskimage\Tape\RecUse -1
            T64_read_record(RecUsedIndex, *imgfile\diskimage\image + $40 + RecUsedIndex * $20, *imgfile\diskimage\Tape\Records())            
        Next                  
    EndProcedure          
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Read first block INTO buffer */
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i di_read(*imgfile.ImageFile, *buffer.CharBuffer, len.i)
        
        Protected *p.offset , bytesleft.i ,  counter.i
        Protected *tts.TrackSector
        
        ;
        ; Tape Images Doesnt use the Disk Images Sources
        Select *imgfile\diskimage\Type              
               Case "T64": ProcedureReturn 254
        EndSelect           
        
        ;
        ;
        FillMemory(*buffer, 255, 0)         
        
        While len
           
            bytesleft = *imgfile\buflen - *imgfile\bufptr
            
            If bytesleft = 0
                
                If *imgfile\nextts\track = 0
                    ProcedureReturn counter
                EndIf
                    
                                
                If ( ( (*imgfile\diskimage\type = "D64" ) Or (*imgfile\diskimage\type = "D71") ) And (*imgfile\ts\track = 18) And (*imgfile\ts\sector = 0) )                    
                    *imgfile\ts\track       = 18
                    *imgfile\ts\sector      = 1            
                Else
                    
                    *tts = next_ts_in_chain(*imgfile\diskimage, *imgfile\ts);
             
                    ;
                    ; FIXME: Next Track and Sector 18/1?
                    If ( (*imgfile\diskimage\type = "D64" ) Or (*imgfile\diskimage\type = "D71") ) And (*tts\track = 18 And *tts\sector = 1)
                        Debug "Warning! Infinite Loop wthin" + " [Track:18/ Sector 1 ]"                   
                        *imgfile\ts\track  = 0                                                
                    Else    
                        *imgfile\ts\sector = *tts\sector
                        *imgfile\ts\track  = *tts\track                      
                    EndIf
                    
                EndIf      
                
                If (*imgfile\ts\track = 0)
                    ProcedureReturn counter
                EndIf
                
                *p = get_ts_addr(*imgfile\diskimage, *imgfile\ts)
                *imgfile\buffer        = *p + 2
                *imgfile\nextts\track  = *p\c[0]
                *imgfile\nextts\sector = *p\c[1]
               
                If (*imgfile\nextts\track = 0)
  
                    *imgfile\buflen = *imgfile\nextts\sector - 1
                    ;
                    ; Prevent 
                    If ( *imgfile\buflen = -1 )
                        Debug "Warning! " + "[*imgfile\buflen = "+Str( *imgfile\buflen )+"]"
                         *imgfile\buflen = 254
                     EndIf
                     
                     ;
                     ; Directory Potential Fix for Read Buflen < 254
                     If (*imgfile\ts\track = 18) And (*imgfile\ts\sector >= 1) And (*imgfile\nextts\sector ! 255)
                         Debug "Warning! " + "Directory Position and Next Track is 0 and Next Sector " +Str( *imgfile\nextts\sector ) +" [*imgfile\buflen = "+Str( *imgfile\buflen )+"]"
                          ;ShowMemoryViewer(*p , 2)
                         *imgfile\buflen = 254
                     EndIf                                              
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Read and get directory & blocks */
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i di_read_directory_blocks(*imgfile.ImageFile, ShowDEL.i = #True)
        
        Structure ByteArray
            c.a[0]
        EndStructure
        
        Protected *buffer.ByteArray, *name.Rawname
        
        Protected offset.i, Pattern.i, Splat.i, Locked.i, Blocks.i, FileLen.i, File$, FileType$, FileTypeOffset.i,  DelOffset.i = 0
        
        *buffer = AllocateMemory(254)
        *name   = AllocateMemory( 17)
        
        If ( di_read(*imgfile, *buffer, 254) <> 254 )
            ProcedureReturn 0
        EndIf   
        
                                                                                    ;/* Read directory blocks */
        ClearList(*imgfile\FileList())       
        
        Select *imgfile\diskimage\Type
                Case "D64", "D71", "D81"        
                    While di_read(*imgfile, *buffer, 254)
                        
                        For offset = -2 To 253 Step 32 
                         ;ShowMemoryViewer(*buffer + offset, 255)   
                          
                            
                            If ( ShowDEL = #False)                                        ; ADD DEL Files (true/false)
                                offset + 2
                            EndIf 
                            
                            If ( *buffer\c[ offset+2 ] >= DelOffset)
                                
                               ; FileLen  = di_name_from_rawname(*name, *buffer +  offset + 5)
                                File$ = PeekS(*buffer +  offset + 5, 16, #PB_Ascii ) 
                                
                                Pattern  = *buffer\c[ offset + 2] & 7
                                FileType$= Filetype_Get(Pattern)
                                
                                Splat    = *buffer\c[offset + 2] & $80                           ; Closed / Unfinished file?
                                Locked   = *buffer\c[offset + 2] & $40                           ; Locked file?
                                Blocks   = *buffer\c[offset + 31] << 8 | *buffer\c[offset + 30]  ; Block Size
                                
                                If Splat : FileType$ = " "+FileType$: Else: FileType$ = "*"+FileType$: EndIf                       
                                If Locked: FileType$ + "<"          : Else: FileType$ + " "          : EndIf     
                                
;                                 ; -- FIXME: Ascii Convert 173 to 237
;                                 For i = 0 To 15
;                                     If ( *name\c[i] = 173 )
;                                         *name\c[i] = 237
;                                     EndIf     
;                                 Next    
                                
                                                                                                             
                                
                                ; -- FIXME: Ascii Convert DEL Files
                                If ( FileType$ = "*DEL " ) And (File$ = "")
                                    For i = 0 To 15
                                        File$ + Chr(0)
                                    Next    
                                EndIf    
                                                                    
                                AddElement( *imgfile\FileList() ) 
                                *imgfile\FileList()\C64File = File$
                                *imgfile\FileList()\C64Size = Blocks
                                *imgfile\FileList()\C64Type = FileType$
                                
                            EndIf   
                        Next offset
                    Wend
                Case "T64"     
                    
                    T64_Allocte_and_Read_Records(*imgfile)
                    T64_Verify_Size_and_Offsets(*imgfile)
                    
                   If  ( *imgfile\diskimage\Tape\RecMax >= 1 )                    
                       ResetList(*imgfile\diskimage\Tape\Records())
                       
                        While NextElement( *imgfile\diskimage\Tape\Records() )
                            
                            FileLen  = di_name_from_rawname(*name, *imgfile\diskimage\Tape\Records()\Filename )
                            
                            Pattern  = *imgfile\diskimage\Tape\Records()\C1541_FileType & 7

                            If ( Pattern = 0 ) And ( ShowDEL.i = #False ) 
                                ;
                                ; Tape T64 Memory Snapshots                               
                                Continue
                            EndIf
                            FileType$= Filetype_Get_Tape(Pattern)
                                                        
                            Blocks   =  *imgfile\diskimage\Tape\Records()\Blocks                        
                                                                                  
                            File$ = PeekS(*name, FileLen, #PB_Ascii )   
                            
                            AddElement( *imgfile\FileList() ) 
                            *imgfile\FileList()\C64File = File$
                            *imgfile\FileList()\C64Size = Blocks
                            *imgfile\FileList()\C64Type = FileType$                                                        
                        Wend    
                    EndIf        
                EndSelect        
        ProcedureReturn *imgfile
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Write CBM File to Image
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure di_write(*imgfile.ImageFile, *buffer.offset, lenght.i, *di.DiskImage)
        
        Protected bytesleft.i, counter.i = 0, *nextts.Tracksector, CBMSize.i = 0, *p.offset     
        
        While (lenght)
            bytesleft = *imgfile\buflen - *imgfile\bufptr
            
            If (bytesleft = 0)                   
                If (*imgfile\diskimage\blocksfree = 0)
                    set_status(*imgfile\diskimage, 72, 0, 0)
                    ProcedureReturn counter
                EndIf                    
                
                *nextts                = alloc_next_ts(*imgfile\diskimage, *imgfile\ts)
                *imgfile\nextts\sector =  *nextts\sector
                *imgfile\nextts\track  =  *nextts\track

                If (*imgfile\ts\track = 0)
                    *imgfile\rawdirentry\startts = *imgfile\nextts
                Else                     
                    *p      = get_ts_addr(*imgfile\diskimage, *imgfile\ts)                  
                    *p\c[0] = *imgfile\nextts\track
                    *p\c[1] = *imgfile\nextts\sector                  
                EndIf
                
                *imgfile\ts = *imgfile\nextts
                *p          = get_ts_addr(*imgfile\diskimage, *imgfile\ts)
                *p\c[0]     = $00
                *p\c[1]     = $FF                      
                
                CopyMemory( *imgfile\buffer,  *p + 2,  *imgfile\bufptr)
                *imgfile\bufptr = 0;
                
                *imgfile\rawdirentry\sizelo + 1
                If ( *imgfile\rawdirentry\sizelo = 0)
                    *imgfile\rawdirentry\sizehi + 1		       
                EndIf                          
                
                *imgfile\diskimage\blocksfree - 1 
            Else
                
                If lenght >= bytesleft
                    While bytesleft   
                        *imgfile\buffer\c[*imgfile\bufptr] = *buffer\c[counter]                        
                        *imgfile\bufptr + 1 
                        counter         + 1                                                    
                        lenght          - 1
                        bytesleft       - 1
                        *imgfile\position + 1    		        
                    Wend  
                Else
                    While lenght
                        *imgfile\buffer\c[*imgfile\bufptr] = *buffer\c[counter]                      
                        *imgfile\bufptr + 1  
                        counter         + 1
                        lenght          - 1
                        bytesleft       - 1                        
                        *imgfile\position + 1
                    Wend   
                EndIf      
                
            EndIf 
        Wend
        ProcedureReturn counter
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- Write CBM File to Image > Close
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure di_close(*imgfile.ImageFile)          
        
        Protected *tts.TrackSector, *p.offset
        
        Select *imgfile\mode
            Case "w"                                
                If (*imgfile\bufptr)                                         
                    
                    If (*imgfile\diskimage\blocksfree)
                        
                        *tts.TrackSector = alloc_next_ts(*imgfile\diskimage, *imgfile\ts)
                        
                        *imgfile\nextts\sector = *tts\sector
                        *imgfile\nextts\track  = *tts\track
                        
                        If (*imgfile\ts\track = 0)
                            *imgfile\rawdirentry\startts = *imgfile\nextts
                        Else
                            *p      = get_ts_addr(*imgfile\diskimage, *imgfile\ts)
                            *p\c[0] = *imgfile\nextts\track
                            *p\c[1] = *imgfile\nextts\sector
                        EndIf
                        
                        *imgfile\ts = *imgfile\nextts
                        
                        *p          = get_ts_addr(*imgfile\diskimage, *imgfile\ts); - 
                        *p\c[0]     = $00
                        *p\c[1]     = *imgfile\bufptr+1
                        
                        *imgfile\buffer = ReAllocateMemory(*imgfile\buffer, *imgfile\bufptr )                                                
                        
                        CopyMemory(*imgfile\buffer,*p + 2 , *imgfile\bufptr)                     
                        
                        *imgfile\bufptr = 0
                        
                        *imgfile\rawdirentry\sizelo + 1
                        If ( (*imgfile\rawdirentry\sizelo + 1) = 0 )                           
                            *imgfile\rawdirentry\sizehi + 1
                        EndIf
                        
                        *imgfile\diskimage\blocksfree - 1                                            
                    EndIf                                                             
                EndIf                
                FreeMemory(*imgfile\buffer)
        EndSelect
        
        *imgfile\diskimage\openfiles - 1
        FreeMemory(*imgfile)                         
    EndProcedure        
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure di_free_ts_bam2(*di.DiskImage, *ts.TrackSector)  

        Define *bam.UnsignedChar
        Protected mask.i, track.i
        
        *di\modified = 1
        
        For track = 0 To 52
            *ts\track = track
            *bam = get_ts_addr(*di, *di\bam2);
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* free a block in the BAM */
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure di_free_ts(*di.DiskImage, *ts.TrackSector) 
        
        Define *bam.offset
        Protected mask.i
        
        *di\modified = 1
        
        Select *di\Type
            Case "D64"
                mask = 1 << (*ts\sector & 7)
                *bam = get_ts_addr(*di, *di\bam)                  
                Select *ts\track                        
                    Case 1 To 35                        
                        *bam\c[*ts\track * 4 + *ts\sector / 8 + 1] | mask
                        *bam\c[*ts\track * 4] + 1
                        ;
                        ; Marty2PB: Added Extended Tracks Support 36 to 40  
                    Case 36 To 40                                            
                        *bam\c[ (16 + *ts\track)  *3 +  *ts\track + *ts\sector / 8 + 1] | mask                           
                        *bam\c[ (16 + *ts\track)  *3 +  *ts\track ] + 1                                            
                EndSelect        
                ProcedureReturn
                
            Case "D71"    
                Select *ts\track
                        
                    Case 0 To 35
                        ; Starting at offset 16500
                        mask = 1 << (*ts\sector & 7)
                        *bam = get_ts_addr(*di, *di\bam)
                        *bam\c[*ts\track * 4 + *ts\sector / 8 + 1] | mask
                        *bam\c[*ts\track * 4] + 1
                        
                    Case 36 To 70
                        ; Starting at offset 165DC
                        *bam = get_ts_addr(*di, *di\bam);
                        *bam\c[*ts\track + 185] + 1   
                        ; FIXME
                        ; in the Original Source, Tracks 36 - 70 does'nt prepare the
                        ; Tracks at Offset 41000. I have no idea.. So I added and 
                        ; changed this With di_free_ts_bam2 and free Blocks are correct.                       
                EndSelect              
                ProcedureReturn
                
            Case "D81"
                ; FIXME
                ; The Code from the Orignal does'nt work really
                ; It missing the Bam Track Sector Preapre and
                ; overwritten some thing. It missed the 16 Byte
                ; Track Selection for BAM 2
                Select *ts\track
                    Case 1 To 39
                        mask = 1 << (*ts\sector & 7)                        
                        *bam = get_ts_addr(*di, *di\bam)
                        *bam\c[*ts\track * 6 + *ts\sector / 8 + 11] | mask
                        *bam\c[*ts\track * 6 + 10] + 1  
                    Case 40
                        *bam = get_ts_addr(*di, *di\bam)                  
                        *bam\c[*ts\track*6 + 10] = $24
                        *bam\c[*ts\track*6 + 11] = $F0
                        *bam\c[*ts\track*6 + 12] = $FF                  
                        *bam\c[*ts\track*6 + 13] = $FF
                        *bam\c[*ts\track*6 + 14] = $FF
                        *bam\c[*ts\track*6 + 15] = $FF
                    Case 41 To 80
                        mask = 1 << (*ts\sector & 7)
                        *bam = get_ts_addr(*di, *di\bam) + 16
                        *bam\c[*ts\track * 6 + *ts\sector / 8 + 11] | mask
                        *bam\c[*ts\track * 6 + 10] + 1                   
                EndSelect                      
        EndSelect
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* free a chain of blocks */
    ; -----------------------------------------------------------------------------------------------------------------------------------------       
    Procedure.i free_chain(*di.DiskImage, *ts.TrackSector )
        
        Protected  *p.offset, Bytes.q, *scratch.TrackSector
        
        Structure ScratchOffset
            DiskTrack.a
            DiskSectr.a
            Offset_Dec.i 
            Offset_Hex.s
            BlockCount.a
            BytesTotal.q
        EndStructure
        
        NewList  Scratch.ScratchOffset()
        
        While (*ts\track)
            
            di_free_ts(*di, *ts)
            
            *p = get_ts_addr(*di, *ts)
            
            AddElement( Scratch() )            
            Scratch()\DiskTrack     = *ts\track
            Scratch()\DiskSectr     = *ts\sector
            Scratch()\Offset_Dec    = *p
            Scratch()\Offset_Hex    = Hex(*p, #PB_Long)
            Scratch()\BlockCount    + ListSize( Scratch() )               
            Scratch()\BytesTotal    = Scratch()\BlockCount * 254                          
            *ts = next_ts_in_chain(*di, *ts)
            
        Wend
        ResetList   ( Scratch() )
        LastElement ( Scratch() )
        
        Bytes =  Scratch()\BytesTotal
        
        ResetList   ( Scratch() )
        While NextElement(  Scratch() )
            *ts\track = Scratch()\DiskTrack
            *ts\sector = Scratch()\DiskSectr
            *p = get_ts_addr(*di, *ts)
            FillMemory(*p    ,   1, $4b)
            FillMemory(*p + 1, 253, $01)
        Wend
        
    EndProcedure      
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- New D64 Image
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure di_format_d64(*di.DiskImage, *rawname.Rawname, *rawid.Rawname, ImageSize.q = 0, DosType.i = 0)
        
        Define *p.offset
        Static ts.TrackSector
        Protected tsTrack.i, tsSectr.i
        
        ; ------------------------------------------------------------------- /* Erase disk */
        If ( *rawid )
            FillMemory( *di\image, ImageSize, $01)                    
            Offst = 0
            For ExTrk = 0 To 682                          
                FillMemory( *di\image + Offst , 1, $4B )
                
                Offst + 256
            Next ExTrk                     
        EndIf                                
        
        *p = get_ts_addr(*di, *di\bam)              
        ;
        ; ------------------------------------------------------------------- /* setup header */             
        *p\c[0] = 18
        *p\c[1] = 1
        *p\c[2] = 'A'
        *p\c[3] = 0
        ;
        ; ------------------------------------------------------------------- /* clear bam */
        FillMemory( *p + 4, $8c, 0)   
        
        ;
        ; ------------------------------------------------------------------- /* free blocks */              
        tsTrack = 0
        tsSectr = 0
        
        For tsTrack = 1 To di_tracks(*di)
            ts\track = tsTrack
            
            For tsSectr = 0 To di_sectors_per_track(*di, ts\track) -1
                ts\sector = tsSectr                    
                di_free_ts(*di, @ts)
                
            Next  tsSectr
            
        Next tsTrack
        ; ------------------------------------------------------------------- /* allocate bam And dir */
        ts\track = 18
        ts\sector = 0
        di_alloc_ts(*di, @ts)
        ts\sector = 1
        di_alloc_ts(*di, @ts)
        
        ; ------------------------------------------------------- /* set id */
        
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
        
        ; ------------------------------------------------------------------- /* copy name */
        
        Select DosType
            Case 0, 1            
                FillMemory( *p + $90, 16, $a0)                        
            Case 2
                FillMemory( *p + $a4, 16, $a0)  
        EndSelect
        
        x = 0: For i = 0 To 15: c.a = *rawname\c[i]: If c ! 0: x + 1: EndIf: Next i   
        
        Select DosType
            Case 0, 1            
                CopyMemory( *rawname, *p + $90, x)
                
                
                FillMemory( *p + $a0, 2, $a0)   
                FillMemory( *p + $a2, 11, $a0)                          
                If (*rawid)
                    CopyMemory( *rawid, *p + $a2, 2)
                EndIf                                        
                
                
            Case 2
                CopyMemory( *rawname, *p + $a4, x)
                FillMemory( *p + $b4, 11, $a0)   
                If (*rawid)
                    CopyMemory( *rawid, *p + $b6, 2)
                EndIf                        
        EndSelect
        
        ; ------------------------------------------------------------------- /* clear unused bytes */
        
        
        Select  DosType
            Case 0:                        
                *p\c[$a5] = '2' 
                *p\c[$a6] = 'A' 
                FillMemory(*p + $ab, $55, 0)
            Case 1:
                *p\c[$a5] = '4'
                *p\c[$a6] = 'A'             
                FillMemory(*p + $ab, $55, 0)
            Case 2:
                *p\c[$b9] = '2'  
                *p\c[$ba] = 'P'                         
        EndSelect                             
        
        ; ------------------------------------------------------------------- /* clear first dir block */      
        FillMemory( *p + 256, 256, 0) 
        *p\c[257] = $ff
        
        ; ------------------------------------------------------------------- /* Adding Infos
        Select ImageSize
            Case 175531: FillMemory( *p + 83456, 683, 01)                       ; Sector Error Info
                
                ;
                ; Track 36 to 40
            Case 196608:                                                        ; Extended Tracks
                ExTrk = 0
                Offst = 83456 
                
                For ExTrk = 0 To 84                          
                    *p\c[Offst  ] = $4B
                    *p\c[Offst+1] = $01
                    FillMemory( *p + Offst +2, 254, 01)
                    Offst + 256
                Next ExTrk
                
                Select  DosType
                    Case 0,1
                        FillMemory( *p + 192   ,  20, $01FFFF11, #PB_Long)      ; Mark as Free
                    Case 2
                        FillMemory( *p + $90   ,  20, $01FFFF11, #PB_Long)      ; Mark as Free
                EndSelect        
                
                ;
                ; Track 36 to 40                        
            Case 197376:                                                        ; Extended Tracks & Sector Error Info
                ExTrk = 0
                Offst = 83456 
                For ExTrk = 0 To 84                          
                    *p\c[Offst  ] = $4B
                    *p\c[Offst+1] = $01
                    FillMemory( *p + Offst +2, 254, 01)
                    Offst + 256
                Next ExTrk 
                
                FillMemory( *p + Offst , 768, 01)
                Select  DosType
                    Case 0,1
                        FillMemory( *p + 192   ,  20, $01FFFF11, #PB_Long)      ; Mark as Free
                    Case 2
                        FillMemory( *p + $90   ,  20, $01FFFF11, #PB_Long)      ; Mark as Free
                EndSelect 
        EndSelect
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- New D71 Image
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure di_format_d71(*di.DiskImage, *rawname.Rawname, *rawid.Rawname, ImageSize.q = 0)
        
        Define *p.offset
        Static ts.TrackSector
        Protected tsTrack.i, tsSectr.i
        
        ; ------------------------------------------------------------------- /* erase disk */
        If ( *rawid )
            FillMemory( *di\image, ImageSize, $01)                    
            Offst = 0
            For ExTrk = 0 To 1348                          
                FillMemory( *di\image + Offst , 1, $4B )
                
                Offst + 256
            Next ExTrk                     
        EndIf  
        ; ------------------------------------------------------------------- /* get ptr To bam2 */
        *p = get_ts_addr(*di, *di\bam2)
        
        ; ------------------------------------------------------------------- /* clear bam2 */
        FillMemory( *p, 256, 0)
        
        ; ------------------------------------------------------------------- /* get ptr To bam */
        *p = get_ts_addr(*di, *di\bam)                             
        *p\c[0] = 18
        *p\c[1] = 1
        *p\c[2] = 'A'
        *p\c[3] = $80  
        
        ; ------------------------------------------------------------------- /* clear bam */              
        FillMemory( *p + 4, $8c, 0)
        
        
        ; ------------------------------------------------------------------- /* clear bam2 counters */              
        FillMemory(*p + $dd, $23, 0)
        
        ; ------------------------------------------------------------------- /* free blocks */              
        tsTrack = 0
        tsSectr = 0
        
        For tsTrack = 1 To di_tracks(*di)
            ts\track = tsTrack
            If ( ts\track ! 53 )
                For tsSectr = 0 To di_sectors_per_track(*di, ts\track) -1
                    ts\sector = tsSectr                     
                    di_free_ts(*di, @ts)                                              
                Next  tsSectr
            EndIf
            
        Next tsTrack         
        
        ; ------------------------------------------------------------------- /* free blocks bam 2*/              
        di_free_ts_bam2(*di, @ts)                                                   
        
        ; ------------------------------------------------------------------- /* allocate bam And dir */
        ts\track = 18
        ts\sector = 0
        di_alloc_ts(*di, @ts)
        ts\sector = 1
        di_alloc_ts(*di, @ts)
        
        ; ------------------------------------------------------------------- /* copy name */
        FillMemory( *p + $90, 16, $a0)
        x = 0
        For i = 0 To 15
            c.a = *rawname\c[i]
            If c ! 0
                x + 1
            EndIf
        Next i    
        CopyMemory( *rawname, *p + $90, x)
        
        ; ------------------------------------------------------------------- /* set id */
        FillMemory( *p + $a0, 2, $a0)   
        If (*rawid)
            CopyMemory( *rawid, *p + $a2, 2)
        EndIf
        FillMemory( *p + $a4, 7, $a0)                  
        *p\c[$a5] = '2'
        *p\c[$a6] = 'A'
        
        ; ------------------------------------------------------------------- /* clear unused bytes */
        FillMemory(*p + $ab, $32, 0)
        
        ; ------------------------------------------------------------------- /* clear first dir block */
        FillMemory(*p + 256, 256, 0)
        *p\c[257] = $ff
        ; ------------------------------------------------------------------- /* Adding Infos
        Select ImageSize
            Case 351062
                FillMemory( *p + 258304, 1366, 01)                     ; Sector Error Info        
        EndSelect                                                 
        
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- New D81 Image
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure di_format_d81(*di.DiskImage, *rawname.Rawname, *rawid.Rawname, ImageSize.q = 0)
        
        Define *p.offset
        Static ts.TrackSector
        Protected tsTrack.i, tsSectr.i  
        
        ; ------------------------------------------------------------------- /* erase disk */
        FillMemory( *di\image, ImageSize, $01)                    
        Offst = 0
        For ExTrk = 0 To 3159                          
            FillMemory( *di\image + Offst , 1, $4B )
            
            Offst + 256
        Next ExTrk                        
        ; ------------------------------------------------------------------- /* get ptr To bam */
        *p = get_ts_addr(*di, *di\bam)  
        
        ; ------------------------------------------------------------------- /* setup header */ and /* set id */
        *p\c[0] = $28
        *p\c[1] = $02
        *p\c[2] = $44
        *p\c[3] = $BB
        *p\c[4] = *rawid\c[0]
        *p\c[5] = *rawid\c[1]              
        *p\c[6] = $c0            
        ; ------------------------------------------------------------------- /* clear bam */                            
        FillMemory( *p + 7, $fa, 0) 
        
        ; ------------------------------------------------------------------- /* get ptr To bam2 */
        *p = get_ts_addr(*di, *di\bam2)             
        
        ; ------------------------------------------------------------------- /* setup header */ and /* set id */ Bam 2
        *p\c[0] = $00
        *p\c[1] = $ff
        *p\c[2] = $44
        *p\c[3] = $bb
        *p\c[4] = *rawid\c[0]
        *p\c[5] = *rawid\c[1]                
        *p\c[6] = $c0              
        
        ; ------------------------------------------------------------------- /* clear bam */                            
        FillMemory( *p + 7, $fa, 0)               
        
        ; ------------------------------------------------------------------- /* free blocks */              
        tsTrack = 0
        tsSectr = 0
        
        For tsTrack = 1 To di_tracks(*di)
            ts\track = tsTrack
            For tsSectr = 0 To di_sectors_per_track(*di, ts\track) -1
                ts\sector = tsSectr   
                di_free_ts(*di, @ts)                                              
            Next tsSectr                  
        Next tsTrack                
        
        ; ------------------------------------------------------------------- /* allocate bam And dir */
        ts\track = 40
        ts\sector = 0
        di_alloc_ts(*di, @ts)
        ts\sector = 1
        di_alloc_ts(*di, @ts)
        ts\sector = 2
        di_alloc_ts(*di, @ts)
        ts\sector = 3
        di_alloc_ts(*di, @ts)
        
        ; ------------------------------------------------------------------- /* get ptr To dir */
        *p = get_ts_addr(*di, *di\dir)
        
        ; ------------------------------------------------------------------- /* copy name */              
        *p\c[0] = $28
        *p\c[1] = $03
        *p\c[2] = $44              
        
        FillMemory( *p + 4, 16, $a0)
        x = 0
        For i = 0 To 15
            c.a = *rawname\c[i]
            If c ! 0
                x + 1
            EndIf
        Next i    
        
        CopyMemory( *rawname, *p + 4, x)              
        
        ; ------------------------------------------------------------------- /* set id */
        FillMemory( *p + $14, 2, $a0)
        If (*rawid)                   
            CopyMemory( *rawid, *p + $16, 2)                                    ; Copy ID the Directory name
        EndIf
        
        FillMemory(*p + $18, 5, $a0);
        *p\c[$19] = '3'
        *p\c[$1A] = 'D'
        
        ; ------------------------------------------------------------------- /* clear unused bytes */
        FillMemory(*p + $1D, $E3, 0);              
        
        ; ------------------------------------------------------------------- /* clear first dir block */
        FillMemory(*p + 768, 256, 0);
        *p\c[769] = $ff   
                
                
    EndProcedure        
  ; -----------------------------------------------------------------------------------------------------------------------------------------
    ;-- New T64 Image
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure di_format_t64(*di.DiskImage, *rawname.Rawname, *rawid.Rawname, ImageSize.q = 0)
        
        Define *p.offset      
        
        ; ------------------------------------------------------------------- /* erase disk */
        FillMemory( *di\image, ImageSize, $00)                            
        *p = *di\image
        ; ------------------------------------------------------------------- /* setup header */
        *p\c[0] = 'C'
        *p\c[1] = '6'
        *p\c[2] = '4'
        *p\c[3] = 'S'
        *p\c[4] = $20
        *p\c[5] = 't'
        *p\c[6] = 'a'
        *p\c[7] = 'p'        
        *p\c[8] = 'e'        
        *p\c[9] = $20        
        *p\c[10] = 'i'
        *p\c[11] = 'm'
        *p\c[12] = 'a'
        *p\c[13] = 'g'        
        *p\c[14] = 'e'        
        *p\c[15] = $20
        *p\c[16] = 'f'        
        *p\c[17] = 'i'        
        *p\c[18] = 'l'       
        *p\c[19] = 'e'
        *p\c[20] = $00         
        ; ------------------------------------------------------------------- /* Tape Version */          
        *p = *di\image + $20
        *p\c[0] = $00
        *p\c[1] = $01        
        
        ; ------------------------------------------------------------------- /* copy name */              
        
        *p = *di\image + $28          
        
        FillMemory( *p , $18, $20)
        x = 0
        For i = 0 To 15
            c.a = *rawname\c[i]
            If c ! 0
                x + 1
            EndIf
        Next i    
        
        CopyMemory( *rawname, *p, x)                                               
    EndProcedure            
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; /* Create Image (Format) */  Format matched with c1541.exe and the Source for D64, D71 and D81 Format Description
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.i di_format(*di.DiskImage, *rawname.Rawname, *rawid.Rawname, ImageSize.q = 0, DosType.i = 0)
                      
        *di\modified = 1
        Select *di\Type
            Case "D64"
                ;
                ; FIXME: Tracks 41+42
                ; Support Extended Tracks and Sector Error Info
                di_format_d64(*di, *rawname, *rawid, ImageSize, DosType)
                
            Case "D71": di_format_d71(*di, *rawname, *rawid, ImageSize)
            Case "D81": di_format_d81(*di, *rawname, *rawid, ImageSize) 
            Case "T64": di_format_t64(*di, *rawname, *rawid, ImageSize)    
        EndSelect
        
        *di\blocksfree = blocks_free(*di)
        
        set_status(*di, 0, 0, 0)
        
        ProcedureReturn *di        
    EndProcedure       
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Debug Test and Show BAM
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure.s debug_load_bam(*di.DiskImage)
        
        Protected FreeSector.i, FullBamLstings$ = "", S$
        
        
        S$ = "TRACK" +#TAB$+ "FREE/ DEFAULT"+#TAB$+"(SECT.IN)"+#TAB$+"MAP > BAM OVERVIEW ([ ]: FREE/ [*]:FULL)" + #CRLF$
        S$ + "     " +#TAB$+ "             "+#TAB$+"         "+#TAB$+"| 0| 1| 2| 3| 4| 5| 6| 7| 8| 9|10|11|12|13|14|15|16|17|18|19|20|" + #CRLF$        
        FullBamLstings$ + S$
        FullBamErrosCodes$ = ""
        
        Static ts.TrackSector
        
        Select *di\Type
                Case "D64", "D71", "D81"
                    CurrenTrack = ts\track
                    CurrenSectr = ts\sector
                    
                    For CurrenTrack = 1 To di_tracks( *di )           
                        ts\track   = CurrenTrack   
                        free.i =  di_track_blocks_free(*di, CurrenTrack)        ; Get Free Blocks From Current Track
                        
                        Free$ = ""
                        Blocks.i = di_get_block_num(*di, @ts, #True)            ; Get Max Blocks from Current Track
                        Sector.i = di_sectors_per_track(*di, CurrenTrack)       ; Get Max Sector from Current Track
                        
                        
                        For CurrenSectr = 0 To Sector-1
                            ts\sector  = CurrenSectr
                            
                            FreeSector = di_is_ts_free(*di, @ts)                ; Is Current Sector Free ? 0 (used) / Free
                            
                            eCode = di_error_codes(*di, @ts)               
                            If eCode >= 20
                                FreeSector = eCode
                                Free$ + "|"+Str(eCode)
                                FullBamErrosCodes$ + "Error ["+ Str(eCode)+ "] Found  on Track "+RSet( Str(CurrenTrack),2,"0")+"/Sector "+RSet( Str(CurrenSectr),2,"0")+" :"+ di_error_codes_desc(eCode) +#CRLF$
                            Else
                                Select FreeSector                                              
                                    Case 0                                                  
                                        Free$ + "| *"                          
                                    Default
                                        Free$ + "| -"                        
                                EndSelect
                            EndIf
                        Next
                        ts\track = 0
                        ts\sector = 0
                        Free$ + "|"
                        
                        S$ = " "+RSet( Str(CurrenTrack),2,"0") + ":  "+#TAB$+ RSet( Str(free),2,"0")+" / "+Str(CurrenSectr)+#TAB$+" ( "+RSet(Str(Blocks),4,"0")+" )" +#TAB$+ Free$ +#CRLF$
                        
                        FullBamLstings$ + S$
                        
                        
                    Next
                    If ( FullBamErrosCodes$ = "")
                        FullBamErrosCodes$ = "No Errors Found :)"
                    EndIf
                Case "T64" 
                    
                    ResetList( *di\Tape\Records() )
                    *CassSide.SectorBlock = AllocateMemory(254)
                    
                    CurrenTrack.i = 0
                    DirEntryIdx.b = $20                   
                    
                    For FileIndex = 0 To ListSize( *di\Tape\Records() ) -1
                        
                        ByteIndex.i  = 0
                        ByteTotal.q  = 0
                        BegAddress.l = 0
                        EndAddress.l = 0
                        CurrentBlock.i=0
                        free          =0
                        SelectElement( *di\Tape\Records(), FileIndex)                         
                        CopyMemory(*di\image + $40 + DirEntryIdx, *CassSide, $20)
                        
                        For ByteIndex = 0 To MemorySize(*CassSide) -1
                            
                            If *CassSide\c[ByteIndex] > 1    
                                CurrenTrack = FileIndex                                
                            EndIf                                                                                       
                        Next
                        
                        If ( CurrenTrack = FileIndex )
                            
                            BegAddress= *di\Tape\Records()\Offset
                            ByteTotal = *di\Tape\Records()\EndAddr - *di\Tape\Records()\StartAddr
                            
                            While ByteTotal
                                
                                If ( ByteTotal <= 254 )
                                    BegAddress - 254
                                    BegAddress + ByteTotal
                                    ByteTotal  = 0
                                EndIf
                                
                                CopyMemory(*di\image + BegAddress, *CassSide, 254)                                
                                                                
                                For ByteIndex = 0 To MemorySize(*CassSide) -1
                                    If *CassSide\c[ByteIndex] > 1    
                                        CurrentBlock +1                          
                                    EndIf                                 
                                Next    
                                
                                If CurrentBlock > 1
                                    free        + 1 
                                    CurrenSectr + 1
                                    
                                    If CurrenSectr = 1
                                        Description$ = "Directory Entry: " + PeekS(*di\image + $28, 16, #PB_Ascii)
                                    Else
                                        Description$ = PeekS( *di\Tape\Records()\Filename,16,#PB_Ascii )
                                    EndIf    
                                    S$ + " "+RSet( Str(CurrenTrack),2,"0") + ":  "+#TAB$+ RSet( Str(CurrenSectr),2,"0")+" / "+RSet( Str(CurrenSectr),2,"0")+#TAB$+" ( "+RSet(Str(free),4,"0")+" )" +#TAB$+ "| *| : "+#TAB$ +Description$ + #CRLF$
                                EndIf    
                                
                                If ( ByteTotal = 0 )
                                    Break 1
                                EndIf
                                BegAddress + 254
                                ByteTotal  - 254
                            Wend
                        EndIf  
                    Next    
                    FullBamLstings$ = S$
                    
                    If ( *di\Tape\Fixes >= 1 )
                        
                        ResetList( *di\Tape\FixesDescriptions() )
                        FullBamErrosCodes$ = "Erros Found. Need Fixes" +#CRLF$
                        While NextElement( *di\Tape\FixesDescriptions() )
                            FullBamErrosCodes$ + *di\Tape\FixesDescriptions() + #CRLF$
                        Wend
                    Else
                        FullBamErrosCodes$ = "No Errors Found - No Fixes Needed :)"                        
                    EndIf
                    
        EndSelect            
        FullBamLstings$ + #CRLF$ + FullBamErrosCodes$ + #CRLF$
        ProcedureReturn FullBamLstings$        
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Return Disk Image Format
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.s di_get_FormatImage(*di.DiskImage)        
        If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
            ProcedureReturn ""
        EndIf        
        ProcedureReturn *di\Type        
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Return Disk Filename
    ; -----------------------------------------------------------------------------------------------------------------------------------------      
    Procedure.s di_get_Filename(*di.DiskImage, Fullpath.i = #False)
        
        If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
            ProcedureReturn ""
        EndIf        
        Select Fullpath
            Case #False
                ProcedureReturn *di\dateiname
            Case #True
                ProcedureReturn *di\dateipath + *di\dateiname
        EndSelect           
    EndProcedure         
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Return Free Blocks Of the C64 Disk Image
    ; -----------------------------------------------------------------------------------------------------------------------------------------       
    Procedure.i di_sho_FreeBlocks(*di.DiskImage)
        
        If ( *di = 0 )
            ProcedureReturn 0
        ElseIf  ( *di = -1 )
            ProcedureReturn -1
        ElseIf  ( *di = -2 )           
            ProcedureReturn -2
        EndIf 
        
        ProcedureReturn *di\blocksfree
    EndProcedure         
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Get C64 Disk Image Title
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s di_Get_TitleHead(*di.DiskImage)
        
        Protected TitleLenght.i = 0, Title.s = "", *name.char
        
        If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
            ProcedureReturn ""
        EndIf
        
        *name  = AllocateMemory(16)
        
        Select *di\Type
                Case "D64", "D71", "D81"
                    Select *di\DiskDOS\Type
                        Case "2P"
                            TitleLenght.i = di_name_from_rawname(*name.char, di_title(*di)+20 )   
                        Default           
                            TitleLenght.i = di_name_from_rawname(*name.char, di_title(*di) )               
                    EndSelect
                Case "T64"  
                    TitleLenght.i = di_name_from_rawname(*name.char, *di\image + $28 ) 
                    
        EndSelect            
        
        Title.s = PeekS(*name, TitleLenght ,#PB_Ascii )        
        ProcedureReturn Title.s
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Get C64 Disk Image ID
    ; -----------------------------------------------------------------------------------------------------------------------------------------      
    Procedure.s di_Get_Title_ID(*di.DiskImage)        
        Protected ident.s = ""        
        If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
            ProcedureReturn ""
        EndIf        
        ident.s = *di\DiskDOS\Ident + " " + *di\DiskDOS\Type        
        ProcedureReturn ident.s       
    EndProcedure       
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.s di_get_GeosFormat(*di.DiskImage)
        
        Protected GeosLenght.i = 0, GEOS.s = "", *GEOS.char
        
        If ( *di = 0 ) Or ( *di = -1 ) Or ( *di = -2 )
            ProcedureReturn ""
        EndIf
        
        *GEOS  = AllocateMemory(16)
        
        Select *di\Type
            Case "D64", "D71", "D81"
                
                di_name_from_rawname(*GEOS.char, di_title(*di)+29) 
                
                GEOS.s = PeekS(*GEOS, 16 ,#PB_Ascii )
                
                If UCase( GEOS ) = "GEOS FORMAT V1.0"
                    ProcedureReturn "Geos Format v1.0"
                EndIf
                ProcedureReturn ""
                
            Case "T64"
                ProcedureReturn ""
        EndSelect        
        
        ProcedureReturn ""
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i C_Sub_Prepare(FN$, CopyTo$ ,DIR$, PT$)        
        
        If ( Len(FN$) = 0 )
            SetError( "No C64 Filename Selected")
            ProcedureReturn -1
        EndIf            
        
        Select CopyTo$
            Case "HD"
            Case "DS"
                If ( FileSize(DIR$ + FN$ + "." +PT$) = -1 )
                    CBMDiskImage::*er\s = "File "+ Chr(34) + FN$ + "." +PT$ + Chr(34) + " Not Found"
                    ProcedureReturn -1
                EndIf
            Default
                CBMDiskImage::*er\s = "Error On Copy Command"
                ProcedureReturn -1
        EndSelect         
        ProcedureReturn 0
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i C_Sub_ReadBytes(*fi.ImageFile)
        
        Protected *buffer.CharBuffer, Bytes.i
        
        *buffer   = AllocateMemory(1048576)                                                           ; For a single file, it should be big enough
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.s C_Sub_SavePattern(*di.DiskImage, DIR$, FN$, SaveAs$, Container.i)   
        
        Protected  SF$, Pattern$                
        
        If ( SaveAs$ = "" )        
        Else
            FN$ = SaveAs$
        EndIf                            
        ProcedureReturn FN$                   
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i C_Sub_SaveBytes(*buffer.offset, SaveAs$, Lenght.i)
        
        Protected  bytes.i, Result.i
        
        Result  = CheckFilename(SaveAs$)
        If Result ! 0 
            SetError("Could'nt Write as "+Chr(32)+SaveAs$+Chr(32) + ". Error: "+ Str(Result))                
        EndIf 
        
        If ( Len( SaveAs$ ) = 0 )
            SetError("No file name specified")  
        EndIf
        
        If FileSize( GetPathPart(SaveAs$) ) ! -2
            SetError("No Directory specified")  
        EndIf 
        
        Define SaveFile = CreateFile( #PB_Any, SaveAs$ )               
        
        If ( SaveFile )
            bytes = WriteData(SaveFile, *Buffer, Lenght)
            
            CloseFile(SaveFile)              
            
            If ( bytes = Lenght)  And ( FileSize(SaveAs$) = bytes )
                ProcedureReturn 0
            Else
                SetError("Could'nt write file")
            EndIf     
        EndIf  
        
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure.i C_Sub_MakePC64(*buffer.offset, FN$, SaveAs$, Lenght)
        
        Protected  PC64ByteSize.i, PC64FileLen.i, PC64ShiftUp$, *PC64BufferName.char ,*PC64BufferTotal.ByteArrayStructure
        
        If SaveAs$ <> ""
            FN$ = SaveAs$
            FN$ = GetFilePart(FN$,#PB_FileSystem_NoExtension)
            FN$ = ptou(FN$) 
        EndIf                    
        
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
    ; -----------------------------------------------------------------------------------------------------------------------------------------   
    Procedure.i C_Sub_ReadPC64_Name(DIR$, FN$, SaveAs$)      
        
        Structure header
            c.a[8]
        EndStructure 
        
        Structure filename
            c.a[16]
        EndStructure   
        
        Protected  *rawfile.filename, *header.header
        
        *rawfile  = AllocateMemory(16) 
        *header   = AllocateMemory(6) 
        
        PC64File.a = OpenFile( 0, DIR$ + FN$, #PB_File_SharedRead|#PB_File_SharedWrite)
        If ( PC64File )
            If ReadFile(PC64File, DIR$ + FN$, #PB_File_SharedRead|#PB_File_SharedWrite) 
                
                bytes = ReadData(PC64File, *header, 7)
                
                If ( PeekS(*header,8, #PB_Ascii) <> "C64File" )   
                    CloseFile( PC64File )
                    ProcedureReturn 0
                EndIf
                
                FileSeek( PC64File, 8 )
                
                If SaveAs$ = "" 
                    bytes = ReadData(PC64File, *rawfile, 16)
                Else
                    SaveAs$ = ptou_back(SaveAs$)  
                    PokeS(*rawfile, SaveAs$, 16, #PB_Ascii)
                EndIf    
                CloseFile( PC64File )
                ProcedureReturn *rawfile
            EndIf
        EndIf
        
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i C_Sub_Write_PC64(*imgfile.ImageFile, *di.DiskImage, DIR$, FN$)
        
        
        Protected PC64Size.q, *buffer.offset
        
        PC64Size.q      = FileSize(DIR$ + FN$) - 26
        *buffer         = AllocateMemory(PC64Size)
        
        PC64File.a = OpenFile( 0, DIR$ + FN$, #PB_File_SharedRead | #PB_File_SharedWrite)
        If ( PC64File )
            If ReadFile(PC64File, DIR$ + FN$, #PB_File_SharedRead| #PB_File_SharedWrite) 
                
                FileSeek( PC64File,  26)
                bytes = ReadData(PC64File, *buffer, PC64Size)
                
                If (di_write(*imgfile, *buffer, bytes ,*di) !bytes )
                    SetError("Could'nt Write File ("+FN$+") To Disk")
                EndIf                 
                
                CloseFile(WriteFile)
            Else
                SetError("Could'nt Open and Read File " + FN$)                
            EndIf
        EndIf   
        CloseFile( PC64File )
    EndProcedure 
    ; -----------------------------------------------------------------------------------------------------------------------------------------        
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
        CloseFile(WriteFile)
    EndProcedure    
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    Procedure.i C_Sub_ReadTpe64(*imgfile.ImageFile, *rawname.rawname, CopyTo$)
        
        Protected *Record.T64_Record, Match.i, Rec.i, *buffer.CharBuffer, Bytes.i 
              
        *buffer    = AllocateMemory(  1 )
        
        ResetList( *imgfile\diskimage\Tape\Records() )
        
        For Rec = 0 To *imgfile\diskimage\Tape\RecUse -1
            
            SelectElement( *imgfile\diskimage\Tape\Records(), Rec)                       
            *Record      = *imgfile\diskimage\Tape\Records()
            
            Match = match_pattern( *Record\Filename, *rawname.Rawname)                           
            If Match                            
               ; If ( *buffer )
                    Bytes =  *Record\EndAddr - *Record\StartAddr                                                                
                    ;If ( Bytes = *Record\Bytes )                        ; Check                                                                        
                        
                        ;
                        ; Adding 2 Bytes for the Start Adress
                        *buffer = ReAllocateMemory(*buffer, Bytes + 2)
                        ;
                        ; Adding the Start Adress ?
                        set_uint16(*buffer, *Record\StartAddr) 
                        
                        CopyMemory(  *imgfile\diskimage\image + *Record\Offset, *buffer +2, Bytes)
                        ProcedureReturn *buffer
                    ;EndIf    
                ;EndIf
            Else
                Continue
            EndIf                            
        Next        
    EndProcedure   
    ; -----------------------------------------------------------------------------------------------------------------------------------------     
    Procedure C_Sub_WriteTpe64(*imgfile.ImageFile, *di.DiskImage, *Rawname.Rawname, DIR$, FN$)
        
        Protected *TapeFile.offset, *dta.Offset, *NewEntry.TapDirEntry, *mve.TapDirEntry, *sOffset.Uint16, *NextStep.offset
        Protected Records.i, Highbyte.a, High.i
        
        *sOffset    = AllocateMemory(                        2 )   
        *SourceFile = AllocateMemory( FileSize( DIR$ + FN$ )-2 )        
        *NewEntry   = AllocateMemory(                      $20 )        
        
        Structure WriteTapeFile
            *cEntry.TapDirEntry
            *cData.offset
        EndStructure
        
        Dim Tape.WriteTapeFile(0)
        
        FillMemory( *NewEntry    ,$20, 0)                                   ; Filler ... Optionals 
        
        ;
        ; Adjust new Tape T64File       
        ;             |    Original Size    | + | The File Lenght     | + | New Directory Entry
        ;
        TapeSize   = *di\size + FileSize(  DIR$ + FN$ ) + $20
        *TapeFile   = AllocateMemory( TapeSize )
        
        If MemorySize( *TapeFile )
            
            Define FileID.a = OpenFile( 0, DIR$ + FN$, #PB_File_SharedRead|#PB_File_SharedWrite)
            
            If ( FileID )            
                Result = ReadFile( FileID, DIR$ + FN$, #PB_File_SharedRead|#PB_File_SharedWrite)
                If Result         
                    
                    FileSeek( FileID, 2)
                    Bytes = ReadData(FileID, *SourceFile, MemorySize( *SourceFile ) )                 
                    CloseFile( FileID )
                EndIf
                
            EndIf
            
            ;
            ; 
            If ( Bytes > 0 ) 
                
                ;
                ; ================================================================== Create New Tape, Header & Entrys            
                ;
                ;
                ; Header to *Tape
                CopyMemory( *di\image , *TapeFile, $40 )                
                
                ;
                ; Move Entrys
                
                ;
                ; Check for Null Tape
                TapeSize   - 2
                
                If ( PeekW(*imgfile\TapHeader\Rec_Max) = 0 )
                    
                    *mve   = *di\image + $40 + IndexCount * $20
                    ;
                    ; Check For the First Entry
                    If ( CompareMemory(*mve, *NewEntry, $20) ! 0 )
                        ;
                        ; Reduce the New File Size, Set Index Counter 0
                        IndexCount = 0
                        TapeSize   - (*di\size - $40)
                    EndIf   
                ElseIf ( PeekW(*imgfile\TapHeader\Rec_Max) = 400 )   
                    SetError("You can not add more than 400 entries in the directory.")
                    
                ElseIf ( PeekW(*imgfile\TapHeader\Rec_Max) > 0 )
                    
                    For IndexCount = 0 To  PeekW(*imgfile\TapHeader\Rec_Max)-1                      
                        
                        *mve   = *di\image + $40 + IndexCount * $20
                        
                        ReDim Tape.WriteTapeFile(IndexCount)
                        
                        DataLenght      = get_uint16( *mve\EndAddr) - get_uint16( *mve\StartAddr)
                        DataOffeset     = get_uint16( *mve\Container )
                        
                        *dta = AllocateMemory( DataLenght )
                        If MemorySize( *dta ) 
                            
                            MoveMemory( *di\image + DataOffeset, *dta , DataLenght )
                            
                            Tape(IndexCount)\cEntry = *mve
                            Tape(IndexCount)\cData  = *dta 
                        EndIf
                        
                    Next 
                EndIf                
                ;
                ; ================================================================== Add the New Entry and Data
                ;
                ;
                ;
                ; ========== Get the Actual End Adress, minus 2 Bytes from the Beginning of File $0108        
                T64_Calculate_End_Adress(*sOffset, 2049, MemorySize( *SourceFile ))
                
                ;
                ; ========== Setup FileTyp, Start & End Adress
                FillMemory( *NewEntry    ,  1, $01 )            ; Tape Filetype  
                FillMemory( *NewEntry + 1,  1, $82 )            ; 1541 Filetype
                FillMemory( *NewEntry + 2,  1, $01 )            ; Start Adress
                FillMemory( *NewEntry + 3,  1, $08 )            ; Start Adress  
                FillMemory( *NewEntry + 4,  1, *sOffset\c[0] )  ; End Adress                
                FillMemory( *NewEntry + 5,  1, *sOffset\c[1] )  ; End Adress                 
                
                ;
                ; ========== Setup Filename  
                CopyMemory( *Rawname, *NewEntry + 16, 16)        ; Rawname        
                
                ;
                ; ========== Copy the New Entry and Data to the Arry                

                ReDim Tape.WriteTapeFile(IndexCount)
                
                DataLen = 0
                Records = ArraySize( Tape() ) 
                
                Tape(Records)\cEntry = *NewEntry
                Tape(Records)\cData  = *SourceFile
                
                ;
                ; ================================================================== Create New Tape, New End Adress
                For IndexCount = 0 To Records
                    
                    ;
                    ; Kopiere die Einträge
                    CopyMemory( Tape(IndexCount)\cEntry, *TapeFile + $40 + IndexCount * $20, $20)                                               
                    
                    ;
                    ; Berechne die neue Endadresse, bei der 1.sten Datei fange wir mit 0 nun
                    ; da die Daten sofort nach dem letzten Tape eintrag beginnen             
                    Set_uint16( *sOffset , $40 + (Records+1) * $20 + DataLen)
                    
                    *NextStep = *TapeFile + $40 + IndexCount * $20
                    *NextStep + 8
                    Highbyte  = 0
                    FillMemory( *NextStep   ,  1, *sOffset\c[0] )  ; New Offset                
                    FillMemory( *NextStep +1,  1, *sOffset\c[1] )  ; New Offset
                    
                    If ( DataLen > 65535 )
                        For High = 65535 To DataLen Step 65535
                            Highbyte + 1
                        Next    
                        
                        Set_uint16( *sOffset , Highbyte)
                        
                        FillMemory( *NextStep +2,  1, *sOffset\c[0] )  ; New Offset                
                        FillMemory( *NextStep +3,  1, *sOffset\c[1] )  ; New Offset                        
                    EndIf    

                    ;
                    ; Gibt es weitere Datei Enträge ??
                    If ( IndexCount <= Records )
                        ;
                        ; Fortführend ab der 2. Datei
                        DataLen + MemorySize( Tape(IndexCount)\cData )
                    EndIf                               
                Next  
                ; ================================================================== Setup the New Tape                
                For IndexCount = 0 To Records
                    ;
                    ; Hole die Datenlänge
                    DataLen =  MemorySize( Tape(IndexCount)\cData )
                    ;
                    ; Kopiere die Daten Vom Jeweiligemn Datei Eintrag
                    CopyMemory( Tape(IndexCount)\cData, *TapeFile + $40 +  (Records +1) * $20 + nOffset, DataLen)                                               
                    ;
                    ; Gibt es weitere Datei Enträge ??                
                    If ( IndexCount <= Records )
                        ;
                        ; Die Datenlänge ist das Ende des neuen Offsets
                        nOffset + DataLen
                    EndIf                    
                Next                 
                

                ;
                ;
                ; Update the Size of Entrys
                FillMemory( *TapeFile + $22                ,  1, Records+1 ,#PB_Byte)
                FillMemory( *TapeFile + $24                ,  1, Records+1 ,#PB_Byte)  
                ;
                ; ================================================================== Ersetze das neue Abbild im Pointer
                FreeMemory( *di\image)
                
                *di\size  = TapeSize
                *di\image = AllocateMemory( TapeSize)
                
                CopyMemory( *TapeFile, *di\image, TapeSize)
  
                FreeMemory(*sOffset)                
                FreeMemory(*NewEntry)
                FreeMemory(*TapeFile)
                
                FreeArray( Tape.WriteTapeFile() )             
            EndIf 
        EndIf
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------         
    ; Info: Copy File
    ; ImageFile$: A D64, D71, D81 image with full path
    ; 
    ; For Copy To HD (Save File From Image to HD)
    ;   Dir$      : Destination Directory
    ;   FN$       : Source File On Image
    ;   CopyTo$   : HD (Argument for Copy to HD)
    ;   SaveAs$   ; Save with Different Path+FileName. If this Empty it save as Original Path+FileName
    ;   Container : 0 = Save as Default file like on Disk (PRG is PRG, SEQ is SEQ etc..)
    ;   Container : 1 = Save as PC64 like *p00 for PRG, *s00 for SEQ etc...
    ;   IsLock    : NOT USED (Only for Write to Image)
    ;   IsSplat   : NOT USED (Only for Write to Image)    
    ;
    ; For Copy to Image (Write a File to Image)
    ;   Dir$      : Source Directory
    ;   FN$       : Souce File
    ;   CopyTo$   : DS (Argument for Copy to Image)
    ;   SaveAs$   ; Write File as different name to the Image (Rename on the Fly)
    ;   Container : NOT USED (Only For Save File to HD)
    ;   IsLock    : Write file with Fileytpe Locked "<"
    ;   IsSplat   : Write file with Fileytpe Splat  "*"      
    ;   
    ; -----------------------------------------------------------------------------------------------------------------------------------------           
    Procedure.i C(ImageFile$ = "", DIR$ = "", FN$ = "", PT$ ="", CopyTo$ = "HD", SaveAs$ = "", Container.i = 0, IsLock.i = #False, IsSplat.i = #False)
        
        Protected *di.DiskImage, *fi.ImageFile, *out, Pattern.i, Mode$ = "",Result.i, WritePC64 = #False, OF$ = "", Blocks.i
        
        If ( C_Sub_Prepare(FN$, CopyTo$ ,DIR$, PT$) = -1 )
            ProcedureReturn -1
        EndIf 
        
        *cbmfile  = AllocateMemory(16)   
        *rawfile  = AllocateMemory(16)
                
        OF$ = FN$
        
        
        ; Extract P00 Name
        Pattern =  Filetype_GetP00(PT$)
        If ( Pattern >= 0 ) And ( CopyTo$ = "DS" )
            *cbmfile = C_Sub_ReadPC64_Name(DIR$, FN$+"."+PT$, SaveAs$)
            If ( *cbmfile ! 0 )
                WritePC64 = #True
            Else
                *cbmfile  = AllocateMemory(16)  
            EndIf    
        EndIf
        
        If ( WritePC64 = #False )
            Pattern.i = Filetype_Set(PT$)
            If ( Pattern = -1 )
                ; Unknown Filetype, Convert them
                Pattern = Filetype_Convert(PT$)
            EndIf            
            If ( CopyTo$ = "DS" )                
                If SaveAs$ <> ""
                    FN$ = SaveAs$
                EndIf                                     
            EndIf 
            
            PokeS( *cbmfile, FN$, 16, #PB_Ascii ) 
            WritePC64 = #False            
        EndIf
                
        Select CopyTo$
            Case "HD":Mode$ = "rb"               
            Case "DS":Mode$ = "wb": 
        EndSelect        
        
        *di = di_load_image(ImageFile$)
        If ( *di = -1 )
            If ( CBMDiskImage::*er\s = "")
                SetError("Couldn't Load Disk Image: " + DiskImage$)
            EndIf  
        EndIf         

        Select *di\Type            
            Case "D64", "D71", "D81"                   
                ;
                ; Disk Dateinamen sind mit $a0 (160) aufgefüllt                
                Base_Setup_RawName(*cbmfile, *rawfile, $a0, 16)                    
               
            Case "T64"
                ;
                ; Tape Dateinamen sind mit $20 (32) aufgefüllt                 
                Base_Setup_RawName(*cbmfile, *rawfile, $20, 16)
        EndSelect            
                      
        *fi = di_open(*di, *rawfile, Pattern ,Mode$)
        If ( *fi = 0 )                     
            di_free_image(*di) 
            ProcedureReturn -1
        EndIf        
        
        Select *di\Type
                ;
                ;
            Case "D64", "D71", "D81"
                If ( CopyTo$ = "DS" )
                    If      ( IsSplat = #True ) And ( IsLock = #True ) 
                        *di\ExtraType = 3
                    ElseIf  ( IsSplat = #True ) And ( IsLock = #False)
                        *di\ExtraType = 2
                    ElseIf  ( IsSplat = #False) And ( IsLock = #True )
                        *di\ExtraType = 1
                    Else
                        *di\ExtraType = 0
                    EndIf         
                    
                    ; Check Free Space (Blocks) on Disk for File before Write
                    Blocks = di_bytes_to_blocks(*di, DIR$ + OF$+"."+PT$)
                    If Blocks>=1
                        di_close(*fi): di_free_image(*di): FreeMemory(*cbmfile): 
                        FreeMemory(*rawfile)   
                        
                        SetError("Not Enough Space To Write ("+Chr(32)+OF$+Chr(32)+") To Disk. It required " + Str(Blocks) + " More Blocks")
                    EndIf
                EndIf
                ;
                ;
            Case "T64"
                ;
                ; Tape Readings
                T64_Allocte_and_Read_Records(*fi)
                ;T64_Verify_Size_and_Offsets(*fi) 
        EndSelect      
 
        Select CopyTo$
                ;
                ; Read, Create and Save File From Image to HD
            Case "HD":
                
                Select *di\Type
                    Case "D64", "D71", "D81"                        
                        *out = C_Sub_ReadBytes(*fi)
                        
                    Case "T64"
                        *out = C_Sub_ReadTpe64( *fi , *rawfile, CopyTo$)
                EndSelect
                
                
                If (*out = -1) 
                    di_free_image(*di) 
                    ProcedureReturn -1
                EndIf              
                
                If ( Container = 1)         
                    *out = C_Sub_MakePC64(*out, FN$, SaveAs$, MemorySize(*out))
                    If ( *out = 0 )
                        ProcedureReturn -1
                    EndIf    
                EndIf
              
                SaveAs$ = C_Sub_SavePattern(*di.DiskImage, DIR$, FN$+"."+PT$, SaveAs$, Container.i) 
                
                di_close(*fi): di_free_image(*di): FreeMemory(*cbmfile): 
                FreeMemory(*rawfile)                                  
                
                If ( C_Sub_SaveBytes( *out, SaveAs$, MemorySize(*out) ) = -1)
                    FreeMemory(*out) 
                    ProcedureReturn -1
                EndIf 
                FreeMemory(*out) 
                ;
                ; Write File to C64 Disk Image
            Case "DS":                                
                
                Select *di\Type
                    Case "D64", "D71", "D81"                 
                        FreeMemory(*cbmfile): FreeMemory(*rawfile)  
                        
                        If ( WritePC64 = #True )
                            If ( C_Sub_Write_PC64(*fi, *di, DIR$, OF$+"."+PT$) = -1)
                                di_close(*fi): di_free_image(*di): ProcedureReturn -1
                            EndIf
                        Else                           
                            If ( C_Sub_WriteBytes(*fi, *di, DIR$, OF$+"."+PT$) = -1)
                                di_close(*fi): di_free_image(*di): ProcedureReturn -1
                            EndIf
                        EndIf
                         Filetype_ModfiyType(*di,*fi, Pattern)
                    Case "T64"
                        C_Sub_WriteTpe64(*fi, *di, *rawfile, DIR$, OF$+"."+PT$)
                EndSelect        
                               
                di_close(*fi): di_free_image(*di)                
        EndSelect                              
        ProcedureReturn 0
    EndProcedure    
    ; ----------------------------------------------------------------------------------------------------------------------------------------- 
    ; Info: Rename File    
    ; ImageFile$: A D64, D71, D81 image with full path
    ; afn$      : Old Name from File on Disk
    ; nfn$      : New Name for File on Disk 
    ; apn$      : The Old Pattern
    ; npn$      : The New Pattern (Optional)
    ; -----------------------------------------------------------------------------------------------------------------------------------------    
    Procedure.i R(ImageFile$ = "", afn$="", nfn$="",apn$ = "", npn$ = "")
        
        Protected *di.Diskimage,  *img.ImageFile, *ren.Rawdirentry, *afn.Rawname, *nfn.Rawname, Pattern$, FileType.i
        
        *di = di_load_image(ImageFile$)
        If ( *di = -1 )
            If ( CBMDiskImage::*er\s = "")
                SetError("Couldn't Load Disk Image: " + DiskImage$)
            EndIf  
        EndIf   
        
        *afn  = AllocateMemory(16)   
        *nfn  = AllocateMemory(16)          
        
        FileType_Source = Filetype_Set(apn$)
        If ( FileType_Source = -1 )
            SetError("Argument Error. Please Set Filetype")
        EndIf
        
        PokeS(*afn, afn$, 16, #PB_Ascii)
        PokeS(*nfn, nfn$, 16, #PB_Ascii)
        
       
        
        Select *di\Type
            Case "D64", "D71", "D81"
                
                Ascii_2_Petscii_Convert_Zero(*afn)
                Ascii_2_Petscii_Convert_Zero(*nfn) 
                
                *ren = find_file_entry(*di, *afn, FileType_Source)
                If ( *ren = 0 )
                    set_status(*di, 62, 0, 0);
                    ProcedureReturn -1
                EndIf 
                            
                CopyMemory(*nfn, *ren\rawname,16) 
                
                set_status(*di, 0, 0, 0);

            Case "T64"
                Ascii_2_Petscii_Convert_Zero(*afn, #True)
                Ascii_2_Petscii_Convert_Zero(*nfn, #True)
                
                *ren = T64_FindFile_Entry(*di, *afn, *nfn, FileType_Source, "RENAME")
                If ( *ren = 0 )
                    ProcedureReturn -1
                EndIf 
                
        EndSelect
        
        *di\modified = 1
        
        *img = di_open(*di, *nfn, FileType_Source ,"rb")
        If ( *img = 0 )            
               ProcedureReturn -1
        EndIf   
        
        FileType_Dest = Filetype_Set(npn$)        
        If ( FileType_Dest = -1 )
             FileType_Dest = FileType_Source
        EndIf
        
        If ( Right( npn$ ,1 ) = "<" )
            *di\ExtraType + 1
        EndIf
        
        If ( Left( npn$  ,1 ) = "*" )  
            *di\ExtraType + 2
        EndIf        
        
        Filetype_ModfiyType(*di,*img, FileType_Dest)        
              
        di_close(*img)
        
        di_free_image(*di)
        
    EndProcedure
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Info: Rename Disk Title
    ; ImageFile$: A D64, D71, D81 image with full path
    ; tn$       : New Title Name for Disk
    ; -----------------------------------------------------------------------------------------------------------------------------------------          
    Procedure T(ImageFile$ = "", tn$="")
        Protected  *di.Diskimage, *of.offset
        
        *di = di_load_image(ImageFile$)
        If ( *di = -1 )
            If ( CBMDiskImage::*er\s = "")
                SetError("Couldn't Load Disk Image: " + DiskImage$)
            EndIf  
        EndIf   
        
        *tn  = AllocateMemory(16)  
        *of  = AllocateMemory(16) 

        Select *di\Type
            Case "D64", "D71", "D81"    
                
                PokeS(*tn, tn$, 16, #PB_Ascii)
                
                Ascii_2_Petscii_Convert_Zero(*tn)
                
                Select *di\DiskDOS\Type
                    Case "2P"
                        *of = di_title(*di)+20   
                    Default           
                        *of = di_title(*di)               
                EndSelect  
                
            Case "T64"
                Ascii_2_Petscii_Convert_Zero(*tn, #True)
                
                PokeS(*tn, tn$, 16, #PB_Ascii)
                *of = *di\image + $28                               
        EndSelect 
        
        *di\modified = 1
        CopyMemory(*tn,*of,16)
        
        di_free_image(*di)         
    EndProcedure  
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Info: Scratch File
    ; ImageFile$: A D64, D71, D81 image with full path
    ; tn$       : File to Delete
    ; -----------------------------------------------------------------------------------------------------------------------------------------          
    Procedure S(ImageFile$ = "", sn$="",  sp$="")    
        
        Protected *di.DiskImage, *scr.Rawdirentry, delcount.i = 0, *sfn.char
        
        *di = di_load_image(ImageFile$)
        If ( *di = -1 )
            If ( CBMDiskImage::*er\s = "")
                SetError("Couldn't Load Disk Image: " + DiskImage$)
            EndIf  
        EndIf          
        
        ; --------------------------------------------------------------------; Get File Type
        FileType_Source = Filetype_Set(sp$)
        If ( FileType_Source = -1 )
            set_status(*di, 64, 0, 0)
            ProcedureReturn -1
        EndIf        
        
        ; --------------------------------------------------------------------; Find File
        *sfn  = AllocateMemory(16)           
        PokeS(*sfn, sn$, 16, #PB_Ascii)
        
        Select *di\Type
            Case "D64", "D71", "D81"
                Ascii_2_Petscii_Convert_Zero(*sfn)
                
                *scr = find_file_entry(*di, *sfn, FileType_Source)                
                If ( *scr = 0)
                    set_status(*di, 62, 0, 0)
                    ProcedureReturn -1
                EndIf    
                
                ; --------------------------------------------------------------------; Delete File Content
                free_chain(*di, *scr\startts)
                
                ; --------------------------------------------------------------------; Delete File Infos in the Entry Directory, Fill Contents
                
                                              ; 00-01: Track/Sector location of Next directory sector
                                              ; $00 If Not the first entry IN the sector
                FillMemory(*scr +$02, 1,$00)  ;    02: File type. 
                                              ; 03-04: Track/sector location of first sector of file
                FillMemory(*scr +$05,16,$00)  ; 05-14: 16 character filename (in PETASCII, padded with $A0)
                                              ; 15-16: Track/Sector location of first side-sector block (REL file only)
                                              ;    17: REL file record length (REL file only, max. value 254)
                                              ; 18-1D: Unused (except with GEOS disks)          
                FillMemory(*scr +$1E, 1,$00)  ; 1E-1F: File size IN sectors, low/high byte  order  ($1E+$1F*256).       
                FillMemory(*scr +$1F, 1,$00)  ; 1E-1F: File size IN sectors, low/high byte  order  ($1E+$1F*256).                
            Case "T64"
                
                Ascii_2_Petscii_Convert_Zero(*sfn, #True)
                
                *ren = T64_FindFile_Entry(*di, *sfn, 0, FileType_Source, "SCRATCH")
                If ( *ren = 0 )
                    ProcedureReturn -1
                EndIf                 
        EndSelect
                
        *di\modified    = 1
        
        set_status(*di, 1, 1, 0)
        
        di_free_image(*di)
        
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
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
    ;
    ; Info: 40 Tracks not standard and the extended BAM is different from DosType 0 and 2
    ; -----------------------------------------------------------------------------------------------------------------------------------------       
    Procedure.i N(ImageFile$ = "", Format$ = "D64", Title$ = "testdisk", DiskID$ = "id", ExTracks.i = 0, DOSType.i = 0)
        
        Protected ImageSize.q, *Title.char, *Buffer.char, *id.CharID, FileName$, *di.DiskImage, *er.LastError
        
        If (ImageFile$ = "")
            CBMDiskImage::*er\s = "No path and file name selected"
            ProcedureReturn -1
        EndIf                        
        
        If ( ExTracks >= 4 )
            CBMDiskImage::*er\s = "Error on Extended Tracks Command (Max Value: 3)"
            ProcedureReturn -1
        EndIf
        
        If ( DOSType >= 3 )
            CBMDiskImage::*er\s = "Error on Dos Type Command (Max Value: 2)"
            ProcedureReturn -1
        EndIf
        
        Select Format$
            Case "D64"                    
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
                ImageFile$+".D64"
                
            Case "D71":
                If ( ExTracks >= 2)
                    CBMDiskImage::*er\s = "False Disk Format for "+Format$
                    ProcedureReturn  -1
                EndIf                     
                Select ExTracks   
                        
                    Case 0: ImageSize = 349696  ; Standard
                    Case 1: ImageSize = 351062  ; Standard + Sector Error Info                          
                EndSelect        
                ImageFile$+".D71"
                
            Case "D81"
                If ( ExTracks >= 1)
                    CBMDiskImage::*er\s = "False Disk Format for "+Format$
                    ProcedureReturn  -1
                EndIf  
                Select ExTracks                   
                    Case 0: ImageSize = 819200  ; Standard
                    Case 1: ImageSize = 822400  ; Standard + Sector Error Info                 
                EndSelect                        
                
                ImageFile$+".D81"
            Case "T64"
                If ( ExTracks >= 1)
                    CBMDiskImage::*er\s = "False Disk Format for "+Format$
                    ProcedureReturn  -1
                EndIf  
                ImageFile$+".T64"
            Default
                CBMDiskImage::*er\s = "Pattern: " + Format$ + " is not supportet"
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
        
        atop( *Title)            
        
        di_rawname_from_name( *Buffer, *Title)        ; /* Convert title */ 
        
        Select Format$
            Case "D64", "D71", "D81" 
                If (DiskID$)
                    PokeS(*id, DiskID$, 2, #PB_Ascii)
                Else 
                    PokeS(*id, "id", 2, #PB_Ascii)
                EndIf  
                atop( *id) 
            Case "T64"
        EndSelect        
        

        di_format(*di, *Buffer, *id, ImageSize, DOSType);
        
        di_free_image(*di);
        
        FreeMemory(*id): FreeMemory(*Title): FreeMemory(*Buffer): CBMDiskImage::*er\s = ""
        ProcedureReturn 0
    EndProcedure         
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Info: Verify
    ; ImageFile$      : A D64, D71, D81 image with full path
    ; FixImage        : Save Fixes to the Current Image
    ; ReportOnlyErrors: Get the Number Of Errors/Fixes
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.i V(ImageFile$, FixImage = #False, ReportOnlyErrors = #False)
        
        Protected *di.Diskimage, *imgfile.ImageFile, Report$, ErrorCount.i, Found.i, Tracks.i, Track.i, Sectors.i, Sector.i
        Protected *Sector.BSect, *Track.BTrck, DiskReport$
        
        *di = di_load_image(ImageFile$)
        If ( *di = -1 )
            If ( CBMDiskImage::*er\s = "")
                SetError("Couldn't Load Disk Image: " + DiskImage$)
            EndIf  
        EndIf          
        
        Select *di\Type
            Case "D64", "D71", "D81"        
            Case "T64"    
                *di\Tape\Fixit = FixImage
        EndSelect        
        
        *imgfile = di_open(*di, '$', 2 ,"rb")
        If ( *imgfile = 0 )
            SetError( "Couldn't open directory for Disk Image: " + DiskImage$ )
        EndIf          
        
        Select *di\Type
            Case "D64", "D71", "D81"
                                                            
                Tracks = ListSize( BAM() )
                For Track = 0 To Tracks-1
                    
                    ResetList( BAM() ): SelectElement( BAM(), Track)

                    *Track = BAM()\Track()                    
                    If *Track
                        
                        ResetList( *Track\Sector() )
                        
                        For Sector = 0 To *Track\MaxSector -1
                            SelectElement( *Track\Sector(), Sector): *Sector = *Track\Sector()
                            If *Sector\ErrorCode ! 0
                                Found + 1
                                DiskReport$ + "Track " + Base_RSet_Int(Track+1) + "/ Sector " + Base_RSet_Int(Sector)  + ", Code " + Str( *Sector\ErrorCode ) + ": " + *Sector\ErrorDesc + #CRLF$
                            EndIf    
                        Next
                    EndIf                                                             
                Next
                
                If ReportOnlyErrors = #True
                    Report$ = Str(Found) 
                Else
                    Select FixImage
                            
                        Case #True
                            If ( Found > 0 )
                            Else
                                Report$         = Str(Found) +" Erros Found. Nothing to do...."  
                            EndIf  
                            
                        Case #False
                            If ( Found > 0 ) 
                                Report$         = Str( Found ) +" Erros Found. Disk Status Bad" + #CRLF$
                                Report$ + DiskReport$
                            Else
                                Report$         = "No Erros Reportet. Disk Status Good"
                            EndIf 
                    EndSelect
                EndIf
                
            Case "T64"  
                
                T64_Allocte_and_Read_Records(*imgfile)
                T64_Verify_Size_and_Offsets(*imgfile)
                
                Found = *imgfile\diskimage\Tape\Fixes 
                If ReportOnlyErrors = #True
                    Report$ = Str(Found) 
                Else    
                    
                    Select FixImage
                        Case #True
                            If ( Found > 0 )
                                *di\modified  = 1 
                                *di\image     = *imgfile\diskimage\image
                                Report$       = Str(Found) +" Erros Fixed."
                            Else
                                Report$       = Str(Found) +" Erros Found. Nothing to do...."  
                            EndIf    
                        Case #False
                            
                            If ( Found > 0 )                          
                                ErrorCount = 0
                                Report$    = Str( Found ) +" Erros Found. Tape Status Bad" + #CRLF$
                                
                                ResetList( *imgfile\diskimage\Tape\FixesDescriptions() ) 
                                ForEach *imgfile\diskimage\Tape\FixesDescriptions()
                                    ErrorCount + 1
                                    Report$    + "Error: " + Str(ErrorCount) + " " + *imgfile\diskimage\Tape\FixesDescriptions() + #CRLF$
                                Next
                                
                            Else
                                Report$ = "No Erros Reportet. Tape Status Good"
                            EndIf                          
                    EndSelect        
                EndIf
        EndSelect        

        di_close(*imgfile)        
        di_free_image(*di)         
        
        CBMDiskImage::*er\s = Report$    
        
    EndProcedure    
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    ; Info: Disk Tools
    ; ImageFile$: A D64, D71, D81 image with full path
    ; Selection : "TITLE"   = Return Disk Title
    ;             "ID"      = Return Disk ID
    ;             "FILE"    = Return File (Filename Only)
    ;             "PATHFILE"= Return Full Path & File
    ;             "FREE"    = Return amount of Blocks Free
    ;             "FORMAT"  = Return the Image Format
    ;             "BAM"     = Return Block Avail. Map
    ; -----------------------------------------------------------------------------------------------------------------------------------------
    Procedure.s CBM_Disk_Image_Tools(DiskImage$, Selection.s = "TITLE")
        
        Protected *di.DiskImage, *imgfile.ImageFile, *er.LastError, R.s
        
        
        *di = di_load_image(DiskImage$)
        If (*di = -1 )            
            If ( CBMDiskImage::*er\s = "")
                R = "Couldn't Load Disk Image: " + DiskImage$ + #CR$
                CBMDiskImage::*er\s  = R
            EndIf             
            ProcedureReturn CBMDiskImage::*er\s
        EndIf
                
        Select UCase(Selection)
            Case "TITLE"    : R = di_Get_TitleHead(*di)        ; Return Title
            Case "ID"       : R = di_Get_Title_ID(*di)         ; Return Disk ID
            Case "FILE"     : R = di_get_Filename(*di)         ; Return Filename
            Case "PATHFILE" : R = di_get_Filename(*di,#True)   ; Return Filename              
            Case "FREE"     : R = Str( di_sho_FreeBlocks(*di) ); Return Free Blocks
            Case "FORMAT"   : R = di_get_FormatImage(*di)      ; Show DiskImage Format
            Case "BAM"      : R = debug_load_bam(*di) 
            Case "GEOSCHECK": R = di_get_GeosFormat(*di)    
        EndSelect         
        
        di_free_image(*di)         
        ProcedureReturn R
    EndProcedure     
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    ; Test Directory and Show Disk Bam
    ; -----------------------------------------------------------------------------------------------------------------------------------------      
    Procedure.i CBM_Load_Directory(DiskImage$)        
        Protected *di.DiskImage, *imgfile.ImageFile       
        
        ClearList ( CBMDiskImage::CBMDirectoryList() )
        
        *di = di_load_image(DiskImage$)
        If ( *di = -1 )
            If ( CBMDiskImage::*er\s = "")
                SetError("Couldn't Load Disk Image: " + DiskImage$)
            EndIf
            ProcedureReturn -1
        EndIf 
        
        *imgfile = di_open(*di, '$', 2 ,"rb")
        If ( *imgfile = 0 )
            SetError( "Couldn't open directory for Disk Image: " + DiskImage$ )
        EndIf      
        
        *imgfile = di_read_directory_blocks(*imgfile)   
        If ( *imgfile = 0 )
           SetError( "BAM Read failed for Disk Image: " + DiskImage$ )
        EndIf
        
        di_Get_List(*imgfile)
        
        di_close(*imgfile)        
        di_free_image(*di) 
        
        ProcedureReturn 1
    EndProcedure            
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    ; Test Directory and Show Disk Bam
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    Procedure.i CBM_Test_Full_Info(DiskImage$, HidePattern$ = "")
        
        Protected *di.DiskImage, *imgfile.ImageFile, *er.LastError
        
        *di = di_load_image(DiskImage$)
        If  ( *di = -1 )
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
        
        Debug "----------------------------------------------|"         
        Debug "| DISK   :" + di_Set_CharSet( di_get_Filename(*di) )
        Debug "| FORMAT :" + di_get_FormatImage(*di)
        Debug "| ----------------------------------| DISK ID |"
        Debug "| DISK NAME  :  0 " + Chr(34) + LSet( di_Get_TitleHead(*di),16,Chr(32) ) + Chr(34)  + "| "+di_Get_Title_ID(*di) 
        Debug "| ------------------------------------------- |"        
        While NextElement( CBMDiskImage::CBMDirectoryList() )
            CBMFileSize.i = CBMDiskImage::CBMDirectoryList()\C64Size
            CBMFileName.s = CBMDiskImage::CBMDirectoryList()\C64File
            CBMFileType.S = CBMDiskImage::CBMDirectoryList()\C64Type
            
            If ( FindString( CBMFileType, HidePattern$ , 1) = 0 )                  
                Debug "| FILE NAME  :"+ RSet( Str( CBMFileSize ),3,Chr(32)) +" "+ Chr(34) + LSet( CBMFileName ,16,Chr(32) ) + Chr(34) + "   " + CBMFileType
            EndIf    
        Wend        
        Debug "| ------------------------------------------- |"       
        Debug "| FREE BLOCKS: " + Str( di_sho_FreeBlocks(*di) ) 
        Debug "| TEST DSKBAM: "
        Debug "| --------------------------------------------|" +#CRLF$+#CRLF$         
        Debug debug_load_bam(*di)   
             
        
        di_close(*imgfile)
        di_free_image(*di)                
    EndProcedure 
    Procedure.l CBMFontCharset1()
    DataSection
            C64FontBeg:
                Data.l $00F15A4D,$00000001,$00000004,$0000FFFF,$000000B8,$00000000,$00000040,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000080
                Data.l $0EBA1F0E,$CD09B400,$4C01B821,$685421CD,$70207369,$72676F72,$72206D61,$69757165,$20736572,$7263694D,$666F736F,$69572074,$776F646E,$0A0D2E73,$00000024,$00000000
                Data.l $3C05454E,$00010085,$00000000,$00008308,$00000000,$00000000,$00000000,$00000000,$0040002C,$00740040,$00850085,$00000106,$00040000,$08020000,$00000000,$03000000
                Data.l $80070004,$00000001,$00140000,$0C500009,$0000002C,$80080000,$00000001,$001D0000,$1C30012B,$00008001,$00000000,$4E4F4607,$52494454,$4D42430D,$7269442D,$6F746365
                Data.l $00007972,$46280000,$52544E4F,$31205345,$392C3030,$36392C36,$4D203A20,$64657869,$34364320,$46202620,$6C707869,$006E6961,$00000000,$00000000,$00000000,$00000000
                Data.l $00010001,$12AA0300,$614D0000,$20797472,$70656853,$00647261,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                Data.l $00000000,$00000000,$00600009,$000B0060,$00000000,$90000000,$00070001,$0700000C,$00000700,$E020FFFF,$00000000,$00069400,$00000000,$42430000,$69442D4D,$74636572
                Data.l $2F79726F,$7472614D,$00000079,$00000000,$12AA0300,$614D0000,$20797472,$70656853,$00647261,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
                Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$00600009,$000B0060,$00000000,$90000000,$00070001,$0700000C,$00000700,$E020FFFF,$00000000,$00069400,$00000000
                Data.l $0006AA00,$00110000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$06AA0007,$00070000,$000006B6,$06C20007,$00070000,$000006CE,$06DA0007
                Data.l $00070000,$000006E6,$06F20007,$00070000,$000006FE,$070A0007,$00070000,$00000716,$07220007,$00070000,$0000072E,$073A0007,$00070000,$00000746,$07520007,$00070000
                Data.l $0000075E,$076A0007,$00070000,$00000776,$07820007,$00070000,$0000078E,$079A0007,$00070000,$000007A6,$07B20007,$00070000,$000007BE,$07CA0007,$00070000,$000007D6
                Data.l $07E20007,$00070000,$000007EE,$07FA0007,$00070000,$00000806,$08120007,$00070000,$0000081E,$082A0007,$00070000,$00000836,$08420007,$00070000,$0000084E,$085A0007
                Data.l $00070000,$00000866,$08720007,$00070000,$0000087E,$088A0007,$00070000,$00000896,$08A20007,$00070000,$000008AE,$08BA0007,$00070000,$000008C6,$08D20007,$00070000
                Data.l $000008DE,$08EA0007,$00070000,$000008F6,$09020007,$00070000,$0000090E,$091A0007,$00070000,$00000926,$09320007,$00070000,$0000093E,$094A0007,$00070000,$00000956
                Data.l $09620007,$00070000,$0000096E,$097A0007,$00070000,$00000986,$09920007,$00070000,$0000099E,$09AA0007,$00070000,$000009B6,$09C20007,$00070000,$000009CE,$09DA0007
                Data.l $00070000,$000009E6,$09F20007,$00070000,$000009FE,$0A0A0007,$00070000,$00000A16,$0A220007,$00070000,$00000A2E,$0A3A0007,$00070000,$00000A46,$0A520007,$00070000
                Data.l $00000A5E,$0A6A0007,$00070000,$00000A76,$0A820007,$00070000,$00000A8E,$0A9A0007,$00070000,$00000AA6,$0AB20007,$00070000,$00000ABE,$0ACA0007,$00070000,$00000AD6
                Data.l $0AE20007,$00070000,$00000AEE,$0AFA0007,$00070000,$00000B06,$0B120007,$00070000,$00000B1E,$0B2A0007,$00070000,$00000B36,$0B420007,$00070000,$00000B4E,$0B5A0007
                Data.l $00070000,$00000B66,$0B720007,$00070000,$00000B7E,$0B8A0007,$00070000,$00000B96,$0BA20007,$00070000,$00000BAE,$0BBA0007,$00070000,$00000BC6,$0BD20007,$00070000
                Data.l $00000BDE,$0BEA0007,$00070000,$00000BF6,$0C020007,$00070000,$00000C0E,$0C1A0007,$00070000,$00000C26,$0C320007,$00070000,$00000C3E,$0C4A0007,$00070000,$00000C56
                Data.l $0C620007,$00070000,$00000C6E,$0C7A0007,$00070000,$00000C86,$0C920007,$00070000,$00000C9E,$0CAA0007,$00070000,$00000CB6,$0CC20007,$00070000,$00000CCE,$0CDA0007
                Data.l $00070000,$00000CE6,$0CF20007,$00070000,$00000CFE,$0D0A0007,$00070000,$00000D16,$0D220007,$00070000,$00000D2E,$0D3A0007,$00070000,$00000D46,$0D520007,$00070000
                Data.l $00000D5E,$0D6A0007,$00070000,$00000D76,$0D820007,$00070000,$00000D8E,$0D9A0007,$00070000,$00000DA6,$0DB20007,$00070000,$00000DBE,$0DCA0007,$00070000,$00000DD6
                Data.l $0DE20007,$00070000,$00000DEE,$0DFA0007,$00070000,$00000E06,$0E120007,$00070000,$00000E1E,$0E2A0007,$00070000,$00000E36,$0E420007,$00070000,$00000E4E,$0E5A0007
                Data.l $00070000,$00000E66,$0E720007,$00070000,$00000E7E,$0E8A0007,$00070000,$00000E96,$0EA20007,$00070000,$00000EAE,$0EBA0007,$00070000,$00000EC6,$0ED20007,$00070000
                Data.l $00000EDE,$0EEA0007,$00070000,$00000EF6,$0F020007,$00070000,$00000F0E,$0F1A0007,$00070000,$00000F26,$0F320007,$00070000,$00000F3E,$0F4A0007,$00070000,$00000F56
                Data.l $0F620007,$00070000,$00000F6E,$0F7A0007,$00070000,$00000F86,$0F920007,$00070000,$00000F9E,$0FAA0007,$00070000,$00000FB6,$0FC20007,$00070000,$00000FCE,$0FDA0007
                Data.l $00070000,$00000FE6,$0FF20007,$00070000,$00000FFE,$100A0007,$00070000,$00001016,$10220007,$00070000,$0000102E,$103A0007,$00070000,$00001046,$10520007,$00070000
                Data.l $0000105E,$106A0007,$00070000,$00001076,$10820007,$00070000,$0000108E,$109A0007,$00070000,$000010A6,$10B20007,$00070000,$000010BE,$10CA0007,$00070000,$000010D6
                Data.l $10E20007,$00070000,$000010EE,$10FA0007,$00070000,$00001106,$11120007,$00070000,$0000111E,$112A0007,$00070000,$00001136,$11420007,$00070000,$0000114E,$115A0007
                Data.l $00070000,$00001166,$11720007,$00070000,$0000117E,$118A0007,$00070000,$00001196,$11A20007,$00070000,$000011AE,$11BA0007,$00070000,$000011C6,$11D20007,$00070000
                Data.l $000011DE,$11EA0007,$00070000,$000011F6,$12020007,$00070000,$0000120E,$121A0007,$00070000,$00001226,$12320007,$00070000,$0000123E,$124A0007,$00070000,$00001256
                Data.l $12620007,$00070000,$0000126E,$127A0007,$00070000,$00001286,$12920007,$00070000,$0000129E,$2D4D4243,$65726944,$726F7463,$614D2F79,$00797472,$86FE0000,$22222232
                Data.l $863A3E3E,$86FEFEFE,$02323202,$32323202,$06FEFEFE,$02063202,$06023232,$86FEFEFE,$3E3E3202,$8602323E,$06FEFEFE,$32323202,$06023232,$02FEFEFE,$0E0E3E02,$02023E3E
                Data.l $02FEFEFE,$0E3E3E02,$3E3E3E0E,$86FEFEFE,$223E3202,$86023222,$32FEFEFE,$02023232,$32323232,$86FEFEFE,$CECECECE,$86CECECE,$02FEFEFE,$F2F2F202,$86023232,$38FEFEFE
                Data.l $1E0E2632,$3832260E,$3EFEFEFE,$3E3E3E3E,$02023E3E,$7AFEFEFE,$32020232,$32323232,$72FEFEFE,$22021232,$32323232,$86FEFEFE,$32323202,$86023232,$06FEFEFE,$02323202
                Data.l $3E3E3E06,$86FEFEFE,$32323202,$92062212,$06FEFEFE,$02323202,$32323206,$86FEFEFE,$82063A02,$860232F2,$02FEFEFE,$CECECE02,$CECECECE,$32FEFEFE,$32323232,$86023232
                Data.l $32FEFEFE,$86863232,$CECECE86,$32FEFEFE,$32323232,$7A320202,$32FEFEFE,$CE863232,$32323286,$32FEFEFE,$86323232,$CECECECE,$02FEFEFE,$CEE6F202,$02023E9E,$06FEFEFE
                Data.l $3E3E3E06,$06063E3E,$F2FEFEFE,$82CECEE4,$029CCECE,$06FEFEFE,$E6E6E606,$0606E6E6,$FEFEFEFE,$0286CEFE,$CECECECE,$FEFEFECE,$009EDEFE,$FEDE9E00,$0000FEFE,$00000000
                Data.l $00000000,$30000000,$30303030,$30300030,$D8000000,$000000D8,$00000000,$50000000,$50F8F850,$5050F8F8,$20000000,$78A0FC78,$2078FC2C,$0C000000,$3018D8CC,$CC6C6030
                Data.l $700000C0,$70D8D8F8,$74FCDCF4,$30000000,$00201030,$00000000,$18000000,$60606030,$18306060,$60000000,$18181830,$60301818,$00000000,$F870D800,$0000D870,$00000000
                Data.l $FC303000,$003030FC,$00000000,$00000000,$30300000,$00002010,$FC000000,$000000FC,$00000000,$00000000,$30300000,$0C000000,$3018180C,$C0606030,$780000C0,$FCDCCCFC
                Data.l $78FCCCEC,$30000000,$30307070,$30303030,$78000000,$3018CCFC,$FCFCC060,$78000000,$3C388CFC,$78FC8C0C,$0C000000,$CC6C3C1C,$0C0CFCFC,$FC000000,$FCF8C0FC,$78FC8C0C
                Data.l $78000000,$FCF8C4FC,$78FCCCCC,$FC000000,$30180CFC,$30303030,$78000000,$78FCCCFC,$78FCCCCC,$78000000,$FCCCCCFC,$78FC8C7C,$00000000,$30300000,$30300000,$00000000
                Data.l $30300000,$30300000,$00002010,$C0603018,$183060C0,$00000000,$F8F80000,$00F8F800,$00000000,$183060C0,$C0603018,$78000000,$3018CCFC,$30300030,$78000000,$DCDCDCCC
                Data.l $78C4C0C0,$78000000,$FCCCCCFC,$CCCCCCFC,$F8000000,$FCF8CCFC,$F8FCCCCC,$78000000,$C0C0CCFC,$78FCCCC0,$F8000000,$CCCCCCFC,$F8FCCCCC,$FC000000,$F0F0C0FC,$FCFCC0C0
                Data.l $FC000000,$F0C0C0FC,$C0C0C0F0,$78000000,$DCC0CCFC,$78FCCCDC,$CC000000,$FCFCCCCC,$CCCCCCCC,$78000000,$30303030,$78303030,$FC000000,$0C0C0CFC,$78FCCCCC,$C6000000
                Data.l $E0F0D8CC,$C6CCD8F0,$C0000000,$C0C0C0C0,$FCFCC0C0,$84000000,$CCFCFCCC,$CCCCCCCC,$8C000000,$DCFCECCC,$CCCCCCCC,$78000000,$CCCCCCFC,$78FCCCCC,$F8000000,$FCCCCCFC
                Data.l $C0C0C0F8,$78000000,$CCCCCCFC,$6CF8DCEC,$F8000000,$FCCCCCFC,$CCCCCCF8,$78000000,$7CF8C4FC,$78FCCC0C,$FC000000,$303030FC,$30303030,$CC000000,$CCCCCCCC,$78FCCCCC
                Data.l $CC000000,$7878CCCC,$30303078,$CC000000,$CCCCCCCC,$84CCFCFC,$CC000000,$3078CCCC,$CCCCCC78,$CC000000,$78CCCCCC,$30303030,$FC000000,$30180CFC,$FCFCC060,$78000000
                Data.l $60606078,$78786060,$0C000000,$7C30301A,$FC623030,$78000000,$18181878,$78781818,$00000000,$FC783000,$30303030,$00000030,$FE602000,$002060FE,$00000000,$FE000000
                Data.l $0000FEFE,$10000000,$FEFE7C38,$FE7C38FE,$38380000,$38383838,$38383838,$00003838,$FEFE0000,$000000FE,$00000000,$FEFE0000,$000000FE,$00000000,$FEFEFE00,$00000000
                Data.l $00000000,$00000000,$00FEFEFE,$70700000,$70707070,$70707070,$38387070,$38383838,$38383838,$00003838,$F0E00000,$383838F8,$E0E03838,$FEFEE0E0,$0000007E,$0E0E0000
                Data.l $FEFE0E0E,$000000FC,$E0E00000,$E0E0E0E0,$FEE0E0E0,$C0C0FEFE,$30306060,$0C0C1818,$06060606,$18180C0C,$60603030,$FEFEC0C0,$E0E0E0FE,$E0E0E0E0,$FEFEE0E0,$0E0E0EFE
                Data.l $0E0E0E0E,$00000E0E,$7E7E7E3C,$003C7E7E,$00000000,$00000000,$FEFEFE00,$6C000000,$FEFEFEFE,$38387CFE,$70701010,$70707070,$70707070,$00007070,$1E0E0000,$3838383E
                Data.l $C6C63838,$387C6CEE,$C6EE7C38,$0000C6C6,$66667E3C,$003C7E66,$38380000,$C6C6C638,$FE383838,$1C1C00FE,$1C1C1C1C,$1C1C1C1C,$00001C1C,$FE7C3810,$0010387C,$38380000
                Data.l $FEFE3838,$383838FE,$C0C03838,$C0C03030,$C0C03030,$38383030,$38383838,$38383838,$06003838,$EC7C7C06,$6C6C6CEC,$FEFE0000,$3E3E7E7E,$0E0E1E1E,$FEFE0606,$0000FEFE
                Data.l $FEFEFE00,$EEFEFEFE,$000082C6,$0082C600,$C6C6FEFE,$C6C6C6C6,$C6C6C6C6,$FEFEC6C6,$0000FEFE,$FEFEFE00,$FEFEFEFE,$000000FE,$FEFEFEFE,$FEFEFEFE,$FE000000,$FEFEFEFE
                Data.l $FEFEFEFE,$00FEFEFE,$FEFE0000,$8E8EFEFE,$8E8E8E8E,$8E8E8E8E,$C6C68E8E,$C6C6C6C6,$C6C6C6C6,$FEFEC6C6,$0002FEFE,$F0F0F000,$1E1EF0F0,$00001E1E,$FEFEFE80,$F0F0FEFE
                Data.l $0000F0F0,$FEFEFE02,$1E1EFEFE,$1E1E1E1E,$001E1E1E,$3E3E0000,$CECE9E9E,$F2F2E6E6,$F8F8F8F8,$E6E6F2F2,$9E9ECECE,$00003E3E,$1E1E1E00,$1E1E1E1E,$00001E1E,$F0F0F000
                Data.l $F0F0F0F0,$FEFEF0F0,$808080C2,$FEC28080,$FEFEFEFE,$FEFEFEFE,$0000FEFE,$92FEFE00,$00000000,$C6C68200,$8E8EEEEE,$8E8E8E8E,$8E8E8E8E,$FEFE8E8E,$0080FEFE,$1E1E1E00
                Data.l $38381E1E,$C6829210,$381082C6,$FEFE3838,$989880C2,$FEC28098,$C6C6FEFE,$383838C6,$00C6C6C6,$E2E2FE00,$E2E2E2E2,$E2E2E2E2,$FEFEE2E2,$0082C6EE,$FEEEC682,$C6C6FEFE
                Data.l $0000C6C6,$C6C6C600,$3E3EC6C6,$3E3ECECE,$3E3ECECE,$C6C6CECE,$C6C6C6C6,$C6C6C6C6,$F8FEC6C6,$128282F8,$92929212,$0000FEFE,$C0C08080,$F0F0E0E0,$FEFEF8F8,$FEFEFEFE
                Data.l $FEFEFEFE,$F0F0FEFE,$F0F0F0F0,$F0F0F0F0,$0000F0F0,$00000000,$FEFEFEFE,$FEFEFEFE,$00000000,$00000000,$00000000,$00000000,$00000000,$E0E0FEFE,$E0E0E0E0,$E0E0E0E0
                Data.l $54AAE0E0,$54AA54AA,$54AA54AA,$0E0E54AA,$0E0E0E0E,$0E0E0E0E,$00000E0E,$00000000,$54AA54AA,$FEFE00AA,$F8F8FCFC,$E0E0F0F0,$0E0EC0C0,$0E0E0E0E,$0E0E0E0E,$38380E0E
                Data.l $3E383838,$38383E3E,$00003838,$00000000,$3E3E3E3E,$38383E3E,$3E383838,$00003E3E,$00000000,$F8000000,$3838F8F8,$00003838,$00000000,$FEFE0000,$000000FE,$3E000000
                Data.l $38383E3E,$38383838,$FE383838,$0000FEFE,$00000000,$FE000000,$3838FEFE,$38383838,$F8383838,$3838F8F8,$E0E03838,$E0E0E0E0,$E0E0E0E0,$70700000,$70707070,$70707070
                Data.l $0E0E0070,$0E0E0E0E,$0E0E0E0E,$FEFE000E,$00000000,$00000000,$FEFE0000,$000000FE,$00000000,$00000000,$00000000,$FE000000,$0E0EFEFE,$0E0E0E0E,$00FEFEFE,$00000000
                Data.l $00000000,$F0F0F000,$1E1E00F0,$00001E1E,$00000000,$38380000,$F8383838,$0000F8F8,$F0F00000,$0000F0F0,$00000000,$00000000,$F0F0F0F0,$1E1E1E1E,$00000000,$FE000000
                Data.l $0000FEFE,$10000000,$FEFE7C38,$FE7C38FE,$38380000,$38383838,$38383838,$00000038,$FEFE0000,$000000FE,$00000000,$FEFE0000,$000000FE,$00000000,$00FEFEFE,$00000000
                Data.l $00000000,$00000000,$00FEFEFE,$38380000,$38383838,$38383838,$38383838,$38383838,$38383838,$00003838,$E0000000,$3838F8F0,$38383838,$1E3E3838,$0000000E,$38380000
                Data.l $F0F83838,$000000E0,$E0E00000,$E0E0E0E0,$FEFEE0E0,$800000FE,$3870E0C0,$02060E1C,$02000000,$381C0E06,$80C0E070,$FEFE0000,$E0E0E0FE,$E0E0E0E0,$FEFE00E0,$0E0E0EFE
                Data.l $0E0E0E0E,$7C00000E,$FEFEFE7C,$7C7CFEFE,$00000000,$00000000,$FE000000,$6C0000FE,$FEFEFEFE,$10387C7C,$70700000,$70707070,$70707070,$00000070,$0E000000,$38383E1E
                Data.l $C6C63838,$387C6CEE,$C6EE6C7C,$7C0000C6,$C6C6FE7C,$7C7CFEC6,$30300000,$CCCCCC30,$78303030,$1C1C0000,$1C1C1C1C,$1C1C1C1C,$00001C1C,$FE7C3810,$0010387C,$38380000
                Data.l $FE383838,$3838FEFE,$C0C03838,$C0C03030,$C0C03030,$38383030,$38383838,$38383838,$06003838,$EC7C7C06,$6C6C6CEC,$7EFE0000,$1E3E3E7E,$060E0E1E,$00000606,$00000000
                Data.l $00000000,$E2E20000,$E2E2E2E2,$E2E2E2E2,$0000E2E2,$00000000,$FEFEFEFE,$FEFEFEFE,$00000000,$00000000,$00000000,$00000000,$00000000,$E0E0FEFE,$E0E0E0E0,$E0E0E0E0
                Data.l $54AAE0E0,$54AA54AA,$54AA54AA,$0E0E54AA,$0E0E0E0E,$0E0E0E0E,$00000E0E,$00000000,$54AA54AA,$FEFE00AA,$F8F8FCFC,$E0E0F0F0,$0E0EC0C0,$0E0E0E0E,$0E0E0E0E,$38380E0E
                Data.l $3E383838,$38383E3E,$00003838,$00000000,$3E3E3E3E,$38383E3E,$3E3E3838,$0000003E,$00000000,$F8000000,$3838F8F8,$00003838,$00000000,$FEFE0000,$000000FE,$3E000000
                Data.l $38383E3E,$38383838,$FE383838,$0000FEFE,$00000000,$FE000000,$3838FEFE,$38383838,$F8383838,$3838F8F8,$E0E03838,$E0E0E0E0,$E0E0E0E0,$70700000,$70707070,$70707070
                Data.l $0E0E0070,$0E0E0E0E,$0E0E0E0E,$FEFE0000,$00000000,$00000000,$FEFE0000,$000000FE,$00000000,$00000000,$00000000,$FEFEFE00,$06060000,$06060606,$FEFE0606,$00000000
                Data.l $00000000,$F0F0F0F0,$1E1E0000,$00001E1E,$00000000,$38380000,$F8383838,$0000F8F8,$F0F00000,$0000F0F0,$00000000,$06000000,$EC7C7C06,$6C6C6CEC,$00000000,$00000000
                C64FontEnd:
            EndDataSection
;             BytesTotal  = ?C64FontEnd - ?C64FontBeg
;             BytesLeft   = BytesTotal
;             
;             *CBM.cbmProgram 
;             *CBM = AllocateMemory(BytesLeft)            
;             
;             DataBlock = 0
;             While BytesLeft
;             
;             *CBM\l[DataBlock] = PeekL(?C64FontBeg + SizeOf(long) * DataBlock)
;             BytesLeft - SizeOf(long)
;             DataBlock + 1      
;             Wend            
            

                OpenLibrary(0,"gdi32.dll")  
                    FontID_C64CHAR           = CallFunction(0,"AddFontMemResourceEx",?C64FontBeg,?C64FontEnd-?C64FontBeg,0,@"1")    
                CloseLibrary(0)   
                Define FontA = LoadFont(#PB_Any,"CBM-Directory/Marty",12,#PB_Font_HighQuality)     
            ProcedureReturn FontID(FontA)
        EndProcedure   
    Procedure.l CBMFontCharset2()
    DataSection
            C64FontBeg:
            Data.l $00F15A4D,$00000001,$00000004,$0000FFFF,$000000B8,$00000000,$00000040,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000080
            Data.l $0EBA1F0E,$CD09B400,$4C01B821,$685421CD,$70207369,$72676F72,$72206D61,$69757165,$20736572,$7263694D,$666F736F,$69572074,$776F646E,$0A0D2E73,$00000024,$00000000
            Data.l $3C05454E,$00010081,$00000000,$00008308,$00000000,$00000000,$00000000,$00000000,$00400027,$00740040,$00810081,$00000102,$00040000,$08020000,$00000000,$03000000
            Data.l $80070004,$00000001,$00130000,$0C500009,$0000002C,$80080000,$00000001,$001C0000,$1C300107,$00008001,$00000000,$4E4F4607,$52494454,$58494609,$49414C50,$0000374E
            Data.l $46230000,$52544E4F,$31205345,$392C3030,$36392C36,$66203A20,$6C707869,$376E6961,$20323120,$00003231,$00000000,$00000000,$00010001,$10640300,$614D0000,$00797472
            Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00600009,$000B0060
            Data.l $00000000,$90000000,$00070001,$0700000C,$20000700,$C420FFFF,$00000000,$0005D400,$00000000,$69460000,$616C7078,$2F376E69,$00343643,$00000000,$00000000,$00000000
            Data.l $10640300,$614D0000,$00797472,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
            Data.l $00000000,$00600009,$000B0060,$00000000,$90000000,$00070001,$0700000C,$20000700,$C420FFFF,$00000000,$0005D400,$00000000,$0005E400,$00110000,$00000000,$00000000
            Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$05E40007,$00070000,$000005F0,$05FC0007,$00070000,$00000608,$06140007,$00070000,$00000620,$062C0007,$00070000
            Data.l $00000638,$06440007,$00070000,$00000650,$065C0007,$00070000,$00000668,$06740007,$00070000,$00000680,$068C0007,$00070000,$00000698,$06A40007,$00070000,$000006B0
            Data.l $06BC0007,$00070000,$000006C8,$06D40007,$00070000,$000006E0,$06EC0007,$00070000,$000006F8,$07040007,$00070000,$00000710,$071C0007,$00070000,$00000728,$07340007
            Data.l $00070000,$00000740,$074C0007,$00070000,$00000758,$07640007,$00070000,$00000770,$077C0007,$00070000,$00000788,$07940007,$00070000,$000007A0,$07AC0007,$00070000
            Data.l $000007B8,$07C40007,$00070000,$000007D0,$07DC0007,$00070000,$000007E8,$07F40007,$00070000,$00000800,$080C0007,$00070000,$00000818,$08240007,$00070000,$00000830
            Data.l $083C0007,$00070000,$00000848,$08540007,$00070000,$00000860,$086C0007,$00070000,$00000878,$08840007,$00070000,$00000890,$089C0007,$00070000,$000008A8,$08B40007
            Data.l $00070000,$000008C0,$08CC0007,$00070000,$000008D8,$08E40007,$00070000,$000008F0,$08FC0007,$00070000,$00000908,$09140007,$00070000,$00000920,$092C0007,$00070000
            Data.l $00000938,$09440007,$00070000,$00000950,$095C0007,$00070000,$00000968,$09740007,$00070000,$00000980,$098C0007,$00070000,$00000998,$09A40007,$00070000,$000009B0
            Data.l $09BC0007,$00070000,$000009C8,$09D40007,$00070000,$000009E0,$09EC0007,$00070000,$000009F8,$0A040007,$00070000,$00000A10,$0A1C0007,$00070000,$00000A28,$0A340007
            Data.l $00070000,$00000A40,$0A4C0007,$00070000,$00000A58,$0A640007,$00070000,$00000A70,$0A7C0007,$00070000,$00000A88,$0A940007,$00070000,$00000AA0,$0AAC0007,$00070000
            Data.l $00000AB8,$0AC40007,$00070000,$00000AD0,$0ADC0007,$00070000,$00000AE8,$0AF40007,$00070000,$00000B00,$0B0C0007,$00070000,$00000B18,$0B240007,$00070000,$00000B30
            Data.l $0B3C0007,$00070000,$00000B48,$0B540007,$00070000,$00000B60,$0B6C0007,$00070000,$00000B78,$0B840007,$00070000,$00000B90,$0B9C0007,$00070000,$00000BA8,$0BB40007
            Data.l $00070000,$00000BC0,$0BCC0007,$00070000,$00000BD8,$0BE40007,$00070000,$00000BF0,$0BFC0007,$00070000,$00000C08,$0C140007,$00070000,$00000C20,$0C2C0007,$00070000
            Data.l $00000C38,$0C440007,$00070000,$00000C50,$0C5C0007,$00070000,$00000C68,$0C740007,$00070000,$00000C80,$0C8C0007,$00070000,$00000C98,$0CA40007,$00070000,$00000CB0
            Data.l $0CBC0007,$00070000,$00000CC8,$0CD40007,$00070000,$00000CE0,$0CEC0007,$00070000,$00000CF8,$0D040007,$00070000,$00000D10,$0D1C0007,$00070000,$00000D28,$0D340007
            Data.l $00070000,$00000D40,$0D4C0007,$00070000,$00000D58,$0D640007,$00070000,$00000D70,$0D7C0007,$00070000,$00000D88,$0D940007,$00070000,$00000DA0,$0DAC0007,$00070000
            Data.l $00000DB8,$0DC40007,$00070000,$00000DD0,$0DDC0007,$00070000,$00000DE8,$0DF40007,$00070000,$00000E00,$0E0C0007,$00070000,$00000E18,$0E240007,$00070000,$00000E30
            Data.l $0E3C0007,$00070000,$00000E48,$0E540007,$00070000,$00000E60,$0E6C0007,$00070000,$00000E78,$0E840007,$00070000,$00000E90,$0E9C0007,$00070000,$00000EA8,$0EB40007
            Data.l $00070000,$00000EC0,$0ECC0007,$00070000,$00000ED8,$0EE40007,$00070000,$00000EF0,$0EFC0007,$00070000,$00000F08,$0F140007,$00070000,$00000F20,$0F2C0007,$00070000
            Data.l $00000F38,$0F440007,$00070000,$00000F50,$0F5C0007,$00070000,$00000F68,$0F740007,$00070000,$00000F80,$0F8C0007,$00070000,$00000F98,$0FA40007,$00070000,$00000FB0
            Data.l $0FBC0007,$00070000,$00000FC8,$0FD40007,$00070000,$00000FE0,$0FEC0007,$00070000,$00000FF8,$10040007,$00070000,$00001010,$101C0007,$00070000,$00001028,$10340007
            Data.l $00070000,$00001040,$104C0007,$00070000,$00001058,$70786946,$6E69616C,$36432F37,$00000034,$00000000,$00000000,$00000000,$60606000,$00606060,$00006060,$00D8D800
            Data.l $00000000,$00000000,$F8500000,$F8F850F8,$00000050,$FC782000,$FC2C78A0,$00002078,$D8CC0C00,$60303018,$00C0CC6C,$D8F87000,$DCF470D8,$000074FC,$10303000,$00000020
            Data.l $00000000,$60301800,$60606060,$00001830,$18306000,$18181818,$00006030,$D8000000,$D870F870,$00000000,$30000000,$30FCFC30,$00000030,$00000000,$00000000,$20103030
            Data.l $00000000,$00FCFC00,$00000000,$00000000,$00000000,$00003030,$180C0C00,$60303018,$00C0C060,$CCFC7800,$CCECFCDC,$000078FC,$70703000,$30303030,$00003030,$CCFC7800
            Data.l $C0603018,$0000FCFC,$8CFC7800,$8C0C3C38,$000078FC,$3C1C0C00,$FCFCCC6C,$00000C0C,$C0FCFC00,$8C0CFCF8,$000078FC,$C4FC7800,$CCCCFCF8,$000078FC,$0CFCFC00,$30303018
            Data.l $00003030,$CCFC7800,$CCCC78FC,$000078FC,$CCFC7800,$8C7CFCCC,$000078FC,$00000000,$00003030,$00003030,$00000000,$00003030,$20103030,$30180000,$60C0C060,$00001830
            Data.l $00000000,$F800F8F8,$000000F8,$60C00000,$30181830,$0000C060,$CCFC7800,$00303018,$00003030,$84847800,$80B8ACBC,$00007886,$CCFC7800,$CCFCFCCC,$0000CCCC,$CCFCF800
            Data.l $CCCCFCF8,$0000F8FC,$CCFC7800,$CCC0C0C0,$000078FC,$CCFCF800,$CCCCCCCC,$0000F8FC,$C0FCFC00,$C0C0F0F0,$0000FCFC,$C0FCFC00,$C0F0F0C0,$0000C0C0,$CCFC7800,$CCDCDCC0
            Data.l $000078FC,$CCCCCC00,$CCCCFCFC,$0000CCCC,$30307800,$30303030,$00007830,$0CFCFC00,$CCCC0C0C,$000078FC,$D8CCC600,$D8F0E0F0,$0000C6CC,$C0C0C000,$C0C0C0C0,$0000FCFC
            Data.l $FCCC8400,$CCCCCCFC,$0000CCCC,$ECCC8C00,$CCCCDCFC,$0000CCCC,$CCFC7800,$CCCCCCCC,$000078FC,$CCFCF800,$C0F8FCCC,$0000C0C0,$CCFC7800,$DCECCCCC,$00006CF8,$CCFCF800
            Data.l $CCF8FCCC,$0000CCCC,$C4FC7800,$CC0C7CF8,$000078FC,$30FCFC00,$30303030,$00003030,$CCCCCC00,$CCCCCCCC,$000078FC,$CCCCCC00,$30787878,$00003030,$CCCCCC00,$FCFCCCCC
            Data.l $000084CC,$CCCCCC00,$CC783078,$0000CCCC,$CCCCCC00,$303078CC,$00003030,$0CFCFC00,$C0603018,$0000FCFC,$C0F0F000,$C0C0C0C0,$0000F0F0,$60C0C000,$18303060,$000C0C18
            Data.l $30F0F000,$30303030,$0000F0F0,$CC783000,$00000084,$00000000,$00000000,$00000000,$00FCFC00,$20303000,$00000010,$00000000,$78000000,$CC7C0C7C,$00007CFC,$F8C0C000
            Data.l $CCCCCCFC,$0000F8FC,$78000000,$CCC0CCFC,$000078FC,$7C0C0C00,$CCCCCCFC,$00007CFC,$78000000,$C0FCCCFC,$000078FC,$78301800,$30303078,$00003030,$7C000000,$FCCCCCFC
            Data.l $78FC8C7C,$F8C0C000,$CCCCCCFC,$0000CCCC,$00303000,$30303030,$00003030,$00181800,$18181818,$70F8D818,$CCC0C000,$F0E0F0D8,$0000CCD8,$30303000,$30303030,$00003030
            Data.l $A8000000,$D4D4FCFC,$0000D4D4,$D8000000,$CCCCECFC,$0000CCCC,$78000000,$CCCCCCFC,$000078FC,$F8000000,$CCCCCCFC,$C0C0F8FC,$7C000000,$CCCCCCFC,$0C0C7CFC,$D8000000
            Data.l $C0C0E0F8,$0000C0C0,$78000000,$8C78C4FC,$000078FC,$78303000,$30303078,$00001838,$CC000000,$DCCCCCCC,$00006CFC,$D8000000,$7070D8D8,$00002070,$D4000000,$FCD4D4D4
            Data.l $0000A8FC,$CC000000,$783078CC,$0000CCCC,$CC000000,$FCCCCCCC,$78FC8C7C,$FC000000,$603018FC,$0000FCFC,$60783800,$6060C060,$00003878,$30303000,$30300030,$00003030
            Data.l $30F0E000,$30301830,$0000E0F0,$D8FC7400,$00000000,$00000000,$381C0C00,$38DCEC70,$00C0E070,$FEFEFEFE,$FE000000,$FEFEFEFE,$82C6EEFE,$C6000000,$FEFE0082,$C6C6C6C6
            Data.l $C6C6C6C6,$C6C6C6C6,$FEFEFEFE,$FE000000,$FEFEFEFE,$00FEFEFE,$FEFE0000,$FEFEFEFE,$0000FEFE,$FEFEFE00,$FEFEFEFE,$FEFEFEFE,$000000FE,$FEFEFEFE,$8E8E8E8E,$8E8E8E8E
            Data.l $8E8E8E8E,$C6C6C6C6,$C6C6C6C6,$C6C6C6C6,$FEFEFEFE,$F0000002,$F0F0F0F0,$1E1E1E1E,$FE800000,$FEFEFEFE,$F0F0F0F0,$FE020000,$FEFEFEFE,$1E1E1E1E,$1E1E1E1E,$0000001E
            Data.l $9E9E3E3E,$E6E6CECE,$F8F8F2F2,$F2F2F8F8,$CECEE6E6,$3E3E9E9E,$1E000000,$1E1E1E1E,$1E1E1E1E,$F0000000,$F0F0F0F0,$F0F0F0F0,$80C2FEFE,$80808080,$FEFEFEC2,$FEFEFEFE
            Data.l $FEFEFEFE,$FE000000,$000092FE,$82000000,$EEEEC6C6,$8E8E8E8E,$8E8E8E8E,$8E8E8E8E,$FEFEFEFE,$1E000080,$1E1E1E1E,$92103838,$82C6C682,$38383810,$80C2FEFE,$80989898
            Data.l $FEFEFEC2,$38C6C6C6,$C6C63838,$FE0000C6,$E2E2E2E2,$E2E2E2E2,$E2E2E2E2,$C6EEFEFE,$C6820082,$FEFEFEEE,$C6C6C6C6,$C6000000,$C6C6C6C6,$CECE3E3E,$CECE3E3E,$CECE3E3E
            Data.l $C6C6C6C6,$C6C6C6C6,$C6C6C6C6,$82F8F8FE,$92121282,$FEFE9292,$80800000,$E0E0C0C0,$F8F8F0F0,$FEFEFEFE,$FEFEFEFE,$FEFEFEFE,$F0F0F0F0,$F0F0F0F0,$F0F0F0F0,$00000000
            Data.l $FEFE0000,$FEFEFEFE,$0000FEFE,$00000000,$00000000,$00000000,$00000000,$FEFE0000,$E0E0E0E0,$E0E0E0E0,$E0E0E0E0,$54AA54AA,$54AA54AA,$54AA54AA,$0E0E0E0E,$0E0E0E0E
            Data.l $0E0E0E0E,$00000000,$54AA0000,$00AA54AA,$FCFCFEFE,$F0F0F8F8,$C0C0E0E0,$0E0E0E0E,$0E0E0E0E,$0E0E0E0E,$38383838,$3E3E3E38,$38383838,$00000000,$3E3E0000,$3E3E3E3E
            Data.l $38383838,$3E3E3E38,$00000000,$00000000,$F8F8F800,$38383838,$00000000,$00000000,$00FEFEFE,$00000000,$3E3E3E00,$38383838,$38383838,$FEFEFE38,$00000000,$00000000
            Data.l $FEFEFE00,$38383838,$38383838,$F8F8F838,$38383838,$E0E0E0E0,$E0E0E0E0,$0000E0E0,$70707070,$70707070,$00707070,$0E0E0E0E,$0E0E0E0E,$000E0E0E,$0000FEFE,$00000000
            Data.l $00000000,$00FEFEFE,$00000000,$00000000,$00000000,$00000000,$FEFEFE00,$0E0E0E0E,$FEFE0E0E,$000000FE,$00000000,$F0000000,$00F0F0F0,$1E1E1E1E,$00000000,$00000000
            Data.l $38383838,$F8F8F838,$00000000,$F0F0F0F0,$00000000,$00000000,$F0F00000,$1E1EF0F0,$00001E1E,$00000000,$FEFEFE00,$00000000,$CCFC7800,$CCFCFCCC,$0000CCCC,$CCFCF800
            Data.l $CCCCFCF8,$0000F8FC,$CCFC7800,$CCC0C0C0,$000078FC,$CCFCF800,$CCCCCCCC,$0000F8FC,$C0FCFC00,$C0C0F0F0,$0000FCFC,$C0FCFC00,$C0F0F0C0,$0000C0C0,$CCFC7800,$CCDCDCC0
            Data.l $000078FC,$CCCCCC00,$CCCCFCFC,$0000CCCC,$30307800,$30303030,$00007830,$0CFCFC00,$CCCC0C0C,$000078FC,$D8CCC600,$D8F0E0F0,$0000C6CC,$C0C0C000,$C0C0C0C0,$0000FCFC
            Data.l $FCCC8400,$CCCCCCFC,$0000CCCC,$ECCC8C00,$CCCCDCFC,$0000CCCC,$CCFC7800,$CCCCCCCC,$000078FC,$CCFCF800,$C0F8FCCC,$0000C0C0,$CCFC7800,$DCECCCCC,$00006CF8,$CCFCF800
            Data.l $CCF8FCCC,$0000CCCC,$C4FC7800,$CC0C7CF8,$000078FC,$30FCFC00,$30303030,$00003030,$CCCCCC00,$CCCCCCCC,$000078FC,$CCCCCC00,$30787878,$00003030,$CCCCCC00,$FCFCCCCC
            Data.l $000084CC,$CCCCCC00,$CC783078,$0000CCCC,$CCCCCC00,$303078CC,$00003030,$0CFCFC00,$C0603018,$0000FCFC,$38383838,$FEFEFE38,$38383838,$3030C0C0,$3030C0C0,$3030C0C0
            Data.l $38383838,$38383838,$38383838,$7C060600,$6CECEC7C,$00006C6C,$3E7E7EFE,$0E1E1E3E,$0606060E,$00000000,$00000000,$00000000,$E2E2E2E2,$E2E2E2E2,$E2E2E2E2,$00000000
            Data.l $FEFE0000,$FEFEFEFE,$0000FEFE,$00000000,$00000000,$00000000,$00000000,$FEFE0000,$E0E0E0E0,$E0E0E0E0,$E0E0E0E0,$54AA54AA,$54AA54AA,$54AA54AA,$0E0E0E0E,$0E0E0E0E
            Data.l $0E0E0E0E,$00000000,$54AA0000,$00AA54AA,$FCFCFEFE,$F0F0F8F8,$C0C0E0E0,$0E0E0E0E,$0E0E0E0E,$0E0E0E0E,$38383838,$3E3E3E38,$38383838,$00000000,$3E3E0000,$3E3E3E3E
            Data.l $38383838,$003E3E3E,$00000000,$00000000,$F8F8F800,$38383838,$00000000,$00000000,$00FEFEFE,$00000000,$3E3E3E00,$38383838,$38383838,$FEFEFE38,$00000000,$00000000
            Data.l $FEFEFE00,$38383838,$38383838,$F8F8F838,$38383838,$E0E0E0E0,$E0E0E0E0,$0000E0E0,$70707070,$70707070,$00707070,$0E0E0E0E,$0E0E0E0E,$00000E0E,$0000FEFE,$00000000
            Data.l $00000000,$00FEFEFE,$00000000,$00000000,$00000000,$FE000000,$0000FEFE,$06060606,$06060606,$0000FEFE,$00000000,$F0F00000,$0000F0F0,$1E1E1E1E,$00000000,$00000000
            Data.l $38383838,$F8F8F838,$00000000,$F0F0F0F0,$00000000,$00000000,$7C060600,$6CECEC7C,$00006C6C,$00000000,$00000000,$00000000
                C64FontEnd:
            EndDataSection
;             BytesTotal  = ?C64FontEnd - ?C64FontBeg
;             BytesLeft   = BytesTotal
;             
;             *CBM.cbmProgram 
;             *CBM = AllocateMemory(BytesLeft)            
;             
;             DataBlock = 0
;             While BytesLeft
;             
;             *CBM\l[DataBlock] = PeekL(?C64FontBeg + SizeOf(long) * DataBlock)
;             BytesLeft - SizeOf(long)
;             DataBlock + 1      
;             Wend            
            
            ; 
            ; Using Openalib. With the code above i can't avoid the High Object Number 
            OpenLibrary(0,"gdi32.dll")  
            FontID_C64CHAR           = CallFunction(0,"AddFontMemResourceEx",?C64FontBeg,?C64FontEnd-?C64FontBeg,0,@"1")    
            CloseLibrary(0)   
            Define FontA = LoadFont(#PB_Any,"Fixplain7/C64",12)
            ProcedureReturn FontID(FontA)
        EndProcedure 
    Procedure.l CBMFontCharset3()
    DataSection
            C64FontBeg:
                Data.l $00F15A4D,$00000001,$00000004,$0000FFFF,$000000B8,$00000000,$00000040,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000080
                Data.l $0EBA1F0E,$CD09B400,$4C01B821,$685421CD,$70207369,$72676F72,$72206D61,$69757165,$20736572,$7263694D,$666F736F,$69572074,$776F646E,$0A0D2E73,$00000024,$00000000
                Data.l $3C05454E,$00010081,$00000000,$00008300,$00000000,$00000000,$00000000,$00000000,$00400025,$00740040,$00810081,$00000102,$00040000,$00020000,$00000000,$03000000
                Data.l $80070004,$00000001,$00130000,$0C500009,$0000002C,$80080000,$00000001,$001C0000,$1C300107,$00008001,$00000000,$4E4F4607,$52494454,$58494609,$49414C50,$0000374E
                Data.l $46210000,$52544E4F,$31205345,$392C3030,$36392C36,$7869663A,$69616C70,$3120376E,$32312032,$00000000,$00000000,$00000000,$00010001,$10700300,$6E550000,$776F6E6B
                Data.l $4328206E,$65766E6F,$64657472,$6F726620,$6D41206D,$20616769,$746E6F66,$69737520,$4620676E,$29796E6F,$00000000,$00000000,$00000000,$00000000,$0060000C,$000B0060
                Data.l $00000000,$90000000,$00070001,$0700000C,$20000700,$C420FFFF,$00000000,$0005D400,$00000000,$69660000,$616C7078,$20376E69,$00003231,$00000000,$00000000,$00000000
                Data.l $10700300,$6E550000,$776F6E6B,$4328206E,$65766E6F,$64657472,$6F726620,$6D41206D,$20616769,$746E6F66,$69737520,$4620676E,$29796E6F,$00000000,$00000000,$00000000
                Data.l $00000000,$0060000C,$000B0060,$00000000,$90000000,$00070001,$0700000C,$20000700,$C420FFFF,$00000000,$0005D400,$00000000,$0005E200,$00110000,$00000000,$00000000
                Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$05E20007,$00070000,$000005EE,$05FA0007,$00070000,$00000606,$06120007,$00070000,$0000061E,$062A0007,$00070000
                Data.l $00000636,$06420007,$00070000,$0000064E,$065A0007,$00070000,$00000666,$06720007,$00070000,$0000067E,$068A0007,$00070000,$00000696,$06A20007,$00070000,$000006AE
                Data.l $06BA0007,$00070000,$000006C6,$06D20007,$00070000,$000006DE,$06EA0007,$00070000,$000006F6,$07020007,$00070000,$0000070E,$071A0007,$00070000,$00000726,$07320007
                Data.l $00070000,$0000073E,$074A0007,$00070000,$00000756,$07620007,$00070000,$0000076E,$077A0007,$00070000,$00000786,$07920007,$00070000,$0000079E,$07AA0007,$00070000
                Data.l $000007B6,$07C20007,$00070000,$000007CE,$07DA0007,$00070000,$000007E6,$07F20007,$00070000,$000007FE,$080A0007,$00070000,$00000816,$08220007,$00070000,$0000082E
                Data.l $083A0007,$00070000,$00000846,$08520007,$00070000,$0000085E,$086A0007,$00070000,$00000876,$08820007,$00070000,$0000088E,$089A0007,$00070000,$000008A6,$08B20007
                Data.l $00070000,$000008BE,$08CA0007,$00070000,$000008D6,$08E20007,$00070000,$000008EE,$08FA0007,$00070000,$00000906,$09120007,$00070000,$0000091E,$092A0007,$00070000
                Data.l $00000936,$09420007,$00070000,$0000094E,$095A0007,$00070000,$00000966,$09720007,$00070000,$0000097E,$098A0007,$00070000,$00000996,$09A20007,$00070000,$000009AE
                Data.l $09BA0007,$00070000,$000009C6,$09D20007,$00070000,$000009DE,$09EA0007,$00070000,$000009F6,$0A020007,$00070000,$00000A0E,$0A1A0007,$00070000,$00000A26,$0A320007
                Data.l $00070000,$00000A3E,$0A4A0007,$00070000,$00000A56,$0A620007,$00070000,$00000A6E,$0A7A0007,$00070000,$00000A86,$0A920007,$00070000,$00000A9E,$0AAA0007,$00070000
                Data.l $00000AB6,$0AC20007,$00070000,$00000ACE,$0ADA0007,$00070000,$00000AE6,$0AF20007,$00070000,$00000AFE,$0B0A0007,$00070000,$00000B16,$0B220007,$00070000,$00000B2E
                Data.l $0B3A0007,$00070000,$00000B46,$0B520007,$00070000,$00000B5E,$0B6A0007,$00070000,$00000B76,$0B820007,$00070000,$00000B8E,$0B9A0007,$00070000,$00000BA6,$0BB20007
                Data.l $00070000,$00000BBE,$0BCA0007,$00070000,$00000BD6,$0BE20007,$00070000,$00000BEE,$0BFA0007,$00070000,$00000C06,$0C120007,$00070000,$00000C1E,$0C2A0007,$00070000
                Data.l $00000C36,$0C420007,$00070000,$00000C4E,$0C5A0007,$00070000,$00000C66,$0C720007,$00070000,$00000C7E,$0C8A0007,$00070000,$00000C96,$0CA20007,$00070000,$00000CAE
                Data.l $0CBA0007,$00070000,$00000CC6,$0CD20007,$00070000,$00000CDE,$0CEA0007,$00070000,$00000CF6,$0D020007,$00070000,$00000D0E,$0D1A0007,$00070000,$00000D26,$0D320007
                Data.l $00070000,$00000D3E,$0D4A0007,$00070000,$00000D56,$0D620007,$00070000,$00000D6E,$0D7A0007,$00070000,$00000D86,$0D920007,$00070000,$00000D9E,$0DAA0007,$00070000
                Data.l $00000DB6,$0DC20007,$00070000,$00000DCE,$0DDA0007,$00070000,$00000DE6,$0DF20007,$00070000,$00000DFE,$0E0A0007,$00070000,$00000E16,$0E220007,$00070000,$00000E2E
                Data.l $0E3A0007,$00070000,$00000E46,$0E520007,$00070000,$00000E5E,$0E6A0007,$00070000,$00000E76,$0E820007,$00070000,$00000E8E,$0E9A0007,$00070000,$00000EA6,$0EB20007
                Data.l $00070000,$00000EBE,$0ECA0007,$00070000,$00000ED6,$0EE20007,$00070000,$00000EEE,$0EFA0007,$00070000,$00000F06,$0F120007,$00070000,$00000F1E,$0F2A0007,$00070000
                Data.l $00000F36,$0F420007,$00070000,$00000F4E,$0F5A0007,$00070000,$00000F66,$0F720007,$00070000,$00000F7E,$0F8A0007,$00070000,$00000F96,$0FA20007,$00070000,$00000FAE
                Data.l $0FBA0007,$00070000,$00000FC6,$0FD20007,$00070000,$00000FDE,$0FEA0007,$00070000,$00000FF6,$10020007,$00070000,$0000100E,$101A0007,$00070000,$00001026,$10320007
                Data.l $00070000,$0000103E,$104A0007,$00070000,$00001056,$70786966,$6E69616C,$32312037,$00000000,$00000000,$00000000,$60000000,$60606060,$60600060,$D8000000,$000000D8
                Data.l $00000000,$00000000,$50F8F850,$0050F8F8,$20000000,$78A0FC78,$2078FC2C,$0C000000,$3018D8CC,$CC6C6030,$700000C0,$70D8D8F8,$74FCDCF4,$30000000,$00201030,$00000000
                Data.l $18000000,$60606030,$18306060,$60000000,$18181830,$60301818,$00000000,$F870D800,$0000D870,$00000000,$FC303000,$003030FC,$00000000,$00000000,$30300000,$00002010
                Data.l $FC000000,$000000FC,$00000000,$00000000,$30300000,$0C000000,$3018180C,$C0606030,$780000C0,$FCDCCCFC,$78FCCCEC,$30000000,$30307070,$30303030,$78000000,$3018CCFC
                Data.l $FCFCC060,$78000000,$3C388CFC,$78FC8C0C,$0C000000,$CC6C3C1C,$0C0CFCFC,$FC000000,$FCF8C0FC,$78FC8C0C,$78000000,$FCF8C4FC,$78FCCCCC,$FC000000,$30180CFC,$30303030
                Data.l $78000000,$78FCCCFC,$78FCCCCC,$78000000,$FCCCCCFC,$78FC8C7C,$00000000,$30300000,$30300000,$00000000,$30300000,$30300000,$00002010,$C0603018,$183060C0,$00000000
                Data.l $F8F80000,$00F8F800,$00000000,$183060C0,$C0603018,$78000000,$3018CCFC,$30300030,$78000000,$ACBC8484,$788680B8,$78000000,$FCCCCCFC,$CCCCCCFC,$F8000000,$FCF8CCFC
                Data.l $F8FCCCCC,$78000000,$C0C0CCFC,$78FCCCC0,$F8000000,$CCCCCCFC,$F8FCCCCC,$FC000000,$F0F0C0FC,$FCFCC0C0,$FC000000,$F0C0C0FC,$C0C0C0F0,$78000000,$DCC0CCFC,$78FCCCDC
                Data.l $CC000000,$FCFCCCCC,$CCCCCCCC,$78000000,$30303030,$78303030,$FC000000,$0C0C0CFC,$78FCCCCC,$C6000000,$E0F0D8CC,$C6CCD8F0,$C0000000,$C0C0C0C0,$FCFCC0C0,$84000000
                Data.l $CCFCFCCC,$CCCCCCCC,$8C000000,$DCFCECCC,$CCCCCCCC,$78000000,$CCCCCCFC,$78FCCCCC,$F8000000,$FCCCCCFC,$C0C0C0F8,$78000000,$CCCCCCFC,$6CF8DCEC,$F8000000,$FCCCCCFC
                Data.l $CCCCCCF8,$78000000,$7CF8C4FC,$78FCCC0C,$FC000000,$303030FC,$30303030,$CC000000,$CCCCCCCC,$78FCCCCC,$CC000000,$7878CCCC,$30303078,$CC000000,$CCCCCCCC,$84CCFCFC
                Data.l $CC000000,$3078CCCC,$CCCCCC78,$CC000000,$78CCCCCC,$30303030,$FC000000,$30180CFC,$FCFCC060,$F0000000,$C0C0C0F0,$F0F0C0C0,$C0000000,$306060C0,$0C181830,$F000000C
                Data.l $303030F0,$F0F03030,$30000000,$0084CC78,$00000000,$00000000,$00000000,$FC000000,$300000FC,$00102030,$00000000,$00000000,$0C7C7800,$7CFCCC7C,$C0000000,$CCFCF8C0
                Data.l $F8FCCCCC,$00000000,$CCFC7800,$78FCCCC0,$0C000000,$CCFC7C0C,$7CFCCCCC,$00000000,$CCFC7800,$78FCC0FC,$18000000,$30787830,$30303030,$00000000,$CCFC7C00,$8C7CFCCC
                Data.l $C00078FC,$CCFCF8C0,$CCCCCCCC,$30000000,$30300030,$30303030,$18000000,$18180018,$D8181818,$C00070F8,$F0D8CCC0,$CCD8F0E0,$30000000,$30303030,$30303030,$00000000
                Data.l $FCFCA800,$D4D4D4D4,$00000000,$ECFCD800,$CCCCCCCC,$00000000,$CCFC7800,$78FCCCCC,$00000000,$CCFCF800,$F8FCCCCC,$0000C0C0,$CCFC7C00,$7CFCCCCC,$00000C0C,$E0F8D800
                Data.l $C0C0C0C0,$00000000,$C4FC7800,$78FC8C78,$30000000,$30787830,$18383030,$00000000,$CCCCCC00,$6CFCDCCC,$00000000,$D8D8D800,$20707070,$00000000,$D4D4D400,$A8FCFCD4
                Data.l $00000000,$78CCCC00,$CCCC7830,$00000000,$CCCCCC00,$8C7CFCCC,$000078FC,$18FCFC00,$FCFC6030,$38000000,$C0606078,$38786060,$30000000,$00303030,$30303030,$E0000000
                Data.l $183030F0,$E0F03030,$74000000,$0000D8FC,$00000000,$0C000000,$EC70381C,$E07038DC,$84FC00C0,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC
                Data.l $FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC
                Data.l $84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000
                Data.l $B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC
                Data.l $FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC
                Data.l $84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000
                Data.l $B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$84FC0000,$B4B4FCCC,$FC84CCFC,$00000000,$00000000,$00000000,$30000000,$30300030,$30303030,$30000000,$CCFC7830
                Data.l $78FCCCC0,$38003030,$F0606C7C,$FCFC6060,$00000000,$FC78CC00,$78FCCCCC,$CC0000CC,$78CCCCCC,$3030FC30,$30000000,$00303030,$30303030,$7C000000,$7C38C0FC,$0C387C6C
                Data.l $CCCCF8FC,$00000000,$00000000,$78000000,$A4A4B484,$007884B4,$F8780000,$006CF8D8,$0000FCFC,$00000000,$50281400,$142850A0,$FCFC0000,$00000C0C,$00000000,$00000000
                Data.l $FC000000,$000000FC,$78000000,$B4ACBC84,$007884AC,$FCFC0000,$00000000,$00000000,$F8700000,$0070F8D8,$00000000,$30300000,$3030FCFC,$00FCFC00,$D8700000,$00F86030
                Data.l $00000000,$20F00000,$00E03060,$00000000,$60300000,$00000000,$00000000,$00000000,$CCCCCC00,$ECFCDCCC,$7C00C0C0,$74D4D4D4,$14141414,$00000000,$30000000,$00000030
                Data.l $00000000,$00000000,$00000000,$E0606030,$00F06060,$00000000,$F8700000,$0070F8D8,$0000F8F8,$00000000,$2850A000,$A0502814,$E0600000,$30186C64,$0C3CD46C,$E0600000
                Data.l $30186C64,$3C18CC78,$60F00000,$3018EC34,$0C3CD46C,$30000000,$30300030,$78FCCC60,$30600000,$FCCCFC78,$CCCCCCFC,$30180000,$FCCCFC78,$CCCCCCFC,$CC780000,$FCCCFC78
                Data.l $CCCCCCFC,$D8740000,$FCCCFC78,$CCCCCCFC,$CCCC0000,$FCCCFC78,$CCCCCCFC,$48300000,$FCCCFC78,$CCCCCCFC,$7C000000,$FCDCD8FC,$DCDCD8F8,$78000000,$C0C0CCFC,$78FCCCC0
                Data.l $30606030,$F0C0FCFC,$FCFCC0F0,$30180000,$F0C0FCFC,$FCFCC0F0,$CC780000,$F0C0FCFC,$FCFCC0F0,$00CC0000,$F0C0FCFC,$FCFCC0F0,$30600000,$30303000,$30303030,$30180000
                Data.l $30303000,$30303030,$CC780000,$30303030,$30303030,$CCCC0000,$30303030,$30303030,$78000000,$F4F4647C,$787C6464,$D8740000,$FCECCC8C,$CCCCCCDC,$30600000,$CCCCFC78
                Data.l $78FCCCCC,$30180000,$CCCCFC78,$78FCCCCC,$CC780000,$CCCCFC78,$78FCCCCC,$D8740000,$CCCCFC78,$78FCCCCC,$CCCC0000,$CCCCFC78,$78FCCCCC,$00000000,$78CC0000,$00CC7830
                Data.l $78000000,$FCDCCCFC,$78FCCCEC,$30600000,$CCCCCCCC,$78FCCCCC,$30180000,$CCCCCCCC,$78FCCCCC,$CC780000,$CCCCCC00,$78FCCCCC,$CCCC0000,$CCCCCC00,$78FCCCCC,$30180000
                Data.l $78CCCCCC,$30303030,$60F00000,$7C6C7C78,$60606078,$FC7800F0,$D8D8CCCC,$D8DCCCCC,$3060C0C0,$0C7C7800,$7CFCCC7C,$30180000,$0C7C7800,$7CFCCC7C,$CC780000,$0C7C7800
                Data.l $7CFCCC7C,$D8740000,$0C7C7800,$7CFCCC7C,$CCCC0000,$0C7C7800,$7CFCCC7C,$6C380000,$0C7C7838,$7CFCCC7C,$00000000,$34FCEC00,$ECFCB07C,$00000000,$CCFC7800,$78FCCCC0
                Data.l $30606030,$CCFC7800,$78FCC0FC,$30180000,$CCFC7800,$78FCC0FC,$CC780000,$CCFC7800,$78FCC0FC,$CCCC0000,$CCFC7800,$78FCC0FC,$C0000000,$60600060,$60606060,$60000000
                Data.l $C0C000C0,$C0C0C0C0,$78000000,$303000CC,$30303030,$CC000000,$303000CC,$30303030,$3E0C0000,$CCFC7C0C,$7CFCCCCC,$D8740000,$ECFCD800,$CCCCCCCC,$30600000,$CCFC7800
                Data.l $78FCCCCC,$30180000,$CCFC7800,$78FCCCCC,$CC780000,$CCFC7800,$78FCCCCC,$D8740000,$CCFC7800,$78FCCCCC,$CCCC0000,$CCFC7800,$78FCCCCC,$00000000,$FC003030,$303000FC
                Data.l $00000000,$DCFC7400,$B8FCECFC,$30600000,$CCCCCC00,$6CFCDCCC,$30180000,$CCCCCC00,$6CFCDCCC,$CC780000,$CCCCCC00,$6CFCDCCC,$CCCC0000,$CCCCCC00,$6CFCDCCC,$30180000
                Data.l $CCCCCC00,$8C7CFCCC,$000078FC,$7C7860F0,$60787C6C,$CCCC00F0,$CCCCCC00,$8C7CFCCC,$000078FC,$00000000,$00000000,$00000000
            C64FontEnd:
            EndDataSection
;             BytesTotal  = ?C64FontEnd - ?C64FontBeg
;             BytesLeft   = BytesTotal
;             
;             *CBM.cbmProgram 
;             *CBM = AllocateMemory(BytesLeft)            
;             
;             DataBlock = 0
;             While BytesLeft
;             
;             *CBM\l[DataBlock] = PeekL(?C64FontBeg + SizeOf(long) * DataBlock)
;             BytesLeft - SizeOf(long)
;             DataBlock + 1      
;             Wend            
            
            ; 
            ; Using Openalib. With the code above i can't avoid the High Object Number 
            OpenLibrary(0,"gdi32.dll")  
            FontID_C64CHAR           = CallFunction(0,"AddFontMemResourceEx",?C64FontBeg,?C64FontEnd-?C64FontBeg,0,@"1")    
            CloseLibrary(0)   
            Define FontA = LoadFont(#PB_Any,"Fixplain7 12",12)
            ProcedureReturn FontID(FontA)
    EndProcedure                 
                                  
EndModule

CompilerIf #PB_Compiler_IsMainFile
    
    Structure cbmProgram
       l.l[0]
   EndStructure 
   
  Procedure OnDrawItem(hWnd, lParam)
                    
        Protected  Text$ = Space(#MAX_PATH)
        
        *lpdis.DRAWITEMSTRUCT = lparam        
        
        If (*lpdis\itemID > -1 )
            
            Select *lpdis\itemAction
                Case #ODA_DRAWENTIRE               
                    
                    ;
                    ; Text Color
                    If( *lpdis\itemState & #ODS_SELECTED )
                        ;
                        ; Highlighted
                        SetTextColor_(*lpdis\hDC,$4F1920) 
                        SetBkColor_( *lpdis\hDC, $DF9DA6 );
                        hBackBrush = CreateSolidBrush_( $DF9DA6 );
                        
                    Else
                        ;
                        ; Not Highlighted
                        SetTextColor_(*lpdis\hDC,$B55D6C) 
                        SetBkColor_( *lpdis\hDC, $792731 );
                        hBackBrush = CreateSolidBrush_( $792731 );                       
                    EndIf  
                    
                    Dim itemrect.RECT(3)
                    For i = 0 To 2                                      ; Columns
                        RtlZeroMemory_(@itemrect(i),SizeOf(RECT))
                        
                        itemrect(i)\top = i
                        
                        SendMessage_(*lpdis\hwndItem, #LVM_GETSUBITEMRECT, *lpdis\itemid, @itemrect(i))
                        
                        text$ = GetGadgetItemText(GetDlgCtrlID_(*lpdis\hwndItem), *lpdis\itemid, i)
                        
                        SelectObject_(*lpdis\hDC, GetStockObject_(#NULL_PEN))
                        
                        SelectObject_(*lpdis\hDC, hBackBrush)
                        Rectangle_ (*lpdis\hDC, itemrect(i)\left, itemrect(i)\top+1, itemrect(i)\right, itemrect(i)\bottom-1)
                        TextOut_(*lpdis\hDC, itemrect(i)\left, itemrect(i)\top, text$, Len(text$))
                        
                        DeleteObject_(hBackBrush)                        
                    Next            
                Case #ODA_SELECT                    
                Case #ODA_FOCUS  
            EndSelect
        EndIf      
    EndProcedure              
  Procedure WinCallback(hWnd, uMsg, wParam, lParam) 
      
      Select uMsg              
          Case #WM_DRAWITEM
              OnDrawItem(hWnd, lParam)
          Case #WM_MEASUREITEM              
              *lpmis.MEASUREITEMSTRUCT = lparam
              *lpmis\itemheight = 12              
      EndSelect
      
    ProcedureReturn #PB_ProcessPureBasicEvents 
  EndProcedure

    Global Preview$    = "CBM Disk Image Test Modul"
    Global dsk$        = ""
    Global Charset     = 1 
    
    ; -----------------------------------------------------------------------------------------------------------------------------------------  
    ; A Few Test Programs
    ; -----------------------------------------------------------------------------------------------------------------------------------------      
    Procedure.s TestProgrammA()    
        DataSection
            C64ProgrammBeg:
		Data.l $080D0801,$209E07CE,$36303228,$00002934,$34A97800,$05A20185,$9D0842BD,$10CA002D,$00A09AF7,$2CCE32C6,$9931B108,$D0C80000,$C932A5F8,$B9EDD008,$00990848,$F7D0C801
		Data.l $0101004C,$9353A608,$2A2FB1B5,$292A2A2A,$1ABDAA07,$01188D01,$1F292FB1,$012220AA,$A401FF4C,$5879AB43,$E6293F3B,$E602D02F,$2FB16030,$91012220,$D02DE62D,$CA2EE602
		Data.l $C5F0F5D0,$EFF000A9,$EBD0FFA9,$2D912FB1,$02D02FE6,$2DE630E6,$2EE602D0,$F0EDD0CA,$017120A8,$22202FB1,$E62D9101,$E602D02D,$F5D0CA2E,$F11039C6,$39868F30,$4CAA2FB1
		Data.l $71200122,$912FB101,$D02FE62D,$E630E602,$E602D02D,$EDD0CA2E,$E91039C6,$2C01004C,$37A901DA,$20580185,$AE4C2500,$F000E0A7,$2C03A9EE,$FF8508A9,$2D912FB1,$D0FFC4C8
		Data.l $2DA518F7,$2D85FF65,$00692EA5,$00A02E85,$18E5D0CA,$FF652FA5,$30A52F85,$30850069,$B901004C,$0099EF00,$F7D0C8FF,$CE01DCCE,$DFAD01DF,$D0DFC901,$FF8060EA,$55506000
		Data.l $DF7D0050,$C0597700,$77B0665D,$0E57B0FA,$9C0D5B6C,$5B5C0167,$016B7C01,$7C016BDC,$5BFC0167,$0167FC01,$0C0157CC,$773C015F,$C35FFC55,$7C0F7FDC,$7FDC3D7C,$5500FCFF
		Data.l $D67D5455,$AC59776C,$77AC665D,$A257FCFF,$21A25B21,$5B21A267,$A26B21A2,$21A26B21,$5B21A267,$A26721A2,$21A25721,$2060A25F,$5F545577,$0F7FDCC3,$DC3D7C7C,$00FCFF7F
		Data.l $7D545555,$59776CD6,$AC665DAC,$57FCFF77,$A25B21A2,$2CA26721,$6A54555B,$9769DC65,$FC5D667C,$02CC21C2,$320C0100,$553C0100,$C35FFC55,$7C0F7FDC,$7FDC3D7C,$2FB6FCFF
		Data.l $17545515,$C31FFCF0,$7C0F1FDC,$BCFCFF1F,$55557F60,$6CD67D54,$5DAC5977,$FF77AC66,$6C03579C,$679C035B,$555B5C03,$DC656A7C,$667C9769,$FF5BFC5D,$0C0167CC,$5F0C0157
		Data.l $55753C01,$DCC35FFC,$7C7C0F7F,$FF7FDC3D,$555500FC,$6CD67D54,$5DAC5977,$FF77AC66,$6C03579C,$679C035B,$555B5C03,$DC656A7C,$667C9769,$FF5BFC5D,$0C0167CC,$5F0C0157
		Data.l $55753C01,$DCC35FFC,$7C7C0F7F,$FF7FDC3D,$008180FC,$393A3B3B,$35363738,$2E303234,$26282A2C,$1B1E2124,$0F121518,$0306090C,$06033BA2,$120F0C09,$1E1B1815,$28262421
		Data.l $302E2C2A,$36353432,$3A393837,$00C6803B,$59803821,$42413700,$47464543,$42670048,$706E4543,$4295006F,$706E4543,$442BB16F,$594C4C56,$4400654A,$4CE46A93,$00440024
		Data.l $B14CE46A,$A3554F22,$00654E25,$23A68D4F,$B57A0089,$A3525022,$00655F25,$27A65250,$7B878881,$B1487D86,$A34D5122,$00656125,$26A74D51,$8A8B7E83,$2BB17985,$5B5B5453
		Data.l $0066625D,$E4695453,$5BE4A15B,$79847823,$58573CB1,$635E5C5A,$58960064,$6C6B5C5A,$7271006D,$76757473,$8F8E9177,$38809290,$12103000,$0E051305,$09001314,$3931000E
		Data.l $D4803838,$01022600,$0E010D14,$D78020F3,$14286000,$0B0E0908,$12051720,$05042005,$03200401,$17201A0F,$0F042005,$0320140E,$0B030112,$140F0E20,$800E0908,$20FD0028
		Data.l $0512072B,$0E091405,$0F142007,$252428B0,$29282726,$3A802B2A,$A2686300,$18E8CE02,$A2AD0610,$18E88D18,$A3BDFE86,$18D68D18,$18E8ADA8,$D018A2CD,$166DBD12,$70BDFA85
		Data.l $DEFB8516,$063018AC,$4C11854C,$A6BC11A4,$C9FAB118,$C912F0FE,$A916D0FF,$18AC9D00,$9D18A69D,$6D4C18A9,$8D01A910,$964C18E9,$18E18D18,$0EF08029,$2918E1AD,$18CD9D1F
		Data.l $4C18A6FE,$E1AD106D,$B9A80A18,$FC851673,$851674B9,$9D00A9FD,$A9BC18C1,$8DFFA918,$C49D18E0,$9DFCB118,$DF8D18AF,$9D3F2918,$DF2C18AC,$FE427018,$DFAD18A9,$C8111018
		Data.l $0610FCB1,$4C18C19D,$B89D10EC,$18A9FE18,$18FCB1C8,$9D18CD7D,$B9A818B5,$DE8D14E3,$1543B918,$9918D6AC,$BB9DD401,$18DEAD18,$9DD40099,$1B4C18BE,$18E0CE11,$BD18D6AC
		Data.l $8EAA18B8,$39BD18D0,$18DC8D16,$2D1639BD,$049918E0,$9900A9D4,$FEA6D402,$AE18C79D,$33BD18D0,$D4039916,$CA9DFEA6,$18D0AE18,$A6162DBD,$18E49DFE,$BD18D0AE,$0599163F
		Data.l $1645BDD4,$A6D40699,$18DCADFE,$FE18B29D,$A9BC18A9,$C9FCB118,$A908D0FF,$18A99D00,$4C18A6FE,$D6AC14DA,$18AFBD18,$15D04029,$D018ACBD,$18B2BD10,$0499FE29,$9900A9D4
		Data.l $0699D405,$18B8BDD4,$164BB9A8,$B918D38D,$D48D1651,$1657B918,$2918D58D,$AD7AD004,$102918D5,$D3AD73D0,$BD6EF018,$072918C4,$029003C9,$D78D0749,$18B5BD18,$14E4B9A8
		Data.l $14E3F938,$B918DB8D,$43F91544,$DB6E4A15,$18D3CE18,$DA8DF710,$14E3B918,$B918D98D,$D88D1543,$18AFBD18,$09C91F29,$D7AC1C90,$16308818,$18D9AD18,$8D18DB6D,$D8AD18D9
		Data.l $18DA6D18,$4C18D88D,$D6AC1210,$18D9AD18,$ADD40099,$019918D8,$18D6ACD4,$F018C1BD,$8D7C2929,$C1BD18DD,$F0032918,$F001C956,$F0012934,$18DDAD18,$18C7BD38,$9D18DDED
		Data.l $CABD18C7,$9D00E918,$BD4C18CA,$18DDAD12,$18C7BD18,$9D18DD6D,$CABD18C7,$9D006918,$BD4C18CA,$18DDAD12,$18BEBD38,$9D18DDED,$009918BE,$18BBBDD4,$BB9D00E9,$D4019918
		Data.l $AD12BD4C,$BD1818DD,$DD6D18BE,$18BE9D18,$BDD40099,$006918BB,$9918BB9D,$D4ADD401,$BD14F018,$6D1818C7,$C79D18D4,$18CABD18,$0F290069,$BD18CA9D,$029918C7,$18CABDD4
		Data.l $ADD40399,$402918D5,$FEA611F0,$2918C4BD,$B7BDAA03,$18D6AC15,$ADD40499,$082918D5,$FEA611F0,$2918C4BD,$AFBDAA07,$18D6AC15,$ADD40399,$202918D5,$FEA618F0,$C918ACBD
		Data.l $AC0FB002,$BBBD18D6,$01691818,$9918BB9D,$DC8CD401,$18D5AD18,$46F00129,$E4BDFEA6,$0A0F2918,$1611BDAA,$BD13518D,$558D1612,$8521A913,$8516A9F8,$BDFEA6F9,$0BA018C4
		Data.l $3FB0F8D1,$F8D10AA0,$09A053B0,$3EB0F8D1,$F8D108A0,$07A047B0,$32B0F8D1,$F8D106A0,$D14C0390,$0AFEA513,$691803D0,$18DC8D01,$8A18E7AE,$D018DC2D,$6D188A33,$178D18DC
		Data.l $E606A0D4,$F8B12588,$E613CB4C,$E3AD2988,$F8711818,$E613CB4C,$AD816188,$F13818E3,$13CB4CF8,$8D18E38D,$DCACD416,$18D5AD18,$30F00229,$ACBDFEA6,$BD29F018,$1F2918AF
		Data.l $DD04E938,$1CB018AC,$BD18D6AC,$BDAA18C4,$049915BB,$15C2BDD4,$7D18FEA6,$651818B5,$14C44C41,$2918D5AD,$AD5CF010,$0F2918D3,$15C9BDAA,$BD143C8D,$3D8D15CB,$15CDBD14
		Data.l $BD14458D,$468D15CF,$BDFEA614,$C9A818C4,$AA31B010,$AC15E1BD,$049918D6,$15D1BDD4,$AD18DC8D,$102918D3,$FEA60CF0,$1818B5BD,$4C18DC6D,$DCAD14C4,$0D691818,$A9D40199
		Data.l $D4008D00,$AD14DA4C,$802918D5,$FEA624F0,$C918C4BD,$BD119001,$FE2918B2,$BDD40499,$019918BB,$14994CD4,$019948A9,$9980A9D4,$D5ADD404,$F0042918,$18D3AE3A,$8D15A3BD
		Data.l $A5BD14B8,$14B98D15,$C4BDFEA6,$AA032918,$8515ABBD,$BDFEA641,$651818B5,$E3B9A841,$18DE8D14,$AC1543B9,$019918D6,$18DEADD4,$A6D40099,$0330CAFE,$6010474C,$3E2D1C0C
		Data.l $917B6651,$FADDC3A9,$7D5A3818,$23F6CCA3,$E0BB8653,$FBB47030,$47ED9847,$E9770CA7,$F768E161,$8FDA308F,$D2EF184E,$EFD1C3C3,$1EB5601F,$A5DF319C,$DFA28687,$3C6BC13E
		Data.l $4BBE6339,$BF450C0F,$79D6837D,$977CC773,$7E8B181E,$F3AC06FA,$2EF88FE6,$02E701EC,$04E403E5,$062205E3,$6007E306,$09080843,$0B0B0A09,$0E0E0D0C,$1211100F,$17161513
		Data.l $1D1C1A19,$2523211F,$2F2C2A27,$3B383532,$4B47433F,$5E59544F,$77706A64,$968E867E,$BDB3A89F,$EEE1D4C8,$15ABA7FD,$0C000C15,$000C2AA3,$08070605,$04050607,$812240E4
		Data.l $2310E511,$A40C0020,$01E12C60,$F1D11615,$02331515,$33FE3300,$33FB33FC,$33F933FA,$118133F8,$80108040,$80108010,$80108010,$0C238010,$21AC0C00,$3E10EF81,$16211615
		Data.l $08101040,$08018004,$28201810,$003000A0,$02013030,$06050403,$29A40100,$08080308,$41110803,$2141E343,$090F0209,$FAFF260A,$01294CF9,$00010002,$00203032,$018400FF
		Data.l $10881080,$16166761,$E3F4DC93,$FDFB2316,$2316E3FF,$E3F4DC93,$18382E16,$170D1701,$176C172E,$17F417B0,$38183842,$38183818,$18382318,$2301E48C,$028A0188,$E3018C01
		Data.l $01882301,$8C01028A,$2301E301,$028B018A,$E3018C01,$018A2301,$8C01028B,$2301E301,$028B018A,$E3018C01,$018A2901,$018C018B,$E495FF01,$E4952102,$E4952102,$E4952102
		Data.l $06802202,$98B861C2,$8C049803,$FF00FF05,$FF00FF00,$050C0185,$20038518,$FF180185,$820C0285,$3A024600,$82080585,$46023A00,$820C0285,$3A024600,$82080585,$46023A00
		Data.l $270485FF,$26052705,$260B290B,$2423270B,$27052605,$26052705,$260B290B,$1B05272F,$27052705,$290B2605,$270B260B,$26052423,$27052705,$240B2605,$242F260B,$85FF1805
		Data.l $240B2404,$27052605,$27052411,$2B052905,$2605241D,$2705260B,$2C052905,$2B2F2905,$24051F05,$2605240B,$24112705,$29052705,$241D2B05,$260B2605,$2F052B05,$302F2B0B
		Data.l $85FF2405,$300B3004,$30052E05,$33053311,$2E053005,$2E05301D,$30052E0B,$35053205,$332F3205,$30052705,$2E05300B,$33113005,$30053305,$301D2E05,$2E0B2E05,$35053205
		Data.l $372F320B,$85FF2B05,$330B3304,$33053205,$37053711,$32053305,$3205331D,$3305320B,$38053505,$372F3505,$33052B05,$3205330B,$37113305,$33053705,$331D3205,$320B3205
		Data.l $3B053705,$3C2F370B,$ADFF3005,$1CD018E9,$EE18C4EE,$C6EE18C5,$8D5FA918,$3A4CD418,$AA00A910,$E818A69D,$F8D000E0,$C48D00A9,$18C58D18,$A218C68D,$18A69D02,$9D18A99D
		Data.l $B59D18AC,$F110CA18,$A918E98D,$18E78DF0,$5DBDAA60,$BDFA8516,$FB85165F,$FAB105A0,$88166D99,$5920F810,$8A00A218,$E8D4009D,$F8D018E0,$07000160,$01060D0E,$E3210303
		Data.l $85853205,$41434105,$013F2118,$07040402,$DF0C3027,$27A3C3A3,$0C030803,$A3011815,$00013031,$000C0702,$3000411A,$0001FF85,$22A20130,$118701F0,$7E4C2600,$18384C18
		Data.l $6EFC3AA8,$66667E66,$66FC00E6,$66667C66,$C67C00FC,$C6C6C0C6,$6EFC007C,$246066E3,$FE00FC6E,$60786066,$FE00FE66,$60786066,$7C00F060,$C6CEC0C6,$EE007CC6,$6C7C6C6C
		Data.l $7E00EE6C,$7E2318E5,$0CE33E00,$386C6C2D,$6C6CEE00,$EE6C6C78,$60E4E000,$00FE6626,$E4D6FEC6,$E6002BC6,$666E7E76,$7C00E666,$60C6E3EE,$007CEE25,$7C6666FC,$00F06060
		Data.l $C6C6EE7C,$067CEED6,$7C6666FC,$00F76666,$7CC0C67C,$007CC606,$18E4DBFF,$E5003C22,$7CEE23C6,$23C6E500,$E400386C,$FED62CC6,$6CEE00C6,$6C6C386C,$C6E300EE,$C6067E2E
		Data.l $CCFE007C,$C6603018,$E53C00FE,$003C2B30,$7C30120C,$00FC6230,$210CE53C,$1823A23C,$18E47E3C,$30100027,$10307F7F,$A218E4A9,$E3001822,$2360A566,$66FF6666,$006666FF
		Data.l $3C603E18,$00187C06,$180C6662,$00466630,$383C663C,$003F6667,$A5180C06,$E3180C22,$0C182530,$E3183000,$3018220C,$3C6625A2,$A3663CFF,$7E181825,$23A71818,$A3301818
		Data.l $22A97E21,$30A21818,$180C0603,$7C006030,$E6D6CECE,$78007CE6,$7E3218E5,$18CC7800,$FCCC6030,$06C67C00,$7CC6060C,$21C6E300,$3406E3FE,$C0C6FE00,$7CC606FE,$C0C67C00
		Data.l $7CC6C6FC,$0CC6FE00,$02A118E4,$29C6C67C,$C67C007C,$C6067EC6,$1821A37C,$A41821A2,$2AA21821,$0E301818,$30603018,$23A30E18,$A37E007E,$0C18702F,$70180C06,$06663C00
		Data.l $1800180C,$E3AA21A9,$97972795,$5FAABC9F,$F028C27F,$FDAA00C0,$A340FDF7,$BD2480E8,$A4605A56,$5054AA23,$A28821A2,$A40E9022,$A2208022,$0810C028,$02060608,$2702E400
		Data.l $28080101,$E3A0A0A8,$A822A2A8,$220AE42A,$21A6AAAA,$27F6E3D2,$D6F6FEFE,$E4A0A8AA,$E39821A8,$E4A0E480,$989823A8,$2295E394,$BFE59F97,$013002E3,$00020303,$95B5BDBF
		Data.l $BFBF9F97,$E57D5D55,$030025FD,$EB010103,$28BFE402,$AA9595B5,$D5FDFDFC,$AA2755E3,$0A2AA880,$28A20202,$000A2AAA,$AA545040,$AAAA25A6,$A4A95655,$29A2AA21,$2A0A0202
		Data.l $6058BFAB,$AB23A480,$94E39898,$BDBDB423,$BDBD25A8,$E3BDBDB4,$BCB422BF,$FC24BDE4,$A48020F4,$02D00A28,$10040802,$02E8A2C0,$01030324,$2902E301,$A5290A00,$9F979795
		Data.l $24BFE4BC,$0A25B5BD,$A0802AA3,$0AAAAAA8,$A0A0A82A,$952380E3,$24A40376,$3FDFB7AA,$FAAA23A4,$2796E3E6,$AA5A0A26,$A42A5F97,$E6FA7A2D,$0A269696,$5FD73602,$28A32A7F
		Data.l $959698A0,$AAAF9B96,$D7AA25A3,$A3AAFDF5,$F5D6A825,$25A3AA7D,$575FA50A,$A025A3AA,$AAFFFD5A,$E30121A3,$1AAA2955,$685A5A56,$E480A0A8,$2A0A2402,$0AE3A8AA,$E30B0922
		Data.l $2680E309,$2AA8A0A0,$26A4D80A,$80FF7FAA,$02E50820,$A6AA0022,$A8AA5722,$08208026,$A8020208,$98969527,$02082220,$2B8023A8,$6024A60A,$A4802060,$60E48021,$60204024
		Data.l $A022A5B5,$AA2CA4FA,$00D5F5BD,$028A2080,$E4AB2A0A,$98A02E80,$FDFF9698,$090925B5,$AAFF0202,$0A2860A6,$090B0B09,$02080A09,$03030101,$80020200,$C0CC4462,$80804040
		Data.l $FFC44840,$82804844,$F0F04441,$A7824144,$21A78721,$02E4A4D2,$090228A8,$97972525,$BFE4BC9F,$29A5BD24,$0040800A,$0201B660,$20100804,$5B208040,$FDA320FF,$78FD1520
		Data.l $E89AFFA2,$8ED0208E,$01A9D021,$9DD8009D,$009DD900,$DB009DDA,$8AF1D0E8,$E0E8E095,$20F9D00F,$38A91FFA,$A9D0188D,$D0228D0E,$238D06A9,$8DD8A9D0,$FEADD016,$26688D0B
		Data.l $09A900A2,$E8D8009D,$009DFAD0,$67E0E8D9,$2EA9F8D0,$00A2E785,$0F709D8A,$D078E0E8,$8532A9F8,$8D00A9EF,$1FA92605,$A926468D,$D012CD3A,$09A0FBD0,$A0FD1088,$21092101
		Data.l $B9EAEA09,$168D2A28,$2A98B9D0,$8DD0208D,$0921D021,$C0C80921,$9822F054,$03F00629,$0525874C,$6E62EAE6,$8D2A28B9,$98B9D016,$D0208D2A,$C8D0218D,$A0258D4C,$FDD08804
		Data.l $168DC8A9,$8D00A9D0,$218DD020,$A200A0D0,$28A0BD00,$BDD00099,$019928A8,$28B0BDD0,$BDD0279D,$F89D28B8,$E8C8C80F,$E1D008E0,$158DFFA9,$D01C8DD0,$108D00A9,$8D0AA9D0
		Data.l $02A9D025,$A9D0268D,$D012CDB0,$00A0FBD0,$C0BD00A2,$D0009928,$9928C8BD,$D0BDD001,$D0279D28,$9D28D8BD,$C8C80FF8,$D008E0E8,$8DFFA9E1,$1C8DD015,$8DC0A9D0,$0EA9D010
		Data.l $A9D0258D,$D0268D06,$D8A900A2,$A92A289D,$2A989D00,$D048E0E8,$E0E0A6F1,$A925F038,$2A998D03,$BD2AEB8D,$A0AA0B00,$2B00B900,$B92A289D,$989D2B10,$C0C8E82A,$E6EED00B
		Data.l $26974CE0,$E08500A9,$A926654C,$D012CDE0,$EAA5FBD0,$A9D0168D,$D012CDF0,$E5A5FBD0,$20D0168D,$E1A61FFD,$0BF028E0,$8D28E0BD,$E1E6266C,$A926CA4C,$4CE18500,$E2A626B2
		Data.l $24F018E0,$88BD00A0,$D9909928,$992868BD,$48BDDA80,$DB709928,$992828BD,$C0C8DBC0,$E6E3D028,$26FB4CE2,$E28500A9,$A626CA4C,$F0A0E0E3,$2908BD17,$BD00A0AA,$809929A8
		Data.l $C0C8E80E,$E6F4D028,$271F4CE3,$E38500A9,$A626FB4C,$F090E0ED,$BD00A01C,$A0992B20,$2BD8BD28,$188A16D0,$C8AA0569,$EBD008C0,$544CEDE6,$8500A927,$271F4CED,$592605AD
		Data.l $058D24F8,$27324C26,$90E0ECA6,$00A01CF0,$992C90BD,$48BD28C0,$8A16D02D,$AA056918,$D008C0C8,$4CECE6EB,$00A92789,$544CEC85,$2646AD27,$8D24F859,$674C2646,$27922027
		Data.l $4C27DA20,$E9A63600,$0DF008E0,$852A20BD,$E602A0EA,$FBD088E9,$8500A960,$BD00A2E9,$709D0F71,$28E0E80F,$00A0F5D0,$00C9EEB1,$978D11F0,$A5EEE60F,$4C03F0EE,$EFE62792
		Data.l $A927924C,$A9EE8500,$4CEF8532,$E4A627B6,$0DF008E0,$852A20BD,$E604A0E5,$FBD088E4,$8500A960,$BD00A2E4,$C09D0FC1,$27E0E80F,$00A0F5D0,$00C9E6B1,$E78D11F0,$A5E6E60F
		Data.l $4C03F0E6,$E7E627DA,$A927DA4C,$A9E68500,$4CE7852E,$2AA627FE,$0B0C0B0B,$0C0F0C0C,$01020F0F,$0F28010F,$0C0F0C0F,$A80C0B0C,$0E06062A,$030E0E06,$0203030E,$28010301
		Data.l $030E0303,$0E060E0E,$02022AA8,$0A0A020A,$07070A07,$01070102,$0A070728,$020A0A07,$052AA80A,$03050305,$0D030D03,$0D01020D,$0D0D3001,$03030D03,$CEE70305,$6A839CB5
		Data.l $99E83B51,$243001E8,$28272625,$742B2A29,$D8BFA68D,$E81F0AF1,$2801E8BE,$27262524,$2B2A2928,$05E40BE4,$0DE403E4,$0DE401E4,$05E403E4,$60A40BE4,$2A292877,$2E2D2C2B
		Data.l $3231302F,$36353433,$3A393837,$3E3D3C3B,$4241403F,$46454443,$4A494847,$4E4D4C4B,$4D4E4F4F,$494A4B4C,$45464748,$41424344,$3D3E3F40,$393A3B3C,$35363738,$31323334
		Data.l $2D2E2F30,$292A2B2C,$25262728,$21222324,$1D1E1F20,$191A1B1C,$15161718,$11121314,$0D0E0F10,$090A0B0C,$05060708,$01020304,$012760A2,$05040302,$09080706,$0D0C0B0A
		Data.l $11100F0E,$15141312,$19181716,$1D1C1B1A,$21201F1E,$25242322,$28802726,$2620EF00,$0D140102,$20F30E01,$28002880,$C4C5C6C7,$C0C1C2C3,$24D83B80,$D1D3D5D6,$6380D8E9
		Data.l $0C0F2300,$0D21B50B,$D3D124B4,$D7E3D6D5,$D3D5D624,$0B29A6D1,$01070F0C,$0B0C0F07,$20B860A6,$25232221,$2E2B2927,$3B373431,$4C47433F,$605B5651,$746F6A65,$88837E79
		Data.l $9C97928D,$B0ABA6A1,$C4BFBAB5,$D8D3CEC9,$ECE7E2DD,$00FBF6F1,$130F0A05,$221F1B17,$2D2B2825,$3433312F,$37373635,$33343536,$2B2D2F31,$1F222528,$0F13171B,$FB00050A
		Data.l $E7ECF1F6,$D3D8DDE2,$BFC4C9CE,$ABB0B5BA,$979CA1A6,$83888D92,$6F74797E,$5B60656A,$474C5156,$373B3F43,$2B2E3134,$23252729,$20202122,$25232221,$2E2B2927,$3B373431
		Data.l $4C47433F,$605B5651,$746F6A65,$88837E79,$9C97928D,$B0ABA6A1,$80BFBAB5,$01210034,$21002780,$005B8001,$3637B860,$31333435,$282B2D2F,$1B1F2225,$0A0F1317,$F6FB0005
		Data.l $E2E7ECF1,$CED3D8DD,$BABFC4C9,$A6ABB0B5,$92979CA1,$7E83888D,$6A6F7479,$565B6065,$43474C51,$34373B3F,$292B2E31,$22232527,$21202021,$27252322,$312E2B29,$3F3B3734
		Data.l $514C4743,$65605B56,$79746F6A,$8D88837E,$A19C9792,$B5B0ABA6,$C9C4BFBA,$DDD8D3CE,$F1ECE7E2,$0500FBF6,$17130F0A,$25221F1B,$2F2D2B28,$35343331,$36373736,$31333435
		Data.l $282B2D2F,$1B1F2225,$0A0F1317,$F6FB0005,$E2E7ECF1,$CED3D8DD,$BABFC4C9,$A6ABB0B5,$21B49CA1,$00678001,$27800121,$B3012100,$12072460,$09140505,$1420070E,$0814200F
		Data.l $20051305,$13151214,$120F1714,$20190814,$100F0510,$20E3050C,$07031323,$092520E3,$0912010B,$022420E3,$E3130F12,$0F042320,$2320E30D,$E3031401,$02062320,$2A20E312
		Data.l $05120906,$0701052D,$20E3050C,$09120425,$20E30516,$1905022C,$20040E0F,$03120F06,$3420E305,$20040E01,$050F0817,$20120516,$0F062009,$140F0712,$27802EE8,$3A80A120
		Data.l $133F2E20,$01140E19,$05202018,$120F1212,$122620FA,$19040105,$2022802E,$13191328,$30313424,$20B78230,$15132F38,$172F150C,$09021A09,$14132014,$050B0912,$03010220
		Data.l $E320E30B,$1478602E,$0814200F,$2005130F,$20190107,$12050D01,$0E010309,$08172013,$0814200F,$200B0E09,$05120517,$01050420,$0F032004,$0517201A,$0E0F0420,$12032014
		Data.l $200B0301,$08140F0E,$20070E09,$20120F06,$05172001,$17200B05,$200C0C05,$05120517,$12050820,$0E012005,$05172004,$02200512,$05141405,$08142012,$05200E01,$EB120516
		Data.l $20202B2E,$20130304,$32333235,$2C20E333,$0F050810,$2018090E,$200C090E,$01082002,$0810202C,$090E0F05,$15132018,$6020E318,$19050844,$0C0F0720,$200D150C,$14200517
		Data.l $07150F08,$01201408,$14150F02,$16050C20,$10200C05,$090B0301,$1420070E,$20130908,$01051207,$09132014,$050C070E,$0C090620,$15022005,$17200214,$05123705,$0F0F1420
		Data.l $15141320,$20040910,$12120F13,$0F072019,$602EE704,$2005171F,$140E0103,$0C0C0120,$20050220,$130E0F13,$20060F20,$20050814,$04120F0C,$20F32EE8,$204680A1,$19133F2E
		Data.l $1801140E,$12052020,$FA120F12,$05122620,$2E190401,$28202280,$24131913,$30303234,$6020EF81,$01AD2F61,$F0EFC9DC,$25794C03,$018537A9,$20FF5B20,$1520FDA3,$BD00A2FD
		Data.l $009D3627,$50E0E801,$004CF5D0,$34A97801,$00A90185,$F285F085,$F18537A9,$F38508A9,$F0B100A0,$008DF291,$F6D0C804,$F3E6F1E6,$03F0F1A5,$A901134C,$A9018537,$08008D00
		Data.l $4CA65920,$A180A7AE,$08153400,$329E07C4,$20323730,$45524227,$52454B41,$66A32721,$34A978B4,$C4A00185,$99083CB9,$83E000F8,$FDB906B0,$03339908,$A9EDD088,$A92D853E
		Data.l $4C2E85DD,$80950100,$9EDD3E01,$096EB99A,$C807E899,$02EEF7D0,$0105EE01,$EDD0F9C6,$342003A2,$C933F003,$A216D007,$03342001,$04A20AD0,$18033420,$05100769,$34200AA2
		Data.l $A5A88503,$A5A985A7,$A5F785FE,$20F885FF,$F8A5036C,$F7A5FF85,$20E8FE85,$1ED00334,$342008A2,$8402A003,$18A685A8,$A665FCA5,$FDA5F785,$F885A765,$4C036C20,$20E80113
		Data.l $1CD00334,$A88403A0,$033420E8,$08A208F0,$4C033420,$0AA2015C,$E6033420,$015C4CA7,$033420E8,$20E80AD0,$69180334,$D6D0A804,$033420E8,$02A20AD0,$18033420,$EDD00669
		Data.l $342008A2,$A9E6D003,$A4A78500,$060CF0FB,$A7262AFA,$D0CAFBC6,$4860A8F2,$FA85FEB1,$FB8508A9,$D0FEA468,$C6FFC602,$D0E7C0FE,$C0FFA4DE,$A9D8D007,$58018537,$A408114C
		Data.l $A522F0A8,$A8E538F7,$F8C603B0,$A5F78538,$B0A8E5FC,$85FDC602,$88F7B1FC,$D098FC91,$F0A9C4F8,$C6F7B10A,$C6F8C6FD,$E6EC10A9,$D800CE01,$006001C6,$A5F5080D,$3630329E
		Data.l $544D2035,$0010E743,$00A0D878,$2EC60184,$B10820CE,$0FD0992D,$2EA5F801,$EDD007C9,$2D67F806,$B92E858C,$FE990842,$F7D08800,$52A000A2,$0001004C,$C90F642B,$8117F0E2
		Data.l $BE01E62D,$EF853402,$EBD03883,$018537A9,$90FF0058,$F050D840,$C0D0C822,$0285FF0B,$0384FEB1,$918802A4,$A4FBD02D,$2DA51803,$02900265,$2D852EE6,$A9010E4C,$FFBAD0E2
		Data.l $2605FF25,$1E383FFC,$157C7308,$3E012F7F,$3E11677F,$3EFB157F,$08421008,$20603320,$FC78A87F,$6D70789C,$B078747C,$0286C3C1,$AE1C130F,$10549C78,$00D59CF8,$0092159F
		Data.l $BF17F5DB,$478A5FCF,$F195F14C,$B061E2F7,$F1E217F1,$B7F1E3B3,$35DE00E1,$DF005F00,$628F0387,$0F0351B0,$71061E21,$70785C7C,$31DC3C6D,$C8081052,$02FD8743,$FE8743D7
		Data.l $D43C008F,$00EEB081,$003207EF,$A04217EB,$20DE24FF,$ECF71880,$9031CC18,$78FF0011,$8535A9D8,$6012A901,$02A2B07C,$E8009562,$C520FBD0,$21E72021,$02322E40,$207E2C20
		Data.l $9E023D18,$7DA2CDA7,$1608E120,$30534899,$20258501,$0EF92052,$3A8C0520,$232009BF,$24BE2008,$200DC820,$775F3065,$06414C06,$D1D00F52,$05A27D86,$A13B1508,$F0AAFB06
		Data.l $B503A218,$F0F8293B,$6046E504,$8DC34633,$18EC215F,$15B76760,$906A20D0,$18EE908E,$188D48A9,$5C23780D,$54940685,$FAA25895,$332006A0,$11AE200C,$A2AF4793,$7908A011
		Data.l $6B17D320,$2632048A,$54214D7F,$AD0D2420,$F5F00D47,$7AF14F4C,$06040206,$8220ED00,$09128107,$090E0906,$AE570080,$AD25D007,$A9072E52,$B4AA8D02,$ABCE0A04,$8D18E816
		Data.l $4E5018EA,$74CE3EF0,$A84D050E,$FDD418EB,$A90D2746,$D01E7806,$A82D771D,$0AD0F029,$01534298,$06F3B9A8,$04A902D0,$1721278D,$298DD028,$772FD0D0,$ADFAD01D,$FFC91FC4
		Data.l $E5ADF3F0,$AEEE3007,$17AC0816,$0DDFC208,$BC3D10AE,$473E9812,$1103E684,$B01591C8,$F5ADB81D,$5143F007,$21D001C5,$2A504A8E,$07F6BCAA,$FEBD00A2,$DB8C9907,$990806BD
		Data.l $2998C8A0,$E0E8A807,$60EAD008,$8D151FAD,$29783873,$A0E51268,$A001BA2A,$E4A92A51,$139152A0,$04AC07A2,$065E40DC,$B9C7209D,$289D0A20,$EE1C60C7,$0004E260,$02030406
		Data.l $07030101,$013F190D,$80BADB07,$1DE080F0,$01FF2CFF,$EE0005E2,$02A50822,$82C6F9F0,$C90900F6,$1CACAD42,$DD223DF0,$F033C9F0,$01C9F331,$34AD2AF0,$9A091FA9,$1DC91E9E
		Data.l $33AD1AB0,$08DE1D0F,$3B0E3F22,$624D0A2D,$5C850F35,$6033B04C,$5BA403A2,$5F3C5EF0,$57F05930,$D046E7BD,$78EB9852,$0444842D,$4484D348,$41444845,$E53853A5,$28063D2C
		Data.l $0FC93383,$18BB2FB0,$804935A5,$8272E89D,$D018C6D5,$2CB4AD08,$F0830BF0,$CA16C986,$06D01AA9,$4C35CC4C,$4721E1CF,$9B10CA35,$2FAD037A,$BDE67C17,$B9A80AC2,$EF8D0269
		Data.l $8D28B908,$28601E20,$40030011,$4D5F0339,$5E098609,$14031A00,$15C90CF0,$18C908F0,$24718FF0,$4B12D019,$D9C91ACA,$B034C907,$09AE4C03,$100BE2CE,$7F66AD12,$3F8D3309
		Data.l $41535409,$600EAB1C,$C934A500,$BD18F021,$2A0A46E3,$75A80129,$4F79A21D,$0899B334,$D3605090,$64C70F24,$B01BC9F4,$0FE677F0,$D7BCE4D0,$3459B946,$4C18EB8D,$DE8E0E80
		Data.l $38204503,$043086FD,$C99040C9,$32C5F4C0,$DD80296A,$1CF046E3,$25DC04AD,$08224D04,$B0D06C29,$37C57DF3,$046AC3D0,$D146E79D,$6034A9A7,$D0298FAD,$4A32A5FA,$A509E08D
		Data.l $BFEA4A33,$E309EC8D,$CF2C0CCD,$2442C4BC,$20B004C9,$A904C1EE,$08C91890,$BD3414B0,$0D86E71A,$8620096A,$B40DA67D,$04A5CC32,$60AA0329,$1BC41FA2,$29091AAD,$DC1F491F
		Data.l $308EFFA2,$BD04A22C,$ADB546F7,$FC3DDC01,$A507D046,$45A11D03,$3A280385,$A91FA9E8,$7860DCBD,$A00BE2A9,$0C642840,$C40489DC,$A9D01A77,$4DFE8D33,$22FFF400,$E206E402
		Data.l $07859100,$AC0B6D20,$43ADD00F,$73400309,$8D9AA9DC,$2B004AFA,$08A9FFFB,$8D81A968,$16D4DD0D,$74486058,$532110FB,$2920609A,$AD22EE1D,$0129CB20,$14DAC304,$C4BD0AA5
		Data.l $0AA68D0A,$4E2D5F08,$0A89C840,$8221A45F,$61B50E3B,$CA273C9D,$A5F710CA,$4CA0F871,$35FB86A1,$A7028DF2,$0A440804,$440C0440,$E004400E,$0499068D,$40034401,$0B440904
		Data.l $440D0440,$E004400F,$004E5D8D,$FF006033,$8AF68C6C,$BB61A20B,$0BC8078F,$28480BAE,$98488ACE,$0A422048,$05A505E6,$3ED007C5,$18488357,$0AA80665,$1129BDAA,$BD0B3E5E
		Data.l $3F05802A,$0D31C40B,$68A868DC,$0F4068AA,$C9199FDF,$8D05859B,$06A40AC7,$8D0B24B9,$E7ADD012,$347F2904,$D0044192,$058DFF10,$0E8D1998,$834203DD,$18A91141,$A9D0168D
		Data.l $D0118D17,$A902A260,$D0188D20,$E6DD008E,$2002E604,$1020189B,$E107EA0A,$000824CF,$AFBD6A0E,$04990A46,$118408D0,$84A84A98,$BE9AAD12,$283CE339,$EB190390,$5F7C403C
		Data.l $61624A82,$AA4BFA99,$C8BD12A4,$D0299981,$AE81FABD,$7D182FA6,$11A446BB,$EED00599,$C8C88718,$B5D008C0,$06050360,$3E520A07,$1818000E,$0C780008,$808F0C89,$0CBD0C9C
		Data.l $0CC40C69,$C28E0CD7,$34B28CF8,$30F001C3,$415D640E,$C9191DD6,$0AEEB089,$B952F0A8,$642F1D21,$C022B90C,$80296505,$2A394C08,$DAD176D8,$EB4C0C77,$860C8E02,$8CCA8EA8
		Data.l $0A36B24A,$96AA1785,$AA9A1D9C,$91D72CA0,$9117A513,$0CE32015,$96F2D0CA,$E78DAA4B,$6404300C,$DF0AF093,$B0603C18,$0507A318,$D50539D4,$0CFC200C,$AE60EBBB,$ADEE0D08
		Data.l $E90009AC,$DCD20D0A,$1B263801,$A528C370,$0CF06D16,$08D2AD7D,$D00CFDEE,$0CFEEE03,$698AEF0B,$8513D024,$008C0815,$28051E14,$1685D869,$2903A560,$AA2E3810,$822D0D20
		Data.l $0A43208D,$0472AD8A,$90641049,$8D03F08A,$A2600D46,$43C57A62,$C8004E8A,$0390C912,$90CA69CA,$208F1290,$481220A9,$39490110,$4A06904A,$ABD80029,$009DD904,$DAE89DDA
		Data.l $60E1D0E8,$382F948C,$E0F0FFE9,$EE06B803,$0DA14C50,$AD0A01CE,$07290D91,$1B6C3628,$1B11A435,$8D1CB50F,$8D202DC0,$24B50DC1,$5170018D,$D004E0E8,$BCFE60E7,$E6318F91
		Data.l $907EF8A8,$0530700F,$902A0FA0,$9D00A90F,$73FF5628,$AB113072,$4586628F,$E530C685,$B02BC54A,$C7EE0BE0,$D01D77AD,$2603A2BF,$6D30AF5C,$838653BD,$2EBDA829,$2865E40F
		Data.l $85453C08,$B91C1CD5,$C8694555,$20951B85,$1AB1138C,$E98C2495,$0A031C41,$2008592E,$0E63E503,$C06946AD,$8A0E648D,$E0698EC0,$860E6C8D,$670DBC11,$782407A2,$19442039
		Data.l $E09D43E0,$CE3888C6,$A011A6F0,$16C08A00,$A61A91DC,$2A4D608B,$632A3968,$01693839,$13A9395B,$C6C40CD5,$070EA946,$D046C2F9,$2FD70525,$BD3DD017,$38100FA4,$36B1B274
		Data.l $099D06F1,$3486CF66,$3883F780,$D7BC4701,$46D3BD46,$79184A4A,$059D0EED,$46E3BD47,$47782A0A,$1908290A,$0D9D4710,$04006047,$2E730002,$FF010201,$08C0AD03,$26AD2CF0
		Data.l $2A416D18,$20542430,$1DB02EC5,$8D08E938,$2C650F33,$34AD5485,$2D65180F,$04A523DB,$694A0E29,$CBFB8D3A,$35579060,$605C850F,$35002028,$1B30AC7C,$0BA2488A,$10D01933
		Data.l $248EF568,$89B9A8BC,$12998009,$4D80603D,$68E88EE6,$8CC73A4C,$476ACD04,$2D8DD4F0,$61348886,$3662C0A0,$700AAC0F,$31C7389D,$C4F8319F,$E7A958A0,$5B0D5DAB,$0DAD118D
		Data.l $108530DD,$22574A03,$0086AE00,$B524F12E,$A0118543,$A760804D,$1704A0B9,$3E8601FA,$D82E12A9,$11A6AC3B,$A28213BD,$250E0B13,$1003638C,$008DB00E,$B0410D81,$4811A540
		Data.l $326918A8,$B99F0F8D,$468D81FA,$188EA964,$8D822C79,$FDE2D001,$9CD309C1,$04B5A009,$A08CD099,$682DDC10,$0D850A0A,$180E260A,$F2420D65,$290EA588,$1BB66901,$18DAA91A
		Data.l $548D506D,$6D80A910,$558D0580,$BD00A210,$840A61C2,$9DC84A13,$E0E8DA66,$96F0D00C,$BA42A4F0,$23282878,$ED17E1A6,$66EA8079,$ECC4EB04,$8DEABA54,$79200BC2,$8F438013
		Data.l $150F1903,$C10F0E20,$160108C1,$08142005,$8C058005,$6C060123,$51875447,$8502A978,$8535A706,$0B6D2007,$C61D0C58,$851C257B,$0110288E,$A2D0278E,$4BF88E30,$4BF98EE8
		Data.l $740148A9,$A807A9E1,$A4700F97,$842B06A2,$F9A01BA2,$2039C07E,$0BA21B38,$C383058E,$5D181B02,$A933B2F5,$79368D4C,$1B378D22,$001B0920,$5C382EFC,$10166526,$A9814223
		Data.l $232888FC,$8C58C1CC,$081881A0,$201AD120,$7727E031,$A010A206,$0D0A200E,$20A909A2,$139107A0,$A5FB1088,$2867DE13,$14A51385,$14850069,$20E72389,$19672053,$C0CE1DAC
		Data.l $D8BCC5CB,$A457C030,$A8F85950,$78556065,$F820657C,$11394C7C,$82021281,$6020E305,$A28025FD,$5111A0A4,$0B8302BF,$A2291D06,$A901A011,$18356803,$08F0168D,$D0228D0A
		Data.l $238D09A9,$20A788D0,$014C19B5,$7044BD12,$DD808839,$F1BC0D85,$8213B90E,$38F5BDA8,$4A4A0CE9,$0DA498AA,$A21B8C4C,$FA098E03,$B44EF047,$A8891F19,$090A0936,$228EAA10
		Data.l $3F0DAD12,$A01B5F20,$122CAEFF,$2E303BB5,$50452F19,$204560D3,$0BA2F7CA,$0310B717,$3C1021AF,$38B008C9,$80D70A2A,$98BB093A,$12C92B80,$17A927B0,$1918EC8D,$0B22295F
		Data.l $CA12728E,$BD664296,$0EA80387,$8E24A08D,$12A94C44,$30B510CA,$3881AD21,$8DAD1C30,$8E368414,$0A7412A5,$18958EAE,$200C169D,$FFA211E0,$A012734C,$AD00A200,$8875A836
		Data.l $42A00608,$22041A20,$1B37AD15,$38076918,$9346A1FD,$1901D923,$098404B0,$E8E30990,$C0C8F160,$60D2D005,$05C909A5,$E0C011B0,$029BF4EB,$F5B912F1,$12F28D12,$60F5E24C
		Data.l $18801379,$182512FE,$83C813C8,$5FA28382,$33FACFA0,$8D16A90C,$8D039815,$2F001816,$2518D0E7,$012962C7,$A2135D0A,$200BA00A,$EFA917D3,$80C2F916,$F7A914F0,$01AD0BBC
		Data.l $8420DDDC,$24641C12,$008D1FA9,$4CB2C4DC,$010210A4,$820C0B81,$13051207,$49120114,$0D01077F,$19282005,$20290E2F,$9E66803F,$00930700,$48200BC1,$EED9A90D,$0A432018
		Data.l $BC055020,$22258DA3,$A9D03C00,$0D188DC8,$A51D8420,$69338537,$2241207E,$A9256F20,$7C408500,$789A0818,$D0279D06,$25FA10CA,$D01CEB38,$AE606868,$2038D434,$33B0140E
		Data.l $BC3A8D8A,$2DB9A80A,$13E70B02,$8D142EB9,$C22013E8,$1CB08160,$C0BDB398,$A811301C,$759D8009,$6D189814,$11801720,$4C19E920,$96E81379,$5DBD00E1,$FFC9A814,$8CE213F0
		Data.l $CD05F03F,$0A07B111,$CD032998,$4802D0EA,$181596AB,$CD170A17,$A616AC14,$2014F615,$BA158615,$7F14E514,$0F831915,$1510148F,$14AA169D,$105E2027,$321140C7,$17770220
		Data.l $9E4827FF,$28FF1820,$09FF09E2,$0609120C,$070A0108,$A2010401,$0201B662,$06E2A7DC,$12101800,$A0C4020C,$2505A240,$8407A0D3,$7D862011,$F91011C6,$28143F92,$7931D004
		Data.l $B2820428,$300817AD,$419C6B24,$F5D9211D,$A5155007,$F0202930,$02B11C10,$021708D0,$A01B1121,$0229AA85,$098AF67D,$448BA201,$F093AD4A,$81AFA20C,$95A21517,$751B0B5E
		Data.l $A2151FEE,$6E2CA0C7,$C0F7403E,$AE3285E1,$AFA5140D,$14757D18,$F2D3328D,$8EBD0513,$AA072945,$A91532EE,$1AB7251B,$E91032C6,$0D6A2078,$AE3D7E20,$A069A211,$0C332015
		Data.l $200A1020,$475CFC24,$4CF5F00D,$0C810620,$03018209,$15100D0F,$20120514,$100F1413,$80040510,$EE200FA9,$FF089118,$C64E4750,$50F33348,$2343CF07,$C950E83C,$540BD001
		Data.l $F013C966,$F00CC9F0,$74F6ADEC,$D04D641C,$3A5EF028,$AB413031,$381A08C3,$0DB42AE9,$63AB401A,$6717CBAD,$F7ADC3AD,$A567F01E,$611F8377,$17707724,$78645AC9,$64284864
		Data.l $045480F4,$2C14A002,$A54841C5,$6C0D8531,$408C483E,$2A0D0621,$80324DD0,$81CDC848,$8033BD45,$AA680287,$8F200610,$16834C16,$CD169420,$683D1007,$383D118D,$D005A02E
		Data.l $06A06003,$BF2913B1,$E8409F93,$16AA6065,$2816ABCE,$32A50002,$02C96215,$B6AD4AD0,$0149A805,$D006D88D,$04B96434,$1708BE17,$982021A0,$1701AC17,$74F87FA5,$B9B80978
		Data.l $7B951702,$0A0A1185,$61878E09,$30B500C8,$9D46D79D,$F73246D3,$01005CA3,$C1C20921,$1119B3B4,$F20C17EE,$128D0306,$00DB3C3D,$8D0F02E9,$06A18F26,$FF1D3143,$AA2FCE95
		Data.l $6038009E,$290C9EBA,$14179927,$30A04281,$80D9A58F,$08226D4A,$E0DC044D,$3F43850B,$E8480AD0,$AA03298A,$2C534C68,$952680CF,$C415A93B,$20120120,$057B6E7F,$10178DCE
		Data.l $38BF79C2,$3FA95606,$05D03BD5,$00A9F95E,$03020060,$00100A05,$75040208,$98488A3E,$C6212A20,$E78D0206,$6214A520,$20E88D47,$22014218,$20138508,$692820E6,$A8FFC500
		Data.l $20139168,$18A9A173,$8D0C169D,$E04CAF96,$F88ECA11,$F98C8817,$17FB238C,$FF2015AD,$020B8D17,$058816F6,$18118880,$17A0F7A2,$810C334C,$0182E71A,$D0498348,$834A2802
		Data.l $4CFF2C4B,$02C04D83,$4F834ED8,$80018400,$BDD260A2,$FF491794,$8D02E92D,$484C14F5,$23C9926A,$DD03A253,$E4F0178E,$A2F85C27,$3041B50C,$CAF8010C,$06A9F610,$A96016AA
		Data.l $8D647407,$A80A0A14,$1299BCB9,$3D11AD3D,$3C321399,$0A184132,$3D149903,$2D0D33A5,$1599046E,$243A203D,$A917C520,$6014D791,$9515B143,$A204D003,$A90BF000,$0A41C401
		Data.l $8EA68295,$98106019,$0FA243F0,$48AD568E,$82A18012,$61EAC861,$89600480,$72EB1868,$26012018,$EC899A90,$103CAD18,$0DF003C9,$08304DAD,$09F1808D,$4C6E0080,$05D1F197
		Data.l $5941D418,$AE020004,$01E018ED,$E98D03F0,$40CE6018,$B668EE1F,$E2108560,$548C1410,$853F4919,$614AE30D,$0E85AA2F,$BB095FBD,$E0E8193B,$A6F5D008,$490DA50E,$23072907
		Data.l $8E400A74,$188A48F2,$4012406D,$26A2453C,$0DA94555,$68148548,$C8948DA0,$5EAE1391,$07E27619,$A6C64647,$6009A6AD,$A928A808,$438E03A2,$08C93BB5,$AEAE2EB0,$7E308A19
		Data.l $F0104608,$D02CA904,$2F1C1102,$61EA5ABD,$B0A1275B,$5CBDA827,$BDC80B2B,$0867BA5D,$1060C45D,$19B3AE0E,$F119B4AC,$06A97038,$981C0B45,$A2BD1082,$F4917710,$9EC715A5
		Data.l $11D10EE1,$D5A0E3F0,$882CAA04,$8E8560FB,$32AD3321,$2164261A,$12396412,$A248F162,$E8F2D0FF,$0A69FAB0,$1C208AA8,$48638D1A,$8DBF3C98,$48604864,$68AD0AD0,$680510B8
		Data.l $04D0F0A9,$1A31EE68,$3048F202,$0F0B8199,$8E1A9B8E,$158D6EAA,$081820D0,$20F828AE,$4D831A66,$02C902A5,$64EEFA90,$51AD0170,$E6D006C9,$8D025940,$67481A65,$862AAEBD
		Data.l $45B40290,$BD1A878D,$098545C0,$A245BABC,$84E0E804,$B908840D,$8D8560C2,$A20370EB,$0EFFA907,$19901A8E,$E026E3A4,$4908A530,$A5A8A70F,$00118A0F,$10CA08E6,$A50DE6DB
		Data.l $934F170D,$0885CAD0,$C6C3C9B4,$60B51009,$6B8303A5,$6EBCAA5C,$4E563045,$7E7995F0,$900A8AAC,$03028A9F,$45867964,$649092F2,$586D0ACC,$0F968DD1,$0CE236AD,$84003868
		Data.l $F283D002,$ADAA0069,$1DFC29F1,$108D1B34,$1B37ADD0,$A00F3900,$8DD0018D,$03002903,$2CE462A2,$15C88ECA,$548DE820,$4A1A6C1B,$BDE8A84A,$86E846A0,$1C94A20D,$0DA61B5F
		Data.l $DFD00FE0,$2AB89260,$18303868,$B3165069,$0EA51B87,$1B808E99,$460A3063,$01D10294,$D0043221,$CC5326E7,$2E1BAF80,$005181ED,$1B8B6D65,$00A20E85,$861BBABC,$65188A09
		Data.l $C63D310E,$077C901B,$09A6E860,$D009E0E8,$010060E6,$2A292802,$78525150,$06E27979,$1E1D1C1B,$012904A5,$32A3F079,$46D3FD38,$53C004B0,$0CC90169,$3C9803B0,$2C20FF60
		Data.l $CC9AAC7E,$F3F01BE8,$8D1CC6B9,$26B91C73,$2E60F987,$8D2DBA8D,$FF492DBF,$982E658D,$200FF3A3,$5C841CCA,$C487409C,$508D4569,$82695749,$AC1D518D,$BE193D11,$3F0F1E15
		Data.l $11811FBD,$5816BD40,$BDC38D58,$8D5E4317,$46C00E4D,$C2C8A884,$42CFF485,$EAE8041C,$23EEC524,$C91CC5AD,$000FF0FF,$9D88023C,$9D0C7A40,$4E4C7A41,$855F871C,$1D34A700
		Data.l $750001BD,$EC10A43C,$08A708BD,$8009BD13,$1F581485,$15E6248C,$13E6162A,$9B6802D0,$0BDD14A5,$7240E9D0,$AC800ADD,$0A544100,$B9233318,$238D8012,$8DFB8DD0,$6860D022
		Data.l $E10A35B5,$BD1CED14,$1CF1A00E,$FC154937,$32FF3711,$90E2F537,$E198787D,$2108E260,$D50D0A69,$68BDD01E,$004130A7,$C7507061,$6A0E4E40,$028DFF69,$0109AD12,$81044A44
		Data.l $728E00A0,$1D788611,$084A1391,$3F0ABDAA,$B104B028,$421462CB,$E5D004C0,$90B54D22,$A2228B04,$CC17ACFF,$793401E9,$7AD0B11D,$ECE4601D,$48386504,$7FA53A67,$C8E0AC08
		Data.l $06307BB5,$5682DD8D,$CAAA681F,$E160E410,$957FA64F,$4CB0E87B,$607F8503,$C000FF00,$681BE9AB,$F8212A20,$CA9B4A14,$8CB6B9A8,$1DE03203,$25048D20,$8D20773B,$6AEC250C
		Data.l $2D202930,$778D1DB5,$5E38B21D,$90D15F46,$850CE328,$0F298A2C,$E729AF50,$853669E8,$1903952D,$4ACD4803,$BFC34E77,$439E7885,$24561EF7,$0730231A,$F68D4005,$BE29981E
		Data.l $280A080A,$CE79856A,$2A318509,$20668D8F,$0458A92E,$2A233277,$33506AE9,$3A098923,$0F29AAA8,$D3607685,$75854A04,$292AA070,$E876A52E,$B01A2B08,$2AA52F85,$E18D1252
		Data.l $8D122E1F,$00BD1FEC,$80001508,$AD618158,$11851EF5,$0E30CE1D,$358875A4,$4A980730,$105AD0A8,$3011C604,$658A5E18,$6C138575,$76E4E80A,$20EED6D0,$1ED14CD0,$0A05E28A
		Data.l $850AE938,$E330A537,$29AE610A,$DE0710F8,$FF4953C1,$85016918,$04E2607A,$AB038F1B,$140BDE3A,$AB9D31C8,$ADFA7A01,$0329DC04,$F88D0236,$A69F461E,$3D11CD7E,$CE0C34D0
		Data.l $E08D46D8,$88001253,$EF803C20,$8D373C8A,$AABD46D3,$46D78D7E,$DF8D01A9,$4A2EA546,$4C46CF8D,$E0C01F59,$03E41D81,$AE1DB820,$080EBDD2,$9C1FC48D,$C0D22071,$5D4100BE
		Data.l $AA0B13B1,$B1081618,$F00F2915,$8B06A902,$E6E9D0A3,$A516E614,$D0DCC916,$0DA720DF,$754402A2,$1AB01469,$0180B4AD,$17AD4870,$E005A217,$17982041,$6820E81B,$4D50E78D
		Data.l $2887D929,$20E62011,$617F29A8,$8D01228E,$8DEE0816,$A6980817,$3802A40D,$6D0C1D12,$8E0D4283,$0EA5D942,$C9E20E47,$20CAD0FF,$7C12213F,$099DE011,$9D00A947,$059D4701
		Data.l $F02B9047,$3A204D8A,$AC77AD24,$43E49A08,$12A04C2C,$78A52473,$6B221C30,$E72BA5CA,$B9054BA9,$75A7471B,$7CF41088,$10D00115,$8073455D,$BCCA2AA6,$2977A514,$DB0FD002
		Data.l $BDAA0A15,$00A28072,$3099AF05,$230E2003,$1B8310AD,$AD28D003,$1DC93D11,$05C904F0,$03A21DD0,$28C82F48,$1722BDC7,$E1C72C9D,$1726AEAB,$71B00730,$F2200BA0,$DE8D36B8
		Data.l $31C92020,$E9382DA5,$3227C904,$8B8DE230,$908D0D22,$602FA50B,$C70A087F,$1402850A,$40A80D46,$0AC98D18,$66A1C721,$20EA0ACE,$2AD42241,$609B60D7,$6B60C2AD,$D020E7EE
		Data.l $20E8EE03,$21078D60,$D5EB0B8C,$66062110,$125A2BA6,$0B9C32E5,$13A59E31,$6E2028C4,$015914A5,$E44C0C63,$60DFD0CA,$080BE7E4,$293FB1A8,$07CF317F,$1940B395,$41B91302
		Data.l $A660947A,$638ECA28,$8829A421,$7E52648C,$606A8D2A,$A5217607,$21708D2B,$A2217C8D,$4C21A062,$A2810C33,$05829061,$85F82EE8,$85ACE928,$ED83EBFF,$EAD802CC,$8400EC83
		Data.l $F8E18001,$8A158513,$137140A5,$98140A20,$664A4095,$85C06915,$C53CA016,$390DE21F,$B32E8388,$05EEBD13,$A90DA55C,$D616C320,$DA366188,$D000A260,$D38D4AAA,$55298A21
		Data.l $00FF090A,$3907A0B9,$882A0D2D,$009DFA10,$E1D0E802,$8D039C96,$DC054A04,$23001C8D,$DC0E8D11,$188DC8A9,$20C30384,$01218DD0,$D025C012,$268D0FA9,$0A4320D0,$200D4820
		Data.l $31A23D72,$E8CBF88E,$A2CBF98E,$0E338E34,$A05BA91E,$3AB303A2,$CBFC9D36,$279D06A9,$F18AF860,$4C0E0320,$17041F50,$2C071032,$85E89BF1,$2E528551,$852D654B,$15272559
		Data.l $A6605A85,$84FBF05B,$080501EB,$746A0E46,$22E0803B,$78690EA5,$4822E18D,$7142467C,$2CEB53A5,$FF4920B0,$F8040169,$32334148,$A88ACB87,$F003E0E8,$D086EC2D,$9F0CD0F7
		Data.l $54902E4C,$1DB00CC9,$9F3708AA,$BB07198A,$B8E53802,$46C7B97C,$CA1D8033,$0A950430,$02A0F910,$8D000AB9,$AA9822E3,$EEEC14A9,$297840BD,$CD409DFF,$27C6E8E8,$0DE6F1C0
		Data.l $25ADE0D3,$8D404902,$26AD22E5,$FA8D2B80,$857C60CB,$850B850A,$A9C3300C,$A23A7E20,$86FFA900,$7C249D38,$9A8110E8,$0C278507,$08AF22B4,$90F3C2A8,$62C2B973,$C94C3031
		Data.l $A904D027,$A225F000,$23B0DD07,$F8B092EB,$BF640630,$13D01B69,$A509BAC9,$85014938,$D47C0F38,$029030C9,$7ED584E9,$AA4AA823,$B0468ABD,$292B8C04,$3841430F,$20983985
		Data.l $070223B7,$B3AFD0C8,$06A2180C,$2908EAB9,$708099FE,$A6F45E0D,$9529A428,$1A9C3A33,$F0D498A8,$C607BA98,$60F3840E,$213F2E2C,$8525202D,$650A0A0D,$13A5AA0D,$8D0729A8
		Data.l $29982321,$04A9A8F8,$ED8C0E85,$731ABD23,$F038A404,$603D6405,$8401B044,$60005211,$11666A38,$A0FAD088,$02E339FF,$A5C78199,$992C3911,$E8C8C789,$CC100EC6,$DC803AA5
		Data.l $603A8539,$C24B408A,$0308C198,$A900A024,$0FA972E0,$E220C1AA,$28A031E1,$D000E2A9,$C8118A04,$E3A91591,$10601391,$B3FF021E,$5CA01301,$12B94B52,$07201074,$3D13B91D
		Data.l $D03D11CD,$C814B915,$15B94109,$9842953D,$43957F80,$07115151,$A060D519,$B60D840C,$B90ADC19,$20A80042,$0A20248E,$880DA424,$E81088B9,$26898E60,$A003488C,$D06CE4CD
		Data.l $CD42B512,$E40BD0E8,$0507F00D,$4C42D607,$4DA82494,$24BCAEE1,$4CF6BDAC,$B50CA200,$6B2023B9,$41012C68,$02C91730,$700413B0,$0569E029,$5D42F538,$02B00485,$82A50690
		Data.l $F18ED33E,$3B8EC424,$25248C25,$BDAA22E2,$3E54F04D,$023E0A45,$CA20E78D,$E88D880B,$E2843020,$08138501,$2820E620,$14788169,$E21050A4,$F0AA4A05,$13F06408,$D0CA7578
		Data.l $600D85FA,$FF69181F,$0D6504E2,$4F8D1E6F,$60D6E025,$AD5C5020,$807B8DE4,$7800C304,$8A3177A9,$9DAA0FA2,$52C9D000,$CCAD60FA,$17A9FB10,$58D0118D,$15AE3840,$A284D4D0
		Data.l $B50EA007,$61990A51,$B5712600,$D0019959,$10CA8888,$87F77CEE,$03A5043B,$B9A80AB3,$0CF025BA,$B925B38D,$B28D25B9,$60C24C25,$9B3EC027,$26780031,$16A626FF,$35279550
		Data.l $C02D8629,$39279905,$E22E3029,$0F61000C,$2BF20FC8,$2A242AC1,$B51663A2,$982B622C,$000AE229,$2F3D2F10,$2F7327B1,$70052EDF,$290408F0,$EE03D003,$6D51005C,$30A8262D
		Data.l $907BD10E,$A99B340A,$02D08506,$C16C6584,$C9C50060,$8039B0EB,$568D0A12,$80559026,$A8290700,$4A4A32A5,$20AA2835,$929A0D0A,$09012982,$70BCAAFF,$F017C326,$6AF6980A
		Data.l $DD1304A0,$230A802A,$8C819B60,$32534F00,$2C41ADCC,$AD0C234E,$1C522BF6,$16F028E1,$10D022E8,$DC18C981,$90031906,$C92C6001,$67AAD020,$8E04A24C,$222084FC,$C3B7AC2F
		Data.l $865E30C3,$ABE9382E,$9FBE0ACB,$BF2978CB,$ED2A380A,$9F000BCA,$CA99047F,$EBA07B77,$CBE433A6,$0AB1E547,$072BA00A,$3032E538,$F00AC9D9,$ADD3B002,$CED01EF7,$CA3078A5
		Data.l $3A507724,$100FFC19,$26EA4C45,$A5276620,$57248531,$28100981,$2A0D0604,$32BDAA0A,$9E2A0880,$BCF1258D,$088C8033,$03A26028,$7B95FFA9,$4CDC41CA,$16CA0D48,$589E38C0
		Data.l $F0FFC940,$7907B3A9,$5D09061D,$338537A5,$E01EF94C,$609F118E,$ED085C78,$1B3A1620,$A8032987,$8D27BFB9,$FED027BD,$0D360060,$FB10F000,$07080405,$2478300B,$111B79C4
		Data.l $20DA1028,$C3A90FCA,$1EE703C2,$4C020782,$35A52860,$85A82A0A,$C5337888,$A55AD037,$F08FAA77,$D4708A28,$C3991ADC,$87BCAA27,$A639100C,$A933A432,$24F22000,$4FADBE4F
		Data.l $502D6025,$11A4119B,$C73903A5,$C70DF027,$27C57971,$24A954E7,$10AD05E9,$F8D002CA,$20C952C0,$01A9F1D0,$B95E0A8D,$1DC93269,$1DCD3D90,$2FC5F829,$7C056BD0,$998730A6
		Data.l $13999D8C,$9B2FEDA9,$9B1FD00F,$0668290D,$4C274020,$15AD28C0,$7A65185E,$A83D118D,$7F293FB1,$1DB82098,$E9382FA5,$66DDA020,$C7ADFE0E,$F004390A,$08184CF9,$F14BDB55
		Data.l $CB2946CD,$6332A541,$8F203285,$317D4882,$09FC2929,$7F868502,$D522418F,$F50F6990,$AD293019,$337D189F,$103A0129,$9A74A904,$05F4C906,$292F5D20,$04000560,$15FF01FC
		Data.l $A202D067,$7CFF2DFB,$2904A586,$2029D001,$DE2A262E,$A151A877,$299805F0,$AE19F008,$90BD5708,$ADA3B029,$03C9091D,$03A50CD0,$06D034C5,$1222ABE3,$1018D1CE,$977950F5
		Data.l $8D00A929,$3485298F,$EF240060,$0C0D0E80,$90E50601,$7167D0C3,$6B29D7C6,$1823C2B1,$BD032968,$9F0C39C4,$668F16C4,$147CF038,$35052AAE,$44333732,$D02AB7BD,$4C615408
		Data.l $A5482A61,$528D7B5A,$4852A53A,$1F676872,$D910030C,$02A18D08,$AD25B44C,$820E2AC0,$F3C71EC6,$F3C702C2,$208711C2,$0D0C010A,$2620E31F,$9E2F0D1F,$07E30600,$00062760
		Data.l $600FFC09,$4D21C3B0,$374000A7,$C63C5344,$1205A9D0,$74470E9D,$0CA7F4C6,$10470F2A,$FEFFF0ED,$FC22A2FC,$6E64C2FE,$1C1B1A01,$1B1C1D1D,$ED091A1A,$40785052,$AAE0E422
		Data.l $86852B57,$2CBDCEAE,$6518CD07,$0CF0CD55,$01A92195,$63171172,$0A59CE52,$BC140A10,$00358D09,$C92B61C1,$C904F004,$C638D005,$7C098B85,$1110E784,$47846E0E,$07008473
		Data.l $438126B7,$E11E6CB8,$0BE20F1D,$1EE21F33,$1C19E21C,$DE29E962,$AE29FEF0,$2AE938F0,$F8A704AE,$B8A706C3,$28B623CC,$EE290CDE,$DA0006F0,$3BE3C283,$14F5ADA9,$F0B94093
		Data.l $00D28D2B,$2A6D18D0,$EA48AA0D,$4736BD4E,$29B78009,$44BDAA68,$34F01647,$1FF08886,$D00B3AAD,$C88C921A,$300F338D,$B4348DD7,$358D0208,$D80FA90F,$B251A5AB,$A553850C
		Data.l $015B8559,$CE225E3E,$081031DC,$10383647,$08508D05,$D02CB410,$2CB3ADFA,$F3D001C9,$3844DC8C,$2D255B6A,$64052642,$202642D3,$1CB00FC9,$E53853A5,$9415902C,$FD380787
		Data.l $0C3046CF,$08B00DC9,$EC8D10A9,$35CC4C18,$60CA10CA,$0FE0C2CE,$AAAD0610,$2D858D16,$06A90260,$8D0CAB94,$2021E617,$10840208,$8C68C136,$D0A336C6,$02A84635,$6A1D46F0
		Data.l $49BA83CE,$09BA65FF,$E17A6507,$A50163E2,$230D9770,$2300E1DA,$F0CF0A3A,$8180C605,$80F82256,$BE8C78D6,$2ED14CC7,$78CD02A9,$03F072F0,$FD2D8D4C,$C808A300,$074B3381
		Data.l $32C50E52,$40DC30B0,$04B5AE3F,$1C0044EE,$06D00729,$8DF8298A,$A000B867,$E41C51A3,$E91EF920,$8537A532,$A652DC33,$A933A432,$AD5BD480,$0810254F,$32E601B2,$0D58C74C
		Data.l $2EC68D7A,$6EE133A5,$2BC506AD,$01E90290,$C4290FC1,$65184A03,$037D4C28,$0D0A20AA,$0149889D,$00A02B0B,$2ADD13B1,$8AC4D080,$038DC45F,$5D4B23A9,$D02D7920,$3075CEFA
		Data.l $C7750717,$530B0881,$0CB92EFE,$2EFF8D2F,$A94FBC20,$2F0F8D06,$4C25B420,$2DDD2EFD,$8BA22E80,$FFA926C5,$BDE15657,$BD774752,$5A6B4862,$6E196B3B,$31D00129,$08AD6065
		Data.l $D01BC949,$18E0200C,$CE4E1B6F,$A916D08D,$2F6C8D1B,$34B57001,$A9298F8D,$A9906904,$60AF8A0B,$8004FD1B,$0349059D,$FFA0F2D0,$AC53B0B9,$0D8C20A4,$AA3B008D,$8210A2C4
		Data.l $32D96D24,$A43073BD,$212C6BBD,$2F7AAC40,$D9476AAD,$C1D02F71,$852F6FB9,$1833A535,$33850869,$8023C172,$8522A949,$2F140934,$28ED4C29,$99C135A5,$4A32A5D4,$EA590729
		Data.l $7918482F,$9DE62FE8,$4120477B,$35056822,$C82FEC4C,$29AA0055,$8400A07F,$13664A13,$1485E069,$A00B308A,$E513B17E,$F8104EFB,$8D13A560,$2A170621,$30340390,$228D14A5
		Data.l $30902B16,$7CA03035,$270D9894,$C8868E61,$00BDAABE,$A50E8502,$41B80A0D,$0EA58888,$98CC4099,$E201EBC3,$CE108804,$E3782460,$5C160D10,$18048C03,$26F7602D,$D05D308D
		Data.l $20249B09,$1652D08F,$8B4CCD3D,$30CEB930,$8E308C8D,$FF20308E,$FF33F301,$9560C931,$FCE6215D,$13BC9D3C,$952C5810,$1E150F55,$0A3C5599,$7F909910,$99A31D40,$2D65445B
		Data.l $BD005D99,$2B9905A7,$609BACD0,$02320686,$B6A83270,$F7068037,$AC36D73A,$3FB13D11,$34A5E630,$E0F026C9,$30B3ACAD,$E2FFA0DB,$05D0A434,$C599C88A,$8CF380F2,$AE002133
		Data.l $ACC1D00F,$BC3006F5,$243D10AD,$312080EF,$FF0944DA,$D73DBDAA,$3A8F8DA7,$AA032980,$BD312BEE,$F0227808,$988A4895,$334E10DB,$ADD06A42,$05C931C7,$01C032B0,$A6AC7690
		Data.l $EE71D09C,$864B00C8,$06F7AD11,$9A482772,$68938C9C,$00D0379D,$11A6B806,$9A4C36A8,$A8BC6C31,$A93909C1,$0A8027DE,$3D06B962,$37A5F49D,$CE4880A7,$AFC91EF8,$06F0324C
		Data.l $4C9868A8,$306831AD,$7E44BBB9,$89310741,$33906906,$EB39059D,$60A26007,$FFA9A797,$70356E9D,$17252FFA,$ECAA38EA,$08460084,$3A8D323C,$F002556B,$8A00A20F,$F0EC37A4
		Data.l $29051015,$05C18D2A,$2829A803,$800F5CF0,$79A50CD0,$F6AE0830,$8D035B8B,$1020323B,$FDA914F0,$A50ED040,$AE9EC678,$05D01EF7,$3C8D0A0A,$8AE71832,$0782D9FF,$E2030306
		Data.l $08090504,$05E20502,$001502E6,$46DFBC15,$13C20A30,$99212499,$207A0127,$9D30A97A,$BD60CBFC,$C80AEF80,$82149284,$3285B932,$4C32838D,$ADC562C2,$7533CB34,$E3349335
		Data.l $4435E033,$D8331036,$082587E0,$EFDE04F0,$82820830,$37F007DD,$D20B6C98,$21220482,$4A32D38E,$589BA03F,$E83239B9,$98880A46,$A1A824BA,$A26913F1,$DD7B9DFF,$86E00F92
		Data.l $01C905C8,$17ADFBD0,$F4D0FFC9,$168D7701,$8D3D11A9,$80AD3D17,$188D4A37,$A237A53D,$046918B7,$203D198D,$734C243A,$B1F96424,$73503A03,$65784ADD,$52791808,$47A80C21
		Data.l $868C4BDC,$B503A211,$F03FC93B,$CA3BF602,$EF40F510,$E2335487,$A901FF5B,$4EAC4208,$133C1D33,$0B94A828,$9D07A9D8,$8A300AB5,$33A0B906,$B9337B4C,$0F8F3398,$103394DE
		Data.l $3390BC0C,$56BC55F0,$E6D19832,$0B000AE2,$0C07720C,$0807680B,$07081080,$80A68C80,$08760609,$2201A90C,$900580CF,$0A866CAF,$AE30A527,$C3AC1D23,$5B8500A9,$8E4086A4
		Data.l $0A01E938,$A87B1D0A,$023463B9,$BD10C7EF,$BD3033DF,$3BC9990D,$0960C45E,$B9686DFB,$EA8D3459,$3450B918,$AB78E030,$C533A50E,$ABE4D037,$690CD870,$32E53809,$15C9D130
		Data.l $21A9CDB0,$08CE7F85,$80208502,$7D864C08,$4128FE08,$FF00FF86,$030A0609,$0A70801B,$C81A0508,$08080920,$09088130,$A0E2460A,$818C818E,$04050504,$20627A52,$DBFEB642
		Data.l $94A602A9,$EF0BD003,$377E3845,$0B40C036,$274EA702,$65254A09,$10D03F07,$F0B2C2C3,$2A8203D0,$6CE38494,$F1433C5C,$27A8A1B0,$1D217F67,$1105228A,$B93D10AC,$12107EAA
		Data.l $076F778A,$7235225F,$145045F1,$2FEA5948,$14104E70,$60D910B3,$F00779F8,$D009C004,$4C11A605,$6BB935CC,$D877F3E5,$32826C02,$FCFAEEE0,$05E2FAFA,$30CFE0FB,$3649733A
		Data.l $71C6958E,$41B878A5,$A5661CD8,$46D7BC37,$039005C0,$382CFC5B,$C2C98AAE,$82DCB8B0,$A9B0CCB9,$A95EAB05,$183A9D0F,$E34935A5,$33BA4C0A,$9B35F38E,$FFA20F4C,$DF0D30A8
		Data.l $E53308E2,$40DE9E00,$BD081036,$421EE38F,$36650C0D,$B0E18AAF,$604B8A06,$A6092BA7,$0C7A602B,$2012B8C6,$694F3611,$8A940243,$D6780ADD,$C8FE03D7,$32561435,$044CFE02
		Data.l $07EE0436,$C1F05131,$ED1EA807,$0103BEC7,$034745FB,$8E670AD0,$4A1636C6,$881C9191,$54430462,$A0A9F080,$2005D010,$15330E80,$61B3142C,$377E4C00,$A2EE0404,$996002E3
		Data.l $04E20477,$620101FF,$8B041607,$880A2985,$36CEBDCE,$7336E18D,$8000E7BD,$4A42329F,$4CE13E13,$F0933319,$2EE8DE06,$704C9A36,$3FE01EB7,$B02FC515,$4C1BFEEE,$D7188744
		Data.l $06D00944,$4C0EAB20,$78863755,$6A32C557,$DDDD8029,$6B443BF0,$E6044C68,$AD2CD0B4,$222DDC04,$B51C3408,$10C9E122,$3B2DC690,$A515F010,$9CEA4A2F,$150AFD38,$B01B022E
		Data.l $A28C1F22,$088C5A22,$085237A4,$E5205983,$09662F36,$80190201,$5462A204,$260B2C60,$E2000700,$AD075070,$37C08D37,$104C1D6E,$F004A933,$0134F44A,$30A621C0,$8C880ACE
		Data.l $4C2334F6,$B5F13493,$14689040,$0A188F8F,$D006A9A0,$C5FAA902,$59329648,$713B0256,$825302C1,$20186A86,$2B50A1C2,$2003D007,$49048F9D,$11842980,$DD32A588,$44119017
		Data.l $1530C810,$15B008C0,$4CC88705,$54BC3862,$C0041088,$980490F8,$64543E10,$33C510A4,$03490C27,$5279010C,$6525D433,$5FD00790,$387D2C19,$0E0B101E,$16902EC5,$1C1C2EA5
		Data.l $36C0383A,$09A62016,$7A298A39,$7DCED8C3,$C9C58079,$C5139015,$A91B902F,$A581D78A,$42F1032F,$A911D02C,$390D9D02,$58A53C14,$15E90580,$03CA2D9B,$A0E21DD0,$C42B18D0
		Data.l $32AA11B9,$040C0643,$887A08C9,$076004B0,$36152F01,$4C010203,$8005771D,$1B4CAE17,$D9D90460,$EFD900DC,$00E27EE0,$36474C94,$B92A54BC,$A23FD025,$390AFED4,$74610618
		Data.l $B528D0CE,$13308B13,$2F1C1597,$377E2039,$C80ADEBC,$029028C0,$8DC000A0,$6E4D4A21,$3E4361E0,$00ABA379,$39B7B9A0,$7160B06C,$FEFDFCFB,$1DA800FF,$2105030A,$0403029E
		Data.l $00050DE2,$2BE20201,$DD53DFC8,$39E0B939,$2039DE8D,$008D057C,$3B353AE1,$39F13A1A,$F1C02BE1,$4C78E21E,$018935E0,$21D00CF0,$022977A5,$564C03F0,$3AA64C32,$D0ABFCB4
		Data.l $8C1BA005,$08C918EB,$50B016F0,$67E84A4A,$55E15505,$60254120,$08465481,$A83AF518,$B9C0207E,$23AC0203,$8FAC5C08,$A47ED029,$212B7ABC,$32E53805,$0CC97230,$37C66EB0
		Data.l $18EC3F0A,$C80839BD,$B2A84A04,$5998AA21,$FE8F9008,$3C43BD86,$85A804C0,$37C515C2,$99863D90,$11A6343F,$0033B020,$10448438,$7C789FA8,$3090ECA8,$C777A910,$550435C8
		Data.l $4C53408C,$439D98C3,$37A56008,$48DD15B6,$A907F0B4,$39059D09,$CB4C88D0,$BD02FE33,$A80A73D0,$09B00BB9,$3B0CB93B,$B8000A8D,$574861C2,$753B1D3B,$E33B3535,$4435E033
		Data.l $7E331036,$86769E33,$C906A322,$D03FF0A8,$6860CB25,$A905E21C,$6AFEBB07,$34A9BD04,$9D0BD08C,$499F09E7,$60A8B280,$4B08D820,$45F682CC,$AA2A0A7A,$28E9A811,$693CFA4E
		Data.l $900CC90C,$B02EC50D,$0CE93809,$4C39969D,$B9823B86,$01290614,$50139DD0,$2FEA594A,$73F00329,$D3BC0E86,$BD96BB46,$68AA46CF,$A624F220,$254FF7C5,$4C600110,$03A03487
		Data.l $12C46F8D,$93F710F0,$7190430B,$E6CF2311,$05BD03A2,$F00E30EA,$1048E00C,$90A78A07,$EA450B30,$D299782A,$A5F81088,$A8022904,$045C408D,$DF0A328C,$80BC2A85,$B41A4C52
		Data.l $A46A9848,$0A911E48,$011D9F68,$549D68A8,$07224C98,$ACF0F8B8,$BEC83C57,$BD0F26F3,$0A300F20,$1846D7BC,$203CF079,$BAE53C59,$664A2200,$5329D013,$13981485,$3669188A
		Data.l $BCCBFC9D,$E3BD3CDC,$1A193046,$E78763FD,$03E78823,$6C052164,$F6141A88,$006BA960,$13A5E00A,$B18DC029,$8D14A53C,$02A23CB2,$A1AD0E84,$406D0A3E,$C2B9A829,$C872953B
		Data.l $0EA4C9C0,$83CA72A6,$73039C80,$CD81C839,$00BD74A6,$CD829902,$316088E3,$103CE0CE,$7E3E60C9,$FDA9EFBE,$DFEFF7FB,$02017FBF,$20100804,$1A008040,$71684E34,$FF8C837A
		Data.l $09060001,$0E010408,$00060202,$6104E307,$0205E212,$60E20101,$BD5FA200,$129D807A,$B787313D,$8D4A13F7,$268D1BE8,$8CA1029D,$7A284074,$C68E888A,$3FC92001,$3F2923F0
		Data.l $2A213220,$BD05A07E,$51AA7D70,$8AC8C423,$1140294A,$AE139113,$D0E83EDE,$D5CEE8D3,$A9C4D00D,$20AFD003,$C1A91BE9,$08E011A2,$A019A2B4,$17982021,$618D27A9,$BD17A214
		Data.l $290274F1,$14759D7F,$A911F5E5,$1A32A62F,$8D17178D,$7840151F,$16AB8D14,$A907F58D,$16AA8D02,$01A903A2,$46DB3274,$9D6C7B95,$3FA946D7,$AEBD3B95,$7EA65E21,$9D7EB2BD
		Data.l $1C207EAA,$A082A2E1,$026E203E,$18A90BF8,$CA0C169D,$0AA9FA10,$730E118D,$3D108D82,$358500A9,$A9262D8D,$476A8D06,$348525A9,$EA8D13A9,$85EBA918,$8534A933,$4C0FA932
		Data.l $778E2FEC,$3E788C3E,$BABD00A2,$4D9D67F0,$80C9E884,$0960F5D0,$31CA130E,$044A0360,$E30B1309,$8098612E,$0FB8B202,$830FDCB8,$82060202,$21420412,$420814E0,$84073D0E
		Data.l $653D1325,$0C132005,$0C102005,$03801901,$15100D0F,$200BCE14,$05100F20,$09140112,$0C010E0F,$4BA08021,$78BF0047,$ED7C47E8,$7984BC7A,$2C78C45C,$C4147864,$01A11CF1
		Data.l $C37EF3FF,$C399A199,$6E388FC3,$8266FEE8,$FCAD60BA,$323E2B51,$D8A3E16E,$D8EC3AEC,$F8E20EAC,$786062FE,$2CE06060,$0CC01538,$81083C66,$66667E66,$5A07B5E7,$4C5A1882
		Data.l $0C0E1068,$CEE678CC,$80DCF8DC,$44E00015,$6942C6C0,$40D6FE40,$E612EE13,$4D65DEF6,$D005D2E6,$E60E14AC,$0E79C0DC,$0776DED0,$C61651DC,$7C1BCCFC,$067CC0C2,$B2A70B86
		Data.l $02605237,$AD042006,$0641CDE6,$8366EC00,$006CD635,$6C700477,$CE00A020,$30386CC6,$FEC9C030,$62AFC986,$FF0DE2A1,$020814B4,$03FF0070,$AAF3FF03,$EECB09E2,$04A2DB0B
		Data.l $BC846C0E,$367F3610,$D97E30E8,$549B1B7E,$C6666300,$48633386,$67186C66,$3B8C3D66,$5C324A32,$0498A0C0,$4A29A84E,$FF3CDB18,$2E98DB3C,$C8021E7E,$CF0ADE2C,$E8B1667E
		Data.l $CB2103CA,$CE0703B0,$28B3E6D6,$3C184066,$721C0E90,$25E4FEC0,$1C22E71E,$FECC6C3C,$3F830C0C,$8106C8C0,$FC703C1C,$FEC51574,$1C0C0EC6,$F0033818,$8A3C669B,$E37C007C
		Data.l $1C7E2BC6,$C1F88078,$0085101C,$A360A284,$0D146481,$40100745,$6098807E,$07741830,$3C006030,$180C0666,$E3C61800,$0A323E26,$7F7F0F8A,$31A900A2,$09020A0A,$7F8F0802
		Data.l $A17F0F19,$20A3028E,$0801235C,$0DAA6008,$5B808438,$0F2B0303,$CE0608E2,$343C2305,$40001434,$4C3887C0,$5ED6D428,$0B2DD55B,$55D79E00,$DFA65F57,$BC2C00FC,$FDFDF7FE
		Data.l $6015E0C6,$547449D8,$3FBFBF74,$800B0D3F,$705858B8,$2A80C070,$36050D6B,$08261818,$575C70C0,$D5351595,$5074CD06,$003F3C3E,$E3FE563F,$001F60F0,$3B03D3F0,$072F3F2F
		Data.l $B0303033,$40E0F0E0,$16252930,$07042417,$5060A005,$40E36050,$FC1E0D61,$9D173625,$9C108D59,$F4E4D494,$0E0658D4,$04CCC4C6,$E4ACC0C8,$9848C46C,$498C3E0D,$FB0AF00E
		Data.l $1828FB08,$029C800F,$08EB20EF,$EF4D14FF,$CC20AFA0,$010201F5,$3A282A16,$C1408040,$0124281C,$BCCE0248,$803CEE2B,$00A89480,$0600AAAA,$0480C7A0,$1E340068,$96A45070
		Data.l $1A040615,$02020828,$056D5900,$526F7A85,$050101A8,$11191406,$1040C068,$B6645458,$0921A217,$56030905,$E81623F8,$95A54BBE,$06E13C36,$01950B02,$0038A008,$D525000C
		Data.l $00282921,$26219916,$990F2306,$3F3B3B07,$0CBCF20C,$FFCB033F,$28230FCC,$002903D0,$0AF2BE29,$26007E78,$828A52C0,$2814058C,$960F4B28,$964044A7,$62863C40,$06E71420
		Data.l $00EA05A9,$52DB506A,$C3A838C3,$10C328A2,$FC39FC03,$1A3F4A68,$A2463F89,$00C38828,$F02F2FC3,$A2C47878,$2C42D960,$EFB0805C,$7707B7D7,$4A6A772D,$B79D9B7F,$823C1F6F
		Data.l $88021C0F,$E4477629,$C4878004,$8A1A418F,$5FEFEF18,$219FAF8B,$0FC94007,$7457A7B7,$314F97B7,$48DAD012,$8AF0687F,$2B999709,$BA64C7D0,$C3DF871F,$9E20B7BF,$5F6F6F42
		Data.l $5777773F,$CCB76F27,$776FAF38,$7F1201AF,$0F58EF87,$22144881,$03D10CD0,$9FB2FF38,$1F3C42BF,$49FF54E8,$2440CC06,$9FDF0877,$861FBFDF,$540FBF12,$9F67CF0E,$07AFD7E7
		Data.l $E7C48FDF,$275F21C0,$BFCFF787,$8F09417F,$C7B7CF84,$28009F6F,$C8A07850,$684018F0,$08E0B890,$A8805830,$4820F8D0,$80C09870,$1D005F07,$07E20106,$9F017A02,$07060470
		Data.l $E3AB0505,$74456003,$5C730702,$0A330181,$E70D01FF,$060B040E,$0E040B06,$010D0305,$10DCC280,$7FAA9E08,$F7EFDFBF,$C6FEFDFB,$04ECDACE,$45F9E02A,$0A0B4646,$702B0608
		Data.l $8205030E,$35001712,$900F087F,$09FF60A2,$281C0B00,$11001F02,$3FE3652C,$16361E41,$0041006F,$3300340A,$7F000280,$0A832068,$8100C942,$0002A4DC,$00620012,$01E300EA
		Data.l $90030BF3,$08008D82,$FF0FFF07,$310C7B0E,$01098E10,$C0010B30,$8503C400,$8701AC07,$C71F870F,$04503C1F,$46C1483F,$887F0400,$E1CFF375,$C001C083,$0D6003C1,$031B0A06
		Data.l $0E0E0A06,$12282D09,$0D280904,$0A07B641,$AA490B88,$82889A36,$46600801,$35545556,$55543434,$4C555565,$144C0720,$062C4C05,$58042040,$06C10820,$3420907F,$38248C78
		Data.l $4E568874,$35CB564E,$9E9E9676,$F0FCFF96,$0F3FFFC0,$A00CE203,$00880823,$15451780,$C62E6002,$FDFBFE62,$8002BFBF,$E2048010,$32EBCB08,$3727FFA4,$170717FF,$EEED2727
		Data.l $EEEFEE4A,$021060ED,$02040072,$05E34660,$A9014E60,$2021618D,$19192007,$15161718,$2D1904C2,$80A70040,$A44690E9,$0B0A4400,$0731078A,$09080645,$89080980,$17C58900
		Data.l $8070040A,$01013801,$002004A8,$04050A4B,$0B06D5B8,$01C0286B,$0DFC411F,$5F82BE06,$FE4F60C3,$0397813E,$7ABEBC05,$3CC25E3D,$163C622E,$E20A3C32,$FF082838,$8B760CA4
		Data.l $CAF1080C,$0C138092,$2D845180,$6432409B,$2623FAC0,$09009000,$4A561D37,$FF3FA041,$042813C0,$72E0620A,$0020E064,$0022E240,$68A24AE3,$531514FC,$35D24614,$45395115
		Data.l $30143D13,$2F90245D,$152F5112,$0A001752,$AFCF3F1B,$00DF8F28,$0600FB0F,$FEF05EFF,$48BF7970,$67157FBF,$159B5726,$11308755,$744E1529,$3315C815,$34F79942,$5454C515
		Data.l $165734D9,$14191754,$5F54D853,$194FD416,$54587F94,$7978363C,$FD94593C,$1474F194,$75F47C71,$73553057,$BC2E537C,$010004E2,$BF15906F,$E0FB16E5,$5780FB17,$20BD67E6
		Data.l $CF00F9EF,$00A55539,$6740E666,$F95790F6,$6FB95AA5,$15AFBD59,$BE556FFE,$BFBF55AF,$C505F06E,$FF6F0C13,$46FB5AAA,$054086C1,$02200D23,$2039222D,$0054B902,$54E90226
		Data.l $56545A57,$A37C20A7,$D5591595,$1F90E42C,$10791175,$08299D01,$0E2B6555,$D4E0040D,$15F47F15,$57505457,$57174A55,$85AA551E,$30B0A645,$6BF0D1A6,$1369A5A2,$66956700
		Data.l $1D230B62,$15731C56,$5A15A46A,$3888FED8,$8EC358E8,$A184880E,$40A94555,$77E0B832,$14AA3AD4,$6688DEA9,$7BC6A86A,$288658C2,$C383F886,$57740083,$6A4255FF,$2A10A054
		Data.l $70304205,$D8A25541,$0A687470,$4188C4DC,$10446404,$828A0440,$40054604,$44444504,$00040040,$1F1AFB79,$A018986A,$042810C8,$6695828A,$40A0A361,$59046866,$83B0A044
		Data.l $367F6956,$40165959,$A80DA006,$8B886AAA,$C4170017,$64F1EEF0,$3F7C153C,$065F3155,$969AA378,$974C20F7,$54677C45,$4317547F,$D05F5510,$17C05F14,$1714F313,$D45E0DA4
		Data.l $44440440,$51F64071,$404F483F,$28E45006,$4E2950A6,$17A895AA,$A204E290,$26002002,$4C269698,$469691A0,$9BB6969E,$AA95E696,$E296AA56,$06E2AA07,$51C1FBEC,$345FBC53
		Data.l $15E57F26,$F956E9BE,$C5F916ED,$11CCF46B,$D4FE7DE4,$F4FF2110,$05F4FE6D,$AA79D0FA,$A4F393B4,$22501515,$41088450,$00744EC8,$D1724760,$0580D135,$DD0D1511,$343300D5
		Data.l $FF4F1503,$48ED36F0,$75D5B53F,$D5D570B5,$FD003E07,$41853519,$1F2F3CEB,$31156A1E,$5703001A,$006902C0,$01780C03,$99BA57F7,$8470B29C,$E1801822,$38C30F0A,$F5C0C1FA
		Data.l $15AD5755,$5DF80151,$6299B558,$6567A911,$55BA88A5,$A6652262,$8988A96A,$A9299209,$65F3C190,$00D89999,$233456A0,$1D2555B0,$94649555,$511453AB,$55484555,$99005621
		Data.l $6A95AA66,$5559A955,$287F5F65,$029A6F16,$6AA1FA7F,$E05A55A5,$44016020,$46546152,$06422552,$695AD2A9,$A7A55655,$C4C0603D,$95D05021,$96255465,$C0C9EA55,$95227AF0
		Data.l $B2E9B080,$ECA90E48,$029F69C2,$AA0A705A,$ADED9956,$C605E2A5,$C6EFC71C,$54D5131F,$02B83550,$0D405405,$55014154,$401BC401,$D54A0555,$01155A0D,$5403555B,$79C04075
		Data.l $52DDD540,$B5125595,$55855675,$155DD516,$8375371D,$47AC7715,$AB5519C0,$9A04A904,$E4560441,$6A044269,$5A58A044,$B96A4B90,$4519549B,$00321994,$11543EEE,$441C1401
		Data.l $141F13D4,$17545717,$FC1454CF,$47CD9D88,$1654697E,$056095A9,$5AE81AA4,$000A9D82,$070A0476,$C3AAA908,$AAAAF314,$60EAABBE,$A9AA6A01,$3EBDAA7A,$22A51E95,$FF2AAA57
		Data.l $79BF9F94,$7D15E270,$0290F312,$20BF5510,$5454AF13,$9E531528,$7001004C,$006B0D00,$47BB6AF9,$49B5BB1E,$AE1AE402,$94BF16E5,$1594BB16,$C013CAAA,$7E68FF18,$A46A7832
		Data.l $2AA4958A,$2A7209A6,$508857F1,$555C2855,$4C5514C8,$84B0BB4E,$16141C54,$D716041F,$04281700,$15140457,$80C40550,$A044F404,$A000D418,$1A94429F,$475BE4FF,$393F6C23
		Data.l $57090F6F,$8F898D2A,$F9BE6E35,$60C9AA6C,$EF7229EB,$B92272C9,$1758AA72,$EE0110A2,$EDBA738D,$6C2DA870,$4FE4B90F,$DFC66FC5,$80418E45,$56156DD8,$B400A078,$A0152968
		Data.l $C4A315D5,$16258316,$0C16248F,$943C5A24,$5A943018,$C25694F0,$54020A54,$4D5409A1,$396D54A5,$645105E1,$0A7E40AA,$60A64281,$900A4C29,$C8A0A342,$42840070,$255558A0
		Data.l $52250058,$0002E128,$85825285,$C205AA50,$AA5A0545,$F5FF5FA5,$AFC50053,$38140B91,$5C532254,$642C78C4,$21C41478,$10445511,$55150400,$34715055,$58F168B8,$8828F0C8
		Data.l $04E23BE3,$C815EEFF,$227D83B1,$F60EAE47,$BDC59E38,$0112F6A1,$F62BA929,$AAD6C556,$A4AAE48F,$CE0700AA,$9AF60B0A,$1F5AF51B,$67D784FD,$0F6DFA0F,$95027CA9,$D05C757C
		Data.l $05C85F01,$781E0A7F,$5EE9855A,$B55E1585,$02B57E05,$01500172,$92F8EC72,$A3C58F18,$0BBC8E3E,$0F187C0F,$003C6794,$0FA9D50B,$FEB3C77B,$A9E90FA8,$07A5A702,$F7EFF4F7
		Data.l $4CF50BDC,$013073AB,$A0595854,$0A245901,$E0450214,$05A04001,$512F9052,$DDCAAE40,$09E25055,$00391D50,$0874AF0F,$BAF5D701,$083417F6,$FEA97A39,$43F5015A,$9A545D7D
		Data.l $5F475707,$0E8A0440,$C8010130,$17011415,$BD070AA0,$79551DA7,$DC3C3BE4,$A1DA6082,$3C0C2CC3,$F11F91B5,$EA6F70A8,$F23DFF94,$0F841F04,$4505E450,$9A03041E,$02A90177
		Data.l $54907A97,$0137D505,$A3078195,$A004391D,$58F9021D,$0568E80A,$0A00F856,$6183B792,$41C96307,$9D828607,$20C46DD8,$FE40D8C1,$00BDC500,$D040F650,$6DF040A9,$41F03CF3
		Data.l $7D01107C,$381337B1,$E35A1DFF,$AA3E0103,$A4A91664,$ECE1553D,$A91DA456,$0EAC05A8,$10EA3C55,$958120E9,$5E65855A,$B57E45B5,$40BE2E40,$3E3D000A,$0501001A,$820005E2
		Data.l $0781DFEB,$02BFA07E,$A1E397B3,$22007B04,$737820C0,$477F1582,$3F427D02,$EA1DA856,$0702C798,$950268EA,$5AD502A8,$DF257501,$D5004475,$01540143,$9501A055,$65428141
		Data.l $78410178,$2FA85005,$A0AEA450,$3A005550,$BB04E23F,$06D1DDF9,$27A2E320,$80E2807E,$00707E27,$5A95F8DF,$3590F8F8,$5022947E,$D60B0F0C,$02B437A4,$76B4F50D,$656E07A4
		Data.l $0198F609,$6F029AF6,$C85F0059,$A9C455E9,$C35701D0,$9310D5D4,$103E4116,$28B92E01,$BA02C5B0,$D88B8380,$2A3E230A,$8B20011E,$78972288,$97008900,$2BC10378,$48BE35EA
		Data.l $26EA40F9,$AE40E944,$560090D6,$A4DA0290,$03A8DA03,$033FA9D9,$F60BA9D5,$02140BB4,$FD0F69F5,$E96A0FA8,$3BF4FD06,$FF16F7FD,$5C05D457,$05805505,$8405405A,$2361C5CB
		Data.l $18550050,$0A28F402,$5205F8E6,$FF7357F4,$AE0DE2C5,$CEAB00C0,$8280A716,$AE22805F,$8CFD2000,$83807DD3,$E09E801B,$B591F535,$40590896,$F60C4090,$A0F60690,$03A0A901
		Data.l $03AFA069,$5A05D16A,$0F949A04,$EAEB01A5,$EF0C0FA4,$B1A73ECB,$38873128,$80AA8010,$4280DAE8,$FAD000A5,$8075F040,$BC00FDF3,$BD3D00FE,$40F63C00,$0D40A91F,$5A0750D6
		Data.l $90DA0F90,$17909A1F,$053F90AA,$AA07A4AA,$C56A0D64,$645A02F0,$0EA4950F,$A90AA4A6,$AA0BC8A8,$506A5501,$C7984055,$42686510,$51015059,$925A50F1,$50001A04,$39D00B3E
		Data.l $15A9A02B,$9C2A5450,$4148800B,$130A4086,$941C6115,$47E26823,$1F0040BB,$05B23090,$F0D01DF0,$2FD0D03F,$905763A0,$6A647B69,$9929955D,$2EB719A9,$9D192378,$6AFF066A
		Data.l $075ABF0D,$FD01DAEB,$6ABF02E7,$02E9DE03,$A500F8F6,$F73DC8F6,$A1575541,$50655D55,$590B8D55,$4098406D,$1806A31A,$00140248,$E205660A,$A068000B,$3E56177B,$FEB2797B
		Data.l $E27B0527,$FD0380BF,$00E601C0,$7C67F909,$DD299066,$647525A0,$A764FD65,$FF9768EF,$59AB9759,$DAFEAE0A,$9FEAEFAF,$EFDFDAFF,$0969C2DF,$9DFFFBDF,$1554AA56,$AF0B0F99
		Data.l $55054456,$5D02AC77,$09776505,$F7C0BF65,$F67CCF42,$FF404505,$1B59E732,$109F4801,$05A06A00,$5580715A,$02A0D231,$6903BE40,$0A009AC8,$555A80AA,$2AA0010A,$AA6AA4AA
		Data.l $6802E064,$9669AAA6,$C25559AA,$A0445A05,$DA96AA9A,$9FAAFA14,$5A959ADA,$301A97AA,$8402073E,$9A0A7722,$7717805D,$02217F72,$08803F85,$012E881D,$8B030C45,$8C8A0A04
		Data.l $55408A06,$09BA7380,$F03C687D,$4FEA6499,$80A040F6,$94104081,$FF985A05,$5655989A,$98AA1F98,$2A58F9A8,$0765800F,$94189295,$B7060906,$40560910,$DC1EE229,$A45350A9
		Data.l $2A024029,$A94A246A,$0A090240,$05800224,$C0148015,$07208581,$07E0078C,$1F83AAE5,$B3187D46,$8F861F80,$96147E0F,$4461F83E,$7C1B7F15,$94AAA871,$6A781C11,$0254D194
		Data.l $1409B950,$02100234,$D8F800F4,$9F8F8383,$183ECF3F,$140860F8,$946A45FE,$012183D4,$751408D0,$31C0E910,$2600C11E,$222A0243,$25852029,$88580040,$F83CA88F,$F83E007F
		Data.l $02505D15,$55029065,$7EAA0A50,$0A80AF7C,$40820BA6,$7C093609,$01087908,$075207C0,$1F06641F,$2F04E20C,$1F9417BB,$96B1B532,$21D61511,$A481156A,$9907A866,$A969A7A9
		Data.l $F66AB80E,$FFE55A6A,$AA55656A,$AA5F1900,$01A89F05,$79F6009F,$54027197,$7B40A50A,$30A92A40,$5A2A6801,$A84A2A94,$0A2E0328,$1A4008D0,$02340A08,$00040056,$09E21514
		Data.l $3B7FCC00,$72DA821E,$1982225A,$9A07A47C,$060208B6,$6916A469,$68AA35A8,$25A8FD27,$1AAAA856,$7E06A87E,$307E02A4,$E19D0178,$59010887,$BF801350,$103F9C02,$90011000
		Data.l $A8A60211,$4894A204,$101410A0,$04800281,$00013205,$F21BF8D1,$10DBF9DA,$07411003,$140590AA,$C32A6866,$05A4F90F,$E009A455,$2405FF03,$7AA4D0FA,$00849F0A,$AA084DFC
		Data.l $B2A91434,$40850200,$020113A9,$86A68DA6,$C5021408,$2808A929,$01082308,$0FFFFD08,$90B0865A,$00E01521,$3F028036,$F9203E22,$B43E922E,$C295B748,$5A0346A7,$8B6A0250
		Data.l $B140812E,$3F905A06,$661590E6,$90D60790,$FFA07CA1,$68EA1203,$9A01400A,$50A50190,$B8505A09,$250A4040,$D02A406A,$918A2ACD,$40822000,$0290820A,$020A6B82,$5050CD50
		Data.l $C100F10C,$ABE44FE4,$FE99BE00,$89FB7480,$DA088057,$0880FE88,$9CBA88FA,$A788FD08,$881EF080,$76B48056,$01A4D688,$F1FE00EA,$09F9F0E5,$7969FDFB,$BE15A955,$71BD55A9
		Data.l $0A7E0081,$E2FE4A9D,$BC21EC3C,$863E810A,$F7045EFB,$50DE00A0,$3F5C429D,$953F409D,$A0752E50,$0AA4560E,$E600A466,$B4E901A8,$5901A90B,$6AA90274,$0D5AFF0D,$9F016A55
		Data.l $5F01AAAA,$A55F02A9,$00549700,$BE782E65,$396A0050,$602AE281,$04320A82,$A2829A2A,$790A0412,$0210C840,$900A0468,$152F6C00,$AA4055C6,$23500CE2,$FE0300F8,$00AEDD00
		Data.l $47006E55,$FA0B007E,$887A0BA4,$B9020040,$A4ED0750,$66A87D16,$D565A866,$64D605D1,$56FE5056,$9F965A24,$A56A56DE,$A9956A96,$6AE967AA,$775BF5DE,$E4D717F4,$4DD4E507
		Data.l $000664BA,$905A0A45,$00028098,$806902B5,$2A809A0A,$962A909A,$6F321AA4,$9C41FF83,$FA504127,$89FF933F,$9D590DC2,$FF100418,$A4BBE668,$D4EAF8AD,$2ADAF729,$77296A66
		Data.l $5A5D295A,$2A6A5D2A,$96A6DA9D,$93A5A976,$5A690BC1,$01A5BA92,$A9A9FF0D,$59A9BDFA,$3D94A97D,$FF305469,$4370439B,$2FE0EC00,$283C9E41,$406A43AC,$047618FE,$54140014
		Data.l $81FF484A,$416F3E87,$AF01107F,$0113BFC1,$106A29AB,$1C988064,$40169905,$10A043B8,$AA04682A,$22812AAA,$A59A0401,$5A5596AA,$12A6A501,$35041076,$550594AA,$AA061654
		Data.l $06A404A8,$814AA4A6,$514A910A,$00410AA8,$811AA80B,$401AA042,$68000968,$A0155416,$093E8DBC,$7CF4813E,$0F84D9C2,$07A40316,$A5051640,$A540A609,$C4F6FF00,$000C40F9
		Data.l $5069A9A6,$48551A0A,$2406C610,$0F86955F,$98590228,$0FF59601,$60066592,$66900999,$49194006,$8D462680,$1600592E,$55028256,$05C60FF2,$35FD3E50,$6907FC79,$05507F0F
		Data.l $4E36A055,$356C8116,$EC850048,$50993D50,$0D50653E,$56051F0B,$80654123,$0A70D82A,$008A0163,$00A1E019,$F21DA0B6,$15600295,$16059011,$B8E30580,$05B31540,$F7F05C22
		Data.l $8007F1E4,$0FF11823,$5EC56096,$F6308146,$A0769495,$39948427,$B915991C,$FDFC1FD3,$0AF514C3,$4023189C,$08511E72,$110213A9,$06521905,$94250520,$26850054,$00046414
		Data.l $FF870455,$8FF3FFC0,$F15FC792,$F5C3649F,$6F659647,$FF30F60C,$6697F26E,$056C0303,$00566566,$01906F60,$506FF89F,$02905602,$BC2F5866,$7041100D,$BB0C3FE3,$19009825
		Data.l $801825B2,$5400243A,$0440514C,$93A905D2,$CFF20FE0,$50D64599,$0194D501,$FE236466,$66792799,$A537F437,$59593E66,$FF56663E,$0F1C872E,$F26301CA,$EDE46501,$F867040F
		Data.l $998E0F88,$99016860,$9501C11C,$70640264,$504226F7,$05804119,$B8A34056,$9D4C159F,$01045401,$57F05298,$CB2349E2,$F28F0825,$97F1E19F,$2760F390,$A607947F,$06CA0564
		Data.l $99F66665,$6666B659,$999935FF,$09646715,$5F05989F,$D09B01E0,$86BF8320,$308D7812,$28875083,$E8009499,$889500B4,$94006564,$00200505,$6001B849,$427B8C01,$860115A0
		Data.l $F8F1BBF8,$8BF94F83,$10A667D6,$0790F82C,$550619AA,$AD056052,$FFC5F554,$699899E5,$B5296465,$40F61598,$FCA5F9F9,$080149BD,$18125A01,$801412C4,$02385916,$200505B0
		Data.l $05405026,$06A0A210,$14088256,$C0030592,$1557FD20,$0BD7FCF8,$0811BFF3,$850F630F,$9B25D920,$95220370,$C6509603,$0520C558,$84527246,$F1FF4040,$486E15A2,$00236641
		Data.l $94650F6F,$40F0D707,$45D74B26,$9B505626,$344B905D,$00949538,$D802E216,$09552454,$A6500518,$024E5801,$08835485,$0CFF0040,$F738825F,$C09E6F4A,$4F90C355,$030FF902
		Data.l $B5010FED,$06F40203,$00057D01,$F5055675,$6AD60695,$DE0D2915,$3DF65F1E,$653D5599,$50991D54,$8B03B388,$80141D44,$7C14141C,$57019080,$9FE1C414,$F80FE390,$20925255
		Data.l $0F225105,$98500205,$01649002,$36FFC250,$032FE004,$02500327,$DC3F2505,$24BC0490,$95025057,$0F0D0A00,$24C6F041,$F500E4FF,$D99000F5,$40563850,$2210D999,$51401940
		Data.l $09406606,$65024099,$8900370B,$9901A1C2,$6658D82A,$50550A68,$6FC320A8,$8AF000A3,$B6073002,$02AC9864,$00186430,$60012494,$33510558,$1554552E,$E2758045,$00D6000D
		Data.l $7C0D00FC,$7C070B00,$0500DF06,$6E0541B4,$009F0900,$0B80A70F,$E50600D8,$64D60750,$1598D50F,$9325FF28,$62D69902,$0DA099D9,$E3655655,$65101799,$57595865,$D8676764
		Data.l $1702E31B,$D507D4D7,$20645C58,$F00AA092,$01985902,$99555A96,$02660540,$90011960,$0115078C,$50055540,$7600FF54,$AF8005C7,$F0FFF95F,$1C99B823,$EF11AE41,$80B73510
		Data.l $6E146F26,$D6D525D8,$6599B599,$5D9A96B7,$946E6669,$56596E6E,$66957C67,$95708759,$15302820,$663E9595,$BD953D7E,$057C553D,$BD065496,$65A79620,$F8360A40,$403E1A91
		Data.l $10C82A99,$04AC6640,$66000959,$F800B516,$21C85515,$406F477F,$BFE45B22,$0A049C90,$62828960,$809500C0,$12585909,$14816478,$19102698,$2C6C1481,$4030EC66,$6599E341
		Data.l $40569EF3,$66591501,$99955566,$1708E590,$49A055F5,$65D82969,$60960990,$6492C82D,$09985106,$9805E041,$4026648D,$0E871959,$8415C926,$114080E8,$F9404015,$05D478E0
		Data.l $A7415EC7,$695A7B1D,$26B81600,$98C04758,$589602AA,$05685E02,$94EFC61D,$1004A418,$FD11607F,$D8FF21E8,$20D85314,$51184A51,$51501856,$06505006,$40011440,$80600014
		Data.l $301011F0,$A1050E01,$3D880424,$C1E3C3E4,$F443E457,$A55F0741,$07C11763,$260861F8,$60A90060,$088FA7E8,$A01F885F,$52201F05,$7F04A07F,$7D2140A0,$161D0168,$06451502
		Data.l $55045055,$55546854,$06051D40,$440AEA81,$04011019,$F0B1F300,$F23C09AA,$307C83F0,$B7A55502,$0900A4AE,$F40850A0,$80162A0B,$B0CA53FF,$01A05599,$5F02A09F,$60DF0260
		Data.l $29D8DF08,$772558DF,$44551204,$10BC1824,$09805005,$52100B14,$E4502190,$A353E1C3,$57E1E33F,$E1E1C1DC,$9D154737,$0A5F81BC,$40FC5823,$88260820,$01F89257,$DF23E0DF
		Data.l $E8F313E8,$19D8D321,$61091649,$76650145,$87C8E0BE,$3F27F2C6,$43C5AF62,$00424035,$E643C2BF,$44A60440,$19D84E56,$4190A045,$A522F290,$290E9C2A,$5FBC0359,$00A04AE0
		Data.l $F701D877,$C6F304C8,$02C202E2,$598E5818,$8841C880,$44231440,$05604200,$49018142,$45060185,$AA140105,$3C8BFDCA,$633FC084,$73A1FC1F,$06C4A4F8,$06A04024,$20600931
		Data.l $1711163C,$1F104410,$2004A8A0,$0EC00402,$BD245FF8,$13452156,$F1009801,$04295514,$1E131980,$10006112,$28281565,$E037FE26,$3C570225,$011A350A,$1206290D,$3A111A15
		Data.l $AA083D90,$C459F66C,$0A044F19,$8048AFC4,$F4980ABD,$5A581D00,$03D900A0,$607F8001,$FF207AA2,$565F01DA,$9E045701,$05812155,$58450250,$25022365,$11096410,$408491CE
		Data.l $F2200521,$EBF40014,$83D043E9,$084BC006,$9536081A,$350845D8,$E03D0080,$0D089535,$23940688,$3A009539,$00A5EA98,$5A00A939,$38801A98,$80268B06,$AB98A918,$01589E01
		Data.l $3F06681F,$547F0468,$08607D04,$F704E0FD,$E85709E8,$F1D64B01,$44C505E0,$281101A0,$50BE0A04,$A4501678,$0C36F800,$53EA0CE0,$0400C800,$85090A90,$29040F68,$9C401A44
		Data.l $8A16442A,$004A3600,$0DB80035,$520A08B0,$EAA01A00,$55AA3880,$59005412,$882909A2,$A50650A9,$80560180,$563FF09A,$8111B5F1,$00A07D42,$FD02A0FD,$A8FF02A8,$006AF701
		Data.l $BA80E9F9,$44088058,$C7876088,$02F2885F,$00685F90,$9800A125,$19910006,$1A3E718F,$58803641,$3501471A,$503D1080,$02E03504,$060A540D,$A51A0694,$B9C6BA02,$A90169EA
		Data.l $18405A50,$A048569A,$F2920600,$07D60900,$A527009A,$8E001F00,$7F06E09F,$E03F0160,$5C603D00,$5500D875,$4605405A,$513E0044,$41200044,$480010A0,$40042810,$05784C9A
		Data.l $E2BF0613,$15410007,$A94210A6,$29906611,$761411DE,$51FE1514,$02E3DD41,$7555555D,$55DE1555,$5594F616,$6A1A94DA,$A4690AA0,$0968D7DA,$A5081865,$A0650828,$A0A9092A
		Data.l $29A0AE09,$AF2B50AE,$98AF1788,$62A89F52,$DF45A85F,$10D74364,$F0A14753,$15110002,$25088421,$1880A588,$00944082,$85884509,$00915000,$404161C6,$485FA145,$E399B7E3
		Data.l $B0752777,$7FE37F1D,$515D0150,$06556605,$7F0AE5FB,$A49D0A64,$A1A8A629,$59A898A6,$83676868,$08161A0F,$02485A06,$EB0AEE04,$A7054088,$C8EA0002,$FA8AEA02,$E5FA02EA
		Data.l $02E8FB02,$5C80E0D8,$68D80AE8,$810A0500,$2958580A,$60065048,$4A686786,$041EC660,$E504EC6E,$773540F8,$5A023044,$0227AA82,$1A00806A,$4A405968,$044D1114,$02341508
		Data.l $81640085,$55015440,$0A1B8950,$1A0A2025,$68560A28,$08886A08,$445507CD,$AA2810A0,$AAAA1488,$04A52FA8,$38828EE1,$829A0204,$00A8810C,$A05290AA,$13104000,$01141228
		Data.l $05F01400,$3A7E9755,$C0F20180,$E0117C03,$807A4700,$A78D5309,$1C9150C8,$90F11DE8,$27E3C381,$F2A583C3,$E902CBE9,$0568F0CB,$7878019E,$9E0660EE,$7A38F90D,$687C003A
		Data.l $551E9A5F,$A743AA01,$B9E8DA00,$092BB400,$661840AA,$0A336826,$0403A405,$02DD1A02,$02805203,$570DC05D,$4051384D,$D06EC520,$09850215,$C4F86C14,$7005E301,$31AA8C43
		Data.l $E0F335BB,$6400886D,$5FD27503,$40808C91,$28D23691,$4BFC1100,$23805105,$F0C2E002,$02500526,$01513B04,$000DE235,$4828C5F5,$213EF42D,$00CCEC74,$154D5735,$D09D0232
		Data.l $E8DE09C0,$037CDF09,$D7023CDF,$10D40334,$01DD7200,$27C486F0,$06A4017E,$D01C8AD0,$060BA802,$0B000F70,$01100460,$500DF050,$09005850,$D4090E50,$07B8000F,$0B010880
		Data.l $00080390,$0240D502,$B00300F5,$28D41700,$B0925027,$A9028289,$2E1029E0,$9D199F9A,$38828D9F,$829A6A04,$466B810D,$0A04407B,$3F417F01,$1D4961A2,$FA35AAC0,$251858C3
		Data.l $1126011E,$78599300,$61645D04,$10A04756,$3A841057,$C2810A04,$5B063763,$03554055,$5B01734D,$7023021A,$54151600,$ED54950E,$55560155,$C1555500,$65319555,$6165EF55
		Data.l $E658957A,$9A975056,$EBC19054,$085701D4,$7C9FF000,$88570880,$8015C4A2,$01705503,$29F025A5,$5AC05C69,$58563158,$7B5635E1,$95E69665,$516BC057,$6A4614A4,$4664A484
		Data.l $590AE66A,$581690E0,$56BE6E1E,$80570300,$C080E701,$59305388,$E055EFE0,$E6D8567B,$969758A5,$90EA0948,$DF686901,$A6161455,$16C9625C,$3E831891,$6B139CAA,$EF807B39
		Data.l $5A7BC07A,$E05EE6E0,$09A09E96,$7601A8E6,$F1570260,$3823A76E,$0303B201,$4DC60830,$0DCFAB85,$A0BE9AE8,$ABE8AB1A,$F58D1AA8,$09AFA864,$6B08A2EB,$00606A48,$180A213A
		Data.l $04006FC9,$CCC0C256,$FCEA8412,$C0AF7A00,$9BF0AAE6,$BE1AB0FA,$B8AF2AAC,$1AA4AB2A,$BA0AE8FA,$E0AE06E4,$A05E0F0A,$01A0AE02,$8B0495EA,$38011978,$4901CBF1,$0D81D892
		Data.l $3B8960A2,$00F01E4C,$25006C39,$E81600AC,$02BB6A01,$08502E83,$0254BBAB,$00BA2E00,$8200EABA,$E81715E9,$00A80A00,$202B602A,$081A52A0,$10C367E7,$D91C0212,$F8061C01
		Data.l $970899D4,$8C546748,$55B95565,$71087559,$5591AD61,$55555165,$14595150,$44446D45,$B804406C,$10AFED40,$E03C1B3F,$700034C0,$22200020,$01A92C02,$685CC3A8,$A86B00A4
		Data.l $88A8AA44,$8099B880,$6602141C,$7964AAE3,$A9020038,$A999A8A9,$84A94998,$CA406404,$A0110187,$50730CB0,$C5141A40,$1411DA41,$119A415F,$D5415A14,$41D91411,$0C941145
		Data.l $0414450F,$FB453BC0,$5A695A4A,$DAE555DF,$55DA7E37,$54A955A5,$C540B659,$695C8E9E,$3CE01440,$8420160E,$113A6014,$9B615F16,$59001611,$D91623D6,$96114561,$411F0612
		Data.l $1A6C2A90,$7ADF00BD,$446BDB00,$56599389,$9659EA69,$95B9C5AA,$C7299605,$8005106E,$62690587,$4142606C,$04CB607C,$5A6046DE,$60469A04,$46390455,$10043560,$46E66046
		Data.l $008089E1,$41140009,$005A7E2A,$A9C165BB,$95564BEA,$DAA4A95E,$5ADA5095,$00A6D540,$3C19BE19,$9D300099,$19571589,$0012072B,$0C041C04,$5B0E097D,$5A99064A,$0AE5D507
		Data.l $65069AAA,$546905A5,$0D40760E,$EF83C06E,$1406966A,$538313E2,$25622263,$16871EB9,$9A26507B,$1CEF5760,$022256BE,$AC8479C5,$49107854,$08CDECD4,$32651114,$5545229A
		Data.l $58652950,$63025499,$A90120CF,$08740950,$45A08210,$975FC0F4,$6D86C147,$C080A586,$789CFC6C,$23BAC5FC,$174224A9,$1B7F3E2A,$41CA12FF,$40400940,$7F054905,$09F9FDCD
		Data.l $F611F8F1,$E11B1690,$159E11BA,$2151010F,$401E1150,$50420910,$E1504105,$27F2E846,$D401C506,$AC940300,$F76880FA,$E09A00C0,$B91AA0AA,$A05F55A0,$00905F03,$6C73052A
		Data.l $00121415,$15D9150A,$90105E91,$01105002,$BF39E050,$101F3F30,$5755C03E,$E45703D0,$4064BC5E,$07246854,$C767E132,$E6800043,$1B907510,$B03E21E5,$00F45515,$AE00F9D5
		Data.l $5ABE4199,$82862E00,$B7390E05,$50202C10,$02340508,$08800485,$D4050899,$3A000BE2,$8C801AA0,$4004C7E2,$398C1D9D,$C80F8080,$4528600F,$A45B05BC,$3502AAA1,$FA42025A
		Data.l $01F99201,$7303A595,$55005001,$285888BB,$E27E21F4,$91FC99B8,$56F9B91F,$F9BA1F91,$A0BA06C9,$55155615,$C0A90EF0,$8A02109F,$9CAA9B2F,$62810C82,$A0A0422D,$0D00A885
		Data.l $AA06C0A9,$0A02E140,$A0A9D5AA,$0A225519,$D0AA0EA0,$01540294,$01281455,$00A55045,$010508C1,$04E37440,$6B0774F2,$3B4F3C34,$5926D067,$C2D61660,$00124647,$7C10E2AF
		Data.l $A0AA343F,$12DA7F3B,$4316D05B,$08909901,$01105086,$484200BE,$933B1431,$3493390B,$923B0239,$16F0BF26,$D501C067,$8096BC25,$0F5A5A85,$0009C07C,$3B3CE134,$95BA26C4
		Data.l $01806E0E,$970980DF,$8D9610C0,$4A88850B,$31140880,$881C1310,$208B0BC5,$080CCB0F,$4502342F,$602D780B,$89908140,$CF118BCA,$3702643B,$0B320A1C,$8F2F00F0,$03507A23
		Data.l $D9365055,$C6963A60,$14008267,$1A009082,$E2100508,$4AD80022,$00A094F5,$1600F86C,$EF1B01BE,$B9B73702,$2600FB99,$006600FE,$FC850170,$00B80900,$84002025,$5B1984E3
		Data.l $80B0E0A0,$40B08083,$0DE0AA2E,$DE02C099,$ED07708A,$048098A1,$481E4054,$08C8F0C9,$022E1394,$158B3FE0,$DF0110AB,$F09B3FF0,$00C0660E,$0002E398,$12029202,$16E20195
		Data.l $350CBDB8,$C57C7308,$D1B19591,$225A0220,$54EA00A4,$1B50F900,$C6CF89F4,$01CEE24E,$0331C758,$C5DF3C0A,$A9028804,$0F610300,$800916E4,$7F00D03F,$88BF5A0F,$209E2140
		Data.l $1B271231,$14187162,$2608C0D6,$44148071,$68219050,$886408D0,$80E08487,$B791AB40,$00D00021,$5CC65B42,$401C3C55,$8008250D,$7ABC2808,$FA7FA82C,$14F97F68,$BD00D47F
		Data.l $D503F250,$28109101,$88F78A04,$0EE2AB81,$B08E210E,$1C15AD8D,$12471A30,$301A00A5,$62AB1501,$1F01106F,$C9E8DA01,$28042A08,$3702811A,$2A40A042,$6A6C44A8,$00C02B80
		Data.l $7D0BF01B,$80FC0740,$5960A230,$0A048DFE,$2D11B601,$B10D9290,$08DA7802,$900E64C4,$4360A617,$191129A0,$11050110,$0901100B,$2840D859,$011A0204,$102A110A,$5539AA01
		Data.l $2094A06B,$02202026,$2A3EAD2A,$FDAF295A,$05406F14,$7E28FD17,$44570441,$0A044006,$E201C281,$3160A20C,$E3F8011D,$544B0703,$53AD05BF,$6001F0F2,$F0EE1FBD,$7C292003
		Data.l $F00EC1BD,$BD26FE15,$0329F185,$20DE0BD0,$BD06D09C,$A1808CC8,$600AE360,$00A9A8E4,$9DFEA59D,$E78CF182,$20A8F00E,$388AFC39,$ACAA07E9,$F2D0FF6E,$2DFEA087,$20804984
		Data.l $835CFDB5,$832DD405,$B9C8F184,$839D7C6D,$08E260F1,$01003000,$71908E9D,$660A3704,$1F395807,$28746308,$78CCFCD0,$09690A7C,$017C987B,$1091770A,$79633714,$F5F45093
		Data.l $10584F02,$B902080F,$6518D81F,$D8400779,$B9C80A2C,$05CCA007,$A841E50D,$61DE33CC,$1470821C,$DF6A01B0,$1F841C1F,$58900754,$782F7B29,$9B0C2C70,$0BE89807,$07B9DE6A
		Data.l $DD368850,$22D838C1,$4041E609,$C3DE2C10,$093D3848,$8041EE03,$790B29F4,$0E0C8892,$3840B077,$38107735,$E755893F,$010DB5C5,$D880E61C,$81FF0A0D,$1450A81E,$32B4600B
		Data.l $1261A260,$D3015F0D,$99979236,$3F5D5C5A,$58974786,$A4635E9D,$803FAD68,$F03F938A,$4A78187D,$AAA3AA6D,$09D03BB5,$EE0C8AE8,$F4B523AA,$603BD660,$26C034A4,$CAAC17F0
		Data.l $1030E01D,$7EAA7A8D,$72AD0830,$D0A4DDD9,$06CE6001,$ADFAD019,$A174DC04,$A58D1809,$4A04A57E,$08224D4A,$03A20BE5,$09105DB9,$030D9C88,$F310CAA8,$0A008C60,$A28399F7
		Data.l $2E652D50,$A02B288D,$18A3E8FF,$C863A179,$09B002C0,$0D2E602D,$E48D7E9D,$B182AC02,$F0FFC93F,$7E9EADD5,$F03D11CD,$BD009D96,$BD3D10AE,$2A7740A6,$1813A521,$E78D0469
		Data.l $6914A520,$20E88D00,$348D3FA8,$A903A010,$880A99FF,$1964FA10,$C464F510,$B9190041,$20E6207E,$201B73A8,$39E40FF0,$9808D080,$64D04029,$49B804F0,$B64902D8,$7E9FAD7E
		Data.l $03F00129,$607EB7EE,$FF44F9A8,$2908F801,$FF050C00,$60C23216,$C2010242,$0B0DE381,$3D7ABEBC,$2E3CC25E,$32163C62,$48E20A3C,$0E00FF4E,$94B09240,$9EE09AB0,$A820A310
		Data.l $B5E0AF00,$BC9C37B3,$8445B9BE,$892985A5,$BCC08E8F,$BCF8BCD8,$E368BD38,$01A42407,$61C22F35,$81E5E5B6,$8216E118,$A53B8219,$21141083,$CC810182,$01FF0CE2,$FF0EE20C
		Data.l $BEC1361A,$ADB80E11,$611505FF,$A01D0A3F,$3A032803,$03067400,$161C1104,$0B006992,$132F1B0B,$101203A1,$3210393A,$1B081000,$0FA00D26,$000E0E12,$000A0A15,$BBE31603
		Data.l $0534091C,$8100061F,$1D030E78,$0002060E,$07020A0C,$28030A0F,$1B0151D0,$0C032D09,$65A1408F,$04A29B8C,$1A0ADA41,$0612E2D8,$D0131280,$08669D0C,$0807C831,$0917002A
		Data.l $85037A06,$17F8B0E2,$54192720,$C85E0B2C,$88502F81,$945C0D43,$86130960,$B20F0C14,$0C776006,$4A091686,$0122460F,$8A3A0264,$A2011437,$84A1070E,$100D1582,$5C36E6C5
		Data.l $89120521,$0EE42034,$12072D04,$32CD9005,$0F201448,$0FA8F006,$141380C9,$0E090112,$961013ED,$4F0E460D,$B8090A78,$0E82120C,$010E130F,$09120620,$0580CD43,$03A0BC40
		Data.l $05201015,$08050BA1,$008218A3,$148380C0,$F213010F,$17132007,$00140505,$050C20B8,$010E0F0D,$20197032,$54090920,$0BE00228,$09028002,$060C0B0B,$0B080134,$020536C0
		Data.l $0603A0E8,$06010203,$03050307,$07020201,$04070701,$03ED0405,$01040085,$330110C8,$0C210009,$420408C0,$001C5131,$1405465A,$42C411C0,$00216F86,$B0071039,$0F60040F
		Data.l $91A8454D,$8AAB8138,$CE00BAAA,$BA4336B8,$5550F4BA,$A00DD4A9,$E3A10334,$449A2255,$AA4D60A3,$35AA6EEE,$066B494F,$A0680006,$00A0A501,$0490AAA6,$A5B8B80A,$5BD020E5
		Data.l $AD37AB28,$8B8888C5,$0AFF818C,$12E2EB44,$545194B7,$478906B8,$EE65BEBB,$FEEF2D22,$FEFEEEBE,$C4DBDDFD,$1F1BB947,$BDBB07E2,$9B60DDE3,$DDEE06E2,$C6E6BBEB,$40021E1F
		Data.l $FFF93A01,$01619614,$0A051917,$1320FF52,$9C991208,$A99913E2,$04CD9B5E,$F99F9BBB,$CEDD1690,$FF9FFF80,$0CE2BBFE,$7712D999,$504669FF,$74557444,$84111151,$055B81F3
		Data.l $05055511,$ABBB08E2,$C4BF1FC5,$BB184AFB,$1C038888,$B9200AE0,$AA9A4A84,$16A99BAD,$A0A06007,$3BA8FFBB,$0A1668A9,$2CFFAF88,$029BFA0B,$BAAB8501,$40AA6EBB,$A2C4AA06
		Data.l $B99AAA8A,$A9A9999A,$CFCCBCBB,$E39F9999,$FB0E61BB,$A9AABABB,$550550AB,$B0454444,$021417C1,$005504A0,$C084D711,$801AE220,$FC840979,$F1E51184,$7A115700,$00FE4513
		Data.l $98852149,$3A21C855,$9CD32815,$B0855032,$349EE403,$0F120220,$080E050B,$F1039B3F,$2E13050E,$74927AC2,$680A123A,$23858362,$00D7169D,$3C859526,$6D330005,$F8DE0185
		Data.l $40539D94,$2A301B80,$17110146,$41140202,$6924233F,$C5261D1D,$099B9536,$54844C10,$06FE0088,$08FE0084,$0A3C0944,$8C520B04,$11198853,$8A8EC014,$242A4807,$8E292483
		Data.l $12263803,$85C11423,$2A200A92,$6B0473AA,$AE442623,$83281426,$9A83AA43,$0A437428,$04E228E2,$1E1C1C19,$87E057A8,$52C39F87,$EC63A2A2,$183112A4,$16212002,$4E018519
		Data.l $0654A29A,$13520E06,$19100908,$190F0B0A,$908D8C01,$115380A2,$19141312,$25022526,$6184E319,$00A283D4,$8186CF45,$5C1CBE0F,$144C0A18,$AF130149,$0F0F0424,$31CBCB12
		Data.l $B1BC86F0,$9EB90DD0,$4A27A4EA,$2B4482A8,$AE6171A1,$BA7B4084,$9085EA26,$800C5387,$8909E040,$00C255A5,$137CBBB0,$87D05202,$92CC4E73,$133787F1,$DF043112,$5D1DC051
		Data.l $F05B1B1F,$17203D1B,$08051201,$0513DC1D,$3C709A88,$04EA12B2,$76A8EA4C,$564F885F,$F86C0602,$A200E672,$00992B88,$A3889B57,$14601880,$20050B01,$12150F19,$09103D20
		Data.l $2E3D0B03,$1DF06B2E,$5D88B434,$CAA10247,$09BC0788,$88E34312,$0009BB05,$9B890425,$7384C14F,$D5202B2B,$3907147D,$1E00743A,$440100E0,$820DAE38,$15AFD183,$534080D6
		Data.l $5101E558,$40854E19,$AE267326,$92AFB344,$75092155,$04480C44,$04C80C4C,$07089254,$5358745C,$3C201F59,$28EF0846,$1522400C,$1E1D4F26,$D388225A,$8687D1D0,$474AC274
		Data.l $00981C48,$404F2518,$24E80098,$991A4A4F,$4055CC94,$17541C49,$2194F116,$6617949C,$022F28A5,$55451000,$C24940EA,$0780C8C0,$B00E8080,$69540880,$260A2342,$8D0AAA5F
		Data.l $7274732C,$41575820,$F0B28CC4,$901693C4,$B0425429,$AA5F49F2,$AA83CB41,$28056A0B,$05E21B84,$40BCEE42,$0EC20345,$12A3DADA,$270CCE37,$2163AC4C,$161C4280,$5A5F5C5F
		Data.l $DBDBDF16,$649887DD,$132AAE33,$96401140,$017C5041,$65279151,$60090023,$31301508,$A5C33332,$36080435,$85B79915,$5399B889,$D05F2417,$C0CB8053,$6028E33E,$63402938
		Data.l $5E6A7882,$AC971724,$28451D25,$C1A10143,$99308915,$C6441093,$8502640D,$A39C0E16,$21040824,$A0460C16,$09106347,$207E3417,$4706E2CE,$2517E383,$5C605F0A,$60CEE3A2
		Data.l $DACB8B43,$08E2CDBE,$14E57347,$CD3C8D3D,$C4C3DABE,$07E2C4AD,$1C3C6447,$3C3B3D3C,$11C0C5C4,$4747403E,$9E0D8A48,$5A0C425A,$1EF2845A,$52B23B1C,$40E81515,$154E233E
		Data.l $4A0F4F21,$99252AE3,$CC909499,$226298E3,$3E4B2194,$415F0600,$41571756,$BC003441,$5F0A4042,$5E3F4242,$175E1721,$D2AFAE5F,$DCDB0B98,$2820DDDB,$0C738B63,$05102020
		Data.l $0915070E,$2013270E,$130E010D,$E80E0F09,$7FA613E0,$8F7284AA,$E676FA8B,$AB8B9A40,$8BBB889C,$4232B310,$CE118BCB,$8BEC9493,$65E6B2F8,$24128BFF,$AE108303,$267B2998
		Data.l $2964E408,$02318C3E,$4B68BB10,$730D138C,$5AF83422,$E339D38C,$A1276724,$8EAE80B1,$FA8C8A69,$A0C2E7BE,$849005EA,$BD8CAD45,$B9CE76DB,$68988A26,$0C128CDE,$1DA598DD
		Data.l $6147EC26,$13893482,$28524E8D,$2908C849,$3CA0A9C2,$E2F6070B,$D8D24C15,$0902CAA8,$12156B07,$060F200E,$94CE0206,$B78D5FBD,$3ACF973E,$9359CDD0,$EE4F647B,$2E5DA4E1
		Data.l $85770760,$99098DB4,$0715054C,$14012008,$1E000F03,$763510C8,$798DC443,$6920C2B6,$460313C5,$5BED8613,$20D08594,$6278FAC0,$0D231580,$98389F8E,$8E327524,$DD8201E4
		Data.l $128E47F1,$1A9EAE06,$8E51B009,$CB6D0411,$DE8E66E4,$76622452,$301A9C8E,$13203300,$13100514,$1DC81420,$210C0C05,$D7291325,$E129BA8D,$8D7D3620,$D89E1011,$DB8D8E28
		Data.l $29252018,$EE07118C,$8C104084,$F8E124BD,$0889976A,$ED852126,$6133218C,$8D03D220,$935D3722,$83E02E9D,$AA1236F0,$A03612CE,$8500C18A,$43B10A9E,$88F0C1F2,$12525802
		Data.l $6888FB1B,$11843885,$E2AA342C,$B0EC0908,$1A1C0930,$2C82C1B3,$09BF6799,$8D782E79,$2F68A5C4,$0CE6A60C,$A045AC32,$3E33F787,$0898006A,$B10D3A08,$885181A8,$371B3431
		Data.l $98C6C82D,$B1CE9899,$693A2944,$2209405E,$31DA3309,$06E264B1,$D3E8090A,$3938141A,$C0F40ED2,$C2548DB2,$C4E2CE2E,$E07A4C8D,$09E33043,$9230C260,$4B1BAE0F,$22819872
		Data.l $068C3312,$B193120A,$6A2D8B43,$95DC1B36,$20A08A83,$82181E82,$36882A58,$821928AE,$3A3395A8,$6536422B,$25545A96,$C71A12E2,$18EA972D,$AB349520,$14910A36,$99141C1A
		Data.l $34846AD6,$BC830242,$825A3036,$24171C10,$F8B42233,$EB8C0920,$4630060D,$98ACAB81,$1C070472,$0E42EC1A,$BB229A8C,$B9880C0E,$1E5499C2,$CD20400A,$82B08130,$0A7310A2
		Data.l $1243210A,$20A21837,$14AE1D00,$9E839F84,$1BBD1092,$1B0B2611,$A462F412,$10537993,$1BB8A282,$B5B501C9,$9207C3AE,$A02D0109,$2D262627,$A5A7820B,$CD61C2E3,$20125295
		Data.l $204E0A4E,$04E0F501,$BA040082,$98E45D40,$96829593,$71064079,$05407719,$E2739871,$2906285D,$54C28DB5,$53F5AB87,$34323025,$36334C15,$53B5B1E5,$102039D1,$9F12361D
		Data.l $7C349EC1,$8C922F63,$1C373032,$99A84B2B,$81B47395,$0B0C0B0B,$4037561B,$011A959A,$62957999,$04384423,$AC452429,$5CAB85AA,$6B1C988C,$088D1AE0,$2F94A8A8,$533D3C0B
		Data.l $CA590B2F,$A400A936,$372D2423,$AE1D0620,$988F8E98,$9E879F99,$320B73A6,$33362E54,$371D0420,$9E859F33,$3533B199,$14221447,$E2549AB0,$2D3A0A04,$2D40A1FA,$95335312
		Data.l $B1979693,$20363053,$2D302D3E,$AE2D222D,$95959895,$E005E283,$1409095C,$141A141C,$98291028,$98998D8D,$00ABC1AA,$C08FF708,$1094D3FB,$14957C90,$901F8352,$C4E60A12
		Data.l $5E903522,$0324B90C,$1213904E,$61579EE4,$13CD3D6C,$29907758,$1714130D,$0108200F,$1305160C,$882213C6,$69A2BA90,$043AB9A1,$B414849A,$00A2BC90,$1190C141,$E24FB808
		Data.l $1CBA90DE,$F41B8493,$20D9BC90,$73E17A79,$9DAE1675,$3A37663A,$01914024,$00031336,$7614914F,$6269E23B,$20067191,$12A8DC5E,$0284A40C,$00C5AD7A,$EEF99070,$59849A28
		Data.l $1131AC9F,$B084D939,$1268184A,$2391BF62,$46E21332,$802191CA,$36C84E10,$0D1391E0,$F1B4D84D,$8490054A,$1191FC44,$AB84DD0B,$CD119209,$9216658E,$E2133802,$EB922718
		Data.l $05480088,$7B0E1291,$1F2FA222,$1D802291,$C4002783,$8003916F,$60C20080,$08DC74D8,$60528637,$4A2A28A4,$72BA2A33,$D9301C2B,$739381D0,$12C2AF1D,$2C252B06,$A4B594F3
		Data.l $1283AFAF,$3C20982B,$8F08170E,$DC98BDC3,$8098CC78,$C7041800,$C00C00C2,$83A42CA2,$00088074,$3C3BC90B,$BD70AD6A,$B56AACBD,$70006883,$6CA43713,$008AD036,$A4B2BA98
		Data.l $9A5163AF,$03A33022,$94A4A670,$059462B2,$A49A274A,$BC74A9AA,$24372C57,$026F3FB3,$253E310D,$9494B9A6,$73BF88B9,$3706E213,$28240868,$5280BCE5,$04040EAA,$2C430828
		Data.l $B5A9A494,$5382AFBB,$B23914B9,$E1F1B088,$2DB0E442,$84B02F34,$99915ED5,$996197B1,$28412DA3,$2CBD0A09,$8BAAB4B9,$9C00A98C,$2D2B2772,$242CE32B,$AEB9BAA6,$B460AFE3
		Data.l $4F3A4192,$4B1000F1,$6050F01B,$339D4DC0,$1205A209,$24278074,$0F1F0752,$1CB10E1F,$07C89D7C,$41C11237,$306E4C21,$11720B14,$2420E618,$4F05E02B,$228292A2,$3058B088
		Data.l $2C24081B,$72A30B16,$1D00261B,$1D24A380,$22524719,$11401104,$E2738D85,$37133705,$11023F03,$83D14A10,$829E2621,$181CDD10,$48206103,$86A192A2,$C852D201,$81E88511
		Data.l $62A2600A,$0C180790,$8D9200C1,$033462C8,$A1841818,$9D9A999E,$5C0082A1,$0F044007,$A2A2100E,$A19E9D86,$94839EA2,$110715C3,$4040150F,$9D2538E3,$97969E92,$B460B6E3
		Data.l $C3227D3B,$888B8B87,$96959493,$0C640F87,$861CE481,$445C1014,$0F1E1826,$42258A19,$228E2A1B,$181E8258,$08802382,$8538882F,$90663578,$B2C0068F,$8BAC3606,$0E04EFCD
		Data.l $3E4440D6,$0F66423E,$5C8A7589,$88991A74,$12171CC3,$45453D0C,$4704E240,$3C5B4B4B,$68018E21,$A8680180,$4F4C4CF0,$0181AC49,$4E1A4D4D,$1800A04E,$01A0201F,$274A2423
		Data.l $2B08A028,$1C22212C,$01A02325,$49482A29,$53522E2D,$395755E1,$D5744355,$7720B658,$337340C8,$59003C50,$597C7D31,$597E1C60,$59758F5C,$5A2134E3,$A66037E3,$4620F5CC
		Data.l $06656463,$680E6766,$6ADF8A69,$6F6E906B,$2A3B7170,$6C8C1614,$2E626970,$73605C72,$626AC08D,$9888720B,$18777476,$583D5CF6,$0C55928B,$6ED07B7D,$73D1007C,$7C720834
		Data.l $FA06E267,$0D920300,$E5630441,$227F8D01,$920E8077,$040E5C77,$3B773C64,$73728975,$5C615F3C,$64893C5D,$7C7B0E0E,$6273908F,$8BEF840D,$A5E37223,$FB895B39,$83A838D9
		Data.l $800982A0,$4108980A,$191D180F,$9716201A,$87331C1B,$EA0E3A83,$83828983,$895C92AA,$99E3568A,$848B0361,$C0E5929B,$24800781,$03100906,$0315FCA0,$06060E10,$13120B88
		Data.l $726D6C0E,$63627264,$345CA85F,$E5372E40,$029E56A0,$0B825682,$84858380,$828506BA,$0EF05606,$12D09B9A,$A1A09F9E,$000E05E2,$31309D9C,$51503332,$1FAC5554,$C75171D4
		Data.l $75171D41,$0003020C,$0A050401,$180D0C0B,$06111087,$0801C007,$0D000109,$11130B12,$E5140F0E,$18321603,$E4192CD0,$7B341A0C,$221D51D1,$C8D31E93,$0231E16C,$1F1E0891
		Data.l $0D21036F,$B5161757,$190CD018,$531A40C8,$23228595,$26256697,$0B9A2726,$342B0C75,$29292803,$2D2D2C2A,$1D9C392E,$E3C32162,$8DA60E60,$A6063083,$68321931,$33063206
		Data.l $6634821A,$2063C321,$67352063,$37B936A0,$1E38D868,$01CB9294,$1E39981E,$E23A1E90,$6003E206,$08D32F22,$21D6E330,$218CE370,$609BE32F,$9C9C2F64,$919D2F91,$3B4E2F9E
		Data.l $3E4B3D3C,$414B403F,$44114342,$784B4645,$A8391D09,$4B10E143,$4A093E47,$48474849,$4D114C01,$11E82290,$23C31001,$40001A02,$4D11110C,$898E944D,$8F959289,$9D97948A
		Data.l $0D3E9F8B,$C710739E,$50548640,$C41C5703,$91F19031,$07E19071,$6054E307,$5037009F,$96220700,$58585555,$52515371,$C7865090,$1A5D064B,$83858C1E,$D8DAD918,$64169ED8
		Data.l $67666565,$39696868,$EA39313C,$18EA0E32,$50C818C8,$0B870E8B,$1EAF5722,$1A686D68,$13C28A0A,$6C6D6C1D,$5656166C,$6F1D0281,$1D215756,$4C49486A,$48470800,$494A4748
		Data.l $960E20B8,$06E2D608,$A5060F0F,$5C5B5A59,$40E08458,$70C84881,$2C717271,$506D104E,$72737185,$3C329628,$819A763E,$8B8C818C,$AE777617,$06320601,$0AB22017,$226074E3
		Data.l $C3259078,$73621B03,$0EA383C3,$AD06E28A,$EA2C3883,$4975C818,$0A1A681B,$03206287,$24E3792A,$0D567B34,$86AD7C56,$81A1A67F,$74848382,$7D7E7D56,$3C80E385,$82878486
		Data.l $892E6088,$228A0220,$8C39208B,$1E8E8D89,$34003C8F,$9D939291,$953D94E3,$92979589,$9894978A,$F38B9299,$9B19910F,$9D9C9C9E,$1298991E,$9031B07E,$2260A2E3,$18D4A327
		Data.l $1E05E290,$97B2E49E,$A15997A0,$01A218E2,$D0A4A34A,$C77A3145,$20A55145,$A5E3D72A,$2ABBA623,$1E31D7E3,$34A73A75,$1D5DC516,$E2A84508,$6EB98108,$A923A8E3,$AAE35CB6
		Data.l $AB1E2260,$46DB75AB,$AE4BAD0C,$B0AF0374,$40B2B134,$74B4B303,$E19F11B1,$9ADBD8D8,$B51E9039,$30601EE3,$1C1EB7B6,$BA1DB9B8,$0623D1CD,$63C1CA32,$B564C20A,$8392D850
		Data.l $58E31E3A,$00680184,$82CC0DCE,$1E93C6C5,$33832060,$80FA1303,$D3264EE3,$EA721E06,$3B71E31E,$5F5E5D72,$62626160,$8A04E263,$CA01945E,$CCCB44D1,$CEA0CD8B,$E3CF7C80
		Data.l $D1D03889,$9C348A8A,$3E808BD2,$D4881AD3,$A2040226,$CCD4A044,$A1E3D56A,$62824037,$64A20800,$2E84D5D0,$4B55241D,$8006320E,$1E6F1D1D,$4E6055E3,$CE1E11E2,$C6C64B38
		Data.l $47C03DAE,$57C4C386,$D1D49403,$C8C6C791,$C71079C9,$504FC140,$41C29550,$524B031C,$0BF84B4B,$263908D5,$10260230,$381157CD,$2C2C125F,$CC161413,$1A545C11,$CC1C1C1B
		Data.l $2920CE54,$B0E3AF82,$56AFA260,$B10440B0,$A838A3C4,$20632063,$31150730,$3433068E,$54353232,$8A16432F,$36858954,$383C3637,$3A536003,$3D02AC3B,$F9DBD8A9,$0D48F11B
		Data.l $45F200A3,$461005E2,$493FB247,$4B4A4510,$634D1045,$D444B4F8,$0C715C1C,$52555453,$56525160,$03595857,$BDC85437,$5D5C1515,$605C5F57,$62615A5A,$91B2B72C,$C6100FD6
		Data.l $417009E2,$76750622,$80787768,$107A791E,$4F7C7B4F,$8C7E7D50,$1CD60063,$32304232,$10073044,$2A924F02,$418584F1,$00D01F02,$D01FBE60,$0F40848E,$8AF48787,$8D0F408A
		Data.l $8310F48D,$86D0908F,$89889291,$8C8B9493,$98979695,$9B519A99,$5782E09B,$A09F9E9B,$CEA1DA0B,$BD20582E,$A44AA3A2,$A2F4A7A5,$E28110A8,$AE2810AB,$BE20E642,$BEB6573E
		Data.l $6BE84240,$C2E167B3,$20632063,$401215C3,$3A898EB9,$2818EB54,$632060F4,$E400A320,$02880100,$ACC71003,$C1AA6104,$98A2A7A6,$A9ABA380,$ACAB96CA,$E4AEADAD,$14731011
		Data.l $21417510,$D81074D0,$811076D9,$A043C382,$31C6A063,$AA946CC7,$E25EA51A,$CACA1008,$C0E603BA,$10232221,$27262524,$CD262928,$2B602AE3,$BA1FE9CB,$41C647CD,$434D00CF
		Data.l $C7D9B3B7,$B4E0031C,$60BE4B10,$3F60030C,$B8104CB7,$B4B9440D,$40B4373E,$E3B5103F,$B62E604F,$D13E3C40,$0D0FD3D2,$2B0E1515,$0C0F8E2C,$13E2800C,$EC6D4EC2,$72018598
		Data.l $788764D3,$5B51D41C,$CE6B43C7,$13536E44,$6032E371,$E196A963,$63E21AD1,$10870BE2,$0142CF69,$486F0855,$D44CD167,$D64C10D5,$100DE2D7,$F2DBA3A2,$12A5A401,$42410881
		Data.l $BB44438A,$E006C0BC,$3E10C082,$40107473,$BDBD7675,$C0C0BBC1,$56EAC3C2,$313E6519,$043C1485,$4842D16C,$406F4673,$410D4A10,$6FF5494D,$4B295066,$4E2D45E3,$7F0006E2
		Data.l $8EA16388,$64880C81,$67256CE3,$686AA096,$D16069E3,$C818C81D,$0CE2B963,$3244E915,$008E20A4,$A0C5C408,$00C9C800,$04030201,$08070605,$0C0B0A09,$EB0F0E0D,$3412105E
		Data.l $16167413,$1B1B146C,$B7DC4015,$18C81917,$1C18F8C8,$2190ACAE,$24232222,$4B262525,$07171F8B,$0C640C75,$8304E4BB,$2B2AA9A9,$2D2C5F5F,$31302F2E,$35343332,$39383736
		Data.l $153C3B3A,$04CFE783,$3F3E3D19,$42414019,$E56B9D30,$C49CC4AF,$C69FC69D,$C8C7C8A0,$D173CAA3,$D8DA8C8B,$05C8C898,$94939219,$818EA2F3,$96819C8D,$E197A0C6,$06320628
		Data.l $98A31A95,$BC9A9926,$BFBEBEBD,$00F841C0,$C3084430,$60AD4E88,$DF1B2014,$19C06873,$09E2CCAC,$6010E319,$6E6D4F41,$52511F12,$7861E320,$3BCE8A6C,$1D028A5C,$741108E2
		Data.l $01A05A50,$5D5E195C,$68645B5B,$1E046579,$29A09EBE,$0C1FF1A5,$3207B87C,$AB326127,$1918B323,$687058C8,$6AE371A4,$81DA7224,$606FE319,$1905E241,$486A0B82,$D6190C59
		Data.l $77337644,$78463CD0,$7C7A48D0,$7F7E7D47,$1E15F00F,$81802059,$0F698281,$438B70EA,$27276027,$078D6362,$25C00632,$18A1C775,$79511FC8,$1DE31C68,$81CA8423,$202111E3
		Data.l $666150E3,$E27E1C85,$31D0190A,$E88E2780,$4C04C118,$1D44D04D,$C640D647,$15004611,$03504850,$0011C414,$14454401,$C4404A49,$D6D5CDB8,$8DA59D10,$45C40550,$539BB795
		Data.l $9D5401A9,$4C5655F5,$B4CDB46E,$196D2E6B,$0C4078C0,$A51734A4,$0BA5A4CD,$8887A6BD,$828A5874,$BC024775,$4BD0908F,$96580786,$0D97603D,$C75FE158,$AF8083D4,$8E899AB0
		Data.l $ACABB3B2,$DB371A93,$04363E6F,$98B40440,$89B6B342,$A8A7D989,$9E2A8DA9,$185131BD,$A19171C7,$08E2BAB9,$59456E81,$295BD368,$AEBA97AD,$060FAFAF,$BF50BDBC,$C10500C0
		Data.l $C32950C2,$13014900,$909CC40C,$39139FC6,$D0CBC7C8,$6631CBD0,$C9C9CF8C,$D5D767CF,$B59195D6,$66AF98B7,$2F269A73,$E27B9F80,$D732B50C,$8429B247,$9F9D2602,$DAA09EA0
		Data.l $9BD80287,$B76BB89D,$9C9B0582,$A2A1A09D,$2A59D8A3,$B3A9197E,$19290AE2,$2989AA19,$E2A9A9B3,$045D2014,$582284AF,$948668B3,$12320680,$19B395B8,$DA8ABEBE,$0C640F84
		Data.l $E250288D,$6D871910,$CC0CE4CC,$41C640C8,$6880CAC6,$CDCEB5B5,$D1CD2929,$22D3D2D2,$6154849F,$A96A5502,$A0E3A4A4,$1787C760,$4BC4E580,$103D05A1,$D4A0080A,$A4A0313C
		Data.l $4504534B,$43A44074,$2E226A1E,$641856D1,$B2418AAC,$0CDA0331,$58030300,$2E6A6EAA,$3DC32E2A,$2A0F03D0,$EA9D006A,$660903A0,$9C70AAA2,$04035254,$4115295A,$AA410E40
		Data.l $6AA93E53,$06E22424,$CE1ADA20,$0A0E06CE,$20088F3E,$252A2924,$067E031A,$B0700520,$12540AF1,$661A00B0,$75A95AAA,$4BAA8810,$1D0088BB,$B20134AA,$0C59F482,$82AE82BA
		Data.l $8A44DEE0,$E1808A22,$8FA01114,$029FBF04,$3FBFFFFC,$67BDBF7F,$A8AA631C,$89B92EA9,$7A402A80,$0A15170F,$80809402,$281FBFBC,$139E0A60,$2FA9E31A,$1B06D662,$D5002809
		Data.l $D8008064,$E315408A,$0060601A,$4E8CF2F1,$E3902988,$00908AC8,$084B888B,$0094AAFC,$F8CAA8AB,$FC00A008,$2FABF800,$01A024AA,$02170218,$C7964E08,$97108A60,$07FFCD50
		Data.l $35171700,$EB0CB780,$0822A038,$CC214440,$D5088EBA,$2668FF21,$64C41824,$F46AA900,$059A9052,$9201AA50,$E302AAFF,$80506552,$11248821,$80EAFF08,$424830D5,$4B520674
		Data.l $9806D9BC,$AA16088E,$3F0C4CBA,$69BA2A00,$C0237A30,$78A255FF,$0CE278C4,$D6C73166,$165656D6,$2F2A5616,$8A141E29,$888A808A,$021319BC,$41D51516,$5055BA21,$A2D04639
		Data.l $B9C55122,$A800A808,$28BF6808,$023C144C,$EC3145D5,$E28835C7,$58984808,$180807E2,$47290808,$C4C02B04,$BDE19AB0,$11510570,$2F528816,$95103954,$7251153C,$583C9410
		Data.l $70113201,$65596038,$5601A068,$80464788,$A1689605,$400C0178,$1A15E20D,$59051004,$11588629,$84B8A004,$3DB25010,$33014E03,$35580404,$4830CA55,$20602216,$05900045
		Data.l $2C114011,$5001A69A,$90400114,$46F7F066,$95501A1D,$809455A0,$006855DE,$00352B11,$076C0425,$04010A2C,$10F08579,$00500514,$39024176,$E7853963,$60664441,$DC8E0080
		Data.l $2A47A0E0,$60826310,$14252605,$AC505044,$72006811,$501400A0,$A6422941,$05050645,$01052125,$04015380,$864A1811,$14605051,$18515140,$D6F10490,$0110AB62,$0538020A
		Data.l $44004055,$85E02090,$410C0185,$4545865E,$B6051115,$E899806A,$10505C6C,$AAA60044,$45555FE5,$2A263F40,$0F401F25,$07010130,$808002D1,$381EC340,$A0266801,$0E02C22A
		Data.l $051550C0,$6000ECC8,$68000122,$E8C5DC04,$1005A995,$29506F2A,$54510409,$542F0154,$41585640,$151103DA,$0480B355,$5A204188,$18045EB6,$4140011E,$26400753,$D01C408B
		Data.l $76800E35,$0CD18A0E,$A801AA87,$490A82CD,$29122004,$9190B4A4,$D09AA929,$0088E500,$0895312E,$002A272A,$087F5033,$0C00A878,$26370140,$2A0E2812,$202A203F,$FFAA6AF4
		Data.l $36A9A8A9,$583C6811,$BA245808,$2B805308,$3B007264,$A7032202,$4F404644,$AB031F00,$0646EC03,$D821AC40,$40029231,$31055A6A,$53F131B1,$1F9944A7,$492B0711,$4F4FFF8F
		Data.l $90904343,$4096E100,$14583120,$813CC71A,$83550811,$1594D1A4,$C1F1F19E,$05CC90C1,$D0D14104,$1D50FD00,$0F084370,$14230038,$80F08629,$147D82C6,$1984C941,$1D110BE2
		Data.l $8B4803D9,$881898B8,$08EA09E2,$55D50C97,$0698C83A,$7731D5D5,$825AFDF5,$0605E288,$564283B0,$00014646,$F8612A21,$68A51215,$8A8678C2,$10C882D9,$04EFA430,$AA08E21A
		Data.l $BC94A410,$FCCC7040,$0A0A74DC,$D515121A,$AAAA43B9,$A4E2788A,$99843033,$0705C0CE,$A8140C73,$80501020,$2C076A15,$04192E08,$031C41E5,$79112101,$12122248,$87107802
		Data.l $08000C0F,$54F37404,$20995441,$401054B8,$3344903B,$1BC3D850,$858488B8,$02DF6180,$124C753C,$00070859,$11504490,$921189D2,$D6565AAB,$F5E45205,$C03841D4,$5C323400
		Data.l $E212DA00,$41017408,$54514541,$1241B8E5,$841F9656,$BD1E9174,$6E59A555,$0334E6A9,$54E8647F,$1004245C,$7E596900,$5180955F,$64645800,$F0481874,$C2340DCE,$059C5CD1
		Data.l $9C4498C3,$271AC800,$540B3909,$4205143B,$C0232115,$C5FD6521,$B94601A9,$1420FCF0,$013AE2A8,$32012609,$073EC003,$20243F73,$0FE4002A,$01920419,$21047006,$15052017
		Data.l $21005204,$04CD043E,$654F00B4,$96AA2043,$AA820460,$403702A4,$556A7F0D,$83023340,$35D1B071,$097128F1,$4855494A,$88459920,$235858A8,$4A484208,$52064940,$A808B05A
		Data.l $C64398A4,$EAAA7F9C,$4084475C,$7A14AAAA,$7DD4A8FC,$77554F04,$0EA41122,$4DCF0380,$FFAC6661,$63DBCC03,$B0510021,$3B460802,$B052427C,$04050101,$E25FD506,$4247440C
		Data.l $73601544,$1B525400,$CC42A305,$042986C1,$96BED145,$42016082,$0A0F0041,$FF3104BA,$4A406CDE,$05212521,$522B1621,$4A404541,$C577A24A,$A0D918FB,$48055850,$F0014181
		Data.l $040400A0,$A1015140,$D0D001A1,$08037480,$8C801891,$0058AA22,$BCA320A3,$FC60C870,$06E230F0,$10333FFF,$CCFC976E,$10060455,$D2220100,$20400454,$846C3C80,$9108E461
		Data.l $64819248,$0C64546C,$E294E4C0,$19765607,$84258D0C,$86110844,$73FF86BC,$54444410,$01A9FD65,$26FF19DC,$28320618,$8018B8C0,$8461CC03,$C8000C81,$8A040CAE,$1891D801
		Data.l $01200228,$E2870A9A,$D0110008,$5108167C,$3C436AEC,$0120A0E2,$CB0D8393,$9A502034,$401AE2AC,$E806050E,$010018A0,$A48AD1AA,$20905019,$6F801803,$6DAA611E,$E3A7C02C
		Data.l $6B386080,$289E692A,$1D3A1414,$0FE32630,$0F6B7F3F,$3443D0E3,$6FBFBFF0,$80100A25,$90E0E00F,$077408D9,$160E5407,$2900E416,$3815C0C0,$DC000708,$A2170700,$402A4B60
		Data.l $00805608,$EB1515C0,$C5556502,$F101C1C5,$1C310171,$0601001C,$BC055216,$6A094595,$5E007000,$AB575755,$4000DF8A,$E8A59490,$8016C640,$6A0C43FC,$031450E4,$035956AB
		Data.l $42A40319,$9C101C02,$612AE309,$C0C79916,$A81194FF,$F9F3C501,$41CF0710,$D2FF2D1C,$0F509057,$2AA015FF,$1B53FF00,$480AA846,$B07147C4,$F3D0B0F1,$1F40050A,$F41CF102
		Data.l $FE41D0E0,$B2F7F8FD,$6C3C51F1,$A800456C,$F0005454,$80CE47C1,$8B1F1C81,$7FBF41D0,$02B0F72F,$59040801,$40804084,$44881020,$3C600152,$4155026D,$45458AB8,$9A090AE0
		Data.l $A8FC5485,$3F1582BD,$AB00AE2A,$A9ABAFA8,$98AFABA9,$9C9BEA78,$A1A6AB8B,$B8BBB9A8,$2AEAEA9B,$CFBABAAA,$9ABAE007,$FEBA1496,$91397189,$FEF3D18F,$1AB2368A,$9F3E1ECA
		Data.l $B8FCF8A5,$D51C745F,$E9638FDD,$5CD177CC,$AE29CADC,$BF6ADBCC,$554BF664,$34BF3F6A,$CEA0C09F,$D15587E8,$944408C8,$008C81A0,$0AAAAA38,$120C4042,$92AA3A16,$84008C81
		Data.l $85849494,$00104145,$52121605,$02024A52,$803F3F52,$151D1C15,$1C0009E2,$D4C4263C,$E31A4958,$1017631F,$1840156D,$C641C1A5,$29034444,$03042180,$40CA446C,$87447755
		Data.l $40404137,$440E0087,$4129C404,$871CBC53,$914056E0,$94D5D1D5,$1F17150F,$35121A1B,$95D1559D,$4C6C1191,$BD017506,$1C143583,$01A93C73,$2A134C54,$6501AD12,$8469B790
		Data.l $15111915,$48E61240,$54DBC411,$91454544,$0C4590D0,$1BE095A7,$52131555,$07074F93,$45844653,$8B9F0690,$51AA5C44,$96800813,$80088095,$15959175,$E7043150,$FF7C47BC
		Data.l $EEEFE0EA,$ABDF45EE,$6DC1FB0B,$B354EE08,$EFECEE50,$3AD1C0EA,$ABFB3BBB,$E8E4FF03,$BBC31494,$11AF30BB,$90A62683,$82869E8D,$903E0C83,$83090011,$8D9F8F83,$C2AA2046
		Data.l $6599762B,$F89F6F9D,$66895256,$569C5D6A,$66895691,$9AAA2A99,$9AA6A69A,$1A007A67,$7D7C6075,$9C7C537E,$4E8F9E9D,$8A58F0BC,$7C9CABEE,$7F959F95,$CF8EFA45,$8B56FED6
		Data.l $857FBFAE,$EC5F91DF,$165C20D2,$CEFE52FE,$A97B1621,$57772EAA,$949F734F,$F5776EA5,$C6FEB3BC,$5B2EBC1A,$9C318844,$40BC5321,$100A0030,$192E3415,$2330BF5B,$10210200
		Data.l $BB3C1120,$44C8AF25,$8C557F11,$37FE123F,$12372615,$8D62E326,$E406E2FF,$24DC04F0,$D49454FE,$054000D4,$0008CC38,$08048880,$FEFFFD04,$A0F2A2FE,$DC9854DC,$56FD1E48
		Data.l $6186F0AB,$406A4206,$6AEAA580,$10D5EAEA,$EFDFCF06,$DECE8F70,$A7A5A72E,$F9A5F6A7,$4C6E55F9,$556A17B1,$8D60CCEE,$5CC9E955,$6A189CA5,$D14510BF,$04A1E100,$459EFEA5
		Data.l $EAC56F41,$C0C0EFEF,$1438C5B2,$53F90900,$03FBFBAB,$D5D5C301,$565A1915,$C75C5757,$959EAB55,$5751525C,$0F1C7A59,$BAF6FA9E,$B6B694DA,$98534F9D,$FB3F6A5F,$2AFA7EBE
		Data.l $9A9F85FE,$93C19085,$FE5A406A,$AA7156AA,$98956500,$56A71689,$7A600A56,$01A7E7A7,$7F7AE716,$617F2918,$0F8F8FAF,$FE592D34,$A48DFC14,$D17F08C1,$90075312,$31F0AD41
		Data.l $A4999195,$6499A6A6,$4A5A6256,$061A7BE5,$54B59FA9,$4F5FDFD3,$488A8DC6,$D5147AEA,$0668FCC1,$02967FD8,$739F1F5F,$D59148DA,$41F0EA93,$81C7D4D0,$495DD850,$40D5FF0E
		Data.l $38D57F15,$C0F19154,$DB824304,$4001177F,$09D8C540,$8070D030,$5545EBAA,$EA9E0F10,$F1C5177E,$10FCFDFD,$5FEAEA0E,$7F3FFF25,$7D3DFD98,$AC47AD84,$D0F46000,$DD771541
		Data.l $729FD1F4,$8B535737,$B8F5FF8F,$5040A6F1,$1F1A4555,$01F1444F,$A41F0E39,$45479191,$65656A2A,$55F555D9,$03080280,$73D9535C,$0182010A,$560A19E6,$7CFF08E2,$45E37571
		Data.l $C5C51961,$53434F3F,$BFA80114,$F1F0FCFF,$EA4A10C5,$5457530F,$1774F09C,$78858141,$517C2014,$1515175A,$9FA72C45,$A18ABF9F,$F6DA7F55,$A6FE5AF6,$A95440FE,$9091A3C7
		Data.l $FAEA2A02,$0A1A4ADA,$F27FD76A,$52D345C5,$7DFF7D14,$AAFB5514,$8FFDD7A9,$45C75153,$D1D3D3D2,$D2D2D0D2,$B094D494,$E2D42F85,$50874707,$F0C145DA,$6220FC3F,$EB14040E
		Data.l $053CFFC3,$0F4351A7,$CD083FFC,$C21D000D,$89DF0E20,$E80A0842,$AAFFCE60,$3A965AAA,$07907A30,$7B7A797B,$8906707B,$803209E2,$5DDD054C,$1DDDDD9D,$2AC04AE0,$9C85B821
		Data.l $E0120864,$5FFAFF0C,$CFCECD94,$A5C5CFC5,$0DEEDD44,$F29580A2,$02A005BF,$5537353F,$5C90FF6C,$D346F5AF,$F353F3E3,$FC49E250,$56027C7C,$7A24FEFA,$81087881,$14940C1A
		Data.l $04F81AFF,$1E861CE2,$3F1CDCDE,$111C3C1C,$10131DC5,$F7550151,$E35400F7,$005F6040,$A4121312,$4169133F,$9D55FB98,$5DE77A9D,$A8BB0592,$81A074A8,$94848585,$9C7107C0
		Data.l $2E0391AC,$BE66FE03,$66BAFEFE,$6F59BF13,$596E7F7F,$7DD683C4,$76DEC1D4,$7D97C25A,$5D774317,$96A8AA96,$91A8A4A6,$2A5AAA95,$628A0A2A,$F8A85866,$7DF86DFA,$60C2AAFF
		Data.l $A1A93038,$AEA1A934,$5505A003,$023D4C40,$B220E068,$4015ACC0,$A1125A4A,$E28784A4,$0B4D901D,$F0F3C388,$8807603D,$1F433330,$34040612,$9001EF08,$3693E390,$F8688487
		Data.l $C3F3F33D,$C03F0F0F,$3033731F,$7EF32E3C,$F1E30101,$04342D60,$A9A1A106,$AA0449E4,$404C0C3C,$AAA00555,$CFCA0C0F,$204E6154,$2A6A4A5A,$68324104,$80AA0BC5,$0291DC85
		Data.l $E312A252,$808F2484,$12E383E0,$02F2D560,$4AE328B6,$40380B62,$84640420,$7464B004,$78C48AA3,$7A5A55C8,$634A6C70,$09AE0E63,$4062428C,$26C4246E,$6A0A6060,$FC0A0842
		Data.l $6124A030,$6A6AA424,$158E61EC,$1AA4A4E4,$0CFB8E01,$2C150884,$5412702A,$4E058585,$30848933,$3F582496,$3F333C33,$33FFAB54,$02F033CF,$B3F3004A,$A00333F3,$979786E7
		Data.l $DAFF03FF,$955A8280,$3C3E6444,$2CA00A3F,$7F4F2F7F,$4E404068,$02A1F102,$91225A98,$42A41082,$2D3C7F26,$40084810,$02223138,$55020282,$C05004DB,$440A8CC1,$40D04041
		Data.l $602220F7,$1505C0E0,$343D0F00,$FF30B900,$C84CD91C,$CCF0C000,$34300965,$F20F3F3D,$C2CC0768,$33E33021,$F0F3733D,$8D71B9C1,$55A80B0D,$0DB04143,$00188E48,$1A045401
		Data.l $A854A095,$A0E334A8,$D80DB02A,$CC21BE29,$E3C07A37,$01AB2454,$80E37203,$37060224,$6036E332,$C4C42031,$96E4F800,$56882A18,$57007324,$3E502404,$A200F1C0,$909A9093
		Data.l $41E18095,$C8A901F1,$C3B033ED,$40700C30,$E0707068,$C8E3C00A,$76783360,$39C2226A,$E00C2C0C,$B21B50B4,$06C2CA3B,$9BD50010,$7F55C89D,$942FD32A,$D166E479,$10EF9293
		Data.l $03E25446,$60E30A01,$B9021F03,$6064E340,$0743B15C,$03351D05,$547450C5,$C0F0575D,$30217151,$722181CE,$0AF30810,$5CDD4200,$4D0BF91C,$9092D35B,$401F1037,$F82645D4
		Data.l $8030C8A0,$40B1D820,$90959512,$90919392,$011C4293,$B1D171A1,$06098971,$12E2F51A,$96452120,$211A4007,$C8658422,$6062E328,$020255E6,$E22CB2DB,$2C2C2008,$205A840E
		Data.l $AC000260,$01207829,$E380EEB2,$33E63824,$152A410A,$2C03B03F,$24249291,$80461210,$906A6A53,$62405C01,$E5806060,$93614CC3,$40E19CC1,$8D80F620,$A4A46485,$40812604
		Data.l $4002A324,$405E4240,$7DF10250,$19748A00,$B6808A88,$00C9060D,$5000D6FA,$9466B864,$F830AF16,$3800E8E8,$42935228,$C51F1544,$678E8478,$02652207,$619A5071,$20FCD020
		Data.l $331564C9,$73801C55,$5148CEFF,$0C40F80D,$60808985,$89C42083,$95FF62C9,$FF150285,$111B2439,$52545CFC,$8638640C,$0E190334,$800C8DAA,$80808685,$0A141F28,$05C38468
		Data.l $3C41888B,$51543115,$40514654,$A0405044,$4044009F,$E3005436,$D1866022,$00010116,$03A82028,$0F614604,$08EC0286,$83546C48,$22A21200,$AA500002,$014009E2,$52050020
		Data.l $141C6765,$07001085,$28405871,$02904000,$D0850594,$88069809,$1C5BA140,$3F00E114,$0A005D2A,$4A481134,$88888040,$2C9680F1,$5806E250,$5B8C07A0,$721080B1,$C7444B09
		Data.l $803770B5,$D7808487,$00771177,$C0114477,$3373509B,$1D3D3D0F,$CC0C014F,$DDDFDFCC,$2447E3FC,$545397B0,$2760F4E3,$F171F1F1,$28D555C5,$2015D50F,$2855AAA6,$0D300C82
		Data.l $8E040405,$0D2901DB,$301B950D,$54A4A454,$E3551004,$2D4E6023,$EB89A99D,$E24E0A9C,$83B29755,$3C8E2097,$002C0DE2,$06462C36,$416D0232,$8E282CA8,$55028A0C,$00880069
		Data.l $2F2F0022,$AA0015F6,$3C41C4C0,$00880055,$027AF8F8,$1540083A,$4C010045,$50002A4A,$10004050,$F325A210,$1FB8A2A2,$AC2B0CE3,$000BB454,$22020058,$05E30222,$150BC623
		Data.l $BC6040E3,$144050D0,$FF05E285,$86848081,$82898E1A,$8887FF83,$46150B50,$63550E0F,$57131211,$47461715,$07060D03,$100DA91A,$1E1F1691,$FF2BFF20,$1D2C2928,$1C222326
		Data.l $F5042A2D,$21242504,$462F2E30,$32FF31FF,$290B0CFF,$18134C78,$42090A25,$1404C53E,$12060515,$F0871011,$E2000116,$1A1BFF0F,$1D1113FF,$190F1C1E,$171F18FF,$FF221216
		Data.l $FFFBA814,$0E0DFF15,$040620FF,$0A211005,$030C0BFF,$08FF0902,$0B86FF07,$8EFF015E,$FEF1C780,$FB0380BD,$FBB2907F,$A8FAFF48,$DC3C2E18,$0F6B6F60,$D1F822AB,$0B104705
		Data.l $2F6A60A2,$803ECC9B,$C010250D,$BFE01F07,$01E51F09,$0EBF0307,$050EFBF3,$22E9C05A,$F3143F00,$07FF38A1,$33F1DCF3,$130F4DA8,$1514130D,$313C0400,$5707F3DC,$7A6523E2
		Data.l $3E3F3C3E,$F3E04690,$3C3C7CFC,$1F1F3F3E,$3CFC4007,$F8F8FC7C,$080980E0,$E909131A,$3C28040C,$140C1428,$AAFF0D10,$E26DA255,$EAEBC3FF,$5E49DBD9,$73C02083,$C05F0C07
		Data.l $C63F0D7F,$0BC01F73,$D7C35CF3,$984BC7AE,$C78C45C7,$41478642,$04E2581C,$02050352,$3C00833A,$F406C4DF,$52696518,$2FE2BA06,$B7982C00,$212A535A,$6C53D01B,$01B302C4
		Data.l $8D0C2121,$4008800B,$01B30644,$5146C502,$210AB191,$04620902,$4D032C20,$06A08402,$08800A88,$882A881A,$4021C04C,$6D2332C4,$80AB02C0,$9C01AA01,$0027360A,$C004F6C0
		Data.l $0489B002,$016C00A0,$AB012BAC,$1B106911,$F188B914,$28F0C858,$E2A04388,$31E200FF,$7ECA03ED,$30020FA7,$A0AB7D0F,$3B907F10,$A85E516F,$A87EB4AA,$A513BD19,$405E1AA8
		Data.l $03686E13,$D607687E,$1D01131F,$BC15A87D,$02AA560A,$66A63FC3,$00652600,$A90295A5,$68A40A24,$BE995105,$05E28527,$478CFF17,$0208BB3D,$06FF181F,$280A807A,$0780FD09
		Data.l $BD0E0280,$A0FE0DA0,$A50DC059,$AAAAA07A,$A8F66A55,$11409616,$406D4556,$03A87EFE,$405D517D,$D644DE10,$04C00FAA,$09AA9607,$5A0A9A9A,$99990B84,$A895898A,$8004AA99
		Data.l $021A6AED,$500904A5,$BF70C3AA,$19F83C88,$00EA1FC4,$F61F4E2F,$40F93E80,$FE3D6005,$80BE3980,$FF806E19,$16A0BE05,$B640B9CE,$A05A6AA0,$15A06D65,$04360BC5,$F60DBA8A
		Data.l $01480DAA,$0BAA7607,$5A09A65A,$669A02A5,$0A669802,$902EEA94,$01198406,$04461502,$E397F2FF,$D52639D1,$939697F0,$FE0B807D,$0F607F84,$C6DF1DBF,$FBE8975F,$01789C01
		Data.l $20A9246B,$0668A602,$7F01A85F,$587E95C0,$0F70FE01,$0440E942,$40FA44F6,$76606A1C,$04400140,$590AC409,$0019E68E,$235004AA,$88801C55,$9F981BC0,$FC0DE2C0,$7E0AC506
		Data.l $40FCCF40,$6F040FC4,$70970FA0,$5F0EE09B,$E8E705E8,$A8DF0DE4,$6A685B1F,$A969686A,$BBCF1158,$0298A701,$EE03985E,$F180035A,$02DA65C0,$A696E695,$04D2A800,$65011A66
		Data.l $29010429,$14A40069,$E43E9052,$9087F1AA,$8095C857,$0B607E06,$FF07A0FF,$E0EF0FD0,$06F8970B,$961FF89B,$F8555A78,$B4E595FF,$5DA4D9AD,$5605A669,$8502F09B,$FD019A76
		Data.l $56F94200,$6956FA00,$DAE903DA,$0B1EF501,$69900864,$82659082,$70A26580,$006A5A44,$A9002A2A,$04A4021A,$7FE65001,$F0B71E41,$FE2F0057,$0EBDDFDF,$7F2E805F,$17F29F80
		Data.l $07EB609F,$6D7D7BB5,$68A9AD60,$5668A5A6,$56066896,$445E05CE,$B20168A0,$03AAF903,$AA800143,$01335502,$91029A51,$025A159A,$800A4680,$2E102A01,$551220AA,$97F11F92
		Data.l $100F808C,$5ACBE69C,$5A1AE8BC,$2F80F6D0,$3C1E80FA,$80FD3E0B,$6FA8BD3D,$607F39A0,$AB606F17,$05609D15,$017380AD,$991A60A6,$A8791AA0,$02E3F905,$2601A8E5,$8064D0E6
		Data.l $76F3F640,$A6960222,$00A5A500,$2459C0A1,$14A40058,$40025800,$00A80A04,$56745405,$692C3E0C,$A040107C,$20AA0210,$01DA3038,$65CEA059,$99504860,$051198A6,$6AC85964
		Data.l $1B0A0441,$E05A2810,$4616E324,$292AA100,$0A0468AA,$A846A081,$04C0A629,$64AAA968,$AAA4AAAA,$4AA9A8A6,$40A6692E,$1664A60E,$62066066,$90411950,$5AA4026A,$01159402
		Data.l $FDDC5550,$162925EE,$C11A4210,$402A438B,$007029DE,$5600F059,$906A0160,$05506606,$9A0970A6,$F59A1970,$F602F05C,$28EA9926,$D86B26E9,$946B6AAA,$AAE0656A,$A05CC0A5
		Data.l $4099AA50,$974697AA,$D0AB0111,$12A923A9,$99F09681,$9599D096,$8E955950,$5219C00B,$A211F91E,$81D00551,$00E54029,$7D67BF94,$40104085,$2A760955,$005014E8,$6794602B
		Data.l $A700B027,$E0A602F0,$09585502,$73E0A8E9,$FE0BB801,$ECFE276C,$2F9CBD2F,$AFA0E56E,$D0BA2D64,$D05F2FFF,$2A94952F,$D22698A9,$586929FD,$A9D457A9,$0B88C0D7,$E0DFA7D0
		Data.l $D7A740A0,$E056A6F0,$C550569E,$A05540B3,$19A05169,$102AA010,$AA002A98,$15A9B9C0,$BCE21440,$01084EB2,$01201EC8,$9A0254A9,$02205622,$206622DE,$0200EE02,$BA2600FE
		Data.l $90561A40,$7FE899BD,$BBBFF4EF,$F867FFF8,$EBECBBEF,$9AF6BCEF,$6E66E5BE,$9ABF95AA,$A5955556,$A9A5686A,$6867A768,$6C94DF5B,$DF1F8178,$2F521FD0,$566EE49B,$745676E4
		Data.l $66D4555D,$55696456,$A44569A4,$24A04428,$06C06040,$00A4A88F,$540054A8,$620CE2AA,$0100A05C,$38101612,$906A71A6,$5A043882,$BA4CB6C4,$83E60080,$1980B6AC,$A01B80F6
		Data.l $80FE0A05,$5EA0FE0E,$A64384FA,$F6ABA0F6,$A8E6ABA8,$06A8D55B,$6E01685A,$EF610268,$03739203,$0FEA2811,$AE0FAABE,$0A9A4694,$054D9A06,$34AA8502,$810A6681,$63168034
		Data.l $4555A582,$1CE2A850,$1E2565E1,$46594505,$39009A3D,$C816FA02,$98790600,$805E8189,$A87DA614,$A9A8FDA5,$186B68FA,$A3F61BD7,$2DAADB6F,$3D2DAA7F,$FD3ECA6B,$044CF948
		Data.l $6D0AAABD,$999902A9,$2A99950A,$8F9C5A91,$564055A6,$D7F023E2,$A02E0088,$00A01600,$B717982D,$39FF80AA,$7D16A096,$A0BD0AA0,$3568FE3A,$7F1A2E97,$685F0240,$AF66265A
		Data.l $A0BD195A,$97726D05,$4E663D9A,$DD00222D,$6A0DD26A,$A6FD0A20,$AAAA7D2A,$51556996,$1CC01599,$0E83C4AF,$0A902CA2,$C1A63C2D,$29609669,$5F29A867,$6E002E13,$6F067211
		Data.l $6AFF06A8,$EBC2FE02,$59005ABB,$225E0190,$2F6AA60B,$9AFE54F9,$3E5AEA3F,$551F5A95,$6AF5196A,$7A405126,$34A9081D,$690DC002,$2999A9C3,$A0A549A4,$6D905645,$0AE2407C
		Data.l $F110EACF,$A9A09F80,$EA1EA343,$83A91AC0,$5B0A6016,$E0AF0998,$0BD8EF05,$02A8FFB6,$6F8E5FBB,$5A3D006A,$0B42F202,$6800945A,$BE1D883E,$9FBE259A,$095AFEFA,$F90A5AF9
		Data.l $2E07F701,$2A6A5E2A,$6949A904,$0A814354,$80592A46,$45654518,$0104A502,$0007E250,$1DB8D0FC,$41D8F0A8,$561D8F2A,$909DFCF0,$07A0E509,$FA06A0F9,$98FF0160,$AAD8BFA0
		Data.l $DF5AD87F,$EABB19D8,$2EAA6F25,$BD3F5A5F,$29D53E6A,$E42FFFE1,$228F6627,$407D4559,$BF09C0E6,$6ABE295A,$5602E0A9,$6AF124FD,$0288F101,$91029A61,$A0F05028,$1D9B0289
		Data.l $02580A04,$47860760,$7D8786DE,$471F6328,$96E49E8A,$68165649,$E69E6F1A,$08A00981,$07D8FF0F,$AB05E8FB,$5A97CF08,$0F6A5D01,$9A3D0663,$6AF6376A,$C61F8168,$3D5AFA3F
		Data.l $0E1E5AA9,$088027B8,$021C5CC0,$0AAA9502,$99842D85,$A949FD36,$00544540,$843F0344,$FF0009E2,$4F4313EC,$029FA00B,$1368E1A8,$6A2D143B,$3929803D,$0AE036C3,$5B0A9866
		Data.l $06D88153,$EC4F02EA,$14E8FF01,$6AB90124,$0BA37000,$80EAC3E6,$3E9AFD3F,$BA1DF30F,$146A275A,$1A55040E,$650A6A81,$AA562A6A,$E0C0AA99,$51A9A040,$45A80299,$0A45A402
		Data.l $40050494,$0006E204,$200EA4AB,$A04000A0,$29688005,$A01A2890,$1A0BCD28,$161AA02D,$906D0AA0,$0B807D0B,$5603A079,$68E60268,$28989B28,$2A02F064,$9F1AD86F,$AABB16D8
		Data.l $1F25C606,$EE2F6ABF,$6AF526B4,$3B42FD09,$407F45FE,$9AE4AE04,$04D22A5A,$556A95AA,$6AA05469,$61790041,$49109111,$80029AA1,$0A0103E4,$04134980,$40A97C10,$86495400
		Data.l $438A0434,$239806C8,$F87109B7,$E8090A20,$00680600,$0F0B800E,$9A0B00D8,$80552580,$2E606B2A,$BF3DE0BD,$F8BF3BF0,$5BFC7E76,$F9DDFEB9,$5AAE9FB6,$A9FD67FF,$DDE130A5
		Data.l $65A4A9A9,$651558AA,$030B8868,$EF075ADB,$34E70BDA,$D710A05C,$5A960FDA,$0A9A9509,$910A9955,$65510A69,$2A65110A,$C170A900,$A808A863,$55540155,$789DFA97,$C1E06414
		Data.l $F91B00DA,$9FA08980,$BC89A0F8,$FD7F9A7D,$DABB979A,$721F96A9,$65BE6718,$A95D7EA5,$65AA64EA,$565068FE,$3BA981E8,$4737E087,$80209AEF,$8F93F740,$3CA9DF86,$2191F005
		Data.l $E257E07B,$37075FD1,$146AA3FC,$6A010655,$1ADA021A,$0386D903,$E005899A,$5A6516DC,$9D9A9F6D,$FE67D6BF,$FD7EA6FD,$65B5BDA7,$EA51597A,$FD01AA54,$555F06D7,$01024C58
		Data.l $650168A9,$FC80DBAD,$EF016ADF,$40B2026A,$F5036AF7,$C1E70269,$02A95505,$95A23095,$00559200,$A0025AA1,$79540A6A,$15A5A22A,$F7115051,$1CC70741,$940B3E64,$00650B00
		Data.l $0E00590F,$693DC669,$80590180,$0AA05B02,$6B070B89,$14807A90,$0BC7085D,$98AAA0E5,$3C79FB1C,$8D000214,$091E5800,$00C80899,$5A05586A,$22DA023B,$A06420D9,$BF937E1D
		Data.l $FF850226,$C8FD0880,$6908A2BE,$0880DD88,$19AA40C0,$022C05C5,$00AA0985,$20170165,$0EA0086C,$6A53746A,$0B260FA8,$6A090220,$022F66A4,$59029A65,$60950254,$2AA0920A
		Data.l $8AAA9082,$FF39D480,$4E8AFC65,$80053F89,$1A742900,$04388290,$2D00A016,$A43D0090,$909A3900,$A63B03C3,$806A0780,$EA5EF40B,$07A8753C,$E6C9F1DA,$DDC72BA8,$A8767815
		Data.l $FE519DA0,$88FD2D00,$A90880F9,$20F503AA,$D901A6F9,$886A0A3B,$9602669A,$96CA8066,$0A94A500,$9A2AA496,$40951A90,$04373805,$C33C3038,$00405510,$81504066,$1101A042
		Data.l $A4030428,$02430242,$0B40A606,$D9055069,$11A0A044,$0F600428,$5A0768DA,$A8962AA8,$A8A790AA,$A7A8A6A5,$08829728,$2BAAF67F,$9626AAE6,$205629AA,$35105A17,$02A89A10
		Data.l $5A02689A,$645A0A68,$2560662A,$E8011066,$089A02FA,$54000801,$F217D907,$9137C205,$0791408F,$00AA1A82,$2016281A,$446815EC,$A2B6760D,$4DFE020D,$BF00A6FF,$667BCE0E
		Data.l $AAA1DA2F,$EA69BFEA,$006AA9BB,$296AA639,$6A0A6A9A,$28017500,$0120950A,$6D02AA59,$AA7D0AAA,$09A97D09,$2D04B5E5,$02232504,$59AC0760,$00490800,$14502C28,$A02A0A2A
		Data.l $D0801608,$D40EE249,$75385028,$E0502290,$04831681,$64BDCAB9,$8294FE00,$A569C3C2,$0066A900,$6A7018A7,$E99F11A7,$80AAA780,$AB805A69,$A9802E30,$2A69A01A,$5C2065A0
		Data.l $ED044099,$A86AFEA4,$FDA06AFD,$C000B800,$9990C9A0,$A9A9091F,$A8992990,$59A09040,$5064A890,$A84044A8,$005A4004,$81D51540,$04205A21,$98284400,$04DB0500,$0A01640A
		Data.l $04800432,$0D00A40D,$80A609D2,$0180A906,$EA03A0A9,$6CDA03AC,$0FAFDA0F,$C30FABFA,$ABF6AFBB,$9E80D6A7,$6BAAD6AB,$991AAAA6,$207905AA,$6103882F,$113EA0A3,$3501103D
		Data.l $00AA1511,$82D0A929,$3D0A0438,$10251169,$6A002609,$E2150012,$4502E123,$4869142B,$9A3881AA,$9E214488,$92660220,$FD0220ED,$B9FC0040,$9924568A,$EB007A96,$C0DF80F9
		Data.l $80FDBB05,$BB80BE67,$AFDF607F,$609F5A60,$D9606E95,$BCF5606D,$68A5F60B,$96589956,$7A855AAE,$6217286A,$8266F683,$5540A6E5,$34E2FF9A,$02005E60,$8001B202,$C2504D44
		Data.l $09945A00,$52AA9896,$A86596A8,$6F6069A9,$5F7FD05D,$58DBBF94,$F968E5FE,$9EF7B8BF,$F6FAFAF8,$96F655F5,$F9A67AA5,$81785E6A,$FD6546A5,$967E69A6,$29987629,$80409456
		Data.l $A9048039,$9E604C10,$060064C8,$C414009B,$0B00A805,$660F0068,$806A1E00,$6980BD15,$AF05D5FF,$A0A76AA0,$F380FB16,$7D06A0FE,$A0D50FA0,$FDA0E503,$56473203,$02A00468
		Data.l $9601A0A6,$A866016A,$07A87A03,$08E1A8BA,$DA0FA820,$9A9A0BAA,$0A9A5A09,$99029A59,$55590296,$0A698402,$822AA880,$948AAAA8,$FC404555,$12D00CE2,$0006023E,$95004051
		Data.l $10406554,$95AA00A0,$02009A0A,$55010069,$50760700,$25A4F516,$6B3B689A,$FAEF3EFA,$2EBD9F2D,$BE1FBDEE,$EB16407E,$9FFE166F,$66565425,$A9A55A5A,$A997A59A,$57695F96
		Data.l $7F07696F,$5A7F8756,$6758BE67,$9D1A50BD,$6AE31A64,$965ACB60,$44A61669,$6AA502F1,$861AA405,$904A05A0,$ADCA0500,$9C0C66A1,$1AC60A81,$7B20C1EC,$2080ABF2,$A2086807
		Data.l $4AAC200E,$BDF1C473,$069DFE90,$E3869DD4,$207C0016,$F920FE56,$FC6020FD,$ADFE1B4C,$11F019D0,$1920A348,$F1802E2E,$78AD65A8,$8D103012,$818009EC,$64D18B50,$FF658DFF
		Data.l $180AB096,$F2011B69,$396948A5,$036CF202,$92F254F2,$5E349AF2,$F2DF0C50,$3760F2A5,$0584BCF3,$18F4CAF4,$F63868F5,$F30BFB58,$F080F6DE,$76F6460D,$0DF7E4F7,$3BE907E0
		Data.l $75F83607,$98F8BBF8,$A1F7A5F8,$8BD82F25,$0DF6E4F6,$FB520EF7,$0119B000,$3007E236,$6340E345,$50331812,$E2C82827,$28134006,$4B1A8004,$13F253AD,$07498317,$0DF2918D
		Data.l $188DF290,$B94060D4,$430C003F,$A9FBD94C,$4624DBFA,$A838603C,$13C0FE12,$55C68FB3,$C7884AC6,$714AC6D5,$1C52B1B5,$1C10D184,$C68CF02B,$AE0785D5,$07588CB9,$A8075570
		Data.l $A2202B18,$64ADF120,$C01CF893,$41CEF9CA,$33C64AC6,$F0732B02,$CE08A218,$730581DD,$0F3C2C87,$63B90850,$84D59EF3,$D4F45C71,$54FC2319,$8C45C422,$478642C7,$4864140D
		Data.l $7017C808,$0D5C3044,$030008F8,$230B1410,$07164423,$960787C5,$140C02C4,$0EB2031D,$64640386,$10581428,$8BC58530,$41508F03,$00807850,$180C80E4,$0B4C773F,$42864108
		Data.l $2604E251,$00100260,$D4485003,$2B21C414,$78C45CD0,$20EC135C,$00111200,$16BB1011,$6F4CEC0E,$24EC9B4C,$451B341B,$14DC8216,$1BC5E036,$1E1C20B1,$14801C90,$AF80EC1A
		Data.l $05B503A9,$B30604E1,$104D3860,$6857105F,$41FC8A70,$7A4414F5,$0C34F857,$A0944F48,$76589708,$4F972060,$1F4A8643,$48D834F0,$F1806803,$5CF5F884,$60306804,$43571701
		Data.l $66A05421,$44787434,$1012B864,$17037512,$1072C30D,$3283138C,$07201631,$121400C5,$17581417,$C8141480,$05003141,$16D51216,$C8120C86,$05003141,$0D141014,$011113E5
		Data.l $140F1305,$0F174158,$2B160F19,$02424808,$E24D2226,$0D802F08,$718D8475,$0B0A5702,$0B12D150,$1014F110,$E40F34E4,$640D000C,$8D9449FD,$47AD0003,$4F400349,$199D390A
		Data.l $5C1E175F,$83907858,$8D0ED38A,$0088D487,$23184B4F,$4C603460,$249FF6AF,$7F14D40C,$868A0328,$2E1CF307,$1E1A2685,$F8018855,$5281AB9C,$43D7F736,$11E1DFD1,$997F460B
		Data.l $C786C3C7,$90730541,$0CC11D31,$0C0C0E0F,$0A000C0A,$025C6008,$F8720312,$6095F8C2,$2EC70715,$C22CA605,$0923C43F,$10C80F0F,$4CAF00A0,$30E39D18,$110DB143,$3532A22C
		Data.l $02E6507C,$071A9941,$0712C565,$7663C2A5,$4111A503,$AA20F0D9,$C3ECE732,$83268752,$20F556AC,$7D88FD3B,$F0A32E32,$FE899148,$A918A0B2,$8A2F2B10,$443C2CC7,$443AA28A
		Data.l $240E3C66,$A80E6444,$939FD218,$72055A38,$691DE65A,$31C70199,$1E52E502,$7C0F1F94,$C8A992EC,$14B2FC1A,$92B9A83F,$B91F57FA,$713DF912,$924CFBFB,$1087D8FD,$0A38828F
		Data.l $2300A080,$84900042,$2345280A,$03485DBF,$09F9455B,$F0F878F2,$0CC3A838,$0A0A0B0B,$F8000C0B,$41C787C3,$1011061D,$100F0F10,$0F111411,$E3A5C811,$BBF96111,$067A16ED
		Data.l $19819A18,$391BA066,$0E2818C8,$0DE21D00,$1E002000,$03001DE2,$44047903,$21E205CF,$785425F8,$45450010,$54266CE2,$00061078,$EE6C2121,$1E210F17,$0901B02E,$050D320A
		Data.l $D008050C,$1078843E,$05010301,$0A0C01E0,$07010801,$B4F0CBB4,$30050131,$2462AA04,$4C4650C1,$70013C09,$00111901,$140DF313,$10E211EB,$0E530FAA,$45D00D00,$320B0514
		Data.l $6444D00C,$34CD050C,$C30A0005,$3307CC1D,$75154850,$A913B213,$A6058D09,$1314800C,$A920A0D4,$2020A220,$08A9FC49,$F0FD7C20,$91B96001,$20183F72,$A903B011,$1A200C39
		Data.l $FBC1B9FC,$FC23BE00,$944C01A2,$83F057FD,$0101423A,$61003AB2,$98B0688E,$07070808,$05050606,$0F8F0404,$03030202,$83603A60,$8D01A98E,$F189A482,$C8F15500,$8B6B8D8A
		Data.l $E0E88545,$A9F8D018,$D4188D0F,$CDF2908D,$F0AAA03D,$8DF0290D,$0EA0EF82,$D64B8AA2,$8EFC144C,$740114A5,$07AC2100,$8E104107,$0EA2FEB3,$60FDB520,$CD5238B2,$20144572
		Data.l $B90FD0F6,$FE8A65B4,$2998C8E8,$D007C907,$8E2DF192,$1FC01A74,$20FF6E0A,$6FAC0AF2,$FC2C4CFF,$BD0B80FE,$8DDDFE9F,$8700B0FE,$FC824C80,$F0FC8AAC,$29D5E103,$8E07500F
		Data.l $8BB9A8FE,$C27D18FC,$0160D069,$0D0011E2,$8C879014,$14D87800,$90100A00,$1E784487,$0820C432,$38E21E40,$F908C879,$30380580,$1C40A840,$1CBA1C30,$0183A838,$FFFEFF00
		Data.l $01604D49,$24241802,$24303C30,$F8000C18,$01031D41,$E279FF01,$52181800,$D00C0C71,$17001140,$40871050,$101C0021,$07A005E2,$30793B01,$AD0C61A3,$1F2945B0,$5C3D98AA
		Data.l $AD13F0FD,$CC8DFD5B,$A924EE05,$44D38DDE,$CD8D64A9,$CECB8060,$879AB31E,$03A1E6F3,$CF29B7A0,$A300A220,$E301A380,$2380A2A0,$AA20A3A0,$18728ECA,$EE6004BC,$4C80CD88
		Data.l $CC191517,$0A64A260,$F255B917,$20CD28EE,$8D8D0506,$0B490B65,$AE05108A,$8AE8F253,$60F1818D,$29BF388D,$60015191,$6DFEA55A,$0A33C56B,$9D730269,$649D9E6A,$9F9D00A9
		Data.l $0EA02104,$F0C18AF0,$8A302A03,$FE0401A7,$760C2804,$1C0DA430,$0108A2A0,$BD1CF007,$20A1DD63,$09B0142A,$4CD8447D,$8FFDFE14,$2590A015,$BD60FEA3,$06A0FEA4,$30E98838
		Data.l $6918FBB0,$11EB8C30,$9064A80A,$73B9C811,$07A18DFF,$F0FF6EAC,$6EEC4E09,$D0880520,$5A66ADF7,$67ADD400,$F2012380,$F0FE89AD,$FF64AD0B,$8BBD06D0,$43213CA2,$8C7D18A2
		Data.l $E35D9DFE,$0D8C600A,$029DFF6A,$FEA2BDD4,$1D4A8E50,$039DF186,$9C2460D4,$001CE220,$0BE26C6C,$F8F4F853,$41C13901,$DE040B01,$01CC3C05,$021075C0,$08F04F8F,$A0045010
		Data.l $1D0710ED,$83084150,$302915D4,$37400670,$72306419,$D1378080,$1C30405D,$2D173481,$23039332,$100F2016,$72DE1F39,$3D500880,$FE43C81D,$017142CE,$175008FE,$01401ED1
		Data.l $0A20006F,$80E140F0,$341018D0,$0507190E,$A2652800,$01147B60,$08E201CF,$FF000175,$97000584,$4D806E7E,$1E843282,$0C881186,$188C0E8A,$4190298E,$8B946292,$F498BB96
		Data.l $7E9D359A,$2BA1D09F,$FAA68EA4,$EEAB6FA8,$06B075AD,$45B5A1B3,$ACBAF3B8,$3AC06EBD,$F3C611C3,$D6CBDFC8,$E6D1D8CE,$23D7FED4,$8FDE52DB,$2BE4D6E1,$F8EB8BE8,$F9F272EE
		Data.l $E2F98CF5,$5F8C8607,$8828F0C8,$E2FF4700,$5500A204
         C64ProgrammEnd:
        EndDataSection        
        BytesTotal  = ?C64ProgrammEnd - ?C64ProgrammBeg
        BytesLeft   = BytesTotal
        
        *CBM.cbmProgram 
        *CBM = AllocateMemory(BytesLeft)
        
        DataBlock = 0
        While BytesLeft
            
            *CBM\l[DataBlock] = PeekL(?C64ProgrammBeg + SizeOf(long) * DataBlock)
            BytesLeft - SizeOf(long)
            DataBlock + 1      
        Wend
        
        Define SaveFile = CreateFile(#PB_Any, GetTemporaryDirectory()+"cbmprog-a.prg", #PB_File_SharedRead|#PB_File_SharedWrite)           
        If ( SaveFile )
            WriteData(SaveFile, *CBM, MemorySize(*CBM))
            CloseFile(SaveFile)     
        EndIf 
        ProcedureReturn GetTemporaryDirectory()+"cbmprog-a.prg"
        
    EndProcedure      
    Procedure.s TestProgrammC()    
        DataSection
            C64ProgrammBeg:
                Data.l $080B0801,$329E0000,$00313630,$40200000,$8536A908,$00A97801,$A200F78D,$00F88E09,$F98D00A9,$8E80A200,$00A000FA,$F991F7B1,$E6F9D088,$A5FAE6F8,$90C0C9FA,$A04C58EF
                Data.l $A000A208,$0857BD40,$E8FFD220,$A9F6D088,$D0208D0C,$60D0218D,$11111193,$1D1D1D1D,$1D1D1D1D,$1D1D1D1D,$209E1D1D,$52415453,$45525420,$118D204B,$1D1D1111,$1D1D1D1D
                Data.l $1D1D1D1D,$43051D1D,$4B434152,$42204445,$45582059,$8D584F52,$00000000,$00000000,$C501A900,$4CFAD0C6,$0000FCE2,$00000000,$00000000,$00000000,$00000000,$00000000
                Data.l $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
            C64ProgrammEnd:
        EndDataSection
       
        BytesTotal  = ?C64ProgrammEnd - ?C64ProgrammBeg
        BytesLeft   = BytesTotal
        
        *CBM.cbmProgram 
        *CBM = AllocateMemory(BytesLeft)
        
        DataBlock = 0
        While BytesLeft
            
            *CBM\l[DataBlock] = PeekL(?C64ProgrammBeg + SizeOf(long) * DataBlock)
            BytesLeft - SizeOf(long)
            DataBlock + 1      
        Wend
        Define SaveFile = CreateFile(#PB_Any, GetTemporaryDirectory()+"cbmprog-c.prg", #PB_File_SharedRead|#PB_File_SharedWrite)           
        If ( SaveFile )
            WriteData(SaveFile, *CBM, MemorySize(*CBM))
            CloseFile(SaveFile)     
        EndIf    
        ProcedureReturn GetTemporaryDirectory()+"cbmprog-c.prg"
    EndProcedure 
    Procedure.s TestProgrammB()    
        DataSection
            C64ProgrammBeg:
            Data.l $083D0801,$35970000,$30383233,$973A302C,$38323335,$3A302C31,$93052299,$3931A322,$3A255029,$3431B24D,$583A3436,$593A31B2,$3A3231B2,$31B25853,$B259533A,$084F0031
            Data.l $C28B0001,$37393128,$36B1B329,$0031A730,$0002087A,$3A30B250,$22932299,$293931A3,$49813A50,$363431B2,$3531A434,$34A93434,$49973A30,$3036312C,$B600823A,$97000308
            Data.l $34323031,$34AC59AA,$2C58AA30,$8B3A3233,$3031B14D,$C2AF3432,$33353628,$A734B229,$38AA4D97,$32332C30,$4DB24D3A,$3A3034AB,$312C4D97,$E2003036,$8B000408,$3931B34D
            Data.l $C2AF3430,$33353628,$A731B229,$332C4D97,$B24D3A32,$3034AA4D,$AA4D973A,$312C3038,$16003036,$58000509,$53AA58B2,$B2593A58,$5953AA59,$3031973A,$59AA3432,$AA3034AC
            Data.l $36312C58,$598B3A30,$B03432B2,$A730B259,$ABB25953,$4E005953,$8B000609,$3933B258,$3128C2B0,$AA333230,$3034AC59,$B22958AA,$A7303631,$ABB25853,$503A5853,$2EAA50B2
            Data.l $22993A35,$31A32213,$28B52939,$5E002950,$8B000709,$A730B258,$50B22550,$6500893A,$89000809,$00000033
            C64ProgrammEnd:
        EndDataSection
               
        BytesTotal  = ?C64ProgrammEnd - ?C64ProgrammBeg
        BytesLeft   = BytesTotal
        
        *CBM.cbmProgram 
        *CBM = AllocateMemory(BytesLeft)
        
        DataBlock = 0
        While BytesLeft
            
            *CBM\l[DataBlock] = PeekL(?C64ProgrammBeg + SizeOf(long) * DataBlock)
            BytesLeft - SizeOf(long)
            DataBlock + 1      
        Wend
               
        Define SaveFile = CreateFile(#PB_Any, GetTemporaryDirectory()+"cbmprog-b.DIR", #PB_File_SharedRead|#PB_File_SharedWrite)           
        If ( SaveFile )
            WriteData(SaveFile, *CBM, MemorySize(*CBM))
            CloseFile(SaveFile)     
        EndIf    
        ProcedureReturn GetTemporaryDirectory()+"cbmprog-b.DIR"
    EndProcedure     
    ; ------------------------------------------------------------------------------------------
    Procedure LoadComma8(DELFiles = 0, Charset = 1)
        
        UseModule CBMDiskImage  
        
        If ( ListSize( CBMDirectoryList() ) > 0)
            ResetList( CBMDirectoryList() )
            ClearGadgetItems(1)
            While NextElement( CBMDirectoryList() )
                
                CBMFileSize.i = CBMDirectoryList()\C64Size
                CBMFileName.s = CBMDirectoryList()\C64File
                CBMFileType.S = CBMDirectoryList()\C64Type
                
                If Len(CBMFileName) = 0 And (FindString(CBMFileType,"*DEL",1) >= 1) And (DELFiles = 0)
                    Continue
                EndIf  
                
                If Len(CBMFileName) = 0 And (FindString(CBMFileType,"FRZ",1) >= 1) And (DELFiles = 0)
                    ;
                    ; T64 Memory Snapshots
                    Continue
                EndIf                 
                
                If Charset = 2
                    ;
                    ; Shift Chars                    
                    CBMFileName = di_Set_CharSet( CBMFileName )
                    CBMFileType = di_Set_CharSet( CBMFileType )
                EndIf  
                
                If Charset = 1
                    ;
                    ; Shift Chars                    
                    CBMFileName = di_Set_CharSet( CBMFileName,1 )
                    CBMFileType = di_Set_CharSet( CBMFileType,1 )
                EndIf                 
                                
                           
                AddGadgetItem(1, -1, Str(CBMFileSize) +Chr(10)+ CBMFileName +Chr(10)+ CBMFileType)             
                
            Wend  
         EndIf
    EndProcedure
    ; ------------------------------------------------------------------------------------------    
    Procedure LoadCBMImage(Reload = #False)
        UseModule CBMDiskImage   
        
        
        ; For the ListiconGadget to change the Header Titles
        ;
        lvc.LV_COLUMN
        lvc\mask    = #LVCF_TEXT   
        Pattern$    = "Images (*.D64,*.D71,*.D81,*.T64)|*.D64;*.D71;*.D81;*.T64;"        

        
        If Reload = #False
            dsk$ = OpenFileRequester("","",Pattern$,1)        
        Else
            dsk$ = GetGadgetText(3)
        EndIf
        
        If dsk$                        
            ;
            ; Load Directory
            If ( CBM_Load_Directory( dsk$ ) ! -1)                
                 LoadComma8()
            ;
            ; Show Disk Title
                String$ = CBM_Disk_Image_Tools( dsk$) 
                lvc\pszText = @String$
                SendMessage_(GadgetID(1),#LVM_SETCOLUMN,1,@lvc)                
            ;
            ; Show Disk ID    
                String$ = CBM_Disk_Image_Tools( dsk$, "ID")
                lvc\pszText = @String$
                SendMessage_(GadgetID(1),#LVM_SETCOLUMN,2,@lvc)                
            ;
            ; Show Free Blocks
                SetGadgetText(2, CBM_Disk_Image_Tools( dsk$, "FREE") +" BLOCKS FREE")   
                
            ;
               ; If ( UCase( GetExtensionPart( dsk$ ) ) = "T64")   
                    Info$ = GetGadgetText(2)
                    V(dsk$, #False, #True)
                    
                    SetGadgetText(2, Info$ + " / Errors [" + *er\s + "]")
                ;EndIf    
            ;
            ; Disk Path and File
                SetGadgetText(3, CBM_Disk_Image_Tools( dsk$, "PATHFILE")) 
                
                SetActiveGadget(1)
                SetGadgetItemState(1,0, #PB_ListIcon_Selected)                
            Else            
                MessageRequester(Preview$,*er\s)
            EndIf
        EndIf                               
    EndProcedure
    ; ------------------------------------------------------------------------------------------
    Procedure SaveCBMFile()
        
        UseModule CBMDiskImage   
  
        
        num = GetGadgetItemState(1, GetGadgetState(1))           
        If num
            Cbmfile$    = GetGadgetItemText(1, GetGadgetState(1), 1)
            CbmPattern$ = GetGadgetItemText(1, GetGadgetState(1), 2)
            
            Cbmfile$    = Trim(Cbmfile$)
            CbmPattern$ = Trim(CbmPattern$)
            
            Pattern$ = "C64 Program (*.PRG)|*.PRG|"
            Pattern$ + "C64 Sequential (*.SEQ)|*.SEQ|"            
            Pattern$ + "C64 User (*.USR)|*.USR|"             
            Pattern$ + "C64 Relative (*.REL)|*.REL|" 
            Pattern$ + "C64 CVT (*.CVT)|*.CVT|"                        
            Pattern$ + "C64 Deleted (*.DEL)|*.DEL|"             
            Pattern$ + "PC64 Program(*.P00)|*.P00|"             
            Pattern$ + "PC64 Sequential(*.S00)|*.S00|"     
            Pattern$ + "PC64 User(*.U00)|*.U00|"     
            Pattern$ + "PC64 Deleted(*.D00)|*.D00"
            If UCase( GetExtensionPart(GetGadgetText(3)) ) = "T64"
                Pattern$ + "T64 Snapshots(*.FRZ)|*.FRZ"
            EndIf
            
            ;
            ; Prepare Patterns
            Select UCase( CbmPattern$) 
                Case "DEL", "*DEL", "DEL<": Index = 5               
                Case "SEQ", "*SEQ", "SEQ<": Index = 1   
                Case "PRG", "*PRG", "PRG<": Index = 0   
                Case "USR", "*USR", "USR<": Index = 2   
                Case "REL", "*REL", "REL<": Index = 3  
                Case "FRZ": Index = 6                     
            EndSelect
        
            
            
            SaveFile$    = di_Set_CharSet(Cbmfile$,2)              
            
            SaveFile$   = SaveFileRequester(Preview$, SaveFile$,Pattern$, Index)
            
            Select SelectedFilePattern()
                Case 0: SaveFile$ + ".PRG": Index = 0
                Case 1: SaveFile$ + ".SEQ": Index = 0         
                Case 2: SaveFile$ + ".USR": Index = 0
                Case 3: SaveFile$ + ".REL": Index = 0
                Case 4: SaveFile$ + ".CVT": Index = 0
                Case 5: SaveFile$ + ".DEL": Index = 0
                Case 6: SaveFile$ + ".P00": Index = 1
                Case 7: SaveFile$ + ".S00": Index = 1
                Case 8: SaveFile$ + ".U00": Index = 1
                Case 9: SaveFile$ + ".D00": Index = 1 
                Case 10:SaveFile$ + ".FRZ": Index = 1                       
            EndSelect      
            
            
            If SaveFile$     

                ;
                ; The Copy Argument
                If C(GetGadgetText(3), GetPathPart(SaveFile$), Cbmfile$, CbmPattern$, "HD", SaveFile$, Index) = -1
                    MessageRequester(Preview$,*er\s)
                Else
                    MessageRequester(Preview$,"Saved as " + Chr(34)+ SaveFile$ +Chr(34) )
                EndIf 
                
            EndIf
            SetActiveGadget(1)
            SetGadgetItemState(1,num, #PB_ListIcon_Selected)
        EndIf    
    EndProcedure
    ; ------------------------------------------------------------------------------------------    
    Procedure WriteCBMFile(Charset, OpenFRQ = #True, DragFile$ = "")        
        If ( GetGadgetText(3) <> "" )
            
            Pattern$    = "CBMFile (*.DEL,*.SEQ,*.PRG,*.USR,*.REL,*.d00,*.s00,*.p00,*.u00,*.r00)"+
                          "|*.DEL;*.SEQ;*.PRG;*.USR;*.REL;*.d00;*.s00;*.p00;*.u00;*.r00;"  
            
            If OpenFRQ = #True
                Prg$ = OpenFileRequester("","",Pattern$,1)    
            Else
                Prg$ = DragFile$
            EndIf
            
            If Prg$
                ;
                ; Shift Chars
                Prg$ = di_Set_CharSet( Prg$ )
                
                ;
                ; Simple Copy File to Image Argument. No Specials like Splat or Locked File and Copy As.
                ; Look at the Copy Argument For more Info
                If C(GetGadgetText(3), GetPathPart(Prg$), GetFilePart(Prg$,1), GetExtensionPart(Prg$), "DS", "", 0) = -1
                    MessageRequester(Preview$,*er\s)
                Else    
                    MessageRequester(Preview$,"Written " +Chr(34)+ Prg$ +Chr(34)+ " to " + Chr(34)+ GetGadgetText(3) +Chr(34))
                    LoadCBMImage(#True)
                EndIf 
                SetActiveGadget(1)           
            EndIf
        EndIf
    EndProcedure
    ; ------------------------------------------------------------------------------------------     
    Procedure RenameCBMFile()
        UseModule CBMDiskImage   
        
        num = GetGadgetItemState(1, GetGadgetState(1)) 
        If num
            Cbmfile$    = GetGadgetItemText(1, GetGadgetState(1), 1)
            CbmPattern$ = GetGadgetItemText(1, GetGadgetState(1), 2)
            num         = GetGadgetState(1)
            ; Kill Spaces
            Cbmfile$    = Trim(Cbmfile$)
            CbmPattern$ = Trim(CbmPattern$)
                
            NewCbmfile$ = InputRequester(Preview$, "Rename File (File and Pattern Sperat by ';')", Cbmfile$+";"+CbmPattern$)
            
            Select UCase( GetExtensionPart( GetGadgetText(3) ) )
                Case "T64"
                    NewCbmTitle$ = di_Set_CharSet(NewCbmTitle$)
            EndSelect             
            
            If NewCbmfile$    
                NCbmfile$ = StringField(NewCbmfile$, 1, ";")
                NCbmPatt$ = StringField(NewCbmfile$, 2, ";")
                
                ;
                ; Rename Argument
                If ( R(GetGadgetText(3), Cbmfile$, NCbmfile$,CbmPattern$, NCbmPatt$) = -1)
                    MessageRequester(Preview$,*er\s)
                Else
                    LoadCBMImage(#True)
                EndIf
                SetActiveGadget(1)
                SetGadgetItemState(1,num, #PB_ListIcon_Selected)                
            EndIf                                
        EndIf    
    EndProcedure 
    ; ------------------------------------------------------------------------------------------        
    Procedure RenameDiskTitle()       
        UseModule CBMDiskImage   
        
        If ( GetGadgetText(3) <> "" )
            Protected NewCbmTitle$ = ""

            NewCbmTitle$ = InputRequester(Preview$, "Rename Title",CBM_Disk_Image_Tools( GetGadgetText(3)) )
            If NewCbmTitle$                 
                ;
                ; Rename Disk Title
                If ( T( GetGadgetText(3), NewCbmTitle$) = -1)
                    MessageRequester(Preview$,*er\s)
                Else       
                    
                    NewCbmTitle$ = CBM_Disk_Image_Tools( GetGadgetText(3) ) 
                    
                    lvColumn.LV_COLUMN 
                    lvColumn\mask    = #LVCF_TEXT                                                            
                    lvColumn\pszText = @NewCbmTitle$
                    
                    SendMessage_(GadgetID(1),#LVM_SETCOLUMN,1,@lvColumn) 
                EndIf 
                SetActiveGadget(1)              
            EndIf
        EndIf
    EndProcedure    
    ; ------------------------------------------------------------------------------------------         
    Procedure ScratchFile()        
        Protected num.i
        
        num = GetGadgetItemState(1, GetGadgetState(1))           
        If num
            Cbmfile$    = GetGadgetItemText(1, GetGadgetState(1), 1)
            CbmPattern$ = GetGadgetItemText(1, GetGadgetState(1), 2)
            num         = GetGadgetState(1)
                        
            If ( S(GetGadgetText(3), Cbmfile$, CbmPattern$) = -1)
                 MessageRequester(Preview$,*er\s)
             Else
                 LoadCBMImage(#True)
                 MessageRequester(Preview$,"Scratched: " + Chr(34)+Cbmfile$ + "." + CbmPattern$+Chr(34))
             EndIf 
            SetActiveGadget(1)
            SetGadgetItemState(1,num, #PB_ListIcon_Selected)             
        EndIf
    EndProcedure
    ; ------------------------------------------------------------------------------------------     
    Procedure FormatImage(Format.i)
        
        Protected Pattern$
        
        Select  Format
            Case 1:
                sFile$  = "NewDisk"
                DiskID$ = "64" 
                Title$  = "purebasic d64"
                Format$ = "D64"
                ExTracks= 0
                DOSType = 0
                Pattern$= "Images (*.D64)|*.D64"     
            Case 2:
                sFile$  = "NewDisk"
                DiskID$ = "64" 
                Title$  = "purebasic d64 ex"
                Format$ = "D64"
                ExTracks= 2; With 40 Tracks
                DOSType = 0  
                Pattern$= "Images (*.D64)|*.D64"                   
            Case 3:
                sFile$  = "NewDisk"
                DiskID$ = "71" 
                Title$  = "purebasic d71"
                Format$ = "D71"
                ExTracks= 1 ; With Sector Error Info
                DOSType = 0 
                Pattern$= "Images (*.D71)|*.D71"                   
            Case 4:
                sFile$  = "NewDisk"
                DiskID$ = "81" 
                Title$  = "purebasic d81"
                Format$ = "D81"
                ExTracks= 0
                DOSType = 0
                Pattern$= "Images (*.D81)|*.D81" 
            Case 5:
                sFile$  = "NewTape"
                DiskID$ = "" 
                Title$  = "purebasic t64"
                Format$ = "T64"
                ExTracks= 0
                DOSType = 0
                Pattern$= "Images (*.T64)|*.T64"                  
        EndSelect
        
        ImageFile$   = SaveFileRequester(Preview$, sFile$, Pattern$, 0)                
        
        
        If ( N(ImageFile$, Format$, Title$ , DiskID$, ExTracks.i, DOSType.i) = -1)
            MessageRequester(Preview$,*er\s)
        Else
            MessageRequester(Preview$,"Image Created: " +Chr(34)+ ImageFile$ + "." + Format$ + Chr(34))
            SetGadgetText(3, ImageFile$ + "." + Format$)
            LoadCBMImage(#True)
        EndIf    
        
    EndProcedure    
    ; ------------------------------------------------------------------------------------------     
    Procedure VerifyImage(FixImage = #False)
        
        If ( V(GetGadgetText(3), FixImage ) = -1)
            MessageRequester(Preview$,*er\s)
        Else
            MessageRequester(Preview$ + " Report",*er\s)
        EndIf    
        
    EndProcedure    
    UseModule CBMDiskImage
    
          

   
    If OpenWindow(0, 0, 0, 340, 600, Preview$, #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
        
        SetWindowCallback(@WinCallback())    ; Callback aktivieren für das Listicon
        
        ListIconGadget(1,4,4,332,400, "BLOCKS",58, #LVS_OWNERDRAWFIXED)         
        AddGadgetColumn(1,1,"",170)
        AddGadgetColumn(1,2,"",100)
        SetGadgetColor(1, #PB_Gadget_BackColor, $792731)
        
        TextGadget(2, 10, 408, 320, 14, "" )
        TextGadget(3, 10, 424, 320, 14, "" ) 
        
        ButtonGadget( 4,4     ,460, 82,  24,"Open Image")
        ButtonGadget( 5,4 + 82,460, 82,  24,"Save File")
        ButtonGadget( 6,4 +166,460, 82,  24,"Write File")
        ButtonGadget( 7,4 +248,460, 82,  24,"Toggle Font")       
        
        ButtonGadget( 8,4     ,460+28 , 100,  24,"Rename File")   
        ButtonGadget( 9,4 +115,460+28 , 100,  24,"Disk Title")
        ButtonGadget(10,4 +230,460+28 , 100,  24,"Scratch")                
        
        ButtonGadget(17,4     ,460+56 , 100,  24,"Check Image")   
        ButtonGadget(18,4 +115,460+56 , 100,  24,"Fix Image")
        ButtonGadget(19,4 +230,460+56 , 100,  24,"Debug Info")
        
        ButtonGadget(11,4     ,460+82 , 115,  24,"Format D64 (35)")
        ButtonGadget(12,4 +115,460+82 , 100,  24,"Format D71")        
        ButtonGadget(13,4 +215,460+82 , 115,  24,"Format D81")
        
        ButtonGadget(14,4     ,460+106, 115,  24,"Format D64 (40)") 
        ButtonGadget(15,4 +115,460+106, 100,  24,"    ---   ") 
        ButtonGadget(16,4 +215,460+106, 115,  24,"Format T64")        
      
        For btn = 2 To 19
            SendMessage_(GadgetID(btn),#WM_SETFONT,CBMFontCharset3(),1) 
        Next
        
        SendMessage_(GadgetID(1),#WM_SETFONT,CBMFontCharset1(),1) 
        SendMessage_(GadgetID(1),#LVM_SETEXTENDEDLISTVIEWSTYLE,0,#LVS_EX_LABELTIP| #LVS_EX_FULLROWSELECT) 
        
        EnableGadgetDrop(1,     #PB_Drop_Files,   #PB_Drag_Copy|#PB_Drag_Copy|#PB_Drag_Link)
        
        

     Repeat
        
        
        Event = WaitWindowEvent()
        Select Event
            Case #PB_Event_Gadget
                Select EventGadget()
                    Case 4 : LoadCBMImage()
                    Case 5 : SaveCBMFile()
                    Case 6 : WriteCBMFile(Charset)
                    Case 7
                        If Charset = 1
                            SendMessage_(GadgetID(1),#WM_SETFONT,CBMFontCharset2(),1)
                            Charset = 2                            
                        Else
                            SendMessage_(GadgetID(1),#WM_SETFONT,CBMFontCharset1(),1) 
                            Charset = 1 
                        EndIf    
                        LoadComma8(0,Charset)
                        
                    Case 8  : RenameCBMFile()
                    Case 9  : RenameDiskTitle()    
                    Case 10 : ScratchFile()  
                    Case 11 : FormatImage(1)
                    Case 12 : FormatImage(3)
                    Case 13 : FormatImage(4)
                    Case 14 : FormatImage(2)                          
                    Case 15  ; ======                    
                    Case 16 : FormatImage(5)                         
                    Case 17 : VerifyImage()
                    Case 18 : VerifyImage(#True)
                    Case 19 : CBM_Test_Full_Info(GetGadgetText(3))
                        
                        
                EndSelect
                
            Case #PB_Event_GadgetDrop
                Select EventGadget()
                    Case 1
                        Files$ = EventDropFiles()
                        Count  = CountString(Files$, Chr(10)) + 1
                        For i = 1 To Count
                            CurrentFile$ = StringField(Files$, i, Chr(10))
                            If CurrentFile$
                                Select UCase (GetExtensionPart(CurrentFile$) )
                                    Case "D64", "D71", "D81", "T64"
                                        ;
                                        ; Fake Load for Drag and Drop
                                        SetGadgetText(3, CurrentFile$)
                                        LoadCBMImage(#True)
                                    Case  "DEL","SEQ","PRG","USR","REL","D00","S00","P00","U00","R00"
                                        WriteCBMFile(Charset, #False, CurrentFile$) 
                                EndSelect 
                            EndIf
                        Next i
                EndSelect                             
        EndSelect
    Until Event = #PB_Event_CloseWindow
  EndIf
CompilerEndIf





; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 6780
; FirstLine = 2448
; Folding = fhQCAi-RLACQEYAAO5CMEMw
; EnableAsm
; EnableXP
; Executable = FileFormat_DiskImageC64.exe
; Debugger = IDE
; Watchlist = CBMDiskImage::di_load_image()>DiskImageFile$