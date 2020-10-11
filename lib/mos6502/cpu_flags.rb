# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class CpuFlags
    def initialize
      reset!
    end

    def carry?
      @carry
    end

    def zero?
      @zero
    end

    def interupt_disable?
      @interupt_disable
    end

    def decimal_mode?
      @decimal_mode
    end

    def break?
      @break
    end

    def overflow?
      @overflow
    end

    def negative?
      @negative
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
  end
end
