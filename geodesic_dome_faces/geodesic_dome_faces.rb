require 'matrix'

module RubyQuiz
  class GeodesicDomeFaces
    attr_reader :primitive, :face, :points

    def initialize(primitive, face)
      @primitive, @face = Shapes.primitives[primitive], face
      unless @primitive[:faces].include? @face
        raise "#@face is an invalid face for #@primitive"
      end
      @points = @primitive[:points].values_at(*@face.split(''))
    end

    def geodesic_dome(f)
      points = self.get_points(f)
    end

    def divide_points(f)
      @vertex_points = {}
      [].tap do |points|
        @points.combination(2) do |a, b|
          (1..f).each do |n|
            o = (n / (f + 1.0)).rationalize
            points << ((a - (a * o)) + (b * o))
          end
        end
      end
    end

    def draw_lines(p)
      [].tap do |lines|
        @vertex_points.keys.combination(2) do |k|
          points = @vertex_points[k]
          #lines << points if
        end
      end
    end
  end

  class Point < Vector
    def distance(p)
      (self - p).map { |n| n**2 }.inject(&:+)**0.5
    end

    def to_s
      "(#{self.to_a * ?,})"
    end
  end

class Shapes
    SQRT2 = Math.sqrt(2)
    SQRT3 = Math.sqrt(3)
    TETRA_Q = SQRT2 / 3
    TETRA_R = 1.0 / 3
    TETRA_S = SQRT2 / SQRT3
    TETRA_T = 2 * SQRT2 / 3
    GOLDEN_MEAN = (Math.sqrt(5)+1)/2

    class << self
      def primitives
        @@primitives ||= Hash[
          :tetrahedron => {
            :points => {
              'a' => Point[ -TETRA_S, -TETRA_Q, -TETRA_R ],
              'b' => Point[  TETRA_S, -TETRA_Q, -TETRA_R ],
              'c' => Point[        0,  TETRA_T, -TETRA_R ],
              'd' => Point[        0,        0,        1 ],
            },
            :faces => %w[
              acb abd adc dbc
            ],
          },
          :octahedron => {
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
            ],
          },
          :icosahedron => {
            :points => {
              'a' => Point[  1,  GOLDEN_MEAN, 0 ],
              'b' => Point[  1, -GOLDEN_MEAN, 0 ],
              'c' => Point[ -1, -GOLDEN_MEAN, 0 ],
              'd' => Point[ -1,  GOLDEN_MEAN, 0 ],
              'e' => Point[  GOLDEN_MEAN, 0,  1 ],
              'f' => Point[ -GOLDEN_MEAN, 0,  1 ],
              'g' => Point[ -GOLDEN_MEAN, 0, -1 ],
              'h' => Point[  GOLDEN_MEAN, 0, -1 ],
              'i' => Point[ 0,  1,  GOLDEN_MEAN ],
              'j' => Point[ 0,  1, -GOLDEN_MEAN ],
              'k' => Point[ 0, -1, -GOLDEN_MEAN ],
              'l' => Point[ 0, -1,  GOLDEN_MEAN ],
            },
            :faces => %w[
              iea iad idf ifl ile
              eha ajd dgf fcl lbe
              ebh ahj djg fgc lcb
              khb kjh kgj kcg kbc
            ],
          }
        ]
      end
    end
  end
end
