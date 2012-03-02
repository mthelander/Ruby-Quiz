require '~/work/rubyquiz/geodesic_dome_faces/geodesic_dome_faces.rb'
include RubyQuiz

describe GeodesicDomeFaces do
  before(:each) do
    @g = GeodesicDomeFaces.new(:octahedron, 'def')
  end

  describe "#initialize" do
    it "should use the shapes class" do
      @g = GeodesicDomeFaces.new(:octahedron, 'def')
      @g.primitive.should == {
        :points => {
          'a' => Point[  0,  0,  1 ],
          'b' => Point[  1,  0,  0 ],
          'c' => Point[  0, -1,  0 ],
          'd' => Point[ -1,  0,  0 ],
          'e' => Point[  0,  1,  0 ],
          'f' => Point[  0,  0, -1 ],
        },
        :faces => %w[
          cba dca eda bea
          def ebf bcf cdf
        ]
      }

      @g.points.map(&:to_a).should == [
        [ -1,  0,  0 ],
        [  0,  1,  0 ],
        [  0,  0, -1 ],
      ]
    end
  end

  describe "#divide_points" do
    it "should get 1 point" do
      a = (1/2.0).rationalize
      @g.divide_points(1).map(&:to_a).should =~ [
        [ -a, a,  0 ],
        [ -a, 0, -a ],
        [  0, a, -a ],
      ]
    end

    it "should get 2 points" do
      a, b = [1/3.0, 2/3.0].map(&:rationalize)

      @g.divide_points(2).map(&:to_a).should =~ [
        [ -b, a,  0 ],
        [ -a, b,  0 ],
        [ -b, 0, -a ],
        [ -a, 0, -b ],
        [  0, b, -a ],
        [  0, a, -b ],
      ]
    end

    it "should get 3 points" do
      a, b, c = 0.25, 0.50, 0.75

      @g.divide_points(3).map(&:to_a).should =~ [
        [ -c, a,  0 ],
        [ -b, b,  0 ],
        [ -a, c,  0 ],
        [ -c, 0, -a ],
        [ -b, 0, -b ],
        [ -a, 0, -c ],
        [  0, c, -a ],
        [  0, b, -b ],
        [  0, a, -c ],
      ]
    end
  end
end

describe Point do
  before(:each) do
    @x, @y = Point[1, 2, 3], Point[4, 5, 6]
  end

  describe "#distance" do
    it "should calculate the distance between two points" do
      @x.distance(@y).should == Math.sqrt(27)
    end
  end
end
