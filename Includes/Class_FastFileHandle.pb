CompilerIf #PB_Compiler_IsMainFile
    UsePNGImageDecoder()    

 CompilerEndIf
                                                                                                                             ;

 DeclareModule FFH
   
        ; Diloage
        Declare.s GetFilePath(Title.s = "", InitialPath.s = "",NewDialog = #True,NoDir = #False ,BrowseIncludeFiles = #True, Extension$ = "*",CSIDL = #PB_Default)
        Declare.s GetFilePBRQ(Title.s,InitialPath.s = "", Save = #False,Extension$ = "Alle Dateien (*.*)|*.*;", ExtensionDefault = 0, MultiSelect = #False)
        Declare.s GetPathPBRQ(Title.s,InitialPath.s = "")
        Declare.i SHOpenWithDialog_(File$ = "",OPEN_AS_INFO_FLAGS.l = 0)        
        
        ; Processe
        Declare.i ShellExec(lpFilePath$ = "",Verb$ = "",Paramter$ = "", Mask = #Null, ExShow.i = #SW_SHOWNORMAL, shAdmin.i = #False, Simple = 1)
        
        ; Downloads
        ; Declare.i GetFileDownload(File$ = "")
        Declare.i WinApi_DownloadFile(Url.s, TargetPath.s)
        Declare.i CheckURL(URL.s)

        ; Path's
        Declare.s GetClSIDPath(FOLDERID_CLSID)
        Declare.s GetClSIDVariable(Path$) 
        Declare.s SetClSIDVariable(Path$)        
        Declare.i ForceCreateDirectories(Path$)        
        Declare.i CreateShortenedPath(GadgetID.L, Path.S, Handle.l, OptString$ = "")
        Declare   PathPartsExt(sText.s, List CharList.s(), sChar$ = Chr(92))
        
        Declare.i GetDriveTypCheck(Drive$)
                
        ; Copy, Move, Delete
        Declare.i SHFileOp_(File$, Function.l = #FO_DELETE, Flags.l = #FOF_ALLOWUNDO |#FOF_NOCONFIRMATION | #FOF_SILENT	)        
        Declare.i Copy(Array sources.s(1), Array dest.s(1), title.s = "", hWnd = 0, flags = #FOF_NOCONFIRMATION | #FOF_NOCONFIRMMKDIR | #FOF_NOERRORUI)
        Declare.i Move(Array sources.s(1), Array dest.s(1), title.s = "", hWnd = 0, flags = #FOF_NOCONFIRMATION | #FOF_NOCONFIRMMKDIR | #FOF_NOERRORUI)
        Declare.i Delete(Array sources.s(1), title.s = "", hWnd = 0, flags = #FOF_NOCONFIRMATION | #FOF_NOERRORUI)
        Declare.i Delete_ShFileOP(From$="",Dest$="",SHFunction.l=#Null,ShFlags.l=#Null)
        
        ; Clipboard Stuff
        Declare.i SetClipBoard(Array sources.s(1),FlagEffect.i = #DROPEFFECT_COPY)
        Declare.s GetClipBoard()
        Declare.i IsClipBoard()
        Declare.i GetClipboardFormat()
        
        ; Keyboard
        Declare.s CheckKeyShortcut(Text.s, Mode.i = -1, okAscii.s = "", OkMaxAwd = -1)
        
        ; Strings
        Declare SHAutoComplete(GadgetID.i, FileHistory = #False, PathHistory = #False, UrlHistory = #False, Flags.l = 0)
        
        ; Text File
        Declare.i DeleteLine(iFileID,sFileName.s,iDelLineNum.i)
 DataSection
         FOLDERID_NetworkFolder: ; {D20BEEC4-5CA8-4905-AE3B-BF251EA09B53}
         Data.l $D20BEEC4
         Data.w $5CA8,$4905
         Data.b $AE,$3B,$BF,$25,$1E,$A0,$9B,$53
         
         FOLDERID_ComputerFolder: ; {0AC0837C-BBF8-452A-850D-79D08E667CA7}
         Data.l $0AC0837C
         Data.w $BBF8,$452A
         Data.b $85,$0D,$79,$D0,$8E,$66,$7C,$A7
         
         FOLDERID_InternetFolder: ; {4D9F7874-4E0C-4904-967B-40B0D20C3E4B}
         Data.l $4D9F7874
         Data.w $4E0C,$4904
         Data.b $96,$7B,$40,$B0,$D2,$0C,$3E,$4B
         
         FOLDERID_ControlPanelFolder: ; {82A74AEB-AEB4-465C-A014-D097EE346D63}
         Data.l $82A74AEB
         Data.w $AEB4,$465C
         Data.b $A0,$14,$D0,$97,$EE,$34,$6D,$63
         
         FOLDERID_PrintersFolder: ; {76FC4E2D-D6AD-4519-A663-37BD56068185}
         Data.l $76FC4E2D
         Data.w $D6AD,$4519
         Data.b $A6,$63,$37,$BD,$56,$06,$81,$85
         
         FOLDERID_SyncManagerFolder: ; {43668BF8-C14E-49B2-97C9-747784D784B7}
         Data.l $43668BF8
         Data.w $C14E,$49B2
         Data.b $97,$C9,$74,$77,$84,$D7,$84,$B7
         
         FOLDERID_SyncSetupFolder: ; {0F214138-B1D3-4A90-BBA9-27CBC0C5389A}
         Data.l $F214138
         Data.w $B1D3,$4A90
         Data.b $BB,$A9,$27,$CB,$C0,$C5,$38,$9A
         
         FOLDERID_ConflictFolder: ; {4BFEFB45-347D-4006-A5BE-AC0CB0567192}
         Data.l $4BFEFB45
         Data.w $347D,$4006
         Data.b $A5,$BE,$AC,$0C,$B0,$56,$71,$92
         
         FOLDERID_SyncResultsFolder: ; {289A9A43-BE44-4057-A41B-587A76D7E7F9}
         Data.l $289A9A43
         Data.w $BE44,$4057
         Data.b $A4,$1B,$58,$7A,$76,$D7,$E7,$F9
         
         FOLDERID_RecycleBinFolder: ; {B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC}
         Data.l $B7534046
         Data.w $3ECB,$4C18
         Data.b $BE,$4E,$64,$CD,$4C,$B7,$D6,$AC
         
         FOLDERID_ConnectionsFolder: ; {6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD}
         Data.l $6F0CD92B
         Data.w $2E97,$45D1
         Data.b $88,$FF,$B0,$D1,$86,$B8,$DE,$DD
         
         FOLDERID_Fonts: ; {FD228CB7-AE11-4AE3-864C-16F3910AB8FE}
         Data.l $FD228CB7
         Data.w $AE11,$4AE3
         Data.b $86,$4C,$16,$F3,$91,$0A,$B8,$FE
         
         FOLDERID_Desktop: ; {B4BFCC3A-DB2C-424C-B029-7FE99A87C641}
         Data.l $B4BFCC3A
         Data.w $DB2C,$424C
         Data.b $B0,$29,$7F,$E9,$9A,$87,$C6,$41
         
         FOLDERID_Startup: ; {B97D20BB-F46A-4C97-BA10-5E3608430854}
         Data.l $B97D20BB
         Data.w $F46A,$4C97
         Data.b $BA,$10,$5E,$36,$08,$43,$08,$54
         
         FOLDERID_Programs: ; {A77F5D77-2E2B-44C3-A6A2-ABA601054A51}
         Data.l $A77F5D77
         Data.w $2E2B,$44C3
         Data.b $A6,$A2,$AB,$A6,$01,$05,$4A,$51
         
         FOLDERID_StartMenu: ; {625B53C3-AB48-4EC1-BA1F-A1EF4146FC19}
         Data.l $625B53C3
         Data.w $AB48,$4EC1
         Data.b $BA,$1F,$A1,$EF,$41,$46,$FC,$19
         
         FOLDERID_Recent: ; {AE50C081-EBD2-438A-8655-8A092E34987A}
         Data.l $AE50C081
         Data.w $EBD2,$438A
         Data.b $86,$55,$8A,$09,$2E,$34,$98,$7A
         
         FOLDERID_SendTo: ; {8983036C-27C0-404B-8F08-102D10DCFD74}
         Data.l $8983036C
         Data.w $27C0,$404B
         Data.b $8F,$08,$10,$2D,$10,$DC,$FD,$74
         
         FOLDERID_Documents: ; {FDD39AD0-238F-46AF-ADB4-6C85480369C7}
         Data.l $FDD39AD0
         Data.w $238F,$46AF
         Data.b $AD,$B4,$6C,$85,$48,$03,$69,$C7
         
         FOLDERID_Favorites: ; {1777F761-68AD-4D8A-87BD-30B759FA33DD}
         Data.l $1777F761
         Data.w $68AD,$4D8A
         Data.b $87,$BD,$30,$B7,$59,$FA,$33,$DD
         
         FOLDERID_NetHood: ; {C5ABBF53-E17F-4121-8900-86626FC2C973}
         Data.l $C5ABBF53
         Data.w $E17F,$4121
         Data.b $89,$00,$86,$62,$6F,$C2,$C9,$73
         
         FOLDERID_PrintHood: ; {9274BD8D-CFD1-41C3-B35E-B13F55A758F4}
         Data.l $9274BD8D
         Data.w $CFD1,$41C3
         Data.b $B3,$5E,$B1,$3F,$55,$A7,$58,$F4
         
         FOLDERID_Templates: ; {A63293E8-664E-48DB-A079-DF759E0509F7}
         Data.l $A63293E8
         Data.w $664E,$48DB
         Data.b $A0,$79,$DF,$75,$9E,$05,$09,$F7
         
         FOLDERID_CommonStartup: ; {82A5EA35-D9CD-47C5-9629-E15D2F714E6E}
         Data.l $82A5EA35
         Data.w $D9CD,$47C5
         Data.b $96,$29,$E1,$5D,$2F,$71,$4E,$6E
         
         FOLDERID_CommonPrograms: ; {0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8}
         Data.l $0139D44E
         Data.w $6AFE,$49F2
         Data.b $86,$90,$3D,$AF,$CA,$E6,$FF,$B8
         
         FOLDERID_CommonStartMenu: ; {A4115719-D62E-491D-AA7C-E74B8BE3B067}
         Data.l $A4115719
         Data.w $D62E,$491D
         Data.b $AA,$7C,$E7,$4B,$8B,$E3,$B0,$67
         
         FOLDERID_PublicDesktop: ; {C4AA340D-F20F-4863-AFEF-F87EF2E6BA25}
         Data.l $C4AA340D
         Data.w $F20F,$4863
         Data.b $AF,$EF,$F8,$7E,$F2,$E6,$BA,$25
         
         FOLDERID_ProgramData: ; {62AB5D82-FDC1-4DC3-A9DD-070D1D495D97}
         Data.l $62AB5D82
         Data.w $FDC1,$4DC3
         Data.b $A9,$DD,$07,$0D,$1D,$49,$5D,$97
         
         FOLDERID_CommonTemplates: ; {B94237E7-57AC-4347-9151-B08C6C32D1F7}
         Data.l $B94237E7
         Data.w $57AC,$4347
         Data.b $91,$51,$B0,$8C,$6C,$32,$D1,$F7
         
         FOLDERID_PublicDocuments: ; {ED4824AF-DCE4-45A8-81E2-FC7965083634}
         Data.l $ED4824AF
         Data.w $DCE4,$45A8
         Data.b $81,$E2,$FC,$79,$65,$08,$36,$34
         
         FOLDERID_RoamingAppData: ; {3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}
         Data.l $3EB685DB
         Data.w $65F9,$4CF6
         Data.b $A0,$3A,$E3,$EF,$65,$72,$9F,$3D
         
         FOLDERID_LocalAppData: ; {F1B32785-6FBA-4FCF-9D55-7B8E7F157091}
         Data.l $F1B32785
         Data.w $6FBA,$4FCF
         Data.b $9D,$55,$7B,$8E,$7F,$15,$70,$91
         
         FOLDERID_LocalAppDataLow: ; {A520A1A4-1780-4FF6-BD18-167343C5AF16}
         Data.l $A520A1A4
         Data.w $1780,$4FF6
         Data.b $BD,$18,$16,$73,$43,$C5,$AF,$16
         
         FOLDERID_InternetCache: ; {352481E8-33BE-4251-BA85-6007CAEDCF9D}
         Data.l $352481E8
         Data.w $33BE,$4251
         Data.b $BA,$85,$60,$07,$CA,$ED,$CF,$9D
         
         FOLDERID_Cookies: ; {2B0F765D-C0E9-4171-908E-08A611B84FF6}
         Data.l $2B0F765D
         Data.w $C0E9,$4171
         Data.b $90,$8E,$08,$A6,$11,$B8,$4F,$F6
         
         FOLDERID_History: ; {D9DC8A3B-B784-432E-A781-5A1130A75963}
         Data.l $D9DC8A3B
         Data.w $B784,$432E
         Data.b $A7,$81,$5A,$11,$30,$A7,$59,$63
         
         FOLDERID_System: ; {1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}
         Data.l $1AC14E77
         Data.w $02E7,$4E5D
         Data.b $B7,$44,$2E,$B1,$AE,$51,$98,$B7
         
         FOLDERID_SystemX86: ; {D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27}
         Data.l $D65231B0
         Data.w $B2F1,$4857
         Data.b $A4,$CE,$A8,$E7,$C6,$EA,$7D,$27
         
         FOLDERID_Windows: ; {F38BF404-1D43-42F2-9305-67DE0B28FC23}
         Data.l $F38BF404
         Data.w $1D43,$42F2
         Data.b $93,$05,$67,$DE,$0B,$28,$FC,$23
         
         FOLDERID_Profile: ; {5E6C858F-0E22-4760-9AFE-EA3317B67173}
         Data.l $5E6C858F
         Data.w $0E22,$4760
         Data.b $9A,$FE,$EA,$33,$17,$B6,$71,$73
         
         FOLDERID_Pictures: ; {33E28130-4E1E-4676-835A-98395C3BC3BB}
         Data.l $33E28130
         Data.w $4E1E,$4676
         Data.b $83,$5A,$98,$39,$5C,$3B,$C3,$BB
         
         FOLDERID_ProgramFilesX86: ; {7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}
         Data.l $7C5A40EF
         Data.w $A0FB,$4BFC
         Data.b $87,$4A,$C0,$F2,$E0,$B9,$FA,$8E
         
         FOLDERID_ProgramFilesCommonX86: ; {DE974D24-D9C6-4D3E-BF91-F4455120B917}
         Data.l $DE974D24
         Data.w $D9C6,$4D3E
         Data.b $BF,$91,$F4,$45,$51,$20,$B9,$17
         
         FOLDERID_ProgramFilesX64: ; {6D809377-6AF0-444B-8957-A3773F02200E}
         Data.l $6D809377
         Data.w $6AF0,$444B
         Data.b $89,$57,$A3,$77,$3F,$02,$20,$0E
         
         FOLDERID_ProgramFilesCommonX64: ; {6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D}
         Data.l $6365D5A7
         Data.w $F0D,$45E5
         Data.b $87,$F6,$D,$A5,$6B,$6A,$4F,$7D
         
         FOLDERID_ProgramFiles: ; {905E63B6-C1BF-494E-B29C-65B732D3D21A}
         Data.l $905E63B6
         Data.w $C1BF,$494E
         Data.b $B2,$9C,$65,$B7,$32,$D3,$D2,$1A
         
         FOLDERID_ProgramFilesCommon: ; {F7F1ED05-9F6D-47A2-AAAE-29D317C6F066}
         Data.l $F7F1ED05
         Data.w $9F6D,$47A2
         Data.b $AA,$AE,$29,$D3,$17,$C6,$F0,$66
         
         FOLDERID_UserProgramFiles: ; {5CD7AEE2-2219-4A67-B85D-6C9CE15660CB}
         Data.l $5CD7AEE2
         Data.w $2219,$4A67
         Data.b $B8,$5D,$6C,$9C,$E1,$56,$60,$CB
         
         FOLDERID_UserProgramFilesCommon: ; {BCBD3057-CA5C-4622-B42D-BC56DB0AE516}
         Data.l $BCBD3057
         Data.w $CA5C,$4622
         Data.b $B4,$2D,$BC,$56,$DB,$0A,$E5,$16
         
         FOLDERID_AdminTools: ; {724EF170-A42D-4FEF-9F26-B60E846FBA4F}
         Data.l $724EF170
         Data.w $A42D,$4FEF
         Data.b $9F,$26,$B6,$0E,$84,$6F,$BA,$4F
         
         FOLDERID_CommonAdminTools: ; {D0384E7D-BAC3-4797-8F14-CBA229B392B5}
         Data.l $D0384E7D
         Data.w $BAC3,$4797
         Data.b $8F,$14,$CB,$A2,$29,$B3,$92,$B5
         
         FOLDERID_Music: ; {4BD8D571-6D19-48D3-BE97-422220080E43}
         Data.l $4BD8D571
         Data.w $6D19,$48D3
         Data.b $BE,$97,$42,$22,$20,$08,$0E,$43
         
         FOLDERID_Videos: ; {18989B1D-99B5-455B-841C-AB7C74E4DDFC}
         Data.l $18989B1D
         Data.w $99B5,$455B
         Data.b $84,$1C,$AB,$7C,$74,$E4,$DD,$FC
         
         FOLDERID_Ringtones: ; {C870044B-F49E-4126-A9C3-B52A1FF411E8}
         Data.l $C870044B
         Data.w $F49E,$4126
         Data.b $A9,$C3,$B5,$2A,$1F,$F4,$11,$E8
         
         FOLDERID_PublicPictures: ; {B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5}
         Data.l $B6EBFB86
         Data.w $6907,$413C
         Data.b $9A,$F7,$4F,$C2,$AB,$F0,$7C,$C5
         
         FOLDERID_PublicMusic: ; {3214FAB5-9757-4298-BB61-92A9DEAA44FF}
         Data.l $3214FAB5
         Data.w $9757,$4298
         Data.b $BB,$61,$92,$A9,$DE,$AA,$44,$FF
         
         FOLDERID_PublicVideos: ; {2400183A-6185-49FB-A2D8-4A392A602BA3}
         Data.l $2400183A
         Data.w $6185,$49FB
         Data.b $A2,$D8,$4A,$39,$2A,$60,$2B,$A3
         
         FOLDERID_PublicRingtones: ; {E555AB60-153B-4D17-9F04-A5FE99FC15EC}
         Data.l $E555AB60
         Data.w $153B,$4D17
         Data.b $9F,$04,$A5,$FE,$99,$FC,$15,$EC
         
         FOLDERID_ResourceDir: ; {8AD10C31-2ADB-4296-A8F7-E4701232C972}
         Data.l $8AD10C31
         Data.w $2ADB,$4296
         Data.b $A8,$F7,$E4,$70,$12,$32,$C9,$72
         
         FOLDERID_LocalizedResourcesDir: ; {2A00375E-224C-49DE-B8D1-440DF7EF3DDC}
         Data.l $2A00375E
         Data.w $224C,$49DE
         Data.b $B8,$D1,$44,$0D,$F7,$EF,$3D,$DC
         
         FOLDERID_CommonOEMLinks: ; {C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D}
         Data.l $C1BAE2D0
         Data.w $10DF,$4334
         Data.b $BE,$DD,$7A,$A2,$0B,$22,$7A,$9D
         
         FOLDERID_CDBurning: ; {9E52AB10-F80D-49DF-ACB8-4330F5687855}
         Data.l $9E52AB10
         Data.w $F80D,$49DF
         Data.b $AC,$B8,$43,$30,$F5,$68,$78,$55
         
         FOLDERID_UserProfiles: ; {0762D272-C50A-4BB0-A382-697DCD729B80}
         Data.l $0762D272
         Data.w $C50A,$4BB0
         Data.b $A3,$82,$69,$7D,$CD,$72,$9B,$80
         
         FOLDERID_Playlists: ; {DE92C1C7-837F-4F69-A3BB-86E631204A23}
         Data.l $DE92C1C7
         Data.w $837F,$4F69
         Data.b $A3,$BB,$86,$E6,$31,$20,$4A,$23
         
         FOLDERID_SamplePlaylists: ; {15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5}
         Data.l $15CA69B3
         Data.w $30EE,$49C1
         Data.b $AC,$E1,$6B,$5E,$C3,$72,$AF,$B5
         
         FOLDERID_SampleMusic: ; {B250C668-F57D-4EE1-A63C-290EE7D1AA1F}
         Data.l $B250C668
         Data.w $F57D,$4EE1
         Data.b $A6,$3C,$29,$0E,$E7,$D1,$AA,$1F
         
         FOLDERID_SamplePictures: ; {C4900540-2379-4C75-844B-64E6FAF8716B}
         Data.l $C4900540
         Data.w $2379,$4C75
         Data.b $84,$4B,$64,$E6,$FA,$F8,$71,$6B
         
         FOLDERID_SampleVideos: ; {859EAD94-2E85-48AD-A71A-0969CB56A6CD}
         Data.l $859EAD94
         Data.w $2E85,$48AD
         Data.b $A7,$1A,$09,$69,$CB,$56,$A6,$CD
         
         FOLDERID_PhotoAlbums: ; {69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C}
         Data.l $69D2CF90
         Data.w $FC33,$4FB7
         Data.b $9A,$0C,$EB,$B0,$F0,$FC,$B4,$3C
         
         FOLDERID_Public: ; {DFDF76A2-C82A-4D63-906A-5644AC457385}
         Data.l $DFDF76A2
         Data.w $C82A,$4D63
         Data.b $90,$6A,$56,$44,$AC,$45,$73,$85
         
         FOLDERID_ChangeRemovePrograms: ; {DF7266AC-9274-4867-8D55-3BD661DE872D}
         Data.l $DF7266AC
         Data.w $9274,$4867
         Data.b $8D,$55,$3B,$D6,$61,$DE,$87,$2D
         
         FOLDERID_AppUpdates: ; {A305CE99-F527-492B-8B1A-7E76FA98D6E4}
         Data.l $A305CE99
         Data.w $F527,$492B
         Data.b $8B,$1A,$7E,$76,$FA,$98,$D6,$E4
         
         FOLDERID_AddNewPrograms: ; {DE61D971-5EBC-4F02-A3A9-6C82895E5C04}
         Data.l $DE61D971
         Data.w $5EBC,$4F02
         Data.b $A3,$A9,$6C,$82,$89,$5E,$5C,$04
         
         FOLDERID_Downloads: ; {374DE290-123F-4565-9164-39C4925E467B}
         Data.l $374DE290
         Data.w $123F,$4565
         Data.b $91,$64,$39,$C4,$92,$5E,$46,$7B
         
         FOLDERID_PublicDownloads: ; {3D644C9B-1FB8-4F30-9B45-F670235F79C0}
         Data.l $3D644C9B
         Data.w $1FB8,$4F30
         Data.b $9B,$45,$F6,$70,$23,$5F,$79,$C0
         
         FOLDERID_SavedSearches: ; {7D1D3A04-DEBB-4115-95CF-2F29DA2920DA}
         Data.l $7D1D3A04
         Data.w $DEBB,$4115
         Data.b $95,$CF,$2F,$29,$DA,$29,$20,$DA
         
         FOLDERID_QuickLaunch: ; {52A4F021-7B75-48A9-9F6B-4B87A210BC8F}
         Data.l $52A4F021
         Data.w $7B75,$48A9
         Data.b $9F,$6B,$4B,$87,$A2,$10,$BC,$8F
         
         FOLDERID_Contacts: ; {56784854-C6CB-462B-8169-88E350ACB882}
         Data.l $56784854
         Data.w $C6CB,$462B
         Data.b $81,$69,$88,$E3,$50,$AC,$B8,$82
         
         FOLDERID_PublicGameTasks: ; {DEBF2536-E1A8-4C59-B6A2-414586476AEA}
         Data.l $DEBF2536
         Data.w $E1A8,$4C59
         Data.b $B6,$A2,$41,$45,$86,$47,$6A,$EA
         
         FOLDERID_GameTasks: ; {054FAE61-4DD8-4787-80B6-090220C4B700}
         Data.l $54FAE61
         Data.w $4DD8,$4787
         Data.b $80,$B6,$9,$2,$20,$C4,$B7,$0
         
         FOLDERID_SavedGames: ; {4C5C32FF-BB9D-43B0-B5B4-2D72E54EAAA4}
         Data.l $4C5C32FF
         Data.w $BB9D,$43B0
         Data.b $B5,$B4,$2D,$72,$E5,$4E,$AA,$A4
         
         FOLDERID_Games: ; {CAC52C1A-B53D-4EDC-92D7-6B2E8AC19434}
         Data.l $CAC52C1A
         Data.w $B53D,$4EDC
         Data.b $92,$D7,$6B,$2E,$8A,$C1,$94,$34
         
         FOLDERID_SEARCH_MAPI: ; {98EC0E18-2098-4D44-8644-66979315A281}
         Data.l $98EC0E18
         Data.w $2098,$4D44
         Data.b $86,$44,$66,$97,$93,$15,$A2,$81
         
         FOLDERID_SEARCH_CSC: ; {EE32E446-31CA-4ABA-814F-A5EBD2FD6D5E}
         Data.l $EE32E446
         Data.w $31CA,$4ABA
         Data.b $81,$4F,$A5,$EB,$D2,$FD,$6D,$5E
         
         FOLDERID_Links: ; {BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}
         Data.l $BFB9D5E0
         Data.w $C6A9,$404C
         Data.b $B2,$B2,$AE,$6D,$B6,$AF,$49,$68
         
         FOLDERID_UsersFiles: ; {F3CE0F7C-4901-4ACC-8648-D5D44B04EF8F}
         Data.l $F3CE0F7C
         Data.w $4901,$4ACC
         Data.b $86,$48,$D5,$D4,$4B,$04,$EF,$8F
         
         FOLDERID_UsersLibraries: ; {A302545D-DEFF-464B-ABE8-61C8648D939B}
         Data.l $A302545D
         Data.w $DEFF,$464B
         Data.b $AB,$E8,$61,$C8,$64,$8D,$93,$9B
         
         FOLDERID_SearchHome: ; {190337D1-B8CA-4121-A639-6D472D16972A}
         Data.l $190337D1
         Data.w $B8CA,$4121
         Data.b $A6,$39,$6D,$47,$2D,$16,$97,$2A
         
         FOLDERID_OriginalImages: ; {2C36C0AA-5812-4B87-BFD0-4CD0DFB19B39}
         Data.l $2C36C0AA
         Data.w $5812,$4B87
         Data.b $BF,$D0,$4C,$D0,$DF,$B1,$9B,$39
         
         FOLDERID_DocumentsLibrary: ; {7B0DB17D-9CD2-4A93-9733-46CC89022E7C}
         Data.l $7B0DB17D
         Data.w $9CD2,$4A93
         Data.b $97,$33,$46,$CC,$89,$02,$2E,$7C
         
         FOLDERID_MusicLibrary: ; {2112AB0A-C86A-4FFE-A368-0DE96E47012E}
         Data.l $2112AB0A
         Data.w $C86A,$4FFE
         Data.b $A3,$68,$D,$E9,$6E,$47,$1,$2E
         
         FOLDERID_PicturesLibrary: ; {A990AE9F-A03B-4E80-94BC-9912D7504104}
         Data.l $A990AE9F
         Data.w $A03B,$4E80
         Data.b $94,$BC,$99,$12,$D7,$50,$41,$4
         
         FOLDERID_VideosLibrary: ; {491E922F-5643-4AF4-A7EB-4E7A138D8174}
         Data.l $491E922F
         Data.w $5643,$4AF4
         Data.b $A7,$EB,$4E,$7A,$13,$8D,$81,$74
         
         FOLDERID_RecordedTVLibrary: ; {1A6FDBA2-F42D-4358-A798-B74D745926C5}
         Data.l $1A6FDBA2
         Data.w $F42D,$4358
         Data.b $A7,$98,$B7,$4D,$74,$59,$26,$C5
         
         FOLDERID_HomeGroup: ; {52528A6B-B9E3-4ADD-B60D-588C2DBA842D}
         Data.l $52528A6B
         Data.w $B9E3,$4ADD
         Data.b $B6,$D,$58,$8C,$2D,$BA,$84,$2D
         
         FOLDERID_DeviceMetadataStore: ; {5CE4A5E9-E4EB-479D-B89F-130C02886155}
         Data.l $5CE4A5E9
         Data.w $E4EB,$479D
         Data.b $B8,$9F,$13,$0C,$02,$88,$61,$55
         
         FOLDERID_Libraries: ; {1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE}
         Data.l $1B3EA5DC
         Data.w $B587,$4786
         Data.b $B4,$EF,$BD,$1D,$C3,$32,$AE,$AE
         
         FOLDERID_PublicLibraries: ; {48DAF80B-E6CF-4F4E-B800-0E69D84EE384}
         Data.l $48DAF80B
         Data.w $E6CF,$4F4E
         Data.b $B8,$00,$0E,$69,$D8,$4E,$E3,$84
         
         FOLDERID_UserPinned: ; {9E3995AB-1F9C-4F13-B827-48B24B6C7174}
         Data.l $9E3995AB
         Data.w $1F9C,$4F13
         Data.b $B8,$27,$48,$B2,$4B,$6C,$71,$74
         
         FOLDERID_ImplicitAppShortcuts: ; {BCB5256F-79F6-4CEE-B725-DC34E402FD46}
         Data.l $BCB5256F
         Data.w $79F6,$4CEE
         Data.b $B7,$25,$DC,$34,$E4,$2,$FD,$46
     EndDataSection
     
    ; SHFileOpen
    #OAIF_ALLOW_REGISTRATION = $00000001 ; Enable the "always use this program" checkbox. If Not passed, it will be disabled.
    #OAIF_REGISTER_EXT       = $00000002 ; Do the registration after the user hits the OK button.
    #OAIF_EXEC               = $00000004 ; Execute file after registering.
    #OAIF_FORCE_REGISTRATION = $00000008 ; Force the Always use this program checkbox To be checked. Typically, you won't use the OAIF_ALLOW_REGISTRATION flag when you pass this value. 
    #OAIF_HIDE_REGISTRATION  = $00000020 ; Introduced IN Windows Vista. Hide the Always use this program checkbox. If this flag is specified, the OAIF_ALLOW_REGISTRATION And OAIF_FORCE_REGISTRATION flags will be ignored. 
    #OAIF_URL_PROTOCOL       = $00000040 ; Introduced IN Windows Vista. The value For the extension that is passed is actually a protocol, so the Open With dialog box should show applications that are registered As capable of handling that protocol.
    #OAIF_FILE_IS_URI        = $00000080 ; Introduced IN Windows 8. The location pointed To by the pcszFile parameter is given As a URI.
    
    ;SH Autovervollständigen
    ;Dies BENÖTIGT ein CoInitialize_(#Null) und ein CoUninitialize_()
    #SHACF_DEFAULT          = $00000000
    #SHACF_FILESYSTEM       = $00000001
    #SHACF_URLHISTORY       = $00000002
    #SHACF_URLMRU           = $00000004
    #SHACF_URLALL           = #SHACF_URLHISTORY | #SHACF_URLMRU
    #SHACF_USETAB           = $00000008
    #SHACF_FILESYS_ONLY     = $00000010
    #SHACF_AUTOSUGGEST_FORCE_ON  = $10000000
    #SHACF_AUTOSUGGEST_FORCE_OFF = $20000000
    #SHACF_AUTOAPPEND_FORCE_ON   = $40000000
    #SHACF_AUTOAPPEND_FORCE_OFF  = $80000000
    #SHACF_FILESYS_DIRS = $00000020    

    
    ;***************************************************************************************************
    ;        
    Structure STRUCT_RFSHANDLE        
      Error.i               ; ErrorID
      Short.s               ; Short Description
      Long.s                ; Long Description      
    EndStructure      
    Global NewList RfsHandle.STRUCT_RFSHANDLE()
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 01
    RfsHandle()\Short = "SE_OK" 
    RfsHandle()\Long  = ""    
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 02
    RfsHandle()\Short = "SE_ERR_FNF" 
    RfsHandle()\Long  = "File not Found"
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 03
    RfsHandle()\Short = "SE_ERR_PNF" 
    RfsHandle()\Long  = "Path Not found" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 05
    RfsHandle()\Short = "SE_ERR_ACCESSDENIED" 
    RfsHandle()\Long  = "Access Denied" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 08
    RfsHandle()\Short = "SE_ERR_OOM" 
    RfsHandle()\Long  = "Out Of Memory" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 26
    RfsHandle()\Short = "SE_ERR_SHARE" 
    RfsHandle()\Long  = "Cannot share an open file" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 27
    RfsHandle()\Short = "SE_ERR_ASSOCINCOMPLETE" 
    RfsHandle()\Long  = "File association information not complete" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 28
    RfsHandle()\Short = "SE_ERR_DDETIMEOUT" 
    RfsHandle()\Long  = "DDE operation timed out"                                 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 29
    RfsHandle()\Short = "SE_ERR_DDEFAIL" 
    RfsHandle()\Long  = "DDE operation failed"                                 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 30
    RfsHandle()\Short = "SE_ERR_DDEBUSY" 
    RfsHandle()\Long  = "DDE operation is busy" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 31
    RfsHandle()\Short = "SE_ERR_NOASSOC" 
    RfsHandle()\Long  = "File association not available"                                 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = 32
    RfsHandle()\Short = "SSE_ERR_DLLNOTFOUND" 
    RfsHandle()\Long  = "Dynamic-link Library Not Found" 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = -1
    RfsHandle()\Short = "PB SE_ERR_FNF" 
    RfsHandle()\Long  = "File not Found"                                 
    
    AddElement( RfsHandle() ):  RfsHandle()\Error = -2
    RfsHandle()\Short = "PB_ERR_OK_DIR" 
    RfsHandle()\Long  = "Directory Found"                  
EndDeclareModule



Module FFH
    
    
    Prototype SHOpenWithDialog(HWND,*poainfo)  
    Prototype SHGetKnownFolderPath__(rfid, dwFlags.l, hToken, *ppszPath)
    
    
;         Procedure Ansi2Uni(ansi.s)
;         Protected memziel
;         
;         SHStrDup_(@ansi, @memziel)
;         
;         ProcedureReturn memziel
;     EndProcedure
    
    
    
    Procedure CreateShortenedPath(GadgetID.L, Path.S, Handle.l, OptString$ = "")
        Protected hDC.L
        Protected Result.L
                                
        hDC = GetDC_(GadgetID(GadgetID))
        
        If hDC <> #False
            Result = PathCompactPath_(hDC, @Path, Int((GadgetWidth(GadgetID) - 10) / 72.0 * GetDeviceCaps_(hDC, #LOGPIXELSX)))
            SetGadgetText(GadgetID, OptString$ + Path)
            ReleaseDC_(WindowID(Handle), hDC)
        EndIf
    EndProcedure
    
    Procedure ForceCreateDirectories(Path$)
        Static tmpDir.s, Init
        Protected result
        
        If Len(Path$) = 0
            ProcedureReturn #False
        Else
            If Not Init
                tmpDir = Path$
                Init   = #True
            EndIf
            If (Right(Path$, 1) = "\")
                Path$ = Left(Path$, Len(Path$) - 1)
            EndIf
            If (Len(Path$) < 3) Or FileSize(Path$) = -2 Or GetPathPart(Path$) = Path$
                If FileSize(tmpDir) = -2
                    result = #True
                EndIf
                tmpDir = "" : Init = #False
                ProcedureReturn result
            EndIf
            ForceCreateDirectories(GetPathPart(Path$))
            ProcedureReturn CreateDirectory(Path$)
        EndIf
    EndProcedure
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;         
    Procedure iBrowse(hwnd, msg, lParam, lData)
        Protected szDir$, Pattern$:
        Shared Ext$
        
        szDir$ = Space(#MAX_PATH)
        
        Select msg
            Case #BFFM_INITIALIZED
                SendMessage_(hwnd, #BFFM_SETSELECTION, #BFFM_INITIALIZED, lData)
                SendMessage_(hwnd, #BFFM_ENABLEOK, 0, 0)
                
            Case #BFFM_SELCHANGED
                If SHGetPathFromIDList_(lParam, @szDir$)
                    SendMessage_(hwnd, #BFFM_SETSTATUSTEXT, 0, @szDir$)
                    ;
                    ; Keine Extension, Ist OK wenn ohne Extension aufegrufen wird
                    If Ext$ = ""
                        SendMessage_(hwnd, #BFFM_ENABLEOK, 0, 1)                              
                    Else                             
                        Pattern$ = GetExtensionPart(szDir$)
                        Pattern$ = UCase(Pattern$)                             
                        
                        If Ext$ = Pattern$
                            SendMessage_(hwnd, #BFFM_ENABLEOK, 0, 1)
                        Else
                            SendMessage_(hwnd, #BFFM_ENABLEOK, 0, 0)
                        EndIf       
                    EndIf
                EndIf   
                
        EndSelect
    EndProcedure 
        
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;
    ;  Windows Path and File Requester (Alternative)
    ;   
    Procedure.s GetFilePath(Title.s = "", InitialPath.s = "",NewDialog = #True,NoDir = #False ,BrowseIncludeFiles = #True, Extension$ = "*",CSIDL = #PB_Default)
        
        
        ; Für die CSIDl
        ; https://docs.microsoft.com/en-us/windows/win32/shell/csidl
        
        ;#BIF_BROWSEINCLUDEURLS (0x00000080)
        ;0x00000080. Version 5.0. The browse dialog box can display URLs. The #BIF_USENEWUI And #BIF_BROWSEINCLUDEFILES flags must also
        ;be set. If any of these three flags are Not set, the browser dialog box rejects URLs. Even when these flags are set, the browse
        ;dialog box displays URLs only If the folder that contains the selected item supports URLs. When the folder's IShellFolder::GetAttributesOf
        ;method is called To request the selected item's attributes, the folder must set the SFGAO_FOLDER attribute flag. Otherwise, the browse
        ;dialog box will Not display the URL.

        ;#BIF_EDITBOX|#BIF_VALIDATE
        ;0x00000010. Version 4.71. Include an edit control in the browse dialog box that allows the user to type the name of an item.
        
        ;#BIF_NEWDIALOGSTYLE or #BIF_USENEWUI
        ;0x00000040. Version 5.0. Use the new user Interface. Setting this flag provides the user With a larger dialog box that can
        ;be resized. The dialog box has several new capabilities, including: drag-And-drop capability within the dialog box, reordering,
        ;shortcut menus, new folders, delete, And other shortcut menu commands.

        ;#BIF_NONEWFOLDERBUTTON (0x00000200)
        ;0x00000200. Version 6.0. Do Not include the New Folder button IN the browse dialog box.

        ;#BIF_BROWSEFORCOMPUTER (0x00001000)
        ;0x00001000. Only Return computers. If the user selects anything other than a computer, the OK button is grayed.        

        ;#BIF_BROWSEFORPRINTER (0x00002000)
        ;0x00002000. Only allow the selection of printers. If the user selects anything other than a printer, the OK button is grayed. 
        ;IN Windows XP And later systems, the best practice is To use a Windows XP-style dialog, setting the root of the dialog To the
        ;Printers And Faxes folder (CSIDL_PRINTERS).

        ;#BIF_BROWSEINCLUDEFILES (0x00004000)
        ;0x00004000. Version 4.71. The browse dialog box displays files As well As folders.
        
        ;#BIF_SHAREABLE (0x00008000)
        ;0x00008000. Version 5.0. The browse dialog box can display sharable resources on remote systems. This is intended For applications
        ;that want To expose remote shares on a local system. The #BIF_NEWDIALOGSTYLE flag must also be set.        
        
        Protected.ITEMIDLIST *ppidl
        Protected.BROWSEINFO Dir
        Protected iResult
        Protected.s iDirectory = Space(#MAX_PATH)
        Protected *Path, t1$
        Shared Ext$
        
        If Extension$ = "*"
            Ext$ = ""
        Else    
            Ext$ = UCase(Extension$)
            
        EndIf
        
        ;First Directory Only
        SetFlags = #BIF_STATUSTEXT | #BIF_UAHINT
        
        If NewDialog = #True
            SetFlags| #BIF_NEWDIALOGSTYLE| #BIF_USENEWUI 
        EndIf
        
        If BrowseIncludeFiles = #True
           SetFlags | #BIF_BROWSEINCLUDEFILES | #BIF_BROWSEINCLUDEURLS 
        Else
          If (FileSize(InitialPath.s) <> -2) And Not (InitialPath.s = "")
                MessageRequester("Error (2)", #CRLF$ + "Path Not Found :"+ #CRLF$ + InitialPath.s)
            EndIf
        EndIf
        
        If NoDir = #True
            SetFlags| #BIF_NONEWFOLDERBUTTON 
        EndIf
        
        CoInitialize_(#Null)
        
        If CSIDL = #PB_Default
            
            *Path =  AllocateMemory(StringByteLength(InitialPath, #PB_Unicode) + 2)
            
            PokeS(*Path, InitialPath, -1, #PB_Unicode)
            *ppidl = ILCreateFromPath_(*Path)
            FreeMemory(*Path)
        Else
            SHGetSpecialFolderLocation_(GetActiveWindow_(), CSIDL, @*ppidl)
        EndIf
        
        
        With Dir
            \hwndOwner      = GetActiveWindow_()
            \pidlRoot       = *ppidl
            \pszDisplayName = @iDirectory
            \lpszTitle      = @Title
            \ulFlags        = SetFlags|#BIF_EDITBOX|#BIF_VALIDATE
            \lpfn           = @iBrowse()
        EndWith
        
        iResult = SHBrowseForFolder_(@dir)
        
        If iResult And Dir\pszDisplayName
            
            t1$ = iDirectory
            SHGetPathFromIDList_(iResult, @iDirectory)
            If (iDirectory = "") Or Len(iDirectory) = 0
                iDirectory = t1$
            EndIf
            CoTaskMemFree_(iResult)
        EndIf
        
        CoTaskMemFree_(*ppidl)
        CoUninitialize_()
        
        If iDirectory
            If FileSize(iDirectory) = -2
                If Right(iDirectory, 1) <> "\"
                    iDirectory + "\"
                EndIf
            EndIf
        EndIf
        
        iDirectory = Trim(iDirectory)
        ProcedureReturn iDirectory
    EndProcedure
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Windows File Requester (Purebasic)
    ;
    Procedure.s GetFilePBRQ(Title.s,InitialPath.s = "", Save = #False, Extension$ = "Alle Dateien (*.*)|*.*;", ExtensionDefault = 0, MultiSelect = #False)
        
        ;Pattern beispiel 'Text (*.txt)|*.txt;*.bat|PureBasic (*.pb)|*.pb|Alle Dateien (*.*)|*.*'
        Protected FileResult$
            
        
        If  MultiSelect = #True
            MultiSelect = #PB_Requester_MultiSelection
        Else
            MultiSelect = 0
        EndIf
        
        Select Save
            Case #False:
                FileResult$ = OpenFileRequester(Title.s,InitialPath.s,Extension$,ExtensionDefault,MultiSelect)
            Case #True : 
                FileResult$ = SaveFileRequester(Title.s,InitialPath.s,Extension$,ExtensionDefault)
        EndSelect
        ProcedureReturn FileResult$
    EndProcedure
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Windows Path Requester (Purebasic)
    ;
    Procedure.s GetPathPBRQ(Title.s,InitialPath.s = "")
        
        Protected PathResult$
        
        If (FileSize(InitialPath.s) <> -2) And Not (InitialPath.s = "")
          CompilerIf #PB_Compiler_IsMainFile
            MessageRequester("Error -2","Path Not Found:" + #CR$ + InitialPath)
          CompilerElse  
            Request::MSG("", "Error -2","Path Not Found:" + #CR$ + InitialPath ,2,2)
          CompilerEndIf  
        EndIf
        
        PathResult$ = PathRequester(Title.s,InitialPath.s)
        ProcedureReturn PathResult$
    EndProcedure   
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Windows ShellExec
    ;
    Procedure.i ShellExec(lpFilePath$ = "",Verb$ = "",Paramter.s = "", Mask = #Null, ExShow.i = #SW_SHOWNORMAL, shAdmin.i = #False, Simple = 1)
      
        ;  "open"      - Opens a file Or a application
        ;  "openas"    - Opens dialog when no program is associated To the extension
        ;  "opennew"   - see MSDN 
        ;  "runas"     - IN Windows 7 And Vista, opens the UAC dialog And IN others, open the Run As... Dialog
        ;  "null"      - Specifies that the operation is the Default For the selected file type.
        ;  "edit"      - Opens the Default text editor For the file.    
        ;  "explore"   - Opens the Windows Explorer IN the folder specified IN lpDirectory.
        ;  "properties"- Opens the properties window of the file.
        ;  "copy"      - see MSDN
        ;  "cut"       - see MSDN
        ;  "paste"     - see MSDN
        ;  "pastelink" - pastes a shortcut
        ;  "delete"    - see MSDN
        ;  "print"     - Start printing the file With the Default application.
        ;  "printto"   - see MSDN
        ;  "find"      - Start a search      
        
        Protected Handle.l, iResult
        
        Define ShExec.SHELLEXECUTEINFO
        
        ShExec\cbSize = SizeOf(SHELLEXECUTEINFO)
        
        If shAdmin = #True
          Paramter = "-admin " + Paramter.s
        EndIf  
        
        ShExec\fMask        = Mask
        ShExec\hwnd         = Handle
        ShExec\lpVerb       = @Verb$
        ShExec\lpFile       = @lpFilePath$        
        ShExec\lpParameters = @Paramter        
        ShExec\lpDirectory  = #Null
        ShExec\nShow        =  #SW_SHOWNORMAL
        ShExec\hInstApp     = #Null
        
        Select Simple 
                Case 1
                    iResult = ShellExecute_(Handle, Verb$, lpFilePath$, Paramter ,#Null, ExShow)
                Case 0    
                    iResult = ShellExecuteEx_(@ShExec.SHELLEXECUTEINFO) 
        EndSelect            
       
        ResetList( RfsHandle() )
        ForEach RfsHandle() 
          If RfsHandle()\Error = GetLastError_()
            Debug #TAB$ + "======================================="
            Debug #TAB$ + "RFS: Error (" +Str( GetLastError_() )+ ")"
            Debug #TAB$ + "RFS: Short " +RfsHandle()\Short
            Debug #TAB$ + "RFS: Long  " +RfsHandle()\Long      
            Debug #TAB$ + "=======================================" 
            Break
          EndIf
        Next
        
        If iResult = 1
           iResult = ShExec\hwnd
           Debug #TAB$ + "ShellExec Return Process ShExec\hwnd="+Str(ShExec\hwnd) 
        EndIf                   
        ProcedureReturn iResult
    EndProcedure
    
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Windows SHOpenWithDialog_
    ;
    
    Procedure.i SHOpenWithDialog_(File$ = "",OPEN_AS_INFO_FLAGS.l = 0)
        
        Protected LibraryID
        
        Structure OPENASINFO
            pcszFile.i
            pcszClass.i
            oaifInFlags.l
        EndStructure  
        
        LibraryID = OpenLibrary(#PB_Any, "shell32.dll")
        If LibraryID
            
            Define OWD.OPENASINFO
            
            OWD\pcszFile = @File$
            OWD\pcszClass = #Null
            OWD\oaifInFlags = OPEN_AS_INFO_FLAGS
            
            iResult = CallFunction(LibraryID, "SHOpenWithDialog", hwnd,@OWD.OPENASINFO)
            CloseLibrary(LibraryID)
        EndIf
        ProcedureReturn iResult
    EndProcedure

    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Windows Delete File To Recyclebin (Droopy)
    ;    
    Procedure.i SHFileOp_(File$, Function.l = #FO_DELETE, Flags.l = #FOF_ALLOWUNDO |#FOF_NOCONFIRMATION | #FOF_SILENT	)
      
      ; Deletes the file to the Recycle Bin without confirmation / ProgressBar
      
      SHFileOp.SHFILEOPSTRUCT 
      SHFileOp\pFrom        = @File 
      SHFileOp\wFunc        = #FO_DELETE 
      SHFileOp\fFlags       = #FOF_ALLOWUNDO |#FOF_NOCONFIRMATION | #FOF_SILENT	
      
      r = SHFileOperation_(SHFileOp) 
      
      ; Returns zero If successful; otherwise nonzero.
      ; Applications normally should simply check For zero Or nonzero.
      ; https://msdn.microsoft.com/en-us/library/windows/desktop/bb762164(v=vs.85).aspx
      ; Error Code	Value	Meaning
      ; DE_SAMEFILE	        0x71	The source And destination files are the same file.
      ; DE_MANYSRC1DEST	    0x72	Multiple file paths were specified IN the source buffer, but only one destination file path.
      ; DE_DIFFDIR	        0x73	Rename operation was specified but the destination path is a different directory. Use the move operation instead.
      ; DE_ROOTDIR	        0x74	The source is a root directory, which cannot be moved Or renamed.
      ; DE_OPCANCELLED	    0x75	The operation was canceled by the user, Or silently canceled If the appropriate flags were supplied To SHFileOperation.
      ; DE_DESTSUBTREE	    0x76	The destination is a subtree of the source.
      ; DE_ACCESSDENIEDSRC	0x78	Security settings denied access To the source.
      ; DE_PATHTOODEEP	    0x79	The source Or destination path exceeded Or would exceed MAX_PATH.
      ; DE_MANYDEST	        0x7A	The operation involved multiple destination paths, which can fail IN the Case of a move operation.
      ; DE_INVALIDFILES	    0x7C	The path IN the source Or destination Or both was invalid.
      ; DE_DESTSAMETREE	    0x7D	The source And destination have the same parent folder.
      ; DE_FLDDESTISFILE	  0x7E	The destination path is an existing file.
      ; DE_FILEDESTISFLD	  0x80	The destination path is an existing folder.
      ; DE_FILENAMETOOLONG	0x81	The name of the file exceeds MAX_PATH.
      ; DE_DEST_IS_CDROM	  0x82	The destination is a Read-only CD-ROM, possibly unformatted.
      ; DE_DEST_IS_DVD	    0x83	The destination is a Read-only DVD, possibly unformatted.
      ; DE_DEST_IS_CDRECORD	0x84	The destination is a writable CD-ROM, possibly unformatted.
      ; DE_FILE_TOO_LARGE	  0x85	The file involved IN the operation is too large For the destination media Or file system.
      ; DE_SRC_IS_CDROM	    0x86	The source is a Read-only CD-ROM, possibly unformatted.
      ; DE_SRC_IS_DVD	      0x87	The source is a Read-only DVD, possibly unformatted.
      ; DE_SRC_IS_CDRECORD	0x88	The source is a writable CD-ROM, possibly unformatted.
      ; DE_ERROR_MAX	      0xB7	MAX_PATH was exceeded during the operation.
      ; 0x402	An unknown error occurred. This is typically due To an invalid path IN the source Or destination. This error does Not occur on Windows Vista And later.
      ; ERRORONDEST	        0x10000	An unspecified error occurred on the destination.
      ; DE_ROOTDIR | ERRORONDEST	0x10074	Destination is a root directory And cannot be renamed.      
      ProcedureReturn r
      
    EndProcedure


    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Windows File Download Save
    ;   
    ;     Procedure.i GetFileDownload(File$ = "")        
    ;         
    ;       If OpenLibrary(0,"shdocvw.dll")
    ;           CallFunction(0, "DoFileDownload", Ansi2Uni(File$))
    ;           CloseLibrary(0)
    ;       EndIf
    ;     EndProcedure
  
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Hole den Windows programm CLSID Ordner
    ;     
    Procedure.s GetClSIDPath(*FOLDERID_CLSID)
        Protected DLL, i, Result.s, *UnicodeBuffer, kfFlag.l, SHGetKnownFolderPath.SHGetKnownFolderPath__
        
        If *FOLDERID_CLSID = 0
            Debug "Schwerwiegender Fehler im Modul RequestPathEx"
            End
        EndIf
        
        If OpenLibrary(0, "Shell32.dll")
            SHGetKnownFolderPath = GetFunction(0, "SHGetKnownFolderPath")
            If SHGetKnownFolderPath
                If SHGetKnownFolderPath(*FOLDERID_CLSID, kfFlag, #Null, @*UnicodeBuffer) = #S_OK And *UnicodeBuffer
                    Result = PeekS(*UnicodeBuffer, -1, #PB_Unicode) + "\"
                    CoTaskMemFree_(*UnicodeBuffer)
                EndIf
            EndIf
            CloseLibrary(0)
        EndIf
        
        If Result = "": Result = GetHomeDirectory():EndIf        
        ProcedureReturn Result
    EndProcedure
  
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Hole den Windows Programm CLSID Ordner (Angabe Variabel, Returncode ist der echte Path)
    ;     
    Procedure.s GetClSIDVariable(Path$)  
      Protected iPos
      
      iPos = FindString(Path$, "%DESKTOP%",1,#PB_String_NoCase)
      If (iPos <> 0)
          Path$ = ReplaceString(Path$,"%DESKTOP%\",GetClSIDPath(?FOLDERID_DESKTOP))
      ProcedureReturn Path$:EndIf
      
      iPos = FindString(Path$, "%DOCUMENTS%",1,#PB_String_NoCase)
      If (iPos <> 0)
          Path$ = ReplaceString(Path$,"%DOCUMENTS%",GetClSIDPath(?FOLDERID_DOCUMENTS))
      ProcedureReturn Path$:EndIf      
          
      iPos = FindString(Path$, "%APPDATA%",1,#PB_String_NoCase)
      If (iPos <> 0): Path$ = ReplaceString(Path$,"%APPDATA%\",GetClSIDPath(?FOLDERID_RoamingAppData)): ProcedureReturn Path$:EndIf 
          
      iPos = FindString(Path$, "%LOCALAPPDATA%",1,#PB_String_NoCase)
      If (iPos <> 0): Path$ = ReplaceString(Path$,"%LOCALAPPDATA%\",GetClSIDPath(?FOLDERID_LOCALAPPDATA)): ProcedureReturn Path$:EndIf       
      
      iPos = FindString(Path$, "%USERPROFILE%",1,#PB_String_NoCase)
      If (iPos <> 0): Path$ = ReplaceString(Path$,"%USERPROFILE%\",GetClSIDPath(?FOLDERID_UserProfiles)): ProcedureReturn Path$:EndIf
      
      iPos = FindString(Path$, "%SAVEDGAMES%",1,#PB_String_NoCase)
      If (iPos <> 0): Path$ = ReplaceString(Path$,"%SAVEDGAMES%\",GetClSIDPath(?FOLDERID_SAVEDGAMES)): ProcedureReturn Path$:EndIf
      
      iPos = FindString(Path$, "%HOMEDRIVE%",1,#PB_String_NoCase)
      If (iPos <> 0): Path$ = ReplaceString(Path$,"%HOMEDRIVE%\",GetHomeDirectory()): ProcedureReturn Path$:EndIf
      
      ProcedureReturn Path$
  EndProcedure
  
  
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ;    
    ; Hole den Windows Programm CLSID Ordner (Angabe Echter Path, Returncode ist die Virtuelle Path variable)
    ;       
    Procedure.s SetClSIDVariable(Path$)    
        Protected lenght.i, iPos1.l, iPos2.l, iPos3.l, PathVariable$, ExpandString$
        
        lenght.i = Len(Path$)
        Select lenght.i
            Case 0: ProcedureReturn ""
            Default
                
                iPos1.l =  FindString(Path$, LCase("\users\"),1,#PB_String_NoCase)
                iPos2.l =  FindString(Path$, LCase("\public\"),1,#PB_String_NoCase)
                If (iPos2.l <> 0)
                    ProcedureReturn Path$
                EndIf
                
                Select iPos1.l
                    Case 0: 
                        ProcedureReturn Path$
                    Default
                        ExpandString$ = "\Desktop\"
                        iPos3.l =  FindString(Path$, LCase(ExpandString$),1,#PB_String_NoCase)
                        If  iPos3.l <> 0
                            PathVariable$  = "%DESKTOP%\"+Right(Path$,lenght.i-iPos3.l-(Len(ExpandString$)-1))
                            ProcedureReturn PathVariable$
                        EndIf
                        
                        ExpandString$ = "\Documents\"
                        iPos3.l =  FindString(Path$, LCase(ExpandString$),1,#PB_String_NoCase)
                        If  iPos3.l <> 0
                            PathVariable$  = "%DOCUMENTS%\"+Right(Path$,lenght.i-iPos3.l-(Len(ExpandString$)-1))
                            ProcedureReturn PathVariable$
                        EndIf                      
                        
                        ExpandString$ = "\Appdata\Roaming\"
                        iPos3.l =  FindString(Path$, LCase(ExpandString$),1,#PB_String_NoCase)
                        If  iPos3.l <> 0
                            PathVariable$  = "%APPDATA%\"+Right(Path$,lenght.i-iPos3.l-(Len(ExpandString$)-1))
                            ProcedureReturn PathVariable$
                        EndIf 
                                               
                        ExpandString$ = "\Appdata\Local\"
                        iPos3.l =  FindString(Path$, LCase(ExpandString$),1,#PB_String_NoCase)
                        If  iPos3.l <> 0
                            PathVariable$  = "%LOCALAPPDATA%\"+Right(Path$,lenght.i-iPos3.l-(Len(ExpandString$)-1))
                            ProcedureReturn PathVariable$
                        EndIf
                        
                        ExpandString$ = "\Appdata\LocalLow\"
                        iPos3.l =  FindString(Path$, LCase(ExpandString$),1,#PB_String_NoCase)
                        If  iPos3.l <> 0
                            PathVariable$  = "%LOCALAPPDATA%\"+Right(Path$,lenght.i-iPos3.l-(Len(ExpandString$)-1))
                            ProcedureReturn PathVariable$
                        EndIf
                        
                        ExpandString$ = "\Saved Games\"
                        iPos3.l =  FindString(Path$, LCase(ExpandString$),1,#PB_String_NoCase)
                        If  iPos3.l <> 0
                            PathVariable$  = "%SAVEDGAMES%\"+Right(Path$,lenght.i-iPos3.l-(Len(ExpandString$)-1))
                            ProcedureReturn PathVariable$
                        EndIf 
                        
                        If LCase(GetHomeDirectory()) = LCase(GetPathPart(Path$))                            
                            PathVariable$ = "%HOMEDRIVE%\"
                            PathVariable$ = ReplaceString(Path$,GetHomeDirectory(),PathVariable$)
                            ProcedureReturn PathVariable$
                        EndIf    
                        ProcedureReturn Path$
                EndSelect
        EndSelect     
    EndProcedure


    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ;
    Procedure.s CheckKeyShortcut(Text.s, Mode.i = -1, okAscii.s = "", OkMaxAwd = -1)
        
        Protected *char.Character , sLen.i, Position.i, cnt
        
        
        If ( OkMaxAwd >=0 )
            cnt = CountString(Text,okAscii)
            If ( cnt >= OkMaxAwd )
                cnt - OkMaxAwd                
                Text = ReplaceString(Text,okAscii,"",1,1,cnt) 
                ProcedureReturn Text
            EndIf
            
        EndIf    
        sLen = Len(Text.s)
        If ( sLen <> 0 )                                    
            For i = 1 To sLen
                dAscii.s = Mid(Text, i,1)
                If Asc(okAscii.s) = Asc(dAscii.s)
                Else                 
                    
                    *char = @dAscii
                    
                    Select Mode
                        Case 1 
                            ; Entferne Alle Zeichen (Grossbuchstaben)
                            If ( *char\c >= 65 And *char\c <= 90 )                         
                                Text = ReplaceString(Text,Chr(*char\c),"")
                                Beep_(1000,800)
                                ProcedureReturn Text
                            EndIf                                                     
                            ; Entferne Umlaute, 252 'ü', 246 'ö', 228 'ä')
                            If ( *char\c = 252 ) Or ( *char\c = 246 ) Or  ( *char\c = 228 )                      
                                Text = ReplaceString(Text,Chr(*char\c),"")
                                ProcedureReturn Text
                            EndIf                              
                        Case 2
                            ; Entferne Alle Zeichen (Kleinbuchstaben)
                            If ( *char\c >= 97 And *char\c <= 122 )                         
                                Text = ReplaceString(Text,Chr(*char\c),"")
                                ProcedureReturn Text
                            EndIf                        
                            
                        Case 3
                            ; Entferne Alle Zeichen (Zahlen)
                            If ( *char\c >= 48 And*char\c <= 57 )                         
                                Text = ReplaceString(Text,Chr(*char\c),"")
                                ProcedureReturn Text
                            EndIf                                                                             
                        Case 4
                            ; Entferne Alle Zeichen (Sonderzeichen)
                            If ( *char\c >= 0   And *char\c <= 47 ) Or
                               ( *char\c >= 58  And *char\c <= 64 ) Or
                               ( *char\c >= 91  And *char\c <= 96 ) Or
                               ( *char\c >= 123 And *char\c <= 255) Or
                               Text = ReplaceString(Text,Chr(*char\c),"")
                                ProcedureReturn Text
                            EndIf
                    EndSelect
                EndIf
                
                If ( i = sLen ): Break: EndIf
            Next  
        EndIf   
         ProcedureReturn Text           
     EndProcedure   

 
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ;
    Procedure.i GetDriveTypCheck(Drive$)
        Protected  DriveTyp.i
                              
        DriveTyp = GetDriveType_(Drive$+"\")
        Select DriveTyp
            Case #DRIVE_UNKNOWN            
            Case #DRIVE_NO_ROOT_DIR              
            Case #DRIVE_REMOVABLE
            Case #DRIVE_FIXED
            Case #DRIVE_REMOTE
            Case #DRIVE_CDROM
            Case #DRIVE_RAMDISK         
        EndSelect
        
        ProcedureReturn DriveTyp
    EndProcedure      
    

    
 
    

    

    

    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Delete File(s)        
    Procedure.i Delete_ShFileOP(From$="",Dest$="",SHFunction.l=#Null,ShFlags.l=#Null)
        Protected  SHFileOp.SHFILEOPSTRUCT, *ptrFile, Result
        
        *ptrFile = AllocateMemory(StringByteLength(From$) + 8)
        PokeS(*ptrFile,From$)  
        
        Select FileSize(Dest$)
            Case 0
                *ptrDest = #Null 
            Case -1    
                *ptrDest = #Null 
            Default                
                *ptrDest = AllocateMemory(StringByteLength(Dest$) + 8)
                PokeS(*ptrDest,Dest$) 
       EndSelect 
        
        SHFileOp\pFrom = *ptrFile
        SHFileOp\pTo   = *ptrDest
        SHFileOp\wFunc = SHFunction 
        SHFileOp\fFlags= ShFlags	                          
        
        Result = SHFileOperation_(@SHFileOp) 
                            
        Select Result
            Case 0
            Case 2
                Debug "The system cannot find the file specified. (0x2)"
                Debug PathFile
                Debug ""
            Case 87
                Debug "ERROR_INVALID_PARAMETER; The parameter is incorrect.(0x57)"
                Debug PathFile
                Debug ""
            Case 124
                Debug "The path in the source or destination or both was invalid. (0x7C)"
                Debug PathFile
                Debug ""
            Default
                Debug Result
        EndSelect
        ProcedureReturn Result
    EndProcedure
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; CreateMem Internal  
    Procedure CreateMem(Array files.s(1))
        
        Protected i, j, size, *mem, *pmem
        
        j = ArraySize(files())
        For i = 0 To j
            If Right(files(i), 1) = "\" : files(i) = Left(files(i), Len(files(i)) - 1) : EndIf
            size + StringByteLength(files(i)) + 1 * SizeOf(Character)
        Next
        size  + 1 * SizeOf(Character)
        *mem = AllocateMemory(size)
        If *mem
            *pmem = *mem
            For i = 0 To j
                PokeS(*pmem, files(i))
                *pmem + StringByteLength(files(i)) + 1 * SizeOf(Character)
            Next
        EndIf
        ProcedureReturn *mem
    EndProcedure
    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Copy
    Procedure.i Copy(Array sources.s(1), Array dest.s(1), title.s = "", hWnd = 0, flags = #FOF_NOCONFIRMATION | #FOF_NOCONFIRMMKDIR | #FOF_NOERRORUI)
        Protected info.SHFILEOPSTRUCT
        Protected *source, *dest, result
        
        *source = CreateMem(sources())
        *dest = CreateMem(dest())
        
        If *source And *dest
            With info
                If hWnd = 0
                    \hwnd = GetForegroundWindow_()
                Else
                    \hwnd = hWnd
                EndIf
                \wFunc = #FO_COPY
                \pFrom = *source
                \pTo = *dest
                \fFlags = flags
                \lpszProgressTitle = @title
                result = Bool(Not SHFileOperation_(info))
                If \fAnyOperationsAborted
                    result = 1
                EndIf
                FreeMemory(*source) : FreeMemory(*dest)
                ProcedureReturn result
            EndWith
        Else
            If *source : FreeMemory(*source) : EndIf
            If *dest : FreeMemory(*dest) : EndIf
            
            ProcedureReturn #False
        EndIf
    EndProcedure
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Move
    Procedure.i Move(Array sources.s(1), Array dest.s(1), title.s = "", hWnd = 0, flags = #FOF_NOCONFIRMATION | #FOF_NOCONFIRMMKDIR | #FOF_NOERRORUI)
        Protected info.SHFILEOPSTRUCT
        Protected *source, *dest, result
        
        *source = CreateMem(sources())
        *dest = CreateMem(dest())
        
        If *source And *dest
            With info
                If hWnd = 0
                    \hwnd = GetForegroundWindow_()
                Else
                    \hwnd = hWnd
                EndIf
                \wFunc = #FO_MOVE
                \pFrom = *source
                \pTo = *dest
                \fFlags = flags
                \lpszProgressTitle = @title
                
                result = Bool(Not SHFileOperation_(info))
                If \fAnyOperationsAborted
                    result = 1
                EndIf
                FreeMemory(*source) : FreeMemory(*dest)
                ProcedureReturn result
            EndWith
        Else
            If *source : FreeMemory(*source) : EndIf
            If *dest : FreeMemory(*dest) : EndIf
            
            ProcedureReturn #False
        EndIf
    EndProcedure
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Delete  
    Procedure.i Delete(Array sources.s(1), title.s = "", hWnd = 0, flags = #FOF_NOCONFIRMATION | #FOF_NOERRORUI)
        Protected info.SHFILEOPSTRUCT
        Protected *mem, result
        
        *mem = CreateMem(sources())
        If *mem
            With info
                If hWnd = 0
                    \hwnd = GetForegroundWindow_()
                Else
                    \hwnd = hWnd
                EndIf
                \wFunc = #FO_DELETE
                \pFrom = *mem
                \fFlags = flags
                \lpszProgressTitle = @title
                result = Bool(Not SHFileOperation_(info))
                If \fAnyOperationsAborted
                    result = 1
                EndIf
                FreeMemory(*mem)
                ProcedureReturn result
            EndWith
        EndIf
    EndProcedure
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Put in Clipboard   
    Procedure.i SetClipBoard(Array sources.s(1),FlagEffect.i = #DROPEFFECT_COPY)
        Protected clipFile, hGlobal, *lpGlobal.DROPFILES, *mem, *Format.FORMATETC, *StgMedium.STGMEDIUM, *pDropEffect
        
        dword.l = 0
        DropEffectFormat.i = 0
        
              
        *mem = CreateMem(sources())
        If *mem
            If OpenClipboard_(0)
                EmptyClipboard_()
                hGlobal = GlobalAlloc_(#GHND, SizeOf(DROPFILES) + MemorySize(*mem))
                If hGlobal
                    *lpGlobal = GlobalLock_(hGlobal)
                    ZeroMemory_(*lpGlobal, SizeOf(DROPFILES))
                    *lpGlobal\pFiles = SizeOf(DROPFILES)
                    CompilerIf #PB_Compiler_Unicode
                        *lpGlobal\fWide = 1 ; Unicode
                    CompilerEndIf
                    *lpGlobal\fNC   = 0
                    *lpGlobal\pt\x  = 0
                    *lpGlobal\pt\y  = 0
                    CopyMemory_((*lpGlobal + SizeOf(DROPFILES)), *mem, MemorySize(*mem))
                    GlobalUnlock_(hGlobal)
                    
                    If SetClipboardData_(#CF_HDROP, hGlobal)
                        clipFile = #True
                    EndIf
                EndIf     
                
                hGlobal = GlobalAlloc_(#GMEM_SHARE|#GMEM_MOVEABLE|#GMEM_ZEROINIT|#GMEM_DDESHARE, 4)
                If hGlobal
                    pDropEffect = GlobalLock_(hGlobal)         ;
                    *pDropEffect = PokeI(pDropEffect,FlagEffect)      ;
                    GlobalUnlock_(hGlobal)                      ;     
                    SetClipboardData_(RegisterClipboardFormat_(#CFSTR_PREFERREDDROPEFFECT), hGlobal);
                EndIf                                         
            EndIf
            CloseClipboard_()
        EndIf
        FreeMemory(*mem)
    ProcedureReturn clipFile
EndProcedure
  
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Getclipboard   
    Procedure.s GetClipBoard()
        Protected nFiles, cbFiles, buffSize, f
        Protected file.s, result.s
        
        If OpenClipboard_(0)
            If IsClipboardFormatAvailable_(#CF_HDROP)
                cbFiles = GetClipboardData_(#CF_HDROP)
                  If cbFiles
                    nFiles = DragQueryFile_(cbFiles, -1, 0, 0)
                    For f = 0 To nFiles - 1
                        buffSize = DragQueryFile_(cbFiles, f, 0, 0) + 1
                        file = Space(buffSize)
                        DragQueryFile_(cbFiles, f, @file, buffSize)
                        If FileSize(file) = - 2
                            file + "\"
                        EndIf
                        If FileSize(file) <> - 1
                            result + file + #LF$
                        EndIf
                    Next
                    If result <> ""
                        result = Left(result, Len(result) - 1)
                    EndIf
                EndIf
            EndIf
            CloseClipboard_()
        EndIf
        ProcedureReturn result
    EndProcedure  
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; IsClipBoard   
    Procedure.i IsClipBoard()
        Protected result
        
        If OpenClipboard_(0) 
            If IsClipboardFormatAvailable_(#CF_HDROP)                        
                result = #CF_HDROP
            EndIf
            
            If IsClipboardFormatAvailable_(#CF_TEXT)                        
                result = #CF_TEXT
            EndIf
            If IsClipboardFormatAvailable_(#CF_OEMTEXT)                        
                result = #CF_TEXT
            EndIf  
            If IsClipboardFormatAvailable_(#CF_UNICODETEXT)                        
                result = #CF_TEXT
            EndIf                      
            
            CloseClipboard_()
        EndIf
        ProcedureReturn result
    EndProcedure    
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; IsClipBoard     
    Procedure GetClipboardFormat()
        Protected lR.i , sBuf$, i.i
        OpenClipboard_(0) 
        lR = EnumClipboardFormats_(lR)
        
            sBuf$=Space(256)
            
            i=GetClipboardFormatName_(lR, @sBuf$, 256)
            
            Debug "buf = " + sBuf$
            Select lR   
                Case #CF_TEXT 
                    Debug "Text" 
                Case #CF_BITMAP 
                    Debug "Bitmap Picture" 
                Case #CF_METAFILEPICT 
                    Debug "Meta-File Picture" 
                Case #CF_SYLK 
                    Debug "Microsoft Symbolic Link (SYLK) data." 
                Case #CF_DIF 
                    Debug "Software Arts' Data Interchange information." 
                Case #CF_TIFF
                    Debug "Tagged Image File Format (TIFF) Picture" 
                Case #CF_OEMTEXT 
                    Debug "Text (OEM)" 
                Case #CF_DIB 
                    Debug "DIB Bitmap Picture" 
                Case #CF_PALETTE 
                    Debug "Colour Palette" 
                Case #CF_PENDATA 
                    Debug "Pen Data" 
                Case #CF_RIFF 
                    Debug "RIFF Audio data" 
                Case #CF_WAVE 
                    Debug "Wave File" 
                Case #CF_UNICODETEXT 
                    Debug "Text (Unicode)" 
                Case #CF_ENHMETAFILE 
                    Debug "Enhanced Meta-File Picture" 
                Case #CF_HDROP 
                    Debug "File List" 
                Case #CF_LOCALE 
                    Debug "Text Locale Identifier" 
                Default
                    Debug lR   
            EndSelect             
            CloseClipboard_()
            ProcedureReturn lR            
        EndProcedure
   
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Download        
        Procedure WinApi_DownloadFile(Url.s, TargetPath.s)
            
            #INET_E_DOWNLOAD_FAILURE = $800C0008
            
            If Not DeleteUrlCacheEntry_(@Url)
                If GetLastError_() = #ERROR_ACCESS_DENIED
                    ProcedureReturn #False
                EndIf
            EndIf
            
            Select URLDownloadToFile_(0, @Url, @TargetPath, 0, 0)
                Case #S_OK                                                                                
                    ProcedureReturn #True
                Case #E_OUTOFMEMORY, #INET_E_DOWNLOAD_FAILURE
                    ProcedureReturn #False
            EndSelect
        EndProcedure            
    ;
    ;
      Procedure.i CheckURL (URL.s)
      Protected NextPart.l
      Protected *Scan.CHARACTER = @URL
     
      If LCase(PeekS(*Scan , 7 )) = "http://"
          NextPart.l + (7 * SizeOf (CHARACTER))
          
      ElseIf LCase(PeekS(*Scan , 8 )) = "https://"
          NextPart.l + (8 * SizeOf (CHARACTER))
          
      ElseIf LCase(PeekS(*Scan , 6 )) = "ftp://"
          NextPart.l + (6 * SizeOf (CHARACTER))
          
      ElseIf LCase(PeekS(*Scan , 7 )) = "ftps://"
        NextPart.l + (7 * SizeOf (CHARACTER))          
      Else
        ProcedureReturn -1
      EndIf

      *Scan + NextPart.l
     
      While *Scan\c
         Select *Scan\c
         Case 35 To 38 , 43 To 58 , 61 , 63, 65 To 90 , 95, 97 To 122 , 192 To 214 , 217 To 222 , 224 To 246 , 249 To 255
         ; dummy
         Default
         ProcedureReturn *Scan\c
         EndSelect
        *Scan + SizeOf (CHARACTER)
      Wend
      ProcedureReturn 0
    EndProcedure
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; DeleteLine , Delete a String a Text Line           
        Procedure.i DeleteLine(iFileID,sFileName.s,iDelLineNum.i)
            ;------------------------------------------------------
            ; ***** Fast code by Bernd (infratec), made fail friendly by IdeasVacuum *****
            
            iReturnVal.i = #True
            iSize.l = FileSize(sFileName)
            iReadLen.l = 0
            i.i = 1
            n.i = 0
            iLength.l = 0
            
            If iSize > 0
                
                If ReadFile(iFileID,sFileName)
                    
                    *Buffer = AllocateMemory(iSize)
                    If *Buffer
                        
                        iReadLen = ReadData(iFileID, *Buffer, iSize)
                        CloseFile(iFileID)
                        
                        If(iReadLen = iSize)
                            
                            While i < iDelLineNum
                                
                                If PeekA(*Buffer + n) = $0A
                                    i + 1
                                EndIf
                                
                                n + 1
                            Wend
                            
                            *Dest = *Buffer + n
                            n = 0
                            
                            While PeekA(*Dest + n) <> $0A
                                n + 1
                            Wend
                            
                            *Source = *Dest + n + 1
                            iLength = (*Buffer + iSize) - *Source
                            
                            MoveMemory(*Source, *Dest, iLength)
                            
                            iSize - n - 1
                            
                            If CreateFile(iFileID, sFileName)
                                
                                WriteData(iFileID, *Buffer, iSize)
                                CloseFile(iFileID)
                            Else
                                MessageRequester("File Issue","File create failed",#PB_MessageRequester_Ok)
                                iReturnVal = #False
                            EndIf
                            
                        Else
                            MessageRequester("Memory Issue","File read failed",#PB_MessageRequester_Ok)
                            iReturnVal = #False
                        EndIf
                        
                        FreeMemory(*Buffer)
                    Else
                        MessageRequester("Memory Issue","Memory allocation failed",#PB_MessageRequester_Ok)
                        iReturnVal = #False
                    EndIf
                Else
                    MessageRequester("File Issue","File open failed",#PB_MessageRequester_Ok)
                    iReturnVal = #False
                EndIf
            Else
                MessageRequester("File Issue","File empty",#PB_MessageRequester_Ok)
                iReturnVal = #False
            EndIf
            
            ProcedureReturn(iReturnVal)
            
        EndProcedure
        
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
    ;Dies BENÖTIGT ein CoInitialize_(#Null) vor dem Stringgadget und ein CoUninitialize_() beim beenden des Fenster
        Procedure SHAutoComplete(GadgetID.i, FileHistory = #False, PathHistory = #False, UrlHistory = #False, Flags.l = 0)
            
            CoInitialize_(#Null)
            
            If IsGadget( GadgetID )
                
                If ( FileHistory = #True )
                    Flags | #SHACF_FILESYSTEM
                EndIf
                
                If ( PathHistory = #True )
                    Flags | #SHACF_FILESYS_ONLY
                EndIf                
                
                If ( UrlHistory = #True )
                    Flags | #SHACF_URLALL
                EndIf                 
                
                SHAutoComplete_( GadgetID( GadgetID ), #SHACF_AUTOAPPEND_FORCE_ON | #SHACF_AUTOSUGGEST_FORCE_ON | Flags)
                SendMessage_(GadgetID( GadgetID ), #EM_SETSEL, Len( GetGadgetText( GadgetID )+1), GetGadgetText( GadgetID ) + 1 )
                
            EndIf
        EndProcedure   
        
    ;//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
    ; Splitted den Path oder eine Textzeile       
    ; Example: FFH::PathPartsExt(TestFile$, Parts()) wobew Parts ein Liste ist (Newlist Parts.()) 
    ;   
       Procedure PathPartsExt(sText.s, List CharList.s(), sChar$ = Chr(92))
           
           Structure tChar
               StructureUnion
                   c.c
                   s.s { 1 }
               EndStructureUnion      
           EndStructure    
           
           Protected nLines.l , lCounter.l , iMax, *Source .tChar, nCharsPerLine.w, CharMax.i
           
           CharMax = CountString(sText,sChar$)          
           CharCnt = CharMax
           
           If ( CharMax = 0 ) And ( Len(sText) = 0 )
               ProcedureReturn #False
           EndIf       
           
           If ( Len(sText) >= 1 )
               
               For i = 1 To CharMax + 3
                   index$ = StringField(sText, i, sChar$) :lCounter = 0               
                   
                   *Source.tChar   = @index$                
                   nCharsPerLine.w = Len ( index$ )
                   
                   If nCharsPerLine.w <> 0                               
                       nLines.l = Len ( index$ ) / nCharsPerLine  
                   EndIf
                   
                   If ( *Source\c <> 0 )
                       AddElement ( CharList() )
                       While *Source\c
                           
                           If nCharsPerLine - 1 < lCounter
                               AddElement ( CharList() )                            
                               lCounter = 0
                           EndIf
                           
                           CharList() + *Source\s
                           lCounter + 1
                           *Source  + SizeOf ( CHARACTER )                        
                       Wend
                       ;
                       ; Hänge den Backslash wieder dran
                       If ( sChar$ = Chr(92) ); And CharCnt > 1) 
                           ;CharCnt - 1
                           CharList() + Chr(92)
                       EndIf    
                   EndIf
                   
               Next
           EndIf
           ProcedureReturn #True
           
       EndProcedure
       
   Procedure.s Doc_BIF_Flags()
        
        ; Für die CSIDl
        ; https://docs.microsoft.com/en-us/windows/win32/shell/csidl
        
        ;#BIF_BROWSEINCLUDEURLS (0x00000080)
        ;0x00000080. Version 5.0. The browse dialog box can display URLs. The #BIF_USENEWUI And #BIF_BROWSEINCLUDEFILES flags must also
        ;be set. If any of these three flags are Not set, the browser dialog box rejects URLs. Even when these flags are set, the browse
        ;dialog box displays URLs only If the folder that contains the selected item supports URLs. When the folder's IShellFolder::GetAttributesOf
        ;method is called To request the selected item's attributes, the folder must set the SFGAO_FOLDER attribute flag. Otherwise, the browse
        ;dialog box will Not display the URL.

        ;#BIF_EDITBOX|#BIF_VALIDATE
        ;0x00000010. Version 4.71. Include an edit control in the browse dialog box that allows the user to type the name of an item.
        
        ;#BIF_NEWDIALOGSTYLE or #BIF_USENEWUI
        ;0x00000040. Version 5.0. Use the new user Interface. Setting this flag provides the user With a larger dialog box that can
        ;be resized. The dialog box has several new capabilities, including: drag-And-drop capability within the dialog box, reordering,
        ;shortcut menus, new folders, delete, And other shortcut menu commands.

        ;#BIF_NONEWFOLDERBUTTON (0x00000200)
        ;0x00000200. Version 6.0. Do Not include the New Folder button IN the browse dialog box.

        ;#BIF_BROWSEFORCOMPUTER (0x00001000)
        ;0x00001000. Only Return computers. If the user selects anything other than a computer, the OK button is grayed.        

        ;#BIF_BROWSEFORPRINTER (0x00002000)
        ;0x00002000. Only allow the selection of printers. If the user selects anything other than a printer, the OK button is grayed. 
        ;IN Windows XP And later systems, the best practice is To use a Windows XP-style dialog, setting the root of the dialog To the
        ;Printers And Faxes folder (CSIDL_PRINTERS).

        ;#BIF_BROWSEINCLUDEFILES (0x00004000)
        ;0x00004000. Version 4.71. The browse dialog box displays files As well As folders.
        
        ;#BIF_SHAREABLE (0x00008000)
        ;0x00008000. Version 5.0. The browse dialog box can display sharable resources on remote systems. This is intended For applications
        ;that want To expose remote shares on a local system. The #BIF_NEWDIALOGSTYLE flag must also be set.             
        
        ; CSIDL_ADMINTOOLS                  FOLDERID_AdminTools         Version 5.0. The file system directory that is used To store administrative tools For an individual user. The MMC will save customized consoles To this directory, And it will roam With the user.
        ; CSIDL_ALTSTARTUP                  FOLDERID_Startup            The file system directory that corresponds To the user's nonlocalized Startup program group. This value is recognized in Windows Vista for backward compatibility, but the folder itself no longer exists.
        ; CSIDL_APPDATA                     FOLDERID_RoamingAppData     Version 4.71. The file system directory that serves As a common repository For application-specific Data. A typical path is C:\Documents And Settings\username\Application Data.
        ; CSIDL_BITBUCKET                   FOLDERID_RecycleBinFolder   The virtual folder that contains the objects IN the user's Recycle Bin.
        ; CSIDL_CDBURN_AREA                 FOLDERID_CDBurning          Version 6.0. The file system directory that acts As a staging area For files waiting To be written To a CD. A typical path is C:\Documents And Settings\username\Local Settings\Application Data\Microsoft\CD Burning.
        ; CSIDL_COMMON_ADMINTOOLS           FOLDERID_CommonAdminTools   Version 5.0. The file system directory that contains administrative tools For all users of the computer.
        ; CSIDL_COMMON_ALTSTARTUP           FOLDERID_CommonStartup      The file system directory that corresponds To the nonlocalized Startup program group For all users. This value is recognized IN Windows Vista For backward compatibility, but the folder itself no longer exists.
        ; CSIDL_COMMON_APPDATA              FOLDERID_ProgramData        Version 5.0. The file system directory that contains application Data For all users. A typical path is C:\Documents And Settings\All Users\Application Data. This folder is used For application Data that is Not user specific. For example, an application can store a spell-check dictionary, a database of clip art, Or a log file IN the CSIDL_COMMON_APPDATA folder. This information will Not roam And is available To anyone using the computer.
        ; CSIDL_COMMON_DESKTOPDIRECTORY     FOLDERID_PublicDesktop      The file system directory that contains files And folders that appear on the desktop For all users. A typical path is C:\Documents And Settings\All Users\Desktop.
        ; CSIDL_COMMON_DOCUMENTS            FOLDERID_PublicDocuments    The file system directory that contains documents that are common To all users. A typical path is C:\Documents And Settings\All Users\Documents.
        ; CSIDL_COMMON_FAVORITES            FOLDERID_Favorites          The file system directory that serves As a common repository For favorite items common To all users.
        ; CSIDL_COMMON_MUSIC                FOLDERID_PublicMusic        Version 6.0. The file system directory that serves As a repository For music files common To all users. A typical path is C:\Documents And Settings\All Users\Documents\My Music.
        ; CSIDL_COMMON_OEM_LINKS            FOLDERID_CommonOEMLinks     This value is recognized IN Windows Vista For backward compatibility, but the folder itself is no longer used.
        ; CSIDL_COMMON_PICTURES             FOLDERID_PublicPictures     Version 6.0. The file system directory that serves As a repository For image files common To all users. A typical path is C:\Documents And Settings\All Users\Documents\My Pictures.
        ; CSIDL_COMMON_PROGRAMS             FOLDERID_CommonPrograms     The file system directory that contains the directories For the common program groups that appear on the Start menu For all users. A typical path is C:\Documents And Settings\All Users\Start Menu\Programs.
        ; CSIDL_COMMON_STARTMENU            FOLDERID_CommonStartMenu    The file system directory that contains the programs And folders that appear on the Start menu For all users. A typical path is C:\Documents And Settings\All Users\Start Menu.
        ; CSIDL_COMMON_STARTUP              FOLDERID_CommonStartup      The file system directory that contains the programs that appear IN the Startup folder For all users. A typical path is C:\Documents And Settings\All Users\Start Menu\Programs\Startup.
        ; CSIDL_COMMON_TEMPLATES            FOLDERID_CommonTemplates    The file system directory that contains the templates that are available To all users. A typical path is C:\Documents And Settings\All Users\Templates.
        ; CSIDL_COMMON_VIDEO                FOLDERID_PublicVideos       Version 6.0. The file system directory that serves As a repository For video files common To all users. A typical path is C:\Documents And Settings\All Users\Documents\My Videos.
        ; CSIDL_COMPUTERSNEARME             FOLDERID_NetworkFolder      The folder that represents other computers IN your workgroup.
        ; CSIDL_CONNECTIONS                 FOLDERID_ConnectionsFolder  The virtual folder that represents Network Connections, that contains network And dial-up connections.
        ; CSIDL_CONTROLS                    FOLDERID_ControlPanelFolder The virtual folder that contains icons For the Control Panel applications.
        ; CSIDL_COOKIES                     FOLDERID_Cookies            The file system directory that serves As a common repository For Internet cookies. A typical path is C:\Documents And Settings\username\Cookies.
        ; CSIDL_DESKTOP                     FOLDERID_Desktop            The virtual folder that represents the Windows desktop, the root of the namespace.
        ; CSIDL_DESKTOPDIRECTORY            FOLDERID_Desktop            The file system directory used To physically store file objects on the desktop (Not To be confused With the desktop folder itself). A typical path is C:\Documents And Settings\username\Desktop.
        ; CSIDL_DRIVES                      FOLDERID_ComputerFolder     The virtual folder that represents My Computer, containing everything on the local computer: storage devices, printers, And Control Panel. The folder can also contain mapped network drives.
        ; CSIDL_FAVORITES                   FOLDERID_Favorites          The file system directory that serves As a common repository For the user's favorite items. A typical path is C:\Documents and Settings\username\Favorites.
        ; CSIDL_FONTS                       FOLDERID_Fonts              A virtual folder that contains fonts. A typical path is C:\Windows\Fonts.
        ; CSIDL_HISTORY                     FOLDERID_History            The file system directory that serves As a common repository For Internet history items.
        ; CSIDL_INTERNET                    FOLDERID_InternetFolder     A virtual folder For Internet Explorer.
        ; CSIDL_INTERNET_CACHE              FOLDERID_InternetCache      Version 4.72. The file system directory that serves As a common repository For temporary Internet files. A typical path is C:\Documents And Settings\username\Local Settings\Temporary Internet Files.
        ; CSIDL_LOCAL_APPDATA               FOLDERID_LocalAppData       Version 5.0. The file system directory that serves As a Data repository For local (nonroaming) applications. A typical path is C:\Documents And Settings\username\Local Settings\Application Data.
        ; CSIDL_MYDOCUMENTS                 FOLDERID_Documents          Version 6.0. The virtual folder that represents the My Documents desktop item. This value is equivalent To CSIDL_PERSONAL.
        ; CSIDL_MYMUSIC                     FOLDERID_Music              The file system directory that serves As a common repository For music files. A typical path is C:\Documents And Settings\User\My Documents\My Music.
        ; CSIDL_MYPICTURES                  FOLDERID_Pictures           Version 5.0. The file system directory that serves As a common repository For image files. A typical path is C:\Documents And Settings\username\My Documents\My Pictures.
        ; CSIDL_MYVIDEO                     FOLDERID_Videos             Version 6.0. The file system directory that serves As a common repository For video files. A typical path is C:\Documents And Settings\username\My Documents\My Videos.
        ; CSIDL_NETHOOD                     FOLDERID_NetHood            A file system directory that contains the link objects that may exist IN the My Network Places virtual folder. It is Not the same As CSIDL_NETWORK, which represents the network namespace root. A typical path is C:\Documents And Settings\username\NetHood.
        ; CSIDL_NETWORK                     FOLDERID_NetworkFolder      A virtual folder that represents Network Neighborhood, the root of the network namespace hierarchy.
        ; CSIDL_PERSONAL                    FOLDERID_Documents          Version 6.0. The virtual folder that represents the My Documents desktop item. This is equivalent To CSIDL_MYDOCUMENTS.
        ;Previous To Version 6.0. The file system directory used To physically store a user's common repository of documents. A typical path is C:\Documents and Settings\username\My Documents. This should be distinguished from the virtual My Documents folder in the namespace. To access that virtual folder, use SHGetFolderLocation, which returns the ITEMIDLIST for the virtual location, or refer to the technique described in Managing the File System.
        ; CSIDL_PRINTERS                    FOLDERID_PrintersFolder     The virtual folder that contains installed printers.
        ; CSIDL_PRINTHOOD                   FOLDERID_PrintHood          The file system directory that contains the link objects that can exist IN the Printers virtual folder. A typical path is C:\Documents And Settings\username\PrintHood.
        ; CSIDL_PROFILE                     FOLDERID_Profile            Version 5.0. The user's profile folder. A typical path is C:\Users\username. Applications should not create files or folders at this level; they should put their data under the locations referred to by CSIDL_APPDATA or CSIDL_LOCAL_APPDATA. However, if you are creating a new Known Folder the profile root referred to by CSIDL_PROFILE is appropriate.
        ; CSIDL_PROGRAM_FILES               FOLDERID_ProgramFiles       Version 5.0. The Program Files folder. A typical path is C:\Program Files.
        ; CSIDL_PROGRAM_FILESX86            FOLDERID_ProgramFilesX86    
        ; CSIDL_PROGRAM_FILES_COMMON        FOLDERID_ProgramFilesCommon Version 5.0. A folder For components that are Shared across applications. A typical path is C:\Program Files\Common. Valid only For Windows XP.
        ; CSIDL_PROGRAM_FILES_COMMONX86     FOLDERID_ProgramFilesCommonX86
        ; CSIDL_PROGRAMS                    FOLDERID_Programs           The file system directory that contains the user's program groups (which are themselves file system directories). A typical path is C:\Documents and Settings\username\Start Menu\Programs.
        ; CSIDL_RECENT                      FOLDERID_Recent             The file system directory that contains shortcuts To the user's most recently used documents. A typical path is C:\Documents and Settings\username\My Recent Documents. To create a shortcut in this folder, use SHAddToRecentDocs. In addition to creating the shortcut, this function updates the Shell's List of recent documents And adds the shortcut To the My Recent Documents submenu of the Start menu.
        ; CSIDL_RESOURCES                   FOLDERID_ResourceDir         Windows Vista. The file system directory that contains resource Data. A typical path is C:\Windows\Resources.
        ; CSIDL_RESOURCES_LOCALIZED         FOLDERID_LocalizedResourcesDir
        ; CSIDL_SENDTO                      FOLDERID_SendTo             The file system directory that contains Send To menu items. A typical path is C:\Documents And Settings\username\SendTo.
        ; CSIDL_STARTMENU                   FOLDERID_StartMenu          The file system directory that contains Start menu items. A typical path is C:\Documents And Settings\username\Start Menu.
        ; CSIDL_STARTUP                     FOLDERID_Startup            The file system directory that corresponds To the user's Startup program group. The system starts these programs whenever the associated user logs on. A typical path is C:\Documents and Settings\username\Start Menu\Programs\Startup.
        ; CSIDL_SYSTEM                      FOLDERID_System             Version 5.0. The Windows System folder. A typical path is C:\Windows\System32.
        ; CSIDL_SYSTEMX86                   FOLDERID_SystemX86          
        ; CSIDL_TEMPLATES                   FOLDERID_Templates          The file system directory that serves As a common repository For document templates. A typical path is C:\Documents And Settings\username\Templates.
        ; CSIDL_WINDOWS                     FOLDERID_Windows            Version 5.0. The Windows directory Or SYSROOT. This corresponds To the %windir% Or %SYSTEMROOT% environment variables. A typical path is C:\Windows.
        
        ; Flags
        ; CSIDL_FLAG_CREATE                 KF_FLAG_CREATE              Version 5.0. Combine With another CSIDL To force the creation of the associated folder If it does Not exist.
        ; CSIDL_FLAG_DONT_UNEXPAND          KF_FLAG_DONT_UNEXPAND       Combine With another CSIDL constant To ensure the expansion of environment variables.
        ; CSIDL_FLAG_DONT_VERIFY            KF_FLAG_DONT_VERIFY         Combine With another CSIDL constant, except For CSIDL_FLAG_CREATE, To Return an unverified folder path With no attempt To create Or initialize the folder.
        ; CSIDL_FLAG_NO_ALIAS               KF_FLAG_NO_ALIAS            Combine With another CSIDL constant To ensure the retrieval of the true system path For the folder, free of any aliased placeholders such As %USERPROFILE%, returned by SHGetFolderLocation. This flag has no effect on paths returned by SHGetFolderPath.
        ; CSIDL_FLAG_PER_USER_INIT          
        ; CSIDL_FLAG_MASK              A mask For any valid CSIDL flag value.                
    EndProcedure        
   EndModule

    
    
CompilerIf #PB_Compiler_IsMainFile
    
;   iResult = FFH::GetFileDownload("http://www.rsbasic.de/downloads/life_in_slavery.zip")
;   Debug iResult
  
  iResult$ = FFH::GetFilePath("", "B:\Roms\",#True,#True,#True,"",#CSIDL_DRIVES)
  Debug iResult$        
  
;   iResult$ = FFH::GetFilePBRQ("Test","X:\")
;   Debug iResult$
;   
;   iResult$ = FFH::GetPathPBRQ("Test","X:")
;   Debug iResult$        
;   
;   Result = FFH::ShellExec("C:\Zwischenablage.txt","properties","",#SEE_MASK_INVOKEIDLIST,#SW_SHOW)
;   Debug Result
;   
;   Debug FFH::GetClSIDPath(FFH::?FOLDERID_SavedGames)
;   
;   Debug FFH::GetClSIDVariable("%DESKTOP%\Test\MyGames\Gears Of War\")
;   Debug FFH::SetClSIDVariable("C:\Users\desktop\MyGames\Gears of War\") 
;   
;   Size.q = FFH::GetFreeHDSpace("C:",0)
;   
;   Debug FFH::ConvertHDSize(Size.q)  
;   
;   
;   
;   File$ = #PB_Compiler_Home + "SDK\VisualC\Readme.txt"
;   FFH::SH_OpenWithDialog_(File$,FFH::#OAIF_ALLOW_REGISTRATION|FFH::#OAIF_EXEC)


CompilerEndIf
    
    


; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1949
; FirstLine = 1146
; Folding = vPoAB3
; EnableAsm
; EnableXP
; CurrentDirectory = ..\..\..\System Platform\Maschines - Arcade Mame Derivats\MAME\
; EnableUnicode