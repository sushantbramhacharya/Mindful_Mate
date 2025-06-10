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

import jwt
import datetime
from flask import current_app

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
        # Create JWT token

        token = jwt.encode({
            'user_id': user.to_dict()['id'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }, current_app.config['SECRET_KEY'], algorithm='HS256')

        return jsonify({
            'message': 'Login successful',
            'token': token,
            'user': user.to_dict()
        }), 200

    return jsonify({'error': 'Invalid email or password'}), 401

from werkzeug.utils import secure_filename
import os


@main.route('/upload-music', methods=['POST'])
def upload_music():
    file = request.files.get('file')
    music_name = request.form.get('musicName')
    author = request.form.get('author')
    category = request.form.get('category')

    if not all([file, music_name, author, category]):
        return jsonify({'error': 'Missing required fields'}), 400

    # Insert doc first to get ObjectId
    music_doc = {
        'music_name': music_name,
        'author': author,
        'category': category,
        'file_path': ''  # temp placeholder
    }
    result = mongo.db.music.insert_one(music_doc)
    object_id = str(result.inserted_id)

    # Save file with ObjectId as filename + extension
    ext = os.path.splitext(file.filename)[1]
    filename = f"{object_id}{ext}"

    upload_dir = os.path.join(current_app.root_path, 'uploads')
    os.makedirs(upload_dir, exist_ok=True)

    file_path = os.path.join(upload_dir, filename)
    file.save(file_path)

    # Update DB with only the filename (relative path)
    mongo.db.music.update_one(
        {'_id': ObjectId(object_id)},
        {'$set': {'file_path': filename}}
    )

    return jsonify({'message': 'Music uploaded successfully!'}), 201
from bson import ObjectId

@main.route('/music', methods=['GET'])
def get_all_music():
    music_list = list(mongo.db.music.find())
    for music in music_list:
        music['_id'] = str(music['_id'])
    return jsonify(music_list), 200

import os

@main.route('/music/<music_id>', methods=['DELETE'])
def delete_music(music_id):
    try:
        music = mongo.db.music.find_one({'_id': ObjectId(music_id)})
        if not music:
            return jsonify({'error': 'Music not found'}), 404

        filename = music.get('file_path')
        if filename:
            upload_dir = os.path.join(current_app.root_path, 'uploads')
            file_path = os.path.join(upload_dir, filename)

            if os.path.exists(file_path):
                os.remove(file_path)

        mongo.db.music.delete_one({'_id': ObjectId(music_id)})

        return jsonify({'message': 'Music deleted successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

from flask import send_from_directory

@main.route('/uploads/<filename>')
def serve_file(filename):
    upload_dir = os.path.join(current_app.root_path, 'uploads')
    return send_from_directory(upload_dir, filename)

from flask import request, jsonify
from bson import ObjectId

@main.route('/music/<music_id>', methods=['PUT'])
def edit_music(music_id):
    try:
        # Check if music exists
        music = mongo.db.music.find_one({'_id': ObjectId(music_id)})
        if not music:
            return jsonify({'error': 'Music not found'}), 404

        # Get data from JSON or form
        if request.is_json:
            data = request.get_json()
        else:
            data = request.form

        # Extract fields to update
        music_name = data.get('musicName')
        author = data.get('author')
        category = data.get('category')

        update_data = {}
        if music_name:
            update_data['music_name'] = music_name
        if author:
            update_data['author'] = author
        if category:
            update_data['category'] = category

        if not update_data:
            return jsonify({'error': 'No fields to update provided'}), 400

        # Update the document
        mongo.db.music.update_one(
            {'_id': ObjectId(music_id)},
            {'$set': update_data}
        )

        # Return updated document
        updated_music = mongo.db.music.find_one({'_id': ObjectId(music_id)})
        updated_music['_id'] = str(updated_music['_id'])

        return jsonify({'message': 'Music updated successfully', 'music': updated_music}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
