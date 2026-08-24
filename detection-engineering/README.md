# Detection Engineering

This directory documents the detection engineering lifecycle used within the
Parking Smart Enterprise Security Platform.

The objective is not simply to create security alerts. Detections are treated
as engineered security capabilities that must be designed, tested, measured,
tuned, maintained and eventually retired when they are no longer effective.

## Objectives

The Detection Engineering capability is designed to:

- identify meaningful attacker behaviour from security telemetry;
- translate threat hypotheses into reliable detection logic;
- map detections to MITRE ATT&CK techniques;
- minimise unnecessary analyst workload and alert fatigue;
- measure detection effectiveness using operational metrics;
- identify false positives and false negatives;
- continuously tune detection logic based on observed behaviour;
- promote useful threat-hunting findings into production detections;
- maintain detection content through version-controlled Detection-as-Code.

## Detection Engineering Lifecycle

The lifecycle used by this project is:

Threat Intelligence / Threat Hypothesis
        ↓
Detection Requirement
        ↓
Data Source Identification
        ↓
Detection Development
        ↓
Validation & Testing
        ↓
Peer / Security Review
        ↓
Deployment
        ↓
Monitoring
        ↓
Measurement
        ↓
Tuning
        ↓
Continuous Improvement
        ↓
Retirement

## Detection Development

Each detection should define:

- the attacker behaviour being detected;
- the required telemetry;
- the MITRE ATT&CK technique;
- the KQL detection logic;
- thresholds and time windows where applicable;
- expected true-positive scenarios;
- known false-positive scenarios;
- investigation guidance;
- recommended response actions.

Detection logic is maintained as code and validated before deployment.

## Detection Quality

Detection quality is evaluated using several signals rather than simply
counting the number of alerts generated.

Important measurements include:

- true positives;
- false positives;
- false negatives;
- precision;
- recall;
- alert volume;
- detection latency;
- investigation workload;
- rule execution health.

A detection generating large numbers of alerts is not necessarily an effective
detection. High-quality detections should identify meaningful attacker
behaviour while maintaining an acceptable operational cost.

## Detection Tuning

Tuning may involve:

- adjusting thresholds;
- changing aggregation windows;
- excluding known legitimate identities or systems;
- introducing behavioural baselines;
- adding contextual enrichment;
- correlating multiple events;
- refining entity mappings;
- changing severity;
- suppressing duplicate activity.

Tuning decisions should be documented and validated to ensure that reducing
false positives does not introduce unacceptable detection gaps.

## Threat Hunt to Detection

Threat hunting provides an important source of new detection opportunities.

The promotion process is:

Hunting Hypothesis
        ↓
Hunting Query
        ↓
Investigation
        ↓
Repeatable Suspicious Behaviour Identified
        ↓
Detection Candidate
        ↓
Testing
        ↓
Tuning
        ↓
Production Analytics Rule

Not every hunting query should become an automated detection. Promotion should
occur only when the behaviour can be detected with sufficient confidence and
acceptable operational impact.

## Detection-as-Code

Detection content in this project is managed through version control.

The pipeline includes:

KQL Detection
        ↓
Analytics Rule YAML
        ↓
Python Validation
        ↓
GitHub Actions
        ↓
Terraform
        ↓
Microsoft Sentinel

This provides repeatability, reviewability and automated validation of
detection content before deployment.

## Repository Structure

- `lifecycle.md` - detailed detection lifecycle and ownership model.
- `tuning/` - detection tuning methodology and worked examples.
- `metrics/` - detection effectiveness and operational measurements.
- `testing/` - validation and testing strategy.

The Microsoft Sentinel detection content itself is maintained separately under
the project's detection and Sentinel directories.