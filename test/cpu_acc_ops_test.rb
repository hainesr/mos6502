# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuAccumulaterOperationsTest < Minitest::Test
  def test_immediate
    [
      [0x29, 0x11, false, false] # AND
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0x33, opcode, 0x55])
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_zero_page
    [
      [0x25, 0x80, true, false], # AND
      [0x45, 0x33, false, false] # EOR
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0xb3, 0xa2, 0x80, 0x86, 0x41, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_zero_page_x
    [
      [0x35, 0xb3, true, false] # AND
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0xb3, 0xa2, 0x12, 0xa0, 0xb3, 0x94, 0x41, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_absolute
    [
      [0x2d, 0x00, false, true], # AND
      [0x4d, 0xff, true, false]  # EOR
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0x33, 0xa2, 0xcc, 0x8e, 0x41, 0x85, opcode, 0x41, 0x85])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_absolute_x
    [
      [0x3d, 0x00, false, true] # AND
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!(
        [
          0xa9, 0x33, 0xa2, 0x56, 0xa0, 0xcc, 0x8c, 0xed, 0x85,
          opcode, 0x97, 0x85
        ]
      )
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_absolute_y
    [
      [0x39, 0x01, false, false] # AND
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!(
        [
          0xa9, 0x33, 0xa0, 0x56, 0xa2, 0xcd, 0x8e, 0xed, 0x85,
          opcode, 0x97, 0x85
        ]
      )
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_indexed_indirect
    [
      [0x21, 0x33, false, false] # AND
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0xb3, 0xa2, 0xd0, 0x81, 0x41, 0xa9, 0x3f, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end

  def test_indirect_indexed
    [
      [0x31, 0x20, false, false] # AND
    ].each do |opcode, result, negative, zero|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa2, 0x06, 0x86, 0x76, 0xa0, 0x04, 0xa9, 0x3f, opcode, 0x75])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
    end
  end
end