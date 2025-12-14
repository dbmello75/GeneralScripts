# 🔐 Proxmox Backup Client Script

A secure and modular shell script to perform local multi-folder backups to **Proxmox Backup Server (PBS)** using the `proxmox-backup-client`.

---

## 📌 Overview

This script:

* Loads configuration variables from `~/.config/pbs.conf`
* Backs up multiple user folders in a single command
* Generates friendly `.pxar` archive names
* Uses `--backup-id` in the `<user>-<hostname>` format for easy PBS identification
* Prints the full backup command before execution
* Ignores any invalid or non-existent folders automatically

---

## 🛠️ Requirements

* **Linux** (Debian recommended)
* [`proxmox-backup-client`](https://pbs.proxmox.com/docs/backup-client.html) installed:

  ```bash
  sudo apt install proxmox-backup-client
  ```
* Access to a **Proxmox Backup Server**
* Valid API key and password credentials

---

## ⚙️ Configuration

### 1. Create the config file: `~/.config/pbs.conf`

This script uses a simple environment-style config file. Create the directory and file:

```bash
mkdir -p ~/.config
nano ~/.config/pbs.conf
```

### 2. Example of `~/.config/pbs.conf`:

```ini
# PBS authentication token
PBS_APIKEY=mytoken@pbs!backup-script
PBS_PASSWORD=mysupersecret

# PBS server and datastore
PBS_HOST=192.168.1.100
PBS_DATASTORE=local

# Folders to back up (relative to $HOME, comma-separated)
LOCAL_FOLDER="Documents,Pictures,Videos"
```

> 🔒 **Security Tip:** protect this file:
>
> ```bash
> chmod 600 ~/.config/pbs.conf
> ```

---

## 🚀 Usage

1. Clone the repository or save the script as `pbs_backup.sh`.

2. Make it executable:

   ```bash
   chmod +x pbs_backup.sh
   ```

3. Run it:

   ```bash
   ./pbs_backup.sh
   ```

---

## 🔍 What the Script Does

### It generates a command like:

```bash
proxmox-backup-client backup \
  dico-Documents.pxar:/home/dico/Documents \
  dico-Pictures.pxar:/home/dico/Pictures \
  --backup-id dico-debian \
  --all-file-systems true
```

### Where:

* `dico` = username
* `debian` = hostname
* `.pxar` = archive format used by PBS

---

## 📂 Naming Convention

* Each archive is named as: `<user>-<folder>.pxar`
* The backup ID is: `<user>-<hostname>`

---

## 📋 Logging & Validation

* Shows which folders are included in the backup
* Warns about any invalid or missing folders
* Displays the full command before running

---

## 📅 Cron Automation (optional)

To schedule the script to run daily at 11 PM:

```bash
crontab -e
```

Add this line:

```bash
0 23 * * * /path/to/pbs_backup.sh >> $HOME/pbs_backup.log 2>&1
```

---

## ✅ Roadmap

* Add auto-comments via `snapshot notes update`
* Push logs to Telegram or WhatsApp using WAHA
* Native logging to `/var/log/`

---

## 📄 License

[MIT](LICENSE)

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or pull requests for improvements, suggestions, or fixes.

