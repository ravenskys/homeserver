#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo bash scripts/bootstrap-ubuntu-24.04.sh"
  exit 1
fi

echo "[1/8] Updating OS packages..."
apt update
apt -y upgrade

echo "[2/8] Installing baseline tools..."
apt install -y \
  curl \
  ca-certificates \
  gnupg \
  lsb-release \
  git \
  htop \
  vim \
  ufw \
  unzip \
  jq

echo "[3/8] Creating core directories..."
mkdir -p /srv/{media,docs,cameras,backups,appdata} /opt/compose

echo "[4/8] Setting firewall baseline..."
ufw allow OpenSSH
ufw --force enable

echo "[5/8] Installing Docker Engine + Compose plugin..."
install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
fi

cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${VERSION_CODENAME}") stable
EOF

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if id -nG "${SUDO_USER:-}" | grep -qw docker; then
  echo "User ${SUDO_USER} already in docker group."
elif [[ -n "${SUDO_USER:-}" ]]; then
  usermod -aG docker "${SUDO_USER}"
  echo "Added ${SUDO_USER} to docker group (re-login required)."
fi

echo "[6/8] Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo "[7/8] Writing quick status snapshot..."
{
  echo "=== bootstrap status ==="
  date
  echo
  echo "Docker:"
  docker --version || true
  echo
  echo "Compose:"
  docker compose version || true
  echo
  echo "UFW:"
  ufw status || true
} >/root/bootstrap-status.txt

echo "[8/8] Done."
echo
echo "Next:"
echo "  1) Re-login so docker group applies."
echo "  2) Run: sudo tailscale up"
echo "  3) Configure mirrored storage (RAID1) for the two 1TB disks."
echo "  4) Deploy stack from /opt/compose as needed."
