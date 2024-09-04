import os
from flask import Flask, jsonify
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

app = Flask(__name__)

# Database setup
DATABASE_URL = os.environ.get('DATABASE_URL', 'postgresql://user:password@db:5432/mydatabase')
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)

Base.metadata.create_all(bind=engine)

@app.route('/')
def hello():
    return "Hello, World! This is a Flask app with PostgreSQL running in Docker."

@app.route('/users')
def get_users():
    db = SessionLocal()
    users = db.query(User).all()
    return jsonify([{"id": user.id, "name": user.name} for user in users])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
