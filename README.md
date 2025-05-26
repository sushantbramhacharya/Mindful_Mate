# 🧠 Mindful Mate - Mental Health Companion

**Mindful Mate** is an AI-powered mental wellness platform designed to provide support through an empathetic chatbot, music and game recommendations, meditation tools, mood tracking, and live chat with professionals.

---

## 💻 Tech Stack

- **Frontend:** React.js  
- **Backend:** Flask (Python)  
- **Chatbot Engine:** Artificial Neural Network (ANN)  
- **Music & Game Recommendation Models:**  
  - Support Vector Machine (SVM)  
  - Logistic Regression  
  - Naive Bayes (NB)  
- **Live Chat:** Real-time messaging with mental health professionals  
- **Database:** User moods, posts, activity logs  

---

## ✨ Features

### 🤖 AI Chatbot (ANN)
- Trained on a custom dataset of real-world and synthetic conversational patterns
- Understands user emotional states and offers thoughtful, supportive responses

### 🎵 Music Recommendation
- Suggests music based on user mood using tested ML models (SVM, Logistic Regression, Naive Bayes)

### 🎮 Game Recommendation
- Recommends relaxing, mindful, or creative games to improve emotional well-being

### 💬 Live Chat with Professionals
- Direct chat option with verified mental health professionals for deeper conversations

### 🧘‍♀️ Meditation Section
- Guided meditations, breathing exercises, and mindfulness content

### 📊 Mood Tracker
- Users can log and track their emotional state over time

### 📝 Posts & Journaling
- Write personal reflections or share thoughts with the supportive community

---

## 📁 Dataset

This project uses a **custom curated dataset** defined in `2.json`.  
The file includes:
- Multiple emotional and conversational **intents**
- Diverse **patterns** for user queries
- Supportive **responses** per intent

Example:
```json
{
  "tag": "stress",
  "patterns": ["I'm stressed", "I feel overwhelmed", "Too much work"],
  "responses": ["You're not alone. Take it one step at a time."]
}
