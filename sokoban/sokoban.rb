require '~/work/rubyquiz/sokoban/sokoban_interface.rb'
include RubyQuiz

start, levels = ARGV.first.to_i, []

File.open("levels.txt") do |fh|
  while level = fh.gets('')
    levels << level
  end
end

current_level = start == 0 ? 1 : start
levels.each do |level|
  sokoban = SokobanInterface.new(level, "-=-= Level #{current_level} =-=-")
  if sokoban.play
    puts "YOU WON!"
  else
    puts "EPIC FAIL!"
    break
  end
  current_level += 1
end
