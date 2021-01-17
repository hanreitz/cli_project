module Drinkies
class Ingredient
  attr_accessor :name
  @@all = []

  def initialize(name)
    @name = name
    @@all << self
  end

  def self.find_by_name(name)
    @@all.find {|i| i.name == name}
  end

  def self.all
    @@all
  end

end
end
