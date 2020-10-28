# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuIllegalInstructionsTest < Minitest::Test
  def setup
    @cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
  end

  # NOP (zero page)
  def test_0x04_0x44_0x64
    @cpu.load!([0x04, 0x01, 0x44, 0x01, 0x64, 0x01])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert_equal(0x00, @cpu.x)
    assert_equal(0x00, @cpu.y)
    assert_equal(0x606, @cpu.pc)
  end

  # NOP (absolute)
  def test_0x0c
    @cpu.load!([0x0c, 0xaa, 0xbb])
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert_equal(0x00, @cpu.x)
    assert_equal(0x00, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end
end
