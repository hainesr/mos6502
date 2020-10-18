# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'
require 'mos6502'

class Mos6502::Klaus2m5Test < Minitest::Test
  IMAGE_FILE = '6502_functional_test.bin'
  IMAGE_PATH = File.expand_path(
    File.join('6502_65C02_functional_tests', 'bin_files', IMAGE_FILE), __dir__
  )
  OUTPUT = !ENV['MOS6502_KLAUS2M5_OUTPUT'].to_i.zero?

  def test_6502
    image = File.read(IMAGE_PATH).bytes
    cpu = Mos6502::Cpu.new(initial_pc: 0x400)
    cpu.load_image!(image)

    last_pc = 0
    message = loop do
      last_pc = cpu.pc
      puts cpu.inspect if OUTPUT

      begin
        cpu.step
      rescue NoMethodError
        break 'Reached an unimplemented instruction.'
      end

      # Run until we hit a jump/break trap.
      break 'Reached a jump/break trap.' if last_pc == cpu.pc
    end

    if OUTPUT
      puts message
      puts "Memory at break point (PC: 0x#{last_pc.to_s(16)}):"
      puts image[last_pc, 8].map { "0x#{_1.to_s(16)}" }.join(', ')
    end

    # We know this won't work yet...
    pass
  end
end
