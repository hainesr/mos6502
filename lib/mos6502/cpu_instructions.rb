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
        # CLC
        0x18 => lambda {
          @status.carry = false
        },

        # AND (immediate)
        0x29 => lambda {
          @a &= next_byte
          set_nz_flags(@a)
        },

        # SEC
        0x38 => lambda {
          @status.carry = true
        },

        # CLI
        0x58 => lambda {
          @status.interupt_disable = false
        },

        # SEI
        0x78 => lambda {
          @status.interupt_disable = true
        },

        # DEY
        0x88 => lambda {
          @y = (@y - 1) & 0xff
          set_nz_flags(@y)
        },

        # TXA
        0x8a => lambda {
          @a = @x & 0xff
          set_nz_flags(@a)
        },

        # TYA
        0x98 => lambda {
          @a = @y & 0xff
          set_nz_flags(@a)
        },

        # TXS
        0x9a => lambda {
          @sp = @x & 0xff
        },

        # TSX
        0xba => lambda {
          @x = @sp & 0xff
          set_nz_flags(@x)
        },

        # DEX
        0xca => lambda {
          @x = (@x - 1) & 0xff
          set_nz_flags(@x)
        },

        # LDY (immediate)
        0xa0 => lambda {
          @y = next_byte
          set_nz_flags(@y)
        },

        # LDX (immediate)
        0xa2 => lambda {
          @x = next_byte
          set_nz_flags(@x)
        },

        # TAY
        0xa8 => lambda {
          @y = @a & 0xff
          set_nz_flags(@y)
        },

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

        # INY
        0xc8 => lambda {
          @y = (@y + 1) & 0xff
          set_nz_flags(@y)
        },

        # CLD
        0xd8 => lambda {
          @status.decimal_mode = false
        },

        # INX
        0xe8 => lambda {
          @x = (@x + 1) & 0xff
          set_nz_flags(@x)
        },

        # NOP
        0xea => lambda {}, # rubocop:disable Style/Lambda

        # SED
        0xf8 => lambda {
          @status.decimal_mode = true
        }
      }
    end
  end
end
