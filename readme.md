# Automated Deployment Tool (Bash + Docker)

## Overview

This project demonstrates a **Bash-based automated deployment workflow** for containerized applications.  
The tool is designed to automate common deployment tasks on a Linux server such as pulling the latest code, rebuilding Docker images, restarting containers, performing health checks, and supporting rollback if a deployment fails.

The goal of this project is to practice **DevOps-style automation using Bash scripting and Docker**, while understanding how deployment pipelines work in real environments.

---

## Deployment Workflow

The deployment script follows this process:

Developer updates application code  
↓  
Deployment script pulls latest code from repository  
↓  
Docker image is rebuilt  
↓  
Old container is stopped and removed  
↓  
New container is started  
↓  
Application health check is performed  
↓  
If health check fails → rollback to previous version

---

## Project Structure

```
auto-deploy-tool/
│
├── deploy.sh
├── rollback.sh
├── config.conf
├── Dockerfile
├── main.py
├── requirements.txt
│
└── README.md
```

### Folder Description

| File / Folder | Description |
|---------------|-------------|
| deploy.sh | Main script that performs automated deployment |
| rollback.sh | Script used to restore the previous working version |
| config.conf | Configuration file containing deployment settings |
| logs/ | Stores deployment logs generated during execution |
| backups/ | Stores references to previously deployed images |
| Dockerfile | Defines container image used for application |
| main.py | Example FastAPI application used for demonstration |

---

## Configuration

Deployment parameters are stored in `config.conf`.

Example:

```
APP_NAME=myapp
CONTAINER_NAME=myapp_container
IMAGE_NAME=myapp_image
PORT=8000
APP_HEALTH_URL=http://localhost:8000/health
```

These values allow the script to be reused for different applications.

---

## How to Run

Make scripts executable:

```bash
chmod +x deploy.sh
chmod +x rollback.sh
```

Run deployment:

```bash
./deploy.sh
```

Run manual rollback:

```bash
./rollback.sh
```

---

## Logging

Deployment activity is written to the **logs directory**.

Examples of logged events:

- Deployment start time
- Docker image build
- Container restart
- Health check result
- Rollback execution

Log files are generated at runtime and are ignored from Git tracking.

---

## Technologies Used

- Bash scripting
- Docker
- Linux command line
- FastAPI (example application)

---

## Purpose of the Project

This project was created as a **DevOps learning exercise** to understand how automated deployment systems work using simple scripting and containerization tools.

It demonstrates how deployment logic can be implemented without complex orchestration tools.
