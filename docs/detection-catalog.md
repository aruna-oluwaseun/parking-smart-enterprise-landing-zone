# Detection Catalog

This catalog documents the Microsoft Sentinel analytics rules implemented in the Parking Smart Enterprise Cloud Security Platform.

The V1 platform contains **20 analytics rules** covering identity, Azure infrastructure, cloud secrets, endpoint activity and security-control tampering.

Detection content is maintained as code and validated through the CI/CD pipeline before deployment.

---

## Detection Coverage

| Detection | Category | MITRE ATT&CK | Severity | Data Source | Analytics Rule | Automated Response |
|---|---|---|---|---|---|---|
| Multiple Failed Sign-ins | Identity | T1110 - Brute Force | Medium | SigninLogs | failed-signins.yaml | — |
| Impossible Travel | Identity | T1078 - Valid Accounts | Medium | SigninLogs | impossible-travel.yaml | Automation rule |
| Privileged Role Assignment | Identity | T1098 - Account Manipulation | High | AuditLogs | privileged-role-assignment.yaml | — |
| Disabled Account Sign-in | Identity | T1078 - Valid Accounts | High | SigninLogs | disabled-account-signin.yaml | — |
| Service Principal Creation | Identity | T1136.003 - Cloud Account | Medium | AuditLogs | service-principal-creation.yaml | — |
| Password Spray | Identity | T1110.003 - Password Spraying | High | SigninLogs | password-spray.yaml | Automation rule |
| MFA Disabled or Modified | Identity | T1556.006 - Multi-Factor Authentication | High | AuditLogs | mfa-disabled.yaml | — |
| Suspicious OAuth Consent Grant | Identity | T1528 - Steal Application Access Token | High | AuditLogs | oauth-consent-attack.yaml | — |
| Possible Token Replay | Identity | T1528 - Steal Application Access Token | High | SigninLogs | token-replay.yaml | — |
| Guest User Privilege Escalation | Identity | T1098.003 - Additional Cloud Roles | High | AuditLogs | guest-user-privilege-escalation.yaml | Automation rule |
| Azure Policy Deleted | Azure Control Plane | T1685 - Disable or Modify Tools | High | AzureActivity | azure-policy-deleted.yaml | — |
| NSG Modified | Azure Control Plane | T1686.001 - Cloud Firewall | High | AzureActivity | nsg-modified.yaml | — |
| Diagnostic Settings Deleted | Azure Control Plane | T1685.002 - Disable or Modify Cloud Log | High | AzureActivity | diagnostic-settings-deleted.yaml | — |
| Key Vault Network Security Modified | Azure Control Plane | T1686.001 - Cloud Firewall | High | AzureActivity | keyvault-firewall-disabled.yaml | — |
| Storage Public Access Changed | Azure Control Plane | T1530 - Data from Cloud Storage | High | AzureActivity | storage-public-access-enabled.yaml | — |
| Key Vault Access Spike | Credential Access | T1555.006 - Cloud Secrets Management Stores | High | AzureDiagnostics | keyvault-access-spike.yaml | Automation rule |
| Excessive Secret Access | Credential Access | T1555.006 - Cloud Secrets Management Stores | High | AzureDiagnostics | excessive-secret-access.yaml | — |
| Unusual Azure Resource Creation | Azure Control Plane | T1578 - Modify Cloud Compute Infrastructure | Medium | AzureActivity | resource-creation-anomaly.yaml | — |
| Security Configuration Change | Defence Evasion | T1685 - Disable or Modify Tools | High | AzureActivity | security-configuration-change.yaml | — |
| Suspicious PowerShell Execution | Endpoint / Execution | T1059.001 - PowerShell | High | SecurityEvent | suspicious-powershell.yaml | — |

---

## Detection Categories

The current detection library covers five primary security domains:

### Identity Security

Identity detections monitor suspicious authentication, account manipulation, privilege escalation and identity-control changes.

Examples include:

- Password spraying
- Impossible travel
- MFA modification
- Token replay
- OAuth consent abuse
- Guest privilege escalation
- Privileged role assignment
- Service principal creation

### Azure Control Plane Security

Azure control-plane detections monitor potentially dangerous changes to cloud infrastructure and security controls.

Examples include:

- Azure Policy deletion
- NSG modification
- Diagnostic settings deletion
- Key Vault network-security changes
- Storage public-access changes
- Unusual resource creation

### Credential and Secret Access

These detections monitor suspicious interaction with Azure Key Vault and cloud secrets.

Examples include:

- Key Vault access spikes
- Excessive secret access

### Endpoint Security

Endpoint-focused detections identify potentially malicious execution behaviour.

The current Sentinel endpoint detection monitors suspicious PowerShell activity.

Additional endpoint hunting and detection content is maintained under the Defender XDR component of the repository.

### Security-Control Tampering

Security-control detections identify activity that may reduce visibility or weaken defensive controls.

Examples include changes to:

- Azure Policy
- Diagnostic settings
- Network controls
- Security configuration

---

## Detection-as-Code Model

Detection content follows a version-controlled engineering workflow:

```text
Threat Scenario
      ↓
KQL Detection Logic
      ↓
Analytics Rule Definition
      ↓
Automated Validation
      ↓
Regression Testing
      ↓
Code Review / CI
      ↓
Terraform Deployment
      ↓
Microsoft Sentinel