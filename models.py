from config import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(256))
    eatlist = db.relationship('Eatlist',
                                backref='user',
                                foreign_keys='Eatlist.user_id')

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return '<User {} - {}>'.format(str(self.id), self.name)

class Recipe(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(120))
    description = db.Column(db.Text)
    url = db.Column(db.String(512))
    image = db.Column(db.String(512))
    serves = db.Column(db.Integer)
    prep_time = db.Column(db.String(120))
    cook_time = db.Column(db.String(120))
    ingredients = db.relationship('Ingredient',
                                    backref='recipe',
                                    foreign_keys='Ingredient.recipe_id')
    star = db.Column(db.Boolean,default=False)

    def __init__(self, title, url, image):
        self.title = title
        self.url = url
        self.image = image

    def __repr__(self):
        return '<Recipe {} - {}>'.format(str(self.id), self.title)

class Ingredient(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    recipe_id = db.Column(db.Integer, db.ForeignKey('recipe.id'))
    name = db.Column(db.String(512))
    type = db.Column(db.String(256))
    quantity = db.Column(db.Float)
    price = db.Column(db.Integer)

    def __init__(self, recipe, name):
        self.recipe = recipe
        self.name = name

    def __repr__(self):
        return '<Ingredient {} - {}>'.format(str(self.id), self.name)

class Eatlist(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id =  db.Column(db.Integer, db.ForeignKey('user.id'))
    recipe_id =  db.Column(db.Integer, db.ForeignKey('recipe.id'))
    date_last_added = db.Column(db.DateTime)
    date_last_bought = db.Column(db.DateTime)

    def __init__(self, user, recipe):
        self.user = user
        self.recipe = recipe

    def __repr__(self):
        return '<Eatlist {} - ({},{})>'.format(str(self.id), str(self.user.id), str(self.recipe.id))
