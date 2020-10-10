# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'memory'

module Mos6502
  class Cpu
    attr_reader :a, :pc, :sp, :x, :y

    def initialize(initial_pc = 0x600)
      @initial_pc = initial_pc
      reset!
    end

    def reset!
      @memory = Memory.new
      @pc = @initial_pc
      @sp = 0x01ff
      @a = 0x00
      @x = 0x00
      @y = 0x00
    end
  end
end
