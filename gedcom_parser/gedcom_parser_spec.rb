require '~/work/rubyquiz/gedcom_parser/gedcom_parser.rb'
include RubyQuiz

RSpec::Matchers.define :match_ignoring_whitespace do |expected|
  match do |actual|
    actual.gsub(/[\s\r]+/, '') == expected.gsub(/[\s\r]+/, '')
  end
end

describe GedcomParser do
  before :each do
    @parser = GedcomParser.new()
  end

  describe "#parse" do
    it "should convert from GEDCOM to XML" do
      result = @parser.parse %q{
0 @I1@ INDI
1 NAME Jamis Gordon /Buck/
2 SURN Buck
2 GIVN Jamis Gordon
1 SEX M
      }

      result.should match_ignoring_whitespace %q{
<gedcom>
  <indi id="@I1@">
    <name value="Jamis Gordon /Buck/">
      <surn>Buck</surn>
      <givn>Jamis Gordon</givn>
    </name>
    <sex>M</sex>
  </indi>
</gedcom>
      }
    end
   end
end
