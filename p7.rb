require "./data/d7.rb"

DEBUG = ARGV.include?("-d")
input = DEBUG ? EXAMPLE : INPUT

class Position 
    # attr_accessor 
end

def uniques(set)
    set.uniq.count
end

def find_midpoint(set)
    sorted = set.sort
    sorted[(sorted.length / 2).to_i]
end

a = find_midpoint(input)
puts "midpoint: #{a}"

puts "uniques out of #{input.count}: #{uniques(input)}"

input_sorted = input.sort
samples = input_sorted.count
puts "Input: #{input_sorted}, #{samples}"
min_pos = input_sorted[samples - 1]
min_fuel = min_pos * samples
puts "Starts: pos:#{min_pos}, fuel: #{min_fuel}"
input.each do |pos|
    puts "***********************************"
    total_fuel = 0
    input.each do |offset|
        fuel = (pos - offset).abs
        #puts "Move from #{offset} to #{pos}: #{fuel}"
        total_fuel += fuel
    end
    puts "Total move from #{pos}: #{total_fuel}"
    if total_fuel < min_fuel
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
    fuel = (min_pos - offset).abs
    puts "- Move from #{offset} to #{min_pos}: #{fuel} fuel"
end
puts "====================================="


