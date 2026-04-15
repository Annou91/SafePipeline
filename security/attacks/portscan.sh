#!/bin/bash
# SafePipeline — Port scan simulation
# Tool: nmap
# Detection: Wazuh IDS alert
#
# Usage: bash portscan.sh [target_ip]
# Example: bash portscan.sh localhost
#
# ⚠️  Run ONLY against localhost or a controlled environment you own.

TARGET=${1:-localhost}

echo "[*] SafePipeline — Port Scan Simulation"
echo "[*] Target : $TARGET"
echo ""

if ! command -v nmap &> /dev/null; then
    echo "[!] nmap not found."
    echo "    Install: winget install nmap  (Windows)"
    echo "             apt install nmap     (Linux)"
    exit 1
fi

# --- Scan 1: Quick top-100 ports ---
echo "[>] Scan 1 — Top 100 ports (fast)"
nmap -F "$TARGET"
echo ""

# --- Scan 2: Service version detection ---
echo "[>] Scan 2 — Service versions on common ports"
nmap -sV -p 22,80,443,3000,5000,8080,9090 "$TARGET"
echo ""

# --- Scan 3: OS detection (requires root) ---
echo "[>] Scan 3 — OS detection (may need sudo)"
nmap -O "$TARGET" 2>/dev/null || echo "    Skipped — requires root/admin"
echo ""

echo "[+] Done. Check Wazuh dashboard for IDS alert (port scan detected)."
