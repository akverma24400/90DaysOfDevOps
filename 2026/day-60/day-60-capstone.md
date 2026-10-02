# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

A Kubernetes capstone that combines application deployment, configuration, persistent storage, health checks, self-healing, and autoscaling in one WordPress + MySQL stack.

This README explains the solution and its verification steps. Kubernetes manifests and commands are maintained separately.

## Objective

Run WordPress in the **capstone** namespace with two application replicas and a persistent MySQL database. Publish a blog post, test recovery after Pod deletion, and configure CPU-based autoscaling. Optionally compare the manual deployment with a Helm release.

## Prerequisites

- A working Kubernetes cluster, such as Kind or Minikube.
- Enough available CPU and memory for MySQL and at least two WordPress Pods.
- A working StorageClass and provisioner, or a compatible pre-created PersistentVolume.
- Metrics Server providing Pod resource metrics for the HPA.
- Helm and access to the chosen chart and its container images for the bonus task.

## Application Architecture

The WordPress Service directs traffic to ready WordPress Pods. Both replicas connect to the same MySQL database using its stable DNS name. MySQL stores its database files on a persistent volume claimed by the StatefulSet.

| Component | Purpose |
| --- | --- |
| Namespace | Groups the capstone resources |
| Secret | Supplies MySQL initialization settings and application credentials |
| ConfigMap | Supplies the WordPress database host and database name |
| MySQL Headless Service | Enables stable DNS discovery for the database Pod |
| MySQL StatefulSet and PVC | Maintain database identity and persistent storage |
| WordPress Deployment | Maintains the application replicas |
| WordPress NodePort Service | Exposes the application through a node port |
| HorizontalPodAutoscaler | Adjusts the WordPress replica count using CPU utilization |

## Task 1: Create the Namespace

Create **capstone** and make it the default namespace for the current Kubernetes context. Keep all application resources in this namespace so they can be inspected and cleaned up together.

**Verification:** The namespace exists, and the current context uses it by default.

## Task 2: Deploy MySQL

### Database configuration

Create a Secret with **stringData** containing these four keys:

| Secret key | Purpose |
| --- | --- |
| MYSQL_ROOT_PASSWORD | Password for the MySQL root account |
| MYSQL_DATABASE | Initial database name: wordpress |
| MYSQL_USER | Application database user |
| MYSQL_PASSWORD | Password for the application database user |

The MySQL container receives these settings through **envFrom**. WordPress uses the application user credentials to connect to the database.

### Networking and StatefulSet

Create a Headless Service named **mysql**, with **clusterIP** set to **None**, exposing port **3306**.

Create a StatefulSet named **mysql** with **one replica**, using **mysql:8.0**. Set its governing Service name to **mysql**, and ensure the Service selector matches the database Pod labels.

The database Pod is named **mysql-0**. With the standard cluster domain, its stable hostname is **mysql-0.mysql.capstone.svc.cluster.local**.

### Persistent storage and resources

Use **volumeClaimTemplates** to request a **1Gi** volume, with **ReadWriteOnce** access, mounted at **/var/lib/mysql**.

| Resource | Request | Limit |
| --- | --- | --- |
| CPU | 250m | 500m |
| Memory | 512Mi | 1Gi |

The PVC must bind to suitable storage before MySQL can run. When the Pod is replaced, the StatefulSet reuses its existing claim. A single MySQL replica demonstrates recovery and persistence; it does not provide database replication.

**Verification:** The PVC is Bound, mysql-0 is running, and a database connection using the application credentials lists the **wordpress** database.

## Task 3: Deploy WordPress

### Application configuration

Create a ConfigMap with the following values:

| ConfigMap key | Value |
| --- | --- |
| WORDPRESS_DB_HOST | mysql-0.mysql.capstone.svc.cluster.local:3306 |
| WORDPRESS_DB_NAME | wordpress |

Create a Deployment named **wordpress** with **two replicas**, using **wordpress:latest** as specified in the challenge.

Load the ConfigMap through **envFrom**. Map credentials from the MySQL Secret using **secretKeyRef**:

| WordPress environment variable | MySQL Secret key |
| --- | --- |
| WORDPRESS_DB_USER | MYSQL_USER |
| WORDPRESS_DB_PASSWORD | MYSQL_PASSWORD |

Define CPU and memory requests and limits for each WordPress container. The following are suggested starting values for this lab:

| Resource | Request | Limit |
| --- | --- | --- |
| CPU | 100m | 500m |
| Memory | 256Mi | 512Mi |

Requests guide scheduling and provide the CPU baseline for autoscaling. Limits cap CPU use and constrain memory consumption.

For consistent logins across replicas, provide the same WordPress authentication keys and salts to every Pod through a Secret. The official image can otherwise generate different values for each instance, which can invalidate login cookies when traffic moves between Pods.

### Health checks

Configure both probes to check **/wp-login.php** on port **80**:

- **Readiness probe:** Determines whether a Pod can receive Service traffic.
- **Liveness probe:** Restarts a container after repeated probe failures.

Allow enough startup time for WordPress and MySQL initialization. Because the login page can depend on database availability, overly aggressive liveness checks may cause unnecessary restarts during a database outage.

**Verification:** Both WordPress Pods show **1/1 Ready** and **Running**, with no repeated probe failures.

## Task 4: Expose WordPress

Create a Service named **wordpress**, of type **NodePort**, with a selector matching the WordPress Pod labels.

| Port setting | Value |
| --- | --- |
| Service port | 80 |
| Target container port | 80 |
| NodePort | 30080 |

For Minikube, use its Service access helper to obtain a reachable address. For Kind, forward local port **8080** to Service port **80**, then open [WordPress locally](http://localhost:8080).

Complete the setup wizard, create the administrator account, and publish a sample blog post.

**Verification:** The setup page loads, installation completes, and the published post is visible.

## Task 5: Test Self-Healing and Persistence

### WordPress recovery

Delete one WordPress Pod and observe the Deployment create a replacement. Wait for the replacement to become ready, then refresh the site.

A port-forward session is attached to a selected Pod. If that Pod is deleted, restart the session before checking the site again.

### MySQL recovery

Delete **mysql-0** and observe the StatefulSet recreate it with the same name and existing PVC. Wait for MySQL to accept connections, then refresh WordPress and check the sample post.

A temporary database outage is expected while the single MySQL Pod recovers.

**Expected result:** The blog post remains because its content is stored in the persistent database.

### What this persistence test covers

The MySQL PVC preserves database content such as posts, users, and site settings. Uploaded media, installed plugins, and themes are files and are not protected by that database volume.

A complete WordPress setup with multiple replicas also needs consistent application files and shared persistent storage for uploads, such as suitable **ReadWriteMany** storage. This lab's database persistence test does not verify file persistence.

## Task 6: Configure Horizontal Pod Autoscaling

Create an HPA targeting the **wordpress** Deployment.

| Setting | Value |
| --- | --- |
| Metric | CPU utilization |
| Target average utilization | 50% |
| Minimum replicas | 2 |
| Maximum replicas | 10 |

The CPU target is measured against the containers' **CPU requests**. With the suggested request of 100m, 50% corresponds to an average of 50m per WordPress container.

Metrics Server must supply usable metrics. An unknown CPU reading means the HPA is not yet receiving the information it needs. Scaling also depends on available cluster capacity.

**Verification:** The HPA shows a minimum of 2, maximum of 10, a 50% target, and a numeric current CPU reading. Remaining at two replicas under light traffic is expected; this alone does not prove scaling under load.

## Task 7: Compare with Helm — Bonus

Install the Bitnami WordPress chart as **wp-helm** in a separate namespace, such as **capstone-helm**. Check the selected chart version's storage requirements and current container-image access requirements before installation.

The Bitnami chart includes a MariaDB dependency by default, so its database configuration differs from this manual MySQL deployment.

| Comparison | Manual manifests | Helm chart |
| --- | --- | --- |
| Resource definition | Each application resource is explicitly defined | Templates generate resources from chart values |
| Configuration | Direct changes to resource definitions | Changes through values supported by the chart |
| Control | Direct control over every manifest field | Control through values, templates, or chart customization |
| Maintenance | Resources are managed individually | Related resources are managed as a release |
| Resource count | Determined by this design and controller-generated objects | Depends on chart version and enabled features |

Compare both namespaces using the same resource types. Include Secrets, ConfigMaps, and PVCs as well as workloads and Services; the standard workload overview does not list every resource.

Record the actual counts from the cluster. Uninstall the Helm release after comparison, then inspect and clean up any retained claims before removing the bonus namespace.

## Task 8: Clean Up and Reflect

Capture the final application and resource screenshots before cleanup. Delete the **capstone** namespace after completing verification, and reset the current context's default namespace to **default**.

Namespace deletion removes namespaced resources, including the PVC. PersistentVolumes are cluster-scoped, and their storage follows the volume's reclaim policy:

- **Delete:** The volume and backing storage are removed when supported by the provisioner.
- **Retain:** The volume and stored data remain for manual handling.

**Verification:** The namespace has disappeared, its application resources are gone, the default namespace is restored, and any remaining volumes have been reviewed.

## Twelve Concepts Practiced

| Concept | Application in this capstone |
| --- | --- |
| Namespace | Groups the application resources |
| Secret | Provides database settings and credentials |
| ConfigMap | Provides non-sensitive WordPress configuration |
| PersistentVolumeClaim | Requests persistent MySQL storage |
| StatefulSet | Maintains MySQL identity and storage association |
| Headless Service | Provides database Pod discovery |
| Deployment | Maintains WordPress replicas |
| NodePort Service | Exposes WordPress |
| Resource requests and limits | Control scheduling requirements and resource consumption |
| Probes | Assess readiness and trigger container recovery |
| HPA | Adjusts application replicas using CPU metrics |
| Helm | Packages and manages an optional comparison deployment |

## Verification and Screenshots

Complete this checklist using the actual deployment results:

- [ ] The capstone namespace contains the WordPress and MySQL stack.
- [ ] MySQL has a Bound PVC and the wordpress database.
- [ ] Both initial WordPress replicas are running and ready.
- [ ] The WordPress setup wizard completes and a blog post is published.
- [ ] A deleted WordPress Pod is replaced.
- [ ] MySQL recovers after Pod deletion and the blog post remains.
- [ ] The HPA reports valid metrics, a 50% target, and limits of 2–10 replicas.
- [ ] The optional Helm comparison and resource counts are recorded.
- [ ] Cleanup and the final storage state are verified.

Add screenshots of the **running WordPress site with the sample post** and the **capstone workload overview**. Additional evidence can show the Bound PVC, HPA status, and the post after MySQL recovery.

## References

- [Kubernetes: StatefulSet basics](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/)
- [Kubernetes: Persistent Volumes and reclaim policies](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Kubernetes: Horizontal Pod Autoscaling](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/)
- [Bitnami: WordPress Helm chart and storage requirements](https://github.com/bitnami/charts/blob/main/bitnami/wordpress/README.md)
- [Docker: Official WordPress image configuration](https://hub.docker.com/_/wordpress)
