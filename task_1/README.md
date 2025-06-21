# 🛠️  AWS + Terraform Bootstrap
Task 1 — DevOps Course

> **Goal:** create a repeatable AWS foundation (state bucket + IAM role) and a GitHub Actions pipeline that runs `terraform fmt / plan / apply`.

---

## 📑 Table of Contents

1. [Prerequisites](#-prerequisites)
2. [Quick Start](#-quick-start)
3. [Repository Layout](#-repository-layout)
4. [What Gets Created](#-what-gets-created)
5. [CI/CD Pipeline](#-cicd-pipeline)
6. [Security Hardening](#-security-hardening)
7. [Troubleshooting](#-troubleshooting)

---

## ⚙️ Prerequisites

| Tool | Minimum version | Check command |
|------|-----------------|---------------|
| **AWS CLI v2** | any v2 | `aws --version` |
| **Terraform** | ≥ 1.6 | `terraform version` |
| **Git** | latest | `git --version` |
| **GitHub CLI** (optional) | latest | `gh --version` |
| A personal **AWS account** | root MFA enabled | – |
| A personal **GitHub repo** | `rsschool-devops-course-tasks` | – |

> Examples use the **Seoul region (`ap-northeast-2`)** — feel free to swap.

---

## 🚀 Quick Start

```bash
# 1  Clone the repository
git clone git@github.com:<YOUR_GH_USER>/rsschool-devops-course-tasks.git
cd rsschool-devops-course-tasks

# 2  Install Terraform 1.7.x (pick one method)

## macOS (Homebrew)
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

## Ubuntu / Debian
sudo apt-get update && \
  sudo apt-get install -y wget unzip && \
  wget https://releases.hashicorp.com/terraform/1.7.4/terraform_1.7.4_linux_amd64.zip && \
  unzip terraform_1.7.4_linux_amd64.zip && \
  sudo mv terraform /usr/local/bin/

terraform version   

# 3  Configure AWS CLI to use your IAM user (with MFA)
aws configure
# Access Key ID  : <paste>
# Secret Access  : <paste>
# Region         : ap-northeast-2
# Output format  : json

# 4  Initialise backend (edit bucket name)
export TF_VAR_bucket_name="rsschool-tf-state-12345"
terraform init -backend-config="bucket=$TF_VAR_bucket_name"

# 5  Plan & apply
terraform plan  -out=tfplan
terraform apply tfplan