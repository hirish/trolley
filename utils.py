from firebase import firebase
import settings
fb = firebase.FirebaseApplication(settings.FIREBASE_URL, None)

def get_recipe(recipe_id):
    recipe = fb.get('/recipe/' + str(recipe_id), None)
    return recipe
