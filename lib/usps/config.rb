module Usps
  class Config
    include ActiveSupport::Configurable

    config_accessor :wsdl, :user_id, :password, :location_id, :agent_id

    def initialize(options = {})
      options.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end
end
