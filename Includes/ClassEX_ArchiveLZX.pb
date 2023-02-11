DeclareModule PackLZX
    
    Declare.i   Process_Archive(File.s)             ; Init and Open Lzx File
    
    Declare.i   Examine_Archive(*LzxMemory)         ; List Content
    Declare.i   Extract_Archive(*LzxMemory)         ; Extract Content    
    Declare.i   Close_Archive(*LzxMemory)           ; Close Archive and Free    
EndDeclareModule


Module PackLZX
    
    Structure ArchiveFormat
        dateiname.s
        dateipath.s
        size.i     
        *image
    EndStructure     
    
    Structure CRC_Memory
        c.c[256]
    EndStructure
    
    Dim Calculation.a(0)    
    Dim CrcFileCalc.a(0)
    Dim DecrunchBuf.a(0)
    
    Structure Info_Header
        c.c[10]
    EndStructure
    
    Structure Archive_Header
        c.c[31]
    EndStructure
    
    Structure Header_Filename
        c.c[256]
    EndStructure
    
    Structure Header_Comment
        c.c[256]
    EndStructure     
    
    Structure FileBuffer
        c.c[256]
        size.i
    EndStructure
          

    
    Structure LZX_FILEDATA
        Count.i                 ; Aktulle Datei Nummer
        File.s                  ; Der DateiName
        Comment.s
        PackMode.c              ; Packmodus
        AttribH.s               ; Datei Attribute
        AttribS.s
        AttribP.s
        AttribA.s
        AttribR.s        
        AttribW.s        
        AttribE.s
        AttribD.s        
        crc.i                   ; crc Archive Header
        crcSum.i                ; crc summe
        crcFile.i               ; Data CRC für die Datei (Siehe Extract Normal)        
        DateY.i                 ; Datum : Jahr
        DateM.i                 ; Datum : Monat
        DateD.i                 ; Datum : Tag
        TimeH.i                 ; Zeit Stunde
        TimeM.i                 ; Zeit Minute
        TimeS.i                 ; Zeit Sekunde
        TotalFiles.i            ; WieViele Dateien        
        SizePacked.i        
        SizeUnpack.i
        PackedByte.b
        MergedSize.i
        SeekPosition.i
        isMerged.i
        ErrorMessage.s
        loc.i
    EndStructure     
    
    Structure LZX_ARCHIVE
        Path.s
        File.s
        Full.s
        Size.q
        Dest.s
        pbData.l
        sum.i                ; ist die Globale Varibale sum und nutzt "variable temp" in crc_calc      
        crc.i                ; Abgleich und Vergleich
        TotalFiles.i
        TotalPacked.i        
        TotalUnpack.i
        MergedSize.i
        *Header.Info_Header
        *Archiv.Archive_Header
        *Filename.Header_Filename
        *Comment.Header_Comment
        List FileData.LZX_FILEDATA()
    EndStructure    
    
      
  ;  Structure offset_len                ; unsigned char offset_len[8];
  ;      c.a[8]
  ;  EndStructure
    
  ;  Structure offset_table              ; unsigned short offset_table[128]
  ;      c.c[129]
  ;  EndStructure
    
  ;  Structure huffman20_len             ; unsigned char huffman20_len[20];
  ;      c.a[20]
  ;  EndStructure    
    
  ;  Structure huffman20_table           ; unsigned short huffman20_table[96];
  ;      c.c[96]
  ;  EndStructure      
    

        
    Structure decrunch_buffer
        c.a[258 + 65536 + 258]
    EndStructure  
            
    Structure LZX_DECODE
        *bit_num.ascii                  ; register unsigned char bit_num = 0;
        *symbol.Integer                ; register int symbol;
        leaf.i                          ; unsigned int leaf; /* could be a register */
        table_mask.i
        bit_mask.i
        pos.i
        fill.i
        next_symbol.i
        reverse.i
        abort.i
    EndStructure 
    
    Structure LZX_DECRUNCH
        *control.Integer  
    EndStructure
    
    Structure LZX_LITERAL
        abort.i        
        *control.Integer        
        *count.Integer                  ; unsigned int count;        
        *decrunch_length.Integer        ; unsigned int decrunch_length;        
        *decrunch_method.Integer        ; unsigned int decrunch_method;       
        *destination.ascii              ; unsigned char *destination;
        *destination_end.ascii          ; unsigned char *destination_end;  
        *last_offset.Integer            ; unsigned int last_offset;        
        *global_control.Integer         ; unsigned int global_control;
        global_shift.i                  ; global_shift;
        pack_size.q        
        *pos.ascii                      ; unsigned char *pos;
        *content.ascii                  ; unsigned char copy from *pos for file saving;
        shift.i        
        *source.ascii                   ; unsigned char *source;
        *source_end.ascii               ; unsigned char *source_end;
        *symbol.integer
        *temp.ascii                     ; unsigned char *temp;
        unpack_size.q      
    EndStructure 
  
    CompilerIf ( #PB_Processor_x64 )
        

    
        DataSection
            CRC_TABLE:
            Data.i $00000000,$77073096,$EE0E612C,$990951BA,$076DC419,$706AF48F
            Data.i $E963A535,$9E6495A3,$0EDB8832,$79DCB8A4,$E0D5E91E,$97D2D988
            Data.i $09B64C2B,$7EB17CBD,$E7B82D07,$90BF1D91,$1DB71064,$6AB020F2
            Data.i $F3B97148,$84BE41DE,$1ADAD47D,$6DDDE4EB,$F4D4B551,$83D385C7
            Data.i $136C9856,$646BA8C0,$FD62F97A,$8A65C9EC,$14015C4F,$63066CD9
            Data.i $FA0F3D63,$8D080DF5,$3B6E20C8,$4C69105E,$D56041E4,$A2677172
            Data.i $3C03E4D1,$4B04D447,$D20D85FD,$A50AB56B,$35B5A8FA,$42B2986C
            Data.i $DBBBC9D6,$ACBCF940,$32D86CE3,$45DF5C75,$DCD60DCF,$ABD13D59
            Data.i $26D930AC,$51DE003A,$C8D75180,$BFD06116,$21B4F4B5,$56B3C423
            Data.i $CFBA9599,$B8BDA50F,$2802B89E,$5F058808,$C60CD9B2,$B10BE924
            Data.i $2F6F7C87,$58684C11,$C1611DAB,$B6662D3D,$76DC4190,$01DB7106
            Data.i $98D220BC,$EFD5102A,$71B18589,$06B6B51F,$9FBFE4A5,$E8B8D433
            Data.i $7807C9A2,$0F00F934,$9609A88E,$E10E9818,$7F6A0DBB,$086D3D2D
            Data.i $91646C97,$E6635C01,$6B6B51F4,$1C6C6162,$856530D8,$F262004E
            Data.i $6C0695ED,$1B01A57B,$8208F4C1,$F50FC457,$65B0D9C6,$12B7E950
            Data.i $8BBEB8EA,$FCB9887C,$62DD1DDF,$15DA2D49,$8CD37CF3,$FBD44C65
            Data.i $4DB26158,$3AB551CE,$A3BC0074,$D4BB30E2,$4ADFA541,$3DD895D7
            Data.i $A4D1C46D,$D3D6F4FB,$4369E96A,$346ED9FC,$AD678846,$DA60B8D0
            Data.i $44042D73,$33031DE5,$AA0A4C5F,$DD0D7CC9,$5005713C,$270241AA
            Data.i $BE0B1010,$C90C2086,$5768B525,$206F85B3,$B966D409,$CE61E49F
            Data.i $5EDEF90E,$29D9C998,$B0D09822,$C7D7A8B4,$59B33D17,$2EB40D81
            Data.i $B7BD5C3B,$C0BA6CAD,$EDB88320,$9ABFB3B6,$03B6E20C,$74B1D29A
            Data.i $EAD54739,$9DD277AF,$04DB2615,$73DC1683,$E3630B12,$94643B84
            Data.i $0D6D6A3E,$7A6A5AA8,$E40ECF0B,$9309FF9D,$0A00AE27,$7D079EB1
            Data.i $F00F9344,$8708A3D2,$1E01F268,$6906C2FE,$F762575D,$806567CB
            Data.i $196C3671,$6E6B06E7,$FED41B76,$89D32BE0,$10DA7A5A,$67DD4ACC
            Data.i $F9B9DF6F,$8EBEEFF9,$17B7BE43,$60B08ED5,$D6D6A3E8,$A1D1937E
            Data.i $38D8C2C4,$4FDFF252,$D1BB67F1,$A6BC5767,$3FB506DD,$48B2364B
            Data.i $D80D2BDA,$AF0A1B4C,$36034AF6,$41047A60,$DF60EFC3,$A867DF55
            Data.i $316E8EEF,$4669BE79,$CB61B38C,$BC66831A,$256FD2A0,$5268E236
            Data.i $CC0C7795,$BB0B4703,$220216B9,$5505262F,$C5BA3BBE,$B2BD0B28
            Data.i $2BB45A92,$5CB36A04,$C2D7FFA7,$B5D0CF31,$2CD99E8B,$5BDEAE1D
            Data.i $9B64C2B0,$EC63F226,$756AA39C,$026D930A,$9C0906A9,$EB0E363F
            Data.i $72076785,$05005713,$95BF4A82,$E2B87A14,$7BB12BAE,$0CB61B38
            Data.i $92D28E9B,$E5D5BE0D,$7CDCEFB7,$0BDBDF21,$86D3D2D4,$F1D4E242
            Data.i $68DDB3F8,$1FDA836E,$81BE16CD,$F6B9265B,$6FB077E1,$18B74777
            Data.i $88085AE6,$FF0F6A70,$66063BCA,$11010B5C,$8F659EFF,$F862AE69
            Data.i $616BFFD3,$166CCF45,$A00AE278,$D70DD2EE,$4E048354,$3903B3C2
            Data.i $A7672661,$D06016F7,$4969474D,$3E6E77DB,$AED16A4A,$D9D65ADC
            Data.i $40DF0B66,$37D83BF0,$A9BCAE53,$DEBB9EC5,$47B2CF7F,$30B5FFE9
            Data.i $BDBDF21C,$CABAC28A,$53B39330,$24B4A3A6,$BAD03605,$CDD70693
            Data.i $54DE5729,$23D967BF,$B3667A2E,$C4614AB8,$5D681B02,$2A6F2B94
            Data.i $B40BBE37,$C30C8EA1,$5A05DF1B,$2D02EF8D
        EndDataSection
        CompilerEndIf    
        
        
    CompilerIf ( #PB_Processor_x86 )        
        
         Structure CRC86
             crc.i[256]
         EndStructure    
         
         DataSection
            CRC_TABLE86:
            Data.i 0        ,$77073096,$EE0E612C,$990951BA,$076DC419,$706AF48F
            Data.i $E963A535,$9E6495A3,$0EDB8832,$79DCB8A4,$E0D5E91E,$97D2D988
            Data.i $09B64C2B,$7EB17CBD,$E7B82D07,$90BF1D91,$1DB71064,$6AB020F2
            Data.i $F3B97148,$84BE41DE,$1ADAD47D,$6DDDE4EB,$F4D4B551,$83D385C7
            Data.i $136C9856,$646BA8C0,$FD62F97A,$8A65C9EC,$14015C4F,$63066CD9
            Data.i $FA0F3D63,$8D080DF5,$3B6E20C8,$4C69105E,$D56041E4,$A2677172
            Data.i $3C03E4D1,$4B04D447,$D20D85FD,$A50AB56B,$35B5A8FA,$42B2986C
            Data.i $DBBBC9D6,$ACBCF940,$32D86CE3,$45DF5C75,$DCD60DCF,$ABD13D59
            Data.i $26D930AC,$51DE003A,$C8D75180,$BFD06116,$21B4F4B5,$56B3C423
            Data.i $CFBA9599,$B8BDA50F,$2802B89E,$5F058808,$C60CD9B2,$B10BE924
            Data.i $2F6F7C87,$58684C11,$C1611DAB,$B6662D3D,$76DC4190,$01DB7106
            Data.i $98D220BC,$EFD5102A,$71B18589,$06B6B51F,$9FBFE4A5,$E8B8D433
            Data.i $7807C9A2,$0F00F934,$9609A88E,$E10E9818,$7F6A0DBB,$086D3D2D
            Data.i $91646C97,$E6635C01,$6B6B51F4,$1C6C6162,$856530D8,$F262004E
            Data.i $6C0695ED,$1B01A57B,$8208F4C1,$F50FC457,$65B0D9C6,$12B7E950
            Data.i $8BBEB8EA,$FCB9887C,$62DD1DDF,$15DA2D49,$8CD37CF3,$FBD44C65
            Data.i $4DB26158,$3AB551CE,$A3BC0074,$D4BB30E2,$4ADFA541,$3DD895D7
            Data.i $A4D1C46D,$D3D6F4FB,$4369E96A,$346ED9FC,$AD678846,$DA60B8D0
            Data.i $44042D73,$33031DE5,$AA0A4C5F,$DD0D7CC9,$5005713C,$270241AA
            Data.i $BE0B1010,$C90C2086,$5768B525,$206F85B3,$B966D409,$CE61E49F
            Data.i $5EDEF90E,$29D9C998,$B0D09822,$C7D7A8B4,$59B33D17,$2EB40D81
            Data.i $B7BD5C3B,$C0BA6CAD,$EDB88320,$9ABFB3B6,$03B6E20C,$74B1D29A
            Data.i $EAD54739,$9DD277AF,$04DB2615,$73DC1683,$E3630B12,$94643B84
            Data.i $0D6D6A3E,$7A6A5AA8,$E40ECF0B,$9309FF9D,$0A00AE27,$7D079EB1
            Data.i $F00F9344,$8708A3D2,$1E01F268,$6906C2FE,$F762575D,$806567CB
            Data.i $196C3671,$6E6B06E7,$FED41B76,$89D32BE0,$10DA7A5A,$67DD4ACC
            Data.i $F9B9DF6F,$8EBEEFF9,$17B7BE43,$60B08ED5,$D6D6A3E8,$A1D1937E
            Data.i $38D8C2C4,$4FDFF252,$D1BB67F1,$A6BC5767,$3FB506DD,$48B2364B
            Data.i $D80D2BDA,$AF0A1B4C,$36034AF6,$41047A60,$DF60EFC3,$A867DF55
            Data.i $316E8EEF,$4669BE79,$CB61B38C,$BC66831A,$256FD2A0,$5268E236
            Data.i $CC0C7795,$BB0B4703,$220216B9,$5505262F,$C5BA3BBE,$B2BD0B28
            Data.i $2BB45A92,$5CB36A04,$C2D7FFA7,$B5D0CF31,$2CD99E8B,$5BDEAE1D
            Data.i $9B64C2B0,$EC63F226,$756AA39C,$026D930A,$9C0906A9,$EB0E363F
            Data.i $72076785,$05005713,$95BF4A82,$E2B87A14,$7BB12BAE,$0CB61B38
            Data.i $92D28E9B,$E5D5BE0D,$7CDCEFB7,$0BDBDF21,$86D3D2D4,$F1D4E242
            Data.i $68DDB3F8,$1FDA836E,$81BE16CD,$F6B9265B,$6FB077E1,$18B74777
            Data.i $88085AE6,$FF0F6A70,$66063BCA,$11010B5C,$8F659EFF,$F862AE69
            Data.i $616BFFD3,$166CCF45,$A00AE278,$D70DD2EE,$4E048354,$3903B3C2
            Data.i $A7672661,$D06016F7,$4969474D,$3E6E77DB,$AED16A4A,$D9D65ADC
            Data.i $40DF0B66,$37D83BF0,$A9BCAE53,$DEBB9EC5,$47B2CF7F,$30B5FFE9
            Data.i $BDBDF21C,$CABAC28A,$53B39330,$24B4A3A6,$BAD03605,$CDD70693
            Data.i $54DE5729,$23D967BF,$B3667A2E,$C4614AB8,$5D681B02,$2A6F2B94
            Data.i $B40BBE37,$C30C8EA1,$5A05DF1B,$2D02EF8D
        EndDataSection   
    CompilerEndIf

    DataSection
        TABLE_ONE:
         Data.a   0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14
     EndDataSection 
     
    DataSection
        TABLE_TWO:
         Data.i  0,1,2,3,4,6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024
         Data.i 1536,2048,3072,4096,6144,8192,12288,16384,24576,32768,49152
     EndDataSection 
     
    DataSection
        TABLE_THREE:
         Data.i 0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383,32767
    EndDataSection        
    
    DataSection
        TABLE_FOUR:
        Data.a 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
        Data.a 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
    EndDataSection    
    
    DataSection
        OFFSET_LEN:
        Data.a 0,0,0,0,0,0,0,0
    EndDataSection 
    
    DataSection
        OFFSET_TBL:
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0        
    EndDataSection    
    
    DataSection
        HUFFMAN_LEN:
        Data.a 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    EndDataSection       
    
    DataSection
        HUFFMAN_TBL:
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        Data.i 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0       
    EndDataSection 
    
    Structure TBL_ONE
        table.a[32]
    EndStructure 
    
    Structure TBL_TWO
        table.i[32]
    EndStructure 
    
    Structure TBL_THREE
        table.i[16]
    EndStructure  
    
    Structure TBL_FOUR
        table.a[34]
    EndStructure 
    
    Structure OFF_LEN
        Len.a[8]
    EndStructure
    
    Structure OFF_TBL
        Tbl.i[129]
    EndStructure 
    
    Structure HUF_LEN
        Len.a[20]
    EndStructure
    
    Structure HUF_TBL
        Tbl.i[97]
    EndStructure   
    
    Structure LIT_LEN               ; unsigned char literal_len[768];
        Len.a[7681]
    EndStructure    
    
    Structure LIT_TBL             ; unsigned short literal_table[5120];
        Tbl.i[5120]
    EndStructure    
    
    Procedure LogicalAND(a,b)           ; Conversion from &&
                                        ; Ob das richtig bezweifle ich. Aber das Auflisten der Dateiene deckt sich mit 'unlzx für Windows 95'                                        ;    
        If (a = 0 And b = 0)
            ProcedureReturn  0
        ElseIf  (a = 0 And b = 1)  
            ProcedureReturn  0
        ElseIf  (a = 1 And b = 0)  
            ProcedureReturn  0  
        ElseIf  (a = 1 And b = 1)  
            ProcedureReturn  1
        EndIf   
        
    EndProcedure    
        

    Macro UNINT(a)
        (a)&$ffffffff
    EndMacro  


    ;
    ;
    ;    
    ; Modus: 0 - Berechne die CRC für das gesamte Archiv
    ; Modus: 1 - Nur für die jeweilge Datei
    ;

    Procedure .i    crc_calc(*Memory.CRC_Memory,*UnLZX.LZX_ARCHIVE, length.i, *FileCalc.ascii = #Null, Modus = 0)
        
        CompilerIf ( #PB_Processor_x64 )       
            
        Structure CRC
            crc.i[256]
        EndStructure  
        
        Select Modus
            Case 0
                Dim Calculation.a(256)
                For Hash = 0 To 255 
                    Calculation(Hash) = *Memory\c[Hash]
                Next
            Case 1
                Dim Calculation.a(length)
                For Hash = 0 To length-1
                    Calculation(Hash) = *FileCalc\a
                    *FileCalc + 1
                Next 
        EndSelect        
 
        ;
        ; Die CRC Summe berechnen
        
        Protected CRC.i, *Table.CRC
        
        *Table = ?CRC_TABLE
                
        If( length > 0)
            
            CRC = UNINT(~*UnLZX\sum) ; /* was (sum ^ 4294967295) */  
            
            While i < Length             
                
                CRC = UNINT(*Table\crc[Calculation(i) ! CRC & 255] ! (CRC >> 8));  temp = crc_table[(*memory++ ^ temp) & 255] ^ (temp >> 8);
                ;
                ;CRC = UNINT(*Table\crc[*Memory\c[i] ! CRC & 255] ! (CRC >> 8));  temp = crc_table[(*memory++ ^ temp) & 255] ^ (temp >> 8);
                ;Debug "CRC Table: " + Str(CRC) + " - Char: " + Str( *Memory\c[i] )                                
                i + 1                
                
            Wend            
            
            Select Modus
                Case 0            
                    *UnLZX\sum            = UNINT(~CRC); /* was (temp ^ 4294967295) */
                Case 1       
                    *UnLZX\FileData()\crc = UNINT(~CRC); /* was (temp ^ 4294967295) */                    
            EndSelect        
            FreeArray( Calculation() )            
        EndIf    
  
    CompilerEndIf  
    
     CompilerIf ( #PB_Processor_x86 )
;     
; 
;         
;         Protected *mem.long, temp.l, *crc_table.CRC86
;         
;         Select Modus
;             Case 0
;                 *mem = *Memory
;             Case 1
;                 *mem = *FileCalc
;         EndSelect
;         
;         ;
;         ; Die CRC Summe berechnen
;         
;         *crc_table = ?CRC_TABLE86
;         
;         If length > 0
;             
;             Select Modus
;                 Case 0
;                     temp = UNINT(~*UnLZX\sum) ; /* was (sum ^ 4294967295) */
;                 Case 1
;                     temp = ~*UnLZX\FileData()\crc
;             EndSelect
;             
;             ;Debug "temp: " + Hex(temp, #PB_Long)
;             
;             Repeat
;                 ;Debug Hex(*mem\l) + " " + Str((*mem\l ! temp) & 255) + " " + Hex(temp)
;                 temp = *crc_table\crc[(*mem\l ! temp) & 255] ! ((temp & $FFFFFFFF) >> 8)
;                 *mem + 1
;                 Length - 1
;             Until Length = 0
;             
;             Select Modus
;                 Case 0            
;                     *UnLZX\sum            = ~temp & $FFFFFFFF; /* was (temp ^ 4294967295) */
;                 Case 1       
;                     *UnLZX\FileData()\crc = ~temp & $FFFFFFFF; /* was (temp ^ 4294967295) */                    
;             EndSelect
;             
;             Debug "sum: " + Hex(*UnLZX\sum, #PB_Long)
;         EndIf         
;         
     CompilerEndIf         
    EndProcedure
    ;
    ;
    ;
    Procedure .s    Get_Unpack(size.i)
                
        If ( size = 0 )
            ProcedureReturn "n/a"
        EndIf    
        ProcedureReturn Str(size)
        
    EndProcedure    
    ;
    ;
    ;
    Procedure .s    Get_Packed(size.i,c.b)
                
        If (c & 1)
            ProcedureReturn "n/a"
        EndIf    
        
        ProcedureReturn Str(size)
        
    EndProcedure    
    ;
    ;
    ;
    Procedure .s    Get_Clock(hour.i,minute.i,second.i)
        
        ;
        ; TODO 
        szClock.s = RSet(Str(hour),2,Chr(48)) + ":" + RSet(Str(minute),2,Chr(48)) + ":" + RSet( Str(second),2,Chr(48))
        ProcedureReturn szClock
        
    EndProcedure
    ;
    ;
    ;
    Procedure .s    Get_Date(day.i,month.i,year.i)

        szDate.s =  RSet(Str(day),2,Chr(48)) + "-" + RSet(Str(month),2,Chr(48)) + "-" + Str(year)
        ProcedureReturn szDate
        
    EndProcedure 
    ;
    ;
    ;
    Procedure .s    Deb_Attrib(attrib.i)
        
        szAttrib.s ="--------"
        ;
        ;
        ; 0 = Kein Attribut gesetzt
        
        If ( (attributes & 32) > 0 )
            ;
            ; Attributes 'h'
            szAttrib = ReplaceString( szAttrib, "-", "h", 0,1,1)
        EndIf    
        
        If ( (attributes & 64) > 0 )
            ;
            ; Attributes 's'
            szAttrib = ReplaceString( szAttrib, "-", "s", 0,2,1)         
        EndIf
        
        If ( (attributes & 128) > 0 )
            ;
            ; Attributes 'p'
            szAttrib = ReplaceString( szAttrib, "-", "p", 0,3,1)         
        EndIf  
        
        If ( (attributes & 16) > 0 )
            ;
            ; Attributes 'a'
            szAttrib = ReplaceString( szAttrib, "-", "a", 0,4,1)           
        EndIf
        
        If ( (attributes & 1) > 0 )
            ;
            ; Attributes 'r': Read
            szAttrib = ReplaceString( szAttrib, "-", "r", 0,5,1)          
        EndIf         
        
        If ( (attributes & 2) > 0 )
            ;
            ; Attributes 'w': Write
            szAttrib = ReplaceString( szAttrib, "-", "w", 0,6,1)          
        EndIf 
        
        If ( (attributes & 8) > 0 )
            ;
            ; Attributes 'e': 
            szAttrib = ReplaceString( szAttrib, "-", "e", 0,7,1)                     
        EndIf         
        
        If ( (attributes & 4) > 0 )
            ;
            ; Attributes 'd': 
            szAttrib = ReplaceString( szAttrib, "-", "d", 0,8,1)                       
        EndIf                    
                    
        ProcedureReturn szAttrib
                
    EndProcedure
    ;
    ;
    ;
    Procedure      Get_Attrib(*UnLZX.LZX_ARCHIVE, attributes.i)
        
        *UnLZX\FileData()\AttribH = "-"
        *UnLZX\FileData()\AttribS = "-"
        *UnLZX\FileData()\AttribP = "-"
        *UnLZX\FileData()\AttribA = "-"
        *UnLZX\FileData()\AttribR = "-"
        *UnLZX\FileData()\AttribW = "-"
        *UnLZX\FileData()\AttribE = "-"
        *UnLZX\FileData()\AttribD = "-"      
        
        ;
        ;
        ; 0 = Kein Attribut gesetzt
        
        If ( (attributes & 32) > 0 )
            ;
            ; Attributes 'h'
            *UnLZX\FileData()\AttribH = "h"
        EndIf    
        
        If ( (attributes & 64) > 0 )
            ;
            ; Attributes 's'
            *UnLZX\FileData()\AttribS = "s"            
        EndIf
        
        If ( (attributes & 128) > 0 )
            ;
            ; Attributes 'p'
            *UnLZX\FileData()\AttribP = "p"            
        EndIf  
        
        If ( (attributes & 16) > 0 )
            ;
            ; Attributes 'a'
            *UnLZX\FileData()\AttribA = "a"            
        EndIf
        
        If ( (attributes & 1) > 0 )
            ;
            ; Attributes 'r': Read
            *UnLZX\FileData()\AttribR = "r"            
        EndIf         
        
        If ( (attributes & 2) > 0 )
            ;
            ; Attributes 'w': Write
            *UnLZX\FileData()\AttribW = "w"            
        EndIf 
        
        If ( (attributes & 8) > 0 )
            ;
            ; Attributes 'e':            
            *UnLZX\FileData()\AttribE = "e"            
        EndIf         
        
        If ( (attributes & 4) > 0 )
            ;
            ; Attributes 'd':        
            *UnLZX\FileData()\AttribD = "d"            
        EndIf                            
    EndProcedure     
    ;
    ;
    ;
    Procedure .s    Get_File(*UnLZX.LZX_ARCHIVE)
                
        Protected  szFile.s = ""
        
        szFile = PeekS(*UnLZX\Filename)
        
        ProcedureReturn szFile
        
    EndProcedure
    ;
    ;
    ;
    Procedure .s    Get_Comment(*UnLZX.LZX_ARCHIVE)
                        
        Protected  szComment.s = ""
        
        szComment = PeekS(*UnLZX\Comment)            
        
        ProcedureReturn szComment
        
    EndProcedure 
    ;
    ;
    ;
    Procedure       Make_Decode_Table_A_Offset(*p.LZX_LITERAL, *Decode.LZX_DECODE, number_symbols, table_size, *length.OFF_LEN, *table.OFF_TBL)
        
    	Debug "Decode Table Offset (B):"
    	While ( (*p\abort = 0) And (*Decode\bit_num <= table_size) )
    		
    		For symbol = 0 To number_symbols-1                      ;For(symbol = 0; symbol < number_symbols; symbol++)
    			
    			If ( *length\Len[symbol] = *Decode\bit_num )
    				
    				Debug "Decode Table Offset:                              /* reverse the order of the position's bits */"
    				*Decode\reverse = *Decode\pos
    				Debug "Decode Table Offset: reverse " + Str(*Decode\reverse)
    				
    				*Decode\leaf    = 0
    				*Decode\fill    = table_size
    				
    				Debug "Decode Table Offset:                              /* reverse the position */"
    				
    				While (*Decode\fill ! 0) 
    					
    					*Decode\leaf    = (*Decode\leaf << 1) + (*Decode\reverse & 1);                        
    					*Decode\reverse >> 1
    					
    					*Decode\fill - 1  
    					If *Decode\fill = 0
    						Break
    					EndIf
    					
    				Wend ;While(--fill)                  
    				
    				
    				*Decode\pos + *Decode\bit_mask
    				
    				If (*Decode\pos  > *Decode\table_mask)
    					
    					Debug "Decode Table Offset: /* we will overrun the table! abort! */"
    					*p\abort = 1
    					Break
    				EndIf
    				
    				*Decode\fill        =  *Decode\bit_mask
    				*Decode\next_symbol = 1 << *Decode\bit_num                    
    				
    				Debug "Decode Table Offset: next_symbol " + Str(*Decode\next_symbol)
    				
    				While (*Decode\fill ! 0)
    					
    					*table\Tbl[*Decode\leaf] = symbol                        
    					*Decode\leaf =  *Decode\leaf + *Decode\next_symbol
    					
    					*Decode\fill - 1
    					If *Decode\fill = 0
    						Break
    					EndIf                        
    					
    				Wend ;While(--fill)    
    				
    			EndIf 
    			Debug "Decode Table Offset: Symbol "+Str(symbol)+" - Bitmask "+Str( *Decode\bit_mask )+" - Position "+Str(*Decode\pos)
    			
    		Next
    		
    		*Decode\bit_mask >> 1            
    		*Decode\bit_num  + 1           
    	Wend 
        
        
    EndProcedure 
    ;
    ;
    ;
    Procedure       Make_Decode_Table_B_Offset(*p.LZX_LITERAL, *Decode.LZX_DECODE, number_symbols, table_size, *length.OFF_LEN, *table.OFF_TBL)
        
    	Debug "Decode Table Offset (B):"
    	While ( ( *p\abort = 0 ) And ( *Decode\bit_num <= 16) )
    		
    		;For(symbol = 0; symbol < number_symbols; symbol++)
    		For symbol = 0 To number_symbols-1
    			
    			If ( *length\Len[symbol] = *Decode\bit_num )
    				
    				Debug "Decode Table Offset:                              /* reverse the order of the position's bits */"
    				*Decode\reverse = *Decode\pos >> 16
    				
    				*Decode\leaf    = 0
    				*Decode\fill    = table_size
    				
    				Debug "Decode Table Offset:                              /* reverse the position */"
    				
    				While (*Decode\fill ! 0)
    					
    					*Decode\leaf    = (*Decode\leaf << 1) + (*Decode\reverse & 1)                                
    					*Decode\reverse >> 1
    					
    					*Decode\fill    - 1  
    				Wend ;While(--fill) 
    				
    				;For(fill = 0; fill < bit_num - table_size; fill++)                            
    				fill.i = *Decode\fill
    				
    				For fill = 0 To ( *Decode\bit_num - table_size)-1
    					
    					*Decode\fill = fill
    					
    					If ( *table\Tbl[*Decode\leaf] = 0 )
    						
    						*table\Tbl[ ( *Decode\next_symbol << 1 ) ] = 0
    						*table\Tbl[ ( *Decode\next_symbol << 1)+1] = 0
    						*table\Tbl[   *Decode\leaf ]               =  *Decode\next_symbol
    						
    						*Decode\next_symbol + 1
    						
    					EndIf 
    					
    					*Decode\leaf = *table\Tbl[*Decode\leaf] << 1
    					*Decode\leaf + (*Decode\pos >> ( 15 - *Decode\fill) ) & 1
    					
    				Next    
    				
    				*table\Tbl[*Decode\leaf] = symbol                    
    				*Decode\pos            + *Decode\bit_mask
    				
    				If ( *Decode\pos >  *Decode\table_mask )
    					Debug "Decode Table Offset:                              /* we will overrun the table! abort! */"
    					*p\abort = 1
    					Break
    				EndIf
    				
    			EndIf          
    		Next
    		*Decode\bit_mask >> 1            
    		*Decode\bit_num  + 1                            
    	Wend
    	
    	For u = 0 To 95
    		Debug "[" +Str(u) +"] " + Str(*table\Tbl[u]) 
    	Next     	
    
    EndProcedure 
    ;
    ;
    ;
    Procedure       Make_Decode_Table_A_Huffman(*p.LZX_LITERAL, *Decode.LZX_DECODE, number_symbols, table_size, *length.HUF_LEN, *table.HUF_TBL)       
                            
    	Debug "Decode Table Huffman (A):"
    	

    	
        While ( (*p\abort = 0) And (*Decode\bit_num <= table_size) )
            
            For symbol = 0 To number_symbols-1                      ;For(symbol = 0; symbol < number_symbols; symbol++)
                
                If ( *length\Len[symbol] = *Decode\bit_num )
                    
                    Debug "Decode Table Huffman:                              /* reverse the order of the position's bits */"
                    *Decode\reverse = *Decode\pos
                    Debug "Decode Table Huffman: reverse " + Str(*Decode\reverse)
                    
                    *Decode\leaf    = 0
                    *Decode\fill    = table_size
                    
                    Debug "Decode Table Huffman:                              /* reverse the position */"
                    
                   While (*Decode\fill ! 0)
                        
                        *Decode\leaf    = (*Decode\leaf << 1) + (*Decode\reverse & 1);                        
                        *Decode\reverse >> 1
                        
                        *Decode\fill - 1  
                    Wend ;While(--fill)                  
                    
                    
                    *Decode\pos + *Decode\bit_mask
                    
                    If (*Decode\pos  > *Decode\table_mask)
                    Debug "Decode Table Huffman: /* we will overrun the table! abort! */"
                        *p\abort = 1
                        Break
                    EndIf
                    
                    *Decode\fill        =  *Decode\bit_mask
                    *Decode\next_symbol = 1 << *Decode\bit_num                    
                    
                    Debug "Decode Table Huffman: next_symbol " + Str(*Decode\next_symbol)
                    
                    While (*Decode\fill ! 0)
                        
                        *table\Tbl[*Decode\leaf] = symbol                        
                        *Decode\leaf =  *Decode\leaf + *Decode\next_symbol
                        
                        *Decode\fill - 1
                        
                    Wend  ;While(--fill)                      
                EndIf 
                    Debug "Decode Table Huffman: Symbol "+Str(symbol)+" - Bitmask "+Str( *Decode\bit_mask )+" - Position "+Str(*Decode\pos)
  
            Next
            
            *Decode\bit_mask >> 1            
            *Decode\bit_num  + 1 
            Delay( 5 )
        Wend
        
    EndProcedure 
    ;
    ;
    ;
    Procedure       Make_Decode_Table_B_Huffman(*p.LZX_LITERAL, *Decode.LZX_DECODE, number_symbols, table_size, *length.HUF_LEN, *table.HUF_TBL)
    	Debug "Decode Table Huffman (B):"
    	
    	While ( ( *p\abort = 0 ) And ( *Decode\bit_num <= 16) )
    		
    		;For(symbol = 0; symbol < number_symbols; symbol++)
    		For symbol = 0 To number_symbols-1
    			
    			
    			If ( *length\Len[symbol] = *Decode\bit_num )
    				
    				
    				Debug "Decode Table Huffman:                              /* reverse the order of the position's bits */"
    				*Decode\reverse = *Decode\pos >> 16
    				
    				*Decode\leaf    = 0
    				*Decode\fill    = table_size
    				
    				
    				Debug "Decode Table Huffman:                              /* reverse the position */"
    				While (*Decode\fill ! 0)
    					
    					*Decode\leaf    = (*Decode\leaf << 1) + (*Decode\reverse & 1)                                
    					*Decode\reverse >> 1
    					
    					*Decode\fill    - 1  
    				Wend ;While(--fill) 
    				
    				
    				;For(fill = 0; fill < bit_num - table_size; fill++)                            
    				fill.i = *Decode\fill
    				
    				For fill = 0 To (*Decode\bit_num - table_size)-1
    					
    					*Decode\fill = fill
    					
    					If ( *table\Tbl[*Decode\leaf] = 0 )
    						
    						*table\Tbl[ ( *Decode\next_symbol << 1 ) ] = 0
    						*table\Tbl[ ( *Decode\next_symbol << 1)+1] = 0
    						*table\Tbl[   *Decode\leaf ]               =  *Decode\next_symbol
    						
    						*Decode\next_symbol + 1
    						
    					EndIf 
    					
    					*Decode\leaf = *table\Tbl[*Decode\leaf] << 1
    					*Decode\leaf + (*Decode\pos >> ( 15 - *Decode\fill) ) & 1
    					
    				Next    
    				
    				*table\Tbl[*Decode\leaf] = symbol                    
    				*Decode\pos            + *Decode\bit_mask
    				
    				If ( *Decode\pos >  *Decode\table_mask )
    					Debug "Decode Table Huffman:                              /* we will overrun the table! abort! */"
    					*p\abort = 1
    					Break
    				EndIf
    				
    			EndIf          
    		Next
    		*Decode\bit_mask >> 1            
    		*Decode\bit_num  + 1    
    		
    		Delay( 5 )
    	Wend          
   
    EndProcedure 
    ;
    ;
    ;
    Procedure       Make_Decode_Table_A_Literal(*p.LZX_LITERAL, *Decode.LZX_DECODE, number_symbols, table_size, *length.LIT_LEN, *table.LIT_TBL)
               
    	Debug "Decode Table Literal (A):"
    	While ( (*p\abort = 0) And (*Decode\bit_num <= table_size) )
    		
    		For symbol = 0 To number_symbols-1
    			
    			If ( *length\Len[symbol] = *Decode\bit_num )
    				
    				Debug "Decode Table Literal:                              /* reverse the order of the position's bits */"
    				*Decode\reverse = *Decode\pos
    				Debug "Decode Table Literal: reverse " + Str(*Decode\reverse)
    				
    				*Decode\leaf    = 0
    				*Decode\fill    = table_size
    				
    				Debug "Decode Table Literal:                              /* reverse the position */"
    				
    				While (*Decode\fill ! 0)
    					
    					*Decode\leaf    = (*Decode\leaf << 1) + (*Decode\reverse & 1);                        
    					*Decode\reverse >> 1
    					
    					*Decode\fill - 1  
    					If *Decode\fill = 0
    						Break
    					EndIf
    				Wend	;While(--fill)                  
    				
    				
    				*Decode\pos + *Decode\bit_mask
    				
    				If (*Decode\pos  > *Decode\table_mask)
    					Debug "Decode Table Literal: /* we will overrun the table! abort! */"
    					*p\abort = 1
    					Break
    				EndIf
    				
    				*Decode\fill        =  *Decode\bit_mask
    				*Decode\next_symbol = 1 << *Decode\bit_num                    
    				
    				Debug "Decode Table Literal: next_symbol " + Str(*Decode\next_symbol)
    				
    				While (*Decode\fill ! 0)
    					
    					*table\Tbl[*Decode\leaf] = symbol                        
    					*Decode\leaf =  *Decode\leaf + *Decode\next_symbol
    					
    					*Decode\fill - 1
    					If *Decode\fill = 0
    						Break
    					EndIf    					
    				Wend	;While(--fill)                        
    			EndIf 
    			Debug "Decode Table Literal: Symbol "+Str(symbol)+" - Bitmask "+Str( *Decode\bit_mask )+" - Position "+Str(*Decode\pos)
    			
    		Next
    		
    		*Decode\bit_mask >> 1            
    		*Decode\bit_num  + 1           
    	Wend
        
    EndProcedure 
    ;
    ;
    ;
    Procedure       Make_Decode_Table_B_Literal(*p.LZX_LITERAL, *Decode.LZX_DECODE, number_symbols, table_size, *length.LIT_LEN, *table.LIT_TBL)
        Debug "Decode Table Literal (B):"
        
        While ( ( *p\abort = 0 ) And ( *Decode\bit_num <= 16) )
            
            ;For(symbol = 0; symbol < number_symbols; symbol++)
            For symbol = 0 To number_symbols-1
                
                If ( *length\Len[symbol] = *Decode\bit_num )
                    
                    Debug "Decode Table Literal:                              /* reverse the order of the position's bits */"
                    *Decode\reverse = *Decode\pos >> 16
                    
                    *Decode\leaf    = 0
                    *Decode\fill    = table_size
                    
                    Debug "Decode Table Literal:                              /* reverse the position */"
                    While (*Decode\fill ! 0)
                        
                        *Decode\leaf    = (*Decode\leaf << 1) + (*Decode\reverse & 1)                                
                        *Decode\reverse >> 1
                        
                        *Decode\fill    - 1  
                   Wend ;While(--fill) 
                    
                    ;For(fill = 0; fill < bit_num - table_size; fill++)                            
                    fill.i = *Decode\fill
                    
                    For fill = 0 To ( *Decode\bit_num - table_size)-1
                        
                        *Decode\fill = fill
                        
                        If ( *table\Tbl[*Decode\leaf] = 0 )
                            
                            *table\Tbl[ ( *Decode\next_symbol << 1 ) ] = 0
                            *table\Tbl[ ( *Decode\next_symbol << 1)+1] = 0
                            *table\Tbl[   *Decode\leaf ]               =  *Decode\next_symbol
                            
                            *Decode\next_symbol + 1
                            
                        EndIf 
                        
                        *Decode\leaf = *table\Tbl[*Decode\leaf] << 1
                        *Decode\leaf + (*Decode\pos >> ( 15 - *Decode\fill) ) & 1
                        
                    Next    
                    
                    *table\Tbl[*Decode\leaf] = symbol                    
                    *Decode\pos            + *Decode\bit_mask
                    
                    If ( *Decode\pos >  *Decode\table_mask )
                    Debug "Decode Table Literal:                              /* we will overrun the table! abort! */"
                        *p\abort = 1
                        Break
                    EndIf
                    
                EndIf          
            Next
            *Decode\bit_mask >> 1            
            *Decode\bit_num  + 1                            
        Wend            
    EndProcedure  
    ;
    ;
    ;
    Procedure       Make_decode_table(*p.LZX_LITERAL, number_symbols, table_size, *OffSetLEN.OFF_LEN, *OffSetTBL.OFF_TBL, 
                                                                                  *HuffmnLEN.HUF_LEN, *HuffmnTBL.HUF_TBL,
                                                                                  *LiteraLEN.LIT_LEN, *LiteraTBL.LIT_TBL,  TableSelect.i = 0)
        *p\abort         = 0 
       
        *Decode.LZX_DECODE = AllocateStructure(LZX_DECODE)
        
        *Decode\bit_num       = 0
        symbol.i      = 0
        *Decode\leaf          = 0
        *Decode\table_mask    = 0        
        *Decode\bit_mask      = 0      
        *Decode\pos           = 0
        *Decode\fill          = 0
        *Decode\next_symbol   = 0        
        *Decode\reverse       = 0           
               
        
        *Decode\pos           = 0  ;/* consistantly used As the current position IN the decode table */
        
        *Decode\table_mask    = 1 << table_size
        *Decode\bit_mask      = 1 << table_size
        
        *Decode\bit_mask >> 1; /* don't do the first number */
        *Decode\bit_num + 1  ;        

        Select TableSelect
        	Case 0: Make_Decode_Table_A_Offset (*p,*Decode, number_symbols, table_size, *OffSetLEN, *OffSetTBL):Delay(25)
        	Case 1: Make_Decode_Table_A_Huffman(*p,*Decode, number_symbols, table_size, *HuffmnLEN, *HuffmnTBL):Delay(25)
        	Case 2: Make_Decode_Table_A_Literal(*p,*Decode, number_symbols, table_size, *LiteraLEN, *LiteraTBL):Delay(25)               
        EndSelect
        
               
        
        ;Debug "Make Decode Table [*Decode\pos] ("+Str( *Decode\pos )
        
        If ( ( *p\abort = 0) And ( *Decode\pos ! *Decode\table_mask ) )
        	
        	;For(symbol = pos; symbol < table_mask; symbol++)
        	For symbol = *Decode\pos To *Decode\table_mask-1        ; /* clear the rest of the table */
        		
        		Debug "Make Decode Table() /* reverse the order of the position's bits */"
        		*Decode\reverse = symbol         
        		*Decode\leaf    = 0		
        		*Decode\fill    = table_size	
        		
        		Debug "Make Decode Table() /* reverse the position */"
        		
        		While (*Decode\fill ! 0)
        			
        			*Decode\leaf = (*Decode\leaf << 1) + (*Decode\reverse & 1);
        			
        			*Decode\reverse >> 1
        			
        			*Decode\fill - 1 
        			If *Decode\fill = 0
        				Break;
        			EndIf	
        		Wend ;While(--fill)
        		
        		Select TableSelect
        			Case 0: *OffSetTBL\Tbl[*Decode\leaf] = 0
        			Case 1: *HuffmnTBL\Tbl[*Decode\leaf] = 0
        			Case 2: *LiteraTBL\Tbl[*Decode\leaf] = 0                       
        		EndSelect                
        		
        	Next symbol   
        	
        	*Decode\next_symbol = *Decode\table_mask >> 1
        	*Decode\pos         << 16
        	*Decode\table_mask  << 16
        	*Decode\bit_mask    = 32768
        	
        	Select TableSelect
        		Case 0: Make_Decode_Table_B_Offset (*p,*Decode, number_symbols, table_size, *OffSetLEN, *OffSetTBL):Delay(25)
        		Case 1: Make_Decode_Table_B_Huffman(*p,*Decode, number_symbols, table_size, *HuffmnLEN, *HuffmnTBL):Delay(25)
        		Case 2: Make_Decode_Table_B_Literal(*p,*Decode, number_symbols, table_size, *LiteraLEN, *LiteraTBL):Delay(25)                      
        	EndSelect         	
        	
        EndIf    
        
        Select TableSelect
        	Case 0
        		If( *Decode\pos ! *Decode\table_mask)
        			Debug  "Make Decode Table(Offset) /* the table is incomplete! */"
        			*p\abort = 1
        		EndIf
        	Case 1
        		If( *Decode\pos ! *Decode\table_mask)
        			Debug  "Make Decode Table(Huffman) /* the table is incomplete! */"
        			*p\abort = 1
        		EndIf  
        	Case 2
        		If( *Decode\pos ! *Decode\table_mask)
        			Debug  "Make Decode Table(Literal) /* the table is incomplete! */"
        			*p\abort = 1
        		EndIf         			
        EndSelect  
        
        ProcedureReturn *p\abort 
        
    EndProcedure    
    ;
    ;
    ;
    Procedure       Read_Literal_Shift(*p.LZX_LITERAL)
        
        ; C Conversion 
        ;
        ; shift += 16;
        ; control += *source++ << (8 + shift);
        ; control += *source++ << shift;       
        
        *p\shift + 16
        
        *p\control + *p\source\a << (8 + *p\shift)
        *p\source + 1

        ;Debug "Read Literal Shift Routine - Control: " + RSet( Str( *p\control ),10," ")  + " :: Source Char " + Str(*p\source\a )   
        
        *p\control + *p\source\a << *p\shift
        *p\source + 1
        ;Debug "Read Literal Shift Routine - Control: " + RSet( Str( *p\control ),10," ") + " :: Source Char " + Str(*p\source\a )
        
    EndProcedure
    ;
    ;
    ;
    Procedure       Read_Literal_Shift_24(*p.LZX_LITERAL)
        
        *p\shift + 16
        

        *p\control + *p\source\a << 24
        *p\source + 1
        
        ;Debug "Read Literal Shift Routine - Control: " + RSet( Str( *p\control ),10," ")  + " :: Source Char " + Str(*p\source\a )   
        
        *p\control + *p\source\a << 16
        *p\source + 1
        ;Debug "Read Literal Shift Routine - Control: " + RSet( Str( *p\control ),10," ") + " :: Source Char " + Str(*p\source\a )  
        
    EndProcedure    
    ;
    ;
    ;
    Procedure       Read_Literal_Table_Build_Offset_Huffman_Table(*p.LZX_LITERAL, *OffSetLEN.OFF_LEN, *OffSetTBL.OFF_TBL)
        
        Protected temp.i
        ;
        ;
        If( (*p\abort = 0) And ( *p\decrunch_method = 3) )
            
            For temp = 0 To 7                
                               
                *OffSetLEN\Len[temp] = *p\control & 7  
                *p\control          >> 3               
                *p\shift             - 3  
                
                If  ( *p\shift < 0)                                      
                    Read_Literal_Shift(*p)                    
                EndIf                    
            Next                         
            
            Debug "Make Decode Table: Offset"  
            *p\abort = Make_decode_table(*p, 8, 7, *OffSetLEN, *OffSetTBL, 0, 0,  0, 0, 0)               
        EndIf         
              
    EndProcedure
    ;
    ;
    ;
    Procedure       Read_Literal_Table_Decrunch_Length(*p.LZX_LITERAL)
        
        
        If ( *p\abort = 0 )
            
            *p\decrunch_length = (*p\control & 255) << 16
            *p\control         >> 8
                       
                 *p\shift - 8
            If ( *p\shift < 0 )                            
                    Read_Literal_Shift(*p)                                
            EndIf      
            
            *p\decrunch_length + (*p\control & 255) << 8
            *p\control         >> 8
            
                 *p\shift - 8          
            If ( *p\shift < 0 )                         
                    Read_Literal_Shift(*p)                                
            EndIf                 
            
            *p\decrunch_length + (*p\control & 255)
            *p\control         >> 8            
            
                 *p\shift - 8
            If ( *p\shift < 0 )          
                    Read_Literal_Shift(*p)                                
           EndIf                                                
        EndIf          
        
    EndProcedure
    ;
    ;
    ;
    Procedure       Read_Literal_Table_Huffman_Decode(*p.LZX_LITERAL, *Huffman20LEN.HUF_LEN, *Huffman20TBL.HUF_TBL)
        
        Protected temp.i
        
        For temp = 0 To 19            ;  For(temp = 0; temp < 20; temp++)   
            
            *Huffman20LEN\Len[temp] = *p\control & 15
            
            *p\control >> 4
            
            *p\shift - 4
            If ( *p\shift < 0 )    
                Read_Literal_Shift(*p)                                
            EndIf
        Next
        
        Debug "Make Decode Table: Huffman"              
        
        *p\abort = Make_decode_table(*p, 20, 6, 0, 0, *Huffman20LEN, *Huffman20TBL,  0, 0, 1)
                        
    EndProcedure
    ;
    ;
    ;
    Macro LOBYTE(byte)     : ( byte & $FF )             : EndMacro
    Macro HIBYTE(byte)     : (( byte >> 8 ) & $FF)      : EndMacro
    Macro LOWORD( word )   : (word & $FFFF)             : EndMacro
    Macro HIWORD( word )   : ((word >> 16) & $FFFF)     : EndMacro
    Macro MAKEWORD(a, b)   : (a & $FF)|((b & $FF)<<8)   : EndMacro
    Macro MAKELONG(a, b)   : ((a&$FFFF)+b<<16)          : EndMacro    
    Procedure      Read_Literal_Table_IsSymbol(*p.LZX_LITERAL, *Huffman20TBL.HUF_TBL)
    	
    	;*p\symbol = *Huffman20TBL\Tbl[*p\control & 63]
    	
    EndProcedure
    Procedure       Read_Literal_Table_Huffman_6BitsL(*p.LZX_LITERAL, *Huffman20LEN.HUF_LEN, *Huffman20TBL.HUF_TBL)
        
    	Protected temp.i
    	
    	*p\symbol =  *Huffman20TBL\Tbl[ *p\control & 63]
    	
    	If ( *p\symbol >= 20 )
    		
    		Debug "Read Literal Table:                              /* symbol is longer than 6 bits */"
    		
    		While(*p\symbol >= 20);   
    			

    			*p\symbol = *Huffman20TBL\Tbl[ ( ( *p\control >> 6) & 1  +  *p\symbol <<1 ) ]       ;  !!!!!!!!!!!!!!!!!!!!! 
    			
    			*p\shift  - 1
    			
    			If ( *p\shift < 0)                                
    				Read_Literal_Shift_24(*p)                                                                                                 
    			EndIf 
    			
    			*p\control  >> 1
    			    			
    		Wend
    		
    		temp = 6;                        
    	Else
    		temp = *Huffman20LEN\Len[*p\symbol]  
    	EndIf
    	
    	*p\control >> temp                    
    	*p\shift    - temp
    	
    	If ( *p\shift < 0 )   
    		Read_Literal_Shift(*p)                                
    	EndIf        
        
    EndProcedure
    ;
    ;
    ;
    ;    
    ;
    ;
    Procedure       Read_Literal_Table(*p.LZX_LITERAL , *OffSetLEN.OFF_LEN, *OffSetTBL.OFF_TBL, *LiteraLEN.LIT_LEN, *LiteraTBL.LIT_TBL)
        
    	Protected *Table_Three.TBL_THREE : *Table_Three = ?TABLE_THREE
    	Protected *Table_Four.TBL_FOUR   : *Table_Four  = ?TABLE_FOUR
    	
    	Protected *Huffman20LEN.HUF_LEN   : *Huffman20LEN  = ?HUFFMAN_LEN
    	Protected *Huffman20TBL.HUF_TBL   : *Huffman20TBL  = ?HUFFMAN_TBL
    	
    	Protected temp.i, pos.i, count.i, fix.i, max_symbol.i
    	
    	*p\abort    = 0        
    	*p\control  = *p\global_control
    	*p\shift    = *p\global_shift
    	
    	;
	;       
    	Debug "Read Literal Table:                              /* fix the control word If necessary */"
    	
    	If ( *p\shift < 0 )                     
    		Read_Literal_Shift(*p)
    	EndIf        
    	
    	;
	;       
    	Debug "Read Literal Table:                              /* Read the decrunch method */"
    	
    	*p\decrunch_method = *p\control & 7
    	*p\control         >> 3        
    	*p\shift           - 3
    	
    	If ( *p\shift < 0)
    		Read_Literal_Shift(*p)
    	EndIf
    	
    	Debug "Read Literal Table:                              /* Read And build the offset huffman table */"         
    	Read_Literal_Table_Build_Offset_Huffman_Table(*p, *OffSetLEN, *OffSetTBL)
    	
    	;        
	;                                                       /* Read decrunch length */
    	Debug "Read Literal Table:                              /* Read decrunch length */"
    	Read_Literal_Table_Decrunch_Length(*p)
    	
    	;
	;        
	;                                                       /* Read And build the huffman literal table */
    	Debug "Read Literal Table:                              /* Read And build the huffman literal table */"  
    	
    	If ( (*p\abort = 0) And ( *p\decrunch_method ! 1) )
    		
    		pos         = 0
    		fix         = 1
    		max_symbol  = 256            
    		
    		Repeat
    			
    			Read_Literal_Table_Huffman_Decode(*p, *Huffman20LEN, *Huffman20TBL)
    			
    			If (*p\abort = 1)
    				Debug "Read Literal Table:                              /* argh! table is corrupt! */"
    				Break
    			EndIf
    			
    			Repeat
    				
    				Read_Literal_Table_Huffman_6BitsL(*p, *Huffman20LEN, *Huffman20TBL)
    				
    				Select *p\symbol
    					Case 17, 18
    						
    						If ( *p\symbol = 17 )                                
    							temp     = 4                                
    							*p\count = 3                                                                    
    							
    						ElseIf *p\symbol = 18
    							
    							temp = 6 - fix;
    							*p\count = 19 ;                                                                    
    						EndIf
    						
    						*p\count    + ( *p\control & *Table_Three\table[temp] ) + fix
    						*p\control  >> temp                            
    						*p\shift    - temp
    						
    						If ( *p\shift < 0 )  
    							Read_Literal_Shift(*p)                                
    						EndIf
    						
    						
    						While (pos < max_symbol ); And ( *p\count = 0) )
    							pos                  + 1
    							
    							*LiteraLEN\Len[pos] = 0                                                                      
    							*p\count             - 1 
    							If  ( *p\count = 0 )
    								Break
    							EndIf
    							
    						Wend 
    						
    					Case 19
    						
    						*p\count    = (*p\control & 1) + 3 + fix
    						
    						*p\shift    - 1
    						If ( *p\shift < 0)                                
    							Read_Literal_Shift_24(*p)                                                                                                 
    						EndIf
    						
    						*p\control >> 1                            
    						*p\symbol   = *Huffman20TBL\Tbl[*p\control & 63]
    						
    						If (*p\symbol >= 20)       ;If((symbol = huffman20_table[control & 63]) >= 20)
    							
    							Debug "Read Literal Table:                              /* symbol is longer than 6 bits */"
    							
    							While (*p\symbol >= 20)                                              
    								*p\symbol = *Huffman20TBL\Tbl[ ( (*p\control >> 6) & 1) + (*p\symbol << 1) ]                                   
    								*p\shift  - 1
    								
    								If ( *p\shift < 0)                                        
    									Read_Literal_Shift_24(*p)                                                                                                  
    								EndIf       
    								
    								*p\control  >> 1                                    
    								
    							Wend       
    							temp = 6;   
    						Else    
    							temp = *Huffman20LEN\Len[*p\symbol]                                  
    						EndIf    
    						
    						*p\control >> temp                    
    						*p\shift    - temp
    						
    						If ( *p\shift < 0 )   
    							Read_Literal_Shift(*p)                                
    						EndIf                                                 
    						
    						*p\symbol =  *Table_Four\table[ *LiteraLEN\Len[pos] + 17 - *p\symbol ]
    						
    						While (pos < max_symbol ); And ( *p\count = 0) )
    							pos                 + 1
    							*LiteraLEN\Len[pos] = 0                                   
    							*p\count            - 1 
    							If  ( *p\count = 0 )
    								Break
    							EndIf
    						Wend                              
    						
    					Default
    						
    						Debug "Repeat: " +Str( *LiteraLEN\Len[pos] + 17 - *p\symbol)+ " --  Symbol A " +Str(17 - *p\symbol)+ " --  Symbol B " +Str(*p\symbol)   
    						
    						*p\symbol           =  *Table_Four\table[ *LiteraLEN\Len[ pos ] + 17 - *p\symbol ]         
    						*LiteraLEN\Len[pos] = *p\symbol                        
    						pos                 + 1                                                          
    				EndSelect        
    				
    				Debug "Repeat: Position "+ Str(pos) +": Max Symbol: "+ Str(max_symbol) +": Control: "+ Str(*p\control) +": Shift: "+ Str(*p\shift)
    				
    				Delay(25)	
    			Until ( Bool( pos < max_symbol) = 0)    
    			
    			fix - 1
    			max_symbol + 512  
    			
    			; Debug " Fix : " + Str( fix ) + ": Max Symbol: " + Str(max_symbol )  
    			
    			Delay(25)
    			
    		Until  (Bool( max_symbol = 768) = 0)
    		
    		If ( *p\abort = 0 )                 
    			Debug "Make Decode Table: Literal" 
    			*p\abort = Make_decode_table(*p, 768, 12, 0, 0, 0, 0,   *LiteraLEN,  *LiteraTBL, 2)                 
    			
    		EndIf    
    		
    	EndIf
    	*p\global_control   = *p\control;
    	*p\global_shift     = *p\shift	;        
    	
    	ProcedureReturn *p\abort
    EndProcedure    
    ;
    ;
    ;   
    Procedure .i    Decrunch_Stop(*DestBeg.ascii, *DestEnd.ascii, *SourceBeg.ascii, *SourceEnd.ascii)
                
            If ( (*DestBeg < *DestEnd) And (*SourceBeg < *SourceEnd) )
                ProcedureReturn #True
            Else
                ProcedureReturn #False
            EndIf       
    EndProcedure 
    ;
    ;
    ;  
    Procedure       Decrunch_BufferDebug(*buffer.decrunch_buffer)
            ;
            ; Buffer test
        
            Protected sz.i, szString.s, szSign.s
            
            Dim DecrunchBuf.a( SizeOf(decrunch_buffer)-1 )
            For sz = 0 To SizeOf(decrunch_buffer)-1
                DecrunchBuf(sz) = *buffer\c[sz]
            Next    
            
            Debug "========================================================================= ; DEMO ;"
            
            For sz = 0 To SizeOf(decrunch_buffer)-1                                
                If ( DecrunchBuf(sz) > 0 )                    
                  
                    Select DecrunchBuf(sz)
                        Case 10
                            szSign = "\n"
                        Default       
                            szSign = RSet( Chr( DecrunchBuf(sz) ),2, " ")
                    EndSelect        
                    Debug "Decrunch Buffer [" +RSet( Str(sz), 6, " ")+"] " + RSet( Str( DecrunchBuf(sz) ),3, " ") + " " + Chr(39) + " " +  szSign  + " "+ Chr(39)             
                EndIf    
                
               szString  + Chr( DecrunchBuf(sz) )                    
            Next
            
            Debug "========================================================================= ; DEMO ;"
            Debug ""
            Debug szString.s
            Debug "========================================================================= ; DEMO ;"
            
    EndProcedure
    ;
    ;
    ;
    Procedure .i    Decrunch(*p.LZX_LITERAL, *DecrBuffer.decrunch_buffer, *OffSetLEN.OFF_LEN,  *OffSetTBL.OFF_TBL, *LiteraLEN.LIT_LEN, *LiteraTBL.LIT_TBL)
        
    	Protected *Table_One.TBL_ONE     : *Table_One   = ?TABLE_ONE        
    	Protected *Table_Two.TBL_TWO     : *Table_Two   = ?TABLE_TWO
    	Protected *Table_Three.TBL_THREE : *Table_Three = ?TABLE_THREE        
    	
    	*p\control  = 0
    	*p\shift    = 0
    	*p\temp     = 0
    	*p\count    = 0
    	*p\symbol   = 0
    	
    	Structure STRINGS                ; unsigned char offset_len[8];
    		c.a[1]
    	EndStructure
    	
    	szString.s = ""
    	
    	
    	*string.STRINGS = AllocateStructure( STRINGS)
    	
    	*sz.ascii
    	
    	*p\control  = *p\global_control
    	*p\shift    = *p\global_shift
    	
    	*MemoryID.ascii = AllocateMemory(1000)
    	
    	
    	Repeat
    		*p\symbol = *LiteraTBL\Tbl[*p\control & 4095]            

    		
    		If (*p\symbol >= 768 )
    			
    			*p\control >> 12
    			
    			*p\shift   - 12                
    			If ( *p\shift < 0 )
    				Read_Literal_Shift(*p)
    			EndIf    
    			
    			; Debug "/* literal is longer than 12 bits */"
    			
    			Repeat
    				*p\symbol = *LiteraTBL\Tbl[ (*p\control & 1) + (*p\symbol << 1) ]                     
    				
    				*p\shift  - 1                    
    				If ( *p\shift = 0 )
    					Read_Literal_Shift_24(*p)
    				EndIf    
    				
    				*p\control >> 1    				
    			Until ( *p\symbol >= 768 )  
    			
    		Else    			
    			*p\temp     = *LiteraLEN\Len[*p\symbol]                
    			*p\control >> *p\temp    			
    			*p\shift    - *p\temp                
    			If ( *p\shift < 0 )
    				Read_Literal_Shift(*p)
    			EndIf             
    		EndIf
    		
    		If ( *p\symbol < 256 )
    			    			
    			*p\destination\a + *p\symbol
    			*p\destination   + 1 
    			           
    		Else
    			
    			*p\symbol - 256
    			*p\temp   = *p\symbol & 31
    			*p\count  = *Table_Two\table[*p\temp]
    			*p\temp   = *Table_One\table[*p\temp]
    			
    			If ( (*p\temp >= 3) And (*p\decrunch_method = 3) )
    				
 				*p\temp     - 3     				  				
    				*p\count    + ((*p\control & *Table_Three\table[ *p\temp ] ) << 3)
    				*p\control >> *p\temp    				
    				*p\shift    - *p\temp 
    				
    				If ( *p\shift  < 0)                        
    					Read_Literal_Shift(*p)
    				EndIf    
    				
    				*p\temp     = *OffSetTBL\Tbl[*p\control & 127]
    				*p\count    + *p\temp
    				*p\temp     =  *OffSetLEN\Len[*p\temp]                    
    				
    			Else    
    				
    				*p\count + *p\control & *Table_Three\table[ *p\temp ]
    				
    				If ( *p\count = 0 )
    					*p\count = *p\last_offset
    				EndIf 
    				
    			EndIf    
    			
    			*p\control >> *p\temp
    			
    			*p\shift    - *p\temp                
    			If ( *p\shift  < 0)                        
    				Read_Literal_Shift(*p)
    			EndIf
    			
    			*p\last_offset =  *p\count
    			*p\temp        =  *p\symbol >> 5    			
    			*p\count       =  *Table_Two\table[*p\temp & 15] + 3
    			*p\temp        =  *Table_One\table[*p\temp]    			
    			*p\count       + (*p\control & *Table_Three\table[*p\temp ])    			
    			*p\control     >> *p\temp    			
    			*p\shift       - *p\temp
    			
    			If ( *p\shift  < 0)                        
    				Read_Literal_Shift(*p)
    			EndIf
    			
    			;(decrunch_buffer + last_offset < destination) ?  destination - last_offset : destination + 65536 - last_offset;                                     
    			
    			
    			If ( ( *DecrBuffer + *p\last_offset) < *p\destination )     
    				
    				szString = PeekS(*p\destination - *p\last_offset, *p\destination - *p\last_offset, #PB_Ascii)
    				
    				PokeS(*MemoryID, szString, *p\destination - *p\last_offset, #PB_Ascii)
    				Debug "String: " + szString
    				Debug "Destination: "+ Str(*p\destination) +" - destination_end "+ Str(*p\destination_end) +" = (Result)  "+ Str(*p\destination_end-*p\destination) 
    				
    			Else
    				szString = PeekS(*p\destination + 65536 - *p\last_offset, *p\destination + 65536 - *p\last_offset, #PB_Ascii)
    				Debug "String: " + szString
    				PokeS(*MemoryID, szString, Len(szString), #PB_Ascii)                      
    			EndIf
    			
    			    			
    			Repeat                         				
    				*p\destination\a = *MemoryID\a
    				*p\destination   + 1      
    				*p\count         - 1        				    				
    			Until *p\count = 0
    			
    		EndIf    
    		
    		;  Debug "X: Destination: [" + Str(*p\destination) + "] Destination End [" + Str(*p\destination_end) + "] Source [" + Str(*p\source) + "] Source End [" + Str(*p\source_end) + "]"

    	Until Decrunch_Stop(*p\destination, *p\destination_end, *p\source, *p\source_end) = #False
    	
    	Decrunch_BufferDebug(*DecrBuffer)
    	
    	*p\global_control   = *p\control;
    	*p\global_shift     = *p\shift	;          
    EndProcedure     
    ;
    ;
    ;     
    Procedure .i    open_output(*UnLZX.LZX_ARCHIVE)
        
        Protected  szDestination.s = "B:\"
        
        
        ;
        ; Verzeichnis Anlegen
        Select FileSize( szDestination + *UnLZX\File + "\")
               Case -1: CreateDirectory( szDestination + *UnLZX\File + "\" )                    
        EndSelect         
        
        *UnLZX\Dest = szDestination + *UnLZX\File + "\"
        
        DirSplit.i = CountString( *UnLZX\FileData()\File, "/")
        szSearch.s = *UnLZX\FileData()\File
        pos_1 = 1
        
        For u = 0 To DirSplit -1
        	
        	pos_2.i = FindString( *UnLZX\FileData()\File, "/", 1 )
        	
        	If ( pos_2 > 0 )
        		DirectoryName.s = Mid( szSearch, pos_1, ( pos_2 - pos_1 ) )
        		
        		Select FileSize( *UnLZX\Dest + "\" + DirectoryName + "\")
        			Case -1
        				CreateDirectory( *UnLZX\Dest + "\" + DirectoryName + "\" )        			        				
        		EndSelect
        		
        		*UnLZX\Dest = *UnLZX\Dest + "\" + DirectoryName + "\"
        				
        		szSearch = ReplaceString( szSearch, DirectoryName + "/", "" ,0, 1, 1)        		
        		
        	EndIf        	        		
        Next	
        	
        Debug "Amiga Slahes: " + *UnLZX\FileData()\File 
        *UnLZX\FileData()\File = ReplaceString( *UnLZX\FileData()\File, "/", "\",0,1,DirSplit)
        Debug "PCDOS Slahes: " + *UnLZX\FileData()\File        	
        
        *UnLZX\Dest = szDestination + *UnLZX\File + "\"
        pbFile = CreateFile(#PB_Any,   *UnLZX\Dest + *UnLZX\FileData()\File)
        If ( pbFile > 0 )
            ProcedureReturn pbFile
            
        EndIf    
        
    EndProcedure    
    ;
    ;
    ;     
   
    Procedure .i    Extract_Normal(*UnLZX.LZX_ARCHIVE)
        
    	*p.LZX_LITERAL = AllocateStructure(LZX_LITERAL)
    	
    	Protected *OffSetLEN.OFF_LEN      : *OffSetLEN     = ?OFFSET_LEN
    	Protected *OffSetTBL.OFF_TBL      : *OffSetTBL     = ?OFFSET_TBL
    	
    	Protected *LiteraLEN.LIT_LEN      :
    	Protected *LiteraTBL.LIT_TBL      :
    	
    	Structure read_buffer
    		c.a[16384]
    	EndStructure 
    	
    	
    	*LiteraLEN.LIT_LEN           = AllocateStructure( LIT_LEN )
    	*LiteraTBL.LIT_TBL           = AllocateStructure( LIT_TBL )
    	
    	*ReadBuffer.read_buffer      = AllocateMemory( SizeOf( read_buffer) )        
    	*DecrBuffer.decrunch_buffer  = AllocateMemory( SizeOf( decrunch_buffer)  )                
    	
    	count = 0
    	
    	
    	*p\global_control           = 0      ; /* initial control word */
    	*p\global_shift             = -16
    	*p\last_offset              = 1
    	*p\decrunch_length          = 0         
    	*p\unpack_size              = 0
    	
    	;For count = 0 To 7
	;    *p\OffsetLen\c[count] = 0;
	;Next
    	
    	For count = 0 To 7
    		*OffSetLEN\Len[count] = 0;
    	Next        
    	
    	For count = 0 To 767
    		*LiteraLEN\Len[count] = 0;
    	Next
    	
    	;source_end = (source = read_buffer + 16384) - 1024;    
    	*p\source     = *ReadBuffer + 16384
    	*p\source_end = *p\source - 1024
    	
    	;pos = destination_end = destination = decrunch_buffer + 258 + 65536;
    	
    	*p\destination      = *DecrBuffer + 258 + 65536
    	*p\destination_end  = *p\destination 
    	*p\pos              = *p\destination_end 
    	
    	Debug ""
    	Debug ""
    	With *UnLZX\FileData()
    		
    		Debug "Extract_Normal: Extracting File: " + \File
    		
    		out_file = open_output(*UnLZX)
    		
    		Debug "Extract_Normal:                                    /* reset CRC */"
    		*UnLZX\FileData()\crc = 0
    		
    		*p\unpack_size = \SizeUnpack
    		*p\pack_size   = \SizePacked
    		
    		While ( *p\unpack_size > 0)
    			
    			Debug "Extract_Normal:                                    /* time To fill the buffer? */"
    			If ( *p\pos = *p\destination )
    				
    				Debug "Extract_Normal:                                    /* check If we have enough Data And Read some If Not */"
    				If (  *p\source >=  *p\source_end )
    					
    					Debug "Extract_Normal:                                    /* have we exhausted the current Read buffer? */"
    					*p\temp = *ReadBuffer;
    					
    					
    					If ( count = *p\temp -  *p\source + 16384 )                              
    						
    						Debug "Extract_Normal:                                    /* copy the remaining overrun To the start of the buffer */"                            
    						
    						Repeat                                
    							;
							;
							; *temp++ = *source++;
    							
    							*p\temp\a + *p\source\a
    							*p\source + 1
    							*p\temp   + 1                                
    							count     - 1
    							
    						Until ( count = 0 )
    					EndIf
    					count = 0
    					*p\source = *ReadBuffer
    					count =  *p\source -  *p\temp + 16384;
    					
    					If (  *p\pack_size <  count)
    						Debug "Extract_Normal:                                    /* make sure we don't read too much */"
    						count =  *p\pack_size
    					EndIf    
    					
    					Debug \SeekPosition
    					FileSeek(*UnLZX\pbData, \loc)                       
    					
    					If  ( ReadData( *UnLZX\pbData, *p\temp, count) = 0 )
    						Debug ""
    						Debug "/* fatal error */"
    						
    						*p\abort = 1;
    						Break
    					EndIf    
    					
    					*p\pack_size- count             ;  pack_size -= count;                        
    					*p\temp     + count		;  temp += count;
    					
    					If (  *p\source >=  *p\temp )
    						Debug "/* argh! no more data! */ "
    						Break                       
    					EndIf
    					
    				EndIf  
    				
    				Debug "Extract_Normal:                                    /* check if we need to read the tables */"
    				If (  *p\decrunch_length <= 0 )
    					
    					Read_Literal_Table(*p, *OffSetLEN,  *OffSetTBL, *LiteraLEN, *LiteraTBL)
    					
    					If  ( *p\abort = 1 )
    						Debug "/* argh! can't make huffman tables! */"
    						Break
    					EndIf    
    				EndIf    
    				
    				Debug "Extract_normal: Destination: "+ Str(*p\destination) +" - destination_end "+ Str(*p\destination_end) +" = (Result)  "+ Str(*p\destination_end-*p\destination) 
    				
    				Debug "Extract_Normal:                                    /* unpack some Data */"
    				If ( *p\destination >= ( *DecrBuffer + 258 + 65536 ))   
    					
    					If (count = ( *p\destination -  *DecrBuffer - 65536 ))
    						
    						*p\destination = *DecrBuffer 
    						*p\temp = *p\destination + 65536
    						
    						Debug "Extract_Normal:                                    /* copy the overrun to the start of the buffer */"
    						
    						Repeat                                                               
    							
    							;Debug "Anfang [Destination: " + Str(*p\destination)+ "][ Temp: "+Str(*p\temp)+" ]"
							;
							;  *destination++ = *temp++;
							;    
    							
    							*p\destination\a + *p\temp\a
    							*p\destination  + 1  
    							*p\temp + 1   
    							
    							count   - 1                
    						Until count = 0
    						
    						*p\pos  = *p\destination                                                        
    					EndIf                            
    				EndIf    
    				
    				*p\destination_end = *p\destination + *p\decrunch_length
    				
    				If ( *p\destination_end > *DecrBuffer + 258 + 65536 )
    					*p\destination_end = *DecrBuffer + 258 + 65536
    				EndIf    
    				
    				*p\temp = 0;
    				
    				*p\temp = *p\destination
    				
    				Debug "Extract_normal: Destination: "+ Str(*p\destination) +" - destination_end "+ Str(*p\destination_end) +" = (Result)  "+ Str(*p\destination_end-*p\destination) 
    				
    				decrunch(*p, *DecrBuffer, *OffSetLEN, *OffSetTBL, *LiteraLEN, *LiteraTBL)
    				
    				*p\decrunch_length - (*p\destination  -  *p\temp);
    				
    				
    			EndIf ; If ( *p\pos = *p\destination )
    			
    			Debug "Extract_Normal:                                    /* calculate amount of data we can use before we need to fill the buffer again */"
    			count = *p\destination - *p\pos
    			
    			If ( count > *p\unpack_size )
    				Debug "Extract_Normal:                                    /* take only what we need */"
    				count = *p\unpack_size
    			EndIf
    			
    			crc_calc(0, *UnLZX, count, *p\pos, 1)                   
    			Debug "Extract_Normal: Calculated CRC : " + Str( \crc ) + " :: (Sollte Sein) " + Str( \crcFile )
    			
    			If ( out_file > 0 )
    				
    				szString.s = ""
    				
    				*p\content = *p\pos       ; Kopiere Den Inhalt
    				
    				For size = 0 To count - 1
    					
    					WriteByte(out_file,*p\content\a) 
    					*p\content + 1
    				Next    
    				
    				
    				*p\unpack_size = *p\unpack_size - count
    				*p\pos         = *p\pos  + count                
    				
    				If \crc = \crcFile                         
    					Debug "Extract_Normal: CRC good"
    				Else
    					Debug "Extract_Normal: CRC bad"                                
    				EndIf
    				
    				CloseFile( out_file )
    			EndIf
    			
    		Wend  
    		
    		ProcedureReturn *p\abort
    	EndWith    
    EndProcedure
    ;
    ;
    ;           
    Procedure .i    Extract_Archive(*UnLZX.LZX_ARCHIVE)
    	
    	
    	ResetList( *UnLZX\FileData() )
    	With *UnLZX\FileData()
    		
    		While NextElement( *UnLZX\FileData() )
    			
    			FileSeek(*UnLZX\pbData, *UnLZX\FileData()\Loc, #PB_Absolute)
    			
    			Select \PackMode
    				Case 0      ;/* store */
    				Case 2	    ;/* normal */
    					Extract_Normal(*UnLZX)
    				Default     ;/* unknown */    
    			EndSelect        
    			
    		Wend    
    	EndWith
    	
    	
    EndProcedure    
    ;
    ;
    ;
    Procedure .i    View_Archive(*UnLZX.LZX_ARCHIVE)
    	
    	Protected TempPosition  = 0
    	Protected total_pack    = 0;
    	Protected total_unpack  = 0;    
    	Protected CurrentPosition  = 0;   ist die "actual" variable
    	Protected abort		      ;
    	Protected result        = 1   ; /* assume an error */        
    	
    	;Debug ("Unpacked" + Chr(9) +"  Packed" + Chr(9) + " CRC Calc " + Chr(9) + " CRC Summe " + Chr(9) +"   Time " + Chr(9) + "   Date " + Chr(9) + " Attrib " + Chr(9) + "Dir/File"  )
	;Debug ("--------" + Chr(9) +"--------" + Chr(9) + "-----------"+ Chr(9) + "-----------" + Chr(9) +"--------" + Chr(9) + "--------" + Chr(9) + "--------" + Chr(9) + "--------"  )      
    	
    	Repeat
    		
    		abort = 1; /* assume an error */            
			 ;
			 ;
    		
    		For x = 0 To 30
    			
    			*UnLZX\Archiv\c[x] = ReadAsciiCharacter(*UnLZX\pbData)
    			CurrentPosition = x+1
    		Next            
    		
    		If (CurrentPosition > 0)                                ; /* 0 is normal And means EOF */
    			
    			If (CurrentPosition = 31 )
    				
    				*UnLZX\sum = 0 ;                                /* reset CRC */  
    				
    				*UnLZX\crc = (*UnLZX\Archiv\c[29] << 24) + (*UnLZX\Archiv\c[28] << 16) + (*UnLZX\Archiv\c[27] << 8) + *UnLZX\Archiv\c[26] ; /* header crc */  
    				
    				*UnLZX\Archiv\c[29] = 0;                        /* Must set the field to 0 before calculating the crc */
    				*UnLZX\Archiv\c[28] = 0;
    				*UnLZX\Archiv\c[27] = 0;
    				*UnLZX\Archiv\c[26] = 0;                    
    				
    				crc_calc( *UnLZX\Archiv, *UnLZX, 31 )                                       
    				
    				;--------------------------------------------------------------------------------------------------------------------------------------------
				;                    
    				TempPosition= *UnLZX\Archiv\c[30] ;             /* filename length */
    				
    				If (*UnLZX\Archiv\c[30] = 0 )
    					;
					; Keine Weiteren Dateien
    					Break;
    				EndIf
    				
    				For x = 0 To TempPosition-1
    					*UnLZX\Filename\c[x] = ReadAsciiCharacter(*UnLZX\pbData)   
    					CurrentPosition = x+1
    				Next                   
    				; 
				; Dateinamen Sichern                                                 
    				
    				If ( CurrentPosition = TempPosition )
    					
    					*UnLZX\Filename\c[TempPosition] = 0;
    					
    					crc_calc(*UnLZX\Filename,  *UnLZX, TempPosition);         
    					
    					;--------------------------------------------------------------------------------------------------------------------------------------------
					;
    					TempPosition     = *UnLZX\Archiv\c[14];            /* comment length */
    					CurrentPosition  = *UnLZX\Archiv\c[14]                     
    					For x = 0 To TempPosition-1
    						*UnLZX\Comment\c[x] = ReadAsciiCharacter(*UnLZX\pbData)   
    					Next                                                                                
    					
    					If ( CurrentPosition = TempPosition )
    						
    						crc_calc(*UnLZX\Comment,  *UnLZX, TempPosition);
    						
    						If ( *UnLZX\sum = *UnLZX\crc )
    							
    							attributes.c = *UnLZX\Archiv\c[0]   ; /* file protection modes */
    							
    							unpack_size = (*UnLZX\Archiv\c[5]  << 24) + (*UnLZX\Archiv\c[4]  << 16) + (*UnLZX\Archiv\c[3]  << 8) + *UnLZX\Archiv\c[2]   ; /* unpack size */
    							pack_size   = (*UnLZX\Archiv\c[9]  << 24) + (*UnLZX\Archiv\c[8]  << 16) + (*UnLZX\Archiv\c[7]  << 8) + *UnLZX\Archiv\c[6]   ; /* packed size */
    							DatePosition= (*UnLZX\Archiv\c[18] << 24) + (*UnLZX\Archiv\c[19] << 16) + (*UnLZX\Archiv\c[20] << 8) + *UnLZX\Archiv\c[21]  ; /* date */
    							
    							
    							year        = ((DatePosition >> 17) & 63) + 1970
    							month       = ((DatePosition >> 23) & 15) + 1
    							day         =  (DatePosition >> 27) & 31
    							hour        =  (DatePosition >> 12) & 31
    							minute      =  (DatePosition >> 6) & 63
    							second      =   DatePosition & 63                                      
    							
    							*UnLZX\TotalPacked + pack_size
    							*UnLZX\TotalUnpack + unpack_size
    							*UnLZX\TotalFiles  +1             
    							*UnLZX\MergedSize  + unpack_size;                                                            
    							
    							
    							;
							; Situtation über die ausgelsenen Dateien
							;Debug RSet(Get_Unpack(unpack_size),8,Chr(32))                     + Chr(9) + 
							;      RSet(Get_Packed(pack_size,*UnLZX\Archiv\c[12]),8,Chr(32))   + Chr(9) +
							;      RSet( Str(*UnLZX\sum),10," ")                               + Chr(9) +
							;      RSet( Str(*UnLZX\crc),10," ")                               + Chr(9) +                                      
							;      Get_Clock  (hour,minute,second)                             + Chr(9) +
							;      Get_Date   (day,month,year)                                 + Chr(9) +
							;      Deb_Attrib (attributes)                                     + Chr(9) +
							;      Get_File   (*UnLZX)                                         + Chr(9) + Chr(9) + Get_Comment(*UnLZX)
    							
    							
    							;
							;
							; Sammle Infos
    							AddElement( *UnLZX\FileData() )
    							With *UnLZX\FileData()
    								
    								\loc         = Loc(*UnLZX\pbData)
    								\Count      = *UnLZX\TotalFiles
    								\File       =  Get_File (*UnLZX)
    								\Comment    =  Get_Comment(*UnLZX)
    								\PackMode   = *UnLZX\Archiv\c[11]; /* pack mode */
    								\crc        = *UnLZX\crc
    								\crcSum     = *UnLZX\sum
    								\crcFile    = (*UnLZX\Archiv\c[25] << 24) + (*UnLZX\Archiv\c[24] << 16) + (*UnLZX\Archiv\c[23] << 8) + *UnLZX\Archiv\c[22]; /* data crc */
    								
    								\DateY = year
    								\DateM = month
    								\DateD = day
    								\TimeH = hour
    								\TimeM = minute
    								\TimeS = second
    								
    								\SizePacked = pack_size
    								\PackedByte = *UnLZX\Archiv\c[12]
    								\SizeUnpack = unpack_size
    								
    								Get_Attrib (*UnLZX, attributes)
    								
    								\isMerged   = #False
    								
    								\ErrorMessage = ""
    							EndWith 
    							
    							
    							;
							; Dateien ''merged
    							If   (*UnLZX\Archiv\c[12] & 1) And ( pack_size > 0)                        
    								;Debug RSet(Str(*UnLZX\MergedSize),8,Chr(32)) + Chr(9) + RSet(Get_Packed(pack_size,LogicalAnd( (*UnLZX\Archiv\c[12] & 1) , pack_size)),8,Chr(32))  + Chr(9) + "Merged"
    								
    								AddElement( *UnLZX\FileData() )
    								With *UnLZX\FileData()
    									\MergedSize = *UnLZX\MergedSize
    									\SizePacked = Val( Get_Packed(pack_size,LogicalAnd( (*UnLZX\Archiv\c[12] & 1) , pack_size)))
    									\isMerged   = #True
    								EndWith
    							EndIf
    							
    							
    							If ( pack_size > 0); /* seek past the packed Data */ 
    								*UnLZX\MergedSize = 0 ;
    								
    								FileSeek(*UnLZX\pbData, pack_size, #PB_Relative) 
    								*UnLZX\FileData()\SeekPosition = Loc(*UnLZX\pbData)
    								Debug "Position: " + Str(*UnLZX\FileData()\SeekPosition)
    							EndIf                   
    						Else
    							
    							*UnLZX\crc = 0
    							*UnLZX\sum = 0
    							AddElement( *UnLZX\FileData() )
    							With *UnLZX\FileData()
    								\Count          = \Count +1
    								\ErrorMessage   = "CRC Mismatch / Archiv Corrupt"                                 
    							EndWith
    							
    							;Debug "... CRC Mismatch/ Archiv Corrupt"
							;Debug "CRC: Archive_Header ... CRC Mismatch/ Archiv Corrupt"
							;Debug "CRC Table: " + Str(*UnLZX\sum) + ":: CRC *UnLZX\Archiv: "+ Str(*UnLZX\crc) + "Archiv Damaged"                               
    							Break
    						EndIf
    						
    						abort = 0
    					Else
    						;Debug "End Of File: Header_Comment"
    					EndIf
    				Else
    					;Debug "End Of File: Header_Filename"
					;Break                
    				EndIf 
    			Else    
    				;Debug "End Of File: Archive_Header"
    			EndIf
    			;Else
			;    Break
    		EndIf                        
    		;result = 0; /* normal termination */                
    		
    	Until (abort = 1)
    	
    	;If ( *UnLZX\TotalFiles > 0 )
	;Debug ("--------" + Chr(9) +"--------" + Chr(9) + "-----------"+ Chr(9) + "-----------" + Chr(9) +"--------" + Chr(9) + "--------" + Chr(9) + "--------" + Chr(9) + "--------"  )
	;Debug RSet( Str( *UnLZX\TotalUnpack),8, " ") + Chr(9) + RSet( Str(*UnLZX\TotalPacked),8, " ") + Chr(9) + " File(s): " + Str(*UnLZX\TotalFiles)               
	;EndIf    

    EndProcedure    
    ;
    ;
    ;
    Procedure  .i   Process_Header(*UnLZX.LZX_ARCHIVE)
        
        Protected FilePosition.i
        
        For FilePosition = 0 To 9
            *UnLZX\Header\c[FilePosition] = ReadAsciiCharacter(*UnLZX\pbData)                             
        Next                         
        
        
       If ( (*UnLZX\Header\c[0] = 76) And (*UnLZX\Header\c[1] = 90) And (*UnLZX\Header\c[2] = 88) )   ; /* LZX */           
           
           
           Debug "Process_Header() : LZX gefunden"
           Debug ""
           ProcedureReturn #True
       EndIf        
       
       ProcedureReturn #False
        
   EndProcedure 
    ;
    ;   
    ;
    Procedure  .s   Files_CountDesc(TotalFiles.i)
        
        If ( TotalFiles = 1 )
            ProcedureReturn ""
        EndIf
        ProcedureReturn "s"
       
    EndProcedure   
    ;
    ;
    ;   
    Procedure .i    Debug_View_Archiv( *UnLZX.LZX_ARCHIVE )
       
       Protected szSizeUnpack.s, szSizePacked.s, szCRCCalc.s, szCRCSumme.s, szFileTime.s, szFileDate.s, szFileAttrib.s, szFileName.s, szMergedSize.s, szComment.s, FileNummer.s
       
            Debug "Nr " + "Unpacked" + Chr(9) +"  Packed" + Chr(9) + " CRC Calc " + Chr(9) + " CRC Summe " + Chr(9) +"   Time " + Chr(9) + "   Date " + Chr(9) + " Attrib " + Chr(9) + "Dir/File"
            Debug "---" + "--------" + Chr(9) +"--------" + Chr(9) + "-----------"+ Chr(9) + "-----------" + Chr(9) +"--------" + Chr(9) + "--------" + Chr(9) + "--------" + Chr(9) + "------------------------------------------------"
        
            ResetList( *UnLZX\FileData() )
            With *UnLZX\FileData()
                
                While NextElement( *UnLZX\FileData() )
                    
                    If ( Len(\ErrorMessage) > 0 )
                        Debug \ErrorMessage
                        Continue
                    EndIf
                    
                    If ( \isMerged   = #True )
                        FileNummer   = "  "
                        szMergedSize = RSet( Str( \MergedSize ) ,8, Chr(32) )
                        szSizePacked = RSet( Str( \SizePacked ) ,8, Chr(32) )
                        Debug FileNummer + szMergedSize + Chr(9) + szSizePacked + Chr(9) + "Merged"
                        Continue
                    Else    
                        
                        FileNummer   =  RSet( Str( \Count ), 2, " ")
                        szSizeUnpack =  RSet( Get_Unpack( \SizeUnpack ), 8, Chr(32) ) 
                        szSizePacked =  RSet( Get_Packed( \SizePacked, \PackedByte ),8, Chr(32) )
                        szCRCCalc    =  RSet( Str( \crc    ),10, " ")
                        szCRCSumme   =  RSet( Str( \crcSum ),10, " ")                     
                        szFileTime   =  Get_Clock  (\TimeH, \TimeM ,\TimeS)
                        szFileDate   =  Get_Date   (\DateD, \DateM ,\DateY)
                        szFileAttrib =  \AttribH + \AttribS + \AttribP + \AttribA + \AttribR + \AttribW + \AttribE + \AttribD
                        szFileName   = \File 
                        szComment    = \Comment
                                                
                        Debug FileNummer + szSizeUnpack + Chr(9) + szSizePacked+ Chr(9) + szCRCCalc + Chr(9) + szCRCSumme + Chr(9) + szFileTime + Chr(9) + szFileDate + Chr(9) +  szFileAttrib + Chr(9) + szFileName
                        
                        If ( Len(szComment) > 0 )
                            Debug "Comment: "+ szComment
                        EndIf                         
                   EndIf                    
               Wend
               
           EndWith
           
          Debug ("--------" + Chr(9) +"--------" + Chr(9) + "-----------"+ Chr(9) + "-----------" + Chr(9) +"--------" + Chr(9) + "--------" + Chr(9) + "--------" + Chr(9) + "------------------------------------------------" )
          Debug RSet( Str( *UnLZX\TotalUnpack),8, " ") + Chr(9) + RSet( Str(*UnLZX\TotalPacked),8, " ") + Chr(9) + " File"+ Files_CountDesc(*UnLZX\TotalFiles) + ": " + Str(*UnLZX\TotalFiles)      
          
                
          Debug ""
          Debug "File: " + *UnLZX\Full
          Debug "Size: " + *UnLZX\Size            
      EndProcedure  
    ;
    ;
    ;
    Procedure .i  Close_Archive( *UnLZX.LZX_ARCHIVE )
        
        If ( *UnLZX > 0 )           
            
            If ( *UnLZX\pbData > 0 )  
                CloseFile( *UnLZX\pbData )
            EndIf
            
            ClearList( *UnLZX\FileData() )
            ClearStructure(*UnLZX, LZX_ARCHIVE)
            FreeMemory(*UnLZX)
        EndIf    
        ProcedureReturn *UnLZX                 
          
    EndProcedure
    ;
    ;
    ;
    Procedure .i  Examine_Archive( *UnLZX.LZX_ARCHIVE )
        
        If ( *UnLZX > 0 )           
            Debug_View_Archiv(*UnLZX)
        EndIf
          
    EndProcedure        
    ;
    ;
    ;
    Procedure .i    Process_Archive(File.s)
                
        If ( FileSize( File ) > 0 )
                        
            *UnLZX.LZX_ARCHIVE  = AllocateMemory(SizeOf(LZX_ARCHIVE))
            InitializeStructure(*UnLZX, LZX_ARCHIVE)
           
            *UnLZX\Size         = FileSize( File )
            *UnLZX\Full         = File
            *UnLZX\Path         = GetPathPart( File  )
            *UnLZX\File         = GetFilePart( File , #PB_FileSystem_NoExtension)
            
            *UnLZX\TotalFiles   = 0
            *UnLZX\Header       = AllocateMemory(  10 *2) ; Keine Ahnung ... "
            *UnLZX\Archiv       = AllocateMemory(  31 *2) ; ... sonst gibt es eine 
            *UnLZX\Filename     = AllocateMemory( 256 *2) ; ... "Overflow in a Dynamically Alloceated Block"
            *UnLZX\Comment      = AllocateMemory( 256 *2) ; ...  und bei einem Korrupten Archiv crasht Freememory()
            
            *UnLZX\pbData       = ReadFile( #PB_Any,  *UnLZX\Full )
            
            NewList  *UnLZX\FileData()
            If ( Process_Header(*UnLZX.LZX_ARCHIVE) = #True )
                
                View_Archive(*UnLZX.LZX_ARCHIVE) 
                
                ProcedureReturn *UnLZX                             
            EndIf  
        EndIf          
                
    EndProcedure
    
    
EndModule

CompilerIf #PB_Compiler_IsMainFile
    EnableExplicit
    
    Debug "UnLzx Purebasic Module v0.2 based on Amiga PowerPC Elf UnLZX 1.0 (22.2.98)"
    Debug "Convertet by Martin Schäfer"
    Debug ""
    
    
    Define File.s, Pattern.s, *LzxMemory
    
    Pattern = "LZX (*.lzx)|*.lzx|Alle Dateien (*.*)|*.*"
        
    File = OpenFileRequester("LZX Tester","",Pattern,0)
    If ( File )  
        ;
        ; Lzx File Öffne und Inbtialisieren
        *LzxMemory = PackLZX::Process_Archive(File)
        
        ;
        ; Archive Auflisten
        PackLZX::Examine_Archive(*LzxMemory)
        
        ;
        ;
        PackLZX::Extract_Archive(*LzxMemory)
        
        ;
        ; Free File and Free Memory
        *LzxMemory = PackLZX::Close_Archive(*LzxMemory)
    EndIf
    
    
    
    
CompilerEndIf    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 350
; FirstLine = 292
; Folding = -Fonz-jB+
; EnableAsm
; EnableXP
; Compiler = PureBasic 5.73 LTS (Windows - x64)
; EnablePurifier