# Enterprise Cloud Security Platform

> Production-inspired Azure cloud security platform combining Infrastructure as Code, DevSecOps, Detection Engineering, Microsoft Sentinel, Defender XDR and automated security validation.

---

## Overview

The Enterprise Cloud Security Platform is a hands-on security engineering project demonstrating how cloud infrastructure, preventive controls, detection engineering, threat hunting and security automation can be managed as code.

The platform uses Microsoft Azure and Terraform to build a secure landing-zone-style environment and integrates:

- Azure hub-and-spoke networking
- Private networking for sensitive platform services
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure Key Vault
- Azure Policy
- Microsoft Defender for Cloud
- Microsoft Sentinel
- Microsoft Defender XDR
- Detection-as-Code
- Threat Hunting
- Security Automation
- DevSecOps security controls
- Software supply-chain security tooling
- Automated detection validation and regression testing

The objective is not simply to deploy cloud resources, but to demonstrate how infrastructure security, SecOps and DevSecOps controls can operate together as an integrated security platform.

---

# Architecture

```text
                         GitHub Repository
                                │
                                ▼
                       GitHub Actions CI/CD
                                │
          ┌─────────────────────┼──────────────────────┐
          │                     │                      │
          ▼                     ▼                      ▼
      Terraform          Security Validation      Supply Chain
          │                     │                      │
          │              Checkov / Trivy              │
          │                 Gitleaks              Syft / Cosign
          │
          ▼
                  Azure Landing Zone
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
            Hub               Application Spoke
             │                       │
      Management Subnet      ┌───────┼─────────┐
                             │       │         │
                             ▼       ▼         ▼
                         App Subnet  AKS    Private
                                          Endpoints
                                              │
                                      ┌───────┴───────┐
                                      ▼               ▼
                                  Key Vault          ACR

                         Azure Security
                               │
                 ┌─────────────┼─────────────┐
                 ▼             ▼             ▼
            Azure Policy   Defender      Monitoring
                           for Cloud
                               │
                               ▼
                       Microsoft Sentinel
                               │
                    Detection-as-Code
                               │
                       Analytics Rules
                               │
                          Incidents
                               │
                      Automation Rules
                               │
                      Logic App Playbooks
                               │
                        Security Response
```

Microsoft Defender XDR provides an additional detection and hunting layer for endpoint and cross-domain security investigations.

---

# Repository Structure

```text
.
├── .github/
│   └── workflows/
│
├── defender-xdr/
│   ├── advanced-hunting/
│   ├── custom-detections/
│   └── incident-response/
│
├── detection-engineering/
│   ├── metrics/
│   ├── testing/
│   └── tuning/
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
├── scripts/
│
├── sentinel/
│   ├── analytics-rules/
│   ├── automation-rules/
│   └── playbooks/
│
└── terraform/
    ├── bootstrap/
    └── environments/
        └── dev/
```

---

# 1. Azure Landing Zone

The infrastructure layer is implemented using Terraform and follows a landing-zone-style architecture.

Core capabilities include:

- Resource-group separation
- Hub-and-spoke networking
- Dedicated management subnet
- Application subnet
- AKS subnet
- Dedicated private-endpoint subnet
- Network Security Groups
- VNet peering
- Managed identities
- Azure RBAC
- Azure Policy
- Central monitoring and security services

The network architecture separates platform, application and private-service connectivity rather than placing all resources into a single flat network.

---

# 2. Private Networking and Platform Hardening

Sensitive platform services are designed to avoid unnecessary public exposure.

## Azure Key Vault

Security controls include:

- Azure RBAC authorization
- Managed-identity access
- Purge protection
- Soft delete
- Restricted network access
- Private Endpoint connectivity
- Private DNS integration

## Azure Container Registry

ACR is configured with:

- Premium SKU
- Administrative account disabled
- Public network access disabled
- Private Endpoint connectivity
- Private DNS integration

The platform therefore provides private connectivity between workloads and critical supporting services.

---

# 3. Azure Kubernetes Service

AKS infrastructure is represented as code and integrated into the application spoke.

Capabilities include:

- Dedicated AKS subnet
- Managed identity
- Azure RBAC integration
- Network integration
- Security-policy controls
- Controlled deployment through Terraform variables

AKS deployment can be enabled or disabled depending on the target environment and deployment requirements.

---

# 4. Microsoft Defender for Cloud

Microsoft Defender for Cloud configuration is managed through Terraform.

The platform uses Defender as part of the cloud workload protection layer alongside Azure Policy, infrastructure hardening and Microsoft Sentinel.

This demonstrates the distinction between:

**Preventive controls**

```text
Terraform
Azure Policy
RBAC
NSGs
Private Endpoints
```

and:

**Detective / response controls**

```text
Defender for Cloud
Microsoft Sentinel
Defender XDR
Detection Engineering
Security Automation
```

---

# 5. Microsoft Sentinel

Microsoft Sentinel provides the SIEM and security-automation layer.

The repository currently contains:

- 20 analytics rules
- 4 automation rules
- 4 response playbooks
- Terraform-based Sentinel deployment
- KQL detection content
- MITRE ATT&CK mapping
- Automated content validation

---

# 6. Detection-as-Code

Detection logic is maintained as version-controlled code.

The workflow is:

```text
Threat Scenario
      │
      ▼
KQL Detection
      │
      ▼
Detection Testing / Tuning
      │
      ▼
Sentinel Analytics Rule
      │
      ▼
Terraform Deployment
      │
      ▼
Microsoft Sentinel
      │
      ▼
Incident
```

The `detections/sentinel/` directory contains underlying KQL detection logic.

The `sentinel/analytics-rules/` directory contains operational Sentinel rule definitions including metadata required to deploy and manage those detections.

This separation allows detection logic to be developed independently while still being packaged as deployable SIEM content.

---

# 7. Sentinel Detection Coverage

The platform currently contains 20 Sentinel analytics rules.

## Identity and Authentication

- Failed Sign-ins
- Disabled Account Sign-in
- Password Spray
- Impossible Travel
- MFA Disabled
- OAuth Consent Attack
- Token Replay
- Guest User Privilege Escalation
- Privileged Role Assignment
- Service Principal Creation

## Azure Infrastructure and Configuration

- Azure Policy Deleted
- Diagnostic Settings Deleted
- NSG Modified
- Storage Public Access Enabled
- Key Vault Firewall Disabled
- Resource Creation Anomaly
- Security Configuration Change

## Secrets and Key Vault

- Key Vault Access Spike
- Excessive Secret Access

## Endpoint

- Suspicious PowerShell

---

# 8. Detection Engineering Lifecycle

The project goes beyond simply storing KQL queries.

The `detection-engineering/` layer documents how detections move through an engineering lifecycle:

```text
Threat Identification
        │
        ▼
Detection Design
        │
        ▼
Implementation
        │
        ▼
Testing
        │
        ▼
Deployment
        │
        ▼
Monitoring
        │
        ▼
Tuning
        │
        ▼
Metrics / Improvement
```

The repository includes:

- Detection lifecycle documentation
- Validation strategy
- Detection test cases
- Password-spray tuning documentation
- General tuning guidance
- Detection metrics

This demonstrates detection engineering as a repeatable software-engineering process rather than one-off SIEM query creation.

---

# 9. Detection Regression Testing

The password-spray detection includes automated regression testing implemented in Python.

Current test coverage includes:

```text
TC01  Below failed-attempt threshold
TC02  Exact detection boundary
TC03  Above detection threshold
TC04  Below target-account threshold
TC05  Single-account brute force
TC06  Distributed source IP addresses
TC07  Clear password spray
TC08  Successful authentication events
```

The tests verify that changes to detection logic do not unintentionally change expected detection behaviour.

Current validation result:

```text
8/8 password-spray regression tests passing
```

---

# 10. Automated Sentinel Content Validation

Python validation scripts verify Sentinel content before changes are accepted into the security pipeline.

Current validation coverage:

```text
20/20 Sentinel analytics rules passing
4/4 Sentinel automation rules passing
8/8 password-spray regression tests passing
```

Validation checks are integrated into GitHub Actions.

This introduces CI/CD principles into detection engineering and helps prevent malformed or incomplete security content from reaching deployment.

---

# 11. Threat Hunting

The project includes a dedicated threat-hunting library covering Azure, identity and endpoint scenarios.

Current hunts include:

## Identity

- Password Spray Followed by Successful Authentication
- Privileged Role Assignment Followed by Sign-in
- Suspicious Service Principal Activity

## Azure

- Key Vault Secret Access After Role Change
- Security Control Tampering
- Suspicious Resource Creation After Role Change

## Endpoint

- Suspicious LOLBin Execution
- Suspicious PowerShell Download and Execution

The hunts focus particularly on behavioural correlation where individual events may not be sufficiently suspicious on their own.

---

# 12. Microsoft Defender XDR

The project also includes Microsoft Defender XDR security engineering content.

## Advanced Hunting

- Credential Access Behaviour
- PowerShell and Network Correlation
- Suspicious Process and Network Chain

## Custom Detection Logic

- LOLBin Network Activity
- Suspicious PowerShell Download

The Defender XDR layer demonstrates endpoint and cross-domain hunting alongside the Azure/Sentinel security-monitoring architecture.

---

# 13. Security Automation and SOAR

Four Microsoft Sentinel automation rules are maintained as code.

Automation coverage currently includes:

- Guest User Privilege Escalation
- Impossible Travel
- Key Vault Access Spike
- Password Spray

Response playbooks include:

- Notify Security Team
- IOC Enrichment
- Create Incident
- Disable Account

The response flow is designed around:

```text
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
    ▼
Enrichment / Notification / Containment
```

---

# 14. DevSecOps Security Pipeline

GitHub Actions continuously validates infrastructure and security content.

The pipeline performs:

```text
Source Code
    │
    ├── Terraform fmt
    ├── Terraform init
    ├── Terraform validate
    │
    ├── Checkov IaC scanning
    ├── Trivy configuration scanning
    ├── Gitleaks secret detection
    │
    ├── Syft SBOM generation
    ├── Cosign tooling validation
    │
    ├── Sentinel analytics-rule validation
    ├── Sentinel automation-rule validation
    └── Detection regression testing
```

The pipeline currently completes successfully across all jobs.

---

# 15. Infrastructure Security Scanning

## Checkov

Checkov is used to statically analyse Terraform configuration for cloud-security misconfigurations.

Current V1 baseline:

```text
Passed checks: 63
Failed checks: 0
Skipped checks: 1
```

The intentional skip relates to `CKV_AZURE_164`.

The legacy Azure Container Registry Docker Content Trust control represented by this check is not implemented as an architectural requirement. The exception is documented directly alongside the ACR resource.

The project instead includes modern software-supply-chain tooling such as SBOM generation and Cosign tooling, with workload image-signing enforcement reserved for workload integration.

A known Checkov parsing limitation also affects `policy.tf`; Terraform's native validation is used as the authoritative syntax validation for the Terraform configuration.

---

# 16. Secret Detection

Gitleaks scans repository history and source content for accidentally committed credentials and secrets.

The current pipeline completes with:

```text
No leaks detected
```

Terraform state, real `.tfvars`, environment files, keys and other sensitive local artifacts are excluded from source control.

---

# 17. Software Supply-Chain Security

The pipeline includes software supply-chain controls.

## SBOM

Syft generates a CycloneDX software bill of materials for the repository.

The generated SBOM is retained as a GitHub Actions artifact.

## Cosign

Cosign is installed and validated in the pipeline as the signing technology selected for future workload-artifact signing.

Actual application/container signing will be introduced when a deployable workload is integrated with the platform.

This distinction prevents the repository from claiming image-signing enforcement before an application image is part of the V1 deployment.

---

# 18. Security Documentation

The project includes supporting engineering and operational documentation:

```text
docs/
├── architecture.md
├── detection-catalog.md
├── incident-response.md
├── security-findings.md
├── security-runbook.md
└── threat-model.md
```

These documents capture architecture, detection coverage, security findings, incident response procedures and threat modelling.

---

# 19. Security Engineering Model

The overall platform follows a layered security model:

```text
                    PREVENT
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
     Terraform      Azure Policy     RBAC
        │
        ▼
 NSGs / Private Endpoints
                       │
                       ▼
                    PROTECT
                       │
                       ▼
              Defender for Cloud
                       │
                       ▼
                    DETECT
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
    Sentinel       Defender XDR   Detection-as-Code
                       │
                       ▼
                     HUNT
                       │
                       ▼
               Threat Hunting
                       │
                       ▼
                    RESPOND
                       │
                       ▼
              Sentinel Automation
                       │
                       ▼
               Logic App Playbooks
                       │
                       ▼
                    IMPROVE
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
           Tuning             Metrics
```

---

# 20. Technologies

## Cloud & Platform

- Microsoft Azure
- Azure Virtual Network
- Azure Kubernetes Service
- Azure Container Registry
- Azure Key Vault
- Azure Private Link
- Azure Private DNS
- Azure Policy
- Azure Monitor
- Microsoft Defender for Cloud
- Microsoft Sentinel
- Microsoft Defender XDR

## Infrastructure as Code

- Terraform
- AzureRM Provider

## DevSecOps

- GitHub Actions
- Checkov
- Trivy
- Gitleaks

## Software Supply Chain

- Syft
- CycloneDX SBOM
- Cosign

## Detection Engineering

- Kusto Query Language (KQL)
- Microsoft Sentinel
- Defender XDR Advanced Hunting
- MITRE ATT&CK
- Detection-as-Code
- Detection Tuning
- Detection Regression Testing

## Automation & Languages

- Python
- PowerShell
- YAML
- JSON
- Terraform / HCL
- KQL

---

# 21. Current Validation Status

| Security Control | Status |
|---|---|
| Terraform formatting | ✅ Passing |
| Terraform validation | ✅ Passing |
| Checkov | ✅ 0 failed checks |
| Trivy | ✅ CI validated |
| Gitleaks | ✅ No leaks detected |
| SBOM generation | ✅ Working |
| Sentinel analytics validation | ✅ 20/20 |
| Sentinel automation validation | ✅ 4/4 |
| Password-spray regression tests | ✅ 8/8 |
| GitHub Actions security pipeline | ✅ Passing |

---

# 22. V1 Project Status

| Component | Status |
|---|---|
| Azure Landing Zone IaC | ✅ Implemented |
| Hub-and-Spoke Networking | ✅ Implemented |
| Private Endpoint Architecture | ✅ Implemented |
| Key Vault Hardening | ✅ Implemented |
| ACR Hardening | ✅ Implemented |
| AKS Infrastructure | ✅ Implemented |
| Azure Policy | ✅ Implemented |
| Defender for Cloud IaC | ✅ Implemented |
| Microsoft Sentinel IaC | ✅ Implemented |
| Sentinel Analytics Rules | ✅ 20 |
| Sentinel Automation Rules | ✅ 4 |
| Logic App Playbooks | ✅ 4 |
| Threat Hunting Library | ✅ Implemented |
| Defender XDR Content | ✅ Implemented |
| Detection Engineering Lifecycle | ✅ Implemented |
| Detection Regression Testing | ✅ Implemented |
| CI/CD Security Validation | ✅ Passing |
| Final V1 Azure Deployment | ⏳ Pending |
| Live Control Verification | ⏳ Pending |

---

# 23. Deployment Status

The V1 infrastructure and security controls are currently validated through Terraform and the CI/CD security pipeline.

The final end-to-end Azure deployment and live control verification are intentionally treated as a separate release gate.

This prevents static validation from being represented as equivalent to successful runtime deployment.

---

# 24. Future Roadmap

Post-V1 development may include:

- Application workload integration
- Container build pipeline
- Cosign image signing and verification
- Admission-time image verification
- Expanded detection regression testing
- Additional Defender XDR detections
- Sentinel workbooks and dashboards
- Python security automation
- OSINT enrichment
- AI/Agentic Security extension
- AWS implementation of the platform architecture

---

# Skills Demonstrated

This project demonstrates practical experience across:

- Azure Cloud Security
- Cloud Security Architecture
- Terraform
- Infrastructure as Code
- Azure Landing Zones
- Network Security
- Private Link / Private Endpoints
- Identity and Access Management
- Azure Policy
- Microsoft Defender for Cloud
- Microsoft Sentinel
- Microsoft Defender XDR
- KQL
- Detection Engineering
- Detection-as-Code
- Detection Testing and Tuning
- Threat Hunting
- MITRE ATT&CK
- Security Automation / SOAR
- Incident Response
- DevSecOps
- Infrastructure Security Scanning
- Secret Detection
- Software Supply-Chain Security
- SBOM
- CI/CD Security
- Python Security Automation

---

# Target Roles

The project is designed to demonstrate skills relevant to roles including:

- Cloud Security Engineer
- DevSecOps Engineer
- Application / Product Security Engineer
- Security Engineer
- Detection Engineer
- Threat Detection Engineer
- Microsoft Sentinel Engineer
- Defender XDR Engineer
- Security Automation Engineer
- SOC / Detection Content Engineer

---

## Author

**Aruna Oluwaseun**

Cloud Security | DevSecOps | Detection Engineering | Microsoft Azure