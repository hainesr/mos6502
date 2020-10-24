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
    assert_equal([0x02, 0x06], @cpu.dump_memory(0x01fe, 2))
    assert(@cpu.break?)
    assert(@cpu.interupt_disable?)
  end

  def test_0x06
    @cpu.load!([0xa9, 0x7f, 0x85, 0x70, 0x06, 0x70])
    @cpu.step
    @cpu.step
    @cpu.step
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal([0xfe], @cpu.dump_memory(0x70, 1))
  end

  def test_0x08
    @cpu.load!([0x38, 0x78, 0x08, 0x68])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x00, @cpu.a)
    @cpu.step
    assert_equal(0x35, @cpu.a)
  end

  def test_0x09
    @cpu.load!([0xa9, 0x55, 0x09, 0xaa])
    @cpu.step
    @cpu.step
    assert_equal(0xff, @cpu.a)
    assert(@cpu.negative?)
    refute(@cpu.zero?)
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

  def test_0x0e
    @cpu.load!([0xa9, 0x7f, 0x8d, 0x0f, 0x70, 0x0e, 0x0f, 0x70])
    @cpu.step
    @cpu.step
    @cpu.step
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal([0xfe], @cpu.dump_memory(0x700f, 1))
  end

  def test_0x10
    @cpu.load!([0xa2, 0xff, 0x10, 0x03, 0xe8, 0x10, 0xfb, 0xa0, 0xff])
    @cpu.step
    @cpu.step
    assert_equal(0x604, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x602, @cpu.pc)
    @cpu.step
    assert_equal(0x607, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
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

  def test_0x24
    @cpu.load!(
      [0xa0, 0x77, 0x84, 0x20, 0xa9, 0x88, 0x24, 0x20, 0x98, 0x24, 0x20]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x88, @cpu.a)
    assert(@cpu.zero?)
    assert(@cpu.overflow?)
    refute(@cpu.negative?)

    @cpu.step
    @cpu.step
    assert_equal(0x77, @cpu.a)
    refute(@cpu.zero?)
    assert(@cpu.overflow?)
    refute(@cpu.negative?)
  end

  def test_0x26
    @cpu.load!([0xa9, 0x7f, 0x85, 0x70, 0x26, 0x70])
    @cpu.step
    @cpu.step
    @cpu.step
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal([0xfe], @cpu.dump_memory(0x70, 1))
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

  def test_0x2c
    @cpu.load!(
      [
        0xa0, 0x77, 0x8c, 0x20, 0x80, 0xa9, 0x88,
        0x2c, 0x20, 0x80, 0x98, 0x2c, 0x20, 0x80
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x88, @cpu.a)
    assert(@cpu.zero?)
    assert(@cpu.overflow?)
    refute(@cpu.negative?)

    @cpu.step
    @cpu.step
    assert_equal(0x77, @cpu.a)
    refute(@cpu.zero?)
    assert(@cpu.overflow?)
    refute(@cpu.negative?)
  end

  def test_0x30
    @cpu.load!([0xa2, 0x00, 0x30, 0x03, 0xca, 0x30, 0xfb, 0xa0, 0xff])
    @cpu.step
    @cpu.step
    assert_equal(0x604, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x602, @cpu.pc)
    @cpu.step
    assert_equal(0x607, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
  end

  def test_0x40
    @cpu.load!(
      [
        0xa9, 0x06, 0x8d, 0xff, 0xff, 0x69, 0x08, 0x8d, 0xfe, 0xff, 0x00, 0x00,
        0xa0, 0x0f, 0x40
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x60e, @cpu.pc)
    assert(@cpu.break?)
    @cpu.step
    assert_equal(0x60c, @cpu.pc)
    @cpu.step
    assert_equal(0x0f, @cpu.y)
  end

  def test_0x46
    @cpu.load!([0xa9, 0x7f, 0x85, 0x70, 0x46, 0x70])
    @cpu.step
    @cpu.step
    @cpu.step
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal([0x3f], @cpu.dump_memory(0x70, 1))
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

  def test_0x49
    @cpu.load!([0xa9, 0x55, 0x49, 0xff, 0x49, 0xaa])
    @cpu.step
    @cpu.step
    assert_equal(0xaa, @cpu.a)
    assert(@cpu.negative?)
    @cpu.step
    assert_equal(0x00, @cpu.a)
    refute(@cpu.negative?)
    assert(@cpu.zero?)
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

  def test_0x4c
    @cpu.load!([0x4c, 0x7f, 0x04])
    @cpu.step
    assert_equal(0x047f, @cpu.pc)
  end

  def test_0x50
    @cpu.load!(
      [0xa9, 0x40, 0x48, 0x28, 0x50, 0x03, 0xb8, 0x50, 0xfb, 0xa0, 0xff]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x606, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x604, @cpu.pc)
    @cpu.step
    assert_equal(0x609, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
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

  def test_0x60
    @cpu.load!([0x20, 0x05, 0x06, 0xa0, 0x0f, 0x60])
    @cpu.step
    assert_equal(0x0605, @cpu.pc)
    assert_equal(0xfd, @cpu.sp)
    @cpu.step
    assert_equal(0x0603, @cpu.pc)
    assert_equal(0xff, @cpu.sp)
    @cpu.step
    assert_equal(0x0f, @cpu.y)
  end

  def test_0x66
    @cpu.load!([0xa9, 0x7f, 0x85, 0x70, 0x66, 0x70])
    @cpu.step
    @cpu.step
    @cpu.step
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    refute(@cpu.zero?)
    assert_equal([0x3f], @cpu.dump_memory(0x70, 1))
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

  def test_0x6c
    @cpu.load!([0x6c, 0x05, 0x06, 0x00, 0x00, 0xce, 0xfa])
    @cpu.step
    assert_equal(0xface, @cpu.pc)
  end

  def test_0x70
    @cpu.load!(
      [0xb8, 0x70, 0x06, 0xa9, 0x40, 0x48, 0x28, 0x70, 0xf8, 0xa0, 0xff]
    )
    @cpu.step
    @cpu.step
    assert_equal(0x603, @cpu.pc)
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x601, @cpu.pc)
    @cpu.step
    assert_equal(0x609, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
  end

  def test_0x81
    @cpu.load!(
      [
        0xa9, 0x50, 0xa0, 0x05, 0x84, 0x20, 0x88, 0x84, 0x21,
        0xa2, 0xe0, 0x81, 0x40
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x50, @cpu.a)
    assert_equal([0x00, 0x50, 0x00], @cpu.dump_memory(0x404, 3))
  end

  def test_0x84
    @cpu.load!([0xa0, 0x40, 0x84, 0x01])
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.y)
    assert_equal([0x00, 0x40, 0x00], @cpu.dump_memory(0, 3))
  end

  def test_0x85
    @cpu.load!([0xa9, 0x40, 0x85, 0x01])
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.a)
    assert_equal([0x00, 0x40, 0x00], @cpu.dump_memory(0, 3))
  end

  def test_0x86
    @cpu.load!([0xa2, 0x40, 0x86, 0x01])
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.x)
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

  def test_0x8c
    @cpu.load!([0xa0, 0x20, 0x8c, 0x01, 0x20])
    @cpu.step
    @cpu.step
    assert_equal(0x20, @cpu.y)
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x00, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x1f, 3))
    assert_equal([0x00, 0x20, 0x00], @cpu.dump_memory(0x2000, 3))
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

  def test_0x8e
    @cpu.load!([0xa2, 0x20, 0x8e, 0x01, 0x20])
    @cpu.step
    @cpu.step
    assert_equal(0x20, @cpu.x)
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x00, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x1f, 3))
    assert_equal([0x00, 0x20, 0x00], @cpu.dump_memory(0x2000, 3))
  end

  def test_0x90
    @cpu.load!([0x38, 0x90, 0x03, 0x18, 0x90, 0xfb, 0xa0, 0xff])
    @cpu.step
    @cpu.step
    assert_equal(0x603, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x601, @cpu.pc)
    @cpu.step
    assert_equal(0x606, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
  end

  def test_0x91
    @cpu.load!([0xa9, 0x95, 0xa2, 0x06, 0x86, 0x76, 0xa0, 0x04, 0x91, 0x75])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal([0x06, 0x95, 0x76], @cpu.dump_memory(0x603, 3))
  end

  def test_0x94
    @cpu.load!([0xa0, 0x40, 0xa2, 0xf0, 0x94, 0x20])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.y)
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0x1f, 3))
    assert_equal([0x00, 0x00, 0x00], @cpu.dump_memory(0xef, 3))
    assert_equal([0x00, 0x40, 0x00], @cpu.dump_memory(0x0f, 3))
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

  def test_0x96
    @cpu.load!([0xa2, 0x40, 0xa0, 0xf0, 0x96, 0x20])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x40, @cpu.x)
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

  def test_0xa1
    @cpu.load!([0xa0, 0x06, 0x84, 0x21, 0xa2, 0x30, 0xa1, 0xf0])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0xa0, @cpu.a)
  end

  def test_0xa2
    @cpu.load!([0xa2, 0x66])
    assert_equal(0x00, @cpu.x)
    @cpu.step
    assert_equal(0x66, @cpu.x)
    assert_equal(0x602, @cpu.pc)
  end

  def test_0xa4
    @cpu.load!([0xa2, 0x42, 0x86, 0x32, 0xa4, 0x32])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x42, @cpu.y)
  end

  def test_0xa5
    @cpu.load!([0xa2, 0x42, 0x86, 0x32, 0xa5, 0x32])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x42, @cpu.a)
  end

  def test_0xa6
    @cpu.load!([0xa9, 0x42, 0x85, 0x32, 0xa6, 0x32])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x42, @cpu.x)
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

  def test_0xac
    @cpu.load!([0xac, 0x02, 0x06])
    @cpu.step
    assert_equal(0x06, @cpu.y)
  end

  def test_0xad
    @cpu.load!([0xad, 0x02, 0x06])
    @cpu.step
    assert_equal(0x06, @cpu.a)
  end

  def test_0xae
    @cpu.load!([0xae, 0x02, 0x06])
    @cpu.step
    assert_equal(0x06, @cpu.x)
  end

  def test_0xb0
    @cpu.load!([0x18, 0xb0, 0x03, 0x38, 0xb0, 0xfb, 0xa0, 0xff])
    @cpu.step
    @cpu.step
    assert_equal(0x603, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x601, @cpu.pc)
    @cpu.step
    assert_equal(0x606, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
  end

  def test_0xb1
    @cpu.load!([0xa2, 0x06, 0x86, 0x76, 0xa0, 0x04, 0xb1, 0x75])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0xa0, @cpu.a)
  end

  def test_0xb4
    @cpu.load!([0xa9, 0x80, 0x85, 0x05, 0xaa, 0xb4, 0x85])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x80, @cpu.y)
    assert_equal(0x80, @cpu.x)
    assert(@cpu.negative?)
  end

  def test_0xb5
    @cpu.load!([0xa2, 0x80, 0x86, 0x05, 0xb5, 0x85])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x80, @cpu.a)
    assert_equal(0x80, @cpu.x)
    assert(@cpu.negative?)
  end

  def test_0xb6
    @cpu.load!([0xa9, 0x80, 0x85, 0x05, 0xa8, 0xb6, 0x85])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x80, @cpu.x)
    assert_equal(0x80, @cpu.y)
    assert(@cpu.negative?)
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

  def test_0xb9
    @cpu.load!([0xa0, 0x01, 0xb9, 0x01, 0x06])
    @cpu.step
    @cpu.step
    assert_equal(0xb9, @cpu.a)
  end

  def test_0xba
    @cpu.load!([0xba])
    @cpu.step
    assert_equal(0xff, @cpu.x)
    assert_equal(0x601, @cpu.pc)
  end

  def test_0xbc
    @cpu.load!([0xa2, 0x01, 0xbc, 0x01, 0x06])
    @cpu.step
    @cpu.step
    assert_equal(0xbc, @cpu.y)
  end

  def test_0xbd
    @cpu.load!([0xa2, 0x01, 0xbd, 0x01, 0x06])
    @cpu.step
    @cpu.step
    assert_equal(0xbd, @cpu.a)
  end

  def test_0xbe
    @cpu.load!([0xa0, 0x65, 0xbe, 0x9c, 0x05])
    @cpu.step
    @cpu.step
    assert_equal(0x65, @cpu.x)
    assert_equal(0x65, @cpu.y)
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

  def test_0xc1
    @cpu.load!(
      [0xa0, 0x04, 0x84, 0xa1, 0x8c, 0x00, 0x04, 0xa2, 0x22, 0x98, 0xc1, 0x7e]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x04, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.zero?)
  end

  def test_0xc4
    @cpu.load!(
      [
        0xa9, 0x10, 0x85, 0x40, 0x69, 0x20, 0x85, 0x42, 0xa0, 0x20, 0x84, 0x41,
        0xc4, 0x40, 0xc4, 0x42, 0xc4, 0x41
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
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

  def test_0xc5
    @cpu.load!(
      [
        0xa9, 0x10, 0x85, 0x40, 0x69, 0x20, 0x85, 0x42, 0xa9, 0x20, 0x85, 0x41,
        0xc5, 0x40, 0xc5, 0x42, 0xc5, 0x41
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
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

  def test_0xcc
    @cpu.load!(
      [
        0xa9, 0x10, 0x85, 0x40, 0x69, 0x20, 0x85, 0x42, 0xa0, 0x20, 0x84, 0x41,
        0xcc, 0x40, 0x00, 0xcc, 0x42, 0x00, 0xcc, 0x41, 0x00
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
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

  def test_0xcd
    @cpu.load!(
      [
        0xa9, 0x10, 0x85, 0x40, 0x69, 0x20, 0x85, 0x42, 0xa9, 0x20, 0x85, 0x41,
        0xcd, 0x40, 0x00, 0xcd, 0x42, 0x00, 0xcd, 0x41, 0x00
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
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

  def test_0xd0
    @cpu.load!([0xa2, 0x00, 0xd0, 0x03, 0xe8, 0xd0, 0xfb, 0xa0, 0xff])
    @cpu.step
    @cpu.step
    assert_equal(0x604, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x602, @cpu.pc)
    @cpu.step
    assert_equal(0x607, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
  end

  def test_0xd1
    @cpu.load!(
      [
        0xa9, 0x95, 0xa2, 0x06, 0x86, 0x76, 0xa0, 0x01,
        0xd1, 0x75, 0xc8, 0xd1, 0x75, 0xc8, 0xd1, 0x75
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x95, @cpu.a)
    assert(@cpu.carry?)
    refute(@cpu.negative?)
    assert(@cpu.zero?)

    @cpu.step
    @cpu.step
    assert_equal(0x95, @cpu.a)
    refute(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)

    @cpu.step
    @cpu.step
    assert_equal(0x95, @cpu.a)
    assert(@cpu.carry?)
    assert(@cpu.negative?)
    refute(@cpu.zero?)
  end

  def test_0xd5
    @cpu.load!([0xa9, 0x22, 0xaa, 0xca, 0x85, 0x32, 0xd5, 0x11])
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x22, @cpu.a)
    assert_equal(0x21, @cpu.x)
    assert(@cpu.carry?)
    assert(@cpu.zero?)
    refute(@cpu.negative?)
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

  def test_0xd9
    @cpu.load!([0xa9, 0x22, 0xa8, 0xd9, 0xdf, 0x05])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x22, @cpu.a)
    assert_equal(0x22, @cpu.y)
    assert(@cpu.zero?)
  end

  def test_0xdd
    @cpu.load!([0xa9, 0x22, 0xaa, 0xdd, 0xdf, 0x05])
    @cpu.step
    @cpu.step
    @cpu.step
    assert_equal(0x22, @cpu.a)
    assert_equal(0x22, @cpu.x)
    assert(@cpu.zero?)
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

  def test_0xe4
    @cpu.load!(
      [
        0xa9, 0x10, 0x85, 0x40, 0x69, 0x20, 0x85, 0x42, 0xa9, 0x20, 0x85, 0x41,
        0xaa, 0xe4, 0x40, 0xe4, 0x42, 0xe4, 0x41
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
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

  def test_0xec
    @cpu.load!(
      [
        0xa9, 0x10, 0x85, 0x40, 0x69, 0x20, 0x85, 0x42, 0xa2, 0x20, 0x86, 0x41,
        0xec, 0x40, 0x00, 0xec, 0x42, 0x00, 0xec, 0x41, 0x00
      ]
    )
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
    @cpu.step
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

  def test_0xf0
    @cpu.load!([0xa2, 0x01, 0xf0, 0x03, 0xca, 0xf0, 0xfb, 0xa0, 0xff])
    @cpu.step
    @cpu.step
    assert_equal(0x604, @cpu.pc)
    @cpu.step
    @cpu.step
    assert_equal(0x602, @cpu.pc)
    @cpu.step
    assert_equal(0x607, @cpu.pc)
    @cpu.step
    assert_equal(0xff, @cpu.y)
  end
end
