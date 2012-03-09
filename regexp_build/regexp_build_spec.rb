require '~/work/rubyquiz/regexp_build/regexp_build.rb'

describe "Regexp" do
  before :each do
    @assert = ->(r, a) { a.any?  { |s| r.match(s) }.should be_true }
    @deny   = ->(r, a) { a.none? { |s| r.match(s) }.should be_true }
  end

#  it "should be able to handle a mix of integers and ranges" do
#    r = Regexp.build(1, 2, 3, 4..6, 7)
#    @assert[r, %w[ 1 2 3 4 5 6 7 ]]
#    @deny[r, %w[ 0 8 9 ]]
#  end
#
#  it "should handle double digit characters" do
#    r = Regexp.build(10..15)
#    @assert[r, %w[ 10 11 12 13 14 15 ]]
#    @deny[r, %w[ 1 2 3 4 5 ]]
#  end

  it "should handle negative numbers" do
    r = Regexp.build(-3, -4, -16)
    p sanitize r
    @assert[r, %w[ -3 -4 -16 ]]
    @deny[r, %w[3 4 16 6 1 ]]
  end

#  it "should handle a large number" do
#    r = Regexp.build(1..1_000_000)
#    p sanitize r
#    @assert[r, (1..1_000_000).map(&:to_s)]
#    @deny[r, %w[ 1000001 ]]
#  end
#
#  it "should not die" do
#    lucky = Regexp.build( 3, 7 )
#    p lucky
#    ("7"    =~ lucky).should be_true
#    ("13"   =~ lucky).should be_false
#    ("3"    =~ lucky).should be_true
#
#    month = Regexp.build( 1..12 )
#    ("0"    =~ month).should be_false
#    ("1"    =~ month).should be_true
#    ("12"   =~ month).should be_true
#
#    day = Regexp.build( 1..31 )
#    ("6"    =~ day).should be_true
#    ("16"   =~ day).should be_true
#    ("Tues" =~ day).should be_false
#
#    year = Regexp.build( 98, 99, 2000..2005 )
#    ("04"   =~ year).should be_false
#    ("2004" =~ year).should be_true
#    ("99"   =~ year).should be_true
#
#    num = Regexp.build( 0..1_000_000 )
#    ("-1"   =~ num).should be_false
#  end
end

def sanitize(s)
  s.to_s.gsub(/[()\\]/, '').gsub(/[?][^:]+[:]/, '')
end

#describe "Range" do
#  it "should convert to a regex" do
#    sanitize((13..33).to_regexp).should == '[1][3-9]|[2][0-9]|[3][0-3]'
#  end
#end
#
#describe "Fixnum" do
#  it "should round down to the nearest multiple of ten" do
#    [ 11, 25, 33, 40 ].map(&:round).should == [ 10, 20, 30, 40 ]
#  end
#end
