<#
.SYNOPSIS
Überwacht die verbleibende Gültigkeitsdauer eines Azure Shared Access Signature (SAS) Tokens.

.DESCRIPTION
Dieses Script wertet ein übergebenes Azure SAS-Token aus und ermittelt anhand des
Parameters "se" (Signed Expiry) dessen Ablaufzeitpunkt.

Das SAS-Token wird zunächst bereinigt und URL-decodiert. Anschließend wird der
Ablaufzeitpunkt ausgelesen und mit der aktuellen UTC-Zeit verglichen.

Die verbleibende Gültigkeitsdauer wird in Tagen berechnet und auf eine Dezimalstelle
gerundet.

Die Ausgabe erfolgt im XML-Format für einen PRTG EXE/Script Advanced Sensor.

Überwacht wird:
    - Tage bis zum Ablauf des SAS-Tokens

.PURPOSE
Frühzeitige Erkennung eines ablaufenden oder bereits abgelaufenen Azure SAS-Tokens,
um Zugriffsprobleme auf damit geschützte Azure-Ressourcen rechtzeitig erkennen und
das SAS-Token vor Ablauf erneuern zu können.

.AUTHOR
RASC79

.COMPANY <company name>

.VERSION
1.0.0

.DATE
2026-05-28

.REQUIREMENTS
- PRTG Network Monitor mit EXE/Script Advanced Sensor
- PowerShell auf dem Probe- oder Core-Server
- Gültiges Azure SAS-Token mit "se"-Parameter
- Keine zusätzlichen PowerShell-Module erforderlich

.PARAMETER SasToken
Das zu überprüfende Azure Shared Access Signature (SAS) Token.

Das Token kann mit oder ohne führendes Fragezeichen (?) übergeben werden.
URL-kodierte Bestandteile des Tokens werden automatisch decodiert.

Für die Ermittlung des Ablaufzeitpunkts muss das SAS-Token einen "se"-Parameter
(Signed Expiry) enthalten.

.OUTPUT
XML-Ausgabe im Format für einen PRTG EXE/Script Advanced Sensor.

Der Sensor liefert folgenden Kanal:
    - Tage bis Ablauf

Einheit:
    - Tage

.NOTES
Das Script ist für die nicht-interaktive Ausführung im Monitoring konzipiert.

Der Ablaufzeitpunkt des SAS-Tokens wird anhand des Parameters "se" ausgewertet
und als UTC-Zeit verarbeitet.

Die verbleibende Laufzeit wird in Tagen mit einer Dezimalstelle ausgegeben.
Für die numerische Ausgabe wird unabhängig von den regionalen Einstellungen
des Systems die InvariantCulture verwendet.

Wird kein "se"-Parameter im SAS-Token gefunden, beendet sich das Script mit
Exit-Code 1.

Empfohlene Verwendung in PRTG:
    - Sensor-Typ: EXE/Script Advanced
    - Primary Channel: Tage bis Ablauf
    - Einheit: Tage
    - Ausführungsintervall: täglich

Warn- und Fehlerschwellen können direkt über die Kanaleinstellungen in PRTG
konfiguriert werden.

.EXAMPLE
.\Check-AzureSasTokenExpiry.ps1 `
-SasToken "?sv=2023-11-03&se=2026-12-31T23%3A59%3A59Z&sp=r&sig=<signature>"

.EXAMPLE
.\Check-AzureSasTokenExpiry.ps1 `
-SasToken "sv=2023-11-03&se=2026-12-31T23%3A59%3A59Z&sp=r&sig=<signature>"

.CHANGELOG
1.0.0 - Initiale produktive Version zur Überwachung der Restlaufzeit eines Azure SAS-Tokens
#>


param(
  [Parameter(Mandatory=$true)]
  [string]$SasToken
)

# Falls Token mit "?" beginnt: entfernen
$SasToken = $SasToken.Trim()
if ($SasToken.StartsWith("?")) { $SasToken = $SasToken.Substring(1) }

# URL-decodieren
$decoded = [System.Net.WebUtility]::UrlDecode($SasToken)

# Expiry "se=" extrahieren
if ($decoded -match "(?:^|&)se=([^&]+)") {

    # Azure liefert im ISO-Format 2026-02-09T12:34:56Z
    $expiry = [datetime]::Parse(
        $matches[1],
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::AssumeUniversal
    )

    $daysLeft = ($expiry.ToUniversalTime() - (Get-Date).ToUniversalTime()).TotalDays

    # PRTG-sicher formatieren 
    $val = [math]::Round($daysLeft, 1)
    $valStr = $val.ToString([System.Globalization.CultureInfo]::InvariantCulture)

    # Ausgabe als kompakte XML-Zeile
    Write-Host "<prtg><result><channel>Tage bis Ablauf</channel><value>$valStr</value><unit>Custom</unit><customunit>Tage</customunit></result></prtg>"
    exit 0
}
else {
    Write-Host "Kein 'se=' (Expiry) im SAS Token gefunden."
    exit 1
}
