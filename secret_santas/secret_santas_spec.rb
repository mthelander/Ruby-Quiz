require '~/work/rubyquiz/secret_santas/secret_santa_chooser.rb'

describe "Name" do
  before(:each) do
      @name = RubyQuiz::Name.new("Michael Thelander <mjt@rentrakmail.com>")
      @expected = {
        "first"  => "Michael",
        "family" => "Thelander",
        "email"  => "mjt@rentrakmail.com"
      }
  end

  %W[ first family email ].each do |method|
    it "should have a #{method}" do
      @name.send(method).should == @expected[method]
    end
  end
end

describe "SecretSantaChooser" do
  it "should die if we don't have enough options to choose from" do
    -> {
      RubyQuiz::SecretSantaChooser.choose_secret_santas(%q{
        Luke Skywalker   <luke@theforce.net>
        Leia Skywalker   <leia@therebellion.org>
        Toula Portokalos <toula@manhunter.org>
      }.split("\n"))
    }.should raise_error("Not enough distinct families!")
  end

  it "should not die if we have enough options to choose from" do
    -> {
      RubyQuiz::SecretSantaChooser.choose_secret_santas(%q{
        Luke Skywalker   <luke@theforce.net>
        Leia Skywalker   <leia@therebellion.org>
        Toula Portokalos <toula@manhunter.org>
        Gus Portokalos   <gus@weareallfruit.net>
      }.split("\n"))
    }.should_not raise_error("Not enough distinct families!")
  end

  it "should choose secret santas" do
    stdin = %q{
      Luke Skywalker   <luke@theforce.net>
      Leia Skywalker   <leia@therebellion.org>
      Toula Portokalos <toula@manhunter.org>
      Gus Portokalos   <gus@weareallfruit.net>
      Bruce Wayne      <bruce@imbatman.com>
      Virgil Brigman   <virgil@rigworkersunion.org>
      Lindsey Brigman  <lindsey@iseealiens.net>
    }.split("\n")

    choices = RubyQuiz::SecretSantaChooser.choose_secret_santas(stdin)
    1.upto(choices.size - 1) do |n|
      a, b = choices[n], choices[(n+1)%choices.size]
      a.family.should_not == b.family
    end
  end

  it "should parse out standard in from the user" do
    stdin = %q{
      --name "Luke Skywalker   <luke@theforce.net>"
      --name "Leia Skywalker   <leia@therebellion.org>"
      --name "Toula Portokalos <toula@manhunter.org>"
      --name "Gus Portokalos   <gus@weareallfruit.net>"
      --name "Bruce Wayne      <bruce@imbatman.com>"
      --name "Virgil Brigman   <virgil@rigworkersunion.org>"
      --name "Lindsey Brigman  <lindsey@iseealiens.net>"
    }.split("\n").join ' '
    output = `ruby ~/work/rubyquiz/secret_santas/secret_santas.rb #{stdin}`
    output.split("\n").size.should == 7
    puts output
  end
end
