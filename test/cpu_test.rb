# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuTest < Minitest::Test
  def setup
    @code_bytes = [0xa9, 0xc0, 0xaa, 0xe8, 0x69, 0xc4, 0x00]
    @code_string = "\xA9\xC0\xAA\xE8i\xC4\x00"
  end

  def test_init_cpu
    cpu = Mos6502::Cpu.new
    assert_equal(0x00, cpu.a)
    assert_equal(0x00, cpu.x)
    assert_equal(0x00, cpu.y)
    assert_equal(0xff, cpu.sp)
    assert_equal(0x600, cpu.pc)
    assert_equal(
      'a: 0x00, x: 0x00, y: 0x00, sp: 0xff, ' \
      'pc: 0x0600, op: 0x00, status: 0b00100000',
      cpu.inspect
    )
  end

  def test_init_cpu_pc
    cpu = Mos6502::Cpu.new(initial_pc: 0x500)
    assert_equal(0x00, cpu.a)
    assert_equal(0x00, cpu.x)
    assert_equal(0x00, cpu.y)
    assert_equal(0xff, cpu.sp)
    assert_equal(0x500, cpu.pc)
    assert_equal(
      'a: 0x00, x: 0x00, y: 0x00, sp: 0xff, ' \
      'pc: 0x0500, op: 0x00, status: 0b00100000',
      cpu.inspect
    )
  end

  def test_init_cpu_code_bytes
    cpu = Mos6502::Cpu.new(code: @code_bytes)
    assert_equal(0x600, cpu.pc)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))
  end

  def test_init_cpu_code_string_pc
    cpu = Mos6502::Cpu.new(code: @code_string, initial_pc: 0x400)
    assert_equal(0x400, cpu.pc)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))
  end

  def test_load_bytes_after_pc_init
    cpu = Mos6502::Cpu.new(initial_pc: 0x500)
    cpu.load!(@code_bytes)
    assert_equal(0x500, cpu.pc)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))
  end

  def test_load_string
    cpu = Mos6502::Cpu.new
    cpu.load!(@code_string)
    assert_equal(0x600, cpu.pc)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))
  end

  def test_cpu_load_nil_resets
    cpu = Mos6502::Cpu.new(code: @code_string)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))

    cpu.load!
    assert_equal([0x00] * 7, cpu.dump_memory(cpu.pc, 7))
  end

  def test_cpu_load_empty_string_resets
    cpu = Mos6502::Cpu.new(code: @code_string)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))

    cpu.load!('')
    assert_equal([0x00] * 7, cpu.dump_memory(cpu.pc, 7))
  end

  def test_cpu_load_empty_array_resets
    cpu = Mos6502::Cpu.new(code: @code_string)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))

    cpu.load!([])
    assert_equal([0x00] * 7, cpu.dump_memory(cpu.pc, 7))
  end

  def test_load_image_empty_string_resets
    cpu = Mos6502::Cpu.new(code: @code_string)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))

    cpu.load_image!('')
    assert_equal([0x00] * 7, cpu.dump_memory(cpu.pc, 7))
  end

  def test_load_image_empty_array_resets
    cpu = Mos6502::Cpu.new(code: @code_string)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))

    cpu.load_image!([])
    assert_equal([0x00] * 7, cpu.dump_memory(cpu.pc, 7))
  end

  def test_load_image_nil_resets
    cpu = Mos6502::Cpu.new(code: @code_string)
    assert_equal(@code_bytes, cpu.dump_memory(cpu.pc, 7))

    cpu.load_image!
    assert_equal([0x00] * 7, cpu.dump_memory(cpu.pc, 7))
  end
end
