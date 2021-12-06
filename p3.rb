require "./data/d3.rb"

# "%05d" % 22.to_s(2)

class Diagnostics
    attr_reader :bitsize

    def initialize(report)
        @gamma = []
        @epsilon = []
        @oxygen = []
        @co2 = []

        @report = report.freeze
        @report_bits = @report.map { |l| l.split("") }.freeze

        @bitsize = report[0].length.freeze
    end

    def calc_power_consumption
        count = @report.count
        ones = @report_bits.transpose.map { |bit_array| bit_array.count("1") }        
        zeros = ones.map { |val| count - val }

        ones.each.with_index do |bit, ndx| 
            if bit > zeros[ndx]
                a = "1"
                b = "0"
            else
                a = "0"
                b = "1"
            end
            @gamma[ndx] = a
            @epsilon[ndx] = b
        end
    end

    def calc_life_support_rating_component(criteria)
        consideration_set = @report_bits
        @bitsize.times.each do |ndx|        
            # puts ndx
            count = consideration_set.count
            ones = consideration_set.transpose.map { |bit_array| bit_array.count("1") }        
            zeros = ones.map { |val| count - val }
            # puts ones.to_s
            # puts zeros.to_s
            
            bit = if criteria == :mcv
                    zeros[ndx] > ones[ndx] ? "0" : "1" # use 1 if tied
                  elsif criteria == :lcv
                    ones[ndx] >= zeros[ndx] ? "0" : "1" # use 0 if tied
                  end
            # puts "bit: #{bit} for #{criteria}"
            consideration_set = consideration_set.select { |byte| byte[ndx] == bit }
            return consideration_set[0] if consideration_set.size == 1

            # puts consideration_set.to_s
        end

        # puts consideration_set.to_s
        consideration_set[0]
    end

    def calc_life_support_rating
        @oxygen = calc_life_support_rating_component(:mcv)
        # puts @oxygen.to_s
        @co2 = calc_life_support_rating_component(:lcv)
        # puts @co2.to_s
    end

    def gamma
        # puts @gamma.to_s
        @gamma.join("").to_i(2)
    end

    def epsilon
        # puts @epsilon.to_s
        @epsilon.join("").to_i(2)
    end

    def power_consumption
        gamma * epsilon
    end

    def oxygen
        @oxygen.join("").to_i(2)
    end

    def co2_scrubber
        @co2.join("").to_i(2)
    end

    def life_support_rating
        oxygen * co2_scrubber
    end

end

# array = EXAMPLE
array = INPUT
report = Diagnostics.new(array)
puts "Bitsize: ", report.bitsize

report.calc_power_consumption
puts "Power Consumption: ", report.power_consumption

report.calc_life_support_rating
puts "Life Support: ", report.life_support_rating

