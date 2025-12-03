# PetClinic Project Manual

## Architecture

```
GitHub → Jenkins (8080) → Tomcat (9090) → PetClinic
                             ↓
                        Nagios (80)
```

## Components

- **Tomcat 10.1.33** - Web server on port 9090
- **Jenkins 2.528.2** - CI/CD on port 8080  
- **Nagios** - Monitoring on port 80
- **Spring Boot** - PetClinic application
- **Maven** - Build tool
- **Ansible** - Automation

---

## Ansible Playbooks

### `ansible/playbooks/tomcat.yml`
Installs and configures Tomcat.

**What it does:**
- Downloads Tomcat 10.1.33
- Extracts to `~/tomcat`
- Configures port 9090
- Creates admin user (admin/123)
- Starts Tomcat

**Run:**
```bash
ansible-playbook ansible/playbooks/tomcat.yml
```

---

### `ansible/playbooks/jenkins.yml`
Installs Jenkins CI/CD server.

**What it does:**
- Downloads Jenkins 2.528.2 WAR
- Creates `~/jenkins` directory
- Starts Jenkins on port 8080
- Generates initial admin password

**Run:**
```bash
ansible-playbook ansible/playbooks/jenkins.yml
```

---

### `ansible/playbooks/monitor-nagios.yml`
Configures PetClinic monitoring.

**What it does:**
- Adds HTTP check command
- Adds process check command
- Creates service checks for PetClinic
- Restarts Nagios

**Checks created:**
- **PetClinic HTTP Check** - Verifies app responds
- **Tomcat Process Check** - Ensures Java is running

**Run:**
```bash
ansible-playbook ansible/playbooks/monitor-nagios.yml
```

---

### `ansible/playbooks/deploy-petclinic.yml`
Deploys application to Tomcat.

**What it does:**
- Stops Tomcat
- Removes old deployment
- Copies WAR file
- Starts Tomcat

**Run:**
```bash
ansible-playbook ansible/playbooks/deploy-petclinic.yml
```

---

### `ansible/playbooks/verify_petclinic.yml`
Verifies deployment success.

**What it does:**
- Checks Tomcat is running
- Checks port 9090 is open
- Tests HTTP endpoint
- Validates response

**Run:**
```bash
ansible-playbook ansible/playbooks/verify_petclinic.yml
```

---

## Jenkins Pipeline

### `jenkins/Jenkinsfile`

**Stage 1: Checkout**
- Gets latest code from GitHub

**Stage 2: Build**  
- Runs Maven build
- Creates WAR file
- Skips tests for speed

**Stage 3: Deploy**
- Runs Ansible deployment playbook
- Copies WAR to Tomcat

**Stage 4: Verify**
- Runs verification playbook
- Checks application is accessible

**Stage 5: Monitoring**
- Configures Nagios checks

**Trigger:**
- Automatically checks GitHub every 2 minutes
- Builds and deploys on changes

---

## Building Manually

### Build WAR file
```bash
cd spring-petclinic
./mvnw clean package -DskipTests
```

**Output:** `target/spring-petclinic-<version>.war`

### Deploy to Tomcat
```bash
# Stop Tomcat
~/tomcat/bin/shutdown.sh

# Copy WAR
cp target/*.war ~/tomcat/webapps/ROOT.war

# Start Tomcat  
~/tomcat/bin/startup.sh
```

---

## Configuration Files

### Tomcat

**Port configuration:** `~/tomcat/conf/server.xml`
```xml
<Connector port="9090" protocol="HTTP/1.1"/>
```

**Users:** `~/tomcat/conf/tomcat-users.xml`
```xml
<user username="admin" password="123" roles="manager-gui,admin-gui"/>
```

### Nagios

**Check commands:** `/usr/local/nagios/etc/objects/commands.cfg`
```
check_petclinic_http - HTTP check with content verification
check_procs - Process monitoring
```

**Services:** `/usr/local/nagios/etc/servers/petclinic_services.cfg`
```
PetClinic HTTP Check - Monitors application endpoint
Tomcat Process Check - Monitors Java process
```

---

## Directory Structure

```
~/deploy-petclinic/
├── ansible/
│   └── playbooks/          # Automation playbooks
├── jenkins/
│   └── Jenkinsfile        # Pipeline definition
└── spring-petclinic/      # Application source

~/tomcat/                  # Tomcat installation
├── webapps/              # Deployed apps
├── logs/                 # Application logs
└── conf/                 # Configuration

~/jenkins/                # Jenkins home
├── jobs/                 # Pipeline jobs
└── workspace/            # Build workspace

/usr/local/nagios/        # Nagios monitoring
├── etc/                  # Configuration
└── var/                  # Runtime files
```

---

## Development

### Make Changes
```bash
# Edit code
vim spring-petclinic/src/...

# Test locally
cd spring-petclinic
./mvnw spring-boot:run
```

### Commit & Deploy
```bash
# Commit changes
git add .
git commit -m "Description"
git push

# Jenkins auto-deploys in ~2 minutes
```

---

## Troubleshooting

### Check Services
```bash
# Tomcat
ps aux | grep tomcat
netstat -tlnp | grep 9090

# Jenkins
ps aux | grep jenkins
netstat -tlnp | grep 8080

# Nagios
ps aux | grep nagios
```

### View Logs
```bash
# Tomcat
tail -f ~/tomcat/logs/catalina.out

# Jenkins
tail -f ~/jenkins/jenkins.log

# Nagios
tail -f /usr/local/nagios/var/nagios.log
```

### Common Issues

**Tomcat won't start:**
```bash
# Check if port is in use
sudo lsof -i :9090

# Check logs
tail -100 ~/tomcat/logs/catalina.out
```

**Nagios shows wrong status:**
```bash
# Restart Nagios
pkill nagios
/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg

# Wait 1 minute and refresh browser
```

**Build fails:**
```bash
# Clean and rebuild
cd spring-petclinic
./mvnw clean
./mvnw package -DskipTests
```

---

## Ports Reference

| Service | Port | URL |
|---------|------|-----|
| Tomcat | 9090 | http://localhost:9090 |
| Jenkins | 8080 | http://localhost:8080 |
| Nagios | 80 | http://localhost/nagios |

---

## Important Paths

| Component | Path |
|-----------|------|
| Tomcat Home | `~/tomcat` |
| Jenkins Home | `~/jenkins` |
| Nagios Config | `/usr/local/nagios/etc` |
| Application WAR | `~/tomcat/webapps/ROOT.war` |
| Build Output | `spring-petclinic/target/*.war` |
