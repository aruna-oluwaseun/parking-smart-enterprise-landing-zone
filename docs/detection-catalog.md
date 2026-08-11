# Detection Catalog

This catalog documents the Microsoft Sentinel detections implemented for the Parking Smart Enterprise Landing Zone.

| Detection | MITRE ATT&CK | Severity | Data Source | Analytics Rule | Response Playbook |
|---|---|---:|---|---|---|
| Multiple Failed Sign-ins | T1110 - Brute Force | Medium | SigninLogs | failed-signins.yaml | notify-teams |
| Impossible Travel | T1078 - Valid Accounts | Medium | SigninLogs | impossible-travel.yaml | notify-teams |
| Privileged Role Assignment | T1098 - Account Manipulation | High | AuditLogs | privileged-role-assignment.yaml | create-incident |
| Disabled Account Sign-in | T1078 - Valid Accounts | High | SigninLogs | disabled-account-signin.yaml | notify-teams |
| Service Principal Creation | T1136.003 - Cloud Account | Medium | AuditLogs | service-principal-creation.yaml | create-incident |
| Password Spray | T1110.003 - Password Spraying | High | SigninLogs | password-spray.yaml | enrich-ioc |
| MFA Disabled or Modified | T1556.006 - Multi-Factor Authentication | High | AuditLogs | mfa-disabled.yaml | create-incident |
| Suspicious OAuth Consent Grant | T1528 - Steal Application Access Token | High | AuditLogs | oauth-consent-attack.yaml | create-incident |
| Possible Token Replay | T1528 - Steal Application Access Token | High | SigninLogs | token-replay.yaml | enrich-ioc |
| Guest User Privilege Escalation | T1098.003 - Additional Cloud Roles | High | AuditLogs | guest-user-privilege-escalation.yaml | create-incident |
| Azure Policy Deleted | T1685 - Disable or Modify Tools | High | AzureActivity | azure-policy-deleted.yaml | create-incident |
| NSG Modified | T1686.001 - Cloud Firewall | High | AzureActivity | nsg-modified.yaml | notify-teams |
| Diagnostic Settings Deleted | T1685.002 - Disable or Modify Cloud Log | High | AzureActivity | diagnostic-settings-deleted.yaml | create-incident |
| Key Vault Network Security Modified | T1686.001 - Cloud Firewall | High | AzureActivity | keyvault-firewall-disabled.yaml | create-incident |
| Storage Public Access Changed | T1530 - Data from Cloud Storage | High | AzureActivity | storage-public-access-enabled.yaml | create-incident |
| Key Vault Access Spike | T1555.006 - Cloud Secrets Management Stores | High | AzureDiagnostics | keyvault-access-spike.yaml | enrich-ioc |
| Excessive Secret Access | T1555.006 - Cloud Secrets Management Stores | High | AzureDiagnostics | excessive-secret-access.yaml | enrich-ioc |
| Unusual Azure Resource Creation | T1578 - Modify Cloud Compute Infrastructure | Medium | AzureActivity | resource-creation-anomaly.yaml | notify-teams |
| Security Configuration Change | T1685 - Disable or Modify Tools | High | AzureActivity | security-configuration-change.yaml | create-incident |
| Suspicious PowerShell Execution | T1059.001 - PowerShell | High | SecurityEvent | suspicious-powershell.yaml | create-incident |