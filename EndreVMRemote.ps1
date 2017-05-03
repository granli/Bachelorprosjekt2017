#region Help
# ----------

<#
    .SYNOPSIS

        Dette er et PowerShell-Script som har som formål å endre VM-er i Hyper-V
        
        Versjon Historie:
                [ ] Versjon 3.0 x          - Remote
                [X] Versjon 2.0 02.05.2017 - Automasjonsmuligheter
                [ ] Versjon 1.5 28.04.2017 - Meny & Undermenyer
                [ ] Versjon 1.0 26.04.2017 - Opprettelse
                 
    .EXAMPLE
    
        Scriptet kjøres .\EndreVMRemote.ps1 for å laste inn funksjonene.
        Deretter bruker man Get-VMMenu for å få et grensesnitt som forenkler scriptet.
        Det går også fint å bruke funksjonene dersom man husker på de, dette kan kjøres slik:
        I kommandovinduet skriver man f.eks Set-vmstatusOff eller Set-vmstatusOn for å slippe menyen.

    .DESCRIPTION
    
        Scriptet baseres på en hovedmeny med undermenyer som kjører funksjoner som ligger i scriptet.
        Menyene er f.eks Get-VMMenu og Get-VMStatusMenu som kan kjøres rett fra kommandolinja. Scriptet
        har vært gjennom en stor forbedringsprosess for å forenkle muligheten å skru av eller endre flere
        maskiner samtidig. Dette er nå mulig på diverse av funksjonene det er mest nyttig. Dette står
        listet i menyen når man bruker Get-VMMenu. Scriptet fokuserer på å kunne endre status på maskin,
        RAM, Switch og ProsessorCount.
                
    .NOTES

        Forfatter: Eirik Granli og Mikael Kvaal
        Laget i forbindelse med Bachelorprosjekt 2017
        Linje: Informatikk, Drift av Datasystemer

#>

#endregion Help

#Funksjon som viser grensesnitt for hovedmenyen
function Get-VMMenu {


     do {
      cls
      Write-Host "======================== Endre VM =========================
1: Skru av - Reboot - Skru På
2: Endre RAM
3: Endre Switchinstillinger
4: Endre CPU Count (Maskin må være avslått)`r`n
Q: Trykk 'Q' to quit.
===========================================================" 

      
      $input = Read-Host "Velg et tall eller q for avslutt"
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

      
      $input = Read-Host "Velg et tall eller q for avslutt"
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


      
      $input = Read-Host "Velg et tall eller q for avslutt"
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

      
      $input = Read-Host "Velg et tall eller q for avslutt"
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

invoke-command -session $sesjonVMserver -scriptblock {
#Funksjon som formaterer input 4 til GB (4 * 1024 * 1024 * 1024)
Function Format-GB {

    #Tar inn parameter størrelse
    param([Parameter(Mandatory=$true)] $Size)

    #Lager ny variabel med parameteret og gjør det om til GB format
    #Dette kan brukes i Set-VMMemory kommandoer
    $FormatSize = [int64]$size.Replace('GB','')*1GB

    #Returnerer formatert størrelse
    return $formatsize
}
}

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
set-vmmemory -vmname $setvmstartupmemoryvalg -startupbytes (format-gb($startup))

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
Set-VMMemory -VMName $SetVMMinMaxValg -minimumbytes (format-gb($setminvalg)) -maximumbytes (format-gb($setmaxvalg))

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
