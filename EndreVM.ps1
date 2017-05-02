

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

function Set-Nummer {

    Param([parameter(mandatory=$true)][Object[]] $NummerVM)

    $tall = 1
    $NummerVM | Foreach-object {

    Add-Member -InputObject $_ -membertype NoteProperty -name Tall -Value $tall

    $tall++}
    return $NummerVM
}

function Set-vmstatusOff{

$VMs = Get-VM | Where State -ne 'off'
$NummerVM = Set-nummer $vms
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state,uptime | out-string)

do{
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

foreach($valg in $vmvalg){

if($valg -in 1..$NummerVM.count){

    $VMNavn = $NummerVM | where{$_.tall -eq $valg}

    Stop-vm -name $vmnavn.vmname -turnoff -erroraction stop -confirm
    Write-host "Maskinen $($vmnavn.vmname) ble slått av" 

}

else {
    Write-host "Fant ikke maskina" -fore red}
}

}

function Set-vmstatusOn {

$VMs = Get-VM | Where State -eq 'off'
$NummerVM = Set-nummer $vms
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state,uptime | out-string)

do{
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

foreach($valg in $vmvalg){

if($valg -in 1..$NummerVM.count){

    $VMNavn = $NummerVM | where{$_.tall -eq $valg}

    start-vm -name $vmnavn.vmname -erroraction silentlycontinue -confirm
    Write-host "Maskinen $($vmnavn.vmname) ble slått på" 

}

else {
    Write-host "Fant ikke maskina" -fore red}
}

}

function Set-vmstatusreboot {
$VMs = Get-VM | Where State -ne 'off'
$NummerVM = Set-nummer $vms
write-host ($NummerVM | Format-Table -autosize -prop Tall,name,state,uptime | out-string)

do{
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

foreach($valg in $vmvalg){

if($valg -in 1..$NummerVM.count){

    $VMNavn = $NummerVM | where{$_.tall -eq $valg}

    restart-vm -name $vmnavn.vmname -erroraction silentlycontinue -confirm
    Write-host "Maskinen $($vmnavn.vmname) ble slått restartet" 

}

else {
    Write-host "Fant ikke maskina" -fore red}
}

}

function Set-VMDME {
$VMs = Get-VM | Where State -eq 'off' | Get-VMMemory
$NummerVM = Set-nummer $vms
write-host ($NummerVM | Format-Table -autosize -prop Tall,vmname,dynamicmemoryenabled | out-string)

do{
    $VMvalg = (read-host -prompt 'Velg tall på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}
    if($VMvalg -eq "q"){return}
}until($VMvalg -ne "")

foreach($valg in $vmvalg){

if($valg -in 1..$NummerVM.count){

$VMNavn = $NummerVM | where{$_.tall -eq $valg}

    if($vmnavn.dynamicmemoryenabled -eq $false){
    Set-VMMemory $vmnavn.vmname -DynamicMemoryEnabled $true -confirm -erroraction silentlycontinue
    Write-host "Satt DME på $($vmnavn.vmname) til true"}
    
    else{
    Set-VMMemory $vmnavn.vmname -DynamicMemoryEnabled $false -confirm -erroraction silentlycontinue
    Write-host "Satt DME på $($vmnavn.vmname) til false"}

}

else {
    Write-host "Fant ikke maskina" -fore red}
}

}

function Set-VMStartupMemory {
 
$getVMStartupMemory = get-vm |  Where State -eq 'off' | get-vmmemory  | select vmname,
@{Name="startup";Expression={[math]::Round(($_.startup/1gb),2)}},
@{Name="minimum";Expression={[math]::Round(($_.minimum/1gb),2)}},
@{Name="maximum";Expression={[math]::Round(($_.maximum/1gb),2)}},
dynamicmemoryenabled | format-table vmname,startup,minimum,maximum,dynamicmemoryenabled
$GetVMStartupMemory
Write-host ""
do {
do {
$SetVMStartupMemoryValg = read-host "Skriv navnet på VM du vil endre MemoryStartup eller q for å avslutte"
}until($SetVMStartupMemoryValg -ne "")

if(Get-VM -name $SetVMStartupMemoryValg -erroraction silentlycontinue |  Where State -eq 'off'){
    $SetVMStartupMemoryValgSjekk = $true
}elseif($SetVMStartupMemoryValg -eq 'q'){return}
else{
    $SetVMStartupMemoryValgSjekk = $false
    }
    
}until(($SetVMStartupMemoryValgSjekk -eq $true))


do{
    try {
        write-host "MemoryStartup må være mellom 1 og 12 (GB)"
        $StartupOK = $true
        $Startup = read-host "Skriv inn ny MemoryStartup eller q for avslutt"
        if($Startup -eq "q"){return}
        }
    Catch{$StartupOK =$false}
}until(($Startup -in 1..12))

set-vmmemory -vmname $setvmstartupmemoryvalg -startupbytes (format-gb($startup))

}

function Set-VMMinMax {

$GetVMMinMax = get-vm | where {($_.dynamicmemoryenabled -eq $true) -and ($_.State -eq 'off')} | select name,dynamicmemoryenabled,
@{Name="MemoryMinimum";Expression={[math]::Round(($_.MemoryMinimum/1gb),2)}},
@{Name="MemoryMaximum";Expression={[math]::Round(($_.MemoryMaximum/1gb),2)}},
@{Name="MemoryStartup";Expression={[math]::Round(($_.MemoryStartup/1gb),2)}} | Format-Table name,dynamicmemoryenabled,MemoryMinimum,MemoryMaximum,MemoryStartup

$GetVMMinMax

Write-host ""
do {
do {
$SetVMMinMaxValg = read-host "Skriv navnet på VM du vil endre Min/Max Minne eller q for å avslutte"
}until($SetVMMinMaxValg -ne "")
If($SetVMName = get-vm -name $SetVMMinMaxValg -erroraction silentlycontinue | where {($_.dynamicmemoryenabled -eq $true) -and ($_.State -eq 'off')} | Select name,
@{Name="MemoryMinimum";Expression={[math]::Round(($_.MemoryMinimum/1gb),2)}},
@{Name="MemoryMaximum";Expression={[math]::Round(($_.MemoryMaximum/1gb),2)}},
@{Name="MemoryStartup";Expression={[math]::Round(($_.MemoryAssigned/1gb),2)}}){
    $setminmaxvalgsjekk = $true   
}elseif($SetVMMinMaxValg -eq 'q'){return}
else{
    $setminmaxvalgsjekk = $false
    Write-host "Fant ikke maskinen..." -fore red}
}until(($setminmaxvalgsjekk -eq $true))

$SjekkMinStartup = get-vm -name $SetVMMinMaxValg | get-vmmemory | select name,
@{Name="Startup";Expression={[math]::Round(($_.Startup/1gb),2)}}
Write-host "Valg av Min / Max GB, trykk q for avslutt"
do {
    try {
        
        $SetMaxValg = read-host "Skriv Maximum GB f.eks 4 eller 6, Må være over MemoryMinimum: $($SetVMName.memoryminimum) og over MemoryStartup:$($SjekkMinStartup.startup) og mellom 4-12"
        $SetMaxValgSjekk = $true
        if($SetMaxValg -eq "q"){
            return}
        }
    Catch{$SetMaxValgSjekk = $false}
}until(((($SetMaxValg -in 4..12) -and $SetMaxValg -gt $setvmname.MemoryMinimum) -and $setmaxvalg -gt $SjekkMinStartup.startup))

do {
    try {
        
        
        $SetMinValg = read-host "Skriv Minimum GB f.eks 1 eller 2, Må være under MemoryMaximum:$($SetMaxValg) og under MemoryStartup:$($SjekkMinStartup.startup) og mellom 1-6"
        $SetMinValgSjekk = $true
        if($SetMinValg -eq "q"){
            return}
        }
    Catch{$SetMinValgSjekk = $false}
}until(((($SetMinValg -in 1..6) -and $setminvalg -lt $SetMaxValg) -and $setminvalg -lt $SjekkMinStartup.startup))

Set-VMMemory -VMName $SetVMMinMaxValg -minimumbytes (format-gb($setminvalg)) -maximumbytes (format-gb($setmaxvalg))

}

function Set-VMSwitch {

$GetCurrentSwitch = get-vm | get-vmnetworkadapter | select vmname,switchname | format-table vmname,switchname
$GetSwitches = get-vmswitch | select name,switchtype | format-table name,switchtype

$GetCurrentSwitch
Write-host ""
do {
do {
$SetSwitchVMValg = read-host "Skriv navnet på VM du vil endre Switch eller q for å avslutte"
}until($SetSwitchVMValg -ne "")
If($SSVMV = get-vm -name $SetSwitchVMValg -erroraction silentlycontinue){
    $SetSwitchVMValgSjekk = $true   
}elseif($SetSwitchVMValg -eq 'q'){return}
else{
    $SetSwitchVMValgSjekk = $false
    Write-host "Fant ikke maskinen..." -fore red}
}until($SetSwitchVMValgSjekk -eq $true)

Write-host "Lister ut tilgjengelige Switcher: "
$getswitches

do{
do{
$SetSwitchValg = read-host "Velg hvilken switch du vil endre til på maskin: $($setswitchvmvalg)"
}until($setswitchvalg -ne "")
if(get-vmswitch -name $setswitchvalg -erroraction SilentlyContinue){
    $SetSwitchValgSjekk = $true
}elseif($setswitchvalg -eq 'q'){return}
else{
    $SetSwitchValgSjekk = $false
    Write-host "Fant ikke Switch..." -fore red}

}until($SetSwitchValgSjekk -eq $true)

Get-VM -name $setswitchvmvalg | get-vmnetworkadapter | Connect-VMNetworkAdapter -switchname $setswitchvalg

}

function Set-VMAddSwitch {

$GetCurrentSwitch = get-vm | get-vmnetworkadapter | select vmname,switchname | format-table vmname,switchname
$GetSwitches = get-vmswitch | select name,switchtype | format-table name,switchtype

$GetCurrentSwitch
Write-host ""
do {
do {
$SetSwitchVMValg = read-host "Skriv navnet på VM du vil endre Switch eller q for å avslutte"
}until($SetSwitchVMValg -ne "")
If($SSVMV = get-vm -name $SetSwitchVMValg -erroraction silentlycontinue){
    $SetSwitchVMValgSjekk = $true   
}elseif($SetSwitchVMValg -eq 'q'){return}
else{
    $SetSwitchVMValgSjekk = $false
    Write-host "Fant ikke maskinen..." -fore red}
}until($SetSwitchVMValgSjekk -eq $true)

Write-host "Lister ut tilgjengelige Switcher: "
$getswitches

do{
do{
$SetSwitchValg = read-host "Velg hvilken switch du vil legge til på maskin: $($setswitchvmvalg)"
}until($setswitchvalg -ne "")
if(get-vmswitch -name $setswitchvalg -erroraction SilentlyContinue){
    $SetSwitchValgSjekk = $true
}elseif($setswitchvalg -eq 'q'){return}
else{
    $SetSwitchValgSjekk = $false
    Write-host "Fant ikke Switch..." -fore red}

}until($SetSwitchValgSjekk -eq $true)

add-vmnetworkadapter -vmname $SetSwitchVMValg -SwitchName $setswitchvalg

}

function Set-VMCPU {

get-vm | Where State -eq 'off' | get-vmprocessor | select vmname,count | format-table vmname,count -autosize
do {
$VMValg = (read-host -prompt 'Skriv navn på VM/VM-er og skill med komma eller skriv q for å gå tilbake: ').Split(',') | foreach {$_.trim()}

if($VMValg -eq "q"){
    return}
}until($VMValg -ne "")

do {
$CPUValg = Read-host 'Skriv inn ny CPU Count (Mellom 1-8)'

if($cpuvalg -eq "q"){
    return}
}until(($CPUValg -in 1..8))


foreach($var in $VMValg){

    $SjekkVM = Get-VM -name $var -erroraction silentlycontinue | Select name
    if($SjekkVM){
    
    get-vm -name $var | set-vmprocessor -count $cpuvalg
    Write-host "Maskinen $($var) fikk Processorcount: $($cpuvalg)."}
    
    else{Write-host "Fant ikke VM: $($var)" -fore red}

    } 



}

Function Format-GB {

    param([Parameter(Mandatory=$true)] $Size)

    $FormatSize = [int64]$size.Replace('GB','')*1GB
    return $formatsize
}