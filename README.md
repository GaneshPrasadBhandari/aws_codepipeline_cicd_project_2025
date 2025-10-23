# 🚀 AWS CI/CD Pipeline for Machine Learning Deployment

## 👨‍💻 Author
**Ganesh Prasad Bhandari**  
Sr. AI/ML & GenAI Solution Architect | MSIT (Clark University, USA)

---

## 🧠 Overview
This project demonstrates an **end-to-end CI/CD pipeline on AWS** for deploying a **Flask-based Machine Learning application**.  
It follows enterprise-grade DevOps/MLOps best practices using **AWS CodePipeline, CodeBuild, CodeDeploy, and EC2**, integrated with GitHub.

---

## 🧩 Architecture
GitHub → CodePipeline → CodeBuild → CodeDeploy → EC2 (Gunicorn + Flask)


| Service | Purpose |
|----------|----------|
| **GitHub** | Source code repository |
| **CodePipeline** | Automates build → test → deploy workflow |
| **CodeBuild** | Installs dependencies, runs tests, builds artifacts |
| **CodeDeploy** | Deploys built artifacts to EC2 |
| **EC2** | Hosts Flask app with Gunicorn |

---

## 📁 Repository Structure
aws_codepipeline_cicd_project_2025/
├── src/
│ ├── components/
│ ├── pipeline/
│ ├── utils.py
│ └── ...
├── templates/
│ ├── index.html
│ └── home.html
├── app.py
├── wsgi.py
├── requirements.txt
├── .gitignore
├── README.md
└── LICENSE



---

## ⚙️ Flask App Endpoints
| Endpoint | Description |
|-----------|--------------|
| `/` | Home page |
| `/predictdata` | Web form input for prediction |
| `/predict` | JSON API for programmatic inference |
| `/health` | Health check endpoint (used by CodeBuild or load balancer) |

---

## 💡 Local Setup
```bash
# 1️⃣ Clone the repo
git clone https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025
cd aws_codepipeline_cicd_project_2025

# 2️⃣ Create virtual environment
python -m venv myvenv
myvenv\Scripts\activate    # (Windows)
source myvenv/bin/activate # (Mac/Linux)

# 3️⃣ Install dependencies
pip install -r requirements.txt

# 4️⃣ Run locally
python app.py
# Visit http://127.0.0.1:5000/health


🧱 AWS Deployment Steps
Create EC2 instance (t2.micro) and install CodeDeploy agent

Create IAM roles for EC2, CodeBuild, and CodeDeploy

Add buildspec.yml and appspec.yml to repo

Configure CodePipeline:

Source: GitHub

Build: CodeBuild

Deploy: CodeDeploy

Push to main → automatic deployment to EC2

📦 Tech Stack
Language: Python 3.10

Framework: Flask

Cloud: AWS

CI/CD: CodePipeline, CodeBuild, CodeDeploy

Server: EC2 + Gunicorn

Version Control: GitHub

Future Additions: Docker, Kubernetes (EKS), DVC, MLflow, S3

🏁 Outcome
This project creates a fully automated CI/CD pipeline for ML model deployment — a job-ready, production-level demonstration of DevOps + MLOps integration.

📜 License
MIT License © 2025 Ganesh Prasad Bhandari


