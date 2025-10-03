#!/usr/bin/env bash

set -euo pipefail

# Determine own port and update that into coolwsd.xml
echo "Attempting to connect to KTP apps API to obtain own port number"

SELF_PORT="$(curl \
  -sSL \
  --retry 10 \
  --retry-delay 0 \
  --retry-max-time 60 \
  --retry-connrefused \
  "http://ktpjs:$KTP_REST_PORT/apps/collabora/port"
)"

SERVER_NAME="$HOST_NAME:$SELF_PORT"
echo "Port number obtained, replacing server name in coolwsd.xml with '$SERVER_NAME'"
sed -i "s|>.*</server_name>|>$SERVER_NAME</server_name>|g" /etc/coolwsd/coolwsd.xml

# Generate Collabora WOPI proof and copy public key to WOPI proof volume
coolconfig generate-proof-key

# Copy WOPI proof public key to volume
# Private key is not copied. We'll use public key decryption on the KTP end
# to validate the request without exposing the private key
cp /etc/coolwsd/proof_key.pub /mnt/wopi-proof/collabora-wopi-proof.pub

# Then start Collabora proper
exec /start-collabora-online.sh
