require "pp"

class HeightMap
    def initialize(filename)
        @data = []
        load_file(filename)
    end
    
    def load_file(filename)
        File.readlines(filename).each do |line|
             @data << line.strip.split(//).map(&:to_i)
        end

        @row_count = @data.length
        @col_count = @data[0].length
    end

    def is_low_point(r, c)
        cur = @data[r][c]
        # pp "checking", cur
        
        min = cur
        (r-1..r+1).each do |rp|
            # pp ["RP", rp]
            next if rp < 0 || rp >= @row_count
            (c-1..c+1).each do |cp|
                # pp ["CP", cp]
                next if cp < 0 || cp >= @col_count
                col = @data[rp][cp]
                min = col if col && col < min 
            end
        end
        # pp ["min", r, c, cur, min]
        min == cur
    end

    def risk_level
        risk = 0
        @data.each.with_index do |row, r|
            row.each.with_index do |col, c|
                if is_low_point(r, c)
                    pp ["low point", r, c, @data[r][c]]
                    risk += @data[r][c] + 1
                end
            end
        end

        risk
    end
end

DEBUG = ARGV.include?("-d")
filename = "data/d9_#{DEBUG ? 'example' : 'input'}.txt"
mapper = HeightMap.new(filename)

result = mapper.risk_level
puts "Risk Level: #{result}"