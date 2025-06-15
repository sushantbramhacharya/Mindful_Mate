from flask import Blueprint, request, jsonify, current_app
from app import mongo
from app.utils.auth import token_required
from bson import ObjectId
import datetime

post = Blueprint('post', __name__)

@post.route('/api/posts', methods=['POST'])
@token_required
def create_post(current_user_id):
    data = request.get_json()
    content = data.get('content')

    if not content:
        return jsonify({'error': 'Post content is required'}), 400

    post = {
        'user_id': current_user_id,
        'content': content,
        'created_at': datetime.datetime.utcnow()
    }

    result = mongo.db.posts.insert_one(post)
    post['_id'] = str(result.inserted_id)

    return jsonify({'message': 'Post created', 'post': post}), 201

@post.route('/api/posts', methods=['GET'])
@token_required
def get_posts(current_user_id):
    posts = list(mongo.db.posts.find({'user_id': current_user_id}))
    for post in posts:
        post['_id'] = str(post['_id'])
    return jsonify(posts), 200

@post.route('/api/posts/<post_id>', methods=['DELETE'])
@token_required
def delete_post(current_user_id, post_id):
    post = mongo.db.posts.find_one({'_id': ObjectId(post_id)})

    if not post:
        return jsonify({'error': 'Post not found'}), 404

    if post['user_id'] != current_user_id:
        return jsonify({'error': 'Not authorized'}), 403

    mongo.db.posts.delete_one({'_id': ObjectId(post_id)})
    return jsonify({'message': 'Post deleted'}), 200
