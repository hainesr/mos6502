# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502/memory'

class Mos6502::MemoryTest < Minitest::Test
  def setup
    @memory = Mos6502::Memory.new
  end

  def test_read_before_write
    assert_equal(0x00, @memory.get(0x00))
    assert_equal(0x00, @memory.get(0xff))
  end

  def test_write
    @memory.set(0x00, 0xff)
    assert_equal(0xff, @memory.get(0x00))
    assert_equal(0x00, @memory.get(0xff))
  end

  def test_write_word_just_writes_byte
    @memory.set(0x00, 0x1010)
    assert_equal(0x10, @memory.get(0x00))
    assert_equal(0x00, @memory.get(0x01))
  end

  def test_read_word
    @memory.set(0x7f, 0x10)
    @memory.set(0x80, 0x20)
    assert_equal(0x2010, @memory.get_word(0x7f))
  end
end
