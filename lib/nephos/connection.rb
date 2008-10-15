module Nephos

   class NephosRequest < Net::HTTPRequest
      attr_reader :signable_path
      def comp
         qstring_args['comp']
      end
      def comp=(operation)
         qstring_args['comp'] = operation
      end
      def add_qstring(name, value)
         qstring_args[name] = value
      end
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
         @signable_path = save_path
         path = build_real_path
         if method == 'PUT' and !body then
            self['content-length'] = 0
         end
         self['x-ms-date'] = Time.now.httpdate
      end

      private
      def build_real_path
         qpairs = []
         qstring_args.each_pair { |key,value|
            qpairs << key + '=' + URI.escape(value)
         }
         if qpairs.length > 0 then
            path + '?' + qpairs.join('&')
         else
            path
         end
      end
      def qstring_args
         @qstring = {} if !@qstring
         @qstring
      end
      def save_path
         spath = path
         spath << '?comp=' + comp if comp
         spath
      end
   end
   class Put < NephosRequest
      METHOD = 'PUT'
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
   end
   class Get < NephosRequest
      METHOD = 'GET'
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = true
   end

   class Connection
      def initialize(uri)
         @uri = uri
      end

      def do_request(request)
         http = http_class.new(@uri.host, @uri.port)

         request.add_qstring 'timeout', @uri.timeout.to_s
         request.complete
         HMACAuth.authorize request, @uri.account, @uri.shared_key

         http.request(request)
      end

      def http_class
         # TODO: add proxy support
         Net::HTTP
      end
   end

end
