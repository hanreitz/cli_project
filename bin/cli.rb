require_relative '../config/environment'
class CLI
    def initialize
        input = ""
        @saved_drinks = []
        puts "***"
        puts ""
        puts "Welcome to Drinkies! Let's dream up a drink menu!"
        menu
    end

    def menu
        prompt
        input = gets.strip.downcase
        while input != "exit"
            case input
            when "1"
                alcoholic_prompt
                alc_input = gets.strip
                if alc_input == "1"
                    ingredients
                    ingredient_select_prompt
                    ing_input = gets.strip
                    if ing_input.to_i > 0 && ing_input.to_i <= ingredients.length
                        results = ingredient_search(ingredients[ing_input.to_i - 1])
                        see_and_save(results)
                    else
                        puts "That number isn't on the list."
                        return_to_main
                    end
                elsif alc_input == "2"
                    see_and_save(random_alc_drx)
                    menu
                end
            when "2"
                non_alc_prompt
                non_alc_input = gets.strip
                if non_alc_input == "1"
                    puts "Type an ingredient to search: "
                    ing_input = gets.strip.capitalize
                    ing_results = ingredient_search(ing_input)
                    non_alc_drx = get_drx("Non_Alcoholic")
                    non_alc_results = []
                    ing_results.each do |drink|
                        if non_alc_drx.include?(drink)
                            non_alc_results << drink
                        end
                    end
                    non_alc_results
                    if non_alc_results.length > 0
                        see_and_save(non_alc_results)
                        return_to_main
                    else
                        puts "That ingredient is not in the database."
                        return_to_main
                    end
                elsif non_alc_input == "2"
                    see_and_save(random_non_alc_drx)
                end
            when "3"
                view_menu
                return_to_main
            when "4"
                clear_menu
                return_to_main
            end
        end
        if input == "exit"
            puts "Thanks for using Drinkies! Have fun!"
            exit
        end
    end

    def prompt
        puts ""
        puts "Press 1 for alcoholic drinks."
        puts "Press 2 for non-alcoholic drinks."
        puts "Press 3 to see your current menu."
        puts "Press 4 to clear your current menu."
        puts "Type exit to end the program."
        puts ""
    end

    def alcoholic_prompt
        puts ""
        puts "Press 1 to select an ingredient."
        puts "Press 2 for a random list of ten drinks."
        puts "Press enter to return to main menu."
        puts ""
    end

    def non_alc_prompt
        puts ""
        puts "Press 1 to search by ingredient."
        puts "Press 2 for a random list of ten drinks."
        puts "Press enter to return to main menu."
        puts ""
    end

    def ingredient_select_prompt
        puts ""
        puts "Type a number to see a list of drinks with that ingredient."
        puts "Press enter to return to main menu."
        puts ""
    end

    def see_recipe_prompt
        puts ""
        puts "Type a number to see the recipe for that drink."
        puts "Press enter to return to main menu."
        puts ""
    end

    def save_prompt
        puts ""
        puts "Press 1 to save this drink to your menu."
        puts "Press 2 to return to the list of drinks"
        puts "Press enter to return to main menu."
        puts ""
    end

    def return_to_main
        puts "Press enter to return to main menu."
        input = gets.strip
        if input != nil
            menu
        end
    end

    def ingredients
        request = APIRequest.new('https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list')
        results = request.parse_json
        ingredients = results["drinks"]
        ing_names = ingredients.collect {|d| d["strIngredient1"]}
        ing_names.each.with_index {|v,i| puts "#{i+1}. #{v}"}
    end

    def ingredient_search(ingredient)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{ingredient}")
        results = request.parse_json
        drinks = results["drinks"]
        drinks_by_ingredient = drinks.collect {|d| d["strDrink"]}.to_a
    end

    def name_search(name)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{name}")
        details = request.parse_json
    end

    def view_recipe(drink)
        drink_details = name_search(drink)
        ingredient_list = []
        measure_list = []
        instructions = []
        drink_details["drinks"].each do |d|
            i = 1
            while d["strIngredient#{i}"] != nil
                ingredient_list << d["strIngredient#{i}"]
                measure_list << d["strMeasure#{i}"]
                instructions << d["strInstructions"]
                i += 1
            end
        end
        i = 0
        while i < ingredient_list.length
            puts "#{measure_list[i]} #{ingredient_list[i]}"
            i += 1
        end
        puts "#{instructions.uniq.to_s.gsub("[1]","")}"
    end

    def see_and_save(drink_array)
        drink_array.each.with_index {|v,i| puts "#{i+1}. #{v}"}
        see_recipe_prompt
        answer = gets.strip.downcase
        if answer.to_i >0 && answer.to_i <= drink_array.length
            view_recipe(drink_array[answer.to_i - 1])
            save_prompt
            save_answer = gets.strip
            if save_answer == "1"
                save_to_menu(drink_array[answer.to_i - 1])
                puts "#{drink_array[answer.to_i - 1]} has been saved to your menu!"
                return_to_main
            elsif save_answer == "2"
                see_and_save(drink_array)
            else
                return_to_main
            end
        else
            return_to_main
        end
    end

    def save_to_menu(drink)
        @saved_drinks << drink
        @saved_drinks
    end

    def random_alc_drx
        randoms = get_drx("Alcoholic").sample(10)
    end

    def random_non_alc_drx
        randoms = get_drx("Non_Alcoholic").sample(10)
    end

    def get_drx(filter)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=#{filter}")
        results = request.parse_json
        drinkies = results["drinks"].collect {|d| d["strDrink"]}.to_a
    end

    def view_menu
        i = 1
        while i <= @saved_drinks.length
            puts "#{i}. #{@saved_drinks[i-1]}"
            i += 1
        end
    end

    def clear_menu
        puts "Are you sure you want to clear the menu? Press 1 to proceed."
        puts "Otherwise, press any key to return to the main menu."
        input = gets.strip
        if input == "1"
            @saved_drinks.clear
            puts "Your current menu is empty."
        end
    end

end

drinks = CLI.new