# 🔁 PROJECT CONTINUATION GUIDE
### Project: AWS CI/CD for ML Model Deployment (Ganesh Prasad Bhandari)

---

## 🎯 Project Objective
This project demonstrates a **complete CI/CD pipeline** for deploying a **Machine Learning Flask Application** using **AWS services** — CodePipeline, CodeBuild, CodeDeploy, and EC2 — integrated with GitHub.  
It follows a real-world **MLOps/DevOps architecture** suitable for enterprise environments.

---

## 📁 Current Repository
**GitHub:** [aws_codepipeline_cicd_project_2025](https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025)

### Current Structure
aws_codepipeline_cicd_project_2025/
│
├── src/ ← ML logic (data_ingestion, data_transformation, model_trainer, etc.)
├── templates/ ← Front-end HTML templates
├── app.py ← Flask entrypoint with /predict, /predictdata, /health
├── wsgi.py ← Gunicorn entrypoint
├── requirements.txt ← Python dependencies
├── .gitignore
├── LICENSE
├── README.md ← Public-facing project description
└── PROJECT_CONTINUATION_GUIDE.md ← Internal context blueprint


---

## ✅ Current Progress
- [x] GitHub repo setup and synced with VS Code  
- [x] Virtual environment created (`myvenv`)  
- [x] ML project integrated (based on Krish Naik’s architecture)  
- [x] Flask app working locally with `/health` and `/predict` endpoints  
- [x] All files committed and pushed to GitHub  

Next steps: AWS pipeline configuration.

---

## 🧠 Target Architecture (AWS CI/CD)
GitHub → CodePipeline → CodeBuild → CodeDeploy → EC2 (Gunicorn + Flask)



| AWS Service | Role |
|--------------|------|
| **CodePipeline** | Automates build → test → deploy workflow |
| **CodeBuild** | Installs dependencies, runs tests, packages code |
| **CodeDeploy** | Deploys artifacts to EC2 instance |
| **EC2** | Hosts production app |
| **IAM Roles** | CodePipelineRole, CodeBuildRole, CodeDeployRole, EC2Role |

---

## ⚙️ AWS Configuration Checklist

### EC2
- Instance type: `t2.micro` (Amazon Linux 2023)
- Open ports: 22 (SSH), 80 (HTTP)
- Install CodeDeploy agent:
  ```bash
  sudo dnf update -y
  sudo dnf install -y ruby wget
  cd /tmp
  REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
  wget https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install
  chmod +x ./install
  sudo ./install auto
  sudo systemctl status 
  codedeploy-agent

Tag instance:
Key: Role
Value: mlproject-ec2


CodeDeploy
Application: mlproject-app

Deployment group: mlproject-dg

Tag filter: Role = mlproject-ec2

CodeBuild
Project: mlproject-build

Buildspec file: buildspec.yml

Runtime: aws/codebuild/standard:7.0

CodePipeline
Source: GitHub (main branch)

Build: CodeBuild project

Deploy: CodeDeploy group

Trigger: On push to main branch

📄 Files To Add Next
File	Purpose
buildspec.yml	Commands for CodeBuild (install → test → package)
appspec.yml	Instructions for CodeDeploy (where to copy and what to run)
scripts/install_dependencies.sh	Installs Python, Gunicorn
scripts/start_server.sh	Starts Gunicorn
scripts/stop_server.sh	Stops Gunicorn
systemd service	Optional: run Gunicorn automatically on EC2 reboot

🚀 Future Enhancements (Phase 2)
Dockerize the entire project

Deploy to EKS (Kubernetes)

Add DVC for data versioning

Integrate MLflow for experiment tracking

Store artifacts in S3

Add CloudWatch monitoring & alarms