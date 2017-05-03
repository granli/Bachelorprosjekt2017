#region Help
# ----------

<#
    .SYNOPSIS

        Dette er et PowerShell-Script som har som formål å lage VM/VM-er i Hyper-V
        
        Versjon Historie:
                [X] Versjon 3.0 03.05.2017 - Remote
                [ ] Versjon 2.0 24.04.2017 - Lage VM uten mal
                [ ] Versjon 1.5 18.04.2017 - Endringer
                [ ] Versjon 1.0 05.04.2017 - Opprettelse
                 
    .EXAMPLE
        
        Scriptet kjøres .\NyVMRemote.ps1 for å laste inn funksjonene.
        Deretter bruker man Get-NyVMMenu for å få et grensesnitt som forenkler brukeropplevelsen.
        Scriptet følger en oppskrift hvor man følger hva output på skjerm er.


    .DESCRIPTION

        Scriptet har som formål å forenkle prosessen å lage VM-er i Hyper-V. Med scriptet kan man
        lage f.eks 10 maskiner med samme spesifikasjoner på kort tid. Ved bruk av mal tar det noe
        lenger tid ettersom man må kopiere en harddisk med os installert. Scriptet uten mal går
        veldig fort. 

        Hovedfunksjonene i scriptet har stort forbedringspotensial, dette kommer av at vi har
        utviklet våre ferdigheter i PowerShell etterhvert som vi har jobbet med det, og funnet ut at 
        løsningene vi har valgt her ikke er optimale. 

        Plan for fremtiden er å gjøre om alle valgene til funksjoner som returnerer verdi, videre skal
        disse verdiene sendes til en funksjon som tar imot alt man kan konfigurere som parametere. På
        denne måten blir det mer ryddig, og generelt bedre kode. 
    
        
                
    .NOTES

        Forfatter: Eirik Granli og Mikael Kvaal
        Laget i forbindelse med Bachelorprosjekt 2017
        Linje: Informatikk, Drift av Datasystemer

#>

#endregion Help

#Funksjon som viser grensesnitt for hovedmenyen
function Get-NyVMMenu {

do {
      cls
      Write-Host "===================== Get-NyVMMenu ========================
1: Ny VM/VM-er med Mal
2: Ny VM/VM-er uten mal`r`n
q: Trykk 'Q' for å gå tilbake.
===========================================================" 



      
      $input = Read-Host "Velg et tall eller q for avslutt"
      switch ($input)
      {
            '1' {
                 cls
                 New-VMMedMal
                 Pause
            } '2' {
                 cls
                 New-VMUtenMal
                 Pause
            }
             
      }
      #Pause
 }
 until ($input -eq 'q')


}

#Funksjon lager VM/VM-er med mal
function New-VMMedMal {
Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "Dette scriptet har som funksjon å lage en eller flere VM-er med manuell konfigurasjon" -foregroundcolor yellow

#-----------------Antall VM-er--------------------#
write-host ""
write-host "#-----------------Antall VM-er--------------------#" -foregroundcolor cyan

write-host "Hvor mange VMer vil du lage? (Må kopiere så mange GB OS er på for hver maskin, så tar tid med mange)" -foregroundcolor yellow
do{
    try {
        write-host "Antall VM må være mellom 1-10 (Kan øke dette etterhvert)" -foregroundcolor yellow
        $TallOK = $true
        [int]$AntallVM = read-host "Antall VM"
        }
    catch{$TallOK =$false}
}
until(($AntallVM -ge 1 -and $AntallVM -le 10) -and $tallOK)
write-host "#-------------------------------------------------#" -foregroundcolor cyan
Write-host ""
#-------------------------------------------------#

#-----------------Valg av Mal PC------------------#
write-host ""
write-host "#-----------------Valg av Mal PC------------------#" -foregroundcolor cyan


#Løkke som kjøres til man har valgt en fil som eksisterer og skrevet på rett måte
do{
    Write-host "Viser innholdet i mappen sysprep: " -foregroundcolor yellow
    
    #cmdlet som viser innholdet i valgt mappe formatert etter kun navn
    get-childitem E:\sysprep -name
    $OriginalVM = Read-host "Skriv mal du vil bruke"
    
    #Variabel som sjekker om det man skrev inn eksisterer
    $sjekkpath = test-path E:\Sysprep\$($originalVM)
    #Dersom inputen er feil får man feilmelding og er nødt til å skrive ny input
    if($sjekkpath -eq $false){
        write-host "Finner ikke filen du skrev inn, prøv på nytt" -foregroundcolor red}
}
while($SjekkPath -ne $true)
write-host "#-------------------------------------------------#" -foregroundcolor cyan
Write-host ""
#-------------------------------------------------#

#-----------------Valg av Navn til VM-------------#
Write-host ""
Write-host "#-----------------Valg av Navn til VM-------------#" -foregroundcolor Cyan

#Løkke som kjøres til sjekk av navn er sant
do{
    #Løkke som kjøres til navnet ikke er tomt
    do{
    $NyVMNavn = Read-host "Skriv navn til ny maskin"
      if($nyvmnavn -eq ""){
        write-host "navnet på VM kan ikke være tomt" -foregroundcolor red
        $sjekkNyVMNavn = $false}}
    until($nyvmnavn -ne "")

    #Sjekker om navnet eksisterer og gir ikke feilmelding dersom den ikke gjør det
    $GetVM = Get-VM -name $nyvmnavn -erroraction SilentlyContinue
 
    if($getvm){
        Write-host "En VM med dette navnet eksisterer, prøv igjen" -foregroundcolor red
        $sjekkNyVMNavn = $false}
    else{
        $sjekknyvmnavn = $true}

  }
until($sjekkNyVMNavn -eq $true)

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Valg av Svitsj------------------#

Write-host ""
Write-host "#-----------------Valg av Svitsj------------------#" -foregroundcolor cyan

do{
    Write-host "Viser tilgjengelige svitsjer " -foregroundcolor yellow
    $showswitch = get-vmswitch
    write-host $showswitch
    $Svitsj = Read-host "Velg svitsj (navnet står etter Name = 'vmxnet3' f.eks)"
    $SjekkSvitsj = get-vmswitch -name $svitsj -erroraction silentlycontinue
    if(!$sjekksvitsj){
        write-host "Svitsjen finnes ikke, prøv igjen" -foregroundcolor red}
}
until($sjekksvitsj)

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Valg av Minne-------------------#

Write-host ""
Write-host "#-----------------Valg av Minne-------------------#" -foregroundcolor cyan

Write-host "Valg av minne for ny VM: " -foregroundcolor Yellow
do{
    $Dynamiskminne = read-host "Skriv True eller False for Dynamiskminne"       
    if($dynamiskminne -eq "false" -or $dynamiskminne -eq "true"){
        if($dynamiskminne -eq "false"){
            $dminne = $false}
        if($dynamiskminne -eq "true"){
            $dminne = $true}
    }else{write-host "invalid input, skriv true eller false" -foregroundcolor red}
}until($dminne -eq $true -or $dminne -eq $false)

Write-host "Valg av StartupBytes: " -foregroundcolor yellow
do{
    try {
        write-host "StartupBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $startupbytesok = $true
        $StartupBytes = read-host "StartupBytes"
        }
    Catch{$StartupbytesOK =$false}
}until(($StartupBytes -ge 1 -and $StartupBytes -le 8) -and $StartupBytesOK)
$FormatStartup = [int64]$startupbytes.Replace('GB','')*1GB

if($dminne -eq $true){

Write-host "Valg av MinimumBytes: " -foregroundcolor yellow
do{
    try {
        write-host "MinimumBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $Minimumbytesok = $true
        $MinimumBytes = read-host "MinimumBytes"
        }
    Catch{$MinimumbytesOK =$false}
}until(($MinimumBytes -ge 1 -and $MinimumBytes -le 8) -and $Minimumbytesok)
$FormatMinimum = [int64]$Minimumbytes.Replace('GB','')*1GB

Write-host "Valg av MaksimumBytes: " -foregroundcolor yellow
do{
    try {
        write-host "MaksimumBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $Maksimumbytesok = $true
        $MaksimumBytes = read-host "MaksimumBytes"
        }
    Catch{$MaksimumbytesOK =$false}
}until(($MaksimumBytes -ge 1 -and $MaksimumBytes -le 8) -and $Maksimumbytesok)
$FormatMaksimum = [int64]$Maksimumbytes.Replace('GB','')*1GB

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Valg av Prosessorer-------------#

Write-host ""
Write-host "#-----------------Valg av Prosessorer-------------#" -foregroundcolor cyan

}
Write-host "Valg av antall prosessor: " -foregroundcolor yellow
do{
    try {
        write-host "Antall prosessorer må være mellom 1-4" -foregroundcolor Yellow
        $ProsessorOK = $true
        [int]$Prosessor = read-host "Prosessorantall"
        }
    Catch{$ProsessorOK =$false}
}until(($Prosessor -ge 1 -and $Prosessor -le 4) -and $ProsessorOK)

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Bekrefte Valg GUI---------------#

$tittel = "Advarsel"
if($dminne -eq $true){
$melding = "Vil du lage VM/VM-er med disse spesifikasjonene?: `
Mal: $($originalVM)`
Navn: $($nyvmnavn)`
Antall VMer: $($antallVM)`
Svitsj: $($svitsj)`
Minne: Dynamisk $($Dynamiskminne) Startup $($startupbytes) Minimum $($minimumbytes) Maksimum $($MaksimumBytes)`
Prosessorantall: $($prosessor)"}
else{
$melding = "Vil du lage VM-ene med spesifikasjonene : `
Mal: $($originalVM)`
Navn: $($nyvmnavn)`
Antall VMer: $($antallVM)`
Svitsj: $($svitsj)`
Minne: Dynamisk $($Dynamiskminne) Startup $($startupbytes)`
Prosessorantall: $($prosessor)"}

$Ja = New-Object System.Management.Automation.Host.ChoiceDescription "Ja"
$Nei = New-Object System.Management.Automation.Host.ChoiceDescription "Nei"
$alternativer = [System.Management.Automation.Host.ChoiceDescription[]]($ja,$nei)
$resultat = $host.UI.promptforchoice($tittel, $melding,$alternativer, 1)

#-------------------------------------------------#

#-----------------Oppretter VM--------------------#

switch($resultat)
{

0{Write-host "Starter automatisk oppretting, dette kan ta litt tid..." -foregroundcolor green
[int]$navnteller = 1

do{
    write-host "#-------------------------------------------------#" -foregroundcolor cyan
    $brukernavn = $nyvmnavn + $navnteller
    Write-host "Kopierer E:\Sysprep\$($OriginalVM) til E:\vhdd\$($brukernavn).vhdx"
    Copy-Item "E:\Sysprep\$($OriginalVM)" -Destination "E:\vhdd\$($brukernavn).vhdx" | Out-Null 
    Write-host "Oppretter VM $($brukernavn)" -foregroundcolor green
    New-VM -Name $brukernavn -VHDPath "E:\vhdd\$($brukernavn).vhdx" -SwitchName $Svitsj | Out-Null
    if($dminne -eq $true){
    Write-host "Setter Dynamiskminne = $($dminne)"
    Write-host "Minne = $($startupbytes)"
    Write-host "MinimumMinne = $($minimumbytes)"
    Write-host "MaksimumMinne = $($maksimumbytes)"
    Set-VMMemory -VMName $brukernavn -DynamicMemoryEnabled $dminne -StartupBytes $FormatStartup -MinimumBytes $FormatMinimum -MaximumBytes $FormatMaksimum
    }else{
    Write-host "Setter Dynamiskminne = $($dminne)"
    Write-host "Minne = $($startupbytes)"
    Set-VMMemory -vmname $brukernavn -dynamicmemoryenabled $dminne -startupbytes $formatstartup}
    Write-host "Setter Prosessor antall til $($prosessor)"
    Set-VMProcessor -VMName $brukernavn -Count $Prosessor -Reserve 0 -Maximum 100 -RelativeWeight 100 
    $navnteller++ 

    Write-host "#-------------------------------------------------#" -foregroundcolor cyan
    Write-host ""
}until($navnteller -gt $AntallVM)
}
1{Write-host "Avslutter" -foregroundcolor Red}

}
#------------------------------------------------------#

}
} #Avslutter funksjon New-VMMedMal

#Funksjon lager VM/VM-er uten mal
function New-VMUtenMal {
Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "Dette scriptet har som funksjon å lage en eller flere VM-er med manuell konfigurasjon." -foregroundcolor yellow
Write-host "Man velger egendefinert størrelse på HDD, plassering og om man vil koble til .iso med OS." -foregroundcolor Yellow

#-----------------Antall VM-er--------------------#
write-host ""
write-host "#-----------------Antall VM-er--------------------#" -foregroundcolor cyan

write-host "Hvor mange VMer vil du lage?" -foregroundcolor yellow
do{
    try {
        write-host "Antall VM må være mellom 1-10 (Kan øke dette etterhvert)" -foregroundcolor yellow
        $TallOK = $true
        [int]$AntallVM = read-host "Antall VM"
        }
    catch{$TallOK =$false}
}
until(($AntallVM -ge 1 -and $AntallVM -le 10) -and $tallOK)
write-host "#-------------------------------------------------#" -foregroundcolor cyan
Write-host ""
#-------------------------------------------------#

#-----------------Valg av HDD---------------------#
Write-host ""
Write-host "#-----------------Valg av HDD---------------------#" -foregroundcolor cyan
$Disk = Get-wmiobject win32_logicaldisk -computername 55e-win2k16-3 -filter "DeviceID='E:'"
$DiskStorrelse = $disk.size /1GB
$DiskLedig = $disk.freespace /1GB
$FormatDiskStorrelse = [math]::Round($diskstorrelse,2)
$FormatDiskLedig = [math]::Round($diskledig,2)


write-host ""
Write-host "Lagringskapasitet på disk E : $($FormatDiskStorrelse) GB" -foregroundcolor Yellow
write-host "Ledig plass på disk E : $($FormatDiskLedig) GB" -foregroundcolor yellow


do{
    try {
        Write-host "Velg størrelse på ny harddisk Minimum 20GB Maksimum 200GB" -foregroundcolor Yellow
        $HDDGBOK = $true
        do {
        $ValgHDDStorrelse = Read-host "Antall GB på HDD (f.eks 40 eller 130)"
        $EstimertPlass = $antallVM * $valghddstorrelse
            if($estimertplass -gt $formatdiskledig){
                Write-host "Overstiger ledig diskplass" -foregroundcolor red} 
        }until($estimertplass -lt $formatdiskledig)
        }
    catch{$HDDGBOK =$false}
}

until(($valghddstorrelse -in 20..200) -and $hddgbok)
$FormatHDD = [int64]$valghddstorrelse.Replace('GB','')*1GB


Write-host "#-------------------------------------------------#" -foregroundcolor cyan
Write-host ""
#-------------------------------------------------#

#--------------------Valg OS----------------------#
Write-host ""
Write-host "#--------------------Valg OS----------------------#" -foregroundcolor cyan
Write-host "Du får nå valget om å koble til .iso fil eller ikke" -foregroundcolor yellow
Write-host "1. Koble til .ISO med OS" -foregroundcolor yellow
Write-host "2. Ikke Koble til .ISO" -foregroundcolor yellow
$ValgOS = read-host "Valg om .ISO"
Write-host ""

if($valgOS -eq "1"){
do{
    Write-host "Viser innholdet i mappen OS: " -foregroundcolor yellow
    
    #cmdlet som viser innholdet i valgt mappe formatert etter kun navn
    get-childitem E:\OS -name
    $ISOValg = Read-host "Skriv .iso du vil bruke"
    
    #Variabel som sjekker om det man skrev inn eksisterer
    $sjekkiso = test-path E:\os\$($isovalg)
    #Dersom inputen er feil får man feilmelding og er nødt til å skrive ny input
    if($sjekkiso -eq $false){
        write-host "Finner ikke filen du skrev inn, prøv på nytt" -foregroundcolor red}
}
while($sjekkiso -ne $true)
}
Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan
#-------------------------------------------------#

#-----------------Valg av Navn til VM-------------#
Write-host ""
Write-host "#-----------------Valg av Navn til VM-------------#" -foregroundcolor Cyan


#Løkke som kjøres til sjekk av navn er sant
do{
    #Løkke som kjøres til navnet ikke er tomt
    do{
    $NyVMNavn = Read-host "Skriv navn til ny maskin"
      if($nyvmnavn -eq ""){
        write-host "navnet på VM kan ikke være tomt" -foregroundcolor red
        $sjekkNyVMNavn = $false}}
    until($nyvmnavn -ne "")

    #Sjekker om navnet eksisterer og gir ikke feilmelding dersom den ikke gjør det
    $GetVM = Get-VM -name $nyvmnavn -erroraction SilentlyContinue
 
    if($getvm){
        Write-host "En VM med dette navnet eksisterer, prøv igjen" -foregroundcolor red
        $sjekkNyVMNavn = $false}
    else{
        $sjekknyvmnavn = $true}

  }
until($sjekkNyVMNavn -eq $true)

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Valg av Svitsj------------------#

Write-host ""
Write-host "#-----------------Valg av Svitsj------------------#" -foregroundcolor cyan

do{
    Write-host "Viser tilgjengelige svitsjer " -foregroundcolor yellow
    $showswitch = get-vmswitch
    write-host $showswitch
    $Svitsj = Read-host "Velg svitsj (navnet står etter Name = 'vmxnet3' f.eks)"
    $SjekkSvitsj = get-vmswitch -name $svitsj -erroraction silentlycontinue
    if(!$sjekksvitsj){
        write-host "Svitsjen finnes ikke, prøv igjen" -foregroundcolor red}
}
until($sjekksvitsj)

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Valg av Minne-------------------#

Write-host ""
Write-host "#-----------------Valg av Minne-------------------#" -foregroundcolor cyan

Write-host "Valg av minne for ny VM: " -foregroundcolor Yellow
do{
    $Dynamiskminne = read-host "Skriv True eller False for Dynamiskminne"       
    if($dynamiskminne -eq "false" -or $dynamiskminne -eq "true"){
        if($dynamiskminne -eq "false"){
            $dminne = $false}
        if($dynamiskminne -eq "true"){
            $dminne = $true}
    }else{write-host "invalid input, skriv true eller false" -foregroundcolor red}
}until($dminne -eq $true -or $dminne -eq $false)

Write-host "Valg av StartupBytes: " -foregroundcolor yellow
do{
    try {
        write-host "StartupBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $startupbytesok = $true
        $StartupBytes = read-host "StartupBytes"
        }
    Catch{$StartupbytesOK =$false}
}until(($StartupBytes -ge 1 -and $StartupBytes -le 8) -and $StartupBytesOK)
$FormatStartup = [int64]$startupbytes.Replace('GB','')*1GB

if($dminne -eq $true){

Write-host "Valg av MinimumBytes: " -foregroundcolor yellow
do{
    try {
        write-host "MinimumBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $Minimumbytesok = $true
        $MinimumBytes = read-host "MinimumBytes"
        }
    Catch{$MinimumbytesOK =$false}
}until(($MinimumBytes -ge 1 -and $MinimumBytes -le 8) -and $Minimumbytesok)
$FormatMinimum = [int64]$Minimumbytes.Replace('GB','')*1GB

Write-host "Valg av MaksimumBytes: " -foregroundcolor yellow
do{
    try {
        write-host "MaksimumBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $Maksimumbytesok = $true
        $MaksimumBytes = read-host "MaksimumBytes"
        }
    Catch{$MaksimumbytesOK =$false}
}until(($MaksimumBytes -ge 1 -and $MaksimumBytes -le 8) -and $Maksimumbytesok)
$FormatMaksimum = [int64]$Maksimumbytes.Replace('GB','')*1GB

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Valg av Prosessorer-------------#

Write-host ""
Write-host "#-----------------Valg av Prosessorer-------------#" -foregroundcolor cyan

}
Write-host "Valg av antall prosessor: " -foregroundcolor yellow
do{
    try {
        write-host "Antall prosessorer må være mellom 1-4" -foregroundcolor Yellow
        $ProsessorOK = $true
        [int]$Prosessor = read-host "Prosessorantall"
        }
    Catch{$ProsessorOK =$false}
}until(($Prosessor -ge 1 -and $Prosessor -le 4) -and $ProsessorOK)

Write-host ""
Write-host "#-------------------------------------------------#" -foregroundcolor cyan

#-------------------------------------------------#

#-----------------Bekrefte Valg GUI---------------#

$tittel = "Advarsel"

if($valgos -eq "1"){
$Melding = "Vil du lage VM/VM-er med disse spesifikasjonene? `
Antall VM-er: $($AntallVM)`
HDD-Størrelse: $($ValgHDDStorrelse)`
Valg av ISO: $($isovalg)`
Navn på VM: $($nyvmnavn)
Svitsj: $($svitsj)`
Minne: Dynamisk $($Dynamiskminne) Startup $($startupbytes) Minimum $($minimumbytes) Maksimum $($MaksimumBytes)`
Prosessorantall: $($prosessor)"}

else{
$Melding = "Vil du lage VM/VM-er med disse spesifikasjonene?: `
Antall VM-er: $($AntallVM)`
HDD-Størrelse: $($ValgHDDStorrelse)`
Navn på VM: $($nyvmnavn)`
Svitsj: $($svitsj)`
Minne: Dynamisk $($Dynamiskminne) Startup $($startupbytes) Minimum $($minimumbytes) Maksimum $($MaksimumBytes)`
Prosessorantall: $($prosessor)"
}


$Ja = New-Object System.Management.Automation.Host.ChoiceDescription "Ja"
$Nei = New-Object System.Management.Automation.Host.ChoiceDescription "Nei"
$alternativer = [System.Management.Automation.Host.ChoiceDescription[]]($ja,$nei)
$resultat = $host.UI.promptforchoice($tittel, $melding,$alternativer, 1)

#-------------------------------------------------#

#-----------------Oppretter VM--------------------#


switch($resultat)
{

0{Write-host "Starter automatisk oppretting, dette kan ta litt tid..." -foregroundcolor green
  Write-host ""
[int]$navnteller = 1

do{
    $brukernavn = $nyvmnavn + $navnteller
    write-host "#-------------------------------------------------#" -foregroundcolor cyan
    Write-host "Oppretter VM $($brukernavn)" -foregroundcolor green
    New-VM -Name $brukernavn -Path "E:\HyperV\$($brukernavn)" -NewVHDPath "E:\vhdd\$($brukernavn).vhdx" -Newvhdsizebytes $formathdd  -SwitchName $Svitsj | Out-Null
    If($valgos -eq "1"){
    Write-host "Setter DvdDrive på VM $($brukernavn) til $($isovalg)"
    Set-VMDvdDrive -Vmname $brukernavn -path "E:\OS\$($isovalg)"}
    if($dminne -eq $true){
    Write-host "Setter Dynamiskminne = $($dminne)"
    Write-host "Minne = $($formatstartup)"
    Write-host "MinimumMinne = $($Formatminimum)"
    Write-host "MaksimumMinne = $($formatmaksimum)"
    Set-VMMemory -VMName $brukernavn -DynamicMemoryEnabled $dminne -StartupBytes $FormatStartup -MinimumBytes $FormatMinimum -MaximumBytes $FormatMaksimum
    }else{
    Write-host "Setter Dynamiskminne = $($dminne)"
    Write-host "Minne = $($formatstartup)"
    Set-VMMemory -vmname $brukernavn -dynamicmemoryenabled $dminne -startupbytes $formatstartup}
    Write-host "Setter Prosessor antall til $($prosessor)"
    Set-VMProcessor -VMName $brukernavn -Count $Prosessor -Reserve 0 -Maximum 100 -RelativeWeight 100 
    
    $navnteller++ 

    Write-host "#-------------------------------------------------#" -foregroundcolor cyan
    Write-host ""
    
}until($navnteller -gt $AntallVM)
}
1{Write-host "Avslutter" -foregroundcolor Red}

}
#-------------------------------------------------#

} # Ender scriptblock
} #Avslutter funksjon New-VMUtenMal

