;..............................................................................................................
; Windows Firewall with Advanced Security - Add application rule
; SFSxOI - 5 August 2008

;///////////////////////// Special Thanks //////////////////////////////
; Special thanks to srod for helping me out when i had it so screwed up
;///////////////////////////////////////////////////////////////////////

; MSDN references used:
; http://msdn.microsoft.com/en-us/library/aa366418(VS.85).aspx
; http://msdn.microsoft.com/en-us/library/aa366459(VS.85).aspx
; http://msdn.microsoft.com/en-us/library/aa364695(VS.85).aspx

; Notes:
; Interfaces below include the IDispatch methods and are generated With OLECOM Interface generator v0.2 by S.M.
; http://www.purebasic.fr/english/viewtopic.php?t=23370
; Thanks for a great tool S.M.
; rules created in this manner are classed as pre-defined so some items can not be changed
; if you mess something up just delete the rule in the firewall interface and start over
;.................................................................................................................


DeclareModule ClassFirewall
    
        Enumeration enumWF
            #NET_FW_PROFILE2_DOMAIN     = $0001              ;Profile type is domain.
            #NET_FW_PROFILE2_PRIVATE    = $0002              ;Profile type is private. This profile type is used for home and other private network types.
            #NET_FW_PROFILE2_PUBLIC     = $0004              ;Profile type is public. This profile type is used for public Internet access points.
            #NET_FW_PROFILE2_ALL        = $7FFFFFFF   
    
            #NET_FW_ACTION_BLOCK        =0                   ;Block traffic.
            #NET_FW_ACTION_ALLOW        =1                   ;Allow traffic.
            #NET_FW_ACTION_MAX          =2                   ;Maximum traffic.
    
            #NET_FW_RULE_DIR_IN         =1                   ;The rule applies To inbound traffic.
            #NET_FW_RULE_DIR_OUT        =2                   ;The rule applies To outbound traffic. 
            #NET_FW_RULE_DIR_MAX        =3                   ;This value is used for boundary checking only and is not valid for application programming.
       
            #NET_FW_MODIFY_STATE_OK                 =1      ;Changing Or adding a firewall rule Or firewall group To the current profile will take effect.
            #NET_FW_MODIFY_STATE_GP_OVERRIDE        =2      ;Changing Or adding a firewall rule Or firewall group To the current profile will Not take effect
                                                            ;because the profile is controlled by the group policy.
            #NET_FW_MODIFY_STATE_INBOUND_BLOCKED    =3      ;Changing or adding a firewall rule or firewall group to the current profile will not take effect                                                        ;because unsolicited inbound traffic is Not allowed.
    
            #NET_FW_IP_PROTOCOL_TCP     = 6
            #NET_FW_IP_PROTOCOL_UDP     = 17
            #NET_FW_IP_PROTOCOL_ANY     = 256
    
            #NET_FW_RULE_CATEGORY_BOOT      = $0000 ;Specifies boot time filters.
            #NET_FW_RULE_CATEGORY_STEALTH   = $0001 ;Specifies stealth filters.
            #NET_FW_RULE_CATEGORY_FIREWALL  = $0002 ;Specifies firewall filters.
            #NET_FW_RULE_CATEGORY_CONSEC    = $0003 ;Specifies connection security filters.
            #NET_FW_RULE_CATEGORY_MAX       = $0004 ;Maximum value For testing purposes. 
        EndEnumeration

        Declare.i   Rule(RuleName.s, 
                         Descr.s    = "",
                         Path.s     = "",
                         AddRemove  = #True,
                         Protcol.i  = #NET_FW_IP_PROTOCOL_ANY,
                         PortLocal.s= "",
                         PortRemte.s= "",
                         Enabled.l  = #VARIANT_TRUE,
                         Group.s    = "",
                         Block.i    = #NET_FW_ACTION_BLOCK,
                         Profile.l  = #NET_FW_PROFILE2_ALL,
                         InOut      = 0)
        
        Declare.i   Set(ProgramPath.s, Blocking.s, ProfileType.i, RuleName.s, Description.s, Protocol.i, AddRemove.i = #True)
        Declare.i   Del(Rulename.s)
        
EndDeclareModule


Module ClassFirewall      
    ;
    ;..............................................................................................................   
    CompilerIf Defined(INetFwPolicy2,#PB_Interface) = #False
        Interface INetFwPolicy2
            QueryInterface(riid.l,ppvObj.l)
            AddRef()
            Release()
            GetTypeInfoCount(pctinfo.l)
            GetTypeInfo(itinfo.l,lcid.l,pptinfo.l)
            GetIDsOfNames(riid.l,rgszNames.l,cNames.l,lcid.l,rgdispid.l)
            Invoke(dispidMember.l,riid.l,lcid.l,wFlags.l,pdispparams.l,pvarResult.l,pexcepinfo.l,puArgErr.l)
            get_CurrentProfileTypes(dispidMember.l)
            get_FirewallEnabled(profileType.l)
            put_FirewallEnabled(profileType.l,riid.w)
            get_ExcludedInterfaces(profileType.l)
            put_ExcludedInterfaces(profileType.l,riid.p-variant)
            get_BlockAllInboundTraffic(profileType.l)
            put_BlockAllInboundTraffic(profileType.l,riid.w)
            get_NotificationsDisabled(profileType.l)
            put_NotificationsDisabled(profileType.l,riid.w)
            get_UnicastResponsesToMulticastBroadcastDisabled(profileType.l)
            put_UnicastResponsesToMulticastBroadcastDisabled(profileType.l,riid.w)
            get_Rules(profileType.l)
            get_ServiceRestriction(profileType.l)
            EnableRuleGroup(profileTypesBitmask.l,group.p-bstr,enable.w)
            IsRuleGroupEnabled(profileTypesBitmask.l,group.p-bstr)
            RestoreLocalFirewallDefaults()
            get_DefaultInboundAction(profileType.l)
            put_DefaultInboundAction(profileType.l,group.l)
            get_DefaultOutboundAction(profileType.l)
            put_DefaultOutboundAction(profileType.l,group.l)
            get_IsRuleGroupCurrentlyEnabled(group.p-bstr)
            get_LocalPolicyModifyState(group.l)
        EndInterface
    CompilerEndIf
    ;    
    ;..............................................................................................................    
    CompilerIf Defined(INetFwRule,#PB_Interface) = #False
        Interface INetFwRule
            QueryInterface(riid.l,ppvObj.l)
            AddRef()
            Release()
            GetTypeInfoCount(pctinfo.l)
            GetTypeInfo(itinfo.l,lcid.l,pptinfo.l)
            GetIDsOfNames(riid.l,rgszNames.l,cNames.l,lcid.l,rgdispid.l)
            Invoke(dispidMember.l,riid.l,lcid.l,wFlags.l,pdispparams.l,pvarResult.l,pexcepinfo.l,puArgErr.l)
            get_Name(dispidMember.l)
            put_Name(dispidMember.p-bstr)
            get_Description(dispidMember.q)
            put_Description(dispidMember.p-bstr)
            get_ApplicationName(dispidMember.l)
            put_ApplicationName(dispidMember.p-bstr)
            get_serviceName(dispidMember.l)
            put_serviceName(dispidMember.p-bstr)
            get_Protocol(dispidMember.l)
            put_Protocol(dispidMember.l)
            get_LocalPorts(dispidMember.l)
            put_LocalPorts(dispidMember.p-bstr)
            get_RemotePorts(dispidMember.l)
            put_RemotePorts(dispidMember.p-bstr)
            get_LocalAddresses(dispidMember.l)
            put_LocalAddresses(dispidMember.p-bstr)
            get_RemoteAddresses(dispidMember.l)
            put_RemoteAddresses(dispidMember.p-bstr)
            get_IcmpTypesAndCodes(dispidMember.l)
            put_IcmpTypesAndCodes(dispidMember.p-bstr)
            get_Direction(dispidMember.q)
            put_Direction(dispidMember.l)
            get_Interfaces(dispidMember.l)
            put_Interfaces(dispidMember.p-variant)
            get_InterfaceTypes(dispidMember.l)
            put_InterfaceTypes(dispidMember.p-bstr)
            get_Enabled(dispidMember.l)
            put_Enabled(dispidMember.w)
            get_Grouping(dispidMember.l)
            put_Grouping(dispidMember.p-bstr)
            get_Profiles(dispidMember.l)
            put_Profiles(dispidMember.l)
            get_EdgeTraversal(dispidMember.l)
            put_EdgeTraversal(dispidMember.w)
            get_Action(dispidMember.l)
            put_Action(dispidMember.l)
        EndInterface
    CompilerEndIf
    ;
    ;..............................................................................................................    
    CompilerIf Defined(INetFwRules,#PB_Interface) = #False
        Interface INetFwRules
            QueryInterface(riid.l,ppvObj.l)
            AddRef()
            Release()
            GetTypeInfoCount(pctinfo.l)
            GetTypeInfo(itinfo.l,lcid.l,pptinfo.l)
            GetIDsOfNames(riid.l,rgszNames.l,cNames.l,lcid.l,rgdispid.l)
            Invoke(dispidMember.l,riid.l,lcid.l,wFlags.l,pdispparams.l,pvarResult.l,pexcepinfo.l,puArgErr.l)
            get_Count(dispidMember.l)
            Add(rule.l)
            Remove(Name.p-bstr)
            Item(Name.p-bstr)
            get__NewEnum(Name.l)
        EndInterface
    CompilerEndIf
    ;
    ;..............................................................................................................              
    Procedure.i Rule(RuleName.s, 
                   Descr.s    = "",
                   Path.s     = "",
                   AddRemove  = #True,
                   Protcol.i  = #NET_FW_IP_PROTOCOL_ANY,
                   PortLocal.s= "",
                   PortRemte.s= "",
                   Enabled.l  = #VARIANT_TRUE,
                   Group.s    = "",
                   Block.i    = #NET_FW_ACTION_BLOCK,
                   Profile.l  = #NET_FW_PROFILE2_ALL,
                   InOut      = 0)
        
        CoInitialize_(0)
        
        If CoCreateInstance_( ?CLSID_NetFwPolicy2,0,1,?IID_INetFwPolicy2,@fwPolicy2_obj.INetFwPolicy2 ) = #S_OK
            
 
                fwPolicy2_obj\get_Rules( @RulesObject.INetFwRules )
            i = fwPolicy2_obj\get_CurrentProfileTypes( @CurrentProfile )

            If CoCreateInstance_( ?CLSID_NetFwRule,0,1,?IID_INetFwRule,@NewRule_obj.INetFwRule ) = #S_OK
                NewRule_obj\put_Name(RuleName)
                NewRule_obj\put_Description(Descr)
                NewRule_obj\put_ApplicationName(Path)
                NewRule_obj\put_Protocol(Protcol)
                
                If ( PortLocal <>"" )
                    NewRule_obj\put_LocalPorts( PortLocal )
                EndIf 

                Select InOut
                    Case 0: NewRule_obj\put_Direction(#NET_FW_RULE_DIR_IN)  ; default                      
                    Case 1: NewRule_obj\put_Direction(#NET_FW_RULE_DIR_IN)  ; in bound side rule
                    Case 2: NewRule_obj\put_Direction(#NET_FW_RULE_DIR_OUT) ; out bound side rule
                EndSelect
                
                
                If ( PortRemte <> "" )
                    NewRule_obj\put_RemotePorts( PortRemte )
                EndIf
                
                NewRule_obj\put_Enabled( Enabled )
                NewRule_obj\put_Grouping( Group )
                
                If Profile = #Null
                    NewRule_obj\put_Profiles( CurrentProfile )
                Else
                    NewRule_obj\put_Profiles( Profile )
                EndIf
                
                NewRule_obj\put_Action( Block )
                
                Select AddRemove
                    Case #True:  RulesObject\Add( NewRule_obj )
                    Case #False: RulesObject\Remove( RuleName )    
                EndSelect
                           
                NewRule_obj\Release(): RulesObject\Release(): CoUninitialize_()
                
                ;Debug fwPolicy2_obj\get_FirewallEnabled( )
                ;Debug fwPolicy2_obj\get_Rules( @RulesObject.INetFwRules )
                
                ProcedureReturn #True                
            Else
                NewRule_obj\Release(): RulesObject\Release(): CoUninitialize_()
                ProcedureReturn #False
            EndIf
        Else
            CoUninitialize_()
            ProcedureReturn #False
        EndIf
    EndProcedure
    ;.............................................................................................................. 
    Procedure.i Set(ProgramPath.s, Blocking.s, ProfileType.i, RuleName.s, Description.s, Protocol.i, AddRemove.i = #True)
        
        Protected Executable.s, Block.i, Profile.l, Result.i
        
        Executable  = GetFilePart(ProgramPath, #PB_FileSystem_NoExtension)        
        Path.s       = ProgramPath
        Group.s     = "LH.Game(Start,i)"
        Description = "Acitvated and Configuration with "+Description+"."
                                    
        Debug "Firewall Rule : "+Rulename
        Debug "Firewall Path : "+Path
        Debug "Firewall Group: "+Group
        Debug "Description   : "+Description
        
        Select UCase(Blocking)
            Case "BLOCK"    :Block = #NET_FW_ACTION_BLOCK                          :Debug "Firewall Block: NET_FW_ACTION_BLOCK"
            Case "ALLOW"    :Block = #NET_FW_ACTION_ALLOW                          :Debug "Firewall Block: NET_FW_ACTION_ALLOW" 
            Case "BYPASS"   :Block = #NET_FW_ACTION_MAX                            :Debug "Firewall Block: NET_FW_ACTION_MAX  "
        EndSelect
        
        Select ProfileType
            Case 1  :Profile =  #NET_FW_PROFILE2_DOMAIN                            :Debug "Firewall Profile: NET_FW_PROFILE2_DOMAIN"
            Case 2  :Profile =  #NET_FW_PROFILE2_PUBLIC                            :Debug "Firewall Profile: NET_FW_PROFILE2_PUBLIC"
            Case 3  :Profile =  #NET_FW_PROFILE2_PRIVATE                           :Debug "Firewall Profile: NET_FW_PROFILE2_PRIVATE"
            Case 4  :Profile =  #NET_FW_PROFILE2_DOMAIN|#NET_FW_PROFILE2_PUBLIC    :Debug "Firewall Profile: NET_FW_PROFILE2_DOMAIN | NET_FW_PROFILE2_PUBLIC"
            Case 5  :Profile =  #NET_FW_PROFILE2_PRIVATE|#NET_FW_PROFILE2_PUBLIC   :Debug "Firewall Profile: NET_FW_PROFILE2_PRIVATE| NET_FW_PROFILE2_PUBLIC"
            Case 6  :Profile =  #NET_FW_PROFILE2_PRIVATE|#NET_FW_PROFILE2_DOMAIN   :Debug "Firewall Profile: NET_FW_PROFILE2_PRIVATE| NET_FW_PROFILE2_DOMAIN"
            Case 7  :Profile =  #NET_FW_PROFILE2_ALL                               :Debug "Firewall Profile: #NET_FW_PROFILE2_ALL"
        EndSelect
                                   
        Result = Rule(Rulename, Description, Path, AddRemove, #NET_FW_IP_PROTOCOL_TCP, "", "", #VARIANT_TRUE, Group, Block, Profile, 0)
        ProcedureReturn Result

    EndProcedure
    ;..............................................................................................................
    Procedure.i Del( Rulename.s )
        Protected Result.i = #False
        
        If (Len(Rulename ) > 0)
            Result = Rule(Rulename, "", "", #False)
            Debug "Firewall Rue Deleted: "+ Rulename            
        EndIf                        
        ProcedureReturn Result
    EndProcedure
    ;..............................................................................................................
    
    DataSection
        CLSID_NetFwPolicy2:
        Data.l $E2B3C97F
        Data.w $6AE1,$41AC
        Data.b $81,$7A,$F6,$F9,$21,$66,$D7,$DD
        IID_INetFwPolicy2:
        Data.l $98325047
        Data.w $C671,$4174
        Data.b $8D,$81,$DE,$FC,$D3,$F0,$31,$86
        CLSID_NetFwRule:
        Data.l $2C5BC43E
        Data.w $3369, $4C33
        Data.b $AB,$0C,$BE,$94,$69,$67,$7A,$F4
        IID_INetFwRule:
        Data.l $AF230D27
        Data.w $BABA,$4E42
        Data.b $AC,$ED,$F5,$24,$F2,$2C,$FC,$E2
        IID_INetFwRules:
        Data.l $9C4C6277
        Data.w $5027, $441E
        Data.b $AF,$AE,$CA,$1F,$54,$2D,$A0,$09
    EndDataSection   
EndModule



; example information only - use real information for your project

;     Rulename$         = "Application Name"
;     Description$      = "Allow my application network traffic"
;     Path$             = "%systemDrive%\\Program Files\\MyApplication.exe"
;     Protcol.l         = #NET_FW_IP_PROTOCOL_TCP,#NET_FW_IP_PROTOCOL_UDP,#NET_FW_IP_PROTOCOL_ANY
;     LocalPorts$       = "4000,5000"
;     RemotePorts$      = "1000,3000"
;     Enabled.l         = #VARIANT_TRUE, #VARIANT_FALSE (Disable)
;     Group$            = "MyProject"
;     Block             = #NET_FW_ACTION_MAX,#NET_FW_RULE_DIR_IN,#NET_FW_RULE_DIR_IN
;     Profile.l         = #NET_FW_PROFILE2_ALL,#NET_FW_PROFILE2_PUBLIC,#NET_FW_PROFILE2_PRIVATE,#NET_FW_PROFILE2_DOMAIN
;     INOUT             = "Ausgehend" = 2/ "Eingehend"=1 / 0 = "Standard"; rule direction
;     ADDREMOVE         = #True for Adding, #False to Remove  
; 
;     ;Note: group.s can also be an indexed group name in a .dll like this "@firewallapi.dll,-23255"
; 
;     ; creating an inbound and outbound rule
;     
;     Debug "Add Firewall Rule: "+rulename_x
;     
;     Firewall_Rule(rulename_x.s, descrip_x.s, app_path_x.s, proto_x.l, loc_port_x.s, rmt_port_x.s, enab_x.l, group_x.s, block_allow_x.l, profile_x.l, in_out_x.s, #True)
;     Delay(18000)
; ;in_out_x.s = "in"
; 
;     Debug "Remove Firewall Rule: "+rulename_x
;..............................................................................................................  
CompilerIf #PB_Compiler_IsMainFile ; Test    
    ClassFirewall::Rule("123456789","A-Programm","C:\Windows\Notepad.exe",#True,ClassFirewall::#NET_FW_IP_PROTOCOL_TCP)
    ClassFirewall::Rule("123456789","A-Programm","C:\Windows\Notepad.exe",#True,ClassFirewall::#NET_FW_IP_PROTOCOL_UDP)    
    ClassFirewall::Rule("123456789","A-Programm","C:\Windows\Notepad.exe",#False,ClassFirewall::#NET_FW_IP_PROTOCOL_TCP)
    ClassFirewall::Rule("123456789","A-Programm","C:\Windows\Notepad.exe",#False,ClassFirewall::#NET_FW_IP_PROTOCOL_UDP)    
CompilerEndIf

; IDE Options = PureBasic 5.73 LTS (Windows - x86)
; CursorPosition = 254
; FirstLine = 38
; Folding = D-
; EnableAsm
; EnableXP
; EnableUnicode