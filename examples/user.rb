# frozen_string_literal: true

# rbs_inline: enabled

# Example class
class User
  attr_reader :email, :name, :nick

  # @rbs email: String
  # @rbs tel: (nil | String)
  # @rbs name: (nil | String)
  # @rbs nick: (nil | String)
  # @rbs return: void
  def initialize(email, tel = nil, name: nil, nick: nil)
    @email = email
    @tel = tel
    @name = name
    @nick = nick
  end
end

# Example class
class Pos
  attr_reader :x, :y, :z

  # @rbs x: Integer
  # @rbs y: Integer
  # @rbs z: Integer
  # @rbs return: void
  def initialize(x, y, z = 0)
    @x = x
    @y = y
    @z = z
  end

  # @rbs (Pos) -> Integer
  #    | (Integer) -> Pos
  def *(*args)
    case args
    in [Pos]
      _mul__overload0(*args)
    in [Integer]
      _mul__overload1(*args)
    end
  end

  # @rbs other: Pos
  # @rbs return: Integer
  def _mul__overload0(other)
    (@x * other.x) + (@y * other.y) + (@z * other.z)
  end

  # @rbs n: Integer
  # @rbs return: Pos
  def _mul__overload1(n)
    Pos.new(@x * n, @y * n, @z * n)
  end

  # @rbs return: String
  def to_s
    "#<Pos: (#{@x}, #{@y}, #{@z})>"
  end
end

puts(
  User.new("a@exmple.com").email,
  Pos.new(2, 3).y,
  Pos.new(1, 2) * Pos.new(3, 4),
  Pos.new(1, 2) * 3,
)
