#!/usr/bin/env python

from flask import Flask
from flask import request
import json
from utils import get_recipe

application = Flask(__name__, static_folder='static', static_url_path='')
app = application

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/<user>/search')
def search(user):
    query = request.args.get('q').lower()
    results = []
    if query == 'spag bol':
        results.append(get_recipe(0))
        results.append(get_recipe(1))
        results.append(get_recipe(2))
    elif query == 'fish and chips':
        results.append(get_recipe(3))
        results.append(get_recipe(4))
    return json.dumps({'results': results})

@app.route('/recipe/<recipe>', methods=['GET','POST'])
def recipe(recipe):
    if request.method == 'POST':
        #fb.post('/recipe',
        print 'POST'
    recipe = get_recipe(recipe) 
    return json.dumps(recipe)

@app.route('/recipe/<recipe>/ingredients', methods=['GET'])
def ingredients(recipe):
    # recipe = get_recipe(recipe) 
    # return json.dumps(recipe)
    return '{"results":[{"name":"Spaghetti","type":"weight","quantity":5},{"name":"Tomatoes","type":"volume","quantity":300},{"name":"Beef","type":"weight","quantity":600},{"name":"Basil","type":"count","quantity":1}]}'

@app.route('/<user>/history')
def history(user):
    limit = request.args.get('limit')
    # return json.dumps({'history': [], 'limit': limit})
    return '{"results": [{"url": "http://www.google.com", "rating": 2, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": false, "name": "Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 5, "imageUrl": "http://i.telegraph.co.uk/multimedia/archive/00793/Spaghe-Bolog_793727c.jpg", "isStarred": false, "name": "Veggie Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 1, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": true, "name": "Simple Bolognese"}]}'

@app.route('/<user>/star', methods=['GET','POST'])
def star(user):
    starred_recipes = []
    if request.method == 'POST':
        recipe = request.args.get('recipe')
        #recipe.star()
        starred_recipes.append(recipe) # get all starred recipes
    # return json.dumps({'star': starred_recipes})
    return '{"results": [{"url": "http://www.google.com", "rating": 0, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": false, "name": "Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 4, "imageUrl": "http://i.telegraph.co.uk/multimedia/archive/00793/Spaghe-Bolog_793727c.jpg", "isStarred": false, "name": "Veggie Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 5, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": true, "name": "Simple Bolognese"}]}'

@app.route('/<user>/eatlist', methods=['GET','POST'])
def eatlist(user):
    eatlist = []
    if request.method == 'POST':
        recipe = request.args.get('recipe')
        # eatlist.add(recipe)
        eatlist.append(recipe)
    return json.dumps({'eatlist': eatlist})

@app.route('/<user>/buy')
def buy(user):
    return json.dumps({'buy': True})

if __name__ == '__main__':
    app.run(debug=True)
