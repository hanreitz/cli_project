require_relative '../config/environment'
class CLI
    def initialize
        input = ""
        @saved_drinks = []
        clear
        space
        welcome_box = TTY::Box.frame "Welcome to Drinkies!", "Let's dream up a drink menu!", padding: 3, align: :center, title: {top_left: "DRINKIES", bottom_right: "v1.0"}
        print welcome_box
        sleep(1)
        menu
    end

    def menu
        space
        main_input = main_prompt
        case main_input
        when 1
            clear
            space
            alc_input = alcoholic_prompt
            case alc_input
            when 1
                clear
                space
                ing_input = ingredient_select_prompt
                clear
                results = ingredient_search(ing_input)
                see_and_save(results)
            when 2
                clear
                puts "Type an ingredient to search: "
                ing_search_input = gets.strip
                clear
                alc_drx = get_drx("Alcoholic")
                ing_search_results = ingredient_search(ing_search_input)
                alc_results = alc_drx & ing_search_results
                if alc_results.length > 0
                    puts "The following drinks contain #{ing_search_input.downcase}."
                    see_and_save(alc_results)
                    return_to_main
                elsif alc_results.length == 0 && ing_search_results.length > 0
                    puts "Sorry, there are no alcoholic drinks containing #{ing_search_input} in the database."
                    puts "Taking you back to the main menu."
                    sleep(2)
                    return_to_main
                else
                    invalid_search
                end
            when 3
                clear
                see_and_save(random_alc_drx)
                menu
            when 4
                return_to_main
            end
        when 2
            non_alc_input = non_alc_prompt
            case non_alc_input
            when 1
                clear
                space
                ing_input = non_alc_ingredient_select_prompt
                clear
                results = ingredient_search(ing_input)
                see_and_save(results)
            when 2
                clear
                puts "Type an ingredient to search: "
                ing_search_input = gets.strip.capitalize
                clear
                non_alc_drx = get_drx("Non_Alcoholic")
                ing_search_results = ingredient_search(ing_search_input)
                non_alc_results = non_alc_drx & ing_search_results
                if non_alc_results.length > 0
                    puts "The following drinks contain #{ing_search_input.downcase}."
                    see_and_save(non_alc_results)
                    return_to_main
                elsif non_alc_results == 0 && ing_search_results.length > 0
                    puts "Sorry, there are no non-alcoholic drinks containing #{ing_input} in the database."
                    sleep(2)
                    return_to_main
                else
                    invalid_search
                end
            when 3
                clear
                see_and_save(random_non_alc_drx)
            when 4
                return_to_main
            end
        when 3
            clear
            view_menu
            puts "Press any key to return to main menu."
            view_input = gets.strip
            if view_input == "" || view_input.length > 0
                return_to_main
            end
        when 4
            clear
            clear_menu
            return_to_main
        when 5
            space
            puts "Thanks for using Drinkies! Have fun!"
            space
            sleep(1.5)
            clear
            exit
        end
    end

    #prompt and formatting objects 

    def prompt
        prompt = TTY::Prompt.new
    end

    def main_prompt
        prompt.select("Main Menu") do |menu|
            menu.choice "Alcoholic Drinks", 1
            menu.choice "Non-Alcoholic Drinks", 2
            menu.choice "View Current Menu", 3
            menu.choice "Clear Current Menu", 4
            menu.choice "Exit Drinkies", 5
        end
    end

    def alcoholic_prompt
        prompt.select("Choose one of the following:") do |menu|
            menu.choice "Select from a list of ingredients.", 1
            menu.choice "Search by ingredient.", 2
            menu.choice "See a random list of ten drinks.", 3
            menu.choice "Return to main menu.", 4
        end
    end

    def non_alc_prompt
        prompt.select("Choose one of the following:") do |menu|
            menu.choice "Select from a list of ingredients.", 1
            menu.choice "Search by ingredient.", 2
            menu.choice "See a random list of ten drinks.", 3
            menu.choice "Return to main menu.", 4
        end
    end

    def ingredient_select_prompt
        ing_menu = ["Return to main menu"]
        ingredients.each {|ing| ing_menu << ing}
        prompt.select("Choose one of the following:", ing_menu, per_page: 10)
    end

    def non_alc_ingredient_select_prompt
        ing_menu = ["Return to main menu"]
        non_alcoholic_ingredient_list.each {|ing| ing_menu << ing}
        prompt.select("Choose one of the following:", ing_menu, per_page: 10)
    end

    def see_recipe_prompt(results_of_ing_search)
        cocktails = []
        cocktails << "Return to main menu"
        cocktails << results_of_ing_search
        prompt.select("View a recipe below or return to the main menu:", cocktails, per_page: 10)
    end

    def save_prompt
        prompt.select("Would you like to save this drink to your menu?") do |menu|
            menu.choice "Save to menu", 1
            menu.choice "Return to drink list", 2
            menu.choice "Return to main menu", 3
        end
    end

    def menu_empty
        puts "Your current menu is empty."
    end

    def space
        puts ""
    end

    def clear
        system("clear")
    end

    def return_to_main
        clear
        menu
    end

    #objects created with user input + API results

    def random_alc_drx
        randoms = get_drx("Alcoholic").sample(10)
    end

    def random_non_alc_drx
        randoms = get_drx("Non_Alcoholic").sample(10)
    end
    
    def non_alcoholic_ingredient_list
        non_alc_drinks = get_drx("Non_Alcoholic")
        ingredient_list = []
        all_ingredients = non_alc_drinks.each do |drink|
            details = name_search(drink)
            drink_details = details["drinks"][0]
            drink_details.each do |key, value|
                if value != nil
                    if key.include? "strIngredient"
                        ingredient_list << value
                    end
                end
            end
        end
        ingredient_list.sort.uniq
    end

    def invalid_search
        space
        puts "Sorry, that ingredient is not in the database."
        puts "Taking you back to the main menu."
        space
        sleep(1.5)
        return_to_main
    end

    def see_and_save(results)
        recipe_input = see_recipe_prompt(results)
        if recipe_input != "Return to main menu"
            view_recipe(recipe_input)
            save_input = save_prompt
            case save_input
            when 1
                save_to_menu(recipe_input)
                puts "#{recipe_input.capitalize} has been saved to your menu!"
                sleep(1)
                return_to_main
            when 2
                clear
                see_and_save(results)
            when 3
                return_to_main
            end
        elsif recipe_input == "Return to main menu"
            return_to_main
        end
    end
    
    def view_recipe(drink)
        clear
        details = name_search(drink)
        drink_details = details["drinks"][0]
        ingredient_list = []
        measure_list = []
        recipe = []
        drink_details.each do |key, value|
            if value != nil
                if key.include? "strIngredient"
                    ingredient_list << value
                end
                if key.include? "strMeasure"
                    measure_list << value
                end
            end
        end
        i = 0
        space
        puts "#{drink}"
        space
        puts "Ingredients"
        space
        while i < ingredient_list.length
            puts "#{measure_list[i]}#{ingredient_list[i]}"
            i += 1
        end
        space
        puts "Method"
        space
        puts drink_details["strInstructions"]
        space
    end

    def save_to_menu(drink)
        @saved_drinks << drink
        @saved_drinks
    end

    def view_menu
        if @saved_drinks.length == 0
            space
            menu_empty
            space
            sleep(1.5)
            return_to_main
        else
            i = 1
            space
            puts "Current Menu:"
            space
            while i <= @saved_drinks.length
                puts "#{i}. #{@saved_drinks[i-1]}"
                i += 1
            end
            space
        end
    end

    def clear_menu
        puts "Are you sure you want to clear the menu? Enter 1 to proceed."
        puts "Otherwise, enter anything else to return to the main menu."
        input = gets.strip
        if input == "1"
            @saved_drinks.clear
            space
            menu_empty
            space
        else
            return_to_main
        end
    end

    #API request objects

    def get_drx(filter)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=#{filter}")
        results = request.parse_json
        drinkies = results["drinks"].collect {|d| d["strDrink"]}.to_a
    end

    def ingredients
        request = APIRequest.new('https://www.thecocktaildb.com/api/json/v1/1/list.php?i=list')
        results = request.parse_json
        ingredient_list = results["drinks"]
        ing_names = ingredient_list.collect {|d| d["strIngredient1"]}
    end

    def ingredient_search(ingredient)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=#{ingredient.capitalize}")
        if request.get_response_body != ""
            results = request.parse_json
            drinks = results["drinks"]
            drinks_by_ingredient = drinks.collect {|d| d["strDrink"]}
        else
            results = []
        end
    end

    def name_search(name)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/search.php?s=#{name}")
        details = request.parse_json
    end

end

drinks = CLI.new