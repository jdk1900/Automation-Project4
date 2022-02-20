try {
    $allautomationAccounts = Get-AzAutomationAccount
    $subscription = (Get-AzContext).Subscription
    $subscriptionName = $ubscription.Name
    $subscriptionID = "/subscriptions/" + $subscription.Id
     
 
    # Iterate through all automation accounts
 
    ForEach ($automationaccount in $allautomationAccounts) {
        $automationAccName = $automationaccount.AutomationAccountName
        $automationAccRG = $automationaccount.ResourceGroupName
 
            Write-Output "INFO --- Enabling Managed Identity in the current automation account '$automationAccName'."
            Set-AzAutomationAccount -ResourceGroupName $automationAccRG -Name $automationAccName -AssignSystemIdentity
 
            Write-Output "INFO --- Get the Object(PrincipalId) from the Managed Identity created with the previous command."
            #This is a Unique identifier assigned to this resource.It is registered with Azure Active Directory.
            $automationAccountObjectId = (Get-AzAutomationAccount -Name $automationAccName -ResourceGroupName $automationAccRG).Identity.PrincipalId
 
            Start-Sleep -s 30
 
            # Assign the role to the Managed Identity
            New-AzRoleAssignment -ObjectId $automationAccountObjectId -RoleDefinitionName "Contributor" -Scope $subscriptionID
 
            Write-Output "INFO --- Remove Run As Account from '$automationAccName'."
            $connection = Get-AzAutomationConnection -ResourceGroupName $automationAccRG -AutomationAccountName $automationAccName -Name AzureRunAsConnection
            $appid = $connection.FieldDefinitionValues.ApplicationId
            Remove-AzADApplication -ApplicationId $appid
         
    } 
} catch {
    $exception = $_.Exception.Message
    throw "ERROR --- Failed to enable managed identity for the automation account $automationAccName : $exception" 
}