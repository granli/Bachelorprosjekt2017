#Oppretter en sesjon så snart vi kjører scriptet

      $passord = '2BADRGR4!'
      $innlogging = 'mollenberg.local\administrator'
      $pass = ConvertTo-SecureString -AsPlainText $passord -Force
      $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $innlogging,$pass
      $SesjonADServer = New-PSSession -ComputerName 55e-win2k16-1 -Credential $cred
      $SesjonVMServer = New-PSSession -ComputerName 55e-win2k16-3 -Credential $cred
      $SesjonScriptServer = New-PSSession -ComputerName 55e-win2k16-2 -Credential $cred

Function Get-OUer {
#Funksjon for å hente OU-er som et objekt til andre funksjoner
#Lager variabel som inneholder alle OU-ene
$OUer =Invoke-Command -Session $SesjonADServer -ScriptBlock {Get-ADOrganizationalunit -filter * -searchbase 'OU=mollenberg IT,DC=mollenberg,DC=local'}
do{
write-host "Skriv navnet på OU-ene. Skill med ',' for hver OU. Skriv 'hjelp' for å liste ut alle OU-er"
# Lar oss velge flere OU-er ved å skille navnene med komma
$OUvalg = (Read-Host).Split(',') | %{$_.Trim()}
# Lister ut alle OU-ene vi kan velge dersom vi skriver hjelp
if($OUvalg -eq 'hjelp'){write-host ($OUer.name | out-string)}else{
#Går gjennom alle valgene vi skrev
foreach($ou in $OUvalg){
# Sjekker om valget er navnet på en OU
if($ou -in $OUer.name)
    #Legger OU-ene til i en variabel
    {[object[]]$valg += $OUer | where {$_.name -eq $OU}}
    else{write-host "fant ingen OU-er med navnet $($OU)" -fore red}
    }
    # Returnerer variabelen som inneholder alle OU-ene
    return $valg  
}
}until($OUvalg -eq 'q')
}# Ender funksjon

Function Get-grupper {
# Funksjon for å hente grupper som et objekt til andre funksjoner
# Lager variabel som inneholder alle gruppene
$grupper = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-adgroup -searchbase "OU=mollenberg IT,dc=mollenberg,dc=local" -filter * -properties members} 
do{
Write-Host "Skriv navnet på gruppene. SKill med ',' for hver gruppe. Skriv 'hjelp' for å liste ut alle grupper"
# Lar oss velge flere grupper ved å skille navnene med komma
$GruppeValg = (Read-Host).Split(',') | %{$_.Trim()}
# Dersom vi skriver hjelp blir alle gruppenavnene listet ut
if($gruppevalg -eq 'hjelp'){write-host ($grupper.name | Out-String)}else{
# Går gjennom alle valgene vi skrev inn
foreach($gruppe in $gruppevalg){
# Sjekker om nanvet vi skrev inn er navnet på en gruppe
if($gruppe -in $grupper.name)
    #Legger gruppene til i en variabel
    {[object[]]$valg += $grupper | where {$_.name -eq $gruppe}}
    else{write-host "Fant ingen grupper med navnet $($gruppe)" -fore red}   
    }
    # returnerer variabelen som inneholder alle gruppene
    return $valg
}
}until($GruppeValg -eq 'q')
}#Ender funksjon

Function Get-brukere {
# Funksjon for å hente brukere som objekter til andre funksjoner
# Lager variabel som inneholder alle brukerne
$brukere = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-aduser -filter *}
do{
Write-Host "Skriv navnet på brukerne. Skill med ',' for hver bruker. Skriv 'hjelp' for å søke i brukernavn"
# Lar oss velge flere brukere ved å skille navnene med komma
$BrukerValg = (Read-Host).Split(',') | %{$_.Trim()}
#Dersom vi skriver hjelp henter vi Finn-adbrukerfunksjonen som lar oss søke på brukernavn
if($brukervalg -eq "hjelp"){Get-ADbruker}else{
#Går gjennom alle valgene vi skrev inn 
foreach ($person in $BrukerValg){
    #Sjekker om valget vi skrev inn er navnet på en bruker
    if($person -in $brukere.samaccountname)
    #Legger brukeren til i en variabel
    {[object[]]$valg += $brukere | where {$_.samaccountname -eq $person}}
    else{write-host "Fant ingen brukere med navnet $($person)" -fore Red}
    }
    # Returnerer variabelen som inneholder alle brukerne
    return $valg
}
}until($BrukerValg -eq 'q')
}#Ender funksjon

function Set-Brukernavn($fornavn, $etternavn) {
#Funksjonen tar inn fornavn og etternavn og lager et brukernavn ut av de første 3 bokstavene i hver.    
    #Setter midlertidig variabelen til $null slik at den ikke inneholder noe fra
    #tidligere.
    
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
    
    #Lager to tellere for å kunne garantere 100% unike brukernavn
    $teller = 1
    $i = 1
    do{
    #Setter sjekk til false, denne holder do-løkka gående helt til vi endrer sjekk till true etter en bruker er blitt opprettet
    $sjekk = $false
    # Lager variabel som brukes til å sjekke om brukernavnet eksisterer
    $finnes = Invoke-command -session $sesjonadserver -scriptblock {get-aduser -filter "samaccountname -eq '$using:brukernavn'" | select -ExpandProperty samaccountname }
    
    #Sjekker om brukernavnet eksisterer fra før
    if($finnes -eq $brukernavn){
    #Brukernavnet eksisterer. Da må vi generere ett nytt
    #Forsøker å opprette et nytt brukernavn
    try{
        # Gir oss beskjed om at brukeren eksisterer og hvor den ligger. Sender også dette til loggfil
        write-host "Brukernavnet "$brukernavn "finnes fra før"
        $dato = (get-date).tostring()        $dato + " " + "Brukernavnet " +$brukernavn + " finnes fra før med Plassering: " + $ou |         out-file -append \\55e-win2k16-1\Powershell-logs\Set-brukernavn.txt        # Øker teller
        $i++
        #Lager nytt brukernavn med teller
        # Her legges en ekstra bokstav til på fornavnet og legger til etternavn for å opprette et nytt brukernavn
        $brukernavn = $fornavn.substring(0,$i)+$etternavn
        #Sjekk blir satt til true og do-løkken vil avsluttes
        $sjekk = $true
        }catch{
        
        #Dersom vi går tom for bokstaver på fornavnet til brukeren må vi legge til et tall i brukernavnet
        # Øker teller
        $teller++
        #Fjerner bokstaver fra fornavn og etternavn på nytt slik at brukernavnet blir det orginale igjen
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

        #Oppretter et nytt brukernavn med teller
        #Brukernavn blir det orginale brukernavnet med et tall bak seg.
        #Løkken fortsetter og det nye brukernavnet vil testes, dersom det også eksisterer øker vi tallet og prøver på nytt helt til det fungerer.
        $brukernavn = $brukernavn + $teller
        }
     }
     # Hvis brukernavnet ikke eksisterer fra før returneres det
     else{return $brukernavn}
     #Fortsetter do-løkken helt til finnes er tom
     }until($finnes = $null)
}#Ender funksjon

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
}#Ender funksjon

Function checkPassword($pass){
#Funksjon som sørger for at passordene er godkjente
    #Setter minimumslengde på 9 tegn
	$passLength = 9
    #Sjekker om passordet er langt nok
	if ($pass.Length -ge $passLength)
		{
        # Lager en teller som skal sikre at passordet går gjennom alle testene
		$isGood = 0
            # Sjekker at den inneholder noe annet enn små bokstaver, store bokstaver og tall. 
		If ($pass -match '[^a-zA-Z0-9]') 
			{
            # Øker teller dersom den inneholder spesialtegn
			$isGood++ }
        #Sjekker at passordet inneholder tall
		If ($pass -match "[0-9]")
			{
            #Øker teller
			$isGood++ }
        #Sjekker at passordet inneholder små bokstaver
		If ($pass -cmatch "[a-z]")
			{
            #Øker teller
			$isGood++ }
        #Sjekker at passordet inneholder store bokstaver
		If ($pass -cmatch "[A-Z]")
			{
            #Øker teller
			$isGood++ }
        #Sjekker om telleren er større en 4
		If ($isGood -ge 4)
			{
            #Hvis teller er mer enn 4, har passordet passert alle sjekkene og det returneres $true
            return $true}
		Else
			{
            return $false}}
	Else {return $false
        }
	}#Ender funksjon

function AD-Meny {
#Starter en "do-løkke" som lar oss holde på i menyen så lenge vi ønsker
do {
#fjerner alt på skjermen slik at kun menyen vises hver gang vi åpner/går tilbake til hovedmenyen
      cls
#write-host som gir brukeren oversikt over meny og dens valg
      Write-Host "=============== Active Directory hovedscript ==============
1: Legge til / Slette brukere
2: Endre brukere
3: Administrasjon av OU
4: Administrasjon av grupper
5: Filbehandling

Q: Trykk 'Q' to quit.
==========================================================="
#Lager variabel som swtich skal bruke
      $input = Read-Host "Velg tall eller trykk Q for å avslutte"
#switch som åpner undermeny basert på valg. Hvert valg åpner en ny funksjon      
      switch ($input)
      {
            '1' {cls
                 Bruker-Meny} 
            '2' {cls
                 Endre-Meny}
            '3' {cls
                 OU-Meny}
            '4' {cls
                 Gruppe-Meny}
            '5' {cls
                 Div-Meny}      
      }#Ender switch
#Ender "do-løkken" ved å skrive q
}until($input -eq "q")
}#Ender funksjon

Function Bruker-Meny {
#Starter en "do-løkke" som lar oss holde på i menyen så lenge vi ønsker
do{
#fjerner alt på skjermen slik at kun menyen vises hver gang vi åpner/går tilbake til hovedmenyen
 cls
#write-host som gir brukeren oversikt over meny og dens valg
      Write-Host "================ Legge til / Slette brukere ===============     
1: Legg til ny bruker
2: Importer brukere fra valgt csv-fil
3: Slette bruker
     
Q: Trykk 'Q' to quit.
==========================================================="
#Lager variabel som swtich skal bruke
      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"
#switch som åpner undermeny basert på valg. Hvert valg åpner en ny funksjon
      switch ($ADValg)
      {
            '1' {cls
                 new-ADUser} 
            '2' {cls
                 New-ADBrukerCSV}
            '3' {cls
                 Set-RemoveADUser}   
      }#Ender switch
#Ender "do-løkken" ved å skrive q
}until($ADValg -eq "q")
}#Ender funksjon

Function Endre-Meny {
#Starter en "do-løkke" som lar oss holde på i menyen så lenge vi ønsker
do{
#fjerner alt på skjermen slik at kun menyen vises hver gang vi åpner/går tilbake til hovedmenyen
 cls
#write-host som gir brukeren oversikt over meny og dens valg
      Write-Host "====================== Endre bruker =======================  
1: Endring av brukere
2: Aktiver / deaktiver brukere
3: List ut deaktiverte brukere
4: Export brukere til csv-fil
5: Søk i brukere
6: Beskytt brukere fra sletting
     
Q: Trykk 'Q' to quit.
==========================================================="
#Lager variabel som swtich skal bruke
      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"
#switch som åpner undermeny basert på valg. Hvert valg åpner en ny funksjon
      switch ($ADValg)
      {
            '1'{cls
                 Set-Endrebruker}
            '2'{cls
                Set-Aktiverbruker}
            '3'{cls
                Get-Deaktivertbruker}
            '4'{cls
                 Export-Brukere}
            '5'{cls
                 Finn-ADbruker
                 pause}
            '6'{cls
                Set-AdobjectProtect
                pause}        
      }#Ender switch
#Ender "do-løkken" ved å skrive q
}until($ADValg -eq "q")
}#Ender funksjon

Function OU-Meny {
#Starter en "do-løkke" som lar oss holde på i menyen så lenge vi ønsker
do{
#fjerner alt på skjermen slik at kun menyen vises hver gang vi åpner/går tilbake til hovedmenyen
 cls
#write-host som gir brukeren oversikt over meny og dens valg
      Write-Host "==================== OU-Administrasjon ====================    
1: Aktivere / Deaktivere OU
2: Linking av GPO    
     
Q: Trykk 'Q' to quit.
==========================================================="
#Lager variabel som swtich skal bruke
      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"
#switch som åpner undermeny basert på valg. Hvert valg åpner en ny funksjon
      switch ($ADValg)
      {
            '1' {cls
                Set-AktiverOU} 
            '2' {cls
                 GPO-link} 
      }#Ender switch
#Ender "do-løkken" ved å skrive q
}until($ADValg -eq "q")
}#Ender funksjon

Function Gruppe-Meny{
#Starter en "do-løkke" som lar oss holde på i menyen så lenge vi ønsker
do{
#fjerner alt på skjermen slik at kun menyen vises hver gang vi åpner/går tilbake til hovedmenyen
cls
#write-host som gir brukeren oversikt over meny og dens valg
      Write-Host "=================== GruppeAdministrasjon ==================    
1: Lage ny gruppe
2: Slette Gruppe
3: Legg til brukere i gruppe
4: Legg til brukere til gruppe fra CSV
5: List ut medlemmer av gruppe
6: Deaktiver / Aktiver brukere i gruppe

Q: Trykk 'Q' to quit.
==========================================================="
#Lager variabel som swtich skal bruke    
      $input = Read-Host "Velg tall eller trykk Q for å avslutte"
#switch som åpner undermeny basert på valg. Hvert valg åpner en ny funksjon
      switch ($input)
      {
            '1' {cls
                 New-ADGruppe
                 } 
            '2' {cls
                 Remove-ADGruppe
                 }
            '3' {cls
                 Set-UserADGruppe
                 }
            '4' {cls
                 Set-UserADGruppeCSV
                 }
            '5' {cls
                 Get-UsersADGruppe
                 }
            '6' {cls
                 Set-GroupDAU
                 }             
            }#Ender switch
#Ender "do-løkken" ved å skrive q
}until($input -eq "q")    
}#Ender funksjon

Function Div-Meny {
#Starter en "do-løkke" som lar oss holde på i menyen så lenge vi ønsker
do{
#fjerner alt på skjermen slik at kun menyen vises hver gang vi åpner/går tilbake til hovedmenyen
cls
#write-host som gir brukeren oversikt over meny og dens valg
      Write-Host "======================= Logg / Filer ======================     
1: Søk gjennom loggfiler
2: Finn filer på filstasjon    
     
Q: Trykk 'Q' to quit.
==========================================================="
#Lager variabel som swtich skal bruke    
      $ADValg = Read-Host "Velg tall eller trykk Q for å avslutte"
#switch som åpner undermeny basert på valg. Hvert valg åpner en ny funksjon
      switch ($ADValg)
      {
            '1' {cls
                 Logg-meny} 
            '2' {cls
                 Fil-meny} 
      }#Ender switch
#Ender "do-løkken" ved å skrive q
}until($ADValg -eq "q")
}#Ender funksjon

Function new-ADUser{
    # Oppretter en ny AD bruker ved å skrive inn info selv
    # Lager variabel for fornavn
    $fornavn = read-host "skriv inn brukerens fornavn" 
    # Lager variabel for etternavn
    $etternavn = Read-Host "Skriv inn brukerens etternavn"
    # Sjekker lengden på navnene
    do
    {
        $err = $false
        # Gir feilmelding dersom lengden på navnet er på mindre enn 2 bokstaver
        if($fornavn.Length -lt 2)
        {$fornavn = read-host `        -prompt 'fornavnet må minst være på to bokstaver'        $err = $true        }        if ($etternavn.Length -lt 2)        {        $etternavn = Read-Host `        -Prompt 'Etternavnet må være på minst to bokstaver'        $err = $true        }    }while($err -eq $true)    # Opprett fullt navn ut fra fornavn og etternavn    $Fulltnavn = "$fornavn $etternavn"       # Henter set-brukernavnfunksjonen for å gi brukeren et unikt brukernavn    $Brukernavn = Set-Brukernavn $fornavn $etternavn    #ta bort mellomrom ol.    $brukernavn = $Brukernavn.trim()        #Spesifiserer OU    $OUvalg = $false    Write-Host "Vennligst velg ønsket OU:         1. Drift         2. Ledelse         3. Produksjon         4. Salg"    # Lager variabel for å velge OU    $OU = Read-Host    # Dersom variabelen er 1-4 blir OU satt    if ($OU -eq "1") {$OU = "OU=drift,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OU -eq "2") {$OU = "OU=ledelse,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OU -eq "3") {$OU = "OU=produksjon,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    if ($OU -eq "4") {$OU = "OU=salg,OU=Mollenberg IT,DC=mollenberg,DC=local"; $OUvalg = $true}    # Dersom variablene ikke er 1-4 blir brukeren sendt til toppen    if ($OUvalg -eq $false) {Write-Host "Ingen valg ble registrert, brukeren ble plassert i toppen av domenet" ; $OU = "OU=Mollenberg IT,DC=mollenberg,DC=local"}    # Lager en variabel som inneholder navn og brukernavn for å lettere kunne skille mellom alle brukerne    $fbnavn = "$fornavn $brukernavn $etternavn"    # Lager E-postvariabel ved å legge på en streng til brukernavnet.    $epost = $brukernavn + "@mollenberg.no"    # les inn og konverter passordet til sikker tekst    do {    $passord = Read-host "Skriv inn brukerens passord" -AsSecureString    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passord)    $plainpassord = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)    #Sjekker at passordet er sikkert nok    if(checkpassword($plainpassord) -eq $true)    {}    else{Write-host "Passord må inneholde: 9 Tegn, A-Z, a-z, 0-9 og et spesialtegn. Prøv igjen!"}    }until(checkpassword($plainpassord) -eq $true)    #Oppretter en scriptblock for å sende kommandoer i en sesjon    Invoke-Command -Session $SesjonADServer -ScriptBlock {        # Lager en variabel som inneholder dato        $dato = (get-date).tostring()        # Forsøker å opprette brukeren        try        {        New-ADUser `        -SamAccountName $using:brukernavn `        -Name $using:fbnavn `        -Surname $using:etternavn `        -Path $using:OU `        -AccountPassword $using:passord `        -ChangePasswordAtLogon $true `        -EmailAddress $using:epost `        -Enabled $true `        -givenname $using:fornavn `
        -userprincipalname $using:brukernavn `        # Bruker variablene til å opprette en streng i loggfil.        $dato + " " + "Brukeren " + $using:fornavn + " " + $using:etternavn + " ble opprettet med brukernavnet: " + $using:Brukernavn + " Plassering: " + $using:ou | 
        out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBruker.txt
		# Forteller oss om brukeren blir opprettet         write-host "Brukeren $using:brukernavn er opprettet med epost $using:epost" -foregroundcolor green        #Pauser her så man kan se at brukeren er opprettet før vi går tilbake til menyen hvor alt på skjermen blir fjernet        Pause        }catch{        #oppretter en variabel dersom vi ikke klarer å lage brukeren        $feilmelding = $dato + " Feil ved oppretting av brukeren " +$using:fbnavn + " Feilmelding :" + $_.exception.message        #Sender ut innholdet i variabelen med rød tekst        write-host $feilmelding -foregroundcolor red        #Pause så vi kan lese        Pause        #Legger feilmeldingen i en loggfil        $feilmelding | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADbruker-feil.txt        }#Ender catch            }#Ender scriptblock}#Ender funksjon

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
		
	 # Importer brukere fra CSV og legger de i en variabel
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
      
      
		
	  # Henter set-brukernavnfunksjonen for å opprette et unikt brukernavn for brukeren
	  $brukernavn = Set-Brukernavn $fornavn $etternavn 
	  # Ta bort mellomrom ol. 
	  $brukernavn = $brukernavn.Trim() 
	  # Opprett fullt navn ut fra fornavn og etternavn 
	  $fulltNavn = "$fornavn $etternavn"
      $fbnavn = "$fornavn $brukernavn $etternavn" 
      # Oppretter epost 
	  $epost = $brukernavn + "@mollenberg.no"
		
	  # #Oppretter en scriptblock for å sende kommandoer i en sesjon
	  Invoke-Command -Session $SesjonADServer -ScriptBlock {
      #Lager variabel med dato
      $dato = (get-date).tostring()
      #Forsøker å opprette brukeren
	   Try 
        {
		   New-ADUser `        -SamAccountName $using:brukernavn `        -Name $using:fbnavn `        -Surname $using:etternavn `        -Path $using:OU `        -AccountPassword $using:passord `        -ChangePasswordAtLogon $true `        -EmailAddress $using:epost `        -Enabled $true `
        -givenname $using:fornavn `
        -userprincipalname $using:brukernavn `
		 #Sender melding om hva som er skjedd til loggfil  
         $dato + " " + "Brukeren " + $using:fornavn + " " + $using:etternavn + " ble opprettet med brukernavnet: " + $using:Brukernavn + " Plassering: " + $using:ou | 
         out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBrukerCSV.txt
         #Gir oss beskjed i vinduet om hva som er gjort
		 write-host "Brukeren $using:brukernavn er opprettet med epost $using:epost" -foregroundcolor green                }catch{        #Lager variabel med feilmelding og sender den til skjerm og loggfil        $feilmelding = $dato + " Feil ved oppretting av brukeren " +$using:fbnavn + " Feilmelding :" + $_.exception.message        write-host $feilmelding -foregroundcolor red        $feilmelding | out-file -append \\55e-win2k16-1\Powershell-logs\New-ADBrukerCSV-feil.txt        }            }     }pause
}#Ender funksjon

function Set-RemoveADUser{
# Funksjon for å slette brukere
# Lager variabel med brukere ved å hente fra funksjonen "get-brukere"
$brukere = Get-brukere
# Lager variabel med dato
$dato = (get-date).tostring()
# Går gjennom alle brukerne i $brukere-variabelen 
ForEach($person in $brukere)
    {Invoke-Command -Session $SesjonADServer -ScriptBlock{
     # Gjør objektet slettbart
     set-adobject -identity "$using:person" -protectedfromaccidentaldeletion:$false
     # Sletter hver bruker i variabelen
     Remove-ADuser -confirm -identity "$using:person"}
     # Lager variabel om hva som er skjedd, skriver ut denne til vindu og loggfil
     $ut = "$($dato) : Brukeren $($person) ble slettet."     write-host $ut -for Red     $ut | out-file -append \\55e-WIN2k16-1\PowerShell-logs\Slettebruker.txt
    }
    Pause
}#Ender funksjon

function Set-Endrebruker {
# Funksjon for å endre på brukere
# Lager variabel med brukerne ved å hente fra funksjonen "get-brukere"
$brukere = Get-brukere

do{
# Lager en variabel som inneholder alle properties som kan endres på
$properties = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-aduser -ldapfilter '(name=amanda)' -properties * | Get-Member -MemberType Properties | where Definition -Match 'Set' }
$velgprop = Read-Host "Velg Property du vil endre, eller skriv 'hjelp' for å liste ut properties"

# Lister ut alle properties man kan endre på dersom man skriver hjelp
if($velgprop -eq 'hjelp'){
write-host ($properties | out-string)
}
# Avslutter "do-løkken ved å skrive navnet på en property som eksisterer i variabelen
}until($velgprop -in $properties.name)
$setprop = read-host "Skriv ny attributt på valgt Property"
# Lager en hastable som inneholder hvilken property, og nye verdien for den valgte property
$hash = New-Object Hashtable
$hash.add($velgprop,$setprop)
# Går gjennom alle brukere som er valgt ut 
foreach ($person in $brukere)
    # Sjekker om man har valgt en gyldig property å endre på
    {if($velgprop -in $properties.name)
    # Bruker hastable for å erstatte alle de valgte properties
    {Invoke-Command -Session $SesjonADServer -ScriptBlock {set-aduser "$using:person" -replace $using:hash}
    # Forteller oss hva som er skjedd
    Write-host "$($velgprop) ble satt til $($setprop) på bruker: $($person)" 
    }else{$velgprop + " ble ikke gjenkjent som en property"}
}
Pause
}#Ender funksjon

function Set-Aktiverbruker {
# Funksjon for å aktivere eller deaktivere brukere
# Bruker get-brukerefunksjonen for å lage en variabel med flere brukere 
$bruker = Get-brukere
# lar oss velge hva vi ønsker å gjøre med valgte brukere
$valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
    switch($valg2){
        # Dersom vi velger 1 blir alle brukerne aktiverte. Velger vi 2 blir alle deaktiverte
        '1'{foreach($item in $bruker)
            {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser "$using:item" | Enable-ADAccount }
            Write-host "$($item) ble Aktivert" -fore green
            }Pause}
        '2'{foreach($item in $bruker)
            {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser "$using:item" | Disable-ADAccount}
            Write-host "$($item) ble Deaktivert" -fore red
            }Pause}
}
}#Ender funksjon

Function Get-Deaktivertbruker {
#Funksjon for å liste ut alle deaktiverte brukere i domenet
Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter {enabled -eq $false} | 
FT name,enabled,samaccountname,distinguishedname} 
pause
}#Ender funksjon

function Export-Brukere{
#Funksjon for å legge brukere i en csv-fil
# Setter variabel med sti til csv-filen
$Utfil = "C:\Users\Administrator.MOLLENBERG\Desktop\Script\ad\brukerecsv.csv"
      Write-Host "=============== Legge brukere i CSV-fil ==============
1: List ut CSV-fil
2: Legg brukere til CSV-fil

Q: Trykk 'Q' to quit.
==========================================================="
      
      $input = Read-Host "Please make a selection: 1 2 eller q for avslutt"
      switch ($input){
            # Dersom vi velger 1 vil du liste ut alle brukere som befinner seg i csv-filen med Out-gridview. Velger man 2 går vi videre for å legge brukere til i filen
            '1'{Import-Csv $Utfil | ogv}
            '2'{write-host "Velg ut de OU-ene, gruppene og brukerne du ønsker å legge i CSV-fila"
# Lager variabler hvor vi kan enten velge brukere, OU-er eller grupper å hente brukere fra
$OUer = Get-OUer
$grupper = Get-grupper   
$brukere = Get-brukere
#Sjekker om vi har valgt noen OU-er
if($ouer){
# Dersom vi har valgt noen OU-er går vi gjennom alle disse
foreach ($ou in $OUer){
    # Lager variabel med alle brukere som befinner seg i den OU-en
    $personer = $ou | % {invoke-command -session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase "$using:ou"}}
    # Går gjennom alle personene i variabelen
    foreach($person in $personer){
        # Sjekker om personen befinner seg i filen fra før. Hvis ikke blir brukeren lagt til i filen
        if(get-content $utfil | select-string -pattern $person){}
        else{$person | select -Property name, enabled, distinguishedname, samaccountname | export-csv -Append $Utfil}
    }}}
# Sjekker om vi har valgt noen grupper
if($grupper){
# Dersom vi har valgt grupper går vi gjennom alle disse
foreach($gruppe in $grupper){
     # Lager variabel med alle brukerne i hver gruppe
     $personer = $gruppe | % {invoke-command -Session $SesjonADServer -ScriptBlock{get-adgroupmember "$using:gruppe"}}
     # Går gjennom alle brukere i variabelen
     foreach($person in $personer){
        # Sjekker om personen befinner seg i filen fra før. Hvis ikke blir brukeren lagt til i filen
        if(get-content $utfil | select-string -pattern $person){}
        else{$person | select -Property name, enabled, distinguishedname, samaccountname | export-csv -Append $Utfil}
        }}}
# Sjekker om vi har valgt noen brukere
if($brukere){
# Dersom vi har valgt brukere går vi gjennom alle disse
foreach($bruker in $brukere){
    # Sjekker om brukeren er i filen fra før. Hvis ikke blir brukeren lagt til i filen
    if(get-content $utfil | select-string -pattern $bruker){}
    else{$bruker | select -property name, enabled, distinguishedname, samaccountname | Export-Csv -Append $Utfil}
    }}
}#Ender valg 2
}#Ender switch
Pause
}#Ender funksjon

Function Get-ADbruker{
# Funksjon for å søke i brukere
Do{
# Lager variabel vi skal søke med
$navn = read-host "Skriv hele eller deler av nanvet for å søke etter en bruker. Trykk 'q' for å gå tilbake"
# Dersom variabelen $navn ikke er tom legger vi alle brukere som har et navn som inneholder variabelen $navn i en ny variabel
if($navn -ne [string]::Empty){
 $brukere = Invoke-Command -Session $SesjonADServer -ScriptBlock {get-aduser -filter "name -like '*$using:navn*'" -properties name, enabled, distinguishedname, samaccountname | format-table name, enabled, distinguishedname, samaccountname | out-string}  
}
# Lister ut alle brukere som befinner seg i variabelen $brukere
if($brukere){    
    write-host $brukere} 
 else{
    # Avslutter funksjon ved å skrive q
    if($navn -eq 'q'){}else{
    # Gir oss beskjed dersom vi ikke finner noen brukere ved hjelp av søkeordet
    write-host 'Fant ingen brukere med brukernavnet ' -foregroundcolor yellow -NoNewline
    write-host $navn -ForegroundColor red -NoNewline
    write-host '. Vennligst prøv igjen med et annet brukernavn' -ForegroundColor yellow}
    }}until($navn -eq "q")  
}#Ender funksjon

function Set-AdobjectProtect {
Invoke-Command -Session $sesjonADserver -ScriptBlock {
# Funksjon som beskytter brukere fra å bli slettet ved en feil

# Finner alle AD-objekter som har propertien "protectedFromAccidentalDeletion og er av "Objectclass" user
Get-ADObject -filter * -Properties ProtectedFromAccidentalDeletion | 
Where-Object {$_.ObjectClass -eq "user"} |

# Setter "true" på propertien. 
Set-ADObject -ProtectedFromAccidentalDeletion $true -verbose
}
}#Ender script

Function Set-AktiverOU{
#Funksjon for å aktivere / deaktivere Brukerne i en OU
# Get-OUerfunksjonen henter brukere som blir lagt i variabelen $ou
$ou = Get-OUer
# Gir oss valg
$valg2 = Read-Host "1: Aktiver, 2: Deaktiver"
    switch($valg2){
        # Går gjennom alle valgte OU-er og aktiverer eller deaktiverer brukerne i disse basert på valget
        '1'{foreach($item in $ou)
            {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase $using:item | Enable-ADAccount}
            Write-host "$($item) ble Aktivert" -fore green}
            pause}
        '2'{foreach($item in $ou)
            {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-aduser -filter * -searchbase $using:item | Disable-ADAccount}
            Write-host "$($item) ble Deaktivert" -fore red}
            pause}
}
}#Ender funksjon

function GPO-link{
# Funksjon for å linke GPO og OU-er
# Oppretter scriptblock
Invoke-Command -Session $SesjonADServer -ScriptBlock {
   
    do{
    # Forteller oss hvilke valg vi har
    write-host "Du har valgt linking av Group Policy Object til en OU. Du vil nå få noen valg:" -ForegroundColor Yellow

    write-host "1. Link GPO til OU" -ForegroundColor Cyan
    Write-Host "2. List ut eksisterende GPO-er" -ForegroundColor Cyan
    Write-Host "3. List ut alle GPO-er som er linket til en bestemt OU" -ForegroundColor Cyan
    Write-Host "4. List ut alle OU-er som er linktet til en bestemt GPO" -ForegroundColor Cyan
    write-host "Q. Avslutt" -ForegroundColor Cyan
    $valg = Read-Host
        if($valg -eq "1")
        # Dersom vi velger 1 vil vi linke GPO Med OU
            {
            do{
            # Velger gpo og lager variabel
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
            
            # Velger OU og lager variabel med OU
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
                # Linker valgt GPO med valgt OU
                new-gplink -name $gponavn -target $OU -ErrorAction SilentlyContinue
                Write-Host "OU-en " -NoNewline
                Write-Host $OU -ForegroundColor Green -NoNewline
                write-host " ble linket med GPO-en " -NoNewline
                Write-Host $gponavn -ForegroundColor Green
                $dato = (get-date).tostring()
                # Legger hendelsen i loggfil 
                $loggfil = $dato + " GPO " + $gponavn + " linket med: " + $OU | out-file -append \\55e-win2k16-1\Powershell-logs\GPO-link.txt
                }else {return}
      
            }
        if($valg -eq "2")
        # Lister ut alle GPO-er med navn
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
           # Lar oss velge ou
           $OUnavn = Read-Host
           # Lister ut alle GPO-er den valgte OU-en er linket med
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
            # Lister ut alle OU-er en GPO er linket med 
            {
                do{
            Write-Host "Skriv inn navnet på GPO-en du vil sjekke eller skriv Q for å gå tilbake" -ForegroundColor Yellow
            # Lager variabel med navnet på en valgt GPO
            $gpotest = Read-Host
            $gponavn = get-gpo -name $gpotest -erroraction silentlycontinue
                if($gponavn){
                # Lager en variabel som inneholder id på en valgt GPO
                $gpoid = "*" + $gponavn.id + "*"
                # Lager variabel som inneholder alle OU-er som er linket med denne
                $path = get-adobject -filter {gplink -like $gpoid} 
                write-host $path}
                }until(($gponavn) -or $gpotest -eq 'q')
            }
    }until($valg -eq "q")

}
}#Ender funksjon

function New-ADGruppe {
# FUnksjon for å opprette nye grupper
do{
# Lar oss lage flere grupper ved å skrive flere navn skilt med komma.
$gruppenavn = (read-host "Skriv navnet på gruppen du ønsker å lage, skill med komma for flere grupper").Split(',') | %{$_.Trim()}
}until($gruppenavn -ne '')

# Går gjennom alle gruppenavnene vi har valgt
foreach($gruppe in $gruppenavn){
# Sjekker om vi har skrevet navn
if($gruppe -ne ''){
# Oppretter gruppen i vårt domene
try {Invoke-Command -Session $sesjonADserver -ScriptBlock {
    new-adgroup -name $using:gruppe -groupscope global -path "OU=mollenberg IT,DC=mollenberg,DC=local"} -erroraction Stop
    Write-host "Gruppa $($gruppe) ble laget" -fore green}

    catch{
    Write-host "Gruppa $($gruppe) eksisterer allerede" -fore red } 
    }else{
    # Får beskjed dersom vi ikke har skrevet noen navn for grupper
    Write-host "Kan ikke lage tom gruppe" -fore red}
}
Pause
}#Ender funksjon

function Remove-ADGruppe {
#Funksjon for å slette grupper
do{
# Bruker get-grupperfunksjonen for å lage variabel med flere grupper
$gruppenavn = get-grupper
}until($gruppenavn -ne '')

#Går gjennom alle de valgte gruppene
foreach($gruppe in $gruppenavn){
# Sjekker om vi har skrevet noen gruppenavn
if($gruppe -ne ''){
#Sletter alle grupper som er valgt
try {Invoke-Command -Session $sesjonADserver -ScriptBlock {
    #remove-adgroup "$using:gruppe" -groupscope global -path "OU=mollenberg IT,DC=mollenberg,DC=local"} -erroraction Stop
    Get-adgroup "$using:gruppe" | remove-adgroup}
    Write-host "Gruppa $($gruppe) ble slettet" -fore green}
    
    catch{
    Write-host "Gruppa $($gruppe) eksisterer ikke" -fore red } 
    }else{
    # Dersom vi ikke har skrevet noe navn får vi beskjed
    Write-host "Kan ikke slette tom gruppe" -fore red}
}
Pause
}#Ender funksjon

Function Set-UserADGruppe {
# Funksjon for å legge brukere til i en gruppe
# Bruker get-grupperfunksjonen for å lage variabel med flere grupper
$Grupper = Get-grupper
# Lager variabel med brukere
$medlemmer = Get-brukere
    # Går gjennom alle grupper
    foreach($gruppe in $Grupper){
        # Går gjennom alle brukere
        foreach($medlem in $medlemmer){
    # Legger de valgte brukerne til de valgte gruppene
    Invoke-Command -Session $sesjonADserver -ScriptBlock {add-adgroupmember "$using:gruppe" -members "$using:medlem"}
    write-host "$($medlem) ble lagt til i gruppen $($gruppe)" -for green
   }} pause
}#Ender funksjon

Function Set-UserADGruppeCSV {
# Funksjon for å legge brukere til i gruppe fra en CSV-fil
# Get-grupperfunksjonen brukes til å lage variabel med flere grupper
$Grupper = Get-grupper
# Går gjennom alle gruppene
foreach($gruppe in $grupper){
# Lager variabel med alle brukere som befinner seg i filen
$brukere = Import-Csv \\55e-win2k16-2\c$\Users\Administrator.MOLLENBERG\Desktop\Script\ad\brukerecsv.csv
# Går gjennom alle brukere  
foreach($bruker in $brukere){
#Legger alle brukerne fra csv-filen i alle de valgte gruppene
$BrukerSam = $bruker.samaccountname
Invoke-Command -Session $sesjonADserver -ScriptBlock {add-adgroupmember "$using:gruppe" -members "$using:Brukersam"}
write-host "$($brukersam) ble lagt til i gruppen $($gruppe)" -for green}
}
pause
}#Ender funksjon

Function Get-UsersADGruppe {
#Funksjon for å vise alle medlemmer av en gruppe
# Lager variabel med flere grupper
$grupper = Get-grupper

# Går gjennom alle gruppene
foreach($gruppe in $grupper){
# Forteller hvilken gruppes brukere som kommer ut
Write-host ""
write-host "Medlemmer av gruppen $($gruppe): " -for Green
# Lister ut brukerne til den valgte gruppen
Invoke-Command -Session $sesjonADserver -ScriptBlock {get-adgroupmember "$using:gruppe" | ft name,samaccountname}
}
pause
}#Ender funksjon

Function Set-GroupDAU {
# Funksjon for å aktivere/deaktivere brukerne i en gruppe
# Lager variabel med flere grupper
$gruppe = Get-grupper
$valg = Read-Host "1: Aktiver, 2: Deaktiver"

switch($valg){
    # Går gjennom alle gruppene som er valgt
    # Aktiverer eller deaktiverer medlemmene i alle gruppene basert på valget
    '1'{foreach($item in $gruppe)
        {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-adgroupmember "$using:item" | Enable-ADAccount}
        foreach ($i in $item.members){Write-host "Brukeren $($i) ble aktivert" -fore green}}
        }
    '2'{foreach($item in $gruppe)
        {Invoke-Command -Session $SesjonADServer -ScriptBlock{get-adgroupmember "$using:item" | Disable-ADAccount}
        foreach ($i in $item.members){Write-host "Brukeren $($i) ble deaktivert" -fore red}}
 }}
Pause
}#Ender funksjon

Function Logg-meny{
# Meny som kaller på flere funksjoner for å søke gjennom filer
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
        1 {Get-Ord} 
        2 {Get-Linjer}
        3 {Get-Logg}
        4 {Get-Innhold}
        x {return} 
        default {"Valget ble ikke gjenkjent"}
    }
}until($Valg -eq "x")
}#Ender funksjon

Function Get-Ord{
#Funksjon for å søke etter bestemte ord i filer på flere maskiner
$Sok = Read-Host "Skriv ordet du vil søke etter"
#Viser navnet på alle filene som inneholder søkeordet
Get-ChildItem -path "\\55e-win2k16-1\Powershell-logs\" -recurse | Select-String -pattern $Sok | group path | FT name
Get-ChildItem -path "\\55e-win2k16-3\HyperVlogs\" -recurse | Select-String -pattern $Sok | group path | FT name
}#Ender funksjon

Function Get-Logg{
#Funksjon som lister ut alle filene som ligger i logg-mappene
Get-ChildItem -path \\55e-win2k16-1\Powershell-logs\* | FT name,fullname
Get-ChildItem -path \\55e-win2k16-3\HyperVlogs\* | FT name,fullname
}#Ender funksjon

function Get-Linjer{
#Funksjon som lister ut alle linjene som inneholder søkeordet
$sok = Read-Host "Skriv inn ett ord og list ut alle linjer som inneholder ordet"
#Lister linjenummeret, selve linjen som inneholder ordet, og i hvilken fil linjen befinner seg
Select-String \\55e-win2k16-1\Powershell-logs\* -pattern $sok | FT linenumber,line,filename,Path
Select-String \\55e-win2k16-3\HyperVlogs\* -pattern $sok | FT linenumber,line,filename,Path
}#Ender funksjon

function Get-Innhold{
#Funksjon som lister ut hele innholdet til en valgt loggfil
$ErrorActionPreference= 'silentlycontinue'
$Innhold = Read-Host "Skriv navnet på loggen du vil se innholdet til"
# Lar oss velge navnet på filen vi ønsker å se innholdet til
Get-Content \\55e-win2k16-1\Powershell-logs\$Innhold 
Get-Content \\55e-win2k16-3\HyperVlogs\$innhold 
}#Ender funksjon

function Fil-meny{
# Funksjon som leter gjennom filtjeneren for diverse typer filer og legger de i en csv-fil
Write-host "1: Legg alle ulovlige filer i csv-filen
2: Vis innholdet av Funnet-filer.csv
3: Slett filene som ligger i Funnet-filer.csv"
$finn = Read-Host
switch($finn)
    { '1' {cls
           Export-filer
          }
      '2' {cls
           Get-filer
          }
      '3' {cls
           Remove-filer
          }  
    }
}#Ender funksjon

Function Export-filer{
# Navnet på filene blir lagt i csv-filen
$outputfil = "C:\Users\Administrator.MOLLENBERG\Desktop\Script\ad\funnet-filer.csv"

$funnet = Invoke-Command -Session $SesjonVMServer -scriptblock{
            # Henter alle filer på maskinen som er av en bestemt type og legger de i en variabel
            Get-ChildItem \\55e-win2k16-3\c$\Users\administrator.MOLLENBERG\Desktop -include *.mp3,*.wma,*.wmv,*.aac,*.avi,*.mp4,*.3gp,*.mkv -Recurse | 
            Where-Object { ($_.PSIsContainer -eq $false)}
          }
            # Legger alle filene i variabelen til i CSV-filen
            $funnet | Select-Object Name,Directory,Length | Export-Csv $outputfil

}#Ender funksjon

Function Get-filer {
# Fuksjon for å vise alle filene i funnet-filer.csv
$inputfil = Import-Csv "C:\Users\Administrator.MOLLENBERG\Desktop\Script\ad\funnet-filer.csv"
$inputfil | ogv
pause
}#Ender funksjon

Function Remove-filer {
# Funksjon for å slette alle filer i funnet-filer.csv

# Importerer filen for å bruke den senere
$inputfil = Import-Csv "C:\Users\Administrator.MOLLENBERG\Desktop\Script\ad\funnet-filer.csv"

# Går gjennom alle filene i CSV-filen
            foreach($fil in $inputfil){
            # Lager en fil-path som kan brukes i kommandoer
            $filpath = join-path $fil.directory $fil.name
            # Fjerner alle filene som ligger i CSV-filen
            Invoke-Command -Session $SesjonVMServer -scriptblock{remove-item -verbose "$using:filpath"}
          }pause
}#Ender funksjon


