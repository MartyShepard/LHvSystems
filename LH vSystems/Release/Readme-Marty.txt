Was ist vSystems?

vSystems ist ein Window Programm Launcher der darauf ausgelegt ist
Spiele, Emulatoren, Ports aber auch Programme zu starten mit 
dem Schwerpunkt auf Flexibilität.

Es ist Kein Massen-Sammler-Starter mit für 5Millioenen Spiele.
 
Es ist mehr für Spiele Serien gedacht die sich über mehre Epochen
und Systeme erschienen. Wo gleichzeitig Notizen und Screenshots/Box Covers hinzufügen kann. Desweiteren eine große Sammlung an Kompatibilitäts und Feature einstellungen für die Programme (Spiele,Emulatoren, Ports etc..).
Es dient aber auch dazu um zum beispiel ein Spiel in dem Zustand in dem man es hat und es funktioniert nach jahren mit 
diesen zustand, quasi ein "Snapshot" mit einstellungen wieder
zu Spielen ohne neu einstellungen der Konfiguration (Registry/ Home User Spiecher Stände, wo war was etc..)

vSystems selbst habe ich so konzipiert das es
* Komplett Portabel ist
* Keine Registry Einstellung nutzt
* Keine Home User einstellung nutzt
* Das die vSytems.exe nicht größer als ~6 Megabyte wird
  mit allen PNG's in der Exe.
  Mit UPX schrumpt das programm (64Bit) auf ~2MB.
* Das man vSystems im Laufden betrieb umbennen kann
* Das man vSystems im Laufden betrieb kopieren kann 
* Das man die Datenbank Laufden betrieb kopieren kann.
* Features werden durch eine Integrierte Kommandline
  an das Programm bereitgestellt ohne das deren Kommandline
  in die Queere kommt.

Die Features die vSystems bereitstellt:
* Portabilität der eingerichteten Programme
* Screenshot veraltung
* Text Verwaltung
* Import und Export von Spielständen
* Registry import und Export
* Große Komptibilitäts verwaltung
* Unterstützung für:
  - Engines (Unity/ Unreal)
  - Ports
  - Emulatoren
* Screenshot vom Laufende Programm (Spiel etc..) machen
* Monitoring (Was passiert auf dem Homedrive und wo legt
  das verdammte Spiel seine Einstellungen ab)
* Firewall Blockierung des Programs
* Prozessor Kern Einstellung
* Borderless Fenster einstellung für nahezu jedes Programm
  (selbst alte Spiele)
* Hotkeys
* Übergabe von Archiven and das programm welches das nicht
  Unterstützt

Auf die einzelnen Punkte gehe ich später in einer Art Tuorial ein

Sämtliche Einstellungen werden beim erst Start an angelgten
Datenbank gespeichert. Screenshots werden in einer Seperaten
Datenbank gesichert.
.\Systeme\DATA\VSYSDB\BASE.DB (Für Sämtliche Einstellungen)
.\Systeme\DATA\VSYSDB\PICT.DB (Für Screenshots)

Beim ersten Start werden nur diese 2 Dateien anglegt.
Dazu existiert zeitgleich ein Piktogramm in der Taskbar
wo man schnell Einstellungen vornehmen kann.

Das Fenster ist so benutzer Freundlich Aufgbaut wie ich es am
persönlichsten finde ohne große verschachtelungen aber mit 
ein wenig Präsenz.

[Screenshot vom Leeren vSytems Fenster]

Das Design hatte ich schon jahre vorher
erstellt bis Windows 8 mit seinem Flachen Design herkam.
Sowie die dunklen FarbTöne (Darkmode).

Handhabung Bedienung:
Verschieben des Fenster:
- Titelleiste oben und unten

[ New      ]
 * Neuen Eintrag erstellen. 

[ Duplicate]
* Aktuelle markierte Eintrag wird dupliziert
  (Bei Screenshots wird mnnachgefragt ob die mitdupliziert
   werden sollen)

[ Delete   ] Hotkey (Delete)
* Eintrag löschen/ bzw alle löschen

[ Edit     ]
* Es wird in einem Hintergrund des Fenster umgeschaltet und
  wo man sämtliche einstellungen vornehmen kann.
  (Dazu später)

[ Infos    ]
* Es wird ein integrierter Text Editor Geöffnet
  (Dazu später)

[ Start    ] Hotkey (Return)
* Erklärt von selbst



Die Screenshots abteilung läßt sich mit dem Splitter Balken
verschieben (Hoch und Runter). Sobald ein Bild importiert
wurde kann man mit der Rechten Taste ein Popupmenü öffnen.
Insgesamt könne für jeden Eintrag 50 Bilder gespeichert
werden. Datei größe von System Achitektur abhängig.

[ Bild von der Screenshot sektion ]

Unterstützung der Bildformate:
BMP, GIF (Keine Animation), ICO, JP[E]G, PCX, PNG, TARGA,
TIFF, AMiga ILBM, Texture DDS

Doppel Maus Klick auf das Thumbnail zeigt das Bild an

Hotkeys:
F5 = Thumbnails vergrößern
F6 = Thumbnails verkleinern
Numpad 4 = Thumbnails zwischenbreich Vertikal vergrößern
Numpad 6 = Thumbnails zwischenbreich Vertikal verkleinern
Numpad 8 = Thumbnails zwischenbreich Horizontal vergrößern
Numpad 2 = Thumbnails zwischenbreich Horizontal verkleinern


Importieren der Bild Datei kann auf 3 Wegen erreicht
werden:
1. Drag'n'Drop (Screenshot auf das Thumbnail ablegen)
2. Kopieren und einfügen (Popup Menü)
3. Bild Laden (Popup Menü)

PopupMenü Beschreibung: [Bild vom Popup Menpü]
Bild Laden           : Selbtst erklärend
Dieses Bild Speichern: Das Aktuelle importierte Bild speichern
Alle Bilder Speichern: Alle Screenshots des Aktullen Eintrags
                       werden gespeichert

Bild Kopieren        : Screenshot wird in die Zwischenbalge 
                       gesichert

Bild einfügen        : Das Bild wir in den akuellen Thumbnail
                       Importiert

Dieses Bild Löschen  : Das Bild wird gelöscht
Alle Bilder löschen  : Alle Bilder des Auktuellen Eintrag
                       werden gelöscht

Splitter Höhe einstellen: Mauelle Eingabe der Splitterhöhe
Gleiche höhe für alle.. : Die Splitterhöhe wird akuelle für
                          alle Einträge gleichgesetzt


Thumnail Zurücksetzten: Die Standard größe für die Thumbnails  
                        wird eingestellt und zurückgesetzt.
Gleiche höhe für alle.. : Alle Thumbnails von allen Einträgen 
                          bekommen die selbe höhe.

1x1 bis 6x1: Bezieht sich auf die Einstellbare größe der 
             Thumbnails je Reihe

bei 1x1 ist das Thumbnail genauso groß wie das Fenster
bei 6x1 sind es 6 Thumbnail Pro Reihe

Thumnail Höhen Option: Wieviele Thumbnail mit dem Splitter
angezigt werden sollen: 1-4 beszieht sich dann auf die 
Splitter höhe. Bei 1 Konfiguriert sich die Splitter höhe
auf die größe (Höhe) der Thumbnails. Bei 4 würde der Splitter
dann 4 Reihen präsentieren unabhängig von der Thumbnial Reihen
Option.

Information: Anzeige was für ein Bild Format/Größe und weite
             Importiert wurde.


Einstellungs Fenster: [Screenshot des Einstellungs Fenster]
Hier lassen sich folgen Einträge verwalten:
[ Title     ]: Spiele Titel
[ SubTitle  ]: Optional der Untertitel.
               * Je nach zeichen ob "-" oder ":" wird
                 der Titel in ader Ansicht mit einem
                 Bindestrich angezeigt.

[Release   ]: Über Eingabe in dem Format Jahr/Monat/Datum oder
              mit dem Klick auf dem Kalender daneben.

Die Folgenden Eingabefelder (Strings) können mit einem
Doppelklick geöffnet werden und es erscheint je ein
Weiteres Fenster mit Auswahl und Editier möglchkeit.
[ Language ]: Sprach Auswahl
[ Platform ]: Platform auswahl.
              Von Amiga, PC, Xbox bis zu ZX Spectrum.

[Programm Einstellung] "Start: Emulator/Port or Nativ" und
[Commandline         ] öffnet ein und dasselbe Fenster
Ohne das weitere Fenster zu öffnen kann man den Namen und die Commandline direkt Editieren.

Mit einem Doppelklick in diese Eingabefelder öffnet sich ein Fenster wo man die Programme verwalten kann.
[ New     ] : Fügt ein weiteren Programm Eintrag hinzu
[Duplicate] : Dupliziert den aktuellen Eintrag
[ Delete  ] : Löscht den aktuellen Eintrag
[ Save    ] : Speichert die Neue oder Auktuelle änderung
[ OK      ] : Schließt das Fenster.

Die beiden EIngabeflder können auch mit Drag'n'Drop bedient werden oder miteinem Doppleklick:
Für das erste Eingabefeld wird das Programm gewählt.
Unterstütz wird *.exe/ *.lnk/ *.bat/ *.cmd/ *.jar
Das 2te ist der Arbeitspfad den man seperat ändern kann.
Es gilt aber, sobald man das programm hinzufügt wird auch der
aktuelle Arbeitspfad eingestellt

Oben Rechts im Fenster befindet sich ein Menü mit dem
sich weitere Einstellungen verwalten lassen:

* Windows Compatibility Einstellungen
Hier lassen sich Kompatibility Modi einstellungen. Sobald
gewählt erschint im "Commandline" Eingabefeld %c<Modus>.

* Support Unreal Engine
Hier lassen sich zahlreiche start einstellungen für
Unreal baseriet Spiele einstellen

* Support Unity Engine
Hier lassen sich zahlreiche start einstellungen für
Unity baseriet Spiele einstellen

* Support Ports/Nativ
Hier lassen sich zahlreiche start einstellungen für
unzählige Ports und Emulatoren einstellen.

* Weiter folgen Intern basierte vSystems Kommandos die
  automtisch in das Eingabefeld "Commandline" eingefügt werden
  Alle Internen vSystem Kommandos werden mit einem "%"
  vorgeschriben um nicht mit den Argumenten des eigentlichen
  programms im Konflikt zu kommen.

  - vSystem Schnell Kokommando
  : Kommando "%cpuf %blockfw %nbcb"
  * Cpu benutz alle Kerne
  * Blockert die *.exe in der Firewall
  * Borderless und Zentriert das Fenster auf dem Desktop

  - vSystem Schnell Kokommando (Admin)
  : Kommando "%cpuf %blockfw %nbcb %cRunAsAdmin"
  * Cpu benutz alle Kerne
  * Blockert die *.exe in der Firewall
  * Borderless und Zentriert das Fenster auf dem Desktop
  * Als Admin Starten

 - Programm: Starte Asynchron
 : Kommando "%a"
 * Das Programm wird ohne Features oder Zustätze
   gestartet. Es wartet nicht auf das Beenden.
   Nur Manuelle Programm Argumente werden übergeben.

 - Programm: Starte Api-Nativ
 : Kommando "%altexe"
 * vSystems startet standard mäßig die Das Programm über
   die Interne Purebasic API. In gamnz seltenen fällen
   funktioniert der start nicht oder das programm bleibt
   hängen. "%altexe" nutzt die Original Windows programm
   Start Api. Bei meinen 1000 Programm Tests musste ich
   das ein oder zweimal verwenden.

 - Programm: Borderless Mode ->
  Diese Kommandos sind nur dann aktiviert solange das Programm läuft
  : Patch Default
  : "%nb"
  *  vSystems versucht die folgenden Fenstereigenschaften der Window 
    API des Programm zu patchen und den Rahmen zu entfernen:
    (Gilt auch für alte Spiele)
    - WS_Border
    - WS_DLGFrame
    - WS_Overlapped

  : Patch Overlapped-Window
  : "%nbb"
  * Zuätzlich wird die Eingenschaft WS_OverlappedWindow gepatched 
    falls die" Standvariante nicht nicht funktioniert 

  : Patch Zentrieren. Damit wird das Fenster auf dem Bildschirm 
  : "%nbc"
  * zentriert. Ältere Spiele benutzen meist die Linke obere Ecke des    
    Bildschirms und haben keine Berechnung oder angabe zum
    Zentrieren des Fensters

  :Patch Voll
    Damit werden alle oberen Kommmandos verwendet.

  : Patch System-Metrics
  : "%nbgsm"
  * Folgende API Eigenschaften werden gepatcht und entfernt.
    - SM_CYCAPTION
    - SM_CXBORDER
    - CXEDGE

  : Lock Mouse
  : "%lck"
  * Damit wird veranlaßt das die Maus das Fenster solange man in 
    seinem Fokus ist nicht verläßt. Für Spiele wo sich die Maus aus 
    dem Fenster bewegt auf Multimonitor Systeme und den Spiel Screen 
    sowie den Focus verliert
                 
  - Programm: Speicher
  : "%fmm<mb>"
   * Hier kann man eine Speicergrnze für 32Bit Programme verwenden
    Gilt ausschlieslich für Programm die 3,5GB durchbrechen wie
    alte LUA verwendete inhalte.


  - Programm CPU Zugehörigkeit
  : "%cpu<n/f>" (n=Nummer, f=Voll alle automtisch)
  * Läst das programm die Zugehorkeit einstellen

  - Programm: Firewall Blockieren
  : "%blockfw"
  * Damit wird ein Eintrag in die Windows Firewall hinzugefügt
    (Das funktioniert auch mit Asyncron aber den Eintrag muss
    manuell selbst wieder rausnehmen)

  - Disable: End-Hotkey
  : "%nhkeyt"
  * Damit wird das Hotkey um den Task den gestarten Programms
    auszuschalten

  - Windows: Disable Taskbar
  : "%tb"
  * Damit wird die Taskbar solangedas Programm läuft ausgeschlatet.
    (Für Spiele/Programme vor der Zeit des Desktop Windows Mangament)
  
  - Windows: Disable Explorer
  : "%ex"
   * Damit wird die Windows Explorer Shell solange das Programm
     läuft ausgeschlatet.
    (Für Spiele/Programme die sich an dem Explorer aufhängen)

  - Windows: Disable Aero/Uxsms
  : "%ux"
  * Damit wird der Aero Modus von Vista/Windows 7 solange das
    Programm läuft ausgeschlatet. Ist quasi das gleiche
    wie der Bekannte Windows Komabitibilit Modus nur über der
   reinen API.

  - VSystems media Kommando
  : "%s" (Bis zu 4). Jedes "%s" gilt nachfolgend für das der 4
    Eingabe Felder
  * Damit wird veranlasst Dateien wie Mods/Roms/Wads und alllei    
    zusätze an das programm zu übergeben
    Bis zu 4 Medien könne übergeben werden (z.b M.A.M.E)


  - VSystems Media Kommando++
  : "%sc"
  * Diese Spezialle Kommando ist ein erweiterte Kommando Argument
    übergabe für das Programm welches man eingerichtet hat.
    Statt Haufenweise z.b ein und dasselbe programm im Verwaltung
    programm Manager zu haben mit verschiedene Argumenten, kann man
    das programm mit dem Kommando "%sc" einrichten und dieses 
    benutzen und seine Argemnte im 1 Eingabefeld anpassen oder   
    zusätzlich zu den Argmenten die man dem programm schon übergibt.


  - Screenshot Aufnhame (Stadsnard an mit Hotky: Rollen-Taste)
  : "%nbkeym"
  * Das Kommando wird auf die Tasten Shift+Rollen versetzt
  

  - Hotkey Auschalten
  : "%nhkeyt"
  * Die Screenshot wird ausgeschaltet

  - Virtualles Laufwerk aktiveren
  : "%vdm<lf>" lf=Laufwerks Buchstaben
  * vSystems erstellt vor programmstart ein Virtuelles lauferk mit
    dem  Pfad wo sich das Programm / Arbietspfad befindet.
    (Für ältere Spiele, wo es heuzutage meist kein CDRom laufwerk
    gibt oder kein Fix um diese Portable zu halten)
  
  - vSystems Log erlauben
  : "%%shout"
  * vSystems zeigt die Ausgabe von dem programm am Ende wenn es
    beendet wurde

  - vSystems Log Datei Schreiben
  : "%svlog"
  * vSystems Speichert die Log Ausgabe von dem programm am Ende
    wenn es beendet wurde
  
  - vSystems Aktivere Monitoring
  : "%wmon"
  * Damit wird geloggt welche zugriffe auf c: (Homedrive)  während
    das Programm läuft passieren. Quais eine sehr verklinerte Lite
    Edition des Process Monitor

  - Minmiere vSystems
  : "%m"
  * Minimiert vSystems Fenster solange dsas Programm läuft

  - Keine Anführungs Zeichen
  : "%nq"
  * vSystems erzeugt bei der Kommando übergabe Anführungszeichen
    Einige programme wurde das flasch implentiert oder Fehlerhaft
    Damit wird das Kommando ohne zustätliche Anführungszeichen    
    übergeben

  - Archiv unterstützung
  : "%pk"
  * Viele Emulatoren nutzen kein 7z z.b und könne so die Roms nicht
    laden. vSystems kann mit dem Kommando "ein wenig unter die Arme 
    greifen".

  - vSystems Save Support
  : "%savetool"
  * Damit wird veranlasst das vSystems eine Konfiguration unter
    .\System\Save\vSystem-SaveSupport.ini veranlasst.
    Einmal Konfiguriert belibt das Spiel komplett Portabel und
    alle Speicherstände landen im Ordner
     .\System\Save\<Spiele-Name-wie-in-der-Datenbank>

  - vSystems Registry Support
  : "%regssp"
  * Damit wird veranlasst das vSystems eine Konfiguration unter
    .\System\REGS\vSystem-RegSupport.ini veranlasst.
    Einmal Konfiguriert belibt das Spiel komplett Portabel und
    der Pfad zu dem Spiel welches durch die Registry abgefragt
    wird bleibt beständig und wird immer berichtig wenn man das
    Spiel elches unter vSystems eingerichtet wurde.

  --- Ende des Menü...


 Die 4 Eingabe Felder
 Diese dienen im zusammeng mit dem Kommando "%s".
 Für je ein angebafeld steht "%s". Hat man n der Kommando übergabe
 "%sc %sc" bedeutet das, das 1 und 2 Eingabe feld aktiv benutzt wird.
 


 
