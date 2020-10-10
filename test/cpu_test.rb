# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::CpuTest < Minitest::Test
  def test_init_cpu
    cpu = Mos6502::Cpu.new
    assert_equal(0x00, cpu.a)
    assert_equal(0x00, cpu.x)
    assert_equal(0x00, cpu.y)
    assert_equal(0x01ff, cpu.sp)
    assert_equal(0x600, cpu.pc)
  end

  def test_init_cpu_pc
    cpu = Mos6502::Cpu.new(0x500)
    assert_equal(0x00, cpu.a)
    assert_equal(0x00, cpu.x)
    assert_equal(0x00, cpu.y)
    assert_equal(0x01ff, cpu.sp)
    assert_equal(0x500, cpu.pc)
  end
end
