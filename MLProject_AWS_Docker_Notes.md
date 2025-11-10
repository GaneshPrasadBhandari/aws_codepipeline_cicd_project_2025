# ML Project – AWS CI/CD + Docker – Working Notes

_Last updated: after successful local Docker build of `mlproject-flask:local`_

## 1. Project overview

- **App type**: Flask web app exposing:
  - Home page (`/`) and a prediction form (`/predictdata`).
  - Uses a trained ML model (loaded via `src.utils.load_object`) to predict a target from form inputs.
- **Goal**: End-to-end MLOps style deployment on AWS with:
  - GitHub → CodePipeline → CodeDeploy → EC2
  - Later: Docker image → ECR → automated deployment (still EC2 for now).

---

## 2. Current AWS setup

### 2.1 EC2

- Region: **us-east-1 (N. Virginia)**.
- Instance:
  - OS: Ubuntu (t3.micro, free tier–friendly).
  - Security group: Inbound HTTP on port **80**, SSH on port **22** from your IP.
- Tags (used by CodeDeploy):
  - `Key=cicd_compute`, `Value=mlproject-ec2-new`
  - `Key=Role`, `Value=mlproject-ec2`

### 2.2 SSH & CodeDeploy agent

- SSH key: `mlproject_new_key1.pem` stored in WSL:

  ```bash
  ~/.ssh/mlproject_new_key1.pem
  chmod 600 ~/.ssh/mlproject_new_key1.pem


SSH command pattern:
ssh -i ~/.ssh/mlproject_new_key1.pem ubuntu@<ec2-public-dns>


CodeDeploy agent:
sudo systemctl status codedeploy-agent
sudo systemctl start codedeploy-agent


2.3 CodeDeploy
Application: mlproject-cicd-app

Deployment group: mlproject-deploy-group1

Compute platform: EC2/On-premises

Environment config: EC2 instances with tag cicd_compute=mlproject-ec2-new

Scripts in /scripts:

before_install.sh – prepares dirs, installs base packages.

install_dependencies.sh – Python, venv, pip install -r requirements.txt.

after_install.sh – systemd service, migrations, etc.

start_service.sh – starts Gunicorn service.

2.4 CodePipeline
Pipeline: my_cicd_codepipeline_automation

Stages:

Source

Provider: GitHub (via CodeConnections)

Repo: GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025

Branch: main

Output artifact: SourceArtifact

Deploy

Provider: AWS CodeDeploy

Application: mlproject-cicd-app

Deployment group: mlproject-deploy-group1

3. Local dev (WSL + VS Code)
3.1 Project path
Windows: D:\myeuron\clark_university\project_assignments_fall2025\aws_codepipeline_cicd_project_2025

WSL: /mnt/d/myeuron/clark_university/project_assignments_fall2025/aws_codepipeline_cicd_project_2025

3.2 Virtual environment
Venv folder: .venv

Activate in WSL:
cd /mnt/d/myeuron/clark_university/project_assignments_fall2025/aws_codepipeline_cicd_project_2025
source .venv/bin/activate

Install deps:
pip install -r requirements.txt

3.3 Git basics
git remote -v
git status
git add <files>
git commit -m "message"
git push origin main

PAT auth is configured, so pushes from WSL/VS Code work.


4. Docker – local
4.1 Prereqs
Docker Desktop installed on Windows

WSL2 integration enabled

Test in WSL:
which docker
docker version


4.2 Dockerfile (summary)
Base: python:3.11-slim

WORKDIR /app
Install build libs via apt-get

Copy requirements.txt and run:
RUN pip install --no-cache-dir -r requirements.txt

Copy entire project and start Gunicorn/Flask bound to 0.0.0.0 (port = 5000 or 80).

4.3 Build
cd /mnt/d/myeuron/clark_university/project_assignments_fall2025/aws_codepipeline_cicd_project_2025
docker build -t mlproject-flask:local .

4.4 Run
If app listens on 5000:
docker run --rm -p 5000:5000 mlproject-flask:local

If app listens on 80:
docker run --rm -p 5000:80 mlproject-flask:local


Test:

http://localhost:5000/
http://localhost:5000/predictdata

Useful:
docker images | grep mlproject
docker ps
docker logs <container-id>
docker stop <container-id>

4.5 Commit Docker changes
git add Dockerfile requirements.txt
git commit -m "Add Dockerfile and fix dill dependency for Docker build"
git push origin main


5. Using existing AWS CI/CD (non-Docker)
Make code changes locally.

git add / git commit / git push main.

In CodePipeline, open my_cicd_codepipeline_automation and click Release change.

Wait for:

Source ✅

Deploy ✅

Grab EC2 public DNS and test:

http://<ec2-dns>/

http://<ec2-dns>/predictdata

6. Future: Docker + ECR CI/CD plan
Create ECR repo mlproject-flask.

Add CodeBuild stage in CodePipeline with a buildspec.yml that:

Logs into ECR.

Builds the Docker image.

Tags & pushes (:latest + commit SHA) to ECR.

Update CodeDeploy scripts on EC2 to:

Install Docker if needed.

docker pull the latest image from ECR.

docker run -d --name mlproject -p 80:5000 <ECR-URI>:latest.

Make sure IAM roles (CodeBuild + EC2/CodeDeploy) have ECR permissions.

Result: GitHub push → CodePipeline → CodeBuild (Docker build + push) → CodeDeploy (pull + run container on EC2).

7. Daily checklist
Start EC2, note public DNS.

From WSL:
5. Using existing AWS CI/CD (non-Docker)
Make code changes locally.

git add / git commit / git push main.

In CodePipeline, open my_cicd_codepipeline_automation and click Release change.

Wait for:

Source ✅

Deploy ✅

Grab EC2 public DNS and test:

http://<ec2-dns>/

http://<ec2-dns>/predictdata

6. Future: Docker + ECR CI/CD plan
Create ECR repo mlproject-flask.

Add CodeBuild stage in CodePipeline with a buildspec.yml that:

Logs into ECR.

Builds the Docker image.

Tags & pushes (:latest + commit SHA) to ECR.

Update CodeDeploy scripts on EC2 to:

Install Docker if needed.

docker pull the latest image from ECR.

docker run -d --name mlproject -p 80:5000 <ECR-URI>:latest.

Make sure IAM roles (CodeBuild + EC2/CodeDeploy) have ECR permissions.

Result: GitHub push → CodePipeline → CodeBuild (Docker build + push) → CodeDeploy (pull + run container on EC2).

7. Daily checklist
1 Start EC2, note public DNS.

2 From WSL:
ssh -i ~/.ssh/mlproject_new_key1.pem ubuntu@<ec2-public-dns>
sudo systemctl start codedeploy-agent

3 In VS Code WSL terminal:
cd /mnt/d/.../aws_codepipeline_cicd_project_2025
source .venv/bin/activate
git pull origin main

4 Optional local Docker test:
docker build -t mlproject-flask:local .
docker run --rm -p 5000:5000 mlproject-flask:local

5 For AWS deploy: push changes, Release change in CodePipeline, test on EC2.

### 📄 COPY UNTIL HERE (end)

---

If you paste that into a markdown file and commit it to the repo, then in a **new chat** you can say something like:

> “Here is the project notes file from my previous session”  
> (then paste the contents or upload the file)

…and we can continue exactly from where you left off (hooking Docker into ECR and CodePipeline, or whatever you want next).
