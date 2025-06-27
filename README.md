# ✅ Export Portainer stack via powershell

## 📌 What this script do

This little powershell snipplet has the purpose to fast export all stacks in your Portainer installation fast and easily.
Unlike the native Portainer backup, it preserve the original stack name.

---

## ⚙️ Configuration steps

The script require a small setup before use:
1. Copy/Clone `PSB.ps1` and `config.json` in a folder on your PC
2. open the `config.json` file with a text editor and fullfile the fields with your real data
```
{
  "PortainerUrl": "http://localhost:9000",
  "Username": "admin",
  "BackupDir": "C:/Users/UserX/MyBkFolder"
}
```
just care about to eventually escape `\` with `\\` or use `/` instead into the `BackupDir` path
3. open a console and create a `portainer.cred` file 
```
$passwordPlain = Read-Host "Use your password here"
$securePassword = $passwordPlain | ConvertTo-SecureString -AsPlainText -Force
$securePassword | ConvertFrom-SecureString | Set-Content -Path "***ScriptPAth***\portainer.cred"
```

---
the file generated *must* be located into the same script folder

## 🔐 The backup dir

Take care: the backup directory will be created if missing, but *will be cleaned* if already exists.
If you need to retain old yaml version, pass `RetainBackupDir` as switch calling the script... so instead every time a folder with the actual timestamp will be created in your designed path.

---

## 🔥 Why i made this script?

My goal was to automatize the export of Portainer stacks, put them into a folder and push on a private repository with Github. So, i can have nor a local copy, and a offsite one for disaster case 

## 🙋‍♂️ For any problem or improvements let me know!

---

## 📘 Basic Example

### ✅ Method 1 standard usage

```
.\PSB.ps1

```

### ✅ Method 2 with all folder retention
```
.\PSB.ps1 -RetainBackupDir

```

### ✅ Method 3 using it in a .bat file
```
cd /d "****\PortainerStackBackup" && powershell -ExecutionPolicy Bypass -File .\PSB.ps1
pause
```
