# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::Suites::NesTest < Mos6502::Suites::Runner
  IMAGE_FILE = 'nestest.nes'
  IMAGE_PATH = File.expand_path(IMAGE_FILE, __dir__)
  NES_HEADER_SIZE = 0x10
  NES_PRG_BLOCK_SIZE = 0x4000
  NES_PRG_LOAD_LOC = 0xc000
  SUCCESS_PC = 0xc66e

  def test_nes
    image = File.read(IMAGE_PATH).bytes
    cpu = Mos6502::Cpu.new(
      initial_pc: NES_PRG_LOAD_LOC, disable_bcd: true, allow_illegal_ops: true
    )
    cpu.load_image!(
      image[NES_HEADER_SIZE...(NES_HEADER_SIZE + NES_PRG_BLOCK_SIZE)],
      NES_PRG_LOAD_LOC
    )

    last_pc = 0
    message = loop do
      last_pc = cpu.pc
      puts cpu.inspect if output == :debug

      begin
        cpu.step
      rescue NoMethodError
        break 'Reached an unimplemented instruction.'
      end

      # Run until we hit a jump/break trap.
      break 'Reached a jump/break trap.' if last_pc == cpu.pc

      # Or until we hit what it seems is the end?
      break if last_pc == SUCCESS_PC
    end

    if last_pc == SUCCESS_PC
      assert_equal([0x00, 0x00], cpu.dump_memory(2, 2))
    else
      code_loc = last_pc - (NES_PRG_LOAD_LOC - NES_HEADER_SIZE)
      flunk(
        "#{message}\n" \
        "Memory at break point (PC: #{format('0x%04x', last_pc)}):\n" +
        image[code_loc, 8].map { |b| format('0x%02x', b) }.join(', ')
      )
    end
  end
end
