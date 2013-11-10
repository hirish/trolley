from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
import pymysql
import settings

application = Flask(__name__, static_folder='static', static_url_path='')
application.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://' + settings.DB_USERNAME + ':' + settings.DB_PASSWORD + '@' + settings.DB_HOST + '/' + settings.DB_NAME
db = SQLAlchemy(application)
