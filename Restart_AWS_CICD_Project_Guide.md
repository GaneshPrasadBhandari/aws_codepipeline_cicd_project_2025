# 🔁 How to Restart and Resume Your AWS CI/CD Project After Shutdown

## 🧠 Project: AWS CI/CD Pipeline for Machine Learning Deployment
**Region:** us-east-1 (N. Virginia)  
**Application:** mlproject-cicd-app  
**Deployment Group:** mlproject-deploy-group  
**EC2 Tag Key/Value:** cicd_compute = mlproject-ec2-new  

---

## ⚙️ Purpose
This guide explains **step-by-step what to do after you’ve shut down your laptop, EC2 instance, or services** — so you can restart your environment and continue working on your **Flask ML CI/CD project** without losing sync between GitHub, AWS, and your local machine.

Follow this exactly every time you start work after a shutdown.

---

## 🪄 1. Open Tools and Environment

### 🧩 Start these applications:
- **VS Code**
- **WSL / Ubuntu Terminal**
- **Browser → AWS Console** (Region: N. Virginia)
- **Browser → GitHub Repository** → [https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025](https://github.com/GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025)

### 🧱 Verify local files
Ensure your VS Code folder contains:
```
app.py
requirements.txt
appspec.yml
scripts/
├── before_install.sh
├── after_install.sh
├── start_service.sh
└── stop_service.sh
```

---

## ☁️ 2. Start EC2 Instance

1. Go to **AWS Console → EC2 → Instances**
2. Find your instance (e.g., `mlproject-ec2-new`)
3. Click **Start Instance**
4. Wait until state = ✅ *Running* and **Status checks = 2/2 passed**
5. Copy the **Public IPv4 DNS** (you’ll need this for SSH)
6. Under **Tags**, confirm you have:  
   `Key = cicd_compute` → `Value = mlproject-ec2-new`
7. Under **IAM Role**, make sure it’s `EC2CodeDeployRole` or your custom role that includes:
   - `AWSCodeDeployRole`
   - `AmazonS3ReadOnlyAccess`
   - `CloudWatchAgentServerPolicy`

---

## 🔐 3. SSH Into EC2 From WSL

```bash
cd ~
ls -l ~/.ssh/mlproject_new_key1.pem
ssh -i ~/.ssh/mlproject_new_key1.pem ubuntu@ec2-<your-new-public-dns>.compute-1.amazonaws.com
```

> ⚠️ **Note:** The public DNS changes every time you restart your EC2 instance. Copy the new one each time.

If permission denied:
```bash
chmod 600 ~/.ssh/mlproject_new_key1.pem
ssh -i ~/.ssh/mlproject_new_key1.pem ubuntu@ec2-<new-dns>
```

Expected output:
```
Welcome to Ubuntu 24.04.3 LTS
ubuntu@ip-172-31-xx-xx:~$
```

---

## 🧩 4. Check and Start CodeDeploy Agent

Once inside EC2, run:
```bash
sudo systemctl status codedeploy-agent
```

If inactive or failed:
```bash
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent
sudo systemctl status codedeploy-agent
```

> ✅ Must be “active (running)” before you can deploy.

---

## 🔁 5. Verify CodeDeploy Connection

Go to AWS Console → **Developer Tools → CodeDeploy → Applications → mlproject-cicd-app**  
→ Click **Deployment groups → mlproject-deploy-group**  
Check **Environment configuration**:  
Tag Key/Value must match EC2 tag (`cicd_compute = mlproject-ec2-new`).

---

## 💻 6. Sync GitHub Repository in VS Code / WSL

From your local machine (WSL, not EC2):

```bash
cd /mnt/d/myeuron/clark_university/project_assignments_fall2025/aws_codepipeline_cicd_project_2025
git pull origin main
```

If up-to-date → ✅ proceed.

---

## 🧬 7. (Optional) Test Flask App Locally

```bash
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

Then visit [http://127.0.0.1:5000](http://127.0.0.1:5000)  
If running → your app code is good.

Stop and deactivate when done:
```bash
deactivate
```

---

## 🪣 8. Confirm app structure before deployment

Structure must match your `appspec.yml`:

```yaml
version: 0.0
os: linux

files:
  - source: /
    destination: /home/ubuntu/mlapp

hooks:
  BeforeInstall:
    - location: scripts/before_install.sh
      runas: ubuntu
  AfterInstall:
    - location: scripts/after_install.sh
      runas: ubuntu
  ApplicationStart:
    - location: scripts/start_service.sh
      runas: ubuntu
  ApplicationStop:
    - location: scripts/stop_service.sh
      runas: ubuntu
```

---

## 🔄 9. Push New Changes (if made)

```bash
git status
git add .
git commit -m "updated deployment scripts"
git push origin main
```

---

## 📦 10. Create a New Deployment in AWS CodeDeploy

1. Go to **CodeDeploy → Applications → mlproject-cicd-app**
2. Click **Create deployment**
3. Fill the following:
   - **Repository**: `GaneshPrasadBhandari/aws_codepipeline_cicd_project_2025`  
     *(no https:// prefix)*
   - **Commit ID**: copy from GitHub’s latest commit (e.g. `932955b016bff63141ffa66ee12d70ed53f29bb7`)
   - **GitHub Token**: choose your saved one (e.g. `github_mlproject_for_cicd`)
4. Select your **deployment group**: `mlproject-deploy-group`
5. Click **Create Deployment**

---

## 🧾 11. Verify Deployment Logs

If deployment fails:
1. Check event log in AWS CodeDeploy console  
2. Or SSH into EC2 and run:

```bash
sudo tail -n 200 /var/log/aws/codedeploy-agent/codedeploy-agent.log
sudo tail -n 200 /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log
```

Typical causes:
| Error | Fix |
|-------|-----|
| `404 Not Found` | Wrong repo name or invalid commit ID |
| `agent not running` | Restart agent |
| `hooks failed` | Wrong paths in `appspec.yml` or scripts |
| `no instances found` | Tag mismatch between EC2 and deployment group |

---

## 🧠 12. (Optional) Run Full CodePipeline Flow

If CodePipeline is configured:
1. Go to AWS Console → CodePipeline
2. Open your pipeline
3. Click **Release change**
4. Watch stages: *Source → Build → Deploy*
5. Check CodeDeploy section for final app deployment

---

## 🧭 13. Quick Daily Startup Checklist

| Step | Command / Action | Status |
|------|------------------|---------|
| Start EC2 | AWS Console → EC2 → Start instance | ☐ |
| Copy new DNS | from EC2 → use for SSH | ☐ |
| SSH connect | `ssh -i ~/.ssh/mlproject_new_key1.pem ubuntu@ec2-...` | ☐ |
| Start CodeDeploy agent | `sudo systemctl start codedeploy-agent` | ☐ |
| Verify agent | `sudo systemctl status codedeploy-agent` | ☐ |
| Pull latest GitHub code | `git pull origin main` | ☐ |
| Test Flask locally (optional) | `python app.py` | ☐ |
| Deploy via CodeDeploy | create new deployment | ☐ |

---

## 🧩 Conclusion

This checklist ensures your project runs smoothly every time you power up.  
Just follow the order:
> **Start EC2 → SSH → Start agent → Sync Git → Deploy → Test app**

---

© 2025 Ganesh Prasad Bhandari | Sr. AI/ML & GenAI Architect | Clark University, USA
