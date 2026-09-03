# Security Operations Runbook

## 1. Purpose

This runbook provides operational guidance for triaging, investigating and responding to security alerts within the Parking Smart Enterprise Cloud Security Platform.

It complements the broader incident-response process documented in:

```text
docs/incident-response.md
```

The incident-response document defines the overall lifecycle.

This runbook defines the practical actions an analyst performs during an investigation.

---

## 2. Security Operations Workflow

The standard investigation workflow is:

```text
Alert / Incident
       ↓
Review Detection
       ↓
Identify Entities
       ↓
Collect Evidence
       ↓
Correlate Activity
       ↓
Threat Hunt
       ↓
Enrich Indicators
       ↓
Determine Verdict
       ↓
Contain if Required
       ↓
Document Findings
       ↓
Close / Escalate
       ↓
Detection Feedback
```

Analysts should avoid making containment decisions based solely on the title or severity of an alert.

Context and supporting evidence must be considered.

---

## 3. Alert Sources

Security events and alerts may originate from:

- Microsoft Sentinel
- Microsoft Defender XDR
- Microsoft Defender for Cloud
- Microsoft Entra ID Sign-in Logs
- Microsoft Entra Audit Logs
- Azure Activity Logs
- Azure Key Vault diagnostic logs
- Endpoint telemetry
- GitHub Actions security scans

---

## 4. Initial Triage Checklist

When an incident is opened, establish the basic context.

Record:

- Incident name
- Detection rule
- Severity
- Detection timestamp
- First observed activity
- Last observed activity
- Affected identity
- Source IP address
- Target resource
- Host/device where applicable
- Authentication result
- Azure operation where applicable
- Related alerts
- MITRE ATT&CK technique
- Relevant automation results

Then answer:

```text
What happened?

Who performed the activity?

What was targeted?

Where did it originate?

Was the action successful?

Is the activity expected?

What happened immediately before and after it?
```

---

## 5. Investigation Classification

During investigation, classify the activity as one of the following:

### True Positive

The detection correctly identified malicious or unauthorized behaviour.

### False Positive

The detection triggered on legitimate activity that should not normally generate an alert.

### Benign Positive

The detection correctly identified the behaviour described by the rule, but the activity was legitimate and expected.

### Suspicious / Inconclusive

There is insufficient evidence to determine whether the activity is malicious.

Additional investigation or escalation is required.

---

# 6. Password Spray Runbook

## Trigger

Sentinel analytics rule:

```text
password-spray.yaml
```

MITRE ATT&CK:

```text
T1110.003 - Password Spraying
```

## Investigation

### Step 1 — Identify the source

Determine:

- Source IP address
- Geographic location where available
- Number of authentication attempts
- Time period
- Targeted accounts

### Step 2 — Review account diversity

Password spraying normally involves attempts against multiple accounts.

Determine whether the activity represents:

```text
One account + many passwords
        ↓
Possible brute force

Many accounts + limited password attempts
        ↓
Possible password spray
```

### Step 3 — Check for successful authentication

Determine whether any targeted account successfully authenticated during or shortly after the attack window.

A successful authentication significantly increases the severity of the investigation.

### Step 4 — Run the related hunt

Use:

```text
hunt/identity/password-spray-followed-by-success.kql
```

The objective is to identify accounts where suspicious failures were followed by successful authentication.

### Step 5 — Enrich the source IP

Review available information such as:

- Reputation
- Hosting provider
- Geographic information
- Known malicious activity

### Step 6 — Determine verdict

Possible outcomes:

```text
Scanning / unsuccessful attack
False positive
Expected authentication activity
Likely credential attack
Confirmed account compromise
```

## Response

For unsuccessful activity:

- Document findings
- Continue monitoring
- Consider blocking confirmed malicious infrastructure where appropriate

For suspected compromise:

- Review the affected identity
- Review subsequent authentication
- Review privilege changes
- Revoke active sessions where appropriate
- Reset or rotate credentials
- Disable the account if justified

High-impact containment should follow appropriate authorization and confidence controls.

---

# 7. Impossible Travel Runbook

## Trigger

```text
impossible-travel.yaml
```

## Objective

Determine whether geographically inconsistent authentication activity represents account compromise or legitimate user behaviour.

## Investigation

Review:

- User identity
- Source IP addresses
- Geographic locations
- Authentication timestamps
- Device information
- Authentication method
- VPN/proxy usage
- Previous sign-in history

Consider legitimate explanations such as:

- Corporate VPN
- Mobile carrier routing
- Cloud proxy
- Security gateway
- Known travel

Correlate with:

- Failed authentication activity
- Token replay alerts
- MFA changes
- Privilege changes
- Other incidents involving the same identity

## Escalate When

Escalate when the activity cannot reasonably be explained and there is supporting evidence of identity compromise.

---

# 8. Privileged Role Assignment Runbook

## Trigger

```text
privileged-role-assignment.yaml
```

## Investigation

Identify:

- Account receiving the privilege
- Identity performing the assignment
- Role assigned
- Assignment timestamp
- Whether the change was approved
- Previous privileges of the account

Run:

```text
hunt/identity/privileged-role-assignment-followed-by-signin.kql
```

Determine whether the newly privileged identity subsequently authenticated or performed sensitive operations.

## Suspicious Indicators

Examples include:

- Unexpected Global Administrator assignment
- Privilege assigned by an unusual administrator
- Guest account receiving elevated privileges
- Privilege assignment followed immediately by sensitive activity
- Assignment outside an approved change window

## Response

If unauthorized:

- Remove the privilege
- Investigate the assigning identity
- Review subsequent activity
- Determine whether additional accounts were modified

---

# 9. Guest User Privilege Escalation Runbook

## Trigger

```text
guest-user-privilege-escalation.yaml
```

## Investigation

Determine:

- Guest identity
- Role assigned
- Identity performing the assignment
- Business justification
- Previous guest activity
- Subsequent authentication and Azure activity

Guest privilege escalation should receive additional scrutiny because external identities can introduce a different trust boundary.

## Response

If unauthorized:

- Remove elevated access
- Investigate the guest identity
- Investigate the assigning identity
- Review resources accessed after elevation

---

# 10. Service Principal Creation Runbook

## Trigger

```text
service-principal-creation.yaml
```

## Investigation

Determine:

- Creating identity
- Service principal/application name
- Creation timestamp
- Credentials added
- Permissions assigned
- Role assignments
- Subsequent activity

Use:

```text
hunt/identity/suspicious-service-principal-activity.kql
```

## Suspicious Indicators

Examples include:

- Creation by an unexpected identity
- High privileges immediately assigned
- Credentials created shortly after compromise indicators
- Service principal used immediately for sensitive operations

## Response

If malicious:

- Disable/remove the unauthorized identity
- Revoke credentials
- Remove role assignments
- Investigate the creator
- Review resources accessed

---

# 11. Key Vault Access Spike Runbook

## Trigger

```text
keyvault-access-spike.yaml
```

## Objective

Determine whether unusually high Key Vault access represents legitimate application behaviour or credential harvesting.

## Investigation

Identify:

- Requesting identity
- Key Vault
- Secrets accessed
- Number of requests
- Source
- Time window
- Recent role assignments

Run:

```text
hunt/azure/keyvault-secret-access-after-role-change.kql
```

Look specifically for:

```text
Role Assignment
      ↓
Key Vault Access
      ↓
Large Number of Secret Requests
```

This sequence may indicate privilege escalation followed by credential access.

## Response

If unauthorized:

- Contain the identity
- Remove unauthorized permissions
- Rotate potentially exposed secrets
- Review subsequent use of those credentials
- Investigate related Azure resources

---

# 12. NSG Modification Runbook

## Trigger

```text
nsg-modified.yaml
```

## Investigation

Determine:

- NSG modified
- Identity performing the change
- Rule added/removed/changed
- Source/destination ranges
- Ports exposed
- Time of modification
- Change authorization

Compare the deployed configuration against the expected Terraform configuration.

## High-Risk Changes

Examples include:

```text
0.0.0.0/0 → sensitive management port

Removal of restrictive rule

Unexpected inbound Internet access

Broad internal network access
```

## Response

If unauthorized:

- Restore the approved configuration
- Investigate the modifying identity
- Determine whether the exposed path was used
- Review related Azure activity

---

# 13. Azure Policy Deletion Runbook

## Trigger

```text
azure-policy-deleted.yaml
```

## Investigation

Determine:

- Policy or assignment affected
- Identity performing the action
- Time of deletion
- Approved change record if applicable
- Resources created or modified afterwards

Run:

```text
hunt/azure/security-control-tampering.kql
```

The objective is to determine whether the attacker weakened governance before making additional infrastructure changes.

## Response

If unauthorized:

- Restore the required policy
- Investigate the responsible identity
- Review infrastructure changes made during the exposure window

---

# 14. Diagnostic Settings Deletion Runbook

## Trigger

```text
diagnostic-settings-deleted.yaml
```

## Risk

Deletion of diagnostic settings may represent defence evasion because telemetry could stop reaching the security platform.

## Investigation

Identify:

- Resource affected
- Actor
- Timestamp
- Logging destination
- Other security-control modifications

Determine whether suspicious activity occurred shortly after telemetry was disabled.

## Response

- Restore diagnostic configuration
- Validate telemetry flow
- Investigate the actor
- Review activity surrounding the logging gap

---

# 15. Storage Public Access Runbook

## Trigger

```text
storage-public-access-enabled.yaml
```

## Investigation

Determine:

- Storage account
- Identity making the change
- Previous configuration
- New exposure level
- Data stored in the account
- Whether anonymous/public access occurred

## Response

If unauthorized:

- Restore private access
- Review access logs
- Determine whether data was accessed
- Investigate the responsible identity

---

# 16. Key Vault Firewall Modification Runbook

## Trigger

```text
keyvault-firewall-disabled.yaml
```

## Investigation

Determine:

- Key Vault affected
- Network configuration before/after
- Identity performing the change
- Whether public access became possible
- Secret access during the exposure period

Correlate with:

- Key Vault Access Spike
- Excessive Secret Access
- Role-assignment activity

## Response

Restore the approved secure configuration and investigate access occurring during the exposure window.

---

# 17. Suspicious PowerShell Runbook

## Trigger

```text
suspicious-powershell.yaml
```

## Investigation

Identify:

- Device
- User
- Process
- Command line
- Parent process
- Network connections
- Download activity
- Related alerts

Use Defender XDR hunting content including:

```text
defender-xdr/advanced-hunting/powershell-network-correlation.kql
```

and:

```text
defender-xdr/advanced-hunting/suspicious-process-network-chain.kql
```

Additional hunt:

```text
hunt/endpoint/suspicious-powershell-download-execution.kql
```

## Suspicious Behaviour

Examples include:

- Encoded commands
- Remote payload downloads
- Unexpected network connections
- Suspicious parent-child process relationships
- Execution from unusual locations

## Response

Depending on confidence:

- Investigate the endpoint
- Identify downloaded artifacts
- Block confirmed malicious indicators
- Isolate the endpoint where justified
- Reset compromised credentials
- Escalate confirmed compromise

---

# 18. Security Configuration Change Runbook

## Trigger

```text
security-configuration-change.yaml
```

## Investigation

Determine:

- Security control changed
- Actor
- Previous configuration
- New configuration
- Change authorization
- Related activity

Use:

```text
hunt/azure/security-control-tampering.kql
```

Multiple security-control changes within a short period should increase investigation priority.

---

# 19. IOC Enrichment Procedure

When an incident contains an external indicator such as an IP address:

1. Extract the indicator.
2. Validate its format.
3. Check available threat-intelligence sources.
4. Determine reputation.
5. Review geographic/network ownership information.
6. Correlate the indicator with other events.
7. Add relevant context to the investigation.

The V1 platform includes:

```text
sentinel/playbooks/enrich-ioc.json
```

Enrichment alone should not be treated as proof that an incident is malicious.

---

# 20. Automation Procedure

Four V1 scenarios have Sentinel automation-rule definitions:

- Password Spray
- Impossible Travel
- Guest User Privilege Escalation
- Key Vault Access Spike

When automation executes, analysts should verify:

```text
Did the automation trigger?
        ↓
Did the playbook execute successfully?
        ↓
Was useful context added?
        ↓
Was any response action performed?
        ↓
Was the action appropriate?
```

Automation failures should be investigated because failed SOAR workflows may leave incidents without expected enrichment or response.

---

# 21. Containment Decision Matrix

| Confidence | Impact | Recommended Approach |
|---|---|---|
| Low | Low | Monitor / gather context |
| Low | High | Escalate before action |
| Medium | Low | Enrich / investigate |
| Medium | High | Analyst validation before containment |
| High | Low | Automated low-risk response may be appropriate |
| High | High | Rapid containment with appropriate guardrails |

The matrix is guidance rather than an automatic decision engine.

---

# 22. Evidence Checklist

Before closing or escalating an investigation, record relevant evidence.

Where applicable:

- User
- IP address
- Device
- Resource
- Timestamp
- Detection
- MITRE technique
- Authentication outcome
- Azure operation
- Related alerts
- Relevant hunting results
- IOC enrichment
- Containment actions
- Analyst conclusion

---

# 23. Escalation Criteria

Escalate when there is evidence of:

- Successful account compromise
- Privileged identity compromise
- Unauthorized privilege escalation
- Credential or secret theft
- Malicious persistence
- Security-control tampering
- Significant public exposure
- Endpoint compromise
- Lateral movement
- Multiple correlated detections
- Uncertain activity with potentially severe impact

---

# 24. Incident Closure

Before closing an incident:

```text
Was the root cause understood?

Were affected assets identified?

Was containment completed?

Were compromised credentials rotated?

Were security controls restored?

Was malicious persistence removed?

Was monitoring restored?

Were relevant findings documented?

Does the detection require tuning?

Is a new detection or hunt required?
```

The incident should include a clear final classification and investigation summary.

---

# 25. Detection Feedback

Security operations feeds directly into detection engineering.

For every significant incident, consider:

- Did the detection fire?
- Did it fire early enough?
- Was severity appropriate?
- Were important entities captured?
- Did the query produce false positives?
- Was malicious activity missed?
- Did automation work?
- Would additional correlation improve confidence?

Where detection logic changes:

```text
Detection Update
      ↓
Regression Test
      ↓
Content Validation
      ↓
CI/CD
      ↓
Deployment
```

The password-spray regression suite provides the initial V1 example of this process.

---

# 26. V1 Operational Limitations

This runbook describes the intended operational process and the security content implemented in the repository.

Some procedures require the final live Azure environment and production-like telemetry before they can be fully exercised.

In particular:

- Not every detection has an automation rule.
- High-impact containment is not intended to operate blindly.
- IOC enrichment requires appropriate external intelligence integration.
- Defender XDR investigations require relevant endpoint telemetry.
- Detection thresholds require tuning against realistic activity.
- Response playbooks require runtime validation after deployment.

These limitations should be considered when demonstrating the V1 platform.

---

# 27. Runbook Summary

The operational model is:

```text
DETECT
   ↓
TRIAGE
   ↓
INVESTIGATE
   ↓
CORRELATE
   ↓
HUNT
   ↓
ENRICH
   ↓
DECIDE
   ↓
CONTAIN
   ↓
RECOVER
   ↓
DOCUMENT
   ↓
TUNE
```

The objective is to combine analyst judgement, detection engineering and controlled automation rather than relying entirely on either manual investigation or automatic response.