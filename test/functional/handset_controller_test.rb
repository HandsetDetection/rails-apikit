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

		#@vendors = hd_remote(Configuration.get('vendors') + ".json", "")
		#@vendor = JSON.parse(deviceVendors())
		#@model = JSON.parse(deviceModels('Sagem'))
		#@deviceView = JSON.parse(deviceView("Nokia","N95"))
		#@devicewWhatHas = JSON.parse(deviceWhatHas('network', 'CDMA'))
		#@fetchTrees = JSON.parse(siteFetchTrees())
		#@fetchSpecs = JSON.parse(siteFetchSpecs())

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

	def test_cloudConfigExists()
		assert_equal(true, true)
	end

	def test_deviceVendors()
		reply = JSON.parse(deviceVendors())
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_send([reply['vendor'], :member?, 'Nokia'])
		assert_send([reply['vendor'], :member?, 'Samsung'])
	end

	def test_deviceModels()
		reply = JSON.parse(deviceView('Nokia', 'N95'))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal(@nokiaN95.downcase, JSON.generate(reply['device']).downcase)
	end

	def test_deviceDeviceWhatHas()
		reply = JSON.parse(deviceWhatHas('design_dimensions', '101 x 44 x 16'))
		assert_not_nil(reply)
		test_reply_isok(reply)
		jsonString = JSON.generate(reply['devices'])

		assert_not_nil(/Asus/.match(jsonString))
		assert_not_nil(/V80/.match(jsonString))
		assert_not_nil(/Spice/.match(jsonString))
		assert_not_nil(/S900/.match(jsonString))
		assert_not_nil(/Voxtel/.match(jsonString))
		assert_not_nil(/RX800/.match(jsonString))
	end

	def test_deviceDetectHTTPDesktop()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Computer', reply['hd_specs']['general_type'])
	end

	def test_deviceDetectHTTPDesktopJunk()
		headers = Hash.new
		headers['User-Agent'] = 'aksjakdjkjdaiwdidjkjdkawjdijwidawjdiajwdkawdjiwjdiawjdwidjwakdjajdkad' + Time.new().to_s

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		assert_equal(301, reply['status'])
		assert_equal('Not Found', reply['message'])
	end

	def test_deviceDetectHTTPWii()
		headers = Hash.new
		headers['User-Agent'] = 'Opera/9.30 (Nintendo Wii; U; ; 2047-7; es-Es)'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Mobile', reply['hd_specs']['general_type'])
	end

	def test_deviceDetectHTTP()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('iPhone', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.3', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_deviceDetectHTTPOtherHeader()
		headers = Hash.new
		headers['user-agent'] = 'blahblahblah'
		headers['x-fish-header'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.3', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_deviceDetectHTTPHardwareInfo()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:100:100'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3GS', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.2.1', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_deviceDetectHTTPHardwareInfoB()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:100:72'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3G', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.2.1', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_deviceDetectHTTPHardwareInfoC()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_0 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:200:1200'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3G', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('2.0', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_deviceDetectHTTPFBiOS()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D201 [FBAN/FBIOS;FBAV/9.0.0.25.31;FBBV/2102024;FBDV/iPhone6,2;FBMD/iPhone;FBSN/iPhone OS;FBSV/7.1.1;FBSS/2; FBCR/vodafoneIE;FBID/phone;FBLC/en_US;FBOP/5]'
		headers['Accept-Language'] = 'da, en-gb;q=0.8, en;q=0.7'

		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 5S', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('7.1.1', reply['hd_specs']['general_platform_version'])
		assert_equal('da', reply['hd_specs']['general_language'])
		assert_equal('Danish', reply['hd_specs']['general_language_full'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('Facebook', reply['hd_specs']['general_app'])
		assert_equal('9.0', reply['hd_specs']['general_app_version'])
		assert_equal('', reply['hd_specs']['general_browser'])
		assert_equal('', reply['hd_specs']['general_browser_version'])

		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_deviceDetectBIAndroid()
		buildInfo = Hash.new
		buildInfo['ro.build.PDA'] = 'I9500XXUFNE7'
		buildInfo['ro.build.changelist'] = '699287'
		buildInfo['ro.build.characteristics'] = 'phone'
		buildInfo['ro.build.date.utc'] = '1401287026'
		buildInfo['ro.build.date'] = 'Wed May 28 23:23:46 KST 2014'
		buildInfo['ro.build.description'] = 'ja3gxx-user 4.4.2 KOT49H I9500XXUFNE7 release-keys'
		buildInfo['ro.build.display.id'] = 'KOT49H.I9500XXUFNE7'
		buildInfo['ro.build.fingerprint'] = 'samsung/ja3gxx/ja3g:4.4.2/KOT49H/I9500XXUFNE7:user/release-keys'
		buildInfo['ro.build.hidden_ver'] = 'I9500XXUFNE7'
		buildInfo['ro.build.host'] = 'SWDD5723'
		buildInfo['ro.build.id'] = 'KOT49H'
		buildInfo['ro.build.product'] = 'ja3g'
		buildInfo['ro.build.tags'] = 'release-keys'
		buildInfo['ro.build.type'] = 'user'
		buildInfo['ro.build.user'] = 'dpi'
		buildInfo['ro.build.version.codename'] = 'REL'
		buildInfo['ro.build.version.incremental'] = 'I9500XXUFNE7'
		buildInfo['ro.build.version.release'] = '4.4.2'
		buildInfo['ro.build.version.sdk'] = '19'
		buildInfo['ro.product.board'] = 'universal5410'
		buildInfo['ro.product.brand'] = 'samsung'
		buildInfo['ro.product.cpu.abi2'] = 'armeabi'
		buildInfo['ro.product.cpu.abi'] = 'armeabi-v7a'
		buildInfo['ro.product.device'] = 'ja3g'
		buildInfo['ro.product.locale.language'] = 'en'
		buildInfo['ro.product.locale.region'] = 'GB'
		buildInfo['ro.product.manufacturer'] = 'samsung'
		buildInfo['ro.product.model'] = 'GT-I9500'
		buildInfo['ro.product.name'] = 'ja3gxx'
		buildInfo['ro.product_ship'] = 'true'

		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Samsung', reply['hd_specs']['general_vendor'])
		assert_equal('GT-I9500', reply['hd_specs']['general_model'])
		assert_equal('Android', reply['hd_specs']['general_platform'])
		assert_equal('Samsung Galaxy S4', reply['hd_specs']['general_aliases'][0])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
	end

	def test_deviceDetectBIiOS()
		buildInfo = Hash.new
		buildInfo['utsname.machine'] = 'iphone4,1',
		buildInfo['utsname.brand'] = 'Apple'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 4S', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('5.0', reply['hd_specs']['general_platform_version'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
	end

	def test_deviceDetectWindowsPhone()
		buildInfo = Hash.new
		buildInfo['devicemanufacturer'] = 'nokia'
		buildInfo['devicename'] = 'RM-875'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Nokia', reply['hd_specs']['general_vendor'])
		assert_equal('Lumia 1020', reply['hd_specs']['general_model'])
		assert_equal('Windows Phone', reply['hd_specs']['general_platform'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal(332, reply['hd_specs']['display_ppi'])
	end

	def test_fetchArchive()
		#result = ultimateFetcharchive()
		#assert(result)
	end

	def test_ultimate_deviceVendors()
		reply = JSON.parse(deviceVendors())
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_send([reply['vendor'], :member?, 'Nokia'])
		assert_send([reply['vendor'], :member?, 'Samsung'])
	end

	def test_ultimate_deviceModels()
		reply = JSON.parse(deviceModels('Nokia'))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert(reply['model'].count > 700)
	end

	def test_ultimate_deviceView()
		reply = JSON.parse(deviceView('Nokia', 'N9'))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal(@nokiaN95.downcase, JSON.generate(reply['device']).downcase)
	end

	def test_ultimate_deviceDeviceWhatHas()
		reply = JSON.parse(deviceWhatHas('design_dimensions', '101 x 44 x 16'))
		assert_not_nil(reply)
		test_reply_isok(reply)
		jsonString = JSON.generate(reply['devices'])
		assert_not_nil(/Asus/.match(jsonString))
		assert_not_nil(/V80/.match(jsonString))
		assert_not_nil(/Spice/.match(jsonString))
		assert_not_nil(/S900/.match(jsonString))
		assert_not_nil(/Voxtel/.match(jsonString))
		assert_not_nil(/RX800/.match(jsonString))
	end

	def test_ultimate_deviceDetectHTTPDesktop()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Computer', reply['hd_specs']['general_type'])
	end

	def test_ultimate_deviceDetectHTTPDesktopJunk()
		headers = Hash.new
		headers['User-Agent'] = 'aksjakdjkjdaiwdidjkjdkawjdijwidawjdiajwdkawdjiwjdiawjdwidjwakdjajdkad'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		assert_equal(301, reply['status'])
		assert_equal('Not Found', reply['message'])
	end

	def test_ultimate_deviceDetectHTTPWii()
		headers = Hash.new
		headers['User-Agent'] = 'Opera/9.30 (Nintendo Wii; U; ; 2047-7; es-Es)'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Mobile', reply['hd_specs']['general_type'])
	end

	def test_ultimate_deviceDetectHTTP()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.3', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_deviceDetectHTTPOtherHeader()
		headers = Hash.new
		headers['User-Agent'] = 'blahblahblah'
		headers['x-fish-header'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.3', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_deviceDetectHTTPHardwareInfo()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:100:100'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3GS', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.2.1', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_deviceDetectHTTPHardwareInfoB()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:100:72'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3G', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.2.1', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_deviceDetectHTTPHardwareInfoC()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_0 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:200:1200'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3G', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('2.0', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_deviceDetectHTTPFBiOS()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D201 [FBAN/FBIOS;FBAV/9.0.0.25.31;FBBV/2102024;FBDV/iPhone6,2;FBMD/iPhone;FBSN/iPhone OS;FBSV/7.1.1;FBSS/2; FBCR/vodafoneIE;FBID/phone;FBLC/en_US;FBOP/5]'
		headers['Accept-Language'] = 'da, en-gb;q=0.8, en;q=0.7'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 5S', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('7.1.1', reply['hd_specs']['general_platform_version'])
		assert_equal('da', reply['hd_specs']['general_language'])
		assert_equal('Danish', reply['hd_specs']['general_language_full'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('Facebook', reply['hd_specs']['general_app'])
		assert_equal('9.0', reply['hd_specs']['general_app_version'])
		assert_equal('', reply['hd_specs']['general_browser'])
		assert_equal('', reply['hd_specs']['general_browser_version'])

		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_deviceDetectBIAndroid()
		buildInfo = Hash.new
		buildInfo['ro.build.PDA'] = 'I9500XXUFNE7'
		buildInfo['ro.build.changelist'] = '699287'
		buildInfo['ro.build.characteristics'] = 'phone'
		buildInfo['ro.build.date.utc'] = '1401287026'
		buildInfo['ro.build.date'] = 'Wed May 28 23:23:46 KST 2014'
		buildInfo['ro.build.description'] = 'ja3gxx-user 4.4.2 KOT49H I9500XXUFNE7 release-keys'
		buildInfo['ro.build.display.id'] = 'KOT49H.I9500XXUFNE7'
		buildInfo['ro.build.fingerprint'] = 'samsung/ja3gxx/ja3g:4.4.2/KOT49H/I9500XXUFNE7:user/release-keys'
		buildInfo['ro.build.hidden_ver'] = 'I9500XXUFNE7'
		buildInfo['ro.build.host'] = 'SWDD5723'
		buildInfo['ro.build.id'] = 'KOT49H'
		buildInfo['ro.build.product'] = 'ja3g'
		buildInfo['ro.build.tags'] = 'release-keys'
		buildInfo['ro.build.type'] = 'user'
		buildInfo['ro.build.user'] = 'dpi'
		buildInfo['ro.build.version.codename'] = 'REL'
		buildInfo['ro.build.version.incremental'] = 'I9500XXUFNE7'
		buildInfo['ro.build.version.release'] = '4.4.2'
		buildInfo['ro.build.version.sdk'] = '19'
		buildInfo['ro.product.board'] = 'universal5410'
		buildInfo['ro.product.brand'] = 'samsung'
		buildInfo['ro.product.cpu.abi2'] = 'armeabi'
		buildInfo['ro.product.cpu.abi'] = 'armeabi-v7a'
		buildInfo['ro.product.device'] = 'ja3g'
		buildInfo['ro.product.locale.language'] = 'en'
		buildInfo['ro.product.locale.region'] = 'GB'
		buildInfo['ro.product.manufacturer'] = 'samsung'
		buildInfo['ro.product.model'] = 'GT-I9500'
		buildInfo['ro.product.name'] = 'ja3gxx'
		buildInfo['ro.product_ship'] = 'true'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Samsung', reply['hd_specs']['general_vendor'])
		assert_equal('GT-I9500', reply['hd_specs']['general_model'])
		assert_equal('Android', reply['hd_specs']['general_platform'])
		assert_equal('Samsung Galaxy S4', reply['hd_specs']['general_aliases'][0])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
	end

	def test_ultimate_deviceDetectBIiOS()
		buildInfo = Hash.new
		buildInfo['utsname.machine'] = 'iphone4,1'
		buildInfo['utsname.brand'] = 'Apple'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 4S', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('5.0', reply['hd_specs']['general_platform_version'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
	end

	def test_ultimate_deviceDetectWindowsPhone()
		buildInfo = Hash.new
		buildInfo['devicemanufacturer'] = 'nokia'
		buildInfo['devicename'] = 'RM-875'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Nokia', reply['hd_specs']['general_vendor'])
		assert_equal('Lumia 1020', reply['hd_specs']['general_model'])
		assert_equal('Windows Phone', reply['hd_specs']['general_platform'])
		assert_equal('Mobile', reply['hd_specs']['general_type'])
		assert_equal('332', reply['hd_specs']['display_ppi'])
	end

	def test_ultimate_community_fetchArchive()
		#result = communityFetcharchive()
		#assert(result)
	end

	def test_ultimate_community_deviceDetectHTTPDesktop()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('', reply['hd_specs']['general_type'])
	end

	def test_ultimate_community_deviceDetectHTTPDesktopJunk()
		headers = Hash.new
		headers['User-Agent'] = 'aksjakdjkjdaiwdidjkjdkawjdijwidawjdiajwdkawdjiwjdiawjdwidjwakdjajdkad'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		assert_equal(301, reply['status'])
		assert_equal('Not Found', reply['message'])
	end

	def test_ultimate_community_deviceDetectHTTPWii()
		headers = Hash.new
		headers['User-Agent'] = 'Opera/9.30 (Nintendo Wii; U; ; 2047-7; es-Es)'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('', reply['hd_specs']['general_type'])
	end

	def test_ultimate_community_deviceDetectHTTP()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('', reply['hd_specs']['general_type'])
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.3', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_community_deviceDetectHTTPOtherHeader()
		headers = Hash.new
		headers['User-Agent'] = 'blahblahblah'
		headers['x-fish-header'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_3 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('', reply['hd_specs']['general_type'])
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.3', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_community_deviceDetectHTTPHardwareInfo()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:100:100'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3GS', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.2.1', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_community_deviceDetectHTTPHardwareInfoB()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_2_1 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:100:72'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3G', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('4.2.1', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_community_deviceDetectHTTPHardwareInfoC()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_0 like Mac OS X; en-gb) AppleWebKit/533.17.9 (KHTML, like Gecko)'
		headers['x-local-hardwareinfo'] = '320:480:200:1200'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 3G', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('2.0', reply['hd_specs']['general_platform_version'])
		assert_equal('en-gb', reply['hd_specs']['general_language'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_community_deviceDetectHTTPFBiOS()
		headers = Hash.new
		headers['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 7_1_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Mobile/11D201 [FBAN/FBIOS;FBAV/9.0.0.25.31;FBBV/2102024;FBDV/iPhone6,2;FBMD/iPhone;FBSN/iPhone OS;FBSV/7.1.1;FBSS/2; FBCR/vodafoneIE;FBID/phone;FBLC/en_US;FBOP/5]'
		headers['Accept-Language'] = 'da, en-gb;q=0.8, en;q=0.7'
		reply = JSON.parse(deviceDetect(headers))
		assert_not_nil(reply)
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 5S', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('7.1.1', reply['hd_specs']['general_platform_version'])
		assert_equal('da', reply['hd_specs']['general_language'])
		assert_equal('Danish', reply['hd_specs']['general_language_full'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert_equal('Facebook', reply['hd_specs']['general_app'])
		assert_equal('9.0', reply['hd_specs']['general_app_version'])
		assert_equal('', reply['hd_specs']['general_browser'])
		assert_equal('', reply['hd_specs']['general_browser_version'])

		assert(reply['hd_specs'].has_key?('display_pixel_ratio'))
		assert(reply['hd_specs'].has_key?('display_ppi'))
		assert(reply['hd_specs'].has_key?('benchmark_min'))
		assert(reply['hd_specs'].has_key?('benchmark_max'))
	end

	def test_ultimate_community_deviceDetectBIAndroid()
		buildInfo = Hash.new
		buildInfo['ro.build.PDA'] = 'I9500XXUFNE7'
		buildInfo['ro.build.changelist'] = '699287'
		buildInfo['ro.build.characteristics'] = 'phone'
		buildInfo['ro.build.date.utc'] = '1401287026'
		buildInfo['ro.build.date'] = 'Wed May 28 23:23:46 KST 2014'
		buildInfo['ro.build.description'] = 'ja3gxx-user 4.4.2 KOT49H I9500XXUFNE7 release-keys'
		buildInfo['ro.build.display.id'] = 'KOT49H.I9500XXUFNE7'
		buildInfo['ro.build.fingerprint'] = 'samsung/ja3gxx/ja3g:4.4.2/KOT49H/I9500XXUFNE7:user/release-keys'
		buildInfo['ro.build.hidden_ver'] = 'I9500XXUFNE7'
		buildInfo['ro.build.host'] = 'SWDD5723'
		buildInfo['ro.build.id'] = 'KOT49H'
		buildInfo['ro.build.product'] = 'ja3g'
		buildInfo['ro.build.tags'] = 'release-keys'
		buildInfo['ro.build.type'] = 'user'
		buildInfo['ro.build.user'] = 'dpi'
		buildInfo['ro.build.version.codename'] = 'REL'
		buildInfo['ro.build.version.incremental'] = 'I9500XXUFNE7'
		buildInfo['ro.build.version.release'] = '4.4.2'
		buildInfo['ro.build.version.sdk'] = '19'
		buildInfo['ro.product.board'] = 'universal5410'
		buildInfo['ro.product.brand'] = 'samsung'
		buildInfo['ro.product.cpu.abi2'] = 'armeabi'
		buildInfo['ro.product.cpu.abi'] = 'armeabi-v7a'
		buildInfo['ro.product.device'] = 'ja3g'
		buildInfo['ro.product.locale.language'] = 'en'
		buildInfo['ro.product.locale.region'] = 'GB'
		buildInfo['ro.product.manufacturer'] = 'samsung'
		buildInfo['ro.product.model'] = 'GT-I9500'
		buildInfo['ro.product.name'] = 'ja3gxx'
		buildInfo['ro.product_ship'] = 'true'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Samsung', reply['hd_specs']['general_vendor'])
		assert_equal('GT-I9500', reply['hd_specs']['general_model'])
		assert_equal('Android', reply['hd_specs']['general_platform'])
		assert(reply['hd_specs']['general_aliases'][0].empty?)
		assert_equal('', reply['hd_specs']['general_type'])
	end

	def test_ultimate_community_deviceDetectBIiOS()
		buildInfo = Hash.new
		buildInfo['utsname.machine'] = 'iphone4,1'
		buildInfo['utsname.brand'] = 'Apple'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Apple', reply['hd_specs']['general_vendor'])
		assert_equal('iPhone 4S', reply['hd_specs']['general_model'])
		assert_equal('iOS', reply['hd_specs']['general_platform'])
		assert_equal('5.0', reply['hd_specs']['general_platform_version'])
		assert_equal('', reply['hd_specs']['general_type'])
	end

	def test_ultimate_community_deviceDetectWindowsPhone()
		buildInfo = Hash.new
		buildInfo['devicemanufacturer'] = 'nokia'
		buildInfo['devicename'] = 'RM-875'
		reply = JSON.parse(deviceDetect(buildInfo))
		test_reply_isok(reply)
		assert_equal('Nokia', reply['hd_specs']['general_vendor'])
		assert_equal('Lumia 1020', reply['hd_specs']['general_model'])
		assert_equal('Windows Phone', reply['hd_specs']['general_platform'])
		assert_equal('', reply['hd_specs']['general_type'])
		assert_equal(0, reply['hd_specs']['display_ppi'])
	end

	def test_reply_isok(reply)
		assert_equal(0, reply['status'])
		assert_equal('OK', reply['message'])
	end
end
