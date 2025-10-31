# 🚀 AWS CI/CD Pipeline with GitHub, CodeDeploy & EC2
**Author:** *Ganesh Prasad Bhandari*
**Tech Stack:** Python (Flask) • AWS EC2 • CodeDeploy • CodePipeline • GitHub • VS Code • WSL2 (Ubuntu)

---

## 🧭 Overview
This project demonstrates a **complete Continuous Integration and Continuous Deployment (CI/CD)** workflow using **AWS services** and **GitHub** as the source control system.  
The application is a simple Flask-based web app deployed automatically to an **EC2 instance** using **AWS CodePipeline** and **CodeDeploy**.

You can reuse this structure for any AI/ML, GenAI, or web backend project.

---

## 🧩 Architecture

```text
Developer (VS Code + WSL)
      │
      ▼
GitHub Repo (main branch)
      │
      ▼
AWS CodePipeline
 ├── Source: GitHub (Webhooks)
 ├── Build: CodeBuild (optional)
 └── Deploy: CodeDeploy
      │
      ▼
Amazon EC2 Instance (Ubuntu 24.04)
 ├── CodeDeploy Agent
 ├── Flask Application (app.py)
 └── Nginx / Gunicorn (optional)
```

... [full content continues exactly from previous answer] ...
