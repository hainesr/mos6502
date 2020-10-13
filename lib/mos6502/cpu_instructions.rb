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

    def set_carry(value, bit)
      @status.carry = (value >> bit) & 1
    end

    def instructions
      {
        # BRK
        0x00 => lambda {
          stack_push((@pc >> 8) & 0xff)
          stack_push(@pc & 0xff)
          stack_push(@status.encode)
          @pc = @memory.get_word(0xfffe)
          @status.break = true
        },

        # PHP
        0x08 => lambda {
          stack_push(@status.encode)
        },

        # CLC
        0x18 => lambda {
          @status.carry = false
        },

        # PLP
        0x28 => lambda {
          @status.decode(stack_pop)
        },

        # AND (immediate)
        0x29 => lambda {
          @a &= next_byte
          set_nz_flags(@a)
        },

        # ROL (accumulator)
        0x2a => lambda {
          carry = @status.carry? ? 1 : 0
          set_carry(@a, 7)
          @a = (@a << 1) & 0xff
          @a |= carry
          set_nz_flags(@a)
        },

        # SEC
        0x38 => lambda {
          @status.carry = true
        },

        # PHA
        0x48 => lambda {
          stack_push(@a)
        },

        # CLI
        0x58 => lambda {
          @status.interupt_disable = false
        },

        # PLA
        0x68 => lambda {
          @a = stack_pop
          set_nz_flags(@a)
        },

        # ROR (accumulator)
        0x6a => lambda {
          carry = @status.carry?
          set_carry(@a, 0)
          @a = @a >> 1
          @a |= 0x80 if carry
          set_nz_flags(@a)
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

        # CLV
        0xb8 => lambda {
          @status.overflow = false
        },

        # TSX
        0xba => lambda {
          @x = @sp & 0xff
          set_nz_flags(@x)
        },

        # INY
        0xc8 => lambda {
          @y = (@y + 1) & 0xff
          set_nz_flags(@y)
        },

        # DEX
        0xca => lambda {
          @x = (@x - 1) & 0xff
          set_nz_flags(@x)
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
