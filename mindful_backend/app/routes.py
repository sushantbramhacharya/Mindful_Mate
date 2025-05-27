from flask import Blueprint, jsonify
from app import mongo
from app.models.user import User 

main = Blueprint('main', __name__)

@main.route('/api/users')
def get_users():
    users = list(mongo.db.users.find())  # users is your collection name
    for user in users:
        user['_id'] = str(user['_id'])  # Convert ObjectId to string
    return jsonify(users)


@main.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()

    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    confirm_password = data.get('confirm_password')

    # Basic validation
    if not all([name, email, password, confirm_password]):
        return jsonify({'error': 'Please provide name, email, password and confirm_password'}), 400

    if password != confirm_password:
        return jsonify({'error': 'Passwords do not match'}), 400

    if User.find_by_email(email):
        return jsonify({'error': 'User already exists'}), 400

    user = User.create(name, email, password)
    if user is None:
        return jsonify({'error': 'Error creating user'}), 500

    return jsonify({'message': 'User created successfully', 'user': user.to_dict()}), 201

@main.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({'error': 'Please provide email and password'}), 400

    user = User.find_by_email(email)
    if user and user.check_password(password):
        # For now, just return success. Later, you can add JWT tokens or sessions.
        return jsonify({'message': 'Login successful', 'user': user.to_dict()}), 200

    return jsonify({'error': 'Invalid email or password'}), 401