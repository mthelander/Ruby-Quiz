module RubyQuiz
  def Regexp.build(*args)
    a = args.map do |n|
      n.is_a?(Range) ? n.to_a : n
    end.flatten.partition do |n|
      n < 0
    end.map(&:sort).map(&:reverse).flatten
    /(#{a*?|})/
  end
end
