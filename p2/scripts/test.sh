#!/bin/bash

IP="192.168.56.110"
HOSTS=("app1.com" "app2.com" "app3.com")
HOSTS_FILE="/etc/hosts"

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo ./add_hosts.sh'."
    exit 1
fi

# Backup the original hosts file
cp "$HOSTS_FILE" "$HOSTS_FILE.bak"
echo "Backed up original $HOSTS_FILE to $HOSTS_FILE.bak"

# Add entries if they don't exist
for HOST in "${HOSTS[@]}"; do
    if ! grep -q "$IP $HOST" "$HOSTS_FILE"; then
        echo "$IP $HOST" >> "$HOSTS_FILE"
        echo "Added: $IP $HOST"
    else
        echo "Entry already exists: $IP $HOST"
    fi
done

echo "Done. Entries added to $HOSTS_FILE."

