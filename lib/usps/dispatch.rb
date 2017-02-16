module Usps
  class Dispatch
    attr_accessor :dispatch_id

    def initialize(dispatch_id = nil)
      @dispatch_id = dispatch_id
    end

    def close_dispatch(params)
      token = Usps::Request.token
      response = Usps::Request.request(:close_dispatch,
                                       'VehicleNum' => params['vehicle_num'],
                                       'VehicleType' => params['vehicle_type'],
                                       'DepDateTime' => params['dep_date_time'],
                                       'ArrDateTime' => params['arr_date_time'],
                                       'AccessToken' => token)
      @dispatch_id = response.find_value(:dispatch_id) if response.success?
      response
    end

    def get_required_reports_for_dispatch
      token = Usps::Request.token
      Usps::Request.request(:get_required_reports_for_dispatch,
                            'DispatchID' => @dispatch_id,
                            'AccessToken' => token)
    end

    def get_dispatch_report(params)
      token = Usps::Request.token
      Usps::Request.request(:get_dispatch_report,
                            'DispatchID' => @dispatch_id,
                            'LocationID' => Usps.configuration.location_id,
                            'ReportName' => params['report_name'],
                            'ReportFormat' => params['report_format'],
                            'AccessToken' => token)
    end
  end
end
