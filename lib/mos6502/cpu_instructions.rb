# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'cpu_ops'

module Mos6502
  class Cpu
    private

    def instructions
      {
        # BRK
        0x00 => lambda {
          @pc += 1
          stack_push((@pc >> 8) & 0xff)
          stack_push(@pc & 0xff)
          stack_push(@status.encode)
          @pc = @memory.get_word(0xfffe)
          @status.break = true
          @status.interupt_disable = true
        },

        # ORA (indexed indirect)
        0x01 => lambda {
          @a |= @memory.get(indexed_indirect)
          set_nz_flags(@a)
        },

        # ORA (zero page)
        0x05 => lambda {
          @a |= @memory.get(zero_page)
          set_nz_flags(@a)
        },

        # ASL (zero page)
        0x06 => lambda {
          address = zero_page
          @memory.set(address, asl(@memory.get(address)))
        },

        # PHP
        0x08 => lambda {
          stack_push(@status.encode)
        },

        # ORA (immediate)
        0x09 => lambda {
          @a |= next_byte
          set_nz_flags(@a)
        },

        # ASL (accumulator)
        0x0a => lambda {
          @a = asl(@a) & 0xff
        },

        # ORA (absolute)
        0x0d => lambda {
          @a |= @memory.get(absolute)
          set_nz_flags(@a)
        },

        # ASL (absolute)
        0x0e => lambda {
          address = absolute
          @memory.set(address, asl(@memory.get(address)))
        },

        # BPL
        0x10 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.negative?
        },

        # ORA (indirect indexed)
        0x11 => lambda {
          @a |= @memory.get(indirect_indexed)
          set_nz_flags(@a)
        },

        # ORA (zero page, X)
        0x15 => lambda {
          @a |= @memory.get(zero_page(@x))
          set_nz_flags(@a)
        },

        # ASL (zero page, X)
        0x16 => lambda {
          address = zero_page(@x)
          @memory.set(address, asl(@memory.get(address)))
        },

        # CLC
        0x18 => lambda {
          @status.carry = false
        },

        # ORA (absolute, Y)
        0x19 => lambda {
          @a |= @memory.get(absolute(@y))
          set_nz_flags(@a)
        },

        # ORA (absolute, X)
        0x1d => lambda {
          @a |= @memory.get(absolute(@x))
          set_nz_flags(@a)
        },

        # ASL (absolute, X)
        0x1e => lambda {
          address = absolute(@x)
          @memory.set(address, asl(@memory.get(address)))
        },

        # JSR
        0x20 => lambda {
          jump_to = absolute
          return_to = @pc - 1
          stack_push((return_to >> 8) & 0xff)
          stack_push(return_to & 0xff)
          @pc = jump_to
        },

        # AND (indexed indirect)
        0x21 => lambda {
          @a &= @memory.get(indexed_indirect)
          set_nz_flags(@a)
        },

        # BIT (zero page)
        0x24 => lambda {
          bit(@memory.get(zero_page))
        },

        # AND (zero page)
        0x25 => lambda {
          @a &= @memory.get(zero_page)
          set_nz_flags(@a)
        },

        # ROL (zero page)
        0x26 => lambda {
          address = zero_page
          @memory.set(address, rol(@memory.get(address)))
        },

        # PLP
        0x28 => lambda {
          @status.decode(stack_pop)
        },

        # AND (immediate)
        0x29 => lambda {
          @a &= next_byte
          set_nz_flags(@a)
        },

        # ROL (accumulator)
        0x2a => lambda {
          @a = rol(@a) & 0xff
        },

        # BIT (absolute)
        0x2c => lambda {
          bit(@memory.get(absolute))
        },

        # AND (absolute)
        0x2d => lambda {
          @a &= @memory.get(absolute)
          set_nz_flags(@a)
        },

        # ROL (absolute)
        0x2e => lambda {
          address = absolute
          @memory.set(address, rol(@memory.get(address)))
        },

        # BMI
        0x30 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.negative?
        },

        # AND (indirect indexed)
        0x31 => lambda {
          @a &= @memory.get(indirect_indexed)
          set_nz_flags(@a)
        },

        # AND (zero page, X)
        0x35 => lambda {
          @a &= @memory.get(zero_page(@x))
          set_nz_flags(@a)
        },

        # ROL (zero page, X)
        0x36 => lambda {
          address = zero_page(@x)
          @memory.set(address, rol(@memory.get(address)))
        },

        # SEC
        0x38 => lambda {
          @status.carry = true
        },

        # AND (absolute, Y)
        0x39 => lambda {
          @a &= @memory.get(absolute(@y))
          set_nz_flags(@a)
        },

        # AND (absolute, X)
        0x3d => lambda {
          @a &= @memory.get(absolute(@x))
          set_nz_flags(@a)
        },

        # ROL (absolute, X)
        0x3e => lambda {
          address = absolute(@x)
          @memory.set(address, rol(@memory.get(address)))
        },

        # RTI
        0x40 => lambda {
          @status.decode(stack_pop)
          @pc = (stack_pop | (stack_pop << 8))
        },

        # EOR (indexed indirect)
        0x41 => lambda {
          @a ^= @memory.get(indexed_indirect)
          set_nz_flags(@a)
        },

        # EOR (zero page)
        0x45 => lambda {
          @a ^= @memory.get(zero_page)
          set_nz_flags(@a)
        },

        # LSR (zero page)
        0x46 => lambda {
          address = zero_page
          @memory.set(address, lsr(@memory.get(address)))
        },

        # PHA
        0x48 => lambda {
          stack_push(@a)
        },

        # EOR (immediate)
        0x49 => lambda {
          @a ^= next_byte
          set_nz_flags(@a)
        },

        # LSR (accumulator)
        0x4a => lambda {
          @a = lsr(@a)
        },

        # JMP (absolute)
        0x4c => lambda {
          @pc = absolute
        },

        # EOR (absolute)
        0x4d => lambda {
          @a ^= @memory.get(absolute)
          set_nz_flags(@a)
        },

        # LSR (absolute)
        0x4e => lambda {
          address = absolute
          @memory.set(address, lsr(@memory.get(address)))
        },

        # BVC
        0x50 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.overflow?
        },

        # EOR (indirect indexed)
        0x51 => lambda {
          @a ^= @memory.get(indirect_indexed)
          set_nz_flags(@a)
        },

        # EOR (zero page, X)
        0x55 => lambda {
          @a ^= @memory.get(zero_page(@x))
          set_nz_flags(@a)
        },

        # LSR (zero page, X)
        0x56 => lambda {
          address = zero_page(@x)
          @memory.set(address, lsr(@memory.get(address)))
        },

        # CLI
        0x58 => lambda {
          @status.interupt_disable = false
        },

        # EOR (absolute, Y)
        0x59 => lambda {
          @a ^= @memory.get(absolute(@y))
          set_nz_flags(@a)
        },

        # EOR (absolute, X)
        0x5d => lambda {
          @a ^= @memory.get(absolute(@x))
          set_nz_flags(@a)
        },

        # LSR (absolute, X)
        0x5e => lambda {
          address = absolute(@x)
          @memory.set(address, lsr(@memory.get(address)))
        },

        # RTS
        0x60 => lambda {
          @pc = (stack_pop | (stack_pop << 8)) + 1
        },

        # ADC (indexed indirect)
        0x61 => lambda {
          adc(@memory.get(indexed_indirect))
        },

        # ADC (zero page)
        0x65 => lambda {
          adc(@memory.get(zero_page))
        },

        # ROR (zero page)
        0x66 => lambda {
          address = zero_page
          @memory.set(address, ror(@memory.get(address)))
        },

        # PLA
        0x68 => lambda {
          @a = stack_pop
          set_nz_flags(@a)
        },

        # ADC (immediate)
        0x69 => lambda {
          adc(next_byte)
        },

        # ROR (accumulator)
        0x6a => lambda {
          @a = ror(@a)
        },

        # JMP (indirect)
        0x6c => lambda {
          @pc = indirect
        },

        # ADC (absolute)
        0x6d => lambda {
          adc(@memory.get(absolute))
        },

        # ROR (absolute)
        0x6e => lambda {
          address = absolute
          @memory.set(address, ror(@memory.get(address)))
        },

        # BVS
        0x70 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.overflow?
        },

        # ADC (zero page, X)
        0x75 => lambda {
          adc(@memory.get(zero_page(@x)))
        },

        # ROR (zero page, X)
        0x76 => lambda {
          address = zero_page(@x)
          @memory.set(address, ror(@memory.get(address)))
        },

        # SEI
        0x78 => lambda {
          @status.interupt_disable = true
        },

        # ADC (absolute, Y)
        0x79 => lambda {
          adc(@memory.get(absolute(@y)))
        },

        # ADC (absolute, X)
        0x7d => lambda {
          adc(@memory.get(absolute(@x)))
        },

        # ROR (absolute, X)
        0x7e => lambda {
          address = absolute(@x)
          @memory.set(address, ror(@memory.get(address)))
        },

        # STA (indexed indirect)
        0x81 => lambda {
          @memory.set(indexed_indirect, @a)
        },

        # STY (zero page)
        0x84 => lambda {
          @memory.set(zero_page, @y)
        },

        # STA (zero page)
        0x85 => lambda {
          @memory.set(zero_page, @a)
        },

        # STX (zero page)
        0x86 => lambda {
          @memory.set(zero_page, @x)
        },

        # DEY
        0x88 => lambda {
          @y = dec(@y) & 0xff
        },

        # TXA
        0x8a => lambda {
          @a = @x & 0xff
          set_nz_flags(@a)
        },

        # STY (absolute)
        0x8c => lambda {
          @memory.set(absolute, @y)
        },

        # STA (absolute)
        0x8d => lambda {
          @memory.set(absolute, @a)
        },

        # STX (absolute)
        0x8e => lambda {
          @memory.set(absolute, @x)
        },

        # BCC
        0x90 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.carry?
        },

        # STA (indirect indexed)
        0x91 => lambda {
          @memory.set(indirect_indexed, @a)
        },

        # STY (zero page, X)
        0x94 => lambda {
          @memory.set(zero_page(@x), @y)
        },

        # STA (zero page, X)
        0x95 => lambda {
          @memory.set(zero_page(@x), @a)
        },

        # STX (zero page, Y)
        0x96 => lambda {
          @memory.set(zero_page(@y), @x)
        },

        # TYA
        0x98 => lambda {
          @a = @y & 0xff
          set_nz_flags(@a)
        },

        # STA (absolute, Y)
        0x99 => lambda {
          @memory.set(absolute(@y), @a)
        },

        # TXS
        0x9a => lambda {
          @sp = @x & 0xff
        },

        # STA (absolute, X)
        0x9d => lambda {
          @memory.set(absolute(@x), @a)
        },

        # LDY (immediate)
        0xa0 => lambda {
          @y = next_byte
          set_nz_flags(@y)
        },

        # LDA (indexed indirect)
        0xa1 => lambda {
          @a = @memory.get(indexed_indirect)
          set_nz_flags(@a)
        },

        # LDX (immediate)
        0xa2 => lambda {
          @x = next_byte
          set_nz_flags(@x)
        },

        # LDY (zero page)
        0xa4 => lambda {
          @y = @memory.get(zero_page)
          set_nz_flags(@y)
        },

        # LDA (zero page)
        0xa5 => lambda {
          @a = @memory.get(zero_page)
          set_nz_flags(@a)
        },

        # LDX (zero page)
        0xa6 => lambda {
          @x = @memory.get(zero_page)
          set_nz_flags(@x)
        },

        # TAY
        0xa8 => lambda {
          @y = @a & 0xff
          set_nz_flags(@y)
        },

        # LDA (immediate)
        0xa9 => lambda {
          @a = next_byte
          set_nz_flags(@a)
        },

        # TAX
        0xaa => lambda {
          @x = @a & 0xff
          set_nz_flags(@x)
        },

        # LDY (absolute)
        0xac => lambda {
          @y = @memory.get(absolute)
          set_nz_flags(@y)
        },

        # LDA (absolute)
        0xad => lambda {
          @a = @memory.get(absolute)
          set_nz_flags(@a)
        },

        # LDX (absolute)
        0xae => lambda {
          @x = @memory.get(absolute)
          set_nz_flags(@x)
        },

        # BCS
        0xb0 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.carry?
        },

        # LDA (indirect indexed)
        0xb1 => lambda {
          @a = @memory.get(indirect_indexed)
          set_nz_flags(@a)
        },

        # LDY (zero page, X)
        0xb4 => lambda {
          @y = @memory.get(zero_page(@x))
          set_nz_flags(@y)
        },

        # LDA (zero page, X)
        0xb5 => lambda {
          @a = @memory.get(zero_page(@x))
          set_nz_flags(@a)
        },

        # LDX (zero page, Y)
        0xb6 => lambda {
          @x = @memory.get(zero_page(@y))
          set_nz_flags(@x)
        },

        # CLV
        0xb8 => lambda {
          @status.overflow = false
        },

        # LDA (absolute, Y)
        0xb9 => lambda {
          @a = @memory.get(absolute(@y))
          set_nz_flags(@a)
        },

        # TSX
        0xba => lambda {
          @x = @sp & 0xff
          set_nz_flags(@x)
        },

        # LDY (absolute, X)
        0xbc => lambda {
          @y = @memory.get(absolute(@x))
          set_nz_flags(@y)
        },

        # LDA (absolute, X)
        0xbd => lambda {
          @a = @memory.get(absolute(@x))
          set_nz_flags(@a)
        },

        # LDX (absolute, Y)
        0xbe => lambda {
          @x = @memory.get(absolute(@y))
          set_nz_flags(@x)
        },

        # CPY (immediate)
        0xc0 => lambda {
          compare(@y, next_byte)
        },

        # CMP (indexed indirect)
        0xc1 => lambda {
          compare(@a, @memory.get(indexed_indirect))
        },

        # CPY (zero page)
        0xc4 => lambda {
          compare(@y, @memory.get(zero_page))
        },

        # CMP (zero page)
        0xc5 => lambda {
          compare(@a, @memory.get(zero_page))
        },

        # DEC (zero page)
        0xc6 => lambda {
          address = zero_page
          @memory.set(address, dec(@memory.get(address)))
        },

        # INY
        0xc8 => lambda {
          @y = inc(@y) & 0xff
        },

        # CMP (immediate)
        0xc9 => lambda {
          compare(@a, next_byte)
        },

        # DEX
        0xca => lambda {
          @x = dec(@x) & 0xff
        },

        # CPY (absolute)
        0xcc => lambda {
          compare(@y, @memory.get(absolute))
        },

        # CMP (absolute)
        0xcd => lambda {
          compare(@a, @memory.get(absolute))
        },

        # DEC (absolute)
        0xce => lambda {
          address = absolute
          @memory.set(address, dec(@memory.get(address)))
        },

        # BNE
        0xd0 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.zero?
        },

        # CMP (indirect indexed)
        0xd1 => lambda {
          compare(@a, @memory.get(indirect_indexed))
        },

        # CMP (zero page, X)
        0xd5 => lambda {
          compare(@a, @memory.get(zero_page(@x)))
        },

        # DEC (zero page, X)
        0xd6 => lambda {
          address = zero_page(@x)
          @memory.set(address, dec(@memory.get(address)))
        },

        # CLD
        0xd8 => lambda {
          @status.decimal_mode = false
        },

        # CMP (absolute, Y)
        0xd9 => lambda {
          compare(@a, @memory.get(absolute(@y)))
        },

        # CMP (absolute, X)
        0xdd => lambda {
          compare(@a, @memory.get(absolute(@x)))
        },

        # DEC (absolute, X)
        0xde => lambda {
          address = absolute(@x)
          @memory.set(address, dec(@memory.get(address)))
        },

        # CPX (immediate)
        0xe0 => lambda {
          compare(@x, next_byte)
        },

        # SBC (indexed indirect)
        0xe1 => lambda {
          sbc(@memory.get(indexed_indirect))
        },

        # CPX (zero page)
        0xe4 => lambda {
          compare(@x, @memory.get(zero_page))
        },

        # SBC (zero page)
        0xe5 => lambda {
          sbc(@memory.get(zero_page))
        },

        # INC (zero page)
        0xe6 => lambda {
          address = zero_page
          @memory.set(address, inc(@memory.get(address)))
        },

        # INX
        0xe8 => lambda {
          @x = inc(@x) & 0xff
        },

        # SBC (immediate)
        0xe9 => lambda {
          sbc(next_byte)
        },

        # NOP
        0xea => lambda {}, # rubocop:disable Style/Lambda

        # CPX (absolute)
        0xec => lambda {
          compare(@x, @memory.get(absolute))
        },

        # SBC (absolute)
        0xed => lambda {
          sbc(@memory.get(absolute))
        },

        # INC (absolute)
        0xee => lambda {
          address = absolute
          @memory.set(address, inc(@memory.get(address)))
        },

        # BEQ
        0xf0 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.zero?
        },

        # SBC (zero page, X)
        0xf5 => lambda {
          sbc(@memory.get(zero_page(@x)))
        },

        # INC (zero page, X)
        0xf6 => lambda {
          address = zero_page(@x)
          @memory.set(address, inc(@memory.get(address)))
        },

        # SED
        0xf8 => lambda {
          @status.decimal_mode = true
        },

        # SBC (absolute, Y)
        0xf9 => lambda {
          sbc(@memory.get(absolute(@y)))
        },

        # SBC (absolute, X)
        0xfd => lambda {
          sbc(@memory.get(absolute(@x)))
        },

        # INC (absolute, X)
        0xfe => lambda {
          address = absolute(@x)
          @memory.set(address, inc(@memory.get(address)))
        }
      }
    end
  end
end
