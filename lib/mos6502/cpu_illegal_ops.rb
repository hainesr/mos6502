# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'cpu_ops'

module Mos6502
  class Cpu
    private

    def dcp(address)
      value = dec(@memory.get(address))
      @memory.set(address, value)
      compare(@a, value)
    end

    def isc(address)
      value = inc(@memory.get(address))
      @memory.set(address, value)
      sbc(value)
    end
  end
end
