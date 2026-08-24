# Password Spray Detection Tuning

## Purpose

This document demonstrates how the Password Spray detection is evaluated and
tuned using Detection Engineering principles.

The objective is not simply to reduce alert volume. Tuning should improve
detection precision while preserving sufficient coverage of password-spraying
behaviour.

## Detection Hypothesis

An attacker may attempt authentication against multiple user accounts using a
small number of commonly used passwords to avoid traditional account-lockout
controls.

## MITRE ATT&CK

- T1110.003 - Brute Force: Password Spraying

## Primary Telemetry

Microsoft Entra ID Sign-in Logs (`SigninLogs`)

Useful fields include:

- `TimeGenerated`
- `UserPrincipalName`
- `IPAddress`
- `ResultType`
- `AppDisplayName`
- `Location`
- `ConditionalAccessStatus`

## Initial Detection Strategy

The initial strategy identifies repeated failed authentication activity within
a defined time window.

Important detection dimensions include:

- source IP address;
- number of failed authentication attempts;
- number of targeted accounts;
- time window;
- authentication result.

A password spray is more suspicious when a single source attempts authentication
against multiple accounts rather than repeatedly attacking only one account.

## Example Initial Logic

An initial detection might use:

- 10-minute aggregation window;
- at least 5 failed authentication attempts;
- multiple distinct user accounts;
- common source IP address.

This provides a starting point rather than a permanently fixed threshold.

## Potential True Positives

Examples include:

- one external IP attempting authentication against many users;
- repeated authentication failures followed by successful authentication;
- authentication attempts against privileged accounts;
- password spraying followed by activity from a newly observed location.

## Potential False Positives

Possible legitimate causes include:

- corporate NAT gateways;
- VPN infrastructure;
- misconfigured applications;
- authentication proxies;
- stale credentials stored by applications;
- penetration testing;
- authorised security assessments;
- shared infrastructure generating authentication failures.

## Tuning Workflow

### Step 1 - Establish Baseline

Measure normal authentication behaviour before changing thresholds.

Review:

- failed sign-ins per source IP;
- distinct users targeted per IP;
- applications generating failures;
- known corporate/VPN IP ranges;
- geographic patterns;
- typical authentication failure volume.

### Step 2 - Review Alerts

Classify investigated alerts as:

- True Positive;
- False Positive;
- Benign Positive;
- Unknown.

The reason for each classification should be recorded.

### Step 3 - Identify Noise Patterns

Look for repeated characteristics among false positives.

Example:

A corporate VPN gateway may generate failed authentication events for many users
from the same public IP address.

Simply increasing the detection threshold could hide real attacks.

A better tuning decision may be to identify the trusted infrastructure and apply
additional context to those events.

### Step 4 - Tune Detection Logic

Potential tuning options include:

- increase or decrease failure threshold;
- require a minimum number of distinct accounts;
- modify the aggregation window;
- identify known corporate egress infrastructure;
- enrich source IP information;
- consider geographic context;
- correlate failures with successful authentication;
- increase severity when privileged accounts are targeted.

### Step 5 - Evaluate Coverage Impact

Every tuning change should consider possible false negatives.

Example:

Original threshold:

5 failed attempts across multiple users.

Proposed threshold:

15 failed attempts across multiple users.

This may reduce false positives but could allow a low-and-slow attacker performing
10 attempts to remain undetected.

Therefore threshold changes should be supported by observed data.

### Step 6 - Regression Test

After tuning, confirm that previously validated attack scenarios are still
detected.

Tests should include:

- below-threshold activity;
- exactly-at-threshold activity;
- above-threshold activity;
- one account with repeated failures;
- multiple accounts from one source;
- known legitimate infrastructure;
- malicious activity followed by successful authentication.

## Example Tuning Decision

Assume the original rule generates:

- 100 alerts per week;
- 20 True Positives;
- 80 False Positives.

Precision:

20 / (20 + 80) = 20%

Investigation shows that 60 false positives originate from known corporate
authentication infrastructure.

Instead of simply increasing the threshold, the detection can be enriched or
filtered using the known infrastructure while maintaining the original attack
threshold for unknown external sources.

After tuning:

- 35 alerts;
- 20 True Positives;
- 15 False Positives.

Precision:

20 / (20 + 15) = 57.1%

The improvement should then be evaluated against recall to confirm that malicious
activity has not been unintentionally excluded.

## High-Risk Context

Password-spray activity may warrant higher priority when:

- privileged users are targeted;
- authentication originates from unusual locations;
- previously unseen IP addresses are involved;
- Conditional Access behaviour is suspicious;
- successful authentication follows the failures;
- the account subsequently performs privileged activity.

## Relationship to Threat Hunting

The threat-hunting library contains:

`hunt/identity/password-spray-followed-by-success.kql`

This hunt correlates failed authentication activity with subsequent successful
authentication.

If this behaviour proves sufficiently reliable, the correlation could be promoted
into a production detection.

This demonstrates the lifecycle:

Password Spray Detection
        ↓
Operational Alerts
        ↓
False-Positive Analysis
        ↓
Tuning
        ↓
Threat Hunting
        ↓
Additional Behaviour Identified
        ↓
Higher-Confidence Detection Candidate

## Tuning Record

Significant production tuning changes should record:

| Field | Description |
|---|---|
| Detection | Detection being modified |
| Date | Date of tuning decision |
| Reason | Why tuning was required |
| Evidence | Alerts/data supporting the change |
| Previous Logic | Previous threshold/filter |
| New Logic | Updated threshold/filter |
| Expected Impact | Expected reduction/improvement |
| Coverage Risk | Potential false-negative impact |
| Validation | Tests performed after the change |
| Reviewer | Person approving the change |

## Key Principle

Detection tuning is not the process of making alerts disappear.

The objective is to improve the signal-to-noise ratio while preserving meaningful
coverage of attacker behaviour.