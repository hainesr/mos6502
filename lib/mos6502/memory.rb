# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class Memory
    def initialize
      @memory = []
    end

    def set(address, value)
      @memory[address] = (value & 0xff)
    end

    def get(address)
      @memory.fetch(address, 0x00)
    end

    def get_word(address)
      get(address) + (get(address + 1) << 8)
    end

    def dump(start, length)
      (start...(start + length)).reduce([]) { |acc, i| acc << get(i) }
    end
  end
end
