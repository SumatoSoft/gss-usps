module GssUsps
  module Request
    def self.request(web_method, params, raw_xml = false)
      client = Savon.client(wsdl: GssUsps.configuration.wsdl,
                            follow_redirects: GssUsps.configuration.follow_redirects, log: true)

      response = if raw_xml
                   client.call(web_method, xml: params)
                 else
                   client.call(web_method, message: params.to_hash)
                 end

      GssUsps::Response.new(response, web_method)
    end

    def self.token
      authenticate_user
    end

    def self.authenticate_user
      response = request(:authenticate_user,
                         'UserID' => GssUsps.configuration.user_id,
                         'Password' => GssUsps.configuration.password,
                         'LocationID' => GssUsps.configuration.location_id,
                         'WorkstationID' => GssUsps.configuration.agent_id)

      response.find_value(:access_token)
    end
  end
end
