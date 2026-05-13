EnableExplicit

#XML = 1
Declare ParseInstallSteps(*StepsNode)
Declare ParseOptionalGroups(*GroupNode)
	
Procedure Main()
    Define xmlFile.s = "B:\Fomod-Install\fomod\ModuleConfig.xml"   ; Pfad anpassen
        
    ; XML laden
    If LoadXML(#XML, xmlFile) = 0
        MessageRequester("Fehler", "XML konnte nicht geladen werden: " + Str(XMLStatus(#XML)))
        ProcedureReturn
    EndIf
    
    Debug GetXMLEncoding(#XML)
    
    Define *MainNode = MainXMLNode(#XML)
    If *MainNode = 0
        MessageRequester("Fehler", "Kein Haupt-Node gefunden")
        FreeXML(#XML)
        ProcedureReturn
    EndIf
    
    ; Debug-Ausgabe der gesamten Struktur (sehr hilfreich)
    Debug "=== XML geladen ==="
    Debug "Root: " + GetXMLNodeName(*MainNode)
    
    ; Beispiel: moduleName auslesen
    Define *Node = ChildXMLNode(*MainNode)
    While *Node
        If GetXMLNodeName(*Node) = "moduleName"
            Debug "Mod-Name: " + GetXMLNodeText(*Node)
        EndIf
        
        ; InstallSteps durchgehen (die eigentlichen Installations-Schritte)
        If GetXMLNodeName(*Node) = "installSteps"
            ParseInstallSteps(*Node)
        EndIf
        
        *Node = NextXMLNode(*Node)
    Wend
    
    FreeXML(#XML)
EndProcedure

; =============================================
; Unterprozedur zum Parsen der Installations-Schritte
; =============================================
Procedure ParseInstallSteps(*StepsNode)
    Define *Step = ChildXMLNode(*StepsNode)
    
    While *Step
        If GetXMLNodeName(*Step) = "installStep"
            Define stepName.s = GetXMLAttribute(*Step, "name")
            Debug "? Install Step: " + stepName
            
            ; Jetzt die Gruppen (Options-Gruppen) durchgehen
            Define *GroupNode = ChildXMLNode(*Step)
            While *GroupNode
                If GetXMLNodeName(*GroupNode) = "optionalFileGroups"
                    ParseOptionalGroups(*GroupNode)
                EndIf
                *GroupNode = NextXMLNode(*GroupNode)
            Wend
        EndIf
        *Step = NextXMLNode(*Step)
    Wend
EndProcedure

Procedure ParseOptionalGroups(*GroupsNode)
    Define *Group = ChildXMLNode(*GroupsNode)
    
    While *Group
        If GetXMLNodeName(*Group) = "group"
            Define groupName.s = GetXMLAttribute(*Group, "name")
            Define groupType.s = GetXMLAttribute(*Group, "type")  ; SelectExactlyOne, SelectAtLeastOne usw.
            
            Debug ""
            Debug ""
            Debug "====================================================="
            
            Debug "   Gruppe: " + groupName + "  (Type: " + groupType + ")"    
            
            Select groupType
            	Case "SelectAll"
            	Case "SelectExactlyOne"
            	Case "SelectAllAny"
            	Default        		
          	EndSelect
                                   
            ; Plugins (die eigentlichen Optionen)
          	Define *Plugins = ChildXMLNode(*Group)	
            While *Plugins
            	If GetXMLNodeName(*Plugins) = "plugins" ; Explicit
           		
            		;
            		;
            		Define *Plugin = ChildXMLNode(*Plugins)
            		While *Plugin            			
            			If GetXMLNodeName(*Plugin) = "plugin"
            				
            				;
										;
            				Debug "Plugin Name: " + GetXMLAttribute(*Plugin, "name"); 
            				
            				Define *Description = ChildXMLNode(*Plugin)
            				While *Description
            					
            					If GetXMLNodeName(*Description) = "description"
            						Define Description.s = ""
            						Define XMLEncode.i   = GetXMLEncoding(#XML)
            						
            						SetXMLEncoding(#XML, #PB_Ascii)
            						Description =  Chr(13) + GetXMLNodeText(*Description)
            						SetXMLEncoding(#XML, XMLEncode)
            						Debug "=---------------------------------------------------="
            						Debug "Description : " + Description
            						Debug "=---------------------------------------------------="           						
            					EndIf
            					
            					;
            					;
            					If GetXMLNodeName(*Description) = "files"
            						Define *Folder = ChildXMLNode(*Description)            						
            						If GetXMLNodeName(*Folder) = "folder" Or GetXMLNodeName(*Folder) = "file"
            							While *Folder
            								
            								Define Priority.s 		= GetXMLAttribute(*Folder, "priority")
            								Define Destination.s = ".\Data\" + GetXMLAttribute(*Folder, "destination")
            								Define source.s      = "..\" + GetXMLAttribute(*Folder, "source")            								          								 
            								
            								Debug "Priority         : " + Priority           								
            								Debug "Quell-Verzeichnis: " + source            								
            								Debug "Ziel-Verzeicznis : " + Destination
            								
            								*Folder = NextXMLNode(*Folder) 
            							Wend	
            						EndIf
            					EndIf	
            					
            					;
            					;
            					If GetXMLNodeName(*Description) = "typeDescriptor"            						
            						Define *tDescriptor = ChildXMLNode(*Description)
            						If GetXMLNodeName(*tDescriptor) = "type"
            							While *tDescriptor
            								Debug "Select           : " + GetXMLAttribute(*tDescriptor, "name")
            								
            								*tDescriptor = NextXMLNode(*tDescriptor) 
            							Wend
            						EndIf            						
            					EndIf
            					
            					*Description = NextXMLNode(*Description) 
            				Wend            				            			            		
            				
            			EndIf
            			*Plugin = NextXMLNode(*Plugin)        			
            		Wend
            	EndIf
            	
              *Plugins = NextXMLNode(*Plugins)
            Wend
        EndIf
        *Group = NextXMLNode(*Group)
    Wend
EndProcedure

Procedure Parse_PluginsOrder(*Group)  		
EndProcedure
Main()
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 111
; FirstLine = 75
; Folding = -
; EnableAsm
; EnableXP