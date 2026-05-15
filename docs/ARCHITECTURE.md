# PayPulse Architecture

## High-Level Overview
TODO: insert final architecture diagram here.

## Design Decisions
- **Monorepo:** all services and infra live in one repo for atomic changes.
- **Node 22 LTS:** pinned via .nvmrc; matches Docker base image and CI runner.
- **Observability via Dynatrace:** chosen over Prometheus/Grafana for enterprise-grade APM, distributed tracing, and Davis AI root cause analysis.

## Open Questions
TODO: track architecture decisions as ADRs.
