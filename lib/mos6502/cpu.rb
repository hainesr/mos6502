# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'memory'

module Mos6502
  class Cpu
    attr_reader :a, :pc, :sp, :x, :y

    def initialize(initial_pc: 0x600, code: nil)
      @initial_pc = initial_pc
      load!(code)
    end

    def load!(code)
      reset!
      return if code.nil?

      loc = @pc
      code = code.bytes if code.respond_to?(:bytes)
      code.each do |b|
        @memory.set(loc, b)
        loc += 1
      end
    end

    def dump_memory(start, length)
      @memory.dump(start, length)
    end

    private

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
