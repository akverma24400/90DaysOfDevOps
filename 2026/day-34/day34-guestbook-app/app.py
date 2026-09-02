import os
import time

import mysql.connector
import redis
from flask import Flask, redirect, render_template, request, url_for

app = Flask(__name__)


def get_database():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", "password"),
        database=os.getenv("DB_NAME", "guestbook"),
    )


def get_redis():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "localhost"),
        port=int(os.getenv("REDIS_PORT", "6379")),
        decode_responses=True,
    )


def initialize_database():
    """Wait for MySQL, then create the messages table automatically."""
    for attempt in range(10):
        try:
            database = get_database()
            cursor = database.cursor()
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS messages (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    message VARCHAR(255) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
            database.commit()
            cursor.close()
            database.close()
            return
        except mysql.connector.Error:
            if attempt == 9:
                raise
            time.sleep(3)


@app.route("/")
def home():
    # Redis stores and increments the page-view counter.
    visits = get_redis().incr("guestbook_visits")

    # MySQL stores and returns all guestbook messages.
    database = get_database()
    cursor = database.cursor(dictionary=True)
    cursor.execute(
        "SELECT name, message, created_at FROM messages ORDER BY id DESC"
    )
    messages = cursor.fetchall()
    cursor.close()
    database.close()

    return render_template("index.html", messages=messages, visits=visits)


@app.route("/add", methods=["POST"])
def add_message():
    name = request.form["name"].strip()
    message = request.form["message"].strip()

    if name and message:
        database = get_database()
        cursor = database.cursor()
        cursor.execute(
            "INSERT INTO messages (name, message) VALUES (%s, %s)",
            (name, message),
        )
        database.commit()
        cursor.close()
        database.close()

    return redirect(url_for("home"))


if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000)
