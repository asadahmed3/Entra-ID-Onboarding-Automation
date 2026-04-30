# 1. Connection Details
$myTenantId = "Input Tenant ID Here"
$domain = "Place Domain Email Here"
$itGroupId = "Paste Group ID Here" 

# 2. Data Ingestion
$usersToCreate = Import-Csv "./new_hires.csv"

Write-Host "--- Starting Zero-Touch Onboarding (Fixed Version) ---" -ForegroundColor White

foreach ($user in $usersToCreate) {
    $upn = "$($user.FirstName).$($user.LastName)@$domain"
    $userParams = @{
        AccountEnabled = $true
        DisplayName = "$($user.FirstName) $($user.LastName)"
        MailNickname = "$($user.FirstName)$($user.LastName)"
        UserPrincipalName = $upn
        JobTitle = $user.JobTitle
        Department = $user.Department
        UsageLocation = "CA"
        PasswordProfile = @{ ForceChangePasswordNextSignIn = $true; Password = "StartPassword2026!" }
    }

    try {
        Write-Host "`n[PROVISIONING] $upn..." -ForegroundColor Cyan
        $createdUser = New-MgUser @userParams
        if ($createdUser.Id) {
            Write-Host "REAL SUCCESS: User $($createdUser.DisplayName) is now in Entra ID." -ForegroundColor Green
            if ($user.Department -eq "IT") {
                New-MgGroupMember -GroupId $itGroupId -DirectoryObjectId $createdUser.Id
                Write-Host "ACTION: Added to IT Support group." -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "FAILED: Could not create $upn. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host "`n--- Automation Cycle Complete ---" -ForegroundColor White
