from flask import Blueprint

# Create a top-level blueprint (optional if you're using multiple blueprints)
main = Blueprint('main', __name__)

# Import routes to register them — but after the blueprint is defined
from app.routes import main as main_routes
from app.routes import post as post_routes
from app.routes import mood as mood_routes