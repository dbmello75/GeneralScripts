# 🔐 Proxmox Backup Client Script

Script shell seguro e modular para realizar backups de múltiplas pastas locais no **Proxmox Backup Server (PBS)** usando o `proxmox-backup-client`.

---

## 📌 Visão Geral

Este script:

* Lê variáveis de configuração a partir de `~/.config/pbs.conf`
* Faz backup de várias pastas do usuário em uma única execução
* Gera nomes amigáveis para os arquivos `.pxar`
* Usa `--backup-id` no padrão `<usuário>-<hostname>` para facilitar organização no PBS
* Exibe o comando antes de executar
* Ignora pastas inexistentes automaticamente

---

## 🛠️ Requisitos

* **Linux (Debian preferencial)**
* [`proxmox-backup-client`](https://pbs.proxmox.com/docs/backup-client.html) instalado:

  ```bash
  sudo apt install proxmox-backup-client
  ```
* Acesso ao seu servidor **Proxmox Backup Server**
* Chave API e senha de acesso válidas

---

## ⚙️ Configuração

### 1. Criar o arquivo de configuração: `~/.config/pbs.conf`

Este script usa um arquivo de configuração simples baseado em variáveis de ambiente. Crie o diretório (caso não exista) e o arquivo:

```bash
mkdir -p ~/.config
nano ~/.config/pbs.conf
```

### 2. Exemplo completo de `~/.config/pbs.conf`:

```ini
# Token/API para autenticação no PBS
PBS_APIKEY=mytoken@pbs!backup-script
PBS_PASSWORD=mysupersecret

# Host e datastore configurado no PBS
PBS_HOST=192.168.1.100
PBS_DATASTORE=local

# Lista de pastas (relativas ao $HOME) separadas por vírgula
LOCAL_FOLDER="Documents,Pictures,Videos"
```

> 🔐 **Segurança:** proteja esse arquivo com:
>
> ```bash
> chmod 600 ~/.config/pbs.conf
> ```

---

## 🚀 Execução

1. Clone o repositório ou salve o script como `pbs_backup.sh`.

2. Dê permissão de execução:

   ```bash
   chmod +x pbs_backup.sh
   ```

3. Execute:

   ```bash
   ./pbs_backup.sh
   ```

---

## 🔍 O que o script faz

### Gera um comando de backup como este:

```bash
proxmox-backup-client backup \
  dico-Documents.pxar:/home/dico/Documents \
  dico-Pictures.pxar:/home/dico/Pictures \
  --backup-id dico-debian \
  --all-file-systems true
```

### Onde:

* `dico` = nome do usuário
* `debian` = nome do host
* `.pxar` = formato do arquivo de backup suportado pelo PBS

---

## 📂 Estrutura de Nomeação

* Os arquivos são nomeados como: `<usuário>-<pasta>.pxar`
* O ID do backup (`--backup-id`) é: `<usuário>-<hostname>`

---

## 📌 Logs e Validações

* Mostra quais pastas serão incluídas
* Emite alertas para pastas ausentes ou inválidas
* Exibe o comando final antes da execução

---

## 🗓️ Agendamento com Cron (opcional)

Para rodar automaticamente todos os dias às 23h:

```bash
crontab -e
```

Adicione:

```bash
0 23 * * * /caminho/para/pbs_backup.sh >> $HOME/pbs_backup.log 2>&1
```

---

## ✅ Roadmap Futuro

* Adicionar comentários automáticos via `snapshot notes update`
* Enviar logs para Telegram ou WhatsApp com WAHA
* Logging em `/var/log/`

---

## 📄 Licença

[MIT](LICENSE)

---

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests com melhorias, sugestões ou correções.

