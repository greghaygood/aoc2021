require "./data/d1.rb"

def count_increases(array)
    incr_count = 0
    prev = 1000000000000000
    array.each do |cur|
        if cur > prev
            incr_count += 1
        end
        prev = cur
    end
    
    incr_count
end

def combine_every_3(array)
   
    new_array = []
    max = array.size - 3
    array.each.with_index do |cur, index|
        new_array << cur + array[index+1] + array[index+2] unless index > max
    end

    #puts new_array
    new_array
end

# array_to_use = EXAMPLE.map(&:to_i)
array_to_use = INPUT.map(&:to_i)
puts count_increases(combine_every_3(array_to_use))
