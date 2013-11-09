#!/usr/bin/env python

from flask import Flask

application = Flask(__name__, static_folder='static', static_url_path='')


@app.route('/')
def hello_world():
    return application.send_static_file('index.html')

if __name__ == '__main__':
    application.run()
