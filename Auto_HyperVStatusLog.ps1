####################################################
#                                                  #
#              Logg Status Hyper V                 #
#                                                  #
####################################################


.'C:\users\administrator.MOLLENBERG\desktop\hyper-vscripts\HyperVStatusRapport.ps1'

$LoggTid = Get-Date -Format "dd.MMM.yyyy HH:mm:ss    "
$Linebreak = "`r`n"

$VMHostLog = "----------------------- VM-Host ---------------------------------" + $Linebreak`+ $loggtid + "Hostname: " + $hostname + $Linebreak`
+ $loggtid + "DomainName: " + $domainname + $Linebreak`
+ $loggtid + "TotalRam: " + $totalram + $Linebreak`
+ $loggtid + "VHDPath: " + $vhdpath + $Linebreak`
+ $loggtid + "VMPath: " + $vmpath + $Linebreak`
+ "-----------------------------------------------------------------" + $Linebreak



$OsLog = "---------------------------- OS ---------------------------------" + $Linebreak`+ $loggtid + "OS: " + $OS.caption + $Linebreak`
+ $loggtid + "ServicePack: " + $OS.ServicePackMajorVersion + $Linebreak`
+ $loggtid + "LastBootUpTime: " + $LastBootUpTime.LastBootUpTime + $Linebreak`
+ $loggtid + "Uptime: " + " Dager " + $uptime.days  + " Timer "+ $uptime.hours  + " Minutter " + $uptime.minutes + $Linebreak`
+ "-----------------------------------------------------------------" + $Linebreak


$ComputerSystemLog = "------------------------- Computer System -----------------------" + $Linebreak`+ $loggtid + "Manufacturer: " + $ComputerSystem.manufacturer + $Linebreak`
+ $loggtid + "Model: " + $ComputerSystem.model + $Linebreak`
+ $loggtid + "NumberOfProcessors: " + $ComputerSystem.NumberOfProcessors + $Linebreak`
+ $loggtid + "NumberOfLogicalProcessors: " + $ComputerSystem.NumberOfLogicalProcessors + $Linebreak`
+ "-----------------------------------------------------------------" + $Linebreak`

$MemoryLog = "---------------------------- Memory -----------------------------" + $Linebreak`+ $loggtid + "FreeGB: " + $memory.freegb + $Linebreak`
+ $loggtid + "TotalGB: " + $memory.totalgb + $Linebreak`
+ $loggtid + "Percent Free: " + $memory.PercentFree + $Linebreak`
+ $loggtid + "FreeVirtualGB: " + $memory.FreeVirtualGB + $Linebreak`
+ $loggtid + "TotalVirtualGB: " + $memory.TotalVirtualGB + $Linebreak`
+ $loggtid + "VirtualPercentFree: " + $memory.VirtualPercentFree + $Linebreak`
+ "-----------------------------------------------------------------" +  $Linebreak`

$NetworkAdaptersLog =  foreach($network in $NetworkAdapters){
"------------------------ Network Adapters -----------------------" + $Linebreak`+ $loggtid + "Name: " + $network.name + $Linebreak`
+ $loggtid + "ReceivedUnicastMB: " + $network.RcvdUnicastMB + $Linebreak`
+ $loggtid + "SentUnicastMB: " + $network.SentUnicastMB + $Linebreak`
+ $loggtid + "ReceivedUnicastPackets: " + $network.ReceivedUnicastPackets + $Linebreak`
+ $loggtid + "SentUnicastPackets: " + $network.SentUnicastPackets + $Linebreak`
+ $loggtid + "ReceivedDiscardedPackets: " + $network.ReceivedDiscardedPackets + $Linebreak`
+ $loggtid + "OutboundDiscardedPackets: " + $network.OutboundDiscardedPackets + $Linebreak`
+ "-----------------------------------------------------------------" +  $Linebreak`
}


$VolumesLog = Foreach($Volume in $Volumes){
"-------------------------- Volumes ------------------------------" + $Linebreak`+ $loggtid + "Drive: " + $Volume.Drive + $Linebreak`
+ $loggtid + "Path: " + $Volume.Path + $Linebreak`
+ $loggtid + "HealthStatus: " + $Volume.HealthStatus + $Linebreak`
+ $loggtid + "SizeGB: " + $Volume.SizeGB + $Linebreak`
+ $loggtid + "FreeGB: " + $Volume.FreeGB + $Linebreak`
+ $loggtid + "PercentFree: " + $Volume.PercentFree + $Linebreak`
+ "-----------------------------------------------------------------" + $Linebreak`

}

$VirtualMachinesLog = foreach ($vm in $allVMs) {
"------------------------ Virtual Machines -----------------------" + $Linebreak`+ $loggtid + "Name: " + $vm.name + $Linebreak`
+ $loggtid + "Uptime: " + " Dager " + $vm.uptime.days  + " Timer "+ $vm.uptime.hours  + " Minutter " + $vm.uptime.minutes + $Linebreak`
+ $loggtid + "Status: " + $vm.status + $Linebreak`
+ $loggtid + "CPUUsage: " + $vm.CPUUsage + $Linebreak`
+ $loggtid + "MemoryAssignedGB: " + $vm.MemoryAssigned + $Linebreak`
+ $loggtid + "MemoryStartupGB: " + $vm.MemoryStartup + $Linebreak`
+ $loggtid + "MemoryDemandGB: " + $vm.MemoryDemand + $Linebreak`
+ $loggtid + "DynamicMemoryEnabled: " + $vm.DynamicMemoryEnabled + $Linebreak`
+ $loggtid + "MemoryMinimumGB: " + $vm.MemoryMinimum + $Linebreak`
+ $loggtid + "MemoryMaximumGB: " + $vm.MemoryMaximum + $Linebreak`
+ "-----------------------------------------------------------------" +  $Linebreak`   
}

$AllVariables = $vmhostlog + $oslog + $ComputerSystemLog + $memorylog + $NetworkAdaptersLog + $VolumesLog + $VirtualMachinesLog
$allvariables | out-file \\55E-WIN2K16-3\HyperVLogs\HyperVStatus.txt

