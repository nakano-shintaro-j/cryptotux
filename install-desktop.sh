#!/bin/bash -x

echo -e '\033[1m ## INSTALL DESKTOP SCRIPT ## \033[0m'
sudo apt-get update

## Install xserver, lxde desktop, and minimal 
sudo apt-get install -y --no-install-recommends \
    xserver-xorg virtualbox-guest-x11 \
    lxde lightdm lightdm-gtk-greeter\
    gtk2-engines gnome-themes-extra dmz-cursor-theme

## Remove packages that are cloud and security oriented
sudo apt-get purge -y \
  ufw \
  cloud-guest-utils \
  cloud-initramfs-copymods \
  cloud-initramfs-dyn-netconf \
  cloud-init \
  multipath-tools \
  packagekit \
  apparmor 

## Configuration Preferences 
cd
# Retrieve configuration files from this repo if not available yet
[ -d " ~/Cryptotux-repository" ] && git clone https://github.com/cryptotuxorg/cryptotux ~/Cryptotux-repository
# Use Vagrant shared folder if available for the latest version during dev or the github imported version
[ -d "/vagrant/assets" ] && cryptopath="/vagrant" ||  cryptopath="/home/$USER/Cryptotux-repository"
# Copy desktop configuration files
cp -R "${cryptopath}/assets/.config" .
cp -R "${cryptopath}/assets/.local" .
cp -R "${cryptopath}/assets/.themes" .


## Visual code & Sublime (desktop only) 
cd
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get install -y apt-transport-https
sudo apt-get update
sudo apt-get install -y code
sudo apt-get install -y sublime-text
rm packages.microsoft.gpg

# To avoid menu dupliate entries
sudo sed -i 's/Utility;//g' /usr/share/applications/code.desktop
sudo sed -i 's/Utility;//g' /usr/share/applications/emacs.desktop
sudo sed -i 's/Utility;/Development;/g' /usr/share/applications/vim.desktop
sudo rm /usr/share/applications/emacs-term.desktop
sudo rm /usr/share/applications/info.desktop

## Install Brave (desktop only)
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update
sudo apt-get install -y brave-browser 

## Development tools
sudo apt-get install -y emacs unzip libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev

## Adapt LXDE branding (Changes default, slightly dirty)
sudo cp /home/bobby/.cryptotux/images/wallpaper.jpg /etc/alternatives/desktop-background
# Used small image for compatibility - Other path to explore : lxsession-logout --banner "/usr/share/lxde/images/logout-banner.png" --side=top
sudo cp /home/bobby/.cryptotux/images/menu-light.png /usr/share/lxde/images/logout-banner.png
sudo cp /home/bobby/.cryptotux/images/menu-light.png /usr/share/lxde/images/lxde-icon.png

## Log in directly to bobby's desktop
sudo echo '[SeatDefaults]
autologin-user=bobby
autologin-user-timeout=0
user-session=LXDE
greeter-session=ligthtdm-gtk-greeter'| sudo tee /etc/lightdm/lightdm.conf


## Boot Cosmetics (optionnal)
echo 'GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_RECORDFAIL_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=0 splash "
GRUB_CMDLINE_LINUX=""' |sudo tee /etc/default/grub.d/10-local-settings.cfg
sudo rm /etc/default/grub.d/50-cloudimg-settings.cfg
sudo update-grub

sudo apt-get install -y plymouth-label
sudo mkdir  /usr/share/plymouth/themes/cryptotux-text/
echo '[Plymouth Theme]
Name=Cryptotux Text
Description=Text mode theme 
ModuleName=ubuntu-text

[ubuntu-text]
title=Cryptotux       
black=0x0078C2
white=0xffffff
brown=0x009DFD
blue=0x00182C' | sudo tee /usr/share/plymouth/themes/cryptotux-text/cryptotux-text.plymouth

sudo ln -sf /usr/share/plymouth/themes/cryptotux-text/cryptotux-text.plymouth /etc/alternatives/text.plymouth
sudo ln -sf /usr/share/plymouth/themes/cryptotux-text/cryptotux-text.plymouth /etc/alternatives/default.plymouth

sudo update-initramfs -u


# Fix for some console apps that launch xterm
sudo ln -s /usr/bin/lxterminal /usr/bin/xterm

sudo apt-get autoremove -y

## Reboot
echo -e '\033[1m ## END OF INSTALL DESKTOP SCRIPT - REBOOTING  ## \033[0m'
sudo reboot # Not ideal when using vagrant