from microservices.services import root_dir, nice_json
from flask import Flask
import json
from werkzeug.exceptions import NotFound
from microservices.database.db_connection import create_connection 
from flask import request

app = Flask(__name__)

def get_all_bookings():
    conn = create_connection()
    if conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT b.user_id, b.date, GROUP_CONCAT(b.movie_id) as movie_ids
            FROM bookings b
            GROUP BY b.user_id, b.date
        """)
        columns = [col[0] for col in cursor.description]
        bookings = {}
        for row in cursor.fetchall():
            user_id = row[0]
            date = row[1]
            movie_ids = row[2].split(',')
            
            if user_id not in bookings:
                bookings[user_id] = {}
            bookings[user_id][date] = movie_ids
        conn.close()
        return bookings
    return {}

bookings = get_all_bookings()

@app.route("/bookings", methods=['POST'])
def add_booking():
    data = request.get_json()
    
    # Validate required fields
    if not all(k in data for k in ('user_id', 'date', 'movie_id')):
        return nice_json({"error": "Missing required fields"}), 400
    
    conn = create_connection()
    if not conn:
        raise ("Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO bookings (user_id, date, movie_id) VALUES (%s, %s, %s)",
            (data['user_id'], data['date'], data['movie_id'])
        )
        conn.commit()
        return nice_json({"status": "success"}), 201
    except Exception as e:
        conn.rollback()
        return nice_json({"error": str(e)}), 400
    finally:
        conn.close()

@app.route("/", methods=['GET'])
def hello():
    return nice_json({
        "uri": "/",
        "subresource_uris": {
            "bookings": "/bookings",
            "booking": "/bookings/<username>"
        }
    })


@app.route("/bookings", methods=['GET'])
def booking_list():
    return nice_json(bookings)
import json

@app.route("/bookings/<username>", methods=['GET'])
def booking_record(username):
    if username not in bookings:
        raise NotFound

    return nice_json(bookings[username])

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(port=5003, debug=True)

