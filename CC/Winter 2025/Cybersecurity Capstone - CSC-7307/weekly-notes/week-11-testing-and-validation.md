# Week 11 — Testing and Validation

**Date:** March 20, 2025
**Topic:** End-to-End Log Pipeline Validation, Rule Testing, and Dashboard Customization

---

> **📍 Project Phase:** Validation | **Progress:** ▓▓▓▓▓▓▓▓░░ 79% | **Week 11 of 14**

## Session Summary

The team entered a comprehensive testing phase, validating the full log pipeline from source devices through to Wazuh dashboard alerts. Simulated events were used to verify rule detection, and dashboards were customized to match Industry Partner's operational requirements.

### End-to-End Log Pipeline Validation

- Traced syslog messages from Cisco and MikroTik devices through the ingestion pipeline to the Wazuh indexer
- Confirmed that all configured log sources were actively forwarding events to the Wazuh manager on UDP 514
- Validated that the Windows Server 2022 agent was consistently delivering Security and System event logs
- Verified log parsing accuracy by comparing raw syslog messages against decoded fields in the Wazuh dashboard

### Wazuh Rule Testing

#### Simulated Event Scenarios

| Scenario | Rule Triggered | Severity | Result |
|----------|---------------|----------|--------|
| Failed SSH login (5 attempts) | Rule 5710 — brute force attack | High | Alert generated correctly |
| Cisco interface down | Rule 87702 — network interface status change | Medium | Syslog decoded and alerted |
| Windows failed logon (Event 4625) | Rule 60122 — Windows authentication failure | Medium | Agent forwarded and rule matched |
| MikroTik firewall drop | Custom decoder — MikroTik firewall action | Low | Log parsed with correct field extraction |

#### Alert Threshold Tuning

- Adjusted brute force detection thresholds from 5 to 8 attempts within 120 seconds to reduce false positives
- Configured frequency-based alerting for repeated firewall denies from the same source IP
- Suppressed informational-level alerts for routine interface flaps on non-critical network segments

### Dashboard Customization

- Created a Industry Partner-specific dashboard view in the Wazuh web interface
- Added panels for top alerting agents, most frequent rule triggers, and geographic source mapping
- Configured a dedicated panel for network device syslog events filtered by severity
- Set default time range to 24 hours with drill-down capability for incident investigation

### Course Instructor Review

Course Instructor observed the testing session and confirmed that the validation approach was thorough. He recommended documenting the test scenarios as part of the final deliverables to demonstrate the system's detection capability to the client.

### Action Items

- Document all test scenarios and results in the final project report
- Finalize alert threshold settings and record the rationale for each adjustment
- Prepare the dashboard configuration for export and inclusion in handover materials
- Begin consolidating all technical documentation for the documentation sprint
