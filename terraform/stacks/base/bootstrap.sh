#!/bin/bash

echo "Running gui script..."
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing ufw..."
sudo apt-get install -y ufw

echo "Configuring Firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 27015:27020/tcp
sudo ufw allow 27015:27020/udp
sudo ufw allow 25565/tcp
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
sudo ufw --force enable

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | sudo debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | sudo debconf-set-selections
sudo iptables -I INPUT 1 -p udp --dport 27015:27020 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 27015:27020 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 25565 -j ACCEPT
sudo apt-get install iptables-persistent -y
sudo apt-get install netfilter-persistent -y
sudo netfilter-persistent save


# 1. Set frontend to noninteractive
export DEBIAN_FRONTEND=noninteractive


# 2. Forces automatic selection for gdm3 (avoids interactive prompts - like asking for OK with arrows)
# This command tells the system to choose gdm3 as the default manager without asking
echo "gdm3 shared/default-x-display-manager select gdm3" | debconf-set-selections

# 3. Update and Install with force flags
# -y: yes to everything
# -o Dpkg::Options::="--force-confdef": keep default configs
# -o Dpkg::Options::="--force-confold": do not prompt for old files
apt-get update -y
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
    ubuntu-desktop \
    gnome-shell \
    gnome-session \
    dbus-x11 \
    tigervnc-standalone-server \
    ubuntu-wallpapers \
    gnome-shell-extension-ubuntu-dock \
    firefox \
    gnome-tweaks

# 4. User creation (usually 'ubuntu' exists by default on OCI)
USER_NAME="ubuntu"
USER_HOME="/home/$USER_NAME"

# 5. Configure VNC password (using variable from Terraform)
mkdir -p $USER_HOME/.vnc
echo "${VNC_PASSWORD}" | vncpasswd -f > $USER_HOME/.vnc/passwd
chown -R $USER_NAME:$USER_NAME $USER_HOME/.vnc
chmod 600 $USER_HOME/.vnc/passwd

# 6. CREATE XSTARTUP SCRIPT
# Write the file that VNC will execute
cat <<EOF > $USER_HOME/.vnc/xstartup
#!/bin/sh
export XDG_CURRENT_DESKTOP="Ubuntu:GNOME"
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_SESSION_TYPE="x11"
export GDK_BACKEND=x11
export LIBGL_ALWAYS_SOFTWARE=1

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

if [ -z "\$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval \$(dbus-launch --sh-syntax --exit-with-session)
fi

# Disable the lock-screen to avoid password prompts in VNC
gsettings set org.gnome.desktop.screensaver lock-enabled false

exec gnome-session --session=ubuntu
EOF

chmod +x $USER_HOME/.vnc/xstartup
chown $USER_NAME:$USER_NAME $USER_HOME/.vnc/xstartup



# 7. Install PI-APPS (App store for Steam, Wine, Minecraft on ARM)
# Run as user, not root
sudo -u $USER_NAME bash -c "wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash"

# 8. Create Systemd service for auto-start
sudo tee /etc/systemd/system/vncserver@.service > /dev/null <<EOF
[Unit]
Description=Start TigerVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu
Environment=HOME=/home/ubuntu

PIDFile=/home/ubuntu/.vnc/%H:%i.pid

# Aggressive cleanup before startup
ExecStartPre=-/usr/bin/vncserver -kill :%i
ExecStartPre=-/usr/bin/rm -f /tmp/.X%i-lock /tmp/.X11-unix/X%i

ExecStart=/usr/bin/vncserver :%i -geometry 1920x1080 -depth 24
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

# 9. Enable and start the service
# Stop service first (even if it previously failed)
sudo systemctl stop vncserver@1.service

# Kill any stray VNC processes
sudo pkill -9 vnc
sudo pkill -9 Xtigervnc

# Remove lock files that prevent startup
sudo rm -f /tmp/.X1-lock
sudo rm -f /tmp/.X11-unix/X1

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service
sudo systemctl start vncserver@1.service



# Install emulation and gaming dependencies
sudo -u ubuntu /home/ubuntu/pi-apps/manage install Box64
sudo -u ubuntu /home/ubuntu/pi-apps/manage install Box86
sudo -u ubuntu /home/ubuntu/pi-apps/manage install Steam
sudo -u ubuntu /home/ubuntu/pi-apps/manage install 'Wine (x64)'

sudo apt-get install -y libsdl2-2.0-0
if [ -n "${CS16_REPO}" ]; then
    echo "GitHub repository detected. Cleaning up before launch..."

    # Step 1: Kill old processes to free up ports
    sudo fuser -k 27016/udp 27017/udp > /dev/null 2>&1
    sudo pkill -9 hlds.exe > /dev/null 2>&1
    sleep 2 # Let the system breathe

    TARGET_DIR="/home/ubuntu/Desktop"
    cd "$TARGET_DIR"
    git clone "${CS16_REPO}"
    sudo chown -R ubuntu:ubuntu "$TARGET_DIR/Counter-Strike-1.6-Servers"
    sudo chmod -R 755 "$TARGET_DIR/Counter-Strike-1.6-Servers"

    # Step 2: Start Zombie Plague Server
    echo "Starting ZP Server on port 27016..."
    ZP_SERVER="$TARGET_DIR/Counter-Strike-1.6-Servers/Counter-StrikeZP"
    cd "$ZP_SERVER"
    sudo -u ubuntu bash -c "cd $ZP_SERVER && \
    export DISPLAY=:1 && \
    export LIBGL_ALWAYS_SOFTWARE=1 && \
    nohup box64 wine ./hlds.exe -console -game cstrike +ip 0.0.0.0 +port 27016 +maxplayers 32 +map zm_dust2 -nomaster > /home/ubuntu/zp_log.txt 2>&1 &"

    # Step C: Start Zombie Swarm Server
    echo "Starting ZS Server on port 27017..."
    ZS_SERVER="$TARGET_DIR/Counter-Strike-1.6-Servers/Counter-StrikeZS"
    cd "$ZS_SERVER"
    sudo -u ubuntu bash -c "cd $ZS_SERVER && \
    export DISPLAY=:1 && \
    export LIBGL_ALWAYS_SOFTWARE=1 && \
    nohup box64 wine ./hlds.exe -console -game cstrike +ip 0.0.0.0 +port 27017 +maxplayers 32 +map zm_dust2 -nomaster > /home/ubuntu/zs_log.txt 2>&1 &"

    echo "Servers started in the background!"
else
    echo "No GitHub token provided."
fi
