# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::Suites::Klaus2m5 < Mos6502::Suites::Runner
  IMAGE_FILE = '6502_functional_test.bin'
  IMAGE_PATH = File.expand_path(
    File.join('6502_65C02_functional_tests', 'bin_files', IMAGE_FILE), __dir__
  )
  SUCCESS_PC = 0x3469

  def test_6502
    image = File.read(IMAGE_PATH).bytes
    cpu = Mos6502::Cpu.new(initial_pc: 0x400)
    cpu.load_image!(image)

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
    end

    if last_pc == SUCCESS_PC
      pass
    else
      flunk(
        "#{message}\n" \
        "Memory at break point (PC: #{format('0x%04x', last_pc)}):\n" +
        image[last_pc, 8].map { |b| format('0x%02x', b) }.join(', ')
      )
    end
  end
end
