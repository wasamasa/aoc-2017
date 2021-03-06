require_relative 'util'

# --- Day 3: Spiral Memory ---
#
# You come across an experimental new kind of memory stored on an
# infinite two-dimensional grid.
#
# Each square on the grid is allocated in a spiral pattern starting at
# a location marked 1 and then counting up while spiraling
# outward. For example, the first few squares are allocated like this:
#
# 17  16  15  14  13
# 18   5   4   3  12
# 19   6   1   2  11
# 20   7   8   9  10
# 21  22  23---> ...
#
# While this is very space-efficient (no squares are skipped),
# requested data must be carried back to square 1 (the location of the
# only access port for this memory system) by programs that can only
# move up, down, left, or right. They always take the shortest path:
# the Manhattan Distance between the location of the data and square
# 1.
#
# For example:
#
# - Data from square 1 is carried 0 steps, since it's at the access
#   port.
# - Data from square 12 is carried 3 steps, such as: down, left, left.
# - Data from square 23 is carried only 2 steps: up twice.
# - Data from square 1024 must be carried 31 steps.
#
# How many steps are required to carry the data from the square
# identified in your puzzle input all the way to the access port?
#
# Your puzzle input is 312051.

input = 312_051

def spiral_iterator
  Enumerator.new do |y|
    directions = [:east, :north, :west, :south].cycle
    steps = 1
    loop do
      direction = directions.next
      steps.times { y << direction }
      direction = directions.next
      steps.times { y << direction }
      steps += 1
    end
  end
end

class Swiper
  def initialize
    @i = 1
    @x = 0
    @y = 0
  end

  def walk(direction)
    case direction
    when :east  then @x += 1
    when :north then @y += 1
    when :west  then @x -= 1
    when :south then @y -= 1
    end
    @i += 1
  end

  def spiral(n)
    iter = spiral_iterator
    walk(iter.next) while @i != n
    [@x, @y]
  end
end

def easy(n)
  swiper = Swiper.new
  x, y = swiper.spiral(n)
  x.abs + y.abs
end

assert(easy(1) == 0)
assert(easy(12) == 3)
assert(easy(23) == 2)
assert(easy(1024) == 31)
puts "easy(input): #{easy(input)}"

# --- Part Two ---

# As a stress test on the system, the programs here clear the grid and
# then store the value 1 in square 1. Then, in the same allocation
# order as shown above, they store the sum of the values in all
# adjacent squares, including diagonals.

# So, the first few squares' values are chosen as follows:

# - Square 1 starts with the value 1.
# - Square 2 has only one adjacent filled square (with value 1), so it
#   also stores 1.
# - Square 3 has both of the above squares as neighbors and stores the
#   sum of their values, 2.
# - Square 4 has all three of the aforementioned squares as neighbors
#   and stores the sum of their values, 4.
# - Square 5 only has the first and fourth squares as neighbors, so it
#   gets the value 5.

# Once a square is written, its value does not change. Therefore, the
# first few squares would receive the following values:

# 147  142  133  122   59
# 304    5    4    2   57
# 330   10    1    1   54
# 351   11   23   25   26
# 362  747  806--->   ...

# What is the first value written that is larger than your puzzle
# input?

# Your puzzle input is still 312051.

class StressTestSwiper < Swiper
  def initialize
    super
    @seen = Hash.new { |h, k| h[k] = 0 }
    @seen[[0, 0]] = 1
  end

  def neighbor_sum
    @seen[[@x - 1, @y - 1]] + @seen[[@x, @y - 1]] + @seen[[@x + 1, @y - 1]] +
    @seen[[@x - 1, @y]]                           + @seen[[@x + 1, @y]] +
    @seen[[@x - 1, @y + 1]] + @seen[[@x, @y + 1]] + @seen[[@x + 1, @y + 1]]
  end

  def walk(direction)
    super
    @seen[[@x, @y]] = neighbor_sum
  end

  def spiral(n)
    iter = spiral_iterator
    walk(iter.next) until @seen[[@x, @y]] > n
    @seen[[@x, @y]]
  end
end

def hard(n)
  swiper = StressTestSwiper.new
  swiper.spiral(n)
end

assert(hard(1) == 2)
assert(hard(5) == 10)
assert(hard(23) == 25)
assert(hard(23) == 25)
assert(hard(150) == 304)
assert(hard(750) == 806)
puts "hard(input): #{hard(input)}"
