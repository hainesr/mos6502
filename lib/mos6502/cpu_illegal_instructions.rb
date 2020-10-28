# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'cpu_ops'

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

        # NOP (zero page, X)
        0x34 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0x3a => lambda {},

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

        # NOP (zero page, X)
        0xd4 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0xda => lambda {},

        # NOP (zero page, X)
        0xf4 => lambda {
          zero_page(@x)
        },

        # NOP (implied)
        0xfa => lambda {}
      }
    end
  end
end
