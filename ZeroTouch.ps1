# 1. Configuration & Global Variables
# These variables define the target environment and ensure users are provisioned to the correct tenant.
$myTenantId = "Input Tenant ID Here"  # The unique ID for your Microsoft Entra tenant.
$domain = "Place Domain Email Here"      # The primary domain (e.g., asad.systems) used for User Principal Names (UPNs).
$itGroupId = "Paste Group ID Here"    # Target ID for the GRP-IT-SUPPORT security group.

# 2. Data Ingestion
# The script imports employee data from a local CSV file, acting as the 'Source of Truth' for onboarding.
$usersToCreate = Import-Csv "./new_hires.csv"

Write-Host "--- Starting Zero-Touch Onboarding (Fixed Version) ---" -ForegroundColor White

# 3. Provisioning Loop
# Iterating through each row in the CSV to handle individual account creation.
foreach ($user in $usersToCreate) {
    
    # Standardizing the UPN format (Firstname.Lastname@domain) for directory consistency.
    $upn = "$($user.FirstName).$($user.LastName)@$domain"
    
    # Defining the user attribute object. 
    # Note: UsageLocation is set to "CA" for Toronto-based compliance and license assignment.
    $userParams = @{
        AccountEnabled = $true
        DisplayName = "$($user.FirstName) $($user.LastName)"
        MailNickname = "$($user.FirstName)$($user.LastName)"
        UserPrincipalName = $upn
        JobTitle = $user.JobTitle
        Department = $user.Department
        UsageLocation = "CA" 
        # Security Best Practice: Enforcing a password reset on first login.
        PasswordProfile = @{ ForceChangePasswordNextSignIn = $true; Password = "StartPassword2026!" }
    }

    # 4. Execution & Error Handling
    # Using a try/catch block to ensure a single failure doesn't halt the entire batch process.
    try {
        Write-Host "`n[PROVISIONING] $upn..." -ForegroundColor Cyan
        
        # Calling the Microsoft Graph SDK to create the user in the cloud.
        $createdUser = New-MgUser @userParams
        
        if ($createdUser.Id) {
            Write-Host "REAL SUCCESS: User $($createdUser.DisplayName) is now in Entra ID." -ForegroundColor Green
            
            # 5. Dynamic Group Assignment (IAM Logic)
            # If the user belongs to the 'IT' department, they are automatically added to the IT Support group.
            if ($user.Department -eq "IT") {
                New-MgGroupMember -GroupId $itGroupId -DirectoryObjectId $createdUser.Id
                Write-Host "ACTION: Added to IT Support group." -ForegroundColor Yellow
            }
        }
    }
    catch {
        # Catching specific exceptions like 'User already exists' or 'Permission denied' without crashing the script.
        Write-Host "FAILED: Could not create $upn. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n--- Automation Cycle Complete ---" -ForegroundColor White
