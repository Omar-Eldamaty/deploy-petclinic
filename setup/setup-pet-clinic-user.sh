#!/bin/bash
if [ "$EUID" -ne 0 ]; then
        echo " You must run this script as root."
        exit 1
fi

if id "pet-clinic" &>/dev/null; then
        echo "[INFO] User pet-clinic already exists"
else
        echo "[INFO] Creating user pet-clinic"
        useradd -m -s /bin/bash pet-clinic
        echo "[INFO] Created pet-clinic"
fi

USER_NAME="pet-clinic"
HOME_DIR="/home/$USER_NAME"
JAVA_DIR="$HOME_DIR/java"
BASHRC="$HOME_DIR/.bashrc"

JAVA21_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%2B11/OpenJDK21U-jdk_x64_linux_hotspot_21.0.5_11.tar.gz"
JAVA25_URL="https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz"

echo "[INFO] Switching to user '$USER_NAME'..."
su - "$USER_NAME" <<EOF
echo "welcome \$(whoami)"

if [ ! -d "$JAVA_DIR" ]; then
        echo "creating dir: $JAVA_DIR"
        mkdir -p "$JAVA_DIR"
else
        echo "$JAVA_DIR exist"
fi

cd "$JAVA_DIR"

#install Java 21
if [ ! -d "jdk21" ]; then
        echo "Downloading JDK 21"
        curl -L -o jdk21.tar.gz "$JAVA21_URL" || { echo "Download failed."; exit 1; }
        echo "Extracting JDK 21..."
        tar -xzf jdk21.tar.gz
        EXTRACTED=\$(ls | grep "^jdk-21" | head -n 1)
        echo "[INFO] Extracted directory: \$EXTRACTED"
        mv "\$EXTRACTED" jdk21
        rm jdk21.tar.gz
        echo "[INFO] JDK 21 installed"
else
        echo "[INFO] JDK 21 already installed"
fi

#install Java 25
if [ ! -d "jdk25" ]; then
        echo "Downloading JDK 25"
        curl -L -o jdk25.tar.gz "$JAVA25_URL" || { echo "Download failed."; exit 1; }
        echo "Extracting JDK 25..."
        tar -xzf jdk25.tar.gz
        EXTRACTED=\$(ls | grep "^jdk-25" | head -n 1)
        echo "[INFO] Extracted directory: \$EXTRACTED"
        mv "\$EXTRACTED" jdk25
        rm jdk25.tar.gz
        echo "[INFO] JDK 25 installed"
else
        echo "[INFO] JDK 25 already installed"
fi

if ! grep -q "export JAVA21_HOME=" "$BASHRC"; then
        echo "" >> "$BASHRC"
        echo "# Java setup" >> "$BASHRC"
        echo "export JAVA21_HOME=$JAVA_DIR/jdk21" >> "$BASHRC"
        echo "export JAVA25_HOME=$JAVA_DIR/jdk25" >> "$BASHRC"
        echo "export JAVA_HOME=\\\$JAVA21_HOME" >> "$BASHRC"
        echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> "$BASHRC"
        echo "alias java21='export JAVA_HOME=\\\$JAVA21_HOME && export PATH=\\\$JAVA_HOME/bin:\\\$PATH && java -version'" >> "$BASHRC"
        echo "alias java25='export JAVA_HOME=\\\$JAVA25_HOME && export PATH=\\\$JAVA_HOME/bin:\\\$PATH && java -version'" >> "$BASHRC"
fi

echo "[INFO] Java setup complete"
EOF

echo "[INFO] Verifying installation..."
su - "$USER_NAME" -c 'java -version'
