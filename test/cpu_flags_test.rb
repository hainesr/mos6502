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

  def test_encode
    assert_equal(0b00110000, @flags.encode)

    @flags.carry = true
    assert_equal(0b00110001, @flags.encode)

    @flags.negative = true
    assert_equal(0b10110001, @flags.encode)

    @flags.interupt_disable = true
    assert_equal(0b10110101, @flags.encode)

    @flags.break = true
    assert_equal(0b10110101, @flags.encode)

    @flags.overflow = true
    assert_equal(0b11110101, @flags.encode)

    @flags.zero = true
    assert_equal(0b11110111, @flags.encode)

    @flags.decimal_mode = true
    assert_equal(0b11111111, @flags.encode)
  end

  def test_decode
    @flags.decode(0b11111111)
    assert(@flags.break?)
    assert(@flags.carry?)
    assert(@flags.decimal_mode?)
    assert(@flags.interupt_disable?)
    assert(@flags.negative?)
    assert(@flags.overflow?)
    assert(@flags.zero?)

    @flags.decode(0)
    refute(@flags.break?)
    refute(@flags.carry?)
    refute(@flags.decimal_mode?)
    refute(@flags.interupt_disable?)
    refute(@flags.negative?)
    refute(@flags.overflow?)
    refute(@flags.zero?)

    @flags.decode(0b11111111)
    @flags.decode(0b00100000)
    refute(@flags.break?)
    refute(@flags.carry?)
    refute(@flags.decimal_mode?)
    refute(@flags.interupt_disable?)
    refute(@flags.negative?)
    refute(@flags.overflow?)
    refute(@flags.zero?)
  end
end
