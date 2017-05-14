#region Help
# ----------

<#
    .SYNOPSIS

        Dette er et PowerShell-Script som har som formål å administrere Hyper-V
        
        Versjon Historie:
                [X] Versjon 3.0 12.05.2017 - Sammenslåing og Ferdigstilling av Hyper-V Funksjoner
                [ ] Versjon 2.5 04.05.2017 - Remote
                [ ] Versjon 2.0 02.05.2017 - Automasjonsmuligheter
                [ ] Versjon 1.6 26.04.2017 - Endre VM funksjoner
                [ ] Versjon 1.5 20.04.2017 - Statusrapport Funksjoner
                [ ] Versjon 1.0 05.04.2017 - Ny VM Funksjoner
                 
    .EXAMPLE
    
        
        Scriptet kjøres .\HyperV.ps1 for å laste inn funksjonene og opprette sesjon mot maskin.
        Deretter bruker man Get-HyperVMenu for å få et grensesnitt som forenkler scriptet.
        Det går også fint å bruke funksjonene dersom man husker på de, dette kan kjøres slik:
        I kommandovinduet skriver man f.eks Set-vmstatusOff eller Set-vmstatusOn for å slippe menyen.

    .DESCRIPTION
        
        Scriptet inneholder disse mulighetene:
            - Lage Ny VM/VM-er
            - Endre VM/VM-er
            - Slette VM/VM-er
            - HyperV Statusrapport


        Scriptet baseres på en hovedmeny med undermenyer som kjører funksjoner som ligger i scriptet.
        Menyene er f.eks Get-VMMenu og Get-VMStatusMenu som kan kjøres rett fra kommandolinja. Scriptet
        har vært gjennom en stor forbedringsprosess for å forenkle muligheten å skru av eller endre flere
        maskiner samtidig. Dette er nå mulig på diverse av funksjonene det er mest nyttig. Dette står
        listet i menyen når man bruker Get-VMMenu. Scriptet fokuserer på å kunne endre status på maskin,
        RAM, Switch og ProsessorCount. 

        Dersom en åpner scriptet i PowerShell ISE Lønner det seg å trykke Ctrl + M for å få oversikt
        over alle funksjonene som listes under menyene.
                
    .NOTES

        Forfatter: Eirik Granli og Mikael Kvaal
        Laget i forbindelse med Bachelorprosjekt 2017
        Linje: Informatikk, Drift av Datasystemer

#>

#endregion Help


#-----------Oppretter Sesjon mot Server-----------------#


#Setter passord dette er KUN for testing, i et arbeidsmiljø
#må passord og brukernavn skrives inn hver gang man oppretter en sesjon 
$passord = '2BADRGR4!'
$innlogging = 'mollenberg.local\administrator'
$pass = ConvertTo-SecureString -AsPlainText $passord -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $innlogging,$pass

#Oppretter Sesjon med New-PSSession mot valgt server
$SesjonVMServer = New-PSSession -ComputerName 55e-win2k16-3 -Credential $cred



#-----------Funksjoner Tilhørende Menyer----------------#


#Funksjon som viser grensesnitt for hovedmenyen
function Get-HyperVMenu {

do {
      cls
      Write-Host "===================== Get-HyperVMenu ======================
1: Ny VM/VM-er
2: Endre VM/VM-er
3: Slett VM/VM-er
4: Hyper-V Statusrapport`r`n
Q: Trykk 'Q' for å gå tilbake
==========================================================="
 
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
      switch ($input)
      {
            '1' {
                 cls
                 Get-NyVMMenu
            } '2' {
                 cls
                 Get-EndreVMMenu
            } '3' {
                 cls
                 Remove-VirtuellMaskin
            } '4' {
                 cls
                 Get-StatusMenu    
            }    
      }
 }
 until ($input -eq 'q')
}

#Funksjon som viser grensesnitt for Ny VM
function Get-NyVMMenu {

do {
      cls
      Write-Host "===================== Get-NyVMMenu ========================
1: Ny VM/VM-er med Mal
2: Ny VM/VM-er uten mal
3: Ny VM/VM-er fra CSV`r`n
Q: Trykk 'Q' for å gå tilbake.
===========================================================" 
      
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
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
            } '3' {
                 cls
                 New-VMCSV
                 Pause
            }
             
      }
      #Pause
 }
 until ($input -eq 'q')

}

#Funksjon som viser grensenitt for Endre VM
function Get-EndreVMMenu {


     do {
      cls
      Write-Host "=================== Get-EndreVMMenu ======================
1: Skru av - Reboot - Skru På
2: Endre RAM
3: Endre Switchinstillinger
4: Endre CPU Count (Maskin må være avslått)`r`n
Q: Trykk 'Q' to quit.
==========================================================="


      
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
      switch ($input)
      {
            '1' {
                 Get-VMStatusMenu 
            } '2' {
                 Get-VMRamMenu
            } '3' {    
                 Get-VMSwitchMenu
            } '4' {
                 Cls
                 Set-VMCPU
                 Pause
            } 'q' {
                
            }
      }
      #Pause
 }
 until ($input -eq 'q')
}

    #Undermenyer av Get-EndreVMMenu

    #Funksjon som viser grensesnitt for undermeny status
    function Get-VMStatusMenu {

do {
      cls
      Write-Host "===================== Get-VMStatus ========================
1: Skru av VM (Mulighet for mange)
2: Skru på VM (Mulighet for mange)
3: Reboot VM (Mulighet for mange)`r`n
q: Trykk 'Q' for å gå tilbake.
===========================================================" 

      
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
      switch ($input)
      {
            '1' {
                 cls
                 Set-VMstatusOff
                 Pause
                 Return
                 
                 
            } '2' {
                 cls
                 Set-VMStatusOn
                 Pause
                 Return
                 
            } '3' {   
                 cls
                 Set-VMStatusReboot
                 Pause
                 Return
            }
             
      }
      #Pause
 }
 until ($input -eq 'q')
}

    #Funksjon som viser grensesnitt for undermeny RAM
    function Get-VMRamMenu {

do {
      cls
      Write-Host "==================== Get-VMRamMenu ========================
1: Endre Dynamisk Minne (Mulighet for mange, på avslåtte maskiner)
2: Endre Startup Minne (Avslåtte Maskiner)
3: Endre Minimum og Maksimum Minne`r`n
q: Trykk 'Q' for å gå tilbake.
===========================================================" 


      
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
      switch ($input)
      {
            '1' {
                 cls
                 Set-VMDME
                 Pause
            } '2' {
                 cls
                 Set-VMStartupMemory
                 Pause
            } '3' {   
                 cls
                 Set-VMMinMax
                 Pause       
            }
             
      }
      #Pause
 }
 until ($input -eq 'q')

}

    #Funksjon som viser grensesnitt for undermeny Switch
    function Get-VMSwitchMenu {

do {
      cls
      Write-Host "=================== Get-VMSwitchMenu ======================
1: Endre Switch
2: Legg til ekstra Switch`r`n
q: Trykk 'Q' for å gå tilbake.
===========================================================" 

      
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
      switch ($input)
      {
            '1' {
                 cls
                 Set-VMSwitch
                 Pause
            } '2' {
                 cls
                 Set-VMAddSwitch
                 Pause
            }
             
      }
      #Pause
 }
 until ($input -eq 'q')


}


#Funksjon som gir et grensesnitt for HyperV Statusrapport
function Get-StatusMenu {


     do {
      cls
      Write-Host "================ Status Rapport av Hyper-V ================"
      
      
      Write-Host "1: Trykk '1' for VM Host."
      Write-Host "2: Trykk '2' for Operating System."
      Write-Host "3: Trykk '3' for Computer System"
      Write-Host "4: Trykk '4' for Memory"
      Write-Host "5: Trykk '5' for Network Adapters"
      Write-Host "6: Trykk '6' for HDD"
      Write-Host "7: Trykk '7' for Virtual Machines"

      Write-Host "Q: Trykk 'Q' to quit."
      Write-host "==========================================================="

      
      #Tar imot valg
      $input = Read-Host "Velg et tall eller q for avslutt"
      
      #Lager en Switchmeny basert på inputen
      switch ($input)
      {
            '1' {
                 cls
                 Get-VMHost
                 Pause
                 
                 
            } '2' {
                 cls
                 Get-OS
                 Pause
            } '3' {
                 cls
                 Get-ComputerSystem
                 Pause
            } '4' {
                 cls
                 Get-Memory
                 Pause
            } '5' {
                 cls
                 Get-NetworkAdapters
                 Pause
            } '6' {
                 cls
                 Get-Volumes
                 Pause
            } '7' {
                 cls
                 Get-VirtualMachines
                 Pause
            } 'q' {
                 return
            }
      }
      #Pause
 }
 until ($input -eq 'q')
}


#-----------Funksjoner Tilhørende Validering------------#


#Funksjon som validerer VMNavn
Function ValidateVMNavn($VMNavn) {

#Lager scriptblock for å sende kommandoer i en sesjon
invoke-command -session $sesjonvmserver -scriptblock {

#Oppretter variabel som tester innparameteren VMNavn
$VM = Get-vm $using:vmnavn -erroraction silentlycontinue

#Dersom variabelen blir opprettet finnes navnet og returnerer false
if($VM){
    return $false

#Dersom variabelen ikke blir opprettet finnes ikke navnet og returnerer vmnavn
}else{
    
    return $using:VMNavn
}
}#end scriptblock
}

#Funksjon som validerer VMPath
Function ValidatePath($Path){

invoke-command -session $sesjonvmserver -scriptblock {

$sjekk = test-path -path $using:path -erroraction silentlycontinue

if($sjekk){
    return $false
}else{
    return $using:Path}


}#End Scriptblock

}

#Funksjon som validerer Switch
Function ValidateSwitch($Switch){

#Lager scriptblock for å sende kommandoer i en sesjon
Invoke-command -session $sesjonvmserver -scriptblock {

#Lager variabel for å sjekke om switch eksisterer
$Switches = Get-VMSwitch -name $using:switch -erroraction silentlycontinue

#Dersom variabelen eksisterer returnerer den switchen
if($Switches){
    Return $using:switch

#Dersom variabelen ikke eksisterer returnerer den false
}else{
    Return $false
    }

}#end scriptblock

}

#Funksjon som validerer tall
function ValidateNumeric($Verdi) {

#Tar imot parameter og sjekker om det er et tall
#Dersom verdien er tall returneres verdi
if($verdi -match "^[\d\.]+$"){
    return $verdi}

#Dersom verdien ikke er et tall returneres false
else{
    return $false}
}


#-----------Funksjoner Tilhørende Formatering-----------#


#Inneholder funksjon Format-GB i Sesjon
invoke-command -session $sesjonVMserver -scriptblock {
#Funksjon som formaterer input 4 til GB (4 * 1024 * 1024 * 1024)
Function Format-GBSession {

    #Tar inn parameter størrelse
    param([Parameter(Mandatory=$true)] $Size)

    #Lager ny variabel med parameteret og gjør det om til GB format
    #Dette kan brukes i Set-VMMemory kommandoer
    $FormatSize = [int64]$size.Replace('GB','')*1GB

    #Returnerer formatert størrelse
    return $formatsize
}
}

#Funksjon Format-GB Uten Sesjon
Function Format-GB {

    #Tar inn parameter størrelse
    param([Parameter(Mandatory=$true)] $Size)

    #Lager ny variabel med parameteret og gjør det om til GB format
    #Dette kan brukes i Set-VMMemory kommandoer
    $FormatSize = [int64]$size.Replace('GB','')*1GB

    #Returnerer formatert størrelse
    return $formatsize
}

#Inneholder funksjon Set-Nummer
invoke-command -session $sesjonVMserver -scriptblock {
#Funksjon som legger til tall på f.eks Get-VM
function Set-Nummer {

    #Tar inn parameter f.eks Get-VM
    Param([parameter(mandatory=$true)][Object[]] $NummerVM)

    #Starter teller på 1
    $tall = 1
    
    #Går gjennom hvert objekt i det som kommer inn i parameteret og legger til tall
    $NummerVM | Foreach-object {
    Add-Member -InputObject $_ -membertype NoteProperty -name Tall -Value $tall
    
    #Inkrementerer telleren for hvert objekt
    $tall++}

    #Returnerer det som kom inn i funksjonen med tall foran hvert objekt
    return $NummerVM
}
}


#-----------Funksjoner Tilhørende NyVM------------------#


#Funksjon lager VM/VM-er med mal
function New-VMMedMal {

#Lager scriptblock for å sende kommandoer i en sesjon
Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "Dette scriptet har som funksjon å lage en eller flere VM-er med manuell konfigurasjon" -foregroundcolor yellow

#-----------------Antall VM-er--------------------#
write-host ""
write-host "#-----------------Antall VM-er--------------------#" -foregroundcolor cyan

write-host "Hvor mange VMer vil du lage? (Må kopiere så mange GB OS er på for hver maskin, så tar tid med mange)" -foregroundcolor yellow

#Kjører løkke til input er tall, ikke tomt og mellom 1-10
do{
    try {
        write-host "Antall VM må være mellom 1-10 (Kan øke dette etterhvert)" -foregroundcolor yellow
        
        #Setter en sjekk for å hoppe ut av løkken
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

#løkke som kjøres til sjekk er true eller sjekk er false
#Har som hensikt å velge True eller False for dynamiskminne
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

#Løkke som kjøres til input er input ogstørre enn 1, og mindre enn 8 i tillegg til en sjekk er OK
do{
    try {
        write-host "StartupBytes må være mellom 1 og 8 (GB)" -foregroundcolor Yellow
        $startupbytesok = $true
        $StartupBytes = read-host "StartupBytes"
        }
    Catch{$StartupbytesOK =$false}
}until(($StartupBytes -ge 1 -and $StartupBytes -le 8) -and $StartupBytesOK)
$FormatStartup = [int64]$startupbytes.Replace('GB','')*1GB

#Dersom Dynamisk minne er aktivert må en velge maksimum og minimum bytes
#Disse følger samme prinsipp som StartupBytes

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

#Oppretter en prompt med diverse informasjon om VM man skal lage
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

#Oppretter variabler for valg av Ja og Nei til prompt om å lage maskiner
$Ja = New-Object System.Management.Automation.Host.ChoiceDescription "Ja"
$Nei = New-Object System.Management.Automation.Host.ChoiceDescription "Nei"

#Setter Ja og Nei til alternativer variabel
$alternativer = [System.Management.Automation.Host.ChoiceDescription[]]($ja,$nei)

#Resultat inneholder tittel, melding og alternativer, og er auto satt til 1 slik at man ikke oppretter VM med uhell
$resultat = $host.UI.promptforchoice($tittel, $melding,$alternativer, 1)

#-------------------------------------------------#

#-----------------Oppretter VM--------------------#

#Bruker en switch hvor 0 = Ja og 1 = Nei
switch($resultat)
{

0{Write-host "Starter automatisk oppretting, dette kan ta litt tid..." -foregroundcolor green
[int]$navnteller = 1

#Kjører gjennom løkke for å lage maskiner basert på teller man satt tidligere
#Viser informasjon til skjerm om hva som skjer hele tiden
do{
    write-host "#-------------------------------------------------#" -foregroundcolor cyan
    
    $brukernavn = $nyvmnavn + $navnteller

    Write-host "Kopierer E:\Sysprep\$($OriginalVM) til E:\vhdd\$($brukernavn).vhdx"
    Copy-Item "E:\Sysprep\$($OriginalVM)" -Destination "E:\vhdd\$($brukernavn).vhdx" | Out-Null 
    
    Write-host "Oppretter VM $($brukernavn)" -foregroundcolor green
    New-VM -Name $brukernavn -VHDPath "E:\vhdd\$($brukernavn).vhdx" -SwitchName $Svitsj | Out-Null
    
    #Dersom dynamisk minne er aktivert må vi sette minimumbytes og maksimumbytes
    if($dminne -eq $true){

    Write-host "Setter Dynamiskminne = $($dminne)"
    Write-host "Minne = $($startupbytes)"
    Write-host "MinimumMinne = $($minimumbytes)"
    Write-host "MaksimumMinne = $($maksimumbytes)"
    Set-VMMemory -VMName $brukernavn -DynamicMemoryEnabled $dminne -StartupBytes $FormatStartup -MinimumBytes $FormatMinimum -MaximumBytes $FormatMaksimum
    
    #Dersom dynamisk minne ikke eraktivert må vi kun sette startupbytes
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
}

#Funksjon lager VM/VM-er uten mal
function New-VMUtenMal {

#Dette scriptet følger samme prosedyre som New-VMMedMal bortsett fra syspreppet harddisk

#Lager scriptblock for å sende kommandoer i en sesjon
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
}

#Funksjon lager VM/VM-er fra CSV
Function New-VMCSV {

 do {
	  # Dialogboks for å åpne CSV-fil 
	  $csvFil = New-Object System.Windows.Forms.OpenFileDialog
	  $csvFil.Filter = 
	  "csv files (*.csv)|*.csv|txt files (*.txt)|"+
	  "*.txt|All files (*.*)|*.*"
	  $csvFil.Title = 
	  "Åpne opp CSV fil som inneholder VM-informasjon"
	  $csvFil.ShowDialog()

}until ($csvFil.FileName -ne "")

    #Importerer CSV fil
    $VMer = Import-Csv $csvFil.filename
cls

    #Kjører gjennom hver linje i CSV Fil og oppretter variabler og oppretter maskin
    foreach($vm in $vmer){

    #Setter VMnavn dersom validering er OK
    $VMNavn = ValidateVMNavn($vm.vmnavn)

    #Setter VHDMappe
    $VHDMappe = $vm.vhdmappe

    #Setter VMMappe
    $vmmappe = $vm.vmmappe
    
    #Dersom VHD Størrelse er int 
    if(ValidateNumeric($vm.NewVHDSizeBytes)){
        #Setter variabel formatert av input i CSV
        $NewVHDSizeBytes = Format-GB($vm.NewVHDSizeBytes)
        Write-host "VM: $($vm.newvhdsizebytes) GB er OK"
    
    #Får feilmelding dersom det ikke er int
    }else{
        write-host "VM: $($vm.newvhdsizebytes) er ikke OK"-fore red
        #Hovedsjekk som bestemmer om man kan lage VM
        $validatesjekk = $false}

    #Sjekker om Minne er tall
    if(ValidateNumeric($vm.MemoryStartupBytes)){
        #Setter variabelen formatert
        $MemoryStartupBytes = Format-GB($vm.MemoryStartupBytes)
        Write-host "VM: $($vm.MemoryStartupBytes) GB er OK"

    }else{
        write-host "VM: $($vm.MemoryStartupBytes) GB er ikke OK"-fore red
        #Hovedsjekk som bestemmer om man kan lage VM
        $validatesjekk = $false}

    #Sjekker om switch eksisterer
    $VMSwitchNavn = ValidateSwitch($vm.VMSwitchNavn)
    

    $validatesjekk = $true

    #Sjekker om vmnavn eksisterer
    if($vmnavn -eq $false){
        $Validatesjekk = $false
        Write-host "VM: $($vm.vmnavn) er ikke OK eksisterer"-fore red}
    
    #Oppretter Path variabler om vmnavn ikke eksisterer
    else{
        Write-host "VM: $($vm.vmnavn) er OK"
        $VMPath = ValidatePath($vmmappe + $vmnavn)
        $VHDPath = ValidatePath($Vhdmappe + $vmnavn + ".vhdx")
        
        #Sjekker for både VMPath og VHDpath om de eksisterer eller ikke i tilfelle

        if($vmpath -eq $false){
            #Hovedsjekk som bestemmer om man kan lage VM
            $validatesjekk = $false
            Write-host "VM: $($vmmappe)$($vmnavn) er ikke OK eksisterer" -fore red}
        else{
            Write-host "VM: $($vmmappe)$($vmnavn) er OK"
            }
        if($vhdpath -eq $false){
            #Hovedsjekk som bestemmer om man kan lage VM
            $validatesjekk = $false
            Write-host "VM: $($vhdmappe)$($vmnavn) er ikke OK eksisterer"-fore red}
        else{
            Write-host "VM: $($vhdmappe)$($vmnavn) er OK"
            }
       
        }
   
   #Dersom switch ikke eksisterer
   if($vmswitchnavn -eq $false){
        #Hovedsjekk som bestemmer om man kan lage VM
        $validatesjekk = $false
        Write-host "VM: $($vm.vmswitchnavn) er ikke OK fant ikke Switch"-fore red}
   
   #Dersom switch eksisterer
   else{
        Write-host "VM: $($vm.vmswitchnavn) er OK"}
    
    #Dersom hovedsjekken ikke er false lager man VM
    if($ValidateSjekk -ne $false){
        Write-host ""
        Write-host "Validering: $($validatesjekk) Lager VM: $($VMNavn)" -fore green
        
        #Kjører kommando opp mot Hyper-v host og bruker variablene vi har laget tidligere
        invoke-command -session $sesjonvmserver -scriptblock {
        New-vm -name $using:vmnavn -path $using:vmpath -newvhdpath $using:vhdpath -switchname $using:vmswitchnavn -newvhdsizebytes $using:NewVHDSizeBytes | out-null
        Set-VMmemory -vmname $using:vmnavn -startupbytes $using:memorystartupbytes | out-null}
    
    #Dersom hovedsjekk er false lager man ikke VM og får melding om dette
    }else{
        Write-host ""
        Write-host "Validering: $($validatesjekk) Lager ikke VM" -fore red}
     write-host "--------------------"   
}
}


#-----------Funksjoner Tilhørende EndreVM---------------#


#Funksjon som skrur av VM/VM-er
function Set-vmstatusOff{
invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel som henter inn VM-er som ikke er av
$VMs = Get-VM | Where State -ne 'off'

#Bruker Set-Nummer for å sette tall foran hvert objekt
$NummerVM = Set-nummer $vms

#Skriver ut til skjerm formatert versjon av Get-VM
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state,uptime | out-string)

#Løkke som tar imot input til input ikke er 'q' eller tomt
do{
    
    #Setter en variabel til valg av VM/VM-er som skilles med komma med en split og trim
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

#Løkke som går gjennom hvert objekt valg i read-host variabelen
foreach($valg in $vmvalg){

#Dersom et av objektene er mellom 1 og antall objekter
if($valg -in 1..$NummerVM.count){

    #Lager variabel som setter valg (1,2 f.eks) til VMNavn som høres til
    $VMNavn = $NummerVM | where{$_.tall -eq $valg}

    #Stopper VM som tilsvarer navn
    Stop-vm -name $vmnavn.vmname -turnoff -erroraction stop -confirm

    #Output til skjerm som viser hva som har skjedd
    Write-host "Maskinen $($vmnavn.vmname) ble slått av" 

}

#Dersom input ikke finnes eller er feil
else {
    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskinen" -fore red}
}
}
}

#Funksjon som skrur på VM/VM-er
function Set-vmstatusOn {
invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel som henter VM-er som er av
$VMs = Get-VM | Where State -eq 'off'

#Bruker Set-Nummer for å sette tall foran hvert objekt
$NummerVM = Set-nummer $vms

#Skriver ut til skjerm formatert versjon av Get-VM
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state,uptime | out-string)

#Løkke som tar imot input til input ikke er 'q' eller tomt
do{
    
    #Setter en variabel til valg av VM/VM-er som skilles med komma med en split og trim
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

#Løkke som går gjennom hvert objekt valg i read-host variabelen
foreach($valg in $vmvalg){

#Dersom et av objektene er mellom 1 og antall objekter
if($valg -in 1..$NummerVM.count){

    #Lager variabel som setter valg (1,2 f.eks) til VMNavn som høres til
    $VMNavn = $NummerVM | where{$_.tall -eq $valg}

    #Starter VM som tilsvarer navn
    start-vm -name $vmnavn.vmname -erroraction silentlycontinue -confirm

    #Output til skjerm som viser hva som har skjedd
    Write-host "Maskinen $($vmnavn.vmname) ble slått på" 

}

#Dersom input ikke finnes eller er feil
else {

    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskina" -fore red}
}
}
}

#Funksjon som restarter VM/VM-er
function Set-vmstatusreboot {
invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel som henter inn VM-er som ikke er av
$VMs = Get-VM | Where State -ne 'off'

#Bruker Set-Nummer for å sette tall foran hvert objekt
$NummerVM = Set-nummer $vms

#Skriver ut til skjerm formatert versjon av Get-VM
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state,uptime | out-string)

#Løkke som tar imot input til input ikke er 'q' eller tomt
do{

    #Setter en variabel til valg av VM/VM-er som skilles med komma med en split og trim
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

#Løkke som går gjennom hvert objekt valg i read-host variabelen
foreach($valg in $vmvalg){

#Dersom et av objektene er mellom 1 og antall objekter
if($valg -in 1..$NummerVM.count){

    #Lager variabel som setter valg (1,2 f.eks) til VMNavn som høres til
    $VMNavn = $NummerVM | where{$_.tall -eq $valg}

    #Restarter VM som tilsvarer navn
    restart-vm -name $vmnavn.vmname -erroraction silentlycontinue -confirm

    #Output til skjerm som viser hva som har skjedd
    Write-host "Maskinen $($vmnavn.vmname) ble slått restartet" 

}

#Dersom input ikke finnes eller er feil
else {
    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskina" -fore red}
}
}
}

#Funksjon som endrer Dynamisk minne på VM/VM-er
function Set-VMDME {

invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel som henter inn VM-er som er av
$VMs = Get-VM | Where State -eq 'off' | Get-VMMemory

#Bruker Set-Nummer for å sette tall foran hvert objekt
$NummerVM = Set-nummer $vms

#Skriver ut til skjerm formatert versjon av Get-VM
write-host ($NummerVM | Format-Table -autosize -prop Tall,vmname,dynamicmemoryenabled | out-string)

#Løkke som tar imot input til input ikke er 'q' eller tomt
do{

    #Setter en variabel til valg av VM/VM-er som skilles med komma med en split og trim
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

#Løkke som går gjennom hvert objekt valg i read-host variabelen
foreach($valg in $vmvalg){

#Dersom et av objektene er mellom 1 og antall objekter
if($valg -in 1..$NummerVM.count){

#Lager variabel som setter valg (1,2 f.eks) til VMNavn som høres til
$VMNavn = $NummerVM | where{$_.tall -eq $valg}

    #Dersom dynamisk minne er false
    if($vmnavn.dynamicmemoryenabled -eq $false){

        #Setter dynamisk minne til true med en confirm
        Set-VMMemory $vmnavn.vmname -DynamicMemoryEnabled $true -confirm -erroraction silentlycontinue
        
        #Output til skjerm som viser hva som har skjedd
        Write-host "Satt DME på $($vmnavn.vmname) til true"}
    
    #Dersom dynamisk minne er true
    else{

    
    #Setter dynamisk minne til true med en confirm
    Set-VMMemory $vmnavn.vmname -DynamicMemoryEnabled $false -confirm -erroraction silentlycontinue
    
    #Output til skjerm som viser hva som har skjedd
    Write-host "Satt DME på $($vmnavn.vmname) til false"}

}

#Dersom input ikke finnes eller er feil
else {
    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskina" -fore red}
}
}
}

#Funksjon som setter Minne på maskin
function Set-VMStartupMemory {

invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel med VM-er som er av
#Variabelen lager også og formaterer f.eks Startup properties
$getVMStartupMemory = get-vm |  Where State -eq 'off' | get-vmmemory  | select vmname,
@{Name="startup";Expression={[math]::Round(($_.startup/1gb),2)}},
@{Name="minimum";Expression={[math]::Round(($_.minimum/1gb),2)}},
@{Name="maximum";Expression={[math]::Round(($_.maximum/1gb),2)}},
dynamicmemoryenabled | format-table vmname,startup,minimum,maximum,dynamicmemoryenabled

#Viser output av Get-VM verdiene til skjerm
$GetVMStartupMemory

#Lager mellomrom for oversikt
Write-host ""

#Løkker som tar imot input til input ikke er 'q' eller tomt
do {
do {
$SetVMStartupMemoryValg = read-host "Skriv navnet på VM du vil endre MemoryStartup eller q for å avslutte"
}until($SetVMStartupMemoryValg -ne "")

#Sjekker om navn på VM eksisterer mot en Get-VM
if(Get-VM -name $SetVMStartupMemoryValg -erroraction silentlycontinue |  Where State -eq 'off'){
    
    #Lager en sjekk for å hoppe ut av løkken
    $SetVMStartupMemoryValgSjekk = $true
}elseif($SetVMStartupMemoryValg -eq 'q'){return}
else{
    #Fortsetter løkken dersom sjekk ikke er sant
    $SetVMStartupMemoryValgSjekk = $false
    }

#Løkken fortsetter til input tilsvarer et navn i Get-VM    
}until(($SetVMStartupMemoryValgSjekk -eq $true))

#Løkke som kjører til input er mellom 1-12
do{
    
    try {
        
        #Output til skjerm som sier hvordan input skal se ut
        write-host "MemoryStartup må være mellom 1 og 12 (GB)"
        
        #Sjekk at input er OK
        $StartupOK = $true
        
        #Input variabel
        $Startup = read-host "Skriv inn ny MemoryStartup eller q for avslutt"
        
        #Hopper ut dersom input er 'q'
        if($Startup -eq "q"){return}
        }
    Catch{$StartupOK =$false}
}until(($Startup -in 1..12))

#Setter StartupBytes property til input ved hjelp av Format-GB funksjonen
set-vmmemory -vmname $setvmstartupmemoryvalg -startupbytes (Format-GBSession($startup))

}
}

#Funksjon som setter Min/Max minne på VM med Dynamisk Minne
function Set-VMMinMax {
invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel med VM-er som er av og har dynamisk minne aktivert
#Variabelen lager også og formaterer f.eks Min/Max properties
$GetVMMinMax = get-vm | where {($_.dynamicmemoryenabled -eq $true) -and ($_.State -eq 'off')} | select name,dynamicmemoryenabled,
@{Name="MemoryMinimum";Expression={[math]::Round(($_.MemoryMinimum/1gb),2)}},
@{Name="MemoryMaximum";Expression={[math]::Round(($_.MemoryMaximum/1gb),2)}},
@{Name="MemoryStartup";Expression={[math]::Round(($_.MemoryStartup/1gb),2)}} | Format-Table name,dynamicmemoryenabled,MemoryMinimum,MemoryMaximum,MemoryStartup

#Viser output av Get-VM verdiene til skjerm
$GetVMMinMax

#Lager mellomrom for oversikt
Write-host ""

#Løkke som tar imot input til input ikke er tomt
do {

#Løkke som sjekker om input er riktig, og returner dersom input er 'q'
do {

#Setter variabel på valg av VM
$SetVMMinMaxValg = read-host "Skriv navnet på VM du vil endre Min/Max Minne eller q for å avslutte"
}until($SetVMMinMaxValg -ne "")

#Sjekker om VM finnes
If($SetVMName = get-vm -name $SetVMMinMaxValg -erroraction silentlycontinue | where {($_.dynamicmemoryenabled -eq $true) -and ($_.State -eq 'off')} | Select name,
@{Name="MemoryMinimum";Expression={[math]::Round(($_.MemoryMinimum/1gb),2)}},
@{Name="MemoryMaximum";Expression={[math]::Round(($_.MemoryMaximum/1gb),2)}},
@{Name="MemoryStartup";Expression={[math]::Round(($_.MemoryAssigned/1gb),2)}}){
    
    #Sjekkvariabel for å avslutte løkke
    $setminmaxvalgsjekk = $true  
     
#returnerer dersom 'q'
}elseif($SetVMMinMaxValg -eq 'q'){return}

#Dersom valg ikke eksisterer 
else{
    #Setter sjekkvariabel til false for å bli i løkke
    $setminmaxvalgsjekk = $false

    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskinen..." -fore red}

}until(($setminmaxvalgsjekk -eq $true))

#Variabel som skal sjekke StartupMinne (Min må være under og Max over)
$SjekkMinStartup = get-vm -name $SetVMMinMaxValg | get-vmmemory | select name,
@{Name="Startup";Expression={[math]::Round(($_.Startup/1gb),2)}}

#Output til skjerm med informasjon
Write-host "Valg av Min / Max GB, trykk q for avslutt"

#Løkke som kjører input til diverse kvalifikasjoner er oppnådd
do {
    try {
        
        #Setter Max valg til variabel
        $SetMaxValg = read-host "Skriv Maximum GB f.eks 4 eller 6, Må være over MemoryMinimum: $($SetVMName.memoryminimum) og over MemoryStartup:$($SjekkMinStartup.startup) og mellom 4-12"
        $SetMaxValgSjekk = $true
        if($SetMaxValg -eq "q"){
            return}
        }
    Catch{$SetMaxValgSjekk = $false}

#Kjøres til input er mellom 4-12, og Greater Than MemoryMinimum og StartupMemory
}until(((($SetMaxValg -in 4..12) -and $SetMaxValg -gt $setvmname.MemoryMinimum) -and $setmaxvalg -gt $SjekkMinStartup.startup))

#Løkke som kjører input til diverse kvalifikasjoner er oppnådd
do {
    try {
        
        #Setter Min valg til variabel
        $SetMinValg = read-host "Skriv Minimum GB f.eks 1 eller 2, Må være under MemoryMaximum:$($SetMaxValg) og under MemoryStartup:$($SjekkMinStartup.startup) og mellom 1-6"
        $SetMinValgSjekk = $true
        if($SetMinValg -eq "q"){
            return}
        }
    Catch{$SetMinValgSjekk = $false}

#Kjøres til input er mellom 1-6, og Lower Than Max valg input og StartupMemory
}until(((($SetMinValg -in 1..6) -and $setminvalg -lt $SetMaxValg) -and $setminvalg -lt $SjekkMinStartup.startup))

#Setter MinimumBytes og MaximumBytes på valgt maskin formatert med Format GB
Set-VMMemory -VMName $SetVMMinMaxValg -minimumbytes (Format-GBSession($setminvalg)) -maximumbytes (Format-GBSession($setmaxvalg))

}
}

#Funksjon som endrer Switch på VM
function Set-VMSwitch {

invoke-command -session $sesjonVMserver -scriptblock {

#Variabel som henter VMer og Switch koblet til
$GetCurrentSwitch = get-vm | get-vmnetworkadapter | select vmname,switchname | format-table vmname,switchname

#Variabel som henter tilgjengelige Switcher
$GetSwitches = get-vmswitch | select name,switchtype | format-table name,switchtype

#Skriver ut til skjerm formatert versjon av Get-VM
$GetCurrentSwitch

#Lager mellomrom for oversikt
Write-host ""

#Løkke som kjøres til input ikke er tom
do {

#Løkke som kjøres til sjekk er true eller input 'q'
do {

#Input variabel
$SetSwitchVMValg = read-host "Skriv navnet på VM du vil endre Switch eller q for å avslutte"
}until($SetSwitchVMValg -ne "")

#Dersom VM finnes
If($SSVMV = get-vm -name $SetSwitchVMValg -erroraction silentlycontinue){
    
    #Setter sjekk til true
    $SetSwitchVMValgSjekk = $true   
}elseif($SetSwitchVMValg -eq 'q'){return}

#Dersom VM Ikke finnes
else{
    
    #Setter sjekk til false
    $SetSwitchVMValgSjekk = $false
    
    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskinen..." -fore red}
}until($SetSwitchVMValgSjekk -eq $true)

#Output til skjerm som viser Switcher
Write-host "Lister ut tilgjengelige Switcher: "

#Kaller på variabel med Switchinformasjon
$getswitches

#Løkke som kjøres til valg ikke er tomt
do{

#Løkke som kjøres til sjekk er true eller input 'q'
do{

#Input variabel som viser hvilken maskin du har valgt og tar inn Switchnavn
$SetSwitchValg = read-host "Velg hvilken switch du vil endre til på maskin: $($setswitchvmvalg)"
}until($setswitchvalg -ne "")

#Dersom switchen eksisterer
if(get-vmswitch -name $setswitchvalg -erroraction SilentlyContinue){
    
    #Setter sjekk til true
    $SetSwitchValgSjekk = $true
}elseif($setswitchvalg -eq 'q'){return}

#Dersom switch ikke eksisterer
else{
    
    #Setter sjekk til false
    $SetSwitchValgSjekk = $false

    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke Switch..." -fore red}

}until($SetSwitchValgSjekk -eq $true)

#Henter VM med navn, og kobler til valgt Switch
Get-VM -name $setswitchvmvalg | get-vmnetworkadapter | Connect-VMNetworkAdapter -switchname $setswitchvalg

}
}

#Funksjon som legger til Switch på VM
function Set-VMAddSwitch {

invoke-command -session $sesjonVMserver -scriptblock {
#Variabel som henter inn Switch som brukes nå
$GetCurrentSwitch = get-vm | get-vmnetworkadapter | select vmname,switchname | format-table vmname,switchname

#Variabel som viser tilgjengelige Switcher
$GetSwitches = get-vmswitch | select name,switchtype | format-table name,switchtype

#Kaller på variabel med VMnavn og switchnavn
$GetCurrentSwitch

#Lager mellomrom for oversikt
Write-host ""

#Løkke som kjøres til input ikke er tom
do {

#Løkke som kjøres til sjekk er true eller input er 'q'
do {

#Valg av VM man endrer switch på
$SetSwitchVMValg = read-host "Skriv navnet på VM du vil legge til Switch eller q for å avslutte"
}until($SetSwitchVMValg -ne "")

#Dersom VM eksisterer
If($SSVMV = get-vm -name $SetSwitchVMValg -erroraction silentlycontinue){
    
    #Setter sjekk til true
    $SetSwitchVMValgSjekk = $true   
}elseif($SetSwitchVMValg -eq 'q'){return}

#Dersom VM ikke eksisterer
else{

    #Setter sjekk til false
    $SetSwitchVMValgSjekk = $false

    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskinen..." -fore red}
}until($SetSwitchVMValgSjekk -eq $true)

#Output til skjerm som viser switcher
Write-host "Lister ut tilgjengelige Switcher: "

#Kaller på variabel med switchinformasjon
$getswitches

#Løkke som kjøres til input ikke er tom
do{

#Løkke som kjøres til sjekk er true eller input er 'q'
do{

#Input variabel av switch man vil legge til
$SetSwitchValg = read-host "Velg hvilken switch du vil legge til på maskin: $($setswitchvmvalg)"
}until($setswitchvalg -ne "")

#Sjekker om switch eksisterer
if(get-vmswitch -name $setswitchvalg -erroraction SilentlyContinue){
    
    #Setter sjekk til true
    $SetSwitchValgSjekk = $true
}elseif($setswitchvalg -eq 'q'){return}

#Dersom switch ikke eksisterer
else{

    #Setter sjekk til false
    $SetSwitchValgSjekk = $false

    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke Switch..." -fore red}

}until($SetSwitchValgSjekk -eq $true)

#Legger til ekstra switch med inputvariablene på hvilken VM og hvilken Switch.
add-vmnetworkadapter -vmname $SetSwitchVMValg -SwitchName $setswitchvalg

}
}

#Funksjon som setter ProcessorCount
function Set-VMCPU {

invoke-command -session $sesjonVMserver -scriptblock {

#Lager variabel som henter inn VM-er som er av
get-vm | Where State -eq 'off' | get-vmprocessor | select vmname,count | format-table vmname,count -autosize

#Løkke som kjører til valg av VM ikke er 'q' eller tomt
do {

#Input variabel
$VMValg = (read-host -prompt 'Skriv navn på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}

if($VMValg -eq "q"){
    return}
}until($VMValg -ne "")

#Løkke som kjører til ProcessorCount valg er mellom 1-8 returnerer med 'q'
do {

#CPUValg input variabel
$CPUValg = Read-host 'Skriv inn ny CPU Count (Mellom 1-8)'

if($cpuvalg -eq "q"){
    return}
}until(($CPUValg -in 1..8))

#Løkke som kjøres for hvert objekt i valg av VM
foreach($var in $VMValg){

    #Sjekker at VM eksisterer
    $SjekkVM = Get-VM -name $var -erroraction silentlycontinue | Select name
    
    #Dersom VM eksisterer
    if($SjekkVM){
    
    #Setter ProcessorCount til cpuvalg variabel
    get-vm -name $var | set-vmprocessor -count $cpuvalg
    
    #Output til skjerm som viser hva som har skjedd
    Write-host "Maskinen $($var) fikk Processorcount: $($cpuvalg)."}
    
    #Dersom VM ikke eksisterer
    else{
    
    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke VM: $($var)" -fore red}

    } 

}

}


#-----------Funksjoner Tilhørende SlettVM---------------#


#Slett VM Funksjon
Function Remove-VirtuellMaskin {

#Lager scriptblock for å sende kommandoer i en sesjon
invoke-command -session $sesjonVMserver -scriptblock {
#Lager variabel som henter VM-er som er av
$VMs = Get-VM | Where State -eq 'off'

#Bruker Set-Nummer for å sette tall foran hvert objekt
$NummerVM = Set-nummer $vms

#Skriver ut til skjerm formatert versjon av Get-VM
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state | out-string)

#Løkke som tar imot input til input ikke er 'q' eller tomt
do{
    
    #Setter en variabel til valg av VM/VM-er som skilles med komma med en split og trim
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

#Løkke som går gjennom hvert objekt valg i read-host variabelen
foreach($valg in $vmvalg){

#Dersom et av objektene er mellom 1 og antall objekter
if($valg -in 1..$NummerVM.count){

    #Lager variabel som setter valg (1,2 f.eks) til VMNavn som høres til
    $VMNavn = $NummerVM | where{$_.tall -eq $valg}
   
    #Harddkodet path til filserver, denne må settes manuelt
    $vhdpath = "E:\vhdd\"
    $VMpath = "E:\HyperV\"

    #Oppretter variabel for path for vm og vhd
    $vmpath = $vmpath + $vmnavn.name
    $vhdpath = $vhdpath + $vmnavn.name + ".vhdx"

    Write-host "Sletter maskin: $($vmnavn.name)"
    Remove-VM $vmnavn.name
    Write-host "$($vmnavn.name) ble slettet" -fore green
    
    Write-host "Sletter VHD: $($vhdpath)"
    Remove-Item $vhdpath
    Write-host "$($vhdpath) ble slettet" -fore green

    Write-host "Sletter VM Path: $($vmpath)"
    Remove-Item $vmpath -recurse
    Write-host "$($vmpath) ble slettet" -fore green

    Write-host ""

}

#Dersom input ikke finnes eller er feil
else {

    #Output til skjerm som viser feilmelding
    Write-host "Fant ikke maskina" -fore red}
}
}
Pause
}


#-----------Funksjoner Tilhørende HyperV Statusrapport--#


#Globale variabler legges i en sesjon mot Hyper-V Host 
Invoke-Command -Session $SesjonVMServer -ScriptBlock {

##Variabler som er planlagt å bruke mot loggfiler
$Date = Get-Date -Format d/MMM/yyyy
$Time = Get-Date -Format "hh:mm:ss tt"

#--------1 Get-VMHost Variabler-------------------#

#Lager hostname til variabel
$hostname = (Get-WmiObject Win32_ComputerSystem).Name

#Lager domenenavn til variabel
$domainname = (Get-WmiObject Win32_ComputerSystem).Domain

#Lager totalram på maskin formatert til variabel
$totalram = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB)))}

#Hardkodet path til VM og VHD
$VHDPath = "E:\vhdd"
$VMPath = "E:\HyperV"

#--------2 Get-OS Variabler-----------------------#

#Lager OS til variabel
$OS = Get-WmiObject -class win32_OperatingSystem -ComputerName $hostname

#Viser sist bootup time i variabel
$LastBootUpTime = Get-CimInstance -classname win32_operatingsystem -computername $hostname

#Lager oppetid til variabel med å trekkefra bootuptime fra tid nå
$uptime = $lastbootuptime.LocalDateTime - $LastBootUpTime.LastBootUpTime | select days, hours, minutes

#-------------------------------------------------#

#--------3 Get-ComputerSystem Variabler-----------#

#Lager diverse informasjon om systemet til variabel 
$ComputerSystem = Get-CimInstance -Classname win32_computersystem -computerName $hostname

#-------------------------------------------------#

#--------4 Get-Memory Variabler-------------------#

#Bruker OS variabelen og legger til minneinformasjon
$Memory = $OS |
Select @{Name="FreeGB";Expression={[math]::Round(($_.FreePhysicalMemory/1MB),2)}},
@{Name="TotalGB";Expression={[math]::Round(($_.TotalVisibleMemorySize/1MB),2)}},
@{Name="PercentFree";Expression={[math]::Round(($_.FreePhysicalMemory/$_.TotalVisibleMemorySize)*100,2)}},
@{Name="FreeVirtualGB";Expression={[math]::Round(($_.FreeVirtualMemory/1MB),2)}},
@{Name="TotalVirtualGB";Expression={[math]::Round(($_.TotalVirtualMemorySize/1MB),2)}},
@{Name="VirtualPercentFree";Expression={[math]::Round(($_.FreeVirtualMemory/$_.TotalVirtualMemorySize)*100,2)}}

#-------------------------------------------------#

#--------5 Get-NetworkAdapters Variabler----------#

#Lagrer nettverksadaptere i variabel med relevant informasjon
$NetworkAdapters = Get-NetAdapterStatistics -CimSession $hostname | 
Select Name,
@{Name="RcvdUnicastMB";Expression={[math]::Round(($_.ReceivedUnicastBytes/1MB),2)}},
@{Name="SentUnicastMB";Expression={[math]::Round(($_.SentUnicastBytes/1MB),2)}},
ReceivedUnicastPackets,SentUnicastPackets,
ReceivedDiscardedPackets,OutboundDiscardedPackets

#-------------------------------------------------#

#--------6 Get-Volumes Variabler------------------#

#Lagrer harddisker på maskin til variabler f.eks :E og :C
$Volumes = Get-Volume -CimSession $hostname | 
Where drivetype -eq 'fixed' | Sort DriveLetter |
Select @{Name="Drive";Expression={
if($_.DriveLetter){$_.driveletter} else {"none"}
}},Path,HealthStatus,
@{Name="SizeGB";Expression={[math]::Round(($_.Size/1gb),2)}},
@{Name="FreeGB";Expression={[math]::Round(($_.SizeRemaining/1gb),4)}},
@{Name="PercentFree";Expression={[math]::Round((($_.SizeRemaining/$_.Size)*100),2)}}

#-------------------------------------------------#

#--------7 Get-VirtualMachines Variabler----------#

#Lagrer alle VM-er som ikke er av til variabel
$allVMs = Get-VM -ComputerName $hostname -ErrorAction Stop  | Where State -ne 'off' | 
Select Name,Uptime,Status,CPUUsage,DynamicMemoryEnabled,
@{Name="MemoryAssigned";Expression={[math]::Round(($_.MemoryAssigned/1gb),2)}},
@{Name="MemoryDemand";Expression={[math]::Round(($_.MemoryDemand/1gb),2)}},
@{Name="MemoryStartup";Expression={[math]::Round(($_.MemoryStartup/1gb),2)}},
@{Name="MemoryMinimum";Expression={[math]::Round(($_.MemoryMinimum/1gb),2)}},
@{Name="MemoryMaximum";Expression={[math]::Round(($_.MemoryMaximum/1gb),2)}}
#-------------------------------------------------#

}#End Scriptblock for variabler

#Funksjon som skriver ut globale variabler om: Hostinformasjon
function Get-VMHost {
Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "======================== VM HOST =========================="
Write-host "Hyper-V Host Name: " -NoNewline
Write-host $hostname
Write-host "Domain Name: " -NoNewline
Write-host $domainname
Write-host "TotalMemoryGB: " -NoNewline
Write-host $totalram
Write-host "VHD Path: " -NoNewline
Write-host $VHDPath
Write-host "VM Path " -NoNewline
Write-host $VMPath
Write-host "==========================================================="
}
}

#Funksjon som skriver ut globale variabler om: OS
function Get-OS {
Invoke-Command -Session $SesjonVMServer -ScriptBlock {

Write-host "=================== Operating System======================="
Write-host "OS: " -NoNewline
$OS.caption
Write-host "ServicePack: " -NoNewline
$OS.ServicePackMajorVersion
Write-Host "LastBootUpTime: " -NoNewline
Write-host $LastBootUpTime.LastBootUpTime 
Write-Host "Uptime: " -NoNewline
Write-host $uptime.days "Dager  " -NoNewline
Write-host $uptime.hours "Timer  " -NoNewline
Write-host $uptime.minutes "Minutter  " 

Write-host "==========================================================="
}
}

#Funksjon som skriver ut globale variabler om: System
function Get-ComputerSystem {

Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "==================== COMPUTER SYSTEM ======================"
Write-host "Manufacturer: " -NoNewline
$ComputerSystem.manufacturer
Write-host "Model: " -NoNewline
$ComputerSystem.model
Write-host "NumberOfProcessors: " -NoNewline
$ComputerSystem.NumberOfProcessors
Write-host "NumberOfLogicalProcessors: " -NoNewline
$ComputerSystem.NumberOfLogicalProcessors
Write-host "==========================================================="
}
}

#Funksjon som skriver ut globale variabler om: Minne
function Get-Memory { 

Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "======================= MEMORY ============================"
Write-host "FreeGB: " -NoNewline
$memory.freegb
Write-host "TotalGB: " -NoNewline
$memory.totalgb
Write-host "Percent Free: " -NoNewline
$memory.PercentFree
Write-host ""
Write-host "FreeVirtualGB: " -NoNewline
$memory.FreeVirtualGB
Write-host "TotalVirtualGB: " -NoNewline
$memory.TotalVirtualGB
Write-host "VirtualPercentFree: " -NoNewline
$memory.VirtualPercentFree

Write-host "==========================================================="
}
}

#Funksjon som skriver ut globale variabler om: NettverkAdapter
function Get-NetworkAdapters {

Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "=================== Network Adapters ======================"

Foreach($Network in $NetworkAdapters){

Write-host "Name: " -NoNewline
$network.name
Write-host "ReceivedUnicastMB: " -NoNewline
$network.RcvdUnicastMB
Write-host "SentUnicastMB: " -NoNewline
$network.SentUnicastMB
Write-host "ReceivedUnicastPackets: " -NoNewline
$network.ReceivedUnicastPackets
Write-host "SentUnicastPackets: " -NoNewline
$network.SentUnicastPackets
Write-host "ReceivedDiscardedPackets: " -NoNewline
$network.ReceivedDiscardedPackets
Write-host "OutboundDiscardedPackets: " -NoNewline
$network.OutboundDiscardedPackets

Write-host ""

}

Write-host "==========================================================="
}
}

#Funksjon som skriver ut globale variabler om: Harddisk
function Get-Volumes {
Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Write-host "======================= Volumes ==========================="

Foreach($Volume in $Volumes){

Write-host "Drive: " -NoNewline
$Volume.Drive
Write-host "Path: " -NoNewline
$Volume.Path
Write-host "HealthStatus: " -NoNewline
$Volume.HealthStatus
Write-host "SizeGB: " -NoNewline
$Volume.SizeGB
Write-host "FreeGB: " -NoNewline
$Volume.FreeGB
Write-host "PercentFree: " -NoNewline
$Volume.PercentFree
Write-host ""


}

Write-host "==========================================================="
}
}

#Funksjon som skriver ut globale variabler om: VM-er
function Get-VirtualMachines {
Invoke-Command -Session $SesjonVMServer -ScriptBlock {
Try {
    
    Write-host "============== VIRTUAL MACHINES RUNNING===================="
    
foreach ($vm in $allVMs) {
     
     Write-host "Name: " -NoNewline
     $vm.Name
     Write-Host "Uptime: " -NoNewline
     Write-host $vm.uptime.days "Dager  " -NoNewline
     Write-host $vm.uptime.hours "Timer  " -NoNewline
     Write-host $vm.uptime.minutes "Minutter  " 
     Write-Host "Status: " -NoNewline
     $vm.status
     Write-Host "CPUUsage: " -NoNewline
     $vm.CPUUsage
     Write-Host "MemoryAssignedGB: " -NoNewline
     $vm.MemoryAssigned
     Write-Host "MemoryStartupGB: " -NoNewline
     $vm.MemoryStartup
     Write-Host "MemoryDemandGB: " -NoNewline
     $vm.MemoryDemand
     Write-Host "DynamicMemoryEnabled: " -NoNewline
     $vm.DynamicMemoryEnabled
     if($vm.dynamicMemoryEnabled){
     Write-Host "MemoryMinimumGB: " -NoNewline
     $vm.MemoryMinimum
     Write-Host "MemoryMaximumGB: " -NoNewline
     $vm.MemoryMaximum}
     
     Write-host ""
     

    } #foreach
    Write-host "==========================================================="
  } #try 
Catch {
    Write-host "Fant igen VM-er"
}
} #End scriptblock

}
