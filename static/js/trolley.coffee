#############################################################################
### MODELS
#############################################################################

Ingredient = Backbone.Model.extend
  defaults:
    id: 0
    name: null
    quantity: 0
    type: "weight"

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
    autoRender: false

  initialize: ->
    $.ajax "/recipe/#{@.get('id')}/ingredients",
      success: (response) =>
        if @.get('autoRender')
          console.log @
        data = $.parseJSON(response).results
        ingredients = (createIngredientFromJSON ingredientJSON for ingredientJSON in data)
        @.set('ingredients', ingredients)
        @.get('ingredients')

  attributeObject: ->
    return {
      id: @.get('id')
      name: @.get('name')
      imageUrl: @.get('imageUrl')
      isStarred: @.get('isStarred')
      rating: @.get('rating')
      description: @.get('description')
      url: @.get('url')
    }

  addToShoppingList: (addToServer) ->
    if addToServer == true
      console.log "Firing at " + '/1/eatlist/' + @.get('id')
      $.ajax('/1/eatlist/' + @.get('id'))

    eatListRecipe = new EatListRecipe
      baseRecipe: @
      ingredients: @.get('ingredients')
      user: window.userId
    eatList.add(eatListRecipe)

Recipes = Backbone.Collection.extend
  model: Recipe

EatListRecipe = Backbone.Model.extend
  defaults:
    quantityModifier: 1
    baseRecipe: new Recipe
    ingredients: new Ingredients
    user: null

EatList = Backbone.Collection.extend
  model: EatListRecipe
  initialize: ->
    console.log "Called"
    @.on 'add', addedToEatListHandler

hideKeyboard = ->
  document.activeElement.blur()
  $("input").blur()

#############################################################################
### UTILITY FUNCTIONS
#############################################################################

createRecipeFromJSON = (jsonRecipe, autoRender) ->
  recipe = recipes.find (recipe) ->
    recipe.get('id') == jsonRecipe.id
  return recipe if recipe?

  if not autoRender?
    autoRender = false

  newRecipe = new Recipe
    url: jsonRecipe.url
    rating: jsonRecipe.rating
    imageUrl: jsonRecipe.imageUrl
    isStarred: jsonRecipe.isStarred
    name: jsonRecipe.name
    id: jsonRecipe.id
    description: jsonRecipe.description
    autoRender: autoRender
  recipes.add newRecipe
  return newRecipe

createIngredientFromJSON = (jsonIngredient) ->
  new Ingredient
    name: jsonIngredient.name
    type: jsonIngredient.type
    quantity: jsonIngredient.quantity

getIngredientsForRecipe = (recipe) ->
  response = $.ajax "/recipe/#{recipe.get('id')}/ingredients", async: false
  console.log response.responseText
  data = $.parseJSON(response.responseText).results
  (createIngredientFromJSON ingredientJSON for ingredientJSON in data)

initEatListFromServer = ->
  $.ajax '/1/eatlist',
    success: initEatListHandler

#############################################################################
### CLICK HANDLERS
#############################################################################

recipeClickHandler = (e, t) ->
  item = if $(@).is('.carousel') then $('.active', @) else $(@)
  flash(item)
  id = parseInt item.attr('recipe-id')
  recipe = recipes.find (recipe) ->
    recipe.get('id') == id

  if not recipe?
    console.log "Clicked on a recipe with an unloaded id (i.e. id could not be found in window.recipes)"
    return

  recipe.addToShoppingList(true)

addedToEatListHandler = (eatListRecipe) ->
  baseRecipe = eatListRecipe.get('baseRecipe')
  ingredients = baseRecipe.get('ingredients')

  eatListBox = $('#eatList')
  eatListRecipeTemplate = $('#eatListRecipeTemplate').html()
  eatListIngredientTemplate = $('#eatListIngredientTemplate').html()

  rendered = _.template eatListRecipeTemplate, {
    name: baseRecipe.get('name')
  }

  eatListBox.append rendered
  recipeElement = eatListBox.children().last()
  window.recipeBox = recipeBox = $(recipeElement).children('ul')

  for ingredient in ingredients
    rendered = _.template eatListIngredientTemplate, {
      name: ingredient.get('name')
      quantity: ingredient.get('quantity')
      price: "$5"
      unit: ingredientTypeToUnit(ingredient.get('type'))
    }
    recipeBox.append rendered

ingredientTypeToUnit = (type) ->
  if type == 'volume'
    return 'ml'
  if type == 'weight'
    return 'g'
  return ''

buyHandler = (e) ->
  $('.hideBg').show()
  $('body').addClass('preventScrolling')
  x = ->
    $('.hideBg').addClass('in')
    $('#confirmation').addClass('in')
  setTimeout(x, 10)

cancelHandler = (e) ->
  $('.hideBg').removeClass('in')
  $('#confirmation').removeClass('in')
  $('body').removeClass('preventScrolling')
  x = ->
   console.log('test')
   $('.hideBg').hide()
  setTimeout(x, 350)

submitHandler = (e) ->
  $.ajax '/email'
  $('#submitIcon').removeClass('glyphicon-cutlery')
  $('#submitIcon').addClass('glyphicon-shopping-cart')

  done = ->
    $('#submitIcon').removeClass('glyphicon-shopping-cart')
    $('#submitIcon').addClass('glyphicon-ok')

    $('#submitIcon').parent().removeClass('btn-primary')
    $('#submitIcon').parent().addClass('btn-success')

  reset = ->
    eatList = new EatList
    eatListBox = $('#eatList')
    eatListBox.html('')

    cancelHandler()

    $('#submitIcon').removeClass('glyphicon-ok')
    $('#submitIcon').addClass('glyphicon-upload')

    $('#submitIcon').parent().removeClass('btn-success')
    $('#submitIcon').parent().addClass('btn-primary')

  setTimeout(done, 500)
  setTimeout(reset, 1000)

toRender = []
initEatListHandler = (jsonEatList) ->
  console.log jsonEatList
  eatList = $.parseJSON(jsonEatList).eatlist
  eatListRecipes = (createRecipeFromJSON(result, true) for result in eatList)
  toRender = eatListRecipes


#############################################################################
### MISC LISTENERS
#############################################################################

$('#searchForm').on('change', 'input[name=servings]', ->
  selected = $.trim($(@).parent('label').text())
  $('button[data-target=#servingSelector]').text(selected)
  $('#servingSelector').collapse('hide')
)

$('.navbar-collapse').on('click', 'a[data-toggle=tab]', ->
  $(@).parents('.navbar-collapse').removeClass('in').addClass('collapse')
)

$('#searchResults').parent('.carousel').swipe(
  swipe: (event, direction, distance, duration, fingerCount) ->
    switch direction
      when 'left' then $(this).carousel('next')
      when 'right' then $(this).carousel('prev')
  tap: recipeClickHandler
)

flash = (element) ->
  element.addClass('flash')
  x = -> element.removeClass('flash')
  setTimeout(x, 200)

#############################################################################
### ON LOAD
#############################################################################

$ ->
  window.userId = userId = 1
  window.recipes = recipes = new Recipes
  window.eatList = eatList = new EatList

  searchBox = $('#search')
  searchResultsBox = $('#searchResults')
  historyRecipesBox = $('#historyResults')
  starredRecipesBox = $('#starredResults')
  errorBox = $('#error')

  errorTemplate = $('#errorTemplate').html()
  searchResultTemplate = $('#searchResultTemplate').html()
  historyRecipeTemplate = $('#historyRecipeTemplate').html()
  starredRecipeTemplate = $('#historyRecipeTemplate').html()

  # init date pickers to today
  $('input[type=date]').get(0).valueAsDate = new Date()

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
    console.log historyRecipes

    # Render recipes
    renderedHistoryRecipes = (renderRecipe historyRecipeTemplate, recipe for recipe in historyRecipes)

    historyRecipesBox.html('')
    historyRecipesBox.append renderedRecipe for renderedRecipe in renderedHistoryRecipes
    historyRecipesBox.children().click recipeClickHandler

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
    window.s = starredRecipes

    # Render recipes
    renderedStarredRecipes = (renderRecipe starredRecipeTemplate, recipe for recipe in starredRecipes)

    starredRecipesBox.html('')
    starredRecipesBox.append renderedRecipe for renderedRecipe in renderedStarredRecipes
    starredRecipesBox.children().click recipeClickHandler

  #############################################################################
  ### ERROR HANDLING
  #############################################################################

  errorHandler = (reqObj) ->
    renderedTemplate = _.template errorTemplate, statusCode: 404
    errorBox.html renderedTemplate

  searchBox.change throttledSearch
  loadHistory()
  loadStarred()
  $('#buy').click buyHandler
  $('#cancel').click cancelHandler
  $('#submit').click submitHandler
  initEatListFromServer()

  x = ->
    recipe.addToShoppingList(false) for recipe in toRender
  setTimeout(x, 3000)

