require 'test_helper'
require 'fileutils'
require 'handset_detection'
require 'pp'

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
		#Rails::logger.debug
	end

	def teardown
		@vendors = nil
	end

	def test_deviceVendorsNokia()				
		_vendor = @vendor		
		assert(_vendor['vendor'].include?('Nokia'), "Device Vendor Nokia found.")
	end

	def test_deviceVendorsCyborg()		
		_vendor = @vendor
		assert(_vendor['vendor'].exclude?('Cyborg'), "Device Vendor Cyborg not found.")
	end

	def test_deviceModelsSagemMyMobileTV()
		_model = @model
		assert(_model['model'].include?('myMobileTV'), "Device Model Sagem myMobileTV found.")
	end

	def test_deviceModelsSagemMySatelliteTV()
		_model = @model
		assert(_model['model'].include?('mySatelliteTV'), "Device Model Sagem mySatelliteTV not found.")
	end

	def test_deviceViewNokiaN95()
		_deviceView = @deviceView
		assert_equal("Symbian", _deviceView["device"]["general_platform"])
		assert_equal("N95", _deviceView["device"]["general_model"])
		assert_equal("Nokia", _deviceView["device"]["general_vendor"])
	end

	def test_deviceViewNokia8080()
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

	    assert_nil(d)	    
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