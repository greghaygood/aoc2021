require "./data/d2.rb"

class Submarine
    def initialize
        # x = forward/back
        # y = left/right
        # z = up/down
        @pos = { x: 0, y: 0, z: 0 }
        @aim = 0
    end

    def position
        @pos
    end

    def move(command)
        # puts command
        cmd, step = command.split(/ /)
        self.send(cmd, step.to_i)
    end

    def forward(step)
        @pos[:x] += step
        @pos[:z] += step * @aim
    end

    def back(step)
        @pos[:x] -= step
    end

    def up(step)
        @aim -= step
    end

    def down(step)
        @aim += step
    end

    def left(step)
        @pos[:y] += step
    end

    def right(step)
        @pos[:y] -= step
    end

end

mySub = Submarine.new
# array = EXAMPLE
array = INPUT
array.each do |cmd|
    mySub.move(cmd)
end

pos = mySub.position
puts "Final position: ", pos
puts "Metric: ", pos[:x] * pos[:z]