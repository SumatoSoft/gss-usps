module Usps
  module ErrorCodes
    ERROR_CODES = {
      authenticate_user: :response_code,
      load_and_record_labeled_package: :reject_package_count
    }
  end
end
