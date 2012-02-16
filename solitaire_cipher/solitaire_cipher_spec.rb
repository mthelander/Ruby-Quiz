require '~/work/rubyquiz/solitaire_cipher.rb'

describe "SolitaireCipher" do
  describe "with a default cipher" do
    before(:each) do
      @cipher = RubyQuiz::SolitaireCipher.new("this is a test message")
    end

    it 'should strip out invalid characters and uppercase the rest' do
      @cipher.massage_message("this is a test message").should == "THISISATESTMESSAGE"
    end

    it 'should group by 5 characters and pad with X' do
      @cipher.groups_of_five("THISISATESTMESSAGE").should == %W[
        THISI
        SATES
        TMESS
        AGEXX
      ]
    end

    it 'should convert chars to numbers' do
      @cipher.to_numbers("ABC DEF".split '').should == [1, 2, 3, ' ', 4, 5, 6]
    end

    it 'should convert numbers to chars' do
      arr = @cipher.to_numbers "ABC DEF".split('')
      @cipher.to_letters(arr).should == [ ?A, ?B, ?C, ' ', ?D, ?E, ?F ]
    end

    it 'should be able to add to keystreams' do
      m = [ 3, 15,  4,  5, 9, ' ', 14, 18, 21, 2, 25, ' ', 12,  9, 22, 5, 12, ' ', 15, 14,  7,  5, 18 ]
      k = [ 4, 23, 10, 24, 8, ' ', 25, 18,  6, 4,  7, ' ', 20, 13, 19, 8, 16, ' ', 21, 21, 18, 24, 10 ]

      arr = @cipher.add_keystreams(m, k)
      arr.should == [ 7, 12, 14, 3, 17, ' ', 13, 10, 1, 6, 6, ' ', 6, 22, 15, 13, 2, ' ', 10, 9, 25, 3, 2 ]
    end

    it 'should be able to subtract to keystreams' do
      m = [ 7, 12, 14, 3, 17, ' ', 13, 10, 1, 6, 6, ' ',  6, 22, 15, 13, 2, ' ', 10, 9,  25,  3, 2  ]
      k = [ 4, 23, 10, 24,8,  ' ', 25, 18, 6, 4, 7, ' ', 20, 13, 19, 8,  16,' ', 21, 21, 18, 24, 10 ]

      arr = @cipher.subtract_keystreams(m, k)
      arr.should == [ 3, 15, 4, 5, 9, ' ', 14, 18, 21, 2, 25, ' ', 12, 9, 22, 5, 12, ' ', 15, 14, 7, 5, 18 ]
    end

    it 'should have 52 regular cards and the jokers' do
      @cipher.cards.map(&:face).should == (1..13).to_a + (1..13).to_a + (1..13).to_a + (1..13).to_a + [1, 2]
      @cipher.cards.map(&:suit).uniq.should == [ 0, 1, 2, 3, nil ]
      @cipher.cards.map { |c| [c.face, c.suit] }.should =~ [
        [ 1,  0 ], [ 1,  1 ], [ 1,  2 ], [ 1,  3 ], [ 1, nil ],
        [ 2,  0 ], [ 2,  1 ], [ 2,  2 ], [ 2,  3 ], [ 2, nil ],
        [ 3,  0 ], [ 3,  1 ], [ 3,  2 ], [ 3,  3 ],
        [ 4,  0 ], [ 4,  1 ], [ 4,  2 ], [ 4,  3 ],
        [ 5,  0 ], [ 5,  1 ], [ 5,  2 ], [ 5,  3 ],
        [ 6,  0 ], [ 6,  1 ], [ 6,  2 ], [ 6,  3 ],
        [ 7,  0 ], [ 7,  1 ], [ 7,  2 ], [ 7,  3 ],
        [ 8,  0 ], [ 8,  1 ], [ 8,  2 ], [ 8,  3 ],
        [ 9,  0 ], [ 9,  1 ], [ 9,  2 ], [ 9,  3 ],
        [ 10, 0 ], [ 10, 1 ], [ 10, 2 ], [ 10, 3 ],
        [ 11, 0 ], [ 11, 1 ], [ 11, 2 ], [ 11, 3 ],
        [ 12, 0 ], [ 12, 1 ], [ 12, 2 ], [ 12, 3 ],
        [ 13, 0 ], [ 13, 1 ], [ 13, 2 ], [ 13, 3 ],
      ]
    end

=begin
  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13,
  14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
  27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
  40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52,
  ?A, ?B
=end
    it 'should be able to move the jokers around' do
      @cipher.move_jokers

      @cipher.prettify.should == [
        1,  ?B, 2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12,
        13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
        26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38,
        39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
        52, ?A
      ]

      3.times { @cipher.move_jokers }

      @cipher.prettify.should == [
        1,  2,  3,  ?A, 4,  5,  6,  7,  ?B, 8,  9,  10, 11,
        12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
        25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
        38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
        51, 52,
      ]
    end

    it 'should do a triple cut' do
      @cipher.triple_cut
      @cipher.prettify.should == [
        ?A, ?B,
        1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13,
        14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
        27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52,
      ]
    end

    it 'should do a count cut' do
      2.times { @cipher.move_jokers }

      @cipher.prettify.should == [
        1,  ?A, 2,  3,  ?B, 4,  5,  6,  7,  8,  9,  10, 11,
        12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
        25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37,
        38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
        51, 52,
      ]

      @cipher.count_cut

      @cipher.prettify.should == [
        51, 1,  ?A, 2,  3,  ?B, 4,  5,  6,  7,  8,  9,  10,
        11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
        24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
        37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
        50, 52,
      ]
    end
  end

  it 'should be able to decrypt a message' do
    ciphertext = "CLEPK HHNIY CFPWH FDFEH"
    cipher = RubyQuiz::SolitaireCipher.new ciphertext
    cipher.decrypt.should == "YOURC IPHER ISWOR KINGX"

    ciphertext = "ABVAW LWZSY OORYK DUPVH"
    cipher = RubyQuiz::SolitaireCipher.new ciphertext
    cipher.decrypt.should == "WELCO METOR UBYQU IZXXX"
  end

  it 'should be able to encrypt a message' do
    ciphertext = "YOURC IPHER ISWOR KINGX"
    cipher = RubyQuiz::SolitaireCipher.new ciphertext
    cipher.encrypt.should == "CLEPK HHNIY CFPWH FDFEH"

    ciphertext = "WELCO METOR UBYQU IZXXX"
    cipher = RubyQuiz::SolitaireCipher.new ciphertext
    cipher.encrypt.should == "ABVAW LWZSY OORYK DUPVH"
  end
end

describe "Cards" do
  it "should convert to a letter" do
    0.upto(1) do |suit|
      1.upto(13) do |face|
        c = RubyQuiz::Card.new face, suit
        c.to_letter.should == (face + suit * 13 + 64).chr
      end
    end
    2.upto(3) do |suit|
      1.upto(13) do |face|
        c = RubyQuiz::Card.new face, suit
        c.to_letter.should == (face + suit * 13 + 64 - 26).chr
      end
   end
  end

  it "should generate spaces for jokers" do
    c = RubyQuiz::Card.new(1, nil)
    c.to_letter.should == ' '
  end
end
