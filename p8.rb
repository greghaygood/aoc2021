require "pp"

class SignalUnscrambler
    DIGIT_SEGMENTS = [
        %w[a b c e f g],    # 0 / len: 6
        %w[c f],            # 1 / len: 2
        %w[a c d e g],      # 2 / len: 5
        %w[a c d f g],      # 3 / len: 5
        %w[b c d f],        # 4 / len: 4
        %w[a b d f g],      # 5 / len: 5
        %w[a b d e f g],    # 6 / len: 6
        %w[a c f],          # 7 / len: 3
        %w[a b c d e f g],  # 8 / len: 7
        %w[a b c d f g],    # 9 / len: 6
    ]

    def initialize(filename)
        @filename = filename
        @data = []        

        @segments = DIGIT_SEGMENTS.each.with_index.reduce({}) do |cume, (seg, index)| 
            sz = seg.length
            cume[sz] ||= {patterns: [], digits: []}
            cume[sz][:patterns] << seg
            cume[sz][:digits] << index
            cume
        end.freeze

        #puts "segments"
        # pp @segments

        self.load_file        
    end

    def load_file
        File.readlines(@filename).each do |line|
             @data << line
        end
    end

    def decipher_5s(codes)
        segs_of_5 = codes.select { |o| o[:input].size == 5 }.map{ |o| o[:input].sort }.uniq
        if segs_of_5.size < 3
            puts "Not enough codes of size 5 to decipher"
        end

        # puts "Segments of 5:"
        a_d_g = []
        b_e_c_f = []
        segs_of_5.each.with_index do |p, n1|
            segs_of_5.each.with_index do |p2, n2|
                next if n1 == n2

                #puts "------------"
                #pp "-", p, p2
                #puts "---"

                same = p & p2                
                #pp "same", same
                a_d_g << same 

                diff = p.difference(p2)
                #pp "diff", diff 
                b_e_c_f << diff
            end
        end
        
        add_cipher_clues([:a, :d, :g], a_d_g.flatten.sort)
        add_cipher_clues([:b, :c, :e, :f], b_e_c_f.flatten.sort)
        compact!
    end

    def decipher_6s(codes)
        segs_of_6 = codes.select { |o| o[:input].size == 6 }.map{ |o| o[:input].sort }.uniq
        if segs_of_6.size < 3
            puts "Not enough codes of size 6 to decipher"
        end

        # puts "Segments of 6:"
        a_b_f_g = []
        c_d_e = []
        segs_of_6.each do |p|
            # puts "-"
            # pp p
            segs_of_6.each do |p2|
                # puts "--"
                # pp p2
                # puts "---"

                same = p & p2
                a_b_f_g << same 
                diff = p.difference(p2)
                # pp diff 
                c_d_e << diff
            end
        end
        
        add_cipher_clues([:a, :b, :f, :g], a_b_f_g.flatten.sort)
        add_cipher_clues([:c, :d, :e], c_d_e.flatten.sort)
        compact!
    end

    def compact!
        @cipher.each do |key, options|
            if options.size == 1
                @deciphered << key.to_sym
                @deciphered.uniq!
                @deciphered.sort!
                @cipher[key.to_s] = @cipher[key.to_s].freeze
            end
        end

        rerun = false
        @deciphered.each do |key|
            exclude = @cipher[key.to_s][0]&.to_s
            if exclude
                # puts "excluding #{key}: #{exclude}"
                # pp exclude
                @cipher.each do |key2, options|
                    next if key.to_sym == key2.to_sym || options.size == 1
                    # pp "before", key2, options
                    options = options.select { |o| o != exclude }
                    # pp "after", options
                    rerun = options.size == 1
                    @cipher[key2.to_s] = options               
                end
            end
        end
       
        compact! if rerun   
    end

    def add_cipher_clues(targets, options)
        targets = [targets] unless targets.is_a?(Array)
        # puts 'adding cipher clues...'
        # pp targets
        options = options.flatten.uniq.sort
        # pp options
        options = options.select { |o| !@deciphered.include?(o) }
        # pp options
        if targets.size == 1 && options.size == 1
            # puts "got a single clue, so locking in"
            key = targets.first.to_s
            @deciphered << targets.first
            @cipher[key] = [options.first].freeze
        else
            targets.each do |sym|
                key = sym.to_s
                # puts "saving clue for #{key}"
                @cipher[key] ||= []
                if @cipher[key].size > 0
                    @cipher[key] = @cipher[key] & options
                else 
                    @cipher[key] << options
                end
                @cipher[key].flatten!
                @cipher[key].sort!
                @cipher[key].uniq!            
            end
        end

        compact!

        # puts "current --------------------------"
        # pp @deciphered
        # pp @cipher
        # puts "----------------------------------"
    end

    def decipher(codes)        
        d1 = codes.select { |o| o[:digit] == 1 }&.first
        d4 = codes.select { |o| o[:digit] == 4 }&.first
        d7 = codes.select { |o| o[:digit] == 7 }&.first
        if d1 && d7
            segment_a = d7[:input].difference(d1[:input])
            add_cipher_clues(:a, segment_a)

            c_and_f = d7[:input].difference(segment_a)
            add_cipher_clues([:c, :f], c_and_f)
        end
        
        if d1 && d4 
            b_and_d = d4[:input].difference(d1[:input])
            add_cipher_clues([:b, :d], b_and_d)
        end

        decipher_5s(codes)
        decipher_6s(codes)

        compact!

        # puts "----------------------------"
        # pp @deciphered
        # puts "---"
        # pp @cipher
        # puts "----------------------------"
        @cipher
    end

    def decode_line(line)
        @cipher = %w[a b c d e f g].reduce({}) { |memo, seg| memo[seg.to_s] = []; memo }
        #pp @cipher
        @deciphered = []

        encoded = [[],[]]
        parts = line.split(/\|/, 2)  
        # first pass to determine uniques
        parts.each.with_index do |part, index|
            part.strip.split(/\s+/).each.with_index do |pattern, index2| 
                len = pattern.length
                segment = @segments[len]
                options = segment[:patterns]
                dec = encoded[index][index2] || {input: [], options: [], digit: nil}
                dec[:input] = pattern.split(//).sort
                dec[:options] = options
                if options.count == 1
                   dec[:digit] = segment[:digits].first
                end
                encoded[index][index2] = dec
            end
        end
        decipher(encoded.flatten)
        @cipher_by_value = {}
        @cipher.each { |k,v| @cipher_by_value[v.first] = k }
        pp @cipher_by_value

        input = decode(encoded[0])
        output = decode(encoded[1])
        decoded_h = {input:input, output: output, value: output.join.to_i}
        puts decoded_h
        return decoded_h
    end

    def decode(encoded_parts)
        # pp "decode", encoded_parts
        encoded_parts.map do |part|
            decoded = part[:input].map do |char|
                @cipher_by_value[char]
            end.compact.sort
            if digit = @decode_cache[decoded]
                digit
            else
                digit = DIGIT_SEGMENTS.find_index(decoded)
            end
        end
    end

    def decode_all
        @decode_cache = {}
        result = 0
        @data.each do |line|
            decoded = decode_line(line)
            result += decoded[:value]
        end

        result
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

# result = su.count_unique_outputs
# puts "Unique Output Values: #{result}"

result = su.decode_all
puts "Total: #{result}"
