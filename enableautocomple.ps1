# Set PR to auto-complete
$setAutoComplete = @{
    "autoCompleteSetBy" = @{
        "id" = $pullRequestResult.createdBy.id
    }
    "completionOptions" = @{       
        "deleteSourceBranch" = $False
        "bypassPolicy" = $False
    }
}

$setAutoCompleteJson = ($setAutoComplete | ConvertTo-Json -Depth 5)

Write-Output "Sending a REST call to set auto-complete on the newly created pull request"

# REST call to set auto-complete on Pull Request
$pullRequestUpdateUrl = ($projectUrl + '/pullRequests/' + $pullRequestId + '?api-version=5.1')

$setAutoCompleteResult = Invoke-RestMethod -Method PATCH -Headers $headers -Body $setAutoCompleteJson -Uri $pullRequestUpdateUrl

Write-Output "Pull request set to auto-complete"
