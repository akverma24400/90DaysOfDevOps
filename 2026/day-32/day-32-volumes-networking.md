# Day 32 – Docker Volumes & Networking

## Overview

Today I learned how Docker volumes keep important data safe and how Docker networks help containers communicate with each other. These are important because containers are temporary by design: deleting a container can remove its internal data, and applications such as a web app and database need a reliable way to connect.

## Screenshots

To see my working screenshots for this task, open the [images folder](./images/).

## Task 1: Data Without a Volume

I created data inside a MySQL/Postgres container and then stopped and removed the container.

**Result:** The data was lost because container storage is temporary. Data stored only inside a container is deleted along with that container.

## Task 2: Named Volumes

I created a named volume and attached it to a database container. A named volume is managed by Docker and exists separately from the container.

```bash
docker volume create db-data
docker volume ls
docker volume inspect db-data
```

**Result:** After removing the old container and creating a new database container with the same volume, the data was still available. The volume kept the database files safe even though the container changed.

## Task 3: Bind Mounts

I created an `index.html` file in a folder on the EC2 host and bind-mounted that folder into an Nginx container.

```bash
docker run -d --name website -p 8080:80 \
  -v /home/ubuntu/website:/usr/share/nginx/html nginx
```

When I edited `index.html` on the host and refreshed the browser, the changes appeared immediately. This happened because the container was directly using the same folder from the host machine.

| Named Volume | Bind Mount |
|---|---|
| Managed by Docker | Uses a folder path on the host machine |
| Docker controls its location | I can see and edit the files directly |
| Best for database/application data | Best for website files and local development |

## Task 4: Default Bridge Network

```bash
docker network ls
docker network inspect bridge
```

- Containers on the default `bridge` network can communicate using their IP addresses.
- They cannot normally communicate using container names.
- I used `docker network inspect bridge` to view connected containers and their IP details.

## Task 5: Custom Bridge Network

```bash
docker network create my-app-net
docker run -dit --name frontend --network my-app-net alpine sh
docker run -dit --name backend --network my-app-net alpine sh
docker exec -it frontend ping -c 3 backend
```

**Result:** Containers on a custom bridge network can communicate using container names, for example `frontend` can ping `backend`.

Custom networks provide Docker DNS, so `frontend` can find `backend` by name. This is better than using IP addresses because a container IP address may change when the container is recreated.

## Task 6: Database and App Together

I created a custom network called `project-net` and ran a MySQL database container with persistent storage. The database container is named `db-server`.

```bash
docker network create project-net

docker run -d --name db-server --network project-net \
  -v /home/ubuntu/project-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=root123 \
  -e MYSQL_DATABASE=company \
  mysql:9.7
```

Any application container connected to `project-net` can connect to the database using the hostname `db-server`. Docker resolves this name automatically because both containers are on the same custom network.

## Key Learning

- Use volumes to keep important data after a container is removed.
- Use bind mounts to share files between the host and a container.
- Use custom Docker networks for simple and reliable container-to-container communication.
