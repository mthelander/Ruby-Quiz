require '~/work/rubyquiz/countdown/countdown.rb'
require 'benchmark'
include RubyQuiz

describe Countdown do
  describe '#build' do
    it 'should build a tree' do
      countdown = Countdown.new(3, [1, 2])
      countdown.tree.should.to_s == Node.new(0, :+, [
        [ 1.0, :+, [ Node.new(2.0, :+), Node.new(2.0, :-), Node.new(2.0, :*), Node.new(2.0, :/) ] ],
        [ 2.0, :+, [ Node.new(1.0, :+), Node.new(1.0, :-), Node.new(1.0, :*), Node.new(1.0, :/) ] ],
      ]).to_s
    end
  end

  describe '#solve' do
    it 'should calculate a solution' do
      target = 522
      countdown = Countdown.new(target, [100, 5, 5, 2, 6, 8])
      solution = countdown.solve
      p solution
      solution.should_not be_nil
      eval(solution).should == target
    end
  end

  describe '#evaluate' do
    it 'should evaluate an expression faster than eval' do
      countdown = Countdown.new(3, [1, 3])
      countdown.evaluate([3, :+, 9]).should == 12
      countdown._eval([3, :+, 9]).should == 12
      countdown.evaluate([?(, 3, :+, 9, ?), :*, 12]).should == 144
      time = Benchmark.realtime do
        1000.times { countdown.evaluate([?(, 3, :+, 9, ?), :*, 12]) }
      end
      puts "Countdown#evaluate time: #{time}ms"

      time = Benchmark.realtime do
        1000.times { eval "(3+9)*12" }
      end
      puts "eval time: #{time}ms"
    end
  end

  describe '#reduce' do
    it 'should eliminate multiplication and division' do
      countdown = Countdown.new(3, [1, 3])
      countdown.reduce([3, :+, 8, :*, 9, :+, 2, :/, 2]).should == [3, :+, 72, :+, 1]
    end
  end
end
