#!/usr/bin/env python
from flask import Flask, request
import config
import json
from models import Recipe, Ingredient, Eatlist, db
from utils import get_recipe

application = config.application

@application.route('/')
def index():
    return application.send_static_file('index.html')

@application.route('/<user>/search')
def search(user):
    query = request.args.get('q').lower()
    results = Recipe.query
    for word in query.split():
      results = results.filter(Recipe.title.like("%%%s%%" % word))
    results = results.all()
    to_return = []
    for r in results:
      result_dict = {
          'id' : r.id,
          'name': r.title,
          'description': r.description,
          'url': r.url,
          'imageUrl': r.image,
          'serves': r.serves,
          'rating': r.rating,
          'prep_time': r.prep_time,
          'cook_time': r.cook_time
      }
      to_return.append(result_dict)
    return json.dumps({'results': to_return})

@application.route('/recipe/<recipe>', methods=['GET','POST'])
def recipe(recipe):
    if request.method == 'POST':
        #fb.post('/recipe',
        print 'POST'
    r = Recipe.query.get(recipe) 
    #recipe_dict = {
    #    'id' : r.id,
    #    'name': r.title,
    #    'description': r.description,
    #    'url': r.url,
    #    'imageUrl': r.image,
    #    'serves': r.serves,
    #    'rating': r.rating,
    #    'prep_time': r.prep_time,
    #    'cook_time': r.cook_time
    #}
    recipe_dict = r.dictify()
    return json.dumps({'recipe': recipe_dict})

@application.route('/recipe/<recipe>/ingredients', methods=['GET'])
def ingredients(recipe):
    ings = Ingredient.query.filter_by(recipe_id=recipe).all()
    to_return = []
    for i in ings:
        i_dict = {
            'id': i.id,
            'name': i.name,
            'type': i.type,
            'quantity': i.quantity
        }
        to_return.append(i_dict)
    return json.dumps({'results': to_return})
    #return '{"results":[{"name":"Spaghetti","type":"weight","quantity":5},{"name":"Tomatoes","type":"volume","quantity":300},{"name":"Beef","type":"weight","quantity":600},{"name":"Basil","type":"count","quantity":1}]}'

@application.route('/<user>/history')
def history(user):
    r1 = Recipe.query.get(4456).dictify()
    r2 = Recipe.query.get(4488).dictify()
    r3 = Recipe.query.get(3929).dictify() 
    return json.dumps({'results': [r1, r2, r3]})
    #return '{"results": [{"url": "http://www.google.com", "rating": 2, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": false, "name": "Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 5, "imageUrl": "http://i.telegraph.co.uk/multimedia/archive/00793/Spaghe-Bolog_793727c.jpg", "isStarred": false, "name": "Veggie Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 1, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": true, "name": "Simple Bolognese"}]}'

@application.route('/<user>/star', methods=['GET','POST'])
def star(user):
    starred_recipes = []
    if request.method == 'POST':
        recipe = request.args.get('recipe')
        recipe = Recipe.query.get(recipe)
        if recipe.star:
            recipe.star = False
        else:
            recipe.star = True
        db.session.add(recipe)
        db.session.commmit()
    recipes = Recipe.query.filter_by(star=True)
    to_return = []
    for r in recipes:
        #result_dict = {
        #    'id' : r.id,
        #    'name': r.title,
        #    'description': r.description,
        #    'url': r.url,
        #    'imageUrl': r.image,
        #    'serves': r.serves,
        ##    'rating': r.rating,
        #    'prep_time': r.prep_time,
        #    'cook_time': r.cook_time,
        #    'star': r.star
        #}
        result_dict = r.dictify()
        to_return.append(result_dict)
    return json.dumps({'results': to_return})
    #return '{"results": [{"url": "http://www.google.com", "rating": 0, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": false, "name": "Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 4, "imageUrl": "http://i.telegraph.co.uk/multimedia/archive/00793/Spaghe-Bolog_793727c.jpg", "isStarred": false, "name": "Veggie Spaghetti Bolognese"}, {"url": "http://www.google.com", "rating": 5, "imageUrl": "http://www.jonathanmalm.com/wp-content/uploads/2011/01/beautiful-food.jpg", "isStarred": true, "name": "Simple Bolognese"}]}'

@application.route('/<user>/eatlist')
def eatlist(user):
    eatlist = Eatlist.query.filter_by(user_id=user).all()
    to_return = []
    for e in eatlist:
         to_return.append(Recipe.query.get(e.recipe_id).dictify())
    return json.dumps({'eatlist': to_return})

@application.route('/<user>/eatlist/<recipe>')
def add_eatlist(user, recipe):
    print recipe
    e = Eatlist(user,int(recipe))
    db.session.add(e)
    db.session.commit()
    return eatlist(user)



@application.route('/<user>/buy')
def buy(user):
    return json.dumps({'buy': True})

if __name__ == '__main__':
    application.run(debug=True)
