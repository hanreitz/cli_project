module Drinkies
class CLI
    def initialize
        input = ""
        @saved_drinks = []
        start
    end

    def start
        input = ""
        clear
        space
        welcome_box = TTY::Box.frame "Welcome to Drinkies!", "Let's dream up a drink menu!", padding: 3, align: :center, title: {top_left: "DRINKIES", bottom_right: "v1.0"}
        print welcome_box
        initialize_all_drx
        #loading bar because this will take a while
        menu
    end

    def menu
        space
        main_input = main_prompt
        case main_input
        when 1 #alcoholic drinks
            clear
            space
            alc_input = alcoholic_prompt
            case alc_input
            when 1 #see a list of ingredients
                clear
                space
                ing_input = ingredient_select_prompt("Alcoholic")
                clear
                results = Drink.find_by_ingredient(ing_input.downcase)
                see_and_save(results)
            when 2 #search by ingredient
                clear
                puts "Type an ingredient to search: "
                ing_search_input = gets.strip
                clear
                alc_drx = get_drx("Alcoholic")
                ing_search_results = Drink.find_by_ingredient(ing_search_input.downcase)
                alc_results = alc_drx & ing_search_results
                if alc_results.length > 0
                    puts "Drinkies found the following drinks with #{ing_search_input}."
                    see_and_save(alc_results)
                    return_to_main
                elsif alc_results.length == 0 && ing_search_results.length > 0
                    puts "Sorry, there are no alcoholic drinks containing #{ing_search_input} in the database."
                    puts "Taking you back to the main menu."
                    sleep(3)
                    return_to_main
                else
                    invalid_search
                end
            when 3 #see a random list of ten drinks
                clear
                see_and_save(random_alc_drx)
                menu
            when 4 #return to the main menu
                return_to_main
            end
        when 2 #non-alcoholic drinks
            non_alc_input = non_alc_prompt
            case non_alc_input
            when 1 #see a list of ingredients
                clear
                space
                non_ing_input = ingredient_select_prompt("Non alcoholic")
                clear
                results = (Drink.find_by_alcoholic("Non alcoholic") & Drink.find_by_ingredient(non_ing_input.downcase))
                see_and_save(results)
            when 2 #search by ingredient
                clear
                puts "Type an ingredient to search: "
                non_ing_search_input = gets.strip
                clear
                non_alc_drx = get_drx("Non alcoholic")
                non_ing_search_results = Drink.find_by_ingredient(non_ing_search_input.downcase)
                non_alc_results = non_alc_drx & non_ing_search_results
                if non_alc_results.length > 0
                    puts "Drinkies found the following drinks with #{ing_search_input}."
                    see_and_save(non_alc_results)
                    return_to_main
                elsif non_alc_results.length == 0 && non_ing_search_results.length > 0
                    puts "Sorry, there are no non-alcoholic drinks containing #{ing_search_input} in the database."
                    puts "Taking you back to the main menu."
                    sleep(3)
                    return_to_main
                else
                    invalid_search
                end
            when 3 #see a random list of ten
                clear
                see_and_save(random_non_alc_drx)
            when 4 #return to main menu
                return_to_main
            end
        when 3 #view current menu
            clear
            view_menu
            puts "Press any key to return to main menu."
            view_input = gets.strip
            if view_input == "" || view_input.length > 0
                return_to_main
            end
        when 4 #clear current menu
            clear
            clear_menu
            return_to_main
        when 5 #exit program
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

    def ingredient_select_prompt(filter)
        ingredients = get_ingredient_list(filter)
        complete_ingredient_menu = ingredients.sort.unshift("Return to main menu")
        prompt.select("Choose one of the following:", complete_ingredient_menu, per_page: 10)
    end

    # def non_alc_ingredient_select_prompt
    #     ing_menu = ["Return to main menu"]
    #     non_alcoholic_ingredient_list.each {|ing| ing_menu << ing}
    #     prompt.select("Choose one of the following:", ing_menu, per_page: 10)
    # end

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

    def initialize_all_drx
        alphanum = [*'1'..'9',*'a'..'z']
        all_drinks = []
        space
        progressbar = ProgressBar.create(total: nil, length: 80, format: 'Grabbing Drink Options! |%B| %a')
        alphanum.each do |i|
            drinks_raw_data = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/search.php?f=#{i}")
            all_drinks << drinks_raw_data.parse_json["drinks"]
            progressbar.increment
        end
        all_drinks.each do |array|
            if array != nil
                array.each do |hash|
                    Drink.new(hash)
                    progressbar.increment
                end
            end
        end
        progressbar.finish
        clear
    end

    def all_alc_drx
        alc_drx = Drink.find_by_alcoholic("Alcoholic")
        alc_drx.collect {|a| a.name}
    end

    def all_non_alc_drx
        non_alc_drx = Drink.find_by_alcoholic("Non alcoholic")
        non_alc_drx.collect {|n| n.name}
    end

    def random_alc_drx
        randoms = all_alc_drx.sample(10)
    end

    def random_non_alc_drx
        randoms = all_non_alc_drx.sample(10)
    end
    
    def get_ingredient_list(filter)
        ingredient_list = []
        if filter == "Alcoholic"
            ingredient_list = Ingredient.all.collect {|i| i.name}
            ingredient_list.sort
        elsif filter == "Non alcoholic"
            Drink.all.each do |d| 
                if d.alcoholic == "Non alcoholic"
                    d.ingredients.each {|i| ingredient_list << i.downcase}
                end
            end
            ingredient_list.uniq.sort
        end
        all_lowercase = ingredient_list.flatten.collect {|i| i.downcase}
        unique_ingredient_list = all_lowercase.uniq.reject{|i| i == ""}
        final_ingredient_list = unique_ingredient_list.collect {|i| i.capitalize}
    end

    # def non_alcoholic_ingredient_list
    #     non_alc_drinks = get_drx("Non_Alcoholic")
    #     ingredient_list = []
    #     all_ingredients = non_alc_drinks.each do |drink|
    #         details = name_search(drink)
    #         drink_details = details["drinks"][0]
    #         drink_details.each do |key, value|
    #             if value != nil
    #                 if key.include? "strIngredient"
    #                     ingredient_list << value
    #                 end
    #             end
    #         end
    #     end
    #     ingredient_list.sort.uniq
    # end

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
                d = Drink.find_by_name(recipe_input)
                d.save_to_menu
                clear
                puts "#{d.name.capitalize} has been saved to your menu!"
                sleep(3)
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
        details = Drink.find_by_name(drink)
        name = details.name
        ingredient_list = details.ingredients
        measure_list = details.measures
        method = details.method
        space
        puts "#{name}"
        space
        puts "Ingredients"
        space
        i=0
        while i < ingredient_list.length
            puts "#{measure_list[i]} #{ingredient_list[i]}"
            i += 1
        end
        space
        puts "Method"
        space
        puts "#{method}"
        space
    end

    def save_to_menu(drink)
        @saved_drinks << drink
        @saved_drinks
    end

    def view_menu
        if Drink.menu.length == 0
            space
            menu_empty
            space
            sleep(2)
            return_to_main
        else
            i = 0
            space
            puts "Current Menu:"
            space
            while i < Drink.menu.length
                puts "#{i + 1}. #{Drink.menu[i].name}"
                i += 1
            end
            space
        end
    end

    def clear_menu
        if Drink.menu.length > 0
            space
            puts "Are you sure you want to clear the menu? Enter 1 to proceed."
            space
            puts "Otherwise, enter anything else to return to the main menu."
            space
            input = gets.strip
            if input == "1"
                @saved_drinks.clear
                space
                menu_empty
                space
                sleep(3)
                return_to_main
            else
                return_to_main
            end
        else
            space
            menu_empty
            space
            sleep(3)
            return_to_main
        end
    end

    #API request objects

    def get_drx(filter)
        request = APIRequest.new("https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=#{filter}")
        results = request.parse_json
        drinkies = results["drinks"].collect {|d| d["strDrink"]}.to_a
    end

end
end