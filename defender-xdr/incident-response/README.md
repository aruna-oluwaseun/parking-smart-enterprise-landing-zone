# Defender XDR Incident Response

This directory documents how Microsoft Defender XDR detections are investigated
and integrated with the wider Parking Smart security-response platform.

## Objective

Defender XDR provides endpoint and identity telemetry that can be used to detect
and investigate suspicious behaviour across devices, users, processes, files,
network connections, and authentication events.

The response process is designed to:

- preserve investigation context;
- correlate related activity across Defender XDR and Microsoft Sentinel;
- enrich incidents with additional threat intelligence;
- reduce unnecessary manual investigation;
- apply deterministic safeguards before automated containment;
- maintain a clear audit trail of response decisions.

## Response Flow

Defender XDR Custom Detection
        ↓
Alert
        ↓
Defender XDR Incident
        ↓
Investigation
        ↓
Evidence Collection
        ↓
Sentinel / SOAR Correlation
        ↓
Automation Rule
        ↓
Logic App
        ↓
Enrichment / Notification / Containment

## Investigation Context

Relevant evidence may include:

- DeviceName
- DeviceId
- AccountName
- ProcessCommandLine
- InitiatingProcessFileName
- SHA1 / SHA256
- RemoteIP
- RemoteUrl
- ProcessId
- ReportId
- authentication context
- related Defender alerts
- Sentinel incident context

## Example Response: Suspicious PowerShell

A PowerShell custom detection may identify suspicious download behaviour.

Investigation should review:

1. The complete PowerShell command line.
2. Parent and initiating processes.
3. User identity.
4. Device involved.
5. File hashes.
6. Remote domains and IP addresses.
7. Network activity surrounding the execution.
8. Related logon activity.
9. Other alerts involving the same user or device.
10. Whether the activity matches approved administrative automation.

Potential response actions include:

- enrich IP/domain/hash indicators;
- notify the SOC;
- create or update the Sentinel incident;
- isolate the device;
- disable or contain a compromised identity;
- escalate for analyst approval.

## Example Response: Suspicious LOLBin Activity

Suspicious execution of utilities such as certutil, mshta, regsvr32, or bitsadmin
should be investigated using process, network, file, and identity context.

The binary itself should not automatically be treated as malicious.

Response decisions should consider:

- command-line arguments;
- remote destinations;
- parent process;
- signed/unsigned files;
- file reputation;
- user privilege level;
- device criticality;
- related alerts and incidents.

## Automated Response Safeguards

Automated actions must not rely solely on an LLM, enrichment provider, or single
detection result.

High-impact actions should pass deterministic checks.

Examples:

- privileged accounts require additional approval;
- emergency/break-glass identities must not be automatically disabled;
- containment requires sufficient confidence;
- missing telemetry should trigger escalation rather than destructive action;
- failed enrichment should not automatically imply malicious activity.

## Integration with Existing SOAR

The existing Sentinel Response-as-Code framework provides:

- IOC enrichment;
- SOC notification;
- incident creation;
- guarded identity containment.

Defender XDR findings can feed into these playbooks rather than creating a
separate response stack.

This provides a common security-response architecture across cloud, identity,
and endpoint detections.

## Detection-to-Response Lifecycle

Threat Hypothesis
        ↓
Advanced Hunting
        ↓
Custom Detection
        ↓
Alert
        ↓
Incident
        ↓
Investigation
        ↓
Enrichment
        ↓
Response Decision
        ↓
Automation / Human Approval
        ↓
Containment
        ↓
Post-Incident Review
        ↓
Detection Improvement