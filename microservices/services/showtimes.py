from microservices.services import root_dir, nice_json
from flask import Flask
from microservices.database.db_connection import create_connection # type: ignore
from flask import request
from werkzeug.exceptions import ServiceUnavailable
from werkzeug.exceptions import NotFound

app = Flask(__name__)

def get_all_showtimes():
    conn = create_connection()
    if conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT date, GROUP_CONCAT(movie_id) as movie_ids
            FROM showtimes
            GROUP BY date
        """)
        columns = [col[0] for col in cursor.description]
        showtimes = {
            row[0]: row[1].split(',')  # row[0] = date, row[1] = movie_ids
            for row in cursor.fetchall()
        }
        conn.close()
        return showtimes
    return {}

#showtimes = get_all_showtimes()

@app.route("/", methods=['GET'])
def hello():
    return nice_json({
        "uri": "/",
        "subresource_uris": {
            "showtimes": "/showtimes",
            "showtime": "/showtimes/<date>"
        }
    })

@app.route("/showtimes", methods=['GET'])
def showtimes_list():
    return nice_json(get_all_showtimes())

@app.route("/showtimes/<date>", methods=['GET'])
def showtimes_record(date):
    conn = create_connection()
    if conn:
        cursor = conn.cursor()  # Removed dictionary=True
        cursor.execute("""
            SELECT movie_id 
            FROM showtimes 
            WHERE date = %s
        """, (date,))
        
        # Get the column index for movie_id
        columns = [col[0] for col in cursor.description]
        movie_id_index = columns.index('movie_id')
        
        movies = [row[movie_id_index] for row in cursor.fetchall()]
        conn.close()
        
        if not movies:  # If no movies found for this date
            raise NotFound
            
        return nice_json(movies)
    
    raise NotFound

@app.route("/showtimes", methods=['POST'])
def add_showtime():
    data = request.get_json()
    
    # Validate required fields
    if not all(k in data for k in ('date', 'movie_id')):
        return nice_json({"error": "Missing required fields"}), 400
    
    conn = create_connection()
    if not conn:
        raise ServiceUnavailable("Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO showtimes (date, movie_id) VALUES (%s, %s)",
            (data['date'], data['movie_id'])
        )
        conn.commit()
        return nice_json({"status": "success"}), 201
    except Exception as e:
        conn.rollback()
        return nice_json({"error": str(e)}), 400
    finally:
        conn.close()

@app.route("/health")
def health():
    return "OK", 200
        
if __name__ == "__main__":
    app.run(port=5002, debug=True)