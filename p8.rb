require "pp"

class SignalUnscrambler
    DIGIT_SEGMENTS = [
        %w[a b c e f g],    # 0 - 6
        %w[c f],            # 1 - 2
        %w[a c d e g],      # 2 - 5
        %w[a c d f g],      # 3 - 5
        %w[b c d f],        # 4 - 4
        %w[a b d f g],      # 5 - 5
        %w[a b d e f g],    # 6 - 6
        %w[a c f],          # 7 - 3
        %w[a b c d e f g],  # 8 - 7
        %w[a b c d f g],    # 9 - 6
    ]

    def initialize(filename)
        @filename = filename
        @data = []

        @segments = DIGIT_SEGMENTS.each.with_index.reduce({}) do |cume, (seg, index)| 
            # pp index
            # pp cume
            # pp seg
            sz = seg.length
            cume[sz] ||= {patterns: [], digits: []}
            cume[sz][:patterns] << seg
            cume[sz][:digits] << index
            cume
        end

        #puts "segments"
        #pp @segments

        self.load_file        
    end

    def load_file
        File.readlines(@filename).each do |line|
             @data << line
        end
    end

    def decode_line(line)
        decoded = [[],[]]
        parts = line.split(/\|/, 2)  
        parts.each.with_index do |part, index|
            part.strip.split(/\s+/).each do |pattern| 
                len = pattern.length
                segment = @segments[len]
                options = segment[:patterns]
                if options.count == 1
                    decoded[index] << segment[:digits]
                else
                    decoded[index] << options
                end
            end
        end

        decoded_h = {input: decoded[0], output: decoded[1]}
        # puts decoded_h
        return decoded_h
    end

    def count_unique_outputs
        count = 0
        @data.each do |line|
            decoded = decode_line(line)
            decoded[:output].each do |piece|
                count += 1 if piece.size == 1
            end
        end

        count
    end
end

DEBUG = ARGV.include?("-d")
filename = "data/d8_#{DEBUG ? 'example' : 'input'}.txt"
su = SignalUnscrambler.new(filename)

result = su.count_unique_outputs
puts "Unique Output Values: #{result}"
