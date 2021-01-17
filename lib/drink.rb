module Drinkies
class Drink
  attr_reader :name, :ingredients, :measures, :method, :alcoholic

  @@all = []
  @@menu = []

  def initialize(drink_data)
    @name = get_name(drink_data)
    @ingredients = get_ingredients(drink_data)
    @measures = get_measures(drink_data)
    @method = get_method(drink_data)
    @alcoholic = get_alcoholic(drink_data)
    @@all << self
  end 

  def get_name(list)
    name = list["strDrink"]
  end

  def get_ingredients(list)
    ingredient_list = []
    list.each do |key, value|
      if key.include? "strIngredient"
        if value != nil
          if Ingredient.find_by_name(value) 
            ingredient = Ingredient.find_by_name(value)
            ingredient_list << ingredient.name
          else
            ingredient = Ingredient.new(value)
            ingredient_list << ingredient.name
          end
        end
      end
    end
    ingredient_list
  end

  def get_measures(list)
    measure_list = []
    list.each do |key, value|
      if value != nil
        if key.include? "strMeasure" 
          measure_list << value
        end
      end
    end
    measure_list
  end

  def get_method(list)
    list["strInstructions"]
  end

  def get_alcoholic(list)
    list["strAlcoholic"]
  end

  def save_to_menu
    @@menu << self
  end

  def self.find_by_name(name)
    drink_results = @@all.find {|drink| drink.name == name}
  end

  def self.find_by_ingredient(ingredient)
    matches = []
    @@all.each do |d|
      downcased_ingredients = d.ingredients.collect {|i| i.downcase}
      if downcased_ingredients.include?(ingredient)
        matches << d
      end
    end
    matches.collect {|dr| dr.name}  
  end 

  def self.find_by_alcoholic(filter)
    @@all.select do |drink|
      drink.alcoholic == "#{filter}"
    end
  end

  def self.all
    @@all
  end

  def self.menu
    @@menu
  end

end
end