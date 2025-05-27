from werkzeug.security import generate_password_hash, check_password_hash
from app import mongo

class User:
    def __init__(self, name, email, password_hashed):
        self.name = name
        self.email = email
        self.password = password_hashed

    @classmethod
    def find_by_email(cls, email):
        user_data = mongo.db.users.find_one({'email': email})
        if user_data:
            user = cls(
                name=user_data['name'],
                email=user_data['email'],
                password_hashed=user_data['password']
            )
            user._id = user_data['_id']
            return user
        return None

    @classmethod
    def create(cls, name, email, password):
        if cls.find_by_email(email):
            return None  # User exists

        password_hashed = generate_password_hash(password)
        user_data = {
            'name': name,
            'email': email,
            'password': password_hashed
        }
        result = mongo.db.users.insert_one(user_data)
        user = cls(name, email, password_hashed)
        user._id = result.inserted_id
        return user

    def check_password(self, password):
        return check_password_hash(self.password, password)

    def to_dict(self):
        return {
            'id': str(self._id),
            'name': self.name,
            'email': self.email,
            # do not expose password hash!
        }
