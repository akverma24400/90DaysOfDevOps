# Day 74 – Node Exporter, cAdvisor, and Grafana Dashboards

## Overview

On Day 74 of the #90DaysOfDevOps challenge, I extended my Prometheus monitoring setup by adding Node Exporter, cAdvisor, and Grafana.

The objective was to monitor both the EC2 host machine and Docker containers, collect their metrics using Prometheus, and visualize everything through Grafana dashboards.

## Architecture

The observability stack consists of:

- **Prometheus:** Collects and stores metrics from monitoring targets.
- **Node Exporter:** Exposes Linux host-level metrics such as CPU, memory, disk, filesystem, and network usage.
- **cAdvisor:** Collects resource utilization and performance metrics from Docker containers.
- **Grafana:** Visualizes Prometheus metrics through interactive dashboards.
- **Notes App:** Application running as a Docker container and included in the monitoring environment.

## Task 1 – Node Exporter for Host Monitoring

Node Exporter was added to the Docker Compose configuration to monitor the EC2 instance.

### Implementation

- Deployed Node Exporter using its official Docker image.
- Exposed port 9100 for metrics.
- Mounted host system directories in read-only mode.
- Configured Prometheus to scrape metrics from Node Exporter.

### Metrics Monitored

- CPU utilization and idle time
- Total and available memory
- Disk and filesystem usage
- Network traffic
- System-level resource information

### Verification

Confirmed that Node Exporter was accessible through its metrics endpoint and that its target appeared as UP in the Prometheus Targets page.

## Task 2 – cAdvisor for Container Monitoring

cAdvisor was deployed to monitor Docker container resource utilization.

### Implementation

- Deployed cAdvisor using its official container image.
- Exposed port 8080.
- Mounted Docker socket and required host directories.
- Added cAdvisor as a Prometheus scrape target.

### Metrics Monitored

- Container CPU usage
- Container memory consumption
- Container network traffic
- Container resource utilization

### Difference Between Node Exporter and cAdvisor

| Node Exporter | cAdvisor |
|---|---|
| Monitors the host machine | Monitors individual containers |
| Provides system-level metrics | Provides container-level metrics |
| Tracks CPU, memory, disk, and network | Tracks container CPU, memory, and network |
| Useful for infrastructure monitoring | Useful for container monitoring |

Both exporters complement each other and provide better visibility into infrastructure health.

## Task 3 – Grafana Setup

Grafana was added to the Docker Compose stack to visualize the collected metrics.

### Implementation

- Deployed Grafana using the Grafana Enterprise Docker image.
- Exposed port 3000.
- Configured persistent storage for Grafana data.
- Started Grafana alongside Prometheus and the exporters.

### Prometheus Datasource Configuration

Configured Prometheus as Grafana's data source.

The internal Docker service address was used instead of localhost because Grafana and Prometheus communicate over the same Docker network.

Datasource URL: http://prometheus:9090

Verified the connection using Grafana's Save & Test functionality.

## Task 4 – Custom Grafana Dashboard

Created a custom dashboard named **DevOps Observability Overview**.

The dashboard provides an overview of host and container health.

### Dashboard Panels

1. **CPU Usage:** Displays overall host CPU utilization as a gauge.
2. **Memory Usage:** Shows the percentage of host memory currently used.
3. **Container CPU Usage:** Displays CPU consumption by individual containers over time.
4. **Container Memory Usage:** Compares memory consumption across containers.
5. **Disk Usage:** Displays root filesystem utilization.

Configured visualizations such as gauges, time-series graphs, bar charts, and stat panels to make monitoring easier.

## Task 5 – Grafana Datasource Provisioning

Configured Grafana datasource provisioning using YAML files.

### Implementation

- Created the Grafana provisioning directory structure.
- Added a datasource configuration file.
- Configured Prometheus as the default datasource.
- Mounted the provisioning directory into the Grafana container.

### Why Use YAML Provisioning?

- Makes configuration repeatable.
- Reduces manual setup.
- Helps maintain consistency across environments.
- Makes infrastructure easier to reproduce.
- Supports version control and automation.

With provisioning, Grafana can automatically configure its Prometheus datasource whenever the monitoring stack starts.

## Task 6 – Import Community Dashboards

Explored pre-built Grafana dashboards to improve monitoring visibility.

### Imported Dashboards

- **Dashboard ID 1860 – Node Exporter Full:** Provides detailed host-level monitoring, including CPU, memory, disk, and network metrics.
- **Dashboard ID 193 – Docker Monitoring:** Provides Docker container monitoring and resource utilization visualizations.

Selected Prometheus as the datasource while importing the dashboards.

## Final Docker Compose Stack

The final observability environment contains:

| Service | Purpose | Port |
|---|---|---|
| Prometheus | Metrics collection and storage | 9090 |
| Node Exporter | Host monitoring | 9100 |
| cAdvisor | Container monitoring | 8080 |
| Grafana | Metrics visualization | 3000 |
| Notes App | Application monitoring target | 8000 |

## Troubleshooting

During implementation, some monitoring targets and Grafana connectivity issues required troubleshooting.

Key checks included:

- Verifying that all Docker containers were running.
- Checking whether Prometheus and exporters shared the same Docker network.
- Reviewing container logs for startup errors.
- Verifying Grafana connectivity through its local endpoint.
- Checking EC2 Security Group inbound rules.
- Ensuring Prometheus used Docker service names to communicate with exporters.

## Key Learnings

- Understanding the difference between host-level and container-level monitoring.
- Learning how Node Exporter exposes Linux system metrics.
- Understanding how cAdvisor collects Docker container metrics.
- Configuring Prometheus to scrape multiple monitoring targets.
- Connecting Grafana with Prometheus.
- Building custom dashboards using PromQL.
- Importing community dashboards.
- Automating Grafana datasource configuration using YAML provisioning.
- Understanding Docker networking in an observability environment.

## Conclusion

Day 74 helped me understand how to monitor infrastructure and containerized applications using Prometheus, Node Exporter, cAdvisor, and Grafana.

Instead of relying only on raw metrics and PromQL queries, I can now visualize system health through Grafana dashboards.

This is an important step toward building production-ready observability systems.

**Challenge:** #90DaysOfDevOps  
**Credit:** TrainWithShubham / Shubham Londhe