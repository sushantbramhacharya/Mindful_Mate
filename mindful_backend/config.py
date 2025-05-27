import os



class DevelopmentConfig:
    MONGO_URI = os.getenv("MONGO_URI")  # use getenv, same as os.environ.get
    DEBUG = True