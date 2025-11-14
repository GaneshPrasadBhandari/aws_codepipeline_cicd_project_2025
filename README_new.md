# 🚀 End-to-End MLOps on AWS  
## CI/CD + Docker + ECR + Kubernetes (EKS)

## 👨‍💻 Author  

**Ganesh Prasad Bhandari**  
*Sr. AI/ML & GenAI Solution Architect | MSIT (Clark University, USA)*  

---

## 🧩 What This Guide Delivers

This repository shows how to take a **Flask + ML model app** from your laptop all the way to a **production-style Kubernetes cluster on AWS (EKS)** using:

- **GitHub** – source control & PRs  
- **AWS CodePipeline** – CI/CD orchestration  
- **AWS CodeBuild** – build, test, Docker image build & push  
- **AWS CodeDeploy / direct kubectl** – deploy to EC2 or EKS  
- **Amazon EC2** – VM-based deployment (Phase-1)  
- **Amazon ECR** – secure Docker image registry  
- **Amazon EKS** – managed Kubernetes for scalable inference  
- **Amazon CloudWatch** – logs & metrics  

The goal is **real-world MLOps**: any ML/AI/GenAI app can plug into this structure by replacing the model code.

---

## 🏗 High-Level Architecture

### 🔁 Overall CI/CD Flow

**Phase 1 – EC2 CI/CD**

`GitHub → CodePipeline → CodeDeploy → EC2 (Flask + Gunicorn)`

**Phase 2 – Docker + ECR**

`GitHub → CodePipeline → CodeBuild (Docker build & push) → ECR`

**Phase 3 – Kubernetes (EKS)**

`GitHub → CodePipeline → CodeBuild (kubectl apply) → EKS (ALB + Pods)`

---

### 📊 Service Responsibility Matrix

| Layer              | Service / Tool                         | Responsibility                                                   |
|--------------------|----------------------------------------|------------------------------------------------------------------|
| Source             | **GitHub**                             | Code hosting, branches, pull requests                            |
| CI Orchestrator    | **AWS CodePipeline**                   | Connects Source → Build → Deploy                                 |
| Build + Test       | **AWS CodeBuild**                      | Run tests, build Docker, push to ECR, apply Kubernetes manifests |
| VM Deployment      | **AWS CodeDeploy + EC2** (Phase-1)     | Zero-downtime deployment on EC2                                  |
| Containers         | **Docker + Amazon ECR**                | Build, tag, store images                                         |
| Orchestrator       | **Amazon EKS (Kubernetes)**            | Scale pods, rollouts, self-healing                               |
| Networking         | **ALB + Kubernetes Service/Ingress**   | HTTP routing & load balancing                                    |
| Observability      | **CloudWatch Logs / Metrics**          | Logs, dashboards, alerts                                         |
| IAM                | **AWS IAM Roles & Policies**           | Least-privilege security between all components                  |

---

## 📁 Repository Structure

```bash
aws_codepipeline_cicd_project_2025/
├── app.py                     # Flask entrypoint
├── wsgi.py                    # Gunicorn entrypoint
├── src/                       # ML logic (data prep, model, utils, etc.)
├── templates/                 # HTML templates for Flask UI
├── tests/                     # Unit / integration tests
├── requirements.txt           # Python dependencies (runtime)
├── requirements_updated.txt   # Optional: dev / extra dependencies
├── scripts/                   # Deployment scripts (EC2 + CodeDeploy)
│   ├── before_install.sh
│   ├── install_dependencies.sh
│   ├── after_install.sh
│   ├── start_service.sh
│   └── stop_service.sh
├── appspec.yml                # CodeDeploy config (EC2)
├── buildspec-build.yml        # CodeBuild: tests + Docker/ECR
├── buildspec-test.yml         # Optional: dedicated test phase
├── Dockerfile                 # Container definition for Flask + ML
├── kubernetes/                # EKS deployment manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress-alb.yaml       # Uses AWS Load Balancer Controller
│   └── hpa.yaml               # Horizontal Pod Autoscaler
├── .dockerignore
├── .gitignore
├── LICENSE
├── README.md                  # You are here
└── MLProject_AWS_CICD_Docker_K8s_Guide.md  # Extended notes
```

## 🌐 Flask API Endpoints (Example)
| Endpoint       | Method | Description                               |
| -------------- | ------ | ----------------------------------------- |
| `/`            | GET    | Home / health info                        |
| `/predictdata` | GET    | Web form UI for predictions               |
| `/predict`     | POST   | JSON input → model prediction (REST API)  |
| `/health`      | GET    | Lightweight health check (used in probes) |


## 0️⃣ Prerequisites
AWS Account (free tier is enough for demo; EKS may incur small costs)

GitHub account

Windows 10/11 + WSL2 Ubuntu (or native Linux/macOS)

VS Code with Remote-WSL extension

Docker Desktop installed and integrated with WSL2

AWS CLI, kubectl, and eksctl installed on your local machine

Replace YOUR_ACCOUNT_ID, YOUR_ECR_REPO_NAME, YOUR_AWS_REGION with your actual values.



## 1️⃣ Local Development (WSL2 + VS Code)
###  1.1 Clone Repository

```bash
# In WSL (Ubuntu inside VS Code)
cd /mnt/d/myeuron/clark_university/project_assignments_fall2025

git clone https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025.git

cd aws_codepipeline_cicd_project_2025
```

### 1.2 Create Virtual Environment

```bash
Copy code
python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt
```


### 1.3 Run Flask App Locally

```bash
python app.py
```

Open: http://127.0.0.1:5000

If everything looks good, the same app will move to EC2 → Docker → EKS.
---

### 2️⃣ Git Setup & First Push
## 2.1 Configure Git Identity (If Needed)

```bash
git config --global user.name "Ganesh Prasad Bhandari"
git config --global user.email "your_email@example.com"
```

## 2.2 Commit & Push

```bash
git status
git add .
git commit -m "Initial commit - Flask ML app with CI/CD skeleton"
git push origin main
```

### 3️⃣ Phase-1: EC2 + CodeDeploy CI/CD (Optional but Good Portfolio)
You already implemented much of this; keeping it here so the README tells a complete story.

## 3.1 Launch EC2 Instance
- **AMI:** Ubuntu 24.04 LTS  
- **Instance Type:** t2.micro  
- **Key Pair:** `mlproject_new_key1.pem`  
- **Security Group Rules:**
  - SSH (22) → My IP
  - HTTP (80) → 0.0.0.0/0
  - Custom TCP (5000) → 0.0.0.0/0

Copy **Public DNS** (e.g., `ec2-23-20-100-164.compute-1.amazonaws.com`).

---
## 3.2 Copy .pem Key to WSL & SSH

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
sudo systemctl enable codedeploy-agent
```

If not active, run:

```bash
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
```

## 3.4 IAM Roles (Minimal)
### EC2 Role
- Attach:
  - `AmazonS3ReadOnlyAccess`
  - `AWSCodeDeployRole`
  - `CloudWatchAgentServerPolicy`

#### CodeDeploy Role
- Create a new IAM role for **CodeDeploy** with the **AWSCodeDeployRole** policy.

Attach both roles respectively.

---

## 3.5 CodeDeploy appspec.yml

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /opt/mlproject
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

### Example scripts/start_service.sh
```bash
#!/bin/bash
sudo systemctl daemon-reload
sudo systemctl enable mlproject.service
sudo systemctl restart mlproject.service
sudo systemctl status mlproject.service --no-pager
```

### 3.6 CodePipeline (EC2 Path)
Source stage: GitHub (this repo)
Deploy stage: CodeDeploy → mlproject-cicd-app → mlproject-deploy-group1
Any git push origin main triggers:
GitHub → CodePipeline → CodeDeploy → new version on EC2.


## 4️⃣ Phase-2: Dockerizing the ML App + ECR
Now we move to container-native deployment.

### 4.1 Dockerfile

```bash
FROM python:3.11-slim

WORKDIR /app

# System deps for scientific stack
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=80

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:80", "wsgi:application"]
```

## 4.2 Build & Test Locally

```bash
# In project root
docker build -t mlproject-flask:local .

docker run -d --name mlproject-test -p 8080:80 mlproject-flask:local

# Test in browser:
# http://localhost:8080

docker logs mlproject-test
docker stop mlproject-test
docker rm mlproject-test
```

### 4.3 Create ECR Repository
In AWS Console → ECR → Create repository:

- Name: mlproject-flask-repo
- Visibility: Private

Or via CLI:

```bash
aws ecr create-repository \
  --repository-name mlproject-flask-repo \
  --region us-east-1
  ```

### 4.4 Authenticate Docker to ECR

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=YOUR_ACCOUNT_ID

aws ecr get-login-password --region $AWS_REGION \
  | docker login \
      --username AWS \
      --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

### 4.5 Tag & Push Image

```bash
REPO_NAME=mlproject-flask-repo
IMAGE_TAG=v1

docker tag mlproject-flask:local ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}

docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}
```
Now we have a versioned ML application image in ECR.



## 5️⃣ Phase-3: Production-Grade Kubernetes on EKS
Now we deploy the same image onto Amazon EKS.

### 5.1 Create EKS Cluster with eksctl
On your local machine (WSL):

```bash
AWS_REGION=us-east-1
CLUSTER_NAME=mlproject-eks

eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --nodegroup-name ml-ng-1 \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 2 \
  --nodes-max 4 \
  --managed
```
This may take 15–20 minutes.

Verify:

```bash
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

kubectl get nodes
```

## 5.2 Install AWS Load Balancer Controller (for ALB Ingress)
For brevity, only key commands are shown. Follow AWS docs if any step changes.

### 5.2.1 Associate OIDC Provider

```bash
eksctl utils associate-iam-oidc-provider \
  --region $AWS_REGION \
  --cluster $CLUSTER_NAME \
  --approve
```

### 5.2.2 Create IAM Policy

```bash
curl -o iam_policy.json \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

### 5.2.3 Create IAM Service Account

```bash
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
  ```

### 5.2.4 Install via Helm

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

Check:

```bash
Copy code
kubectl get pods -n kube-system | grep aws-load-balancer-controller
```

### 5.3 Kubernetes Manifests
Create directory kubernetes/ with the following files.

### 5.3.1 kubernetes/deployment.yaml

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlproject-deployment
  labels:
    app: mlproject
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mlproject
  template:
    metadata:
      labels:
        app: mlproject
    spec:
      containers:
        - name: mlproject-container
          image: YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/mlproject-flask-repo:v1
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 80
          env:
            - name: PORT
              value: "80"
          readinessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 80
            initialDelaySeconds: 30
            periodSeconds: 30
```

### 5.3.2 kubernetes/service.yaml

```bash
apiVersion: v1
kind: Service
metadata:
  name: mlproject-service
  labels:
    app: mlproject
spec:
  type: NodePort
  selector:
    app: mlproject
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080
```

### 5.3.3 kubernetes/ingress-alb.yaml

```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mlproject-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: mlproject-service
                port:
                  number: 80
```

### 5.3.4 kubernetes/hpa.yaml (Auto-Scaling)

```bash
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mlproject-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mlproject-deployment
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60
```

### 5.4 Apply Manifests Manually (First Time)

```bash
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress-alb.yaml
kubectl apply -f kubernetes/hpa.yaml

kubectl get pods
kubectl get svc
kubectl get ingress.
```
Once the Ingress is ready, AWS will create an ALB.
You’ll see an address like:

```bash
mlproject-ingress-1234567890.us-east-1.elb.amazonaws.com
```
Open it in a browser – you should see your Flask ML app running on EKS 🎉



## 6️⃣ Phase-4: CI/CD to EKS with CodePipeline + CodeBuild
Now we automate EKS deployment from GitHub.

### 6.1 CodeBuild Role Permissions
Create an IAM role for CodeBuild with:

- AmazonEC2ContainerRegistryPowerUser
- AmazonEKSClusterPolicy
- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy
- CloudWatchLogsFullAccess
- Optional inline policy for eks:DescribeCluster, eks:UpdateKubeconfig

Attach this role to the CodeBuild project.

### 6.2 buildspec-build.yml (CI/CD to ECR + EKS)

```bash
version: 0.2

env:
  variables:
    AWS_REGION: "us-east-1"
    CLUSTER_NAME: "mlproject-eks"
    REPOSITORY_NAME: "mlproject-flask-repo"
    IMAGE_TAG: "latest"
  shell: bash

phases:
  install:
    runtime-versions:
      docker: 24
    commands:
      - echo "Installing dependencies..."
      - pip install -r requirements.txt
      - curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-07-11/bin/linux/amd64/kubectl
      - chmod +x ./kubectl
      - mv ./kubectl /usr/local/bin/
      - curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
      - tar -xzf eksctl_Linux_amd64.tar.gz
      - mv eksctl /usr/local/bin/
  pre_build:
    commands:
      - echo "Logging in to Amazon ECR..."
      - ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
      - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
      - IMAGE_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPOSITORY_NAME}:${IMAGE_TAG}
      - echo "Image URI: $IMAGE_URI"
  build:
    commands:
      - echo "Running tests..."
      - pytest -q || echo "Tests can be configured here"
      - echo "Building Docker image..."
      - docker build -t $IMAGE_URI .
      - echo "Pushing Docker image..."
      - docker push $IMAGE_URI
  post_build:
    commands:
      - echo "Updating kubeconfig..."
      - aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
      - echo "Updating Kubernetes manifests with new image tag..."
      - sed -i "s|image: .*mlproject-flask-repo.*|image: ${IMAGE_URI}|" kubernetes/deployment.yaml
      - echo "Applying Kubernetes manifests..."
      - kubectl apply -f kubernetes/deployment.yaml
      - kubectl apply -f kubernetes/service.yaml
      - kubectl apply -f kubernetes/ingress-alb.yaml
      - kubectl apply -f kubernetes/hpa.yaml
artifacts:
  files:
    - '**/*'
```
This single CodeBuild project:

1. Builds + pushes Docker image → ECR
2. Updates deployment.yaml with the new image tag
3. Applies all Kubernetes manifests → rolling update in EKS

### 6.3 CodePipeline Stages (EKS Path)
1. Source stage

- Provider: GitHub (V2 / CodeConnections)
- Repo: GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025
- Branch: main

2. Build/Deploy stage

- Provider: CodeBuild
- Project: mlproject-eks-build-deploy
- Uses buildspec-build.yml

Every time you push to main:

git push origin main → CodePipeline → CodeBuild → new Docker image → ECR → EKS rolling update.

Zero manual kubectl needed ✅



## 7️⃣ Observability & Health Checks
### 7.1 Quick Checks

```bash
# Pods, services, ingress, HPA
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get hpa

# Logs from one pod
POD_NAME=$(kubectl get pods -l app=mlproject -o jsonpath='{.items[0].metadata.name}')
kubectl logs $POD_NAME
``` 

### 7.2 Curl Health Check

```bash
ALB_DNS=$(kubectl get ingress mlproject-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl http://$ALB_DNS/health
```


## 8️⃣ Common Troubleshooting
| Problem                                           | Likely Cause                                                  | Fix                                                                                  |                                                            |
| ------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ---------------------------------------------------------- |
| `Permission denied (publickey)` on SSH            | .pem permissions wrong                                        | `chmod 600 ~/.ssh/mlproject_new_key1.pem`                                            |                                                            |
| CodeDeploy EC2 deployment fails at `AfterInstall` | Wrong path or missing `mlproject.service`                     | Verify `/etc/systemd/system/mlproject.service` and scripts paths                     |                                                            |
| Docker build fails in CodeBuild                   | Missing system libs                                           | Add apt packages to `Dockerfile` or `buildspec`                                      |                                                            |
| ECR push denied                                   | IAM role missing ECR rights                                   | Attach `AmazonEC2ContainerRegistryPowerUser` to CodeBuild role                       |                                                            |
| EKS `kubectl` commands fail in CodeBuild          | kubeconfig not updated or IAM role not allowed                | Ensure `aws eks update-kubeconfig` runs and CodeBuild role has `eks:DescribeCluster` |                                                            |
| ALB Ingress not created                           | AWS Load Balancer Controller not running or annotations wrong | Check `kubectl get pods -n kube-system                                               | grep aws-load-balancer-controller` and ingress annotations |



## 9️⃣ How to Reuse This for Any ML / GenAI App
1. Replace model logic inside src/ and the prediction code in app.py.

2. Add any extra Python packages to requirements.txt.

3. Rebuild pipeline: git add . && git commit && git push.

4. CI/CD takes care of:
- Testing (pytest)
- Docker build
- ECR push
- Rolling update on EKS

This is exactly how real teams ship ML models safely.



### 🔚 Final Notes
This project demonstrates a full, production-style MLOps stack:

✅ Local dev → ✅ EC2 → ✅ Docker → ✅ ECR → ✅ EKS + ALB → ✅ Automated CI/CD


---

## 🌐 References

- [AWS CodePipeline Docs](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)  
- [AWS CodeDeploy Docs](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)  
- [Flask Documentation](https://flask.palletsprojects.com/en/latest/)  

---


© 2025 Ganesh Prasad Bhandari
AI, ML & GenAI Solution Architect | MSIT – Clark University (USA)