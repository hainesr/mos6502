# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502/cpu'

# A class to expose the list of Cpu instructions.
class TestCpu < Mos6502::Cpu
  def instructions_list
    @instructions.keys
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
