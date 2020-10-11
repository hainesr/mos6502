# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class Cpu
    private

    def set_nz_flags(value) # rubocop:disable Naming/AccessorMethodName
      @status.zero = value.zero?
      @status.negative = value & 0x80
    end

    def instructions
      {
        # LDA (immediate)
        0xa9 => lambda {
          @a = next_byte
          set_nz_flags(@a)
        },

        # TAX
        0xaa => lambda {
          @x = @a & 0xff
          set_nz_flags(@x)
        },

        # INX
        0xe8 => lambda {
          @x = (@x + 1) & 0xff
          set_nz_flags(@x)
        }
      }
    end
  end
end
