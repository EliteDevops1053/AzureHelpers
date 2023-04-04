
$ErrorActionPreference = 'SilentlyContinue'


Function Connect-Azure {

  Begin {
    Write-Verbose -Message "Connecting to Azure..."
    Connect-AzAccount
    
  }
  Process {
    Try {
        $subs = Get-AzSubscription -SubscriptionId "fcf65c12-e569-4fe5-8433-b4142d1f6219"
        foreach ($sub in $subs){
            Set-AzContext -SubscriptionId $sub.Id
        
        Select-AzSubscription -SubscriptionId $sub.Id
        $SubscriptionName = (Get-AzSubscription -SubscriptionId $sub.Id).Name

        Export-Templates 
        }
    }
    Catch {
        Write-Host -BackgroundColor Red "Error: $($_.Exception)"
    Break
    }
  }
  End {
    If ($?) {
      Write-Host 'Connected to Azure Successfully.'
      Write-Host 'Selected Subscription' $SubscriptionName'.'
    }
  }
}

Function Export-Templates {

    # Export templates for each resource
    Begin{
        Write-Verbose -Message "Exporting Templates..."
    }
    Process {
        Try {
            $ResourceGroups = Get-AzResourceGroup

            foreach ($Resourcegroup in $ResourceGroups) {
                

                $Resources = Get-AzResource -ResourceGroupName $Resourcegroup.ResourceGroupName 
                
                foreach ($Resource in $Resources) {
                    $ResourceTypeFolderName = $Resource.ResourceType -replace ".*/"
                    $FileName = $SubscriptionName + "\" + $Resourcegroup.ResourceGroupName + "\" + $ResourceTypeFolderName + "\WithParams\" + $Resource.Name
                    $FileNameNoParams = $SubscriptionName + "\" + $ResourceGroupName + "\" + $ResourceTypeFolderName + "\NoParams\" + $Resource.Name
                    Export-AzResourceGroup -ResourceGroupName $Resourcegroup.ResourceGroupName -Resource $Resource.ResourceId -Path $FileName -IncludeParameterDefaultValue -Force
                    Export-AzResourceGroup -ResourceGroupName $Resourcegroup.ResourceGroupName -Resource $Resource.ResourceId -Path $FileNameNoParams -SkipAllParameterization -Force
                    Write-Host  "file name is $($FileName)"
                    $BicepFileName = ($FileName + ".json") 
                    $BicepFileNameNoParams = ($FileNameNoParams + ".json")
                    bicep decompile $BicepFileName -Force
                    bicep decompile $BicepFileNameNoParams -Force
                }
            }
        }
        Catch {
            Write-Host -BackgroundColor Red "Error: $($_.Exception)"
        Break
        }
    }
    End {
        If ($?) {
            Write-Host 'Exported Completed'
          }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Connect-Azure 
