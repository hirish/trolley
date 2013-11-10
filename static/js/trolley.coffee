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
    url: null
    ingredients: new Ingredients
    imageUrl: null
    servingSize: 2
    isStarred: false
    rating: 0
    description: "This is a description"

  attributeObject: ->
    return {
      name: @.get('name')
      imageUrl: @.get('imageUrl')
      isStarred: @.get('isStarred')
      rating: @.get('rating')
      description: @.get('description')
      url: @.get('url')
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

$('#searchResults').parent('.carousel').swipe(
  swipe: (event, direction, distance, duration, fingerCount) ->
    switch direction
      when 'left' then $(this).carousel('next')
      when 'right' then $(this).carousel('prev')
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

  searchBox = $('#search')
  searchResultsBox = $('#searchResults')
  historyRecipesBox = $('#historyResults')
  starredRecipesBox = $('#starredResults')
  errorBox = $('#error')

  errorTemplate = $('#errorTemplate').html()
  searchResultTemplate = $('#searchResultTemplate').html()
  historyRecipeTemplate = $('#historyRecipeTemplate').html()
  starredRecipeTemplate = $('#historyRecipeTemplate').html()

  createRecipeFromJSON = (jsonRecipe) ->
    new Recipe
      url: jsonRecipe.url
      rating: jsonRecipe.rating
      imageUrl: jsonRecipe.imageUrl
      isStarred: jsonRecipe.isStarred
      name: jsonRecipe.name
      id: 1
      description: "This description should be changed"

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
    recipeResults = (createRecipeFromJSON result for result in results)

    # Render the recipes
    renderedResults = (renderRecipe searchResultTemplate, recipeResult for recipeResult in recipeResults)

    # Add rendered results to the search results
    searchResultsBox.html('')
    searchResultsBox.append renderedResult for renderedResult in renderedResults
    $('#searchResults .item:first').addClass 'active'

    # show the carousel div and rebind
    carousel = $('#searchResults').parent('.carousel')
    carousel.removeClass('hidden').carousel() if results.length > 0

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
    history = $.parseJSON(jsonHistory).results
    historyRecipes = (createRecipeFromJSON result for result in history)

    # Render recipes
    renderedHistoryRecipes = (renderRecipe historyRecipeTemplate, recipe for recipe in historyRecipes)

    historyRecipesBox.html('')
    historyRecipesBox.append renderedRecipe for renderedRecipe in renderedHistoryRecipes

  #############################################################################
  ### STARRED
  #############################################################################

  loadStarred = ->
    console.log "Loading Starred..."
    $.ajax "/#{userId}/star",
      success: starredHandler
      error: errorHandler

  starredHandler = (jsonStarred) ->
    # Parse JSON Starred into recipe objects
    starred = $.parseJSON(jsonStarred).results
    starredRecipes = (createRecipeFromJSON result for result in starred)

    # Render recipes
    renderedStarredRecipes = (renderRecipe starredRecipeTemplate, recipe for recipe in starredRecipes)

    starredRecipesBox.html('')
    starredRecipesBox.append renderedRecipe for renderedRecipe in renderedStarredRecipes

  #############################################################################
  ### ERROR HANDLING
  #############################################################################

  errorHandler = (reqObj) ->
    renderedTemplate = _.template errorTemplate, statusCode: 404
    errorBox.html renderedTemplate

  searchBox.change throttledSearch
  loadHistory()
  loadStarred()
