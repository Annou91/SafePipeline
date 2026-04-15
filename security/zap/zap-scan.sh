#!/bin/bash
# SafePipeline — OWASP ZAP headless scan against localhost:5000
# Run this script from the security/zap/ directory

TARGET="http://localhost:5000"
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p "$REPORT_DIR"

echo "[*] Starting OWASP ZAP full scan against $TARGET"
echo "[*] Report will be saved to $REPORT_DIR/zap-report-$TIMESTAMP.html"

docker run --rm \
  --network=host \
  -v "$(pwd)/reports:/zap/wrk/:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t "$TARGET" \
  -r "zap-report-$TIMESTAMP.html" \
  -J "zap-report-$TIMESTAMP.json" \
  -w "zap-report-$TIMESTAMP.md" \
  -I \
  -z "-config scanner.attackStrength=HIGH"

echo ""
echo "[+] Scan complete. Reports saved to $REPORT_DIR/"
echo "    HTML : $REPORT_DIR/zap-report-$TIMESTAMP.html"
echo "    JSON : $REPORT_DIR/zap-report-$TIMESTAMP.json"
