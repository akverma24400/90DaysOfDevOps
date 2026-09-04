# Day 36 – Dockerize a Full Todo List Application

This project is a **Todo List application** built with Node.js and PostgreSQL. It lets users add, view, update, and manage their daily tasks. The complete application is Dockerized, so it can be started with a single Docker Compose command.

## What I Practised

- Created a Dockerfile for the Node.js application
- Used Docker Compose to run the application and PostgreSQL database together
- Configured environment variables through a `.env` file
- Added a persistent Docker volume for PostgreSQL data
- Used a custom Docker network for container communication
- Added a PostgreSQL healthcheck and made the app wait for the database
- Tagged and pushed the application image to Docker Hub

## Project Services

| Service | Description | Port |
| --- | --- | --- |
| `app` | Node.js Todo List application | `3000` |
| `db` | PostgreSQL database | `5432` |

## Prerequisites

- Docker
- Docker Compose plugin

## Environment Variables

Create a `.env` file in the project root. Do not commit this file to GitHub.

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=todolist_db
DATABASE_URL=postgresql://postgres:your_secure_password@db:5432/todolist_db
PORT=3000
```

> Replace `your_secure_password` with your own strong password. The hostname in `DATABASE_URL` must be `db`, which is the database service name in Docker Compose.

## Run the Application with Docker Compose

1. Clone the repository:

   ```bash
   git clone https://github.com/akverma24400/<your-repository-name>.git
   cd <your-repository-name>
   ```

2. Create the `.env` file using the variables above.

3. Build and start all services:

   ```bash
   docker compose up -d --build
   ```

4. Check container status:

   ```bash
   docker compose ps
   ```

5. Open the application in your browser:

   ```text
   http://localhost:3000
   ```

6. View application logs when needed:

   ```bash
   docker compose logs -f app
   ```

7. Stop the application:

   ```bash
   docker compose down
   ```

## Data Persistence

PostgreSQL data is stored in a named Docker volume. Your tasks remain available even after running `docker compose down`.

To remove the application **and** database data completely:

```bash
docker compose down -v
```

## Docker Hub Image

Docker Hub: `https://hub.docker.com/r/akash24400/<your-image-name>`

Pull the image directly with:

```bash
docker pull akash24400/<your-image-name>:latest
```

## Fresh-Run Test

I verified the project by bringing down the Docker Compose stack, rebuilding/running it again, and confirming that the application could connect to PostgreSQL successfully.

```bash
docker compose down
docker compose up -d --build
docker compose ps
```

## Learning Outcome

This project helped me understand how to package a complete application with Docker, connect it to a database using Docker Compose, persist database data with volumes, use healthchecks for reliable startup, and ship the image to Docker Hub.

---

**Day 36 of #90DaysOfDevOps**
