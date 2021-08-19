DeclareModule MathBytes
    
    Declare.s Bytes2String(byte.q , nbDecimals.l = 0) 
    Declare.q String2Bytes(Value.s, UnitSelect.i = -1) 
    
    ; In LH.Mame    
    Declare.s ConvertSize(filesize.d, ByteDesc = -1, HDCheckFreeSpace$ = "", HDByteVariant = 0, ShowBytesToo = #False)   ; 29.04.2015
    Declare.i Chs2Lba(Cylinder.i, Heads.i, Sectors, SectorSize.i = 512,Mode = -1)
    Declare.i Lba2Chs(bytesize.i, sectorsize.i, sectors.i, heads.i)
    Declare.s GetFromCHSLBA_chs()
    Declare.i GetFromCHSLBA_tbytes() 
    Declare.s ConvertFileSize(Size.q,KB=0,MB=0)
EndDeclareModule  

Module MathBytes
    
    ;***************************************************************************************************
    ;        
    ; Structure für CHDMan
    Structure STRUCT_CHSLBA
        
        ttracks.i               ; Total umber Of Tracks
        tSectors.i              ; Total Number Of Sectors
        tBytes.i                ; Total Number Of Bytes
        tMegabytes.d            ; Total Number Of Megabytes
        tGigabytes.d            ; Total Number Of Gigabytes
        sAddressLBA.i           ; LBA Start Adress
        eAddressLBA.i           ; LBA End  Adress (THE LBA)
        cylinder.i              ; Number Of Cylinder Per Drive
        heads.i                 ; Number Of Heads Per Drive
        sectors.i               ; Number Of Sectors Per Track
        ssize.i                 ; Number Of Bytes Per Sector (Sector Size)
        mbrsector.i             ; MBR + Hidden Sectors
        mbrsize.i               ; MBR Size in bytes
        chs.s        
    EndStructure                 
    
    Global CHSLBA.STRUCT_CHSLBA     
    ;******************************************************************************************************************************************
    ;        
    ; Konvertiert die Eingabe von bytes zum String
    ;__________________________________________________________________________________________________________________________________________        
    Procedure.s Bytes2String(byte.q , nbDecimals.l = 0) 
        Protected output.s,*chr.Character, pos.i
        
        Protected unit.b = Round(Log(byte)/Log(1024), 0)
        
        output.s =  StrD(byte/Pow(1024, unit), 15)
        pos = FindString(output,".")
        *chr = @output + pos  
        
        If *chr\c <> '0' 
            output = Left(output,pos+2) + StringField(" Bytes,KB,MB,GB,TB,PB,EB", unit+1, ",") 
        Else 
            output = Left(output,pos-1) + StringField(" Bytes,KB,MB,GB,TB,PB,EB", unit+1, ",")        
        EndIf    
        
        Select output
            Case "0.00 Bytes"
                output = "0 Bytes"
        EndSelect 
            
        ProcedureReturn output 
    EndProcedure  
    ;******************************************************************************************************************************************
    ;        
    ;  Konvertiert die Eingabe von Strings (MB,GB etc.. nach Byte Grösse)
    ;__________________________________________________________________________________________________________________________________________         
    Procedure.q String2Bytes(Value.s, UnitSelect.i = -1) 
        Protected Bytes.d, *char.Character , B$, i.i,sign.s, p.i, Unit$
        
        p = FindString(Value,",",1)
        If p >= 1
            Value  = ReplaceString(Value,",",".")
        EndIf
        
        sign.s   = UCase(Right(Value,2))
        Unit$    = UCase(Right(Value,2))
        
        For i = 0 To 1            
            *char = @sign                                            
            If ( *char\c = 'B' ) Or
               ( *char\c = 'M' ) Or
               ( *char\c = 'G' ) Or
               ( *char\c = 'T' ) Or
               ( *char\c = 'P' ) Or
               ( *char\c = 'E' ); Or
                                ;( *char\c = '.' )
                Value = ReplaceString(Value,Chr(*char\c),"")
                sign  = ReplaceString(sign ,Chr(*char\c),"")
                Break
            EndIf                          
            If i = 1
                Break;
            EndIf    
        Next
        Bytes  = ValD(Value)
        Select UnitSelect
                ;
                ;
            Case 0
                Select UCase(Unit$)
                    Case "KB"
                        Bytes*1024 
                    Case "MB"                    
                        Bytes*1048576
                    Case "GB"
                        Bytes*1073741824
                    Case "TB"
                        Bytes*1099511627776
                    Case "PB"
                        Bytes*1125899906842624
                    Case "EB"
                        Bytes*1152921504606846976
                EndSelect
                ;
                ;
            Case -1     
                Select UCase(Unit$)
                    Case "KB"
                        Bytes*1000 
                    Case "MB"                    
                        Bytes*1000000
                    Case "GB"
                        Bytes*1000000000
                    Case "TB"
                        Bytes*1000000000000
                    Case "PB"
                        Bytes*1000000000000000
                    Case "EB"
                        Bytes*1000000000000000000
                EndSelect 
        EndSelect
            
        ProcedureReturn Bytes
    EndProcedure            
    ;******************************************************************************************************************************************
    ;  Berechnet die Festplatten Geometrie
    ;
    ;  CHS nach LBA
    ;__________________________________________________________________________________________________________________________________________ 
     Procedure.i Chs2Lba(Cylinder.i, Heads.i, Sectors, SectorSize.i = 512,Mode = -1)
         Protected c.i, h.i, s.i, maxheads.i = 16, sAddrLBA.i, eAddrLBA.i, hdTracks.i, hdSectors.i, Bytes.i, MBRSize.i
  
         ;
         ; C: Cylinder, gültiger Bereich: 0-1023 cylinders
         If ( c >= 1024 )
             ProcedureReturn 0
         EndIf
         
         CHSLBA\cylinder     = Cylinder
         CHSLBA\heads        = heads
         CHSLBA\sectors      = Sectors
         CHSLBA\ssize        = SectorSize
         CHSLBA\sAddressLBA  = ( (0 * Heads + 1) * Sectors) + 1 - 1         
         
            CHSLBA\ttracks   = CHSLBA\cylinder * CHSLBA\heads     
            CHSLBA\tSectors  = CHSLBA\ttracks  * CHSLBA\sectors
            CHSLBA\tBytes    = CHSLBA\tSectors * CHSLBA\ssize 
            CHSLBA\mbrsize   = CHSLBA\sectors  * CHSLBA\ssize
            CHSLBA\tMegabytes= ((CHSLBA\tBytes) / 1000000)
            CHSLBA\tGigabytes= ((CHSLBA\tBytes) / 1000000000);
            
          CHSLBA\eAddressLBA = CHSLBA\tSectors
         
     EndProcedure
    ;******************************************************************************************************************************************
    ;  Berechnet die Festplatten Geometrie
    ;
    ;  LAB nach CHS
    ;__________________________________________________________________________________________________________________________________________ 
     Procedure.i Lba2Chs(bytesize.i, sectorsize.i, sectors.i, heads.i)
         Protected temp.i                 
         
            temp = bytesize / sectorsize             ; divid contains the sector Size
         CHSLBA\cylinder     =  temp /( heads * sectors ); - 1

            temp = heads * sectors % temp            
         CHSLBA\heads        = temp / sectors        
         CHSLBA\sectors      = sectors % temp
                
         CHSLBA\chs     = Str(CHSLBA\cylinder) +"," +Str(CHSLBA\heads) +"," +Str(CHSLBA\sectors)          
     EndProcedure     
     
     Procedure.s GetFromCHSLBA_chs()
         ProcedureReturn CHSLBA\chs
     EndProcedure   
     
     Procedure.i GetFromCHSLBA_tbytes()
         ProcedureReturn CHSLBA\tBytes
     EndProcedure        
    ;******************************************************************************************************************************************
    ;  Berechnet die Dateigrösse nach KB, MB
    ;__________________________________________________________________________________________________________________________________________   
     Procedure.s ConvertFileSize(Size.q,KB=0,MB=0)
         
         If ( Size <= -1 )
             ProcedureReturn "Negativer Wert"
         EndIf    
        ;Size / 1024
        
        Select KB
            Case 1
                If Size < 100
                    size$ = StrD(Size,2) ; '3.21 KB'
                ElseIf Size < 100
                    size$ = StrD(Size,1) ; '32.1 KB'
                Else
                    size$ = StrD(Size,0) ; '321 KB'
                EndIf
                If Left(StringField(size$,2,"."), 1) = "0" : size$ = StringField(size$,1,".") : EndIf
                ProcedureReturn size$+" KB"                
            Case 0
        EndSelect
        
        Select MB
            Case 1                
                If Size < 1024 ; KiloByte
                    If Size < 100
                        size$ = StrD(Size,2) ; '3.21 KB'
                    ElseIf Size < 100
                        size$ = StrD(Size,1) ; '32.1 KB'
                    Else
                        size$ = StrD(Size,0) ; '321 KB'
                    EndIf
                    If Left(StringField(size$,2,"."), 1) = "0" : size$ = StringField(size$,1,".") : EndIf
                    ProcedureReturn size$+" KB"
                    
                ElseIf Size < 1048576 ; MegaByte     
                    Size / 1024
                    If Size < 10
                        size$ = StrD(Size, 2) ; '6.54' MB'
                    ElseIf Size < 100
                        size$ = StrD(Size, 1) ; '65.4' MB
                    Else
                        size$ = StrD(Size, 0) ; '654' MB
                    EndIf
                    If Left(StringField(size$,2,"."), 1) = "0" : size$ = StringField(size$,1,".") : EndIf
                    ProcedureReturn size$+" MB"
                EndIf      
            Case 0
        EndSelect 
        
        
        If Size < 1024 ; KiloByte
            If Size < 100
                size$ = StrD(Size,2) ; '3.21 KB'
            ElseIf Size < 100
                size$ = StrD(Size,1) ; '32.1 KB'
            Else
                size$ = StrD(Size,0) ; '321 KB'
            EndIf
            If Left(StringField(size$,2,"."), 1) = "0" : size$ = StringField(size$,1,".") : EndIf
            ProcedureReturn size$+" KB"
            
        ElseIf Size < 1048576 ; MegaByte
            Size / 1024
            If Size < 10
                size$ = StrD(Size, 2) ; '6.54' MB'
            ElseIf Size < 100
                size$ = StrD(Size, 1) ; '65.4' MB
            Else
                size$ = StrD(Size, 0) ; '654' MB
            EndIf
            If Left(StringField(size$,2,"."), 1) = "0" : size$ = StringField(size$,1,".") : EndIf
            ProcedureReturn size$+" MB"
            
        Else ; GigaByte
            Size / 1048576
            If Size < 10
                size$ = StrD(Size, 2) ; '1.23 GB'
            ElseIf Size < 100
                size$ = StrD(Size, 1) ; '12.3 GB'
            Else
                size$ = StrD(Size, 0) ; '123 GB'
            EndIf
            If Left(StringField(size$,2,"."), 1) = "0" : size$ = StringField(size$,1,".") : EndIf
            ProcedureReturn size$+" GB"
        EndIf
    EndProcedure
    
    ;******************************************************************************************************************************************
    ;  Berechnet die Verzeichnisgrösse
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.q GetDirectorySize(Path.s, rekursiv = #True)
        
        Protected dir.l, Size.q, entry.s
        
        If Not Right(Path, 1) = "\"
            Path+"\"
        EndIf
        dir = ExamineDirectory(#PB_Any, Path, "")
        If dir
            While NextDirectoryEntry(dir)
                entry = DirectoryEntryName(dir)
                If entry = "." Or entry = ".."
                    Continue
                ElseIf DirectoryEntryType(dir) = #PB_DirectoryEntry_File
                    Size + DirectoryEntrySize(dir)
                ElseIf rekursiv
                    Size + GetDirectorySize(Path+entry+"\", rekursiv)
                EndIf
            Wend
            FinishDirectory(dir)    
        EndIf
        ProcedureReturn Size
    EndProcedure   
    
    ;******************************************************************************************************************************************
    ;  Berechnet den Speicherplatz
    ;__________________________________________________________________________________________________________________________________________ 
    Procedure.q GetFreeHDSpace(Drive$,Variant=0)
        
        Define.q BytesFreeToCaller, TotalBytes, TotalFreeBytes
        
        If Len(Drive$) = 2 And FindString(Drive$,"\",1)= 0
            Drive$ = Drive$ + "\"
        EndIf

        SetErrorMode_(#SEM_FAILCRITICALERRORS)

        Define.q BytesFreeToCaller, TotalBytes, TotalFreeBytes

        If GetDiskFreeSpaceEx_(@Drive$, @BytesFreeToCaller, @TotalBytes, @TotalFreeBytes) = 0
           ProcedureReturn 0 
        EndIf

        SetErrorMode_(0)
        Select Variant   
            Case 0
                ProcedureReturn TotalFreeBytes.q
            Case 1
                ProcedureReturn TotalBytes.q
            Case 2
                ProcedureReturn BytesFreeToCaller.q
        EndSelect            
    EndProcedure     
    ;******************************************************************************************************************************************
    ;  Berechnet die Dateigrösse und gibt diese als String aus
    ;__________________________________________________________________________________________________________________________________________             
    Procedure.s ConvertSize(filesize.d, ByteDesc = -1, HDCheckFreeSpace$ = "", HDByteVariant = 0, ShowBytesToo = #False)   ; 29.04.2015
        Protected level.b = 0, levelc.b = 0, HDSpace.d, Original.d = filesize, DescSize$, p.i
        
        Dim units.s(24) 
        
        Select ByteDesc
            Case -1        
                units(0) = "B"
                units(1) = "KB"
                units(2) = "MB"
                units(3) = "GB"
                units(4) = "TB"
                units(5) = "PB"       
                units(6) = "EB"
                units(7) = "ZB"
                units(8) = "YB"
                units(9) = "XB"
                units(10) = "WB"
                units(11) = "VB"
                units(12) = "UB"
                units(13) = "TDB"
                units(14) = "SB"
                units(15) = "RB"
                units(16) = "QB"
                units(17) = "PPB"
                units(18) = "OB"
                units(19) = "NB"
                units(20) = "MIB"
                units(21) = "LB"
                units(22) = "HB"
                units(23) = "AB"
                units(24) = "SOB"
            Case 1
                units(0) = "Bytes"
                units(1) = "Kilobytes"
                units(2) = "Megabytes"
                units(3) = "Gigabytes"
                units(4) = "Terabytes"
                units(5) = "Petabybtes"       
                units(6) = "Exabytes"                 
                units(7) = "Zettabytes"
                units(8) = "Yottabytes"
                units(9) = "Xonabytes"
                units(10) = "Wekabytes"
                units(11) = "Vundabytes"
                units(12) = "Udabytes"
                units(13) = "Tredabytes"
                units(14) = "Sortabytes"
                units(15) = "Rintabytes"
                units(16) = "Quexabytes"
                units(17) = "Peptabytes"
                units(18) = "Ochabytes"
                units(19) = "Nenabytes"
                units(20) = "Mingabytes"
                units(21) = "Lumabytes"
                units(22) = "Hanabytes"
                units(23) = "Anabytes"
                units(24) = "Sophobytes"
        EndSelect
        
        HDSpace.d = -1
        If HDCheckFreeSpace$
            HDSpace.d = GetFreeHDSpace(HDCheckFreeSpace$,HDByteVariant)
            If (filesize > HDSpace) And (HDSpace >=1)
                ;                    While HDSpace > 1023 
                ;                        HDSpace = HDSpace / 1024          
                ;                        levelc + 1            
                ;                    Wend                 
                ;                    ProcedureReturn "Not enough space free space on Drive: " + HDCheckFreeSpace$ + " Free: " + StrD(HDSpace, n) + " " + units(levelc)
            EndIf               
        EndIf    
        
        While filesize > 1023 
            filesize = filesize / 1024                   
            level + 1                         
        Wend
        
        
        Select filesize
            Case -9223372036854775808                                                    
                ProcedureReturn "Coded 08.05.2016, Error in Quad Byte Descriptor"
                
        EndSelect
        
        
        If level >=24
            ProcedureReturn  StrD(filesize, 2) + " (Coded 08.05.2016, Unnown Byte Description)"
        EndIf    
        
        If level = 0
            n = 0 
        EndIf  
        Select ShowBytesToo
            Case #False
                ProcedureReturn StrD(filesize, 2) + " " + units(level)
            Case #True
                
                If (Original >= 1) And (Original < 9199999999999999999 )
                    DescSize$ = StrD(Original)
                    ByteLen   = Len(DescSize$)
                    If ByteLen >=13
                       
                    EndIf    
                    If ( ByteLen >=4 )
                        NbDecimals = 2
                        For n = 0 To ByteLen                                                   
                            m =  Mod(n,4)
                            If ( m = 0 )                            
                                Select ByteLen                 
                                    Case 4,7,10,13,16,19: p = n +2
                                    Case 5,8,11,14,17,20: p = n +3
                                    Case 6,9,12,15,18,21: p = n +4   
                                EndSelect        
                                DescSize$ = InsertString(DescSize$,".",p)        
                            EndIf 
                        Next 
                    EndIf
                    If ( Right(DescSize$,1) = "." )                      
                        DescSize$ = Left(DescSize$,Len(DescSize$) - 1)
                    EndIf    
                EndIf                    
                ProcedureReturn StrD(filesize, NbDecimals) + " " + units(level) + " ( "+ DescSize$ + " Bytes)"
        EndSelect     
    EndProcedure     
    
    ;******************************************************************************************************************************************
    ;  Berechnet die Dateigrösse und gibt diese als String aus
    ;__________________________________________________________________________________________________________________________________________         
    Procedure.s ConvertHDSize(Value.q)    
        
        Protected unit.b=0, byte.q, nSize.s
        
        byte = Value
        While byte >= 1024
            byte / 1024 : unit + 1
        Wend
        
        If unit
            nSize = StrD(Value/Pow(1024, unit), 15)
            pos.l = FindString(nSize, ".")
        Else
            nSize = Str(Value)
        EndIf
        
        If unit
            If pos <  4
                nSize=Mid(nSize,1,pos+2)
            Else
                nSize = Mid(nSize, 1, pos-1)
            EndIf
        EndIf
        
        ProcedureReturn nSize+" "+StringField("bytes,KB,MB,GB,TB,PB", unit+1, ",") 
    EndProcedure    
    
   
EndModule
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 199
; FirstLine = 88
; Folding = zn+
; EnableAsm
; EnableXP