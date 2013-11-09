#!/usr/bin/env python

from flask import Flask

application = Flask(__name__, static_folder='static', static_url_path='')
app = application

@app.route('/')
def hello_world():
    return app.send_static_file('index.html')

if __name__ == '__main__':
    app.run()
