Enterprise Cloud Security Platform

Production-inspired Azure security engineering platform combining Infrastructure as Code, cloud security, DevSecOps, Microsoft Sentinel, Defender XDR, Detection-as-Code, threat hunting, SOAR and security automation.

Overview

The Enterprise Cloud Security Platform is a security engineering project designed to demonstrate how cloud infrastructure, preventive controls, detection engineering, threat hunting and automated incident response can be managed as code.

Built around Microsoft Azure, Terraform and the Microsoft security ecosystem, the project combines:

Azure landing-zone architecture
Hub-and-spoke networking
Infrastructure as Code
Cloud security hardening
Microsoft Defender for Cloud
Microsoft Defender XDR
Microsoft Sentinel
KQL detection engineering
Detection-as-Code
Threat hunting
SOAR and incident-response automation
Detection tuning and regression testing
DevSecOps security controls
Infrastructure security scanning
Software supply-chain security foundations

Rather than treating infrastructure, SIEM detections and automation as separate labs, the repository models them as components of an integrated security engineering platform.

Architecture
                         GitHub
                           │
                           ▼
                   GitHub Actions
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
    Terraform          IaC Security       Secret/Supply
    Validation          Scanning          Chain Controls
        │                  │                  │
        │             Checkov/Trivy       Gitleaks/Syft
        │                                     │
        └──────────────────┬──────────────────┘
                           │
                           ▼
                    Azure Landing Zone
                           │
              ┌────────────┼─────────────┐
              ▼            ▼             ▼
         Networking       AKS           ACR
              │                          │
              │                    Private Access
              │
              ├──── Key Vault
              │       │
              │   Private Endpoint
              │
              ▼
       Defender for Cloud
              │
              ▼
        Security Telemetry
              │
       ┌──────┴────────┐
       ▼               ▼
Microsoft Sentinel  Defender XDR
       │               │
       └───────┬───────┘
               ▼
       Detection Engineering
               │
        KQL Analytics Rules
               │
               ▼
        Security Incidents
               │
        Automation Rules
               │
               ▼
       Logic App Playbooks
               │
       ┌───────┼─────────┐
       ▼       ▼         ▼
   Enrichment Notify   Response
               │
               ▼
       Security Operations
Security Architecture
Azure Landing Zone

The infrastructure uses a hub-and-spoke network architecture to provide logical separation between shared management infrastructure and application workloads.

Implemented components include:

Hub virtual network
Application spoke virtual network
Hub-to-spoke and spoke-to-hub VNet peering
Dedicated management subnet
Application subnet
Dedicated AKS subnet
Dedicated private-endpoint subnet
Network Security Groups
NSG-to-subnet associations
Resource-group separation
Managed identities
Azure RBAC
Azure Policy

Infrastructure is provisioned and managed using Terraform.

Private Networking

Private networking is used to reduce exposure of sensitive platform services.

The platform includes:

Application Spoke
10.20.0.0/16
│
├── Application Subnet
│
├── AKS Subnet
│
└── Private Endpoint Subnet
        │
        ├── Key Vault Private Endpoint
        │
        └── ACR Private Endpoint

Private DNS provides name resolution for privately exposed Azure services.

Key Vault hardening includes:

Public network access disabled
Default-deny network ACLs
Private Endpoint
Private DNS
Azure RBAC
Managed-identity-based access
Purge protection
Soft-delete protection

ACR private-networking hardening is implemented in Terraform as part of the final V1 hardening phase.

Azure Kubernetes Service

The platform contains Terraform configuration for AKS and supporting network/RBAC integration.

Security considerations include:

Dedicated AKS subnet
Managed identity
Network isolation
Azure RBAC integration
Defender integration
Container-registry integration
Infrastructure security scanning

AKS deployment can be controlled through Terraform configuration to avoid unnecessary resource consumption in development environments.

Microsoft Defender for Cloud

Defender for Cloud provides cloud security posture and workload protection capabilities.

The project incorporates Defender configuration into Infrastructure as Code and uses Defender as part of the broader cloud-security monitoring architecture.

This provides a preventative and detection layer alongside Azure Policy, Sentinel and Defender XDR.

Microsoft Defender XDR

The project includes a dedicated:

defender-xdr/

security-engineering area covering Microsoft Defender XDR detection and investigation concepts.

Defender XDR complements Sentinel by providing endpoint and identity-focused telemetry and investigation capabilities that can be correlated with cloud security events.

Microsoft Sentinel

Microsoft Sentinel provides the SIEM and SOAR layer of the platform.

Sentinel infrastructure and security content are managed through Terraform and source-controlled configuration.

The platform includes:

Log Analytics integration
Microsoft Sentinel enablement
Analytics rules
Automation rules
Logic App playbooks
Detection content
Incident-response workflows
KQL hunting queries
Detection Engineering

Detection logic is maintained separately from deployment configuration.

detections/
└── sentinel/
    └── KQL detection logic

sentinel/
├── analytics-rules/
├── automation-rules/
└── playbooks/

detection-engineering/
└── tuning, testing and measurement

This separation allows detection logic to be developed and tested independently while the Sentinel configuration controls how that logic is operationalised.

Implemented detection scenarios include identity, Azure control-plane, Key Vault and endpoint activity.

Examples include:

Password spraying
Impossible travel
Failed authentication
MFA disablement
OAuth consent attacks
Token replay
Privileged role assignment
Guest-user privilege escalation
Service-principal creation
Key Vault secret-access anomalies
Key Vault firewall modification
Azure Policy deletion
Diagnostic-settings deletion
NSG modification
Public storage exposure
Suspicious resource creation
Suspicious PowerShell activity
Security configuration changes
Detection-as-Code

Security detections are treated as software artifacts rather than manually created SIEM configuration.

KQL
 │
 ▼
Detection Logic
 │
 ▼
Analytics Rule
 │
 ▼
Automated Validation
 │
 ▼
Source Control
 │
 ▼
Microsoft Sentinel

The project currently validates 20 Sentinel analytics rules through automated Python validation.

This approach enables:

Version control
Repeatable deployment
Peer review
Automated validation
Consistent metadata
MITRE ATT&CK mapping
Detection lifecycle management
Detection Testing

Detection engineering extends beyond simply writing KQL.

The project includes automated regression testing for detection behaviour.

The password-spray detection, for example, is tested against scenarios including:

Below-threshold activity
Exact detection boundaries
Above-threshold activity
Insufficient target-account diversity
Single-account brute force
Distributed source IP addresses
Clear password-spray behaviour
Successful authentication events

The current password-spray regression suite contains 8 automated test cases.

This helps prevent detection changes from silently altering expected security behaviour.

Detection Tuning

The platform includes detection-tuning documentation and methodology.

Tuning considers:

False positives
False negatives
Detection thresholds
Time windows
Entity behaviour
Environmental baselines
Detection precision
Detection coverage

This provides a lifecycle around detections rather than treating them as static KQL queries.

Detection Metrics

Detection effectiveness is considered through metrics designed to measure the quality and operational value of security rules.

The project includes documentation around detection measurement and continuous improvement.

Threat Hunting

A dedicated threat-hunting library is implemented under:

hunt/
├── identity/
├── azure/
└── endpoint/

Current hunting scenarios include:

Identity
Password spray followed by successful authentication
Privileged role assignment followed by sign-in
Suspicious service-principal activity
Azure
Key Vault secret access after role change
Security-control tampering
Suspicious resource creation after role change
Endpoint
Suspicious LOLBin execution
Suspicious PowerShell download/execution

Hunting queries differ from scheduled detections by supporting proactive investigation of suspicious behaviours and attack hypotheses.

MITRE ATT&CK

Detection and hunting content is mapped to relevant MITRE ATT&CK techniques and tactics.

Coverage includes areas such as:

Initial Access
Execution
Persistence
Privilege Escalation
Credential Access
Defense Evasion
Collection

MITRE ATT&CK provides a common framework for describing attacker behaviour and evaluating detection coverage.

Security Automation and SOAR

Sentinel automation rules connect detected security activity to response workflows.

Detection
    │
    ▼
Analytics Rule
    │
    ▼
Sentinel Incident
    │
    ▼
Automation Rule
    │
    ▼
Logic App Playbook
    │
    ├── Enrichment
    ├── Notification
    └── Response

Automation content is maintained as code and validated automatically.

Implemented workflows include security notification and enrichment capabilities, with response workflows designed around managed identity and controlled permissions.

DevSecOps Pipeline

GitHub Actions provides automated security validation.

The current pipeline performs:

Commit / Pull Request
        │
        ├── Terraform fmt
        ├── Terraform init
        ├── Terraform validate
        │
        ├── Checkov
        ├── Trivy
        ├── Gitleaks
        │
        ├── SBOM generation
        │      └── Syft / CycloneDX
        │
        ├── Cosign tooling validation
        │
        ├── Sentinel content validation
        ├── Automation-rule validation
        │
        └── Detection regression tests

The pipeline fails when required validation or security controls fail, providing a security gate before infrastructure/security-content changes are accepted.

Infrastructure Security Scanning

Checkov is used to assess Terraform against cloud-security best practices.

During V1 development, findings were used as engineering inputs rather than blindly suppressed.

Remediation work included:

Key Vault network ACL enforcement
Key Vault public-access removal
Key Vault Private Link
Private DNS
Private-endpoint subnet security
ACR private-networking design

Known scanner limitations and accepted exceptions are documented rather than hidden.

Software Supply-Chain Security

The platform repository includes foundations for software supply-chain security:

Secret scanning with Gitleaks
SBOM generation with Syft
CycloneDX SBOM format
Cosign tooling
Trivy security scanning

Application build, SAST, SCA and container-image production belong to the separate application repository, maintaining separation between application delivery and security/platform infrastructure.

Image-signing architecture uses modern signing approaches rather than relying on deprecated Docker Content Trust.

Automated Security Validation

Python is used to validate security content.

Current automated validation includes:

20 Sentinel analytics rules
        ↓
Content validation

Automation rules
        ↓
Configuration validation

Password-spray detection
        ↓
8 regression tests

This demonstrates the application of software-engineering practices to security operations content.

Repository Structure

The repository has evolved beyond the original structure and now includes:

.
├── .github/
│   └── workflows/
│
├── defender-xdr/
│
├── detection-engineering/
│
├── detections/
│   └── sentinel/
│
├── diagrams/
│
├── docs/
│
├── hunt/
│   ├── azure/
│   ├── endpoint/
│   └── identity/
│
├── policies/
│
├── scripts/
│
├── sentinel/
│   ├── analytics-rules/
│   ├── automation-rules/
│   └── playbooks/
│
└── terraform/
    ├── bootstrap/
    ├── environments/
    │   └── dev/
    └── modules/
Security Engineering Principles

The project applies several core security-engineering principles:

Defence in depth — preventive, detective and responsive controls operate together.

Least privilege — RBAC and managed identities reduce unnecessary permissions and credential exposure.

Private-by-design networking — sensitive Azure services are moved away from unnecessary public exposure.

Security as Code — infrastructure, detections and automation are source controlled.

Detection-as-Code — security detection logic is versioned, validated and tested.

Shift-left security — security checks run during CI/CD rather than only after deployment.

Assume breach — detection, hunting and incident-response capabilities complement preventative controls.

Continuous improvement — detections are tested, measured and tuned rather than considered complete once deployed.

Validation

V1 uses multiple validation layers:

Terraform
├── terraform fmt
└── terraform validate

Infrastructure Security
├── Checkov
└── Trivy

Secrets
└── Gitleaks

Supply Chain
├── Syft
└── Cosign tooling

Detection Engineering
├── Analytics-rule validation
├── Automation-rule validation
└── Detection regression tests
