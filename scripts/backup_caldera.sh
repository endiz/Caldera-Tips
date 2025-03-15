#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Check if caldera service exists
if ! systemctl list-unit-files | grep -q "caldera.service"; then
    echo "Caldera service not found. Please create caldera.service, enable and start it before running this script."
    exit 1
fi

USERNAME=${SUDO_USER:-$(whoami)}
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/${USERNAME}/backups"
LOG_FILE="/var/log/caldera.log"
CALDERA_DIR="/home/${USERNAME}/caldera"

mkdir -p ${BACKUP_DIR}
echo "Stopping caldera service."
sudo systemctl stop caldera.service
cd $(dirname ${CALDERA_DIR})
echo "Starting caldera backup."
tar -czf ${BACKUP_DIR}/caldera_backup_${BACKUP_DATE}.tar.gz $(basename ${CALDERA_DIR})
echo "[$(date)] Caldera backup created: ${BACKUP_DIR}/caldera_backup_${BACKUP_DATE}.tar.gz" >> ${LOG_FILE}
# Keep only last 5 backups
cd ${BACKUP_DIR} && ls -t caldera_backup_*.tar.gz | tail -n +6 | xargs -r rm
echo "Caldera backup created: ${BACKUP_DIR}/caldera_backup_${BACKUP_DATE}.tar.gz. Last 5 backups kept."
echo "Starting caldera service"
sudo systemctl start caldera.service