# Day 77 – Full Stack Observability Project with Docker Compose

## 📌 Project Overview

As part of the **90DaysOfDevOps – Zero to Hero AI-Powered UDAAN Batch 11**, I completed Day 77 by integrating all the observability components built over the previous days into a unified monitoring and logging stack using Docker Compose.

The objective was to bring metrics, logs, traces, and alerting together into a centralized observability platform, providing complete visibility into infrastructure and application health.

Using the `observability-for-devops` reference repository by **Shubham Londhe**, I explored a complete observability architecture and validated the communication between its services.

## 🎯 Project Objectives

- Deploy a complete observability stack using Docker Compose.
- Monitor infrastructure and container-level metrics.
- Collect and analyze application and Docker logs.
- Integrate distributed tracing using OpenTelemetry.
- Configure Prometheus and Loki as Grafana data sources.
- Build a unified **Production Overview** dashboard.
- Understand how different observability components work together.

## 🏗️ Architecture Overview

The project integrates eight core services into a centralized observability environment.

### 1. Metrics Monitoring
- **Prometheus:** Collects and stores time-series metrics.
- **Node Exporter:** Exposes host-level CPU, memory, disk, and network metrics.
- **cAdvisor:** Monitors Docker container resource utilization.

### 2. Visualization
- **Grafana:** Provides centralized dashboards for infrastructure metrics, container performance, and application logs.

### 3. Log Management
- **Loki:** Aggregates and stores application and container logs.
- **Promtail:** Collects Docker container logs and forwards them to Loki.

### 4. Distributed Tracing
- **OpenTelemetry Collector:** Receives OTLP telemetry data and processes traces and metrics through configured pipelines.

### 5. Sample Application
- **Notes App:** A sample application used to generate application traffic and validate observability pipelines.

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Docker | Containerization |
| Docker Compose | Multi-container orchestration |
| Prometheus | Metrics collection |
| Node Exporter | Host monitoring |
| cAdvisor | Container monitoring |
| Grafana | Visualization and dashboards |
| Loki | Log aggregation |
| Promtail | Log collection |
| OpenTelemetry | Distributed tracing |
| Linux | Host environment |

## 📊 Implementation and Validation

### 1. Full Stack Deployment
- Explored the reference repository structure.
- Reviewed Docker Compose and individual service configurations.
- Deployed the observability environment through Docker Compose.
- Verified container health and service availability.

### 2. Metrics Pipeline Validation
- Verified Prometheus scrape targets.
- Checked the health of monitoring endpoints.
- Queried host CPU and memory utilization.
- Monitored container CPU and memory consumption.
- Compared Prometheus configurations with previous implementations.

### 3. Logs Pipeline Validation
- Generated application traffic using the Notes App.
- Verified Docker log collection through Promtail.
- Queried application logs using LogQL.
- Filtered error messages and HTTP request logs.
- Checked Promtail targets and Loki ingestion.

### 4. Distributed Tracing Validation
- Configured and examined OpenTelemetry Collector pipelines.
- Sent sample OTLP trace data to the collector.
- Validated HTTP request and database spans.
- Examined trace IDs, span IDs, attributes, and parent-child relationships.
- Reviewed collector debug output to understand trace processing.

### 5. Unified Grafana Dashboard

Created a centralized dashboard named:

**Production Overview – Observability Stack**

The dashboard brings together four major monitoring sections:

- **System Health:** CPU usage, memory usage, disk usage, and Prometheus target availability.
- **Container Metrics:** Container CPU, memory consumption, and running container count.
- **Application Logs:** Notes App logs, error rates, and log volume.
- **Service Overview:** Prometheus scrape duration and OpenTelemetry metrics ingestion.

Configured the dashboard with a 30-minute time range and automatic refresh every 10 seconds.

## 📅 90DaysOfDevOps Learning Journey

| Day | Concepts Covered |
|---|---|
| Day 73 | Prometheus, PromQL, and metrics fundamentals |
| Day 74 | Node Exporter, cAdvisor, and Grafana dashboards |
| Day 75 | Loki, Promtail, and LogQL |
| Day 76 | OpenTelemetry Collector, distributed tracing, and alerting |
| Day 77 | Complete observability stack integration and unified dashboard |

## 🔍 Key Learnings

- Understanding the complete observability architecture.
- Integrating multiple monitoring tools using Docker Compose.
- Monitoring infrastructure and container performance.
- Centralizing logs from Docker containers.
- Understanding distributed tracing and OTLP data flow.
- Building unified Grafana dashboards using multiple data sources.
- Troubleshooting service connectivity and telemetry pipelines.
- Comparing individual configurations with a complete reference architecture.

## 🚀 Production Improvements

Some improvements that could make this architecture more production-ready:

- Configure Alertmanager with Slack or PagerDuty integrations.
- Integrate Grafana Tempo for persistent distributed trace storage.
- Enable HTTPS/TLS for service endpoints.
- Implement authentication and role-based access control.
- Configure log retention and storage limits.
- Introduce high availability for monitoring components.
- Implement backup and recovery strategies.

## ☁️ Managed Observability vs Self-Hosted Observability

This project also helped me understand the difference between self-hosted observability platforms and managed solutions such as Datadog, New Relic, and AWS CloudWatch.

Self-hosted tools provide flexibility, customization, and control over infrastructure, while managed platforms reduce operational overhead by providing hosted monitoring, storage, and analytics capabilities.

## 📚 Reference Repository

[Observability for DevOps – Shubham Londhe](https://github.com/LondheShubham153/observability-for-devops)

## 🙏 Acknowledgements

Special thanks to **Shubham Londhe** and **TrainWithShubham** for providing structured learning resources and practical DevOps challenges through the 90DaysOfDevOps initiative.

---

**Day 77 Completed – Bringing Metrics, Logs, and Traces Together! 🚀**

#90DaysOfDevOps #DevOps #Observability #Prometheus #Grafana #Docker #DockerCompose #Loki #Promtail #OpenTelemetry #Monitoring #CloudComputing