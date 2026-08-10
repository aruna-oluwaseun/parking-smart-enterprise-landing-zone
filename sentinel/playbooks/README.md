# Sentinel Playbooks

This directory contains Logic App playbook designs used for automated and semi-automated incident response.

## Playbooks

### disable-account
Disables a suspected compromised Microsoft Entra ID user after analyst approval.

### create-incident
Creates and enriches a Sentinel incident from a qualifying security alert.

### enrich-ioc
Enriches suspicious IP addresses and indicators with threat-intelligence context.

### notify-teams
Sends high-severity incident notifications to the security operations team.

## Safety

Potentially destructive actions such as disabling accounts should use human approval before execution in production environments.