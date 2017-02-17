module GssUsps
  class Receptacle
    attr_accessor :receptacle_id
    def initialize(receptacle_id = nil)
      @receptacle_id = receptacle_id
    end

    def create_receptacle_for_rate_type_to_destination(params)
      token = GssUsps::Request.token
      response = GssUsps::Request.request(:create_receptacle_for_rate_type_to_destination,
                                       'RateType' => params['rate_type'],
                                       'Dutiable' => params['dutiable'],
                                       'ReceptacleType' => params['receptacle_type'],
                                       'ForeignOECode' => params['foreign_oe_code'],
                                       'CountryCode' => params['country_code'],
                                       'DateOfMailing' => DateTime.now.strftime('%Y-%m-%dT%I:%M:%S'),
                                       'PieceCount' => params['piece_count'],
                                       'WeightInLbs' => params['weight_in_lbs'],
                                       'AccessToken' => token)
      @receptacle_id = response.find_value(:receptacle_id) if response.success?
      response
    end

    def get_receptacle_label(params)
      token = GssUsps::Request.token
      GssUsps::Request.request(:get_receptacle_label,
                            'ReceptacleID' => @receptacle_id,
                            'FileFormat' => params['file_format'],
                            'AccessToken' => token)
    end

    def move_receptacle_to_open_dispatch
      token = GssUsps::Request.token
      GssUsps::Request.request(:move_receptacle_to_open_dispatch,
                            'ReceptacleID' => @receptacle_id,
                            'AccessToken' => token)
    end
  end
end
