module RubyQuiz
  class Countdown
    attr_reader :tree

    def initialize(target, source)
      @target, @source, = target.to_f, source.map(&:to_f)

      @tree = Node.new(0, :+)
      @source.product([:+]).each do |n|
        next unless should_continue?(n)
        @tree << build(Node.new(*n), @source)
      end
    end

    def operators
      @operators ||= [:+, :-, :*, :/]
    end

    def build(node, possibilities, depth = 1)
      node.tap do |node|
        sub_possibilities = possibilities.reject { |n| n == node.value }
        return node if sub_possibilities.empty?
        sub_possibilities.product(operators()) do |p|
          next unless should_continue?(p)
          node <<  build(Node.new(p.first, p.last), sub_possibilities, depth + 1)
        end
      end
    end

    def should_continue?(p)
      return false if p.empty?
      case p.first
        when 1 then ![:*, :/].include?(p.last)
        when 0 then ![:-, :+].include?(p.last)
        else true
      end
    end

    def evaluate(solution, depth = 0)
      while (i = solution.rindex(?())
        j = solution[i..solution.size-1].index(?))
        solution[i..j] = _eval(solution[i+1..j-1])
      end
      _eval(reduce(solution))
    end

    def _eval(solution)
      solution = reduce(solution)
      op = :+
      solution.reduce(0) do |result, term|
        case term
          when Fixnum then result = result.send(op, term)
          when Symbol then op = term; result
        end
      end
    end

    def reduce(terms)
      0.upto(terms.size) do |i|
        a, op, b = terms[i..i+2]
        if [:*, :/].include?(op)
          terms[i..i+2] = a.send(op, b)
        end
      end

      terms
    end

    def solve
      find_solution(@tree, '')
    end

    def find_solution(node, solution, depth = 0)
      solution.chop! if solution =~ /.*[-+*\/]$/
      return solution if valid_solution?(solution)

      node.children.each do |child|
        parenthesized = solution.empty? ? '' : "(#{solution})"
        s = find_solution(child, child.term + parenthesized, depth + 1)
        return s if valid_solution?(s)
      end

      solution
    end

    def valid_solution?(expression)
      eval(expression) == @target
    end
  end

  class Node
    attr_accessor :children, :visited
    attr_reader :value, :op

    def initialize(value, op, children = [])
      @value, @op, @children = value, op, children
    end

    def <<(node)
      @children << node
    end

    def to_s
      "#@op #@value [ #@children ]"
    end

    def term
      "#@value#@op"
    end
  end
end
