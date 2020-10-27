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

        # NOP (zero page)
        0x44 => lambda {
          zero_page
        },

        # NOP (zero page)
        0x64 => lambda {
          zero_page
        }
      }
    end
  end
end
