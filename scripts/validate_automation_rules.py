from pathlib import Path
import sys
import uuid
import yaml

RULE_DIR = Path("sentinel/automation-rules")
PLAYBOOK_DIR = Path("sentinel/playbooks")

REQUIRED_FIELDS = [
    "id",
    "name",
    "description",
    "enabled",
    "order",
    "trigger",
    "actions",
]

VALID_SEVERITIES = {
    "Informational",
    "Low",
    "Medium",
    "High",
}

VALID_STATUSES = {
    "New",
    "Active",
    "Closed",
}


def is_valid_guid(value):
    try:
        uuid.UUID(str(value))
        return True
    except (ValueError, TypeError, AttributeError):
        return False


def playbook_exists(playbook_name):
    json_path = PLAYBOOK_DIR / f"{playbook_name}.json"
    return json_path.exists()


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

    if "enabled" in rule and not isinstance(rule["enabled"], bool):
        errors.append("enabled must be true or false")

    if "order" in rule and not isinstance(rule["order"], int):
        errors.append("order must be an integer")

    trigger = rule.get("trigger")

    if trigger is not None and not isinstance(trigger, dict):
        errors.append("trigger must be an object")

    actions = rule.get("actions")

    if actions is not None:
        if not isinstance(actions, list):
            errors.append("actions must be a list")
        else:
            for index, action in enumerate(actions):
                if not isinstance(action, dict):
                    errors.append(
                        f"actions[{index}] must be an object"
                    )
                    continue

                playbook = action.get("playbook")

                if not playbook:
                    errors.append(
                        f"actions[{index}] is missing playbook"
                    )
                    continue

                if not playbook_exists(playbook):
                    errors.append(
                        f"Referenced playbook does not exist: {playbook}.json"
                    )

    incident = rule.get("incident", {})

    if incident and not isinstance(incident, dict):
        errors.append("incident must be an object")
    elif isinstance(incident, dict):
        severities = incident.get("severity")

        if severities is not None:
            if not isinstance(severities, list):
                errors.append("incident.severity must be a list")
            else:
                for severity in severities:
                    if severity not in VALID_SEVERITIES:
                        errors.append(
                            f"Invalid incident severity: {severity}"
                        )

    statuses = rule.get("status")

    if statuses is not None:
        if not isinstance(statuses, list):
            errors.append("status must be a list")
        else:
            for status in statuses:
                if status not in VALID_STATUSES:
                    errors.append(
                        f"Invalid incident status: {status}"
                    )

    return rule, errors


def main():
    if not RULE_DIR.exists():
        print(f"ERROR: Automation rule directory not found: {RULE_DIR}")
        sys.exit(1)

    files = sorted(RULE_DIR.glob("*.yaml"))

    if not files:
        print("ERROR: No Sentinel automation-rule YAML files found.")
        sys.exit(1)

    print(f"Checking {len(files)} Sentinel automation rules...\n")

    seen_ids = {}
    seen_names = {}
    total_errors = 0

    for path in files:
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
        f"{len(files)} automation rules passed."
    )


if __name__ == "__main__":
    main()