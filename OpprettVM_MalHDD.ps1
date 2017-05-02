####################################################
#                                                  #
#          Konfigurer og opprett VM/VM-er          #
#                Installert OS                     #
####################################################

#Scriptet er skrevet av Eirik Granli og Mikael Kvaal
#Laget for å automatisere oppretting av VM-er i Hyper-V
#Scriptet tar deg gjennom valgene under: 

# Valg av Antall VM-er
# Valg av Navn til VM
# Valg av Svitsj
# Valg av eksisterende .vhdx
# Valg av Minne
# Valg av Antall Prosessorer

#Forbedring: Ordentlig sjekk av HDD plass før kopiering, få feilmelding om for mye

#Funksjon som starter scriptet
function ManuellVM
{
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