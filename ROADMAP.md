# ROADMAP — Cybersecurity Capstone (CSC-7307) — Winter 2025 (Pilot 411)

This pilot creates a public, employer-facing course portfolio repository for the Cybersecurity Capstone (CSC-7307), Winter 2025, taught by Instructor Course Instructor at Cambrian College. It documents the Industry Partner capstone project — a real-world SIEM deployment and ISO 27001 compliance engagement.

## Now

- [x] Establish repository structure (README, docs, CC/, artifacts)
- [x] Create root configuration files (.gitattributes, .gitleaks.toml, .markdownlint.json)
- [x] Align conventions with Pilot 008/009/010 (naming, labels, evidence)
- [x] Author course-level README with portfolio highlights
- [x] Document Industry Partner capstone project (architecture, Wazuh, ISO 27001)
- [x] Create weekly notes summarizing 14 weeks of class sessions
- [x] Add Wazuh deployment scripts with documentation (4 scripts: setup, recovery, health check, version lock)
- [x] Document guest speakers and certification resources
- [x] Create evidence index and scripts documentation
- [x] Author employer-first root README with highlights and navigation
- [x] Add Mermaid visualizations (architecture, data flow, ISO gap analysis, timeline, pipeline)
- [x] Add individual contribution sections and operational metrics
- [x] Create assignment writeups (project charter, progress report, final report, reflection)
- [x] Create Operations Security Policy (ISO 27001-aligned)
- [x] Fix IP address inconsistencies across documents and scripts
- [x] Add LICENSE file
- [x] Employer-perspective portfolio assessment (19 docs reviewed, B+ baseline)
- [x] Remediate all 16 assessment gaps (29 files, +953 lines, 3 new files)
- [x] Add 18+ Mermaid visualizations across all documents
- [x] Create visual evidence gallery (screenshots/VISUAL_EVIDENCE.md)
- [x] Clarify Cisco decoder resolution in WAZUH_DEPLOYMENT.md
- [x] Strengthen individual reflection with skills matrix and metrics
- [x] Add Gantt charts and risk matrices to project charter
- [x] Complete rewrite of certification resources with pathway diagram
- [x] Add execution workflow and troubleshooting to scripts README
- [x] Add evidence mapping and scoring methodology to ISO 27001
- [x] Add process flows to Operations Security Policy
- [x] Add progress indicators to all 14 weekly notes
- [x] Create GLOSSARY.md, PORTFOLIO_SUMMARY.md
- [x] Update Evidence Index with all new files and visualizations
- [x] Document assessment and remediation (PORTFOLIO_ASSESSMENT_REPORT.md, REMEDIATION_LOG.md)

## Next

- [ ] Replace Mermaid recreations with actual screenshots (if lab environment available)
- [ ] Add repo topics/description; enable secret scanning/code scanning
- [ ] Add link-check CI workflow (Markdown links + image paths)
- [ ] Run PM plumbing (parse roadmap → artifacts, sessions index)
- [ ] Register pilot in portfolio and render docs index
- [ ] Add effort estimates to FINDINGS_AND_RECOMMENDATIONS.md
- [ ] Add actual sign-off dates to Project Charter approval section

## Later

- [ ] Optional GitHub Pages landing page with professional branding
- [ ] Optional video walkthrough of SIEM deployment or dashboard
- [ ] Optional markdown linting and shell checks for scripts (CI/CD)
- [ ] Expand with additional capstone artifacts as available
- [ ] Add decision log tracking key technical decisions
- [ ] Create skills matrix page mapping evidence to target job requirements

## Milestones (Definition of Done)

- [x] Repository structure finalized and documented
- [x] Industry Partner project fully documented with technical depth
- [x] Weekly notes provide complete course narrative (14 weeks)
- [x] Mermaid visualizations in all technical documents (18+ diagrams)
- [x] Individual contributions and operational metrics documented
- [x] Assignments and deliverables included (charter, reports, reflection)
- [x] Operations Security Policy created and linked
- [x] Script suite complete (setup, recovery, health check, version lock)
- [x] Portfolio assessed from employer perspective (B+ → A- after remediation)
- [x] All assessment gaps remediated and documented
- [ ] Evidence artifacts present (roadmap.json, state.json, sessions index)
- [ ] No secrets or personal data; all content sanitized for public display
- [ ] CI workflows operational; badges added to README

## Runbook

- PM loop: `scripts/pm.sh run` (auto-commit artifacts); `PM_PUSH=1 scripts/pm.sh all`
- Issues (optional): `scripts/pm.sh sync` (requires `gh` + `GH_TOKEN`)
- Assessment: see `docs/PORTFOLIO_ASSESSMENT_REPORT.md`
- Remediation log: see `docs/REMEDIATION_LOG.md`
