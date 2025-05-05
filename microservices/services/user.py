import requests
from microservices.services import root_dir, nice_json
from flask import Flask, request
from werkzeug.exceptions import NotFound, ServiceUnavailable
from microservices.database.db_connection import create_connection # type: ignore

app = Flask(__name__)

def get_all_users():
    conn = create_connection()
    if conn:
        cursor = conn.cursor()  # Remove dictionary=True
        cursor.execute("SELECT * FROM users")
        
        # Manually create dictionary from results
        columns = [col[0] for col in cursor.description]
        users = {
            row[0]: dict(zip(columns, row))  # First column is user_id
            for row in cursor.fetchall()
        }
        
        conn.close()
        return users
    return {}

#users = get_all_users()

@app.route("/", methods=['GET'])
def hello():
    return nice_json({
        "uri": "/",
        "subresource_uris": {
            "users": "/users",
            "user": "/users/<username>",
            "bookings": "/users/<username>/bookings",
            "suggested": "/users/<username>/suggested"
        }
    })

@app.route("/users", methods=['GET'])
def users_list():
    return nice_json(get_all_users())  

@app.route("/users/<username>", methods=['GET'])
def user_record(username):
    conn = create_connection()
    if conn:
        cursor = conn.cursor()  # Removed dictionary=True
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (username,))
        
        # Manually create dictionary
        columns = [col[0] for col in cursor.description]
        row = cursor.fetchone()
        conn.close()
        
        if not row:
            raise NotFound
        
        user = dict(zip(columns, row))
        return nice_json(user)
    
    raise NotFound

@app.route("/users/<username>/bookings", methods=['GET'])
def user_bookings(username):
    all_users = get_all_users()
    if username not in all_users:
        raise NotFound("User '{}' not found.".format(username))

    try:
        users_bookings = requests.get(f"http://127.0.0.1:5003/bookings/{username}")
    except requests.exceptions.ConnectionError:
        raise ServiceUnavailable("The Bookings service is unavailable.")

    if users_bookings.status_code == 404:
        raise NotFound("No bookings were found for {}".format(username))

    users_bookings = users_bookings.json()

    result = {}
    for date, movie_ids in users_bookings.items():
        result[date] = []
        for movie_id in movie_ids:
            try:
                movies_resp = requests.get(f"http://127.0.0.1:5001/movies/{movie_id}")
            except requests.exceptions.ConnectionError:
                raise ServiceUnavailable("The Movie service is unavailable.")
            movies_resp = movies_resp.json()
            result[date].append({
                "title": movies_resp["title"],
                "rating": movies_resp["rating"],
                "uri": movies_resp["uri"]
            })

    return nice_json(result)

@app.route("/users/<username>/suggested", methods=['GET'])
def user_suggested(username):
    raise NotImplementedError()

@app.route("/users", methods=['POST'])
def add_user():
    data = request.get_json()
    
    # Validate required fields
    if not all(k in data for k in ('user_id', 'name', 'last_active')):
        return nice_json({"error": "Missing required fields"}), 400
    
    conn = create_connection()
    if not conn:
        raise ServiceUnavailable("Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO users (user_id, name, last_active) VALUES (%s, %s, %s)",
            (data['user_id'], data['name'], data['last_active'])
        )
        conn.commit()
        return nice_json({"status": "success", "uri": f"/users/{data['user_id']}"}), 201
    except Exception as e:
        conn.rollback()
        return nice_json({"error": str(e)}), 400
    finally:
        conn.close()
        
if __name__ == "__main__":
    app.run(port=5000, debug=True)