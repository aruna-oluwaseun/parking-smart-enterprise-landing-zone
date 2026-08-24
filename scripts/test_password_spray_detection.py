from collections import defaultdict
from datetime import datetime, timedelta


DETECTION_WINDOW = timedelta(minutes=15)
FAILED_ATTEMPT_THRESHOLD = 20
TARGET_ACCOUNT_THRESHOLD = 5


def detect_password_spray(events):
    """
    Simulates the core behavioural logic of the KQL password-spray detection.

    Expected event fields:
        time
        ip
        user
        success
    """

    failed_events = [
        event
        for event in events
        if event["success"] is False
        and event.get("ip")
        and event.get("user")
    ]

    failed_events.sort(key=lambda event: event["time"])

    by_ip = defaultdict(list)

    for event in failed_events:
        by_ip[event["ip"]].append(event)

    detections = []

    for ip_address, ip_events in by_ip.items():
        for start_index, start_event in enumerate(ip_events):
            window_end = start_event["time"] + DETECTION_WINDOW

            window_events = [
                event
                for event in ip_events[start_index:]
                if event["time"] <= window_end
            ]

            failed_attempts = len(window_events)

            target_accounts = {
                event["user"]
                for event in window_events
            }

            if (
                failed_attempts >= FAILED_ATTEMPT_THRESHOLD
                and len(target_accounts) >= TARGET_ACCOUNT_THRESHOLD
            ):
                detections.append(
                    {
                        "ip": ip_address,
                        "failed_attempts": failed_attempts,
                        "target_accounts": len(target_accounts),
                    }
                )

                break

    return detections


def build_events(
    failed_attempts,
    account_count,
    ip_addresses=None,
    success=False,
):
    if ip_addresses is None:
        ip_addresses = ["198.51.100.10"]

    base_time = datetime(2026, 8, 24, 10, 0, 0)

    users = [
        f"user{i + 1}@example.com"
        for i in range(account_count)
    ]

    events = []

    for index in range(failed_attempts):
        events.append(
            {
                "time": base_time + timedelta(seconds=index * 20),
                "ip": ip_addresses[index % len(ip_addresses)],
                "user": users[index % account_count],
                "success": success,
            }
        )

    return events


def assert_alert(events, test_name):
    result = detect_password_spray(events)

    assert result, f"{test_name}: expected ALERT but got NO ALERT"

    print(f"PASS {test_name}")


def assert_no_alert(events, test_name):
    result = detect_password_spray(events)

    assert not result, f"{test_name}: expected NO ALERT but got ALERT"

    print(f"PASS {test_name}")


def test_tc01_below_failure_threshold():
    events = build_events(
        failed_attempts=19,
        account_count=5,
    )

    assert_no_alert(
        events,
        "TC01 Below failed-attempt threshold",
    )


def test_tc02_exact_detection_boundary():
    events = build_events(
        failed_attempts=20,
        account_count=5,
    )

    assert_alert(
        events,
        "TC02 Exact detection boundary",
    )


def test_tc03_above_detection_threshold():
    events = build_events(
        failed_attempts=25,
        account_count=5,
    )

    assert_alert(
        events,
        "TC03 Above detection threshold",
    )


def test_tc04_below_account_threshold():
    events = build_events(
        failed_attempts=20,
        account_count=4,
    )

    assert_no_alert(
        events,
        "TC04 Below target-account threshold",
    )


def test_tc05_single_account_brute_force():
    events = build_events(
        failed_attempts=30,
        account_count=1,
    )

    assert_no_alert(
        events,
        "TC05 Single-account brute force",
    )


def test_tc06_distributed_sources():
    events = build_events(
        failed_attempts=20,
        account_count=5,
        ip_addresses=[
            "198.51.100.10",
            "198.51.100.11",
            "198.51.100.12",
            "198.51.100.13",
            "198.51.100.14",
        ],
    )

    assert_no_alert(
        events,
        "TC06 Distributed source IP addresses",
    )


def test_tc07_clear_password_spray():
    events = build_events(
        failed_attempts=50,
        account_count=20,
    )

    assert_alert(
        events,
        "TC07 Clear password spray",
    )


def test_tc08_successful_authentication():
    events = build_events(
        failed_attempts=50,
        account_count=20,
        success=True,
    )

    assert_no_alert(
        events,
        "TC08 Successful authentication events",
    )


def main():
    print("Running password-spray detection regression tests...\n")

    tests = [
        test_tc01_below_failure_threshold,
        test_tc02_exact_detection_boundary,
        test_tc03_above_detection_threshold,
        test_tc04_below_account_threshold,
        test_tc05_single_account_brute_force,
        test_tc06_distributed_sources,
        test_tc07_clear_password_spray,
        test_tc08_successful_authentication,
    ]

    for test in tests:
        test()

    print(
        f"\nValidation successful. "
        f"{len(tests)} password-spray tests passed."
    )


if __name__ == "__main__":
    main()