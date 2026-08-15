from pathlib import Path
import sys
import uuid
import yaml

RULE_DIR = Path("sentinel/analytics-rules")
KQL_DIR = Path("detections/sentinel")

REQUIRED_FIELDS = [
    "id",
    "name",
    "description",
    "severity",
    "enabled",
    "kind",
    "kqlFile",
    "queryFrequency",
    "queryPeriod",
    "triggerOperator",
    "triggerThreshold",
    "tactics",
    "relevantTechniques",
    "version",
]

VALID_SEVERITIES = {
    "Informational",
    "Low",
    "Medium",
    "High",
}

VALID_KINDS = {
    "Scheduled",
}


def is_valid_guid(value):
    try:
        uuid.UUID(str(value))
        return True
    except (ValueError, TypeError, AttributeError):
        return False


def validate_rule(path):
    errors = []

    try:
        with path.open("r", encoding="utf-8") as handle:
            rule = yaml.safe_load(handle)
    except Exception as exc:
        return None, [f"Unable to parse YAML: {exc}"]

    if not isinstance(rule, dict):
        return None, ["YAML root must be an object"]

    for field in REQUIRED_FIELDS:
        if field not in rule:
            errors.append(f"Missing required field: {field}")

    rule_id = rule.get("id")

    if rule_id and not is_valid_guid(rule_id):
        errors.append(f"Invalid GUID: {rule_id}")

    severity = rule.get("severity")

    if severity and severity not in VALID_SEVERITIES:
        errors.append(f"Invalid severity: {severity}")

    kind = rule.get("kind")

    if kind and kind not in VALID_KINDS:
        errors.append(f"Invalid kind: {kind}")

    kql_file = rule.get("kqlFile")

    if kql_file:
        if not str(kql_file).endswith(".kql"):
            errors.append(
                f"kqlFile must reference a .kql file: {kql_file}"
            )

        kql_path = KQL_DIR / str(kql_file)

        if not kql_path.exists():
            errors.append(f"KQL file does not exist: {kql_path}")

    tactics = rule.get("tactics")

    if tactics is not None and not isinstance(tactics, list):
        errors.append("tactics must be a list")

    techniques = rule.get("relevantTechniques")

    if techniques is not None and not isinstance(techniques, list):
        errors.append("relevantTechniques must be a list")

    entity_mappings = rule.get("entityMappings")

    if entity_mappings is not None and not isinstance(entity_mappings, list):
        errors.append("entityMappings must be a list")

    return rule, errors


def main():
    if not RULE_DIR.exists():
        print(f"ERROR: Rule directory not found: {RULE_DIR}")
        sys.exit(1)

    rule_files = sorted(RULE_DIR.glob("*.yaml"))

    if not rule_files:
        print("ERROR: No analytics-rule YAML files found.")
        sys.exit(1)

    print(f"Checking {len(rule_files)} Sentinel analytics rules...\n")

    seen_ids = {}
    seen_names = {}

    total_errors = 0

    for path in rule_files:
        rule, errors = validate_rule(path)

        if rule:
            rule_id = str(rule.get("id", "")).strip()
            rule_name = str(rule.get("name", "")).strip().lower()

            if rule_id:
                if rule_id in seen_ids:
                    errors.append(
                        f"Duplicate ID also used by: {seen_ids[rule_id]}"
                    )
                else:
                    seen_ids[rule_id] = path.name

            if rule_name:
                if rule_name in seen_names:
                    errors.append(
                        f"Duplicate rule name also used by: "
                        f"{seen_names[rule_name]}"
                    )
                else:
                    seen_names[rule_name] = path.name

        if errors:
            total_errors += len(errors)

            print(f"FAIL {path.name}")

            for error in errors:
                print(f"  - {error}")

            print()

        else:
            print(f"PASS {path.name}")

    print()

    if total_errors:
        print(f"Validation failed with {total_errors} error(s).")
        sys.exit(1)

    print(
        f"Validation successful. "
        f"{len(rule_files)} analytics rules passed."
    )


if __name__ == "__main__":
    main()