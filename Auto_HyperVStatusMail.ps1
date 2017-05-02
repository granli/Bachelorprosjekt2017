####################################################
#                                                  #
#              Mail Status Hyper-V                 #
#                                                  #
####################################################

.'C:\users\administrator.MOLLENBERG\desktop\hyper-vscripts\HyperVStatusRapport.ps1'
.'C:\users\administrator.MOLLENBERG\desktop\hyper-vscripts\Auto_HyperVStatusLog.ps1'

Start-Service smtpsvc

#Skal bruke samme variabel som Loggvariabelen til å sende en daglig mail om status
$time = Get-Date -Format "dd.MMM.yyyy HH:mm:ss"
$SmtpServer = "158.38.43.88"
$SmtpFrom = "administrator@55e-win2k16-3.Mollenberg.Local"
$SmtpTo = "administrator@55e-win2k16-3.Mollenberg.Local"
$SmtpSubject = "Hyper-V Status " + $time
$SmtpBody = $allvariables

Send-MailMessage -to $smtpto -from $smtpfrom -subject $smtpsubject -body $smtpbody -smtpserver $smtpserver