from microservices.services import root_dir, nice_json
from flask import Flask
from werkzeug.exceptions import NotFound, ServiceUnavailable
from microservices.database.db_connection import create_connection
import json
from flask import request

app = Flask(__name__)

from decimal import Decimal
import json

def get_all_movies():
    conn = create_connection()
    print(">>> Connecting to DB to fetch all movies")
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM movies")
            print(">>> Query executed: SELECT * FROM movies")
            columns = [col[0] for col in cursor.description]
            movies = {}
            for row in cursor.fetchall():
                print(f">>> Row fetched: {row}")
                movie_data = dict(zip(columns, row))
                for key, value in movie_data.items():
                    if isinstance(value, Decimal):
                        movie_data[key] = float(value)
                movies[row[0]] = movie_data
            return movies
        finally:
            conn.close()
    print(">>> Connection failed")
    return {}


@app.route("/", methods=['GET'])
def hello():
    return nice_json({
        "uri": "/",
        "subresource_uris": {
            "movies": "/movies",
            "movie": "/movies/<movieid>"
        }
    })
@app.route("/movies/<movieid>", methods=['GET'])
def movie_info(movieid):
    conn = create_connection()
    if not conn:
        raise ServiceUnavailable("Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM movies WHERE movie_id = %s", (movieid,))
        row = cursor.fetchone()
        
        if not row:
            raise NotFound(f"Movie {movieid} not found")
        
        columns = [col[0] for col in cursor.description]
        movie = dict(zip(columns, row))
        
        # Convert Decimal fields to float
        for key, value in movie.items():
            if isinstance(value, Decimal):
                movie[key] = float(value)
                
        movie["uri"] = f"/movies/{movieid}"
        return nice_json(movie)
    finally:
        conn.close()

@app.route("/movies", methods=['GET'])
def movie_record():
    return nice_json(get_all_movies())


@app.route("/movies", methods=['POST'])
def add_movie():
    data = request.get_json()
    
    # Validate required fields
    if not all(k in data for k in ('movie_id', 'title', 'rating', 'director')):
        return nice_json({"error": "Missing required fields"}), 400
    
    conn = create_connection()
    if not conn:
        raise ServiceUnavailable("Database connection failed")
    
    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO movies (movie_id, title, rating, director) VALUES (%s, %s, %s, %s)",
            (data['movie_id'], data['title'], float(data['rating']), data['director'])
        )
        conn.commit()
        return nice_json({"status": "success", "uri": f"/movies/{data['movie_id']}"}), 201
    except Exception as e:
        conn.rollback()
        return nice_json({"error": str(e)}), 400
    finally:
        conn.close()

        
if __name__ == "__main__":
    app.run(port=5001, debug=True)