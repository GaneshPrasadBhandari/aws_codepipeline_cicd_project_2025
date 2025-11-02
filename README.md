# 🚀 AWS CI/CD Pipeline for Machine Learning Deployment

## 👨‍💻 Author
**Ganesh Prasad Bhandari**  
Ex. Sr. AI/ML Scientist & GenAI Solution Architect | MSIT (Clark University, USA)

---

## 🧠 Overview
This repository demonstrates an **end-to-end CI/CD pipeline on AWS** for deploying a **Flask-based Machine Learning application** using real-world DevOps & MLOps practices.  

It leverages:
- **AWS CodePipeline** → automation orchestrator  
- **AWS CodeBuild** → build and test stages  
- **AWS CodeDeploy** → EC2 deployment  
- **GitHub** → version control and source trigger  

---

## 🧩 Architecture

**Flow:**  
`GitHub → CodePipeline → CodeBuild → CodeDeploy → EC2 (Flask + Gunicorn)`

| Service | Purpose |
|----------|----------|
| **GitHub** | Source repository & CI/CD trigger |
| **CodePipeline** | Manages source → build → test → deploy |
| **CodeBuild** | Installs dependencies, runs tests, packages artifacts |
| **CodeDeploy** | Automates EC2 deployment |
| **EC2 (Ubuntu)** | Host machine for the ML Flask app |
| **IAM Roles** | Grants least-privilege access across services |

---

## 📁 Repository Structure
aws_codepipeline_cicd_project_2025/
├── src/ # ML logic (ingestion, transformation, model, etc.)
├── templates/ # HTML templates for Flask
├── scripts/ # Deployment scripts (used by CodeDeploy)
│ ├── before_install.sh
│ ├── start_service.sh
│ └── stop_service.sh
├── tests/ # Unit and integration tests
├── app.py # Flask entrypoint
├── wsgi.py # Gunicorn entrypoint
├── appspec.yml # CodeDeploy configuration
├── buildspec-build.yml # CodeBuild build stage config
├── buildspec-test.yml # CodeBuild test stage config
├── requirements.txt # Python dependencies
├── .gitattributes # LF normalization (Linux-compatible)
├── .gitignore
├── LICENSE
├── README.md
└── PROJECT_CONTINUATION_GUIDE.md



---

## ⚙️ Flask Endpoints

| Endpoint | Description |
|-----------|--------------|
| `/` | Homepage |
| `/predictdata` | Web-based input form |
| `/predict` | JSON API for predictions |
| `/health` | Health-check endpoint (used for pipeline tests) |

---

## 🧱 Local Setup

#```bash
# 1️⃣ Clone the repo
git clone https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025
cd aws_codepipeline_cicd_project_2025

# 2️⃣ Create and activate virtual environment
python -m venv myvenv
myvenv\Scripts\activate     # Windows
source myvenv/bin/activate  # Mac/Linux

# 3️⃣ Install dependencies
pip install -r requirements.txt

# 4️⃣ Run locally
python app.py
# Visit http://127.0.0.1:5000/health

--- 


## ☁️ AWS Setup Guide (Step-by-Step)
## 1. EC2 Configuration
Launch EC2 (Ubuntu 24.04 LTS, t3.micro, free-tier eligible)

Create key pair (.pem file)

Configure security group:

SSH (Port 22)

HTTP (Port 80)

SSH into instance:
ssh -i "mlproject_key.pem" ubuntu@<EC2-Public-DNS>



## Install updates & CodeDeploy agent:
sudo apt update -y && sudo apt install ruby-full wget -y
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl status codedeploy-agent  # should be active



## Add EC2 tag:
Key: Role
Value: mlproject-ec2



## 2. IAM Roles
Create or attach:

EC2 Instance Role → AmazonEC2RoleforAWSCodeDeploy

CodeDeploy Role → AWSCodeDeployRole

CodeBuild Role → AWSCodeBuildDeveloperAccess

CodePipeline Role → AWSCodePipelineFullAccess

## 3. AWS CodeDeploy
Create Application → mlproject-app

Create Deployment Group → mlproject-dg

Service Role: CodeDeployServiceRole

Environment: EC2

Tag Key: Role, Value: mlproject-ec2

Deployment Type: In-place

## 4. AWS CodeBuild
Create two projects:



## 🧩 Build Project
Name: mlproject-build

Source Provider: CodePipeline

Environment: Ubuntu (aws/codebuild/standard:7.0)

Buildspec: buildspec-build.yml

Artifacts: CodePipeline



## 🧪 Test Project
Name: mlproject-test

Buildspec: buildspec-test.yml

## 5. AWS CodePipeline
Pipeline Name: mlproject-pipeline

Source Provider: GitHub (via CodeStar Connection)

Build Stage: mlproject-build

Test Stage: mlproject-test

Deploy Stage: CodeDeploy (mlproject-app → mlproject-dg)

Trigger: Automatically on main branch push.




## 🔁 First Deployment Validation
After the first successful run:

Visit: http://<EC2-Public-DNS>/health
{"status": "ok"}

(Optional) Send JSON request:
curl -X POST http://<EC2-Public-DNS>/predict \
  -H "Content-Type: application/json" \
  -d '{"gender":"male","ethnicity":"group B","reading_score":72,"writing_score":70}'




## 🧩 Developer Notes
Line Ending Compatibility
Windows users must ensure LF endings for .sh and .yml files:

In VS Code, bottom-right corner → switch from CRLF → LF.

Add .gitattributes:
*.sh text eol=lf
*.yml text eol=lf


## Executable Permissions
Make scripts executable before pushing:
git update-index --chmod=+x scripts/*.sh
git commit -m "Make scripts executable"
git push



## ⚙️ Tech Stack

| Category            | Tools                                                 |
| ------------------- | ----------------------------------------------------- |
| Language            | Python 3.10                                           |
| Framework           | Flask                                                 |
| CI/CD               | AWS CodePipeline, CodeBuild, CodeDeploy               |
| Cloud               | AWS EC2                                               |
| Server              | Gunicorn                                              |
| SCM                 | GitHub                                                |
| Future Enhancements | Docker, Kubernetes (EKS), DVC, MLflow, S3 integration |



## 🏁 Outcome
This project demonstrates a fully automated CI/CD pipeline for Machine Learning applications — integrating DevOps + MLOps best practices for real-world deployments.

It is production-ready, scalable, and extendable to containerized (Docker/Kubernetes) or tracking-based (DVC/MLflow) environments.



## 📜 License
MIT License © 2025 Ganesh Prasad Bhandari




