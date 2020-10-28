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

  # NOP (absolute, X)
  def test_0x1c_0x3c_0x5c_0x7c_0xdc_0xfc
    @cpu.load!(
      [
        0x1c, 0xa9, 0xa9, 0x3c, 0xa9, 0xa9, 0x5c, 0xa9, 0xa9,
        0x7c, 0xa9, 0xa9, 0xdc, 0xa9, 0xa9, 0xfc, 0xa9, 0xa9
      ]
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
    assert_equal(0x612, @cpu.pc)
  end

  # NOP (immediate)
  def test_0x80
    @cpu.load!([0x80, 0xff])
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert_equal(0x00, @cpu.x)
    assert_equal(0x00, @cpu.y)
    assert_equal(0x602, @cpu.pc)
  end

  # LAX (indexed indirect)
  def test_0xa3
    @cpu.load!([0xa0, 0x06, 0x84, 0x21, 0xa2, 0x30, 0xa3, 0xf0])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0xa0, @cpu.a)
    assert_equal(0xa0, @cpu.x)
  end

  # LAX (zero page)
  def test_0xa7
    @cpu.load!([0xa0, 0x42, 0x84, 0x32, 0xa7, 0x32])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x42, @cpu.a)
    assert_equal(0x42, @cpu.x)
  end

  # LAX (absolute)
  def test_0xaf
    @cpu.load!([0xaf, 0x02, 0x06])
    @cpu.step
    assert_equal(0x06, @cpu.a)
    assert_equal(0x06, @cpu.x)
  end

  # LAX (indirect indexed)
  def test_0xb3
    @cpu.load!([0xa2, 0x06, 0x86, 0x76, 0xa0, 0x04, 0xb3, 0x75])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0xa0, @cpu.a)
    assert_equal(0xa0, @cpu.x)
  end

  # LAX (zero page, Y)
  def test_0xb7
    @cpu.load!([0xa0, 0x80, 0x84, 0x05, 0xb7, 0x85])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x80, @cpu.a)
    assert_equal(0x80, @cpu.x)
  end

  # LAX (absolute, X)
  def test_0xbf
    @cpu.load!([0xa2, 0x01, 0xbf, 0x01, 0x06])
    @cpu.step
    @cpu.step
    assert_equal(0xbf, @cpu.a)
    assert_equal(0xbf, @cpu.x)
  end
end
