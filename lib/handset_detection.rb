require "digest"
require 'socket'
require 'json'
require 'zip/zip'

#require 'extensions/all'


module ActionController
  module HandsetDetection
    class HandsetDetectionConfigFileNotFoundException < StandardError
    end

    class Configuration

      @@other_options = {'vendors' => '/device/vendors',
        'models' => '/device/models',
        'view' => '/device/view',
        'whathas' => '/device/whathas',
      }
      unless File.exist?(Rails.root.to_s + '/config/handset_detection.yml')
        raise HandsetDetectionConfigFileNotFoundException.new("File RAILS_ROOT/config/handset_detection.yml not found")
      else
        env = ENV['RAILS_ENV'] || RAILS_ENV
        HANDSET_DETECTION_CONFIG = YAML.load_file(Rails.root.to_s + '/config/handset_detection.yml')[env]
        @@other_options.each { | key, value |
          HANDSET_DETECTION_CONFIG[key] = value
        }
      end

      def self.get(option)
        HANDSET_DETECTION_CONFIG[option]
      end
    end


    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      @@cache = nil
      def handset_detection
        include HandsetDetection::InstanceMethods
        extend HandsetDetection::SingletonMethods
      end
    end

    module SingletonMethods
    end

    module InstanceMethods
        
      def deviceVendors
        rep = hd_remote(Configuration.get('vendors') + ".json", "")        
        headers,body = rep.split("\r\n\r\n",2)
        return body
      end
#
      def deviceModels(vendor)
        rep = hd_remote(Configuration.get('models') +"/#{vendor}.json","")
        headers,body = rep.split("\r\n\r\n",2)
        return body
      end
#
      def deviceView(vendor, model)
        rep = hd_remote(Configuration.get('view') + "/#{vendor}/#{model}.json", "")
        headers,body = rep.split("\r\n\r\n",2)
        return body
      end
#
      def deviceWhatHas(key, value)
        rep = hd_remote(Configuration.get('whathas') + "/#{key}/#{value}.json", "")
        headers,body = rep.split("\r\n\r\n",2)
        return body
      end
#
      def siteDetect(data)
        id = Configuration.get('site_id')
		    rep = hd_remote("/site/detect/#{id}.json",data)
        headers,body = rep.split("\r\n\r\n",2)
        return body
	    end
#
      def siteFetchTrees
        id = Configuration.get('site_id')
        rep = hd_remote("/site/fetchtrees/#{id}.json", "")
        headers,body = rep.split("\r\n\r\n",2)
        return body
      end
#
      def siteFetchSpecs()
        id = Configuration.get('site_id')
        rep = hd_remote("/site/fetchspecs/#{id}.json", "")
        headers,body = rep.split("\r\n\r\n",2)
        return body
      end

      def siteFetchArchive()
        id = Configuration.get('site_id')        
        rep = hd_remote("/site/fetcharchive/#{id}.json", "")                
        File.open(Rails.root.to_s + '/tmp/files/ultimate.zip', 'wb') {|f| f.write(rep)}  
        extract_files()                          
      end
#
      def detect(data,server_detect=1)
        #@@cache = ActiveSupport::Cache::FileStore.new(Rails.root.to_s + "/tmp/handset_cache_store")
        @@cache ||= ActiveSupport::Cache.lookup_store(:memory_store)
        reply = Hash.new
        non_mobile = Configuration.get('non_mobile')
        if !data['user-agent'].nil?
          if data['user-agent'].match(non_mobile) != nil
            reply["status"] = 301
            reply["message"] = "FastFail : Probable bot, spider or script"
            return reply
          end      
        end
        if server_detect == 1
          return siteDetect(data)
        elsif server_detect == 0
          resp_data = localSiteDetect(data)
          if resp_data["status"] == 301
            set_cache()
            resp_data = localSiteDetect(data)
          end
          return resp_data
        else
          reply["class"] = "unknown"
          reply['message']="Invalid detection method selected , use 1 for server detection and 0 for local detection"
          return reply
        end
      end

      #
      def delete_cache
        @@cache.clear
        return true
      end


      #
      def set_cache
        logger.info 'set_cahe'
        if File::exists?(Rails.root.to_s + '/tmp/specs')
          logger.info 'files already exists , just setting up cache'
          @@cache ||= ActiveSupport::Cache.lookup_store(:memory_store)          
          f1=set_cache_specs_local()
          f3=set_cache_devices_local()
          f2=set_cache_trees_local()                    
          return (f1 and f2 and f3)
        else
          logger.info 'files doest exist , loading data from server , writing to files and then setting up cache'
          return update_cache()
        end
      end

      #
      def update_cache
        #@@cache = ActiveSupport::Cache::FileStore.new(Rails.root.to_s + "/tmp/handset_cache_store")
        @@cache ||= ActiveSupport::Cache.lookup_store(:memory_store)              
        f1 = set_cache_specs()
        f3 = set_cache_devices()
        f2 = set_cache_trees()                
        return (f1 and f2 and f3)
      end
########################################################################################################################
 #  private
      def hd_remote(suburl, data)
        apiserver =  Configuration.get('apiserver')        
		    #url = "http://" + apiserver + "/apiv3" + suburl + ".json"        
        url = "http://" + apiserver + "/apiv3" + suburl
        serverip = apiserver
		    jsondata = data.to_json                
        servers = Socket.gethostbyname(apiserver)        
        #servers = servers.shuffle        
        reply = "nothing"
        servers.each{|serverip|
          reply = hd_post(apiserver,serverip, url, jsondata,suburl)
          break if reply['status'] != 301
        }        
        return reply
      end
#
      def hd_post(apiserver,serverip,url,jsondata,suburl)        
        username = Configuration.get('username')
        #puts username
        realm = 'APIv3'
        secret = Configuration.get('password')

		    port = 80
		    nc = "00000001"

		    cnonce = Digest::MD5.hexdigest("#{Time.now}#{@secret}")
    		qop = 'auth'

    		ha1 = Digest::MD5.hexdigest("#{username}:#{realm}:#{secret}")

        ha2 = Digest::MD5.hexdigest("POST:/apiv3/#{suburl}.json")

    		response = Digest::MD5.hexdigest("#{ha1}:APIv3:#{nc}:#{cnonce}:#{qop}:#{ha2}")

        if Configuration.get('use_proxy') == 1
          pserver = Configuration.get('proxy_server')
          port = Configuration.get('proxy_port')
          user  = Configuration.get('proxy_user')
          pass = Configuration.get('proxy_pass')
          socket = TCPSocket.open(pserver,port)
        else
          socket = TCPSocket.open(serverip,port)
        end
        hd_request = "POST #{url} HTTP/1.0\r\n"
     	  hd_request = hd_request + "Host: #{apiserver}\r\n"
     	  
        if Configuration.get('use_proxy') == 1 
          u = Configuration.get('proxy_user')
          p = Configuration.get('proxy_pass')
          if !u.nil? and !p.nil?
			      hd_request = hd_request + "Proxy-Authorization:Basic " + base64_encode("#{u}:#{p}") + "\r\n"
			    end
		    end
    	  hd_request = hd_request +  "Content-Type: application/zip\r\n";

   		  hd_request = hd_request +  'Authorization: Digest username='
        hd_request = hd_request + '"' + Configuration.get('username') + '"' + 'realm="APIv3", nonce="APIv3",'

        hd_request = hd_request + "uri=/apiv3/#{suburl}.json, qop=auth, nc=00000001, "
        hd_request = hd_request + 'cnonce="' + "#{cnonce}" + '", '
        hd_request = hd_request + 'response="' + "#{response}" + '", '

        hd_request = hd_request + 'opaque="APIv3"'
        hd_request = hd_request + "\r\n"
		    hd_request = hd_request +  "Content-length: #{jsondata.length}\r\n\r\n"
        hd_request = hd_request +  "#{jsondata}\r\n\r\n"
        socket.write(hd_request)

		    hd_reply = socket.read

        return hd_reply
      end
#
      def localSiteDetect(headers)
	      #@@cache = ActiveSupport::Cache::FileStore.new(Rails.root.to_s + "/tmp/handset_cache_store")
        @@cache ||= ActiveSupport::Cache.lookup_store(:memory_store)
	      reply = Hash.new
	      #device = Hash.new
        #if !(@@cache.exist?("nokian958gb") and @@cache.exist?("htcchacha") and @@cache.exist?("nokian9"))
        #  set_cache
        #end
        id = getDevice(headers)
	      if id
	        device = @@cache.read("device"+ id)
	        device = device.dup
          if device != false

			browser = Hash.new
			platform = Hash.new   
			platform_id = getExtra('platform', headers)
			browser_id = getExtra('browser', headers)
			if platform_id != false 
				platform = @@cache.read("extra"+ platform_id)
				platform = platform.dup
			end			
			if browser_id != false
				browser = @@cache.read("extra"+ browser_id)
				browser = browser.dup
			end	
			# Selective merge
			if !browser.nil?			
			  #debugger
			  if !browser['general_browser'].nil?
			    if !browser['general_browser'].empty?
				platform['general_browser'] = browser['general_browser']
				platform['general_browser_version'] = browser['general_browser_version']
			    end
			  end
			end
			if !platform.nil?
			  if !platform['general_platform'].nil?
			    if !platform['general_platform'].empty? 
				device['general_platform'] = platform['general_platform']
				if device['general_platform_version'].nil?
				  device['general_platform_version'] = platform['general_platform_version']	
				end
			    end
			  end
			end			
			if !platform.nil?
			  if !platform['general_browser'].nil?			
			    if !platform['general_browser'].empty?
				device['general_browser'] = platform['general_browser']
				device['general_browser_version'] = platform['general_browser_version']	
			    end
			  end
			end		
	    reply['status'] = 0
            reply['class'] = 'Mobile'
            reply['hd_specs'] = device
	    return reply
	  end
	end
	reply['status'] = 301
	reply['message'] = ' :Local detect nothing found, try site detection '
        reply['class'] = ': unknown  '
	return reply
      end

#
      def getDevice(headers)
        agent = ""
        osHeader = false
	      browserHeader = false           
        #headers = headers.inject({}) do |hash, keys|
        #  headers[keys[0].downcase] = keys[1]
        #  headers
        #end
        headers = Hash[headers.map { |key, value| [key,value.downcase] }]
        if !headers['x-operamini-phone'].nil? #and headers['x-operamini-phone'] != "? # ?")
	  		  id = matchDevice('x-operamini-phone',headers['x-operamini-phone'])
			    if id
				    return id
			    end
			    headers['x-operamini-phone'] = nil
        end

        if !headers['profile'].nil?
			    id =matchDevice('profile',headers['profile'])
			    if id
				    return id
			    end
			    headers['profile'] = nil
		    end

        if !headers['x-wap-profile'].nil?
          id =matchDevice('profile',headers['x-wap-profile'])
			    if id
				    return id
          end
			    headers['profile'] = nil
		    end

        ###############################################################################
        order = ['x-operamini-phone-ua', 'x-mobile-ua', 'user-agent']
        reg_match = /^x-/i
        headers.each{|key,value|
			    if !order.include?(key)

            m = key.match(reg_match)
            if !m.nil?
				      order << key
            end
          end
		    }
        ###############################################################################
		    if !headers['user-agent'].nil?
			    agent = headers['user-agent']
        end

		    order.each{|item|
		  	  if !headers[item].nil?

				    id = matchDevice('user-agent', headers[item])
				    if id
					    osHeader = item
					    browserHeader = item
			        if item == 'x-operamini-phone-ua' and !headers['user-agent'].nil?
						    browserHeader = 'user-agent'
					    end
					    return id
				    end
				  #unset($headers[$item]);
			    end
		    }

		    return matchDevice('user-agent', agent,'1')

      end

     

      def getExtra(cls, valuearr)
	#debugger	
	if cls == 'platform' 
	  checkOrder = ['x-operamini-phone-ua','user-agent'] + valuearr.keys
	elsif cls == 'browser' 
	  checkOrder = ['agent'] + valuearr.keys 			
	end

	
	checkOrder.each{|field|
	logger.info field.include?('x-').to_s  
	if !valuearr[field].nil? #and (field == 'user-agent' or field.include?('x-'))
	    id = matchExtra('user-agent', valuearr[field], cls)
	    if id 
		#returned		
	      return id
		logger.info "id" + id.to_s		
		#ok
		
	    end
		#
	  end
	}
	
        return false;
      end 
#	
      def matchDevice(header,value,generic = '0')

		
        match_filter = Configuration.get('match_filter')
	
	  for i in 0..match_filter.length-1
            value = value.gsub(match_filter[i,1],"")
          end
	treetag = header + generic
        value = value.downcase
        match(header,value,treetag)
      end 
	
      def matchExtra(header, value, cls)
		    #debugger
		    value = value.strip

		    value = value.gsub(" ","")
		    value = value.downcase
		    treetag = header + cls
		
		    return match(header, value, treetag);
      end
	

      def match(header,value,treetag)
	      f = 0
        r = 0	
	    #debugger
	    branch = get_branch(treetag)
        if branch == false
          return false
        end  
        if (header == 'user-agent')
			  #Sieve matching strategy
			    branch.each{|order,filters|
				    filters.each{|filter,matches|
					    f = f + 1
					    if !value.index(filter).nil?
						    matches.each{|match,node|
							    r = r + 1
							    if !value.index(match).nil?
								    return node
							    end
						    }
					    end
				    }
			    }
		    else
			  #// Direct matching strategy
			  
			    if !branch[value].nil?
				    node = branch[value]
				    return node
			    end
		    end
        return false
      end
  #
      def get_branch(header)
        #debugger
        if @@cache.read(header)
			    return @@cache.read(header)
        end
        return false
      end


      def set_cache_specs()
      	id = Configuration.get('site_id')
        rep = hd_remote("/site/fetchspecs/#{id}.json", "")
        headers,body = rep.split("\r\n\r\n",2)
        File.open(Rails.root.to_s + '/tmp/specs', 'w') {|f| f.write(body) }
        return set_cache_specs_local()
      end
#
      def set_cache_trees()
        id = Configuration.get('site_id')
        rep = hd_remote("/site/fetchtrees/#{id}.json", "")
        headers,body = rep.split("\r\n\r\n",2)
        File.open(Rails.root.to_s + '/tmp/trees', 'w') {|f| f.write(body) }
        return set_cache_trees_local()
      end

      def set_cache_devices()      
        return set_cache_devices_local()        
      end

      def extract_files()
        Zip::ZipFile.open(Rails.root.to_s + '/tmp/files/ultimate.zip') { |zip_file|
          zip_file.each { |f|          
            f_path=File.join(Rails.root.to_s + '/tmp/files/', f.name.gsub(':','_'))
            FileUtils.mkdir_p(File.dirname(f_path))            
            if(f_path=~/\Device_.*json+/)
              zip_file.extract(f, f_path) unless File.exist?(f_path)
            end          
          }
        }
        return true
      end

      def set_cache_devices_local()                   
        Dir.glob(Rails.root.to_s+'/tmp/files/'+"*.json") do |filename|          
          file = File.new(filename,'r')    
          body = file.read()
          device = ActiveSupport::JSON.decode body
          device_id = device['Device']['_id']
          device_specs = device['Device']['hd_specs']
          begin
            @@cache.write("device" + device_id.to_s,device_specs)
          rescue
            logger.info '======================================= ERROR IN SPECS ================================================='
            logger.info device
            logger.info id
            logger.info specs
          end        
        end             
        return true   
      end      
      
      def set_cache_specs_local()
	      #file = File.new(Rails.root.to_s + '/tmp/specs','r')
        #body = file.read()
        #data = ActiveSupport::JSON.decode body
=begin      
	      if !data['devices'].nil?
	        data['devices'].each {|device|
            device_id = device['Device']['_id']
            device_specs = device['Device']['hd_specs']
            begin
              @@cache.write("device" + device_id.to_s,device_specs)
            rescue
              logger.info '======================================= ERROR IN SPECS ================================================='
              logger.info device
              logger.info id
              logger.info specs
            end
	        }
	      end
=end        
      	if !data['extras'].nil?
	        data['extras'].each {|extra|
            extra_id = extra['Extra']['_id']
            extra_specs = extra['Extra']['hd_specs']
            begin
              @@cache.write("extra" + extra_id.to_s,extra_specs)
            rescue
              logger.info '======================================= ERROR IN SPECS ================================================='
              logger.info device
              logger.info id
              logger.info specs
            end
	        }
	      end
	      return true
      end
#
      def set_cache_trees_local()
        file = File.new(Rails.root.to_s + '/tmp/trees','r')
        body = file.read()
        data = ActiveSupport::JSON.decode body
        if data.nil?
          return false
        end
        data['trees'].each {|key,branch|
          @@cache.write(key.to_s,branch)
        }
        return true
      end



    end

  end

end

ActionController::Base.send(:include, ActionController::HandsetDetection)
