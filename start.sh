#!/usr/bin/env bash

set -euo pipefail

# We need to run iptables as root to set up the egress firewall.
# For the rest of the operations, we can drop privileges to the 'cool' user.
run_as_cool() {
  setpriv \
    --reuid=cool \
    --regid=cool \
    --init-groups \
    "$@"
}

configure_egress_firewall() {
  local address
  local host

  echo "Configuring Collabora egress firewall"

  # Allows packets that belong to an already-established connection (e.g., responses to incoming requests)
  iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

  # Allow egress to localhost
  iptables -A OUTPUT -d 127.0.0.0/8 -j ACCEPT

  # Allow egress to needed KTP hosts (ktp, ktpjs, and the host)
  for host in ktp ktpjs "$HOST_NAME"; do
    address="$(getent ahostsv4 "$host" | awk '{ print $1; exit }')"
    echo "Allowing egress to $host ($address)"
    iptables -A OUTPUT -d "$address" -j ACCEPT
  done

  # Reject all other egress traffic
  iptables -A OUTPUT -j REJECT
}

configure_egress_firewall

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
run_as_cool coolconfig generate-proof-key

# Copy WOPI proof public key to volume
# Private key is not copied. We'll use public key decryption on the KTP end
# to validate the request without exposing the private key
run_as_cool cp /etc/coolwsd/proof_key.pub /mnt/wopi-proof/collabora-wopi-proof.pub

# Then start Collabora proper as the 'cool' user
exec setpriv \
  --reuid=cool \
  --regid=cool \
  --init-groups \
  /start-collabora-online.sh
