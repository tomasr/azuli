module Nephos

   class NephosRequest < Net::HTTPRequest
      def add_metadata(metadata)
         metadata.each_pair { |key,value|
            set_metadata(key, value)
         }
      end
      def set_metadata(name, value)
         self['x-ms-meta-' + name.to_s] = value.to_s
      end
      def metadata
         metaprops = {}
         headers.each_key { |key|
            metaprops[key] = self[key] if key =~ /^x-ms-meta-/
         }
         metaprops
      end
      def set_property(name, value)
         self['x-ms-prop-' + name.to_s] = value.to_s
      end
      # Complete request so that headers make sense
      def complete
         if method == 'PUT' and !body then
            self['content-length'] = 0
         end
         self['x-ms-date'] = Time.now.httpdate
      end
   end
   class Put < NephosRequest
      METHOD = 'PUT'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
   end

   class Connection
      def initialize(uri, request)
         @uri = uri
         @request = request
      end

      def do_request
         http = http_class.new(@uri.host, @uri.port)

         @request.complete
         HMACAuth.authorize @request, @uri.account, @uri.shared_key

         http.request(@request)
      end

      def http_class
         # TODO: add proxy support
         Net::HTTP
      end
   end

end
