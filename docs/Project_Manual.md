# PetClinic Project Manual

## Technical Architecture

### System Overview
```
GitHub → Jenkins (Port 8080) → Tomcat (Port 9090) → PetClinic App
                                    ↓
                              Nagios Monitor (Port 80)
```

### Technology Stack
- **Runtime**: Java 21
- **Build**: Java 25 + Maven 3.8.8
- **App Server**: Tomcat 10.1.33
- **CI/CD**: Jenkins 2.528.2
- **Automation**: Ansible 2.x
- **Monitoring**: Nagios Core 4.x
- **Framework**: Spring Boot 4.0.0-SNAPSHOT

---

## Shell Scripts Reference

### Setup Scripts

#### `setup/setup-pet-clinic-user.sh`
Creates `pet-clinic` user and installs Java versions.

**What it does:**
1. Creates user with home directory
2. Adds to sudo group
3. Downloads Java 21 and 25
4. Extracts to `/opt/`
5. Creates Java switch commands (`java21`, `java25`)

**Usage:**
```bash
sudo bash setup/setup-pet-clinic-user.sh
```

**Key Variables:**
- `NEW_USER="pet-clinic"`
- `JAVA21_URL`: Oracle Java 21 download link
- `JAVA25_URL`: Oracle Java 25 download link
- `JAVA_INSTALL_DIR="/opt"`

---

#### `scripts/install-ansible.sh`
Installs Ansible using apt package manager.

**What it does:**
1. Updates package cache
2. Installs software-properties-common
3. Adds Ansible PPA
4. Installs ansible

**Usage:**
```bash
sudo bash scripts/install-ansible.sh
```

---

### Build & Deploy Scripts

#### `scripts/build-petclinic.sh`
Builds PetClinic WAR file using Maven.

**What it does:**
1. Switches to Java 25
2. Creates ServletInitializer for WAR packaging
3. Runs Maven clean package
4. Skips tests for faster builds
5. Outputs WAR to `target/petclinic.war`

**Usage:**
```bash
bash scripts/build-petclinic.sh
```

**Key Commands:**
```bash
cd spring-petclinic
bash ../scripts/create-servlet-initializer.sh
source ~/.bashrc && java25
./mvnw clean package -DskipTests
```

**Output:**
- `target/petclinic.war` (deployable WAR file)

---

#### `scripts/create-servlet-initializer.sh`
Creates ServletInitializer for Spring Boot WAR deployment.

**What it does:**
1. Creates necessary Java package directory
2. Generates ServletInitializer.java file
3. Extends SpringBootServletInitializer

**Usage:**
```bash
cd spring-petclinic
bash ../scripts/create-servlet-initializer.sh
```

**Generated File:**
```java
package org.springframework.samples.petclinic;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

public class ServletInitializer extends SpringBootServletInitializer {
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(PetClinicApplication.class);
    }
}
```

---

#### `scripts/deploy-to-root.sh`
Deploys WAR to Tomcat ROOT context.

**What it does:**
1. Stops Tomcat
2. Removes old ROOT deployment
3. Copies new WAR as ROOT.war
4. Starts Tomcat

**Usage:**
```bash
bash scripts/deploy-to-root.sh
```

**Key Steps:**
```bash
~/tomcat/bin/shutdown.sh
rm -rf ~/tomcat/webapps/ROOT ~/tomcat/webapps/ROOT.war
cp spring-petclinic/target/petclinic.war ~/tomcat/webapps/ROOT.war
~/tomcat/bin/startup.sh
```

**Result:**
- Application accessible at `http://localhost:9090/petclinic`

---

#### `scripts/maven_download.sh`
Downloads and installs Maven (if not using wrapper).

**What it does:**
1. Downloads Maven binary
2. Extracts to `/opt/maven`
3. Sets up environment variables
4. Creates maven command alias

**Usage:**
```bash
bash scripts/maven_download.sh
```

---

## Ansible Playbooks Reference

### Service Installation Playbooks

#### `ansible/playbooks/tomcat.yml`
Installs and configures Tomcat 10.1.33.

**Tasks:**
1. Download Tomcat binary
2. Extract to `~/tomcat`
3. Configure server.xml (port 9090)
4. Setup admin users
5. Deploy manager apps
6. Start Tomcat

**Variables:**
- `tomcat_version: "10.1.33"`
- `tomcat_port: 9090`
- `tomcat_admin_user: admin`
- `tomcat_admin_pass: 123`

**Usage:**
```bash
ansible-playbook ansible/playbooks/tomcat.yml
```

---

#### `ansible/playbooks/jenkins.yml`
Installs and configures Jenkins CI/CD server.

**Tasks:**
1. Download Jenkins WAR
2. Create Jenkins home directory
3. Start Jenkins service
4. Configure port 8080
5. Setup initial admin password

**Variables:**
- `jenkins_version: "2.528.2"`
- `jenkins_port: 8080`
- `jenkins_home: ~/jenkins`

**Usage:**
```bash
ansible-playbook ansible/playbooks/jenkins.yml
```

---

#### `ansible/playbooks/install-monitoring.yml`
Installs Nagios monitoring system.

**Tasks:**
1. Download Nagios Core source
2. Compile and install
3. Configure web interface
4. Setup Apache integration
5. Create nagios user
6. Start Nagios daemon

**Variables:**
- `nagios_version: "4.4.14"`
- `nagios_port: 80`

**Usage:**
```bash
ansible-playbook ansible/playbooks/install-monitoring.yml
```

---

#### `ansible/playbooks/monitor-nagios.yml`
Configures PetClinic monitoring checks.

**Tasks:**
1. Create check commands
2. Define service checks (HTTP + Process)
3. Configure Nagios to monitor PetClinic
4. Restart Nagios

**Monitored Services:**
- **PetClinic HTTP Check**: Verifies app responds with "Spring PetClinic"
- **Tomcat Process Check**: Ensures Java process is running

**Usage:**
```bash
ansible-playbook ansible/playbooks/monitor-nagios.yml
```

**Check Commands:**
```yaml
check_petclinic_http: Check HTTP endpoint with content verification
check_procs: Check if Java process is running
```

---

### Deployment Playbooks

#### `ansible/playbooks/deploy-petclinic.yml`
Deploys PetClinic to Tomcat.

**Tasks:**
1. Stop Tomcat
2. Remove old deployment
3. Copy WAR file
4. Start Tomcat
5. Wait for deployment

**Usage:**
```bash
ansible-playbook ansible/playbooks/deploy-petclinic.yml
```

---

#### `ansible/playbooks/verify_petclinic.yml`
Verifies PetClinic deployment.

**Tasks:**
1. Check Tomcat is running
2. Verify port 9090 is listening
3. Test HTTP endpoint
4. Validate response content

**Usage:**
```bash
ansible-playbook ansible/playbooks/verify_petclinic.yml
```

---

## Jenkins Pipeline

### Jenkinsfile Stages

#### Stage 1: Checkout
```groovy
git url: 'https://github.com/Omar-Eldamaty/deploy-petclinic.git'
```
**Purpose**: Get latest code from GitHub

---

#### Stage 2: Build
```groovy
sh 'bash scripts/build-petclinic.sh'
```
**Purpose**: Compile application using Maven + Java 25

---

#### Stage 3: Deploy
```groovy
sh 'ansible-playbook ansible/playbooks/deploy-petclinic.yml'
```
**Purpose**: Deploy WAR to Tomcat using Ansible

---

#### Stage 4: Sanity Check
```groovy
sh 'curl -f http://localhost:9090/petclinic'
```
**Purpose**: Verify application is accessible

---

#### Stage 5: Monitoring
```groovy
sh 'ansible-playbook ansible/playbooks/monitor-nagios.yml'
```
**Purpose**: Configure/update monitoring checks

---

### Pipeline Configuration

**SCM Polling:**
```groovy
triggers {
    pollSCM('H/2 * * * *')  // Check every 2 minutes
}
```

**Environment:**
```groovy
environment {
    JAVA_HOME = '/opt/jdk-21'
    MAVEN_HOME = '/opt/apache-maven-3.8.8'
    PATH = "$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"
}
```

---

## Configuration Files

### Tomcat Configuration

**`~/tomcat/conf/server.xml`**
```xml
<Connector port="9090" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

**`~/tomcat/conf/tomcat-users.xml`**
```xml
<user username="admin" password="123" 
      roles="manager-gui,admin-gui"/>
```

---

### Jenkins Configuration

**Job Configuration:**
- Type: Pipeline
- SCM: Git
- Repository: https://github.com/Omar-Eldamaty/deploy-petclinic.git
- Script Path: jenkins/Jenkinsfile
- Poll SCM: H/2 * * * *

---

### Nagios Configuration

**Commands (`/usr/local/nagios/etc/objects/commands.cfg`):**
```cfg
define command{
    command_name    check_petclinic_http
    command_line    /usr/local/nagios/libexec/check_http -H $ARG1$ -p $ARG2$ -u $ARG3$ -s "$ARG4$" --onredirect=critical
}
```

**Services (`/usr/local/nagios/etc/servers/petclinic_services.cfg`):**
```cfg
define service {
    host_name               localhost
    service_description     PetClinic HTTP Check
    check_command           check_petclinic_http!127.0.0.1!9090!/petclinic!Spring PetClinic
}
```

---

## Directory Structure

```
/home/pet-clinic/
├── deploy-petclinic/           # Project repository
│   ├── setup/                  # Setup scripts
│   ├── scripts/                # Automation scripts
│   ├── ansible/                # Playbooks & inventory
│   ├── jenkins/                # Pipeline definition
│   ├── spring-petclinic/       # Application source
│   └── docs/                   # Documentation
│
├── tomcat/                     # Tomcat installation
│   ├── bin/                    # Start/stop scripts
│   ├── conf/                   # Configuration files
│   ├── webapps/                # Deployed applications
│   └── logs/                   # Application logs
│
└── jenkins/                    # Jenkins home
    ├── config.xml              # Jenkins configuration
    ├── jobs/                   # Pipeline jobs
    ├── workspace/              # Build workspace
    └── secrets/                # Admin password

/opt/
├── jdk-21/                     # Java 21 runtime
└── jdk-25/                     # Java 25 build tools

/usr/local/nagios/              # Nagios installation
├── bin/                        # Nagios binaries
├── etc/                        # Configuration
├── var/                        # Runtime files
└── share/                      # Web interface
```

---

## Development Workflow

### Adding New Features

1. **Clone repository**
```bash
git clone https://github.com/Omar-Eldamaty/deploy-petclinic.git
cd deploy-petclinic
```

2. **Create feature branch**
```bash
git checkout -b feature/my-feature
```

3. **Make changes**
```bash
# Edit code in spring-petclinic/
```

4. **Test locally**
```bash
bash scripts/build-petclinic.sh
bash scripts/deploy-to-root.sh
curl http://localhost:9090/petclinic
```

5. **Commit and push**
```bash
git add .
git commit -m "Add new feature"
git push origin feature/my-feature
```

6. **Jenkins auto-deploys** (if merged to main)

---

### Customizing Deployment

**Change Tomcat Port:**
```bash
# Edit ansible/playbooks/tomcat.yml
# Change tomcat_port variable
# Re-run playbook
ansible-playbook ansible/playbooks/tomcat.yml
```

**Add Monitoring Checks:**
```bash
# Edit ansible/playbooks/monitor-nagios.yml
# Add new service definitions
# Re-run playbook
ansible-playbook ansible/playbooks/monitor-nagios.yml
```

**Modify Build Process:**
```bash
# Edit scripts/build-petclinic.sh
# Update Maven goals/options
# Test build
bash scripts/build-petclinic.sh
```

---

## Troubleshooting Guide

### Build Issues

**Maven Build Fails:**
```bash
# Check Java version
java25

# Clean and rebuild
cd spring-petclinic
./mvnw clean
bash ../scripts/build-petclinic.sh
```

**ServletInitializer Missing:**
```bash
cd spring-petclinic
bash ../scripts/create-servlet-initializer.sh
```

---

### Deployment Issues

**Tomcat Won't Start:**
```bash
# Check logs
tail -100 ~/tomcat/logs/catalina.out

# Check port
netstat -tlnp | grep 9090

# Kill conflicting process
kill -9 $(lsof -t -i:9090)
```

**WAR Not Deploying:**
```bash
# Check file exists
ls -lh ~/tomcat/webapps/ROOT.war

# Check permissions
chmod 644 ~/tomcat/webapps/ROOT.war

# Force undeploy
rm -rf ~/tomcat/webapps/ROOT*
```

---

### Monitoring Issues

**Nagios Shows Wrong Status:**
```bash
# Restart Nagios
pkill nagios
/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg

# Force service check
echo "[$(date +%s)] SCHEDULE_FORCED_SVC_CHECK;localhost;PetClinic HTTP Check;$(date +%s)" > /usr/local/nagios/var/rw/nagios.cmd
```

**Check Commands Fail:**
```bash
# Test manually
/usr/local/nagios/libexec/check_http -H 127.0.0.1 -p 9090 -u /petclinic -s "Spring PetClinic"
```

---

## Performance Tuning

### Tomcat Optimization
```bash
# Edit ~/tomcat/bin/setenv.sh
export CATALINA_OPTS="-Xms512M -Xmx2048M -XX:MaxPermSize=512m"
```

### Jenkins Optimization
```bash
# Start Jenkins with more memory
java -Xmx1024m -jar jenkins/jenkins.war --httpPort=8080
```

### Build Speed
```bash
# Use Maven daemon for faster builds
./mvnw -Dmaven.test.skip=true package
```

---

## Security Best Practices

1. **Change Default Passwords**
```bash
# Edit ~/tomcat/conf/tomcat-users.xml
# Change admin password from default
```

2. **Restrict Manager Access**
```bash
# Edit ~/tomcat/conf/server.xml
# Add RemoteAddrValve to limit access
```

3. **Enable HTTPS**
```bash
# Generate keystore
keytool -genkey -alias tomcat -keyalg RSA
# Configure SSL in server.xml
```

4. **Regular Updates**
```bash
# Check for security updates regularly
# Update Java, Tomcat, Jenkins versions
```

---

## Backup & Recovery

### Backup Script
```bash
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf ~/backup-$DATE.tar.gz \
  ~/tomcat/conf \
  ~/jenkins/config.xml \
  ~/jenkins/jobs \
  /usr/local/nagios/etc
```

### Restore
```bash
tar -xzf ~/backup-YYYYMMDD.tar.gz -C /
# Restart services
```

---

## Contributing

See main README.md for contribution guidelines.

---

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Tomcat Documentation](https://tomcat.apache.org/tomcat-10.1-doc/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Ansible Documentation](https://docs.ansible.com/)
