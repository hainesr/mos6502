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
  end
end
