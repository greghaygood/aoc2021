
class Area
    attr_accessor :x, :y, :vents

    def initialize(x, y)
        @x = x
        @y = y
        @vents = 0
    end

    def display
        @vents > 0 ? @vents : "."
    end

    def to_s
        "X: #{x} Y: #{y}  Vents: #{vents}"
    end
end

class VentPlot
    @@SNAP_HV = false

    def initialize
        @grid = []
        @X = 0
        @Y = 0
    end

    def print
        # transpose the coordinates to match the AOC example: https://adventofcode.com/2021/day/5
        (0..@X).each do |y|
            (0..@Y).each do |x|
                a = @grid[x][y] rescue nil
                area = a || Area.new(x, y)
                printf "%s" % area.display
            end
            puts "\n"
        end        
    end

    def danger_spots 
        count = 0
        (0..@X).each do |y|
            (0..@Y).each do |x|
                a = @grid[x][y] rescue nil
                area = a || Area.new(x, y)
                count += 1 if area.vents > 1
            end
        end       
        count 
    end

    def load_file(filename)
        File.readlines(filename).each do |line|
            #puts line
            start, stop = line.split('->', 2).map(&:strip)

            x1, y1 = start.split(',').map(&:to_i)
            x2, y2 = stop.split(',').map(&:to_i)
            # puts "start: #{x1},#{y1}  stop: #{x2},#{y2}"
            @X = [@X, x1, x2].max
            @Y = [@Y, y1, y2].max

            if (x1==x2 || y1==y2) ## handle the straight lines
                x1, x2 = [x1,x2].sort # so the range works
                y1, y2 = [y1,y2].sort # so the range works
                (x1..x2).each do |x|
                    (y1..y2).each do |y|
                        #puts "X @ #{x},#{y}"
                        @grid[x] = [] if @grid[x].nil?
                        @grid[x][y] = Area.new(x, y) if @grid[x][y].nil?

                        a = @grid[x][y]
                        a.vents += 1
                        @grid[x][y] = a
                    end
                end
            elsif !@@SNAP_HV 
                x_dir = x2 <=> x1
                y_dir = y2 <=> y1
                x = x1
                y = y1
                # puts "Steps: x:#{x_dir}, y:#{y_dir}"
                x_iter = (x2 - x1).abs + 1
                y_iter = (y2 - y1).abs + 1
                while x_iter > 0
                    while y_iter > 0
                        #puts "X @ #{x},#{y}"
                        @grid[x] = [] if @grid[x].nil?
                        @grid[x][y] = Area.new(x, y) if @grid[x][y].nil?

                        a = @grid[x][y]
                        a.vents += 1
                        @grid[x][y] = a

                        x += x_dir
                        y += y_dir
                        y_iter -= 1
                    end

                    x_iter -= 1              
                end
            end
        end
        
        puts "Grid: X:#{@X} Y:#{@Y}"
        print if DEBUG
    end
end

DEBUG = ARGV.include?("-d")
vm = VentPlot.new
vm.load_file("data/d5_#{DEBUG ? 'example' : 'input'}.txt")

count = vm.danger_spots
if count > 0
    puts "Found some danger spots: #{count}"
else
    puts "Safe to proceed, Captain!"
end
