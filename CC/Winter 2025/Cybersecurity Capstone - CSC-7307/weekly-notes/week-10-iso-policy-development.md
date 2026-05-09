# Week 10 — ISO 27001 Policy Development

**Date:** March 13, 2025
**Topic:** Operations Security Policy Drafting and Compliance Mapping

---

> **📍 Project Phase:** Hardening | **Progress:** ▓▓▓▓▓▓▓░░░ 71% | **Week 10 of 14**

## Session Summary

The team dedicated this session to ISO 27001 policy development, focusing on drafting the Operations Security Policy and mapping the SIEM deployment to specific compliance requirements. Course Instructor provided structured feedback on policy format and language.

### Policy Development

#### Operations Security Policy Draft

- Drafted the initial version of the Operations Security Policy aligned with ISO 27001:2022 Annex A control A.12
- Policy sections included scope, objectives, roles and responsibilities, operational procedures, and change management
- Incorporated SIEM monitoring requirements as a core operational control
- Defined log retention periods and event review cadences appropriate for Industry Partner's environment

#### ISO 27001 Annex A Control Mapping

| Control | Description | SIEM Relevance |
|---------|-------------|----------------|
| A.12.1 | Operational procedures and responsibilities | Wazuh deployment runbooks and SOPs |
| A.12.4 | Logging and monitoring | Syslog collection, Wazuh alerting pipeline |
| A.12.6 | Technical vulnerability management | Wazuh vulnerability detection module |
| A.8.15 | Logging | Centralized log aggregation via Wazuh manager |
| A.8.16 | Monitoring activities | Dashboard-based monitoring and alert triage |

#### Gap Analysis Documentation

- Identified controls fully addressed by the current Wazuh deployment
- Documented controls partially addressed and recommended additional configurations
- Flagged controls outside the SIEM scope requiring separate organizational policies

### Course Instructor Feedback

Course Instructor reviewed the draft policy and recommended:
- Strengthening the language around incident escalation procedures
- Adding a section on policy review frequency and version control
- Ensuring the policy references Industry Partner's existing organizational structure

### Team Collaboration

- Group 1 contributed technical control descriptions based on the Wazuh deployment
- Group 2 provided network monitoring context for the logging and monitoring sections
- The full team reviewed the gap analysis findings and prioritized remaining work

### Action Items

- Incorporate Course Instructor's feedback into the second draft of the Operations Security Policy
- Complete the gap analysis documentation with remediation recommendations
- Prepare a summary of compliance findings for the next client meeting
- Begin mapping deliverables to the final presentation outline
