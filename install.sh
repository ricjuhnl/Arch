#!/bin/bash

username=$(id -u -n 1000)
builddir=$(pwd)

# Exit on any error
set -e

# Making folders
echo "Creating folders"
mkdir -p /home/$username/.config
mkdir -p /home/$username/.local/share/fonts
sudo chown -R $username:$username /home/$username

echo "Starting package installation..."

# Update package database first
echo "Updating package database..."
sudo pacman -Sy

# Install yay AUR helper
echo "Installing yay AUR helper..."
sudo pacman -S --needed --noconfirm git base-devel
cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

# Verify yay installation
echo "Verifying yay installation..."
if command -v yay &> /dev/null; then
    echo "✓ yay installed successfully"
else
    echo "✗ yay installation failed. Exiting."
    exit 1
fi

# Check if the apps_list.txt file exists
cd $builddir
if [ ! -f "$builddir/apps_list.txt" ]; then
    echo "Error: apps_list.txt file not found!"
    exit 1
fi

# Install packages from the list
echo "Installing packages from apps_list.txt..."
for x in $(cat $builddir/apps_list.txt); do 
    echo "Installing $x..."
    yay -S --noconfirm $x
done

echo "Package installation complete!"

# Installing fonts
echo "Installing Nerd fonts"
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/CascadiaCode.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Mononoki.zip
unzip CascadiaCode.zip -d /home/$username/.local/share/fonts
unzip Mononoki.zip -d /home/$username/.local/share/fonts
sudo chown $username:$username /home/$username/.local/share/fonts/*

# Reloading Font
fc-cache -vf

# Prompt the user to reboot
read -p "Reboot now? (y/n): " REBOOT_CHOICE
if [ "$REBOOT_CHOICE" = "y" ]; then
    sudo reboot
else
    echo "You chose not to reboot. Please manually reboot your system if necessary."
fi
