# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuAccumulatorOperationsTest < Minitest::Test
  def test_immediate
    # 0x33 <OP> 0x55
    [
      [0x09, 0x77, false, false, false, false], # ORA
      [0x29, 0x11, false, false, false, false], # AND
      [0x49, 0x66, false, false, false, false], # EOR
      [0x69, 0x88, true, false, false, true],   # ADC
      [0xe9, 0xdd, true, false, false, false]   # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0x33, opcode, 0x55])
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_zero_page
    # 0xb3 <OP> 0x80
    [
      [0x05, 0xb3, true, false, false, false],  # ORA
      [0x25, 0x80, true, false, false, false],  # AND
      [0x45, 0x33, false, false, false, false], # EOR
      [0x65, 0x33, false, false, true, true],   # ADC
      [0xe5, 0x32, false, false, true, false]   # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0xb3, 0xa2, 0x80, 0x86, 0x41, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_zero_page_x
    # 0xb3 <OP> 0xb3
    [
      [0x15, 0xb3, true, false, false, false], # ORA
      [0x35, 0xb3, true, false, false, false], # AND
      [0x55, 0x00, false, true, false, false], # EOR
      [0x75, 0x66, false, false, true, true],  # ADC
      [0xf5, 0xff, true, false, false, false]  # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
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
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_absolute
    # 0x33 <OP> 0xcc
    [
      [0x0d, 0xff, true, false, false, false], # ORA
      [0x2d, 0x00, false, true, false, false], # AND
      [0x4d, 0xff, true, false, false, false], # EOR
      [0x6d, 0xff, true, false, false, false], # ADC
      [0xed, 0x66, false, false, false, false] # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new
      cpu.load!([0xa9, 0x33, 0xa2, 0xcc, 0x8e, 0x41, 0x85, opcode, 0x41, 0x85])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(result, cpu.a)
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_absolute_x
    # 0x33 <OP> 0xcc
    [
      [0x1d, 0xff, true, false, false, false], # ORA
      [0x3d, 0x00, false, true, false, false], # AND
      [0x5d, 0xff, true, false, false, false], # EOR
      [0x7d, 0xff, true, false, false, false], # ADC
      [0xfd, 0x66, false, false, false, false] # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
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
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_absolute_y
    # 0x33 <OP> 0xcd
    [
      [0x19, 0xff, true, false, false, false],  # ORA
      [0x39, 0x01, false, false, false, false], # AND
      [0x59, 0xfe, true, false, false, false],  # EOR
      [0x79, 0x00, false, true, true, false],   # ADC
      [0xf9, 0x65, false, false, false, false]  # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
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
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_indexed_indirect
    # 0x3f <OP> 0xb3
    [
      [0x01, 0xbf, true, false, false, false],  # ORA
      [0x21, 0x33, false, false, false, false], # AND
      [0x41, 0x8c, true, false, false, false],  # EOR
      [0x61, 0xf2, true, false, false, false],  # ADC
      [0xe1, 0x8b, true, false, false, true]    # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
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
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_indirect_indexed
    # 0x3f <OP> 0xa0
    [
      [0x11, 0xbf, true, false, false, false],  # ORA
      [0x31, 0x20, false, false, false, false], # AND
      [0x51, 0x9f, true, false, false, false],  # EOR
      [0x71, 0xdf, true, false, false, false],  # ADC
      [0xf1, 0x9e, true, false, false, true]    # SBC
    ].each do |opcode, result, negative, zero, carry, overflow|
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
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end
end
