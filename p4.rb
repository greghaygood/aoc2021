
class Board
    ROWS = 5
    COLS = 5

    @number = -1
    @numbers = []
    @marked = []
    @last_number = -1
    @won = false
    @playing = false

    def initialize(number, input)
        @number = number
        @numbers = input.flatten # single-dim array
        @marked = @numbers.map { false }
        @playing = true
        @won = false
        
        #print
    end

    def playing?
        @playing
    end

    def mark(number)
        return unless @playing

        if @numbers.include?(number)
            @marked[@numbers.index(number)] = true
            @last_number = number
        end        
    end

    def print
        puts "Board ##{@number} (last played: #{@last_number})"
        ROWS.times.each do |row|
            COLS.times.each do |col|
                printf "%3d" % @numbers[(row * COLS) + col]
                printf "%1s" % (@marked[(row * COLS) + col] ? "*" : " ")
            end
            printf "     "
            COLS.times.each do |col|
                printf "%3s" % (@marked[(row * COLS) + col] ? "T" : "F")
            end

            puts "\n"
        end
        puts "\n"
    end

    def done!
        @won = true
        @playing = false
    end

    def winner?
        ROWS.times.each do |r|
            c1 = (r * COLS)
            c5 = c1 + COLS - 1
            row = @marked.slice(c1..c5)
            # puts "checking row: #{row} (#{c1}..#{c5})"
            if row.all?{ |m| m == true }
                #puts "WON!"
                done!
                return true
            end
        end    
        
        COLS.times.each do |c|
            col = []
            ROWS.times.each do |r|
                col << @marked[c + (COLS * r)]
            end
            # puts "checking col: #{col}"
            if col.all?{ |m| m == true }
                #puts "WON!"
                done!
                return true
            end
        end

        false
    end

    def score
        score = 0
        return score unless @won

        @marked.each.with_index do |m, index|
            if m == false
                score += @numbers[index]
            end
        end

        score * @last_number
    end

end

class Game 
    #@@MODE = :FirstWinner
    @@MODE = :LastWinner
    @@SEP = "*****************************************"

    def initialize 
        @queue = []
        @boards = []
        @active_board_count = 0
        @winner = nil
        @winners = []
    end

    def play_interactive!
        puts "Ready? Hit <SPACEBAR> to play a number..."
        while key = gets
            key.chomp!
            if key == " "
               play_game

            elsif key == "q"
                puts "All done!"
                exit 0
            end
        end        
    end

    def play!
        @queue.length.times.each do |ignore|
            play_game
        end
    end

    def play_game
        draw_number
        check_boards

        case @@MODE
        when :FirstWinner

            if @winner
                declare_winner!(@winner)
            end
    
        when :LastWinner

            if @winner
                puts @@SEP
                puts "Got a winner ...."
                puts @@SEP
                puts ""
                @winner.print
                puts @@SEP
                @winners << @winner
                @active_board_count -= 1            
                @winner = nil
            end

            if @queue.length == 0
                declare_winner!(@winners.last)
            end

        else
            puts "Not sure what mode we\'re playing ...."
            exit 0
        end

    end

    def declare_winner!(winner)
        puts @@SEP
        puts ""
        puts "WINNER!   Final Score: #{winner.score}"
        puts ""
        puts @@SEP
        puts ""
        winner.print
        puts @@SEP
        exit 0;
    end

    def draw_number
        @current_number = @queue.shift
        puts @@SEP
        puts "Next number: #{@current_number}"
        #puts @@SEP
    end

    def check_boards
        @boards.each do |board|
            next unless board.playing?

            board.mark(@current_number)

            board.print

            if board.winner?
                @winner = board
                # break;
            end
        end
    end

    def load_file(filename)
        cur_board = []
        cur_line = 0
        board_count = 1
        File.foreach(filename) do |line|
            line.strip!
            if @queue.empty?
                @queue = line.split(',').flatten.map(&:to_i)
            else
                unless line.empty?
                    cur_board << line.split(/\s+/).map(&:to_i)
                    cur_line += 1

                    if cur_line == 5
                        @boards << Board.new(board_count, cur_board) unless cur_board.empty?
                        board_count += 1
                        cur_line = 0
                        cur_board = []
                    end
                end
            end

        end

        @active_board_count = @boards.count
        puts "Starting board count: #{@active_board_count}"
        puts "Starting number count: #{@queue.count}"

    end
end

game = Game.new
# game.load_file("data/d4_example.txt")
game.load_file("data/d4_input.txt")

# game.play_interactive!
game.play!