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

  # NOP (zero page, X)
  def test_0x14_0x34_0x54_0x74_0xd4_0xf4
    @cpu.load!(
      [0x14, 0x01, 0x34, 0x01, 0x54, 0x01, 0x74, 0x01, 0xd4, 0x01, 0xf4, 0x01]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert_equal(0x00, @cpu.x)
    assert_equal(0x00, @cpu.y)
    assert_equal(0x60c, @cpu.pc)
  end

  # NOP (implied)
  def test_0x1a_0x3a_0x5a_0x7a_0xda_0xfa
    @cpu.load!([0x1a, 0x3a, 0x5a, 0x7a, 0xda, 0xfa])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert_equal(0x00, @cpu.x)
    assert_equal(0x00, @cpu.y)
    assert_equal(0x606, @cpu.pc)
  end
end
