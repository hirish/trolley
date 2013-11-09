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
  window.searchBox = searchBox = $('#search')
  search = (e) ->
    searchText = searchBox.val()
    console.log searchText
    $.ajax 'search?q=' + searchText,
      success: searchResultHandler
      error: errorHandler
  throttledSearch = _.throttle search, 250

  searchResultHandler = (results) ->
    console.log results

  errorView = $('#error')
  errorHandler = (reqObj) ->
    errorTemplate = $('#errorTemplate').html()
    renderedTemplate = _.template errorTemplate, statusCode: 404
    errorView.html renderedTemplate

  searchBox.keyup throttledSearch
