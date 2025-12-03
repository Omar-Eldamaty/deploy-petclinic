#!/bin/bash
echo "=== Starting Nagios Setup ==="

# Fix permissions
sudo chown -R nagios:nagcmd /home/pet-clinic/nagios
sudo chmod 775 /home/pet-clinic/nagios/var
sudo chmod 775 /home/pet-clinic/nagios/var/rw 2>/dev/null || sudo mkdir -p /home/pet-clinic/nagios/var/rw && sudo chmod 775 /home/pet-clinic/nagios/var/rw
sudo chmod 664 /home/pet-clinic/nagios/var/rw/nagios.cmd 2>/dev/null || true

# Kill any existing Nagios
sudo pkill -9 -f nagios 2>/dev/null

# Start Nagios
echo "Starting Nagios..."
sudo -u nagios /home/pet-clinic/nagios/bin/nagios -d /home/pet-clinic/nagios/etc/nagios.cfg

# Wait and check
sleep 3
echo "=== Checking Status ==="
if ps aux | grep -q "[n]agios"; then
    echo "✅ Nagios is running!"
    ps aux | grep -E "[n]agios"
else
    echo "❌ Nagios failed to start"
    echo "Checking logs..."
    sudo tail -20 /home/pet-clinic/nagios/var/nagios.log 2>/dev/null || echo "No log file"
fi

# Create systemd service for future starts
echo "=== Creating systemd service ==="
sudo tee /etc/systemd/system/nagios.service << 'EOF'
[Unit]
Description=Nagios Monitoring Server
After=network.target

[Service]
Type=forking
User=nagios
Group=nagcmd
ExecStart=/home/pet-clinic/nagios/bin/nagios -d /home/pet-clinic/nagios/etc/nagios.cfg
PIDFile=/home/pet-clinic/nagios/var/nagios.lock
Restart=on-failure
RestartSec=30s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nagios
sudo systemctl start nagios 2>/dev/null || true

echo "=== Final Status ==="
sudo systemctl status nagios --no-pager | head -20
