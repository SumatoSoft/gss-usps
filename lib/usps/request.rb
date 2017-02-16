module Usps
  module Request
    def self.request(web_method, params, raw_xml = false)
      client = Savon.client(wsdl: Usps.configuration.wsdl)

      response = if raw_xml
                   client.call(web_method, xml: params)
                 else
                   client.call(web_method, message: params.to_hash)
                 end

      Usps::Response.new(response, web_method)
    end

    def self.token
      authenticate_user
    end

    def self.authenticate_user
      response = request(:authenticate_user,
                         'UserID' => Usps.configuration.user_id,
                         'Password' => Usps.configuration.password,
                         'LocationID' => Usps.configuration.location_id,
                         'WorkstationID' => Usps.configuration.agent_id)

      response.find_value(:access_token)
    end
  end
end
