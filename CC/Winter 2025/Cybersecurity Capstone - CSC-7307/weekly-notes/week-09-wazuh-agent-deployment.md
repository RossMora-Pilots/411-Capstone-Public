# Week 9 — Wazuh Agent Deployment

**Date:** March 6, 2025
**Topic:** Windows Agent Deployment, Agent-Manager Communication, and Vulnerability Detection

---

> **📍 Project Phase:** Integration | **Progress:** ▓▓▓▓▓▓░░░░ 64% | **Week 9 of 14**

## Session Summary

The team shifted focus to deploying Wazuh agents on endpoint systems, beginning with Windows Server 2022. Group 1 led the agent deployment work while Group 2 continued refining syslog integration documentation.

### Technical Progress

#### Windows Server 2022 Agent Installation

- Downloaded and installed the Wazuh 4.9.2 agent MSI package on a Windows Server 2022 VM
- Configured the agent to point to the Wazuh manager via `ossec.conf` with the correct server address
- Verified the agent registered successfully with the manager and appeared in the Wazuh dashboard
- Confirmed log forwarding from Windows Event Log channels (System, Security, Application)

#### Agent-Manager Communication Testing

- Validated TCP 1514 (agent enrollment) and TCP 1515 (agent communication) connectivity
- Tested agent reconnection behavior after simulated network interruptions
- Confirmed that queued events were forwarded correctly once connectivity was restored
- Measured agent registration latency at under 3 seconds in the lab environment

#### Vulnerability Detection Module

- Enabled the Wazuh Vulnerability Detector module on the manager
- Configured vulnerability feeds for Windows (NVD and Microsoft Security Update feeds)
- Initial scan identified several known CVEs on the test Windows Server VM
- Discussed relevance of vulnerability detection as an added value for Industry Partner's security posture

### Deployment Documentation

- Began writing a step-by-step Wazuh agent deployment guide for Windows environments
- Documented prerequisites including .NET Framework version, firewall rules, and service account permissions
- Included screenshots of the Wazuh dashboard showing successful agent registration

### Course Instructor Feedback

Course Instructor reviewed the team's deployment approach and recommended documenting rollback procedures in case an agent installation causes performance issues on production systems. He also suggested testing agent deployment via Group Policy for scalability.

### Action Items

- Test Wazuh agent deployment on a second Windows Server instance
- Explore Group Policy-based agent distribution for enterprise-scale deployment
- Document the vulnerability detection findings for the client report
- Continue refining the syslog decoder configuration for MikroTik devices
