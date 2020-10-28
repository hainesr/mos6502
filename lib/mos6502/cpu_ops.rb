# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class Cpu
    private

    def adc(value)
      carry = @status.carry? ? 1 : 0

      result = if @status.decimal_mode?
                 adc_decimal(@a, value, carry)
               else
                 adc_twos(@a, value, carry)
               end

      @a = result & 0xff
      set_nz_flags(@a)
    end

    def adc_twos(acc, value, carry)
      result = acc + value + carry
      @status.overflow =
        (((acc & 0x7f) + (value & 0x7f) + carry) >> 7) ^ (result >> 8)
      @status.carry = result > 0xff

      result
    end

    def adc_decimal(acc, value, carry)
      result = (acc & 0x0f) + (value & 0x0f) + carry
      result = 0x10 | ((result + 0x06) & 0x0f) if result >= 0x0a
      result += (acc & 0xf0) + (value & 0xf0)

      overflow = ((acc ^ value) & 0x80).zero?

      if result >= 0xa0
        result += 0x60
        @status.carry = true
        @status.overflow = overflow && (result >= 0x0180)
      else
        @status.carry = false
        @status.overflow = !overflow && (result < 0x80)
      end

      result
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

    def dec(value)
      value = (value - 1) & 0xff
      set_nz_flags(value)
      value
    end

    def inc(value)
      value = (value + 1) & 0xff
      set_nz_flags(value)
      value
    end

    def lsr(value)
      set_carry(value, 0)
      value = value >> 1
      set_nz_flags(value)
      value
    end

    def rol(value)
      carry = @status.carry? ? 1 : 0
      set_carry(value, 7)
      value = value << 1
      value |= carry
      set_nz_flags(value)
      value
    end

    def ror(value)
      carry = @status.carry?
      set_carry(value, 0)
      value = value >> 1
      value |= 0x80 if carry
      set_nz_flags(value)
      value
    end

    def sbc(value)
      carry = @status.carry? ? 1 : 0

      result = if @status.decimal_mode?
                 sbc_decimal(@a, value, carry)
               else
                 # We can use ADC with value EOR 0xff to subtract.
                 adc_twos(@a, value ^ 0xff, carry)
               end

      @a = result & 0xff
      set_nz_flags(@a)
    end

    def sbc_decimal(acc, value, carry)
      ones = 0x0f + (acc & 0x0f) - (value & 0x0f) + carry
      tens = 0xf0 + (acc & 0xf0) - (value & 0xf0)

      if ones < 0x10
        ones -= 6
      else
        tens += 0x10
        ones -= 0x10
      end

      overflow = !((acc ^ value) & 0x80).zero?

      if tens < 0x100
        tens -= 0x60
        @status.carry = false
        @status.overflow = overflow && (tens < 0x80)
      else
        @status.carry = true
        @status.overflow = overflow && (tens < 0x0180)
      end

      ones + tens
    end
  end
end
