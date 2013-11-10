// Generated by CoffeeScript 1.6.3
/* MODELS
*/

var EatList, EatListRecipe, Ingredient, Ingredients, Recipe, Recipes, addedToEatListHandler, buyHandler, cancelHandler, createIngredientFromJSON, createRecipeFromJSON, getIngredientsForRecipe, hideKeyboard, initEatListFromServer, initEatListHandler, recipeClickHandler, submitHandler;

Ingredient = Backbone.Model.extend({
  defaults: {
    id: 0,
    name: null,
    quantity: 0,
    type: "weight"
  }
});

Ingredients = Backbone.Collection.extend({
  model: Ingredient
});

Recipe = Backbone.Model.extend({
  defaults: {
    id: 0,
    name: null,
    url: null,
    ingredients: new Ingredients,
    imageUrl: null,
    servingSize: 2,
    isStarred: false,
    rating: 0,
    description: "This is a description"
  },
  initialize: function() {
    var _this = this;
    return $.ajax("/recipe/" + (this.get('id')) + "/ingredients", {
      success: function(response) {
        var data, ingredientJSON, ingredients;
        data = $.parseJSON(response).results;
        ingredients = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            ingredientJSON = data[_i];
            _results.push(createIngredientFromJSON(ingredientJSON));
          }
          return _results;
        })();
        _this.set('ingredients', ingredients);
        return _this.get('ingredients');
      }
    });
  },
  attributeObject: function() {
    return {
      id: this.get('id'),
      name: this.get('name'),
      imageUrl: this.get('imageUrl'),
      isStarred: this.get('isStarred'),
      rating: this.get('rating'),
      description: this.get('description'),
      url: this.get('url')
    };
  },
  addToShoppingList: function() {
    var eatListRecipe;
    eatListRecipe = new EatListRecipe({
      baseRecipe: this,
      ingredients: this.get('ingredients'),
      user: window.userId
    });
    return eatList.add(eatListRecipe);
  }
});

Recipes = Backbone.Collection.extend({
  model: Recipe
});

EatListRecipe = Backbone.Model.extend({
  defaults: {
    quantityModifier: 1,
    baseRecipe: new Recipe,
    ingredients: new Ingredients,
    user: null
  }
});

EatList = Backbone.Collection.extend({
  model: EatListRecipe,
  initialize: function() {
    console.log("Called");
    return this.on('add', addedToEatListHandler);
  }
});

hideKeyboard = function() {
  document.activeElement.blur();
  return $("input").blur();
};

$('#searchForm').on('change', 'input[name=servings]', function() {
  var selected;
  selected = $.trim($(this).parent('label').text());
  $('button[data-target=#servingSelector]').text(selected);
  return $('#servingSelector').collapse('hide');
});

$('.navbar-collapse').on('click', 'a[data-toggle=tab]', function() {
  return $(this).parents('.navbar-collapse').removeClass('in').addClass('collapse');
});

$('#searchResults').parent('.carousel').swipe({
  swipe: function(event, direction, distance, duration, fingerCount) {
    switch (direction) {
      case 'left':
        return $(this).carousel('next');
      case 'right':
        return $(this).carousel('prev');
    }
  }
});

/* UTILITY FUNCTIONS
*/


createRecipeFromJSON = function(jsonRecipe) {
  var newRecipe, recipe;
  recipe = recipes.find(function(recipe) {
    return recipe.get('id') === jsonRecipe.id;
  });
  if (recipe != null) {
    return recipe;
  }
  newRecipe = new Recipe({
    url: jsonRecipe.url,
    rating: jsonRecipe.rating,
    imageUrl: jsonRecipe.imageUrl,
    isStarred: jsonRecipe.isStarred,
    name: jsonRecipe.name,
    id: jsonRecipe.id,
    description: "This description should be changed"
  });
  recipes.add(newRecipe);
  return newRecipe;
};

createIngredientFromJSON = function(jsonIngredient) {
  return new Ingredient({
    name: jsonIngredient.name,
    type: jsonIngredient.type,
    quantity: jsonIngredient.quantity
  });
};

getIngredientsForRecipe = function(recipe) {
  var data, ingredientJSON, response, _i, _len, _results;
  response = $.ajax("/recipe/" + (recipe.get('id')) + "/ingredients", {
    async: false
  });
  console.log(response.responseText);
  data = $.parseJSON(response.responseText).results;
  _results = [];
  for (_i = 0, _len = data.length; _i < _len; _i++) {
    ingredientJSON = data[_i];
    _results.push(createIngredientFromJSON(ingredientJSON));
  }
  return _results;
};

initEatListFromServer = function() {
  return $.ajax('/1/eatlist', {
    success: initEatListHandler,
    error: errorHandler
  });
};

/* CLICK HANDLERS
*/


recipeClickHandler = function(e) {
  var id, recipe;
  id = parseInt($(this).attr('recipe-id'));
  recipe = recipes.find(function(recipe) {
    return recipe.get('id') === id;
  });
  if (recipe == null) {
    console.log("Clicked on a recipe with an unloaded id (i.e. id could not be found in window.recipes)");
    return;
  }
  return recipe.addToShoppingList();
};

addedToEatListHandler = function(eatListRecipe) {
  var baseRecipe, eatListBox, eatListIngredientTemplate, eatListRecipeTemplate, ingredient, ingredients, recipeBox, recipeElement, rendered, _i, _len, _results;
  baseRecipe = eatListRecipe.get('baseRecipe');
  ingredients = baseRecipe.get('ingredients');
  eatListBox = $('#eatList');
  eatListRecipeTemplate = $('#eatListRecipeTemplate').html();
  eatListIngredientTemplate = $('#eatListIngredientTemplate').html();
  rendered = _.template(eatListRecipeTemplate, {
    recipe: baseRecipe
  });
  eatListBox.append(rendered);
  recipeElement = eatListBox.children().last();
  window.recipeBox = recipeBox = $(recipeElement).children('ul');
  _results = [];
  for (_i = 0, _len = ingredients.length; _i < _len; _i++) {
    ingredient = ingredients[_i];
    rendered = _.template(eatListIngredientTemplate, {
      ingredient: ingredient
    });
    _results.push(recipeBox.append(rendered));
  }
  return _results;
};

buyHandler = function(e) {
  var x;
  $('.hideBg').show();
  $('body').addClass('preventScrolling');
  x = function() {
    $('.hideBg').addClass('in');
    return $('#confirmation').addClass('in');
  };
  return setTimeout(x, 10);
};

cancelHandler = function(e) {
  var x;
  $('.hideBg').removeClass('in');
  $('#confirmation').removeClass('in');
  $('body').removeClass('preventScrolling');
  x = function() {
    console.log('test');
    return $('.hideBg').hide();
  };
  return setTimeout(x, 350);
};

submitHandler = function(e) {
  var done, reset;
  $('#submitIcon').removeClass('glyphicon-cutlery');
  $('#submitIcon').addClass('glyphicon-upload');
  done = function() {
    $('#submitIcon').removeClass('glyphicon-upload');
    $('#submitIcon').addClass('glyphicon-ok');
    $('#submitIcon').parent().removeClass('btn-primary');
    return $('#submitIcon').parent().addClass('btn-success');
  };
  reset = function() {
    var eatList, eatListBox;
    eatList = new EatList;
    eatListBox = $('#eatList');
    eatListBox.html('');
    cancelHandler();
    $('#submitIcon').removeClass('glyphicon-ok');
    $('#submitIcon').addClass('glyphicon-upload');
    $('#submitIcon').parent().removeClass('btn-success');
    return $('#submitIcon').parent().addClass('btn-primary');
  };
  setTimeout(done, 500);
  return setTimeout(reset, 1000);
};

initEatListHandler = function(jsonEatList) {
  var eatList, eatListRecipes, recipe, result, _i, _len, _results;
  eatList = $.parseJSON(jsonEatList).results;
  eatListRecipes = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = eatList.length; _i < _len; _i++) {
      result = eatList[_i];
      _results.push(createRecipeFromJSON(result));
    }
    return _results;
  })();
  _results = [];
  for (_i = 0, _len = eatListRecipes.length; _i < _len; _i++) {
    recipe = eatListRecipes[_i];
    _results.push(recipe.addToShoppingList());
  }
  return _results;
};

/* ON LOAD
*/


$(function() {
  var eatList, errorBox, errorHandler, errorTemplate, historyHandler, historyRecipeTemplate, historyRecipesBox, loadHistory, loadStarred, recipes, renderRecipe, search, searchBox, searchResultHandler, searchResultTemplate, searchResultsBox, starredHandler, starredRecipeTemplate, starredRecipesBox, throttledSearch, userId;
  window.userId = userId = 1;
  window.recipes = recipes = new Recipes;
  window.eatList = eatList = new EatList;
  searchBox = $('#search');
  searchResultsBox = $('#searchResults');
  historyRecipesBox = $('#historyResults');
  starredRecipesBox = $('#starredResults');
  errorBox = $('#error');
  errorTemplate = $('#errorTemplate').html();
  searchResultTemplate = $('#searchResultTemplate').html();
  historyRecipeTemplate = $('#historyRecipeTemplate').html();
  starredRecipeTemplate = $('#historyRecipeTemplate').html();
  /* SEARCH
  */

  search = function(e) {
    var searchText;
    searchText = searchBox.val();
    return $.ajax("/" + userId + "/search?q=" + searchText, {
      success: searchResultHandler,
      error: errorHandler
    });
  };
  throttledSearch = _.throttle(search, 250);
  renderRecipe = function(template, recipe) {
    return _.template(template, recipe.attributeObject());
  };
  searchResultHandler = function(jsonResults) {
    var carousel, recipeResult, recipeResults, renderedResult, renderedResults, result, results, _i, _len;
    results = $.parseJSON(jsonResults).results;
    recipeResults = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = results.length; _i < _len; _i++) {
        result = results[_i];
        _results.push(createRecipeFromJSON(result));
      }
      return _results;
    })();
    renderedResults = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = recipeResults.length; _i < _len; _i++) {
        recipeResult = recipeResults[_i];
        _results.push(renderRecipe(searchResultTemplate, recipeResult));
      }
      return _results;
    })();
    searchResultsBox.html('');
    for (_i = 0, _len = renderedResults.length; _i < _len; _i++) {
      renderedResult = renderedResults[_i];
      searchResultsBox.append(renderedResult);
    }
    $('#searchResults .item:first').addClass('active');
    searchResultsBox.children().click(recipeClickHandler);
    carousel = $('#searchResults').parent('.carousel');
    if (results.length > 0) {
      return carousel.removeClass('hidden').carousel();
    }
  };
  /* HISTORY
  */

  loadHistory = function() {
    console.log("Loading History...");
    return $.ajax("/" + userId + "/history", {
      success: historyHandler,
      error: errorHandler
    });
  };
  historyHandler = function(jsonHistory) {
    var history, historyRecipes, recipe, renderedHistoryRecipes, renderedRecipe, result, _i, _len;
    history = $.parseJSON(jsonHistory).results;
    historyRecipes = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = history.length; _i < _len; _i++) {
        result = history[_i];
        _results.push(createRecipeFromJSON(result));
      }
      return _results;
    })();
    console.log(historyRecipes);
    renderedHistoryRecipes = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = historyRecipes.length; _i < _len; _i++) {
        recipe = historyRecipes[_i];
        _results.push(renderRecipe(historyRecipeTemplate, recipe));
      }
      return _results;
    })();
    historyRecipesBox.html('');
    for (_i = 0, _len = renderedHistoryRecipes.length; _i < _len; _i++) {
      renderedRecipe = renderedHistoryRecipes[_i];
      historyRecipesBox.append(renderedRecipe);
    }
    return historyRecipesBox.children().click(recipeClickHandler);
  };
  /* STARRED
  */

  loadStarred = function() {
    console.log("Loading Starred...");
    return $.ajax("/" + userId + "/star", {
      success: starredHandler,
      error: errorHandler
    });
  };
  starredHandler = function(jsonStarred) {
    var recipe, renderedRecipe, renderedStarredRecipes, result, starred, starredRecipes, _i, _len;
    starred = $.parseJSON(jsonStarred).results;
    starredRecipes = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = starred.length; _i < _len; _i++) {
        result = starred[_i];
        _results.push(createRecipeFromJSON(result));
      }
      return _results;
    })();
    renderedStarredRecipes = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = starredRecipes.length; _i < _len; _i++) {
        recipe = starredRecipes[_i];
        _results.push(renderRecipe(starredRecipeTemplate, recipe));
      }
      return _results;
    })();
    starredRecipesBox.html('');
    for (_i = 0, _len = renderedStarredRecipes.length; _i < _len; _i++) {
      renderedRecipe = renderedStarredRecipes[_i];
      starredRecipesBox.append(renderedRecipe);
    }
    return starredRecipesBox.children().click(recipeClickHandler);
  };
  /* ERROR HANDLING
  */

  errorHandler = function(reqObj) {
    var renderedTemplate;
    renderedTemplate = _.template(errorTemplate, {
      statusCode: 404
    });
    return errorBox.html(renderedTemplate);
  };
  searchBox.change(throttledSearch);
  loadHistory();
  loadStarred();
  $('#buy').click(buyHandler);
  $('#cancel').click(cancelHandler);
  $('#submit').click(submitHandler);
  return $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    var curr, currH, currTab;
    curr = $(e.target);
    currH = curr.attr('href');
    console.log(currH);
    currTab = $(curr.attr('href'));
    return e.preventDefault();
  });
});
