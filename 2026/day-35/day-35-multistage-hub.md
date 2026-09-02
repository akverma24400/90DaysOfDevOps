# Day 35 – Docker Multi-Stage Builds & Docker Hub

## Overview

Today I learned how to reduce Docker image size using multi-stage builds, push images to Docker Hub, manage image tags, and follow Dockerfile best practices.

## Task 1: Single-Stage Image

I created a simple Node.js application and built it using a single-stage Dockerfile.

```bash
docker build -t app:latest .
docker images 
```

The single-stage image contains the application, dependencies, build tools, and other unnecessary files.

## Task 2: Multi-Stage Build

I created `Dockerfile-multistage` with two stages:

- **Builder stage:** Installs the application dependencies.
- **Runner stage:** Copies only the files required to run the application.

```bash
docker build -f Dockerfile-multistage -t day35-app:multistage .
docker images day35-app
```

| Image | Size |
|---|---:|
| Single-stage | `Add size` |
| Multi-stage | `Add size` |

The multi-stage image is smaller because build tools, temporary files, and unnecessary dependencies are not copied into the final image.

## Task 3: Push to Docker Hub

I logged in, tagged the image, and pushed it to Docker Hub.

```bash
docker login
docker tag day35-app:multistage akash24400/day35-app:v1
docker push akash24400/day35-app:v1
```

I verified the uploaded image by pulling it again:

```bash
docker pull akash24400/day35-app:v1
```

## Task 4: Docker Hub Repository

I explored the Docker Hub repository, added a description, and checked the available tags.

- `latest` pulls the image tagged as the default version.
- A specific tag such as `v1` pulls that exact version.

```bash
docker pull akash24400/day35-app:latest
docker pull akash24400/day35-app:v1
```

## Task 5: Image Best Practices

I applied the following Docker best practices:

- Used a small Alpine-based image.
- Used a specific base-image version instead of `latest`.
- Ran the application as a non-root user.
- Combined related `RUN` commands to reduce layers.
- Used `.dockerignore` to exclude unnecessary files.
- Copied only the required application files into the final image.

## Useful Commands

```bash
docker images
docker history day35-app:multistage
docker image inspect day35-app:multistage
docker run -d -p 3000:3000 day35-app:multistage
```

## Conclusion

This task helped me understand how multi-stage builds create smaller and safer Docker images. I also learned how to tag, push, pull, and manage image versions using Docker Hub.
