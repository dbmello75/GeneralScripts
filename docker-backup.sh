#!/bin/bash
# ------------------------------------------------------------------------------
# Script de Backup de Projetos em /opt com Volumes Docker
#
# Este script realiza o backup de todos os projetos localizados em /opt.
# Para cada projeto, ele executa as seguintes etapas:
#
# 1. Cria um diretório temporário para armazenar os dados antes da compactação.
# 2. Copia os arquivos do projeto localizado em /opt/<projeto> para o temp dir.
# 3. Identifica e inclui volumes Docker nomeados que começam com <projeto>_.
#    Cada volume é empacotado individualmente usando um container Alpine.
# 4. Compacta todos os dados do projeto (arquivos + volumes) em um .tar.gz.
#    O arquivo final é salvo em: /var/lib/backups/<projeto>/<projeto>_bkp__<timestamp>.tar.gz
# 5. Limpa o diretório temporário após a compactação.
# 6. Ao final, gera um resumo com:
#    - O tamanho do backup de cada projeto (ex: xibo: 62M)
#    - O total ocupado por todos os projetos juntos (ex: Total: 433M)
#
# Recursos utilizados:
# - set -euo pipefail: segurança no shell
# - docker volume ls + grep: busca por volumes relacionados ao projeto
# - docker run + tar: extrai dados dos volumes
# - du -sh: calcula tamanhos dos diretórios
# - numfmt: converte o total para formato legível (K, M, G)
#
# Requisitos:
# - Docker instalado e acessível pelo usuário que executa o script
# - Coreutils (para comandos como numfmt, du, tar, etc.)
#
# Autor: [Seu Nome Aqui]
# Data de criação: [Data]
# ------------------------------------------------------------------------------

set -euo pipefail

BACKUP_BASE="/var/lib/backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
TMP_ROOT="/tmp"

mkdir -p "$BACKUP_BASE"

echo "🚀 Iniciando backup dos projetos em /opt usando volumes nomeados..."

# Loop em cada subpasta de /opt
for PROJECT_DIR in /opt/*; do
  [ -d "$PROJECT_DIR" ] || continue  # pula se não for diretório

  PROJECT_NAME=$(basename "$PROJECT_DIR")
  TMP_DIR="$TMP_ROOT/backup-${PROJECT_NAME}-${TIMESTAMP}"

  echo
  echo "🔍 Projeto detectado: $PROJECT_NAME"
  echo "📂 Diretório do projeto: $PROJECT_DIR"
  echo "🧰 Temp dir: $TMP_DIR"

  mkdir -p "$TMP_DIR"

  # 1) Copiar todos os arquivos do projeto (/opt/<projeto> → project/)
  echo "📁 Copiando arquivos do projeto..." 
  mkdir -p "$TMP_DIR/project"
  cp -a "$PROJECT_DIR"/. "$TMP_DIR/project"

  # 2) Buscar volumes Docker que começam com <projeto>_
  echo "📦 Procurando volumes Docker com prefixo '${PROJECT_NAME}_'..."
  VOLUMES=$(docker volume ls --format '{{.Name}}' | grep "^${PROJECT_NAME}_" || true)

  if [ -n "$VOLUMES" ]; then
    mkdir -p "$TMP_DIR/volumes"
    for VOL in $VOLUMES; do
      echo "   ⤷ Incluindo volume: $VOL"
      docker run --rm \
        -v "$VOL":/data \
        -v "$TMP_DIR/volumes":/backup \
        alpine sh -c "cd /data && tar cf /backup/${VOL}.tar ."
    done
  else
    echo "   ℹ️ Nenhum volume encontrado para prefixo ${PROJECT_NAME}_ (ok se projeto não usar volumes)."
  fi

  # 3) Gerar o .tar.gz final por projeto
  DEST_DIR="$BACKUP_BASE/$PROJECT_NAME"
  mkdir -p "$DEST_DIR"
  BACKUP_FILE="${PROJECT_NAME}_bkp__${TIMESTAMP}.tar.gz"

  echo "🗜️  Compactando para: $DEST_DIR/$BACKUP_FILE"
  tar -czf "$DEST_DIR/$BACKUP_FILE" -C "$TMP_DIR" .

  # 4) Limpar temporário
  rm -rf "$TMP_DIR"

  echo "✅ Backup do projeto '$PROJECT_NAME' concluído."
done

echo
echo "🏁 Todos os backups foram concluídos. Arquivos em: $BACKUP_BASE"

echo
echo "📊 Resumo dos backups por projeto:"

TOTAL_SIZE=0

# Cria uma tabela resumida dos tamanhos por projeto
while IFS= read -r LINE; do
  SIZE=$(echo "$LINE" | awk '{print $1}')
  NAME=$(echo "$LINE" | awk -F'/' '{print $NF}')
  echo " - $NAME: $SIZE"

  # Converte tamanho para bytes para somar ao total
  NUM=$(echo "$SIZE" | grep -oE '[0-9.]+')
  UNIT=$(echo "$SIZE" | grep -oE '[KMG]')

  case $UNIT in
    K) BYTES=$(awk "BEGIN {printf \"%.0f\", $NUM * 1024}") ;;
    M) BYTES=$(awk "BEGIN {printf \"%.0f\", $NUM * 1024 * 1024}") ;;
    G) BYTES=$(awk "BEGIN {printf \"%.0f\", $NUM * 1024 * 1024 * 1024}") ;;
    *) BYTES=$NUM ;;
  esac

  TOTAL_SIZE=$((TOTAL_SIZE + BYTES))
done < <(du -sh "$BACKUP_BASE"/* 2>/dev/null)

# Converte total de bytes para formato legível
TOTAL_HUMAN=$(numfmt --to=iec --suffix=B "$TOTAL_SIZE")

echo "🔢 Total: $TOTAL_HUMAN"
