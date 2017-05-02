####################################################
#                                                  #
#          Status Rapport av Hyper-V               #
#                                                  #
####################################################

#Laget basert på idé fra www.altaro.com 

####################################################
############## GLOBALE VARIABLER ###################
####################################################

#til loggfiler
$Date = Get-Date -Format d/MMM/yyyy
$Time = Get-Date -Format "hh:mm:ss tt"

#--------1 Get-VMHost Variabler-------------------#
$hostname = (Get-WmiObject Win32_ComputerSystem).Name
$domainname = (Get-WmiObject Win32_ComputerSystem).Domain
$totalram = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB)))}
$VHDPath = "E:\vhdd"
$VMPath = "E:\HyperV"
#--------2 Get-OS Variabler-----------------------#
$OS = Get-WmiObject -class win32_OperatingSystem -ComputerName $hostname
$LastBootUpTime = Get-CimInstance -classname win32_operatingsystem -computername $hostname
$uptime = $lastbootuptime.LocalDateTime - $LastBootUpTime.LastBootUpTime | select days, hours, minutes
#-------------------------------------------------#

#--------3 Get-ComputerSystem Variabler-----------#
$ComputerSystem = Get-CimInstance -Classname win32_computersystem -computerName $hostname
#-------------------------------------------------#

#--------4 Get-Memory Variabler-------------------#
$OS = Get-WmiObject -class win32_OperatingSystem -ComputerName $hostname
$Memory = $OS |
Select @{Name="FreeGB";Expression={[math]::Round(($_.FreePhysicalMemory/1MB),2)}},
@{Name="TotalGB";Expression={[math]::Round(($_.TotalVisibleMemorySize/1MB),2)}},
@{Name="PercentFree";Expression={[math]::Round(($_.FreePhysicalMemory/$_.TotalVisibleMemorySize)*100,2)}},
@{Name="FreeVirtualGB";Expression={[math]::Round(($_.FreeVirtualMemory/1MB),2)}},
@{Name="TotalVirtualGB";Expression={[math]::Round(($_.TotalVirtualMemorySize/1MB),2)}},
@{Name="VirtualPercentFree";Expression={[math]::Round(($_.FreeVirtualMemory/$_.TotalVirtualMemorySize)*100,2)}}
#-------------------------------------------------#

#--------5 Get-NetworkAdapters Variabler----------#
$NetworkAdapters = Get-NetAdapterStatistics -CimSession $hostname | 
Select Name,
@{Name="RcvdUnicastMB";Expression={[math]::Round(($_.ReceivedUnicastBytes/1MB),2)}},
@{Name="SentUnicastMB";Expression={[math]::Round(($_.SentUnicastBytes/1MB),2)}},
ReceivedUnicastPackets,SentUnicastPackets,
ReceivedDiscardedPackets,OutboundDiscardedPackets
#-------------------------------------------------#

#--------6 Get-Volumes Variabler------------------#
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
$allVMs = Get-VM -ComputerName $hostname -ErrorAction Stop  | Where State -ne 'off' | 
Select Name,Uptime,Status,CPUUsage,DynamicMemoryEnabled,
@{Name="MemoryAssigned";Expression={[math]::Round(($_.MemoryAssigned/1gb),2)}},
@{Name="MemoryDemand";Expression={[math]::Round(($_.MemoryDemand/1gb),2)}},
@{Name="MemoryStartup";Expression={[math]::Round(($_.MemoryStartup/1gb),2)}},
@{Name="MemoryMinimum";Expression={[math]::Round(($_.MemoryMinimum/1gb),2)}},
@{Name="MemoryMaximum";Expression={[math]::Round(($_.MemoryMaximum/1gb),2)}}


#-------------------------------------------------#

####################################################
################ END VARIABLER #####################
####################################################

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

      
      $input = Read-Host "Please make a selection: 1 2 eller q for avslutt"
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

function Get-VMHost {

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

function Get-OS {


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

function Get-ComputerSystem {
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

function Get-Memory { 

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

function Get-NetworkAdapters {
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

function Get-Volumes {
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

function Get-VirtualMachines {

Try {
    
    Write-host "============== VIRTUAL MACHINES RUNNING===================="
    
foreach ($vm in $allVMs) {
     
     #$html2= $item.Group | Select $vmProps
     
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



} 


