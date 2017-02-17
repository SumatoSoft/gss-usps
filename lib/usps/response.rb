module Usps
  class Response
    HTTP_OK_STATUS = 200
    SOAP_OK_STATUS = 0

    ERROR_CODES = {
      authenticate_user: :response_code,

      load_and_record_labeled_package: :reject_package_count,
      get_package_labels: :response_code,
      add_package_in_receptacle: :response_code,
      calculate_postage: :response_code,

      create_receptacle_for_rate_type_to_destination: :response_code,
      get_receptacle_label: :response_code,
      move_receptacle_to_open_dispatch: :response_code


    }.freeze

    def initialize(response, web_method)
      @savon = response
      @http  = response.http
      @hash  = response.to_hash
      @code  = response.http.code
      @web_method = web_method
    end

    attr_accessor :savon, :http, :hash, :code

    def http_correct?
      @code == HTTP_OK_STATUS
    end

    def soap_correct?
      checked_field = ERROR_CODES[@web_method]
      find_value(checked_field).to_i == SOAP_OK_STATUS
    end

    def success?
      http_correct? && soap_correct?
    end

    def find_value(key)
      nested_hash_value(@hash, key)
    end

    private

    def nested_hash_value(obj, key)
      if obj.respond_to?(:key?) && obj.key?(key)
        obj[key]
      elsif obj.respond_to?(:each)
        r = nil
        obj.find { |*a| r = nested_hash_value(a.last, key) }
        r
      end
    end
  end
end
