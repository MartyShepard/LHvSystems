DeclareModule UnLZX
	
	Declare.i   Process_Archive(File.s)             			 ; Init and Open Lzx File
	Declare.i   Examine_Archive(*LzxMemory)					 ; List Content
	
	Declare.i   Extract_Archive(*LzxMemory,	szTarget.s	  ="",	 ; Extract to Targe Directory
	                           			szFilename.s  ="",	 ; Extract File Only by Name
	                            			DecrunchNum.i = -1)	 ; Extract File Only by Position
	
	Declare.i	Verify_Archive(*LzxMemory,    szFilename.s = "",	 ; Verify Check File by Name
								DeCrunchNum.i = -1)	 ; Verify Check File by Position
	
	Declare.i   ListSize_Archive(*UnLZX)
	Declare.s	About_UnLZX()
	Declare.i   Close_Archive(*LzxMemory)					 ; Close Archive and Free    
		
	
	;
	; User Liste
	Structure LZX_CONTENT
		IndexID.i
		FileNum.i
		PathFile.s
		Attributes.s
		szFileDate.s
		szFileTime.s
		SizePacked.s
		SizeUnpack.s
		CRC.s
		szComment.s
		isMerge.i
		MergedUnpack.i
		MergedPacked.i
		MergedEnName.s		
	EndStructure 
  
	Global NewList User_LZX_List.LZX_CONTENT()  
	
	
EndDeclareModule


Module UnLZX 
	
	; Original Text by David Tritcher
	;
	;
	; /* $VER: unlzx.c 1.0 (22.2.98) */
	; /* Created: 11.2.98 */
	
	; /* LZX Extract in (supposedly) portable C.                                */
	;
	; /* Compile With:                                                          */
	; /* gcc unlzx.c -ounlzx -O2                                                */
	;
	; /* Thanks To Dan Fraser For decoding the coredumps And helping me track   */
	; /* down some HIDEOUSLY ANNOYING bugs.                                     */
	;
	; /* Everything is accessed As unsigned char's to try and avoid problems    */
	; /* With byte order And alignment. Most of the decrunch functions          */
	; /* encourage overruns IN the buffers To make things As fast As possible.  */
	; /* All the time is taken up IN crc_calc() And decrunch() so they are      */
	; /* pretty damn optimized. Don't try to understand this program.           */
	;
	;
	; Purebasic C Conversion Code
	; Compiled and Testet with 5.73+ LTS 64Bit. Thanks to Infratec 
	
	
	Structure AsciiArray
		a.a[0]
	EndStructure
		
	Structure UnicodeArray
		u.u[0]
	EndStructure
	
	Structure LongArray
		l.l[0]
	EndStructure 
	
	Structure LZX_FILEDATA
		Count.i                 ; Aktulle Datei Nummer
		File.s			; Der DateiName
		Comment.s
		PackMode.a              ; Packmodus
    		attributes.a
    		TimeDate.i       
		crc.l                   ; crc Archive Header
		sum.l				; crc summe
		crcFile.l			; Data CRC für die Datei (Siehe Extract Normal)        
		TotalFiles.i		; WieViele Dateien        
		SizePacked.i        
		SizeUnpack.i
		PackedByte.b
		MergedSize.i
		SeekPosition.i
		isMerged.i
		ErrorMessage.s
		loc.i
		NewLocPos.q
	EndStructure     
	
	Structure LZX_DIRECTORY
		PathFile.s
		Position.i
	EndStructure
	
	Structure LZX_ARCHIVE
		Path.s
		File.s
		Full.s
		TargetDirectory.s
		Size.q
		Dest.s
		pbData.l
		sum.l                			; ist die Globale Varibale sum und nutzt "variable temp" in crc_calc      
		crc.l			   			; Abgleich und Vergleich
		TotalFiles.i
		TotalPacked.i        
		TotalUnpack.i
		MergedSize.i
		FileError.i
		ExtractAll.i
		ExtractPos.i
		crcCountGood.i
		crcCountBad.i
		crcCountNull.i
		FileExtracted.i
		Verify.i
		info_header.a[10]				; unsigned char info_header[10];
		archiv_header.a[31]			; unsigned char archive_header[31];
		header_filename.a[256]			; unsigned char header_filename[256];
		header_comment.a[256]			; unsigned char header_comment[256];
		List FileData.LZX_FILEDATA()
		List ListData.LZX_DIRECTORY()        
	EndStructure    

	Structure LZX_DECODE
		*bit_num.ascii                  	; register unsigned char bit_num = 0;
		*symbol.Integer			  	; register int symbol;
		leaf.i				  	; unsigned int leaf; /* could be a register */
		table_mask.i
		bit_mask.i
		pos.i
		fill.i
		next_symbol.i
		reverse.i
		abort.i
	EndStructure 	
	
	Structure LZX_LITERAL
		abort.i        
		*control.Integer        
		count.i                  		; unsigned int count;
		*content.ascii				; unsigned char copy from *pos for file saving;        
		decrunch_length.i				; unsigned int decrunch_length;        
		decrunch_method.i				; unsigned int decrunch_method;       
		*destination.ascii			; unsigned char *destination;
		*destination_end.ascii			; unsigned char *destination_end;  
		last_offset.i				; unsigned int last_offset;        
    		global_control.i        		; unsigned int global_control
    		global_shift.i          		; global_shift
		pack_size.i      
		*pos.ascii                      	; unsigned char *pos;
		shift.i        
		*source.ascii                   	; unsigned char *source;
		*source_end.ascii				; unsigned char *source_end;
		*symbol.integer
		*temp.ascii                     	; unsigned char *temp;
		unpack_size.i
		offset_len.a[8]         		; unsigned char offset_len[8]
		offset_table.u[128]			; unsigned short offset_table[128]
		huffman20_len.a[20]			; unsigned char huffman20_len[20]
		huffman20_table.u[96]			; unsigned short huffman20_table[96]
		literal_len.a[768]			; unsigned char literal_len[768]
		literal_table.u[5120]			; unsigned short literal_table[5120]
		*read_buffer.ascii			; AllocateMemory(16384)
		*Decrunch_Buffer.ascii			; AllocateMemory(258 + 65536 + 258)
	EndStructure 
	
	
	DataSection
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; static const unsigned int crc_table[256]=
		;
		CRC_TABLE:
		Data.l $00000000,$77073096,$EE0E612C,$990951BA,$076DC419,$706AF48F
		Data.l $E963A535,$9E6495A3,$0EDB8832,$79DCB8A4,$E0D5E91E,$97D2D988
		Data.l $09B64C2B,$7EB17CBD,$E7B82D07,$90BF1D91,$1DB71064,$6AB020F2
		Data.l $F3B97148,$84BE41DE,$1ADAD47D,$6DDDE4EB,$F4D4B551,$83D385C7
		Data.l $136C9856,$646BA8C0,$FD62F97A,$8A65C9EC,$14015C4F,$63066CD9
		Data.l $FA0F3D63,$8D080DF5,$3B6E20C8,$4C69105E,$D56041E4,$A2677172
		Data.l $3C03E4D1,$4B04D447,$D20D85FD,$A50AB56B,$35B5A8FA,$42B2986C
		Data.l $DBBBC9D6,$ACBCF940,$32D86CE3,$45DF5C75,$DCD60DCF,$ABD13D59
		Data.l $26D930AC,$51DE003A,$C8D75180,$BFD06116,$21B4F4B5,$56B3C423
		Data.l $CFBA9599,$B8BDA50F,$2802B89E,$5F058808,$C60CD9B2,$B10BE924
		Data.l $2F6F7C87,$58684C11,$C1611DAB,$B6662D3D,$76DC4190,$01DB7106
		Data.l $98D220BC,$EFD5102A,$71B18589,$06B6B51F,$9FBFE4A5,$E8B8D433
		Data.l $7807C9A2,$0F00F934,$9609A88E,$E10E9818,$7F6A0DBB,$086D3D2D
		Data.l $91646C97,$E6635C01,$6B6B51F4,$1C6C6162,$856530D8,$F262004E
		Data.l $6C0695ED,$1B01A57B,$8208F4C1,$F50FC457,$65B0D9C6,$12B7E950
		Data.l $8BBEB8EA,$FCB9887C,$62DD1DDF,$15DA2D49,$8CD37CF3,$FBD44C65
		Data.l $4DB26158,$3AB551CE,$A3BC0074,$D4BB30E2,$4ADFA541,$3DD895D7
		Data.l $A4D1C46D,$D3D6F4FB,$4369E96A,$346ED9FC,$AD678846,$DA60B8D0
		Data.l $44042D73,$33031DE5,$AA0A4C5F,$DD0D7CC9,$5005713C,$270241AA
		Data.l $BE0B1010,$C90C2086,$5768B525,$206F85B3,$B966D409,$CE61E49F
		Data.l $5EDEF90E,$29D9C998,$B0D09822,$C7D7A8B4,$59B33D17,$2EB40D81
		Data.l $B7BD5C3B,$C0BA6CAD,$EDB88320,$9ABFB3B6,$03B6E20C,$74B1D29A
		Data.l $EAD54739,$9DD277AF,$04DB2615,$73DC1683,$E3630B12,$94643B84
		Data.l $0D6D6A3E,$7A6A5AA8,$E40ECF0B,$9309FF9D,$0A00AE27,$7D079EB1
		Data.l $F00F9344,$8708A3D2,$1E01F268,$6906C2FE,$F762575D,$806567CB
		Data.l $196C3671,$6E6B06E7,$FED41B76,$89D32BE0,$10DA7A5A,$67DD4ACC
		Data.l $F9B9DF6F,$8EBEEFF9,$17B7BE43,$60B08ED5,$D6D6A3E8,$A1D1937E
		Data.l $38D8C2C4,$4FDFF252,$D1BB67F1,$A6BC5767,$3FB506DD,$48B2364B
		Data.l $D80D2BDA,$AF0A1B4C,$36034AF6,$41047A60,$DF60EFC3,$A867DF55
		Data.l $316E8EEF,$4669BE79,$CB61B38C,$BC66831A,$256FD2A0,$5268E236
		Data.l $CC0C7795,$BB0B4703,$220216B9,$5505262F,$C5BA3BBE,$B2BD0B28
		Data.l $2BB45A92,$5CB36A04,$C2D7FFA7,$B5D0CF31,$2CD99E8B,$5BDEAE1D
		Data.l $9B64C2B0,$EC63F226,$756AA39C,$026D930A,$9C0906A9,$EB0E363F
		Data.l $72076785,$05005713,$95BF4A82,$E2B87A14,$7BB12BAE,$0CB61B38
		Data.l $92D28E9B,$E5D5BE0D,$7CDCEFB7,$0BDBDF21,$86D3D2D4,$F1D4E242
		Data.l $68DDB3F8,$1FDA836E,$81BE16CD,$F6B9265B,$6FB077E1,$18B74777
		Data.l $88085AE6,$FF0F6A70,$66063BCA,$11010B5C,$8F659EFF,$F862AE69
		Data.l $616BFFD3,$166CCF45,$A00AE278,$D70DD2EE,$4E048354,$3903B3C2
		Data.l $A7672661,$D06016F7,$4969474D,$3E6E77DB,$AED16A4A,$D9D65ADC
		Data.l $40DF0B66,$37D83BF0,$A9BCAE53,$DEBB9EC5,$47B2CF7F,$30B5FFE9
		Data.l $BDBDF21C,$CABAC28A,$53B39330,$24B4A3A6,$BAD03605,$CDD70693
		Data.l $54DE5729,$23D967BF,$B3667A2E,$C4614AB8,$5D681B02,$2A6F2B94
		Data.l $B40BBE37,$C30C8EA1,$5A05DF1B,$2D02EF8D
	EndDataSection
	
	DataSection
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; static const unsigned char table_one[32]=
		;		
		TABLE_ONE:
		Data.a   0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14
	EndDataSection 
	
	DataSection
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; static const unsigned int table_two[32]=
		;			
		TABLE_TWO:
		Data.u  0,1,2,3,4,6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024
		Data.u 1536,2048,3072,4096,6144,8192,12288,16384,24576,32768,49152
	EndDataSection 
	
	DataSection
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; static const unsigned int table_three[16]=
		;		
		TABLE_THREE:
		Data.u 0,1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383,32767
	EndDataSection        
	
	DataSection
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; static const unsigned char table_four[34]=
		;			
		TABLE_FOUR:
		Data.a 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
		Data.a 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
	EndDataSection 
	;
	;
	;
	; --------------------------------------
	; C -> PB Konvertierung Logical AND (&&)
	;
	Procedure LogicalAND(a,b)           
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
	;
	;
	;
	Procedure.s Version()
		Protected.s szString
		
		szString = "$VER: UnLZX Purebasic Module v0.7"
		
		ProcedureReturn szString
	EndProcedure
	;
	;
	;	
	Procedure.s About_UnLZX()
		 	
		Protected.s szString
		szString = Version() + #CRLF$
		szString + "      Based on Amiga PowerPC Elf UnLZX 1.0 (22.2.98)" + #CR$
		szString + "      Port by David Tritscher <dt14 at uow.edu.au>" + #CRLF$
		szString + "Convertet to Purebasic Nativ by Infratec & Marty2pb"
		
		ProcedureReturn szString

	EndProcedure	
	;
	;
	;
	; Modus: 0 - Berechne die CRC für das gesamte Archiv
	; Modus: 1 - Nur für die jeweilge Datei
	;    
	; * Build a fast huffman decode table from the symbol bit lengths.         *
	; * There is an alternate algorithm which is faster but also more complex. *
	Procedure 	   crc_calc(*Memory.AsciiArray, *UnLZX.LZX_ARCHIVE, length.i, *FileCalc.ascii = #Null, Modus.i = 0)
		
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; register unsigned int temp;
		;		
		Protected *mem.Ascii, temp.q, *crc_table.LongArray
		
		
		Select Modus
			Case 0
				*mem = *Memory
			Case 1
				*mem = *FileCalc
		EndSelect
		
		*crc_table = ?CRC_TABLE
		
		If length > 0
			
			; --------------------------------------
			; C -> PB Konvertierung
			;
			;  temp = ~sum
			;				
			Select Modus
				Case 0
					temp = ~*UnLZX\sum  ; was (sum ^ 4294967295)
				Case 1
					temp = ~*UnLZX\FileData()\sum
			EndSelect
			
			; --------------------------------------
			; C -> PB Konvertierung
			;
			;  do
 			;  {
			; 
			;   temp = crc_table[(*memory++ ^ temp) & 255] ^ (temp >> 8);
			;
			;  } While(--length);
			;			
			Repeat				
				temp = *crc_table\l[(*mem\a ! temp) & 255] ! ((temp & $FFFFFFFF) >> 8)
				*mem + 1
				Length - 1
			Until Length = 0
			
			Select Modus
				Case 0            
					*UnLZX\sum = ~temp & $FFFFFFFF  ; was (temp ^ 4294967295)
				Case 1       
					*UnLZX\FileData()\sum = ~temp & $FFFFFFFF ; was (temp ^ 4294967295)
			EndSelect
			
		EndIf		
		
	EndProcedure
	;
	;
	;
	Procedure .s  Get_Unpack(size.i)
		
		Protected result.s
		
		
		If size = 0
			result = "n/a"
		Else
			result = Str(size)
		EndIf
		
		ProcedureReturn result
		
	EndProcedure    
	;
	;
	;
	Procedure .s  Get_Packed(size.i,c.b)
		
		Protected result.s
		
		
		If c & 1
			result = "n/a"
		Else
			result = Str(size)
		EndIf
		
		ProcedureReturn result
		
	EndProcedure    
	;
	;
	;
	Procedure .s  Get_Clock(TimeDate.i)
		
		ProcedureReturn FormatDate("%hh:%ii:%ss", TimeDate)
		
	EndProcedure
	;
	;
	;
	Procedure.s   Get_Date(TimeDate.i)
		
		ProcedureReturn FormatDate("%dd-%mm-%yyyy", TimeDate)
		
	EndProcedure
	;
	;
	;
	Procedure.s   Get_Attrib(attributes.a)
		
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; printf("%c%c%c%c%c%c%c%c ",
            ; (attributes & 32)  ? 'h' : '-',
            ; (attributes & 64)  ? 's' : '-',
            ; (attributes & 128) ? 'p' : '-',
            ; (attributes & 16)  ? 'a' : '-',
            ; (attributes & 1)   ? 'r' : '-',
            ; (attributes & 2)   ? 'w' : '-',
            ; (attributes & 8)   ? 'e' : '-',
		; (attributes & 4)   ? 'd' : '-');
		; --------------------------------------		
		Protected Attributes$
		
		
		Attributes$ = "--------"
		
		If attributes & 32
			ReplaceString(Attributes$, "-", "h", #PB_String_InPlace, 1, 1)
		EndIf
		
		If attributes & 64
			ReplaceString(Attributes$, "-", "s", #PB_String_InPlace, 2, 1)
		EndIf
		
		If attributes & 128
			ReplaceString(Attributes$, "-", "p", #PB_String_InPlace, 3, 1)
		EndIf
		
		If attributes & 16
			ReplaceString(Attributes$, "-", "a", #PB_String_InPlace, 4, 1)
		EndIf
		
		If attributes & 1
			ReplaceString(Attributes$, "-", "r", #PB_String_InPlace, 5, 1)
		EndIf
		
		If attributes & 2
			ReplaceString(Attributes$, "-", "w", #PB_String_InPlace, 6, 1)
		EndIf
		
		If attributes & 8
			ReplaceString(Attributes$, "-", "e", #PB_String_InPlace, 7, 1)
		EndIf
		
		If attributes & 4
			ReplaceString(Attributes$, "-", "d", #PB_String_InPlace, 8, 1)
		EndIf
		
		ProcedureReturn Attributes$
		
	EndProcedure      
	;
	;
	;
	Procedure.s   Get_File(*UnLZX.LZX_ARCHIVE)
		
		ProcedureReturn PeekS(@*UnLZX\header_filename[0], -1, #PB_Ascii)
		
	EndProcedure
	;
	;
	;
	Procedure .s  Get_Comment(*UnLZX.LZX_ARCHIVE)
		
		Protected  szComment.s = ""
		
		szComment = PeekS(@*UnLZX\header_comment[0], -1, #PB_Ascii)          
		
		ProcedureReturn szComment
		
	EndProcedure 
	;
	;
	;
	Procedure.i   Make_decode_table(number_symbols.i, table_size.i, *length.AsciiArray, *table.UnicodeArray)
		
		Protected.i bit_num, symbol, leaf
		Protected.i table_mask, bit_mask, pos, fill, next_symbol, reverse, abort
		
		
		table_mask = 1 << table_size
		bit_mask = table_mask
		
		bit_mask >> 1 ; don't do the first number
		bit_num + 1
		
		While abort = 0 And bit_num <= table_size
			
			For symbol = 0 To number_symbols - 1
				If *length\a[symbol] = bit_num
					
					;Debug "reverse the order of the position's bits"
					reverse = pos
					
					leaf = 0
					fill = table_size
					
					;Debug "reverse the position"
					Repeat
						leaf = (leaf << 1) + (reverse & 1)
						reverse >> 1
						fill - 1
					Until fill = 0
					
					pos + bit_mask
					If pos > table_mask
						Debug "ERROR: we will overrun the table abort!" + " pos: " + Str(pos) + " table_mask: " + Str(table_mask)
						abort = 1
						Break
					EndIf
					
					fill = bit_mask
					next_symbol = 1 << bit_num
					
					Repeat
						*table\u[leaf] = symbol
						leaf + next_symbol
						fill - 1
					Until fill = 0
					
				EndIf
			Next symbol
			
			bit_mask >> 1
			bit_num + 1
		Wend
		
		
		If abort = 0 And pos <> table_mask
			
			For symbol = pos To table_mask - 1        ; clear the rest of the table
				
				;Debug "reverse the order of the position's bits"
				reverse = symbol
				leaf = 0
				fill = table_size
				
				;Debug "reverse the position"
				Repeat
					leaf = (leaf << 1) + (reverse & 1)
					reverse >> 1
					fill - 1
				Until fill = 0
				
				*table\u[leaf] = 0
				
			Next symbol
			
			next_symbol = table_mask >> 1
			pos << 16
			table_mask << 16
			bit_mask = 32768
			
			
			While abort = 0 And bit_num <= 16
				
				For symbol = 0 To number_symbols - 1
					
					If *length\a[symbol] = bit_num
						
						;Debug "reverse the order of the position's bits"
						reverse = pos >> 16
						
						leaf = 0
						fill = table_size
						
						;Debug "reverse the position"
						Repeat
							leaf = (leaf << 1) + (reverse & 1)
							reverse >> 1
							fill - 1
						Until fill = 0
						
						For fill = 0 To bit_num - table_size - 1
							
							If *table\u[leaf] = 0
								*table\u[(next_symbol << 1)] = 0
								*table\u[(next_symbol << 1) + 1] = 0
								*table\u[leaf] = next_symbol
								next_symbol + 1
							EndIf
							
							leaf = *table\u[leaf] << 1
							leaf + (pos >> (15 - fill)) & 1
							
						Next fill
						
						*table\u[leaf] = symbol
						
						pos + bit_mask
						If pos > table_mask
							Debug "ERROR: we will overrun the table abort!"
							abort = 1
							Break
						EndIf
						
					EndIf
				Next symbol
				
				bit_mask >> 1
				bit_num + 1
			Wend
			
		EndIf
		
		If pos <> table_mask
			Debug  "ERROR: the table is incomplete!"
			abort = 1
		EndIf
		
		ProcedureReturn abort
    
	EndProcedure    
	;
	;
	;
	Macro MacroLiteralShift_16_8
		; --------------------------------------
		; C -> PB Konvertierung
		;
		; shift += 16;
            ; control += *source++ << (8 + shift);
		; control += *source++ << shift;
		; --------------------------------------
		shift + 16
		
		control + (*p\source\a << (8 + shift))
		*p\source + 1
		control + (*p\source\a << shift)
		*p\source + 1
		control & $FFFFFFFF
	EndMacro
	;
	;
	;
	Macro MacroLiteralShift_16_24
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ; shift += 16;
            ; control += *source++ << 24;
            ; control += *source++ << 16;	
		; --------------------------------------		
		shift + 16
		
		control + (*p\source\a << 24)
		*p\source + 1
		control + (*p\source\a << 16)
		*p\source + 1
		control & $FFFFFFFF
	EndMacro 
	;
	;
	;  Read and build the decrunch tables. There better be enough data in the 
	;  source buffer or it's stuffed.
	;
	Procedure.i   Read_Literal_Table(*p.LZX_LITERAL)  
		
		; --------------------------------------
		; C -> PB Konvertierung
		;			
		; register unsigned int control;
		; register int shift;
		; unsigned int symbol, pos, count, fix, max_symbol;
		; --------------------------------------
		
		Protected *Table_Three.UnicodeArray
		Protected *Table_Four.AsciiArray
		Protected.i temp, pos, count, fix, max_symbol, symbol, shift, abort
		Protected.q control
			
		*Table_Three = ?TABLE_THREE
		*Table_Four  = ?TABLE_FOUR
		
		control  = *p\global_control
		shift    = *p\global_shift
		
		;Debug "fix the control word If necessary"
		If shift < 0
			MacroLiteralShift_16_8
		EndIf
		
		;Debug "Read the decrunch method"
		*p\decrunch_method = control & 7
		control >> 3
		
		shift - 3
		If shift < 0
			MacroLiteralShift_16_8
		EndIf
		
		;Debug "Read And build the offset huffman table"
		If abort = 0 And *p\decrunch_method = 3
			
			; --------------------------------------
			; C -> PB Konvertierung
			;						
			; for(temp = 0; temp < 8; temp++)
			; --------------------------------------			
			For temp = 0 To 7
				
				*p\offset_len[temp] = control & 7
				control >> 3
				
				;Debug "Offset = " + RSet( Str( *p\OffsetLen\c[temp] ),2,"0") +  " - Char:" + Chr(*p\OffsetLen\c[temp]) + ": Control: " + Str( *p\control ) + ": Shift: " + Str( *p\shift )
				
				shift - 3
				If shift < 0
					MacroLiteralShift_16_8
				EndIf
				
			Next temp
			
			abort = Make_decode_table(8, 7, @*p\offset_len[0], @*p\offset_table[0])
			If ( abort = 1 )
				Debug "ERROR: Decode Table Offset"
			EndIf	
			
		EndIf
		
		;Debug "Read decrunch length"
		
		If abort = 0
			
			*p\decrunch_length = (control & 255) << 16
			control >> 8
			
			shift - 8
			If shift < 0
				MacroLiteralShift_16_8
			EndIf
			
			;  Debug " Control: " + Str( *p\control ) + ": Shift: " + Str( *p\shift )
			
			*p\decrunch_length + ((control & 255) << 8)
			control >> 8
			
			shift - 8
			If shift < 0
				MacroLiteralShift_16_8
			EndIf
			; Debug " Control: " + Str( *p\control ) + ": Shift: " + Str( *p\shift )
			
			*p\decrunch_length + (control & 255)
			control >> 8
			
			shift - 8
			If shift < 0
				MacroLiteralShift_16_8
			EndIf
			;Debug " Control: " + Str( *p\control ) + ": Shift: " + Str( *p\shift )
			
		EndIf
		
		;Debug "Read And build the huffman literal table"
		
		; --------------------------------------
		; C -> PB Konvertierung					
		;
		; if((!abort) && (decrunch_method != 1))
		; {];
		; --------------------------------------			
		If abort = 0 And *p\decrunch_method <> 1
			
			pos = 0
			fix = 1
			max_symbol = 256
			
			; --------------------------------------
			; C -> PB Konvertierung					
			;
			; do
			; {					
			; } while(max_symbol == 768);
			; --------------------------------------			
			Repeat
				
				For temp = 0 To 19
					
					*p\huffman20_len[temp] = control & 15
					control >> 4
					
					shift - 4
					If shift < 0
						MacroLiteralShift_16_8
					EndIf
					
					;Debug "Temp: " + Str(temp) + " Control: " + Hex(control) + " Shift: " + Str(shift ) + " Huffm20 Len: " + Str(*p\huffman20_len[temp])
					
				Next temp
				
				abort = Make_decode_table(20, 6, @*p\huffman20_len[0], @*p\huffman20_table[0])
				If ( abort = 1 )
					Debug "ERROR:  Huffman Table is corrupt!"
					Break
				EndIf									
				
				; --------------------------------------
				; C -> PB Konvertierung					
				;
				; do
				; {					
				; } while(pos < max_symbol);
				; --------------------------------------				
				Repeat
					;Debug "S" + Str(shift) + " T" + Str(temp) + " C" + Hex(control)
					
					; --------------------------------------
					; C -> PB Konvertierung					
					;
					; if((symbol = huffman20_table[control & 63]) >= 20)
					; --------------------------------------
					symbol = *p\huffman20_table[control & 63]
					If symbol >= 20
						
						;Debug "symbol is longer than 6 bits"
						; --------------------------------------
						; C -> PB Konvertierung
						;						
						;  do
						;  {					
						;  } while(symbol >= 20);
						; --------------------------------------
						Repeat
							
							symbol = *p\huffman20_table[((control >> 6) & 1) + (symbol << 1)]
							
							If shift = 0
								shift - 1
								MacroLiteralShift_16_24
							Else
								shift - 1
							EndIf
							
							control >> 1
							
						Until Not symbol >= 20
						
						temp = 6
						
					Else
						
						temp = *p\huffman20_len[symbol]
						
					EndIf
					
					control >> temp
					

					; --------------------------------------
					; C -> PB Konvertierung
					;						
					;  If((shift -= temp) < 0)				
					; --------------------------------------					
					shift - temp
					If shift < 0
						MacroLiteralShift_16_8
					EndIf
					
					Select symbol
						Case 17, 18
							
							If symbol = 17
								temp = 4
								count = 3
							Else ; symbol = 18
								temp  = 6 - fix
								count = 19
							EndIf
							
							count + ((control & *Table_Three\u[temp] ) + fix)
							control >> temp
							
							shift - temp
							If shift < 0
								MacroLiteralShift_16_8
							EndIf
							
							; --------------------------------------
							; C -> PB Konvertierung
							;	
							; while((pos < max_symbol) && (count--))
							; 	literal_len[pos++] = 0;
							; --------------------------------------
							While pos < max_symbol And count <> 0
								*p\literal_len[pos] = 0
								pos + 1
								count - 1
							Wend
							
						Case 19
							count = (control & 1) + 3 + fix
							
							If shift = 0
								shift - 1
								MacroLiteralShift_16_24
							Else
								shift - 1
							EndIf
							
							control >> 1
							
							; --------------------------------------
							; C -> PB Konvertierung					
							;
							; if((symbol = huffman20_table[control & 63]) >= 20)
							; --------------------------------------								
							symbol = *p\huffman20_table[control & 63]
							If symbol >= 20
								
								;Debug "symbol is longer than 6 bits"
								; --------------------------------------
								; C -> PB Konvertierung					
								;	
								;  do
								;  {					
								;  } while(symbol >= 20);
								; --------------------------------------							
								Repeat
									symbol = *p\huffman20_table[((control >> 6) & 1) + (symbol << 1)]
									
									; --------------------------------------
									; C -> PB Konvertierung					
									;	
									; if(!shift--)
									; {}
									; --------------------------------------
									If shift = 0
										shift - 1
										MacroLiteralShift_16_24
									Else
										shift - 1
									EndIf
									
									control >> 1
									
								Until Not symbol >= 20
								
								temp = 6
							Else								
								temp = *p\huffman20_len[symbol]
							EndIf
							
							control >> temp
							
							shift - temp
							If shift < 0
								MacroLiteralShift_16_8
							EndIf
							
							; --------------------------------------
							; C -> PB Konvertierung					
							;	
							; symbol = table_four[literal_len[pos] + 17 - symbol];
							; --------------------------------------							
							symbol = *Table_Four\a[*p\literal_len[pos] + 17 - symbol]
							
							; --------------------------------------
							; C -> PB Konvertierung
							;	
							; while((pos < max_symbol) && (count--))
							; 	literal_len[pos++] = symbol;
							; --------------------------------------							
							While pos < max_symbol And count > 0
								*p\literal_len[pos] = symbol
								pos + 1
								count - 1
							Wend
							
						Default
							; --------------------------------------
							; C -> PB Konvertierung					
							;	
							; symbol = table_four[literal_len[pos] + 17 - symbol];							
							; --------------------------------------
							symbol = *Table_Four\a[*p\literal_len[pos] + 17 - symbol]
							
							; --------------------------------------
							; C -> PB Konvertierung					
							;	
							; literal_len[pos++] = symbol;							
							; --------------------------------------														
							*p\literal_len[pos] = symbol
							pos + 1
							
					EndSelect
					
					;Debug "Repeat: Position "+ Str(pos) +": Max Symbol: "+ Str(max_symbol) +": Control: "+ StrU(*p\control) +": Shift: "+ Str(*p\shift)
					
				Until Not pos < max_symbol
				
				
				fix - 1
				max_symbol + 512
				
				; Debug " Fix : " + Str(fix) + ": Max Symbol: " + Str(max_symbol)
				
			Until Not max_symbol = 768
			
			If abort = 0
				abort = Make_decode_table(768, 12, @*p\literal_len[0], @*p\literal_table[0])
				If ( abort = 1 )
					Debug "ERROR:  Literal Table damaged!"					
				EndIf				
			EndIf
			
		EndIf
		*p\global_control   = control
		*p\global_shift     = shift
		
		ProcedureReturn abort
		
	EndProcedure   

	;
	;
	;
	Procedure     Decrunch_BufferDebug(*buffer)
		;
		; Buffer test
		
		Protected sz.i, szString.s, szSign.s
		Protected *ptr.Ascii
		
		
		Debug "========================================================================= ; DEMO ;"
		
		For *ptr = *buffer To *buffer + MemorySize(*buffer) - 1
			If *ptr\a > 0
				
				Select *ptr\a
					Case #LF
						szSign = "\n"
					Default
						szSign = Chr(*ptr\a)
				EndSelect
				Debug "Decrunch Buffer [" +RSet( Str(*ptr), 8, " ") + "] " + RSet(Str(*ptr\a),3, " ") + " '" +  szSign  + "'"
			EndIf
			
			szString + Chr(*ptr\a)
		Next *ptr
		
		Debug "========================================================================= ; DEMO ;"
		Debug ""
		Debug szString.s
		Debug "========================================================================= ; DEMO ;"
		
	EndProcedure
	;
	;
	;
	; * Fill up the decrunch buffer. Needs lots of overrun for both destination *
	; * and source buffers. Most of the time is spent in this routine so it's  *
	; * pretty damn optimized. *
	;
	Procedure .i  Decrunch(*p.LZX_LITERAL, *decrunch_buffer)
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ; register unsigned int control;
            ; register int shift;
		; unsigned int temp;
		; unsigned int symbol, count;
		; unsigned char *string;
		; --------------------------------------			
		Protected *Table_One.AsciiArray
		Protected *Table_Two.UnicodeArray
		Protected *Table_Three.UnicodeArray
		Protected *string.Ascii
		Protected.i temp, count, symbol, shift
		Protected.q control
		
		
		*Table_One   = ?TABLE_ONE
		*Table_Two   = ?TABLE_TWO
		*Table_Three = ?TABLE_THREE
		
		control 	 = *p\global_control
		shift		 = *p\global_shift
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
		; do
		; {
		; } while((destination < destination_end) && (source < source_end));
		; --------------------------------------			
		Repeat
			
			; --------------------------------------
			; C -> PB Konvertierung
			;		
		      ;  if((symbol = literal_table[control & 4095]) >= 768)
			; --------------------------------------				
			symbol = *p\literal_table[control & 4095]
			If symbol >= 768
				
				control >> 12
				
				shift - 12
				If shift < 0
					MacroLiteralShift_16_8
				EndIf
				
				;Debug "literal is longer than 12 bits"
				; --------------------------------------
				; C -> PB Konvertierung
				;		
				; do
				; {
				; } while(symbol >= 768);
				; --------------------------------------					
				Repeat
					
					symbol = *p\literal_table[(control & 1) + (symbol << 1)]
					
					If shift = 0
						shift - 1
						MacroLiteralShift_16_24
					Else
						shift - 1
					EndIf
					
					control >> 1
					
				Until Not symbol >= 768
			Else
				
				temp = *p\literal_len[symbol]
				control >> temp
				
				shift - temp
				If shift < 0
					MacroLiteralShift_16_8
				EndIf
			EndIf
			
			If symbol < 256
				
				; --------------------------------------
				; C -> PB Konvertierung
				;		
				;  *destination++ = symbol;
				; --------------------------------------				
				*p\destination\a = symbol
				*p\destination + 1
				
			Else
				
				; --------------------------------------
				; C -> PB Konvertierung
				;		
				;  symbol-= 256;
				;  count  = table_two[temp = symbol & 31];
				;  temp   = table_one[temp];
				; --------------------------------------				
				symbol - 256
				temp   = symbol & 31
				count  = *Table_Two\u[temp]
				temp   = *Table_One\a[temp]
				
				; --------------------------------------
				; C -> PB Konvertierung
				;		
				; if((temp >= 3) && (decrunch_method == 3))
				; {}
				; --------------------------------------				
				If temp >= 3 And *p\decrunch_method = 3
					
					temp - 3
					
					count + ((control & *Table_Three\u[temp]) << 3)
					control >> temp
					
					shift - temp
					If shift < 0
						MacroLiteralShift_16_8
					EndIf
					
					; --------------------------------------
					; C -> PB Konvertierung
					;		
					; count += (temp = offset_table[control & 127]);
					; temp = offset_len[temp];
					; --------------------------------------					
					temp  = *p\offset_table[control & 127]
					count + temp
					temp  = *p\offset_len[temp]
				Else
					
					; --------------------------------------
					; C -> PB Konvertierung
					;		
					; count += control & table_three[temp];
					; --------------------------------------
					count + (control & *Table_Three\u[temp])
					If count = 0
						count = *p\last_offset
					EndIf
				EndIf
				
				control >> temp
				
				shift - temp
				If shift < 0
					MacroLiteralShift_16_8
				EndIf
				
				*p\last_offset = count
				
				temp  = (symbol >> 5) & 15
				count = *Table_Two\u[temp] + 3
				temp  = *Table_One\a[temp]
				count + (control & *Table_Three\u[temp])
				control >> temp
				
				shift - temp
				If shift < 0
					MacroLiteralShift_16_8
				EndIf
				
				; --------------------------------------
				; C -> PB Konvertierung
				;		
				; string = (decrunch_buffer + last_offset < destination) ? destination - last_offset : destination + 65536 - last_offset;
				; --------------------------------------				
				If *decrunch_buffer + *p\last_offset < *p\destination
					*string = *p\destination - *p\last_offset
				Else
					*string = *p\destination + 65536 - *p\last_offset
				EndIf
				
			
				; --------------------------------------
				; C -> PB Konvertierung
				;		
				; do
				; {
				;  *destination++ = *string++;
				; } while(--count);
				; --------------------------------------				
				Repeat
					*p\destination\a = *string\a
					*p\destination + 1
					*string + 1
					count - 1
				Until count = 0
				
			EndIf
			
			;Debug "Destination: " + Str(*p\destination) + " End " + Str(*p\destination_end) + " Source:" + Str(*p\source) + " End " + Str(*p\source_end)
		Until Not ((*p\destination < *p\destination_end) And (*p\source < *p\source_end))
		
		;Debug_Decrunch_Buffer(*DecrBuffer)
		
		*p\global_control = control
		*p\global_shift = shift
	EndProcedure     
	;
	;
	; * Opens a file for writing & creates the full path if required. *
	;
	Procedure .i  Open_Output(szAmigaFileSystem.s, szKonformTarget.s)
				
		Protected szDestination.s, subdir_count.i, i.i
		
		;
		; Not Allowed on Windows File System
		ReplaceString(szAmigaFileSystem, "?", "_", #PB_String_InPlace)
		ReplaceString(szAmigaFileSystem, "|", "_", #PB_String_InPlace)		
					
		
		szDestination.s = GetPathPart(szKonformTarget) + GetFilePart(szKonformTarget, #PB_FileSystem_NoExtension)
		
		If Right( szDestination, 1 ) <> "\"
			    szDestination + "\"	; Windows					
		EndIf
						
		If ( FileSize( szDestination ) ! -2 )
		     CreateDirectory(szDestination)
		EndIf			
		
		
		If FindString(szAmigaFileSystem, "/")
			
			subdir_count = CountString(szAmigaFileSystem, "/")
			
			For i = 1 To subdir_count
				
				szDestination + StringField(szAmigaFileSystem, i, "/") + "\"
				
				If ( FileSize( szDestination ) ! -2 )
		     			CreateDirectory(szDestination)
				EndIf	
			Next i
		EndIf
    
    		ProcedureReturn CreateFile(#PB_Any, szDestination + GetFilePart(szAmigaFileSystem))   
		
    	EndProcedure    
	;
	;
	;   
    	Procedure.i  Open_Output_Generate(*UnLZX.LZX_ARCHIVE)
    		
    		Protected.s szMsg

    		With *UnLZX\FileData()
    			
    			Select \PackMode
    				Case 0	: szMsg = "Stored"
    				Case 2	: szMsg = "Crunched"
    				Default	: szMsg = "Unknown" ; ....
    			EndSelect		
    					
    			
    			If ( *UnLZX\Verify = #True ) And ( Len(\File) > 0 )
    				If  ( *UnLZX\ExtractPos = -1 )
    					Debug #LF$ + "Packed Mode: "+szMsg+" - Checking File: " + \File	    				
    					ProcedureReturn  0
    					
    				ElseIf ( *UnLZX\ExtractPos = ListIndex( *UnLZX\FileData() ) )
    					Debug #LF$ + "Packed Mode: "+szMsg+" - Checking Single File: " + \File	
    					ProcedureReturn 0
    				EndIf	
    			EndIf 
    			
    			
    			If ( Len( \File ) = 0)
    				ProcedureReturn 0
    			EndIf	
  			
    							
    			If ( *UnLZX\ExtractAll = #True ) And ( *UnLZX\ExtractPos = -1 ) 
    				
    				Debug #LF$ + "PackMode:  "+szMsg+"  - Extracting File: " + \File
    				
				ProcedureReturn open_output(\File, *UnLZX\TargetDirectory)
				
			ElseIf ( *UnLZX\ExtractAll = #False ) And ( *UnLZX\ExtractPos = ListIndex( *UnLZX\FileData() ) ) 
				
				Debug #LF$ + "PackMode:  "+szMsg+"  - Extracting a single file from Archive: " + \File
				ProcedureReturn open_output(\File, *UnLZX\TargetDirectory)	
				
			EndIf				
		EndWith			
			
    	EndProcedure
	;
	;
	;  
    	Procedure.i  Open_Output_CloseFile(*UnLZX.LZX_ARCHIVE, PBFileData.i, Stop.i)
    		
    		If ( PBFileData = 0 ) And ( *UnLZX\Verify = #False )
    			
    			ProcedureReturn Stop
    			
    		ElseIf ( PBFileData > 0 ) And ( *UnLZX\Verify = #False )
    			
			CloseFile(PBFileData)
		EndIf	
		
		If ( Len(*UnLZX\FileData()\File) > 0 )
			
			With *UnLZX\FileData()
				
				If ( Stop = 0 ) And  ( ( *UnLZX\ExtractPos = -1 ) Or ( *UnLZX\ExtractPos = ListIndex( *UnLZX\FileData() ) ) )
					
					If ( \crcFile = 0 ) And ( \sum = 0 ) And \isMerged = #False
						*UnLZX\crcCountNull + 1
						
						Debug "No More Files/ Archive Damaged"	; Fix Me Correct Null Crc's
						Debug "> [ CRC: " + RSet( Hex(\crcFile,#PB_Long ), 10, "0") + " = " + RSet( Hex(\sum,#PB_Long ), 10, "0") + " NULL ] <"  + #CR$
						ProcedureReturn Stop
					Else    			
						If ( \crcFile = \sum  )   
							
							*UnLZX\crcCountGood  + 1
							*UnLZX\FileExtracted + 1
							Debug "CRC: " + RSet( Hex(\crcFile,#PB_Long ), 10, "0") + " = " + RSet( Hex(\sum,#PB_Long ), 10, "0") + " Good" + #CR$	
							ProcedureReturn Stop
						EndIf
						
						If ( \crcFile ! \sum  ) 
							*UnLZX\crcCountBad   + 1
							Debug "> [ CRC: " + RSet( Hex(\crcFile,#PB_Long ), 10, "0") + " = " + RSet( Hex(\sum,#PB_Long ), 10, "0") + " Bad ] <"  + #CR$
							ProcedureReturn Stop
						EndIf	
					EndIf
					
				EndIf	
			EndWith  
		EndIf
    	EndProcedure	
	;
	;
	;
	; * Trying to understand this function is hazardous. *
    	;
	Procedure .i  Extract_Normal(*UnLZX.LZX_ARCHIVE,*p.LZX_LITERAL)
		
		
		
		Protected.i count = 0
		   
		With *UnLZX\FileData()	

			out_file = Open_Output_Generate(*UnLZX)

			;Debug "reset CRC"
			*UnLZX\FileData()\sum = 0
			
			*p\unpack_size = \SizeUnpack				
			*p\pack_size   = \SizePacked
		
			While *p\unpack_size > 0
				
				;Debug "time To fill the buffer?"
				If *p\pos = *p\destination 
					
					;Debug "check If we have enough Data And Read some If Not"
					If *p\source >= *p\source_end
						
						;Debug "have we exhausted the current Read buffer?"
						*p\temp = *p\read_buffer
						
						count = *p\temp - *p\source + 16384

						If count							
							;Debug "copy the remaining overrun To the start of the buffer"
							; --------------------------------------
							; C -> PB Konvertierung
							;		
	      					; do 
            					; {
							; *temp++ = *source++;
							; } while(--count);
							; --------------------------------------								
							Repeat
								*p\temp\a = *p\source\a
								*p\temp   + 1
								*p\source + 1
								count     - 1
							Until count = 0								
						EndIf
						
						*p\source = *p\read_buffer
						count = *p\source - *p\temp + 16384
						
						\NewLocPos = count
						;Debug "Read/Write Position: " +Str( Loc(*UnLZX\pbData))
						
						If ( *p\pack_size = 0 ) 
							;
							; FixMe
							*p\pack_size = count															
							;Debug "merged packed"
						EndIf
						
						If  *p\pack_size < count
							;Debug "make sure we don't read too much"
							count = *p\pack_size						
						EndIf
																						
						If ReadData(*UnLZX\pbData, *p\temp, count) <> count
														
							If ( Lof(*UnLZX\pbData) = Loc(*UnLZX\pbData) ) ; FixME: Ende datei aber noch nicht fertig.
								*p\pack_size = 0
								count = Loc(*UnLZX\pbData) - \NewLocPos
								Continue
							Else		
								Debug "FATAL ERROR: can't read "+Str(count)+" data. File Lenght: " + Str( Lof(*UnLZX\pbData)) + " Read/Write Position: " +Str( Loc(*UnLZX\pbData))
								abort = 1
								Break
							EndIf	
						EndIf						
												
						*p\pack_size - count

						*p\temp + count
						If source >= *p\temp
							Debug "ERROR: argh no more data!"
							Break
						EndIf
						
					EndIf
					
					;Debug "check if we need to read the tables"
					If *p\decrunch_length <= 0
						
						;Debug "read_literal_table"
						
						abort = read_literal_table(*p)
						If abort = 1
							Debug "ERROR: argh can't make huffman tables!"							
							Break
						EndIf
					EndIf
					
					;Debug "unpack some Data"
					If *p\destination >= (*p\decrunch_buffer + 258 + 65536)
						
						count = *p\destination - *p\decrunch_buffer - 65536
						If count > 0
							
							*p\destination = *p\decrunch_buffer
							*p\temp = *p\destination + 65536
							
							;Debug "copy the overrun to the start of the buffer. count: " + Str(count)
							; --------------------------------------
							; C -> PB Konvertierung
							;		
	      					; do 
            					; {
							; *destination++ = *temp++;
							; } while(--count);
							; --------------------------------------								
							Repeat
								;  *destination++ = *temp++;
								*p\destination\a = *p\temp\a
								*p\destination + 1
								*p\temp + 1
								count - 1
							Until count = 0
						EndIf
						
						*p\pos = *p\destination
					EndIf
					*p\destination_end = *p\destination + *p\decrunch_length
					If *p\destination_end  > *p\decrunch_buffer + 258 + 65536
						*p\destination_end = *p\decrunch_buffer + 258 + 65536
					EndIf
					*p\temp = *p\destination
					
					decrunch(*p, *p\decrunch_buffer)
					
					*p\decrunch_length - (*p\destination - *p\temp)
				EndIf
				
				;Debug "calculate amount of data we can use before we need to fill the buffer again"
				count = *p\destination - *p\pos
				If count > *p\unpack_size
					;Debug "take only what we need"
					count = *p\unpack_size
				EndIf
				
				crc_calc(0, *UnLZX, count, *p\pos, 1)

				If IsFile(out_file)
					If WriteData(out_file, *p\pos, count) <> count
						CloseFile(out_file)
						out_file = 0
					EndIf
				EndIf

				*p\unpack_size - count
				*p\pos + count
				
				;Debug "left decrunch_length: " + Str(*p\decrunch_length)
				;Debug "left unpack_size: " + Str(*p\unpack_size)   				
			Wend
			
			abort = Open_Output_CloseFile(*UnLZX, out_file, abort)
			
		EndWith		
	
	EndProcedure
	;
	;
	; * This is less complex than extract_normal. Almost decipherable. *
	;
	Procedure.i   Extract_Store(*UnLZX.LZX_ARCHIVE,*p.LZX_LITERAL)
		
		Protected.i out_file, count, abort, unpack_size, pack_size
		Protected *read_buffer
		
		
		*read_buffer = AllocateMemory(16384)
		If *read_buffer
			
			With *UnLZX\FileData()
								
				FileSeek( *UnLZX\pbData, \loc )
				
				out_file = Open_Output_Generate(*UnLZX)
				
				If out_file Or ( *UnLZX\Verify = #True )
					
					\sum = 0   ; reset CRC
					
					pack_size 	= \SizePacked					
					unpack_size = \SizeUnpack
					
					If unpack_size > \SizePacked
						unpack_size = \SizePacked
					EndIf
					
					While unpack_size > 0
						
						If unpack_size > 16384
							count = 16384
						Else
							count = unpack_size
						EndIf
						
						If ReadData(*UnLZX\pbData, *read_buffer, count) <> count
							abort = 1
							Break   ; fatal error
						EndIf
						pack_size - count

						crc_calc(#Null, *UnLZX, count, *read_buffer, 1)
						
						If IsFile(out_file) ; Write the Data To the file
							If WriteData(out_file, *read_buffer, count) <> count
								CloseFile(out_file)
								out_file = 0
							EndIf
						EndIf
						unpack_size - count
					Wend
					
					abort = Open_Output_CloseFile(*UnLZX, out_file, abort)
					
				EndIf
			EndWith
			
			FreeMemory(*read_buffer)
		EndIf
				
		ProcedureReturn abort
		
	EndProcedure    
	;
	;
	; * Easiest of the three. Just print the file(s) we didn't understand. *
	;
	Procedure.i	  Extract_Unknown(*UnLZX.LZX_ARCHIVE)
		
		Protected.i abort = 0
		
		Debug "Unknown File : " + *UnLZX\FileData()\File
		
		ProcedureReturn abort
	EndProcedure	
	;
	;
	;	
	Procedure.i	  Extract_Structure_Init(*p.LZX_LITERAL)		       
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ; unsigned char *source;
            ; unsigned char *destination;
		; unsigned char *source_end;
		; unsigned char *destination_end;
		; unsigned char read_buffer[16384]; 			/* have a reasonable sized read buffer */
		; unsigned char decrunch_buffer[258+65536+258]; 	/* allow overrun for speed */
		; --------------------------------------			
		*p\read_buffer 			= AllocateMemory(16384)
    		*p\decrunch_buffer 		= AllocateMemory(258 + 65536 + 258)
		*p\count = 0
		
		
		*p\global_control           = 0      ; /* initial control word */
		*p\global_shift             = -16
		*p\last_offset              = 1
		*p\decrunch_length          = 0         
		*p\unpack_size              = 0
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ; source_end = (source = read_buffer + 16384) - 1024; 
		; --------------------------------------					
		*p\source     = *p\read_buffer + 16384
		*p\source_end = *p\source - 1024
		
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ; pos = destination_end = destination = decrunch_buffer + 258 + 65536;
		; --------------------------------------		
		*p\destination      = *p\decrunch_buffer + 258 + 65536
		*p\destination_end  = *p\destination 
		*p\pos              = *p\destination_end  
		
		ProcedureReturn *p.LZX_LITERAL
	EndProcedure	
	;
	;
	;
	Procedure 	  Extract_Structure_Clear(*p.LZX_LITERAL)	
		
		If ( *p\decrunch_buffer > 0 )
			FreeMemory(*p\decrunch_buffer)
		EndIf	
		
		If ( *p\read_buffer > 0 )		
			FreeMemory(*p\read_buffer)
		EndIf
		
		ClearStructure(*p,LZX_LITERAL)
		
	EndProcedure
	;
	;
	;
	Procedure.i	  Extract_Files_Search(*UnLZX.LZX_ARCHIVE, szFilename.s = "", DecrunchNum.i = -1)	 		
		
		;
		;
		; Such und Entpacke
		If ( Len( szFilename ) > 0 ) Or (DecrunchNum > 0)
			;
			; Benutzer sucht nach datei. -5 = Datei/Path ist nicht in der Liste vorhanden
			*UnLZX\ExtractPos = -5
			
			While NextElement( *UnLZX\ListData()  )
				If ( *UnLZX\ListData()\PathFile = szFilename ) Or (DecrunchNum = *UnLZX\ListData()\Position)
					*UnLZX\ExtractAll = #False
					*UnLZX\ExtractPos = *UnLZX\ListData()\Position
					Break
				EndIf
			Wend
			ProcedureReturn *UnLZX\ExtractPos
		EndIf
		
		ProcedureReturn 0		
	EndProcedure	
	;
	;
	;
	;
	Procedure.i	  Extract_GetUserNum(*UnLZX.LZX_ARCHIVE, DecrunchNum.i)				
			
		With User_LZX_List()
			
			ResetList( User_LZX_List() )
			
			If DecrunchNum > ListSize( *UnLZX\ListData() )
				ProcedureReturn -6	; Such Nummer Überschreitet die Grösse der Liste
			EndIf				
			
			While NextElement( User_LZX_List() )
				If \FileNum = DecrunchNum 
					ProcedureReturn \IndexID
				EndIf				
			Wend
			;
			; Such Nummer nicht Gefunden
			ProcedureReturn -7
		EndWith
	EndProcedure	
	;	
	;
	;
	Procedure	 Extract_SetTargetDirectory(*UnLZX.LZX_ARCHIVE, szTarget.s = "")
		;
		; Extrahiere das Archiv in das Unterverzeichnis mit dem Archiv Namen
		
		If ( szTarget = "*" )
			*UnLZX\TargetDirectory = GetPathPart( *UnLZX\Full ) + GetFilePart( *UnLZX\Full, #PB_FileSystem_NoExtension) + "\"
			
		ElseIf ( szTarget <> "" )
			
		If Right( szTarget, 1 ) <> "\"	;Or Right( szTarget, 1 ) <> "/"
			 szTarget + "\"	; Windows
			;szDestination + "/"				
		EndIf				
			*UnLZX\TargetDirectory = szTarget + GetFilePart(*UnLZX\Full)
		Else
			;
			; Standard im Selben Verzeicznis wo auch das Archiv ist
			*UnLZX\TargetDirectory = GetPathPart( *UnLZX\Full )
		EndIf			
		
	EndProcedure
	;	
	;
	;
	Procedure	 Extract_Result(*UnLZX.LZX_ARCHIVE)
		
		Protected.s szMsg = "Extracted"
		
		If *UnLZX\Verify = #True
			szMsg.s = "Checked"
		EndIf	
		
		Debug "[ Files "+szMsg+" " + Str(*UnLZX\FileExtracted) + "/"+Str( ListSize( *UnLZX\ListData()))+"  /Good CRC: " + Str(*UnLZX\crcCountGood) + " /Bad CRC: " + Str(*UnLZX\crcCountBad) + " /Nul CRC: " + Str(*UnLZX\crcCountNull) +" ]"		
		
	EndProcedure	
	;	
	;
	;
	Macro Extract_Single_FileBreak
		If ( *UnLZX\ExtractAll = #False)  And ( *UnLZX\ExtractPos = \Count-1 )
			Break
		EndIf		
	EndMacro
	;	
	;
	;
	Procedure .i  Extract_Reset_FileSeek_Pos(*UnLZX.LZX_ARCHIVE)
		;
		;	Resete die FileSeek Position
		;
			While NextElement( *UnLZX\FileData() )
				*UnLZX\FileData()\NewLocPos = 0							
			Wend
			
			FileSeek(  *UnLZX\pbData, 0, #PB_Relative); Setze Setze Seek Position am Anfang
	EndProcedure	
	;
	;
	;
	; * Read the archive and build a linked list of names. Merged files is     *
	; * always assumed. Will fail if there is no memory for a node. Sigh.      *
	;
	Procedure .i  Extract_Archive(*UnLZX.LZX_ARCHIVE, szTarget.s="", szFilename.s = "", DeCrunchNum.i = -1)
		
		Protected.i CurrentElement, MergedPosition, MergeTotal, SearchPosition = -1, Total, MergedSeekPos, Result
		Protected.q MergedSize
		
		*p.LZX_LITERAL 		= AllocateStructure(LZX_LITERAL)
		
		*UnLZX\ExtractAll 	= #True
		*UnLZX\ExtractPos 	= -1
		
		*UnLZX\crcCountGood 	= 0
		*UnLZX\crcCountBad  	= 0
		*UnLZX\crcCountNull  	= 0	
		*UnLZX\FileExtracted	= 0			
				
		;
		ResetList( *UnLZX\FileData() )
		ResetList( *UnLZX\ListData() )
		
		
		Extract_Reset_FileSeek_Pos(*UnLZX)
		
		If *UnLZX\Verify = #False
			Debug #LFCR$ + "> ... Extract:"
		Else
			Debug #LFCR$ + "> ... Verify:"
		EndIf	
		
		If *UnLZX\Verify = #False
			;		
			; Optional: Zielverzeichnis 
			Extract_SetTargetDirectory(*UnLZX, szTarget)
		EndIf			
		
	
			;		
			; Optional: Extract single files by Num			
			If ( DeCrunchNum > 0 )
				Result = Extract_GetUserNum(*UnLZX, DeCrunchNum)
				If Result < 0 
					ProcedureReturn Result
				EndIf
				DeCrunchNum = Result
			EndIf	
			
	
			;		
			; Optional: Extract single files by Name				
			If ( Len(szFilename) ) > 0 Or ( DeCrunchNum > 0 )
				Result = Extract_Files_Search(*UnLZX, szFilename, DeCrunchNum) 		
				If Result < 0 			
					Debug "File " + szFilename + " Not"
					FreeStructure(*p)
					ProcedureReturn Result
				EndIf	
			EndIf
		
		;
		ResetList( *UnLZX\FileData() )
		ResetList( *UnLZX\ListData() )
			
		With *UnLZX\FileData()		
			ForEach *UnLZX\FileData()		
				
				If (\SizePacked = 0 )
					PushListPosition( *UnLZX\FileData() )
					
					While NextElement( *UnLZX\FileData() )
						
						If ( \SizePacked > 0)
							MergedSize 		= \SizePacked
							MergedPosition	= \loc							
							PopListPosition( *UnLZX\FileData() )
							\SizePacked 	= MergedSize
							\loc 			= MergedPosition	
							Break
						EndIf	
					Wend																					
				EndIf
				
				If (\isMerged = 1) Or (Len(\File) = 0)
					Continue
				EndIf
				
				If (\SizeUnpack = 0 )
					;
					; Archiv beschädigt oder keine Dateien, Löse Push
					PopListPosition( *UnLZX\FileData() )
				EndIf
				
				FileSeek(*UnLZX\pbData, \Loc, #PB_Absolute)			
				
				Select *UnLZX\FileData()\PackMode
						
					Case 0      ; store				
						*p = Extract_Structure_Init(*p)						
						Extract_Store(*UnLZX, *p)						
						Extract_Structure_Clear(*p)
						
					Case 2      ; normal  																	
						*p = Extract_Structure_Init(*p)
						
						;
						; Wiederhole nur bei Merged Dateien	
						
						Repeat 
							;
							; Repeat für den Merged Modus da Position/Source und Destination 
							; für die Datei aktuell im pointer befinden		
							If ( \NewLocPos > 0 ) And (\SizePacked = 0 ) 
								FileSeek(*UnLZX\pbData, \NewLocPos  + \loc, #PB_Absolute)
							EndIf								
							
							Extract_Normal(*UnLZX,*p)	
							
							; Debug "File Seek : " +  Str( \NewLocPos  + \loc )	
							;
							; Mache Weiter bis der Merge packed byte beendet(0) ist
							; Gehe aus dem loop bei Packebyte 0 oder nach der Extraction
							; bestimmter Dateien
							
							Extract_Single_FileBreak		; Steige nach der Datei aus (Single Extract)
							
							If ( \PackedByte = 0) 								
								Break
							EndIf
							
							NextElement( *UnLZX\FileData() )
							
							
						ForEver 
						Extract_Structure_Clear(*p)	
						
					Default     ; unknown
						Extract_Unknown(*UnLZX)
						
				EndSelect  
				Extract_Single_FileBreak
			Next
		EndWith
		Delay( 5 )
		
		Extract_Result(*UnLZX)		
		
	EndProcedure    
	;
	;
	;
	; * List the contents of an archive in a nice formatted kinda way.         *
	;
	Procedure .i  View_Archive(*UnLZX.LZX_ARCHIVE)
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ; unsigned int temp;
            ; unsigned int total_pack = 0;
		; unsigned int total_unpack = 0;
		; unsigned int total_files = 0;
		; unsigned int merge_size = 0;
		; --------------------------------------			
		Protected TempPosition  = 0
		Protected total_pack    = 0;
		Protected total_unpack  = 0;    
		Protected CurrentPosition  = 0;   ist die "actual" variable
		Protected abort			;
		Protected result        = 1	; /* assume an error */   
		
		
		;Debug ("Unpacked" + Chr(9) +"  Packed" + Chr(9) + " CRC Calc " + Chr(9) + " CRC Summe " + Chr(9) +"   Time " + Chr(9) + "   Date " + Chr(9) + " Attrib " + Chr(9) + "Dir/File"  )
		;Debug ("--------" + Chr(9) +"--------" + Chr(9) + "-----------"+ Chr(9) + "-----------" + Chr(9) +"--------" + Chr(9) + "--------" + Chr(9) + "--------" + Chr(9) + "--------"  )      
		
		Repeat
			
			abort = 1; /* assume an error */            
				   ;
				   ;
			
			actual = ReadData(*UnLZX\pbData, @*UnLZX\archiv_header[0], 31)
			If actual > 0     ; 0 is normal And means EOF
				
				If actual = 31
					
					; --------------------------------------
					; C -> PB Konvertierung
					;		
				      ; crc = (archive_header[29] << 24) + (archive_header[28] << 16) + (archive_header[27] << 8) + archive_header[26];
			            ; archive_header[29] = 0;
					; archive_header[28] = 0;
					; archive_header[27] = 0;
					; archive_header[26] = 0;
					; --------------------------------------						
					*UnLZX\crc = (*UnLZX\archiv_header[29] << 24) + (*UnLZX\archiv_header[28] << 16) + (*UnLZX\archiv_header[27] << 8) + *UnLZX\archiv_header[26] ; header crc
					
					*UnLZX\archiv_header[29] = 0    ; Must set the field to 0 before calculating the crc
					*UnLZX\archiv_header[28] = 0	  ;
					*UnLZX\archiv_header[27] = 0	  ;
					*UnLZX\archiv_header[26] = 0	  ;
					
					*UnLZX\sum = 0                  ; reset CRC
					crc_calc(@*UnLZX\archiv_header[0], *UnLZX, 31)                                    
					
					; --------------------------------------------------------------------------------------------------------------------------------------------
					;
					temp = *UnLZX\archiv_header[30] ; filename length
					If temp = 0
						; no more files
						Break
					EndIf
					
					; --------------------------------------
					; C -> PB Konvertierung
					;		
				      ; actual = fread(header_comment, 1, temp, in_file);
			            ; if(actual == temp)
					; {
					; header_comment[temp] = 0;
					; ....}
					; --------------------------------------						
					actual = ReadData(*UnLZX\pbData, @*UnLZX\header_filename[0], temp)
					If actual = temp
						
						*UnLZX\header_filename[temp] = 0
						;Debug PeekS(@*UnLZX\header_filename[0], -1, #PB_Ascii)
						
						crc_calc(@*UnLZX\header_filename[0], *UnLZX, temp)      
						
						; -------------------------------------------------------------------------------------------------------------------------------------
						;
						temp = *UnLZX\archiv_header[14]   ; comment length
						actual = ReadData(*UnLZX\pbData, @*UnLZX\header_comment[0], temp)
						If actual = temp
							
							crc_calc(@*UnLZX\header_comment[0], *UnLZX, temp)
							
							If *UnLZX\sum = *UnLZX\crc
								
								;Debug "CRC: " + Hex(*UnLZX\crc)
								
								attributes = *UnLZX\archiv_header[0]   ; file protection modes
								
								unpack_size  = (*UnLZX\archiv_header[5]  << 24) + (*UnLZX\archiv_header[4]  << 16) + (*UnLZX\archiv_header[3]  << 8) + *UnLZX\archiv_header[2]   ; unpack size
								pack_size    = (*UnLZX\archiv_header[9]  << 24) + (*UnLZX\archiv_header[8]  << 16) + (*UnLZX\archiv_header[7]  << 8) + *UnLZX\archiv_header[6]	 ; packed size
								DatePosition = (*UnLZX\archiv_header[18] << 24) + (*UnLZX\archiv_header[19] << 16) + (*UnLZX\archiv_header[20] << 8) + *UnLZX\archiv_header[21]	 ; date

								; --------------------------------------
								; C -> PB Konvertierung
								;		
							      ; year = ((temp >> 17) & 63) + 1970;
						            ; month = (temp >> 23) & 15;
								; day = (temp >> 27) & 31;
								; hour = (temp >> 12) & 31;
								; minute = (temp >> 6) & 63;
								; second = temp & 63;
								; --------------------------------------									
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
									\PackMode   = *UnLZX\archiv_header[11]; /* pack mode */
									\crc        = *UnLZX\crc
									\Sum        = *UnLZX\sum
									\crcFile    = (*UnLZX\archiv_header[25] << 24) + (*UnLZX\archiv_header[24] << 16) + (*UnLZX\archiv_header[23] << 8) + *UnLZX\archiv_header[22]; /* data crc */
									
									\TimeDate = Date(Year, month, day, hour, minute, second)
									
									\SizePacked = pack_size
									\PackedByte = *UnLZX\archiv_header[12]
									\SizeUnpack = unpack_size
									
									\attributes = attributes
									
									\isMerged   = #False
									
									\ErrorMessage = ""
								EndWith 
								
								
								;
								; Dateien ''merged
								If   (*UnLZX\archiv_header[12] & 1) And ( pack_size > 0)                        
									;Debug RSet(Str(*UnLZX\MergedSize),8,Chr(32)) + Chr(9) + RSet(Get_Packed(pack_size,LogicalAnd( (*UnLZX\Archiv\c[12] & 1) , pack_size)),8,Chr(32))  + Chr(9) + "Merged"
									AddElement( *UnLZX\FileData() )
									With *UnLZX\FileData()
										\MergedSize = *UnLZX\MergedSize
										\SizePacked = Val( Get_Packed(pack_size,LogicalAnd( (*UnLZX\archiv_header[12] & 1) , pack_size)))
										\isMerged   = #True										
									EndWith
								EndIf
								
								
								If ( pack_size > 0); /* seek past the packed Data */ 
									; --------------------------------------
									; C -> PB Konvertierung
									;	
									; merge_size = 0;
									; if(!fseek(in_file, pack_size, SEEK_CUR))
							            ; {}
									; --------------------------------------									
									*UnLZX\MergedSize = 0 ;
									
									FileSeek(*UnLZX\pbData, pack_size, #PB_Relative) 
									*UnLZX\FileData()\SeekPosition = Loc(*UnLZX\pbData)
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
	Procedure .i  Process_Header(*UnLZX.LZX_ARCHIVE)
		
		Protected actual.i, result.i
		
		; --------------------------------------
		; C -> PB Konvertierung
		;		
	      ;  actual = fread(info_header, 1, 10, in_file);
            ;  {
		; 	if(actual == 10)
		; 	{
		;	 	if((info_header[0] == 76) && (info_header[1] == 90) && (info_header[2] == 88))
		;	 	{}
		;	}
		;  }
		; --------------------------------------			
		actual = ReadData(*UnLZX\pbData, @*UnLZX\info_header[0], 10)
		If actual = 10
			If (*UnLZX\info_header[0] = 'L') And (*UnLZX\info_header[1] = 'Z') And (*UnLZX\info_header[2] = 'X')   ; LZX
				Debug "LZX found"
				result = #True
			EndIf
		EndIf
		
		ProcedureReturn result
		
	EndProcedure 
	;
	;
	;
	Procedure .s  Files_CountDesc(TotalFiles.i)
		
		If ( TotalFiles = 1 )
			ProcedureReturn ""
		EndIf
		ProcedureReturn "s"
		
	EndProcedure   
	;
	;
	;   
	Procedure .i  Debug_View_Archiv( *UnLZX.LZX_ARCHIVE )
		
		Protected.s szSizeUnpack, szSizePacked, szCRCCalc, szCRC, szFileTime, szFileDate, szFileAttrib, szFileName, szMergedSize, szComment, FileNummer
		Protected.i Count
		
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
					
					Count + 1
					
					szSizeUnpack =  RSet( Str(\SizeUnpack) , 8, Chr(32) ) 
					FileNummer   =  RSet( Str( Count ), 2, " ")
					If ( \SizeUnpack = 0 )
						Count - 1
						szSizeUnpack = "  Damage"
						FileNummer = RSet( "", 2, " ")
					EndIf						
											
					szSizePacked =  RSet( Get_Packed( \SizePacked, \PackedByte ),8, Chr(32) )
				      szCRCCalc    =  RSet( Hex(\sum, #PB_Long), 10, " ")
				      szCRC        =  RSet( Hex(\crc, #PB_Long), 10, " ")                
          				szFileTime   = Get_Clock(\TimeDate)
          				szFileDate   = Get_Date(\TimeDate)
          				szFileAttrib = Get_Attrib(\attributes)
					szFileName   = \File 
					szComment    = \Comment
					
					 Debug FileNummer + szSizeUnpack + #TAB$ + szSizePacked+ #TAB$ + szCRCCalc + #TAB$ + szCRC + #TAB$ + szFileTime + #TAB$ + szFileDate + #TAB$ + szFileAttrib + #TAB$ + szFileName
					
					If ( Len(szComment) > 0 )
						Debug "Comment: "+ szComment
					EndIf                         
				EndIf                    
			Wend
			
		EndWith
		
		Debug ("--------" + Chr(9) +"--------" + Chr(9) + "-----------"+ Chr(9) + "-----------" + Chr(9) +"--------" + Chr(9) + "--------" + Chr(9) + "--------" + Chr(9) + "------------------------------------------------" )
		Debug RSet( Str( *UnLZX\TotalUnpack),8, " ") + Chr(9) + RSet( Str(*UnLZX\TotalPacked),8, " ") + Chr(9) + " File"+ Files_CountDesc(Count) + ": " + Str(Count)      
		
			
		Debug #LFCR$ + #TAB$ + "File: " + *UnLZX\Full
		Debug #TAB$ + "Size: " + *UnLZX\Size  + #CRLF$
	EndProcedure  
	;
	;
	;
	Procedure	.i Process_DataContent(*UnLZX.LZX_ARCHIVE )
		
		With *UnLZX
			ResetList(\FileData() )
			ResetList(\ListData() )
			
			While NextElement( \FileData() )
				
				If (\FileData()\isMerged = #True)
					*UnLZX\TotalFiles - 1
					Continue
				Else	
					AddElement( \ListData() )
					\ListData()\PathFile = \FileData()\File
					\ListData()\Position = ListIndex( \FileData() )
				EndIf	      			      		
			Wend
			
			ResetList(\FileData() )
			ResetList(\ListData() )      	
		EndWith
		
		ProcedureReturn ListSize(*UnLZX\ListData())
	EndProcedure
	;
	;
	;
	Procedure	.i Process_DataUserList(*UnLZX.LZX_ARCHIVE )
		
		Protected.i FileNum
		If ( *UnLZX > 0 )  
			With *UnLZX
				
				ResetList( \FileData() )
				ResetList( User_LZX_List() )
				
				While NextElement( \FileData() )
					
					AddElement( User_LZX_List() )
					If ( \FileData()\isMerged   = #True )
						User_LZX_List()\isMerge	 	= \FileData()\isMerged 
						User_LZX_List()\MergedUnpack	= \FileData()\MergedSize
						User_LZX_List()\MergedPacked	= \FileData()\SizePacked
						User_LZX_List()\MergedEnName 	= "Merged"
						Continue
					EndIf
					
					FileNum + 1
					User_LZX_List()\isMerge	 	= #False								
					User_LZX_List()\FileNum		= FileNum
					
					User_LZX_List()\SizeUnpack	= Str( \FileData()\SizeUnpack ) 
					
					If ( \FileData()\SizeUnpack = 0 )				
						User_LZX_List()\SizeUnpack = "Damage"
						User_LZX_List()\FileNum		= -1
					EndIf	
					
					User_LZX_List()\IndexID 	= ListIndex( \FileData() )
					
					User_LZX_List()\PathFile 	= \FileData()\File				
					User_LZX_List()\Attributes	= Get_Attrib( \FileData()\attributes )
					User_LZX_List()\szFileDate	= Get_Date( \FileData()\TimeDate )
					User_LZX_List()\szFileTime	= Get_Clock( \FileData()\TimeDate )
					User_LZX_List()\SizePacked	= Get_Packed( \FileData()\SizePacked, \FileData()\PackedByte )
					
					User_LZX_List()\szComment	= \FileData()\Comment				
				Wend	
				ResetList( \FileData() )
				ResetList( User_LZX_List() )	
			EndWith
		EndIf
		
		ProcedureReturn ListSize( User_LZX_List() )
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
	Procedure.i   Verify_Archive(*UnLZX.LZX_ARCHIVE, szFilename.s = "", DeCrunchNum.i = -1)
		
		If ( *UnLZX > 0 ) 
			
			*UnLZX\Verify = #True
			
			Extract_Archive(*UnLZX, "", szFilename, DeCrunchNum)
			
			*UnLZX\Verify = #False
			ProcedureReturn *UnLZX\crcCountBad	
		EndIf
		;
		; No LZX Opened in Memory
		ProcedureReturn -8
		
		
	EndProcedure	
	;
	;
	;
	Procedure .i  ListSize_Archive(*UnLZX.LZX_ARCHIVE)
		
		Protected.i Result
		
		If ( *UnLZX > 0 ) 
			
			
			ResetList( User_LZX_List() )
			
			While NextElement( User_LZX_List() )
				
				If  User_LZX_List()\isMerge
					Continue
				EndIf
				Result + 1

			Wend	
			
			ResetList( User_LZX_List() )
			
			ProcedureReturn Result
		EndIf
		;
		; No LZX Opened in Memory
		ProcedureReturn -8
		
	EndProcedure	
	;
	;
	;	
	Procedure .i  Examine_Archive( *UnLZX.LZX_ARCHIVE )    	    	  
		
		Protected.i Result
		
		If ( *UnLZX > 0 )     		
			Result = Process_DataContent(*UnLZX )
			If Result = 0
				ProcedureReturn -2
			EndIf
			
			Result = Process_DataUserList(*UnLZX )
			If Result = 0
				ProcedureReturn -3
			EndIf			
			
			Debug_View_Archiv(*UnLZX)
		EndIf
		
		ProcedureReturn 1
		
	EndProcedure	
	;
	;
	; * Process a single archive. *
	;
	Procedure .i  Process_Archive(File.s)

		If ( FileSize( File ) > 0 )
			
			*UnLZX.LZX_ARCHIVE  = AllocateMemory(SizeOf(LZX_ARCHIVE))
			InitializeStructure(*UnLZX, LZX_ARCHIVE)
			
			*UnLZX\Size         	= FileSize( File )
			*UnLZX\Full         	= File
			*UnLZX\Path         	= GetPathPart( File  )
			*UnLZX\File         	= GetFilePart( File , #PB_FileSystem_NoExtension)
			
			*UnLZX\FileError	  	= 1
			*UnLZX\TotalFiles   	= 0
			
			*UnLZX\pbData       	= ReadFile( #PB_Any,  *UnLZX\Full )
			*UnLZX\Verify	  	= #False					
			
			If ( *UnLZX\pbData = 0 )            
				Debug File + ": Datei ist von einem anderen programm geöffnet/ File is in Use"
				Close_Archive(*UnLZX)
				ProcedureReturn -4
			EndIf
			Debug "Opened :" + File + #CR$
			

			NewList  *UnLZX\FileData.LZX_FILEDATA()
			NewList  *UnLZX\ListData.LZX_DIRECTORY()
			
			If ( Process_Header(*UnLZX.LZX_ARCHIVE) = #True )
				
				View_Archive(*UnLZX.LZX_ARCHIVE) 
				
				ProcedureReturn *UnLZX                             
			Else
				ProcedureReturn -1
			EndIf	
		EndIf          
		
	EndProcedure
	
	
EndModule

CompilerIf #PB_Compiler_IsMainFile
	EnableExplicit
	
	; History
	
	;	v-0.7
	;	Support: Verify single File by FileName or Position Number
	
	;	v-0.6
	;	UnLZX::Extract_Archive(*LzxMemory, "*")
	;	Adding: Verify Archive UnLZX::Verify_Archive(*LzxMemory)
	
	
	;	v-0.1 - 0.5
	;	Initial Coding;	
	;	Converting Extract algo C Style to PB
	;	Big Thanks to Infratec for Correcting the Code
	;	Support Extract to Target Directory (Infratec)
	;	Support Extract to Sub Directory "*"
	;	Support Extract by Num (x Integer) or Name "String"
	
	;	Added Conversions Commentary
	
	
	
	Define File.s, Pattern.s, *LzxMemory, Result.i
	
	Pattern = "LZX (*.lzx)|*.lzx|Alle Dateien (*.*)|*.*"
	
	
	File = OpenFileRequester("LZX Tester","",Pattern,0)
	
	If ( File )  
		
		Debug UnLZX::About_UnLZX() + #CRLF$
		
		*LzxMemory = UnLZX::Process_Archive(File)
		
		If ( *LzxMemory > 0 )
			;
			; Archive Auflisten
			Result =  UnLZX::Examine_Archive(*LzxMemory)						
				;
				; ReturnCodes
				;
				; -1 : No LZX File
				; -2 : Error Data Listing
				; -3 : Error User Listing
				; -4 : File is In use

			;
			; Listing Example
			If Result > 0			
			
				While NextElement( UnLZX::User_LZX_List() )
					
					If  UnLZX::User_LZX_List()\isMerge
						Continue
					EndIf
					
					Debug #TAB$ + UnLZX::User_LZX_List()\PathFile
				Wend	
			Else 
				Debug Result
			EndIf	
			;
			;
			; Negative Zahlen sind Fehler
			; Positve  Zahlen sind  Schlechte CRC's
			; Bei 0 ist alles ok
			;
			Result = UnLZX::Verify_Archive(*LzxMemory)
			; Result = UnLZX::Verify_Archive(*LzxMemory, "", 2)
			If Result < 0
				Debug "Verify:" + Str(Result)
			Else
				If ( Result > 0)
					Debug "Verify: Bad CRC's = " + Str(Result)
				Else
					Debug "Verify: OK"
				EndIf	
			EndIf	
			
			;
			;
			;
			Result =  UnLZX::Extract_Archive(*LzxMemory, "*")
			If Result < 0
				Debug "Extract:" + Str(Result)
			EndIf
			
			;Archiv auf den selben Laufwerk in ein Unterverzeichnis mit dem Archiv Namen entpacken
			;Result =  UnLZX::Extract_Archive(*LzxMemory, "*")				
						
    			;Result =  UnLZX::Extract_Archive(*LzxMemory, "c:\tmp")			; Zielverzeichnis
			;Result =  UnLZX::Extract_Archive(*LzxMemory, "c:\tmp","gdm-np77.txt")	; Zielverzeichnis und dir Datei "gdm-np77.txt" Entpacken	
			;Result =  UnLZX::Extract_Archive(*LzxMemory, "B:\","", 6);			; Zielverzeichnis und Entpacke die (Archiv Position) 6 Datei
				;
				; ReturnCodes
				;
				; -5 : Extractting by File = File Not in the List
				; -6 : Extractting by Nr   = Number excced List
				; -7 : Extractting by Nr   = File Not in the List			
			
			;
			;
			;
			Result =  UnLZX::ListSize_Archive(*LzxMemory)
			If Result > 0
				Debug #LFCR$ + "> ... Archiv Count"
				Debug "LZX Archiv contains: " +  Result + " Files"
			EndIf	
			;
			;
			; Free File and Free Memory
			Debug #LFCR$ + "> ... Closing LZX File " + File
			*LzxMemory = UnLZX::Close_Archive(*LzxMemory)
			
		EndIf
	EndIf	
CompilerEndIf    
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 302
; FirstLine = 261
; Folding = bAAAAAA5
; EnableAsm
; EnableXP
; Compiler = PureBasic 5.73 LTS (Windows - x64)
; EnablePurifier