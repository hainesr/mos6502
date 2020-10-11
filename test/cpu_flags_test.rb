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

  def test_set_flags
    [
      [true, true],
      [false, false],
      [1, true],
      [0, false],
      [:what?, true],
      [nil, false]
    ].each do |flag, set|
      @flags.carry = flag
      assert_equal(set, @flags.carry?)

      @flags.zero = flag
      assert_equal(set, @flags.zero?)

      @flags.interupt_disable = flag
      assert_equal(set, @flags.interupt_disable?)

      @flags.decimal_mode = flag
      assert_equal(set, @flags.decimal_mode?)

      @flags.break = flag
      assert_equal(set, @flags.break?)

      @flags.overflow = flag
      assert_equal(set, @flags.overflow?)

      @flags.negative = flag
      assert_equal(set, @flags.negative?)
    end
  end

  def test_reset
    @flags.carry = true
    @flags.zero = true
    @flags.interupt_disable = true
    @flags.decimal_mode = true
    @flags.break = true
    @flags.overflow = true
    @flags.negative = true

    @flags.reset!

    refute(@flags.break?)
    refute(@flags.carry?)
    refute(@flags.decimal_mode?)
    refute(@flags.interupt_disable?)
    refute(@flags.negative?)
    refute(@flags.overflow?)
    refute(@flags.zero?)
  end
end
