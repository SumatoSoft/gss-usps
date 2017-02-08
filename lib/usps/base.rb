module Usps
  class Base
    def error(value=nil)
      Usps::Error.new(value)
    end
    def success(value=nil)
      Usps::Success.new(value)
    end
  end
end
