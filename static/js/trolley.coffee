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
    description: "This is a description"

  attributeObject: ->
    return {
      name: @.get('name')
      imageURL: @.get('imageURL')
      isStarred: @.get('isStarred')
      rating: @.get('rating')
      description: @.get('description')
    }

Recipes = Backbone.Collection.extend
  model: Recipe

EatListRecipe = Backbone.Model.extend
  defaults:
    quantityModifier: 1
    baseRecipe: new Recipe
    ingredients: new Ingredients
    user: null

hideKeyboard = ->
  document.activeElement.blur()
  $("input").blur()

$('#searchForm').on('change', 'input[name=servings]', ->
  selected = $.trim($(this).parent('label').text())
  $('button[data-target=#servingSelector]').text(selected)
  $('#servingSelector').collapse('hide')
)

selected = '#eat-now'
switchTab = (e) ->
  $('.navbar-collapse').collapse('hide')
  $(@).tab('show')
  $(selected).hide()

  selected = $(@).attr('href')
  $(selected).fadeIn(150)

$ ->
  $('#tab-switch li a').click switchTab

  window.userId = userId = 1
  pasta = new Ingredient
    id: 1
    name: "Spaghetti"
    amount: 150
    isVolume: false
  bologneseIngredients = new Ingredients [pasta]

  curry = new Recipe
      id: 1
      name: "Curry"
      imageURL: "http://d1jrw5jterzxwu.cloudfront.net/sites/default/files/article_media/curry.jpg"
      ingredients: bologneseIngredients
      servingSize: 2
      isStarred: false
      rating: 5
      description: "I really like curry."

  bolognese = new Recipe
      id: 1
      name: "Spaghetti Bolognese"
      imageURL: "http://upload.wikimedia.org/wikipedia/commons/e/e5/Heston_Blumenthal's_Perfect_Spaghetti_Bolognese.jpg"
      ingredients: bologneseIngredients
      servingSize: 2
      isStarred: false
      rating: 5
      description: "This is a really delicious bolognese sauce made with the finest truffles."

  myBolognese = new EatListRecipe
    baseRecipe: bolognese
    ingredients: bolognese.get('ingredients')
  anotherBolognese = new EatListRecipe
    baseRecipe: bolognese
    ingredients: bolognese.get('ingredients')
  finalBolognese = new EatListRecipe
    baseRecipe: bolognese
    ingredients: bolognese.get('ingredients')

  eatlist = [myBolognese, anotherBolognese, finalBolognese]

  searchBox = $('#search')
  searchResultsBox = $('#searchResults')
  errorBox = $('#error')

  errorTemplate = $('#errorTemplate').html()
  searchResultTemplate = $('#searchResultTemplate').html()

  createRecipeFromJSON = (jsonRecipe) ->
    # Filler
    return bolognese

  #############################################################################
  ### SEARCH
  #############################################################################

  # Push the search request to the server
  search = (e) ->
    searchText = searchBox.val()
    $.ajax "/#{userId}/search?q=#{searchText}",
      success: searchResultHandler
      error: errorHandler
  # Prevent search being called too frequently; this is a mobile app!
  throttledSearch = _.throttle search, 250

  renderRecipe = (template, recipe) ->
    _.template template, recipe.attributeObject()

  searchResultHandler = (jsonResults) ->
    console.log "Returned"
    console.log jsonResults
    # Turn JSON recipes into recipe objects
    results = $.parseJSON(jsonResults).results
    results = [results, results, results]
    recipeResults = (createRecipeFromJSON result for result in results)
    recipeResults = [bolognese, curry]

    # Render the recipes
    renderedResults = (renderRecipe searchResultTemplate, recipeResult for recipeResult in recipeResults)

    # Add rendered results to the search results
    searchResultsBox.html('')
    searchResultsBox.append renderedResult for renderedResult in renderedResults
    $('#searchResults .item:first').addClass 'active'

    $('#searchResults').parent().removeClass 'hidden'

  #############################################################################
  ### HISTORY
  #############################################################################

  loadHistory = ->
    console.log "Loading History..."
    $.ajax "/#{userId}/history",
      success: historyHandler
      error: errorHandler

  historyHandler = (jsonHistory) ->
    # Parse JSON History into recipe objects
    history = $.parseJSON jsonHistory.results
    history = [history]
    historyRecipes (createRecipeFromJSON result for result in history)

    # Render recipes
    renderedHistoryRecipes = (renderHistoryRecipe recipe for recipe in historyRecipes)

    historyRecipesBox.html('')
    historyRecipesBox.append renderedRecipe for renderedRecipe in renderedHistoryRecipes


  renderHistoryRecipe = (result) ->
    return true
    #_.tempalte

  #############################################################################
  ### ERROR HANDLING
  #############################################################################

  errorHandler = (reqObj) ->
    renderedTemplate = _.template errorTemplate, statusCode: 404
    errorBox.html renderedTemplate

  searchBox.change throttledSearch
