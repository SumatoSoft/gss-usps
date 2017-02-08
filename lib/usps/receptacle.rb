module Usps
  class Receptacle
    def create_receptacle_for_rate_type_to_destination(package)
      token = Usps::Request.get_token
      response = Usps::Request.request(:create_receptacle_for_rate_type_to_destination,
      {
        "RateType" => "EPMI",
        "Dutiable" => "true",
        "ReceptacleType" => "I",
        "ForeignOECode" => "",
        "CountryCode" => "RU",
        "DateOfMailing" => DateTime.now.strftime('%Y-%m-%dT%I:%M:%S'),
        "PieceCount" => "1",
        "WeightInLbs" => (package.weight * OUNCE_TO_LB).to_s,
        "AccessToken" => token
      })
      binding.pry
      if response.success?
        response
      else
        response.get_error_hash
      end
    end

    def get_receptacle_label(receptacle_id)
      token = Usps::Request.get_token
      response = Usps::Request.request(:get_receptacle_label,
      {
        "ReceptacleID" => receptacle_id,
        "FileFormat" => "PNG",
        "AccessToken" => token
      })
      binding.pry
      if response.success?
        base64_data = nested_hash_value(response.body, :base64_binary)
        File.open("receptacle_label.png", 'wb') do|f|
          f.write(Base64.decode64(base64_data))
        end
      else
        response.get_error_hash
      end
    end

    def move_receptacle_to_open_dispatch(receptacle_id)
      token = Usps::Request.get_token
      response = Usps::Request.request(:move_receptacle_to_open_dispatch,
      {
        "ReceptacleID" => receptacle_id,
        "AccessToken" => token
      })
      binding.pry
      if response.success?
        response
      else
        response.get_error_hash
      end
    end

  end
end
