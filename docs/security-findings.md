# Security Findings and Remediation

## 1. Purpose

This document records security findings identified during the development and validation of the Parking Smart Enterprise Cloud Security Platform.

The objective is to demonstrate a repeatable security-engineering process:

```text
Identify
   ↓
Assess
   ↓
Prioritise
   ↓
Remediate
   ↓
Validate
   ↓
Document
   ↓
Prevent Regression
```

Security findings are not treated simply as scanner failures. Each finding should be reviewed in the context of the architecture, threat model, environment and intended security posture.

---

## 2. Security Assessment Approach

The V1 platform uses several complementary security controls.

| Control | Purpose |
|---|---|
| Checkov | Terraform / Infrastructure-as-Code security scanning |
| Trivy | Infrastructure configuration security scanning |
| Gitleaks | Secret detection |
| Terraform validation | Configuration correctness |
| Terraform formatting | Code consistency |
| Detection validation scripts | Sentinel analytics-rule validation |
| Automation validation scripts | Sentinel automation-rule validation |
| Detection regression tests | Detection behaviour validation |
| Syft | Software Bill of Materials generation |
| Cosign | Software supply-chain signing capability |

These controls are executed through the GitHub Actions security pipeline.

---

# 3. Findings Summary

During V1 development, Infrastructure-as-Code scanning identified several security issues requiring investigation.

Important findings included:

| Finding | Control | Initial Status | V1 Treatment |
|---|---|---|---|
| ACR public network access | Checkov CKV_AZURE_139 | Failed | Remediated |
| ACR trusted/signed image requirement | Checkov CKV_AZURE_164 | Failed | Documented exception |
| Missing NSG association on subnets | Checkov CKV2_AZURE_31 | Failed | Remediated |
| Terraform state / variable exposure risk | Repository review | Risk identified | Protected through `.gitignore` |
| Repository secret exposure | Gitleaks | No active leak detected | Continuous CI scanning |
| Detection content errors | Custom validation | Potential risk | CI validation implemented |
| Detection regression | Custom testing | Potential risk | Password-spray regression suite implemented |

The final Checkov scan for the V1 Terraform configuration produced:

```text
Passed checks: 63
Failed checks: 0
Skipped checks: 1
Parsing errors: 1
```

The skipped check represents an explicitly managed exception rather than an unresolved failed control.

The remaining parsing error is tracked separately because the Terraform configuration itself validates successfully.

---

# 4. Finding: Azure Container Registry Public Network Access

## Finding

Checkov initially reported:

```text
CKV_AZURE_139
Ensure ACR set to disable public networking
```

Affected resource:

```text
azurerm_container_registry.main
```

## Risk

Allowing unrestricted public network access to a container registry increases the exposed attack surface.

Potential risks include:

- Unauthorized access attempts
- Credential attacks
- Increased Internet exposure
- Container image reconnaissance
- Misconfiguration leading to image exposure

## Remediation

The Terraform configuration was updated so that public network access to the Azure Container Registry is disabled.

The intended architecture therefore moves toward controlled private connectivity rather than unrestricted Internet exposure.

## Validation

Checkov was executed again after the Terraform change.

The finding no longer appeared as a failed check.

## Status

```text
REMEDIATED
```

---

# 5. Finding: Container Image Trust

## Finding

Checkov reported:

```text
CKV_AZURE_164
Ensures that ACR uses signed/trusted images
```

Affected resource:

```text
azurerm_container_registry.main
```

## Security Objective

The objective behind this control is to reduce software-supply-chain risk by ensuring that untrusted or tampered container images cannot be deployed without verification.

## V1 Design

The platform implements supply-chain security capabilities through:

```text
Container / Artifact
        ↓
SBOM Generation
        ↓
Syft
        ↓
Artifact Signing
        ↓
Cosign
        ↓
Verification / Deployment Controls
```

The GitHub Actions pipeline installs and validates Cosign and generates an SBOM using Syft.

## Treatment

The Checkov finding was reviewed rather than blindly suppressed.

The specific ACR trusted-image control represented by the Checkov rule is not implemented directly as part of the V1 ACR configuration.

The check is therefore handled as a documented V1 exception while image-signing capability is demonstrated separately using Cosign.

This distinction is important:

```text
Checkov control skipped
        ≠
Security risk ignored
```

Instead:

```text
Control reviewed
        ↓
Architecture considered
        ↓
Alternative / future control identified
        ↓
Exception documented
```

## Future Improvement

A production implementation should enforce image verification before deployment rather than relying only on image signing.

Possible enforcement points include admission controls and deployment-policy mechanisms.

## Status

```text
ACCEPTED / DOCUMENTED V1 EXCEPTION
```

---

# 6. Finding: Missing Network Security Group Associations

## Finding

Checkov reported:

```text
CKV2_AZURE_31
Ensure VNET subnet is configured with a Network Security Group (NSG)
```

The finding initially affected several subnets, including:

```text
hub_management
application
aks
private_endpoints
```

## Risk

Subnets without appropriate network controls can increase the risk of:

- Unnecessary network exposure
- Unauthorized lateral movement
- Unrestricted communication between workloads
- Weak segmentation
- Increased blast radius following compromise

## Remediation

Network Security Groups and subnet associations were added to the Terraform networking configuration where appropriate.

This strengthened the network-segmentation model of the landing zone.

## Validation

Checkov was rerun after remediation.

The `CKV2_AZURE_31` failures were eliminated from the complete environment scan.

## Status

```text
REMEDIATED
```

---

# 7. Terraform State and Sensitive Configuration

## Risk

Terraform state can contain sensitive infrastructure information and, depending on the resources involved, potentially sensitive values.

Terraform variable files may also contain environment-specific or secret values.

Committing these files to a public source repository could expose sensitive configuration.

## Control

The repository `.gitignore` excludes:

```text
*.tfstate
*.tfstate.*
*.tfvars
*.auto.tfvars
tfplan
*.tfplan
**/.terraform/*
```

Example variable templates remain permitted:

```text
*.tfvars.example
*.auto.tfvars.example
```

## Validation

Repository tracking was checked using Git to verify that Terraform state, local variable files, plans and `.terraform` working-directory content were not being tracked.

## Status

```text
MITIGATED
```

---

# 8. Secret Exposure Prevention

## Risk

Secrets accidentally committed to source control can expose:

- Cloud credentials
- API keys
- Access tokens
- Certificates
- Application credentials

Git history can preserve those secrets even after the visible file has been changed.

## Control

Gitleaks is integrated into the GitHub Actions pipeline.

The pipeline scans the repository for potential secret exposure.

The repository also excludes common sensitive file types including:

```text
.env
.env.*
*.pem
*.key
*.pfx
*.p12
.azure/
```

## Current Result

The CI pipeline completed the Gitleaks scan without detecting an active leak.

## Status

```text
CONTROL IMPLEMENTED
```

---

# 9. Infrastructure-as-Code Security Scanning

The platform uses more than Terraform's native validation.

This is intentional because:

```text
terraform validate
```

answers primarily:

> Is this Terraform configuration structurally valid?

Whereas security scanning asks:

> Is this infrastructure configuration secure?

The pipeline therefore performs:

```text
Terraform fmt
      ↓
Terraform init
      ↓
Terraform validate
      ↓
Checkov
      ↓
Trivy
```

This provides both configuration validation and security-policy evaluation.

## Status

```text
IMPLEMENTED
```

---

# 10. Detection Content Validation

## Risk

Detection-as-Code introduces its own software-quality risks.

A malformed analytics rule could:

- Fail deployment
- Contain missing metadata
- Use invalid configuration
- Produce inconsistent detection behaviour
- Reduce security visibility

## Control

The repository contains:

```text
scripts/validate_detection_content.py
```

The validator checks the Sentinel analytics-rule content before deployment.

The current V1 validation covers:

```text
20 Sentinel analytics rules
```

The validation suite currently completes successfully:

```text
Validation successful. 20 analytics rules passed.
```

## Status

```text
IMPLEMENTED
```

---

# 11. Automation Rule Validation

## Risk

Incorrect SOAR automation configuration could cause:

- Failed playbook invocation
- Missing incident response
- Incorrect automation behaviour
- Inconsistent response workflows

## Control

The repository contains:

```text
scripts/validate_automation_rules.py
```

The current V1 implementation validates four Sentinel automation rules:

```text
Password Spray
Impossible Travel
Guest User Privilege Escalation
Key Vault Access Spike
```

Current validation result:

```text
Validation successful. 4 automation rules passed.
```

## Status

```text
IMPLEMENTED
```

---

# 12. Detection Regression Testing

## Risk

Changes to detection thresholds or query logic can unintentionally alter detection behaviour.

A syntactically valid detection is not necessarily a correct detection.

For example, changing the password-spray threshold could result in:

```text
Too low
   ↓
Excessive false positives

Too high
   ↓
Missed attacks
```

## Control

The repository contains:

```text
scripts/test_password_spray_detection.py
```

The V1 regression suite tests scenarios including:

- Below failed-attempt threshold
- Exact detection boundary
- Above detection threshold
- Below target-account threshold
- Single-account brute force
- Distributed source IP addresses
- Clear password spray
- Successful authentication events

Current result:

```text
Validation successful. 8 password-spray tests passed.
```

## Security Value

This demonstrates an important Detection-as-Code principle:

```text
Detection Change
      ↓
Regression Testing
      ↓
Content Validation
      ↓
CI/CD
      ↓
Deployment
```

## Status

```text
IMPLEMENTED FOR PASSWORD-SPRAY V1
```

---

# 13. Software Supply-Chain Security

The V1 pipeline introduces software-supply-chain controls using Syft and Cosign.

## SBOM

Syft is used to generate a CycloneDX Software Bill of Materials.

The SBOM provides visibility into software components and dependencies associated with the repository/workload.

## Signing

Cosign provides artifact/container-signing capability.

Signing helps establish provenance and integrity by allowing consumers to verify that an artifact originates from an expected source and has not been modified.

## V1 Limitation

V1 demonstrates these capabilities but does not claim a complete production software-supply-chain enforcement architecture.

Future versions should connect signing with deployment-time verification and policy enforcement.

## Status

```text
PARTIALLY IMPLEMENTED / FUTURE ENFORCEMENT REQUIRED
```

---

# 14. CI/CD Security Gate

Security validation is integrated into GitHub Actions rather than being performed only as a manual activity.

The pipeline currently includes:

```text
Source Change
      ↓
GitHub Actions
      ↓
Terraform Format
      ↓
Terraform Validation
      ↓
Checkov
      ↓
Trivy
      ↓
Gitleaks
      ↓
SBOM Generation
      ↓
Cosign Setup
      ↓
Detection Validation
      ↓
Automation Validation
      ↓
Detection Regression Testing
```

This creates a repeatable security-validation process for infrastructure and security content.

At the completion of the V1 validation work, the pipeline executed successfully.

## Status

```text
IMPLEMENTED
```

---

# 15. Remaining and Residual Risks

V1 intentionally retains several areas requiring further implementation or production validation.

These include:

### Live Telemetry Validation

Detection logic requires realistic Azure, identity and endpoint telemetry for complete operational tuning.

### Detection Tuning

Thresholds require adjustment based on production baselines.

### Automated Containment

High-impact containment should not be enabled blindly without authorization, confidence controls and rollback procedures.

### Image Verification

Cosign signing capability should ultimately be paired with deployment-time verification.

### IOC Enrichment

External threat-intelligence integrations require appropriate API configuration and operational validation.

### Defender XDR

Advanced hunting queries require relevant endpoint telemetry to be fully exercised.

### Parsing Error Investigation

Checkov currently reports one parsing error even though:

```text
terraform validate
```

reports the Terraform configuration as valid.

This should be investigated separately rather than incorrectly describing it as a remediated security finding.

---

# 16. Finding Management Process

The project follows this general process when security tooling reports a finding:

```text
Scanner Finding
      ↓
Validate Finding
      ↓
Determine Context
      ↓
Assess Risk
      ↓
True Finding?
   ↙        ↘
 Yes        No / Not Applicable
  ↓               ↓
Remediate       Document
  ↓               ↓
Rescan        Justify Exception
   ↘             ↙
      CI/CD
        ↓
   Prevent Regression
```

The goal is not to achieve a misleading scanner score by suppressing every failure.

The goal is to understand each finding and make an evidence-based security decision.

---

# 17. Lessons Learned

The V1 security review demonstrates several practical security-engineering principles.

### Valid Infrastructure Is Not Necessarily Secure

Terraform validation verifies configuration correctness but does not replace security scanning.

### Scanner Findings Require Analysis

A failed security check should be investigated rather than automatically accepted or suppressed.

### Security Exceptions Should Be Explicit

When a control cannot reasonably be implemented in the current version, the exception should be documented with its rationale and future treatment.

### Security Should Be Shifted Left

Checkov, Trivy, Gitleaks and custom detection validation allow issues to be identified before deployment.

### Security Content Is Software

Detection rules and automation definitions benefit from:

```text
Version Control
Testing
Validation
Code Review
CI/CD
Regression Testing
```

### Automation Requires Guardrails

The ability to automate containment does not mean every response should be automated.

Risk, confidence and business impact must be considered.

---

# 18. V1 Security Posture Summary

The V1 project demonstrates security controls across several layers:

```text
SOURCE CODE
   ↓
Gitleaks

INFRASTRUCTURE CODE
   ↓
Terraform Validation
Checkov
Trivy

CLOUD PLATFORM
   ↓
Network Segmentation
Azure Policy
Defender for Cloud
Private Connectivity

SOFTWARE SUPPLY CHAIN
   ↓
Syft
SBOM
Cosign

SECURITY TELEMETRY
   ↓
Microsoft Sentinel
Defender XDR

DETECTION ENGINEERING
   ↓
Analytics Rules
KQL
MITRE ATT&CK
Regression Testing

SECURITY OPERATIONS
   ↓
Automation Rules
Logic App Playbooks
Threat Hunting
Incident Response
```

Security findings discovered during development are therefore treated as part of a continuous engineering lifecycle rather than as isolated scanner output.