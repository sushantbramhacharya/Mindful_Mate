from flask import Blueprint, jsonify
from app import mongo

main = Blueprint('main', __name__)

@main.route('/api/users')
def get_users():
    users = list(mongo.db.users.find())  # users is your collection name
    for user in users:
        user['_id'] = str(user['_id'])  # Convert ObjectId to string
    return jsonify(users)
