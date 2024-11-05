# frozen_string_literal: true

# rbs_inline: enabled

# Example class
class User
  attr_reader :email, :name, :nick

  # @rbs email: String
  # @rbs tel: (nil | String)
  # @rbs name: (nil | String)
  # @rbs nick: (nil | String)
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
  def initialize(x, y, z = 0)
    @x = x
    @y = y
    @z = z
  end

  # @rbs (Pos) -> untyped
  #    | (Integer) -> untyped
  def *(*args)
    case args
    in [Pos]
      _mul__overload0(*args)
    in [Integer]
      _mul__overload1(*args)
    end
  end

  # @rbs other: Pos
  def _mul__overload0(other)
    (@x * other.x) + (@y * other.y) + (@z * other.z)
  end

  # @rbs n: Integer
  def _mul__overload1(n)
    Pos.new(@x * n, @y * n, @z * n)
  end
end

puts(
  User.new("a@exmple.com").email,
  Pos.new(2, 3).y,
  Pos.new(1, 2) * Pos.new(3, 4),
  Pos.new(1, 2) * 3,
)
