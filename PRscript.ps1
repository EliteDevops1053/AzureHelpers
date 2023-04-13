param(
$PAT
)
function CreateTopicBranch
{
    #GettingObjectID
    $BranchObjectID = "https://dev.azure.com/<OrgName>/one/_apis/git/repositories/$repoId/refs?filter=heads/$BranchName&api-version=6.0"
    $BranchObjectIDResponse = Invoke-RestMethod -Uri $BranchObjectID -Method get -ContentType Application/json -Headers @{Authorization =("Basic {0}"-f $Auth)}   

    #CreatingNewBranch
    $CreateBranchURI = "https://dev.azure.com/<OrgName>/one/_apis/git/repositories/$repoId/refs?api-version=6.0"
    $RequestBody = ConvertTo-Json @(
    @{
    name = "$TopicBranchNameFormat"
    newObjectId = $BranchObjectIDResponse.value.objectId
    oldObjectId = "0000000000000000000000000000000000000000"
    })
    write-host "Creating Topic Branch....."
    $UriResponse = Invoke-RestMethod -Uri $CreateBranchURI -Method Post -Body $RequestBody -ContentType "Application/json" -Headers @{Authorization =("Basic {0}"-f $Auth)}
    Write-host "Topic Branch created :" $UriResponse.value.name
    return $UriResponse.value.name

}
function UpdatejsonFile($FullBranchName)
{
    $BranchName = $FullBranchName.replace("refs/heads/","")
    $Directory = "$env:System_DefaultWorkingDirectory\Repo"
    mkdir $Directory
    Write-host "Directory created : " $Directory    

    git config --global user.name $env:RELEASE_REQUESTEDFOR
    git config --global user.email $env:RELEASE_REQUESTEDFOREMAIL
   
    #Cloning the Repo
    write-host "Cloning <reponame> Repository......."
    $RepoURL = "https://$($env:PAT1)@<OrgName>.visualstudio.com/DefaultCollection/One/_git/<reponame>"
    git clone $RepoURL $Directory --branch=$BranchName
    Write-host "<reponame> Repo Cloned !!"    
    Set-Location $Directory



    #Savingthefile
   
    git add .
    git commit -m "<commit message>"
    git push -u -q
    Write-host "Pushed the changes"
}
function CreatePR($SourceBranchName,$TargetBranchName)
{
    $PRURI = "https://dev.azure.com/<OrgName>/one/_apis/git/repositories/$repoId/pullrequests?api-version=6.0"
    $RequestBody =
    @{
    sourceRefName = $SourceBranchName
    targetRefName = "refs/heads/$TargetBranchName"
    title = "<Pr Title>"
    description = "<Pr Description>"
    } | ConvertTo-Json
    Write-host "Creating Pull Request...."
    $PRResponse = Invoke-RestMethod -Uri $PRURI -Method Post -Body $RequestBody -ContentType "Application/json" -Headers @{Authorization =("Basic {0}"-f $Auth)}
    Write-host "Pull Request created"
    $PRLink = "https://dev.azure.com/<OrgName>/One/_git/<reponame>/pullrequest/"+$PRResponse.pullRequestId   
    Write-Host "Pull Request ID :"$PRResponse.pullRequestId 
    write-host "Pull Request Link:"$PRLink
}

##<reponame> Repo ID
$repoId = "<repoId>"
#Authentication
$Auth = [convert]::ToBase64String([text.encoding]::ascii.GetBytes(("{0}:{1}" -f "",$PAT)))
#BranchNameFormat
$AliasName = $env:RELEASE_REQUESTEDFOREMAIL.Replace("<@domainName.com>","")
$TopicBranchNameFormat = "refs/heads/users/$AliasName/<branchname format>"+(Get-Date).Day+(Get-Date).Month
$UpdateNeeded = 0

if($UpdateNeeded -gt 0)
{
   $NewBranchName = CreateTopicBranch
   UpdatejsonFile $NewBranchName
   CreatePR $NewBranchName $BranchName
}
