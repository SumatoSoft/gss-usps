module GssUsps
  class Response
    HTTP_OK_STATUS = 200
    SOAP_OK_STATUS = 0

    ERROR_CODES = {
      load_and_record_labeled_package: :reject_package_count
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
      Integer(find_value(field_with_response_code)) == SOAP_OK_STATUS
    end

    def success?
      http_correct? && soap_correct?
    end

    def failure?
      !success?
    end

    def find_value(key)
      nested_hash_value(@hash, key)
    end

    private

    def field_with_response_code
      ERROR_CODES.fetch(@web_method, :response_code)
    end

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
