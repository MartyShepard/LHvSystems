;======================================================================
; Module:          Registry.pbi
;
; Author:          Thomas (ts-soft) Schulz, Martin Schäfer
; Date:            September 18, 2014
; Version:         1.4.2.1
; Target Compiler: PureBasic 5.2+
; Target OS:       Windows
; License:         Free, unrestricted, no warranty whatsoever
;                  Use at your own risk
; Target Test OS   Windows 7 (64Bit), Windows 8 (32Bit), WindowsXP (32Bit)
;======================================================================

; History:
; Version 1.4.2.2 Sep 18, 2014
; Module changed to RegEditEX
; Return Codes fixed
; + Reg File Import
; + Reg File Export (Using Original Microsoft Structure)
; DeleteTree works IN 64Bit mode on 32Bit Hive
; + Dynamic Hive Redirection
; + SubKeyExists
; Deletekey. it use only DeletKeyEX_ for Windows Version >=60
; and the old variant for Windows Version <= 53
; 

; Version 1.4.2, Jun 27, 2014
; fixed WriteValue

; Version 1.4.1, Sep 02, 2013
; fixed XP_DeleteTree()

; Version 1.4, Sep 02, 2013
; fixed Clear Resultstructure
; + compatibility to WinXP

; Version 1.3.3, Sep 01, 2013
; + Clear Resultstructure

; Version 1.3.2, Aug 31, 2013
; fixed a Bug with WriteValue and Unicode

; Version 1.3.1, Aug 30, 2013
; + DeleteTree() ; Deletes the subkeys and values of the specified key recursively.

; Version 1.3, Aug 30, 2013
; + ErrorString to RegValue Structure
; + RegValue to all Functions
; RegValue holds Errornumber and Errorstring!
; Renamed CountValues to CountSubValues

; Version 1.2.1, Aug 25, 2013
; source length reduced with macros

; Version 1.2, Aug 25, 2013
; + CountSubKeys()
; + CountValues()
; + ListSubKey()
; + ListSubValue()
; + updated example
;
; Version 1.1, Aug 25, 2013
; + ReadValue for #REG_BINARY returns a comma separate string with hexvalues (limited to 2096 bytes)
; + small example


;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;    
DeclareModule RegEditEX
        
     Structure RegValue
        TYPE.l                                                      ; like: #REG_BINARY, #REG_DWORD ...
        SIZE.l
        ERROR.l
        ERRORSTR.s
        DWORD.l                                                     ; #REG_DWORD
        QWORD.q                                                     ; #REG_QWORD
        *BINARY                                                     ; #REG_BINARY
        STRING.s                                                    ; #REG_EXPAND_SZ, #REG_MULTI_SZ, #REG_SZ
    EndStructure   
        
    Enumeration -1 Step -1
        #REG_ERR_ALLOCATE_MEMORY
        #REG_ERR_BINARYPOINTER_MISSING
        #REG_ERR_REGVALUE_VAR_MISSING
    EndEnumeration
    
    #LH_REGISTRYFILE=303
    Declare.i GetErrorCode()
    Declare.s GetErrorMsg()
    
    
    Structure REGTOPKEYANDNAME
        HKEY.q
        LKEY.s
    EndStructure 
    Global NewList _HLREG.REGTOPKEYANDNAME()
    
    
    Declare.i ReadType(topKey,              ; like #HKEY_LOCAL_MACHINE, #HKEY_CURRENT_USER, #HKEY_CLASSES_ROOT ...
                       KeyName.s,           ; KeyName without topKey
                       ValueName.s = "",    ; ValueName, "" for Default
                       WOW64 = #False,      ; If #TRUE, uses the 'Wow6432Node' path for Key
                       *Ret.RegValue = 0)   ; result 0 = error or #REG_NONE (not supported)
    
    Declare.s ReadValue(topKey,KeyName.s,ValueName.s = "",WOW64 = #False,*Ret.RegValue = 0,FileExport=0)    
        
    Declare.i WriteValue(topKey,
                         KeyName.s,
                         ValueName.s,
                         Value.s,           ; Value as string
                         Type.l,            ; Type like: #REG_DWORD, #REG_EXPAND_SZ, #REG_SZ
                         WOW64 = #False,
                         *Ret.RegValue = 0, ; to return more infos, is required for #REG_BINARY!
                         HEX7=0)            ; Nur in Verbindung mit hex(7):

    ; result 0 = error, > 0 = successfull (1 = key created, 2 = key opened)
 

    Declare.i CreateSubKey(topKey, SubKeyName.s ,WOW64 = #False, *Ret.RegValue = 0)
    
    Declare.i DeleteTree(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
    Declare.i DeleteKey(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
    Declare.i DeleteValue(topKey, KeyName.s, ValueName.s, WOW64 = #False, *Ret.RegValue = 0)
    
    Declare.i CountSubKeys(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
    Declare.i CountSubValues(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
 
    Declare.s ListSubKey(topKey, KeyName.s, index, WOW64 = #False, *Ret.RegValue = 0)       ; the index is 0-based! 
    Declare.s ListSubValue(topKey, KeyName.s, index, WOW64 = #False, *Ret.RegValue = 0) 
    
    Declare.i SubKeyExists(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
    
    Declare.i FileImport(RegistryFile$, WOW64 = #False) 
    Declare.i FileExport(RegistryFile$, ManagedKeyPath$,WOW64 = #False)
    
    Declare.s WindowsVersion(iSelect=0)  
    
    Declare.i ConvertKey(Key.s,List _HLREG.REGTOPKEYANDNAME())
    Declare.s ChangeSubK(SubKeyPath$)
    Declare.s ChangeManK(ManagePath$)
    Declare.l FileImport_Kodierung(RegistryFile$)
    
    ;Der Export keyPath auf 64Bit System wird ohne \WOW6432Node\ geschrieben, Kann man sich aber anpassen ;)
    
EndDeclareModule
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;    
Module RegEditEX         
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;  
        
  Prototype RegDeleteKeyEXW(hKey.i, lpSubKey.p-Unicode, samDesired.l, Reserved.l = 0)
  Prototype RegSetValueEXW(hKey.i, lpValueName.p-Unicode, Reserved.l, dwType.l, *lpData, cbData.l)
  Prototype RegDeleteTreeW(hKey.i, lpSubKey.p-Unicode = 0)    
  
  Global RegDeleteKeyEXW.RegDeleteKeyEXW
  Global RegSetValueEXW.RegSetValueEXW
  Global RegDeleteTreeW.RegDeleteTreeW
  
  Structure KEY_ITEM_COUNT
    KeyNames.l
    KeyPaths.l
  EndStructure

  Structure KEYS_NAME
    KeyValueID.l
    KeyName.s
    KeyData.s
  EndStructure

  Structure PATH_NAME
    KeyValueID.l
    KeyName.s
    KeyFullPath.s
  EndStructure
  
  Structure RegBasic
      HexString$
  EndStructure   
  
  Structure tChar
      StructureUnion
          c.c
          s.s { 1 }
      EndStructureUnion
  EndStructure
  
  Structure FILEIMPORT_KEYS
    KeySectionName$
    KeySection$
  EndStructure
  
  Global NewList HexBasic.s()
  Global NewList RegBasic.RegBasic()        
  Global NewList FullKeyPath.PATH_NAME()                          ; Alle gefundenen Dateien mit kompletten Pfad
  Global NewList FullKeyName.KEYS_NAME() 
  Global KEYCOUNT.KEY_ITEM_COUNT

     
  Structure REGCODES
          ERROR.l
          ERRORSTR.s
  EndStructure
  Global NewList RegCodes.REGCODES()
        AddElement(RegCodes()): RegCodes()\ERROR = 0
        AddElement(RegCodes()): RegCodes()\ERRORSTR.s = ""
  
  Define Advapi32dll.i
  
  Advapi32dll = OpenLibrary(#PB_Any, "Advapi32.dll")
  If Advapi32dll
    RegDeleteKeyEXW  = GetFunction(Advapi32dll, "RegDeleteKeyExW")
    RegSetValueEXW   = GetFunction(Advapi32dll, "RegSetValueExW")
    RegDeleteTreeW   = GetFunction(Advapi32dll, "RegDeleteTreeW")
  EndIf 

  #KEY_WOW64_64KEY = $100
  #KEY_WOW64_32KEY = $200
  
  Macro OpenKey()
        If  #PB_Processor_x64
            If WOW64 = #True
                samDesired | #KEY_WOW64_64KEY
            Else
                samDesired | #KEY_WOW64_32KEY
            EndIf  
        Else
            samDesired | #KEY_WOW64_32KEY
        EndIf
   
        If Left(KeyName, 1) = "\"  : KeyName = Right(KeyName, Len(KeyName) - 1) : EndIf
        If Right(KeyName, 1) = "\" : KeyName = Left(KeyName, Len(KeyName) - 1)  : EndIf
   
        If *Ret <> 0: ClearStructure(*Ret, RegValue): EndIf
   
        error = RegOpenKeyEx_(topKey, KeyName, 0, samDesired, @hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            If hKey: RegCloseKey_(hKey): EndIf
            ProcedureReturn error
        EndIf
  EndMacro 
  
  Macro OpenKeyS()
        If  #PB_Processor_x64
            If WOW64 = #True
                samDesired | #KEY_WOW64_64KEY
            Else
                samDesired | #KEY_WOW64_32KEY
            EndIf  
        Else
            samDesired | #KEY_WOW64_32KEY
        EndIf  
   
        If Left(KeyName, 1) = "\"  : KeyName = Right(KeyName, Len(KeyName) - 1) : EndIf
        If Right(KeyName, 1) = "\" : KeyName = Left(KeyName, Len(KeyName) - 1)  : EndIf
   
        If *Ret <> 0: ClearStructure(*Ret, RegValue): EndIf
   
        error = RegOpenKeyEx_(topKey, KeyName, 0, samDesired, @hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            If hKey: RegCloseKey_(hKey): EndIf
            ProcedureReturn ""
        EndIf
 EndMacro 
 
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
; 
    Procedure.l Hex2Dec(h$)
        h$=UCase(h$)
        
        For r=1 To Len(h$)
            d<<4
            a$=Mid(h$,r,1)
            If Asc(a$)>60
                d+Asc(a$)-55
            Else
                d+Asc(a$)-48
            EndIf
        Next: ProcedureReturn d
    EndProcedure   
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;    
    Procedure.s Hex2Asc(AscString$)     
        Protected Convertet$ = "", i, InHex$,AscLenghLength=Len(AscString$)
        
        For i = 1 To AscLenghLength Step 1 
            InMid$ = Mid(AscString$, i, 1)
            
            InAscL = Asc(InMid$)   
            InHex$ = Hex(InAscL)
            InHex$ = InHex$+",00,"

            Convertet$ = Convertet$+InHex$
            If i = AscLenghLength-1
                Debug Convertet$ +"/Current="+i+" // Von:"+AscLenghLength
            EndIf
        Next i: ProcedureReturn Convertet$
    EndProcedure    
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;
    Procedure.s WindowsVersion(iSelect=0)
    Protected sMajor$, sMinor$, sBuild$, Version$, sPlatform$, SystemRoot$, iResult.l
    Define Os.OSVERSIONINFO
    Define WinVersion$


    Os\dwOSVersionInfoSize = SizeOf(OSVERSIONINFO)
    GetVersionEx_(@Os.OSVERSIONINFO)
    
    Select iSelect
    Case 0:
          sMajor$ = Str(Os\dwMajorVersion)
          sMinor$ = Str(Os\dwMinorVersion)
          ProcedureReturn sMajor$+sMinor$
    Case 1:
          sBuild$ = Str(Os\dwBuildNumber)
          ProcedureReturn sBuild$
    Case 2:
          sSPack$ = PeekS(@Os\szCSDVersion)
          ProcedureReturn sSPack$
    Case 4:
          sPlatform$    = Str(Os\dwPlatformId)
          sMajor$       = Str(Os\dwMajorVersion)
          sMinor$       = Str(Os\dwMinorVersion)        
          
          Version$= sPlatform$+"."+sMajor$+"."+sMinor$
          Select Version$
                  
              Case "1.0.0":     ProcedureReturn "Windows 95"
              Case "1.1.0":     ProcedureReturn "Windows 98"
              Case "1.9.0":     ProcedureReturn "Windows Millenium"
              Case "2.3.0":     ProcedureReturn "Windows NT 3.51"
              Case "2.4.0":     ProcedureReturn "Windows NT 4.0"
              Case "2.5.0":     ProcedureReturn "Windows 2000"
              Case "2.5.1":     ProcedureReturn "Windows XP"
              Case "2.5.3":     ProcedureReturn "Windows 2003 (SERVER)"
              Case "2.6.0":     ProcedureReturn "Windows Vista"
              Case "2.6.1":     ProcedureReturn "Windows 7"
              Case "2.6.2":     ProcedureReturn "Windows 8"             ;Build 9200                 
              Default:          ProcedureReturn "Unknown"
          EndSelect
          
      Case 5:
          If ExamineEnvironmentVariables()
              While NextEnvironmentVariable()
                  SystemRoot$ = EnvironmentVariableName()
                  If (LCase(SystemRoot$)="systemroot")
                      ProcedureReturn EnvironmentVariableValue() 
                          
                  EndIf
              Wend
          EndIf
          
      Case 6:
          If ExamineEnvironmentVariables()
               While NextEnvironmentVariable()
                  SystemRoot$ = EnvironmentVariableName()
                  If (LCase(SystemRoot$)="systemroot")
                      
                      iResult = FileSize(SystemRoot$+"SYSWOW64\")
                      If (iResult = -2)                        
                          ProcedureReturn EnvironmentVariableValue()+"\SYSWOW64\"
                      Else
                          ProcedureReturn EnvironmentVariableValue()+"\SYSTEM32\"
                      EndIf                                                
                  EndIf
              Wend
          EndIf          
                      
    EndSelect
    
      ;-----------------------------------------------------------------------------------------------        
      ; Get_WindowsVersion(iSelect=0), Holt die Aktuelle Windows Version, via iSelect lässt sich
      ; mehrere Information zurückgeben
      ; iSelect=5 gibt das Windows Root Verzeichnis Zurück
      ; iSelect=6 gibt das Windows System Verzeichnis Zurück
      ;-----------------------------------------------------------------------------------------------    
EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
; 
    Procedure HiveFSRedirection(samDesired,WOW64)
   If  #PB_Processor_x64
        If WOW64 = #True
            ProcedureReturn samDesired | #KEY_WOW64_64KEY
        Else
            ProcedureReturn samDesired | #KEY_WOW64_32KEY
        EndIf   
    Else
      ProcedureReturn samDesired | #KEY_WOW64_32KEY
    EndIf  
    EndProcedure   
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;       
    Procedure.s GetLastErrorStr(error)
        Protected Buffer.i, result.s
   
            If FormatMessage_(#FORMAT_MESSAGE_ALLOCATE_BUFFER | #FORMAT_MESSAGE_FROM_SYSTEM, 0, error, 0, @Buffer, 0, 0)
            result = PeekS(Buffer)
            LocalFree_(Buffer)

            SelectElement(RegCodes(),0)
            RegCodes()\ERROR = error
            SelectElement(RegCodes(),1)
            RegCodes()\ERRORSTR = result

      ProcedureReturn result
    EndIf
  EndProcedure  
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;                                                                                              
    Procedure.i GetErrorCode(): SelectElement(RegCodes(),0): ProcedureReturn Regcodes()\ERROR: EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;  
    Procedure.s GetErrorMsg(): SelectElement(RegCodes(),1): ProcedureReturn Regcodes()\ERRORSTR: EndProcedure           
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;          
    Procedure CreateSubKey(topKey, SubKeyName.s ,WOW64 = #False, *Ret.RegValue = 0)
        
        Protected error, lpSecurityAttributes.SECURITY_ATTRIBUTES, hKey, create,samDesired = #KEY_ALL_ACCESS

        samDesired = HiveFSRedirection(samDesired,WOW64)  
               
        error = RegCreateKeyEx_(topKey, SubKeyName, 0, 0, #REG_OPTION_NON_VOLATILE, samDesired, @lpSecurityAttributes, @hKey, @create)
        If *Ret <> 0
           *Ret\ERROR = error
           *Ret\ERRORSTR = GetLastErrorStr(error)
        EndIf
        GetLastErrorStr(error)    
        If hKey: RegCloseKey_(hKey): EndIf: ProcedureReturn createKey         
    EndProcedure    
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;     
    Procedure.i XP_DeleteTree(topKey, KeyName.s,WOW64, *RET.RegValue = 0)
           
        Protected hKey, error, dwSize.l, sBuf.s = Space(260), samDesired = #KEY_ENUMERATE_SUB_KEYS 
        
        samDesired = samDesired|HiveFSRedirection(samDesired,WOW64)
        
        ;OpenKey()
        If Left(KeyName, 1) = "\"  : KeyName = Right(KeyName, Len(KeyName) - 1) : EndIf
        If Right(KeyName, 1) = "\" : KeyName = Left(KeyName, Len(KeyName) - 1)  : EndIf
   
        If *Ret <> 0: ClearStructure(*Ret, RegValue): EndIf
        
        error = RegOpenKeyEx_(topKey, @KeyName, 0, samDesired, @hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            
            If hKey: RegCloseKey_(hKey): EndIf: ProcedureReturn #False
        EndIf
        
       
        Repeat
            dwSize.l = 260
            error = RegEnumKeyEx_(hKey, 0, @sBuf, @dwSize, 0, 0, 0, 0)
            If Not error
                XP_DeleteTree(hKey, sBuf,WOW64,0)
                ProcedureReturn error
            EndIf
        Until error
        
        RegCloseKey_(hKey)
        error = RegDeleteKey_(topKey, KeyName)         
            If error 
                If *Ret <> 0
                    *Ret\ERROR = error
                    *Ret\ERRORSTR = GetLastErrorStr(error)
                EndIf
                GetLastErrorStr(error)
                ProcedureReturn #False
            EndIf
            GetLastErrorStr(error)
            ProcedureReturn #True   
  EndProcedure      
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;      
    Procedure.i DeleteTree(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_ALL_ACCESS
        Protected hKey
        Protected SubKeyToRemove$
        
        samDesired = samDesired|HiveFSRedirection(samDesired,WOW64)

        
        If RegDeleteTree = 0
            
            error = XP_DeleteTree(topKey, KeyName,samDesired, *RET)
            If error = 0
                ProcedureReturn XP_DeleteTree(topKey, KeyName,samDesired, *RET)
            EndIf                
        EndIf
   
        OpenKey()
   
        error = RegDeleteTreeW(hKey)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            ProcedureReturn #False
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn #True   
    EndProcedure   
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;   
    Procedure.i DeleteKey(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_WRITE, WinVersion.i
   
        samDesired = HiveFSRedirection(samDesired,WOW64)
   
        If Left(KeyName, 1) = "\"  : KeyName = Right(KeyName, Len(KeyName) - 1) : EndIf
        If Right(KeyName, 1) = "\" : KeyName = Left(KeyName, Len(KeyName) - 1)  : EndIf
   
        WinVersion.i = Val(WindowsVersion())
        If (WinVersion.i >= 60)
            error = RegDeleteKeyEXW(topKey, KeyName, samDesired)
        ElseIf (WinVersion.i <= 53)
            error = RegDeleteKey_(topKey, KeyName) 
        EndIf
        
        If error
            If *Ret <> 0
                ClearStructure(*Ret, RegValue)
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            ProcedureReturn #False
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn #True
    EndProcedure  
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;   
    Procedure.i DeleteValue(topKey, KeyName.s, ValueName.s, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_WRITE
        Protected hKey
   
        OpenKey()
   
        error = RegDeleteValue_(hKey, ValueName)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): ProcedureReturn #False
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn #True         
    EndProcedure     
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
; 
    Procedure.i CountSubKeys(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_READ
        Protected hKey, count
   
        OpenKey()
   
        error = RegQueryInfoKey_(hKey, 0, 0, 0, @count, 0, 0, 0, 0, 0, 0, 0)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): ProcedureReturn #False
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn count
    EndProcedure    
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
; 
    Procedure.s ListSubKey(topKey, KeyName.s, index, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_READ
        Protected hKey, size, result.s
   
        OpenKeyS()
   
        error = RegQueryInfoKey_(hKey, 0, 0, 0, 0, @size, 0, 0, 0, 0, 0, 0)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            RegCloseKey_(hKey): ProcedureReturn ""
        EndIf
        
        size + 1
        result = Space(size)
        error = RegEnumKeyEx_(hKey, index, @result, @size, 0, 0, 0, 0)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): ProcedureReturn ""
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn result   
    EndProcedure    
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;  
    Procedure.i CountSubValues(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_READ
        Protected hKey, count
   
        OpenKey()
   
        error = RegQueryInfoKey_(hKey, 0, 0, 0, 0, 0, 0, @count, 0, 0, 0, 0)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): ProcedureReturn #False
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn count
    EndProcedure   
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;   
    Procedure.s ListSubValue(topKey, KeyName.s, index, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_READ
        Protected hKey, size, result.s
   
        OpenKeyS()
   
        error = RegQueryInfoKey_(hKey, 0, 0, 0, 0, 0, 0, 0, @size, 0, 0, 0)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            RegCloseKey_(hKey): ProcedureReturn ""
        EndIf
        
        size + 1
        result = Space(size)
        error = RegEnumValue_(hKey, index, @result, @size, 0, 0, 0, 0)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): ProcedureReturn ""
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn result   
    EndProcedure       
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;    
    Procedure.i ReadType(topKey, KeyName.s, ValueName.s = "", WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_READ
        Protected hKey, lpType
   
        OpenKey()
   
        error = RegQueryValueEx_(hKey, ValueName, 0, @lpType, 0, 0)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            ProcedureReturn #False
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn lpType                
    EndProcedure  
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure.s ReadValue(topKey, KeyName.s, ValueName.s = "", WOW64 = #False, *Ret.RegValue = 0,FileExport=0)                
        Protected error, result.s, samDesired = #KEY_READ
        Protected hKey, lpType.l, *lpData , lpcbData.l, ExSZlength, *ExSZMem, i,bufferSize

        
        OpenKeyS()
   
        error = RegQueryValueEx_(hKey, ValueName, 0, 0, 0, @lpcbData)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): RegCloseKey_(hKey): ProcedureReturn ""
        EndIf
   
        If lpcbData
            *lpData = AllocateMemory(lpcbData)
            If *lpData = 0
                If *Ret <> 0
                    *Ret\ERROR = #REG_ERR_ALLOCATE_MEMORY
                    *Ret\ERRORSTR = "Error: Can't allocate memory"
                EndIf
                SelectElement(RegCodes(),0): RegCodes()\ERROR = #REG_ERR_ALLOCATE_MEMORY
                SelectElement(RegCodes(),1): RegCodes()\ERRORSTR = "Error: Can't allocate memory"
                RegCloseKey_(hKey): ProcedureReturn ""
            EndIf
        EndIf
        
                   lpcbData = 1024 
                   lpData.s = Space(1024) 
                   
        error = RegQueryValueEx_(hKey, ValueName, 0, @lpType, *lpData, @lpcbData)
        RegCloseKey_(hKey)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error): FreeMemory(*lpData): ProcedureReturn ""
        EndIf   
   
        If *Ret <> 0: *Ret\TYPE = lpType: EndIf
   
        Select lpType
            Case #REG_BINARY
                If lpcbData <= 2096
                    For i = 0 To lpcbData - 1
                        result + "$" + RSet(Hex(PeekA(*lpData + i)), 2, "0") + ","
                    Next
                Else
                    
                    For i = 0 To 2095
                        result + "$" + RSet(Hex(PeekA(*lpData + i)), 2, "0") + ","
                    Next
                EndIf
                result = Left(result, Len(result) - 1)
                
                If *Ret <> 0: *Ret\BINARY = *lpData: *Ret\SIZE = lpcbData :EndIf: ProcedureReturn result ; we don't free the memory!
       
            Case #REG_DWORD
                If *Ret <> 0
                    *Ret\DWORD = PeekL(*lpData)
                    *Ret\SIZE = SizeOf(Long)
                EndIf
                If FileExport=0
                    result = Str(PeekL(*lpData))
                EndIf
                If FileExport=1
                    result = Str(PeekL(*lpData))
                    iLenght = Len(result)
                    If (iLenght = 1)
                        result = "dword:0000000"+Str(PeekL(*lpData))
                     ElseIf (iLenght = 2)
                        result = "dword:000000"+Str(PeekL(*lpData))
                     ElseIf (iLenght = 3)
                        result = "dword:00000"+Str(PeekL(*lpData))                        
                     ElseIf (iLenght = 4)
                        result = "dword:0000"+Str(PeekL(*lpData))                        
                     ElseIf (iLenght = 5)
                        result = "dword:000"+Str(PeekL(*lpData))                        
                     ElseIf (iLenght = 6)
                        result = "dword:00"+Str(PeekL(*lpData))                        
                     ElseIf (iLenght = 7)
                        result = "dword:0"+Str(PeekL(*lpData))                        
                    EndIf
                      
                EndIf
       
            Case #REG_EXPAND_SZ
                ExSZlength = ExpandEnvironmentStrings_(*lpData, 0, 0)
                If ExSZlength > 0
                    *ExSZMem = AllocateMemory(ExSZlength)
                    If *ExSZMem
                        If ExpandEnvironmentStrings_(*lpData, *ExSZMem, ExSZlength)
                            result = PeekS(*ExSZMem)
                            If *Ret <> 0
                                *Ret\STRING = result
                                *Ret\SIZE = Len(result)
                            EndIf
                        EndIf
                        FreeMemory(*ExSZMem)
                    EndIf
                Else
                Debug "Error: Can't allocate memory"
                EndIf
       
            Case #REG_MULTI_SZ
                While i < lpcbData
                    If PeekS(*lpData + i, 1) = ""
                        result + #LF$
                    Else
                        result + PeekS(*lpData + i, 1)
                    EndIf
                    i + SizeOf(Character)
                Wend
                
                If Right(result, 1) = #LF$
                    result = Left(result, Len(result) - 1)
                EndIf
                If *Ret <> 0: *Ret\STRING = result
                    *RET\SIZE = Len(result)
                EndIf
       
            Case #REG_QWORD
                If *Ret <> 0
                    *RET\QWORD = PeekQ(*lpData)
                    *RET\SIZE = SizeOf(Quad)
                EndIf
                result = Str(PeekQ(*lpData))

       
              Case #REG_SZ
                  
                If (*lpData <> 0)
                  result = PeekS(*lpData,*lpData)
                EndIf
                If *Ret <> 0
                    *RET\STRING = result
                    *RET\SIZE = SizeOf(result)
                EndIf
                
        EndSelect
        If (*lpData <> 0)
          FreeMemory(*lpData)
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn result
    EndProcedure    
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;    
    Procedure.i WriteValue(topKey, KeyName.s, ValueName.s, Value.s, Type.l, WOW64 = #False, *Ret.RegValue = 0,HEX7=0)
        Protected error, samDesired = #KEY_WRITE
        Protected hKey, *lpData, lpcbData.q, count, create, i, tmp.s, pos, temp1.l, temp2.q
   
        samDesired = HiveFSRedirection(samDesired,WOW64)  
   
        If Left(KeyName, 1) = "\"  : KeyName = Right(KeyName, Len(KeyName) - 1) : EndIf
        If Right(KeyName, 1) = "\" : KeyName = Left(KeyName, Len(KeyName) - 1)  : EndIf
   
        If *Ret <> 0
            If Type <> #REG_BINARY
                ClearStructure(*Ret, RegValue)
            Else
                *Ret\TYPE = 0
                *Ret\ERROR = 0
                *Ret\ERRORSTR = ""
                *Ret\DWORD = 0
                *Ret\QWORD = 0
                *Ret\STRING = ""
            EndIf
        EndIf
   
        error = RegCreateKeyEx_(topKey, KeyName, 0, 0, 0, samDesired, 0, @hKey, @create)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            If hKey: RegCloseKey_(hKey): EndIf: ProcedureReturn #False
        EndIf
   
        Select Type
            Case #REG_BINARY
                
                BufferLength=Len(Value.s)/2
                If BufferLength       
                    
                  *RegBuffer=AllocateMemory(BufferLength)
                      For n=0 To BufferLength-1
                          
                          OctetHexa.s=Mid(Value.s,(n*2)+1,2)
                          Octet=Hex2Dec(OctetHexa)
                          
                          PokeB(*RegBuffer+n,Octet)
                      Next
                      
                      error= RegSetValueEx_(hKey,ValueName,0,#REG_BINARY,*RegBuffer,BufferLength)
                      If error
                        If *Ret <> 0
                            *Ret\ERROR = error
                            *Ret\ERRORSTR = GetLastErrorStr(error)
                        EndIf
                       EndIf
                       GetLastErrorStr(error)
                      FreeMemory(*RegBuffer)
                  EndIf
                  
;                 If *Ret = 0
;                     If *Ret <> 0
;                         *Ret\ERROR = #REG_ERR_REGVALUE_VAR_MISSING
;                         *Ret\ERRORSTR = "Error: Required *Ret.RegValue parameter not found!"
;                     EndIf
;                     SelectElement(RegCodes(),0): RegCodes()\ERROR = #REG_ERR_REGVALUE_VAR_MISSING
;                     SelectElement(RegCodes(),1): RegCodes()\ERRORSTR = "Error: Required *Ret.RegValue parameter not found!"
;                     RegCloseKey_(hKey): ProcedureReturn #False
;                 EndIf
;                 
;                 lpcbData = *Ret\SIZE
;                 *lpData = *Ret\BINARY
;                 If *lpData = 0
;                     If *Ret <> 0
;                         *Ret\ERROR = #REG_ERR_BINARYPOINTER_MISSING
;                         *Ret\ERRORSTR = "Error: No Pointer to BINARY defined!"
;                     EndIf
;                     SelectElement(RegCodes(),0): RegCodes()\ERROR = #REG_ERR_BINARYPOINTER_MISSING
;                     SelectElement(RegCodes(),1): RegCodes()\ERRORSTR = "Error: No Pointer to BINARY defined!" 
;                     RegCloseKey_(hKey): ProcedureReturn #False         
;                 EndIf
;                   If lpcbData = 0:lpcbData = MemorySize(*lpData):EndIf                
;                   error = RegSetValueEx_(hKey, ValueName, 0, #REG_BINARY, *lpData, lpcbData)
       
            Case #REG_DWORD
                temp1 = Val(Value)
                error = RegSetValueEx_(hKey, ValueName, 0, #REG_DWORD, @temp1, 4)
       
            Case #REG_QWORD
                temp2 = Val(Value)
                error = RegSetValueEx_(hKey, ValueName, 0, #REG_QWORD, @temp2, 8)
       
            Case #REG_EXPAND_SZ
                CompilerIf #PB_Compiler_Unicode 
                    error = RegSetValueEx_(hKey, ValueName, 0, Type, @Value, StringByteLength(Value) + SizeOf(Character)*2 +1)
                CompilerElse
                    error = RegSetValueEx_(hKey, ValueName, 0, Type, @Value, StringByteLength(Value) + SizeOf(Character))
                CompilerEndIf
                
            Case #REG_SZ
                Debug ""
               
                CompilerIf #PB_Compiler_Unicode 
                    error = RegSetValueEx_(hKey, ValueName, 0, Type, @Value, StringByteLength(Value) + SizeOf(Character)*2 +1)
                CompilerElse
                    error = RegSetValueEx_(hKey, ValueName, 0, Type, @Value, StringByteLength(Value) + SizeOf(Character))
                CompilerEndIf

                
            Case #REG_MULTI_SZ
                X = Len(Value): Debug "REG_MULTI_SZ Länge: "+X
                If (HEX7=1)
                    HexAsc$ = ""
                    For i = 1 To X Step 2
                        HexAsc$ = HexAsc$ + Chr(Val("$"+Mid(Value, i, 2)))
                    
                    Next i 
                    Debug "REG_MULTI_SZ HEX(7): Original:"+ Value+#CRLF$+"REG_MULTI_SZ HEX(7): Übersetzt:"+ HexAsc$
                    Value = HexAsc$
                EndIf
                
                count = CountString(Value, #LF$)
                For i = 0 To count
                    tmp = StringField(Value, i + 1, #LF$)
                    lpcbData + StringByteLength(tmp, #PB_Unicode) + 2
                Next
                
                If lpcbData
                    *lpData = AllocateMemory(lpcbData)
                    If *lpData
                        For i = 0 To count
                            tmp = StringField(Value, i + 1, #LF$)
                            PokeS(*lpData + pos, tmp, -1, #PB_Unicode)
                            pos + StringByteLength(tmp, #PB_Unicode) + 1
                        Next
                        error = RegSetValueEXW(hKey, ValueName, 0, Type, *lpData, lpcbData)
                        FreeMemory(*lpData)
                    Else
                        If *Ret <> 0
                            *Ret\ERROR = #REG_ERR_ALLOCATE_MEMORY
                            *Ret\ERRORSTR = "Error: Can't allocate memory"
                        EndIf
                        SelectElement(RegCodes(),0): RegCodes()\ERROR = #REG_ERR_ALLOCATE_MEMORY
                        SelectElement(RegCodes(),1): RegCodes()\ERRORSTR = "Error: Can't allocate memory"
                        RegCloseKey_(hKey): ProcedureReturn #False           
                    EndIf
                EndIf       
            EndSelect
   
            RegCloseKey_(hKey)
            If error
                If *Ret <> 0
                    *Ret\ERROR = error
                    *Ret\ERRORSTR = GetLastErrorStr(error)
                EndIf
                GetLastErrorStr(error): ProcedureReturn #False
            EndIf
            GetLastErrorStr(error)
            ProcedureReturn create         
        EndProcedure         
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;
    Procedure.i SubKeyExists(topKey, KeyName.s, WOW64 = #False, *Ret.RegValue = 0)
        Protected error, samDesired = #KEY_READ
        Protected hKey, lpType, hKeyLabel
   
        OpenKey()
   
        error = RegOpenKeyEx_(hKey, ValueName, 0, samDesired, @hKeyLabel)
        RegCloseKey_(hKeyLabel)
        If error
            If *Ret <> 0
                *Ret\ERROR = error
                *Ret\ERRORSTR = GetLastErrorStr(error)
            EndIf
            GetLastErrorStr(error)
            ProcedureReturn error
        EndIf
        GetLastErrorStr(error)
        ProcedureReturn error                
    EndProcedure         
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;
    Procedure.i ConvertRegKey2TopAndKeyName(key$)
        Protected iPos.i
        
        Structure RegConverted
            TopKey.q
            Keyname$
        EndStructure
        
        Global NewList RegConverted.RegConverted()
        
        AddElement(RegConverted()): RegConverted()\TopKey.q = 0
        AddElement(RegConverted()): RegConverted()\Keyname$ = ""    
        
        iPos = FindString(key$,"HKEY_CLASSES_ROOT\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_CLASSES_ROOT
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_CLASSES_ROOT\","")
            ProcedureReturn
        EndIf 
        
        iPos = FindString(key$,"HKEY_CURRENT_CONFIG\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_CURRENT_CONFIG
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_CURRENT_CONFIG\","")
            ProcedureReturn
        EndIf            
        
        iPos = FindString(key$,"HKEY_CURRENT_USER\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_CURRENT_USER
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_CURRENT_USER\","")
            ProcedureReturn
        EndIf
        
        iPos = FindString(key$,"HKEY_DYN_DATA\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_DYN_DATA
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_DYN_DATA\","")
            ProcedureReturn
        EndIf
        
        iPos = FindString(key$,"HKEY_LOCAL_MACHINE\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_LOCAL_MACHINE
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_LOCAL_MACHINE\","")
            ProcedureReturn
        EndIf
        
        iPos = FindString(key$,"HKEY_PERFORMANCE_DATA\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_PERFORMANCE_DATA
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_PERFORMANCE_DATA\","")
            ProcedureReturn
        EndIf
        
        iPos = FindString(key$,"HKEY_USERS\")    
        If iPos <> 0
            SelectElement(RegConverted(),0): RegConverted()\TopKey = #HKEY_USERS
            SelectElement(RegConverted(),1)
            RegConverted()\Keyname$ = ReplaceString(key$,"HKEY_USERS\","")
            ProcedureReturn
        EndIf
        Debug "Unknown: "+ key$
    EndProcedure 
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
; 
    Procedure FileImport_GetTypes(iSection$,iSectionsKey$,iRegistryFile$,Stringformat.l,topKey,WOW64=#False)
        
        Protected StrLng, iValue$, iDatas$, iResult, iErrorCode, DWordPos, HexPos, StrSlash, iBreak, iLIneTC$
        
        iSection$ = ReplaceString(iSection$,Chr(34),"")
        
        HexPos = FindString(iSection$,"hex(7):",1)  
         If HexPos <> 0
            StrLng = Len(iSection$)

            StrSlash = FindString(iSection$,"\",StrLng)
            If StrSlash <> 0
                iDatas$ = ""
                iBreak = #False
                If OpenFile(0,iRegistryFile$)
                    If ReadFile(0, iRegistryFile$)                 
                        
                        While Eof(0) = 0           
                            iLIneTC$ = ReadString(0, Stringformat)
                            iLIneTC$ = ReplaceString(iLIneTC$,Chr(34),"")
                            iLIneLng = Len(iLIneTC$)
                            
                            If (iSection$ = iLIneTC$)
                                iDatas$ = iLIneTC$
                                
                                While Eof(0) = 0                
                                    iLIneTC$ = ReadString(0, Stringformat)
                                    iLIneTC$ = ReplaceString(iLIneTC$,Chr(34),"")
                                    iLIneLng = Len(iLIneTC$)               
                                    iDatas$ = iDatas$+Trim(iLIneTC$)
                                    
                                    If (Len(iLIneTC$) = 0): iBreak = #True: Break
                                    EndIf                          
                                    If (FindString(iLIneTC$,",\",iLIneLng-1) = 0)
                                        iBreak = #True
                                        Break
                                    EndIf
                                Wend
                            EndIf
                            If (iBreak = #True)
                                iSection$ = ReplaceString(iDatas$,Chr(92),"")
                                StrLng = Len(iSection$)
                                Break
                            EndIf
                        Wend
                    EndIf
                EndIf
                CloseFile(0)
            EndIf   
            
            iValue$ = Left(iSection$,HexPos-2)
            iDatas$ = Mid(iSection$,HexPos)
            iDatas$ = ReplaceString(iDatas$,"hex(7):","")
            iDatas$ = ReplaceString(iDatas$,Chr(44),"")
            
            WriteValue(topKey, iSectionsKey$, iValue$, iDatas$,#REG_MULTI_SZ, WOW64,0,1)
            GetErrorMsg(): ProcedureReturn
        
        EndIf        
        
        HexPos = FindString(iSection$,"hex:",1)        
        If HexPos <> 0
            StrLng = Len(iSection$)
            StrSlash = FindString(iSection$,"\",StrLng)
            If StrSlash <> 0
                iDatas$ = ""
                iBreak = #False
                If OpenFile(0,iRegistryFile$)
                    If ReadFile(0, iRegistryFile$)                 
                        
                        While Eof(0) = 0           
                            iLIneTC$ = ReadString(0, Stringformat)
                            iLIneTC$ = ReplaceString(iLIneTC$,Chr(34),"")
                            iLIneLng = Len(iLIneTC$)
                            
                            If (iSection$ = iLIneTC$)
                                iDatas$ = iLIneTC$
                                
                                While Eof(0) = 0                
                                    iLIneTC$ = ReadString(0, Stringformat):
                                    iLIneTC$ = ReplaceString(iLIneTC$,Chr(34),"")
                                    iLIneLng = Len(iLIneTC$)               
                                    iDatas$ = iDatas$+Trim(iLIneTC$)
                                    
                                    If (Len(iLIneTC$) = 0): iBreak = #True: Break
                                    EndIf                          
                                    If (FindString(iLIneTC$,",\",iLIneLng-1) = 0)
                                        iBreak = #True
                                        Break
                                    EndIf
                                Wend
                            EndIf
                            If (iBreak = #True)
                                iSection$ = ReplaceString(iDatas$,Chr(92),"")
                                StrLng = Len(iSection$)
                                Break
                            EndIf
                        Wend
                    EndIf
                EndIf
                CloseFile(0)
            EndIf   
            
            iValue$ = Left(iSection$,HexPos-2)
            iDatas$ = Mid(iSection$,HexPos)
            iDatas$ = ReplaceString(iDatas$,"hex:","")
            iDatas$ = ReplaceString(iDatas$,Chr(44),"")
            
            WriteValue(topKey, iSectionsKey$, iValue$, iDatas$,#REG_BINARY, WOW64)
            GetErrorMsg(): ProcedureReturn
        
        Else
            DWordPos = FindString(iSection$,"dword:",1)
            If DWordPos <> 0
                StrLng = Len(iSection$)
                
                iValue$ = Left(iSection$,DWordPos-2): iDatas$ = Mid(iSection$,DWordPos)      
                iDatas$ = ReplaceString(iDatas$,"dword:",""): iDatasL = Val("$"+iDatas$)
                
                WriteValue(topKey, iSectionsKey$, iValue$, Str(iDatasL),#REG_DWORD, WOW64)
                GetErrorMsg(): ProcedureReturn
                
            Else
                StrPos = FindString(iSection$,"=",1)
                If StrPos <> 0
                    StrLng = Len(iSection$)
                    
                    iValue$ = Left(iSection$,StrPos-1)
                    If Chr(64) = iValue$: iValue$ = "": EndIf
                    
                    iDatas$ = Mid(iSection$,StrPos+1): iDatas$ = ReplaceString(iDatas$,"\\","\")    
                    
                    iValue$ = Trim(iValue$)
                    iDatas$ = Trim(iDatas$)
                    
                    WriteValue(topKey, iSectionsKey$, iValue$, iDatas$,#REG_SZ, WOW64)
                    GetErrorMsg(): ProcedureReturn
                EndIf
            EndIf
        EndIf       
    EndProcedure  
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;
    Procedure FileImport_GetSectionsNames(path.s, List OutList.FILEIMPORT_KEYS(),Stringformat)
   
        If OpenFile(0,path.s)
            If ReadFile(0, path.s)                 
                
                While Eof(0) = 0           
                    iSection$ = ReadString(0, Stringformat)
                    iSectLeng = Len(iSection$)
                    
                    If FindString(iSection$,"[",1) And FindString(iSection$,"]",iSectLeng)
                        iSection$ = Mid(iSection$,2,iSectLeng-2)
                        If FindString(iSection$,"wow6432node\",1, #PB_String_NoCase)
                            iSection$ = ReplaceString(iSection$,"wow6432node\","", #PB_String_NoCase,1)
                            
                        EndIf
                        AddElement(OutList()):OutList()\KeySectionName$ = iSection$                       
                    EndIf
                    
                    If FindString(iSection$,"=",2) And Not FindString(iSection$,"]",iSectLeng) And Not FindString(iSection$,"[",1)
                        AddElement(OutList()):OutList()\KeySection$ = iSection$
                    EndIf
                Wend
            EndIf
            
        EndIf
        CloseFile(0)
    EndProcedure

;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure.l FileImport_Kodierung(RegistryFile$)
        
        If ReadFile(0, RegistryFile$)
            ; BOM schreibe
            PB_Stringformat = ReadStringFormat(0)
            
            Select PB_Stringformat
                Case #PB_Ascii   : CloseFile(0):Debug "RegistryFile Format: (ASCII): "+#PB_Ascii
                    ProcedureReturn #PB_Ascii       
                Case #PB_UTF8    : CloseFile(0):Debug "RegistryFile Format: EF BB BF (UTF8): "+#PB_UTF8
                    ProcedureReturn #PB_UTF8        
                Case #PB_Unicode : CloseFile(0):Debug "RegistryFile Format: FF FE (Unicode): "+#PB_Unicode
                    ProcedureReturn #PB_Unicode 
                Case #PB_UTF16BE : CloseFile(0):Debug "RegistryFile Format: FE FF (UTF16BE): "+#PB_UTF16BE   
                    ProcedureReturn #PB_UTF16BE
                Case #PB_UTF32   : CloseFile(0):Debug "RegistryFile Format: FF FE 00 00 (UTF32): "+#PB_UTF32
                    ProcedureReturn #PB_UTF32
                Case #PB_UTF32BE : CloseFile(0)
                    ProcedureReturn #PB_UTF32BE:Debug "RegistryFile Format: 00 00 FE FF (PB_UTF32BE): "+#PB_UTF32BE
            EndSelect          
            CloseFile(0)
        EndIf 
        Debug "RegistryFile Format: (Fehler)"
        ProcedureReturn 0
    EndProcedure  
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure FileImport(RegistryFile$, WOW64=#False)        
        Protected Position.i, Size.i, HKey.q, SKey.s,Stringformat.l

        Global NewList KeySectionsNames.FILEIMPORT_KEYS()
        
        Stringformat = FileImport_Kodierung(RegistryFile$)

        Size.i = FileSize(RegistryFile$)
        If (Size.i <> 0) Or (Size.i <> -1) 
            
            FileImport_GetSectionsNames(RegistryFile$, KeySectionsNames.FILEIMPORT_KEYS(),Stringformat.l)
            
            ResetList(KeySectionsNames())
            While NextElement(KeySectionsNames())
              
              iSectioName$  = KeySectionsNames()\KeySectionName$
              iSection$     = KeySectionsNames()\KeySection$
              
              If (Len(iSectioName$) <> 0)
                    Debug #CRLF$+"Erstelle Section: ["+iSectioName$+"]"
                    ConvertRegKey2TopAndKeyName(iSectioName$)
                    SelectElement(RegConverted(),0): HKey.q = Regconverted()\TopKey.q
                    SelectElement(RegConverted(),1): SKey.s = Regconverted()\Keyname$
                    FreeList(RegConverted())
                    CreateSubKey(HKey.q,  SKey.s ,WOW64)
                    
              EndIf
              If (Len(iSection$) <> 0)
                    Debug "Füge Daten ein: "+iSection$
                    FileImport_GetTypes(iSection$,SKey.s,RegistryFile$,Stringformat.l,HKey.q,WOW64)
                    
              EndIf
              
            Wend
        EndIf
        
        FreeList(KeySectionsNames())
    EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;       
    Procedure FileExport_CRLF(File$)
        Debug "FileExport_CRLF File: "+File$        
        If OpenFile(#LH_REGISTRYFILE,File$)
            FileSeek(#LH_REGISTRYFILE, Lof(#LH_REGISTRYFILE))
            WriteStringN(#LH_REGISTRYFILE, "",#PB_UTF32)
            CloseFile(#LH_REGISTRYFILE)
        EndIf
    EndProcedure 
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;       
    Procedure FileExport_SECT(File$,RegistryData$)
        Debug "FileExport_SECT File: "+File$+" // "+RegistryData$
        If OpenFile(#LH_REGISTRYFILE,File$)
            FileSeek(#LH_REGISTRYFILE, Lof(#LH_REGISTRYFILE))
            WriteStringN(#LH_REGISTRYFILE, RegistryData$,#PB_UTF32)
            CloseFile(#LH_REGISTRYFILE)
        EndIf
    EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;     
    Procedure FileExport_SPLT(sText.s , nCharsPerLine.w , List HexBasic.s())
        Protected nLines  .l           = Len ( sText ) / nCharsPerLine
        Protected *Source .tChar       = @ sText
        Protected lCounter.l
        
        
        If Not *Source: ProcedureReturn #False: EndIf
        
        AddElement ( HexBasic () )
        
        While *Source\c
            If nCharsPerLine -1 < lCounter And *Source\s = Chr(44) 
                AddElement ( HexBasic () )
                lCounter = 0         
            EndIf
            HexBasic() + *Source\s
            lCounter + 1
            *Source  + SizeOf ( CHARACTER )
        Wend
        ProcedureReturn #True
        
        ;Len(Value)*2 + 1) 
        
    EndProcedure 
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;     
    Procedure FileExport_HEX7(List HexBasic.s(), List RegBasic.RegBasic())
        Protected HexString$, iPos, NewHexString$
        ForEach HexBasic()                
            HexString$ = HexBasic()
            iPos = FindString(HexString$,",",1)
            
            If Not (iPos = 1)
                AddElement(RegBasic()):RegBasic()\HexString$ = HexString$+",\"        
            EndIf
            
            If (iPos = 1)
                Length = Len(HexString$)
                NewHexString$ = Mid(HexString$,2,Length-1)            
                NewHexString$ = "  "+NewHexString$+",\"
                AddElement(RegBasic()):RegBasic()\HexString$ = NewHexString$
            EndIf         
        Next 
        
        ResetList(RegBasic())
        If LastElement(RegBasic()) <> 0
            NewHexString$ = RegBasic()\HexString$
            Length = Len(NewHexString$)
            NewHexString$ = Mid(NewHexString$,0,Length-2)  
            RegBasic()\HexString$ = NewHexString$
        EndIf

        ProcedureReturn #True
    EndProcedure    
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure FileExport_ADD(KeyName$,ManagedPath$,IndexID.i,Count.i)
        If Len(KeyName$) = 0 :ProcedureReturn #False: EndIf 
        
        ResetList(FullKeyPath())
        If ListSize(FullKeyPath()) = 0 
                   
        Else
            ResetList(FullKeyPath())
            While NextElement(FullKeyPath())
                If (FullKeyPath()\KeyName = KeyName$)
                  ProcedureReturn #False
                EndIf
            Wend
        EndIf
                
        AddElement(FullKeyPath())
          FullKeyPath()\KeyValueID  = IndexID.i
          FullKeyPath()\KeyName     = KeyName$
          FullKeyPath()\KeyFullPath = ManagedPath$+KeyName$ 
          ;Debug Str(IndexID.i)+"/"+Count+" ["+ManagedPath$+KeyName$+"]" 
        ProcedureReturn #True
      EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure FileExport_COUT(HKey.q, SKey.s,WOW64,ManagedPath$)
      Protected cout, iPos, i, KeyName$, iResult
      Debug "FileExport_COUT /Path: "+SKey.s
      
      If Right(SKey.s, 1) = "\" :SKey.s = Left(SKey.s, Len(SKey.s) - 1)  : EndIf
          
      ManagedPath$ = ReplaceString(ManagedPath$,SKey.s,"")
      If Right(ManagedPath$, 2) = "\\"
          ManagedPath$ = Left(ManagedPath$, Len(ManagedPath$) - 1)
      EndIf
      
      Cout = CountSubKeys(HKey.q, SKey.s,WOW64)
      For i = 0 To Cout - 1
        
        If  Cout <> 0      
          KeyName$ = ListSubKey(HKey.q, SKey.s,i,WOW64)
          
          If Len(KeyName$) <> 0
            
 
                SKey.s = SKey.s+"\"+KeyName$

            
            iResult = FileExport_ADD(SKey.s,ManagedPath$,i,Cout)
            If iResult = 1
              FileExport_COUT(HKey.q, SKey.s,WOW64,ManagedPath$)
            EndIf  
          EndIf

          SKey.s = ReverseString(SKey.s)
          iPos = FindString(SKey.s,"\",1)
          SKey.s  = Mid(SKey.s,iPOs+1,Len(SKey.s))
          SKey.s = ReverseString(SKey.s)
        EndIf         
      Next
 EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;
    Procedure FileExport_PREP(File$,ManagedKeyPath$,WOW64,RegistryFile$)
      Protected cout, iPos, iPosHex, h, i, KeyName$, KeyData$, HKey.q,LKey.s,Key_Type
      ConvertRegKey2TopAndKeyName(ManagedKeyPath$)
      
      SelectElement(RegConverted(),0): HKey.q = Regconverted()\TopKey.q
      SelectElement(RegConverted(),1): LKey.s = Regconverted()\Keyname$
      ClearList(RegConverted()):FreeList(RegConverted())
      
      FileExport_CRLF(RegistryFile$)
      FileExport_SECT(RegistryFile$,"["+ManagedKeyPath$+"]")
      
      cout = CountSubValues(HKey.q, LKey.s,WOW64)
      If cout <> 0
        For i = 0 To Cout - 1
          KeyName$ = ListSubValue(HKey.q, LKey.s, i, WOW64)
          KeyData$ = ReadValue(HKey.q, LKey.s, KeyName$, WOW64,0,1)
          Key_Type = ReadType(HKey.q, LKey.s, KeyName$, WOW64)
          
          Select Key_Type
            Case #REG_SZ, #REG_EXPAND_SZ  :Debug #CRLF$+"Key Type: REG_SZ/ REG_EXPAND_SZ"
            Case #REG_DWORD               :Debug #CRLF$+"Key Type: REG_DWORD"
            Case #REG_QWORD               :Debug #CRLF$+"Key Type: REG_QWORD"
            Case #REG_BINARY              :Debug #CRLF$+"Key Type: REG_BINARY"
            Case #REG_MULTI_SZ            :Debug #CRLF$+"Key Type: REG_MULTI_SZ"
            Case #REG_NONE                :Debug #CRLF$+"Key Type: REG_NONE"
            Default                       :Debug #CRLF$+"Key Type: REG_@"
          EndSelect
          Debug "Key-Path :"+LKey.s+#CRLF$+"Key-Name :"+KeyName$+#CRLF$+"Key-Data :"+KeyData$
          

          If (Len(KeyName$) <> 0) And (Len(KeyData$) <> 0)
              KeyName$ = Chr(34)+KeyName$+Chr(34)
              
              Select Key_Type
                  ;-----------------------------------------------------------------------------
                  ; Exportiere #REG_SZ, #REG_EXPAND_SZ  
                  ;_____________________________________________________________________________                      
                  Case #REG_SZ, #REG_EXPAND_SZ          
                      KeyData$ = Chr(34)+KeyData$+Chr(34)
                      KeyData$ = ReplaceString(KeyData$,"\","\\",1)
                      FileExport_SECT(RegistryFile$,KeyName$+"="+KeyData$)
                      
                  ;-----------------------------------------------------------------------------
                  ; Exportiere DWORD
                  ;_____________________________________________________________________________
                  Case #REG_DWORD
                      KeyData$ = KeyData$
                      If FindString(KeyData$,"dword:",1,#PB_String_CaseSensitive) = 0
                          
                          If Len(KeyData$) <= 9
                              KeyData$ = "dword:0"+UCase(Hex(Val(KeyData$)))
                          Else
                              KeyData$ = "dword:"+UCase(Hex(Val(KeyData$)))
                          EndIf
                      EndIf
                          
                      FileExport_SECT(RegistryFile$,KeyName$+"="+KeyData$)
                  ;-----------------------------------------------------------------------------
                  ; Exportiere QWORD
                  ;_____________________________________________________________________________                      
                  Case #REG_QWORD                    
                  ;-----------------------------------------------------------------------------
                  ; Exportiere BINARY
                  ;_____________________________________________________________________________                      
                  Case #REG_BINARY
                          h = CountString(KeyData$,"$")
                          Repeat
                              KeyData$ = ReplaceString(KeyData$,"$","")
                              h = CountString(KeyData$,"$")
                          Until h = 0
                          KeyData$ = "hex:"+KeyData$: KeyData$ = LCase(KeyData$)
                          FileExport_SECT(RegistryFile$,KeyName$+"="+KeyData$)
                  ;-----------------------------------------------------------------------------
                  ; Exportiere #REG_MULTI_SZ
                  ;_____________________________________________________________________________                         
                  Case #REG_MULTI_SZ
                      
                        Convertet$ = Hex2Asc(KeyData$)
                        Convertet$ = LCase(Convertet$+"00,00")    
                        If Len(KeyName$+"=hex(7):") >= 80
                            FileExport_SPLT(KeyName$+"=hex(7):"+Convertet$ , 74 , HexBasic())
                        Else
                            FileExport_SPLT(KeyName$+"=hex(7):"+Convertet$ , 75 , HexBasic())
                        EndIf
                        FileExport_HEX7(HexBasic.s(),RegBasic.RegBasic())   
                        
                        ResetList(RegBasic())
                        ForEach RegBasic()
                             FileExport_SECT(RegistryFile$,RegBasic()\HexString$)
                        Next
                        ClearList(RegBasic()):ClearList(HexBasic.s())
                  ;-----------------------------------------------------------------------------
                  ; Exportiere #REG_NONE, @
                  ;_____________________________________________________________________________                          
                  Case #REG_NONE
                      
                  Default
                      If (Len(KeyName$) = 0) And (Len(KeyData$) <> 0)
                          KeyName$ = "@"
                          KeyData$ = Chr(34)+KeyData$+Chr(34)
                      Else
                          If (Len(KeyName$) = 0) And (Len(KeyData$) = 0)
                              KeyName$ = "@"
                              KeyData$ = Chr(34)+""+Chr(34)
                          EndIf
                      EndIf
                      FileExport_SECT(RegistryFile$,KeyName$+"="+KeyData$)
              EndSelect
          EndIf
        Next
      EndIf
     EndProcedure
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure FileExport(RegistryFile$,ManagedKeyPath$,WOW64=#False) 
        Protected iSubKeys.i, HKey.q, SKey.s, KeyName$, iMax
        
        Debug "Export Registry: "+RegistryFile$
        
          If OpenFile(#LH_REGISTRYFILE,RegistryFile$)            
              WriteStringN(#LH_REGISTRYFILE, "Windows Registry Editor Version 5.00",#PB_UTF32)
              CloseFile(#LH_REGISTRYFILE)
          EndIf
               
          ConvertRegKey2TopAndKeyName(ManagedKeyPath$)
                
          SelectElement(RegConverted(),0): HKey.q = Regconverted()\TopKey.q
          SelectElement(RegConverted(),1): SKey.s = Regconverted()\Keyname$
          FreeList(RegConverted()) 
          
          iMax = ListSize(FullKeyPath())
          If iMax <> 0: ClearList(FullKeyPath()):EndIf
          
          FileExport_PREP(File$,ManagedKeyPath$,WOW64,RegistryFile$)         
          FileExport_COUT(HKey.q, SKey.s,WOW64,ManagedKeyPath$)
          
          ResetList(FullKeyPath())
          While NextElement(FullKeyPath())           
               FileExport_PREP(File$,FullKeyPath()\KeyFullPath,WOW64,RegistryFile$)
          Wend
          FileExport_CRLF(RegistryFile$)
          FreeList(RegConverted())
      EndProcedure
       
;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
;         
    Procedure.i ConvertKey(Key.s,List _HLREG.REGTOPKEYANDNAME())
 
        Protected topKey,KeyName.s, liMax, temp$, PositionSlash
 
        temp$ =StringField(Key,1,"\")
        temp$ =UCase(temp$)
        
        
        
        liMax = ListIndex(_HLREG()): If (liMax<>0): ClearList(_HLREG()):EndIf  
        
        AddElement(_HLREG()): _HLREG()\HKEY.q = 0
        AddElement(_HLREG()): _HLREG()\LKEY.s = "" 
        
        Select temp$
            Case "HKEY_CLASSES_ROOT"
                SelectElement(_HLREG(),0): _HLREG()\HKEY.q = #HKEY_CLASSES_ROOT
                
            Case "HKEY_CURRENT_USER"
                SelectElement(_HLREG(),0): _HLREG()\HKEY.q = #HKEY_CURRENT_USER
                
            Case "HKEY_LOCAL_MACHINE"
                SelectElement(_HLREG(),0): _HLREG()\HKEY.q = #HKEY_LOCAL_MACHINE                
                
            Case "HKEY_USERS"
                SelectElement(_HLREG(),0): _HLREG()\HKEY.q = #HKEY_USERS                    
                
            Case "HKEY_CURRENT_CONFIG"
                SelectElement(_HLREG(),0): _HLREG()\HKEY.q = #HKEY_CURRENT_CONFIG                  
        EndSelect
        
        PositionSlash=FindString(Key,"\",1)
        SelectElement(_HLREG(),0): _HLREG()\LKEY.s = Right(Key,(Len(Key)-PositionSlash))        
        ProcedureReturn
 
    EndProcedure 
    
    
    ;///////////////////////////////////////////////////////////////////////////////////////////////
    ; Remove all Backslahs from Subkey 
    ; 
    Procedure.s ChangeSubK(SubKeyPath$)
        
        Protected cout
        
        Repeat
            cout = 0
            If Right(SubKeyPath$, 1) = "\"
                cout = 1
                SubKeyPath$ = Left(SubKeyPath$, Len(SubKeyPath$) - 1)          
            EndIf
        Until cout = 0
        
        Repeat
            cout = 0
            If Left(SubKeyPath$, 1) = "\"
                cout = 1
                SubKeyPath$ = Mid(SubKeyPath$, 2, Len(SubKeyPath$) - 1)          
            EndIf
        Until cout = 0   
        
        
        ProcedureReturn SubKeyPath$
    EndProcedure    
    
    ;///////////////////////////////////////////////////////////////////////////////////////////////
    ; Korrgiere den Managekey 
    ; 
    Procedure.s ChangeManK(ManagePath$)
        Protected cout
        Repeat
            cout = 0
            If Right(ManagePath$, 1) = "\"
                cout = 1
                ManagePath$ = Left(ManagePath$, Len(ManagePath$) - 1)          
            EndIf
        Until cout = 0
        ProcedureReturn ManagePath$    
    EndProcedure
EndModule  

;/////////////////////////////////////////////////////////////////////////////////////////
CompilerIf #PB_Compiler_IsMainFile
    
; Commands
; 
; RegEditEX::ReadType(HighKey.i,LowKey$, ValueName.s, WOW64 = #False/#True)
; RegeditEX::ReadValue(HighKey.i,LowKey$,ValueName.s, WOW64 = #False/#True,0,0)
; 
; RegEditEX::WriteValue(HighKey.i,LowKey$, ValueName.s,Value.s,Type.l,WOW64 = #False/#True)
; RegEditEX::CreateSubKey(HighKey.i,LowKey$)
; 
; RegEditEX::DeleteTree(HighKey.i,LowKey$, WOW64 = #False/#True)
; RegEditEX::DeleteKey(HighKey.i,LowKey$, WOW64 = #False/#True)
; RegEditEX::DeleteValue(HighKey.i,LowKey$, ValueName.s, WOW64 = #False/#True)
; 
; RegEditEX::CountSubKeys(HighKey.i,LowKey$, WOW64 = #False/#True)
;RegEditEX::CountSubValues(HighKey.i,LowKey$, WOW64 = #False/#True)
; 
; RegEditEX::ListSubKey(HighKey, LowKey$.s, index, WOW64 = #False/#True) 
; RegEditEX::ListSubValue(HighKey, LowKey$.s, index, WOW64 = #False/#True) 
; 
; RegEditEX::FileImport(RegistryFile$, WOW64 = #False/False)
; RegEditEX::FileExport(RegistryFile$, ManagedKeyPath$,WOW64 = #False/False)

; Die Hive Redirection läuft voll Automatisch. Sobald sich DAS programm auf einem 32Bit Basierten System befindet
; hat der WOW64 = #False/#True Redirection Wert keine Bedeutung mehr und alle Keys werden normal IN dem 32Bit Baum  
; bearbeitet. WOW64 = #False/#True Wert funktioniert NUR auf 64Bit Systemen 
; 
; Beispiele, Bitte auskommentieren , Successfully  Testet WindowsXP (32Bit), Windows 7 (64Bit), Windows 8 (32Bit)
; MessageRequester("","Key Wird Erstellt (64Bit Hive) :HKEY_LOCAL_MACHINE\Software\Test64Bit")
; RegEditEX::CreateSubKey(#HKEY_LOCAL_MACHINE,"Software\Test64Bit",#True)
; MessageRequester("",RegEditEX::GetErrorMsg())
; 
; MessageRequester("","Key Wird Erstellt (32Bit Hive) :HKEY_LOCAL_MACHINE\Software\Test32Bit")
; RegEditEX::CreateSubKey(#HKEY_LOCAL_MACHINE,"Software\Test32Bit")
; MessageRequester("",RegEditEX::GetErrorMsg())
; 
; MessageRequester("","Überprüfe Key (64Bit Hive) :HKEY_LOCAL_MACHINE\Software\Test64Bit")
; RegEditEX::SubKeyExists(#HKEY_LOCAL_MACHINE, "Software\Test64Bit",#True)
; MessageRequester("",RegEditEX::GetErrorMsg())
; 
; MessageRequester("","Überprüfe Key (32Bit Hive) :HKEY_LOCAL_MACHINE\Software\Test64Bit (Fehler muss erscheinen)")
; RegEditEX::SubKeyExists(#HKEY_LOCAL_MACHINE, "Software\Test64Bit")
; MessageRequester("",RegEditEX::GetErrorMsg())
; 
; MessageRequester("","Lösche Key (64Bit Hive) :HKEY_LOCAL_MACHINE\Software\Test64Bit")
; RegEditEX::DeleteKey(#HKEY_LOCAL_MACHINE, "Software\Test64Bit",#True)  
; MessageRequester("",RegEditEX::GetErrorMsg())
; 
; MessageRequester("","Lösche Key (32Bit Hive) :HKEY_LOCAL_MACHINE\Software\Test32Bit")
; RegEditEX::DeleteKey(#HKEY_LOCAL_MACHINE, "Software\Test32Bit")  
; MessageRequester("",RegEditEX::GetErrorMsg())
; 
; MessageRequester("","LIste und Zähle Keys auf (32Bit Hive) DisplayName/DisplayVersion"+#CRLF$+sSubKey$ )
    sSubKey$ = "SOFTWARE\Epic Games\Unreal Engine\builds"
    iView$ = ""
    count = RegEditEX::CountSubValues(#HKEY_CURRENT_USER, sSubKey$)
    For i = 0 To count - 1
      Ordner$ = RegEditEX::ListSubValue(#HKEY_CURRENT_USER, sSubKey$, i)
      Debug Ordner$
      ;DisplayName$ = RegEditEX::ReadValue(#HKEY_LOCAL_MACHINE,sSubKey$+Ordner$+"\","DisplayName")
      ;DisplayVers$ = RegEditEX::ReadValue(#HKEY_LOCAL_MACHINE,sSubKey$+Ordner$+"\","DisplayVersion")      
      ;If (Len(DisplayName$) <> 0) And (Len(DisplayVers$) <> 0)
         ; iView$ = iView$+Str(i)+"/"+Str(count)+" ["+DisplayName$+"  ;  "+DisplayVers$+"]"+#CRLF$
          ;iPos = FindString(UCase(DisplayName$),"AURORA",1)
          ;If iPos <> 0
              ;iView$ =  Str(i)+"/"+Str(count)+" ["+DisplayName$+"  ;  "+DisplayVers$+"]"
      ;iView$ = iView$+Str(i)+"/"+Str(count)+" ["+DisplayName$+"  ;  "+DisplayVers$+"]"+#CRLF$
         ;EndIf
      ;EndIf

  Next
  
    Debug "=============================================="
    ;sSubKey$ = "SOFTWARE\Epic Games\Unreal Engine\build"
    iView$ = ""
    count = RegEditEX::CountSubKeys(#HKEY_CURRENT_USER, sSubKey$)
    For i = 0 To count - 1
      Ordner$ = RegEditEX::ListSubKey(#HKEY_CURRENT_USER, sSubKey$, i)
      Debug Ordner$
      ;DisplayName$ = RegEditEX::ReadValue(#HKEY_LOCAL_MACHINE,sSubKey$+Ordner$+"\","DisplayName")
      ;DisplayVers$ = RegEditEX::ReadValue(#HKEY_LOCAL_MACHINE,sSubKey$+Ordner$+"\","DisplayVersion")      
      ;If (Len(DisplayName$) <> 0) And (Len(DisplayVers$) <> 0)
         ; iView$ = iView$+Str(i)+"/"+Str(count)+" ["+DisplayName$+"  ;  "+DisplayVers$+"]"+#CRLF$
          ;iPos = FindString(UCase(DisplayName$),"AURORA",1)
          ;If iPos <> 0
              ;iView$ =  Str(i)+"/"+Str(count)+" ["+DisplayName$+"  ;  "+DisplayVers$+"]"
      ;iView$ = iView$+Str(i)+"/"+Str(count)+" ["+DisplayName$+"  ;  "+DisplayVers$+"]"+#CRLF$
         ;EndIf
      ;EndIf

    Next
   ; MessageRequester("",iView$)
;     
;     MessageRequester("","Exportiere 'HKEY_LOCAL_MACHINE\SOFTWARE\Adobe' Nach C:\Adobe.Reg vom 32Bit Hive")
;     RegEditEX::FileExport("C:\AdobeExport.reg","HKEY_LOCAL_MACHINE\SOFTWARE\Adobe")
;     
;     MessageRequester("", "Import aus Spass C:\AdobeExport.reg nach 'HKEY_LOCAL_MACHINE\SOFTWARE\Adobe' in den 64Bit Hive")
;     RegEditEX::FileImport("C:\AdobeExport.reg")
;     
;     MessageRequester("","Löche den Baum 'HKEY_LOCAL_MACHINE\SOFTWARE\Adobe' (64Bit Hive)")
;     RegEditEX::DeleteTree(#HKEY_LOCAL_MACHINE,"SOFTWARE\Adobe")
;     If RegEditEX::GetErrorCode() = 2
;         RegEditEX::DeleteKey(#HKEY_LOCAL_MACHINE, "SOFTWARE\Adobe",#True)
;     EndIf
;     MessageRequester("",RegEditEX::GetErrorMsg())
;    
;RegEditEX::FileExport("C:\D3d.reg","HKEY_LOCAL_MACHINE\SOFTWARE\United Software\Final Demand\"):Delay(25)
;RegEditEX::FileImport("C:\D3d.reg")
;RegEditEX::FileImport("N:\AdobeExport.reg")
;RegEditEX::FileImport("N:\! Source Projects\LH Game Start\INCLUDES_CLS\Test_Regmultisz.reg")
CompilerEndIf
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 1761
; FirstLine = 1050
; Folding = Hewz-B5-
; EnableAsm
; EnableXP
; Executable = Test_Regestry.exe
; EnableUnicode