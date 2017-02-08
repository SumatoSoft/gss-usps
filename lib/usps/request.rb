module Usps
  module Request
    def self.request(web_method, params, raw_xml=false)
      client = Savon.client(wsdl: Usps.configuration.wsdl)

      response = if raw_xml
         client.call(web_method, xml: params)
      else
         client.call(web_method, message: params.to_hash)
      end

      response_obj = Usps::Response.new(response, web_method)
      binding.pry
      if response_obj.http_correct? && response_obj.soap_correct?
        Usps::Success.new(response, web_method)
      else
        Usps::Error.new(response, web_method)
      end
    end

    def self.get_token
      self.authenticate_user
    end

    def self.authenticate_user
      response = self.request(:authenticate_user,
        {
          "UserID" => Usps.configuration.user_id,
          "Password" => Usps.configuration.password,
          "LocationID" => Usps.configuration.location_id,
          "WorkstationID" => Usps.configuration.agent_id
        })

      response.find_value(:access_token)
    end
  end
end
