# 🧠 AWS CI/CD Pipeline for Machine Learning Deployment

## 👨‍💻 Author
**Ganesh Prasad Bhandari**  
*Sr. AI/ML & GenAI Solution Architect | MSIT (Clark University, USA)*  

---

## 🧩 Overview

This repository demonstrates a complete **end-to-end CI/CD pipeline on AWS** for deploying a **Flask-based Machine Learning application** using real-world DevOps & MLOps practices.

It leverages the following AWS services:

- **AWS CodePipeline** → CI/CD orchestration
- **AWS CodeBuild** → build and test automation
- **AWS CodeDeploy** → automated EC2 deployment
- **Amazon EC2** → compute environment for hosting Flask app
- **GitHub** → version control and CI trigger source

---

## 🏗️ Architecture
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


## ⚙️ Local Setup (Windows + VS Code + WSL)

### 1️⃣ Clone Repository

```bash
# In WSL (Ubuntu terminal inside VS Code)
cd /mnt/d/myeuron/clark_university/project_assignments_fall2025
git clone https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025.git
cd aws_codepipeline_cicd_project_2025
```

### 2️⃣ Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3️⃣ Run Flask App Locally

```bash
python app.py
```

Open [http://127.0.0.1:5000](http://127.0.0.1:5000)

---

## 🔐 Git Configuration

If Git asks for identity:

```bash
git config --global user.name "Ganesh Prasad Bhandari"
git config --global user.email "youremail@example.com"
```

Commit and push code:

```bash
git add .
git commit -m "Initial commit - Flask CI/CD setup"
git push origin main
```

---

## ☁️ AWS Setup (Step-by-Step)

### 4️⃣ Launch EC2 Instance

- **AMI:** Ubuntu 24.04 LTS  
- **Instance Type:** t2.micro  
- **Key Pair:** `mlproject_new_key1.pem`  
- **Security Group Rules:**
  - SSH (22) → My IP
  - HTTP (80) → 0.0.0.0/0
  - Custom TCP (5000) → 0.0.0.0/0

Copy **Public DNS** (e.g., `ec2-23-20-100-164.compute-1.amazonaws.com`).

---

### 5️⃣ Configure SSH Key in WSL

```bash
mkdir -p ~/.ssh
cp "/mnt/d/myeuron/clark_university/project_assignments_fall2025/AWSKeys/mlproject_new_key1.pem" ~/.ssh/
chmod 600 ~/.ssh/mlproject_new_key1.pem
ssh -i ~/.ssh/mlproject_new_key1.pem ubuntu@ec2-23-20-100-164.compute-1.amazonaws.com
```

✅ Expected Output:

```
Welcome to Ubuntu 24.04.3 LTS
ubuntu@ip-172-31-25-44:~$
```

---

### 6️⃣ Install CodeDeploy Agent on EC2

```bash
sudo apt update -y
sudo apt install ruby-full wget -y
cd /home/ubuntu
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl status codedeploy-agent
```

If not active, run:

```bash
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
```

---

### 7️⃣ Create IAM Roles

#### EC2 Role
- Attach:
  - `AmazonS3ReadOnlyAccess`
  - `AWSCodeDeployRole`
  - `CloudWatchAgentServerPolicy`

#### CodeDeploy Role
- Create a new IAM role for **CodeDeploy** with the **AWSCodeDeployRole** policy.

Attach both roles respectively.

---

## 🧱 Application Structure

```
aws_codepipeline_cicd_project_2025/
├── app.py
├── requirements.txt
├── appspec.yml
├── scripts/
│   ├── before_install.sh
│   ├── after_install.sh
│   ├── start_service.sh
│   └── stop_service.sh
└── README.md
```

---

## 🧩 appspec.yml

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /var/www/mlproject
    overwrite: true

hooks:
  ApplicationStop:
    - location: scripts/stop_service.sh
      timeout: 60
      runas: ubuntu

  BeforeInstall:
    - location: scripts/before_install.sh
      timeout: 300
      runas: ubuntu

  AfterInstall:
    - location: scripts/after_install.sh
      timeout: 300
      runas: ubuntu

  ApplicationStart:
    - location: scripts/start_service.sh
      timeout: 120
      runas: ubuntu
```

---

## 🚀 Deployment Steps (CodeDeploy + CodePipeline)

### 1️⃣ Create CodeDeploy Application

- **Name:** `mlproject-cicd-app`
- **Compute platform:** EC2/On-premises

### 2️⃣ Create Deployment Group

- **Name:** `mlproject-deployment-group`
- **Service role:** `CodeDeployServiceRole-mlproject`
- **Environment:** Amazon EC2 instances
- **Tag Key/Value:** Role = `mlproject-ec2`
- **Deployment type:** In-place

### 3️⃣ Verify EC2 Connectivity

```bash
sudo systemctl status codedeploy-agent
```

If failed, restart the agent.

---

### 4️⃣ Create AWS CodePipeline

- **Source:** GitHub → (connect your repo)  
- **Build:** (optional) Skip for Flask app  
- **Deploy:** CodeDeploy → Select application & group  

Once created, push any change:

```bash
git add .
git commit -m "testing pipeline trigger"
git push origin main
```

Pipeline triggers automatically 🎯

---

## 🧾 Verification Commands

On **EC2**:

```bash
sudo systemctl status codedeploy-agent
sudo tail -f /var/log/aws/codedeploy-agent/codedeploy-agent.log
ls -l /var/www/mlproject
sudo systemctl status mlproject.service
curl http://localhost:5000
```

---

## 🧠 Troubleshooting

| Issue | Fix |
|-------|-----|
| `Permission denied (.pem)` | Run `chmod 600 ~/.ssh/mlproject_new_key1.pem` |
| `CodeDeploy agent not found` | Reinstall with `sudo ./install auto` |
| `ApplicationStart failed` | Verify `mlproject.service` exists in `/etc/systemd/system/` |
| `404 Not Found` during deploy` | Ensure correct GitHub repo & commit ID |

---

## 🌐 References

- [AWS CodePipeline Docs](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)  
- [AWS CodeDeploy Docs](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)  
- [Flask Documentation](https://flask.palletsprojects.com/en/latest/)  

---

## ✅ Next Steps (Phase 2)
We will extend this setup with:
- **Docker Containerization** → Flask app inside container  
- **ECR** → push image  
- **EKS or Fargate** → deploy via Kubernetes manifest  

*(coming next section)*

---

© 2025 Ganesh Prasad Bhandari | AI & GenAI Architect | MSIT Clark University  
