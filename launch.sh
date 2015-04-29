#!/bin/bash

#set -eo pipefail

export ETCD_PORT=${ETCD_PORT:-4001}
export HOST_IP=${HOST_IP:-172.17.42.1}
export ETCD=$HOST_IP:$ETCD_PORT

echo "[smokeping] booting container. ETCD: $ETCD."

# Try to make initial configuration every 5 seconds until successful
until confd -onetime -node $ETCD -config-file /etc/confd/conf.d/sp-general.toml; do
    echo "[smokeping] waiting for confd to create initial smokeping configuration."
    sleep 5
done

# Put a continual polling `confd` process into the background to watch
# for changes every 10 seconds
confd -interval 10 -node $ETCD -config-file /etc/confd/conf.d/sp-general.toml &
echo "[smokeping] confd is now monitoring etcd for changes..."

# Start the smokeping service using the generated config
echo "[smokeping] starting smokeping service..."
service smokeping start

# Follow the logs to allow the script to continue running
tail -f /var/log/*.log

