# Microsoft Defender XDR Engineering

This directory contains the Defender XDR engineering capability for the
Parking Smart Enterprise Security Platform.

The objective is to demonstrate how endpoint and identity telemetry can be
used for threat hunting, behavioural correlation, custom detection engineering,
incident investigation, and integration with Microsoft Sentinel and SOAR.

## Architecture

Microsoft Defender XDR
        |
        +-- DeviceProcessEvents
        +-- DeviceNetworkEvents
        +-- DeviceLogonEvents
        +-- DeviceFileEvents
        +-- Other XDR telemetry
                |
                v
        Advanced Hunting
                |
                v
        Behaviour Correlation
                |
                v
        Detection Candidate
                |
                v
        Custom Detection
                |
                v
        Alert / Incident
                |
                v
        Investigation
                |
                v
        Microsoft Sentinel
                |
                v
        Response-as-Code / SOAR
                |
        +-------+---------+
        |                 |
        v                 v
   Enrichment        Notification
        |
        v
   Guarded Containment

## Advanced Hunting

The `advanced-hunting` directory contains hypothesis-driven investigations
using Defender XDR telemetry.

Current hunts include:

### PowerShell Network Correlation

Correlates suspicious PowerShell execution from `DeviceProcessEvents` with
subsequent outbound activity from `DeviceNetworkEvents`.

This provides stronger behavioural context than detecting PowerShell execution
alone.

### Suspicious Process Network Chain

Correlates suspicious LOLBin execution with subsequent network activity.

Examples include abuse of:

- certutil
- bitsadmin
- mshta
- rundll32
- regsvr32

### Credential Access Behaviour

Correlates successful endpoint authentication from `DeviceLogonEvents` with
subsequent credential-access behaviour from `DeviceProcessEvents`.

This provides identity-to-endpoint behavioural correlation.

## Custom Detection Engineering

The `custom-detections` directory contains hunting behaviours that have been
refined into repeatable detection candidates.

Current candidates include:

- suspicious PowerShell download activity;
- suspicious LOLBin network activity.

Custom detections aim to provide sufficiently reliable signals for operational
alerting while retaining the richer hunting queries for investigation.

## Detection Engineering Principle

Not every hunting query should become a production detection.

The lifecycle used is:

Threat Hypothesis
        |
        v
Advanced Hunting
        |
        v
Suspicious Behaviour
        |
        v
Detection Candidate
        |
        v
Validation
        |
        v
Tuning
        |
        v
Custom Detection
        |
        v
Operational Monitoring
        |
        v
Continuous Improvement

## Correlation over Individual Indicators

The Defender XDR capability prioritises behavioural correlation.

For example:

PowerShell execution alone
        =
Low confidence

PowerShell execution
        +
Suspicious command line
        +
Outbound network connection
        =
Higher confidence

This reduces dependence on individual indicators that attackers can easily
change.

## Relationship with Microsoft Sentinel

Defender XDR complements rather than replaces Microsoft Sentinel within this
project.

Defender XDR provides deep endpoint and identity investigation capabilities,
while Sentinel provides central SIEM correlation, analytics, incident
management, and SOAR orchestration.

The combined architecture supports:

Endpoint
   +
Identity
   +
Azure
   +
Threat Intelligence
        |
        v
Cross-domain Detection
        |
        v
Incident
        |
        v
Automated Response

## Response Integration

Defender XDR incidents can use the existing Sentinel Response-as-Code
capabilities for:

- IOC enrichment;
- security-team notification;
- incident creation and enrichment;
- guarded identity containment.

High-impact actions should be protected by deterministic controls and human
approval where appropriate.

See:

`incident-response/README.md`

for the response workflow and investigation methodology.

## Repository Structure

defender-xdr/
|
+-- README.md
|
+-- advanced-hunting/
|   +-- powershell-network-correlation.kql
|   +-- suspicious-process-network-chain.kql
|   +-- credential-access-behaviour.kql
|
+-- custom-detections/
|   +-- suspicious-powershell-download.kql
|   +-- lolbin-network-activity.kql
|
+-- incident-response/
    +-- README.md

## Security Engineering Outcome

This capability demonstrates:

- Microsoft Defender XDR Advanced Hunting;
- KQL-based endpoint investigation;
- cross-table telemetry correlation;
- behavioural detection engineering;
- custom-detection development;
- MITRE ATT&CK-aligned threat analysis;
- incident-response design;
- SIEM/XDR integration;
- SOAR integration;
- guarded automated response.