#!/bin/bash
################################################################################
# Script: create-servlet-initializer.sh
# Description: Create ServletInitializer class for Tomcat deployment
# Usage: bash create-servlet-initializer.sh
################################################################################

set -e

SRC_DIR="$HOME/spring-petclinic"
INIT_FILE="$SRC_DIR/src/main/java/org/springframework/samples/petclinic/ServletInitializer.java"

if [ ! -d "$SRC_DIR" ]; then
    echo "[ERROR] Source directory not found: $SRC_DIR"
    exit 1
fi

echo "=========================================="
echo " Creating ServletInitializer"
echo "=========================================="

if [ -f "$INIT_FILE" ]; then
    echo "[INFO] ServletInitializer already exists"
else
    echo "[INFO] Creating ServletInitializer.java..."
    
    cat > "$INIT_FILE" << 'JAVA_EOF'
package org.springframework.samples.petclinic;

import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

public class ServletInitializer extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(PetClinicApplication.class);
    }

}
JAVA_EOF

    echo "[SUCCESS] ServletInitializer created at:"
    echo "$INIT_FILE"
fi

