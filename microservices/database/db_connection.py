import MySQLdb
from MySQLdb import Connection, Error
from typing import Optional
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

def create_connection() -> Optional[Connection]:
    """Create a secure database connection using environment variables"""
    try:
        return MySQLdb.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME'),
            port=int(os.getenv('DB_PORT', '3306')),  # Default MySQL port
            autocommit=True,
            connect_timeout=10
        )
    except Error as e:
        print(f"❌ Database connection failed: {e}")
        return None