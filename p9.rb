require "pp"

class HeightMap
    MARK = '_'

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
        @location_total = @row_count * @col_count
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

    def find_lowpoints
        lps = []
        @data.each.with_index do |row, r|
            row.each.with_index do |col, c|
                if is_low_point(r, c)
                    # pp ["low point", r, c, @data[r][c]]
                    lps << [r, c]
                end
            end
        end

        lps
    end

    def risk_level
        find_lowpoints.reduce(0) do |sum, lp|
            r = lp[0]
            c = lp[1]
            sum += @data[r][c] + 1
        end
    end

    def MEH_do_clear_row(row, c0, r)
        pp ['clearing row', row, c0]
        clear = false
        row.each.with_index do |val, c|
            pp ["row", val, c, clear]
            next if c < 0 || c < c0 || c > @col_count
            clear = true if val == 9 || val == MARK
            pp ['cleared?', clear, val]
                
            if clear
                val = MARK 
                row[c] = val
                @scanned[r][c0] = true
            end
        end

        row
    end

    def MEH_do_clear_col(col, r0)
        pp ['clearing col', col, r0]
        clear = false
        col.each.with_index do |val, n|
            pp ["col", val, n, clear]
            next if n < r0 || n >= @row_count
            clear = true if val == 9 || val == MARK
            pp ['cleared?', clear, val]
            if clear
                val = MARK 
                col[n] = val
                #@scanned[r0][n] = true
            end

        end

        col
    end

    def MEH_clear_row(grid, r, c0)
        row = grid[r]
        row = do_clear_row(row, c0, r)
        row = do_clear_row(row.reverse, @col_count - c0 - 1, r).reverse
        grid[r] = row
        grid
    end

    def is_end(value)
        value == MARK || value == 9
    end

    def scan_neighbors(grid, r0, c0)
        # pp ["scan_neighbors", r0, c0]
        new_neighbors = []
        @scanned[r0][c0] = true
        to_scan = [] 
        to_scan << [r0-1, c0] unless r0 == 0
        to_scan << [r0+1, c0] unless r0+1 == @row_count
        to_scan << [r0, c0-1] unless c0 == 0
        to_scan << [r0, c0+1] unless c0+1 == @col_count

        to_scan.each do |rc|
            rn = rc[0]
            cn = rc[1]
            # pp ['to scan', rn, cn, @scanned[rn]]
            unless @scanned[rn][cn]
                val = grid[rn][cn]
                if is_end(val)
                    grid[rn][cn] = MARK
                else
                    new_neighbors << [rn,cn]
                end
            end
        end
        # pp ["extra neighbors", new_neighbors]
        new_neighbors
    end

    def do_scan_basin(grid, r0, c0)
        basin_size = 0
        neighbors = [[r0, c0]]
        scanning = true
        count = @location_total

        while scanning && count > 0
            count -= 1
            # pp ["scan run", count, neighbors]
            new_neighbors = []
            neighbors.each do |rc|
                unless is_end(grid[rc[0]][rc[1]])
                    basin_size += 1 # grid[rc[0]][rc[1]]
                end

                addl = scan_neighbors(grid, rc[0], rc[1])
                new_neighbors << addl
            end
            to_add = new_neighbors.flatten(1).uniq
            scanning = false if to_add.size == 0
            neighbors = to_add
        end

        # grid = clear_row(grid, r0, c0)
        #grid = clear_line(grid.transpose, c0, r0, @row_count).transpose

        puts "Basin size: #{basin_size}" if DEBUG
        basin_size
    end 

    def scan_basin(grid, r0, c0)
        @scanned = grid.map do |row|
            row.map do |col|
                false
            end
        end

        basin_size = do_scan_basin(grid, r0, c0)
        print_grid(grid) if DEBUG
        print_grid(@scanned) if DEBUG
        
        basin_size
    end

    def print_grid(grid)
        puts "----"
        pp grid
        puts "----"
        grid.each.with_index do |row, r|
            row.each.with_index do |col, c|
                if col == true
                    print 'T'
                elsif col == false
                    print 'F'
                else
                    print col
                end
            end
            print "\n"
        end
    end

    def find_basin_sizes
        basins = []

        lps = find_lowpoints
        pp lps if DEBUG
        lps.each do |lp|
            pp ["basin low point", lp] if DEBUG
            grid = @data.dup
            basin_size = scan_basin(grid, lp[0], lp[1])
            
            print_grid(grid) if DEBUG
            # print "--\n"
            # print_grid(grid.reverse)
            basins << basin_size
        end

        basins
    end
end

DEBUG = ARGV.include?("-d")
filename = "data/d9_#{DEBUG ? 'example' : 'input'}.txt"
mapper = HeightMap.new(filename)

result = mapper.risk_level
puts "Risk Level: #{result}"

all_basin_sizes = mapper.find_basin_sizes
all = all_basin_sizes
pp ["all basin sizes", all] if DEBUG
largest = all_basin_sizes.sort.reverse.slice(0, 3)
puts "Largest Basins: "
pp largest
total = largest.reduce(1) { |sum,val| sum * val }
puts "Largest Basin Value: #{total}"

