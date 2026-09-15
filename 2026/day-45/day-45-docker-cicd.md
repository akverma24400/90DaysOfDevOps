# Day 45 – Docker Build & Push in GitHub Actions

## Goal

Automate building a Docker image and publishing it to Docker Hub whenever code is pushed to the main branch.

## Tools Used

GitHub Actions, Docker, Docker Buildx, Docker Hub, and GitHub Secrets.

## How It Works

1. **Prepare the app:** Keep the application and its Dockerfile in the repository.
2. **Get the code:** GitHub Actions checks out the repository on a runner.
3. **Log in:** GitHub Secrets provide the Docker Hub username and access token.
4. **Build and tag:** Docker creates an image with a latest tag and a short commit SHA tag.
5. **Publish:** The workflow pushes both tags to Docker Hub.
6. **Run:** Pull the image onto a local machine or cloud server and start a container with the required settings and database.

## Why Two Tags?

- **Latest:** Points to the most recently published build.
- **Commit SHA:** Helps identify the build associated with a particular code change.

## Branch Control

Publish images only from the main branch. To test feature branches, the workflow must also trigger on those branches, build the image, and skip publishing. A main-only trigger will not run feature-branch checks.

## Status Badge

A workflow badge in the repository README shows whether the latest workflow run passed or failed.

## Issue Encountered

Docker Hub login failed with “Username required” because the username secret name did not match the workflow. The saved secret was DOCKERHUB_USERNAME, while the workflow referenced DOCKER_USERNAME. The login step and image tags must use the saved name.

## Verification

Check that the workflow passes, both image tags appear on Docker Hub, and the pulled image runs successfully with its required dependencies.

## Key Takeaway

The journey is: push code, build an image, publish it, pull it, and run a container. This workflow automates building and publishing; deployment is a separate step.
