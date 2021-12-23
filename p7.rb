require "./data/d7.rb"

SCALED_BURN_RATE = true
DEBUG = ARGV.include?("-d")
input = DEBUG ? EXAMPLE : INPUT

def fuel_cost(num)
    cost =  if SCALED_BURN_RATE
                num.times.reduce(0) do |sum, n|
                    sum += n+1
                end
            else
                num
            end
end

input_sorted = input.sort
start = input_sorted.first
last = input_sorted.last
samples = input_sorted.count
puts "Input: #{input_sorted}, #{samples}"
min_pos = input_sorted[samples - 1]
min_fuel = 10000000000000
puts "Starts: pos:#{min_pos}, fuel: #{min_fuel}"
(start..last).each do |pos|
    #puts "***********************************"
    total_fuel = 0
    input.each do |offset|
        fuel = fuel_cost((pos - offset).abs)
        #puts "Move from #{offset} to #{pos}: #{fuel}"
        total_fuel += fuel
    end
    #puts "Total move from #{pos}: #{total_fuel}"
    if total_fuel < min_fuel
        puts "***********************************"
        puts "New best position: #{pos}"
        min_fuel = total_fuel
        min_pos = pos
    end        
end

puts "====================================="
puts "Ideal Position: #{min_pos}"
puts "Fuel Used: #{min_fuel}"
puts "====================================="
input.each do |offset|
    fuel = fuel_cost((min_pos - offset).abs)
    if DEBUG
        puts "- Move from #{offset} to #{min_pos}: #{fuel} fuel"
    end
end
