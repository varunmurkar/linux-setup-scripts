#!/bin/bash

# Basics
echo "Installing apt-fast to speed up future package downloads"
sudo add-apt-repository ppa:apt-fast/stable
# sudo apt-get update
sudo apt-get -y install apt-fast

# Remember to configure apt-fast mirrors to use fastest available servers
echo "Remember to configure apt-fast mirrors to use fastest available servers"

echo "Update installed packages to make avoid conflicts and skip later downloads"
sudo apt-fast upgrade -y

# Install extras for sensible usage
sudo apt-fast install ubuntu-restricted-extras vlc ffmpeg 

# Use Brave instead of Firefox 
sudo apt-fast install apt-transport-https curl
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-fast update
sudo apt-fast install brave-browser
sudo apt purge firefox -yy
sudo apt purge firefox-locale-en -yy
if [ -d "/home/$USER/.mozilla" ]; then
    rm -rf /home/$USER/.mozilla
fi
if [ -d "/home/$USER/.cache/mozilla" ]; then
    rm -rf /home/$USER/.cache/mozilla
fi


# -----------------------
# Harden Linux 
#--Required Packages-
#-ufw
#-fail2ban

echo "Reconfiguring firewall and sysctl rules to harden TCP/IP, rejecting forced connections"

# --- Setup UFW rules
sudo ufw limit 22/tcp  
sudo ufw allow 80/tcp  
sudo ufw allow 443/tcp  
sudo ufw default deny incoming  
sudo ufw default allow outgoing
sudo ufw enable

# --- Harden /etc/sysctl.conf
sudo sysctl kernel.modules_disabled=1
sudo sysctl -a
sudo sysctl -A
sudo sysctl mib
sudo sysctl net.ipv4.conf.all.rp_filter
sudo sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'

# --- Enable fail2ban
sudo apt-fast install fail2ban
sudo cp fail2ban.local /etc/fail2ban/
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Fix power management
sudo add-apt-repository ppa:linrunner/tlp
sudo apt-fast update
sudo apt-fast install tlp tlp-rdw
sudo tlp start

# Prepare gaming specs (1/2): Install better AMD Drivers - Kisak Mesa
sudo dpkg --add-architecture i386
sudo add-apt-repository ppa:kisak/kisak-mesa -y
sudo apt-fast update
sudo apt-fast install libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 -y


# Prepare gaming specs (2/2): Install Steam and custom Proton GE
sudo apt-fast steam
cd ~
wget https://raw.githubusercontent.com/Termuellinator/ProtonUpdater/master/cproton.sh
sudo chmod +x cproton.sh
./cproton.sh


## Music
curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-fast update && sudo apt-fast install spotify-client -y

## Install Git and VS Code
sudo apt-fast install git 
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-fast install apt-transport-https
sudo apt-fast update
sudo apt-fast install code


#Install general utilities
sudo apt-fast install htop synaptic 

# Make things pretty
echo "Installing Papirus icon set"
sudo add-apt-repository ppa:papirus/papirus
sudo apt-fast install papirus-icon-theme

# Remove unnecessary things
sudo apt remove apport apport-gtk

## Gotta reboot now:
sudo apt update && sudo apt upgrade -y
sudo apt autoremove && sudo apt autoclean && sudo apt clean
echo "Remember to tweak startup items and other system settings as required"

echo $'\n'$"*** All done! Please reboot now. ***"
