# Docker Cheat Sheet

A quick reference for everyday Docker work.

## Container Commands

| Command | Purpose |
| --- | --- |
| `docker run nginx` | Create and run a container from an image. |
| `docker run -it ubuntu bash` | Run an interactive Ubuntu container with Bash. |
| `docker run -d --name web -p 8080:80 nginx` | Run Nginx in the background and map host port 8080 to container port 80. |
| `docker ps` | List running containers. |
| `docker ps -a` | List all containers, including stopped ones. |
| `docker stop <container>` | Gracefully stop a container. |
| `docker start <container>` | Start a stopped container. |
| `docker restart <container>` | Restart a container. |
| `docker rm <container>` | Remove a stopped container. |
| `docker rm -f <container>` | Force-remove a running container. |
| `docker exec -it <container> sh` | Open a shell inside a running container. |
| `docker logs <container>` | View container logs. |
| `docker logs -f <container>` | Follow container logs live. |
| `docker inspect <container>` | Show detailed container configuration and network details. |

## Image Commands

| Command | Purpose |
| --- | --- |
| `docker pull nginx:alpine` | Download an image from Docker Hub. |
| `docker images` | List local images. |
| `docker image ls` | List local images. |
| `docker build -t my-app:1.0 .` | Build and tag an image using the Dockerfile in the current folder. |
| `docker tag my-app:1.0 username/my-app:1.0` | Create a Docker Hub tag for an image. |
| `docker push username/my-app:1.0` | Push an image to Docker Hub. |
| `docker login` | Authenticate with Docker Hub or a private registry. |
| `docker rmi <image>` | Remove an image. |
| `docker image prune` | Remove unused dangling images. |
| `docker history <image>` | View image layers and their sizes. |

## Volume Commands

| Command | Purpose |
| --- | --- |
| `docker volume create app-data` | Create a named volume. |
| `docker volume ls` | List volumes. |
| `docker volume inspect app-data` | Show volume details. |
| `docker run -v app-data:/data nginx` | Mount a named volume inside a container. |
| `docker run -v "$(pwd):/app" node` | Bind-mount the current host folder into `/app`. |
| `docker volume rm app-data` | Remove a volume. |
| `docker volume prune` | Remove unused volumes. |

## Network Commands

| Command | Purpose |
| --- | --- |
| `docker network create app-network` | Create a custom bridge network. |
| `docker network ls` | List Docker networks. |
| `docker network inspect app-network` | Show connected containers and network settings. |
| `docker run -d --name db --network app-network mysql:8` | Run a container on a custom network. |
| `docker network connect app-network <container>` | Connect an existing container to a network. |
| `docker network disconnect app-network <container>` | Disconnect a container from a network. |

> Containers on the same custom network can communicate using the container or service name, such as `db` or `backend`.

## Docker Compose Commands

| Command | Purpose |
| --- | --- |
| `docker compose up` | Create and start services; logs stay attached to the terminal. |
| `docker compose up -d` | Create and start services in detached mode. |
| `docker compose down` | Stop and remove Compose services and networks. |
| `docker compose down -v` | Also remove named volumes created by Compose. |
| `docker compose ps` | Show Compose service status. |
| `docker compose logs` | View logs for all services. |
| `docker compose logs -f <service>` | Follow logs for one service. |
| `docker compose build` | Build service images. |
| `docker compose build --no-cache` | Build service images without using cache. |
| `docker compose up -d --build` | Build images and start services. |
| `docker compose exec <service> sh` | Open a shell inside a running Compose service. |

## Cleanup and Disk Usage

| Command | Purpose |
| --- | --- |
| `docker system df` | Check Docker disk usage. |
| `docker container prune` | Remove all stopped containers. |
| `docker image prune -a` | Remove images not used by any container. |
| `docker network prune` | Remove unused networks. |
| `docker system prune` | Remove unused containers, networks, and dangling images. |
| `docker system prune -a --volumes` | Aggressively remove unused Docker resources, including unused volumes. |

> Be careful with prune commands: review anything important before running them.

## Dockerfile Instructions

| Instruction | Purpose |
| --- | --- |
| `FROM node:22-alpine` | Choose the base image. |
| `WORKDIR /app` | Set the working directory inside the image. |
| `COPY package*.json ./` | Copy files from the build context into the image. |
| `RUN npm ci` | Run a command while building the image. |
| `COPY . .` | Copy the remaining application files. |
| `EXPOSE 3000` | Document the port the application listens on. |
| `ENV NODE_ENV=production` | Set an environment variable in the image. |
| `CMD ["node", "index.js"]` | Set the default command; it can be overridden at runtime. |
| `ENTRYPOINT ["python"]` | Set the main executable for the container. |

## Useful Patterns

### Build and run an application

```bash
docker build -t my-app:1.0 .
docker run -d --name my-app -p 3000:3000 my-app:1.0
```

### Tag and push to Docker Hub

```bash
docker login
docker tag my-app:1.0 akash24400/my-app:1.0
docker push akash24400/my-app:1.0
```

### Inspect a failing container

```bash
docker ps -a
docker logs <container-name>
docker inspect <container-name>
```
