# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuIllegalAccumulatorOperationsTest < Minitest::Test
  def test_indexed_indirect
    # 0x3f <OP> 0xb3
    [
      [0xc3, 0x3f, 0xb2, true, false, false, false] # DCP
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
      cpu.load!([0xa9, 0xb3, 0xa2, 0xd0, 0x81, 0x41, 0xa9, 0x3f, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x00, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end
end
