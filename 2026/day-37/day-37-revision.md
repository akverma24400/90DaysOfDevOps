# Day 37 – Docker Revision & Cheat Sheet

## Goal

Day 37 was a revision day for Docker concepts learned from Days 29–36. The focus was on reviewing Docker commands, Dockerfiles, volumes, networking, Docker Compose, multi-stage builds, Docker Hub, healthchecks, and container dependencies.

## What I Revised

- Running containers in interactive and detached modes
- Managing containers and images
- Docker image layers and build cache
- Writing Dockerfiles using `FROM`, `RUN`, `COPY`, `WORKDIR`, and `CMD`
- Docker volumes and bind mounts
- Custom Docker networks and container communication
- Multi-container applications with Docker Compose
- Environment variables and `.env` files
- Multi-stage Docker builds
- Pushing images to Docker Hub
- Healthchecks and `depends_on`

## Self-Assessment

| Topic | Status |
| --- | --- |
| Run containers from Docker Hub | Can do |
| List, stop, remove containers and images | Can do |
| Image layers and caching | Can do |
| Write a Dockerfile from scratch | Can do |
| CMD vs ENTRYPOINT | Shaky |
| Build and tag a custom image | Can do |
| Named volumes | Can do |
| Bind mounts | Shaky |
| Custom networks and container communication | Can do |
| Docker Compose for multi-container apps | Can do |
| Environment variables and `.env` in Compose | Can do |
| Multi-stage Dockerfile | Can do |
| Push an image to Docker Hub | Can do |
| Healthchecks and `depends_on` | Can do |

## Quick-Fire Answers

1. **Image vs container:** An image is a read-only template used to create containers. A container is a running or stopped instance of an image.
2. **Data after removing a container:** Data stored only inside the container is deleted. Use a volume or bind mount to keep it.
3. **Communication on a custom network:** Containers use each other's service or container name as the hostname, for example `http://backend:5000`.
4. **`docker compose down -v`:** It stops and removes services, networks, and named volumes. `docker compose down` keeps named volumes.
5. **Why multi-stage builds:** They copy only the required final build output into the final image, making images smaller and safer.
6. **`COPY` vs `ADD`:** `COPY` simply copies files. `ADD` has extra features such as extracting local tar files and downloading URLs, so `COPY` is preferred in most cases.
7. **`-p 8080:80`:** Maps port `8080` on the host machine to port `80` inside the container.
8. **Check Docker disk usage:** Run `docker system df`.

## Weak Spots Revisited

### 1. CMD vs ENTRYPOINT

- `CMD` sets the default command or arguments and can be easily replaced when the container starts.
- `ENTRYPOINT` sets the main executable for the container; extra values given at runtime are passed as its arguments.

Example:

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

Running `docker run my-app test.py` executes `python test.py`.

### 2. Bind Mounts

A bind mount connects a folder from the host machine to a folder inside the container. It is useful during development because code changes on the host are immediately available in the container.

```bash
docker run -v "$(pwd):/app" -p 3000:3000 node-app
```

## Files Included

- `docker-cheatsheet.md` – Quick Docker commands organized by category.
- `day-37-revision.md` – Self-assessment checklist and revision answers.

## Key Takeaway

Docker becomes easier when the commands are practiced repeatedly. This revision helped connect the full workflow: build an image, run containers, persist data, connect services, manage them with Compose, and ship the final image to Docker Hub.

---

Part of my **#90DaysOfDevOps** learning journey.
