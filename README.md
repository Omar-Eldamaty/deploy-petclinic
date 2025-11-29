# 🚀 PetClinic DevOps Automation Project

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Jenkins](https://img.shields.io/badge/Jenkins-2.528.2-red)]()
[![Tomcat](https://img.shields.io/badge/Tomcat-10.1.33-yellow)]()
[![Java](https://img.shields.io/badge/Java-21%20%7C%2025-orange)]()

> Fully automated CI/CD pipeline for Spring PetClinic application using Ansible, Jenkins, and shell scripting - demonstrating DevOps best practices without relying on package managers.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Project Structure](#project-structure)
- [Technologies](#technologies)

---

## 🎯 Overview

This project demonstrates a complete DevOps workflow for deploying the Spring PetClinic application with the following objectives:

- **Automated Deployment**: End-to-end automation using Ansible and Jenkins
- **Infrastructure as Code**: All configurations defined in code
- **No Package Manager Dependency**: Manual installations to demonstrate core concepts
- **CI/CD Pipeline**: Automatic builds and deployments on code changes
- **Monitoring**: Process monitoring and health checks

### Project Goals

✅ Create a reproducible deployment environment  
✅ Implement CI/CD best practices  
✅ Demonstrate infrastructure automation  
✅ Provide comprehensive documentation  
✅ Ensure scalability and maintainability  

---

## ✨ Features

### 🔄 Continuous Integration/Deployment
- Automatic builds triggered by GitHub commits (SCM polling)
- Maven-based build system with Java 25
- WAR file generation and deployment
- Automated sanity testing

### 🏗️ Infrastructure Automation
- Ansible playbooks for service installation
- Tomcat web server configuration (port 9090)
- Jenkins CI/CD server setup (port 8080)
- Process monitoring using Nagios (port 80)

### 🔧 Configuration Management
- Multi-Java version support (Java 21 for runtime, Java 25 for builds)
- Environment variable management
- Reusable shell scripts
- Idempotent operations

### 📊 Monitoring & Health Checks
- Tomcat process monitoring
- Port availability checks
- Application endpoint verification
- Automated log collection

---

## 🏛️ Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                        GitHub Repository                     │
│                   (Source Code + Pipeline)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │ SCM Polling (every 2 min)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                     Jenkins (Port 8080)                      │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Pipeline Stages:                                     │   │
│  │  1. Checkout   → Get latest code                     │   │
│  │  2. Build      → Maven + Java 25                     │   │
│  │  3. Deploy     → Ansible playbook                    │   │
│  │  4. Verify     → Sanity checks                       │   │
│  │  5. Monitor    → Health verification                 │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │ Ansible Deployment
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Tomcat Server (Port 9090)                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Spring PetClinic Application                 │   │
│  │         Runtime: Java 21                             │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                       ▲
                       │ HTTP Requests
                       │
                  End Users
```

**Component Interaction:**
1. Developer pushes code to GitHub
2. Jenkins detects changes via SCM polling
3. Pipeline builds application with Maven (Java 25)
4. Ansible deploys WAR to Tomcat
5. Tomcat runs application (Java 21)
6. Monitoring tool verify health
7. Users access application on port 9090

---

## 📦 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+ or Debian 11+ (or compatible Linux)
- **RAM**: Minimum 4GB (8GB recommended)
- **Disk**: 10GB free space
- **Network**: Internet connection for downloads

### Required Software (Installed Automatically)
- Java 21 (Jenkins & Tomcat runtime)
- Java 25 (Maven builds)
- Maven 3.8.8
- Tomcat 10.1.33
- Jenkins 2.528.2
- Ansible (only component requiring package manager)

### Required Access
- Root/sudo access for initial user setup
- GitHub account
- SSH access to target servers

---

## 🚀 Quick Start

### Step 1: Initial Setup (as root)
```bash
# Download and run user setup script
wget https://raw.githubusercontent.com/Omar-Eldamaty/deploy-petclinic/main/setup/setup-pet-clinic-user.sh
sudo bash setup-pet-clinic-user.sh
```

This creates the `pet-clinic` user and installs both Java versions.

### Step 2: Clone Repository (as pet-clinic user)
```bash
# Switch to pet-clinic user
su - pet-clinic

# Clone the repository
git clone https://github.com/Omar-Eldamaty/deploy-petclinic.git
cd deploy-petclinic
```

### Step 3: Install Services
```bash
# Install Ansible (only step requiring package manager)
sudo bash scripts/install-ansible.sh

# Install Tomcat
ansible-playbook ansible/playbooks/tomcat.yml

# Install Jenkins
ansible-playbook ansible/playbooks/jenkins.yml

# Install Monitoring
ansible-playbook ansible/playbooks/install-monitoring.yml
```

### Step 4: Configure Jenkins Pipeline

1. Access Jenkins: `http://localhost:8080`
2. Get initial password: `cat ~/jenkins/secrets/initialAdminPassword`
3. Install suggested plugins
4. Create pipeline job:
   - **Name**: `petclinic-pipeline`
   - **Type**: Pipeline
   - **Pipeline script from SCM**: Git
   - **Repository URL**: `https://github.com/Omar-Eldamaty/deploy-petclinic.git`
   - **Script Path**: `jenkins/Jenkinsfile`

### Step 5: Test Deployment
```bash
# Manual build test
bash scripts/build-petclinic.sh
bash scripts/deploy-to-root.sh

# Verify
curl http://localhost:9090/petclinic
```

### Step 6: Trigger First Pipeline Run

1. Jenkins → petclinic-pipeline → **Build Now**
2. Wait for completion
3. Access application: `http://localhost:9090/petclinic`

---

## 📚 Documentation

Detailed documentation is available in the `docs/` directory:

| Document | Description | Audience |
|----------|-------------|----------|
| [User Manual](docs/USER_MANUAL.md) | Step-by-step installation instructions | End Users |
| [Project Manual](docs/PROJECT_MANUAL.md) | Technical details and development guide | Developers/DevOps |

---

## 📂 Project Structure
```
deploy-petclinic/
├── setup/                          # Initial system setup
│   └── setup-pet-clinic-user.sh   # User and Java installation
│   
│
├── spring-petclinic/              # Application source code
│   ├── src/                       # Java source files
│   ├── pom.xml                    # Maven configuration
│   └── mvnw                       # Maven wrapper
│
├── scripts/                       # Automation scripts
│   ├── create-servlet-initializer.sh        # create servlet initializer
│   └── maven_download.sh         # Build WAR file and Deploy to Tomcat
│   
│
├── ansible/                       # Configuration Management
│   │   ├── inventory/                # Server inventory
│   │   └── hosts.ini
│   └── playbooks/                # Automation playbooks
│       ├── tomcat.yml
│       ├── jenkins.yml
│       ├── nagios.yml
│       ├── monitor-nagios.yml
│       ├── deploy-petclinic.yml
│       └── verify_petclinic.yml
│
├── jenkins/                       # CI/CD pipeline
│   └── Jenkinsfile               # Pipeline definition
│
├── docs/                          # Documentation
│   ├── USER_MANUAL.md
│   └── PROJECT_MANUAL.md
│  
├── .gitignore                     # Git ignore rules
└── README.md                      # This file
```

---

## 🛠️ Technologies

### Core Technologies
- **Java**: 21 (Runtime) & 25 (Build)
- **Spring Boot**: 4.0.0-SNAPSHOT
- **Maven**: 3.8.8
- **Apache Tomcat**: 10.1.33
- **Jenkins**: 2.528.2

### Automation Tools
- **Ansible**: 2.x (Infrastructure automation)
- **Bash**: Shell scripting
- **Git**: Version control

### Monitoring
- Nagios for process monitoring
- Port availability checks
- HTTP endpoint verification

---

## 🔐 Default Credentials

### Tomcat Manager
- **URL**: http://localhost:9090/manager
- **Username**: `admin`
- **Password**: `123`

### Jenkins
- **URL**: http://localhost:8080
- **Username**: `admin`
- **Initial Password**: `cat ~/jenkins/secrets/initialAdminPassword`

⚠️ **Security Note**: Change default passwords in production environments!

---

## 🔍 Verification

### Check All Services
```bash
# Verify Java installations
java21 && java25

# Check Tomcat
curl http://localhost:9090/

# Check Jenkins
curl http://localhost:8080/

# Check application
curl http://localhost:9090/petclinic

# Check monitoring
curl http://localhost/nagios/
```

---

## Troubleshooting

### Quick Diagnostics
```bash
# Check process status
ps aux | grep -E 'tomcat|jenkins'

# Check ports
netstat -tlnp | grep -E '8080|9090'

# Check logs
tail -50 ~/tomcat/logs/catalina.out
tail -50 ~/jenkins/jenkins.log
```


---

## 📊 Pipeline Status

The CI/CD pipeline automatically:
1. ✅ Detects code changes (every 2 minutes)
2. ✅ Builds application with Maven
3. ✅ Deploys to Tomcat
4. ✅ Runs sanity checks
5. ✅ Verifies monitoring

**Average Pipeline Duration**: ~5-7 minutes

---

## 👥 Project Information

- **Author**: DevOps Team
- **Version**: 1.0
- **Last Updated**: November 2025
- **Repository**: https://github.com/Omar-Eldamaty/deploy-petclinic

---

## 🔗 Useful Links

- [Spring PetClinic Official](https://github.com/spring-projects/spring-petclinic)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-10.0-doc/)

---

<div align="center">

**⭐ If you find this project helpful, please star it! ⭐**

Made with ❤️ for DevOps Learning

</div>
