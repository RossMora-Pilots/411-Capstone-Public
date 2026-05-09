# Screenshots & Visual Evidence

> **Note:** This capstone project was conducted in a virtual lab environment. The screenshots below are **Mermaid-based recreations** of the actual dashboards, topologies, and configurations observed during the project. They faithfully represent the system state and outputs documented in the project artifacts.

---

## 📊 Wazuh Dashboard — Event Ingestion Overview

The Wazuh Dashboard displayed real-time event ingestion from all integrated log sources. During peak operation, the dashboard showed approximately 2,400 events per day across three source categories.

```mermaid
xychart-beta
    title "Wazuh Daily Event Ingestion (~2,400 events/day)"
    x-axis ["Cisco IOSv", "MikroTik CHR", "Wazuh Self-Monitor", "System Logs"]
    y-axis "Events per Day" 0 --> 1400
    bar [1100, 750, 350, 200]
```

---

## 🖧 GNS3 Network Topology

The GNS3 environment hosted the Cisco IOSv router used for syslog forwarding to the Wazuh Manager. The topology below recreates the lab network as configured during the project.

```mermaid
graph TB
    subgraph "Hyper-V Host — SBY-7VTBN34"
        subgraph "Virtual Switch — 192.168.80.0/20"
            WAZUH["🛡️ Wazuh Manager<br/>Debian VM — 8 GB RAM<br/>192.168.80.2<br/>UDP 514 Listener"]
            GNS3["🖧 GNS3 VM<br/>Linux — 2 GB RAM<br/>192.168.93.60"]
            MIKRO["🖧 MikroTik CHR<br/>RouterOS — 512 MB<br/>192.168.93.242"]
            WINSRV["💻 Windows Server 2022<br/>Domain Services<br/>(Offline during testing)"]
        end
    end

    GNS3 -->|"Syslog UDP 514<br/>~1,100 events/day"| WAZUH
    MIKRO -->|"Syslog UDP 514<br/>~750 events/day"| WAZUH
    WINSRV -.->|"Wazuh Agent<br/>(when online)"| WAZUH

    style WAZUH fill:#1a5276,stroke:#2980b9,color:#fff
    style GNS3 fill:#1e8449,stroke:#27ae60,color:#fff
    style MIKRO fill:#1e8449,stroke:#27ae60,color:#fff
    style WINSRV fill:#7f8c8d,stroke:#95a5a6,color:#fff
```

---

## 🔔 Wazuh Alert Configuration — Custom Rules

Over 15 custom alert rules were configured to detect security-relevant events from Cisco and MikroTik devices. The table below recreates the rule categories and their alert levels.

```mermaid
pie title "Custom Alert Rules by Category (15+ rules)"
    "Authentication Events" : 4
    "Configuration Changes" : 3
    "Interface Status" : 3
    "Syslog Errors" : 2
    "Access Violations" : 2
    "System Health" : 2
```

| Rule Category | Example Trigger | Alert Level | Source |
|---------------|----------------|:-----------:|--------|
| **Authentication** | Failed login on Cisco IOSv | High | Cisco Syslog |
| **Configuration Change** | Running-config modified | Medium | Cisco Syslog |
| **Interface Flap** | Interface up/down events | Medium | MikroTik Syslog |
| **Access Violation** | Denied ACL entry | High | Cisco Syslog |
| **System Health** | CPU/memory threshold exceeded | Low | MikroTik Syslog |
| **Syslog Error** | Malformed syslog message received | Low | Wazuh Internal |

---

## 🖥️ Wazuh Health Check — Script Output Recreation

The `wazuh_healthcheck.sh` script produced color-coded 9-point diagnostic output. Below is a recreation of a typical successful health check run.

```
╔══════════════════════════════════════════════════════════════╗
║              WAZUH HEALTH CHECK — v4.9.2                     ║
╠══════════════════════════════════════════════════════════════╣
║  [✅ PASS]  1. Service Status      wazuh-manager active      ║
║  [✅ PASS]  2. Port Listening       UDP 514, TCP 1514/1515   ║
║  [✅ PASS]  3. Disk Usage           /var/ossec at 34%         ║
║  [✅ PASS]  4. Log File Sizes       Within expected range     ║
║  [✅ PASS]  5. Recent Errors        0 errors in last 50 lines ║
║  [✅ PASS]  6. Agent Connections    1 agent connected          ║
║  [⚠️ WARN]  7. Indexer Status       Slow response (2.1s)      ║
║  [✅ PASS]  8. Version Check        4.9.2 (locked)            ║
║  [✅ PASS]  9. Config Validation    ossec.conf valid           ║
╠══════════════════════════════════════════════════════════════╣
║  RESULT:  8 PASS  |  1 WARN  |  0 FAIL                      ║
╚══════════════════════════════════════════════════════════════╝
```

---

## 📋 Wazuh Setup Script — Execution Flow

The `wazuh_setup.sh` script executed a 4-phase deployment with automatic rollback on failure.

```mermaid
flowchart TD
    START["▶️ sudo ./wazuh_setup.sh"] --> P1
    subgraph P1["Phase 1 — Pre-Checks"]
        A1["Check root privileges"] --> A2["Install xmllint"]
        A2 --> A3["Verify wazuh-manager running"]
        A3 --> A4["Validate ossec.conf exists"]
        A4 --> A5["Test network to log sources"]
        A5 --> A6["Check UDP 514 availability"]
    end
    P1 --> P2
    subgraph P2["Phase 2 — Configuration"]
        B1["Backup ossec.conf<br/>(timestamped)"] --> B2["Remove existing syslog block"]
        B2 --> B3["Insert new syslog config"]
        B3 --> B4["Validate XML — xmllint"]
        B4 --> B5{"XML Valid?"}
        B5 -->|"Yes"| B6["Validate — wazuh-control"]
        B5 -->|"No"| ROLLBACK["🔄 Restore backup<br/>Exit with error"]
        B6 --> B7{"Config Valid?"}
        B7 -->|"Yes"| B8["Restart wazuh-manager"]
        B7 -->|"No"| ROLLBACK
    end
    P2 --> P3
    subgraph P3["Phase 3 — Post-Checks"]
        C1["Confirm service running"] --> C2["Verify UDP 514 listening"]
        C2 --> C3["Check processes as root"]
        C3 --> C4["Review error logs"]
        C4 --> C5["Test UDP connectivity"]
    end
    P3 --> P4
    subgraph P4["Phase 4 — Monitoring"]
        D1["Tail ossec.log 30s<br/>Filter: syslog|cisco"]
        D2["Tail alerts.log 30s<br/>Filter: syslog|cisco"]
    end
    P4 --> DONE["✅ Deployment Complete"]

    style P1 fill:#2c3e50,stroke:#34495e,color:#fff
    style P2 fill:#1a5276,stroke:#2980b9,color:#fff
    style P3 fill:#1e8449,stroke:#27ae60,color:#fff
    style P4 fill:#7d3c98,stroke:#8e44ad,color:#fff
    style ROLLBACK fill:#922b21,stroke:#c0392b,color:#fff
    style DONE fill:#1e8449,stroke:#27ae60,color:#fff
```

---

## 🔒 ISO 27001 Compliance Posture

The gap analysis identified 12 control areas with varying levels of implementation. The visualization below recreates the compliance dashboard.

```mermaid
quadrantChart
    title ISO 27001:2022 Compliance Readiness — Industry Partner
    x-axis Low Implementation --> High Implementation
    y-axis Low Priority --> High Priority
    quadrant-1 Implement Next
    quadrant-2 Strong Foundation
    quadrant-3 Plan for Later
    quadrant-4 Quick Wins Available
    Logging & Monitoring: [0.85, 0.90]
    Network Segmentation: [0.70, 0.65]
    Operations Security Policy: [0.75, 0.85]
    Change Management: [0.50, 0.80]
    Asset Inventory: [0.40, 0.75]
    Risk Assessment: [0.30, 0.95]
    Access Control: [0.35, 0.80]
    Incident Response: [0.15, 0.90]
    Business Continuity: [0.10, 0.70]
    Internal Audit: [0.10, 0.60]
    Management Review: [0.10, 0.55]
    Clock Synchronization: [0.80, 0.50]
```

---

## 📈 Project Timeline — Actual Progress

```mermaid
gantt
    title Industry Partner Capstone — Actual Timeline
    dateFormat YYYY-MM-DD
    axisFormat %b %d

    section Discovery
    Course Intro & Team Formation       :done, 2025-01-09, 7d
    Client Kickoff & Scoping            :done, 2025-01-16, 7d
    Certifications & Planning           :done, 2025-01-23, 7d

    section Build
    SIEM Evaluation & Lab Setup         :done, 2025-01-30, 7d
    Wazuh Deployment & Config           :done, 2025-02-06, 7d
    Syslog Integration & Troubleshooting:done, 2025-02-13, 7d
    SNMP Research & Advanced Config     :done, 2025-02-20, 7d
    Reading Week                        :done, 2025-02-27, 7d

    section Deliver
    Agent Deployment & Testing          :done, 2025-03-06, 7d
    ISO Policy Development              :done, 2025-03-13, 7d
    Testing & Validation                :done, 2025-03-20, 7d
    Documentation Sprint                :done, 2025-03-27, 7d
    Client Handoff                      :done, 2025-04-03, 7d
    Final Presentation                  :done, 2025-04-10, 7d
```

---

## 📐 Virtual Lab Architecture — Hyper-V Layout

```mermaid
block-beta
    columns 4
    block:host:4
        columns 4
        A["🖥️ Hyper-V Host\nWindows 11\nSBY-7VTBN34"]:4
    end
    block:vswitch:4
        columns 4
        B["🔀 Virtual Switch — 192.168.80.0/20"]:4
    end
    block:vms:4
        columns 4
        C["🛡️ Wazuh\nDebian\n8 GB RAM\n192.168.80.2"]
        D["🖧 GNS3\nLinux\n2 GB RAM\n192.168.93.60"]
        E["🖧 MikroTik\nRouterOS\n512 MB\n192.168.93.242"]
        F["💻 Win Server\n2022\n(Offline)\nDomain Svc"]
    end

    style C fill:#1a5276,stroke:#2980b9,color:#fff
    style D fill:#1e8449,stroke:#27ae60,color:#fff
    style E fill:#1e8449,stroke:#27ae60,color:#fff
    style F fill:#7f8c8d,stroke:#95a5a6,color:#fff
```

---

## 📝 Evidence Notes

These visual recreations are based on:
- Configuration files documented in [WAZUH_DEPLOYMENT.md](../industry-partner-project/WAZUH_DEPLOYMENT.md)
- Architecture specifications from [ARCHITECTURE.md](../industry-partner-project/ARCHITECTURE.md)
- Operational metrics recorded during the 8-week active deployment period
- Script output patterns from the [4-script automation suite](../SCRIPTS_README.md)
- ISO 27001 gap analysis from [ISO_27001_JOURNEY.md](../industry-partner-project/ISO_27001_JOURNEY.md)

All diagrams render natively on GitHub using Mermaid syntax.

---

> *Last updated: 2026-04-06 — Portfolio remediation and visualization enhancements*
