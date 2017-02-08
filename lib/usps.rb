require 'usps/version'
require 'usps/base'
require 'usps/config'
require 'usps/dispatch'
require 'usps/package'
require 'usps/receptacle'
require 'usps/request'
require 'usps/response'
require 'usps/error'
require 'usps/success'
require 'usps/error_codes'

module Usps
  def self.configuration
    @configuration ||= Config.new
  end

  def self.config
    config = configuration
    yield(config)
  end
end
