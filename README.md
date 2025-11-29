# 🚀 PetClinic DevOps Automation Project

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)]()
[![Jenkins](https://img.shields.io/badge/Jenkins-2.528.2-red)]()
[![Tomcat](https://img.shields.io/badge/Tomcat-9.0.82-yellow)]()
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
- [Contributing](#contributing)
- [License](#license)

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
- Process monitoring scripts

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
6. Monitoring scripts verify health
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
- Tomcat 9.0.82
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
wget https://raw.githubusercontent.com/YOUR_USERNAME/pet-clinic-devops/main/setup/setup-pet-clinic-user.sh
sudo bash setup-pet-clinic-user.sh
```

This creates the `pet-clinic` user and installs both Java versions.

### Step 2: Clone Repository (as pet-clinic user)
```bash
# Switch to pet-clinic user
su - pet-clinic

# Clone the repository
git clone https://github.com/YOUR_USERNAME/pet-clinic-devops.git
cd pet-clinic-devops
```

### Step 3: Install Services
```bash
# Install Ansible (only step requiring package manager)
sudo bash scripts/install-ansible.sh

# Install Tomcat
ansible-playbook ansible/playbooks/install-tomcat.yml

# Install Jenkins
ansible-playbook ansible/playbooks/install-jenkins.yml

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
   - **Repository URL**: `https://github.com/YOUR_USERNAME/pet-clinic-devops.git`
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
| [User Manual](docs/USER_MANUAL.md) | How to use the deployed application | End Users |
| [Project Manual](docs/PROJECT_MANUAL.md) | Technical details and development guide | Developers/DevOps |
| [Setup Guide](docs/SETUP_GUIDE.md) | Step-by-step installation instructions | System Administrators |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues and solutions | All Users |
| [Architecture](docs/ARCHITECTURE.md) | System design and component details | Technical Leads |

---

## 📂 Project Structure
```
pet-clinic-devops/
├── setup/                          # Initial system setup
│   ├── setup-pet-clinic-user.sh   # User and Java installation
│   └── README.md                   # Setup instructions
│
├── spring-petclinic/              # Application source code
│   ├── src/                       # Java source files
│   ├── pom.xml                    # Maven configuration
│   └── mvnw                       # Maven wrapper
│
├── scripts/                       # Automation scripts
│   ├── build-petclinic.sh        # Build WAR file
│   ├── deploy-to-root.sh         # Deploy to Tomcat
│   ├── sanity-check.sh           # Health checks
│   └── start-tomcat-detached.sh  # Tomcat daemon
│
├── ansible/                       # Infrastructure as Code
│   ├── ansible.cfg               # Ansible configuration
│   ├── inventory/                # Server inventory
│   │   └── hosts.ini
│   └── playbooks/                # Automation playbooks
│       ├── install-tomcat.yml
│       ├── install-jenkins.yml
│       ├── deploy_petclinic.yml
│       └── verify_petclinic.yml
│
├── jenkins/                       # CI/CD pipeline
│   └── Jenkinsfile               # Pipeline definition
│
├── docs/                          # Documentation
│   ├── USER_MANUAL.md
│   ├── PROJECT_MANUAL.md
│   ├── SETUP_GUIDE.md
│   ├── TROUBLESHOOTING.md
│   └── ARCHITECTURE.md
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
- **Apache Tomcat**: 9.0.82
- **Jenkins**: 2.528.2

### Automation Tools
- **Ansible**: 2.x (Infrastructure automation)
- **Bash**: Shell scripting
- **Git**: Version control

### Monitoring
- Custom bash scripts for process monitoring
- Port availability checks
- HTTP endpoint verification

---

## 💻 Key Commands

### Application Management
```bash
# Build application
bash scripts/build-petclinic.sh

# Deploy to Tomcat
ansible-playbook ansible/playbooks/deploy_petclinic.yml

# Run sanity checks
bash scripts/sanity-check.sh

# Start monitoring
bash ~/monitoring/start-monitoring.sh
```

### Service Management
```bash
# Tomcat
~/tomcat/bin/startup.sh          # Start
~/tomcat/bin/shutdown.sh         # Stop
tail -f ~/tomcat/logs/catalina.out  # Logs

# Jenkins
~/jenkins/start-jenkins.sh       # Start
~/jenkins/stop-jenkins.sh        # Stop
~/jenkins/status-jenkins.sh      # Status
tail -f ~/jenkins/jenkins.log    # Logs
```

### Java Version Switching
```bash
java21                           # Switch to Java 21
java25                           # Switch to Java 25
java -version                    # Check current version
```

---

## 🔐 Default Credentials

### Tomcat Manager
- **URL**: http://localhost:9090/manager
- **Username**: `admin`
- **Password**: `admin123`

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
bash ~/monitoring/monitor-all.sh
```

---

## 🐛 Troubleshooting

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

For detailed troubleshooting, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

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

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is created for educational purposes. 

- **DevOps Configuration**: Free to use and modify
- **Spring PetClinic Application**: Licensed under Apache License 2.0

---

## 👥 Project Information

- **Author**: DevOps Team
- **Version**: 1.0
- **Last Updated**: November 2025
- **Repository**: https://github.com/YOUR_USERNAME/pet-clinic-devops

---

## 🔗 Useful Links

- [Spring PetClinic Official](https://github.com/spring-projects/spring-petclinic)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)

---

## 📞 Support

For issues or questions:
- Create an issue in GitHub
- Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- Review [Project Manual](docs/PROJECT_MANUAL.md)

---

<div align="center">

**⭐ If you find this project helpful, please star it! ⭐**

Made with ❤️ for DevOps Learning

</div>
