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
end
