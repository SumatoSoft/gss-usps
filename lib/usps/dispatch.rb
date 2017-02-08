module Usps
  class Dispatch
    attr_accessor :id, :dep_date, :arr_date

    def initialize(dep_date, arr_date, id=nil)
      @dep_date = dep_date
      @arr_date = arr_date
      @id = id
    end

    def close_dispatch
      token = Usps::Request.get_token
      response = Usps::Request.request(:close_dispatch,
      {
        "VehicleNum" => "513151",
        "VehicleType" => "A",
        "DepDateTime" => DateTime.now.strftime('%Y-%m-%dT%I:%M:%S'),
        "ArrDateTime" => (DateTime.now + 1).strftime('%Y-%m-%dT%I:%M:%S'),
        "AccessToken" => token
      })
      binding.pry
      if response.success?
        response
      else
        response.get_error_hash
      end
    end

    def get_required_reports_for_dispatch(dispatch_id)
      token = Usps::Request.get_token
      response = Usps::Request.request(:get_required_reports_for_dispatch,
      {
        "DispatchID" => dispatch_id,
        "AccessToken" => token
      })
      binding.pry
      if response.success?
        response
      else
        response.get_error_hash
      end
    end

    def get_dispatch_report(report_name, dispatch_id)
      token = Usps::Request.get_token
      response = Usps::Request.request(:get_dispatch_report,
      {
        "DispatchID" => dispatch_id,
        "LocationID" => LocationID,
        "ReportName" => report_name,
        "ReportFormat" => "PDF",
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
