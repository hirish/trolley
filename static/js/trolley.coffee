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
    name: null
    ingredients: new Ingredients
    url: null

Recipes = Backbone.Collection.extend
  model: Recipe


$ ->
  window.userId = userId = 1

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
    console.log "****RENDERING****"
    console.log result
    _.template searchResultTemplate,
      name: result.get('name')
      url: result.get('url')

  searchResultHandler = (jsonResults) ->
    results = [$.parseJSON(jsonResults).results]
    recipeResults = (createRecipeFromJSON result for result in results)
    console.log recipeResults

    # Render the recipes
    renderedResults = (renderSearchResult recipeResult for recipeResult in recipeResults)

    searchResultsBox.html('')
    searchResultsBox.append renderedResult for renderedResult in renderedResults

  createRecipeFromJSON = (jsonRecipe) ->
    new Recipe
      name: "Spaghetti Bolognese"
      url: "http://upload.wikimedia.org/wikipedia/commons/e/e5/Heston_Blumenthal's_Perfect_Spaghetti_Bolognese.jpg"

  errorHandler = (reqObj) ->
    renderedTemplate = _.template errorTemplate, statusCode: 404
    errorBox.html renderedTemplate

  searchBox.keyup throttledSearch
