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

  def test_0x00
    @cpu.load!([0x00])
    @cpu.step
    assert_equal(0x0000, @cpu.pc)
    assert_equal(0xfc, @cpu.sp)
    assert(@cpu.break?)
  end

  def test_0x08
    @cpu.load!([0x38, 0x78, 0x08, 0x68])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    @cpu.step
    assert_equal(0x25, @cpu.a)
  end

  def test_0x0a
    @cpu.load!([0xa9, 0xff, 0x0a])
    @cpu.step
    @cpu.step
    assert(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal(0xfe, @cpu.a)
  end

  def test_0x18_0x38
    @cpu.load!([0x18, 0x38, 0x18])
    refute(@cpu.carry?)
    @cpu.step
    refute(@cpu.carry?)
    @cpu.step
    assert(@cpu.carry?)
    @cpu.step
    refute(@cpu.carry?)
  end

  def test_0x20
    @cpu.load!([0x20, 0x00, 0x07])
    @cpu.step
    assert_equal(0x0700, @cpu.pc)
    assert_equal(0xfd, @cpu.sp)
  end

  def test_0x28
    @cpu.load!([0xa9, 0x4d, 0x48, 0x28])
    @cpu.step
    @cpu.step
    assert_equal(0xfe, @cpu.sp)
    refute(@cpu.overflow?)
    refute(@cpu.carry?)
    refute(@cpu.decimal_mode?)
    refute(@cpu.interupt_disable?)
    @cpu.step
    assert_equal(0xff, @cpu.sp)
    assert(@cpu.overflow?)
    assert(@cpu.carry?)
    assert(@cpu.decimal_mode?)
    assert(@cpu.interupt_disable?)
  end

  def test_0x29
    @cpu.load!([0xa9, 0x33, 0x29, 0x55])
    @cpu.step
    @cpu.step
    assert_equal(0x11, @cpu.a)
    assert_equal(0x604, @cpu.pc)
  end

  def test_0x2a
    @cpu.load!([0xa9, 0x80, 0x38, 0x2a])
    @cpu.step
    assert(@cpu.negative?)
    @cpu.step
    @cpu.step
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert_equal(0x01, @cpu.a)
  end

  def test_0x48_0x68
    @cpu.load!([0xa9, 0x44, 0x48, 0xa9, 0x00, 0x68])
    @cpu.step
    assert_equal(0x44, @cpu.a)
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert(@cpu.zero?)
    @cpu.step
    assert_equal(0x44, @cpu.a)
    refute(@cpu.zero?)
    assert_equal(0x606, @cpu.pc)
  end

  def test_0x4a
    @cpu.load!([0xa9, 0xfe, 0x4a])
    @cpu.step
    @cpu.step
    refute(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal(0x7f, @cpu.a)
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

  def test_0x69_2scomp
    @cpu.load!(
      [0xa9, 0x03, 0x69, 0x02, 0x69, 0xfa, 0x69, 0x01, 0x69, 0x80, 0x69, 0x80]
    )
    @cpu.step
    @cpu.step
    assert_equal(0x05, @cpu.a)
    refute(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0xff, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    assert(@cpu.zero?)

    @cpu.step
    assert_equal(0x81, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x01, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.overflow?)
    refute(@cpu.zero?)
  end

  def test_0x69_bcd
    @cpu.load!(
      [0xf8, 0xa9, 0x90, 0x69, 0x09, 0x69, 0x99, 0x69, 0x01, 0x69, 0x01]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x99, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x98, @cpu.a)
    assert(@cpu.carry?)
    assert(@cpu.negative?)
    assert(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    assert(@cpu.zero?)

    @cpu.step
    assert_equal(0x02, @cpu.a)
    refute(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)
  end

  def test_0x6a
    @cpu.load!([0xa9, 0x03, 0x38, 0x6a])
    @cpu.step
    refute(@cpu.negative?)
    @cpu.step
    @cpu.step
    assert(@cpu.carry?)
    assert(@cpu.negative?)
    assert_equal(0x81, @cpu.a)
  end

  def test_0x85
    @cpu.load!([0xa9, 0x40, 0x85, 0x01])
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.a)
    assert_equal([0x00, 0x40, 0x00], @cpu.dump_memory(0, 3))
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

  def test_0x8d
    @cpu.load!([0xa9, 0x20, 0x8d, 0x01, 0x20])
    @cpu.step
    @cpu.step
    assert_equal(0x20, @cpu.a)
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x00, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x1f, 3))
    assert_equal([0x00, 0x20, 0x00], @cpu.dump_memory(0x2000, 3))
  end

  def test_0x95
    @cpu.load!([0xa9, 0x40, 0xa2, 0xf0, 0x95, 0x20])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.a)
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x1f, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0xef, 3))
    assert_equal([0x00, 0x40, 0x00], @cpu.dump_memory(0x0f, 3))
  end

  def test_0x98
    @cpu.load!([0xa0, 0x12, 0x98])
    assert_equal(0x00, @cpu.a)
    @cpu.step
    @cpu.step
    assert_equal(0x12, @cpu.a)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0x99
    @cpu.load!([0xa9, 0x20, 0xa0, 0xff, 0x99, 0x01, 0x20])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x00, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0xff, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x2000, 3))
    assert_equal([0x00, 0x20, 0x00], @cpu.dump_memory(0x20ff, 3))
  end

  def test_0x9a
    @cpu.load!([0x9a])
    @cpu.step
    assert_equal(0x00, @cpu.sp)
    assert_equal(0x601, @cpu.pc)
  end

  def test_0x9d
    @cpu.load!([0xa9, 0x20, 0xa2, 0xff, 0x9d, 0x01, 0x20])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x00, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0xff, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x2000, 3))
    assert_equal([0x00, 0x20, 0x00], @cpu.dump_memory(0x20ff, 3))
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

  def test_0xb8
    @cpu.load!([0xa9, 0x40, 0x48, 0x28, 0xb8])
    @cpu.step
    @cpu.step
    @cpu.step
    assert(@cpu.overflow?)
    @cpu.step
    refute(@cpu.overflow?)
  end

  def test_0xba
    @cpu.load!([0xba])
    @cpu.step
    assert_equal(0xff, @cpu.x)
    assert_equal(0x601, @cpu.pc)
  end

  def test_0xc0
    @cpu.load!([0xa0, 0x20, 0xc0, 0x10, 0xc0, 0x30, 0xc0, 0x20])
    @cpu.step
    @cpu.step
    assert_equal(0x20, @cpu.y)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x20, @cpu.y)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x20, @cpu.y)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.zero?)
  end

  def test_0xc8
    @cpu.load!([0xa0, 0xff, 0xc8])
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.y)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xc9
    @cpu.load!([0xa9, 0x20, 0xc9, 0x10, 0xc9, 0x30, 0xc9, 0x20])
    @cpu.step
    @cpu.step
    assert_equal(0x20, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x20, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x20, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.zero?)
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

  def test_0xe0
    @cpu.load!([0xa2, 0x20, 0xe0, 0x10, 0xe0, 0x30, 0xe0, 0x20])
    @cpu.step
    @cpu.step
    assert_equal(0x20, @cpu.x)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x20, @cpu.x)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x20, @cpu.x)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.zero?)
  end

  def test_0xe8
    @cpu.load!([0xa2, 0x33, 0xe8])
    @cpu.step
    @cpu.step
    assert_equal(0x34, @cpu.x)
    assert_equal(0x603, @cpu.pc)
  end

  def test_0xe9_2scomp
    @cpu.load!(
      [0xa9, 0x01, 0xe9, 0x01, 0xe9, 0xff, 0xe9, 0x01, 0xe9, 0x80, 0xe9, 0x7d]
    )
    @cpu.step
    @cpu.step
    assert_equal(0xff, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0xff, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0xfd, @cpu.a)
    assert(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x7d, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x00, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    assert(@cpu.zero?)
  end

  def test_0xe9_bcd
    @cpu.load!(
      [0xf8, 0xa9, 0x90, 0xe9, 0x09, 0xe9, 0x99, 0xe9, 0x01, 0xe9, 0x01]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x80, @cpu.a)
    assert(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x81, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x79, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.overflow?)
    refute(@cpu.zero?)

    @cpu.step
    assert_equal(0x78, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.overflow?)
    refute(@cpu.zero?)
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
