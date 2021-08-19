CompilerIf #PB_Compiler_IsMainFile
    

CompilerEndIf

;
; PE file structures
;
DeclareModule FFP
    
    ; File Inmformation
    #FVI_FileVersion      = $0001
    #FVI_FileDescription  = $0002
    #FVI_LegalCopyright   = $0004
    #FVI_InternalName     = $0008
    #FVI_OriginalFilename = $0010
    #FVI_ProductName      = $0020
    #FVI_ProductVersion   = $0040
    #FVI_CompanyName      = $0080
    #FVI_LegalTrademarks  = $0100
    #FVI_SpecialBuild     = $0200
    #FVI_PrivateBuild     = $0400
    #FVI_Comments         = $0800
    #FVI_Language         = $1000
    #FVI_Email            = $1001
    #FVI_Website          = $1002
    #FVI_Special          = $1003
    

    ; MZ = initials of Mark Zbikowski, one of the original architects of MS-DOS.
    #IMAGE_DOS_SIGNATURE          = $5A4D      ; MZ  -  IMAGE_DOS_HEADER \ e_magic
    #IMAGE_DOS_SIGNATURE_REVERSED = $4D5A      ; ZM  -  IMAGE_DOS_HEADER \ e_magic
    #IMAGE_OS2_SIGNATURE          = $454E      ; NE
    #IMAGE_OS2_SIGNATURE_LE       = $454C      ; LE
    #IMAGE_VXD_SIGNATURE          = $454C      ; LE
    
    #IMAGE_NT_SIGNATURE           = $00004550  ; PE00
    
    #IMAGE_ORDINAL_FLAG = $80000000
    
    #IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16
    
    ; IMAGE_NT_HEADERS -> IMAGE_FILE_HEADER -> Machine
    #IMAGE_FILE_MACHINE_UNKNOWN   =    $0  ; Unknown
    #IMAGE_FILE_MACHINE_I386      = $014c  ; Intel 386.
    #IMAGE_FILE_MACHINE_R3000     = $0162  ; MIPS little-endian, 0x160 big-endian
    #IMAGE_FILE_MACHINE_R4000     = $0166  ; MIPS little-endian
    #IMAGE_FILE_MACHINE_R10000    = $0168  ; MIPS little-endian
    #IMAGE_FILE_MACHINE_WCEMIPSV2 = $0169  ; MIPS little-endian WCE v2
    #IMAGE_FILE_MACHINE_ALPHA     = $0184  ; Alpha_AXP
    #IMAGE_FILE_MACHINE_SH3       = $01a2  ; SH3 little-endian
    #IMAGE_FILE_MACHINE_SH3DSP    = $01a3
    #IMAGE_FILE_MACHINE_SH3E      = $01a4  ; SH3E little-endian
    #IMAGE_FILE_MACHINE_SH4       = $01a6  ; SH4 little-endian
    #IMAGE_FILE_MACHINE_SH5       = $01a8  ; SH5
    #IMAGE_FILE_MACHINE_ARM       = $01c0  ; ARM Little-Endian
    #IMAGE_FILE_MACHINE_THUMB     = $01c2
    #IMAGE_FILE_MACHINE_AM33      = $01d3
    #IMAGE_FILE_MACHINE_POWERPC   = $01F0  ; IBM PowerPC Little-Endian
    #IMAGE_FILE_MACHINE_POWERPCFP = $01f1
    #IMAGE_FILE_MACHINE_IA64      = $0200  ; Intel 64
    #IMAGE_FILE_MACHINE_MIPS16    = $0266  ; MIPS
    #IMAGE_FILE_MACHINE_ALPHA64   = $0284  ; ALPHA64
    #IMAGE_FILE_MACHINE_MIPSFPU   = $0366  ; MIPS
    #IMAGE_FILE_MACHINE_MIPSFPU16 = $0466  ; MIPS
    #IMAGE_FILE_MACHINE_AXP64     = #IMAGE_FILE_MACHINE_ALPHA64
    #IMAGE_FILE_MACHINE_TRICORE   = $0520  ; Infineon
    #IMAGE_FILE_MACHINE_CEF       = $0CEF
    #IMAGE_FILE_MACHINE_EBC       = $0EBC  ; EFI Byte Code
    #IMAGE_FILE_MACHINE_AMD64     = $8664  ; AMD64 (K8)
    #IMAGE_FILE_MACHINE_M32R      = $9041  ; M32R little-endian
    #IMAGE_FILE_MACHINE_CEE       = $C0EE
    
    ; IMAGE_NT_HEADERS -> IMAGE_FILE_HEADER -> Characteristics
    #IMAGE_FILE_RELOCS_STRIPPED         = $0001  ; Relocation info stripped from file.
    #IMAGE_FILE_EXECUTABLE_IMAGE        = $0002  ; File is executable  (i.e. no unresolved externel references).
    #IMAGE_FILE_LINE_NUMS_STRIPPED      = $0004  ; Line nunbers stripped from file.
    #IMAGE_FILE_LOCAL_SYMS_STRIPPED     = $0008  ; Local symbols stripped from file.
    #IMAGE_FILE_AGGRESIVE_WS_TRIM       = $0010  ; Agressively trim working set
    #IMAGE_FILE_LARGE_ADDRESS_AWARE     = $0020  ; App can handle >2gb addresses
    #IMAGE_FILE_BYTES_REVERSED_LO       = $0080  ; Bytes of machine word are reversed.
    #IMAGE_FILE_32BIT_MACHINE           = $0100  ; 32 bit word machine.
    #IMAGE_FILE_DEBUG_STRIPPED          = $0200  ; Debugging info stripped from file in .DBG file
    #IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP = $0400  ; If Image is on removable media, copy And run from the swap file.
    #IMAGE_FILE_NET_RUN_FROM_SWAP       = $0800  ; If Image is on Net, copy And run from the swap file.
    #IMAGE_FILE_SYSTEM                  = $1000  ; System File.
    #IMAGE_FILE_DLL                     = $2000  ; File is a DLL.
    #IMAGE_FILE_UP_SYSTEM_ONLY          = $4000  ; File should only be run on a UP machine
    #IMAGE_FILE_BYTES_REVERSED_HI       = $8000  ; Bytes of machine word are reversed.
    
    ; IMAGE_NT_HEADERS -> IMAGE_OPTIONAL_HEADER -> Magic
    #IMAGE_NT_OPTIONAL_HDR32_MAGIC      = $10
    #IMAGE_NT_OPTIONAL_HDR64_MAGIC      = $20
    
    ; IMAGE_NT_HEADERS -> IMAGE_OPTIONAL_HEADER -> Subsystem
    #IMAGE_SUBSYSTEM_UNKNOWN            = 0  ; Unknown subsystem.
    #IMAGE_SUBSYSTEM_NATIVE             = 1  ; Image doesn't require a subsystem.
    #IMAGE_SUBSYSTEM_WINDOWS_GUI        = 2  ; Image runs in the Windows GUI subsystem.
    #IMAGE_SUBSYSTEM_WINDOWS_CUI        = 3  ; Image runs in the Windows character subsystem.
    #IMAGE_SUBSYSTEM_OS2_CUI            = 5  ; image runs in the OS/2 character subsystem.
    #IMAGE_SUBSYSTEM_POSIX_CUI          = 7  ; image runs in the Posix character subsystem.
    #IMAGE_SUBSYSTEM_NATIVE_WINDOWS     = 8  ; image is a native Win9x driver.
    #IMAGE_SUBSYSTEM_WINDOWS_CE_GUI     = 9  ; Image runs in the Windows CE subsystem.
    #IMAGE_SUBSYSTEM_EFI_APPLICATION    = 10
    #IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER = 11
    #IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER = 12
    #IMAGE_SUBSYSTEM_EFI_ROM            = 13
    #IMAGE_SUBSYSTEM_XBOX               = 14
    
    ; IMAGE_NT_HEADERS -> IMAGE_OPTIONAL_HEADER -> DllCharacteristics
    #IMAGE_DLLCHARACTERISTICS_NO_BIND               = $0800     ; Do not bind this image.
                                                                ;                                                 $1000     ; Reserved.
    #IMAGE_DLLCHARACTERISTICS_WDM_DRIVER            = $2000     ; Driver uses WDM model
                                                                ;                                                 $4000     ; Reserved.
    #IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE = $8000
    
    
    ; IMAGE_SECTION_HEADER -> Name
    #IMAGE_SIZEOF_SHORT_NAME = 8
    
    
    ;
    ; Section characteristics.
    ;
    #IMAGE_SCN_TYPE_REG                   = $00000000  ; Reserved.
    #IMAGE_SCN_TYPE_DSECT                 = $00000001  ; Reserved.
    #IMAGE_SCN_TYPE_NOLOAD                = $00000002  ; Reserved.
    #IMAGE_SCN_TYPE_GROUP                 = $00000004  ; Reserved.
    #IMAGE_SCN_TYPE_NO_PAD                = $00000008  ; Reserved.
    #IMAGE_SCN_TYPE_COPY                  = $00000010  ; Reserved.
    
    #IMAGE_SCN_CNT_CODE                   = $00000020  ; Section contains code.
    #IMAGE_SCN_CNT_INITIALIZED_DATA       = $00000040  ; Section contains initialized Data.
    #IMAGE_SCN_CNT_UNINITIALIZED_DATA     = $00000080  ; Section contains uninitialized Data.
    
    #IMAGE_SCN_LNK_OTHER                  = $00000100  ; Reserved.
    #IMAGE_SCN_LNK_INFO                   = $00000200  ; Section contains comments Or some other type of information.
    #IMAGE_SCN_TYPE_OVER                  = $00000400  ; Reserved.
    #IMAGE_SCN_LNK_REMOVE                 = $00000800  ; Section contents will not become part of image.
    #IMAGE_SCN_LNK_COMDAT                 = $00001000  ; Section contents comdat.
                                                       ;                                     = $00002000  ; Reserved.
    #IMAGE_SCN_MEM_PROTECTED              = $00004000  ; - Obsolete
    #IMAGE_SCN_NO_DEFER_SPEC_EXC          = $00004000  ; Reset speculative exceptions handling bits in the TLB entries For this section.
    #IMAGE_SCN_GPREL                      = $00008000  ; Section content can be accessed relative to GP
    #IMAGE_SCN_MEM_FARDATA                = $00008000
    #IMAGE_SCN_MEM_SYSHEAP                = $00010000  ; - Obsolete
    #IMAGE_SCN_MEM_PURGEABLE              = $00020000
    #IMAGE_SCN_MEM_16BIT                  = $00020000
    #IMAGE_SCN_MEM_LOCKED                 = $00040000
    #IMAGE_SCN_MEM_PRELOAD                = $00080000
    
    #IMAGE_SCN_ALIGN_1BYTES               = $00100000 
    #IMAGE_SCN_ALIGN_2BYTES               = $00200000 
    #IMAGE_SCN_ALIGN_4BYTES               = $00300000 
    #IMAGE_SCN_ALIGN_8BYTES               = $00400000 
    #IMAGE_SCN_ALIGN_16BYTES              = $00500000  ; Default alignment if no others are specified.
    #IMAGE_SCN_ALIGN_32BYTES              = $00600000 
    #IMAGE_SCN_ALIGN_64BYTES              = $00700000 
    #IMAGE_SCN_ALIGN_128BYTES             = $00800000 
    #IMAGE_SCN_ALIGN_256BYTES             = $00900000 
    #IMAGE_SCN_ALIGN_512BYTES             = $00A00000 
    #IMAGE_SCN_ALIGN_1024BYTES            = $00B00000 
    #IMAGE_SCN_ALIGN_2048BYTES            = $00C00000 
    #IMAGE_SCN_ALIGN_4096BYTES            = $00D00000 
    #IMAGE_SCN_ALIGN_8192BYTES            = $00E00000 
    ; Unused                              = $00F00000
    #IMAGE_SCN_ALIGN_MASK                 = $00F00000
    
    #IMAGE_SCN_LNK_NRELOC_OVFL            = $01000000  ; Section contains extended relocations.
    #IMAGE_SCN_MEM_DISCARDABLE            = $02000000  ; Section can be discarded.
    #IMAGE_SCN_MEM_NOT_CACHED             = $04000000  ; Section is not cachable.
    #IMAGE_SCN_MEM_NOT_PAGED              = $08000000  ; Section is not pageable.
    #IMAGE_SCN_MEM_SHARED                 = $10000000  ; Section is shareable.
    #IMAGE_SCN_MEM_EXECUTE                = $20000000  ; Section is executable.
    #IMAGE_SCN_MEM_READ                   = $40000000  ; Section is readable.
    #IMAGE_SCN_MEM_WRITE                  = $80000000  ; Section is writeable.
    
    
    ; IMAGE_NT_HEADERS -> IMAGE_OPTIONAL_HEADER -> DataDirectory
    #IMAGE_DIRECTORY_ENTRY_EXPORT         =  0   ; Export Directory
    #IMAGE_DIRECTORY_ENTRY_IMPORT         =  1   ; Import Directory
    #IMAGE_DIRECTORY_ENTRY_RESOURCE       =  2   ; Resource Directory
    #IMAGE_DIRECTORY_ENTRY_EXCEPTION      =  3   ; Exception Directory
    #IMAGE_DIRECTORY_ENTRY_SECURITY       =  4   ; Security Directory
    #IMAGE_DIRECTORY_ENTRY_BASERELOC      =  5   ; Base Relocation Table
    #IMAGE_DIRECTORY_ENTRY_DEBUG          =  6   ; Debug Directory
    #IMAGE_DIRECTORY_ENTRY_COPYRIGHT      =  7   ; Description String
    #IMAGE_DIRECTORY_ENTRY_GLOBALPTR      =  8   ; Machine Value (MIPS GP)
    #IMAGE_DIRECTORY_ENTRY_TLS            =  9   ; TLS Directory
    #IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG    = 10   ; Load Configuration Directory
    #IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT   = 11   ; Bound Import Directory in headers
    #IMAGE_DIRECTORY_ENTRY_IAT            = 12   ; Import Address Table
    #IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT   = 13   ; Delay Load Import Descriptors
    #IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR = 14   ; COM Runtime descriptor
    
    ; IMAGE_NT_HEADERS -> IMAGE_OPTIONAL_HEADER -> Magic
    #IMAGE_NT_OPTIONAL_HDR32_MAGIC      = $10
    #IMAGE_NT_OPTIONAL_HDR64_MAGIC      = $20
    

    Declare.s GetSection(FilePath$,TimeStamp=0,TimeStampWithComma=0)
    Declare.s GetFileInfo_Flag(ElementFlag)
    Declare.s GetFileInfo(lptstrFilename$, FVI_Flag)
EndDeclareModule

Module FFP
  
      
    ;- IMAGE_DOS_HEADER
    Structure _IMAGE_DOS_HEADER
        e_magic.w      ; Magic number
        e_cblp.w       ; Bytes on last page of file
        e_cp.w         ; Pages in file
        e_crlc.w       ; Relocations
        e_cparhdr.w    ; Size of header in paragraphs
        e_minalloc.w   ; Minimum extra paragraphs needed
        e_maxalloc.w   ; Maximum extra paragraphs needed
        e_ss.w         ; Initial (relative) SS value
        e_sp.w         ; Initial SP value
        e_csum.w       ; Checksum
        e_ip.w         ; Initial IP value
        e_cs.w         ; Initial (relative) CS value
        e_lfarlc.w     ; File address of relocation table
        e_ovno.w       ; Overlay number
        e_res.w[4]     ; Reserved words (0 To 3)
        e_oemid.w      ; OEM identifier (for e_oeminfo)
        e_oeminfo.w    ; OEM information; e_oemid specific
        e_res2.w[10]   ; Reserved words (0 To 9)
        e_lfanew.l     ; File address of new exe header (RVA)
    EndStructure
    
    
    
    ;- IMAGE_DATA_DIRECTORY
    Structure _IMAGE_DATA_DIRECTORY
        VirtualAddress.l  ; AS DWORD
        Size.l            ; AS DWORD
    EndStructure
    
    ;- IMAGE_OPTIONAL_HEADER
    Structure _IMAGE_OPTIONAL_HEADER
        ; Standard fields.
        Magic.w                         ; AS WORD
        MajorLinkerVersion.b            ; AS BYTE
        MinorLinkerVersion.b            ; AS BYTE
        SizeOfCode.l                    ; AS DWORD
        SizeOfInitializedData.l         ; AS DWORD
        SizeOfUninitializedData.l       ; AS DWORD
        AddressOfEntryPoint.l           ; AS DWORD
        BaseOfCode.l                    ; AS DWORD
        BaseOfData.l                    ; AS DWORD
                                        ; NT additional fields.
        ImageBase.l                     ; AS DWORD
        SectionAlignment.l              ; AS DWORD
        FileAlignment.l                 ; AS DWORD
        MajorOperatingSystemVersion.w   ; AS WORD
        MinorOperatingSystemVersion.w   ; AS WORD
        MajorImageVersion.w             ; AS WORD
        MinorImageVersion.w             ; AS WORD
        MajorSubsystemVersion.w         ; AS WORD
        MinorSubsystemVersion.w         ; AS WORD
        Win32VersionValue.l             ; AS DWORD
        SizeOfImage.l                   ; AS DWORD
        SizeOfHeaders.l                 ; AS DWORD
        CheckSum.l                      ; AS DWORD
        Subsystem.w                     ; AS WORD
        DllCharacteristics.w            ; AS WORD
        SizeOfStackReserve.l            ; AS DWORD
        SizeOfStackCommit.l             ; AS DWORD
        SizeOfHeapReserve.l             ; AS DWORD
        SizeOfHeapCommit.l              ; AS DWORD
        LoaderFlags.l                   ; AS DWORD
        NumberOfRvaAndSizes.l           ; AS DWORD
        DataDirectory._IMAGE_DATA_DIRECTORY[#IMAGE_NUMBEROF_DIRECTORY_ENTRIES]
    EndStructure
    
    ;- IMAGE_FILE_HEADER
    Structure _IMAGE_FILE_HEADER
        Machine.w                         ; AS WORD
        NumberOfSections.w                ; AS WORD
        TimeDateStamp.l                   ; AS DWORD
        PointerToSymbolTable.l            ; AS DWORD
        NumberOfSymbols.l                 ; AS DWORD
        SizeOfOptionalHeader.w            ; AS WORD
        Characteristics.w                 ; AS WORD
    EndStructure
    
    ;- IMAGE_NT_HEADERS
    Structure _IMAGE_NT_HEADERS
        Signature.l
        FileHeader._IMAGE_FILE_HEADER
        OptionalHeader._IMAGE_OPTIONAL_HEADER
    EndStructure
    
    
    
    Structure _IMAGE_SECTION_HEADER
        Name.b[#IMAGE_SIZEOF_SHORT_NAME]   ; AS STRING * %IMAGE_SIZEOF_SHORT_NAME
        StructureUnion
            PhysicalAddress.l                  ; AS DWORD
            VirtualSize.l                      ; AS DWORD
        EndStructureUnion
        VirtualAddress.l                    ; AS DWORD
        SizeOfRawData.l                     ; AS DWORD
        PointerToRawData.l                  ; AS DWORD
        PointerToRelocations.l              ; AS DWORD
        PointerToLinenumbers.l              ; AS DWORD
        NumberOfRelocations.w               ; AS WORD
        NumberOfLinenumbers.w               ; AS WORD
        Characteristics.l                   ; AS DWORD
    EndStructure
    
    
    
    Structure _IMAGE_IMPORT_DESCRIPTOR
        StructureUnion
            Characteristics.l      ; DWORD
            OriginalFirstThunk.l   ; DWORD
        EndStructureUnion
        TimeDateStamp.l          ; DWORD
        ForwarderChain.l         ; DWORD
        Name.l                   ; DWORD
        FirstThunk.l             ; DWORD
    EndStructure
    
    Structure _IMAGE_THUNK_DATA
        StructureUnion
            ForwarderString.l
            Function.l
            Ordinal.l
            AddressOfData.l
        EndStructureUnion
    EndStructure
    
    
    Structure _IMAGE_EXPORT_DIRECTORY
        Characteristics.l
        TimeDateStamp.l
        MajorVersion.w
        MinorVersion.w
        Name.l
        Base.l
        NumberOfFunctions.l
        NumberOfNames.l
        AddressOfFunctions.l
        AddressOfNames.l
        AddressOfNameOrdinals.l
    EndStructure
    
  ;==========================================================================================================
  ; Modul Information der Exe Dateien
  ;__________________________________________________________________________________________________________      
  Procedure.s GetFileInfo_Flag(ElementFlag)
    Protected TempString$ = ""
    Select ElementFlag
      Case #FVI_FileVersion     : TempString$ = "FileVersion"
      Case #FVI_FileDescription : TempString$ = "FileDescription"
      Case #FVI_LegalCopyright  : TempString$ = "LegalCopyright"
      Case #FVI_InternalName    : TempString$ = "InternalName"
      Case #FVI_OriginalFilename: TempString$ = "OriginalFilename"
      Case #FVI_ProductName     : TempString$ = "ProductName"
      Case #FVI_ProductVersion  : TempString$ = "ProductVersion"
      Case #FVI_CompanyName     : TempString$ = "CompanyName"
      Case #FVI_LegalTrademarks : TempString$ = "LegalTrademarks"
      Case #FVI_SpecialBuild    : TempString$ = "SpecialBuild"
      Case #FVI_PrivateBuild    : TempString$ = "PrivateBuild"
      Case #FVI_Comments        : TempString$ = "Comments"
      Case #FVI_Language        : TempString$ = "Language"
      Case #FVI_Email           : TempString$ = "Email"
      Case #FVI_Website         : TempString$ = "Website"
      Case #FVI_Special         : TempString$ = "Special"
    EndSelect
    ProcedureReturn TempString$
  EndProcedure    
  ;==========================================================================================================
  ; Modul Information der Exe Dateien
  ;__________________________________________________________________________________________________________        
  Prototype.l GetFileVersionInfoSizeW(lptstrFilename.p-unicode, lpdwHandle.l)
  Prototype.l GetFileVersionInfoW(lptstrFilename.p-unicode, dwHandle.l, dwLen.l, lpData.l)
  Prototype.l VerQueryValueW(pBlock.l, lpSubBlock.p-unicode, lplpBuffer.l, puLen.w)
  Prototype.l VerLanguageNameW(wLang.l, szLang.p-unicode, cchLang.l)
  ;==========================================================================================================
  ;
  ;__________________________________________________________________________________________________________        
  Procedure.s GetFileInfo(lptstrFilename$, FVI_Flag)
    Protected TempString$ = "", TempPtr, TempBlkSize, *TempBlk
    Protected TempLibHandle, TempBuff, TempBuffSize, TempCPLI$, TempLangSize = 128, TempLang$ = Space(TempLangSize)
    Protected GetFileVersionInfoSize.GetFileVersionInfoSizeW
    Protected GetFileVersionInfo.GetFileVersionInfoW
    Protected VerQueryValue.VerQueryValueW
    Protected VerLanguageName.VerLanguageNameW
    
    If FileSize(lptstrFilename$) >= 0
      TempLibHandle = OpenLibrary(#PB_Any, "version.dll")
      If TempLibHandle
        GetFileVersionInfoSize.GetFileVersionInfoSizeW = GetFunction(TempLibHandle, "GetFileVersionInfoSizeW")
        GetFileVersionInfo.GetFileVersionInfoW = GetFunction(TempLibHandle, "GetFileVersionInfoW")
        VerQueryValue.VerQueryValueW = GetFunction(TempLibHandle, "VerQueryValueW")
        VerLanguageName.VerLanguageNameW = GetFunction(TempLibHandle, "VerLanguageNameW")
        
        TempBlkSize = GetFileVersionInfoSize(lptstrFilename$, @TempPtr)
        If TempBlkSize > 0
          *TempBlk = AllocateMemory(TempBlkSize)
          If *TempBlk > 0
            If GetFileVersionInfo(lptstrFilename$, 0, TempBlkSize, *TempBlk)
              If VerQueryValue(*TempBlk, "\\VarFileInfo\\Translation", @TempBuff, @TempBuffSize)
                TempCPLI$ = RSet(Hex(PeekW(TempBuff)), TempBuffSize, "0") + RSet(Hex(PeekW(TempBuff + 2)), TempBuffSize, "0")
                VerLanguageName(PeekW(TempBuff), TempLang$, TempLangSize)
              EndIf
              If VerQueryValue(*TempBlk, "\\StringFileInfo\\" + TempCPLI$ + "\\" + GetFileInfo_Flag(FVI_Flag), @TempBuff, @TempBuffSize)
                TempString$ = PeekS(TempBuff, TempBuffSize)
              EndIf
              If FVI_Flag = #FVI_Language
                TempString$ = TempLang$
              EndIf
            EndIf
          EndIf
          FreeMemory(*TempBlk)
        EndIf
      EndIf
      CloseLibrary(TempLibHandle)
    EndIf
    
    ProcedureReturn(TempString$)
  EndProcedure
  
  ;==========================================================================================================
  ; PE Format: http://go.microsoft.com/FWLink/?LinkId=84140
  ;            http://www.microsoft.com/whdc/system/platform/firmware/PECOFF.mspx
  ;__________________________________________________________________________________________________________       
  Procedure.s GetSection(FilePath$,TimeStamp=0,TimeStampWithComma=0)
    
    Protected size,a, TimeStamp_Result$ = ""
    
    If ReadFile(0,FilePath$)
      
      size = Lof(0)
      If size < SizeOf(_IMAGE_DOS_HEADER)
        Debug("ERROR: input file too small.")
        ProcedureReturn
      EndIf
      Debug("reading EXE ("+Str(size)+" bytes)")
      *mem._IMAGE_DOS_HEADER = AllocateMemory(size)
      If *mem=0
        Debug("memory allocation error.")
        CloseFile(0)
        ProcedureReturn
      Else
        ReadData(0,*mem,size)
      EndIf
      
      CloseFile(0)
      
      If *mem
        
        
        
        If *mem\e_magic = #IMAGE_DOS_SIGNATURE Or *mem\e_magic = #IMAGE_DOS_SIGNATURE_REVERSED
          If ((*mem\e_lfanew + SizeOf(_IMAGE_NT_HEADERS)) > size)
            Debug("ERROR: input file too small.")
            ProcedureReturn
          EndIf
          
          *NTheader._IMAGE_NT_HEADERS = *mem + *mem\e_lfanew
          If Not *NTheader\Signature = #IMAGE_NT_SIGNATURE              ; PE00
            Debug("ERROR. no valid NT HEADER.")
            ProcedureReturn
          EndIf

         ; für Dich interessante Punkte
                   
          Debug "Image Base: "             + Str(*NTheader\OptionalHeader\ImageBase)
          Debug "Base Of Code: "           + Str(*NTheader\OptionalHeader\BaseOfCode)
          Debug "Size Of Code: "           + Str(*NTheader\OptionalHeader\SizeOfCode)
          Debug "Address Of Entry Point: " + Str(*NTheader\OptionalHeader\AddressOfEntryPoint)
          Debug "Characteristics: "        + Str(*NTheader\FileHeader\Characteristics)
          Debug "Time Date Stamp: "        + Str(*NTheader\FileHeader\TimeDateStamp)
          
          If (TimeStamp = 1)
            
            TimeStampData$ =  Hex(*NTheader\FileHeader\TimeDateStamp)
            
            For i = 1 To 8 Step 2
              
              TimeStamp_Byte$ = Right(TimeStampData$,2)
              
              If Len(TimeStamp_Result$) = 0
                TimeStamp_Result$ = TimeStamp_Byte$
              Else
                
                If (TimeStampWithComma = 1)
                  TimeStamp_Result$ = TimeStamp_Result$+","+TimeStamp_Byte$
                Else
                  TimeStamp_Result$ = TimeStamp_Result$+TimeStamp_Byte$
                EndIf
              EndIf    
              TimeStampData$ = Left(TimeStampData$,Len(TimeStampData$)-2)
              
            Next
            Debug "TimeDateStamp Result: " + TimeStamp_Result$
            ProcedureReturn TimeStamp_Result$
          EndIf
          
          
          
          number_of_sections = *NTheader\FileHeader\NumberOfSections & $FFFF
          Debug(Str(number_of_sections))
          
          *SectionHeader._IMAGE_SECTION_HEADER = *mem + *mem\e_lfanew + 4 + SizeOf(_IMAGE_FILE_HEADER) + *NTheader\FileHeader\SizeOfOptionalHeader
          *CurrentSectionHeader._IMAGE_SECTION_HEADER = *SectionHeader
          
          If number_of_sections
            For a = 1 To number_of_sections
              
              Debug("         Name                    : "+PeekS(@*CurrentSectionHeader\Name[0],#IMAGE_SIZEOF_SHORT_NAME,#PB_Ascii))
              Debug("         Virtual Size            : "+StrU(*CurrentSectionHeader\VirtualSize,#PB_Long)+" ($"+Hex(*CurrentSectionHeader\VirtualSize)+")")
              Debug("         Virtual Address         : "+StrU(*CurrentSectionHeader\VirtualAddress,#PB_Long)+" ($"+Hex(*CurrentSectionHeader\VirtualAddress)+")")
              Debug("         Size of Raw Data        : "+StrU(*CurrentSectionHeader\SizeOfRawData,#PB_Long)+" ($"+Hex(*CurrentSectionHeader\SizeOfRawData)+")")
              Debug("         Pointer to Raw Data     : "+StrU(*CurrentSectionHeader\PointerToRawData,#PB_Long)+" ($"+Hex(*CurrentSectionHeader\PointerToRawData)+")")
              Debug("         Pointer to Relocations  : "+StrU(*CurrentSectionHeader\PointerToRelocations,#PB_Long)+" ($"+Hex(*CurrentSectionHeader\PointerToRelocations)+")")
              Debug("         Pointer to Line Numbers : "+StrU(*CurrentSectionHeader\PointerToLinenumbers,#PB_Long)+" ($"+Hex(*CurrentSectionHeader\PointerToLinenumbers)+")")
              Debug("         Number of Relocations   : "+StrU(*CurrentSectionHeader\NumberOfRelocations&$FFFF,#PB_Word))
              Debug("         Number of Line Numbers  : "+StrU(*CurrentSectionHeader\NumberOfLinenumbers&$FFFF,#PB_Word))
              
              x = *CurrentSectionHeader\Characteristics
              If x
                If x & #IMAGE_SCN_CNT_CODE : Debug("found code section.") : EndIf
              EndIf
              *CurrentSectionHeader + SizeOf(_IMAGE_SECTION_HEADER)
            Next a
          EndIf
          
          ;             PrintN("writing file...")
          ;             If CreateFile(1,#file)
          ;                 WriteData(1,*mem,size)
          ;                 CloseFile(1)
          ;                 PrintN("patched successfully. DONE.")
          ;             Else
          Debug("ERROR. can not write file "+FilePath$)
          ProcedureReturn
        EndIf
      Else
        Debug("no valid executable found.")
        ProcedureReturn
      EndIf
    Else
      Debug("ERROR. Can not open "+FilePath$)
      ProcedureReturn
    EndIf
  EndProcedure
  
  
  

EndModule

CompilerIf #PB_Compiler_IsMainFile

    File$ = "C:\Windows\notepad.exe"

    Debug "================================ PE Info ========================================================================"
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_FileVersion) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_FileVersion)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_FileDescription) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_FileDescription)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_LegalCopyright) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_LegalCopyright)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_InternalName) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_InternalName)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_OriginalFilename) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_OriginalFilename)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_ProductName) + " : " + FFP::GetFileInfo(File$,FFP::#FVI_ProductName)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_ProductVersion) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_ProductVersion)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_CompanyName) + " : " + FFP::GetFileInfo(File$,FFP::#FVI_CompanyName)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_LegalTrademarks) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_LegalTrademarks)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_SpecialBuild) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_SpecialBuild)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_PrivateBuild) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_PrivateBuild)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_Comments) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_Comments)
    Debug FFP::GetFileInfo_Flag(FFP::#FVI_Language) + " : " + FFP::GetFileInfo(File$, FFP::#FVI_Language)
    Debug ""
    Debug "Getfile Info ===================================================================================================="
    For x = 0 To $1100
        y$ = Trim(FFP::GetFileInfo(File$, x))
        If y$ <> ""
            Debug Hex(x) + "  " + FFP::GetFileInfo_Flag(x) + " : " + FFP::GetFileInfo(File$, x)
        EndIf
    Next    
    Debug " GetSection ====================================================================================================="  
    Debug FFP::GetSection(File$,1,1)
    
CompilerEndIf

 
; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 406
; FirstLine = 336
; Folding = --
; EnableAsm
; EnableUnicode
; EnableXP