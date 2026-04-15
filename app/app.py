import json
import logging
import os
import sqlite3

from flask import Flask, request, session, redirect, url_for, render_template
from prometheus_flask_exporter import PrometheusMetrics
from database import init_db

app = Flask(__name__)
app.secret_key = "supersecretkey"  # Intentionally weak secret key
PrometheusMetrics(app)  # exposes /metrics endpoint for Prometheus

# -------------------------------------------------------------------
# Logging — structured JSON logs for Wazuh and Fail2Ban
# -------------------------------------------------------------------
os.makedirs("/var/log/safepipeline", exist_ok=True)

logging.basicConfig(
    filename="/var/log/safepipeline/app.log",
    level=logging.INFO,
    format="%(message)s",
)
security_logger = logging.getLogger("security")


def log_event(event, **kwargs):
    entry = {"app": "safepipeline", "event": event, "src_ip": request.remote_addr}
    entry.update(kwargs)
    security_logger.info(json.dumps(entry))


# Initialize the database on startup
init_db()


def get_db():
    """Connect to the SQLite database."""
    conn = sqlite3.connect("users.db")
    conn.row_factory = sqlite3.Row
    return conn


# -------------------------------------------------------------------
# LOGIN — Vulnerability: SQL Injection + plain text password
# -------------------------------------------------------------------
@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        conn = get_db()
        cursor = conn.cursor()

        # INTENTIONAL VULNERABILITY: SQL Injection
        # Never concatenate user input directly into a SQL query
        query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
        cursor.execute(query)
        user = cursor.fetchone()
        conn.close()

        if user:
            log_event("login_success", username=username)
            session["user"] = username
            return redirect(url_for("dashboard"))
        else:
            log_event("login_failed", username=username)
            error = "Invalid credentials"

    return render_template("login.html", error=error)


# -------------------------------------------------------------------
# DASHBOARD — Vulnerability: XSS (reflected)
# -------------------------------------------------------------------
@app.route("/dashboard")
def dashboard():
    if "user" not in session:
        return redirect(url_for("login"))

    # INTENTIONAL VULNERABILITY: XSS
    # User input reflected directly into the page without escaping
    message = request.args.get("message", "")
    if message:
        log_event("xss_attempt", payload=message)
    return render_template("dashboard.html", user=session["user"], message=message)


# -------------------------------------------------------------------
# API — Vulnerability: SQL Injection via GET parameter
# -------------------------------------------------------------------
@app.route("/api/users")
def get_user():
    user_id = request.args.get("id", "")

    # Detect obvious SQLi patterns
    sqli_patterns = ["'", '"', "--", ";", "OR", "UNION", "SELECT", "DROP"]
    if any(p.lower() in user_id.lower() for p in sqli_patterns):
        log_event("sqli_attempt", param="id", value=user_id)

    conn = get_db()
    cursor = conn.cursor()

    # INTENTIONAL VULNERABILITY: SQL Injection via API
    query = f"SELECT id, username FROM users WHERE id = {user_id}"
    cursor.execute(query)
    user = cursor.fetchone()
    conn.close()

    if user:
        return {"id": user["id"], "username": user["username"]}
    return {"error": "User not found"}, 404


# -------------------------------------------------------------------
# LOGOUT
# -------------------------------------------------------------------
@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
