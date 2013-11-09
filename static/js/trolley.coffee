Ingredient = Backbone.Model.extend
  defaults:
    id: 0
    name: null
    amount: 0
    isVolume: false

Ingredients = Backbone.Collection.extend
  model: Ingredient

Recipe = Backbone.Model.extend
  defaults:
    id: 0
    name: null
    ingredients: new Ingredients
    imageURL: null
    servingSize: 2
    isStarred: false
    rating: 0

Recipes = Backbone.Collection.extend
  model: Recipe

EatListRecipe = Backbone.Model.extend
  defaults:
    quantityModifier: 1
    baseRecipe: new Recipe
    ingredients: new Ingredients
    user: null

$ ->
  window.userId = userId = 1
  pasta = new Ingredient
    id: 1
    name: "Spaghetti"
    amount: 150
    isVolume: false
  bologneseIngredients = new Ingredients [pasta]

  bolognese = new Recipe
      id: 1
      name: "Spaghetti Bolognese"
      imageURL: "http://upload.wikimedia.org/wikipedia/commons/e/e5/Heston_Blumenthal's_Perfect_Spaghetti_Bolognese.jpg"
      ingredients: bologneseIngredients
      servingSize: 2
      isStarred: false
      rating: 5

  myBolognese = new EatListRecipe
    baseRecipe: bolognese
    ingredients: bolognese.get('ingredients')
    user: 1

  searchBox = $('#search')
  searchResultsBox = $('#searchResults')
  errorBox = $('#error')

  errorTemplate = $('#errorTemplate').html()
  searchResultTemplate = $('#searchResultTemplate').html()

  # Push the search request to the server
  search = (e) ->
    searchText = searchBox.val()
    $.ajax "/#{userId}/search?q=#{searchText}",
      success: searchResultHandler
      error: errorHandler
  # Prevent search being called too frequently; this is a mobile app!
  throttledSearch = _.throttle search, 250

  renderSearchResult = (result) ->
    _.template searchResultTemplate,
      name: result.get('name')
      imageURL: result.get('imageURL')

  searchResultHandler = (jsonResults) ->
    # Turn JSON recipes into recipe objects
    results = [$.parseJSON(jsonResults).results]
    recipeResults = (createRecipeFromJSON result for result in results)

    # Render the recipes
    renderedResults = (renderSearchResult recipeResult for recipeResult in recipeResults)

    # Add rendered results to the search results
    searchResultsBox.html('')
    searchResultsBox.append renderedResult for renderedResult in renderedResults

  createRecipeFromJSON = (jsonRecipe) ->
    # Filler
    return bolognese

  errorHandler = (reqObj) ->
    renderedTemplate = _.template errorTemplate, statusCode: 404
    errorBox.html renderedTemplate

  searchBox.keyup throttledSearch
