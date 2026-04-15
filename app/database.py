import sqlite3


def init_db():
    """Create the SQLite database and insert test users."""
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()

    # Create users table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL
        )
    """)

    # Insert test users (passwords stored in plain text — intentional vulnerability)
    cursor.execute("DELETE FROM users")
    cursor.execute("INSERT INTO users (username, password) VALUES ('admin', 'admin123')")
    cursor.execute("INSERT INTO users (username, password) VALUES ('alice', 'password1')")
    cursor.execute("INSERT INTO users (username, password) VALUES ('bob', 'letmein')")

    conn.commit()
    conn.close()
    print("Database initialized.")


if __name__ == "__main__":
    init_db()
