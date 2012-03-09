class Regexp
  def self.build(*args)
    a = args.group_by(&:class)
    integers, ranges = a[Fixnum] || [], a[Range] || []
    Regexp.union(*ranges.map(&:to_r), *integers.sort.reverse.map(&:to_r))
  end
end

class Range
  def to_r
    max_length = self.last.to_s.size
    first, last = self.first, self.last
    left, right = [ first.round + 10, first ].min, [ last.round, last ].max

    #p "first: #{first}, last: #{last}, left: #{left}, right: #{right}"
    #p "#{first..left-1}, #{left..right}, #{right+1..last}"
    Regexp.union([first..left-1, left..right, right+1..last].map(&:_to_r).compact)
  end

  def _to_r
    return nil if self.to_a.empty?
    max_length, $; = self.last.to_s.size, ''
    a, b = [ self.first, self.last ].map do |n|
      n.to_s.rjust(max_length, ?0).split.map(&:to_i)
    end

    Regexp.compile("^#{a.zip(b).map(&:to_r).join}$")
  end
end

class Array
  def to_r
    case
      when self.first == self.last
        self.first.to_r(false)
      #when (0..9) === self.first && (0..9) === self.last
      #  "^[#{self.first}-#{self.last}]$"
      else
        "[#{[self.first, self.last]*?-}]"
    end
  end
end

class Fixnum
  def round
    self - (self % 10)
  end

  def to_r(wrap=true)
    l, r = wrap ? ['^[', ']$' ] : [ ?[, ?] ]
    l.insert(1, ?-) if self < 0
    l + self.abs.to_s + r
  end
end
