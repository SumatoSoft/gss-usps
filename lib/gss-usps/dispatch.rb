module GssUsps
  class Dispatch
    attr_accessor :dispatch_id

    def initialize(dispatch_id = nil)
      @dispatch_id = dispatch_id
    end

    def close_dispatch
      token = GssUsps::Request.token
      response = GssUsps::Request.request(:close_dispatch,
                                       'AccessToken' => token)
      @dispatch_id = response.find_value(:dispatch_id) if response.success?
      response
    end

    def reopen_dispatch
      token = GssUsps::Request.token
      GssUsps::Request.request(:reopen_dispatch,
                               'DispatchID' => @dispatch_id,
                               'AccessToken' => token)
    end

    def get_required_reports_for_dispatch
      token = GssUsps::Request.token
      GssUsps::Request.request(:get_required_reports_for_dispatch,
                            'DispatchID' => @dispatch_id,
                            'AccessToken' => token)
    end

    def get_dispatch_report(params)
      token = GssUsps::Request.token
      GssUsps::Request.request(:get_dispatch_report,
                            'DispatchID' => @dispatch_id,
                            'LocationID' => GssUsps.configuration.location_id,
                            'ReportName' => params['report_name'],
                            'ReportFormat' => params['report_format'],
                            'AccessToken' => token)
    end
  end
end
