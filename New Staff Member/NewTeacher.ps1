
<# ###################################################################
    Objective: With some basic data, give new teachers O365 and AD accounts

    This script was written by Brandon Willis and Jorge Covarrubias.
    Last updated on 7/16/2016 by Brandon Willis



######################################################################>




#Pre-defined Variables
$password = "temp" | ConvertTo-SecureString -AsPlainText -Force
$peopleToAdd = @() #Purposely left empty as it will become a multi-dimensional array.

#Defining Functions------------------------------------------------------------------------------
Function Get-FileName()
{
    $initialDirectory = Get-Location

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

#End Defining Functions--------------------------------------------------------------------------
#GETTING USER INPUT -----------------------------------------------------------------------------
$usingFile = Read-Host -Prompt 'Are you looping through a CSV file with columns: firstname, lastname, OU (If blank, default is yes)'

#If user wants to use a file
if ($usingFile -eq "" -Or $usingFile.Substring(0,1) -eq "y"){
        $path = Get-FileName
        Write-Host $path

        $PeopleToAddToAD = import-csv $path
        ForEach ($row in $PeopleToAddToAD){

            #$variable = $row.(Column Name)
            $firstName = $row.firstname
            $lastName = $row.lastname
            $OU = $row.OU
            if ($OU -eq ""){
                $OU = DISTRICT
            }

            #Create a row for each person's info
            $tempArray = ,@($firstName, $lastName, $OU)
            Write-Host $tempArray
            #Add row to people to add
            $peopleToAdd += $tempArray
        }

    #Once path is a valid CSV file
}

#If not using a file (Entering in the data)
else{

    #If not using file, get input. Say how many people you are entering
    do {
        $inputString = read-host -Prompt "Number of people you are adding (If left empty will default to 1)"
        if($inputString -eq ""){
            $inputString = "1"
        }
        $numberOfPeople = $inputString -as [Double] #--------------------------------------------This may have to be Double. Don't know yet. Might need to find a way to be integer
        $ok = $numberOfPeople -ne $NULL
        if ( -not $ok ) { write-host "You must enter a numeric value" }
    }
    until ( $ok )

    Write-Host $numberOfPeople

    # Why did "for($i=0; $i -lt $numberOfPeople; $i++)" not work?
    #Get info for X number of people where X = $numberOfPeople
    for($loops=0; $loops -lt $numberOfPeople; $loops++){ #------------------------------------------------This is looping over and over and over do an echo $i test
        Write-Host $loops
        $firstName = Read-Host -Prompt 'First name '
        $lastName = Read-Host -Prompt 'Last name '
        $email = $firstName.subString(0, 1) + $lastName + "@sd104.us"
        $filledOU = "false"

        
        #Make sure the OU exists
        while ($filledOU -ne "true"){
	        $ou = Read-Host -Prompt 'OU (Leaving blank will default to DISTRICT) '
	        if($ou -eq ""){
                $ou = "DISTRICT"
                break;
            }
	        <#
		        Loop through some text file to see if the OU exists (done)
		        If OU exists set $filledOU = true (done)
		        If $filledOU is still false, show error message and continue loop (done)
	        #>

            $CSV = Import-CSV "OUs.csv"
            foreach($line in $CSV){
                if ($line.OU -eq $ou){
				    $filledOU = "true"
                    break;
			    }
	        }
	        if ($filledOU -ne "true"){
		        Write-Host "The OU: '$ou' does not exist." -fore "white" -back "red"
	        }
        }

        #Create a row for each person's info
        $tempArray = ,@($firstName, $lastName, $ou)
        #Add row to people to add
        $peopleToAdd += $tempArray
    }
}
# End of user input ---------------------------------------------------------------------------------




<#
    Each person is now an array inside of $peopleToAdd.
    
    $peopleToAdd[x][0] = First Name
    $peopleToAdd[x][1] = Last Name
    $peopleToAdd[x][2] = OU
#>




<#
	RUN COMMANDS TO ADD TO AD AND CREATE O365 Accounts
#>

#New-ADUser -Name $fname -Surname $lname -AccountPassword 104Tempp -ChangePasswordAtLogon 0 -Description BadWolf -Enabled 1 -SamAccountName BWillis -ScriptPath Stafflgn.bat -PasswordNeverExpires 1 -UserPrincipalName BWillis -WhatIf

#Testing if the array went well
foreach ($person in $peopleToAdd){
    Write-Host $person[0] " Fill-in " $person[1] " is part of " $person[2]
}

pause