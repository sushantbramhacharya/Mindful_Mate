from flask import Blueprint, request, jsonify
from app import mongo
from app.models.user import User 

main = Blueprint('main', __name__)

@main.route('/api/users')
def get_users():
    users = list(mongo.db.users.find())
    for user in users:
        user['_id'] = str(user['_id'])
    return jsonify(users)

@main.route('/api/register', methods=['POST'])
def register():
    if request.is_json:
        data = request.get_json()
    else:
        data = request.form

    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    confirm_password = data.get('confirm_password')

    if not all([name, email, password, confirm_password]):
        return jsonify({'error': 'Please provide name, email, password, and confirm_password'}), 400

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
    if request.is_json:
        data = request.get_json()
    else:
        data = request.form

    email = data.get('email')
    password = data.get('password')

    if not all([email, password]):
        return jsonify({'error': 'Please provide email and password'}), 400

    user = User.find_by_email(email)
    if user and user.check_password(password):
        return jsonify({'message': 'Login successful', 'user': user.to_dict()}), 200

    return jsonify({'error': 'Invalid email or password'}), 401
