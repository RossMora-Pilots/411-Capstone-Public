# Runbook — Pilot 411 (Cybersecurity Capstone)

## Overview

This runbook covers operations and maintenance for the Cybersecurity Capstone portfolio repository.

## PM Loop (Local Pilot Workspace)

```bash
# Parse ROADMAP + index sessions (no commit)
PM_COMMIT=0 scripts/pm.sh run

# Parse + commit artifacts
scripts/pm.sh run

# Parse + sync Issues (requires gh CLI + GH_TOKEN)
GH_REPO=<owner>/411-Capstone-CSC scripts/pm.sh sync
```

## Content Organization

### Course Materials

All course content is organized under:

```
CC/Winter 2025/Cybersecurity Capstone - CSC-7307/
```

### Industry Partner Project

The capstone project documentation is under:

```
CC/.../industry-partner-project/
├── README.md              ← Project overview
├── ARCHITECTURE.md        ← Virtual lab environment
├── WAZUH_DEPLOYMENT.md    ← SIEM implementation details (+ Cisco decoder resolution)
├── ISO_27001_JOURNEY.md   ← Compliance documentation (+ evidence mapping)
├── OPERATIONS_SECURITY_POLICY.md  ← ISO 27001-aligned security policy (+ process flows)
├── FINDINGS_AND_RECOMMENDATIONS.md  ← Technical findings
└── scripts/
    ├── wazuh_setup.sh         ← Automated Wazuh deployment
    ├── wazuh_recovery.sh      ← Backup restoration and recovery
    ├── wazuh_healthcheck.sh   ← 9-point system diagnostics
    └── wazuh_version_lock.sh  ← Version pinning with drift detection
```

### Supporting Documents (added during remediation)

```
CC/.../
├── PORTFOLIO_SUMMARY.md    ← One-page executive brief for hiring managers
├── GLOSSARY.md             ← 30+ cybersecurity term definitions
├── CERTIFICATION_RESOURCES.md  ← Certification pathway with skill mapping
├── SCRIPTS_README.md       ← Script catalog, workflow, troubleshooting
└── screenshots/
    └── VISUAL_EVIDENCE.md  ← 9 Mermaid diagram recreations of dashboards/topology
```

### Documentation (this directory)

```
docs/
├── README.md                       ← This file
├── Runbook.md                      ← Operations guide
├── PORTFOLIO_ASSESSMENT_REPORT.md  ← Full assessment with ratings and recommendations
└── REMEDIATION_LOG.md              ← Detailed log of all 16 remediation items
```

## Evidence and Health

- Roadmap snapshot: `artifacts/roadmap.json`
- Portfolio config: `portfolio/config.json`
- Portfolio assessment: `docs/PORTFOLIO_ASSESSMENT_REPORT.md`
- Remediation log: `docs/REMEDIATION_LOG.md`
- Evidence index: `CC/.../EVIDENCE_INDEX.md` (catalog of all 49 files + 18 visualizations)

## Security Posture

- No secrets committed; `.gitleaks.toml` configured for scanning
- Email addresses and personal identifiers redacted from all public content
- Git LFS configured for large binary files
- Commit template enforced via `.gitmessage.txt`

## Visualization Strategy

All diagrams use Mermaid syntax for GitHub-native rendering:

- **Flowcharts** — Process flows, decision trees, career pathways
- **Gantt charts** — Project timelines, remaining work
- **Pie charts** — Effort distribution, compliance posture
- **XY charts** — Event volumes, metric comparisons
- **Quadrant charts** — Risk heat maps, gap analysis
- **Timelines** — Growth phases, project milestones
- **Sequence diagrams** — Script execution flows
- **Graph diagrams** — Network topology

No external rendering tools required — all render natively on GitHub.
