module Usps
  class Package < Base
    attr_accessor :package_id
    def initialize(params)
      @package = params[:package]
      @user = params[:user]
      @sender = params[:sender]
      @address = params[:address]
      @add_information = params[:add_information]
      @declarations = params[:declarations]
    end

    def load_and_record_labeled_package
      xml_request = form_xml_for_labeled_package
      response = Usps::Request.request(:load_and_record_labeled_package, xml_request, true)
      @package_id = response.find_value(:package_id) if response.success?
      response
    end

    def get_package_labels
      token = Usps::Request.get_token
      response = Usps::Request.request(:get_package_labels,
      {
        "PackageID" => @package_id,
        "MailingAgentID" => Usps.configuration.agent_id,
        "BoxNumber" => @add_information['box_number'],
        "FileFormat" => @add_information['image_file_format'],
        "AccessToken" => token
      })
    end

    def add_package_in_receptacle(receptacle_id)
      token = Usps::Request.get_token
      response = Usps::Request.request(:add_package_in_receptacle,
      {
        "USPSPackageTrackingID" => @package_id,
        "ReceptacleID" => receptacle_id,
        "AccessToken" => token
      })
    end

  private
    def form_xml_for_labeled_package
      manifest_attr = {'xmlns' => "mailerdataformatf07.xsd",
                    'xmlns:xsi' => "http://www.w3.org/2001/XMLSchemainstance",
                    'xsi:schemaLocation' => "mailerdataformatf07.xsd https://gss.usps.com/usps-cpas/mailerdataformatf07.xsd"}

      envelope_attr = {'xmlns:soapenv' => "http://schemas.xmlsoap.org/soap/envelope/",
                    'xmlns:gss' => "http://www.usps-cpas.com/usps-cpas/GSSAPI/"}

      hash_doc = form_hash_for_labeled_package
      token = Usps::Request.get_token

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send("soapenv:Envelope", envelope_attr) do
          xml.send("soapenv:Body") do
            xml.send("gss:LoadAndRecordLabeledPackage") do
              xml.send("gss:xmlDoc") do
                xml.send("Manifest", manifest_attr) do
                  hash_to_xml(hash_doc, xml)
                end
              end
              xml.send("gss:AccessToken", token)
            end
          end
        end
      end

      set_attribute(builder.doc.root, "Package", "PackageID", @package['id'])

      builder.to_xml
    end

    def form_hash_for_labeled_package
      dispatch_hash = get_request_header
      package_hash = get_package_data

      hash = dispatch_hash.merge(package_hash)
      declarations_array = @declarations.map{|d| get_declaration_data(d)}
      hash["Package"].merge!({ "Item" => declarations_array })
      hash
    end

    def get_request_header
      {
        "Dispatch" => {
          "ShippingAgentID" => Usps.configuration.agent_id,
          "ReceivingAgentID" => @add_information["receiving_agent_id"],
          "DataFileCreationDateandTime" => DateTime.now.strftime('%Y-%m-%dT%I:%M:%S'),
          "TimeZone" => @add_information["time_zone"],
          "FileFormatVersion" => @add_information["file_format_version"]
        }
      }
    end

    def get_package_data
      hash = {
        "Package" => {
          "OrderID" => @package['id'],
          "ItemValueCurrencyType" => @add_information["item_value_currency_type"],

          "SenderName" => @sender['name'],
          "SenderFirstName" => @sender['first_name'],
          "SenderMiddleInitial" => @sender['middle_initial'],
          "SenderLastName" => @sender['last_name'],
          "SenderBusinessName" => @sender['business_name'],
          "SenderAddress_Line_1" => @sender['address_line_1'],
          "SenderCity" => @sender['city'],
          "SenderProvince" => @sender['province'],
          "SenderPostal_Code" => @sender['postal_code'],
          "SenderCountry_Code" => @sender['country_code'],
          "SenderPhone" => @sender['phone'],
          "SenderEmail" => @sender['email'],
          "SenderSignature" => @sender['signature'],

          "RecipientFirstName" => @user['first_name'],
          "RecipientLastName" => @user['last_name'],
          "RecipientAddress_Line_1" => @address['address1'],
          "RecipientCity" => @address['city'],
          "RecipientProvince" =>  @address['province'],
          "RecipientPostal_Code" => @address['zip'],
          "RecipientCountry_Code" => @address['country'],
          "RecipientPhone" => @address['phone'],
          "RecipientEmail" => @user['email'],

          "PackageType" => @add_information["package_type"],
          "ShippingandHandling" => "",
          "ShippingCurrencyType" => @add_information["item_value_currency_type"],

          "PackageID" => @package['id'],
          "PackageWeight" => @package['weight'],
          "WeightUnit" => @add_information['weight_unit'],
          "UnitOfMeasurement" =>  @add_information['unit_of_measurement'],

          "ServiceType" => @add_information['service_type'],
          "RateType" => @add_information['rate_type'],
          "PackagePhysicalCount" => @add_information['package_physical_count'],
          "MailingAgentID" => Usps.configuration.agent_id,
          "ValueLoaded" => @add_information['value_loaded'],
          "PFCorEEL" => @add_information['pf_cor_eel']
        }
      }
      hash["Package"]["RecipientAddress_Line_2"] = @address['address2'] unless @address['address2'].blank?
      hash["Package"]["RecipientAddress_Line_3"] = @address['address2'] unless @address['address3'].blank?
      unless @package['insurance_value'].blank? || @package['insurance_value'].to_f == 0.0
        hash["Package"]["ShippingandHandling"] = @package['insurance_value'].to_f
      end
      hash
    end

    def get_declaration_data(declaration)
      {
        "ItemID" => declaration['id'],
        "ItemDescription" => declaration['item'],
        "UnitValue" => declaration['value'].to_s,
        "Quantity" => declaration['quantity'],
        "ItemWeight" => declaration['weight'],
        "UnitofItemWeight" => @add_information['weight_unit']
      }
    end

    def hash_to_xml(hash, xml)
      hash.each do |key, value|
        if (value.is_a? String) || (value.is_a? Numeric)
          xml.send(key, value)
        elsif value.is_a? Hash
          xml.send(key.to_s) { hash_to_xml(value, xml) }
        elsif value.is_a? Array
          value.each do |v|
            xml.send(key.to_s) {hash_to_xml(v, xml)}
          end
        end
      end
      xml
    end

    def set_attribute(node, node_name, attr_name, attr_value)
      if node.name != node_name
        node.children.each do |n|
          set_attribute(n, node_name, attr_name, attr_value)
        end
      else
        node[attr_name] = attr_value
      end
    end

  end
end
