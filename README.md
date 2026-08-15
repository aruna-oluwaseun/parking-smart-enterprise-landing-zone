# Enterprise Cloud Security Platform

> Enterprise-grade Azure Landing Zone, DevSecOps, Detection Engineering and Microsoft Sentinel implemented using Infrastructure as Code.

---

# Overview

Enterprise Cloud Security Platform is a production-inspired cloud security platform that demonstrates how modern Security Operations teams design, deploy, secure, monitor and automate enterprise cloud infrastructure using Microsoft Azure, Terraform, DevSecOps and Detection Engineering.

The platform combines secure infrastructure deployment, continuous security validation, Microsoft Defender for Cloud, Microsoft Sentinel, Detection-as-Code and Security Automation into a single repository.

Unlike isolated cloud labs, this project demonstrates an integrated enterprise security platform where infrastructure, detections and automation are managed as code.

---

# Objectives

The project demonstrates how to:

- Build an enterprise Azure Landing Zone
- Deploy infrastructure using Terraform
- Secure cloud resources using Azure Policy
- Protect workloads using Microsoft Defender for Cloud
- Build a secure DevSecOps pipeline
- Scan Infrastructure as Code
- Secure software supply chains
- Implement Detection-as-Code
- Build Microsoft Sentinel detections
- Map detections to MITRE ATT&CK
- Automate incident response
- Deploy security infrastructure using Infrastructure as Code

---

# High-Level Architecture

```text
                        GitHub Repository
                               │
                               ▼
                    GitHub Actions CI/CD
                               │
      ┌────────────────────────┼────────────────────────┐
      ▼                        ▼                        ▼
 Terraform              Security Scanning         Container Security
      │                        │                        │
      ▼                        ▼                        ▼
 Azure Landing Zone     Checkov / Trivy         SBOM / Cosign
      │
      ▼
 Azure Infrastructure
      │
      ▼
 Microsoft Defender for Cloud
      │
      ▼
 Microsoft Sentinel
      │
      ▼
 Detection Rules (KQL)
      │
      ▼
 Analytics Rules
      │
      ▼
 Sentinel Incidents
      │
      ▼
 Automation Rules
      │
      ▼
 Logic App Playbooks
      │
      ▼
 Security Operations
```

---

# Technologies

## Cloud

- Microsoft Azure
- Azure Landing Zones
- Azure Virtual Networks
- Hub & Spoke Networking
- Azure Kubernetes Service
- Azure Key Vault
- Azure Container Registry
- Azure Policy
- Azure Monitor
- Microsoft Defender for Cloud
- Microsoft Sentinel

---

## Infrastructure as Code

- Terraform
- AzureRM Provider

---

## DevSecOps

- GitHub Actions
- Checkov
- Trivy
- Gitleaks
- Syft
- Cosign

---

## Detection Engineering

- Microsoft Sentinel
- Kusto Query Language (KQL)
- MITRE ATT&CK
- Detection-as-Code
- Analytics Rules
- Logic Apps

---

## Languages

- Terraform (HCL)
- KQL
- YAML
- JSON
- PowerShell
- Python (planned)

---

# Repository Structure

```text
.
├── terraform/
│   ├── bootstrap/
│   ├── environments/
│   └── modules/
│
├── detections/
│   └── sentinel/
│
├── sentinel/
│   ├── analytics-rules/
│   ├── playbooks/
│   └── workbooks/
│
├── docs/
├── diagrams/
├── scripts/
└── .github/
```

---

# Features

## Azure Landing Zone

- Hub & Spoke Network
- Resource Groups
- Azure Policy
- Network Segmentation
- Monitoring
- Managed Identity

---

## DevSecOps Pipeline

The CI/CD pipeline automatically performs:

- Terraform Validation
- Terraform Formatting
- Infrastructure Security Scanning
- Secret Detection
- Container Scanning
- SBOM Generation
- Container Signing

---

## Detection Engineering

Enterprise detections include:

### Identity

- Failed Sign-ins
- Password Spray
- Impossible Travel
- MFA Disabled
- OAuth Consent Attack
- Token Replay
- Guest Privilege Escalation
- Service Principal Creation

### Azure Infrastructure

- Azure Policy Deleted
- Diagnostic Settings Deleted
- NSG Modified
- Storage Public Access Enabled
- Key Vault Firewall Disabled
- Resource Creation Anomaly

### Cloud Secrets

- Key Vault Access Spike
- Excessive Secret Access

### Endpoint

- Suspicious PowerShell

### Security Configuration

- Security Configuration Change

---

# Detection-as-Code

Every detection consists of:

```
KQL Detection
        │
        ▼
Analytics Rule
        │
        ▼
Terraform Deployment
        │
        ▼
Microsoft Sentinel
```

---

# MITRE ATT&CK Coverage

The platform currently covers:

- Initial Access
- Execution
- Persistence
- Privilege Escalation
- Credential Access
- Defense Evasion
- Collection

---

# Security Automation

Implemented playbooks include:

- Notify Security Team
- IOC Enrichment
- Create Incident
- Disable Account

---

# Documentation

- Architecture
- Threat Model
- Incident Response
- Detection Catalogue
- Security Findings
- Security Runbook

---

# CI/CD Security Controls

The pipeline performs:

- Terraform Validation
- Checkov
- Trivy
- Gitleaks
- Syft SBOM Generation
- Cosign Image Signing

---

# Future Roadmap

- Dynamic Detection-as-Code Framework
- Threat Hunting Library
- Detection Tuning Guide
- Microsoft Sentinel Workbooks
- Data Connector Documentation
- Python Security Automation
- OSINT Enrichment
- Malicious Email Analysis
- Rails Workload Deployment
- AWS Version

---

# Skills Demonstrated

- Microsoft Azure
- Azure Landing Zones
- Terraform
- Infrastructure as Code
- DevSecOps
- GitHub Actions
- Microsoft Defender for Cloud
- Microsoft Sentinel
- Detection Engineering
- KQL
- MITRE ATT&CK
- Detection-as-Code
- Security Automation
- AKS
- Container Security
- Supply Chain Security
- Incident Response

---

# Target Roles

- Detection Engineer
- Threat Detection Engineer
- Microsoft Sentinel Engineer
- Cloud Security Engineer
- Security Engineer
- Security Automation Engineer
- DevSecOps Engineer
- Product Security Engineer
- SOC Engineer

---

# Project Status

| Component | Status |
|----------|--------|
| Azure Landing Zone | ✅ Complete |
| Terraform Infrastructure | ✅ Complete |
| DevSecOps Pipeline | ✅ Complete |
| Defender for Cloud | ✅ Complete |
| Detection Engineering | 🚧 In Progress |
| Security Automation | 🚧 In Progress |
| Detection-as-Code | 🚧 In Progress |
| Rails Workload | ⏳ Planned |
| Threat Hunting | ⏳ Planned |
| AWS Version | ⏳ Planned |

---

## Author

**Aruna Oluwaseun**

Enterprise Cloud Security | DevSecOps | Detection Engineering | Microsoft Azure
