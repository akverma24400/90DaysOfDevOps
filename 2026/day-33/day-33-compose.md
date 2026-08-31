# Day 33 – Docker Compose: Multi-Container Basics

## Overview

Today I learned how Docker Compose helps us run and manage multiple containers using a single YAML file.

It automatically manages containers, networks, volumes, ports, and environment variables.

---

## Task 1: Install and Verify

I checked whether Docker Compose was available and verified its installed version.

---

## Task 2: Nginx with Docker Compose

I created a `compose-basics` folder and added a Docker Compose file for Nginx.

I learned how to:

- Start Nginx using Docker Compose
- Map the container port to the host
- Access Nginx through the browser
- Stop and remove the service

---

## Task 3: WordPress and MySQL

I created a multi-container application containing:

- WordPress as the frontend application
- MySQL as the database
- A named volume for database persistence

Docker Compose automatically created a common network for both services. WordPress connected to MySQL using the MySQL service name instead of an IP address.

### Data Persistence Test

I configured WordPress and then stopped and restarted the application. My WordPress data remained available because MySQL stored its data in a named volume.

---

## Task 4: Docker Compose Commands

I practised commands to:

- Start services in detached mode
- Check running services
- View logs of all services
- View logs of a specific service
- Stop services without removing them
- Remove containers and networks
- Rebuild images after making changes
- Validate the Compose configuration

> Removing volumes will also delete stored database data, so it should be done carefully.

---

## Task 5: Environment Variables

I learned two ways to provide environment variables:

1. Add variables directly to the Compose file.
2. Store variables inside a `.env` file and reference them from the Compose file.

Using a `.env` file keeps configuration separate and makes the Compose file easier to manage. The `.env` file should be added to `.gitignore` because it may contain sensitive information such as database passwords.

---

## Key Learnings

- Docker Compose manages multiple containers with a single command.
- Services communicate using their service names.
- Compose automatically creates a shared network.
- Named volumes keep data persistent.
- Environment variables make configuration flexible.
- A `.env` file should not be pushed to GitHub.
- Docker Compose makes multi-container applications easier to manage.

---

## Screenshots

The practical screenshots for each task are available in the `images` folder.

---

## Conclusion

Docker Compose simplifies multi-container application management. It allows us to start, stop, connect, and configure multiple services from one YAML file.
