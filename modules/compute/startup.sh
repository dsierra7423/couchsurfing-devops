#!/usr/bin/env bash
set -euxo pipefail

echo ">> Installing Docker on Debian 12 (bookworm) ..."

# ------------------------------------------------------------------------------
# 1) Prerequisitos
# ------------------------------------------------------------------------------
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# ------------------------------------------------------------------------------
# 2) Clave GPG oficial de Docker
# ------------------------------------------------------------------------------
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# ------------------------------------------------------------------------------
# 3) Repositorio estable para Debian bookworm
# ------------------------------------------------------------------------------
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian bookworm stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ------------------------------------------------------------------------------
# 4) Instala Docker Engine, CLI, containerd y complementos
# ------------------------------------------------------------------------------
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
                        docker-buildx-plugin docker-compose-plugin

# ------------------------------------------------------------------------------
# 5) Activa el servicio Docker
# ------------------------------------------------------------------------------
sudo systemctl enable --now docker

# ------------------------------------------------------------------------------
# 6) Añade al usuario 'debian' al grupo docker
# ------------------------------------------------------------------------------
sudo usermod -aG docker debian || true

echo ">> Docker installation finished."
sudo docker --version

