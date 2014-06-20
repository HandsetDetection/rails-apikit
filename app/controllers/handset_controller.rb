require 'fileutils'

class HandsetController < ApplicationController
  def index
    render :text => '
<h1><center>Handset Detection Rails API Kit Demo</center></h1>

    <h3>There are following Methods</h3>

    <ul>
      <li>Install gem in Gemfile i.e gem "handsetdetection"</li>
      <li>Add "handset_detection" at the top of your Application Controller i.e. <br>
        &nbsp;&nbsp;class ApplicationController < ActionController::Base<br>
        &nbsp;&nbsp;&nbsp;&nbsp;require "handset_detection"<br>
        &nbsp;&nbsp;&nbsp;&nbsp;.<br>
        &nbsp;&nbsp;&nbsp;&nbsp;.<br>
        &nbsp;&nbsp;&nbsp;&nbsp;.<br>
        &nbsp;&nbsp;end
      </li>
      <li>Thats it, use Handset detection Methods anywhere in rails application</li>
    </ul>

    <h3> Examples of each method </h3>

    <ul>
      <li> <a href="/handset/device_vendors">deviceVendors</a> </li>
      <li> <a href="/handset/device_models">deviceModels("Sagem")</a> </li>
      <li> <a href="/handset/device_view">deviceView("Nokia","N95")</a> </li>
      <li> <a href="/handset/device_whathas">deviceWhatHas("network","CDMA")</a> </li>
      <li> <a href="/handset/site_detect">For Server detection , pass header and server_detect = 1 to detect method e.g.<br/><br/>detect({
        "Host"=>"localhost",
        "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language"=>"en-us,en;q=0.5",
        "Accept-Encoding"=>"gzip, deflate",
        "Connection"=>"keep-alive",
        "Cache-Control"=>"max-age=0",
        "ipaddress"=>"127.0.0.1",
        "User-Agent"=>"NokiaN95",
        "x-wap-profile"=>"http://nds1.nds.nokia.com/uaprof/NN95-1r100.xml"
      },server_detect = 1)</a> </li>
      <li> <a href="/handset/local_detect">For Local detection , pass header and server_detect = 0 to detect method e.g.<br/><br/>detect({
        "Host"=>"localhost",
        "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language"=>"en-us,en;q=0.5",
        "Accept-Encoding"=>"gzip, deflate",
        "Connection"=>"keep-alive",
        "Cache-Control"=>"max-age=0",
        "ipaddress"=>"127.0.0.1",
        "User-Agent"=>"NokiaN95",
        "x-wap-profile"=>"http://nds1.nds.nokia.com/uaprof/NN95-1r100.xml"
      },server_detect = 0)</a> </li>
      <li> <a href="/handset/fetch_trees">siteFetchTrees</a> </li>
      <li> <a href="/handset/fetch_specs">siteFetchSpecs</a> </li>
      <li> <a href="/handset/fetch_archive">siteFetchArchive</a> </li>
      <li> <a href="/handset/set_cache_manually">Set Cache</a> </li>
      <li> <a href="/handset/delete_cache_manually">Delete Cache</a> </li>      
      <li> <a href="/handset/local_test">Local Detection Test</a> </li>
      <li> <a href="/handset/site_test">Server Detection Test</a> </li>

    </ul>
'
  end
  def device_vendors
    @vendors = deviceVendors()
    render :text => "<br/> @vendors = deviceVendors<br/> And then print @vendors will results like<br/>" + @vendors
  end
  def device_models
    @vendors = deviceModels("Sagem")
    render :text => "<br/> @models = deviceModels('Sagem')<br/> And then print @models will results like<br/>" + @vendors
  end
  
  def device_view
    @vendors = deviceView("Nokia","N95")
    render :text => "<br/> @models = deviceView('Nokia','N95')<br/> And then print @models will results like<br/>" + @vendors
  end
  
  def device_whathas
    @vendors = deviceWhatHas('network', 'CDMA')
    render :text => "<br/> @models = deviceWhatHas('network','CDMA')<br/> And then print @models will results like<br/>" + @vendors
  end
  
  def site_detect
    start_time = Time.now
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
    end_time = Time.now
    elapsed_time = (end_time - start_time) * 1000
    elapsedTimeSec = elapsed_time/1000.to_f
    render :text => '<br/>detect method take two arguments , <br/>1st is data header and <br/>2nd is detection method (send 1 for server detection and 0 for local detection , if no argument is passed then server detection is used<br/><br/> d = detect({
      "Host"=>"localhost",
      "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language"=>"en-us,en;q=0.5",
      "Accept-Encoding"=>"gzip, deflate",
      "Connection"=>"keep-alive",
      "Cache-Control"=>"max-age=0",
      "ipaddress"=>"127.0.0.1",
   "user-agent" => "Dalvik/1.4.0 (Linux; U; Android 2.3.1; TM-7022 Build/GINGERBREAD)",
      "x-wap-profile"=>"http://wap.sonyericsson.com/UAprof/LT15iR301.xml"
    },server_detect = 1)<br/><br/> And then print d.to_s will results like<br/><br/>' + d.to_s + "<br/><br/>Elapsed Time " + elapsedTimeSec.to_s  
  end

  def local_detect
    start_time = Time.now
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
    end_time = Time.now
    elapsed_time = (end_time - start_time) * 1000
    elapsedTimeSec = elapsed_time/1000.to_f
    #debugger
    render :text => '<br/>detect method take two arguments , <br/>1st is data header and <br/>2nd is detection method (send 1 for server detection and 0 for local detection , if no argument is passed then server detection is used<br/><br/> d = detect({
      "Host"=>"localhost",
      "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      "Accept-Language"=>"en-us,en;q=0.5",
      "Accept-Encoding"=>"gzip, deflate",
      "Connection"=>"keep-alive",
      "Cache-Control"=>"max-age=0",
      "ipaddress"=>"127.0.0.1",
      "user-agent" => "Dalvik/1.4.0 (Linux; U; Android 2.3.1; TM-7022 Build/GINGERBREAD)",
      "x-wap-profile"=>"http://wap.sonyericsson.com/UAprof/LT15iR301.xml"
    },server_detect = 0)<br/><br/> And then print d.to_s will results like<br/><br/>' + d.to_s + "<br/><br/>Elapsed Time " + elapsedTimeSec.to_s  
  end

  def fetch_trees
    data = siteFetchTrees
    render :text => data
  end

  def fetch_specs
    @vendors = siteFetchSpecs
    render :text => @vendors
  end

  def fetch_archive
    start_time = Time.now
    data = siteFetchArchive
    end_time = Time.now
    elapsed_time = (end_time - start_time) * 1000
    elapsedTimeSec = elapsed_time/1000.to_f
    render :text => "<h1>Test Complete</h1><h3>Elapsed time: " + elapsedTimeSec.to_s + "ms</h3>"
  end

  def delete_cache_manually
    render :text => "Just call delete_cache Method to delete both cache spec and cache tree<br/>This will return True if both are deleted<br/>" + delete_cache.to_s
    #cache = ActiveSupport::Cache.lookup_store(:memory_store)
    #cache = ActiveSupport::Cache::FileStore.new(Rails.root.to_s + "/lib/handset_cache_store")
    #cache.write('mst','MUHAMMAD Shahzad Tariq')
    #render :text => cache.read('mst')
  end

  def set_cache_manually
    render :text => "Just call set_cache Method to set both cache spec and cache tree<br/>This will return True if both are set<br/>" + set_cache.to_s
  end
  
  def local_test
    data = ''
    count = 0
    f = File.open("headers.txt", "r") 
    start_time = Time.now
      f.each_line do |line|
        headers = line.split("|")
        useragent = headers[0]
        profile = headers[1].to_s
        #(1..10).each do |i|
          #data += useragent   
        detect({
          "Host"=>"localhost",
          "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Accept-Language"=>"en-us,en;q=0.5",
          "Accept-Encoding"=>"gzip, deflate",
          "Connection"=>"keep-alive",
          "Cache-Control"=>"max-age=0",
          "user-agent" => useragent,
          "x-wap-profile"=> profile
        },server_detect = 1)                                      
        count += 1        
        #end        
      end
     end_time = Time.now
     elapsed_time = (end_time - start_time) * 1000
     elapsedTimeSec = elapsed_time/1000.to_f
     dps = count / elapsedTimeSec
     tdps = dps.to_i
     #data += "<br/>"
     data += "<h1>Test Complete</h1>"
     data += "<h3>Elapsed time: " + elapsedTimeSec.to_s + "ms, Total detections: " + count.to_s + ", Detections per second: " + tdps.to_s + "</h3>"  
    render :text => data
  end

  def local_array_test
    data = ''
    test_str = ""
    test_count = 0    
    start_time = Time.now
    $gls.each{|value|
      d = detect({
          "Host"=>"localhost",
          "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Accept-Language"=>"en-us,en;q=0.5",
          "Accept-Encoding"=>"gzip, deflate",
          "Connection"=>"keep-alive",
          "Cache-Control"=>"max-age=0",
          "user-agent" => value['user-agent'],
          "x-wap-profile"=> value['x-wap-profile']
        },server_detect = 0)        
        test_count = test_count + 1
        #test_str = test_str + "User-agent: " + value['user-agent'] + "<br/>" + "profile: " + value['x-wap-profile'] + "<br/><br/>" + "Device Detection Response: " + d.to_s + "<br/>================================================================================================<br/>"
    }    
    end_time = Time.now
    elapsed_time = (end_time - start_time) * 1000
    elapsedTimeSec = elapsed_time/1000.to_f
    dps = test_count / elapsedTimeSec
    tdps = dps.to_i    
    data += "<h1>Test Complete</h1>"
    data += "<h3>Elapsed time: " + elapsedTimeSec.to_s + "ms, Total detections: " + test_count.to_s + ", Detections per second: " + tdps.to_s + "</h3>"  
    render :text => data
  end

  def site_test
    test_str = ""
    test_count = 0

    $gls.each{|value|
      d = detect({
          "Host"=>"localhost",
          "Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
          "Accept-Language"=>"en-us,en;q=0.5",
          "Accept-Encoding"=>"gzip, deflate",
          "Connection"=>"keep-alive",
          "Cache-Control"=>"max-age=0",
          "user-agent" => value['user-agent'],
          "x-wap-profile"=> value['x-wap-profile']
        },server_detect = 1)

        test_count = test_count + 1
        test_str = test_str + "User-agent: " + value['user-agent'] + "<br/>" + "profile: " + value['x-wap-profile'] + "<br/><br/>" + "Device Detection Response: " + d.to_s + "<br/>================================================================================================<br/>"
    }
    render :text => test_str  + "               Count: " + test_count.to_s
  end

  def socket_test
    x = Socket.gethostbyname "google.com"
    render :text => "x"
  end
end

