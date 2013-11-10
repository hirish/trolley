from models import User, Recipe, Ingredient, Eatlist
from config import db

u = User('Barney')
db.session.add(u)
db.session.commit()

r = Recipe('Veggie bolognese','http://www.bbcgoodfood.com/recipes/9080/veggie-bolognese','http://www.bbcgoodfood.com/sites/bbcgoodfood.com/files/recipe_images/recipe-image-legacy-id--18292_11.jpg')
db.session.add(r)
db.session.commit()

i = Ingredient(r,'Spaghetti')
db.session.add(i)
db.session.commit()
i2 = Ingredient(r,'Carrots')
db.session.add(i2)
db.session.commit()

e = Eatlist(u,r)
db.session.add(e)
db.session.commit()
