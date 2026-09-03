# Enterprise Cloud Security Platform — Threat Model

## 1. Purpose

This threat model documents the primary security threats considered in the design of the Parking Smart Enterprise Cloud Security Platform.

The objective is to connect:

- Assets
- Trust boundaries
- Threat scenarios
- Attack techniques
- Preventive controls
- Detective controls
- Security response

The model focuses on the V1 Azure environment, including identity, networking, AKS, Azure Container Registry, Azure Key Vault, CI/CD, Microsoft Sentinel and security automation.

---

## 2. Threat Modelling Approach

The platform uses a threat-scenario-based approach informed by MITRE ATT&CK.

The general process is:

```text
Identify Asset
     ↓
Identify Threat
     ↓
Identify Attack Path
     ↓
Assess Existing Controls
     ↓
Define Detection
     ↓
Define Response
     ↓
Validate / Improve
```

Threat modelling is performed alongside infrastructure and detection engineering rather than as a separate one-time activity.

---

## 3. Critical Assets

The primary assets requiring protection are:

| Asset | Security Concern |
|---|---|
| Microsoft Entra identities | Account compromise, privilege escalation and persistence |
| Privileged accounts | Administrative takeover |
| Service principals / workload identities | Machine identity compromise |
| Azure subscription | Unauthorized resource access or modification |
| Azure Key Vault | Secret and credential theft |
| Azure Container Registry | Malicious or unauthorized container artifacts |
| AKS | Workload and cluster compromise |
| Virtual networks | Unauthorized connectivity and lateral movement |
| Security controls | Defence evasion and security weakening |
| Log Analytics / Sentinel | Loss of detection visibility |
| GitHub repository | Source and infrastructure-code compromise |
| CI/CD pipeline | Supply-chain compromise |
| Terraform state | Exposure of sensitive infrastructure information |
| Detection content | Detection bypass or malicious rule modification |
| SOAR workflows | Unauthorized or unsafe automated response |

---

## 4. Trust Boundaries

The architecture contains several important trust boundaries.

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions
    │
    ▼
Azure Control Plane
    │
    ▼
Azure Landing Zone
    │
    ├── Hub VNet
    │
    └── Application Spoke
            │
            ├── AKS
            ├── Key Vault
            └── ACR

Security Telemetry
    │
    ▼
Log Analytics
    │
    ▼
Microsoft Sentinel
    │
    ▼
Automation Rules
    │
    ▼
Logic App Playbooks
```

Crossing each boundary requires appropriate authentication, authorization, network controls or validation.

---

# 5. Identity Threats

## 5.1 Password Spraying

### Threat

An attacker attempts a small number of commonly used passwords against multiple user accounts to avoid traditional account-lockout controls.

### Potential Impact

Successful compromise may provide initial access to the Azure environment.

### MITRE ATT&CK

`T1110.003 — Password Spraying`

### Preventive Controls

- Microsoft Entra authentication controls
- MFA
- Least privilege
- Identity security policies

### Detective Controls

- Password Spray Sentinel detection
- Failed Sign-ins detection
- Password Spray Followed by Success hunting query

### Validation

The password-spray detection includes eight regression test scenarios covering threshold boundaries, brute-force differentiation and distributed attack behaviour.

### Response

High-confidence password-spray incidents can trigger Sentinel automation for enrichment and analyst investigation.

---

## 5.2 Stolen or Replayed Authentication Tokens

### Threat

An attacker obtains an authentication token and attempts to reuse it to impersonate a legitimate identity.

### Potential Impact

Token theft may bypass password-based controls and allow access under the victim's identity.

### MITRE ATT&CK

`T1528 — Steal Application Access Token`

### Detective Controls

- Possible Token Replay detection
- Impossible Travel detection
- Identity threat-hunting queries

### Response

Analysts investigate authentication context, source IP addresses, affected identities and related activity.

---

## 5.3 MFA Modification

### Threat

An attacker with sufficient account access modifies or disables MFA-related configuration to weaken authentication security.

### Potential Impact

The attacker may establish easier or persistent access to the compromised identity.

### MITRE ATT&CK

`T1556.006 — Multi-Factor Authentication`

### Preventive Controls

- Least privilege
- Administrative RBAC
- Identity governance

### Detective Controls

- MFA Disabled or Modified analytics rule
- AuditLogs monitoring

### Response

Investigate:

- actor identity;
- affected account;
- authentication activity;
- associated privilege changes;
- subsequent sign-ins.

---

## 5.4 Privilege Escalation

### Threat

A compromised or malicious identity obtains privileged Azure or Entra permissions.

### Potential Impact

Privilege escalation may allow modification of infrastructure, identities, security controls or sensitive data.

### Detective Controls

- Privileged Role Assignment detection
- Guest User Privilege Escalation detection
- Privileged Role Assignment Followed by Sign-in hunting query

### Response

Validate whether the assignment was authorized and investigate subsequent activity performed by the identity.

---

## 5.5 Malicious Service Principal Creation

### Threat

An attacker creates or modifies a service principal to establish persistent machine-based access.

### Potential Impact

Service principals can provide persistent access independent of an interactive user account.

### MITRE ATT&CK

`T1136.003 — Cloud Account`

### Detective Controls

- Service Principal Creation detection
- Suspicious Service Principal Activity hunt

### Response

Investigate:

- creating identity;
- credentials;
- assigned permissions;
- subsequent API/resource activity.

---

## 5.6 OAuth Consent Abuse

### Threat

A malicious application obtains permissions through an OAuth consent grant.

### Potential Impact

The application may gain persistent access to organizational data without repeatedly requiring user credentials.

### Detective Controls

- Suspicious OAuth Consent Grant detection
- AuditLogs investigation

### Response

Review application permissions, consenting identity, publisher information and subsequent activity.

---

# 6. Secrets and Credential Threats

## 6.1 Key Vault Secret Theft

### Threat

An attacker with access to a workload identity, user identity or Azure resource attempts to retrieve secrets from Azure Key Vault.

### Potential Impact

Compromised secrets may provide access to applications, infrastructure or downstream systems.

### Preventive Controls

- Azure RBAC
- Managed identity
- Private Endpoint
- Public network restrictions
- Purge protection
- Least privilege

### Detective Controls

- Key Vault Access Spike detection
- Excessive Secret Access detection
- Key Vault Secret Access After Role Change hunting query

### Response

Investigate the requesting identity, secret access volume, recent role assignments and subsequent use of accessed credentials.

---

## 6.2 Secrets Committed to Source Control

### Threat

Credentials, API keys or other sensitive values are accidentally committed to the Git repository.

### Potential Impact

Anyone with repository access may obtain the credential.

If the repository becomes publicly accessible, exposure becomes substantially more serious.

### Preventive Controls

`.gitignore` excludes sensitive local artifacts including:

```text
*.tfvars
*.tfstate
.env
*.pem
*.key
*.pfx
```

### Detective Controls

Gitleaks scans repository history during CI/CD.

Current V1 pipeline result:

```text
No leaks detected
```

### Response

Any discovered credential should be treated as compromised and rotated rather than simply removed from the latest commit.

---

# 7. Network Threats

## 7.1 Unauthorized Network Access

### Threat

An attacker attempts to reach workloads or sensitive Azure services through unnecessarily exposed network paths.

### Preventive Controls

- Hub-and-spoke architecture
- Subnet segmentation
- Network Security Groups
- Private Endpoints
- Public network restrictions

### Detective Controls

- NSG Modified detection
- Azure activity monitoring

---

## 7.2 Network Security Group Modification

### Threat

An attacker modifies an NSG to permit unauthorized network connectivity.

### Potential Impact

This could expose workloads, enable lateral movement or bypass intended network segmentation.

### MITRE ATT&CK

`T1686.001 — Cloud Firewall`

### Detective Controls

- NSG Modified analytics rule
- Security Configuration Change detection
- Security Control Tampering hunt

### Response

Compare the change against approved infrastructure configuration and identify the actor responsible.

---

# 8. Azure Key Vault Network Security

## Threat

An attacker weakens Key Vault network restrictions or enables public access.

### Potential Impact

The network attack surface of a sensitive secrets-management service increases.

### Preventive Controls

- Public network access disabled
- Private Endpoint
- Private DNS
- Terraform-managed configuration

### Detective Controls

- Key Vault Network Security Modified detection
- AzureActivity monitoring

### Response

Validate the configuration against Terraform and investigate the identity responsible for the modification.

---

# 9. Azure Container Registry Threats

## 9.1 Public Registry Exposure

### Threat

An Azure Container Registry is unnecessarily accessible through a public network endpoint.

### Preventive Controls

The V1 ACR configuration includes:

- Premium SKU
- Administrative account disabled
- Public network access disabled
- Private Endpoint
- Private DNS

---

## 9.2 Malicious or Untrusted Container Images

### Threat

A malicious or tampered container image enters the software supply chain and is deployed to a workload.

### Potential Impact

The attacker could gain code execution inside the application environment.

### Current Controls

The CI/CD architecture includes:

- Trivy security scanning
- Syft SBOM generation
- Cosign tooling

### V1 Limitation

Cosign is currently installed and validated as the selected signing technology.

Actual workload image signing and signature enforcement are deferred until a containerised application workload is integrated.

This threat therefore remains only partially mitigated in V1.

---

# 10. AKS Threats

## Threat Scenarios

Potential Kubernetes-related threats include:

- unauthorized API access;
- excessive cluster privileges;
- compromised workloads;
- malicious container images;
- lateral movement;
- secret theft;
- insecure network exposure.

### Security Controls

The architecture includes:

- Dedicated AKS subnet
- Managed identity
- RBAC
- Network segmentation
- Infrastructure security scanning
- Azure Policy capabilities
- Defender for Cloud integration

AKS deployment is optional in the development environment to reduce unnecessary cost.

---

# 11. Azure Control Plane Threats

## 11.1 Azure Policy Deletion

### Threat

An attacker deletes or weakens Azure Policy controls to permit insecure infrastructure configuration.

### MITRE ATT&CK

`T1685 — Disable or Modify Tools`

### Detective Controls

- Azure Policy Deleted analytics rule
- Security Configuration Change detection
- Security Control Tampering hunt

### Response

Determine:

- who performed the action;
- which policy was affected;
- whether subsequent resource changes occurred;
- whether the change was authorized.

---

## 11.2 Diagnostic Settings Deletion

### Threat

An attacker disables diagnostic settings to reduce security visibility before conducting malicious activity.

### Potential Impact

Security events may no longer reach the monitoring platform.

### Detective Controls

- Diagnostic Settings Deleted analytics rule
- Security Configuration Change detection

### Response

Restore logging and investigate activity surrounding the configuration change.

---

## 11.3 Unauthorized Resource Creation

### Threat

A compromised identity creates unexpected Azure infrastructure.

Potential attacker objectives include:

- persistence;
- cryptocurrency mining;
- staging infrastructure;
- data exfiltration;
- unauthorized compute.

### Detective Controls

- Unusual Azure Resource Creation detection
- Suspicious Resource Creation After Role Change hunt

---

# 12. Logging and Detection Threats

## Threat

An attacker attempts to evade detection by disabling or modifying security controls.

Possible targets include:

```text
Azure Policy
Diagnostic Settings
NSGs
Sentinel configuration
Security monitoring
```

### Detective Controls

The platform includes multiple overlapping detections rather than relying on one generic rule.

This supports defence in depth against security-control tampering.

---

# 13. Endpoint Threats

## 13.1 Suspicious PowerShell

### Threat

An attacker uses PowerShell for execution, download, discovery or post-compromise activity.

### MITRE ATT&CK

`T1059.001 — PowerShell`

### Detective Controls

Sentinel:

- Suspicious PowerShell Execution

Defender XDR:

- Suspicious PowerShell Download
- PowerShell / Network Correlation
- Suspicious Process / Network Chain

Threat Hunting:

- Suspicious PowerShell Download Execution

This provides multiple opportunities to identify suspicious PowerShell behaviour.

---

## 13.2 Living-off-the-Land Activity

### Threat

An attacker abuses legitimate operating-system binaries to perform malicious activity while attempting to blend into normal system behaviour.

### Detective Controls

Defender XDR and hunting content include suspicious LOLBin execution and network activity scenarios.

---

# 14. CI/CD and Software Supply-Chain Threats

## 14.1 Malicious Infrastructure Change

### Threat

A malicious or insecure Terraform change is committed to the repository.

### Preventive / Detective Controls

GitHub Actions executes:

```text
Terraform fmt
Terraform init
Terraform validate
Checkov
Trivy
Gitleaks
```

This allows infrastructure changes to be evaluated before deployment.

---

## 14.2 Detection Logic Tampering

### Threat

A change to detection content accidentally or deliberately weakens security monitoring.

### Controls

The pipeline executes:

```text
validate_detection_content.py
validate_automation_rules.py
test_password_spray_detection.py
```

Detection content is therefore subject to automated validation and regression testing.

---

## 14.3 Dependency and Artifact Risk

### Threat

Software dependencies or build artifacts contain vulnerable or unauthorized components.

### Controls

The supply-chain layer includes:

- Trivy
- Syft
- CycloneDX SBOM generation
- Cosign tooling

Full image-signing enforcement requires integration with the future application workload.

---

# 15. SOAR and Automation Threats

Automation itself introduces security risk.

## 15.1 Incorrect Automated Containment

### Threat

A false-positive detection triggers an automated containment action against a legitimate user.

### Potential Impact

- User lockout
- Business disruption
- Operational impact

### Design Principle

Low-risk actions such as enrichment and notification can be highly automated.

High-impact actions such as disabling an identity require stronger confidence and should support guarded or human-approved response patterns.

Conceptually:

```text
Detection
    ↓
Confidence Assessment
    ↓
┌──────────────────────┐
│ Low/Medium Confidence│
└──────────┬───────────┘
           ↓
   Enrich / Notify

┌──────────────────────┐
│ High Confidence      │
└──────────┬───────────┘
           ↓
Guarded Containment
```

This prevents automation from becoming an additional operational risk.

---

# 16. Threat-to-Control Mapping

| Threat | Prevent | Detect | Respond |
|---|---|---|---|
| Password spraying | MFA / identity controls | Password Spray | Enrich / investigate |
| Token abuse | Identity controls | Token Replay / Impossible Travel | Investigate / revoke access where appropriate |
| Privilege escalation | RBAC / least privilege | Role Assignment / Guest Escalation | Investigate / remove unauthorized privilege |
| Secret theft | Key Vault RBAC / Private Endpoint | Key Vault detections | Investigate / rotate affected secrets |
| NSG tampering | Terraform / RBAC | NSG Modified | Investigate / restore configuration |
| Logging disabled | RBAC / IaC | Diagnostic Settings Deleted | Restore telemetry / investigate |
| Policy tampering | RBAC / IaC | Azure Policy Deleted | Restore policy / investigate |
| Public service exposure | Private Endpoints / network controls | Configuration detections | Restore secure configuration |
| Suspicious PowerShell | Endpoint controls | Sentinel / Defender XDR | Investigate endpoint |
| Malicious IaC | Code review / IaC | Checkov / Trivy | Block pipeline / remediate |
| Secret committed to Git | Secret handling / `.gitignore` | Gitleaks | Rotate credential |
| Supply-chain compromise | Scanning / controlled builds | Trivy / SBOM | Investigate artifact |
| Detection tampering | Version control / review | CI validation / regression tests | Reject change |
| Unsafe SOAR action | Guardrails | Incident review | Human-approved containment |

---

# 17. Detection Gaps and Residual Risk

Threat modelling also identifies areas where controls are incomplete.

Current V1 residual risks include:

- container image signing is not yet enforced against a deployed workload;
- runtime verification requires the final Azure deployment;
- not every Sentinel detection currently has automated regression tests;
- Defender XDR content requires further runtime operationalisation;
- some automated containment actions should remain guarded;
- detection effectiveness will require production-like telemetry for realistic tuning.

These are documented rather than representing incomplete controls as fully implemented.

---

# 18. Continuous Threat Modelling

Threat modelling is not treated as a one-time design exercise.

The intended lifecycle is:

```text
Architecture Change
        ↓
New Attack Surface
        ↓
Threat Assessment
        ↓
Preventive Control
        ↓
Detection Requirement
        ↓
Detection / Hunting Logic
        ↓
Response Procedure
        ↓
Testing
        ↓
Operational Feedback
        ↓
Threat Model Update
```

This creates a relationship between architecture engineering and security operations.

---

# 19. Threat Model Summary

The platform applies defence in depth across:

```text
IDENTITY
   ↓
NETWORK
   ↓
WORKLOAD
   ↓
SECRETS
   ↓
CLOUD CONTROL PLANE
   ↓
CI/CD SUPPLY CHAIN
   ↓
DETECTION
   ↓
AUTOMATED RESPONSE
```

The objective is not to assume that preventive controls will stop every attack.

Instead:

```text
Prevent where possible
        ↓
Detect what bypasses prevention
        ↓
Investigate suspicious behaviour
        ↓
Respond proportionately
        ↓
Learn and improve
```

This threat model therefore directly informs the platform's preventive controls, Sentinel detections, Defender XDR hunting content and SOC automation workflows.