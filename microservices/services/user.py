import requests
from microservices.services import root_dir, nice_json
from flask import Flask, request
from werkzeug.exceptions import NotFound, ServiceUnavailable
from microservices.database.db_connection import create_connection # type: ignore

app = Flask(__name__)

# Enhanced logging configuration
import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_all_users():
    try:
        logger.info("Attempting database connection...")
        conn = create_connection()
        if not conn:
            logger.error("Database connection failed!")
            return {}
            
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        logger.info(f"Retrieved {len(users)} rows from database")
        
        if not users:
            logger.warning("No users found in database")
            return {}
            
        columns = [col[0] for col in cursor.description]
        result = {
            row[0]: dict(zip(columns, row))
            for row in users
        }
        
        conn.close()
        return result
        
    except Exception as e:
        logger.error(f"Database error: {str(e)}")
        return {}


@app.route("/user", methods=['GET'])
@app.route("/user/", methods=['GET'])
@app.route("/users", methods=['GET'])
@app.route("/users/", methods=['GET'])
def users_list():
    logger.info("Users list endpoint accessed")
    users = get_all_users()
    
    if not users:
        logger.info("No users found, returning empty list")
        return nice_json([])
    
    logger.info(f"Returning {len(users)} users")
    return nice_json(users)

@app.route("/users/<username>", methods=['GET'])
def user_record(username):
    logger.info(f"Accessing user record for: {username}")
    conn = create_connection()
    if not conn:
        raise ServiceUnavailable("Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (username,))
        row = cursor.fetchone()
        
        if not row:
            logger.warning(f"User not found: {username}")
            raise NotFound(f"User {username} not found")
            
        columns = [col[0] for col in cursor.description]
        user = dict(zip(columns, row))
        logger.info(f"Found user: {user}")
        return nice_json(user)
        
    except Exception as e:
        logger.error(f"Error fetching user: {str(e)}")
        raise ServiceUnavailable("Database error occurred")
    finally:
        conn.close()

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

@app.route("/health")
def health():
    return "OK", 200


@app.route("/", methods=['GET'])
def hello():
    logger.info("Root endpoint accessed")
    return nice_json({
        "message": "Movie Booking API",
        "endpoints": {
            "users": "/users",
            "user_details": "/users/<user_id>",
            "user_bookings": "/users/<user_id>/bookings"
        }
    })
        
@app.before_request
def log_request_info():
    logger.info(f"Incoming request: {request.method} {request.path}")

@app.after_request
def log_response(response):
    logger.info(f"Outgoing response: {response.status}")
    return response

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
