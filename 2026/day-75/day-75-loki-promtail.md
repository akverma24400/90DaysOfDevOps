# Day 75 – Log Management with Loki and Promtail

## Overview

On Day 75 of my DevOps learning journey, I explored log management and learned how to collect, aggregate, and analyze Docker container logs using **Grafana Loki and Promtail**.

Previously, I built a metrics monitoring stack using Prometheus, Node Exporter, cAdvisor, and Grafana. In this task, I extended the observability stack by adding log monitoring, allowing me to investigate not only what is happening in my infrastructure, but also why something is happening.

## Objectives

- Understand the logging pipeline and log aggregation.
- Deploy Grafana Loki as a log storage backend.
- Configure Promtail to collect Docker container logs.
- Integrate Loki with Grafana as a datasource.
- Learn LogQL for querying and filtering logs.
- Correlate metrics and logs for troubleshooting.

---

## 1. Understanding the Logging Pipeline

The logging pipeline consists of the following components:

- **Docker Containers:** Generate application logs and write them to log files on the host.
- **Promtail:** Collects logs, parses them, adds labels, and forwards them to Loki.
- **Loki:** Stores logs and indexes their labels for efficient querying.
- **Grafana:** Provides a centralized interface to explore and visualize logs.
- **Engineer:** Uses metrics and logs together to troubleshoot issues.

### Logging Flow

Docker Containers → Promtail → Loki → Grafana → Engineer

### Why Loki Doesn't Index Full Log Text

Unlike Elasticsearch, Loki does not index every word in the log message. Instead, it indexes labels associated with log streams and stores the actual log content in compressed chunks.

This approach reduces storage requirements, indexing overhead, and operational complexity.

**Trade-off:** Queries that search the actual log content may need to scan more log data than full-text indexed systems, especially when label filters are broad. Choosing appropriate labels and narrowing the time range becomes important for query performance.

---

## 2. Deploying Grafana Loki

Loki is a log aggregation system developed by Grafana Labs. It is designed to store and query logs efficiently using a label-based approach similar to Prometheus.

### Configuration Highlights

- Authentication disabled for the local learning environment.
- HTTP server running on port 3100.
- TSDB index store for log indexing.
- Filesystem storage for log chunks.
- Single-replica configuration for learning purposes.
- Persistent Docker volume to retain Loki data.

### Docker Deployment

Loki was added to the existing Docker Compose monitoring stack and started as a separate service.

### Verification

Loki's readiness endpoint was checked to confirm that the service was running and ready to receive requests.

---

## 3. Deploying Promtail

Promtail is the log collection agent that connects Docker container logs to Loki.

It reads Docker's JSON log files from the host, processes the log entries, attaches labels, and forwards them to Loki.

### Configuration Highlights

- Configured Promtail's HTTP server on port 9080.
- Defined a positions file to track the last-read log location.
- Configured Loki as the log destination.
- Set up Docker log file discovery using file path patterns.
- Enabled the Docker pipeline stage to parse Docker JSON logs.

### Volume Mounts

- Docker container log directory mounted read-only to allow log collection.
- Docker socket mounted to support container metadata discovery.
- Promtail configuration mounted into the container.
- Positions file used to track log ingestion progress.

### Why Positions Files Are Important

Promtail maintains a record of where it stopped reading each log file. This prevents it from unnecessarily rereading logs from the beginning after restarting, helping it continue log collection from the tracked position.

---

## 4. Integrating Loki with Grafana

Grafana provides a centralized interface for monitoring metrics and exploring logs.

Loki was added as a new datasource alongside Prometheus.

### Datasource Configuration

- **Prometheus:** Used for metrics monitoring.
- **Loki:** Used for log aggregation and querying.
- Loki is accessed internally through the Docker network using its service name and port.

After configuring the datasource, Grafana was restarted to load the updated configuration.

### Result

Grafana can now query both metrics and logs from a single interface, making infrastructure monitoring and troubleshooting easier.

---

## 5. LogQL – Querying Logs

LogQL is Loki's query language. It allows users to filter log streams using labels, search log content, and generate log-based metrics.

### Stream Selector

Used to retrieve all Docker logs:

`{job="docker"}`

### Filter by Container

Used to retrieve logs belonging to a specific container:

`{container_name="prometheus"}`

### Keyword Search

Used to find log lines containing the word error:

`{job="docker"} |= "error"`

### Negative Filter

Used to exclude log lines containing a specific keyword:

`{job="docker"} != "health"`

### Regular Expression Filter

Used to find log lines containing HTTP status codes in the 400–599 range:

`{job="docker"} |~ "status=[45]\\d{2}"`

### Count Logs Over Time

Counts log entries within a five-minute window:

`count_over_time({job="docker"}[5m])`

### Log Rate

Calculates the rate of log entries per second over a five-minute window:

`rate({job="docker"}[5m])`

### Top Containers by Log Volume

Identifies the top five containers producing the most logs:

`topk(5, sum by (container_name) (rate({job="docker"}[5m])))`

---

## 6. Challenge – Error Logs from Notes App

### Find Error Logs from notes-app Within the Last Hour

Query:

`{container_name="notes-app"} |= "error"`

This filters the notes-app log stream and returns log lines containing the word error.

In Grafana Explore, set the time range to **Last 1 hour**.

### Count Error Logs Per Minute

Query:

`sum by (container_name) (count_over_time({container_name="notes-app"} |= "error" [1m]))`

This counts the matching error log entries within each one-minute window and groups the results by container name.

---

## 7. Correlating Metrics and Logs in Grafana

One of the most useful capabilities of Grafana is correlating metrics and logs within the same platform.

Metrics can reveal abnormal behavior, such as increased CPU utilization, memory consumption, or traffic spikes. Logs help investigate the events and errors behind those anomalies.

### Prometheus Query

Container CPU usage over the last five minutes:

`rate(container_cpu_usage_seconds_total{name="notes-app"}[5m])`

### Loki Query

Logs from the notes-app container:

`{container_name="notes-app"}`

### Split View

Grafana Explore split view allows two queries to be viewed side by side:

- Left panel – Prometheus metrics
- Right panel – Loki logs

By using the same time range, an engineer can compare resource utilization with log events during the same period.

### Why Metrics and Logs Together Help During Incident Response

Having metrics and logs in the same tool improves incident response because engineers don't need to switch between different monitoring systems.

Metrics quickly identify anomalies and help determine when a problem started. Logs provide context about errors, application events, and failures occurring during that period.

Combining both reduces investigation time, improves troubleshooting accuracy, and helps engineers identify the root cause more efficiently.

---

## 8. Key Learnings

- Understood the fundamentals of log aggregation and centralized logging.
- Learned how Loki stores and indexes log data using labels.
- Configured Promtail to collect Docker container logs.
- Integrated Loki into Grafana as a datasource.
- Practiced LogQL queries for filtering, searching, and counting logs.
- Learned how to correlate infrastructure metrics with application logs.
- Improved my understanding of observability and incident response workflows.

---

## 9. Observability Stack

The monitoring and logging stack now includes:

- **Prometheus** – Metrics collection and monitoring.
- **Node Exporter** – Host-level metrics.
- **cAdvisor** – Container-level metrics.
- **Grafana** – Metrics visualization and log exploration.
- **Loki** – Log aggregation and storage.
- **Promtail** – Log collection and forwarding.

---

## Conclusion

Day 75 strengthened my understanding of observability by introducing centralized log management using Loki and Promtail.

With metrics and logs available in Grafana, I can monitor resource utilization, investigate application errors, and correlate system behavior with log events more effectively.

This is an important step toward building monitoring systems that are not just able to detect problems, but also help engineers understand and troubleshoot them.

**Day 75 completed – 90DaysOfDevOps 🚀**

#90DaysOfDevOps #DevOps #Grafana #Loki #Promtail #Logging #Observability #Docker #Prometheus #CloudComputing #LearningInPublic
