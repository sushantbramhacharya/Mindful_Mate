from pprint import pp
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
    app.config['EXERCISE_VIDEOS_DIR'] = 'exercise_videos'
    app.config['ALLOWED_EXTENSIONS'] = {'mp4', 'mov', 'webm'}
    CORS(app, supports_credentials=True, origins=["http://localhost:5173"])
    mongo.init_app(app)


    #routes registreation
    from app.routes.main import main as main_routes
    from app.routes.post import post as post_routes
    app.register_blueprint(main_routes)
    app.register_blueprint(post_routes)
    from app.routes.mood import mood as mood_routes
    app.register_blueprint(mood_routes)

    from app.routes.exercise import exercise_bp
    app.register_blueprint(exercise_bp)

    from app.routes.predict import prediction
    app.register_blueprint(prediction)

    
    return app
