# Security Operations Runbook

## Purpose

This runbook defines how security alerts generated within the Parking Smart Azure environment are triaged, investigated, contained, and closed.

## Alert Sources

Alerts may originate from:

- Microsoft Sentinel
- Microsoft Defender for Cloud
- Azure Activity Logs
- Microsoft Entra ID Sign-in Logs
- Azure Key Vault diagnostic logs
- GitHub Actions security scans

## Severity Levels

### Critical
Examples:
- Privileged account compromise
- Security control deletion
- Large-scale secret access
- Confirmed malicious activity

Action:
- Immediate investigation
- Escalate to incident
- Containment may be automated

### High
Examples:
- Privileged role assignment
- Suspicious PowerShell execution
- Key Vault access spike

Action:
- Investigate immediately
- Validate user and source activity
- Trigger playbook if confirmed

### Medium
Examples:
- Multiple failed authentication attempts
- Impossible travel
- Unusual resource creation

Action:
- Investigate context
- Correlate with other alerts
- Escalate if suspicious

## Investigation Workflow

1. Review the Sentinel incident.
2. Identify affected user, IP address, resource, or application.
3. Review related events in Log Analytics.
4. Check recent Azure Activity Logs.
5. Review authentication activity.
6. Identify related alerts.
7. Determine whether the activity is expected or malicious.

## IOC Enrichment

For suspicious IP addresses:

1. Extract the IP from the Sentinel incident.
2. Perform threat-intelligence lookup.
3. Review geographic location.
4. Review reputation information.
5. Add enrichment information to the incident.

## Containment

Depending on the incident:

- Disable compromised Entra ID account.
- Revoke privileged access.
- Rotate credentials or secrets.
- Restrict suspicious network access.
- Disable compromised service principal.
- Isolate affected workload.

High-impact containment actions should normally require analyst approval.

## Eradication

- Remove unauthorised access.
- Delete malicious resources.
- Remove persistence mechanisms.
- Rotate credentials.
- Correct insecure configuration.
- Rebuild affected workloads where necessary.

## Recovery

- Restore normal access.
- Validate system integrity.
- Re-enable workloads.
- Monitor for recurrence.
- Confirm security controls are functioning.

## Post-Incident Review

After closure:

- Review detection effectiveness.
- Update KQL logic if required.
- Add new indicators.
- Improve automation.
- Update Terraform or Azure Policy controls.
- Document lessons learned.

## Detection-to-Response Flow

Detection-as-Code
      ↓
Microsoft Sentinel Analytics Rule
      ↓
Sentinel Incident
      ↓
Analyst Investigation
      ↓
Logic App Playbook
      ↓
Containment / Notification / Enrichment
      ↓
Recovery
      ↓
Lessons Learned