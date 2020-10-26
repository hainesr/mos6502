# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class Memory
    def initialize(image = nil)
      load!(image)
    end

    def set(address, value)
      @memory[address] = (value & 0xff)
    end

    def get(address)
      @memory[address] || 0x00
    end

    def get_word(address)
      get(address) + (get(address + 1) << 8)
    end

    def load(image, start = 0)
      return if image.nil?

      image = image.bytes if image.respond_to?(:bytes)
      @memory[start, image.length] = image
    end

    def load!(image, start = 0)
      @memory = []
      load(image, start)
    end

    def dump(start, length)
      (start...(start + length)).reduce([]) { |acc, i| acc << get(i) }
    end
  end
end
