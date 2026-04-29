# Zero-Touch User Onboarding | PowerShell & Microsoft Graph API

## 🚀 Overview
This repository contains a production-ready PowerShell script designed to automate the user provisioning process within **Microsoft Entra ID (Azure AD)**. By leveraging the **Microsoft Graph SDK**, this tool transforms manual entry tasks into a seamless, "Zero-Touch" workflow.

## ✨ Key Features
* **Bulk Provisioning:** Automates the creation of multiple users from a structured CSV file.
* **Dynamic IAM Logic:** Automatically assigns users to specific Security Groups (e.g., GRP-IT-SUPPORT) based on department attributes.
* **Security First:** Enforces `ForceChangePasswordNextSignIn` and standardized UPN formatting.
* **Error Handling:** Robust `Try/Catch` blocks to handle duplicate UPNs and API connection issues.

## 🛠️ Tech Stack
* **Language:** PowerShell 7.x
* **API:** Microsoft Graph SDK
* **Platform:** Cross-platform (Tested on macOS & Windows)
* **Cloud:** Microsoft Entra ID (Azure AD)

## 📖 How It Works
1.  **Authentication:** The script establishes a secure session via `Connect-MgGraph` with scoped permissions (`User.ReadWrite.All`, `GroupMember.ReadWrite.All`).
2.  **Data Processing:** It iterates through a local `users.csv` file.
3.  **Validation:** It checks for existing identities before attempting creation.
4.  **Execution:** Users are created and instantly mapped to the correct organizational groups.

## 📸 Screenshots
![Automation Success](Images/)

## ⚖️ License
Distributed under the MIT License. See `LICENSE` for more information.
