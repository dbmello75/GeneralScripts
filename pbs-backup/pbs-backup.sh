#!/bin/bash

# Load config from ~/.config/pbs.conf
ENV_FILE="$HOME/.config/pbs.conf"
if [ -f "$ENV_FILE" ]; then
    while IFS='=' read -r key value; do
        key=$(echo "$key" | xargs) # trim
        value=$(echo "$value" | sed -e 's/^ *//g' -e 's/ *$//g' -e 's/^["'\'']\(.*\)["'\'']$/\1/') # strip quotes
        [ -z "$key" ] || [[ "$key" =~ ^# ]] && continue
        export "$key=$value"
    done < "$ENV_FILE"
else
    echo "❌ Arquivo $ENV_FILE não encontrado"
    exit 1
fi

# Compose PBS_REPOSITORY
PBS_REPOSITORY="${PBS_APIKEY}@${PBS_HOST}:${PBS_DATASTORE}"

# Set identifiers
username=$(basename "$HOME")
hostname=$(hostname)

# Convert comma-separated LOCAL_FOLDER into array
IFS=',' read -ra DIRS <<< "$LOCAL_FOLDER"

# Build backup spec
SPEC=""
VALID_COUNT=0
for folder in "${DIRS[@]}"; do
    full_path="$HOME/$folder"
    if [ -d "$full_path" ]; then
        archive="${username}-${folder}.pxar"
        SPEC="$SPEC $archive:$full_path"
        VALID_COUNT=$((VALID_COUNT+1))
    else
        echo "⚠️  Diretório não encontrado: $full_path — ignorando"
    fi
done

# Validate spec content
if [ "$VALID_COUNT" -eq 0 ]; then
    echo "❌ Nenhuma pasta válida para backup encontrada. Abortando."
    exit 2
fi

# Show folders and final command
echo ""
echo "📂 Pastas incluídas no backup:"
printf '  - %s\n' "${DIRS[@]}"
echo ""

echo "💡 Comando de backup gerado:"
echo "proxmox-backup-client backup${SPEC} --backup-id \"${username}-${hostname}\" --all-file-systems true"

# Execute backup
proxmox-backup-client backup ${SPEC} --backup-id "${username}-${hostname}" --all-file-systems true

