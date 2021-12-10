require "./data/d6.rb"

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

state = starting_point
initial_gen_size = state.size
puts "Initial Gen Size: #{initial_gen_size}"
puts "Initial state: #{state}"
day_lbl = "day"
limit.times.each do |gen0|
    
    gen = gen0 + 1
    kids = []
    state = state.map do |g| 
        g1 = g - 1;  
        case g1
        when 0
            kids << 9
        when -1
            g1 = 6
        end
        g1 
    end

    state_show = if state.count > 20
                    [state.slice(0,9), '...', state.slice(-9, 9)].flatten
                 else
                    state
                 end
    puts "After #{gen} #{day_lbl}: #{state_show}"
    break if limit == gen
    day_lbl = "days"
    state = state + kids
end

puts "Total: #{state.count}"