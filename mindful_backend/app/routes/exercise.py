from flask import Blueprint, request, jsonify, current_app, send_from_directory
from werkzeug.utils import secure_filename
from bson import ObjectId
import os
import datetime
import jwt
from app import mongo
from app.models.user import User

exercise_bp = Blueprint('exercises', __name__)

# Constants
EXERCISE_VIDEOS_DIR = 'exercise_videos'

def get_exercise_upload_dir():
    """Get the absolute path to the exercise videos upload directory"""
    upload_dir = os.path.join(current_app.root_path, 'uploads', EXERCISE_VIDEOS_DIR)
    os.makedirs(upload_dir, exist_ok=True)
    return upload_dir

@exercise_bp.route('/exercises', methods=['GET'])
def get_all_exercises():
    try:
        exercises = list(mongo.db.exercises.find())
        for exercise in exercises:
            exercise['_id'] = str(exercise['_id'])
            # Add full video URL
            if exercise.get('file_path'):
                exercise['video_url'] = f"/uploads/{EXERCISE_VIDEOS_DIR}/{exercise['file_path']}"
        return jsonify(exercises), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@exercise_bp.route('/upload-exercise', methods=['POST'])
def upload_exercise():
    try:
        if 'video' not in request.files:
            return jsonify({'error': 'No video file provided'}), 400
        
        file = request.files['video']
        if file.filename == '':
            return jsonify({'error': 'No selected video file'}), 400

        # Get form data
        exercise_name = request.form.get('exerciseName')
        category = request.form.get('category')
        duration = request.form.get('duration')
        difficulty = request.form.get('difficulty', 'Beginner')
        description = request.form.get('description', '')
        instructions = request.form.get('instructions', '')

        if not all([exercise_name, category, duration]):
            return jsonify({'error': 'Missing required fields'}), 400

        # Create exercise document
        exercise_doc = {
            'exercise_name': exercise_name,
            'category': category,
            'duration': duration,
            'difficulty': difficulty,
            'description': description,
            'instructions': instructions.split('\n') if instructions else [],
            'file_path': ''
        }
        
        # Insert into database to get ID
        result = mongo.db.exercises.insert_one(exercise_doc)
        object_id = str(result.inserted_id)

        # Save file with ObjectId as filename
        ext = os.path.splitext(file.filename)[1]
        filename = f"{object_id}{ext}"
        
        # Get exercise videos upload directory
        upload_dir = get_exercise_upload_dir()
        
        # Save file
        file_path = os.path.join(upload_dir, filename)
        file.save(file_path)
        
        # Update database with relative file path
        mongo.db.exercises.update_one(
            {'_id': ObjectId(object_id)},
            {'$set': {'file_path': filename}}
        )
        
        return jsonify({
            'message': 'Exercise uploaded successfully!',
            'exercise_id': object_id,
            'video_url': f"/uploads/{EXERCISE_VIDEOS_DIR}/{filename}"
        }), 201
        
    except Exception as e:
        if 'object_id' in locals():
            mongo.db.exercises.delete_one({'_id': ObjectId(object_id)})
        return jsonify({'error': str(e)}), 500

@exercise_bp.route('/exercises/<exercise_id>', methods=['DELETE'])
def delete_exercise(exercise_id):
    try:
        exercise = mongo.db.exercises.find_one({'_id': ObjectId(exercise_id)})
        if not exercise:
            return jsonify({'error': 'Exercise not found'}), 404

        filename = exercise.get('file_path')
        if filename:
            upload_dir = get_exercise_upload_dir()
            file_path = os.path.join(upload_dir, filename)

            if os.path.exists(file_path):
                os.remove(file_path)

        mongo.db.exercises.delete_one({'_id': ObjectId(exercise_id)})

        return jsonify({'message': 'Exercise deleted successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@exercise_bp.route('/uploads/<subdir>/<filename>')
def serve_exercise_file(subdir, filename):
    """Serve exercise files from specific subdirectories"""
    if subdir != EXERCISE_VIDEOS_DIR:
        return jsonify({'error': 'Invalid directory'}), 404
    
    upload_dir = os.path.join(current_app.root_path, 'uploads', subdir)
    return send_from_directory(upload_dir, filename)

@exercise_bp.route('/exercises/<exercise_id>', methods=['PUT'])
def update_exercise(exercise_id):
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400

        update_data = {
            'exercise_name': data.get('exerciseName'),
            'category': data.get('category'),
            'duration': data.get('duration'),
            'difficulty': data.get('difficulty'),
            'description': data.get('description'),
            'instructions': data.get('instructions')
        }

        # Remove None values
        update_data = {k: v for k, v in update_data.items() if v is not None}

        result = mongo.db.exercises.update_one(
            {'_id': ObjectId(exercise_id)},
            {'$set': update_data}
        )

        if result.modified_count == 0:
            return jsonify({'message': 'No changes made'}), 200

        return jsonify({'message': 'Exercise updated successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500