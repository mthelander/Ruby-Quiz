module RubyQuiz
  class SecretSantaChooser
    class << self
      def choose_secret_santas(lines)
        lines.map!(&:strip).reject!(&:empty?)
        people = lines.map { |l| Name.new(l) }
        if people.group_by(&:family).max.last.size > (people.size / 2)
          raise "Not enough distinct families!"
        end

        people.shuffle! until people.all? do |person|
          people[(people.index(person) + 1) % people.size] != person
        end

        people
      end
    end
  end

  class Name
    attr_reader :first, :family, :email

    def initialize(line)
      /([^ ]+) +([^ ]+) +<([^>]+)>/.match(line) do |m|
        @first, @family, @email = m.captures
      end
    end

    def to_s
      "#@first #@family"
    end

    def ==(name)
      @family == name.family
    end
  end
end
