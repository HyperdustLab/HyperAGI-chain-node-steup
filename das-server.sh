#!/bin/bash

# Set paths for configuration files
ORBIT_CONFIG="/home/user/.arbitrum/orbitSetupScriptConfig.json"
NODE_CONFIG="/home/user/.arbitrum/nodeConfig.json"

# Create keys directory and generate keys if they don't exist
mkdir -p /home/user/.arbitrum/keys && \
[ ! -f /home/user/.arbitrum/keys/das_bls.pub ] && datool keygen --dir /home/user/.arbitrum/keys; \
[ ! -f /home/user/.arbitrum/keys/ecdsa.pub ] && datool keygen --dir /home/user/.arbitrum/keys --ecdsa;

# Read sequencerInbox address from the orbitSetupScriptConfig JSON file
SEQUENCER_INBOX_ADDRESS=$(jq -r '.sequencerInbox' "$ORBIT_CONFIG")

# Read the parent-chain-node-url from the nodeConfig JSON file
PARENT_CHAIN_NODE_URL=$(jq -r '.node."data-availability"."parent-chain-node-url"' "$NODE_CONFIG")

# Check if the "data-availability" key exists
if jq -e '.node | has("data-availability")' "$NODE_CONFIG" >/dev/null; then
    # Start daserver with the new command
    /usr/local/bin/daserver \
        --data-availability.extra-signature-checking-public-key /home/user/.arbitrum/keys/ecdsa.pub \
        --data-availability.parent-chain-node-url "$PARENT_CHAIN_NODE_URL" \
        --enable-rpc \
        --rpc-addr '0.0.0.0' \
        --enable-rest \
        --rest-addr '0.0.0.0' \
        --log-level 5 \
        --data-availability.local-db-storage.enable \
        --data-availability.local-db-storage.data-dir /home/user/das-data \
        --data-availability.local-db-storage.discard-after-timeout=true \
        --data-availability.s3-storage.enable \
        --data-availability.s3-storage.access-key "$S3_ACCESS_KEY" \
        --data-availability.s3-storage.bucket "$S3_BUCKET" \
        --data-availability.s3-storage.region "$S3_REGION" \
        --data-availability.s3-storage.secret-key "$S3_SECRET_KEY" \
        --data-availability.s3-storage.object-prefix "$S3_OBJECT_PREFIX" \
        --data-availability.key.key-dir /home/user/.arbitrum/keys \
        --data-availability.local-cache.enable \
        --data-availability.rest-aggregator.enable \
        --data-availability.rest-aggregator.sync-to-storage.eager \
        --data-availability.rest-aggregator.sync-to-storage.state-dir /home/user/syncState \
        --data-availability.rest-aggregator.urls "http://3.7.54.15:9877,http://3.110.25.201:9877" \
        --data-availability.sequencer-inbox-address "$SEQUENCER_INBOX_ADDRESS"
else
    # Log a message and exit if "data-availability" key doesn't exist
    echo "You're running in Rollup mode. No need for das-server, so exiting the container ..."
    exit 0
fi
