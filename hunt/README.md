# Microsoft Sentinel Threat Hunting

This directory contains proactive threat-hunting queries for the Parking Smart
Enterprise Landing Zone.

The hunting library complements the automated Microsoft Sentinel analytics
rules under `sentinel/analytics-rules` and the KQL detection content under
`detections/sentinel`.

## Objectives

The hunting capability is designed to:

- proactively identify attacker behaviour that may not generate an alert;
- investigate suspicious activity across identity, Azure and endpoint telemetry;
- correlate multiple events into potential attack sequences;
- map hunting hypotheses to MITRE ATT&CK;
- identify opportunities for new detections;
- improve existing detections based on hunting findings.

## Hunting Methodology

Each hunt follows a hypothesis-driven process:

1. Define an attacker behaviour or security hypothesis.
2. Identify the telemetry required to investigate it.
3. Query and correlate the relevant events using KQL.
4. Investigate users, identities, IP addresses, devices and resources involved.
5. Identify expected administrative or operational activity.
6. Determine whether the behaviour represents malicious or suspicious activity.
7. Document findings and potential false positives.
8. Promote repeatable high-confidence behaviour into an automated detection where appropriate.

## Hunting Library

### Identity

#### Password Spray Followed by Successful Sign-in

**File:** `identity/password-spray-followed-by-success.kql`

**Hypothesis:**  
An attacker may perform repeated failed authentication attempts and subsequently
successfully authenticate after identifying valid credentials.

**MITRE ATT&CK:**
- T1110.003 - Password Spraying
- T1078 - Valid Accounts

**Telemetry:** Microsoft Entra ID `SigninLogs`

**Investigation:** Review the source IP addresses, affected account, geographic
location, application accessed, Conditional Access result and subsequent activity.

**Potential false positives:** Users repeatedly entering an incorrect password,
shared egress IP addresses, application authentication problems or legitimate
password changes.

---

#### Suspicious Service Principal Activity

**File:** `identity/suspicious-service-principal-activity.kql`

**Hypothesis:**  
An attacker may create or modify a service principal and subsequently use that
identity for persistence or unauthorized cloud access.

**MITRE ATT&CK:**
- T1136.003 - Create Account: Cloud Account
- T1098 - Account Manipulation
- T1078.004 - Valid Accounts: Cloud Accounts

**Telemetry:** Microsoft Entra ID `AuditLogs` and service-principal sign-in telemetry.

**Investigation:** Identify who created or modified the service principal, review
credential changes, permissions, sign-in IP addresses and resources accessed.

**Potential false positives:** CI/CD identities, Terraform deployments,
application onboarding and legitimate service-principal credential rotation.

---

#### Privileged Role Assignment Followed by Sign-in

**File:** `identity/privileged-role-assignment-followed-by-signin.kql`

**Hypothesis:**  
A compromised identity may receive privileged access and subsequently authenticate
and use that privilege.

**MITRE ATT&CK:**
- T1098 - Account Manipulation
- T1078.004 - Valid Accounts: Cloud Accounts

**Telemetry:** Microsoft Entra ID `AuditLogs` and `SigninLogs`

**Investigation:** Determine who performed the role assignment, which role was
assigned, whether the change was approved and what the target identity did afterwards.

**Potential false positives:** Approved administrative changes, PIM activation,
emergency access procedures and legitimate onboarding.

## Azure Control Plane

### Security Control Tampering

**File:** `azure/security-control-tampering.kql`

**Hypothesis:**  
An attacker with Azure permissions may attempt to weaken monitoring, networking,
policy or other security controls to reduce visibility or facilitate subsequent activity.

**MITRE ATT&CK:**
- T1562.001 - Impair Defenses: Disable or Modify Tools
- T1562.007 - Impair Defenses: Disable or Modify Cloud Firewall

**Telemetry:** `AzureActivity`

**Investigation:** Review the caller, source IP, affected resource, change operation,
related activity and whether the modification corresponds to an approved change.

**Potential false positives:** Terraform deployments, infrastructure maintenance,
network changes and approved security-policy updates.

---

### Suspicious Resource Creation After Role Change

**File:** `azure/suspicious-resource-creation-after-role-change.kql`

**Hypothesis:**  
An attacker may obtain elevated permissions and subsequently create cloud
infrastructure for persistence, staging or further compromise.

**MITRE ATT&CK:**
- T1098 - Account Manipulation
- T1136.003 - Create Account: Cloud Account
- T1578 - Modify Cloud Compute Infrastructure

**Telemetry:** Microsoft Entra ID `AuditLogs` and `AzureActivity`

**Investigation:** Review the role change, initiating administrator, created
resource, source IP, resource configuration and subsequent activity.

**Potential false positives:** Terraform deployments, approved infrastructure
changes, developer provisioning and automated platform operations.

---

### Key Vault Secret Access After Role Change

**File:** `azure/keyvault-secret-access-after-role-change.kql`

**Hypothesis:**  
An attacker may obtain additional privileges and then access Key Vault to retrieve
credentials or other sensitive information.

**MITRE ATT&CK:**
- T1098 - Account Manipulation
- T1555 - Credentials from Password Stores
- T1078.004 - Valid Accounts: Cloud Accounts

**Telemetry:** Microsoft Entra ID `AuditLogs` and Azure Key Vault diagnostic logs.

**Investigation:** Review the identity receiving access, secrets or keys accessed,
source IP, role change, frequency of access and subsequent resource activity.

**Potential false positives:** Application deployments, secret rotation,
administrative troubleshooting and legitimate workload secret retrieval.

## Endpoint

### Suspicious PowerShell Download and Execution

**File:** `endpoint/suspicious-powershell-download-execution.kql`

**Hypothesis:**  
An attacker may use PowerShell to download, decode or execute malicious scripts
and payloads.

**MITRE ATT&CK:**
- T1059.001 - PowerShell
- T1105 - Ingress Tool Transfer

**Telemetry:** Microsoft Defender for Endpoint `DeviceProcessEvents`

**Investigation:** Review the complete command line, parent process, user, device,
download destination, URLs, file hashes and subsequent child processes.

**Potential false positives:** Administrative scripts, software deployment,
configuration management and legitimate automation.

---

### Suspicious LOLBin Execution

**File:** `endpoint/suspicious-lolbin-execution.kql`

**Hypothesis:**  
An attacker may abuse trusted Windows binaries to download content, execute
malicious code or proxy execution while blending into legitimate activity.

**MITRE ATT&CK:**
- T1218 - System Binary Proxy Execution
- T1105 - Ingress Tool Transfer

**Telemetry:** Microsoft Defender for Endpoint `DeviceProcessEvents`

**Investigation:** Review command-line arguments, parent process, user, remote
URLs, downloaded files, hashes and subsequent processes.

**Potential false positives:** Legitimate administration, software installation,
enterprise management tools and troubleshooting.

## Hunt-to-Detection Lifecycle

Threat hunts are not automatically converted into alerts.

A hunt should be considered for promotion to a Microsoft Sentinel analytics rule
when:

- the behaviour has meaningful security impact;
- the required telemetry is consistently available;
- the behaviour can be identified with acceptable precision;
- legitimate activity can be filtered or baselined;
- the query performs efficiently over the required time window;
- the expected response can be clearly defined.

The lifecycle is:

Threat Hypothesis → Hunt → Investigation → Findings → Tuning → Detection Candidate
→ Analytics Rule → Monitoring → Continuous Improvement

## Required Telemetry

The complete hunting library may require:

- Microsoft Entra ID Sign-in Logs;
- Microsoft Entra ID Audit Logs;
- Azure Activity Logs;
- Azure Key Vault diagnostic logs;
- Microsoft Defender for Endpoint DeviceProcessEvents.

Queries requiring telemetry that is not currently ingested should be treated as
documented detection/hunting requirements until the appropriate data connector
is enabled.

## Relationship to Detection-as-Code

Threat hunting and Detection-as-Code serve different purposes within this project.

Hunting is analyst-driven and hypothesis-based. Detection rules continuously
evaluate telemetry and automatically generate alerts when defined conditions are met.

High-confidence findings from the hunting process can therefore become candidates
for the Detection-as-Code pipeline.