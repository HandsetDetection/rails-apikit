require 'test_helper'
require 'fileutils'
require 'handset_detection'
require 'pp'
=begin
run command: ruby -I test test/functional/handset_controller_test.rb	
=end
class HandsetControllerTest < ActionController::TestCase
	include ActionController::HandsetDetection
	include ActionController::HandsetDetection::InstanceMethods	

	def setup
		@vendors = hd_remote(Configuration.get('vendors') + ".json", "")
		@vendor = JSON.parse(deviceVendors())		
		@model = JSON.parse(deviceModels('Sagem'))
		@deviceView = JSON.parse(deviceView("Nokia","N95"))
		@devicewWhatHas = JSON.parse(deviceWhatHas('network', 'CDMA'))
		@fetchTrees = JSON.parse(siteFetchTrees())
		@fetchSpecs = JSON.parse(siteFetchSpecs)
		Rails::logger.debug
	end

	def teardown
		@vendors = nil
		@vendor = nil
		@model = nil
		@deviceView = nil
		@devicewWhatHas = nil
		@fetchTrees = nil
		@fetchSpecs = nil		
	end

	def test_userCredentials()
		assert_equal("your_api_username", Configuration.get('username'))
		assert_equal("your_api_password", Configuration.get('password'))
		assert_equal("your_api_siteId", Configuration.get('site_id'))
	end
	def test_deviceVendorsPass()
		_vendor = @vendor	
		_arrayVendors = ["Cutepad", "Sunstech", "ZeusPAD", "Motorola", "BenQ"]	
		_arrayVendors.each{ |v| assert(_vendor['vendor'].include?(v), "Device Vendor #{v} not found.") }		
	end

	def test_deviceVendorsFail()
		_vendor = @vendor	
		_arrayVendors = ["FlyingPad", "Arcade", "Cyborgii", "Symbianize", "BingQ", "DroidXV"]	
		_arrayVendors.each{ |v| assert(_vendor['vendor'].exclude?(v), "Device Vendor #{v} found.") }
	end

	def test_deviceVendorNokia()				
		_vendor = @vendor		
		assert(_vendor['vendor'].include?('Nokia'), "Device Vendor Nokia not found.")
	end

	def test_deviceVendorCyborg()		
		_vendor = @vendor
		assert(_vendor['vendor'].exclude?('Cyborg'), "Device Vendor Cyborg found.")
	end
	
	def test_deviceModelSagemPass()
		_model = @model		
		["Vodafone 527", "PUMA Phone M1", "DoCoMo myV-75", "myX-5-2T"].each { |m| assert(_model['model'].include?(m), "Device Model #{m} not found.") }				
	end

	def test_deviceModelSagemFail()
		_model = @model		
		["myCloudPhone", "PANDA Phone", "Volatile-X201", "TitanX1", "iPhone 5S"].each { |m| assert(_model['model'].exclude?(m), "Device Model #{m} found.") }		
	end

	def test_deviceModelSagemMyMobileTV()
		_model = @model
		assert(_model['model'].include?('myMobileTV'), "Device Model Sagem myMobileTV not found.")
	end

	def test_deviceModelSagemMySatelliteTV()
		_model = @model
		assert(_model['model'].include?('mySatelliteTV'), "Device Model Sagem mySatelliteTV not found.")
	end

	def test_deviceViewNokiaN95()
		_deviceView = @deviceView
		assert_equal("Symbian", _deviceView["device"]["general_platform"])
		assert_equal("N95", _deviceView["device"]["general_model"])
		assert_equal("Nokia", _deviceView["device"]["general_vendor"])
	end

	def test_deviceViewNokia8080Fail()
		_deviceView = JSON.parse(deviceView("Nokia","8080"))		
		assert_equal("301", _deviceView["status"].to_s)		
	end

	def test_deviceWhatHas()
		_devicewWhatHas = @devicewWhatHas
		assert_not_nil(_devicewWhatHas, "Device is not empty")		
		assert_equal("Samsung", _devicewWhatHas["devices"][0]["general_vendor"].to_s)		
		assert_equal("LG", _devicewWhatHas["devices"][1]["general_vendor"])		
	end

	def test_siteDetect()
		d = detect({
	      "Host"=>"localhost",
	      "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
	      "Accept-Language"=>"en-us,en;q=0.5",
	      "Accept-Encoding"=>"gzip, deflate",
	      "Connection"=>"keep-alive",
	      "Cache-Control"=>"max-age=0",
	      "user-agent" => "Dalvik/1.4.0 (Linux; U; Android 2.3.1; TM-7022 Build/GINGERBREAD)",
	      "x-wap-profile"=>"http://wap.sonyericsson.com/UAprof/LT15iR301.xml"
	   	},server_detect = 1)

		_data = JSON.parse(d.to_s)

		assert_not_nil(_data)
		assert_equal("SonyEricsson", _data["hd_specs"]["general_vendor"])
		assert_equal("LT15I", _data["hd_specs"]["general_model"])
		assert_equal("Android", _data["hd_specs"]["general_platform"])
		assert_equal("2.3.1", _data["hd_specs"]["general_platform_version"])
	end

	def test_localDetect()
		d = detect({
	      "Host"=>"localhost",
	      "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
	      "Accept-Language"=>"en-us,en;q=0.5",
	      "Accept-Encoding"=>"gzip, deflate",
	      "Connection"=>"keep-alive",
	      "Cache-Control"=>"max-age=0",
	      'user-agent' => 'Dalvik/1.4.0 (Linux; U; Android 2.3.1; TM-7022 Build/GINGERBREAD)',
	      "x-wap-profile"=>'http://wap.sonyericsson.com/UAprof/LT15iR301.xml'
	    },server_detect = 0)	   

	    _data = JSON.parse(d.to_s)
	    
	    assert_nil(_data)	    
	end

	def test_siteFetchTrees()
		_data = @fetchTrees		
		assert_not_nil(_data)		
	end

	def test_siteFetchSpecs()
		_data = @fetchSpecs		
		assert_not_nil(_data)		
	end

end