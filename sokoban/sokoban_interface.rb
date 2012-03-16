require 'matrix'

module RubyQuiz
  MAN               = ?@
  CRATE             = ?o
  WALL              = ?#
  FLOOR             = ?\s
  STORAGE           = ?.
  CRATE_ON_STORAGE  = ?*
  MAN_ON_STORAGE    = ?+

  DIRECTIONS = {
    up:    Vector[-1,  0],
    down:  Vector[ 1,  0],
    left:  Vector[ 0, -1],
    right: Vector[ 0,  1]
  }

  MOVEMENT_KEYS = {
    "A" => :up,
    "B" => :down,
    "D" => :left,
    "C" => :right,
    "k" => :up,
    "j" => :down,
    "h" => :left,
    "l" => :right
  }

  class SokobanInterface
    def initialize(template, title='')
      @level, @template, @title = Level.new(template), template, title
    end

    def get_input
      system "clear"
      self.draw
      system "stty raw -echo"
      STDIN.getc
    end

    def play
      until @level.won?
        begin
          str = self.get_input
          return false if str == ?q
          @level = Level.new(@template) if str == ?r
          movement = MOVEMENT_KEYS[str]
          @level.move(movement) unless movement.nil?
        ensure
          system "stty -raw echo"
        end
      end
      self.display

      true
    end

    def draw
      system "clear"
      puts "#@title\n#@level"
    end
  end

  class Level
    attr_reader :static, :moveable

    def initialize(template)
      validate_template template
      @static, @moveable = build_level(template)
    end

    def build_level(template)
      s_temp = template.gsub(/[#{moveable_tokens.join}]/, FLOOR => FLOOR, MAN  => FLOOR, CRATE   => FLOOR, MAN_ON_STORAGE => STORAGE, CRATE_ON_STORAGE => STORAGE)
      d_temp = template.gsub(/[#{static_tokens.join}]/,   FLOOR => FLOOR, WALL => FLOOR, STORAGE => FLOOR, MAN_ON_STORAGE => MAN,     CRATE_ON_STORAGE => CRATE)

      [ self.template_to_matrix(s_temp), self.template_to_matrix(d_temp) ]
    end

    def move(direction)
      from = Vector[*current_location]
      to   = from + DIRECTIONS[direction]

      if valid_move?(to)
        prev_to = @moveable[*to]
        @moveable[*to] = MAN
        @moveable[*from] = FLOOR
        @moveable[*get_next_point(from, to)] = CRATE if prev_to == CRATE
      end
    end

    def valid_move?(point)
      row, col = *point
      cell = @static[row, col]

      return false if cell == WALL
      return true if (cell == STORAGE || cell == FLOOR) && @moveable[row, col] != CRATE

      next_point = get_next_point(Vector[*current_location()], point)

      @static[*next_point] != WALL && @moveable[*next_point] != CRATE
    end

    def get_next_point(a, b)
      b + (b - a)
    end

    def current_location
      @moveable.index(MAN)
    end

    def to_s
      (@static + @moveable).row_vectors.map(&:to_a).map(&:join).join(?\n)
    end

    def won?
      template = self.to_s

      template.count(STORAGE) == 0 && template.count(MAN_ON_STORAGE) == 0
    end

    def valid_chars
      static_tokens | moveable_tokens
    end

    def static_tokens
      [ WALL, FLOOR, STORAGE ] + multi_tokens
    end

    def moveable_tokens
      [ MAN, CRATE ] + multi_tokens
    end

    def multi_tokens
      [ MAN_ON_STORAGE, CRATE_ON_STORAGE ]
    end

    def template_to_matrix(template)
      rows = template.split(?\n).reject(&:empty?)
      max_width = rows.max.length
      g = rows.map do |row|
        row.ljust(max_width, ?\s).split('').map { |c| Token.new(c) }
      end

      Matrix[*g]
    end

    def validate_template(template)
      if template =~ /([^#{self.valid_chars.join}\n])/
        raise "Invalid token in template: #{$1}"
      end
      raise 'Only one man allowed' unless (template.count(MAN) + template.count(MAN_ON_STORAGE)) == 1
      s, ms, c, cs = [ STORAGE, MAN_ON_STORAGE, CRATE, CRATE_ON_STORAGE ].map { |s| template.count(s) }
      raise "Not enough #{STORAGE}!" unless (s + ms) == (c + cs)
    end
  end

  class Token
    def initialize(char)
      @char = char
    end

    def +(other)
      s = other.to_s
      case
        when [ @char, s ].sort == [ STORAGE, MAN ]
          MAN_ON_STORAGE
        when [ @char, s ].sort == [ STORAGE, CRATE ]
          CRATE_ON_STORAGE
        else
          s == FLOOR ? @char : s
      end
    end

    def to_s
      "#@char"
    end

    def ===(other)
      self == other
    end

    def ==(other)
      case other
        when Token
          @char == other.to_s
        when String
          @char == other
        else
          raise InvalidArgumentException
      end
    end
  end
end

class Matrix
  def []=(row, col, value)
    @rows[row][col] = value
  end
end
