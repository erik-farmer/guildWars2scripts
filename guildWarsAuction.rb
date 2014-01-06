require 'rubygems'
require 'rest-client'
require 'json'
start = Time.now

#Returns all items
def full_item_list
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/all-items/*all*")
  itemList = JSON.parse(response)
  itemList
end

#Gets item ids based on the supplied name
def get_item_ids
  ids = []
  items = full_item_list
  items["results"].each do |item|
    ids << item["data_id"]
  end
  ids
end

#Calculates the cost of all recipe ingrediants from the highest buy order on the market
def calc_crafting_profit id
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/recipe/#{id}")
  if response.code != 200
    return
  end
  itemData = JSON.parse(response)
  
  profit = (itemData["result"]["result_item_max_offer_unit_price"] * 0.85) - itemData["result"]["crafting_cost"]
  # profit value is 6 digits for gold/silver/copper so 3000 is 30 silver pieces
  if profit > 3000
    puts "Item #{itemData["result"]["data_id"]} #{itemData["result"]["name"]} profit is: #{profit}"
  end

  rescue RestClient::ResourceNotFound
    return
  rescue RestClient::ServiceUnavailable
    return
end

#Returns the discipline ID to be used 
def get_discipline_list
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/disciplines")
  disciplines = JSON.parse(response)
  disciplines["results"]
end

#Gets total amount of pages for #get_discipline_recipes
def get_discipline_pages
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/recipes/1")
  pages = JSON.parse(response)["last_page"]
  return pages
end

#returns a list of recipes for a given discipline
def get_discipline_recipes discipline_id
  recipes = []
  last_page = get_discipline_pages
  (1..last_page).each do |page|
    response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/recipes/#{discipline_id}/#{page}")
    recipe_list = JSON.parse(response)["results"]
    recipe_list.each do |recipe|
      recipes << recipe["data_id"]
    end
  end
  recipes
end


#EXAMPLE
recipes = []
  #7 being the discipline ID for our desired discipline from #get_discpline_list
  recipes << get_discipline_recipes(7)
  recipes.flatten!

puts "All #{recipes.size} craftable recipes calculated in #{Time.now - start} seconds"

recipes.each do |recipe|
  calc_crafting_profit(recipe) #unless calc_crafting_profit(recipe) == nil
end

puts "Time elapsed #{Time.now - start} seconds"