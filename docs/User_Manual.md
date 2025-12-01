# PetClinic User Manual

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/Omar-Eldamaty/deploy-petclinic.git
cd deploy-petclinic
```

### 2. Install Services

**Install Tomcat:**
```bash
ansible-playbook ansible/playbooks/tomcat.yml
```

**Install Jenkins:**
```bash
ansible-playbook ansible/playbooks/jenkins.yml
```

**Install Monitoring:**
```bash
ansible-playbook ansible/playbooks/monitor-nagios.yml
```

### 3. Setup Jenkins Pipeline

1. Open Jenkins: `http://localhost:8080`
2. Get password: `cat ~/jenkins/secrets/initialAdminPassword`
3. Install suggested plugins
4. Create new Pipeline job
5. Configure Git repository: `https://github.com/Omar-Eldamaty/deploy-petclinic.git`
6. Set script path: `jenkins/Jenkinsfile`
7. Click "Build Now"

## Access Applications

| Application | URL | Credentials |
|-------------|-----|-------------|
| PetClinic | http://localhost:9090/petclinic | None |
| Tomcat Manager | http://localhost:9090/manager | admin / 123 |
| Jenkins | http://localhost:8080 | From file above |
| Nagios | http://localhost/nagios | nagiosadmin / nagios |

## Daily Use

### Deploy Application
Jenkins automatically deploys when you push to GitHub (checks every 2 minutes).

**Manual deployment:**
```bash
cd spring-petclinic
./mvnw clean package -DskipTests
cp target/*.war ~/tomcat/webapps/ROOT.war
```

### Check Status
```bash
# Check if services are running
ps aux | grep -E 'tomcat|jenkins'

# Check application
curl http://localhost:9090/petclinic
```

### View Logs
```bash
# Tomcat logs
tail -f ~/tomcat/logs/catalina.out

# Jenkins logs  
tail -f ~/jenkins/jenkins.log
```

### Restart Services
```bash
# Restart Tomcat
~/tomcat/bin/shutdown.sh
~/tomcat/bin/startup.sh

# Restart Nagios
pkill nagios
/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg
```

## Troubleshooting

**Application not loading?**
```bash
# Check Tomcat is running
ps aux | grep tomcat

# Check port
netstat -tlnp | grep 9090

# View errors
tail -50 ~/tomcat/logs/catalina.out
```

**Build fails in Jenkins?**
- Check console output in Jenkins web UI
- Verify Java is installed: `java -version`

**Port already in use?**
```bash
# Find what's using the port
sudo lsof -i :9090

# Kill the process
sudo kill -9 <PID>
```
