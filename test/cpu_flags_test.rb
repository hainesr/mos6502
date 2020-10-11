# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502/cpu_flags'

class Mos6502::CpuFlagsTest < Minitest::Test
  def setup
    @flags = Mos6502::CpuFlags.new
  end

  def test_init
    refute(@flags.break?)
    refute(@flags.carry?)
    refute(@flags.decimal_mode?)
    refute(@flags.interupt_disable?)
    refute(@flags.negative?)
    refute(@flags.overflow?)
    refute(@flags.zero?)
  end
end
