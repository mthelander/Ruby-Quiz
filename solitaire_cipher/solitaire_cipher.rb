module RubyQuiz
  class SolitaireCipher
    attr_reader :cards

    def initialize(message)
      @message, @cards = message, Array.new(54) do |i|
        Card.new (i%13)+1, i > 51 ? nil : i/13
      end
    end

    def encrypt
      self.process :add_keystreams
    end

    def decrypt
      self.process :subtract_keystreams
    end

    def process(process_method)
      msg = self.massage_message @message
      keystream = self.find_keystream_letters(msg.length)

      keystream, msg = [keystream, msg].map do |m|
        self.to_numbers self.groups_of_five(m).join(' ').chars.to_a
      end
      processed = self.send process_method, msg, keystream

      self.to_letters(processed).join
    end

    def massage_message(string)
      string.upcase.gsub(/[^A-Z]/, '')
    end

    def groups_of_five(string)
      string.scan(/.{1,5}/).map { |g| g.ljust(5, ?X) }
    end

    def to_numbers(arr)
      arr.map { |c| map_char c }
    end

    def to_letters(arr)
      arr.map { |c| map_char c }
    end

    def add_keystreams(m, k)
      [].tap do |result|
        0.upto(m.size-1) do |n|
          result << case
            when m[n] == ' ' || k[n] == ' '
              ' '
            when (sum = m[n] + k[n]) > 26
              sum - 26
           else
              sum
          end
        end
      end
    end

    def subtract_keystreams(m, k)
      [].tap do |result|
        0.upto(m.size-1) do |n|
          result << case
            when m[n] == ' ' || k[n] == ' '
              ' '
            when m[n] <= k[n]
              m[n] + 26 - k[n]
            else
              m[n] - k[n]
          end
        end
      end
    end

    def move_jokers
      [1, 2].each do |offset|
        from = @cards.index { |c| c.suit.nil? && c.face == offset }
        to = case @cards[from]
          when @cards[-1]
            offset
          when @cards[-2]
            offset == 1 ? from + offset : 1
          else
            from + offset
        end
        @cards.insert(to, @cards.delete_at(from))
      end
    end

    def triple_cut
      left, right = @cards.select { |c| c.suit.nil? }.map { |c| @cards.index(c) }

      @cards = @cards[right+1...@cards.size] + @cards[left..right] + @cards[0...left]
    end

    def count_cut
      @cards.insert(-2, *@cards.slice!(0, @cards.last.value))
    end

    def find_keystream_letters(n=1)
      [].tap do |result|
        until result.size == n
          %W[ move_jokers triple_cut count_cut ].each { |m| self.send(m) }
          output = @cards.take(@cards.first.value + 1).last.to_letter
          result << output unless output == ' '
        end
      end.join
    end

    def prettify
      @cards.map(&:print_value)
    end

    private
      def map_char(char)
        case char
          when 1..26
            (char + 64).chr
          when ?A..?Z
            char.ord % 64
          else
            char
        end
      end
  end

  class Card
    attr_reader :face, :suit

    def initialize(face, suit)
      @face, @suit = face, suit
    end

    def print_value
      @print_value ||= (@suit.nil? ? (@face + 64).chr : @face + (@suit * 13))
    end

    def value
      @value ||= (@suit.nil? ? 53 : @face + (@suit * 13))
    end

    def to_letter
      @letter ||= self.suit.nil? ? ' ' : (self.value - (@suit > 1 ? 26 : 0) + 64).chr
    end
  end
end
