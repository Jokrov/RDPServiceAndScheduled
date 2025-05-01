# 🖥️ Windows Service Manager: RDP & Network Utilities

[![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/powershell/)
[![Admin Privileges](https://img.shields.io/badge/Requires-Administrator-red.svg)](#)
[![Task Scheduler](https://img.shields.io/badge/Auto--Start-Task_Scheduler-yellowgreen.svg)](#)
[![Test Coverage](https://img.shields.io/badge/Tested-Virtual_Env-brightgreen.svg)](#)

---

## 📖 Overview

Professional toolset for automated management of critical Windows services including:

✅ **Remote Desktop Services**  
✅ **Network Configuration Utilities**  
✅ **System Recovery Automation**

**Primary Use Cases**:
- Service recovery after system updates
- RDP server configuration automation
- Enterprise network component management
- Safe configuration testing in isolated environments

---

## 🛠️ Managed Services

| Service Name                  | ID            | Critical Level | Description |
|-------------------------------|---------------|----------------|-------------|
| Remote Desktop Configuration  | `SessionEnv`  | High           | Manages RDP sessions and configuration parameters |
| Remote Desktop Services       | `TermService` | Critical       | Core component for Remote Desktop Protocol |
| RDP Port Redirector           | `UmRdpService`| Medium         | Device redirection (USB/printers) in RDP sessions |
| IP Helper                     | `iphlpsvc`    | Low*           | IPv6 support, Teredo/ISATAP tunneling, and netsh APIs |

> *⚠️ iphlpsvc is used by other system components - modify with caution*

---

## 🚀 Quick Start

### 1. Environment Setup
```powershell
# Create script directory
New-Item -Path "C:\Scripts" -ItemType Directory -Force

# Copy files
Copy-Item -Path ".\Enable-RDPServices.ps1" -Destination "C:\Scripts"
Copy-Item -Path ".\Enable-ScheduledTask.ps1" -Destination "C:\Scripts"

