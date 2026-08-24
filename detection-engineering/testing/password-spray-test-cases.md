# Password Spray Detection Test Cases

## Detection Under Test

`detections/sentinel/password_spray.kql`

## Detection Parameters

The current detection uses:

- Detection window: 15 minutes
- Failed attempt threshold: 20
- Target account threshold: 5
- Authentication result: Failed
- Grouping entity: Source IP address

The purpose of these tests is to verify that tuning changes do not unintentionally
break expected detection behaviour.

## Test Matrix

| Test | Failed Attempts | Accounts | Source IPs | Expected |
|---|---:|---:|---:|---|
| Below failure threshold | 19 | 5 | 1 | No alert |
| At failure threshold | 20 | 5 | 1 | Alert |
| Above failure threshold | 25 | 5 | 1 | Alert |
| Below account threshold | 20 | 4 | 1 | No alert |
| At account threshold | 20 | 5 | 1 | Alert |
| Single-account brute force | 30 | 1 | 1 | No alert |
| Distributed low-volume activity | 20 | 5 | Multiple | No alert per individual IP |
| Clear password spray | 50 | 20 | 1 | Alert |

## TC01 - Below Failed-Attempt Threshold

Generate 19 failed authentication events from one IP address against five accounts
within the detection window.

Expected result:

`NO ALERT`

Reason:

The activity does not meet the minimum 20 failed-attempt threshold.

## TC02 - Exact Detection Boundary

Generate exactly 20 failed authentication events from one IP address against exactly
five accounts within 15 minutes.

Expected result:

`ALERT`

This verifies that the configured threshold is inclusive.

## TC03 - Above Detection Threshold

Generate 25 failed authentication events from one IP address against five or more
accounts.

Expected result:

`ALERT`

## TC04 - Below Target-Account Threshold

Generate at least 20 failed authentication events from one IP address but distribute
them across only four accounts.

Expected result:

`NO ALERT`

This distinguishes password spraying from concentrated authentication failures.

## TC05 - Single-Account Brute Force

Generate 30 failed authentication attempts against one account from one source IP.

Expected result:

`NO ALERT`

The behaviour may warrant a separate brute-force detection, but it should not satisfy
this password-spray rule.

## TC06 - Multiple Source IP Addresses

Generate authentication failures against multiple accounts, but distribute the
activity across source IP addresses so that no individual IP meets both thresholds.

Expected result:

`NO ALERT`

This also documents a possible detection limitation: distributed password spraying
may evade a source-IP-based aggregation strategy.

## TC07 - Clear Password Spray

Generate 50 failed authentication events from one IP address targeting 20 different
accounts within 15 minutes.

Expected result:

`ALERT`

This represents a high-confidence password-spray scenario.

## TC08 - Successful Authentication Events

Generate successful authentication events using the same accounts and IP address.

Expected result:

The successful events should not contribute to the failed-attempt threshold because
the detection filters on failed authentication results.

Successful authentication following a spray is investigated separately by:

`hunt/identity/password-spray-followed-by-success.kql`

## Regression Requirement

Any future modification to the password-spray detection should be checked against
these cases.

At minimum:

- TC01 must remain negative;
- TC02 must remain positive;
- TC04 must remain negative;
- TC05 must remain negative;
- TC07 must remain positive.

If a tuning change intentionally changes one of these outcomes, the reason should be
documented as part of the tuning decision.

## Known Detection Limitations

The current detection primarily identifies password spraying where multiple
authentication failures originate from the same source IP address.

Potential evasions include:

- distributed password spraying across multiple IP addresses;
- low-and-slow spraying outside the 15-minute aggregation window;
- attackers remaining below the failed-attempt threshold;
- missing or delayed authentication telemetry.

These limitations can become candidates for additional correlated detections or
threat-hunting hypotheses.