module GssUsps
  class Config
    include ActiveSupport::Configurable

    config_accessor :wsdl, :user_id, :password, :location_id, :agent_id, :entry_facility_zip, :follow_redirects

    def initialize(options = {})
      options.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end
end
