# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'cpu_illegal_ops'

module Mos6502
  class Cpu
    private

    def illegal_instructions
      {
        # NOP (zero page)
        0x04 => lambda {
          zero_page
        },

        # NOP (absolute)
        0x0c => lambda {
          absolute
        },

        # NOP (zero page, X)
        0x14 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0x1a => lambda {},

        # NOP (absolute, X)
        0x1c => lambda {
          absolute(@x)
        },

        # NOP (zero page, X)
        0x34 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0x3a => lambda {},

        # NOP (absolute, X)
        0x3c => lambda {
          absolute(@x)
        },

        # NOP (zero page)
        0x44 => lambda {
          zero_page
        },

        # NOP (zero page, X)
        0x54 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0x5a => lambda {},

        # NOP (absolute, X)
        0x5c => lambda {
          absolute(@x)
        },

        # NOP (zero page)
        0x64 => lambda {
          zero_page
        },

        # NOP (zero page, X)
        0x74 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0x7a => lambda {},

        # NOP (absolute, X)
        0x7c => lambda {
          absolute(@x)
        },

        # NOP (immediate)
        0x80 => lambda {
          next_byte
        },

        # SAX (indexed indirect)
        0x83 => lambda {
          @memory.set(indexed_indirect, @a & @x)
        },

        # SAX (zero page)
        0x87 => lambda {
          @memory.set(zero_page, @a & @x)
        },

        # SAX (absolute)
        0x8f => lambda {
          @memory.set(absolute, @a & @x)
        },

        # SAX (zero page, Y)
        0x97 => lambda {
          @memory.set(zero_page(@y), @a & @x)
        },

        # LAX (indexed indirect)
        0xa3 => lambda {
          @a = @x = @memory.get(indexed_indirect)
          set_nz_flags(@a)
        },

        # LAX (zero page)
        0xa7 => lambda {
          @a = @x = @memory.get(zero_page)
          set_nz_flags(@a)
        },

        # LAX (absolute)
        0xaf => lambda {
          @a = @x = @memory.get(absolute)
          set_nz_flags(@a)
        },

        # LAX (indirect indexed)
        0xb3 => lambda {
          @a = @x = @memory.get(indirect_indexed)
          set_nz_flags(@a)
        },

        # LAX (zero page, Y)
        0xb7 => lambda {
          @a = @x = @memory.get(zero_page(@y))
          set_nz_flags(@a)
        },

        # LAX (absolute, X)
        0xbf => lambda {
          @a = @x = @memory.get(absolute(@x))
          set_nz_flags(@a)
        },

        # DCP (DEC + CMP) (indexed indirect)
        0xc3 => lambda {
          dcp(indexed_indirect)
        },

        # DCP (DEC + CMP) (zero page)
        0xc7 => lambda {
          dcp(zero_page)
        },

        # DCP (DEC + CMP) (absolute)
        0xcf => lambda {
          dcp(absolute)
        },

        # DCP (DEC + CMP) (indirect indexed)
        0xd3 => lambda {
          dcp(indirect_indexed)
        },

        # NOP (zero page, X)
        0xd4 => lambda {
          zero_page(@x)
        },

        # DCP (DEC + CMP) (zero page, X)
        0xd7 => lambda {
          dcp(zero_page(@x))
        },

        # NOP (implied)
        0xda => lambda {},

        # DCP (DEC + CMP) (absolute, Y)
        0xdb => lambda {
          dcp(absolute(@y))
        },

        # NOP (absolute, X)
        0xdc => lambda {
          absolute(@x)
        },

        # SBC (immediate) + NOP
        0xeb => lambda {
          sbc(next_byte)
        },

        # NOP (zero page, X)
        0xf4 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0xfa => lambda {},

        # NOP (absolute, X)
        0xfc => lambda {
          absolute(@x)
        }
      }
    end
  end
end
