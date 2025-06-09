from flask import Flask
from flask_cors import CORS
from flask_pymongo import PyMongo
from dotenv import load_dotenv
load_dotenv()
from config import DevelopmentConfig
import os

mongo = PyMongo()

def create_app():
    app = Flask(__name__)
    app.config.from_object(DevelopmentConfig)

    #For JWT
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')
    CORS(app, supports_credentials=True, origins=["http://localhost:5173"])
    mongo.init_app(app)

    from .routes import main
    app.register_blueprint(main)

    return app
