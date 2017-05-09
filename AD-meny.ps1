function AD-Meny {
do {
      cls
      Write-Host "=============== Active Directory hovedscript ==============
1: Legge til / Slette brukere
2: Endre brukere
3: Administrasjon av OU
4: Administrasjon av grupper
5: Søk i loggfiler

Q: Trykk 'Q' to quit.
==========================================================="

      $input = Read-Host "Velg tall eller trykk Q for å avslutte"
      switch ($input)
      {
            '1' {cls
                 AD-valg1} 
            '2' {cls
                 AD-valg2}
            '3' {cls
                 AD-valg3}
            '4' {cls
                 AD-valg4}
            '5' {cls
                 AD-valg5}      
      }
 }until($input -eq "q")
}

Function AD-valg1 {
do{
 cls
      Write-Host "================ Legge til / Slette brukere ===============     
1: Legg til ny bruker
2: Importer brukere fra valgt csv-fil
3: Slette bruker
     
Q: Trykk 'Q' to quit.
==========================================================="

      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"

      switch ($ADValg)
      {
            '1' {cls
                 new-ADUser} 
            '2' {cls
                 New-ADBrukerCSV}
            '3' {cls
                 Slettebruker}   
      }
 }until($ADValg -eq "q")
}

Function AD-valg2 {
do{
 cls
      Write-Host "====================== Endre bruker =======================  
1: Endring av brukere
2: Aktiver / deaktiver brukere
3: List ut deaktiverte brukere
4: Export brukere til csv-fil
5: Søk i brukere
     
Q: Trykk 'Q' to quit.
==========================================================="

      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"

      switch ($ADValg)
      {
            '1' {cls
                 endrebruker3}
            '2'{$bruker = Get-brukere
                $valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
                switch($valg2){
                           '1'{foreach($item in $bruker)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser $using:item | Enable-ADAccount }}}
                           '2'{foreach($item in $bruker)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser $using:item | Disable-ADAccount}}}
                           }}
            '3'{Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter {enabled -eq $false} | FT name,enabled,samaccountname,distinguishedname } 
            pause}
            '4' {cls
                 Export-Brukere}
            '5' {cls
                 Finn-ADbruker
                 pause}   
      }
 }until($ADValg -eq "q")
}

Function AD-valg3 {
do{
 cls
      Write-Host "==================== OU-Administrasjon ====================    
1: Aktivere / Deaktivere OU
2: Linkning av GPO    
     
Q: Trykk 'Q' to quit.
==========================================================="

      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"

      switch ($ADValg)
      {
            '1' {cls
                 $ou = Get-OUer
                $valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
                switch($valg2){
                           '1'{foreach($item in $ou)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase $using:item | Enable-ADAccount}}}
                           '2'{foreach($item in $ou)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase $using:item | Disable-ADAccount}}}
                           }} 
            '2' {cls
                 GPO-link} 
      }
 }until($ADValg -eq "q")
}

Function AD-valg4{

do{
cls
      Write-Host "=============== Legge bruker i gruppe ==============     
1: List ut grupper
2: Søk etter brukere
3: Liste ut medlemmer av en gruppe
4: Legge brukere til gruppe
5: Legge brukere til gruppe fra CSV-fil
6: Lage ny gruppe


Q: Trykk 'Q' to quit.
==========================================================="
      
      $input = Read-Host "Velg tall eller trykk Q for å avslutte"
      switch ($input)
      {
            '1' {cls
                 Invoke-Command -Session $sesjonADserver -ScriptBlock {
                 get-adgroup -searchbase "OU=mollenberg IT,dc=mollenberg,dc=local" -filter * | FT name,groupscope}
                 pause} 
            '2' {cls
                 finn-adbruker}
            '3' {cls
                 Invoke-Command -Session $sesjonADserver -ScriptBlock {
                 $gruppe = read-host "Skriv navnet på gruppen du ønsker å liste ut medlemmer fra"
                 get-adgroupmember $gruppe | FT Samaccountname -ErrorAction Stop}
                 pause}
            '4' {cls
                 $Gruppe = (read-host "Skriv navnet på gruppenee du ønsker").Split(',') | %{$_.Trim()}
                 $medlem = (read-host "Skriv navnet på brukerne du ønsker å gjøre til medlem av gruppene").Split(',') | %{$_.Trim()}
                 Invoke-Command -Session $sesjonADserver -ScriptBlock {
                 add-adgroupmember $using:gruppe -members $using:medlem}
                 pause}
            '5' {cls
                 $Gruppe = (read-host "Skriv navnet på gruppenee du ønsker").Split(',') | %{$_.Trim()}
                 Import-Csv \\55e-win2k16-2\c$\Users\Administrator.MOLLENBERG\Desktop\Script\ad\brukerecsv.csv | 
                 % {Invoke-Command -Session $sesjonADserver -ScriptBlock {add-adgroupmember $using:gruppe -members $_.samaccountname}}
                 pause}
            '6' {cls
                 $gruppenavn = read-host "Skriv navnet på gruppen du ønsker å lage"
                 Invoke-Command -Session $sesjonADserver -ScriptBlock {
                 new-adgroup -name $using:gruppenavn -groupscope global -path "OU=mollenberg IT,DC=mollenberg,DC=local"}}
            '7'{$gruppe = Get-grupper
                $valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
                switch($valg2){
                           '1'{foreach($item in $gruppe)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-adgroupmember $using:item | Enable-ADAccount}}}
                           '2'{foreach($item in $gruppe)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-adgroupmember $using:item | Disable-ADAccount}}}
                           }}
                     
            }
}until($input -eq "q")

}

Function AD-valg5 {
do{
 cls
      Write-Host "======================= Logg / Filer ======================     
1: Søk gjennom loggfiler
2: Finn filer på filstasjon    
     
Q: Trykk 'Q' to quit.
==========================================================="


      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"

      switch ($ADValg)
      {
            '1' {cls
                 finn-filer} 
            '2' {cls
                 loggSok} 
      }
 }until($ADValg -eq "q")
}

function Export-Brukere{
cls
$Utfil = "C:\Users\Administrator.MOLLENBERG\Desktop\Script\ad\brukerecsv.csv"
      Write-Host "=============== Legge brukere i CSV-fil ==============
      
      
1: List ut CSV-fil
2: Legg brukere til CSV-fil


Q: Trykk 'Q' to quit.
==========================================================="
      
      $input = Read-Host "Please make a selection: 1 2 eller q for avslutt"
      switch ($input){
            '1'{Import-Csv $Utfil | ogv}
            '2'{
$OUer +=Invoke-Command -Session $SesjonADServer -ScriptBlock {@{
"drift" = get-aduser -filter * -searchbase "ou=drift,ou=mollenberg it,dc=mollenberg,dc=local"
"ledelse" =get-aduser -filter * -searchbase "ou=ledelse,ou=mollenberg it,dc=mollenberg,dc=local"
"produksjon" = get-aduser -filter * -searchbase "ou=produksjon,ou=mollenberg it,dc=mollenberg,dc=local"
"salg" = get-aduser -filter * -searchbase "ou=salg,ou=mollenberg it,dc=mollenberg,dc=local"
"alle" = get-aduser -filter *}}
   
$valg = (Read-Host "Skriv navnet på brukerne eller OU-ene du ønsker å legge til i CSV-filen. Skill hver input med ',' ").Split(',') | %{$_.Trim()}

foreach($bruker in $valg){
if($bruker -in $OUer.keys)
    {$ouer.$bruker | select -property name, enabled, distinguishedname, samaccountname | Export-Csv -Append $Utfil}

    elseif($bruker -in $OUer.alle.samaccountname){
        
        $navn = $OUer.alle | where {$_.samaccountname -eq $bruker}
        
        if(get-content $utfil | Select-String -pattern $navn){}
        else{
        $navn | select -property name, enabled, distinguishedname, samaccountname | Export-Csv $Utfil
            }
     }else{"Fant ingen brukere med brukernavnet " + $bruker}
                        }
}#Ender valg 2
}#Ender switch
}#Ender Funksjon

Function New-ADBrukerCSV {
		
 do {
	  # Dialogboks for å åpne CSV-fil 
	  $csvFil = New-Object System.Windows.Forms.OpenFileDialog
	  $csvFil.Filter = 
	  "csv files (*.csv)|*.csv|txt files (*.txt)|"+
	  "*.txt|All files (*.*)|*.*"
	  $csvFil.Title = 
	  "Åpne opp CSV fil som inneholder brukere"
	  $csvFil.ShowDialog()
 }until ($csvFil.FileName -ne "")
		
	 # Importer brukere fra CSV
	 $brukere = Import-Csv $csvFil.FileName -Delimiter ";"
	 write 'csv importert'
		
 # Gå igjennom alle brukere 
 foreach ($bruker in $brukere) {
		
	  # Konvert passord over til sikker tekst 
	  $passord = ConvertTo-SecureString $bruker.Passord `
	   -AsPlainText -Force 
	  # Hent ut etternavn 
	  $etternavn = $bruker.Etternavn 
	  # Hent ut fornavn 
	  $fornavn = $bruker.Fornavn 
	  
	  # Hent ut OU-sti 
	  $OU = $bruker.OU;
      
      
		
	  # Sett et unikt brukernavn 
	  $brukernavn = Set-Brukernavn $fornavn $etternavn 
	  # Ta bort mellomrom ol. 
	  $brukernavn = $brukernavn.Trim() 
	  # Opprett fullt navn ut fra fornavn og etternavn 
	  $fulltNavn = "$fornavn $etternavn"
      $fbnavn = "$fornavn $brukernavn $etternavn" 
      # Hent ut epost 
	  $epost = $brukernavn + "@mollenberg.no"
		
	  # Opprett bruker 
	  Invoke-Command -Session $SesjonADServer -ScriptBlock {
      $dato = (get-date).tostring()
	   Try 
        {
		   New-ADUser `        -SamAccountName $using:brukernavn `        -Name $using:fbnavn `        -Surname $using:etternavn `        -Path $using:OU `        -AccountPassword $using:passord `        -ChangePasswordAtLogon $true `        -EmailAddress $using:epost `        -Enabled $true `
        -givenname $using:fornavn `
        -userprincipalname $using:brukernavn `
		   
         $dato + " " + "Brukeren " + $using:fornavn + " " + $using:etternavn + " ble opprettet med brukernavnet: " + $using:Brukernavn + " Plassering: " + $using:ou | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBrukerCSV.txt
		 write-host "Brukeren $using:brukernavn er opprettet med epost $using:epost" -foregroundcolor green                }catch{        $feilmelding = $dato + " Feil ved oppretting av brukeren " +$using:fbnavn + " Feilmelding :" + $_.exception.message        write-host $feilmelding -foregroundcolor red        $feilmelding | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBrukerCSV-feil.txt        }            }     }
}

Function Get-OUer {
$OUer =Invoke-Command -Session $SesjonADServer -ScriptBlock {@{
"drift" = get-aduser -filter * -searchbase "ou=drift,ou=mollenberg it,dc=mollenberg,dc=local"
"ledelse" =get-aduser -filter * -searchbase "ou=ledelse,ou=mollenberg it,dc=mollenberg,dc=local"
"produksjon" = get-aduser -filter * -searchbase "ou=produksjon,ou=mollenberg it,dc=mollenberg,dc=local"
"salg" = get-aduser -filter * -searchbase "ou=salg,ou=mollenberg it,dc=mollenberg,dc=local"
"alle" = get-aduser -filter *}}
do{
write-host "Skriv navnet på OU-ene. Skill med ',' for hver OU. Skriv 'hjelp' for å liste ut alle OU-er"
$OUvalg = (Read-Host).Split(',') | %{$_.Trim()}
if($OUvalg -eq 'hjelp'){$OUer}else{
foreach($ou in $OUvalg){
if($ou -in $OUer.keys)
    {$ferdigOU += $ouer.$ou}
    else{"fant ingen OU-er med navnet " + $OU}
    }if($ferdigOU){
return $ferdigOU}
}
}until($OUvalg -eq 'q')
}

Function Get-grupper {
$grupper = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-adgroup -searchbase "OU=mollenberg IT,dc=mollenberg,dc=local" -filter * -properties members} 
do{
Write-Host "Skriv navnet på gruppene. SKill med ',' for hver bruker. Skriv 'hjelp' for å liste ut alle grupper"
$GruppeValg = (Read-Host).Split(',') | %{$_.Trim()}
if($gruppevalg -eq 'hjelp'){$grupper.name}else{
foreach($gruppe in $gruppevalg){
if($gruppe -in $grupper.name)
    {$FerdigGruppe += $gruppe + ","}
else{"Fant ingen grupper med navnet " + $gruppe}   
    }if($FerdigGruppe){
$formatgruppe = $FerdigGruppe.Split(',',[system.stringsplitoptions]::RemoveEmptyEntries) | %{$_.Trim()}
return $formatgruppe}
}
}until($gruppevalg -eq 'q')
}

Function Get-brukere {
$brukere = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-aduser -filter *}
do{
Write-Host "Skriv navnet på brukerne. Skill med ',' for hver bruker. Skriv 'hjelp' for å søke i brukernavn"
$BrukerValg = (Read-Host).Split(',') | %{$_.Trim()}
if($brukervalg -eq "hjelp"){Finn-ADbruker}else{
foreach ($person in $BrukerValg){
if($person -in $brukere.samaccountname)
    {$FerdigBruker+=$person + ","}
    else{"Fant ingen brukere med navnet " + $person}
    }if($FerdigBruker){
    $formatbruker=$FerdigBruker.Split(',',[system.stringsplitoptions]::RemoveEmptyEntries) | %{$_.Trim()}
    return $formatbruker}
}
}until($brukervalg -eq 'q')
}

function Aktivering {
do{
Write-Host "1: Aktiver/deaktiver OU-er
2: Aktiver/deaktiver grupper
3: Aktiver/deaktiver brukere
4: List ut deaktiverte brukere
Q: Trykk 'Q' to quit"
$valg = Read-Host 

switch ($valg){
            '1'{$ou = Get-OUer
                $valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
                switch($valg2){
                           '1'{foreach($item in $ou)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase $using:item | Enable-ADAccount}}}
                           '2'{foreach($item in $ou)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase $using:item | Disable-ADAccount}}}
                           }}
            '2'{$gruppe = Get-grupper
                $valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
                switch($valg2){
                           '1'{foreach($item in $gruppe)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-adgroupmember $using:item | Enable-ADAccount}}}
                           '2'{foreach($item in $gruppe)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-adgroupmember $using:item | Disable-ADAccount}}}
                           }}
            '3'{$bruker = Get-brukere
                $valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
                switch($valg2){
                           '1'{foreach($item in $bruker)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser $using:item | Enable-ADAccount }}}
                           '2'{foreach($item in $bruker)
                                {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser $using:item | Disable-ADAccount}}}
                           }}
            '4'{Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter {enabled -eq $false} | FT name,enabled,samaccountname,distinguishedname } 
            pause}
}#Ender Switch $valg
}until($valg -eq 'q')
}#Ender funksjon

function endrebruker3 {
$brukere = Get-brukere
$velgprop = Read-Host "velgprop"
$setprop = read-host "setprop"
$properties = Invoke-Command -Session $SesjonADServer -ScriptBlock {Get-ADUser -Filter * -Properties * | Get-Member -MemberType property}

$hash = New-Object Hashtable
$hash.add($velgprop,$setprop)

foreach ($person in $brukere)
    {if($velgprop -in $properties.name)
    {Invoke-Command -Session $SesjonADServer -ScriptBlock {set-aduser $using:person -replace $using:hash}
    }else{$velgprop + " ble ikke gjenkjent som en property"}
}
}

Function Finn-ADbruker{

Do{

$navn = read-host "Skriv hele eller deler av nanvet for å søke etter en bruker. Trykk 'q' for å gå tilbake"

if($navn -ne [string]::Empty){
 $brukere = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-aduser -filter "name -like '*$using:navn*'" -properties name, enabled, distinguishedname, samaccountname | format-table name, enabled, distinguishedname, samaccountname | out-string}  
}

if($brukere){    
    write-host $brukere} 
 else{
    if($navn -eq 'q'){}else{
    write-host 'Fant ingen brukere med brukernavnet ' -foregroundcolor yellow -NoNewline
    write-host $navn -ForegroundColor red -NoNewline
    write-host '. Vennligst prøv igjen med et annet brukernavn' -ForegroundColor yellow}
    }}until($navn -eq "q")
    
}

Function Finn-endrebruker{

Do{

 $navn = read-host
 
if($navn -ne [string]::Empty){
 $brukere = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-aduser -filter "name -like '*$using:navn*'" -properties givenname, surname, enabled, streetaddress, emailaddress, mobilephone, samaccountname, HomePhone  | format-table givenname, surname, enabled, streetaddress, emailaddress, mobilephone, samaccountname, HomePhone | out-string}  
}
 
if($brukere){
    
    write-host $brukere
    } 
 else
    {
    write-host 'Fant ingen brukere med brukernavnet ' -foregroundcolor yellow -NoNewline
    write-host $navn -ForegroundColor red -NoNewline
    write-host '. Vennligst prøv igjen med et annet brukernavn' -ForegroundColor yellow
    }
    }while(!$brukere)
    
}

Function SletteBruker{
    Write-Host "Søk etter bruker du vil slette med fornavn eller etternavn: "
    invoke-expression Finn-ADbruker
    invoke-command -Session $sesjonADServer -ScriptBlock {
   
    #Gir oss beskjed om hva som skal skrives inn
    
    write-host "Skriv inn SamAccountName på brukeren du ønsker å slette: "

    $bruker = Read-Host 
    
    #Henter informasjonen som ble skrevet inn over og bruker denne til å slette den valgte brukeren.
    #Gir oss beskjed om hva som vil skje, og om vi ønsker å gjennomføre 

    do
    {
    
    $Kontonavn = Get-ADuser -filter {samaccountname -eq $bruker}
    $validering = $false
    $ou = ($kontonavn.distinguishedname -split ",",2)[1]
    
    if($Kontonavn)
        {
    $Kontonavn | set-adobject -protectedfromaccidentaldeletion:$false 
    Remove-ADuser -confirm -identity $bruker #-recursive 
    $validering = $true 
    Write-Host "Brukeren: "  -foregroundcolor yellow -NoNewline
    write-host $bruker  -ForegroundColor red -NoNewline
    write-host " ble slettet fra OU-en: " -ForegroundColor yellow -NoNewline
    write-host $ou -ForegroundColor red 
    $dato = (get-date).tostring()    $dato + " " + "Brukeren: " + $bruker + " ble slettet fra: " + $ou | out-file -append c:\users\administrator\desktop\Powershell-logs\slettebruker.txt
          
        }
    if ($bruker -eq "x") 
        {return}
    if($validering -eq $false)
        {
    Write-Host 'Brukeren med brukernavn ' -ForegroundColor Yellow -NoNewline
                    write-host $Bruker -foregroundcolor red -noNewline
                    write-host ' finnes ikke, vennligst prøv igjen eller trykk X for å avslutte' -ForegroundColor yellow
    $bruker = Read-Host 
        }
        
    }while ($validering -eq $false)
}
}

function Set-Brukernavn($fornavn, $etternavn) {
#Funksjonen tar inn fornavn og etternavn og lager et brukernavn ut av de første 3 bokstavene i hver.    
    #Setter midlertidig variabelen til $null slik at den ikke inneholder noe fra
    #tidligere.
    $MidlertidigBrukernavn = $null
    $sjekk = $true

    #If-testene under sjekker om lengden på fornavn og etternavn. Hvis etternavnet er
    #på to bokstaver blir brukernavent på to bokstaver i stedet for tre
    if($fornavn.length -le 2){
        $brukernavn = $fornavn.substring(0,2) 
    }else{
        $brukernavn = $fornavn.substring(0,3)
    }
    if($etternavn.length -le 2){
        $brukernavn += $etternavn.substring(0,2) 
    }
    else{
        $brukernavn += $etternavn.substring(0,3)
    }
    
    $teller = 1
    $i = 1
    do{
    $sjekk = $false
    $finnes = Invoke-command -session $sesjonadserver -scriptblock {get-aduser -filter "samaccountname -eq '$using:brukernavn'" | select -ExpandProperty samaccountname }
    
    
    if($finnes -eq $brukernavn){
    try{
        write-host "Brukernavnet "$brukernavn "finnes fra før"
        $dato = (get-date).tostring()        $dato + " " + "Brukernavnet " +$brukernavn + " finnes fra før med Plassering: " + $ou | out-file -append c:\users\administrator\desktop\loggfiler\set-brukernavn.txt
        $i++
        $brukernavn = $fornavn.substring(0,$i)+$etternavn
        $sjekk = $true
        }catch{
        #If-testene under sjekker om lengden på fornavn og etternavn. Hvis etternavnet er
    #på to bokstaver blir brukernavent på to bokstaver i stedet for tre
    if($fornavn.length -le 2){
        $brukernavn = $fornavn.substring(0,2) 
    }else{
        $brukernavn = $fornavn.substring(0,3)
    }
    if($etternavn.length -le 2){
        $brukernavn += $etternavn.substring(0,2) 
    }
    else{
        $brukernavn += $etternavn.substring(0,3)
    }
        $teller++
        $brukernavn = $brukernavn + $teller
        }
     }else{return $brukernavn}
     
     }until($finnes = $null)
}

Function new-ADUser{
    # Oppretter en ny AD bruker ved å skrive inn info selv
    # Skriv inn fornavn
    $fornavn = read-host "skriv inn brukerens fornavn" 
    # Skriv inn etternavn
    $etternavn = Read-Host "Skriv inn brukerens etternavn"
    # Sjekk at fornavn og etternavn ikke er for kort
    do
    {
        $err = $false
        if($fornavn.Length -lt 2)
        {$fornavn = read-host `        -prompt 'fornavnet må minst være på to bokstaver'        $err = $true        }        if ($etternavn.Length -lt 2)        {        $etternavn = Read-Host `        -Prompt 'Etternavnet må være på minst to bokstaver'        $err = $true        }    }while($err -eq $true)    # Opprett fullt navn ut fra fornavn og etternavn    $Fulltnavn = "$fornavn $etternavn"       # sett et unikt brukernavn    $Brukernavn = Set-Brukernavn $fornavn $etternavn        #Spesifiserer OU    $OUvalg = $false    Write-Host "Vennligst velg ønsket OU:         1. Drift         2. Ledelse         3. Produksjon         4. Salg"    $OU = Read-Host    if ($OU -eq "1") {$OU = "OU=drift,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OU -eq "2") {$OU = "OU=ledelse,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OU -eq "3") {$OU = "OU=produksjon,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OU -eq "4") {$OU = "OU=salg,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OUvalg -eq $false) {Write-Host "Ingen valg ble registrert, brukeren ble plassert i toppen av domenet" ; $OU = "OU=Mollenberg IT,DC=mollenberg,DC=local"}    #ta bort mellomrom ol.    $brukernavn = $Brukernavn.trim()    $fbnavn = "$fornavn $brukernavn $etternavn"    $epost = $brukernavn + "@mollenberg.no"    # les inn og konverter passordet til sikker tekst    do {    $passord = Read-host "Skriv inn brukerens passord" -AsSecureString    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passord)    $plainpassord = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)    if(checkpassword($plainpassord) -eq $true)    {}    else{Write-host "Passord må inneholde: 9 Tegn, A-Z, a-z, 0-9 og et spesialtegn. Prøv igjen!"}    }until(checkpassword($plainpassord) -eq $true)     #forsøk å opprett AD bruker    Invoke-Command -Session $SesjonADServer -ScriptBlock {        $dato = (get-date).tostring()        try        {        New-ADUser `        -SamAccountName $using:brukernavn `        -Name $using:fbnavn `        -Surname $using:etternavn `        -Path $using:OU `        -AccountPassword $using:passord `        -ChangePasswordAtLogon $true `        -EmailAddress $using:epost `        -Enabled $true `        -givenname $using:fornavn `
        -userprincipalname $using:brukernavn `        $dato + " " + "Brukeren " + $using:fornavn + " " + $using:etternavn + " ble opprettet med brukernavnet: " + $using:Brukernavn + " Plassering: " + $using:ou | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBruker.txt
		         write-host "Brukeren $using:brukernavn er opprettet med epost $using:epost" -foregroundcolor green        Pause        }catch{        $feilmelding = $dato + " Feil ved oppretting av brukeren " +$using:fbnavn + " Feilmelding :" + $_.exception.message                write-host $feilmelding -foregroundcolor red        Pause        $feilmelding | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADbruker-feil.txt        }            }}Function New-ADBrukerCSV {
		
 do {
	  # Dialogboks for å åpne CSV-fil 
	  $csvFil = New-Object System.Windows.Forms.OpenFileDialog
	  $csvFil.Filter = 
	  "csv files (*.csv)|*.csv|txt files (*.txt)|"+
	  "*.txt|All files (*.*)|*.*"
	  $csvFil.Title = 
	  "Åpne opp CSV fil som inneholder brukere"
	  $csvFil.ShowDialog()
 }until ($csvFil.FileName -ne "")
		
	 # Importer brukere fra CSV
	 $brukere = Import-Csv $csvFil.FileName -Delimiter ";"
	 write 'csv importert'
		
 # Gå igjennom alle brukere 
 foreach ($bruker in $brukere) {
		
	  # Konvert passord over til sikker tekst 
	  $passord = ConvertTo-SecureString $bruker.Passord `
	   -AsPlainText -Force 
	  # Hent ut etternavn 
	  $etternavn = $bruker.Etternavn 
	  # Hent ut fornavn 
	  $fornavn = $bruker.Fornavn 
	  
	  # Hent ut OU-sti 
	  $OU = $bruker.OU;
      
      
		
	  # Sett et unikt brukernavn 
	  $brukernavn = Set-Brukernavn $fornavn $etternavn 
	  # Ta bort mellomrom ol. 
	  $brukernavn = $brukernavn.Trim() 
	  # Opprett fullt navn ut fra fornavn og etternavn 
	  $fulltNavn = "$fornavn $etternavn"
      $fbnavn = "$fornavn $brukernavn $etternavn" 
      # Hent ut epost 
	  $epost = $brukernavn + "@mollenberg.no"
		
	  # Opprett bruker 
	  Invoke-Command -Session $SesjonADServer -ScriptBlock {
      $dato = (get-date).tostring()
	   Try 
        {
		   New-ADUser `        -SamAccountName $using:brukernavn `        -Name $using:fbnavn `        -Surname $using:etternavn `        -Path $using:OU `        -AccountPassword $using:passord `        -ChangePasswordAtLogon $true `        -EmailAddress $using:epost `        -Enabled $true `
        -givenname $using:fornavn `
        -userprincipalname $using:brukernavn `
		   
         $dato + " " + "Brukeren " + $using:fornavn + " " + $using:etternavn + " ble opprettet med brukernavnet: " + $using:Brukernavn + " Plassering: " + $using:ou | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBrukerCSV.txt
		 write-host "Brukeren $using:brukernavn er opprettet med epost $using:epost" -foregroundcolor green                }catch{        $feilmelding = $dato + " Feil ved oppretting av brukeren " +$using:fbnavn + " Feilmelding :" + $_.exception.message        write-host $feilmelding -foregroundcolor red        $feilmelding | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBrukerCSV-feil.txt        }            }     }
Pause
}

function GPO-link{
Invoke-Command -Session $SesjonADServer -ScriptBlock {
   
    do{
    write-host "Du har valgt linking av Group Policy Object til en OU. Du vil nå få noen valg:" -ForegroundColor Yellow

    write-host "1. Link GPO til OU" -ForegroundColor Cyan
    Write-Host "2. List ut eksisterende GPO-er" -ForegroundColor Cyan
    Write-Host "3. List ut alle GPO-er som er linket til en bestemt OU" -ForegroundColor Cyan
    Write-Host "4. List ut alle OU-er som er linktet til en bestemt GPO" -ForegroundColor Cyan
    write-host "Q. Avslutt" -ForegroundColor Cyan
    $valg = Read-Host
        if($valg -eq "1")
            {
            do{
            Write-Host "Skriv navn på GPO eller skriv Q for å gå tilbake" -ForegroundColor Yellow
            $gponavn = Read-Host 
            $gposjekk = get-gpo -name $gponavn -erroraction silentlycontinue
             }until($gposjekk)  
                do{    
            Write-Host "GPO-en " -ForegroundColor Yellow -NoNewline
            Write-Host $gponavn -ForegroundColor Green -NoNewline
            Write-Host " er Valgt. Hvilken OU vil du linke den med?" -ForegroundColor Yellow
            Write-Host "1. drift" -ForegroundColor Cyan
            Write-Host "2. ledelse" -ForegroundColor Cyan
            Write-Host "3. Produksjon" -ForegroundColor Cyan
            Write-Host "4. Salg" -ForegroundColor Cyan
            Write-Host "Q. Gå tilbake" -ForegroundColor Cyan
            
            
            $OUnavn = Read-Host
            if($OUnavn -eq "1")
                {$OU="OU=drift,OU=Mollenberg IT,DC=mollenberg,DC=local"}
            if($OUnavn -eq "2")
                {$OU="OU=ledelse,OU=Mollenberg IT,DC=mollenberg,DC=local"}
            if($OUnavn -eq "3")
                {$OU="OU=produksjon,OU=Mollenberg IT,DC=mollenberg,DC=local"}
            if($OUnavn -eq "4")
                {$OU="OU=salg,OU=Mollenberg IT,DC=mollenberg,DC=local"}
                
                }until(($OUnavn -eq "q") -or $ounavn -in 1..4)
                if($ounavn -in 1..4){
                new-gplink -name $gponavn -target $OU -ErrorAction SilentlyContinue
                Write-Host "OU-en " -NoNewline
                Write-Host $OU -ForegroundColor Green -NoNewline
                write-host " ble linket med GPO-en " -NoNewline
                Write-Host $gponavn -ForegroundColor Green
                $dato = (get-date).tostring() 
                $loggfil = $dato + " GPO " + $gponavn + " linket med: " + $OU | out-file -append \\55e-win2k16-1\Powershell-logs\GPO-link.txt
                }else {return}

               
                   
            }
        if($valg -eq "2")
            {get-gpo -all | FT displayname}
        if($valg -eq "3")
            { 
            do{    
            Write-Host "List ut alle GPO-er som er linket til en bestemt OU " -ForegroundColor Yellow 
            Write-Host "1. drift" -ForegroundColor Cyan
            Write-Host "2. ledelse" -ForegroundColor Cyan
            Write-Host "3. Produksjon" -ForegroundColor Cyan
            Write-Host "4. Salg" -ForegroundColor Cyan
            Write-Host "Q. Gå tilbake" -ForegroundColor Cyan
           $OUnavn = Read-Host
                if($OUnavn -eq "1")
                    {(get-gpinheritance -target "OU=drift,OU=Mollenberg IT,DC=mollenberg,DC=local").gpolinks | FT displayname,target}
                if($OUnavn -eq "2")
                    {(get-gpinheritance -target "OU=ledelse,OU=Mollenberg IT,DC=mollenberg,DC=local").gpolinks | FT displayname,target}
                if($OUnavn -eq "3")
                    {(get-gpinheritance -target "OU=produksjon,OU=Mollenberg IT,DC=mollenberg,DC=local").gpolinks | FT displayname,target}
                if($OUnavn -eq "4")
                    {(get-gpinheritance -target "OU=salg,OU=Mollenberg IT,DC=mollenberg,DC=local").gpolinks | FT displayname,target}     
             
             }until($OUnavn -eq "q")
        
            }
            if($valg -eq "4")
            {
                do{
            Write-Host "Skriv inn navnet på GPO-en du vil sjekke eller skriv Q for å gå tilbake" -ForegroundColor Yellow
            $gpotest = Read-Host
            $gponavn = get-gpo -name $gpotest -erroraction silentlycontinue
                if($gponavn){
                $gpoid = "*" + $gponavn.id + "*"
                $path = get-adobject -filter {gplink -like $gpoid} 
                write-host $path}
                }until(($gponavn) -or $gpotest -eq 'q')
            }
    }until($valg -eq "q")

}
}

function Format-Brukernavn ($brukernavn){
    #Funksjonen tar imot et brukernavn og formaterer det til små bokstaver og endrer æøå til eoa
    #setter brukernavn til små bokstaver
    $brukernavn=$brukernavn.ToLower()
    #Erstatter æøå med eoa
    $brukernavn=$brukernavn.replace('æ','e')
    $brukernavn=$brukernavn.replace('ø','o')
    $brukernavn=$brukernavn.replace('å','a')
    #Returnere det formatere brukernavnet    
    return $brukernavn
}

function finn-filer{
$finn = Read-Host "Bruk 1 for å finne filer eller 2 for å slette innholdet av csv-filen"
$outputfil = "C:\Users\Administrator.MOLLENBERG\Desktop\Script\funnet-filer.csv"
$inputfil = Import-Csv "C:\Users\Administrator.MOLLENBERG\Desktop\Script\funnet-filer.csv"
switch($finn)
    { '1' {$funnet = Invoke-Command -Session $SesjonVMServer -scriptblock{
            Get-ChildItem \\55e-win2k16-3\c$\Users\administrator.MOLLENBERG\Desktop -include *.mp3,*.wma,*.wmv,*.aac,*.avi,*.mp4,*.3gp,*.mkv -Recurse | 
            Where-Object { ($_.PSIsContainer -eq $false)}
          }
            $funnet | Select-Object Name,Directory,Length | Export-Csv $outputfil
          }
      '2' {
            foreach($fil in $inputfil){
            $filpath = join-path $fil.directory $fil.name
            Invoke-Command -Session $SesjonVMServer -scriptblock{remove-item -verbose $using:filpath -whatif}
          }
          } 
    }
}

Function loggSok{
do{
Write-host "Hva ønsker du å gjøre?
1 = Søk etter et ord og list ut alle filer som inneholder ordet
2 = Søk etter et ord og list ut alle linjer i alle filer som inneholder ordet
3 = List ut alle logger
4 = List ut innholdet til en bestemt logg
X = Avslutt" -ForegroundColor Yellow

$Valg = Read-Host

switch ($Valg) 
    { 
        1 {SokOrd} 
        2 {ListLinjer}
        3 {ListLogg}
        4 {ListInnhold}
        x {return} 
        default {"Valget ble ikke gjenkjent"}
    }
}until($Valg -eq "x")
}

Function SokOrd {
$Sok = Read-Host "Skriv ordet du vil søke etter"
Get-ChildItem -path "\\55e-win2k16-1\Powershell-logs\" -recurse | Select-String -pattern $Sok | group path | FT name
Get-ChildItem -path "\\55e-win2k16-3\HyperVlogs\" -recurse | Select-String -pattern $Sok | group path | FT name
}

Function ListLogg{
Get-ChildItem -path \\55e-win2k16-1\Powershell-logs\* | FT name,fullname
Get-ChildItem -path \\55e-win2k16-3\HyperVlogs\* | FT name,fullname
}

function ListLinjer{
$sok = Read-Host "Skriv inn ett ord og list ut alle linjer som inneholder ordet"
Select-String \\55e-win2k16-1\Powershell-logs\* -pattern $sok | FT linenumber,line,filename,Path
Select-String \\55e-win2k16-3\HyperVlogs\* -pattern $sok | FT linenumber,line,filename,Path
}

function ListInnhold{
$ErrorActionPreference= 'silentlycontinue'
$Innhold = Read-Host "Skriv inn ett ord og list ut alle linjer som inneholder ordet"
Get-Content \\55e-win2k16-1\Powershell-logs\$Innhold 
Get-Content \\55e-win2k16-3\HyperVlogs\$innhold 
}

Function checkPassword($pass){
	$passLength = 9

	if ($pass.Length -ge $passLength)
		{$pw2test = $pass
		$isGood = 0
		If ($pw2test -match '[^a-zA-Z0-9]') #check for special chars
			{
			$isGood++ }
		If ($pw2test -match "[0-9]")
			{
			$isGood++ }
		If ($pw2test -cmatch "[a-z]")
			{
			$isGood++ }
		If ($pw2test -cmatch "[A-Z]")
			{
			$isGood++ }

		If ($isGood -ge 4)
			{ 
            return $true}
		Else
			{
            return $false}}
	Else {return $false
        }
	}