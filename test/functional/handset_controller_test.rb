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
	
	# initialize first setup objects
	def setup		
		@notFoundHeaders = ['Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; GTB7.1; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; InfoPath.2; .NET CLR 3.5.30729; .NET4.0C; .NET CLR 3.0.30729; AskTbFWV5/5.12.2.16749; 978803803','Mozilla/5.0 (Windows; U; Windows NT 5.1; fr; rv:1.9.2.22) Gecko/20110902 Firefox/3.6.22 ( .NET CLR 3.5.30729) Swapper 1.0.4','Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; Sky Broadband; GTB7.1; SeekmoToolbar 4.8.4; Sky Broadband; Sky Broadband; AskTbBLPV5/5.9.1.14019)']

		@h1 = Hash.new
		@h1['user-agent'] = 'Mozilla/5.0 (Linux; U; Android 2.2.2; en-us; SCH-M828C[3373773858] Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
		@h1['x-wap-profile'] = 'http://www-ccpp.tcl-ta.com/files/ALCATEL_one_touch_908.xml'
		@h1['match'] = 'AlcatelOT-908222'

		@h2 = Hash.new
		@h2['user-agent'] = 'Mozilla/5.0 (Linux; U; Android 2.2.2; en-us; SCH-M828C[3373773858] Build/FROYO) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
		@h2['match'] = 'SamsungSCH-M828C'

		@h3 = Hash.new
		@h3['x-wap-profile'] = 'http://www-ccpp.tcl-ta.com/files/ALCATEL_one_touch_908.xml'
		@h3['match'] = 'AlcatelOT-90822'

		@h4 = Hash.new
		@h4['user-agent'] = 'Mozilla/5.0 (Linux; U; Android 2.3.3; es-es; GT-P1000N Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1'
		@h4['x-wap-profile'] = 'http://wap.samsungmobile.com/uaprof/GT-P1000.xml'
		@h4['match'] = 'SamsungGT-P1000'

		@h5 = Hash.new
		@h5['user-agent'] = 'Opera/9.80 (J2ME/MIDP; Opera Mini/5.21076/26.984; U; en) Presto/2.8.119 Version/10.54'
		@h5['match'] = 'GenericOperaMini'

		@h6 = Hash.new
		@h6['user-agent'] = 'Opera/9.80 (iPhone; Opera Mini/6.1.15738/26.984; U; tr) Presto/2.8.119 Version/10.54'
		@h6['match'] = 'AppleiPhone'

		@h7 = Hash.new
		@h7['user-agent'] = 'Mozilla/5.0 (Linux; U; Android 2.1-update1; cs-cz; SonyEricssonX10i Build/2.1.B.0.1) AppleWebKit/530.17 (KHTML, like Gecko) Version/4.0 Mobile Safari/530.17'
		@h7['match'] = 'SonyEricssonX10I'

		@nokiaN95 = '{"general_vendor":"Nokia","general_model":"N95","general_platform":"Symbian","general_platform_version":"9.2","general_browser":"","general_browser_version":"","general_image":"nokian95-1403496370-0.gif","general_aliases":[],"general_eusar":"0.50","general_battery":["Li-Ion 950 mAh","BL-5F"],"general_type":"Mobile","general_cpu":["Dual ARM 11","332Mhz"],"design_formfactor":"Dual Slide","design_dimensions":"99 x 53 x 21","design_weight":"120","design_antenna":"Internal","design_keyboard":"Numeric","design_softkeys":"2","design_sidekeys":["Volume","Camera"],"display_type":"TFT","display_color":"Yes","display_colors":"16M","display_size":"2.6\"","display_x":"240","display_y":"320","display_other":[],"memory_internal":["160MB","64MB RAM","256MB ROM"],"memory_slot":["microSD","8GB","128MB"],"network":["GSM850","GSM900","GSM1800","GSM1900","UMTS2100","HSDPA2100","Infrared port","Bluetooth 2.0","802.11b","802.11g","GPRS Class 10","EDGE Class 32"],"media_camera":["5MP","2592x1944"],"media_secondcamera":["QVGA"],"media_videocapture":["VGA@30fps"],"media_videoplayback":["MPEG4","H.263","H.264","3GPP","RealVideo 8","RealVideo 9","RealVideo 10"],"media_audio":["MP3","AAC","AAC+","eAAC+","WMA"],"media_other":["Auto focus","Video stabilizer","Video calling","Carl Zeiss optics","LED Flash"],"features":["Unlimited entries","Multiple numbers per contact","Picture ID","Ring ID","Calendar","Alarm","To-Do","Document viewer","Calculator","Notes","UPnP","Computer sync","VoIP","Music ringtones (MP3)","Vibration","Phone profiles","Speakerphone","Accelerometer","Voice dialing","Voice commands","Voice recording","Push-to-Talk","SMS","MMS","Email","Instant Messaging","Stereo FM radio","Visual radio","Dual slide design","Organizer","Word viewer","Excel viewer","PowerPoint viewer","PDF viewer","Predictive text input","Push to talk","Voice memo","Games"],"connectors":["USB","miniUSB","3.5mm Headphone","TV Out"]}'
		@AlcatelOT_908222 = '{"general_vendor":"Alcatel","general_model":"OT-908","general_platform":"Android","general_platform_version":"2.2","general_browser":"","general_browser_version":"","general_image":"","general_aliases":["Alcatel One Touch 908"],"general_eusar":"","general_battery":["Li-Ion 1300 mAh"],"general_type":"Mobile","general_cpu":["600Mhz"],"design_formfactor":"Bar","design_dimensions":"110 x 57.4 x 12.4","design_weight":"120","design_antenna":"Internal","design_keyboard":"Screen","design_softkeys":"","design_sidekeys":["Lock/Unlock","Volume"],"display_type":"TFT","display_color":"Yes","display_colors":"262K","display_size":"2.8\"","display_x":"240","display_y":"320","display_other":["Capacitive","Touch","Multitouch"],"memory_internal":["150MB"],"memory_slot":["microSD","microSDHC","32GB","2GB"],"network":["GSM850","GSM900","GSM1800","GSM1900","UMTS900","UMTS2100","HSDPA900","HSDPA2100","Bluetooth 3.0","802.11b","802.11g","802.11n","GPRS Class 12","EDGE Class 12"],"media_camera":["2MP","1600x1200"],"media_secondcamera":[],"media_videocapture":["Yes"],"media_videoplayback":["MPEG4","H.263","H.264"],"media_audio":["MP3","AAC","AAC+","WMA"],"media_other":["Geo-tagging"],"features":["Unlimited entries","Caller groups","Multiple numbers per contact","Search by both first and last name","Picture ID","Ring ID","Calendar","Alarm","Calculator","Computer sync","OTA sync","Music ringtones (MP3)","Polyphonic ringtones (64 voices)","Vibration","Flight mode","Silent mode","Speakerphone","Accelerometer","Compass","Voice recording","SMS","MMS","Email","Push Email","IM","Stereo FM radio with RDS","SNS integration","Google Search","Maps","Gmail","YouTube","Google Talk","Picasa integration","Organizer","Document viewer","Voice memo","Voice dialing","Predictive text input","Games"],"connectors":["USB 2.0","microUSB","3.5mm Headphone"],"general_language":""}'
		@SamsungSCH_M828C = '{"general_vendor":"Samsung","general_model":"SCH-M828C","general_platform":"Android","general_platform_version":"2.2","general_browser":"","general_browser_version":"","general_image":"samsungsch-m828c-1355919519-0.jpg","general_aliases":["Samsung Galaxy Prevail","Samsung Galaxy Precedent"],"general_eusar":"","general_battery":["Li-Ion 1500 mAh"],"general_type":"Mobile","general_cpu":["800Mhz"],"design_formfactor":"Bar","design_dimensions":"113 x 57 x 12","design_weight":"108","design_antenna":"Internal","design_keyboard":"Screen","design_softkeys":"","design_sidekeys":[],"display_type":"TFT","display_color":"Yes","display_colors":"262K","display_size":"3.2\"","display_x":"320","display_y":"480","display_other":["Capacitive","Touch","Multitouch","Touch Buttons"],"memory_internal":["117MB"],"memory_slot":["microSD","microSDHC","32GB","2GB"],"network":["CDMA800","CDMA1900","Bluetooth 3.0"],"media_camera":["2MP","1600x1200"],"media_secondcamera":[],"media_videocapture":["QVGA"],"media_videoplayback":["MP3","WAV","eAAC+"],"media_audio":["MP4","H.264","H.263"],"media_other":["Geo-tagging"],"features":["Unlimited entries","Caller groups","Multiple numbers per contact","Search by both first and last name","Picture ID","Ring ID","Calendar","Alarm","Document viewer","Calculator","Computer sync","OTA sync","Music ringtones (MP3)","Polyphonic ringtones","Vibration","Flight mode","Silent mode","Speakerphone","Accelerometer","Voice dialing","Voice recording","SMS","Threaded viewer","MMS","Email","Push Email","IM","Organizer","Google Search","Maps","Gmail","YouTube","Google Talk","Picasa integration","Voice memo","Predictive text input (Swype)","Games"],"connectors":["USB","microUSB","3.5mm Headphone"],"general_language":""}'
		@AlcatelOT_90822 = '{"general_vendor":"Alcatel","general_model":"OT-908","general_platform":"Android","general_platform_version":"2.2","general_browser":"","general_browser_version":"","general_image":"","general_aliases":["Alcatel One Touch 908"],"general_eusar":"","general_battery":["Li-Ion 1300 mAh"],"general_type":"Mobile","general_cpu":["600Mhz"],"design_formfactor":"Bar","design_dimensions":"110 x 57.4 x 12.4","design_weight":"120","design_antenna":"Internal","design_keyboard":"Screen","design_softkeys":"","design_sidekeys":["Lock/Unlock","Volume"],"display_type":"TFT","display_color":"Yes","display_colors":"262K","display_size":"2.8\"","display_x":"240","display_y":"320","display_other":["Capacitive","Touch","Multitouch"],"memory_internal":["150MB"],"memory_slot":["microSD","microSDHC","32GB","2GB"],"network":["GSM850","GSM900","GSM1800","GSM1900","UMTS900","UMTS2100","HSDPA900","HSDPA2100","Bluetooth 3.0","802.11b","802.11g","802.11n","GPRS Class 12","EDGE Class 12"],"media_camera":["2MP","1600x1200"],"media_secondcamera":[],"media_videocapture":["Yes"],"media_videoplayback":["MPEG4","H.263","H.264"],"media_audio":["MP3","AAC","AAC+","WMA"],"media_other":["Geo-tagging"],"features":["Unlimited entries","Caller groups","Multiple numbers per contact","Search by both first and last name","Picture ID","Ring ID","Calendar","Alarm","Calculator","Computer sync","OTA sync","Music ringtones (MP3)","Polyphonic ringtones (64 voices)","Vibration","Flight mode","Silent mode","Speakerphone","Accelerometer","Compass","Voice recording","SMS","MMS","Email","Push Email","IM","Stereo FM radio with RDS","SNS integration","Google Search","Maps","Gmail","YouTube","Google Talk","Picasa integration","Organizer","Document viewer","Voice memo","Voice dialing","Predictive text input","Games"],"connectors":["USB 2.0","microUSB","3.5mm Headphone"],"general_language":""}'		
		@SamsungGT_P1000 = '{"general_vendor":"Samsung","general_model":"GT-P1000","general_platform":"Android","general_platform_version":"2.2","general_browser":"","general_browser_version":"","general_image":"samsunggt-p1000-1368755043-0.jpg","general_aliases":["Samsung Galaxy Tab"],"general_eusar":"1.07","general_battery":["Li-Ion 4000 mAh"],"general_type":"Tablet","general_cpu":["1000Mhz"],"design_formfactor":"Bar","design_dimensions":"190.1 x 120.45 x 11.98","design_weight":"380","design_antenna":"Internal","design_keyboard":"Screen","design_softkeys":"","design_sidekeys":[],"display_type":"TFT","display_color":"Yes","display_colors":"16M","display_size":"7\"","display_x":"1024","display_y":"600","display_other":["Capacitive","Touch","Multitouch","Touch Buttons","Gorilla Glass","TouchWiz"],"memory_internal":["16GB","32GB","512MB RAM"],"memory_slot":["microSD","microSDHC","32GB"],"network":["GSM850","GSM900","GSM1800","GSM1900","UMTS900","UMTS1900","UMTS2100","HSDPA900","HSDPA1900","HSDPA2100","Bluetooth 3.0","802.11b","802.11g","802.11n","GPRS","EDGE"],"media_camera":["3.15MP","2048x1536"],"media_secondcamera":["1.3MP"],"media_videocapture":["720x480@30fps"],"media_videoplayback":["MPEG4","H.264","DivX","XviD"],"media_audio":["MP3","AAC","FLAC","WMA","WAV","AMR","OGG","MIDI"],"media_other":["Auto focus","Video calling","Geo-tagging","LED Flash"],"features":["Unlimited entries","Caller groups","Multiple numbers per contact","Search by both first and last name","Picture ID","Ring ID","Calendar","Alarm","Document viewer","Calculator","DLNA","Computer sync","OTA sync","Music ringtones (MP3)","Flight mode","Silent mode","Speakerphone","Accelerometer","Voice commands","Voice recording","SMS","Threaded viewer","MMS","Email","Push Mail","IM","RSS","Social networking integration","Full HD video playback","Up to 7h movie playback","Organizer","Image/video editor","Thinkfree Office","Word viewer","Excel viewer","PowerPoint viewer","PDF viewer","Google Search","Maps","Gmail","YouTube","Google Talk","Picasa integration","Readers/Media/Music Hub","Voice memo","Voice dialing","Predictive text input (Swype)","Games"],"connectors":["USB","3.5mm Headphone","TV Out","MHL"],"general_language":""}'		
		@GenericOperaMini = '{"general_vendor":"Generic","general_model":"Opera Mini 5","general_platform":"","general_platform_version":"","general_browser":"","general_browser_version":"","general_image":"","general_aliases":[],"general_eusar":"","general_battery":[],"general_type":"Mobile","general_cpu":[],"design_formfactor":"","design_dimensions":"","design_weight":"","design_antenna":"","design_keyboard":"","design_softkeys":"","design_sidekeys":[],"display_type":"","display_color":"","display_colors":"","display_size":"","display_x":"176","display_y":"160","display_other":[],"memory_internal":[],"memory_slot":[],"network":[],"media_camera":[],"media_secondcamera":[],"media_videocapture":[],"media_videoplayback":[],"media_audio":[],"media_other":[],"features":[],"connectors":[]}'
		@AppleiPhone = '{"general_vendor":"Apple","general_model":"iPhone","general_platform":"iOS","general_image":"apple^iphone.jpg","general_aliases":[],"general_eusar":"0.97","general_battery":["Li-Ion 1400 mAh"],"general_type":"Mobile","general_cpu":["ARM 11","412Mhz"],"design_formfactor":"Bar","design_dimensions":"115 x 61 x 11.6","design_weight":"135","design_antenna":"Internal","design_keyboard":"Screen","design_softkeys":"","design_sidekeys":["Volume"],"display_type":"TFT","display_color":"Yes","display_colors":"16M","display_size":"3.5\"","display_x":"320","display_y":"480","display_other":["Capacitive","Touch","Multitouch","Gorilla Glass"],"memory_internal":["4GB","8GB","16GB RAM"],"memory_slot":[],"network":["GSM850","GSM900","GSM1800","GSM1900","Bluetooth 2.0","802.11b","802.11g","GPRS","EDGE"],"media_camera":["2MP","1600x1200"],"media_secondcamera":[],"media_videocapture":[],"media_videoplayback":["MPEG4","H.264"],"media_audio":["MP3","AAC","WAV"],"media_other":[],"features":["Unlimited entries","Multiple numbers per contact","Picture ID","Ring ID","Calendar","Alarm","Document viewer","Calculator","Timer","Stopwatch","Computer sync","OTA sync","Polyphonic ringtones","Vibration","Phone profiles","Flight mode","Silent mode","Speakerphone","Accelerometer","Voice recording","Light sensor","Proximity sensor","SMS","Threaded viewer","Email","Google Maps","Audio/video player","Games"],"connectors":["USB","3.5mm Headphone","TV Out"],"general_platform_version":"1.x","general_browser":"","general_browser_version":"","general_language":""}'
		@SonyEricssonX10I = '{"general_vendor":"SonyEricsson","general_model":"X10I","general_platform":"Android","general_platform_version":"1.6","general_browser":"","general_browser_version":"","general_image":"","general_aliases":["SonyEricsson Xperia X10","SonyEricsson X10"],"general_eusar":"","general_battery":["Li-Po 1500 mAh","BST-41"],"general_type":"Mobile","general_cpu":["1000Mhz"],"design_formfactor":"Bar","design_dimensions":"119 x 63 x 13","design_weight":"135","design_antenna":"Internal","design_keyboard":"Screen","design_softkeys":"","design_sidekeys":["Volume","Camera"],"display_type":"TFT","display_color":"Yes","display_colors":"65K","display_size":"4\"","display_x":"480","display_y":"854","display_other":["Capacitive","Touch","Multitouch"],"memory_internal":["1GB","384MB RAM"],"memory_slot":["microSD","microSDHC","32GB","8GB"],"network":["GSM850","GSM900","GSM1800","GSM1900","UMTS900","UMTS1700","UMTS2100","HSDPA900","HSDPA1700","HSDPA2100","Bluetooth 2.1","802.11b","802.11g","GPRS Class 10","EDGE Class 10"],"media_camera":["8MP","3264x2448"],"media_secondcamera":[],"media_videocapture":["WVGA@30fps"],"media_videoplayback":["MPEG4"],"media_audio":["MP3","AAC","AAC+","WMA","WAV"],"media_other":["Auto focus","Image stabilizer","Video stabilizer","Face detection","Smile detection","Digital zoom","Geo-tagging","Touch focus","LED Flash"],"features":["Unlimited entries","Caller groups","Multiple numbers per contact","Search by both first and last name","Picture ID","Ring ID","Calendar","Alarm","Document viewer","Calculator","World clock","Stopwatch","Notes","Computer sync","OTA sync","Music ringtones (MP3)","Polyphonic ringtones","Vibration","Flight mode","Silent mode","Speakerphone","Voice recording","Accelerometer","Compass","Timescape/Mediascape UI","SMS","Threaded viewer","MMS","Email","Push email","IM","Google Search","Maps","Gmail","YouTube","Google Talk","Facebook and Twitter integration","Voice memo","Games"],"connectors":["USB 2.0","microUSB","3.5mm Headphone"],"general_language":""}'
		@Device_10 = '{"Device":{"_id":"10","hd_specs":{"general_vendor":"Samsung","general_model":"SPH-A680","general_platform":"","general_platform_version":"","general_browser":"","general_browser_version":"","general_image":"samsungsph-a680-1403617960-0.jpg","general_aliases":["Samsung VM-A680"],"general_eusar":"","general_battery":["Li-Ion 900 mAh"],"general_type":"Mobile","general_cpu":[],"design_formfactor":"Clamshell","design_dimensions":"83 x 46 x 24","design_weight":"96","design_antenna":"Internal","design_keyboard":"Numeric","design_softkeys":"2","design_sidekeys":[],"display_type":"TFT","display_color":"Yes","display_colors":"65K","display_size":"","display_x":"128","display_y":"160","display_other":["Second External TFT"],"memory_internal":[],"memory_slot":[],"network":["CDMA800","CDMA1900","AMPS800"],"media_camera":["VGA","640x480"],"media_secondcamera":[],"media_videocapture":["Yes"],"media_videoplayback":[],"media_audio":[],"media_other":["Exposure control","White balance","Multi shot","Self-timer","LED Flash"],"features":["300 entries","Multiple numbers per contact","Picture ID","Ring ID","Calendar","Alarm","To-Do","Calculator","Stopwatch","SMS","T9","Computer sync","Polyphonic ringtones (32 voices)","Vibration","Voice dialing (Speaker independent)","Voice recording","TTY\/TDD","Games"],"connectors":["USB"]}}}'

		@headers = Hash.new
		@headers['AlcatelOT-908222'] = @AlcatelOT_908222
		@headers['SamsungSCH-M828C'] = @SamsungSCH_M828C
		@headers['AlcatelOT-90822'] = @AlcatelOT_90822
		@headers['SamsungGT-P1000'] = @SamsungGT_P1000
		@headers['GenericOperaMini'] = @GenericOperaMini
		@headers['AppleiPhone'] = @AppleiPhone
		@headers['SonyEricssonX10I'] = @SonyEricssonX10I

		@map = Hash['h1'=>@h1, 'h2'=>@h2, 'h3'=>@h3, 'h4'=>@h4, 'h5'=>@h5, 'h6'=>@h6, 'h7'=>@h7]

		@vendors = hd_remote(Configuration.get('vendors') + ".json", "")
		@vendor = JSON.parse(deviceVendors())		
		@model = JSON.parse(deviceModels('Sagem'))
		@deviceView = JSON.parse(deviceView("Nokia","N95"))
		@devicewWhatHas = JSON.parse(deviceWhatHas('network', 'CDMA'))
		@fetchTrees = JSON.parse(siteFetchTrees())
		@fetchSpecs = JSON.parse(siteFetchSpecs)		

		Rails::logger.debug
	end

	# close objecs set to null
	def teardown
		@vendors = nil
		@vendor = nil
		@model = nil
		@deviceView = nil
		@devicewWhatHas = nil
		@fetchTrees = nil
		@fetchSpecs = nil		
	end

	# test username
	def test_usernameRequired()
		assert_equal("", Configuration.get('username'))
	end

	# test secret
	def test_secretRequired()
		assert_equal("", Configuration.get('password'))
	end

	# Test for default config readon from config file
	def test_defaultFileConfig()
		assert_not_nil(Configuration.get('username'))
		assert_not_nil(Configuration.get('password'))
		assert_not_nil(Configuration.get('site_id'))
		assert_not_nil(Configuration.get('apiserver'))
	end

	# Test for default http headers read when a new object is instantiated
	def test_defaultSetup()
		header = "Mozilla/5.0 (SymbianOS/9.2; U; Series60/3.1 NokiaN95-3/20.2.011 Profile/MIDP-2.0 Configuration/CLDC-1.1 ) AppleWebKit/413"
		profile = "http://nds1.nds.nokia.com/uaprof/NN95-1r100.xml"
		ipaddress = "127.0.0.1"
		data = Hash['user-agent'=>header, 'x-wap-profile'=>profile, 'ipaddress'=>ipaddress]
	end

	def test_manualSetup()
		header = "Mozilla/5.0 (SymbianOS/9.2; U; Series60/3.1 NokiaN95-3/20.2.011 Profile/MIDP-2.0 Configuration/CLDC-1.1 ) AppleWebKit/413"
		profile = "http://nds1.nds.nokia.com/uaprof/NN95-1r100.xml"
		d = detect({
	      "Host"=>"localhost",
	      "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
	      "Accept-Language"=>"en-us,en;q=0.5",
	      "Accept-Encoding"=>"gzip, deflate",
	      "Connection"=>"keep-alive",
	      "Cache-Control"=>"max-age=0",
	      "user-agent" => header,
	      "x-wap-profile"=>profile
	   	},server_detect = 1)
		_data = JSON.parse(d.to_s)
		assert_not_nil(_data)
		assert_equal(header d["user-agent"])
		assert_equal(profile, d["x-wap-profile"])		
	end

	def test_invalidCredentials()
		Configuration.get('jones')
		Configuration.get('jipple')
		Configuration.get('57')		
		vendors = deviceVendors()
		assert_not_nil(vendors)
	end

	def deviceVendors(local, proxy)
		_vendors = ["Apple", "Sony", "Samsung", "Nokia", "LG", "HTC", "Karbonn"]
		Configuration.get('use_proxy')

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

	def test_UltimateFetchTrees()
		reply = @fetchTrees
		assert_equal(true, reply)
		assert_equal(true, File.exists?(File.join(Rails.root.to_s + '/tmp/files/hd3trees.json'))
		filenames = ["user-agent0.json", "user-agent1.json", "user-angetplatform.json", "user-agentbrowser.json", "profile0.json"]
		filename.each { |f| 
			assert_equal(true, File.exists?(File.join(Rails.root.to_s + '/tmp/files/', f))
		}
	end

	def test_UltimateFetchSpecs
		reply = @fetchSpecs
		assert_equal(true, reply)
		assert_equal(true, File.exists?(File.join(Rails.root.to_s + '/tmp/files/hd3specs.json'))
		filenames = ["Device_10.json", "Extra_546.json", "Device_46142.json", "Extra_9.json", "Extra_102.json", "user-agent0.json", "user-agent1.json", "user-agentplatform.json", "user-agentbrowser.json", "profile0.json"]
		filename.each { |f| 
			assert_equal(true, File.exists?(File.join(Rails.root.to_s + '/tmp/files/', f))
		}
	end

	def test_UltimateFetchSpecsFail
		Configuration.get('username')
		Configuration.get('password')
		Configuration.get('site_id')
		Configuration.get('apiserver')
		reply = @fetchTrees
		assert_equal(false, reply)
	end

	def test_UltimateFetchArchive		
		filenames = ["Device_10.json", "Extra_546.json", "Device_46142.json", "Extra_9.json", "Extra_102.json", "user-agent0.json", "user-agent1.json", "user-agentplatform.json", "user-agentbrowser.json", "profile0.json"]
		filename.each { |f| 
			assert_equal(true, File.exists?(File.join(Rails.root.to_s + '/tmp/files/', f))
		}
		content = data = File.read(Rails.root.to_s + '/tmp/files/device_10.json')
		assert_equal(@Device_10, content)
	end

end
