require 'gss-usps/version'
require 'gss-usps/config'
require 'gss-usps/dispatch'
require 'gss-usps/package'
require 'gss-usps/receptacle'
require 'gss-usps/request'
require 'gss-usps/response'

module GssUsps
  def self.configuration
    @configuration ||= Config.new
  end

  def self.config
    config = configuration
    yield(config)
  end
end
