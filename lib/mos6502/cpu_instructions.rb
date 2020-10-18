# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

module Mos6502
  class Cpu
    private

    def branch(offset)
      if offset > 0x7f
        @pc - (0x100 - offset)
      else
        @pc + offset
      end
    end

    def compare(register, value)
      @status.carry = register >= value
      set_nz_flags(register - value)
    end

    def adc(value)
      carry = @status.carry? ? 1 : 0

      if @status.decimal_mode?
        result = (@a & 0x0f) + (value & 0x0f) + carry
        result = 0x10 | ((result + 0x06) & 0x0f) if result >= 0x0a
        result += (@a & 0xf0) + (value & 0xf0)

        if result >= 0xa0
          result += 0x60
          @status.carry = true
          @status.overflow = ((@a ^ value) & 0x80).zero? && (result >= 0x0180)
        else
          @status.carry = false
          @status.overflow = !((@a ^ value) & 0x80).zero? && (result < 0x80)
        end
      else
        result = @a + value + carry
        @status.overflow =
          (((@a & 0x7f) + (value & 0x7f) + carry) >> 7) ^ (result >> 8)
        @status.carry = result > 0xff
      end

      @a = result & 0xff
      set_nz_flags(@a)
    end

    def sbc(value)
      if @status.decimal_mode?
        carry = @status.carry? ? 1 : 0
        ones = 0x0f + (@a & 0x0f) - (value & 0x0f) + carry
        tens = 0xf0 + (@a & 0xf0) - (value & 0xf0)

        if ones < 0x10
          ones -= 6
        else
          tens += 0x10
          ones -= 0x10
        end

        if tens < 0x100
          tens -= 0x60
          @status.carry = false
          @status.overflow = !((@a ^ value) & 0x80).zero? && (tens < 0x80)
        else
          @status.carry = true
          @status.overflow = !((@a ^ value) & 0x80).zero? && (tens < 0x0180)
        end

        @a = (ones + tens) & 0xff
        set_nz_flags(@a)
      else
        adc(value ^ 0xff)
      end
    end

    def instructions
      {
        # BRK
        0x00 => lambda {
          stack_push((@pc >> 8) & 0xff)
          stack_push(@pc & 0xff)
          stack_push(@status.encode)
          @pc = @memory.get_word(0xfffe)
          @status.break = true
        },

        # PHP
        0x08 => lambda {
          stack_push(@status.encode)
        },

        # ASL (accumulator)
        0x0a => lambda {
          set_carry(@a, 7)
          @a = (@a << 1) & 0xff
          set_nz_flags(@a)
        },

        # BPL
        0x10 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.negative?
        },

        # CLC
        0x18 => lambda {
          @status.carry = false
        },

        # JSR
        0x20 => lambda {
          jump_to = next_word
          return_to = @pc - 1
          stack_push((return_to >> 8) & 0xff)
          stack_push(return_to & 0xff)
          @pc = jump_to
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
          carry = @status.carry? ? 1 : 0
          set_carry(@a, 7)
          @a = (@a << 1) & 0xff
          @a |= carry
          set_nz_flags(@a)
        },

        # BMI
        0x30 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.negative?
        },

        # SEC
        0x38 => lambda {
          @status.carry = true
        },

        # RTI
        0x40 => lambda {
          @status.decode(stack_pop)
          @pc = (stack_pop | (stack_pop << 8))
        },

        # PHA
        0x48 => lambda {
          stack_push(@a)
        },

        # LSR (accumulator)
        0x4a => lambda {
          set_carry(@a, 0)
          @a = @a >> 1
          set_nz_flags(@a)
        },

        # JMP (absolute)
        0x4c => lambda {
          @pc = absolute
        },

        # CLI
        0x58 => lambda {
          @status.interupt_disable = false
        },

        # RTS
        0x60 => lambda {
          @pc = (stack_pop | (stack_pop << 8)) + 1
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
          carry = @status.carry?
          set_carry(@a, 0)
          @a = @a >> 1
          @a |= 0x80 if carry
          set_nz_flags(@a)
        },

        # SEI
        0x78 => lambda {
          @status.interupt_disable = true
        },

        # STA (zero page)
        0x85 => lambda {
          @memory.set(zero_page, @a)
        },

        # DEY
        0x88 => lambda {
          @y = (@y - 1) & 0xff
          set_nz_flags(@y)
        },

        # TXA
        0x8a => lambda {
          @a = @x & 0xff
          set_nz_flags(@a)
        },

        # STA (absolute)
        0x8d => lambda {
          @memory.set(absolute, @a)
        },

        # BCC
        0x90 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.carry?
        },

        # STA (zero page, X)
        0x95 => lambda {
          @memory.set(zero_page(@x), @a)
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

        # LDX (immediate)
        0xa2 => lambda {
          @x = next_byte
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

        # LDA (absolute)
        0xad => lambda {
          @a = @memory.get(next_word)
          set_nz_flags(@a)
        },

        # BCS
        0xb0 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.carry?
        },

        # CLV
        0xb8 => lambda {
          @status.overflow = false
        },

        # TSX
        0xba => lambda {
          @x = @sp & 0xff
          set_nz_flags(@x)
        },

        # CPY (immediate)
        0xc0 => lambda {
          compare(@y, next_byte)
        },

        # INY
        0xc8 => lambda {
          @y = (@y + 1) & 0xff
          set_nz_flags(@y)
        },

        # CMP (immediate)
        0xc9 => lambda {
          compare(@a, next_byte)
        },

        # DEX
        0xca => lambda {
          @x = (@x - 1) & 0xff
          set_nz_flags(@x)
        },

        # BNE
        0xd0 => lambda {
          offset = next_byte
          @pc = branch(offset) unless @status.zero?
        },

        # CLD
        0xd8 => lambda {
          @status.decimal_mode = false
        },

        # CPX (immediate)
        0xe0 => lambda {
          compare(@x, next_byte)
        },

        # INX
        0xe8 => lambda {
          @x = (@x + 1) & 0xff
          set_nz_flags(@x)
        },

        # SBC (immediate)
        0xe9 => lambda {
          sbc(next_byte)
        },

        # NOP
        0xea => lambda {}, # rubocop:disable Style/Lambda

        # BEQ
        0xf0 => lambda {
          offset = next_byte
          @pc = branch(offset) if @status.zero?
        },

        # SED
        0xf8 => lambda {
          @status.decimal_mode = true
        }
      }
    end
  end
end
