from flask import Blueprint, request, jsonify, current_app
from app import mongo
from app.utils.auth import token_required
from bson import ObjectId
import datetime

post = Blueprint('post', __name__)

@post.route('/api/posts', methods=['POST'])
@token_required
def create_post(current_user_id):
    """
    Creates a new post.
    Requires 'title', 'content', and 'category' in the request body.
    Initializes 'comments' as an empty list and 'upvotes' to 0.
    """
    data = request.get_json()
    title = data.get('title')
    content = data.get('content')
    category = data.get('category') # New: Get category from request

    # Validate required fields
    if not title:
        return jsonify({'error': 'Post title is required'}), 400
    if not content:
        return jsonify({'error': 'Post content is required'}), 400
    if not category: # New: Validate category
        return jsonify({'error': 'Post category is required'}), 400

    post_data = {
        'user_id': current_user_id,
        'title': title,           # New: Add title to post data
        'content': content,
        'category': category,     # New: Add category to post data
        'comments': [],           # New: Initialize comments as an empty list
        'upvotes': 0,             # New: Initialize upvotes to 0
        'created_at': datetime.datetime.utcnow()
    }

    result = mongo.db.posts.insert_one(post_data)
    post_data['_id'] = str(result.inserted_id)

    return jsonify({'message': 'Post created', 'post': post_data}), 201

@post.route('/api/posts', methods=['GET'])
@token_required
def get_posts(current_user_id):
    """
    Retrieves all posts belonging to the current user.
    Includes 'title', 'content', 'category', 'comments', 'upvotes', and 'created_at'.
    """
    posts_cursor = mongo.db.posts.find({'user_id': current_user_id})
    posts_list = []
    for post_doc in posts_cursor:
        # Convert ObjectId to string for JSON serialization
        post_doc['_id'] = str(post_doc['_id'])
        # Ensure comments and upvotes exist for consistency, even if not explicitly saved previously
        post_doc['comments'] = post_doc.get('comments', [])
        post_doc['upvotes'] = post_doc.get('upvotes', 0)
        posts_list.append(post_doc)
        
    return jsonify(posts_list), 200

@post.route('/api/posts/<post_id>', methods=['DELETE'])
@token_required
def delete_post(current_user_id, post_id):
    """
    Deletes a specific post by its ID.
    Only the post owner can delete it.
    """
    post_to_delete = mongo.db.posts.find_one({'_id': ObjectId(post_id)})

    if not post_to_delete:
        return jsonify({'error': 'Post not found'}), 404

    if post_to_delete['user_id'] != current_user_id:
        return jsonify({'error': 'Not authorized'}), 403

    mongo.db.posts.delete_one({'_id': ObjectId(post_id)})
    return jsonify({'message': 'Post deleted'}), 200

# --- New Endpoints for Upvoting and Comments ---

@post.route('/api/posts/<post_id>/upvote', methods=['POST'])
@token_required
def upvote_post(current_user_id, post_id):
    """
    Increments the upvote count for a specific post.
    Ensures a user can only upvote once (requires more complex logic,
    this is a simple increment for demonstration).
    """
    # Find the post and increment upvotes
    result = mongo.db.posts.update_one(
        {'_id': ObjectId(post_id)},
        {'$inc': {'upvotes': 1}}
    )

    if result.matched_count == 0:
        return jsonify({'error': 'Post not found'}), 404
    
    # You might want to fetch the updated post to return the new upvote count
    updated_post = mongo.db.posts.find_one({'_id': ObjectId(post_id)})
    if updated_post:
        updated_post['_id'] = str(updated_post['_id'])
        return jsonify({'message': 'Post upvoted', 'upvotes': updated_post.get('upvotes', 0)}), 200
    else:
        return jsonify({'error': 'Could not retrieve updated post'}), 500


@post.route('/api/posts/<post_id>/comments', methods=['POST'])
@token_required
def add_comment(current_user_id, post_id):
    """
    Adds a new comment to a specific post.
    Requires 'comment_content' in the request body.
    """
    data = request.get_json()
    comment_content = data.get('comment_content')

    if not comment_content:
        return jsonify({'error': 'Comment content is required'}), 400

    comment = {
        'user_id': current_user_id,
        'content': comment_content,
        'created_at': datetime.datetime.utcnow()
    }

    # Add the comment to the 'comments' array of the post
    result = mongo.db.posts.update_one(
        {'_id': ObjectId(post_id)},
        {'$push': {'comments': comment}}
    )

    if result.matched_count == 0:
        return jsonify({'error': 'Post not found'}), 404
    
    return jsonify({'message': 'Comment added', 'comment': comment}), 201

@post.route('/api/posts/<post_id>/comments', methods=['GET'])
@token_required
def get_comments(current_user_id, post_id):
    """
    Retrieves all comments for a specific post.
    """
    post_doc = mongo.db.posts.find_one({'_id': ObjectId(post_id)})

    if not post_doc:
        return jsonify({'error': 'Post not found'}), 404
    
    comments = post_doc.get('comments', [])
    # Convert ObjectIds within comments if necessary (e.g., if user_id was ObjectId)
    # For now, assuming user_id is already a string
    return jsonify(comments), 200

