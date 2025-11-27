#!/bin/bash

set -e

REPO_URL="https://github.com/Omar-Eldamaty/deploy-petclinic"
SRC_DIR="$HOME/deploy-petclinic/spring-petclinic"
MAVEN_DIR="$HOME/maven"
WAR_OUTPUT_DIR="$HOME/build"

# Ensure output directory exists
mkdir -p "$WAR_OUTPUT_DIR"

echo "[INFO] Checking Maven..."
if [ ! -d "$MAVEN_DIR" ]; then
    echo "[INFO] Downloading Maven..."
    wget https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz -O /tmp/maven.tar.gz
    mkdir -p "$MAVEN_DIR"
    tar -xzf /tmp/maven.tar.gz -C "$MAVEN_DIR" --strip-components=1
fi

export PATH="$MAVEN_DIR/bin:$PATH"

echo "[INFO] Cloning PetClinic repo..."
if [ ! -d "$SRC_DIR" ]; then
    git clone "$REPO_URL" "$SRC_DIR"
else
    cd "$SRC_DIR"
    git pull
fi

cd "$SRC_DIR"
export JAVA_HOME="$HOME/java/jdk25"
export PATH="$JAVA_HOME/bin:$PATH"

echo "[INFO] Building WAR with JDK25..."
mvn clean package -DskipTests

echo "[INFO] Copying WAR to build directory..."
cp "$SRC_DIR/target/spring-petclinic-4.0.0-SNAPSHOT.war" "$WAR_OUTPUT_DIR/petclinic.war"

echo "[SUCCESS] Build completed. WAR file in $WAR_OUTPUT_DIR"

