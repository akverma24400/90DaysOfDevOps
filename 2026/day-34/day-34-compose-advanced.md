# Day 34 – Docker Compose: Advanced Multi-Container Apps

## Overview

Today I created a production-like multi-container application using Docker Compose. The stack contains a web application, a database, and Redis cache.

## Application Stack

- **Web App:** Runs the application and is built using a custom Dockerfile.
- **Database:** Stores application data using a named volume.
- **Redis:** Provides fast in-memory caching.

## Tasks Completed

### 1. Three-Service Stack

Created a `docker-compose.yml` file containing the web app, database, and Redis services.

### 2. Healthcheck and Dependencies

- Added a healthcheck to the database.
- Used `depends_on` with `condition: service_healthy`.
- The web app now waits until the database is ready before starting.

### 3. Restart Policies

- `restart: always` restarts a container whenever it stops, including after a Docker restart.
- `restart: on-failure` restarts it only when the process exits with an error.

Use `always` for important long-running services such as databases. Use `on-failure` for jobs or apps that should restart only after an unexpected error.

### 4. Custom Dockerfile

Used `build:` in Docker Compose to build the web app from its Dockerfile.

After changing the application code, I rebuilt and restarted it with:

```bash
docker compose up -d --build
```

### 5. Networks, Volumes, and Labels

- Created a custom network for service communication.
- Created a named volume for persistent database data.
- Added labels to organize and identify services.

## Testing Commands

```bash
docker compose down
docker compose up -d --build
docker compose ps
docker compose logs -f
docker kill <database-container-name>
```

The database became healthy before the web app started. Its data remained available after the containers were recreated, and the restart policy successfully brought the database container back after it was stopped.

## Files Created

- `docker-compose.yml`
- `Dockerfile`
- Application source file
- `day-34-compose-advanced.md`

## Conclusion

This task helped me understand service dependencies, healthchecks, restart policies, custom builds, persistent storage, and isolated networking in Docker Compose.
