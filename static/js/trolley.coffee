Ingredient = Backbone.Model.extend
  defaults:
    name: null
    value: 0
    amountRequired: 0
    amountRequiredUnit: 'g'

Ingredients = Backbone.Collection.extend
  model: Ingredient

Recipe = Backbone.Model.extend
  defaults:
    ingredients: new Ingredients
    url: null

Recipes = Backbone.Collection.extend
  model: Recipe

$ ->
  console.log "Trolleys are fun"
