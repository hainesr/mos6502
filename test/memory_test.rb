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
    assert_equal(0x00, @memory.get_word(0x00))
  end

  def test_write
    @memory.set(0x00, 0xff)
    assert_equal(0xff, @memory.get(0x00))
    assert_equal(0x00, @memory.get(0xff))
  end

  def test_write_word_just_writes_lo_byte
    @memory.set(0x00, 0x2010)
    assert_equal(0x10, @memory.get(0x00))
    assert_equal(0x00, @memory.get(0x01))
  end

  def test_read_word
    @memory.set(0x7f, 0x10)
    @memory.set(0x80, 0x20)
    assert_equal(0x2010, @memory.get_word(0x7f))
    assert_equal(0x20, @memory.get_word(0x80))
  end

  def test_dump_empty
    assert_equal([0x00, 0x00, 0x00, 0x00], @memory.dump(0x00, 4))
    assert_equal([0x00, 0x00, 0x00, 0x00], @memory.dump(0x4f, 4))
  end

  def test_dump_set
    bytes = [0xa9, 0xc0, 0xaa, 0xe8, 0x69, 0xc4, 0x00]
    bytes.each_with_index { |b, i| @memory.set(0x600 + i, b) }

    assert_equal(bytes[0, 4], @memory.dump(0x600, 4))
    assert_equal(bytes[1, 4], @memory.dump(0x601, 4))
    assert_equal(bytes[3, 4], @memory.dump(0x603, 4))
    assert_equal([0xc4, 0x00, 0x00, 0x00], @memory.dump(0x605, 4))
  end
end
