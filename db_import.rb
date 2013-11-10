require 'json'
require 'mysql2'

raw = {}

begin
  recipes = JSON.parse(IO.read(ARGV.first))
rescue Exception => e
  puts e.class
end

DB_USERNAME = 'trolley_admin'
DB_PASSWORD = 'SVIP_Tr0lley'
DB_HOST = 'trolley.cgrsaioc3rlt.us-east-1.rds.amazonaws.com'
DB_NAME = 'trolleydb'

# open db connection
db = Mysql2::Client.new(
  host: DB_HOST,
  username: DB_USERNAME,
  password: DB_PASSWORD, 
  database: DB_NAME
)

recipes.each do |recipe|
  serves = recipe["serves"].is_a?(Array) ? recipe["serves"].max : recipe["serves"]

  recipe_query = "INSERT INTO recipe (title, description, url, image, serves, prep_time, cook_time, rating) VALUES (\"#{db.escape(recipe['title'])}\", \"#{db.escape(recipe['description'])}\", \"#{recipe['url']}\", \"#{recipe['image']}\", #{serves}, \"#{recipe['prep_time']}\", \"#{recipe['cook_time']}\", #{recipe['rating']})"

  # run the query
  db.query(recipe_query)

  recipe_id = db.last_id

  ingredients_query = "INSERT INTO ingredient (recipe_id, name, type, quantity, price)"

  recipe["ingredients"].each do |ingredient|
    ingredients_query += "(#{recipe_id}, \'#{db.escape(ingredient['name'])}\", \"#{ingredient['type']}\", #{ingredient['quantity']}, #{ingredient['price']})"
  end

  # add ingredients
  db.query(ingredients_query.chomp(','))

end

