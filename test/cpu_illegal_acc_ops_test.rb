# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuIllegalAccumulatorOperationsTest < Minitest::Test
  def test_zero_page
    # 0xb3 <OP> 0x80
    [
      [0x07, 0xb3, 0x00, true, false, true, false],  # SLO
      [0x27, 0x00, 0x00, false, true, true, false],  # RLA
      [0x47, 0xf3, 0x40, true, false, false, false], # SRE
      [0xc7, 0xb3, 0x7f, false, false, true, false], # DCP
      [0xe7, 0x31, 0x81, false, false, true, false]  # ISC
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
      cpu.load!([0xa9, 0xb3, 0xa2, 0x80, 0x86, 0x41, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x41, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_zero_page_x
    # 0xb3 <OP> 0xb3
    [
      [0x17, 0xf7, 0x66, true, false, true, false],  # SLO
      [0x37, 0x22, 0x66, false, false, true, false], # RLA
      [0x57, 0xea, 0x59, true, false, true, false],  # SRE
      [0xd7, 0xb3, 0xb2, false, false, true, false], # DCP
      [0xf7, 0xfe, 0xb4, true, false, false, false]  # ISC
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
      cpu.load!([0xa9, 0xb3, 0xa2, 0x12, 0xa0, 0xb3, 0x94, 0x41, opcode, 0x41])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x53, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_absolute
    # 0x33 <OP> 0xcc
    [
      [0x0f, 0xbb, 0x98, true, false, true, false],   # SLO
      [0x2f, 0x10, 0x98, false, false, true, false],  # RLA
      [0x4f, 0x55, 0x66, false, false, false, false], # SRE
      [0xcf, 0x33, 0xcb, false, false, false, false], # DCP
      [0xef, 0x65, 0xcd, false, false, false, false]  # ISC
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
      cpu.load!([0xa9, 0x33, 0xa2, 0xcc, 0x8e, 0x41, 0x85, opcode, 0x41, 0x85])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x8541, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_absolute_x
    # 0x33 <OP> 0xcc
    [
      [0x1f, 0xbb, 0x98, true, false, true, false],   # SLO
      [0x3f, 0x10, 0x98, false, false, true, false],  # RLA
      [0xdf, 0x33, 0xcb, false, false, false, false], # DCP
      [0xff, 0x65, 0xcd, false, false, false, false]  # ISC
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
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
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x85ed, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_absolute_y
    # 0x33 <OP> 0xcd
    [
      [0x1b, 0xbb, 0x9a, true, false, true, false],   # SLO
      [0x3b, 0x12, 0x9a, false, false, true, false],  # RLA
      [0x5b, 0x55, 0x66, false, false, true, false],  # SRE
      [0xdb, 0x33, 0xcc, false, false, false, false], # DCP
      [0xfb, 0x64, 0xce, false, false, false, false]  # ISC
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
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
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x85ed, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end

  def test_indexed_indirect
    # 0x3f <OP> 0xb3
    [
      [0x03, 0x7f, 0x66, false, false, true, false], # SLO
      [0x23, 0x26, 0x66, false, false, true, false], # RLA
      [0x43, 0x66, 0x59, false, false, true, false], # SRE
      [0xc3, 0x3f, 0xb2, true, false, false, false], # DCP
      [0xe3, 0x8a, 0xb4, true, false, false, true]   # ISC
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

  def test_indirect_indexed
    # 0x3f <OP> 0xa0
    [
      [0x13, 0x7f, 0x40, false, false, true, false],  # SLO
      [0x33, 0x00, 0x40, false, true, true, false],   # RLA
      [0x53, 0x6f, 0x50, false, false, false, false], # SRE
      [0xd3, 0x3f, 0x9f, true, false, false, false],  # DCP
      [0xf3, 0x9d, 0xa1, true, false, false, true]    # ISC
    ].each do |opcode, a, mem, negative, zero, carry, overflow|
      cpu = Mos6502::Cpu.new(allow_illegal_ops: true)
      cpu.load!([0xa2, 0x06, 0x86, 0x76, 0xa0, 0x04, 0xa9, 0x3f, opcode, 0x75])
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      cpu.step
      assert_equal(a, cpu.a)
      assert_equal([mem], cpu.dump_memory(0x0604, 1))
      assert_equal(negative, cpu.negative?)
      assert_equal(zero, cpu.zero?)
      assert_equal(carry, cpu.carry?)
      assert_equal(overflow, cpu.overflow?)
    end
  end
end
