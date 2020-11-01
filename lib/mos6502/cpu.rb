# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'forwardable'

require_relative 'cpu_flags'
require_relative 'cpu_instructions'
require_relative 'cpu_illegal_instructions'
require_relative 'memory'

module Mos6502
  class Cpu
    extend Forwardable

    attr_reader :a, :pc, :sp, :x, :y

    def_delegators :@status, :break?, :carry?, :decimal_mode?,
                   :interupt_disable?, :negative?, :overflow?, :zero?

    def initialize(initial_pc: 0x600, allow_illegal_ops: false)
      @initial_pc = initial_pc
      @status = CpuFlags.new
      reset!
      @instructions = instructions
      @instructions.merge!(illegal_instructions) if allow_illegal_ops
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

    def load_image(image = nil, start = 0)
      return if image.nil?

      @memory.load(image, start)
    end

    def load_image!(image = nil, start = 0)
      reset!
      load_image(image, start)
    end

    def dump_memory(start, length)
      @memory.dump(start, length)
    end

    def inspect
      format(
        'a: 0x%02x, x: 0x%02x, y: 0x%02x, sp: 0x%02x, ' \
        'pc: 0x%04x, op: 0x%02x, status: 0b%08b',
        @a, @x, @y, @sp, @pc, @memory.get(@pc), @status.encode
      )
    end

    private

    # Stack access.
    def stack_push(value)
      @memory.set((@sp & 0xff) + 0x0100, value)

      # Decrement the stack pointer, and wrap it if it goes below 0.
      @sp -= 1
      @sp = @sp &= 0xff if @sp < 0 # rubocop:disable Style/NumericPredicate
    end

    def stack_pop
      # Increment the stack pointer, and wrap it if it goes above 255.
      @sp += 1
      @sp = @sp &= 0xff if @sp > 0xff

      @memory.get((@sp & 0xff) + 0x0100)
    end

    # Program access.
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

    # Memory access.
    def zero_page(register = 0)
      (next_byte + register) & 0xff
    end

    def absolute(register = 0)
      (next_word + register)
    end

    def indirect
      @memory.get_word(next_word)
    end

    def indexed_indirect
      @memory.get_word(zero_page(@x))
    end

    def indirect_indexed
      @memory.get_word(next_byte) + @y
    end

    # Status access.
    def set_nz_flags(value) # rubocop:disable Naming/AccessorMethodName
      @status.zero = value.zero?
      @status.negative = value & 0x80
    end

    def set_carry(value, bit)
      @status.carry = (value >> bit) & 1
    end

    # Reset!
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
