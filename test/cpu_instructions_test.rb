# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuInstructionsTest < Minitest::Test
  def setup
    @cpu = Mos6502::Cpu.new
  end

  def test_0x29
    @cpu.load!([0xa9, 0x33, 0x29, 0x55])
    @cpu.step
    @cpu.step
    assert_equal(0x11, @cpu.a)
    assert_equal(0x604, @cpu.pc)
  end

  def test_0xca
    @cpu.load!([0xa2, 0x33, 0xca])
    @cpu.step
    @cpu.step
    assert_equal(0x32, @cpu.x)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xa0
    @cpu.load!([0xa0, 0x66])
    assert_equal(0x00, @cpu.y)
    @cpu.step
    assert_equal(0x66, @cpu.y)
    assert_equal(0x602, @cpu.pc)
  end

  def test_0xa2
    @cpu.load!([0xa2, 0x66])
    assert_equal(0x00, @cpu.x)
    @cpu.step
    assert_equal(0x66, @cpu.x)
    assert_equal(0x602, @cpu.pc)
  end

  def test_0xa8
    @cpu.load!([0xa9, 0x21, 0xa8])
    assert_equal(0x00, @cpu.y)
    @cpu.step
    @cpu.step
    assert_equal(0x21, @cpu.a)
    assert_equal(0x21, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xa9
    @cpu.load!([0xa9, 0xc0])
    assert_equal(0x00, @cpu.a)
    @cpu.step
    assert_equal(0xc0, @cpu.a)
    assert_equal(0x602, @cpu.pc)
  end

  def test_0xaa
    @cpu.load!([0xa9, 0x33, 0xaa])
    assert_equal(0x00, @cpu.x)
    @cpu.step
    @cpu.step
    assert_equal(0x33, @cpu.a)
    assert_equal(0x33, @cpu.x)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xc8
    @cpu.load!([0xa0, 0xff, 0xc8])
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xe8
    @cpu.load!([0xa2, 0x33, 0xe8])
    @cpu.step
    @cpu.step
    assert_equal(0x34, @cpu.x)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xea
    @cpu.load!([0xea, 0xea, 0xea])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert_equal(0x00, @cpu.x)
    assert_equal(0x00, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end
end
