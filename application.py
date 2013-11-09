#!/usr/bin/env python

from flask import Flask

application = Flask(__name__, static_folder='static', static_url_path='')
app = application

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/<user>/search')
def search(user):
    query = request.args.get('q')
    return {'results': query}

@app.route('/<user>/history')
def history(user):
    limit = request.args.get('limit')
    return {'history': [], 'limit': limit}

@app.route('/<user>/star', methods=['GET','POST'])
def star(user):
    starred_recipes = []
    if request.method == 'POST':
        recipe = request.args.get('recipe')
        #recipe.star()
        starred_recipes.append(recipe) # get all starred recipes
    return {'star': starred_recipes}

@app.route('/<user>/eatlist', methods=['GET','POST'])
def eatlist(user):
    eatlist = []
    if request.method = 'POST':
        recipe = request.args.get('recipe')
        # eatlist.add(recipe)
        eatlist.append(recipe)
    return {'eatlist': eatlist}

@app.route('/<user>/buy')
def buy(user):
    return {'buy': True}

if __name__ == '__main__':
    app.run()
