require "./data/d6.rb"

class Population
    def initialize(start)
        @state = start
    end

    def generation_count(n)
        puts "Initial state: #{@state}"
        day_lbl = "day"

        n.times.each do |gen0|    
            gen = gen0 + 1
            kids = []
            @state = @state.map do |g| 
                g1 = g - 1;  
                case g1
                when 0
                    kids << 9
                when -1
                    g1 = 6
                end
                g1 
            end
            #puts "State now? #{@state}"
            new_kids = @state.count(0)
            
            state_show = if @state.count > 20
                            [@state.slice(0,9), '...', @state.slice(-9, 9)].flatten
                         else
                            @state
                         end
            puts "After #{gen} #{day_lbl}: #{state_show}"
            break if n == gen
            day_lbl = "days"
        
            #puts "New? #{new_kids}"
            new_kids.times.each { @state << 9 }
        end

        @state.count
    end
end

DEBUG = ARGV.include?("-d")
starting_point = DEBUG ? EXAMPLE : INPUT

limit = 10
if ARGV.include?("-l")
    li = ARGV.index("-l")
    new_limit = ARGV[li + 1] 
    limit = new_limit.to_i unless new_limit.nil?
end

puts "limit: #{limit}"
puts starting_point.to_s

pop = Population.new(starting_point)
count = pop.generation_count(limit)

puts "Total: #{count}"