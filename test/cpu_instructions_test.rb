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

  def test_0x58_0x78
    @cpu.load!([0x58, 0x78, 0x58])
    refute(@cpu.interupt_disable?)
    @cpu.step
    refute(@cpu.interupt_disable?)
    @cpu.step
    assert(@cpu.interupt_disable?)
    @cpu.step
    refute(@cpu.interupt_disable?)
  end

  def test_0x88
    @cpu.load!([0xa0, 0x00, 0x88])
    @cpu.step
    @cpu.step
    assert_equal(0xff, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0x8a
    @cpu.load!([0xa2, 0x75, 0x8a])
    assert_equal(0x00, @cpu.a)
    @cpu.step
    @cpu.step
    assert_equal(0x75, @cpu.a)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0x98
    @cpu.load!([0xa0, 0x12, 0x98])
    assert_equal(0x00, @cpu.a)
    @cpu.step
    @cpu.step
    assert_equal(0x12, @cpu.a)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0x9a
    @cpu.load!([0x9a])
    @cpu.step
    assert_equal(0x00, @cpu.sp)
    assert_equal(0x601, @cpu.pc)
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

  def test_0xba
    @cpu.load!([0xba])
    @cpu.step
    assert_equal(0xff, @cpu.x)
    assert_equal(0x601, @cpu.pc)
  end

  def test_0xc8
    @cpu.load!([0xa0, 0xff, 0xc8])
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xca
    @cpu.load!([0xa2, 0x33, 0xca])
    @cpu.step
    @cpu.step
    assert_equal(0x32, @cpu.x)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xd8_0xf8
    @cpu.load!([0xd8, 0xf8, 0xd8])
    refute(@cpu.decimal_mode?)
    @cpu.step
    refute(@cpu.decimal_mode?)
    @cpu.step
    assert(@cpu.decimal_mode?)
    @cpu.step
    refute(@cpu.decimal_mode?)
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
