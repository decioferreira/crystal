module Crypto::Subtle
  def self.constant_time_compare(x, y)
    return 0 if x.length != y.length

    v = 0_u8

    x.length.times do |i|
      v = v | x[i] ^ y[i]
    end

    constant_time_byte_eq(v, 0)
  end

  def self.constant_time_byte_eq(x, y)
    z = ~(x ^ y)
    z &= z >> 4
    z &= z >> 2
    z &= z >> 1
    z
  end
end
