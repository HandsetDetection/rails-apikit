require "digest"
require 'socket'
require 'json'
require 'zip/zip'
#require 'extensions/all'


module ActionController
  module HandsetDetection
    class HandsetDetectionConfigFileNotFoundException < StandardError
    end

    class HandsetExtra
      def initialize
        @data = nil
        @store = HandsetStore.new
      end

      def set(data)
        @data = data
      end

      def matchExtra(cclass, headers)
        headers.delete('profile')
        order = @detectionConfig["#{cclass}-ua-order"]
        headers.each{|key, value|
          if order.include?(key) && /^x-i/.match(key)
            order.push(key)
          end
        }
        order.each{|field|
          if (!headers[field].empty?)
            id = getMatch('user-agent', headers[field], cclass, field, cclass)
            if (id != nil)
              extra = findById(id)
              return extra
            end
          end
        }
        return nil
      end

      def findById(id)
        return @store.read("Extra_#{id}")
      end

      def matchLanguage(headers)
        extra = Array.new
        extra['_id'] = 0
        extra['Extra']['hd_specs']['general_language'] = ''
        extra['Extra']['hd_specs']['general_language_full'] = ''
        if (!headers['language'].empty?)
          candidate = headers['language']
          if (detectionLanguage[candidiate])
            extra['Extra']['hd_specs']['general_language'] = candidate
            extra['Extra']['hd_specs']['general_language_full'] = detectionLanguages[candidate]
            return extra
          end
        end

        checkOrder = @detectionConfig['language-ua-order'].hash(headers)
        languageList = @detectionLanguages
        checkOrder.each{|header|
          if (!agent.empty?)
            languageList.each{|code, full|
              if (/[; \(]#{code}[; \)]/.match(agent))
                extra['Extra']['hd_specs']['general_language'] = code
                extra['Extra']['hd_specs']['general_language_full'] = full
                return extra
              end
            }
          end
        }
        return nil
      end

      def verifyPlatform(specs = nil)
        platform = @data
        platformName = platform['Extra']['hd_specs']['general_platform'].downcase.strip
        platformVersion = platform['Extra']['hd_specs']['general_platform_version'].downcase.strip
        devicePlatformName = specs['general_platform'].downcase.strip
        devicePlatformVersionMin = specs['general_platform_version'].downcase.strip
        devicePlatformVersionMax = specs['general_platform_version_max'].downcase.strip

        if (platform.empty? || platformName.empty? || devicePlatformName.empty?)
          return true
        end
        if (platformName != devicePlatformName)
          return true
        end
        if (!platformVersion.empty? && devicePlatformVersionMin.empty? && comparePlatformVersion(platformVersion, devicePlatformVersionMin) <= -1)
          return false
        end
        if (!platformVersion.empty? && !devicePlatformVersionMax.empty? && !comparePlatformVersions(platformVersion, devicePlatformVersionMax) >= 1)
          return false
        end
        return true
      end

      def breakVersionApart(versionNumber)
        tmp = (versionNumber + "0.0.0.0").split('.', 4)
        reply = Hash.new
        reply['major'] = !tmp[0].empty? ? tmp[0] : '0'
        reply['minor'] = !tmp[1].empty? ? tmp[1] : '0'
        reply['point'] = !tmp[2].empty? ? tmp[2] : '0'
        return reply
      end

      def compareSmartly(a, b)
        return a.is_a?(Numeric) && b.is_a?(Numeric) ? a - b : a <=> b
      end

      def comparePlatformVersions(va, vb)
        if (va.empty? || vb.empty?)
          return 0
        end
        versionA = breakVersionApart(va)
        versionB = breakVersionApart(vb)
        major = compareSmartly(versionA['major'], versionB['major'])
        minor = compareSmartly(versionA['minor'], versionB['minor'])
        point = compareSmartly(versionA['point'], versionB['point'])

        if (major != 0)
          return major
        end
        if (minor != 0)
          return minor
        end
        if (point != 0)
          return point
        end

        return 0
      end
    end
    class HandsetStore

      def initialize()
        @cache = Hash.new
        @dir = Rails.root.to_s + '/tmp/files/handset_cache_store/'
      end

      def write(key, data)
        if (data == nil)
          return false
        end
        if (!store(key, data))
          return false
        end
        @Cache[key] = data
        return true
      end

      def store(key, data)
        jsonstr = JSON.generate(data)
        f = File.new(@dir + key + ".json", "w")
        f.write(jsonstr)
        f.close()
        return true
      end

      def read(key)
        if ((reply = @cache[key]) != nil)
          return reply
        end
        if ((reply = fetch(key)) != nil)
          @cache[key] = reply
          return reply
        end

        return nil
      end

      def fetch(key)
        file = File.read(@dir + key + ".json")
        if (file == nil)
          retur nil
        end
        return JSON.parse(file)
      end

      def fetchDevices()
        data = Hash.new
        data['devices'] = Array.new
        Dir.glob(@dir + "Device*.json") { |deviceFile|
          device = read(File.basename(deviceFile, ".json"))
          data['devices'].push(device)
        }
        return data
      end
    end

    class Configuration
      @@other_options = {
          'vendors' => '/device/vendors',
          'models' => '/device/models',
          'view' => '/device/view',
          'whathas' => '/device/whathas',
          'detect' => '/device/detect',
          'ultimateFetcharchive' => '/device/fetcharchive',
          'communityFetcharchive' => '/community/fetcharchive',
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

      def self.set(option, value)
        HANDSET_DETECTION_CONFIG[option] = value
      end
    end

    Dir[Rails.root.to_s + "/tmp/files/"]
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
      @@store = HandsetStore.new()

      def deviceVendors
        if (Configuration.get('server_detect') == 1)
          rep = hd_remote(Configuration.get('vendors') + ".json", "")
          headers,body = rep.split("\r\n\r\n",2)
        else
          body = localVendors()
        end

        return body
      end
#
      def deviceModels(vendor)
        if (Configuration.get('server_detect') == 1)
          rep = hd_remote(Configuration.get('models') +"/#{vendor}.json","")
          headers,body = rep.split("\r\n\r\n",2)
        else
          body = localModels(vendor)
        end

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

      def deviceDetect(data)
        id = Configuration.get('site_id')
        rep = hd_remote(Configuration.get('detect') + "/#{id}.json",data)
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

      def ultimateFetcharchive()
        id = Configuration.get('site_id')
        rep = hd_remote(Configuration.get('ultimateFetcharchive') + "/#{id}.json", "")
        File.open(Rails.root.to_s + '/tmp/files/ultimate.zip', 'wb') {|f| f.write(rep)}
        extract_files()
      end

      def communityFetcharchive()
        id = Configuration.get('site_id')
        rep = hd_remote(Configuration.get('communityFetcharchive') + "/#{id}.json", "")
        File.open(Rails.root.to_s + '/tmp/files/ultimate.zip', 'wb') {|f| f.write(rep)}
        extract_files()
      end

      def setErrorToReply(reply, status, message)
        reply['status'] = status
        reply['message'] = message
        return reply
      end

      def localVendors()
        reply = Hash.new
        data = @@store.fetchDevices()
        if (data == nil)
          return false
        end
        tmp = Array.new
        data['devices'].each { |item|
          tmp.push(item['Device']['hd_specs']['general_vendor'])
        }
        reply['vendor'] = tmp
        setErrorToReply(reply, 0, 'OK')
        return JSON.generate(reply)
      end

      def localModels(vendor)
        reply = Hash.new
        data = @@store.fetchDevices()
        if (data == nil)
          return nil
        end
        vendor = vendor.downcase
        tmp = Array.new
        data['devices'].each { |item|
          if (vendor == item['Device']['hd_specs']['general_vendor'].downcase)
            tmp.push(item['Device']['hd_specs']['general_model'])
          end
          key = vendor + " "
          if (item['Device']['hd_specs']['general_aliases'].length > 0)
            item['Device']['hd_specs']['general_aliases'].each { |alias_item|
              if (alias_item.index(key) == 0)
                tmp.push(alias_item.sub(key, ''))
              end
            }
          end
        }
        reply['model'] = tmp
        setErrorToReply(reply, 0, 'OK')
        return JSON.generate(reply)
      end

      def localView(vendor, model)
        reply = Hash.new
        data = @@store.fetchDevices()
        if (data == nil)
          return nil
        end
        vendor = vendor.downcase
        model = model.downcase
        data['devices'].each {|item|
          if (vendor == item['Device']['hd_specs']['general_vendor'].downcase && model == item['Device']['hd_specs']['general_model'].downcase)
            reply['device'] = item['device']['hd_specs']
            return setErrorToReply(reply, 0, 'OK')
          end
        }
        return JSON.generate(setErrorToReply(reply, 301, 'Nothing found'))
      end

      def localWhatHas(key, value)
        reply = Hash.new
        data = @@store.fetchDevices()
        if (data == nil)
          return nil
        end
        tmp = Array.new
        value = value.downcase
        data['devices'].each{|item|
          if (item['Device']['hd_specs'][key] != nil)
            match = false
            deviceValue = item['Device']['hd_specs'][key]
            if deviceValue.is_a?Array
              deviceValue.each{|check|
                if (check.index(value) != nil)
                  match = true
                end
              }
            else
              if (deviceValue.index(value) != nil)
                match = true
              end
            end
            if (match)
              tmpData = Hash.new
              tmpData['id'] = item['Device']['_id']
              tmpData['general_vendor'] = item['Device']['hd_specs']['general_vendor']
              tmpData['general_model'] = item['Device']['hd_specs']['general_model']
              tmp.push(tmpData)
            end
          end
        }
        reply['devices'] = tmp
        return JSON.generate(setErrorToReply(reply, 0, 'OK'))
      end

      def array_change_key_case(headers)
        headers.each{|key, value|
          headers[key.downcase] = value
        }
      end

      def localDetect(headers)
        array_change_key_case(headers)
        hardwareInfo = headers['x-local-hardwareinfo']
        headers.delete('x-local-hardwareinfo')
        if (hasBiKeys(headers))
          return v4MatchBuildInfo(headers)
        end
        return v4MatchHttpHeaders(headers, hardwareInfo)
      end

      def findRating(deviceId, props)
        device = findById(deviceId)
        if (device['Device']['hd_specs'].empty?)
          return nil
        end

        specs = device['Device']['hd_specs']

        total = 0
        result = Array.new

        if (!props['display_x'].empty? && !props['display_y'].empty?)
          total += 40
          if (specs['display_x'] == props['display_x'] && specs['display_y'] == props['display_y'])
            result['resolution'] = 40
          elsif (specs['display_x'] == props['display_y'] && specs['display_y'] == props['display_x'])
            result['resolution'] = 40
          elsif specs['display_pixel_ration'] > 1.0
            adjx = props['display_x'] * specs['display_pixel_ratio']
            adjy = props['display_y'] * specs['display_pixel_ratio']
            if (specs['display_x'] == adjx && specs['display_y'] == adjy)
              result['resolution'] = 40
            elsif specs['display_x'] == adjy && specs['display_y'] == adjx
              result['resolution'] = 40
            end
          end
        end

        if (!props['display_pixel_ration'].empty?)
          total += 40
          if (specs['display_pixel_ratio'] == round(props['display_pixel_ratio'] / 100, 2))
            result['display_pixel_ratio'] = 40
          end
        end

        if (!props['benchmark'].empty?)
          total += 20
          if (!specs['benchmark_min'].empty? && !specs['benchmark_max'].empty?)
            if (props['benchmark'].to_i >= specs['benchmark_min'].to_i && props['benchmark'].to_i <= specs['benchmark_max'].to_i)
              result['benchmark'] = 10
              result['benchmark_span'] = 10
            else
              result['benchmark'] = 0
              steps = (specs['benchmark_max'].to_i - specs['benchmark_min'].to_i) / 10
              if (props['benchmark'].to_i >= specs['benchmark_max'].to_i)
                tmp = round((props['benchmark'] - specs['benchmark_max']) / steps).to_i
                result['benchmark_span'] = 10 - (min(10, max(0, tmp)))
              end
            end
          end
        end
        result['score'] = (total == 0) ? 0 : round((array_sum(result) / total) * 100, 2).to_i
        result['possible'] = total
        result['distance'] = 100000
        if (!specs['benchmark_min'].empty? && !specs['benchmark_max'].empty? && !props['benchmark'].empty?)
          result['distance'] = abs(((specs['benchmark_min'] + specs['benchmark_max']) / 2) - props['benchmark']).to_i
        end
        return result
      end

      def specsOverlay(specsField, device, specs)
        case specsField
          when 'platform'
            if !specs['hd_specs']['general_platform'].empty?
              device['Device']['hd_specs']['general_platform'] = specs['hd_specs']['general_platform']
              device['Device']['hd_specs']['general_platform_version'] = specs['hd_specs']['general_platform_version']
            end
          when 'browser'
            if (!specs['hd_specs']['general_browser'].empty?)
              device['Device']['hd_specs']['general_browser'] = specs['hd_specs']['general_browser']
              device['Device']['hd_specs']['general_browser_version'] = specs['hd_specs']['general_browser_version']
            end
          when 'app'
            if !specs['hd_specs']['general_app'].empty?
              device['Device']['hd_specs']['general_app'] = specs['hd_specs']['general_app']
              device['Device']['hd_specs']['general_app_version'] = specs['hd_specs']['general_app_version']
              device['Device']['hd_specs']['general_app_category'] = specs['hd_specs']['general_app_category']
            end
          when 'language'
            if !specs['hd_specs']['general_language'].empty?
              device['Device']['hd_specs']['general_language'] = specs['hd_specs']['general_language']
              device['Device']['hd_specs']['general_language_full'] = specs['hd_specs']['general_language_full']
            end
        end
      end

      def infoStringToArray(hardwareInfo)
        if (hardwareInfo.include?('='))
          tmp = hardwareInfo.split('=', 2)
          if (tmp.length == 1)
            return Array.new
          else
            hardwareInfo = tmp[1]
          end
        end
        reply = Array.new
        info = hardwareInfo.split(':')
        if (info.length != 2)
          return Array.new
        end
        reply['display_x'] = info[0].to_i
        reply['display_y'] = info[1].to_i
        reply['display_pixel_ratio'] = info[2].to_i
        reply['benchmark'] = info[3].to_i
        return reply
      end

      def functionInfoOverlay(device, infoArray)
        if (!infoArray['display_x'].empty?)
          device['Device']['hd_specs']['display_x'] = infoArray['display_x']
        end
        if (!infoArray['display_y'].empty?)
          device['Device']['hd_specs']['display_y'] = infoArray['display_y']
        end
        if (!infoArray['display_pixel_ratio'].empty?)
          device['Device']['hd_specs']['display_pixel_ratio'] = infoArray['display_pixel_ratio']
        end
      end

      def matchDevice(headers)
        agent = ''
        if (!headers['x-operamini-phone'].empty? && headers['x-operamini-phone'] != "? # ?")
          id = getMatch('x-operamini-phone', headers['x-operamini-phone'], DETECTIONV4_STANDARD, 'x-operamini-phone', 'device')
          if (id != nil)
            return findById(id)
          end
          agent = headers['x-operamini-phone']
          headers.delete('x-operamini-phone')
        end

        if !headers['profile'].empty?
          id = getMatch('profile', headers['profile'], DETECTIONV4_STANDARD, 'profile', 'device')
          if (id != nil)
            return findById(id)
          end
        end

        if (!headers['x-wap-profile'])
          id = getMatch('profile', headers['x-wap-profile'], DETECTIONV4_STANDARD, 'x-wap-profile', 'device')
          if (id != nil)
            return findById(id)
          end
          headers.delete('x-wap-profile')
        end

        order = @detectionConfig['device-ua-order']
        headers.each{|key, value|
          if (order.include?(key) && /^x-i/.match(key))
            order.push(key)
          end
        }

        order.each{|item|
          if (!headers[item].empty?)
            id = getMatch('user-agent', headers[item], DETECTIONV4_STANDARD, item, 'device')
            if (id != nil)
              return findById(id)
            end
          end
        }

        if (headers.has_key?('x-operamini-phone-ua'))
          id = getMatch('user-agent', headers['x-operamini-phone-ua'], DETECTIONV4_GENERIC, 'agent', 'device')
        end
        if (id.empty? && headers.has_key?('agent'))
          id = getMatch('user-agent', headers['agent'], DETECTIONV4_GENERIC, 'agent', 'device')
        end
        if (!id.empty?)
          return findById(id)
        end
        return nil
      end

      def findById(id)
        return @@store.read("Device_#{id}")
      end

      def fetchDevices()
        result = @@store.fetchDevices()
        if (result == nil)
          result = Hash.new
          return setErrorToReply(result, 299, "Error : fetchDevices cannot read files from store.")
        end
        return setErrorToReply(result, 0, 'OK')
      end

      def v4MatchBuildInfo(buildInfo)
        @device = nil
        @platform = nil
        @browser = nil
        @app = nil
        @detectedRuleKey = nil
        @ratingResult = nil
        @reply = nil
        if (buildInfo.empty?)
          return nil
        end
        @buildInfo = buildInfo
        @device = v4MatchBiHelper(buildInfo, 'device')
        if (@device.empty?)
          return nil
        end

        @platform = v4MatchBiHelper(buildInfo, 'platform')
        if (!@platform.empty?)
          specsOverlay('platform', device, platform)
        end
        @reply['hd_specs'] = @device['Device']['hd_specs']
        return setErrorToReply(reply, 0, 'OK')
      end

      def v4MatchBIHelper(buildInfo)
        confBIKeys = @detectionConfig["#{category}-bi-order"]
        if (confBIKeys.empty? || buildInfo.empty?)
          return nil
        end

        hints = Array.new
        confBIKeys.each{|platform, set|
          value = ''
          set.each{|tuple|
            checking = true
            tuple.each{|item|
              if (!buildInfo.has_key?(item))
                checking = false
                break
              else
                value += "|#{buildInfo[item]}"
              end
            }
            if (checking)
              value.strip!
              hints.push(value)
              subtree = (category == 'device') ? DETECTIONV4_STANDARD : category
              id = getMatch('buildInfo', value, subtree, 'buildinfo', category)
              if (id != nil)
                return (category == 'device') ? findById(id) : @@extra.findById(id)
              end
            end
          }
        }

        platform = hasBiKeys(buildInfo)
        if (!platform.empty?)
          try = ["generic|#{platform}", "#{platform}|generic"]
          try.each{|value|
            subtree = (category == 'device') ? DETECTION4_GENERIC : category
            id = getMatch('buildinfo', value, subtree, 'buildinfo', category)
            if (id != nil)
              return (category == 'device') ? findById(id) : @@extra.findById(id)
            end
          }
        end

        return nil
      end

      def hasBiKeys(headers)
        biKeys = @detectionConfig['device-bi-order']
        if (headers.has_key?('agent'))
          return false
        end
        if (headers.has_key?('user-agent'))
          return false
        end

        biKeys.each{|platform, set|
          set.each{|tuple|
            count = 0
            total = tuple.length
            tuple.each{|item|
              if (headers.has_key?(item))
                count += 1
              end
              if (count == total)
                return platform
              end
            }
          }
        }
        return false
      end

      def v4MatchHttpHeaders(headers, hardwareInfo=nil)
        @device = nil
        @platform = nil
        @browser = nil
        @app = nil
        @ratingResult = nil
        @detectedRuleKey = Array.new
        @reply = nil
        @hwProps = nil

        if (headers.empty?)
          return nil
        end

        headers.delete('ip')
        headers.delete('host')

        headers.each{|key, value|
          if (key == 'accept-language' || key == 'content-language')
            key = 'language'
            tmp = value.downcase.replace(' ', '').split(/[,;]/)
            if (tmp.length > 0)
              value = tmp[0]
            else
              next
            end
          end
          @deviceHeaders[key.downcase] = cleanStr(value)
          @extraHeaders[key.downcase] = @@extra.extraCleanStr(value)
        }
        #@device = matchDevice(@deviceHeaders, )

        if (@device.empty?)
          return setErrorToReply(@reply, 301, "Not Found")
        end
        if (!hardwareInfo.empty?)
          hwProps = infoStringToArray(hardwareInfo)
        end
        if (!@device['Device']['hd_ops']['stop_on_detect'].empty?)
          if (!@device['Device']['hd_ops']['overlay_result_specs'])
            hardwareInfoOverlay(@device, hwProps)
          end
          @reply['hd_specs'] = @device['Device']['hd_specs']
          return setErrorToReply(@reply, 0, "OK")
        end

        @platform = @@extra.matchExtra('platform', @extraHeaders)
        @browser = @@extra.matchExtra('browser', @extraHeaders)
        @app = @@exstra.matchExtra('app', @extraHeaders)
        @language = @@extra.matchLnaguage(@extraHeaders)

        deviceList = getHighAccuracyCandidates()
        if (!deviceList.empty?)
          @@extra.set(@platform)
          pass1List = Array.new
          deviceList.each{|id|
            tryDevice = findById(id)
            if (@@extra.verifyPlatform(tryDevice['Device']['hd_specs']))
              pass1List.push(id)
            end
          }

          if (pass1List.length >= 2 && hwProps.empty?)
            result = Array.new
            pass1List.each{|id|
              tmp = findRating(id, hwProps)
              if (!tmp.empty?)
                tmp['_id'] = id
                result.push(tmp)
              end
            }
            result.sort!{|d1, d2|
              if ((d2['score'].to_i - id1['score'].to_i) != 0)
                return d2['score'].to_i - d1['score'].to_i
              end
              return sd1['distance'].to_i - d2['distance'].to_i
            }
            @ratingResult = result
            if (@ratingResult[0]['score'].to_i != 0)
              device = findById(result[0]['_id'])
              if (!device.empty?)
                @device = device
              end
            end
          end
        end

        specsOverlay('platform', @device, @platform['Extra'])
        specsOverlay('browser', @device, @browser['Extra'])
        specsOverlay('app', @device, @app['Extra'])
        specsOverlay('language', @device, @language['Extra'])

        if (!@device['Device']['hd_ops']['overlay_result_specs'].empty? && !hardwareInfo.empty?)
          hardwareInfoOverlay(@device, hwProps)
        end
        @reply['hd_specs'] = @device['Device']['hd_specs']
        return setErrorToReply(@reply, 0, 'OK')
      end

      def getHighAccuracyCandidates()
        branch = getBranch('hachecks')
        ruleKey = detectedRuleKey['device']
        if (!branch[ruleKey].empty?)
          return branch[ruleKey]
        end
        return nil
      end

      def isHelperUseful(headers)
        if (headers.empty?)
          return false
        end
        headers.delete('ip')
        headers.delete('host')
        if (localDetect(headers).empty?)
          return false
        end
        if (getHighAccuracyCandidates().empty?)
          return false
        end
        return true
      end
#
      def detect(data)
        #@@cache = ActiveSupport::Cache::FileStore.new(Rails.root.to_s + "/tmp/files/handset_cache_store")
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
        server_detect = Configuration.get('server_detect')
        if server_detect == 1
          return deviceDetect(data)
        elsif server_detect == 0
          resp_data = localDetect(data)
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
        Rails::logger.info 'set_cahe'
        if File::exists?(Rails.root.to_s + '/tmp/specs')
          Rails::logger.info 'files already exists , just setting up cache'
          @@cache ||= ActiveSupport::Cache.lookup_store(:memory_store)          
          f1=set_cache_specs_local()
          f3=set_cache_devices_local()
          f2=set_cache_trees_local()
          return (f1 and f2 and f3)
        else
          Rails::logger.info 'files doest exist , loading data from server , writing to files and then setting up cache'
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
		    #url = "http://" + apiserver + "/apiv4" + suburl + ".json"
        url = "http://" + apiserver + "/apiv4" + suburl
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
        realm = 'APIv4'
        secret = Configuration.get('password')

		    port = 80
		    nc = "00000001"

		    cnonce = Digest::MD5.hexdigest("#{Time.now}#{@secret}")
    		qop = 'auth'

    		ha1 = Digest::MD5.hexdigest("#{username}:#{realm}:#{secret}")

        ha2 = Digest::MD5.hexdigest("POST:/apiv4/#{suburl}.json")

    		response = Digest::MD5.hexdigest("#{ha1}:APIv4:#{nc}:#{cnonce}:#{qop}:#{ha2}")

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
        hd_request = hd_request + '"' + Configuration.get('username') + '"' + 'realm="APIv4", nonce="APIv4",'

        hd_request = hd_request + "uri=/apiv4/#{suburl}.json, qop=auth, nc=00000001, "
        hd_request = hd_request + 'cnonce="' + "#{cnonce}" + '", '
        hd_request = hd_request + 'response="' + "#{response}" + '", '

        hd_request = hd_request + 'opaque="APIv4"'
        hd_request = hd_request + "\r\n"
		    hd_request = hd_request +  "Content-length: #{jsondata.length}\r\n\r\n"
        hd_request = hd_request +  "#{jsondata}\r\n\r\n"
        socket.write(hd_request)

		    hd_reply = socket.read

        return hd_reply
      end
#
      def localSiteDetect(headers)
	      #@@cache = ActiveSupport::Cache::FileStore.new(Rails.root.to_s + "/tmp/files/handset_cache_store")
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
	Rails::logger.info field.include?('x-').to_s
	if !valuearr[field].nil? #and (field == 'user-agent' or field.include?('x-'))
	    id = matchExtra('user-agent', valuearr[field], cls)
	    if id 
		#returned		
	      return id
		Rails::logger.info "id" + id.to_s
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
            Rails::logger.info '======================================= ERROR IN SPECS ================================================='
            Rails::logger.info device
            Rails::logger.info id
            Rails::logger.info specs
          end        
        end             
        return true   
      end      
      
      def set_cache_specs_local()
	      file = File.new(Rails.root.to_s + '/tmp/specs','r')
        body = file.read()
        data = ActiveSupport::JSON.decode body
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
              Rails::logger.info '======================================= ERROR IN SPECS ================================================='
              Rails::logger.info device
              Rails::logger.info id
              Rails::logger.info specs
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
