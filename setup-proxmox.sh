#!/bin/bash
# rodar esse script após a instalaćão do proxmox.

set -e

# Função para verificar se o script está rodando no Proxmox VE
function check_proxmox() {
  if ! pveversion &>/dev/null; then
    echo "❌ Este script deve ser executado em um host Proxmox VE!"
    exit 1
  fi
  echo "✅ Host Proxmox VE detectado"
}

# Baixar templates LXC Debian 12 e 13
function download_lxc_templates() {
  echo "📥 Baixando templates LXC Debian 12 e 13..."
  pveam update
  pveam download local debian-12-standard_12.0-1_amd64.tar.zst
  pveam download local debian-13-standard_13.0-1_amd64.tar.zst
  echo "✅ Templates baixados"
}

# Função para rodar script remoto via curl
function run_remote_script() {
  local url="$1"
  local name=$(basename "$url")
  echo "🔧 Executando script remoto: $name"
  curl -fsSL "$url" | bash
}

# Execução principal
function main() {
  check_proxmox
  download_lxc_templates

  run_remote_script "https://raw.githubusercontent.com/dbmello75/ProxmoxVE/main/tools/pve/post-pve-install.sh"
  run_remote_script "https://raw.githubusercontent.com/dbmello75/ProxmoxVE/main/vm/debian-13-vm.sh"

  echo "🎉 Setup completo com sucesso!"
}

main
