#!/bin/bash

# Set paths for configuration files
ORBIT_CONFIG="/home/user/.arbitrum/orbitSetupScriptConfig.json"
NODE_CONFIG="/home/user/.arbitrum/nodeConfig.json"

# Read sequencerInbox address from the orbitSetupScriptConfig JSON file
SEQUENCER_INBOX_ADDRESS=$(jq -r '.sequencerInbox' "$ORBIT_CONFIG")

# Read the parent-chain-node-url from the nodeConfig JSON file
PARENT_CHAIN_NODE_URL=$(jq -r '.node."data-availability"."parent-chain-node-url"' "$NODE_CONFIG")

# Check if the "data-availability" key exists
if jq -e '.node | has("data-availability")' "$NODE_CONFIG" >/dev/null; then
    # Start daserver with the new command
    /usr/local/bin/daserver \
        --data-availability.parent-chain-node-url "$PARENT_CHAIN_NODE_URL" \
        --enable-rpc \
        --rpc-addr '0.0.0.0' \
        --enable-rest \
        --rest-addr '0.0.0.0' \
        --log-level 3 \
        --data-availability.local-db-storage.enable \
        --data-availability.local-db-storage.data-dir /home/user/das-data \
        --data-availability.local-db-storage.discard-after-timeout=false \
        --data-availability.key.key-dir /home/user/.arbitrum/keys \
        --data-availability.local-cache.enable \
        --data-availability.sequencer-inbox-address "$SEQUENCER_INBOX_ADDRESS"
        --data-availability.s3-storage.enable \
        --data-availability.s3-storage.access-key "<YOUR ACCESS KEY>" \
        --data-availability.s3-storage.bucket "<YOUR BUCKET>" \
        --data-availability.s3-storage.region "<YOUR REGION>" \
        --data-availability.s3-storage.secret-key "<YOUR SECRET KEY>" \
        --data-availability.s3-storage.object-prefix "<YOUR OBJECT KEY PREFIX>/" \
        --data-availability.s3-storage.discard-after-timeout false \
        --data-availability.local-file-storage.enable \
        --data-availability.local-file-storage.data-dir /home/user/data/das-data

else
    # Log a message and exit if "data-availability" key doesn't exist
    echo "You're running in Rollup mode. No need for das-server, so exiting the container ..."
    exit 0
fi
