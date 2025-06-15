from flask import Blueprint, current_app, request, jsonify
from app import mongo
from app.utils.auth import token_required
import datetime
from bson import ObjectId # Required if you store comment user_ids as ObjectIds

mood = Blueprint('mood_bp', __name__)

@mood.route('/api/moods', methods=['POST'])
@token_required
def log_mood(current_user_id):
    """
    Logs a user's mood entry.
    Requires 'mood' and optionally 'notes' in the request body.
    """
    data = request.get_json()
    mood = data.get('mood')
    notes = data.get('notes', '') # Optional notes

    if not mood:
        return jsonify({'error': 'Mood is required'}), 400

    mood_entry = {
        'user_id': current_user_id,
        'mood': mood,
        'notes': notes,
        'created_at': datetime.datetime.utcnow() # Store creation timestamp
    }

    try:
        result = mongo.db.mood_entries.insert_one(mood_entry)
        mood_entry['_id'] = str(result.inserted_id) # Convert ObjectId to string
        return jsonify({'message': 'Mood logged successfully', 'mood_entry': mood_entry}), 201
    except Exception as e:
        current_app.logger.error(f"Error logging mood: {e}")
        return jsonify({'error': 'Failed to log mood'}), 500

@mood.route('/api/moods', methods=['GET'])
@token_required
def get_mood_history(current_user_id):
    """
    Retrieves the mood history for the authenticated user.
    Returns mood entries sorted by 'created_at' in descending order (newest first).
    """
    try:
        # Find all mood entries for the current user, sorted by created_at descending
        mood_history_cursor = mongo.db.mood_entries.find(
            {'user_id': current_user_id}
        ).sort('created_at', -1) # -1 for descending order

        mood_history_list = []
        for entry in mood_history_cursor:
            entry['_id'] = str(entry['_id']) # Convert ObjectId to string
            # Ensure 'created_at' is a string for consistent parsing on Flutter side
            if isinstance(entry.get('created_at'), datetime.datetime):
                entry['created_at'] = entry['created_at'].isoformat() + 'Z' # Convert to ISO format string with Z for UTC
            
            mood_history_list.append(entry)
            
        return jsonify(mood_history_list), 200
    except Exception as e:
        current_app.logger.error(f"Error fetching mood history: {e}")
        return jsonify({'error': 'Failed to fetch mood history'}), 500

# You might want to add other endpoints like updating or deleting a mood entry
# @mood_bp.route('/api/moods/<mood_id>', methods=['PUT'])
# @token_required
# def update_mood_entry(current_user_id, mood_id):
#     # ... (implementation for updating a specific mood entry)
#     pass

# @mood_bp.route('/api/moods/<mood_id>', methods=['DELETE'])
# @token_required
# def delete_mood_entry(current_user_id, mood_id):
#     # ... (implementation for deleting a specific mood entry)
#     pass
