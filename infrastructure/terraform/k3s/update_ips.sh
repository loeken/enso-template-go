#!/bin/bash

# Fetch the current public IP
newip=$(curl -s ifconfig.co -4)

# Exit the script if no public IP was found
if [ -z "$newip" ]; then
  echo "Could not retrieve public IP."
  exit 1
fi

# Check if /opt/oldip exists, if not, create it with the current public IP
if [ ! -f /opt/oldip ]; then
  echo $newip > /opt/oldip
fi

# Fetch the IP that was saved in /opt/oldip
oldip=$(cat /opt/oldip)

# If the IPs don't match, replace the IP in the K3s service configuration
# and restart the service
if [ "$oldip" != "$newip" ]; then
  sed -i "s/$oldip/$newip/g" /etc/systemd/system/k3s.service
  systemctl daemon-reload
  systemctl restart k3s
  echo $newip > /opt/oldip
fi
