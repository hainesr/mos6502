# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class Cpu
    private

    def adc(value)
      carry = @status.carry? ? 1 : 0

      if @status.decimal_mode?
        result = (@a & 0x0f) + (value & 0x0f) + carry
        result = 0x10 | ((result + 0x06) & 0x0f) if result >= 0x0a
        result += (@a & 0xf0) + (value & 0xf0)

        if result >= 0xa0
          result += 0x60
          @status.carry = true
          @status.overflow = ((@a ^ value) & 0x80).zero? && (result >= 0x0180)
        else
          @status.carry = false
          @status.overflow = !((@a ^ value) & 0x80).zero? && (result < 0x80)
        end
      else
        result = @a + value + carry
        @status.overflow =
          (((@a & 0x7f) + (value & 0x7f) + carry) >> 7) ^ (result >> 8)
        @status.carry = result > 0xff
      end

      @a = result & 0xff
      set_nz_flags(@a)
    end

    def asl(value)
      set_carry(value, 7)
      value = value << 1
      set_nz_flags(value)
      value
    end

    def bit(value)
      @status.zero = (@a & value).zero?
      @status.overflow = value & 0x40
      @status.negative = value & 0x80
    end

    def branch(offset)
      if offset > 0x7f
        @pc - (0x100 - offset)
      else
        @pc + offset
      end
    end

    def compare(register, value)
      @status.carry = register >= value
      set_nz_flags(register - value)
    end

    def lsr(value)
      set_carry(value, 0)
      value = value >> 1
      set_nz_flags(value)
      value
    end

    def sbc(value)
      if @status.decimal_mode?
        carry = @status.carry? ? 1 : 0
        ones = 0x0f + (@a & 0x0f) - (value & 0x0f) + carry
        tens = 0xf0 + (@a & 0xf0) - (value & 0xf0)

        if ones < 0x10
          ones -= 6
        else
          tens += 0x10
          ones -= 0x10
        end

        if tens < 0x100
          tens -= 0x60
          @status.carry = false
          @status.overflow = !((@a ^ value) & 0x80).zero? && (tens < 0x80)
        else
          @status.carry = true
          @status.overflow = !((@a ^ value) & 0x80).zero? && (tens < 0x0180)
        end

        @a = (ones + tens) & 0xff
        set_nz_flags(@a)
      else
        adc(value ^ 0xff)
      end
    end
  end
end
