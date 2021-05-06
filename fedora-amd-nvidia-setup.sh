#!/bin/bash

# Disclaimer
echo "Dear future-me or anyone else: If using this script willy-nilly breaks your stuff, past-me is not responsible." '\n'"At this time, this script is not meant to be interactive, but just quickly automate the usual tasks. Check before executing."

# Basics
# Configure DNF for faster download
# sudo nano /etc/dnf/dnf.conf
## Add line : max_parallel_downloads=10
echo 'fastestmirror=true' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=5' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
cat /etc/dnf/dnf.conf

echo "Enabling RPM Fusion and making sure we're update to all latest packages"
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf upgrade --refresh
sudo dnf check
sudo dnf autoremove
sudo dnf update
sudo reboot

# Let's make sure we have WiFi
echo "Let's make sure we have WiFi"
sudo dnf install kmod-wl
# sudo reboot

# Install extras for sensible usage
sudo dnf install zsh wget dnf-plugins-core celluloid ffmpeg htop apt-transport-https curl gnome-tweak-tool gnome-extensions-app gnome-shell-extension-appindicator gimp timeshift -y
zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# Install additional multimedia codecs
# sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
# sudo dnf groupupdate sound-and-video
sudo dnf install gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install lame\* --exclude=lame-devel
sudo dnf group upgrade --with-optional Multimedia

# Optimize Power Management
sudo dnf install tlp tlp-rdw powertop
sudo systemctl enable tlp && sudo tlp start

# Enable Flathub for Flatpak
$ flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo flatpak update

# Install OBS, Todoist, Obsidian 
flatpak install flathub com.obsproject.Studio com.todoist.Todoist md.obsidian.Obsidian

# Install Mailspring
# Download latest .rpm from https://getmailspring.com/download
cd ~/Downloads
sudo dnf install mailspring-*.x86_64.rpm -y

# Install Telegram
sudo dnf install telegram-desktop

# Install Development Tools
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code git


# Use Brave instead of Firefox 
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser
sudo dnf remove firefox firefox-locale-en
rm -rf /home/$USER/.mozilla
rm -rf /home/$USER/.cache/mozilla

# Install Slack : Download .rpm from https://slack.com/intl/en-in/downloads/linux

# Install OnlyOffice : Download .rpm from https://slack.com/intl/en-in/downloads/linux
wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors.x86_64.rpm
sudo dnf localinstall onlyoffice-desktopeditors.x86_64.rpm

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
sudo dnf install epel-release -y
sudo dnf install fail2ban -y
sudo systemctl enable fail2ban && sudo systemctl start fail2ban
sudo nano /etc/fail2ban/jail.local
# Add the following in jail.local (uncommented, obviously)
# [sshd]
# enabled = true
# port = 22
# filter = sshd
# logpath = /var/log/auth.log
# maxretry = 3
sudo systemctl restart fail2ban

# Enable hardware accelaration : Install better Nvidia drivers & libraries
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda vdpauinfo libva-vdpau-driver libva-utils
modinfo -F version nvidia
# sudo dnf install vulkan-loader vulkan-loader.i686 fedora-workstation-repositories
# sudo dnf config-manager --set-enabled rpmfusion-nonfree-nvidia-driver
# sudo dnf repository-packages rpmfusion-nonfree-nvidia-driver info

## Music
sudo dnf install lpf-spotify-client
lpf  approve spotify-client
sudo -u pkg-build lpf build spotify-client 
sudo dnf install /var/lib/lpf/rpms/spotify-client/spotify-client-*.rpm

## Install Figma
# Download latest .rpm from https://github.com/Figma-Linux/figma-linux/releases
sudo dnf install figma-linux-*.x86_64.rpm

# Make things pretty
sudo dnf install papirus-icon-theme

# Install WhiteSur GTK Theme
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
cd /WhiteSur-gtk-theme
.install.sh -c dark -c light -i fedora 
sudo .tweaks.sh -g -b default -F

# Install Inter typeface
wget https://github.com/rsms/inter/releases/download/v3.15/Inter-3.18.zip -P ~/Downloads/
cd Downloads/
unzip Inter-3.18.zip -d "Inter-3.18"
sudo cp "Inter-3.18/Inter Desktop/*" /user/share/fonts/opentype/inter
rm -rf /Inter-3.18
cd ../
echo "Remember to enable Inter through the Tweak tool"
gnome-tweaks

# Cleanup
sudo dnf autoremove && sudo dnf autoclean

echo $'\n'$"*** All done! Please reboot now. ***"
