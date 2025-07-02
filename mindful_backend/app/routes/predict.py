from flask import Blueprint, request, jsonify
from app import mongo
from app.utils.auth import token_required
import joblib
import datetime

prediction = Blueprint('prediction', __name__)

# Load the pre-trained pipeline (vectorizer + SVC)
try:
    model = joblib.load('app/ml_model/svc_model.joblib')  # Your pipeline
    class_labels = ['Anxiety', 'Bipolar', 'Depression', 
                   'Normal', 'Personality disorder', 
                   'Stress', 'Suicidal']
except Exception as e:
    print(f"Error loading model: {str(e)}")
    model = None

@prediction.route('/api/predict', methods=['POST'])
@token_required
def predict_mental_health(current_user_id):
    """
    Predict mental health category from text using the SVC pipeline.
    Requires 'text' in request body.
    """
    if not model:
        return jsonify({'error': 'Model not loaded'}), 503

    data = request.get_json()
    input_text = data.get('text')

    if not input_text or not isinstance(input_text, str):
        return jsonify({'error': 'Valid text input is required'}), 400

    try:
        # Pipeline handles vectorization automatically
        response = model.predict([input_text])  # Note: [input_text] wraps it as a list
        response = response[0] if response else 'Unknown'

        # Optional: Store in MongoDB
        # mongo.db.predictions.insert_one({
        #     'user_id': current_user_id,
        #     'text': input_text[:500],  # Store first 500 chars to avoid huge documents
        #     'prediction': response,
        #     'timestamp': datetime.datetime.utcnow()
        # })

        return jsonify(response), 200

    except Exception as e:
        return jsonify({'error': f'Prediction failed: {str(e)}'}), 500