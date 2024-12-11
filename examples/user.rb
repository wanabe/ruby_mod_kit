# frozen_string_literal: true

# rbs_inline: enabled

# Example class
class User
  # @rbs @email: String
  # @rbs @tel: nil | String
  # @rbs @name: nil | String
  # @rbs @nick: nil | String

  attr_reader :email #: String
  attr_reader :name #: nil | String
  attr_reader :nick #: nil | String

  # @rbs email: String
  # @rbs tel: nil | String
  # @rbs name: nil | String
  # @rbs nick: nil | String
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
  # @rbs @x: Integer
  # @rbs @y: Integer
  # @rbs @z: Integer

  attr_reader :x #: Integer
  attr_reader :y #: Integer
  attr_reader :z #: Integer

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
    in [Pos => other]
      (@x * other.x) + (@y * other.y) + (@z * other.z)
    in [Integer => n]
      Pos.new(@x * n, @y * n, @z * n)
    end
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
