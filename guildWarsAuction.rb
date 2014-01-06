require 'rubygems'
require 'rest-client'
require 'json'
start = Time.now

def full_item_list
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/all-items/*all*")
  itemList = JSON.parse(response)
  itemList
end

def get_item_ids
  ids = []
  items = full_item_list
  items["results"].each do |item|
    ids << item["data_id"]
  end
  ids
end

def calc_crafting_profit id
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/recipe/#{id}")
  if response.code != 200
    return
  end
  itemData = JSON.parse(response)
  
  profit = (itemData["result"]["result_item_max_offer_unit_price"] * 0.85) - itemData["result"]["crafting_cost"]
  if profit > 3000
    puts "Item #{itemData["result"]["data_id"]} #{itemData["result"]["name"]} profit is: #{profit}"
    #return {itemData["result"]["name"] => profit}
  end

  rescue RestClient::ResourceNotFound
    return
  rescue RestClient::ServiceUnavailable
    return
end

def get_discipline_list
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/disciplines")
  disciplines = JSON.parse(response)
  disciplines["results"]
end

def get_discipline_pages
  response = RestClient.get("http://www.gw2spidy.com/api/v0.9/json/recipes/1")
  pages = JSON.parse(response)["last_page"]
  return pages
end

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

recipes = []
#profitable_recipes = []
#(1..get_discipline_list.size).each do |discipline_id|

  recipes << get_discipline_recipes(7)#(discipline_id)
  recipes.flatten!
#end

puts "All #{recipes.size} craftable recipes calculated in #{Time.now - start} seconds"

recipes.each do |recipe|
  calc_crafting_profit(recipe) #unless calc_crafting_profit(recipe) == nil
end

#puts profitable_recipes



puts "Time elapsed #{Time.now - start} seconds"