#!/usr/bin/env bash
# Copyright (C) 2026 Atul-Kadian
# New Ubuntu arm64 server: Docker, Nginx, Certbot, Doppler CLI, and the
# firewall opened for 80 and 443.
# Apps run in Docker, so there is no Node here. Safe to re-run.
set -euo pipefail

TIMEZONE="${TIMEZONE:-Asia/Kolkata}"

export DEBIAN_FRONTEND=noninteractive

if [ "$(uname -m)" != "aarch64" ]; then
  echo "This script is for arm64; this machine is $(uname -m)."
  exit 1
fi

echo "Updating packages ..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing base tools ..."
# iptables-persistent asks whether to save the current rules; it keeps them.
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install -y curl ca-certificates gnupg git unzip htop iptables-persistent

echo "Setting the timezone to ${TIMEZONE} ..."
sudo timedatectl set-timezone "$TIMEZONE"

echo "Opening ports 80 and 443 ..."
# Some cloud Ubuntu images reject everything but SSH in iptables, on top of
# the provider's own firewall. The rule goes above the REJECT, or it never
# matches. The provider's firewall still needs its own rules, in its console.
RULE=(-p tcp -m multiport --dports 80,443 -m state --state NEW -j ACCEPT)
if sudo iptables -C INPUT "${RULE[@]}" 2>/dev/null; then
  echo "  already open"
else
  line=$(sudo iptables -L INPUT --line-numbers | awk '/REJECT/ {print $1; exit}')
  if [ -n "$line" ]; then
    sudo iptables -I INPUT "$line" "${RULE[@]}"
  else
    sudo iptables -A INPUT "${RULE[@]}"
  fi
  sudo netfilter-persistent save
fi

echo "Installing Docker ..."
if command -v docker >/dev/null; then
  echo "  already installed"
else
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo usermod -aG docker "$USER"
# Container logs otherwise grow until the disk fills.
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{ "log-driver": "json-file", "log-opts": { "max-size": "10m", "max-file": "3" } }' |
    sudo tee /etc/docker/daemon.json >/dev/null
  sudo systemctl restart docker
fi
sudo systemctl enable --now docker

echo "Installing Nginx ..."
sudo apt-get install -y nginx
sudo systemctl enable --now nginx

echo "Installing Certbot ..."
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -sf /snap/bin/certbot /usr/bin/certbot

echo "Installing the Doppler CLI ..."
if command -v doppler >/dev/null; then
  echo "  already installed"
else
  curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' |
    sudo gpg --dearmor --yes -o /usr/share/keyrings/doppler-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" |
    sudo tee /etc/apt/sources.list.d/doppler-cli.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y doppler
fi

echo ""
echo "Done. Versions installed:"
echo "  docker:  $(docker --version)"
echo "  compose: $(docker compose version)"
echo "  nginx:   $(nginx -v 2>&1)"
echo "  certbot: $(certbot --version 2>&1)"
echo "  doppler: $(doppler --version)"
echo ""
echo "Next:"
echo "  - Log out and back in, so docker works without sudo."
echo "  - In the cloud provider's console, allow TCP 80 and 443 in its firewall too."
echo "  - Clone the repo and deploy, then point DNS here and run certbot."
