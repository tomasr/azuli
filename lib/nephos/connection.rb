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
         qstring_args[name.to_s] = value.to_s
      end
      def add_qstring_params(params)
         params.each_pair { |key,value|
            add_qstring(key, value)
         }
      end
      def add_metadata(metadata)
         metadata.each_pair { |key,value|
            set_metadata(key, value)
         }
      end
      def set_metadata(name, value)
         self[Metadata.as_meta(name.to_s)] = value.to_s
      end
      def metadata
         metaprops = {}
         headers.each_key { |key|
            metaprops[key] = self[key] if Metadata.is_meta(key)
         }
         metaprops
      end
      def set_property(name, value)
         self['x-ms-prop-' + name.to_s] = value.to_s
      end
      # Complete request so that headers make sense
      def complete
         @signable_path = save_path
         @path = build_real_path

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
         spath = String.new path
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
   class Head < NephosRequest
      METHOD = 'HEAD'
      REQUEST_HAS_BODY = false
      RESPONSE_HAS_BODY = false
   end

   class Connection
      def initialize(uri)
         @uri = uri
         @http = http_class.new(@uri.host, @uri.port)
      end

      def do_request(request, allow_conflict = false)
         request.add_qstring 'timeout', @uri.timeout
         request.complete

         HMACAuth.authorize request, @uri.account, @uri.shared_key

         response = @http.request(request)
         check_response response, allow_conflict
         response
      end

      def http_class
         # TODO: add proxy support
         Net::HTTP
      end

      def check_response(response, allow_conflict = false)
         if response.kind_of? Net::HTTPSuccess then
            # nothing
         elsif allow_conflict and response.kind_of? Net::HTTPConflict then
            # nothing
         elsif response.content_type == 'application/xml' then
            raise NephosException.new(response.body)
         else
            response.value() # force error
         end
      end
   end

   class NephosException < Exception
      attr_reader :code, :exception_message, :stack_trace
      def initialize(error_xml)
         error = XmlSimple.xml_in(error_xml)
         @code = error['Code']
         details = error['ExceptionDetails'][0]
         if details then
            @exception_message = details['ExceptionMessage']
            @stack_trace = details['StackTrace']
         end
         super error['Message']
      end
   end
end
