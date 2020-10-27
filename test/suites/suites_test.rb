# frozen_string_literal: true

# Copyright (c) 2020, Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require 'test_helper'

module Mos6502::Suites
  extend self # rubocop:disable Style/ModuleFunction
  attr_accessor :test_suites

  ENV_NAMESPACE = :mos6502
  TEST_SUITE_DIR = 'suites'
  TEST_SUITE_RUNNER = 'run.rb'
  TEST_SUITES = [:klaus2m5, :nestest].freeze

  # Turn on individual test suites?
  def init_test_suites!
    @test_suites = {}

    TEST_SUITES.each do |suite, _|
      env = [ENV_NAMESPACE, suite].map(&:to_s).join('_').upcase
      @test_suites[suite] = ENV[env].nil? ? :off : ENV[env].intern
    end
  end

  init_test_suites!

  # A superclass for test suite runners to access configured options.
  class Runner < Minitest::Test
    def self.suite_name
      name.split('::').last.downcase
    end

    def output
      Mos6502::Suites.test_suites[self.class.suite_name.intern]
    end
  end
end

# Load test suites that we want to run.
Mos6502::Suites.test_suites.each do |suite, status|
  next if status == :off

  path = File.join(suite.to_s, Mos6502::Suites::TEST_SUITE_RUNNER)
  require_relative path
end
