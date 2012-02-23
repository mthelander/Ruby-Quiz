require '~/work/rubyquiz/secret_santas/secret_santa_chooser.rb'
require 'optparse'

lines = []
OptionParser.new do |opts|
  opts.on('-n', '--name NAME') do |line|
    unless /([^ ]+) +([^ ]+) +<([^>]+)>/ =~ line
      raise "Invalid name. Must be of the form FIRST_NAME LAST_NAME <EMAIL>"
    end
    lines << line
  end 
end.parse!

choices = RubyQuiz::SecretSantaChooser.choose_secret_santas lines
0.upto(choices.size - 1) do |n|
  a, b = choices[n], choices[(n+1)%choices.size]
  puts "#{a}'s secret santa is #{b}"
end
