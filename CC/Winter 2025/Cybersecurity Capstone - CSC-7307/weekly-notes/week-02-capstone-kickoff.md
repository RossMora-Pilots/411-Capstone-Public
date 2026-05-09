# Week 2 — Capstone Kickoff with Industry Partner

**Date:** January 16–17, 2025
**Topic:** Initial Client Meeting and Project Scoping

---

> **📍 Project Phase:** Discovery | **Progress:** ▓▓░░░░░░░░ 14% | **Week 2 of 14**

## Session Summary

The team held its first meeting with **Industry Mentor** from Industry Partner. to understand the project scope and deliverables.

### Client Briefing

Industry Partner. is a company in Canada serving various sectors. Key points from the briefing:

- **Previous Work:** The Fall 2024 capstone group performed preliminary ISO 27001 certification work
- **Current Objectives:**
  - Continue the ISO 27001:2022 certification journey
  - Evaluate and deploy SIEM/logging tools
  - Integration with existing OpenNMS monitoring infrastructure
- **Infrastructure:** Industry Mentor demonstrated the Hyper-V lab environment with Wazuh, GNS3, and MikroTik VMs

### Lab Environment Overview

Industry Mentor walked the team through the existing virtual environment:
- **Wazuh Debian VM** (8 GB RAM) — Primary SIEM for log collection
- **GNS3 VM** (2 GB RAM) — Cisco IOSv device emulation
- **MikroTik VM** (512 MB RAM) — Router simulation
- **Windows Server 2022** — Available for future domain services

### Team Discussion

Initial observations and questions raised during the meeting:
- Need to understand device-specific log output formats (e.g., OPNsense plain text output)
- Consideration of GNS3 for Cisco virtual routers and switches
- Discussion of remote access options for the virtual environment
- Clarification needed on CentOS log formats

### Action Items

- Sub-groups to be formed for Wazuh configuration and network device integration
- Follow-up meeting with Industry Mentor to receive detailed documentation from the Fall 2024 group
- Team to familiarize themselves with the Wazuh dashboard and administrative interface
