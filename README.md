# 💻 PowerShell Command Center

A modular collection of custom PowerShell functions to enhance terminal productivity, system monitoring, and aesthetics.

---

## 📂 Project Structure
* **Microsoft.PowerShell_profile.ps1**: The master entry point that auto-loads all scripts.
* **Functions/**: Sub-directory containing modularized logic:
    * Visuals.ps1: Terminal aesthetics (Matrix rain, greetings).
    * Network.ps1: Port checking and connectivity tools.
    * Web.ps1: Sanitized Google and YouTube search integration.


---

## 🚀 Installation

1. **Locate your Profile:** Open PowerShell and type `$PROFILE`.
2. **Clone the Repo:** Clone these files into the directory where your profile is located (usually `Documents\WindowsPowerShell\`).
3. **Set Execution Policy:** Ensure you can run local scripts:
   `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
4. **Restart PowerShell:** Everything will auto-load on start.

---

## ✨ Key Features

### 🟢 The Matrix (matrix)
A responsive, falling-code animation with dynamic "dead zones" and color support.
* **Usage:** `matrix -colour Cyan`

### 🔍 Web Search (google, youtube)
Robust, URL-sanitized searches directly from the CLI. Prevents URL breakage and handles interactive input.
* **Usage:** `google "PowerShell modular profiles"` or `yt "lofi hip hop"`

### 🔌 Port Checker (port)
Validates port ranges (0-65535) and identifies processes currently occupying specific ports.
* **Usage:** `port 8080`

## 🛠️ Built With
* **PowerShell** - Core scripting engine.
* **.NET [uri] Class** - For robust URL encoding.
* **PascalCase Standards** - For professional command naming.

---