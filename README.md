# Azure SAS Token Expiry Monitoring (PRTG)

Dieses PowerShell-Script überwacht die verbleibende Gültigkeitsdauer eines
**Azure Shared Access Signature (SAS) Tokens** und gibt das Ergebnis im Format
eines **PRTG EXE/Script Advanced Sensors** aus.

------------------------------------------------------------------------

## 🚀 Features

-   Überwachung des Ablaufdatums eines Azure SAS-Tokens
-   Auswertung des **`se`-Parameters (Signed Expiry)**
-   Anzeige von:
    -   Tage bis Ablauf
-   Unterstützung von SAS-Tokens:
    -   mit führendem `?`
    -   ohne führendes `?`
    -   mit URL-kodierten Parametern
-   **PRTG-kompatible XML-Ausgabe**
-   Kulturunabhängige Zahlenformatierung
-   Keine zusätzlichen PowerShell-Module erforderlich

------------------------------------------------------------------------

## 📋 Voraussetzungen

-   PRTG Network Monitor
-   PowerShell (auf Probe oder Core Server)
-   Gültiges Azure SAS-Token
-   SAS-Token mit vorhandenem `se`-Parameter

------------------------------------------------------------------------

## ⚙️ Verwendung in PRTG

### Sensor-Typ

EXE/Script Advanced

### Parameter

```text
-SasToken "%scriptplaceholder1"
```

### Platzhalter

-   `%scriptplaceholder1` = Azure SAS-Token

Beispiel:

```text
-SasToken "?sv=2023-11-03&se=2026-12-31T23%3A59%3A59Z&sp=r&sig=<signature>"
```

------------------------------------------------------------------------

## 📊 Sensor-Channels

-   Tage bis Ablauf -- Verbleibende Gültigkeitsdauer des SAS-Tokens in Tagen

------------------------------------------------------------------------

## 🔔 Schwellenwerte

Im Script selbst sind keine Warn- oder Fehlerschwellen definiert.

Empfohlene Konfiguration direkt im PRTG Channel:

-   Warning: z. B. 30 Tage
-   Error: z. B. 7 Tage

------------------------------------------------------------------------

## 🧠 Funktionsweise

1.  Übergabe des SAS-Tokens als Script-Parameter
2.  Entfernen von Leerzeichen am Anfang und Ende
3.  Entfernen eines optionalen führenden `?`
4.  URL-Decodierung des SAS-Tokens
5.  Extraktion des `se`-Parameters
6.  Interpretation des Ablaufzeitpunkts als UTC
7.  Berechnung der verbleibenden Laufzeit in Tagen
8.  Rundung auf eine Dezimalstelle
9.  Rückgabe an PRTG als XML

------------------------------------------------------------------------

## 📤 PRTG-Ausgabe

Beispiel einer erfolgreichen Ausgabe:

```xml
<prtg><result><channel>Tage bis Ablauf</channel><value>125.4</value><unit>Custom</unit><customunit>Tage</customunit></result></prtg>
```

------------------------------------------------------------------------

## ⚠️ Hinweis

-   Der Ablaufzeitpunkt wird aus dem SAS-Parameter `se` ermittelt
-   Die Berechnung erfolgt auf Basis von UTC
-   Die Ausgabe verwendet unabhängig von den regionalen Einstellungen einen Punkt als Dezimaltrennzeichen
-   Ein abgelaufenes SAS-Token kann zu einem negativen Wert bei `Tage bis Ablauf` führen
-   SAS-Tokens sollten wie Zugangsdaten behandelt und nicht in öffentlichen Repositories gespeichert werden

------------------------------------------------------------------------

## 🛠 Troubleshooting

### Kein `se`-Parameter gefunden

Ausgabe:

```text
Kein 'se=' (Expiry) im SAS Token gefunden.
```

Prüfen:

-   Enthält das SAS-Token einen `se`-Parameter?
-   Wurde das vollständige SAS-Token an das Script übergeben?
-   Ist das Token korrekt formatiert?

### Sensor liefert keinen gültigen Wert

Prüfen:

-   Script manuell in PowerShell ausführen
-   Übergabe des PRTG Script Placeholders prüfen
-   Format des Ablaufzeitpunkts im `se`-Parameter prüfen
-   PRTG Probe Service Account und Ausführungsumgebung prüfen

------------------------------------------------------------------------

## 📌 Empfehlung

-   Intervall: täglich
-   Primary Channel: Tage bis Ablauf
-   Warning Limit: 30 Tage
-   Error Limit: 7 Tage
-   SAS-Token nicht direkt im GitHub Repository hinterlegen

------------------------------------------------------------------------

## 👤 Autor

RASC79
