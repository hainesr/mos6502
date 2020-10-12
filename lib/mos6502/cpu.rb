# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'forwardable'

require_relative 'cpu_flags'
require_relative 'cpu_instructions'
require_relative 'memory'

module Mos6502
  class Cpu
    extend Forwardable

    attr_reader :a, :pc, :sp, :x, :y

    def_delegators :@status, :break?, :carry?, :decimal_mode?,
                   :interupt_disable?, :negative?, :overflow?, :zero?

    def initialize(initial_pc: 0x600, code: nil)
      @initial_pc = initial_pc
      @status = CpuFlags.new
      load!(code)
      @instructions = instructions
    end

    def step
      inst = next_byte
      @instructions[inst].call
    end

    def load!(code = nil)
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

    def inspect
      format(
        'a: 0x%02x, x: 0x%02x, y: 0x%02x, sp: 0x%02x, ' \
        'pc: 0x%04x, status: 0b%08b', @a, @x, @y, @sp, @pc, @status.encode
      )
    end

    private

    def next_byte
      pc = @pc
      @pc += 1
      @memory.get(pc)
    end

    def next_word
      pc = @pc
      @pc += 2
      @memory.get_word(pc)
    end

    def reset!
      @memory = Memory.new
      @pc = @initial_pc
      @sp = 0xff
      @a = 0x00
      @x = 0x00
      @y = 0x00
      @status.reset!
    end
  end
end
