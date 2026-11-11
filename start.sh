#!/bin/sh

set -eu

# Determine own port and update that into coolwsd.xml.
# wget comes from busybox; the distroless image has no curl.
echo "Attempting to connect to KTP apps API to obtain own port number"

SELF_PORT=""
attempt=0
while [ "$attempt" -lt 10 ]; do
  attempt=$((attempt + 1))
  if SELF_PORT="$(wget -q -T 5 -O - "http://ktpjs:${KTP_REST_PORT}/apps/collabora/port")" && [ -n "$SELF_PORT" ]; then
    break
  fi
  SELF_PORT=""
  if [ "$attempt" -lt 10 ]; then
    sleep 1
  fi
done

if [ -z "$SELF_PORT" ]; then
  echo "Failed to obtain port number from KTP apps API" >&2
  exit 1
fi

SERVER_NAME="$HOST_NAME:$SELF_PORT"
echo "Port number obtained, replacing server name in coolwsd.xml with '$SERVER_NAME'"
sed -i "s|>.*</server_name>|>$SERVER_NAME</server_name>|g" /etc/coolwsd/coolwsd.xml

# Generate Collabora WOPI proof and copy public key to WOPI proof volume.
# coolconfig is not shipped in the distroless image; openssl writes the same PEM pair.
openssl genpkey -algorithm RSA -out /etc/coolwsd/proof_key -pkeyopt rsa_keygen_bits:2048
openssl rsa -in /etc/coolwsd/proof_key -outform PEM -pubout -out /etc/coolwsd/proof_key.pub
chmod 600 /etc/coolwsd/proof_key

# Copy WOPI proof public key to volume
# Private key is not copied. We'll use public key decryption on the KTP end
# to validate the request without exposing the private key
cp /etc/coolwsd/proof_key.pub /mnt/wopi-proof/collabora-wopi-proof.pub

# Then start Collabora proper. The image no longer ships start-collabora-online.sh.
exec /usr/bin/coolwsd \
  --use-env-vars \
  --o:sys_template_path=/opt/cool/systemplate \
  --o:child_root_path=/opt/cool/child-roots \
  --o:file_server_root_path=/usr/share/coolwsd \
  --o:cache_files.path=/opt/cool/cache \
  --o:logging.color=false \
  --o:stop_on_config_change=true
