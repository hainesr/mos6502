# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502/cpu'

# A class to expose some internals of the Cpu.
class TestCpu < Mos6502::Cpu
  def instructions_list
    @instructions.keys
  end

  def stack_ptr_dec
    stack_push(0x00)
  end

  def stack_ptr_inc
    stack_pop
  end
end

# Test manipulating the stack pointer to ensure correct behaviour.
class Mos6502::CpuStackPointerTest < Minitest::Test
  def setup
    @cpu = TestCpu.new
  end

  def test_stack_dec
    # Check normal decrementing.
    assert_equal(0xff, @cpu.sp)
    @cpu.stack_ptr_dec
    assert_equal(0xfe, @cpu.sp)
    @cpu.stack_ptr_dec
    assert_equal(0xfd, @cpu.sp)

    # Go right down to 1.
    0xfc.times { @cpu.stack_ptr_dec }
    assert_equal(0x01, @cpu.sp)

    # Check wrapping.
    @cpu.stack_ptr_dec
    assert_equal(0x00, @cpu.sp)
    @cpu.stack_ptr_dec
    assert_equal(0xff, @cpu.sp)
    @cpu.stack_ptr_dec
    assert_equal(0xfe, @cpu.sp)
  end

  def test_stack_inc
    assert_equal(0xff, @cpu.sp)
    @cpu.stack_ptr_inc
    assert_equal(0x00, @cpu.sp)
    @cpu.stack_ptr_inc
    assert_equal(0x01, @cpu.sp)
    @cpu.stack_ptr_inc
    assert_equal(0x02, @cpu.sp)
  end
end

# This test is really just to help make maintenance easier.
class Mos6502::CpuInstructionsOrderTest < Minitest::Test
  def test_cpu_instructions_order
    cpu = TestCpu.new
    instructions = cpu.instructions_list
    assert_equal(
      instructions.sort, instructions,
      'CPU instructions should be in ascending numerical order'
    )
  end
end
