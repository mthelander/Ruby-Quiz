require '~/work/rubyquiz/regexp_build/regexp_build.rb'
include RubyQuiz

describe "Regexp" do
  before :each do
    @assert = ->(r, a) { a.any?  { |s| r.match(s) }.should be_true }
    @deny   = ->(r, a) { a.none? { |s| r.match(s) }.should be_true }
  end

  it "should be able to handle a mix of integers and ranges" do
    r = Regexp.build(1, 2, 3, 4..6, 7)
    @assert[r, %w[ 1 2 3 4 5 6 7 ]]
    @deny[r, %w[ 0 8 9 ]]
  end

  it "should handle double digit characters" do
    r = Regexp.build(10..15)
    @assert[r, %w[ 10 11 12 13 14 15 ]]
    @deny[r, %w[ 1 2 3 4 5 ]]
  end

  it "should handle negative numbers" do
    r = Regexp.build(-3, -4, -16)
    @assert[r, %w[ -3 -4 -16 ]]
    @deny[r, %w[3 4 16 6 1 ]]
  end
end
