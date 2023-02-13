$subscriptionId = "09e9f915-42ff-4571-82a4-0912ed4de2e6"
$resourceGroupName = "testrg"
try{
    Connect-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile .\main.bicep -TemplateParameterFile .\main.parameters.json -Name "test-strg"
}
catch {
   Write-Host 'Deployment failed, please open portal to and check deployment logs for investigation'
}