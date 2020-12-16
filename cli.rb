class CLI

    def start
        input = ""
        puts "What's for Dinner?"
        menu
    end

    def menu
        puts ""
        prompt
        puts ""
        input = gets.strip.downcase
        while input != "exit"
            case input
            when "1"
                puts ""
                diet_hash_menu
                puts ""
                input = gets.strip.downcase
                while input != "exit"
                    case input
                    when "1"
                        #diet_hash(vegan)
                        #diet_rest_menu
                    when "2"
                        #diet_hash(vegetarian)
                        #input = "exit"
                    when "3"
                        #diet_hash(pescatarian)
                        #input = "exit"
                    when "4"
                        #saved_recipes
                        #input = "exit"
                    when "5"
                        #diet_hash(keto/HFLC)
                        #input = "exit"
                    when "6"
                        #diet_hash(high-protein low-carb)
                        #input = "exit"
                    when "exit"
                        puts "Going back to main menu."
                    end
                end
                prompt
                input = gets.strip
            when "2"
                input = gets.strip.downcase
                while input != "exit"

            when "3"
            when "4"
            when "5"
            when "exit"
                puts "Thanks for using 'What's for Dinner?'! See you next time."
            end
        end
        prompt
        input = gets.strip
                
    end

    def prompt
        puts ""
        puts "Press 1 to enter dietary restrictions (ex: vegan)."
        puts "Press 2 to enter food allergies."
        puts "Press 3 to search by ingredient."
        puts "Press 4 to see saved recipes."
        puts "Press 5 to skip straight to a random recipe."
        puts "Type exit to end the program."
        puts ""
    end

    def diet_rest_menu
        puts ""
        puts "Press 1 if you are vegan (NO animal products)."
        puts "Press 2 if you are vegetarian (eggs, dairy OK)."
        puts "Press 3 if you are pescatarian (eggs, seafood, dairy OK)."
        puts "Press 4 if you follow a gluten-free diet."
        puts "Press 5 if you follow a keto or HFLC diet."
        puts "Press 6 if you follow a high-protein low-carb diet."
        puts "Type exit to return to main menu."
        puts ""
    end

    def diet_hash(diet_name)
        #searches API for specific diet parameters (tags? Like vegan?)
        #saves matches to hash
        #returns hash
    end

    def allergy_hash(ingredient)
        #searches API for specific allergies (removes if they have those ingredients)
        #saves matches to hash
        #returns hash
    end

    def mash_hash
        #takes all hashes that could exist on a recipe search and finds only the recipes that exist in all of them
        #dietary hash, up to several allergy hashes, ingredient search results
        #returns the hash
    end

    def saved_recipes
       puts "#{@saved_recipes}"
    end
end