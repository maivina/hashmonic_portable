![PowerShell](https://img.shields.io/badge/Built%20With-PowerShell-blue) ![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey) ![Status](https://img.shields.io/badge/Status-Stable-brightgreen) ![License](https://img.shields.io/badge/License-MIT-purple)

```markdown

                          _   _    _    ____  _   _ __  __  ___  _   _ ___ ____ 
                         | | | |  / \  / ___|| | | |  \/  |/ _ \| \ | |_ _/ ___|
                         | |_| | / _ \ \___ \| |_| | |\/| | | | |  \| || | |    
                         |  _  |/ ___ \ ___) |  _  | |  | | |_| | |\  || | |___ 
                         |_| |_/_/   \_\____/|_| |_|_|  |_|\___/|_| \_|___\____|
                                             [ BY MAIVINA ]

```

**A Portable, High-Performance Cybersecurity Forensics & Hashing Suite built natively in PowerShell.**

</div>

---

## 📖 Table of Contents
* [Overview](#overview)
* [See it in Action](#see-it-in-action)
* [Advanced Features](#advanced-features)
* [The Portable Architecture](#the-portable-architecture)
* [Installation and Usage](#installation-and-usage)
* [Interface Modules](#interface-modules)

---

## Overview

**Hashmonic** is a professional-grade file forensics and integrity monitoring tool. Designed for penetration testers, sysadmins, and power users, it provides deep Windows file system integration without the need for third-party `C#` compilers or heavy installations.

Whether you need to generate cryptographic intelligence briefs, monitor memory-level file modifications in real-time, or cross-reference massive directory structures byte-for-byte, Hashmonic executes with unbreakable error handling and zero ghost processes.

---

## See it in Action

https://github.com/user-attachments/assets/5e6b1f8d-8d1b-49e2-b4dc-49fcf0698c2b

> **Note:** Watch the tool dynamically swap algorithms, deep-scan directories, and output real-time surveillance events.

---

## Advanced Features

* 🔐 **Dynamic Cryptographic Engine:** Instantly swap between `MD5`, `SHA1`, `SHA256` (Default), `SHA384`, and `SHA512` algorithms on the fly.
* 🔍 **Deep Forensic Directory Scanning:** Bypasses locked files and ignores Windows junction loops (`ReparsePoints`). Accurately calculates exact byte-for-byte sizes matching Windows Explorer.
* 📊 **Cross-Reference Directory Comparison:** Compares entire directory trees to find matching hashes, security mismatches, and missing files, generating a full statistical breakdown.
* 📡 **Live Surveillance Dashboard:** A real-time memory monitor that tracks file system events without creating massive log files.
* File/Folder Creation, Deletion, and Renaming.
* Content Modifications.
* Security Attribute Changes (e.g., when a file is locked to `ReadOnly` or hidden).


* 📑 **Intelligence Reporting:** Automatically generates beautifully formatted `.txt` forensic briefs saved directly to an internal `\Reports` directory.
* 🔊 **Asynchronous Audio Engine:** Runs custom console beeps on a separate background thread, providing instant auditory feedback without freezing the UI.

---

## The Portable Architecture

Hashmonic is designed to be **100% self-healing and portable**. You can place the application folder on a USB drive, move it across different networks, or shift it between drives.

Instead of manually editing Windows shortcut targets, the included `Fix_Shortcut_Path.bat` automatically analyzes its current location, repairs the `Launch Tool.lnk` binary, forces Administrator privileges, and preserves your custom console aesthetics (transparency/colors).

---

## Installation and Usage

You can download Hashmonic using either the standard Release archive or via Git. Choose **one** of the download methods below, then proceed to the setup steps.

### Step 1: Download the Tool

**Option A: Standard Download (Recommended)**
1. Navigate to the **Releases** section on the right side of this repository.
2. Download the latest `hashmonic_portable.7z` file and extract it to your preferred location on your computer.

**Option B: For Power Users (Git)**
1. Open your terminal and clone the repository directly:
```
 git clone https://github.com/maivina/hashmonic_portable.git
```

### Step 2: Initialization (Required Setup)

Regardless of how you downloaded Hashmonic, you **must** run the setup script before using the tool for the first time.

1. **Auto-Repair Setup:** Open your Hashmonic folder and double-click `Fix_Shortcut_Path.bat`.
* **What this does:** This dynamically syncs the shortcut to your current directory, forces Administrator privileges, and safely launches the tool.
* **Important:** If you ever move the Hashmonic folder to a new location on your computer, the shortcut path will break. You must run `Fix_Shortcut_Path.bat` once in the new location to repair it.



### Step 3: Everyday Usage

1. **Standard Launch:** For all future uses, simply double-click the updated `Launch Tool.lnk` shortcut!

> **Note:** If prompted by Windows Execution Policies during setup, you may need to open PowerShell as an Administrator and run `Set-ExecutionPolicy RemoteSigned` once.

---

## Interface Modules

| Module ID | Module Name | Forensic Function |
| --- | --- | --- |
| **[ 1 ]** | **Single File Forensics** | Drag & drop an artifact to extract metadata, exact byte size, and generate a cryptographic signature. |
| **[ 2 ]** | **Comparison Engine** | Drag two files to instantly verify if their contents are cryptographically identical. |
| **[ 3 ]** | **Scan Directory** | Perform a deep integrity scan on an entire folder tree and map all hashes down to the exact byte. |
| **[ 4 ]** | **Comparison Directory** | Cross-reference two directories to detect modifications and missing source/target files. |
| **[ 5 ]** | **Text / String Hasher** | Type any string to instantly generate a cipher result and formatted character count. |
| **[ 6 ]** | **Live Surveillance Dashboard** | Watch a directory in real-time for suspicious file modifications or attribute changes. |
| **[ 7 ]** | **Open Intelligence Folder** | Instantly mount the internal `\Reports` directory in Windows Explorer. |
| **[ S ]** | **Configure Hash Engine** | Change the active hashing algorithm instantly. |

---

<div align="center">
<i>Engineered by Maivina • System Integrity Verified</i>
</div>
