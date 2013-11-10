import settings

def get_recipe(recipe_id):
    recipe = fb.get('/recipe/' + str(recipe_id), None)
    recipe['id'] = recipe_id
    return recipe
