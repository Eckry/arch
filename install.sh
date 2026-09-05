#!/bin/bash

pacman_packages="$(cat "./packages/pacman.txt" | tr '\n' ' ')"
aur_packages="$(cat "./packages/aur.txt" | tr '\n' ' ')"

echo "====== INSTALLING PACMAN PACKAGES ====="
sudo pacman -S --needed $pacman_packages

echo "====== INSTALLING AUR ====="
cd ..
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
cd arch

echo "====== INSTALLING AUR PACKAGES ====="
yay -S $aur_packages

mkdir ~/Pictures
cp ./wallpapers/wp.jpg ~/Pictures/wp.jpg
