# PetClinic User Manual

## Quick Installation Guide

### Prerequisites
- Ubuntu 20.04+ or Debian-based Linux
- 4GB RAM minimum
- 10GB free disk space
- Internet connection
- Root/sudo access

### Installation Steps

#### 1. Initial System Setup (as root)
```bash
# Download setup script
wget https://raw.githubusercontent.com/Omar-Eldamaty/deploy-petclinic/main/setup/setup-pet-clinic-user.sh

# Run setup (creates user and installs Java)
sudo bash setup-pet-clinic-user.sh
```

#### 2. Clone Repository (as pet-clinic user)
```bash
# Switch to pet-clinic user
su - pet-clinic

# Clone project
git clone https://github.com/Omar-Eldamaty/deploy-petclinic.git
cd deploy-petclinic
```

#### 3. Install Ansible
```bash
sudo bash scripts/install-ansible.sh
```

#### 4. Install Services
```bash
# Install Tomcat (runs on port 9090)
ansible-playbook ansible/playbooks/tomcat.yml

# Install Jenkins (runs on port 8080)
ansible-playbook ansible/playbooks/jenkins.yml

# Install Monitoring (runs on port 80)
ansible-playbook ansible/playbooks/install-monitoring.yml
```

#### 5. Configure Jenkins

**Access Jenkins:**
```bash
# Open browser to: http://localhost:8080
# Get initial password:
cat ~/jenkins/secrets/initialAdminPassword
```

**Create Pipeline:**
1. Install suggested plugins
2. Create admin user
3. New Item → Pipeline
4. Name: `petclinic-pipeline`
5. Pipeline from SCM → Git
6. Repository: `https://github.com/Omar-Eldamaty/deploy-petclinic.git`
7. Script Path: `jenkins/Jenkinsfile`
8. Save

#### 6. First Deployment

**Option A - Via Jenkins (Automated):**
```bash
# Just click "Build Now" in Jenkins
# Pipeline will automatically build and deploy
```

**Option B - Manual Deployment:**
```bash
# Build application
bash scripts/build-petclinic.sh

# Deploy to Tomcat
bash scripts/deploy-to-root.sh
```

### Verification

#### Check All Services
```bash
# Tomcat
curl http://localhost:9090/

# Jenkins
curl http://localhost:8080/

# PetClinic Application
curl http://localhost:9090/petclinic

# Monitoring
curl http://localhost/nagios/
```

#### Access Applications

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| **PetClinic** | http://localhost:9090/petclinic | None |
| **Tomcat Manager** | http://localhost:9090/manager | admin / 123 |
| **Jenkins** | http://localhost:8080 | admin / (from file) |
| **Nagios** | http://localhost/nagios | nagiosadmin / nagios |

### Daily Operations

#### Deploy New Changes
```bash
# Automatic (via Jenkins)
# - Push code to GitHub
# - Jenkins detects changes (every 2 minutes)
# - Builds and deploys automatically

# Manual
cd ~/deploy-petclinic
git pull
bash scripts/build-petclinic.sh
bash scripts/deploy-to-root.sh
```

#### Check Logs
```bash
# Tomcat logs
tail -f ~/tomcat/logs/catalina.out

# Jenkins logs
tail -f ~/jenkins/jenkins.log

# Application logs
tail -f ~/tomcat/logs/localhost.*.log
```

#### Restart Services
```bash
# Restart Tomcat
~/tomcat/bin/shutdown.sh
~/tomcat/bin/startup.sh

# Restart Jenkins
pkill -f jenkins.war
cd ~ && nohup java -jar jenkins/jenkins.war --httpPort=8080 > jenkins/jenkins.log 2>&1 &

# Restart Nagios
pkill nagios
/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg
```

### Troubleshooting

#### Application Won't Start
```bash
# Check if Tomcat is running
ps aux | grep tomcat

# Check port availability
netstat -tlnp | grep 9090

# Review logs
tail -100 ~/tomcat/logs/catalina.out
```

#### Jenkins Build Fails
```bash
# Check Java versions
java21  # Should show Java 21
java25  # Should show Java 25

# Check Maven
mvn -version

# View Jenkins console output in web UI
```

#### Port Conflicts
```bash
# Find process using port
sudo lsof -i :9090

# Kill process if needed
sudo kill -9 <PID>
```
### Maintenance

#### Update Application
```bash
cd ~/deploy-petclinic
git pull
# Jenkins will auto-deploy, or run manually:
bash scripts/build-petclinic.sh
bash scripts/deploy-to-root.sh
```

#### Clean Build
```bash
cd ~/deploy-petclinic/spring-petclinic
./mvnw clean
```

#### Backup Configuration
```bash
# Backup important files
tar -czf ~/backup-$(date +%Y%m%d).tar.gz \
  ~/tomcat/conf \
  ~/jenkins/config.xml \
  /usr/local/nagios/etc
```

### Uninstallation

#### Remove Services
```bash
# Stop all services
~/tomcat/bin/shutdown.sh
pkill -f jenkins.war
sudo pkill nagios

# Remove directories
rm -rf ~/tomcat ~/jenkins ~/deploy-petclinic

# Remove user (as root)
sudo userdel -r pet-clinic
```

### Getting Help

#### Check Service Status
```bash
# Quick health check
ps aux | grep -E 'tomcat|jenkins|nagios'
netstat -tlnp | grep -E '8080|9090|80'
```

