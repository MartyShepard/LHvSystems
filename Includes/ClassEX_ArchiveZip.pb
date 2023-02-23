CompilerIf #PB_Compiler_IsMainFile   
      UseCRC32Fingerprint()
 CompilerEndIf


;
;   Copyright (C) 2009 - 2013 Thomas Schulz (ts-soft)
; -----------------------------------------------------------------------
;   This software is provided 'as-is', without any express Or implied
;   warranty.  In no event will the authors be held liable For any damages
;   arising from the use of this software.
;
;   Permission is granted To anyone To use this software For any purpose,
;   including commercial applications, And To alter it And redistribute it
;   freely, subject To the following restrictions:
;
;   1. The origin of this software must Not be misrepresented; you must not
;      claim that you wrote the original software. If you use this software
;      in a product, an acknowledgment in the product documentation would be
;      appreciated but is Not required.
;   2. Altered source versions must be plainly marked As such, And must Not be
;      misrepresented As being the original software.
;   3. This notice may Not be removed Or altered from any source distribution.
;

DeclareModule CLZIP
    #ZLIB_FILEFUNC_MODE_READ            =  1
    #ZLIB_FILEFUNC_MODE_WRITE           =  2
    #ZLIB_FILEFUNC_MODE_READWRITEFILTER =  3
    #ZLIB_FILEFUNC_MODE_EXISTING        =  4
    #ZLIB_FILEFUNC_MODE_CREATE          =  8
    
    #ZIP_OK                             =  0
    #ZIP_CANCEL                         =  1
    #UNZIP_OK                           =  0
    #UNZIP_CANCEL                       =  1
    #UNZ_END_OF_LIST_OF_FILE            = -100
    
    #Z_NO_COMPRESSION                   =  0
    #Z_BEST_SPEED                       =  1
    #Z_BEST_COMPRESSION                 =  9
    #Z_DEFAULT_COMPRESSION              = -1
    
    #Z_DEFLATED                         =  8
    
    Enumeration
        #ZIP_SUPPORT_OK
        #ZIP_SUPPORT_NOT_ARCHIVE
        #ZIP_SUPPORT_ERROR_IN_ARCHIVE
    EndEnumeration
    
    Enumeration
        #APPEND_STATUS_CREATE
        #APPEND_STATUS_CREATEAFTER
        #APPEND_STATUS_ADDINZIP
    EndEnumeration
    
    CompilerIf Defined(tm_unz, #PB_Structure) = #False
        ;/* tm_unz contain date/time info */
        Structure tm_unz
            tm_sec.l;            /* seconds after the minute - [0,59] */
            tm_min.l;            /* minutes after the hour - [0,59] */
            tm_hour.l;           /* hours since midnight - [0,23] */
            tm_mday.l;           /* day of the month - [1,31] */
            tm_mon.l ;            /* months since January - [0,11] */
            tm_year.l;           /* years - [1980..2044] */
        EndStructure
    CompilerEndIf
    
    CompilerIf Defined(unz_global_info, #PB_Structure) = #False
        ;/* unz_global_info structure contain global data about the ZIPfile
        ;   These data comes from the end of central dir */
        Structure unz_global_info
            number_entry.l      ;         /* total number of entries in
            size_comment.l      ;         /* size of the global comment of the zipfile */
        EndStructure
    CompilerEndIf
    
    CompilerIf Defined(unz_file_info, #PB_Structure) = #False
        Structure unz_file_info
            version.l;              /* version made by                 2 bytes */
            version_needed.l;       /* version needed to extract       2 bytes */
            flag.l          ;                 /* general purpose bit flag        2 bytes */
            compression_method.l;   /* compression method              2 bytes */
            dosDate.l           ;              /* last mod file date in Dos fmt   4 bytes */
            crc.l               ;                  /* crc-32                          4 bytes */
            compressed_size.l   ;      /* compressed size                 4 bytes */
            uncompressed_size.l ;    /* uncompressed size               4 bytes */
            size_filename.l     ;        /* filename length                 2 bytes */
            size_file_extra.l   ;      /* extra field length              2 bytes */
            size_file_comment.l ;    /* file comment length             2 bytes */
            disk_num_start.l    ;       /* disk number start               2 bytes */
            internal_fa.l       ;          /* internal file attributes        2 bytes */
            external_fa.l       ;          /* external file attributes        4 bytes */
            tmu_date.tm_unz     ;
            FileName.s
        EndStructure
    CompilerEndIf
    
    CompilerIf Defined(zip_fileinfo, #PB_Structure) = #False
        Structure zip_fileinfo
            tm_zip.tm_unz
            dosDate.l
            internal_fa.l
            external_fa.l
        EndStructure
    CompilerEndIf
    
  
    
    Declare PackMemory(*source, sourceLen = #PB_Default, level = #Z_DEFAULT_COMPRESSION)
    Declare UnpackMemory(*source, *dest)
    Declare SetPassword(password.s = "")
    Declare GetFilesCount(Zip_FileName.s)
    Declare.s GetFileComment(Zip_FileName.s)
    Declare.s GetFileInfo(Zip_FileName.s, FileNumber, *FileInfo.unz_file_info = 0)
    Declare.i IsPasswordRequired(Zip_FileName.s, FileNumber)
    Declare.i IsZipArchive(ZipFilename.s)
    Declare GetFileNumber(Zip_FileName.s, FileName.s) 
    Declare ExtractFile(Zip_FileName.s, FileNumber, Output_Path.s, CreatePath = #True, Callback = 0)
    Declare ExtractArchiv(Zip_FileName.s, Output_Path.s, CreatePath = #True, Callback = 0)
    Declare CatchFile(Zip_FileName.s, FileNumber, Callback = 0)
    Declare FileClose(ZipHandle, Comment.s = "")
    Declare FileCreate(Zip_FileName.s)
    Declare FileOpen(FileName.s)
    Declare FileAdd(ZipHandle, Filename.s, Archive_Filename.s, Compression = #Z_DEFAULT_COMPRESSION, Callback = 0)
    Declare DirAdd(ZipHandle, Directory.s, Compression = #Z_DEFAULT_COMPRESSION, Callback = 0)
    Declare MemAdd(ZipHandle, *source, sourceLen, Archive_Filename.s, Compression = #Z_DEFAULT_COMPRESSION, Callback = 0)   
    Declare BrowseDirectory(sPath.s, List ZIP_DirList.s(), List ZIP_FileList.s())
EndDeclareModule
Module CLZIP
    
  ImportC "msvcrt.lib"
        _wfopen(file.s, mode.s)
        fopen(file.s, mode.s)
        malloc(size)
        free(mem)
        fwrite(*buffer, result, sizeof ,fh)
        fclose(fh);
    EndImport
    
    ImportC "zlib.lib"
        compress2(*dest, *destLen, *source, sourceLen.i, level.i)
        uncompress(*dest, *destLen, *source, sourceLen.i)
    EndImport
    
    CompilerSelect #PB_Compiler_Processor
        CompilerCase #PB_Processor_x86
            #miniziplib$ = "_Libs\minizip_x86.lib"
            !extrn __chkstk
            !public __chkstk as "___chkstk"
        CompilerCase #PB_Processor_x64
            #miniziplib$ = "_Libs\minizip_x64.lib"
        CompilerEndSelect
        
    ImportC #miniziplib$
        fill_fopen_filefunc(*fileapi)
        unzClose(unzFile)
        unzCloseCurrentFile(unzFile)
        unzGetCurrentFileInfo(unzFile, *pfile_info, *szFileName, fileNameBufferSize.l, *extraField, extraFieldBufferSize.l, *szComment, commentBufferSize.l)
        unzGetGlobalComment(unzFile, *szComment, uSizeBuf.i)
        unzGetGlobalInfo(unzFile, *pglobal_info)
        unzGoToFirstFile(unzFile)
        unzGoToNextFile(unzFile)
        unzLocateFile(unzFile, Filename.s, a)
        unzOpen2(path.s, *zlib_filefunc)
        unzOpenCurrentFile(unzFile)
        unzOpenCurrentFilePassword(unzFile, password.p-ascii)
        unzReadCurrentFile(unzFile, *buf, len.i)
        zipClose(zipFile, *global_comment)
        zipCloseFileInZip(zipFile)
        zipOpen(path.p-ascii, append.i)
        zipOpen2(path.p-ascii, append.i, *zipcharpc, *zlib_filefunc)
        zipOpenNewFileInZip2(zipFile, filename.p-utf8, *zipfi, *extrafield_local, size_extrafield_local.i, *extrafield_global, size_extrafield_global.i, *comment, method.i, level.i, raw.i)
        zipOpenNewFileInZip3(zipFile, filename.p-utf8, *zipfi, *extrafield_local, size_extrafield_local.i, *extrafield_global, size_extrafield_global.i, *comment, method.i, level.i, raw.i, windowBits.i, memLevel.l, strategy.i, password.p-ascii, crcForCtypting)
        zipWriteInFileInZip(zipFile, *buf, len.i)
    EndImport
    
    Prototype ZIP_PackerCallback(progress)
    Prototype ZIP_ArchivCallback(progress, files)
    
    Prototype open_file_func (opaque.i, filename.s, mode)
    Prototype read_file_func (opaque.i, stream.i, buf.i, size)
    Prototype write_file_func(opaque.i, stream.i, buf.i, size)
    Prototype tell_file_func (opaque.i, stream.i)
    Prototype seek_file_func (opaque.i, stream.i, offset, origin)
    Prototype close_file_func(opaque.i, stream.i)
    Prototype testerror_file_func(opaque.i,stream.i)
    
    Structure zlib_filefunc_def
        zopen_file.open_file_func
        zread_file.read_file_func
        zwrite_file.write_file_func
        ztell_file.tell_file_func
        zseek_file.seek_file_func
        zclose_file.close_file_func
        zerror_file.testerror_file_func
        opaque.open_file_func
    EndStructure
    
Define.s ZIP_Password

Procedure.i MakeSureDirectoryPathExists(Path$)
  
  If Right(Path$, Len(Path$)) <> "\"
    Path$ + "\" 
  EndIf
  
  Select FileSize(Path$)
    Case -2: ProcedureReturn #True
    Default
      ProcedureReturn #False
  EndSelect    
  
EndProcedure  
  

;{ private functions
Procedure fopen_file_func(opaque, filename.s, mode)

  Protected file.i
  Protected mode_fopen.s

  If ((mode & #ZLIB_FILEFUNC_MODE_READWRITEFILTER) = #ZLIB_FILEFUNC_MODE_READ)
    mode_fopen = "rb"
  ElseIf (mode & #ZLIB_FILEFUNC_MODE_EXISTING)
    mode_fopen = "r+b"
  ElseIf (mode & #ZLIB_FILEFUNC_MODE_CREATE)
    mode_fopen = "wb"
  EndIf

  If filename And mode_fopen
    CompilerIf #PB_Compiler_Unicode
    file = _wfopen(filename, mode_fopen)
    CompilerElse
    file = fopen(filename, mode_fopen)
    CompilerEndIf
  EndIf

  ProcedureReturn file
EndProcedure

Procedure BrowseDirectory(sPath.s, List ZIP_DirList.s(), List ZIP_FileList.s())
  Protected dirID, sDirName.s
  
  If (Right(sPath, 1) <> "\"): sPath + "\"  : EndIf

  dirID = ExamineDirectory(#PB_Any, sPath, "")
  If dirID
    While NextDirectoryEntry(dirID)
      If DirectoryEntryType(dirID) =  #PB_DirectoryEntry_File
        AddElement(ZIP_FileList())
        ZIP_FileList() = sPath + DirectoryEntryName(dirID)
      Else
        sDirName = DirectoryEntryName(dirID)
        If (sDirName <> ".") And (sDirName <> "..")
          AddElement(ZIP_DirList())
          ZIP_DirList() = sPath + sDirName
          BrowseDirectory(sPath + sDirName, ZIP_DirList(), ZIP_FileList())
        EndIf
      EndIf
    Wend
    FinishDirectory(dirID)
  EndIf
EndProcedure

;}

Procedure PackMemory(*source, sourceLen = #PB_Default, level = #Z_DEFAULT_COMPRESSION)
  Protected *dest, destLen

  If level < #PB_Default Or level > 9 : level = #PB_Default : EndIf
  If *source
    If sourceLen = #PB_Default : sourceLen = MemorySize(*source) : EndIf
    destLen = sourceLen + 13 + (Int(sourceLen / 100))
    *dest = AllocateMemory(destLen)
    If *dest
      If Not compress2(*dest, @destLen, *source, sourceLen, level)
        *dest = ReAllocateMemory(*dest, destLen)
        ProcedureReturn *dest
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure UnpackMemory(*source, *dest)
  Protected sourceLen = MemorySize(*source)
  Protected destLen = MemorySize(*dest)

  If Not uncompress(*dest, @destLen, *source, sourceLen)
    ProcedureReturn destLen
  EndIf
EndProcedure

Procedure SetPassword(password.s = "")
  Shared ZIP_Password
  ZIP_Password = password
EndProcedure

Procedure.i GetFilesCount(Zip_FileName.s)
  Protected GlobalInfo.unz_global_info
  Protected file_api.zlib_filefunc_def
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)

  If Handle
    If Not unzGetGlobalInfo(Handle, @GlobalInfo)
      unzClose(Handle)
      ProcedureReturn GlobalInfo\number_entry
    EndIf
    unzClose(Handle)
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.s GetFileComment(Zip_FileName.s)
  Protected GlobalInfo.unz_global_info
  Protected file_api.zlib_filefunc_def
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)
  Protected size.i, result.s, nSize.i

  If Handle
    If Not unzGetGlobalInfo(Handle, @GlobalInfo)
      size = GlobalInfo\size_comment
      If size
        Dim szComment.c(size + 1)
        nSize = unzGetGlobalComment(Handle, @szComment(), size)
        If nSize > 0
          result = PeekS(@szComment(), -1, #PB_Ascii)
        EndIf
      EndIf
    EndIf
    unzClose(Handle)
  EndIf
  ProcedureReturn result
EndProcedure

Procedure.s GetFileInfo(Zip_FileName.s, FileNumber, *FileInfo.unz_file_info = 0)
  Protected Dim filename_buffer.c(#MAX_PATH + 1)
  Protected file_api.zlib_filefunc_def, i
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)

  If FileNumber > 0 And FileNumber <= GetFilesCount(Zip_FileName)
    If Handle
      unzGoToFirstFile(Handle)
      If FileNumber > 1
        For i = 2 To FileNumber
          unzGoToNextFile(Handle)
        Next
      EndIf
      unzGetCurrentFileInfo(Handle, *FileInfo, filename_buffer(), #MAX_PATH, 0, 0, 0, 0)
      If *FileInfo
        *FileInfo\FileName = PeekS(filename_buffer(), -1, #PB_UTF8)
      EndIf
      unzClose(Handle)
      ProcedureReturn PeekS(filename_buffer(), -1, #PB_UTF8)
    EndIf
  EndIf
  unzClose(Handle)
  ProcedureReturn ""
EndProcedure

Procedure IsPasswordRequired(Zip_FileName.s, FileNumber)
  Protected zfi.unz_file_info

  GetFileInfo(Zip_FileName, FileNumber, @zfi)
  If zfi\flag & %1
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure.i IsZipArchive(ZipFilename.s)
  Protected file_api.zlib_filefunc_def
  Protected unz.i, code.l, result.l

  code = #ZIP_SUPPORT_OK
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  unz = unzOpen2(ZipFilename, @file_api)
  If unz
    result = unzGoToFirstFile(unz)
    If result <> #UNZ_END_OF_LIST_OF_FILE And result <> #UNZIP_OK
      Code = #ZIP_SUPPORT_ERROR_IN_ARCHIVE
    EndIf
    If Code = #ZIP_SUPPORT_OK
      While result = #UNZIP_OK
        result = unzGoToNextFile(unz)
      Wend
      If result <> #UNZ_END_OF_LIST_OF_FILE
        Code = #ZIP_SUPPORT_ERROR_IN_ARCHIVE
      EndIf
    EndIf
    unzClose(unz)
    ProcedureReturn Code
  EndIf
  ProcedureReturn #ZIP_SUPPORT_NOT_ARCHIVE
EndProcedure

Procedure GetFileNumber(Zip_FileName.s, FileName.s)
  Protected Dim filename_buffer.c(#MAX_PATH + 1)
  Protected FileInfo.unz_file_info, fCount, i
  Protected file_api.zlib_filefunc_def
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)

  If Handle
    FileName = UCase(FileName)
    ReplaceString(FileName, "\", "/", #PB_String_InPlace)
    If Not unzGoToFirstFile(Handle)
      unzGetCurrentFileInfo(Handle, FileInfo, @filename_buffer(), #MAX_PATH, 0, 0, 0, 0)
      FileInfo\FileName = UCase(PeekS(@filename_buffer(), -1, #PB_UTF8))
      If FileInfo\FileName = FileName
        unzClose(Handle)
        ProcedureReturn 1
      EndIf
      fCount = GetFilesCount(Zip_FileName)
      For i = 2 To fCount
        unzGoToNextFile(Handle)
        unzGetCurrentFileInfo(Handle, FileInfo, @filename_buffer(), #MAX_PATH, 0, 0, 0, 0)
        FileInfo\FileName = UCase(PeekS(@filename_buffer(), -1, #PB_UTF8))
        If FileInfo\FileName = FileName
          unzClose(Handle)
          ProcedureReturn i
        EndIf
      Next
    EndIf
    unzClose(Handle)
  EndIf
EndProcedure

Procedure ExtractFile(Zip_FileName.s, FileNumber, Output_Path.s, CreatePath = #True, Callback = 0)
  Protected Dim filename_buffer.c(#MAX_PATH + 1)
  Protected FileInfo.unz_file_info
  Protected i.i, Size.q, DirPath.s, result
  Protected *OutBuffer, FF, Date, divider.f
  Protected file_api.zlib_filefunc_def
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)
  Shared ZIP_Password

  If Right(Output_Path, 1) <> "\" : Output_Path + "\" : EndIf
  If FileNumber > 0 And FileNumber <= GetFilesCount(Zip_FileName)
    If Handle
      unzGoToFirstFile(Handle)
      If FileNumber > 1
        For i = 2 To FileNumber
          unzGoToNextFile(Handle)
        Next
      EndIf
      unzGetCurrentFileInfo(Handle, @FileInfo, @filename_buffer(), #MAX_PATH, 0, 0, 0, 0)
      FileInfo\FileName = PeekS(@filename_buffer(), -1, #PB_UTF8)
      Size = FileInfo\uncompressed_size
      If Size
        divider = 100 / (Size)
      EndIf
      DirPath = Output_Path + FileInfo\FileName
      ReplaceString(DirPath, "/", "\", #PB_String_InPlace)
      If Size = 0 And CreatePath = #True And Right(FileInfo\FileName, 1) = "\"
        MakeSureDirectoryPathExists(DirPath)
        unzCloseCurrentFile(Handle)
        unzClose(Handle)
        With FileInfo
          SetFileDate(DirPath, #PB_Date_Modified, Date(\tmu_date\tm_year, \tmu_date\tm_mon + 1, \tmu_date\tm_mday, \tmu_date\tm_hour, \tmu_date\tm_min, \tmu_date\tm_sec))
          SetFileAttributes(DirPath, \external_fa)
        EndWith
        ProcedureReturn #True
      Else
        If ZIP_Password <> ""
          result = unzOpenCurrentFilePassword(Handle, ZIP_Password)
        Else
          result = unzOpenCurrentFile(Handle)
        EndIf
        If Not result
          If CreatePath = #False
            FileInfo\FileName = GetFilePart(DirPath)
          Else
            MakeSureDirectoryPathExists(GetPathPart(DirPath))
          EndIf
          CompilerIf #PB_Compiler_Unicode
          FF = _wfopen(DirPath, "w+b")
          CompilerElse
          FF = fopen(DirPath, "w+b")
          CompilerEndIf
          If FF
            *OutBuffer = AllocateMemory(102400)
            If *OutBuffer
              i = 0
              Repeat
                Size = unzReadCurrentFile(Handle, *OutBuffer, 102400)
                fwrite(*OutBuffer, Size, 1, FF)
                i + Size
                If Callback
                  If CallFunctionFast(Callback, Int(i * divider)) = #UNZIP_CANCEL
                    unzCloseCurrentFile(Handle)
                    fclose(FF)
                    FreeMemory(*OutBuffer)
                    unzClose(Handle)
                    ProcedureReturn #False
                  EndIf
                EndIf
              Until Not Size
              If Callback
                CallFunctionFast(Callback, 100)
              EndIf
              FreeMemory(*OutBuffer)
            EndIf
            fclose(FF)
            With FileInfo
              SetFileDate(DirPath, #PB_Date_Modified, Date(\tmu_date\tm_year, \tmu_date\tm_mon + 1, \tmu_date\tm_mday, \tmu_date\tm_hour, \tmu_date\tm_min, \tmu_date\tm_sec))
              SetFileAttributes(DirPath, \external_fa)
            EndWith
          EndIf
          unzCloseCurrentFile(Handle)
        EndIf
      EndIf
      unzClose(Handle)
      ProcedureReturn #True
    EndIf
  EndIf
  unzClose(Handle)
  ProcedureReturn #False
EndProcedure

Procedure ExtractArchiv(Zip_FileName.s, Output_Path.s, CreatePath = #True, Callback = 0)
  Protected Dim filename_buffer.c(#MAX_PATH + 1)
  Protected FileInfo.unz_file_info
  Protected Size.q, DirPath.s, firstFile.i, i.i, res.l, count.i = -1, result
  Protected *OutBuffer, FF, Date, divider.f, divider2.f
  Protected file_api.zlib_filefunc_def
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)
  Shared ZIP_Password

  If Handle
    divider2 = 100 / GetFilesCount(Zip_FileName)
    If Right(Output_Path, 1) <> "\" : Output_Path + "\" : EndIf
    While firstFile <> -1
      count + 1
      If Callback
        If CallFunctionFast(Callback, 0, Int(count * divider2)) = #UNZIP_CANCEL
          unzCloseCurrentFile(Handle)
          CloseFile(FF)
          FreeMemory(*OutBuffer)
          unzClose(Handle)
          ProcedureReturn #False
        EndIf
      EndIf
      If Not firstFile
        unzGoToFirstFile(Handle)
        firstfile = #True
      Else
        res = unzGoToNextFile(Handle)
        If res = #UNZ_END_OF_LIST_OF_FILE
          firstFile = -1
        EndIf
      EndIf
      unzGetCurrentFileInfo(Handle, @FileInfo, @filename_buffer(), #MAX_PATH, 0, 0, 0, 0)
      FileInfo\FileName = PeekS(@filename_buffer(), -1, #PB_UTF8)
      Debug "ArcZip: "+FileInfo\FileName
      Size = FileInfo\uncompressed_size
      If Size > 0
        divider = 100 / Size
      EndIf
      DirPath = Output_Path + FileInfo\FileName
      ReplaceString(DirPath, "/", "\", #PB_String_InPlace)
      If Size = 0 And CreatePath = #True And Right(FileInfo\FileName, 1) = "\"
        MakeSureDirectoryPathExists(DirPath)
        unzCloseCurrentFile(Handle)
        With FileInfo
          SetFileDate(DirPath, #PB_Date_Modified, Date(\tmu_date\tm_year, \tmu_date\tm_mon + 1, \tmu_date\tm_mday, \tmu_date\tm_hour, \tmu_date\tm_min, \tmu_date\tm_sec))
          SetFileAttributes(DirPath, \external_fa)
        EndWith
      Else
        If ZIP_Password <> ""
          result = unzOpenCurrentFilePassword(Handle, ZIP_Password)
        Else
          result = unzOpenCurrentFile(Handle)
        EndIf
        If Not result
          If CreatePath = #False
            FileInfo\FileName = GetFilePart(DirPath)
          Else
            MakeSureDirectoryPathExists(GetPathPart(DirPath))
          EndIf
          CompilerIf #PB_Compiler_Unicode
          FF = _wfopen(DirPath, "w+b")
          CompilerElse
          FF = fopen(DirPath, "w+b")
          CompilerEndIf
          If FF
            *OutBuffer = AllocateMemory(102400)
            If *OutBuffer
              i = 0
              Repeat
                Size =  unzReadCurrentFile(Handle, *OutBuffer, 102400)
                If Size : fwrite(*OutBuffer, Size, 1, FF) : EndIf
                i + Size
                If Callback
                  If CallFunctionFast(Callback, Int(i * divider), Int(count * divider2)) = #UNZIP_CANCEL
                    unzCloseCurrentFile(Handle)
                    fclose(FF)
                    FreeMemory(*OutBuffer)
                    unzClose(Handle)
                    ProcedureReturn #False
                  EndIf
                EndIf
              Until Not Size
              FreeMemory(*OutBuffer)
            EndIf
            fclose(FF)
            With FileInfo
              SetFileDate(DirPath, #PB_Date_Modified, Date(\tmu_date\tm_year, \tmu_date\tm_mon + 1, \tmu_date\tm_mday, \tmu_date\tm_hour, \tmu_date\tm_min, \tmu_date\tm_sec))
              SetFileAttributes(DirPath, \external_fa)
            EndWith
          EndIf
          unzCloseCurrentFile(Handle)
        EndIf
      EndIf
    Wend
    If Callback
      CallFunctionFast(Callback, 100, 100)
    EndIf
    unzClose(Handle)
  EndIf
  ProcedureReturn count
EndProcedure

Procedure CatchFile(Zip_FileName.s, FileNumber, Callback = 0)
  Protected Dim filename_buffer.c(#MAX_PATH + 1)
  Protected FileInfo.unz_file_info
  Protected i.i, Size.q, length.i, divider.f, result
  Protected *OutBuffer, *Buffer
  Protected file_api.zlib_filefunc_def
  fill_fopen_filefunc(@file_api)
  file_api\zopen_file = @fopen_file_func()
  Protected Handle = unzOpen2(Zip_FileName, @file_api)
  Shared ZIP_Password

  If FileNumber > 0 And FileNumber <= GetFilesCount(Zip_FileName)
    If Handle
      unzGoToFirstFile(Handle)
      If FileNumber > 1
        For i = 1 To FileNumber - 1
          unzGoToNextFile(Handle)
        Next
      EndIf
      unzGetCurrentFileInfo(Handle, @FileInfo, @filename_buffer(), #MAX_PATH, 0, 0, 0, 0)
      FileInfo\FileName = PeekS(@filename_buffer(), -1, #PB_UTF8)
      Size = FileInfo\uncompressed_size
      If Size
        divider = 100 / Size
        If ZIP_Password <> ""
          result = unzOpenCurrentFilePassword(Handle, ZIP_Password)
        Else
          result = unzOpenCurrentFile(Handle)
        EndIf
        If Not result
          *OutBuffer = AllocateMemory(Size)
          If *OutBuffer
            *Buffer = *OutBuffer
            If *Buffer
              i = 0
              Repeat
                If Size > 102400
                  unzReadCurrentFile(Handle, *Buffer, 102400)
                  *Buffer + 102400
                  Size - 102400
                Else
                  unzReadCurrentFile(Handle, *Buffer, Size)
                  Size = 0
                EndIf
                i + Size
                If Callback
                  If CallFunctionFast(Callback, Int(i * divider)) = #UNZIP_CANCEL
                    unzCloseCurrentFile(Handle)
                    FreeMemory(*OutBuffer)
                    unzClose(Handle)
                    ProcedureReturn #False
                  EndIf
                EndIf
              Until Not Size
            EndIf
          EndIf
          unzCloseCurrentFile(Handle)
        EndIf
      EndIf
    EndIf
  EndIf
  unzClose(Handle)
  ProcedureReturn *OutBuffer
EndProcedure

Procedure FileClose(ZipHandle, Comment.s = "")
  Protected *mem, FF, Size
  If Comment <> ""
    If UCase(GetExtensionPart(Comment)) = "TXT" And FileSize(Comment) > 0
      FF = ReadFile(#PB_Any, Comment)
      If FF
        Size = Lof(FF)
        *mem = AllocateMemory(Size)
        If *mem
          ReadData(FF, *mem, Size)
        EndIf
        CloseFile(FF)
        If  *mem
          Comment = PeekS(*mem)
          FreeMemory(*mem)
        EndIf
      EndIf
    EndIf
    *mem = AllocateMemory(Len(Comment))
    If *mem
      PokeS(*mem, Comment, -1, #PB_Ascii)
    EndIf
  EndIf
  zipClose(ZipHandle, *mem)
  If *mem : FreeMemory(*mem) : EndIf
EndProcedure

Procedure FileCreate(Zip_FileName.s)
  ProcedureReturn zipOpen(Zip_FileName, #APPEND_STATUS_CREATE)
EndProcedure

Procedure FileOpen(FileName.s)
  Protected FF, Append_Method
  If FileSize(FileName) <= 0 : ProcedureReturn #False : EndIf
  If IsZipArchive(FileName) = #ZIP_SUPPORT_OK
    Append_Method = #APPEND_STATUS_ADDINZIP
  Else
    FF = OpenFile(#PB_Any, FileName)
    If FF
      FileSeek(FF, Lof(FF))
      WriteByte(FF, $50)
      WriteByte(FF, $4B)
      WriteByte(FF, $05)
      WriteByte(FF, $06)
      WriteLong(FF, 0)
      WriteLong(FF, 0)
      WriteLong(FF, 0)
      WriteLong(FF, 0)
      WriteWord(FF, 0)
      CloseFile(FF)
    EndIf
    Append_Method = #APPEND_STATUS_ADDINZIP
  EndIf
  ProcedureReturn zipOpen(FileName, Append_Method)
EndProcedure

Procedure FileAdd(ZipHandle, Filename.s, Archive_Filename.s, Compression = #Z_DEFAULT_COMPRESSION, Callback = 0)
  Protected file_date = GetFileDate(Filename, #PB_Date_Modified)
  Protected in_filesize.q, divider.f, FF, *buffer, length.i, result
  Protected zfi.zip_fileinfo
  Shared ZIP_Password

  With zfi
    \tm_zip\tm_sec   = Val(FormatDate("%ss", file_date))
    \tm_zip\tm_min   = Val(FormatDate("%ii", file_date))
    \tm_zip\tm_hour  = Val(FormatDate("%hh", file_date))
    \tm_zip\tm_mday  = Val(FormatDate("%dd", file_date))
    \tm_zip\tm_mon   = Val(FormatDate("%mm", file_date)) -1
    \tm_zip\tm_year  = Val(FormatDate("%yyyy", file_date))
    \external_fa     = GetFileAttributes(Filename)
  EndWith

  in_filesize = FileSize(Filename)
  If in_filesize > 2147483647 : ProcedureReturn #False : EndIf

  divider = 100 / in_filesize
   
  
  If ZIP_Password <> "" And in_filesize <> -2
 ;   result = zipOpenNewFileInZip3(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0, 15, 8, 0, ZIP_Password, CRC32FileFingerprint(Filename))
  result = zipOpenNewFileInZip3(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0, 15, 8, 0, ZIP_Password, FileFingerprint(Filename,#PB_Cipher_CRC32))  
  Else
    result = zipOpenNewFileInZip2(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0)
  EndIf
  If Not result
    FF = ReadFile(#PB_Any, Filename)
    If FF
      FileBuffersSize(FF, 102400)
      *buffer = AllocateMemory(102400)
      If *buffer
        Repeat
          length = ReadData(FF, *buffer, 102400)
          If zipWriteInFileInZip(ZipHandle, *buffer, length)
            zipCloseFileInZip(ZipHandle)
            ProcedureReturn #False
          EndIf
          If Callback
            If CallFunctionFast(Callback, Int(Loc(FF) * divider)) = #ZIP_CANCEL
              CloseFile(FF)
              zipCloseFileInZip(ZipHandle)
              FreeMemory(*buffer)
              ProcedureReturn #False
            EndIf
          EndIf
        Until Eof(FF)
        CloseFile(FF)
        zipCloseFileInZip(ZipHandle)
        FreeMemory(*buffer)
        ProcedureReturn #True
      EndIf
    EndIf
    zipCloseFileInZip(ZipHandle)
  EndIf
  ProcedureReturn #False
EndProcedure

Procedure DirAdd(ZipHandle, Directory.s, Compression = #Z_DEFAULT_COMPRESSION, Callback = 0)
  Protected file_date, zfi.zip_fileinfo, Archive_Filename.s, result, count
  Protected in_filesize.q, FF, *buffer, length, divider.f, divider2.f
  Shared ZIP_Password
  NewList ZIP_FileList.s()
  NewList ZIP_DirList.s()

  If Right(Directory, 1) <> "\" : Directory + "\" : EndIf

  If FileSize(Directory) = -2
    BrowseDirectory(Directory, ZIP_DirList(), ZIP_FileList())
    ForEach ZIP_DirList()
      file_date = GetFileDate(ZIP_DirList(), #PB_Date_Modified)
      With zfi
        \tm_zip\tm_sec   = Val(FormatDate("%ss", file_date))
        \tm_zip\tm_min   = Val(FormatDate("%ii", file_date))
        \tm_zip\tm_hour  = Val(FormatDate("%hh", file_date))
        \tm_zip\tm_mday  = Val(FormatDate("%dd", file_date))
        \tm_zip\tm_mon   = Val(FormatDate("%mm", file_date)) -1
        \tm_zip\tm_year  = Val(FormatDate("%yyyy", file_date))
        \external_fa     = GetFileAttributes(ZIP_DirList())
      EndWith
      Archive_Filename = RemoveString(ZIP_DirList(), Directory)
      If Not zipOpenNewFileInZip2(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0)
        zipCloseFileInZip(ZipHandle)
      EndIf
    Next
    If ListSize(ZIP_FileList())
      divider2 = 100 / ListSize(ZIP_FileList())
    EndIf
    count = 0
    ForEach ZIP_FileList()
      If Callback
        CallFunctionFast(Callback, 0, Int(count * divider2))
      EndIf
      count + 1
      file_date = GetFileDate(ZIP_FileList(), #PB_Date_Modified)
      With zfi
        \tm_zip\tm_sec   = Val(FormatDate("%ss", file_date))
        \tm_zip\tm_min   = Val(FormatDate("%ii", file_date))
        \tm_zip\tm_hour  = Val(FormatDate("%hh", file_date))
        \tm_zip\tm_mday  = Val(FormatDate("%dd", file_date))
        \tm_zip\tm_mon   = Val(FormatDate("%mm", file_date)) -1
        \tm_zip\tm_year  = Val(FormatDate("%yyyy", file_date))
        \external_fa     = GetFileAttributes(ZIP_FileList())
      EndWith
      Archive_Filename = RemoveString(ZIP_FileList(), Directory)
      in_filesize = FileSize(ZIP_FileList())
      If in_filesize > 2147483647 : Continue : EndIf

      If ZIP_Password <> ""
        result = zipOpenNewFileInZip3(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0, 15, 8, 0, ZIP_Password, FileFingerprint(ZIP_FileList(), #PB_Cipher_CRC32))
      Else
        result = zipOpenNewFileInZip2(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0)
      EndIf
      If Not result
        FF = ReadFile(#PB_Any, ZIP_FileList())
        If FF
          If Lof(FF)
            divider = 100 / Lof(FF)
          EndIf
          FileBuffersSize(FF, 102400)
          *buffer = AllocateMemory(102400)
          If *buffer
            length = 0
            Repeat
              length = ReadData(FF, *buffer, 102400)
              If zipWriteInFileInZip(ZipHandle, *buffer, length)
                zipCloseFileInZip(ZipHandle)
                count - 1
                Continue
              EndIf
              If Callback
                If CallFunctionFast(Callback, Int(Loc(FF) * divider), Int(count * divider2)) = #ZIP_CANCEL
                  zipCloseFileInZip(ZipHandle)
                  CloseFile(FF)
                  FreeMemory(*Buffer)
                  ProcedureReturn #False
                EndIf
              EndIf
            Until Eof(FF)
            CloseFile(FF)
            zipCloseFileInZip(ZipHandle)
            FreeMemory(*buffer)
          EndIf
        EndIf
      EndIf
    Next
    If Callback
      CallFunctionFast(Callback, 100, 100)
    EndIf
    ProcedureReturn count
  EndIf
EndProcedure

Procedure MemAdd(ZipHandle, *source, sourceLen, Archive_Filename.s, Compression = #Z_DEFAULT_COMPRESSION, Callback = 0)
  Protected zfi.zip_fileinfo
  Protected divider.f, pos.i, result
  Shared ZIP_Password

  divider = 100 / sourceLen

  With zfi
    \tm_zip\tm_sec   = Val(FormatDate("%ss", Date()))
    \tm_zip\tm_min   = Val(FormatDate("%ii", Date()))
    \tm_zip\tm_hour  = Val(FormatDate("%hh", Date()))
    \tm_zip\tm_mday  = Val(FormatDate("%dd", Date()))
    \tm_zip\tm_mon   = Val(FormatDate("%mm", Date())) -1
    \tm_zip\tm_year  = Val(FormatDate("%yyyy", Date()))
  EndWith

  If ZIP_Password <> ""
    result = zipOpenNewFileInZip3(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0, 15, 8, 0, ZIP_Password, Fingerprint(*source, sourceLen, #PB_Cipher_CRC32))
  Else
    result = zipOpenNewFileInZip2(ZipHandle, Archive_Filename, @zfi, #Null, 0, #Null, 0, #Null, #Z_DEFLATED, Compression, 0)
  EndIf
  If Not result
    While sourceLen > 102400
      If zipWriteInFileInZip(ZipHandle, *source, 102400)
        zipCloseFileInZip(ZipHandle)
        ProcedureReturn #False
      EndIf
      sourceLen - 102400
      *source + 102400
      pos + 102400
      If Callback
        If CallFunctionFast(Callback, Int(pos * divider)) = #UNZIP_CANCEL
          zipCloseFileInZip(ZipHandle)
          ProcedureReturn #False
        EndIf
      EndIf
    Wend
    If zipWriteInFileInZip(ZipHandle, *source, sourceLen)
      zipCloseFileInZip(ZipHandle)
      ProcedureReturn #False
    EndIf
    If Callback
      If CallFunctionFast(Callback, 100) = #UNZIP_CANCEL
        zipCloseFileInZip(ZipHandle)
        ProcedureReturn #False
      EndIf
    EndIf

    zipCloseFileInZip(ZipHandle)
    ProcedureReturn #True
  EndIf
  ProcedureReturn #False
EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
	
	
	Debug CLZIP::GetFileInfo("B:\Testpack\mss_v093.zip", 4)
	CLZIP::ExtractArchiv("B:\Testpack\mss_v093.zip", "B:\testPack")
	
CompilerEndIf
; IDE Options = PureBasic 6.00 LTS (Windows - x64)
; CursorPosition = 972
; FirstLine = 293
; Folding = DfAgA9
; EnableAsm
; EnableXP
; EnableUnicode