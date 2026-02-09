# 24/7 ARM OCI Server
- This project automates the deployment of a high-performance ```VM.Standard.A1.Flex``` instance on Oracle Cloud Infrastructure
- It sets up a full Ubuntu 24.04 Desktop environment with VNC access
- It auto-deploys specialized game servers running via emulation

# ✨ Core Features
- **Infrastructure as Code:** Full VPC, Subnet, and Security List configuration using Terraform.
- **ARM Optimization:** Leverages the Ampere A1 Compute instance (up to 4 OCPUs / 24GB RAM).
- **Server Ready:** Pre-configured example for:
    - **Counter-Strike 1.6** (Zombie Plague & Zombie Swarm modes).
- **Emulation Stack:** Automatically installs **Box64, Box86, and Wine** to run x86/x64 applications on ARM.
- **Remote Desktop:** Automated GNOME Desktop installation with TigerVNC and Pi-Apps.
- **Secure by Design:** SSH access restricted to a specific management IP.

# 🛡 Security Notes
- SSH (22): Only allowed from the IP specified in my_public_ip
- VNC (5901): Not exposed publicly; access it only via SSH Tunneling
- Game Ports: Open to 0.0.0.0/0 for public connectivity

# 🎮 Game Servers
The infrastructure is ready!
If you want to play on my servers, you can try them at:
- **Counter-Strike 1.6 - Zombie Plague:** `130.61.172.46:27016`
- **Counter-Strike 1.6 - Zombie Swarm:** `130.61.172.46:27017`
