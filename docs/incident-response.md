# Incident Response

## 1. Purpose

This document defines the incident-response lifecycle for the Parking Smart Enterprise Cloud Security Platform.

The process integrates Microsoft Sentinel, Defender XDR, threat hunting, automation rules and Logic App playbooks to support detection, investigation, containment, recovery and continuous improvement.

The objective is to provide a repeatable process while ensuring that high-impact automated actions are appropriately controlled.

---

## 2. Incident Response Lifecycle

The platform follows the following operational lifecycle:

```text
Security Telemetry
        ↓
Detection
        ↓
Alert / Sentinel Incident
        ↓
Triage
        ↓
Investigation and Scoping
        ↓
Enrichment
        ↓
Containment Decision
        ↓
Remediation
        ↓
Recovery
        ↓
Post-Incident Review
        ↓
Detection Tuning
```

Incident response is therefore connected directly to detection engineering rather than treated as a separate process.

---

## 3. Detection and Alert Generation

Security telemetry may originate from sources including:

- Microsoft Entra ID
- Azure Activity Logs
- Azure Key Vault diagnostics
- Azure infrastructure
- Endpoint telemetry
- Microsoft Defender XDR

Microsoft Sentinel analytics rules evaluate relevant telemetry using KQL-based detection logic.

Examples include:

- Password Spray
- Impossible Travel
- Token Replay
- Privileged Role Assignment
- Guest User Privilege Escalation
- Key Vault Access Spike
- Azure Policy Deleted
- Diagnostic Settings Deleted
- NSG Modified
- Suspicious PowerShell Execution

When rule conditions are satisfied, the activity can generate a security alert and associated Sentinel incident.

---

## 4. Triage

The first objective during triage is to determine whether the activity requires further investigation.

The analyst reviews:

- Detection name
- Severity
- Time of activity
- User or service identity
- Source IP address
- Target resource
- Related entities
- Authentication result
- Azure operation
- Previous alerts
- Relevant contextual information

The analyst determines whether the activity appears to be:

```text
True Positive
False Positive
Benign Positive
Requires Further Investigation
```

Priority is influenced by both severity and business/security context.

---

## 5. Investigation and Scoping

If further investigation is required, the analyst determines the scope of the activity.

Questions include:

- Which identity was involved?
- Which resources were accessed?
- Where did the activity originate?
- Were privileges modified?
- Were secrets accessed?
- Were additional accounts affected?
- Did the attacker create new resources?
- Were security controls modified?
- Did suspicious activity occur before or after the original alert?
- Is there evidence of persistence or lateral movement?

Microsoft Sentinel and Defender XDR can be used together to investigate related activity.

---

## 6. Threat Hunting

Threat-hunting queries complement scheduled detections.

The repository contains hunting content covering:

### Identity

- Password Spray Followed by Success
- Privileged Role Assignment Followed by Sign-in
- Suspicious Service Principal Activity

### Azure

- Key Vault Secret Access After Role Change
- Security Control Tampering
- Suspicious Resource Creation After Role Change

### Endpoint

- Suspicious LOLBin Execution
- Suspicious PowerShell Download Execution

These queries allow analysts to investigate behaviour extending beyond the original alert.

---

## 7. Enrichment

Incident enrichment adds context that helps the analyst determine the appropriate response.

Potential enrichment information includes:

- IP reputation
- Identity information
- Resource information
- Related incidents
- Authentication history
- Privilege information
- IOC context

The V1 repository includes an IOC-enrichment playbook pattern:

```text
sentinel/playbooks/enrich-ioc.json
```

Enrichment is particularly suitable for automation because it improves analyst context without immediately changing the environment.

---

## 8. Containment Decision

Containment depends on the confidence and potential impact of the incident.

Examples include:

| Scenario | Possible Response |
|---|---|
| Suspicious IP | Enrich and investigate |
| Password spray | Investigate affected accounts and source |
| Compromised identity | Revoke access / disable account where justified |
| Unauthorized privilege assignment | Remove unauthorized privilege |
| Exposed credential | Rotate credential |
| Security-control tampering | Restore secure configuration |
| Malicious endpoint activity | Isolate or investigate endpoint |
| Public resource exposure | Restore network restrictions |

High-impact containment should not be triggered solely because an alert exists.

---

## 9. Security Automation

The platform separates three concepts:

```text
Analytics Rule
      ↓
Detects suspicious activity

Automation Rule
      ↓
Determines automated response behaviour

Logic App Playbook
      ↓
Performs the response action
```

V1 contains four Sentinel automation-rule definitions covering:

- Password Spray
- Impossible Travel
- Guest User Privilege Escalation
- Key Vault Access Spike

Automation definitions are stored under:

```text
sentinel/automation-rules/
```

---

## 10. Response Playbooks

The V1 platform contains four response playbook patterns.

### Notify Security Team

```text
sentinel/playbooks/notify-teams.json
```

Purpose:

Notify security personnel when an incident requires attention.

---

### IOC Enrichment

```text
sentinel/playbooks/enrich-ioc.json
```

Purpose:

Enrich indicators such as suspicious IP addresses with additional context.

---

### Create Incident

```text
sentinel/playbooks/create-incident.json
```

Purpose:

Support automated incident creation or workflow orchestration.

---

### Disable Account

```text
sentinel/playbooks/disable-account.json
```

Purpose:

Provide a containment pattern for a confirmed or sufficiently high-confidence compromised identity.

Account disabling is considered a high-impact action and should be protected by appropriate approval or confidence controls.

---

## 11. Automation Safety

SOAR automation can itself create operational risk.

For example, automatically disabling a legitimate employee account because of a false-positive alert could cause business disruption.

The platform therefore applies the following principle:

```text
Low-Risk Action
     ↓
Automate

High-Impact Action
     ↓
Validate / Approve
     ↓
Contain
```

Examples of low-risk automation include:

- IOC enrichment
- Security-team notification
- Incident tagging
- Context collection

Examples of higher-impact actions include:

- Disabling identities
- Revoking sessions
- Removing privileges
- Isolating endpoints
- Changing production infrastructure

These actions require stronger confidence and appropriate guardrails.

---

## 12. Containment

Containment aims to prevent further malicious activity while preserving sufficient evidence for investigation.

Potential containment actions include:

- Disable compromised accounts
- Revoke active sessions
- Remove unauthorized privileges
- Rotate exposed credentials
- Restore network restrictions
- Restore deleted security controls
- Block malicious indicators
- Isolate affected workloads where appropriate

Containment should be proportional to the confidence and severity of the incident.

---

## 13. Eradication

After containment, the underlying cause of the incident must be removed.

Examples include:

- Removing malicious credentials
- Removing unauthorized service principals
- Reverting malicious infrastructure changes
- Removing unauthorized role assignments
- Patching vulnerable workloads
- Removing malicious artifacts
- Correcting insecure configurations

The objective is to ensure the attacker cannot regain access through the same mechanism.

---

## 14. Recovery

Recovery restores affected services and identities to a known secure state.

Activities may include:

- Re-enable legitimate accounts
- Restore approved infrastructure configuration
- Validate Azure Policy
- Validate diagnostic settings
- Confirm network restrictions
- Verify Key Vault configuration
- Validate workloads
- Increase monitoring temporarily

Infrastructure managed by Terraform can be compared against the intended configuration to help identify unauthorized configuration drift.

---

## 15. Post-Incident Review

After the incident is resolved, the security team performs a review.

Questions include:

- What happened?
- How was initial access obtained?
- Which assets were affected?
- Which controls worked?
- Which controls failed?
- Did the detection trigger early enough?
- Was the severity appropriate?
- Was the response effective?
- Did automation help?
- Did automation introduce risk?
- Could the incident have been prevented?
- Are additional detections required?

The outcome feeds back into security engineering.

---

## 16. Detection Feedback Loop

Incident response provides feedback to detection engineering.

```text
Incident
   ↓
Investigation
   ↓
Detection Performance Review
   ↓
False Positive / False Negative Analysis
   ↓
Detection Logic Adjustment
   ↓
Regression Testing
   ↓
CI Validation
   ↓
Updated Detection
```

For example, if password-spray investigations show that the threshold generates excessive false positives, the detection can be tuned and the existing regression tests rerun before the updated rule is accepted.

This creates a continuous improvement cycle.

---

## 17. Example: Password Spray Incident

An example response workflow is:

```text
Multiple failed authentication attempts
                ↓
Password Spray Analytics Rule
                ↓
Sentinel Alert / Incident
                ↓
Automation Rule
                ↓
IOC Enrichment
                ↓
SOC Analyst Triage
                ↓
Review:
- Source IP
- Target accounts
- Failure count
- Authentication history
                ↓
Run Password Spray Followed by Success Hunt
                ↓
Was an account successfully accessed?
        ┌───────┴────────┐
        │                │
       NO               YES
        │                │
Monitor / Block     Investigate Account
Source as needed          ↓
                   Containment Decision
                          ↓
                 Revoke / Disable if justified
                          ↓
                     Recovery
                          ↓
                 Detection Review
```

This demonstrates the relationship between detection engineering, threat hunting, SOC investigation and security automation.

---

## 18. Example: Key Vault Access Spike

```text
Abnormal secret-access activity
             ↓
Key Vault Access Spike Detection
             ↓
Sentinel Incident
             ↓
Automation Rule
             ↓
Enrichment
             ↓
Identify Requesting Identity
             ↓
Check Recent Role Changes
             ↓
Run Key Vault Hunting Query
             ↓
Determine Whether Access Was Authorized
             ↓
Contain Identity / Rotate Secrets if Required
             ↓
Post-Incident Review
```

This scenario is particularly important because credential theft may allow an attacker to move from one compromised identity or workload into additional systems.

---

## 19. Evidence Preservation

During investigation, relevant evidence should be preserved where possible.

Examples include:

- Sentinel incident details
- Authentication logs
- Audit logs
- Azure Activity Logs
- Key Vault diagnostics
- Defender XDR telemetry
- Source IP addresses
- Timestamps
- User and service identities
- Resource identifiers
- Infrastructure changes

Evidence should be collected before destructive remediation where practical.

---

## 20. Incident Classification

Incidents can be broadly prioritized using:

| Priority | Description |
|---|---|
| Low | Suspicious activity with limited impact or confidence |
| Medium | Credible security event requiring investigation |
| High | Likely compromise or significant security-control violation |
| Critical | Confirmed compromise with substantial business or security impact |

Severity should be adjusted using investigation context rather than relying only on the original analytics-rule severity.

---

## 21. Roles and Responsibilities

### SOC / Security Analyst

- Triage incidents
- Investigate alerts
- Execute hunting queries
- Collect evidence
- Escalate confirmed threats

### Detection Engineer

- Develop and maintain detection logic
- Tune detections
- Analyze false positives and false negatives
- Maintain regression tests
- Improve detection coverage

### Security Automation / SOAR Engineer

- Develop automation rules
- Maintain response playbooks
- Implement enrichment workflows
- Add automation guardrails
- Monitor automation effectiveness

### Cloud / Security Engineer

- Remediate infrastructure security issues
- Restore secure configuration
- Support containment
- Improve preventive controls

In a smaller security team, one engineer may perform several of these responsibilities.

---

## 22. V1 Scope and Limitations

The repository demonstrates the incident-response architecture and response-as-code approach.

Current limitations include:

- Live response requires the final Azure deployment and telemetry.
- Some playbooks are implementation patterns rather than fully production-integrated workflows.
- High-impact containment requires appropriate authorization and production guardrails.
- Not every analytics rule has a dedicated automation rule.
- Detection tuning requires realistic operational telemetry.

These limitations are intentionally documented rather than representing design artifacts as fully operational production services.

---

## 23. Incident Response Summary

The V1 incident-response model can be summarized as:

```text
PREVENT
   ↓
DETECT
   ↓
TRIAGE
   ↓
INVESTIGATE
   ↓
ENRICH
   ↓
CONTAIN
   ↓
ERADICATE
   ↓
RECOVER
   ↓
LEARN
   ↓
IMPROVE DETECTIONS
```

The key principle is that incident response, detection engineering and security automation operate as a continuous security-engineering lifecycle.