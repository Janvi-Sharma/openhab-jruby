# frozen_string_literal: true

require 'openhab/core/load_path'
require 'openhab/core/entity_lookup'
require 'openhab/core/script_handling'
require 'openhab/core/openhab_setup'
require 'openhab/log/logger'
require 'openhab/dsl/dsl'
require 'openhab/version'

#
# Module used to extend base object with OpenHAB Library functionality
#
module OpenHAB
  include OpenHAB::Log
  #
  # Extends calling object with DSL and helper methods
  #
  # @param [Object] base Object to decorate with DSL and helper methods
  #
  #
  # rubocop:disable  Metrics/MethodLength
  # Number of extensions and includes requires more lines
  def self.extended(base)
    OpenHAB::Core.wait_till_openhab_ready
    base.extend Log
    base.extend OpenHAB::Core::ScriptHandling
    base.extend OpenHAB::Core::EntityLookup
    base.extend OpenHAB::DSL
    base.extend OpenHAB::DSL::TimeOfDay

    base.send :include, OpenHAB::DSL::TimeOfDay
    base.send :include, OpenHAB::DSL::Items
    base.send :include, OpenHAB::DSL::Types
    logger.info "OpenHAB JRuby Scripting Library Version #{OpenHAB::VERSION} Loaded"

    OpenHAB::Core.add_rubylib_to_load_path
  end
  # rubocop:enable  Metrics/MethodLength
end

# Extend caller with OpenHAB methods

# rubocop: disable Style/MixinUsage
extend OpenHAB
# rubocop: enable Style/MixinUsage
