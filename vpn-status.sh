#!/bin/bash

set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $BASEDIR

# ./ssh-to-vm.sh docker exec  wireguard wg show


# Get the full output once
full_output=$(./ssh-to-vm.sh docker exec wireguard wg show wg0)

# Get latest handshakes (format: public_key timestamp)
./ssh-to-vm.sh docker exec wireguard wg show wg0 latest-handshakes | \
while read public_key timestamp; do
    # Skip if timestamp is 0 (never connected)
    if [ "$timestamp" != "0" ]; then
        # Calculate time since last handshake
        current_time=$(date +%s)
        time_diff=$((current_time - timestamp))
        
        # Only show if handshake within last 3 minutes (180 seconds)
        if [ $time_diff -lt 180 ]; then
            # Extract this peer's info from full output
            echo "$full_output" | awk -v peer="$public_key" '
                /^peer: / {
                    if ($2 == peer) {
                        found = 1
                        print
                        next
                    } else {
                        found = 0
                    }
                }
                found && /^  / { print }
                found && /^$/ { exit }
            '
            echo
        fi
    fi
done
