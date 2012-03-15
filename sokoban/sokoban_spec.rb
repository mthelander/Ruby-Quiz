require '~/work/rubyquiz/sokoban/sokoban_interface.rb'
include RubyQuiz

RSpec::Matchers.define :be_the_same_template do |expected|
  match do |actual|
    r = expected.split(?\n).reject(&:empty?)

    actual == r.map do |s|
      s.ljust(r.max.length, ?\s)
    end.join(?\n)
  end
end

describe Level do
  before :each do
    @template = %q{
########
# .o   #
#   @  #
#      #
########
    }
  end
  describe "#to_s" do
    it "should convert back to a string" do
      level = Level.new(@template)
      level.to_s.should be_the_same_template(@template)
    end

    it "should die if there is more than one man character" do
      -> { Level.new(@template.insert(0, ?@)) }.should raise_error 'Only one man allowed'
    end
  end

  describe "#move" do
    before :each do
      @level = Level.new(@template)
    end

    it "should move up" do
      @level.move(:up)
      @level.to_s.should be_the_same_template %q{
########
# .o@  #
#      #
#      #
########
      }
    end

    it "should move down" do
      @level.move(:down)
      @level.to_s.should be_the_same_template %q{
########
# .o   #
#      #
#   @  #
########
      }
    end

    it "should move left" do
      @level.move(:left)
      @level.to_s.should be_the_same_template %q{
########
# .o   #
#  @   #
#      #
########
      }
    end

    it "should move right" do
      @level.move(:right)
      @level.to_s.should be_the_same_template %q{
########
# .o   #
#    @ #
#      #
########
      }
    end

    it "should not be able to go through walls" do
      temp = %q{
########
# .o   #
#     @#
#      #
########
      }
      2.times { @level.move(:right) }
      @level.to_s.should be_the_same_template temp
      @level.move(:right)
      @level.to_s.should be_the_same_template temp
    end

    it "should push crates" do
      %w[ up left ].each { |d| @level.move(d.to_sym) }
      @level.to_s.should be_the_same_template %q{
########
# *@   #
#      #
#      #
########
      }
    end

    it "should not be able to push a crate through a wall" do
      puts "#@level"
      %w[ left up ].each { |d| @level.move(d.to_sym) }
      puts "#@level"
      @level.to_s.should be_the_same_template %q{
########
# .o   #
#  @   #
#      #
########
      }
    end
  end

  describe "#get_next_point" do
    it "should get the next point" do
      l = Level.new(@template)
      l.get_next_point(Vector[5, 6], Vector[5, 7]).should == Vector[5, 8] # down
      l.get_next_point(Vector[5, 6], Vector[6, 6]).should == Vector[7, 6] # right
      l.get_next_point(Vector[5, 6], Vector[4, 6]).should == Vector[3, 6] # left
      l.get_next_point(Vector[5, 6], Vector[5, 5]).should == Vector[5, 4] # up
    end
  end

  it "should die if we give it an invalid template" do
    -> {
      Level.new("@o# .. o@#% ")
    }.should raise_error("Invalid token in template: %")
  end
end
