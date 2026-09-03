# Enterprise Cloud Security Platform — Architecture

## 1. Architecture Goals

The Enterprise Cloud Security Platform is designed as a production-inspired Azure security architecture that integrates cloud infrastructure, preventive security controls, detection engineering, threat hunting, security automation and DevSecOps.

The architecture is based on several core principles:

- Infrastructure as Code
- Defence in depth
- Network segmentation
- Least privilege
- Private connectivity for sensitive services
- Centralised security monitoring
- Detection-as-Code
- Automated security validation
- Security orchestration and automated response
- Continuous detection testing and tuning

The objective is to demonstrate how security controls can operate as an integrated platform rather than as isolated security tools.

---

## 2. High-Level Architecture

The platform consists of five major layers:

```text
Source Control / CI/CD
        │
        ▼
Infrastructure & Preventive Controls
        │
        ▼
Cloud Workload Protection & Monitoring
        │
        ▼
Detection & Threat Hunting
        │
        ▼
Automated Response & Continuous Improvement
```

GitHub provides source control and CI/CD.

Terraform defines the Azure infrastructure and security configuration.

Azure Policy, RBAC, NSGs and private networking provide preventive controls.

Microsoft Defender for Cloud provides cloud security posture and workload protection capabilities.

Microsoft Sentinel provides SIEM, detection and SOAR capabilities.

Microsoft Defender XDR provides additional hunting and detection content for endpoint and cross-domain investigations.

---

## 3. Infrastructure as Code

Azure infrastructure is defined using Terraform.

The Terraform configuration is separated into:

```text
terraform/
├── bootstrap/
└── environments/
    └── dev/
```

### Bootstrap Layer

The bootstrap configuration establishes infrastructure required to support Terraform state and initial platform deployment.

### Environment Layer

The development environment contains the main platform configuration, including:

- Networking
- AKS
- Azure Container Registry
- Azure Key Vault
- Azure Policy
- Microsoft Defender for Cloud
- Microsoft Sentinel
- Sentinel analytics rules
- Sentinel automation rules
- Sentinel playbooks

Infrastructure as Code allows infrastructure and security configuration to be:

- version controlled;
- peer reviewed;
- statically analysed;
- reproduced;
- tested through CI/CD;
- changed through an auditable engineering process.

---

## 4. Network Architecture

The platform uses a hub-and-spoke network architecture.

```text
                   Hub VNet
                 10.10.0.0/16
                       │
                  VNet Peering
                       │
                       ▼
             Application Spoke VNet
                 10.20.0.0/16
```

### Hub VNet

The hub provides central platform connectivity.

It contains a dedicated management subnet:

```text
snet-management
10.10.1.0/24
```

### Application Spoke

The application spoke separates workload resources from the hub.

It contains dedicated subnets for different functions:

```text
Application Spoke
│
├── Application subnet
│   10.20.1.0/24
│
├── AKS subnet
│   10.20.2.0/23
│
└── Private Endpoint subnet
```

The hub and application spoke are connected using bidirectional VNet peering.

This design provides a foundation for separating shared platform services from application workloads.

---

## 5. Network Security

Network Security Groups are associated with relevant subnets to provide network-level traffic controls.

The architecture avoids treating the Azure virtual network as a single trusted security boundary.

Instead, different workload types are placed into dedicated subnets so that security controls can be applied according to workload function.

The architecture therefore follows:

```text
Network
   ↓
Subnet Segmentation
   ↓
NSG Enforcement
   ↓
Private Service Connectivity
```

This reduces unnecessary exposure and supports defence in depth.

---

## 6. Private Connectivity

Sensitive platform services use Azure Private Link architecture.

A dedicated private-endpoint subnet provides connectivity to services that should not require general public network exposure.

The V1 architecture includes private connectivity for:

- Azure Key Vault
- Azure Container Registry

Conceptually:

```text
Application / AKS
       │
       ▼
Azure VNet
       │
       ▼
Private Endpoint
       │
       ▼
Private Link
       │
       ▼
Azure PaaS Service
```

Private DNS integration allows the normal service hostname to resolve to the private endpoint address from within the connected network.

This is preferable to allowing workloads to access sensitive platform services through publicly exposed endpoints.

---

## 7. Azure Key Vault

Azure Key Vault provides secure secret-management capabilities.

The V1 design includes:

- Azure RBAC authorization
- Managed identity access
- Soft delete
- Purge protection
- Network restrictions
- Private Endpoint connectivity
- Private DNS integration

The workload identity is granted the required Key Vault role using Azure RBAC rather than embedding application credentials directly into infrastructure configuration.

The intended access model is:

```text
Workload
   │
   ▼
Managed Identity
   │
   ▼
Azure RBAC
   │
   ▼
Key Vault
```

This removes the need to store long-lived Key Vault credentials in application configuration.

---

## 8. Azure Container Registry

Azure Container Registry provides the registry layer for future containerised workloads.

The V1 security architecture includes:

- Premium SKU
- Administrative account disabled
- Public network access disabled
- Private Endpoint connectivity
- Private DNS integration

The intended workload flow is:

```text
AKS
 │
 ▼
Private Network
 │
 ▼
ACR Private Endpoint
 │
 ▼
Azure Container Registry
```

The platform also includes software supply-chain tooling in CI/CD.

Cosign is installed and validated as the selected signing technology, but actual workload image signing and verification are intentionally deferred until a containerised application workload is integrated.

This prevents the architecture from representing tooling installation as equivalent to enforced image-signing controls.

---

## 9. Azure Kubernetes Service

Azure Kubernetes Service provides the Kubernetes platform represented by the infrastructure.

AKS uses a dedicated subnet inside the application spoke.

The architecture includes capabilities such as:

- Dedicated AKS networking
- Managed identity
- Azure integration
- RBAC controls
- Security-policy configuration
- Terraform-controlled deployment

AKS deployment is controlled through a Terraform variable.

This allows the cluster to remain disabled when unnecessary, reducing cost during development while preserving the infrastructure definition.

---

## 10. Identity and Access Architecture

The platform uses Azure identity controls instead of relying on embedded credentials.

Key identity concepts include:

- Managed identities
- Azure RBAC
- Least-privilege role assignments
- Disabled ACR administrative credentials
- Workload identity

A representative access path is:

```text
Application Workload
        │
        ▼
Managed Identity
        │
        ▼
Azure RBAC
        │
        ▼
Authorised Azure Resource
```

This reduces credential-management overhead and limits the use of static secrets.

---

## 11. Azure Policy

Azure Policy forms part of the preventive governance layer.

Policy-as-Code allows governance requirements to be represented alongside infrastructure configuration.

The architecture uses policy to help prevent or identify configurations that violate expected security requirements.

Policy complements rather than replaces other controls:

```text
Azure Policy
     +
Terraform
     +
RBAC
     +
Network Controls
     +
Security Monitoring
```

Together these provide multiple layers of control.

---

## 12. Microsoft Defender for Cloud

Microsoft Defender for Cloud provides the cloud-security posture and workload-protection layer.

Within the overall architecture it sits between preventive infrastructure controls and security operations.

```text
Terraform / Azure Policy
          │
          ▼
Azure Resources
          │
          ▼
Defender for Cloud
          │
          ▼
Security Monitoring
```

This provides a defence-in-depth model where insecure configuration is first reduced through IaC and policy, while Defender provides an additional security assessment and protection layer.

---

## 13. Centralised Monitoring

Azure Monitor and Log Analytics provide the telemetry foundation for centralised security monitoring.

Relevant Azure and identity telemetry can be collected and made available to Microsoft Sentinel.

The general data path is:

```text
Azure / Identity / Security Telemetry
               │
               ▼
        Log Analytics
               │
               ▼
      Microsoft Sentinel
```

Detection quality depends on appropriate telemetry being available.

For that reason, log collection and detection engineering are treated as connected architectural concerns.

---

## 14. Microsoft Sentinel

Microsoft Sentinel provides the primary SIEM and SOAR layer.

The platform contains:

- 20 analytics rules
- 4 automation rules
- 4 Logic App response playbooks
- KQL detection logic
- Threat-hunting queries
- Detection validation
- Terraform deployment logic

The basic detection path is:

```text
Security Telemetry
        │
        ▼
     KQL Logic
        │
        ▼
 Analytics Rule
        │
        ▼
    Sentinel
        │
        ▼
    Incident
```

---

## 15. Detection-as-Code

Security detections are treated as software-engineering artifacts.

Detection logic is stored under:

```text
detections/sentinel/
```

Operational Sentinel rule definitions are stored under:

```text
sentinel/analytics-rules/
```

This separation is intentional.

The KQL file represents the underlying detection logic.

The analytics-rule definition packages that logic with operational metadata such as:

- severity;
- scheduling;
- tactics;
- techniques;
- entity mappings;
- thresholds;
- rule configuration.

The resulting lifecycle is:

```text
Threat Scenario
      │
      ▼
KQL Development
      │
      ▼
Testing
      │
      ▼
Tuning
      │
      ▼
Analytics Rule
      │
      ▼
Version Control
      │
      ▼
CI Validation
      │
      ▼
Terraform Deployment
      │
      ▼
Microsoft Sentinel
```

---

## 16. Detection Engineering Lifecycle

The project includes a dedicated detection-engineering layer.

```text
detection-engineering/
├── lifecycle.md
├── metrics/
├── testing/
└── tuning/
```

The detection lifecycle follows:

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
Measurement
        │
        └──────────────► Detection Improvement
```

This model recognises that a detection is not complete simply because a KQL query returns results.

A production-quality detection must also be testable, tunable, measurable and maintainable.

---

## 17. Detection Testing

Python scripts provide automated validation for security content.

Current automated validation covers:

```text
20 Sentinel analytics rules
4 Sentinel automation rules
8 password-spray regression tests
```

The password-spray detection includes explicit test scenarios covering:

- below-threshold activity;
- exact threshold boundaries;
- activity above the detection threshold;
- insufficient target-account diversity;
- single-account brute force;
- distributed source IPs;
- clear password spraying;
- successful authentication events.

This allows detection changes to be regression tested before deployment.

---

## 18. Threat Hunting

The platform includes a separate threat-hunting library.

```text
hunt/
├── azure/
├── endpoint/
└── identity/
```

Unlike scheduled analytics rules, hunting queries are designed primarily for analyst-led investigation and hypothesis testing.

Several hunts correlate related security events.

Examples include:

```text
Password Spray
      +
Successful Authentication
```

and:

```text
Privileged Role Assignment
          +
Subsequent Sign-in
```

Correlation can reveal suspicious behaviour that may not be sufficiently high-confidence when events are analysed individually.

---

## 19. Microsoft Defender XDR

Microsoft Defender XDR provides an additional security investigation and detection layer.

The repository includes:

```text
defender-xdr/
├── advanced-hunting/
├── custom-detections/
└── incident-response/
```

Advanced hunting content includes:

- Credential Access Behaviour
- PowerShell / Network Correlation
- Suspicious Process / Network Chains

Custom detection candidates include:

- LOLBin Network Activity
- Suspicious PowerShell Download

This layer extends the project beyond Azure resource telemetry into endpoint and cross-domain security investigation scenarios.

---

## 20. SOAR and SOC Automation

Microsoft Sentinel automation rules connect detections to response workflows.

The architecture follows:

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
```

Four playbook patterns are represented:

### Notification

```text
Incident
   ↓
Notify Security Team
```

### Enrichment

```text
Suspicious IOC
     ↓
Enrichment Playbook
     ↓
Additional Context
```

### Incident Management

```text
Security Event
     ↓
Incident Workflow
```

### Containment

```text
High-Confidence Identity Incident
              ↓
        Guarded Response
              ↓
        Disable Account
```

Containment actions require greater care than enrichment or notification because automated response can affect legitimate users and business operations.

---

## 21. DevSecOps Architecture

GitHub Actions provides continuous security validation.

The pipeline is divided into multiple security functions:

```text
                    Git Push / Pull Request
                              │
                              ▼
                       GitHub Actions
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
 Infrastructure          Secret Security       Supply Chain
        │                     │                     │
 Terraform fmt             Gitleaks               Syft
 Terraform init                                   SBOM
 Terraform validate                               Cosign
 Checkov
 Trivy
        │
        └─────────────────────┬─────────────────────┘
                              ▼
                   Security Content Testing
                              │
                  Analytics-rule validation
                  Automation-rule validation
                  Detection regression tests
```

This creates security gates before infrastructure or detection changes are considered ready for deployment.

---

## 22. Infrastructure Security Scanning

Checkov and Trivy analyse Terraform configuration for security weaknesses and cloud misconfiguration.

The V1 Checkov baseline is:

```text
Passed: 63
Failed: 0
Skipped: 1
```

One Checkov control is intentionally skipped for the ACR resource because the check relates to the legacy Docker Content Trust model rather than the signing approach selected for future workload integration.

The exception is documented alongside the resource instead of globally hiding the finding.

There is also a known Checkov parsing limitation involving `policy.tf`.

Terraform's own validation succeeds, so native Terraform validation remains the authoritative syntax check for the Terraform configuration.

---

## 23. Secret Protection

Gitleaks scans the repository for accidentally committed credentials and secrets.

The V1 pipeline currently reports:

```text
No leaks detected
```

Local sensitive Terraform artifacts are excluded from Git using `.gitignore`.

Examples include:

```text
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
*.tfplan
.env
*.pem
*.key
*.pfx
```

Terraform example variable files can remain version controlled without containing real credentials.

---

## 24. Software Supply-Chain Controls

Syft generates a CycloneDX Software Bill of Materials during CI/CD.

The SBOM is uploaded as a GitHub Actions artifact.

This provides an inventory artifact that can support:

- dependency visibility;
- vulnerability-management workflows;
- software provenance processes;
- compliance evidence.

Cosign is also installed and validated by the pipeline.

Actual container signing and verification are deferred until an application workload and container build pipeline are integrated.

---

## 25. Continuous Detection Improvement

The security architecture contains a feedback loop.

```text
Detection
   │
   ▼
Incident
   │
   ▼
Investigation
   │
   ▼
Detection Performance
   │
   ▼
Tuning
   │
   ▼
Regression Testing
   │
   ▼
Updated Detection
```

Detection metrics can be used to assess performance using concepts such as:

- True Positives
- False Positives
- False Negatives
- Precision
- Recall

This turns detection engineering into a measurable engineering process.

---

## 26. Defence-in-Depth Model

The complete security model can be summarised as:

```text
PREVENT
│
├── Terraform
├── Azure Policy
├── RBAC
├── NSGs
└── Private Endpoints
        │
        ▼
PROTECT
│
└── Microsoft Defender for Cloud
        │
        ▼
OBSERVE
│
├── Azure Monitor
└── Log Analytics
        │
        ▼
DETECT
│
├── Microsoft Sentinel
├── Detection-as-Code
└── Defender XDR
        │
        ▼
HUNT
│
├── Sentinel Hunting
└── Defender XDR Advanced Hunting
        │
        ▼
RESPOND
│
├── Automation Rules
└── Logic App Playbooks
        │
        ▼
IMPROVE
│
├── Detection Tuning
├── Metrics
└── Regression Testing
```

No single security control is expected to protect the environment by itself.

Instead, preventive, detective and responsive controls reinforce one another.

---

## 27. Security Design Principles

The architecture demonstrates the following principles:

### Least Privilege

Managed identities and RBAC are preferred over embedded credentials.

### Defence in Depth

Network, identity, governance, workload-protection and detection controls operate together.

### Reduce Public Exposure

Sensitive Azure services use private connectivity where appropriate.

### Security as Code

Infrastructure, detections, automation and policy configuration are maintained through version-controlled artifacts.

### Shift Left

Terraform configuration and secrets are scanned before deployment.

### Detection-as-Code

Security detections are developed, reviewed and validated through engineering workflows.

### Automate Repetitive Response

SOAR workflows reduce manual SOC activity for suitable enrichment, notification and response actions.

### Test Security Logic

Detection behaviour is regression tested instead of assuming that syntactically valid queries behave correctly.

### Continuous Improvement

Detection tuning and metrics feed improvements back into detection logic.

---

## 28. V1 Deployment State

The infrastructure and security content have passed static and CI/CD validation.

Current validation includes:

```text
Terraform validation                 PASS
Checkov                              PASS
Trivy                                PASS
Gitleaks                             PASS
SBOM generation                      PASS
Sentinel analytics validation        20/20 PASS
Sentinel automation validation       4/4 PASS
Password-spray regression testing    8/8 PASS
GitHub Actions pipeline              PASS
```

The final V1 live Azure deployment and runtime control verification are treated as a separate release gate.

This distinction is intentional:

```text
Code exists
    ≠
Code validates
    ≠
Infrastructure deployed
    ≠
Security control verified at runtime
```

A security control should only be described as runtime-verified after its behaviour has been confirmed in the deployed environment.

---

## 29. Known Limitations and Future Integration

The following areas are outside the current V1 runtime-verification scope or are intended for subsequent development:

- Final end-to-end Azure redeployment
- Runtime verification of newly hardened private networking
- Application workload integration
- Container build pipeline
- Cosign workload image signing
- Admission-time signature verification
- Expanded regression tests across additional detections
- Additional Defender XDR operationalisation
- Sentinel dashboards/workbooks
- Agentic AI security extension
- AWS implementation

These are intentionally separated from implemented V1 controls to avoid overstating the project's current deployment state.

---

## 30. Architecture Summary

The Enterprise Cloud Security Platform demonstrates an integrated security-engineering model:

```text
                    BUILD SECURELY
                          │
              Terraform + GitHub Actions
                          │
                          ▼
                       PREVENT
                          │
              Policy + RBAC + Network
                          │
                          ▼
                       PROTECT
                          │
                 Defender for Cloud
                          │
                          ▼
                       OBSERVE
                          │
               Monitor + Log Analytics
                          │
                          ▼
                        DETECT
                          │
               Sentinel + Defender XDR
                          │
                          ▼
                         HUNT
                          │
                    KQL Hunting
                          │
                          ▼
                       RESPOND
                          │
                 SOAR + Logic Apps
                          │
                          ▼
                       IMPROVE
                          │
               Test + Tune + Measure
```

The architecture therefore combines Cloud Security, DevSecOps, Detection Engineering and SOC Automation into a single version-controlled security platform.