# Day 76 – OpenTelemetry and Alerting

## Overview

On Day 76 of the 90DaysOfDevOps challenge, I explored OpenTelemetry and alerting to improve my understanding of end-to-end observability.

Previously, I implemented metrics collection using Prometheus and log management using Loki. Today, I added the third pillar of observability: **Distributed Tracing**, using OpenTelemetry.

I also configured alerting with Prometheus and Grafana to detect infrastructure and application issues.

## What I Learned

### 1. Introduction to OpenTelemetry

OpenTelemetry (OTEL) is an open-source, vendor-neutral framework used to generate, collect, and export telemetry data.

It supports three major types of telemetry:

- **Metrics:** Numerical measurements of system performance.
- **Logs:** Records of events occurring within an application.
- **Traces:** Tracking requests as they travel across multiple services.

### 2. OpenTelemetry Collector

The OpenTelemetry Collector receives, processes, and exports telemetry data.

Its main components are:

- **Receivers:** Accept telemetry data from different sources.
- **Processors:** Process, filter, batch, and transform telemetry data.
- **Exporters:** Send collected telemetry to monitoring and observability backends.

### 3. OpenTelemetry Protocol (OTLP)

OTLP is the standard protocol used to transfer telemetry data between applications and OpenTelemetry components.

It supports:
- gRPC – Port 4317
- HTTP – Port 4318

### 4. Distributed Tracing

Distributed tracing helps track a request across multiple services.

Each operation within a trace is represented by a span containing information such as trace ID, span ID, duration, timestamps, and attributes.

This helps identify performance bottlenecks and troubleshoot issues in distributed applications.

## Implementation

### 1. OpenTelemetry Collector Setup

- Created a dedicated configuration for the OpenTelemetry Collector.
- Configured OTLP receivers for gRPC and HTTP.
- Added batch processing.
- Configured Prometheus and Debug exporters.
- Integrated the collector with Docker Compose.

### 2. Prometheus Integration

- Added the OpenTelemetry Collector as a Prometheus scrape target.
- Exposed the Prometheus exporter endpoint on port 8889.
- Verified the collector's availability through Prometheus Targets.

### 3. Testing Telemetry Data

- Sent sample distributed traces using OTLP HTTP.
- Verified trace information through collector debug output.
- Sent sample metrics to the collector.
- Queried the exported metrics in Prometheus.

### 4. Prometheus Alerting

Configured five alerting rules to monitor critical infrastructure conditions:

- High CPU Usage
- High Memory Usage
- Container Down
- Target Down
- High Disk Usage

Also explored alert severity, PromQL expressions, evaluation intervals, and alert states.

### 5. Grafana Alerting

- Created a notification contact point.
- Configured a High Container Memory alert rule.
- Set up notification policies.
- Explored Normal, Pending, and Firing alert states.

## Observability Architecture

The complete observability stack now includes:

**Metrics Pipeline**
- Node Exporter → Prometheus
- cAdvisor → Prometheus
- OpenTelemetry Collector → Prometheus
- Prometheus → Grafana Dashboards and Alerts

**Logs Pipeline**
- Docker Containers → Promtail → Loki → Grafana

**Traces Pipeline**
- Application / OTLP → OpenTelemetry Collector → Debug Output

## Services and Ports

| Service | Port | Purpose |
|---|---|---|
| Prometheus | 9090 | Metrics collection and querying |
| Node Exporter | 9100 | Host metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Dashboards and alerting |
| Loki | 3100 | Log aggregation |
| Promtail | 9080 | Log collection |
| OpenTelemetry Collector | 4317 | OTLP gRPC |
| OpenTelemetry Collector | 4318 | OTLP HTTP |
| OpenTelemetry Collector | 8889 | Prometheus exporter |
| Notes App | 8000 | Sample application |

## Key Learnings

- Understanding the three pillars of observability.
- Collecting telemetry using OpenTelemetry.
- Understanding distributed tracing and spans.
- Integrating OpenTelemetry with Prometheus.
- Creating Prometheus alerting rules.
- Configuring Grafana notifications and alert policies.
- Understanding how monitoring and alerting help identify production issues.

## Conclusion

Day 76 helped me understand how metrics, logs, and traces work together to provide complete visibility into an application and its infrastructure.

With Prometheus, Grafana, Loki, Promtail, and OpenTelemetry integrated, I now have a more complete observability stack capable of monitoring system health, collecting telemetry, and alerting when something goes wrong.

**Consistency is the key to mastering DevOps! 🚀**

#90DaysOfDevOps #DevOps #OpenTelemetry #Prometheus #Grafana #Loki #Observability #Monitoring #Alerting #CloudComputing