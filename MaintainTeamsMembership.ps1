#change the path to the list with users from Bamaflex:

$emailaddresses=Get-Content -Path "C:\Users\genev\OneDrive - Hogeschool West-Vlaanderen\TI\PSTEAMS\inputTI.txt"
$TeamCCCPGroupId="3764bba9-b7ca-4941-a5a8-c4ec94d2e8ee"
$TeamBDAGroupId="7a933410-0dfa-4fab-824a-194d70ba5fb0"
$TeamPGAIGroupId="e3dc83f8-69e2-484b-ab94-d630dc752747"
$TeamTIStudents="4e29f98e-5c2b-4331-8bd5-815493c83b74"


#change the ID parameter here
$teamId=$TeamTIStudents


# -----------------------------------------
# Run this first
# -----------------------------------------

#Set-ExecutionPolicy RemoteSigned


# -----------------------------------------

#not working with MFA accounts
#$crendentials=Get-Credential

Connect-MicrosoftTeams #-Credential $crendentials
Connect-AzureAD #-Credential $crendentials

$team=Get-Team -GroupId $teamId

$groupMembers=(Get-AzureADGroupMember -ObjectId $teamId -All $true | select UserPrincipalName)

#Write-Host $groupMembers

#check if the users are still enrolled in HOWEST programm
Write-Host "Check current users" -ForegroundColor White
for($i=0; $i -lt $groupMembers.length; $i++){
    write-host $groupMembers[$i]

    #check if user is in valid user list
    #if NO, then delete the user from TEAMS
    #skip Howest staff members
    if(!$groupMembers[$i].UserPrincipalName.toLower().EndsWith("@howest.be")){
        if($emailaddresses.tolower().Contains($groupMembers[$i].UserPrincipalName.toLower())){
            #Write-Host "user found"
        }
        else{
            Write-Host "user not found: remove from TEAMS" -ForegroundColor Red
            Remove-TeamUser -groupId $teamId -User $groupMembers[$i].UserPrincipalName
        }
    }else{
        Write-Host "SKIPPING STAFF MEMBER" -ForegroundColor Gray
    }
      

}

#add new users
Write-Host "Check user membership" -ForegroundColor White
for($i=0; $i -lt $emailaddresses.length; $i++){
    write-host $emailaddresses[$i]
    $bUserFound=$false
    #check if the user is already in TEAMS
    #if NO, then ADD the user
    for($j=0; $j -lt $groupMembers.length;$j++){
      
        if($groupMembers[$j].UserPrincipalName.toLower() -eq $emailaddresses[$i].ToLower()){
            $bUserFound=$true
            #Write-Host "user found in teams members list" -ForegroundColor Yellow
            break
        }
    }

    if(!$bUserFound){
        Write-Host "adding member to TEAMS" -ForegroundColor Green
        Add-TeamUser -GroupId $teamId -User $emailaddresses[$i]
    }

  

}
