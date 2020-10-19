# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class CpuFlags
    def initialize
      reset!
    end

    def carry=(flag)
      @carry = set_flag(flag)
    end

    def carry?
      @carry
    end

    def zero=(flag)
      @zero = set_flag(flag)
    end

    def zero?
      @zero
    end

    def interupt_disable=(flag)
      @interupt_disable = set_flag(flag)
    end

    def interupt_disable?
      @interupt_disable
    end

    def decimal_mode=(flag)
      @decimal_mode = set_flag(flag)
    end

    def decimal_mode?
      @decimal_mode
    end

    def break=(flag)
      @break = set_flag(flag)
    end

    def break?
      @break
    end

    def overflow=(flag)
      @overflow = set_flag(flag)
    end

    def overflow?
      @overflow
    end

    def negative=(flag)
      @negative = set_flag(flag)
    end

    def negative?
      @negative
    end

    def encode
      [
        @negative, @overflow, true, true, @decimal_mode,
        @interupt_disable, @zero, @carry
      ].reduce(0) { |acc, flag| (acc << 1) + get_flag(flag) }
    end

    def decode(bin)
      self.carry = bin & 1
      self.zero = (bin >> 1) & 1
      self.interupt_disable = (bin >> 2) & 1
      self.decimal_mode = (bin >> 3) & 1
      self.break = (bin >> 4) & 1
      self.overflow = (bin >> 6) & 1
      self.negative = (bin >> 7) & 1
    end

    def reset!
      @carry = false
      @zero = false
      @interupt_disable = false
      @decimal_mode = false
      @break = false
      @overflow = false
      @negative = false
    end

    private

    def set_flag(flag)            # rubocop:disable Naming/AccessorMethodName
      flag == 0 ? false : !!flag  # rubocop:disable Style/NumericPredicate
    end

    def get_flag(flag)
      flag ? 1 : 0
    end
  end
end
