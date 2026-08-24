# Detection Engineering Lifecycle

This document defines the lifecycle used to develop, validate, deploy, maintain,
and retire security detections within the Parking Smart Enterprise Security
Platform.

## 1. Detection Identification

A new detection may originate from:

- threat intelligence;
- MITRE ATT&CK coverage analysis;
- incident findings;
- threat-hunting results;
- vulnerability research;
- security architecture reviews;
- emerging attacker techniques;
- gaps identified in existing detections.

A detection should address a meaningful attacker behaviour rather than exist
only to increase rule coverage.

## 2. Detection Requirements

Before implementation, define:

- detection name;
- threat hypothesis;
- attacker behaviour;
- MITRE ATT&CK technique;
- required telemetry;
- relevant entities;
- expected malicious scenarios;
- expected legitimate scenarios;
- initial severity;
- investigation guidance;
- potential response actions.

## 3. Detection Development

Detection logic is developed using KQL.

Development should consider:

- appropriate time windows;
- aggregation strategy;
- thresholds;
- entity correlation;
- contextual enrichment;
- expected data volume;
- query performance;
- known legitimate activity.

Where possible, detections should focus on attacker behaviour rather than
individual indicators that can change easily.

## 4. Validation and Testing

Before production deployment, detections should be validated for:

### Syntax

The query and analytics-rule definition must be syntactically valid.

### Schema

Required fields, entity mappings, MITRE mappings, severity, query periods and
other metadata must conform to the project's Detection-as-Code standards.

### Positive Testing

Known or simulated malicious activity should cause the detection to match.

### Negative Testing

Expected legitimate activity should not generate unnecessary alerts.

### Boundary Testing

Threshold-based detections should be tested immediately below, at, and above
their configured thresholds.

### Regression Testing

Tuning changes should not unintentionally remove previously validated detection
coverage.

## 5. Detection States

Detections progress through defined lifecycle states.

### Experimental

The detection is under initial development and investigation.

### Testing

Detection logic has been implemented and is undergoing validation.

### Production

The detection has passed validation and is deployed as an active analytics rule.

### Tuning

The detection remains active but is being modified based on operational findings.

### Deprecated

The detection is still available but is scheduled for replacement or retirement.

### Retired

The detection is no longer active because it is obsolete, duplicated, ineffective,
or replaced by better detection logic.

Typical progression:

Experimental
    ↓
Testing
    ↓
Production
    ↓
Monitoring
    ↓
Tuning
    ↓
Production
    ↓
Deprecated
    ↓
Retired

A tuned detection may return to Production multiple times during its lifetime.

## 6. Production Monitoring

After deployment, detection behaviour should be monitored.

Important questions include:

- How many alerts is the rule generating?
- How many alerts are true positives?
- How many are false positives?
- Are expected attack simulations detected?
- Are known attacks being missed?
- How long does detection take?
- How much analyst investigation time does the rule consume?
- Is the underlying query executing successfully?
- Has the telemetry or environment changed?

## 7. Detection Tuning

Tuning should be driven by evidence rather than simply reducing alert volume.

Potential tuning actions include:

- threshold adjustment;
- time-window adjustment;
- allowlisting known legitimate systems;
- excluding approved administrative activity;
- entity-based baselining;
- contextual enrichment;
- event correlation;
- duplicate suppression;
- severity adjustment;
- query optimisation.

Every significant tuning decision should record:

- why the change was made;
- evidence supporting the change;
- expected effect;
- possible coverage reduction;
- validation performed after the change.

## 8. Detection Review

Production detections should be periodically reviewed.

Review should consider:

- current threat relevance;
- MITRE ATT&CK changes;
- telemetry availability;
- false-positive rate;
- detection coverage;
- query performance;
- operational value;
- overlap with other detections;
- incident and threat-hunting findings.

High-noise detections should not automatically be disabled. The cause of the
noise should first be understood.

Likewise, a rule producing no alerts is not automatically effective. It may
indicate that the attack has not occurred, the telemetry is missing, or the
detection logic is ineffective.

## 9. Retirement

A detection may be retired when:

- the underlying technology no longer exists;
- required telemetry is permanently unavailable;
- another detection provides better coverage;
- attacker behaviour has materially changed;
- the rule produces insufficient security value;
- the detection has been replaced by a higher-confidence correlation.

Retirement decisions should be documented in version control.

## 10. Continuous Improvement

Detection Engineering is iterative.

Incident investigations and threat hunts should feed lessons back into the
detection system:

Incident / Hunt
      ↓
New Behaviour Identified
      ↓
Detection Gap
      ↓
Detection Development
      ↓
Testing
      ↓
Deployment
      ↓
Measurement
      ↓
Tuning
      ↓
Improved Detection

The objective is to continuously improve detection precision, coverage,
maintainability, and operational value.