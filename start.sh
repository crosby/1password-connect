#!/bin/bash
set -euo pipefail

# Connect refuses to start unless its config folder is private to this user.
mkdir -p /home/opuser/.op/data
chmod 700 /home/opuser/.op /home/opuser/.op/data

# The credentials file comes from a secret env var (base64 of 1password-credentials.json).
: "${OP_CREDENTIALS_B64:?Set OP_CREDENTIALS_B64}"
umask 077
echo "$OP_CREDENTIALS_B64" | base64 -d > /home/opuser/.op/1password-credentials.json
export OP_SESSION=/home/opuser/.op/1password-credentials.json
export OP_LOG_LEVEL="${OP_LOG_LEVEL:-info}"

# Same ports as 1Password's Helm chart: they find each other over localhost.
OP_HTTP_PORT=8081 OP_BUS_PORT=11221 OP_BUS_PEERS=localhost:11220 connect-sync &
OP_HTTP_PORT=8080 OP_BUS_PORT=11220 OP_BUS_PEERS=localhost:11221 connect-api &

# If either one exits, stop the container so Northflank restarts both together.
wait -n
exit 1
